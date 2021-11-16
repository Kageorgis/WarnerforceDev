/*******************************************************************************************************************************************
* File Name     :   WB_LocalTitleTrigger
* Description   :   Trigger on Local Data object.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     17 Dec.2015        CTS                ER-000008 : Created the class.
*                                               Trigger to update the 'Changes' field on Client Avail when some fields gets updated on Local Data object.
*                                               ER-473 
* 2.0     28 March 2016      CTS                Trigger to update the 'Changes' field on Title when 'Key Dates' section fields gets updates in Local data object.
********************************************************************************************************************************************/


trigger WB_LocalTitleTrigger on Local_Title__c (after insert, after update, after delete,before insert,before update) {
    
    if(WB_LocalTitleTriggerHandler.recursiveUpdate){
        return;
    }
    
    if(trigger.newMap != null){
        if(UserInfo.getName()==Label.SFDC_Integration_User){
            if(WB_LocalTitleTriggerHandler.processedRecIds.containsAll(trigger.newMap.keySet())){
                return;
            }
        }
    }
    
    WB_LocalTitleTriggerHandler WB_LocalTitleTriggerHandlerInstance = new WB_LocalTitleTriggerHandler();

    //SINC1435031 
    //Added On - 1/17/2018
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate)
            WB_LocalTitleTriggerHandlerInstance.updateisReleaseDatesChangedFlag(trigger.new);
        
        if(trigger.isInsert){
            WB_LocalTitleTriggerHandlerInstance.populateLocalTitleStatus(trigger.new);
        }
        
        if(trigger.isUpdate){ 
            WB_LocalTitleTriggerHandlerInstance.validatePriceCode(trigger.newMap, trigger.oldMap);
            WB_LocalTitleTriggerHandlerInstance.validateLocalTitleLongDescriptionUpdate(trigger.newMap, trigger.oldMap);
        }    
    }
    
    if(trigger.isInsert && trigger.isAfter) {
        //WB_UpdateChangesForReport.updateChangesByCountry(trigger.new, trigger.oldMap);
        //ER-473 Start
        WB_LocalTitleTriggerHandlerInstance.OnInsert(trigger.new);
        WB_LocalTitleTriggerHandlerInstance.changePlaylistValueInRPs(trigger.new,'Insert'); // ER-10 : Playlist  CAS2EXT
        
        //ER-003244 - IN8055 data load to Local_Title__c failed in production-Apex CPU time limit exc   
        if(UserInfo.getName()==Label.SFDC_Integration_User){
            WB_LocalTitleTriggerHandler.processedRecIds = new Set<Id>(trigger.newMap.keySet());
    	}
    
    }

    if(trigger.isUpdate && trigger.isAfter) {
        WB_UpdateChangesForReport.updateChangesByLocalData(trigger.new, trigger.oldMap);
        WB_LocalTitleTriggerHandlerInstance.OnUpdate(trigger.new, trigger.oldMap);
        WB_LocalTitleTriggerHandlerInstance.resetClientAvailFlag(trigger.new);   // ER-10 : Playlist  CAS2EXT
        WB_LocalTitleTriggerHandlerInstance.changePlaylistValueInRPs(trigger.new,'Update'); // ER-10 : Playlist  CAS2EXT
        
        //ER-003244 - IN8055 data load to Local_Title__c failed in production-Apex CPU time limit exc   
        if(UserInfo.getName()==Label.SFDC_Integration_User){
            WB_LocalTitleTriggerHandler.processedRecIds = new Set<Id>(trigger.newMap.keySet());
    	}
    }
    
    //ER-473 End
        
    
}