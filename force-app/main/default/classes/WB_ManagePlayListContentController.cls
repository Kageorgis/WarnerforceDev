global with sharing class WB_ManagePlayListContentController {
    
    public String titlename { get; set; }   

    public String Playlistname { get; set; } 
    public String pageblockname{ get; set; }
    public Boolean showcontent{ get; set; }
    public Boolean showCompareContent{ get; set; }
    public Boolean showPlaylistTable{ get; set; }
    public Integer count{get; set;}
    public String selectedPlaylistIds{get;set;}
    
    public Boolean incorrectContentType{ get; set; }
    public Boolean DigitalPlanningChk{ get; set; } 
    public String titleid {get;set;}
    public List<Title__c> lstTitles{get;set;}
    public List<Playlist__c> lstPlaylists{get;set;}
    public Map<Id,PlaylistWrapper> mapPlaylistwrapper{get;set;}
    public List<Playlist__c> listPlaylistSorted{get; set;}
    public List<Playlist_Content__c> lstPlaylistcontent{get;set;}
    public String title = '';
    public String playListID = '';
    public id selectedplaylist{get; set;}
    public Boolean showAS{get; set;}
    public Boolean ProfileFlag{get; set;}
    public list<Title__c> titlelistAvaliable {get;set;}
    public String canCreate {get;set;}
    public Boolean isRecordOwner {get;set;}
    public String uTerritory {get;set;}
    
    
    public WB_ManagePlayListContentController(ApexPages.StandardController controller) {
        pageblockname = '';
        ProfileFlag = false;
        incorrectContentType = false;
        DigitalPlanningChk = false;
        isRecordOwner = false;
        //showcontent=false;
        showCompareContent=false;
        Title__c title = new Title__c();
        mapPlaylistwrapper = new Map<Id,PlaylistWrapper>();
        listPlaylistSorted = new List<Playlist__c>();
        
        /*-- User Details : START --*/
        
        User u =  [SELECT ID, Territory__c, profile.name FROM User WHERE ID =: UserInfo.getUserId()];
        uTerritory = u.Territory__c;
        /*-- User Details : ENDS --*/
        
        titleid = System.currentPagereference().getParameters().get('Id');
        if(titleid != null)
        {
            title = [Select id,name,Content_type__c, OwnerId, Digital_Planning__c, Clear_to_Avail__c from Title__c where id =: titleid limit 1];
            titlename = title.Name;
            if(title.Content_type__c != 'Season' && !title.Content_type__c.contains('Collection'))
                incorrectContentType = true;
            if(title.Digital_Planning__c != 'Yes' || title.Clear_to_Avail__c != TRUE)
                DigitalPlanningChk = true;
        }
        lstPlaylists = [Select id,name,Parent_Title__c,Parent_Title__r.name,Country__r.name,Version_Number__c,Playlist_Type__c,Playlist_Status__c,CreatedById,Territory__c from Playlist__c where Parent_Title__c=:titleid ORDER BY Version_Number__c ASC];
        
        if(lstPlaylists != null && lstPlaylists.size() > 0)
        {
            showPlaylistTable=true;
            for(Playlist__c playlist : lstPlaylists)
            {
                mapPlaylistwrapper.put(playlist.id,new PlaylistWrapper(playlist));
                //listPlaylistwrapper.add(new PlaylistWrapper(playlist));
                listPlaylistSorted.add(playlist);
                if(UserInfo.getUserId() == playlist.CreatedById){ 
                    
                }
            }
        }
        else
        {
            showPlaylistTable=false;
        }
        mapPlaylistwrapper.values().sort();
        User loggedinUser = [SELECT id,Name,Profile.Name,isGPPPermissionSetAssigned__c from User where id =: Userinfo.getuserid()];
        ProfileFlag = false;
        if(loggedinUser != null && ((loggedinUser.Profile.Name != Label.WB_Global_Title_Planner && loggedinUser.isGPPPermissionSetAssigned__c !=true) || loggedinUser.Profile.Name.contains('Admin')))
        {
            ProfileFlag = true;
        }
        
      /*-------------------------------------------*/
      if(titleid != '' && titleid != null){
       set<string> allUserTitle = getAllUser(title.OwnerId);
       if(allUserTitle.contains(UserInfo.getUserId()) || ProfileFlag == true){
           canCreate = 'Yes';
       }
       else{
           canCreate = 'No';    
       }
      }
       /*-------------------------------------------*/
        
    }
    
    
    public Pagereference FetchContent()
    {
        
        system.debug('selectedplaylist**********'+selectedplaylist);
        lstPlaylistcontent = [Select id,name,Content_Title__r.name,Content_Title__r.MPM__r.Name,Title_Name__c,Content_VV__c,Content_Sequence__c from Playlist_Content__c where Playlist__c =: selectedplaylist order by Content_Sequence__c];
        if(lstPlaylistcontent.size() > 0)
        {
            pageblockname = 'Playlist content of '+ Playlistname;
            showcontent=true;
        }
        else
            pageblockname = 'No playlist exist for '+ Playlistname + ' Title.';
        return null;
    }
    
    public PageReference ComparePlaylistContent() {
        showCompareContent=false;
        Set<Id> playlistSelected = new Set<Id>();
        selectedPlaylistIds = '';
        for(PlaylistWrapper pl : mapPlaylistwrapper.values())        
        {
            if(pl.isselected)
                selectedPlaylistIds += pl.playlist.id+',';   
            mapPlaylistwrapper.get(pl.playlist.id).listPlaylistContent = new List<Playlist_Content__c>();
            if(pl.isselected)
                playlistSelected.add(pl.playlist.id);
        }
        selectedPlaylistIds.removeEnd(',');
        if(playlistSelected.size() > 0 && playlistSelected.size() <= 3)
        {
            showCompareContent = true;
            count = playlistSelected.size();
            for(Playlist_Content__c plc : [Select id,name,Content_Title__r.name,Title_Name__c,Content_VV__c,Playlist__c,Playlist__r.name,Content_Sequence__c from Playlist_Content__c where Playlist__c in: playlistSelected order by Playlist__c,Content_Sequence__c])
            {
                mapPlaylistwrapper.get(plc.Playlist__c).pageblockname = 'Playlist content for ' + plc.Playlist__r.name;
                mapPlaylistwrapper.get(plc.Playlist__c).listPlaylistContent.add(plc);
            }
        }
        
        else if(playlistSelected.size() == 0)
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Select at least one Playlist to compare their content'));
        else if(playlistSelected.size() > 3)
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Users can compare up to three playlists'));
        return null;
    }
    
    public Pagereference CreateNewPlaylist()
    {
        Pagereference pref = new Pagereference('/apex/WB_playlistContentdetails?playList=&title='+titleid+'&mode=n');
        return pref;
    }
    
    global class PlaylistWrapper implements Comparable
    {
        public Playlist__c playlist{ get; set; }
        public Boolean isSelected{ get; set; }
        public String pageblockname{get; set;}
        public integer versionNumber;
        public List<Playlist_Content__c> listPlaylistContent{get; set;}
        public PlaylistWrapper(Playlist__c p)
        {
            playlist = p;
            isSelected = false;
            pageblockname = 'Playlist content records not available for '+p.name;
            listPlaylistContent = new List<Playlist_Content__c>();
            versionNumber = Integer.valueof(p.Version_number__c);
        }
        
        global Integer compareTo(Object objToCompare) {
         return Integer.valueOf(versionNumber - ((PlaylistWrapper)objToCompare).versionNumber);

    }
    }

    
     public set<String> getAllUser(String queueID){
       set<string> allUserList = New set<string>();
       list<string> groupids = new list<string>();
       list<GroupMember> userOrGroupID = [Select UserOrGroupId FROM GroupMember WHERE GroupId =: queueID];
       for(GroupMember GM : userOrGroupID){
           if(string.valueof(GM.UserOrGroupId).substring(0, 3) == '00G'){
             groupids.add(GM.UserOrGroupId);
           }
           else{
               allUserList.add(GM.UserOrGroupId);                   
           }
       }
       for(GroupMember GM1 : [Select UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN : groupids]){
           allUserList.add(GM1.UserOrGroupId);
       }
       return allUserList;
   }
   
   public Pagereference BackToTitle()
   {
       Pagereference pref = new Pagereference('/'+titleid);
       return pref;
   }
    
}