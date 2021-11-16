trigger RF_ExtTitleTrigger on Ext_Title__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
       system.debug('IN EXT TRIGGER');
        RF_TriggerDispatcher.run(new RF_ExtTitleTriggerHandler() , 'ExtTitle'); 
        
    }