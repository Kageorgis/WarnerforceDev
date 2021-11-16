/**
   @Author Cognizant (Dilip Mistry)
   @name CRM_PublishAssortmentsController
   @CreateDate 10 Aug 2016
   @Description Helper class for Assortment Publish Logic
   @Version <1.0>
*/
public without sharing class CRM_PublishAssortmentHelper {
    
    public static final Integer PUBLISH_BATCH_SIZE = getPublishAssortmentBatchSize();
    
    public static Integer getPublishAssortmentBatchSize() {
        Integer DEFAULT_BATCH_SIZE = 50;
        CRM_Batch_Size__c publishAssortmentInstance = CRM_Batch_Size__c.getInstance('Publish Assortment Batch');
        
        return publishAssortmentInstance != null ?  (Integer) publishAssortmentInstance.Batch_Size__c : DEFAULT_BATCH_SIZE;
    }
    
    public static void publishAssortment(Id assortmentId) {
        Map<Id,Bundle__c> mapAssortments = getAssortmentMap(assortmentId);
        
        if(!mapAssortments.isEmpty()) {
            Bundle__c assortment = mapAssortments.values().get(0);
            //If the Batch is running then it won't RUN again.
            if(!assortment.Publish_In_Progress__c){
                
                validateAssortment(assortment);
                
                assortment.Publish_In_Progress__c = true;
                update assortment;
                                   
                Map<Id, Opportunity> allCancelDealsMap = getSAPDealsForCancellation(assortmentId);
                if(allCancelDealsMap.size() > 0 && isPromotionalAssortment(assortment)){
                     // Publish assortment to Cancel SAP Deal
                    CRM_BatchPublishAssortmentCancelSAPDeals batchPublishAssortmentCancelSAPDeals = new CRM_BatchPublishAssortmentCancelSAPDeals();
                    batchPublishAssortmentCancelSAPDeals.assortment = assortment;
                    batchPublishAssortmentCancelSAPDeals.cancelDealMap = allCancelDealsMap;
                    Database.executeBatch(batchPublishAssortmentCancelSAPDeals, PUBLISH_BATCH_SIZE);
                }else{
                    // publish assortment once its validated
                    CRM_BatchPublishAssortmentDeals batchProcessDeals = new CRM_BatchPublishAssortmentDeals();
                    batchProcessDeals.assortment = assortment;
                    Database.executeBatch(batchProcessDeals, PUBLISH_BATCH_SIZE);
                }
            }
            else{
                throw new CRM_CustomException(Label.CRM_Generate_Update_Deal_is_already_in_progress);   
            }  
        }
    }
    
    /* HELPER METHODS */
    public static void validateAssortment(Bundle__c assortment) {
        if(CRM_Functional_Permissions__c.getInstance().Revoke_Publish_Assortment__c == true ) {
            throw new CRM_CustomException(Label.CRM_PublishAssortment_Msg_InvalidAccess);
        }
        
        if(assortment.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_CANCELLED) {
            throw new CRM_CustomException(Label.CRM_PublishAssortment_Msg_InvalidStatus);
        }
        // Throw error of share% is not equals to 0 or 100%
        if(assortment.Product_Share__c != 100 && assortment.Product_Share__c != 0) { // Defect #4130: Removed - && isPromotionalAssortment(assortment)
            throw new CRM_CustomException(Label.CRM_Assortment_Product_Share_Percent_should_be_100_or_0);
        }
        if(assortment.Account_Count__c == null || assortment.Account_Count__c == 0 ) {
            throw new CRM_CustomException(System.Label.CRM_PublishAssortment_Msg_NoAssortmentAccount);
        }
    }
    
    public static Map<Id,Bundle__c> getAssortmentMap(Id assortmentId) {
        Map<Id,Bundle__c> mapAssortments = new Map<Id,Bundle__c>( [Select Id, Name, Campaign_Type__c, Account_Count__c, Product_Count__c, Replen__c,Product_Share__c, Assortment_Status__c, Start_Date__c, End_Date__c, Promo_Start_Date__c, Promo_End_Date__c,OwnerId,Decay_Curve_Template__c,
                    RecordTypeId, Target_Revenue__c, High_Level_Target__c, Last_Published_Date__c, Price_Book__c, Price_Book__r.Product_Type__c, Pricing_Account__c, Pricing_Account__r.Owner_Games__c, Pricing_Account__r.Id, Pricing_Account__r.Name, Pricing_Account__r.AccountNumber, Pricing_Account__r.OwnerId, CurrencyISOCode, Publish_In_Progress__c,
                    Pricing_Method__c, Automatic_Product_Count__c, No_Demand__c, No_Pricing__c,RecordType.DeveloperName, 
                    //US#958 - added fields Couponing_Discount__c,Couponing_Redemption_Rate__c
                    Couponing_Discount__c,Couponing_Redemption_Rate__c,
                    (select Id, Account__c, Account__r.Name, Account__r.Digital_Country_Code__c, Account__r.Video_Digital__c, Account__r.Sales_Organization__c,SAP_Sales_Org__c, Account__r.AccountNumber, Account__r.Owner_Games__c, Account__r.OwnerId, Account__r.Price_Book__c, Assortment__c, High_Level_Target__c, Share__c,Account_Number__c from Assortment_Accounts__r order by Account__c),
                    (select Id, Automatically_Add_Product__c, Bundle__c, Assortment_Price__c, List_Price__c, Product__c, Product__r.SAP_Material_Type__c, Share__c,Product__r.ProductCode, Product__r.Name from Bundle_Products__r order by Product__c),
                    (select Id, Name, Assortment__c, POS_Type__c from POS_Forecasts__r )
                    From Bundle__c
                    where Id = : assortmentId ]);
        
        return mapAssortments;
    }
    
    /**
     *  @name - createDealRecord
     *  @Description - method to create a deal for the provided assortment and assortment account
     *  @param - assortment - assortment used for deal creation
     *  @param - assortmentAccount - account for which deal is required to be created
     *  @return - Opportunity - Newly created deal (Opportunity) record.
     **/
    public static Opportunity createDealRecord(Bundle__c assortment, Assortment_Account__c assortmentAccount, Boolean hasFERTProds) {
        Opportunity opp = new Opportunity();
        opp.UniquePublishKey__c = assortment.Id+'-'+assortmentAccount.Account__c;
        
        if(isPromotionalAssortment(assortment)){
            // Deal Record Type to be “High Level” if assortment has no FERTs when generating it. 
            //Update the record type to physical deal once FERTs are added.
            opp.RecordTypeId = (hasFERTProds ? CRM_RecordTypeUtil.RT_DEAL_PHYSICAL : CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL);
            
            String dealStage = (assortment.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED ? CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED : CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED);
            opp.StageName = dealStage;
        }
        else{
            /*opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;
            opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            if(assortmentAccount.Share__c != null && assortment.Target_Revenue__c != null){
                opp.High_Level_Target_Revenue__c = (assortmentAccount.Share__c * assortment.Target_Revenue__c) / 100;
            }
            else{
                opp.High_Level_Target_Revenue__c = 0;
            }*/
            // Req#609 : Create Physical Deal if Products present else create High Level deal for Promotional Assortments
            if (assortment.Automatic_Product_Count__c > 0) {

                // US#786 : To create digital deal for digital accounts
                if(CRM_ApplicationUtility.isDigitalAssortment(assortment)) 
                    opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                else
                    opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                        
                opp.No_Demand__c = assortment.No_Demand__c != null ? assortment.No_Demand__c : false;
                opp.No_Pricing__c = assortment.No_Pricing__c != null ? assortment.No_Pricing__c : false;
                // DEF#4168 : Priority on Deals generated from an Assortment should default to 'Normal'
                if (opp.Deal_Priority__c == null || opp.Deal_Priority__c == '') {
                    opp.Deal_Priority__c = CRM_AppConstants.OPPORTUNITY_DEAL_PRIORITY_NORMAL;
                }

                if (CRM_AppConstants.GERMANY_SALES_ORGS.contains(assortmentAccount.SAP_Sales_Org__c)) { //assortmentAccount.Account__r.Sales_Organization__c
                    opp.Customer_Delivery_Date__c = assortment.Start_Date__c;
                }
            } else {
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;
            }

            opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            if(assortmentAccount.Share__c != null && assortment.Target_Revenue__c != null){
                opp.High_Level_Target_Revenue__c = (assortmentAccount.Share__c * assortment.Target_Revenue__c) / 100;
            }
            else{
                opp.High_Level_Target_Revenue__c = 0;
            }
        }
        
        opp.Name =  assortment.Name +' - '+ assortmentAccount.Account__r.Name; 
        opp.Promo_Start_Date__c = assortment.Promo_Start_Date__c;
        opp.Promo_End_Date__c = assortment.Promo_End_Date__c;
        opp.Start_Date__c = assortment.Start_Date__c;
        opp.CloseDate = assortment.End_Date__c;
        opp.AccountId = assortmentAccount.Account__c;
        if(CRM_ApplicationUtility.isDigitalAssortment(assortment)) 
            opp.Pricebook2Id = assortmentAccount.Account__r.Price_Book__c;
        else
            opp.Pricebook2Id = assortment.Price_Book__c;  
        // DEF#4688
        if (assortmentAccount.Account__r.Owner_Games__c != null) {
            opp.OwnerId = assortmentAccount.Account__r.Owner_Games__c;
        } else {
            opp.OwnerId = assortmentAccount.Account__r.OwnerId;
        }
        opp.Bundle__c = assortment.Id;
        opp.Assortment_Account__c = assortmentAccount.Id;
        opp.High_Level_Target__c = assortmentAccount.High_Level_Target__c;
        opp.CurrencyISOCode = assortment.CurrencyISOCode;
        opp.Last_Published_Date__c = System.now();
        opp.Replen__c = assortment.Replen__c;
        
        return opp; 
    }
    
    /**
     *  @name - createDealProductRecord
     *  @Description - method to create a deal product record with information from Assortment(Bundle), Assortment_Product and Assortment_Account
     *  @param - assortment - assortment to be used for pricebook and promo/pricing dates information
     *  @param - assortmentAccount - account for which deal product will be linked
     *  @param - assortmentProduct - product to be added as deal product  
     *  @param - mapPBEntries - map of PricebookEntries to be used for linking product to a deal
     *  @return - OpportunityLineItem - Newly created deal product (OpportunityLineItem) record.
     **/
    public static OpportunityLineItem createDealProductRecord(Opportunity deal, Bundle__c assortment, Assortment_Account__c assortmentAccount, Bundle_Product__c assortmentProduct, Map<String,PricebookEntry> mapPBEntries) {
        String pbeUniqueKey = null;

        //US#958 - fetched custom setting datd to prefill return cost for FR
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
        
        if(! CRM_ApplicationUtility.isDigitalAssortment(assortment))
            pbeUniqueKey = assortment.Price_Book__c +'-'+ assortmentProduct.Product__c +'-'+ assortment.CurrencyISOCode;
        else
            pbeUniqueKey = deal.Pricebook2Id +'-'+ assortmentProduct.Product__c +'-'+ assortment.CurrencyISOCode;
                
        if(mapPBEntries.get(pbeUniqueKey) != null) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Decay_Curve_Template__c = assortment.Decay_Curve_Template__c;
            oli.UniquePublishKey__c = assortment.Id+'-'+assortmentAccount.Account__c+'-'+assortmentProduct.Product__c;
            oli.PricebookEntryId = mapPBEntries.get(pbeUniqueKey).Id;
        
            // Req#609 : Set Prices for Promotional Assortments based on Pricing Modes
            if (!isPromotionalAssortment(assortment)) {
                if (assortment.Pricing_Method__c == CRM_AppConstants.ASSORTMENT_PRICING_MODE_NET_PRICE) {
                    if(CRM_ApplicationUtility.isDigitalAssortment(assortment))
                        oli.ListPrice__c = assortmentProduct.List_Price__c;
                    oli.Account_Price__c = assortmentProduct.Assortment_Price__c;
                    oli.Promoted_Price__c = oli.Account_Price__c;
                    //oli.UnitPrice = oli.Account_Price__c;
                } else {
                    oli.ListPrice__c = assortmentProduct.Assortment_Price__c != null ? assortmentProduct.Assortment_Price__c : 0;
                    //oli.UnitPrice = oli.ListPrice__c;
                }
            } else {
                oli.ListPrice__c = (assortmentProduct.Assortment_Price__c != null ? assortmentProduct.Assortment_Price__c : assortmentProduct.List_Price__c) ;
                //oli.Account_Price__c = assortmentProduct.Assortment_Price__c;
                //oli.Promoted_Price__c = (oli.Account_Price__c != null ? oli.Account_Price__c : oli.ListPrice__c);
                oli.UnitPrice = assortmentProduct.List_Price__c;
            }
            oli.Share__c = assortmentProduct.Share__c;
        
            Decimal totalQuantity = (assortmentAccount.Share__c != null ? assortmentAccount.Share__c : 0)  
                    * (assortmentProduct.Share__c != null ? assortmentProduct.Share__c : 0) 
                    *(assortment.High_Level_Target__c != null ? assortment.High_Level_Target__c : 0) / (100*100);
        
            totalQuantity = Math.round(totalQuantity);
        
            // US#787 : To populate Replen Quantity for Digital Assortments
            if(CRM_ApplicationUtility.isDigitalAssortment(assortment)) {
                oli.Replen_Quantity__c = totalQuantity;
                //oli.Replen_Quantity__c = oli.Replen_Quantity__c == 0 ? 1 : oli.Replen_Quantity__c;
                oli.Published_Quantity__c = oli.Replen_Quantity__c;
                oli.Quantity = oli.Replen_Quantity__c == 0 ? 1 : oli.Replen_Quantity__c;
            } else {
                // US#936 : US Games
                if (CRM_AppConstants.US_SALES_ORGS.contains(assortmentAccount.SAP_Sales_Org__c)) {
                    oli.Initial_Quantity__c = 0;
                    oli.Replen_Quantity__c = 0;
                    oli.Target_Quantity__c = totalQuantity;
                } else {
                    oli.Initial_Quantity__c = (assortment.Replen__c!= null ? Math.round(totalQuantity * (1-assortment.Replen__c/100)) : totalQuantity);
                    oli.Replen_Quantity__c = (assortment.Replen__c!= null ? Math.round(totalQuantity * (assortment.Replen__c/100)) : 0) ;
                }
                //oli.Initial_Quantity__c = oli.Initial_Quantity__c == 0 ? 1 : oli.Initial_Quantity__c;
                oli.Published_Quantity__c = oli.Initial_Quantity__c + oli.Replen_Quantity__c;
                oli.Quantity = (oli.Initial_Quantity__c + oli.Replen_Quantity__c) == 0 ? 1 : oli.Initial_Quantity__c + oli.Replen_Quantity__c;
            }

            oli.Last_Published_Date__c = System.now();
            system.debug('&&&&'+isPromotionalAssortment(assortment));
            //US#958 - copy values for couponing discount and redumption rate from assortment to calculate GRLR
            if(isPromotionalAssortment(assortment)){
                system.debug('inside cvampiang');
                oli.Bundle_Couponing_Discount__c = assortment.Couponing_Discount__c;
                oli.Bundle_Couponing_Redemption_Rate__c = assortment.Couponing_Redemption_Rate__c;
                oli.Return_Cost__c = defaultConfiguration.CRM_Default_Return_Cost_FR__c;
            }
            //US#958 - end
            return oli;
         }
         return null;
    }
    
    
    /**
     *  @name - upsertPOSForecastItems
     *  @Description - method to publish(insert/update) POSF Items for the given assortment
     *  @param - mapPublishedDeals - map of deals which have been already published by the logic above
     *  @param - mapAssortments - map of assortment record along with its child records
     *  @return - none
     **/
    public static Map<String,POS_Forecast_Item__c> createPOSForecastItems(Bundle__c assortment, Map<String,Opportunity> mapPublishedDeals) {
        Map<String,POS_Forecast_Item__c> mapPublishedForecastItems = new Map<String,POS_Forecast_Item__c>();
        Bundle__c relatedAssortment =  assortment;
        
        for(Opportunity deal : mapPublishedDeals.values()) {
            system.debug('deal--->'+deal);
            if(relatedAssortment != null && !relatedAssortment.POS_Forecasts__r.isEmpty()) {
                for(POS_Forecast__c forecast : relatedAssortment.POS_Forecasts__r) {
                    system.debug('forecast--->'+forecast);
                    POS_Forecast_Item__c forecastItem = createPOSForecastItemRecord(deal, forecast);
                    
                    mapPublishedForecastItems.put(forecastItem.UniquePublishKey__c, forecastItem);
                }
            }
        }
        
        // Update record ids for existing POS_Forecast_Item records
        for(POS_Forecast_Item__c forecastItem : [Select Id, UniquePublishKey__c from POS_Forecast_Item__c where UniquePublishKey__c IN: mapPublishedForecastItems.keyset()]) {
            if(mapPublishedForecastItems.containsKey(forecastItem.UniquePublishKey__c)) {
                mapPublishedForecastItems.get(forecastItem.UniquePublishKey__c).Id = forecastItem.Id;
            }
        }
        
        return mapPublishedForecastItems;
    }
    
    /**
     *  @name - createPOSForecastItemRecord
     *  @Description - method to create POS_Forecast_Item__c with the given deal and POSF record.
     *  @param - deal - Deal to which POSF Item should be added
     *  @param - forecast - Parent POS_Forecast record for POSF item
     *  @return - POS_Forecast_Item__c - Newly created POS_Forecast_Item__c record.
     **/
    public static POS_Forecast_Item__c createPOSForecastItemRecord(Opportunity deal, POS_Forecast__c forecast) {
        
        String publishKey = deal.Bundle__c +'-'+ deal.AccountId +'-'+ forecast.Id;
        
        POS_Forecast_Item__c forecastItemRec = new POS_Forecast_Item__c();
        forecastItemRec.Deal__c = deal.Id;
        forecastItemRec.Deal__r = deal;
        forecastItemRec.POS_Forecast__c = forecast.Id;
        forecastItemRec.POS_Forecast__r = forecast;
        forecastItemRec.UniquePublishKey__c = publishKey;
        
        return forecastItemRec;
    }
    
    /**
     *  @name - getPricebookEntries
     *  @Description - method to get the PricebookEntry data so that assortment products can be linked as deal products where 
     *                  PricebookEntryId is a mandatory field to be populated
     *  @param - assortments - list of assortment for which pricebook entry records to be retrieved from system
     *  @return - Map<String,PricebookEntry> - map of PricebookEntry records with combination of "Pricebook-Product-Currency" as key
     **/
    public static Map<String,PricebookEntry> getPricebookEntries(Bundle__c[] assortments) {
        Set<String> setCurrencyCodes = new Set<String>();
        Set<Id> setPricebookIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        
        Map<String,PricebookEntry> mapPricebookEntries = new Map<String,PricebookEntry>();
        
        for(Bundle__c  assortment : assortments) {
            setCurrencyCodes.add(assortment.CurrencyISOCode);
            setPricebookIds.add(assortment.Price_Book__c);
            
            for(Bundle_Product__c assrtProd : assortment.Bundle_Products__r) {
                setProductIds.add(assrtProd.Product__c);
            }
        }
        
        for(PricebookEntry pbe : [select Id, CurrencyISOCode, Product2Id, Product2.Name, Product2.ProductCode, Pricebook2Id  from PricebookEntry 
                where Pricebook2Id IN: setPricebookIds and Product2Id IN :setProductIds and CurrencyISOCode IN: setCurrencyCodes ]) {
            
            String mapUniqueKey = pbe.Pricebook2Id +'-'+ pbe.Product2Id +'-'+ pbe.CurrencyISOCode;
            mapPricebookEntries.put(mapUniqueKey, pbe);
        }
        
        return mapPricebookEntries;
    }
    
    /**
     *  @name - getPricebookEntries
     *  @Description - method to get the PricebookEntry data so that assortment products can be linked as deal products where 
     *                  PricebookEntryId is a mandatory field to be populated
     *  @param - assortments - list of assortment for which pricebook entry records to be retrieved from system
     *  @param - deals - list of published deals for which pricebook entry records to be retrieved from system
     *  @return - Map<String,PricebookEntry> - map of PricebookEntry records with combination of "Pricebook-Product-Currency" as key
     **/
    public static Map<String,PricebookEntry> getPricebookEntries(Bundle__c[] assortments, Opportunity[] publishedDeals) {
        Set<String> setCurrencyCodes = new Set<String>();
        Set<Id> setPricebookIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        
        Map<String,PricebookEntry> mapPricebookEntries = new Map<String,PricebookEntry>();
        
        for(Bundle__c  assortment : assortments) {
            setCurrencyCodes.add(assortment.CurrencyISOCode);
            for(Bundle_Product__c assrtProd : assortment.Bundle_Products__r) {
                setProductIds.add(assrtProd.Product__c);
            }
        }
        
        for(Opportunity  deal : publishedDeals) {
            setPricebookIds.add(deal.Pricebook2Id);
        }
        
        for(PricebookEntry pbe : [select Id, CurrencyISOCode, Product2Id, Product2.Name, Product2.ProductCode, Pricebook2Id  from PricebookEntry 
                where Pricebook2Id IN: setPricebookIds and Product2Id IN :setProductIds and CurrencyISOCode IN: setCurrencyCodes ]) {
            
            String mapUniqueKey = pbe.Pricebook2Id +'-'+ pbe.Product2Id +'-'+ pbe.CurrencyISOCode;
            mapPricebookEntries.put(mapUniqueKey, pbe);
        }
        
        return mapPricebookEntries;
    }
    
    public static Map<String,Opportunity> queryPublishedDealRecords(Bundle__c assortment) {
        Map<String,Opportunity> mapPublishedDeals = new Map<String,Opportunity>(); 
        Assortment_Account__c[] listAllAssortmentAccounts = assortment.Assortment_Accounts__r;
            
        // Publish the assortment with Pricing Account Details (Create a new Deal/Deal_Products for this pricing accounts as well)
        if(assortment.Pricing_Account__c != null) {
            listAllAssortmentAccounts.add( new Assortment_Account__c(
                    Account__c = assortment.Pricing_Account__c,
                    Account__r = assortment.Pricing_Account__r,
                    Assortment__c = assortment.Id
                )
            );
        }
        
        // PREPARE LIST OF DEAL PRODUCTS TO CREATE/UPDATE 
        if(!assortment.Bundle_Products__r.isEmpty()) {
            
            for(Assortment_Account__c assrtAcc : listAllAssortmentAccounts) {
                String uniqueDealKey = assrtAcc.Assortment__c + '-' +  assrtAcc.Account__c; 
                mapPublishedDeals.put(uniqueDealKey, null);
            }
            
            for(Opportunity opp : [select Id, Bundle__c, Bundle__r.RecordTypeId,Start_Date__c, RecordTypeId, CloseDate, CurrencyISOCode, Assortment_Account__c, Assortment_Account__r.Id, Assortment_Account__r.Account__c, Assortment_Account__r.Account_Number__c,Assortment_Account__r.Account__r.Name, //Add Account Name Field in Publish Error message
                    Assortment_Account__r.Share__c, TotalOpportunityQuantity, Replen__c, High_Level_Target__c, 
                    StageName, Hidden_Estimated_Quantity__c, UniquePublishKey__c, AccountId, Pricebook2Id
                    from Opportunity where UniquePublishKey__c IN: mapPublishedDeals.keySet()]
            ) {
                // Req#609 : Remove committed / awaiting Approval deals from deal products being updated
                if (
                        opp.Bundle__c != null && !isPromotionalAssortment(assortment) &&
                        (
                            opp.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED ||
                            opp.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL
                        )
                ) {
                   continue;
                } else {
                mapPublishedDeals.put(opp.UniquePublishKey__c, opp);
                }
            }
        }
        
        return mapPublishedDeals;
    }
    
    /**
     *  @name - removeNonwritableFields
     *  @Description - method to remove the non-writable fields like OpportunityId and PricebookEntryId when an existing deal product is updated
     *  @param - mapOLIs - map of opportunitylineitems where key is UniquePublishKey__c
     *  @return - void
     **/
    public static void removeNonwritableFields(Map<String,OpportunityLineItem> mapOLIs, Bundle__c assortment) {
        for(String oliPublishKey : mapOLIs.keySet()) {
            OpportunityLineItem lineItem = mapOLIs.get(oliPublishKey);
            
            if(lineItem.Id != null) {
                OpportunityLineItem oliToUpdate = new OpportunityLineItem(Id=lineItem.Id);
                oliToUpdate.UniquePublishKey__c = lineItem.UniquePublishKey__c;
                oliToUpdate.ListPrice__c = lineItem.ListPrice__c;
                oliToUpdate.UnitPrice = lineItem.UnitPrice;
                if (!isPromotionalAssortment(assortment)) {
                    oliToUpdate.Account_Price__c = lineItem.Account_Price__c;
                }
                oliToUpdate.Promoted_Price__c = lineItem.Promoted_Price__c;
                oliToUpdate.Initial_Quantity__c = lineItem.Initial_Quantity__c;
                oliToUpdate.Replen_Quantity__c = lineItem.Replen_Quantity__c;
                oliToUpdate.Published_Quantity__c = lineItem.Published_Quantity__c;
                oliToUpdate.Target_Quantity__c = lineItem.Target_Quantity__c;
                //oliToUpdate.Quantity = lineItem.Quantity;
                oliToUpdate.Last_Published_Date__c = lineItem.Last_Published_Date__c;
                oliToUpdate.Share__c = lineItem.Share__c;
                oliToUpdate.Decay_Curve_Template__c = lineItem.Decay_Curve_Template__c;
                //Non-Writable Fields (OpportunityId and PricebookEntryId)
                //oliToUpdate.PricebookEntryId = mapPBEntries.get(pbeUniqueKey).Id;         
                
                //US#958 - added code to update fields from assortment to DP.
                oliToUpdate.Bundle_Couponing_Discount__c = assortment.Couponing_Discount__c;
                oliToUpdate.Bundle_Couponing_Redemption_Rate__c = assortment.Couponing_Redemption_Rate__c;
                //US#958 -end
                
                //--CPU Time Limit--RTC--Start--//
                oliToUpdate.Invalid_Deal_Product__c = lineItem.Invalid_Deal_Product__c;
                //--CPU Time Limit--RTC--End--//
                mapOLIs.put(oliPublishKey, oliToUpdate);
            }
        }
    }
    
    /**
     *  @name - hasFERTProducts
     *  @Description - method to find if there are any FERT products added for an assortment
     *  @param - assortmentProducts - list of assortment products pertaining to an assortment
     *  @return - void
     **/
    public static Boolean hasFERTProducts(Bundle_Product__c[] assortmentProducts) {
        Integer totalFERTCount = 0;
        
        if(assortmentProducts != null && !assortmentProducts.isEmpty()) {
            for(Bundle_Product__c ap: assortmentProducts) {
                if(ap.Product__r.SAP_Material_Type__c == CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT) {
                    totalFERTCount++;
                }
            }
        }
        return totalFERTCount > 0 ? true : false;
    }
    
    public static void updateAssortment(Bundle__c assortment) {
        //Defect#3715 - created new instance of assortment to update the last publish date toa vaoid other field updates during the process.
        Bundle__c assortmentObj = new Bundle__c(Id=assortment.id);
        assortmentObj.Last_Published_Date__c = System.now();
        assortmentObj.Publish_In_Progress__c = false;
        
        //US : 814 : Finance Review Process on Assortment Profitability
        if(assortment.RecordTypeId == CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN && assortment.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TRADE_CAMPAING_TYPE){
            updateFinanceReviewFields(assortmentObj);    
        }
        update assortmentObj;
        //assortment.Last_Published_Date__c = System.now();
        //assortment.Publish_In_Progress__c = false;
        //update assortment;
    }
    
    //US : 814 : Finance Review Process on Assortment Profitability
    public static void updateFinanceReviewFields(Bundle__c assortment){
        
        Decimal quantity = 0;
        Decimal estimatedRevenue = 0;
        Decimal returnsRevenue = 0;
        Decimal couponingForecast = 0;
        Decimal estimatedSalesAllowancesValue = 0;
        Decimal totalCostOfProducts = 0;
        Decimal PAPCost = 0;
        Decimal handlingLogistics = 0;
        Decimal royaltyAmount = 0;

        List<OpportunityLineItem> dealProducts = [Select Id,Estimated_Revenue_Formula__c,Total_Quantity__c,Returns_Revenue__c,Couponing_Forecast__c,Estimated_Sales_Allowances_Value__c,
                                                            Total_Cost_of_Products__c,PAP_Cost__c,Handling_Logistics__c,Royalty_Fee_Cost__c,Total_Royalty_Amount__c//US#958 - added new field
                                                     FROM OpportunityLineItem
                                                     WHERE opportunity.Bundle__c = :assortment.Id AND opportunity.account.RecordTypeId = :CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO AND opportunity.Bundle__r.RecordTypeId = :CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN AND
                                                     opportunity.Bundle__r.Campaign_Type__c = :CRM_AppConstants.ASSORTMENT_TRADE_CAMPAING_TYPE];
        
        system.debug('=====dealProducts===='+dealProducts);
        if(!dealProducts.isEmpty()){
            for(OpportunityLineItem dp : dealProducts){
                quantity += dp.Total_Quantity__c != null ? dp.Total_Quantity__c : 0;
                estimatedRevenue += dp.Estimated_Revenue_Formula__c != null ? dp.Estimated_Revenue_Formula__c : 0;
                returnsRevenue += dp.Returns_Revenue__c != null ? dp.Returns_Revenue__c : 0;
                couponingForecast += dp.Couponing_Forecast__c != null ? dp.Couponing_Forecast__c : 0;
                estimatedSalesAllowancesValue += dp.Estimated_Sales_Allowances_Value__c != null ? dp.Estimated_Sales_Allowances_Value__c : 0;
                totalCostOfProducts += dp.Total_Cost_of_Products__c != null ? dp.Total_Cost_of_Products__c : 0;
                PAPCost += dp.PAP_Cost__c != null ? dp.PAP_Cost__c : 0;
                handlingLogistics += dp.Handling_Logistics__c != null ? dp.Handling_Logistics__c : 0;
                //US#958 - changed formula to rollup 'Total_Royalty_Amount__c' new field created for FR in royalty amount of assortment.
                royaltyAmount += dp.Total_Royalty_Amount__c != null ? dp.Total_Royalty_Amount__c : 0;
            }
        }
        system.debug('=====quantity===='+quantity);
        system.debug('=====estimatedRevenue===='+estimatedRevenue);
        system.debug('=====returnsRevenue===='+returnsRevenue);
        system.debug('=====couponingForecast===='+couponingForecast);
        system.debug('=====estimatedSalesAllowancesValue===='+estimatedSalesAllowancesValue);
        system.debug('=====totalCostOfProducts===='+totalCostOfProducts);
        system.debug('=====PAPCost===='+PAPCost);
        system.debug('=====handlingLogistics===='+handlingLogistics);
        system.debug('=====royaltyAmount===='+royaltyAmount);
        
            
        assortment.Quantity__c = quantity;
        assortment.Estimated_Revenue__c = estimatedRevenue;
        assortment.Returns_Revenue__c = returnsRevenue;
        assortment.Couponing_Forecast__c = couponingForecast;
        assortment.Estimated_Sales_Allowances_Value__c = estimatedSalesAllowancesValue;
        assortment.Total_Cost_of_Products__c = totalCostOfProducts;
        assortment.PAP_Cost__c = PAPCost;
        assortment.Handling_Logistics__c = handlingLogistics;
        assortment.Royalty_Amountc__c = royaltyAmount;
        assortment.Profitability_Date_Stamped__c = system.today();
    }      
    
    
    public static boolean isPromotionalAssortment(Bundle__c assortment) {
        return (assortment.RecordTypeId != CRM_RecordTypeUtil.RT_Promotional_Assortment ? true : false);
    }
    
    public static void sendCompletionEmail(Bundle__c assortment, PublishError[] errors) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(assortment.OwnerId);
        
        List<String> ccAddresses = new List<String>{Userinfo.getUserEmail()};
        message.setccAddresses(ccAddresses);
        
        message.setSaveAsActivity(false); 
        message.subject = String.format(
            System.Label.CRM_Assortment_Successful_Message_Mail_Subject,
            new String[] {assortment.Name}
        ); // 'Assortment <'+assortment.Name+'> has been published';
        
        if(errors == null || errors.isEmpty()) {
            //message.plainTextBody = 'Assortment has been published successfully.';
            //String htmlEmailBody = '<p>Assortment has been published successfully.</p><p>Please find Assortment details:</p>';
            String htmlEmailBody = '<p>' + System.Label.CRM_Assortment_Successful_Message_Mail_Body +'</p><p>'+ System.Label.CRM_Assortment_Successful_Message_Mail_Body_1 + '</p>';
            htmlEmailBody += createAssortmentInfoTable(assortment);
            message.htmlbody = htmlEmailBody;
            
        }
        else {
            //Resolved Null pointer exception 
            Boolean isDigitalAssortment = CRM_ApplicationUtility.isDigitalAssortment(assortment); 
            
            String htmlEmailBody = '<p>'+System.Label.CRM_Assortment_Error_Message+'</p>';//Please find Assortment details:
            htmlEmailBody += createAssortmentInfoTable(assortment);
            
            htmlEmailBody += '<p>'+System.Label.CRM_Assortment_Error_Message_Details+'</p>'; //Assortment has been published with following error:
            htmlEmailBody += '<table style="width:90%;font-size: 15px;border: 1px solid black;border-collapse: collapse;">';
            htmlEmailBody += '  <tr>';
            htmlEmailBody += '    <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">'+System.Label.CRM_Assortment_Error_Message_Account_Number_Header+'</th>'; //Account Number
            //Add Account Name Field in Publish Error message
            htmlEmailBody += '    <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">'+System.Label.CRM_Assortment_Error_Message_Account_Name_Header+'</th>'; //Account Name
            htmlEmailBody += '    <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">'+System.Label.CRM_Assortment_Error_Message_Product_Material_Number_Header+'</th>';//Product Material Number
            if(isDigitalAssortment) 
                htmlEmailBody += '    <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">'+System.Label.CRM_Assortment_Error_Message_Product_Header+'</th>'; //Product
            if(assortment.recordTypeId <> CRM_RecordTypeUtil.RT_Promotional_Assortment){
            htmlEmailBody += '    <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">'+System.Label.CRM_Assortment_Error_Message_POS_Forecast_Header+'</th>';} //POS Forecast
            htmlEmailBody += '    <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">'+System.Label.CRM_Assortment_Error_Message+'</th>'; //Error Message
            htmlEmailBody += '  </tr>';
            
            for(PublishError err :  errors) {
                htmlEmailBody += '  <tr>';
                htmlEmailBody += '    <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+ (String.isBlank(err.accountNumber)? '' : err.accountNumber) +'</td>';
                //Add Account Name Field in Publish Error message
                htmlEmailBody += '    <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+ (String.isBlank(err.accountName)? '' : err.accountName) +'</td>';
                htmlEmailBody += '    <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+ (String.isBlank(err.productCode)? '' : err.productCode) +'</td>';
                if(isDigitalAssortment) 
                    htmlEmailBody += '    <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+ (String.isBlank(err.productName)? '' : err.productName) +'</td>';
                if(assortment.recordTypeId <> CRM_RecordTypeUtil.RT_Promotional_Assortment){
                    htmlEmailBody += '    <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+ (String.isBlank(err.posForecast)? '' : err.posForecast) +'</td>';
                }
                htmlEmailBody += '    <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+ (String.isBlank(err.error)? '' : err.error) +'</td>';
                htmlEmailBody += '  </tr>';
            } 
            
            htmlEmailBody += '</table>';
            
            
            message.htmlbody = htmlEmailBody;
        }
        
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {message});
    }
    public static String createAssortmentInfoTable(Bundle__c assortment){
        
        String htmlEmailBody = '<table style="width:70%;font-size: 15px;border: 1px solid black;border-collapse: collapse;">';
               htmlEmailBody += '    <thead>';
               htmlEmailBody += '        <tr style="border: 1px solid black;border-collapse: collapse;">';
               htmlEmailBody += '            <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">Assortment Name</th>';
               htmlEmailBody += '            <th style="text-align: left;padding: 5px;border: 1px solid black;border-collapse: collapse;">Status</th>';
               htmlEmailBody += '        </tr>';
               htmlEmailBody += '    </thead>';
               htmlEmailBody += '    <tbody>';
               htmlEmailBody += '        <tr style="border: 1px solid black;border-collapse: collapse;">';
               htmlEmailBody += '            <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;"><a href="https:'+'//'+URL.getSalesforceBaseUrl().getHost()+'/'+assortment.Id+'">'+assortment.Name+'</a></td>';
               htmlEmailBody += '            <td style=" padding: 5px;border: 1px solid black;border-collapse: collapse;">'+assortment.Assortment_Status__c+'</td>';
               htmlEmailBody += '    </tbody>';
               htmlEmailBody += '</table>';
               
        return htmlEmailBody;
    }
    private static Map<Id, Opportunity> getSAPDealsForCancellation(Id assortmentId) {
        // Query all the deals which have been sent to OTC but afterward Send_To_OTC flag has been unchcked from Assortment_Account
        Map<Id, Opportunity> dealsMap = new Map<Id, Opportunity>([select Id 
                            from Opportunity
                            where Assortment_Account__c <> null and Assortment_Account__r.Assortment__c = :assortmentId and Assortment_Account__r.Send_To_OTC__c = false
                            and UniquePublishKey__c <> null and Sent_To_SAP__c <> null]);
                            
        return dealsMap;
    }   
    
    public class PublishError {
        public String accountNumber {get;set;}
        //Add Account Name Field in Publish Error message
        public String accountName {get;set;}
        public String productCode {get;set;}
        public String posForecast {get;set;}
        public String error {get;set;}
        public String productName {get;set;}
        public Boolean isDigitalAssortment {get; set;}
    }
}