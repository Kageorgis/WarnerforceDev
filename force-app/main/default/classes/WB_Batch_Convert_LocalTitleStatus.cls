global class WB_Batch_Convert_LocalTitleStatus implements Database.Batchable<sObject>{
    
    String query = null;
    List<Country__c> contuntryList = null;
    
    global WB_Batch_Convert_LocalTitleStatus(){
    	query = 'Select Id,Name,Readiness__c,Local_Title_Status__c FROM Local_Title__c';	
    }
    
    global WB_Batch_Convert_LocalTitleStatus(List<Country__c> contuntryList){
    	this.contuntryList = contuntryList;
    	query = 'Select Id,Name,Readiness__c,Local_Title_Status__c FROM Local_Title__c WHERE Country__c in :contuntryList';	
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Local_Title__c> scope){
    	for(Local_Title__c lt:scope){
    		if(lt.Readiness__c == 'Complete'){
    			lt.Readiness__c = 'Confirmed';
    		}else{
    			lt.Readiness__c = lt.Local_Title_Status__c;
    		}
    	}
    	
    	WB_LocalTitleTriggerHandler.recursiveUpdate = true;
    	Database.update(scope,false);
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
}