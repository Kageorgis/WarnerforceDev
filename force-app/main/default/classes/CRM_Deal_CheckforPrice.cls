/**
@Author: Accenture
@name: CRM_Deal_CheckforPrice
@CreateDate: June 25, 2020
@Description:  Controller class for Lightning Component 'CRM_Deal_CheckforPrice' to show the upcoming/future Pricebook entry periods for 
				those particular Deal Products on 'Check for Price' button click on Deal
@Version - 1.0
@reference: None
*/

public with sharing class CRM_Deal_CheckforPrice {
    /** 
    *  Method to fetch the NewPriceWrapper details for the Deal Products
    *  @name getNewPriceDetails
    *  @param Deal Id
    *  @return NewPriceWrapper Wrapper
    *  @throws none
	*/ 
    @AuraEnabled
    public static String getNewPriceDetails(Id oppId) {
        NewPriceWrapper newPriceWrap = new NewPriceWrapper();
        Opportunity oppRecord = new Opportunity();
        String result = '';
        Map<Id, List<OpportunityLineItem>> productIdvsDealProductMap = new Map<Id, List<OpportunityLineItem>>(); //Map to store the Product Id reference (as key) and the Deal Product(s) associated to it (as value)
        
        try{
            //Querying the current Deal Record
            oppRecord = [SELECT Id, Name, Deal_Code__c, Account.Name, Account.Class_of_Trade__c, Start_Date__c, CloseDate FROM Opportunity WHERE Id =: oppId LIMIT 1];
            System.debug('oppRecord = ' + oppRecord);
            Integer queryLimitCount = Limits.getLimitQueryRows() - Limits.getQueryRows();
            
            //Querying the Deal Products for the current Deal Record
            for(OpportunityLineItem oli : [Select Id, Name, Product2Id, Product2.Name, Product_Code__c, Commitment_Number__c, Start_Date__c, End_Date__c, System_Cost__c, OpportunityId, CurrencyIsoCode FROM OpportunityLineItem WHERE OpportunityId=:oppId LIMIT:queryLimitCount]){
                if(!productIdvsDealProductMap.containsKey(oli.Product2Id)){
                    productIdvsDealProductMap.put(oli.Product2Id, new List<OpportunityLineItem>{oli});
                }else{
                    List<OpportunityLineItem> dealProductList = productIdvsDealProductMap.get(oli.Product2Id);
                    dealProductList.add(oli);
                    productIdvsDealProductMap.put(oli.Product2Id, dealProductList);
                }
            }
        	System.debug('productIdvsDealProductMap = ' + productIdvsDealProductMap);
            queryLimitCount = Limits.getLimitQueryRows() - Limits.getQueryRows();
            
            newPriceWrap.dealRecord = oppRecord;
            newPriceWrap.msgText = productIdvsDealProductMap.size()==0?Label.CRM_Check_Reprice_No_Deal_Product:'';
            newPriceWrap.msgSeverity = productIdvsDealProductMap.size()==0?'error':'';
            
            if(productIdvsDealProductMap.size()>0){
                newPriceWrap = buildFuturePriceWrapper(productIdvsDealProductMap, oppRecord);
            }
        }catch(Exception ex){
            newPriceWrap.msgSeverity = 'error';
            newPriceWrap.msgText = ex.getMessage();
        }
        System.debug('newPriceWrap = ' + newPriceWrap);
        
        //Serialize the JSON into a string and return the data
        result = JSON.serialize(newPriceWrap);
        System.debug('result = ' + result);
        
        return result;
    }
    
    /** 
    *  Method to build/frame the New Price Wrapper as per the NewPriceWrapper declaration
    *  @name buildFuturePriceWrapper
    *  @param productIdvsDealProductMap (Map containing the Product2 Id Reference (as Key) and the associated Deal Products to it (as value))
    *  @return NewPriceWrapper Wrapper
    *  @throws none
	*/ 
    private static NewPriceWrapper buildFuturePriceWrapper(Map<Id, List<OpportunityLineItem>> productIdvsDealProductMap, Opportunity oppRecord) {
        NewPriceWrapper newPriceWrap = new NewPriceWrapper();
        newPriceWrap.dealProductsWrapper = new List<DealProductsWrapper>();
        List<DealProductsWrapper> dealProductWrapList = new List<DealProductsWrapper>();
        List<FuturePricingWrapper> futurePricingWrapList = new List<FuturePricingWrapper>();
        DealProductsWrapper dpWrap = new DealProductsWrapper();
        FuturePricingWrapper fpWrap = new FuturePricingWrapper();
        
        Set<Id> dealProductId = new Set<Id>();
        Set<String> pbepPriceTypes = new Set<String>(); //Set variable to store the Pricebook Entry Period Price Types
        Set<String> startDateListPrice = new Set<String>(); //Set variable to store the concatenated value (concat character: pipe "|") of the Deal Product Id, Price Book Entry Period record's Start Date & the List Price.
        Map<Id, List<FuturePricingWrapper>> dealProductvsFuturePriceMap = new Map<Id, List<FuturePricingWrapper>>(); //Map to store the Deal Product Id (as key) and the future pricing detail(s) associated to it (as value)
        Integer queryLimitCount = Limits.getLimitQueryRows() - Limits.getQueryRows();
        String productId = '';
        String priceTypes = '';
        
        for(Id pId : productIdvsDealProductMap.keySet()){
            productId = productId + '\'' + String.valueOf(pId) + '\',';
        }
        productId = productId.removeEnd(',');
		
        if(String.isNotBlank(oppRecord.Account.Class_of_Trade__c)){
            pbepPriceTypes.add(oppRecord.Account.Class_of_Trade__c.toUpperCase());
            
            if(oppRecord.Account.Class_of_Trade__c==CRM_AppConstants.CLASS_OF_TRADE_RETAIL_COST){
                pbepPriceTypes.add(CRM_AppConstants.PBEP_PRICE_TYPE_PROMOTION);
                pbepPriceTypes.add(CRM_AppConstants.PBEP_PRICE_TYPE_DEALER);
            }
            
            for(String pType : pbepPriceTypes){
                priceTypes = priceTypes + '\'' + pType + '\',';
            }
            priceTypes = priceTypes.removeEnd(',');
        }else{
            priceTypes = '\'' + '\'';
        }
        
        String query = 'Select Id, Price_Type__c, Product__c, List_Price__c, Start_Date__c, CurrencyIsoCode FROM Pricebook_Entry_Period__c WHERE';
        query+= ' (Product__c IN (' + productId + ') AND Price_Type__c IN (' + priceTypes + ')'; 
        query+= ' AND Start_Date__c>=' + String.valueOf(Date.today()) + ' AND Start_Date__c<=' + String.valueOf(oppRecord.CloseDate);
        query+= ') LIMIT ' + queryLimitCount;
        System.debug('query = ' + query);
        
        try{
            //Querying the Pricebook Entry Period records for the Product records obtained above
            for(Pricebook_Entry_Period__c pbep : Database.query(query)){
            	for(OpportunityLineItem oli : productIdvsDealProductMap.get(pbep.Product__c)){
                    String uniqueDatePriceKey = oli.Id+'|'+pbep.Start_Date__c+'|'+pbep.List_Price__c;
                    if(pbep.Start_Date__c>=oli.Start_Date__c && !startDateListPrice.contains(uniqueDatePriceKey)){
                        dpWrap = new DealProductsWrapper();
                        fpWrap = new FuturePricingWrapper();
                        startDateListPrice.add(uniqueDatePriceKey);
                        
                        fpWrap.pbepId = pbep.Id;
                        fpWrap.startDate = pbep.Start_Date__c;
                        fpWrap.listPrice = pbep.CurrencyIsoCode + ' ' + String.valueOf(pbep.List_Price__c);
                        fpWrap.lineItemId = oli.Id;
                        System.debug('fpWrap = ' + fpWrap);

                        if(!dealProductvsFuturePriceMap.containsKey(oli.Id)){
                            dealProductvsFuturePriceMap.put(oli.Id, new List<FuturePricingWrapper>{fpWrap});
                        }else{
                            List<FuturePricingWrapper> fpWrapList = dealProductvsFuturePriceMap.get(oli.Id);
                            fpWrapList.add(fpWrap);
                            dealProductvsFuturePriceMap.put(oli.Id, fpWrapList);
                        }
                        System.debug('dealProductvsFuturePriceMap = ' + dealProductvsFuturePriceMap);
                        
                        if(!dealProductId.contains(oli.Id)){
                            dpWrap.lineItemId = oli.Id;
                            dpWrap.productId = oli.Product2Id;
                            dpWrap.productName = oli.Product2.Name;
                            dpWrap.productCode = oli.Product_Code__c;
                            dpWrap.commitmentNumber = oli.Commitment_Number__c;
                            dpWrap.startDate = oli.Start_Date__c;
                            dpWrap.endDate = oli.End_Date__c;
                            dpWrap.systemCost = oli.CurrencyIsoCode + ' ' + String.valueOf(oli.System_Cost__c);
                            System.debug('dpWrap = ' + dpWrap);
                            
                            dealProductId.add(oli.Id);
                            dealProductWrapList.add(dpWrap);
                        }
                        System.debug('dealProductId = ' + dealProductId);
                    }
                }
            }
            System.debug('dealProductvsFuturePriceMap = ' + dealProductvsFuturePriceMap);
            System.debug('dealProductWrapList = ' + dealProductWrapList);
            
            //Form the DealProductsWrapper Wrapper Details with FuturePricingWrapper Data
            for(DealProductsWrapper dp : dealProductWrapList){
                for(FuturePricingWrapper fpw : dealProductvsFuturePriceMap.get(dp.lineItemId)){
                    futurePricingWrapList.add(fpw);
                }
                dp.futurePrices = futurePricingWrapList;
                futurePricingWrapList = new List<FuturePricingWrapper>();
            }
            System.debug('DealProductsWrapper = ' + dealProductWrapList);
            
            //Form the NewPriceWrapper Wrapper Details with DealProductsWrapper Data
            newPriceWrap.dealRecord = oppRecord;
            newPriceWrap.dealProductsWrapper = dealProductWrapList;
            newPriceWrap.futurePricingExists = dealProductWrapList.size()!=0?true:false;
            newPriceWrap.msgSeverity = newPriceWrap.futurePricingExists?'':'warning';
            newPriceWrap.msgText = newPriceWrap.futurePricingExists?'':Label.CRM_Check_Reprice_No_Available_Data;
        }catch(Exception ex){
            newPriceWrap.msgSeverity = 'error';
            newPriceWrap.msgText = ex.getMessage();
        }

        return newPriceWrap;
    }
    
    /**
    *  @Description - wrapper class to hold the deal record, the future pricing information for the deal products, error messages if encountered
    *  @name  NewPriceWrapper 
    */
    public class NewPriceWrapper{
        public Boolean futurePricingExists{
            get; set;
        }
        public String msgSeverity{
            get; set;
        }
        public String msgText{
            get; set;
        }
        public Opportunity dealRecord{
            get; set;
        }
        public List<DealProductsWrapper> dealProductsWrapper{
            get; set;
        }
        public NewPriceWrapper(){
            this.futurePricingExists = false;
        }
    }
    
    /**
    *  @Description - wrapper class for containing the Deal Products and its corresponding future pricing mapping
    *  @name  DealProductsWrapper 
    */
    public class DealProductsWrapper{
        public Id lineItemId;
        public Id productId;
        public String productName;
        public String productCode;
        public String commitmentNumber;
        public Date startDate;
        public Date endDate;
        public String systemCost;
        public List<FuturePricingWrapper> futurePrices;
    }
    
    /**
    *  @Description - wrapper class to store the future pricing data keeping the Deal Product Id as key (for map reference)
    *  @name  FuturePricingWrapper 
    */
    public class FuturePricingWrapper{
        public Id pbepId;
        public Id lineItemId;
        public Date startDate;
        public String listPrice;
    }
}