public with sharing class CRM_PBEPSequenceController {
    
    public static void executeBeforeInsert(List<Pricebook_Entry_Period__c> lstNewPBEP) {
        CRM_PBEPHandler pbepHandlerInstance = new CRM_PBEPHandler();
        pbepHandlerInstance.setDuplicatePBEP(new Map<Id,Pricebook_Entry_Period__c>(), lstNewPBEP);
    }

    /*public static void executeBeforeUpdate(Map<Id,Pricebook_Entry_Period__c> mapOldPBEP, Map<Id,Pricebook_Entry_Period__c> mapNewPBEP) {
    }*/

    public static void executeAfterInsert(Map<Id,Pricebook_Entry_Period__c> mapOldPBEP,Map<Id,Pricebook_Entry_Period__c> mapNewPBEP) {
        CRM_PBEPHandler pbepHandlerInstance = new CRM_PBEPHandler();
        pbepHandlerInstance.populateNRProductCreatedOfProductForDigitalPBEP(mapNewPBEP.values());
        //To create Standard PBEntry as well as custom PBEntry only for no integration purpose
        
        CRM_Default_Configuration__c setting = CRM_Default_Configuration__c.getOrgDefaults();
        
        system.debug('*** in before if case');
        system.debug('*** in if casesetting.Informatica_User_Id__c'+setting.Informatica_User_Id__c);
        if(setting.Informatica_User_Id__c == null)
        {
        pbepHandlerInstance.createPBENTRYForNewPBEPeriod(mapNewPBEP.values());
        }
        else{
            if(setting.Informatica_User_Id__c != null && (Id)(setting.Informatica_User_Id__c) != UserInfo.getUserId()){
            pbepHandlerInstance.createPBENTRYForNewPBEPeriod(mapNewPBEP.values());
            }
        }
    }

    public static void executeAfterUpdate(Map<Id,Pricebook_Entry_Period__c> mapOldPBEP,Map<Id,Pricebook_Entry_Period__c> mapNewPBEP) {

        CRM_PBEPHandler pbepHandlerInstance = new CRM_PBEPHandler();
        //pbepHandlerInstance.updateInvalidDealProducts(mapOldProducts,mapNewProducts);
        pbepHandlerInstance.setDuplicatePBEPFuture(mapOldPBEP, mapNewPBEP.values());
        pbepHandlerInstance.recalculateDealProductSchedule(mapOldPBEP, mapNewPBEP.values());
        pbepHandlerInstance.populateStreetdateChangedOfProductForDigitalPBEP(mapOldPBEP, mapNewPBEP.values());
    }
}