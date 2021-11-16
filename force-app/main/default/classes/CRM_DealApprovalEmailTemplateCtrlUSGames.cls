/**
	@Author Cognizant
	@name CRM_DealApprovalEmailTemplateCtrlUSGames
	@CreateDate 
	@Description This class is used to handle more than 1000 products under a singal Opportunity in apex:repeat via map approach. 
				 this is handling the US,CAN & MEX territory
	@Version <1.0>
	@reference Defect#4737, 4749
*/
public with sharing class CRM_DealApprovalEmailTemplateCtrlUSGames {
	
	//Opportunity record 
	public Opportunity deal{get;set;}
	
	//Get Deal Products
	public Map<Id, OpportunityLineItem> getDealProducts(){
		Map<Id, OpportunityLineItem> mapDealProducts = new Map<Id, OpportunityLineItem>();
		
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        Integer limitNumber = Integer.valueOf(defaultConfiguration.Deal_Product_Limit_in_Email_Templates__c);
        
		if(deal != null){
			mapDealProducts = new Map<Id, OpportunityLineItem>(
									[SELECT Product2.Name, Product2Id, ProductCode, Start_Date__c, End_Date__c,
											Reason__c, Comments__c, POS_Rebate__c, POS_Forecast__c, Co_op_Requested_Amount__c
									   FROM OpportunityLineItem
									  WHERE OpportunityId =: deal.Id 
                                        AND Reason__c != 'Budget' LIMIT : limitNumber ]);
		}
		return mapDealProducts.size() > 0 ? mapDealProducts : null;
	}
}