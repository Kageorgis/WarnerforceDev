/**
   @Author Cognizant
   @name CRMJV_DecayCurveReforcastingService
   @CreateDate 28 Oct 2020
   @Description: batch service class to reforcast schedule using new replen quantity.
   @Version <1.0>
   @reference: W-017642 - Enable Decay Curves and Re-forecasting Schedules
*/

public with sharing class CRMJV_DecayCurveReforcastingService{
    Public static List<CRMJV_DecayCurveReforcastingBatchException> lstExceptions = new List<CRMJV_DecayCurveReforcastingBatchException>();
    Public static Set<Id> setNotSuccessDealProducts = new Set<Id>();
    /**
    * @Description - Method for Processing DecayCurve 
    * @name processDecayCurveReforcasting
    */
    public static Set<Id> processDecayCurveReforcasting(List<OpportunityLineItem> dealProducts, Date weekStartDate){
        Set<Id> setErrorDealProductIds = new Set<Id>();
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Map<Id,OpportunityLineItem> mapDealProductToUpdate = new Map<Id,OpportunityLineItem>();
        
        Savepoint sp = Database.setSavepoint();
        try{
            Map<Id,List<OpportunityLineItemSchedule>> mapIdToOppoLineItemSchedulesList =prepareMapWithExistingOpportunityLineItemSchedules(dealProducts);
            for(OpportunityLineItem objProd : dealProducts){
                if (objProd.OpportunityLineItemSchedules.size() > 0){
                    if((objProd.New_Replen_Ship_Fcst__c==Null || objProd.New_Replen_Ship_Fcst__c==0) 
                    && (mapIdToOppoLineItemSchedulesList.get(objProd.Id)[0].Quantity != objProd.POS_Quantity__c)){
                        //DP.New Replen Qty =  (Replen Qty * Pos Qty )/ Current Qty
                        objProd.New_Replen_Ship_Fcst__c=(objProd.Replen_Ship_Fcst__c * objProd.POS_Quantity__c)/mapIdToOppoLineItemSchedulesList.get(objProd.Id)[0].Quantity;    
                        mapDealProductToUpdate.put(objProd.id,objProd);
                        objProd.Last_Re_Forecasted_Date__c=date.today();
                    }else if((objProd.New_Replen_Ship_Fcst__c!=Null || objProd.New_Replen_Ship_Fcst__c!=0)
                    && (mapIdToOppoLineItemSchedulesList.get(objProd.Id)[0].Quantity != objProd.POS_Quantity__c)){     
                        //DP.New Replen Qty =  (New Replen Qty * Pos Qty )/ Current Qty
                        objProd.New_Replen_Ship_Fcst__c=(objProd.New_Replen_Ship_Fcst__c * objProd.POS_Quantity__c)/mapIdToOppoLineItemSchedulesList.get(objProd.Id)[0].Quantity;    
                        mapDealProductToUpdate.put(objProd.id,objProd);
                        objProd.Last_Re_Forecasted_Date__c=date.today();
                    }else if(mapIdToOppoLineItemSchedulesList.get(objProd.Id)[0].Quantity == objProd.POS_Quantity__c){
                        setNotSuccessDealProducts.add(objProd.id);
                    }
                }
            }
            if(!mapDealProductToUpdate.isEmpty()){
                List<OpportunityLineItem> lstUpdatedDealProducts=updateCommitedDealsToBypassValidation(mapDealProductToUpdate.values(),false);
                Database.SaveResult[] saveResultList = Database.update(lstUpdatedDealProducts,false);
                set<Id> setSuccessDealProducts = new set<Id>();
                set<Id> setSuccessDealProductsSchedules = new set<Id>();
                
                for(Integer i = 0; i < saveResultList.size(); i++){
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    OpportunityLineItem prd = lstUpdatedDealProducts[i];
                    List<String> lstErrors = new List<String>();
                    if(!saveResultInstance.isSuccess()){
                        setErrorDealProductIds.add(prd.Id);
                        setNotSuccessDealProducts.add(prd.Id);  
                        CRM_ErrorLogger.ErrorLog errorLog;
                        for(Database.Error err : saveResultInstance.getErrors()){
                            lstErrors.add(err.getMessage());
                            // Save the error in database
                            errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = prd.Id;
                            errorLog.functionalModule = 'Re-forecasting Schedules';
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(new CRMJV_DecayCurveReforcastingBatchException(prd.Id,lstErrors));
                    }else{
                        setSuccessDealProducts.add(prd.Id);
                    }
                }
                if (!setSuccessDealProducts.isEmpty()) {
                    setNotSuccessDealProducts.AddAll(createDealProductSchedule(setSuccessDealProducts, new Set<Id>(), weekStartDate));
                    List<OpportunityLineItem> lstUpdatedDealPrdt=updateCommitedDealsToBypassValidation(mapDealProductToUpdate.values(),true);
                }
            }  
        }catch(Exception e){
            // Save the error in database
            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
            errorLog.lineNumber = String.valueOf(e.getLineNumber());
            errorLog.functionalModule = 'Re-forecasting Schedules'; 
            errorLog.errorMessage = e.getMessage().left(200);
            errorLog.stackTrace = e.getStackTraceString();
            listErrorLog.add(errorLog);
            
            //Adding Exception
            lstExceptions.add(new CRMJV_DecayCurveReforcastingBatchException(null,new List<String>{e.getMessage()}));
            setNotSuccessDealProducts.addAll(mapDealProductToUpdate.keyset());
            database.rollback(sp);
        }
        if(!listErrorLog.isEmpty()){
            // Inserts all errors into database
            CRM_ErrorLogger.logError(listErrorLog);
        }    
        return new Set<Id>(setNotSuccessDealProducts);
    }
    
    /**
    * @Description - Method to Get All Exception
    * @name CRMJV_DecayCurveReforcastingBatchException
    */
    public static List<CRMJV_DecayCurveReforcastingBatchException> getAllExceptions(){
        return lstExceptions;   
    }
    
    /**
    * @Description - Class for Exception Handling
    * @name CRMJV_DecayCurveReforcastingBatchException
    */
    public class CRMJV_DecayCurveReforcastingBatchException extends Exception{
        public Id recordId;
        public List<String> lstErrors;
        public CRMJV_DecayCurveReforcastingBatchException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    } 
    
    /**
    * @Description - Method to MAP Deal Product with Schedules
    * @name prepareMapWithExistingOpportunityLineItemSchedules
    */
    private static Map<Id,List<OpportunityLineItemSchedule>> prepareMapWithExistingOpportunityLineItemSchedules(List<OpportunityLineItem> lstOpportunityLineItem) {
        Map<Id,List<OpportunityLineItemSchedule>> mapIdToOppoLineItemSchedulesList = new Map<Id,List<OpportunityLineItemSchedule>>();
        for (OpportunityLineItem olInstance : lstOpportunityLineItem) {
            if (olInstance.OpportunityLineItemSchedules.size() > 0) {
                for (OpportunityLineItemSchedule olis : olInstance.OpportunityLineItemSchedules) {
                    if (mapIdToOppoLineItemSchedulesList.containsKey(olInstance.id)) {
                        mapIdToOppoLineItemSchedulesList.get(olInstance.id).add(olis);
                    } else {
                        mapIdToOppoLineItemSchedulesList.put(olInstance.id, new List<OpportunityLineItemSchedule> {olis});
                    }
                }
            }
        }
        return mapIdToOppoLineItemSchedulesList;
    }
    
    /**
    * @Description - Method to Update the commited deals to bypass the validation.
    * @name prepareMapWithExistingOpportunityLineItemSchedules
    */
    public static List<OpportunityLineItem> updateCommitedDealsToBypassValidation(List<OpportunityLineItem> listLineitems,Boolean finalReset) {
        
        Map<Id,Opportunity> mapDeals = new Map<Id,Opportunity>();
        Map<Id,List<OpportunityLineItem>> mapDealIdToDealProductId = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> finalDealProducts = new List<OpportunityLineItem>(); 
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        
        for(OpportunityLineItem objDealProduct : listLineitems){
            if(!mapDealIdToDealProductId.containsKey(objDealProduct.OpportunityId)){
                mapDealIdToDealProductId.put(objDealProduct.OpportunityId,new List<OpportunityLineItem>{objDealProduct});
            }else{
                mapDealIdToDealProductId.get(objDealProduct.OpportunityId).add(objDealProduct);
            }
            
            if(!finalReset && objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                objDealProduct.Opportunity.Bypass_Committed_Deals__c=system.now();
                mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
            }else if(finalReset && objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                objDealProduct.Opportunity.Bypass_Committed_Deals__c=null;
                mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
            }
        }
        
        Database.SaveResult[] saveResultList = Database.update(mapDeals.values(), false);
        for (Integer i = 0; i < saveResultList.size(); i++) {
            Database.SaveResult saveResultInstance = saveResultList[i];
            Opportunity dealInstance = mapDeals.values()[i];
            List<String> lstErrors = new List<String>();
            if (!saveResultInstance.isSuccess()) {
                //Remove the list of dealProducts with associated deals that failed
                if(!finalReset && mapDealIdToDealProductId.containsKey(dealInstance.Id)){
                    for(OpportunityLineItem dealProduct :mapDealIdToDealProductId.get(dealInstance.Id)){
                        setNotSuccessDealProducts.add(dealProduct.id);    
                    }
                    mapDealIdToDealProductId.remove(dealInstance.Id);
                }
                
                for(Database.Error err : saveResultInstance.getErrors()) {
                    lstErrors.add(err.getMessage());
                    // Save the error in database
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.recordId = dealInstance.Id;
                    errorLog.functionalModule = 'Re-forecasting Schedules';
                    errorLog.errorMessage = err.getMessage().left(200);
                    listErrorLog.add(errorLog);
                }
                lstExceptions.add(new CRMJV_DecayCurveReforcastingBatchException(dealInstance.Id,lstErrors));
            }
        }
        
        for(List<OpportunityLineItem> temp : mapDealIdToDealProductId.values()){
            finalDealProducts.addAll(temp);
        }
        if(!listErrorLog.isEmpty()){
            // Inserts all errors into database
            CRM_ErrorLogger.logError(listErrorLog);
        }    
        return  finalDealProducts;
    }
    
    /**
     * This method Will create the deal Product Schedules for DFI / POS deal.
     * @name: createDealProductSchedule
     * @param: Set<Id> setDealProductIds - Set of deal product Ids being inserted, updated 
     * @param: Set<Id> setProductIds - Set of Product Ids whose product street Date / PBEP Start Date is changed
     * @return None
     */
    private static Set<Id> createDealProductSchedule(Set<Id> setDealProductIds, Set<Id> setProductIds, Date weekStartDate){
        Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        set<Id> setNotSuccessDealProducts = new set<Id>();
        Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers = new Map<Id, CRM_DataObjects.DealProdWrapper>();

        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
        if(setDealProductIds != null && !setDealProductIds.isEmpty()){
            String strquery = 'SELECT Id, Quantity, Discount, P_L_Quantity__c, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c,  OpportunityId, Opportunity.Account.Decay_Curve_Template__c,'+
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
                                    'Initial_Ship_Fcst__c, Replen_Ship_Fcst__c, ListPrice__c, Deal_Sales_Organisation__c, Deal_Record_Type__c, New_Replen_Ship_Fcst__c '+
                                ' FROM OpportunityLineItem'+
                                ' WHERE '+
                                    '('+
                                        'Id IN: setDealProductIds'+
                                    ')'+
                                    ' AND Product2Id != null'+
                                            ' AND ('+' Opportunity.StageName != \''+CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED+'\''+
                                                    ' AND ('+
                                                    'Opportunity.StageName != \''+CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED+'\' OR '+
                                                    '( Opportunity.StageName = \''+CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED+'\' AND '+
                                                      'Opportunity.Bypass_Committed_Deals__c != null '+
                                                    ') '+
                                                    ')'+
                                                    ' AND'+
                                                    '('+
                                                        'Opportunity.Sales_Organisation__c = \''+CRM_AppConstants.TERRITORY_SDS_US_CODE+'\' OR Opportunity.Sales_Organisation__c = \''+ CRM_AppConstants.TERRITORY_SDS_CANADA_CODE+'\''+
                                                    ')'+
                                                    ' AND'+
                                                    '('+
                                                        'Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_Physical_DFI_Deal+'\' OR Opportunity.RecordTypeId = \''+CRM_RecordTypeUtil.RT_Physical_POS_Deal+ '\' OR Opportunity.RecordTypeId = \''+ CRM_RecordTypeUtil.RT_Physical_Planning_Deal+'\'' +
                                                    ')'+
                                            ')'+
                                    ' LIMIT 10000';         
            lstDealProducts = database.query(strquery);
        }
        if (lstDealProducts != null && !lstDealProducts.isEmpty()) {
            Map<Id,OpportunityLineItem> mapDealProductIdToInstance = new Map<Id,OpportunityLineItem>(lstDealProducts);
          
            Map<Id, list<Decay_Curve_Item__c>> mapTemplateIdToItems =
                    fetchDecayCurveTemplateItemsWithPB(
                        mapDealProductIdToInstance,
                        mapIdToDealProductWrappers
                    );
        setNotSuccessDealProducts = processDecayCurve(
                    mapDealProductIdToInstance,
                    mapTemplateIdToItems,
                    mapIdToDealProductWrappers,
                    weekStartDate
                );
        }
        return setNotSuccessDealProducts;
    }
    
    /**
     * This method is used to process decay Curve calculation
     * @name: processDecayCurve
     * @param: Map<Id, OpportunityLineItem> mapDealProductIdToInstance - Map of deal product being inserted, updated or whose product street Date / PBEP Start Date is changed
     * @param: Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems - Map of Normal / P&L Decay Curve Template Id to its Decay Curve Items
     * @param: Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers - Map of Deal Product Id to Deal Product Wrapper used for Digital Products
     * @return None
     */
    private static set<Id> processDecayCurve(
        Map<Id, OpportunityLineItem> mapDealProductIdToInstance,
        Map<Id, List<Decay_Curve_Item__c>> mapTemplateIdToItems,
        Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers,
        Date weekStartDate
    )  {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        set<Id> setNotSuccessDealProducts = new set<Id>();
        set<Id> setSuccessDealProducts = new set<Id>();
        Set<Id> dealProductIdSet = new Set<Id>();
        Set<Id> scheduleIdSet = new Set<Id>();
        Map<id,set<String>> scheduleIdSetMap = new Map<id,set<String>>();

        for (OpportunityLineItem dealProduct : mapDealProductIdToInstance.values()) {
            Date initialDate = dealProduct.Opportunity.Promo_Start_Date__c;
            if (initialDate != null) {
                // Create Initial Schedules for both Normal Decay Curve and P&L Decay Curve for Physical Deals
                schedules.addAll(createInitialSchedules(dealProduct, initialDate, dealProductIdSet));
                // Create Replen/PL Schedules for both Normal Decay Curve and P&L Decay Curve for Physical / Digital Deals
                schedules.addAll(createReplenAndPLSchedules(dealProduct,initialDate,mapTemplateIdToItems,dealProductIdSet));      
            }
        }

        List<OpportunityLineItemSchedule> schedulesToInsert = new List<OpportunityLineItemSchedule>();
        for (OpportunityLineItemSchedule olis : [Select OpportunityLineItemID,ScheduleDate,Description From OpportunityLineItemSchedule Where OpportunityLineItemID in: dealProductIdSet And ScheduleDate >=: weekStartDate]){    //AND Description LIKE: decayDescription]
            if(olis.Description != CRM_AppConstants.SCHEDULE_ZERO && olis.Description != CRM_AppConstants.SCHEDULE_INITIAL){
                scheduleIdSet.add(olis.id);
                if (scheduleIdSetMap.containsKey(olis.OpportunityLineItemID)) {
                    scheduleIdSetMap.get(olis.OpportunityLineItemID).add(String.valueOf(olis.ScheduleDate));
                } else {
                    scheduleIdSetMap.put(olis.OpportunityLineItemID, new Set<String> {String.valueOf(olis.ScheduleDate)});
                }
            }
        }
        
        for(OpportunityLineItemSchedule temp : schedules){
            if(scheduleIdSetMap.containsKey(temp.OpportunityLineItemID) && scheduleIdSetMap.get(temp.OpportunityLineItemID).contains(String.valueOf(temp.ScheduleDate))){
                schedulesToInsert.add(temp);
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            // Delete Existing Schedules
            List<OpportunityLineItemSchedule> dealProductSchedules = [SELECT ID FROM OpportunityLineItemSchedule WHERE OpportunityLineItemID IN: dealProductIdSet AND Id IN:scheduleIdSet];
            if(!dealProductSchedules.isEmpty()){
                delete dealProductSchedules;
            }
            // Insert Schedules according to Normal decay curve template OR replen delay days
            if(!schedulesToInsert.isEmpty()) {
                Database.SaveResult[] saveResultList = database.insert(schedulesToInsert,False);                
                for(Integer i = 0; i < saveResultList.size(); i++){
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    OpportunityLineItemSchedule olis = schedulesToInsert[i]; 
                    List<String> lstErrors = new List<String>();
                    if(!saveResultInstance.isSuccess()){
                        CRM_ErrorLogger.ErrorLog errorLog;
                        for(Database.Error err : saveResultInstance.getErrors()){
                            lstErrors.add(err.getMessage());
                             // Save the error in database
                            errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = olis.OpportunityLineItemID;
                            errorLog.functionalModule = 'Re-forecasting Schedules';
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        setNotSuccessDealProducts.add(olis.OpportunityLineItemID);
                        lstExceptions.add(new CRMJV_DecayCurveReforcastingBatchException(olis.OpportunityLineItemID,lstErrors));
                    }else{
                        setSuccessDealProducts.add(olis.OpportunityLineItemID);  
                    }
                }
            }
        } catch (Exception ex) {
            CRM_ErrorLogger.ErrorLog err = new CRM_ErrorLogger.ErrorLog();
            err.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DECAY_CURVE;
            err.lineNumber =  String.valueOf(ex.getLineNumber());
            err.errorMessage = ex.getMessage().left(255);
            err.stackTrace = ex.getStackTraceString();
            CRM_ErrorLogger.logError(err);
            setNotSuccessDealProducts.addAll(dealProductIdSet);
            Database.rollback(sp);
            throw ex;
        }
        if(!listErrorLog.isEmpty()){
            // Inserts all errors into database
            CRM_ErrorLogger.logError(listErrorLog);
        }
        return setNotSuccessDealProducts;
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
        
    ) {
        Map<ID, List<Decay_Curve_Item__c>> mapTemplateIdToItems = new Map<ID, List<Decay_Curve_Item__c>>();
        
        for (OpportunityLineItem dealProduct : mapIdToDealProductInstance.values()) {
            CRM_DataObjects.DealProdWrapper dealProductWrapperInstance = new CRM_DataObjects.DealProdWrapper();
            Id decayCurveTemplateId = getDecayCurveTemplatId(dealProduct); 
            if (decayCurveTemplateId != null) {
                mapTemplateIdToItems.put(decayCurveTemplateId, new Decay_Curve_Item__c[]{});
            } 
        }
        // Get all Decay curve item using template ID 
        for (Decay_Curve_Item__c currentItem : [SELECT ID,Percent_Allocation__c,Day_Number__c,Decay_Curve_Template__c FROM Decay_Curve_Item__c
                                                WHERE
                                                Decay_Curve_Template__c IN :mapTemplateIdToItems.keySet()
                                                AND (
                                                    Decay_Curve_Template__r.Status__c =: CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE OR
                                                    Decay_Curve_Template__r.Status__c =: CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ARCHIVED
                                                )
                                                ORDER BY CreatedDate ASC
                                            ]) 
        { 
         ID currentTemplateId = currentItem.Decay_Curve_Template__c;
         if (currentTemplateId != null) {
                mapTemplateIdToItems.get(currentTemplateId).add(currentItem);
         }
        }
        return mapTemplateIdToItems;
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
        Set<Id> dealProductIdSet
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        Decimal initialQuantity;
        
        if ((dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
            && (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)) {
                Decimal replanQuantity = 0;
                if(dealProduct.New_Replen_Ship_Fcst__c != null && dealProduct.New_Replen_Ship_Fcst__c != 0 && dealProduct.Replen_Ship_Fcst__c != null && dealProduct.Replen_Ship_Fcst__c!=0){
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
        Set<Id> dealProductIdSet
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        String scheduleType =
            dealProduct.Discount == 100
            ? CRM_AppConstants.SCHEDULE_TYPE_QUANTITY
            : CRM_AppConstants.SCHEDULE_TYPE_BOTH;
       
        if( ((dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal|| dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
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
                  scheduleType
              ));  
          }
       return schedules;
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
            String scheduleType
    ) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();

        // Create Schedlues for Both Physical & Digital Type of Deals based on Templates present or not
        Id decayCurveTemplateId = getDecayCurveTemplatId(dealProduct);
        
        if(((dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal || dealProduct.Opportunity.RecordtypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
            && (dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE))) {
                
                Decimal replenQuantity = 0;
                if(dealProduct.New_Replen_Ship_Fcst__c != null && dealProduct.New_Replen_Ship_Fcst__c != 0) {
                    replenQuantity = dealProduct.New_Replen_Ship_Fcst__c;
                } else if(dealProduct.Replen_Ship_Fcst__c != null) {
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
        return schedules;
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
 }