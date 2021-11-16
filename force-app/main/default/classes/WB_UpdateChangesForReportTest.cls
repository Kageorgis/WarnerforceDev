@isTest
public class WB_UpdateChangesForReportTest {

    public static Account objAccount;
    public static CA_Upload__c caUpload;
    public static Local_Title__c localTitle;
    public static Agreement__c storefrontGoogle1;
    public static List<Pricing__c> pricingList;
    public static List<Client_Avail__c> clientAvailList;
    public static List<Title__c> titleList;
    public static List<Country__c> countryList;
    public static List<Language__c> languageList;
    public static List<Available_Languages__c> availLanguageList;
    public static List<Commercial_Avail__c> releasePlanList;
    public static Client_Avail__c clientAvail;
    public static MPM__c objMPM;
    
    static void setUpdata() {
        
        objAccount = TestUtil.initAccount();
        insert objAccount;
        
        objMPM = new MPM__c(name='1122333', MPM_Number__c='1122333');
        insert objMPM;
        
        titleList = new List<Title__c>();
        Title__c title1 = TestUtil.initTitle('Batman Begins', '1000000001');
        title1.Formats__c = 'SD; 4K UHD';
        title1.MPM__c = objMPM.Id;
        titleList.add(title1);
        insert titleList;
        
        countryList = new List<Country__c>();
        Country__c country1 = TestUtil.initCountry('USA', 'QQ', 'TF');
        countryList.add(country1);
        insert countryList;
        
        languageList = new List<Language__c>();
        Language__c language1 = TestUtil.initLanguage('English', '', 1);
        languageList.add(language1);
        insert languageList;
        
        availLanguageList = new List<Available_Languages__c>();
        Available_Languages__c availLang1 = TestUtil.initAvailableLang(languageList[0].Id, 'Sub', titleList[0].Id);
        Available_Languages__c availLang2 = TestUtil.initAvailableLang(languageList[0].Id, 'Audio', titleList[0].Id);
        availLanguageList.add(availLang1);
        availLanguageList.add(availLang2);
        insert availLanguageList;
        
        localTitle = TestUtil.initLocalTitle(languageList[0].Id, countryList[0].Id);
        insert localTitle;
        
        releasePlanList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan1 = TestUtil.initReleasePlan(titleList[0].Id, localTitle.Id, countryList[0].Id, languageList[0].Id);
            releasePlan1.Channel__c = 'EST';
            releasePlan1.Format__c = 'SD';
            releasePlan1.Language_Type__c = 'Sub & Audio';
            releasePlan1.Exclusive_Date__c = date.today()-200;
            releasePlan1.Start_Date__c = date.today()-100;
            releasePlan1.End_Date__c = date.today()+100;
            releasePlan1.Rights_End__c=date.today()+200;
            releasePlan1.APO__c = 'Yes';
        releasePlanList.add(releasePlan1);
        insert releasePlanList;
        
        storefrontGoogle1 = TestUtil.initStoreFront2(objAccount.Id, countryList[0].Id);
        storefrontGoogle1.APO__c = 'Yes';
        storefrontGoogle1.Channel_Picklist__c = 'EST';
        insert storefrontGoogle1;
        test.startTest();
        pricingList = new List<Pricing__c>();
        Pricing__c pricing1 = TestUtil.initPricing(objAccount.Id, countryList[0].Id);
            pricing1.Channel__c = 'EST';
            pricing1.Format__c = 'SD';
            pricing1.Price_Tier__c = 'testingCTS';
        pricingList.add(pricing1);
        
        Pricing__c pricing2 = TestUtil.initPricing(objAccount.Id, countryList[0].Id);
            pricing2.Channel__c = 'VODc';
            pricing2.Format__c = 'SD';
            pricing2.Price_Tier__c = 'testingAgain';
        pricingList.add(pricing2);
        insert pricingList;
        
        clientAvail = TestUtil.initClientAvail(objAccount.Id, releasePlanList[0], localTitle.Id);
        clientAvail.Price_Tier_Text__c = 'testingCTS';
        clientAvail.APO__c = 'Yes';
        insert clientAvail;
        
        List<Client_Avail__c> clientAvailInserted = [SELECT Name, Local_Title__r.Price_Code__c FROM Client_Avail__c where Id =: clientAvail.Id];
        
        localTitle = [Select Id,Price_Code__c from Local_Title__c where Id =: clientAvailInserted[0].Local_Title__c];
        localTitle.Price_Code__c = 'Direct To Video Catalog';
        update localTitle;
		 
		clientAvail.Status__c = 'Confirmed';
        update clientAvail;
        Test.stopTest();
    }
    
    @isTest(SeeAllData='true')
	private static void test_clientAvail() {
        
        setUpdata();
        
        //Test.startTest();
        List<Report> reportList = [Select Id, Name, DeveloperName, lastRunDate from Report where Id =: Label.APO_Client_Avail_Report];
        
        clientAvail.Announce_Date__c = system.today();
        //clientAvail.Price_Tier_Text__c = 'testingAgain';
        clientAvail.APO_Date_Override__c = system.today() - 2;
        //clientAvail.Local_Title__c = localData.Id;
        clientAvail.Start_Date__c = system.today();
        update clientAvail;
        
        List<Client_Avail__c> clientAvails = [SELECT Name, Changes__c, Local_Title__r.Price_Code__c FROM Client_Avail__c  where Id =: clientAvail.Id];
        system.debug('--------clientAvails------'+clientAvails);
        //system.assertNotEquals(null, clientAvails.Changes__c);
        //Test.stopTest();
	}
	
	@isTest(SeeAllData='true')
	private static void test_localData() {
        setUpdata();
        
        List<Report> reportList = [Select Id, Name, DeveloperName, lastRunDate from Report where Id =: Label.APO_Client_Avail_Report];
        
        localTitle.Local_Rating__c = 'Test|15';
        localTitle.Local_Theatrical_Release_Date__c = system.today();
        update localTitle;
        
        List<Client_Avail__c> clientAvails = [SELECT Name, Changes__c, Local_Title__r.Price_Code__c FROM Client_Avail__c  where Id =: clientAvail.Id];
        system.debug('--------clientAvails------'+clientAvails);
        //system.assertNotEquals(null, clientAvails.Changes__c);
        
	}

}