public with sharing class WB_MpmReleasePlanExport{
    public list<Title__c> titleIds{get; set;}
    public list<Title__c> selectedTitle;
    public list<Rights__c> rightsList{get;set;}
    public boolean rightsDisplayBlock{get;set;}
    public string titleIdMPMs{get;set;}
    Public  list<String> lstTitleIdsnew;
    public list<MPM__c> exceptionMPMList{get;set;}
    public string exceptionMPMListName{get;set;}
    
    
     public WB_MpmReleasePlanExport(ApexPages.StandardSetController controller){
        String videoversion='';
        titleIdMPMs = ApexPages.currentPage().getParameters().get('ID');
        lstTitleIdsnew= new list<string>();
        if(titleIdMPMs!=null){
            lstTitleIdsnew = titleIdMPMs.split(',');         
        selectedTitle =[Select Name,MPM__c,Video_Version__c,MPM__r.Generic__c from Title__c where id IN:lstTitleIdsnew];
        if(selectedTitle.size()> 0)
			videoversion = selectedTitle[0].Video_Version__c;
        }
        
        list<string> MPMIds = new list<string>();
        if(selectedTitle.size()>0){
            for(Title__c title :selectedTitle){
                MPMIds.add(title.MPM__c);
            }
        }
        
        /* 
        Modified By: Preeti jha
        Summery: fields added in query to display on vf page and also sorted as ReleasePlanKey__c asc.
        */
		if(selectedTitle.size()>0){
			if(videoversion!=null && selectedTitle[0].MPM__r.Generic__c )
				rightsList = [SELECT id,name,Channel__c,MPM__c,MPM__r.Generic__c,MPM__r.MPM_Number__c,MPM_Short_Description__c,Notes__c,
				Rights_End__c,Rights_Start__c,Rights_Start_2__c,Rights_Start_3__c,Rights_Start_4__c,Rights_Start_5__c,Rights_End_2__c,
				Rights_End_3__c,Rights_End_4__c,Rights_End_5__c,Rights_Group__c,Status__c,Request_Refresh__c,Date_Last_Changed__c,
				MPM__r.Name,RT_Lifecycle__c,RecordType.Name,Title_MPM_Description__c,VV_MPM__c
				FROM Rights__c  WHERE Video_Version__c =:videoversion order by Key__c ASC]; //ER-000959 : RecordType.Name added in query
			else
				rightsList = [SELECT id,name,Channel__c,MPM__c,MPM__r.Generic__c,MPM__r.MPM_Number__c,MPM_Short_Description__c,Notes__c,
				Rights_End__c,Rights_Start__c,Rights_Start_2__c,Rights_Start_3__c,Rights_Start_4__c,Rights_Start_5__c,Rights_End_2__c,
				Rights_End_3__c,Rights_End_4__c,Rights_End_5__c,Rights_Group__c,Status__c,Request_Refresh__c,Date_Last_Changed__c,
				MPM__r.Name,RT_Lifecycle__c,RecordType.Name,Title_MPM_Description__c,VV_MPM__c
				FROM Rights__c  WHERE MPM__c IN: MPMIds order by Key__c ASC]; //ER-000959 : RecordType.Name added in query
        }
       //for MPMs whose rightdates are not present
        set<string> rightsList_mpm = new set<string>();
        for(Rights__c right : rightsList){
            rightsList_mpm.add(right.MPM__c);
        }
        set<string> excep_rightsList_mpm = new set<string>();
        for(string titlempm : MPMIds){
            if(rightsList_mpm.contains(titlempm)){
            }
            else if(!selectedTitle[0].MPM__r.Generic__c)   
            excep_rightsList_mpm.add(titlempm);
        }
        exceptionMPMList =[select Name from MPM__c where id IN:excep_rightsList_mpm];
        for(MPM__c exmpm :exceptionMPMList){
            if(exceptionMPMListName == null){
                exceptionMPMListName = exmpm.Name ;
            }
            else{
                exceptionMPMListName = exceptionMPMListName+','+exmpm.Name ;
            }
        }
        //Final display of Rights or error Msg
       if(rightsList.size() != 0 && rightsList != null && exceptionMPMListName==null ){
           rightsDisplayBlock=true;       
       }else if(rightsList != null && rightsList.size() != 0 ){
                rightsDisplayBlock=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Rights entries for the following MPMs-'+exceptionMPMListName));
        }   
        else{
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Rights entries for the MPMs of the selected Titles'));
                rightsDisplayBlock=false;
            }
     
     }
     
     public PageReference exportToExcel() {
          PageReference nextpage = new PageReference('/apex/WB_MpmReleasePlanExportExcel');
          return nextpage;
          
    }
    public PageReference getDisableExcel() {
        return null;
    }
    /*
    Method name: RequestRefresh() and batchIdGeneration()
    created by: Preeti Jha
    Requirment: CRRT Phase -4B, When Request refresh button is clicked then all rights of that perticular MPM should get Refreshed.
    */
   
    public pageReference RequestRefresh(){
        list<Rights__c> lstFinalRightsUpdate = new list<Rights__c>();
        list<Request_Rights_error_log__c> rightsExceptionRecDelete= new list<Request_Rights_error_log__c>();
        rightsExceptionRecDelete=[select id from Request_Rights_error_log__c limit 1000];
        if(rightsExceptionRecDelete.size() != 0){
            try{
                Database.DeleteResult[] saveResult = Database.delete(rightsExceptionRecDelete, false);
            }catch(exception e){
                system.debug('An Exception Occured' + e);
            }
        }
        
        if(rightsList != null && rightsList.size() > 0){
            list<Request_Rights_error_log__c> lstError = new list<Request_Rights_error_log__c>();
            list<Rights__c> lstRightUpdate = new list<Rights__c>();
            for(Rights__c rights : rightsList){
                //avoid MPM starting with 1 from request refresh
                if(!(rights.MPM__r.MPM_Number__c).startsWith('2')){
                    Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                    RightsError.MPM__c = rights.MPM__r.Name;
                    RightsError.Reason__c = 'You can only submit a rights request for non generic MPM starting with \'2\'';
                    lstError.add(RightsError);
                    Break;
                }
                 //Rights having Channel as Hotal or All and if Rights group is Worldwide then Refresh should not happen. 
                if(!rights.MPM__r.Generic__c && !rights.Request_Refresh__c && rights.Channel__c !='Hotel' && rights.Channel__c !='All' && rights.Rights_Group__c  !='Worldwide')
                {
                    rights.Request_Refresh__c = true;
                    lstRightUpdate.add(rights);
                }
                else if(rights.MPM__r.Generic__c){
                    Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                    RightsError.MPM__c = rights.MPM__r.Name;
                    RightsError.Request_Refresh__c =rights.Request_Refresh__c;
                    RightsError.Rights_End_1__c =rights.Rights_End__c;
                    RightsError.Rights_Id__c =rights.Name;
                    RightsError.Rights_Start_1__c =rights.Rights_Start__c;
                    RightsError.Status__c =rights.Status__c;
                    RightsError.Channel__c = rights.Channel__c;
                    RightsError.Rights_Group__c = rights.Rights_Group__c;
                    RightsError.Reason__c = 'Generic MPM '+rights.MPM__c+' is selected. Request refresh cannot be initiated for generic MPMs. ';
                    
                    lstError.add(RightsError);
                }
            }
            if(lstRightUpdate != null && lstRightUpdate.size() > 0){
                try{ 
                    lstFinalRightsUpdate = batchIdGeneration(lstRightUpdate);
                    
                    Database.SaveResult[] saveResult  = Database.update(lstFinalRightsUpdate, false);
                     String errMessage = '';
                     for(Integer i=0 ; i < saveResult.size() ; i++){
                        if(!saveResult[i].isSuccess()){
                            Database.Error error = saveResult[i].getErrors().get(0);
                            Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                            RightsError.MPM__c = lstRightUpdate[i].MPM__r.Name;
                            RightsError.Request_Refresh__c =lstRightUpdate[i].Request_Refresh__c;
                            RightsError.Rights_End_1__c =lstRightUpdate[i].Rights_End__c;
                            RightsError.Rights_Id__c =lstRightUpdate[i].Name;
                            RightsError.Rights_Start_1__c =lstRightUpdate[i].Rights_Start__c;
                            RightsError.Status__c =lstRightUpdate[i].Status__c;
                            RightsError.Channel__c = lstRightUpdate[i].Channel__c;
                            RightsError.Rights_Group__c = lstRightUpdate[i].Rights_Group__c;
                            RightsError.Reason__c = error.getMessage();
                            
                            lstError.add(RightsError);
                        }
                     }
                     
                 }
                 catch(Exception ex){
                     system.debug('Here is exception'+ex);
                 }
            }
            if(lstError!=null && lstError.size() > 0)
            {
                insert lstError;
                PageReference PageRef = new Pagereference('/apex/WB_RequestRights_Redirect');                   
                PageRef.setredirect(false);
                return PageRef;
            }
        }
        return null;
    }
    
     /**batch id  creation method **/
    public list<Rights__c> batchIdGeneration(list<Rights__c> list_TobeUpdate){
        
       user userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
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