global class WB_Batch_Update_ReleasePlan_Owner implements Database.Batchable<sObject>,Database.Stateful{
    
    set<Id> idSet1 = new set<Id>();
    set<Id> idSetRPs = new set<Id>();
    global String query = null; 
    global  WB_Batch_Update_ReleasePlan_Owner(set<Id> idSet){
        idSet1=idSet;    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('inside start');
        query='select id,OwnerId,CreatedById,Country_Lookup__c,Country_Formula__c,Local_Title__c,Title__c,Channel__c from Commercial_Avail__c  where Local_Title__c IN:idSet1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Commercial_Avail__c> scope){
        //set<Id> idSet = new set<Id>();
        System.debug('Inside release Plan scope'+scope);
         if(scope != null && !scope.isEmpty()){
        WB_CheckingDateOverlapController.setQueueToOwner(scope);
         System.debug('Inside release Plan scope'+scope);    
        List<Commercial_Avail__c> rp= new List<Commercial_Avail__c>();
  /*      for (Commercial_Avail__c  ReleasePlan : scope) {
          //  rp.add(ReleasePlan);
            idSetRPs.add(ReleasePlan.id);
          //  ReleasePlan.IsCountryUpdated__c=false;
        }  */
             Map<Id,String> rpErrorMap = new Map<Id,String>();
             if(scope != null && !scope.isEmpty()){
             Database.saveResult[] saveResult  = Database.update(scope,false);
            if(saveResult != null && saveResult.size()>0){
                for(Integer index=0;index<saveResult.size();index++){
                    Database.SaveResult updateResult = saveResult[index]; 
                    if(!updateResult.isSuccess()){
                        
                        String errorMessage = '';
                        for(Database.Error err : updateResult.getErrors()) {
                            errorMessage += err.getMessage();
                        }
                        System.debug('errorMessage'+errorMessage);
                        Id rpId = updateResult.getId();
                        System.debug('rpId'+rpId);
                        if(!rpErrorMap.containsKey(rpId))
                            rpErrorMap.put(rpId, errorMessage);
                    }
                }
            }
         }
            if(scope.size() != null && scope.size() > 0){
                createErrorLog(rpErrorMap.keySet(),rpErrorMap);
            }
        //update scope;
        }
    }
    global void finish(Database.BatchableContext bc){
        System.debug('inside finish of RP');
        if(idSet1 != null && idSet1.size()>0){
        WB_Batch_Update_ClientAvail_Owner bt= new WB_Batch_Update_ClientAvail_Owner(idSet1);
        database.ExecuteBatch(bt);   
        }
    }
    public void createErrorLog(Set<Id> rpId,Map<Id,String> ttErrorMap){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(rpId != null && rpId.size()>0){
             for(Id rp : rpId){
                 if(ttErrorMap.get(rp) != null){
                     WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = rp;
                     errorLogInstance.errorCategory = 'Release Plan Owner Assignment Batch Error';
                     errorLogInstance.errorDescription = ttErrorMap.get(rp).left(252);
                     errorLogInstance.errorDescriptionLong = ttErrorMap.get(rp).left(32000); 
                     errorLogInstance.objectName = 'Release Plan';
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