@isTest
private class WB_LocalTitleImage_Webservice_ctrl_Test {

    private static testMethod void testmethod1() {
        
        WB2B_Details__c custSetting = new WB2B_Details__c();
        custSetting.name = 'WB2B';
        custSetting.clientId__c = 'SALES_FORCE';
        custSetting.client_secret__c = '&Er8BrayUDE7UwR54rerewrE2uphES=7';
        custSetting.Request_Url__c ='https://api.wb2b.com/services/rest/v1/dAssetURL?';
        insert custSetting;
                                 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',
                First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='SD'
        );//Formats__c='HD',
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        Language__c Language = new Language__c (Name='TestLanguage2', Language_Order__c = 1,Language_Code_2__c='TL1');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1,Language_Code_2__c='TL2');
        insert Language1;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        
        Commercial_Avail__c commTest = new Commercial_Avail__c(
            Title__c = title1.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+190, start_Date__c = system.today()+10,
            Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2)
        );
        insert commTest;
        Local_Title__c localTitle = [Select id from Local_Title__c limit 1];
        update localTitle;
        // Local_Data_Image__c localImage = new Local_Data_Image__c(Local_Data__c=localTitle.id,Image_Size__c='2kb',URL_LastUpdate__c=system.today());
        //insert localImage;
        ApexPages.StandardController controller = new ApexPages.StandardController([Select id from Local_Title__c limit 1]);
        WB_LocalTitleImage_Webservice_controller ctrl = new WB_LocalTitleImage_Webservice_controller(controller);
       test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Success());
            ctrl.WB_Image_Webservice_response();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Failure());
            ctrl.WB_Image_Webservice_response();
        test.stopTest();
    }
    
    //Mock Response Methods
     public class MockHttpResponse_Success implements HttpCalloutMock {
   // Implement this interface method
    public  HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('https://wbads.hs.llnwd.net/v1/m/s/MarsReplatform/Prod/WHVGraphic/2BrokeGirlsTheCompleteSecondSeason/900/2BrokeGirls_S2_VODEST_KeyartPrint_2000x2841_US_89557f4b.JPEG?ip=168.161.192.15/24&e=1526124221&h=ce75af3aae3ca25a72eb8bc18399dba2');
        res.setStatusCode(200);
        return res;
    }
    }
    public class MockHttpResponse_Failure implements HttpCalloutMock {
   // Implement this interface method
    public  HTTPResponse respond(HTTPRequest req) {
       // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('https://wbads.hs.llnwd.net/v1/m/s/MarsReplatform/Prod/WHVGraphic/2BrokeGirlsTheCompleteSecondSeason/900/2BrokeGirls_S2_VODEST_KeyartPrint_2000x2841_US_89557f4b.JPEG?ip=168.161.192.15/24&e=1526124221&h=ce75af3aae3ca25a72eb8bc18399dba2');
        res.setStatusCode(201);
        return res;
    }
  }
}