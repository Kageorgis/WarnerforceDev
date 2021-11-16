/**
   @Author: Cognizant Team
   @name CRM_AssortmentAccountHandler 
   @CreateDate 20/09/2016
   @Description: This Handler is used to perform tasks for the Trigger.
   @Version 1.0
  */
public without sharing class CRM_AssortmentAccountHandler {
    
    /**
    *  @Description - Defect #3697: Update Deal status to 'Cancelled' when Assortment Account is Deleted.       
    *  @name - cancelDeals
    *  @params - Trigger.OldMap
    *  @return - void
    */
    public static void cancelDeals(Map<Id,Assortment_Account__c> mapAssortAccount){
        //List to hold List of Opportunity to update
        List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
        
        //Fetch the Deal record corresponding to the Assortment Account and where Stage not equal to Cancelled and Revised.
        List<Opportunity> lstOpportunity = [
                SELECT StageName From Opportunity 
                WHERE Assortment_Account__c IN :mapAssortAccount.keySet() 
                AND StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED
                AND StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_REVISED
        ];
        //Iterate through the List of Opportunity and change the status to 'Cancelled'.
        for(Opportunity opty :lstOpportunity){
            opty.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            lstOpportunityToUpdate.add(opty);
        }
        
        //update the List of Opportunity with Stage 'Cancelled'
        if(!lstOpportunityToUpdate.isEmpty()){
            update lstOpportunityToUpdate;
        }
    }
}