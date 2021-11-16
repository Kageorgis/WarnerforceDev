trigger WB_OnRightsCreateUpdate on Rights__c (before Insert, before Update, After Undelete, before Delete) {
    if((trigger.isBefore && (trigger.isInsert || trigger.isUpdate))){    
        //Added method setMarketRegionTerritory() under ER-000862  Add Region, Market Group & WB Territory to Rights Object
        //Description: Copy Region, market Group & WB Territory values form locale to rights objects
        WB_RightsTriggerHandler.setMarketRegionTerritory(trigger.new);
        
        WB_RightsTriggerHandler.validateRightsAndSetQueueAsOwner(trigger.new);          
    }
    else if(trigger.isAfter && trigger.isUndelete){
        List<Rights__c> lstUndelRyts = new List<Rights__c>([Select Id FROM Rights__c WHERE Id IN: trigger.new]);
        Database.SaveResult[] srList = Database.update(lstUndelRyts, false);
    }
    //Added under ER-004371  Remove Deletion Permissions for WB Legal Profile on Rights Object
    //Description: Restrict profiles other than Admin & Support profiles from deleting Rights object.
    else if(trigger.isBefore && trigger.isDelete){        
        WB_RightsTriggerHandler.restrictDeletionOfRightsRecords(trigger.Old);
    }
}