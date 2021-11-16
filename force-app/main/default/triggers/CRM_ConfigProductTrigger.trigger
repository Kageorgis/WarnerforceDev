/**
   @Author Cognizant
   @name CRM_ConfigProductTrigger 
   @CreateDate 18 July 2016
   @Description Trigger on Config_Product__c object
   @Version <1.0>
*/
trigger CRM_ConfigProductTrigger on Config_Product__c (before insert,before delete) {

    if(trigger.isInsert && trigger.isBefore) {
        CRM_ConfigProductTgrSequenceController.beforeInsert(trigger.new);
    }
    
    if(trigger.isDelete && trigger.isBefore && CRM_AppConstants.configProductDeleteFlag) {
        CRM_ConfigProductTgrSequenceController.beforeDelete(trigger.old);
    }
    
}