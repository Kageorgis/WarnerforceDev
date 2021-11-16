@isTest
public class WB_MultiSelectLookupAccountTest {

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
    
    private static testMethod void loadRecTest() {
        setUpData();
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<sobject> lstAccounts = WB_MultiSelectLookupAccount.loadRec(promoRec.Id);
        
        System.assertEquals(1, lstAccounts.size());
    }
    
    private static testMethod void searchAccountsTest() {
        setUpData();

        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<Country__c> lstCountries = [SELECT Id,Name FROM Country__c];
        List<sobject> returnedResult = WB_MultiSelectLookupAccount.searchAccounts('TestA',null,lstCountries);
        
        System.assertEquals(1, returnedResult.size());
    }
    
    private static testMethod void fetchAccountsTest() {
        setUpData();
        
        Account accRec = [SELECT Id,Name FROM Account];
        List<sObject> returnedResult = WB_MultiSelectLookupAccount.fetchAccounts(accRec,null);
        
        System.assertEquals(1, returnedResult.size());
    }
    
    private static testMethod void saveRecTest() {
        setUpData();
        
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<Account> lstAccount = [SELECT Id,Name FROM Account];
        WB_MultiSelectLookupAccount.saveRec(promoRec.Id, lstAccount);
        
        System.assertEquals(1, [SELECT count() FROM Promotion__c]);
    }
}