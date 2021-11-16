/*
Class Name   : WB_CreateClientAvail_Cont_Test 
Description  : This class is to do code coverage for WB_CreateClientAvail_Controller class    
Created By   : Cognizant Technology Solutions - Rashmi
Created On   : DEC 2014
Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1               [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]
CH01            ER-000390 - III : Added Assertions              Akash                                                      05/23/2016
*/


@isTest 
private class WB_CreateClientAvail_Cont_Test{
    public static List<Title__c> title_List = new List<Title__c>();
    public static List<Country__c> country_List = new List<Country__c>();
    public static List<Pricing__c> price_List = new List<Pricing__c>();
    public static List<Local_Title__c> listlocaltitles;
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    public static List<Client_Avail__c> listClientavails;
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    
    @isTest
    static void myUnitTest1() {
        
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        insert countryJapan;
        
        Language__c languageFrench = new Language__c(Name='French',Language_Order__c = 1,Language_Code_2__c='fr');
        insert languageFrench;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        insert listAvailLang;
        
        List<Language_Preference__c> langPrefList = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Country',Language__c=languageFrench.Id,Level__c='1');
        langPrefList.add(langPrefTest);
        
        insert langPrefList;
        //Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        //langPrefList.add(langPrefTest2);

        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        List<Language_Preference__c> langPrefListTypeSF = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Storefront',Language__c=languageFrench.Id,Level__c='1',Account__c = acctGoogle.Id,Storefront__c=storefrontGoogle1.Id);
        langPrefListTypeSF.add(langPrefTest1);
        
        insert langPrefListTypeSF;

        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c = date.today()+3,End_Date__c=releaseplan1.End_Date__c
            
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        Test.startTest();
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
            //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            //WB_CreateClientAvail_Controller.accountwrapper accwrap = new WB_CreateClientAvail_Controller.accountwrapper();
            controller.selectedAccountslistwrap[0].selected = true;
            controller.getSelected();
            PageReference pageR = controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            
            // get the list of ApexPages.Message
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
            }
            
        }
        //delete clientAvailList; 
        Test.stopTest();
        
        
        
    }
    
    @isTest
    static void myUnitTest2() {
        
        List<Account> accountList = new List<Account>();
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account acctGoogle = new Account(Name='TestGoogle',Customer_Focus__c='Active', recordtypeId = rtypeId);
        accountList.add(acctGoogle);
        Account acctAmazon = new Account(Name='TestAmazon',Customer_Focus__c='Active', recordtypeId = rtypeId);
        accountList.add(acctAmazon);
        insert accountList;
        
        List<Title__c> titleList = new List<Title__c>();
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        titleList.add(title1);
        titleList.add(title2);
        insert titleList;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF', Territory__c = 'France');
        insert countryFrance;
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ', Territory__c = 'Japan');
        insert countryJapan;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,Country__c = countryFrance.Id,
                                           Channel__c ='DTD',Format__c ='HD');
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(), End_Date__c= date.today().addDays(10), Rights_End__c=date.today().addDays(11)
                                                                  );
        insert releaseplan1;
        string CommIds = releaseplan1.Id;
        
        List<Agreement__c> agreementList = new List<Agreement__c>();
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        agreementList.add(storefrontGoogle1);
        Agreement__c storefrontAmazon1 = new Agreement__c(
            Account__c=acctAmazon.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        agreementList.add(storefrontAmazon1);
        
        //insert storefrontGoogle1; 
        insert agreementList;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        List<Client_Avail__c> clientAvailsUpdateList = new List<Client_Avail__c>();
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.Start_Date__c.addDays(2), RP_Synch__c = true
        );
        clientAvailList.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c.addDays(3),End_Date__c=releaseplan1.Start_Date__c.addDays(5), RP_Synch__c = true
        );
        clientAvailList.add(clientAvail2);
        
        Test.startTest();
        Client_Avail__c clientAvail3 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c.addDays(6),End_Date__c=releaseplan1.Start_Date__c.addDays(8), RP_Synch__c = true
        );
        clientAvailList.add(clientAvail3);
        
        Client_Avail__c clientAvail4 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.Start_Date__c, RP_Synch__c = false
        );
        clientAvailList.add(clientAvail4);
        
        insert clientAvailList;
        
        clientAvail1.RP_Synch__c = false;
        clientAvail1.Start_Date__c = null;
        clientAvail1.End_Date__c = null;
        clientAvailsUpdateList.add(clientAvail1);
        
        clientAvail3.RP_Synch__c = false;
        clientAvail3.Client__c=acctAmazon.Id;
        clientAvailsUpdateList.add(clientAvail3);
        clientAvailsUpdateList.add(clientAvail4);
        
        if(clientAvailsUpdateList.size() > 0){
            try{
                system.debug('clientAvailsUpdateList---- ' +clientAvailsUpdateList.size());
                update clientAvailsUpdateList;
            }catch(Exception Ex){
                system.debug('Update exception is ====: ' + Ex.getMessage());
            }
        }
        
        Profile p = [select id from profile where name=: System.Label.WB_Territory_Release_Planner];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id, Territory__c = 'France'
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            
            try {
                controller.bulksave();
                controller.bulkcancel();
            } catch(exception e) {
                System.Assert(e.getMessage().contains('Start date is overlapping with existing record'));
            }
        }
        delete clientAvailList;
        Test.stopTest();
    }
    
    @isTest
    static void myUnitTest3() {
        
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        List<Title__c> titleList = new List<Title__c>();
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        titleList.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        titleList.add(title2);
        insert titleList;
        
        List<Country__c> countryList = new List<Country__c>();
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        //insert countryFrance;
        countryList.add(countryFrance);
        
        Country__c countryUSA =new Country__c(Name ='USA',Country_Code2__c ='US',Country_Code__c='US');
        //insert countryUSA;
        countryList.add(countryUSA);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        //insert countryJapan;
        countryList.add(countryJapan);
        insert countryList;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1);
        insert languageEnglish;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =titleList[0].Id,Country__c = countryList[0].Id,
                                                   Language__c =languageFrench.Id);//,Price_Code__c =price1.Name);
        insert local1 ;
        
        List<Commercial_Avail__c> commAvailList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=titleList[0].Id,Country_Lookup__c=countryList[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2);
        
        //insert releaseplan1;
        commAvailList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=titleList[1].Id,Country_Lookup__c=countryList[2].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+4,Rights_End__c=date.today()+12);
        
        //insert releaseplan2;
        commAvailList.add(releaseplan2);
        insert commAvailList;
        
        string CommIds = commAvailList[0].Id +','+commAvailList[1].Id ;
        
        Test.startTest();
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryList[0].Id, Pricing_Currency__c='FR', Content_Type__c=titleList[0].Content_Type__c,
            Channel_Picklist__c=commAvailList[0].Channel__c, Format__c=commAvailList[0].Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=commAvailList[0].Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=commAvailList[0].Start_Date__c,End_Date__c=commAvailList[0].Start_Date__c
        );
        Client_Avail__c clientAvail11 = new Client_Avail__c(
            Commercial_Avail__c=commAvailList[0].Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=commAvailList[0].Start_Date__c.addDays(1),End_Date__c=commAvailList[0].Start_Date__c.addDays(1)
        );
        insert clientAvail11;
        Announcement_Rule__c objAnnType = new Announcement_Rule__c(
            Account__c = acctGoogle.Id,
            Announcement_Type__c = 'test1111',
            Channels__c = 'DTD',
            Content_Type__c = 'Feature',
            Disposition__c = 'Active',
            Announcement_From_Email__c = 'test@test.com',
            Announcement_From_Name__c = 'Test',
            Statuses__c = 'Confirmed',
            Selection_Criteria__c = 'Delta'
        );
        insert objAnnType;
        
        Announcement__c objAnn = new Announcement__c(
            Announcement_Type__c = objAnnType.Id,
            Account__c = acctGoogle.Id,
            Report_Id__c = '',
            Report_Name__c = 'WB_Standard_Combined',
            Email_Template__c = 'Announcement USA Standard',
            Name__c = 'Test Announcement',
            Run_Date__c = Date.today(),
            From_Date__c = Date.today(),
            Status__c = 'Confirmed,Tentative,Cancelled',
            Sent_Date__c = Date.today(),
            Job_Run_Status__c = 'Completed',
            Selection_Criteria__c = 'Delta',
            Channels__c = 'DTD',
            Content_Type__c = 'Feature'
        );
        insert objAnn;
        
        Announcement_Record__c annRecord = new Announcement_Record__c(Client_Avail__c = clientAvail11.Id,Announcement__c = objAnn.Id,Change_Status__c = 'New', Account__c = acctGoogle.Id);
        
        delete clientAvail11;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.forceBatchProcessChk = true;
            controller.deleteExceptionedRecords();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            
            controller.batchProcessEmailNotificationOkBtn();
            controller.pageRedirect();
            controller.bulkcancel();
            
            System.assertEquals(0, controller.selectedStorefronts.size());
        }
        Test.stopTest();
    }
    
    @isTest
    static void myUnitTest4() {
        
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
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HDD'
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Test.startTest();
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.obj = new Client_Avail__c(status__c = 'Confirmed');
            controller.forceBatchProcessChk = true;
            controller.deleteExceptionedRecords();
            //WB_CreateClientAvail_Controller.accountwrapper accwrap = new WB_CreateClientAvail_Controller.accountwrapper();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            
            System.assertEquals(0, controller.selectedStorefronts.size());
            System.assertEquals(true, controller.forceBatchProcessChk);
        }
        //delete clientAvailList; 
        Test.stopTest();
        
    }
    
    @isTest
    static void myUnitTest5() {
        
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
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'//HDD
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id);//,Price_Code__c =price1.Name
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        //insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        wizardRunFlag__c wzflg = new wizardRunFlag__c(name ='FlagValue',WizardFlag__c = 'False');
        insert wzflg;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Test.startTest();
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            //WB_CreateClientAvail_Controller.accountwrapper accwrap = new WB_CreateClientAvail_Controller.accountwrapper();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            
            System.assertEquals(1, controller.selectedStorefronts.size());
        }
        //delete clientAvailList; 
        Test.stopTest();
    }
    
    @isTest
    static void myUnitTest6() {
        
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
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'//HDD
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id);//,Price_Code__c =price1.Name
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Test.startTest();
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.bulkcancel();
            
            // get the list of ApexPages.Message
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(0, controller.selectedStorefronts.size());
                System.assert(msg.getSummary().contains(System.Label.No_storefronts_were_found));
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void myUnitTest7() {
        
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
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'//HDD
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id);//,Price_Code__c =price1.Name
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        wizardRunFlag__c wzflg = new wizardRunFlag__c(name ='FlagValue',WizardFlag__c = 'False');
        insert wzflg;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Pending',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '1234',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '1555',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Test.startTest();
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            
            System.assertEquals(0, controller.selectedStorefronts.size());
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void nonMatchingStorefrontChannel() {
        
        
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
                                                   Language__c =languageFrench.Id);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Format__c=releaseplan1.Format__c, Status__c ='Active', Channel_Picklist__c='VODi',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        
        Test.startTest();
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();    
            System.assertEquals(1, controller.selectedStorefronts.size());
        }
        Test.stopTest();
    }  
    @isTest
    static void missingStorefrontChannel() {
        
        
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
                                                   Language__c =languageFrench.Id);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',Channel__c=null,//Channel__c='DTD',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=languageFrench.Id,
            Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',Channel__c=null,//Channel__c='DTD',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title2.Content_Type__c,
            Format__c=releaseplan1.Format__c, Status__c ='Active', Channel_Picklist__c='VODi',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        system.debug('storefrontGoogle1 ====: ' + storefrontGoogle1);
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u9 = new User(
            alias = 'standt2', email='testuser9@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u9;
        Id u9id = u9.Id;
        
        Test.startTest();
        System.runAs(u9){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.str = String.valueOf(CommIds);
            controller.commercialAvailIds = null;
            controller.clientAvailException_list = null;
            controller.deleteExceptionedRecords();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            controller.pageRedirect();
            controller.batchProcessEmailNotificationOkBtn();       
            System.assertEquals(1, controller.selectedStorefronts.size());
        }
        Test.stopTest();
    }
    
    //ER-529
    @isTest
    static void myUnitTest9() {
        
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
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'//HDD
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id);//,Price_Code__c =price1.Name
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today(), Start_Date__c=date.today(),End_Date__c= date.today()+30,Rights_End__c=date.today()+30
                                                                  );
        insert releaseplan1;
        
        string CommIds = releaseplan1.Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,Client_Start_Ovver__c=date.today()+2,End_Date__c=releaseplan1.End_Date__c
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Test.startTest();
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            System.assertEquals(1, controller.selectedStorefronts.size());
        }
        Test.stopTest();
    }
    
    @isTest
    static void myUnitTest10() {
        
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
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c = null);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today(), Start_Date__c=date.today(),End_Date__c= date.today()+30,Rights_End__c=date.today()+30
                                                                  );
        insert releaseplan1;
        
        string CommIds = releaseplan1.Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c=date.today()+60,RP_Synch__c = true
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Test.startTest();
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            if(controller.selectedAccountslistwrap.size() > 0){
                controller.selectedAccountslistwrap[0].selected = true;
            }
            controller.getSelected();
            controller.bulksave();
            controller.batchIdForApexBatch();
            System.assertEquals(1, controller.selectedStorefronts.size());
        }
        Test.stopTest();
    }
    
    //ER-529
    private static Country__c createCountry(String cName,String countryCode,String CountryCode2,String Territory){
        Country__c country = new Country__c(Name = cName,Country_Code2__c = countryCode,
                                            Territory__c = Territory,
                                            Country_Code__c = CountryCode2);
        return country;
    }
    //create Local Title Records    
    private static List<Local_Title__c> createLocalTitle (Integer noOfRecs,Title__c title,Language__c language,List<Country__c> countrylst) {
        List<Local_Title__c> localTitleList = new List<Local_Title__c>();
        
        if(noOfRecs > 0 ) {
            for(Integer i= 0 ;i< noOfRecs;i++){
                localTitleList.add(new Local_Title__c(Name = 'Local Title'+i,
                                                      Title__c = title.Id,
                                                      Country__c = countrylst[i].Id,
                                                      Language__c = language.Id,
                                                      Price_Code__c = null)) ;
            }
        }
        return localTitleList;
    }
    private static List<Commercial_Avail__c> createCommercialAvail (Integer noOfRecs,Title__c Title,List<Country__c> countryLst,
                                                                    List<Local_Title__c> localTitleLst,Language__c language){
                                                                        
                                                                        List<Commercial_Avail__c> commercialAvailLst = new List<Commercial_Avail__c>();
                                                                        if(noOfRecs > 0 ) {
                                                                            for(Integer i= 0 ;i< noOfRecs;i++){
                                                                                commercialAvailLst.add(new Commercial_Avail__c(
                                                                                    Title__c = title.Id,
                                                                                    Country_Lookup__c = countryLst[i].Id,
                                                                                    Local_Title__c = localTitleLst[i].Id,
                                                                                    Languages__c = language.Id,
                                                                                    Channel__c='DTD',Format__c='HD',
                                                                                    Language_Type__c='Dub',Status__c='Tentative',
                                                                                    Exclusive_Date__c = date.today()+i, Start_Date__c=date.today()+i,
                                                                                    End_Date__c= date.today()+30+i,Rights_End__c=date.today()+30+i)) ;
                                                                            }
                                                                        }
                                                                        return commercialAvailLst;
                                                                    }
    
    
    private static List<Agreement__c> createStoreFront (integer noOfRecs,Account acc,List<Country__c> countryLst,Title__c title,
                                                        List<Commercial_Avail__c> commeAvailLst){
                                                            List<Agreement__c> storeFrontLst = new List<Agreement__c>();
                                                            if(noOfRecs > 0 ) {
                                                                for(Integer i= 0 ;i< noOfRecs;i++){
                                                                    storeFrontLst.add(new Agreement__c(
                                                                        Account__c=acc.Id,
                                                                        Content_Type__c=title.Content_Type__c,
                                                                        Country__c = countryLst[i].Id,
                                                                        Channel_Picklist__c = commeAvailLst[i].Channel__c,
                                                                        Format__c = commeAvailLst[i].Format__c,
                                                                        Status__c ='Active',
                                                                        Pricing_Currency__c='FR',SAP_Customer_Number__c='12010421')) ;
                                                                }
                                                            }
                                                            return storeFrontLst;
                                                        }
    
    private static List<Client_Avail__c> createClientAvail (Integer noOfRecs,List<Commercial_Avail__c> commeAvailList, Account acc) {
        List<Client_Avail__c> clientAvailLst = new List<Client_Avail__c>();
        for(Integer i= 0 ;i< noOfRecs;i++){
            clientAvailLst.add(new Client_Avail__c(
                Client__c=acc.Id,
                Start_Date__c = date.today() + 2 + i,
                End_Date__c = date.today()+10+i,
                Commercial_Avail__c = commeAvailList[i].Id,
                Status__c ='Draft')) ;
        }
        return clientAvailLst;
    }
    
    private static List<Client_Avail__c> createChildClientAvail (Integer noOfRecs,List<Commercial_Avail__c> commeAvailList, Account acc,List<Client_Avail__c> parentClientAvailLst) {
        List<Client_Avail__c> clientAvailLst = new List<Client_Avail__c>();
        for(Integer i= 0 ;i< noOfRecs;i++){
            clientAvailLst.add(new Client_Avail__c(
                Client__c=acc.Id,
                Commercial_Avail__c = parentClientAvailLst[i].Commercial_Avail__c,
                Status__c ='Draft',
                Local_Data_Category_Picklist__c = 'TV Catelog',
                Parent_Client_Avail__c =parentClientAvailLst[i].Id )) ;
        }
        return clientAvailLst;
    }
    //Test method covers the logic for assignOwner method 
    @isTest
    static void myUnitTest11() {
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        List<Country__c> countryList = new List<Country__c>();
        List<Local_Title__c> localTitleList =new List<Local_Title__c>();
        List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c>();
        List<Agreement__c> storeFrontList = new List<Agreement__c>();
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title2;
        
        Country__c countryAPAC = createCountry('TestFrance','TR','TR','APAC Licensee Group');
        countryList.add(countryAPAC);
        Country__c countryJapan = createCountry('TestJapan','TJ','TJ','Japan');
        countryList.add(countryJapan);
        Country__c countryUK = createCountry('TestUK','UK','UK','United Kingdom');
        countryList.add(countryUK);
        Country__c countrySpain = createCountry('TestSpain','SP','SP','Spain');
        countryList.add(countrySpain);
        Country__c countryNordic = createCountry('TestNordic','NR','NR','Nordic');
        countryList.add(countryNordic);
        Country__c countryMexico = createCountry('TestMexico','MX','MX','Mexico');
        countryList.add(countryMexico);
        Country__c countryKorea = createCountry('TestKorea','KR','KR','Korea');
        countryList.add(countryKorea);
        Country__c countryItaly = createCountry('TestItaly','IT','IT','Italy');
        countryList.add(countryItaly);
        Country__c countryHM = createCountry('TestHomeOffice','HO','HO','Home Office');
        countryList.add(countryHM);
        Country__c countryGermany = createCountry('TestGermany','GR','GR','Germany');
        countryList.add(countryGermany);
        Country__c countryFrance = createCountry('TestFrance','FR','FR','France');
        countryList.add(countryFrance);
        Country__c countryLG = createCountry('TestLG','LG','LG','EMEA Licensee Group');
        countryList.add(countryLG);
        Country__c countryChina = createCountry('TestChina','CH','CH','China');
        countryList.add(countryChina);
        Country__c countryBrazil = createCountry('TestBrazil','BR','BR','Brazil');
        countryList.add(countryBrazil);
        
        insert countryList;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        localTitleList =  createLocalTitle (countryList.size(),title1,languageFrench,countryList);
        insert localTitleList;
        
        
        commercialAvailList = createCommercialAvail(countryList.size(),title1,countryList,localTitleList,languageFrench);
        insert commercialAvailList;
        
        storeFrontList = createStoreFront(countryList.size(),acctGoogle,countryList,title1,commercialAvailList);
        insert storeFrontList;
        
        system.debug('Inserting CA ********');
        clientAvailList = createClientAvail (countryList.size(),commercialAvailList,acctGoogle);
        insert clientAvailList;
        /*test.startTest();
List<Client_Avail__c> CA = new List<Client_Avail__c>();
for(Client_Avail__c c: clientAvailList)
{
c.Start_Date__c  = date.today()+20;
CA.add(c);
}
update CA;
test.stopTest();*/
        
    } 
    
    @isTest
    static void myUnitTest12() {
        
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm; 
        
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        // /* -- Title creation-- */
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
        
        Title__c episodeTitle = new Title__c();
        episodeTitle.Name = 'Episode Title1';
        episodeTitle.Digital_Planning__c = 'Yes';
        episodeTitle.Clear_to_Avail__c = true;
        episodeTitle.Content_Type__c = 'Episode';
        episodeTitle.Video_Version__c = '000000002';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle.MPM__c = Mpm.id;
        episodeTitle.Formats__c='SD';
        Insert episodeTitle;
        
        Title__c episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Episode Title1';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        episodeTitle2.Formats__c='SD';
        Insert episodeTitle2;
        
        Playlist__c playlist = new Playlist__c();
        playlist.name = 'test playlist';
        playlist.Version_Number__c = 1;
        playlist.Parent_Title__c = t.id;
        playlist.Playlist_Status__c = 'Active';
        insert playlist;
        
        Playlist__c playlist1 = new Playlist__c();
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
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        
        
        List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = date.today();
        LT.Playlist__C = playlist.id;
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
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
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
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
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
        
        Agreement__c storefrontGoogle1 = initStoreFront(acctGoogle.Id, country.Id, listReleaseplan[0], t);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
        insert storefrontGoogle1;
        
        List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, listReleaseplan[0], listlocaltitles[0].Id);
        clientAvail.Playlist__c = playlist.id;
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail.Lock_Pricing_Update__c = false;
        clientAvail.RP_Synch__c = false;
        listClientavails.add(clientAvail);
        test.startTest();
        insert listClientavails;
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, listReleaseplan[0], listlocaltitles[1].Id);
        clientAvail1.Title__c = episodeTitle.id;
        clientAvail1.Avail_Type__c = 'Automated'; 
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        clientAvail1.Parent_Client_Avail__c = listClientavails[0].id;
        insert clientAvail1;
        
        test.stopTest();
        List<Episode_Avails_Scheduler__c> listSetting  = [select id,Scheduler_Id__c,name from Episode_Avails_Scheduler__c];
        for( Episode_Avails_Scheduler__c settingrecord : listSetting){
            System.abortJob(settingrecord.Scheduler_id__c);
        }
        delete listSetting;
        system.debug('*******Episode avail list'+[Select count() from Client_Avail__c where Title_content_Type__c ='Episode']);
        clientAvail.Start_Date__c = system.today()+10;
        clientAvail.Episode_Price_Tier__c = 'tbd';
        try{
            update clientAvail;
        }
        catch(Exception e){
            string message = e.getmessage();
            Boolean flag = message.contains('Season Avails with a Playlist cannot be confirmed with a TBD Episode Price Tier');
            system.assertEquals(true,flag);
        }
    }
    public static Agreement__c initStoreFront(Id accId, Id countryId, Commercial_Avail__c objCA, Title__c objTitle)
    {
        Agreement__c objAgreement = new Agreement__c(Account__c = accId
                                                     , country__c = countryId
                                                     , Status__c = 'Active'
                                                     , Pricing_Currency__c ='FR'
                                                     , Content_Type__c = 'Season;Episode'
                                                     , Channel_Picklist__c = objCA.Channel__c
                                                     , Format__c = objCA.Format__c,SAP_Customer_Number__c='12010421');
        return objAgreement;
    }
    
    @isTest
    public static void UpdateEpisodeAvails() {
        
        List<Account> accList = new List<Account>();
        List<Title__c> titleList = new List<Title__c>();
        List<Country__c> cList = new List<Country__c>();
        List<Language__c> lList = new List<Language__c>();
        List<Local_Title__c> lTitle = new List<Local_Title__c>();
        List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
        List<Agreement__c> aList = new List<Agreement__c>();
        List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
        List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
        List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
        List<String> selectedClientAvailIds = new List<String>();
        List<Pricing__c> lPricing = new List<Pricing__c>();
        Integer count=3;    
        Playlist__c playlist1;
        Playlist__c playlist12;
        Account objAccount;
        List<Local_Title__c> listlocaltitles;
        List<Client_Avail__c> listClientavails;
        Commercial_Avail__c releasePlan1;
        List<Commercial_Avail__c> listReleaseplan;
        Title__c t;
        Title__c episodeTitle;
        Language__c Language;
        Country__c Country; 
        Account objAccount1;
        Title__c t1;
        Title__c episodeTitle1;
        Title__c episodeTitle2;
        Playlist__c playlist123;
        Playlist__c playlist13;
        Language__c Language1;
        Country__c Country_1; 
        List<Local_Title__c> listlocaltitles12;
        List<Client_Avail__c> listClientavails12;
        List<Pricing__c> lPricing5 = new List<Pricing__c>();
        List<Commercial_Avail__c> listReleaseplan_1;
        Commercial_Avail__c releasePlan_1;
        
        /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c(); 
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646'; 
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        objAccount1 = TestUtil.initAccount();
        objAccount1.Type='Global';
        insert objAccount1;
        
        /* -- Title creation-- */
        t1 = new Title__c();
        t1.Name = 'Vampire Diaries S01';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '000000001';
        t1.MPM__c = Mpm.id;
        t1.US_TV_Air_Date__c = system.today();
        t1.Formats__c='SD';
        Insert t1;
        
        episodeTitle1 = new Title__c();
        episodeTitle1.Name = 'Vampire Diaries S01E01';
        episodeTitle1.Digital_Planning__c = 'Yes';
        episodeTitle1.Clear_to_Avail__c = true;
        episodeTitle1.Content_Type__c = 'Episode';
        episodeTitle1.Video_Version__c = '000000002';
        episodeTitle1.Global_Category__c = 'TV Catalog';
        episodeTitle1.Formats__c='SD';
        episodeTitle1.MPM__c = Mpm.id;
        Insert episodeTitle1;
        
        episodeTitle2 = new Title__c();
        episodeTitle2.Name = 'Vampire Diaries S01E02';
        episodeTitle2.Digital_Planning__c = 'Yes';
        episodeTitle2.Clear_to_Avail__c = true;
        episodeTitle2.Content_Type__c = 'Episode';
        episodeTitle2.Video_Version__c = '000000003';
        episodeTitle2.Global_Category__c = 'TV Catalog';
        episodeTitle2.MPM__c = Mpm.id;
        episodeTitle2.Formats__c='SD';
        Insert episodeTitle2;
        
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t1.id;
        playlist123.Playlist_Status__c = 'Active';
        //insert playlist123;
        
        Country_1 = New Country__c();
        Country_1.Name = 'IndiaC';
        Country_1.Country_Code2__c = 'IA';
        Country_1.Country_Code__c = 'IA';
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
        pricing5.Channel__c='VODi';
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
        pricing51.Channel__c='VODi';
        pricing51.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        pricing51.Price_Tier__c ='123';
        pricing51.Episode_Price_Tier__c='89.9';
        pricing51.Format__c='SD';
        lPricing5.add(pricing51);
        
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
        //LT.Playlist__C = playlist123.id;
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
        episodeLT.Category__c = 'TV New Release';
        listlocaltitles12.add(episodeLT);
        
        Insert listlocaltitles12;
        
        for(Local_Title__c lt1 : listlocaltitles12){
            system.debug('####Local_Title__c:'+lt1); 
        }
        
        listReleaseplan_1 = new List<Commercial_Avail__c>();
        releasePlan_1 = new Commercial_Avail__c();
        releasePlan_1.Channel__c = 'VODi';
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
        //releasePlan_1.Playlist__C = playlist123.id;
        listReleaseplan_1.add(releasePlan_1);
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.Title__c=episodeTitle1.id;
        releasePlan2.Languages__c = Language1.id;
        releasePlan2.Country_Lookup__c = Country_1.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = system.today()-200;
        releasePlan2.Start_Date__c = system.today()-70;
        releasePlan2.End_Date__c = system.today()+170;
        releasePlan2.Rights_End__c=system.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        
        listReleaseplan_1.add(releasePlan2);
        
        
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount1.Id, country_1.Id, listReleaseplan_1[0], t1);
        storefrontGoogle1.Formats_with_EC__c = listReleaseplan_1[0].Format__c;
        storefrontGoogle1.Content_Type__c = 'Episode;Season';
        insert storefrontGoogle1;
        
        
        countrySIDList.add(new Country_SID_Key__c(Name='IndiaC', Country_Code__c='IA',Country_Code2_c__c='IA',Locale_SID_Key__c='Asia/Kolkata',Region__c='Asia Pacific'));
        insert countrySIDList;
        
        Commercial_Avail__c releasePlan21 = new Commercial_Avail__c();
        releasePlan21.Channel__c = 'VODi';
        releasePlan21.Title__c=episodeTitle1.id;
        releasePlan21.Languages__c = Language1.id;
        releasePlan21.Country_Lookup__c = Country_1.id;
        releasePlan21.Format__c = 'HD';
        releasePlan21.Language_Type__c = 'Sub & Audio';
        releasePlan21.Exclusive_Date__c = system.today()-200;
        releasePlan21.Start_Date__c = system.today()-70;
        releasePlan21.End_Date__c = system.today()+70;
        releasePlan21.Rights_End__c=system.today()+200;
        releasePlan21.Status__c = 'Confirmed';
        listReleaseplan_1.add(releasePlan21);
        
        insert listReleaseplan_1;
        
        listClientavails12 = new List<Client_Avail__c>();
        Client_Avail__c seasonClientAvail = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[0], listlocaltitles12[0].Id);
        seasonClientAvail.Start_Date__c = system.today();
        seasonClientAvail.End_Date__c = system.today()+70;
        seasonClientAvail.Status__c = 'Tentative';
        seasonClientAvail.Price_Tier_Text__c = 'test2';
        seasonClientAvail.Episode_Price_Tier__c = 'reprice12';
        seasonClientAvail.Local_Data_Category_Picklist__c = 'TV Catalog';
        seasonClientAvail.Recalculate_Playlist_Avails__c = 'Update Episode Avails';
        seasonClientAvail.Storefront__c = storefrontGoogle1.Id;
        //seasonClientAvail.Recalculate_Playlist_Avails__c = 'Ready To Process';
        listClientavails12.add(seasonClientAvail);
        
        Client_Avail__c episodeclientAvail1 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        episodeclientAvail1.Start_Date__c = system.today()+1;
        episodeclientAvail1.End_Date__c = system.today()+70;
        episodeclientAvail1.Avail_Type__c = 'Automated'; 
        episodeclientAvail1.Local_Data_Category_Picklist__c = 'TV Catalog';
        episodeclientAvail1.Price_Tier_Text__c = 'reprice12';
        episodeclientAvail1.Storefront__c = storefrontGoogle1.Id;
        listClientavails12.add(episodeclientAvail1);
        
        Client_Avail__c episodeclientAvail2 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[2], listlocaltitles12[1].Id);
        
        episodeclientAvail2.Start_Date__c = system.today()-3;
        episodeclientAvail2.End_Date__c = system.today()+70;
        episodeclientAvail2.Avail_Type__c = 'Automated'; 
        episodeclientAvail2.Local_Data_Category_Picklist__c = 'TV New Release';
        episodeclientAvail2.Price_Tier_Text__c = 'reprice12';
        episodeclientAvail2.Storefront__c = storefrontGoogle1.Id;
        listClientavails12.add(episodeclientAvail2);
        
        Client_Avail__c episodeclientAvail3 = TestUtil.initClientAvail(objAccount1.Id, listReleaseplan_1[1], listlocaltitles12[1].Id);
        episodeclientAvail3.Start_Date__c = system.today().addDays(90);
        episodeclientAvail3.End_Date__c = system.today()+100;
        episodeclientAvail3.Avail_Type__c = 'Automated'; 
        episodeclientAvail3.Local_Data_Category_Picklist__c = 'Catalog';
        episodeclientAvail3.Price_Tier_Text__c = 'reprice12';
         episodeclientAvail3.Storefront__c = storefrontGoogle1.Id;
        listClientavails12.add(episodeclientAvail3);
        
        WB_Playlist_Mgmt_Process_Handler classInstance=new WB_Playlist_Mgmt_Process_Handler();
        
        Test.startTest();
        insert listClientavails12;
        system.debug('listClientavails12****'+listClientavails12);
        listClientavails12[1].Parent_Client_Avail__c=listClientavails12[0].Id;
        listClientavails12[2].Parent_Client_Avail__c=listClientavails12[0].Id;
        listClientavails12[3].Parent_Client_Avail__c=listClientavails12[0].Id;
        //listClientavails12[0].Start_Date__c = system.today()-2;
        update listClientavails12;
        system.debug('listClientavails12 1111****'+listClientavails12);
        
        Test.stopTest();
    }
    
    
    @isTest
    public Static Void validateManualPriceCodeTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        String Key = '6000047545'+'TestFrance'+'TestFrench';
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        System.debug(LoggingLevel.INFO,'Local Data Map:'+controller.selectedlocalDataMapWrap);
        
        ApexPages.currentPage().getParameters().put('ID',rpList[0].Id);
        ApexPages.currentPage().getParameters().put('paramValue',rpList[0].Id);
        ApexPages.currentPage().getParameters().put('priceCodekey',Key);
        
        WB_CreateClientAvail_Controller.localDataWrapper ld = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld = controller.selectedlocalDataMapWrap.get(Key);
            ld.newPriceCode = 'Pr1';
            controller.selectedlocalDataMapWrap.put(key,ld);
            
        }
        controller.validateManualPriceCode();
        
        
        WB_CreateClientAvail_Controller.localDataWrapper ld1 = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld1 = controller.selectedlocalDataMapWrap.get(Key);
            ld.newPriceCode = '';
            ld1.error = 'Invalid Price Code';
            controller.selectedlocalDataMapWrap.put(key,ld1);
            
        }
        controller.validateManualPriceCode();
        
        WB_CreateClientAvail_Controller.localDataWrapper ld2 = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld2 = controller.selectedlocalDataMapWrap.get(Key);
            ld2.newPriceCode = 'ABC';
            //ld2.error = 'Invalid Price Code';
            controller.selectedlocalDataMapWrap.put(key,ld2);
            
        }
        controller.validateManualPriceCode();
        
        WB_CreateClientAvail_Controller.localDataWrapper ld3 = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld3 = controller.selectedlocalDataMapWrap.get(Key);
            ld3.newPriceCode = 'Pr1';
            ld3.error = 'Invalid Price Code';
            controller.selectedlocalDataMapWrap.put(key,ld3);
            
        }
        controller.validateManualPriceCode();
        
        
        Test.stopTest();
    }
    
    @isTest
    public Static Void getPriceCodeTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        String Key = '6000047545'+'TestFrance'+'TestFrench';
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        String priceCOde_Value = 'Pr1';
        controller.paramValue = rpList[0].Id;
        controller.priceCodekey = Key;
        ApexPages.currentPage().getParameters().put('priceCOde_Value',priceCOde_Value);
        controller.getPriceCode();
        
        String priceCOde_Value1 = 'ABC';
        controller.paramValue = rpList[1].Id;
        controller.priceCodekey = Key;
        ApexPages.currentPage().getParameters().put('priceCOde_Value',priceCOde_Value1);
        controller.getPriceCode();
        
        ApexPages.currentPage().getParameters().put('pId',price_List[0].Id);
        controller.selectcon();
        controller.cancelPopUp();
    }
    
    @isTest
    public Static Void pricingErrorTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active'
        );
        insert storefrontGoogle1; 
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        ApexPages.currentPage().getParameters().put('key', key);
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw = controller.selectedPricingMapwrap.get(key);
            pw.wsp = '0';
            controller.selectedPricingMapwrap.put(key,pw);
        }
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw1 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw1 = controller.selectedPricingMapwrap.get(key);
            pw1.wsp = 'abc';
            controller.selectedPricingMapwrap.put(key,pw1);
        }
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw2 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw2 = controller.selectedPricingMapwrap.get(key);
            pw2.wsp = '5';
            controller.selectedPricingMapwrap.put(key,pw2);
        }
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw3 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw3 = controller.selectedPricingMapwrap.get(key);
            pw3.wsp = '5';
            pw3.contentType = 'Season';
            controller.selectedPricingMapwrap.put(key,pw3);
        }
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw4 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw4 = controller.selectedPricingMapwrap.get(key);
            pw4.wsp = '5';
            pw4.episodeWSP = '8';
            pw4.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(key,pw4);
        }
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw5 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw5 = controller.selectedPricingMapwrap.get(key);
            pw5.wsp = '';
            //pw5.episodeWSP = '8';
            pw5.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(key,pw5);
        }
        controller.pricingError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw6 = controller.selectedPricingMapwrap.get(key);
            pw6.wsp = '';
            pw6.episodeWSP = '8';
            pw6.contentType = 'Feature';
            
            controller.selectedPricingMapwrap.put(key,pw6);
        }
        controller.pricingError();
    }
    
    @isTest
    public Static Void pricingEpisodeWSPErrorTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active'
        );
        insert storefrontGoogle1; 
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        ApexPages.currentPage().getParameters().put('key', key);
        controller.pricingEpisodeWSPError();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw = controller.selectedPricingMapwrap.get(key);
            pw.episodeWSP = '0';
            controller.selectedPricingMapwrap.put(key,pw);
        }
        controller.pricingEpisodeWSPError(); 
        
        WB_CreateClientAvail_Controller.pricingWrapper pw1 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw1 = controller.selectedPricingMapwrap.get(key);
            pw1.episodeWSP = '';
            pw1.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(key,pw1);
        }
        controller.pricingEpisodeWSPError(); 
        
        WB_CreateClientAvail_Controller.pricingWrapper pw2 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw2 = controller.selectedPricingMapwrap.get(key);
            pw2.wsp = '';
            pw2.episodeWSP = '8';
            pw2.contentType = 'Season';
            pw2.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(key,pw2);
        }
        controller.pricingEpisodeWSPError(); 
        
        WB_CreateClientAvail_Controller.pricingWrapper pw3 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw3 = controller.selectedPricingMapwrap.get(key);
            pw3.wsp = '5';
            pw3.episodeWSP = '8';
            pw3.contentType = 'Season';
            // pw3.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(key,pw3);
        }
        controller.pricingEpisodeWSPError(); 
        
        WB_CreateClientAvail_Controller.pricingWrapper pw4 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw4 = controller.selectedPricingMapwrap.get(key);
            pw4.wsp = '5';
            pw4.episodeWSP = 'ab';
            pw4.contentType = 'Season';
            // pw3.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(key,pw4);
        }
        controller.pricingEpisodeWSPError(); 
    }
    
    @isTest
    public Static Void changeCategoryTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active'
        );
        insert storefrontGoogle1; 
        String Key = title_List[0].Video_Version__c+country_List[0].Name+languageFrench.Name;
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        ApexPages.currentPage().getParameters().put('keyVal', key);
        ApexPages.currentPage().getParameters().put('contentType',title_List[0].Content_Type__c);
        
        WB_CreateClientAvail_Controller.localDataWrapper ld = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld = controller.selectedlocalDataMapWrap.get(Key);
            ld.ca.Local_Data_Category_Picklist__c = 'TV Catalog';
            controller.selectedlocalDataMapWrap.put(key,ld);
            
        }
        controller.changeCategory();
        
        
        ApexPages.currentPage().getParameters().put('keyVal', key);
        ApexPages.currentPage().getParameters().put('contentType',title_List[1].Content_Type__c);
        WB_CreateClientAvail_Controller.localDataWrapper ld1 = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld1 = controller.selectedlocalDataMapWrap.get(Key);
            ld1.ca.Local_Data_Category_Picklist__c = 'Catalog';
            controller.selectedlocalDataMapWrap.put(key,ld1);
            
        }
        controller.changeCategory();
        
        ApexPages.currentPage().getParameters().put('keyVal', key);
        ApexPages.currentPage().getParameters().put('contentType',title_List[0].Content_Type__c);
        WB_CreateClientAvail_Controller.localDataWrapper ld2 = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(Key)){
            ld2 = controller.selectedlocalDataMapWrap.get(Key);
            ld2.ca.Local_Data_Category_Picklist__c = 'Catalog';
            controller.selectedlocalDataMapWrap.put(key,ld2);
            
        }
        controller.changeCategory();
    }
    
    @isTest
    public Static Void bulksaveTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active'
        );
        insert storefrontGoogle1; 
        String ldKey = title_List[0].Video_Version__c+country_List[0].Name+languageFrench.Name;
        String pwKey = rpList[0].Channel__c+rpList[0].Format__c;
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        WB_CreateClientAvail_Controller.localDataWrapper ld = new WB_CreateClientAvail_Controller.localDataWrapper();
        if(controller.selectedlocalDataMapWrap.containsKey(ldKey)){
            ld = controller.selectedlocalDataMapWrap.get(ldKey);
            ld.ca.Local_Data_Category_Picklist__c = 'Catalog';
            ld.error = 'Please enter valid Data.';
            controller.selectedlocalDataMapWrap.put(ldKey,ld);
            
        }
        controller.bulksave();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw2 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(pwKey)){
            pw2 = controller.selectedPricingMapwrap.get(pwKey);
            pw2.wsp = '9';
            pw2.episodeWSP = '8';
            pw2.contentType = 'Season';
            // pw2.errorMsg = 'Please provide Episode WSP for Content Type Season';
            controller.selectedPricingMapwrap.put(pwKey,pw2);
        }
        controller.bulksave();
        
        
    }
    
    @isTest
    public Static Void bulksave_Test(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '5'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=rpList[0].Channel__c, Format__c=rpList[0].Format__c, Status__c ='Active',CRM_Storefront__c = true
        );
        insert storefrontGoogle1; 
        
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = rpList[0].Channel__c;
        rc.Country__c = country_List[0].Id;
        rc.Account__c = acctGoogle.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = title_List[0].Content_Type__c;
        rc.Format__c = rpList[0].Format__c;
        rc.Price_Tier__c = '5';
        rc.Storefront__c = storefrontGoogle1.Id;
        
        insert rc;
        
        String ldKey = title_List[0].Video_Version__c+country_List[0].Name+languageFrench.Name;
        String pwKey = rpList[0].Channel__c+rpList[0].Format__c;
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        if(controller.selectedAccountslistwrap.size() > 0){
            controller.selectedAccountslistwrap[0].selected = true;
        }
        controller.getSelected();
        
        controller.bulksave();
    }
    @isTest
    public Static Void myUnitTestTBDNCRM(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        //insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '5'
                                          );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        //string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=rpList[0].Channel__c, Format__c=rpList[0].Format__c, Status__c ='Active',CRM_Storefront__c = true
        );
        insert storefrontGoogle1; 
        
        String ldKey = title_List[0].Video_Version__c+country_List[0].Name+languageFrench.Name;
        String pwKey = rpList[0].Channel__c+rpList[0].Format__c;
        
        Test.startTest();
        //System.runAs(u){
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', CommIds);
        controller.deleteExceptionedRecords();
        
        if(controller.selectedAccountslistwrap.size() > 0){
            controller.selectedAccountslistwrap[0].selected = true;
        }
        controller.getSelected();
        
        controller.bulksave();
    }
    @isTest
    public Static Void pricingErrorTestRCTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price1);
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010801'
        );
        insert storefrontGoogle1; 
        
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = rpList[0].Channel__c;
        rc.Country__c = country_List[0].Id;
        rc.Account__c = acctGoogle.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = title_List[0].Content_Type__c;
        rc.Format__c = rpList[0].Format__c;
        rc.WSP1__c = 5;
        rc.Storefront__c = storefrontGoogle1.Id;
        rc.Rate_Card_Type__c='WSP';
        
        insert rc;
        
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        
        Test.startTest();
        
        PageReference pageRef = Page.WB_Create_ClientAvail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', CommIds);
        ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        controller.deleteExceptionedRecords();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw6 = controller.selectedPricingMapwrap.get(key);
            pw6.wsp = '5';
            pw6.contentType = 'Feature';
            
            controller.selectedPricingMapwrap.put(key,pw6);
        }
        controller.selectedAccountslistwrap[0].selected = true;
        controller.getSelected();
        controller.validateComponents();
        controller.displayCAMessage();
        PageReference pageR = controller.bulksave();
        controller.bulkcancel();
        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
           // System.Assert(msg.getSummary().contains('The Storefront is not enabled for Warner Bros. Titles.'));
        }
        
        Test.stopTest();
    }
    @isTest
    public Static Void pricingErrorTestRCTestNCRM(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',WS_Price__c=56.56,Price_Tier__c=''
                                          );
        price_List.add(price1);
        
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c = true,SAP_Customer_Number__c='12010801'
        );
        insert storefrontGoogle1; 
        
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        
        Test.startTest();
        
        PageReference pageRef = Page.WB_Create_ClientAvail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', CommIds);
        ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        controller.deleteExceptionedRecords();
        WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw6 = controller.selectedPricingMapwrap.get(key);
            pw6.wsp = '5';
            pw6.contentType = 'Feature';
            
            controller.selectedPricingMapwrap.put(key,pw6);
        }
        controller.selectedAccountslistwrap[0].selected = true;
        controller.getSelected();
        PageReference pageR = controller.bulksave();
        controller.bulkcancel();
        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
        }
        
        
        Test.stopTest();
    }
    @isTest
    public Static Void pricingErrorTestAgree(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',WS_Price__c=56.56,Price_Tier__c=''
                                          );
        price_List.add(price1);
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c = true,SAP_Customer_Number__c='12010801'
        );
        insert storefrontGoogle1; 
        
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        
        Test.startTest();
        
        PageReference pageRef = Page.WB_Create_ClientAvail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', CommIds);
        ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        controller.deleteExceptionedRecords();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw6 = controller.selectedPricingMapwrap.get(key);
            pw6.wsp = '5';
            pw6.contentType = 'Feature';
            
            controller.selectedPricingMapwrap.put(key,pw6);
        }
        controller.selectedAccountslistwrap[0].selected = true;
        controller.getSelected();
        
        PageReference pageR = controller.bulksave();
        controller.bulkcancel();
        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
             //System.Assert(msg.getSummary().contains('The Storefront is not enabled for Warner Bros. Titles.'));
        }
        
        Test.stopTest();
    }
    @isTest
    public Static Void SFelse(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',WS_Price__c=56.56,Price_Tier__c=''
                                          );
        price_List.add(price1);
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Provisional',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c = true
        );
        insert storefrontGoogle1; 
        
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        try {
            Test.startTest();
            
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.updatePriceCode();
            controller.deleteExceptionedRecords();
            
            WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
            if(controller.selectedPricingMapwrap.containsKey(key)){
                pw6 = controller.selectedPricingMapwrap.get(key);
                pw6.wsp = '5';
                pw6.contentType = 'Feature';
                
                controller.selectedPricingMapwrap.put(key,pw6);
            }
            controller.selectedAccountslistwrap[0].selected = true;
            controller.getSelected();
            
            PageReference pageR = controller.bulksave();
            controller.bulkcancel();
            
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
            }
            
            
            Test.stopTest();
        } catch (Exception  e) {
        }
    }  
    @isTest
    public Static Void SFelseUpdate(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',WS_Price__c=56.56,Price_Tier__c=''
                                          );
        price_List.add(price1);
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active'
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[0].Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Expired',CRM_Storefront__c = true
        );
        insert storefrontGoogle1; 
        
        String key =rpList[0].Channel__c+rpList[0].Format__c;
        
        try {
            Test.startTest();
            
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.getCategories();
            controller.updatePriceCode();
            controller.deleteExceptionedRecords();
            
            WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
            if(controller.selectedPricingMapwrap.containsKey(key)){
                pw6 = controller.selectedPricingMapwrap.get(key);
                pw6.wsp = '5';
                pw6.contentType = 'Feature';
                
                controller.selectedPricingMapwrap.put(key,pw6);
            }
            controller.updatePriceCode();
            controller.selectedAccountslistwrap[0].selected = true;
            controller.getSelected();
            
            PageReference pageR = controller.bulksave();
            controller.bulkcancel();
            
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
            }
            
            
            Test.stopTest();
        } catch (Exception  e) {
        }
    }  
    @isTest
    public Static Void PricingSeasonTest(){
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);    
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        country_List.add(countryFrance);
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
                                           Country__c = country_List[0].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',WS_Price__c=56.56,Price_Tier__c=''
                                          );
        price_List.add(price1);
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[1].Content_Type__c,
                                           Country__c = country_List[1].Id,Channel__c ='DTD',Format__c ='HD',Price_Code_Status__c = 'Active',Episode_Price__c=56.90
                                          );
        price_List.add(price2);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[1].Id,Country__c = country_List[1].Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price_List[1].Name);
        insert local1 ;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title_List[1].Id,Country_Lookup__c=country_List[1].Id,Languages__c=languageFrench.Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        rpList.add(releaseplan2);
        insert rpList;
        
        string CommIds = rpList[1].Id;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[1].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[1].Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c = true,SAP_Customer_Number__c='12010801'
        );
        insert storefrontGoogle1; 
        
        String key =rpList[1].Channel__c+rpList[1].Format__c;
        
        
        Test.startTest();
        
        PageReference pageRef = Page.WB_Create_ClientAvail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', CommIds);
        ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        controller.deleteExceptionedRecords();
        
        WB_CreateClientAvail_Controller.pricingWrapper pw6 = new WB_CreateClientAvail_Controller.pricingWrapper();
        if(controller.selectedPricingMapwrap.containsKey(key)){
            pw6 = controller.selectedPricingMapwrap.get(key);
            pw6.wsp = '5';
            pw6.contentType = 'Feature';
            
            controller.selectedPricingMapwrap.put(key,pw6);
        }
        controller.selectedAccountslistwrap[0].selected = true;
        controller.getSelected();
        
        PageReference pageR = controller.bulksave();
        controller.bulkcancel();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.Assert(msg.getSummary().contains(System.Label.Create_Client_Avail_No_storefront));
        }
        Test.stopTest();
    }
     @isTest
   public Static Void testgetNextPrice(){


    Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
    Account acctGoogle = new Account(Name='TestAccount',Customer_Focus__c='Active', recordtypeId = rtypeId);
    insert acctGoogle;
    
    MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
    insert mpm;
    
    
    Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='555555',Content_Type__c='Feature',Digital_Planning__c='YES',Formats__c='HD',Clear_to_Avail__c = true);
    insert  title1;
    
    list<Country__c> countryList = new list<Country__c>();
    Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='T11',Country_Code__c='T98');
    countryList.add(countryFrance);
    insert countryList;
    
    Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
    insert languageFrench;
    
    Pricing__c newPrice = new Pricing__c();
    newPrice.Content_Type__c = 'Feature';
    newPrice.Account__c = acctGoogle.Id;
    newPrice.Country__c = countryFrance.Id;
    newPrice.Channel__c = 'EST';
    newPrice.Format__c = 'HD';
    newPrice.WS_Price__c = 120.00;
    insert newPrice;
    
    list<Local_Title__c> localTitleList = new list<Local_Title__c>();
    
    Local_Title__c localtitle = new Local_Title__c(Name='test Local Title',Title__c = title1.Id, Country__c = countryFrance.Id, Language__c = languageFrench.Id );
    localTitleList.add(localtitle);
    insert localTitleList;  
    localtitle.Price_Code__c='newPrice';
    
    Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                            Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                                                            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
    
    test.startTest();
    insert releaseplan1;
    
    Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                    Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
    insert storefrontGoogle1;
    
    Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                      
                                                  Client__c=acctGoogle.Id,                                                      
                                                  Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=date.today()+1 );
                                                  
    insert clientAvail1;
    
    
    List<Client_Avail_Price__c> ListCap=new List<Client_Avail_Price__c>();
    
    Client_Avail_Price__c objCAP = [select id,Client_Avail__c,Expiry_Date__c,Effective_Date__c from Client_Avail_Price__c where Client_Avail__c =: clientAvail1.id];
    ListCap.add(objCAP);
   
    WB_PriceUtility.getNextPrice(objCAP,ListCAP);
     test.stopTest();
}



@isTest
public static void testgetCurrentPrice(){

    MPM__c Mpm = new MPM__c();
    Mpm.Name = '2063646';
    Mpm.MPM_Number__c = '2063646';
    Mpm.Film_Color__c = 'Color';
    insert Mpm;
    
    Account objAccount = TestUtil.createAccount('Apple iTunes');
    objAccount.Customer_Focus__c = 'Active';
    objAccount.Type='Global';
    insert objAccount;
    
    Title__c title = TestUtil.initTitle('Harry Potter and the Goblet of Fire','1243355672');
    title.MPM__c = Mpm.Id;
    insert title;
    
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
    
    List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
    Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
    listAvailLang.add(availLangTitle1);
    
    Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
    listAvailLang.add(availLangTitle2);
    
    insert listAvailLang;
    
    Pricing__c pricing1 = new Pricing__c();
    pricing1.Name = 'CheckPriceCode1';
    pricing1.Account__c = objAccount.id;
    pricing1.Country__c = Country.id;
    pricing1.Channel__c='EST';
    pricing1.Content_Type__c='Feature';       
    pricing1.Price_Tier__c ='reprice1';
    pricing1.Format__c='SD';
    lPricing.add(pricing1);
    
    
    insert lPricing;
    
    listlocaltitles = new List<Local_Title__c>();
    
    Local_Title__c LT = new Local_Title__c();
    LT.Name = title.Name;
    LT.Title__c = title.Id;
    LT.Country__c = Country.Id;
    LT.Language__c = Language.Id;
    LT.Price_Code__c = 'CheckPriceCode1';
    listlocaltitles.add(LT);
    insert listlocaltitles;
    
    List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
    Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
    releasePlan1.Channel__c = 'EST';
    releasePlan1.Local_Title__c = listlocaltitles[0].id;
    releasePlan1.Title__c=title.id;
    releasePlan1.Languages__c = Language.id;
    releasePlan1.Country_Lookup__c = Country.id;
    releasePlan1.Format__c = 'SD';
    releasePlan1.Language_Type__c = 'Sub & Audio';
    releasePlan1.Exclusive_Date__c = date.today()-200;
    releasePlan1.Start_Date__c = date.today()-2;
    releasePlan1.End_Date__c = date.today()+5;
    releasePlan1.Rights_End__c=date.today()+300;
    releasePlan1.Status__c = 'Confirmed';
    listReleaseplan.add(releasePlan1);
    
    
    
    test.startTest();
    insert listReleaseplan;
    
    Agreement__c sf = TestUtil.initStoreFront(objAccount.Id, country.Id, listReleaseplan[0], title);
    insert sf;
    sf.APO__c = 'Yes';
    
    update sf;
    
    
    WB_Pricing_Settings__c pricingFlag = new WB_Pricing_Settings__c();
    pricingFlag.Name = 'Publish to Client';
    pricingFlag.IsPublishToClient__c = True;
    insert pricingFlag;
    
    listClientavails = new List<Client_Avail__c>();
    Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
    clientAvail.Local_Title__c = listlocaltitles[0].id;
    clientAvail.Status__c = 'Confirmed';
    clientAvail.Storefront__c = sf.Id;
    clientAvail.Local_Data_Category_Picklist__c = 'Theatrical New Release';
    listClientavails.add(clientAvail);
    
    insert listClientavails;
    
     List<Client_Avail_Price__c> ListCAP =new List<Client_Avail_Price__c>();
     Client_Avail_Price__c objCAP = [select id,Client_Avail__c,Expiry_Date__c,Effective_Date__c from Client_Avail_Price__c where Client_Avail__c =: listClientavails[0].id];
     ListCAP.add(objCAP);
    Map<String,Integer> countryOffsetMap = new Map<String,Integer>();
    Country_SID_Key__c createRPC = new Country_SID_Key__c();
    createRPC.Name = 'INDIA';
    createRPC.Country_Code__c = 'IND';
    createRPC.Region__c = 'Asia Pacific';
    createRPC.Locale_SID_Key__c = 'Asia/Kolkata';
    createRPC.Country_Code2_c__c = 'IN';
    createRPC.isPublishToClient__c = True;
    insert createRPC;
    Integer minutes = 2;
    countryOffsetMap.put(createRPC.Country_Code__c,minutes);
    DateTime currentTime = System.now();
    Commercial_Avail__c objCA =[select id,Country_Code__c from Commercial_Avail__c where id =:releaseplan1.id];
    System.debug('objCA'+objCA);
    WB_PriceUtility.getCurrentPrice(ListCAP,objCA.Country_Code__c,countryOffsetMap,currentTime);
    test.stopTest();
}

@isTest
    static void myUnitTest_SfTest() {
        
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        insert countryJapan;
        
        List<Language__c> langList = new List<Language__c>();
        Language__c languageFrench = new Language__c(Name='French',Language_Order__c = 1,Language_Code_2__c='fr');
        langList.add(languageFrench);
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        langList.add(languageEnglish);
        
        insert langList;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=langList[0].Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=langList[0].Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        
        Available_Languages__c availLangTitle3= new Available_Languages__c(Language__c=langList[1].Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=langList[1].Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        insert listAvailLang;
        
        List<Language_Preference__c> langPrefList = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Country',Language__c=langList[0].Id,Level__c='1');
        langPrefList.add(langPrefTest);
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Country',Language__c=langList[1].Id,Level__c='0');
        langPrefList.add(langPrefTest1);
        
        insert langPrefList;
        //Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        //langPrefList.add(langPrefTest2);

        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =langList[0].Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=langList[0].Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=langList[0].Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        List<Language_Preference__c> langPrefListTypeSF = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Storefront',Language__c=langList[0].Id,Level__c='1',Account__c = acctGoogle.Id,Storefront__c=storefrontGoogle1.Id);
        langPrefListTypeSF.add(langPrefTest3);
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Storefront',Language__c=langList[1].Id,Level__c='0',Account__c = acctGoogle.Id,Storefront__c=storefrontGoogle1.Id);
        langPrefListTypeSF.add(langPrefTest2);
        
        insert langPrefListTypeSF;

        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c = date.today()+3,End_Date__c=releaseplan1.End_Date__c
            
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        Test.startTest();
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
            //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            //WB_CreateClientAvail_Controller.accountwrapper accwrap = new WB_CreateClientAvail_Controller.accountwrapper();
            controller.selectedAccountslistwrap[0].selected = true;
            controller.getSelected();
            PageReference pageR = controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            
            // get the list of ApexPages.Message
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.Assert(msg.getSummary().contains('Higher Priority Language available on Title for Account'));
            }
            
        }
        //delete clientAvailList; 
        Test.stopTest();
        
        
        
    }

    @isTest
    static void myUnitTest_noSfTest() {
        
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        insert countryJapan;
        
        List<Language__c> langList = new List<Language__c>();
        Language__c languageFrench = new Language__c(Name='French',Language_Order__c = 1,Language_Code_2__c='fr');
        langList.add(languageFrench);
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        langList.add(languageEnglish);
        
        Language__c languageSpanish = new Language__c(Name='Spanish',Language_Order__c = 1,Language_Code_2__c='sp');
        langList.add(languageSpanish);
        
        insert langList;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=langList[0].Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=langList[0].Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        
        Available_Languages__c availLangTitle3= new Available_Languages__c(Language__c=langList[1].Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=langList[1].Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        insert listAvailLang;
        
        List<Language_Preference__c> langPrefList = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Country',Language__c=langList[0].Id,Level__c='1');
        langPrefList.add(langPrefTest);
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Country',Language__c=langList[1].Id,Level__c='0');
        langPrefList.add(langPrefTest1);
        
        
        
        insert langPrefList;
        //Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        //langPrefList.add(langPrefTest2);

        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
                                          );
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =langList[0].Id,Price_Code__c =price1.Name);
        insert local1 ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=langList[0].Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryJapan.Id,Languages__c=langList[0].Id,
            Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan2;
        
        string CommIds = releaseplan1.Id +','+releaseplan2.Id ;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        List<Language_Preference__c> langPrefListTypeSF = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Storefront',Language__c=langList[2].Id,Level__c='1',Account__c = acctGoogle.Id,Storefront__c=storefrontGoogle1.Id);
        langPrefListTypeSF.add(langPrefTest3);
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=countryFrance.Id,Type__c = 'Storefront',Language__c=langList[1].Id,Level__c='0',Account__c = acctGoogle.Id,Storefront__c=storefrontGoogle1.Id);
        langPrefListTypeSF.add(langPrefTest2);
        
        insert langPrefListTypeSF;

        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c = date.today()+3,End_Date__c=releaseplan1.End_Date__c
            
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        //insert clientAvailList;
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
            timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
        );
        insert u;
        Id uid = u.Id;
        
        Test.startTest();
        System.runAs(u){
            PageReference pageRef = Page.WB_Create_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', CommIds);
            ApexPages.currentPage().getParameters().put('UNIQUEID', CommIds);
            //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
            controller.deleteExceptionedRecords();
            //WB_CreateClientAvail_Controller.accountwrapper accwrap = new WB_CreateClientAvail_Controller.accountwrapper();
            controller.selectedAccountslistwrap[0].selected = true;
            controller.getSelected();
            PageReference pageR = controller.bulksave();
            controller.batchIdForApexBatch();
            controller.bulkcancel();
            
            // get the list of ApexPages.Message
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.Assert(msg.getSummary().contains('not present on Storefront Language Preferences for Account'));
            }
            
        }
        //delete clientAvailList; 
        Test.stopTest();
        
        
        
    }
}