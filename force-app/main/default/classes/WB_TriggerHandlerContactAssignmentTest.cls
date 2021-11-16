/*
Class Name   : WB_TriggerHandlerContactAssignmentTest 
Description  : This class is to do code coverage for WB_TriggerHandlerContactAssignment            
Created By   : Cognizant Technology Solutions - Harika Bondalapati
Created On   : March 2015

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                       4/27/2016
       scenarios.                      
*/

@isTest
public with sharing class WB_TriggerHandlerContactAssignmentTest{
    static testMethod void updateMPMTest() {
      // create MPM
      //MPM_Long_Desc__c='test long',
      MPM__c mpm = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm;
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm.Id);
      insert tracker;
      //Create Account
      Account acct = TestUtil.initAccount();
      acct.EC_Digital_Account__c='Internal';
      insert acct;
      //Create Contact
      Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',Role__c='EC Contact');
      insert con;
      Contact con2 = new Contact(AccountId=acct.Id,LastName='test Lastname',Role__c='Marketing');
      insert con2;
      //create or update Contact role
      Test.startTest();
          List<Contact_Assignment__c> consList = new List<Contact_Assignment__c>();
          List<Contact_Assignment__c> consListNew = new List<Contact_Assignment__c>();
          Contact_Assignment__c conrol1 = new Contact_Assignment__c(Account__c=acct.Id,Contact__c=con.Id,EC_Tracker__c=tracker.Id,Role__c='EC Contact');
          consList.add(conrol1);
          Contact_Assignment__c conrol2 = new Contact_Assignment__c(Account__c=acct.Id,Contact__c=con2.Id,EC_Tracker__c=tracker.Id);
          consList.add(conrol2);
          insert consList;
          //system.assertEquals(consList.size(),2);
          //conrol1.Role__c = '';
          //update conrol1;
          system.debug('insert done');
          Contact_Assignment__c conres2 = [select Id,Role__c from Contact_Assignment__c where Id =:conrol2.Id];
          //CH01
          //system.assertEquals(conres2.Role__c,'Marketing');
          //system.assertEquals(conrol1.Role__c,'EC Contact');
          for(Contact_Assignment__c cont : consList){
              cont.Role__c = '';
              consListNew.add(cont);
              
          }
          //system.assertEquals(consListNew[1].Role__c, '');
          update consListNew;
      Test.stopTest();     
   }
}