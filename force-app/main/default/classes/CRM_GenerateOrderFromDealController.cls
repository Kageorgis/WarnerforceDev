/**
   @Author Cognizant Technology Solutions
   @name CRM_GenerateOrderFromDealController
   @CreateDate 12/4/2015
   @Description The class is used to pass the Deal Id to visual flow parameter and redirect to new order Id created using Flow
   @Version 1.0
   @reference None
*/
public with Sharing class CRM_GenerateOrderFromDealController{
    private final Opportunity opt;
    public static Opportunity dealRecord {get;set;}  
    public static List<OpportunityLineItem> dealProductRecords {get;set;} 
    public static List<Id> dealProductRecordIds {get;set;} 
    //Constructor
    public CRM_GenerateOrderFromDealController(ApexPages.StandardController controller) {
        this.opt= (Opportunity)controller.getRecord();

    }
    /**
    *  Description-The method is used to pass parameter to Flow and instantiate the page to which the flow should redirect
    *  @name-startFlow
    *  @param-None
    *  @return-The return parameter redirects to the new order edit layout
    *  @throws exception-An unhandled fault has occurred while processing the flow.Please contact your system administrator for more information.
    */
    @RemoteAction
    public static LineItemRecords generateOrderAndOrderProducts(Id[] dealIds){
        
        dealProductRecords = new List<OpportunityLineItem>(); 
        dealProductRecordIds = new List<Id>();
        
        List<Opportunity> lstOpportunity =
                                 [SELECT id, name,CurrencyIsoCode, Start_Date__c, CloseDate,Sales_Organisation__c, Customer_Delivery_Date__c,accountId,Pricebook2Id,StageName,Market_Type__c, 
                                 Account.Sales_Organization__c, Account.Status__c,Account.RecordType.Name,Account.Planning_Customer__c, Account.BillingStreet,
                                 Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.ShippingStreet,Account.ShippingCity,
                                 Account.ShippingState,Account.ShippingPostalCode,Account.ShippingCountry,Account.Revenue_Share__c,
                                 (Select Id from OpportunityLineItems WHERE Initial_Quantity__c > 0) //US843 - added a filter to skip deal products if initial quantity is 0 or null
                                 FROM Opportunity
                                 WHERE id IN: dealIds 
                                 limit 10000];
        if (!lstOpportunity.isEmpty()) {
        dealRecord = lstOpportunity[0];
        dealProductRecords = dealRecord.OpportunityLineItems;
        }
        
        for(OpportunityLineItem op : dealProductRecords){
           dealProductRecordIds.add(op.Id); 
        }
        system.debug('dealProductRecords -----------'+dealProductRecordIds.size());
        
        try{
             if(dealRecord.Account.Planning_Customer__c == false
                 ||(dealRecord.Account.Status__c!=CRM_AppConstants.ACCOUNT_STATUS_ACTIVE && dealRecord.Account.Status__c!=CRM_AppConstants.ACCOUNT_STATUS_EXPLANNING)
               )
            {
                 throw new CRM_GenerateOrderFromDealControllerException(Label.CRM_Restrict_Order_Generation_for_Filter);
            }
            
             /*Japan Defect #3925 */
            if(dealRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && (dealRecord.StageName != CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED  && dealRecord.StageName != CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT  )){
             
                throw new CRM_GenerateOrderFromDealControllerException(Label.CRM_Restrict_Order_Generation_for_Japan);
            }

            Id orderId = generateOrder();
            
            LineItemRecords rec = new LineItemRecords();
            
            rec.urlToReturn = '/'+orderId+'/e?retURL=%2F'+orderId;
            rec.dealProductIds = dealProductRecordIds;
            
            return rec;

        }
        catch(Exception e){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            //ApexPages.addMessage(myMsg);
            //Defect#4565 : page msg was not shown previously
            throw new CRM_GenerateOrderFromDealControllerException(e.getMessage());
            return null; 
        }
    }
    
    Public static Id generateOrder(){
        
        Order orderRec = new Order();
        system.debug('dealRecord-------------------'+dealRecord);
        if(dealRecord != null){
            if(dealRecord.Account.Revenue_Share__c ==  true && 
               dealRecord.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && 
               dealRecord.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE){
                 orderRec.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_REV_SHARE;       
            }else{
                orderRec.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_STANDARD;
            }
            //if customer delivery date is not black for germany
            if((dealRecord.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || 
                dealRecord.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE) &&
                dealRecord.Customer_Delivery_Date__c != null
            ){
                orderRec.EffectiveDate = dealRecord.Customer_Delivery_Date__c;
                
            }else{
                system.debug('inside else statment');
                //US#846 - set EffeectedDate(Requested Delivery date) should be today + 1 for JP if promo date is in future.
                orderRec.EffectiveDate = dealRecord.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && dealRecord.Start_Date__c > System.Today()
                                           ? System.today() + 1: dealRecord.Start_Date__c;
                                          
                                            
                //US#846 ENDS
            }
                orderRec.AccountId = dealRecord.AccountId;
                orderRec.Status = CRM_AppConstants.ORDER_STATUS_OPEN;
                orderRec.OpportunityId = dealRecord.Id;
                orderRec.Pricebook2Id = dealRecord.Pricebook2Id;
                orderRec.CurrencyIsoCode = dealRecord.CurrencyIsoCode;
                orderRec.BillingCity = dealRecord.Account.BillingCity;
                orderRec.BillingCountry =dealRecord.Account.BillingCountry;
                orderRec.BillingPostalCode = dealRecord.Account.BillingPostalCode;
                orderRec.BillingStreet = dealRecord.Account.BillingStreet;
                orderRec.ShippingCity =dealRecord.Account.ShippingCity;
                orderRec.ShippingState =dealRecord.Account.ShippingState;
                orderRec.ShippingCountry =dealRecord.Account.ShippingCountry;
                orderRec.ShippingPostalCode = dealRecord.Account.ShippingPostalCode;
        }
        if(orderRec != null){
            insert orderRec;
        }
 
        return orderRec.Id;
    }

    @RemoteAction
    public static ProductSaveError[] generateOrderProducts(Id orderId,Id[] dealProdIds){
        List<OrderItem> lstorderProductsToInsert = new List<OrderItem>();
            //US843 - added Initial_Quantity__c field in query and filter records where Initial_Quantity__c >0 
            List<OpportunityLineItem> lstdealproducts = [SELECT Id,opportunity.Sales_Organisation__c,Initial_Quantity__c, Quantity,UnitPrice,PricebookEntryId,Promoted_Price__c,Handling_Fee__c 
                                                            FROM OpportunityLineItem 
                                                            WHERE Id IN:dealProdIds];
            for(OpportunityLineItem dealprod : lstdealproducts){
                OrderItem orderProduct = new OrderItem();
                if(dealprod.opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE){
                    if(dealprod.Handling_Fee__c != null){
                        orderProduct.UnitPrice = dealprod.Handling_Fee__c;
                        
                    }else{
                        orderProduct.UnitPrice = 0;
                    }
                }else{
                    orderProduct.UnitPrice = dealprod.Promoted_Price__c;
                }
                orderProduct.OrderId = orderId;
                //orderProduct.Quantity = dealprod.Quantity;
                //US843 start
                orderProduct.Quantity = dealprod.Initial_Quantity__c;
                 //US843 Ends
                orderProduct.PricebookEntryId = dealprod.PricebookEntryId;
                
               lstorderProductsToInsert.add(orderProduct);
            }
            
            if(!lstorderProductsToInsert.isEmpty()){
                //insert lstorderProductsToInsert;
                Database.SaveResult[] orderProdInsertResults = Database.insert(lstorderProductsToInsert, false);
                return getSaveErrors(orderProdInsertResults, lstorderProductsToInsert);
            }else{
                return null;
            }
    }
    
     private static ProductSaveError[] getSaveErrors(Database.SaveResult[] saveResults, OrderItem[] lstorderProductsToInsert) {
        ProductSaveError[] errors = new ProductSaveError[]{};
        Map<Id,String> mapPricebookEntryError = new Map<Id,String>(); 
         
        for(Integer i=0; i< saveResults.size(); i++) {
            if(!saveResults[i].isSuccess()) {
                ProductSaveError err = new ProductSaveError();
                err.error = saveResults[i].getErrors()[0].getMessage();
                errors.add(err);
            }
        }
       
        return errors;
    }
    public class ProductSaveError {
        public String productCode {get;set;}
        public String productName {get;set;}
        public String error {get;set;}
    }
        
    public class LineItemRecords{
        public List<Id> dealProductIds{get;set;}
        public String urlToReturn{get;set;}
    }
    
    public class CRM_GenerateOrderFromDealControllerException extends Exception {
    }
}