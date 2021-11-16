/*
    @Author : Ajit Singh
    @Date :  17-09-2020
    @Description : RF_ReleaseforceTrigger that will call the RUN methods of RF_TriggerDispatcher class
    
*/

    trigger RF_ReleaseforceTrigger on Release__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
       
        RF_TriggerDispatcher.run(new RF_ReleaseforceTriggerHandler() , 'Releaseforce'); 
        
    }