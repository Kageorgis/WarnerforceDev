/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers on delete of country plan target
   * Date Created:  04 Apil 2016
   * Version: 0.1 
   */
trigger CRM_CountryPlanTarget on Country_Plan_Target__c(before Insert,after insert,after update,after delete,before update, before delete) {

    /*if(Trigger.isBefore && Trigger.isInsert) {  
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
    }
    */
    //US842 start    
    
     if(Trigger.isBefore && Trigger.isInsert) {
        CRM_CountryPlanTargetSequenceController.executeBeforeInsert(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        CRM_CountryPlanTargetSequenceController.executeBeforeUpdate(Trigger.New);
    }
    
    //US842 ENDS:
    if(Trigger.isBefore && Trigger.isDelete) {
        CRM_CountryPlanTargetSequenceController.executeBeforeDelete(trigger.old);
        //system.debug('trigger.old'+trigger.old);
    } 

}