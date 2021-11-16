@isTest
private class WB_RedirectCommercialAvail_Con_Test{
 


static testMethod void testRedirect() {
   
      
    Profile p = [select id from profile where name='System Administrator'];
    User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);
    insert u;    
    
    Release_Plan_Exceptions__c excep1 = new Release_Plan_Exceptions__c(Name = 'test',User_Detail__c ='u.Id');    
     insert excep1 ;
     
     list<Release_Plan_Exceptions__c> exception_list = new list<Release_Plan_Exceptions__c >();
     exception_list.add(excep1);
     
      system.runAs(u) {
       Test.startTest();   
       PageReference pageRef = Page.WB_RP_Redirect;
       Test.setCurrentPage(pageRef);
       ApexPages.currentPage().getParameters().put('id', excep1.Id);
      
       ApexPages.StandardSetController  sc = new ApexPages.StandardSetController (exception_list);
       WB_RedirectCommercialAvail_Controller controller = new WB_RedirectCommercialAvail_Controller (sc);
       //controller.final_list.add(aval_excp1);
      controller.proceed();
        Test.stopTest();
       }
 
}
}