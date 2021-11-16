/******* 
WB_RedirectContactAssignmentTest
Creation Date- 16 Mar 2015
Description- This class is to do code coverage for WB_RedirectContactAssignment
Author- Harika Bondalapati
*******/
@isTest
public with sharing class WB_RedirectContactAssignmentTest{
    static testMethod void RedirectTest() {
          // create MPM
          MPM__c mpm = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
          insert mpm;
          //create EC Tracker
          EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm.Id);
          insert tracker;
          //Create Account
          Account acct= new Account(Name='test Account',EC_Digital_Account__c='Internal');
          acct.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
          insert acct;
          //Create Contact
          Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',Role__c='EC Vendor;EC Contact');
          insert con;
          //create custom settings
          Custom_Entered_Values__c newCusSet = new Custom_Entered_Values__c(Field_Name__c='EC_Tracker__c',Object_Name__c='Contact_Assignments__c',User_Entered_Value__c='456852',Name='ECTrackerLookupId');
          insert newCusSet;
          Custom_Entered_Values__c newCusSet2 = new Custom_Entered_Values__c(Field_Name__c='Account__c',Object_Name__c='Contact_Assignments__c',User_Entered_Value__c='457852',Name='AccountFieldId');
          insert newCusSet2;
          Custom_Entered_Values__c newCusSet3 = new Custom_Entered_Values__c(Field_Name__c='Id',Object_Name__c='Account',User_Entered_Value__c='459852',Name='AccountNamePrepopulate');
          insert newCusSet3;
          
          //create Contact Assignment
          Test.startTest();
          
              PageReference pageRef = Page.WB_Redirect_Contact_Assignments;
              Test.setCurrentPage(pageRef);
              ApexPages.currentPage().getParameters().put('Id', tracker.Id);
              ApexPages.StandardController sc = new ApexPages.StandardController(tracker);
              //,Contact__c=con.Id
              WB_RedirectContactAssignment cont = new WB_RedirectContactAssignment(sc);
              cont.Redirect();
              Contact_Assignment__c cona = new Contact_Assignment__c(Account__c=acct.Id,EC_Tracker__c=tracker.Id,Role__c='Marketing');
              insert cona;
              system.assertNotEquals(cona.Id,null);
          Test.stopTest();     
    }
}