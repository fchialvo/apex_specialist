@isTest
global class WarehouseCalloutServiceErrorMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('contentType', 'application/json');
        response.setBody('invalid_json');
        return response;
    }
}