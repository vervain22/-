from night_candidates import attach as attach_night_candidates
from adas_advisories import Advisories
from action_history import ActionHistory

import bootstrap
import argparse,collections,hashlib,json,logging,os,signal,threading,time,traceback
from pathlib import Path
import cv2,numpy as np
from pipeline import RAW,read_pair
from paired_hub import PairedHub as FrameHub
from hybrid_worker import SignalWorker
from camera_tracking import CameraWorker
from adapters import environment
from decision import Engine
from unified import Worker
from presentation import assemble,render,warmup
from sample_buffer import SampleBuffer
from memory_guard import MemoryGuard
from board_key import BoardKey
from imu_link import ImuLink
from virtual_drive import VirtualDrive,attach_simulation
from display_hold import LightBoxHold
from visual_alerts import alert_flags
from lane_timing import EVIDENCE_TTL,OBSERVATION_GAP,DISPLAY_TTL,CONFIRMATIONS,TEXT_HOLD
from lane_display_latch import LaneDisplayLatch as LaneTextHold
from modes import SCENES,SCHEDULES,next_scene,scene_inputs,annotate

def publish(path,value):
    temporary=path.with_suffix('.tmp');temporary.write_text(json.dumps(value,ensure_ascii=False),encoding='utf-8');temporary.replace(path)

def no_competing_consumer():

    conflicts=[]
    for proc in Path('/proc').glob('[0-9]*'):
        if int(proc.name)==os.getpid():continue
        try:
            argv=(proc/'cmdline').read_bytes().split(b'\0')
            executable=Path(argv[0].decode(errors='replace')).name
            if not executable.startswith('python'):continue
            cmd=b' '.join(argv).decode(errors='replace')
            if not any(x in cmd for x in ('main.py','live.py','preview.py')):continue
            cwd=str((proc/'cwd').resolve());description=cmd+' '+cwd
            if any(x in description for x in ('dual_recognition','lane_','quad_integrated','quad_modes')):conflicts.append(description)
        except (OSError,PermissionError):continue
    if conflicts:raise RuntimeError('Other recognition consumer running: '+repr(conflicts))

def save_sample(out,index,display,result,debug):
    name=f'sample_{index:04d}';cv2.imwrite(str(out/(name+'_quad.jpg')),display)
    publish(out/(name+'_display.json'),result)
    if debug:
        row,(image,outputs)=debug
        if not cv2.imwrite(str(out/(name+'_lane_source.png')),image):raise IOError('sample write')
        np.savez_compressed(out/(name+'_lane_outputs.npz'),output_0=outputs[0],output_1=outputs[1])
        publish(out/(name+'_lane.json'),row)

def main():
    import fcntl
    parser=argparse.ArgumentParser();parser.add_argument('--seconds',type=float,default=8)
    parser.add_argument('--dense-lane-samples',action='store_true',help='Bounded test only: retain up to 12 consecutive exact lane pairs; compress after workers stop')
    parser.add_argument('--preview',action='store_true',help='Keep observation window running until ESC/x or SIGTERM; bounded diagnostic history')
    parser.add_argument('--headless',action='store_true');parser.add_argument('--raw',type=Path,default=RAW)
    parser.add_argument('--scene',choices=SCENES,default='LANE_CHANGE')
    parser.add_argument('--no-board-key',action='store_true',help='Keyboard-only diagnostic run')
    parser.add_argument('--no-imu',action='store_true',help='Explicit no-sensor diagnostic mode')
    parser.add_argument('--windowed',action='store_true',help='Start in a resizable window; F toggles fullscreen')
    parser.add_argument('--hdmi-nav-profile',choices=('off','material3_lower_left'),default='off',help='Opt-in fixed navigation-screen exclusion for material 3 composition')
    args=parser.parse_args()
    if args.dense_lane_samples and args.preview:raise ValueError('Dense lane audit requires bounded test, never preview')
    if not args.preview and not 0<args.seconds<=60:raise ValueError('Integration tests bounded to 0..60 seconds')
    lock=Path('/tmp/qiansai_unified_npu.lock').open('w');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    no_competing_consumer();bootstrap.runtime();cv2.setNumThreads(1);warmup()
    out=bootstrap.ROOT/time.strftime(('preview_' if args.preview else 'run_')+'%Y%m%d_%H%M%S');out.mkdir()
    (bootstrap.ROOT/'latest_run.txt').write_text(str(out))
    sources={str(p.relative_to(bootstrap.ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in bootstrap.ROOT.rglob('*.py')}
    publish(out/'configuration.json',dict(code_sha256=sources,ttl=.5,schedule=SCHEDULES,initial_scene=args.scene,
        npu_calling_threads=1,npu_model_contexts=3,signal_detector='reference_localization_fpga_same_frame_color',hdmi_display_classes=['zebra','person','red','green','black','yellow'],signal_fallback_enabled=False,light_box_hold_seconds=.8,unknown_signal_blocks=False,first_current_red_is_effective=True,reference_decision_extra_score_cutoff=False,same_packet_signal=True,hdmi_nav_profile=args.hdmi_nav_profile,red_green_conflict_policy='KEEP_LAST_CONFIRMED_UNTIL_CONFLICT_ENDS',max_pending_lane_cpu=1,original_capture_controlled=False,
        lane_paint_features='v2_same_packet_lower_half',lane_evidence_ttl=EVIDENCE_TTL,lane_observation_gap=OBSERVATION_GAP,lane_display_ttl=DISPLAY_TTL,lane_confirmations=CONFIRMATIONS,lane_text_hold=None,dense_lane_samples=args.dense_lane_samples,
        lane_change_flow='REQUEST_CONFIRM_CANCEL',lane_demo_mapping='IMAGE_SIDE_TO_VIRTUAL_BOUNDARY',
        lane_raw_confirmed_unchanged=True,lane_boundary_memory_seconds=None,lane_type_memory_confirmations=1,lane_display_decision_shared_state=True,lane_type_display_last_valid_until_replaced=True,lane_no_detection_skips_type_gate=True,lane_rejection_flash_cycles=3,side_camera_does_not_gate_straight_while_requested=True,lane_memory_requires_driver_ready=False,camera_priority_between_lane_npu=True,memory_maintenance_interval=30,
        mode='LIVE_SIMULATION',preview=args.preview,board_key_enabled=not args.no_board_key,camera_lane_enabled=False,imu_enabled=not args.no_imu,hardware_actuation=False))
    from display_cadence import DisplayCadence
    cadence=DisplayCadence(30);last_diagnostic=-float("inf")
    stopped=threading.Event();neutral_requested=threading.Event()
    signal.signal(signal.SIGUSR1,lambda *_:neutral_requested.set())
    for sig in (signal.SIGINT,signal.SIGTERM):signal.signal(sig,lambda *_:stopped.set())
    hub=FrameHub(args.raw);worker=Worker(hub,scene=args.scene,nav_profile=args.hdmi_nav_profile);light=tracking=board_key=imu=None
    from logging.handlers import RotatingFileHandler
    logger=logging.getLogger('unified_signals');logger.setLevel(logging.INFO)
    logger.addHandler(RotatingFileHandler(out/'signal_jobs.jsonl',maxBytes=2_000_000,backupCount=1))
    samples=SampleBuffer(limit=12 if args.dense_lane_samples else 8,max_bytes=96*1024*1024 if args.dense_lane_samples else 64*1024*1024);sample_count=0;last_save=-100;last_debug_ns=None
    rows=collections.deque(maxlen=600) if args.preview else [];error=None;loop=0;eventid=0;engine=Engine(mode='OBSERVATION',scene=args.scene);event=None;display=None
    memory_guard=MemoryGuard()
    window='Smart Traffic';started=time.monotonic();last_transition=None
    try:
        if not worker.ready.wait(25) or worker.error:raise RuntimeError('NPU init: '+str(worker.error))
        if not args.no_board_key:
            board_key=BoardKey()
            if not board_key.ready.wait(5) or board_key.error:raise RuntimeError('Board key: '+str(board_key.error))
        drive=VirtualDrive();advisories=Advisories();history=ActionHistory();box_hold=LightBoxHold(.8);lane_text=LaneTextHold()
        if not args.no_imu:imu=ImuLink()
        light=SignalWorker(worker,hub,logger);tracking=CameraWorker(worker,hub)
        publish(out/'ready.json',dict(ready=True,scene=args.scene,board_key=not args.no_board_key))
        if not args.headless:
            cv2.namedWindow(window,cv2.WINDOW_NORMAL | cv2.WINDOW_GUI_NORMAL)
            
            
            cv2.resizeWindow(window,1035,660);cv2.moveWindow(window,0,0)
            fullscreen=not args.windowed
            cv2.setWindowProperty(window,cv2.WND_PROP_FULLSCREEN,
                                  cv2.WINDOW_FULLSCREEN if fullscreen else cv2.WINDOW_NORMAL)
        start=time.monotonic()
        while not stopped.is_set() and (args.preview or time.monotonic()-start<args.seconds):
            begin=time.perf_counter()
            for part in (worker,light,tracking):
                if part.error:raise RuntimeError(part.error)
            try:
                hdmi,camera,stamp,ns=read_pair(hub);images=(hdmi,camera)
            except (OSError,ValueError):images=(None,None);stamp=None;ns=None
            scene,mode_epoch=worker.scene_snapshot()
            if neutral_requested.is_set():
                if imu:imu.reset(neutral=True)
                neutral_requested.clear()
            requested_scene=None
            changed=False
            if board_key:
                if board_key.error:raise RuntimeError('Board key disconnected: '+board_key.error)
                for press in board_key.drain():
                    logger.info(json.dumps(dict(board_key_action=press['action'],held_seconds=press.get('held_seconds'),timestamp=press['timestamp'])))
                    if press['action']=='RECENTER':
                        if imu:imu.reset(neutral=True)
                        continue
                    requested_scene=next_scene(worker.scene_snapshot()[0])
                    changed=worker.set_scene(requested_scene) or changed
                    logger.info(json.dumps(dict(board_key_release=True,source='UBOOT',keycode=115,
                        timestamp=press['timestamp'],scene=requested_scene,mode_epoch=worker.scene_snapshot()[1])))
            if event and event['action']=='RECENTER':
                if imu:imu.reset(neutral=True)
                event=None
            if event and event['action']=='STOP' and imu:
                imu.reset(neutral=False);event=None
            if event and event['action'].startswith('SCENE_'):requested_scene=event['action'][6:]
            if requested_scene:changed=worker.set_scene(requested_scene) or changed
            if changed:
                scene,mode_epoch=worker.scene_snapshot()
                engine=Engine(mode='OBSERVATION',scene=scene);event=None
                if imu:imu.reset(preserve_calibration=True)
                logger.info(json.dumps(dict(scene_switch=True,scene=scene,mode_epoch=mode_epoch,timestamp=time.time())))
            now=time.time();packets,_=worker.snapshot();lane=worker.lane_snapshot()
            packets,signal_result,lane,geometry=scene_inputs(scene,mode_epoch,packets,light.latest,lane,tracking.latest)
            key_status='keyboard_only' if board_key is None else 'ready'
            result=assemble(packets,signal_result,lane,geometry,now,stamp)
            annotate(result,scene,mode_epoch,key_status)
            attach_night_candidates(result,packets.get('hdmi'),now)
            result['capture_epoch']=hub.generation
            
            
            lane_for_decision=lane if result['lane']['current'] else None
            env=environment(now,lane_for_decision,result)
            state=engine.update(now,env,event);event=None
            box_hold.update(result,now)
            state=attach_simulation(result,drive,imu.snapshot() if imu else None,now)
            result.update(state=state,camera_lane_enabled=False)
            lane_text.update(result,now)
            result['visual_alerts']=alert_flags(result,state,now)
            advisories.update(result,state,now)
            history.update(result,state,now)
            display=render(images,result,state,now)
            
            
            submitted=time.time()
            deadlines=[result['camera'].get('expires_at',0),result['hdmi'].get('expires_at',0),result['lane'].get('valid_until') or 0]
            deadlines.append((result.get('lane_model_display_source') or {}).get('expires_at',0))
            deadlines.extend(a.get('expires_at',0) for a in result.get('lane_text',{}).values())
            if (worker.lane_snapshot() is not lane or any(now<=d<submitted for d in deadlines)
                    or worker.snapshot()[0].get('lane_display') is not packets.get('lane_display')
                    or stamp is not None and now<=stamp+.5<submitted):
                
                
                
                try:
                    hdmi,camera,stamp,ns=read_pair(hub);images=(hdmi,camera)
                except (OSError,ValueError):images=(None,None);stamp=None;ns=None
                packets,_=worker.snapshot();lane=worker.lane_snapshot();submitted=time.time()
                packets,signal_result,lane,geometry=scene_inputs(scene,mode_epoch,packets,light.latest,lane,tracking.latest)
                result=assemble(packets,signal_result,lane,geometry,submitted,stamp)
                annotate(result,scene,mode_epoch,key_status)
                attach_night_candidates(result,packets.get('hdmi'),submitted)
                result['capture_epoch']=hub.generation
                state=engine.update(submitted,environment(submitted,lane if result['lane']['current'] else None,result))
                box_hold.update(result,submitted)
                state=attach_simulation(result,drive,imu.snapshot() if imu else None,submitted)
                result.update(state=state,camera_lane_enabled=False)
                if stamp is None or not 0<=submitted-stamp<=.5:images=(None,None)
                lane_text.update(result,submitted)
                result['visual_alerts']=alert_flags(result,state,submitted)
                advisories.update(result,state,submitted)
                history.update(result,state,submitted)
                display=render(images,result,state,submitted)
            transition=(scene,mode_epoch,(result.get('imu') or {}).get('epoch'),state['intent'],state['executed'],
                        state['decision']['status'],tuple(state['decision']['reasons']))
            if transition!=last_transition:
                logger.info(json.dumps(dict(virtual_transition=True,timestamp=result['published_at'],state=state,
                    imu=result.get('imu'),camera=result['camera'],capture_timestamp=result.get('capture_timestamp'))))
                last_transition=transition
            latest_job=worker.jobs[-1] if worker.jobs else {}
            timing={k:latest_job[k] for k in ('channel','source_ns','seconds','input_age','completed_age','profile') if k in latest_job}
            result['runtime_timing']=dict(frame_decode_seconds=hub.last_read_seconds,last_job=timing)
            diagnostic_now=time.monotonic()
            if diagnostic_now-last_diagnostic>=.2:
                publish(out/'latest.json',result)
                last_diagnostic=diagnostic_now
            rows.append(dict(now=time.time(),scene=scene,mode_epoch=mode_epoch,source_ns=ns,camera_valid=result['camera']['valid'],light_valid=result['hdmi']['valid'],
                lane_current=result['lane']['current'],lane_source_ns=result['lane']['source_ns'],lane_sides=[{k:v for k,v in side.items() if k!='observed_fragments'} for side in result['lane']['sides']],
                visible_targets=len(result['camera']['rendered_detections']),executed=state['executed'],virtual_lane=state['virtual_lane'],decision=state['decision'],last_request=state['last_request'],loop_seconds=time.perf_counter()-begin))
            rows[-1].update(signal_state=result['hdmi']['state'],signal_reason=result['hdmi']['reason'],
                diagnostics=result['diagnostics'],imu=result.get('imu'),signal_timing=light.latest.get('timing'),runtime_timing=result['runtime_timing'])
            debug=worker.lane_debug
            if not args.preview and sample_count<(12 if args.dense_lane_samples else 8) and time.monotonic()-last_save>=(0 if args.dense_lane_samples else 4) and debug and debug[0]['source_ns']!=last_debug_ns:
                if samples.append(display,result,debug):sample_count+=1
                last_save=time.monotonic();last_debug_ns=debug[0]['source_ns']
            memory_report=memory_guard.poll()
            if memory_report:publish(out/'memory.json',memory_report)
            loop+=1
            if args.headless:stopped.wait(.02)
            else:
                cv2.imshow(window,display);key=cv2.waitKey(1)&255
                cadence.wait(stopped)
                if key in (27,ord('x')):break
                if key in (ord('f'),ord('F')):
                    fullscreen=not fullscreen
                    cv2.setWindowProperty(window,cv2.WND_PROP_FULLSCREEN,
                                          cv2.WINDOW_FULLSCREEN if fullscreen else cv2.WINDOW_NORMAL)
                    continue
                action={ord('r'):'RECENTER',ord('0'):'NEUTRAL',ord('w'):'FORWARD',ord('s'):'BACKWARD',ord('a'):'CHANGE_LEFT',ord('d'):'CHANGE_RIGHT',ord('q'):'TURN_LEFT',ord('e'):'TURN_RIGHT',32:'STOP',ord('1'):'SCENE_INTERSECTION',ord('2'):'SCENE_LANE_CHANGE',ord('3'):'SCENE_NIGHT'}.get(key)
                if action:eventid+=1;event=dict(id=eventid,timestamp=time.time(),action=action)
    except BaseException:error=traceback.format_exc()
    finally:
        stopped.set()
        for part in (imu,board_key,tracking,light,worker,hub):
            try:
                if part is not None:part.close()
            except BaseException:error=(error or '')+traceback.format_exc()
        try:
            samples.flush(out,save_sample)
        except BaseException:error=(error or '')+traceback.format_exc()
        if display is not None:cv2.imwrite(str(out/'last_frame.png'),display)
        cv2.destroyAllWindows()
        publish(out/'latest.json',dict(consumer_stopped=True,vehicle_permission=False,state=dict(executed='STOP'),camera=dict(valid=False,detections=[]),hdmi=dict(valid=False,state='UNKNOWN'),lane=dict(current=False,sides=[])))
        publish(out/'summary.json',dict(error=error,elapsed=time.monotonic()-started,iterations=loop,rows=list(rows),
            preview=args.preview,rows_truncated=loop>len(rows),
            jobs=worker.jobs,lane_jobs=worker.lane_jobs,lane_skipped_busy=worker.lane_skipped_busy,lane_rejected_epoch=worker.lane_rejected_epoch,
            samples=sample_count,sample_buffer_bytes=samples.bytes,samples_dropped=samples.dropped,
            compression_after_workers_stopped=True,capture_controlled=False,accuracy_validated=False))
        print(json.dumps(dict(output=str(out),error=error,iterations=loop)),flush=True)
    if error:raise RuntimeError(error)

if __name__=='__main__':main()

