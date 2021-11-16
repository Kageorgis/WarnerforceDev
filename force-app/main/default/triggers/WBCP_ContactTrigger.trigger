trigger WBCP_ContactTrigger on Contact (before insert,before update,after insert,after update,after delete) {
    
    if(WBCP_ContactTriggerHandler.recursiveUpdate)
        return;
    
    if(Trigger.isBefore){
        
        if(Trigger.isInsert){
            WBCP_ContactTriggerHandler.populateRegionValue(Trigger.new,Null,'Insert');
        }
        
        if(Trigger.isUpdate){
             WBCP_ContactTriggerHandler.populateRegionValue(Trigger.new,Trigger.oldMap,'Update');
        }
        
    }
    
   if(Trigger.isAfter){
       
       if(Trigger.isInsert){
           WBCP_ContactTriggerHandler.updateAccountTerritoryRegions(Trigger.new,Null,'Insert');
       }
       if(Trigger.isUpdate){
            WBCP_ContactTriggerHandler.updateAccountTerritoryRegions(Trigger.new,Trigger.oldMap,'Update');
       }
       if(Trigger.isDelete){
            WBCP_ContactTriggerHandler.updateAccountTerritoryRegions(Null,Trigger.oldMap,'Delete');
       }
       
    }
}