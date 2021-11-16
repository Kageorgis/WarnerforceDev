public class WB_tabImage_WebserviceController {
    public String imageURL{get;set;}
    public Boolean imageRenderBln{get;set;}
    public Integer Status_code;
    public ID recordIDFromURL;
    public String reqstEndPoint;   
   // public sObject selectedObject;
    public Set<string>stObjectFields;
    public Static String ImageSize='L'; 
    public map<String,String> mapIDtosObjectName;
    public String countryCode='' ;
    public String languageCode='' ;
    public String video_version='';
    public string SourceIP=''; 
    
    
    public WB_tabImage_WebserviceController()
    {
        
        stObjectFields = new Set<String>();          
        mapIDtosObjectName = new Map<String,String>();
        recordIDFromURL = ApexPages.currentPage().getParameters().get('id');
        imageRenderBln = TRUE;
        
    }
    public void WB_Image_WebserviceResponse()
    {
        
        Id LoggedInUser= Userinfo.getUserId();
        List<loginhistory> loghistory=[SELECT Id,LoginTime,LoginType,SourceIp,UserId FROM LoginHistory 
                                    WHERE UserId =:LoggedInUser  order by loginTime desc limit 1];     
        
         if(loghistory != NULL && loghistory.size()> 0)
       SourceIP= loghistory[0].SourceIp;
        IF(recordIDFromURL == null) 
        {
            ApexPages.Message error_mssg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Something went wrong ..  Please Append Record ID to see Image by appending &ID=<--your salesforce id-->' );
           ApexPages.addMessage(error_mssg); 
            
        }
        String strObjectName = getObjectNamebyPassingID(recordIDFromURL);
        IF(strObjectName == 'Local_Title__c')
        {
            stObjectFields.add('LanguageCodeForImage__c');
            stObjectFields.add('CountryCodeForImage__c');
            stObjectFields.add('Title_VV_F__c');
            Local_Title__c objLocalTitle = (Local_Title__c) getQueriedDynamicSObject('Local_Title__c',stObjectFields,recordIDFromURL);
           languageCode= (String)objLocalTitle.LanguageCodeForImage__c;
           countryCode=(String)objLocalTitle.CountryCodeForImage__c;
          video_version=(String)objLocalTitle.Title_VV_F__c;
          reqstEndPoint =  'videoVersionNumber='+video_version+'&ipAddress='+SourceIP+'&imageSize='+ImageSize+'&countryCode='+countryCode.toUpperCase()+'&languageCode='+languageCode.toUpperCase();
  
        }else IF(strObjectName == 'Title__c')
        {
            stObjectFields.add('Video_Version__c');
            Title__c objTitle =(Title__c)getQueriedDynamicSObject('Title__c',stObjectFields,recordIDFromURL);
            video_version=(String)objTitle.Video_Version__c;
            reqstEndPoint = 'videoVersionNumber='+video_version+'&ipAddress='+SourceIP+'&imageSize='+ImageSize;
            
        }
        /*--Add other Object Code Here*/
        
        if(reqstEndPoint != null)
        {
            String strResponseBody =  WB2B_Details_RunCallouts(reqstEndPoint);
    		if(strResponseBody != NULL)
               imageURL = strResponseBody;
            
        }
          
    		
    
    }
    
    public String WB2B_Details_RunCallouts(String endpointAppendString)
    {
        try{
		//Get EndPoint details from custom setting
        WB2B_Details__c WB2B_Record = WB2B_Details__c.getValues('WB2B'); 
        if(WB2B_Record != NULL){
        
            HttpRequest request = new HttpRequest();
            String endpoint = WB2B_Record.Request_Url__c;
            endpoint += endpointAppendString;
            request.setEndPoint(endpoint);
            request.setHeader('client-id', WB2B_Record.clientId__c);
            request.setHeader('client-secret', WB2B_Record.client_secret__c); 
            request.setMethod('GET');
          //  system.debug('Request Url::'+request);
            HttpResponse response = new HTTP().send(request);
         //   system.debug('Response Url::'+response.getBody()); 
           	String responseBody= response.getBody();
            Status_code =response.getStatusCode();
            if(Status_code == 200){   
                return responseBody;
                 
            }
           else{
                    ApexPages.Message error_mssg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Image Not Available' );
                    ApexPages.addMessage(error_mssg); 
                    imageRenderBln=false;
              		return null;
                }
              }
            return null;
             
            }
         catch(Exception e){
                    system.debug('something went wrong while image is updated'+e);
                    ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Please refresh the page and if problem still persist please contact to WB support' );
                    ApexPages.addMessage(myMsg); 
                    imageRenderBln=false;
                  return null;
                }
		   
        
    }
  	/* 
   * Dynamic Sobject List
   *  public List<sObject> prepareEndPoint(String strObjctAPIName,List<String>lstFieldString,String clauseWhere)
    {
        String query = 'SELECT ';
        for(String sField:lstFieldString)
        {
            query += sField + ',';
        }
        query.removeEnd(',');
		  query += ' FROM '+ strObjctAPIName + ' WHERE '+  clauseWhere;    
     return Database.query(query);   
    }
    */
    public sObject getQueriedDynamicSObject(String strObjctAPIName,Set<String>stFieldString,Id recordId)
    {
        if(strObjctAPIName != null )
        {        
        String query = 'SELECT ';
         If(stFieldString==null || stFieldString.size()== 0)
        {
           query +=  'ID ' ;
        }else 
        {
            for(String sField:stFieldString)
            {
                query += sField + ',';
            }
       		query = query.removeEnd(',');
        
        }
            
        
		  query += ' FROM '+ strObjctAPIName + ' WHERE ID =\''+  recordId +'\'';    
     return Database.query(query);   
        } return null;
    }
    
    public string getObjectNamebyPassingID(Id recordID){
      
		String strObjName;
		Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
		for(String s:describe.keyset())
			mapIDtosObjectName.put(describe.get(s).getDescribe().getKeyPrefix(),s);
        if(recordID!=NULL)
        {
		strObjName = mapIDtosObjectName.get(String.valueOf(recordId).substring(0,3)); 
        }
       // selectedObject = describe.get(strObjName).newSObject();
        return strObjName;
        }
   
}