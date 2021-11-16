/*******************************************************************************************************************************************
* File Name     :   WB_RPReleaseTrigger
* Description   :   
* @author       :   Dennis Cho
* Modification Log
===================================================================================================
* Ver.    Date              Author              
---------------------------------------------------------------------------------------------------
* 1.0     24-DEC-2019       Dennis Cho          
Calculate costs for physical and digital Release Planning Release records 
* 2.0     4-JUL-2020		Dennis Cho
Modify trigger to ignore Category in costing derivation for physical releases
********************************************************************************************************************************************/

trigger WB_RPReleaseTrigger on Release_Planning_Release__c (before insert, before update) {
    if(trigger.isBefore && trigger.isInsert) {
		list<Release_Planning_Release__c> newPhysicalRPReleaseList = new list<Release_Planning_Release__c>();
        list<Release_Planning_Release__c> newDigitalRPReleaseList = new list<Release_Planning_Release__c>();
        list<Release_Planning_Release__c> newRPReleaseList = new list<Release_Planning_Release__c>();

        for (Release_Planning_Release__c RPR : trigger.new) {
			newRPReleaseList.add(RPR);
        }
		WB_RPRelease.insertRPRelease(newRPReleaseList); 
        
        for (Release_Planning_Release__c RPR : trigger.new) {
            if (RPR.SRP__c != null &&
                (RPR.Retail_Cost__c == null || RPR.Expected_Retail__c == null))
                newPhysicalRPReleaseList.add(RPR);
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId())
                newDigitalRPReleaseList.add(RPR);
        }
        WB_RPRelease.insertPhysicalRPRelease(newPhysicalRPReleaseList);   
        WB_RPRelease.insertDigitalRPRelease(newDigitalRPReleaseList);
    } 
    
    if(trigger.isBefore && trigger.isUpdate) {
		list<Release_Planning_Release__c> changedPhysicalRPReleaseList = new list<Release_Planning_Release__c>();
		list<Release_Planning_Release__c> changedSDERPReleaseList = new list<Release_Planning_Release__c>();
		list<Release_Planning_Release__c> changedSDSRPReleaseList = new list<Release_Planning_Release__c>();
		list<Release_Planning_Release__c> changedHDERPReleaseList = new list<Release_Planning_Release__c>();
		list<Release_Planning_Release__c> changedHDSRPReleaseList = new list<Release_Planning_Release__c>();
		list<Release_Planning_Release__c> changed4DERPReleaseList = new list<Release_Planning_Release__c>();
		list<Release_Planning_Release__c> changed4DSRPReleaseList = new list<Release_Planning_Release__c>();        
        for (Release_Planning_Release__c RPR : trigger.new) {
            if (RPR.SRP__c != trigger.oldmap.get(RPR.id).SRP__c &&
                RPR.SRP__c > 0) 
             /*   || RPR.Category__c != trigger.oldmap.get(RPR.id).Category__c) */
            {
                changedPhysicalRPReleaseList.add(RPR);   
            }
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId() &&
                RPR.SD_Episode_Retail__c != trigger.oldmap.get(RPR.id).SD_Episode_Retail__c)
                    changedSDERPReleaseList.add(RPR);   
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId() &&
                RPR.SD_Season_Retail__c != trigger.oldmap.get(RPR.id).SD_Season_Retail__c)
                    changedSDSRPReleaseList.add(RPR);
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId() &&
                RPR.HD_Episode_Retail__c != trigger.oldmap.get(RPR.id).HD_Episode_Retail__c)
                    changedHDERPReleaseList.add(RPR);   
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId() &&
                RPR.HD_Season_Retail__c != trigger.oldmap.get(RPR.id).HD_Season_Retail__c)
                    changedHDSRPReleaseList.add(RPR);
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId() &&
                RPR.X4k_Episode_Retail__c != trigger.oldmap.get(RPR.id).X4k_Episode_Retail__c)
                    changed4DERPReleaseList.add(RPR);   
            if (RPR.RecordTypeId == 
                Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId() &&
                RPR.X4k_Season_Retail__c != trigger.oldmap.get(RPR.id).X4k_Season_Retail__c)
                    changed4DSRPReleaseList.add(RPR);
        }
        WB_RPRelease.updatePhysicalRPRelease(changedPhysicalRPReleaseList);
        WB_RPRelease.updateSDERPRelease(changedSDERPReleaseList);
        WB_RPRelease.updateSDSRPRelease(changedSDSRPReleaseList);        
        WB_RPRelease.updateHDERPRelease(changedHDERPReleaseList);
        WB_RPRelease.updateHDSRPRelease(changedHDSRPReleaseList);              
        WB_RPRelease.update4DERPRelease(changed4DERPReleaseList);
        WB_RPRelease.update4DSRPRelease(changed4DSRPReleaseList);                      
    } 
}