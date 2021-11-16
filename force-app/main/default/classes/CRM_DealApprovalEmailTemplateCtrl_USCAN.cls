/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrl_USCAN
	@CreateDate 
	@Description This class is used to handle more than 1000 products under a singal Opportunity in apex:repeat via map approach. 
				 this is handling the US & CAN territory
	@Version <1.0>
	@reference Defect#4737, 4749
*/
public with sharing class CRM_DealApprovalEmailTemplateCtrl_USCAN {
	
	//Opportunity record 
	public Opportunity deal{get;set;}
	
	public Opportunity getDealRec() { 
		if(deal != null)
			return [SELECT Id, Co_op_Requested_Amount__c
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
									[SELECT Product2.Name, Product2Id, ProductCode, Vendor_ID__c, Retailer_Product_Id__c,
											Product2.Street_Date__c, Promoted_Price__c, Quantity, TotalPrice, 
											Co_op_Requested_Amount__c, Reason__c
									   FROM OpportunityLineItem
									  WHERE OpportunityId =: deal.Id 
                                        AND (Co_op_Requested_Amount__c != null AND Co_op_Requested_Amount__c > 0 ) LIMIT : limitNumber  ]);
		}
		return mapDealProducts.size() > 0 ? mapDealProducts : null;
	}
}