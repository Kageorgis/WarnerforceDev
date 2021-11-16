@RestResource(urlMapping='/getWBSalesforceStatus/*')
global without sharing class WB_Salesforce_CatchPoint {
    @HttpGet
    global static String getWBSalesforceStatus() {
        return 'OK';
    }
    
}