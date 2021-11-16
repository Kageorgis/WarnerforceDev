public class WB_Batch_AutomatedReleaseDateRP implements Database.Batchable<sObject>,Database.Stateful {
    String queryString = Null;
    public List<CAS_Error_Log__c> lstCasErrorLog = new List<CAS_Error_Log__c>();
    public Map<String,CAS_Error_Log__c> rpIdCASErrorLogMap = new Map<String,CAS_Error_Log__c>();
    String contentType = 'Feature';
    
    public WB_Batch_AutomatedReleaseDateRP(){
        queryString = 'SELECT Id,Channel__c,Title_Content_Type__c,RP_AutoCalc__c,Rights_Start__c,Rights_Object_End__c,Rights_End__c,Exclusive_Date__c,Start_Date__c,End_Date__c,GPP_Avail_Start__c,Country_Lookup__c,Country_Lookup__r.EST_Offset__c,'+
                      'Country_Lookup__r.VOD_Offset__c,Country_Lookup__r.VOD_Exploitation_Days__c,Country_Lookup__r.Physical_Offset__c,Local_Title__c,Local_Title__r.Local_Theatrical_Release_Date__c,Local_Title__r.Initial_VOD_Release_Date__c,'+
                      'Title__c,Rights_ID__c,Title__r.US_Theatrical_Release_Date_New__c,Title__r.First_Available_Date__c,Title__r.Expiration_Date__c FROM Commercial_Avail__c where RP_AutoCalc__c=True AND Title_Content_Type__c =: contentType';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Commercial_Avail__c> scope){

        Map<String,Set<Commercial_Avail__c>> titleRPMap = new Map<String,Set<Commercial_Avail__c>>();
        Map<String,Set<Commercial_Avail__c>> localTitleRPMap = new Map<String,Set<Commercial_Avail__c>>();
        Map<String,Set<Commercial_Avail__c>> rightsRPMap = new Map<String,Set<Commercial_Avail__c>>();
        Map<String,Set<Commercial_Avail__c>> countryRPMap = new Map<String,Set<Commercial_Avail__c>>();
        List<Commercial_Avail__c> rpToProcessList = new List<Commercial_Avail__c>();
        Set<Commercial_Avail__c> rpSet = new Set<Commercial_Avail__c>();
        Set<Commercial_Avail__c> rpStartDateSet = new Set<Commercial_Avail__c>();
        Set<Commercial_Avail__c> rpFinalUpdateSet = new Set<Commercial_Avail__c>();
        List<Commercial_Avail__c> updateRPList = new List<Commercial_Avail__c>();
        
        for(Commercial_Avail__c rpRecord : scope){
            
            if(!(titleRPMap.containsKey(rpRecord.Title__c)))
                titleRPMap.put(rpRecord.Title__c,new Set<Commercial_Avail__c>());
            titleRPMap.get(rpRecord.Title__c).add(rpRecord);
            
            if(!localTitleRPMap.containsKey(rpRecord.Local_Title__c))
                localTitleRPMap.put(rpRecord.Local_Title__c,new Set<Commercial_Avail__c>());
            localTitleRPMap.get(rpRecord.Local_Title__c).add(rpRecord);
            
            if(!rightsRPMap.containsKey(rpRecord.Rights_ID__c))
                rightsRPMap.put(rpRecord.Rights_ID__c,new Set<Commercial_Avail__c>());
            rightsRPMap.get(rpRecord.Rights_ID__c).add(rpRecord);

            if(!countryRPMap.containsKey(rpRecord.Country_Lookup__c))
                countryRPMap.put(rpRecord.Country_Lookup__c,new Set<Commercial_Avail__c>());
            countryRPMap.get(rpRecord.Country_Lookup__c).add(rpRecord);

            if(rpRecord.Start_Date__c < System.Today()){
                rpStartDateSet.add(rpRecord);
            }

        }

        List<Title__c> titleList = [Select Id from Title__c where SystemModStamp = LAST_N_DAYS:1  AND Id IN :titleRPMap.keySet()];
        List<Local_Title__c> localTitleList = [Select Id from Local_Title__c where SystemModStamp = LAST_N_DAYS:1  AND Id IN :localTitleRPMap.keySet()];
        List<Rights__c> rightsList = [Select Id from Rights__c where SystemModStamp = LAST_N_DAYS:1  AND Id IN :rightsRPMap.keySet()];
        List<Country__c> countryList = [Select Id from Country__c where SystemModStamp = LAST_N_DAYS:1  AND Id IN :countryRPMap.keySet()];
        
        if(titleList != Null && titleList.size()>0){
            for(Title__c titleRec : titleList){
                if(titleRPMap.containsKey(titleRec.Id)){
                    rpSet.addAll(titleRPMap.get(titleRec.Id));
                }
            }
        }
        
        if(localTitleList != Null && localTitleList.size()>0){
            for(Local_Title__c localTitleRec : localTitleList){
                if(localTitleRPMap.containsKey(localTitleRec.Id)){
                    rpSet.addAll(localTitleRPMap.get(localTitleRec.Id));
                }
            }
        }
        
        if(rightsList != Null && rightsList.size()>0){
            for(Rights__c rightRec : rightsList){
                if(rightsRPMap.containsKey(rightRec.Id)){
                    rpSet.addAll(rightsRPMap.get(rightRec.Id));
                }
            }
        }
        
        if(countryList != Null && countryList.size()>0){
            for(Country__c countryRec : countryList){
                if(countryRPMap.containsKey(countryRec.Id)){
                    rpSet.addAll(countryRPMap.get(countryRec.Id));
                }
            }
        }
        
        try{

            //List of RP if Local Title/Title/Rights have been modified
            if(rpSet != Null && rpSet.size()>0){
                rpFinalUpdateSet.addAll(rpSet);
            }

            //List of RP if RP Start Date is passed
            if(rpStartDateSet != Null && rpStartDateSet.size()>0){
                rpFinalUpdateSet.addAll(rpStartDateSet);
            }

            if(rpFinalUpdateSet != Null && rpFinalUpdateSet.size()>0){

                rpToProcessList.addAll(rpFinalUpdateSet);
                Map<Id,Commercial_Avail__c> processRPMap = new Map<Id,Commercial_Avail__c>();
                processRPMap.putAll(rpToProcessList);
                
                updateRPList = WB_CalculateRPDates.autoCalcReleaseDates(processRPMap.values(),Null,Null,Null,Null,processRPMap,'Batch');
                if(updateRPList != Null && updateRPList.size()>0){
                    Database.Saveresult[] saveResult = Database.update(updateRPList, false);
                    for(Integer index=0;index<saveResult.size();index++){
                        Database.SaveResult updateResult = saveResult[index];
                      
                        if(!updateResult.isSuccess()){
                            String errorMessage ='';
                            
                            for(Database.Error err : updateResult.getErrors()) {
                                errorMessage += err.getMessage();
                               }
                                
                                CAS_Error_Log__c casErrorLog = new CAS_Error_Log__c(Object_Name__c = updateRPList[index].Id.getSObjectType().getDescribe().getName(),
                                                                Error_Description__c = errorMessage.left(252),Error_Description_Long__c = errorMessage.left(99998),
                                                                Error_Category__c = 'Release Plan - Automate Release Dates Error',Record_Id__c = updateRPList[index].Id);
                                lstCasErrorLog.add(casErrorLog);
                                rpIdCASErrorLogMap.put(updateRPList[index].Id,casErrorLog);
                            
                        }
                    }
                    if(lstCasErrorLog != NULL && lstCasErrorLog.size() > 0){
                        try{
                            insert lstCasErrorLog;
                        }catch(exception e){
                            system.debug(LoggingLevel.INFO,'Following Error:'+e.getMessage());}
                    }
                    
                }
            }

        }catch(Exception e){
            System.debug(LoggingLevel.INFO,'Following error occurred: '+e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(rpIdCASErrorLogMap != Null && rpIdCASErrorLogMap.size()>0){
            List<Commercial_Avail__c> rpErrorList = new List<Commercial_Avail__c>();
            string header = 'Title, Video Version, Release Plan Name,Release Plan Id,Channel, Format, Language, Language Type, Country, Error Category, Error Description \n';
            string finalstr = header;
            rpErrorList = [SELECT Id,Title_Formula__c,Title_Video_Version__c,Name,Channel__c,Format__c,Language_Formula__c,Language_Type__c,Country_Formula__c FROM Commercial_Avail__c WHERE Id IN :rpIdCASErrorLogMap.keySet()];

            if(rpErrorList != Null && rpErrorList.size()>0){
                for(Commercial_Avail__c rpRecord : rpErrorList){
                    string recordString = '"'+rpRecord.Title_Formula__c+'","'+rpRecord.Title_Video_Version__c+'","'+rpRecord.Name+'","'+rpRecord.Id+'","'+rpRecord.Channel__c+'","'+rpRecord.Format__c+'","'+
                                          rpRecord.Language_Formula__c+'","'+rpRecord.Language_Type__c+'","'+rpRecord.Country_Formula__c+'","';
                    if(rpIdCASErrorLogMap.get(rpRecord.Id) != Null){
                        recordString = recordString+rpIdCASErrorLogMap.get(rpRecord.Id).Error_Category__c+'","'+rpIdCASErrorLogMap.get(rpRecord.Id).Error_Description_Long__c  +'"\n';
                    }

                    finalstr = finalstr +recordString;
                }

                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                blob csvBlob = Blob.valueOf(finalstr);
                string csvname= 'Automated Release Date - Failed Client Avails.csv';
                csvAttc.setFileName(csvname);
                csvAttc.setBody(csvBlob);
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.addAll(Label.RP_Automated_Error_Email_List.split(';'));
                String subject ='CAS Error Log CSV for Automated Release Date RP';
                email.setSubject(subject);
                email.setToAddresses(sendTo);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                email.setPlainTextBody('Those records which could not be updated (exceptions) are included in an attachment to this message for the user to review.');
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

            }
        }
     
    }

}