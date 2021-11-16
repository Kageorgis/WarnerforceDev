trigger WB_PromotionTitleTrigger on Promotion_Title__c (after insert,after delete) {

    if(Trigger.isAfter){
        Set<Id> promotionIds = new Set<Id>();
        if(Trigger.isInsert){
            for(Promotion_Title__c obj : Trigger.new){
                promotionIds.add(obj.PromotionID__c);
            }
        }
        if(Trigger.isDelete){
            for(Promotion_Title__c obj : Trigger.old){
                promotionIds.add(obj.PromotionID__c);
            }
        }
        if(!promotionIds.isEmpty()){
            WB_PromotionTriggerHandler.updatePromotionOwner(promotionIds);
        }
    }
}