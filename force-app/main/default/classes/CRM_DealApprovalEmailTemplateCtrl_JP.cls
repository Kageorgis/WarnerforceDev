/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrl_JP
	@CreateDate 
	@Description This class is used to handle more than 1000 products under a singal Opportunity in apex:repeat via map approach. 
				 this is handling the JP territory
	@Version <1.0>
	@reference Defect#4737
*/
public with sharing class CRM_DealApprovalEmailTemplateCtrl_JP {
	
	//Opportunity record 
	public Opportunity deal{get;set;}
	
	//Get Deal Products
	public Map<Id, OpportunityLineItem> getDealProducts(){
		Map<Id, OpportunityLineItem> mapDealProducts = new Map<Id, OpportunityLineItem>();
		
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        Integer limitNumber = Integer.valueOf(defaultConfiguration.Deal_Product_Limit_in_Email_Templates__c);
        
		if(deal != null){
			mapDealProducts = new Map<Id, OpportunityLineItem>(
									[SELECT Product2.Name, Product2Id, ProductCode, UnitPrice, Contribution__c, 
											Minimum_Price__c, Minimum_Contribution__c, Price_is_Minimum__c, 
											Contribution_is_Minimum__c, Quantity, Initial_Quantity__c, Replen_Quantity__c
									   FROM OpportunityLineItem
									  WHERE OpportunityId =: deal.Id 
                                        AND (Price_is_Minimum__c = True OR Contribution_is_Minimum__c = True OR Override_COP__c = True) LIMIT : limitNumber ]);
		}
		return mapDealProducts.size() > 0 ? mapDealProducts : null;
	}
}