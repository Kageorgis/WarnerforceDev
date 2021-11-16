/*
    @Author : Ajit Singh
    @Date :  02-07-2021
    @Description : CP_ForecastCycleTrigger that will call the RUN methods of CP_TriggerDispatcher class
    
*/

    trigger CP_ForecastCycleTrigger on CP_Forecast_Cycle__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
       
        CP_TriggerDispatcher.run(new CP_ForecastCycleTriggerHandler() , Label.CP_FORECAST_CYCLE);
        
    }