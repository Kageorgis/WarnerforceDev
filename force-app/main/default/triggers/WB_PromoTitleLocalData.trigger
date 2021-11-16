trigger WB_PromoTitleLocalData on Promotion_Title__c (before insert,before update) {

   if(Trigger.isInsert  && Trigger.isBefore){
         system.debug('Trigger.new  --->> ' + Trigger.new);
         WB_TriggerHandlerPromoTitleLocalData.storeLocalDataWithPromotionTitle(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        WB_TriggerHandlerPromoTitleLocalData.storeLocalDataWithPromotionTitle(Trigger.new);
        
        WB_TriggerPromitiontitlechanelformat_chk.beforeupdatepromotiontitle(); // Added on 29 Jan
    }
    
    
}