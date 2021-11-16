@isTest
private class WB_CA_Upload_Streaming_Controller_Test {

	private static testMethod void testMethod1() {
	    
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
        
	    Test.startTest();
	    
	    ApexPages.StandardController controller = new ApexPages.StandardController(objCAUpload);
        WB_CA_Upload_Streaming_Controller controller1 = new WB_CA_Upload_Streaming_Controller(controller);
        controller1.getlinkForAttachment();
        controller1.getSummaryData();
        delete attachment;
        controller1.getlinkForAttachment();
        test.stoptest();
	}
    
    
    private static testmethod void WB_CAUpload_CreatePushTopic_test(){
        test.starttest();
        WB_CAUpload_CreatePushTopic instance = new WB_CAUpload_CreatePushTopic();
        InstallContext context;
        instance.onInstall(context);
        test.stoptest();
    }
}