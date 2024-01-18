@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('contentType', 'application/json');
        response.setBody('[{"_id": "55d66226726b611100aaf742","replacement": true,"quantity": 183,"name": "Cooling Fan","maintenanceperiod": 0,"lifespan": 0,"cost": 300,"sku": "100004"}]');
        response.setStatusCode(200);
        return response;
}}