@isTest
private class CRM_RequestHandlerTest {

    static testMethod void requestUpdateTest(){
        Account acct = new Account();
        acct.name = 'Test Acct Name';
        insert acct;        
        
        Request__c req = new  Request__c();
        req.Type__c = 'Contract' ;
        req.account__c = acct.id;
        req.Sub_Type__c ='New account open'; 
        req.Status__c ='Draft';
        insert req;
        
        system.assertEquals(1,[Select Id, Name from Request__c].size());
        
        req.Type__c = 'Co-op Ad';
        req.Sub_Type__c ='Sales Support & Coop.Ad.A-New Release';
        update req;
        
        system.assertEquals('Co-op Ad',[Select Id, Type__c from Request__c].Type__c);
    }
    
    static testMethod void requestCloneTest(){
    	Account acct = new Account();
        acct.name = 'Test Acct Name';
        insert acct;        
        
        Request__c req = new  Request__c();
        req.Type__c = 'Contract' ;
        req.account__c = acct.id;
        req.Sub_Type__c ='New account open'; 
        req.Status__c ='Draft';
        req.Date_Approved__c = system.today()+5;
        req.Date_Submitted__c = system.today();
        insert req;
        
        system.assertEquals(null,[Select Id, Date_Approved__c from Request__c].Date_Approved__c,'While cloning Request Date Approved should not be clone');
        system.assertEquals(null,[Select Id, Date_Submitted__c from Request__c].Date_Submitted__c,'While cloning Request Date Submitted should not be clone');
        
    }
}