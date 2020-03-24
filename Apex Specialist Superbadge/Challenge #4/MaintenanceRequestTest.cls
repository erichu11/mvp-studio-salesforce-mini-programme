@isTest
public class MaintenanceRequestTest {

    private static final String CASE_TYPE_REPAIR = 'Repair';
    private static final String CASE_TYPE_ROUTINE_MAINTENANCE = 'Routine Maintenance';
    private static final String CASE_SUBJECT_SINGLE = 'Single Work Part Maintenance';
    private static final String CASE_SUBJECT_MULTIPLE = 'Multiple Work Part Maintenance';
    private static final String CASE_SUPPLIED_NAME = 'Test Supplier';

    private static final Integer PRODUCT_ONE_MAINTENANCE_CYCLE = 365;
    private static final Integer PRODUCT_TWO_MAINTENANCE_CYCLE = 730;

    @testSetup
    static void setup(){
        Product2 prod1 = new Product2();
        prod1.Cost__c = 100;
        prod1.Name = 'Test Product 1';
        prod1.Lifespan_Months__c = 12;
        prod1.Maintenance_Cycle__c = PRODUCT_ONE_MAINTENANCE_CYCLE;
        prod1.Current_Inventory__c = 100;
        prod1.Replacement_Part__c = true;
        prod1.Warehouse_SKU__c = '10001';
        insert prod1;
        
        Product2 prod2 = new Product2();
        prod2.Cost__c = 200;
        prod2.Name = 'Test Product 2';
        prod2.Lifespan_Months__c = 24;
        prod2.Maintenance_Cycle__c = PRODUCT_TWO_MAINTENANCE_CYCLE;
        prod2.Current_Inventory__c = 100;
        prod2.Replacement_Part__c = true;
        prod2.Warehouse_SKU__c = '10002';
        insert prod2;
        
        List<Case> caseList = new List<Case>();
        for(Integer i=0; i<300; i++) {
            Case caseNew = new Case();
            
            caseNew.Status = 'New';
            caseNew.Equipment__c = prod1.Id;
            caseNew.SuppliedName = CASE_SUPPLIED_NAME;
            caseNew.Type = CASE_TYPE_REPAIR;
            caseList.add(caseNew);  

            if (Math.Mod(i,2) == 0) {
                caseNew.Subject = CASE_SUBJECT_SINGLE;
            } else {
                caseNew.Subject = CASE_SUBJECT_MULTIPLE;
            }
        }
        
        insert caseList;
        
        List<Work_Part__c> workPartList = new List<Work_Part__c>();
        for(Case c : [SELECT Id, Subject, Type FROM Case WHERE SuppliedName = :CASE_SUPPLIED_NAME]) {
            Work_Part__c workPart = new Work_Part__c();
            workPart.Maintenance_Request__c = c.Id;
            workPart.Equipment__c = prod2.Id;

            workPartList.add(workPart); 

            //Half of the cases will only have one work part whereas the other half will have work parts that use both products
            if (c.Subject == CASE_SUBJECT_MULTIPLE) {
                Work_Part__c workPart2 = new Work_Part__c();
                workPart2.Maintenance_Request__c = c.Id;
                workPart2.Equipment__c = prod1.Id;

                workPartList.add(workPart2); 
            } 
        }

        insert workPartList;
    }
    
    @isTest
    static void testMaintenanceRequest(){
        List<Case> caseList = new List<Case>();
        for(Case c : [SELECT Id FROM Case WHERE SuppliedName = :CASE_SUPPLIED_NAME]) {
            c.Status = 'Closed';
            caseList.add(c);
        }
        
        Test.startTest();
            update caseList;
        Test.stopTest();

        System.assertEquals(300, [SELECT count() FROM Case WHERE Type = :CASE_TYPE_ROUTINE_MAINTENANCE and Date_Reported__c = :Date.today()]);

        //Half of the newly generated cases have Work Parts that use both Products and therefore should have a shorter due date
        Date multipleWorkPartDueDate = Date.today().addDays(PRODUCT_ONE_MAINTENANCE_CYCLE);
        System.assertEquals(150, [SELECT count() FROM Case WHERE Type = :CASE_TYPE_ROUTINE_MAINTENANCE and Date_Due__c = :multipleWorkPartDueDate]);
        
    }
}
