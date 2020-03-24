public class WarehouseSyncSchedule implements Schedulable{
    public void execute(System.SchedulableContext context){
        WarehouseCalloutService.runWarehouseEquipmentSync();
    }
}
