/**
   @Author Cognizant
   @name CRM_GeneratePBEP 
   @CreateDate 28 April 2016
   @Description This batch class will be used to create pbe record in salesforce.
   @Version <1.0>
   @reference Requirement no 153
*/

global class CRM_GeneratePBEP implements Database.Batchable<sObject> {       

    /**
 *  start method
 *  @name start
 *  @param Database.BatchableContext BC
 *  @return Database.strQueryLocator
 *  @throws Exception None
 */

global Database.QueryLocator start(Database.BatchableContext BC){
    
    
        CRM_Default_Configuration__c setting = CRM_Default_Configuration__c.getOrgDefaults();

        String createdByUser ;
        if(setting.PBEP_CreatedByUser__c != null)
        {
            createdByUser = setting.PBEP_CreatedByUser__c;
        }
    
        String strQuery = 'SELECT ID,Product__c,CurrencyIsoCode,Price_Book__c ';
        strQuery += ' FROM Pricebook_Entry_Period__c';
        if(setting.PBEP_CreatedByUser__c != null){
            strQuery += ' WHERE CreatedById =\'' + setting.PBEP_CreatedByUser__c + '\' ';
        }
        strQuery += ' ORDER BY CreatedDate';
     
        System.debug('strQuery ------------->'+strQuery );
    
    return Database.getQuerylocator(strQuery);
}

/**
 *  Execute the logic
 *  @name execute
 *  @param Database.BatchableContext BC
 *  @param List<Pricebook_Entry_Period__c>scope
 *  @return None
 *  @throws Exception None
 */

global void execute(Database.BatchableContext BC, List<Pricebook_Entry_Period__c>scope){
  
  
   CRM_PBEPHandler instance = new CRM_PBEPHandler();
   instance.createPBENTRYForNewPBEPeriod(scope);

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