global class WB_CAUpload_CreatePushTopic implements InstallHandler {
	global void onInstall(InstallContext context) {
        PushTopic pushTopic;
        try{
        	pushTopic = [select Name, query, ApiVersion, NotifyForOperations, NotifyForFields
            	         from PushTopic where name = 'CAUploadSummaryData'];
        }catch(Exception e){}
        
        if (pushTopic == null){
            pushTopic = new PushTopic();
        }
        system.debug('*******pushTopic'+pushTopic);
        if(test.isRunningTest())
            pushTopic.Name = 'CAUploadSummaryDatatest';
        else
            pushTopic.Name = 'CAUploadSummaryData';
        pushTopic.Query = 'SELECT Id,Name,Total_Stream__c,Total_Successful_Stream__c,Total_Fail_Stream__c,Upload_Status__c FROM CA_Upload__c';
        pushTopic.ApiVersion = 36.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = true;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'Referenced';
        system.debug('*******pushTopic'+pushTopic);
        upsert pushTopic;
    }
}