/*******************************************************************************************************************************************
* File Name     :   TaskTrigger
* Description   :   
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4 Dec.2015        CTS                 ER-000399 : Created the class. Language Readiness - reassigned task owners to be remembered for future tasks
* 2.0                                       
********************************************************************************************************************************************/


trigger WB_TaskTrigger on Task (before insert, after update) {
    
    if(Trigger.isUpdate && Trigger.isAfter){    
        WB_UpdateTaskOwnerHandler.updateOwnerFields(trigger.new, trigger.oldMap);
    }
    
    if(Trigger.isInsert && Trigger.isBefore) {
        WB_UpdateTaskOwnerHandler.updateTaskOwner(trigger.new);
    }
}