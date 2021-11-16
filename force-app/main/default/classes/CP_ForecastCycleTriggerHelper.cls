/*========================================================================================================
* @author: Ajit Singh
* @date: 05/07/2021
* @description: Helper class that will implement the functionality of CP_ForecastCycleTriggerHandler

==========================================================================================================*/
public class CP_ForecastCycleTriggerHelper {
    
    /*CPBPP-91: When Forecast cycle's status is changed to "Active" then a forecast will be created for each licensee that
				has field Forecast Required- Bottom-Up=(True) for the cycle. */
    public static void autoCreateForecast(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        system.debug('Inside autoCreateForecast-->');
        String foreCastCycleStatus='';   
        //Boolean forecastAlreadyCreated=false;
        Set<id> foreCastCycleId= new Set<id>();  
        for(Id forecastId : newItems.keySet()){ 
            CP_Forecast_Cycle__c newRec = (CP_Forecast_Cycle__c) newItems.get(forecastId);
            foreCastCycleStatus=newRec.status__c;
            //forecastAlreadyCreated=newRec.Forecast_Created__c;// Delete this field- Forecast_Created__c
            foreCastCycleId.add(newRec.id);
        }
        List<Account> accountForecastList=[select id,name,Forecasting_Approver__c,CP_Forecast_Required_Bottom_Up__c,RecordType.name from Account where CP_Forecast_Required_Bottom_Up__c=true AND RecordType.name='WBCP Licensee'];
         system.debug('accountForecastList size:'+accountForecastList.size());
        List<CP_Forecast__c> foreCastList= new List<CP_Forecast__c>();
        
         List<CP_Forecast_Cycle__c> fcycleList= [Select id,name,(select id,name from forecasts__r) from CP_Forecast_Cycle__c where id IN:foreCastCycleId ];
        system.debug('fcycleList size:'+fcycleList.size());
        Set<Id> forecastIdList=new Set<Id>();
        for(CP_Forecast_Cycle__c fcl:fcycleList){
            for(CP_forecast__c fc:fcl.forecasts__r){
                system.debug('forecast id:'+fc.id);
                forecastIdList.add(fc.id);
            }
            
        }   
        
        if(foreCastCycleStatus==Label.CP_FORECAST_ACTIVE && forecastIdList.size()==0){
            for(Account acc:accountForecastList){
                system.debug('inside accountForecastList:'+acc.Name);
                CP_Forecast__c forecastObj=new CP_Forecast__c();
                forecastObj.Licensee_Name__c=acc.id;
                forecastObj.Forecast_Status__c=Label.CP_FORECAST_OPEN;
                 system.debug('Forecasting_Approver__c:'+acc.Forecasting_Approver__c);
                if(acc.Forecasting_Approver__c!=null){
                forecastObj.ownerid=acc.Forecasting_Approver__c;
                }
                for(Id fcId:foreCastCycleId){
                    forecastObj.Forecast_Cycle__c=fcId;
               }
                forecastObj.Forecast_version__c=Decimal.valueOf(1);
                //forecastObj.Forecast_Type__c=Label.CP_ROYAlTY;
                foreCastList.add(forecastObj);
            }
            system.debug('foreCastList final size to be inserted:'+foreCastList.size());
            
            CP_ForecastBatchInsert forecastBatch = new CP_ForecastBatchInsert(foreCastList); 
            Id batchId = Database.executeBatch(forecastBatch);
            system.debug('batch id in update:'+batchId);
            //insert foreCastList;
            
            /*for(Id forecastId : newItems.keySet()){
                CP_Forecast_Cycle__c newRec = (CP_Forecast_Cycle__c) newItems.get(forecastId);
                newRec.Forecast_Created__c=true;
            }*/
            
            
        }
    }
    public static void autoCreateForecastOnInsert(List<sObject> newRecordsList , Map<Id, sObject> newItems){
         String foreCastCycleStatus='';   
       // Boolean forecastAlreadyCreated=false;
        Set<id> foreCastCycleId= new Set<id>();  
        for(Id forecastId : newItems.keySet()){ 
            CP_Forecast_Cycle__c newRec = (CP_Forecast_Cycle__c) newItems.get(forecastId);
            foreCastCycleStatus=newRec.status__c;
            //forecastAlreadyCreated=newRec.Forecast_Created__c;
            foreCastCycleId.add(newRec.id);
        }
        List<Account> accountForecastList=[select id,name,CP_Forecast_Required_Bottom_Up__c from Account where CP_Forecast_Required_Bottom_Up__c=true AND RecordType.name='WBCP Licensee'];
        List<CP_Forecast__c> foreCastList= new List<CP_Forecast__c>();
        
        if(foreCastCycleStatus==Label.CP_FORECAST_ACTIVE ){//&& forecastAlreadyCreated==false
            for(Account acc:accountForecastList){
                system.debug('inside accountForecastList:'+acc.Name);
                CP_Forecast__c forecastObj=new CP_Forecast__c();
                system.debug('acc.id:'+acc.id);
                //Id accountId=Id.valueOf(acc.id);
                forecastObj.Licensee_Name__c=Id.valueOf(acc.id);
                
                forecastObj.Forecast_Status__c=Label.CP_FORECAST_OPEN;
                for(Id fcId:foreCastCycleId){
                    forecastObj.Forecast_Cycle__c=fcId;
               }
                forecastObj.Forecast_version__c=Decimal.valueOf(1);
               
                foreCastList.add(forecastObj);
            }
           
            
           // insert foreCastList;
            
            CP_ForecastBatchInsert forecastBatch = new CP_ForecastBatchInsert(foreCastList); 
            Id batchId = Database.executeBatch(forecastBatch);
             system.debug('batch id in insert:'+batchId);
            
         
        }
    }
    
}