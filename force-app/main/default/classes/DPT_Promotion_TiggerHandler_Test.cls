@isTest
public class DPT_Promotion_TiggerHandler_Test{
    static testmethod void testPromoCountries()
    {
        
    }
    /*
    @isTest(SeeAllData='true')
    static void testInsetUpdateEvents(){ 
    //create Account
        Account acct = TestUtil.initAccount();
        insert acct;
        // Create account announcer        
        Account_Role__c accRole =  new Account_Role__c(Account__c = acct.Id, User__c = Userinfo.getUserId(), Role__c = 'Promoter');
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
        Agreement__c storefront = new Agreement__c(Account__c = acct.Id, Country__c = countryFrance.Id, status__c = 'Active',Pricing_Currency__c ='AUD');
        insert  storefront ;
        // create prmotion
        Promotion__c promoRec = new Promotion__c(Account__c = acct.Id,Currency__c = 'AUD - Australian Dollar',Promotion_Owner__c = Userinfo.getUserId(), Channels__c = 'EST' ,Formats__c = 'HD');
        insert promoRec;
        // create title
        title__c titletest = new title__c (name = 'testtitle',Video_Version__c = '1234');
        insert titletest ;
        // create promtion title
        Promotion_Title__c promotitle = new Promotion_Title__c(PromotionID__c = promoRec.Id , Title__c = titletest.Id , Channel__c = 'EST' , Format__c = 'HD' );
        insert promotitle;
        ApexPages.currentPage().getParameters().put('id', promoRec.Id);
        promoRec.Status__c = 'Draft';
        update promoRec;        
         
    }
*/
}