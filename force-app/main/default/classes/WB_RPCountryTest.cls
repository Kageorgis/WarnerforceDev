@isTest
public class WB_RPCountryTest {

    @testSetup static void setup() {

        Country__c countryusa = new Country__c(
            Name = 'USA',
            Country_Code__c = 'US',
	    	Country_Code2__c = 'US'
            );
        insert countryusa;

        Country__c countrycan = new Country__c(
            Name = 'Canada',
            Country_Code__c = 'CA',
	    	Country_Code2__c = 'CA'
            );
        insert countrycan;

        Account newaccount1 = new Account(
            Name = 'WB Internal'
            );
	    newaccount1.RecordTypeID = 
	      Schema.SObjectType.Account.getRecordTypeInfosByName().get('Digital Client').getRecordTypeId();			  
            insert newaccount1;

        Contact newcontact1 = new Contact(
            LastName = 'Mayne'
            );
	    newcontact1.RecordTypeID = 
	      Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBHE Contact').getRecordTypeId();	
	    newcontact1.AccountId = newaccount1.id;		  
            insert newcontact1;

        Release_Planning_Title__c RPTitle1 = new Release_Planning_Title__c(
            Name = 'Falling Skies S1',
	    Marketing_Group__c = 'WB'
            );
	    RPTitle1.WB_HE_Contact__c = newcontact1.id;		  
            insert RPTitle1;

        Release_Planning_Country_Content__c RPCountry1 = new Release_Planning_Country_Content__c(
            Content_Type__c = 'Season'
            );
	    RPCountry1.Release_Planning_Title__c = RPTitle1.id;	
	    RPCountry1.Country__c = countryusa.id;	  
            insert RPCountry1;
    }

    @isTest static void testMethod1() {
	RecordType rtus = [select id,Name from RecordType where SobjectType='Release_Planning_Country_Content__c' and Name='USA' Limit 1];
    RecordType rtca = [select id,Name from RecordType where SobjectType='Release_Planning_Country_Content__c' and Name='Canada' Limit 1];  
	Release_Planning_Title__c RPTitle = [SELECT ID from Release_Planning_Title__c WHERE Name = 'Falling Skies S1' LIMIT 1];
    Release_Planning_Country_Content__c RPCountry1 = new Release_Planning_Country_Content__c(
        Content_Type__c = 'Season',
	    RecordTypeId = rtus.id,
	    Release_Planning_Title__c = RPTitle.id
	    );
        insert RPCountry1;   
        Release_Planning_Country_Content__c RPCountry2 = [SELECT Record_Type_Name__c from Release_Planning_Country_Content__c where ID = :RPCountry1.id];
        System.assertEquals(RPCountry2.Record_Type_Name__c,'USA');
	RPCountry1.RecordTypeId = rtca.Id;
	update RPCountry1;
	Release_Planning_Country_Content__c RPCountry3 = [SELECT Record_Type_Name__c from Release_Planning_Country_Content__c where ID = :RPCountry1.id];
	System.assertEquals(RPCountry3.Record_Type_Name__c,'Canada');
    }
}