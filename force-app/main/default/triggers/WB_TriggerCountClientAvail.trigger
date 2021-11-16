/* =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                          Date                                  Comment
*  Prachi Gadewar                  28-7-2015                             CH01 : Calling two methods for ER-15 price tier validation.
*            
*  
*/
trigger  WB_TriggerCountClientAvail  on Client_Avail__c (after update,  after insert, after delete,before update) {

    if(Trigger.isUpdate){
        
        // CH01: If value of Price Tier changes then assign null to Validation Failure. 
        if(Trigger.isBefore)
        {
            for(Client_Avail__c clientAvail : trigger.new)
            {
                Client_Avail__c oldClientAvail = (Client_Avail__c)Trigger.oldMap.get(clientAvail.id);
                if(clientAvail.Price_Tier_Text__c != oldClientAvail.Price_Tier_Text__c)
                    clientAvail.Validation_Failures__c = null;
            }
        }
        // END
        if(Trigger.isAfter){
            //WB_TriggerHandlerCountClientAvail.CountClientAvail();
            // CH01: ER-15 Price Tier validation perform.
            WB_TriggerHandlerCountClientAvail.validatePriceTiersOnUpdate();
            //CRM- updae dates in PBEP on update of CA Dates
            system.debug('****in handlerInstance');
            CRM_ClientAvailHandler handlerInstance = new CRM_ClientAvailHandler();
            handlerInstance.updatePBEPDates(trigger.oldMap, trigger.newMap);
            //WB_TriggerHandlerDateOverlapClientAvail.ChangeEpisodeCAFields(trigger.new); // ER-10 CAS2EXT
        }
    }
    if(Trigger.isInsert){

        WB_TriggerHandlerCountClientAvail.CountClientAvail();
        // CH01: ER-15 Price Tier validation perform.
        WB_TriggerHandlerCountClientAvail.validatePriceTiersOnInsert();
        
        if(Trigger.isafter)
        {
        CRM_ClientAvailHandler handlerInstance = new CRM_ClientAvailHandler();
        handlerInstance.updateComercialAvail(trigger.newMap);
        }
    }
    if(Trigger.isDelete){

        WB_TriggerHandlerCountClientAvail.CountClientAvail();
    }
}