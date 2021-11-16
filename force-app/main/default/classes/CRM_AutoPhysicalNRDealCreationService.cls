/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_AutoPhysicalNRDealCreationService
   @CreateDate 31 Dec 2015
   @Description This batch class is responsible for automatic creation of Deals, and corresponding 
                Deal Products associated to them for Physical NR products created in the system.
                Scenario 1: Create new Deal and Deal Products if no Deal found related to "Sold To" Accounts for each NR Products inserted.
                Scenario 2: Clone Deal Product once Street Date of NR Product is updated or create new deal if not present.
                Scenario 3: Update Deal Product Quantity of NR Product if its related Target's revenue is updated or new Target is created.
   @Version <1.0>
   @reference Requirement no 155
*/
public with sharing class CRM_AutoPhysicalNRDealCreationService {

    /**
     * @Description - Method to process all NR Product records
     * @name processNRProductRecords
     * @param lstSoldToAccounts List of all Sold To Accounts
     * @param lstNRProducts List of all NR Products
     * @param mapProductIdToAccountPlanList - Map of Product Id to corresponding List of Targets
     * @param setProcessedProductIds Set of all the Processed Product Ids
     */
    public static List<CRM_AutoPhysicalNRDealCreationServiceException> processNRProductRecords(
            List<Account> lstSoldToAccounts,
            List<Product2> lstNRProducts,
            //Set<String> setProductAndAccountIdForTargets,
            Map<String, List<Pricebook_Entry_Period__c>> mapIdToPBEPList,
            Set<Id> setProcessedProductIds
    ) {
    System.debug('lstNRProducts::'+lstNRProducts);  
    System.debug('mapIdToPBEPList::'+mapIdToPBEPList);

    List<Opportunity> lstNewDealsToInsert = new List<Opportunity>();
    Map<Id,List<Opportunity>> mapAccountIdToAllDeals = new Map<Id,List<Opportunity>>();
    //List<Opportunity> lstAllDeals = new List<Opportunity>();
    List<OpportunityLineItem> lstDeleteDealProductsToBeCloned = new List<OpportunityLineItem>();
    List<OpportunityLineItemSchedule> lstDealProductSchedulesToBeCloned = new List<OpportunityLineItemSchedule>();
    Set<Account> setSelectedAccounts = new Set<Account>();
    Map<Id, Product2> mapProductIdToInstance = new Map<Id, Product2>();
    Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts = new Map<String, List<OpportunityLineItem>>();
    Set<Id> setPriceBookIds = new Set<Id>();
    Map<String, OpportunityLineItem> mapExistingDealProducts = new Map<String, OpportunityLineItem>();
    Set<Id> setProcessedDealIds = new Set<Id>();
    Map<String, List<String>> mapDealNameToErrorList = new Map<String, List<String>>();
    Map<String, OpportunityLineItem> mapNewDealProductsToUpsert = new Map<String, OpportunityLineItem>();
    Map<String, List<Product2>> mapDealNameToProductInstance = new Map<String, List<Product2>>();
    Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP = new Map<String, Pricebook_Entry_Period__c>();
    Map<Id, Opportunity> mapDealIdToInstance = new Map<Id, Opportunity>();
    Map<String,PricebookEntry> mapPriceBookEntry = new Map<String,PricebookEntry>();
    Map<String, List<OpportunityLineItemSchedule>> mapExistingDealProductsWithSchedules = 
        new Map<String, List<OpportunityLineItemSchedule>>();
    Map<String, List<CRM_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList = new Map<String, List<CRM_TargetRevenueDetail>>();
    List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
    List<CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions =
        new List<CRM_AutoPhysicalNRDealCreationServiceException>();
    Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal = new Map<Id, List<Opportunity>>();
    Map<String, Opportunity> mapDealUniqueStringToInstanceForApprovedOrCommitted = new Map<String, Opportunity>();
    Map<Id, Account> mapIdToAccountInstance = new Map<Id, Account>();
    Set<String> setProcessedDealProductIds = new Set<String>();
    Set<String> setNewlyInsertedUniqueDPKey = new Set<String>();
    Map<Id, PricebookEntry> mapPBEIdToInstance = new Map<Id, PricebookEntry>();
    Set<String> setProductAndAccountIdForTargets = new Set<String>();

    try{
        System.debug('setProductAndAccountIdForTargets::'+setProductAndAccountIdForTargets);
        if (!lstSoldToAccounts.isEmpty()) {
            mapIdToAccountInstance = new Map<Id, Account>(lstSoldToAccounts);
        }
        System.debug('--mapIdToAccountInstance.keySet()->'+mapIdToAccountInstance.keySet());

        //Map of Type with corresponding Set of Accounts
        Map<String,Set<Account>> mapProductTypeWithRelatedAccounts =
            fetchListOfAccountsForType(lstSoldToAccounts, mapDealIdToInstance, mapProductAndAccountIdToTargetDetailList, setProductAndAccountIdForTargets);
        System.debug('mapProductTypeWithRelatedAccounts::'+mapProductTypeWithRelatedAccounts);

        if (mapDealIdToInstance.size() > 0 && !mapDealIdToInstance.values().isEmpty()) {

            //Fetch Existing Deal Product for products
            fetchExistingDealProducts(
                lstNRProducts, mapProductIdToExistingDealProducts, mapExistingDealProducts,
                mapDealIdToInstance, mapDealUniqueStringToInstanceForApprovedOrCommitted
            );
        }

        System.debug('--mapExistingDealProducts-->'+mapExistingDealProducts);
        System.debug('--mapProductIdToExistingDealProducts-->'+mapProductIdToExistingDealProducts);
        for (Product2 productInstance : lstNRProducts) {
            //OpportunityLineItem clonedDealProduct = new OpportunityLineItem();
            System.debug('productInstance::'+productInstance);
            mapProductIdToInstance.put(productInstance.Id, productInstance);
            setSelectedAccounts =
                fetchRelatedAccounts(productInstance,mapProductTypeWithRelatedAccounts);

            for (Account accountInstance : setSelectedAccounts) {
                Boolean bCreateNewDeal = false;

                //JAPAN US 481
                if(
                        accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && 
                        (productInstance.Product_Market__c == null || !CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(productInstance.Product_Market__c))
                ) {
                   setProcessedProductIds.add(productInstance.Id);
                   continue;
                }

                // Boolean Flag to distinguish France Sales Org
                Boolean isTargetBasedSalesOrg =
                    //productInstance.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
                        CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c) ||
                        CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c);

                        //CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c);

                if(!mapAccountIdToAllDeals.containsKey(accountInstance.Id)){
                    if(accountInstance.Opportunities != null && !accountInstance.Opportunities.isEmpty()){
                       mapAccountIdToAllDeals.put(accountInstance.Id,accountInstance.Opportunities);
                       //lstAllDeals.addAll(accountInstance.Opportunities);
                    }
                }

                System.debug('accountInstance::'+accountInstance);
                // Based on Type check proceed further
                if (!mapAccountIdToAllDeals.isEmpty() && mapAccountIdToAllDeals.containsKey(accountInstance.Id)) {
                    bCreateNewDeal =
                        processAllDeals(productInstance,accountInstance,mapAccountIdToAllDeals,setProductAndAccountIdForTargets,lstDeleteDealProductsToBeCloned,
                            mapIdToPBEPList,setProcessedProductIds,mapProductIdToExistingDealProducts,setPriceBookIds,mapExistingDealProducts,
                            setProcessedDealIds,mapNewDealProductsToUpsert,mapDealNameToProductInstance,mapUniqueKeyToValidPBEP,
                            mapExistingDealProductsWithSchedules,mapProductIdAndAssociatedDeal, mapDealUniqueStringToInstanceForApprovedOrCommitted
                        );
                } else {
                    System.debug('--no deals present for the account else -->'+productInstance); 

                    // Create new deal for Scenario 1 and 2 and for Scenario 3 only in case of France
                    /*if (
                            productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                            (isFranceSalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id))
                    ) {*/
                        bCreateNewDeal = true;
                    /*} else {
                        setProcessedProductIds.add(productInstance.Id);
                    }*/
                }

                // Create New Deal RECORDS
                if (bCreateNewDeal) {
                    //Create new deal
                    Opportunity newDeal = createDealWithAccounts(accountInstance,productInstance);
                    System.debug('newDeal::'+newDeal);
                    String strKey = productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode;

                    System.debug('-mapIdToPBEPList.containsKey(strKey)-->'+mapIdToPBEPList.containsKey(strKey));
                    if (mapIdToPBEPList.containsKey(strKey)) {
                        for (Pricebook_Entry_Period__c pbep : mapIdToPBEPList.get(strKey)) {
                            if (isValidPBEP(pbep, newDeal, productInstance)) {
                                mapUniqueKeyToValidPBEP.put(strKey, pbep);
                                break;
                            }
                        }
                    }

                    // Boolean flag to allow deal creation in France only if Account Plan details present in case of Scenario 1, 2 & 3
                    // Boolean flag to allow deal creation in Germany only if Target details present in case of Scenario 1, 2 & 3
                    Boolean isTargetPresent = false;

                    if (CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c)) {
                        // Check for valid target present for Germany
                        if (
                                mapProductAndAccountIdToTargetDetailList.containsKey(productInstance.Id + '-' + accountInstance.Id) &&
                                mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id) != null &&
                                mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id).size() > 0
                        ) {
                            for (CRM_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id)) {
                                if (
                                    productInstance.Street_Date__c != null &&
                                    targetDetailInstance.targetInstance.Calc_Start_Date__c <= productInstance.Street_Date__c &&
                                    targetDetailInstance.targetInstance.Calc_End_Date__c >= productInstance.Street_Date__c
                                ) {
                                    isTargetPresent = true;
                                    break;
                                }
                            }
                        }
                    } else {
                        isTargetPresent = mapProductAndAccountIdToTargetDetailList.containsKey(productInstance.Id + '-' + accountInstance.Id) &&
                            mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id) != null &&
                            mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id).size() > 0;
                    }

                    Boolean isValidNewDealInsertAllowed =
                        mapUniqueKeyToValidPBEP.containsKey(strKey) &&
                        mapUniqueKeyToValidPBEP.get(strKey) != null &&
                        (
                            productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                            mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c ||
                            (isTargetBasedSalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id))
                        );

                    // If no valid PBEP found, don't create new Deal
                    // If no Account Plans found for France, don't create new Deal
                    if (
                        newDeal != null &&
                        isValidNewDealInsertAllowed && 
                        (!isTargetBasedSalesOrg || (isTargetBasedSalesOrg && isTargetPresent))
                    ) {
                        if (processNewDeals(
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
                                setProductAndAccountIdForTargets
                        )) {

                            if (mapAccountIdToAllDeals.containsKey(accountInstance.Id)) {
                                List<Opportunity> lstDeal = mapAccountIdToAllDeals.get(accountInstance.Id);
                                lstDeal.add(newDeal);
                                mapAccountIdToAllDeals.put(accountInstance.Id,lstDeal);
                            } else {
                                mapAccountIdToAllDeals.put(accountInstance.Id,new List<Opportunity>{newDeal});
                            }
                        }
                    } else {
                        OpportunityLineItem validDealProductToCloneInstance;
                        if (productInstance.Street_Date_Has_Changed__c) {
                            validDealProductToCloneInstance =
                                fetchDealProductToClone(accountInstance, productInstance, mapProductIdToExistingDealProducts);
                        }

                        // If no deal created due to no valid PBEP found or no Account Plan present for France, we don't clone the deal product but
                        // we have to delete the deal Product that was supposed to be cloned only if its Deal is in any Stage
                        if (validDealProductToCloneInstance != null) {
                            lstDeleteDealProductsToBeCloned.add(validDealProductToCloneInstance);
                        }
                        setProcessedProductIds.add(productInstance.Id);
                    }
                }
            }
        }

        System.debug('lstNewDealsToInsert:111:'+lstNewDealsToInsert);
        //List<Opportunity> dealToBeInsertedFilteredList = new List<Opportunity>();
        // Inserting new deals
        if (!lstNewDealsToInsert.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.insert(lstNewDealsToInsert, false);
            Opportunity deal;
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                deal = lstNewDealsToInsert[i];
                if (deal != null) {
                    if (saveResultInstance.isSuccess()) {
                        setProcessedDealIds.add(deal.Id);
                        //dealToBeInsertedFilteredList.add(deal);
                        
                        // Process Scenario 2 for only newly inserted deals
                        if (mapDealNameToProductInstance.containsKey(deal.Name + '-' + deal.AccountId)) {
                            // If multiple products of same type changes streetDate to lie in newly created deal for a single account
                            for(Product2 productInstance : mapDealNameToProductInstance.get(deal.Name + '-' + deal.AccountId)){
                                if (productInstance.Street_Date_Has_Changed__c) {
                                    // lstDeleteDealProductsToBeCloned will be returned only if deal product is cloned
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
                                            mapProductIdAndAssociatedDeal
                                        )
                                    );
                                }
                            }
                        }
                    } else {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(
                            String.format(
                                System.Label.CRM_Deal_Not_Processed,
                                new String[] {
                                    deal.Name,
                                    deal.AccountId
                                }
                            )
                        );

                        for (Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }

                        if (mapDealNameToErrorList.containsKey(deal.Name)) {
                            List<String> errorList = mapDealNameToErrorList.get(deal.Name);
                            errorList.addAll(lstErrors);
                            mapDealNameToErrorList.put(deal.Name, errorList);
                        } else {
                            mapDealNameToErrorList.put(deal.Name, lstErrors);
                        }
                    }
                }
            }
        }

        // Change the Stage to Revised so that Deal Products can be updated / inserted / deleted for Approved OR Committed Deals
        if (mapDealUniqueStringToInstanceForApprovedOrCommitted.size() > 0 && !mapDealUniqueStringToInstanceForApprovedOrCommitted.values().isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(mapDealUniqueStringToInstanceForApprovedOrCommitted.values(), false);
            Opportunity deal;
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                deal = mapDealUniqueStringToInstanceForApprovedOrCommitted.values()[i];
                if (deal != null) {
                    if (!saveResultInstance.isSuccess()) {
                        setProcessedDealIds.remove(deal.Id);

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(
                            String.format(
                                System.Label.CRM_Deal_Not_Processed,
                                new String[] {
                                    deal.Name,
                                    deal.AccountId
                                }
                            )
                        );

                        for (Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }

                        if (mapDealNameToErrorList.containsKey(deal.Name)) {
                            List<String> errorList = mapDealNameToErrorList.get(deal.Name);
                            errorList.addAll(lstErrors);
                            mapDealNameToErrorList.put(deal.Name, errorList);
                        } else {
                            mapDealNameToErrorList.put(deal.Name, lstErrors);
                        }
                    }
                }
            }
        }

        System.debug('lstDeleteDealProductsToBeCloned::'+lstDeleteDealProductsToBeCloned);
        //lstAllDeals.addAll(dealToBeInsertedFilteredList);
        //System.debug('dealToBeInsertedFilteredList:222:'+dealToBeInsertedFilteredList);

        mapPBEIdToInstance =
            fetchPriceBookEntryForProduct(setPriceBookIds, mapProductIdToInstance, mapPriceBookEntry);
        //Map<Id, Opportunity> mapIdToDeal = new Map<Id, Opportunity> (lstAllDeals);
        //System.debug('-mapIdToDeal-->'+mapIdToDeal);
        System.debug('mapPriceBookEntry::'+mapPriceBookEntry);
        System.debug('--mapProductIdAndAssociatedDeal-->'+mapProductIdAndAssociatedDeal);

        // Calling method to create Deal Products on Deals
        //createDealProductOnDeal(mapIdToDeal,setProcessedProductIds);
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
        lstExceptions.add(
            new CRM_AutoPhysicalNRDealCreationServiceException(
                null,
                new List<String>{e.getMessage()}
            )
        );
    }
        // Skip the validation rule when invoked through NR Bacth and allow changing deal product rental prices
        CRM_ApplicationUtility.isInvokedByNRBatch = true;

        //Map<Id, OpportunityLineItem> mapIdToInsertedDPInstance = new Map<Id, OpportunityLineItem>();
        if (!mapNewDealProductsToUpsert.values().isEmpty()) {
            Database.UpsertResult[] saveResultList =
                Database.upsert(mapNewDealProductsToUpsert.values(), false);
            OpportunityLineItem dealProduct;
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.UpsertResult saveResultInstance = saveResultList[i];
                 dealProduct = mapNewDealProductsToUpsert.values()[i];
                if (dealProduct != null) {
                    Id productId =
                        dealProduct.Product2Id != null 
                        ? dealProduct.Product2Id 
                        : mapPBEIdToInstance.containsKey(dealProduct.PricebookEntryId) ? mapPBEIdToInstance.get(dealProduct.PricebookEntryId).Product2Id : dealProduct.Product2Id;

                    if (saveResultInstance.isSuccess()) {
                        setProcessedProductIds.add(productId);
                        if (dealProduct.Product2Id != null) {
                            setProcessedDealProductIds.add(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
                        } else {
                            setNewlyInsertedUniqueDPKey.add(dealProduct.NR_Deal_Product_Unique_Key__c);
                        }
                        // mapIdToInsertedDPInstance.put(dealProduct.Id, dealProduct);
                    } else {
                        // Add these errors in Error wrapper Class and prepare a list of same
                        setProcessedProductIds.remove(productId);

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(
                            String.format(
                                System.Label.CRM_Deal_Product_Not_Processed,
                                new String[] {
                                    dealProduct.OpportunityId
                                }
                            )
                        );

                        for (Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealProduct.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(
                            new CRM_AutoPhysicalNRDealCreationServiceException(
                                productId,
                                lstErrors
                            )
                        );
                    }
                }
            }
        }

        System.debug('mapNewDealProductsToUpsert111::'+mapNewDealProductsToUpsert);
        List<OpportunityLineItem> dealProductToBeDeletedFilteredList =
            new List<OpportunityLineItem>();
        for (OpportunityLineItem dealProductToBeDeletedInstance : lstDeleteDealProductsToBeCloned) {
            if (setProcessedProductIds.contains(dealProductToBeDeletedInstance.Product2Id)) {
                dealProductToBeDeletedFilteredList.add(dealProductToBeDeletedInstance);
            }
        }

        System.debug('lstDeleteDealProductsToBeCloned::'+lstDeleteDealProductsToBeCloned);
        if (!dealProductToBeDeletedFilteredList.isEmpty()) {
            Database.DeleteResult[] deleteResultList =
                Database.delete(dealProductToBeDeletedFilteredList, false);
            OpportunityLineItem dealProduct;
            for (Integer i = 0; i < deleteResultList.size(); i++) {
                dealProduct = dealProductToBeDeletedFilteredList[i];
                Database.DeleteResult deleteResultInstance = deleteResultList[i];
                if (dealProduct != null) {
                    Id productId =
                        dealProduct.Product2Id != null 
                        ? dealProduct.Product2Id 
                        : mapPBEIdToInstance.containsKey(dealProduct.PricebookEntryId) ? mapPBEIdToInstance.get(dealProduct.PricebookEntryId).Product2Id : dealProduct.Product2Id;
                    if (deleteResultInstance.isSuccess()) {
                        setProcessedProductIds.add(productId);
                        setProcessedDealProductIds.add(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
                    } else {
                        setProcessedProductIds.remove(productId);
                        setProcessedDealProductIds.remove(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(
                            String.format(
                                System.Label.CRM_Deal_Product_Not_Deleted,
                                new String[] {
                                    dealProduct.Id,
                                    dealProduct.OpportunityId
                                }
                            )
                        );
                        for(Database.Error err : deleteResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealProduct.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(
                            new CRM_AutoPhysicalNRDealCreationServiceException(
                                productId,
                                lstErrors
                            )
                        );
                    }
                }
            }
        }
        System.debug('dealProductToBeDeletedFilteredList::'+dealProductToBeDeletedFilteredList);

        for(String strDealProduct : mapExistingDealProductsWithSchedules.keySet()){
            OpportunityLineItem dealProduct;

            if (mapExistingDealProducts.containsKey(strDealProduct)) {
                dealProduct = mapExistingDealProducts.get(strDealProduct);
            } else if (mapNewDealProductsToUpsert.containsKey(strDealProduct)) {
                dealProduct = mapNewDealProductsToUpsert.get(strDealProduct);
            }

            if (dealProduct != null) {
                for (OpportunityLineItemSchedule dealProductSchedule : mapExistingDealProductsWithSchedules.get(strDealProduct)){
                    if (dealProductSchedule.Id == null) {
                        dealProductSchedule.OpportunityLineItemId = dealProduct.Id;
                    }
                    dealProductSchedule.ScheduleDate =
                        calculateScheduleDateForClonedSchedules(dealProduct, dealProductSchedule);
                    lstDealProductSchedulesToBeCloned.add(dealProductSchedule);
                }
            }
        }

        System.debug('lstDealProductSchedulesToBeCloned::'+lstDealProductSchedulesToBeCloned);
        if (!lstDealProductSchedulesToBeCloned.isEmpty()) {
            Database.UpsertResult[] saveResultList =
                Database.upsert(lstDealProductSchedulesToBeCloned, false);
            OpportunityLineItemSchedule scheduleInstance;
            OpportunityLineItem dealProduct;
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.UpsertResult saveResultInstance = saveResultList[i];
                scheduleInstance = lstDealProductSchedulesToBeCloned[i];
                // dealProduct = mapIdToInsertedDPInstance.get(scheduleInstance.OpportunityLineItemId);

                if (scheduleInstance != null) {
                    if (saveResultInstance.isSuccess()) {
                        setProcessedProductIds.add(scheduleInstance.OpportunityLineItem.Product2Id);
                        setProcessedDealProductIds.add(scheduleInstance.OpportunityLineItem.Product2Id + '-' + scheduleInstance.OpportunityLineItem.Opportunity.AccountId);
                    } else {
                        // Add these errors in Error wrapper Class and prepare a list of same
                        setProcessedProductIds.remove(scheduleInstance.OpportunityLineItem.Product2Id);
                        setProcessedDealProductIds.remove(scheduleInstance.OpportunityLineItem.Product2Id + '-' + scheduleInstance.OpportunityLineItem.Opportunity.AccountId);
                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        if (scheduleInstance.ScheduleDate == null) {
                            lstErrors.add(System.Label.CRM_NR_Batch_Schedule_Date_is_Null + scheduleInstance.OpportunityLineItem.Product2Id);
                        }

                        for (Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = scheduleInstance.OpportunityLineItemId;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(
                            new CRM_AutoPhysicalNRDealCreationServiceException(
                                scheduleInstance.OpportunityLineItem.Product2Id,
                                lstErrors
                            )
                        );
                    }
                }
            }
        }
        System.debug('--mapDealUniqueStringToInstanceForApprovedOrCommitted---before--->'+mapDealUniqueStringToInstanceForApprovedOrCommitted);

        // Change the stage back to Approved OR Committed for deals whose Deal Products have been updated / inserted / deleted
        if (mapDealUniqueStringToInstanceForApprovedOrCommitted.size() > 0 && !mapDealUniqueStringToInstanceForApprovedOrCommitted.values().isEmpty()) {
            //List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest> ();
            for (Opportunity approvedOrCommittedDeal : mapDealUniqueStringToInstanceForApprovedOrCommitted.values()) {
                if (
                        approvedOrCommittedDeal.Id != null && approvedOrCommittedDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED
                ) {
                    if (mapDealUniqueStringToInstanceForApprovedOrCommitted.containsKey(approvedOrCommittedDeal.Id + '-' + CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED)) {
                        mapDealUniqueStringToInstanceForApprovedOrCommitted.get(
                            approvedOrCommittedDeal.Id + '-' + CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED
                        ).StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
                    } else if (mapDealUniqueStringToInstanceForApprovedOrCommitted.containsKey(approvedOrCommittedDeal.Id + '-' + CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)) {
                         mapDealUniqueStringToInstanceForApprovedOrCommitted.get(
                            approvedOrCommittedDeal.Id + '-' + CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                        ).StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;

                        /*mapDealUniqueStringToInstanceForApprovedOrCommitted.remove(
                            approvedOrCommittedDeal.Id + '-' + CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                        );
                        Approval.ProcessSubmitRequest requestInstance = new Approval.ProcessSubmitRequest();
                        requestInstance.setObjectId(approvedOrCommittedDeal.Id);
                        approvalRequestList.add(requestInstance);*/
                    }
                }
            }

            // Submit for Approval only for Deals that were previously in Committed Stage
            /*if (approvalRequestList.size() > 0 && !approvalRequestList.isEmpty()) {
                Approval.ProcessResult[] processResults = Approval.process(approvalRequestList, false);
                for (Approval.ProcessResult resultInstance : processResults) {
                    if (!resultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for (Database.Error err : resultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }

                        System.debug('lstErrors---:'+lstErrors);
                    }
                }
            }*/
            System.debug('--mapDealUniqueStringToInstanceForApprovedOrCommitted---after--->'+mapDealUniqueStringToInstanceForApprovedOrCommitted);

            if (mapDealUniqueStringToInstanceForApprovedOrCommitted.size() > 0 && !mapDealUniqueStringToInstanceForApprovedOrCommitted.values().isEmpty()) {
                Database.SaveResult[] saveResultList =
                    Database.update(mapDealUniqueStringToInstanceForApprovedOrCommitted.values(), false);
                Opportunity deal;
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    deal = mapDealUniqueStringToInstanceForApprovedOrCommitted.values()[i];
                    System.debug('deal:222:'+deal);
                    if (deal != null) {
                        if (!saveResultInstance.isSuccess()) {

                            // Error Handling
                            List<String> lstErrors = new List<String>();
                            lstErrors.add(
                                String.format(
                                    System.Label.CRM_Deal_Not_Processed,
                                    new String[] {
                                        deal.Name,
                                        deal.AccountId
                                    }
                                )
                            );

                            for (Database.Error err : saveResultInstance.getErrors()) {
                                lstErrors.add(err.getMessage());

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }

                            if (mapDealNameToErrorList.containsKey(deal.Name)) {
                                List<String> errorList = mapDealNameToErrorList.get(deal.Name);
                                errorList.addAll(lstErrors);
                                mapDealNameToErrorList.put(deal.Name, errorList);
                            } else {
                                mapDealNameToErrorList.put(deal.Name, lstErrors);
                            }
                        }
                    }
                }
            }
        }

        if (setNewlyInsertedUniqueDPKey.size() > 0) {
            for (OpportunityLineItem dealProduct : [
                SELECT
                    Id, Opportunity.AccountId, Product2Id
                FROM
                    OpportunityLineItem
                WHERE
                    Product2Id IN: setProcessedProductIds
                    AND NR_Deal_Product_Unique_Key__c IN: setNewlyInsertedUniqueDPKey
            ]) {
                setProcessedDealProductIds.add(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId);
            }
        }

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
     * @Description - Method to process Target flags to reset the values for successfully processed deal products
     * @name processTargetFlags
     */
    private static void processTargetFlags(
            List<Product2> lstNRProducts, List<Account> lstSoldToAccounts, Set<String> setProcessedDealProductIds, Set<Id> setProcessedProductIds,
            Set<String> setProductAndAccountIdForTargets, Map<String, List<CRM_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
            List<CRM_ErrorLogger.ErrorLog> listErrorLog, List<CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions
    ) {
        Map<Id, Decimal> mapAccountPlanIdToUpdatedNRVersion = new Map<Id, Decimal>();
        for (Account_Plan__c accountPlanInstance : [
            SELECT
                Id, NR_Version__c,
                Target_Revenue_Has_Changed__c,
                Country_Plan__r.NR_Product__c,
                Customer__c
            FROM
                Account_Plan__c
            WHERE
                Target_Revenue_Has_Changed__c = true
                AND Country_Plan__c != null
                AND Country_Plan__r.NR_Product__c IN: lstNRProducts
                AND Customer__c != null
                AND Customer__r.Planning_Customer__c = true
                AND (
                        (
                            Customer__r.Sales_Organization__c NOT IN: CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO AND
                            Customer__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                        ) OR
                        (
                            Customer__r.Sales_Organization__c IN: CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO AND
                            (
                                Customer__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO OR
                                Customer__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO
                            )
                        )
                    )
                AND 
                (
                    Customer__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_ACTIVE
                    OR Customer__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_BLOCKED
                )
                AND 
                (
                    Customer__r.Games_Physical__c = true
                    OR Customer__r.Video_Physical__c = true
                    OR (Customer__r.Music_Physical__c = true AND Customer__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_JAPAN_CODE)
                )
                AND Customer__r.Sales_Organization__c NOT IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS
                AND Customer__r.Games_Digital__c = false
                AND Customer__r.Video_Digital__c = false
                AND Customer__r.Music_Digital__c = false
                AND Customer__r.Price_Book__c != null
                AND Customer__c IN: lstSoldToAccounts
        ]) {
            mapAccountPlanIdToUpdatedNRVersion.put(accountPlanInstance.Id, accountPlanInstance.NR_Version__c);
        }

        //Commented Germany Code Changes
        for (Target__c targetInstance : [
            SELECT
                Id, NR_Version__c,
                Target_Revenue_Has_Changed__c,
                Product__c
            FROM
                Target__c
            WHERE
                Target_Revenue_Has_Changed__c = true
                AND Account__r.Sales_Organization__c IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS
                AND Product__c != null
                AND Product__c IN: lstNRProducts
                AND Account__c != null
                AND Account__r.Planning_Customer__c = true
                AND (
                        (
                            Account__r.Sales_Organization__c NOT IN: CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO AND
                            Account__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                        ) OR
                        (
                            Account__r.Sales_Organization__c IN: CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO AND
                            (
                                Account__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO OR
                                Account__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO
                            )
                        )
                    )
                AND
                (
                    Account__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_ACTIVE
                    OR Account__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_BLOCKED
                )
                AND
                (
                    Account__r.Games_Physical__c = true
                    OR Account__r.Video_Physical__c = true
                )
                AND Account__r.Games_Digital__c = false
                AND Account__r.Video_Digital__c = false
                AND Account__r.Price_Book__c != null
                AND Account__c IN: lstSoldToAccounts
        ]) {
            mapAccountPlanIdToUpdatedNRVersion.put(targetInstance.Id, targetInstance.NR_Version__c);
        }

        List<Target__c> updateProcessedTargetList = new List<Target__c>();
        List<Account_Plan__c> updateProcessedAccountPlanList = new List<Account_Plan__c>();
        for (String uniqueKey : setProductAndAccountIdForTargets) {
            List<String> uniqueIds = uniqueKey.split('-');
            if (
                    mapProductAndAccountIdToTargetDetailList.containsKey(uniqueKey) &&
                    mapProductAndAccountIdToTargetDetailList.get(uniqueKey) != null &&
                    mapProductAndAccountIdToTargetDetailList.get(uniqueKey).size() > 0 &&
                    (setProcessedDealProductIds.contains(uniqueKey) || setProcessedProductIds.contains(uniqueIds[0]))
            ) {
                for (
                        CRM_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(uniqueKey)
                ) {
                    if (targetDetailInstance.accountPlanInstance != null) {
                        if (
                                targetDetailInstance.accountPlanInstance.Target_Revenue_Has_Changed__c == true &&
                                mapAccountPlanIdToUpdatedNRVersion.containsKey(targetDetailInstance.accountPlanInstance.Id) &&
                                mapAccountPlanIdToUpdatedNRVersion.get(targetDetailInstance.accountPlanInstance.Id) == targetDetailInstance.accountPlanInstance.NR_Version__c
                        ) {
                            targetDetailInstance.accountPlanInstance.Target_Revenue_Has_Changed__c = false;
                            targetDetailInstance.accountPlanInstance.NR_Version__c = 0;
                            updateProcessedAccountPlanList.add(targetDetailInstance.accountPlanInstance);
                        }
                        
                    } else {
                        if (
                                targetDetailInstance.targetInstance.Target_Revenue_Has_Changed__c == true &&
                                mapAccountPlanIdToUpdatedNRVersion.containsKey(targetDetailInstance.targetInstance.Id) &&
                                mapAccountPlanIdToUpdatedNRVersion.get(targetDetailInstance.targetInstance.Id) == targetDetailInstance.targetInstance.NR_Version__c
                        ) {
                            targetDetailInstance.targetInstance.Target_Revenue_Has_Changed__c = false;
                            targetDetailInstance.targetInstance.NR_Version__c = 0;
                            updateProcessedTargetList.add(targetDetailInstance.targetInstance);
                        }
                    }
                }
            }
        }
        
        if (!updateProcessedAccountPlanList.isEmpty()) {
            listErrorLog.addAll(resetProcessedAccountPlanFlags(updateProcessedAccountPlanList, lstExceptions));
        }

        if (!updateProcessedTargetList.isEmpty()) {
            listErrorLog.addAll(resetProcessedTargetFlags(updateProcessedTargetList, lstExceptions));
        }
    }

    /**
     * @Description - Method to reset the Target_Revenue_Has_Changed__c flag as the NR Product is processed properly for that Target
     * @name resetProcessedTargetFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    public static List<CRM_ErrorLogger.ErrorLog> resetProcessedAccountPlanFlags(
            List<Account_Plan__c> updateProcessedAccountPlanList,
            List<CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions
    ) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedAccountPlanList.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedAccountPlanList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Account_Plan__c accountPlanInstance = updateProcessedAccountPlanList[i];
                if (!saveResultInstance.isSuccess()) {
                    //setProcessedProductIds.remove(accountPlanInstance.Country_Plan__r.NR_Product__c);

                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    //lstErrors.add('Account Plan Record with Id "'+ accountPlanInstance.Id+'" not processed properly due to below reasons');
                    lstErrors.add(
                        String.format(
                            System.Label.CRM_Account_Plan_Not_Processed,
                            new String[] {
                                accountPlanInstance.Id
                            }
                        )
                    );
                    for (Database.Error err : saveResultInstance.getErrors()) {
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = accountPlanInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationServiceException(
                            accountPlanInstance.Country_Plan__r.NR_Product__c,
                            lstErrors
                        )
                    );
                }
            }
        }
        return listErrorLog;
    }

    /**
     * @Description - Method to reset the Target_Revenue_Has_Changed__c flag as the NR Product is processed properly for that Target
     * @name resetProcessedTargetFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    public static List<CRM_ErrorLogger.ErrorLog> resetProcessedTargetFlags(
            List<Target__c> updateProcessedTargetList,
            List<CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions
    ) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedTargetList.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedTargetList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Target__c targetInstance = updateProcessedTargetList[i];
                if (!saveResultInstance.isSuccess()) {
                    //setProcessedProductIds.remove(targetInstance.Product__c);

                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    lstErrors.add(
                        String.format(
                            System.Label.CRM_Target_Not_Processed,
                            new String[] {
                                targetInstance.Id
                            }
                        )
                    );
                    for (Database.Error err : saveResultInstance.getErrors()) {
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = targetInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationServiceException(
                            targetInstance.Product__c,
                            lstErrors
                        )
                    );
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
    private static Date calculateScheduleDateForClonedSchedules(OpportunityLineItem dealProduct, OpportunityLineItemSchedule scheduleRecord) {
        Date newScheduleDate = null;
        Date oldScheduleDate = scheduleRecord.ScheduleDate;
        if (dealProduct.Product2.Previous_Street_Date__c != null && dealProduct.Product2.Street_Date__c != null && oldScheduleDate != null) {
            Date oldStreetDate = dealProduct.Product2.Previous_Street_Date__c;
            Integer numberDaysDifference = oldStreetDate.daysBetween(oldScheduleDate);

            Date nweStreetDate = dealProduct.Product2.Street_Date__c;
            if (
                    // dealProduct.Opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_UK_CODE &&
                    dealProduct.NR_Revenue_Recognition_Date__c != null &&
                    dealProduct.NR_Revenue_Recognition_Date__c != nweStreetDate &&
                    scheduleRecord.Description == CRM_AppConstants.SCHEDULE_INITIAL
                    // && scheduleRecord.Revenue != 0 && scheduleRecord.Quantity == 0
            ) {
                Integer checkValidDifference = dealProduct.NR_Revenue_Recognition_Date__c.daysBetween(nweStreetDate);
                if (numberDaysDifference < 0) {
                    if (checkValidDifference > 0) {
                        checkValidDifference =  checkValidDifference * (-1);
                    }

                    if (checkValidDifference < numberDaysDifference) {
                        numberDaysDifference = checkValidDifference;
                    }
                } else {
                    if ((checkValidDifference > 0 && checkValidDifference > numberDaysDifference)) {
                        numberDaysDifference = checkValidDifference * (-1);
                    } else if (checkValidDifference < 0) {
                        numberDaysDifference = checkValidDifference;
                    }
                }
            }
            newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        }
        return newScheduleDate;
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
            Set<String> setProductAndAccountIdForTargets
    ) {
        String strKey = productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode;
        Boolean newDealInserted = false;
        Boolean isNewPBEPInsert =
            mapUniqueKeyToValidPBEP.containsKey(strKey) &&
            mapUniqueKeyToValidPBEP.get(strKey) != null &&
            mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c;
        Boolean isNewDealInsertAllowed =
            //productInstance.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
            (
                (
                    (
                        CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c) || 
                        CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c)
                    ) &&
                    productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                )||
                (
                    (
                        CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c) || 
                        CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c)
                    ) &&
                    productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                )
            ) &&
            setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id);

        if (productInstance.NR_Product_Created__c) {
            processScenarioOne(productInstance, newDeal, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
            lstNewDealsToInsert.add(newDeal);
            newDealInserted = true;
        } else  if (productInstance.Street_Date_Has_Changed__c) {

                // Add to mapDealNameToProductInstance if Street Date of Product is changed and new deal is created through Batch
                if (mapDealNameToProductInstance.containsKey(newDeal.Name + '-' + newDeal.AccountId)) {
                    mapDealNameToProductInstance.get(newDeal.Name + '-' + newDeal.AccountId).add(productInstance);
                } else {
                    mapDealNameToProductInstance.put(newDeal.Name + '-' + newDeal.AccountId, new List<Product2> {productInstance});
                }
                lstNewDealsToInsert.add(newDeal);
                newDealInserted = true;
        } else if (isNewDealInsertAllowed || isNewPBEPInsert) {
            processScenarioOne(productInstance, newDeal, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
            lstNewDealsToInsert.add(newDeal);
            newDealInserted = true;
        }
        return newDealInserted;
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
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal, Map<String, Opportunity> mapDealUniqueStringToInstanceForApprovedOrCommitted
    ) {
        Boolean bCreateNewDeal = false;
        Opportunity validDealInstance ;
        for (Opportunity dealInstance : mapAccountIdToAllDeals.get(accountInstance.Id)) {
             if(isValidDeal(accountInstance, dealInstance, productInstance)){
                validDealInstance = dealInstance;
                System.debug('validDealInstance::'+validDealInstance);
                break;
             }
        }
        // Check the product streetDate lie inside deal start date and End date &&
        // Check the deal stage = NR Default OR Planned
        if(validDealInstance != null) {
            Boolean updateCommittedDealAllowed = false;
            String strKey = productInstance.Id + '-' + validDealInstance.Pricebook2Id + '-' + validDealInstance.CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey) && !mapUniqueKeyToValidPBEP.containsKey(strKey)) {
                for (Pricebook_Entry_Period__c pbep : mapIdToPBEPList.get(strKey)) {
                    if (isValidPBEP(pbep, validDealInstance, productInstance)) {
                        mapUniqueKeyToValidPBEP.put(strKey, pbep);
                        break;
                    }
                }
            }

            // If valid Deal Stage is NR Default then only proceed with all Scenario execution
            if (
                    productInstance.NR_Product_Created__c &&
                    mapUniqueKeyToValidPBEP.containsKey(strKey) &&
                    mapUniqueKeyToValidPBEP.get(strKey) != null
            ) {
                // Process for S1
                processScenarioOne(productInstance, validDealInstance,setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
                updateCommittedDealAllowed = true;
            } else if (
                    productInstance.Street_Date_Has_Changed__c
            ) {
                if (validDealInstance.Id != null) {
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
                            mapProductIdAndAssociatedDeal
                        )
                    );
                    updateCommittedDealAllowed = true;
                } else if (
                        mapUniqueKeyToValidPBEP.containsKey(strKey) &&
                        mapUniqueKeyToValidPBEP.get(strKey) != null
                ) {

                    // Add to mapDealNameToProductInstance if Street Date of Product is changed and valid deal is newly created through Batch
                    // P1 (NR) -> D1 newly created (Id = null)
                    // P2 (SD) -> D1 not inserted (Id = null)
                    if (mapDealNameToProductInstance.containsKey(validDealInstance.Name + '-' + validDealInstance.AccountId)) {
                        mapDealNameToProductInstance.get(validDealInstance.Name + '-' + validDealInstance.AccountId).add(productInstance);
                    } else {
                        mapDealNameToProductInstance.put(validDealInstance.Name + '-' + validDealInstance.AccountId, new List<Product2> {productInstance});
                    }
                } else {
                    setProcessedProductIds.add(productInstance.Id);
                }
            } else if(
                    setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + validDealInstance.AccountId) &&
                    mapUniqueKeyToValidPBEP.containsKey(strKey) &&
                    mapUniqueKeyToValidPBEP.get(strKey) != null
            ) {

                // Process for S3
                processScenarioThree(
                    productInstance,
                    validDealInstance,
                    setProcessedProductIds,
                    setPriceBookIds,
                    mapUniqueKeyToValidPBEP,
                    mapProductIdAndAssociatedDeal
                );
                updateCommittedDealAllowed = true;
            } else if (
                    mapUniqueKeyToValidPBEP.containsKey(strKey) &&
                    mapUniqueKeyToValidPBEP.get(strKey) != null &&
                    mapUniqueKeyToValidPBEP.get(strKey).Process_NR_Batch__c
            ) {
                processScenarioOne(productInstance, validDealInstance,setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
                updateCommittedDealAllowed = true;
            } else {
                setProcessedProductIds.add(productInstance.Id);
            }

            bCreateNewDeal = false;
            if (validDealInstance.Id != null && updateCommittedDealAllowed) {
                String uniqueKey = validDealInstance.Id + '-' + validDealInstance.StageName;
                if (
                        uniqueKey != null && !mapDealUniqueStringToInstanceForApprovedOrCommitted.containsKey(uniqueKey) &&
                        mapUniqueKeyToValidPBEP.containsKey(strKey) && mapUniqueKeyToValidPBEP.get(strKey) != null &&
                        (
                            validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                            validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                        )
                ) {
                    
                    validDealInstance.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                    mapDealUniqueStringToInstanceForApprovedOrCommitted.put(uniqueKey, validDealInstance);
                }
                setProcessedDealIds.add(validDealInstance.Id);
            }
            //break;
        } else {
            System.debug('--no valid deal else -->');

            /*// Boolean Flag to distinguish France Sales Org
            Boolean isFranceSalesOrg =
                //productInstance.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
                CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c) ||
                CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c);

            // Create new deal only in case of S1 & S2 and S3 only if France
            if (
                    productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                    (isFranceSalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id))
            ) {
                // Create new Deals (For Scenario 1 always and For Scenario 2 when
                // previous linked deal producct's deal is in any Stage)
                bCreateNewDeal = true;
            } else {
                setProcessedProductIds.add(productInstance.Id);
            }*/
            bCreateNewDeal = true;
        }
        return bCreateNewDeal;
    }

    private static Boolean isValidPBEP(
            Pricebook_Entry_Period__c pbepInstance,
            Opportunity dealInstance,
            Product2 productInstance
    ) {
        if (pbepInstance.Start_Date__c <= dealInstance.CloseDate && pbepInstance.End_Date__c >= dealInstance.Start_Date__c && productInstance.Id == pbepInstance.Product__c) {
            System.debug('--true-->');
            return true;
        } else {
            System.debug('--false-->');
            return false;
        }
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
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal
    ) {
        System.debug('-S1--->');
        String strKey = productInstance.Id + '-' + dealInstance.Pricebook2Id + '-' + dealInstance.CurrencyIsoCode;

        if (
            mapUniqueKeyToValidPBEP.containsKey(strKey) &&
            mapUniqueKeyToValidPBEP.get(strKey) != null
        ) {
            // Found existing deal for product
            if (mapProductIdAndAssociatedDeal.containsKey(productInstance.Id)) {
                mapProductIdAndAssociatedDeal.get(productInstance.Id).add(dealInstance);
            } else {
                mapProductIdAndAssociatedDeal.put(productInstance.Id, new List<Opportunity> {dealInstance});
            }
            setPriceBookIds.add(dealInstance.PriceBook2Id);
        } else {
            setProcessedProductIds.add(productInstance.Id);
        }
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
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal
    ) {
        List<OpportunityLineItem> lstDeleteDealProductsToBeCloned =
            new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> lstClonedSchedule =
            new List<OpportunityLineItemSchedule>();
        Boolean dealProductForValidDealPresent = false;
        OpportunityLineItem validDealProductToCloneInstance;
        if (mapProductIdToExistingDealProducts.containsKey(dealInstance.AccountId +'-'+ productInstance.Id)) {
            System.debug('-S2---->');
            for (
                    OpportunityLineItem dealProduct :
                        mapProductIdToExistingDealProducts.get(
                            dealInstance.AccountId +'-'+ productInstance.Id
                        )
            ) {
                System.debug('In for!!!');
                if (dealProduct.OpportunityId != dealInstance.Id) {
                    validDealProductToCloneInstance = dealProduct;
                    break;
                } else {
                    dealProductForValidDealPresent = true;

                    // Get the scedules so that its Date can be recalculated if the deal Product present in valid deal as only the month changes but Quarter is same
                    if (!dealProduct.Manually_Schedule__c){
                        for(OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules){
                            lstClonedSchedule.add(schedule);
                            System.debug('existing own deal product schedule::'+schedule);
                        }
                    }

                    System.debug('existing own deal product schedule lstClonedSchedule::' + lstClonedSchedule);
                    if (lstClonedSchedule != null && !lstClonedSchedule.isEmpty()){
                        mapExistingDealProductsWithSchedules.put(
                            dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,
                            lstClonedSchedule
                        );
                    }
                    break;
                }
            }
        } 
        System.debug('-----validDealProductToCloneInstance-->'+validDealProductToCloneInstance);
        System.debug('-----dealProductForValidDealPresent-->'+dealProductForValidDealPresent);
            if (validDealProductToCloneInstance != null) {
                // Clone deal Product present in any deal Stage
                //if (validDealProductToCloneInstance.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT) {

                    String strKey = productInstance.Id + '-' + dealInstance.Pricebook2Id + '-' + dealInstance.CurrencyIsoCode;
                    System.debug('-strKey 22--->'+strKey);

                    // Before cloning check the deal product having uniqueKey is not present for the valid deal
                    // D1 -> DP1 to be cloned for P1
                    // D2 valid Deal -> already contains DP2 for P1
                    // Do not clone DP1 as DP2 with uniqueKey already presnt
                    if (!mapExistingDealProducts.containsKey(dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode)) {

                        // Only the product which has been cloned should be deleted
                        lstDeleteDealProductsToBeCloned.add(validDealProductToCloneInstance);

                        if (
                            mapUniqueKeyToValidPBEP.containsKey(strKey) &&
                            mapUniqueKeyToValidPBEP.get(strKey) != null
                        ) {
                            OpportunityLineItem clonedDealProduct = validDealProductToCloneInstance.clone();
                            clonedDealProduct.OpportunityId = dealInstance.Id;
                            System.debug('--dealProduct-S2->'+validDealProductToCloneInstance);
                            System.debug('--clonedDealProduct-S2->'+clonedDealProduct);
                            mapNewDealProductsToUpsert.put(
                                dealInstance.Id + '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,
                                clonedDealProduct
                            );

                            // Add the cloned product in the map of Existing batch generated deal products so that it can be used
                            // further for scenario 3 in this method (createDealProductRecord)
                            /*mapExistingDealProducts.put(
                                dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,
                                clonedDealProduct
                            );*/
                            System.debug('clonedDealProduct.OpportunityLineItemSchedules::'+clonedDealProduct.OpportunityLineItemSchedules);
                            if (clonedDealProduct.Manually_Schedule__c){
                                for(OpportunityLineItemSchedule schedule : validDealProductToCloneInstance.OpportunityLineItemSchedules){
                                    OpportunityLineItemSchedule clonedSchedule = schedule.clone();
                                    lstClonedSchedule.add(clonedSchedule);
                                    System.debug('clonedSchedule::'+clonedSchedule);
                                }
                            }
                            System.debug('lstClonedSchedule::'+lstClonedSchedule);
                            if(lstClonedSchedule != null && !lstClonedSchedule.isEmpty()){
                                mapExistingDealProductsWithSchedules.put(
                                    dealInstance.Id+ '-' + productInstance.Id + '-' + dealInstance.CurrencyISOCode,
                                    lstClonedSchedule
                                );
                            }

                            // Process for S3
                            processScenarioThree(
                                productInstance,
                                dealInstance,
                                setProcessedProductIds,
                                setPriceBookIds,
                                mapUniqueKeyToValidPBEP,
                                mapProductIdAndAssociatedDeal
                            );
                        } else {
                            setProcessedProductIds.add(productInstance.Id);
                        }
                    } else {
                        setProcessedProductIds.add(productInstance.Id);
                    }
                /*} else {
                    setProcessedProductIds.add(productInstance.Id);
                }*/
            } else  {
                System.debug('-----IN ELSE-->');
                if (!dealProductForValidDealPresent) {
                    System.debug('-S2--S1--->');
                    processScenarioOne(productInstance, dealInstance, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP,mapProductIdAndAssociatedDeal);
                } else {
                    if (setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + dealInstance.AccountId)) {
                        // Process for S3
                        processScenarioThree(
                            productInstance,
                            dealInstance,
                            setProcessedProductIds,
                            setPriceBookIds,
                            mapUniqueKeyToValidPBEP,
                            mapProductIdAndAssociatedDeal
                        );
                    } else {
                        setProcessedProductIds.add(productInstance.Id);
                    }
                }
        }
        return lstDeleteDealProductsToBeCloned;
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
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal
    ) {
        System.debug('--S3--->');
        processScenarioOne(productInstance, dealInstance, setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
    }

    /**
     * @Description - Method to create Deal on an Account
     * @name createDealWithAccounts 
     * @param accountInstance - Instance of Account for which deal needs to be created
     * @param product - Instance of the Product for which deal needs to be created
     * @return Opportunity - Newly created Deal
     */
    private static Opportunity createDealWithAccounts(Account accountInstance, Product2 product) {
        List<Opportunity> lstNewDeals = new List<Opportunity>();
        Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();
        String dealName = '';
        String dealPeriod = '';
        String strdealProductType = '';
        Id ownerId = accountInstance.OwnerId;
        
        if (product.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
            strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
        } else {
            strdealProductType = product.Type__c;
        }
        
        if (accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE || accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE) {
            mapStartAndCloseDateForDeal = calculateDatesForDeal(product.Street_Date__c, CRM_AppConstants.NR_Deal_For_Quarter);
            Integer currentQtr =
                Decimal.valueOf(
                    product.Street_Date__c.toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr;
            dealName = CRM_AppConstants.NR_Deal_Naming_Convention + strdealProductType + ' ' + CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr + ' ';
        } else {
            //JAPAN US 481
            if (
                accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                product.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(product.Product_Market__c)
            ) {
                mapStartAndCloseDateForDeal = calculateDatesForJapanDeal(product.Street_Date__c);
                String productType;
                String marketType;
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');

                    if (strdealProductType == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_GAMES_PHYSICAL;
                    } else if (strdealProductType == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_PHYSICAL;
                    } 
                    // US JAPAN : 561
                    else if (strdealProductType == CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE) {
                        // DEF#4275
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_PHYSICAL;
                        strdealProductType = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
                    }

                    if (product.Product_Market__c == CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE) {
                        marketType = CRM_AppConstants.NR_Deal_Japan_Market_Type_RENTAL;
                    } else {
                        marketType = CRM_AppConstants.NR_Deal_Japan_Market_Type_SELL_THROUGH;
                    }

                    if (productType != null && marketType != null) {
                        // For eg:  NR Rental Video Physical 2016年10月16日   to 2016年11月15日   NBC ユニバーサル・エンターテイメントジャパン合同会社
                        dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + marketType + productType + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day;
                    }
                    dealPeriod = startMonth + '-' + endMonth;
                }
            } else {
                mapStartAndCloseDateForDeal = calculateDatesForDeal(product.Street_Date__c, CRM_AppConstants.NR_Deal_For_Month);
                Datetime sDate =
                    datetime.newInstance(
                        product.Street_Date__c.year(),
                        product.Street_Date__c.month(),
                        product.Street_Date__c.day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
                dealName = CRM_AppConstants.NR_Deal_Naming_Convention + strdealProductType + ' ' + dealPeriod + ' ';
            }
        }

        //if(accountInstance.Games_Digital__c || accountInstance.Games_Physical__c){
        // DEF#4233
        
        // added code as a part of DE#4754 CODE START
        
        if (strdealProductType == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE) {
            if(accountInstance.Owner_Games__c != null && accountInstance.Owner_Games__r.IsActive){
                ownerId = accountInstance.Owner_Games__c;
            }
        }

        // added code as a part of DE#4754 CODE END
        
        Opportunity deal =
            new Opportunity(
                StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT,
                CloseDate = mapStartAndCloseDateForDeal.get('End Date'),
                Promo_End_Date__c = mapStartAndCloseDateForDeal.get('End Date'),
                AccountId = accountInstance.Id,
                Pricebook2Id = accountInstance.Price_Book__c,
                CurrencyIsoCode = accountInstance.CurrencyIsoCode,
                Start_Date__c = mapStartAndCloseDateForDeal.get('Start Date'),
                Promo_Start_Date__c = mapStartAndCloseDateForDeal.get('Start Date'),
                Type = System.Label.CRM_New_Business_Value,
                Product_Type__c = strdealProductType,
                NR_Deal_Unique_Key__c = accountInstance.Id + '-' + dealPeriod + '-' + fetchProductTypeShortName(product.Type__c),
                OwnerId = ownerId
            );

        if (CRM_RecordTypeUtil.RT_DEAL_DIGITAL != null && CRM_RecordTypeUtil.RT_DEAL_PHYSICAL != null) {
            if(deal.Product_Type__c!= null){
                if(
                        deal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE ||
                        deal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE 
                        //|| deal.Product_Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE // US JAPAN : 561
                ) {
                    deal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    deal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }

        //JAPAN US 481
        if(
                accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                deal.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL &&
                CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(product.Product_Market__c)
        ) {
            deal.Market_Type__c = product.Product_Market__c;
            deal.Name = dealName + ' ' + accountInstance.Name;
        } else {
            deal.Name = dealName + product.Street_Date__c.year() + ' ' + accountInstance.Name;
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
        if (productType != null && productType.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)){
            productTypeShortName = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE_SHORT_NAME;
        } else if(productType == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
            productTypeShortName =CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE_SHORT_NAME;
        } else if(productType == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE){
            productTypeShortName =CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE_SHORT_NAME;
        } else if(productType == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE){
            productTypeShortName =CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE_SHORT_NAME;
        }
        // US JAPAN : 561
        else if(productType == CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE){
            // DEF#4275
            productTypeShortName =CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE_SHORT_NAME;
        } else if(productType == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE){
            // DEF#4275
            productTypeShortName =CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE_SHORT_NAME;
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
    public static Map<String, Date> calculateDatesForDeal(Date streetDate, String timeFrame) {
        Date startDate;
        Date endDate;
        Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();
        Integer currentQtr =
            Decimal.valueOf(streetDate.month()).divide(3.0, 0, System.RoundingMode.UP).intValue();

        if (timeFrame == CRM_AppConstants.NR_Deal_For_Quarter) {
              startDate = date.newInstance(streetDate.year(), ((currentQtr - 1) * 3 + 1), 1);
              endDate = startDate.addMonths(3) - 1;
        } else if(timeFrame == CRM_AppConstants.NR_Deal_For_Month) {
            startDate = streetDate.toStartOfMonth();
            endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        }

        mapStartAndCloseDateForDeal.put('Start Date', startDate);
        mapStartAndCloseDateForDeal.put('End Date', endDate);
        return mapStartAndCloseDateForDeal;
    }

    /**
     * @Description - Method to calculate start and end date on Japan Deal
     * @name calculateDatesForJapanDeal 
     * @param streetDate - Street Date of Physical Product / Start Date of PBEP for Digital Product
     * @return Map<String, Date> - Map of start and end date on Deal
     */
    public static Map<String, Date> calculateDatesForJapanDeal(Date streetDate) {
        Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();

        Date startDate;
        Date endDate;

        if (streetDate != null) {
            if (streetDate.day() > 15) {
                startDate = (streetDate.toStartOfMonth()).addDays(15);
                endDate = (streetDate.toStartOfMonth().addMonths(1)).addDays(14);
            } else {
                startDate = (streetDate.toStartOfMonth().addMonths(-1)).addDays(15);
                endDate = (streetDate.toStartOfMonth()).addDays(14);
            }
        }

        mapStartAndCloseDateForDeal.put('Start Date', startDate);
        mapStartAndCloseDateForDeal.put('End Date', endDate);
        return mapStartAndCloseDateForDeal;
    }

    /**
     * @Description - Method to fetch PricebookEntry details for particular Products and PriceBooks
     *                used in deals used for deal product creation
     * @name fetchPriceBookEntryForProduct
     */
    public static Map<Id,PricebookEntry> fetchPriceBookEntryForProduct(
            Set<Id> setPriceBookIds,
            Map<Id, Product2> mapProductIdToInstance,
            Map<String,PricebookEntry> mapPriceBookEntry
    ) {
        Map<Id, PricebookEntry> mapPBEIdToInstance = new Map<Id, PricebookEntry>([
                SELECT
                    Product2Id,
                    Pricebook2Id,
                    UnitPrice,
                    CurrencyIsoCode,
                    IsActive
                FROM
                    PriceBookEntry
                WHERE
                    Product2Id IN: mapProductIdToInstance.keySet()
                    AND Pricebook2Id IN: setPriceBookIds
                    AND IsActive = true
        ]);
        for (PricebookEntry pricBkEntry : mapPBEIdToInstance.values()) {
             mapPriceBookEntry.put(
                pricBkEntry.Pricebook2Id + '-' + pricBkEntry.Product2Id + '-' + pricBkEntry.CurrencyIsoCode,
                pricBkEntry
            );
        }
        System.debug('mapPriceBookEntry::' + mapPriceBookEntry);
        return mapPBEIdToInstance;
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
            List<CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions
    ) { 
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers =
            new CRM_ProductPricingHandler.DealWrapper[]{};
        for (Opportunity deal : lstDeals) {
            if (setProcessedDealIds.contains(deal.Id)) {
                CRM_ProductPricingHandler.DealWrapper currentDealWrapper =
                    new CRM_ProductPricingHandler.DealWrapper();

                currentDealWrapper.dealId = deal.Id;
                currentDealWrapper.accountId = deal.AccountID;
                currentDealWrapper.dealCurrency = deal.CurrencyIsoCode;
                currentDealWrapper.productId = productId;
                currentDealWrapper.pricebookId = deal.Pricebook2ID;
                currentDealWrapper.dealStartDate = deal.Start_Date__c;
                currentDealWrapper.dealEndDate = deal.CloseDate;

                System.debug('currentDealWrapper::'+currentDealWrapper);
                setProcessedProductIds.add(productId);
                listDealWrappers.add(currentDealWrapper);
            } else {
                setProcessedProductIds.remove(productId);
                if (mapDealNameToErrorList.containsKey(deal.Name) && deal.Id == null) {
                    lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationServiceException(
                            productId,
                            mapDealNameToErrorList.get(deal.Name)
                        )
                    );
                }
            }
        }
        return listDealWrappers;
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
            Map<String, List<CRM_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
            List<CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal,
            Set<String> setProductAndAccountIdForTargets,
            Map<Id, Account> mapIdToAccountInstance
     ) {
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers =
            new CRM_ProductPricingHandler.DealWrapper[]{};
        System.debug('--mapProductIdAndAssociatedDeal-->'+mapProductIdAndAssociatedDeal);

        for (Id productId : mapProductIdAndAssociatedDeal.keySet()) {
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
        CRM_ProductPricingHandler pricingHandler = processPricingDetails(listDealWrappers, mapProductIdToInstance);
        System.debug('---pricingHandler--'+pricingHandler); 
        System.debug('---mapUniqueKeyToValidPBEP.keySet()-->'+mapUniqueKeyToValidPBEP.keySet());

        for (CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers) {
            System.debug('dw::'+dw);
            String strKey = dw.productId + '-' + dw.pricebookId + '-' + dw.dealCurrency;
            System.debug('strKey::'+strKey);
            // Not initialized so that it is null when no Target details found
            CRM_TargetRevenueDetail validTargetDetailInstance;
            if (pricingHandler != null && mapUniqueKeyToValidPBEP.containsKey(strKey) && mapProductIdToInstance.containsKey(dw.productId)) {
                System.debug('--Key222-->'+dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency);
                Boolean bCreateDealProductForInvalidTarget = false;
                if (
                        dw.AccountID != null && dw.productId != null &&
                        mapProductAndAccountIdToTargetDetailList.containsKey(dw.productId + '-' + dw.AccountID) &&
                        mapProductAndAccountIdToTargetDetailList.get(dw.productId + '-' + dw.AccountID) != null &&
                        mapProductAndAccountIdToTargetDetailList.get(dw.productId + '-' + dw.AccountID).size() > 0
                ) {
                    System.debug('-- in if-mapProductAndAccountIdToTargetDetailList.containsKey(dw.productId - dw.AccountID)->'+ mapProductAndAccountIdToTargetDetailList.containsKey(dw.productId + '-' + dw.AccountID));
                    for (CRM_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(dw.productId + '-' + dw.AccountID)) {
                        System.debug('In ifff1111 Valid Target targetDetailInstance -> '+targetDetailInstance);
                        // Commented Germany Code Changes
                        Date releaseDate = mapProductIdToInstance.get(dw.productId).Street_Date__c;

                        // For digital check PBEP Start Date lies between Target Calculated Dates to get a valid Target
                        if (mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                            releaseDate = mapUniqueKeyToValidPBEP.get(strKey).Start_Date__c;
                        }

                        // Account Plan Present for UK and France. take the Account Plan with CreatedDate Asc
                        if (targetDetailInstance.accountPlanInstance != null) {
                            validTargetDetailInstance = targetDetailInstance;
                            bCreateDealProductForInvalidTarget = true;
                            break;
                        }
                        // If Target record Present for Germany and it matches the Dates then take the Last Modified Target
                        // Commented Germany Code Changes
                        else if (targetDetailInstance.targetInstance != null) {
                            if (
                                    releaseDate != null &&
                                    targetDetailInstance.targetInstance.Calc_Start_Date__c <= releaseDate &&
                                    targetDetailInstance.targetInstance.Calc_End_Date__c >= releaseDate
                            ) {
                                validTargetDetailInstance = targetDetailInstance;
                                bCreateDealProductForInvalidTarget = true;
                                break;
                            }
                        } else {
                            bCreateDealProductForInvalidTarget = true;
                        }
                    }
                }
                // Dont create or update Deal Products for France if no valid Account Plan present and Germany & Nordics if no Target present
                // US274 : France Changes OR US352 : Germany
                else if (
                        validTargetDetailInstance == null && mapProductIdToInstance.containsKey(dw.productId) &&
                        mapIdToAccountInstance.containsKey(dw.AccountId) &&
                        (
                            (
                                (
                                    CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(mapIdToAccountInstance.get(dw.AccountId).Sales_Organization__c) ||
                                    CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS.contains(mapIdToAccountInstance.get(dw.AccountId).Sales_Organization__c)
                                ) &&
                                mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                            )||
                            (
                                (
                                    CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(mapIdToAccountInstance.get(dw.AccountId).Digital_Country_Code__c) ||
                                    CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES.contains(mapIdToAccountInstance.get(dw.AccountId).Digital_Country_Code__c)
                                ) &&
                                mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                            )
                        )
                        //mapProductIdToInstance.get(dw.productId).SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE
                ) {
                    bCreateDealProductForInvalidTarget = false;
                    System.debug('---in else if--->');
                }
                // Create or update Deal Products with Target Quanity 1 for UK / Germany even if no valid Account Plan present
                // Now applicable only for UK
                else {
                    bCreateDealProductForInvalidTarget = true;
                    System.debug('---in else else--->');
                }

                System.debug('--bCreateDealProductForInvalidTarget-->'+bCreateDealProductForInvalidTarget);
                if (bCreateDealProductForInvalidTarget) {
                    createDealProductRecord(
                        dw,
                        validTargetDetailInstance,
                        pricingHandler,
                        mapProductIdToInstance,
                        mapExistingDealProducts,
                        mapNewDealProductsToUpsert,
                        mapUniqueKeyToValidPBEP,
                        mapPriceBookEntry,
                        setProductAndAccountIdForTargets
                    );
                }
            }
        }
    }

    private static CRM_ProductPricingHandler processPricingDetails(
            CRM_ProductPricingHandler.DealWrapper[] listDealWrappers,
            Map<Id, Product2> mapProductIdToInstance
    ) {
        CRM_ProductPricingHandler pricingHandler = new CRM_ProductPricingHandler();
        Set<Id> accountIds = new Set<Id>();
        for (CRM_ProductPricingHandler.DealWrapper dealWrapperInstance : listDealWrappers) {
            accountIds.add(dealWrapperInstance.AccountId);
        }
        pricingHandler.setAccountIds = accountIds;
        pricingHandler.mapProductDetails = mapProductIdToInstance;
        pricingHandler.initializeAccountDetails();
        return pricingHandler;
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
            CRM_TargetRevenueDetail targetDetailInstance,
            CRM_ProductPricingHandler pricingHandler,
            Map<Id, Product2> mapProductIdToInstance,
            Map<String, OpportunityLineItem> mapExistingDealProducts,
            Map<String, OpportunityLineItem> mapNewDealProductsToUpsert,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<String,PricebookEntry> mapPriceBookEntry,
            Set<String> setProductAndAccountIdForTargets
    ) {
        Pricebook_Entry_Period__c pbep =
            mapUniqueKeyToValidPBEP.get(dw.productId + '-' + dw.pricebookId + '-' + dw.dealCurrency);
        Decimal productListPrice = pbep != null && pbep.List_Price__c != null ? pbep.List_Price__c : 0;
        Decimal accountPrice = pbep != null ? pricingHandler.getAccountPrice(dw, pbep) : 0;
        Decimal fileDiscount = pbep != null ? pricingHandler.getFileDiscountPercentage(dw, pbep) : 0;
        System.debug('--pbep-->'+pbep);

        OpportunityLineItem objDealProduct = new OpportunityLineItem();
        if (
                accountPrice > 0 &&
                mapPriceBookEntry.containsKey(
                    dw.pricebookId + '-' + dw.productId + '-' + dw.dealCurrency
                )
        ) {

            // Below code executes only for Scenario 3
            if (
                // mapExistingDealProducts -> map is used to check existing batch created deal products fetched through query
                mapExistingDealProducts.containsKey(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency) ||
                // Scenario 2 + 3 : mapNewDealProductsToUpsert -> map is used to check deal products cloned in Scenario 2 only and needs to be modified in Scenario 3
                mapNewDealProductsToUpsert.containsKey(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency)
            ) {

                // Fetch all the exsitng batch generated deal products only in case of Scenario 3
                objDealProduct =
                    mapExistingDealProducts.containsKey(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency)
                    ? mapExistingDealProducts.get(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency)
                    : mapNewDealProductsToUpsert.get(dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency);
 
                // Update the quantity of existing deal product in case of Scenario 3 for any deal product
                if (
                        objDealProduct != null //&&
                        //((objDealProduct.OpportunityLineItemSchedules.size() == 0 && objDealProduct.Manually_Schedule__c) ||
                        //!objDealProduct.Manually_Schedule__c) && 
                        //objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT 
                        //&& (target!= null && target.Target_Revenue_Has_Changed__c)
                ) {
                    System.debug('-in if Scenario 3 update--->');
                    mapNewDealProductsToUpsert.put(
                        dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency,
                        setDealProductValues(
                            objDealProduct,
                            dw,
                            targetDetailInstance,
                            accountPrice,
                            productListPrice,
                            fileDiscount,
                            mapUniqueKeyToValidPBEP,
                            mapPriceBookEntry,
                            mapProductIdToInstance
                        )
                    );
                }

                // If no existing batch generated deal product exists, create new deal product for Scenario 1
                // Or Scenario 2 (where we need to execute it as Scenario 1 in case of no deal products found to be cloned)
            } else {
                /*if (
                    mapExistingDealProducts.size() == 0 ||
                    !mapExistingDealProducts.containsKey(
                        dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency
                    )
                ) {*/
                System.debug('-in if-else->');
                if (
                        mapProductIdToInstance.containsKey(dw.productId) || 
                        mapUniqueKeyToValidPBEP.containsKey(dw.productId + '-' + dw.pricebookId + '-' + dw.dealCurrency)
                ) {
                    Boolean isNewDealProductInsertAllowed =
                        targetDetailInstance != null && 
                        (
                            CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(targetDetailInstance.salesOrg) ||
                            CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg) ||
                            CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS.contains(targetDetailInstance.salesOrg) ||
                            CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)
                            /*targetDetailInstance.salesOrg == CRM_AppConstants.TERRITORY_FRANCE_CODE ||
                            targetDetailInstance.salesOrg == CRM_AppConstants.TERRITORY_NETHERLAND_CODE ||
                            targetDetailInstance.salesOrg == CRM_AppConstants.TERRITORY_BELGIUM_CODE ||
                            targetDetailInstance.salesOrg == CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE*/
                        ) &&
                        //mapProductIdToInstance.get(dw.productId).SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
                        setProductAndAccountIdForTargets.contains(dw.productId + '-' + dw.accountId);

                   if (
                        mapProductIdToInstance.get(dw.productId).NR_Product_Created__c ||
                        mapProductIdToInstance.get(dw.productId).Street_Date_Has_Changed__c ||
                        mapUniqueKeyToValidPBEP.get(dw.productId + '-' + dw.pricebookId + '-' + dw.dealCurrency).Process_NR_Batch__c ||
                        isNewDealProductInsertAllowed
                   ) {
                        objDealProduct = new OpportunityLineItem();
                        objDealProduct.NR_Deal_Product_Unique_Key__c = dw.accountId + '-' + dw.productId;
                        mapNewDealProductsToUpsert.put(
                            dw.dealId + '-' + dw.productId + '-' + dw.dealCurrency,
                            setDealProductValues(
                                objDealProduct,
                                dw,
                                targetDetailInstance,
                                accountPrice,
                                productListPrice,
                                fileDiscount,
                                mapUniqueKeyToValidPBEP,
                                mapPriceBookEntry,
                                mapProductIdToInstance
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
            CRM_TargetRevenueDetail targetDetailInstance,
            Decimal accountPrice,
            Decimal productListPrice,
            Decimal fileDiscount,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP,
            Map<String,PricebookEntry> mapPriceBookEntry,
            Map<Id, Product2> mapProductIdToInstance
    ) {
        //Boolean calculatePrices = true;

        if (objDealProduct.Id == null) {
            objDealProduct.OpportunityId = dw.dealId;
            objDealProduct.PricebookEntryId =
                mapPriceBookEntry.get(dw.pricebookId + '-' + dw.productId + '-' + dw.dealCurrency).Id;
            objDealProduct.Quantity = 1;
            if (mapProductIdToInstance.containsKey(dw.productId)) {
                if (mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && objDealProduct.Replen_Quantity__c == null ) {
                    objDealProduct.Replen_Quantity__c = 0;
                    objDealProduct.Target_Quantity__c = 0;
                    System.debug('-if---mapProductIdToInstance.containsKey(dw.productId).Type__c-->'+mapProductIdToInstance.get(dw.productId).Type__c);
                } else if (mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL && objDealProduct.Initial_Quantity__c == null && objDealProduct.Replen_Quantity__c == null) {
                    objDealProduct.Initial_Quantity__c = 0;
                    objDealProduct.Target_Quantity__c = 0;
                    System.debug('-else if---mapProductIdToInstance.containsKey(dw.productId).Type__c-->'+mapProductIdToInstance.get(dw.productId).Type__c);
                }
            }
        } else {
            // For France Physical Products Prices Should not be updated
            /*if (
                    targetDetailInstance != null &&
                    (
                        CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(targetDetailInstance.salesOrg) ||
                        CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)
                    ) &&
                    targetDetailInstance.accountPlanInstance != null &&
                    targetDetailInstance.salesOrg != null &&
                    (
                        (
                            targetDetailInstance.salesOrg != CRM_AppConstants.TERRITORY_JAPAN_CODE &&// JAPAN US 481 - No Restriction for Update Prices of Physical Product in Japan
                            targetDetailInstance.salesOrg != CRM_AppConstants.TERRITORY_ITALY_CODE &&
                            targetDetailInstance.salesOrg != CRM_AppConstants.TERRITORY_SPAIN_CODE &&
                            targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                        ) ||
                        (
                            targetDetailInstance.salesOrg != CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE &&// JAPAN US 481 - No Restriction for Update Prices  of Digital Product in Japan
                            targetDetailInstance.salesOrg != CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE &&
                            targetDetailInstance.salesOrg != CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE &&
                            targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                        )
                    )
            ) {
                if (targetDetailInstance.accountPlanInstance != null && targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                    calculatePrices = false;
                }
            }*/
            }

        //if (calculatePrices) {
            objDealProduct.Account_Price__c = accountPrice.setScale(2);
            if (objDealProduct.OpportunityLineItemSchedules.size() == 0) {
                objDealProduct.UnitPrice = accountPrice.setScale(2);
            }
        //}

        if (mapUniqueKeyToValidPBEP.containskey(dw.productId + '-' + dw.pricebookId + '-' + dw.dealCurrency)) {
            Pricebook_Entry_Period__c pbep =
                mapUniqueKeyToValidPBEP.get(dw.productId + '-' + dw.pricebookId + '-' + dw.dealCurrency);
            objDealProduct.File_Discount__c = fileDiscount;

            if (mapProductIdToInstance.containsKey(dw.productId) && mapProductIdToInstance.get(dw.productId).RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                objDealProduct.ListPrice__c = pbep.Account_Price__c != null ? pbep.Account_Price__c : productListPrice;
            } else {
                objDealProduct.ListPrice__c = productListPrice;
            }

            //objDealProduct.Promoted_Price__c = pbep.Suggested_Price__c != null && pbep.Suggested_Price__c != 0 ? pbep.Suggested_Price__c : accountPrice;
            // Added code here as for NR stopped populating from DP trigger
            //if (calculatePrices) {
                objDealProduct.Minimum_Price__c = pbep.Minimum_Price__c;
                objDealProduct.Customer_Retail_Price__c = pbep.Retail_Price__c;
                if (objDealProduct.Promoted_Price__c == null) {
                    Decimal promotedPrice = objDealProduct.Account_Price__c;// pbep.Suggested_Price__c != null ? pbep.Suggested_Price__c :  //Suggested_Price__c, - US#895 - removed ref. of suggested price
                    objDealProduct.Promoted_Price__c = promotedPrice.setScale(2);
                }
            //}

            if (objDealProduct.Pricebook_Entry_Period__c != pbep.Id) {
                objDealProduct.Pricebook_Entry_Period__c = pbep.Id;
                System.debug('--in if pbep.Id--->'+pbep.Id);
            } 
        }

        System.debug('targetDetailInstance::'+targetDetailInstance);

        // Set quantity 0 if target record or its target revenue value is not present
        Decimal calculatedQuantity = 0;
        //Defect#4557 - temp variable to store actual target quantity without ceil.
        Decimal calculatedActualQuantity = 0;
        
        Boolean updateInitialQuantity = false;

        if (targetDetailInstance != null) {
            // US274 : France Changes
            if (
                    CRM_AppConstants.NR_WITH_FRANCE_LIKE_WITHOUT_BENELUX_SALES_ORGS.contains(targetDetailInstance.salesOrg) ||
                    CRM_AppConstants.NR_WITH_FRANCE_LIKE_WITHOUT_BENELUX_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)
                    /*CRM_AppConstants.FRANCE_SALES_ORGS.contains(targetDetailInstance.salesOrg) ||
                    CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)*/
            ) {
                // If AccountPlan.Target_Quantity__c is BLank or 0 then also create Deal Product with 0 value
                if (targetDetailInstance.accountPlanInstance != null) {

                    // For Japan, calculate quantity based on Target Revenue only if Target Revenue on Country Plan is populated else based on Target Quantity
                    if (
                            (
                                targetDetailInstance.salesOrg == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                                targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                            ) ||
                            (
                                targetDetailInstance.salesOrg == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE &&
                                targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                            )
                    ) {
                        Decimal price = 0;
                        if (
                                targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.Product_Market__c != null &&
                                targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.Product_Market__c ==  CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE
                        ) {
                            //Japan - DEF#3926
                            if (objDealProduct.Override_Pricing__c) {
                                price = objDealProduct.Rental_Revenue_Per_Unit__c;
                            } else {
                                price = targetDetailInstance.accountPlanInstance.Rental_Revenue_Per_Unit__c;
                                objDealProduct.Handling_Fee__c = targetDetailInstance.accountPlanInstance.Handling_Fee__c;
                                objDealProduct.Rental_Price__c = targetDetailInstance.accountPlanInstance.Rental_Price__c;
                                objDealProduct.Revenue_Share__c = targetDetailInstance.accountPlanInstance.Revenue_Share__c;
                                objDealProduct.Number_of_Rentals_per_Unit__c = targetDetailInstance.accountPlanInstance.Number_of_Rentals_per_Unit__c;
                                objDealProduct.Final_Purchase_Price__c =targetDetailInstance.accountPlanInstance.Final_Purchase_Price__c;
                                objDealProduct.Final_Purchase__c = targetDetailInstance.accountPlanInstance.Final_Purchase__c;
                                objDealProduct.Decay_Curve_Template__c = targetDetailInstance.accountPlanInstance.Decay_Curve_Template__c;
                            }
                        }
                        // For all Japan Digital & only Physical with Sell Through
                        else {
                            price = objDealProduct.Account_Price__c;
                        }

                        if (targetDetailInstance.accountPlanInstance.Target_Quantity__c != null && targetDetailInstance.accountPlanInstance.Target_Quantity__c > 0) {
                            calculatedQuantity = targetDetailInstance.accountPlanInstance.Target_Quantity__c;
                        } else if (
                                price != null && price > 0 &&
                                targetDetailInstance.accountPlanInstance.Total_Target__c != null &&
                                targetDetailInstance.accountPlanInstance.Total_Target__c > 0
                        ) {
                            calculatedQuantity = Math.ceil(targetDetailInstance.accountPlanInstance.Total_Target__c / price);
                            //Defect#4557 - code to be added to store value in new field actual target quantity without ceil
                            calculatedActualQuantity = targetDetailInstance.accountPlanInstance.Total_Target__c / price;
                        }
                    }
                    // For FR, calculate quantity based on Target Quantity
                    else {
                        calculatedQuantity =
                            targetDetailInstance.accountPlanInstance.Target_Quantity__c != null && targetDetailInstance.accountPlanInstance.Target_Quantity__c > 0
                            ? targetDetailInstance.accountPlanInstance.Target_Quantity__c
                            : 0;
                    }

                    // JAPAN US 481 - restrict Initial / Replen Quantity Update for Japan
                    if (targetDetailInstance.salesOrg == CRM_AppConstants.TERRITORY_JAPAN_CODE || targetDetailInstance.salesOrg == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE) {
                        updateInitialQuantity = false;
                    } else {
                        updateInitialQuantity = true;
                    }
                }
            } 
            // US155 : UK & US352 : Germany Changes : Now applicable only for UK and FR Benelux as Germany code removed
            else if (objDealProduct.Account_Price__c != null && objDealProduct.Account_Price__c > 0) {
                //Commented Germany Code Changes
                if (
                        CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS.contains(targetDetailInstance.salesOrg) || 
                        CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)
                ) {
                    if (
                            CRM_AppConstants.TERRITORY_NORDICS_CODE.contains(targetDetailInstance.salesOrg) ||
                            CRM_AppConstants.ACCOUNT_NORDICS_DIGITAL_COUNTRY_CODE.contains(targetDetailInstance.salesOrg)
                    ) {
                        updateInitialQuantity = true;
                    }

                    if (
                            targetDetailInstance.targetInstance != null &&
                            targetDetailInstance.targetInstance.Target_Units__c != null &&
                            targetDetailInstance.targetInstance.Target_Units__c > 0
                    ) {
                        calculatedQuantity = targetDetailInstance.targetInstance.Target_Units__c;
                    } else if (
                            targetDetailInstance.targetInstance != null &&
                            targetDetailInstance.targetInstance.Target__c != null &&
                            targetDetailInstance.targetInstance.Target__c > 0
                    ) {
                        calculatedQuantity = Math.ceil(targetDetailInstance.targetInstance.Target__c / objDealProduct.Account_Price__c);
                    }
                } else {
                    if (
                            CRM_AppConstants.NR_WITH_BENELUX_LIKE_SALES_ORGS.contains(targetDetailInstance.salesOrg) || 
                            CRM_AppConstants.NR_WITH_BENELUX_LIKE_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)
                    ) {
                        updateInitialQuantity = true;
                    }

                    if (
                            targetDetailInstance.accountPlanInstance != null &&
                            targetDetailInstance.accountPlanInstance.PublishedTarget__c != null &&
                            targetDetailInstance.accountPlanInstance.PublishedTarget__c > 0
                    ) {
                        calculatedQuantity = Math.ceil(targetDetailInstance.accountPlanInstance.PublishedTarget__c / objDealProduct.Account_Price__c);
                    }
                }
            }

            if (updateInitialQuantity) {
                // Only for France, italy, Spain , Nordics Physical Product where Manually Schedule = false and Initial Quantity is same as Target Quantity, populate Initial Quantity
                // with the updated Target Quantity
                if (
                    !objDealProduct.Manually_Schedule__c &&
                    objDealProduct.Target_Quantity__c == objDealProduct.Initial_Quantity__c &&
                    (
                        (targetDetailInstance.accountPlanInstance != null && targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) || 
                        (targetDetailInstance.targetInstance != null && targetDetailInstance.targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL)
                    )
                ) {
                    objDealProduct.Initial_Quantity__c = calculatedQuantity;
                } else if (
                    !objDealProduct.Manually_Schedule__c &&
                    objDealProduct.Target_Quantity__c == objDealProduct.Replen_Quantity__c &&
                    (
                        (targetDetailInstance.accountPlanInstance != null && targetDetailInstance.accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) || 
                        (targetDetailInstance.targetInstance != null && targetDetailInstance.targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL)
                    )
                ) {
                    //if (CRM_AppConstants.ACCOUNT_IT_SP_NO_DIGITAL_COUNTRY_CODES.contains(targetDetailInstance.salesOrg)) {
                        objDealProduct.Replen_Quantity__c = calculatedQuantity;
                    //}
                }
            }

            // Add Account Plan Id in deal products for all territories
            if (targetDetailInstance.accountPlanInstance != null) {
                objDealProduct.Account_Plan__c = targetDetailInstance.accountPlanInstance.Id;
            } else if (targetDetailInstance.targetInstance != null && targetDetailInstance.targetInstance.Account_Plan_Lookup__c != null) {
                objDealProduct.Account_Plan__c = targetDetailInstance.targetInstance.Account_Plan_Lookup__c;
            }
        }

        System.debug('calculatedQuantity--->'+calculatedQuantity);
        objDealProduct.Target_Quantity__c = calculatedQuantity;
        //Defect#4557  update actual target quantity on dea product
        objDealProduct.Actual_Target_Quantity__c = calculatedActualQuantity;
        
        System.debug('objDealProduct----->'+objDealProduct);
        return objDealProduct;
    }

    /**
     * @Description - Method to fetch existing Deal Products for List of Products
     * @name fetchExistingDealProducts
     * @param List<Product2> productList List of NR Products
     */
    public static void fetchExistingDealProducts(
            List<Product2> productList, Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts,
            Map<String, OpportunityLineItem> mapExistingDealProducts, Map<Id, Opportunity> mapDealIdToInstance,
            Map<String, Opportunity> mapDealUniqueStringToInstanceForApprovedOrCommitted
    ) {
        System.debug('-productList--->'+productList);
        System.debug('-mapDealIdToInstance--->'+mapDealIdToInstance);

        for (OpportunityLineItem dealProductInsatnce : [
            SELECT
                Id,
                Discount, Description, Product2Id,OpportunityId,PricebookEntryId,CurrencyIsoCode,UnitPrice,
                ProductCode,Quantity, Subtotal, Account_Price__c, Returned_Quantity__c, Returned_Amount__c,
                Actual_Revenue__c, Approved_Qty__c, Contribution_is_Minimum__c,//Allocation_Override__c,
                Customer_Retail_Price__c,Customer_Sell_Price__c, Decay_Curve_Template__c,
                Distribution_Cost__c, Estimated_Quantity__c,Initial_Quantity__c, ListPrice__c,Manually_Schedule__c,
                Master_Negative__c, Merchandising__c, Minimum_Contribution__c, NR_Deal_Product_Unique_Key__c,
                Open_Amount__c, Open_Quantity__c, Override_COP__c, P_L_Decay_Curve_Template__c, P_L_Quantity__c, 
                PAP__c, POS_Quantity__c, POS_Revenue__c, Price_is_Minimum__c, Production_Cost__c,
                Replen_Delay_Days__c, Replen_Quantity__c, Returns__c, Promoted_Price__c,
                Royalty_Fee_Fixed__c, Sales_Allowance__c, Target_Quantity__c,Pricebook_Entry_Period__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                //Japan - DEF#3926
                Rental_Revenue_Per_Unit__c, Handling_Fee__c, Rental_Price__c , Revenue_Share__c, Number_of_Rentals_per_Unit__c,
                Final_Purchase_Price__c , Final_Purchase__c, NR_Revenue_Recognition_Date__c, Override_Pricing__c,
                Opportunity.StageName,
                Opportunity.Pricebook2Id,
                Opportunity.CurrencyIsoCode,
                Opportunity.AccountId,
                Opportunity.Start_Date__c,
                Opportunity.CloseDate,
                Product2.Street_Date__c,
                Product2.Previous_Street_Date__c,
                Product2.Street_Date_Has_Changed__c,
                Opportunity.Sales_Organisation__c,
                (
                    SELECT
                        Id,
                        OpportunityLineItemId,
                        OpportunityLineItem.Opportunity.AccountId,
                        OpportunityLineItem.Product2Id,
                        Type,
                        Revenue,
                        Quantity,
                        Description,
                        ScheduleDate,
                        CurrencyIsoCode
                    FROM
                        OpportunityLineItemSchedules
                    ORDER BY ScheduleDate ASC
                )
            FROM
                OpportunityLineItem
            WHERE
                Product2Id IN: productList
                AND ((Product2.Street_Date__c != null AND Product2.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) OR Product2.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL)
                AND OpportunityId IN: mapDealIdToInstance.keySet()
                /*AND (
                    Opportunity.StageName =: CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT
                )*/
                AND (
                    Opportunity.RecordTypeId =:CRM_RecordTypeUtil.RT_DEAL_DIGITAL
                    OR Opportunity.RecordTypeId =:CRM_RecordTypeUtil.RT_DEAL_PHYSICAL
                )
                AND NR_Deal_Product_Unique_Key__c != null
            ORDER BY Opportunity.LastModifiedDate, LastModifiedDate DESC]
        ) {
            //if (dealProductInsatnce.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT) {
                // Map with all existing batch generated deal products
                mapExistingDealProducts.put(
                    dealProductInsatnce.OpportunityId + '-'
                        + dealProductInsatnce.Product2Id + '-'
                        + dealProductInsatnce.CurrencyIsoCode,
                    dealProductInsatnce
                );
            //}

            System.debug('dealProductInsatnce.NR_Deal_Product_Unique_Key__c'+dealProductInsatnce.NR_Deal_Product_Unique_Key__c);
            if (
                    mapProductIdToExistingDealProducts.containsKey(
                        dealProductInsatnce.NR_Deal_Product_Unique_Key__c
                    )
            ) {
                mapProductIdToExistingDealProducts.get(dealProductInsatnce.NR_Deal_Product_Unique_Key__c).add(dealProductInsatnce);
            } else {
                mapProductIdToExistingDealProducts.put(
                    dealProductInsatnce.NR_Deal_Product_Unique_Key__c,
                    new List<OpportunityLineItem> {dealProductInsatnce}
                );
            }

            // Deal Product whose Street Date is chnaged needs to be moved from current committed deal to a new deal
            if (
                    dealProductInsatnce.Product2.Street_Date_Has_Changed__c &&
                    mapDealIdToInstance.containsKey(dealProductInsatnce.OpportunityId) &&
                    mapDealIdToInstance.get(dealProductInsatnce.OpportunityId) != null &&
                    (
                        mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                        mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                    )
            ) {
                Opportunity dealInstance = mapDealIdToInstance.get(dealProductInsatnce.OpportunityId);
                String uniqueKey = dealInstance.Id + '-' + dealInstance.StageName;
                dealInstance.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                
               // added code as a part of DE#4754 CODE START
                if(dealInstance.Owner.IsActive == false  && dealInstance.Account.Owner_Games__r.IsActive == false ){
                    dealInstance.OwnerId = dealInstance.Account.OwnerId;
                }
                // added code as a part of DE#4754 CODE END
                
                mapDealUniqueStringToInstanceForApprovedOrCommitted.put(uniqueKey, dealInstance);
            }
            
            // added code as a part of DE#4754 CODE START
            else if(
                    mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).Owner.IsActive == false && 
                    mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).Account.Owner_Games__r.IsActive == false &&
                    (
                        mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName != CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED &&
                        mapDealIdToInstance.get(dealProductInsatnce.OpportunityId).StageName != CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                    )
            ) {
                    
                    Opportunity dealInstance = mapDealIdToInstance.get(dealProductInsatnce.OpportunityId);
                    dealInstance.OwnerId = dealInstance.Account.OwnerId;
                    String uniqueKey = dealInstance.Id + '-' + dealInstance.StageName;
                    mapDealUniqueStringToInstanceForApprovedOrCommitted.put(uniqueKey, dealInstance);
                    
            }
             // added code as a part of DE#4754 CODE END
        }
    }

    /**
     * @Description - Method to fetch Related Sold To Accounts for Product based on its Type
     * @name fetchRelatedAccounts
     * @param Product2 productInstance - NR product instance for which related Sold To Accoucts need to be fetched
     * @param Map<String, List<Account>> mapProductTypeWithRelatedAccounts - Map of Product Type with List of Accounts
     */
     public static Set<Account> fetchRelatedAccounts(
            Product2 productInstance,
            Map<String, Set<Account>> mapProductTypeWithRelatedAccounts
    ) {
        Set<Account> setRelatedAccounts = new Set<Account>();
        if (productInstance.Exclusive_Customer__c == null) {
            System.debug('-in else->'+productInstance.Type__c);
            System.debug('-in else-mapProductTypeWithRelatedAccounts--->'+mapProductTypeWithRelatedAccounts.keySet());
            System.debug('-in else-mapProductTypeWithRelatedAccounts--->'+mapProductTypeWithRelatedAccounts.values());
            String strdealProductType = null;
            if (productInstance.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)){
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = productInstance.Type__c;
            }
            if(mapProductTypeWithRelatedAccounts.containsKey(strdealProductType)){
                setRelatedAccounts.addAll(mapProductTypeWithRelatedAccounts.get(strdealProductType));
            }
        }
        System.debug('setRelatedAccounts:::'+setRelatedAccounts);
         return setRelatedAccounts;
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
            Map<String, List<CRM_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
            Set<String> setProductAndAccountIdForTargets
    ) {
        Map<String,Set<Account>> mapProductTypeWithRelatedAccounts =
            new Map<String,Set<Account>>();
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE,new Set<Account>());
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE,new Set<Account>());
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE,new Set<Account>());
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE,new Set<Account>());
        // US JAPAN : 561
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE,new Set<Account>());
        mapProductTypeWithRelatedAccounts.put(CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE,new Set<Account>());

        for (Account acc : lstSoldToAccounts) {
            // List<String> lstAccountType = new List<String>();
            /*if (acc.Games_Digital__c) {
               // lstAccountType.add(System.Label.CRM_Games_Digital_Product_Type);
               mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE).add(acc);
            } if (acc.Video_Digital__c) {
                mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE).add(acc);
            } if (acc.Games_Physical__c) {
                mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE).add(acc);
            } if (acc.Video_Physical__c) {
                mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE).add(acc);
            }*/
            if (acc.Storefront__c == null) {
                if (acc.Games_Physical__c) {
                    mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE).add(acc);
                } if (acc.Video_Physical__c) {
                    mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE).add(acc);
                }

                // US JAPAN : 561
                if (acc.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && acc.Music_Physical__c) {
                    mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE).add(acc);
                }
            } else {
                if (acc.Games_Digital__c) {
                    // lstAccountType.add(System.Label.CRM_Games_Digital_Product_Type);
                    mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE).add(acc);
                }

                if (acc.Video_Digital__c) {
                    mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE).add(acc);
                }

                // US JAPAN : 561
                if (acc.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE && acc.Music_Digital__c) {
                    mapProductTypeWithRelatedAccounts.get(CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE).add(acc);
                }
            }

            /*
            System.debug('lstAccountType::'+lstAccountType);
            for (String strType : lstAccountType) {
                if (mapProductTypeWithRelatedAccounts.containsKey(strType)) {
                    List<Account> lstAcc = mapProductTypeWithRelatedAccounts.get(strType);
                    lstAcc.add(account);
                    mapProductTypeWithRelatedAccounts.put(strType, lstAcc);
                } else {
                    mapProductTypeWithRelatedAccounts.put(strType, new List<Account>{account});
                }
            }*/

            System.debug('--acc.Account_Plans__r-->'+acc.Account_Plans__r.size());

            // Process on Account Plan records for Non-Germany Users
            for (Account_Plan__c accountPlanInstance : acc.Account_Plans__r) {
                //if (accountPlanInstance.Customer__r.Sales_Organization__c == accountPlanInstance.Country_Plan__r.NR_Product__r.SAP_Sales_Org__c) {
                String uniqueKey = accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c;

                // For France, Target Quantity will be calculated from Account Plan.Target Quantity.
                // If its not specified then also Deal Products needs to be created with 0 value
                // For other territiry (Eg : UK) if Published Target is not present then deal Product needs to be created with 1 value
                if (
                        // US274 : France Changes
                        (
                            CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountPlanInstance.Customer__r.Sales_Organization__c) &&
                            accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                        ) ||
                        (
                            CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountPlanInstance.Customer__r.Digital_Country_Code__c) &&
                            accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                        ) ||
                        /*accountPlanInstance.Customer__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE ||
                        accountPlanInstance.Customer__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE ||
                        accountPlanInstance.Customer__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE ||
                        accountPlanInstance.Customer__r.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE ||*/
                        // US155 : UK & US352 : Germany Changes : Now applicable only for UK as Germany code removed
                        (
                            (
                                (
                                    !CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountPlanInstance.Customer__r.Sales_Organization__c) &&
                                    accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                                ) ||
                                (
                                    !CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountPlanInstance.Customer__r.Digital_Country_Code__c) &&
                                    accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                                )
                            ) &&
                            /*accountPlanInstance.Customer__r.Sales_Organization__c != CRM_AppConstants.TERRITORY_FRANCE_CODE &&
                            accountPlanInstance.Customer__r.Sales_Organization__c != CRM_AppConstants.TERRITORY_NETHERLAND_CODE &&
                            accountPlanInstance.Customer__r.Sales_Organization__c != CRM_AppConstants.TERRITORY_BELGIUM_CODE &&
                            accountPlanInstance.Customer__r.Digital_Country_Code__c != CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE &&*/
                            accountPlanInstance.PublishedTarget__c != null
                        )
                ) {
                    CRM_TargetRevenueDetail targetDetailsInstance = new CRM_TargetRevenueDetail();
                    targetDetailsInstance.isAccountPlanPresent = true;

                    if (accountPlanInstance.Customer__r.Video_Digital__c || accountPlanInstance.Customer__r.Games_Digital__c || accountPlanInstance.Customer__r.Music_Digital__c) {
                        targetDetailsInstance.salesOrg = accountPlanInstance.Customer__r.Digital_Country_Code__c;
                    } else {
                        targetDetailsInstance.salesOrg = accountPlanInstance.Customer__r.Sales_Organization__c;
                    }

                    targetDetailsInstance.accountPlanInstance = accountPlanInstance;
                    if (accountPlanInstance.Target_Revenue_Has_Changed__c) {
                        setProductAndAccountIdForTargets.add(uniqueKey);
                    }
                    if (mapProductAndAccountIdToTargetDetailList.containsKey(uniqueKey)) {
                        mapProductAndAccountIdToTargetDetailList.get(uniqueKey).add(targetDetailsInstance);
                    } else {
                        mapProductAndAccountIdToTargetDetailList.put(
                            uniqueKey,
                            new List<CRM_TargetRevenueDetail>{targetDetailsInstance}
                        );
                    }
                }
                //}
            }

            System.debug('--acc.Targets__r-->'+acc.Targets__r.size());

            // Process on Target records for Germany Users
            //Commented Germany Code Changes
            for (Target__c targetInstance : acc.Targets__r) {
                String uniqueKey = targetInstance.Product__c + '-' + targetInstance.Account__c;
                CRM_TargetRevenueDetail targetDetailsInstance = new CRM_TargetRevenueDetail();
                targetDetailsInstance.isAccountPlanPresent = false;
                targetDetailsInstance.targetInstance = targetInstance;
                if (targetInstance.Target_Revenue_Has_Changed__c) {
                        setProductAndAccountIdForTargets.add(uniqueKey);
                    }
                if (targetInstance.Account__r.Video_Digital__c || targetInstance.Account__r.Games_Digital__c) {
                    targetDetailsInstance.salesOrg = targetInstance.Account__r.Digital_Country_Code__c;
                } else {
                    targetDetailsInstance.salesOrg = targetInstance.Account__r.Sales_Organization__c; //targetInstance.Product__r.SAP_Sales_Org__c;
                }
                if (mapProductAndAccountIdToTargetDetailList.containsKey(uniqueKey)) {
                    mapProductAndAccountIdToTargetDetailList.get(uniqueKey).add(targetDetailsInstance);
                } else {
                    mapProductAndAccountIdToTargetDetailList.put(
                        uniqueKey,
                        new List<CRM_TargetRevenueDetail>{targetDetailsInstance}
                    );
                }
            }

            System.debug('mapProductAndAccountIdToTargetDetailList::'+mapProductAndAccountIdToTargetDetailList);
            for(Opportunity deal : acc.Opportunities){
                mapDealIdToInstance.put(deal.Id, deal);
            }
        }
        return mapProductTypeWithRelatedAccounts;
     }

    /**
     * @Description - Method to check if the Deal is valid with respect to Product
     * @name isValidDeal 
     * @param Opportunity dealInstance - Existing deal instance that needs to be validated
     * @param Product2 productInstance - NR product instance to match some criterias with the existing deal
     * @return Boolean Returns true if all the criteris match with the exsting deal for the specified NR product
     */
    private static Boolean isValidDeal(Account accountInstance, Opportunity dealInstance, Product2 productInstance) {
        System.debug('dealInstance::'+dealInstance);
        System.debug('dealInstance.Product_Type__c::'+dealInstance.Product_Type__c);
        System.debug('dealInstance.NR_Deal_Unique_Key__c::'+dealInstance.NR_Deal_Unique_Key__c);
        System.debug('productInstance::'+productInstance);
        // DEF#4275
        String strdealProductType = null;
        if (productInstance.Type__c == CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE) {
            strdealProductType = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        } else {
            strdealProductType = productInstance.Type__c;
        }
        //Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();
        String dealPeriod = '';
        String dealUniqueKey = '';
        Id dealRecordTypeId;
        if (accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE || accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE) {
            //mapStartAndCloseDateForDeal = calculateDatesForDeal(productInstance.Street_Date__c, CRM_AppConstants.NR_Deal_For_Quarter);
            Integer currentQtr =
                Decimal.valueOf(
                    productInstance.Street_Date__c.toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr;
        } else {
            //mapStartAndCloseDateForDeal = calculateDatesForDeal(productInstance.Street_Date__c, CRM_AppConstants.NR_Deal_For_Month);
            if (
                    accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                    productInstance.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                    CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(productInstance.Product_Market__c)
            ) {
                Map<String, Date> mapStartAndCloseDateForDeal = calculateDatesForJapanDeal(productInstance.Street_Date__c);
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    dealPeriod = startMonth + '-' + endMonth;
                }
            } else {
                Datetime sDate =
                    datetime.newInstance(
                        productInstance.Street_Date__c.year(),
                        productInstance.Street_Date__c.month(),
                        productInstance.Street_Date__c.day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }
        }

        if(dealInstance.Product_Type__c != null){
            dealUniqueKey = accountInstance.Id + '-' + dealPeriod + '-' + fetchProductTypeShortName(dealInstance.Product_Type__c);
        }

        System.debug('dealUniqueKey::'+dealUniqueKey);
        if (CRM_RecordTypeUtil.RT_DEAL_DIGITAL != null && CRM_RecordTypeUtil.RT_DEAL_PHYSICAL != null) {
            if(dealInstance.Product_Type__c!= null){
                if(
                        dealInstance.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE ||
                        dealInstance.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE 
                        // || dealInstance.Product_Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE // US JAPAN : 561
                ) {
                    dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        if (
            (
                dealInstance.Start_Date__c <= productInstance.Street_Date__c &&
                dealInstance.CloseDate >= productInstance.Street_Date__c
            ) &&
            /*(
                dealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT
            ) &&*/
            (
                dealInstance.RecordTypeId == dealRecordTypeId
            ) &&
            (   dealInstance.Product_Type__c != null &&
                strdealProductType != null &&
                strdealProductType.contains(dealInstance.Product_Type__c)
            ) &&
            (   dealUniqueKey != null &&
                dealInstance.NR_Deal_Unique_Key__c != null &&
                dealUniqueKey == dealInstance.NR_Deal_Unique_Key__c
            )
        ) {
            System.debug('###'+true);

            // JAPAN US 481 - Method executed only for Physical Products
            if (
                    (
                        productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                        accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE
                    ) &&
                    CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(productInstance.Product_Market__c) &&
                    productInstance.Product_Market__c != dealInstance.Market_Type__c
            ) {
                return false;
            }
            return true;
        } else {
            System.debug('###'+false);
            return false;
        }
    }

    /**
     * @Description - Method to fetch the deal Product that needs to be cloned
     * @name fetchDealProductToClone 
     * @param Account accountInstance - Account for which the deal Product needs to be decideed as Unique
     * @param Product2 productInstance - Product for which the Deal Product needs to be decideed as unique
     * @param Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts - Map of all Deal Products unique to the combination of Account and Product
     * @return accountInstance Return the deal product instance that needs to be cloned
     */
    public static OpportunityLineItem fetchDealProductToClone(
            Account accountInstance, Product2 productInstance,
            Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts
    ) {
        OpportunityLineItem validDealProductToCloneInstance;
        if (mapProductIdToExistingDealProducts.containsKey(accountInstance.Id +'-'+ productInstance.Id)) {
            System.debug('-S2---->');
            for (
                OpportunityLineItem dealProduct :
                    mapProductIdToExistingDealProducts.get(
                        accountInstance.Id +'-'+ productInstance.Id
                    )
            ) {
                System.debug('In for!!!'+dealProduct);
                validDealProductToCloneInstance = dealProduct;
                break;
            }
        } 
        return validDealProductToCloneInstance;
    }

    /**
     * @Description - Class for calculatiing Deal Product Target Quantity
     * @name CRM_TargetRevenueDetails
     */
    public class CRM_TargetRevenueDetail {
        public Boolean isAccountPlanPresent;
        public Account_Plan__c accountPlanInstance;
        public Target__c targetInstance;
        public String salesOrg;
    }

    /**
     * @Description - Class for Exception Handling
     * @name CRM_AutoPhysicalNRDealCreationServiceException
     */
    public class CRM_AutoPhysicalNRDealCreationServiceException extends Exception {
        public Id recordId;
        public List<String> lstErrors;
        public CRM_AutoPhysicalNRDealCreationServiceException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }
}