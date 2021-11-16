trigger WB_ECAnnouncementType_Trigger on EC_AnnouncementType__c (after delete, after insert, after update, before delete, before insert, before update) {
    WB_Trigger_Factory.createHandler(EC_AnnouncementType__c.sObjectType);
}