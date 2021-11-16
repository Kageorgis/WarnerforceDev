@IsTest
private class WB_Salesforce_CatchPoint_Test {
    @isTest static void testWB_Salesforce_CatchPoint() {
        RestRequest request = new RestRequest();
        request.requestUri =URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/getWBSalesforceStatus/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        String Result=WB_Salesforce_CatchPoint.getWBSalesforceStatus();
        System.assertEquals('OK', Result);
    }
}