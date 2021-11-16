/******* 
WB_TriggerHandlerDigitalAllocationTest
Creation Date- 2 Apr 2015
Description- This class is to Test WB_TriggerHandlerDigitalAllocation
Author- Harika Bondalapati
*******/
@isTest
public with sharing class WB_TriggerHandlerDigitalAllocationTest{
    static testMethod void AllocduplicateTest(){
          // create MPM
          MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
          insert mpm1;
          //insert Title
          Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
          insert title;
      
           //Create Account
          Account acct= new Account(Name='test Account',EC_Digital_Account__c='Digital');
          acct.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
          insert acct;
          Account acct2= new Account(Name='test Account2',EC_Digital_Account__c='Digital');
          acct2.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
          insert acct2;
          //create EC Tracker
          EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
          insert tracker;
          //create or update EC Piece
          EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,EC_Status__c='Pending',Min__c=56,Sec__c=45, MPM__c = mpm1.Id);
          insert ec1;
          EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,EC_Status__c='Pending',Min__c=56,Sec__c=45,MPM__c=mpm1.Id);
         // insert ec2;
          //Create a record on ECTitelAllocaiton Object to add ecs to titles
          List<EC_Account_Allocation__c> lstECAlloc = new List<EC_Account_Allocation__c>();
          EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
          lstECAlloc.add(eca1);
          insert lstECAlloc;
          
          ApexPages.StandardSetController objSC = new ApexPages.StandardSetController(lstECAlloc);
          
          Test.startTest();
               PageReference pageRef = Page.WB_EC_Account_Allocation;
               Test.setCurrentPage(pageRef);
               ApexPages.currentPage().getParameters().put('id', mpm1.Id);
               //ApexPages.StandardController sc = new ApexPages.StandardController(mpm1);
               WB_ECAccountAllocation con = new WB_ECAccountAllocation(objSC);
               con.selectclick();
               con.getSelectedValues();
               con.unselectclick();
               con.getunSelectedValues();
               con.Allocate();
               con.updateAll();
               con.Saves();
               con.Cancel();
               EC_Account_Allocation__c eca2 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
               try{
                  insert eca2;
               }catch(DmlException e) {
                  System.debug('The following exception has occurred: ' + e.getMessage());
               }
         Test.stopTest();   
    }  
}