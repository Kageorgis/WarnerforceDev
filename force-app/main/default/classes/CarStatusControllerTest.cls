/*========================================================================================================
* @author Ajit Singh
* @date 22/09/2020
* @description: Test class for CarStatusController
==========================================================================================================*/
@isTest
public class CarStatusControllerTest {
    
   static testmethod void setCarStatustest(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        System.assertNotEquals(lng.Id, null);

        RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        System.assertNotEquals(userAccess.Id, null);
        
        // system.runAs(usr){
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
       carObj.Requesting_Group__c ='DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;

        insert carObj;
        System.assertNotEquals(carObj.Id, null);
        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        // }
        
        // test.stopTest();
        
        }   
    static testmethod void setCarStatustest1(){
        
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        System.assertNotEquals(userAccess.Id, null);
        
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
        carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
        System.assertNotEquals(carObj.Id, null);

        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
    }
    static testmethod void setCarStatustest2(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
		System.assertNotEquals(userAccess.Id, null);
        
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);

        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
   
    static testmethod void setCarStatustest3(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
       // useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
		System.assertNotEquals(userAccess.Id, null);
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }

    static testmethod void setCarStatustest4(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
		System.assertNotEquals(userAccess.Id, null);
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);

        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
    static testmethod void setCarStatustest5(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

        RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
       // useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
		System.assertNotEquals(userAccess.Id, null);
        
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);

        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
   
    static testmethod void setCarStatustest6(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
       // useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess; 
		System.assertNotEquals(userAccess.Id, null);
        
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Test','Assigned');
        carObj.Status__c = 'Draft';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);

        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
    static testmethod void setCarStatustest7(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);

      	RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess; 
		System.assertNotEquals(userAccess.Id, null);
        
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Creative Review','Assigned');
        carObj.Status__c = 'Draft';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
    static testmethod void setCarStatustest8(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess; 
		System.assertNotEquals(userAccess.Id, null);        
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Creative Review','Assigned');
        carObj.Status__c = 'Draft';
        carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
    static testmethod void setCarStatustest9(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
       // useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
		System.assertNotEquals(userAccess.Id, null);		
        test.startTest();
        car__c carObj = RF_TestUtil.carslist('Creative Review','Assigned');
        carObj.Status__c = 'Draft';
        carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        system.debug('*** '+carObj.id);             
        CarStatusController.setCarStatus(carObj.id,userId); 
        test.stopTest();
        
    }
   	  
    static testmethod void reactivateStatustest(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
 		RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        car__c carObj = RF_TestUtil.carslist('Test Reactivate','Draft');
        carObj.Last_Valid_Status__c= 'Hold';
        carobj.Requesting_Group__c = 'DIGITAL';
        carobj.reason__c = 'testing';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        carObj.Reactivate_Flag__c = true;
        insert carObj;
   		system.assertNotEquals(carObj.Id, null);
      //  Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.reactivateStatus(carObj.id,'test');
        test.stopTest();
        
    }
    static testmethod void setHoldStatustest(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
       // useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        car__c carObj = RF_TestUtil.carslist('Test Set Reason2','Draft');
        carObj.Reason__c='Testing';
        carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        carObj.reasonFlag__c=true;
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        //Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.setHoldStatus(carObj.id);
        test.stopTest();
        
    }
    static testmethod void UpdateCarFieldstest(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        System.assertNotEquals(lng.Id, null);
        mpm__c mpmObj = new mpm__c();
        mpmObj.mpm_number__c = '321234';
        
        insert mpmObj;
        System.assertNotEquals(mpmObj.Id, null);
        RF_Studio__c RFObj = new RF_Studio__c();
        RFObj.Distributor__c = 'Universal';
        insert RFObj;
        System.assertNotEquals(RFObj.Id, null);
        release__c relObj = new release__c();
        relObj.name = 'test';
        relObj.mpm__c = mpmObj.Id;
        relObj.Brand_Group__c = 'TV';
        relObj.RF_Studio__c = RFObj.Id;
        relObj.Distributor__c = RFObj.id;
        relObj.Country_List__c = 'USA';
        insert relObj;
        System.assertNotEquals(relObj.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        
        
        car__c carObj = RF_TestUtil.carslist('Test','Draft');
        carObj.release__c = relObj.Id;
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        carObj.Brand_Group__c = 'Film';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.RF_Studio__c =  RFObj.id;
        carObj.MPM__c = mpmObj.id;
        insert carObj;
        System.assertNotEquals(carObj.Id, null);

        release__c relObj1 = new release__c();
        relObj1.name = 'test1';
        relObj1.mpm__c = mpmObj.Id;
        relObj1.Brand_Group__c = 'TV';
        relObj1.RF_Studio__c = RFObj.Id;
        relObj1.Country_List__c = 'USA';
        insert relObj1;
		System.assertNotEquals(relObj1.Id, null);

        carObj.release__c = relObj1.Id;
        update carObj;
    }
    static testmethod void setReasontest1(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
        
         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        car__c carObj = RF_TestUtil.carslist('Test Set Reason','Draft');
        carObj.Reason__c='Testing';
         carobj.Requesting_Group__c = 'DIGITAL';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
       // Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.setReason(carObj.id,'Testing','Cancel');
        test.stopTest();
    }

	/*static testmethod void assignQueues1(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
        
         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Trade';
       // useraccess.Requesting_Group__c = 'SDS';
        useraccess.Distributor__c = 'WB';
        insert useraccess;
        
        car__c carObj = RF_TestUtil.carslist('Test Set Reason','Draft');
        carObj.status__c = 'Draft';
        carobj.Requesting_Group__c = 'SDS';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        
       // Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.setCarStatus(carObj.id,userId);
        test.stopTest();
    }*/
   		static testmethod void assignQueues2(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
        RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Trade';
        //useraccess.Requesting_Group__c = 'SDS';
        useraccess.Distributor__c = 'WB';
        insert useraccess;
        
        car__c carObj = RF_TestUtil.carslist('Test Set Reason','Draft');
       // carObj.Reason__c='Testing';
        carObj.status__c = 'Draft';
       	carobj.Requesting_Group__c = 'SDS';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        
       // Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.setCarStatus(carObj.id,userId);
        test.stopTest();
    }
    static testmethod void assignQueues3(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
        
       Profile p = [SELECT Id FROM Profile WHERE Name='SFDC Support Level 2'];
     	 User u2 = new User(Alias = 'newtest1', Email='newtest1@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='newtest1@testorg.com');

      System.runAs(u2) {
        
         RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        //useraccess.Requesting_Group__c = 'SDS';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        
        car__c carObj = RF_TestUtil.carslist('Test Set Reason','Draft');
       // carObj.Reason__c='Testing';
        //carObj.status__c = 'Draft';
        carObj.country__c = cnt.id;
        carobj.Requesting_Group__c = 'SDS';
        carObj.language__c = lng.id;
        //carObj.Suppress_Integration__c = true;
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        
       // Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.setCarStatus(carObj.id,userId);
        test.stopTest();
      }
    }
    
 static testmethod void assignQueues4(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
		System.assertNotEquals(cnt.Id, null);

        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
		System.assertNotEquals(lng.Id, null);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='SFDC Support Level 2'];
        User u2 = new User(Alias = 'newtest1', Email='newtest1@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='newtest1@testorg.com');

      System.runAs(u2) {
      	
           RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
       // useraccess.Requesting_Group__c = 'SDS';
        useraccess.Distributor__c = 'WB';
        insert useraccess;
        
        car__c carObj = RF_TestUtil.carslist('Test Set Reason','Trade Review');
       // carObj.Reason__c='Testing';
        carObj.status__c = 'Draft';
        carobj.Requesting_Group__c = 'SDS';
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        
        carObj.Suppress_Integration__c = false;
        insert carObj;
		System.assertNotEquals(carObj.Id, null);
        
       // Id userId= UserInfo.getUserId();
        test.startTest();
        CarStatusController.setCarStatus(carObj.id,userId);
        test.stopTest();
          
      }
    }    
}