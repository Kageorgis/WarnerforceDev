trigger CP_Property on Property__c (before insert,before update) {   
    if(Trigger.isBefore && Trigger.isInsert){
        CP_PropertySequenceController.executeBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        CP_PropertySequenceController.executeBeforeUpdate(Trigger.new, Trigger.oldMap);
    }   
}