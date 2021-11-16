/******* 
WB_ECAccountAllocationDelete_Test
Creation Date- 18 Jun 2019
Description- This class is to Test WB_ECAccountAllocationDelete
Author- Shubham Agrawal
*******/


@isTest
public class WB_ECAccountAllocationDelete_Test {
    
     static testMethod void ECAllocDelTest() {
        // Create Account 
        Account acct2= new Account(Name='test Account2',EC_Digital_Account__c='Digital');
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
        EC_Piece__c ec3 = new EC_Piece__c(EC_Name__c='ec test piece4',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45,
                                    EC_Availability__c='Free to Consumers', International_End_Card__c='Yes',US_End_Card__c = 'Yes');   
        
        lstECPiece.add(ec3);
        insert lstECPiece;
        
        //create EC Account Allocation
        List<EC_Account_Allocation__c> lstECAlloc = new List<EC_Account_Allocation__c>();
        EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec3.Id,MPM__c=mpm1.Id,Account__c=acct2.Id,Format__c='HD');
        lstECAlloc.add(eca1);
        insert lstECAlloc;  
          
                
        ApexPages.StandardSetController objSC = new ApexPages.StandardSetController(lstECAlloc);
        
        PageReference pageRef = Page.WB_ECAccountAllocation_Delete_Lightning;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',ec3.Id);
        
        test.startTest();
            WB_ECAccountAllocationDelete obj = new WB_ECAccountAllocationDelete(objSC);
            obj.delECAllocation();
            
            obj.redirectToECP();
            WB_ECAccountAllocationDelete.deleteECAllocation(ec3.Id);
        test.stopTest();
       
        EC_Account_Allocation__c ecaObj = [Select Id, IsDeleted from EC_Account_Allocation__c WHERE Id = :eca1.Id ALL ROWS];
        System.assertEquals(ecaObj.IsDeleted, true);
         

	}

}