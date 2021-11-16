trigger DPT_PromitionCurrencychk on Promotion__c (before insert,before update,after update) {
/*Commented By- Suraj Thakur, doesn't need in this functionality
If(Trigger.isUpdate){
    
    DPT_TriggerPromitionCurrencychk.beforeupdatepromotion();
    DPT_TriggerHandlerPromoOwner.CheckPromoOwnerBeforeUpdate();
    DPT_TriggerHandlerPromoCreation.CheckPromoCreatBeforeUpdate();
    

}

If(Trigger.isInsert){
    
    DPT_TriggerPromitionCurrencychk.beforeinsertpromotion();
    DPT_TriggerHandlerPromoOwner.CheckPromoOwnerBeforeInsert();
    DPT_TriggerHandlerPromoCreation.CheckPromoCreatBeforeInsert();
    

}

if(Trigger.isAfter){
    WB_PromoTitle_TempCapCreation.createTempCAP(Trigger.new);
}
*/
}