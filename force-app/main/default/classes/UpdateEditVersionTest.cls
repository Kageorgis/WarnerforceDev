@isTest
public class UpdateEditVersionTest
{
    @isTest
        //Test criteria: With UV Publish date and Territory List
    static void UpdateEditVersionTest_with_territory()
    {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('USA', 'US', 'USA');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('English', 'en',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;

        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'en_US', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'en_US';
        objLPD.UV_Published_Date = String.valueOf(system.today()) ;
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'USA';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        
        /*UpdateEditVersion.LocalTitleDetails objinLTD = new UpdateEditVersion.LocalTitleDetails();
        objinLTD.IntegrationID = '7000000006';
        objinLTD.Video_Version = '7000000006';
        objinLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objinLTD.Status = 'Inactive';
        objinLTD.LocalePublishDateList = lpdList;
        objinLTD.TerritoryList = TerritoryList;*/
       
        
         LocalTitleDetailsList.add(objLTD);
       // LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        system.assertEquals(objLPD.UV_Published_Date,String.valueOf(system.today()));
        system.debug('responseList ==: ' + responseList);
        system.debug('Local Data updated is -----'+objLocalTitle.UV_Published_Date__c);
        system.debug('Local Data updated is -----'+objLocalTitle.Territory_Specific__c);
        
        Test.stopTest();
    }
    
    @isTest
        //Test Criteria: With Publish date and no Territory
    static void UpdateEditVersionTest_without_territory()
    {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('USA', 'US', 'USA');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('English', 'en',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;

        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'en_US', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'en_US';
        objLPD.UV_Published_Date = '07/28/2015';
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'USA';
        
        //TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        system.debug('Territory List1 ====='+TerritoryList+'-----'+objLTD.TerritoryList);
        objLTD.TerritoryList = TerritoryList;
        
        UpdateEditVersion.LocalTitleDetails objinLTD = new UpdateEditVersion.LocalTitleDetails();
        objinLTD.IntegrationID = '7000000006';
        objinLTD.Video_Version = '7000000006';
        objinLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objinLTD.Status = 'Inactive';
        objinLTD.LocalePublishDateList = lpdList;
        objinLTD.TerritoryList = TerritoryList;
        system.debug('Territory List2 ====='+TerritoryList+'-----'+objinLTD.TerritoryList);
        
        LocalTitleDetailsList.add(objLTD);
        LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.debug('responseList ==: ' + responseList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        
        Test.stopTest();
    }
    
    @isTest
    //Test Criteria: With Territory List and no Publish Date
    static void UpdateEditVersionTest_without_PublishedDate()
    {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('USA', 'US', 'USA');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('English', 'en',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;

        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'en_US', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'en_US';
        objLPD.UV_Published_Date = '07/28/2015';
        
        //lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'USA';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        UpdateEditVersion.LocalTitleDetails objinLTD = new UpdateEditVersion.LocalTitleDetails();
        objinLTD.IntegrationID = '7000000006';
        objinLTD.Video_Version = '7000000006';
        objinLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objinLTD.Status = 'Inactive';
        objinLTD.LocalePublishDateList = lpdList;
        objinLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.debug('responseList ==: ' + responseList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        
        Test.stopTest();
    }
    
    @isTest
    //Test Criteria: without Video Version
    static void UpdateEditVersionTest_withoutVideoVersion() {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('USA', 'US', 'USA');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('English', 'en',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;

        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'en_US', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'en_US';
        objLPD.UV_Published_Date = '07/28/2015';
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'USA';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        //objLTD.Video_Version = '7000000006';  Removed VV to test missing video version test case
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        
        UpdateEditVersion.LocalTitleDetails objinLTD = new UpdateEditVersion.LocalTitleDetails();
        objinLTD.IntegrationID = '7000000006';
        objinLTD.Video_Version = '7000000006';
        objinLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objinLTD.Status = 'Inactive';
        objinLTD.LocalePublishDateList = lpdList;
        objinLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.debug('responseList ==: ' + responseList);
        
        system.assertEquals(responseList[0].Message_Result, false);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        
        Test.stopTest();
    }
    
    @isTest
    
    //Test Criteria: without territory and UV Publish date
    static void UpdateEditVersionTest_withoutTerritoryUVPublishDate() {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('USA', 'US', 'USA');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('English', 'en',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;

        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'en_US', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'en_US';
        objLPD.UV_Published_Date = '07/28/2015';
        
        //lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'USA';
        
        //TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        
        UpdateEditVersion.LocalTitleDetails objinLTD = new UpdateEditVersion.LocalTitleDetails();
        objinLTD.IntegrationID = '7000000006';
        objinLTD.Video_Version = '7000000006';
        objinLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objinLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objinLTD.Status = 'Inactive';
        objinLTD.LocalePublishDateList = lpdList;
        objinLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.debug('responseList ==: ' + responseList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        
        Test.stopTest();
    }
   
    @isTest
    //ER-553
    static void UpdateEditVersionTest_with_territory2()
    {
        Test.startTest();
        
        Locale_Map__c testLocale = new Locale_Map__c();
        testLocale.Name = 'en_IL';
        testLocale.Country_Code__c = 'IL';
        testLocale.Language_Code__c = 'en';
        insert testLocale;
        
        Country__c countryUSA = TestUtil.createCountry('Ireland', 'IL', 'IRL');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('English', 'en',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;
        
        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'en_IL', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'en_IL';
        objLPD.UV_Published_Date = String.valueOf(system.today()) ;
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'Ireland';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        // LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        system.assertEquals(objLPD.UV_Published_Date,String.valueOf(system.today()));
        system.debug('responseList ==: ' + responseList);
        system.debug('Local Data updated is -----'+objLocalTitle.UV_Published_Date__c);
        system.debug('Local Data updated is -----'+objLocalTitle.Territory_Specific__c);
        
        Test.stopTest();
    }
    
    @isTest
    //ER-553
    static void UpdateEditVersionTest_with_territory3()
    {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('Canada', 'CA', 'CAN');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('French', 'fr',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;
        
        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'fr_CA', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'fr_CA';
        objLPD.UV_Published_Date = String.valueOf(system.today()) ;
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'Canada';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        // LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        system.assertEquals(objLPD.UV_Published_Date,String.valueOf(system.today()));
        system.debug('responseList ==: ' + responseList);
        system.debug('Local Data updated is -----'+objLocalTitle.UV_Published_Date__c);
        system.debug('Local Data updated is -----'+objLocalTitle.Territory_Specific__c);
        
        Test.stopTest();
    }
    
     @isTest
    //ER-553
    static void UpdateEditVersionTest_with_territory4()
    {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('Brazil', 'BR', 'BRZ');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('Portuguse', 'pt',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;
        
        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'pt_BR', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'pt_BR';
        objLPD.UV_Published_Date = String.valueOf(system.today()) ;
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'Brazil';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        // LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        system.assertEquals(objLPD.UV_Published_Date,String.valueOf(system.today()));
        system.debug('responseList ==: ' + responseList);
        system.debug('Local Data updated is -----'+objLocalTitle.UV_Published_Date__c);
        system.debug('Local Data updated is -----'+objLocalTitle.Territory_Specific__c);
        
        Test.stopTest();
    }
    
    @isTest
    //ER-553
    static void UpdateEditVersionTest_with_territory5()
    {
        Test.startTest();
        
        Country__c countryUSA = TestUtil.createCountry('Spain', 'ES', 'SPN');
        insert countryUSA;
        
        Language__c languageEnglish = TestUtil.createLanguage('Spanish', 'ce',1);
        insert languageEnglish;
        
        Title__c objTitle = TestUtil.createTitle('Test Title', '7000000006');
        insert objTitle;
        
        Local_Title__c objLocalTitle = TestUtil.createLocalData('7000000006', countryUSA, languageEnglish, 'ce_ES', objTitle.Id);
        insert objLocalTitle;
        
        list<UpdateEditVersion.LocalTitleDetails> LocalTitleDetailsList = new list<UpdateEditVersion.LocalTitleDetails>();
        list<UpdateEditVersion.LocalePublishDate> lpdList = new list<UpdateEditVersion.LocalePublishDate>();
        list<UpdateEditVersion.Territory> TerritoryList = new list<UpdateEditVersion.Territory>();
        
        UpdateEditVersion.LocalePublishDate objLPD = new UpdateEditVersion.LocalePublishDate();
        objLPD.Locale = 'ce_ES';
        objLPD.UV_Published_Date = String.valueOf(system.today()) ;
        
        lpdList.add(objLPD);
        
        UpdateEditVersion.Territory objTerritory = new UpdateEditVersion.Territory();
        objTerritory.Territory = 'Spain';
        
        TerritoryList.add(objTerritory);
        
        UpdateEditVersion.LocalTitleDetails objLTD = new UpdateEditVersion.LocalTitleDetails();
        objLTD.IntegrationID = '7000000006';
        objLTD.Video_Version = '7000000006';
        objLTD.ALID = 'urn:dece:alid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.CID = 'urn:dece:cid:eidr-s:81FC-F664-E388-B4D7-D3BF-T';
        objLTD.Version_EIDR = '11.1111/1111-K111-KK1K-KK1K-1K11-K';
        objLTD.Status = 'Active';
        objLTD.LocalePublishDateList = lpdList;
        objLTD.TerritoryList = TerritoryList;
        
        LocalTitleDetailsList.add(objLTD);
        // LocalTitleDetailsList.add(objinLTD);
        
        List<UpdateEditVersion.ResponseMessage> responseList = UpdateEditVersion.updateEditVersion(LocalTitleDetailsList);
        
        system.assertEquals(responseList[0].Message_Result, true);
        system.assertEquals(responseList[0].Video_Version, objLTD.Video_Version);
        system.assertEquals(responseList[0].IntegrationID, objLTD.IntegrationID);
        system.assertEquals(objLPD.UV_Published_Date,String.valueOf(system.today()));
        system.debug('responseList ==: ' + responseList);
        system.debug('Local Data updated is -----'+objLocalTitle.UV_Published_Date__c);
        system.debug('Local Data updated is -----'+objLocalTitle.Territory_Specific__c);
        
        Test.stopTest();
    }

    
}