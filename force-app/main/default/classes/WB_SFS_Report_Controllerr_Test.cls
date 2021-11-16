/**
	@Author: Cognizant
	@name: WB_SFS_Report_Controllerr_Test
	@CreateDate: 30 June 2020
	@Description: This class is Test Class for WB_SFS_Report_Controllerr. 
	@Version <1.0>
	@reference: ER-004177
*/

@isTest(seeAllData=false)
private class WB_SFS_Report_Controllerr_Test {
    
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
    // public static Playlist__c playlist12;
    //public static Account objAccount;
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
    
    /**
	*  @name getSFSReportDataTest
	*  @param none - to Test method getSFSReportDataTest from class WB_SFS_Report_Controllerr
	*/
    
    @isTest
    static void getSFSReportDataTest()
    {
        Account objAccount = TestUtil.initAccount();
        objAccount.Type='Global';
        insert objAccount;
        system.debug('==>objAccount'+objAccount);
        
        t = new Title__c();
        t.Name = 'Test Title';
        t.Digital_Planning__c = 'Yes';
        t.Clear_to_Avail__c = true;
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        //t.MPM__c = Mpm.id;
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
        //episodeTitle.MPM__c = Mpm.id;
        Insert episodeTitle;
        
        Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle.Global_Category__c = 'TV Catalog';
        //episodeTitle2.MPM__c = Mpm.id;
        Insert episodeTitle2;
        
        
        
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
        //LT.Playlist__C = playlist12.id;
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
        // releasePlan1.Playlist__C = playlist12.id;
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
        //setUpData(true);
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        //clientAvail.Playlist__c = playlist12.id;
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
        
        
        //WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        WB_ClientAvailPriceHandler.recursiveInsert = false; 
        
        Client_Avail_Price__c cap3 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+3,
                                                               Accounting_Category__c ='Catalog', Price__c=10.99,Episode_Price__c=2.99,Type__c='Reprice',Category__c = 'Catalog',
                                                               recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap3);
        insert cap3;
        
        //,Episode_Price_Tier__c='test1'
        Client_Avail_Price__c cap4 = new Client_Avail_Price__c(Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+20,
                                                               Accounting_Category__c ='Catalog', Price_Tier__c='reprice2',Type__c='Reprice',Category__c = 'Catalog');
        
        insert cap4; 
        
        cap4.Price_Tier__c='reprice4';
        cap4.Episode_Price_Tier__c = WB_PriceUtility.PRICE_TIER_TBD;
        update cap4;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', 
                          lastname='Testing', profileid = p.Id,languagelocalekey='en_US', localesidkey='en_US', 
                          timezonesidkey='America/Los_Angeles', username='superUser@testorg.com');
        insert u;
        System.runAs(u)
        {
            //FilterWrapper filterWrap = new FilterWrapper();
        //system.debug('filterWrap===>' +filterWrap.accountId);
        String idAcc = String.valueOf(objAccount.Id);
        WB_SFS_Report_Controllerr.FilterWrapper filterWrap = new WB_SFS_Report_Controllerr.FilterWrapper();
        //system.debug('objAccountId===>'+objAccount.Id);
        filterWrap.title = 'Test';
        filterWrap.countryId = Country.Id;
        filterWrap.fromDate = System.today();
        filterWrap.toDate = System.today()+5;
        filterWrap.accountId = idAcc;
        
        List<String> capIds = new List<String>();
        capIds.add(cap4.Id);
        //capIds.add(capRecord2.Id);
        
        List<WB_SFS_Report_Controllerr.SFSDataWrapper> sfsDataWrapper = new List<WB_SFS_Report_Controllerr.SFSDataWrapper>();
        sfsDataWrapper = WB_SFS_Report_Controllerr.getSFSReportData(capIds, filterWrap);
        system.debug('sfsDataWrapper==>' +sfsDataWrapper[0]);
        System.assertEquals('IND', sfsDataWrapper[0].territory);
        }
        
        test.stoptest();
    }
    
    /**
	*  @name getUserLocaleLowerCaseTest
	*  @param none - to Test method getUserLocaleLowerCase from class WB_SFS_Report_Controllerr
	*/
    @isTest
    static void getUserLocaleLowerCaseTest()
    {
        test.startTest();
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', 
                          lastname='Testing', profileid = p.Id,languagelocalekey='en_US', localesidkey='en_US', 
                          timezonesidkey='America/Los_Angeles', username='superUser@testorg.com');
        insert u;
        System.runAs(u)
        {
            String getUserLocaleCase = WB_SFS_Report_Controllerr.getUserLocaleLowerCase();
            //system.debug('getUserLocale=====>' +getUserLocale);
            System.assertEquals('en-us', getUserLocaleCase);
        }
        
        test.stopTest();
    }
    
    /**
	*  @name getUserLocaleTest
	*  @param none - to Test method getUserLocale from class WB_SFS_Report_Controllerr
	*/
    @isTest
    static void getUserLocaleTest()
    {
        test.startTest();
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', 
                          lastname='Testing', profileid = p.Id,languagelocalekey='en_US', localesidkey='en_US', 
                          timezonesidkey='America/Los_Angeles', username='superUser@testorg.com');
        insert u;
        System.runAs(u)
        {
            String getUserLocale = WB_SFS_Report_Controllerr.getUserLocale();
            //system.debug('getUserLocale=====>' +getUserLocale);
            System.assertEquals('en-US', getUserLocale);
        }
        
        test.stopTest();
    }
}