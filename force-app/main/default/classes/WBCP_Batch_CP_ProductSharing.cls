global class WBCP_Batch_CP_ProductSharing implements Database.Batchable<sObject>{
    List<CP_Product__c> newCPProductList = new List<CP_Product__c>();
    Public String roleName;
    Set<String> profileSet = new Set<string>{CP_ProductUtility.WBCP_ADMIN_LICENSEE_PROFILE,CP_ProductUtility.WBCP_PLAT_LICENSEE_PROFILE};
    
    global WBCP_Batch_CP_ProductSharing(List<CP_Product__c> cpProductList,String wbAccessRole){
        newCPProductList=cpProductList;
        roleName= wbAccessRole;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,User_License_Type__c,ProfileId,WBCP_Access_Role__c,UserRoleId,UserRole.Name, Country FROM User WHERE User_License_Type__c =: CP_ProductUtility.WBCP_SALESFORCE_PLATFORM AND isActive = True AND WBCP_Access_Role__c != Null AND WBCP_Access_Role__c =:roleName AND Profile.Name IN: profileSet]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){  
      try{
             CPProductApexSharingHandler.shareCPRecords(newCPProductList,scope,CP_ProductUtility.WBCP_BATCH);
        } catch(Exception  ex) {
            system.debug(LoggingLevel.INFO,'WBCP_Batch_CP_ProductSharing Batch error='+ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
  }
}