///******* 
//Name:WB_GenerateReportBatchProcess
//Creation Date- 16 Feb 2015
//Last Modified Date - 
//Last Modified by  - Imran
//Description- This is trigger class to generate report at runtime base on Announcement Id
//Author- Imran
//*******/
global class WB_GenerateReportBatchProcess implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{

     
     global set<Id> lstAnnouncementIds;   
     public list<Announcement__c> TESTannoucementListToUpdate = new list<Announcement__c>();
     private static String ALGO_NAME='AES128';
     private static String AES_PRIVATE_KEY='Psfk0yJziqwDGb2Op6J43w==';
       
    global WB_GenerateReportBatchProcess( set<Id> AnnouncementIds){
        lstAnnouncementIds = AnnouncementIds;
    }     

    global Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT  id,Name,Name__c,File_Status__c,Announcement_Price_Type__c,File_Format__c,Announcement_Type__c,Announcement_Record_Count__c,CreatedBy.email,Sent_Date__c FROM Announcement__c WHERE id IN :lstAnnouncementIds';       
        return Database.getQueryLocator(Query);
    }
    
   
    
    global void execute(Database.BatchableContext BC, 
                                            List<Announcement__c> scope){
        TESTannoucementListToUpdate = scope;
        String commaSepratedList='';
        boolean IsBigAnnouncment = false;
        
        for(Announcement__c ann : scope){
            System.debug('ann.File_Format__c :'+ann.File_Format__c);
            System.debug('ann.Announcement_Record_Count__c :'+ann.Announcement_Record_Count__c);
             if(ann.File_Format__c=='CSV' && ann.Announcement_Record_Count__c > WB_Announcement_Util.CSV_LIMIT){
                  commaSepratedList += ann.Id +',' ;
              }else if(ann.Announcement_Record_Count__c > WB_Announcement_Util.XLS_LIMIT) {
                  IsBigAnnouncment = true;
                  commaSepratedList += ann.Id +',' ;
              }
        }
        
        if (commaSepratedList.length() > 1 || IsBigAnnouncment) {
            CAS_Global_Settings__c globalConfig = CAS_Global_Settings__c.getValues('CAS Global Settings');
        //First way to get session id
        System.debug('Activation : '+globalConfig.Activation_Username__c);
        System.debug('Key : '+globalConfig.Activation_Key__c);
        Blob aesKey = EncodingUtil.base64Decode(AES_PRIVATE_KEY);
        Blob encUsername = EncodingUtil.base64Decode(globalConfig.Activation_Username__c);
        Blob encPassword = EncodingUtil.base64Decode(globalConfig.Activation_Key__c);
        String uName=Crypto.decryptWithManagedIV(ALGO_NAME, aesKey, encUsername).toString();       
        String passwd=Crypto.decryptWithManagedIV(ALGO_NAME, aesKey, encPassword).toString();
        
        
        //2nd way to get session id
        Http h = new Http();
        HttpRequest req2 = new HttpRequest();
        String loginEndpoint  = globalConfig.Login_Endpoint__c;
        String loginReq = '<?xml version="1.0" encoding="utf-8" ?><env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"> <env:Body><n1:login xmlns:n1="urn:partner.soap.sforce.com"><n1:username>'+uName+'</n1:username><n1:password>'+passwd+'</n1:password></n1:login></env:Body></env:Envelope>';
        req2.setBody(loginReq);
        req2.setHeader('Content-Type','text/xml');
        req2.setHeader('SOAPAction','login');
        req2.setEndpoint(loginEndpoint);
        req2.setMethod('POST');
        System.debug('>>>>>>>>>>>>>>>>>Logging In now');
        HttpResponse res; 
        res = h.send(req2);
        System.debug('>>>>>>>>>>>>>>>>>Login response');
        String loginRes = res.getBody();
        String SESSION_ID='<sessionId>';
        Integer startIndex = loginRes.indexOf(SESSION_ID);
        startIndex+=SESSION_ID.length();
        Integer endIndex= loginRes.indexOf('</',startIndex);
        String sessionId =loginRes.substring(startindex,endIndex);
        System.debug('SESSION ID 2 : '+sessionId);
        

        
        // remove last additional comma from string
        commaSepratedList = commaSepratedList.subString(0,commaSepratedList.length());
        System.debug('IDS LIST :'+commaSepratedList);
        String surl = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/';
        String addr = surl + 'services/apexrest/WB_CreateReport';
        HttpRequest req = new HttpRequest();
        req.setEndpoint( addr );
        req.setMethod('POST');
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        req.setHeader('Content-Type','application/json');
        Map<String,String> postBody = new Map<String,String>();
        postBody.put('ids',commaSepratedList);
        String reqBody = JSON.serialize(postBody);
        req.setBody(reqBody);
        Http http = new Http();
        HttpResponse response = http.send(req);
        }
    }   //end of funtion
    
  
   
    /*
        The finish method is called after all batches are processed. 
        Use this method to send confirmation emails or execute post-processing
        operations.
        
        Currently this function do the following things
            1. Update the Annoucement Type record with  Last Run Date.
            2. Update Annoucement records with Status, Run Date and Sent Date.
    */
    global void finish(Database.BatchableContext BC){      
        List<Announcement__c> annoucementListUpdate = new List<Announcement__c>();
        List<Announcement_Rule__c> annTypeListUpdate = new List<Announcement_Rule__c>();
        Boolean isTempOnly = false;
        AsyncApexJob a = [SELECT Id, 
                                CompletedDate,
                                Status, 
                                NumberOfErrors, 
                                JobItemsProcessed,  
                                TotalJobItems, 
                                CreatedBy.Email, 
                                ExtendedStatus  
                          FROM AsyncApexJob 
                          WHERE Id = :BC.getJobId()];  
        for(Announcement__c ann : TESTannoucementListToUpdate){
            
            if((ann.Announcement_Price_Type__c != null && ann.Announcement_Price_Type__c.containsOnly('TEMP'))){
                isTempOnly = true;
            }
            ann.Sent_Date__c = a.CompletedDate;
            ann.Run_Date__c = a.CompletedDate;
           // ann.Job_Run_Status__c = a.Status;//ER-000384
            annoucementListUpdate.add(ann);
            /* added on 17th march 2015 to update announcement 
             last run date after the batch process is completed */
            Announcement_Rule__c annTypeRec = new Announcement_Rule__c();
            annTypeRec.ID = ann.Announcement_Type__c;
            annTypeRec.Date_Last_Run__c = ann.Run_Date__c;
            annTypeRec.Job_Processing_Status__c = null;
            annTypeListUpdate.add(annTypeRec);
        }
        update annoucementListUpdate;
        update annTypeListUpdate;
        try{
            if (!Test.IsRunningTest()){
                if(!isTempOnly)
                    Id batchInstanceId = Database.executeBatch(new WB_UpdateAOOnCABatchProcess(lstAnnouncementIds), 20);
            }
        }catch(Exception e){
            System.debug('Error WB_UpdateAOOnCABatchProcess :'+e);
        }
    }
    

}