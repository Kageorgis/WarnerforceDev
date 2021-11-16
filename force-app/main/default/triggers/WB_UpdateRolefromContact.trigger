/******* 
WB_UpdateRolefromContact 
Creation Date- 19 Feb 2015
Description- This trigger to call the WB_TriggerHandlerContactAssignment trigger handler to 
             update the Role field value on Contact Role object when any insert or update happens.
Author- Harika Bondalapati
*******/
trigger WB_UpdateRolefromContact on Contact_Assignment__c(before insert,before update) {
 
  if(Trigger.isInsert  && Trigger.isBefore){
         system.debug('Trigger.new  --->> ' + Trigger.new);
         WB_TriggerHandlerContactAssignment.updateRole(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        WB_TriggerHandlerContactAssignment.updateRole(Trigger.new);
    }
}