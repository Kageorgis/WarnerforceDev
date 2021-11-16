/*
    @Author : Ajit Singh
    @Date :  26-07-2021
    @Description : CP_ForecastItemTrigger that will call the RUN methods of CP_TriggerDispatcher class
    
*/

    trigger CP_ForecastItemTrigger on CP_Forecast_Item__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
       
        CP_TriggerDispatcher.run(new CP_ForecastItemTriggerHandler() , Label.CP_FORECAST_ITEM);
        
    }