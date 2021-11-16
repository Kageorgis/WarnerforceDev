/******* 
WB_PhysicalAllocationsTest
Creation Date- 2 Apr 2015
Description- This class is to Test WB_PhysicalAllocations
Author- Harika Bondalapati
*******/
@isTest
public with sharing class WB_PhysicalAllocationsTest{
    static testMethod void AllocTest(){
      // create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      //create a title
      Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
      insert title;
      Title__c title2 = new Title__c(Name='TestTitle12Sep2', Video_Version__c='123486789',MPM__c=mpm1.Id);
      insert title2;
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      //create or update EC Piece
      EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
      insert ec1;
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
      insert ec2;
      //Create a record on ECTitelAllocaiton Object to add ecs to titles
      EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title.Id);
      insert ecta1;
      Test.startTest();
           PageReference pageRef = Page.WB_PhysicalAllocations;
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id', mpm1.Id);
           ApexPages.StandardController sc = new ApexPages.StandardController(mpm1);
           WB_PhysicalAllocations con = new WB_PhysicalAllocations(sc);
           con.selectclick();
           con.getSelectedValues();
           con.unselectclick();
           con.getunSelectedValues();
           con.Next();
           ApexPages.currentPage().getParameters().put('q', title.Id);
           con.updateAll();
           con.Saves();
           con.Cancel();
           EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title.Id);
           insert ecta;
           system.assertNotEquals(ecta.Id,null);
      Test.stopTest();   
    }  
   
    static testMethod void AllocTest2(){
      // create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      //create a title
      Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
      insert title;
      Title__c title2 = new Title__c(Name='TestTitleSep', Video_Version__c='123496789',MPM__c=mpm1.Id);
      insert title2;
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      //create or update EC Piece
      EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
      insert ec1;
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
      insert ec2;
      //Create a record on ECTitelAllocaiton Object to add ecs to titles
      
      Test.startTest();
           PageReference pageRef = Page.WB_PhysicalAllocations;
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id', mpm1.Id);
           ApexPages.StandardController sc = new ApexPages.StandardController(mpm1);
           WB_PhysicalAllocations con = new WB_PhysicalAllocations(sc);
           String titl1 = title.Video_Version__c + '-' + title.Name;
           String titl2 = title2.Video_Version__c + '-' + title2.Name;
           List<String> st = new List<String>();
           st.add(titl1);
           st.add(titl2);
           con.leftselected = st;
           con.selectclick();
           con.getSelectedValues();
           con.unselectclick();
           con.getunSelectedValues();
           con.Next();
           con.updateAll();
           con.Saves();
           con.Cancel();
           EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title.Id);
           insert ecta;
           system.assertNotEquals(ecta.Id,null);
       Test.stopTest();   
    }  
}