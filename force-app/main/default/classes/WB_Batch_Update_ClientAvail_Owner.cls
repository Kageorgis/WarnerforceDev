global class WB_Batch_Update_ClientAvail_Owner implements Database.Batchable<sObject>,Database.Stateful{
    
    set<Id> idSet1 = new set<Id>();
    global String query = null; 
    global  WB_Batch_Update_ClientAvail_Owner(set<Id> idSet){
        idSet1=idSet;
        
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Inside Client Avail');
        System.debug('idSet1'+idSet1);
        query='select id,OwnerId,CreatedById,Release_Plan_Country__c,Local_Title__c,Commercial_Avail__c,Title__c,Title_Physical_Planning__c,Title_Digital_Planning__c from Client_Avail__c  where Local_Title__c IN:idSet1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Client_Avail__c> scope){
        // set<Id> idSet = new set<Id>();
        if(scope != null && !scope.isEmpty()){
        System.debug('Inside Client Avail scope'+scope);
        WB_TriggerHandlerDateOverlapClientAvail.assignOwner(scope);
        Map<Id,String> caErrorMap = new Map<Id,String>();
        if(scope != null && !scope.isEmpty()){
           // Database.update(scope);
            System.debug('scope'+scope);
            
            Database.saveResult[] saveResult  = Database.update(scope,false);
            System.debug('saveResult'+saveResult);
            if(saveResult != null && saveResult.size()>0){
                for(Integer index=0;index<saveResult.size();index++){
                    System.debug('Inside for loop');
                    System.debug('saveResult[index]'+saveResult[index]);
                    Database.SaveResult updateResult = saveResult[index]; 
                    System.debug('!updateResult.isSuccess()'+!updateResult.isSuccess());
                    if(!updateResult.isSuccess()){
                        System.debug('Inside Error');
                        String errorMessage = '';
                        for(Database.Error err : updateResult.getErrors()){
                            errorMessage += err.getMessage();
                            System.debug('errorMessage'+errorMessage);
                        }
                        
                       Id caId = updateResult.getId();
                        if(!caErrorMap.containsKey(caId))
                            caErrorMap.put(caId, errorMessage);
                    }
                }
            }
            if(scope.size() != null && scope.size() > 0){
                createErrorLog(caErrorMap.keySet(),caErrorMap);
            }
        }
      }
    }
    global void finish(Database.BatchableContext bc){
        System.debug('inside finish of CA');
    }
    public void createErrorLog(Set<Id> caId,Map<Id,String> ttErrorMap){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(caId != null && caId.size()>0){
             for(Id ca : caId){
                 if(ttErrorMap.get(ca) != null){
                     WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = ca;
                     errorLogInstance.errorCategory = 'Client Avail Owner Assignment Batch Error';
                     errorLogInstance.errorDescription = ttErrorMap.get(ca).left(252);
                     errorLogInstance.errorDescriptionLong = ttErrorMap.get(ca).left(32000); 
                     errorLogInstance.objectName = 'Client Avail';
                    // errorLogInstance.account = lt.Account__c;
                     errorLogs.add(errorLogInstance);
                 }
                 
             }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            System.debug('inside error logs of CA'); 
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }
        }
    
}