@isTest
public class WarehouseSyncScheduleTest {  
    public static String CRON_EXP = '0 0 1 * * ?';
    public static final String WAREHOUSE_SYNC_SCHEDULE_TEST = 'WarehouseSyncScheduleTest';
    
    @isTest
    static void testExecute(){
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
            String jobId = System.schedule(WAREHOUSE_SYNC_SCHEDULE_TEST, CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM CronTrigger WHERE CronJobDetail.Name = :WAREHOUSE_SYNC_SCHEDULE_TEST]);
    }

}
