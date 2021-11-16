/*===============================================================================================================
* @author Ajit Singh
* @date 23/02/2021
* @description: Trigger handler class for "RF Exception Log" which implements all the trigger events like insert,update,delete
==================================================================================================================*/
public class RF_ExceptionLogTriggerHandler implements RF_TriggerInterface{
  
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
       
       		system.debug('inside BeforeUpdate');	
           
        }
    
     
    public void BeforeInsert(List<RF_Exception_Log__c> newItems) {
           system.debug('inside BeforeInsert');	
           RF_ExceptionLogHelper.updateRFLogInCAR(newItems);
           RF_ExceptionLogHelper.sendMail(newItems); 
     }
    
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {
       
    }
    
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
       
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      
    }
    
     
}