/*******************************************************************************************************************************************
* File Name     :   WB_AccountTrigger
* Description   :   Trigger for Handler to check if any one of the storefront has APO flag set to Yes then only its Accounts APO flag can be set to Yes.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10 Dec.2015        CTS                ER-000008 : Created the class.
* 2.0       
********************************************************************************************************************************************/

trigger WB_AccountTrigger on Account (before insert, before update, after insert, after update) {

    if(trigger.isInsert && trigger.isBefore) {
        WB_checkAPOflagHandler.checkStoreFrontAPO(trigger.new);
        //CRM Enahancement (Update Physical Product Flag on Account)
        //Move 'CRM - Update Physical Product Flag' Worlflow fields update in trigger.
        CRM_AccountHandler.executeBeforeInsert(trigger.new);
        //WBCP_ParentChildLicenseeHandler.handleLicenseeInsert(Trigger.new,'Insert',Null);
    }

    if(trigger.isUpdate && trigger.isBefore) {
        WB_checkAPOflagHandler.checkStoreFrontAPO(trigger.new);
        //WBCP_ParentChildLicenseeHandler.handleLicenseeInsert(Trigger.new,'Update',Trigger.oldMap);
    }

    //CRM Enahancement (insert/update the account team memeber record)
    if(trigger.isInsert && trigger.isafter) {
        CRM_ProcessAccountTeamMembers.processTeamMembers(Trigger.oldMap, Trigger.newMap);
        //WBCP_ParentChildLicenseeHandler.updateLicenseeParentSchedule(Trigger.new);
    }

    if(trigger.isUpdate && trigger.isafter) {
        CRM_ProcessAccountTeamMembers.processTeamMembers(Trigger.oldMap, Trigger.newMap);
        //WBCP_ParentChildLicenseeHandler.updateLicenseeParentSchedule(Trigger.new);
        WBCP_AccountTriggerHandler.shareAccountRecords(Trigger.new,Trigger.oldMap,Null,CP_ProductUtility.WBCP_TRIGGER);
    }

}