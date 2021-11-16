global class WB_Batch_CAP_PushToSFS implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    global String query = null;
    global String caStatus = WB_PriceUtility.STATUS_CONF;
    global List<String> storefronts = new List<String>();
    global Integer days = 7;
    global Date pushToSFSWindow = System.Today();
    /* Start ******* Scheduler Methods************ */
    global WB_Batch_CAP_PushToSFS(){
    	
    }
    
	global void execute (SchedulableContext ctx){
		Database.executeBatch(new WB_Batch_CAP_PushToSFS('Push-To-SFS'));  	
	}
	
	/* End ******* Scheduler Methods************ */
	
	
	/* Start ******* Batch Methods************ */
    global WB_Batch_CAP_PushToSFS(String name){
    	WB_Pricing_Settings__c  pushToSFSWindowData = WB_Pricing_Settings__c.getInstance('Push to SFS');
		try{
			if(pushToSFSWindowData != null){
	    		days = Integer.valueOf(pushToSFSWindowData.Value__c);
			}
		}catch(Exception ex){ System.debug('Error while retriveing custom settings data'+ex.getMessage()); }
		
		pushToSFSWindow = pushToSFSWindow.adddays(days);
		    		
    	for(Agreement__c storefront: [Select Id,Name,SFS_Integration__c FROM Agreement__c Where Status__c = 'Active']){
    		if(storefront.SFS_Integration__c != null){
    			storefronts.add(storefront.Id);
    		}		 
    	}

        query = 'Select Id,Client_Avail__c,Client_Avail_Status__c,CA_Start_Date__c,CA_End_Date__c,Effective_Date__c,Expiry_Date__c,Pre_Order__c,'+
        		' Storefront__c,Title_Content_Type__c,Client_Avail_Channel__c,Client_Avail_Format__c,Category__c,Accounting_Category__c '+ 
        		' FROM Client_Avail_Price__c '+ 
        		' WHERE Expiry_Date__c >= TODAY '+
        		' AND Push_to_SFS__c = NULL' +
        		' AND Pre_Order__c = FALSE'+
        		' AND CAP_Lifecycle__c like \'Active%\' '+
        		' AND Client_Avail__r.Status__c = :caStatus '+ 
        		' AND Client_Avail__r.Storefront__c in :storefronts ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Avail_Price__c> scope){
    	
    	WB_ClientAvailPriceHandler capHandler = new WB_ClientAvailPriceHandler();
    	List<Client_Avail_Price__c> capsToUpdate = new List<Client_Avail_Price__c>();
    	Set<String> storefrontIDs = new Set<String>();
    	  
		for(Client_Avail_Price__c cap:scope){ 
			storefrontIDs.add(cap.Storefront__c);
		}
		List<Agreement__c> storefronts = [Select Id,SFS_Integration__c from Agreement__c where Id IN :storefrontIDs];
		Map<Id,Client_Avail_Price__c> filteredCAPs = capHandler.getFilteredCAPs(scope,storefronts);
		System.debug('filteredCAPs'+filteredCAPs);
    	for(Client_Avail_Price__c cap:filteredCAPs.values()){
    		if(cap.Effective_Date__c >= cap.CA_Start_Date__c && cap.Effective_Date__c <= pushToSFSWindow){
    			cap.Push_to_SFS__c = System.now();
    			capsToUpdate.add(cap);
    		} 
    	}
            	
    	capHandler.populateAccountingCategory(capsToUpdate); 
    	
    	WB_ClientAvailPriceHandler.recursiveUpdate = true;
    	System.debug('capsToUpdate'+capsToUpdate);
    	Database.SaveResult[] saveResult  = Database.update(capsToUpdate,false);
    	
    	WB_ClientAvailPriceHandler.recursiveUpdate = false;
    	//Capture failed CAPs and log errors in CAS Error log object.
    	
    	Map<Id,String> capErrorMap = new Map<Id,String>();
      
	    for(Integer index = 0; index < saveResult.size();index++){
	        Database.SaveResult updateResult = saveResult[index];
        	if(!updateResult.isSuccess()){
          		String errorMessage = '';
          		Id capId;
          		for(Database.Error err : updateResult.getErrors()) {
                  errorMessage += err.getMessage();
              	}
          		capId = capsToUpdate[index].Id;
          		if(!capErrorMap.containsKey(capId)){
            		capErrorMap.put(capId, errorMessage);
          		}
        	}
      	}
      	
      	insertErrorLogs(capErrorMap,'Push to SFS');
    	
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    /* End ******* Batch Methods************ */
    
    public void insertErrorLogs(Map<Id,String> caErrorMap, String Category){
    	List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
	    if(caErrorMap != null && caErrorMap.size()>0){
		  	for(Id caId: caErrorMap.keySet()){
	        	if(caErrorMap.get(caId) != null){
	            	WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
	                errorLogInstance.recordId = caId;
	                errorLogInstance.errorCategory = Category;
	                errorLogInstance.errorDescription = caErrorMap.get(caId).left(252);
	                errorLogInstance.errorDescriptionLong = caErrorMap.get(caId).left(32000); 
	                errorLogInstance.objectName = caId.getSObjectType().getDescribe().getName();
	                errorLogs.add(errorLogInstance);
	            }
	        }
	     }
         
      if(errorLogs != null && errorLogs.size()>0){
        WB_CAS_ErrorLogger.logError(errorLogs); 
      }
      
    }
    
}