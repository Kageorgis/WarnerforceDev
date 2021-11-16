/**
   @Author Cognizant
   @name CRM_AttachmentSequenceController_Test
   @CreateDate 9 Dec 2016
   @Description Test class for CRM_AttachmentSequenceController
   @Version <1.0>
   @reference Requirement no 536(JAPAN)
  */
  
@isTest(seeAlldata=false)
public with sharing class CRM_AttachmentSequenceController_Test {
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static Attachment requestAttachment;
    static Attachment orderAttachment;
    static Order newOrder;
    static Request__c req;
    
    static void createTestData() {
    list<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, false);
    lstParentAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
    lstParentAccounts[0].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    insert lstParentAccounts;
        
    req = new Request__c();
    req.Account__c = lstParentAccounts[0].Id;
    req.Type__c = 'Contract';
    req.Sub_Type__c = 'New Account Open';
    insert req;
        
    String orderReturnOrderId = Schema.SObjectType.Order.getRecordTypeInfosByname().get('Return').getRecordTypeId();
    
    newOrder = new Order();
    newOrder.AccountId = lstParentAccounts[0].Id;
    newOrder.EffectiveDate = system.today();
    newOrder.Customer_PO_Number__c = 'CPN3442';
    newOrder.recordTypeId = orderReturnOrderId;
    newOrder.Status = 'Open';
    insert newOrder;
        
    requestAttachment = new Attachment();
    requestAttachment.Name = 'Testing Aattachment';
    requestAttachment.ParentId = req.Id;
    requestAttachment.body = Blob.valueof('Testing Delete Attachment Functionality For Request');
    insert requestAttachment;
    
    User u = [Select Id from User where Profile.Name = 'SAP Integration API Only' and isActive = true Limit 1];
    
    CRM_Default_Configuration__c customSet = new CRM_Default_Configuration__c();
    customSet.Email_Service_User_Id__c = u.Id;
    insert customSet; 
    
        System.runAs(u){
            orderAttachment = new Attachment();
            orderAttachment.Name = 'Testing Order Aattachment';
            orderAttachment.ParentId = newOrder.Id;
            orderAttachment.body = Blob.valueof('Testing Delete Attachment Functionality For Order with Specific User');
            insert orderAttachment ;
        }
    }
    
    /**
    *  Added By:Ketan
    *  Test 1: Delete Attachment attached for Request Which has status not equal to Draft
    *  @name deleteAttachmentForRequestTest
    */
    static testMethod void deleteAttachmentForRequestTest(){
        createTestData();
        Approval.ProcessSubmitRequest reqApproval = new Approval.ProcessSubmitRequest();
        reqApproval.setObjectId(req.Id);
        reqApproval.setProcessDefinitionNameOrId('CRM_Request_Approval_Process_Japan_V1');
        Approval.ProcessResult resultApprovalProcess = Approval.process(reqApproval);
        try{
            delete requestAttachment;
        }Catch(System.DmlException ex){
            Boolean expectedExceptionThrown =  (ex.getDmlMessage(0).contains(System.label.CRM_Delete_Attachment_Error)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /**
    *  Added By:Ketan
    *  Test 2: Delete Attachment attached for Request Which has status equal to Draft
    *  @name deleteAttachmentForRequestStatusEqualToDraftTest
    */
    static testMethod void deleteAttachmentForRequestStatusEqualToDraftTest(){
        createTestData();
        delete requestAttachment;
        system.assertEquals(0,[Select count() From Attachment where parentId =: req.Id]);
    }
    
    /**
    *  Added By: Tushar
    *  Test 3: Delete Attachment attached for Order
    *  @name deleteAttachmentForOrderTest
    */
    static testMethod void deleteAttachmentForOrderTest(){
        createTestData();
        
        string errorMessage = label.CRM_Delete_Attachment_Error;
        
        Test.startTest();
            Database.DeleteResult result = Database.delete(orderAttachment, false);
        Test.stopTest();
        system.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals(errorMessage ,result.getErrors()[0].getMessage());
    }
}