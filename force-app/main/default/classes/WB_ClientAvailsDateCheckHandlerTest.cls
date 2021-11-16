/*******************************************************************************************************************************************
* File Name     :   WB_ClientAvailsDateCheckHandlerTest
* Description   :   Test class for Handler to check start date and end date of Client Avails at the time of creation from Release plans
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10 Nov.2015        CTS                ER-000065 : Created the class.
* 2.0       
********************************************************************************************************************************************/

@isTest
private class WB_ClientAvailsDateCheckHandlerTest {

    public static Account acctGoogle;
    public static Title__c title;
    
    public static Country__c countryFrance;
    public static Language__c languageFrench;
    public static Local_Title__c localTitle;
    public static Agreement__c storefrontGoogle;
    
    public static List<Title__c> titleList;
    public static List<Country__c> countryList;
    public static List<Language__c> languageList;
    public static List<Local_Title__c> localTitleList;
    public static List<Commercial_Avail__c> releasePlanList;
    public static List<Client_Avail__c> clientAvailList;
    
    static void setUpdata() {
        acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
     
        titleList = new List<Title__c>();
        title = TestUtil.initTitle('Dark Night Collection', '6000025000');
        title.Content_Type__c = Label.Collection_Features;
        title.Formats__c='SD';
        insert title;
        
        List<Playlist__c> listPlaylist = new List<Playlist__c>();
        Playlist__c p1= new Playlist__c(Name='Standard',Parent_Title__c = title.id,Playlist_Status__c='Active',Playlist_Type__c='Collection Features',Version_Number__c=1);
        listPlaylist.add(p1);
        insert listPlaylist;
        
        Title__c title1 = TestUtil.initTitle('Batman Begins', '6000025001');
        //title1.Collection_Title__c = title.Id;
        title1.Formats__c='SD';
        titleList.add(title1);
        Title__c title2 = TestUtil.initTitle('Dark Night', '6000025002');
        title2.Formats__c='SD';
        //title2.Collection_Title__c = title.Id;
        
        titleList.add(title2);
        Title__c title3 = TestUtil.initTitle('Dark Night Rises', '6000025003');
        title3.Formats__c='SD';
        //title3.Collection_Title__c = title.Id;
        titleList.add(title3);
        Title__c title4 = TestUtil.initTitle('Dark Night 4', '6000025004');
        title4.Formats__c='SD';
        //title4.Collection_Title__c = title.Id;
        titleList.add(title4);
        insert titleList;
        
        countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        localTitle = TestUtil.initLocalTitle(languageFrench.Id, countryFrance.Id);
        localTitle.Title__c = title.Id;
        insert localTitle;
        
        releasePlanList = new List<Commercial_Avail__c>();
        Commercial_Avail__c CommercialAvail1 = TestUtil.initReleasePlan(titleList[0].Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail1.End_Date__c = date.today() + 2;
        releasePlanList.add(CommercialAvail1);
        
        Commercial_Avail__c CommercialAvail2 = TestUtil.initReleasePlan(titleList[1].Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail2.Start_Date__c = date.today() - 2;
        releasePlanList.add(CommercialAvail2);
        
        Commercial_Avail__c CommercialAvail3 = TestUtil.initReleasePlan(titleList[2].Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail3.Start_Date__c = date.today() - 2;
        CommercialAvail3.End_Date__c = date.today() + 2;
        releasePlanList.add(CommercialAvail3);
        
        Commercial_Avail__c CommercialAvail4 = TestUtil.initReleasePlan(titleList[3].Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail4.Start_Date__c = date.today() - 4;
        CommercialAvail4.End_Date__c = date.today() + 4;
        releasePlanList.add(CommercialAvail4);
        
        
        insert releasePlanList;
        
        storefrontGoogle = TestUtil.initStoreFront2(acctGoogle.Id, countryFrance.Id);
        storefrontGoogle.Channel_Picklist__c = 'VODc';
        insert storefrontGoogle;
        
        clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[0], localTitle.Id);
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[1], localTitle.Id);
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[2], localTitle.Id);
        clientAvailList.add(clientAvail3);
        
        Client_Avail__c clientAvaila = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[3], localTitle.Id);
            clientAvaila.Start_Date__c = date.today() - 4;
            clientAvaila.End_Date__c = date.today() - 1;
            clientAvailList.add(clientAvaila);
        Client_Avail__c clientAvailb = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[3], localTitle.Id);
            clientAvailb.Start_Date__c = date.today() + 1;
            clientAvailb.End_Date__c = date.today() + 4;
            clientAvailList.add(clientAvailb);
        insert clientAvailList;
    }
    
    static testMethod void myUnitTest1() {
        
        setUpdata();
        Test.startTest();
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.End_Date__c = date.today() + 3;
        insert CommercialAvail;
        commercialAvail.status__c = 'Confirmed';
        update commercialAvail;
    
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        try {
            insert clientAvail;
            system.debug(logginglevel.info,'####clientAvail'+clientAvail );
        //system.debug('*********listClientAvail'+listClientAvail);
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest2() {
        
        setUpdata();
        Test.startTest();
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.Start_Date__c = date.today() - 3;
        insert CommercialAvail;
        
        
        
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest3() {
        
        setUpdata();
        Test.startTest();
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.Start_Date__c = date.today() - 3;
        CommercialAvail.End_Date__c = date.today() + 3;
        insert CommercialAvail;
        
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest4() {
        
        setUpdata();
        Test.startTest();
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.End_Date__c = date.today() + 3;
        insert CommercialAvail;
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest5() {
        
        setUpdata();
        Test.startTest();
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=title.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[0].id);
        insert pc;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.End_Date__c = date.today() + 3;
        CommercialAvail.Playlist__c = playlist.id;
        insert CommercialAvail;
        
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail.Playlist__c = playlist.id;
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest5a() {
        
        setUpdata();
        
        Test.startTest();
        releasePlanList[0].Start_Date__c = date.today() - 10 ;
        releasePlanList[0].End_Date__c = date.today() + 10;
        releasePlanList[1].Start_Date__c = date.today() - 10;
        releasePlanList[1].End_Date__c = date.today() + 10;
        update releasePlanList;
        
        clientAvailList[0].Start_Date__c = date.today() - 3;
        clientAvailList[0].End_Date__c = date.today();
        clientAvailList[1].Start_Date__c = date.today() - 8;
        clientAvailList[1].End_Date__c = date.today() + 2;
        update clientAvailList;
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=title.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[0].id);
        insert pc;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.Start_Date__c = date.today() - 2;
        CommercialAvail.End_Date__c = date.today() - 1;
        CommercialAvail.Playlist__c = playlist.id;
        insert CommercialAvail;
        
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail.Playlist__c = playlist.id;
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest6() {
        
        setUpdata();
        Test.startTest();
        
        delete [select id from Client_Avail__c];
        
        releasePlanList[0].Start_Date__c = date.today() + 10;
        releasePlanList[0].End_Date__c = date.today() + 20;
        releasePlanList[1].Start_Date__c = date.today() - 10;
        releasePlanList[1].End_Date__c = date.today() - 6;
        releasePlanList[2].Start_Date__c = date.today()+ 5;
        releasePlanList[2].End_Date__c = date.today() + 6;
        releasePlanList[3].Start_Date__c = date.today() - 20;
        releasePlanList[3].End_Date__c = date.today() - 11;
        update releasePlanList;
        
        clientAvailList = new List<Client_Avail__c>();
        clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[0], localTitle.Id);
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[1], localTitle.Id);
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[2], localTitle.Id);
        clientAvailList.add(clientAvail3);
        Client_Avail__c clientAvaila = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[3], localTitle.Id);
        clientAvailList.add(clientAvaila);
        insert clientAvailList;
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=title.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        List<Playlist_Content__c> listplaylistContent = new List<Playlist_Content__c>();
        Playlist_Content__c pc1 = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[0].id);
        listplaylistContent.add(pc1);
        Playlist_Content__c pc2 = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[1].id);
        listplaylistContent.add(pc2);
        Playlist_Content__c pc3 = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[2].id);
        listplaylistContent.add(pc3);
        
        insert listplaylistContent;
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        insert CommercialAvail;
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail.Playlist__c = playlist.id;
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
        
        List<Client_Avail__c> lstClientAvail = [Select Id, Price_Tier_Text__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c =: CommercialAvail.Id];
        system.assertNotEquals(null, lstClientAvail);
    }
    
    static testMethod void myUnitTest7() {
        
        setUpdata();
        Test.startTest();
        
        delete [select id from Client_Avail__c];
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=title.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[0].id);
        insert pc;
        
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        insert CommercialAvail;
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail.Playlist__c = playlist.id;
        try {
            insert clientAvail;
        } catch (Exception e) {
            system.debug('------catch------'+e.getMessage());
        }
        Test.stopTest();
    }
    
    static testMethod void testUpdatePricing1()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        
        Title__c title1 = TestUtil.initTitle('TestGoogle', '6000047545');
        title1.Formats__c='SD';
        insert title1;
        
        Country__c France = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert France;
        
        Language__c French = TestUtil.initLanguage('TestFrench', '', 1);
        insert French;
        
        Local_Title__c locTitle = TestUtil.initLocalTitle(French.Id, France.Id);
        locTitle.Title__c = title1.Id;
        insert locTitle;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title1.Id, locTitle.Id, France.Id, French.Id);
        insert CommercialAvail;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(acct.Id, France.Id, CommercialAvail, title1);
        insert storefrontGoogle1;
        
        Pricing__c pricing = TestUtil.initPricing(acct.Id, France.Id);
        insert pricing;
        
        //test.startTest();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acct.Id, CommercialAvail, locTitle.Id);
        insert clientAvail;
        clientAvail.status__c = 'Confirmed';
        update clientAvail;
        //test.stopTest();
        
        Client_Avail__c cAvail = [select id,pricing__c from Client_Avail__c where Id =: clientAvail.Id];
        system.debug('*****Pricing Id:'+pricing.Id+'*****Client Avail Pricing Id:'+cAvail.pricing__c);
        system.assertEquals(pricing.Id, cAvail.pricing__c);
        
    }
    
    static testMethod void testUpdatePricing2()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        
        Title__c title1 = TestUtil.initTitle('TestGoogle', '6000047545');
        title1.Formats__c='SD';
        insert title1;
        
        Country__c France = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert France;
        
        Language__c French = TestUtil.initLanguage('TestFrench', '', 1);
        insert French;
        
        Local_Title__c locTitle = TestUtil.initLocalTitle(French.Id, France.Id);
        locTitle.Title__c = title1.Id;
        locTitle.Price_Code__c = null;
        insert locTitle;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title1.Id, locTitle.Id, France.Id, French.Id);
        insert CommercialAvail;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(acct.Id, France.Id, CommercialAvail, title1);
        insert storefrontGoogle1;
        
        Pricing__c pricing = TestUtil.initPricing(acct.Id, France.Id);
        insert pricing;
        
        //test.startTest();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acct.Id, CommercialAvail, locTitle.Id);
        insert clientAvail;
        clientAvail.status__c = 'Confirmed';
        clientAvail.Price_Tier_Text__c = pricing.Price_Tier__c;
        update clientAvail;
        //test.stopTest();
        
        Client_Avail__c cAvail = [select id,pricing__c from Client_Avail__c where Id =: clientAvail.Id];
        system.debug('*****Pricing Id:'+pricing.Id+'*****Client Avail Pricing Id:'+cAvail.pricing__c);
        system.assertEquals(pricing.Id, cAvail.pricing__c);
        
    }
    
    static testMethod void testUpdatePricing3()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        
        Title__c title1 = TestUtil.initTitle('TestGoogle', '6000047545');
        title1.Formats__c='SD';
        insert title1;
        
        Country__c France = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert France;
        
        Language__c French = TestUtil.initLanguage('TestFrench', '', 1);
        insert French;
        
        Local_Title__c locTitle = TestUtil.initLocalTitle(French.Id, France.Id);
        locTitle.Title__c = title1.Id;
        locTitle.Price_Code__c = null;
        insert locTitle;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title1.Id, locTitle.Id, France.Id, French.Id);
        insert CommercialAvail;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(acct.Id, France.Id, CommercialAvail, title1);
        insert storefrontGoogle1;
        
        Pricing__c pricing = TestUtil.initPricing(acct.Id, France.Id);
        insert pricing;
        
        Release_Plan_Country__c setting = new Release_Plan_Country__c();
        setting.Name = 'test1';
        setting.Country__c = 'TestFrance';
        setting.isActive__c = true;
        insert setting;
        
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acct.Id, CommercialAvail, locTitle.Id);
        insert clientAvail;
        clientAvail.status__c = 'Confirmed';
        clientAvail.Price_Tier_Text__c = pricing.Price_Tier__c;
        update clientAvail;
        
        test.startTest();
        WB_Batch_ClientAvailPricingUpdate b = new WB_Batch_ClientAvailPricingUpdate();
        Id batchJobId = Database.executeBatch(b, 10);
        test.stopTest();
        
        Client_Avail__c cAvail = [select id,pricing__c from Client_Avail__c where Id =: clientAvail.Id];
        system.debug('*****Pricing Id:'+pricing.Id+'*****Client Avail Pricing Id:'+cAvail.pricing__c);
        system.assertEquals(pricing.Id, cAvail.pricing__c);
        
    }
    
    /*static void testCheckDatesValidation()
    {   
        setUpdata();
        
        Test.startTest();
        
        delete [select id from Client_Avail__c];
        
        releasePlanList[0].Start_Date__c = date.today() + 10;
        releasePlanList[0].End_Date__c = date.today() + 20;
        releasePlanList[1].Start_Date__c = date.today() - 10;
        releasePlanList[1].End_Date__c = date.today() - 6;
        releasePlanList[2].Start_Date__c = date.today()+ 5;
        releasePlanList[2].End_Date__c = date.today() + 6;
        releasePlanList[3].Start_Date__c = date.today() - 20;
        releasePlanList[3].End_Date__c = date.today() - 11;
        update releasePlanList;
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=titleList[0].id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        List<Playlist_Content__c> listplaylistContent = new List<Playlist_Content__c>();
        Playlist_Content__c pc1 = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[0].id);
        listplaylistContent.add(pc1);
        Playlist_Content__c pc2 = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[1].id);
        listplaylistContent.add(pc2);
        Playlist_Content__c pc3 = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=titleList[2].id);
        listplaylistContent.add(pc3);
        insert listplaylistContent; 
        system.debug(' in Test class listplaylistContent****'+listplaylistContent);
        
        clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[0], localTitle.Id);
        clientAvail1.RP_Synch__c = true;
        clientAvailList.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[1], localTitle.Id);
        clientAvail2.RP_Synch__c = true;
        clientAvailList.add(clientAvail2);
        
        Client_Avail__c clientAvail3 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[2], localTitle.Id);
        clientAvail3.RP_Synch__c = true;
        clientAvailList.add(clientAvail3);
        
        Client_Avail__c clientAvail4 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[3], localTitle.Id);
        clientAvail4.RP_Synch__c = true;
        clientAvail4.Playlist__c = playlist.Id;
        clientAvailList.add(clientAvail4);
        insert clientAvailList;
        
        Test.startTest();
        List<Client_Avail__c> caList = [Select id,Title_Content_Type__c from Client_Avail__c Limit 10];
        WB_ClientAvailsDateCheckHandler.checkDatesValidation(clientAvailList);
        
        test.stopTest();
        
    } */
    
    static testMethod void testUpdatePricing4(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 5;
            feature1CA.Status__c = 'Tentative';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        
        Client_Avail__c feature2CA = TestUtil.initClientAvail(objAccount.Id, feature2RP, feature2LT.Id);
            feature2CA.Start_Date__c = system.today() + 10;
            feature2CA.End_Date__c = system.today() + 30;
            feature2CA.Status__c = 'Tentative';
            feature2CA.Price__c = 133;
            //feature2CA.Episode_Price_Tier__c = 'reprice12';
            feature2CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature2CA.Storefront__c = storefrontGoogle1.Id;
            //feature2CA.Channel__c = 'VODi';
            feature2CA.Price_Tier_Text__c = '';
        listClientavails.add(feature2CA);
        insert listClientavails;
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() + 2;
            collectionFeatureCA.End_Date__c = system.today() + 15;
            collectionFeatureCA.Status__c = 'Tentative';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;
            
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
    static testMethod void testUpdatePricing5(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 3;
            feature1CA.Status__c = 'Tentative';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        Client_Avail__c feature1CA2 = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA2.Start_Date__c = system.today() +6;
            feature1CA2.End_Date__c = system.today() + 7;
            feature1CA2.Status__c = 'Tentative';
            feature1CA2.Price__c = 138;
            //feature1CA2.Episode_Price_Tier__c = 'reprice12';
            feature1CA2.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA2.Storefront__c = storefrontGoogle1.Id;
            //feature1CA2.Channel__c = 'VODi';
            feature1CA2.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA2);
        
        /*Client_Avail__c feature2CA = TestUtil.initClientAvail(objAccount.Id, feature2RP, feature2LT.Id);
            feature2CA.Start_Date__c = system.today() + 10;
            feature2CA.End_Date__c = system.today() + 30;
            feature2CA.Status__c = 'Tentative';
            feature2CA.Price__c = 133;
            //feature2CA.Episode_Price_Tier__c = 'reprice12';
            feature2CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature2CA.Storefront__c = storefrontGoogle1.Id;
            //feature2CA.Channel__c = 'VODi';
            feature2CA.Price_Tier_Text__c = '';
        listClientavails.add(feature2CA);*/
        insert listClientavails;
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() + 2;
            collectionFeatureCA.End_Date__c = system.today() + 15;
            collectionFeatureCA.Status__c = 'Tentative';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;
            
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
    static testMethod void testUpdatePricing6(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 3;
            feature1CA.Status__c = 'Tentative';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        Client_Avail__c feature1CA2 = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA2.Start_Date__c = system.today() +4;
            feature1CA2.End_Date__c = system.today() + 7;
            feature1CA2.Status__c = 'Tentative';
            feature1CA2.Price__c = 138;
            //feature1CA2.Episode_Price_Tier__c = 'reprice12';
            feature1CA2.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA2.Storefront__c = storefrontGoogle1.Id;
            //feature1CA2.Channel__c = 'VODi';
            feature1CA2.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA2);
        
        insert listClientavails;
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() + 2;
            collectionFeatureCA.End_Date__c = system.today() + 15;
            collectionFeatureCA.Status__c = 'Tentative';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;
            
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
    static testMethod void testUpdatePricing7(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 3;
            feature1CA.Status__c = 'Tentative';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        Client_Avail__c feature1CA2 = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA2.Start_Date__c = system.today() +4;
            feature1CA2.End_Date__c = system.today() + 7;
            feature1CA2.Status__c = 'Tentative';
            feature1CA2.Price__c = 138;
            //feature1CA2.Episode_Price_Tier__c = 'reprice12';
            feature1CA2.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA2.Storefront__c = storefrontGoogle1.Id;
            //feature1CA2.Channel__c = 'VODi';
            feature1CA2.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA2);
        
        insert listClientavails;
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() - 3;
            collectionFeatureCA.End_Date__c = system.today() + 15;
            collectionFeatureCA.Status__c = 'Tentative';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;
            
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
    static testMethod void testUpdatePricing8(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 3;
            feature1CA.Status__c = 'Tentative';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        Client_Avail__c feature1CA2 = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA2.Start_Date__c = system.today() +4;
            feature1CA2.End_Date__c = system.today() + 7;
            feature1CA2.Status__c = 'Tentative';
            feature1CA2.Price__c = 138;
            //feature1CA2.Episode_Price_Tier__c = 'reprice12';
            feature1CA2.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA2.Storefront__c = storefrontGoogle1.Id;
            //feature1CA2.Channel__c = 'VODi';
            feature1CA2.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA2);
        
        insert listClientavails;
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() - 3;
            collectionFeatureCA.End_Date__c = system.today() + 6;
            collectionFeatureCA.Status__c = 'Confirmed';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;
            
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
    static testMethod void testUpdatePricing9(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 3;
            feature1CA.Status__c = 'Draft';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        Client_Avail__c feature1CA2 = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA2.Start_Date__c = system.today() +4;
            feature1CA2.End_Date__c = system.today() + 7;
            feature1CA2.Status__c = 'Draft';
            feature1CA2.Price__c = 138;
            //feature1CA2.Episode_Price_Tier__c = 'reprice12';
            feature1CA2.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA2.Storefront__c = storefrontGoogle1.Id;
            //feature1CA2.Channel__c = 'VODi';
            feature1CA2.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA2);
        
        insert listClientavails;
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() - 3;
            collectionFeatureCA.End_Date__c = system.today() + 6;
            collectionFeatureCA.Status__c = 'Draft';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;
            
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
    static testMethod void testUpdatePricing10(){
        
       Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                       // Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
           //objAccount.RecordTypeID = rtAcc;
           objAccount.CurrencyIsoCode = 'USD';
       insert objAccount;
        List<Title__c> titleList = new List<Title__c>();
        Title__c collectionFeatureTitle = new Title__c();
            collectionFeatureTitle.Name = 'Vampire Diaries S01';
            collectionFeatureTitle.Digital_Planning__c = 'Yes';
            collectionFeatureTitle.Clear_to_Avail__c = true;
            collectionFeatureTitle.Content_Type__c = 'Collection Features';
            collectionFeatureTitle.Video_Version__c = '000000001';
            collectionFeatureTitle.MPM__c = Mpm.id;
            collectionFeatureTitle.Formats__c = 'SD';
            collectionFeatureTitle.US_TV_Air_Date__c = system.today();
         titleList.add(collectionFeatureTitle);
  
        Title__c featureTitle1 = new Title__c();
            featureTitle1.Name = 'Vampire Diaries S01E01';
            featureTitle1.Digital_Planning__c = 'Yes';
            featureTitle1.Clear_to_Avail__c = true;
            featureTitle1.Content_Type__c = 'Feature';
            featureTitle1.Video_Version__c = '000000002';
            featureTitle1.Global_Category__c = 'TV Catalog';
            featureTitle1.MPM__c = Mpm.id;
            featureTitle1.Formats__c = 'SD';
        titleList.add(featureTitle1);
        
        Title__c featureTitle2 = new Title__c();
            featureTitle2.Name = 'Vampire Diaries S01E02';
            featureTitle2.Digital_Planning__c = 'Yes';
            featureTitle2.Clear_to_Avail__c = true;
            featureTitle2.Content_Type__c = 'Feature';
            featureTitle2.Video_Version__c = '000000003';
            featureTitle2.Global_Category__c = 'TV Catalog';
            featureTitle2.MPM__c = Mpm.id;
            featureTitle2.Formats__c = 'SD';
        titleList.add(featureTitle2);
        Insert titleList;
        
        Country__c Country = New Country__c();
            Country.Name = 'India';
            Country.Country_Code2__c = 'IN';
            Country.Country_Code__c = 'IND';
            Country.Status__c = 'Active';
            Country.TV_Day_After_US_Offset__c = 2;
            Country.TV_Day_After_Local_Offset__c = 1;
            Country.Generate_CRM_Product__c = true;
        insert Country;
        
        Language__c Language = New Language__c();
            Language.Name = 'English';
            Language.Language_Code_2__c = 'en';
            Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> alList = new List<Available_Languages__c>();
        Available_Languages__c cfAL = new Available_Languages__c();
            cfAL.Title__c = collectionFeatureTitle.Id;
            cfAL.Language__c = Language .Id;
            cfAL.Language_Types__c = 'Sub';
            cfAL.Clear_to_Avail__c = True;
        alList.add(cfAL);
        Available_Languages__c f1AL = new Available_Languages__c();
            f1AL.Title__c = featureTitle1.Id;
            f1AL.Language__c = Language .Id;
            f1AL.Language_Types__c = 'Sub';
            f1AL.Clear_to_Avail__c = True;
        alList.add(f1AL);
        Available_Languages__c f2AL = new Available_Languages__c();
            f2AL.Title__c = featureTitle2.Id;
            f2AL.Language__c = Language .Id;
            f2AL.Language_Types__c = 'Sub';
            f2AL.Clear_to_Avail__c = True;
        alList.add(f2AL);
        insert alList;
        
        Playlist__c playlist = new Playlist__c();
            playlist.name = 'test playlist';
            playlist.Version_Number__c = 1;
            playlist.Parent_Title__c = collectionFeatureTitle.id;
            playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c f1PC = new Playlist_Content__c();
            f1PC.Content_Title__c=featureTitle1.id;
            f1PC.Playlist__c = playlist.id;
        contentlist.add(f1PC);
        
        Playlist_Content__c f2PC = new Playlist_Content__c();
            f2PC.Content_Title__c=featureTitle2.id;
            f2PC.Playlist__c = playlist.id;
        contentlist.add(f2PC);
        
        insert contentlist;
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        
        Local_Title__c collectionFeatureLT = New Local_Title__c();
            collectionFeatureLT.Name = collectionFeatureTitle.Name;
            collectionFeatureLT.Title__c = collectionFeatureTitle.Id;
            collectionFeatureLT.Country__c = Country.Id;
            collectionFeatureLT.Language__c = Language.Id;
            collectionFeatureLT.Local_TV_Air_Date__c = date.today();
            collectionFeatureLT.Playlist__C = playlist.id;
            collectionFeatureLT.Price_Code__c = 'CheckPriceCode';
            collectionFeatureLT.Category__c = 'TV Catalog';
        listlocaltitles.add(collectionFeatureLT);
        
        Local_Title__c feature1LT = New Local_Title__c();
            feature1LT.Name = featureTitle1.Name;
            feature1LT.Title__c = featureTitle1.Id;
            feature1LT.Country__c = Country.Id;
            feature1LT.Language__c = Language.Id;
            feature1LT.Local_TV_Air_Date__c = date.today();
            //feature1LT.Parent_Local_Data__c=LT.id;
            feature1LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature1LT);
        
        Local_Title__c feature2LT = New Local_Title__c();
            feature2LT.Name = featureTitle2.Name;
            feature2LT.Title__c = featureTitle2.Id;
            feature2LT.Country__c = Country.Id;
            feature2LT.Language__c = Language.Id;
            feature2LT.Local_TV_Air_Date__c = date.today();
            //feature2LT.Parent_Local_Data__c=LT.id;
            feature2LT.Category__c = 'TV Catalog';
        listlocaltitles.add(feature2LT);
        
        Insert listlocaltitles;
        
        List<Commercial_Avail__c>listReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c collectionFeatureRP = new Commercial_Avail__c();
            collectionFeatureRP.Channel__c = 'VODi';
            collectionFeatureRP.Title__c= collectionFeatureTitle.id;
            collectionFeatureRP.Languages__c = Language.id;
            collectionFeatureRP.Country_Lookup__c = Country.id;
            collectionFeatureRP.Format__c = 'SD';
            collectionFeatureRP.Language_Type__c = 'Sub';
            collectionFeatureRP.Exclusive_Date__c = date.today()-200;
            collectionFeatureRP.Start_Date__c = date.today()-100;
            collectionFeatureRP.End_Date__c = date.today()+100;
            collectionFeatureRP.Rights_End__c=date.today()+200;
            collectionFeatureRP.Status__c = 'Confirmed';
            collectionFeatureRP.Playlist__C = playlist.id;
            collectionFeatureRP.Local_Title__c = collectionFeatureLT.Id;
        listReleaseplan.add(collectionFeatureRP);
        
        Commercial_Avail__c feature1RP = new Commercial_Avail__c();
            feature1RP.Channel__c = 'VODi';
            feature1RP.Title__c= featureTitle1.id;
            feature1RP.Languages__c = Language.id;
            feature1RP.Country_Lookup__c = Country.id;
            feature1RP.Format__c = 'SD';
            feature1RP.Language_Type__c = 'Sub';
            feature1RP.Exclusive_Date__c = system.today()-200;
            feature1RP.Start_Date__c = system.today()-70;
            feature1RP.End_Date__c = system.today()+70;
            feature1RP.Rights_End__c=system.today()+200;
            feature1RP.Status__c = 'Confirmed';
            feature1RP.Local_Title__c = feature1LT.Id;
        listReleaseplan.add(feature1RP);
        
        Commercial_Avail__c feature2RP = new Commercial_Avail__c();
            feature2RP.Channel__c = 'VODi';
            feature2RP.Title__c=featureTitle2.id;
            feature2RP.Languages__c = Language.id;
            feature2RP.Country_Lookup__c = Country.id;
            feature2RP.Format__c = 'SD';
            feature2RP.Language_Type__c = 'Sub';
            feature2RP.Exclusive_Date__c = system.today()-200;
            feature2RP.Start_Date__c = system.today()-70;
            feature2RP.End_Date__c = system.today()+70;
            feature2RP.Rights_End__c=system.today()+200;
            feature2RP.Status__c = 'Confirmed';
            feature2RP.Local_Title__c = feature2LT.Id;
        listReleaseplan.add(feature2RP);
        
        insert listReleaseplan;
        
        
        
       Agreement__c storefrontGoogle1 = new Agreement__c(
                    Account__c = objAccount.Id,
                    Active__c = true,
                    Content_Type__c = 'Collection Features;Feature',
                    Pricing_Currency__c = 'USD',
                    Format__c = 'SD',
                    Status__c = 'Active', 
                    //Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'VODi',
                    Country__c = Country.ID,
                    SAP_Customer_Number__c='12010421'
            );
        storefrontGoogle1.CRM_Account__c = objAccount.Id;      
        storefrontGoogle1.Status__c = 'Active';
        insert storefrontGoogle1;
        
	    List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
	    Client_Avail__c feature1CA = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA.Start_Date__c = system.today() - 1;
            feature1CA.End_Date__c = system.today() + 3;
            feature1CA.Status__c = 'Draft';
            feature1CA.Price__c = 132;
            //feature1CA.Episode_Price_Tier__c = 'reprice12';
            feature1CA.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA.Storefront__c = storefrontGoogle1.Id;
            //feature1CA.Channel__c = 'VODi';
            feature1CA.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA);
        Client_Avail__c feature1CA2 = TestUtil.initClientAvail(objAccount.Id, feature1RP, feature1LT.Id);
            feature1CA2.Start_Date__c = system.today() +4;
            feature1CA2.End_Date__c = system.today() + 7;
            feature1CA2.Status__c = 'Draft';
            feature1CA2.Price__c = 138;
            //feature1CA2.Episode_Price_Tier__c = 'reprice12';
            feature1CA2.Local_Data_Category_Picklist__c = 'TV Catalog';
            feature1CA2.Storefront__c = storefrontGoogle1.Id;
            //feature1CA2.Channel__c = 'VODi';
            feature1CA2.Price_Tier_Text__c = '';
        listClientavails.add(feature1CA2);
         insert listClientavails;
        CA_Upload__c caUpload = new CA_Upload__c(Upload_Status__c='Waiting To Process');
        insert caUpload;
        List<CA_Upload_Record__c> listCAUploadRecords = new List<CA_Upload_Record__c>();
        CA_Upload_Record__c objCAUR1 = TestUtil.initCAUploadRecord('TestAccount', 'TV Catalog', caUpload, 'VODi', 'India', system.today() + 6, 'SD', '', 'English', 'Sub', '147', '',
                                                                   '', '', '',NULL , '', system.today() - 3, 'Draft',NULL, '000000001');
        
        listCAUploadRecords.add(objCAUR1);
        insert listCAUploadRecords;
        WB_Batch_CA_Upload batch = new WB_Batch_CA_Upload(caUpload.id);
        Database.executebatch(batch,10);
        /*Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = True;
        Client_Avail__c collectionFeatureCA = TestUtil.initClientAvail(objAccount.Id, collectionFeatureRP, collectionFeatureLT.Id);
            collectionFeatureCA.Start_Date__c = system.today() - 3;
            collectionFeatureCA.End_Date__c = system.today() + 6;
            collectionFeatureCA.Status__c = 'Draft';
            collectionFeatureCA.Price__c = 134;
            //collectionFeatureCA.Episode_Price_Tier__c = 'reprice12';
            collectionFeatureCA.Local_Data_Category_Picklist__c = 'TV Catalog';
            collectionFeatureCA.Storefront__c = storefrontGoogle1.Id;
            //collectionFeatureCA.Channel__c = 'VODi';
            collectionFeatureCA.Price_Tier_Text__c = '';
            //collectionFeatureCA.Playlist__c = playlist.Id;
            collectionFeatureCA.Batch_Id__c = batchIdCustomSetting.Id;
            collectionFeatureCA.Title__c = collectionFeatureTitle.Id;
            insert collectionFeatureCA;
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            collectionFeatureCA.Playlist__c = playlist.Id;
            update collectionFeatureCA;*/
         
        test.startTest();
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
            List<Client_Avail__c> caList = [Select Id,Name, Release_Plan_Title__c, Playlist__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Language__c, Release_Plan_Channel__c, Client__c, Batch_Id__c,Title_Content_Type__c,Start_Date__c, End_Date__c, Status__c FROM Client_Avail__c WHERE Title_Content_Type__c = 'Collection Features'];
            System.debug('+++++++Printing CF CA'+caList);
            WB_ClientAvailsDateCheckHandler.checkDatesValidation(caList); 
            WB_ClientAvailPriceHandler.recursiveUpdate = True;
        test.stopTest();
    
    }
}