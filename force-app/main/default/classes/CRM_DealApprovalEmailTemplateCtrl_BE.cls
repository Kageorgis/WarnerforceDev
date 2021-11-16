/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrl_BE
	@CreateDate 
	@Description This class is used to handle more than 1000 products under a singal Opportunity in apex:repeat via map approach. 
				 this is handling the BE territory
	@Version <1.0>
	@reference Defect#4737
*/
public with sharing class CRM_DealApprovalEmailTemplateCtrl_BE {
	
	//Opportunity record 
	public Opportunity deal{get;set;}
	
	public Opportunity getDealRec() { 
		if(deal != null)
			return [SELECT Id, Count_Opportunity_Products__c FROM Opportunity WHERE Id =: deal.Id];
		return null;
	}
	
	//Get Deal Products
	public Map<Id, OpportunityLineItem> getDealProducts(){
		Map<Id, OpportunityLineItem> mapDealProducts = new Map<Id, OpportunityLineItem>();
		
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        Integer limitNumber = Integer.valueOf(defaultConfiguration.Deal_Product_Limit_in_Email_Templates__c);
        
		if(deal != null){
			mapDealProducts = new Map<Id, OpportunityLineItem>(
									[SELECT Product2Id, Product2.Name, ProductCode, Account_Price__c, Promoted_Price__c, 
											Quantity, Contribution__c, Contribution_is_Minimum__c     
									   FROM OpportunityLineItem
									  WHERE OpportunityId =: deal.Id 
                                        AND (Contribution__c < 40 OR Opportunity.Product_Price_is_Under_Minimum__c > 0 OR Override_COP__c= True) LIMIT : limitNumber ]);
		}
		return mapDealProducts.size() > 0 ? mapDealProducts : null;
	}
}