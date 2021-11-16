/*
    @Author : Ajit Singh
    @Date :  17-09-2020
    @Description : CAR_CARTrigger that will call the RUN methods of RF_TriggerDispatcher class
    
*/

    trigger CAR_CARTrigger on CAR__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
       
        RF_TriggerDispatcher.run(new CAR_CARTriggerHandler() , 'CAR');
        
    }