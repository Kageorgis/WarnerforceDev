/**
   @Author-Cognizant Technology Solutions
   @name-CRM_DealProductPricing
   @CreateDate-<Date>
   @Description-The class is used to calculates the Account Price on Deal Product using applicable List Price and Discount Percentage.
   @Description-CRM_ProductPricingHandler methods are called to fetch the applicable discount percentage and list price
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_UpdateDealProductPricing {

    /**
    *  @Description - This method call the update pricing fields functionality for insert - update operation respectively
    *  @name - updateDealProductPrices
    *  @return - void
    **/
    public Map<Id,OpportunityLineItem> oldDPMap = new Map<Id,OpportunityLineItem>();
    public void updateDealProductPrices(Map<Id,OpportunityLineItem> oldDealProductsMap, OpportunityLineItem[] newDealProducts) {
        Set<Id> setNewDealProductIds = new  Set<Id>();  
        if(oldDealProductsMap == null || oldDealProductsMap.size() == 0) {
            generateDealProductPricingWrapper(newDealProducts,true);
        } 
        else {
            OpportunityLineItem[] listImpactedDealProducts = new OpportunityLineItem[]{};
            for(OpportunityLineItem newDP : newDealProducts) {                   
                if(newDP.ListPrice__c != oldDealProductsMap.get(newDP.Id).ListPrice__c || newDP.Account_Price__c != oldDealProductsMap.get(newDP.Id).Account_Price__c) {
                    listImpactedDealProducts.add(newDP);
                }

                if (
                        (oldDealProductsMap.get(newDP.id).Handling_Fee__c != newDP.Handling_Fee__c ||
                        oldDealProductsMap.get(newDP.id).Rental_Price__c != newDP.Rental_Price__c ||
                        oldDealProductsMap.get(newDP.id).Revenue_Share__c != newDP.Revenue_Share__c ||
                        oldDealProductsMap.get(newDP.id).Number_of_Rentals_per_Unit__c != newDP.Number_of_Rentals_per_Unit__c ||
                        oldDealProductsMap.get(newDP.id).Final_Purchase_Price__c != newDP.Final_Purchase_Price__c ||
                        oldDealProductsMap.get(newDP.id).Final_Purchase__c != newDP.Final_Purchase__c)
                ) {
                    if (newDP.Override_Pricing__c && newDP.Account_Plan__c !=null) {
                        setNewDealProductIds.add(newDP.id);
                    } else if (!CRM_ApplicationUtility.isInvokedByNRBatch && !newDP.Override_Pricing__c) {
                        newDP.addError(System.label.CRM_Set_Override_Pricing_Error);
                    }
                }

                // Req#790
                if (
                        oldDealProductsMap.get(newDP.id).Initial_Quantity__c != newDP.Initial_Quantity__c &&
                        oldDealProductsMap.get(newDP.id).Initial_Quantity__c != null && 
                        newDP.Initial_Quantity__c == null
                        
                ) {
                    newDP.Initial_Quantity__c = 0;
                }
                if (
                        oldDealProductsMap.get(newDP.id).Replen_Quantity__c != newDP.Replen_Quantity__c &&
                        oldDealProductsMap.get(newDP.id).Replen_Quantity__c != null && 
                        newDP.Replen_Quantity__c == null
                        
                ) {
                    newDP.Replen_Quantity__c = 0;
                }
                if (
                        oldDealProductsMap.get(newDP.id).Initial_Back_Order_Quantity__c != newDP.Initial_Back_Order_Quantity__c &&
                        oldDealProductsMap.get(newDP.id).Initial_Back_Order_Quantity__c != null && 
                        newDP.Initial_Back_Order_Quantity__c == null
                        
                ) {
                    newDP.Initial_Back_Order_Quantity__c = 0;
                }
            }

            if(!listImpactedDealProducts.isEmpty()){
                oldDPMap = oldDealProductsMap;
                generateDealProductPricingWrapper(listImpactedDealProducts,false);
            }
            system.debug('setNewDealProductIds::::::::::::'+setNewDealProductIds.size());
            if (!setNewDealProductIds.isEmpty()) {
                updateTargetQtyOnDealProducts(newDealProducts,setNewDealProductIds);
            }
        }
    }
    
   /**Japan Change DEF#3926
    *  @Description - This method updates deal products with before update
    *  @name - updateTargetQtyOnDealProducts
    *  @return - void
    **/
    public void updateTargetQtyOnDealProducts( List<OpportunityLineItem> newlstOppoItems, Set<Id> setNewDealProductIds){
        map<Id,OpportunityLineItem> mapOfDPIdToDealProd = new map<Id,OpportunityLineItem>(); 
        mapOfDPIdToDealProd = getDealProductsWithAccPlans(setNewDealProductIds);
        for(OpportunityLineItem newDP : newlstOppoItems) {      
            Decimal price = newDP.Rental_Revenue_Per_Unit__c;
            if(
                    newDP.Account_Plan__c != null && mapOfDPIdToDealProd.containsKey(newDP.id) &&
                    mapOfDPIdToDealProd.get(newDP.Id) != null && mapOfDPIdToDealProd.get(newDP.id).Account_Plan__c != null
            ) {
                Account_Plan__c accPlanInstance = mapOfDPIdToDealProd.get(newDP.id).Account_Plan__r;
                System.debug('--accPlanInstance--->'+accPlanInstance);
                if(
                        accPlanInstance != null && price != null && price > 0 &&
                        accPlanInstance.Total_Target__c != null && accPlanInstance.Total_Target__c  > 0 &&
                        (accPlanInstance.Country_Plan__r.Target_Quantity__c  == null || accPlanInstance.Country_Plan__r.Target_Quantity__c == 0)
                ) {
                    newDP.Target_Quantity__c = Math.ceil(accPlanInstance.Total_Target__c / price);
                    //Defect#4557 - code snnipet to store value without ceil method in new field actual target quantity.
                    newDP.Actual_Target_Quantity__c = accPlanInstance.Total_Target__c / price;
                }
            }
        }
    }

    /**Japan Change DEF#3926
    *  @Description - This method retrieves Account Plans specific to the products before update
    *  @name - getAccountPlans
    *  @return - Map<Id,Account_Plan__c>
    **/
    private static Map<Id,OpportunityLineItem> getDealProductsWithAccPlans(Set<Id> setOfDealProductIds){
        map<Id,OpportunityLineItem> mapOfIdToDealProd = new map<Id, OpportunityLineItem>();
        List<OpportunityLineItem> lstDealProducts =
            new List<OpportunityLineItem>([
                SELECT
                    Id, Account_Plan__c, Account_Plan__r.Total_Target__c, Product2Id,
                    Account_Plan__r.Country_Plan__c, Account_Plan__r.Country_Plan__r.Target_Quantity__c
                FROM OpportunityLineItem
                WHERE Id IN : setOfDealProductIds 
                AND Account_Plan__r.RecordType.Name =: CRM_AppConstants.RENTAL_ACCOUNT_PLAN
                AND Product2.Product_Market__c =:  CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE
                AND Opportunity.Sales_Organisation__c =: CRM_AppConstants.TERRITORY_JAPAN_CODE
            ]);
        system.debug('===>> List of lstDealProducts' + lstDealProducts.size()); 
    for(OpportunityLineItem dealPro : lstDealProducts){
       mapOfIdToDealProd.put(dealPro.id,dealPro);
     }       
      return mapOfIdToDealProd;
  } 
  
     /**
    *  @Description - This method prepares data specific to Costing and invokes the related functionality.
    *  @name - generateDealProductPricingWrapper
    *  @return - Method created to invoke the HandlerClasses from outside without using the trigger
    **/
    public void generateDealProductPricingWrapper(List<OpportunityLineItem> lstDealProduct, Boolean flag){
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        Map<Id,Opportunity> mapDeals = getOpportunities(lstDealProduct);
        Set<Id> assortmentProAndAccIds = new Set<Id>();
         
        CRM_ProductPricingHandler.DealWrapper dw;
        
        for(OpportunityLineItem oli : lstDealProduct) {
            Boolean validInsertUpdate =
                flag ||
                (
                    !flag && 
                    (
                        (
                            mapDeals.get(oli.OpportunityId).Bundle__c != null && mapDeals.get(oli.OpportunityId).Bundle__r.RecordTypeId != null &&
                            mapDeals.get(oli.OpportunityId).Bundle__r.RecordTypeId != CRM_RecordTypeUtil.RT_Promotional_Assortment
                        ) ||
                        oli.ListPrice__c != oldDPMap.get(oli.id).ListPrice__c
                    ) 
                ) ||
                (
                    !flag && 
                    mapDeals.get(oli.OpportunityId).Bundle__c != null && mapDeals.get(oli.OpportunityId).Bundle__r.RecordTypeId != null &&
                    mapDeals.get(oli.OpportunityId).Bundle__r.RecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment &&
                    oldDPMap != null && oli.id != null && oldDPMap.containsKey(oli.id) &&
                    (
                        oli.Account_Price__c != oldDPMap.get(oli.id).Account_Price__c ||
                        oli.ListPrice__c != oldDPMap.get(oli.id).ListPrice__c
                    )
            );
            if (validInsertUpdate) {
                dw = new CRM_ProductPricingHandler.DealWrapper();
                dw.dealId = oli.OpportunityId;
                dw.accountId = mapDeals.get(oli.OpportunityId).AccountId;
                dw.dealCurrency = mapDeals.get(oli.OpportunityId).CurrencyISOCode;
                dw.productId =oli.Product2Id;
                dw.pricebookId = mapDeals.get(oli.OpportunityId).Pricebook2Id;
                dw.dealStartDate = mapDeals.get(oli.OpportunityId).Start_Date__c;
                dw.dealEndDate = mapDeals.get(oli.OpportunityId).CloseDate;
                dw.dealProduct = oli;
                dw.dealRecordTypeId = mapDeals.get(oli.OpportunityId).RecordTypeId;
                if(mapDeals.get(oli.OpportunityId).Bundle__c != null && mapDeals.get(oli.OpportunityId).Bundle__r.RecordTypeId != null) {
                    dw.assoertmentRTId =  mapDeals.get(oli.OpportunityId).Bundle__r.RecordTypeId;
                }
                assortmentProAndAccIds.add(dw.accountId);
                assortmentProAndAccIds.add(dw.productId);
                listDealWrappers.add(dw);
            }
        }

        if(!listDealWrappers.isEmpty()){            
           updatePricingFields(listDealWrappers,mapDeals,flag,assortmentProAndAccIds);
        }
    }
    
        /**
        *  @Description - The method set all the pricing fields on Deal Product
        *  @name - updatePricingFields
        *  @return - void
    */
    public void updatePricingFields(
            CRM_ProductPricingHandler.DealWrapper[] listDealWrappers,
            Map<Id,Opportunity> mapDeals,
            Boolean recInsertFlag,
            Set<Id> assortmentProAndAccIds
    ) {

        Id digitalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        Id physicalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        
        Map<String,Bundle_Product__c> assortmentProductMap = new Map<String,Bundle_Product__c>();
        Map<String,Assortment_Account__c> assortmentAccountMap = new Map<String,Assortment_Account__c>();
        
        if(!listDealWrappers.isEmpty()){
            CRM_ProductPricingHandler instance = new CRM_ProductPricingHandler(listDealWrappers);
            //Assortment List
            List<Bundle__c> assortmentList = getAssortments(mapDeals,assortmentProAndAccIds);
            // US#787
            Map<Id,Bundle__c> assortmentMap = new Map<Id,Bundle__c>(assortmentList);

            //Assortment Product Map (Key => bundleId+'-'+ProductID , Value => Asoertment Product)
            assortmentProductMap = getAssortmentProducts(assortmentList);
            //Assortment Account Map (Key => bundleId+'-'+AccountId , Value => null)
            assortmentAccountMap = getAssortmentAccounts(assortmentList);

            // for insert
            if(recInsertFlag){
                for(CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers) {
                    
                    Pricebook_Entry_Period__c pbep = instance.getProductDatedPricebookEntryPeriod(dw);
                    system.debug('-----pbep----> : '+pbep);
                    if(pbep == null && 
                        (dw.dealRecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || dw.dealRecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL || 
                        dw.dealRecordTypeId == CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL || dw.dealRecordTypeId == CRM_RecordTypeUtil.RT_DEAL_RBA))     // US#787
                        dw.dealProduct.addError(Label.CRM_Assortment_PBEP_Not_Found);
                    
                    if (!dw.dealProduct.Manually_Schedule__c && dw.dealProduct.Initial_Quantity__c == null && dw.dealProduct.Replen_Quantity__c == null) {
                        if (dw.dealRecordTypeId == physicalDealRecordTypeId) {
                            dw.dealProduct.Initial_Quantity__c = dw.dealProduct.Quantity;
                        } else if (dw.dealRecordTypeId == digitalDealRecordTypeId) {
                            dw.dealProduct.Replen_Quantity__c = dw.dealProduct.Quantity;
                        }
                    }

                    // Set ePos Quantity as 1 for NR Deals whose Account is a Consignment Customer
                    //DEFECT: #3758 Condition Removed (dw.dealProduct.NR_Deal_Product_Unique_Key__c != null).
                    if (dw.dealProduct.P_L_Quantity__c == null) {
                        if (
                            mapDeals.containsKey(dw.dealProduct.OpportunityId) &&
                            mapDeals.get(dw.dealProduct.OpportunityId) != null &&
                            mapDeals.get(dw.dealProduct.OpportunityId).AccountId != null &&
                            mapDeals.get(dw.dealProduct.OpportunityId).Account.Consignment_Customer__c
                        ) {
                            dw.dealProduct.P_L_Quantity__c = 1;
                        }
                    }

                    Decimal promotedPrice = 0;
                    //Assortment Product Map Key
                    String assortmentProKey = (mapDeals.get(dw.dealId).Bundle__c != null ? mapDeals.get(dw.dealId).Bundle__c : null)+'-'+dw.productId;
                    //Assortment Account Map Key
                    String assortmentAccKey = (mapDeals.get(dw.dealId).Bundle__c != null ? mapDeals.get(dw.dealId).Bundle__c : null)+'-'+dw.accountId;

                    //#US463 
                    Decimal fileDiscountPerc = instance.getFileDiscountPercentage(dw, pbep);
                    dw.dealProduct.File_Discount__c = fileDiscountPerc;

                    //US#460: Start of Change
                    if(
                            dw.assoertmentRTId != null && dw.assoertmentRTId == CRM_RecordTypeUtil.RT_Promotional_Assortment && 
                            assortmentProductMap.containsKey(assortmentProKey) && 
                            //assortmentAccountMap.containsKey(assortmentAccKey) &&
                            assortmentProductMap.get(assortmentProKey).Bundle__c != null &&
                            assortmentProductMap.get(assortmentProKey).Bundle__r.Pricing_Method__c == CRM_AppConstants.ASSORTMENT_PRICING_MODE_NET_PRICE
                    ){
                        //#US463 removed and added above
                        //Decimal fileDiscountPerc = instance.getFileDiscountPercentage(dw);
                        /*dw.dealProduct.ListPrice__c = (assortmentProductMap.get(assortmentProKey).Assortment_Price__c != null ? assortmentProductMap.get(assortmentProKey).Assortment_Price__c : 0);
                        dw.dealProduct.Account_Price__c = dw.dealProduct.ListPrice__c * (1-(fileDiscountPerc/100));
                        promotedPrice = dw.dealProduct.Account_Price__c;
                        dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                        dw.dealProduct.UnitPrice = dw.dealProduct.Account_Price__c;*/
                        if(CRM_ApplicationUtility.isDigitalAssortment(assortmentMap.get(assortmentProductMap.get(assortmentProKey).Bundle__c))) {   // US#787
                            dw.dealProduct.ListPrice__c = (pbep != null && pbep.Account_Price__c != null) ? pbep.Account_Price__c : dw.dealProduct.ListPrice__c;
                        }
                        else
                            dw.dealProduct.ListPrice__c = pbep != null ? pbep.List_Price__c : 0;
                        dw.dealProduct.Account_Price__c =
                            (
                                dw.dealProduct.Account_Price__c != null
                                ? dw.dealProduct.Account_Price__c
                                : (assortmentProductMap.get(assortmentProKey).Assortment_Price__c != null ? assortmentProductMap.get(assortmentProKey).Assortment_Price__c : 0)
                            );
                        dw.dealProduct.Account_Price__c = dw.dealProduct.Account_Price__c.setScale(2);
                        promotedPrice = dw.dealProduct.Promoted_Price__c == null ? dw.dealProduct.Account_Price__c : dw.dealProduct.Promoted_Price__c;
                        dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                        dw.dealProduct.UnitPrice = dw.dealProduct.Account_Price__c;
                        if(pbep != null && dw.dealProduct.Pricebook_Entry_Period__c != pbep.id) {
                            dw.dealProduct.Pricebook_Entry_Period__c = pbep.id;
                        }
                    }//US#460: End of Change
                    // US#241: Start of Change
                    // Prices for deals created via published assortments
                    else if(
                            (
                                dw.dealProduct.UniquePublishKey__c != null || 
                                (dw.assoertmentRTId != null && dw.assoertmentRTId == CRM_RecordTypeUtil.RT_Promotional_Assortment)
                            ) && assortmentProductMap.containsKey(assortmentProKey)
                    ) { // To identify if the deal product is created by publish logic
                        // only update Account Price and Promo Price and keep the list price as it is
                        //#US463 removed and added above
                        //Decimal fileDiscountPerc = instance.getFileDiscountPercentage(dw);
                        dw.dealProduct.ListPrice__c =
                            (
                                dw.dealProduct.ListPrice__c != null
                                ? dw.dealProduct.ListPrice__c
                                : (assortmentProductMap.get(assortmentProKey).Assortment_Price__c != null ? assortmentProductMap.get(assortmentProKey).Assortment_Price__c : 0)
                            ); 
                        dw.dealProduct.Account_Price__c = dw.dealProduct.ListPrice__c * (1-(fileDiscountPerc/100));
                        dw.dealProduct.Account_Price__c = dw.dealProduct.Account_Price__c.setScale(2);
                        promotedPrice = dw.dealProduct.Promoted_Price__c == null ? dw.dealProduct.Account_Price__c : dw.dealProduct.Promoted_Price__c;
                        dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                        dw.dealProduct.UnitPrice = dw.dealProduct.Account_Price__c;
                    }else if(pbep != null && dw.dealProduct.NR_Deal_Product_Unique_Key__c == null) { // Set Prices only for Non NR Deal Products insert
                        if (dw.dealRecordTypeId == digitalDealRecordTypeId) {
                            dw.dealProduct.ListPrice__c = pbep.Account_Price__c != null ? pbep.Account_Price__c : pbep.List_Price__c;
                        } else {
                            dw.dealProduct.ListPrice__c = pbep.List_Price__c;
                        }
                        dw.dealProduct.Minimum_Price__c = pbep.Minimum_Price__c;
                        dw.dealProduct.SR_Price__c = pbep.SR_Price__c;  //#768
                        dw.dealProduct.Vendor_ID__c = pbep.Vendor_ID__c;  //#768
                        //dw.dealProduct.Customer_Retail_Price__c = pbep.Retail_Price__c;
                        dw.dealProduct.Account_Price__c = instance.getAccountPrice(dw);
                        dw.dealProduct.Account_Price__c = dw.dealProduct.Account_Price__c.setScale(2);
                        
                        if (dw.dealProduct.Promoted_Price__c == null) {// added by rmn
                            promotedPrice =dw.dealProduct.Account_Price__c; 
                            //US#895 -commneted code as a part of us to remove reference of suggested price
                            //  pbep.Suggested_Price__c != null ? pbep.Suggested_Price__c :  
                            dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                        }
                        
                        dw.dealProduct.UnitPrice = dw.dealProduct.Account_Price__c;
                        
                        if(dw.dealProduct.Pricebook_Entry_Period__c != pbep.id) {
                            dw.dealProduct.Pricebook_Entry_Period__c = pbep.id;
                        }
                    }
                    // US#241: End of Change
                
                }
            }
            
            // for Update
            if(!recInsertFlag){

                for(CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers) {
                    Decimal promotedPrice = 0;
                    //#US463
                    Pricebook_Entry_Period__c pbep = instance.getProductDatedPricebookEntryPeriod(dw);
                    Decimal fileDiscountPerc = instance.getFileDiscountPercentage(dw, pbep);
                    dw.dealProduct.File_Discount__c = fileDiscountPerc;

                    if (dw.assoertmentRTId != null && dw.assoertmentRTId == CRM_RecordTypeUtil.RT_Promotional_Assortment) {

                        //Assortment Product Map Key
                        String assortmentProKey = (mapDeals.get(dw.dealId).Bundle__c != null ? mapDeals.get(dw.dealId).Bundle__c : null)+'-'+dw.productId;
                        //Assortment Account Map Key
                        String assortmentAccKey = (mapDeals.get(dw.dealId).Bundle__c != null ? mapDeals.get(dw.dealId).Bundle__c : null)+'-'+dw.accountId;

                        if (
                                assortmentProductMap.containsKey(assortmentProKey) && 
                                //assortmentAccountMap.containsKey(assortmentAccKey) &&
                                assortmentProductMap.get(assortmentProKey).Bundle__c != null &&
                                assortmentProductMap.get(assortmentProKey).Bundle__r.Pricing_Method__c == CRM_AppConstants.ASSORTMENT_PRICING_MODE_NET_PRICE
                        ) {
                        if(CRM_ApplicationUtility.isDigitalAssortment(assortmentMap.get(assortmentProductMap.get(assortmentProKey).Bundle__c))) {   // US#787
                            dw.dealProduct.ListPrice__c = (pbep != null && pbep.Account_Price__c != null) ? pbep.Account_Price__c : dw.dealProduct.ListPrice__c;
                        }else{
                            dw.dealProduct.ListPrice__c = pbep != null ? pbep.List_Price__c : 0;
                        }
                            dw.dealProduct.Account_Price__c =
                                (
                                    dw.dealProduct.Account_Price__c != null
                                    ? dw.dealProduct.Account_Price__c
                                    : (assortmentProductMap.get(assortmentProKey).Assortment_Price__c != null ? assortmentProductMap.get(assortmentProKey).Assortment_Price__c : 0)
                                );
                            dw.dealProduct.Account_Price__c = dw.dealProduct.Account_Price__c.setScale(2);
                            promotedPrice = dw.dealProduct.Promoted_Price__c == null ? dw.dealProduct.Account_Price__c : dw.dealProduct.Promoted_Price__c;
                            dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                            dw.dealProduct.UnitPrice = dw.dealProduct.Account_Price__c;
                            if(pbep != null && dw.dealProduct.Pricebook_Entry_Period__c != pbep.id) {
                                dw.dealProduct.Pricebook_Entry_Period__c = pbep.id;
                            }
                        } else {
                            dw.dealProduct.ListPrice__c =
                                (
                                    dw.dealProduct.ListPrice__c != null
                                    ? dw.dealProduct.ListPrice__c
                                    : (assortmentProductMap.get(assortmentProKey).Assortment_Price__c != null ? assortmentProductMap.get(assortmentProKey).Assortment_Price__c : 0)
                                );
                            dw.dealProduct.Account_Price__c = dw.dealProduct.ListPrice__c * (1-(fileDiscountPerc/100));
                            dw.dealProduct.Account_Price__c = dw.dealProduct.Account_Price__c.setScale(2);
                            promotedPrice = dw.dealProduct.Promoted_Price__c == null ? dw.dealProduct.Account_Price__c : dw.dealProduct.Promoted_Price__c;
                            dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                            dw.dealProduct.UnitPrice = dw.dealProduct.Account_Price__c;
                        }
                    } else {
                        // US#241: Start of Change
                        // Prices for deals created via published assortments
                        if(dw.dealProduct.UniquePublishKey__c != null && dw.dealProduct.Last_Published_Date__c != oldDPMap.get(dw.dealProduct.id).Last_Published_Date__c) { // To identify if the deal product is created by publish logic
                            // only update Account Price and Promo Price and keep the list price as it is
                            //Decimal fileDiscountPerc = instance.getFileDiscountPercentage(dw);
                            dw.dealProduct.ListPrice__c = (dw.dealProduct.ListPrice__c != null ? dw.dealProduct.ListPrice__c : 0); 
                            dw.dealProduct.Account_Price__c = dw.dealProduct.ListPrice__c * (1-(fileDiscountPerc/100));
                            dw.dealProduct.Account_Price__c = dw.dealProduct.Account_Price__c.setScale(2);
                            if(!oldDPMap.isEmpty()){
                                //Defect No #3829 && dw.dealProduct.Promoted_Price__c == oldDPMap.get(dw.dealProduct.id).Account_Price__c
                                if(oldDPMap.get(dw.dealProduct.id) != null && dw.dealProduct.Promoted_Price__c == oldDPMap.get(dw.dealProduct.id).Promoted_Price__c) {
                                    promotedPrice = dw.dealProduct.Account_Price__c;
                                    dw.dealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                                }
                            }
                        }
                        // US#241: End of change
                    }
                }
            }
        }
    }
        /**
        *  @Description - The method prepares a (map) collection of Deal Id and the Information of Deal
        *  @name - getOpportunities
        *  @return - return a collection of Deal Id and Deal Information
    */
    private Map<Id,Opportunity> getOpportunities(OpportunityLineItem[] dealProds) {
        Map<Id,Opportunity> mapOppLineItems = new Map<Id,Opportunity>();
         
        for(OpportunityLineItem oli : dealProds) {
            mapOppLineItems.put(oli.OpportunityId, null);
        }
        
        mapOppLineItems = new Map<Id,Opportunity>([select Id,Account.Consignment_Customer__c,Bundle__c,Bundle__r.RecordTypeId,Start_Date__c, RecordTypeId, CloseDate, Pricebook2Id, CurrencyISOCode, AccountId
                        from Opportunity 
                        where Id IN: mapOppLineItems.keySet()]);
                        
        return mapOppLineItems;
    }
    
    /**
        *  @Description - The method prepares a (List) collection of Assortment
        *  @name - getAssortments
        *  @return - return a collection of Assortment
    */
    private List<Bundle__c> getAssortments(Map<Id,Opportunity> dealMap,Set<Id> assortmentProAndAccIds){
        Set<Id> assortmentId = new Set<Id>();
        List<Bundle__c> assortmentlst = new List<Bundle__c>();
        
        if(dealMap.size() > 0){
            for(Opportunity opp : dealMap.values()){
                if(opp.Bundle__c != null)
                    assortmentId.add(opp.Bundle__c);
            }
            if(assortmentId.size() > 0)
                assortmentlst = [Select Id, Price_Book__c, Price_Book__r.Product_Type__c,
                                 (Select Id,Assortment_Price__c,Bundle__c,Product__c, Bundle__r.Pricing_Method__c From Bundle_Products__r Where Product__c IN :assortmentProAndAccIds),
                                 (Select Id,Assortment__c,Account__c From Assortment_Accounts__r Where Account__c IN :assortmentProAndAccIds)
                                 From Bundle__c
                                 Where ID IN :assortmentId];
                    
        }
        return assortmentlst;
    } 
    
    /**
        *  @Description - The method prepares a (map) collection of Assortment Product
        *  @name - getAssortmentProducts
        *  @return - return a collection of Assortment Product
    */
    private Map<String,Bundle_Product__c> getAssortmentProducts(List<Bundle__c> assortmentlst){
        
        Map<String,Bundle_Product__c> assoertmentProductMap = new Map<String,Bundle_Product__c>();
        List<Bundle_Product__c> assortmentPro = new List<Bundle_Product__c>();
        
        if(assortmentlst.size() > 0){
            for(Bundle__c assortment : assortmentlst){
                if(assortment.Bundle_Products__r != null)
                    assortmentPro.addAll(assortment.Bundle_Products__r);
            }
            
            if(assortmentPro.size() > 0){
                for(Bundle_Product__c ap : assortmentPro){
                    String mapKey = ap.Bundle__c+'-'+ap.Product__c;
                    assoertmentProductMap.put(mapKey,ap);
                }
            }
        }
        return assoertmentProductMap;
    } 
    
    /**
        *  @Description - The method prepares a (map) collection of Assortment Account
        *  @name - getAssortmentAccounts
        *  @return - return a collection of Assortment Account
    */
    private Map<String,Assortment_Account__c> getAssortmentAccounts(List<Bundle__c> assortmentlst){
        Map<String,Assortment_Account__c> assoertmentAcountMap = new Map<String,Assortment_Account__c>();
        List<Assortment_Account__c> assortmentAcc = new List<Assortment_Account__c>();
        
        if(assortmentlst.size() > 0){
            for(Bundle__c assortment : assortmentlst){
                if(assortment.Assortment_Accounts__r != null)
                        assortmentAcc.addAll(assortment.Assortment_Accounts__r);
            }
            
            if(assortmentAcc.size() > 0){
                for(Assortment_Account__c aa : assortmentAcc){
                    String mapKey = aa.Assortment__c+'-'+aa.Account__c;
                    assoertmentAcountMap.put(mapKey,null);
                }
            }
        }
        return assoertmentAcountMap;
    } 
}