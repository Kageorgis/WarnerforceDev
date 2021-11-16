@isTest
public class WB_CommitPromotionControllerTest {
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
    public static Account objAccount2;
    public static Title__c t1;
    public static Title__c episodeTitle1;
    public static Playlist__c playlist123;
    public static Language__c Language1;
    public static Country__c Country_1; 
    public static List<Local_Title__c> listlocaltitles12;
    public static List<Client_Avail__c> listClientavails12;
    static List<Pricing__c> lPricing5 = new List<Pricing__c>();
    public static List<Commercial_Avail__c> listReleaseplan_1;
    public static Commercial_Avail__c releasePlan_1;
    
    /**
*  Create Test Data. 
*  @name setUpData
*  @param None
*  @return None
*  @throws None
*/
    static void setUpData(){
        try{
            //insert MPM
            MPM__c Mpm = new MPM__c(); 
            Mpm.Name = '2063646';
            Mpm.MPM_Number__c = '2063646'; 
            Mpm.Film_Color__c = 'Color';
            insert Mpm;
            
            //insert Account
            //objAccount1 = TestUtil.initAccount();
            Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
            objAccount1 = new Account(Name='TestAccount1',Customer_Focus__c='Active', recordtypeId = rtypeId);
            objAccount1.Type='Global';
            insert objAccount1;
            
            objAccount2 = new Account(Name='TestAccount2',Customer_Focus__c='Active', recordtypeId = rtypeId);
            objAccount2.Type='Global';
            insert objAccount2;
            
            t1 = new Title__c();
            t1.Name = 'Vampire Diaries S01';
            t1.Digital_Planning__c = 'Yes';
            t1.Clear_to_Avail__c = true;
            t1.Content_Type__c = 'Season';
            t1.Video_Version__c = '000000001';
            t1.MPM__c = Mpm.id;
            t1.US_TV_Air_Date__c = system.today();
            t1.Formats__c = 'SD;HD';
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
            episodeTitle2.Formats__c = 'SD;HD';
            Insert episodeTitle2;
            
            playlist123 = new Playlist__c();
            playlist123.name = 'test playlist';
            playlist123.Version_Number__c = 1;
            playlist123.Parent_Title__c = t1.id;
            playlist123.Playlist_Status__c = 'Active';
            insert playlist123;
            
            List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
            Playlist_Content__c content = new Playlist_Content__c();
            content.Content_Title__c=episodeTitle1.id;
            content.Playlist__c = playlist123.id;
            contentlist.add(content);
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
            releasePlan2.End_Date__c = system.today()+100;
            releasePlan2.Rights_End__c=system.today()+200;
            releasePlan2.Status__c = 'Confirmed';
            
            listReleaseplan_1.add(releasePlan2);
            
            insert listReleaseplan_1;
            
            Agreement__c storefrontGoogle1 = new Agreement__c(Account__c = objAccount1.Id
                                                              ,country__c = country_1.Id
                                                              ,Status__c = 'Active'
                                                              ,Pricing_Currency__c ='FR'
                                                              ,Format__c = 'HD;SD;'
                                                              ,Channel_Picklist__c = 'EST'
                                                              ,Content_Type__c = 'Episode;Season'
                                                              ,Active__c = true
                                                              ,WSP_Currency__c = 'INR',SAP_Customer_Number__c='12010421');
            insert storefrontGoogle1;
            
            
            countrySIDList.add(new Country_SID_Key__c(Name='India', Country_Code__c='IND',Country_Code2_c__c='IN',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
            insert countrySIDList;
            
            //insert Promotion
            Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1',Country__c='India');
            insert promo;
            
            //insert Custom Setting
            List<WB_Promotion_Limits__c> listLimits = new List<WB_Promotion_Limits__c>();
            listLimits.add(new WB_Promotion_Limits__c(Name='Commit Batch Process Threshold',Limit_Size__c=100));
            listLimits.add(new WB_Promotion_Limits__c(Name='Commit PTD Chunk Size',Limit_Size__c=100));
            listLimits.add(new WB_Promotion_Limits__c(Name='MaxAccountsAllowed',Limit_Size__c=100));
            listLimits.add(new WB_Promotion_Limits__c(Name='MaxCountriesAllowed',Limit_Size__c=100));
            listLimits.add(new WB_Promotion_Limits__c(Name='Promotion Titles Size Limit',Limit_Size__c=100));
            listLimits.add(new WB_Promotion_Limits__c(Name='Save PT Chunk Size',Limit_Size__c=100));
            listLimits.add(new WB_Promotion_Limits__c(Name='Validate PT Chunk Size',Limit_Size__c=100));
            insert listLimits;
            
            List<WB_Promotion_Formats__c> listFormats = new List<WB_Promotion_Formats__c>();
            listFormats.add(new WB_Promotion_Formats__c(Name='All',Formats__c='SD,HD,3DHD,4K UHD,HD+DVD,HD+BD'));
            listFormats.add(new WB_Promotion_Formats__c(Name='All 2D',Formats__c='SD,HD,4K UHD'));
            insert listFormats;
        }
        catch(Exception e){
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    private static testMethod void WB_CommitPromotionControllerTestCaseHandson() {
        setUpData();
        
        Promotion__c promo = [SELECT Id FROM Promotion__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(promo);
        WB_CommitPromotionController controller = new WB_CommitPromotionController(sc);
        
        PageReference pageRef = Page.WB_CommitPromotion;
        pageRef.getParameters().put('id', String.valueOf(promo.Id));
        Test.setCurrentPage(pageRef);
    }
    
    private static testMethod void WB_CommitPromotionControllerTestCasePass() {
        setUpData();
        
        Test.startTest();
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        //clientAvail.Playlist__c = playlist123.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Confirmed';
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
        clientAvail1.Status__c = 'Confirmed';
        //clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        //clientAvail1.Episode_Price_Tier__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        //insert clientAvail;
        
        insert listClientavails12;
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = listClientavails12[0].id,Effective_Date__c=system.today()+5,
                                                               Price_Code__c='CheckPriceCode',Type__c='Reprice',Category__c = 'Catalog',
                                                               recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap1);
        insert cap1;
        
        Promotion__c promo = [SELECT Id FROM Promotion__c LIMIT 1];
        System.debug('SF==='+[SELECT Id,Account__c,Account__r.Name,Country__r.Name,Status__c,Content_Type__c,Format__c,Channel_Picklist__c,WSP_Currency__c,CRM_Storefront__c FROM Agreement__c]);        
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> lstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        WB_UploadPromotionTitlesController.PromotionTitleWrapper ptwObj;
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> returnLstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        
        //Insert PT Records
        
        ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '000000001';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'INR';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        
        ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '000000002';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'INR';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '000000003';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'INR';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        returnLstPTW = WB_UploadPromotionTitlesController.savePromotionTitleRecords(lstPTW,promo.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(promo);
        WB_ValidatePromotionController validateController = new WB_ValidatePromotionController(sc);
        
        WB_ValidatePromotionController.MapWrapper mapWrapperObj = WB_ValidatePromotionController.fetchPromoTitleRec(promo.Id,true);
        List<String> upsertedKeys = WB_ValidatePromotionController.createlstPromoTitleDetail(promo.Id,mapWrapperObj.mapNameCountry,mapWrapperObj.mapNameAccount,mapWrapperObj.mapNameSF,new List<Id>(mapWrapperObj.ptIDs),true);
        WB_ValidatePromotionController.deletePTDs(promo.Id,upsertedKeys);
        WB_ValidatePromotionController.findDeltaPTDValidate(promo.Id);
        Test.stopTest();
        WB_CommitPromotionController.createTEMPCAP(promo.Id);
        System.assertEquals(2,[SELECT count() FROM Client_Avail_Price__c WHERE Promotion__c = :promo.Id]);
        WB_CommitPromotionController.cancelTempCAPs(promo.Id);        
        System.assertEquals(0,[SELECT count() FROM Client_Avail_Price__c WHERE Promotion__c = :promo.Id]);
    }
    
    private static testMethod void WB_CommitPromotionControllerTestThresholdSize() {
        setUpData();
        
        Test.startTest();
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        //clientAvail.Playlist__c = playlist123.id;
        //clientAvail1.Title__c = episodeTitle.id;
        clientAvail.Start_Date__c = system.today();
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Confirmed';
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
        clientAvail1.Status__c = 'Confirmed';
        //clientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        //clientAvail1.Episode_Price_Tier__c = 'reprice12';
        listClientavails12.add(clientAvail1);
        //insert clientAvail;
        
        insert listClientavails12;
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = listClientavails12[0].id,Effective_Date__c=system.today()+5,
                                                               Price_Code__c='CheckPriceCode',Type__c='Reprice',Category__c = 'Catalog',
                                                               recordtypeid=WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),'PERM'));
        system.debug('Client Avail Pricing : '+cap1);
        insert cap1;
        
        Promotion__c promo = [SELECT Id FROM Promotion__c LIMIT 1];
        System.debug('SF==='+[SELECT Id,Account__c,Account__r.Name,Country__r.Name,Status__c,Content_Type__c,Format__c,Channel_Picklist__c,WSP_Currency__c,CRM_Storefront__c FROM Agreement__c]);        
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> lstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        WB_UploadPromotionTitlesController.PromotionTitleWrapper ptwObj;
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> returnLstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        
        //Insert PT Records
        
        ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '000000001';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'INR';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        
        ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '000000002';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'INR';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '000000003';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'INR';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        returnLstPTW = WB_UploadPromotionTitlesController.savePromotionTitleRecords(lstPTW,promo.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(promo);
        WB_ValidatePromotionController validateController = new WB_ValidatePromotionController(sc);
        Test.stopTest();
        WB_CommitPromotionController.findDeltaPTD(promo.Id,1000);
        WB_CommitPromotionController.createTEMPCAP(promo.Id);
        System.assertEquals(2,[SELECT count() FROM Client_Avail_Price__c WHERE Promotion__c = :promo.Id]);
    }
}