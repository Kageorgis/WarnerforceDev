/*******************************************************************************************************************************************
* File Name     :   WB_ClientAvailDateOverlap
* Description   :   Trigger to check date overlap on client avail
* author       :   Rashmi Singh
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4 Sep.2014        Rashmi Singh        Created class
*                                               
********************************************************************************************************************************************/


trigger  WB_ClientAvailDateOverlap  on Client_Avail__c (before update,before delete, before insert) {
    
    system.debug('Inside trigger --------'); 
    if(Trigger.isUpdate && Trigger.isBefore){
        
        //first update Local Title field with Local Title 
        for(Client_Avail__c c:Trigger.New) {
            if(c.Parent_Client_Avail__c == null)
                c.Local_Title__c=c.LocalTitleId__c;
        }
        //WB_TriggerHandlerDateOverlapClientAvail.dateOverlapBeforeupdate();
        WB_TriggerHandlerDateOverlapClientAvail.RecalculatePlaylistFlagBeforeUpdate(trigger.new);  // ER-10 CAS2EXT
        WB_StorefrontAssociateClientAvail.storefrontAssociateWithClientAvailBeforeUpdate();
        //WB_ChangedFieldsIdentifierClass.checkForClientAvails(); commented by Imran on 6 march
        WB_ClientAvailsDateCheckHandler.updatePricing(trigger.new, trigger.oldMap);  //ER-476
        WB_UpdateChangesForReport.updateLastRunChange(trigger.new, trigger.oldMap);       //CTS - APO
       
    } 
    
    if(Trigger.isInsert && Trigger.isBefore){
        
        //first update Local Title field with Local Title 
        for(Client_Avail__c c:Trigger.New) {
            if(c.Parent_Client_Avail__c == null) // Added condition for ER:10
                c.Local_Title__c=c.LocalTitleId__c;
        }     
        WB_TriggerHandlerDateOverlapClientAvail.dateOverlapBeforeinsert();
        WB_StorefrontAssociateClientAvail.storefrontAssociateWithClientAvailBefore();
        WB_TriggerHandlerDateOverlapClientAvail.RecalculatePlaylistFlagBeforeInsert(trigger.new);  // ER-10 CAS2EXT;
        WB_ClientAvailsDateCheckHandler.checkDatesValidation(trigger.new);   // CTS - Bundle(ER-65)
        WB_ClientAvailsDateCheckHandler.updatePricing(trigger.new, trigger.oldMap);  //ER-476
        WB_StorefrontAssociateClientAvail.PopulateECAvailField(trigger.new);                  //CTS - ECLM
    }
    
    // Added by shalini to allow Client Avail deletion before it is announced
    if(Trigger.isDelete && Trigger.isBefore){
        List<Client_Avail__c> clientAvailsLst = Trigger.old;    
        WB_TriggerHandlerDateOverlapClientAvail.deleteClientAvail(clientAvailsLst);
        system.debug('exit from before Delete');
    }
    
    
}