/***************************************************************************************************************************************************************
   @Author: Aditi Satpute
   @name: CRM_AutoEstablishSchedulesHelper
   @CreateDate: 18/2/2016
   @Description: This class provides the backend logic required to generate Demand and Financial
                 Decay Curves which will create automatic schedules for deal products.
   @Version: 1.0
   @reference: Requirement No. 13 & 176
***************************************************************************************************************************************************************/

public with sharing class CRM_AutoEstablishSchedulesHelper{
    private static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    private static Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
    public static Set<String> dealProdAcctIdSet = new Set<String>();
    
    /**
     * This method Will create the deal Product Schedules for Digital / Physical deal with future callout on change of Discount.
     * @name: executeDecayCurveFuture
     * @param: Set<Id> setDealProductIds - Set of deal product Ids being inserted, updated 
     * @param: Set<Id> setProductIds - Set of Product Ids whose product street Date / PBEP Start Date is changed
     * @return None
     
    @future
    public static void executeDecayCurveFuture(Set<Id> setDealProductIds, Set<Id> setProductIds){
        createDealProductSchedule(setDealProductIds, setProductIds);
    }*/

    /**
     * This method Will create the deal Product Schedules for Digital / Physical deal.
     * @name: createDealProductSchedule
     * @param: Set<Id> setDealProductIds - Set of deal product Ids being inserted, updated 
     * @param: Set<Id> setProductIds - Set of Product Ids whose product street Date / PBEP Start Date is changed
     * @return None
     */
    public static void createDealProductSchedule(Set<Id> setDealProductIds, Set<Id> setProductIds){
    
        Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers =
            new Map<Id, CRM_DataObjects.DealProdWrapper>();
        //Map<String,Account_Plan__c> mapOfDPKeyToAcctPlan = new Map<String,Account_Plan__c>();
        System.debug('--physicalProductRecordTypeId-->'+physicalProductRecordTypeId);
        System.debug('--digitalProductRecordTypeId-->'+digitalProductRecordTypeId);
        
        //To Recalculate Schedules When Revert back Order Product quantity into Deal Product Initial Quantity upon Multi Order Activation
        List<CRM_Multiorder_Functionality__c> lstMultiOrderCS = [Select Id,ByPassValidation__c From CRM_Multiorder_Functionality__c Limit 1];
        Boolean byPassCommittedDealChangeValidation = (!lstMultiOrderCS.isEmpty()) ? lstMultiOrderCS[0].ByPassValidation__c : false;
        String byPassValidationFilter = byPassCommittedDealChangeValidation ? 
                      (' AND Opportunity.StageName = \''+CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)+'\'' : 
                      (' AND ('+
                          'Opportunity.StageName != \''+CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED+'\' OR '+
                          '( Opportunity.StageName = \''+CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED+'\' AND '+
                            'Opportunity.Bypass_Committed_Deals__c != null '+
                            ') '+
                          ')');
                          
        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
        if(setDealProductIds != null && !setDealProductIds.isEmpty()){
            system.debug('Before Query.........setDealProductIDs.size()..........................'+setDealProductIDs.size());
            String strquery = 'SELECT Id, Quantity, Discount, P_L_Quantity__c, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c,   OpportunityId, Opportunity.Account.Decay_Curve_Template__c,'+
                  'Opportunity.RecordTypeId, Opportunity.Start_Date__c, Opportunity.CloseDate, Product2Id, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice,Product2.RecordTypeId,'+
                  'Opportunity.AccountId,Account_Price__c, Opportunity.Account.Consignment_Customer__c, P_L_Decay_Curve_Template__c, Opportunity.Account.P_L_Decay_Curve_Template__c,Opportunity.CurrencyIsoCode,'+
                  'Opportunity.Promo_Start_Date__c, Opportunity.PriceBook2Id, Promoted_Price__c, NR__c, Target_Quantity__c, Product2.Release_Category__c,'+
                  'Product2.CanUseRevenueSchedule,Product2.CanUseQuantitySchedule, Opportunity.StageName,Opportunity.Market_Type__c, Opportunity.Sales_Organisation__c,'+
                  'Initial_Back_Order_Quantity__c, Opportunity.Customer_Delivery_Date__c, Opportunity.Account.Digital_Country_Code__c,'+ // US 547 : Japan  Changes
                          //Japan - DEF#3926
                  'Account_Plan__c,Decay_Curve_Template__r.MaxDecayCurveItemDay__c,Handling_Fee__c, Rental_Price__c ,'+
                  'Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c , Final_Purchase__c, Override_Pricing__c,'+
                  'Account_Plan__r.Country_Plan__c, Account_Plan__r.RecordTypeId, Account_Plan__r.Country_Plan__r.NR_Product__c, Account_Plan__r.Country_Plan__r.RecordTypeId,'+
                            // US-296 Changes (Rev Rec Changes)
                  'Material_Street_Date__c, NR_Revenue_Recognition_Date__c,'+
                                    //W-017642,W-017679 -Added fields for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
                                    'Initial_Ship_Fcst__c, Replen_Ship_Fcst__c, ListPrice__c, Deal_Sales_Organisation__c, Deal_Record_Type__c, New_Replen_Ship_Fcst__c '+
                ' FROM OpportunityLineItem'+
                ' WHERE '+
                  '('+
                    'Id IN: setDealProductIds'+
                  ')'+
                          //AND ( Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL OR Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL )
                  ' AND Product2Id != null'+
                          //AND (Opportunity.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED AND Opportunity.StageName !=: CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)
                          // AND Product2.Marketing_Material__c = false
                  ' AND ('+
                      '('+
                        'Opportunity.Sales_Organisation__c = \''+CRM_AppConstants.TERRITORY_FRANCE_CODE+'\' AND Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_DEAL_PHYSICAL+'\' AND Opportunity.StageName != \''+CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED+'\''+
                      ')'+
                      ' OR ('+
                          '('+
                            'Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_DEAL_DIGITAL+'\' OR Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_DEAL_PHYSICAL+'\''+
                          ')'+
                          ' AND'+
                          ' Opportunity.StageName != \''+CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED+'\''+
                          byPassValidationFilter+
                      ')'+
                              //W-017642,W-017679 - START - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
                              ' OR ('+
                          '('+
                            'Opportunity.Sales_Organisation__c = \''+CRM_AppConstants.TERRITORY_SDS_US_CODE+'\' OR Opportunity.Sales_Organisation__c = \''+ CRM_AppConstants.TERRITORY_SDS_CANADA_CODE+'\''+
                          ')'+
                          ' AND'+
                          '('+
                            'Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_Physical_DFI_Deal+'\' OR Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_Physical_POS_Deal+'\' OR Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_Physical_Planning_Deal+'\''+
                          ')'+
                      ')'+
                            //W-017642 - End - Added functionality for create Schedules for DFI and POS Deal and JV orgs
                  ')'+
                  ' LIMIT 10000';
                  
      system.debug('If strquery : '+strquery);          
            lstDealProducts = database.query(strquery);
        }else if(setProductIds != null && !setProductIds.isEmpty()){
            Set<Id> setPriceBookEntryIds = new Set<Id>();
            for(PriceBookEntry pbe : [Select Id FROM PriceBookEntry WHERE Product2Id IN: setProductIds]){
                setPriceBookEntryIds.add(pbe.Id);
            }
            lstDealProducts = [SELECT Id, Quantity, Discount, P_L_Quantity__c, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, OpportunityId, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Opportunity.CloseDate, Product2Id, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice,Product2.RecordTypeId,
                Opportunity.AccountId,Account_Price__c, Opportunity.Account.Consignment_Customer__c, P_L_Decay_Curve_Template__c, Opportunity.Account.P_L_Decay_Curve_Template__c,Opportunity.CurrencyIsoCode,
                Opportunity.Promo_Start_Date__c, Opportunity.PriceBook2Id, Promoted_Price__c, NR__c, Target_Quantity__c, Product2.Release_Category__c,
                Product2.CanUseRevenueSchedule,Product2.CanUseQuantitySchedule, Opportunity.StageName, Opportunity.Market_Type__c,Opportunity.Sales_Organisation__c,
                Initial_Back_Order_Quantity__c, Opportunity.Customer_Delivery_Date__c, Opportunity.Account.Digital_Country_Code__c, // US 547 : Japan  Changes
                //Japan - DEF#3926
                Account_Plan__c,Decay_Curve_Template__r.MaxDecayCurveItemDay__c, Handling_Fee__c, Rental_Price__c , Revenue_Share__c,
                Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c , Final_Purchase__c, Override_Pricing__c,
                Account_Plan__r.Country_Plan__c, Account_Plan__r.RecordTypeId, Account_Plan__r.Country_Plan__r.NR_Product__c, Account_Plan__r.Country_Plan__r.RecordTypeId,
                // US-296 Changes (Rev Rec Changes)
                Material_Street_Date__c, NR_Revenue_Recognition_Date__c,
                //W-017642,W-017679 - Start - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
                Initial_Ship_Fcst__c, Replen_Ship_Fcst__c, ListPrice__c, Deal_Sales_Organisation__c,Deal_Record_Type__c, New_Replen_Ship_Fcst__c 
            FROM OpportunityLineItem
            WHERE
                (
                    Product2Id IN: setProductIds
                        AND PriceBookEntryId IN: setPriceBookEntryIds
                        AND Manually_Schedule__c = false
                        AND(
                            (Product2.RecordTypeId =: physicalProductRecordTypeId AND NR__c = true)
                            OR
                            (Product2.RecordTypeId =: digitalProductRecordTypeId)
                        )
                        AND NR_Deal_Product_Unique_Key__c = null
                )
                //AND ( Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL OR Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL )
                AND Product2Id != null
                //AND (Opportunity.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED AND Opportunity.StageName !=: CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)
                // AND Product2.Marketing_Material__c = false
                AND(
                    (
                        Opportunity.Sales_Organisation__c =: CRM_AppConstants.TERRITORY_FRANCE_CODE AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL AND Opportunity.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED
                    )
                    OR(
                        (
                            Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL OR Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL
                        ) 
                        AND 
                        Opportunity.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED 
                        AND(
                          Opportunity.StageName !=: CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                          OR(
                            Opportunity.StageName =: CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED AND Opportunity.Bypass_Committed_Deals__c != null
                          )
                        )
                    )
                )
                LIMIT 10000
            ];
        }

        system.debug('Before Query.........lstDealProducts.size()..........................'+lstDealProducts.size());
        if (lstDealProducts != null && !lstDealProducts.isEmpty()) {
            Map<Id,OpportunityLineItem> mapDealProductIdToInstance = new Map<Id,OpportunityLineItem>(lstDealProducts);
           // List<OpportunityLineItem> lstJapanDP = new List<OpportunityLineItem>(); 
            System.debug('---mapDealProductIdToInstance-->'+mapDealProductIdToInstance);
            //Japan Development US#483 --- Starts Here ----
            /*for(OpportunityLineItem oli : lstDealProducts) {
                if (
                        oli.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && 
                        oli.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE &&
                        oli.NR__c && oli.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL
                ) {
                    String accountProductIdKey = String.ValueOf(oli.Opportunity.Account.Id).substring(0, 15) + '-' + String.ValueOf(oli.Product2.Id).substring(0, 15);
                    dealProdAcctIdSet.add(accountProductIdKey);
                }
            }
            if(dealProdAcctIdSet != null && !dealProdAcctIdSet.isEmpty())
            {
                mapOfDPKeyToAcctPlan = getAccountPlans(dealProdAcctIdSet);
            }*/
            Map<Id, list<Decay_Curve_Item__c>> mapTemplateIdToItems =
                    fetchDecayCurveTemplateItemsWithPB(
                        mapDealProductIdToInstance,
                        mapIdToDealProductWrappers
                        //,mapOfDPKeyToAcctPlan
                    );
            //Japan Development US#483 --- End Here ----
                System.debug('--mapIdToDealProductWrappers before-->'+mapIdToDealProductWrappers);
                if (mapIdToDealProductWrappers.size() > 0) {
                    CRM_ApplicationUtility.updateDigitalProductStreetDates(mapIdToDealProductWrappers.values());
                }
                System.debug('--mapIdToDealProductWrappers after-->'+mapIdToDealProductWrappers);
                
                processDecayCurve(
                    mapDealProductIdToInstance,
                    mapTemplateIdToItems,
                    mapIdToDealProductWrappers
                    //,mapOfDPKeyToAcctPlan
                );
            
        }
    }

    /**
     * This method is used to process decay Curve calculation
     * @name: processDecayCurve
     * @param: Map<Id, OpportunityLineItem> mapDealProductIdToInstance - Map of deal product being inserted, updated or whose product street Date / PBEP Start Date is changed
     * @param: Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems - Map of Normal / P&L Decay Curve Template Id to its Decay Curve Items
     * @param: Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers - Map of Deal Product Id to Deal Product Wrapper used for Digital Products
     * @return None
     */
    private static void processDecayCurve(
            Map<Id, OpportunityLineItem> mapDealProductIdToInstance,
            Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems,
            Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers
            //,Map<String,Account_Plan__c> mapOfDPKeyToAcctPlan
    )  {
        //START-Added for CRM-JV US-W-017643 For JV ORG Initial Date always be startDate
        Id posRecordTypeID = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
        Id dfiRecordTypeID = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
        Id planningRecordTypeID = CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
        
        Set<Id> posdfiDealRecordTypeSet = new Set<Id>{posRecordTypeID, dfiRecordTypeID, planningRecordTypeID};
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        //List<OpportunityLineItem> dealProducts = new List<OpportunityLineItem>();
        Set<Id> dealProductIdSet = new Set<Id>();
        for (OpportunityLineItem dealProduct : mapDealProductIdToInstance.values()) {
            Double promoPrice = dealProduct.Promoted_Price__c == null ? 0 : dealProduct.Promoted_Price__c;
                                
            // Process only for Digital / Physical deals for non marketing material Products
            Date initialDate = dealProduct.Opportunity.Promo_Start_Date__c; 
            if(!(posdfiDealRecordTypeSet.contains(dealProduct.Opportunity.RecordTypeId) && 
                    (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || 
                    dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE))){
                // Set Initial Date as Customer Delivery Date for Germany in case of Physical or Digital deals
                if(
                  ((dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId) && (CRM_AppConstants.GERMANY_SALES_ORGS.contains(dealProduct.Opportunity.Sales_Organisation__c))) ||
                  ((dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) && (CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES).contains(dealProduct.Opportunity.Account.Digital_Country_Code__c))            
                ) {
                    initialDate = dealProduct.Opportunity.Customer_Delivery_Date__c;
                 }
                if (
                    (dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId && (dealProduct.NR__c))
                ) {
                    initialDate = dealProduct.Product2.Street_Date__c;
                } else if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {

                    if (mapIdToDealProductWrappers.containsKey(dealProduct.Id)) {
                        CRM_DataObjects.DealProdWrapper dealProductWrapper =
                            mapIdToDealProductWrappers.get(dealProduct.Id);
                        if (
                            dealProductWrapper.productStreetDate <= dealProduct.Opportunity.CloseDate
                            && dealProductWrapper.productNREndDate >= dealProduct.Opportunity.Start_Date__c
                        ) {
                            initialDate = dealProductWrapper.productStreetDate;
                        }
                    }
                }
            }
            //END-For CRM-JV US-W-017643
            System.debug('-initialDate--->'+initialDate);

            // Set Target quantity by defualt if PL quantity is not available when it is a consignment customer deal product
            if (
                    dealProduct.Opportunity != null &&
                    dealProduct.Opportunity.AccountId != null &&
                    dealProduct.Opportunity.Account.Consignment_Customer__c &&
                    dealProduct.P_L_Quantity__c == null
            ) {
                dealProduct.P_L_Quantity__c = dealProduct.Target_Quantity__c;
            }

            // Process only if initial Date is not null. As Product street date is not mandatory, it can be null.
            if (initialDate != null) {
                //Japan Development US#483 --- Starts Here ----
                //String searchKey = createAccountProductKey(dealProduct);
                //if(null != dealProdAcctIdSet && !dealProdAcctIdSet.isEmpty() && dealProdAcctIdSet.contains(searchKey)) {
                if(
                        dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && 
                        dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE &&
                        //dealProduct.NR__c && 
                        dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL
                ) {
                    /*if (
                        dealProduct.Account_Plan__c != null && dealProduct.Account_Plan__r.Country_Plan__c != null &&
                        dealProduct.Account_Plan__r.Country_Plan__r.NR_Product__c == dealProduct.Product2Id &&
                        dealProduct.Account_Plan__r.Country_Plan__r.RecordTypeId == CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE &&
                        dealProduct.Account_Plan__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL
                    ) {*/
                        // if(null != mapOfDPKeyToAcctPlan && !mapOfDPKeyToAcctPlan.isEmpty() && (mapOfDPKeyToAcctPlan.keySet()).contains(searchKey)){
                        // Create Initial Schedules For JAPAN (Initial Schedule)
                        schedules.addAll(createInitialSchedulesJapan(dealProduct, initialDate, dealProductIdSet));//, mapOfDPKeyToAcctPlan));

                        // Create Decay Curver Schedules For JAPAN (Decay Curve Schedule)
                        schedules.addAll(calculateDecayCurveSchedulesJapan(dealProduct,initialDate,mapTemplateIdToItems, dealProductIdSet));//,mapOfDPKeyToAcctPlan ));

                        // Create Final Schedules for JAPAN (Final Schedules)
                        schedules.addAll(createFinalSchedulesJapan(dealProduct,initialDate,dealProductIdSet));//,mapOfDPKeyToAcctPlan));
                    //}
                // Japan Development US#483 --- Ends Here ----
                } else if (
                        (dealProduct.Opportunity.Sales_Organisation__c != CRM_AppConstants.TERRITORY_JAPAN_CODE) ||
                        (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) ||
                        (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && 
                         dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                         dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE )
                ) {
                    // Create Initial Schedules for both Normal Decay Curve and P&L Decay Curve for Physical Deals
                    schedules.addAll(createInitialSchedules(dealProduct, initialDate, dealProductIdSet, promoPrice));

                    // Create Replen/PL Schedules for both Normal Decay Curve and P&L Decay Curve for Physical / Digital Deals
                    schedules.addAll(createReplenAndPLSchedules(dealProduct,initialDate,mapTemplateIdToItems,dealProductIdSet, promoPrice));
                }
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {
            // Delete Existing Schedules
            List<OpportunityLineItemSchedule> dealProductSchedules =
                [
                    SELECT
                        ID
                    FROM
                        OpportunityLineItemSchedule
                    WHERE
                        OpportunityLineItemID IN: dealProductIdSet
                ];
            if (!dealProductSchedules.isEmpty()) {
                delete dealProductSchedules;
            }

            // Insert Schedules according to Normal / P&L decay curve template OR replen delay days
            System.debug('---schedules.size()->'+schedules.size());
            if (!schedules.isEmpty()) {
                insert schedules;
            }
        } catch (Exception ex) {
           system.debug('*****'+ex.getMessage()+'*****'+ex.getLineNumber());
            CRM_ErrorLogger.ErrorLog err = new CRM_ErrorLogger.ErrorLog();
            err.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DECAY_CURVE;
            err.lineNumber =  String.valueOf(ex.getLineNumber());
            err.errorMessage = ex.getMessage().left(255);
            err.stackTrace = ex.getStackTraceString();
            CRM_ErrorLogger.logError(err);
            Database.rollback(sp);
            throw ex;
        }
    }

    /**
     * This method is used to create Initial Schedules
     * @name: createInitialSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which replen and P&L Schedules need to be created
     * @param: Date initialDate  - The initial Date to decide the Schedule Date of Replen and P&L Schedules
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are calculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @return List<OpportunityLineItemSchedule> - List of schedules generated
     */
    private static List<OpportunityLineItemSchedule> createInitialSchedules(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Set<Id> dealProductIdSet,
            Double promoPrice
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        Decimal initialQuantity;
        if (dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
            // US 547 : Japan  Changes
            if (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE) {
                /*if (dealProduct.Initial_Quantity__c != null && dealProduct.Initial_Quantity__c != 0 && dealProduct.Initial_Back_Order_Quantity__c != null && dealProduct.Initial_Back_Order_Quantity__c != 0) {
                    initialQuantity = dealProduct.Initial_Quantity__c + dealProduct.Initial_Back_Order_Quantity__c;
                } else if (dealProduct.Initial_Quantity__c != null && dealProduct.Initial_Quantity__c != 0) {
                    initialQuantity = dealProduct.Initial_Quantity__c;
                } else if (dealProduct.Initial_Back_Order_Quantity__c != null && dealProduct.Initial_Back_Order_Quantity__c != 0) {
                    initialQuantity = dealProduct.Initial_Back_Order_Quantity__c;
                }*/
                if (dealProduct.Initial_Quantity__c != null && dealProduct.Initial_Back_Order_Quantity__c != null) {
                    initialQuantity = dealProduct.Initial_Quantity__c + dealProduct.Initial_Back_Order_Quantity__c;
                } else if (dealProduct.Initial_Quantity__c != null) {
                    initialQuantity = dealProduct.Initial_Quantity__c;
                } else if (dealProduct.Initial_Back_Order_Quantity__c != null) {
                    initialQuantity = dealProduct.Initial_Back_Order_Quantity__c;
                }
            } else {
                // Existing logic for non Japan territories
                if (dealProduct.Initial_Quantity__c != null) { // && dealProduct.Initial_Quantity__c != 0) {
                    initialQuantity = dealProduct.Initial_Quantity__c;
                }
            }

            Boolean isValidZeroQuantity = initialQuantity == 0 && (dealProduct.Replen_Quantity__c == null || dealProduct.Replen_Quantity__c == 0);

            if ((initialQuantity != null && initialQuantity > 0) || isValidZeroQuantity) {
                String scheduleType = dealProduct.Discount == 100 ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY : CRM_AppConstants.SCHEDULE_TYPE_BOTH;
                // US-296 Changes (Rev Rec Changes)
                if(
                        //dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_UK_CODE && 
                        dealProduct.NR__c == true && dealProduct.Opportunity.Account.Consignment_Customer__c == false && 
                        dealProduct.Material_Street_Date__c != dealProduct.NR_Revenue_Recognition_Date__c
                        //&& dealProduct.Product2.CanUseQuantitySchedule && dealProduct.Product2.CanUseRevenueSchedule
                ) {
                    // Create a revenue schedule on NR_Revenue_Recognition_Date__c with 0 quantity
                    /*schedules.add(createSchedules(
                        dealProduct.Id,
                        CRM_AppConstants.SCHEDULE_TYPE_BOTH,
                        (dealProduct.Discount == 100 || (dealProduct.P_L_Quantity__c != null && dealProduct.P_L_Quantity__c != 0))? 0 : initialQuantity * promoPrice,
                        0,
                        CRM_AppConstants.SCHEDULE_INITIAL,
                        dealProduct.NR_Revenue_Recognition_Date__c
                    ));
                    
                    // Create a quantity schedule on "Product Street Date" / Intial Date with 0 revenue
                    schedules.add(createSchedules(
                        dealProduct.Id,
                        CRM_AppConstants.SCHEDULE_TYPE_BOTH,
                        0,
                        Math.ceil(initialQuantity),
                        CRM_AppConstants.SCHEDULE_INITIAL,
                        dealProduct.NR_Revenue_Recognition_Date__c
                    ));
                    dealProductIdSet.add(dealProduct.Id);*/
                    initialDate = dealProduct.NR_Revenue_Recognition_Date__c;
                }
                //else
                if (
                    (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY && dealProduct.Product2.CanUseQuantitySchedule) ||
                    (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH && dealProduct.Product2.CanUseQuantitySchedule && dealProduct.Product2.CanUseRevenueSchedule)
                ) {
                    schedules.add(createSchedules(
                        dealProduct.Id,
                        scheduleType,
                        (dealProduct.Discount == 100 || (dealProduct.P_L_Quantity__c != null && dealProduct.P_L_Quantity__c != 0))
                        ? 0 
                        : isValidZeroQuantity ? 0 : initialQuantity * promoPrice,
                        isValidZeroQuantity ? 1 : Math.ceil(initialQuantity),
                        isValidZeroQuantity ? CRM_AppConstants.SCHEDULE_ZERO : CRM_AppConstants.SCHEDULE_INITIAL,
                        initialDate
                    ));
                    dealProductIdSet.add(dealProduct.Id);
                }
            }
        }
        //W-017642,W-017679 - START - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
        else if ((dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
                 && (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)
                ) {
                    if(dealProduct.ListPrice__c != null) {
                        
                        Decimal replanQuantity = 0;
                        if(dealProduct.New_Replen_Ship_Fcst__c != null && dealProduct.New_Replen_Ship_Fcst__c != 0 
                           && dealProduct.Replen_Ship_Fcst__c != null && dealProduct.Replen_Ship_Fcst__c != 0) {
                            replanQuantity = dealProduct.New_Replen_Ship_Fcst__c;
                        } else if(dealProduct.Replen_Ship_Fcst__c != null && dealProduct.Replen_Ship_Fcst__c != 0) {
                            replanQuantity = dealProduct.Replen_Ship_Fcst__c;
                        }
                        
                        if (dealProduct.Initial_Ship_Fcst__c != null) {
                            initialQuantity = dealProduct.Initial_Ship_Fcst__c;
                        }
                        Boolean isValidZeroQuantity = initialQuantity == 0 && (replanQuantity == null || replanQuantity == 0);
                        
                        if ((initialQuantity != null && initialQuantity > 0) || isValidZeroQuantity) {
                            String scheduleType = dealProduct.Discount == 100 ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY : CRM_AppConstants.SCHEDULE_TYPE_BOTH;
                            if (
                                (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY && dealProduct.Product2.CanUseQuantitySchedule) ||
                                (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH && dealProduct.Product2.CanUseQuantitySchedule && dealProduct.Product2.CanUseRevenueSchedule)
                            ) {
                                schedules.add(createSchedules(
                                    dealProduct.Id,
                                    scheduleType,
                                    (dealProduct.Discount == 100 )
                                    ? 0 
                                    : isValidZeroQuantity ? 0 : initialQuantity * dealProduct.ListPrice__c,
                                    isValidZeroQuantity ? 1 : Math.ceil(initialQuantity),
                                    isValidZeroQuantity ? CRM_AppConstants.SCHEDULE_ZERO : CRM_AppConstants.SCHEDULE_INITIAL,
                                    initialDate
                                ));
                                dealProductIdSet.add(dealProduct.Id);
                            }
                        }
                    }
                }
        //W-017642,W-017679 - END - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
        return schedules;
    }

    /**
     * This method is used to create Replen and P&L Schedules
     * @name: createReplenAndPLSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which replen and P&L Schedules need to be created
     * @param: Date initialDate  - The initial Date to decide the Schedule Date of Replen and P&L Schedules
     * @param: Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems - Map of all Decay Curve Template Items for which schedules needs to be created
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are recalculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @return List<OpportunityLineItemSchedule> - List of schedules genearated
     */
    private static List<OpportunityLineItemSchedule> createReplenAndPLSchedules(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems,
            Set<Id> dealProductIdSet,
            Double promoPrice
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        String scheduleType =
            dealProduct.Discount == 100
            ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY
            : CRM_AppConstants.SCHEDULE_TYPE_BOTH;

        //W-017642,W-017679 - START - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
        if( ((dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
             && (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)) && 
           ((scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY && dealProduct.Product2.CanUseQuantitySchedule) ||
            (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH && dealProduct.Product2.CanUseQuantitySchedule && dealProduct.Product2.CanUseRevenueSchedule)) &&
           ((dealProduct.Replen_Ship_Fcst__c != null) || (dealProduct.New_Replen_Ship_Fcst__c != null))
          ) {
            // Calculate normal Decay Curve Schedules with Quantity / Both Type based on conditions
            schedules.addAll(calculateDecayCurveSchedules(
                dealProduct,
                initialDate,
                mapTemplateIdToItems,
                dealProductIdSet,
                scheduleType,
                promoPrice
            ));  
        }
      //W-017642,W-017679 - END - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
        else if (
            ((scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY && dealProduct.Product2.CanUseQuantitySchedule) ||
            (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH && dealProduct.Product2.CanUseQuantitySchedule && dealProduct.Product2.CanUseRevenueSchedule)) &&
            ((dealProduct.Replen_Quantity__c != null && dealProduct.Replen_Quantity__c != 0) || (dealProduct.Replen_Quantity__c == 0 && dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL))
        ) {
            // Calculate normal Decay Curve Schedules with Quantity / Both Type based on conditions
            schedules.addAll(calculateDecayCurveSchedules(
                dealProduct,
                initialDate,
                mapTemplateIdToItems,
                dealProductIdSet,
                scheduleType,
                promoPrice
            ));
        }

        if (dealProduct.Product2.CanUseRevenueSchedule && dealProduct.Product2.CanUseQuantitySchedule) {
            // Calculate P&L Decay Curve Schedules with Revenue Type when it is a consignment customer and Promo Price is present
            if (dealProduct.P_L_Quantity__c != null && dealProduct.P_L_Quantity__c != 0 && dealProduct.Discount != 100) {
                schedules.addAll(calculatePandLDecayCurveSchedules(
                    dealProduct,
                    initialDate,
                    mapTemplateIdToItems,
                    dealProductIdSet,
                    promoPrice
                ));
            }
        }
        return schedules;
    }

    /**
     * This method is used to create P&L Schedules based on P&L Decay Curve templates
     * @name: calculatePandLDecayCurveSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which P&L  Schedules need to be created
     * @param: Date initialDate  - The initial Date to decide the Schedule Date of P&L Schedules
     * @param: Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems - Map of all Decay Curve Template Items for which schedules needs to be created
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are recalculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @return List<OpportunityLineItemSchedule> - List of schedules genearated
     */
    private static List<OpportunityLineItemSchedule> calculatePandLDecayCurveSchedules(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems,
            Set<Id> dealProductIdSet,
            Double promoPrice
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();

        // Create P&L Schedule
        Id pAndLDecayCurvetemplateId = getPandLDecayCurveTemplatId(dealProduct);
        if (pAndLDecayCurvetemplateId != null && mapTemplateIdToItems.containsKey(pAndLDecayCurvetemplateId)) {
            for (Decay_Curve_Item__c currentItem : mapTemplateIdToItems.get(pAndLDecayCurvetemplateId)) {

                // Calcaluate remaining decimal
                Decimal actualRevenue = ((dealProduct.P_L_Quantity__c * currentItem.Percent_Allocation__c) / 100) * promoPrice;

                // Create Schedules by decay curve template
                schedules.add(createSchedules(
                    dealProduct.Id,
                    CRM_AppConstants.SCHEDULE_TYPE_BOTH,
                    actualRevenue,
                    0,
                    CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(currentItem.Percent_Allocation__c) + ' %',
                    initialDate.addDays((Integer) currentItem.Day_Number__c)
                ));
                dealProductIdSet.add(dealProduct.Id);
            }

        } else {
            schedules.add(createSchedules(
                dealProduct.Id,
                CRM_AppConstants.SCHEDULE_TYPE_BOTH,
                dealProduct.P_L_Quantity__c * promoPrice,
                0,
                CRM_AppConstants.SCHEDULE_PL,
                initialDate
            ));
            dealProductIdSet.add(dealProduct.Id);
        }
        System.debug('---PL--schedules--->'+schedules);
        return schedules;
    }

    /**
     * This method is used to create Replen Schedules based on Normal Decay Curve templates
     * @name: calculateDecayCurveSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which P&L  Schedules need to be created
     * @param: Date initialDate  - The initial Date to decide the Schedule Date of P&L Schedules
     * @param: Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems - Map of all Decay Curve Template Items for which schedules needs to be created
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are recalculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @return List<OpportunityLineItemSchedule> - List of schedules genearated
     */
    private static List<OpportunityLineItemSchedule> calculateDecayCurveSchedules(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems,
            Set<Id> dealProductIdSet,
            String scheduleType,
            Double promoPrice
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();

        // Create Schedlues for Both Physical & Digital Type of Deals based on Templates present or not
        Id decayCurveTemplateId = getDecayCurveTemplatId(dealProduct);
        
        //W-017642,W-017679 - START - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
        if((dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
            && (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)
          ) {   
              if(dealProduct.ListPrice__c != null) {
                  
                  Decimal replenQuantity = 0;
                  if(dealProduct.New_Replen_Ship_Fcst__c != null && dealProduct.New_Replen_Ship_Fcst__c != 0 &&
                    dealProduct.Replen_Ship_Fcst__c != null && dealProduct.Replen_Ship_Fcst__c != 0) {
                      replenQuantity = dealProduct.New_Replen_Ship_Fcst__c;
                  } else if(dealProduct.Replen_Ship_Fcst__c != null && dealProduct.Replen_Ship_Fcst__c != 0) {
                      replenQuantity = dealProduct.Replen_Ship_Fcst__c;
                  }
                  
                  if (replenQuantity != 0 && decayCurveTemplateId != null && mapTemplateIdToItems.containsKey(decayCurveTemplateId)) {
                      Decimal remainingQuantity = 0;
                      for (Decay_Curve_Item__c currentItem : mapTemplateIdToItems.get(decayCurveTemplateId)) {
                          // Calcaluate remaining decimal
                          Decimal actualQuantity = (replenQuantity * currentItem.Percent_Allocation__c) / 100;
                          Decimal roundQuantity = Integer.valueOf(actualQuantity);
                          remainingQuantity += actualQuantity - roundQuantity;
                          Decimal revenue = (dealProduct.Discount == 100) ? 0 : roundQuantity * dealProduct.ListPrice__c;
                          
                          // Create Schedules by decay curve template
                          schedules.add(createSchedules(
                              dealProduct.Id,
                              scheduleType,
                              revenue,
                              roundQuantity,
                              CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(currentItem.Percent_Allocation__c) + ' %',
                              initialDate.addDays((Integer) currentItem.Day_Number__c)
                          ));
                          dealProductIdSet.add(dealProduct.Id);
                      }
                      
                      // Update the last schedule quantity and revenue by reminder 
                      if (remainingQuantity > 0) {
                          OpportunityLineItemSchedule lstSchedule = schedules[schedules.size() - 1];
                          if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH) {
                              lstSchedule.Quantity += Math.ceil(remainingQuantity);
                              lstSchedule.Revenue = lstSchedule.Quantity * dealProduct.ListPrice__c;
                          } else if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY) {
                              lstSchedule.Quantity += Math.ceil(remainingQuantity);
                          }
                      }
                      // Create Schedule by Replen delay days
                  } else {
                      Integer replenDays;
                      replenDays = dealProduct.Replen_Delay_Days__c == null ? 7 : (Integer) dealProduct.Replen_Delay_Days__c;
                      Boolean isValidZeroQuantity = replenQuantity == 0;
                      
                      if (replenDays != null) {
                          schedules.add(createSchedules(
                              dealProduct.Id,
                              scheduleType,
                              (dealProduct.Discount == 100) 
                              ? 0 : 
                              isValidZeroQuantity ? 0 : replenQuantity * dealProduct.ListPrice__c,
                              isValidZeroQuantity ? 1 : Math.ceil(replenQuantity),
                              isValidZeroQuantity ? CRM_AppConstants.SCHEDULE_ZERO : CRM_AppConstants.SCHEDULE_REPLEN_DELAY,
                              initialDate.addDays(replenDays)
                          ));
                          dealProductIdSet.add(dealProduct.Id);
                      }
                  }
              }
          } else { //W-017642,W-017679 - END - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
              
              if (dealProduct.Replen_Quantity__c != 0 && decayCurveTemplateId != null && mapTemplateIdToItems.containsKey(decayCurveTemplateId)) {
                  Decimal remainingQuantity = 0;
                  for (Decay_Curve_Item__c currentItem : mapTemplateIdToItems.get(decayCurveTemplateId)) {
                      // Calcaluate remaining decimal
                      Decimal actualQuantity = (dealProduct.Replen_Quantity__c * currentItem.Percent_Allocation__c) / 100;
                        Decimal roundQuantity = Integer.valueOf(actualQuantity);
                        remainingQuantity += actualQuantity - roundQuantity;
                        Decimal revenue = (dealProduct.Discount == 100 || (dealProduct.P_L_Quantity__c != null && dealProduct.P_L_Quantity__c != 0)) ? 0 : roundQuantity * promoPrice;
                        
                        // Create Schedules by decay curve template
                        schedules.add(createSchedules(
                            dealProduct.Id,
                            scheduleType,
                            revenue,
                            roundQuantity,
                            CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(currentItem.Percent_Allocation__c) + ' %',
                            initialDate.addDays((Integer) currentItem.Day_Number__c)
                        ));
                        dealProductIdSet.add(dealProduct.Id);
                    }
                    
                    // Update the last schedule quantity and revenue by reminder 
                    if (remainingQuantity > 0) {
                        OpportunityLineItemSchedule lstSchedule = schedules[schedules.size() - 1];
                        if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH) {
                            lstSchedule.Quantity += Math.ceil(remainingQuantity);
                            lstSchedule.Revenue =
                                (dealProduct.P_L_Quantity__c != null && dealProduct.P_L_Quantity__c != 0)
                                ? 0
                                : lstSchedule.Quantity * promoPrice;
                        } else if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY) {
                            lstSchedule.Quantity += Math.ceil(remainingQuantity);
                        }
                    }
                    // Create Schedule by Replen delay days
                } else {
                    Integer replenDays;
                    if (dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                        replenDays = dealProduct.Replen_Delay_Days__c == null ? 7 : (Integer) dealProduct.Replen_Delay_Days__c;
                    } else if (dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                        replenDays = 0;
                    }
                    Boolean isValidZeroQuantity = dealProduct.Replen_Quantity__c == 0 && dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                    
                    if (replenDays != null) {
                        schedules.add(createSchedules(
                            dealProduct.Id,
                            scheduleType,
                            (dealProduct.Discount == 100 || (dealProduct.P_L_Quantity__c != null && dealProduct.P_L_Quantity__c != 0)) 
                            ? 0 : 
                            isValidZeroQuantity ? 0 : dealProduct.Replen_Quantity__c * promoPrice,
                            isValidZeroQuantity ? 1 : Math.ceil(dealProduct.Replen_Quantity__c),
                            isValidZeroQuantity ? CRM_AppConstants.SCHEDULE_ZERO : CRM_AppConstants.SCHEDULE_REPLEN_DELAY,
                            initialDate.addDays(replenDays)
                        ));
                        dealProductIdSet.add(dealProduct.Id);
                    }
                }
            } //W-017642,W-017679 - END - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
        System.debug('---Normal--schedules--->'+schedules);
        return schedules;
    }

    /**
     * This method is used to find which p&l decay curve template Id to be used
     * @name: getPandLDecayCurveTemplatId
     * @param:  OpportunityLineItem dealProduct - Insatnce of deal Product for which we need the p&l decay Curve Template Id
     * @return Id - Id of P&L Decay Curve template
     * @throws exception-None
     */
    private static Id getPandLDecayCurveTemplatId(OpportunityLineItem dealProduct) {

        // Get Direct Template ID for P&L
        if (dealProduct.P_L_Decay_Curve_Template__c != null) {
            return dealProduct.P_L_Decay_Curve_Template__c;

        // Get Indirect Template ID for P&L i.e. Account Level
        } else if (
                dealProduct.Opportunity != null &&
                dealProduct.Opportunity.Account != null &&
                dealProduct.Opportunity.Account.P_L_Decay_Curve_Template__c != null
        ) {
            return dealProduct.Opportunity.Account.P_L_Decay_Curve_Template__c;
        }
        return null;
    }

    /**
     * This method is used to find which decay curve template Id to be used
     * @name: getDecayCurveTemplatId
     * @param:  OpportunityLineItem dealProduct - Insatnce of deal Product for which we need the decay Curve Template Id
     * @return Id - Id of Decay Curve template
     * @throws exception-None
     */
    private static Id getDecayCurveTemplatId(OpportunityLineItem dealProduct) {
        // Get Direct Template ID
        if (dealProduct.Decay_Curve_Template__c != null) {
            return dealProduct.Decay_Curve_Template__c;

        // Get Indirect Template ID i.e. Account Level
        } else if (
                dealProduct.Opportunity.Sales_Organisation__c != CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                dealProduct.Opportunity != null &&
                dealProduct.Opportunity.Account != null &&
                dealProduct.Opportunity.Account.Decay_Curve_Template__c != null
        ) {
            return dealProduct.Opportunity.Account.Decay_Curve_Template__c;
        }
        return null;
    }

    /**
     * This method is used to create Decay Curve Items
     * @name: fetchDecayCurveTemplateItemsWithPB
     * @param:  Map<Id,OpportunityLineItem> mapIdToDealProductInstance - Map of all deal Products required to populate the Templates
     * @param:  Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers - Map of all deal Product Wrapper required to populate for Digital Products
     * @return Map<ID, List<Decay_Curve_Item__c>> - Map of all Decay Curve Items
     * @throws exception-None
     */
    private static Map<ID, List<Decay_Curve_Item__c>> fetchDecayCurveTemplateItemsWithPB(
            Map<Id,OpportunityLineItem> mapIdToDealProductInstance,
            Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers
            //,Map<String,Account_Plan__c> mapOfDPKeytoAccPlan
    ) {
        Map<ID, List<Decay_Curve_Item__c>> mapTemplateIdToItems = new Map<ID, List<Decay_Curve_Item__c>>();
        
        for (OpportunityLineItem dealProduct : mapIdToDealProductInstance.values()) {
            CRM_DataObjects.DealProdWrapper dealProductWrapperInstance =
                new CRM_DataObjects.DealProdWrapper();
            Id decayCurveTemplateId = getDecayCurveTemplatId(dealProduct); system.debug('@@**decayCurveTemplateId --> ' + decayCurveTemplateId);
            if (decayCurveTemplateId != null) {
                mapTemplateIdToItems.put(decayCurveTemplateId, new Decay_Curve_Item__c[]{});
            }  system.debug('@@** mapTemplateIdToItems' + mapTemplateIdToItems);

            Id pAndLdecayCurveTemplateId = getPandLDecayCurveTemplatId(dealProduct);
            if (pAndLdecayCurveTemplateId != null) {
                mapTemplateIdToItems.put(pAndLdecayCurveTemplateId, new Decay_Curve_Item__c[]{});
            }
      
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                dealProductWrapperInstance.dealCurrencyCode = dealProduct.Opportunity.CurrencyIsoCode;
                dealProductWrapperInstance.pricebookId = dealProduct.Opportunity.Pricebook2Id;
                dealProductWrapperInstance.productId = dealProduct.Product2Id;
                dealProductWrapperInstance.productRecTypeId = digitalProductRecordTypeId;
                mapIdToDealProductWrappers.put(dealProduct.Id, dealProductWrapperInstance);
            }
            //Japan Development US#483 --- Starts Here ----
            /*if(dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && 
                    dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE &&
                    dealProduct.NR__c)
            {
                //String accountProductIdKey = String.ValueOf(dealProduct.Opportunity.Account.Id).substring(0, 15) + '-' + String.ValueOf(dealProduct.Product2.Id).substring(0, 15);
                String accountProductIdKey = createAccountProductKey(dealProduct);
                if(
                        !String.isBlank(accountProductIdKey) && mapOfDPKeytoAccPlan.containsKey(accountProductIdKey) &&
                        mapOfDPKeytoAccPlan.get(accountProductIdKey) != null && mapOfDPKeytoAccPlan.get(accountProductIdKey).Decay_Curve_Template__c != null) 
                {
                    mapTemplateIdToItems.put(mapOfDPKeytoAccPlan.get(accountProductIdKey).Decay_Curve_Template__c,new Decay_Curve_Item__c[]{});
                }
            }*/
            //Japan Development US#483 --- Ends Here ----
        }
        // Get all Decay curve item using template ID 
        for (Decay_Curve_Item__c currentItem : [
                SELECT
                    ID,
                    Percent_Allocation__c,
                    Day_Number__c,
                    Decay_Curve_Template__c
                FROM
                    Decay_Curve_Item__c
                WHERE
                    Decay_Curve_Template__c IN :mapTemplateIdToItems.keySet()
                    AND (
                          Decay_Curve_Template__r.Status__c =: CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE OR
                          Decay_Curve_Template__r.Status__c =: CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ARCHIVED
                        )
                    ORDER BY CreatedDate ASC
        ]) {
            ID currentTemplateId = currentItem.Decay_Curve_Template__c; 
            if (currentTemplateId != null) {
                mapTemplateIdToItems.get(currentTemplateId).add(currentItem);
            }
        }  
        return mapTemplateIdToItems;
    }

    /**
     * This method is used to create Schedules
     * @name: createSchedules
     * @param:  Id dealProductId - Deal Product Id for which Schedules needs to be created
     * @param:  String scheduleType - Indicates what should be the Schedule Type
     * @param:  Decimal revenue - Revenue required for creation of Schedules
     * @param:  Decimal quantity - Quantity required for creation of Schedules
     * @param:  String description - Description required for creation of Schedules
     * @param:  Date scheduleDate - Date on which the schedules should be created
     * @return OpportunityLineItemSchedule - Insatnce of schedules
     * @throws exception-None
     */
    private static OpportunityLineItemSchedule createSchedules(
            Id dealProductId,
            String scheduleType,
            Decimal revenue,
            Decimal quantity,
            String description,
            Date scheduleDate
    ) {
        OpportunityLineItemSchedule dealProductSchedule =
            new OpportunityLineItemSchedule(
                Description = description,
                OpportunityLineItemId = dealProductId,
                ScheduleDate = scheduleDate,
                Type = scheduleType
            );

        if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH) {
            dealProductSchedule.Revenue = revenue;
            dealProductSchedule.Quantity = quantity;
        } else if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_QUANTITY) {
            dealProductSchedule.Quantity = quantity;
        }
        
        // US-296 Changes (Rev Rec Changes)
        else if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_REVENUE) {
            dealProductSchedule.Revenue = revenue;
        }
        return dealProductSchedule;
    }

    /**
     * This method is used to invoke Schedule calculation
     * @name: executeDealProductScheduling
     * @param:  Map<Id,Product2> (Old products)
     * @param:  List<Product2> ( New List Of Products)
     * @param:  Boolean isInsert Used to decide whether to invoke insert / update conditions
     * @return null
     * @throws exception-
     */
    public static void executeDealProductScheduling(
            Map<Id,OpportunityLineItem> mapOldDealProducts,
            List<OpportunityLineItem> dealProductList,
            Boolean isInsert
    ) {
        Map<Id, OpportunityLineItem> mapDealProductIdToInstance = new Map<Id, OpportunityLineItem>();
        //Map<Id, OpportunityLineItem> mapDealProductIdToInstanceFuture = new Map<Id, OpportunityLineItem>();
        System.debug('-isInsert-->'+isInsert);
        System.debug('-dealProductList.size()-->'+dealProductList.size() +'--dealProductList-->'+dealProductList);
        for (OpportunityLineItem objNewDealProduct: dealProductList){
            // if(objNewDealProduct.Deal_Sales_Organisation__c != CRM_AppConstants.TERRITORY_SDS_US_CODE   
            //  && objNewDealProduct.Deal_Sales_Organisation__c != CRM_AppConstants.TERRITORY_SDS_CANADA_CODE )
            //  {
            if (!CRM_ApplicationUtility.clonedDealIds.contains(objNewDealProduct.OpportunityId)) {
                if (isInsert) {
                    if(!objNewDealProduct.Manually_Schedule__c){    
                        mapDealProductIdToInstance.put(objNewDealProduct.Id, objNewDealProduct);
                    }
                } else {
                    OpportunityLineItem objOldDealProduct = mapOldDealProducts.get(objNewDealProduct.Id);
                    /*if (!objNewDealProduct.Manually_Schedule__c && objOldDealProduct.Discount != objNewDealProduct.Discount) {
            mapDealProductIdToInstanceFuture.put(objNewDealProduct.Id, objNewDealProduct);
          } else*/
                    //W-017642,W-017679 - START - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
                    if((objOldDealProduct.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL || objOldDealProduct.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL || objOldDealProduct.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_PLANNING_DEAL)
                && (objOldDealProduct.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || objOldDealProduct.Deal_Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)) {  
                        if (
                            (objOldDealProduct.Manually_Schedule__c != objNewDealProduct.Manually_Schedule__c && !objNewDealProduct.Manually_Schedule__c) ||
                            (
                                !objNewDealProduct.Manually_Schedule__c && 
                                (
                                    objOldDealProduct.Replen_Ship_Fcst__c != objNewDealProduct.Replen_Ship_Fcst__c
                                    || objOldDealProduct.Initial_Ship_Fcst__c != objNewDealProduct.Initial_Ship_Fcst__c
                                    || objOldDealProduct.Decay_Curve_Template__c != objNewDealProduct.Decay_Curve_Template__c
                                    || objOldDealProduct.Replen_Delay_Days__c != objNewDealProduct.Replen_Delay_Days__c
                                    || objOldDealProduct.New_Replen_Ship_Fcst__c != objNewDealProduct.New_Replen_Ship_Fcst__c
                                    || objOldDealProduct.ListPrice__c != objNewDealProduct.ListPrice__c
                                )
                            )
                        ) {
                            mapDealProductIdToInstance.put(objNewDealProduct.Id, objNewDealProduct);
                        }
                    }
                    else { //W-017642,W-017679 - END - Added functionality for create Schedules for DFI ,ADV/POS And Physical Planning Deal and JV orgs
                        if (
                            (objOldDealProduct.Manually_Schedule__c != objNewDealProduct.Manually_Schedule__c && !objNewDealProduct.Manually_Schedule__c) ||
                            (
                                !objNewDealProduct.Manually_Schedule__c && 
                                (
                                    objOldDealProduct.Promoted_Price__c != objNewDealProduct.Promoted_Price__c
                                    || objOldDealProduct.Replen_Quantity__c != objNewDealProduct.Replen_Quantity__c
                                    || objOldDealProduct.Initial_Quantity__c != objNewDealProduct.Initial_Quantity__c
                                    || objOldDealProduct.Decay_Curve_Template__c != objNewDealProduct.Decay_Curve_Template__c
                                    || objOldDealProduct.Replen_Delay_Days__c != objNewDealProduct.Replen_Delay_Days__c
                                    || objOldDealProduct.P_L_Quantity__c != objNewDealProduct.P_L_Quantity__c
                                    || objOldDealProduct.P_L_Decay_Curve_Template__c != objNewDealProduct.P_L_Decay_Curve_Template__c
                                    || objOldDealProduct.Initial_Back_Order_Quantity__c != objNewDealProduct.Initial_Back_Order_Quantity__c
                                    || objOldDealProduct.Handling_Fee__c != objNewDealProduct.Handling_Fee__c
                                    || objOldDealProduct.Rental_Price__c  != objNewDealProduct.Rental_Price__c
                                    || objOldDealProduct.Revenue_Share__c != objNewDealProduct.Revenue_Share__c
                                    || objOldDealProduct.Number_of_Rentals_per_Unit__c != objNewDealProduct.Number_of_Rentals_per_Unit__c
                                    || objOldDealProduct.Final_Purchase_Price__c  != objNewDealProduct.Final_Purchase_Price__c 
                                    || objOldDealProduct.Final_Purchase__c != objNewDealProduct.Final_Purchase__c
                                )
                            )
                        ) {
                            mapDealProductIdToInstance.put(objNewDealProduct.Id, objNewDealProduct);
                        }   
                    }  //W-017642 
                }
            }
            //}
        }

        if (mapDealProductIdToInstance.size() > 0){
            createDealProductSchedule(mapDealProductIdToInstance.keySet(), new Set<Id>());
        }
        /*if (mapDealProductIdToInstanceFuture.size() > 0){
            executeDecayCurveFuture(mapDealProductIdToInstanceFuture.keySet(), new Set<Id>());
        }
        System.debug('mapDealProductIdToInstanceFuture--> ' + mapDealProductIdToInstanceFuture);
        */
        System.debug('mapDealProductIdToInstance--> ' + mapDealProductIdToInstance);
    }

    /**
     * This method is used to invoke Schedule recalculation if Street date of any product is changed
     * @name: recalculateDealProductSchedule
     * @param:  Map<Id,Product2> (Old products)
     * @param:  List<Product2> ( New List Of Products)
     * @return null
     * @throws exception-
     
    public void recalculateDealProductSchedule(Map<Id,Product2> mapOldProducts,List<Product2> lstNewProducts) {
        Set<Id> updatedProdIdSet = new Set<Id>();
        for (Product2 prod : lstNewProducts) {
            Product2 oldProd = mapOldProducts.get(prod.Id);
            if(oldProd.Street_Date__c != prod.Street_Date__c) {
                updatedProdIdSet.add(prod.Id);
            }
        }
        if (updatedProdIdSet!= null && updatedProdIdSet.size() > 0) {
            createDealProductSchedule(new Set<Id>() ,updatedProdIdSet);
        }
    }*/
    
     //Japan Development US#483 --- Starts Here Line no 741 to Line no 916----
 
     /**
     * This method is used to create Initial Schedules Japan
     * @name: createInitialSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which replen and P&L Schedules need to be created
     * @param: Date initialDate  - The initial Date to decide the Schedule Date of Replen and P&L Schedules
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are calculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @param: searchKey - Key of Account and product Id
     * @return List<OpportunityLineItemSchedule> - List of schedules generated
     */
    private static List<OpportunityLineItemSchedule> createInitialSchedulesJapan(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Set<Id> dealProductIdSet
            //,map<String, Account_Plan__c> mapOfDPKeyToAcctPlan
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        //String searchKey = createAccountProductKey(dealProduct);
        if (dealProduct.Initial_Quantity__c != null //&& dealProduct.Initial_Quantity__c != 0
            //&& dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL
            //&& null != searchKey && null != mapOfDPKeyToAcctPlan.get(searchKey)
        ) {
            Boolean isValidZeroQuantity = dealProduct.Initial_Quantity__c == 0;
            Decimal handlingFee = dealProduct.Handling_Fee__c != null ? dealProduct.Handling_Fee__c : 0; // Handling fee from deal product
            String scheduleType = dealProduct.Discount == 100 ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY : CRM_AppConstants.SCHEDULE_TYPE_BOTH;
            {
                schedules.add(createSchedules(
                    dealProduct.Id,
                    scheduleType,
                    isValidZeroQuantity ? 0 : dealProduct.Initial_Quantity__c * handlingFee,
                    isValidZeroQuantity ? 1 : Math.ceil(dealProduct.Initial_Quantity__c),
                    isValidZeroQuantity ? CRM_AppConstants.SCHEDULE_ZERO : CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE,
                    initialDate
                ));
                dealProductIdSet.add(dealProduct.Id);
            }
        }
        return schedules;
    }

    /**
     * This method is used to create Final Schedules (US#483 - Japan Method)
     * @name: createFinalSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which replen and P&L Schedules need to be created
     * @param: Date initialDate  - 
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are calculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @return List<OpportunityLineItemSchedule> - List of schedules generated
     */
    private static List<OpportunityLineItemSchedule> createFinalSchedulesJapan(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Set<Id> dealProductIdSet
            //,map<String, Account_Plan__c> mapOfDPKeyToAcctPlan
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        //String searchKey = createAccountProductKey(dealProduct);
        if (
                dealProduct.Initial_Quantity__c != null && dealProduct.Initial_Quantity__c != 0 &&
                dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && 
                dealProduct.Decay_Curve_Template__c != null
                //null != searchKey && null != mapOfDPKeyToAcctPlan.get(searchKey) && mapOfDPKeyToAcctPlan.get(searchKey).Decay_Curve_Template__c !=null
        ) {
            String scheduleType = dealProduct.Discount == 100 ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY : CRM_AppConstants.SCHEDULE_TYPE_BOTH;
            Integer initialQuantity = 0;

            Decimal finalPurchasePrice = dealProduct.Final_Purchase_Price__c != null ? dealProduct.Final_Purchase_Price__c : 0;
            Decimal finalPurchase = dealProduct.Final_Purchase__c != null ? dealProduct.Final_Purchase__c : 0;
            Id decayCurveId = dealProduct.Decay_Curve_Template__c;
            Decimal maxDaysCount = dealProduct.Decay_Curve_Template__r.MaxDecayCurveItemDay__c != null ? dealProduct.Decay_Curve_Template__r.MaxDecayCurveItemDay__c : 0;
            Integer maxDays = Integer.valueOf(maxDaysCount + 1);

            Date initialDateJapan = initialDate.addDays(maxDays); //Added as per detail design #482                         

            if (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH && dealProduct.Product2.CanUseQuantitySchedule && dealProduct.Product2.CanUseRevenueSchedule) {
                schedules.add(createSchedules(
                    dealProduct.Id,
                    scheduleType,
                    (dealProduct.Initial_Quantity__c * finalPurchasePrice * (finalPurchase/100)),
                    initialQuantity,
                    CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE,
                    initialDateJapan
                ));
                dealProductIdSet.add(dealProduct.Id);
            }
        }
        return schedules;
    }

    /**
     * This method is used to create Replane Schedules based on Normal Decay Curve templates With Decay curve Item
     * @name: calculateDecayCurveSchedules
     * @param: OpportunityLineItem dealProduct - Insatnce of deal Product for which P&L  Schedules need to be created
     * @param: Date initialDate  - The initial Date to decide the Schedule Date of P&L Schedules
     * @param: Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems - Map of all Decay Curve Template Items for which schedules needs to be created
     * @param: Set<Id> dealProductIdSet - Set of deal Product Ids for which the schedules are recalculated and need to delete existing schedules
     * @param: Double promoPrice - The price on which revenue needs to be calculated for all schedules
     * @return List<OpportunityLineItemSchedule> - List of schedules genearated
     */
    private static List<OpportunityLineItemSchedule> calculateDecayCurveSchedulesJapan(
            OpportunityLineItem dealProduct,
            Date initialDate,
            Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems,
            Set<Id> dealProductIdSet
            //,map<String, Account_Plan__c> mapOfDPKeyToAcctPlan
    ) {
        //String SCHEDULE_DECAY_CURVE_TEMPLATE = label.CRM_Decay_Template_Schedule;  // Label for Description of Schedule
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();

        //String searchKey = createAccountProductKey(dealProduct); // Key of AccountId and ProductId

        if (
                dealProduct.Initial_Quantity__c != null && 
                dealProduct.Initial_Quantity__c != 0 && //null != searchKey && null != mapOfDPKeyToAcctPlan.get(searchKey) && mapOfDPKeyToAcctPlan.get(searchKey).Decay_Curve_Template__c != null
                dealProduct.Decay_Curve_Template__c != null
        ) {
            String scheduleType = dealProduct.Discount == 100 ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY: CRM_AppConstants.SCHEDULE_TYPE_BOTH;
            Decimal rentalPrice = dealProduct.Rental_Price__c != null ? dealProduct.Rental_Price__c : 0;
            Decimal revenueShare = dealProduct.Revenue_Share__c != null ? dealProduct.Revenue_Share__c : 0;
            Decimal noOfRenatalPerUnit = dealProduct.Number_of_Rentals_per_Unit__c != null ? dealProduct.Number_of_Rentals_per_Unit__c : 0;

            ID decayCurveId = dealProduct.Decay_Curve_Template__c;
            if (decayCurveId != null && mapTemplateIdToItems.containsKey(decayCurveId)) {
                Decimal quantity = 0;
                for (Decay_Curve_Item__c currentItem : mapTemplateIdToItems.get(decayCurveId)) {
                    Integer maxDays = Integer.valueOf(currentItem.Day_Number__c);  // Converting Decimal to Integer
                    Date initialDateJapFinal = initialDate.addDays(maxDays);
                    Decimal percentDecayCurveItem = currentItem.Percent_Allocation__c;
                    Decimal revenue = (dealProduct.Initial_Quantity__c * rentalPrice * (revenueShare/100) * noOfRenatalPerUnit * (percentDecayCurveItem/100));
                    // Create Schedules by decay curve template
                    schedules.add(createSchedules(
                        dealProduct.Id,
                        scheduleType,
                        revenue,
                        quantity, 
                        CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(currentItem.Percent_Allocation__c) + ' %',
                        initialDateJapFinal
                    ));
                    dealProductIdSet.add(dealProduct.Id);
                }
            }
        }
        return schedules;
    }

    /**
     * This method is used to get Account Plans reated with Deal Products (US#483 - Japan Method)
     * @name: getAccountPlans
     * @param : Set<Id> dealProdAcctIdSet - Set of Accounts Id related to DealProdcuts
     * @return List<Account_Plan__c>> - List of Account Plans related to Deal products
     
    private static Map<String,Account_Plan__c> getAccountPlans(Set<String> setOfDealProductKeys){
        list<Account_Plan__c> acctPlanLst;
        map<String,Account_Plan__c> mapOfDPKeyToAccPlan = new map<String, Account_Plan__c>();
        
        acctPlanLst = new List<Account_Plan__c>([SELECT id,Handling_Fee__c,Customer__c,Final_Purchase_Price__c,Final_Purchase__c,Account_Product_Id__c,
                                                  Decay_Curve_Template__c, Number_of_Rentals_per_Unit__c,Revenue_Share__c,Rental_Price__c, NR_Product__c,
                                                  Decay_Curve_Template__r.MaxDecayCurveItemDay__c, Country_Plan__r.RecordType.Name 
                                                  FROM Account_Plan__c 
                                                  WHERE Account_Product_Id__c IN:setOfDealProductKeys 
                                                  AND Country_Plan__r.RecordTypeId =:CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE
                                                  AND RecordType.Name =: CRM_AppConstants.RENTAL_ACCOUNT_PLAN]);
        system.debug('===>> List of Account Plan acctPlanLst' + acctPlanLst); 
            for(Account_Plan__c accPlan : acctPlanLst){
                mapOfDPKeyToAccPlan.put(accPlan.Account_Product_Id__c,accPlan);
            }        
            return mapOfDPKeyToAccPlan;
    }
    
    private static String createAccountProductKey(OpportunityLineItem dealProduct){
        return String.ValueOf(dealProduct.Opportunity.Account.Id).substring(0, 15) + '-' + String.ValueOf(dealProduct.Product2.Id).substring(0, 15);
    }*/
    //Japan Development US#483 --- Ends Here Line no 741 to Line no 916----
}