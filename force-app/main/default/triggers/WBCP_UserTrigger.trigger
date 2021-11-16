/*******************************************************************************************************************************************
* File Name     :   WB_AccountTrigger
  @CreateDate 21 May 2021
* Description   :   Trigger for Handler to share Account and CP product records to new user based on region.
* @author       :   CTS
********************************************************************************************************************************************/
trigger WBCP_UserTrigger on User (before insert, before update, after insert, after update) {
    Set<String> profileSet = new Set<string>{CP_ProductUtility.WBCP_ADMIN_LICENSEE_PROFILE,CP_ProductUtility.WBCP_PLAT_LICENSEE_PROFILE};
    if(Trigger.isInsert && Trigger.isafter) {
        Map<id,User> IdUserMap=new Map<Id,User>();
        for(User user:Trigger.new){
            if((profileSet != Null && profileSet.size()>0) && profileSet.contains(user.User_Profile_Name__c) && user.WBCP_Access_Role__c !=Null){
                IdUserMap.put(user.id,user);
            }
        }
        if(IdUserMap.size() > 0){
            WBCP_AccountTriggerHandler.shareAccountRecords(Null,Null,IdUserMap,CP_ProductUtility.WBCP_BATCH);  
            // Calling batch class to share account and CP product records to user 
            database.executeBatch(new WBCP_Batch_UserRecordSharing(IdUserMap)); 
        }
    }
    if(Trigger.isUpdate && Trigger.isafter){
        Map<id,User> IdUserMap=new Map<Id,User>();
        for(User user: Trigger.new){
            User oldUser = Trigger.oldMap.get(user.id);
            if((profileSet != Null && profileSet.size()>0) && profileSet.contains(user.User_Profile_Name__c) && oldUser !=null && oldUser.WBCP_Access_Role__c == null && user.WBCP_Access_Role__c !=''){
                IdUserMap.put(user.id,user);
            }
        }
         if(IdUserMap.size() > 0){
         // Calling batch class to share account and CP product records to user 
          WBCP_AccountTriggerHandler.shareAccountRecords(Null,Null,IdUserMap,CP_ProductUtility.WBCP_BATCH); 
          database.executeBatch(new WBCP_Batch_UserRecordSharing(IdUserMap)); 
        }
    }
}