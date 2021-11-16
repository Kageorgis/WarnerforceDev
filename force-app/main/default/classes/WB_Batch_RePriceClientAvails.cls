global with sharing class WB_Batch_RePriceClientAvails implements Database.Batchable<sObject>, database.stateful{
    
    Client_Avail__c objCA;
    List<String> selectedCAIds;
    Id userId;
    List<String> messageList;
    global map<string, list<String>> errorMessageMap = new map<string, list<String>>();
    
    global WB_Batch_RePriceClientAvails(Client_Avail__c obj, List<String> selectedClientAvailIds, Id loggedInUserId){
        objCA = obj;
        selectedCAIds = selectedClientAvailIds;
        userId = loggedInUserId;
        errorMessageMap = new map<string, list<String>>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        errorMessageMap = new map<string, list<String>>();
        return Database.getQueryLocator('select Id from Client_Avail__c where Id IN: selectedCAIds');
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Avail__c> scope){
        
        //errorMessageMap.put('Test', new List<String>{'Value 1'});
        system.debug('errorMessageMap=====> ' + errorMessageMap);
        
        List<String> selectedClientAvailIds = new List<String>();
        for(Client_Avail__c obj : scope){
            selectedClientAvailIds.add(obj.Id);
        }
        
        List<String> tempMessageList = new List<String>();
        WB_RePriceClientAvails_Handler objRePriceClientAvails_Handler = new WB_RePriceClientAvails_Handler();
        //messageList.addAll(objRePriceClientAvails_Handler.updateprice(objCA, selectedClientAvailIds, userId, true));
        map<string, List<String>> resultMap = objRePriceClientAvails_Handler.updateprice(objCA, selectedClientAvailIds, userId, true);
        if(resultMap != null && resultMap.size() > 0)
            errorMessageMap.putAll(resultMap);
        
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('-----errorMessageMap---------'+errorMessageMap.values());
        //Akash Changes start
        if(errorMessageMap != null && errorMessageMap.size() > 0){
        
            String htmlBody = '<html><body>';
            htmlBody = htmlBody + '<p>The batch execution for reprice has been completed!\n\n</p>';
            String messageBody = 'The batch execution for reprice has been completed!\n';
            
            system.debug('==== Send Email ====');
            user u = new user(id=userId );
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage ();
            message.setSubject (Label.WB_Batch_Reprice_Wizard_Subject);
            message.setPlainTextBody (messageBody);
               
            List<Client_Avail_Wizard_Exceptions__c> exceptionList = new List<Client_Avail_Wizard_Exceptions__c>([
                select Account__c, Country__c, Language__c, Format__c, Channel__c, Title__c, User_Detail__c, Price_Tier__c, Status__c,
                       SR_Price__c, WS_Price__c, ClientAvail_Start_Date__c, ClientAvail_End_Date__c, Reason__c, Name
                  from Client_Avail_Wizard_Exceptions__c where User_Detail__c =:Userinfo.getUserId()
            ]);
            string header = 'Account, Title, Country, Language, Channel, Format, Client Start, Client End, Client Avail Status, Reason\n';
            string finalstr = header ;
                for(Client_Avail_Wizard_Exceptions__c caException : exceptionList){
                    string recordString = '"'+(caException.Account__c != null ? caException.Account__c : caException.Name)
                                         +'","'+(caException.Title__c != null ? caException.Title__c : '-')
                                         +'","'+(caException.Country__c != null ? caException.Country__c : '-')
                                         +'","'+(caException.Language__c != null ? caException.Language__c : '-')
                                         +'","'+(caException.Channel__c != null ? caException.Channel__c : '-')
                                         +'","'+(caException.Format__c != null ? caException.Format__c : '-')
                                         +'","'+caException.ClientAvail_Start_Date__c
                                         +'","'+caException.ClientAvail_End_Date__c
                                         +'","'+(caException.Status__c != null ? caException.Status__c : '-')
                                         +'","'+(caException.Reason__c != null ? caException.Reason__c : '-')
                                         +'","'
                                         +'"\n';
                    finalstr = finalstr + recordString;
                }
            for(String mapKey : errorMessageMap.keySet()){
                    for(String errorMessage : errorMessageMap.get(mapKey)){
                        string recName = (mapKey.contains('saveResult')) ? 'New Client Avail' : mapKey;
                        string recordString = '"'+recName+'","'
                                              +errorMessage+'","'
                                              +'"\n';
                        finalstr = finalstr + recordString;
                    }
                }
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                blob csvBlob = Blob.valueOf(finalstr);
                string csvname= 'RepriceErrors.csv';
                csvAttc.setFileName(csvname);
                csvAttc.setBody(csvBlob);
                message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                message.setHtmlBody(htmlBody);
                message.setToAddresses (new String [] {UserInfo.getUserEmail(),system.label.WB_Batch_Email_Recipient});
                Messaging.sendEmail (new Messaging.SingleEmailMessage [] {message});
                delete exceptionList;
            }
            /* Delete Client_Avail_Exception__c records */
            List<Client_Avail_Exception__c> existing = [SELECT Id From Client_Avail_Exception__c where User_Detail__c =:Userinfo.getUserId()];
                if(existing!= null && existing.size()>0){
                    delete existing;
            }
            //Akash Changes finish
    }
}