/*****************************************************************************
 * Description:     Test Class for ExportPromotionTitles Web Service
 *
 * Author:          Date:          Description
 * Ishwar Kabra     07-Jan-15      First Draft  
 *****************************************************************************/
@isTest
public class ExportPromotionTitlesTest
{
    static testmethod void testPromoCountries()
    {
        
    }
    /*
    static testMethod void testExportPromotionTitles()
    {
         Test.startTest();
         
         Account a = TestUtil.createAccount('Harry Potter');
         insert a;
         
          // Create account announcer        
        Account_Role__c accRole =  new Account_Role__c(Account__c = a.Id, User__c = Userinfo.getUserId(), Role__c = 'Promoter');
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
        Agreement__c storefront = new Agreement__c(Account__c = a.Id,Country__c = countryFrance.Id, status__c = 'Active',Pricing_Currency__c ='AUD');
        insert  storefront ;
         
         Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
         insert title;
         Promotion__c p = new Promotion__c(Account__c = a.Id ,Send_to_Marvin__c = True, Currency__c = 'AUD - Australian Dollar',Promotion_Owner__c = Userinfo.getUserId(), Channels__c = 'EST' ,Formats__c = 'HD');
        
         
         insert p;
         
         Promotion_Title__c pt = TestUtil.createPromotionTitle(p.Id, title.Id);
         insert pt;
         
         List<ExportPromotionTitles.PromotionDetails> pdList = ExportPromotionTitles.exportPromotionDetails();
         System.assertEquals(pdList.size(),1);
         Test.stopTest();
    }
*/
}