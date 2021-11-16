@istest
public class CarHelperTest {
    @isTest
    static void validatestatusTest(){
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
    }
    
    /*static testmethod void validatestatusTest1(){
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
        crs.Status__c = 'Assigned';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        
        insert crs;
         crs.Status__c = 'Working';
        crs.Primary_Vendor__c = 'AVK';
        crs.Suppress_Integration__c = True;
        update crs;
       
        
    }*/
    
    static testmethod void triggerElse(){
        list<car__c> carsList = new list<car__c>();
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
        crs.Primary_Vendor__c = 'BLT';
        
        insert crs;
        carsList.add(crs);
        CAR_CARTriggerHandler handler = new CAR_CARTriggerHandler();
        handler.BeforeInsert(carsList);
    }
    
     static testmethod void triggerElse1(){
      	Map<Id, Car__c> newItems= new Map<Id,Car__c>();
        Map<Id, Car__c> oldItems = new Map<Id, Car__c>();
        
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
        crs.Primary_Vendor__c = 'BLT';
        insert crs;
         
        oldItems.put(crs.id,crs);
        newItems.put(crs.id,crs);
        CAR_CARTriggerHandler handler = new CAR_CARTriggerHandler();
        handler.BeforeUpdate(newItems,oldItems);
         CAR_CARHelper.preventDeletionOfnonDraftCars(oldItems);
    }
    
    
    static testmethod void validatestatusTest7(){
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
        crs.Primary_Vendor__c = 'BLT';
        
        insert crs;
         crs.Status__c = 'Draft';
        crs.reason__c = 'test';
        //crs.Suppress_Integration__c = false;
        update crs;
       
        
    }
   
    static testmethod void validatestatusTest8(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        
        RF_User_Access__c useraccess = new RF_User_Access__c();
         Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Sales';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'UNI';
        insert useraccess;
        
        Car__c crs = new Car__c();
        crs.name = 'test';
        crs.Suppress_Integration__c = True;
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        crs.Primary_Vendor__c = 'BLT';
        
        insert crs;
         crs.Status__c = 'Trade Review';
        crs.reason__c = 'test';
        //crs.Suppress_Integration__c = false;
        update crs;
       
        
    }
    
     static testmethod void validatestatusTest9(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        
        RF_User_Access__c useraccess = new RF_User_Access__c();
         Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Trade';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'UNI';
        insert useraccess;
        
        Car__c crs = new Car__c();
        crs.name = 'test';
        crs.Suppress_Integration__c = True;     
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        crs.Primary_Vendor__c = 'BLT';
        
        insert crs;
         crs.Status__c = 'Brand Review';
        crs.reason__c = 'test';
        //crs.Suppress_Integration__c = false;
        update crs;
       
        
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
        RFObj.Distributor__c = 'Uni';
        insert RFObj;
        System.assertNotEquals(RFObj.Id, null);
        release__c relObj = new release__c();
        relObj.name = 'test';
        relObj.mpm__c = mpmObj.Id;
        relObj.Brand_Group__c = 'TV';
        relObj.RF_Studio__c = RFObj.Id;
        relObj.Country_List__c = 'USA';
        insert relObj;
        System.assertNotEquals(relObj.Id, null);

         RF_User_Access__c useraccess = new RF_User_Access__c();
         Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'UNI';
        insert useraccess;
         
        car__c carObj = RF_TestUtil.carslist('Test','Draft');
        carObj.release__c = relObj.Id;
        carObj.country__c = cnt.id;
        carObj.language__c = lng.id;
        carObj.Brand_Group__c = 'Film';
        carObj.RF_Studio__c =  RFObj.id;
        carObj.RF_Studios__c = RFObj.Distributor__c;
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
    
    static testmethod void validatestatusTest2(){
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
        //crs.Suppress_Integration__c = false;
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        
        insert crs;
        crs.Suppress_Integration__c = false;
        crs.Primary_Vendor__c = 'AMMO';
         crs.Status__c = 'Assigned';
        update crs;
       
        
    }
 static testmethod void validatestatusTest3(){
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
        crs.Suppress_Integration__c = true;
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        
        insert crs;
         crs.Status__c = 'Trade Review';
        update crs;
       
        
    }
    
    static testmethod void validatestatusTest4(){
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
        crs.Status__c = 'Draft';
        //crs.Reason__c == null;
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        
        insert crs;
         crs.Status__c = 'Trade Review';
        update crs;
    }
    static testmethod void validatestatusTest5(){
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
       
        RF_User_Access__c useraccess = new RF_User_Access__c();
         Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        
        Car__c crs = new Car__c();
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        
        insert crs;
         crs.Status__c = 'Trade Review';
        update crs;
    }
    
    static testmethod void updateCarFieldTest1(){
        mpm__c mpmObj = new mpm__c();
        mpmObj.mpm_number__c = '321234';
        insert mpmObj;
        RF_Studio__c RFObj = new RF_Studio__c();
        RFObj.Distributor__c = 'test';
        insert RFObj;
       release__c relObj = new release__c();
        relObj.name = 'test';
        relObj.mpm__c = mpmObj.Id;
        relObj.Brand_Group__c = 'TV';
        relObj.RF_Studio__c = RFObj.Id;
        relObj.Country_List__c = 'USA';
        insert relObj;
        release__c relObj1 = new release__c();
        relObj1.name = 'test1';
        relObj1.mpm__c = mpmObj.Id;
        relObj1.Brand_Group__c = 'TV';
        relObj1.RF_Studio__c = RFObj.Id;
        relObj1.Country_List__c = 'USA';
        insert relObj1;
        
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        RF_User_Access__c useraccess = new RF_User_Access__c();
         Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        useraccess.CAR_Role__c = 'Creative';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'Universal';
        insert useraccess;
        
        Car__c crs = new Car__c();
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        crs.release__c = relObj.Id;
        insert crs;
       	crs.release__c = relObj1.Id;
        update crs;
        
    }
     
    
}