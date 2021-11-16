global class WB_Batch_Update_LocalTitle_Owner implements Database.Batchable<sObject>,schedulable,Database.Stateful{
    
    set<Id> idSet = new set<Id>();
    global String query = null; 
    global  WB_Batch_Update_LocalTitle_Owner(){
        query='select id,Title__c,CountryF__c,External_Company__c,Country__c,OwnerId,CreatedById,DisplayStudioOverride__c,IsDisplayStudioUpdated__c,Title__r.IsDisplayStudioUpdated__c,Title__r.DisplayStudio__c,LocalDisplayStudio__c,Title_Physical_Planning__c,Title_Digital_Planning__c,Country__r.Turner_Override__c,Country__r.HBO_Override__c from Local_Title__c where (IsDisplayStudioUpdated__c=True OR Title__r.IsDisplayStudioUpdated__c=True) AND (HBO_Owner__c != null OR Turner_Owner__c != null) AND External_Company__c = Null';
    }
    global void execute (SchedulableContext ctx){
        Database.executeBatch(new WB_Batch_Update_LocalTitle_Owner());    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Local_Title__c> scope){
        List<Local_Title__c> ltToUpdate = new List<Local_Title__c>();
        Set<Id> tileToUpdate= new Set<Id>();
        if(scope != null && !scope.isEmpty()){
            for (Local_Title__c Locltitle : scope) {
                system.debug('Local Title : '+Locltitle.ID+'-------'+Locltitle.CountryF__c+'-------------------------'+Locltitle.OwnerId);
                idSet.add(Locltitle.id);         
                if(Locltitle.Title__r.IsDisplayStudioUpdated__c == True ){
                    tileToUpdate.add(Locltitle.Title__c);
                    System.debug('inside 1if condition');
                    
                } 
                else
                   // ltToUpdate.add(Locltitle);  
                Locltitle.IsDisplayStudioUpdated__c=false;
            }
            if(scope != null && !scope.isEmpty()){
                WB_LocalTitleTriggerHandler.setQueueToOwner(scope); 
            }
            Map<Id,String> ltErrorMap = new Map<Id,String>();
            if(scope != null && !scope.isEmpty()){
                
            //    WB_LocalTitleTriggerHandler.recursiveUpdate = true;
                Database.saveResult[] saveResult  = Database.update(scope,false);
            //    WB_LocalTitleTriggerHandler.recursiveUpdate = false;
                System.debug('saveResult'+saveResult); 
            if(saveResult != null && saveResult.size()>0){
                for(Integer index=0;index<saveResult.size();index++){
                    Database.SaveResult updateResult = saveResult[index]; 
                    System.debug('updateResult.isSuccess()'+updateResult.isSuccess());
                    System.debug('!Test.isRunningTest()'+!Test.isRunningTest());
                   // if(!Test.isRunningTest()){
                    if(!updateResult.isSuccess() && !Test.isRunningTest()){
                        String errorMessage = '';
                        for(Database.Error err : updateResult.getErrors()) {
                            errorMessage += err.getMessage();
                        }
                        system.debug('errorMessage : '+errorMessage);
                       Id ldId = updateResult.getId();
                        if(!ltErrorMap.containsKey(ldId))
                            ltErrorMap.put(ldId, errorMessage);
                    }
               // }
                }
            }
            }
            if(scope.size() != null && scope.size() > 0){
                createErrorLog(ltErrorMap.keySet(),ltErrorMap);
            }
            
            
            List<Title__c> listTitle = new List<Title__c>();
            for(Title__c titleobj:[select id,IsDisplayStudioUpdated__c from Title__c where id IN:tileToUpdate]){
                titleobj.IsDisplayStudioUpdated__c=false;
                listTitle.add(titleobj);  
            }
            Map<Id,String> ttErrorMap = new Map<Id,String>();
            if(listTitle != null && !listTitle.isEmpty()){
            Database.saveResult[] saveResult2  = Database.update(listTitle);
            if(saveResult2 != null && saveResult2.size()>0){
                for(Integer index=0;index<saveResult2.size();index++){
                    Database.SaveResult updateResult = saveResult2[index]; 
                    if(!updateResult.isSuccess()){
                        String errorMessage = '';                      
                        for(Database.Error err : updateResult.getErrors()) {
                            errorMessage += err.getMessage();
                        }
                       Id ttId = updateResult.getId();
                        if(!ttErrorMap.containsKey(ttId))
                            ttErrorMap.put(ttId, errorMessage);
                    }
                }
            }
            }
            if(listTitle.size() != null && listTitle.size() > 0){
                createErrorLog(ttErrorMap.keySet(),ltErrorMap);
            }
            System.debug('Below update');
            System.debug('idSet'+idSet);    
        }
    }
    global void finish(Database.BatchableContext bc){       
        if(idSet != null && idSet.size()>0){
            WB_Batch_Update_ReleasePlan_Owner bt = new WB_Batch_Update_ReleasePlan_Owner(idSet);
            dataBase.ExecuteBatch(bt); 
        }
    }
 /*   public void createErrorLog(List<Local_Title__c> localtitleList,Map<Id,String> ltErrorMap){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(localtitleList != null && localtitleList.size()>0){
             for(Local_Title__c lt : localtitleList){
                 if(ltErrorMap.get(lt.Id) != null){
                     WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = lt.Id;
                     errorLogInstance.errorCategory = '';
                     errorLogInstance.errorDescription = ltErrorMap.get(lt.Id).left(252);
                     errorLogInstance.errorDescriptionLong = ltErrorMap.get(lt.Id).left(32000); 
                     errorLogInstance.objectName = lt.Id.getSObjectType().getDescribe().getName();
                    // errorLogInstance.account = lt.Account__c;
                     errorLogs.add(errorLogInstance);
                 }
                 
             }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }       
    }  */
        public void createErrorLog(Set<Id> titleORltId,Map<Id,String> ttErrorMap){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(titleORltId != null && titleORltId.size()>0){
             for(Id tt : titleORltId){
                 if(ttErrorMap.get(tt) != null){
                     WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = tt;
                     errorLogInstance.errorCategory = 'Local Tilte Owner Assignment Batch Error';
                     errorLogInstance.errorDescription = ttErrorMap.get(tt).left(252);
                     errorLogInstance.errorDescriptionLong = ttErrorMap.get(tt).left(32000); 
                     errorLogInstance.objectName = 'Local Data';
                    // errorLogInstance.account = lt.Account__c;
                     errorLogs.add(errorLogInstance);
                 }
                 
             }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }
        }
}