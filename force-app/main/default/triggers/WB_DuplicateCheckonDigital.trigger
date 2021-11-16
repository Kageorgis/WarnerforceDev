/******* 
WB_DuplicateCheckonDigital
Creation Date- 19 Nov 2014
Description- This trigger to call the WB_TriggerHandlerECPieces trigger handler to 
             update the MPM field value on EC Piece object when any insert or update happens.
Author- Harika Bondalapati
*******/
trigger WB_DuplicateCheckonDigital on EC_Account_Allocation__c(before insert,before update) {
 
  if(Trigger.isInsert  && Trigger.isBefore){
         system.debug('Trigger.new  --->> ' + Trigger.new);
         WB_TriggerHandlerDigitalAllocation.checkDigitalDuplicates(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        WB_TriggerHandlerDigitalAllocation.checkDigitalDuplicates(Trigger.new);
    }
}