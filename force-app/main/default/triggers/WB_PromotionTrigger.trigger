trigger WB_PromotionTrigger on Promotion__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        WB_PromotionTriggerHandler.checkPromotion(Trigger.oldMap,Trigger.new);
    }
}