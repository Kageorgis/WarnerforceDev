public class ScriptForCollection implements Database.Batchable<sObject>,Database.Stateful{
    
    /*
        Database.executebatch(new ScriptForCollection(),10);
    */
    
    public Map<Id,List<Title__c>> collectiontitleMap = new Map<Id,List<Title__c>>();
    public List<Title__c> collectionList = new List<Title__c>();
    public set<Id> setIds = new set<Id>();
  
    public Database.QueryLocator start(Database.BatchableContext BC){   
        // get all titles where component  titles should not be null
        String query;   
        for(Title__c title : [Select Id,Collection_Title__c from Title__c where Collection_Title__c != null]){
            if(!collectiontitleMap.containskey(title.Collection_Title__c))
                collectiontitleMap.put(title.Collection_Title__c,new List<Title__c>());
            collectiontitleMap.get(title.Collection_Title__c).add(title);
        }
        setIds = collectiontitleMap.keyset();
        query = 'Select Id,Name,Content_Type__C from Title__c where id in: setIds and Content_type__c like \'%Collection%\'';
        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Title__c> scope){
        system.debug(LoggingLevel.Info ,'*******scope*********'+scope);
        Map<Id,Playlist__c> mapPlaylist = new Map<Id,Playlist__c>();
        List<Playlist_Content__c> playlistContentList = new List<Playlist_Content__c>();
        Map<Id,List<Local_Title__c>> collectionLocaltitlesMap = new Map<Id,List<Local_Title__c>>();
        List<Local_Title__c> localTitleUpdateList = new List<Local_Title__c>();
        
        for(Local_Title__c localTitle : [Select id,Title__c from Local_Title__c where Title__c in: scope]){
            if(!collectionLocaltitlesMap.containskey(localTitle.Title__c))
                collectionLocaltitlesMap.put(localTitle.Title__c, new List<Local_Title__c>());
            collectionLocaltitlesMap.get(localTitle.Title__c).add(localTitle);
        }
        
        for(Title__c cTitle : scope){
            Playlist__c playlist = new Playlist__c();
            playlist.name = 'Standard';
            playlist.Playlist_Status__c = 'Active';
            playlist.Playlist_Type__c = cTitle.Content_Type__C;
            playlist.Parent_Title__c = cTitle.id;
            playlist.Version_Number__c = 1;
            mapPlaylist.put(cTitle.id,playlist);
        }
        
        insert mapPlaylist.values();
        
        for(Id cTitleId : mapPlaylist.keyset()){
            Integer count=1;
            for(Title__c title : collectiontitleMap.get(cTitleId))
            {
                Playlist_Content__c content = new Playlist_Content__c();
                content.Content_Sequence__c = count++;
                content.Content_Status__c='Actice';
                content.Content_Title__c=title.id;
                content.Playlist__c = mapPlaylist.get(cTitleId).id;
                playlistContentList.add(content);
            }
            if(collectionLocaltitlesMap != null){
                for(Local_Title__c localTitle : collectionLocaltitlesMap.get(cTitleId)){
                    localTitle.Playlist__c = mapPlaylist.get(cTitleId).id;
                    localTitleUpdateList.add(localTitle);
                }
            }
        }
        
        Insert playlistContentList;
        update localTitleUpdateList;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}