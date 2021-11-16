@isTest
public class WB_AutomateDigitalAllocationTest 
{

	static testMethod void automateAllocationTest() 
	{
	  //Create Digital Accounts
      Account acct2= TestUtil.initAccount();
      acct2.EC_Digital_Account__c='Digital';
      insert acct2;
      
      Account acct = TestUtil.initAccount();
      acct.EC_Digital_Account__c='Digital';
      acct.Season_Pass__c=true;
      insert acct;
      
      //Create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      
      //create a title
      Title__c title = new Title__c(Name='TestTitle23Feb', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
      insert title;
      
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      
      //create EC Pieces
      List<EC_Piece__c> lstECPiece = new List<EC_Piece__c>();
      EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,EC_Availability__c='Season pass');
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,EC_Availability__c='Free to Consumers');
      EC_Piece__c ec3 = new EC_Piece__c(EC_Name__c='ec test piece3',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers', International_End_Card__c='12');
      EC_Piece__c ec4 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers', International_End_Card__c='Yes',US_End_Card__c = 'Yes');   
      EC_Piece__c ec5 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers',US_End_Card__c = 'Yes');   
      EC_Piece__c ec6 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers',US_End_Card__c = 'Yes');   
      lstECPiece.add(ec1);
      lstECPiece.add(ec2);
      lstECPiece.add(ec3);
      lstECPiece.add(ec4);
      lstECPiece.add(ec5);
      lstECPiece.add(ec6);
      insert lstECPiece;
      
      //Create EC_Digital_Account_Set_Up
      List<EC_Digital_Account_Set_Up__c> setUpList = new List<EC_Digital_Account_Set_Up__c>();
      EC_Digital_Account_Set_Up__c setUp1 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Season pass', Account__c = acct.Id, Format__c='SD');
      EC_Digital_Account_Set_Up__c setUp2 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='SD');
      EC_Digital_Account_Set_Up__c setUp3 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Season pass', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp4 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp5 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD', International_End_Card__c='Yes');
      EC_Digital_Account_Set_Up__c setUp6 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD', International_End_Card__c='Yes',US_End_Card__c = 'Yes');
      EC_Digital_Account_Set_Up__c setUp7 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD', US_End_Card__c = 'Yes');
      EC_Digital_Account_Set_Up__c setUp8 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD', US_End_Card__c = 'Yes');
      setUpList.add(setUp1);
      setUpList.add(setUp2);
      setUpList.add(setUp3);
      setUpList.add(setUp4);
      setUpList.add(setUp5);
      setUpList.add(setUp6);
      setUpList.add(setUp7);
      setUpList.add(setUp8);
      insert setUpList;
      
      test.startTest();
      
      pageReference pageRef = page.WB_AutomateECAllocation;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', title.Id);
      ApexPages.currentPage().getParameters().put('bu', 'TV');
      ApexPages.currentPage().getParameters().put('mpmId', mpm1.Id);
      
      WB_AutomateDigitalAllocation ada = new WB_AutomateDigitalAllocation();
      ada.automateAllocation();
      ada.getInsertedAllocations();
      ada.getErrCount();
      ada.returnToMpm();
      
      test.stopTest();
      
	}
	
	static testMethod void automateAllocationTest_negetive() 
	{
	  //Create Digital Accounts
      Account acct = TestUtil.initAccount();
      acct.EC_Digital_Account__c='Digital';
      acct.Season_Pass__c=true; 
      insert acct;

      /*Account acct2= new Account(Name='test Account2',EC_Digital_Account__c='Digital');
      insert acct2;*/
      
      //Create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      
      //create a title
      Title__c title = new Title__c(Name='TestTitle23Feb', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
      insert title;
      
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      
      //create EC Pieces
      List<EC_Piece__c> lstECPiece = new List<EC_Piece__c>();
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,EC_Availability__c='Free to Consumers');
      EC_Piece__c ec3 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers', International_End_Card__c='Yes',US_End_Card__c = 'Yes');   
      EC_Piece__c ec4 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers',US_End_Card__c = 'Yes');
      EC_Piece__c ec5 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                        EC_Availability__c='Free to Consumers',US_End_Card__c = 'Yes');
                                        
      lstECPiece.add(ec2);
      lstECPiece.add(ec3);
      lstECPiece.add(ec4);
      lstECPiece.add(ec5);
      insert lstECPiece;
      
      
      EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
      insert eca1;
      
      EC_Account_Allocation__c eca2 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec3.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
      insert eca2;
      try{
        EC_Account_Allocation__c eca3 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec3.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
        insert eca3;
      }
      catch(Exception e){
          system.assert(+e.getMessage().contains('This allocation record already exists. Please select another Digital Client or EC'));
      }
      
      //Create EC_Digital_Account_Set_Up
      List<EC_Digital_Account_Set_Up__c> setUpList = new List<EC_Digital_Account_Set_Up__c>();
      EC_Digital_Account_Set_Up__c setUp2 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp3 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='HD', International_End_Card__c='Yes',US_End_Card__c = 'Yes');
      EC_Digital_Account_Set_Up__c setUp4 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='HD', US_End_Card__c = 'Yes');
      EC_Digital_Account_Set_Up__c setUp5 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='HD', International_End_Card__c = 'Yes');
      setUpList.add(setUp2);
      setUpList.add(setUp3);
      setUpList.add(setUp4);
      setUpList.add(setUp5);
      insert setUpList;
      
      test.startTest();
      
      pageReference pageRef = page.WB_AutomateECAllocation;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', title.Id);
      ApexPages.currentPage().getParameters().put('bu', 'TV');
      ApexPages.currentPage().getParameters().put('mpmId', mpm1.Id);
      
      WB_AutomateDigitalAllocation ada = new WB_AutomateDigitalAllocation();
      ada.automateAllocation();
      ada.getInsertedAllocations();
      ada.getErrCount();
      ada.returnToMpm();
      
      test.stopTest();
      

	}
	
	static testMethod void automateAllocationTest3() 
	{
	  //Create Digital Accounts
      Account acct = TestUtil.initAccount();
      acct.EC_Digital_Account__c='Digital';
      acct.Season_Pass__c=true; 
      insert acct;
      
      Account acct2 = TestUtil.initAccount();
      acct2.EC_Digital_Account__c='Digital';
      acct2.Season_Pass__c=true; 
      insert acct2;
      
      //Create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      
      //create a title
      Title__c title = new Title__c(Name='TestTitle23Feb', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
      insert title;
      
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      
      //create EC Pieces
      List<EC_Piece__c> lstECPiece = new List<EC_Piece__c>();
      EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45, EC_Status__c='Final');
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45, EC_Status__c='Final');
      lstECPiece.add(ec1);
      lstECPiece.add(ec2);
      insert lstECPiece;
      
      //Create EC_Digital_Account_Set_Up
      List<EC_Digital_Account_Set_Up__c> setUpList = new List<EC_Digital_Account_Set_Up__c>();
      EC_Digital_Account_Set_Up__c setUp1 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Season pass', Account__c = acct.Id, Format__c='SD');
      EC_Digital_Account_Set_Up__c setUp2 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='SD');
      EC_Digital_Account_Set_Up__c setUp3 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Season pass', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp4 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp5 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TCAT', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp6 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TCAT', Account__c = acct.Id, Format__c='HD');
      setUpList.add(setUp1);
      setUpList.add(setUp2);
      setUpList.add(setUp3);
      setUpList.add(setUp4);
      setUpList.add(setUp5);
      setUpList.add(setUp6);
      insert setUpList;
      
      test.startTest();
      
      pageReference pageRef = page.WB_AutomateECAllocation;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', title.Id);
      ApexPages.currentPage().getParameters().put('bu', 'TCAT');
      ApexPages.currentPage().getParameters().put('mpmId', mpm1.Id);
      
      WB_AutomateDigitalAllocation ada = new WB_AutomateDigitalAllocation();
      ada.automateAllocation();
      ada.getInsertedAllocations();
      ada.getErrCount();
      ada.returnToMpm();
      
      test.stopTest();
      
	}
	static testMethod void automateAllocationTest4() 
	{
	  //Create Digital Accounts
      Account acct = TestUtil.initAccount();
      acct.EC_Digital_Account__c='Digital';
      acct.Season_Pass__c=true; 
      insert acct;
      
      Account acct2 = TestUtil.initAccount();
      acct2.EC_Digital_Account__c='Digital';
      acct2.Season_Pass__c=true; 
      insert acct2;
      
      //Create MPM
      MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
      insert mpm1;
      
      //create a title
      Title__c title = new Title__c(Name='TestTitle23Feb', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes');
      Title.Digital_Planning__c = 'NO';
      insert title;
      
      //create EC Tracker
      EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
      insert tracker;
      
      //create EC Pieces
      List<EC_Piece__c> lstECPiece = new List<EC_Piece__c>();
      EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45, EC_Status__c='Final');
      EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45, EC_Status__c='Final');
      lstECPiece.add(ec1);
      lstECPiece.add(ec2);
      insert lstECPiece;
      
      //Create EC_Digital_Account_Set_Up
      List<EC_Digital_Account_Set_Up__c> setUpList = new List<EC_Digital_Account_Set_Up__c>();
      EC_Digital_Account_Set_Up__c setUp1 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Season pass', Account__c = acct.Id, Format__c='SD');
      EC_Digital_Account_Set_Up__c setUp2 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct.Id, Format__c='SD');
      EC_Digital_Account_Set_Up__c setUp3 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Season pass', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp4 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TV', EC_Availability__c='Free to Consumers', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp5 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TCAT', Account__c = acct2.Id, Format__c='HD');
      EC_Digital_Account_Set_Up__c setUp6 = new EC_Digital_Account_Set_Up__c(Business_Unit__c='TCAT', Account__c = acct.Id, Format__c='HD');
      setUpList.add(setUp1);
      setUpList.add(setUp2);
      setUpList.add(setUp3);
      setUpList.add(setUp4);
      setUpList.add(setUp5);
      setUpList.add(setUp6);
      insert setUpList;
      
      test.startTest();
      
      pageReference pageRef = page.WB_AutomateECAllocation;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id', title.Id);
      ApexPages.currentPage().getParameters().put('bu', 'TCAT');
      ApexPages.currentPage().getParameters().put('mpmId', mpm1.Id);
      ApexPages.currentPage().getParameters().put('ecpieceId', ec1.Id);
      
      WB_AutomateDigitalAllocation ada = new WB_AutomateDigitalAllocation();
      ada.automateAllocation();
      ada.getInsertedAllocations();
      ada.getErrCount();
      ada.returnToMpm();
      
      test.stopTest();
      
	}
}