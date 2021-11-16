public with sharing class WB_ExportPlaylistContentController {

    public List<PlaylistExcelWrapper> listPlaylistContents{get; set;}
    public String header{get; set;}
    public String nextLine {get; set;}
    
    public PageReference exportToExcel() {
        List<String> playlistIds = ApexPages.currentpage().getParameters().get('pl').split(',');
        header = 'Title Name\tVideo Version Number\tSequence Number';
        listPlaylistContents = new List<PlaylistExcelWrapper>();
        nextLine = '\r\n';
        for(String plId : playlistIds)
             listPlaylistContents.add(new PlaylistExcelWrapper(plId));
        return null;
    }
    
    public class PlaylistExcelWrapper
    {
        public String PlaylistName{get; set;}
        public Integer count{get; set;}
        public String PlaylistId{get; set;}
        public List<PlaylistContentExcelWrapper> listPlaylistContent{get; set;}
        public PlaylistExcelWrapper(String pid)
        {
            listPlaylistContent = new List<PlaylistContentExcelWrapper>();
            count=0;
            for(Playlist_Content__c cont : [SELECT id,name,Content_Title__r.name,Content_VV__c,Playlist__c,Playlist__r.name,Content_Sequence__c 
                                            FROM Playlist_Content__c 
                                            WHERE Playlist__c =: pid 
                                            ORDER BY Content_Sequence__c])
            {
                if(count == 0)
                {
                    PlaylistName = cont.Playlist__r.name;
                    PlaylistId = cont.Playlist__c;
                    count++;
                }
                listPlaylistContent.add(new PlaylistContentExcelWrapper(cont));
            }
            
        }
    }
    
    public class PlaylistContentExcelWrapper
    {
        public String titleName{get; set;}
        public String videoVersionNumber{get; set;}
        public Decimal sequenceNumber{get; set;}
        public PlaylistContentExcelWrapper(Playlist_Content__c cont)
        {
            titleName = cont.Content_Title__r.name+'\t';
            videoVersionNumber = cont.Content_VV__c+'\t';
            sequenceNumber = cont.Content_Sequence__c;
        }
    }

}