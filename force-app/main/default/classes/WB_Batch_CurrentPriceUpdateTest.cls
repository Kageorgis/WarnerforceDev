@isTest
public class WB_Batch_CurrentPriceUpdateTest {
    
    public static List<Account> accList = new List<Account>();
    public static List<Title__c> titleList = new List<Title__c>();
    public static List<Country__c> cList = new List<Country__c>();
    public static List<Language__c> lList = new List<Language__c>();
    public static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    public static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    public static List<Agreement__c> aList = new List<Agreement__c>();
    public static List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
    public static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    public static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    public static List<String> selectedClientAvailIds = new List<String>();
    public static Integer count=3;
     static List<Pricing__c> lPricing = new List<Pricing__c>();
    
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
    
    public static void insertTestData()
    {
       /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
      objAccount = TestUtil.initAccount();
        objAccount.Type='Global';
        insert objAccount;
        
        /* -- Title creation-- */
         t = new Title__c();
        t.Name = 'Test Title';
        t.Digital_Planning__c = 'Yes';
        t.Formats__c = 'SD';
        t.Clear_to_Avail__c = true;
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.US_TV_Air_Date__c = system.today();
        Insert t;
        
        episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Formats__c = 'SD';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        Insert episodeTitle;
        
         Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Formats__c = 'SD';
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
         WB_ClientAvailPriceHandler.recursiveInsert = true;
         
 Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'Direct To Video Catalog2';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='VODi';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='567';
        pricing1.Episode_Price_Tier__c='311';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing3= new Pricing__c();
        pricing3.Name = 'Direct To Video Catalog3';
        pricing3.Account__c = objAccount.id;
        pricing3.Country__c = Country.id;
        pricing3.Channel__c='VODi';
        pricing3.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing3.Price_Tier__c ='123';
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
        pricing2.Price_Tier__c ='123.89';
        pricing2.Episode_Price_Tier__c='678';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);       
                
        insert lPricing;
        
        listlocaltitles= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist12.id;
        LT.Price_Code__c = 'CheckPriceCode';
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
        //releasePlan1.Country_Code__c = 'IND';
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
        
       Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=objAccount.Id,Country__c=Country.Id,Pricing_Currency__c='INR',Content_Type__c='Episode; Feature; Season',
                                                            Channel_Picklist__c = listReleaseplan[0].Channel__c,Format__c=listReleaseplan[0].Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421',Formats_with_EC__c=listReleaseplan[0].Format__c,Selected_Combination__c='Season_VODi_SD , Episode_VODi_SD');
        insert storefrontGoogle1;
        
        Agreement__c storefrontGoogle2 = new Agreement__c(Account__c=objAccount.Id,Country__c=Country.Id,Pricing_Currency__c='INR',Content_Type__c='Episode',
                                                            Channel_Picklist__c = listReleaseplan[0].Channel__c,Format__c=listReleaseplan[0].Format__c,Status__c ='Active',SAP_Customer_Number__c='12010422',Formats_with_EC__c=listReleaseplan[0].Format__c);
        //insert storefrontGoogle2;
        /*Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, listReleaseplan[0], t);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
        storefrontGoogle1.SAP_Customer_Number__c='12010421';
        //insert storefrontGoogle1;*/
        
        List<Agreement__c> sfList = [Select Id,SAP_Customer_Number__c,Account__c,Account__r.Name,Country__c,Country__r.Name,Pricing_Currency__c,Content_Type__c,Channel_Picklist__c,Format__c,Status__c FROM Agreement__c];
        system.debug(LoggingLevel.INFO,'sfList:'+sfList);
        for(Agreement__c sf : sfList){
            system.debug('Account Name:'+sf.Account__r.Name);
            system.debug('Country Name:'+sf.Country__r.Name);
        }
        
        countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        
          listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price__c = 9.99; 
         clientAvail.Episode_Price__c = 2.99;
        clientAvail.Price_Tier_Text__c = null;
         clientAvail.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[1].Id);
            clientAvail1.Start_Date__c = system.today();
            clientAvail1.End_Date__c = system.today()+70;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
            clientAvail1.Price__c = 2.99; 
        	clientAvail1.Price_Tier_Text__c = null;
            clientAvail1.Storefront__c = storefrontGoogle1.Id;
           
      
        insert listClientavails;
        
       WB_ClientAvailPriceHandler.recursiveInsert = false;
        clientAvail1.Parent_Client_Avail__c = listClientavails[0].Id;
        clientAvail.Price__c = 10;
        insert clientAvail1;
        system.debug('1. WB_ClientAvailPriceHandler.recursiveInsert:'+WB_ClientAvailPriceHandler.recursiveInsert);
        
         List<Client_Avail__c> caRecs = [Select Id,Playlist__c,Commercial_Avail__r.Country_Code__c,Parent_Client_Avail__c,Start_Date__c,End_Date__c,Price_Tier_Text__c,Episode_Price_Tier__c,Local_Data_Category_Picklist__c,Commercial_Avail__c,Client__c,Local_Title__c,Local_Title__r.Title__c,(Select Id,Client_Avail__c,Pricing__c,Price__c,Local_Data_Price_Code__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Effective_Date__c,Expiry_Date__c,Title_Content_Type__c,Category__c,Type__c from Client_Avail_Prices__r) from Client_Avail__c];
        listClientavails.add(clientAvail1);
        
       
    }
    public static testmethod void testMethod1() {       
        insertTestData();
        DateTime gmtTime = null;
        Date gmtDate = null;
       /* ER-004293* Date nextDate = null;
        DateTime nextDateTime;        
        // ER-004293 gmtTime = System.now();* ER-004293*/
        gmtTime = System.today();
        gmtDate = Date.newInstance(gmtTime.yearGmt(),gmtTime.monthGmt(),gmtTime.dayGmt());
        
     /*  ER-004293   nextDateTime = System.now().addHours(12);       
 		nextDate = Date.newInstance(nextDateTime.yearGmt(),nextDateTime.monthGmt(),nextDateTime.dayGmt());  
     * ER-004293*/
      
      Test.startTest();
       List<Client_Avail__c> caRecs = [Select Id,Playlist__c,Commercial_Avail__r.Country_Code__c,Parent_Client_Avail__c,Start_Date__c,End_Date__c,Price_Tier_Text__c,Episode_Price_Tier__c,Local_Data_Category_Picklist__c,Commercial_Avail__c,Client__c,Local_Title__c,Local_Title__r.Title__c,(Select Id,Client_Avail__c,Pricing__c,Price__c,Local_Data_Price_Code__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Effective_Date__c,Expiry_Date__c,Title_Content_Type__c,Category__c,Type__c from Client_Avail_Prices__r) from Client_Avail__c];
        //Price_Tier__c = '567'
        
      Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=gmtDate,Expiry_Date__c=gmtDate+50,
            Price__c=8.99,Episode_Price__c = 1.99,Type__c='Reprice',Category__c = 'Catalog',SR_Price__c =200.50,
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM')); 
        system.debug('Client Avail Pricing : '+cap1);
        insert cap1;
        
        Client_Avail_Price__c cap2 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[1].id,Effective_Date__c=gmtDate+5,Expiry_Date__c=gmtDate+50,
            Price__c = 0.99,Type__c='Reprice',Category__c = 'Catalog',SR_Price__c =200.50,
            recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap2);
        insert cap2;
        
        listClientavails[0].Price__c = 7.99;
        update listClientavails;
        
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
      WB_ClientAvailPriceHandler.recursiveInsert = false; 
        
        WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_ClientAvailPriceHandler.isCADateChange = false;
        system.debug('####gmtDate: '+gmtDate);
         
        LIst<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList = [Select Id,Effective_Date__c,SR_Price__c,SR_Per_Episode__c,Client_Avail__r.Local_Title__r.Price_Code__c,Client_Avail__r.Local_Title__r.Category__c,Client_Avail__r.Local_Title__c,Recordtype.name,Category__c,Client_Avail__r.Title_Content_Type__c,Client_Avail__r.Pricing__c,Client_Avail_Price__c.Price_Tier__c,Client_Avail__r.Episode_Price_Tier__c,Client_Avail__r.Price_Tier_Text__c,Episode_Price__c,Client_Avail__r.Episode_Price__c,Episode_Price_Tier__c,Client_Avail__r.Price__c,Price__c,Expiry_Date__c,Pricing__c,Price_Code__c,Type__c,Name,Client_Avail__c,Client_Avail__r.Name,Client_Avail__r.Commercial_Avail__r.Country_Code__c from Client_Avail_Price__c  ];
        
        cap1.Price_Tier__c = 'reprice2';
        cap2.Price_Tier__c = 'reprice2';
        cap2.Price__c = null;
        cap2.Episode_Price_Tier__c = null;
        cap2.Episode_Price__c = null;
         
        update clAvailPriceList;
        
        WB_UpdateCAWithCurrentPriceController CACurrentPriceCtrl = new WB_UpdateCAWithCurrentPriceController();
        CACurrentPriceCtrl.RunBatch();
        WB_Schedule_CA_CurrentPriceUpdate caCurrentPriceUpdate = new WB_Schedule_CA_CurrentPriceUpdate();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, new WB_Schedule_CA_CurrentPriceUpdate() );
        
        WB_Batch_ClientAvail_CurrentPriceUpdate b = new WB_Batch_ClientAvail_CurrentPriceUpdate();
        System.debug('Calling Batch' +b);
        Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,capList);
        b.finish(bc);
        
        Test.stopTest();
        
       
    }
}