/**
   @Author Cognizant
   @name CRM_EditAllOppProductsCtrl
   @CreateDate 12 Nov 2015
   @Description This class will be use to edit the deal products.
   @Version <1.0>
   @reference Requirement no 35
*/

global with sharing class CRM_EditAllOppProductsCtrl {
    public Opportunity deal;
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    static Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
    public boolean isGerman{get; set;}
    public boolean isFrance{get; set;} 
    public boolean isJapan{get; set;} 
    public boolean isJapanForSellThrough{get; set;}
    public boolean isJapanTerritory{get; set;}
    public boolean isFR_BXTerritory{get;set;}
    public boolean showCoopTab{get; set;}
    public Double highLevelForecast{get; set;}
    public Double highLevelTarget{get; set;}
    public Integer decimalPlaces{get; set;}
    public Boolean isRevenueShareAccount {get;set;}
    public Double coopRequestedDealAmount {get; set;}
    public Double coopBlanceFromBudget {get; set;}
    public boolean isEstimateAvailableOnDealAndDp{get; set;}
    //US:936:US Games
    public Boolean isUSCANMEXTerritory{get;set;}
    /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        /*String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();*/
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }

        /*if (currentUserLocale.contains('en-')) {
            currentUserLocale = currentUserLocale.substringBefore('-');
        }*/
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }

    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();
    }

    /**
     *Method to hide Decay Curve Field for DE Profiles ---- For Requirement 289
     
    global boolean hideOrDisableFields{
        get {
            return (CRM_Functional_Permissions__c.getInstance().DisableDecayCurveSelection__c == true ? true:false); 
        }
    }*/

    public CRM_EditAllOppProductsCtrl(ApexPages.Standardcontroller stdCon) {
        
        if (stdCon.getId() != null) {
            List<Opportunity> lstOpportunity =
                [
                    SELECT
                        Id, stageName, Sales_Organisation__c, RecordTypeId, AccountId, NR_Deal_Unique_Key__c,Account.Digital_Country_Code__c, Account.Consignment_Customer__c, Market_Type__c, Last_Published_Date__c, RecordType.DeveloperName,
                        Account.Sales_Organization__c, Bundle__c, Bundle__r.RecordTypeId, High_Level_Forecast__c, High_Level_Target__c, TotalOpportunityQuantity,Estimated_Quantity__c,
                        Account.Revenue_Share__c,Co_op_Requested_Amount__c,Estimated_Customer_Revenue__c,/*Coop_Budget__r.Co_op_Balance__c, US#954 Ankita US Games*/Amount,Co_op_Closed__c
                    FROM Opportunity WHERE Id = :stdCon.getId()
                ];
            if (!lstOpportunity.isEmpty()) {
                deal = lstOpportunity[0];
                isRevenueShareAccount = false;
                //US:936:US Games 
                isUSCANMEXTerritory = (deal.RecordTypeId != null && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL 
                                       && CRM_AppConstants.US_SALES_ORGS.contains(deal.Sales_Organisation__c));
            
            
                //isGerman = (lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE )? true: false;
                isFrance = (lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE)? true: false;
                isJapan = ((lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) &&(lstOpportunity[0].Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) && (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL))?  true: false;
                isJapanForSellThrough = ((lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) &&(lstOpportunity[0].Market_Type__c == CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE) && (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL))?  true: false;
                isGerman = (
                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                    ||
                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(lstOpportunity[0].Account.Digital_Country_Code__c))
                );
                isJapanTerritory = (
                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                    ||
                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                );
                
                isFR_BXTerritory = (
                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && 
                        (lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE ||
                         lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE ||
                         lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE
                        )
                    )
                    ||
                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && 
                        (lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE ||
                        lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_BG_DIGITAL_COUNTRY_CODE ||
                        lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_LX_DIGITAL_COUNTRY_CODE ||
                        lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_NL_DIGITAL_COUNTRY_CODE
                        )
                    )
                );
                if (isJapanTerritory) {
                    decimalPlaces = 0;
                } else {
                    decimalPlaces = 2;
                }
                if (lstOpportunity[0].Account.Revenue_Share__c) {
                    isRevenueShareAccount = true;
                }
                showCoopTab = populateShowCoopFieldsFlag(deal);
                if(deal != null && deal.High_Level_Target__c != null){
                    highLevelTarget = deal.High_Level_Target__c;
                }else{
                     //highLevelTarget = deal.TotalOpportunityQuantity;
                    highLevelTarget = deal.Estimated_Quantity__c;
                }
                if(deal != null && deal.High_Level_Forecast__c != null){
                    highLevelForecast = deal.High_Level_Forecast__c;
                }else if(deal != null && deal.High_Level_Target__c != null){
                    highLevelForecast = deal.High_Level_Target__c;
                }else{
                    highLevelForecast = 0;
                }
                coopRequestedDealAmount = deal.Co_op_Requested_Amount__c != null ? deal.Co_op_Requested_Amount__c : 0;
                //coopBlanceFromBudget = deal.Coop_Budget__r.Co_op_Balance__c != null ? deal.Coop_Budget__r.Co_op_Balance__c : 0;
                if(deal.Amount != 0 && deal.Amount != null)
                    isEstimateAvailableOnDealAndDp = true;
            }
        }
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    global boolean populateShowCoopFieldsFlag(Opportunity opp){
        String territorys;
        if(opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
            territorys = CRM_Hide_Coop_Fields__c.getInstance(opp.RecordType.DeveloperName) != null ? CRM_Hide_Coop_Fields__c.getInstance(opp.RecordType.DeveloperName).Edit_All_Territory__c : '';
        }else{
            territorys = CRM_Hide_Coop_Fields__c.getInstance('Deal') != null ? CRM_Hide_Coop_Fields__c.getInstance('Deal').Edit_All_Territory__c : '';
        }
        Set<String> setOfTerritorys = new Set<String>(territorys.split(';'));
        if(!setOfTerritorys.isEmpty()){
            if(setOfTerritorys.contains(opp.Sales_Organisation__c) || setOfTerritorys.contains(opp.Account.Digital_Country_Code__c))
                 return false;
        }
        return true;
    }
    
    /**
     * Method to check whether Quantity fields should be editable or read only
     */
    global Boolean getIsQuantityReadOnly() {
        if (
                deal != null && 
                (
                    (
                        !(
                            deal.Bundle__c != null && deal.Bundle__r.RecordTypeId == CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN &&
                            deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE
                        ) &&
                        deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                    )
                    || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_CLOSED
                )
        ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Method to check whther the deal is of Digital Record Type
     */
    global Boolean getIsDigitalDeal() {
        if (deal != null && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     *US#598  Method to check whther the deal is of Digital Record Type
     */
    global Boolean getIsNRDeal() {
        if (deal != null && deal.NR_Deal_Unique_Key__c != null && deal.NR_Deal_Unique_Key__c != '') {
            return true;
        } else {
            return false;
        }
    }
    
    

    /**
     * Method to check whther the Account related to the deal is of Consignment type
     */
    global Boolean getIsConsignmentCustomer() {
        if (deal != null && deal.AccountId != null && deal.Account.Consignment_Customer__c) {
            return true;
        } else {
            return false;
        }
    }
    /**
     * US#799 : Method to check whther the cost tab is accessible for user.
     */
    global Boolean getisAccessibleToUser() {
        if (Schema.SobjectType.OpportunityLineItem.fields.Override_COP__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Returns__c.isAccessible()
            || Schema.SobjectType.OpportunityLineItem.fields.PAP__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Sales_Allowance__c.isAccessible()
            || Schema.SobjectType.OpportunityLineItem.fields.Gema__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Merchandising__c.isAccessible()
            || Schema.SobjectType.OpportunityLineItem.fields.Distribution_Cost__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Production_Cost__c.isAccessible()
            || Schema.SobjectType.OpportunityLineItem.fields.Royalty_Fee_Fixed__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Master_Negative__c.isAccessible()
            || Schema.SobjectType.OpportunityLineItem.fields.Return_Cost__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Gross_receipt_taxes_FFA__c.isAccessible()
            || Schema.SobjectType.OpportunityLineItem.fields.Cash_Discounts__c.isAccessible() || Schema.SobjectType.OpportunityLineItem.fields.Doubtful_Accounts__c.isAccessible()
        ) {
            return true;
        } else {
            return false;
        }
    }
    
    
    /**
     * Method to fetch CRM_Max_Product_Limit__c to fetch Product limit
     */
    global Integer getMaxProductLimit() {
        return CRM_Max_Product_Limit__c.getInstance('Edit_Products') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Edit_Products').Count__c) : 0;
    }
    /**
     * Method to fetch picklist values for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     * @param first_val First value to be displayed along with the picklist values
     */
    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getFilterPicklistValues(
            String object_name,
            String field_name,
            String first_val
    ) {
        return CRM_AddProductsHelper.getFilterPicklistValues(object_name, field_name, first_val);
    } 
    global Boolean isPageReadOnly {
        get {
                if((deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_CLOSED) && deal.Account.Sales_Organization__c != CRM_AppConstants.TERRITORY_FRANCE_CODE) {
                        return true;
                }
                else if((deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_CLOSED) && deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE && deal.Last_Published_Date__c==null) {
                        return true;
                }
                else{
                    return false;
                }
        }
    }
    global Boolean isCoOpClosed{
         get {
                if(deal.Co_op_Closed__c == true && isGerman == true ){
                    return true;
                }else{
                    return false;
                }
         } 
    }
    
    /**
     *  Method to fetch the Deal Product from DealId which is called from EditProductsCtrl.js 
     *  @name getLineItems
     *  @param Id opportunityId
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.ProductToEdit[] getLineItems(Id opportunityId,set<Id> lineItemRecIds) {
        CRM_DataObjects.ProductToEdit[] listProducts = new CRM_DataObjects.ProductToEdit[]{};
        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
        Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers = new Map<Id, CRM_DataObjects.DealProdWrapper>();
        Set<String> dealProdAcctIdSet = new Set<String>();
        Boolean isJPForSellThrough = false;
        try{
            if(CRM_Functional_Permissions__c.getInstance().Prevent_Edit_All_OppProducts__c) {
                throw new CRM_EditProductsException(Label.CRM_Deal_Entry_NoAccessError);
            }
            List<Opportunity> lstOpportunity =  [SELECT Id, RecordTypeId,Storefront_Account__c,Start_Date__c, Account.Sales_Organization__c,Account.Digital_Country_Code__c FROM Opportunity WHERE Id = :opportunityId];
            system.debug('lineItemRecIds --------------'+lineItemRecIds);
            //US#985 Initialize the map for all the Rate cards
            if(lstOpportunity[0].Storefront_Account__c != null && lstOpportunity[0].Start_Date__c != null){
                CRM_PricingUtility.intializePrices(new Set<Id>{lstOpportunity[0].Storefront_Account__c},lstOpportunity[0].Start_Date__c,false);
            }
            String queryString;
            if(lineItemRecIds != null){
                queryString = 'SELECT  Id,' +
                                     // Line Item  Fields
                                     /*US 501 */ 'Royalty_Fee_Cost__c, Opportunity.Account.Digital_Country_Code__c,Royalty_Fee_Fixed__c, P_L_Decay_Curve_Template__c,Product2Id,Opportunity.AccountId, P_L_Quantity__c,'+
                                     ' Product2.Local_Title__r.Language_Code__c, toLabel(Product2.Product_Language_Code__c),Permanent_Price_Tier__c,'+ //US#663 - Added field Permanent_Price_Tier__c
                                     /*US#172*/'Product2.Country_Code__c,Product2.Tittle_Content_Type__c,Product2.Product_Market__c,Product2.Product_Format__c,'+//toLabel(Product2.Product_Format__c),
                                     'POS_Quantity__c, ProductCode, ListPrice, ListPrice__c, Cut_off_date__c, Quantity, Account_Price__c, PricebookEntryId,Product2.RecordTypeId,'+
                                     'Product2.Name, Product2.Id,   currencyISOCode, Target_Quantity__c, Actual_Quantity__c, Manually_Schedule__c,'+ //Suggested_Price__c,//US#895 -commneted code as a part of us to remove reference of suggested price
                                     'Minimum_Price__c, toLabel(Product2.Release_Category__c), Product2.Product_Type__c, Product2.Street_Date__c, Customer_Retail_Price__c, Decay_Curve_Template__r.Name, '+
                                     'Approved_Qty__c, ServiceDate, Returns__c, Sales_Allowance__c, Merchandising__c, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c,'+
                                     'Product2.Distribution_Cost__c, Product2.Production_Cost__c, Product2.Royalty_Fee_Fixed__c, Co_op_Requested_Amount__c, Reason__c, Comments__c,'+
                                     'Product2.Master_Negative__c, TotalPrice, Total_COP__c, Est_Contribution__c, Opportunity.RecordTypeId, Opportunity.StageName, Product2.Type__c,'+
                                     'Customer_Sales_Revenue__c, Customer_Contribution__c, Override_COP__c, Discount, Minimum_Contribution__c, PAP__c,Opportunity.Sales_Organisation__c,'+
                                     'P_L_Decay_Curve_Template__r.Name,Promoted_Price__c,NR__c,Discount__c,Initial_Back_Order_Quantity__c,Return_Cost__c,'+
                                     //Japan - DEF#3926
                                     'Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c, Override_Pricing__c, '+
                                     'Opportunity.Market_Type__c,Distribution_Cost__c,Production_Cost__c,Product2.Return_Cost__c,Master_Negative__c,'+
                                     'NR_Deal_Product_Unique_Key__c,toLabel(format__c),POS_Revenue__c,Actual_Revenue__c,Total_Quantity__c,'+//US#598 Untargeted deal Product and Product format added as a part of UserStory#617  //DEF#3977
                                     'Gema__c, Gross_receipt_taxes_FFA__c, Doubtful_Accounts__c,  Contribution__c, Cash_Discounts__c,Price_Tier__c,Opportunity.Storefront_Account__c,'+
                                     // Opportunity related Account Fields
                                     'Opportunity.Account.Consignment_Customer__c,Opportunity.PriceBook2Id,Opportunity.Start_Date__c,Opportunity.CloseDate, Opportunity.Account.Sales_Organization__c, Share__c, Opportunity.Replen__c, Opportunity.High_Level_Target__c, Opportunity.TotalOpportunityQuantity, Consignment_Multiplier__c,'+
                                     // Opportunity Line Item Schedules
                                     '(SELECT Id, Type, Quantity, ScheduleDate, Revenue  FROM OpportunityLineItemSchedules LIMIT 1)'+
                                    'FROM OpportunityLineItem WHERE OpportunityId = : opportunityId AND Id IN : lineItemRecIds';
            }else{
                 queryString = 'SELECT  Id,' +
                                     // Line Item  Fields
                                     /*US 501 */ 'Royalty_Fee_Cost__c, Opportunity.Account.Digital_Country_Code__c,Royalty_Fee_Fixed__c, P_L_Decay_Curve_Template__c,Product2Id,Opportunity.AccountId, P_L_Quantity__c,'+
                                     ' Product2.Local_Title__r.Language_Code__c, toLabel(Product2.Product_Language_Code__c),Permanent_Price_Tier__c,'+ //US#663 - Added field Permanent_Price_Tier__c
                                     /*US#172*/'Product2.Country_Code__c,Product2.Tittle_Content_Type__c,Product2.Product_Market__c,Product2.Product_Format__c,'+//toLabel(Product2.Product_Format__c),
                                     'POS_Quantity__c, ProductCode, ListPrice, ListPrice__c, Cut_off_date__c, Quantity, Account_Price__c, PricebookEntryId,Product2.RecordTypeId,'+
                                     'Product2.Name, Product2.Id,   currencyISOCode, Target_Quantity__c, Actual_Quantity__c, Manually_Schedule__c,'+ //Suggested_Price__c,//US#895 -commneted code as a part of us to remove reference of suggested price
                                     'Minimum_Price__c, toLabel(Product2.Release_Category__c), Product2.Product_Type__c, Product2.Street_Date__c, Customer_Retail_Price__c, Decay_Curve_Template__r.Name, '+
                                     'Approved_Qty__c, ServiceDate, Returns__c, Sales_Allowance__c, Merchandising__c, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c,'+
                                     'Product2.Distribution_Cost__c, Product2.Production_Cost__c, Product2.Royalty_Fee_Fixed__c, Co_op_Requested_Amount__c, Reason__c, Comments__c,'+
                                     'Product2.Master_Negative__c, TotalPrice, Total_COP__c, Est_Contribution__c, Contribution__c, Opportunity.RecordTypeId, Opportunity.StageName, Product2.Type__c,'+
                                     'Customer_Sales_Revenue__c, Customer_Contribution__c, Override_COP__c, Discount, Minimum_Contribution__c, PAP__c,Opportunity.Sales_Organisation__c,'+
                                     'P_L_Decay_Curve_Template__r.Name,Promoted_Price__c,NR__c,Discount__c,Initial_Back_Order_Quantity__c,Return_Cost__c,'+
                                     //Japan - DEF#3926
                                     'Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c, Override_Pricing__c, '+
                                     'Opportunity.Market_Type__c,Distribution_Cost__c,Production_Cost__c,Product2.Return_Cost__c,Master_Negative__c,'+
                                     'NR_Deal_Product_Unique_Key__c,toLabel(format__c),POS_Revenue__c,Actual_Revenue__c,Total_Quantity__c,'+//US#598 Untargeted deal Product and Product format added as a part of UserStory#617  //DEF#3977
                                     'Gema__c, Gross_receipt_taxes_FFA__c, Doubtful_Accounts__c,  Cash_Discounts__c,Price_Tier__c,Opportunity.Storefront_Account__c,'+
                                     // Opportunity related Account Fields
                                     'Opportunity.Account.Consignment_Customer__c,Opportunity.PriceBook2Id,Opportunity.Start_Date__c,Opportunity.CloseDate, Opportunity.Account.Sales_Organization__c, Share__c, Opportunity.Replen__c, Opportunity.High_Level_Target__c, Opportunity.TotalOpportunityQuantity, Consignment_Multiplier__c,'+
                                     // Opportunity Line Item Schedules
                                     '(SELECT Id, Type, Quantity, ScheduleDate, Revenue  FROM OpportunityLineItemSchedules LIMIT 1)'+
                                    'FROM OpportunityLineItem WHERE OpportunityId = : opportunityId ';
            }
                                    
                                    if((lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                                    || (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)){
                                        queryString +=  ' ORDER BY ProductCode ' ;  
                                    }else{ 
                                        queryString += ' ORDER BY Product2.Name';
                                    }
            system.debug('queryString*************'+queryString);
            for(OpportunityLineItem dealProduct : Database.query(queryString)){
                if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                    CRM_DataObjects.DealProdWrapper dealProductWrapperInstance = new CRM_DataObjects.DealProdWrapper();
                    dealProductWrapperInstance.dealCurrencyCode = dealProduct.Opportunity.CurrencyIsoCode;
                    dealProductWrapperInstance.pricebookId = dealProduct.Opportunity.Pricebook2Id;
                    dealProductWrapperInstance.productId = dealProduct.Product2Id;
                    dealProductWrapperInstance.productRecTypeId = digitalProductRecordTypeId;
                    mapIdToDealProductWrappers.put(dealProduct.Id, dealProductWrapperInstance);
                }
                
                String accountProductIdKey = String.ValueOf(dealProduct.Opportunity.AccountId).substring(0, 15) + '-' + String.ValueOf(dealProduct.Product2Id).substring(0, 15);
                System.debug('#accountProductIdKey' + accountProductIdKey);
                dealProdAcctIdSet.add(accountProductIdKey);
                
                lstDealProducts.add(dealProduct);
            }
            if (mapIdToDealProductWrappers.size() > 0) {
                CRM_ApplicationUtility.updateDigitalProductStreetDates(mapIdToDealProductWrappers.values());
            }
            //Map<String, Account_Plan__c> mapDPKeyToAccPlan = getAccountPlans(dealProdAcctIdSet);
            for(OpportunityLineItem dealProduct : lstDealProducts) {
                isJPForSellThrough = ((dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) &&(dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE) && (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL))?  true: false;
                Boolean isJapanTerritory = (
                    (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                    ||
                    (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                );
                Decimal promotedPrice = 0;
                Double replenQuantity = 0;
                CRM_DataObjects.ProductToEdit prod = new CRM_DataObjects.ProductToEdit();

                //if (dealProduct.Opportunity != null && dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                /*if (isJPForSellThrough) { 
                    if (
                            (dealProduct.Initial_Quantity__c == null || dealProduct.Initial_Quantity__c == 0) &&
                            (dealProduct.Initial_Back_Order_Quantity__c == null || dealProduct.Initial_Back_Order_Quantity__c == 0) &&
                            dealProduct.Replen_Quantity__c == null
                    ) {
                        replenQuantity = dealProduct.Quantity;
                    } else {
                        replenQuantity = dealProduct.Replen_Quantity__c; 
                    }
                } else {
                     if ((dealProduct.Initial_Quantity__c == null || dealProduct.Initial_Quantity__c == 0) && dealProduct.Replen_Quantity__c == null) {
                        replenQuantity = dealProduct.Quantity;
                     } else {
                        replenQuantity = dealProduct.Replen_Quantity__c; 
                    }
                }*/
                //} else {
                    //replenQuantity = dealProduct.Replen_Quantity__c;
                //}
                
                replenQuantity = dealProduct.Replen_Quantity__c;
                //prod.coopReason = new CRM_DataObjects.PicklistOption[]{};
                prod.lineItemId = dealProduct.Id;
                prod.pricebookEntryId = dealProduct.PricebookEntryId;
                prod.productId = dealProduct.Product2.Id;
                prod.productName = dealProduct.Product2.Name;
                prod.format = dealProduct.Product2.Product_Format__c;
                prod.prodFormat = dealProduct.format__c;//US#617
                prod.productCode = dealProduct.ProductCode;
                //Added for laMoulinette functionality for France - Begin
                prod.sharePercent = dealProduct.Share__c;
                //US#663 - added field
                prod.PermanentPriceTier = dealProduct.Permanent_Price_Tier__c;
                prod.replenPercent = dealProduct.Opportunity.Replen__c;
                //Added for laMoulinette functionality for France - End
                /*
                if(dealProduct != null && dealProduct.Opportunity.High_Level_Target__c != null){
                    prod.highLevelTarget = dealProduct.Opportunity.High_Level_Target__c;
                }else{
                    prod.highLevelTarget = dealProduct.Opportunity.TotalOpportunityQuantity;
                }*/
                //prod.releaseCategory = dealProduct.Product2.Release_Category__c;
                /*if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                    if (mapIdToDealProductWrappers.containsKey(dealProduct.Id)) {
                        CRM_DataObjects.DealProdWrapper dealProductWrapper =
                            mapIdToDealProductWrappers.get(dealProduct.Id);
                        System.debug('--dealProductWrapper.productStreetDate-->'+dealProductWrapper.productStreetDate);
                        prod.releaseCategory = dealProductWrapper.releaseCatgory;
                    }
                }else if (
                    dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId
                ) {
                    prod.releaseCategory = dealProduct.Product2.Release_Category__c;
                }*/
                prod.posQuantity = dealProduct.POS_Quantity__c;
                prod.totalQty = dealProduct.Quantity;
                /*if(dealProduct.Account_Price__c != null){
                    prod.listPrice = dealProduct.Account_Price__c;
                }else{*/
                    // DEF#4438
                    prod.listPrice = dealProduct.ListPrice__c; // list price calculated from Pricebook Entry Period Object
                //}
                
                prod.accountPrice = dealProduct.Account_Price__c;
                //prod.minimumPrice = dealProduct.Minimum_Price__c; // German Requirement Provided by Jorge on Mail.
                prod.pap = dealProduct.PAP__c;
                
                /*if(dealProduct.Discount > 0.00){
                    prod.discount = dealProduct.Discount;
                }else{
                    prod.discount = 0.00;
                }*/
                if(dealProduct.Discount__c != null){
                    prod.discount = dealProduct.Discount__c;
                }else{
                    prod.discount = 0.00;
                }
                if (dealProduct.Promoted_Price__c == null) {
                    if(dealProduct.Account_Price__c > 0.00 && dealProduct.Discount > 0.00){
                        promotedPrice = dealProduct.Account_Price__c *(1-dealProduct.Discount/100);
                    }else{
                        promotedPrice = dealProduct.Account_Price__c != null ? dealProduct.Account_Price__c : 0;
                    }
                } else {
                    promotedPrice = dealProduct.Promoted_Price__c;
                }
                if (isJapanTerritory) {
                    prod.promotedPrice = promotedPrice.SetScale(0);
                } else {
                    prod.promotedPrice = promotedPrice.SetScale(2);
                }
                prod.startDate = convertDateToString(dealProduct.ServiceDate);
                prod.approvedQty = dealProduct.Approved_Qty__c;
                prod.customerRetailPrice = dealProduct.Customer_Retail_Price__c;
                //prod.materialStreetDate = convertDateToString(dealProduct.Product2.Street_Date__c);
                if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                    if (mapIdToDealProductWrappers.containsKey(dealProduct.Id)) {
                        CRM_DataObjects.DealProdWrapper dealProductWrapper =
                            mapIdToDealProductWrappers.get(dealProduct.Id);
                        /*if (
                            dealProduct.Opportunity.Start_Date__c <= dealProductWrapper.productStreetDate &&
                            dealProductWrapper.productStreetDate < dealProduct.Opportunity.CloseDate
                        ) {
                            prod.materialStreetDate = convertDateToString(dealProductWrapper.productStreetDate);
                        }*/
                        prod.materialStreetDate = convertDateToString(dealProductWrapper.productStreetDate);
                    }
                }else if (
                    dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId
                ) {
                    prod.materialStreetDate = convertDateToString(dealProduct.Product2.Street_Date__c);
                }
                prod.cutOffDate = convertDateToString(dealProduct.Cut_off_date__c);
                
                prod.salesAllowance = dealProduct.Sales_Allowance__c;
                prod.returns = dealProduct.Returns__c;
                prod.distributionCost = dealProduct.Distribution_Cost__c != Null ? dealProduct.Distribution_Cost__c : ((isJapanTerritory && dealProduct.Product2.Distribution_Cost__c != null) ? dealProduct.Product2.Distribution_Cost__c.SetScale(0) : dealProduct.Product2.Distribution_Cost__c);
                prod.returnCost = dealProduct.Return_Cost__c != Null ? dealProduct.Return_Cost__c : ((isJapanTerritory && dealProduct.Product2.Return_Cost__c != null) ? dealProduct.Product2.Return_Cost__c.SetScale(0) : dealProduct.Product2.Return_Cost__c);
                prod.productionCost = dealProduct.Production_Cost__c != Null ? dealProduct.Production_Cost__c : ((isJapanTerritory && dealProduct.Product2.Production_Cost__c != null) ? dealProduct.Product2.Production_Cost__c.SetScale(0) : dealProduct.Product2.Production_Cost__c);

                //prod.coop = dealProduct.Coop__c;
                prod.merchandising = dealProduct.Merchandising__c;
                
                //US 501
                /*if(
                    (
                        dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                        dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE 
                     )||
                     (
                        dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                            (
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
                            )
                     )
                ){
                    prod.royalFeeFixed = dealProduct.Product2.Royalty_Fee_Fixed__c;
                }
                else{
                    prod.royalFeeFixed = dealProduct.Royalty_Fee_Cost__c;                
                }*/
                
                if(
                    (
                        dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                        (
                            dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE ||
                            dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE ||
                            dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE ||
                            dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_ITALY_CODE //US#799 - added check for italy
                        )       
                    )||
                    (
                        dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                            (
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE ||
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_BG_DIGITAL_COUNTRY_CODE ||
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_NL_DIGITAL_COUNTRY_CODE ||
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_LX_DIGITAL_COUNTRY_CODE ||
                                dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE //US#799 - added check for italy
                            )
                    )
                  ){
                        prod.royalFeeFixed = dealProduct.Royalty_Fee_Cost__c; 
                  }
                  else{
                      prod.royalFeeFixed = dealProduct.Royalty_Fee_Fixed__c!=null ? dealProduct.Royalty_Fee_Fixed__c:((isJapanTerritory && dealProduct.Product2.Royalty_Fee_Fixed__c != null) ? dealProduct.Product2.Royalty_Fee_Fixed__c.SetScale(0) : dealProduct.Product2.Royalty_Fee_Fixed__c);//dealProduct.Royalty_Fee_Fixed__c:dealProduct.Product2.Royalty_Fee_Fixed__c;
                      
                  }
                  
                //prod.masterNegative = dealProduct.Product2.Master_Negative__c;
                prod.masterNegative = dealProduct.Master_Negative__c != Null ? dealProduct.Master_Negative__c : ((isJapanTerritory && dealProduct.Product2.Master_Negative__c != null) ? dealProduct.Product2.Master_Negative__c.SetScale(0) : dealProduct.Product2.Master_Negative__c);
                prod.overrideCOP = dealProduct.Override_COP__c;
                if(promotedPrice != null){
                    if(isJPForSellThrough && dealProduct.Initial_Back_Order_Quantity__c != null){ 
                        if (dealProduct.Replen_Quantity__c != null && dealProduct.Initial_Quantity__c != null) {
                            prod.totalPrice = (dealProduct.Replen_Quantity__c + dealProduct.Initial_Quantity__c + dealProduct.Initial_Back_Order_Quantity__c) * promotedPrice;
                        } else if (dealProduct.Replen_Quantity__c != null ) {
                            prod.totalPrice = (dealProduct.Replen_Quantity__c + dealProduct.Initial_Back_Order_Quantity__c) * promotedPrice;
                        } else if (dealProduct.Initial_Quantity__c != null && promotedPrice != null) {
                            prod.totalPrice = (dealProduct.Initial_Quantity__c + dealProduct.Initial_Back_Order_Quantity__c ) * promotedPrice;
                        } else{
                            prod.totalPrice = dealProduct.Initial_Back_Order_Quantity__c * promotedPrice;
                        }
                    }else{
                        if (dealProduct.Replen_Quantity__c != null && dealProduct.Initial_Quantity__c != null ) {
                            prod.totalPrice = (dealProduct.Replen_Quantity__c + dealProduct.Initial_Quantity__c) * promotedPrice;
                        } else if (dealProduct.Replen_Quantity__c != null) {
                            prod.totalPrice = dealProduct.Replen_Quantity__c * promotedPrice;
                        } else if (dealProduct.Initial_Quantity__c != null) {
                            prod.totalPrice = dealProduct.Initial_Quantity__c * promotedPrice;
                        }
                    }
                }else {
                         prod.totalPrice = 0;
                }

                if (prod.totalPrice != null){
                    if (isJapanTerritory) {
                        prod.totalPrice = Decimal.valueOf(prod.totalPrice).setScale(0);
                    } else {
                        prod.totalPrice = Decimal.valueOf(prod.totalPrice).setScale(2);
                    }
                }

                //prod.totalPrice = dealProduct.Replen_Quantity__c != null && promotedPrice != null ? dealProduct.Replen_Quantity__c * promotedPrice : 0;
                prod.totalCOP = dealProduct.Total_COP__c;
                prod.estContribution = dealProduct.Est_Contribution__c;
                prod.customerSalesRevenue = dealProduct.Customer_Sales_Revenue__c;
                prod.customerContribution = dealProduct.Customer_Contribution__c;
                prod.minimumContribution = dealProduct.Minimum_Contribution__c;
                //prod.isMarketingMaterial = dealProduct.Product2.Marketing_Material__c;
                prod.currencyCode = dealProduct.currencyISOCode;
                prod.dealOrOrderId = opportunityId;            
                prod.isSelected = false;
                /*if(dealProduct.Opportunity.Sales_Organisation__c == '6014'){
                    prod.isGermanyAccount = true;
                }*/
                prod.targetUnit = dealProduct.Target_Quantity__c;
                prod.actualQty = dealProduct.Actual_Quantity__c;
                prod.initialQuantity = dealProduct.Initial_Quantity__c;
                if (isJPForSellThrough && dealProduct.Initial_Back_Order_Quantity__c != null){
                    prod.initialBackOrderQuantity = dealProduct.Initial_Back_Order_Quantity__c;
                    if (prod.initialQuantity != null) {
                        prod.suggestedPrice = prod.targetUnit - (prod.initialQuantity + dealProduct.Initial_Back_Order_Quantity__c);
                    } else {
                        prod.suggestedPrice = prod.targetUnit - dealProduct.Initial_Back_Order_Quantity__c;
                    }
                } else if (prod.initialQuantity != null && prod.targetUnit != null) {
                    prod.suggestedPrice = prod.targetUnit - prod.initialQuantity;
                }
                prod.replenQuantity = replenQuantity;
                prod.decayCurveTemplate = dealProduct.Decay_Curve_Template__c;
                if (dealProduct.Decay_Curve_Template__c != null) {
                    prod.decayCurveTemplateName = dealProduct.Decay_Curve_Template__r.Name;
                }
                //Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Reason__c.getDescribe();
                //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                //prod.nrCoopAmount = dealProduct.Coop_Requested_Amount_NR__c;
                prod.nrCoopAmount = dealProduct.Co_op_Requested_Amount__c;
                prod.coopReason = dealProduct.Reason__c;
                //US#172 US#985 Use Rate Card for Price tier
                prod.priceTier = dealProduct.Price_tier__c; 
                List<Rate_Card__c> lstPricingRecords = new List<Rate_Card__c>();
                if(dealProduct.Opportunity.Storefront_Account__c != null && dealProduct.Opportunity.Start_Date__c != null){
                    lstPricingRecords = CRM_PricingUtility.fetchPricing(dealProduct.Opportunity.Storefront_Account__c,dealProduct.Opportunity.Start_Date__c,dealProduct.Product2) ;
                }
                for(Rate_Card__c pricing : lstPricingRecords){
                    prod.lstPriceTier.add(pricing.Price_tier__c); 
                }
                //US#985 End Ankita
                prod.isNR = dealProduct.NR__c;
                //prod.coopReason.add(dealProduct.Reason__c);
                /*
                if (dealProduct.Reason__c != null) {
                    CRM_DataObjects.PicklistOption selOption = new CRM_DataObjects.PicklistOption(dealProduct.Reason__c, dealProduct.Reason__c);
                    selOption.selected = true;
                    prod.coopReason.add(selOption);
                }
                */
                prod.coopComments = dealProduct.Comments__c;
                //prod.allocationOverride = dealProduct.Allocation_Override__c;
                /*if(dealProduct.Est_Contribution__c != null && dealProduct.Est_Contribution__c != 0 && dealProduct.Quantity != null && dealProduct.Quantity != 0){
                        prod.estContributionPercent =  (dealProduct.Est_Contribution__c / dealProduct.Quantity).setScale(2);
                }
                // DEF JAPAN ISSUES : 13 -> All Territories [Estimate Contribution / Estimated Revenue]
                if (prod.estContribution != null && prod.estContribution != 0 && prod.totalPrice != null && prod.totalPrice != 0) {
                    prod.estContributionPercent = prod.estContribution / prod.totalPrice;
                } else {
                    prod.estContributionPercent = 0;
                }*/
                
                // DEF#4400
                prod.estContributionPercent = dealProduct.Contribution__c;
                prod.scheduleEnabled = dealProduct.OpportunityLineItemSchedules != null && dealProduct.OpportunityLineItemSchedules.size() > 0 ? true : false;
                //prod.languageCode = dealProduct.Product2.Local_Title__r.Language_Code__c != null ? dealProduct.Product2.Local_Title__r.Language_Code__c.toUppercase() : 'NA';
                prod.languageCode = dealProduct.Product2.Product_Language_Code__c != null ? dealProduct.Product2.Product_Language_Code__c.toUppercase() : 'NA';
                prod.isManuallySchedule = dealProduct.Manually_Schedule__c;
                if (dealProduct.Replen_Delay_Days__c == null) {
                    //if (replenQuantity != null && replenQuantity > 0) {
                    if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                        prod.replenDelayDays = 7;
                    }
                    //}
                } else {
                    prod.replenDelayDays = Integer.valueOf(dealProduct.Replen_Delay_Days__c);
                }
                if (dealProduct.Opportunity != null && dealProduct.Opportunity.Account != null && dealProduct.Opportunity.Account.Consignment_Customer__c) {
                    prod.isConsignmentCustomer = true;
                    if (dealProduct.P_L_Quantity__c == null) {
                        prod.plQuantity = dealProduct.Target_Quantity__c;
                    } else {
                        prod.plQuantity = dealProduct.P_L_Quantity__c;
                    }

                    // Set the P&L Decay Template default to Account Decay Template if P&L Decay Template is not set on Deal Product
                    /*if (dealProduct.P_L_Decay_Curve_Template__c == null) {
                        prod.plDecayCurveTemplate = dealProduct.Account.P_L_Decay_Curve_Template__c;
                        if (Account.P_L_Decay_Curve_Template__c != null) {
                            prod.plDecayCurveTemplateName = dealProduct.Account.P_L_Decay_Curve_Template__r.Name;
                        }
                    } else {*/
                        prod.plDecayCurveTemplate = dealProduct.P_L_Decay_Curve_Template__c;
                        prod.plDecayCurveTemplateName = dealProduct.P_L_Decay_Curve_Template__r.Name;
                    //}
                } else {
                    prod.isConsignmentCustomer = false;
                }

                //Japan
                prod.overrideRentalPrices = 
                        ((!prod.isNR || (prod.isNR && dealProduct.NR_Deal_Product_Unique_Key__c == null)) && !dealProduct.Override_Pricing__c)
                        ? true : dealProduct.Override_Pricing__c;
                /*if(dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE){
                    String accountProductIdKey = String.ValueOf(dealProduct.Opportunity.AccountId).substring(0, 15) + '-' + String.ValueOf(dealProduct.Product2Id).substring(0, 15);
                    if(!mapDPKeyToAccPlan.isEmpty() && mapDPKeyToAccPlan.containsKey(accountProductIdKey)){
                        Account_Plan__c accPlan = mapDPKeyToAccPlan.get(accountProductIdKey);
                        //Japan - DEF#3926
                        prod.handlingFee = dealProduct.Handling_Fee__c != null ? dealProduct.Handling_Fee__c : accPlan != null ? accPlan.Handling_Fee__c : 0;
                        prod.rentalPrice = dealProduct.Rental_Price__c != null ? dealProduct.Rental_Price__c : accPlan != null ? accPlan.Rental_Price__c : 0;
                        prod.revenueShare = dealProduct.Revenue_Share__c != null ? dealProduct.Revenue_Share__c : accPlan != null ? accPlan.Revenue_Share__c : 0;
                        prod.numberOfRentals = dealProduct.Number_of_Rentals_per_Unit__c != null ? dealProduct.Number_of_Rentals_per_Unit__c : accPlan != null ? accPlan.Number_of_Rentals_per_Unit__c : 0;
                        prod.finalPurchasePrice = dealProduct.Final_Purchase_Price__c != null ? dealProduct.Final_Purchase_Price__c : accPlan != null ? accPlan.Final_Purchase_Price__c : 0;
                        prod.finalPurchase = dealProduct.Final_Purchase__c != null ? dealProduct.Final_Purchase__c : accPlan != null ? accPlan.Final_Purchase__c : 0;
                        prod.decayCurve = dealProduct.Decay_Curve_Template__c != null ? dealProduct.Decay_Curve_Template__r.Name : accPlan != null && accPlan.Decay_Curve_Template__c != null ? accPlan.Decay_Curve_Template__r.Name : '';
                    }
                }*/
                //US#598
                if((dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && prod.isNR) &&
                    ((dealProduct.Actual_Revenue__c == 0 || dealProduct.Actual_Revenue__c == NULL) &&
                     (dealProduct.POS_Revenue__c == 0 || dealProduct.POS_Revenue__c == NULL) && 
                     (dealProduct.Target_Quantity__c == 0 || dealProduct.Target_Quantity__c == NULL) &&
                     (dealProduct.Total_Quantity__c == 0 || dealProduct.Total_Quantity__c == NULL))){
                       prod.isUnTargetedDealProd = true; 
                }
                system.debug('*****************************************'+prod.isUnTargetedDealProd);
                if (isJapanTerritory) {
                    prod.handlingFee = dealProduct.Handling_Fee__c;
                    prod.rentalPrice = dealProduct.Rental_Price__c;
                    prod.revenueShare = dealProduct.Revenue_Share__c;
                    prod.numberOfRentals = dealProduct.Number_of_Rentals_per_Unit__c;
                    prod.finalPurchasePrice = dealProduct.Final_Purchase_Price__c;
                    prod.finalPurchase = dealProduct.Final_Purchase__c;
                    //prod.decayCurve = dealProduct.Decay_Curve_Template__c;
                }
                //US #581: Populate Consignment Multiplier on Deal Product
                prod.consignmentMultiplier = dealProduct.Consignment_Multiplier__c;
                
                // Added for Germany US #283
                prod.gema = dealProduct.Gema__c;
                prod.grossReceiptTaxesFFA = dealProduct.Gross_receipt_taxes_FFA__c;
                prod.doubtfulAccounts = dealProduct.Doubtful_Accounts__c;
                prod.cashDiscounts = dealProduct.Cash_Discounts__c;
                listProducts.add(prod);
            }
        }
        catch(Exception e){
            throw new CRM_EditProductsException(e.getMessage());
        }
        return listProducts;
    }

    /**
     *  Method to update the Deal Product on a Deal based on changes made on Edit All Products page
     *  @name saveLineItems
     *  @param Id opportunityId, List<CRM_DataObjects.ProductToEdit> products, Boolean quickSave
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction
    static global CRM_DataObjects.ProductToEdit[] saveLineItems(Id opportunityId, List<CRM_DataObjects.ProductToEdit> products, Boolean quickSave) {
        // Get all current products
        Map<Id,OpportunityLineItem> mapCurrentDealProducts = new Map<Id,OpportunityLineItem>([SELECT Id, POS_Quantity__c,P_L_Quantity__c, P_L_Decay_Curve_Template__c,PAP__c, PricebookEntryId, Quantity, Discount, Customer_Retail_Price__c, UnitPrice, Returns__c, Sales_Allowance__c,
                                                                                          Promoted_Price__c,/*Coop__c,*/ Merchandising__c, Return_Cost__c, Product2.Distribution_Cost__c, Product2.Production_Cost__c, Product2.Royalty_Fee_Fixed__c, Opportunity.stagename,
                                                                                          Product2.Master_Negative__c, Opportunity.RecordTypeId, Opportunity.Account.Sales_Organization__c,Opportunity.Account.Digital_Country_Code__c,Opportunity.Market_Type__c,Initial_Back_Order_Quantity__c,
                                                                                          Opportunity.AccountId,Product2.Country_Code__c,Product2.Tittle_Content_Type__c,Product2.Product_Market__c,Product2.Product_Format__c,ListPrice__c, 
                                                                                          Override_Pricing__c, Gema__c,Price_Tier__c, Gross_receipt_taxes_FFA__c, Doubtful_Accounts__c, Cash_Discounts__c,
                                                                                          (Select Id, Type,OpportunityLineItemId, Description, Quantity, ScheduleDate, Revenue  From OpportunityLineItemSchedules)
                                                  FROM OpportunityLineItem
                                                  WHERE OpportunityId = :opportunityId]);
                                                  
        // Build a map for OpportunityLineItemSchedule with PriceBookEntryId as key
        Map<Id, List<OpportunityLineItemSchedule>> mapCurrentDealProductsSchedule = new Map<Id, List<OpportunityLineItemSchedule>>();
        set<Id> lineItemIds = new set<Id>();
        // Run through list of records to update and track the upsert records
        List<OpportunityLineItem> lstDealProducttoUpsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstDealProducttoDelete = new List<OpportunityLineItem>();
        //List<OpportunityLineItemSchedule> lstDealProductScheduleToDelete = new List<OpportunityLineItemSchedule>();
        //List<FutureSchedulesWrapper> lstDealProductScheduleToInsert = new List<FutureSchedulesWrapper>();
        System.debug('products----' + products);
        Boolean isJPForSellThrough = false;
        Boolean isJPForRental = false;
        for (CRM_DataObjects.ProductToEdit x : products) {
            if (mapCurrentDealProducts.containsKey(x.lineItemId)) {
                lineItemIds.add(mapCurrentDealProducts.get(x.lineItemId).Id);
                OpportunityLineItem dealProduct = mapCurrentDealProducts.get(x.lineItemId);
                //US#172 Price Tier 
                dealProduct.Price_Tier__c = x.priceTier;
                isJPForSellThrough = ((dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) &&(dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE) && (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL))?  true: false;
                isJPForRental = (
                    (
                        (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) ||
                        (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                    ) && 
                    (dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE)
                ) ?  true: false;
                // Change to quantity on existing product
                if (x.totalQty == null || x.totalQty == 0) {
                    lstDealProducttoDelete.add(dealProduct);
                } else {
                    //dealProduct.POS_Quantity__c = x.posQuantity;
                    //system.debug('Discounts --->'+dealProduct.Discount +'-'+ x.discount);
                    if(dealProduct.OpportunityLineItemSchedules != null && dealProduct.OpportunityLineItemSchedules.size() > 0) {
                        /*if (dealProduct.Discount != x.discount) {
                            String scheduleType = '';
                            lstDealProductScheduleToDelete.addAll(dealProduct.OpportunityLineItemSchedules);
                            // If Manually Schedule = true, take backup of schedules and delete them so that Discount can be modified
                            if (x.isManuallySchedule) {
                                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                                    FutureSchedulesWrapper scheduleInstance = new FutureSchedulesWrapper();
                                    scheduleInstance.schedule = schedule.clone();
                                    lstDealProductScheduleToInsert.add(scheduleInstance);
                                    scheduleType = schedule.Type;
                                }
                            }
                            if (
                                (scheduleType == CRM_AppConstants.SCHEDULE_TYPE_BOTH || scheduleType == CRM_AppConstants.SCHEDULE_TYPE_REVENUE)
                                && x.discount == 100
                            ) {
                                throw new CRM_EditProductsException(Label.CRM_Cannot_Add_Discount_As_100_For_Manual_Revenue_Schedules);
                            }
                        }*/
                    } else {
                         if (x.initialBackOrderQuantity != null && isJPForSellThrough) {
                            if (x.initialQuantity != null && x.replenQuantity != null) {
                                dealProduct.Quantity = x.initialQuantity + x.replenQuantity + x.initialBackOrderQuantity;
                            } else if (x.initialQuantity != null) {
                                dealProduct.Quantity = x.initialQuantity + x.initialBackOrderQuantity;
                            } else if (x.replenQuantity != null) {
                                dealProduct.Quantity = x.replenQuantity + x.initialBackOrderQuantity;
                            } else {
                                dealProduct.Quantity = x.initialBackOrderQuantity;
                            }
                         } else {
                            if (x.initialQuantity != null && x.replenQuantity != null) {
                                dealProduct.Quantity = x.initialQuantity + x.replenQuantity;
                            } else if (x.initialQuantity != null) {
                                dealProduct.Quantity = x.initialQuantity;
                            } else if (x.replenQuantity != null) {
                                dealProduct.Quantity = x.replenQuantity;
                            }
                         }
                    }
                    //dealProduct.Quantity = x.totalQty;
                    //dealProduct.Discount = x.discount;
                    //System.debug('--dealProduct.Discount-->'+dealProduct.Discount);
                    dealProduct.Customer_Retail_Price__c = x.customerRetailPrice;
                    Decimal promoPrice = x.promotedPrice;
                    //US#663 - added check for promo price
                    if(promoPrice!= null){
                        dealProduct.Promoted_Price__c = promoPrice.setScale(2);
                    }
                    //dealProduct.Coop__c = x.coop;
                    dealProduct.Merchandising__c = x.merchandising;
                    dealProduct.Returns__c = x.returns;
                    dealProduct.Sales_Allowance__c = x.salesAllowance;
                    dealProduct.Distribution_Cost__c  = x.distributionCost;
                    dealProduct.Return_Cost__c  = x.returnCost;
                    dealProduct.Production_Cost__c = x.productionCost;
                    dealProduct.Royalty_Fee_Fixed__c  = x.royalFeeFixed;
                    dealProduct.Master_Negative__c  = x.masterNegative;
                    dealProduct.Minimum_Contribution__c = x.minimumContribution;
                    dealProduct.PAP__c = x.pap;
                    dealProduct.Target_Quantity__c = x.targetUnit;
                    dealProduct.Initial_Quantity__c = x.initialQuantity;
                    dealProduct.Initial_Back_Order_Quantity__c = x.initialBackOrderQuantity;
                    dealProduct.Replen_Quantity__c = x.replenQuantity;
                    dealProduct.Decay_Curve_Template__c = x.decayCurveTemplate;
                    //dealProduct.Coop_Requested_Amount_NR__c = x.nrCoopAmount;
                    dealProduct.Co_op_Requested_Amount__c = x.nrCoopAmount;
                    dealProduct.Reason__c = x.coopReason;  
                    dealProduct.Comments__c = x.coopComments;
                    //dealProduct.Allocation_Override__c = x.allocationOverride;
                    dealProduct.Manually_Schedule__c = x.isManuallySchedule;
                    if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                        dealProduct.Replen_Delay_Days__c = x.replenDelayDays;
                    } else {
                        dealProduct.Replen_Delay_Days__c = 0;
                    }
                    dealProduct.P_L_Quantity__c = x.plQuantity;
                    dealProduct.P_L_Decay_Curve_Template__c = x.plDecayCurveTemplate;
                    //Japan - DEF#3926
                    dealProduct.Override_Pricing__c = x.overrideRentalPrices;
                    if (isJPForRental && x.overrideRentalPrices) {
                        dealProduct.Handling_Fee__c = x.handlingFee;
                        dealProduct.Rental_Price__c = x.rentalPrice;
                        dealProduct.Revenue_Share__c = x.revenueShare;
                        dealProduct.Number_of_Rentals_per_Unit__c = x.numberOfRentals;
                        dealProduct.Final_Purchase_Price__c = x.finalPurchasePrice;
                        dealProduct.Final_Purchase__c = x.finalPurchase;
                    }
                    //US #581: Populate Consignment Multiplier on Deal Product
                    dealProduct.Consignment_Multiplier__c = x.consignmentMultiplier;
                    
                    // Added for Germany US #283
                    dealProduct.Gema__c = x.gema;
                    dealProduct.Doubtful_Accounts__c = x.doubtfulAccounts;
                    dealProduct.Gross_receipt_taxes_FFA__c = x.grossReceiptTaxesFFA;
                    dealProduct.Cash_Discounts__c = x.cashDiscounts;
                    lstDealProducttoUpsert.add(dealProduct);
                    
                } 
            }
        }
        
        System.debug('@#@#@#@# Before Break');
        
        // Commit changes
        Savepoint sp = Database.setSavepoint();
        try{
            //system.debug('lstDealProducttoDelete -------->'+lstDealProducttoDelete);
            if(lstDealProducttoDelete != null && !lstDealProducttoDelete.isEmpty()){
                delete lstDealProducttoDelete;
            }
            /*system.debug('lstDealProductScheduleToDelete -------->'+lstDealProductScheduleToDelete);
            if(lstDealProductScheduleToDelete != null && !lstDealProductScheduleToDelete.isEmpty()){
                delete lstDealProductScheduleToDelete;
            }*/
            //system.debug('lstDealProducttoUpsert -------->'+lstDealProducttoUpsert);
            if(lstDealProducttoUpsert != null && !lstDealProducttoUpsert.isEmpty()){
                update lstDealProducttoUpsert;
                //Defect: #3736 - Edit IQ and RQ for committed deals using La moulinette.
                List<Opportunity> lstDeal = [Select Id from Opportunity Where Id =: lstDealProducttoUpsert[0].OpportunityId AND isChangedHLF__c = true];
                if (lstDeal.size() > 0 && !lstDeal.isEmpty()) {
                    lstDeal[0].isChangedHLF__c = False;
                    update lstDeal;
                }
            }
            /*system.debug('lstDealProductScheduleToInsert -------->'+lstDealProductScheduleToInsert);
            // If Manually Schedule = true, insert the scedules using future callout so that discount can be modified
            if(lstDealProductScheduleToInsert != null && !lstDealProductScheduleToInsert.isEmpty()){
                insertFutureManualSchedules(JSON.serialize(lstDealProductScheduleToInsert));
            }*/
        }catch(System.DMLException e){
           for (Integer i = 0; i < e.getNumDml(); i++) {
                Database.rollback(sp);
                System.debug('!@!@!@!@!@ getMessage: ' + e.getMessage());
                // Process exception here                
                throw new CRM_EditProductsException(e.getDmlMessage(i));
            }
        }catch(Exception e){
            Database.rollback(sp);
            System.debug('!@!@!@!@!@ getMessage: ' + e.getMessage());
            throw new CRM_EditProductsException(e.getMessage());
            
        }
        system.debug('quickSave ---------'+quickSave);
        if(quickSave){
            system.debug('lineItemIds ------------->'+lineItemIds);
        
            return getLineItems(opportunityId,lineItemIds);
        }else{
            //return null;
            return getLineItems(opportunityId,lineItemIds);
        }
    }

    /**
     * Method to insert Manually entered Schedules using future callout so that we can modify the discount
     * @name insertFutureManualSchedules
     * @param String schedulesToInsertJSON JSON string containing the list of schedules
     * @return None
     
    @future
    public static void insertFutureManualSchedules(String schedulesToInsertJSON) {
        List<FutureSchedulesWrapper> scheduleWrapperList =
            (List<FutureSchedulesWrapper>) JSON.deserialize(schedulesToInsertJSON, List<FutureSchedulesWrapper>.class);
        List<OpportunityLineItemSchedule> insertScheduleList = new List<OpportunityLineItemSchedule>();

        for (FutureSchedulesWrapper scheduleWrapperInstance : scheduleWrapperList) {
            insertScheduleList.add(scheduleWrapperInstance.schedule);
        }

        if (insertScheduleList != null && !insertScheduleList.isEmpty()) {
            insert insertScheduleList;
        }
    }

    private class FutureSchedulesWrapper {
        OpportunityLineItemSchedule schedule;
    }
    */

    /**
     *  Method to convert Date datatype into String datatype
     *  @name convertDateToString
     *  @param Date dt
     *  @return String
     *  @throws None
     */
    
    public static String convertDateToString(Date dt) {
        if(dt != null) {
            //return (Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0))).format('MM/dd/yyyy');
            return dt.format();
        }       
        return null;
    }
    /**
     *  This method returns list of Deal Products for particular UPC / Material Number
     *  @name addLineItems
     *  @param Id opportunityId, CRM_DataObjects.SearchFilters filters
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    @RemoteAction
    static global CRM_DataObjects.ProductToEdit[] addLineItems(Id opportunityId, CRM_DataObjects.SearchFilters filters) {
        List<CRM_DataObjects.ProductItem> lstProductItems = new List<CRM_DataObjects.ProductItem>();
        // Get all current products
        List<Opportunity> lstDeals = [Select id, Pricebook2Id , Start_Date__c, Account.Revenue_share__c ,Account.Sales_Organization__c,AccountId, CurrencyIsoCode, Bundle__c,CloseDate,Market_Type__c,
                            Account.Price_Book__r.Country__c,//Defect#4461 - added account.pricebook.contry field in query
                            (SELECT PricebookEntryId, Quantity, Discount, Customer_Retail_Price__c, UnitPrice, Initial_Quantity__c FROM OpportunityLineItems) 
                            from Opportunity 
                            where Id =:opportunityId limit 1];
        //Run through list of records to update and track the upsert records
        List<OpportunityLineItem> lstDealProducttoUpsert = new List<OpportunityLineItem>();
        if(!lstDeals.isEmpty()){
            //Build a map for OpportunityLineItem with PriceBookEntryId as key
            Map<Id, OpportunityLineItem> mapCurrentDealProducts = new Map<Id, OpportunityLineItem>();
            for (OpportunityLineItem x : lstDeals[0].OpportunityLineItems) {
                mapCurrentDealProducts.put(x.PricebookEntryId, x);
            }
            lstProductItems = searchProductForDealorOrder(lstDeals, filters);
            if(lstProductItems.isEmpty()){
                throw new CRM_EditProductsException(Label.CRM_No_Product_found_label);
            }
            for (CRM_DataObjects.ProductItem x: lstProductItems) {
                if (mapCurrentDealProducts.containsKey(x.pricebookEntryId)) {
                    throw new CRM_EditProductsException(Label.CRM_Product_already_found_label);
                }
                else{
                    x.listPrice = x.listPrice == null ? 0 : x.listPrice;
                    // New product to add
                    lstDealProducttoUpsert.add(new OpportunityLineItem(
                        OpportunityId = opportunityId,
                        PricebookEntryId = x.pricebookEntryId,
                        Quantity = 1,
                        UnitPrice = x.listPrice,
                        listPrice__c = x.listPrice,
                        discount = 0
                    ));
                }
            }
            // Commit changes
            Savepoint sp = Database.setSavepoint();
            try{
                if(lstDealProducttoUpsert != null && !lstDealProducttoUpsert.isEmpty()){
                    upsert lstDealProducttoUpsert;
                }
            }catch(System.DMLException e){
               for (Integer i = 0; i < e.getNumDml(); i++) {
                    Database.rollback(sp);
                    // Process exception here
                    throw new CRM_EditProductsException(e.getDmlMessage(i));
                }
            }catch(Exception e){
                Database.rollback(sp);
                throw new CRM_EditProductsException(e.getMessage());
            }
        }
        return getLineItems(opportunityId,null);
    }
    static List<CRM_DataObjects.ProductItem> searchProductForDealorOrder(List<Opportunity> lstDeals, CRM_DataObjects.SearchFilters filters){
        List<CRM_DataObjects.ProductItem> lstProductItemsFetched = new List<CRM_DataObjects.ProductItem>();
        List<CRM_DataObjects.ProductItem> lstProductItemsMatched = new List<CRM_DataObjects.ProductItem>();
        CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
            dealOrOrder.currencyCode = lstDeals[0].CurrencyIsoCode;
            dealOrOrder.startDate = lstDeals[0].Start_Date__c;
            dealOrOrder.bundleId = lstDeals[0].Bundle__c;
            dealOrOrder.accountId = lstDeals[0].AccountId;
            dealOrOrder.endDate = lstDeals[0].CloseDate;
            // DEF#4143 : Moved filtering code from controller to AddProductsHelper
            dealOrOrder.recordType = CRM_AppConstants.OPPORTUNITY_OBJECT;
            dealOrOrder.dealRecord = lstDeals[0];

            filters.fullMatchMaterialNumber = true;
            lstProductItemsFetched = CRM_AddProductsHelper.searchProducts(dealOrOrder, lstDeals[0].Pricebook2Id, filters);
            System.debug('lstProductItemsFetched-->'+lstProductItemsFetched);
            for(CRM_DataObjects.ProductItem productItem :lstProductItemsFetched){
                if(productItem.universalProductCode == filters.materialNumber ){
                    lstProductItemsMatched.add(productItem);
                    System.debug('lstProductItemsMatched1111-->'+lstProductItemsMatched);
                }else if(productItem.externalId == productItem.salesOrg +'-'+ productItem.distriButionChannel +'-'+ filters.materialNumber){
                    lstProductItemsMatched.add(productItem);
                    System.debug('lstProductItemsMatched2222-->'+lstProductItemsMatched);
                }
            }
         System.debug('lstProductItemsMatched-->'+lstProductItemsMatched);
         return lstProductItemsMatched;
    }
    /**
     *  This method updates list of Deal with new High Level Forecast - France
     *  @name addLineItems
     *  @param Id opportunityId, Double highLevelForecast
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    @RemoteAction
    static global void updateDeal(Id opportunityId, Double highLevelForecast) {
        List<CRM_DataObjects.ProductItem> lstProductItems = new List<CRM_DataObjects.ProductItem>();
        // Get all current products
        List<Opportunity> lstDeals = [Select id, StageName, Pricebook2Id , Start_Date__c, AccountId, CurrencyIsoCode, Bundle__c, CloseDate, High_Level_Forecast__c, isChangedHLF__c,
                            (SELECT PricebookEntryId, Quantity, Discount, Customer_Retail_Price__c, UnitPrice, Initial_Quantity__c FROM OpportunityLineItems) 
                            from Opportunity 
                            where Id =:opportunityId limit 1];
        //Run through list of records to update and track the upsert records
       // List<Opportunity> lstDealtoUpsert = new List<Opportunity>();
        if(!lstDeals.isEmpty()){
            lstDeals[0].High_Level_Forecast__c = highLevelForecast;
            //Defect: #3736 - Edit IQ and RQ for committed deals using La moulinette.
            //Flag(True) to bypass VR.
            if (lstDeals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                lstDeals[0].isChangedHLF__c = True;
            }
            // Commit changes
            Savepoint sp = Database.setSavepoint();
            try{
                if(lstDeals != null && !lstDeals.isEmpty()){
                    System.debug('lstDeals-->'+lstDeals);
                    update lstDeals;
                }
            }catch(System.DMLException e){
               for (Integer i = 0; i < e.getNumDml(); i++) {
                    Database.rollback(sp);
                    // Process exception here
                    throw new CRM_EditProductsException(e.getDmlMessage(i));
                }
            }catch(Exception e){
                Database.rollback(sp);
                throw new CRM_EditProductsException(e.getMessage());
            }
        }
        //return getLineItems(opportunityId);
    }
    public class CRM_EditProductsException extends Exception {
    }
    
    // Japan US #483 
    /*private static Map<String, Account_Plan__c> getAccountPlans(Set<String> dealProdAcctIdSet){
        List<Account_Plan__c> lstAccountPlan;
        Map<String, Account_Plan__c> mapDealProdAccPlanId = new Map<String, Account_Plan__c>();
        
        lstAccountPlan = [SELECT Id,Handling_Fee__c,Customer__c,Final_Purchase_Price__c,Final_Purchase__c,Rental_Price__c,Revenue_Share__c,
                                 Number_of_Rentals_per_Unit__c,Account_Product_Id__c,Decay_Curve_Template__r.Name 
                          FROM Account_Plan__c 
                          WHERE Account_Product_Id__c IN :dealProdAcctIdSet];
        for(Account_Plan__c accPlan :lstAccountPlan){
            mapDealProdAccPlanId.put(accPlan.Account_Product_Id__c, accPlan);
        }
        
        return mapDealProdAccPlanId;
    }*/
}