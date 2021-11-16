@isTest
public class WB_MultiSelectLookupControllerTest {

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
        List<sobject> lstAccounts = WB_MultiSelectLookupController.loadRec(promoRec.Id);
        
        System.assertEquals(1, lstAccounts.size());
    }
    
    private static testMethod void loadCountriesTest() {
        setUpData();

        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<Country__c> lstCountries = [SELECT Id,Name FROM Country__c];
        List<sobject> returnedResult = WB_MultiSelectLookupController.loadCountries(promoRec.Id);
        
        System.assertEquals(1, returnedResult.size());
    }
    
    private static testMethod void fetchLookUpValuesTest() {
        setUpData();
        
        Account accRec = [SELECT Id,Name FROM Account];
        List<sObject> returnedResult = WB_MultiSelectLookupController.fetchLookUpValues('Test',null);
        
        System.assertEquals(0, returnedResult.size());
    }
    
    private static testMethod void fetchCountryNamesTest() {
        setUpData();
        
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<Country__c> availableCountries = [SELECT Id,Name FROM Country__c];
        List <sObject> lstReturnedResult = WB_MultiSelectLookupController.fetchCountryNames('Ind',null,null,availableCountries);
        
        System.assertEquals(1, lstReturnedResult.size());
    }
    
    private static testMethod void fetchCountryValuesTest() {
        setUpData();
        
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        Country__c countRec = [SELECT Id,Name FROM Country__c WHERE Name = 'India'];
        List<Country__c> availableCountries = [SELECT Id,Name FROM Country__c];
        List <sObject> lstReturnedResult = WB_MultiSelectLookupController.fetchCountryValues(countRec,null,availableCountries);
        
        System.assertEquals(0, lstReturnedResult.size());
    }
    
    private static testMethod void fetchCountryValuesCountryTest() {
        setUpData();
        
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        Country__c countRec = [SELECT Id,Name FROM Country__c WHERE Name = 'India'];
        List<Country__c> availableCountries = [SELECT Id,Name FROM Country__c];
        List <sObject> lstReturnedResult = WB_MultiSelectLookupController.fetchCountryValuesCountry(countRec,null,availableCountries);
        
        System.assertEquals(1, lstReturnedResult.size());
    }
    
    private static testMethod void saveRecTest() {
        setUpData();
        
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        List<Country__c> lstCountries = [SELECT Id,Name FROM Country__c];
        WB_MultiSelectLookupController.saveRec(promoRec.Id,lstCountries);
        
        System.assertEquals('India', [SELECT Id,Name,Country__c FROM Promotion__c WHERE Id = :promoRec.Id].Country__c);
    }
}