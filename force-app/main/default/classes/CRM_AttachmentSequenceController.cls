public with sharing class CRM_AttachmentSequenceController {
    public static void executeBeforeDelete(List<attachment> oldAttachments) {
    	set<Id> setOfRequestIds = new Set<Id>();
    	Map<Id,Request__c> mapOfRequests = new Map<Id,Request__c>();
    	Id createdID = CRM_Default_Configuration__c.getOrgDefaults().Email_Service_User_Id__c;
	  	for(Attachment attch : oldAttachments){ 
	  		setOfRequestIds.add(attch.ParentId);
	  		if(attch.CreatedById == createdID)
  				attch.addError(System.label.CRM_Delete_Attachment_Error);
  		} 
  		
  		if(!setOfRequestIds.isEmpty()){
  			mapOfRequests = new Map<Id,Request__c>([Select Id,Status__c From Request__c Where Id IN :setOfRequestIds]);
  			if(!mapOfRequests.isEmpty()){
  				for(Attachment attch : oldAttachments){ 
  					if(mapOfRequests.containsKey(attch.ParentId) && 
  					   mapOfRequests.get(attch.ParentId) != null && 
  					   mapOfRequests.get(attch.ParentId).Status__c != CRM_AppConstants.REQUEST_DRAFT_STATUS){
  						attch.addError(System.label.CRM_Delete_Attachment_Error);
  					}
  				}
  			}
  		}
    }
}