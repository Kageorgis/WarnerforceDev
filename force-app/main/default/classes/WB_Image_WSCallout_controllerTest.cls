@IsTest

private with sharing class WB_Image_WSCallout_controllerTest
{
    
    private static testMethod void coverTypes()
    {
        WB2B_Details__c custSetting = new WB2B_Details__c();
        custSetting.name = 'WB2B';
        custSetting.clientId__c = 'SALES_FORCE';
        custSetting.client_secret__c = '&Er8BrayUDE7UwR54rerewrE2uphES=7';
        custSetting.Request_Url__c ='https://api.wb2b.com/services/rest/v1/dAssetURL?';
        insert custSetting;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature');
        List<Title__c > titleList= new List<Title__c >();       
        titleList.add(title1) ;
        insert titleList;        
                       
        /*Image__c image1 = new Image__c( Title__c=titleList[0].Id, Image_Size__c='L');
        //List<Image__c > imageList= new List<Image__c >();        
        //imageList.add(image1);        
        insert imageList;*/
        
        Id LoggedInUser= Userinfo.getUserId();
        
        system.currentPageReference().getParameters().put('Id', title1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(title1);
        WB_Image_WebserviceCallout_controller wsController = new WB_Image_WebserviceCallout_controller(sc);
       
        // Set mock callout class
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Success());
            wsController.WB_Image_Webservice_response();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Failure());
            wsController.WB_Image_Webservice_response();
        test.stopTest();
     }
    
   
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
        res.setStatusCode(404);
        return res;
    }
  }
    
    
  

}