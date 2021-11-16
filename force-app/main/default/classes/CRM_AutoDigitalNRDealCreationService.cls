/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_AutoDigitalNRDealCreationService
   @CreateDate 31 Dec 2015
   @Description This batch class is responsible for automatic creation of Deals, and corresponding 
                Deal Products associated to them for Physical NR products created in the system.
                Scenario 1: Create new Deal and Deal Products if no Deal found related to "Sold To" Accounts for each NR Products inserted.
                Scenario 2: Clone Deal Product once Street Date of NR Product is updated or create new deal if not present.
                Scenario 3: Update Deal Product Quantity of NR Product if its related Target's revenue is updated or new Target is created.
   @Version <1.0>
   @reference Requirement no 155
*/
public with sharing class CRM_AutoDigitalNRDealCreationService {

    static Id digitalDealRecordTypeId;
    static Id physicalDealRecordTypeId;

    /**
     * @Description - Method to process all NR Product records
     * @name processNRProductRecords
     * @param lstSoldToAccounts List of all Sold To Accounts
     * @param lstNRProducts List of all NR Products
     * @param setProductAndAccountIdForTargets - Map of Product Id to corresponding List of Targets
     * @param mapIdToPBEPInstance - Map of all PBEP related to NR Physical Products being processed
     * @param setProcessedProductIds Set of all the Processed Product Ids
     */
    public static List<CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException> processNRProductRecords(
            List<Account> lstSoldToAccounts,
            List<Product2> lstNRProducts,
            //Set<String> setProductAndAccountIdForTargets,
            Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance,
            Set<Id> setProcessedProductIds
    ) {
    System.debug('lstNRProducts::'+lstNRProducts);  
    System.debug('mapIdToPBEPInstance::'+mapIdToPBEPInstance);
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
    Map<Id, Opportunity> mapDealIdToInstance = new Map<Id, Opportunity>();
    Map<String,PricebookEntry> mapPriceBookEntry = new Map<String,PricebookEntry>();
    Map<String, List<OpportunityLineItemSchedule>> mapExistingDealProductsWithSchedules = 
        new Map<String, List<OpportunityLineItemSchedule>>();
    Map<String, List<CRM_AutoPhysicalNRDealCreationService.CRM_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList =
        new Map<String, List<CRM_AutoPhysicalNRDealCreationService.CRM_TargetRevenueDetail>>();
    List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
    List<CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions =
        new List<CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException>();
    Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal = new Map<Id, List<Opportunity>>();
    Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP = mapIdToPBEPInstance;
    Map<String, Opportunity> mapDealUniqueStringToInstanceForApprovedOrCommitted = new Map<String, Opportunity>();
    Map<Id, Account> mapIdToAccountInstance = new Map<Id, Account>();
    Set<String> setProcessedDealProductIds = new Set<String>();
    Set<String> setNewlyInsertedUniqueDPKey = new Set<String>();
    Map<Id, PricebookEntry> mapPBEIdToInstance = new Map<Id, PricebookEntry>();
    Set<String> setProductAndAccountIdForTargets = new Set<String>();

    try{
        System.debug('setProductAndAccountIdForTargets::'+setProductAndAccountIdForTargets);
        physicalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        digitalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        System.debug('--digitalDealRecordTypeId-->'+digitalDealRecordTypeId);
        System.debug('--physicalDealRecordTypeId-->'+physicalDealRecordTypeId);
        if (!lstSoldToAccounts.isEmpty()) {
            mapIdToAccountInstance = new Map<Id, Account>(lstSoldToAccounts);
        }
        System.debug('--mapIdToAccountInstance.keySet()->'+mapIdToAccountInstance.keySet());

        //Map of Type with corresponding Set of Accounts
        Map<String,Set<Account>> mapProductTypeWithRelatedAccounts =
            CRM_AutoPhysicalNRDealCreationService.fetchListOfAccountsForType(
                lstSoldToAccounts,
                mapDealIdToInstance,
                mapProductAndAccountIdToTargetDetailList,
                setProductAndAccountIdForTargets
            );
        System.debug('mapProductTypeWithRelatedAccounts::'+mapProductTypeWithRelatedAccounts);

        if (mapDealIdToInstance.size() > 0 && !mapDealIdToInstance.values().isEmpty()) {
            //Fetch Existing Deal Product for products
            CRM_AutoPhysicalNRDealCreationService.fetchExistingDealProducts(
                lstNRProducts, mapProductIdToExistingDealProducts, mapExistingDealProducts,
                mapDealIdToInstance, mapDealUniqueStringToInstanceForApprovedOrCommitted
            );
        }

        System.debug('--mapExistingDealProducts-->'+mapExistingDealProducts);
        System.debug('--mapProductIdToExistingDealProducts-->'+mapProductIdToExistingDealProducts);

        for (Product2 productInstance : lstNRProducts) {
            System.debug('productInstance::'+productInstance);
            mapProductIdToInstance.put(productInstance.Id, productInstance);
            setSelectedAccounts =
                CRM_AutoPhysicalNRDealCreationService.fetchRelatedAccounts(productInstance,mapProductTypeWithRelatedAccounts);
            for (Account accountInstance : setSelectedAccounts) {
                Boolean bCreateNewDeal = false;

                // Boolean Flag to distinguish France Sales Org
                Boolean isFranceAndGermanySalesOrg =
                    // productInstance.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
                    CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c) ||
                    CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c);

                    // || CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c);
                    /*accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE ||
                    accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE ||
                    accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE ||
                    accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;*/

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
                            setProcessedProductIds,mapProductIdToExistingDealProducts,setPriceBookIds,mapExistingDealProducts,setProcessedDealIds,
                            mapNewDealProductsToUpsert,mapDealNameToProductInstance, mapUniqueKeyToValidPBEP,mapExistingDealProductsWithSchedules,
                            mapProductIdAndAssociatedDeal, mapDealUniqueStringToInstanceForApprovedOrCommitted
                        );
                } else {
                    System.debug('--no deals present for the account else -->');

                    // Create new deal for Scenario 1 and 2 and for Scenario 3 only in case of France
                    /*if (
                            productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                            (isFranceAndGermanySalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id))
                    ) {*/
                        bCreateNewDeal = true;
                    /*} else {
                        setProcessedProductIds.add(productInstance.Id);
                    }*/
                }

                // Create New Deal RECORDS
                if (bCreateNewDeal) {
                    //Create new deal
                    Opportunity newDeal = createDealWithAccounts(accountInstance,productInstance, mapUniqueKeyToValidPBEP);
                    System.debug('newDeal::'+newDeal);

                    // Boolean flag to allow deal creation in France only if Account Plan details present in case of Scenario 1, 2 & 3
                    // Boolean flag to allow deal creation in Germany only if Target details present in case of Scenario 1, 2 & 3
                    Boolean isTargetPresent = false;

                    if (CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c)) {
                        // Check for valid target present for Germany
                        if (
                                mapProductAndAccountIdToTargetDetailList.containsKey(productInstance.Id + '-' + accountInstance.Id) &&
                                mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id) != null &&
                                mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id).size() > 0
                        ) {
                            for (CRM_AutoPhysicalNRDealCreationService.CRM_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id)) {
                                if (
                                    mapUniqueKeyToValidPBEP.containsKey(productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode) &&
                                    mapUniqueKeyToValidPBEP.get(productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode) != null
                                ) {
                                    Date releaseDate =
                                        mapUniqueKeyToValidPBEP.get(productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode).Start_Date__c;
                                    if (releaseDate != null &&
                                        targetDetailInstance.targetInstance.Calc_Start_Date__c <= releaseDate &&
                                        targetDetailInstance.targetInstance.Calc_End_Date__c >= releaseDate
                                    ) {
                                        isTargetPresent = true;
                                        break;
                                    }
                                }
                            }
                        }
                    } else {
                        isTargetPresent = mapProductAndAccountIdToTargetDetailList.containsKey(productInstance.Id + '-' + accountInstance.Id) &&
                        mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id) != null &&
                        mapProductAndAccountIdToTargetDetailList.get(productInstance.Id + '-' + accountInstance.Id).size() > 0;
                    }

                    Boolean isValidNewDealInsertAllowed =
                        newDeal != null &&
                        mapUniqueKeyToValidPBEP.containsKey(productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode) &&
                        mapUniqueKeyToValidPBEP.get(productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode) != null &&
                        (
                            productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                            mapUniqueKeyToValidPBEP.get(productInstance.Id + '-' + newDeal.PriceBook2Id + '-' + newDeal.CurrencyIsoCode).Process_NR_Batch__c ||
                            (isFranceAndGermanySalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id))
                        );

                    // If no valid PBEP found, don't create new Deal
                    // If no Account Plans found for France, don't create new Deal
                    if (
                        isValidNewDealInsertAllowed &&
                        (!isFranceAndGermanySalesOrg || (isFranceAndGermanySalesOrg && isTargetPresent))
                    ) {
                        if (CRM_AutoPhysicalNRDealCreationService.processNewDeals(
                                newDeal,productInstance,accountInstance,lstDeleteDealProductsToBeCloned,lstNewDealsToInsert,setProcessedProductIds,
                                setPriceBookIds,mapDealNameToProductInstance,mapUniqueKeyToValidPBEP,mapProductIdAndAssociatedDeal, setProductAndAccountIdForTargets
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
                        /*OpportunityLineItem validDealProductToCloneInstance;
                        if (productInstance.Street_Date_Has_Changed__c) {
                            validDealProductToCloneInstance =
                                CRM_AutoPhysicalNRDealCreationService.fetchDealProductToClone(
                                    accountInstance, productInstance, mapProductIdToExistingDealProducts
                                );
                        }

                        // If no deal created due to no valid PBEP found or no Account Plan present for France, we don't clone the deal product but
                        // we have to delete the deal Product that was supposed to be cloned only if its Deal is in any Stage
                        if (validDealProductToCloneInstance != null) {
                            lstDeleteDealProductsToBeCloned.add(validDealProductToCloneInstance);
                        }*/
                        setProcessedProductIds.add(productInstance.Id);
                    }
                }
            }
        }

        System.debug('lstNewDealsToInsert:111:'+lstNewDealsToInsert);
        // List<Opportunity> dealToBeInsertedFilteredList = new List<Opportunity>();
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
                                        CRM_AutoPhysicalNRDealCreationService.processScenarioTwo(
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

        CRM_AutoPhysicalNRDealCreationService.fetchPriceBookEntryForProduct(setPriceBookIds, mapProductIdToInstance, mapPriceBookEntry);

        // Calling method to create Deal Products on Deals
        CRM_AutoPhysicalNRDealCreationService.createDealProductOnDeal(
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
            new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
                null,
                new List<String>{e.getMessage()}
            )
        );
    }
        // Map<Id, OpportunityLineItem> mapIdToInsertedDPInstance = new Map<Id, OpportunityLineItem>();
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
                            new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
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
        System.debug('dealProductToBeDeletedFilteredList::'+dealProductToBeDeletedFilteredList);
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
                            new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
                                productId,
                                lstErrors
                            )
                        );
                    }
                }
            }
        }
        System.debug('dealProductToBeDeletedFilteredList::'+dealProductToBeDeletedFilteredList);

        System.debug('--mapExistingDealProductsWithSchedules--->'+mapExistingDealProductsWithSchedules);
        for(String strDealProduct : mapExistingDealProductsWithSchedules.keySet()){
            OpportunityLineItem dealProduct;

            if (mapExistingDealProducts.containsKey(strDealProduct)) {
                dealProduct = mapExistingDealProducts.get(strDealProduct);
            } else if (mapNewDealProductsToUpsert.containsKey(strDealProduct)) {
                dealProduct = mapNewDealProductsToUpsert.get(strDealProduct);
            }

            if (dealProduct != null) {
                String uniquePBEP = dealProduct.Product2Id + '-' + dealProduct.Opportunity.PriceBook2Id + '-' + dealProduct.Opportunity.CurrencyIsoCode;
                if (mapUniqueKeyToValidPBEP.containsKey(uniquePBEP)) {
                    Pricebook_Entry_Period__c pbep = mapUniqueKeyToValidPBEP.get(uniquePBEP);
                    for (OpportunityLineItemSchedule dealProductSchedule : mapExistingDealProductsWithSchedules.get(strDealProduct)){
                        if (dealProductSchedule.Id == null) {
                            dealProductSchedule.OpportunityLineItemId = dealProduct.Id;
                        }

                        dealProductSchedule.ScheduleDate =
                            calculateScheduleDateForClonedSchedules(pbep, dealProductSchedule.ScheduleDate);
                        lstDealProductSchedulesToBeCloned.add(dealProductSchedule);
                    }
                }
            }
        }

        System.debug('lstDealProductSchedulesToBeCloned::'+lstDealProductSchedulesToBeCloned);
        if (!lstDealProductSchedulesToBeCloned.isEmpty()) {
            Database.UpsertResult[] saveResultList =
                Database.upsert(lstDealProductSchedulesToBeCloned, false);
            OpportunityLineItemSchedule scheduleInstance;
            // OpportunityLineItem dealProduct;
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
                            new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
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
            Set<String> setProductAndAccountIdForTargets, Map<String, List<CRM_AutoPhysicalNRDealCreationService.CRM_TargetRevenueDetail>> mapProductAndAccountIdToTargetDetailList,
            List<CRM_ErrorLogger.ErrorLog> listErrorLog, List<CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions
    ) {
        Map<Id, Decimal> mapAccountPlanIdToUpdatedNRVersion = new Map<Id, Decimal>();
        for (Account_Plan__c accountPlanInstance : [
                SELECT
                    Id, NR_Version__c,
                    Target_Revenue_Has_Changed__c,
                    Country_Plan__r.NR_Product__c
                FROM
                    Account_Plan__c
                WHERE
                    Target_Revenue_Has_Changed__c = true
                    AND Country_Plan__c != null
                    AND Country_Plan__r.NR_Product__c IN: lstNRProducts
                    AND Customer__c != null
                    AND Customer__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                    AND Customer__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_ACTIVE
                    AND
                    (
                        Customer__r.Games_Digital__c = true
                        OR Customer__r.Video_Digital__c = true
                        OR (Customer__r.Music_Digital__c = true AND Customer__r.Digital_Country_Code__c =: CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                    )
                    AND Customer__r.Digital_Country_Code__c NOT IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES
                    AND Customer__r.Games_Physical__c = false
                    AND Customer__r.Video_Physical__c = false
                    AND Customer__r.Music_Physical__c = false
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
                    AND Product__c != null
                    AND Product__c IN: lstNRProducts
                    AND Account__c != null
                    AND Account__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                    AND Account__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_ACTIVE
                    AND
                    (
                        Account__r.Games_Digital__c = true
                        OR Account__r.Video_Digital__c = true
                    )
                    AND Account__r.Games_Physical__c = false
                    AND Account__r.Video_Physical__c = false
                    AND Account__r.Price_Book__c != null
                    AND Account__c IN: lstSoldToAccounts
                    AND Account__r.Digital_Country_Code__c IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES
        ]) {
            mapAccountPlanIdToUpdatedNRVersion.put(targetInstance.Id, targetInstance.NR_Version__c);
        }

        System.debug('-mapAccountPlanIdToUpdatedNRVersion-->'+mapAccountPlanIdToUpdatedNRVersion);

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
                        CRM_AutoPhysicalNRDealCreationService.CRM_TargetRevenueDetail targetDetailInstance : mapProductAndAccountIdToTargetDetailList.get(uniqueKey)
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
            listErrorLog.addAll(CRM_AutoPhysicalNRDealCreationService.resetProcessedAccountPlanFlags(updateProcessedAccountPlanList, lstExceptions));
        }

        if (!updateProcessedTargetList.isEmpty()) {
            listErrorLog.addAll(CRM_AutoPhysicalNRDealCreationService.resetProcessedTargetFlags(updateProcessedTargetList, lstExceptions));
        }
    }

    /**
     * @Description - Method to calculate Schedule Date for all the schedules that are cloned  when street Date is changed
     * @name calculateScheduleDateForClonedSchedules
     * @param related - Instance of digital product PricebookEntryPeriod for which Start Date has been changed
     * @param oldScheduleDate - Old Schedule Date which is recieved from Schedules for a deal product
     *                          that needs to be cloned for changed Start Date of its related Product PBEP
     * @return Date - New ScheduleDate calculated based on Street Date changed
     */
    private static Date calculateScheduleDateForClonedSchedules(Pricebook_Entry_Period__c pbep, Date oldScheduleDate) {
        Date newScheduleDate = null;

        if (pbep.Start_Date__c != null && oldScheduleDate != null) {
            Date oldStreetDate = pbep.Previous_Start_Date__c != null ? pbep.Previous_Start_Date__c : pbep.Start_Date__c;
            Integer numberDaysDifference = oldStreetDate.daysBetween(oldScheduleDate);

            Date nweStreetDate = pbep.Start_Date__c;
            newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        }
        return newScheduleDate;
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
            Set<Id> setProcessedProductIds, Map<String, List<OpportunityLineItem>> mapProductIdToExistingDealProducts,
            Set<Id> setPriceBookIds, Map<String, OpportunityLineItem> mapExistingDealProducts, Set<Id> setProcessedDealIds,
            Map<String, OpportunityLineItem> mapNewDealProductsToUpsert, Map<String, List<Product2>> mapDealNameToProductInstance,
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP, Map<String, List<OpportunityLineItemSchedule>> mapExistingDealProductsWithSchedules,
            Map<Id, List<Opportunity>> mapProductIdAndAssociatedDeal, Map<String, Opportunity> mapDealUniqueStringToInstanceForApprovedOrCommitted
    ) {
        Boolean bCreateNewDeal = false;
        Opportunity validDealInstance ;
        for (Opportunity dealInstance : mapAccountIdToAllDeals.get(accountInstance.Id)) {
            String strKey = productInstance.Id + '-' + dealInstance.PriceBook2Id + '-' + dealInstance.CurrencyIsoCode;
            System.debug('---in for--strKey-->'+strKey);
            if (mapUniqueKeyToValidPBEP.containsKey(strKey)) {
                // Check the product streetDate lie inside deal start date and End date 
                if(isValidDeal(accountInstance, dealInstance, productInstance, mapUniqueKeyToValidPBEP)){
                    validDealInstance = dealInstance;
                    System.debug('validDealInstance::'+validDealInstance);
                    break;
                }
            }
        }
        if(validDealInstance != null) {
            Boolean updateCommittedDealAllowed = false;
            String validPBEPKey = productInstance.Id + '-' + validDealInstance.PriceBook2Id + '-' + validDealInstance.CurrencyIsoCode;

            if (
                productInstance.NR_Product_Created__c  &&
                mapUniqueKeyToValidPBEP.containsKey(validPBEPKey) &&
                mapUniqueKeyToValidPBEP.get(validPBEPKey) != null
            ) {
                // Process for S1
                CRM_AutoPhysicalNRDealCreationService.processScenarioOne(productInstance, validDealInstance,setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
                updateCommittedDealAllowed = true;
            } else if (
                productInstance.Street_Date_Has_Changed__c
            ) {
                if(validDealInstance.Id != null){
                    // Process for S2 & S2 + S3 for existing valid deal which is inserted
                    lstDeleteDealProductsToBeCloned.addAll(
                        CRM_AutoPhysicalNRDealCreationService.processScenarioTwo(
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
                }
                else if (
                    mapUniqueKeyToValidPBEP.containsKey(validPBEPKey) &&
                    mapUniqueKeyToValidPBEP.get(validPBEPKey) != null
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
                    setProductAndAccountIdForTargets.contains(productInstance.Id + '-' +validDealInstance.AccountId) &&
                    // validDealInstance.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT &&
                    mapUniqueKeyToValidPBEP.containsKey(validPBEPKey) &&
                    mapUniqueKeyToValidPBEP.get(validPBEPKey) != null
            ) {
                // Process for S3
                CRM_AutoPhysicalNRDealCreationService.processScenarioThree(
                    productInstance,
                    validDealInstance,
                    setProcessedProductIds,
                    setPriceBookIds,
                    mapUniqueKeyToValidPBEP,
                    mapProductIdAndAssociatedDeal
                );
                updateCommittedDealAllowed = true;
            } else if (
                mapUniqueKeyToValidPBEP.containsKey(validPBEPKey) &&
                mapUniqueKeyToValidPBEP.get(validPBEPKey) != null &&
                mapUniqueKeyToValidPBEP.get(validPBEPKey).Process_NR_Batch__c
            ) {
                CRM_AutoPhysicalNRDealCreationService.processScenarioOne(productInstance, validDealInstance,setProcessedProductIds, setPriceBookIds, mapUniqueKeyToValidPBEP, mapProductIdAndAssociatedDeal);
                updateCommittedDealAllowed = true;
            } else {
                setProcessedProductIds.add(productInstance.Id);
            }
            bCreateNewDeal = false;

            if (validDealInstance.Id != null && updateCommittedDealAllowed) {
                String uniqueKey = validDealInstance.Id + '-' + validDealInstance.StageName;
                if (
                        uniqueKey != null && !mapDealUniqueStringToInstanceForApprovedOrCommitted.containsKey(uniqueKey) &&
                        mapUniqueKeyToValidPBEP.containsKey(validPBEPKey) && mapUniqueKeyToValidPBEP.get(validPBEPKey) != null &&
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
                // productInstance.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
                CRM_AppConstants.NR_WITH_FRANCE_LIKE_SALES_ORGS.contains(accountInstance.Sales_Organization__c) ||
                CRM_AppConstants.NR_WITH_FRANCE_LIKE_DIGITAL_COUNTRY_CODES.contains(accountInstance.Digital_Country_Code__c);

            // Create new deal only in case of S1 & S2 and S3 only if France
            if (
                    productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c ||
                    (isFranceSalesOrg && setProductAndAccountIdForTargets.contains(productInstance.Id + '-' + accountInstance.Id))
            ) {
                // Create new Deals (For Scenario 1 always and For Scenario 2 when
                // previous linked deal producct's deal is in any Stage) && For France in case of Scenario 3 as well
                bCreateNewDeal = true;
            } else {
                setProcessedProductIds.add(productInstance.Id);
            }*/
            bCreateNewDeal = true;
        }
        return bCreateNewDeal;
    }

    /**
     * @Description - Method to create Deal on an Account
     * @name createDealWithAccounts 
     * @param accountInstance - Instance of Account for which deal needs to be created
     * @param product - Instance of the Product for which deal needs to be created
     * @param  mapUniqueKeyToValidPBEP - Valid PBEP Map for Digital NR Products
     * @return Opportunity - Newly created Deal
     */
    private static Opportunity createDealWithAccounts(Account accountInstance, Product2 product, Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP) {

        String uniquePBEPKey = product.Id + '-' + accountInstance.Price_Book__c + '-' + accountInstance.CurrencyIsoCode;
        if (mapUniqueKeyToValidPBEP.containsKey(uniquePBEPKey)) {
            Pricebook_Entry_Period__c pbep = mapUniqueKeyToValidPBEP.get(uniquePBEPKey);

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

            if (
                //accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE  ||
                accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
            ) {
                mapStartAndCloseDateForDeal =
                    CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(pbep.Start_Date__c, CRM_AppConstants.NR_Deal_For_Quarter);
                Integer currentQtr =
                    Decimal.valueOf(
                        pbep.Start_Date__c.toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr;
                dealName = CRM_AppConstants.NR_Deal_Naming_Convention + strdealProductType + ' ' + CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr + ' ';

            } else {
                //JAPAN US 481
                if(
                        (
                            product.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                            accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE
                        )
                ) {
                    mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(pbep.Start_Date__c);
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

                        if (strdealProductType == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                            productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_GAMES_DIGITAL;
                        } else if (strdealProductType == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE) {
                            productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                        }
                        // US JAPAN : 561
                        else if (strdealProductType == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE) {
                            // DEF#4275
                            productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                            strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
                        }

                        if (product.Product_Market__c != null && CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(product.Product_Market__c)) {
                            if (product.Product_Market__c == CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE) {
                                marketType = CRM_AppConstants.NR_Deal_Japan_Market_Type_RENTAL;
                            } else {
                                marketType = CRM_AppConstants.NR_Deal_Japan_Market_Type_SELL_THROUGH;
                            }
                        }

                        if (productType != null) {
                            if (marketType != null) {
                                // For eg:  NR Rental Video Digital 2016年10月16日   to 2016年11月15日 NBC ユニバーサル・エンターテイメントジャパン合同会社
                                dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + marketType + productType + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day;
                            } else {
                                // For eg:  NR Video Digital 2016年10月16日   to 2016年11月15日 NBC ユニバーサル・エンターテイメントジャパン合同会社
                                dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + productType + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day;
                            }
                        }
                        dealPeriod = startMonth + '-' + endMonth;
                    }
                } else {
                    mapStartAndCloseDateForDeal =
                        CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(pbep.Start_Date__c, CRM_AppConstants.NR_Deal_For_Month);
                    Datetime sDate =
                        datetime.newInstance(
                            pbep.Start_Date__c.year(),
                            pbep.Start_Date__c.month(),
                            pbep.Start_Date__c.day()
                        );
                    String currentMonth = sDate.format('MMM');
                    dealPeriod = currentMonth;
                    dealName = CRM_AppConstants.NR_Deal_Naming_Convention + strdealProductType + ' ' + dealPeriod + ' ';
                }
            }

            //if(accountInstance.Games_Digital__c || accountInstance.Games_Physical__c){
            // DEF#4233
            
            //Added IsActive condition as a part of DE#4754
            if (strdealProductType == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                if(accountInstance.Owner_Games__c != null && accountInstance.Owner_Games__r.IsActive){
                    ownerId = accountInstance.Owner_Games__c;
                }
            }

            System.debug('strdealProductType::'+strdealProductType);
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
                    NR_Deal_Unique_Key__c = accountInstance.Id + '-' + dealPeriod + '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(product.Type__c),
                    OwnerId = ownerId
                );

            if (digitalDealRecordTypeId != null && physicalDealRecordTypeId != null) {
                if(deal.Product_Type__c!= null){
                    if(
                            deal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE ||
                            deal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE
                            // || deal.Product_Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE // US JAPAN : 561
                    ) {
                        deal.RecordtypeId = digitalDealRecordTypeId;
                    }else{
                        deal.RecordtypeId = physicalDealRecordTypeId;
                    }
                }
            }

            //JAPAN US 481
            if(
                    (
                        product.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                        accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE
                    ) &&
                    deal.RecordtypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL //&&
                    //product.Product_Market__c != null && CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(product.Product_Market__c)
            ) {
                if (product.Product_Market__c != null && CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(product.Product_Market__c)) {
                    deal.Market_Type__c = product.Product_Market__c;
                }
                deal.Name = dealName + ' ' + accountInstance.Name;
            } else {
                deal.Name = dealName + pbep.Start_Date__c.year() + ' ' + accountInstance.Name;
            }

            return deal;
        } else {
            return null;
        }
    }

    /**
     * @Description - Method to check if the Deal is valid with respect to Product
     * @name isValidDeal 
     * @param Opportunity dealInstance - Existing deal instance that needs to be validated
     * @param Product2 productInstance - NR product instance to match some criterias with the existing deal
     * @param Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP - Valid PBEP Map for Digital NR Products
     * @return Boolean Returns true if all the criteris match with the exsting deal for the specified NR product
     */
    private static Boolean isValidDeal(Account accountInstance, Opportunity dealInstance, Product2 productInstance, Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP) {
        // DEF#4275
        String strdealProductType = null;
        if (productInstance.Type__c.contains(CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE)) {
            strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
        } else {
            strdealProductType = productInstance.Type__c;
        }

        String dealPeriod = '';
        String dealUniqueKey = '';
        Id dealRecordTypeId;
        String strKey = productInstance.Id + '-' + dealInstance.Pricebook2Id + '-' + dealInstance.CurrencyIsoCode;
        Pricebook_Entry_Period__c pbep = mapUniqueKeyToValidPBEP.get(strKey);
        if (
                //accountInstance.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE  ||
                accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
        ) {
            Integer currentQtr =
                Decimal.valueOf(
                    pbep.Start_Date__c.toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr;
        } else {
            if(
                (
                    productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                    accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE
                ) // &&
                // productInstance.Product_Market__c != null && CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(productInstance.Product_Market__c)
            ) {
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(pbep.Start_Date__c);
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
                        pbep.Start_Date__c.year(),
                        pbep.Start_Date__c.month(),
                        pbep.Start_Date__c.day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }
        }

        if(dealInstance.Product_Type__c != null){
            dealUniqueKey = accountInstance.Id + '-' + dealPeriod + '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(dealInstance.Product_Type__c);
        }
        System.debug('dealUniqueKey::'+dealUniqueKey);
        if (digitalDealRecordTypeId != null && physicalDealRecordTypeId != null) {
            if(dealInstance.Product_Type__c!= null){
                if(
                        dealInstance.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE ||
                        dealInstance.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE 
                        //|| dealInstance.Product_Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE
                ) {
                    dealRecordTypeId = digitalDealRecordTypeId;
                }else{
                    dealRecordTypeId = physicalDealRecordTypeId;
                }
            }
        }
        if (
            (
                dealInstance.Start_Date__c <= pbep.Start_Date__c &&
                dealInstance.CloseDate >= pbep.Start_Date__c
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
            // JAPAN US 481 - Method executed only for Digital Products
            if (
                    (
                        productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                        accountInstance.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE
                    ) &&
                    productInstance.Product_Market__c != null &&
                    CRM_AppConstants.JAPAN_PRODUCT_MARKETS.contains(productInstance.Product_Market__c) &&
                    productInstance.Product_Market__c != dealInstance.Market_Type__c
            ) {
                return false;
            }

            System.debug('###'+true);
            return true;
        } else {
            System.debug('###'+false);
            return false;
        }
    }
}