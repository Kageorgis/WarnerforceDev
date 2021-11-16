/** 
* Author: cognizant Team
* Description: This trigger is used to call methods from Handllers to udpate Deal Product and Deal
* Date Created:  05 Dec 2015
* Version: 0.4   
*/
trigger CRM_OrderProduct on OrderItem (before Insert,after insert,after update,after delete,before update, before delete) {

    //List<User> runningUser = [SELECT ByPassValidationRule__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }
    System.debug('#### User allowed to run through the trigger');

    if(Trigger.isBefore && Trigger.isInsert) {
        // Null the unique order item code, so that it can be saved when order is cloned with products as well
        for(OrderItem oi : trigger.new) {
            oi.Unique_Product_ID__c = null;
        }
          
        CRM_OrderProductSequenceController.executeBeforeInsert(trigger.new);
        System.debug('Sequence Controller executed ---'); 
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        //CRM_OrderProductSequenceController.executeBeforeUpdate(trigger.oldMap, trigger.newMap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
     	CRM_OrderProductSequenceController.executeBeforeDelete(trigger.old);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {

    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
       
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {
        
    }
}