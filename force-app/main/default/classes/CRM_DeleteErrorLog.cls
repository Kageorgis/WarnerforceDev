/**
   @Author Cognizant
   @name CRM_DeleteErrorLog
   @CreateDate 27 April 2016
   @Description This batch class will be used to create product record in salesforce. It will run daily
   @Version <1.0>
*/

global class CRM_DeleteErrorLog implements Database.Batchable<sObject>, Database.stateful {       

    /**
 *  start method
 *  @name start
 *  @param Database.BatchableContext BC
 *  @return Database.strQueryLocator
 *  @throws Exception None
 */

global Database.QueryLocator start(Database.BatchableContext BC){
     
    String strQuery = 'SELECT ID ';
    strQuery += ' FROM CRM_Error_Log__c';
    strQuery += ' ORDER BY CreatedDate';
     
    System.debug('strQuery ------------->'+strQuery );
    
    return Database.getQuerylocator(strQuery);
}

/**
 *  Execute the logic
 *  @name execute
 *  @param Database.BatchableContext BC
 *  @param List<CRM_Error_Log__c>scope
 *  @return None
 *  @throws Exception None
 */

global void execute(Database.BatchableContext BC, List<CRM_Error_Log__c>scope){
  
    system.debug('scope'+scope.size());  
    delete scope;

}


/**
 *  Calling dependent batch from finish method
 *  @name finish
 *  @param Database.BatchableContext BC
 *  @return None
 *  @throws Exception None
 */
    
    global void finish(Database.BatchableContext BC){

    }    

}