@isTest
public with sharing class MaintenanceRequestHelperTest {

    @isTest
    private static void testTrigger() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        Product2 equipment = new Product2(Name = 'Generator', Maintenance_Cycle__c = 30, Replacement_Part__c = true);
        insert vehicle;
        insert equipment;

        Case cs = new Case(Status = 'New', 
                           Origin = 'Web', 
                           Subject = 'Test Case', 
                           Type = 'Repair', 
                           Vehicle__c = vehicle.Id, 
                           Equipment__c = equipment.Id,
                           Date_Reported__c = Date.today());
        insert cs;
        

        Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c(Maintenance_Request__c = cs.Id, Equipment__c = equipment.Id);
        insert item;
        
        Case caseToUpdate = [SELECT Id, Status FROM Case WHERE Id = :cs.Id LIMIT 1];

        Test.startTest();
        caseToUpdate.Status = 'Closed';

        try {
            update caseToUpdate;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();

        List<Case> newCase = [SELECT Id, Status, Type FROM Case WHERE ParentId = :caseToUpdate.Id];
        System.assertEquals(1, newCase.size());
        
        List<Equipment_Maintenance_Item__c> items = [SELECT Id, Equipment__c FROM Equipment_Maintenance_Item__c];
        System.assertEquals(2, items.size());

    }
}