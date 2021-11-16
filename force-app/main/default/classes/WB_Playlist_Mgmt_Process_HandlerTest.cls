@isTest(SeeAllData=false)
public class WB_Playlist_Mgmt_Process_HandlerTest {

    public static Account objAccount1;
     public static Title__c t1;
     public static Title__c episodeTitle1;
     public static Title__c episodeTitle2;
     public static Title__c episodeTitle3;
     public static Playlist__c playlist123;
     public static Playlist__c playlist13;
     public static Language__c Language1;
     public static Country__c Country_1; 
     public static List<Local_Title__c> listlocaltitles12;
     public static List<Client_Avail__c> listClientavails12;
     static List<Pricing__c> lPricing5 = new List<Pricing__c>();
     public static List<Commercial_Avail__c> listReleaseplan_1;
     public static Commercial_Avail__c releasePlan_1;
     static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    
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
        episodeTitle1.Global_Category__c = 'TV Day After US';
        episodeTitle1.MPM__c = Mpm.id;
        Insert episodeTitle1;
        
        episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Vampire Diaries S01E02';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Formats__c = 'SD';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle2.Global_Category__c = 'TV Day After US';
        episodeTitle2.MPM__c = Mpm.id;
        Insert episodeTitle2;
        
        episodeTitle3 = new Title__c();
        episodeTitle3.Name = 'Vampire Diaries S01E03';
        episodeTitle3.Digital_Planning__c = 'Yes';
        episodeTitle3.Formats__c = 'SD';
        episodeTitle3.Clear_to_Avail__c = true;
        episodeTitle3.Content_Type__c = 'Episode';
        episodeTitle3.Video_Version__c = '000000004';
        episodeTitle3.Global_Category__c = 'TV Day After US';
        episodeTitle3.MPM__c = Mpm.id;
        Insert episodeTitle3;
        
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
        Test.startTest();
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
        LT.Playlist__C = playlist123.id;
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
        releasePlan_1.Playlist__C = playlist123.id;
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
        Test.stopTest();
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, listReleaseplan_1[0], t1);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan_1[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        
        countrySIDList.add(new Country_SID_Key__c(Name='IndiaC', Country_Code__c='IA',Country_Code2_c__c='IA',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
        
    }
    
    @isTest
    public static void testMethodStatusInProgress()
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
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After US';
        listClientavails12.add(clientAvail);
        
        
        insert listClientavails12;
        listClientavails12[0].Playlist__c = playlist123.id;
        update listClientavails12[0];
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        
        
        
        /*delete content2;
        
        WB_Batch_Playlist_Mgmt_Process c3 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c3,1);*/
        
        Playlist_Content__c content3 = new Playlist_Content__c();
        content3.Content_Title__c=episodeTitle2.id;
        content3.Playlist__c = playlist123.id;
        //contentlist.add(content3);
        insert content3;
        
        WB_Batch_Playlist_Mgmt_Process c4 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c4,1);
        
        /*WB_Playlist_Mgmt_Process_Handler objprocHandlerClass = new WB_Playlist_Mgmt_Process_Handler();
        objprocHandlerClass.CreateClientAvails(listClientavails12);*/
        
        
    }
    
    /* ----NEED TO FIX 29-Jan-2018
    @isTest
    public static void testMethodStatusInProgress2()
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
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After US';
        listClientavails12.add(clientAvail);
        
        
        insert listClientavails12;
        listClientavails12[0].Playlist__c = playlist123.id;
        
        update listClientavails12[0];
        
        listlocaltitles12[1].Parent_Local_Data__c = listlocaltitles12[0].id;
        update listlocaltitles12[1];
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[1].Id);
        clientAvail1.Start_Date__c = system.today();
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After US';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        clientAvail1.Parent_Client_Avail__c = listClientavails12[0].Id;
        listClientavails12.add(clientAvail1);
        insert listClientavails12[1];
        
        
        
                  
        WB_Batch_Playlist_Mgmt_Process c4 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c4,1);
        
       
        
       Playlist_Content__c content3 = new Playlist_Content__c();
        content3.Content_Title__c=episodeTitle2.id;
        content3.Playlist__c = playlist123.id;
        //contentlist.add(content3);
        //insert content3;
        
        
        
        WB_Playlist_Mgmt_Process_Handler objprocHandlerClass = new WB_Playlist_Mgmt_Process_Handler();
        objprocHandlerClass.CreateClientAvails(listClientavails12);
        
        List<Playlist_Content__c> pc = [Select Id,Content_Title__r.Name from Playlist_Content__c where Content_Title__c=:episodeTitle1.Id];
        system.debug('Content_Title__r.Name:'+pc[0].Content_Title__r.Name);
        delete pc[0];
        //delete content;
        //listClientavails12[0].Playlist__c =null;
        //listClientavails12[0].Recalculate_Playlist_Avails__c ='Update Playlist';
        //update listClientavails12[0];
        
        WB_Playlist_Mgmt_Process_Handler objprocHandlerClass1 = new WB_Playlist_Mgmt_Process_Handler();
        objprocHandlerClass1.CreateClientAvails(listClientavails12);
        //WB_Batch_Playlist_Mgmt_Process c3 = new WB_Batch_Playlist_Mgmt_Process();
       // database.executebatch(c3,1);
        
        
        
    }
    ----NEED TO FIX*/
    
   
}