public class WB_LocalTitleImage_Webservice_controller{
    public id Localtitle_Id;
    public Local_Title__c obj;
    public Static String ImageSize='S';
    public String countryCode='' ;
    public String languageCode='' ;
    public String video_version='';
    public string SourceIP='';
    public string TitleImage1{get;set;}
    public string Image_URL;
    public boolean imageRender{get;set;}
    Public Integer Status_code;

    public WB_LocalTitleImage_Webservice_controller (ApexPages.StandardController controller) {
    
    obj= (Local_Title__c) controller.getRecord();   
    system.debug('object list'+obj);
    imageRender=true;
    }
  
    public void WB_Image_Webservice_response(){
        
        Localtitle_Id =obj.Id;   
        Local_Title__c titleImage= [select CountryCodeForImage__c,LanguageCodeForImage__c,Title_VV_F__c from Local_Title__c where id=:Localtitle_Id ];
		
		//List<Local_Data_Image__c> lstImage= [select Id, Image_Size__c, URL_LastUpdate__c from Local_Data_Image__c where Local_Data__c=:Localtitle_Id];

        Id LoggedInUser= Userinfo.getUserId();
        List<loginhistory> loghistory=[SELECT Id,LoginTime,LoginType,SourceIp,UserId FROM LoginHistory 
                                    WHERE UserId =:LoggedInUser  order by loginTime desc limit 1];     

        /*if(lstImage != NULL && lstImage.size()>0){
            //if(lstImage[0].Image_Size__c != null){
                //ImageSize=lstImage[0].Image_Size__c;
                ImageSize='L';
            }
            else {
                ImageSize='L';
            }
        }*/
       if(loghistory != NULL && loghistory.size()> 0 )
            SourceIP= loghistory[0].SourceIp;
        languageCode= titleImage.LanguageCodeForImage__c.toUpperCase();
        countryCode=titleImage.CountryCodeForImage__c.toUpperCase();
        video_version=titleImage.Title_VV_F__c;
        //Get EndPoint details from custom setting
        WB2B_Details__c WB2B_Record = WB2B_Details__c.getValues('WB2B'); 
        if(WB2B_Record != NULL){
        // Webservice call
            try{
            HttpRequest request = new HttpRequest();
            String endpoint = WB2B_Record.Request_Url__c;
            endpoint += 'videoVersionNumber='+video_version+'&ipAddress='+SourceIP+'&imageSize='+ImageSize+'&countryCode='+countryCode+'&languageCode='+languageCode;
            request.setEndPoint(endpoint);
            request.setHeader('client-id', WB2B_Record.clientId__c);
            request.setHeader('client-secret', WB2B_Record.client_secret__c); 
            request.setMethod('GET');
            system.debug('Request Url::'+request);
            HttpResponse response = new HTTP().send(request);
            system.debug('Response Url::'+response.getBody()); 
            if(response.getBody() != NULL)
                Image_URL = response.getBody();
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