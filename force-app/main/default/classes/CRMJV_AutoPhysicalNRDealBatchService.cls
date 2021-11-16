/**
   @Author Rahulkumar(Cognizant)
   @name CRMJV_AutoPhysicalNRDealBatchService
   @CreateDate 15 Dec 2020
   @Description This batch class is responsible for automatic creation of JV Deals, and corresponding Deal Products associated to them for NR products created in the system.
   @Version <1.0>
   @reference Requirement no W-017644, W-017678 from JV Project
*/
public with sharing class CRMJV_AutoPhysicalNRDealBatchService{

    public static Map<Id,String> mapDealRecordTypeToShortName = new Map<Id,String>();
    public static List<String> priceType = new List<String>();
    public static Map<String,Opportunity> mapDealUniqueStringToInstanceForCommitted = new Map<String,Opportunity>();
    public static Map<String,String> mapDealToStageNameForCommitted = new Map<String,String>();
    public static Map<Id, Opportunity> mapDealIdToInstance = new Map<Id, Opportunity>();
    public static Map<Id, String> mapPOSDealCreditNoteItemIdToName = new Map<Id, String>();

    static{
        mapDealRecordTypeToShortName.put(CRM_RecordTypeUtil.RT_Physical_POS_Deal, System.Label.CRM_ADVPOS_Deal_Type_Short_Name);
        mapDealRecordTypeToShortName.put(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, System.Label.CRM_DFI_Deal_Type_Short_Name);
        mapDealRecordTypeToShortName.put(CRM_RecordTypeUtil.RT_Physical_Planning_Deal, System.Label.CRM_Planning_Deal_Type_Short_Name);

        priceType.add(CRM_AppConstants.PBEP_PRICE_TYPE_PROMOTION);
        priceType.add(CRM_AppConstants.PBEP_PRICE_TYPE_DEALER);
    }

    /**
     * @Description - Method to process all NR Product records
     * @name processNRProductRecords
     * @param lstSoldToAccounts List of all Sold To Accounts
     * @param lstNRProducts List of all NR Products
     * @param mapProductIdToAccountPlanList - Map of Product Id to corresponding List of Targets
     * @param setProcessedProductIds Set of all the Processed Product Ids
     */
    public static List<CRMJV_AutoPhysicalNRDealServiceException> processNRProductRecords(List<Account> lstSoldToAccounts,List<Product2> lstNRProducts,
                    Map<String, List<Pricebook_Entry_Period__c>> mapIdToPBEPList,Set<Id> setProcessedProductIds){

        System.debug('@@lstNRProducts-->'+lstNRProducts);  
        System.debug('@@mapIdToPBEPList-->'+mapIdToPBEPList);

        List<CRMJV_AutoPhysicalNRDealServiceException> lstExceptions = new List<CRMJV_AutoPhysicalNRDealServiceException>();
    
        List<Opportunity> lstNewDealsToInsert = new List<Opportunity>();
        Map<Id,List<Opportunity>> mapAccountIdToAllDeals = new Map<Id,List<Opportunity>>();
        List<OpportunityLineItem> lstDeleteDealProductsToBeCloned = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> lstDealProductSchedulesToBeCloned = new List<OpportunityLineItemSchedule>();
        Map<Id, Account> mapSelectedAccounts = new Map<Id, Account>();
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        Map<Id, Product2> mapProductIdToInstance = new Map<Id, Product2>();
        Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts = new Map<String, List<OpportunityLineItem>>();
        Set<Id> setPriceBookIds = new Set<Id>();
        Map<String, OpportunityLineItem> mapExistingDealProducts = new Map<String, OpportunityLineItem>();
        Set<Id> setProcessedDealIds = new Set<Id>();
        Map<String, List<String>> mapDealNameToErrorList = new Map<String, List<String>>();
        Map<String, OpportunityLineItem> mapNewDealProductsToUpsert = new Map<String, OpportunityLineItem>();
        Map<String, List<Product2>> mapDealNameToProductInstance = new Map<String, List<Product2>>();
        Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP = new Map<String, Pricebook_Entry_Period__c>();
        Map<String,PricebookEntry> mapPriceBookEntry = new Map<String,PricebookEntry>();
        Map<String, List<OpportunityLineItemSchedule>> mapExistingDealProductsWithSchedules = new Map<String, List<OpportunityLineItemSchedule>>();
        Map<String, List<CRMJV_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList = new Map<String, List<CRMJV_TargetRevenueDetail>>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();

        Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal = new Map<Id, List<Opportunity>>();
        Map<Id, Account> mapIdToAccountInstance = new Map<Id, Account>();
        Set<String> setProcessedDealProductIds = new Set<String>();
        Set<String> setNewlyInsertedUniqueDPKey = new Set<String>();
        Map<Id, PricebookEntry> mapPBEIdToInstance = new Map<Id, PricebookEntry>();
        Set<String> setProductAndAccountIdForTargets = new Set<String>();

        try{
            if(!lstSoldToAccounts.isEmpty()){
                mapIdToAccountInstance = new Map<Id, Account>(lstSoldToAccounts);
            }
    
            //Map of Type with corresponding Set of Accounts
            Map<String,Set<Account>> mapProductTypeWithRelatedAccounts =
                fetchListOfAccountsForType(lstSoldToAccounts, mapDealIdToInstance, mapProductAndAccountIdToTargetDetailList, setProductAndAccountIdForTargets, mapAccounts);
            System.debug('@@mapProductTypeWithRelatedAccounts-->'+mapProductTypeWithRelatedAccounts);
    
            if(mapDealIdToInstance.size() > 0 && !mapDealIdToInstance.values().isEmpty()){    
                //Fetch Existing Deal Product for products
                fetchExistingDealProducts(lstNRProducts, mapProductIdToExistingDealProducts, mapExistingDealProducts,
                    mapDealIdToInstance, mapDealUniqueStringToInstanceForCommitted);
            }
            System.debug('@@mapExistingDealProducts-->'+mapExistingDealProducts);
            System.debug('@@mapProductIdToExistingDealProducts-->'+mapProductIdToExistingDealProducts);

            for(Product2 productInstance :lstNRProducts){
                mapProductIdToInstance.put(productInstance.Id, productInstance);
                mapSelectedAccounts = fetchRelatedAccounts(productInstance,mapProductTypeWithRelatedAccounts);
                for(Account accountInstance :mapSelectedAccounts.values()){
                    for(Id dealRecordType :mapDealRecordTypeToShortName.keySet()){
                        Boolean bCreateNewDeal = false;

                        // Boolean Flag to distinguish France Sales Org
                        Boolean isTargetBasedSalesOrg = true;
        
                        if(!mapAccountIdToAllDeals.containsKey(accountInstance.Id) && 
                                accountInstance.Opportunities != null && !accountInstance.Opportunities.isEmpty()){
                            mapAccountIdToAllDeals.put(accountInstance.Id,accountInstance.Opportunities);
                        }
                    
                        // Based on Type check proceed further
                        if (!mapAccountIdToAllDeals.isEmpty() && mapAccountIdToAllDeals.containsKey(accountInstance.Id)){
                            bCreateNewDeal =
                                processAllDeals(productInstance,accountInstance,mapAccountIdToAllDeals,setProductAndAccountIdForTargets,lstDeleteDealProductsToBeCloned,
                                    mapIdToPBEPList,setProcessedProductIds,mapProductIdToExistingDealProducts,setPriceBookIds,mapExistingDealProducts,
                                    setProcessedDealIds,mapNewDealProductsToUpsert,mapDealNameToProductInstance,mapUniqueKeyToValidPBEP,
                                    mapExistingDealProductsWithSchedules,mapProductIdAndAssociatedDeal, mapDealUniqueStringToInstanceForCommitted,
                                    dealRecordType
                                );
                        }else{
                            System.debug('--no deals present for the account else -->');
                            bCreateNewDeal = true;
                        }

                        system.debug('@@bCreateNewDeal-->'+bCreateNewDeal);
                        // Create New Deal RECORDS
                        if(bCreateNewDeal){
                            //Create new deal
                            Opportunity newDeal = createDealWithAccounts(accountInstance,productInstance,dealRecordType);
                            System.debug('@@newDeal-->'+newDeal);

                            if(accountInstance.Class_of_Trade__c != null){
                                priceType.add(accountInstance.Class_of_Trade__c.toUpperCase());  
                            }
                            for(String pbepPriceType: priceType){
                                //String accountCOT = accountInstance.Class_of_Trade__c != null ? '-' + accountInstance.Class_of_Trade__c.toUpperCase() : '';
                                String strKey = productInstance.ProductCode + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode + '-' + pbepPriceType;
                                //System.debug('@@mapIdToPBEPList.containsKey(strKey)-->'+strKey+'--'+mapIdToPBEPList.containsKey(strKey));
                                if(mapIdToPBEPList.containsKey(strKey)){
                                    for(Pricebook_Entry_Period__c pbep : mapIdToPBEPList.get(strKey)){
                                        if(isValidPBEP(pbep,newDeal,productInstance)){
                                            mapUniqueKeyToValidPBEP.put(strKey,pbep);
                                            break;
                                        }
                                    }
                                }
                            }
                            // Boolean flag to allow deal creation if Target details present in case of Scenario 1, 2 & 3
                            Boolean isTargetPresent = false;
                            if(mapProductAndAccountIdToTargetDetailList.containsKey(productInstance.Id + '-' + accountInstance.Id) &&
                                    mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id) != null &&
                                    mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id).size() > 0){
                                for(CRMJV_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id)){
                                    if(productInstance.Street_Date__c != null &&
                                            targetDetailInstance.targetInstance.Calc_Start_Date__c <= productInstance.Street_Date__c &&
                                            targetDetailInstance.targetInstance.Calc_End_Date__c >= productInstance.Street_Date__c){
                                        isTargetPresent = true;
                                        break;
                                    }
                                }
                            }

                            String accountCOT = accountInstance.Class_of_Trade__c != null ? accountInstance.Class_of_Trade__c.toUpperCase() : '';
                            String strKey = productInstance.ProductCode + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode;
                                                                
                            Boolean isValidNewDealInsertAllowed =
                                isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP)) &&
                                (productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                                    //mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c ||
                                    (isTargetBasedSalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id)));
                            system.debug('@@isValidNewDealInsertAllowed-->'+isValidNewDealInsertAllowed);

                            // If no valid PBEP found, don't create new Deal
                            if(newDeal != null && isValidNewDealInsertAllowed && (isTargetBasedSalesOrg && isTargetPresent)){
                                if(processNewDeals(
                                        newDeal,
                                        productInstance,
                                        accountInstance,
                                        lstDeleteDealProductsToBeCloned,
                                        lstNewDealsToInsert,
                                        setProcessedProductIds,
                                        setPriceBookIds,
                                        mapDealNameToProductInstance,
                                        mapUniqueKeyToValidPBEP,
                                        mapProductIdAndAssociatedDeal,
                                        setProductAndAccountIdForTargets)){

                                    if(mapAccountIdToAllDeals.containsKey(accountInstance.Id)){
                                        List<Opportunity> lstDeal = mapAccountIdToAllDeals.get(accountInstance.Id);
                                        lstDeal.add(newDeal);
                                        mapAccountIdToAllDeals.put(accountInstance.Id,lstDeal);
                                    }else{
                                        mapAccountIdToAllDeals.put(accountInstance.Id,new List<Opportunity>{newDeal});
                                    }
                                }
                            }else{
                                OpportunityLineItem validDealProductToCloneInstance;
                                if(productInstance.Street_Date_Has_Changed__c){
                                    validDealProductToCloneInstance = fetchDealProductToClone(accountInstance, productInstance, mapProductIdToExistingDealProducts, dealRecordType);
                                }    
                                // If no deal created due to no valid PBEP found, we don't clone the deal product but
                                // we have to delete the deal Product that was supposed to be cloned only if its Deal is in any Stage
                                if(validDealProductToCloneInstance != null){
                                    lstDeleteDealProductsToBeCloned.add(validDealProductToCloneInstance);
                                }
                                setProcessedProductIds.add(productInstance.Id);
                            }
                        }
                    }
                }
            }
    
            System.debug('@@lstNewDealsToInsert:111-->'+lstNewDealsToInsert);
            // Inserting new deals
            if(!lstNewDealsToInsert.isEmpty()){
                Database.SaveResult[] saveResultList = Database.insert(lstNewDealsToInsert,false);
                Opportunity deal;
                for(Integer i = 0; i < saveResultList.size(); i++){
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    deal = lstNewDealsToInsert[i];
                    if(deal != null){
                        if(saveResultInstance.isSuccess()){
                            setProcessedDealIds.add(deal.Id);
                            
                            // Process Scenario 2 for only newly inserted deals
                            if(mapDealNameToProductInstance.containsKey(deal.Name + '-' + deal.AccountId)){
                                // If multiple products of same type changes streetDate to lie in newly created deal for a single account
                                for(Product2 productInstance : mapDealNameToProductInstance.get(deal.Name + '-' + deal.AccountId)){
                                    if(productInstance.Street_Date_Has_Changed__c){
                                        // lstDeleteDealProductsToBeCloned will be returned only if deal product is cloned
                                        String accountCOT = mapAccounts.containsKey(deal.AccountId) && mapAccounts.get(deal.AccountId).Class_of_Trade__c != null ? 
                                            mapAccounts.get(deal.AccountId).Class_of_Trade__c.toUpperCase() : '';

                                        lstDeleteDealProductsToBeCloned.addAll(
                                            processScenarioTwo(
                                                productInstance,
                                                deal,
                                                setProductAndAccountIdForTargets,
                                                setProcessedProductIds,
                                                mapProductIdToExistingDealProducts,
                                                setPriceBookIds,
                                                mapExistingDealProducts,
                                                mapNewDealProductsToUpsert,
                                                mapUniqueKeyToValidPBEP,
                                                mapExistingDealProductsWithSchedules,
                                                mapProductIdAndAssociatedDeal,
                                                accountCOT
                                            )
                                        );
                                    }
                                }
                            }
                        }else{   // Error Handling
                            system.debug('@@Error in deal insert-->');
                            List<String> lstErrors = new List<String>();
                            lstErrors.add(String.format(System.Label.CRM_Deal_Not_Processed,new String[]{deal.Name,deal.AccountId}));
    
                            for(Database.Error err :saveResultInstance.getErrors()){
                                lstErrors.add(err.getMessage());
    
                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
    
                            if(mapDealNameToErrorList.containsKey(deal.Name)){
                                List<String> errorList = mapDealNameToErrorList.get(deal.Name);
                                errorList.addAll(lstErrors);
                                mapDealNameToErrorList.put(deal.Name,errorList);
                            }else{
                                mapDealNameToErrorList.put(deal.Name,lstErrors);
                            }
                        }
                    }
                }
            }
    
            system.debug('@@mapDealUniqueStringToInstanceForCommitted-->'+mapDealUniqueStringToInstanceForCommitted);
            // Change the DFI deal Stage to Revised so that Deal Products can be updated / inserted / deleted for Approved OR Committed Deals
            if(mapDealUniqueStringToInstanceForCommitted.size() > 0 && !mapDealUniqueStringToInstanceForCommitted.values().isEmpty()){
                Database.SaveResult[] saveResultList = Database.update(mapDealUniqueStringToInstanceForCommitted.values(),false);
                Opportunity deal;
                for(Integer i = 0; i < saveResultList.size(); i++){
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    deal = mapDealUniqueStringToInstanceForCommitted.values()[i];
                    if(deal != null){
                        if(!saveResultInstance.isSuccess()){
                            setProcessedDealIds.remove(deal.Id);
    
                            // Error Handling
                            system.debug('@@Error in commit to revise deal -->');
                            List<String> lstErrors = new List<String>();
                            lstErrors.add(String.format(System.Label.CRM_Deal_Not_Processed,new String[]{deal.Name,deal.AccountId}));
    
                            for(Database.Error err : saveResultInstance.getErrors()){
                                lstErrors.add(err.getMessage());
    
                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
    
                            if(mapDealNameToErrorList.containsKey(deal.Name)){
                                List<String> errorList = mapDealNameToErrorList.get(deal.Name);
                                errorList.addAll(lstErrors);
                                mapDealNameToErrorList.put(deal.Name,errorList);
                            }else{
                                mapDealNameToErrorList.put(deal.Name,lstErrors);
                            }
                        }
                    }
                }
            }    
            mapPBEIdToInstance = fetchPriceBookEntryForProduct(setPriceBookIds, mapProductIdToInstance, mapPriceBookEntry);
            System.debug('mapPriceBookEntry::'+mapPriceBookEntry);
            System.debug('--mapProductIdAndAssociatedDeal-->'+mapProductIdAndAssociatedDeal);

            // Calling method to create Deal Products on Deals
            createDealProductOnDeal(
                setProcessedProductIds,
                mapProductIdToInstance,
                mapExistingDealProducts,
                setProcessedDealIds,
                mapDealNameToErrorList,
                mapNewDealProductsToUpsert,
                mapUniqueKeyToValidPBEP,
                mapPriceBookEntry,
                mapProductAndAccountIdToTargetDetailList,
                lstExceptions,
                mapProductIdAndAssociatedDeal,
                setProductAndAccountIdForTargets,
                mapIdToAccountInstance
            );            
        }catch(Exception e){
            // Save the error in database
            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
            errorLog.lineNumber = String.valueOf(e.getLineNumber());
            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
            errorLog.errorMessage = e.getMessage().left(200);
            errorLog.stackTrace = e.getStackTraceString();
            listErrorLog.add(errorLog);
            
            //Adding Exception
            lstExceptions.add(new CRMJV_AutoPhysicalNRDealServiceException(null,new List<String>{e.getMessage()}));
        }

        //--Remove commited deal product from list and add it to in upsert list with cancel mark--Start--//
        system.debug('@@lstDeleteDealProductsToBeCloned-->'+lstDeleteDealProductsToBeCloned);
        if(!lstDeleteDealProductsToBeCloned.isEmpty()){
            for(OpportunityLineItem objDealProduct :lstDeleteDealProductsToBeCloned){
                if(mapDealUniqueStringToInstanceForCommitted.containsKey(objDealProduct.OpportunityId) && objDealProduct.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL){
                    objDealProduct.DFI_Status__c = 'Cancel';
                    objDealProduct.Is_Canceled__c = true;
                    if(!objDealProduct.NR_Deal_Product_Unique_Key__c.contains('Cancel')){
                        objDealProduct.NR_Deal_Product_Unique_Key__c = objDealProduct.NR_Deal_Product_Unique_Key__c + '-Cancel';
                    }
                    mapNewDealProductsToUpsert.put(objDealProduct.OpportunityId + '-' + objDealProduct.Product2Id + '-' + objDealProduct.CurrencyISOCode, objDealProduct);
                }
            }
        }
        system.debug('@@mapNewDealProductsToUpsert-->'+mapNewDealProductsToUpsert);
        //--Remove commited deal product from list and add it to in upsert list with cancel mark--End--//
            
        // Skip the validation rule when invoked through NR Bacth and allow changing deal product rental prices
        CRM_ApplicationUtility.isInvokedByNRBatch = true;
        if(!mapNewDealProductsToUpsert.values().isEmpty()){
            Database.UpsertResult[] saveResultList = Database.upsert(mapNewDealProductsToUpsert.values(), false);
            OpportunityLineItem dealProduct;
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.UpsertResult saveResultInstance = saveResultList[i];
                dealProduct = mapNewDealProductsToUpsert.values()[i];
                if(dealProduct != null){
                    Id productId = dealProduct.Product2Id != null ? dealProduct.Product2Id : mapPBEIdToInstance.containsKey(dealProduct.PricebookEntryId) ? mapPBEIdToInstance.get(dealProduct.PricebookEntryId).Product2Id : dealProduct.Product2Id;

                    if(saveResultInstance.isSuccess()){
                        setProcessedProductIds.add(productId);
                        if(dealProduct.Product2Id != null){
                            setProcessedDealProductIds.add(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
                        }else{
                            setNewlyInsertedUniqueDPKey.add(dealProduct.NR_Deal_Product_Unique_Key__c);
                        }
                    }else{
                        // Add these errors in Error wrapper Class and prepare a list of same
                        setProcessedProductIds.remove(productId);

                        // Error Handling
                        system.debug('@@Error in deal product upsert-->');
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(String.format(System.Label.CRM_Deal_Product_Not_Processed,new String[]{dealProduct.OpportunityId}));

                        for(Database.Error err : saveResultInstance.getErrors()){
                            string errMessage = err.getMessage();
                            //--Check for POD deal with Credit Note, if exists send validation message--Start--//
                            if(dealProduct.Deal_Record_Type__c ==  CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL &&
                                    dealProduct.Credit_Note_Item__c != null && mapPOSDealCreditNoteItemIdToName.containsKey(dealProduct.Credit_Note_Item__c)){
                                errMessage = String.format(errMessage,new String[]{mapPOSDealCreditNoteItemIdToName.get(dealProduct.Credit_Note_Item__c)});
                                setProcessedProductIds.add(productId);
                            }
                            //--Check for POD deal with Credit Note, if exists send validation message--End--//

                            lstErrors.add(errMessage);

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealProduct.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = errMessage.left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(new CRMJV_AutoPhysicalNRDealServiceException(productId,lstErrors));
                    }
                }
            }
        }
        System.debug('mapNewDealProductsToUpsert111::'+mapNewDealProductsToUpsert);
        System.debug('lstDeleteDealProductsToBeCloned::'+lstDeleteDealProductsToBeCloned);
        
        List<OpportunityLineItem> dealProductToBeDeletedFilteredList = new List<OpportunityLineItem>();
        for(OpportunityLineItem dealProductToBeDeletedInstance : lstDeleteDealProductsToBeCloned){
            if(dealProductToBeDeletedInstance.Deal_Record_Type__c ==  CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL){
                if(dealProductToBeDeletedInstance.Credit_Note_Item__c == null && setProcessedProductIds.contains(dealProductToBeDeletedInstance.Product2Id) && !dealProductToBeDeletedInstance.Is_Canceled__c){
                    dealProductToBeDeletedFilteredList.add(dealProductToBeDeletedInstance);
                }
            }else{
                if(setProcessedProductIds.contains(dealProductToBeDeletedInstance.Product2Id) && !dealProductToBeDeletedInstance.Is_Canceled__c){
                    dealProductToBeDeletedFilteredList.add(dealProductToBeDeletedInstance);
                }
            }
        }

        System.debug('dealProductToBeDeletedFilteredList::'+dealProductToBeDeletedFilteredList);
        if(!dealProductToBeDeletedFilteredList.isEmpty()){
            Database.DeleteResult[] deleteResultList = Database.delete(dealProductToBeDeletedFilteredList, false);
            OpportunityLineItem dealProduct;
            for(Integer i = 0; i < deleteResultList.size(); i++){
                dealProduct = dealProductToBeDeletedFilteredList[i];
                Database.DeleteResult deleteResultInstance = deleteResultList[i];
                if(dealProduct != null){
                    Id productId = dealProduct.Product2Id != null ? dealProduct.Product2Id : mapPBEIdToInstance.containsKey(dealProduct.PricebookEntryId) ? mapPBEIdToInstance.get(dealProduct.PricebookEntryId).Product2Id : dealProduct.Product2Id;
                    if(deleteResultInstance.isSuccess()){
                        setProcessedProductIds.add(productId);
                        setProcessedDealProductIds.add(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
                    }else{
                        setProcessedProductIds.remove(productId);
                        setProcessedDealProductIds.remove(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
                        
                        // Error Handling
                        system.debug('@@Error in deal product delete-->');
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(String.format(System.Label.CRM_Deal_Product_Not_Deleted, new String[]{dealProduct.Id,dealProduct.OpportunityId}));
                        
                        for(Database.Error err : deleteResultInstance.getErrors()){
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealProduct.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(new CRMJV_AutoPhysicalNRDealServiceException(productId,lstErrors));
                    }
                }
            }
        }

        for(String strDealProduct : mapExistingDealProductsWithSchedules.keySet()){
            OpportunityLineItem dealProduct;

            if(mapExistingDealProducts.containsKey(strDealProduct)){
                dealProduct = mapExistingDealProducts.get(strDealProduct);
            }else if(mapNewDealProductsToUpsert.containsKey(strDealProduct)){
                dealProduct = mapNewDealProductsToUpsert.get(strDealProduct);
            }

            if(dealProduct != null){
                for(OpportunityLineItemSchedule dealProductSchedule : mapExistingDealProductsWithSchedules.get(strDealProduct)){
                    if(dealProductSchedule.Id == null){
                        dealProductSchedule.OpportunityLineItemId = dealProduct.Id;
                    }
                    dealProductSchedule.ScheduleDate = calculateScheduleDateForClonedSchedules(dealProduct,dealProductSchedule);
                    lstDealProductSchedulesToBeCloned.add(dealProductSchedule);
                }
            }
        }
        System.debug('lstDealProductSchedulesToBeCloned::'+lstDealProductSchedulesToBeCloned);

        if(!lstDealProductSchedulesToBeCloned.isEmpty()){
            Database.UpsertResult[] saveResultList = Database.upsert(lstDealProductSchedulesToBeCloned, false);
            OpportunityLineItemSchedule scheduleInstance;
            OpportunityLineItem dealProduct;
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.UpsertResult saveResultInstance = saveResultList[i];
                scheduleInstance = lstDealProductSchedulesToBeCloned[i];

                if(scheduleInstance != null){
                    if(saveResultInstance.isSuccess()){
                        setProcessedProductIds.add(scheduleInstance.OpportunityLineItem.Product2Id);
                        setProcessedDealProductIds.add(scheduleInstance.OpportunityLineItem.Product2Id + '-' + scheduleInstance.OpportunityLineItem.Opportunity.AccountId);
                    }else{
                        // Add these errors in Error wrapper Class and prepare a list of same
                        setProcessedProductIds.remove(scheduleInstance.OpportunityLineItem.Product2Id);
                        setProcessedDealProductIds.remove(scheduleInstance.OpportunityLineItem.Product2Id + '-' + scheduleInstance.OpportunityLineItem.Opportunity.AccountId);
                        
                        // Error Handling
                        system.debug('@@Error in deal product sch upsert-->');
                        List<String> lstErrors = new List<String>();
                        if(scheduleInstance.ScheduleDate == null){
                            lstErrors.add(System.Label.CRM_NR_Batch_Schedule_Date_is_Null + scheduleInstance.OpportunityLineItem.Product2Id);
                        }

                        for(Database.Error err : saveResultInstance.getErrors()){
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = scheduleInstance.OpportunityLineItemId;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(new CRMJV_AutoPhysicalNRDealServiceException(scheduleInstance.OpportunityLineItem.Product2Id,lstErrors));
                    }
                }
            }
        }

        System.debug('--mapDealUniqueStringToInstanceForCommitted---before--->'+mapDealUniqueStringToInstanceForCommitted);

        // Change the stage back to Approved OR Committed for deals whose Deal Products have been updated / inserted / deleted
        if(mapDealUniqueStringToInstanceForCommitted.size() > 0 && !mapDealUniqueStringToInstanceForCommitted.values().isEmpty()){
            for(Opportunity approvedOrCommittedDeal : mapDealUniqueStringToInstanceForCommitted.values()){
                if(approvedOrCommittedDeal.Id != null && approvedOrCommittedDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED){
                    if(mapDealToStageNameForCommitted.containsKey(approvedOrCommittedDeal.Id) && mapDealToStageNameForCommitted.get(approvedOrCommittedDeal.Id) == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                        approvedOrCommittedDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
                        approvedOrCommittedDeal.Admin_Status__c = 'Sent to SAP';
                    }else if(mapDealToStageNameForCommitted.containsKey(approvedOrCommittedDeal.Id) && mapDealToStageNameForCommitted.get(approvedOrCommittedDeal.Id) == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED){
                        approvedOrCommittedDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                    }
                }
            }
            System.debug('--mapDealUniqueStringToInstanceForCommitted---after--->'+mapDealUniqueStringToInstanceForCommitted);
            //if(mapDealUniqueStringToInstanceForCommitted.size() > 0 && !mapDealUniqueStringToInstanceForCommitted.values().isEmpty()){
                Database.SaveResult[] saveResultList = Database.update(mapDealUniqueStringToInstanceForCommitted.values(),false);
                Opportunity deal;
                for(Integer i = 0; i < saveResultList.size(); i++){
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    deal = mapDealUniqueStringToInstanceForCommitted.values()[i];
                    System.debug('deal:222:'+deal);
                    if(deal != null){
                        if(!saveResultInstance.isSuccess()){
                            system.debug('@@Error in revise to commit deal-->');
                            // Error Handling
                            List<String> lstErrors = new List<String>();
                            lstErrors.add(String.format(System.Label.CRM_Deal_Not_Processed,new String[]{deal.Name,deal.AccountId}));

                            for(Database.Error err : saveResultInstance.getErrors()){
                                lstErrors.add(err.getMessage());

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }

                            if(mapDealNameToErrorList.containsKey(deal.Name)){
                                List<String> errorList = mapDealNameToErrorList.get(deal.Name);
                                errorList.addAll(lstErrors);
                                mapDealNameToErrorList.put(deal.Name, errorList);
                            }else{
                                mapDealNameToErrorList.put(deal.Name, lstErrors);
                            }
                        }
                    }
                }
            //}
        }

        if(setNewlyInsertedUniqueDPKey.size() > 0){
            for(OpportunityLineItem dealProduct : [SELECT Id,Opportunity.AccountId,Product2Id FROM OpportunityLineItem WHERE Product2Id IN: setProcessedProductIds AND NR_Deal_Product_Unique_Key__c IN: setNewlyInsertedUniqueDPKey]){
                setProcessedDealProductIds.add(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
            }
        }

        system.debug('@@setProcessedProductIds-->'+setProcessedProductIds);
        // Reset Target 
        processTargetFlags(
            lstNRProducts, lstSoldToAccounts, setProcessedDealProductIds, setProcessedProductIds,
            setProductAndAccountIdForTargets, mapProductAndAccountIdToTargetDetailList, 
            listErrorLog, lstExceptions
        );

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
        
        return lstExceptions;
    }

    /**
     * @Description - Method to process all the Deals
     * @name processAllDeals 
     * @param productInstance - Instance of Product for which Deal needs to be created
     * @param accountInstance - Instance of the Account for which Deal needs to be created
     * @param mapAccountIdToAllDeals - Map of Account Id to All Deals(New & Existing)
     * @param setProductAndAccountIdForTargets - Map of Product Id to corresponding List of Targets
     * @param lstDeleteDealProductsToBeCloned - List of existing Deal Products which needs to be deleted if Street Date of product is changed
     * @return Boolean - Boolean variable to decide whether new deal needs to be created or not. 
     */
    private static Boolean processAllDeals(
            Product2 productInstance, Account accountInstance, Map<Id, List<Opportunity>> mapAccountIdToAllDeals,
            Set<String> setProductAndAccountIdForTargets, List<OpportunityLineItem> lstDeleteDealProductsToBeCloned,
            Map<String, List<Pricebook_Entry_Period__c>> mapIdToPBEPList, Set<Id> setProcessedProductIds,
            Map<String,List<OpportunityLineItem>> mapProductIdToExistingDealProducts, Set<Id> setPriceBookIds, Map<String, OpportunityLineItem> mapExistingDealProducts,
            Set<Id> setProcessedDealIds, Map<String, OpportunityLineItem> mapNewDealProductsToUpsert, Map<String, List<Product2>> mapDealNameToProductInstance,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP, Map<String, List<OpportunityLineItemSchedule>> mapExistingDealProductsWithSchedules,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal, Map<String, Opportunity> mapDealUniqueStringToInstanceForCommitted,
            Id dealRecordType){

        Boolean bCreateNewDeal = false;
        Opportunity validDealInstance ;
        for(Opportunity dealInstance : mapAccountIdToAllDeals.get(accountInstance.Id)){
            if(isValidDeal(accountInstance, dealInstance, productInstance, dealRecordType)){
                validDealInstance = dealInstance;
                System.debug('validDealInstance::'+validDealInstance);
                break;
            }
        }
        // Check the product streetDate lie inside deal start date and End date &&
        // Check the deal stage = NR Default OR Planned
        if(validDealInstance != null){
            Boolean updateCommittedDealAllowed = false;

            if(accountInstance.Class_of_Trade__c != null){
                priceType.add(accountInstance.Class_of_Trade__c.toUpperCase());  
            }
            for(String pbepPriceType: priceType){
                //String accountCOT = accountInstance.Class_of_Trade__c != null ? '-' + accountInstance.Class_of_Trade__c.toUpperCase() : '';
                String strKey = productInstance.ProductCode + '-' + validDealInstance.Pricebook2Id + '-' + validDealInstance.CurrencyIsoCode + '-' + pbepPriceType;
                System.debug('@@processAllDeals(strKey)-->'+strKey+'--'+mapIdToPBEPList.containsKey(strKey));
                if(mapIdToPBEPList.containsKey(strKey) && !mapUniqueKeyToValidPBEP.containsKey(strKey)){
                    for(Pricebook_Entry_Period__c pbep : mapIdToPBEPList.get(strKey)){
                        if(isValidPBEP(pbep, validDealInstance, productInstance)){
                            mapUniqueKeyToValidPBEP.put(strKey, pbep);
                            break;
                        }
                    }
                }
            }

            // If valid Deal Stage is NR Default then only proceed with all Scenario execution
            String accountCOT = accountInstance.Class_of_Trade__c != null ? accountInstance.Class_of_Trade__c.toUpperCase() : '';
            String strKey = productInstance.ProductCode + '-' + validDealInstance.Pricebook2Id + '-' + validDealInstance.CurrencyIsoCode;

            if(productInstance.NR_Product_Created__c && isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP))){

                // Process for S1
                processScenarioOne(productInstance, validDealInstance,setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal, accountCOT);
                updateCommittedDealAllowed = true;
            }else if(productInstance.Street_Date_Has_Changed__c){
                if(validDealInstance.Id != null){
                    // Process for S2 & S2 + S3 for existing valid deal which is inserted
                    lstDeleteDealProductsToBeCloned.addAll(
                        processScenarioTwo(
                            productInstance, 
                            validDealInstance,
                            setProductAndAccountIdForTargets,
                            setProcessedProductIds,
                            mapProductIdToExistingDealProducts,
                            setPriceBookIds,
                            mapExistingDealProducts,
                            mapNewDealProductsToUpsert,
                            mapUniqueKeyToValidPBEP,
                            mapExistingDealProductsWithSchedules,
                            mapProductIdAndAssociatedDeal,
                            accountCOT
                        )
                    );
                    updateCommittedDealAllowed = true;
                }else if(isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP))){

                    // Add to mapDealNameToProductInstance if Street Date of Product is changed and valid deal is newly created through Batch
                    // P1 (NR) -> D1 newly created (Id = null)
                    // P2 (SD) -> D1 not inserted (Id = null)
                    if(mapDealNameToProductInstance.containsKey(validDealInstance.Name + '-' + validDealInstance.AccountId)){
                        mapDealNameToProductInstance.get(validDealInstance.Name + '-' + validDealInstance.AccountId).add(productInstance);
                    }else{
                        mapDealNameToProductInstance.put(validDealInstance.Name + '-' + validDealInstance.AccountId, new List<Product2>{productInstance});
                    }
                }else{
                    setProcessedProductIds.add(productInstance.Id);
                }
            }else if(setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + validDealInstance.AccountId) &&
                        isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP))){
                // Process for S3
                processScenarioThree(
                    productInstance,
                    validDealInstance,
                    setProcessedProductIds,
                    setPriceBookIds,
                    mapUniqueKeyToValidPBEP,
                    mapProductIdAndAssociatedDeal,
                    accountCOT);
                updateCommittedDealAllowed = true;
            }else if(isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP)) /*&&
                    mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c*/){
                processScenarioOne(productInstance, validDealInstance,setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal, accountCOT);
                updateCommittedDealAllowed = true;
            }else{
                setProcessedProductIds.add(productInstance.Id);
            }

            bCreateNewDeal = false;
            if(validDealInstance.Id != null && updateCommittedDealAllowed){
                //String uniqueKey = validDealInstance.Id + '-' + validDealInstance.StageName;
                //if(uniqueKey != null && !mapDealUniqueStringToInstanceForCommitted.containsKey(uniqueKey) &&
                if(!mapDealUniqueStringToInstanceForCommitted.containsKey(validDealInstance.Id) &&
                        isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP)) && 
                        (validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                            validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED ||
                            validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED)){
                    
                    mapDealToStageNameForCommitted.put(validDealInstance.Id,validDealInstance.StageName);
                    if(validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                        validDealInstance.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                        validDealInstance.Admin_Status__c = 'New';
                    }                    
                    //mapDealUniqueStringToInstanceForCommitted.put(uniqueKey, validDealInstance);
                    mapDealUniqueStringToInstanceForCommitted.put(validDealInstance.Id, validDealInstance);
                }
                setProcessedDealIds.add(validDealInstance.Id);
            }
        }else{
            System.debug('--no valid deal else -->');
            bCreateNewDeal = true;
        }
        return bCreateNewDeal;
    }

    /**
     * @Description - Method to check if the Deal is valid with respect to Product
     * @name isValidDeal 
     * @param Opportunity dealInstance - Existing deal instance that needs to be validated
     * @param Product2 productInstance - NR product instance to match some criterias with the existing deal
     * @return Boolean Returns true if all the criteris match with the exsting deal for the specified NR product
     */
    private static Boolean isValidDeal(Account accountInstance, Opportunity dealInstance, Product2 productInstance, Id dealRecordTypeId){
        Boolean isValid = false;
        String strdealProductType = productInstance.Type__c;
        String dealPeriod = '';
        String dealUniqueKey = '';

        Datetime sDate = datetime.newInstance(productInstance.Street_Date__c.year(),productInstance.Street_Date__c.month(),productInstance.Street_Date__c.day());
        String currentMonth = sDate.format('MMM');
        dealPeriod = currentMonth + String.valueOf(productInstance.Street_Date__c.year());

        if(dealInstance.Product_Type__c != null){
            dealUniqueKey = accountInstance.Id + '-' + dealPeriod + '-' + fetchProductTypeShortName(dealInstance.Product_Type__c) + '-' + mapDealRecordTypeToShortName.get(dealInstance.RecordTypeId);
        }
        System.debug('@@dealUniqueKey-->'+dealUniqueKey);

        if ((dealInstance.Start_Date__c <= productInstance.Street_Date__c && dealInstance.CloseDate >= productInstance.Street_Date__c) &&
                (dealInstance.RecordTypeId == dealRecordTypeId ) &&
                (dealInstance.Product_Type__c != null && strdealProductType != null && strdealProductType.contains(dealInstance.Product_Type__c)) &&
                (dealUniqueKey != null && dealInstance.NR_Deal_Unique_Key__c != null && dealUniqueKey == dealInstance.NR_Deal_Unique_Key__c)){
            isValid = true;
        }
        System.debug('@@Valid Deal-->'+isValid);
        return isValid;
    }

    /**
     * @Description - Method to process Target flags to reset the values for successfully processed deal products
     * @name processTargetFlags
     */
    private static void processTargetFlags(
            List<Product2> lstNRProducts, List<Account> lstSoldToAccounts, Set<String> setProcessedDealProductIds, Set<Id> setProcessedProductIds,
            Set<String> setProductAndAccountIdForTargets, Map<String, List<CRMJV_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
            List<CRM_ErrorLogger.ErrorLog> listErrorLog, List<CRMJV_AutoPhysicalNRDealServiceException> lstExceptions){

        Map<Id,Decimal> mapAccountPlanIdToUpdatedNRVersion = new Map<Id,Decimal>();
        for(Target__c targetInstance :[SELECT Id, NR_Version__c,Target_Revenue_Has_Changed__c,Product__c
                    FROM Target__c
                    WHERE Target_Revenue_Has_Changed__c = true AND RecordTypeId =: CRM_RecordTypeUtil.RT_TARGET_PRODUCT
                        AND (Target__c != null OR Target_Units__c != null)
                        AND Product__c != null AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT
                        AND Product__r.SAP_Sales_Org__c IN: CRM_AppConstants.SALES_JV_ORGS
                        AND Account__c != null AND Account__r.Planning_Customer__c = true
                        AND Account__r.Sales_Organization__c != null 
                        AND Account__r.Sales_Organization__c IN: CRM_AppConstants.SALES_JV_ORGS
                        AND Account__r.Video_Physical__c = true 
                        AND Account__r.Games_Physical__c = false
                        AND Account__r.Music_Physical__c = false 
                        AND Account__r.Video_Digital__c = false
                        AND Account__r.Games_Digital__c = false
                        AND Account__r.Music_Digital__c = false
                        AND Account__c IN: lstSoldToAccounts]){
            mapAccountPlanIdToUpdatedNRVersion.put(targetInstance.Id, targetInstance.NR_Version__c);
        }

        List<Target__c> updateProcessedTargetList = new List<Target__c>();
        for(String uniqueKey : setProductAndAccountIdForTargets){
            List<String> uniqueIds = uniqueKey.split('-');
            if(mapProductAndAccountIdToTargetDetailList.containsKey(uniqueKey) &&
                    mapProductAndAccountIdToTargetDetailList.get(uniqueKey) != null &&
                    mapProductAndAccountIdToTargetDetailList.get(uniqueKey).size() > 0 &&
                    (setProcessedDealProductIds.contains(uniqueKey) || setProcessedProductIds.contains(uniqueIds[0]))){
                
                for(CRMJV_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(uniqueKey)){                    
                    if (targetDetailInstance.targetInstance.Target_Revenue_Has_Changed__c == true &&
                            mapAccountPlanIdToUpdatedNRVersion.containsKey(targetDetailInstance.targetInstance.Id) &&
                            mapAccountPlanIdToUpdatedNRVersion.get(targetDetailInstance.targetInstance.Id) == targetDetailInstance.targetInstance.NR_Version__c
                    ){
                        targetDetailInstance.targetInstance.Target_Revenue_Has_Changed__c = false;
                        targetDetailInstance.targetInstance.NR_Version__c = 0;
                        updateProcessedTargetList.add(targetDetailInstance.targetInstance);
                    }                    
                }
            }
        }
        if(!updateProcessedTargetList.isEmpty()){
            listErrorLog.addAll(resetProcessedTargetFlags(updateProcessedTargetList, lstExceptions));
        }
    }    

    /**
     * @Description - Method to reset the Target_Revenue_Has_Changed__c flag as the NR Product is processed properly for that Target
     * @name resetProcessedTargetFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    public static List<CRM_ErrorLogger.ErrorLog> resetProcessedTargetFlags(List<Target__c> updateProcessedTargetList,
            List<CRMJV_AutoPhysicalNRDealServiceException> lstExceptions){

        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if(!updateProcessedTargetList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(updateProcessedTargetList,false);
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.SaveResult saveResultInstance = saveResultList[i];
                Target__c targetInstance = updateProcessedTargetList[i];
                if (!saveResultInstance.isSuccess()){
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    lstErrors.add(String.format(System.Label.CRM_Target_Not_Processed,new String[]{targetInstance.Id}));
                    for(Database.Error err : saveResultInstance.getErrors()){
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = targetInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    lstExceptions.add(new CRMJV_AutoPhysicalNRDealServiceException(targetInstance.Product__c,lstErrors));
                }
            }
        }
        return listErrorLog;
    }

    /**
     * @Description - Method to calculate Schedule Date for all the schedules that are cloned  when street Date is changed
     * @name calculateScheduleDateForClonedSchedules
     * @param dealProduct - Instance of deal product for which prodcut street Date has been changed
     * @param oldScheduleDate - Old Schedule Date which is recieved from Schedules for a deal product
     *                          that needs to be cloned for changed Street Date of its related Product
     * @return Date - New ScheduleDate calculated based on Street Date changed
     */
    private static Date calculateScheduleDateForClonedSchedules(OpportunityLineItem dealProduct, OpportunityLineItemSchedule scheduleRecord){
        Date newScheduleDate = null;
        Date oldScheduleDate = scheduleRecord.ScheduleDate;

        if(dealProduct.Product2.Previous_Street_Date__c != null && dealProduct.Product2.Street_Date__c != null && oldScheduleDate != null){
            Date oldStreetDate = dealProduct.Product2.Previous_Street_Date__c;
            Integer numberDaysDifference = oldStreetDate.daysBetween(oldScheduleDate);

            Date nweStreetDate = dealProduct.Product2.Street_Date__c;
            if(dealProduct.NR_Revenue_Recognition_Date__c != null && dealProduct.NR_Revenue_Recognition_Date__c != nweStreetDate &&
                    scheduleRecord.Description == CRM_AppConstants.SCHEDULE_INITIAL){
                Integer checkValidDifference = dealProduct.NR_Revenue_Recognition_Date__c.daysBetween(nweStreetDate);
                if(numberDaysDifference < 0){
                    if(checkValidDifference > 0){
                        checkValidDifference =  checkValidDifference * (-1);
                    }
                    if(checkValidDifference < numberDaysDifference){
                        numberDaysDifference = checkValidDifference;
                    }
                }else{
                    if((checkValidDifference > 0 && checkValidDifference > numberDaysDifference)){
                        numberDaysDifference = checkValidDifference * (-1);
                    }else if(checkValidDifference < 0){
                        numberDaysDifference = checkValidDifference;
                    }
                }
            }
            newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        }
        return newScheduleDate;
    }

    /**
     * @Description - Method to create Deal Product on Deal
     * @name  createDealProductOnDeal 
     * @param  mapIdToDeal - Map of Deal Id to Deal instance for which Deal Product needs to be created
     * @param  setProcessedProductIds - Set of processed Product Ids for which deals got inserted successfully
     */
    public static void createDealProductOnDeal(
        Set<Id> setProcessedProductIds,
        Map<Id, Product2> mapProductIdToInstance,
        Map<String, OpportunityLineItem> mapExistingDealProducts,
        Set<Id> setProcessedDealIds,
        Map<String, List<String>> mapDealNameToErrorList,
        Map<String, OpportunityLineItem> mapNewDealProductsToUpsert,
        Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
        Map<String,PricebookEntry> mapPriceBookEntry,
        Map<String, List<CRMJV_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
        List<CRMJV_AutoPhysicalNRDealServiceException> lstExceptions,
        Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal,
        Set<String> setProductAndAccountIdForTargets,
        Map<Id, Account> mapIdToAccountInstance){

        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        System.debug('--mapProductIdAndAssociatedDeal-->'+mapProductIdAndAssociatedDeal);

        for(Id productId : mapProductIdAndAssociatedDeal.keySet()){
            listDealWrappers.addAll(
                createDealWrapper(
                    mapProductIdAndAssociatedDeal.get(productId),
                    productId,
                    setProcessedProductIds,
                    setProcessedDealIds,
                    mapDealNameToErrorList,
                    lstExceptions
                )
            );
        }
        System.debug('---listDealWrappers--'+listDealWrappers);
        System.debug('---mapUniqueKeyToValidPBEP.keySet()-->'+mapUniqueKeyToValidPBEP.keySet());

        for(CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers){
            if(mapProductIdToInstance.containsKey(dw.productId)){
                String accountCOT = mapIdToAccountInstance.containsKey(dw.AccountId) && mapIdToAccountInstance.get(dw.AccountId).Class_of_Trade__c != null ? mapIdToAccountInstance.get(dw.AccountId).Class_of_Trade__c.toUpperCase() : '';
                String strKey = mapProductIdToInstance.get(dw.productId).ProductCode + '-' + dw.pricebookId + '-' + dw.dealCurrency;
                // Not initialized so that it is null when no Target details found
                CRMJV_TargetRevenueDetail validTargetDetailInstance;

                //if (pricingHandler != null && mapUniqueKeyToValidPBEP.containsKey(strKey) && mapProductIdToInstance.containsKey(dw.productId)){
                if(isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP)) && mapProductIdToInstance.containsKey(dw.productId)){
                    Boolean bCreateDealProductForInvalidTarget = false;

                    if(dw.AccountID != null && dw.productId != null &&
                            mapProductAndAccountIdToTargetDetailList.containsKey(dw.productId + '-' + dw.AccountID) &&
                            mapProductAndAccountIdToTargetDetailList.get(dw.productId + '-' + dw.AccountID) != null &&
                            mapProductAndAccountIdToTargetDetailList.get(dw.productId + '-' + dw.AccountID).size() > 0){
                        System.debug('@@in if-mapProductAndAccountIdToTargetDetailList.containsKey(dw.productId - dw.AccountID)-->'+ mapProductAndAccountIdToTargetDetailList.containsKey(dw.productId + '-' + dw.AccountID));
                        for(CRMJV_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(dw.productId + '-' + dw.AccountID)){
                            System.debug('@@In ifff1111 Valid Target targetDetailInstance -->' + targetDetailInstance);
                            Date releaseDate = mapProductIdToInstance.get(dw.productId).Street_Date__c;

                            // If Target record Present and it matches the Dates then take the Last Modified Target
                            if(targetDetailInstance.targetInstance != null){
                                if (releaseDate != null && targetDetailInstance.targetInstance.Calc_Start_Date__c <= releaseDate &&
                                        targetDetailInstance.targetInstance.Calc_End_Date__c >= releaseDate){
                                    validTargetDetailInstance = targetDetailInstance;
                                    bCreateDealProductForInvalidTarget = true;
                                    break;
                                }
                            }else{
                                bCreateDealProductForInvalidTarget = true;
                            }
                        }
                    }
                    // Dont create or update Deal Products, if no Target present
                    else if (
                            validTargetDetailInstance == null && mapProductIdToInstance.containsKey(dw.productId) &&
                            mapIdToAccountInstance.containsKey(dw.AccountId) &&
                            mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL){
                        bCreateDealProductForInvalidTarget = false;
                        System.debug('---in else if--->');
                    }
                    System.debug('--bCreateDealProductForInvalidTarget-->'+bCreateDealProductForInvalidTarget);

                    if(bCreateDealProductForInvalidTarget){
                        createDealProductRecord(
                            dw,
                            validTargetDetailInstance,
                            mapProductIdToInstance,
                            mapExistingDealProducts,
                            mapNewDealProductsToUpsert,
                            mapUniqueKeyToValidPBEP,
                            mapPriceBookEntry,
                            setProductAndAccountIdForTargets,
                            accountCOT
                        );
                    }
                }
            }
        }
    }

    /**
     * @Description - Method to create Deal Product on Deal
     * @name createDealProductRecord 
     * @param DealWrapper dw - DealWrapper record for creating Deal Product
     * @param Target__c target - To fetch Target Revenue for calculation of Quantity on Deal Product
     * @param CRM_ProductPricingHandler pricingHandler - To fetch List Price and File Discount for a product
     */
    private static void createDealProductRecord(
            CRM_ProductPricingHandler.DealWrapper dw,
            CRMJV_TargetRevenueDetail targetDetailInstance,
            Map<Id, Product2> mapProductIdToInstance,
            Map<String, OpportunityLineItem> mapExistingDealProducts,
            Map<String, OpportunityLineItem> mapNewDealProductsToUpsert,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<String,PricebookEntry> mapPriceBookEntry,
            Set<String> setProductAndAccountIdForTargets,
            String accountCOT){

        String strKey = mapProductIdToInstance.get(dw.productId).ProductCode + '-' + dw.pricebookId + '-' + dw.dealCurrency;
        String dealPeriod = datetime.newInstance(mapProductIdToInstance.get(dw.productId).Street_Date__c.year(),mapProductIdToInstance.get(dw.productId).Street_Date__c.month(),mapProductIdToInstance.get(dw.productId).Street_Date__c.day()).format('MMM') + String.valueOf(mapProductIdToInstance.get(dw.productId).Street_Date__c.year());
        System.debug('@@strKey dealproduct-->'+strKey+'=='+accountCOT+'=='+dealPeriod);

        OpportunityLineItem objDealProduct = new OpportunityLineItem();
        //if(accountPrice > 0 && mapPriceBookEntry.containsKey(dw.pricebookId + '-' + dw.productId + '-' + dw.dealCurrency)){
        if(mapPriceBookEntry.containsKey(dw.pricebookId + '-' + dw.productId + '-' + dw.dealCurrency)){
            // Below code executes only for Scenario 3
            // mapExistingDealProducts -> map is used to check existing batch created deal products fetched through query
            // Scenario 2 + 3 : mapNewDealProductsToUpsert -> map is used to check deal products cloned in Scenario 2 only and needs to be modified in Scenario 3
            if(mapExistingDealProducts.containsKey(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency) ||
                mapNewDealProductsToUpsert.containsKey(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency)){

                // Fetch all the exsitng batch generated deal products only in case of Scenario 3
                objDealProduct =
                    mapExistingDealProducts.containsKey(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency)
                    ? mapExistingDealProducts.get(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency)
                    : mapNewDealProductsToUpsert.get(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency);
 
                // Update the quantity of existing deal product in case of Scenario 3 for any deal product
                if(objDealProduct != null){
                    System.debug('-in if Scenario 3 update--->');
                    mapNewDealProductsToUpsert.put(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency,
                        setDealProductValues(
                            objDealProduct,
                            dw,
                            targetDetailInstance,
                            mapUniqueKeyToValidPBEP,
                            mapPriceBookEntry,
                            mapProductIdToInstance,
                            accountCOT
                        )
                    );
                }
                // If no existing batch generated deal product exists, create new deal product for Scenario 1
                // Or Scenario 2 (where we need to execute it as Scenario 1 in case of no deal products found to be cloned)
            }else{
                System.debug('-in if-else->');
                if(mapProductIdToInstance.containsKey(dw.productId) || isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP))){
                    
                    Boolean isNewDealProductInsertAllowed =
                        targetDetailInstance != null && setProductAndAccountIdForTargets.contains(dw.productId + '-' + dw.accountId);
                    
                    if(mapProductIdToInstance.get(dw.productId).NR_Product_Created__c ||
                            mapProductIdToInstance.get(dw.productId).Street_Date_Has_Changed__c ||
                            //mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c ||
                            isNewDealProductInsertAllowed){

                        objDealProduct = new OpportunityLineItem();
                        objDealProduct.NR_Deal_Product_Unique_Key__c = dw.accountId + '-' + dw.productId + '-' + mapDealRecordTypeToShortName.get(dw.dealRecordTypeId);
                        //objDealProduct.NR_Deal_Product_Unique_Key__c = dw.accountId + '-' + dw.productId + '-' + dealPeriod + '-' + mapDealRecordTypeToShortName.get(dw.dealRecordTypeId);
                        mapNewDealProductsToUpsert.put(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency,
                            setDealProductValues(
                                objDealProduct,
                                dw,
                                targetDetailInstance,
                                mapUniqueKeyToValidPBEP,
                                mapPriceBookEntry,
                                mapProductIdToInstance,
                                accountCOT
                            )
                        );
                    }
                }
            }
        }
    }

    /**
     * @Description - Method to set Deal Products values
     * @name setDealProductValues 
     * @param OpportunityLineItem objDealProduct 
     * @param DealWrapper dw - DealWrapper record for creating Deal Product
     * @param Target__c target - To fetch Target Revenue for calculation of Quantity on Deal Product
     * @param CRM_ProductPricingHandler pricingHandler - To fetch List Price and File Discount for a product
     */
    private static OpportunityLineItem setDealProductValues(
            OpportunityLineItem objDealProduct,
            CRM_ProductPricingHandler.DealWrapper dw,
            CRMJV_TargetRevenueDetail targetDetailInstance,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<String,PricebookEntry> mapPriceBookEntry,
            Map<Id, Product2> mapProductIdToInstance,
            String accountCOT){

        System.debug('@@dw.dealId-->'+dw.dealId+'--@@IsCommitedDeal-->'+mapDealUniqueStringToInstanceForCommitted.containsKey(dw.dealId));
        if(objDealProduct.Id == null){
            objDealProduct.OpportunityId = dw.dealId;
            objDealProduct.PricebookEntryId = mapPriceBookEntry.get(dw.pricebookId + '-' + dw.productId + '-' + dw.dealCurrency).Id;
            objDealProduct.Quantity = 1;
        }
        if(dw.dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
            objDealProduct.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            objDealProduct.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }else if(dw.dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
            objDealProduct.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
        }
        objDealProduct.Start_Date__c = dw.dealStartDate;
        objDealProduct.End_Date__c = dw.dealEndDate;

        String strKey = mapProductIdToInstance.get(dw.productId).ProductCode + '-' + dw.pricebookId + '-' + dw.dealCurrency;
        System.debug('@@strKey setdealproductval-->'+strKey+'=='+accountCOT);
        Map<String,String> validCOTPBEP = getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP);
        if(isValidCOTPBEP(validCOTPBEP)){
            //Pricebook_Entry_Period__c pbep = mapUniqueKeyToValidPBEP.get(strKey);
            objDealProduct.ListPrice__c = Double.valueOf(validCOTPBEP.get('PBEPPRICE'));
            objDealProduct.UnitPrice = Double.valueOf(validCOTPBEP.get('PBEPPRICE'));
            if(objDealProduct.Pricebook_Entry_Period__c != validCOTPBEP.get('PBEPID')){
                objDealProduct.Pricebook_Entry_Period__c = validCOTPBEP.get('PBEPID');
            }
        }

        System.debug('@@targetDetailInstance-->'+targetDetailInstance);
        // Set quantity 0 if target record or its target revenue value is not present
        Decimal calculatedQuantity = 0;
        if(targetDetailInstance != null){
            if(objDealProduct.ListPrice__c != null && objDealProduct.ListPrice__c > 0){            
                if(targetDetailInstance.targetInstance != null && targetDetailInstance.targetInstance.Target_Units__c != null &&
                        targetDetailInstance.targetInstance.Target_Units__c > 0){
                    calculatedQuantity = targetDetailInstance.targetInstance.Target_Units__c;
                }else if(targetDetailInstance.targetInstance != null && targetDetailInstance.targetInstance.Target__c != null &&
                        targetDetailInstance.targetInstance.Target__c > 0){
                    calculatedQuantity = Math.ceil(targetDetailInstance.targetInstance.Target__c / objDealProduct.ListPrice__c);
                }                
            }
        }
        objDealProduct.Target_Quantity__c = calculatedQuantity;

        if(mapDealUniqueStringToInstanceForCommitted.containsKey(dw.dealId)){
            Opportunity commitedDeal = mapDealUniqueStringToInstanceForCommitted.get(dw.dealId);
            if(commitedDeal.RecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                objDealProduct.DFI_Status__c = 'Cancel';
                objDealProduct.Is_Canceled__c = true;
                if(!objDealProduct.NR_Deal_Product_Unique_Key__c.contains('Cancel')){
                    objDealProduct.NR_Deal_Product_Unique_Key__c = objDealProduct.NR_Deal_Product_Unique_Key__c + '-Cancel';
                }
            }
        }
        System.debug('objDealProduct----->'+objDealProduct);
        return objDealProduct;
    }

    /**
     * @Description - Method to create DealWrapper using Deal and PriceBookEntry
     * @name createDealWrapper 
     * @param lstDeals - List of Deals for wich DealWrapper needs to be created
     * @param productId - ProductId for which DealWrapper needs to be created
     * @param setProcessedProductIds - Set of processed Product Ids for which deals got inserted successfully
     * @return CRM_ProductPricingHandler.DealWrapper[] - List of DealWrappers
     */
    public static CRM_ProductPricingHandler.DealWrapper[] createDealWrapper(
            List<Opportunity> lstDeals,
            Id productId,
            Set<Id> setProcessedProductIds,
            Set<Id> setProcessedDealIds,
            Map<String, List<String>> mapDealNameToErrorList,
            List<CRMJV_AutoPhysicalNRDealServiceException> lstExceptions){

        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        for(Opportunity deal :lstDeals){
            if(setProcessedDealIds.contains(deal.Id)){
                CRM_ProductPricingHandler.DealWrapper currentDealWrapper = new CRM_ProductPricingHandler.DealWrapper();
                currentDealWrapper.dealId = deal.Id;
                currentDealWrapper.accountId = deal.AccountID;
                currentDealWrapper.dealCurrency = deal.CurrencyIsoCode;
                currentDealWrapper.productId = productId;
                currentDealWrapper.pricebookId = deal.Pricebook2ID;
                currentDealWrapper.dealStartDate = deal.Start_Date__c;
                currentDealWrapper.dealEndDate = deal.CloseDate;
                currentDealWrapper.dealRecordTypeId = deal.RecordTypeId;

                setProcessedProductIds.add(productId);
                listDealWrappers.add(currentDealWrapper);
            }else{
                setProcessedProductIds.remove(productId);
                if(mapDealNameToErrorList.containsKey(deal.Name) && deal.Id == null){
                    lstExceptions.add(new CRMJV_AutoPhysicalNRDealServiceException(productId,mapDealNameToErrorList.get(deal.Name)));
                }
            }
        }
        return listDealWrappers;
    }    

    /**
     * @Description - Method to fetch PricebookEntry details for particular Products and PriceBooks
     *                used in deals used for deal product creation
     * @name fetchPriceBookEntryForProduct
     */
    public static Map<Id,PricebookEntry> fetchPriceBookEntryForProduct(Set<Id> setPriceBookIds,Map<Id, Product2> mapProductIdToInstance,Map<String,PricebookEntry> mapPriceBookEntry){
        Map<Id, PricebookEntry> mapPBEIdToInstance = new Map<Id, PricebookEntry>([
                SELECT Product2Id, Pricebook2Id, UnitPrice, CurrencyIsoCode, IsActive
                FROM PriceBookEntry
                WHERE Product2Id IN: mapProductIdToInstance.keySet() AND Pricebook2Id IN: setPriceBookIds AND IsActive = true]);

        for(PricebookEntry pricBkEntry : mapPBEIdToInstance.values()){
            mapPriceBookEntry.put(pricBkEntry.Pricebook2Id + '-' + pricBkEntry.Product2Id + '-' + pricBkEntry.CurrencyIsoCode,pricBkEntry);
        }
        return mapPBEIdToInstance;
    }

    /**
     * @Description - Method to process Scenario 2 i.e. All the Products whose Street Date has been changed
     * @name processScenarioTwo 
     * @param productInstance - Instance of Product for which Deal Product needs to be processed
     * @param accountInstance - Instance of the Account for which Deal Product needs to be processed
     */
    public static List<OpportunityLineItem> processScenarioTwo(
            Product2 productInstance,
            Opportunity dealInstance,
            Set<String> setProductAndAccountIdForTargets,
            Set<Id> setProcessedProductIds,
            Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts,
            Set<Id> setPriceBookIds,
            Map<String, OpportunityLineItem> mapExistingDealProducts,
            Map<String, OpportunityLineItem> mapNewDealProductsToUpsert,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<String, List<OpportunityLineItemSchedule>> mapExistingDealProductsWithSchedules,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal,
            String accountCOT){

        List<OpportunityLineItem> lstDeleteDealProductsToBeCloned = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> lstClonedSchedule = new List<OpportunityLineItemSchedule>();
        Boolean dealProductForValidDealPresent = false;
        OpportunityLineItem validDealProductToCloneInstance;
        
        String dealPeriod = datetime.newInstance(productInstance.Street_Date__c.year(),productInstance.Street_Date__c.month(),productInstance.Street_Date__c.day()).format('MMM') + String.valueOf(productInstance.Street_Date__c.year());
        String dealProductUniqueKey = dealInstance.AccountId +'-'+ productInstance.Id +'-'+ mapDealRecordTypeToShortName.get(dealInstance.RecordTypeId);
        //String dealProductUniqueKey = dealInstance.AccountId +'-'+ productInstance.Id +'-'+ dealPeriod +'-'+ mapDealRecordTypeToShortName.get(dealInstance.RecordTypeId);
        system.debug('@@dealProductUniqueKey-->'+dealProductUniqueKey);

        if(mapProductIdToExistingDealProducts.containsKey(dealProductUniqueKey)){
            System.debug('-S2---->');
            for(OpportunityLineItem dealProduct :mapProductIdToExistingDealProducts.get(dealProductUniqueKey)){
                System.debug('In for!!!');
                if(dealProduct.OpportunityId != dealInstance.Id){
                    validDealProductToCloneInstance = dealProduct;
                    break;
                }else{
                    dealProductForValidDealPresent = true;

                    // Get the scedules so that its Date can be recalculated if the deal Product present in valid deal as only the month changes but Quarter is same
                    if(!dealProduct.Manually_Schedule__c){
                        for(OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules){
                            lstClonedSchedule.add(schedule);
                        }
                    }
                    System.debug('existing own deal product schedule lstClonedSchedule::' + lstClonedSchedule);

                    if(lstClonedSchedule != null && !lstClonedSchedule.isEmpty()){
                        mapExistingDealProductsWithSchedules.put(dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,lstClonedSchedule);
                    }
                    break;
                }
            }
        } 
        System.debug('-----validDealProductToCloneInstance-->'+validDealProductToCloneInstance);
        System.debug('-----dealProductForValidDealPresent-->'+dealProductForValidDealPresent);

        if(validDealProductToCloneInstance != null){
            // Clone deal Product present in any deal Stage            
            //String accountCOT = dealInstance.Account.Class_of_Trade__c != null ? '-' + dealInstance.Account.Class_of_Trade__c.toUpperCase() : '';
            String strKey = productInstance.ProductCode + '-' + dealInstance.Pricebook2Id + '-' + dealInstance.CurrencyIsoCode;
            System.debug('-strKey 22--->'+strKey+'=='+accountCOT);

            // Before cloning check the deal product having uniqueKey is not present for the valid deal
            // D1 -> DP1 to be cloned for P1
            // D2 valid Deal -> already contains DP2 for P1
            // Do not clone DP1 as DP2 with uniqueKey already presnt
            if(!mapExistingDealProducts.containsKey(dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode)){

                // Only the product which has been cloned should be deleted
                lstDeleteDealProductsToBeCloned.add(validDealProductToCloneInstance);
                if(isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP))){
                    OpportunityLineItem clonedDealProduct = validDealProductToCloneInstance.clone();
                    clonedDealProduct.OpportunityId = dealInstance.Id;
                    System.debug('--dealProduct-S2->'+validDealProductToCloneInstance);
                    System.debug('--clonedDealProduct-S2->'+clonedDealProduct);

                    mapNewDealProductsToUpsert.put(dealInstance.Id + '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,clonedDealProduct);
                    System.debug('clonedDealProduct.OpportunityLineItemSchedules::'+clonedDealProduct.OpportunityLineItemSchedules);

                    if (clonedDealProduct.Manually_Schedule__c){
                        for(OpportunityLineItemSchedule schedule : validDealProductToCloneInstance.OpportunityLineItemSchedules){
                            OpportunityLineItemSchedule clonedSchedule = schedule.clone();
                            lstClonedSchedule.add(clonedSchedule);
                        }
                    }
                    System.debug('lstClonedSchedule::'+lstClonedSchedule);

                    if(lstClonedSchedule != null && !lstClonedSchedule.isEmpty()){
                        mapExistingDealProductsWithSchedules.put(dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,lstClonedSchedule);
                    }

                    // Process for S3
                    processScenarioThree(
                        productInstance,
                        dealInstance,
                        setProcessedProductIds,
                        setPriceBookIds,
                        mapUniqueKeyToValidPBEP,
                        mapProductIdAndAssociatedDeal,
                        accountCOT);
                }else{
                    setProcessedProductIds.add(productInstance.Id);
                }
            }else{
                //--Add deal product to delete list, if deap product moved to other valid deal and those valid deal has already have same product--Start--//
                system.debug('###');
                lstDeleteDealProductsToBeCloned.add(validDealProductToCloneInstance);
                //----//
                setProcessedProductIds.add(productInstance.Id);
            }
        }else{
            System.debug('-----IN ELSE-->');
            if(!dealProductForValidDealPresent){
                System.debug('-S2--S1--->');
                processScenarioOne(productInstance, dealInstance, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP,mapProductIdAndAssociatedDeal,accountCOT);
            }else{
                if(setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + dealInstance.AccountId)){
                    // Process for S3
                    processScenarioThree(
                        productInstance,
                        dealInstance,
                        setProcessedProductIds,
                        setPriceBookIds,
                        mapUniqueKeyToValidPBEP,
                        mapProductIdAndAssociatedDeal,
                        accountCOT);
                }else{
                    setProcessedProductIds.add(productInstance.Id);
                }
            }
        }
        return lstDeleteDealProductsToBeCloned;
    }

    /**
     * @Description - Method to process Scenario 1 i.e. All the New Release Product which are created today
     * @name processScenarioOne 
     * @param productInstance - Instance of Product for which Deal needs to be created
     * @param accountInstance - Instance of the Account for which Deal needs to be created
     */
    public static void processScenarioOne(
            Product2 productInstance,
            Opportunity dealInstance,
            Set<Id> setProcessedProductIds,
            Set<Id> setPriceBookIds,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal,
            String accountCOT){
        System.debug('-S1--->');
        //String accountCOT = dealInstance.Account.Class_of_Trade__c != null ? '-' + dealInstance.Account.Class_of_Trade__c.toUpperCase() : '';
        String strKey = productInstance.ProductCode + '-' + dealInstance.Pricebook2Id + '-' + dealInstance.CurrencyIsoCode;
        System.debug('-strKey S1--->'+strKey+'=='+accountCOT);

        if(isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP))){
            // Found existing deal for product
            if(mapProductIdAndAssociatedDeal.containsKey(productInstance.Id)) {
                mapProductIdAndAssociatedDeal.get(productInstance.Id).add(dealInstance);
            }else{
                mapProductIdAndAssociatedDeal.put(productInstance.Id, new List<Opportunity> {dealInstance});
            }
            setPriceBookIds.add(dealInstance.PriceBook2Id);
        }else{
            setProcessedProductIds.add(productInstance.Id);
        }
    }

    /**
     * @Description - Method to process Scenario 3 i.e. All the Products whose Target Revenue has been changed
     * @name processScenarioThree 
     * @param productInstance - Instance of Product for which Deal Product needs to be processed
     * @param dealInstance - Instance of the Deal for which Deal Product needs to be processed
     */
    public static void processScenarioThree(
            Product2 productInstance,
            Opportunity dealInstance,
            Set<Id> setProcessedProductIds,
            Set<Id> setPriceBookIds,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal,
            String accountCOT){
        System.debug('--S3--->');
        processScenarioOne(productInstance, dealInstance, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal, accountCOT);
    }    

    /**
     * @Description - Method to fetch the deal Product that needs to be cloned
     * @name fetchDealProductToClone 
     * @param Account accountInstance - Account for which the deal Product needs to be decideed as Unique
     * @param Product2 productInstance - Product for which the Deal Product needs to be decideed as unique
     * @param Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts - Map of all Deal Products unique to the combination of Account and Product
     * @return accountInstance Return the deal product instance that needs to be cloned
     */
    public static OpportunityLineItem fetchDealProductToClone(Account accountInstance, Product2 productInstance,
            Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts, Id dealRecordType){
        OpportunityLineItem validDealProductToCloneInstance;
        String dealPeriod = datetime.newInstance(productInstance.Street_Date__c.year(),productInstance.Street_Date__c.month(),productInstance.Street_Date__c.day()).format('MMM') + String.valueOf(productInstance.Street_Date__c.year());
        String dealProductUniqueKey = accountInstance.Id +'-'+ productInstance.Id + '-' + mapDealRecordTypeToShortName.get(dealRecordType);
        //String dealProductUniqueKey = accountInstance.Id +'-'+ productInstance.Id +'-'+ dealPeriod + '-' + mapDealRecordTypeToShortName.get(dealRecordType);
        system.debug('@@dealProductUniqueKey2-->'+dealProductUniqueKey);

        if(mapProductIdToExistingDealProducts.containsKey(dealProductUniqueKey)){
            for(OpportunityLineItem dealProduct :mapProductIdToExistingDealProducts.get(dealProductUniqueKey)){
                validDealProductToCloneInstance = dealProduct;
                break;
            }
        } 
        return validDealProductToCloneInstance;
    }

    /**
     * @Description - Method to create New Deal
     * @name processNewDeals 
     * @param productInstance - Instance of Product for which Deal needs to be created
     * @param accountInstance - Instance of the Account for which Deal needs to be created
     * @param lstDeleteDealProductsToBeCloned - List of existing Deal Products which needs to be deleted if Street Date of product is changed
     * @param mapProductIdToAccountPlanList - Map of Product Id to corresponding List of Targets
     * @return newDealInserted - Boolean that returns true if New Deal is inserted else return false
     */
    public static Boolean processNewDeals(
            Opportunity newDeal,
            Product2 productInstance,
            Account accountInstance,
            List<OpportunityLineItem> lstDeleteDealProductsToBeCloned,
            List<Opportunity> lstNewDealsToInsert,
            Set<Id> setProcessedProductIds,
            Set<Id> setPriceBookIds,
            Map<String, List<Product2>> mapDealNameToProductInstance,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal,
            Set<String> setProductAndAccountIdForTargets){

        String accountCOT = accountInstance.Class_of_Trade__c != null ? accountInstance.Class_of_Trade__c.toUpperCase() : '';
        String strKey = productInstance.ProductCode + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode;
        system.debug('@@processNewDeals accountCOT-->'+accountCOT);
        Boolean newDealInserted = false;
        Boolean isNewPBEPInsert = isValidCOTPBEP(getValidCOTPBEP(strKey,accountCOT,mapUniqueKeyToValidPBEP));
        //Boolean isNewPBEPInsert = mapUniqueKeyToValidPBEP.containsKey(strKey) && mapUniqueKeyToValidPBEP.get(strKey) != null && mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c;
        Boolean isNewDealInsertAllowed = productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id);

        if(productInstance.NR_Product_Created__c){
            system.debug('@@NR_Product_Created__c');
            processScenarioOne(productInstance, newDeal, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal, accountCOT);
            lstNewDealsToInsert.add(newDeal);
            newDealInserted = true;
        }else if(productInstance.Street_Date_Has_Changed__c){
            system.debug('@@Street_Date_Has_Changed__c');            
            // Add to mapDealNameToProductInstance if Street Date of Product is changed and new deal is created through Batch
            if(mapDealNameToProductInstance.containsKey(newDeal.Name + '-' + newDeal.AccountId)){
                mapDealNameToProductInstance.get(newDeal.Name + '-' + newDeal.AccountId).add(productInstance);
            }else{
                mapDealNameToProductInstance.put(newDeal.Name + '-' + newDeal.AccountId, new List<Product2> {productInstance});
            }
            lstNewDealsToInsert.add(newDeal);
            newDealInserted = true;
        }else if(isNewDealInsertAllowed || isNewPBEPInsert){
            system.debug('@@Common');
            processScenarioOne(productInstance, newDeal, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal, accountCOT);
            lstNewDealsToInsert.add(newDeal);
            newDealInserted = true;
        }
        return newDealInserted;
    }

    private static Boolean isValidPBEP(Pricebook_Entry_Period__c pbepInstance,Opportunity dealInstance,Product2 productInstance){
        Boolean isValid = false;
        if(dealInstance.Start_Date__c >= pbepInstance.Start_Date__c && dealInstance.CloseDate <= pbepInstance.End_Date__c && productInstance.Id == pbepInstance.Product__c){
            isValid = true;
        }
        System.debug('@@isValidPBEP-->'+isValid);
        return isValid;
    }

    /**
     * @Description - Method to create Deal on an Account
     * @name createDealWithAccounts 
     * @param accountInstance - Instance of Account for which deal needs to be created
     * @param product - Instance of the Product for which deal needs to be created
     * @return Opportunity - Newly created Deal
     */
    private static Opportunity createDealWithAccounts(Account accountInstance,Product2 product,Id dealRecordType){
        String dealName = '';
        String dealPeriod = '';     
        String dealRecordTypeName = getRecordTypeNameById(CRM_AppConstants.OPPORTUNITY_OBJECT,dealRecordType);

        Map<String, Date> mapStartAndCloseDateForDeal = calculateDatesForDeal(product.Street_Date__c, CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(product.Street_Date__c.year(),product.Street_Date__c.month(),product.Street_Date__c.day());
        String currentMonth = sDate.format('MMM');
        dealPeriod = currentMonth;
        dealName = CRM_AppConstants.NR_Deal_Naming_Convention + product.Type__c + ' ' + dealPeriod+ ' ' + product.Street_Date__c.year();

        Opportunity deal = new Opportunity();
        deal.RecordtypeId = dealRecordType;
        deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        deal.CloseDate = mapStartAndCloseDateForDeal.get('End Date');
        deal.Promo_End_Date__c = mapStartAndCloseDateForDeal.get('End Date');
        deal.AccountId = accountInstance.Id;
        deal.Pricebook2Id = accountInstance.Price_Book__c;
        deal.CurrencyIsoCode = accountInstance.CurrencyIsoCode;
        deal.Start_Date__c = mapStartAndCloseDateForDeal.get('Start Date');
        deal.Promo_Start_Date__c = mapStartAndCloseDateForDeal.get('Start Date');
        deal.Type = System.Label.CRM_New_Business_Value;
        deal.Product_Type__c = product.Type__c;
        deal.NR_Deal_Unique_Key__c = accountInstance.Id + '-' + dealPeriod + String.valueOf(product.Street_Date__c.year()) + '-' + fetchProductTypeShortName(product.Type__c) + '-' + mapDealRecordTypeToShortName.get(dealRecordType);
        deal.OwnerId = accountInstance.OwnerId;
        deal.Market_Type__c = product.Product_Market__c;
        deal.Name = dealName +' '+ dealRecordTypeName + ' ' + accountInstance.Name;
        if(dealRecordType == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
        }else if(dealRecordType == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
            deal.Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CREDIT_MEMO;
        }
        return deal;
    }

    /**
     * @Description - Method to fetch Product Type Short Name
     * @name fetchProductType
     * @param productType - Type of Product
     * @return String - Short Name of Product Type
     */
    public static String fetchProductTypeShortName(String productType){
        String productTypeShortName = '';
        if(productType != null && productType == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE){
            productTypeShortName = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE_SHORT_NAME;
        }
        return productTypeShortName;
    }
    
    /**
     * @Description - Method to calculate start and end date on Deal based on Quarter or Month
     * @name calculateDatesForDeal 
     * @param streetDate - Street Date of Product
     * @param timeFrame - Timeframe with value 'Q' or 'M' based on Quarter or Month
     * @return Map<String, Date> - Map of start and end date on Deal
     */
    public static Map<String,Date> calculateDatesForDeal(Date streetDate,String timeFrame){
        Date startDate;
        Date endDate;
        Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();
        Integer monthDuration = Integer.valueOf(System.Label.CRMJV_NR_Deal_EndDate_Duration_In_Months);

        if(timeFrame == CRM_AppConstants.NR_Deal_For_Month){
            startDate = streetDate.toStartOfMonth();
            endDate = startDate.addMonths(monthDuration).toStartofMonth().addDays(-1);
        }

        mapStartAndCloseDateForDeal.put('Start Date', startDate);
        mapStartAndCloseDateForDeal.put('End Date', endDate);
        return mapStartAndCloseDateForDeal;
    }

    /**
     * @Description - Method to fetch Related Sold To Accounts for Product based on its Type
     * @name fetchRelatedAccounts
     * @param Product2 productInstance - NR product instance for which related Sold To Accoucts need to be fetched
     * @param Map<String, List<Account>> mapProductTypeWithRelatedAccounts - Map of Product Type with List of Accounts
     */
    public static Map<Id, Account> fetchRelatedAccounts(Product2 productInstance,Map<String, Set<Account>> mapProductTypeWithRelatedAccounts){
        Map<Id, Account> mapRelatedAccounts = new Map<Id, Account>();
        if(productInstance.Exclusive_Customer__c == null && mapProductTypeWithRelatedAccounts.containsKey(productInstance.Type__c)){
            for(Account acc: mapProductTypeWithRelatedAccounts.get(productInstance.Type__c)){
                if(!mapRelatedAccounts.containsKey(acc.Id) && productInstance.SAP_Sales_Org__c == acc.Sales_Organization__c){
                    mapRelatedAccounts.put(acc.Id,acc);
                }
            }
        }
        return mapRelatedAccounts;
    }

    /**
     * @Description - Method to fetch existing Deal Products for List of Products
     * @name fetchExistingDealProducts
     * @param List<Product2> productList List of NR Products
     */
    public static void fetchExistingDealProducts(
            List<Product2> productList, Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts,
            Map<String, OpportunityLineItem> mapExistingDealProducts, Map<Id, Opportunity> mapDealIdToInstance,
            Map<String, Opportunity> mapDealUniqueStringToInstanceForCommitted){

        System.debug('-productList--->'+productList);
        System.debug('-mapDealIdToInstance--->'+mapDealIdToInstance);

        for(OpportunityLineItem dealProductInsatnce : [SELECT Id, Discount, Description, Product2Id,OpportunityId,PricebookEntryId,CurrencyIsoCode,UnitPrice,
                                    ProductCode,Quantity, Subtotal, Account_Price__c, Returned_Quantity__c, Returned_Amount__c,
                                    Actual_Revenue__c, Approved_Qty__c, Contribution_is_Minimum__c,//Allocation_Override__c,
                                    Customer_Retail_Price__c,Customer_Sell_Price__c, Decay_Curve_Template__c,
                                    Distribution_Cost__c, Estimated_Quantity__c,Initial_Quantity__c, ListPrice__c,Manually_Schedule__c,
                                    Master_Negative__c, Merchandising__c, Minimum_Contribution__c, NR_Deal_Product_Unique_Key__c,
                                    Open_Amount__c, Open_Quantity__c, Override_COP__c, P_L_Decay_Curve_Template__c, P_L_Quantity__c, 
                                    PAP__c, POS_Quantity__c, POS_Revenue__c, Price_is_Minimum__c, Production_Cost__c,
                                    Replen_Delay_Days__c, Replen_Quantity__c, Returns__c, Promoted_Price__c,
                                    Royalty_Fee_Fixed__c, Sales_Allowance__c, Target_Quantity__c,Pricebook_Entry_Period__c,
                                    Rental_Revenue_Per_Unit__c, Handling_Fee__c, Rental_Price__c , Revenue_Share__c, Number_of_Rentals_per_Unit__c,
                                    Final_Purchase_Price__c , Final_Purchase__c, NR_Revenue_Recognition_Date__c, Override_Pricing__c,
                                    Opportunity.StageName, Opportunity.Pricebook2Id, Opportunity.CurrencyIsoCode, Opportunity.AccountId,
                                    Opportunity.Start_Date__c, Opportunity.CloseDate, Product2.Street_Date__c, Product2.Previous_Street_Date__c,
                                    Product2.Street_Date_Has_Changed__c,Opportunity.Sales_Organisation__c,Is_Canceled__c,Deal_Record_Type__c,DFI_Status__c,
                                    Credit_Note_Item__c,Credit_Note_Item__r.Credit_Note__r.Name,
                                    (SELECT Id, OpportunityLineItemId, OpportunityLineItem.Opportunity.AccountId, OpportunityLineItem.Product2Id,
                                            Type, Revenue, Quantity, Description, ScheduleDate, CurrencyIsoCode
                                        FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC)
                                FROM OpportunityLineItem
                                WHERE Product2Id IN: productList
                                    AND Product2.Street_Date__c != null AND Product2.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                                    AND OpportunityId IN: mapDealIdToInstance.keySet()                                    
                                    AND NR_Deal_Product_Unique_Key__c != null
                                ORDER BY Opportunity.LastModifiedDate, LastModifiedDate DESC]
        ){
            mapExistingDealProducts.put(dealProductInsatnce.OpportunityId + '-' + dealProductInsatnce.Product2Id + '-' + dealProductInsatnce.CurrencyIsoCode,dealProductInsatnce);

            if(mapProductIdToExistingDealProducts.containsKey(dealProductInsatnce.NR_Deal_Product_Unique_Key__c)){
                mapProductIdToExistingDealProducts.get(dealProductInsatnce.NR_Deal_Product_Unique_Key__c).add(dealProductInsatnce);
            }else{
                mapProductIdToExistingDealProducts.put(dealProductInsatnce.NR_Deal_Product_Unique_Key__c,new List<OpportunityLineItem>{dealProductInsatnce});
            }

            // Deal Product whose Street Date is chnaged needs to be moved from current committed deal to a new deal
            if(dealProductInsatnce.Product2.Street_Date_Has_Changed__c &&
                    mapDealIdToInstance.containsKey(dealProductInsatnce.OpportunityId) &&
                    mapDealIdToInstance.get(dealProductInsatnce.OpportunityId) != null && 
                    (mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                        mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED ||
                        mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED)){

                Opportunity dealInstance = mapDealIdToInstance.get(dealProductInsatnce.OpportunityId);
                //String uniqueKey = dealInstance.Id + '-' + dealInstance.StageName;

                mapDealToStageNameForCommitted.put(dealInstance.Id,dealInstance.StageName);
                if(mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                    dealInstance.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                    dealInstance.Admin_Status__c = 'New';
                }
                if(dealInstance.Owner.IsActive == false){
                    dealInstance.OwnerId = dealInstance.Account.OwnerId;
                }
                //mapDealUniqueStringToInstanceForCommitted.put(uniqueKey, dealInstance);
                mapDealUniqueStringToInstanceForCommitted.put(dealInstance.Id, dealInstance);
            }
            if(dealProductInsatnce.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL &&
                    dealProductInsatnce.Credit_Note_Item__c != null && dealProductInsatnce.Credit_Note_Item__r.Credit_Note__r.Name != null){
                mapPOSDealCreditNoteItemIdToName.put(dealProductInsatnce.Credit_Note_Item__c,dealProductInsatnce.Credit_Note_Item__r.Credit_Note__r.Name);
            }
        }
        system.debug('@@mapPOSDealCreditNoteItemIdToName-->'+mapPOSDealCreditNoteItemIdToName);
    }

   /**
     * @Description - Method to fetch a Map of Type with corresponding List of Accounts
     * @name fetchListOfAccountsForType
     * @param List<Account> lstSoldToAccounts - List of all Sold To accounts
     * @return Map<String, List<Account>> mapProductTypeWithRelatedAccounts - Map of Product Type with List of Accounts
     */
    public static Map<String,Set<Account>> fetchListOfAccountsForType(
            List<Account> lstSoldToAccounts,
            Map<Id, Opportunity> mapDealIdToInstance,
            Map<String, List<CRMJV_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
            Set<String> setProductAndAccountIdForTargets,
            Map<Id,Account> mapAccounts){

        Map<String,Set<Account>> mapProductTypeWithRelatedAccounts = new Map<String,Set<Account>>();
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE,new Set<Account>());

        for(Account acc : lstSoldToAccounts){
            if(acc.Storefront__c == null && acc.Video_Physical__c){
                mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE).add(acc);
            }           

            // Process on Target records
            System.debug('@@acc.Targets__r-->'+acc.Targets__r.size());
            for(Target__c targetInstance : acc.Targets__r){
                String uniqueKey = targetInstance.Product__c + '-' + targetInstance.Account__c;
                CRMJV_TargetRevenueDetail targetDetailsInstance = new CRMJV_TargetRevenueDetail();
                targetDetailsInstance.targetInstance = targetInstance;
                if(targetInstance.Target_Revenue_Has_Changed__c){
                    setProductAndAccountIdForTargets.add(uniqueKey);
                }
                targetDetailsInstance.salesOrg = targetInstance.Account__r.Sales_Organization__c;

                if(mapProductAndAccountIdToTargetDetailList.containsKey(uniqueKey)){
                    mapProductAndAccountIdToTargetDetailList.get(uniqueKey).add(targetDetailsInstance);
                }else{
                    mapProductAndAccountIdToTargetDetailList.put(uniqueKey,new List<CRMJV_TargetRevenueDetail>{targetDetailsInstance});
                }
            }
            System.debug('@@mapProductAndAccountIdToTargetDetailList-->'+mapProductAndAccountIdToTargetDetailList);

            for(Opportunity deal : acc.Opportunities){
                if(mapDealRecordTypeToShortName.containsKey(deal.RecordTypeId)){
                    mapDealIdToInstance.put(deal.Id, deal);
                }
            }
            
            mapAccounts.put(acc.Id,acc);
        }
        return mapProductTypeWithRelatedAccounts;
     }

    public static String getRecordTypeNameById(String objectName,Id strRecordTypeId){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }

    public static Map<String,String> getValidCOTPBEP(String strKey, String accountCOT, Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP){
        Map<String,String> mapValidCOTPBEP = new Map<String,String>();

        String key;
        Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();
        Double PBEPListPrice;
        Boolean isRetailMenuCOT = false;
        Set<String> setPromoDealerCOT = new Set<String>{CRM_AppConstants.PBEP_PRICE_TYPE_PROMOTION,CRM_AppConstants.PBEP_PRICE_TYPE_DEALER};
        List<String> listAccountCOT = new List<String>{CRM_AppConstants.PBEP_PRICE_TYPE_PROMOTION,CRM_AppConstants.PBEP_PRICE_TYPE_DEALER};
        if(!(accountCOT.toUpperCase() == CRM_AppConstants.PBEP_PRICE_TYPE_RETAIL_COST || accountCOT.toUpperCase() == CRM_AppConstants.PBEP_PRICE_TYPE_MENU)){
          listAccountCOT.add(accountCOT.toUpperCase());
        }else{
            isRetailMenuCOT = true;
        }
        for(String cotVal: listAccountCOT){
            key = strKey + '-' + cotVal;
            //system.debug('@@COTPBEPkey-->'+key);

            if(!setPromoDealerCOT.contains(cotVal) && mapUniqueKeyToValidPBEP.containskey(key)){
                pbep = mapUniqueKeyToValidPBEP.get(key);
            }else if(setPromoDealerCOT.contains(cotVal) && mapUniqueKeyToValidPBEP.containskey(key)){
                if(PBEPListPrice == null){
                    PBEPListPrice = mapUniqueKeyToValidPBEP.get(key).List_Price__c;
                }
                //system.debug('@@PBEPListPrice-->'+PBEPListPrice);
                if(isRetailMenuCOT){
                    pbep = mapUniqueKeyToValidPBEP.get(key);
                    isRetailMenuCOT = false;
                }
            }
            if(pbep != null && pbep.Id != null && PBEPListPrice != null){
                break;
            }
        }
        mapValidCOTPBEP.put('PBEPID',pbep.Id);
        mapValidCOTPBEP.put('PBEPPRICE',String.valueOf(PBEPListPrice));
        //system.debug('@@mapValidCOTPBEP-->'+mapValidCOTPBEP);
        return mapValidCOTPBEP;
    }

    public static Boolean isValidCOTPBEP(Map<String,String> mapValidCOTPBEP){
        Boolean isValid = false;
        if(!mapValidCOTPBEP.isEmpty() && mapValidCOTPBEP.get('PBEPID') != null && mapValidCOTPBEP.get('PBEPID') != '' && 
                mapValidCOTPBEP.get('PBEPPRICE') != null && mapValidCOTPBEP.get('PBEPPRICE') != ''){
            isValid = true;
        }
        return isValid;
    }

    /**
     * @Description - Class for calculatiing Deal Product Target Quantity
     * @name CRMJV_TargetRevenueDetails
     */
    public class CRMJV_TargetRevenueDetail{
        public Target__c targetInstance;
        public String salesOrg;
    }

    /**
     * @Description - Class for Exception Handling
     * @name CRMJV_AutoPhysicalNRDealServiceException
     */
    public class CRMJV_AutoPhysicalNRDealServiceException extends Exception{
        public Id recordId;
        public List<String> lstErrors;
        public CRMJV_AutoPhysicalNRDealServiceException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }    
}