/*******************************************************************************************************************************************
* File Name     :   WB_Batch_ClientAvailPricingUpdate
* Description   :   A batch job for marking updating Pricing field value on existing Client Aavails in Confirmed Status
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author          Modification
---------------------------------------------------------------------------------------------------
* 1.0     19 Apr 2016        CTS            Created the class                                                         
********************************************************************************************************************************************/

global class WB_Batch_ClientAvailPricingUpdate implements Database.Batchable<sObject>{
    
    
    String query = '';
    Date dt = Date.today();
    List<Client_Avail__c> lstClientAvail;
    List<Pricing__c> lstPricingTiers = new List<Pricing__c>();
    global WB_Batch_ClientAvailPricingUpdate(){
    }
   
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Release_Plan_Country__c> countryList = Release_Plan_Country__c.getall().values();
        Set<String> SetRelease_Plan_Country = new Set<String>();
        for(Release_Plan_Country__c s:countryList){
            if(s.isActive__c == true)
            SetRelease_Plan_Country.add(s.Country__c);
        }
         query =  'SELECT Client__c, Release_Plan_Country__c, Release_Plan_Format__c, Release_Plan_Channel__c, End_Date__c, '
                +' Price_Tier_Text__c, Title_Content_Type__c, Local_Title__r.Price_Code__c, Status__c, Validation_Failures__c '
                +' FROM Client_Avail__c '
                +' WHERE Status__c = \'Confirmed\' '
                +' and Release_Plan_Country__c IN:SetRelease_Plan_Country ';
       return Database.getQueryLocator(query);
    }
  
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Client_Avail__c>scope)  {
        system.debug('scope*****'+scope);
        if(scope.size() > 0){
            try{
                Database.SaveResult[] results = Database.update(scope,false);
                if (results != null){
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()) {
                            Database.Error[] errs = result.getErrors();
                            for(Database.Error err : errs)
                                System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                            }
                        }
                    }
            }
            catch (DMLException e){
                for (Client_Avail__c ca : scope) {
                     System.debug('There was a problem updating the Right Record');
                }
            }
        }
       
	}
 
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
       
    }
}