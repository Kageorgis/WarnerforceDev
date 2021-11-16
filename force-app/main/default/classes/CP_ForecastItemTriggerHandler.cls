/*========================================================================================================================
* @author: Ajit Singh
* @date: 27/07/2021
* @description: Trigger handler class for ForecastItem which implements all the trigger events like insert,update,delete
==========================================================================================================================*/
public class CP_ForecastItemTriggerHandler implements CP_TriggerInterface{
    
    public void BeforeInsert(List<CP_Forecast_Item__c> newItems) { 
        
        /*Try{
            system.debug('-->Inside CP_ForecastItemTriggerHandler BeforeInsert');
           // CP_ForecastingItemController.showGridErrorValidation(newItems);
        }Catch(System.Exception ex){}*/
        
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { 
        Try{
            system.debug('Inside BeforeUpdate' + Trigger.new);
            CP_ForecastingItemController.showGridErrorValidationUpdate(Trigger.new);
            //CP_ForecastingItemController.checkDuplicateRecord(Trigger.new);
            
        }Catch(System.Exception ex){
            
            
        }
    }
    
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {
        /*  Try{
system.debug('Inside BeforeDelete');


}Catch(System.Exception ex){


}*/
        
        
    }
    
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, sObject> newItems) {
        Try{
            System.debug('AfterInsert:');
            CP_ForecastingItemController.populateForecastAdjustment(newRecordsList);
            CP_ForecastItemTriggerHelper.changeForecastStatusToDraft(newRecordsList,newItems);
            if(Trigger.isInsert && Trigger.isAfter)
             CP_ForecastingItemController.showGridErrorValidationInsert(Trigger.new);
            //CP_ForecastingItemController.checkDuplicateRecord(Trigger.new);
        }Catch(System.Exception ex){
        }
        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Try{
            //CP_ForecastingItemController.checkDuplicateRecord(Trigger.new);
            //CP_ForecastingItemController.showGridErrorValidation(Trigger.new);
        }Catch(System.Exception ex){
        }
    }
    
    // public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    // public void AfterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {}
    
}