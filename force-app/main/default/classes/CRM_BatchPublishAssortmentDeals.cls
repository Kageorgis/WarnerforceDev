/**
   @Author Cognizant (Dilip Mistry)
   @name CRM_PublishAssortmentsController
   @CreateDate 10 Aug 2016
   @Description Batch job to Create Deals and POS Forecast Items as part of Publish Assortment Logic
   @Version <1.0>
*/
global without sharing class CRM_BatchPublishAssortmentDeals implements Database.Batchable<Sobject>, Database.Stateful {
    global Bundle__c assortment;
    // Key -> Unique Publish Key, Value --> StageName
    global Map<String,String> mapFinalDealsStageChanges = new Map<String,String>();
    global CRM_PublishAssortmentHelper.PublishError[] publishErrors = new CRM_PublishAssortmentHelper.PublishError[]{};
    
    global Assortment_Account__c[] start(Database.BatchableContext BC){
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
        
        return listAllAssortmentAccounts;
    }
    
    global void execute(Database.BatchableContext BC, List<Assortment_Account__c> scope){
        CRM_ApplicationUtility.isPublishAssortmentDealsBatch = true;
        Assortment_Account__c[] listAssortmentAccounts = scope;
        
        Map<String,Opportunity> mapPublishedDeals = new Map<String,Opportunity>();
        Map<String,Opportunity> mapExistingDeals = new Map<String,Opportunity>();
        
        // Create/Update a deal for every assortment account where all assortment products will be added as deal products.
        for(Assortment_Account__c assrtAcc : listAssortmentAccounts) {
            //String uniqueDealKey = assrtAcc.Account__c + '-' + assrtAcc.Assortment__c;
            Boolean hasFERTProducts = CRM_PublishAssortmentHelper.hasFERTProducts(assortment.Bundle_Products__r);
             
            Opportunity deal = CRM_PublishAssortmentHelper.createDealRecord(assortment, assrtAcc, hasFERTProducts);
            deal.Account = assrtAcc.Account__r;
            String uniqueDealKey = deal.UniquePublishKey__c;
            mapPublishedDeals.put(uniqueDealKey, deal);
        }
        
        
        // update the Deal Record Id for published deals
        for(Opportunity opp : [select Id, TotalOpportunityQuantity, Replen__c, High_Level_Target__c, StageName, Hidden_Estimated_Quantity__c, UniquePublishKey__c 
                from Opportunity where UniquePublishKey__c IN: mapPublishedDeals.keySet()]) {
                    
            mapExistingDeals.put(opp.UniquePublishKey__c, opp);
        }
        
        // Update the stage to avoid the following issues:
        // 1) Deal cannot be created in Revised/Committed Stage
        // 2) Deal Products cannot be added on committed deals
        // and instead use two operation First insert with valid stage and then update it to committed
        for(Opportunity deal : mapPublishedDeals.values()) {
            Opportunity existingDeal = mapExistingDeals.get(deal.UniquePublishKey__c);
            Boolean isExistingDeal = existingDeal != null ? true : false;
            
            // Update the record ID and Hidden_Estimated_Quantity__c fields from existing deal record
            if(isExistingDeal) {
                deal.Id = existingDeal.Id;
                deal.Hidden_Estimated_Quantity__c = existingDeal.Hidden_Estimated_Quantity__c;
                // Req#609 : Remove committed / awaiting Approval deals from being updated
                if (
                        !CRM_PublishAssortmentHelper.isPromotionalAssortment(assortment) &&
                        (
                            existingDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED ||
                            existingDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL
                        )
                ) {
                    mapPublishedDeals.remove(existingDeal.UniquePublishKey__c);
                    continue;
                }
            }

            // First revise the stage of deal to add products 
            if(((isExistingDeal && existingDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)
                || (deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)) && CRM_PublishAssortmentHelper.isPromotionalAssortment(assortment)) {
                
                String changedDealStage;
                
                if(isExistingDeal == false && deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                    changedDealStage = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
                }
                else if(isExistingDeal==true) {
                    if(existingDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                        changedDealStage = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                        
                        if(existingDeal.StageName != CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                            changedDealStage = existingDeal.StageName;
                        }
                    } 
                } 
                
                if(changedDealStage != null) {
                    mapFinalDealsStageChanges.put(deal.UniquePublishKey__c, deal.StageName);
                    
                    deal.StageName = changedDealStage;
                } 
            }
            

            // Default Estimated Quantity from High Level Target of an assortment 
            // Update TotalQty on opportunity Only if:
            //      1. deal is a new deal
            //      2. deal is existing but user has not overriden the Estimated Qty yet
            if(!isExistingDeal || 
                (existingDeal.TotalOpportunityQuantity == existingDeal.High_Level_Target__c)) {
                
                deal.TotalOpportunityQuantity = deal.High_Level_Target__c;
            }
        }
        // create/update the deals
        if(!mapPublishedDeals.isEmpty()) {
            Opportunity[] dealsToUpsert = mapPublishedDeals.values();
            Database.UpsertResult[] upsertDealResults = Database.upsert(dealsToUpsert, false);
            logDealUpsertErrors(dealsToUpsert, upsertDealResults);
        }
        
        Map<String,POS_Forecast_Item__c> mapPublishedForecastItems = CRM_PublishAssortmentHelper.createPOSForecastItems(assortment, mapPublishedDeals);
        
        if(!mapPublishedForecastItems.isEmpty() && CRM_PublishAssortmentHelper.isPromotionalAssortment(assortment)) {
            POS_Forecast_Item__c[] forecastItemsToUpsert = mapPublishedForecastItems.values();
            Database.UpsertResult[] upsertResults = Database.upsert(forecastItemsToUpsert, false);
            
            logForecastItemsUpsertErrors(forecastItemsToUpsert, upsertResults);
        }
    }
    
    
    private void logDealUpsertErrors(Opportunity[] publishedDeals, Database.UpsertResult[] upsertDealResults) {
        for(Integer i=0; i < upsertDealResults.size(); i++) {
            if(!upsertDealResults[i].isSuccess()) {
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.AccountNumber = publishedDeals[i].Account.AccountNumber;
                err.AccountName = publishedDeals[i].Account.Name;  //Add Account Name Field in Publish Error message
                err.error = upsertDealResults[i].getErrors().get(0).getMessage();
                
                publishErrors.add(err);
            }
        }
    }
    
    private void logForecastItemsUpsertErrors(POS_Forecast_Item__c[] forecastItems, Database.UpsertResult[] upsertResults) {
        for(Integer i=0; i < upsertResults.size(); i++) {
            if(!upsertResults[i].isSuccess()) {
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.AccountNumber = forecastItems[i].Deal__r.Account.AccountNumber;
                err.AccountName = forecastItems[i].Deal__r.Account.Name;  //Add Account Name Field in Publish Error message
                err.posForecast = forecastItems[i].POS_Forecast__r.Name;
                err.error = upsertResults[i].getErrors().get(0).getMessage();
                
                publishErrors.add(err);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){

        //if(CRM_PublishAssortmentHelper.isPromotionalAssortment(assortment)){
           
            CRM_BatchPublishAssortmentDealProducts processDealProducts = new CRM_BatchPublishAssortmentDealProducts();
            processDealProducts.assortment = this.assortment;
            processDealProducts.mapFinalDealsStageChanges = this.mapFinalDealsStageChanges;
            processDealProducts.publishErrors = this.publishErrors;
            Database.executeBatch(processDealProducts, CRM_PublishAssortmentHelper.PUBLISH_BATCH_SIZE);
        /*}
       else {
            CRM_BatchPublishAssortmentFinalActions batchPublishFinalActions = new CRM_BatchPublishAssortmentFinalActions();
            batchPublishFinalActions.assortment = this.assortment;
            batchPublishFinalActions.mapFinalDealsStageChanges = this.mapFinalDealsStageChanges;
            batchPublishFinalActions.publishErrors = this.publishErrors;
            Database.executeBatch(batchPublishFinalActions, CRM_PublishAssortmentHelper.PUBLISH_BATCH_SIZE);
       }*/
    }
}