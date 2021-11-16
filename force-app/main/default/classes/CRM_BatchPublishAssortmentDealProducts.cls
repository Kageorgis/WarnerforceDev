/**
   @Author Cognizant (Dilip Mistry)
   @name CRM_PublishAssortmentsController
   @CreateDate 10 Aug 2016
   @Description Batch job to Create Deal Products as part of Publish Assortment Logic
   @Version <1.0>
*/
global without sharing class CRM_BatchPublishAssortmentDealProducts implements Database.Batchable<AssortmentAccountProduct>, Database.Stateful {
    global Bundle__c assortment;
    global Integer MAX_PUBLISH_ERRORS = CRM_Batch_Size__c.getInstance('Publish_Assortment_ErrorRecordSize') != null ? (Integer)CRM_Batch_Size__c.getInstance('Publish_Assortment_ErrorRecordSize').Batch_Size__c : 200;
    
    // Key -> Unique Publish Key, Value --> StageName
    global Map<String,String> mapFinalDealsStageChanges;
    global CRM_PublishAssortmentHelper.PublishError[] publishErrors;
    
    global Iterable<AssortmentAccountProduct> start(Database.BatchableContext BC){
        AssortmentAccountProduct[] listAssortmentAccountProduct = new AssortmentAccountProduct[]{};
        
        Assortment_Account__c[] listAssortmentAccounts = assortment.Assortment_Accounts__r;
        
        // Create a deal product for each account/product combination
        for(Assortment_Account__c assortmentAccount : listAssortmentAccounts) {
            for(Bundle_Product__c assortmentProduct : assortment.Bundle_Products__r) {
                AssortmentAccountProduct aap = new AssortmentAccountProduct();
                aap.assortmentAccountId = assortmentAccount.Id;
                aap.assortmentProductId = assortmentProduct.Id;

                listAssortmentAccountProduct.add(aap);
            }
        }
        
        // Publish the assortment with Pricing Account Details (Create a new Deal/Deal_Products for this pricing accounts as well)
        if(assortment.Pricing_Account__c != null && assortment.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL) {
            for(Bundle_Product__c assortmentProduct : assortment.Bundle_Products__r) {
                AssortmentAccountProduct aap = new AssortmentAccountProduct();
                aap.pricingAccountId = assortment.Pricing_Account__c;
                aap.assortmentProductId = assortmentProduct.Id;
    
                listAssortmentAccountProduct.add(aap);
            }
        }
        
        /*
        // Create a deal product for each account/product combination
        for(Bundle_Product__c assortmentProduct : assortment.Bundle_Products__r) {
            for(Assortment_Account__c assortmentAccount : assortment.Assortment_Accounts__r) {
                AssortmentAccountProduct aap = new AssortmentAccountProduct();
                aap.assortmentAccountId = assortmentAccount.Id;
                aap.assortmentProductId = assortmentProduct.Id;

                listAssortmentAccountProduct.add(aap);
            }
            
            // Publish the assortment with Pricing Account Details (Create a new Deal/Deal_Products for this pricing accounts as well)
            if(assortment.Pricing_Account__c != null && assortment.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL) {
                AssortmentAccountProduct aap = new AssortmentAccountProduct();
                aap.pricingAccountId = assortment.Pricing_Account__c;
                aap.assortmentProductId = assortmentProduct.Id;
    
                listAssortmentAccountProduct.add(aap);
            }
        }
        */
        
        system.debug('listAssortmentAccountProduct.size()--->'+listAssortmentAccountProduct.size());
        CustomIterable myIterable = new CustomIterable(listAssortmentAccountProduct);
        
        return myIterable;
    }
    
    /* EXECUTE METHOD */
    global void execute(Database.BatchableContext BC, List<AssortmentAccountProduct> listAssrtAccountProducts){
        system.debug('listAssrtAccountProducts size--->'+listAssrtAccountProducts.size());
        
        Map<Id,Assortment_Account__c> mapAssortmentAccounts = new Map<Id,Assortment_Account__c>(assortment.Assortment_Accounts__r);
        Map<Id,Bundle_Product__c> mapAssortmentProducts = new Map<Id,Bundle_Product__c>(assortment.Bundle_Products__r);
        
        Map<String,OpportunityLineItem> mapPublishedDealProducts = new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> mapExistingDealProducts = new Map<String,OpportunityLineItem>();
        Map<Id,OpportunityLineItem> mapDealLineItemsToDelete = new Map<Id,OpportunityLineItem>();
        Map<String,Opportunity> mapPublishedDeals = CRM_PublishAssortmentHelper.queryPublishedDealRecords(assortment);
        System.debug('mapPublishedDeals size --->'+mapPublishedDeals.size());
        Map<Assortment_Account__c, Set<Bundle_Product__c>> mapAccountMissingProduct = new  Map<Assortment_Account__c, Set<Bundle_Product__c>>();
        
        Set<Id> setProductsToPublish = getProductIdsToPublish(assortment.Bundle_Products__r);
        Map<String,PricebookEntry> mapPricebookEntries = new Map<String,PricebookEntry>();
        
        Boolean isDigitalAssortment = CRM_ApplicationUtility.isDigitalAssortment(assortment); 
        
        if(! isDigitalAssortment)
            mapPricebookEntries = CRM_PublishAssortmentHelper.getPricebookEntries(new Bundle__c[]{assortment});
        else
            mapPricebookEntries = CRM_PublishAssortmentHelper.getPricebookEntries(new Bundle__c[]{assortment}, mapPublishedDeals.values());
        
        // collection to contain product corresponding to a pricebook entry 
        Map<Id,Product2> mapPricebookEntryToProduct = new Map<Id,Product2>();
        
        for(PricebookEntry pbe: mapPricebookEntries.values()) {
            mapPricebookEntryToProduct.put(pbe.Id, pbe.Product2);
        }
        
        // Set of account ids for incoming listAssrtAccountProducts combinations
        Set<Id> setDealAccountIds = new Set<Id>();
        
        //--Ankita CPU Time limit RTC--Start--//
        Map<String,boolean> invalidDealProductMap = new Map<String,boolean>();
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        //--Ankita CPU Time limit RTC--End--//
        
        // Create a new deal product for each of the bundle_product and link it to deal created from the assortment account
        for(AssortmentAccountProduct aap : listAssrtAccountProducts) {
            Assortment_Account__c assortmentAccount = mapAssortmentAccounts.get(aap.assortmentAccountId);
            Bundle_Product__c assortmentProduct = mapAssortmentProducts.get(aap.assortmentProductId);
            
            if(aap.pricingAccountId != null && assortment.Pricing_Account__c != null && assortment.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL) {
                assortmentAccount = new Assortment_Account__c(
                            Account__c = assortment.Pricing_Account__c,
                            Account__r = assortment.Pricing_Account__r,
                            Assortment__c = assortment.Id
                        );
            }
            
            // Fill the set of account ids for current batch scope 
            setDealAccountIds.add(assortmentAccount.Account__c);
            
            String dealkey = assortment.Id + '-' + assortmentAccount.Account__c;
            Opportunity deal = mapPublishedDeals.get(dealkey);
                        
            System.debug('AssortmentAccountProduct  --->'+aap);
            System.debug('dealkey  --->'+dealkey);
            
            if(deal != null) {
                OpportunityLineItem dealProduct = new OpportunityLineItem();
                if (
                        (assortment.RecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment && assortmentProduct.Automatically_Add_Product__c) ||
                        (assortment.RecordTypeId != CRM_RecordTypeUtil.RT_Promotional_Assortment && assortmentProduct.Product__r.SAP_Material_Type__c == CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT)
                ) {
                    dealProduct = CRM_PublishAssortmentHelper.createDealProductRecord(deal, assortment, assortmentAccount, assortmentProduct, mapPricebookEntries);
                    //dealProduct = CRM_PublishAssortmentHelper.createDealProductRecord(assortment, assortmentAccount, assortmentProduct, mapPricebookEntries);
                    if(dealProduct != null) {
                        dealProduct.OpportunityId = deal.Id;
                        dealProduct.Opportunity = deal;
                        String uniqueDealProdKey = dealProduct.UniquePublishKey__c;
                        mapPublishedDealProducts.put(uniqueDealProdKey, dealProduct);                  
                    } else {
                        Set<Bundle_Product__c> setBundleProds = mapAccountMissingProduct.get(assortmentAccount);
                        if(setBundleProds == null) 
                            setBundleProds = new Set<Bundle_Product__c>();
                        setBundleProds.add(assortmentProduct);
                        mapAccountMissingProduct.put(assortmentAccount, setBundleProds);
                    }
                }
            }
        }
        
       if(! mapAccountMissingProduct.isEmpty()) 
            logProdNotFoundErrors(mapAccountMissingProduct, isDigitalAssortment);
        
        System.debug('mapPublishedDealProducts size --->'+mapPublishedDealProducts.size());
        System.debug('setDealAccountIds size --->'+setDealAccountIds.size());
        
        // Fetch existing deal products and mark it for deletion if not added on assortment
        //--CPU Time Limit--Added fileds in select query to populate DealWrapper--RTC--//
        for(OpportunityLineItem oli : [select Id, UniquePublishKey__c, Promoted_Price__c, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.ProductCode, 
                    Published_Quantity__c, Quantity, Initial_Quantity__c, Replen_Quantity__c, Opportunity.Assortment_Account__r.Account_Number__c,Opportunity.Assortment_Account__r.Account__r.Name,  //Add Account Name Field in Publish Error message
                    OpportunityId,Opportunity.AccountId,Opportunity.CurrencyISOCode,Product2Id,Opportunity.Pricebook2Id,Opportunity.Start_Date__c,Opportunity.CloseDate,
                    Opportunity.RecordTypeId,Pricebook_Entry_Period__c,Invalid_Deal_Product__c 
                    from OpportunityLineItem 
                    where Opportunity.UniquePublishKey__c IN: mapPublishedDeals.keySet()
                    and Opportunity.AccountId IN: setDealAccountIds ]) {
                        
            mapExistingDealProducts.put(oli.UniquePublishKey__c, oli);

            //--CPU Time Limit--RTC--Start--//
            if(!mapPublishedDealProducts.isEmpty() && mapPublishedDealProducts.containsKey(oli.UniquePublishKey__c)){
                CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
                dw.dealId = oli.OpportunityId;
                dw.accountId = oli.Opportunity.AccountId;
                dw.dealCurrency = oli.Opportunity.CurrencyISOCode;
                dw.productId = oli.Product2Id;
                dw.pricebookId = oli.Opportunity.Pricebook2Id;
                dw.dealStartDate = oli.Opportunity.Start_Date__c;
                dw.dealEndDate = oli.Opportunity.CloseDate;
                dw.dealProduct = oli;
                dw.dealRecordTypeId = oli.Opportunity.RecordTypeId;
                listDealWrappers.add(dw);
                invalidDealProductMap.put(oli.UniquePublishKey__c, false);
            }
            //--CPU Time Limit--RTC--End--//
            
            // Remove the Product if previously created from the Publish Logic but the original assortment product has been deleted
            if(oli.UniquePublishKey__c != null && !setProductsToPublish.contains(oli.PricebookEntry.Product2Id)) {
                mapDealLineItemsToDelete.put(oli.Id, oli);
            }
        }

        //--CPU Time Limit--RTC--Start--//        
        if(!listDealWrappers.isEmpty()){
            CRM_ProductPricingHandler instance = new CRM_ProductPricingHandler(listDealWrappers);

            // Verify the deal product contains valid PBEP and set invalidDealProduct flag accordingly
            for(CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers){
                Pricebook_Entry_Period__c pbep = instance.getProductDatedPricebookEntryPeriod(dw);
                //system.debug('@@PBEP-->'+dw.dealProduct.Pricebook_Entry_Period__c+'-'+pbep.Id);
                if (dw.dealProduct.Pricebook_Entry_Period__c != null){
                    if (pbep != null){
                        if (dw.dealProduct.Pricebook_Entry_Period__c != pbep.Id){
                            // If already not set then set the flag as conditions are true    
                            if (!dw.dealProduct.Invalid_Deal_Product__c){
                                //dw.dealProduct.Invalid_Deal_Product__c = true;
                                if(invalidDealProductMap.containsKey(dw.dealProduct.UniquePublishKey__c)){
                                    invalidDealProductMap.put(dw.dealProduct.UniquePublishKey__c,true);
                                }
                            }
                        }else{
                            // If conditions are not true and flag is set then make it false
                            if(dw.dealProduct.Invalid_Deal_Product__c){
                                //dw.dealProduct.Invalid_Deal_Product__c = false;
                                if(invalidDealProductMap.containsKey(dw.dealProduct.UniquePublishKey__c)){
                                    invalidDealProductMap.put(dw.dealProduct.UniquePublishKey__c,false);
                                }
                            }
                        }
                    }else{
                        if (!dw.dealProduct.Invalid_Deal_Product__c){
                            //dw.dealProduct.Invalid_Deal_Product__c = true;
                            if(invalidDealProductMap.containsKey(dw.dealProduct.UniquePublishKey__c)){
                                invalidDealProductMap.put(dw.dealProduct.UniquePublishKey__c,true);
                            }
                        }
                    }
                }
            }
        }
        System.debug('@@invalidDealProductMap2-->'+invalidDealProductMap);
        //--CPU Time Limit--RTC--End--//
        
        // Update the deal products with Deal Record Id after all the deals are inserted/updated
        for(String dealProdUniquePublishKey : mapPublishedDealProducts.keySet()) {
            OpportunityLineItem oli = mapPublishedDealProducts.get(dealProdUniquePublishKey);
            
            String dealUniquePublishKey = oli.Opportunity.Bundle__c +'-'+ oli.Opportunity.AccountId;
            Opportunity deal = mapPublishedDeals.get(dealUniquePublishKey);
            
            OpportunityLineItem existingDealProd = mapExistingDealProducts.get(dealProdUniquePublishKey);
            Boolean isExistingDealProd = mapExistingDealProducts.containsKey(dealProdUniquePublishKey) ? true : false;
            
            // Update the Id of the deal line item record from existing LineItem record
            if(isExistingDealProd) {
                oli.Id = existingDealProd.Id;
                oli.Promoted_Price__c = existingDealProd.Promoted_Price__c;
                
                Decimal totalExistingQty = existingDealProd.Quantity;
                
                //Added for Req - 378 for France - Update Initial Quantity and Replen Quantity with Existing quantities if User has entered.
                if(existingDealProd.Published_Quantity__c  != totalExistingQty){
                    oli.Initial_Quantity__c = existingDealProd.Initial_Quantity__c;
                    oli.Replen_Quantity__c = existingDealProd.Replen_Quantity__c;
                }
            }
            else {
                Bundle__c relatedAssortment = assortment;
                oli.OpportunityId = deal.Id;
        
                // Update the quantity from Hidden Estimated Quantity if available
                if(deal.Hidden_Estimated_Quantity__c != null && deal.Hidden_Estimated_Quantity__c > 0) {
                    Decimal totalQty = deal.Hidden_Estimated_Quantity__c * (oli.Share__c != null ? oli.Share__c : 0) / 100;
                    totalQty = Math.round(totalQty);
                    
                    oli.Initial_Quantity__c = (relatedAssortment.Replen__c!= null ? Math.round(totalQty * (1-relatedAssortment.Replen__c/100)) : totalQty);
                    oli.Replen_Quantity__c = (relatedAssortment.Replen__c!= null ? Math.round(totalQty * (relatedAssortment.Replen__c/100)) : 0);
                    
                    oli.Initial_Quantity__c = oli.Initial_Quantity__c == 0 ? 1 : oli.Initial_Quantity__c;
                    oli.Quantity = oli.Initial_Quantity__c + oli.Replen_Quantity__c;
                }
            }
            
            //--CPU Time Limit--RTC--Start--//
            if(invalidDealProductMap.containsKey(dealProdUniquePublishKey)){
                oli.Invalid_Deal_Product__c = invalidDealProductMap.get(dealProdUniquePublishKey);
            }           
            //--CPU Time Limit--RTC--End--//
        }
        
        
        // Delete the products which are available for deal but removed on assortment
        // Assumed that it will not be a long list of products [no need of batch processing]
        if(!mapDealLineItemsToDelete.isEmpty()) {
            Database.DeleteResult[] deleteResult;
            OpportunityLineItem[] listDealProductsToDelete;
            
            listDealProductsToDelete = mapDealLineItemsToDelete.values();
            deleteResult = Database.delete(mapDealLineItemsToDelete.values(),false);

            // Error Capturing 
            logDealProdDeleteErrors(listDealProductsToDelete, deleteResult, isDigitalAssortment);
        }
        
        if(!mapPublishedDealProducts.isEmpty()) {
            CRM_PublishAssortmentHelper.removeNonwritableFields(mapPublishedDealProducts, assortment);
            OpportunityLineItem[] listDealProductsToUpsert = mapPublishedDealProducts.values();
            
            //upsert listDealProductsToUpsert;
            
            Database.UpsertResult[] upsertResults = Database.upsert(listDealProductsToUpsert, false);
            
            // Error Capturing Part
            logDealProdUpsertErrors(listDealProductsToUpsert, upsertResults, mapPricebookEntryToProduct, isDigitalAssortment);
        }
    }
    
    
    /* Method to get the Product Ids of products associated to an assortment */
    private Set<Id> getProductIdsToPublish(Bundle_Product__c[] listAssortmentProducts) {
        Set<Id> setProductIds = new Set<Id>();
        
        for(Bundle_Product__c asrtProd : listAssortmentProducts) {
            setProductIds.add(asrtProd.Product__c);
        }
        
        return setProductIds;
    }
    
    private void logProdNotFoundErrors(Map<Assortment_Account__c, Set<Bundle_Product__c>> mapAccountMissingProduct, Boolean isDigitalAssortment) {
        Integer count = 0;
        
        for(Assortment_Account__c keyAssAccount : mapAccountMissingProduct.keySet()) {
            for(Bundle_Product__c valBundleProd : mapAccountMissingProduct.get(keyAssAccount)) {
                if(publishErrors.size() > MAX_PUBLISH_ERRORS) 
                    break;
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.accountNumber = keyAssAccount.Account_Number__c;
                err.accountName = keyAssAccount.Account__r.Name; //Add Account Name Field in Publish Error message
                err.productCode = valBundleProd.Product__r.ProductCode;
                err.error = Label.CRM_Assortment_Product_Not_Found;
                err.productName = valBundleProd.Product__r.Name;
                err.isDigitalAssortment = isDigitalAssortment;
                
                publishErrors.add(err);    
                count++;
            }
        }
    }
    
    private void logDealProdDeleteErrors(OpportunityLineItem[] deletedDealProds, Database.DeleteResult[] deleteDealProdResults, Boolean isDigitalAssortment) {
        for(Integer i=0; i < deleteDealProdResults.size(); i++) {
            if(!deleteDealProdResults[i].isSuccess()) {
                if(publishErrors.size() > MAX_PUBLISH_ERRORS) {
                    break;
                }
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.accountNumber = deletedDealProds[i].Opportunity.Assortment_Account__r.Account_Number__c;
                err.accountName = deletedDealProds[i].Opportunity.Assortment_Account__r.Account__r.Name; //Add Account Name Field in Publish Error message
                err.productCode = deletedDealProds[i].PricebookEntry.Product2.ProductCode;
                err.error = deleteDealProdResults[i].getErrors().get(0).getMessage();
                err.productName = deletedDealProds[i].Product2.Name;
                err.isDigitalAssortment = isDigitalAssortment;
                
                publishErrors.add(err);
            }
        }
    }
    
    private void logDealProdUpsertErrors(OpportunityLineItem[] publishedDealProds, Database.UpsertResult[] upsertDealProdResults,Map<Id,Product2> mapPricebookEntryToProduct, Boolean isDigitalAssortment) {
        for(Integer i=0; i < upsertDealProdResults.size(); i++) {
            if(!upsertDealProdResults[i].isSuccess()) {
                if(publishErrors.size() > MAX_PUBLISH_ERRORS) {
                    break;
                }
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.accountNumber = publishedDealProds[i].Opportunity.Assortment_Account__r.Account_Number__c;
                err.accountName = publishedDealProds[i].Opportunity.Assortment_Account__r.Account__r.Name;  //Add Account Name Field in Publish Error message
                
                if(publishedDealProds[i].PricebookEntryId != null && mapPricebookEntryToProduct.get(publishedDealProds[i].PricebookEntryId) != null) {
                    err.productCode = mapPricebookEntryToProduct.get(publishedDealProds[i].PricebookEntryId).ProductCode;
                }
                else {
                    err.productCode = 'PBEID: '+publishedDealProds[i].PricebookEntryId;
                }
                err.error = upsertDealProdResults[i].getErrors().get(0).getMessage();
                err.productName = mapPricebookEntryToProduct.get(publishedDealProds[i].PricebookEntryId).Name;
                err.isDigitalAssortment = isDigitalAssortment;
                
                publishErrors.add(err);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        CRM_BatchPublishAssortmentFinalActions batchPublishFinalActions = new CRM_BatchPublishAssortmentFinalActions();
        batchPublishFinalActions.assortment = this.assortment;
        batchPublishFinalActions.mapFinalDealsStageChanges = this.mapFinalDealsStageChanges;
        batchPublishFinalActions.publishErrors = this.publishErrors;
        Database.executeBatch(batchPublishFinalActions, CRM_PublishAssortmentHelper.PUBLISH_BATCH_SIZE);
    }
    
    
    global class CustomIterable implements Iterator<AssortmentAccountProduct>, Iterable<AssortmentAccountProduct> {
        AssortmentAccountProduct[] listDealProdWrapper;
        Integer counter;
        
        global CustomIterable(AssortmentAccountProduct[] listDealProdWrapper){ 
            this.listDealProdWrapper = listDealProdWrapper;
            counter = 0;
        }  
        
        global Iterator<AssortmentAccountProduct> Iterator(){
            return this;
        }
    
        global boolean hasNext(){ 
            return (counter >= listDealProdWrapper.size() ? false : true);
        }
    
        global AssortmentAccountProduct next(){
            counter++; 
            return listDealProdWrapper[counter-1];
        }
    }
    
    global class AssortmentAccountProduct {
        //global Bundle__c assortment; 
        //global Assortment_Account__c assortmentAccount;
        //global Bundle_Product__c assortmentProduct;
        global Id assortmentAccountId;
        global Id assortmentProductId;
        global Id pricingAccountId;
    }
}