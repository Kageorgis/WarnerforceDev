/**
 * Written by: Astha
 * Description: This controller is used for Rights Request Refresh functionality for TITLE and VBOMs.
 * Project: EBR <!--ER-000959-->
**/

public class WB_Request_Refresh_Title_Controller {
    public List<Title__c> lstSelectedTitle{get;set;}
    public List<titleMPMWrapper> lstSelectedTitleMPM {get;set;}
    public SelectOption[] allRightsGroup{get;set;}
    public SelectOption[] allChannels{get; set;}
    public Rights__c objRights {get;set;}
    public boolean isBatchProcessing{get;set;}
    public boolean mpmScrollerTitle{get;set;}
    public String AllIds;
    public List<string> lstSelectedMPMIds;
    public List<String> lstselectedIDs;
    public boolean isAllRightsGroupSelected{get;set;}
    public boolean isAllChannelSelected{get;set;}    
    public map<ID,String> maptitleIDandMPM = new map<ID,String>(); // map of title ID and related MPM number
    public map<ID,Set<ID>> maptitleIDListTBOMID = new map<ID,Set<ID>>(); // map of title ID and list of related TBOM ID 
    public map<ID,String> mapTBOMIDandMPM = new map<ID,String>(); // map of TBOM and related MPM number
    public set<String> setAllMPMIDs = new set<String>();    //set all mpm numbers   
    public map<String,MPM__c> mapMPMrecords = new map<String,MPM__c>(); // map of mpm number and mpm record 
    public Integer parentMPMCount = 0;
    public map<String,Rights__c> mapKeyRightsToBeInserted = new map<String,Rights__c>();
    public map<String,Rights__c> mapKeyRightsToBeUpdated = new map<String,Rights__c>();
    user userDetail;
    public List<titleMPMWrapper> lstUniqueTitleMPM{get;set;} //ER-000959
    public Map<String,titleMPMWrapper> mapSelectedTitleMPM {get;set;}
    list<Request_Rights_error_log__c> lstRightsError = new list<Request_Rights_error_log__c>();
        
    
    //Multi select
    public SelectOption[] selectedRightsGroup {get; set;}
    Public SelectOption[] selectedRightsChannel {get; set;}
    
    public WB_Request_Refresh_Title_Controller (){
        lstUniqueTitleMPM = new List<titleMPMWrapper>();
        isAllRightsGroupSelected = false;
        isAllChannelSelected = false;
        objRights = new Rights__c();
        lstSelectedTitleMPM = new List<titleMPMWrapper>();
        lstSelectedMPMIds = new list<string>();
        lstselectedIDs = new list<String>();
        userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
        mapSelectedTitleMPM = new Map<String,titleMPMWrapper>();
        isBatchProcessing = false;
        
        AllIds = ApexPages.currentPage().getParameters().get('ID');
        if(!string.isBlank(AllIds)){
            lstselectedIDs = AllIds.split(','); 
        }
        
        if(lstselectedIDs != null && lstselectedIDs.size() > 0)
            lstSelectedTitle = [Select Id,Name,Status__c,Film_Color_formula__c,Video_Version__c ,Production_Year_formula__c,MPM__r.Generic__c,MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r),
            (Select ID, Name, MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c, MPM__r.Generic__c,Title__r.Video_Version__c FROM Title_BOM__r where BOM_Type__c='VBOM') from Title__c where Id IN:lstselectedIDs];
        
        mpmScrollerTitle = (lstSelectedTitle!=null && lstSelectedTitle.size() > 10) ? true : false;
        
        //Querying on Title records and related title-BOMs and Rights records 
        for(Title__c title : lstSelectedTitle){
            
            lstSelectedTitleMPM.add(new titleMPMWrapper(title));
            if(title.MPM__r.ID!=null){
                //lstSelectedTitleMPM.add(new titleMPMWrapper(title.MPM__r.ID, TRUE, title.MPM__r.Name, title.MPM__r.MPM_Short_Desc__c,'MPM', title.MPM__r.Production_Year__c, title.MPM__r.Status__c,
                //title.MPM__r.Generic__c,title.MPM__r.Film_Color__c,title.Video_Version__c,title.id));
                parentMPMCount++;
                maptitleIDandMPM.put(title.id,title.MPM__r.Name);
                setAllMPMIDs.add(title.MPM__r.ID);
            }            
            for(Title_BOM__c titleBOM:title.Title_BOM__r){
                lstSelectedTitleMPM.add(new titleMPMWrapper(titleBOM));
                mapTBOMIDandMPM.put(titleBOM.ID,titleBOM.MPM__r.Name);
                setAllMPMIDs.add(titleBOM.MPM__r.ID);
                
                if(maptitleIDListTBOMID.containsKey(title.ID))
                maptitleIDListTBOMID.get(title.ID).add(titleBOM.ID);
                else{   
                    Set<ID> TBOMIds = new Set<ID>();
                    TBOMIds.add(titleBOM.ID);
                    maptitleIDListTBOMID.put(title.ID,TBOMIds); 
                }
            }
        }
        //ER-000959 :start
        for(titleMPMWrapper wrapper :lstSelectedTitleMPM){
            
            String key = wrapper.VideoVersion+'_'+wrapper.vvmpmID;
            mapSelectedTitleMPM.put(key,wrapper);   
        }
        lstUniqueTitleMPM=mapSelectedTitleMPM.values();
        //ER-000959 : end
        
        //Querying on MPM to fetch MPM and related Rights
        if(setAllMPMIDs != null && setAllMPMIDs.size() > 0){
            for(MPM__c mpmRec:[Select Id,Name,MPM_Short_Desc__c,Production_Year__c,Abstract_EIDR__c,Status__c,Film_Color__c, Generic__c,MPM_Number__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r)
            from MPM__c where Id IN:setAllMPMIDs ]){
                    mapMPMrecords.put(mpmRec.Name,mpmRec);
            }
        }
        
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
            //if(f.getLabel() != 'Hotel') // comment under ER-001170  Add PPV and Hotel to HE Profiles
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
        
        Integer  threshold =1, TitleMPMCount = 1, countryCount = 1, channelCount= 1;
        TitleMPMCount = lstSelectedTitleMPM.size()+parentMPMCount;//ER-000959:30-04-2018
        countryCount = selectedRightsGroup.size();
        channelCount = selectedRightsChannel.size();
        threshold = TitleMPMCount * countryCount * channelCount;
        if(threshold > 300){            
            isBatchProcessing = true;
         //  WB_Batch_VBOMRightsRequestWizard batchRightsRequest = new WB_Batch_VBOMRightsRequestWizard(lstSelectedMPMIds, setGroupsAndchannel, objRights);
             WB_Batch_VBOMRightsRequestWizard batchRightsRequest = new WB_Batch_VBOMRightsRequestWizard(lstSelectedTitle, mapMPMrecords, maptitleIDandMPM,
            maptitleIDListTBOMID, mapTBOMIDandMPM, setGroupsAndchannel, objRights);
           database.executeBatch(batchRightsRequest, 200);
            return null;
        }
        else{
            isBatchProcessing = false;
            List<Rights__c> updateRightsLst =new List<Rights__c>();
            List<Rights__c> insertRightsLst =new List<Rights__c>();
            List<Rights__c> lstFinalRightsUpsert = new List<Rights__c>();
            
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
                                        //newRights.Title__c = titleRec.Id;
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
                                        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                        RightsError.MPM__c = selectMPM.Name;
                                        RightsError.Title__c = titleRec.name;
                                        RightsError.Reason__c = 'Request refresh for Component MPM-'+ selectMPM.Name +' cannot be initiated, as it is generic.';
                                        lstRightsError.add(RightsError);
                                        flag = false;                                   
                                    }
                                    else if(!(selectMPM.MPM_Number__c).startsWith('2')){
                                        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                        RightsError.MPM__c = selectMPM.Name;
                                        RightsError.Title__c = titleRec.name;
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
                                                    //newRights.Title__c = titleRec.Id;
                                                    Id recordTypeId = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
                                                    newRights.RecordTypeId = recordTypeId;
                                                    insertRightsLst.add(newRights);
                                            }
                                        }
                                    }
                                }
                            }
                            finalflag = finalflag||flag; //finalflag: will be set to true if even a single MPM is generic & flag: will be set to true for non-generic MPM. 
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
                            RightsError.Title__c = titleRec.name;
                            RightsError.Reason__c = 'WARNING: There are no component MPMs present for the title- '+titleRec.name;
                            lstRightsError.add(RightsError);
                        }
                     }
                    else{
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no Generic MPM related to this title'));
                        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();                        
                        RightsError.Title__c = titleRec.name;
                        RightsError.Reason__c = 'There are no non-Generic MPM (component/parent) related to the title- '+titleRec.name;
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
                    // try{ 
                        Database.UpsertResult[] saveResult  = Database.upsert(lstFinalRights, false);
                         String errMessage = '';
                         for(Integer i=0 ; i < saveResult.size() ; i++){
                            if(!saveResult[i].isSuccess()){
                                Database.Error error = saveResult[i].getErrors().get(0);
                                Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                                //RightsError.MPM__c = lstFinalRights[i].MPM__r.Name;
                                RightsError.Title__c= lstFinalRights[i].Title__r.Name;
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
    
    public class titleMPMWrapper{
        public ID vvmpmID{ get; set; }
        public String VideoVersion { get; set; }
        public boolean isLink{get;set;}
        public String Name {get;set;}
        public String description{ get; set; }
        public String recordTypeName{ get; set; }
        public String ProductionYear{get;set;}
        public String status { get; set; }
        public string FilmColor{ get; set; }
        public boolean generic{ get; set; }
        public String VideoVersionId {get;set;}
        
        public titleMPMWrapper(Title__c titleRec){
            vvmpmID = titleRec.Id;
            VideoVersion=titleRec.Video_Version__c;
            isLink=false;
            Name=titleRec.Video_Version__c;
            VideoVersionId = titleRec.id;
            description=titleRec.Name;
            recordTypeName='VBOM';
            ProductionYear=titleRec.Production_Year_formula__c;
            status=titleRec.Status__c;
            FilmColor=titleRec.Film_Color_formula__c;
            generic=titleRec.MPM__r.Generic__c;
        }
        public titleMPMWrapper(Title_BOM__c titleBOM){
            vvmpmID = titleBOM.MPM__r.ID;
            VideoVersion=titleBOM.Title__r.Video_Version__c;
            isLink=true;
            Name=titleBOM.MPM__r.Name;
            VideoVersionId = titleBOM.Title__r.id;
            description=titleBOM.MPM__r.MPM_Short_Desc__c;
            recordTypeName='MPM';
            ProductionYear=titleBOM.MPM__r.Production_Year__c;
            status=titleBOM.MPM__r.Status__c ;
            FilmColor=titleBOM.MPM__r.Film_Color__c;
            generic=titleBOM.MPM__r.Generic__c;
        }
    }
}