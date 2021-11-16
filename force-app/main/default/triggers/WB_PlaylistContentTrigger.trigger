trigger WB_PlaylistContentTrigger on Playlist_Content__c (after insert,after update,after delete) {
    WB_PlaylistContentTriggerHandler playlistContentHandler = new WB_PlaylistContentTriggerHandler();
    List<Playlist_Content__c> lstUpdatedPC = new List<Playlist_Content__c>();
    if(trigger.isAfter){
        if(trigger.isInsert) {
            playlistContentHandler.updatePlaylistALID(Trigger.New);
        }  
        
        if(trigger.isUpdate) {
            playlistContentHandler.updatePlaylistALID(trigger.new);
        }
         if(trigger.isDelete){
            playlistContentHandler.updatePlaylistALID(Trigger.Old);
        }
    }
    
}