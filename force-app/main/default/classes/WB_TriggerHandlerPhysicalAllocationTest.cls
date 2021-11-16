/*
Class Name   : WB_TriggerHandlerPhysicalAllocationTest 
Description  : This class is to do code coverage for WB_TriggerHandlerPhysicalAllocation class
Created By   : Cognizant Technology Solutions - Harika Bondalapati
Created On   : MAY 2015

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
*/

@isTest
public with sharing class WB_TriggerHandlerPhysicalAllocationTest{
  static testMethod void AllocphysduplicateTest(){
  // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  insert title;
  Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm1.id,Video_Version__c ='555555');
  insert title1;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  system.debug('insert tracker done');
  //create or update EC Piece
  EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',MPM__c=mpm1.Id,EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,EC_Status__c='Pending',Min__c=56,Sec__c=45);
  insert ec1;
  EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',MPM__c=mpm1.Id,EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,EC_Status__c='Pending',Min__c=56,Sec__c=45);
  insert ec2;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title.Id,PLM_ID__c=1);
  insert ecta1;
  Test.startTest();
  
      EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title.Id,PLM_ID__c=2);
      
      try{
          insert ecta;
      }catch(DmlException e) {
         System.debug('The following exception has occurred: ' + e.getMessage());
      }
      try{
          insert ecta1;
      }catch(DmlException e) {
         System.debug('The following exception has occurred: ' + e.getMessage());
      }
      //CH01
      List<EC_Title_Allocation__c> ListECTitle = new List<EC_Title_Allocation__c> ();
      List<EC_Title_Allocation__c> ListECTitleNew = new List<EC_Title_Allocation__c> ();
      EC_Title_Allocation__c ectitle = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title.Id,PLM_ID__c=2);
      ListECTitle.add(ectitle);
      insert ListECTitle;
      //system.assertEquals(ListECTitle[0].Title__c,title.Id);
        for(EC_Title_Allocation__c c: ListECTitle){
            c.Title__c = title1.Id;
            ListECTitleNew.add(c);
        }
        //system.assertEquals(ListECTitleNew[0].Title__c,title1.Id);
        update ListECTitleNew;
      
  Test.stopTest();   
   }  
}