/*
 ===============================================
Date: 12/07/2020
Test class for RF_CARFromReleaseController
=============================================== */
@isTest
public class RF_CARFromReleaseControllerTest {
    
    static testmethod void createCARTest(){
     
        Profile p = [SELECT Id FROM Profile WHERE Name='SFDC Support Level 2'];
        User u2 = new User(Alias = 'newtest1', Email='newtest1@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newtest1@testorg.com');
        
        System.runAs(u2) {
            list<recordtype> recordtypes = [select id,name from recordtype where sObjectType = 'Release__C' and name = 'Theatrical'];
            country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
            insert cnt;
            language__c lng =  RF_TestUtil.languageList('English',1);
            insert lng;
            System.assertNotEquals(lng.Id, null);
            Account acc = new Account();
            acc.Name = 'test';	
            RF_Studio__c std = new RF_Studio__c();
            std.Distributor__c = 'WB';
            insert std;
            insert acc;  
            System.assertNotEquals(acc.Id, null);
            Release__c rel = new Release__c();
            rel.RF_Studio__c = std.id;
            rel.Country_List__c = 'USA';
            rel.recordtypeid= recordtypes[0].id;
            insert rel;
            
            System.assertNotEquals(rel.Id, null);
            RF_User_Access__c rf = new RF_User_Access__c();
            rf.user__c = u2.id;
            insert rf;
            System.assertNotEquals(rf.Id, null);
            RF_CARFromReleaseController.createCAR(rel.id,'str',acc.id,system.today(), u2.id);
        }
 
    }

}