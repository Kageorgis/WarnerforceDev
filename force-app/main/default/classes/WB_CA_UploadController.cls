/*******************************************************************************************************************************************
* File Name     :   WB_CA_UploadController
* Description   :   Controller for WB_CA_Staging page
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21 Oct.2015       CTS                 ER-000069 : Created the class.
* 2.0     04 Nov.2015       CTS                 Removed Generate CSV Tab code
********************************************************************************************************************************************/

public with sharing class WB_CA_UploadController {
    
    public Boolean activeTab {get;set;}
    public List<CA_Upload__c> CAUploadList {get;set;} 
    Public attachment objAttachment{get; set;}
    private String fileName;
    private Integer fileSize;
    private Blob fileBody;
    public Map<Id,Id> mapCAUploadAttachementIds {get; set;}
    public String ChkMapKey{get; set;}
    //public map<String,Set<string>> mapObjectNameStFields;
   public String strReportObjectName;
    public WB_CA_UploadController() {
        
        activeTab = false;
        mapCAUploadAttachementIds = new Map<Id,Id>();
        objAttachment = new Attachment();
        
        CAUploadList = [SELECT Id, Name, Requested_User__c, Upload_Time__c, Upload_Batch_Number__c, Upload_Status__c, Number_of_Records_Uploaded__c, Number_of_Records_Processed__c, Number_of_Records_Failed__c  
                        FROM CA_Upload__c 
                        WHERE OwnerId =: UserInfo.getUserId() AND Upload_Status__c =: 'Completed' ORDER BY Upload_Time__c DESC];
                        /*AND CreatedDate >: (system.today()-2) 
                        ORDER BY LastModifiedDate DESC ];*/

        if(CAUploadList.size() < 0 || CAUploadList.isEmpty()) {
            activeTab = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No CA Upload records are available for this User.');
            ApexPages.addMessage(myMsg);
        }
        for(Attachment att : [SELECT Id,ParentId FROM Attachment where Parentid in: CAUploadList]){
            if(!mapCAUploadAttachementIds.containskey(att.ParentId))
                mapCAUploadAttachementIds.put(att.ParentId,att.id);
            else
                mapCAUploadAttachementIds.remove(att.ParentId);
        }
        ChkMapKey = string.valueof(mapCAUploadAttachementIds.keyset()).replace('{', '').replace('{', '');
    }
    
    public Pagereference ReadFile(){
        
        CA_Upload__c cauToUpload = new CA_Upload__c(Requested_User__c = UserInfo.getUserId(), 
                                                    Requested_User_Email_Id__c = UserInfo.getUserEmail(),
                                                    Requested_User_Profile_Id__c = UserInfo.getProfileId(),
                                                    Upload_Status__c = 'Uploaded',
                                                    Upload_Time__c = System.now()
                                                    );
        insert cauToUpload;
        
        objAttachment.ParentId = cauToUpload.Id;
        objAttachment.IsPrivate = false;

        try {
                insert objAttachment;
        } catch (DMLException err) {
            if(err.getMessage().contains('REQUIRED_FIELD_MISSING'))
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select file for attachment.'));
            return null;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        } finally {
            objAttachment = new Attachment(); 
        }
        
        cauToUpload = [Select Id, Name from CA_Upload__c where Id =: cauToUpload.Id];
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your file has been uploaded. Your Upload Request Id is '
                            + cauToUpload.Name +'. Please wait for email confirming records have completed processing, then revisit this page and click Upload Results tab to download failed records, if any..'));
        return new Pagereference('/apex/WB_CA_Upload_Streaming?id='+cauToUpload.Id);
   
    }
    
    
    
}