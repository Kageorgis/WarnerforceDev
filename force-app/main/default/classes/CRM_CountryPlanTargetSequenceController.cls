public with sharing class CRM_CountryPlanTargetSequenceController {
    
    public static void executeBeforeDelete(List<Country_Plan_Target__c> lstContryPlanTargets) {

        // Delete Related Targets
        CRM_CountryPlanTargetSequenceHandler instanceHandler = new CRM_CountryPlanTargetSequenceHandler();
        instanceHandler.deleteTargets(lstContryPlanTargets);
        //system.debug('***lstContryPlanTargets'+lstContryPlanTargets);
    }
    
    //US842 - Roll up target quantity on country plan.Target_quantity__c
    
    //before trigger
    public static void executeBeforeUpdate(List<Country_Plan_Target__c> newCPTList){
        CRM_CountryPlanTargetSequenceHandler instanceHandler = new CRM_CountryPlanTargetSequenceHandler();
        instanceHandler.doValidateCPT(newCPTList);
        
    }
    
    public static void executeBeforeInsert(List<Country_Plan_Target__c>newCPTList){
        CRM_CountryPlanTargetSequenceHandler instanceHandler = new CRM_CountryPlanTargetSequenceHandler();
        instanceHandler.doValidateCPT(newCPTList);
    }
    //US842 ends
}