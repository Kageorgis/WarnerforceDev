trigger WB_TVSalesHistoryTrigger on TV_Sales_History__c (before update,before insert) {
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        WB_TVSalesHistoryTriggerHandler.setQueueToOwner(Trigger.new);
    }
}