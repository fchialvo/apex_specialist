@isTest
private class WarehouseCalloutServiceTest {
    @isTest
    static void testProcessData() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService service = new WarehouseCalloutService();
        Test.startTest();
            System.enqueueJob(service);
        	WarehouseCalloutService.processData();
        Test.stopTest();

        List<Product2> equipment = [SELECT Id, Cost__c	, Current_Inventory__c, Description, Lifespan_Months__c, Maintenance_Cycle__c	, Name	, ProductCode, Replacement_Part__c, Warehouse_SKU__c FROM Product2 WHERE Warehouse_SKU__c = '100004'];
        System.assertEquals(1, equipment.size());
        System.assertEquals('Generator 1000 kW', equipment[0].Name);
    }
}