@istest
public class WB_RedirectRequestRefreshController_Test {
    
    public static testMethod void testRedirectRightsError(){
        list<Request_Rights_error_log__c> lstRightsError= new list<Request_Rights_error_log__c>();
        
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstRightsError);
        WB_RedirectRequestRefresh_Controller obj = new WB_RedirectRequestRefresh_Controller(sc);
        
        Request_Rights_error_log__c errorRights = new Request_Rights_error_log__c(Name='Test');
        lstRightsError.add(errorRights);
        insert lstRightsError;
         ApexPages.StandardSetController scr = new ApexPages.StandardSetController(lstRightsError);
        WB_RedirectRequestRefresh_Controller obj1 = new WB_RedirectRequestRefresh_Controller(scr);
        obj1.proceed();
    }
}