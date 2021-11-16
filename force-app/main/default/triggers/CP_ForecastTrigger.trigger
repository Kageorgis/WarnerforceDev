/*
    @Author : Ajit Singh
    @Date :  07-07-2021
    @Description : CP_ForecastTrigger that will call the RUN methods of CP_TriggerDispatcher class
    
*/

    trigger CP_ForecastTrigger on CP_Forecast__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
       
        CP_TriggerDispatcher.run(new CP_ForecastTriggerHandler() , Label.CP_FORECAST);
        
    }