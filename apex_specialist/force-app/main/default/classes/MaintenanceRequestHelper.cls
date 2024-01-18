public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> updWorkOrders, Map<Id, Case> oldWorkOrders) {
        Set<Id> validIds = new Set<Id>();

        for (Case c : updWorkOrders) {
            if (oldWorkOrders.get(c.Id).Status != 'Closed' && c.Status == 'Closed') {
                if (c.Type == 'Repair' || c.Type == 'Routine Maintenance') {
                    validIds.add(c.Id);
                }
            }
        }

        if (!validIds.isEmpty()) {
            Set<Id> maintenanceRequestIds = new Set<Id>();
            for (AggregateResult ar : [SELECT Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :validIds GROUP BY Maintenance_Request__c]) {
                maintenanceRequestIds.add((Id) ar.get('Maintenance_Request__c'));
            }

            Map<Id, Case> closedCasesM = new Map<Id, Case>([
                SELECT Id, Vehicle__c, ProductId, Equipment__r.Maintenance_Cycle__c
                FROM Case
                WHERE Id IN :validIds
            ]);

            Map<Id, Decimal> maintenanceCycles = new Map<Id, Decimal>();
            for (AggregateResult ar : [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) cycle FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :maintenanceRequestIds GROUP BY Maintenance_Request__c]) {
                maintenanceCycles.put((Id) ar.get('Maintenance_Request__c'), (Decimal) ar.get('cycle'));
            }

            List<Case> newCases = new List<Case>();

            for (Case cc : closedCasesM.values()) {
                Case nc = new Case(
                    ParentId = cc.Id,
                    Status = 'New',
                    Subject = 'Routine Maintenance',
                    Type = 'Routine Maintenance', 
                    Vehicle__c = cc.Vehicle__c,
                    ProductId = cc.ProductId,
                    Origin = 'Web',
                    Date_Reported__c = Date.Today()
                );

                if (maintenanceCycles.containsKey(cc.Id)) {
                    nc.Date_Due__c = Date.today().addDays((Integer) maintenanceCycles.get(cc.Id));
                }
                newCases.add(nc);
            }

            insert newCases;
            
            
       		 List<Equipment_Maintenance_Item__c> clonedWPs = new List<Equipment_Maintenance_Item__c>();
       		 for (Case nc : newCases){
                      System.debug(closedCasesM.get(nc.ParentId));
                 
            List<Equipment_Maintenance_Item__c> items = [SELECT Id, Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c = :nc.ParentId];

            for (Equipment_Maintenance_Item__c wp : items){
                if(wp != null){
                    Equipment_Maintenance_Item__c wpClone = wp.clone();
                    wpClone.Maintenance_Request__c = nc.Id;
                    ClonedWPs.add(wpClone);
                }
                else{
                    System.debug('null');
                }
            }
        }
        insert ClonedWPs;
        }
    }
}