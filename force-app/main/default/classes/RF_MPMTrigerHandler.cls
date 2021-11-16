public class RF_MPMTrigerHandler implements RF_TriggerInterface{
    public void BeforeInsert(List<SObject> newRecordsList) {
    	RF_MPMHelper.setPrefixFinacial(trigger.new);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
     // RF_MPMHelper.FiancialPrefix(Map<Id, SObject> newItems, Map<Id, SObject> oldItems); 
     RF_MPMHelper.setPrefixFinacial(trigger.new);   
    }
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
        RF_MPMHelper handlerInstance = new RF_MPMHelper();
        list<MPM__C> MPMlist = new list<MPM__C>();
        for(sObject so: newItems.values()){
            MPMlist.add((MPM__C)so);
        }
        
       // handlerInstance.updateMPMFamily(MPMlist);
        handlerInstance.updateExtTitle(MPMlist);        
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        RF_MPMHelper handlerInstance = new RF_MPMHelper();
        list<MPM__C> MPMlist = new list<MPM__C>();
        for(sObject so: newItems.values()){
            MPMlist.add((MPM__C)so);
        }
        
        handlerInstance.updateExtTitle(MPMlist);
        
    }
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {}
    
    
}