/*******************************************************************************************************************************************
* File Name     :   MPMTalentTrigger 
* Description   :   trigger on MPM Talent.
* @author       :   CTS
* Modification Log
* Created Date  :   2/2/2018
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 
********************************************************************************************************************************************/
trigger MPMTalentTrigger on MPM_Talent__c (after insert, after update) {

    if((Trigger.isInsert ||Trigger.isUpdate)&& Trigger.isAfter){
        WB_MPMTalentTrigger_Handler handlerInstance = new WB_MPMTalentTrigger_Handler();
        handlerInstance.deleteMPMTalent(Trigger.new);
    }

}