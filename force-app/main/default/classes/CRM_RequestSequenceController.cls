public with sharing class CRM_RequestSequenceController{
    
    public static void executeBeforeInsert(List<Request__c> lstNewRequest){
    	CRM_RequestHandler.UpdateApproverfields(lstNewRequest,null);
    }

    public static void executeBeforeUpdate( list<Request__c> lstNewRequests, Map<Id,Request__c> mapOldRequests) {
    	CRM_RequestHandler.UpdateApproverfields(lstNewRequests,mapOldRequests);
    }
}