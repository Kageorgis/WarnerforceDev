global class WB_Batch_LocalData_MA_Update implements Schedulable,Database.Batchable<ClientAvailCountWrapper>,Database.Stateful{
    
    String accountName = 'Movies Anywhere';
    public static final String STATUS_CONF = 'Confirmed';
    public static final String STATUS_TENTVE = 'Tentative';
    
    List<ClientAvailCountWrapper> aggrResultWrapperList = null;
    
    /* Start ******** Scheduler Methods************/ 
    global WB_Batch_LocalData_MA_Update(){
        
    }
    
    @ReadOnly 
    global void execute (SchedulableContext ctx){
        List<Agreement__c> storefrontList = [Select Id,Name From Agreement__c where Account__r.Name = :accountName and Account__r.RecordType.Name = 'Digital Client'];
        List<AggregateResult> aggrResultList = [Select Local_Title__r.Id,Status__c,count(id) From Client_Avail__c  Where Storefront__c in :storefrontList and Release_Plan_Channel__c = 'EST' group by Local_Title__r.Id,Status__c];
        
        Map<String,ClientAvailCountWrapper> aggResultMap = new Map<String,ClientAvailCountWrapper>();
        for(AggregateResult aggResult:aggrResultList){
            String localDataId = (String)aggResult.get('Id');
                
            if(aggResultMap.get(localDataId) == null){
                aggResultMap.put(localDataId,new ClientAvailCountWrapper(localDataId)); 
            }
            
            aggResultMap.get(localDataId).populateStatusCount(aggResult.get('Status__c'),aggResult.get('expr0'));
        }
         
        Database.executeBatch(new WB_Batch_LocalData_MA_Update(aggResultMap.values()));     
    }
    
    /* End ******* Scheduler Methods************ */
    
    /* Start ******** Batch Methods************/ 
    global WB_Batch_LocalData_MA_Update(List<ClientAvailCountWrapper> aggrResultWrapperList){
        this.aggrResultWrapperList = aggrResultWrapperList;
        if(this.aggrResultWrapperList == null)
            aggrResultWrapperList = new List<ClientAvailCountWrapper>();
    }
    
    global Iterable<ClientAvailCountWrapper> start(Database.BatchableContext BC){
        System.debug('In Start Method');
        return  aggrResultWrapperList;
    }

    global void execute(Database.BatchableContext BC, List<ClientAvailCountWrapper> scope){
        System.debug('In Execute Method');
        List<Local_Title__c> finalUpdateList = new List<Local_Title__c>();
        
        List<String> localDataIds = new List<String>();
        for(ClientAvailCountWrapper wrapper:scope){
            localDataIds.add(wrapper.localDataId);  
        }
        
        Map<Id,Local_Title__c> localDataMap = new Map<Id,Local_Title__c>([Select Id,Edit_EIDR_2D__c,MA_ID__c,LT_MA_Flag__c From Local_Title__c Where Id in :localDataIds]);
        
        for(ClientAvailCountWrapper wrapper:scope){
            if(localDataMap.get(wrapper.localDataId) == null) 
                continue;
            
            if( (wrapper.getStatusCount(STATUS_CONF) != null && wrapper.getStatusCount(STATUS_CONF) > 0) || 
                (wrapper.getStatusCount(STATUS_TENTVE) != null && wrapper.getStatusCount(STATUS_TENTVE) > 0) ){
                    if(localDataMap.get(wrapper.localDataId).LT_MA_Flag__c == false){
                        Local_Title__c ltRec = new Local_Title__c();
                        ltRec.Id = wrapper.localDataId;
                        ltRec.LT_MA_Flag__c=true;
                        if(localDataMap.get(wrapper.localDataId).MA_ID__c == Null || localDataMap.get(wrapper.localDataId).MA_ID__c == ''){
                            ltRec.MA_ID__c = localDataMap.get(wrapper.localDataId).Edit_EIDR_2D__c;
                        }
                        finalUpdateList.add(ltRec); //update flag to true
                       
                    }
            }else{
                if(localDataMap.get(wrapper.localDataId).LT_MA_Flag__c){
                    finalUpdateList.add(new Local_Title__c(Id=wrapper.localDataId,LT_MA_Flag__c=false,MA_ID__c='')); //update flag to false
                    
                }
                    
            }
        }
        
        Database.SaveResult[] updateResult = Database.update(finalUpdateList,false);
        //Error handling pending - Insert errors into error object
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('In Finish Method');
    }
    /* End ******** Batch Methods************/
    
    global class ClientAvailCountWrapper
    {
        public String localDataId;
        Map<String,Integer> statusCountMap = new Map<String,Integer>();
        
        public ClientAvailCountWrapper(String localDataId){
            this.localDataId = localDataId;
        }
        
        public void populateStatusCount(Object statusVal,Object availCount){
            statusCountMap.put((String)statusVal,(Integer)availCount);
        }
        
        public Integer getStatusCount(String statusVal){
            return statusCountMap.get(statusVal);
        }
    }
}