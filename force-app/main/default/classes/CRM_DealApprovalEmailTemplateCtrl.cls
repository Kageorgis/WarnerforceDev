/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrl
	@CreateDate 
	@Description This class is used to handle more than 1000 products under a singal Opportunity in apex:repeat via map approach. 
				 this is handling the UK territories
	@Version <1.0>
	@reference Defect#4737
*/
public with sharing class CRM_DealApprovalEmailTemplateCtrl{
	
	//Opportunity record 
	public Opportunity deal{get;set;}
	
	//Get Deal Products
	public Map<Id, OpportunityLineItem> getDealProducts(){
		Map<Id, OpportunityLineItem> mapDealProducts = new Map<Id, OpportunityLineItem>();
		
		CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        Integer limitNumber = Integer.valueOf(defaultConfiguration.Deal_Product_Limit_in_Email_Templates__c);
		
		if(deal != null){
			String dealId = deal.Id;
			mapDealProducts = new Map<Id, OpportunityLineItem>(
									[Select Product2.Name, ProductCode, Product2.Street_Date__c, Minimum_Price__c, Account_Price__c, Promoted_Price__c, 
											Price_is_Minimum__c, Quantity, Initial_Quantity__c, Replen_Quantity__c, TotalPrice, Minimum_Contribution__c, 
											Contribution__c, Contribution_is_Minimum__c     
									   From OpportunityLineItem
									  Where OpportunityId =: dealId AND (Price_is_Minimum__c = True  OR Opportunity.Pricebook_Account__c =: System.Label.CRM_Deal_Pricebook_Account_UK_EA) LIMIT : limitNumber ]);
		}
		return mapDealProducts.size() > 0 ? mapDealProducts : null;
	}
}