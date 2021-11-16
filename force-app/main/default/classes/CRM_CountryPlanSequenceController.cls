/** 
 * Author: Anupama & Aditi Satpute
 * Description: Sequence Controller used to invoke following functionality :
                1. Create / update Account Plan records based on Account Split Template added in Country Plan
                2. Update Account Plan Records with target Revenue Has Changed based on some fields updated on Country Plan
 * Date Created: 10th June 2016
 * Version: 1
 */
public with sharing class CRM_CountryPlanSequenceController {

    /*public static void executeBeforeInsert(List<Country_Plan__c> lstNewCountryPlans) {
    }

    public static void executeBeforeUpdate(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans) {
    }

    public static void executeAfterDelete(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans) {
    }*/

    public static void executeAfterInsert(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans){
         //Requirement#479: Update (Release Category = "New Release",Product Price Group = NR) Linked NR Product fields
         //CRM_CreateNewAccountPlan.updateNRProductFields(mapOldCountryPlans, mapNewCountryPlans);
         CRM_CreateNewAccountPlan.prepareAccountPlan(mapOldCountryPlans, mapNewCountryPlans);
    }

    public static void executeAfterUpdate(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans) {
         CRM_CreateNewAccountPlan.prepareAccountPlan(mapOldCountryPlans, mapNewCountryPlans);
         CRM_CreateNewAccountPlan.updateAccountPlanToSetTargetRevenueHasChanged(mapOldCountryPlans, mapNewCountryPlans);
    }
}