/******* 
WB_ECAccountAllocationTest
Creation Date- 2 Apr 2015
Description- This class is to Test WB_ECAccountAllocation
Author- Harika Bondalapati
*******/
@isTest
public with sharing class WB_ECAccountAllocationTest{
    static testMethod void AllocAccountTest(){
      // create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      //create a title
      Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
      insert title;
       //Create Account
      Account acct= TestUtil.initAccount();
      acct.EC_Digital_Account__c='Digital';
      insert acct;
      
      Account acct2= TestUtil.initAccount();
      acct2.EC_Digital_Account__c='Digital';
      insert acct2;
      
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      //create or update EC Piece
      EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
      insert ec1;
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
      insert ec2;
      
      //Create a record on ECTitelAllocaiton Object to add ecs to titles
      List<EC_Account_Allocation__c> lstECAlloc = new List<EC_Account_Allocation__c>();
      EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
      lstECAlloc.add(eca1);
      insert lstECAlloc;
      
      ApexPages.StandardSetController objSC = new ApexPages.StandardSetController(lstECAlloc);
      
      Test.startTest();
           PageReference pageRef = Page.WB_EC_Account_Allocation;
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id', mpm1.Id);
           //ApexPages.StandardController sc = new ApexPages.StandardController(mpm1);
           WB_ECAccountAllocation con = new WB_ECAccountAllocation(objSC);
           con.getvvs();
           con.getBusinessUnit();
           String acctt1 = acct2.Name + ' -' + ' SD';
           String acctt2 = acct.Name + ' -' + ' HD';
           List<String> st = new List<String>();
           st.add(acctt1);
           st.add(acctt2);
           con.leftselected = st;
           con.selectclick();
           con.getSelectedValues();
           con.unselectclick();
           con.getunSelectedValues();
           con.SelectedVV = title.Id;
           con.SelectedBU = 'TV';
           con.Redirect();
           con.SelectedBU = 'None';
           con.Redirect();
           //ApexPages.currentPage().getParameters().put('SelectedVV',title.Id);
           con.Allocate();
           ApexPages.currentPage().getParameters().put('q', acctt2);
           con.updateAll();
           con.Saves();
           con.Cancel();
           EC_Account_Allocation__c eca = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Account__c=acct2.Id,Format__c='SD');
           insert eca;
           eca1.Format__c = 'SD';
           upsert eca1;
      Test.stopTest();   
   }  
    static testMethod void AllocAccountTest2(){
       // create MPM
       MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
       insert mpm1;
       //create a title
       Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
       insert title;
       Title__c title2 = new Title__c(Name='TestTitle1Sep', Video_Version__c='1234236789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
       insert title2;
       //Create Account
       
       Account acct = TestUtil.initAccount();
       acct.EC_Digital_Account__c='Digital';
       insert acct;

       Account acct2 = TestUtil.initAccount();
       acct2.EC_Digital_Account__c='Digital';
       insert acct2;

       //create EC Tracker
       EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
       insert tracker;
       //create or update EC Piece
       EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
       insert ec1;
       EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
       insert ec2;
       //Create a record on ECTitelAllocaiton Object to add ecs to titles
       List<EC_Account_Allocation__c> lstECAlloc = new List<EC_Account_Allocation__c>();
       EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
       lstECAlloc.add(eca1);
       insert lstECAlloc;
       
       ApexPages.StandardSetController objSC = new ApexPages.StandardSetController(lstECAlloc);
        
       Test.startTest();
           PageReference pageRef = Page.WB_EC_Account_Allocation;
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id', mpm1.Id);
           WB_ECAccountAllocation con = new WB_ECAccountAllocation(objSC);
           for(Integer i=0;i<con.DisplayAcctfmt.size();i++){
              con.leftselected.add(con.DisplayAcctfmt[i].Acctfmt);
           }
           con.getvvs();
           con.selectclick();
           con.getSelectedValues();
           con.unselectclick();
           con.getunSelectedValues();
           con.Allocate();
           con.updateAll();
           con.Saves();
           con.Cancel();
           system.assertEquals(eca1.Format__c,'HD');
           eca1.Format__c = 'SD';
           upsert eca1;
           system.assertEquals(eca1.Format__c,'SD');
       Test.stopTest();   
    }  
    static testMethod void AllocAccountTest3(){
       // create MPM
       MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
       insert mpm1;
       //create a title
       Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
       insert title;
       Title__c title2 = new Title__c(Name='TestTitle1Sep', Video_Version__c='1234236789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
       insert title2;
       //Create Account
       
       Account acct = TestUtil.initAccount();
       acct.EC_Digital_Account__c='Digital';
       insert acct;

       Account acct2 = TestUtil.initAccount();
       acct2.EC_Digital_Account__c='Digital';
       insert acct2;

       //create EC Tracker
       EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
       insert tracker;
       //create or update EC Piece
       EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
       insert ec1;
       EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
       insert ec2;
       //Create a record on ECTitelAllocaiton Object to add ecs to titles
       List<EC_Account_Allocation__c> lstECAlloc = new List<EC_Account_Allocation__c>();
       EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
       lstECAlloc.add(eca1);
       insert lstECAlloc;
       
       ApexPages.StandardSetController objSC = new ApexPages.StandardSetController(lstECAlloc);
       
       Test.startTest();
           PageReference pageRef = Page.WB_EC_Account_Allocation;
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id', mpm1.Id);
           ApexPages.currentPage().getParameters().put('ecpid', ec1.Id);
           WB_ECAccountAllocation con = new WB_ECAccountAllocation(objSC);
           con.SelectedVV = title.Id;
           con.SelectedBU = 'TV';
           con.Redirect();
           con.Cancel();
       Test.stopTest();   
    } 
}