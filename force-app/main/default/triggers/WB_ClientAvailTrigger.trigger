trigger WB_ClientAvailTrigger on Client_Avail__c (before Insert, before Update, after Insert, after Update, before delete, after delete) 
{
    if(WB_ClientAvailPriceHandler.recursiveUpdate || WB_ClientAvailPriceHandler.recursiveInsert || WB_ClientAvailPriceHandler.recursiveDelete || WB_ClientAvailPriceHandler.isCADateChange){
        /*if(Trigger.isAfter && Trigger.isUpdate){
            CRM_ClientAvailHandler handlerInstance = new CRM_ClientAvailHandler();
            handlerInstance.updatePBEPDates(trigger.oldMap, trigger.newMap);
        }*/
       return;
    }
       
    if(trigger.isInsert)
    {
        if(trigger.isBefore)
        {
            //system.debug('before assignowner****');
            WB_TriggerHandlerDateOverlapClientAvail.assignOwner(Trigger.new);                                      //Replaced Workflows with trigger logic for owner assignment
            //first update Local Title field with Local Title 
            /*for(Client_Avail__c c:Trigger.New) 
            {
                if(c.Parent_Client_Avail__c == null)                                                    // Added condition for ER:10
                    c.Local_Title__c=c.LocalTitleId__c;
            }*/
            WB_TriggerHandlerDateOverlapClientAvail.dateOverlapBeforeinsert();
            WB_TriggerHandlerDateOverlapClientAvail.RecalculatePlaylistFlagBeforeInsert(trigger.new);   // ER-10 CAS2EXT;
            WB_StorefrontAssociateClientAvail.storefrontAssociateWithClientAvailBefore();
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(trigger.new);                          // CTS - Bundle(ER-65)
            WB_ClientAvailsDateCheckHandler.updatePricing(trigger.new, trigger.oldMap);                 //ER-476
            WB_StorefrontAssociateClientAvail.PopulateECAvailField(trigger.new);                        //CTS - ECLM
            WB_TriggerHandlerDateOverlapClientAvail.CalculateAPODate(trigger.new, trigger.oldMap);      //ER-820 - Post Implementation Changes 
            
            WB_ClientAvailPriceHandler clientAvailPriceHandler = new WB_ClientAvailPriceHandler();
            clientAvailPriceHandler.populatePriceFieldsOnCA(trigger.new);

            WB_TriggerHandlerDateOverlapClientAvail.roundPricingtwoDigit(trigger.new);
        }
         
        if(trigger.isAfter)
        {
            //WB_TriggerHandlerCountClientAvail.validatePriceTiersOnInsert();                             // CH01: ER-15 Price Tier validation perform.
            WB_TriggerHandlerCountClientAvail.CountClientAvail();
            
            //CRM_ClientAvailHandler handlerInstance = new CRM_ClientAvailHandler();
            //handlerInstance.updateComercialAvail(trigger.newMap);
            
            WB_ClientAvailPriceHandler clientAvailPriceHandler = new WB_ClientAvailPriceHandler();
            clientAvailPriceHandler.createClientAvailPrice(trigger.new);
        }
    }
    
    if(trigger.isUpdate)
    {
        if(trigger.isBefore)
        {
            //system.debug('trigger.new*********in Trigger'+trigger.new);
            List<Client_Avail__c> newAvails = new List<Client_Avail__c>();
            List<Client_Avail__c> oldAvails = new List<Client_Avail__c>();
            // CH01: If value of Price Tier changes then assign null to Validation Failure
            for(Client_Avail__c clientAvail : trigger.new)
            {
                Client_Avail__c oldClientAvail = (Client_Avail__c)Trigger.oldMap.get(clientAvail.id);
                if(clientAvail.Price_Tier_Text__c != oldClientAvail.Price_Tier_Text__c)
                    clientAvail.Validation_Failures__c = null;
            }
            //first update Local Title field with Local Title 
            for(Client_Avail__c c:Trigger.New) 
            {
                Client_Avail__c oldAvail = trigger.oldMap.get(c.Id);
                if(c.Parent_Client_Avail__c == null)
                    c.Local_Title__c=c.LocalTitleId__c;
                if(c.Local_Title__c != oldAvail.Local_Title__c || c.Commercial_Avail__c != oldAvail.Commercial_Avail__c || c.Client__c != oldAvail.Client__c
                || c.Start_Date__c != oldAvail.Start_Date__c || c.End_Date__c != oldAvail.End_Date__c || c.RP_Synch__c != oldAvail.RP_Synch__c){
                    newAvails.add(c);
                    oldAvails.add(oldAvail);
                }
                
            }
            //system.debug('newAvails******'+newAvails.size());
            if(newAvails != NULL && newAvails.size() > 0)//
            WB_TriggerHandlerDateOverlapClientAvail.dateOverlapBeforeupdate(newAvails,oldAvails);
            WB_TriggerHandlerDateOverlapClientAvail.ChangeEpisodeCAFields(trigger.new,trigger.newMap);  // ER-10 CAS2EXT  //ER-820: Moved From After To Before Update
            WB_TriggerHandlerDateOverlapClientAvail.RecalculatePlaylistFlagBeforeUpdate(trigger.new);   // ER-10 CAS2EXT
            WB_StorefrontAssociateClientAvail.storefrontAssociateWithClientAvailBeforeUpdate();
            //Commented Method call - SINC1557841
            //WB_ClientAvailsDateCheckHandler.updatePricing(trigger.new, trigger.oldMap);                 //ER-476
            WB_UpdateChangesForReport.updateLastRunChange(trigger.new, trigger.oldMap);                 //CTS - APO
            WB_TriggerHandlerDateOverlapClientAvail.CalculateAPODate(trigger.new, trigger.oldMap);      //ER-820 - Post Implementation Changes  
            WB_TriggerHandlerCountClientAvail.assignRateCardBeforeUpdate();
        }
        
        if(trigger.isAfter)
        {
            
            List<Client_Avail__c> newAvails = new List<Client_Avail__c>();
                
            WB_TriggerHandlerCountClientAvail.validatePriceTiersOnUpdate();   
            WB_TriggerHandlerCountClientAvail.updateIsCAChangedFlagOnRP(); //MDR - Updated on 26 April'17 
            // CH01: ER-15 Price Tier validation perform.
            //CRM- updae dates in PBEP on update of CA Dates
            //system.debug('****in handlerInstance');
            
            //CRM_ClientAvailHandler handlerInstance = new CRM_ClientAvailHandler();
            //handlerInstance.updatePBEPDates(trigger.oldMap, trigger.newMap);
            
            WB_ClientAvailPriceHandler clientAvailPriceHandler = new WB_ClientAvailPriceHandler();
            
            //clientAvailPriceHandler.createPreOrderClientAvailPrice(trigger.newMap,trigger.oldMap);
            clientAvailPriceHandler.updateClientAvailPriceStartEndDate(trigger.newMap,trigger.oldMap);
        }
    }
    
    if(trigger.isDelete)
    {
        if(trigger.isBefore)
        {
            List<Client_Avail__c> clientAvailsLst = Trigger.old;    
            WB_TriggerHandlerDateOverlapClientAvail.deleteClientAvail(clientAvailsLst);
            //system.debug('exit from before Delete');
           // WB_PBEP_Product_CreationHandler.deletePBEPRecord(clientAvailsLst);
        }
        
        if(trigger.isAfter)
        {
            WB_TriggerHandlerCountClientAvail.CountClientAvail();
        }
    }
        
    
}