/*
   @Author: Vaibhav Trivedi
   @name CRM_BatchTargetRollUp
   @CreateDate 1 Dec 2015
   @Description: Batch Class to roll up the revenue fields of Target Object (Approved, Planned, Confirmed, Actuals, High Level)
   @Version 1.0
  */
global with sharing class CRM_BatchTargetRollUp implements database.batchable<sObject>, database.Stateful {
    Map<Id, OpportunityLineItem[]> mapDealProductsForProduct;
    Map<Id, OpportunityLineItem[]> mapDealProductsForProductGroups;
    Map<Id, OpportunityLineItem[]> mapDealProductsForBundles;        
    //Req: #159 => Map to store Deal Produucts for Mid Term NR Target.
    Map<id, OpportunityLineItem[]> mapDealProductsForProductGroupOfMidTermNR; 
    public static Date gStartDate;
    //*******
    public static Target__c targetGlobal;
    
    //Global Set's For Updating Account on the basis of processed and unprocessed Target's
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    
    Set<Id> processedTargetAccountIds = new Set<Id>();
    Set<Id> unprocessedTargetAccountIds = new Set<Id>();
    
    /**
    *  Getting Start Date from custom setting to Filter Target records
    *  @name getStartDate
    */
    private Date getStartDate() {
        //System.debug('$%$%$%$%$% INSIDE getStartDate');
        //System.debug('^^^^^^^^^^^^^^^^^^^^^^^ TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c: ' + TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c);
        //System.debug('*********************** TargetLimitter__c.getOrgDefaults(): ' + TargetLimitter__c.getOrgDefaults());
        if(TargetLimitter__c.getOrgDefaults() != null && TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c != null)
            return System.Today().addMonths((Integer)(0 - TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c));
        return System.Today().addMonths((Integer)(0 - 6));
    }
    
    /**
    *  Start method of Batch 
    *  @name start
    *  @return  Query locator  - returning the records from query string
    */
    global Database.queryLocator start(Database.BatchableContext BC) {
        System.debug(' @@@@ INSIDE SCOPE');
        gStartDate =  getStartDate();        
        System.debug('$$$$$$$$$$$$$$ gStartDate: ' + gStartDate);
        String query ='SELECT id, Calc_End_Date__c, End_Date__c, StartDate__c, Approved__c, RecordTypeId, Bundle__c, Actual_Revenue__c, Account__c, Confirmed__c, ';
        query += 'High_Level__c, Planned__c,Product__c, Product__r.RecordType.Name, Product_Group__c, Calc_Start_Date__c, Target__c, Bundle__r.End_Date__c, Bundle__r.Start_Date__c FROM Target__c';
        query +=  ' WHERE Account__r.scheduleRevenueChanged__c = true';
         
        //query += ' AND Id = \'a214B000000D8Yg\' ';
        
        System.debug('=====================> Target query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    /* method to re-initialize the variables for next batch processing */
    private void initialize() {
        mapDealProductsForProduct = new Map<Id, OpportunityLineItem[]>();
        mapDealProductsForProductGroups = new Map<Id, OpportunityLineItem[]>();
        mapDealProductsForBundles = new Map<Id, OpportunityLineItem[]>();        
        mapDealProductsForProductGroupOfMidTermNR = new  Map<Id, OpportunityLineItem[]>(); 
        
        //gStartDate = null;
        //targetGlobal = null;
        
        saveResults = new List<Database.SaveResult>();
    }
    
    /**
    *  Execute method of Batch
    *  @name execute
    *  @param scopeTarget- For storing the records returned from Start method
    */
    global void execute(Database.BatchableContext BC,List<target__c> scopeTarget) {
        initialize();
        
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setProductGroupIds = new Set<Id>();
        Map<Id,Set<Id>> mapBundleToProductIds = new Map<Id,Set<Id>>();
        Set<Id> setAllBundleProductIds = new Set<Id>();
        for(Target__c objTarget: scopeTarget){
            setAccountIds.add(objTarget.Account__c);
            //Assigning target object to a global target object
            targetGlobal = objTarget;
            
            //system.debug('Lookups on targets: ' + objTarget.Product__c + ', ' + objTarget.Product_Group__c + ', ' + objTarget.Bundle__c);
            if(objTarget.Product__c != null)            
                setProductIds.add(objTarget.Product__c);
            else if(objTarget.Product_Group__c != null){
                setProductGroupIds.add(objTarget.Product_Group__c);                                
            }else if(objTarget.Bundle__c != null)
                mapBundleToProductIds.put(objTarget.Bundle__c, new Set<Id>());
        }
        
        prepareDealProductMaps(setProductIds, setProductGroupIds, setAllBundleProductIds, setAccountIds, mapBundleToProductIds);        
                
        for(Target__c objTarget : scopeTarget) {
          collectingResultsForTargets(objTarget);
        }
    //List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    //List<Database.SaveResult> saveAccountResults = new List<Database.SaveResult>();
    
    try{    
    
            saveResults = Database.update(scopeTarget,false);
            Map<Id, Id> mapTargetAndAccount = new Map<Id, Id>();
            for (Target__c objTarget: scopeTarget){
                mapTargetAndAccount.put(objTarget.Id, objTarget.Account__c);
            }

            //List<Id> lstAcctId = new List<Id>();
            //Error Logging for target
            List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
            if (mapTargetAndAccount != null){
                for (Database.SaveResult sr : saveResults) {
                    if(sr.isSuccess() && mapTargetAndAccount.containsKey(sr.getId()) && mapTargetAndAccount.get(sr.getId()) != null){
                        //lstAcctId.add(mapTargetAndAccount.get(sr.getId()));
                         processedTargetAccountIds.add(mapTargetAndAccount.get(sr.getId()));
                        
                    }
                    else{
                        unprocessedTargetAccountIds.add(mapTargetAndAccount.get(sr.getId()));
                         
                      //Error Logging for Unprocessed Targets  
                        for (Database.Error err : sr.getErrors()) {
                            CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
                            errorLogInstance.recordId = sr.getId();
                            errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_TARGET;
                            errorLogInstance.className = 'CRM_BatchTargetRollUp';
                            errorLogInstance.errorMessage += err.getMessage().left(200);
                            listErrorLog.add(errorLogInstance);
                        }   
                      //Error Logging for Unprocessed Targets  
                    }                                           
                }
                CRM_ErrorLogger.logError(listErrorLog);
            }  
            
            /*if (lstAcctId != null && lstAcctId.size() > 0){
                List<Account> lstAcct = [SELECT Id, scheduleRevenueChanged__c FROM Account WHERE Id IN: lstAcctId AND scheduleRevenueChanged__c = true]; 
                if (lstAcct != null && lstAcct.size() > 0){
                    for (Account objAcct: lstAcct){
                        objAcct.scheduleRevenueChanged__c = false;
                    }
                    saveAccountResults = Database.update(lstAcct);
                    //update lstAcct;
                }          
            }*/
            
        } catch(exception ex) {
            if (saveResults != null){
                for(Database.SaveResult sr: saveResults)
                    logAnException(ex, sr.getId());
            }
            /* 
            //Commented the below code snippet as it is no longer in use
            //saveAccountResults is always an empty list
            if (saveAccountResults != null){
                for (Database.SaveResult asr: saveAccountResults)
                    logAnException(ex, asr.getId());
            }
            */
        }
        
    }
    
    
    /**
    * Creating Maps of Deal Products for products , Groups and Bundles
    * 
    *    @name prepareDealProductMaps
    *    @param setProductIds - 
    *  @param setProductGroupIds
    *  @param setAllBundleProductIds
    *  @param mapBundleToProductIds
    *  @param setAccountIds 
    *   @returning -  Maps of Deal Products for products , Groups and Bundles
    */  
    private void prepareDealProductMaps(Set<Id> setProductIds, Set<Id> setProductGroupIds, Set<Id> setAllBundleProductIds, 
                                            Set<Id> setAccountIds, Map<Id,Set<Id>> mapBundleToProductIds) {
                                            
        List<Bundle_Product__c> lstBundleProducts = new List<Bundle_Product__c>();
        if (mapBundleToProductIds != null){
            lstBundleProducts = [Select Product__c, Name, Bundle__c From Bundle_Product__c 
                      where Bundle__c IN: mapBundleToProductIds.keySet() AND Bundle__r.RecordTypeId != : CRM_RecordTypeUtil.RT_BUNDLE_NEW_RELEASE];
            for(Bundle_Product__c objBundleProduct : lstBundleProducts) {
                if (objBundleProduct.Bundle__c != null && mapBundleToProductIds.containsKey(objBundleProduct.Bundle__c) && mapBundleToProductIds.get(objBundleProduct.Bundle__c) != null)
                mapBundleToProductIds.get(objBundleProduct.Bundle__c).add(objBundleProduct.Product__c);
                setAllBundleProductIds.add(objBundleProduct.Product__c);
            }
        }
        
        //******Retrieving All Deal Products, Query Modified for requirement #FR 456: Target_Revenue__c, Opportunity.Sales_Organisation__c
        Set<Id> oppLineItemIds = new Set<Id>();
        if(targetGlobal.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR && targetGlobal.Product_Group__c !=null){
            oppLineItemIds  = returnValidLineItemForProductGroup(targetGlobal,setProductGroupIds, true);
        }
        else if(targetGlobal.RecordTypeId != CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR && targetGlobal.Product_Group__c !=null){
             oppLineItemIds  = returnValidLineItemForProductGroup(targetGlobal,setProductGroupIds, false);
        }
        
         List<OpportunityLineItem> lstAllDealProducts = new List<OpportunityLineItem>(); 
         system.debug('oppLineItemIds================>'+ oppLineItemIds.size());
          system.debug('targetGlobal================>'+ targetGlobal);
        //Query Modified ******
        if((targetGlobal.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_GROUP || targetGlobal.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR) && oppLineItemIds.size()>0 && oppLineItemIds !=null){
        system.debug('In If Condition================>');
        lstAllDealProducts = [Select Id, Returns__c,Target_Revenue__c, Opportunity.Account.Digital_Country_Code__c, Opportunity.Sales_Organisation__c,Product2.RecordTypeId,Opportunity.CurrencyIsoCode,Opportunity.Pricebook2Id, opportunity.AccountId, opportunity.RecordTypeId, product2.Id, Product2.Street_Date__c, Product2.NR_End_Date__c, Product2.Product_Type__c, Actual_Revenue__c,
                opportunity.ForecastCategoryName, Account_Price__c, ListPrice, ListPrice__c, opportunity.Start_Date__c, Product2.Product_Group__c, Pricebook_Entry_Period__c, Pricebook_Entry_Period__r.Start_Date__c, Pricebook_Entry_Period__r.End_Date__c, NR__c, 
                (Select Id, Quantity, ScheduleDate, Revenue, Type  From OpportunityLineItemSchedules)
                From OpportunityLineItem 
                where ID IN :oppLineItemIds AND opportunity.AccountId IN:setAccountIds and (Product2Id IN : setProductIds OR product2.Product_Group__c IN: setProductGroupIds OR Product2Id IN: setAllBundleProductIds) AND Opportunity.RecordTypeId !=: CRM_RecordTypeUtil.RT_DEAL_ACTUALS AND Opportunity.RecordTypeId !=: CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS ];
                
        }
        else{
        lstAllDealProducts = [Select Id, Returns__c,Target_Revenue__c, Opportunity.Account.Digital_Country_Code__c, Opportunity.Sales_Organisation__c,Product2.RecordTypeId,Opportunity.CurrencyIsoCode,Opportunity.Pricebook2Id, opportunity.AccountId, opportunity.RecordTypeId, product2.Id, Product2.Street_Date__c, Product2.NR_End_Date__c, Product2.Product_Type__c, Actual_Revenue__c,
                opportunity.ForecastCategoryName, Account_Price__c, ListPrice, ListPrice__c, opportunity.Start_Date__c, Product2.Product_Group__c, Pricebook_Entry_Period__c, Pricebook_Entry_Period__r.Start_Date__c, Pricebook_Entry_Period__r.End_Date__c, NR__c, 
                (Select Id, Quantity, ScheduleDate, Revenue, Type  From OpportunityLineItemSchedules)
                From OpportunityLineItem 
                where opportunity.AccountId IN:setAccountIds and (Product2Id IN : setProductIds OR product2.Product_Group__c IN: setProductGroupIds OR Product2Id IN: setAllBundleProductIds) AND Opportunity.RecordTypeId !=: CRM_RecordTypeUtil.RT_DEAL_ACTUALS AND Opportunity.RecordTypeId !=: CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS ];
            
        }
         
        if(lstAllDealProducts != null) {
          for(OpportunityLineItem dp : lstAllDealProducts) {
              if(setProductIds.contains(dp.Product2Id) ) {
                  if(!mapDealProductsForProduct.containsKey(dp.Product2Id) && dp.NR__c) {
                      mapDealProductsForProduct.put(dp.Product2Id, new OpportunityLineItem[]{});
                    }                   
                    if (mapDealProductsForProduct != null && mapDealProductsForProduct.containsKey(dp.Product2Id) && mapDealProductsForProduct.get(dp.Product2Id) != null && dp != null && dp.NR__c){
                        mapDealProductsForProduct.get(dp.Product2Id).add(dp);
                    }
                }
                
                
                //Req:#159 New Map Created For Mid Term NR Target And Contain only those DP Whose NR is True.
                    if(setProductGroupIds.contains(dp.Product2.Product_Group__c)) {
                        if(!mapDealProductsForProductGroupOfMidTermNR.containsKey(dp.Product2.Product_Group__c) && dp.NR__c == true) {
                            mapDealProductsForProductGroupOfMidTermNR.put(dp.Product2.Product_Group__c, new OpportunityLineItem[]{});
                        }
                        if (dp != null && dp.Product2 != null && dp.Product2.Product_Group__c != null && mapDealProductsForProductGroupOfMidTermNR!= null && mapDealProductsForProductGroupOfMidTermNR.containsKey(dp.Product2.Product_Group__c) && mapDealProductsForProductGroupOfMidTermNR.get(dp.Product2.Product_Group__c) != null && dp.NR__c == true){
                            mapDealProductsForProductGroupOfMidTermNR .get(dp.Product2.Product_Group__c).add(dp);
                        }
                    }
                //Req:#159 New Map Created For Mid Term NR Target


                /*if (mapDealProductsForProductGroups.containsKey(dp.Product2.Product_Group__c)){
                    System.debug('%^%^%^%^%^%^%^% mapDealProductsForProductGroups.get(dp.Product2.Product_Group__c): ' + mapDealProductsForProductGroups.get(dp.Product2.Product_Group__c));
                }else{
                    System.debug('Map does not contain any associated value: ' + mapDealProductsForProductGroups);
                }*/

                if(setProductGroupIds.contains(dp.Product2.Product_Group__c)) {
                    if(!mapDealProductsForProductGroups.containsKey(dp.Product2.Product_Group__c) && dp.NR__c == false) {
                        mapDealProductsForProductGroups.put(dp.Product2.Product_Group__c, new OpportunityLineItem[]{});
                    }
                    if (dp != null && dp.Product2 != null && dp.Product2.Product_Group__c != null && mapDealProductsForProductGroups != null && mapDealProductsForProductGroups.containsKey(dp.Product2.Product_Group__c) && mapDealProductsForProductGroups.get(dp.Product2.Product_Group__c) != null && dp.NR__c == false){
                        mapDealProductsForProductGroups.get(dp.Product2.Product_Group__c).add(dp);
                    }
                }

                // check it for a bundle
                for(Id bundleId : mapBundleToProductIds.keySet()) {
                    for(Id prdId : mapBundleToProductIds.get(bundleId)) {
                        if(dp.Product2Id == prdId) {
                            if(!mapDealProductsForBundles.containsKey(bundleId)) {
                                mapDealProductsForBundles.put(bundleId, new OpportunityLineItem[]{});
                            }
                            if (dp != null && bundleId != null && mapDealProductsForBundles != null && mapDealProductsForBundles.containsKey(bundleId) && mapDealProductsForBundles.get(bundleId) != null){
                                mapDealProductsForBundles.get(bundleId).add(dp);
                            }
                        }                       
                    }
                }
            }
        }else{
            //System.debug('@#@#@#@#@lstAllDealProducts is NULL');
        }
    }

    /**
    *  Use For collecting the results to the corresponding fileds of Target object (Approved, Planned, Confirmed)
    *  @name collectingResultsForTargets
    *  @param objTarget - Target object
    *  #159 else if modified for product group
    */
    private void collectingResultsForTargets(Target__c objTarget){
    
        if(objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_PRODUCT) {
                objTarget.Approved__c   = 0;
                objTarget.Planned__c    = 0;
                objTarget.Confirmed__c  = 0;
                objTarget.High_Level__c = 0;
                objTarget = setValuesForTargetFromProduct(objTarget);
        } else if(objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_GROUP || objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR) {
                objTarget.Approved__c   = 0;
                objTarget.Planned__c    = 0;
                objTarget.Confirmed__c  = 0;
                objTarget.High_Level__c = 0;
                objTarget = setValuesForTargetFromProductGroup(objTarget);
        } else if(objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_BUNDLE) {
                objTarget.Approved__c   = 0;
                objTarget.Planned__c    = 0;
                objTarget.Confirmed__c  = 0;
                objTarget.High_Level__c = 0;
                objTarget = setValuesForTargetFromBundles(objTarget);
        } 
    }
    
  /**
    *  Query to retrieve the High Level Deals
    *  @name getHighLevelDeals
    */
    private List<Deal_Product_Group__c> getHighLevelDealProductGroups(Target__c objTarget){
        List<Deal_Product_Group__c> lstHighLevelDeals = new List<Deal_Product_Group__c>();

        if (objTarget != null && objTarget.Product_Group__c != null && objTarget.Account__c != null) {
            lstHighLevelDeals = [
                                SELECT
                                    Id, Opportunity__r.Name, Opportunity__r.Start_Date__c, Opportunity__r.AccountId,
                                    Opportunity__r.ForecastCategoryName, Opportunity__r.RecordTypeId, Opportunity__r.Id, Name, Product_Group__c, Revenue__c  
                                FROM Deal_Product_Group__c
                                WHERE Opportunity__r.RecordTypeId = : CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL
                                AND Product_Group__c =: objTarget.Product_Group__c
                                AND Opportunity__r.AccountId =: objTarget.Account__c
                            ];
        }
        return lstHighLevelDeals;
    }
    
    /**
    *  Use for Calculating the values retrieved from the Deal Products, for corresponding fields of Target object (Approved, Planned, Confirmed)
    *       For Product Record Type Of Target
    *  @name setValuesForTargetFromProduct
    *  @param objTarget - Target Object
    *  @return objTarget - Target Object Field
    */
    private Target__c setValuesForTargetFromProduct(Target__c objTarget) {
        String ForecastCategoryName;
        Double approved = 0;
        Double planned = 0;
        Double confirmed = 0;
        Double actual = 0;
        Double noQuantityRevenue = 0;
        Boolean targetFlag = true; // Flag to set target__c equals to zero only for first time
        try {
            List<OpportunityLineItem> lstDealproductsOfProducts = mapDealProductsForProduct.get(objTarget.Product__c);
            
            if(lstDealproductsOfProducts != null) {
                for(OpportunityLineItem dealProduct: lstDealproductsOfProducts) {
                Opportunity deal = dealProduct.opportunity;
               
            //#FR User Story 456 : Rollup Deal Product Target Revenue to associated Target Target Field Only For France
                if(
                        deal.AccountId == objTarget.Account__c &&
                        (
                            deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE ||
                            (
                                (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) ||
                                (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && deal.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                            )
                        )
                ) {
                    if(targetFlag){
                       objTarget.Target__c = 0;
                       targetFlag = false; 
                    }
                    objTarget.Target__c =( (objTarget.Target__c!=null?objTarget.Target__c:0) + dealProduct.Target_Revenue__c);
                }
            //End of #FR User Story 456
               
                ForecastCategoryName = dealProduct.opportunity.ForecastCategoryName;
                if(dealProduct != null && (dealProduct.OpportunityLineItemSchedules == null  || dealProduct.OpportunityLineItemSchedules.size() == 0)) {
                    setNoQuantitiesTarget(objTarget, dealProduct, deal);
                }
                //System.debug('#$#$#$#$#$#$# dealProduct.OpportunityLineItemSchedules: ' + dealProduct.OpportunityLineItemSchedules.size());
                //System.debug('==========> OpportunityLineItemSchedule: ' + dealProduct.OpportunityLineItemSchedules);
                //System.debug('%%%%%%%%%%%%%%%%% dealProduct: ' + dealProduct);
                for(OpportunityLineItemSchedule schedules : (List<OpportunityLineItemSchedule>)dealProduct.OpportunityLineItemSchedules) {
                    if((deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) && 
                        conditionsForProducts(objTarget, dealProduct, schedules, deal) && schedules.Revenue != null){
                        if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED) {
                            if (objTarget.Approved__c == null)
                                objTarget.Approved__c = 0;
                            approved += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                            objTarget.Approved__c = approved;
                           
                        } if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED) {
                            if (objTarget.Planned__c == null)
                                objTarget.Planned__c = 0;
                            Planned += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                            objTarget.Planned__c = Planned;
                           
                        } if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED) {
                            if (objTarget.Confirmed__c == null)
                                objTarget.Confirmed__c = 0;
                            confirmed += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                            objTarget.Confirmed__c = confirmed;
                            
                            
                        }
                    } /*else if(deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_ACTUALS && 
                                conditionsForActualsForBundlesAndProducts(objTarget, dealProduct, schedules, deal)){
                          if (objTarget.Actual_Revenue__c == null) 
                              objTarget.Actual_Revenue__c = 0;
                          actual += schedules.Revenue;
                          objTarget.Actual_Revenue__c = actual;
                        }*/
                    }   
                }
            }else{
                //System.debug('@#@#@#@#@ lstDealproductsOfProducts is empty');
            }
        } catch(exception e) {
        throw e;
        }
        return objTarget;
    }
    
    /**
    *  Use for Calculating the values retrieved from the Deal Products, for corresponding fields of Target object (Approved, Planned, Confirmed)
    *       For Product Group Record Type Of Target
    *  @name setValuesForTargetFromProductGroup
    *  @param objTarget - Target Object
    *  @return objTarget - Target Object Field
    */
    private Target__c setValuesForTargetFromProductGroup (Target__c objTarget) {
        String ForecastCategoryName;
        Double approved = 0;
        Double planned = 0;
        Double confirmed = 0;
        Double actual = 0;
        Double noQuantityRevenue = 0;
        Double highLevel = 0;
        
        //List<OpportunityLineItem> lstDealproductsOfGroups = mapDealProductsForProductGroups.get(objTarget.Product_Group__c);
        List<OpportunityLineItem> lstDealproductsOfGroups = new List<OpportunityLineItem>();
        //Req:#159 Passing different maps on the basis of Target Record Type.
            if(objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR ){
                lstDealproductsOfGroups = mapDealProductsForProductGroupOfMidTermNR.get(objTarget.Product_Group__c);
            }
            else{
                lstDealproductsOfGroups = mapDealProductsForProductGroups.get(objTarget.Product_Group__c);
            }
        //Req:#159 Passing different maps on the basis of Target Record Type.
        
        if(lstDealproductsOfGroups != null){  
                
                for(OpportunityLineItem dealProduct: lstDealproductsOfGroups) {
                    
                    Opportunity deal = dealProduct.opportunity;
                    ForecastCategoryName = deal.ForecastCategoryName;
                    if(dealProduct != null && (dealProduct.OpportunityLineItemSchedules == null  || dealProduct.OpportunityLineItemSchedules.size() == 0)) {
                        setNoQuantitiesTarget(objTarget, dealProduct, deal);
                        
                    }
                    
                    for(OpportunityLineItemSchedule schedules :(List<OpportunityLineItemSchedule>)dealProduct.OpportunityLineItemSchedules){
                        if( (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) && 
                            conditionsForProductsGroupsAndBundlesForNormalDeals(objTarget, dealProduct, schedules, deal) && schedules.Revenue != null){
                             
                            if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED) {
                                    if (objTarget.Approved__c == null) 
                                        objTarget.Approved__c =0;
                                    approved += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                                   objTarget.Approved__c = approved;
                                
                            }
                            if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED) {
                                if (objTarget.Planned__c == null) 
                                    objTarget.Planned__c =0;
                                Planned += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                                objTarget.Planned__c = Planned;
                              
                            } if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED) {
                                if (objTarget.Confirmed__c == null) 
                                    objTarget.Confirmed__c =0;
                                confirmed += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                                objTarget.Confirmed__c = confirmed;                
                            }               
                      
                        } /*else if(deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_ACTUALS &&
                            schedules != null && 
                            schedules.Revenue != null &&
                            objTarget.Account__c == deal.AccountId &&   
                            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) && schedules.ScheduleDate >  dealProduct.Product2.NR_End_Date__c) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && compareNRENDDateForDigitalProductGroups(schedules.ScheduleDate, mapDealProdWrapperProductGroup.get(dealProduct.Id))))&&
                            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) && objTarget.Calc_Start_Date__c  >= gStartDate && schedules.ScheduleDate >=  objTarget.Calc_Start_Date__c  &&
                            schedules.ScheduleDate <= objTarget.Calc_End_Date__c) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && compareTheStreetDate(schedules.ScheduleDate, objTarget, mapDealProdWrapperProductGroup.get(dealProduct.Id))))) {
                            if (objTarget.Actual_Revenue__c == null) 
                                objTarget.Actual_Revenue__c = 0;
                            actual += schedules.Revenue;
                            objTarget.Actual_Revenue__c = actual;
                        }  */
                    }        
                }
            
        }
        for (Deal_Product_Group__c dealProductGroup : getHighLevelDealProductGroups(objTarget)) {
            /*System.debug('=====> INSIDE High Level Loop');
            System.debug('====> dealProductGroup.Opportunity__r.RecordTypeId: ' + dealProductGroup.Opportunity__r.RecordTypeId);
            System.debug('====> CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL: ' + CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL);
            System.debug('===> objTarget.Account__c: '  + objTarget.Account__c);            
            System.debug('====> dealProductGroup.Opportunity__r.AccountId: ' + dealProductGroup.Opportunity__r.AccountId);
            System.debug('!@!@!@!@ objTarget.Calc_Start_Date__c: '  +objTarget.Calc_Start_Date__c);
            System.debug('#$#$#$#$#$ dealProductGroup.Opportunity__r.Start_Date__c:'  + dealProductGroup.Opportunity__r.Start_Date__c);
            System.debug('%$%$%$%$%$% objTarget.Calc_End_Date__c: ' + objTarget.Calc_End_Date__c);
            System.debug('@!#!#!#!#! dealProductGroup.Opportunity__r.Start_Date__c : ' + dealProductGroup.Opportunity__r.Start_Date__c);*/

            if (dealProductGroup != null && dealProductGroup.Opportunity__c != null &&
                objTarget.Calc_Start_Date__c != null && dealProductGroup.Opportunity__r.Start_Date__c != null && objTarget.Calc_Start_Date__c <= dealProductGroup.Opportunity__r.Start_Date__c &&
                objTarget.Calc_End_Date__c != null && dealProductGroup.Opportunity__r.Start_Date__c != null && objTarget.Calc_End_Date__c >= dealProductGroup.Opportunity__r.Start_Date__c
            ) {
                if (objTarget.High_Level__c == null) {
                    objTarget.High_Level__c =0;
                }
                if (dealProductGroup.Revenue__c != null && dealProductGroup.Revenue__c != 0){
                    highLevel += dealProductGroup.Revenue__c;
                    objTarget.High_Level__c = highLevel;
                }
            }
        }  
        return objTarget;
    }  

    private boolean compareNRENDDateForDigitalProductGroups(Date dealProductScheduleDate, CRM_DataObjects.DealProdWrapper dw){
        boolean bReturn = false;
        
        if (dealProductScheduleDate < dw.productNREndDate){
            //System.debug('@@@ 5');
            bReturn = true;     
        }
        return bReturn;
    }   
    
    private Map<Id, CRM_DataObjects.DealProdWrapper> prepareDealProductWrapperMap(List<OpportunityLineItem> lstDealproductsOfGroups){
    
        Map<Id, CRM_DataObjects.DealProdWrapper> mapDealProdWrapper = new Map<Id, CRM_DataObjects.DealProdWrapper>();       
        for(OpportunityLineItem dealProduct: lstDealproductsOfGroups) {
            CRM_DataObjects.DealProdWrapper dw = new CRM_DataObjects.DealProdWrapper();
            dw.dealId = dealProduct.OpportunityId;
            dw.dealCurrencyCode = dealProduct.Opportunity.CurrencyIsoCode;
            dw.pricebookId = dealProduct.Opportunity.Pricebook2Id;
            dw.productId = dealProduct.Product2Id;
            dw.productRecTypeId = dealProduct.Product2.RecordTypeId;
            mapDealProdWrapper.put(dealProduct.Id, dw);
        }
        
        return mapDealProdWrapper;          
    }
    
    
    /*private boolean compareTheStreetDate(OpportunityLineItem dealProduct, Date dateToCompareWith, Target__c objTarget){
        Date endDate;
        Date startDate;
        boolean bTargetWithinRange = false;
        gStartDate =  getStartDate();
        
        System.debug('@#@#@#@# INSIDE compareTheStreetDate');
        
        if (objTarget != null){
            if (objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_PRODUCT && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.Start_Date__c != null){            
                endDate = dealProduct.Pricebook_Entry_Period__r.Start_Date__c + 56;
                startDate = dealProduct.Pricebook_Entry_Period__r.Start_Date__c;
            }else if (objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_GROUP){
                endDate = objTarget.End_Date__c;
                startDate = objTarget.StartDate__c;
            }else if (objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_BUNDLE && objTarget.Bundle__c != null){
                endDate = objTarget.Bundle__r.End_Date__c;
                startDate = objTarget.Bundle__r.Start_Date__c;
            }
            
            System.debug('@#@#@#@# Condition 1]    dateToCompareWith <= endDate: ' + (dateToCompareWith <= endDate));
            System.debug('@#@#@#@# Condition 2]    dateToCompareWith >= startDate: ' + (dateToCompareWith >= startDate));
            System.debug('$%$%$%$% Condition 3]    startDate >= gStartDate: ' + (startDate >= gStartDate));
            
            if (dateToCompareWith != null && endDate != null && startDate != null && dateToCompareWith <= endDate && dateToCompareWith >= startDate && startDate >= gStartDate){
                System.debug('@@@ 6');
                bTargetWithinRange = true;
            }
        }
        return bTargetWithinRange;
    }*/

    
    /**
    *  Use for Calculating the values retrieved from the Deal Products, for corresponding fields of Target object (Approved, Planned, Confirmed)
    *       For Bundle Record Type Of Target
    *  @name setValuesForTargetFromBundles
    *  @param objTarget - Target Object
    *  @return objTarget - Target Object Fields
    */
    private Target__c setValuesForTargetFromBundles (Target__c objTarget) {
        String ForecastCategoryName;
        Decimal approved = 0;
        Decimal planned = 0;
        Decimal confirmed = 0;
        Decimal actual = 0;
        Decimal noQuantityRevenue = 0;
        try {
            List<OpportunityLineItem> lstDealproductsOfBundles = mapDealProductsForBundles.get(objTarget.Bundle__c);
            if(lstDealproductsOfBundles != null) 
            for(OpportunityLineItem dealProduct: lstDealproductsOfBundles) {
                Opportunity deal = dealProduct.opportunity;
                ForecastCategoryName = deal.ForecastCategoryName;
                if(dealProduct != null && (dealProduct.OpportunityLineItemSchedules == null  || dealProduct.OpportunityLineItemSchedules.size() == 0)) {
                    setNoQuantitiesTarget(objTarget, dealProduct, deal);
                }
                for(OpportunityLineItemSchedule schedules :(List<OpportunityLineItemSchedule>)dealProduct.OpportunityLineItemSchedules){
                    if( (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) && 
                        conditionsForProductsGroupsAndBundlesForNormalDeals(objTarget, dealProduct, schedules, deal) && schedules.Revenue != null){
                        if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED) {
                            if (objTarget.Approved__c == null) 
                                objTarget.Approved__c =0;
                            approved += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                           objTarget.Approved__c = approved;
                        
                        } if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED) {
                            if (objTarget.Planned__c == null) 
                                objTarget.Planned__c =0;
                            Planned += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                            objTarget.Planned__c = Planned;
                          
                        } if(ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED) {
                            //System.debug('**** schedules: ' + schedules);
                            
                            if (objTarget.Confirmed__c == null) 
                                objTarget.Confirmed__c =0;                          
                            confirmed += calculatingRollUp(schedules.Revenue, dealProduct.Returns__c);
                            objTarget.Confirmed__c = confirmed;
                        }
                    } /*else if(deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_ACTUALS && 
                                conditionsForActualsForBundlesAndProducts(objTarget, dealProduct, schedules, deal)) {
                            if (objTarget.Actual_Revenue__c == null) 
                                objTarget.Actual_Revenue__c =0;
                            actual += schedules.Revenue;
                            objTarget.Actual_Revenue__c = actual;
                    }*/
                }
            }
        } catch(exception e) {
        throw e;
        }
        return objTarget;
    }
    
  
    /**
    *  Filters and conditions used for Record type "Product" of Target Object
    *  @name conditionsForProducts
    *  @param objTarget, dealProduct, schedules, deal
    */
    private Boolean conditionsForProducts(Target__c objTarget, OpportunityLineItem dealProduct, OpportunityLineItemSchedule schedules, Opportunity deal){
        gStartDate =  getStartDate();

        if(
            //dealProduct.Returns__c != null  &&        // This check has been removed upon urgent changed on an email 'Rollup Target Logic Change (Returns)'
            //Condition Modifed as per Defect 3760. Earlier (schedules.ScheduleDate <=  dealProduct.Pricebook_Entry_Period__r.End_Date__c) , Now (schedules.ScheduleDate >=  dealProduct.Pricebook_Entry_Period__r.Start_Date__c)
            
            objTarget.Account__c == deal.AccountId &&   
            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2)&& schedules.ScheduleDate <=  dealProduct.Product2.NR_End_Date__c) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.End_Date__c != null && schedules.ScheduleDate >=  dealProduct.Pricebook_Entry_Period__r.Start_Date__c)) &&
            (objTarget.Calc_Start_Date__c  >= gStartDate  && schedules.ScheduleDate >=  objTarget.Calc_Start_Date__c  &&
            schedules.ScheduleDate <= objTarget.Calc_End_Date__c)
        ){
            return true;
        }
        return false;
    }
    
    /**
    *  Filters and conditions used for calculation of Actual revenue, where Record type is "Product" And "Bundle"  of Target Object to reuse the code
    *  @name conditionsForActualsForBundlesAndProducts
    *  @param objTarget, dealProduct, schedules, deal
    */
    /*
    private Boolean conditionsForActualsForBundlesAndProducts(Target__c objTarget, OpportunityLineItem dealProduct, 
                                                                OpportunityLineItemSchedule schedules, Opportunity deal){
        
        gStartDate =  getStartDate();
        System.debug('gStartDate conditionsForActualsForBundlesAndProducts: ' + gStartDate);
        if(schedules != null && 
            schedules.Revenue != null &&
            objTarget.Account__c == deal.AccountId &&
            //schedules.ScheduleDate >=  objTarget.Calc_Start_Date__c  &&
            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) && schedules.ScheduleDate >=  objTarget.Calc_Start_Date__c && objTarget.Calc_Start_Date__c  >= gStartDate  && schedules.ScheduleDate <= objTarget.Calc_End_Date__c &&  
            schedules.ScheduleDate <=  dealProduct.Product2.NR_End_Date__c) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && compareTheStreetDate(dealProduct, schedules.ScheduleDate, objTarget) && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.End_Date__c != null && schedules.ScheduleDate <= dealProduct.Pricebook_Entry_Period__r.End_Date__c ))) {            
            System.debug('@@@ 2');
            return true;
        }
        return false;
    }*/
  
  
    /*private boolean compareNREndDateForDigitalForActualsBundlesAndProducts(Date dateToCompareWith, Map<Id, CRM_DataObjects.DealProdWrapper> mapDealProdWrapperProduct, Map<Id, CRM_DataObjects.DealProdWrapper> mapDealProdWrapperBundle, Id id){
        CRM_DataObjects.DealProdWrapper wrapperBundle = new CRM_DataObjects.DealProdWrapper();
        CRM_DataObjects.DealProdWrapper wrapperProduct = new CRM_DataObjects.DealProdWrapper();
        
        if (mapDealProdWrapperProduct != null && mapDealProdWrapperProduct.containsKey(id) && mapDealProdWrapperProduct.get(id) != null)
            wrapperProduct = mapDealProdWrapperProduct.get(id);
        if (mapDealProdWrapperBundle != null && mapDealProdWrapperBundle.containsKey(id) && mapDealProdWrapperBundle.get(id) != null)
            wrapperBundle = mapDealProdWrapperBundle.get(id);
        
        boolean bReturn = false;
        
        if (wrapperProduct != null && wrapperProduct.productNREndDate != null && dateToCompareWith != null && dateToCompareWith <= wrapperProduct.productNREndDate){
            System.debug('@@@ 8');
            bReturn = true;
        }else if(wrapperBundle != null && wrapperBundle.productNREndDate != null && dateToCompareWith != null && dateToCompareWith <= wrapperBundle.productNREndDate){
            System.debug('@@@ 9');
            bReturn = true;
        }
        
        return bReturn;
    }*/
  
  
    /**
    *  Filters and conditions used for calculation of revenue, where Record type is "Product Group" And "Bundle"  of Target Object
    *  @name conditionsForProductsGroupsAndBundlesForNormalDeals
    *  @param objTarget, dealProduct, schedules, deal
    */
    private Boolean conditionsForProductsGroupsAndBundlesForNormalDeals(Target__c objTarget, OpportunityLineItem dealProduct, 
                                                                        OpportunityLineItemSchedule schedules, Opportunity deal
    ){
        gStartDate =  getStartDate();
        if(schedules != null &&
            //dealProduct.Returns__c != null  &&        // This check has been removed upon urgent changed on an email 'Rollup Target Logic Change (Returns)'
            objTarget.Account__c == deal.AccountId &&   
            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) 
            /*&& schedules.ScheduleDate >  dealProduct.Product2.NR_End_Date__c) */
            && 
               (schedules.ScheduleDate >  dealProduct.Product2.NR_End_Date__c && objTarget.RecordTypeId != CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR)
                 || (schedules.ScheduleDate <=  dealProduct.Product2.NR_End_Date__c && objTarget.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR))|| (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.End_Date__c != null && schedules.ScheduleDate >  dealProduct.Pricebook_Entry_Period__r.End_Date__c)) &&
            (objTarget.Calc_Start_Date__c  >= gStartDate  && schedules.ScheduleDate >=  objTarget.Calc_Start_Date__c  &&
            schedules.ScheduleDate <= objTarget.Calc_End_Date__c)
        ) {
            return true;
        }
        return false;
    }    

    /**
    *  Filters and conditions used for calculation of Actual revenue, for No Quantity Schedules 
    *  @name conditionsForNoQuantitySchedules
    *  @param objTarget, dealProduct, schedules, deal
    */
    private Boolean conditionsForNoQuantitySchedules(Target__c objTarget, OpportunityLineItem dealProduct, Opportunity deal){
    
        gStartDate =  getStartDate();
        if( dealProduct.Actual_Revenue__c != null && 
            objTarget.Account__c == deal.AccountId &&
            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) && dealProduct.Product2.NR_End_Date__c != null) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.End_Date__c != null)) &&
            (objTarget.Calc_Start_Date__c  >= gStartDate  && deal.Start_Date__c >=  objTarget.Calc_Start_Date__c &&
            deal.Start_Date__c <= objTarget.Calc_End_Date__c)
        ) {
            return true;
        }
        return false;
    }    
    
    /**
    *  To reuse the calculations occuring repetitively in a code
    *  @name calculatingRollUp
    *  @param Quantity
    *  @param Price
    *  @param Returns
    *  @return Quantity - Return the Quantity after the calculations
    */
    private Decimal calculatingRollUp(Decimal Revenue, Decimal Returns) {
        //return Revenue * (1 - (Returns / 100));       // This check has been removed upon urgent changed on an email 'Rollup Target Logic Change (Returns)'
        return Revenue;    
    }
    
    private String getProductType(OpportunityLineItem dealProduct) {
        //if(CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2)) 
            //return dealProduct.Product2.Product_Type__c;
        //else        
        return dealProduct.NR__c?'NR':'LB';
    }
    
    
    private String getDigitalProductType(Map<Id, CRM_DataObjects.DealProdWrapper> mapDealProdWrapper, Id dealProductId){
        String strReturn = '';
        System.debug('@#@#@#@#@#@# INSIDE getDigitalProductType');       

        CRM_DataObjects.DealProdWrapper dw = mapDealProdWrapper.get(dealProductId);
        System.debug('@#@#@#@#@#@#@ dw.productStreetDate : ' + dw.productStreetDate);
        System.debug('@#@#@#@#@#@#@ dw.productNREndDate: ' + dw.productNREndDate);        
        if (dw != null && dw.productStreetDate != null && dw.productNREndDate != null){
            if (dw.productStreetDate <= System.Today() && System.Today() <= dw.productNREndDate)
                strReturn = CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE;
            else
                strReturn = CRM_AppConstants.PRODUCT_TYPE_CATALOG;
        }
        return strReturn;           
    }
     
    
    private void setNoQuantitiesTarget(Target__c objTarget, OpportunityLineItem dealProduct, Opportunity deal) {
        Decimal noQuantityRevenue = 0;        
        String productType = getProductType(dealProduct);
        //System.debug('====> compareNREndDateForDigitalProductsForNoQtyTargetsCase1(deal.Start_Date__c, mapDealProdWrapperBundle, mapDealProdWrapperProduct, mapDealProdWrapperProductGroup, dealProduct.Id)' + compareNREndDateForDigitalProductsForNoQtyTargetsCase1(deal.Start_Date__c, mapDealProdWrapperBundle, mapDealProdWrapperProduct, mapDealProdWrapperProductGroup, dealProduct.Id));

        if((deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) && 
            conditionsForNoQuantitySchedules(objTarget, dealProduct, deal) &&
            (productType == CRM_AppConstants.PRODUCT_TYPE_CATALOG) && 
            ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) && deal.Start_Date__c >=  dealProduct.Product2.NR_End_Date__c) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.End_Date__c != null && deal.Start_Date__c >=  dealProduct.Pricebook_Entry_Period__r.End_Date__c ))){
            if(deal.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED){   
                if (objTarget.Approved__c == null)
                    objTarget.Approved__c = 0;
                noQuantityRevenue += dealProduct.Actual_Revenue__c;
                objTarget.Approved__c = noQuantityRevenue;
            }
            if(deal.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED){ 
                if (objTarget.Planned__c == null)
                    objTarget.Planned__c = 0;
                noQuantityRevenue += dealProduct.Actual_Revenue__c;                          
                objTarget.Planned__c = noQuantityRevenue;
            }
            if(deal.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED){    
                if (objTarget.Confirmed__c == null)
                    objTarget.Confirmed__c = 0;
                noQuantityRevenue += dealProduct.Actual_Revenue__c;        
                objTarget.Confirmed__c = noQuantityRevenue;
            }
        } else if((deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) &&
                    conditionsForNoQuantitySchedules(objTarget, dealProduct, deal) &&
                    productType == CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE && 
                    ((CRM_ApplicationUtility.isPhysicalProduct(dealProduct.Product2) && deal.Start_Date__c <=  dealProduct.Product2.NR_End_Date__c) || (CRM_ApplicationUtility.isDigitalProduct(dealProduct.Product2) && dealProduct.Pricebook_Entry_Period__c != null && dealProduct.Pricebook_Entry_Period__r.End_Date__c != null && deal.Start_Date__c <=  dealProduct.Pricebook_Entry_Period__r.End_Date__c))){
            if(deal.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED){   
                if (objTarget.Approved__c == null)
                    objTarget.Approved__c = 0;
                noQuantityRevenue += dealProduct.Actual_Revenue__c;
                objTarget.Approved__c = noQuantityRevenue;
            }
            if(deal.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED){    
                if (objTarget.Planned__c == null)
                    objTarget.Planned__c = 0;
                noQuantityRevenue += dealProduct.Actual_Revenue__c;                          
                objTarget.Planned__c = noQuantityRevenue;
            }
            if(deal.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED){    
                if (objTarget.Confirmed__c == null)
                    objTarget.Confirmed__c = 0;
                noQuantityRevenue += dealProduct.Actual_Revenue__c;        
                objTarget.Confirmed__c = noQuantityRevenue;
            }
        }
    }    
    
    /*
    *  This method will return valid opportunityLineItems ID for Target of type product
    *  @name: returnValidLineItemForProductGroup
    *  @param: Target Object, Set of ProductGroupIds, NR Product or not
    *  @return: Set<Id> 
    */
    private Set<Id> returnValidLineItemForProductGroup(Target__c objTarget, Set<Id> setProductGroupIds, Boolean valueOfNR)
    {
        Set<Id> setOppLineItemIds = new Set<Id>();
        //Fetching Schedules For Physical Product
        /*List<OpportunityLineItemSchedule> phyProductSchedules = [SELECT OpportunityLineItemId FROM OpportunityLineItemSchedule WHERE OpportunityLineItem.Product2.RecordTypeId = :CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL AND 
                                                                 OpportunityLineItem.Opportunity.AccountId = :objTarget.Account__c AND OpportunityLineItem.Product2.Product_Group__c IN :setProductGroupIds AND 
                                                                 ScheduleDate >= :objTarget.Calc_Start_Date__c AND ScheduleDate <= :objTarget.Calc_End_Date__c AND OpportunityLineItem.NR__c =: valueOfNR];
        */
        System.debug('In function objTarget===============>'+objTarget);
        System.debug('In function setProductGroupIds===============>'+ setProductGroupIds);
        System.debug('In function valueOfNR===============>'+valueOfNR);
        
        //Fetching Schedules For Digital Product
        List<OpportunityLineItemSchedule> productSchedules = [SELECT OpportunityLineItemId FROM OpportunityLineItemSchedule WHERE  
                                                              OpportunityLineItem.Opportunity.AccountId = :objTarget.Account__c AND OpportunityLineItem.Product2.Product_Group__c IN :setProductGroupIds AND
                                                              ((OpportunityLineItem.Product2.RecordTypeId = :CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL AND OpportunityLineItem.Pricebook_Entry_Period__c != null AND OpportunityLineItem.Pricebook_Entry_Period__r.End_Date__c != null) OR  OpportunityLineItem.Product2.RecordTypeId = :CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) AND 
                                                              ScheduleDate >= :objTarget.Calc_Start_Date__c AND ScheduleDate <= :objTarget.Calc_End_Date__c AND OpportunityLineItem.NR__c =: valueOfNR];
        
        for(OpportunityLineItemSchedule oppSchedule: productSchedules ){
            setOppLineItemIds.add(oppSchedule.OpportunityLineItemId);
        }
        
       system.debug('setOppLineItemIds=============>'+setOppLineItemIds);
        
        //Return all the opportunityLineItem Ids
        return setOppLineItemIds;
    }
    
    
    
    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public void logAnException(Exception ex, Id recordId){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null)
            errorLogInstance.recordId = recordId;
        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_TARGET;
        errorLogInstance.className = 'CRM_BatchTargetRollUp';
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();
        listErrorLog.add(errorLogInstance);
    }
    
    /**
    *  Finish Method of Batch
    *  @name finish
    *  @returning results for processed records by batch and sending mail to owner
    */
    global void finish(Database.BatchableContext BC) {
        List<Database.SaveResult> saveAccountResults = new List<Database.SaveResult>();
        
        if (processedTargetAccountIds != null && processedTargetAccountIds.size() > 0){
                List<Account> lstAcct = [SELECT Id, scheduleRevenueChanged__c FROM Account WHERE Id IN: processedTargetAccountIds AND Id NOT IN: unprocessedTargetAccountIds]; 
                if (lstAcct != null && lstAcct.size() > 0){
                    for (Account objAcct: lstAcct){
                        objAcct.scheduleRevenueChanged__c = false;
                    }
                    System.debug('Account List to be updated:'+ lstAcct);
                    saveAccountResults = Database.update(lstAcct,false);
                }          
            }
            //Refactoring Code: #159 Log an exception for unprocessed Account's
            List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
            for(Database.SaveResult sr: saveAccountResults){        
                if (!sr.isSuccess()){
                    for (Database.Error err : sr.getErrors()) { 
                        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
                        errorLogInstance.recordId = sr.getId();
                        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_TARGET;
                        errorLogInstance.className = 'CRM_BatchTargetRollUp';
                        errorLogInstance.errorMessage += err.getMessage();
                        listErrorLog.add(errorLogInstance);
                    }    
                }   
            }           
            
        CRM_ErrorLogger.logError(listErrorLog);
        
        /*AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, 
                            CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :BC.getJobId()];  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        String[] toAddresses = new String[] {a.CreatedBy.Email};  
        mail.setToAddresses(toAddresses);       
        mail.setSubject('"Roll Up Target Revenues" BatchJob Status: ' + a.Status);  
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +  
                                        ' batches with '+ a.NumberOfErrors + ' failures. Message: ' + a.ExtendedStatus);  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  */
        BatchStatusNotification.sendBatchStatusMail(BC,'Roll Up Target Revenues');  
    }
}