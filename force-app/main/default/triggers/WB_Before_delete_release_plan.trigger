trigger WB_Before_delete_release_plan on Commercial_Avail__c (before delete) {

if(Trigger.isDelete){

WB_Before_delete_release_plan_Controller.beforedelete_releaseplan();

}

}