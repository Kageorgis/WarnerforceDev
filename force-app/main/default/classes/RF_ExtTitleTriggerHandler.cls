public class RF_ExtTitleTriggerHandler implements RF_TriggerInterface {
    public void BeforeInsert(List<SObject> newRecordsList) {   
        system.debug('IN BEFORE HANDLER');
        RF_ExtTitleHelper.setMPMFCPrefix(trigger.new);
       //RF_ExtTitleHelper.SetMPMRequeststatus(trigger.new);
       //RF_ExtTitleHelper.setMPMRequest(newRecordsList); 
       //RF_ExtTitleHelper.setprefix(newItems.values(),oldItems);
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        for(Id rec:newItems.KeySet()){
            
            ext_title__c extnew = (ext_title__c)newItems.get(rec);
            Ext_Title__C extold = (Ext_Title__C)oldItems.get(rec);
            
            if(extnew.Integration_State__c != extold.Integration_State__c  ){
                system.debug('extnew.Integration_State__c' +extnew.Integration_State__c);
                system.debug('extold.Integration_State__c' +extold.Integration_State__c);
                return;
            }
        }
        RF_ExtTitleHelper.setMPMRequest(newItems.values(),oldItems);
        RF_ExtTitleHelper.setMPMFCPrefixUpdate(trigger.new,oldItems);
        RF_ExtTitleHelper.SetMPMRequeststatus(trigger.new,oldItems);
      //RF_ExtTitleHelper.setprefix(newItems.values(),oldItems);
        system.debug('newItems.values()'+newItems.values());
        system.debug('oldItems'+oldItems);

    }
   public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {}
   public void AfterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {}
   public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
  //public void AfterDelete(Map<Id, SObject> oldItems) {}

  //public void AfterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {}
      
}