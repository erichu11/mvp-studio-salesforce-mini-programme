trigger MaintenanceRequest on Case (before update, after update) {
    
    if(Trigger.isUpdate  && Trigger.isAfter) {
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case c: Trigger.new){
            if (!Trigger.oldMap.get(c.Id).IsClosed && c.IsClosed && (c.Type == 'Repair' || c.Type == 'Routine Maintenance')){
                caseMap.put(c.Id, c);
            }
        }
        
        if(!caseMap.isEmpty()){
        	MaintenanceRequestHelper.updateWorkOrders(caseMap);    
        }        
    }
}