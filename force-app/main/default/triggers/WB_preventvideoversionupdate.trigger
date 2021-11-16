trigger WB_preventvideoversionupdate on Title__c (before insert,before update,after update) {
    
    if(trigger.isBefore && trigger.isUpdate){
        WB_PreventvideoversionUpdateController.updatevideoversion();
        for(Title__c objTitle : trigger.new) {                                    
            Title__c oldTitle = trigger.oldMap.get(objTitle.Id);
			if (objTitle.DisplayStudio__c != oldTitle.DisplayStudio__c) {
                objTitle.IsDisplayStudioUpdated__c=true;
            }
        }                                                                        
    }
    if(trigger.isAfter && trigger.IsUpdate){
        WB_PreventvideoversionUpdateController.setQueueToLocalDataOwner(trigger.new);
    }
}