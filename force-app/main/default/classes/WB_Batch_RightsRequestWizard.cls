/**
 * Written by: Preeti Jha(CTS)
 * Description: This controller is used for Rights Request Refresh functionality for larger data.
 * Project: CRRT (Phase 4-b) 
**/

public class WB_Batch_RightsRequestWizard implements Database.Batchable<sObject>,Database.Stateful{ 

    Public String queryString=''; // Query string used to get scope in Execute method.
    public list<string> lstSelectMPM;
    Set<string> setGroupsAndchannel;
    public Rights__c objRights;
    list<Request_Rights_error_log__c> lstRightsError = new list<Request_Rights_error_log__c>();
    user userDetail;
    
    public WB_Batch_RightsRequestWizard(list<string> lstMPMId, set<string> setGroupsNchannel, Rights__c objRightsData){
        lstSelectMPM = lstMPMId;
        setGroupsAndchannel = setGroupsNchannel;
        objRights = objRightsData;
        userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c,Rights_Batch_Id__c from User where id =: Userinfo.getUserId()];
   }
     public Database.QueryLocator start(Database.BatchableContext BC){
        queryString = 'Select Id,Name,MPM_Short_Desc__c,Abstract_EIDR__c,Status__c,Generic__c from MPM__c where Id IN:lstSelectMPM';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<MPM__c> scope){
            List<Rights__c> updateRightsLst =new List<Rights__c>();
            List<Rights__c> insertRightsLst =new List<Rights__c>();
            List<Rights__c> lstFinalRightsUpsert = new List<Rights__c>();
            List<MPM__c> lstMPMnRights =[Select Id,Name,MPM_Short_Desc__c,Abstract_EIDR__c,Status__c,Generic__c,MPM_Number__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r) from MPM__c where Id IN:lstSelectMPM];
            for(MPM__c selectMPM : lstMPMnRights){
                
                if(selectMPM.Generic__c){
                    Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                    RightsError.MPM__c = selectMPM.Name;
                    RightsError.Reason__c = 'Generic MPM '+selectMPM.Name+' is selected. Request refresh cannot be initiated for generic MPMs. ';
                    lstRightsError.add(RightsError);
                    
                }
                else if(!(selectMPM.MPM_Number__c).startsWith('2')){
                    Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                    RightsError.MPM__c = selectMPM.Name;
                    RightsError.Reason__c = 'You can only submit a rights request for non generic MPM starting with \'2\'';
                    lstRightsError.add(RightsError);
                }
                else{
                    for(string groupsChannel : setGroupsAndchannel){
                        Boolean rightsAvailable = false;
                        String RightsGroups = groupsChannel.split('_')[0];
                        String Channels = groupsChannel.split('_')[1];
                        
                        for(Rights__c mpmRights : selectMPM.Rights__r){                            
                            if(mpmRights.Channel__c == Channels && mpmRights.Rights_Group__c == RightsGroups && !mpmRights.Request_Refresh__c)
                            {
                                rightsAvailable = true;
                                if(objRights.Rights_Query_Start_Date__c != null)
                                    mpmRights.Rights_Query_Start_Date__c = objRights.Rights_Query_Start_Date__c;
                                mpmRights.Request_Refresh__c = True;
                                
                                updateRightsLst.add(mpmRights);
                                break;
                            }
                            else if(mpmRights.Channel__c == Channels && mpmRights.Rights_Group__c == RightsGroups && mpmRights.Request_Refresh__c)
                            {
                                rightsAvailable = true;
                               /* Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                RightsError.MPM__c = selectMPM.Name;
                                RightsError.Request_Refresh__c =mpmRights.Request_Refresh__c;
                                RightsError.Rights_End_1__c =mpmRights.Rights_End__c;
                                RightsError.Rights_Id__c =mpmRights.Name;
                                RightsError.Rights_Start_1__c =mpmRights.Rights_Start__c;
                                RightsError.Status__c =mpmRights.Status__c;
                                RightsError.Channel__c = mpmRights.Channel__c;
                                RightsError.Rights_Group__c = mpmRights.Rights_Group__c;
                                RightsError.Reason__c = 'Request refresh for MPM-'+selectMPM.Name+', '+mpmRights.Rights_Group__c+' and '+mpmRights.Channel__c+' is already checked. ';
                                
                                lstRightsError.add(RightsError);*/
                            }
                           
                        }
                        if(!rightsAvailable){
                            Rights__c newRights = new Rights__c();
                            newRights.Channel__c = Channels;
                            newRights.Rights_Group__c = RightsGroups;
                            if(objRights.Rights_Query_Start_Date__c != null)
                                newRights.Rights_Query_Start_Date__c = objRights.Rights_Query_Start_Date__c;
                            newRights.Request_Refresh__c = True;
                            newRights.Source__c = 'Manual';
                            newRights.Status__c = 'Researching';
                            newRights.MPM__c = selectMPM.Id;
                            insertRightsLst.add(newRights);
                            
                            }
                        }
                    }
                }
                
                lstFinalRightsUpsert.addAll(insertRightsLst);
                lstFinalRightsUpsert.addAll(updateRightsLst);
                
                List<Rights__c> lstFinalRights = new List<Rights__c>();
                if(lstFinalRightsUpsert != null && lstFinalRightsUpsert.size() > 0)
                    lstFinalRights = batchIdGeneration(lstFinalRightsUpsert); 
                
                 if(lstFinalRights !=null && lstFinalRights.size() > 0 ){
                     try{ 
                        Database.UpsertResult[] saveResult  = Database.upsert(lstFinalRights, false);
                         String errMessage = '';
                         for(Integer i=0 ; i < saveResult.size() ; i++){
                            if(!saveResult[i].isSuccess()){
                                Database.Error error = saveResult[i].getErrors().get(0);
                                Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                RightsError.MPM__c = lstFinalRights[i].MPM__r.Name;
                                RightsError.Request_Refresh__c =lstFinalRights[i].Request_Refresh__c;
                                RightsError.Rights_End_1__c =lstFinalRights[i].Rights_End__c;
                                RightsError.Rights_Id__c =lstFinalRights[i].Name;
                                RightsError.Rights_Start_1__c =lstFinalRights[i].Rights_Start__c;
                                RightsError.Status__c =lstFinalRights[i].Status__c;
                                RightsError.Channel__c = lstFinalRights[i].Channel__c;
                                RightsError.Rights_Group__c = lstFinalRights[i].Rights_Group__c;
                                RightsError.Reason__c = '...'+error.getMessage();
                                
                                lstRightsError.add(RightsError);
                            }
                         }
                         
                     }
                     catch(Exception ex){
                         system.debug('Here is exception'+ex);
                     }
                 }
               
            if(lstRightsError != null && lstRightsError.size() > 0){
               Database.Saveresult[] saveExceptionResult  = Database.insert(lstRightsError, false);
            }
    }
    public void finish(Database.BatchableContext BC){
        
        //integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];
        string header = 'Rights Id, MPM, Rights Group, Channel, Rights Start 1, Rights End 1, Status, Reason \n';
        string finalstr = header ;
       
        for(Request_Rights_error_log__c rpExceptionOut_lst: lstRightsError)
        {
            string recordString = '"'+rpExceptionOut_lst.Rights_Id__c+'","'
                +rpExceptionOut_lst.MPM__c+'","'
                +rpExceptionOut_lst.Rights_Group__c+'","'
                +rpExceptionOut_lst.Channel__c+'","'
                +rpExceptionOut_lst.Rights_Start_1__c+'","'
                +rpExceptionOut_lst.Rights_End_1__c+'","'
                +rpExceptionOut_lst.Status__c+'","'
                +rpExceptionOut_lst.Reason__c+'","'
                +'"\n';
            string record= recordString.replace('null','');
            finalstr = finalstr +recordString;
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= 'Rights.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :BC.getJobId()];
        // Email the Batch Job's submitter that the Job is finished.
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            
        String subject ='Rights Request Exception CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        String strWbGrid = '/apex/WB_Grid?al=true&CF_QP_filterField=Batch_Id__c&CF_QP_filterValue='+userDetail.Rights_Batch_Id__c+'&obj=Rights__c';
       
        if(lstRightsError == null || lstRightsError.size() == 0){
            email.setPlainTextBody('If you’ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + strWbGrid + '\n If, however, you’ve created more records since you ran the wizard which initiated this batch process,those records won’t be available.');// You can see this batch’s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
        }
        else if(lstRightsError != null && lstRightsError.size() > 0){
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review. Few records are created successfully, you can see records by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + strWbGrid + '\n If, however, you’ve created more records since you ran the wizard which initiated this batch process,those records won’t be available.');// You can see this batch’s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
    /**batch id  creation method **/
    public list<Rights__c> batchIdGeneration(list<Rights__c> list_TobeUpdate){
        
        
        list<Batch_Ids_Customsetting__c> clientAvailBatchId_lst = [Select Id,Name,RP_Batch_Id__c,RP_Created_Date__c,CA_User_Detail__c,Rights_Batch_Id__c,Rights_Created_Date__c from 
                                                                   Batch_Ids_Customsetting__c for update];
        
        if(clientAvailBatchId_lst != null && clientAvailBatchId_lst.size() > 0 && clientAvailBatchId_lst[0].Rights_Batch_Id__c != null){
            integer incremnt = integer.ValueOf(clientAvailBatchId_lst[0].Rights_Batch_Id__c);
            incremnt++;
            string finalBatchId = String.valueOf(incremnt);
            
            clientAvailBatchId_lst[0].Name = userDetail.Id;
            clientAvailBatchId_lst[0].Rights_Batch_Id__c = finalBatchId;
            clientAvailBatchId_lst[0].Rights_Created_Date__c = system.now();
            clientAvailBatchId_lst[0].CA_User_Detail__c = userDetail.Id;
            Database.Upsertresult[] saveBatchResult  = Database.upsert(clientAvailBatchId_lst, false);
            if(saveBatchResult[0].isSuccess()){ 
                userDetail.Rights_Batch_Id__c = clientAvailBatchId_lst[0].Rights_Batch_Id__c;
                update userDetail;
            }
            
           for(Rights__c rights : list_TobeUpdate){
                 rights.Batch_Id__c = clientAvailBatchId_lst[0].Rights_Batch_Id__c;
            }
        }
        return list_TobeUpdate;
    }
    
}