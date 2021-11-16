@isTest(SeeAllData=false) 
public class WB_Batch_PBEP_RateCardUpdate_Test{
    
    private static Id standardPricebookId ;
    public static List<Agreement__c> sfList = new List<Agreement__c>();
    static {
        if(standardPricebookId ==  null){
            standardPricebookId = System.Test.getStandardPricebookId();
        }
    }
    public static Account objAccount;
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    public static Account objAccount1;
    public static Account objAccount2;
    public static Account objAccount3;
    public static Account objAccount4;
    public static Account objAccount5;
    static Id rtAcDC =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Digital_Client'][0].Id;
    public static Title__c title;
     public static Title__c title1;
      public static Title__c title3;
       public static Title__c title4;
       public static Title__c title5;
       public static Title__c title6;
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    public static Country__c Country; 
    public static List<Local_Title__c> listlocaltitles;
    public static Language__c Language;
    public static Local_Title__c LT;
    public static Local_Title__c LT1;
    public static Local_Title__c LT2;
    public static Local_Title__c LT3;
    public static Local_Title__c LT4;
    public static List<Commercial_Avail__c> listReleaseplan;
    public static Commercial_Avail__c releasePlan;
    public static Commercial_Avail__c releasePlan1;
    public static Commercial_Avail__c releasePlan2;
    public static Agreement__c storefrontGoogle1;
    public static Agreement__c storefrontGoogle2;
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    public static List<Client_Avail__c> listClientavails;
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    public static List<Rate_Card__c> ratecardList = new List<Rate_Card__c>();
    
    public static void setUpData(Boolean flag){
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
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
       
       title = new Title__c();
       title.Name = 'Vampire Diaries S01';
       title.Digital_Planning__c = 'Yes';
       title.Clear_to_Avail__c = true;
       title.Content_Type__c = 'Season';
       title.Video_Version__c = '000000001';
       title.MPM__c = Mpm.id;
       title.Formats__c = 'SD;HD';
       title.US_TV_Air_Date__c = system.today();
       insert title;
       
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
       
       Pricing__c pricing6 = new Pricing__c();
       pricing6.Name = 'CheckPriceCode';
       pricing6.Account__c = objAccount1.id;
       pricing6.Country__c = Country.id;
       pricing6.Channel__c='EST';
       pricing6.Content_Type__c='Season';
       //pricing1.WS_Price__c=28;
       pricing6.Price_Tier__c ='9';
       pricing6.Episode_Price_Tier__c='10';
       pricing6.Format__c='HD';
       lPricing.add(pricing6);
       
       Pricing__c pricing6_ep = new Pricing__c();
       pricing6_ep.Name = 'CheckPriceCode';
       pricing6_ep.Account__c = objAccount1.id;
       pricing6_ep.Country__c = Country.id;
       pricing6_ep.Channel__c='VODi';
       pricing6_ep.Content_Type__c='Episode';
       //pricing1.WS_Price__c=28;
       pricing6_ep.Price_Tier__c ='10';
       //pricing6_ep.Episode_Price_Tier__c='10';
       pricing6_ep.Format__c='SD';
       lPricing.add(pricing6_ep);
       
       Pricing__c pricing1 = new Pricing__c();
       pricing1.Name = 'CheckPriceCode1';
       pricing1.Account__c = objAccount1.id;
       pricing1.Country__c = Country.id;
       pricing1.Channel__c='EST';
       pricing1.Content_Type__c='Season';
       //pricing1.WS_Price__c=28;
       pricing1.Price_Tier__c ='test2';
       pricing1.Episode_Price_Tier__c='reprice12';
       pricing1.Format__c='HD';
       lPricing.add(pricing1);
       
       Pricing__c pricing3 = new Pricing__c();
       pricing3.Name = 'CheckPriceCode2';
       pricing3.Account__c = objAccount1.id;
       pricing3.Country__c = Country.id;
       pricing3.Channel__c='Hotel';
       pricing3.Content_Type__c='Season';
       //pricing3.WS_Price__c=28;
       pricing3.Price_Tier__c ='test2';
       pricing3.Episode_Price_Tier__c='reprice12';
       pricing3.Format__c='SD';
       lPricing.add(pricing3);
    
       insert lPricing;
       
       listlocaltitles= new List<Local_Title__c>();
       LT = New Local_Title__c();
       LT.Name = title.Name;
       LT.Title__c = title.Id;
       LT.Country__c = Country.Id;
       LT.Language__c = Language.Id;
       LT.Local_TV_Air_Date__c = date.today();
       //LT.Playlist__C = playlist.id;
       LT.Price_Code__c = 'CheckPriceCode';
       LT.Category__c = 'TV Catalog';
       LT.Local_DVD_Release_Date__c = system.today();
       listlocaltitles.add(LT);
       
       insert listlocaltitles;
       
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
       releasePlan.Title__c=title.id;
       releasePlan.Languages__c = Language.id;
       releasePlan.Country_Lookup__c = Country.id;
       releasePlan.Format__c = 'SD';
       releasePlan.Language_Type__c = 'Sub & Audio';
       releasePlan.Exclusive_Date__c = date.today()-200;
       releasePlan.Start_Date__c = date.today()-100;
       releasePlan.End_Date__c = date.today()+100;
       releasePlan.Rights_End__c=date.today()+200;
       releasePlan.Status__c = 'Confirmed';
       //releasePlan.Playlist__C = playlist.id;
       releasePlan.Local_Title__c = listlocaltitles[0].Id;
       listReleaseplan.add(releasePlan);
       
       releasePlan1 = new Commercial_Avail__c();
       releasePlan1.Channel__c = 'EST';
       releasePlan1.Title__c=title.id;
       releasePlan1.Languages__c = Language.id;
       releasePlan1.Country_Lookup__c = Country.id;
       releasePlan1.Format__c = 'HD';
       releasePlan1.Language_Type__c = 'Sub & Audio';
       releasePlan1.Exclusive_Date__c = date.today()-200;
       releasePlan1.Start_Date__c = date.today()-100;
       releasePlan1.End_Date__c = date.today()+100;
       releasePlan1.Rights_End__c=date.today()+200;
       releasePlan1.Status__c = 'Confirmed';
       //releasePlan.Playlist__C = playlist.id;
       releasePlan1.Local_Title__c = listlocaltitles[0].Id;
       listReleaseplan.add(releasePlan1);
       
       releasePlan2 = new Commercial_Avail__c();
       releasePlan2.Channel__c = 'Hotel';
       releasePlan2.Title__c=title.id;
       releasePlan2.Languages__c = Language.id;
       releasePlan2.Country_Lookup__c = Country.id;
       releasePlan2.Format__c = 'SD';
       releasePlan2.Language_Type__c = 'Sub & Audio';
       releasePlan2.Exclusive_Date__c = date.today()-200;
       releasePlan2.Start_Date__c = date.today()-100;
       releasePlan2.End_Date__c = date.today()+100;
       releasePlan2.Rights_End__c=date.today()+200;
       releasePlan2.Status__c = 'Confirmed';
       //releasePlan.Playlist__C = playlist.id;
       releasePlan2.Local_Title__c = listlocaltitles[0].Id;
       listReleaseplan.add(releasePlan2);
       
       insert listReleaseplan;
       
       storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Episode;Season',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD;HD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi;EST;Hotel',
                    Country__c = Country.ID
                    
            );
       storefrontGoogle1.CRM_Account__c = objAccount.Id;      
       storefrontGoogle1.Status__c = 'Active';
       storefrontGoogle1.Account__c = objAccount1.Id;
       storefrontGoogle1.SAP_Customer_Number__c='12010421';
       //storefrontGoogle1.CRM_Storefront__c = true;
       
       insert storefrontGoogle1;
       
       WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Start_Date__c = system.today()+2;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = 'test2';
        clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail);
        
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan[1], listlocaltitles[0].Id);
        clientAvail1.Start_Date__c = system.today()+2;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Status__c = 'Tentative';
        clientAvail1.Price_Tier_Text__c = 'test2';
        clientAvail1.Episode_Price_Tier__c = 'reprice12';
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        //clientAvail1.APO_Date__c = system.today()-4;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan[2], listlocaltitles[0].Id);
        clientAvail2.Start_Date__c = system.today()-2;
        clientAvail2.End_Date__c = system.today()+70;
        clientAvail2.Status__c = 'Tentative';
        clientAvail2.Price_Tier_Text__c = 'test2';
        clientAvail2.Episode_Price_Tier__c = 'reprice12';
        clientAvail2.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail2.Storefront__c = storefrontGoogle1.Id;
        //clientAvail2.APO_Date__c = system.today()-4;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail2);
       
        insert listClientavails;
         WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
         
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
       
       
       
       
    }
    
    @isTest
    public static void rateCardUpdatesTest(){
    
        setUpData(true);
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = listReleaseplan[0].Channel__c;
        rc.Country__c = Country.Id;
        rc.Account__c = objAccount1.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = title.Content_Type__c;
        rc.Format__c = listReleaseplan[0].Format__c;
        rc.Price_Tier__c = '9';
        rc.Storefront__c = storefrontGoogle1.Id;
        rc.Rate_Card_Type__c = 'Step DVD 6/18';
        rc.WSP1__c = 5.9;
        rc.WSP2__c = 6.3;
        rc.WSP3__c = 2.3;

        
        ratecardList.add(rc);
        
        Rate_Card__c rc1 = new Rate_Card__c();
        rc1.Channel__c = listReleaseplan[1].Channel__c;
        rc1.Country__c = Country.Id;
        rc1.Account__c = objAccount1.Id;
        rc1.Start_Date__c = date.today();
        rc1.End_Date__c = date.today()+200;
        rc1.Content_Type__c = title.Content_Type__c;
        rc1.Format__c = listReleaseplan[1].Format__c;
        rc1.Price_Tier__c = 'test2';
        rc1.Storefront__c = storefrontGoogle1.Id;
        rc1.Rate_Card_Type__c = 'Step DVD 6/18';
        rc1.WSP1__c = 5.9;
        rc1.WSP2__c = 6.3;
        rc1.WSP3__c = 2.3;

        
        ratecardList.add(rc1);
        
        Rate_Card__c rc3 = new Rate_Card__c();
        rc3.Channel__c = listReleaseplan[2].Channel__c;
        rc3.Country__c = Country.Id;
        rc3.Account__c = objAccount1.Id;
        rc3.Start_Date__c = date.today()-4;
        rc3.End_Date__c = date.today()+200;
        rc3.Content_Type__c = title.Content_Type__c;
        rc3.Format__c = listReleaseplan[2].Format__c;
        rc3.Price_Tier__c = 'test2';
        rc3.Storefront__c = storefrontGoogle1.Id;
        rc3.Rate_Card_Type__c = 'Step DVD 6/18';
        rc3.WSP1__c = 5.9;
        rc3.WSP2__c = 6.3;
        rc3.WSP3__c = 2.3;

        
        ratecardList.add(rc3);
        
        insert ratecardList;
        
        
        test.startTest();
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+5,Price_Tier__c = '9',Episode_Price_Tier__c = '10',Type__c='Reprice',Category__c = 'TV Catalog'));
        //clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+50,Price_Tier__c='14',Type__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
        
        storefrontGoogle1.CRM_Storefront__c = true;
        update storefrontGoogle1;
        
        List<Agreement__c> sfList = [Select Id,CRM_Storefront__c from Agreement__c];
        system.debug('sfList:'+sfList);
        
        WB_Batch_PBEP_RateCardUpdate wb = new WB_Batch_PBEP_RateCardUpdate(sfList,true,true);
        
        Database.executeBatch(wb);
        test.stopTest();
        
        
    }
    @isTest
    public static void RC_EpiUpdate(){
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB2';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
       List<MPM__c> Mpmlist=new List<MPM__c>();
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        Mpmlist.add(Mpm);
        
        MPM__c Mpm1 = new MPM__c(); 
        Mpm1.Name = '20636463';
        Mpm1.MPM_Number__c = '20636465'; 
        Mpm1.Film_Color__c = 'Color';
        Mpmlist.add(Mpm1);
        insert Mpmlist;
        
      objAccount2 = new Account(Name ='TestAccount1 ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       objAccount2.RecordTypeID = rtAcc;
       objAccount2.CurrencyIsoCode = 'USD';
       objAccount2.Price_Book__c = pb.Id;  
       insert objAccount2;
         objAccount3 = new Account(Name ='TestAccount2 ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       objAccount3.RecordTypeID = rtAcDC;
       objAccount3.CurrencyIsoCode = 'USD';
       objAccount3.Price_Book__c = pb.Id;  
       insert objAccount3;
       
       List<Title__c> titlelist=new List<Title__c>();
       title3 = new Title__c();
       title3.Name = 'Vampire Diaries S01';
       title3.Digital_Planning__c = 'Yes';
       title3.Clear_to_Avail__c = true;
       title3.Content_Type__c = 'Season';
       title3.Video_Version__c = '000000001';
       title3.MPM__c = Mpm.id;
       title3.Formats__c = 'SD;HD';
       title3.US_TV_Air_Date__c = system.today();
       titlelist.add(title3);
      
        title4 = new Title__c();
       title4.Name = 'Vampire Diaries E01';
       title4.Digital_Planning__c = 'Yes';
       title4.Clear_to_Avail__c = true;
       title4.Content_Type__c = 'Episode';
       title4.Video_Version__c = '000000002';
       title4.MPM__c = Mpm1.id;
       title4.Formats__c = 'SD;HD';
       title4.US_TV_Air_Date__c = system.today();
       titlelist.add(title4);
       insert titlelist;
       
        List<Playlist__c> playlist = new List<Playlist__c>();
        Playlist__c playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = title3.id;
        playlist123.Playlist_Status__c = 'Active';
        playlist.add(playlist123);
    
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=title4.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
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
       
       listlocaltitles= new List<Local_Title__c>();
       LT1 = New Local_Title__c();
       LT1.Name = title3.Name;
       LT1.Title__c = title3.Id;
       LT1.Country__c = Country.Id;
       LT1.Language__c = Language.Id;
       LT1.Local_TV_Air_Date__c = date.today();
       //LT.Playlist__C = playlist.id;
       LT1.Price_Code__c = 'CheckPriceCodeE';
       LT1.Category__c = 'TV Catalog';
       LT1.Local_DVD_Release_Date__c = system.today();
       listlocaltitles.add(LT1);
       
       LT2 = New Local_Title__c();
       LT2.Name = title4.Name;
       LT2.Title__c = title4.Id;
       LT2.Country__c = Country.Id;
       LT2.Language__c = Language.Id;
       LT2.Local_TV_Air_Date__c = date.today();
       //LT.Playlist__C = playlist.id;
       LT2.Price_Code__c = 'CheckPriceCodeE';
       LT2.Category__c = 'TV Catalog';
       LT2.Local_DVD_Release_Date__c = system.today();
       listlocaltitles.add(LT2);
       
       insert listlocaltitles;
     
       Pricing__c pricing1 = new Pricing__c();
       pricing1.Name = 'CheckPriceCodeE';
       pricing1.Account__c = objAccount3.id;
       pricing1.Country__c = Country.id;
       pricing1.Channel__c='EST';
       pricing1.Content_Type__c='Season';
       //pricing1.WS_Price__c=28;
       pricing1.Price_Tier__c ='Tier 1';
       pricing1.Episode_Price_Tier__c='Tier 5';
       pricing1.Format__c='HD';
       lPricing.add(pricing1);
       
       Pricing__c pricing2 = new Pricing__c();
       pricing2.Name = 'CheckPriceCodeE';
       pricing2.Account__c = objAccount3.id;
       pricing2.Country__c = Country.id;
       pricing2.Channel__c='EST';
       pricing2.Content_Type__c='Episode';
       //pricing1.WS_Price__c=28;
       pricing2.Price_Tier__c ='Tier 5';
       //pricing2.Episode_Price_Tier__c='10';
       pricing2.Format__c='HD';
       lPricing.add(pricing2); 
       
       insert lPricing;
       
       Product_Creation_Batch_Setting__c pc = new Product_Creation_Batch_Setting__c();
       pc.Name = 'Default';
       pc.Generate_CRM_Product__c = true;
       pc.Last_N_Days__c = null;
       insert pc;
       
       String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
       Product2 insertProd = new Product2();
       insertProd.RecordTypeId = productRecTypeId;
       insertProd.Name = 'Test Product';
       insertProd.ProductCode = '000000002';
       insertProd.Type__c = 'Video Digital';
       insertProd.Product_Market__c ='EST';
       insertProd.Product_Format__c = 'SD;HD';
       insertProd.Local_Title__c = LT1.Id;
       insertProd.External_Id__c = 'IND_en_000000001_EST_HD';
       insert insertProd;
       
    
      listReleaseplan = new List<Commercial_Avail__c>();
       releasePlan = new Commercial_Avail__c();
       releasePlan.Channel__c = 'EST';
       releasePlan.Title__c=title3.id;
       releasePlan.Languages__c = Language.id;
       releasePlan.Country_Lookup__c = Country.id;
       releasePlan.Format__c = 'HD';
       releasePlan.Language_Type__c = 'Sub & Audio';
       releasePlan.Exclusive_Date__c = date.today()-200;
       releasePlan.Start_Date__c = date.today()-100;
       releasePlan.End_Date__c = date.today()+100;
       releasePlan.Rights_End__c=date.today()+200;
       releasePlan.Status__c = 'Confirmed';
       //releasePlan.Playlist__C = playlist.id;
       releasePlan.Local_Title__c = listlocaltitles[0].Id;
       listReleaseplan.add(releasePlan);
       insert listReleaseplan;
       
        storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount2.Id,
                    Active__c = true,
                    Content_Type__c = 'Episode;Season',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD;HD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi;EST;Hotel',
                    Country__c = Country.ID
            );
       storefrontGoogle1.CRM_Account__c = objAccount2.Id;      
       storefrontGoogle1.Status__c = 'Active';
       storefrontGoogle1.Account__c = objAccount3.Id;
       storefrontGoogle1.SAP_Customer_Number__c='12010421';
       
       insert storefrontGoogle1;
       
       List<Rate_Card__c> ratecardlist=new List<Rate_Card__c>();
       
       Rate_Card__c rc3 = new Rate_Card__c();
        rc3.Channel__c = listReleaseplan[0].Channel__c;
        rc3.Country__c = Country.Id;
        rc3.Account__c = objAccount3.Id;
        rc3.Start_Date__c = date.today();
        rc3.End_Date__c = date.today()+200;
        rc3.Content_Type__c = title3.Content_Type__c;
        rc3.Format__c = listReleaseplan[0].Format__c;
        rc3.Price_Tier__c = 'Tier 1'; 
        rc3.Storefront__c = storefrontGoogle1.Id;
        rc3.Rate_Card_Type__c = 'Standard';
        rc3.WSP1__c = 5.9;
        ratecardlist.add(rc3);
        
         Rate_Card__c rc4 = new Rate_Card__c();
        rc4.Channel__c = listReleaseplan[0].Channel__c;
        rc4.Country__c = Country.Id;
        rc4.Account__c = objAccount3.Id;
        rc4.Start_Date__c = date.today();
        rc4.End_Date__c = date.today()+200;
        rc4.Content_Type__c = title4.Content_Type__c;
        rc4.Format__c = listReleaseplan[0].Format__c;
        rc4.Price_Tier__c = 'Tier 5';
        rc4.Storefront__c = storefrontGoogle1.Id;
        rc4.Rate_Card_Type__c = 'Standard';
        rc4.WSP1__c = 5.9;
        ratecardlist.add(rc4);
        
        
        insert ratecardlist;
    
        
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
        WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail4 = TestUtil.initClientAvail(objAccount3.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail4.Start_Date__c = system.today()+5;
        clientAvail4.End_Date__c = system.today()+70;
        clientAvail4.Status__c = 'Tentative';
        //clientAvail4.Price__c = 45;
        //clientAvail4.Episode_Price__c = 65;
        clientAvail4.Price_Tier_Text__c = 'Tier 1';
        clientAvail4.Episode_Price_Tier__c = 'Tier 5';
        clientAvail4.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail4.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail4);
        
         Client_Avail__c clientAvail5 = TestUtil.initClientAvail(objAccount3.Id, listReleaseplan[0], listlocaltitles[1].Id);
        clientAvail5.Start_Date__c = system.today()+5;
        clientAvail5.End_Date__c = system.today()+70;
        clientAvail5.Status__c = 'Tentative';
        //clientAvail5.Price__c = 65;
        //clientAvail4.Price_Tier_Text__c = 'Tier 5';
        //clientAvail4.Episode_Price_Tier__c = '10';
        clientAvail5.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail5.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail5);
        test.startTest();
        insert listClientavails;  
        
        listClientavails[1].Parent_Client_Avail__c= listClientavails[0].id;
        listClientavails[1].Recalculate_Playlist_Avails__c='';
        
        update listClientavails[1];
      
        
        storefrontGoogle1.CRM_Storefront__c = true;
        update storefrontGoogle1;
        
        List<Agreement__c> sfList = [Select Id,CRM_Storefront__c from Agreement__c];
        system.debug('sfList:'+sfList);
        
        WB_Batch_PBEP_RateCardUpdate wb = new WB_Batch_PBEP_RateCardUpdate(sfList,true,true);
        
        Database.executeBatch(wb);
        
        test.stopTest();
        
    
    }
  @isTest
    public static void RC_EpiUpdateTest(){
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB23';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
       List<MPM__c> Mpmlist=new List<MPM__c>();
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '20636467';
        Mpm.MPM_Number__c = '20636467'; 
        Mpm.Film_Color__c = 'Color';
        Mpmlist.add(Mpm);
        
        MPM__c Mpm1 = new MPM__c(); 
        Mpm1.Name = '206364634';
        Mpm1.MPM_Number__c = '206364654'; 
        Mpm1.Film_Color__c = 'Color';
        Mpmlist.add(Mpm1);
        insert Mpmlist;
        
      objAccount4 = new Account(Name ='TestAccount11',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       objAccount4.RecordTypeID = rtAcc;
       objAccount4.CurrencyIsoCode = 'USD';
       objAccount4.Price_Book__c = pb.Id;  
       insert objAccount4;
         objAccount5 = new Account(Name ='TestAccount22 ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       objAccount5.RecordTypeID = rtAcDC;
       objAccount5.CurrencyIsoCode = 'USD';
       objAccount5.Price_Book__c = pb.Id;  
       insert objAccount5;
       
       List<Title__c> titlelist=new List<Title__c>();
       title5 = new Title__c();
       title5.Name = 'Vampire Diaries S002';
       title5.Digital_Planning__c = 'Yes';
       title5.Clear_to_Avail__c = true;
       title5.Content_Type__c = 'Season';
       title5.Video_Version__c = '0000000011';
       title5.MPM__c = Mpm.id;
       title5.Formats__c = 'SD;HD';
       title5.US_TV_Air_Date__c = system.today();
       titlelist.add(title5);
      
        title6 = new Title__c();
       title6.Name = 'Vampire Diaries E01';
       title6.Digital_Planning__c = 'Yes';
       title6.Clear_to_Avail__c = true;
       title6.Content_Type__c = 'Episode';
       title6.Video_Version__c = '0000000022';
       title6.MPM__c = Mpm1.id;
       title6.Formats__c = 'SD;HD';
       title6.US_TV_Air_Date__c = system.today();
       titlelist.add(title6);
       insert titlelist;
       
        List<Playlist__c> playlist = new List<Playlist__c>();
        Playlist__c playlist1234 = new Playlist__c();
        playlist1234.name = 'test playlist';
        playlist1234.Version_Number__c = 11;
        playlist1234.Parent_Title__c = title5.id;
        playlist1234.Playlist_Status__c = 'Active';
        playlist.add(playlist1234);
    
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=title6.id;
        content.Playlist__c = playlist1234.id;
        contentlist.add(content);
        
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
       
       listlocaltitles= new List<Local_Title__c>();
       LT3 = New Local_Title__c();
       LT3.Name = title5.Name;
       LT3.Title__c = title5.Id;
       LT3.Country__c = Country.Id;
       LT3.Language__c = Language.Id;
       LT3.Local_TV_Air_Date__c = date.today();
       //LT.Playlist__C = playlist.id;
       LT3.Price_Code__c = 'CheckPriceCodeEPP';
       LT3.Category__c = 'TV Catalog';
       LT3.Local_DVD_Release_Date__c = system.today();
       listlocaltitles.add(LT3);
       
       LT4 = New Local_Title__c();
       LT4.Name = title6.Name;
       LT4.Title__c = title6.Id;
       LT4.Country__c = Country.Id;
       LT4.Language__c = Language.Id;
       LT4.Local_TV_Air_Date__c = date.today();
       //LT.Playlist__C = playlist.id;
       LT4.Price_Code__c = 'CheckPriceCodeEPP';
       LT4.Category__c = 'TV Catalog';
       LT4.Local_DVD_Release_Date__c = system.today();
       listlocaltitles.add(LT4);
       
       insert listlocaltitles;
     
       Pricing__c pricing3 = new Pricing__c();
       pricing3.Name = 'CheckPriceCodeE';
       pricing3.Account__c = objAccount5.id;
       pricing3.Country__c = Country.id;
       pricing3.Channel__c='EST';
       pricing3.Content_Type__c='Season';
       //pricing1.WS_Price__c=28;
       pricing3.WS_Price__c=10;
       pricing3.Episode_Price__c=20;
       pricing3.Format__c='HD';
       lPricing.add(pricing3);
       
       Pricing__c pricing4 = new Pricing__c();
       pricing4.Name = 'CheckPriceCodeE';
       pricing4.Account__c = objAccount5.id;
       pricing4.Country__c = Country.id;
       pricing4.Channel__c='EST';
       pricing4.Content_Type__c='Episode';
       //pricing1.WS_Price__c=28;
       pricing4.WS_Price__c=20;
       //pricing2.Episode_Price_Tier__c='10';
       pricing4.Format__c='HD';
       lPricing.add(pricing4); 
       
       insert lPricing;
       
       Product_Creation_Batch_Setting__c pc = new Product_Creation_Batch_Setting__c();
       pc.Name = 'Default';
       pc.Generate_CRM_Product__c = true;
       pc.Last_N_Days__c = null;
       insert pc;
       
       String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
       Product2 insertProd = new Product2();
       insertProd.RecordTypeId = productRecTypeId;
       insertProd.Name = 'Test Product1';
       insertProd.ProductCode = '000000002';
       insertProd.Type__c = 'Video Digital';
       insertProd.Product_Market__c ='EST';
       insertProd.Product_Format__c = 'SD;HD';
       insertProd.Local_Title__c = LT3.Id;
       insertProd.External_Id__c = 'IND_en_000000001_EST_HD';
       insert insertProd;
       
    
       listReleaseplan = new List<Commercial_Avail__c>();
       releasePlan = new Commercial_Avail__c();
       releasePlan.Channel__c = 'EST';
       releasePlan.Title__c=title5.id;
       releasePlan.Languages__c = Language.id;
       releasePlan.Country_Lookup__c = Country.id;
       releasePlan.Format__c = 'HD';
       releasePlan.Language_Type__c = 'Sub & Audio';
       releasePlan.Exclusive_Date__c = date.today()-200;
       releasePlan.Start_Date__c = date.today()-100;
       releasePlan.End_Date__c = date.today()+100;
       releasePlan.Rights_End__c=date.today()+200;
       releasePlan.Status__c = 'Confirmed';
       //releasePlan.Playlist__C = playlist.id;
       releasePlan.Local_Title__c = listlocaltitles[0].Id;
       listReleaseplan.add(releasePlan);
       insert listReleaseplan;
       
        storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount4.Id,
                    Active__c = true,
                    Content_Type__c = 'Episode;Season',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD;HD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi;EST;Hotel',
                    Country__c = Country.ID
            );
       storefrontGoogle1.CRM_Account__c = objAccount4.Id;      
       storefrontGoogle1.Status__c = 'Active';
       storefrontGoogle1.Account__c = objAccount5.Id;
       storefrontGoogle1.SAP_Customer_Number__c='12010421';
       
       insert storefrontGoogle1;
       
       List<Rate_Card__c> ratecardlist1=new List<Rate_Card__c>();
       
       Rate_Card__c rc5 = new Rate_Card__c();
        rc5.Channel__c = listReleaseplan[0].Channel__c;
        rc5.Country__c = Country.Id;
        rc5.Account__c = objAccount5.Id;
        rc5.Start_Date__c = date.today();
        rc5.End_Date__c = date.today()+200;
        rc5.Content_Type__c = title5.Content_Type__c;
        rc5.Format__c = listReleaseplan[0].Format__c;
        rc5.WSP1__c= 10; 
        rc5.Storefront__c = storefrontGoogle1.Id;
        rc5.Rate_Card_Type__c = 'WSP';
       // rc5.WSP1__c = 5.9;
        ratecardlist1.add(rc5);
        
         Rate_Card__c rc6 = new Rate_Card__c();
        rc6.Channel__c = listReleaseplan[0].Channel__c;
        rc6.Country__c = Country.Id;
        rc6.Account__c = objAccount5.Id;
        rc6.Start_Date__c = date.today();
        rc6.End_Date__c = date.today()+200;
        rc6.Content_Type__c = title6.Content_Type__c;
        rc6.Format__c = listReleaseplan[0].Format__c;
        rc6.WSP1__c=20;
        rc6.Storefront__c = storefrontGoogle1.Id;
        rc6.Rate_Card_Type__c = 'WSP';
        //rc6.WSP1__c = 5.9;
        ratecardlist1.add(rc6);

        insert ratecardlist1;
    
        
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
        WB_PBEP_Product_CreationHandler wc = new WB_PBEP_Product_CreationHandler();
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail5 = TestUtil.initClientAvail(objAccount5.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail5.Start_Date__c = system.today()+10;
        clientAvail5.End_Date__c = system.today()+70;
        clientAvail5.Status__c = 'Tentative';
        clientAvail5.Price_Tier_Text__c = Null;
        clientAvail5.Price__c= 10;
        clientAvail5.Episode_Price__c= 20;
        clientAvail5.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail5.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail5);
        
         Client_Avail__c clientAvail6 = TestUtil.initClientAvail(objAccount5.Id, listReleaseplan[0], listlocaltitles[1].Id);
        clientAvail6.Start_Date__c = system.today()+10;
        clientAvail6.End_Date__c = system.today()+70;
        clientAvail6.Status__c = 'Tentative';
        clientAvail6.Price_Tier_Text__c = Null;
        clientAvail6.Local_Data_Category_Picklist__c = 'TV Catalog';
        clientAvail6.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail6);
        test.startTest();
        insert listClientavails;  
        
        listClientavails[1].Parent_Client_Avail__c= listClientavails[0].id;
        listClientavails[1].Recalculate_Playlist_Avails__c='';
        
        update listClientavails[1];
      
        
        storefrontGoogle1.CRM_Storefront__c = true;
        update storefrontGoogle1;
        
        List<Agreement__c> sfList = [Select Id,CRM_Storefront__c from Agreement__c];
        system.debug('sfList:'+sfList);
        
         
        WB_Batch_PBEP_RateCardUpdate wb = new WB_Batch_PBEP_RateCardUpdate(sfList,true,true);
        
        Database.executeBatch(wb);
        
        test.stopTest();
        
    
    }
 
    
}