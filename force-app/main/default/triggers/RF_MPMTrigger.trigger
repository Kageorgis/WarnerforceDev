trigger RF_MPMTrigger on MPM__c (Before Insert,before update,after insert, after update)   {

    /*if(trigger.isBefore )
    {
        if((Trigger.isInsert ||Trigger.isUpdate) ){
            WB_MPMTrigger_Handler handl
        RF_TriggerDispatcher.run(new RF_ExtTitleTriggerHandler() , 'ExtTitle'); 
erInstance = new WB_MPMTrigger_Handler();
           
            handlerInstance.updateMPMFamily(Trigger.new);
        }
    }
    if(trigger.isAfter )
    {
        if((Trigger.isInsert ||Trigger.isUpdate) ){
            WB_MPMTrigger_Handler handlerInstance = new WB_MPMTrigger_Handler();
           
            handlerInstance.updateMPMFamily(Trigger.new);
            handlerInstance.updateExtTitle(Trigger.new);
            
        }
    }*/
            RF_TriggerDispatcher.run(new RF_MPMTrigerHandler() , 'MPM'); 

      
}