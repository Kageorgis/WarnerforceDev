@isTest
private class WB_CAUploadTriggerHandlerTest {

	private static testMethod void testmethod1() {
        CA_Upload__c caUpload = new CA_Upload__c(Upload_Status__c='Uploaded');
        insert caUpload;
        Attachment newAttachment = new Attachment();
        newAttachment.Body = blob.valueof('testbody'); 
        newAttachment.Name = 'Uploaded Document'; 
        newAttachment.ContentType = 'csv'; 
        newAttachment.ParentId = caUpload.id; 
        insert newAttachment;
        test.startTest();
        caUpload.Upload_Status__c='Waiting To Process';
        update caUpload;
        test.stopTest();
        List<Attachment> attachmentList = new List<Attachment>([Select id from Attachment where ParentId =: caUpload.id]);
        system.assertEquals(attachmentList.size(), 0);
	}

}