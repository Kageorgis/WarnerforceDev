/*******************************************************************************************************************************************
* File Name     :   TestUtil
* Description   :   Utility Class to initialize the test data for test classes
* @author       :   
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     -                 TCS                 Created the class.
* 2.0     12 Oct.2015       CTS                 Added some methods to get the test data for test classes
********************************************************************************************************************************************/


public class TestUtil 
{
    public static Integer batchNumberTest;
    public static boolean isRunning_WB_Batch_AddWeeklyRightsCheck = false;
    
    // Create Profile
    public static Profile initProfile(String profileName) {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: profileName];//'Standard User'
        return objProfile;
    }
    
    // Create User
    public static User initUser (Id profileId) {
        User objUser = new User(Alias = 'standt', Email='cas@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = profileId, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='abc'+math.random()+'@testorg.com');
        return objUser;
    }
    
    // Create Account 
    public Static Account initAccount () {
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount = new Account(Name='TestAccount',Customer_Focus__c='Active', recordtypeId = rtypeId);
        return objAccount;
    }
    
    // Create Title 
    public Static Title__c initTitle (String title, String videoVersion) {
        Title__c objTitle = new Title__c(Name = title
                                        , Video_Version__c = videoVersion
                                        , Content_Type__c = 'Feature'
                                        , Digital_Planning__c = 'YES'
                                         ,Formats__c ='SD'
                                        , Clear_to_Avail__c = true);
        return objTitle;
    }
    
    // Create country
    public Static Country__c initCountry(String cname, String countryCode2, String countryCode)
    {
        Country__c objCountry = new Country__c (Name = cname
                                            , Country_Code2__c = countryCode2
                                            , Country_Code__c = countryCode);
        return objCountry;
    }
      
    // Create Language_c
    public Static Language__c initLanguage(String lname, String langCode,Integer lOrder)
    {
        Language__c objLanguage = new Language__c(Name = lname
                                                , Language_Code_2__c = langCode
                                                , Language_Order__c = lOrder);
        return objLanguage;
    }  
    
    // Create Available Languages
    public Static Available_Languages__c initAvailableLang(Id languageId, String LangType, Id titleId) 
    {
         Available_Languages__c objAvailLang = new Available_Languages__c(Language__c = languageId
                                                                        , Language_Types__c = LangType
                                                                        , Title__c = titleId
                                                                        , Clear_To_Avail__c = true); 
        return objAvailLang;
    }
    
    // Create Release Plan
    public static Commercial_Avail__c initReleasePlan(Id titleId, Id localTitleId, Id countryId, Id languageId)
    {
        Commercial_Avail__c objReleasePlan = new Commercial_Avail__c(Country_Lookup__c = countryId
                                                                    , Languages__c = languageId
                                                                    , Language_Type__c = 'Sub'
                                                                    , Channel__c = 'VODc'
                                                                    , Format__c = 'HD'
                                                                    , Title__c = titleId
                                                                    , Local_Title__c = localTitleId
                                                                    , Status__c = 'Confirmed'
                                                                    , Exclusive_Date__c = date.today()-100
                                                                    , Start_Date__c=date.today()-1
                                                                    , End_Date__c= date.today()+1
                                                                    , Rights_End__c=date.today()+100);                                                            
                                                                    
        return objReleasePlan;
    }
    
    // Create Agreement
    public static Agreement__c initStoreFront(Id accId, Id countryId, Commercial_Avail__c objCA, Title__c objTitle)
    {
        Agreement__c objAgreement = new Agreement__c(Account__c = accId
                                                    , country__c = countryId
                                                    , Status__c = 'Active'
                                                    , Pricing_Currency__c ='FR'
                                                    , Content_Type__c = objTitle.Content_Type__c
                                                    , Channel_Picklist__c = objCA.Channel__c
                                                    , Format__c = objCA.Format__c,SAP_Customer_Number__c='12010421');
        return objAgreement;
    }
    
    // Create Agreement
    public static Agreement__c initStoreFront2(Id accId, Id countryId)
    {
        Agreement__c objAgreement = new Agreement__c(Account__c = accId
                                                    , country__c = countryId
                                                    , Status__c = 'Active'
                                                    , Pricing_Currency__c ='USD'
                                                    , Content_Type__c = 'Collection Features; Collection TV; Episode; Feature; Season'
                                                    , Channel_Picklist__c = 'VODi'
                                                    , Format__c = 'SD; HD; 3DHD; 4K UHD',SAP_Customer_Number__c='12010422');
        return objAgreement;
    }
    
   // Create Pricing
    public static Pricing__c initPricing(Id accId, Id countryId)//, Id storeId)
    {
        Pricing__c objPricing = new Pricing__c(Name='Direct To Video Catalog'
                                    , Account__c = accId
                                    //, Storefront_Currency2__c = storeId
                                    , Country__c = countryId
                                    , Channel__c='VODc'
                                    , Content_Type__c='Feature'
                                    , Price_Tier__c='Catalog'
                                    , Format__c='HD');
        return objPricing;
    }
    
    // Create Announcement Rule
    public static Announcement_Rule__c initAnnouncementType(Id accId)
    {
        Announcement_Rule__c objAnnRule = new Announcement_Rule__c(Account__c = accId);
        return objAnnRule;
        
    }
    
    // Create Local Title
    public static Local_Title__c initLocalTitle(Id languageId, Id countryId)
    {
        Local_Title__c objLocalTitle = new Local_Title__c(Name='@urFRENZ (2009)'
                                                        , Price_Code__c = 'Direct To Video Catalog'
                                                        , Language__c = languageId
                                                        , Country__c = countryId);
        return objLocalTitle;
    }
    
    // Create Client Avail
    public static Client_Avail__c initClientAvail(Id accId, Commercial_Avail__c objCA, Id LocalTitleId)
    {
        Client_Avail__c objClientAvail = new Client_Avail__c(Commercial_Avail__c = objCA.Id
                                                            , Client__c = accId
                                                            , Start_Date__c = objCA.Start_Date__c
                                                            , End_Date__c = objCA.End_Date__c 
                                                            , Effective_Price_Date__c = date.today()
                                                            , Price_Tier_Text__c = 'Catalog'
                                                            , Status__c = 'Draft'
                                                            , Local_Title__c = LocalTitleId);
        return objClientAvail;
    }
    
    // Create CA Upload
    public static CA_Upload__c initCAUpload()
    {
        CA_Upload__c objCAUpload = new CA_Upload__c (Upload_Time__c = system.now());
        return objCAUpload;                                            
    }
    
    // Create CA Upload Record
    public static CA_Upload_Record__c initCAUploadRecord(String accountName, String category, CA_Upload__c objCAUpload, 
                                                   String channel, String country, Date endDate, String format, String episodePriceTier,
                                                   String language, String languageType, String wsCost, String episodeWSCost, 
                                                   String localEpisodes, String localRating, String localEditRequired, Date preOrderDate,
                                                   String priceTier, Date startDate, String status, Date suppressionDate, String videoVersion)
    /* Account_Name, Category, CA_Upload, Channel, Country, End_Date, Format, Episode_Price_Tier, Language, Language_Type, WS_Cost, Episode_WSCost, Local_Data_No_Of_Episodes, 
    Local_Data_Rating, Local_Edit_Required, Pre_Order_Date, Price_Tier, Start_Date, Status, Suppression_Date, Video_Version */
    {
        CA_Upload_Record__c objCAURecord = new CA_Upload_Record__c ();
        if(accountName != null) objCAURecord.Account_Name__c = accountName;
        if(category != null) objCAURecord.Category__c=category;
        if(objCAUpload != null) objCAURecord.CA_Upload__c=objCAUpload.id;
        if(channel != null) objCAURecord.Channel__c=channel;
        if(country != null) objCAURecord.Country__c=country;
        if(endDate != null) objCAURecord.End_Date__c=endDate;
        if(format != null) objCAURecord.Format__c=format;
        if(episodePriceTier != null) objCAURecord.Episode_Price_Tier__c=episodePriceTier;
        if(language != null) objCAURecord.Language__c=language;
        if(languageType != null) objCAURecord.Language_Type__c=languageType;
        if(wsCost != null) objCAURecord.WS_Cost__c = wsCost;
        if(episodeWSCost != null) objCAURecord.Episode_WS_Cost__c = episodeWSCost;
        if(localEpisodes != null) objCAURecord.Local_Data_No_Of_Episodes__c=localEpisodes;
        if(localRating != null) objCAURecord.Local_Data_Rating__c=localRating;
        if(localEditRequired != null) objCAURecord.Local_Edit_Required__c=localEditRequired;
        if(preOrderDate != null) objCAURecord.Pre_Order_Date__c=preOrderDate;
        if(priceTier != null) objCAURecord.Price_Tier__c=priceTier;
        if(startDate != null) objCAURecord.Start_Date__c=startDate;
        if(status != null) objCAURecord.Status__c=status;
        if(suppressionDate != null) objCAURecord.Suppression_Date__c=suppressionDate;
        if(videoVersion != null) objCAURecord.Video_Version__c=videoVersion;
        return objCAURecord;                                            
    }
    
    // Create Rights
    public static Rights__c initRights(MPM__c objMpm, String country,  String channel)
    {
        Rights__c objRights = new Rights__c (MPM__c = objMpm.Id, Status__c='Confirmed', Rights_Group__c=country, Channel__c=channel);
        return objRights; 
    }
    
    // Create Locale (Rights_Group__c)
    public static Rights_Group__c initRightsGroup(Country__c objCountry, Language__c objLanguage, String rightGroup)
    {
        Rights_Group__c objRightsGroup = new Rights_Group__c (Name='es_US', Country__c = objCountry.Id, Language__c=objLanguage.Id
                                                            , Rights_Group__c=rightGroup);
        return objRightsGroup; 
    }
    
    // Create country record
    public Static Country__c createCountry(String cname, String countryCode2, String countryCode)
    {
        Country__c c = new Country__c (
        Name = cname,
        Country_Code2__c = countryCode2,
        Country_Code__c = countryCode
        );
        return c;
    }
    
    // Create Language_c record
    public Static Language__c createLanguage(String lname, String langCode,Integer lcode)
    {
        Language__c l = new Language__c(
        Name = lname,
        Language_Code_2__c = langCode,
        Language_Order__c = lcode
        );
        return l;
    }
    
    //Create GAP_Locale__c
    public Static GAP_Locale__c createGapLocale(String locale, String parentLocale)
    {
        GAP_Locale__c gapLocale = new GAP_Locale__c(
        GAP_Locale__c = true,
        Locale__c = locale,
        Parent_Locale__c = parentLocale
        );
        return gapLocale;
    }
    
    public static Local_Title__c createLocalData(String version, Country__c c, Language__c l, string parentLocale, Id titleId)
    {
        Local_Title__c lt = new Local_Title__c(
        Key__c = version + '_' + parentLocale,
        Local_Title__c = 'TestTitle',
        Country__c = c.Id,
        Language__c = l.Id,
        Title__c = titleId
        );
        return lt;
    }
    
    public static Title__c createTitle(String tName, String videoVersion)
    {
        Title__c t = new Title__c(
        Name = tName,
        Video_Version__c = videoVersion
        );
        return t;
    }
 
    // Create Account
    public static Account createAccount(String aName)
    {
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account a = new Account(
        Name = aName, recordtypeId = rtypeId
        );
        return a;
    }
 
    //Create Promotion__c record
    public static Promotion__c createPromotion(String pName, Id accId, Date startDate, Date endDate)
    {
        Promotion__c p = new Promotion__c(
        Name = pName,
        /*Account__c = accId,*/
        Start_Date__c = startDate,
        End_Date__c = endDate
        );
        return p;
    }
 
    //Create Promotion_Title__c record
    public static Promotion_Title__c createPromotionTitle(Id promotionId, Id titleId)
    {
        Promotion_Title__c pt = new Promotion_Title__c(
        PromotionID__C = promotionId,
        Title__c = titleId
        );
        return pt;
    }
    
    // Create MPM
    public static MPM__c createMPM(String mpmNumber)
    {
        MPM__c mpm = new MPM__c(
        Name = 'Test_Johny Bravo',
        MPM_Number__c = mpmNumber
        );
        return mpm;
    }
    
    // Create MPM release Date
    public static MPM_Release_Date__c createMPMReleaseDate(Id mpmId, Id country, Date theatricalDate, Date tvAirDate)
    {
        MPM_Release_Date__c mrd = new MPM_Release_Date__c(
        MPM__c = mpmId,
        Country__c = country,
        Theatrical_Release_Date__c = theatricalDate,
        TV_Airing_Date__c = tvAirDate
        );
        return mrd;
    }
    
    // Create Release Plan
    public static Commercial_Avail__c createReleasePlan(Id titleId, Id localTitleId, Id countryId, Id languageId)
    {
        Commercial_Avail__c rp = new Commercial_Avail__c(
        Local_Title__c = localTitleId,
        Title__c = titleId,
        Country_Lookup__c = countryId,
        Languages__c = languageId
        );
        return rp;
    }
     
    public static Agreement__c createStoreFront(Id accId, Id countryId)
    {
        Agreement__c a = new Agreement__c(
        Account__c = accId,
        country__c = countryId,
        Status__c = 'Active',
        SAP_Customer_Number__c='12010421'    
        );
        return a;
    }
    
    public static Pricing__c createPricing(Id accId, Id countryId, Id storeId)
    {
        Pricing__c p = new Pricing__c(
        Storefront_Currency2__c = storeId,
        Account__c = accId,
        Country__c = countryId
        );
        return p;
    }
    public static Announcement_Rule__c createAnnouncementType(Id accId)
    {
        Announcement_Rule__c annType= new Announcement_Rule__c(
        Account__c = accId
        );
        return annType;
        
    }
    
    public static Earliest_Avail_Date__c createEADRecord(Id titleId,Id CountryId){
        Earliest_Avail_Date__c eadRecord =  new Earliest_Avail_Date__c();
        eadRecord.Title__c = titleId;
        eadRecord.Earliest_Avail_Date__c = system.today();
        eadRecord.Format__c ='HD';
        eadRecord.Channel__c = 'EST';
        eadRecord.Country__c = CountryId;
        eadRecord.Status__c ='Unlocked';
        
        return eadRecord;
    }
    
    //ER-002734 Start
    // Create MPM as per the number passed through argument
    public static MPM__c initMPM(String mpmNumber)
    {
        MPM__c mpm = new MPM__c(
        Name = mpmNumber,
        MPM_Number__c = mpmNumber
        );
        return mpm;
    }
    //ER-002734 END
}