/******* 
WB_TriggerHandlerPromoTitleLocalDataTest
Creation Date- 6 Nov 2014
Description- This class is to do code coverage for WB_TriggerHandlerPromoTitleLocalData
Author- Harika Bondalapati
*******/
@isTest
private class WB_TriggerHandlerPromoTitleLocalDataTest{

    static testmethod void testPromoCountries()
    {
        
    }
    /*
     static testMethod void storeLocalDataWithPromotionTitleTest() {
      //create Title
    
        Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789');
        
        List<Title__c> titleList = new List<Title__c>();
        titleList.add(title);
        insert title;
    
    //create Language
        
        Language__c Language = new Language__c (Name='TestLanguage', Language_Order__c=1);
        insert Language;

    //create Country
    
        Country__c Country= new Country__c(Name='TestCountry',Country_Code__c='3',Country_Code2__c='2',Channel__c = 'DTD');
        insert Country;
 
     //create Local Data
     
       
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test loca data',Title__c =title.id,
        Country__c =Country.id,Language__c=Language.id);
        
        List<Local_Title__c> localdataList = new List<Local_Title__c>();
        localdataList.add(localdata);
        insert localdataList;
        
        Account account = new Account(Name= 'Test Account');
        account.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        insert account;
        
         // Create account announcer        
        Account_Role__c accRole =  new Account_Role__c(Account__c = account.Id, User__c = Userinfo.getUserId(), Role__c = 'Promoter');
        insert accRole; 
         list<User> userDetail = [   SELECT id,ProfileId,Profile.Name,Territory__c  from User where id =: Userinfo.getUserId()];
        // inset countries    
        list<Country__c> countryList = new list<Country__c>();
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='T11',Country_Code__c='T98',Territory__c = userDetail[0].Territory__c);
        Country__c countryFrance1 =new Country__c(Name ='TestFrance1',Country_Code2__c ='778',Country_Code__c='F88');
        countryList.add(countryFrance);
        countryList.add(countryFrance1);
        insert countryList;
         // create storefronts
        Agreement__c storefront = new Agreement__c(Account__c = account.Id,Country__c = countryFrance.Id, status__c = 'Active',Pricing_Currency__c ='AUD');
        insert  storefront ;
        
        //Promotion__c testPromotion = new Promotion__c(Name='Dummy Promotion',Account__c = account.id,Country__c = 'India',Start_Date__c=Date.parse('11/01/2014'),End_Date__c=Date.parse('12/01/2014'));
        //insert testPromotion;
  
        Promotion__c testPromotion = new Promotion__c(Account__c = account.Id, Currency__c = 'AUD - Australian Dollar',Promotion_Owner__c = Userinfo.getUserId(), Channels__c = 'EST' ,Formats__c = 'HD');
        insert testPromotion ;
        
        
        Test.startTest();
        Promotion_Title__c promTitle = new Promotion_Title__c(PromotionID__c=testPromotion.id, Title__c= title.id);
        insert promTitle;
        Test.stopTest();     
     }
*/
     
}