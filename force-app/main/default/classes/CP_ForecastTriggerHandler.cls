/*========================================================================================================================
* @author: Ajit Singh
* @date: 07/07/2021
* @description: Trigger handler class for Forecast which implements all the trigger events like insert,update,delete
==========================================================================================================================*/
public class CP_ForecastTriggerHandler implements CP_TriggerInterface{
    
   
    public void BeforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) { 
        Try{
            system.debug('Inside BeforeUpdate');
            CP_ForecastTriggerHelper.closeForecast(newRecordsMap,oldRecordsMap);
            CP_ForecastTriggerHelper.updateStatustToDraft(newRecordsMap,oldRecordsMap);
            //CP_ForecastTriggerHelper.updateStatustToDraftNew(newRecordsMap,oldRecordsMap);
            CP_ForecastTriggerHelper.sendEmailToForecastOwner(newRecordsMap,oldRecordsMap);
            //CP_ForecastTriggerHelper.cloneNewVersionForecast(newRecordsMap,oldRecordsMap);
            //CP_ForecastTriggerHelper.sendEmailToLicensees();
            
 		   }Catch(System.Exception ex){
              
	       }
    }
    
        
   public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Try{
            
            SYSTEM.debug('After Update');
            //CP_ForecastTriggerHelper.massApproveForecast(newItems,oldItems);
            //CP_ForecastTriggerHelper.updateStatustToDraft(newItems,oldItems);
             CP_ForecastTriggerHelper.cloneNewVersionForecast(newItems,oldItems);
           
            // CP_ForecastTriggerHelper.shareContractsWithAgent((List<sObject>) newItems.values() ,newItems);

        }Catch(System.Exception ex){

		}
    }
    
     public void BeforeInsert(List<CP_Forecast__c> newItems) { 
        
        Try{
            system.debug('-->Inside BeforeInsert');
            CP_ForecastTriggerHelper.preventForecastInsert(newItems);
          //  CP_ForecastTriggerHelper.addVersionToForecast(newItems);// to b uncommented- 23/09
            //CP_ForecastTriggerHelper.checkLatestForecastVersion(newItems);
         }Catch(System.Exception ex){
  
        }
   }
      
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, sObject> newItems) {
        Try{
            System.debug('AfterInsert:');
            //CP_ForecastTriggerHelper.updateStatustToDraft(newItems,oldItems);
             CP_ForecastTriggerHelper.updateFileOnForecast(newRecordsList,newItems);
            CP_ForecastTriggerHelper.updateOwnerOnForecast(newRecordsList,newItems);
            //CP_ForecastTriggerHelper.shareForecastRecordWithAgent(newRecordsList,newItems);
            //CP_ForecastTriggerHelper.shareContractsWithAgent(newRecordsList,newItems);
        }Catch(System.Exception ex){
        }
        
    }
    
    
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {
       /* Try{
            system.debug('Inside BeforeDelete');            
        }Catch(System.Exception ex){      
        }*/
        
        
    }
  

    
    // public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    // public void AfterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {}
    
}