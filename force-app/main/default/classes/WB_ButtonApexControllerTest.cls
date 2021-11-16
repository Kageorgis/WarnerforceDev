@isTest
public class WB_ButtonApexControllerTest {

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
        
        //insert Promotion
        Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1',Country__c='India');
        insert promo;
    }
    
    private static testMethod void getRecordTest() {
        setUpData();
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        Promotion__c promoReturnRecord = WB_ButtonApexController.getRecord(promoRec.Id);
        
        System.assertEquals(promoRec.Account_Multipicklist__c, promoReturnRecord.Account_Multipicklist__c);
    }
    
    private static testMethod void deleteRecordTest() {
        setUpData();
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        WB_ButtonApexController.deleteRecord(promoRec);
        
        System.assertEquals(0, [SELECT count() FROM Promotion__c]);
    }
    
    private static testMethod void updateRecordTest() {
        setUpData();
        Promotion__c promoRec = [SELECT Id,Account_Multipicklist__c FROM Promotion__c];
        WB_ButtonApexController.updateRecord(promoRec);
        
        System.assertEquals(0, [SELECT count() FROM Client_Avail_Price__c WHERE Promotion__c = :promoRec.Id]);
    }
}