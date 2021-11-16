@isTest
public class WB_MainMultiSelectControllerTest {

    static void setupData() {
        //insert Account
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount1 = new Account(Name='TestAccount1',Customer_Focus__c='Active', recordtypeId = rtypeId);
        objAccount1.Type='Global';
        insert objAccount1;
        
        Country__c Country_1 = new Country__c();
        Country_1.Name = 'India';
        Country_1.Country_Code2__c = 'IN';
        Country_1.Country_Code__c = 'IND';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        insert Country_1;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c = objAccount1.Id
                                                          ,country__c = country_1.Id
                                                          ,Status__c = 'Active'
                                                          ,Pricing_Currency__c ='FR'
                                                          ,Format__c = 'HD;SD;'
                                                          ,Channel_Picklist__c = 'EST'
                                                          ,Content_Type__c = 'Episode;Season'
                                                          ,Active__c = true
                                                          ,WSP_Currency__c = 'INR');
        insert storefrontGoogle1;
        
        //insert Promotion
        Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1',Country__c='India');
        insert promo;
    }
    
    private static testMethod void mainLoadCountriesTest() {
        setUpData();
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<sobject> lstCountries = WB_MainMultiSelectController.mainLoadCountries(promoRec.Id);
        
        System.assertEquals(1, lstCountries.size());
    }
    
    private static testMethod void saveRecTest() {
        setUpData();

        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<Country__c> lstCountries = [SELECT Id,Name FROM Country__c];
        List<Account> lstAccounts = [SELECT Id,Name FROM Account];
        Boolean result = WB_MainMultiSelectController.saveRec(promoRec.Id,lstCountries,lstAccounts);
        
        System.assertEquals(true, result);
    }
    
    private static testMethod void getPromotionRecordTest() {
        setUpData();
        Promotion__c promoRec = [SELECT Id,Name FROM Promotion__c];
        Promotion__c returnResult = WB_MainMultiSelectController.getPromotionRecord(promoRec.Id);
        
        System.assertEquals(promoRec.Name, returnResult.Name);
    }
    
    private static testMethod void getCustomSettingsTest() {
        setUpData();
        //insert Custom Setting
        List<WB_Promotion_Limits__c> listLimits = new List<WB_Promotion_Limits__c>();
        listLimits.add(new WB_Promotion_Limits__c(Name='Commit Batch Process Threshold',Limit_Size__c=100));
        listLimits.add(new WB_Promotion_Limits__c(Name='Commit PTD Chunk Size',Limit_Size__c=100));
        listLimits.add(new WB_Promotion_Limits__c(Name='MaxAccountsAllowed',Limit_Size__c=100));
        listLimits.add(new WB_Promotion_Limits__c(Name='MaxCountriesAllowed',Limit_Size__c=100));
        listLimits.add(new WB_Promotion_Limits__c(Name='Promotion Titles Size Limit',Limit_Size__c=100));
        listLimits.add(new WB_Promotion_Limits__c(Name='Save PT Chunk Size',Limit_Size__c=100));
        listLimits.add(new WB_Promotion_Limits__c(Name='Validate PT Chunk Size',Limit_Size__c=100));
        insert listLimits;
        
        List<Decimal> lstResult = WB_MainMultiSelectController.getCustomSettings();
        
        System.assertEquals(2, lstResult.size());
    }
}