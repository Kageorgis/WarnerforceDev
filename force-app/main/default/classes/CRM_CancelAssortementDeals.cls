public without sharing class CRM_CancelAssortementDeals {
	/***
    Purpose    : Checks for Assorment Status after update. If status is cancelled updates respective opportunities stage.
    Parameters : Trigger.OldMap , Trigger.NewMap
    Return     : Void
    ***/
    public static void cancelAssortementOpportunity(Map<Id,Bundle__c> mapOldAssortments,Map<Id,Bundle__c> mapNewAssortments) {
        Set<Id> assortmentIdSet = new Set<Id>();
        Opportunity[] opportunityUpdateList = new Opportunity[]{};

        //get all assortment where status is changed to 'Cancelled'
        for (Bundle__c oldAssortment : mapOldAssortments.values()) {
            Bundle__c newAssortment = mapNewAssortments.get(oldAssortment.Id);
            if (
                newAssortment.Assortment_Status__c != oldAssortment.Assortment_Status__c &&
                newAssortment.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_CANCELLED
            ) {
                assortmentIdSet.add(newAssortment.Id);		
            }
        }

        if (!assortmentIdSet.isEmpty()) {
            //get all the opportunities where last published date is not null 
            //and parent assortments stage is changed to 'cancelled'
            opportunityUpdateList = [
                    SELECT StageName,Id FROM Opportunity 
                    WHERE Last_Published_Date__c != NULL 
                    AND StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED
                    AND StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_REVISED
                    AND Bundle__c IN : assortmentIdSet
            ];
            //change the opportunity stage to 'cancelled'									  
            if (!opportunityUpdateList.isEmpty()) {
                for (Opportunity op : opportunityUpdateList) {
                    op.StageName = 	CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;		
                }
                update opportunityUpdateList;
            }
        }
    }
}