"""核实PCIe配置并启动持续采集。"""
import fcntl
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
APP = ROOT / 'capture/build/app'
MODULE = ROOT / 'driver/pango_pci_driver.ko'
DEVICE = '0002:21:00.0'
PCI = Path('/sys/bus/pci/devices') / DEVICE
RUNTIME = ROOT / 'runtime'
RAW = Path('/dev/shm/fpga_current_frame_1280x720.rgb565')
KNOWN_APPS = {str(APP), '/userdata/qiansai_v1/RK_code_newest/app_pcie/build/app'}


def command(args):
    return subprocess.run(args, check=True, capture_output=True, timeout=15)


def capture_pids():
    rows = []
    for path in Path('/proc').glob('[0-9]*/cmdline'):
        try:
            first = path.read_bytes().split(b'\0')[0].decode()
            if first in KNOWN_APPS:
                rows.append(int(path.parent.name))
        except (OSError, UnicodeError):
            pass
    return rows


def stop_capture():
    for pid in capture_pids():
        subprocess.run(['sudo', '-n', 'kill', '-TERM', str(pid)], check=False, timeout=5)
    for _ in range(30):
        if not capture_pids():
            return
        time.sleep(.1)
    raise RuntimeError('Capture process did not stop; PCIe configuration was not changed.')


def resource_addresses(text):
    lines = text.splitlines()
    if len(lines) < 3:
        raise RuntimeError('Incomplete PCIe resources')
    addresses = []
    for line, size in zip(lines[:3], (8192, 4096, 8192)):
        start, end, flags = (int(word, 16) for word in line.split())
        if (not flags & 0x200 or flags & 0x100000 or start <= 0 or end > 0xffffffff
                or end-start+1 != size or start % size):
            raise RuntimeError('Unexpected FPGA PCIe resource assignment')
        addresses.append(start)
    sizes = (8192, 4096, 8192)
    for index, address in enumerate(addresses):
        for other_index in range(index+1, 3):
            if address < addresses[other_index]+sizes[other_index] and addresses[other_index] < address+sizes[index]:
                raise RuntimeError('Overlapping PCIe resources')
    return addresses


def read_configuration():
    output = command(['sudo', '-n', 'setpci', '-s', DEVICE,
                      '10.l', '14.l', '18.l', 'COMMAND']).stdout.decode().split()
    if len(output) != 4:
        raise RuntimeError('Cannot read PCIe configuration')
    values = [int(word, 16) for word in output]
    return values[:3], values[3]


def prepare_pcie():
    if not PCI.is_dir():
        raise RuntimeError('FPGA PCIe device is not enumerated; check board power and FPGA loading.')
    if (PCI/'vendor').read_text().strip() != '0x0755' or (PCI/'device').read_text().strip() != '0x0755':
        raise RuntimeError('Unexpected PCIe device; no configuration was changed.')
    expected = resource_addresses((PCI/'resource').read_text())
    bars, control = read_configuration()
    if bars == expected and control & 6 == 6:
        print('PCIe configuration ready', flush=True)
        return
    if any(value not in (0, address) for value, address in zip(bars, expected)):
        raise RuntimeError('Conflicting PCIe BAR values; automatic recovery refused.')
    # 仅恢复已核实的本板设备，使用Linux分配地址，不重新分配PCIe资源。
    stop_capture()
    backup = RUNTIME / ('pci_config_' + time.strftime('%Y%m%d_%H%M%S') + '.bin')
    backup.write_bytes(command(['sudo', '-n', 'cat', str(PCI/'config')]).stdout)
    writes = ['%02x.l=%08x' % (16+4*index, address) for index, address in enumerate(expected)]
    command(['sudo', '-n', 'setpci', '-s', DEVICE, *writes, 'COMMAND=0006:0006'])
    bars, control = read_configuration()
    if bars != expected or control & 6 != 6:
        raise RuntimeError('PCIe recovery verification failed; capture not started. Backup: ' + str(backup))
    print('PCIe configuration restored: ' + ', '.join('%08x' % value for value in bars), flush=True)


def serve():
    # 持续持有控制管道，避免采集超时后因输入结束直接退出。
    names = ('DISPLAY', 'XAUTHORITY', 'PCIE_SHOW_WINDOW', 'PCIE_MAX_FRAMES',
             'PCIE_NPU_RAW_INTERVAL', 'PCIE_NPU_JPG_INTERVAL')
    values = (':0', '/home/linaro/.Xauthority', '0', '0', '1', '100')
    proc = subprocess.Popen(['sudo', '-n', 'env',
                             *[key+'='+value for key, value in zip(names, values)], str(APP)],
                            cwd=str(APP.parent), stdin=subprocess.PIPE)
    try:
        proc.stdin.write(b'y\n')
        proc.stdin.flush()
        return proc.wait()
    finally:
        proc.stdin.close()


def start_capture():
    with (RUNTIME/'capture.log').open('ab') as log:
        subprocess.Popen(['/usr/bin/python3', str(Path(__file__).resolve()), '--serve'],
                         cwd=str(ROOT), stdin=subprocess.DEVNULL, stdout=log,
                         stderr=subprocess.STDOUT, start_new_session=True)


def wait_frames(seconds):
    seen = set()
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        time.sleep(.25)
        try:
            stat = RAW.stat()
            if stat.st_size == 1843200 and 0 <= time.time()-stat.st_mtime < .5:
                seen.add(stat.st_mtime_ns)
        except FileNotFoundError:
            pass
        if len(seen) >= 3:
            return True
    return False


def main():
    RUNTIME.mkdir(exist_ok=True)
    with (RUNTIME/'capture_start.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError('Another capture startup is running; wait for it to finish.')
        prepare_pcie()
        APP.chmod(APP.stat().st_mode | 0o111)
        if 'pango_pci_driver ' not in Path('/proc/modules').read_text():
            command(['sudo', '-n', 'insmod', str(MODULE)])
        if not capture_pids():
            start_capture()
        if not wait_frames(15):
            # 超时后旧进程可能正等待重新输入，最多重启一次，不无限重试。
            stop_capture()
            prepare_pcie()
            start_capture()
            if not wait_frames(15):
                stop_capture()
                raise RuntimeError('PCIe configuration is ready but no continuous frames. '
                                   'Check HDMI input and FPGA video state. Log: ' + str(RUNTIME/'capture.log'))
        print('Capture ready')


if __name__ == '__main__':
    try:
        raise SystemExit(serve() if '--serve' in sys.argv else main())
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        raise SystemExit(str(error))
