trigger DPT_PromoTitleLocalData on Promotion_Title__c (before insert,before update) {
/*
Commented By- Suraj Thakur

   if(Trigger.isInsert  && Trigger.isBefore){
         system.debug('Trigger.new  --->> ' + Trigger.new);
         WB_TriggerHandlerPromoTitleLocalData.storeLocalDataWithPromotionTitle(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        WB_TriggerHandlerPromoTitleLocalData.storeLocalDataWithPromotionTitle(Trigger.new);        
        DPT_TriggerPromotionTtlechanelformat_chk.beforeupdatepromotiontitle(); // Added on 29 Jan
    }
    
 */   
}