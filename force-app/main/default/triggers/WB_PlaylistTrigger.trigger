trigger WB_PlaylistTrigger on Playlist__c (after Update) {
    
    WB_PlaylistTriggerHandler H = New WB_PlaylistTriggerHandler();
    if(trigger.isUpdate && trigger.isAfter)
    H.updateRelatedClientAvail(trigger.new);
   
}