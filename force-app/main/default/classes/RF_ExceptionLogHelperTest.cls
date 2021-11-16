@isTest
public class RF_ExceptionLogHelperTest {
    static  testmethod  void validatestatusTestExceptionLog(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        
        useraccess.CAR_Role__c = 'Creative';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'UNI';
        insert useraccess;
        
        Car__c crs = new Car__c();
        crs.name = 'test';
        crs.Suppress_Integration__c = True;
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        
        insert crs;
        crs.Status__c = 'Draft';
        update crs;
        
        RF_Exception_Log__c excpLog = new RF_Exception_Log__c();
        excpLog.Object_Name__c='CAR__c';
        excpLog.Source_ID__c= crs.Id;
        excpLog.RF_Error_Log__c='Limit Exception-101';
        List<RF_Exception_Log__c> lstExcep = new List<RF_Exception_Log__c>();
        lstExcep.add(excpLog);
        insert lstExcep;
        excpLog.RF_Error_Log__c='Limit Exception-102';
        List<RF_Exception_Log__c> lstExcep2 = new List<RF_Exception_Log__c>();
        lstExcep2.add(excpLog);
        update lstExcep2;
        //RF_ExceptionLogHelper.updateRFLogInCAR(lstExcep);
        /*Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u2 = new User(Alias = 'testExce', Email='newtestException1@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='TestingException', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newtestException1@testorg.com');
        System.runAs(u2){*/
          //  RF_ExceptionLogHelper.sendMail(lstExcep);
       // }
        
    }

}