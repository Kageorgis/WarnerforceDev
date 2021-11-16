@isTest(SeeAllData=false) 
private class WB_PBEP_Product_CreationHandler_Test{
    
    public static Account objAccount;
    public static Account objAccount1;
    public static Title__c t;
    public static Title__c episodeTitle;
    public static Playlist__c playlist;
    public static Playlist__c playlist_1;
    public static Language__c Language;
    public static Country__c Country; 
    public static Local_Title__c LT;
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    public static List<Local_Title__c> listlocaltitles;
    public static List<Commercial_Avail__c> listReleaseplan;
    public static Commercial_Avail__c releasePlan;
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    public static List<Client_Avail__c> listClientavails;
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    static Id rtAcDC =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Digital_Client'][0].Id;
    private static Id standardPricebookId ;
    public static Agreement__c storefrontGoogle1;
    //public static List<Client_Avail__c> listClientavails;
    static {
        if(standardPricebookId ==  null){
            standardPricebookId = System.Test.getStandardPricebookId();
        }
    }
    
    public static void setUpData(Boolean flag){
        
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
        /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       objAccount.RecordTypeID = rtAcc;
       objAccount.CurrencyIsoCode = 'USD';
       objAccount.Price_Book__c = pb.Id;  
       insert objAccount;
       
       objAccount1 = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       objAccount1.RecordTypeID = rtAcDC;
       objAccount1.CurrencyIsoCode = 'USD';
       objAccount1.Price_Book__c = pb.Id;  
       insert objAccount1;
        
       /*objAccount = TestUtil.initAccount();
        objAccount.Type='Global';
        insert objAccount;*/
        
        /* -- Title creation-- */
         t = new Title__c();
        t.Name = 'Vampire Diaries S01';
        t.Digital_Planning__c = 'Yes';
        t.Clear_to_Avail__c = true;
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.Formats__c = 'SD';
        t.US_TV_Air_Date__c = system.today();
        Insert t;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Vampire Diaries S01E01';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c = 'SD';
        Insert episodeTitle;
        
         Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Vampire Diaries S01E02';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle2.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        episodeTitle2.Formats__c = 'SD';
        Insert episodeTitle2;
        
        playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        playlist_1 = new Playlist__c();
        playlist_1.name = 'test playlist1';
        playlist_1.Version_Number__c = 1;
        playlist_1.Parent_Title__c = t.id;
        playlist_1.Playlist_Status__c = 'Active';
        insert playlist_1;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=episodeTitle.id;
        content.Playlist__c = playlist.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=episodeTitle2.id;
        content2.Playlist__c = playlist_1.id;
        contentlist.add(content2);
        insert contentlist;
        
         Country = New Country__c();
        Country.Name = 'India';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.TV_Day_After_US_Offset__c = 2;
        Country.TV_Day_After_Local_Offset__c = 1;
        Country.Generate_CRM_Product__c = true;
        insert Country;
        
         
        
         Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Code_2__c = 'en';
        Language.Language_Order__c = 1;
        insert Language;
        
        Pricing__c pricing5 = new Pricing__c();
        pricing5.Name = 'CheckPriceCode';
        pricing5.Account__c = objAccount1.id;
        pricing5.Country__c = Country.id;
        pricing5.Channel__c='VODi';
        pricing5.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing5.Price_Tier__c ='9';
        pricing5.Episode_Price_Tier__c='10';
        pricing5.Format__c='SD';
        lPricing.add(pricing5);
        
        Pricing__c pricing_ep = new Pricing__c();
        pricing_ep.Name = 'CheckPriceCode';
        pricing_ep.Account__c = objAccount1.id;
        pricing_ep.Country__c = Country.id;
        pricing_ep.Channel__c='VODi';
        pricing_ep.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing_ep.Price_Tier__c ='10';
        //pricing_ep.Episode_Price_Tier__c='10';
        pricing_ep.Format__c='SD';
        lPricing.add(pricing_ep);
        
        Pricing__c pricing51 = new Pricing__c();
        pricing51.Name = 'CheckPriceCode1';
        pricing51.Account__c = objAccount.id;
        pricing51.Country__c = Country.id;
        pricing51.Channel__c='VODi';
        pricing51.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing51.Price_Tier__c ='89.4';
        //pricing51.Episode_Price_Tier__c='89.4';
        pricing51.Format__c='SD';
        lPricing.add(pricing51);
        
        insert lPricing;
        
        /* for(Pricing__c pr : lPricing){
            system.debug('####Pricing:'+pr);
        } */
        
        
        listlocaltitles= new List<Local_Title__c>();
         LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist.id;
        LT.Price_Code__c = 'CheckPriceCode';
        LT.Category__c = 'TV Catalog';
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
        
        /* for(Local_Title__c lt1 : listlocaltitles){
           system.debug('####Local_Title__c:'+lt1); 
        } */
        
        Product_Creation_Batch_Setting__c pc = new Product_Creation_Batch_Setting__c();
        pc.Name = 'Default';
        pc.Generate_CRM_Product__c = true;
        pc.Last_N_Days__c = null;
        insert pc;
        
         String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = '000000001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='VODi';
        insertProd.Product_Format__c = 'SD';
        insertProd.Local_Title__c = LT.Id;
        insertProd.External_Id__c = 'IND_en_000000001_VODi_SD';
        insert insertProd;
        
         listReleaseplan = new List<Commercial_Avail__c>();
        releasePlan = new Commercial_Avail__c();
        releasePlan.Channel__c = 'VODi';
        releasePlan.Title__c=t.id;
        releasePlan.Languages__c = Language.id;
        releasePlan.Country_Lookup__c = Country.id;
        releasePlan.Format__c = 'SD';
        releasePlan.Language_Type__c = 'Sub & Audio';
        releasePlan.Exclusive_Date__c = date.today()-200;
        releasePlan.Start_Date__c = date.today()-100;
        releasePlan.End_Date__c = date.today()+100;
        releasePlan.Rights_End__c=date.today()+200;
        releasePlan.Status__c = 'Confirmed';
        releasePlan.Playlist__C = playlist.id;
        releasePlan.Local_Title__c = listlocaltitles[0].Id;
        listReleaseplan.add(releasePlan);
        
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
        
        /*String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = '000000001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='VODi';
        insertProd.Product_Format__c = 'SD';
        insertProd.Local_Title__c = LT.Id;
        insert insertProd;*/
        
       List<Commercial_Avail__c> rp = new List<Commercial_Avail__c>();
       rp = [SELECT ID, OwnerId, Country_Lookup__r.Country_Code__c, Title_Video_Version__c, Start_Date__c, End_Date__c,Title__r.Digital_Planning__c,Title__r.Clear_to_Avail__c, Title_Content_Type__c, Country_Lookup__r.Generate_CRM_Product__c, Channel__c, Format__c, Local_Title__r.Name, Local_Title__r.Local_Synopsis__c, Languages__r.Language_Code_2__c, Title__r.Genre__c,  Local_Title__r.Title_VV_F__c,Product__c  FROM Commercial_Avail__c ];
       /* for(Commercial_Avail__c c : rp){
           system.debug('Product__c:'+c.Product__c);
           system.debug('Country_Lookup__r.Country_Code__c:'+c.Country_Lookup__r.Country_Code__c);
           system.debug('Country.Generate_CRM_Product__c:'+c.Country_Lookup__r.Generate_CRM_Product__c);
           system.debug('Languages__r.Language_Code_2__c:'+c.Languages__r.Language_Code_2__c);
           system.debug('Title_Video_Version__c:'+c.Title_Video_Version__c);
           system.debug('Channel__c:'+c.Channel__c);
           system.debug('Local_Title__c:'+c.Local_Title__c);
           system.debug('Title__r.Clear_to_Avail__c:'+c.Title__r.Clear_to_Avail__c);
           system.debug('Title__r.Digital_Planning__c:'+c.Title__r.Digital_Planning__c);
           system.debug('End_Date__c:'+c.End_Date__c);
           system.debug('Format__c:'+c.Format__c);
           /*system.debug(':'+rp.);
           system.debug(':'+rp.);
           
       } 
       system.debug('$$$$rp:'+rp); */ 
       storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Episode;Season',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        storefrontGoogle1.Account__c = objAccount1.Id;
        /*TestUtil.initStoreFront(objAccount.Id, country.Id, listReleaseplan[0], t);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';*/
        insert storefrontGoogle1;
        
        
         WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
	    listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail);
        
       
        insert listClientavails;
         WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
         
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
    }
    
    private static testmethod void assignProductToReleasePlan(){
        setUpData(true);
        
        
         test.startTest();
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+5,Price__c = 32,Episode_Price_Tier__c = '10',Type__c='Reprice',Category__c = 'TV Catalog'));
        //clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+50,Price_Tier__c='14',Type__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
        
        List<Pricing__c> pricingList = new List<Pricing__c>();
        
        Pricing__c pricingRec = new Pricing__c();
        pricingRec.Name = 'CheckPriceCode12';
        pricingRec.Account__c = objAccount1.id;
        pricingRec.Country__c = Country.id;
        pricingRec.Channel__c='VODi';
        pricingRec.Content_Type__c='Season';
        pricingRec.WS_Price__c=28;
        //pricingRec.Price_Tier__c ='15.6';
        pricingRec.Episode_Price_Tier__c='89.4';
        pricingRec.Format__c='SD';
        pricingList.add(pricingRec);
        //insert pricingRec;
        
        Pricing__c pricingRec_ep = new Pricing__c();
        pricingRec_ep.Name = 'CheckPriceCode12';
        pricingRec_ep.Account__c = objAccount1.id;
        pricingRec_ep.Country__c = Country.id;
        pricingRec_ep.Channel__c='VODi';
        pricingRec_ep.Content_Type__c='Episode';
        //pricingRec_ep.WS_Price__c=28;
        pricingRec_ep.Price_Tier__c ='89.4';
        //pricingRec_ep.Episode_Price_Tier__c='89.4';
        pricingRec_ep.Format__c='SD';
        
        pricingList.add(pricingRec_ep);
        
        insert pricingList;
        
        
        
        clAvailPriceList[0].Price__c = 28;
        //clAvailPriceList[0].Price_Tier__c = '15.6';
        clAvailPriceList[0].Episode_Price_Tier__c = '89.4';
        //clAvailPriceList[0].Price_Code__c = 'CheckPriceCode12';
        update clAvailPriceList[0];
       
        list<Commercial_Avail__c> commavail = [Select ID, OwnerId, Country_Lookup__r.Country_Code__c, Title_Video_Version__c, Start_Date__c, End_Date__c,Title__r.Digital_Planning__c,Title__r.Clear_to_Avail__c, Title_Content_Type__c, Country_Lookup__r.Generate_CRM_Product__c, Channel__c, Format__c, Local_Title__r.Name, Local_Title__r.Local_Synopsis__c, Languages__r.Language_Code_2__c, Title__r.Genre__c,  Local_Title__r.Title_VV_F__c,Product__c FROM Commercial_Avail__c];
        //system.debug();
        Map<Id,Commercial_Avail__c> RPupdateMap = new Map<Id,Commercial_Avail__c>();
        for(Commercial_Avail__c rp : commavail){
            RPupdateMap.put(rp.Id, rp);
        }
        List<Product2> product21 = new List<Product2>();
        product21 = [Select Id,External_Id__c FROM Product2];
        //system.debug('product2:'+product21);
        WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
        wc.assignProductToReleasePlan(commavail);
        wc.updateAssignedProductsFromRP(commavail, RPupdateMap);
        //wc.insertOrUpdatePriceBookEntryPeriod(clAvailPriceList);
        test.stopTest();
        
      
    }
    
    private static testmethod void assignProductToReleasePlan1(){
        setUpData(true);
        
        List<Product2> lstProdUpdated = new List<Product2>();
        List<Id> ProdRP = new List<Id> ();
         test.startTest();
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+5,Price_Tier__c = '9',Episode_Price_Tier__c = '10',Type__c='Reprice',Category__c = 'TV Catalog'));
        //clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+50,Price_Tier__c='14',Type__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
        
        
        List<Pricing__c> pricingList = new List<Pricing__c>();
        
        Pricing__c pricingRec = new Pricing__c();
        pricingRec.Name = 'CheckPriceCode12';
        pricingRec.Account__c = objAccount1.id;
        pricingRec.Country__c = Country.id;
        pricingRec.Channel__c='VODi';
        pricingRec.Content_Type__c='Season';
        pricingRec.Price_Tier__c ='15.6';
        //pricingRec.Price_Tier__c ='15.6';
        pricingRec.Episode_Price_Tier__c='89.4';
        pricingRec.Format__c='SD';
        pricingList.add(pricingRec);
        //insert pricingRec;
        
        Pricing__c pricingRec_ep = new Pricing__c();
        pricingRec_ep.Name = 'CheckPriceCode12';
        pricingRec_ep.Account__c = objAccount1.id;
        pricingRec_ep.Country__c = Country.id;
        pricingRec_ep.Channel__c='VODi';
        pricingRec_ep.Content_Type__c='Episode';
        //pricingRec_ep.WS_Price__c=28;
        pricingRec_ep.Price_Tier__c ='89.4';
        //pricingRec_ep.Episode_Price_Tier__c='89.4';
        pricingRec_ep.Format__c='SD';
        
        pricingList.add(pricingRec_ep);
        
        insert pricingList;
        
        //clAvailPriceList[0].Price__c = 28;
        clAvailPriceList[0].Price_Tier__c = '15.6';
        clAvailPriceList[0].Episode_Price_Tier__c = '89.4';
        //clAvailPriceList[0].Price_Code__c = 'CheckPriceCode12';
        update clAvailPriceList[0];
       
        list<Commercial_Avail__c> commavail = [Select ID, OwnerId, Country_Lookup__r.Country_Code__c, Title_Video_Version__c, Start_Date__c, End_Date__c,Title__r.Digital_Planning__c,Title__r.Clear_to_Avail__c, Title_Content_Type__c, Country_Lookup__r.Generate_CRM_Product__c, Channel__c, Format__c, Local_Title__r.Name, Local_Title__r.Local_Synopsis__c, Languages__r.Language_Code_2__c, Title__r.Genre__c,  Local_Title__r.Title_VV_F__c,Product__c FROM Commercial_Avail__c];
        //system.debug();
        Map<Id,Commercial_Avail__c> RPupdateMap = new Map<Id,Commercial_Avail__c>();
        for(Commercial_Avail__c rp : commavail){
            RPupdateMap.put(rp.Id, rp);
        }
       
        List<Product2> product21 = new List<Product2>();
        product21 = [Select Id,External_Id__c,Release_Plan__c FROM Product2];
        //system.debug('product2:'+product21);
        WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
        wc.assignProductToReleasePlan(commavail);
        wc.updateAssignedProductsFromRP(commavail, RPupdateMap);
        //wc.insertOrUpdatePriceBookEntryPeriod(clAvailPriceList);
        test.stopTest();
        
      
    }
    
    //Method added by Akash to cover product Street_Date__c update
    private static testMethod void AssignProductsToRP(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
       
        Country__c countryUSA =new Country__c(Name ='USA',Country_Code2__c ='US',Country_Code__c='USA');
        insert countryUSA;
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        insert languageEnglish;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
            Country__c = countryUSA.Id,Channel__c ='DTD',Format__c ='HD'
        );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryUSA.Id,
                                Language__c =languageEnglish.Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        
            
            List<Commercial_Avail__c> rpTobeUpdate = new List<Commercial_Avail__c>();
            List<Commercial_Avail__c> rpTobeUpdateFinal = new List<Commercial_Avail__c>();
            List<Commercial_Avail__c> rpNewlist = new List<Commercial_Avail__c>();
            Map<Id,Commercial_Avail__c> RPupdateMap = new Map<Id,Commercial_Avail__c>();
            
            Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryUSA.Id,Local_Title__c = local1.Id,
                    Languages__c=languageEnglish.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+7,Rights_End__c=date.today()+10
                    
            );
            rpTobeUpdate.add(releaseplan1);
            
            Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryUSA.Id,Local_Title__c = local1.Id,
                    Languages__c=languageEnglish.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                    Exclusive_Date__c = date.today()+10, Start_Date__c=date.today()+10,End_Date__c= date.today()+20,Rights_End__c=date.today()+20
                    
            );
            rpTobeUpdate.add(releaseplan2);
            insert rpTobeUpdate;
            
            Test.startTest();
            
            RPupdateMap.put(releaseplan1.Id, releaseplan1);
            RPupdateMap.put(releaseplan2.Id, releaseplan2);
            
            List<Product2> product21 = new List<Product2>();
            product21 = [Select Id,External_Id__c,Release_Plan__c,Street_Date__c FROM Product2 Where Release_Plan__c IN : rpTobeUpdate];
            
            //System.assertEquals(rpTobeUpdate[0].id,product21[0].Release_Plan__c);
            
            system.debug('Checking product21 List from Test class Before Update--->>'+product21);
            
            rpTobeUpdate[0].Start_Date__c = date.today()+3;
            update rpTobeUpdate;
            
            WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
            wc.assignProductToReleasePlan(rpTobeUpdate);
            wc.updateAssignedProductsFromRP(rpTobeUpdate, RPupdateMap);
            
            delete rpTobeUpdate[0];
            
            rpTobeUpdate[1].Start_Date__c = date.today()+16;
            update rpTobeUpdate[1];
            product21 = [Select Id,External_Id__c,Release_Plan__c,Street_Date__c FROM Product2 Where Release_Plan__c IN : rpTobeUpdate];
            wc.updateAssignedProductsFromRP(rpTobeUpdate, RPupdateMap);
            
            
            delete rpTobeUpdate[1];
            product21 = [Select Id,External_Id__c,Release_Plan__c,Street_Date__c FROM Product2 Where Release_Plan__c =: null OR Release_Plan__c =: ''];
            wc.updateAssignedProductsFromRP(rpTobeUpdate, RPupdateMap);
            
            
            Commercial_Avail__c releaseplan3 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryUSA.Id,Local_Title__c = local1.Id,
                    Languages__c=languageEnglish.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                    Exclusive_Date__c = date.today()+30, Start_Date__c=date.today()+30,End_Date__c= date.today()+40,Rights_End__c=date.today()+40
                    
            );
            rpTobeUpdateFinal.add(releaseplan3);
            insert rpTobeUpdateFinal;
            
            rpTobeUpdateFinal[0].Start_Date__c = System.today() + 31;
            update rpTobeUpdateFinal;
            
            RPupdateMap.put(releaseplan3.id, releaseplan3);
            product21 = [Select Id,External_Id__c,Release_Plan__c,Street_Date__c FROM Product2 Where Release_Plan__c =:releaseplan3.id];
            wc.updateAssignedProductsFromRP(rpTobeUpdateFinal, RPupdateMap);
            system.debug('Checking product21 List from Test class After Update--->>'+product21);
            
        Test.stopTest();
    }
    
        //Method added by Akash
    @isTest
    static void createErrorLogTest() {
        
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        insert countryJapan;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
        );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                Exclusive_Date__c = date.today()-5, Start_Date__c=date.today(),End_Date__c= date.today()+3,Rights_End__c=date.today()+5
                
        );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-5, Start_Date__c=date.today(),End_Date__c= date.today()+3,Rights_End__c=date.today()+5
        );
        
        Test.startTest();
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        //Client_Start_Ovver__c = date.today()+2,End_Date__c=releaseplan1.End_Date__c
        /*Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft'
            
            
        );*/
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft', Start_Date__c = date.today()+2,End_Date__c=releaseplan1.End_Date__c
            
            
        );
       
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //clientAvailList.add(clientAvail2);
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        
        System.runAs(u){
            insert clientAvailList;
            //WB_PriceUtility.createErrorLog(clientAvailList, 'error');
            
        }
        Test.stopTest();
    }
  
}