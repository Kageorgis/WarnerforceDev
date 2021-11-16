public with sharing class WB_PlayListContentDetailsController {

    public Playlist__c playListObj {get;set;} 
    public Title__c searchTitleRecord {get;set;}
    public List<Title__c> lstTitles{get;set;}
    public TitleSearchWrapper titleSearchInstance{get; set;}
    public String Header{get; set;}
    
    public list<Playlist_Content__c> PlayListBaseRecord {get; set;}  
    public string leftString {get;set;}
    public string rightString {get;set;}
    public String title = '';
    public String playListID = '';
    public list<Title__c> titlelistAvaliable {get;set;}
    public list<Playlist_Content__c> titlelistSelected {get;set;}
    public Decimal cloneVideoVersion {get;set;}
    public string mode {get;set;}
    set<string> titleSetSelected = new set<string>();
    public list<Local_Title__c> playlistInLocalData {get;set;}
    public list<Client_Avail__c> playlistInClientAvail {get;set;}
    public list<Commercial_Avail__c> playlistInCommercialAvail {get;set;}
    public Integer BOMcount {get;set;}
    public Integer TitleCount { get; set; }
    public String GlobalCategory;
    public boolean activeStatus=false;
    public boolean RecalculateSequence {get;set;}
    public String titleContentType{get;set;}

    public WB_PlayListContentDetailsController ()
    {
        String SobjectApiName = 'Playlist__c';
        titleSearchInstance = new TitleSearchWrapper();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        //RecalculateSequence = false;
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 
        title = System.currentPagereference().getParameters().get('Title');
        playListID = System.currentPagereference().getParameters().get('playList') ;
        mode = ApexPages.currentpage().getParameters().get('mode');
        
        cloneVideoVersion = 1;
        titleContentType = [SELECT id,Content_Type__c from Title__c where id =: title limit 1].Content_Type__c;
        if((mode == 'c' || mode == 'n')){
        list<Playlist__c> playListV = [SELECT Version_Number__c,Recalculate_Sequence__c  FROM Playlist__c WHERE Parent_Title__c =:title Order by Version_Number__c DESC Limit 1];
        if(playListV != null && playListV.size() > 0){
               cloneVideoVersion = playListV[0].Version_Number__c + 1;
               //RecalculateSequence = playListV[0].Recalculate_Sequence__c;
        }
        }
        
        /*-- for new Playlist Record --*/
        if(mode == 'n'){
            Header = 'Create Playlist';
            playListObj = new Playlist__c();
            playListObj.Version_Number__c = cloneVideoVersion;
            playListObj.Parent_Title__c = title;
            
            if(titleContentType == 'Season')
            {
                if(cloneVideoVersion == 1)
                    playListObj.Playlist_Type__c = 'TV Season Standard';
                else
                    playListObj.Playlist_Type__c = 'TV Season Local';
            }
            // START : ER-606 : Choose playlist types as per selected content type
            else if(titleContentType == 'Collection Features' ){
                if(cloneVideoVersion == 1)
                     playListObj.Name = 'Standard';
                playListObj.Playlist_Type__c = 'Collection Features';
                 
            }
            /*else if(titleContentType == 'Collection Features')
                playListObj.Playlist_Type__c = 'Collection Features';*/
            else if(titleContentType == 'Collection TV')
                playListObj.Playlist_Type__c = 'Collection TV';
            
            // END : ER-606
        }
        else if(mode == 'e'){
            Header = 'Edit Playlist : ';
        }

        searchTitleRecord = new Title__c();
        
        leftString = '';
        rightString = '';
        titlelistAvaliable = new list<Title__c>();
        titlelistSelected = new list<Playlist_Content__c>();
        
        if(title != '' && title != null && playListID != '' && playListID != null){
            String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID=\''+playListID+'\'';
        playListObj = Database.query(query);  
        
       }
       
       if(mode == 'c'){
           Header = 'Clone Playlist : ';
           if(titleContentType == 'Season')
               playListObj.Playlist_Type__c = 'TV Season Local';
               
           // START : ER-606 : Choose playlist types as per selected content type
           else if(titleContentType == 'Collection Features')
                playListObj.Playlist_Type__c = 'Collection Features';
           else if(titleContentType == 'Collection TV')
                playListObj.Playlist_Type__c = 'Collection TV';
           // END : ER-606
           playListObj.Playlist_Status__c = 'Draft';
        }

        If(playListID != '' && playListID != null){
        PlayListBaseRecord = new list<Playlist_Content__c>();
        PlayListBaseRecord = [SELECT Id, Content_Title__c,Title_Name__c,Content_Title__r.MPM_F__c, Content_VV__c, Content_Sequence__c,Content_Title__r.MPM_Long_Desc__c FROM Playlist_Content__c WHERE Playlist__c=: playListID ORDER BY Content_Sequence__c ASC];   
        if(PlayListBaseRecord != null){ 
          for(Playlist_Content__c PC : PlayListBaseRecord){
              titlelistSelected.add(PC);
          }      
       }
       }
       
       /*--------------------------------------*/
       if(title != '' && title != null){
       List<ID> BOM_List = New List<ID>();
       for(Title_BOM__c B : [SELECT MPM__c FROM Title_BOM__c WHERE Title__c =: title AND MPM__c != '' AND BOM_Type__c = 'VBOM']){
           if(B != null)
           BOM_List.add(B.MPM__c);
       }
       BOMcount = 0;
       BOMcount = BOM_List.size();
       
       if(BOMcount == 0){
           Title__c ttl = [SELECT MPM__c,Season_Episode_Number__c  FROM Title__c WHERE Id = :title LIMIT 1];
           if(ttl.MPM__c != null){
               MPM__c mpm = [SELECT Generic__c FROM MPM__c WHERE Id = :ttl.MPM__c LIMIT 1];
               if(mpm.Generic__c != TRUE)
                   BOM_List.add(ttl.MPM__c);
           }
       }
       BOMcount = BOM_List.size();

       for(Playlist_Content__c PlC : titlelistSelected){
            titleSetSelected.add(PLC.Content_Title__c);
       }
       String queryOnTitle = 'SELECT ID, name, video_version__c,MPM_F__c,TV_Title__c,Season_Episode_Number__c,MPM_Long_Desc__c';
        queryOnTitle += ' FROM Title__c ';
        queryOnTitle += 'WHERE MPM__c IN (SELECT ID from MPM__c WHERE ID IN : BOM_List) ';
        queryOnTitle += ' AND ';
        
        // START : ER-606 : Added code to check content type and based on content type add proper filters.
        if(titleContentType == 'Collection Features'){
            queryOnTitle += ' Content_Type__c = \'Feature\'';
            queryOnTitle += ' AND Clear_to_Avail__c = true ';
        }
        else if(titleContentType == 'Season' || titleContentType == 'Collection TV')
            queryOnTitle += ' Content_Type__c = \'Episode\'';
        // END : ER-606
        
        queryOnTitle += ' AND Digital_Planning__c = \'Yes\' ';
        queryOnTitle += ' ORDER BY Season__c ASC, Episode__c ASC';
        queryOnTitle += ' Limit 500';
        /*[SELECT ID, name, video_version__c,MPM_F__c,TV_Title__c,Season_Episode_Number__c
            FROM Title__c 
            WHERE MPM__c IN (SELECT ID from MPM__c WHERE ID IN : BOM_List) 
            AND Content_Type__c = 'Episode' 
            AND Digital_Planning__c = 'Yes' 
            ORDER BY Season__c ASC, Episode__c ASC 
            Limit 500]*/
       for(Title__c titleList : Database.query(queryOnTitle)){
           if(!titleSetSelected.contains(titleList.ID)){
             titlelistAvaliable.add(titleList);
           }
       }
       TitleCount = 0;
       TitleCount = titlelistAvaliable.size();
       system.debug('@@@@@@@@@@@@@@'+titlelistAvaliable);
       }       
       playlistInLocalData = new list<Local_Title__c>();
       playlistInClientAvail = new list<Client_Avail__c>();
       playlistInCommercialAvail = new list<Commercial_Avail__c>();
       /*--------------------------------------*/
       if(playListObj.Playlist_Status__c != null && playListObj.Playlist_Status__c == 'Active')
            activeStatus = true;
        
    }
     //Get Field set to display as a PlayList input Fields.
    public List<Schema.FieldSetMember> getPlayListFieldSet() 
    {
        return SObjectType.Playlist__c.FieldSets.PlayList_Mapping_Page.getFields();
    }
    public List<Schema.FieldSetMember> getTitleSearchFields() 
    {
        return SObjectType.Title__c.FieldSets.Search_Manage_Playlist.getFields();
    }
    
    public PageReference search() {
        
        system.debug('***************************search called');
        lstTitles = new List<Title__c>();
        String searchQuery='';
        List<String> listVVNumbers;
        List<String> listMPMNames;
        List<String> listCTs;
        List<String> listAbstractEs;
        /*------------------------------------------*/
        
        if(titleSearchInstance.titleName != '' || titleSearchInstance.titleVVNumber != '' ||
           titleSearchInstance.MPMName != '' || titleSearchInstance.ContentType != '' || titleSearchInstance.AbstractEIDR != '')
        {
            Boolean flagAND = false;
            searchQuery = 'Select id,name,Content_Type__c,Video_Version__c,MPM__c,MPM_F__c,Clear_to_Avail__c,Title_Abstract_EIDR__c,TV_Title__c,Season_Episode_Number__c,MPM_Long_Desc__c FROM Title__c WHERE';
            if(titleSearchInstance.titleName != '')
            {
                flagAND=true;
                Integer count=0;
                String whereclause = '';
                String tempname = String.escapeSingleQuotes(titleSearchInstance.titleName);
                List<String> listNames = tempname.split('\\*');
                for(String sname : listNames)
                {
                    if(count !=0)
                        whereclause += ' AND';    
                    whereclause += ' Name like \'%'+sname+'%\'';
                    count++;
                }
                searchQuery += whereclause;
            }
            if(titleSearchInstance.titleVVNumber != '')
            {
                if(flagAND)
                    searchQuery += ' AND';
                else
                    flagAND=true;
                listVVNumbers = titleSearchInstance.titleVVNumber.split(',');
                searchQuery += ' Video_Version__c in: listVVNumbers';
            }
            if(titleSearchInstance.MPMName != '')
            {
                if(flagAND)
                    searchQuery += ' AND';
                else
                    flagAND=true;
                listMPMNames = titleSearchInstance.MPMName.split(',');
                searchQuery += ' MPM__r.name in: listMPMNames';
            }
            if(titleSearchInstance.ContentType != '')
            {
                if(flagAND)
                    searchQuery += ' AND';
                else
                    flagAND=true;
                listCTs = titleSearchInstance.ContentType.split(',');
                searchQuery += ' Content_Type__c in: listCTs';
            }
            if(titleSearchInstance.AbstractEIDR != '')
            {
                if(flagAND)
                    searchQuery += ' AND';
                else
                    flagAND=true;
                listAbstractEs = titleSearchInstance.AbstractEIDR.split(',');
                searchQuery += ' Title_Abstract_EIDR__c in: listAbstractEs';
            }
            if(flagAND)
            {
                // START : ER-606 : Added conditions as per selected content types
                if(titleContentType == 'Collection Features'){
                    searchQuery += ' AND Content_Type__c = \'Feature\'';
                    searchQuery += ' AND Clear_to_Avail__c = true ';
                }
                else if(titleContentType == 'Season')
                    searchQuery += ' AND Content_Type__c = \'Episode\'';
                else if(titleContentType == 'Collection TV')
                    searchQuery += ' AND Clear_to_Avail__c = true ';
                // END : ER-606
                
                searchQuery += ' AND Digital_Planning__c = \'Yes\' AND id not in: titleSetSelected AND id not in: titlelistAvaliable ORDER BY Season__c ASC, Episode__c ASC limit 500';
                
            }
        }
        system.debug('**************searchQuery************'+searchQuery);
        if(searchQuery != ''){
            lstTitles = Database.query(searchquery);  
            if(lstTitles ==null || lstTitles.size() == 0) {  
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Digital Planned Titles are not found for your search criteria or already on \'Suggested Titles\' Section/Tab.'));  
            }
        }
        return null;
    }
    
    public PageReference customSaveRecord()
    {

        list<string> selectedItems = ApexPages.currentpage().getParameters().get('selectedValue_serialised').split('!#!');   
        Set<String> tempSet = new Set<String>();
        tempSet.addAll(selectedItems); 
        if(tempSet.size() < selectedItems.size()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Same Title(s) has been added multiple times.Please remove multiple instance of same title')); 
            return null; 
        }
        
        if(ApexPages.currentpage().getParameters().get('selectedValue_serialised').trim() == '') {  
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There must be at least one \'Title\' added to the Playlist before saving.')); 
            return null;

        }
        
        /*-- if the playlist is in use, it should not be deleted--- START ---- */
        
        if(playListObj.Playlist_Status__c != 'Active' && playListObj.ID != null && activeStatus){
            playlistInLocalData = [SELECT ID, Name FROM Local_Title__c WHERE Playlist__c =: playListObj.ID AND External_Company__c = Null];
            playlistInClientAvail = [SELECT ID, Name FROM Client_Avail__c WHERE Playlist__c =: playListObj.ID ];
            playlistInCommercialAvail = [SELECT ID, Name FROM Commercial_Avail__c WHERE Playlist__c =: playListObj.ID ];
        if(playlistInLocalData.size() > 0 || playlistInClientAvail.size() > 0 || playlistInCommercialAvail.size() > 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Playlist is in use, Status must stay Active until you remove the playlist reference from below Local Data, Release Plan and Client Avail records. Start with Local Data, system will cascade the updates to Release Plan and Client Avails automatically.')); 
            return null;
        }
            
        }
        
        /*-- if the playlist is in use, it should not be deleted--- ENDS ---- */
        
        /*-- Create New Playlist and map Playlist_Content to new playlist ----*/
      if(playListObj.ID == null && mode == 'n'){
        user u = [SELECT ID, Territory__c, profile.name FROM User WHERE ID =: UserInfo.getUserId()];
        if(u.Profile.Name == 'WB - Territory Avails Planner')
        playListObj.Territory__c = u.Territory__c;
        // set Recalculate Sequence value
        //playListObj.Recalculate_Sequence__c = RecalculateSequence;
         /*---- Unique Playlist Name ------*/
        
        Integer findDuplicate = [SELECT count() FROM Playlist__c WHERE Name =: playListObj.Name.trim() AND Parent_Title__c =:playListObj.Parent_Title__c];
        if(findDuplicate > 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Duplicate \'Playlist Name\' found. Enter Unique Playlist Name')); 
            return null;
        }
        /*---- Unique Playlist Name ------*/
        
        if(playListObj.Playlist_Status__c == 'Deleted'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, '\'Playlist Status\' cannot be Deleted while creating new Playlist')); 
            return null;
        }
        
        try{      
           // playListObj.Version_Number__c = cloneVideoVersion;
            insert playListObj;
            
        }  catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        updatePlaylistContent(playListObj.id);
        PageReference pageRef = new PageReference('/apex/WB_PlayListContentDetails?playList='+playListObj.id+'&Title='+title+'&mode=e');
        pageRef.setRedirect(true);     
        return pageRef;
    }
    
     /*-- Update Existing Playlist N Playlist_Content ----*/
    if(playListObj.ID != null && title !=null && mode == 'e'){    
         try { 
         UPDATE playListObj;
        } catch(System.DMLException e) {
            
            if(e.getMessage().contains('Avail is pending for creation of Content Avails - Please retry in 10 mins.'))
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Avail is pending for creation of Content Avails - Please retry in 10 mins')); 
            else
            ApexPages.addMessages(e);
            return null;
        }
        updatePlaylistContent(playListID);
        if(titleContentType == 'Season')
            updateGlobalCategoryReletedTitle(playListID);
        
        PageReference pageRef = new PageReference('/apex/WB_PlayListContentDetails?playList='+playListObj.id+'&Title='+title+'&mode='+mode);
        pageRef.setRedirect(true);     
        return pageRef;
        
    }
    /*-- Clone  Existing Playlist N Playlist_Content ----*/
    if(playListObj.ID != null && title !=null && mode == 'c'){ 
        
        /*---- Unique Playlist Name ------*/
        Integer findDuplicate = [SELECT count() FROM Playlist__c WHERE Name =: playListObj.Name.trim() AND Parent_Title__c =:playListObj.Parent_Title__c];
        if(findDuplicate > 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Duplicate \'Playlist Name\' found. Enter Unique Playlist Name')); 
            return null;
        }
        /*---- Unique Playlist Name ------*/
        
        if(playListObj.Playlist_Status__c == 'Deleted'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, '\'Playlist Status\' cannot be Deleted while Cloning a Playlist')); 
            return null;
        }
        
        Playlist__c cplayListRecord = new Playlist__c();
        cplayListRecord = playListObj;
        cplayListRecord.id = null;
        cplayListRecord.Version_Number__c = cloneVideoVersion;        
         try { 
         Insert cplayListRecord;
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } 
        updatePlaylistContent(cplayListRecord.id);        
        PageReference pageRef = new PageReference('/apex/WB_PlayListContentDetails?playList='+cplayListRecord.id+'&Title='+title+'&mode=e');
        pageRef.setRedirect(true);     
        return pageRef;
        
    }
      
      return null;  
    }
    
    /* Method to insert/remove Playlist_Content from a Playlist*/
    public pagereference showSelectedItems(){
           rightString = ApexPages.currentpage().getParameters().get('selectedValue_serialised');
           leftString = ApexPages.currentpage().getParameters().get('availValue_serialised');
           return null;
       }
       
       public void updatePlaylistContent(string playListIDString){
          
        rightString = ApexPages.currentpage().getParameters().get('selectedValue_serialised');
        leftString = ApexPages.currentpage().getParameters().get('availValue_serialised');
        list<string> selectedItems = rightString.split('!#!');   
        
        list<Playlist_Content__c> PLUpdateInsert = New list<Playlist_Content__c>();    
        list<Playlist_Content__c> PLListExisting = [SELECT ID, Content_Title__c FROM Playlist_Content__c WHERE Playlist__c =:playListIDString ];  
        
        /* ---  Sorting, Insertion logic  ---*/
        set<string> PLSetExisting = new set<string>(); 
        set<string> SelectedTitleSet = new set<string>(); 
        for(Playlist_Content__c m :PLListExisting){ 
        PLSetExisting.add(m.Content_Title__c); 
        } 
        for(String ST :selectedItems){
        if(ST.trim() != '')    
        SelectedTitleSet.add(ST.trim()); 
        } 
        Integer OrderNo = 1;
        for(String S : selectedItems){
           for(Playlist_Content__c P : PLListExisting){
                if(s.trim() != '' && s.trim() == P.Content_Title__c){
                    PLUpdateInsert.add(New Playlist_Content__c(
                           id=P.id,Content_Sequence__c = OrderNo));
                }
                else{ 
                    if(s.trim() != '' && !PLSetExisting.contains(s.trim())){
                    PLUpdateInsert.add(New Playlist_Content__c(
                    Content_Sequence__c = OrderNo, Content_Status__c = 'Active', Content_Title__c = s.trim(), Playlist__c = playListIDString));
                    break;
                }
                }
            }
            if(PLListExisting.size() == 0 && s.trim() != ''){
                    PLUpdateInsert.add(New Playlist_Content__c(
                    Content_Sequence__c = OrderNo, Content_Status__c = 'Active', Content_Title__c = s.trim(), Playlist__c = playListIDString));
                
            }
            OrderNo = OrderNo+1;
        }
        
        /* ---  Remove Playlist_Content from Playlist logic  ---*/     
        list<Playlist_Content__c> removePL = new list<Playlist_Content__c>();
        for(Playlist_Content__c RemoveIrrit :PLListExisting){
            if(!SelectedTitleSet.contains(RemoveIrrit.Content_Title__c)){
                removePL.add(New Playlist_Content__c( ID= RemoveIrrit.id) );
            }
        }

        if(PLUpdateInsert.size() > 0){
            try{
            upsert PLUpdateInsert;
            if(titleContentType == 'Season')
                updateGlobalCategoryReletedTitle(playListID); //sriniz 06/16/2016
            }  catch(System.DMLException e) {
           
           if(e.getMessage().contains('Avail is pending for creation of Content Avails - Please retry in 10 mins'))
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Avail is pending for creation of Content Avails - Please retry in 10 mins')); 
           else
           ApexPages.addMessages(e);

        }
        }
        if(removePL.size() > 0){
            delete removePL;
        }
        
        List<Playlist_Content__c> listPC = [SELECT id from Playlist_Content__c where Playlist__c =: playListIDString];
        update new Playlist__c(id=playListIDString,Total_Playlist_Content__c=listPC.size());
           
       }
       
       public class TitleSearchWrapper
       {
           Public String titleName{get; set;}
           Public String titleVVNumber{get; set;}
           Public String MPMName{get; set;}
           Public String ContentType{get; set;}
           Public String AbstractEIDR{get; set;}
           public TitleSearchWrapper(){
                titleName = '';
                titleVVNumber = '';
                MPMName = '';
                ContentType = '';
                AbstractEIDR = '';
           }
       }
       
       public void updateGlobalCategoryReletedTitle(string playListIDString){
           list<Title__c> titleToUpdate = New List<Title__c>();
          Title__c ParentTitle = [SELECT ID, Global_Category__c FROM Title__c WHERE ID =: System.currentPagereference().getParameters().get('Title')]; 
          if(ParentTitle.Global_Category__c != ''){
         list<string> selectedItems = rightString.split('!#!');   
    
         list<Title__c> titleRecord = [SELECT Id,Global_Category__c FROM Title__c WHERE ID =:selectedItems ]; 
         for(Title__c TR : titleRecord){
             if(TR.Global_Category__c == null){  
                 Title__c t = New Title__c();
                 t.ID = TR.Id;
                 t.Global_Category__c = ParentTitle.Global_Category__c;
                 titleToUpdate.add(t);
             }
         }
         }
         update titleToUpdate;  
       }
       
       public pagereference backToPage(){
           pagereference pref = new pagereference('/apex/WB_ManagePlayListContent?id='+title);
           return pref;
       }
  
}