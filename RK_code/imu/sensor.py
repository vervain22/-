
import ctypes
import json
import os
import re
import struct
import time
from pathlib import Path

CONFIG = ((0x6B, 0x01), (0x6C, 0x00), (0x1A, 0x03),
          (0x19, 0x09), (0x1B, 0x08), (0x1C, 0x08))


def inventory(root=Path('/sys/bus/i2c/devices')):

    result = []
    for adapter in sorted(root.glob('i2c-*')):
        number = int(adapter.name.split('-')[1])
        clients = []
        for p in sorted(root.glob(str(number) + '-*')):
            if not re.fullmatch(r'\d+-[0-9a-fA-F]{4}', p.name):
                continue
            name = p / 'name'
            clients.append(dict(address='0x%02x' % int(p.name.split('-')[1], 16),
                                name=name.read_text().strip() if name.exists() else None,
                                driver=(p / 'driver').resolve().name
                                if (p / 'driver').is_symlink() else None))
        name = adapter / 'name'
        result.append(dict(bus=number, device='/dev/i2c-' + str(number),
                           name=name.read_text().strip() if name.exists() else None,
                           clients=clients))
    return result


class Message(ctypes.Structure):
    _fields_ = [('addr', ctypes.c_uint16), ('flags', ctypes.c_uint16),
                ('length', ctypes.c_uint16), ('buffer', ctypes.c_void_p)]


class Transfer(ctypes.Structure):
    _fields_ = [('messages', ctypes.POINTER(Message)), ('count', ctypes.c_uint32)]


class LinuxI2C:
    def __init__(self, bus, address):
        if bus not in (2, 3, 5) or address not in (0x68, 0x69):
            raise ValueError('Bring-up permits only candidate buses 2/3/5 and addresses 0x68/0x69')
        import fcntl
        self.address = address
        self.fd = None
        client = Path('/sys/bus/i2c/devices/%d-%04x' % (bus, address))
        if client.exists():
            raise RuntimeError('Address already registered by kernel: ' + str(client))
        fd = os.open('/dev/i2c-%d' % bus, os.O_RDWR | os.O_CLOEXEC)
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            
            
            fcntl.ioctl(fd, 0x0703, address)  
            capabilities = ctypes.c_ulong()
            fcntl.ioctl(fd, 0x0705, capabilities)  
            if not capabilities.value & 1:
                raise RuntimeError('Adapter lacks I2C_FUNC_I2C')
        except BaseException:
            os.close(fd)
            raise
        self.fd = fd
        self.fcntl = fcntl

    def read(self, register, size):
        if not 0 <= register <= 255 or not 1 <= size <= 14:
            raise ValueError('Invalid register read')
        pointer = (ctypes.c_uint8 * 1)(register)
        output = (ctypes.c_uint8 * size)()
        messages = (Message * 2)(
            Message(self.address, 0, 1, ctypes.addressof(pointer)),
            Message(self.address, 1, size, ctypes.addressof(output)))
        request = Transfer(messages, 2)
        done = self.fcntl.ioctl(self.fd, 0x0707, request)  
        if done != 2:
            raise OSError('Incomplete I2C register read: %s messages' % done)
        return bytes(output)

    def write(self, register, value):
        if os.write(self.fd, bytes((register, value))) != 2:
            raise OSError('Incomplete I2C register write')

    def close(self):
        if self.fd is not None:
            os.close(self.fd)
            self.fd = None


def identify(device):
    identity = device.read(0x75, 1)[0]
    if identity != 0x68:
        raise RuntimeError('Unexpected WHO_AM_I=0x%02x; no configuration written' % identity)
    return identity


def configure(device, sleep=time.sleep):
    identify(device)
    for register, value in CONFIG:
        device.write(register, value)
        if register == 0x6B:
            sleep(0.1)
        actual = device.read(register, 1)[0]
        if actual != value:
            raise RuntimeError('Config readback failed at 0x%02x: 0x%02x != 0x%02x'
                               % (register, actual, value))
    sleep(0.1)


def decode(data):
    if len(data) != 14:
        raise ValueError('Expected a complete 14-byte sample')
    ax, ay, az, temperature, gx, gy, gz = struct.unpack('>7h', data)
    return dict(accel_g=[v / 8192.0 for v in (ax, ay, az)],
                gyro_dps=[v / 65.5 for v in (gx, gy, gz)],
                temperature_c=temperature / 340.0 + 36.53)


def read_sample(device, clock=time.monotonic, sleep=time.sleep):

    end = clock() + 0.1
    while True:
        if device.read(0x3A, 1)[0] & 1:
            return decode(device.read(0x3B, 14))
        if clock() >= end:
            raise RuntimeError('No DATA_RDY within 100ms')
        sleep(0.001)
