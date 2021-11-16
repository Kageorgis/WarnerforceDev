@isTest
private class WB_ManagePlayListLocalData_Cont_Test{

  public static List<Client_Avail__c> listClientavails;
    public static Playlist__c playlist1;
    public static Playlist__c playlist;
    public static Title__c episodeTitle;
    public static Commercial_Avail__c releasePlan1;
    public static Local_Title__c episodeLT;
    public static Local_Title__c episodeLT2;
    public static List<Local_Title__c> listlocaltitles;
    public static Country__c Country_USA;
    public static Language__c Language_ENG;
    public static Country__c Country_German;
    public static Language__c Language_Germany;
    public static List<Local_Data_sync_Group__c> listSyncGroup;
    public static  Language__c Language;

    public static void setUpData(Boolean flag){
        /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.initAccount();
        objAccount.Type='Global';
        insert objAccount;
        
        /* -- Title creation-- */
        Title__c t = new Title__c();
        t.Name = 'Test Title';
        t.Digital_Planning__c = 'Yes';
        t.Clear_to_Avail__c = true;
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.US_TV_Air_Date__c = system.today();
        t.Formats__c= 'SD';
        Insert t;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Test Title';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c= 'SD';
        Insert episodeTitle;
        
        Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        episodeTitle2.Formats__c = 'SD';
        Insert episodeTitle2;
        
        playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist1.Version_Number__c = 1;
        playlist1.Parent_Title__c = episodeTitle.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        content.Content_Sequence__c = 1;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist1.id;
        content.Content_Sequence__c = 2;
        contentlist.add(content2);
    //    insert contentlist;

        Playlist_Content__c content3 = new Playlist_Content__c();
        content3.Content_Title__c=t.id;
        content3.Playlist__c = playlist.id;
        content.Content_Sequence__c = 3;
        contentlist.add(content3);
        insert contentlist;
        
        Country__c Country = New Country__c();
        Country.Name = 'India';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.TV_Day_After_US_Offset__c = 2;
        Country.TV_Day_After_Local_Offset__c = 1;
        insert Country;
        
        Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        Country_USA = New Country__c();
        Country_USA.Name = 'USA';
        Country_USA.Country_Code2__c = 'US';
        Country_USA.Country_Code__c = 'US';
        Country_USA.Status__c = 'Active';
        Country_USA.TV_Day_After_US_Offset__c = 2;
        Country_USA.TV_Day_After_Local_Offset__c = 1;
        insert Country_USA;
        
        Language_ENG = New Language__c();
        Language_ENG.Name = 'English';
        Language_ENG.Language_Order__c = 1;
        insert Language_ENG;
        
        Country_German = New Country__c();
        Country_German.Name = 'German';
        Country_German.Country_Code2__c = 'GE';
        Country_German.Country_Code__c = 'GER';
        Country_German.Status__c = 'Active';
        Country_German.TV_Day_After_US_Offset__c = 2;
        Country_German.TV_Day_After_Local_Offset__c = 1;
        insert Country_German;
        
        Language_Germany = New Language__c();
        Language_Germany.Name = 'Germany';
        Language_Germany.Language_Order__c = 1;
        insert Language_Germany;
        
        //Seson Local Title
        listlocaltitles= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        episodeLT2 = New Local_Title__c();
        episodeLT2.Name = t.Name;
        episodeLT2.Title__c = episodeTitle.Id;
        episodeLT2.Country__c = Country.Id;
        episodeLT2.Language__c = Language.Id;
        episodeLT2.Local_TV_Air_Date__c = date.today();
        episodeLT2.Local_Episodes__c = 1;
        episodeLT2.Parent_Local_Data__c=LT.id;
        episodeLT2.Category__c = 'TV Catalog';
        episodeLT2.Playlist__C = playlist1.id;
        
        episodeLT = New Local_Title__c();
        episodeLT.Name = t.Name;
        episodeLT.Title__c = episodeTitle.Id;
        episodeLT.Local_Episodes__c = 1;
        episodeLT.Country__c = Country_USA.Id;
        episodeLT.Language__c = Language.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Catalog';
        episodeLT.Playlist__C = playlist1.id;
        listlocaltitles.add(episodeLT);
        listlocaltitles.add(episodeLT2);
        
        insert listlocaltitles;
        
        
   }
   public static void setUplocalDataSyncGroupDatA(Language__c Language){
        
        listSyncGroup = new List<Local_Data_sync_Group__c>();
        listSyncGroup.add(new Local_Data_sync_Group__c(Name = 'Sync Group'));
        listSyncGroup.add(new Local_Data_sync_Group__c(Name = 'Sync Group1'));
        insert listSyncGroup;
        
        List<Local_Data_sync_Group_Item__c> listSyncGroupItems = new List<Local_Data_sync_Group_Item__c>();
        listSyncGroupItems.add(new Local_Data_sync_Group_Item__c(Country__c = Country_USA.Id , Language__c = Language.Id,Local_Data_sync_Group__c =listSyncGroup[0].Id ));
        listSyncGroupItems.add(new Local_Data_sync_Group_Item__c(Country__c = Country_German.Id , Language__c = Language_Germany.Id,Local_Data_sync_Group__c =listSyncGroup[0].Id ));
        listSyncGroupItems.add(new Local_Data_sync_Group_Item__c(Country__c = Country_USA.Id, Language__c = Language.Id,Local_Data_sync_Group__c =listSyncGroup[1].Id ));
        insert listSyncGroupItems;
   } 
    static testMethod void getContentLocalDataTest(){
        
        setUpData(true);
        Test.startTest(); 
        
        PageReference pageRef = Page.WB_ManagePlayListLocalData;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('LocalTitleId', listlocaltitles[0].id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listlocaltitles);
        WB_ManagePlayListLocalData_Controller controller = new WB_ManagePlayListLocalData_Controller(sc);
        controller.cancel();
        controller.updateContentLocalData();
        Test.stopTest();
        
    }
    static testmethod void getContentLocalDataTest1(){
         setUpData(true);
         setUplocalDataSyncGroupDatA(Language);
         Test.startTest(); 
         ApexPages.currentPage().getParameters().put('LocalTitleId', listlocaltitles[0].id);
         ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listlocaltitles);
         WB_ManagePlayListLocalData_Controller controller = new WB_ManagePlayListLocalData_Controller(sc);
         controller.getLocalDataSyncGroup();
         controller.selectedlocalDataSyncGrNm = listSyncGroup[0].Name;
         controller.contentLocalData[0].Local_TV_Air_Date__c = date.today() + 2;
         controller.updateContentLocalData();
         Local_Title__c EpisodicLT = [select id,Local_TV_Air_Date__c from Local_Title__c where Title__c =:episodeTitle.Id  AND Country__c =: Country_USA.Id
                                                           AND Language__c =: Language.Id ];
         system.assertEquals(EpisodicLT.Local_TV_Air_Date__c,date.today()+2);
         Test.stopTest();
         
    }
     static testmethod void getContentLocalDataTest2(){
         setUpData(true);
         setUplocalDataSyncGroupDatA(Language);
         Test.startTest(); 
         ApexPages.currentPage().getParameters().put('LocalTitleId', listlocaltitles[0].id);
         ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listlocaltitles);
         WB_ManagePlayListLocalData_Controller controller = new WB_ManagePlayListLocalData_Controller(sc);
         controller.getLocalDataSyncGroup();
         controller.selectedlocalDataSyncGrNm = listSyncGroup[1].Name;
         controller.contentLocalData[0].Local_TV_Air_Date__c = date.today() + 2;
         controller.contentLocalData[0].Name = 'Test- '+ date.today();
         controller.updateContentLocalData();
         Local_Title__c EpisodicLT = [select id,Local_TV_Air_Date__c,name from Local_Title__c where Title__c =:episodeTitle.Id  AND Country__c =: Country_USA.Id
                                                           AND Language__c =: Language.Id ];
         system.assertEquals(EpisodicLT.Local_TV_Air_Date__c,date.today()+2);
         system.assertEquals(EpisodicLT.name,'Test Title');
          
         Test.stopTest();
         
    }
    static testMethod void customBtn_PlaylistLocalData(){
        
        setUpData(true);
        Test.startTest(); 
        Local_Title__c LT = listlocaltitles[0];
        PageReference pageRef = Page.WB_ManagePlayListLocalData;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(LT);
        WB_ManagePlayListLocalData_Controller controller = new WB_ManagePlayListLocalData_Controller(sc);
        controller.forwardToListController();
        Test.stopTest();
        
    }
 }