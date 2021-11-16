public without sharing class CRM_UpdateTargetAccountHandler {
    /*   
        Description: This method is used to update Account object. This method would be called on 'After Insert' and 'After Update' events.
    
        Inputs: Old and new maps of Target from CRM_Target trigger. 
    */
    public static void updateAccount(Map<Id, Target__c> oldTargetMap, Map<Id, Target__c> newTargetMap){
        set<Id> accIds = new set<Id>();
        for(Target__c target:newTargetMap.values()){
            if(trigger.isInsert){ 
                accIds.add(target.Account__c);               
            }
            if(trigger.isUpdate){
                Target__c oldTarget = (oldTargetMap == null ? null : oldTargetMap.get(target.id));
                Boolean hasGLCalendarChanged = (oldTarget != null && oldTarget.GL_Calendar__c != target.GL_Calendar__c);
                Boolean hasStartDateChanged = (oldTarget != null && oldTarget.StartDate__c != target.StartDate__c);
                Boolean hasBundleChanged = (oldTarget != null && oldTarget.Bundle__c != target.Bundle__c);
                
                if(hasGLCalendarChanged || hasStartDateChanged || hasBundleChanged){
                    accIds.add(target.Account__c);
                }
            }
        }
    
        if(accIds != null && !accIds.isEmpty()){
            List<Account> accountList = [SELECT Id,scheduleRevenueChanged__c from Account where Id IN:accIds AND scheduleRevenueChanged__c = FALSE];
            system.debug('debug : '+accountList);
            for(Account acc:accountList){
                acc.scheduleRevenueChanged__c = TRUE;
            }
            
            if(!accountList.isEmpty() && accountList != null){
                Update accountList;
            }
        }
    }
}