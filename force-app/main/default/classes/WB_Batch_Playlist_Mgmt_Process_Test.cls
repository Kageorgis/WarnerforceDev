@isTest
private class WB_Batch_Playlist_Mgmt_Process_Test {
    public static List<Client_Avail__c> listClientavails;
    public static Playlist__c playlist1;
    public static Playlist__c playlist;
    public static Title__c episodeTitle;
    public static Commercial_Avail__c releasePlan1;
    public static Commercial_Avail__c releasePlan2;
    public static Local_Title__c episodeLT;
    public static List<Local_Title__c> listlocaltitles;
    public static List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
     public static Language__c Language;
     
    
    
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
        t.Formats__c='SD';
        Insert t;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c ='SD';
        Insert episodeTitle;
        
        Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        episodeTitle2.Formats__c ='SD';
        Insert episodeTitle2;
        
        playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Recalculate_Sequence__c = True ;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist.Recalculate_Sequence__c = True ;
        playlist1.Version_Number__c = 1;
        playlist1.Parent_Title__c = t.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist1.id;
        contentlist.add(content2);
        insert contentlist;
        
        Country__c Country = New Country__c();
        Country.Name = 'India';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.TV_Day_After_US_Offset__c = 2;
        Country.TV_Day_After_Local_Offset__c = 1;
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        listlocaltitles= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        episodeLT = New Local_Title__c();
        episodeLT.Name = t.Name;
        episodeLT.Title__c = episodeTitle.Id;
        episodeLT.Country__c = Country.Id;
        episodeLT.Language__c = Language.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Catalog';
        listlocaltitles.add(episodeLT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'VODi';
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()-100;
        releasePlan1.End_Date__c = date.today()+100;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        
        releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()-100;
        releasePlan2.End_Date__c = date.today()+100;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, listReleaseplan[0], t);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
        insert storefrontGoogle1;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist.id;
        clientAvail.Start_Date__c = date.today()+2;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail);
        if(flag)
        {
            Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
            clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
            clientAvail1.Storefront__c = storefrontGoogle1.Id;
            listClientavails.add(clientAvail1);
        }
        insert listClientavails;
        if(flag)
        {
            WB_ClientAvailPriceHandler.recursiveUpdate = true;
            listClientavails[1].Parent_Client_Avail__c = listClientavails[0].id;
            listClientavails[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails[1];
            WB_ClientAvailPriceHandler.recursiveUpdate = false;
        }
        
    }
    
    public static void setUpData1(Boolean flag){
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
        t.Global_Category__c = 'TV Catalog';
        t.Digital_Planning__c = 'Yes';
        t.Clear_to_Avail__c = true;
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.US_TV_Air_Date__c = system.today();
        t.Formats__c='SD';
        Insert t;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c ='SD';
        Insert episodeTitle;
        
        Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        episodeTitle2.Formats__c ='SD';
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
        playlist1.Parent_Title__c = t.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist1.id;
        contentlist.add(content2);
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
        
        listlocaltitles= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Category__c = 'TV Catalog';
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        episodeLT = New Local_Title__c();
        episodeLT.Name = t.Name;
        episodeLT.Title__c = episodeTitle.Id;
        episodeLT.Country__c = Country.Id;
        episodeLT.Language__c = Language.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Catalog';
        listlocaltitles.add(episodeLT);
        
        Insert listlocaltitles;
        
        releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'VODi';
        releasePlan1.Title__c=t.id;
        releasePlan1.Local_Title__c = listlocaltitles[0].Id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()-100;
        releasePlan1.End_Date__c = date.today()+100;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        
        releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()-100;
        releasePlan2.End_Date__c = date.today()+100;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        //listReleaseplan.add(releasePlan2);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, listReleaseplan[0], t);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
        insert storefrontGoogle1;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist.id;
        clientAvail.Start_Date__c = date.today()+2;
        clientAvail.Status__c = 'Tentative';
        listClientavails.add(clientAvail);
       
        insert listClientavails;
        
        Client_Avail__c ca = listClientavails[0]; 
        system.debug('ca.Commercial_Avail__r##########################'+listReleaseplan[0].Id);
        system.debug('ca.Commercial_Avail__r&&&&&&&&&&&&&##########################'+ca.Commercial_Avail__c);
         system.debug('ca.Commercial_Avail__r.Languages__c##########################'+ca.Commercial_Avail__r.Languages__c);
         
        listReleaseplan[0].Languages__c = Language.id;
        update listReleaseplan[0];
        
    }
    
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_InsertScenario1() {
        //Test.startTest();
            setUpData(false);
            listClientavails[0].Recalculate_Playlist_Avails__c = '';
            update listClientavails[0];
            String CRON_EXP = '0 0 0 15 3 ? *';
            Test.startTest();
            String jobId = System.schedule('schedule Season titles', CRON_EXP, new WB_Batch_Playlist_Mgmt_Process());
            system.assertNotEquals(jobId, null);
        test.stopTest();
        
    }
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_InsertScenario2() {
            
            setUpData(true);
            
            episodeLT.Category__c = 'TV Day After US';
            test.startTest();
            update episodeLT;
            String CRON_EXP = '0 0 0 15 3 ? *';
            
            WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
            database.executebatch(c2,1);
        test.stopTest();
        
    }
    
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_UpdatePlaylistScenario1() {
        
        setUpData(false);
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[0].Start_Date__c = date.today()+2;
        update listClientavails[0];
        
        test.startTest();
        listClientavails[0].Recalculate_Playlist_Avails__c = 'Update Playlist';
        update listClientavails[0];
        episodeLT.Category__c = 'TV Day After US';
        update episodeLT;
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        test.stopTest();
    }
    
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_UpdatePlaylistScenario2() {
        
        setUpData(true);
        
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[1].Recalculate_Playlist_Avails__c = '';
        update listClientavails;
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        
        List<Episode_Avails_Scheduler__c> listSetting  = [select id,Scheduler_Id__c,name from Episode_Avails_Scheduler__c];
        for( Episode_Avails_Scheduler__c settingrecord : listSetting){
            System.abortJob(settingrecord.Scheduler_id__c);
        }
        delete listSetting;
        
        test.startTest();
        
        listClientavails[0].Playlist__c = playlist1.id;
        update listClientavails[0];
        
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        test.stopTest();
        
    }
    
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_UpdateLocalDataScenario() {
        setUpData(false);
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[0].Start_Date__c = date.today()+2;
        update listClientavails;
        test.startTest();
        listClientavails[0].Recalculate_Playlist_Avails__c='Update Local Data';
        update listClientavails[0];
        Local_Title__c episodeLocalTitle = [Select id,Local_TV_Air_Date__c from Local_Title__c where Title__c =: episodeTitle.id limit 1];
        episodeLocalTitle.Local_TV_Air_Date__c = System.today();
        episodeLocalTitle.Category__c =  'TV Day After US';
        update episodeLocalTitle;
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        test.stopTest();
        
    }
    
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_UpdateLocalDataScenario2() {
        setUpData(false);
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        update listClientavails;
        test.startTest();
        listClientavails[0].Local_Data_Category_Picklist__c = 'TV Day After US';
        update listClientavails[0];
        Local_Title__c episodeLocalTitle = [Select id,Local_TV_Air_Date__c from Local_Title__c where Title__c =: episodeTitle.id limit 1];
        episodeLocalTitle.Local_TV_Air_Date__c = System.today();
        update episodeLocalTitle;
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        test.stopTest();    
        
    }
    /*----NEED TO FIX - 29Jan2018
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_UpdateLocalDataTVDaysScenario() {
        test.startTest();
        setUpData1(false);
        test.stopTest();
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        update listClientavails[0];
       
        List<Episode_Avails_Scheduler__c> listSetting  = [select id,Scheduler_Id__c,name from Episode_Avails_Scheduler__c];
        for( Episode_Avails_Scheduler__c settingrecord : listSetting){
            System.abortJob(settingrecord.Scheduler_id__c);
        }
        delete listSetting;
        listClientavails[0].Playlist__c = playlist1.id;
        listClientavails[0].Local_Data_Category_Picklist__c = 'TV Day After US';
        listClientavails[0].Recalculate_Playlist_Avails__c = 'Update Local Data';
        update listClientavails[0];
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        
        
    }
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_UpdateLocalDataTVDaysScenario1() {
        test.startTest();
        setUpData1(true);
        
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        //listClientavails[1].Avail_Type__c ='Automated';
        
        update listClientavails[0];
        //update listClientavails[1];
        //system.debug('listClientavails[1].Avail_Type__c>>>>>>'+listClientavails[1].Avail_Type__c);
        List<Episode_Avails_Scheduler__c> listSetting  = [select id,Scheduler_Id__c,name from Episode_Avails_Scheduler__c];
        for( Episode_Avails_Scheduler__c settingrecord : listSetting){
            System.abortJob(settingrecord.Scheduler_id__c);
        }
        delete listSetting;
        listClientavails[0].Playlist__c = playlist.id;
        //listClientavails[0].Local_Data_Category_Picklist__c = 'TV Day After US';
        //listClientavails[0].Recalculate_Playlist_Avails__c = 'Update Local Data';
        update listClientavails[0];
        test.stopTest();
        List<Client_Avail__c> rp = [Select Commercial_Avail__r.Languages__c from Client_Avail__c where id=:listClientavails[0].Id];
        for(Client_Avail__c rp1 : rp){
            system.debug('RP Laguage:'+rp1.Commercial_Avail__r.Languages__c);
        }
        //for(Local_Title__c lt : [Select id,Title__c,Name,Language__r.Name,Country__c,Local_BD_Release_Date__c,Local_TV_Air_Date__c,  //Local_TV_Air_Date_Audio__c,Local_TV_Air_Date_Sub__c,
                   //         Local_Category__c,Country__r.TV_Day_After_US_Offset__c,Country__r.TV_Day_After_Local_Offset__c 
            //FROM Local_Title__c]){
             //   system.debug('Language***************'+lt.Language__r.Name);
                
            //}
         //List<Client_Avail__c> caList = [SELECT ID,Name,Recalculation_Status__c FROM Client_Avail__c WHERE Recalculate_Playlist_Avails__c =:'Insert' and Recalculation_Status__c = false];   
        //system.debug('CA LIST :'+caList);
       
         
         
        WB_Playlist_Mgmt_Process_Handler objprocHandlerClass = new WB_Playlist_Mgmt_Process_Handler();
        objprocHandlerClass.CreateClientAvails(listClientavails);
        //WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        //database.executebatch(c2,1);
        
        
        
    }
    ----NEED TO FIX 29Jan2018-----*/
    public static testMethod void WB_TriggerHandlerDateOverlapClientAvail_TestMethod1() {
        
        setUpData(true);
        test.startTest();
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[0].Title__C=null;
        listClientavails[0].Local_Title__c=null;
        listClientavails[0].Start_Date__c = listClientavails[0].Start_Date__c + 10;
        listClientavails[0].End_Date__c = listClientavails[0].End_Date__c - 9;
        listClientavails[0].Episode_Price_Tier__c = '123';
        listClientavails[1].Recalculate_Playlist_Avails__c = '';
        listClientavails[1].Parent_Client_Avail__c = listClientavails[0].id;
        update listClientavails;
        test.stopTest();
        
    }
    
    public static testMethod void WB_TriggerHandlerDateOverlapClientAvail_TestMethod2() {
        SetupBasicData();
        test.starttest();
        listClientavails[0].Recalculate_Playlist_Avails__c = '';
        update listClientavails;

        system.debug('*************listlocaltitles*************'+listlocaltitles);
        test.stoptest();

    }
    
    public static testMethod void WB_TriggerHandlerDateOverlapClientAvail_TestMethod3() {
        SetupBasicData();
        Country__c country = [Select id,name from Country__c];
        country.name = 'USA';
        update country;
        episodeTitle.Global_Category__c = 'TV Day After US ';
        update episodeTitle; 
        test.starttest();
        
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[0].Status__c = 'Tentative';
        update listClientavails;
        listlocaltitles[1].Local_TV_Air_Date__c = system.Today()+1;
        update listlocaltitles[1];
        test.stoptest();
    }
    
    public static testMethod void WB_TriggerHandlerDateOverlapClientAvail_TestMethod4() {
        SetupBasicData();
        Country__c country = [Select id,name from Country__c];
        country.name = 'USA';
        update country;
        playlist.name = 'test playlist 1';
        update playlist;
        episodeTitle.Global_Category__c = 'TV Day After US ';
        update episodeTitle; 
        test.starttest();
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[0].Status__c = 'Tentative';
        listClientavails[0].Local_Data_Category_Picklist__c = 'TV Day After US';
        update listClientavails;
        listlocaltitles[1].Local_TV_Air_Date__c = system.Today()+1;
        update listlocaltitles[1];
        playlist.Total_Playlist_Content__c = 4;
        update playlist;
        test.stoptest();
    }
    //START: ER-820 Post Implementation Changes
    public static testMethod void WB_TriggerHandlerDateOverlapClientAvail_CalculateAPODate(){
                /* -- MPM creation-- */
        listlocaltitles= new List<Local_Title__c>();
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
        t.Formats__c='SD';
        Insert t;
        
        Country__c Country = New Country__c();
        Country.Name = 'Test';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c = 'SD';
        Insert episodeTitle;
        
        playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist1.Version_Number__c = 1;
        playlist1.Parent_Title__c = t.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
    
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        insert content;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today()-110;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        Local_Title__c LT1 = New Local_Title__c();
        LT1.Name = episodeTitle.Name;
        LT1.Local_Theatrical_Release_Date__c = date.today()-110;
        LT1.Title__c = episodeTitle.Id;
        LT1.Country__c = Country.Id;
        LT1.Language__c = Language.Id;
        LT1.Local_TV_Air_Date__c = System.today()+2;
        listlocaltitles.add(LT1);
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'EST';
        //Trupti
        releasePlan1.APO__c = 'Yes';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+25;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        
        releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'EST';
        //Trupti
        releasePlan2.APO__c = 'Yes';
        releasePlan2.Title__c=episodeTitle.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()-100;
        releasePlan2.End_Date__c = date.today()+100;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        insert listReleaseplan;
         
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        
        
        update storefrontGoogle1;

        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.APO_Date__c = date.today()-200;
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
        clientAvail1.Title__c = episodeTitle.id;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.APO__c = 'Yes';
        clientAvail1.APO_Date__c = date.today()-200;
        clientAvail1.Status__c = 'Confirmed';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail.Local_Title__c = listlocaltitles[1].id;
        listClientavails.add(clientAvail1);
        

        //insert listClientavails;
        
       
        insert listClientavails;
        //Calculate APO Date
        for(Client_Avail__c c : listClientavails){
            c.APO_Date__c = date.today() + 5;
        }
        try{
            update listClientavails;
        }
        catch(Exception e){
        
            Boolean expectedExceptionThrown =  e.getMessage().contains('Pre-Order date can\'t be changed when APO flag is Yes.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        test.startTest();
        List<Client_Avail__c> listClientavails1 = [select id from Client_Avail__c];
        
        for(Client_Avail__c c : listClientavails1){
           c.APO_Date_Override__c = date.today()-110;
        }
        update listClientavails1;
        
        for(Client_Avail__c c : listClientavails1){
            c.APO_Date_Override__c = null;
            c.APO_Days_Override__c = 5;
        }
        update listClientavails1;
        
        for(Client_Avail__c c : listClientavails1){
            c.APO_Date_Override__c = null;
            c.APO_Days_Override__c = null;
        }
        update listClientavails1;

        //Calculate Suppresion date override
        
        for(Client_Avail__c c : listClientavails1){
            c.Suppression_Date_Override__c = date.today();
        }
        update listClientavails1;

        //Remove APO fields
        for(Client_Avail__c c : listClientavails1){
            c.APO__c = '';
        }
        update listClientavails1;

        test.stopTest();
        
    }
    //END - ER-820 Post Implementation Changes
    public static testMethod void WB_TriggerHandlerDateOverlapClientAvail_Exception() {
        SetupBasicData();
        Country__c country = [Select id,name from Country__c];
        country.name = 'USA';
        update country;
        episodeTitle.Global_Category__c = 'TV Day After US '; 
        update episodeTitle; 
        test.starttest();
        listClientavails[0].Recalculate_Playlist_Avails__c='';
        listClientavails[0].Status__c = 'Confirmed';
        listClientavails[1].Parent_Client_Avail__c = listClientavails[0].id;
        
        try{
            update listClientavails;
            listlocaltitles[1].Local_TV_Air_Date__c = system.Today()+1;
            update listlocaltitles[1];
        }
        catch(Exception e)
        {
            system.debug('message================='+e.getmessage());
            Boolean stringMatch = e.getmessage().contains('Episode Avails cannot be confirmed with a TBD price tier');
            system.assertEquals(true, stringMatch);
        }
        
        test.stoptest();
    }
    
    public static testMethod void WB_Batch_Playlist_Mgmt_Process_TriggerDateOverlapIncreaseCov() {
        
        test.startTest();
        setUpData(false);
        WB_Batch_Playlist_Mgmt_Process c2 = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c2,1);
        test.stopTest();
        listClientavails[0].Start_Date__c = listClientavails[0].Start_Date__c + 1;
        listClientavails[0].End_Date__c = listClientavails[0].End_Date__c - 1;
        listClientavails[0].Episode_Price_Tier__c = '123';
        update listClientavails[0];
    }
    
    public static void SetupBasicData(){
        /* -- MPM creation-- */
        listlocaltitles= new List<Local_Title__c>();
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
        t.Formats__c ='SD';
        Insert t;
        
        Country__c Country = New Country__c();
        Country.Name = 'Test';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c ='SD';
        Insert episodeTitle;
        
        playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist1.Version_Number__c = 1;
        playlist1.Parent_Title__c = t.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
    
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        insert content;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        Local_Title__c LT1 = New Local_Title__c();
        LT1.Name = episodeTitle.Name;
        LT1.Title__c = episodeTitle.Id;
        LT1.Country__c = Country.Id;
        LT1.Language__c = Language.Id;
        LT1.Local_TV_Air_Date__c = System.today()+2;
        listlocaltitles.add(LT1);
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'VODi';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+25;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        
        releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()-100;
        releasePlan2.End_Date__c = date.today()+100;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
        clientAvail1.Title__c = episodeTitle.id;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail.Local_Title__c = listlocaltitles[1].id;
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail1);
        
        insert listClientavails;
        
        listlocaltitles[1].Parent_Local_Data__c = listlocaltitles[0].id;
        update listlocaltitles[1];
        
    }
    
     public static void episodeCA(){
        /* -- MPM creation-- */
        listlocaltitles= new List<Local_Title__c>();
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
        t.Formats__c ='SD';
        Insert t;
        
        Country__c Country = New Country__c();
        Country.Name = 'Test';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c ='SD';
        Insert episodeTitle;
        
        playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist1.Version_Number__c = 1;
        playlist1.Parent_Title__c = t.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
    
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        insert content;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        Local_Title__c LT1 = New Local_Title__c();
        LT1.Name = episodeTitle.Name;
        LT1.Title__c = episodeTitle.Id;
        LT1.Country__c = Country.Id;
        LT1.Language__c = Language.Id;
        LT1.Local_TV_Air_Date__c = System.today()+2;
        listlocaltitles.add(LT1);
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'VODi';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+25;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        
        releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()-100;
        releasePlan2.End_Date__c = date.today()+100;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist.id;
        clientAvail.Avail_Type__c = 'Automated'; 
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
        clientAvail1.Title__c = episodeTitle.id;
        clientAvail1.Commercial_Avail__c = clientAvail.Commercial_Avail__c;
        clientAvail1.Client__c = clientAvail.Client__c;
        clientAvail1.End_Date__c = clientAvail.End_Date__c;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail.Local_Title__c = listlocaltitles[1].id;
        listClientavails.add(clientAvail1);
        
        insert listClientavails;
        WB_Playlist_Mgmt_Process_Handler plyHandler = new WB_Playlist_Mgmt_Process_Handler();
        plyHandler.CreateClientAvails(listClientavails);
        listlocaltitles[1].Parent_Local_Data__c = listlocaltitles[0].id;
        update listlocaltitles[1];
        
    }
    
}