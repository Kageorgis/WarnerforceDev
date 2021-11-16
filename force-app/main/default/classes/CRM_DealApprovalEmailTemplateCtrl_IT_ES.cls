/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrl_IT_ES
	@CreateDate 
	@Description This class is used to handle more than 1000 products under a singal Opportunity in apex:repeat via map approach. 
				 this is handling the IT & ES territory
	@Version <1.0>
	@reference Defect#4737, 4749
*/
public with sharing class CRM_DealApprovalEmailTemplateCtrl_IT_ES {
	
	//Opportunity record 
	public Opportunity deal{get;set;}
	
	public Opportunity getDealRec() { 
		if(deal != null)
			return [SELECT Id, Product_Price_is_Under_Minimum__c, RecordType.DeveloperName, 
						   Account.Digital_Country_Code__c, Product_Contribution_is_Under_Minimum_S__c, Sales_Organisation__c
					  FROM Opportunity 
					 WHERE Id =: deal.Id];
		return null;
	}
	
	//Get Deal Products
	public Map<Id, OpportunityLineItem> getDealProducts(){
		Map<Id, OpportunityLineItem> mapDealProducts = new Map<Id, OpportunityLineItem>();
		
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        Integer limitNumber = Integer.valueOf(defaultConfiguration.Deal_Product_Limit_in_Email_Templates__c);
        
		if(deal != null){
			mapDealProducts = new Map<Id, OpportunityLineItem>(
									[SELECT Product2.Name, Product2Id, ProductCode, Promoted_Price__c, 
											Account_Price__c, Contribution__c, Min_Contribution_Sales__c,
											Price_is_Minimum__c, Contribution_is_under_Minimum_Finance__c, 
											Contribution_is_under_Minimum_Sales__c, Product2.ProductCode
									   FROM OpportunityLineItem
									  WHERE OpportunityId =: deal.Id 
                                        AND (Price_is_Minimum__c = True OR Contribution_is_under_Minimum_Finance__c = True OR Contribution_is_under_Minimum_Sales__c = True) LIMIT : limitNumber]);
		}
		return mapDealProducts.size() > 0 ? mapDealProducts : null;
	}
}