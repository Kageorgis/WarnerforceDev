trigger CP_FlowThroughDates on Flow_Through_Dates__c (before insert,before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        CP_FlowThroughDatesSequenceController.executeBeforeInsert(Trigger.new);
    } 
    if(Trigger.isBefore && Trigger.isUpdate){
        CP_FlowThroughDatesSequenceController.executeBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}