/**
   @Author - Cloudcreations
   @name - WBSF_CalculateTotalWholesaleCost
   @CreateDate - 01 October 2019
   @Description - Opportunity Product Trigger Handler for calculating Total Wholesale Cost Field
   @Version - 1.0
   @reference  -None
*/
public without sharing class WBSF_CalculateTotalWholesaleCost {
    /**
    *  @Description - Method to Calculate the Total Wholesale Cost when the MSRP and/or quantity are modified
    *  @name - CalculateTotalWholesaleCost
    *  @return - void
    */
    public static void CalculateTotalWholesaleCost(Map<Id, OpportunityLineItem> oldDealProductsMap, List<OpportunityLineItem> newDealProducts){
        if(oldDealProductsMap == null){
            for(OpportunityLineItem oli:newDealProducts) if(oli.Wholesale_unit_cost__c != null) oli.Total_Wholesale_Cost__c = oli.Wholesale_unit_cost__c * oli.quantity;
        }
        else{
            for(OpportunityLineItem oli:newDealProducts){
                if(oldDealProductsMap.get(oli.id).Wholesale_unit_cost__c != oli.Wholesale_unit_cost__c || oldDealProductsMap.get(oli.id).quantity != oli.quantity){
                    if(oli.Wholesale_unit_cost__c != null) oli.Total_Wholesale_Cost__c = oli.Wholesale_unit_cost__c * oli.quantity;
                    else oli.Total_Wholesale_Cost__c = null;
                } 
            } 
        }
    }
}