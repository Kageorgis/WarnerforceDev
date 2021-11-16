/*============================================================================================================
   @Author: Dilip Mistry, Pradeep Singh
   @name CRM_BatchTargetRollUp_V2
   @CreateDate 14 November 2016
   @Description: Batch Class to roll up the revenue fields of Target Object (Approved, Planned, Confirmed, 
                 Actuals, High Level)
   @Version 2.0
===============================================================================================================*/
public class CRM_BatchTargetRollUp_V2 implements database.batchable<sObject>, database.Stateful {
    /* In first batch only product targets will be processed with a larger batch size say 50
     * In second batch run other types of targets like Bundle, ProductGroup, MidTermNR will be processed with slightly smaller batch size say 10
     */
    public Boolean IS_FIRST_RUN; 
    public Set<Id> setProcessedAccountIds;
    public Set<Id> setFailedAccountIds;
    public String firstBatchState;
    public Set<id> setHotSellerDealProductIds;
    
    /*-----------------------------------------------------------------*/
    /*                  START METHOD 
    /*-----------------------------------------------------------------*/
    public Database.queryLocator start(Database.BatchableContext BC) {
        if(IS_FIRST_RUN != false) {
            IS_FIRST_RUN = true;
            setProcessedAccountIds = new Set<Id>();
            setFailedAccountIds = new Set<Id>();
            setHotSellerDealProductIds = new Set<Id>();
        }
        String query = 'SELECT Id FROM Target__c WHERE Account__r.scheduleRevenueChanged__c = TRUE ';
        
        /* Add filter on calc_end_date */
        Date startDate;
        if(TargetLimitter__c.getOrgDefaults() != null && TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c != null) {
            startDate = System.Today().addMonths((Integer)(0 - TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c));
        }
        else {
            startDate = System.Today().addMonths((Integer)(0 - 6));
        }
        query += ' AND Calc_End_Date__c >= :startDate'; 
        
        /* add filter on record type */
        Set<Id> setProductTargetsRecTypeIds = new Set<Id>{CRM_RecordTypeUtil.RT_TARGET_PRODUCT};
        query +=  ' AND ' + (IS_FIRST_RUN ? 'RecordTypeId IN :setProductTargetsRecTypeIds' : 'RecordTypeId NOT IN :setProductTargetsRecTypeIds ');
        
        System.debug('EXECUTING START SOQL.....' + query
                + '\n WHERE var:startDate is --> '+ startDate
                + '\n & var:setProductTargetsRecTypeIds is --> '+ setProductTargetsRecTypeIds
            );
        
        return Database.getQueryLocator(query);
    }
    
    /*-----------------------------------------------------------------*/
    /*                  EXECUTE METHOD 
    /*-----------------------------------------------------------------*/
    public void execute(Database.BatchableContext BC, List<target__c> scopeTarget) {
        List<Target__c> targets = [SELECT Id, RecordType.Name, Calc_Start_Date__c, Calc_End_Date__c,
                                            Account__c, Product__c, Product_Group__c, Bundle__c, Hot_Seller__c,Forecast_GRLR__c, //US#973
                                            Approved__c, Confirmed__c, High_Level__c, Planned__c, Account__r.Sales_Organization__c, Account__r.Digital_Country_Code__c
                                   FROM Target__c
                                   WHERE Id IN :scopeTarget];
        
        for (Target__c t : targets) {
            calculateTarget(t);
        }
        
        
        // Update the targets
        List<Database.SaveResult> updateResultTargets = Database.update(targets, false);
        
        logTargetSaveErrors(updateResultTargets, targets);
    }
    
    private void calculateTarget(Target__c target) {
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        List<Deal_Product_Group__c> dealProductGroups = new List<Deal_Product_Group__c>();
        Map<string,decimal> mapOfOLIRevenue = new Map<string,decimal>();  // added as a part of US#973
        // Reset values
        target.Planned__c = 0;
        target.Approved__c = 0;
        target.Confirmed__c = 0;
        target.High_Level__c = 0;
        target.Forecast_GRLR__c = 0; // added as a part of US#973
        //target.Target__c = 0;
        
        Boolean targetFlag = true; // Flag to set target__c equals to zero only for first time
        
        // US#493 Change (added Returns_Forecast__c & Billing_Adjustment_Forecast__c for rollup)
        target.Returns_Forecast__c = 0;
        target.Billing_Adjustment_Forecast__c = 0;
            
        /* New Release (Product Lvl) */
        if (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_PRODUCT) {
            // US-620 change: Added flag to include catalog products in Target calculation for Hot Seller
            Boolean NROnlyFlag = (target.Hot_Seller__c == true ? false : true);
             
            schedules = [SELECT ScheduleDate, OpportunityLineItem.Opportunity.ForecastCategoryName, Revenue, OpportunityLineItem.Opportunity.RecordTypeId,
                         OpportunityLineItemId, OpportunityLineItem.Target_Revenue__c, OpportunityLineItem.Product2Id, OpportunityLineItem.Product2.RecordTypeId, OpportunityLineItem.Product2.NR_End_Date__c,
                         OpportunityLineItem.Pricebook_Entry_Period__c, OpportunityLineItem.Pricebook_Entry_Period__r.Start_Date__c, OpportunityLineItem.Pricebook_Entry_Period__r.End_Date__c
                         ,OpportunityLineItem.NR__c,OpportunityLineItem.Returns__c,OpportunityLineItem.Gross_Revenues_less_Returns__c,OpportunityLineItem.Estimated_Revenue_Formula__c  // US#973 US-620 Change (Hot Seller)
                         FROM OpportunityLineItemSchedule
                         WHERE OpportunityLineItem.Product2Id = :target.Product__c
                         AND OpportunityLineItem.Opportunity.AccountId = :target.Account__c
                         AND OpportunityLineItem.Opportunity.RecordTypeId IN (:CRM_RecordTypeUtil.RT_DEAL_PHYSICAL, :CRM_RecordTypeUtil.RT_DEAL_DIGITAL)
                         AND ScheduleDate >= :target.Calc_Start_Date__c
                         AND ScheduleDate <= :target.Calc_End_Date__c
                         AND (OpportunityLineItem.NR__c = TRUE OR OpportunityLineItem.NR__c =:NROnlyFlag )
                         AND Description != :CRM_AppConstants.SCHEDULE_ZERO];
        }
        /* Catalog (by Product Group) */
        else if (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_GROUP) {
            schedules = [SELECT ScheduleDate, OpportunityLineItem.Opportunity.ForecastCategoryName, Revenue, OpportunityLineItem.Opportunity.RecordTypeId,
                         OpportunityLineItemId, OpportunityLineItem.Target_Revenue__c, OpportunityLineItem.Product2Id, OpportunityLineItem.Product2.RecordTypeId, OpportunityLineItem.Product2.NR_End_Date__c,
                         OpportunityLineItem.Pricebook_Entry_Period__c, OpportunityLineItem.Pricebook_Entry_Period__r.Start_Date__c, OpportunityLineItem.Pricebook_Entry_Period__r.End_Date__c,OpportunityLineItem.Returns__c,OpportunityLineItem.Gross_Revenues_less_Returns__c,OpportunityLineItem.Estimated_Revenue_Formula__c  // US#973
                         FROM OpportunityLineItemSchedule
                         WHERE OpportunityLineItem.Product2.Product_Group__c = :target.Product_Group__c
                         AND OpportunityLineItem.Opportunity.AccountId = :target.Account__c
                         AND (OpportunityLineItem.Opportunity.RecordTypeId IN (:CRM_RecordTypeUtil.RT_DEAL_PHYSICAL, :CRM_RecordTypeUtil.RT_DEAL_DIGITAL)
                              OR (OpportunityLineItem.Opportunity.RecordTypeId IN (:CRM_RecordTypeUtil.RT_Physical_DFI_Deal, :CRM_RecordTypeUtil.RT_Physical_POS_Deal, :CRM_RecordTypeUtil.RT_Physical_Planning_Deal)
                                  AND (OpportunityLineItem.Opportunity.Sales_Organisation__c IN (:CRM_AppConstants.TERRITORY_SDS_US_CODE, :CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)))) // Added record types as part of US #W-017615
                         AND ScheduleDate >= :target.Calc_Start_Date__c
                         AND ScheduleDate <= :target.Calc_End_Date__c
                         AND OpportunityLineItem.NR__c = FALSE
                         AND Description != :CRM_AppConstants.SCHEDULE_ZERO];
            
            // US#493 Change (added Returns_Forecast__c & Billing_Adjustment_Forecast__c for rollup)
            dealProductGroups = [SELECT Opportunity__r.ForecastCategoryName, Revenue__c, Billing_Adjustment_Forecast__c, Returns_Forecast__c
                                 FROM Deal_Product_Group__c
                                 WHERE Product_Group__c = :target.Product_Group__c
                                 AND Opportunity__r.AccountId = :target.Account__c
                                 AND Opportunity__r.Start_Date__c >= :target.Calc_Start_Date__c
                                 AND Opportunity__r.Start_Date__c <= :target.Calc_End_Date__c];
        }
        /* New Release (by Product Group) */
        else if (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR) {
            schedules = [SELECT ScheduleDate, OpportunityLineItem.Opportunity.ForecastCategoryName, Revenue, OpportunityLineItem.Opportunity.RecordTypeId,
                         OpportunityLineItemId, OpportunityLineItem.Target_Revenue__c, OpportunityLineItem.Product2Id, OpportunityLineItem.Product2.RecordTypeId, OpportunityLineItem.Product2.NR_End_Date__c,
                         OpportunityLineItem.Pricebook_Entry_Period__c, OpportunityLineItem.Pricebook_Entry_Period__r.Start_Date__c, OpportunityLineItem.Pricebook_Entry_Period__r.End_Date__c,OpportunityLineItem.Returns__c,OpportunityLineItem.Gross_Revenues_less_Returns__c,OpportunityLineItem.Estimated_Revenue_Formula__c  // US#973
                         FROM OpportunityLineItemSchedule
                         WHERE OpportunityLineItem.Product2.Product_Group__c = :target.Product_Group__c
                         AND OpportunityLineItem.Opportunity.AccountId = :target.Account__c
                         AND OpportunityLineItem.Opportunity.RecordTypeId IN (:CRM_RecordTypeUtil.RT_DEAL_PHYSICAL, :CRM_RecordTypeUtil.RT_DEAL_DIGITAL)
                         AND ScheduleDate >= :target.Calc_Start_Date__c
                         AND ScheduleDate <= :target.Calc_End_Date__c
                         AND OpportunityLineItem.NR__c = TRUE
                         AND Description != :CRM_AppConstants.SCHEDULE_ZERO];
        }
        /* Bundle */
        else if (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_BUNDLE) {
            List<Bundle_Product__c> bps = [SELECT Product__c FROM Bundle_Product__c WHERE Bundle__c = :target.Bundle__c];
            List<Id> products = new List<Id>();
            
            for (Bundle_Product__c bp : bps)
                products.add(bp.Product__c);
            
            schedules = [SELECT ScheduleDate, OpportunityLineItem.Opportunity.ForecastCategoryName, Revenue, OpportunityLineItem.Opportunity.RecordTypeId,
                         OpportunityLineItemId, OpportunityLineItem.Target_Revenue__c, OpportunityLineItem.Product2Id, OpportunityLineItem.Product2.RecordTypeId, OpportunityLineItem.Product2.NR_End_Date__c,
                         OpportunityLineItem.Pricebook_Entry_Period__c, OpportunityLineItem.Pricebook_Entry_Period__r.Start_Date__c, OpportunityLineItem.Pricebook_Entry_Period__r.End_Date__c,OpportunityLineItem.Returns__c,OpportunityLineItem.Gross_Revenues_less_Returns__c,OpportunityLineItem.Estimated_Revenue_Formula__c  // US#973
                         FROM OpportunityLineItemSchedule
                         WHERE OpportunityLineItem.Product2Id IN :products
                         AND OpportunityLineItem.Opportunity.AccountId = :target.Account__c
                         AND OpportunityLineItem.Opportunity.RecordTypeId IN (:CRM_RecordTypeUtil.RT_DEAL_PHYSICAL, :CRM_RecordTypeUtil.RT_DEAL_DIGITAL)
                         AND ScheduleDate >= :target.Calc_Start_Date__c
                         AND ScheduleDate <= :target.Calc_End_Date__c
                         AND Description != :CRM_AppConstants.SCHEDULE_ZERO];
        }

        // Update low level forecasts
        for (OpportunityLineItemSchedule s : schedules) {
            Decimal revenue = s.Revenue != null ? s.Revenue : 0;
            
            //US-620 change: For Hot Seller, Synch the flag on Deal Product
            // If checked on deal product, schedule will not be counted for Group Target 
            if(target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_PRODUCT && target.Hot_Seller__c == true && s.OpportunityLineItem.NR__c != true){
                setHotSellerDealProductIds.add(s.OpportunityLineItemId);
            }
            
            // US-620 change: Flag to exclude hot_seller deal products from rollup in GroupTargets
            Boolean excludeHotSeller = (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_GROUP && setHotSellerDealProductIds.contains(s.OpportunityLineItemId));
            
            // check if product is Physical and schedule_date is less than NR_End_Date of the Product OR
            // if Product is Digital and schedule_date is between Start_Date and End_Date of PBEP    
            
            
            // Eligibility check for Physical Products
            Boolean physicalEligibility = CRM_ApplicationUtility.isPhysicalProduct(s.OpportunityLineItem.Product2);
                    /* -- Commented as part of Defect#4024: Rollup should be just based on NR__c flag with no additional check --
                    && (
                        (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_PRODUCT && (s.ScheduleDate <  s.OpportunityLineItem.Product2.NR_End_Date__c || target.Hot_Seller__c))
                        || (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR && s.ScheduleDate <  s.OpportunityLineItem.Product2.NR_End_Date__c)
                        || (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_GROUP && s.ScheduleDate >=  s.OpportunityLineItem.Product2.NR_End_Date__c) 
                        || (target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_BUNDLE && s.ScheduleDate >=  s.OpportunityLineItem.Product2.NR_End_Date__c)
                    ); */
            
            // Eligibility check for Digital Products
            Boolean digitalEligibility = (CRM_ApplicationUtility.isDigitalProduct(s.OpportunityLineItem.Product2) 
                    && s.OpportunityLineItem.Pricebook_Entry_Period__c != null 
                    && s.OpportunityLineItem.Pricebook_Entry_Period__r.End_Date__c != null 
                    && s.ScheduleDate >=  s.OpportunityLineItem.Pricebook_Entry_Period__r.Start_Date__c ); 
            
            System.debug('physicalEligibility & digitalEligibility --->'+physicalEligibility +' & '+ digitalEligibility);
            Boolean eligibleForRollup = (!excludeHotSeller) && (physicalEligibility || digitalEligibility);
            System.debug('********* schedule ->'+ s.Id + ' is eligibleForRollup ->'+eligibleForRollup);
            
            if(!eligibleForRollup) {
                continue;
            }
            Boolean isJVOrg = false;
            //added as a part of US #W-017615 - start
            if(s.OpportunityLineItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal ||
               s.OpportunityLineItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal ||
               s.OpportunityLineItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_Physical_Planning_Deal) {
                   isJVOrg = true;
            }  //added as a part of US #W-017615 - end
             
            if(!isJVOrg) {
                // added as a part of US#973
                Decimal estimatedRevenue = s.OpportunityLineItem.Estimated_Revenue_Formula__c != null ? s.OpportunityLineItem.Estimated_Revenue_Formula__c : 0;
                Decimal GRLR = s.OpportunityLineItem.Gross_Revenues_less_Returns__c != null ? s.OpportunityLineItem.Gross_Revenues_less_Returns__c : 0;
                
                system.debug('==='+estimatedRevenue);
                system.debug('==='+GRLR);
                system.debug('==='+s.Revenue);
                
                
                if(estimatedRevenue > 0 ){
                    target.Forecast_GRLR__c += ( s.Revenue / estimatedRevenue ) * GRLR;
                }
                
                system.debug('==='+target.GRLR__c);
            }
            // added as a part of US#973
            
            /*
            string oppIdReturn = s.OpportunityLineItemId +'&&' + string.valueOf(estiRevenue) + '&&' +string.valueOf(GRLR);
            if(mapOfOLIRevenue.containsKey(oppIdReturn)){
               decimal temp =  mapOfOLIRevenue.get(oppIdReturn) + s.Revenue;
               mapOfOLIRevenue.put(oppIdReturn,temp);
            }
            else{
                mapOfOLIRevenue.put(oppIdReturn,s.Revenue);
            }
            system.debug('==='+mapOfOLIRevenue);
            // added as a part of US#973
            */
            
            if (s.OpportunityLineItem.Opportunity.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED)
                target.Planned__c += revenue;
            else if (s.OpportunityLineItem.Opportunity.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED)
                target.Approved__c += revenue;
            else if (s.OpportunityLineItem.Opportunity.ForecastCategoryName == CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED)
                target.Confirmed__c += revenue;  
        }
       
       /** Commented as part of US#596 - Logic has been moved to the flow 'Calculate Target Price' ***
       // Update Target Revenue
       if(target.RecordTypeId == CRM_RecordTypeUtil.RT_TARGET_PRODUCT) {
            Set<Id> setDealProductIds = new Set<Id>();
            Decimal promotedPrice;
            
            for (OpportunityLineItemSchedule s : schedules) {
                Boolean isValid = (target.Account__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE 
                        || (s.OpportunityLineItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && target.Account__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                        || (s.OpportunityLineItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && target.Account__r.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE));
                
                if(isValid){
                    if(targetFlag) {
                        target.Target__c = 0;
                        targetFlag = false;      
                    }
                    
                    if(!setDealProductIds.contains(s.OpportunityLineItemId)) {
                        target.Target__c = ((target.Target__c != null ? target.Target__c : 0) + s.OpportunityLineItem.Target_Revenue__c);
                        setDealProductIds.add(s.OpportunityLineItemId);
                    }
                }
            }
       }
       */
       
        // Update high level forecasts
        for(Deal_Product_Group__c dpg : dealProductGroups) {
            target.High_Level__c += (dpg.Revenue__c != null ? dpg.Revenue__c : 0);
            
            // US#493 Change (added Returns_Forecast__c & Billing_Adjustment_Forecast__c for rollup)
            target.Returns_Forecast__c += (dpg.Returns_Forecast__c != null ? dpg.Returns_Forecast__c : 0);
            target.Billing_Adjustment_Forecast__c += (dpg.Billing_Adjustment_Forecast__c != null ? dpg.Billing_Adjustment_Forecast__c : 0);
        }
    }
    
    /* Method to log error during target updates */
    private void logTargetSaveErrors(Database.SaveResult[] updateResultTargets, Target__c[] targets) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        
        // log the errors during updating targets
        for(Integer i= 0; i < updateResultTargets.size(); i++) {
            Database.SaveResult sr = updateResultTargets[i];
            
            if(sr.isSuccess()) {
                setProcessedAccountIds.add(targets[i].Account__c);
            }
            else {
                setFailedAccountIds.add(targets[i].Account__c);
                //Error Logging for Unprocessed Targets  
                for (Database.Error err : sr.getErrors()) {
                    CRM_ErrorLogger.ErrorLog errorLogInstance = getErrorLogRecord(sr, err, targets[i]);
                    listErrorLog.add(errorLogInstance);
                }   
            }
        }
        
        if(!listErrorLog.isEmpty()) {
            CRM_ErrorLogger.logError(listErrorLog);
        }
    }
    
    private CRM_ErrorLogger.ErrorLog getErrorLogRecord(Database.SaveResult sr, Database.Error err, Sobject record) {
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        errorLogInstance.recordId = sr.getId();
        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_TARGET;
        errorLogInstance.className = 'CRM_BatchTargetRollUp_V2';
        errorLogInstance.errorMessage = ('Record ->'+ record.get('Id') +' & Error -> '+ err.getMessage()).left(250);
        errorLogInstance.stackTrace = err.getMessage();
        return errorLogInstance;
    }
    
    /*-----------------------------------------------------------------*/
    /*                  FINISH METHOD 
    /*-----------------------------------------------------------------*/
    public void finish(Database.BatchableContext BC) {
        String current_state = 'Current State.......'
                    + '\n var:IS_FIRST_RUN ----> '+ IS_FIRST_RUN
                    + '\n var:setProcessedAccountIds size ----> '+ setProcessedAccountIds.size()
                    + '\n var:setFailedAccountIds size ----> '+ setFailedAccountIds.size()
                    + '\n var:setHotSellerDealProductIds size ----> '+ setHotSellerDealProductIds.size();
        
        if(firstBatchState == null) { 
            firstBatchState = current_state;
        }
        
        System.debug('firstBatchState---->'+firstBatchState);
        System.debug('current_state  ---->'+current_state);
                     
        if(this.IS_FIRST_RUN == true) {
            CRM_BatchTargetRollUp_V2 batch = new CRM_BatchTargetRollUp_V2();
            batch.IS_FIRST_RUN = false;
            batch.firstBatchState = this.firstBatchState;
            batch.setProcessedAccountIds = this.setProcessedAccountIds;
            batch.setFailedAccountIds = this.setFailedAccountIds;
            batch.setHotSellerDealProductIds = this.setHotSellerDealProductIds;
            
            CRM_Batch_Size__c batchSizeSetting = CRM_Batch_Size__c.getInstance('Target_Rollup_Batch-Other');
            Integer batchSize = batchSizeSetting != null && batchSizeSetting.Batch_Size__c != null ? (Integer) batchSizeSetting.Batch_Size__c : 1;
            database.executeBatch(batch, batchSize);
        }
        else {
            executeFinalActions(BC);
            //START -Added for CRMJV US No. W-017643
            if(system.now().format('E')=='Fri'){
                CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Decay Curve Re-Forcasting Batch');
                Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 500;
                Database.executebatch(new CRMJV_DecayCurveReforcastingBatch(),defaultBatchSize);
            }    
            //END -Added for CRMJV US No.l W-017643
        }
        
    }  
    
    /* method to reset the account flags and send batch completion email */
    private void executeFinalActions(Database.BatchableContext BC) {
        System.debug('Executing final actions.....');
        // Reset RevenueScheduleChange flag on Target
        if(!setProcessedAccountIds.isEmpty()) {
            Account[] listAccountsToReset = new Account[]{};
            
            for(Id accountId : setProcessedAccountIds) {
                if(!setFailedAccountIds.contains(accountId)) {
                    listAccountsToReset.add(new Account(Id=accountId, scheduleRevenueChanged__c = false)); 
                }
            }
            
            if(!listAccountsToReset.isEmpty()) {
                Database.SaveResult[] saveAccountResults = Database.update(listAccountsToReset,false);
                List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                
                // log the errors during updating targets
                for(Integer i= 0; i < saveAccountResults.size(); i++) {
                    Database.SaveResult sr = saveAccountResults[i];
                    
                    if(!sr.isSuccess()) {
                        //Error Logging for Unprocessed Targets  
                        for (Database.Error err : sr.getErrors()) {
                            CRM_ErrorLogger.ErrorLog errorLogInstance = getErrorLogRecord(sr, err, listAccountsToReset[i]);
                            listErrorLog.add(errorLogInstance);
                        }   
                    }
                }
                
                if(!listErrorLog.isEmpty()) {
                    CRM_ErrorLogger.logError(listErrorLog);
                }
            }
        }
        
        // Send the notification email once batch job is finished.
        BatchStatusNotification.sendBatchStatusMail(BC,'Roll Up Target Revenues');  
    }
}