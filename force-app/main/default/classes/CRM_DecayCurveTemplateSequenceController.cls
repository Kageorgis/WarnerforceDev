public with sharing class CRM_DecayCurveTemplateSequenceController {
     public static void executeBeforeInsert(List<Decay_Curve_Template__c> lstNewDecayCurveTemplates) {
       CRM_DecayCurveTemplateHandler.updateVersionNumber(null,lstNewDecayCurveTemplates);
     }
     public static void executeBeforeUpdate(Map<Id,Decay_Curve_Template__c> mapOldDecayCurveTemplates, List<Decay_Curve_Template__c> lstNewDecayCurveTemplates) {
       CRM_DecayCurveTemplateHandler.updateVersionNumber(mapOldDecayCurveTemplates,lstNewDecayCurveTemplates);
     }
     public static void executeBeforeDelete(List<Decay_Curve_Template__c> lstOldDecayCurveTemplates){
       CRM_DecayCurveTemplateHandler.restrictToDeleteActiveOrArchivedDCT(lstOldDecayCurveTemplates);
     }
}