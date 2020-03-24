@isTest
private class WarehouseCalloutServiceTest {
    
    @isTest
    static void testRunWarehouseEquipmentSync(){
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        System.assertEquals(2, [SELECT count() FROM Product2]);
    }
}
