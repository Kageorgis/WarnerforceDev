/*
Trigger Name : WB_AnnouncementType_Trigger 
Description  :  To call Trigger on Announcement Type Object 
Created By   : Cognizant Technology Solutions - Shekhar Vinayak
Created On   : 10th Aug 2015

Change History:
--------------------------------------------------------------------------------------------------------------------------------------
Sr#         Description                                                          Updated By                                                        Updated On
---------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                  Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

*/

trigger WB_AnnouncementType_Trigger  on Announcement_Rule__c(after delete, after insert, after update, before delete, before insert, before update) {
    WB_Trigger_Factory.createHandler(Announcement_Rule__c.sObjectType);
}