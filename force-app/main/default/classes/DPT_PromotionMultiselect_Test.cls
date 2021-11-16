@isTest
public class DPT_PromotionMultiselect_Test{
    static testmethod void testPromoCountries()
    {
        
    }
    /*
    @isTest(SeeAllData='true')
    static void testPromoCountries(){ 
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
        Country__c countryFrance2 =new Country__c(Name ='TestFrance2',Country_Code2__c ='121',Country_Code__c='F12',Territory__c = userDetail[0].Territory__c);
        Country__c countryFrance3 =new Country__c(Name ='TestFrance3',Country_Code2__c ='122',Country_Code__c='F13',Territory__c = userDetail[0].Territory__c);
        countryList.add(countryFrance);
        countryList.add(countryFrance1);
        countryList.add(countryFrance2);
        countryList.add(countryFrance3);
        insert countryList;
        // create storefronts
        list<Agreement__c> storefrontList = new list<Agreement__c>();
        Agreement__c storefront = new Agreement__c(Account__c = acct.Id,Country__c = countryFrance.Id, status__c = 'Active',Pricing_Currency__c ='AUD');
        Agreement__c storefront1 = new Agreement__c(Account__c = acct.Id,Country__c = countryFrance2.Id, status__c = 'Active',Pricing_Currency__c ='AUD');
        Agreement__c storefront2 = new Agreement__c(Account__c = acct.Id,Country__c = countryFrance3.Id, status__c = 'Active',Pricing_Currency__c ='AUD');
        storefrontList.add(storefront);
        storefrontList.add(storefront2);
        storefrontList.add(storefront1);
        insert  storefrontList;
        // create prmotion
        Promotion__c promoRec = new Promotion__c(Account__c = acct.Id,Currency__c = 'AUD - Australian Dollar',Promotion_Owner__c = Userinfo.getUserId() );
        insert promoRec;
        // create promotion country
        list<Promotion_Countries__c> promoCountriesList = new list<Promotion_Countries__c>();
        Promotion_Countries__c promoCon1 = new Promotion_Countries__c(PromotionID__c = promoRec.Id,country__c = countryFrance3.Id );
        promoCountriesList.add(promoCon1);
        insert promoCountriesList ;
                
        ApexPages.currentPage().getParameters().put('id', promoRec.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(promoRec);
        DPT_PromotionMultiselect_Controller con = new DPT_PromotionMultiselect_Controller(sc);
        con.selectedCountriesRecords.clear();         
        con.selectedCountriesRecords.add(new SelectOption(countryFrance.Id, countryFrance.Name));
        con.saveCountries();      
        
                
         
    }
*/
}