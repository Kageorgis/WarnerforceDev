public with sharing class CRM_GenerateMultiOrderFromDealController {
    public boolean isCommittedDeal{get; set;}
    public boolean isNotValidDealAccount{get; set;}
    public boolean isRevenueShareAccount{get; set;}
    public boolean isRentalDealForRevenueShareAccount{get; set;}
    public CRM_GenerateMultiOrderFromDealController(Apexpages.StandardController stdCon) {
        isCommittedDeal = false;
        isNotValidDealAccount = false;
        isRevenueShareAccount = false;
        isRentalDealForRevenueShareAccount = false;
        
        String dealId = stdCon.getId();
        List<Opportunity> lstdeals = [Select Id,Sales_Organisation__c,Market_Type__c,StageName,Account.RecordTypeId,Account.Revenue_Share__c From Opportunity Where Id =:dealId];
        if(!lstdeals.isEmpty()){
	        if(!lstdeals.isEmpty() && 
	           (lstdeals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || 
	            lstdeals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED || 
	           (lstdeals[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && lstdeals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT))){
	            isCommittedDeal = true;
	        }
	        if(lstdeals[0].Account.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO){
	            isNotValidDealAccount = true;
	        }
            if(lstdeals[0].Account.Revenue_Share__c){
                isRevenueShareAccount = true;
                if(lstdeals[0].Market_Type__c == CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE){
                    isRentalDealForRevenueShareAccount = true;
                }
            }
        }
    }
    
    @RemoteAction 
    public static String generateMultiOrder(Id dealId,Id accountId,String CurrencyIsoCode,String salesOrg,Boolean isRevenueShareAccount){
        String redirectURL = null;
        
        if(dealId != null && accountId != null){
            Order orderObj = new Order();
            orderObj.OpportunityId = dealId;
            if(isRevenueShareAccount)
                orderObj.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE;
            else
                orderObj.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER;
            orderObj.AccountId = accountId;
            orderObj.Status = CRM_AppConstants.ORDER_STATUS_OPEN;
            orderObj.CurrencyIsoCode = CurrencyIsoCode;
            orderObj.Customer_PO_Number__c = '/';
            orderObj.EffectiveDate = System.Today();
            
            try{
                insert orderObj;
                redirectURL = 'apex/CRM_MultiUploadExtractOrder?id='+String.valueOf(orderObj.Id);
            }catch(System.DMLException de){
                throw new CRM_GenerateMultiOrderFromDealException(de.getDmlMessage(0));
            }
        }
        return redirectURL;
    }
    
    public class CRM_GenerateMultiOrderFromDealException extends Exception {}
}