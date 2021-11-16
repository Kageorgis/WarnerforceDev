@isTest
private class WB_ClientAvailPriceHandlerTest {
    
    static List<Account> accList = new List<Account>();
    static List<Title__c> titleList = new List<Title__c>();
    static List<Country__c> cList = new List<Country__c>();
    static List<Agreement__c> agreementList = new List<Agreement__c>();
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
     public static List<Commercial_Avail__c> listReleaseplan;
     public static Title__c t;
     public static Title__c episodeTitle;
     public static Language__c Language;
     public static Country__c Country; 
     
      public static Account objAccount1;
     public static Title__c t1;
     public static Title__c episodeTitle1;
     public static Playlist__c playlist123;
     public static Playlist__c playlist13;
     public static Language__c Language1;
     public static Country__c Country_1; 
     public static List<Local_Title__c> listlocaltitles12;
    public static List<Client_Avail__c> listClientavails12;
     static List<Pricing__c> lPricing5 = new List<Pricing__c>();
     public static List<Commercial_Avail__c> listReleaseplan_1;
      public static Commercial_Avail__c releasePlan_1;
      
      
      
   public static void setUpData1(Boolean flag){
       MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
      objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
         t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        t1.Formats__c = 'SD';
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
        
         Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Vampire Diaries S01E02';
        episodeTitle2.Digital_Planning__c = 'Yes';
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
        
        playlist13 = new Playlist__c();
        playlist13.name = 'test playlist1';
        playlist13.Version_Number__c = 1;
        playlist13.Parent_Title__c = t1.id;
        playlist13.Playlist_Status__c = 'Active';
        insert playlist13;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle1.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist13.id;
        contentlist.add(content2);
        insert contentlist;
        
         Country_1 = New Country__c();
        Country_1.Name = 'India';
        Country_1.Country_Code2__c = 'IN';
        Country_1.Country_Code__c = 'IND';
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
        pricing5.Channel__c='EST';
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
        pricing51.Channel__c='EST';
        pricing51.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing51.Price_Tier__c ='123';
        pricing51.Episode_Price_Tier__c='89.9';
        pricing51.Format__c='SD';
        lPricing5.add(pricing51);
        
        Pricing__c pricing_ep = new Pricing__c();
        pricing_ep.Name = 'CheckPriceCode1';
        pricing_ep.Account__c = objAccount1.id;
        pricing_ep.Country__c = Country_1.id;
        pricing_ep.Channel__c='EST';
        pricing_ep.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing_ep.Price_Tier__c ='reprice13';
        //pricing_ep.Episode_Price_Tier__c='89.9';
        pricing_ep.Format__c='SD';
        lPricing5.add(pricing_ep);
        
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
        releasePlan_1.Channel__c = 'EST';
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
        releasePlan2.Channel__c = 'EST';
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
        
        
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
    }
    

private static testMethod void CAPSeasonCreatedEpisode_1() {
        setUpData1(true);
        
        test.startTest();
        
         WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Playlist__c = playlist123.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        //insert clientAvail;
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
            //clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Start_Date__c = system.today()+1;
            clientAvail1.End_Date__c = system.today()+70;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price_Tier_Text__c = 'reprice12';
            //clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
         //clientAvail1.Episode_Price_Tier__c = 'reprice12';
        listClientavails12.add(clientAvail1);
            //insert clientAvail;
            
             insert listClientavails12;
             WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
            
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12[1];
            
            Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = listClientavails12[0].id,Effective_Date__c=system.today()+5,
            Price_Code__c='CheckPriceCode',Type__c='Reprice',Category__c = 'Catalog',
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap1);
        insert cap1;
            
         WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
        try{
            WB_ClientAvailPriceHandler.recursiveInsert = false;
            WB_ClientAvailPriceHandler.isCADateChange = false; 
            //cap1.Effective_Date__c = system.today()+9;
           delete cap1;
        }
        catch(Exception e){
            system.debug('**********Exception********* '+e.getmessage());
            String message = e.getmessage();
        } 
        test.stoptest();
        
        
    }
   
  public static void setUpData(Boolean flag){
       MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
      objAccount = TestUtil.initAccount();
        objAccount.Type='Global';
        insert objAccount;
        
         t = new Title__c();
        t.Name = 'Test Title';
        t.Digital_Planning__c = 'Yes';
        t.Clear_to_Avail__c = true;
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.US_TV_Air_Date__c = system.today();
        t.Formats__c = 'SD';
        Insert t;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        Insert episodeTitle;
        
         Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        Insert episodeTitle2;
        
        playlist12 = new Playlist__c();
        playlist12.name = 'test playlist';
        playlist12.Version_Number__c = 1;
        playlist12.Parent_Title__c = t.id;
        playlist12.Playlist_Status__c = 'Active';
        insert playlist12;
        
        playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist1.Version_Number__c = 1;
        playlist1.Parent_Title__c = t.id;
        playlist1.Playlist_Status__c = 'Active';
        insert playlist1;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist12.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist1.id;
        contentlist.add(content2);
        insert contentlist;
        
         Country = New Country__c();
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
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist12.id;
        LT.Price_Code__c = 'Direct To Video Catalog2';
        listlocaltitles.add(LT);
        
        Local_Title__c episodeLT = New Local_Title__c();
        episodeLT.Name = t.Name;
        episodeLT.Title__c = episodeTitle.Id;
        episodeLT.Country__c = Country.Id;
        episodeLT.Language__c = Language.Id;
        episodeLT.Local_TV_Air_Date__c = date.today();
        episodeLT.Parent_Local_Data__c=LT.id;
        episodeLT.Category__c = 'TV Catalog';
        listlocaltitles.add(episodeLT);
        
        Insert listlocaltitles;
        
         listReleaseplan = new List<Commercial_Avail__c>();
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
        releasePlan1.Playlist__C = playlist12.id;
        listReleaseplan.add(releasePlan1);
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = system.today()-200;
        releasePlan2.Start_Date__c = system.today()-70;
        releasePlan2.End_Date__c = system.today()+70;
        releasePlan2.Rights_End__c=system.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, listReleaseplan[0], t);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
    }
    
    
    private static testMethod void CAPSeasonCreatedEpisode1() {
        setUpData(true);
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist12.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
         clientAvail.Episode_Price_Tier__c = 'reprice12';
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
            //clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Start_Date__c = system.today()+1;
            clientAvail1.End_Date__c = system.today()+70;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price_Tier_Text__c = 'reprice12';
         //clientAvail1.Episode_Price_Tier__c = 'reprice12';
            listClientavails.add(clientAvail1);
      
        insert listClientavails;
       
            listClientavails[1].Parent_Client_Avail__c = listClientavails[0].id;
            listClientavails[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails[1];
        test.startTest();
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='VODi';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='reprice2';
        pricing1.Episode_Price_Tier__c='test1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing3= new Pricing__c();
        pricing3.Name = 'Direct To Video Catalog3';
        pricing3.Account__c = objAccount.id;
        pricing3.Country__c = Country.id;
        pricing3.Channel__c='VODi';
        pricing3.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing3.Price_Tier__c ='reprice3';
        pricing3.Episode_Price_Tier__c='test3';
        pricing3.Format__c='SD';
        lPricing.add(pricing3);
        
        Pricing__c pricing4= new Pricing__c();
        pricing4.Name = 'Direct To Video Catalog4';
        pricing4.Account__c = objAccount.id;
        pricing4.Country__c = Country.id;
        pricing4.Channel__c='VODi';
        pricing4.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing4.Price_Tier__c ='reprice4';
        pricing4.Episode_Price_Tier__c='test4';
        pricing4.Format__c='SD';
        lPricing.add(pricing4);
        
        
      Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='VODi';
        pricing1.Content_Type__c='Season';
        //pricing2.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing2.Price_Tier__c ='reprice2';
        pricing2.Episode_Price_Tier__c='test1';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        
        
        insert lPricing;
        
        for(Pricing__c pc:lPricing){
          system.debug('###Pricing:'+pc);  
        }
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false; 
        
        Client_Avail_Price__c cap3 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+5,
            Price__c=10.99,Episode_Price__c=2.99,Type__c='Reprice',Category__c = 'Catalog',
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap3);
        insert cap3;
       
        List<Client_Avail__c> caRecs = [Select Id,Playlist__c,Parent_Client_Avail__c,Start_Date__c,End_Date__c,Price_Tier_Text__c,Episode_Price_Tier__c,Local_Data_Category_Picklist__c,Commercial_Avail__c,Client__c,Local_Title__c,Local_Title__r.Title__c,(Select Id,Client_Avail__c,Pricing__c,Price__c,Local_Data_Price_Code__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Effective_Date__c,Expiry_Date__c,Title_Content_Type__c,Category__c,Type__c from Client_Avail_Prices__r) from Client_Avail__c];
        for(Client_Avail__c c :caRecs){
            system.debug('## Client_Avail__c:'+c);
            for(Client_Avail_Price__c cap : c.Client_Avail_Prices__r){
                system.debug('## Client Avail Pricing:'+cap);
            }
        }
         WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
        try{
            WB_ClientAvailPriceHandler.recursiveInsert = false;
            WB_ClientAvailPriceHandler.isCADateChange = false; 
           delete cap3;
        }
        catch(Exception e){
            system.debug('**********Exception********* '+e.getmessage());
            String message = e.getmessage();
        } 
        
        test.stoptest();
    }
    
    private static testMethod void CAPSeasonCreatedEpisode2() {
        setUpData(true);
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist12.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
         clientAvail.Episode_Price_Tier__c = 'reprice12';
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
            //clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Start_Date__c = system.today()+1;
            clientAvail1.End_Date__c = system.today()+60;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price_Tier_Text__c = 'reprice12';
         //clientAvail1.Episode_Price_Tier__c = 'reprice12';
            listClientavails.add(clientAvail1);
      
        insert listClientavails;
       
            listClientavails[1].Parent_Client_Avail__c = listClientavails[0].id;
            listClientavails[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails[1];
         test.startTest();  
            
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='VODi';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='reprice2';
        pricing1.Episode_Price_Tier__c='test1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing3= new Pricing__c();
        pricing3.Name = 'Direct To Video Catalog3';
        pricing3.Account__c = objAccount.id;
        pricing3.Country__c = Country.id;
        pricing3.Channel__c='VODi';
        pricing3.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing3.Price_Tier__c ='reprice3';
        pricing3.Episode_Price_Tier__c='test3';
        pricing3.Format__c='SD';
        //lPricing.add(pricing3);
        
        Pricing__c pricing4= new Pricing__c();
        pricing4.Name = 'Direct To Video Catalog4';
        pricing4.Account__c = objAccount.id;
        pricing4.Country__c = Country.id;
        pricing4.Channel__c='VODi';
        pricing4.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing4.Price_Tier__c ='reprice4';
        pricing4.Episode_Price_Tier__c='test4';
        pricing4.Format__c='SD';
        lPricing.add(pricing4);
        
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='VODi';
        //pricing1.Content_Type__c='Season';
        pricing2.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing2.Price_Tier__c ='reprice2';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        Pricing__c pricing_Ep_1 = new Pricing__c();
        pricing_Ep_1.Name = 'CheckPriceCode';
        pricing_Ep_1.Account__c = objAccount.id;
        pricing_Ep_1.Country__c = Country.id;
        pricing_Ep_1.Channel__c='VODi';
        pricing_Ep_1.Content_Type__c='Episode';
        pricing_Ep_1.Price_Tier__c ='test1';
        pricing_Ep_1.Format__c='SD';
        //lPricing.add(pricing_Ep_1);
        
        insert lPricing;
        
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false; 
        
        Client_Avail_Price__c cap3 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+3,
            Price__c=10.99,Episode_Price__c=2.99,Type__c='Reprice',Category__c = 'Catalog',
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap3);
        insert cap3;
        
		//,Episode_Price_Tier__c='test1'
        Client_Avail_Price__c cap4 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+20,
            Price_Tier__c='reprice2',Type__c='Reprice',Category__c = 'Catalog');
        
        insert cap4; 
        
         cap4.Price_Tier__c='reprice4';
         cap4.Episode_Price_Tier__c = WB_PriceUtility.PRICE_TIER_TBD;
         update cap4;
         
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
         
        test.stoptest();
    }
    
    private static testMethod void CAPSeasonCreatedEpisode3() {
        setUpData(true);
        
         system.debug('#### in third method...');
        listClientavails = new List<Client_Avail__c>();
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist12.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
         clientAvail.Episode_Price_Tier__c = 'reprice12';
         clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
         insert clientAvail;
         test.startTest();
          
        //listClientavails.add(clientAvail);
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
            //clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Start_Date__c = system.today()+1;
            clientAvail1.End_Date__c = system.today()+60;
            //clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price_Tier_Text__c = 'reprice12';
         //clientAvail1.Episode_Price_Tier__c = 'reprice12';
         clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            insert clientAvail1;
                       
            
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='VODi';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='reprice2';
        pricing1.Episode_Price_Tier__c='test1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing3= new Pricing__c();
        pricing3.Name = 'Direct To Video Catalog3';
        pricing3.Account__c = objAccount.id;
        pricing3.Country__c = Country.id;
        pricing3.Channel__c='VODi';
        pricing3.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing3.Price_Tier__c ='reprice3';
        pricing3.Episode_Price_Tier__c='test3';
        pricing3.Format__c='SD';
        lPricing.add(pricing3);
        
        Pricing__c pricing4= new Pricing__c();
        pricing4.Name = 'Direct To Video Catalog4';
        pricing4.Account__c = objAccount.id;
        pricing4.Country__c = Country.id;
        pricing4.Channel__c='VODi';
        pricing4.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing4.Price_Tier__c ='reprice4';
        pricing4.Episode_Price_Tier__c='test4';
        pricing4.Format__c='SD';
        lPricing.add(pricing4);
        
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='VODi';
        pricing1.Content_Type__c='Season';
        //pricing2.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing2.Price_Tier__c ='reprice2';
        pricing2.Episode_Price_Tier__c='test1';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        
        
        insert lPricing;
        try{
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = clientAvail.id,Effective_Date__c=system.today()+5,
            Price_Code__c='Direct To Video Catalog2',Type__c='Reprice',Category__c = 'Catalog',
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
         insert cap1;  
         clientAvail.Status__c = 'confirmed';
         update clientAvail;
            Client_Avail_Price__c cap2 = new Client_Avail_Price__c(Client_Avail__c = clientAvail.id,Effective_Date__c=system.today()+15,Price__c=8.0,
           Expiry_Date__c = system.today()+20,Category__c = 'Catalog',recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'TEMP'));
        system.debug('Client Avail Pricing : '+cap2);
        insert cap2;
        } catch(Exception ex){
            
        }
        clientAvail.Start_Date__c = system.today()+21;
        update clientAvail;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false; 
        
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
         
        test.stoptest();
    }
    
    private static void insertTestData(Boolean SeasonTitles){
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        System.debug('###Mpm:'+Mpm);
        
        for(Integer i = 0; i<count; i++)
        {
            Account acct = TestUtil.createAccount('Google Acc'+i);
            acct.Customer_Focus__c = 'Active';
            accList.add(acct); 
        }
        insert accList;
        
        for(integer i = 0; i<count; i++)
        {
            Title__c title1 = TestUtil.initTitle('TestGoogle'+i, '600004754'+i);
            if(SeasonTitles)
            {
                title1.Content_Type__c = 'Season';
                if(i == 1)
                    title1.Content_Type__c = 'Episode';
            }
            else
                title1.Content_Type__c = 'Feature';
            
            titleList.add(title1);
        }
        insert titleList;
        
        Country__c country1 = TestUtil.initCountry('Colombia', 'CO', 'COL');
            Country__c country2 = TestUtil.initCountry('China', 'CN', 'CHN');
            Country__c country3 = TestUtil.initCountry('Canada', 'CA', 'CAN');
            cList.add(country1);
            cList.add(country2);
            cList.add(country3);
       
        insert cList;
        
        for(Integer i = 0; i<count; i++)
        {
            Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
            lList.add(languageFrench);
        }
        insert lList;
        
        for(Integer i=0; i<count; i++)
        {
            Local_Title__c localTitle = TestUtil.initLocalTitle(lList[i].Id, cList[i].Id);
            localTitle.Title__c = titleList[i].id;
            lTitle.add(localTitle);
        }
        insert lTitle;
        
        for(Integer i=0; i<count; i++)
        {
            Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(titleList[i].Id, lTitle[i].Id, cList[i].Id, lList[i].Id);
            CommercialAvail.Start_Date__c = system.today()-70;
            CommercialAvail.End_Date__c = system.today()+70;
            cAvailList.add(CommercialAvail);
        }
        insert cAvailList;
        
        for(Integer i=0; i<count; i++)
        {
            Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(accList[i].Id, cList[i].Id, cAvailList[i], titleList[i]);
            aList.add(storefrontGoogle1);
        }
        insert aList;
        
        for(Integer i=0; i<count; i++)
        {
            Client_Avail__c clientAvail = TestUtil.initClientAvail(accList[i].Id, cAvailList[i], lTitle[i].Id);
            clientAvail.Start_Date__c = system.today()-70;
            clientAvail.End_Date__c = system.today()+70;
            clAvailList.add(clientAvail);
        
        }
        insert clAvailList;
        clAvailList[1].Parent_Client_Avail__c = clAvailList[0].id;
        update clAvailList[1];
        
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='China', Country_Code__c='CHN',Country_Code2_c__c='CN',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='Canada', Country_Code__c='CAN',Country_Code2_c__c='CA',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        
        insert countrySIDList;
    }
    
  
    private static testMethod void CAPInsertANDUpdateTestCase() {
        
        insertTestData(true);
        test.startTest();
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        pricing.Price_Tier__c = 'test1';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='Reprice';
        lPricing.add(pricing);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing1.Name = 'Direct To Video Catalog';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        pricing1.Price_Tier__c ='test1';
        pricing1.Episode_Price_Tier__c='Reprice';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
        Pricing__c pricing4 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing4.Name = 'Direct To Video Catalog 1';
        pricing4.Channel__c='VODc';
        pricing4.Content_Type__c='Season';
        pricing4.Price_Tier__c ='Reprice4';
        pricing4.Episode_Price_Tier__c='Reprice';
        pricing4.Format__c='HD';
        lPricing.add(pricing4);
        
        Pricing__c pricing2 = TestUtil.createPricing(accList[2].Id, cList[2].Id,null);
        pricing2.Name = 'Direct To Video Catalog';
        pricing2.Channel__c='VODc';
        pricing2.Content_Type__c='Season';
        pricing2.Price_Tier__c = 'test1';
        pricing2.Episode_Price_Tier__c='Reprice';
        pricing2.Format__c='HD';
        lPricing.add(pricing2);
        
        Pricing__c pricing3 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing3.Name = 'Direct To Video Catalog Test';
        pricing3.Channel__c='VODc';
        pricing3.Content_Type__c='Season';
        pricing3.Price_Tier__c ='test1';
        pricing3.Episode_Price_Tier__c='Reprice';
        pricing3.Format__c='HD';
        lPricing.add(pricing3);
        
        Pricing__c pricing_Ep_1 = TestUtil.createPricing(accList[2].Id, cList[2].Id,null);
        pricing_Ep_1.Name = 'Direct To Video Catalog';
        pricing_Ep_1.Channel__c='VODc';
        pricing_Ep_1.Content_Type__c='Episode';
        pricing_Ep_1.Price_Tier__c = 'Reprice';
        pricing_Ep_1.Format__c='HD';
        lPricing.add(pricing_Ep_1);
        
        Pricing__c pricing_Ep_2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_Ep_2.Name = 'Direct To Video Catalog Test';
        pricing_Ep_2.Channel__c='VODc';
        pricing_Ep_2.Content_Type__c='Episode';
        pricing_Ep_2.Price_Tier__c ='Reprice';
        pricing_Ep_2.Format__c='HD';
        lPricing.add(pricing_Ep_2);
        
        insert lPricing;
        
        Playlist__c playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = titleList[0].id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=titleList[2].id;
        content.Playlist__c = playlist.id;
        contentlist.add(content);
        insert contentlist;
        
        clAvailList[0].Playlist__c = playlist.id;
        clAvailList[1].Parent_Client_Avail__c = clAvailList[0].id;
        update clAvailList;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        
        clAvailList[1].Start_Date__c = system.today()+10; 
        update clAvailList[1];
        
         WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=clAvailList[1].Start_Date__c,Price_Tier__c='test1',Type__c='First',Episode_Price_Tier__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today(),Price_Tier__c='test1',Episode_Price_Tier__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
         
        clAvailPriceList[0].Effective_Date__c = system.today()+50;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
        try{
            update clAvailPriceList;
        }
        catch(Exception e){
            system.debug('**********Exception********* '+e.getmessage());
            String message = e.getmessage();
            Boolean match = message.contains('First price record start date must be same as Client Avail start date');
            system.assertEquals(true, match);
        }

        test.stoptest();
    }
    
    private static testMethod void CAPInsertANDDeleteTestCase() {
        
        insertTestData(true);
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        pricing.Price_Tier__c = 'test1';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='Reprice';
        lPricing.add(pricing);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing1.Name = 'Direct To Video Catalog';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Episode';
        pricing1.Price_Tier__c ='Reprice';
        //pricing1.Episode_Price_Tier__c='Reprice';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
        Pricing__c pricing4 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing4.Name = 'Direct To Video Catalog 1';
        pricing4.Channel__c='VODc';
        pricing4.Content_Type__c='Season';
        pricing4.Price_Tier__c ='Reprice4';
        pricing4.Episode_Price_Tier__c='Reprice';
        pricing4.Format__c='HD';
        // lPricing.add(pricing4);
        
        Pricing__c pricing2 = TestUtil.createPricing(accList[2].Id, cList[2].Id,null);
        pricing2.Name = 'Direct To Video Catalog';
        pricing2.Channel__c='VODc';
        pricing2.Content_Type__c='Season';
        pricing2.Price_Tier__c = 'test1';
        pricing2.Episode_Price_Tier__c='Reprice';
        pricing2.Format__c='HD';
        lPricing.add(pricing2);
        
        Pricing__c pricing3 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing3.Name = 'Direct To Video Catalog Test';
        pricing3.Channel__c='VODc';
        pricing3.Content_Type__c='Season';
        pricing3.Price_Tier__c ='test1';
        pricing3.Episode_Price_Tier__c='Reprice';
        pricing3.Format__c='HD';
        lPricing.add(pricing3);
        
        Pricing__c pricing_Ep_1 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_Ep_1.Name = 'Direct To Video Catalog';
        pricing_Ep_1.Channel__c='VODc';
        pricing_Ep_1.Content_Type__c='Episode';
        pricing_Ep_1.Price_Tier__c ='Reprice';
        pricing_Ep_1.Format__c='HD';
        lPricing.add(pricing_Ep_1);
		
        Pricing__c pricing_Ep_2 = TestUtil.createPricing(accList[2].Id, cList[2].Id,null);
        pricing_Ep_2.Name = 'Direct To Video Catalog Test';
        pricing_Ep_2.Channel__c='VODc';
        pricing_Ep_2.Content_Type__c='Episode';
        pricing_Ep_2.Price_Tier__c ='Reprice';
        pricing_Ep_2.Format__c='HD';
        lPricing.add(pricing_Ep_2);
        
        insert lPricing;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        test.startTest();
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Price_Tier__c='test1',Type__c='First',Episode_Price_Tier__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today(),Price_Tier__c='test1',Episode_Price_Tier__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
         
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
        try{
            delete clAvailPriceList[0];
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains('First record cannot be deleted.') )b = true;
            }
            system.assert(b);
        
        }
        catch(Exception e){
            System.debug(e);
            
        }
        test.stoptest();
    }
    
    private static testMethod void CAPPriceTierPriceValidationsTestCase1() {
        insertTestData(true);
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = 'Reprice1';
        //pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='Reprice';
        lPricing.add(pricing);
        insert lPricing;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        test.startTest();
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Category__c = 'Catalog',Price_Tier__c='Reprice1',Price__c=2,Episode_Price_Tier__c='Reprice',Type__c='Reprice',recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM')));
        try{
            insert clAvailPriceList;
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean b = false;
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail().contains(WB_PriceUtility.PR_PRT_MX_ERROR) )b = true;
            }
            system.assert(b);
        }
        catch(Exception e){
            System.debug(e);
        }
        test.stoptest();
    }
    
    private static testMethod void CAPPriceTierPriceValidationsTestCase2() {
        
        insertTestData(true);
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        pricing.Price_Tier__c = 'Reprice1';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='Reprice';
        lPricing.add(pricing);
        
        Pricing__c pricing_Ep_2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_Ep_2.Name = 'Direct To Video Catalog Test';
        pricing_Ep_2.Channel__c='VODc';
        pricing_Ep_2.Content_Type__c='Episode';
        pricing_Ep_2.Price_Tier__c ='Reprice';
        pricing_Ep_2.Format__c='HD';
        lPricing.add(pricing_Ep_2);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing1.Name = 'Direct To Video Catalog';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Episode';
        pricing1.Price_Tier__c ='Reprice';
        //pricing1.Episode_Price_Tier__c='Reprice';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
        insert lPricing;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        test.startTest();
        //WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Price_Tier__c='Reprice1',Episode_Price_Tier__c='Reprice',Category__c = 'Catalog',Type__c='Reprice',recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM')));
        insert clAvailPriceList;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        Client_Avail_Price__c cap = [Select id,Price_Tier__c,Price__c from Client_Avail_Price__c limit 1];
        cap.Price_Tier__c = 'test';
        cap.Price__c = 2;
        
        try{
            update cap;
        }
        catch(Exception e){
            String message = e.getmessage();
            system.debug('*************CAPPriceTierPriceValidationsTestCase2********'+message);
            Boolean match = message.contains(WB_PriceUtility.PR_PRT_MX_ERROR);
            system.assertEquals(true, match);
        }
        test.stoptest();
    }
    
    private static testMethod void CAPInsertPriceSameTestCase() {
        
        insertTestData(true);
        
       
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = 'test1';
        //pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='test1';
        lPricing.add(pricing);
        
        Pricing__c pricing_Ep_2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_Ep_2.Name = 'Direct To Video Catalog Test';
        pricing_Ep_2.Channel__c='VODc';
        pricing_Ep_2.Content_Type__c='Episode';
        pricing_Ep_2.Price_Tier__c ='test1';
        pricing_Ep_2.Format__c='HD';
        lPricing.add(pricing_Ep_2);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing1.Name = 'Direct To Video Catalog';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='test1';
        pricing1.Episode_Price_Tier__c='test1';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
        Pricing__c pricing_Ep_1 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing_Ep_1.Name = 'Direct To Video Catalog Test';
        pricing_Ep_1.Channel__c='VODc';
        pricing_Ep_1.Content_Type__c='Episode';
        pricing_Ep_1.Price_Tier__c ='test1';
        pricing_Ep_1.Format__c='HD';
        lPricing.add(pricing_Ep_1);
        
        insert lPricing;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        test.startTest();
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c();
        cap1.Price_Tier__c = 'test1';
        //cap1.Price_Tier__c = null;
        //cap1.Episode_Price__c = null;
        cap1.Episode_Price_Tier__c = 'test1';
        cap1.Client_Avail__c = clAvailList[0].id;
        cap1.Effective_Date__c = system.today();
        cap1.Type__c='Reprice';
        cap1.Category__c = 'Catalog';
        insert cap1;
        
        insert clAvailPriceList;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        Client_Avail_Price__c cap2 = new Client_Avail_Price__c();
        cap2.Price_Tier__c = 'test1';
        //cap2.Price_Tier__c = null;
        //cap2.Episode_Price__c = null;
        cap2.Episode_Price_Tier__c = 'test1';
        cap2.Client_Avail__c = clAvailList[0].id;
        cap2.Effective_Date__c = system.today()+10;
        cap2.Type__c='Reprice'; 
        cap2.Category__c = 'Catalog';
            
        try{
            insert cap2;
        }
        catch(Exception e){
            system.debug('**********Exception********* '+e.getmessage());
            String message = e.getmessage();
            Boolean match = message.contains(WB_PriceUtility.DATE_OVERLAP_ERROR);
            system.assertEquals(true, match);
        }
        test.stoptest();
    }
    
    private static testMethod void CAPUpdatePriceSameTestCase() {
        
        insertTestData(true);
        
         Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = 'test1';
        pricing.Episode_Price_Tier__c='Reprice';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='test1';
        lPricing.add(pricing);
        
        Pricing__c pricing_ep = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_ep.Name = 'Direct To Video Catalog';
        pricing_ep.Channel__c='VODc';
        pricing_ep.Content_Type__c='Episode';
        //pricing.WS_Price__c=26;
        pricing_ep.Price_Tier__c = 'test1';
        //pricing.Episode_Price_Tier__c='31';
        pricing_ep.Format__c='HD';
        //pricing_ep.Episode_Price_Tier__c='test1';
        lPricing.add(pricing_ep);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='test2';
        pricing1.Episode_Price_Tier__c='test2';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
        Pricing__c pricing2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing2.Name = 'Direct To Video Catalog2';
        pricing2.Channel__c='VODc';
        pricing2.Content_Type__c='Episode';
        //pricing2.WS_Price__c=28;
        pricing2.Price_Tier__c ='test2';
        //pricing2.Episode_Price_Tier__c='test2';
        pricing2.Format__c='HD';
        //pricing2.Key__c += '';
        lPricing.add(pricing2);
        
        Pricing__c pricing2_ep = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing2_ep.Name = 'Direct To Video Catalog2';
        pricing2_ep.Channel__c='VODc';
        pricing2_ep.Content_Type__c='Episode';
        //pricing2_ep.WS_Price__c=28;
        pricing2_ep.Price_Tier__c ='test2';
        //pricing2_ep.Episode_Price_Tier__c='test2';
        pricing2_ep.Format__c='HD';
        //pricing2_ep.Key__c += '';
        lPricing.add(pricing2_ep);
        
        Pricing__c pricing_ep12 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing_ep12.Name = 'Direct To Video Catalog';
        pricing_ep12.Channel__c='VODc';
        pricing_ep12.Content_Type__c='Episode';
        pricing_ep12.Price_Tier__c ='Reprice';
        //pricing1.Episode_Price_Tier__c='Reprice';
        pricing_ep12.Format__c='HD';
        lPricing.add(pricing_ep12);
        
        insert lPricing;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        test.startTest();
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        //WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c();
        cap1.Price_Tier__c = 'test2';
        //cap1.Price__c = null;
        //cap1.Episode_Price__c = null;
        cap1.Episode_Price_Tier__c = 'test2';
        cap1.Client_Avail__c = clAvailList[0].id;
        cap1.Effective_Date__c = system.today();
        cap1.Type__c='First';
        cap1.Category__c = 'Catalog';
        insert cap1;
         
        
        
        lPricing[1].Price_Tier__c = 'test4';
        lPricing[1].Price_Tier__c = 'test4';
        update lPricing[1];

        try{
            WB_ClientAvailPriceHandler.recursiveInsert = false;
            WB_ClientAvailPriceHandler.isCADateChange = false; 
            cap1.Price_Tier__c = 'test3';
            cap1.Effective_Date__c = system.today()-10;
            cap1.Episode_Price_Tier__c = 'test1';
            update cap1;
        }
        catch(Exception e){
            system.debug('**********Exception********* '+e.getmessage());
            String message = e.getmessage();
            Boolean match = message.contains(WB_PriceUtility.FIRST_CAP_INV_DT);
            system.assertEquals(true, match);
        }
        test.stoptest();
    }
    
    private static testMethod void CAPSameEffecrtiveExpiryDateTestCase() {
        
        insertTestData(true);
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = 'test2';
        //pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='test2';
        lPricing.add(pricing);
        
        Pricing__c pricing_Ep_2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_Ep_2.Name = 'Direct To Video Catalog';
        pricing_Ep_2.Channel__c='VODc';
        pricing_Ep_2.Content_Type__c='Episode';
        //pricing_Ep_2.WS_Price__c=28;
        pricing_Ep_2.Price_Tier__c ='test2';
       // pricing_Ep_2.Episode_Price_Tier__c='test2';
        pricing_Ep_2.Format__c='HD';
        lPricing.add(pricing_Ep_2);
        
        insert lPricing;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        //WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
        
        test.startTest();
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c();
        cap1.Price_Tier__c = 'test2';
        cap1.Episode_Price__c = 11;
        cap1.Client_Avail__c = clAvailList[0].id;
        cap1.Effective_Date__c = system.today();
        cap1.Type__c='First';
        cap1.Category__c = 'Catalog';
        insert cap1;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        
        lPricing[1].Price_Tier__c = 'test3';
        lPricing[1].Episode_Price_Tier__c = 'test4';
        update lPricing[1];
        
        
        try{
            WB_ClientAvailPriceHandler.recursiveInsert = false;
            WB_ClientAvailPriceHandler.isCADateChange = false; 
            cap1.Effective_Date__c = system.today()+9;
            update cap1;
        }
        catch(Exception e){
            system.debug('**********Exception********* '+e.getmessage());
            String message = e.getmessage();
            Boolean match = message.contains(WB_PriceUtility.FIRST_CAP_INV_DT);
            system.assertEquals(true, match);
        }
        test.stoptest();
    }
    
    private static testMethod void CAPSeasonCreatedEpisode() {
        insertTestData(true);
        test.startTest();
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Account__c = accList[0].id;
        pricing1.Country__c = cList[0].id;
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='reprice2';
        pricing1.Episode_Price_Tier__c='test1';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
        Pricing__c pricing_Ep_2 = new Pricing__c();
        pricing_Ep_2.Name = 'Direct To Video Catalog2';
        pricing_Ep_2.Account__c = accList[0].id;
        pricing_Ep_2.Country__c = cList[0].id;
        pricing_Ep_2.Channel__c='VODc';
        pricing_Ep_2.Content_Type__c='Episode';
        //pricing_Ep_2.WS_Price__c=28;
        pricing_Ep_2.Price_Tier__c ='test1';
        //pricing_Ep_2.Episode_Price_Tier__c='test1';
        pricing_Ep_2.Format__c='HD';
        lPricing.add(pricing_Ep_2);
        
        Pricing__c pricing_Ep_3 = new Pricing__c();
        pricing_Ep_3.Name = 'Direct To Video Catalog2';
        pricing_Ep_3.Account__c = accList[1].id;
        pricing_Ep_3.Country__c = cList[1].id;
        pricing_Ep_3.Channel__c='VODc';
        pricing_Ep_3.Content_Type__c='Episode';
        //pricing_Ep_2.WS_Price__c=28;
        pricing_Ep_3.Price_Tier__c ='test1';
        //pricing_Ep_2.Episode_Price_Tier__c='test1';
        pricing_Ep_3.Format__c='HD';
        lPricing.add(pricing_Ep_3);
        
        Pricing__c pricing_ep = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing_ep.Name = 'Direct To Video Catalog';
        pricing_ep.Channel__c='VODc';
        pricing_ep.Content_Type__c='Episode';
        pricing_ep.Price_Tier__c ='Reprice';
        //pricing1.Episode_Price_Tier__c='Reprice';
        pricing_ep.Format__c='HD';
        lPricing.add(pricing_ep);
        
        insert lPricing;
        
        Playlist__c playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = titleList[0].id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=titleList[2].id;
        content.Playlist__c = playlist.id;
        contentlist.add(content);
        insert contentlist;
        
        clAvailList[0].Playlist__c = playlist.id;
        clAvailList[1].Parent_Client_Avail__c = clAvailList[0].id;
        update clAvailList;
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        //WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
        
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),
            Price_Code__c='Direct To Video Catalog2',Type__c='Reprice',Category__c = 'Catalog',
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap1);
        insert cap1;
        cap1.Effective_Date__c = system.today()+1;
        update cap1;
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.recursiveDelete = false;
        delete cap1;
        test.stoptest();
    }
    
    private static testMethod void CAPUpdateANDDeleteTestCase2() {
        insertTestData(true);
        
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = '9';
        //pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='10';
        lPricing.add(pricing);
        
        Pricing__c pricing_ep = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing_ep.Name = 'Direct To Video Catalog';
        pricing_ep.Channel__c='VODc';
        pricing_ep.Content_Type__c='Episode';
        //pricing.WS_Price__c=26;
        pricing_ep.Price_Tier__c = '10';
        //pricing.Episode_Price_Tier__c='31';
        pricing_ep.Format__c='HD';
        //pricing_ep.Episode_Price_Tier__c='10';
        lPricing.add(pricing_ep);
        
        Pricing__c pricing_1 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing_1.Name = 'Direct To Video Catalog';
        pricing_1.Channel__c='VODc';
        pricing_1.Content_Type__c='Episode';
        //pricing.WS_Price__c=26;
        pricing_1.Price_Tier__c = '14';
        //pricing.Episode_Price_Tier__c='31';
        pricing_1.Format__c='HD';
        //pricing_1.Episode_Price_Tier__c='10';
        lPricing.add(pricing_1);
        
        Pricing__c pricing_2 = TestUtil.createPricing(accList[1].Id, cList[1].Id,null);
        pricing_2.Name = 'Direct To Video Catalog3';
        pricing_2.Channel__c='VODc';
        pricing_2.Content_Type__c='Episode';
        //pricing.WS_Price__c=26;
        pricing_2.Price_Tier__c = '10';
        //pricing.Episode_Price_Tier__c='31';
        pricing_2.Format__c='HD';
        //pricing_2.Episode_Price_Tier__c='10';
        lPricing.add(pricing_2);
        
        Pricing__c pricing2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing2.Name = 'Direct To Video Catalog1';
        pricing2.Channel__c='VODc';
        pricing2.Content_Type__c='Season';
        pricing2.Price_Tier__c = '11';
        pricing2.Format__c='HD';
        pricing2.Episode_Price_Tier__c='12';
        lPricing.add(pricing2);
        
        Pricing__c pricing2_ep = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing2_ep.Name = 'Direct To Video Catalog1';
        pricing2_ep.Channel__c='VODc';
        pricing2_ep.Content_Type__c='Episode';
        pricing2_ep.Price_Tier__c = '12';
        pricing2_ep.Format__c='HD';
        //pricing2_ep.Episode_Price_Tier__c='12';
        lPricing.add(pricing2_ep);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        pricing1.Price_Tier__c = '12';
        pricing1.Format__c='HD';
        pricing1.Episode_Price_Tier__c='13';
        lPricing.add(pricing1);
        //insert lPricing;
        
        Pricing__c pricing1_ep = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing1_ep.Name = 'Direct To Video Catalog2';
        pricing1_ep.Channel__c='VODc';
        pricing1_ep.Content_Type__c='Episode';
        pricing1_ep.Price_Tier__c = '13';
        pricing1_ep.Format__c='HD';
        //pricing1_ep.Episode_Price_Tier__c='13';
        lPricing.add(pricing1_ep);
        insert lPricing;
        
        test.startTest();
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        //WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
        
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Price_Tier__c='9',Episode_Price_Tier__c='10',Type__c='First',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[1].id,Effective_Date__c=system.today()+50,Price_Tier__c='14',Type__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
        insert new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+2,Price_Tier__c='11',Episode_Price__c=12,Type__c='Reprice',Category__c = 'Catalog');
        insert new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+4,Price_Tier__c='12',Episode_Price__c=13,Type__c='Reprice',Category__c = 'Catalog');
        
        clAvailList[1].Start_Date__c = system.today()+10;
        clAvailList[1].End_Date__c= system.today()+30;  
        update clAvailList;
        
        
        //delete clAvailPriceList[1];
        
        test.stoptest();
    }
    
    private static testMethod void capValidationTest() {
        insertTestData(true);
                
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = '9';
        //pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
        pricing.Episode_Price_Tier__c='10';
        lPricing.add(pricing);
        
        Pricing__c pricing2 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing2.Name = 'Direct To Video Catalog1';
        pricing2.Channel__c='VODc';
        pricing2.Content_Type__c='Season';
        pricing2.Price_Tier__c = '11';
        pricing2.Format__c='HD';
        pricing2.Episode_Price_Tier__c='12';
        lPricing.add(pricing2);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[0].Id, cList[0].Id,null);
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        pricing1.Price_Tier__c = '12';
        pricing1.Format__c='HD';
        pricing1.Episode_Price_Tier__c='13';
        lPricing.add(pricing1);
        insert lPricing;
        
        test.startTest();
        List<Client_Avail_Price__c> capList = [Select Id,Name from Client_Avail_Price__c where Client_Avail__c = :clAvailList[0].id OR Client_Avail__c = :clAvailList[1].id];
        
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Price_Tier__c='9',Episode_Price_Tier__c='10',Type__c='Reprice',Category__c = 'Invalid'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=null,Price_Tier__c='14',Episode_Price_Tier__c='20',Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()-5,Price_Tier__c='14',Episode_Price_Tier__c='20',Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+10,Price_Tier__c='14',Episode_Price_Tier__c='20',Type__c='Reprice',Category__c = 'Invalid Tier'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+25,Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+35,Price_Tier__c='14',Price_Code__c='Direct To Video Catalog1',Type__c='Reprice',Category__c = 'Catalog'));
        
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+15,Price_Tier__c='14',Episode_Price_Tier__c='10',Episode_Price__c=11,Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+18,Price_Tier__c='15',Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+20,Episode_Price_Tier__c='10',Price_Code__c='Direct To Video Catalog1',Type__c='Reprice',Category__c = 'Catalog'));
        
        Client_Avail_Price__c validRecord = new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+22,Price__c=30,Episode_Price__c=10,Type__c='Reprice',Category__c = 'Catalog');
        clAvailPriceList.add(validRecord);
        
        Database.insert(clAvailPriceList,false);
    
    Client_Avail_Price__c validRecord1 = new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+22,Expiry_Date__c=system.today()+32,Price_Tier__c='9',Episode_Price_Tier__c='10',Category__c = 'Direct To Video Catalog');
        
        test.stoptest();
  }
    
    private static testMethod void seasonEpisodePriceUpdate(){
        setUpData(true);
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = null;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        listClientavails.add(clientAvail);
        
        //insert  clientAvail;
         
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[1].Id);
        clientAvail1.Start_Date__c = system.today()+20;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Price_Tier_Text__c = 'reprice12';
        listClientavails.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[1].Id);
        clientAvail2.Start_Date__c = system.today()+30;
        clientAvail2.End_Date__c = system.today()+50;
        clientAvail2.Avail_Type__c = 'Automated'; 
        clientAvail2.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail2.Price_Tier_Text__c = 'reprice13';
        listClientavails.add(clientAvail2);
        
        insert listClientavails;
        
        listClientavails[1].Parent_Client_Avail__c = listClientavails[0].id;
        listClientavails[1].Recalculate_Playlist_Avails__c = '';
        //listClientavails[2].Parent_Client_Avail__c = listClientavails[0].id;
        //listClientavails[2].Recalculate_Playlist_Avails__c = '';
        update listClientavails[1];
        
        try{
            
            test.startTest();
            
            WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
            WB_ClientAvailPriceHandler.recursiveInsert = false; 
            
            Client_Avail_Price__c seasonReprice1 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+15,
                Price__c=10.99,Episode_Price__c=2.99,Type__c='Reprice',Category__c = 'Catalog',
                recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
            system.debug('Client Avail Pricing : '+seasonReprice1);
            insert seasonReprice1;
            
            seasonReprice1.Effective_Date__c = system.today()+25;
            update seasonReprice1;
            
            seasonReprice1.Effective_Date__c = system.today()+10;
            update seasonReprice1;
            
            seasonReprice1.Effective_Date__c = listClientavails[0].start_date__c;
            Database.update(seasonReprice1,false);
            
            seasonReprice1.Effective_Date__c = seasonReprice1.Effective_Date__c.addDays(-1);
            Database.update(seasonReprice1,false);
            
         //  test.stoptest();
        }catch(Exception ex){
            
        }
        
        
    }
    
    @isTest
    public static void testMethodToUpdateCAStartEndDate()
    {
        //Insert Account 
         for(Integer i = 0; i<count; i++){
            Account acc = TestUtil.createAccount('WB Account'+i);
            acc.Customer_Focus__c = 'Active';
            accList.add(acc); 
         }
         insert accList;
         
         //Insert Titles
         for(integer i = 0; i<count; i++)
         {
            Title__c newTitle = TestUtil.initTitle('WBMovie'+i, '600004754'+i);
            newTitle.Content_Type__c = 'Season';
            if(i == 3)
                newTitle.Content_Type__c = 'Episode'; 
            titleList.add(newTitle);
         }
         insert titleList;
         
         //Insert Countries   
         Country__c country1 = TestUtil.initCountry('Colombia', 'CO', 'COL');
         Country__c country2 = TestUtil.initCountry('China', 'CN', 'CHN');
         Country__c country3 = TestUtil.initCountry('Canada', 'CA', 'CAN');
         cList.add(country1);
         cList.add(country2);
         cList.add(country3);
         insert cList;
         
         //List<Country_Groups__c> countryGroupList = new List<Country_Groups__c>();
         Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=country1.Name);
         insert countryGroup;
         
         Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=country1.Id);
         insert countryGC;
         
         //Insert Languages
         for(Integer i = 0; i<count; i++)
         {
            Language__c newLanguage = TestUtil.initLanguage('English', '', 1);
            lList.add(newLanguage);
         }
         insert lList;
        
         //Insert Local Data
         for(Integer i=0; i<count; i++)
         {
            Local_Title__c localTitle = TestUtil.initLocalTitle(lList[i].Id, cList[i].Id);
            localTitle.Title__c = titleList[i].id;
            lTitle.add(localTitle);
         }
         insert lTitle;
         
         //Create Release Plan
         for(Integer i=0; i<count; i++)
         {
            Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(titleList[i].Id, lTitle[i].Id, cList[i].Id, lList[i].Id);
            CommercialAvail.Start_Date__c = system.today()+5;
            CommercialAvail.Exclusive_Date__c =  system.today()+5;
            CommercialAvail.End_Date__c = system.today()+250;
            CommercialAvail.Rights_End__c =system.today()+250;
            cAvailList.add(CommercialAvail);
         }
         insert cAvailList;
         
         //Create Storefront
         for(Integer i=0; i<count; i++)
         {
            Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(accList[i].Id, cList[i].Id, cAvailList[i], titleList[i]);
            agreementList.add(storefrontGoogle1);
         }
         insert agreementList;
         
         //Create Client Avail 
         for(Integer i=0; i<count; i++)
         {
            Client_Avail__c clientAvail = TestUtil.initClientAvail(accList[0].Id, cAvailList[i], lTitle[i].Id);
            clientAvail.Start_Date__c = system.today()+5;
            clientAvail.End_Date__c = system.today()+250;
            clientAvail.status__c = 'Tentative';
            clientAvail.Announce_Override__c = 'Force';
            clientAvail.Storefront__c = agreementList[0].Id; 
            clAvailList.add(clientAvail);
         }
         insert clAvailList;
        // system.debug('clAvailList>>>>>>>>'+clAvailList);
         //List<Client_Avail_Price__c>  getCapList = new List<Client_Avail_Price__c>();
         //getCapList = [select ID from Client_Avail_Price__c WHERE Client_Avail__c =: clAvailList[0].Id];
         //system.debug(LoggingLevel.INFO,'CAPLIST>>>>>>>>>>'+getCapList);
         //Insert Custom Setting - Country SID Key
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='China', Country_Code__c='CHN',Country_Code2_c__c='CN',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='Canada', Country_Code__c='CAN',Country_Code2_c__c='CA',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
        //Insert Client Avail Pricing for CA
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+149,Price__c=10.0,Episode_Price__c=10.0,Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        
        insert clAvailPriceList[0];
        clAvailList[0].Status__c = 'confirmed';
        update clAvailList[0];
       
        
     
        
            
             clAvailList[0].Price__c = null;
            clAvailList[0].Start_Date__c = system.today()+25;
            //update clAvailList[0];
            
             clAvailList[0].Price__c = null;
            clAvailList[0].Start_Date__c = system.today()+150;
            Test.startTest();
            update clAvailList[0];
            
              clAvailList[0].Price__c = null;
             clAvailList[0].End_Date__c = system.today()+240;
           // update clAvailList[0];
            
            clAvailList[0].Price__c = null;
            clAvailList[0].Start_Date__c = system.today()+170;
            clAvailList[0].End_Date__c = system.today()+240;
            update clAvailList[0];
            
            
            clAvailList[0].Price__c = null;
              clAvailList[0].Start_Date__c = system.today()+150;
            clAvailList[0].End_Date__c = system.today()+152;
            update clAvailList[0];
          
            
            clAvailList[0].Start_Date__c = system.today()+100;
            clAvailList[0].Price__c = null;
            clAvailList[0].End_Date__c = system.today()+140;
            update clAvailList[0];
           
            
        Test.stopTest();
    }
    
     @isTest
    public static void testMethodForWB_CADelete()
    {
      try{                 
        listlocaltitles= new List<Local_Title__c>();
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
       
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
        Country.Name = 'INDIA';
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
        
        Playlist__c playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
    
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        insert content;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        Local_Title__c LT1 = New Local_Title__c();
        LT1.Name = episodeTitle.Name;
        LT1.Local_Theatrical_Release_Date__c = date.today();
        LT1.Title__c = episodeTitle.Id;
        LT1.Country__c = Country.Id;
        LT1.Language__c = Language.Id;
        LT1.Local_TV_Air_Date__c = System.today()+2;
        listlocaltitles.add(LT1);
        
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'EST';
        releasePlan1.APO__c = 'Yes';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+80;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        Test.startTest();
        insert listReleaseplan;
         
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        
        update storefrontGoogle1;
       
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'INDIA';
        createRPC.Country_Code__c = 'IND';
        createRPC.Region__c = 'Asia Pacific';
        createRPC.Locale_SID_Key__c = 'Asia/Kolkata';
        createRPC.Country_Code2_c__c = 'IN';
        createRPC.isPublishToClient__c = True;
        insert createRPC;
        
        WB_Pricing_Settings__c pricingFlag = new WB_Pricing_Settings__c();
        pricingFlag.Name = 'Publish to Client';
        pricingFlag.IsPublishToClient__c = True;
        insert pricingFlag;
          
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        insert clientAvail;
        
        listClientavails.add(clientAvail);
        clientAvail.Playlist__c = playlist.id;
        update clientAvail;
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[1].Id);
        clientAvail1.Title__c = episodeTitle.id;
        clientAvail1.Parent_Client_Avail__c = clientAvail.id;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.APO__c = 'Yes';
        clientAvail1.Status__c = 'Confirmed';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail1.Local_Title__c = listlocaltitles[1].id;
        insert clientAvail1;
        listClientavails.add(clientAvail1);
        
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
	    String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c,Expiry_Date__c=listClientavails[0].Start_Date__c.addDays(2),Price__c=120.00);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[0].End_Date__c,Price_Tier__c='reprice2',Episode_Price_Tier__c='test1',Type__c='Reprice');
	   capList.add(cap1);
	   capList.add(cap2);
	   WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=objAccount.Id,
                                                        Content_Type__c = 'Season', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=objAccount.Id,
                                                            Content_type__c='Season', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();        
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clientAvail.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clientAvail.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
        
        Database.insert(annRecList);
        
        WB_TriggerHandlerDateOverlapClientAvail.deleteClientAvail(listClientavails);
       // delete listClientavails;
        
        Test.stopTest();
        }catch(Exception ex){
             system.debug(LoggingLevel.INFO,'Exception:'+ex);
        }
        
      }
      
      @isTest
    public static void testMethodForWB_CADeleteWithoutAnnouncement()
    {
      try{                
        listlocaltitles= new List<Local_Title__c>();
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
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
        Country.Name = 'INDIA';
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
        
        Playlist__c playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
    
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        insert content;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        
        Local_Title__c LT1 = New Local_Title__c();
        LT1.Name = episodeTitle.Name;
        LT1.Local_Theatrical_Release_Date__c = date.today();
        LT1.Title__c = episodeTitle.Id;
        LT1.Country__c = Country.Id;
        LT1.Language__c = Language.Id;
        LT1.Local_TV_Air_Date__c = System.today()+2;
        listlocaltitles.add(LT1);
        
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'EST';
        releasePlan1.APO__c = 'Yes';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+80;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        releasePlan1.Playlist__C = playlist.id;
        listReleaseplan.add(releasePlan1);
        Test.startTest();
        insert listReleaseplan;
         
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        
        update storefrontGoogle1;
       
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'INDIA';
        createRPC.Country_Code__c = 'IND';
        createRPC.Region__c = 'Asia Pacific';
        createRPC.Locale_SID_Key__c = 'Asia/Kolkata';
        createRPC.Country_Code2_c__c = 'IN';
        createRPC.isPublishToClient__c = True;
        insert createRPC;
        
        WB_Pricing_Settings__c pricingFlag = new WB_Pricing_Settings__c();
        pricingFlag.Name = 'Publish to Client';
        pricingFlag.IsPublishToClient__c = True;
        insert pricingFlag;
          
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        insert clientAvail;
        
        listClientavails.add(clientAvail);
        clientAvail.Playlist__c = playlist.id;
        update clientAvail;
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, releasePlan1, listlocaltitles[1].Id);
        clientAvail1.Title__c = episodeTitle.id;
        clientAvail1.Parent_Client_Avail__c = clientAvail.id;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.APO__c = 'Yes';
        clientAvail1.Status__c = 'Confirmed';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail1.Local_Title__c = listlocaltitles[1].id;
        insert clientAvail1;
        listClientavails.add(clientAvail1);
        
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
	    String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c,Expiry_Date__c=listClientavails[0].Start_Date__c.addDays(2),Price__c=120.00);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[0].End_Date__c,Price_Tier__c='reprice2',Episode_Price_Tier__c='test1',Type__c='Reprice');
	   capList.add(cap1);
	   capList.add(cap2);
	   WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
        WB_TriggerHandlerDateOverlapClientAvail.deleteClientAvail(listClientavails);
       // delete listClientavails;
        
        Test.stopTest();
        }catch(Exception ex){
             system.debug(LoggingLevel.INFO,'Exception:'+ex);
        }
        
      }
      
       private static testMethod void CAWithAPODateTest() {
        setUpData1(true);
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Playlist__c = playlist123.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        //insert clientAvail;
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
            //clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Start_Date__c = system.today()+20;
            clientAvail1.End_Date__c = system.today()+70;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price_Tier_Text__c = 'reprice12';
            clientAvail1.APO_Date__c = system.today() + 1;
            //clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
         	//clientAvail1.Episode_Price_Tier__c = 'reprice12';
        	listClientavails12.add(clientAvail1);
            //insert clientAvail;
            
             insert listClientavails12;
             WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
            
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12[1];
             test.startTest();
            List<Client_Avail_Price__c> capList = [Select Id,Type__c,Price_Code__c, Pricing__c,Episode_Price__c  from Client_Avail_Price__c where Client_Avail__c =:listClientavails12[1].Id ];
           
           
           for(Client_Avail_Price__c capRec : capList){
           	if(capRec.type__c == 'First'){
           		capRec.Price_Tier__c  = 'reprice13';
           	}
           }
           update capList;
           test.stoptest();
            
           
    }
    private static testMethod void CAWithPastAPODate() {
        setUpData1(true);
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        clientAvail.Playlist__c = playlist123.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        //insert clientAvail;
        listClientavails12.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
            //clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Start_Date__c = system.today()+20;
            clientAvail1.End_Date__c = system.today()+70;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price_Tier_Text__c = 'reprice12';
            clientAvail1.APO_Date__c = system.today() - 10;
            //clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
         	//clientAvail1.Episode_Price_Tier__c = 'reprice12';
        	listClientavails12.add(clientAvail1);
            //insert clientAvail;
            
             insert listClientavails12;
             WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
            
            listClientavails12[1].Parent_Client_Avail__c = listClientavails12[0].id;
            listClientavails12[1].Recalculate_Playlist_Avails__c = '';
            update listClientavails12[1];
             test.startTest();
            List<Client_Avail_Price__c> capList = [Select Id,Type__c,Price_Code__c, Pricing__c,Episode_Price__c  from Client_Avail_Price__c where Client_Avail__c =:listClientavails12[1].Id ];
           
           
           for(Client_Avail_Price__c capRec : capList){
           	if(capRec.type__c == 'First'){
           		capRec.Price_Tier__c  = 'reprice13';
           	}
           }
           update capList;
           test.stoptest();
            
           
    }
    
    @isTest
    public static void UpdateCAOnPricingChngTest1(){
     Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        List<Title__c> ListTitle=new List<Title__c>();
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        ListTitle.add(title1);
        
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        ListTitle.add(title2);
        insert ListTitle;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='FR',Country_Code__c='FRA');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        List<Local_Title__c> ListLocTitle=new List<Local_Title__c>();
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[0].Id,Country__c = countryFrance.Id,
                                Language__c =languageFrench.Id);
        ListLocTitle.add(local1);
        
        Local_Title__c local2 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[1].Id,Country__c = countryFrance.Id,
                                Language__c =languageFrench.Id);
        ListLocTitle.add(local2);
        
         
         List<Commercial_Avail__c> ListCommAvl=new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=ListTitle[0].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[0].Id,
                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                Exclusive_Date__c = date.today()-31, Start_Date__c=date.today()-30,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
                
        );
        ListCommAvl.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=ListTitle[1].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[1].Id,
                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                Exclusive_Date__c = date.today()-31, Start_Date__c=date.today()-30,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
                
        );
        ListCommAvl.add(releaseplan2);
        insert ListCommAvl;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c=false,SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=ListCommAvl[0].Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
            End_Date__c=Date.today()-2
        );
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(
            Commercial_Avail__c=ListCommAvl[0].Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
            End_Date__c=Date.today()-2,Announce_Override__c='Force'
        );
      
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        clientAvailList.add(clientAvail2);
        insert clientAvailList;
        
		List<Pricing__c> ListPric=new List<Pricing__c>();
		Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,WS_Price__c=56.78,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
        );
        ListPric.add(price1);
        
        Pricing__c price2 = new Pricing__c(Name ='Pr2',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,WS_Price__c=58.78,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
        );
        ListPric.add(price2);
        insert ListPric;
		
		 Map<String,Integer> countryOffsetMap = new Map<String,Integer>();
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'FRANCE';
        createRPC.Country_Code__c = 'FRA';
        createRPC.Region__c = 'Western Europe';
        createRPC.Locale_SID_Key__c = '	Europe/Lisbon';
        createRPC.Country_Code2_c__c = 'FR';
        createRPC.isPublishToClient__c = True;
        Test.startTest();
        insert createRPC;
        
        List<Client_Avail_Price__c> capList = [select id,Price_Code__c,Effective_Date__c,Expiry_Date__c,Client_Avail__c from Client_Avail_Price__c];
        List<Client_Avail_Price__c> updateCapList =new List<Client_Avail_Price__c>();
        for(Client_Avail_Price__c cap : capList){
            cap.Price_Code__c=ListPric[0].Name;
            if(cap.Client_Avail__c == clientAvailList[1].id){
                cap.Announce_Override__c='Force';
            }
            updateCapList.add(cap);
            
        }
        
        update updateCapList;
        
	    Test.stopTest();	   
    }
    
	
	@isTest   //commemted  
    public static void updateClientAvailPriceStartEndDateTest(){
		
		Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        List<Title__c> ListTitle=new List<Title__c>();
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        ListTitle.add(title1);
        insert ListTitle;
   
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='FR',Country_Code__c='FRA');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        List<Local_Title__c> ListLocTitle=new List<Local_Title__c>();
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[0].Id,Country__c = countryFrance.Id,
                                Language__c =languageFrench.Id);
        ListLocTitle.add(local1);
        insert ListLocTitle;
        
        List<Commercial_Avail__c> ListCommAvl=new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=ListTitle[0].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[0].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                Exclusive_Date__c = date.today()-31, Start_Date__c=date.today()-30,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
                
        );
        ListCommAvl.add(releaseplan1);
        insert ListCommAvl;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=ListTitle[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c=false,SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
            End_Date__c=Date.today()-2
        );
       Test.startTest();
	   
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'FRANCE';
        createRPC.Country_Code__c = 'FRA';
        createRPC.Region__c = 'Western Europe';
        createRPC.Locale_SID_Key__c = '	Europe/Lisbon';
        createRPC.Country_Code2_c__c = 'FR';
        createRPC.isPublishToClient__c = True;
        insert createRPC;
        insert clientAvailList;
	
		
		String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = 'PC001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='EST';
        insertProd.Local_Title__c = local1.Id;
        insert insertProd;
        
        String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
        Opportunity createDeal = new Opportunity ();
        createDeal.RecordTypeId = oppRecTypeId;
        createDeal.Name = 'Test Deal';
        createDeal.Deal_Code__c  = 'DC001';
        createDeal.StageName = 'Planned';
        createDeal.Promo_Start_Date__c = date.today()-28;
        createDeal.Promo_End_Date__c = date.today()-2;  
        createDeal.Start_Date__c = Date.today()-28;
        createDeal.CloseDate = Date.today()-2;
        createDeal.Account = acctGoogle;
        insert createDeal; 
		
		String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
		
		Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Deal_ID__c=createDeal.id,Client_Avail__c=clientAvail1.id,Category__c='Catalog',Effective_Date__c=date.today()-28,Expiry_Date__c=Date.today()-2,Price__c=56.77);
		insert cap3;

		clientAvail1.End_Date__c=Date.today()-1;
		update clientAvail1;
			
	    Test.stopTest();  	   
    }
	
	@isTest
    public static void updateClientAvailPriceStartEndDateTest_1(){
			
			Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
			
			List<Title__c> ListTitle=new List<Title__c>();
			Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
			ListTitle.add(title1);
			Title__c title2 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
			ListTitle.add(title2);
			insert ListTitle;
	   
			Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='FR',Country_Code__c='FRA');
			insert countryFrance;
			
			Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
			insert languageFrench;
			
			List<Local_Title__c> ListLocTitle=new List<Local_Title__c>();
			Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[0].Id,Country__c = countryFrance.Id,
									Language__c =languageFrench.Id);
			ListLocTitle.add(local1);
			Local_Title__c local2 = new Local_Title__c(Name = 'local2',Title__c =ListTitle[1].Id,Country__c = countryFrance.Id,
									Language__c =languageFrench.Id);
			ListLocTitle.add(local2);
			insert ListLocTitle;
			
			List<Commercial_Avail__c> ListCommAvl=new List<Commercial_Avail__c>();
			Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=ListTitle[0].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[0].Id,
					Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
					Exclusive_Date__c = date.today()-31, Start_Date__c=date.today()-30,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
					
			);
			ListCommAvl.add(releaseplan1);
			Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=ListTitle[1].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[1].Id,
					Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
					Exclusive_Date__c = date.today()-31, Start_Date__c=date.today()-30,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
					
			);
			ListCommAvl.add(releaseplan2);
			insert ListCommAvl;
			
			Agreement__c storefrontGoogle1 = new Agreement__c(
				Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=ListTitle[0].Content_Type__c,
				Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c=false,SAP_Customer_Number__c='12010421'
			);
			insert storefrontGoogle1;  
        
            Client_Avail__c clientAvail1 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
                End_Date__c=Date.today()-2
            );
           
    	   Client_Avail__c clientAvail2 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan2.Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
                End_Date__c=Date.today()-3
            );
    	   
            List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
            clientAvailList.add(clientAvail1);
    		clientAvailList.add(clientAvail2);
    		Country_SID_Key__c createRPC = new Country_SID_Key__c();
            createRPC.Name = 'FRANCE';
            createRPC.Country_Code__c = 'FRA';
            createRPC.Region__c = 'Western Europe';
            createRPC.Locale_SID_Key__c = '	Europe/Lisbon';
            createRPC.Country_Code2_c__c = 'FR';
            createRPC.isPublishToClient__c = True;
            insert createRPC;
            insert clientAvailList;
    	    clientAvail2.End_Date__c=Date.today()-2;
    	    update clientAvail2;
    		
    		Test.startTest();
    		String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
            Product2 insertProd = new Product2();
            insertProd.RecordTypeId = productRecTypeId;
            insertProd.Name = 'Test Product';
            insertProd.ProductCode = 'PC001';
            insertProd.Type__c = 'Video Digital';
            insertProd.Product_Market__c ='EST';
            insertProd.Local_Title__c = local1.Id;
            insert insertProd;
            
            String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
            Opportunity createDeal = new Opportunity ();
            createDeal.RecordTypeId = oppRecTypeId;
            createDeal.Name = 'Test Deal';
            createDeal.Deal_Code__c  = 'DC001';
            createDeal.StageName = 'Planned';
            createDeal.Promo_Start_Date__c = date.today()-28;
            createDeal.Promo_End_Date__c = date.today()-2;  
            createDeal.Start_Date__c = Date.today()-28;
            createDeal.CloseDate = Date.today()-2;
            createDeal.Account = acctGoogle;
            insert createDeal; 
    		
    		String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
    		
			List<Client_Avail_Price__c> ListCAP = new List<Client_Avail_Price__c>();
    		Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Deal_ID__c=createDeal.id,Client_Avail__c=clientAvail1.id,Category__c='Catalog',Effective_Date__c=date.today()-29,Expiry_Date__c=Date.today()-2,Price__c=56.77);
    		ListCAP.add(cap3);
    		Client_Avail_Price__c cap31 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Deal_ID__c=createDeal.id,Client_Avail__c=clientAvail2.id,Category__c='Catalog',Effective_Date__c=date.today()-30,Expiry_Date__c=Date.today()-2,Price__c=56.77);
    		ListCAP.add(cap31);
    		insert ListCAP;
   
    		clientAvail1.APO_Date__c=system.today() - 40;
    		update clientAvail1;
    		clientAvail2.APO_Date__c=system.today() - 40;
    		update clientAvail2;
		
	        Test.stopTest();	 	  	   
    }
    
    @isTest
    public static void updateClientAvailPriceStartEndDateTest_2(){
			
			Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
			
			List<Title__c> ListTitle=new List<Title__c>();
			Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
			ListTitle.add(title1);
			Title__c title2 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
			ListTitle.add(title2);
			insert ListTitle;
	   
			Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='FR',Country_Code__c='FRA');
			insert countryFrance;
			
			Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
			insert languageFrench;
			
			List<Local_Title__c> ListLocTitle=new List<Local_Title__c>();
			Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[0].Id,Country__c = countryFrance.Id,
									Language__c =languageFrench.Id);
			ListLocTitle.add(local1);
			Local_Title__c local2 = new Local_Title__c(Name = 'local2',Title__c =ListTitle[1].Id,Country__c = countryFrance.Id,
									Language__c =languageFrench.Id);
			ListLocTitle.add(local2);
			insert ListLocTitle;
			
			List<Commercial_Avail__c> ListCommAvl=new List<Commercial_Avail__c>();
			Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=ListTitle[0].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[0].Id,
					Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
					Exclusive_Date__c = date.today()-61, Start_Date__c=date.today()-50,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
					
			);
			ListCommAvl.add(releaseplan1);
			Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=ListTitle[1].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[1].Id,
					Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
					Exclusive_Date__c = date.today()-31, Start_Date__c=date.today()-30,End_Date__c= date.today()-1,Rights_End__c=date.today()-1
					
			);
			ListCommAvl.add(releaseplan2);
			insert ListCommAvl;
			
			Agreement__c storefrontGoogle1 = new Agreement__c(
				Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=ListTitle[0].Content_Type__c,
				Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c=false,SAP_Customer_Number__c='12010421'
			);
			insert storefrontGoogle1;  
        
            Client_Avail__c clientAvail1 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
                End_Date__c=Date.today()-2
            );
           
    	   Client_Avail__c clientAvail2 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan2.Id, Client__c=acctGoogle.Id,Status__c='Tentative',Start_Date__c=date.today()-30,
                End_Date__c=Date.today()-3
            );
    	   
            List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
            clientAvailList.add(clientAvail1);
    		clientAvailList.add(clientAvail2);
    		Country_SID_Key__c createRPC = new Country_SID_Key__c();
            createRPC.Name = 'FRANCE';
            createRPC.Country_Code__c = 'FRA';
            createRPC.Region__c = 'Western Europe';
            createRPC.Locale_SID_Key__c = '	Europe/Lisbon';
            createRPC.Country_Code2_c__c = 'FR';
            createRPC.isPublishToClient__c = True;
            insert createRPC;
			
            insert clientAvailList;
			
    	    clientAvail2.End_Date__c=Date.today()-2;
			clientAvail2.APO_Date__c = date.today()-40;
    	    update clientAvail2;
    		
    		Test.startTest();
    		String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
            Product2 insertProd = new Product2();
            insertProd.RecordTypeId = productRecTypeId;
            insertProd.Name = 'Test Product';
            insertProd.ProductCode = 'PC001';
            insertProd.Type__c = 'Video Digital';
            insertProd.Product_Market__c ='EST';
            insertProd.Local_Title__c = local1.Id;
            insert insertProd;
            
            String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
            Opportunity createDeal = new Opportunity ();
            createDeal.RecordTypeId = oppRecTypeId;
            createDeal.Name = 'Test Deal';
            createDeal.Deal_Code__c  = 'DC001';
            createDeal.StageName = 'Planned';
            createDeal.Promo_Start_Date__c = date.today()-28;
            createDeal.Promo_End_Date__c = date.today()-2;  
            createDeal.Start_Date__c = Date.today()-28;
            createDeal.CloseDate = Date.today()-2;
            createDeal.Account = acctGoogle;
            insert createDeal; 
    		
    		String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
    		
			List<Client_Avail_Price__c> ListCAP = new List<Client_Avail_Price__c>();
    		Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Deal_ID__c=createDeal.id,Client_Avail__c=clientAvail1.id,Category__c='Catalog',Effective_Date__c=date.today()-29,Expiry_Date__c=Date.today()-2,Price__c=56.77);
    		ListCAP.add(cap3);
    		Client_Avail_Price__c cap31 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Deal_ID__c=createDeal.id,Client_Avail__c=clientAvail2.id,Category__c='Catalog',Effective_Date__c=date.today()-30,Expiry_Date__c=Date.today()-2,Price__c=56.77);
    		ListCAP.add(cap31);
    		insert ListCAP;
   
    		clientAvail1.APO_Date__c=system.today() - 40;
    		update clientAvail1;
    		clientAvail2.APO_Date__c=system.today() - 40;
    		update clientAvail2;
		
	        Test.stopTest();	 	  	   
    }
    
     @isTest
    public static void announceTempCAP1(){
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        //Country__c c = tdu.createCountry();
        Country__c c = TestUtil.initCountry('Colombia', 'CO', 'COL');
        insert c;
        
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=t.id,Language__c=l.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
       
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
        rp.Exclusive_Date__c = System.today().addDays(-200);
        rp.Start_Date__c = System.today().addDays(-200);
        rp.End_Date__c = System.today().addDays(500);
        rp.Rights_End__c= System.today().addDays(500);
        update rp;
        
        String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = 'PC001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='EST';
        insertProd.Local_Title__c = lt.Id;
        insert insertProd;
        Test.startTest();  
        String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
        Opportunity createDeal = new Opportunity ();
        createDeal.RecordTypeId = oppRecTypeId;
        createDeal.Name = 'Test Deal';
        createDeal.Deal_Code__c  = 'DC001';
        createDeal.StageName = 'Planned';
        createDeal.Promo_Start_Date__c = System.today().addDays(-400);
        createDeal.Promo_End_Date__c = System.today().addDays(-200);
        createDeal.Start_Date__c = System.today().addDays(-400);
        createDeal.CloseDate = System.today().addDays(-200);
        createDeal.Account = accList[0];
        insert createDeal; 
        
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Status__c='Draft',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(300));
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       insert CaccListInsert;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=System.today().addDays(40),Price__c=20.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=System.today().addDays(119),Price__c=55.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = 'Reprice',Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=System.today().addDays(120),Expiry_Date__c=ca1.End_Date__c,Price__c=18.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca1.id,Category__c='Catalog',Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=13.99);
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
        capList.add(cap4);
        capList.add(cap5);
      
       WB_ClientAvailPriceHandler.recursiveInsert = false;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        WB_ClientAvailPriceHandler wb = new WB_ClientAvailPriceHandler();
        wb.validateTempCAP(capList,Null,Null);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
     
      
       
     Test.stopTest();
      
        
    }
    
    @isTest
    public static void announceTempCAP2(){
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        //Country__c c = tdu.createCountry();
        Country__c c = TestUtil.initCountry('Colombia', 'CO', 'COL');
        insert c;
        
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=t.id,Language__c=l.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
       
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
        rp.Exclusive_Date__c = System.today().addDays(-200);
        rp.Start_Date__c = System.today().addDays(-200);
        rp.End_Date__c = System.today().addDays(500);
        rp.Rights_End__c= System.today().addDays(500);
        update rp;
        
        String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = 'PC001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='EST';
        insertProd.Local_Title__c = lt.Id;
        insert insertProd;
        Test.startTest();  
        String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
        Opportunity createDeal = new Opportunity ();
        createDeal.RecordTypeId = oppRecTypeId;
        createDeal.Name = 'Test Deal';
        createDeal.Deal_Code__c  = 'DC001';
        createDeal.StageName = 'Planned';
        createDeal.Promo_Start_Date__c = System.today().addDays(-400);
        createDeal.Promo_End_Date__c = System.today().addDays(-200);
        createDeal.Start_Date__c = System.today().addDays(-400);
        createDeal.CloseDate = System.today().addDays(-200);
        createDeal.Account = accList[0];
        insert createDeal; 
        
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(300));
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       insert CaccListInsert;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Price__c=20.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=System.today().addDays(250),Price__c=20.99,Price_Tier__c = '10.3');
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=System.today().addDays(119),Price__c=55.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = 'Reprice',Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=System.today().addDays(120),Expiry_Date__c=ca1.End_Date__c,Price__c=18.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=System.today().addDays(305),Price__c=13.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=System.today().addDays(300));
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
        capList.add(cap4);
        capList.add(cap5);
        capList.add(cap6);
        capList.add(cap7);
      
       WB_ClientAvailPriceHandler.recursiveInsert = false;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        WB_ClientAvailPriceHandler wb = new WB_ClientAvailPriceHandler();
        wb.validateTempCAP(capList,Null,Null);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
     
      
       
     Test.stopTest();
      
        
    }
    
    
      private static testMethod void testPushToSFSUpdate() {
       
      Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
      
      List<Title__c> ListTitle=new List<Title__c>();
      Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
      ListTitle.add(title1);
      Title__c title2 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
      ListTitle.add(title2);
      insert ListTitle;
     
      Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='FR',Country_Code__c='FRA');
      insert countryFrance;
      countrySIDList.add(new Country_SID_Key__c(Name='TestFrance', Country_Code__c='FRA',Country_Code2_c__c='FR',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
      
      Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
      insert languageFrench;
      
      List<Local_Title__c> ListLocTitle=new List<Local_Title__c>();
      Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[0].Id,Country__c = countryFrance.Id,
                  Language__c =languageFrench.Id);
      ListLocTitle.add(local1);
      Local_Title__c local2 = new Local_Title__c(Name = 'local2',Title__c =ListTitle[1].Id,Country__c = countryFrance.Id,
                  Language__c =languageFrench.Id);
      ListLocTitle.add(local2);
      insert ListLocTitle;
      
      List<Commercial_Avail__c> ListCommAvl=new List<Commercial_Avail__c>();
      Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=ListTitle[0].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[0].Id,
          Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Confirmed',
          Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+11
          
      );
      ListCommAvl.add(releaseplan1);
      Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=ListTitle[1].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[1].Id,
          Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Confirmed',
          Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+11
          
      );
      ListCommAvl.add(releaseplan2);
      insert ListCommAvl;
      
      Agreement__c storefrontGoogle1 = new Agreement__c(
        Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=ListTitle[0].Content_Type__c,
        Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c=false,SAP_Customer_Number__c='12010421'
      );
      insert storefrontGoogle1; 
      storefrontGoogle1.SFS_Integration__c='Feature_EST_HD';
      update storefrontGoogle1;
      
      List<Pricing__c> ListPric=new List<Pricing__c>();
		Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,WS_Price__c=56.78,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
        );
        ListPric.add(price1);
        Pricing__c price2 = new Pricing__c(Name ='Pr2',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,WS_Price__c=57.78,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
        );
        ListPric.add(price2);
        
            Client_Avail__c clientAvail1 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Confirmed',Start_Date__c=date.today(),Price__c=56.78,
                End_Date__c=Date.today()+5
            );
           
         Client_Avail__c clientAvail2 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan2.Id, Client__c=acctGoogle.Id,Status__c='Confirmed',Start_Date__c=date.today(),Price__c=57.78,
                End_Date__c=Date.today()+5
            );
         
            List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
            clientAvailList.add(clientAvail1);
        clientAvailList.add(clientAvail2);
        insert clientAvailList;
        
      Test.startTest();
         WB_Batch_CAP_PushToSFS uca = new WB_Batch_CAP_PushToSFS('Push to SFS');
        Database.executeBatch(uca);
      Test.stopTest();  
      Client_Avail__c ca=[select id,Start_Date__c from Client_Avail__c where id=:clientAvailList[0].id];
      ca.Start_Date__c=Date.today()+1;
      update ca;
          Client_Avail_Price__c cap=[select id,Accounting_Category__c,Client_Avail__c,Push_to_SFS__c,Price__c from Client_Avail_Price__c where Client_Avail__c=:clientAvailList[0].id];
         cap.Push_to_SFS__c=Date.today()-1;
       cap.Price__c=57.78;
      update cap;  
    /*    Client_Avail_Price__c cap=[select id,Accounting_Category__c,Client_Avail__c,Push_to_SFS__c from Client_Avail_Price__c where Client_Avail__c=:clientAvailList[1].id];
        cap.Push_to_SFS__c=Date.today()-1;
        cap.Accounting_Category__c='Catalog';
      update cap; */
	}

    
}