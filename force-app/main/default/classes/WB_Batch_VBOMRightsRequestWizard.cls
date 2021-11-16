/**
 * Written by: Astha(CTS)
 * Description: For creating/updating rights in case, count > 300
 * Project: EBR-Advanced Rights 
**/

public class WB_Batch_VBOMRightsRequestWizard implements Database.Batchable<sObject>,Database.Stateful{ 

    Public String queryString=''; // Query string used to get scope in Execute method.
    public List<String> lstselectedIDs;
    //public list<string> lstSelectMPM;
    List<Title__c> lstSelectedTitle = new List<Title__c>();
    map<String,MPM__c> mapMPMrecords = new map<String,MPM__c>();
    map<ID,String> maptitleIDandMPM = new map<ID,String>();
    map<ID,Set<ID>> maptitleIDListTBOMID = new map<ID,Set<ID>>(); 
    map<ID,String> mapTBOMIDandMPM = new map<ID,String>(); 
    set<String> setAllMPMIDs = new set<String>();    
    
    public map<String,Rights__c> mapKeyRightsToBeInserted = new map<String,Rights__c>();
    public map<String,Rights__c> mapKeyRightsToBeUpdated = new map<String,Rights__c>();
    
    Set<string> setGroupsAndchannel;
    public Rights__c objRights;
    list<Request_Rights_error_log__c> lstRightsError = new list<Request_Rights_error_log__c>();
    user userDetail;
    
    public WB_Batch_VBOMRightsRequestWizard( list<Title__c> clstSelectedTitle,map<String,MPM__c> cmapMPMrecords, map<ID,String> cmaptitleIDandMPM,
            map<ID,Set<ID>> cmaptitleIDListTBOMID, map<ID,String> cmapTBOMIDandMPM, set<string> setGroupsNchannel, Rights__c objRightsData){
        //lstSelectMPM = lstMPMId;
        lstSelectedTitle= clstSelectedTitle;
        mapMPMrecords = cmapMPMrecords;
        maptitleIDandMPM = cmaptitleIDandMPM;
        maptitleIDListTBOMID = cmaptitleIDListTBOMID;
        mapTBOMIDandMPM = cmapTBOMIDandMPM;
        setGroupsAndchannel = setGroupsNchannel;
        objRights = objRightsData;
        userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c,Rights_Batch_Id__c from User where id =: Userinfo.getUserId()];
    
        system.debug('*******setGroupsAndchannel '+setGroupsAndchannel+'@@@@@setGroupsNchannel'+setGroupsNchannel);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        queryString = 'Select Id,Name,MPM_Short_Desc__c,Abstract_EIDR__c,Status__c,Generic__c from MPM__c limit 1';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<MPM__c> scope){
            List<Rights__c> updateRightsLst =new List<Rights__c>();
            List<Rights__c> insertRightsLst =new List<Rights__c>();
            List<Rights__c> lstFinalRightsUpsert = new List<Rights__c>();
            
            
            system.debug('*******setGroupsAndchannel: BEFORE@@@'+setGroupsAndchannel);
            for(Title__c titleRec : lstSelectedTitle){
                if(!titleRec.MPM__r.Generic__c){
                    //iterate on title related MPM - START
                    if(mapMPMrecords.get(maptitleIDandMPM.get(titleRec.ID))!=null){
                        MPM__c selectMPM=mapMPMrecords.get(maptitleIDandMPM.get(titleRec.ID));
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
                                    if(mpmRights.Channel__c == Channels && mpmRights.Rights_Group__c == RightsGroups)
                                    {
                                        rightsAvailable = true;
                                        if(mpmRights.Rights_Query_Start_Date__c != objRights.Rights_Query_Start_Date__c || mpmRights.Request_Refresh__c == false ){
                                            if(objRights.Rights_Query_Start_Date__c != null)
                                                mpmRights.Rights_Query_Start_Date__c = objRights.Rights_Query_Start_Date__c;
                                            mpmRights.Request_Refresh__c = True;
                                            
                                            updateRightsLst.add(mpmRights);
                                        }
                                        break;
                                    }
                                    else if(mpmRights.Channel__c == Channels && mpmRights.Rights_Group__c == RightsGroups && mpmRights.Request_Refresh__c)
                                    {
                                        rightsAvailable = true;
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
                                        Id recordTypeId = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
                                        newRights.RecordTypeId = recordTypeId;
                                        insertRightsLst.add(newRights); 
                                }
                            }
                        }
                    }
                    //iterate on title related MPM - END
                }
                else{
                    boolean finalflag = false;//for identifying if right is to be created for Title
                    boolean flagTBOM = true;
                    if(titleRec.Title_BOM__r.size()>0){
                        //iterate on TBOM related MPM - START
                        for(ID TBOMID: maptitleIDListTBOMID.get(titleRec.ID)){
                            boolean flag = null; 
                            if(mapTBOMIDandMPM.get(TBOMID)!=null){
                                if(mapMPMrecords.get(mapTBOMIDandMPM.get(TBOMID))!=null){
                                    MPM__c selectMPM = mapMPMrecords.get(mapTBOMIDandMPM.get(TBOMID));
                                    if(selectMPM.Generic__c){
                                        //Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                        //RightsError.MPM__c = selectMPM.Name;
                                        //RightsError.Reason__c = 'Generic MPM '+selectMPM.Name+' is selected. Request refresh cannot be initiated for generic MPMs. ';
                                        //lstRightsError.add(RightsError);
                                        flag = false;                                   
                                    }
                                    else if(!(selectMPM.MPM_Number__c).startsWith('2')){
                                        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                        RightsError.MPM__c = selectMPM.Name;
                                        RightsError.Reason__c = 'You can only submit a rights request for non generic MPM starting with \'2\'';
                                        lstRightsError.add(RightsError);
                                        flag= true;
                                    }
                                    else{
                                        flag = true;
                                        for(string groupsChannel : setGroupsAndchannel){
                                            Boolean rightsAvailable = false;
                                            String RightsGroups = groupsChannel.split('_')[0];
                                            String Channels = groupsChannel.split('_')[1];
                                            
                                            for(Rights__c mpmRights : selectMPM.Rights__r){                                                        
                                                if(mpmRights.Channel__c == Channels && mpmRights.Rights_Group__c == RightsGroups)
                                                {
                                                    rightsAvailable = true;
                                                    if(mpmRights.Rights_Query_Start_Date__c != objRights.Rights_Query_Start_Date__c || mpmRights.Request_Refresh__c == false ){
                                                        if(objRights.Rights_Query_Start_Date__c != null)
                                                            mpmRights.Rights_Query_Start_Date__c = objRights.Rights_Query_Start_Date__c;
                                                        mpmRights.Request_Refresh__c = True;
                                                        
                                                        updateRightsLst.add(mpmRights);
                                                    }
                                                    break;
                                                }
                                                else if(mpmRights.Channel__c == Channels && mpmRights.Rights_Group__c == RightsGroups && mpmRights.Request_Refresh__c)
                                                {
                                                    rightsAvailable = true;
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
                                                    Id recordTypeId = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
                                                    newRights.RecordTypeId = recordTypeId;
                                                    insertRightsLst.add(newRights);
                                            }
                                        }
                                    }
                                }
                            }
                            finalflag = finalflag||flag;
                        }
                        //iterate on TBOM related MPM - END
                    }
                    else{
                        flagTBOM = false;
                    }   
                    if(finalflag ||!flagTBOM ){
                        //iterate on group-channel combination for rights related to title record-----START
                        for(string groupsChannel : setGroupsAndchannel){
                                Boolean rightsAvailable = false;
                                String RightsGroups = groupsChannel.split('_')[0];
                                String Channels = groupsChannel.split('_')[1];
                                
                                for(Rights__c titleRights : titleRec.Rights__r){                                                        
                                    if(titleRights.Channel__c == Channels && titleRights.Rights_Group__c == RightsGroups)
                                    {
                                        rightsAvailable = true;
                                        if(titleRights.Rights_Query_Start_Date__c != objRights.Rights_Query_Start_Date__c || titleRights.Request_Refresh__c == false ){
                                            if(objRights.Rights_Query_Start_Date__c != null)
                                                titleRights.Rights_Query_Start_Date__c = objRights.Rights_Query_Start_Date__c;
                                            titleRights.Request_Refresh__c = True;
                                            
                                            updateRightsLst.add(titleRights);
                                        }
                                        break;
                                    }
                                    else if(titleRights.Channel__c == Channels && titleRights.Rights_Group__c == RightsGroups && titleRights.Request_Refresh__c)
                                    {
                                        rightsAvailable = true;                                    
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
                                        newRights.Title__c = titleRec.Id;
                                        Id recordTypeId = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
                                        newRights.RecordTypeId = recordTypeId;
                                        insertRightsLst.add(newRights);
                                    
                                }
                            }
                        //iterate on group-channel combination for rights related to title record-----END
                        if(!flagTBOM){
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no component MPM present for this title')); 
                            Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();                        
                            RightsError.Reason__c = 'WARNING: There are no component MPMs present for the title- '+titleRec.name;
                            RightsError.Title__c = titleRec.name;
                            lstRightsError.add(RightsError);
                        }
                     }
                    else{
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no Generic MPM related to this title'));
                        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();                        
                        RightsError.Reason__c = 'There is no Generic MPM (component/parent) related to the title- '+titleRec.name;
                        RightsError.Title__c = titleRec.name;
                        lstRightsError.add(RightsError);}
                    
                }
                
            }
            //iteration for rights end
                
                //filter duplicate Rights
                for(Rights__c insRight : insertRightsLst){
                    if(insRight.MPM__c!=null){
                        String key= ''+insRight.Channel__c+ insRight.Rights_Group__c+insRight.MPM__c;
                        if(!mapKeyRightsToBeInserted.containsKey(key))
                        mapKeyRightsToBeInserted.put(key,insRight);  
                    }
                    else{
                        String key= ''+insRight.Channel__c+ insRight.Rights_Group__c+insRight.Title__c;
                        if(!mapKeyRightsToBeInserted.containsKey(key))
                        mapKeyRightsToBeInserted.put(key,insRight); 
                    } 
                }
                
                for(Rights__c updRight : updateRightsLst){
                    
                    if(updRight.MPM__c!=null){
                        String key= ''+updRight.Channel__c+ updRight.Rights_Group__c+ updRight.MPM__c ;
                        if(!mapKeyRightsToBeUpdated.containsKey(key))
                        mapKeyRightsToBeUpdated.put(key,updRight); 
                    }
                    else{
                        String key= ''+updRight.Channel__c+ updRight.Rights_Group__c+updRight.Title__c;
                        if(!mapKeyRightsToBeUpdated.containsKey(key))
                        mapKeyRightsToBeUpdated.put(key,updRight); 
                    }                   
                }
                
                lstFinalRightsUpsert.addAll(mapKeyRightsToBeInserted.values());
                lstFinalRightsUpsert.addAll(mapKeyRightsToBeUpdated.values());
                
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
                +rpExceptionOut_lst.Title__c+'","'
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
        toAddresses.add('CTSSalesforceSupport@warnerbros.com'); //Adding CTS Salesforce Support DL   
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