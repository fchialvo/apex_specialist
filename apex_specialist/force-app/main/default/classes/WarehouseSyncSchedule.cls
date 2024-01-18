public with sharing class WarehouseSyncSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
    try {
		ID jobID = System.enqueueJob(new WarehouseCalloutService());
    } catch (Exception e) {
    	System.debug('Caught Exception: ' + e.getMessage());
    }
  }
}