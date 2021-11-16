/******* 
WB_DuplicateCheckonPhysical
Creation Date- 19 Nov 2014
Description- This trigger to call the WB_TriggerHandlerECPieces trigger handler to 
             update the MPM field value on EC Piece object when any insert or update happens.
Author- Harika Bondalapati
*******/
trigger WB_DuplicateCheckonPhysical on EC_Title_Allocation__c(before insert,before update) {
 
  if(Trigger.isInsert  && Trigger.isBefore){
         system.debug('Trigger.new  --->> ' + Trigger.new);
         WB_TriggerHandlerPhysicalAllocation.checkPhysicalDuplicates(Trigger.new,true);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        WB_TriggerHandlerPhysicalAllocation.checkPhysicalDuplicates(Trigger.new,false);
    }
}