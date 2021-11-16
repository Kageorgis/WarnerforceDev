trigger CRM_DecayCurveTemplate on Decay_Curve_Template__c (before insert, before update, before delete) {
    if(trigger.isBefore && trigger.isInsert){
        CRM_DecayCurveTemplateSequenceController.executeBeforeInsert(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate) {
        CRM_DecayCurveTemplateSequenceController.executeBeforeUpdate(trigger.oldMap, trigger.new);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        CRM_DecayCurveTemplateSequenceController.executeBeforeDelete(trigger.old);
    }
}