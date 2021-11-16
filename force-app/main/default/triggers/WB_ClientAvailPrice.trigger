trigger WB_ClientAvailPrice on Client_Avail_Price__c (before insert,before update,after insert,after update,before delete,after delete) {
    
    //Add logic to skip trigger.
    
    WB_ClientAvailPriceHandler clientAvailPriceHandler = new WB_ClientAvailPriceHandler();
    WB_PBEP_Product_CreationHandler pbepHandler = new WB_PBEP_Product_CreationHandler();
    
    
    Id userId = UserInfo.getUserId();
    ByPassAutomationRules__c byPass = ByPassAutomationRules__c.getInstance(userId);
    
    if(byPass != NULL && byPass.Active__c)
        return;
    
    if(Trigger.isInsert)
    {
        //Stop recursive call.
        if(WB_ClientAvailPriceHandler.recursiveInsert) return;
        
        if(Trigger.isBefore){
            clientAvailPriceHandler.populatePrice(WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(Trigger.new));
            clientAvailPriceHandler.validateTempCAP(WB_ClientAvailTempPriceHandler.getTempPriceRecords(Trigger.new),null,WB_PriceUtility.INSERT_OP);
            
            WB_ClientAvailTempPriceHandler.validateTempPrice(Trigger.new,WB_PriceUtility.INSERT_OP);
      clientAvailPriceHandler.populateAccountingCategory(Trigger.new);    //SC to SFS change
            clientAvailPriceHandler.roundPricingtwoDigit(Trigger.new);
        
        }else if(Trigger.isAfter){
            //Set recursive falg. 
            WB_ClientAvailPriceHandler.recursiveInsert = true;
            Map<Id,Client_Avail_Price__c> permPriceNewMap = WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(Trigger.newMap);
            clientAvailPriceHandler.calculateExpiryDates(permPriceNewMap,WB_PriceUtility.INSERT_OP);
            WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(Trigger.new,new Map<Id,Client_Avail_Price__c>(),WB_PriceUtility.INSERT_OP);
            WB_ClientAvailPriceHandler.updateCatalogCAPRequiredOnCA(Trigger.new,Null,'Insert');
            WB_ClientAvailPriceHandler.recursiveInsert = false;
            
            //if(!WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS)
            //pbepHandler.insertOrUpdatePriceBookEntryPeriod(permPriceNewMap.values());
            
        }
        
    }else if(Trigger.isUpdate){ 
        //Stop recursive call.
        if(WB_ClientAvailPriceHandler.recursiveUpdate || WB_ClientAvailPriceHandler.recursiveInsert || WB_ClientAvailPriceHandler.recursiveDelete || WB_ClientAvailPriceHandler.isCADateChange) return;
        
        Map<Id,Client_Avail_Price__c> permPriceNewMap = WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(Trigger.newMap);
        if(Trigger.isBefore){
            //populate Pricing__c if there is change in Price Fields.
            clientAvailPriceHandler.updatePrice(permPriceNewMap,WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(Trigger.oldMap));
            clientAvailPriceHandler.validateTempCAP(WB_ClientAvailTempPriceHandler.getTempPriceRecords(Trigger.new),Trigger.oldMap,WB_PriceUtility.UPDATE_OP);
            WB_ClientAvailTempPriceHandler.validateTempPrice(Trigger.new,WB_PriceUtility.UPDATE_OP);
      clientAvailPriceHandler.updatePushToSFS(Trigger.new,Trigger.oldMap);                 //SC to SFS change
            clientAvailPriceHandler.roundPricingtwoDigit(Trigger.new);
        }else if(Trigger.isAfter){
            //Set recursive falg.
            WB_ClientAvailPriceHandler.recursiveUpdate = true;
            clientAvailPriceHandler.calculateExpiryDates(permPriceNewMap,WB_PriceUtility.UPDATE_OP,WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(Trigger.oldMap));
            WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(Trigger.new,Trigger.oldMap,WB_PriceUtility.UPDATE_OP);
            WB_ClientAvailPriceHandler.updateCatalogCAPRequiredOnCA(Trigger.new,Trigger.oldMap,'Update');
            WB_ClientAvailPriceHandler.recursiveUpdate = false;
            
            //if(!WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS)
            //pbepHandler.insertOrUpdatePriceBookEntryPeriod(permPriceNewMap.values());
            
        }
    }else if(Trigger.isDelete){
        //Stop recursive call.
        if(WB_ClientAvailPriceHandler.recursiveUpdate || WB_ClientAvailPriceHandler.recursiveInsert || WB_ClientAvailPriceHandler.recursiveDelete || WB_ClientAvailPriceHandler.isCADateChange) return;
        
        Map<Id,Client_Avail_Price__c> permPriceOldMap = WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(Trigger.oldMap);
        
        if(Trigger.isBefore){
            
            clientAvailPriceHandler.validateCAPDelete(permPriceOldMap);
            
            WB_ClientAvailTempPriceHandler.validateTempPrice(Trigger.old,WB_PriceUtility.DELETE_OP);
        }else if(Trigger.isAfter){ 
            //Set recursive falg.
            WB_ClientAvailPriceHandler.recursiveDelete = true;
            clientAvailPriceHandler.calculateExpiryDates(permPriceOldMap,WB_PriceUtility.DELETE_OP,permPriceOldMap);
            WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(Trigger.old,Trigger.oldMap,WB_PriceUtility.DELETE_OP);
            WB_ClientAvailPriceHandler.updateCatalogCAPRequiredOnCA(Trigger.old,Null,'Delete');
            WB_ClientAvailPriceHandler.recursiveDelete = false;
            
            //if(!WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS)
            //pbepHandler.insertOrUpdatePriceBookEntryPeriod(permPriceOldMap.values());
            
        }
    }
    
}