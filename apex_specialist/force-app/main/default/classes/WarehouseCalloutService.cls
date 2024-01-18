public with sharing class WarehouseCalloutService implements Queueable {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public class EquipmentResponse {
        public String id;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenanceperiod;
        public Integer lifespan;
        public Decimal cost;
        public String sku;
    }

    public void execute(QueueableContext context) {
        try {
            processData();
        } catch (Exception e) {
            System.debug('Caught Exception: ' + e.getMessage());
        }
    }

    @Future(callout = true)
    public static void processData() {
        try {
            HttpResponse response = fetchData(WAREHOUSE_URL);

            if (response.getStatusCode() == 200) {
                List<EquipmentResponse> equipmentList = parseData(response.getBody());
                upsertEquipmentRecords(equipmentList);
            }
        } catch (Exception e) {
            System.debug('Error encountered: ' + e.getMessage());
        }
    }

    private static HttpResponse fetchData(String endpoint) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        return http.send(request);
    }

    private static List<EquipmentResponse> parseData(String responseBody) {
        return (List<EquipmentResponse>) JSON.deserialize(responseBody, List<EquipmentResponse>.class);
    }

    private static void upsertEquipmentRecords(List<EquipmentResponse> equipmentList) {
        List<Product2> newEquipmentRecords = new List<Product2>();
        for (EquipmentResponse equipment : equipmentList) {
            Product2 newEquipment = createEquipmentRecord(equipment);
            newEquipmentRecords.add(newEquipment);
        }
        upsert newEquipmentRecords Warehouse_SKU__c;
    }

    private static Product2 createEquipmentRecord(EquipmentResponse equipment) {
        Product2 newEquipment = new Product2();
	
        newEquipment.Id = equipment.id;
        newEquipment.Name = equipment.name;
        newEquipment.Replacement_Part__c = equipment.replacement;
        newEquipment.Cost__c = equipment.cost;
        newEquipment.Current_Inventory__c = equipment.quantity;
        newEquipment.Lifespan_Months__c = equipment.lifespan;
        newEquipment.Maintenance_Cycle__c = equipment.maintenanceperiod;
        newEquipment.Warehouse_SKU__c = equipment.sku;
        return newEquipment;
    }
}