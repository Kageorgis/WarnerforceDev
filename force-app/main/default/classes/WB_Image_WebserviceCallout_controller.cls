public class WB_Image_WebserviceCallout_controller {
    public id Title_Id;
    public title__c obj;
    public String ImageSize='S';
    public String video_version='';
    public string SourceIP='';
    public string TitleImage1{get;set;}
    public string Image_URL;
    public boolean imageRender{get;set;}
    Public Integer Status_code;

    public WB_Image_WebserviceCallout_controller(ApexPages.StandardController controller) {
        obj= (title__c) controller.getRecord();
        imageRender=true;
    }
  
    public void WB_Image_Webservice_response(){
        Title_Id=obj.Id;
        // removed country_code__c and Language_code__c on 19th Nov2014   
        title__c titleImage= [select Video_Version__c from title__c where id=:Title_Id];
        //List<image__c> lstImage= [select Id, Image_Size__c, URL_LastUpdate__c from Image__c where Title__c=:Title_Id];        
        Id LoggedInUser= Userinfo.getUserId();
        List<loginhistory> loghistory=[SELECT Id,LoginTime,LoginType,SourceIp,UserId 
                                       FROM LoginHistory WHERE UserId =:LoggedInUser 
                                       order by loginTime desc limit 1];    
        
        /*if(lstImage != NULL && lstImage.size()>0){
            if(lstImage[0].Image_Size__c != NULL){
                //ImageSize=lstImage[0].Image_Size__c;    
                ImageSize = 'L';
            }
            else
                ImageSize = 'L';
        }*/
        //ImageSize='L';
        if(loghistory != NULL && loghistory.size()> 0 )
            SourceIP= loghistory[0].SourceIp;
        video_version=titleImage.Video_Version__c;
        WB2B_Details__c WB2B_Record = WB2B_Details__c.getValues('WB2B');
        
        if(WB2B_Record != NULL) {
            // Webservice call
            try{
                HttpRequest request = new HttpRequest();
                // Set the endpoint URL.
                String endpoint = WB2B_Record.Request_Url__c;
                endpoint += 'videoVersionNumber='+video_version+'&ipAddress='+SourceIP+'&imageSize='+ImageSize;
                request.setEndPoint(endpoint);
                request.setHeader('client-id', WB2B_Record.clientId__c);
                request.setHeader('client-secret', WB2B_Record.client_secret__c);
                request.setMethod('GET');
                system.debug('Request Url::'+request);
                HttpResponse response = new HTTP().send(request);
                system.debug('Response Url::'+response.getBody()); 
                if(Response.getBody() != NULL)
                    Image_URL = Response.getBody();
                Status_code =response.getStatusCode();
                if(Status_code == 200){  
                    titleImage1 = Image_URL;
                }
                else{
                    ApexPages.Message error_mssg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Image Not Available' );
                    ApexPages.addMessage(error_mssg); 
                    imageRender=false;
                }
              }
              catch(Exception e){
                system.debug('something went wrong while image is updated'+e);
                ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Please refresh the page ' );
                ApexPages.addMessage(myMsg); 
                imageRender=false;
             }
        }
    }
}