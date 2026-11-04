class LaneDisplayLatch:
    
    
    def update(self,result,now):
        rows=result.get('state',{}).get('lane_boundary_memory',{})
        out={s:dict(kind=r['candidate_type'],source_timestamp=r['source_timestamp'],
            source_ns=r.get('source_ns'),supported=True,visual_only=True,
            decision_permission=False,shared_decision_state=True,mode='SHARED_STATE') for s,r in rows.items()}
        result['lane_last_display']=out
        return out
