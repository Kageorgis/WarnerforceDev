/*========================================================================================================
* @author: Ajit Singh
* @date: 27/07/2021
* @description: Helper class that will implement the functionality of CP_ForecastItemTriggerHandler
==========================================================================================================*/
public class CP_ForecastItemTriggerHelper {
    
 public static void changeForecastStatusToDraft(List<sObject> newRecordsList , Map<Id, sObject> newItems){
     system.debug('inside changeForecastStatusToDraft:'); 	
     Set<Id> forecastId=new Set<Id>();
     for(Id fcItemId : newItems.keySet()){ 
            CP_Forecast_Item__c newRec = (CP_Forecast_Item__c) newItems.get(fcItemId);
		    forecastId.add(newRec.Forecast__c);
        }
    	List<CP_Forecast__c> fCList= new List<CP_Forecast__c>();
        List<CP_Forecast__c> foreCastList=[select id,name,Forecast_Status__c from CP_Forecast__c where Id IN:forecastId];
       system.debug(' before foreCastList:'+foreCastList); 		
      for(CP_Forecast__c fcl : foreCastList){ 
        if(fcl.Forecast_Status__c==Label.CP_FORECAST_OPEN){
              CP_Forecast__c fcobj=new CP_Forecast__c();
              fcobj.Forecast_Status__c=Label.CP_DRAFT_FORECAST;
              fcobj.id=fcl.id;
              fCList.add(fcobj);
          }
 	  }
      system.debug(' after fCList:'+fCList); 	
     if(fCList.size()>0){
      	update fCList;
     }
   }
}