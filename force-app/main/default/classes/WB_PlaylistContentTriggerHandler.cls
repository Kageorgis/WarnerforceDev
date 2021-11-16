/*
created on - 25 September,2017
Created By - CAS Team
ER - 1524 Method returns Playlist with PlaylistALIDs field on Playlist with ; sepated string of Content Title's ALID */

public class WB_PlaylistContentTriggerHandler   {
    public List<Id> lstPlaylist = new List<Id>();
    public List<Playlist__c> finalPlaylistToUpdate = new List<Playlist__c>();
    public List<playlistContentWrapper> playlistContentWrapperLst = new List<playlistContentWrapper>();
	public Map<Id,List<playlistContentWrapper>> mapPlaylistWithPC = new Map<Id,List<playlistContentWrapper>>();
    
    //constructor
    public WB_PlaylistContentTriggerHandler(){}    
    
    /*Method updates PlaylistALIDs field on Playlist with ; sepated string of Content Title's ALID */
    public void updatePlaylistALID(List<Playlist_Content__c> lstPlaylistContent)  {

        
        for (Playlist_Content__c pc:lstPlaylistContent){
			    lstPlaylist.add(pc.Playlist__c);
        }
        List<Playlist_Content__c> lstPlaylistcontentResults = [Select Id,Content_Sequence__c,Playlist__c,Content_Title__r.ALID__c
		                                                       FROM Playlist_Content__c 
		                                                       WHERE Playlist__c IN: lstPlaylist];
		
		for (Playlist_Content__c ar : lstPlaylistcontentResults){
            if(!mapPlaylistWithPC.containsKey(ar.Playlist__c))
				mapPlaylistWithPC.put(ar.Playlist__c,new List<playlistContentWrapper>());
			    mapPlaylistWithPC.get(ar.playlist__c).add(new playlistContentWrapper (ar));
			
		}
        for(Id playlistId:mapPlaylistWithPC.keyset())
		{
			List<playlistContentWrapper> lstPC = mapPlaylistWithPC.get(playlistId);
			lstPC.sort();
			if(lstPC != NULL && lstPC.size() > 0){
				String key = '';
				for(playlistContentWrapper pc:lstPC){
					if(pc.playlistContentObj.Content_Title__r.ALID__c != NULL)
						key = key + ';' + pc.playlistContentObj.Content_Title__r.ALID__c;
				 }
				Key = key.removeStart(';').trim();
        	    Playlist__c playlistToUpdate = new Playlist__c(Id = playlistId,PlaylistALIDs__c = key);
			    finalPlaylistToUpdate.add(playlistToUpdate);
            }
		}
		if(finalPlaylistToUpdate!= NULL && finalPlaylistToUpdate.size()>0)
		    Database.update (finalPlaylistToUpdate,false);
	}
	public class playlistContentWrapper  implements Comparable{
        public Playlist_Content__c playlistContentObj;
        public playlistContentWrapper(){}
        public playlistContentWrapper(Playlist_Content__c pc){
           playlistContentObj = pc;
            
        }
        public Integer compareTo(Object ObjToCompare) {
        playlistContentWrapper compareToStud = (playlistContentWrapper)ObjToCompare;
        
        if (playlistContentObj.Content_Sequence__c == compareToStud.playlistContentObj.Content_Sequence__c) return 0;
        if (playlistContentObj.Content_Sequence__c > compareToStud.playlistContentObj.Content_Sequence__c) return 1;
        return -1;
    }    
    }

}