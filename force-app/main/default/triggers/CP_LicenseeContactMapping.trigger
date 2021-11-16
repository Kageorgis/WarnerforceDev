trigger CP_LicenseeContactMapping on CP_Licensee_Contact_Mapping__c (before insert,before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        CP_ContactMappingSequenceController.executeBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        CP_ContactMappingSequenceController.executeBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
}