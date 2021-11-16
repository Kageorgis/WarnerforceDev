public with sharing class WB_View_Rights {

    public string titleId{get;set;}
    public Id idListMPM;
    public list<Rights__c> rightsList{get;set;}
    public boolean rightsDisplayBlock{get;set;}
   
    public list<Title__c> title = new list<Title__c>();
    public String titleName;
    public boolean disableExcel{get;set;} 
    public list<Title__c> titleDetail = new list<Title__c>();
    public String mpmName;
    public Title__c titleInfo{get;set;}
    public Boolean isMPMGeneric=false;
    
    public Integer showRecords{get; set;}
    public Boolean showViewAllLink{get; set;}
    public string errorMsg{get; set;}
    public string callingFrom{get; set;}
    /*ER-1660
    Updated on - 23 Jan 2018*/
    private Id id;
 
     public WB_View_Rights(ApexPages.StandardController controller) {
       this.titleInfo = (Title__c)controller.getRecord();
       id = controller.getRecord().Id;
       showRecords = 10;
       showViewAllLink = true;
     }

     public PageReference forwardToListController() {
        PageReference pr = Page.WB_ViewRights_On_Title;
        pr.getParameters().put('id', id);
        return pr;
    }
    /*END Of ER-1660*/
    public WB_View_Rights(ApexPages.StandardSetController controller) {
       
        this.titleInfo= (Title__c)controller.getRecord();
        titleId = ApexPages.currentPage().getParameters().get('id');
        callingFrom = ApexPages.currentPage().getParameters().get('CallingFrom');
        //titleId  = 'a02J000000DDBAX';
        //titleName=[SELECT id,name,MPM__c,MPM__r.name,MPM__r.MPM_Number__c,Video_Version__c FROM Title__c WHERE id =: titleId].Name;
        titleDetail=[SELECT id,name,MPM__c,MPM__r.name,MPM__r.MPM_Number__c,Video_Version__c,MPM__r.Generic__c FROM Title__c WHERE id =: titleId];
        this.titleInfo = titleDetail[0];
        isMPMGeneric = titleDetail[0].MPM__r.Generic__c; //True if MPM is generic
        
        mpmName= titleDetail[0].MPM__r.name;
        titleName= titleDetail[0].Name;
        String videoversion = titleDetail[0].Video_Version__c ;
        Id idListMPM;
        idListMPM=[SELECT id,name,MPM__c,MPM__r.name,MPM__r.MPM_Number__c FROM Title__c WHERE id =: titleId].MPM__c;
        
        
        /* 
        Modified By: Preeti jha
        Summery: Fields added in query to display on vf page and also sorted as ReleasePlanKey asc.
        */
        
        if(idListMPM != null){
            if(isMPMGeneric)//if generic fetch VBOM rights else fetch MPM rights
               rightsList = [SELECT id,name,Channel__c,MPM__c,MPM__r.Generic__c,MPM__r.MPM_Number__c,MPM_Short_Description__c,Notes__c,
               Rights_End__c,Rights_Start__c,Rights_Start_2__c,Rights_Start_3__c,Rights_Start_4__c,Rights_Start_5__c,Rights_End_2__c,
               Rights_End_3__c,Rights_End_4__c,Rights_End_5__c,Rights_Group__c,Status__c,Date_Last_Changed__c,Request_Refresh__c,
               MPM__r.Name, RT_Lifecycle__c,RecordType.Name, Video_Version__c,Title_MPM_Description__c,VV_MPM__c
                                 FROM Rights__c
                                 WHERE (Video_Version__c =:videoversion)
                                 ORDER BY Key__c ASC]; //ER-000959 : RecordType.Name added in query
            else
                rightsList = [SELECT id,name,Channel__c,MPM__c,MPM__r.Generic__c,MPM__r.MPM_Number__c,MPM_Short_Description__c,Notes__c,
               Rights_End__c,Rights_Start__c,Rights_Start_2__c,Rights_Start_3__c,Rights_Start_4__c,Rights_Start_5__c,Rights_End_2__c,
               Rights_End_3__c,Rights_End_4__c,Rights_End_5__c,Rights_Group__c,Status__c,Date_Last_Changed__c,Request_Refresh__c,
               MPM__r.Name, RT_Lifecycle__c,RecordType.Name, Video_Version__c,Title_MPM_Description__c,VV_MPM__c
                                 FROM Rights__c
                                 WHERE (MPM__c=:idListMPM )
                                 ORDER BY Key__c ASC]; //ER-000959 : RecordType.Name added in query
        
                                          
        }
        
        if(rightsList != null && rightsList.size() != 0 ){
                rightsDisplayBlock=True;
                showRecords = (callingFrom == 'viewall') ? rightsList.size() : 10;
                showViewAllLink = (showRecords >= rightsList.size()) ? false : true;
        }   
        else{
                //ER-001648 Enabled view rights and title for lightning
                if(!isMPMGeneric){
                    errorMsg = System.Label.NoRightsForMPM+' "'+mpmName+ '" for the title "' + titleName + '"';
                }else{
                    errorMsg = 'No entries for rights found for '+' "'+videoversion + '" for the title "' + titleName + '"';
                }
            
                //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,System.Label.NoRightsForMPM+' "'+mpmName+ '" for the title "' + titleName + '"'  ));
                 //No Rights entries for the MPM of the Title
                //else
                //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No entries for rights found for '+' "'+videoversion + '" for the title "' + titleName + '"'  ));
                
                rightsDisplayBlock=false;
                showRecords = 0;
                showViewAllLink = false;
        } 
    }
    
    public PageReference exportToExcel() {
      Id id = System.currentPageReference().getParameters().get('id');
      PageReference nextpage = new PageReference('/apex/WB_RightsExportToExcel');
      nextpage.setRedirect(false);
      return nextpage;
      
    }
    /*
    Method name: RequestRefresh
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
                 if(!isMPMGeneric && !(rights.MPM__r.MPM_Number__c).startsWith('2')){
                    Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c();
                    RightsError.MPM__c = rights.MPM__r.Name;
                    RightsError.Reason__c = 'You can only submit a rights request for non generic MPM starting with \'2\'';
                    lstError.add(RightsError);
                    Break;
                }
                //Rights having Channel as Hotal or All and if Rights group is Worldwide then Refresh should not happen. 
                //else if(!rights.MPM__r.Generic__c && !rights.Request_Refresh__c && rights.Channel__c !='Hotel' && rights.Channel__c !='All' && rights.Rights_Group__c  !='Worldwide')
                else if(!isMPMGeneric && !rights.MPM__r.Generic__c && !rights.Request_Refresh__c && rights.Channel__c !='All' && rights.Rights_Group__c  !='Worldwide') // removed channel hotel condition under ER-001170  Add PPV and Hotel to HE Profiles
                 {
                    rights.Request_Refresh__c = true;
                    lstRightUpdate.add(rights);
                }
                else if(!isMPMGeneric && rights.MPM__r.Generic__c){
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
                    Break;
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
                            if(!isMPMGeneric)
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
                
                PageReference PageRef = new Pagereference('/apex/WB_RequestRights_Redirect?titleId='+titleInfo.id+'&titleName='+titleInfo.name);                   
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
    
    public PageReference viewAllRightsRecords(){
        PageReference PageRef = new Pagereference('/apex/wb_viewrights_on_title?id='+titleInfo.id+'&CallingFrom=viewall');
        PageRef.setredirect(true);
        return PageRef;
    }
}