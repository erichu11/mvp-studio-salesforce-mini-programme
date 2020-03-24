public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(Map<Id, Case> caseMap){

        List<Case> newCases = new List<Case>();
        Map<Id, Integer> productMaintenanceCycleMap = new Map<Id, Integer>();
        Map<Id, Integer> caseMaintenanceCycleMap = new Map<Id, Integer>();
        
        //Add all products' maintenance cycle to the productMaintenanceCycleMap
		for (Product2 product : [SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Maintenance_Cycle__c != null]) {
            productMaintenanceCycleMap.put(product.Id, Integer.valueOf(product.Maintenance_Cycle__c));
        }
        
        for (Work_Part__c workPart : [SELECT Id, Equipment__c, Maintenance_Request__c FROM Work_Part__c WHERE Maintenance_Request__c in :caseMap.keySet() AND Equipment__c != null]) {
            if (productMaintenanceCycleMap.containsKey(workPart.Equipment__c)) {
                //If a work part's case doesn't have a maintenance cycle yet, set it as the product's maintenance cycle
                if(!caseMaintenanceCycleMap.containsKey(workPart.Maintenance_Request__c)){
                    caseMaintenanceCycleMap.put(workPart.Maintenance_Request__c, productMaintenanceCycleMap.get(workPart.Equipment__c));   
                } 
                //If the case already has a maintenance cycle, update it if the current work part's product has a shorter maintenance cycle
                else if(productMaintenanceCycleMap.get(workPart.Equipment__c) < caseMaintenanceCycleMap.get(workPart.Maintenance_Request__c)){
                    caseMaintenanceCycleMap.put(workPart.Maintenance_Request__c, productMaintenanceCycleMap.get(workPart.Equipment__c));  
                } 
            } 
        }
        
        for(Case c : caseMap.values()){
            
            Case newCase = new Case();
            newCase.Status = 'New';
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = 'Routine Maintenance Request';
            newCase.Date_Reported__c = Date.today();
            newCase.Date_Due__c = Date.today().addDays(caseMaintenanceCycleMap.get(c.Id));
            newCase.Equipment__c = c.Equipment__c;
            newCase.Product__c = c.Product__c;
            newCase.AccountId = c.AccountId;
            newCase.ContactId = c.ContactId;
            newCase.AssetId = c.AssetId;
            newCase.Origin = c.Origin;
            newCase.Reason = c.Reason;
            newCase.Vehicle__c = c.Vehicle__c;
          	
            newCases.add(newCase);
        }
        
        if(!newCases.isEmpty()){
            insert newCases;
        }
    }

}
