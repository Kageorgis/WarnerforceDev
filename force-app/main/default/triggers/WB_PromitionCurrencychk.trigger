trigger WB_PromitionCurrencychk on Promotion__c (before insert,before update) {

If(Trigger.isUpdate){

//WB_TriggerPromitionCurrencychk.beforeupdatepromotion();

}

If(Trigger.isInsert){

//WB_TriggerPromitionCurrencychk.beforeinsertpromotion();

}

}