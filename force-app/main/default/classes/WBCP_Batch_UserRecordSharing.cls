/*
   @Author: Nilesh Jha
   @name WBCP_Batch_UserRecordSharing
   @CreateDate 21 May 2021
   @Description: Batch Class to share Account and CP product record to new user based on region.
   @Version 52
  */
global class WBCP_Batch_UserRecordSharing implements Database.Batchable<sObject> {
  Map<id,User> IdUserMapBatch=new Map<id,User>();
  
  global WBCP_Batch_UserRecordSharing(Map<id,User> IdUserMap){
    IdUserMapBatch=IdUserMap;
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator([Select Id,Licensee__c,WBCP_Country__c,WBCP_Country__r.Name,OwnerId from CP_Product__c]);
  }
   
  global void execute(Database.BatchableContext BC, List<CP_Product__c> scope){    
    try{
      CPProductApexSharingHandler.shareCPRecords(scope,IdUserMapBatch.values(),CP_ProductUtility.WBCP_BATCH);
    } catch(Exception  ex) {
      system.debug(LoggingLevel.INFO,'WBCP_Batch_UserRecordSharing Batch error='+ex.getMessage());
    }
  }
    
  global void finish(Database.BatchableContext BC) {
  }
}