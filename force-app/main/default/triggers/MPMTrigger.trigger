trigger MPMTrigger on MPM__c (Before Insert,before update,after insert, after update)   {

 if(WB_TriggerRecursionHelper.mpmRecursiveUpdate){       
        //Flag was set for Product update on RP. Skipping recursive execution of triger code.       
        return;     
    }
    
    if((Trigger.isInsert ||Trigger.isUpdate) ){
        WB_MPMTrigger_Handler handlerInstance = new WB_MPMTrigger_Handler();
       
        handlerInstance.updateMPMFamily(Trigger.new);
    }
    
      
}