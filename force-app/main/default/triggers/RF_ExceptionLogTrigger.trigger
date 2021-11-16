/*
    @Author : Ajit Singh
    @Date :  23-02-2021
    @Description : RF_ExceptionLogTrigger that will call the RUN methods of RF_TriggerDispatcher class
    
*/
trigger RF_ExceptionLogTrigger on RF_Exception_Log__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	RF_TriggerDispatcher.run(new RF_ExceptionLogTriggerHandler() , 'RF Exception Log');
}