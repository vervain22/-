
SCENES = ('LANE_CHANGE', 'INTERSECTION', 'NIGHT')
SCHEDULES = {
    'NIGHT': ('hdmi', 'camera'),
    'INTERSECTION': ('hdmi', 'camera'),
    'LANE_CHANGE': ('lane', 'camera'),
}
LABELS = {'NIGHT': '夜间', 'INTERSECTION': '路口', 'LANE_CHANGE': '变道', 'CAMERA_RISK': '摄像头风险'}

def next_scene(scene):
    return SCENES[(SCENES.index(scene) + 1) % len(SCENES)]

def scene_inputs(scene, epoch, packets, signal, lane, geometry):

    def matched(row):
        return row is not None and row.get('mode_epoch') == epoch
    packets = {k: v if matched(v) else None for k, v in packets.items()}
    hp = packets.get('hdmi')
    if scene in ('INTERSECTION','NIGHT') and hp is not None and 'signal' in hp:
        paired = hp['signal']
        if (matched(paired) and paired.get('source_timestamp') == hp.get('source_timestamp')
                and paired.get('source_ns') == hp.get('source_ns')):
            signal = paired
        else:
            signal = dict(valid=False, state='UNKNOWN', tracks=[], reason='signal_packet_mismatch')
    if scene not in ('INTERSECTION','NIGHT') or not matched(signal):
        signal = dict(valid=False, state='UNKNOWN', tracks=[], reason='mode_disabled_or_switching')
    if scene != 'LANE_CHANGE' or not matched(lane):
        lane = None
    if scene != 'LANE_CHANGE':packets.pop('lane_display',None)
    if not matched(geometry):
        geometry = dict(rows=[])
    return packets, signal, lane, geometry

def annotate(result, scene, epoch, key_status):
    result.update(scene=scene, mode_epoch=epoch, board_key=key_status,
                  enabled=dict(signal=scene in ('INTERSECTION','NIGHT'), lane=scene=='LANE_CHANGE', camera=True))
    if scene not in ('INTERSECTION','NIGHT'):
        result['hdmi'].update(valid=False, state='UNKNOWN', tracks=[], reason='mode_disabled')
        if 'hdmi_objects' in result:result['hdmi_objects'].update(valid=False,detections=[])
    if scene != 'LANE_CHANGE':
        result['lane'].update(current=False, sides=[], reason='MODE_DISABLED')
        result['lane_model_display']=[]
        result['lane_model_display_source']=None
    return result
