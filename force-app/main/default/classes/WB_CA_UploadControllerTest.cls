/*******************************************************************************************************************************************
* File Name     :   WB_CA_UploadControllerTest
* Description   :   Test class for WB_CA_UploadController for WB_CA_Staging page
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     04 Nov.2015       CTS                 ER-000069 : Created the class.
********************************************************************************************************************************************/


@isTest
private class WB_CA_UploadControllerTest {

    private static testMethod void test1() {
        
        Test.startTest();
        CA_Upload__c objCAUpload =  new CA_Upload__c(Requested_User__c = UserInfo.getUserId(), 
                                        Requested_User_Email_Id__c = UserInfo.getUserEmail(),
                                        Requested_User_Profile_Id__c = UserInfo.getProfileId(),
                                        Upload_Status__c = 'Completed',
                                        Upload_Time__c = System.now());
        insert objCAUpload;
        
        Blob b = Blob.valueOf('Test Data');  
        Attachment attachment = new Attachment(); 
        attachment.Name = 'Test Attachment for Parent.xlsx';
        attachment.Body = b;
        attachment.ParentId = objCAUpload.id;
        insert attachment;
        
        WB_CA_UploadController objController = new WB_CA_UploadController();
        Test.stopTest();
        
        List<CA_Upload__c> cuList = [Select Id from CA_Upload__c];
        system.assertNotEquals(null, cuList);
        system.assertEquals(1, cuList.size());
	}
    
	private static testMethod void test2() {
        
        Test.startTest();
        WB_CA_UploadController objController = new WB_CA_UploadController();
        objController.ReadFile();
        Test.stopTest();
        
        List<CA_Upload__c> cuList = [Select Id from CA_Upload__c];
        system.assertNotEquals(null, cuList);
        system.assertEquals(1, cuList.size());
        
        List<Attachment> attachList = [Select Id from Attachment];
        system.assertEquals(0, attachList.size());
	}
	
	private static testMethod void test3() {
        
        Test.startTest();
        
        WB_CA_UploadController objController = new WB_CA_UploadController();
        
        Blob b = Blob.valueOf('Test Data');  
        Attachment attachment = new Attachment(); 
        attachment.Name = 'Test Attachment for Parent.xlsx';
        attachment.Body = b;
        objController.objAttachment = attachment;
        
        objController.ReadFile();
        
        Test.stopTest();
        
        List<CA_Upload__c> cuList = [Select Id from CA_Upload__c];
        system.assertNotEquals(null, cuList);
        system.assertEquals(1, cuList.size());
	}
	
	private static testMethod void test4() {
        
        Test.startTest();
        CA_Upload__c objCAUpload =  new CA_Upload__c(Requested_User__c = UserInfo.getUserId(), 
                                        Requested_User_Email_Id__c = UserInfo.getUserEmail(),
                                        Requested_User_Profile_Id__c = UserInfo.getProfileId(),
                                        Upload_Status__c = 'Completed',
                                        Upload_Time__c = System.now());
        insert objCAUpload;
        
        Blob b = Blob.valueOf('Test Data');  
        Attachment attachment = new Attachment(); 
        attachment.Name = 'Test Attachment for Parent.xlsx';
        attachment.Body = b;
        attachment.ParentId = objCAUpload.id;
        insert attachment;
        
        Blob b1 = Blob.valueOf('Test Data');  
        Attachment attachment1 = new Attachment(); 
        attachment1.Name = 'Test Attachment for Parent1.xlsx';
        attachment1.Body = b1;
        attachment1.ParentId = objCAUpload.id;
        insert attachment1;
        
        WB_CA_UploadController objController = new WB_CA_UploadController();
        Test.stopTest();
        
        List<CA_Upload__c> cuList = [Select Id from CA_Upload__c];
        system.assertNotEquals(null, cuList);
        system.assertEquals(1, cuList.size());
	}
   
}