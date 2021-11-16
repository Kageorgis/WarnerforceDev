/**
 * Written by: Preeti Jha(CTS)
 * Description: This controller is used for Rights Request Refresh functionality.
 * Project: CRRT (Phase 4-b) 
**/

public class WB_Request_Refresh_Controller {
    public List<MPM__c> lstSelectedMPM{get;set;}
    public SelectOption[] allRightsGroup{get;set;}
    public SelectOption[] allChannels{get; set;}
    public Rights__c objRights {get;set;}
    public boolean isBatchProcessing{get;set;}
    public boolean mpmScroller{get; set;}
    public string MPMIds;
    public List<string> lstSelectedMPMIds;
    public boolean isAllRightsGroupSelected{get;set;}
    public boolean isAllChannelSelected{get;set;}
    
    user userDetail;
    
    list<Request_Rights_error_log__c> lstRightsError = new list<Request_Rights_error_log__c>();
        
    
    //Multi select
    public SelectOption[] selectedRightsGroup { get; set; }
    Public SelectOption[] selectedRightsChannel {get; set;}
    
    public WB_Request_Refresh_Controller(){
        isAllRightsGroupSelected = false;
        isAllChannelSelected = false;
        objRights = new Rights__c();
        lstSelectedMPM = new List<MPM__c>();
        lstSelectedMPMIds = new list<string>();
        //lstRightsError = new list<Request_Rights_error_log__c>();
        userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
       
        isBatchProcessing = false;
        
        MPMIds = ApexPages.currentPage().getParameters().get('ID');
        if(!string.isBlank(MPMIds)){
            lstSelectedMPMIds = MPMIds.split(','); 
        }
        if(lstSelectedMPMIds != null && lstSelectedMPMIds.size() > 0)
            lstSelectedMPM = [Select Id,Name,MPM_Short_Desc__c,Production_Year__c,Abstract_EIDR__c,Status__c,Film_Color__c, Generic__c,MPM_Number__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r) from MPM__c where Id IN:lstSelectedMPMIds ];
        
        mpmScroller = (lstSelectedMPM!=null && lstSelectedMPM.size() > 10) ? true : false;
        
        allRightsGroup = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Rights__c.Rights_Group__c.getDescribe(); //picklist value of Rights group
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getLabel() != 'Worldwide')
                allRightsGroup.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        allChannels = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResultChannel =Rights__c.Channel__c.getDescribe(); //picklist value of Channel
        List<Schema.PicklistEntry> pleChannel = fieldResultChannel.getPicklistValues();
            
        for( Schema.PicklistEntry f : pleChannel)
        {
            //if(f.getLabel() != 'Hotel') - comment under ER-001170  Add PPV and Hotel to HE Profiles 
                allChannels.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        
        selectedRightsGroup = new list<SelectOption>();
        selectedRightsChannel = new list<SelectOption>();
    
    }
    
    public pageReference RequestRefresh(){
        
        /** Delete Rights error if present**/
        list<Request_Rights_error_log__c> rightsExceptionRecDelete= new list<Request_Rights_error_log__c>();
        rightsExceptionRecDelete=[select id from Request_Rights_error_log__c];
        if(rightsExceptionRecDelete.size() != 0){
            try{
                Database.DeleteResult[] saveResult = Database.delete(rightsExceptionRecDelete, false);
            }catch(exception e){
                system.debug('An Exception Occured' + e);
            }
        }
        
        Set<string> setGroupsAndchannel = new Set<string>();
        set<string> setChannel = new set<string>();
        
        set<string> dynamicOptions = new set<string>();
        Schema.DescribeFieldResult fieldResult = Rights__c.channel__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Boolean channelAll = false;    
        for( Schema.PicklistEntry picklistValue : fieldResult.getPicklistValues())
        {
            if(picklistValue.getValue() != 'All')
                dynamicOptions.add(picklistValue.getValue());
        } 
        
        set<string> setRightsGroup = new set<string>();
        Map<string,set<String>> mapRightsGroupCountry = new Map<string,set<String>>();
        
        for(SelectOption rightsGroup : selectedRightsGroup){
            setRightsGroup.add(rightsGroup.getValue());
        }
        
        for(Rights_Group__c locals : [Select id, Country__c, Country__r.Channel__c, Rights_Group__c from Rights_Group__c where Rights_Group__c IN: (setRightsGroup) AND Rights_Locale__c = True]){
            List<String> strChannel;
            if(locals.Country__r.Channel__c != null && locals.Country__r.Channel__c != ''){
                strChannel = ((locals.Country__r.Channel__c).split(';'));
                set<string> uniqueChannel = new set<string>();
                uniqueChannel.addAll(strChannel);
                if(mapRightsGroupCountry.containsKey(locals.Rights_Group__c)){
                    set<String> channel = mapRightsGroupCountry.get(locals.Rights_Group__c);
                    channel.addAll(uniqueChannel);
                    mapRightsGroupCountry.put(locals.Rights_Group__c,channel);
                }
                else{
                    mapRightsGroupCountry.put(locals.Rights_Group__c, uniqueChannel);
    
                }
            }            
        }
        
        for(string rightsGroup : mapRightsGroupCountry.keyset()){
            for(string countryChannel : mapRightsGroupCountry.get(rightsGroup)){
               for(SelectOption rightsChannel : selectedRightsChannel){
                    if(rightsChannel.getValue() == 'All'){
                        channelAll = true;
                        Break;
                    }
                    else{
                        if(countryChannel == rightsChannel.getValue()){
                            setGroupsAndchannel.add(rightsGroup+ '_'+rightsChannel.getValue());
                            break;
                        }
                    }
                    
                }
                if(channelAll){
                    setGroupsAndchannel = new Set<string>();
                    for(string channel: dynamicOptions){
                        
                        setGroupsAndchannel.add(rightsGroup+ '_'+channel);
                    }
                }
            }
            
        }
        
        Integer  threshold =1, MPMCount = 1, countryCount = 1, channelCount= 1;
        MPMCount = lstSelectedMPM.size();
        countryCount = selectedRightsGroup.size();
        channelCount = selectedRightsChannel.size();
        threshold = MPMCount * countryCount * channelCount;
       
        if(threshold > 300){            
            isBatchProcessing = true;
            WB_Batch_RightsRequestWizard batchRightsRequest = new WB_Batch_RightsRequestWizard(lstSelectedMPMIds, setGroupsAndchannel, objRights);
            database.executeBatch(batchRightsRequest, 200);
            return null;
        }
        else{
            isBatchProcessing = false;
            List<Rights__c> updateRightsLst =new List<Rights__c>();
            List<Rights__c> insertRightsLst =new List<Rights__c>();
            List<Rights__c> lstFinalRightsUpsert = new List<Rights__c>();
            
            for(MPM__c selectMPM : lstSelectedMPM){
                
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
                    // try{ 
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
                                RightsError.Reason__c = error.getMessage();
                                
                                lstRightsError.add(RightsError);
                            }
                        // }
                         
                     }
                     /*catch(Exception ex){
                         system.debug('Here is exception'+ex);
                     }*/
                 }
               
            if(lstRightsError != null && lstRightsError.size() > 0){
                insert lstRightsError;                
            }
            
            PageReference PageRef = new Pagereference('/apex/WB_RequestRights_Redirect');                   
            PageRef.setredirect(false);
             return pageRef;
            /*else{
                PageReference PageRef = new Pagereference('/apex/WB_Grid');
                Pageref.getParameters().put('al','true');
                Pageref.getParameters().put('obj','Rights__c');
                Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
                Pageref.getParameters().put('CF_QP_filterValue',userDetail.Rights_Batch_Id__c);
                Pageref.setRedirect(false);
                return pageRef;
            }*/
        
        }
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
    
    //CRRT Phase6: Added new feature to select all rigths group and select all channel
    public void selectAllRightsGroup(){
        if(isAllRightsGroupSelected){
            selectedRightsGroup.addall(allRightsGroup);
            selectedRightsGroup.sort();
            allRightsGroup.clear();
        }
        else if(!isAllRightsGroupSelected){
            allRightsGroup.addall(selectedRightsGroup);
            allRightsGroup.sort();
            selectedRightsGroup.clear();
        }
    }
    
    public void selectAllChannel(){
        if(isAllChannelSelected){
            selectedRightsChannel.addall(allChannels);
            selectedRightsChannel.sort();
            allChannels.clear();
        }
        else if(!isAllChannelSelected){
            allChannels.addall(selectedRightsChannel);
            allChannels.sort();
            selectedRightsChannel.clear();
        }
    }
    //End CRRT Phase6
    
}