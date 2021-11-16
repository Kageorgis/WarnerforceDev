@isTest(SeeAllData=false)
public class WB_PlaylistContentCA_ControllerTest {
     static List<Account> accList = new List<Account>();
    static List<Title__c> titleList = new List<Title__c>();
    static List<Country__c> cList = new List<Country__c>();
    static List<Language__c> lList = new List<Language__c>();
    static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    static List<Agreement__c> aList = new List<Agreement__c>();
    static List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    static List<String> selectedClientAvailIds = new List<String>();
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    static Integer count=3;    
    public static Playlist__c playlist1;
    public static Playlist__c playlist12;
    public static Account objAccount;
    public static List<Local_Title__c> listlocaltitles;
    public static List<Client_Avail__c> listClientavails;
     public static Commercial_Avail__c releasePlan1;
     public static List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
     public static Title__c t;
     public static Title__c episodeTitle;
     public static Language__c Language;
     public static Country__c Country; 
     public static Account objAccount1;
     public static Title__c t1;
     public static Title__c episodeTitle1;
     public static Title__c episodeTitle2;
     public static Playlist__c playlist123;
     public static Playlist__c playlist13;
     public static Language__c Language1;
     public static Country__c Country_1; 
     public static List<Local_Title__c> listlocaltitles12;
     public static List<Client_Avail__c> listClientavails12;
     static List<Pricing__c> lPricing5 = new List<Pricing__c>();
     public static List<Commercial_Avail__c> listReleaseplan_1;
     public static Commercial_Avail__c releasePlan_1;
     public static Playlist__c playlist;
     public static Local_Title__c episodeLT;
     public static Commercial_Avail__c releasePlan2; 
    
    
    public static void createTestData(Boolean flag){
        /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
        /* -- Title creation-- */
         t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Formats__c = 'SD';
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        Insert t1;
        
        episodeTitle1 = new Title__c();
        episodeTitle1.Name = 'Vampire Diaries S01E01';
        episodeTitle1.Digital_Planning__c = 'Yes';
        episodeTitle1.Formats__c = 'SD';
        episodeTitle1.Clear_to_Avail__c = true;
        episodeTitle1.Content_Type__c = 'Episode';
        episodeTitle1.Video_Version__c = '000000002';
        episodeTitle1.Global_Category__c = 'TV Catalog';
        episodeTitle1.MPM__c = Mpm.id;
        Insert episodeTitle1;
        
        episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Vampire Diaries S01E02';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle1.Formats__c = 'SD';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle2.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        Insert episodeTitle2;
        
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t1.id;
        playlist123.Playlist_Status__c = 'Active';
        insert playlist123;
       
        Country_1 = New Country__c();
        Country_1.Name = 'IndiaC';
        Country_1.Country_Code2__c = 'IA';
        Country_1.Country_Code__c = 'IA';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        Country_1.Territory__c = 'USA';
        insert Country_1;
        
        Language1 = New Language__c();
        Language1.Name = 'English';
        Language1.Language_Order__c = 1;
        insert Language1;
        
        Pricing__c pricing5 = new Pricing__c();
        pricing5.Name = 'CheckPriceCode';
        pricing5.Account__c = objAccount1.id;
        pricing5.Country__c = Country_1.id;
        pricing5.Channel__c='VODi';
        pricing5.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing5.Price_Tier__c ='123';
        pricing5.Episode_Price_Tier__c='89.9';
        pricing5.Format__c='SD';
        lPricing5.add(pricing5);
        
        Pricing__c pricing51 = new Pricing__c();
        pricing51.Name = 'CheckPriceCode';
        pricing51.Account__c = objAccount1.id;
        pricing51.Country__c = Country_1.id;
        pricing51.Channel__c='VODi';
        pricing51.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing51.Price_Tier__c ='123';
        pricing51.Episode_Price_Tier__c='89.9';
        pricing51.Format__c='SD';
        lPricing5.add(pricing51);
        
        insert lPricing5;
        
        for(Pricing__c pr : lPricing5){
            system.debug('####Pricing:'+pr);
        }
        
        listlocaltitles12= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t1.Name;
        LT.Title__c = t1.Id;
        LT.Country__c = Country_1.Id;
        LT.Language__c = Language1.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist123.id;        //Removed Comment
        LT.Price_Code__c = 'CheckPriceCode';
        LT.Category__c = 'TV Catalog';
        listlocaltitles12.add(LT);
        
        Local_Title__c episodeLT = New Local_Title__c();
        episodeLT.Name = t1.Name;
        episodeLT.Title__c = episodeTitle1.Id;
        episodeLT.Country__c = Country_1.Id;
        episodeLT.Language__c = Language1.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Catalog';
        listlocaltitles12.add(episodeLT);
        
        Insert listlocaltitles12;
        
        for(Local_Title__c lt1 : listlocaltitles12){
           system.debug('####Local_Title__c:'+lt1); 
        }
        
        listReleaseplan_1 = new List<Commercial_Avail__c>();
        releasePlan_1 = new Commercial_Avail__c();
        releasePlan_1.Channel__c = 'VODi';
        releasePlan_1.Title__c=t1.id;
        releasePlan_1.Languages__c = Language1.id;
        releasePlan_1.Country_Lookup__c = Country_1.id;
        releasePlan_1.Format__c = 'SD';
        releasePlan_1.Language_Type__c = 'Sub & Audio';
        releasePlan_1.Exclusive_Date__c = date.today()-200;
        releasePlan_1.Start_Date__c = date.today()-100;
        releasePlan_1.End_Date__c = date.today()+100;
        releasePlan_1.Rights_End__c=date.today()+200;
        releasePlan_1.Status__c = 'Confirmed';
        releasePlan_1.Playlist__C = playlist123.id;     //Removed Comment
        
        listReleaseplan_1.add(releasePlan_1);
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle1.id;
        releasePlan2.Languages__c = Language1.id;
        releasePlan2.Country_Lookup__c = Country_1.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = system.today()-200;
        releasePlan2.Start_Date__c = system.today()-70;
        releasePlan2.End_Date__c = system.today()+70;
        releasePlan2.Rights_End__c=system.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        
        listReleaseplan_1.add(releasePlan2);
        
        insert listReleaseplan_1;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, listReleaseplan_1[0], t1);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan_1[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        countrySIDList.add(new Country_SID_Key__c(Name='IndiaC', Country_Code__c='IA',Country_Code2_c__c='IA',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
    }
    
       //getSeasonsWithoutPlaylist Start
    @isTest
    public static void testMethodgetSeasonsWithoutPlay(){
        
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
        /* -- Title creation-- */
         t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Formats__c = 'SD';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        Insert t1;
        
        episodeTitle1 = new Title__c();
        episodeTitle1.Name = 'Vampire Diaries S01E01';
        episodeTitle1.Digital_Planning__c = 'Yes';
        episodeTitle1.Formats__c = 'SD';
        episodeTitle1.Clear_to_Avail__c = true;
        episodeTitle1.Content_Type__c = 'Episode';
        episodeTitle1.Video_Version__c = '000000002';
        episodeTitle1.Global_Category__c = 'TV Catalog';
        episodeTitle1.MPM__c = Mpm.id;
        episodeTitle1.US_TV_Air_Date__c = system.today();
        Insert episodeTitle1;
        
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t1.id;
        playlist123.Playlist_Status__c = 'Active';
        insert playlist123;
        
        Country_1 = New Country__c();
        Country_1.Name = 'IndiaC';
        Country_1.Country_Code2__c = 'IA';
        Country_1.Country_Code__c = 'IA';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        insert Country_1;
        
        Language1 = New Language__c();
        Language1.Name = 'English';
        Language1.Language_Order__c = 1;
        insert Language1;
        
        //listlocaltitles12= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t1.Name;
        LT.Title__c = t1.Id;
        LT.Country__c = Country_1.Id;
        LT.Language__c = Language1.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist123.id;        
        LT.Price_Code__c = 'CheckPriceCode';
        LT.Category__c = 'TV Catalog';
        //listlocaltitles12.add(LT);
        insert LT;
        
        Local_Title__c episodeLT = New Local_Title__c();
        episodeLT.Name = t1.Name;
        episodeLT.Title__c = episodeTitle1.Id;
        episodeLT.Country__c = Country_1.Id;
        episodeLT.Language__c = Language1.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Catalog';
        insert episodeLT;
        
        //listReleaseplan_1 = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan_1 = new Commercial_Avail__c();
        releasePlan_1.Channel__c = 'VODi';
        releasePlan_1.Title__c=t1.id;
        releasePlan_1.Languages__c = Language1.id;
        releasePlan_1.Country_Lookup__c = Country_1.id;
        releasePlan_1.Format__c = 'SD';
        releasePlan_1.Language_Type__c = 'Sub & Audio';
        releasePlan_1.Exclusive_Date__c = date.today()-200;
        releasePlan_1.Start_Date__c = date.today()-100;
        releasePlan_1.End_Date__c = date.today()+100;
        releasePlan_1.Rights_End__c=date.today()+200;
        releasePlan_1.Status__c = 'Confirmed';
        releasePlan_1.Playlist__C = playlist123.id;    
        insert releasePlan_1;
        
        commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle1.id;
        releasePlan2.Languages__c = Language1.id;
        releasePlan2.Country_Lookup__c = Country_1.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = system.today()-200;
        releasePlan2.Start_Date__c = system.today()-70;
        releasePlan2.End_Date__c = system.today()+70;
        releasePlan2.Rights_End__c=system.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        insert releasePlan2;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, releasePlan_1, t1);
        storefrontGoogle1.Formats_with_EC__c = releasePlan_1.Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
         
        listClientavails12 = new List<Client_Avail__c>();
        //Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        
        Client_Avail__c clientAvail = new Client_Avail__c();
        clientAvail.Client__c = objAccount1.Id;
        clientAvail.Commercial_Avail__c = releasePlan_1.Id;
        clientAvail.Local_Title__c = LT.Id;
        clientAvail.Start_Date__c = system.today()+10;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After US';
        //clientAvail.Playlist__c = null;
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, releasePlan2, episodeLT.Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After US';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        clientAvail1.Status__c = 'Tentative';
        listClientavails12.add(clientAvail1);
        
        /*
        System.debug('Title_Content_Type__c--->>'+listClientavails12[0].Title_Content_Type__c);
        System.debug('Playlist__c--->>'+listClientavails12[0].Playlist__c);
        System.debug('Commercial_Avail__r.Playlist__c--->>'+listClientavails12[0].Commercial_Avail__r.Playlist__c);
        System.debug('END_DATE__c--->>'+listClientavails12[0].END_DATE__c);
        System.debug('CA_LifeCycle__c--->>'+listClientavails12[0].CA_LifeCycle__c);
        
        try{
            listClientavails12[0].Playlist__c = null;
            update listClientavails12;
            Client_Avail__c ca = [Select id,Client__c,Playlist__c,Commercial_Avail__r.Playlist__c,Title_Content_Type__c,Commercial_Avail__c,Local_Title__c,CA_LifeCycle__c,Start_Date__c,End_Date__c,Status__c,Price_Tier_Text__c,Episode_Price_Tier__c,Local_Data_Category_Picklist__c from Client_Avail__c Where Id IN : listClientavails12];
            WB_PlaylistContentCA_Controller.getSeasonsWithoutPlaylist();
            System.debug('Printing ca--->>'+ca);
        }
        catch(Exception ex){
            system.debug('Printing Exception--->>'+ex.getStackTraceString());
        }
        */
        
        Test.startTest();
        insert listClientavails12;
        listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
        update listClientavails12;
        //WB_PlaylistContentCA_Controller.getDayAfterEpisodesWithInvalidStartDate();
        listClientavails12[1].Status__c = 'Draft';
        update listClientavails12;
       // WB_PlaylistContentCA_Controller.getDraftEpisodesWithBroadcastDate();
        Test.stopTest();
    }
    
    //getSeasonsWithoutPlaylist Finish
    @isTest
    public static void testMethodStatusInProgress()
    {
        createTestData(true);
        Test.startTest();
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        
            insert listClientavails12;
            
            listClientavails12[0].Playlist__c = playlist123.id;
            //update listClientavails12[0];
                
            Datetime yesterday = Datetime.now().addDays(-4);
            WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
                
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            
            update listClientavails12;
            
            Set<Id> caId = new Set<Id>();
            for(Client_Avail__c ca : listClientavails12){
                caId.add(ca.Id);
            }
            
            List<Client_Avail__c> caList = new List<Client_Avail__c>();
             caList = [Select Id,Name from Client_Avail__c where Id IN:caId];
            String Id1 = String.valueOf(caList[0].Id);
            String Id2 = String.valueOf(caList[1].Id);
            
            //WB_PlaylistContentCA_Controller playlistCtrl = new WB_PlaylistContentCA_Controller();
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1 = new List<WB_PlaylistContentCA_Controller.CAWrapper>();
            WB_PlaylistContentCA_Controller.CAWrapper wb1 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb1.videoVersion = '000000001';
            wb1.title ='Vampire Diaries S01';
            wb1.account='TestAccount';
            wb1.country='IndiaC';
            wb1.channel='VODi';
            wb1.format='SD';
            wb1.language='English';
            wb1.contentType='Season';
            wb1.languageType='Sub & Audio';
            wb1.caRecordId=Id1;
            wb1.caCategory='';
            wb1.price='';
            wb1.episodePrice='';
            wb1.episodePriceTier='';
            wb1.caName=caList[0].Name;
            wb1.action='action';
            wb1.selected=true;
            wb1.processedTime=null;
            //wb1.processedTime=system.now().addHours(1);
            wrapperCAlist1.add(wb1);
            
            WB_PlaylistContentCA_Controller.CAWrapper wb2 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb2.videoVersion = '000000001';
            wb2.title ='Vampire Diaries S02';
            wb2.account='TestAccount';
            wb2.country='IndiaC';
            wb2.channel='VODi';
            wb2.format='SD';
            wb2.language='English';
            wb2.contentType='Season';
            wb2.languageType='Sub & Audio';
            wb2.caRecordId=Id2;
            wb2.caCategory='';
            wb2.price='';
            wb2.episodePrice='';
            wb2.episodePriceTier='';
            wb2.caName=caList[1].Name;
            wb2.action='action';
            wb2.selected=true;
            wb2.processedTime=system.now();
            wrapperCAlist1.add(wb2);
            //wb1.priceTier='';
            
            wrapperCAlist1.sort();
            
            //WB_PlaylistContentCA_Controller.reCalculateEpisodes(wrapperCAlist1);
            System.debug('testMethodStatusInProgress--->'+wrapperCAlist1);
            //List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist2  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            
            //playlistCtrl.setstatusValueToComp('In Progress');
            //playlistCtrl.getstatusValueToComp();
        Test.stopTest();
        
    }
    
    @isTest
    public static void testMethodStatusError()
    {
        createTestData(true);
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
            
        insert listClientavails12;
        Test.setCreatedDate(listClientavails12[0].Id, DateTime.newInstance(2017,03,12));
        Test.startTest();
            
            listClientavails12[0].Playlist__c = playlist123.id;
            //update listClientavails12[0];
            
            Datetime yesterday = Datetime.now().addDays(-4);
            WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12;
            
            CAS_Error_Log__c createErrLogs = new CAS_Error_Log__c();
            createErrLogs.Object_Name__c = 'Client_Avail__c';
            createErrLogs.Error_Category__c = 'Episode Calculation';
            createErrLogs.Record_Id__c = clientAvail.Id;
            createErrLogs.Account__c = objAccount1.Id;
            createErrLogs.Error_Description__c = 'Error Message: Episode Avails cannot be confirmed with a TBD price tier.';
            insert createErrLogs;
            
            CAS_Error_Log__c createErrLogs1 = new CAS_Error_Log__c();
            createErrLogs1.Object_Name__c = 'Client_Avail__c';
            createErrLogs1.Error_Category__c = 'Episode Calculation';
            createErrLogs1.Record_Id__c = clientAvail1.Id;
            createErrLogs1.Account__c = objAccount1.Id;
            createErrLogs1.Error_Description__c = 'Error Message: Episode Avails cannot be confirmed with a TBD price tier.';
            insert createErrLogs1;
            
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('Error');
            
            /*playlistCtrl.setstatusValueToComp('Error');
            playlistCtrl.getstatusValueToComp();*/
        
        Test.stopTest();
        
    }
    
    //Akash Test Method for getCAErrorList : Start
    @isTest
    public static void testMethodcaErrorList()
    {
        createTestData(true);
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
            
        insert listClientavails12;
        Test.setCreatedDate(listClientavails12[0].Id, DateTime.newInstance(2017,03,12));
        Test.startTest();
            
            Profile p = [select id from profile where name='System Administrator'];
            User u = new User(alias = 'standt', email='testuser@testorg.com', 
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', Territory__c = 'USA',
                              localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);
            
            insert u;
            System.runAs(u){
                listClientavails12[0].Playlist__c = playlist123.id;
               
                Datetime yesterday = Datetime.now().addDays(-7);
                WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
                listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
                listClientavails12[1].Recalculate_Playlist_Avails__c = '';
                update listClientavails12;
                
                CAS_Error_Log__c createErrLogs = new CAS_Error_Log__c();
                createErrLogs.Object_Name__c = 'Client_Avail__c';
                createErrLogs.Error_Category__c = 'Playlist Update';
                createErrLogs.Record_Id__c = clientAvail.Id;
                createErrLogs.Account__c = objAccount1.Id;
                createErrLogs.Error_Description__c = 'Error Message: PlayList Update.';
                insert createErrLogs;
                
                CAS_Error_Log__c createErrLogs1 = new CAS_Error_Log__c();
                createErrLogs1.Object_Name__c = 'Client_Avail__c';
                createErrLogs1.Error_Category__c = 'Playlist Update';
                createErrLogs1.Record_Id__c = clientAvail1.Id;
                createErrLogs1.Account__c = objAccount1.Id;
                createErrLogs1.Error_Description__c = 'Error Message: PlayList Update.';
                insert createErrLogs1;
                
                List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('Error');
                
            }
            Test.stopTest();
                
                Client_Avail__History  ch = new Client_Avail__History();
                ch.Field = 'Recalculate_Playlist_Avails__c';
                ch.ParentId = listClientavails12[0].Id;
                insert ch;
                
                Set<String> possibleStatus = new Set<String>();
                Map<String,Datetime> caProcessedTimeMap = new Map<String,Datetime>();
                Map<String,Client_Avail__History> caHistoryMap = new Map<String,Client_Avail__History>();
                
                possibleStatus.add('Update Playlist');
                caProcessedTimeMap.put(ch.Field+ch.ParentId,ch.createdDate);
                caHistoryMap.put(listClientavails12[0].id,ch);
                
                List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1  = WB_PlaylistContentCA_Controller.getRecords('Error');
                //WB_PlaylistContentCA_Controller.getCADataList(possibleStatus, caProcessedTimeMap, caHistoryMap);
                
    }
    
    //Akash Test Method for getCAErrorList : Finish
    
    @isTest
    public static void testMethodStatusSuccess()
    {
        createTestData(true);
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
       
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        Test.startTest();
            
            insert listClientavails12;
            listClientavails12[0].Playlist__c = playlist123.id;
            listClientavails12[0].Recalculate_Playlist_Avails__c = '';
            //update listClientavails12[0];
            
            WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12;
            
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('Success');
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1  = WB_PlaylistContentCA_Controller.getRecords('test');
           
            /*playlistCtrl.setstatusValueToComp('Success');
            playlistCtrl.getstatusValueToComp();
            
            PageReference pageRef = PAGE.WB_PlaylistContentCA;
            Test.setCurrentPage(pageRef);
            playlistCtrl.Refresh();*/
        Test.stopTest();
        
    }
    
   /* @isTest
    public static void testMethodWithoutStatus()
    {
        createTestData(true);
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        Test.startTest();
            
            insert listClientavails12;
            listClientavails12[0].Playlist__c = playlist123.id;
            //update listClientavails12[0];
                 
            Datetime yesterday = Datetime.now().addDays(-4);
            WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
                
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12;
            
            Set<Id> caId = new Set<Id>();
            for(Client_Avail__c ca : listClientavails12){
                caId.add(ca.Id);
            }
            
            List<Client_Avail__c> caList = new List<Client_Avail__c>();
            caList = [Select Id,Name from Client_Avail__c where Id IN:caId];
            String Id1 = String.valueOf(caList[0].Id);
            String Id2 = String.valueOf(caList[1].Id);
             
            //WB_PlaylistContentCA_Controller playlistCtrl = new WB_PlaylistContentCA_Controller();
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1 = new List<WB_PlaylistContentCA_Controller.CAWrapper>();
            WB_PlaylistContentCA_Controller.CAWrapper wb1 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb1.videoVersion = '000000001';
            wb1.title ='Vampire Diaries S01';
            wb1.account='TestAccount';
            wb1.country='IndiaC';
            wb1.channel='VODi';
            wb1.format='SD';
            wb1.language='English';
            wb1.contentType='Season';
            wb1.languageType='Sub & Audio';
            wb1.caRecordId=Id1;
            wb1.caCategory='';
            wb1.price='';
            wb1.episodePrice='';
            wb1.episodePriceTier='';
            wb1.caName=caList[0].Name;
            wb1.action='action';
            wb1.selected=true;
            //wb1.processedTime=null;
            wb1.processedTime=system.now().addHours(1);
            wrapperCAlist1.add(wb1);
            
            WB_PlaylistContentCA_Controller.CAWrapper wb2 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb2.videoVersion = '000000001';
            wb2.title ='Vampire Diaries S02';
            wb2.account='TestAccount';
            wb2.country='IndiaC';
            wb2.channel='VODi';
            wb2.format='SD';
            wb2.language='English';
            wb2.contentType='Season';
            wb2.languageType='Sub & Audio';
            wb2.caRecordId=Id2;
            wb2.caCategory='';
            wb2.price='';
            wb2.episodePrice='';
            wb2.episodePriceTier='';
            wb2.caName=caList[1].Name;
            wb2.action='action';
            wb2.selected=true;
            wb2.processedTime=system.now();
            wrapperCAlist1.add(wb2);
            //wb1.priceTier='';
            
            wrapperCAlist1.sort();
            
            WB_PlaylistContentCA_Controller.reCalculateEpisodes(wrapperCAlist1);
            //List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist2  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            
            //playlistCtrl.setstatusValueToComp('In Progress');
            //playlistCtrl.getstatusValueToComp();
        Test.stopTest();
    }*/
    
    //Akash Test Method Start
    @isTest
    public static void testMethodreCalculateEpisodes()
    {
        
        createTestData(true);
        Test.startTest();
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail.Playlist__c = playlist123.id;
        //listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        insert listClientavails12;
            
        Datetime yesterday = Datetime.now().addDays(-4);
        WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
    
        //listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
        //listClientavails12[1].Recalculate_Playlist_Avails__c = '';
        //update listClientavails12;
        
        listClientavails12[0].Parent_Client_Avail__c = NULL;
        listClientavails12[0].Recalculate_Playlist_Avails__c = '';
        update listClientavails12;
        
        Set<Id> caId = new Set<Id>();
        for(Client_Avail__c ca : listClientavails12){
            caId.add(ca.Id);
        }
        
        List<Client_Avail__c> caList = new List<Client_Avail__c>();
        caList = [Select Id,Name from Client_Avail__c where Id IN:caId];
        String Id1 = String.valueOf(caList[0].Id);
        //String Id2 = String.valueOf(caList[1].Id);
        
        
        List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
        
        List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1 = new List<WB_PlaylistContentCA_Controller.CAWrapper>();
        WB_PlaylistContentCA_Controller.CAWrapper wb1 = new WB_PlaylistContentCA_Controller.CAWrapper();
        wb1.videoVersion = '000000001';
        wb1.title ='Vampire Diaries S01';
        wb1.account='TestAccount';
        wb1.country='IndiaC';
        wb1.channel='VODi';
        wb1.format='SD';
        wb1.language='English';
        wb1.contentType='Season';
        wb1.languageType='Sub & Audio';
        wb1.caRecordId=Id1;
        wb1.caCategory='';
        wb1.price='';
        wb1.episodePrice='';
        wb1.episodePriceTier='';
        wb1.caName=caList[0].Name;
        wb1.action='action';
        wb1.selected=true;
        //wb1.processedTime=null;
        wb1.processedTime=system.now().addHours(1);
        wrapperCAlist1.add(wb1);
        /*
        WB_PlaylistContentCA_Controller.CAWrapper wb2 = new WB_PlaylistContentCA_Controller.CAWrapper();
        wb2.videoVersion = '000000001';
        wb2.title ='Vampire Diaries S02';
        wb2.account='TestAccount';
        wb2.country='IndiaC';
        wb2.channel='VODi';
        wb2.format='SD';
        wb2.language='English';
        wb2.contentType='Season';
        wb2.languageType='Sub & Audio';
        wb2.caRecordId=Id1;
        wb2.caCategory='';
        wb2.price='';
        wb2.episodePrice='';
        wb2.episodePriceTier='';
        wb2.caName=caList[0].Name; 
        wb2.action='action';
        wb2.selected=true;
        wb2.processedTime=system.now();
        wrapperCAlist1.add(wb2);
        */
         
        
            wrapperCAlist1.sort();
           /* WB_PlaylistContentCA_Controller.getSeasonsWithMissingEpisodes();
            WB_PlaylistContentCA_Controller.getDraftEpisodesWithBroadcastDate();
            WB_PlaylistContentCA_Controller.getSeasonsWithNonTVCategory();
            WB_PlaylistContentCA_Controller.getSeasonsWithoutPlaylist();
            WB_PlaylistContentCA_Controller.getDayAfterEpisodesWithInvalidStartDate();
            WB_PlaylistContentCA_Controller.getNonDayAfterEpisodesWithInvalidStartDate();*/
            WB_PlaylistContentCA_Controller.reCalculateEpisodes(wrapperCAlist1);
        Test.stopTest();
    }
    //Akash Test Method Finish
    
    //Akash Test Method Start : commented 10 Jan
    /*
    @isTest
    public static void testMethodgetSeasonsWithMissingEp(){
        
        // -- MPM creation-- //
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
        // -- Title creation-- //
         t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Formats__c = 'SD';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        Insert t1;
        
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t1.id;
        playlist123.Playlist_Status__c = 'Active';
        insert playlist123;
        
        Country_1 = New Country__c();
        Country_1.Name = 'IndiaC';
        Country_1.Country_Code2__c = 'IA';
        Country_1.Country_Code__c = 'IA';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        insert Country_1;
        
        Language1 = New Language__c();
        Language1.Name = 'English';
        Language1.Language_Order__c = 1;
        insert Language1;
        
        listlocaltitles12= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t1.Name;
        LT.Title__c = t1.Id;
        LT.Country__c = Country_1.Id;
        LT.Language__c = Language1.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist123.id;        //Removed Comment
        LT.Price_Code__c = 'CheckPriceCode';
        LT.Category__c = 'TV Catalog';
        listlocaltitles12.add(LT);
        insert listlocaltitles12;
        
        listReleaseplan_1 = new List<Commercial_Avail__c>();
        releasePlan_1 = new Commercial_Avail__c();
        releasePlan_1.Channel__c = 'VODi';
        releasePlan_1.Title__c=t1.id;
        releasePlan_1.Languages__c = Language1.id;
        releasePlan_1.Country_Lookup__c = Country_1.id;
        releasePlan_1.Format__c = 'SD';
        releasePlan_1.Language_Type__c = 'Sub & Audio';
        releasePlan_1.Exclusive_Date__c = date.today()-200;
        releasePlan_1.Start_Date__c = date.today()-100;
        releasePlan_1.End_Date__c = date.today()+100;
        releasePlan_1.Rights_End__c=date.today()+200;
        releasePlan_1.Status__c = 'Confirmed';
        releasePlan_1.Playlist__C = playlist123.id;     //Removed Comment
        listReleaseplan_1.add(releasePlan_1);
        insert listReleaseplan_1;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, listReleaseplan_1[0], t1);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan_1[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today()+10;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        insert listClientavails12;
        
        Test.startTest();
        // WB_PlaylistContentCA_Controller.getSeasonsWithMissingEpisodes();
        Test.stopTest();
    }
    //Akash Test Method Finish
    */
    
    //Non Tv Category
    //Akash Test Method Start : Commented 10 Jan
    /*
    @isTest
    public static void testMethodgetNonTVCategory(){
        
        // -- MPM creation-- //
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
        // -- Title creation-- //
        t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Formats__c = 'SD';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        Insert t1;
        
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t1.id;
        playlist123.Playlist_Status__c = 'Active';
        insert playlist123;
        
        Country_1 = New Country__c();
        Country_1.Name = 'IndiaC';
        Country_1.Country_Code2__c = 'IA';
        Country_1.Country_Code__c = 'IA';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        insert Country_1;
        
        Language1 = New Language__c();
        Language1.Name = 'English';
        Language1.Language_Order__c = 1;
        insert Language1;
        
        listlocaltitles12= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t1.Name;
        LT.Title__c = t1.Id;
        LT.Country__c = Country_1.Id;
        LT.Language__c = Language1.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist123.id;        //Removed Comment
        LT.Price_Code__c = 'CheckPriceCode';
        LT.Category__c = 'TV Catalog';
        listlocaltitles12.add(LT);
        insert listlocaltitles12;
        
        listReleaseplan_1 = new List<Commercial_Avail__c>();
        releasePlan_1 = new Commercial_Avail__c();
        releasePlan_1.Channel__c = 'VODi';
        releasePlan_1.Title__c=t1.id;
        releasePlan_1.Languages__c = Language1.id;
        releasePlan_1.Country_Lookup__c = Country_1.id;
        releasePlan_1.Format__c = 'SD';
        releasePlan_1.Language_Type__c = 'Sub & Audio';
        releasePlan_1.Exclusive_Date__c = date.today()-200;
        releasePlan_1.Start_Date__c = date.today()-100;
        releasePlan_1.End_Date__c = date.today()+100;
        releasePlan_1.Rights_End__c=date.today()+200;
        releasePlan_1.Status__c = 'Confirmed';
        releasePlan_1.Playlist__C = playlist123.id;     //Removed Comment
        listReleaseplan_1.add(releasePlan_1);
        insert listReleaseplan_1;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, listReleaseplan_1[0], t1);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan_1[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today()+10;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'Catalog';
        clientAvail.Playlist__c = playlist123.id;
        listClientavails12.add(clientAvail);
        insert listClientavails12;
        
        Test.startTest();
         //WB_PlaylistContentCA_Controller.getSeasonsWithNonTVCategory();
        Test.stopTest();
    }
    //Akash Test Method Finish
    */
    
    //Akash Test Method Start : Commented 10 Jan
    /*
    @isTest
    public static void testMethodgetDraftEpisodedt(){
        
        // -- MPM creation-- //
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
        // -- Title creation-- //
         t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Episode';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        Insert t1;
        
        episodeTitle1 = new Title__c();
        episodeTitle1.Name = 'Vampire Diaries S01E01';
        episodeTitle1.Digital_Planning__c = 'Yes';
        episodeTitle1.Clear_to_Avail__c = true;
        episodeTitle1.Content_Type__c = 'Episode';
        episodeTitle1.Video_Version__c = '000000002';
        episodeTitle1.Global_Category__c = 'TV Catalog';
        episodeTitle1.MPM__c = Mpm.id;
        Insert episodeTitle1;
        
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t1.id;
        playlist123.Playlist_Status__c = 'Active';
        insert playlist123;
        
        Country_1 = New Country__c();
        Country_1.Name = 'IndiaC';
        Country_1.Country_Code2__c = 'IA';
        Country_1.Country_Code__c = 'IA';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        insert Country_1;
        
        Language1 = New Language__c();
        Language1.Name = 'English';
        Language1.Language_Order__c = 1;
        insert Language1;
        
        listlocaltitles12= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t1.Name;
        LT.Title__c = t1.Id;
        LT.Country__c = Country_1.Id;
        LT.Language__c = Language1.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist123.id;        //Removed Comment
        LT.Price_Code__c = 'CheckPriceCode';
        LT.Category__c = 'TV Day After US';
        listlocaltitles12.add(LT);
        
        Local_Title__c episodeLT = New Local_Title__c();
        episodeLT.Name = t1.Name;
        episodeLT.Title__c = episodeTitle1.Id;
        episodeLT.Country__c = Country_1.Id;
        episodeLT.Language__c = Language1.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Day After US';
        listlocaltitles12.add(episodeLT);
        
        insert listlocaltitles12;
        
        listReleaseplan_1 = new List<Commercial_Avail__c>();
        releasePlan_1 = new Commercial_Avail__c();
        releasePlan_1.Channel__c = 'VODi';
        releasePlan_1.Title__c=t1.id;
        releasePlan_1.Languages__c = Language1.id;
        releasePlan_1.Country_Lookup__c = Country_1.id;
        releasePlan_1.Format__c = 'SD';
        releasePlan_1.Language_Type__c = 'Sub & Audio';
        releasePlan_1.Exclusive_Date__c = date.today()-200;
        releasePlan_1.Start_Date__c = date.today()-100;
        releasePlan_1.End_Date__c = date.today()+100;
        releasePlan_1.Rights_End__c=date.today()+200;
        releasePlan_1.Status__c = 'Confirmed';
        releasePlan_1.Playlist__C = playlist123.id;     //Removed Comment
        listReleaseplan_1.add(releasePlan_1);
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle1.id;
        releasePlan2.Languages__c = Language1.id;
        releasePlan2.Country_Lookup__c = Country_1.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = system.today()-200;
        releasePlan2.Start_Date__c = system.today()-70;
        releasePlan2.End_Date__c = system.today()+70;
        releasePlan2.Rights_End__c=system.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan_1.add(releasePlan2);
        insert listReleaseplan_1;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, listReleaseplan_1[0], t1);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan_1[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today()+10;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Draft';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After US';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After US';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        clientAvail1.Status__c = 'Draft';
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After US';
        clientAvail1.Parent_Client_Avail__c = listClientavails12[0].id;
        listClientavails12.add(clientAvail1);
        insert listClientavails12;
        
        Test.startTest();
         //WB_PlaylistContentCA_Controller.getSeasonsWithMissingEpisodes();
         //WB_PlaylistContentCA_Controller.getDraftEpisodesWithBroadcastDate();
        // WB_PlaylistContentCA_Controller.getDayAfterEpisodesWithInvalidStartDate();
        Test.stopTest();
    }
    
    //Akash Test Method Finish
    */
    
    //Commented 10 Jan
    
    @isTest
    public static void testMethodWithoutStatus1()
    {
        createTestData(true);
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        Test.startTest();
            
            insert listClientavails12;
            listClientavails12[0].Playlist__c = playlist123.id;
            //update listClientavails12[0];
                 
            Datetime yesterday = Datetime.now().addDays(-4);
            WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
                
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12;
            
            Set<Id> caId = new Set<Id>();
            for(Client_Avail__c ca : listClientavails12){
                caId.add(ca.Id);
            }
            
            List<Client_Avail__c> caList = new List<Client_Avail__c>();
             caList = [Select Id,Name from Client_Avail__c where Id IN:caId];
            String Id1 = String.valueOf(caList[0].Id);
            String Id2 = String.valueOf(caList[1].Id);
             
            //WB_PlaylistContentCA_Controller playlistCtrl = new WB_PlaylistContentCA_Controller();
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1 = new List<WB_PlaylistContentCA_Controller.CAWrapper>();
            WB_PlaylistContentCA_Controller.CAWrapper wb1 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb1.videoVersion = '000000001';
            wb1.title ='Vampire Diaries S01';
            wb1.account='TestAccount';
            wb1.country='IndiaC';
            wb1.channel='VODi';
            wb1.format='SD';
            wb1.language='English';
            wb1.contentType='Season';
            wb1.languageType='Sub & Audio';
            wb1.caRecordId=Id1;
            wb1.caCategory='';
            wb1.price='';
            wb1.episodePrice='';
            wb1.episodePriceTier='';
            wb1.caName=caList[0].Name;
            wb1.action='action';
            wb1.selected=true;
            //wb1.processedTime=null;
            wb1.processedTime=system.now().addHours(1);
            wrapperCAlist1.add(wb1);
            
            WB_PlaylistContentCA_Controller.CAWrapper wb2 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb2.videoVersion = '000000001';
            wb2.title ='Vampire Diaries S02';
            wb2.account='TestAccount';
            wb2.country='IndiaC';
            wb2.channel='VODi';
            wb2.format='SD';
            wb2.language='English';
            wb2.contentType='Season';
            wb2.languageType='Sub & Audio';
            wb2.caRecordId=Id2;
            wb2.caCategory='';
            wb2.price='';
            wb2.episodePrice='';
            wb2.episodePriceTier='';
            wb2.caName=caList[1].Name;
            wb2.action='action';
            wb2.selected=true;
            wb2.processedTime=system.now().addHours(1);
            //wb2.processedTime=system.now();
            wrapperCAlist1.add(wb2);
            //wb1.priceTier='';
            
            wrapperCAlist1.sort();
            
            //WB_PlaylistContentCA_Controller.reCalculateEpisodes(wrapperCAlist1);
            //List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist2  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            
            //playlistCtrl.setstatusValueToComp('In Progress');
            //playlistCtrl.getstatusValueToComp();
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodWithoutStatus2()
    {
       createTestData(true);
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist123.id;
        contentlist.add(content2);
        insert contentlist;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today()+1;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        Test.startTest();
            
            insert listClientavails12;
            listClientavails12[0].Playlist__c = playlist123.id;
            //update listClientavails12[0];
                 
            Datetime yesterday = Datetime.now().addDays(-4);
            WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
                
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12;
            
            Set<Id> caId = new Set<Id>();
            for(Client_Avail__c ca : listClientavails12){
                caId.add(ca.Id);
            }
            
            List<Client_Avail__c> caList = new List<Client_Avail__c>();
             caList = [Select Id,Name from Client_Avail__c where Id IN:caId];
            String Id1 = String.valueOf(caList[0].Id);
            String Id2 = String.valueOf(caList[1].Id);
             
            //WB_PlaylistContentCA_Controller playlistCtrl = new WB_PlaylistContentCA_Controller();
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist1 = new List<WB_PlaylistContentCA_Controller.CAWrapper>();
            WB_PlaylistContentCA_Controller.CAWrapper wb1 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb1.videoVersion = '000000001';
            wb1.title ='Vampire Diaries S01';
            wb1.account='TestAccount';
            wb1.country='IndiaC';
            wb1.channel='VODi';
            wb1.format='SD';
            wb1.language='English';
            wb1.contentType='Season';
            wb1.languageType='Sub & Audio';
            wb1.caRecordId=Id1;
            wb1.caCategory='';
            wb1.price='';
            wb1.episodePrice='';
            wb1.episodePriceTier='';
            wb1.caName=caList[0].Name;
            wb1.action='action';
            wb1.selected=true;
            //wb1.processedTime=null;
            wb1.processedTime=system.now().addHours(-1);
            wrapperCAlist1.add(wb1);
            
            WB_PlaylistContentCA_Controller.CAWrapper wb2 = new WB_PlaylistContentCA_Controller.CAWrapper();
            wb2.videoVersion = '000000001';
            wb2.title ='Vampire Diaries S02';
            wb2.account='TestAccount';
            wb2.country='IndiaC';
            wb2.channel='VODi';
            wb2.format='SD';
            wb2.language='English';
            wb2.contentType='Season';
            wb2.languageType='Sub & Audio';
            wb2.caRecordId=Id2;
            wb2.caCategory='';
            wb2.price='';
            wb2.episodePrice='';
            wb2.episodePriceTier='';
            wb2.caName=caList[1].Name;
            wb2.action='action';
            wb2.selected=true;
            wb2.processedTime=system.now().addHours(1);
            //wb2.processedTime=system.now();
            wrapperCAlist1.add(wb2);
            //wb1.priceTier='';
            
            wrapperCAlist1.sort();
            
            //WB_PlaylistContentCA_Controller.reCalculateEpisodes(wrapperCAlist1);
            //List<WB_PlaylistContentCA_Controller.CAWrapper> wrapperCAlist2  = WB_PlaylistContentCA_Controller.getRecords('In Progress');
            
            //playlistCtrl.setstatusValueToComp('In Progress');
            //playlistCtrl.getstatusValueToComp();
        Test.stopTest();
    }
    
}