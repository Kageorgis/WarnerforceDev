/*******************************************************************************************************************************************
* File Name     :   WB_ECTrackerTrigger
* Description   :   
* @author       :   Dennis Cho
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     16 Aug.2017        Dennis Cho                 ER-000776 : Title metadata is currently not available on EC Tracker.  This trigger will 
copy title metadata from Title and Local Data onto the EC Tracker record at time of creation, removing the need for the user to manually 
maintain these fields.  
                                     
********************************************************************************************************************************************/

trigger WB_ECTrackerTrigger on EC_Tracker__c (before insert, before update) {
    if(trigger.isBefore && trigger.isInsert) {
    	WB_ECTracker.insertECTracker(trigger.new);    
    } 
	if(trigger.isBefore && trigger.isUpdate) {
		list<EC_Tracker__c> changedTitleList = new list<EC_Tracker__c>();
        for (EC_Tracker__c tr : trigger.new) {
            if (tr.Title__c != trigger.oldmap.get(tr.id).Title__c) {
                changedTitleList.add(tr);
            }
        }
        WB_ECTracker.updateECTracker(changedTitleList);    
    } 
}