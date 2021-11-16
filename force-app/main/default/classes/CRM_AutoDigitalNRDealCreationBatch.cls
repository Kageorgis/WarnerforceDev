/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_AutoDigitalNRDealCreationBatch
   @CreateDate 31 Dec 2015
   @Description This batch class is responsible for automatic creation of Deals, and corresponding
                Deal Products associated to them for Digital NR products created in the system.
   @Version <1.0>
   @reference Requirement no 155
*/
global with sharing class CRM_AutoDigitalNRDealCreationBatch implements Database.Batchable<sObject>, Database.stateful {

    global final String query;
    global final Map<Id, Product2> mapProducts;
    //global final Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
    // Commented Germany Code Changes
    global final Map<Id, List<Target__c>> mapProductIdToTargetList = new Map<Id, List<Target__c>>();
    //global final Set<String> setProductAndAccountIdForTargets = new Set<String>();
    global final Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance;
    global final Set<Id> setProcessedProductIds = new Set<Id>();
    global List<Id> localListProductIds;
    global final List<CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException> lstExceptions =
        new List<CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException>();

    /**
     * Batch constructor to assign query
     */
    global CRM_AutoDigitalNRDealCreationBatch() {

        // Query for fetching 'Sold To' Accounts with Opportunities
        this.query ='SELECT ' + 
                'Id, ' +
                'Name, ' +
                'Sales_Organization__c, ' +
                'Price_Book__c, ' +
                'Games_Digital__c, ' +
                'Video_Digital__c, ' +
                'Games_Physical__c, ' +
                'Video_Physical__c, ' +
                'CurrencyIsoCode, ' +
                'OwnerId, '+
                'Status__c, '+
                'Digital_Country_Code__c,' +
                'Owner_Games__c '+
                /*'(' +
                    'SELECT ' +
                        'Id, ' +
                        'RecordTypeId, ' +
                        'Name, ' +
                        'Start_Date__c, ' +
                        'CloseDate, ' +
                        'AccountID, ' +
                        'Pricebook2ID, ' +
                        'StageName, ' +
                        'Product_Type__c, '+
                        'NR_Deal_Unique_Key__c, '+
                        'CurrencyIsoCode ' +
                    'FROM ' +
                        'Opportunities ' +
//                    'WHERE ' +
//                        'StageName = \''+ CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT + '\' ' +
                '), ' + 
                '(' + 
                    'SELECT ' +
                    'Id,' +
                    'Customer__c,' +
                    'Country_Plan__c,' +
                    'Country_Plan__r.NR_Product__c,' +
                    'Country_Plan__r.RecordTypeId,' +
                    'PublishedTarget__c,' +
                    'Target_Revenue_Has_Changed__c, ' +
                    'NR_Version__c ' +
                'FROM ' +
                    'Account_Plans__r ' +
                'WHERE ' +
                    'Country_Plan__c != null ' +
                    'AND ' +
                    'Country_Plan__r.NR_Product__c != null ' +
                    'AND ' +
                    'Country_Plan__r.RecordTypeId = \'' + CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE + '\' ' +
                    'ORDER BY CreatedDate ASC' +
                ') ' +*/
            'FROM ' +
                'Account ' +
            'WHERE ' +
            	' Digital_Country_Code__c !=\''+CRM_AppConstants.ACCOUNT_BRAZIL_DIGITAL_COUNTRY_CODE+'\' '+ //ER-3242 Brazil Implementation
                'AND RecordTypeId = \'' + CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO + '\' ' +
                'AND Status__c = \'' + CRM_AppConstants.ACCOUNT_STATUS_ACTIVE + '\' ' +
                'AND (' +
                    'Games_Digital__c = true ' +
                    'OR Video_Digital__c = true ' +
                    'OR (Music_Digital__c = true AND Digital_Country_Code__c = \''+ CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE +'\' )' +
                ')' +
                ' AND Games_Physical__c = false' +
                ' AND Video_Physical__c = false' +
                //' AND id = \'0012D00000HXH5J\'' +
                ' AND Music_Physical__c = false';
        this.mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        this.mapProducts= new Map<Id, Product2>(getNRProducts());
        System.debug('--this.mapProducts-->'+this.mapProducts);
    }

    /**
     * Start method of batch to fetch all NR Product records
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('------this.query------>'+this.query);
        return Database.getQueryLocator(this.query);
    }

    /**
     * Execute method of batch to process on NR Product records and create
     * Deal or Deal Product records accordingly
     */
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        System.debug('--accountList-->'+accountList);
        List<Account> accountsWithInnerQuery =
            [
                SELECT 
                    Id, Name, Sales_Organization__c,Price_Book__c,Games_Digital__c, Video_Digital__c,
                    Games_Physical__c,Video_Physical__c, CurrencyIsoCode, OwnerId,Status__c, Owner_Games__c,Owner_Games__r.IsActive,Digital_Country_Code__c,
                    Music_Digital__c, Music_Physical__c, Storefront__c, // US JAPAN : 561
                    ( SELECT 
                        Id, RecordTypeId, Name, Start_Date__c, CloseDate, AccountID, Pricebook2ID,Market_Type__c,
                        StageName, Product_Type__c, NR_Deal_Unique_Key__c, CurrencyIsoCode,OwnerId,Account.OwnerId,Owner.IsActive,Account.Owner_Games__r.IsActive
                        FROM Opportunities WHERE NR_Deal_Unique_Key__c != null
                    ),
                    (
                        SELECT
                            Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, Country_Plan__r.RecordTypeId,//Country_Plan__r.NR_Product__r.SAP_Sales_Org__c,
                            // US274 : France Changes
                            Target_Quantity__c, // Country_Plan__r.Release_Type__c, 
                            PublishedTarget__c, Target_Revenue_Has_Changed__c, NR_Version__c,
                            Total_Target__c, Rental_Revenue_Per_Unit__c, Country_Plan__r.NR_Product__r.Product_Market__c, // US514 : Japan Modifications
                            //Japan - DEF#3926
                            Handling_Fee__c, Rental_Price__c , Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c , Final_Purchase__c,Decay_Curve_Template__c,
                            Customer__r.Sales_Organization__c, Customer__r.Digital_Country_Code__c,  Country_Plan__r.NR_Product__r.RecordTypeId,
                            Customer__r.Video_Digital__c, Customer__r.Games_Digital__c,
                            Customer__r.Music_Digital__c // US JAPAN : 561
                        FROM Account_Plans__r
                        WHERE Country_Plan__c != null AND Country_Plan__r.NR_Product__c != null
                        AND Country_Plan__r.NR_Product__r.RecordTypeId != null
                        AND Country_Plan__r.NR_Product__c IN: this.mapProducts.keySet()
                        AND (
                            (
                                Customer__r.Digital_Country_Code__c NOT IN: CRM_AppConstants.NR_WITH_BENELUX_LIKE_DIGITAL_COUNTRY_CODES
                            ) OR
                            (
                                (
                                    Customer__r.Digital_Country_Code__c IN: CRM_AppConstants.NR_WITH_BENELUX_LIKE_DIGITAL_COUNTRY_CODES
                                ) AND isTargetPresent__c = true
                            )
                        )
                        // AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c != null AND Country_Plan__r.NR_Product__r.RecordTypeId != null
                        /*
                        Commented Germany Code Changes
                        AND Customer__r.Sales_Organization__c !=: CRM_AppConstants.TERRITORY_GERMANY_CODE
                        //AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c !=: CRM_AppConstants.TERRITORY_GERMANY_CODE
                        AND Customer__r.Sales_Organization__c !=: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                        //AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c !=: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                        */
                        AND Customer__r.Digital_Country_Code__c NOT IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES
                        AND Country_Plan__r.RecordTypeId =: CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE
                        ORDER BY CreatedDate ASC
                    )
                    // Commented Germany Code Changes
                    ,
                    (
                        SELECT
                            Id, Account__c, Product__c, Target__c, Target_Units__c, Target_Revenue_Has_Changed__c, Product__r.RecordTypeId,
                            NR_Version__c, Account__r.Sales_Organization__c, Calc_End_Date__c,Calc_Start_Date__c, //, Product__r.SAP_Sales_Org__c
                            Account__r.Video_Digital__c, Account__r.Games_Digital__c, Account__r.Digital_Country_Code__c, Account_Plan_Lookup__c
                        FROM Targets__r WHERE Product__c != null AND (Target__c != null OR Target_Units__c != null)
                        AND (
                            Account__r.Digital_Country_Code__c IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES
                            /*(
                                Account__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_GERMANY_CODE
                                //AND Product__r.SAP_Sales_Org__c =: CRM_AppConstants.TERRITORY_GERMANY_CODE
                            )
                            OR
                            (
                                Account__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                                //AND Product__r.SAP_Sales_Org__c =: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                            )*/
                        )
                        ORDER BY LastModifiedDate DESC
                    )
                    FROM Account
                    WHERE
                        Id IN: accountList AND Price_Book__c != null
                        AND (Digital_Country_Code__c != null)
            ];
        System.debug('--accountsWithInnerQuery-->'+accountsWithInnerQuery);
        System.debug('--this.productList-->'+this.mapProducts.values());
        lstExceptions.addAll(CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            accountsWithInnerQuery,
            this.mapProducts.values(),
            //this.setProductAndAccountIdForTargets,
            this.mapIdToPBEPInstance,
            this.setProcessedProductIds
        ));
    }

    /**
     * Finish method of batch process.
     */
    global void finish(Database.BatchableContext BC) {

        // Process AccountPlan for Target, Product and PBEP flags to reset the values for successfully processed products
        processProductTargetAndPBEPFlags();
        // Send mail to logged in User for all the details of processed / non processed products
        sendMail(); 
    } 

    /**
     * @Description - Method to process Account Plan for Target, Product and PBEP flags to reset the values for successfully processed products
     * @name processProductTargetAndPBEPFlags
     */
    private void processProductTargetAndPBEPFlags() {
        List<Product2> updateProcessedProductList = new List<Product2>();
        List<Account_Plan__c> updateProcessedAccountPlanList = new List<Account_Plan__c>();
        List<Target__c> updateProcessedTargetList = new List<Target__c>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        //Map<Id, Decimal> mapAccountPlanIdToUpdatedNRVersion = new Map<Id, Decimal>();

        System.debug('-this.setProcessedProductIds-before-->'+this.setProcessedProductIds);
        for (CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException excp : this.lstExceptions) {
            if (excp.recordId != null && this.setProcessedProductIds.contains(excp.recordId)) {
                this.setProcessedProductIds.remove(excp.recordId);
            }
        }
        System.debug('-this.setProcessedProductIds-after-->'+this.setProcessedProductIds);

        /*for (Account_Plan__c accountPlanInstance : [
                SELECT
                    Id, NR_Version__c,
                    Target_Revenue_Has_Changed__c,
                    Country_Plan__r.NR_Product__c
                FROM
                    Account_Plan__c
                WHERE
                    Target_Revenue_Has_Changed__c = true
                    AND Country_Plan__c != null
                    AND Country_Plan__r.NR_Product__c IN: this.setProcessedProductIds
                    AND Customer__c != null
                    AND Customer__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                    AND Customer__r.Status__c =: CRM_AppConstants.ACCOUNT_STATUS_ACTIVE
                    AND
                    (
                        Customer__r.Games_Digital__c = true
                        OR Customer__r.Video_Digital__c = true
                        OR (Customer__r.Music_Digital__c = true AND Customer__r.Digital_Country_Code__c =: CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                    )
                    AND Customer__r.Sales_Organization__c NOT IN: CRM_AppConstants.GERMANY_SALES_ORGS
                    AND Customer__r.Games_Physical__c = false
                    AND Customer__r.Video_Physical__c = false
                    AND Customer__r.Music_Physical__c = false
                    AND Customer__r.Price_Book__c != null
                    LIMIT 10000
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
                    AND Product__c IN: this.setProcessedProductIds
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
                    LIMIT 10000
        ]) {
            mapAccountPlanIdToUpdatedNRVersion.put(targetInstance.Id, targetInstance.NR_Version__c);
        }

        System.debug('-mapAccountPlanIdToUpdatedNRVersion-->'+mapAccountPlanIdToUpdatedNRVersion);*/

        System.debug('--this.setProcessedProductIds-->'+this.setProcessedProductIds);
        for (Id productId : this.setProcessedProductIds) {
            System.debug('In finish'+setProcessedProductIds);
            if (this.mapProducts.containsKey(productId)) {
                Product2 productInstance = this.mapProducts.get(productId);
                System.debug('Unset product'+productInstance);
                System.debug('--productInstance.NR_Version__c-->'+productInstance.NR_Version__c);
                if (
                    (
                        productInstance.NR_Product_Created__c ||
                        productInstance.Street_Date_Has_Changed__c
                    )
                ) {
                    if (productInstance.NR_Product_Created__c) {
                        productInstance.NR_Product_Created__c = false;
                    }

                    if (productInstance.Street_Date_Has_Changed__c){
                        productInstance.Street_Date_Has_Changed__c = false;
                    }
                    updateProcessedProductList.add(productInstance);
                }
            }
        }
        listErrorLog.addAll(resetProcessedProductFlags(updateProcessedProductList, setProcessedProductIds));

        /*for (Id productId : this.setProcessedProductIds) {
            if (mapProductIdToAccountPlanList.containsKey(productId)) {
                for (Account_Plan__c accountPlanInstance : mapProductIdToAccountPlanList.get(productId)) {
                    System.debug('Unset target'+accountPlanInstance);
                    System.debug('mapAccountPlanIdToUpdatedNRVersion.get(target.Id)-->'+mapAccountPlanIdToUpdatedNRVersion.get(accountPlanInstance.Id));
                    System.debug('accountPlanInstance.NR_Version__c-->'+accountPlanInstance.NR_Version__c);
                    if (accountPlanInstance.Target_Revenue_Has_Changed__c && mapAccountPlanIdToUpdatedNRVersion.containsKey(accountPlanInstance.Id)) {
                        if (mapAccountPlanIdToUpdatedNRVersion.get(accountPlanInstance.Id) == accountPlanInstance.NR_Version__c) {
                            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
                            accountPlanInstance.NR_Version__c = 0;
                            updateProcessedAccountPlanList.add(accountPlanInstance);
                        }
                    }
                }
            }
            //Commented Germany Code Changes
            else if (mapProductIdToTargetList.containsKey(productId)) {
                for (Target__c targetInstance : mapProductIdToTargetList.get(productId)) {
                    System.debug('Unset target'+targetInstance);
                    System.debug('mapAccountPlanIdToUpdatedNRVersion.get(targetInstance.Id)-->'+mapAccountPlanIdToUpdatedNRVersion.get(targetInstance.Id));
                    System.debug('targetInstance.NR_Version__c-->'+targetInstance.NR_Version__c);
                    if (targetInstance.Target_Revenue_Has_Changed__c && mapAccountPlanIdToUpdatedNRVersion.containsKey(targetInstance.Id)) {
                        if (mapAccountPlanIdToUpdatedNRVersion.get(targetInstance.Id) == targetInstance.NR_Version__c) {
                            targetInstance.Target_Revenue_Has_Changed__c = false;
                            targetInstance.NR_Version__c = 0;
                            updateProcessedTargetList.add(targetInstance);
                        }
                    }
                }
            }
        }

        if (!updateProcessedAccountPlanList.isEmpty()) {
            listErrorLog.addAll(resetProcessedAccountPlanFlags(updateProcessedAccountPlanList, this.setProcessedProductIds));
        }

        if (!updateProcessedTargetList.isEmpty()) {
            listErrorLog.addAll(resetProcessedTargetFlags(updateProcessedTargetList, this.setProcessedProductIds));
        }*/

        List<Pricebook_Entry_Period__c> updatePricebookEntryPeriodList = new List<Pricebook_Entry_Period__c>();
        for (String key : mapIdToPBEPInstance.keySet()) {
            Pricebook_Entry_Period__c pbep = mapIdToPBEPInstance.get(key);
            if (pbep != null && this.setProcessedProductIds.contains(pbep.Product__c)) {
                if (pbep.Process_NR_Batch__c || pbep.Previous_Start_Date__c != null) {
                    if (pbep.Process_NR_Batch__c) {
                        pbep.Process_NR_Batch__c = false;
                    }
                    if(pbep.Previous_Start_Date__c != null){
                        pbep.Previous_Start_Date__c = null;
                    }
                    updatePricebookEntryPeriodList.add(pbep);
                }
            }
        }

        listErrorLog.addAll(resetProcessedPBEPFlags(updatePricebookEntryPeriodList));

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
    }

    /**
     * @Description - Method to reset the NR_Product_Created__c flag as the NR product is processed properly
     * @name resetProcessedProductFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedProductFlags(
            List<Product2> updateProcessedProductList,
            Set<Id> setProcessedProductIds
    ) {
        /*New__Debugs*/
        system.debug('Before Processing setProcessedProductIds' + setProcessedProductIds);
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedProductList.isEmpty()) {
            System.debug('--updateProcessedProductList-->'+updateProcessedProductList);
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedProductList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Product2 productInstance = updateProcessedProductList[i];
                System.debug('--productInstance-->'+productInstance);
                System.debug('--saveResultInstance.getId()-->'+saveResultInstance.getId());
                if (!saveResultInstance.isSuccess()) {
                    system.debug('In If Condition---Error-products-->');
                    setProcessedProductIds.remove(productInstance.Id);

                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    for(Database.Error err : saveResultInstance.getErrors()) {
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = productInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    this.lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
                            productInstance.Id,
                            lstErrors
                        )
                    );
                } else {
                    system.debug('In else Condition---Success-products-->');
                }
                 /*New__Debugs*/
                system.debug('After Processing setProcessedProductIds' + setProcessedProductIds);
            }
        }
        return listErrorLog;
    }

    /**
     * @Description - Method to reset the Target_Revenue_Has_Changed__c flag as the NR Product is processed properly for that Target
     * @name resetProcessedTargetFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedAccountPlanFlags(
            List<Account_Plan__c> updateProcessedAccountPlanList,
            Set<Id> setProcessedProductIds
    ) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedAccountPlanList.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedAccountPlanList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Account_Plan__c accountPlanInstance = updateProcessedAccountPlanList[i];
                if (!saveResultInstance.isSuccess()) {
                    system.debug('In else Condition---Error-Account Plan-->');
                    setProcessedProductIds.remove(accountPlanInstance.Country_Plan__r.NR_Product__c);

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
                    this.lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
                            accountPlanInstance.Country_Plan__r.NR_Product__c,
                            lstErrors
                        )
                    );
                } else {
                    system.debug('In else Condition---Success-Account Plan-->');
                }
            }
        }
        return listErrorLog;
    }*/

    /**
     * @Description - Method to reset the Target_Revenue_Has_Changed__c flag as the NR Product is processed properly for that Target
     * @name resetProcessedTargetFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedTargetFlags(
            List<Target__c> updateProcessedTargetList,
            Set<Id> setProcessedProductIds
    ) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedTargetList.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedTargetList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Target__c targetInstance = updateProcessedTargetList[i];
                if (!saveResultInstance.isSuccess()) {
                    setProcessedProductIds.remove(targetInstance.Product__c);

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
                    this.lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
                            targetInstance.Product__c,
                            lstErrors
                        )
                    );
                }
            }
        }
        return listErrorLog;
    }*/

    /**
     * @Description - Method to reset the Process NR Batch flag as the NR Product is processed properly for that PBEP
     * @name resetProcessedPBEPFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedPBEPFlags(List<Pricebook_Entry_Period__c> updateProcessedPBEPList) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedPBEPList.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedPBEPList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Pricebook_Entry_Period__c pbepInstance = updateProcessedPBEPList[i];
                if (!saveResultInstance.isSuccess()) {
                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    //lstErrors.add('Pricebook Entry Period Record with Id "'+ +'" not processed properly due to below reasons');
                    lstErrors.add(
                        String.format(
                            System.Label.CRM_PBEP_Not_Processed,
                            new String[] {
                                pbepInstance.Id
                            }
                        )
                    );
                    for (Database.Error err : saveResultInstance.getErrors()) {
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = pbepInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    this.lstExceptions.add(
                        new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(
                            pbepInstance.Product__c,
                            lstErrors
                        )
                    );
                }
            }
        }
        return listErrorLog;
    }

    /**
     * @Description - Method to send mail to logged in User for all the details of processed / non processed products
     * @name sendMail
     */
    private void sendMail() {

        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();

        /* Ankita: Commented the changes for Sending mail to CRM users only 
            sendTo.add(UserInfo.getUserEmail()); 
        */
        //Get emailIds from Custom setting
        sendTo = BatchStatusNotification.getBatchNotificationRecipients(CRM_AppConstants.Entity_CRM);
        if(!sendTo.isEmpty()) {
            mail.setToAddresses(sendTo);
        }

        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(System.Label.CRM_Digital_NR_Mail_Display_Name);

        // Step 4. Set email contents - you can use variables!
        mail.setSubject(System.Label.CRM_Digital_NR_Batch_Mail_Subject);

        String body = '';
        body = '<html>';
        body += '<body>';
        if(!this.lstExceptions.isEmpty()){
            body += '<table border = 1>';
            body += '<tr>';
            body += '<th>' + System.Label.CRM_NR_Batch_Products_Column_Name + '</th>';
            body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
            body += '</tr>';
            System.debug('---this.lstExceptions------>'+this.lstExceptions);
            for (CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException excp : this.lstExceptions) {
                System.debug('---excp------>'+excp);
                body += '<tr>';
                if(excp.recordId != null){
                    if (this.mapProducts.containsKey(excp.recordId) && this.mapProducts.get(excp.recordId).Name != null) {
                       body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + this.mapProducts.get(excp.recordId).Name + '</a></td>';
                    } else {
                        body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                    }
                }else{
                    body +='<td></td>';
                }
                /*for (String errorString :  excp.lstErrors) {
                    body += '<td>' + errorString + '</td>';
                }*/
                body += '<td>' + excp.lstErrors[0] + '</td>';
                body += '</tr>';
                if (excp.lstErrors.size() > 1) {
                   body += '<tr>';
                   for (Integer i = 1; i < excp.lstErrors.size(); i++) {
                        body += '<td>' + excp.lstErrors[i] + '</td>';
                   }
                   body += '</tr>';
                }
                
            }
            body += '<table>';
        } else {
            body +=System.Label.CRM_NR_Batch_Processed_Successfully_Message;
        }
        body += '</body>';
        body += '</html>';
        mail.setHtmlBody(body);

        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    /**
     * @Description - Method to fetch all New Release products that needs to be processed for automatic Deal creation
     * @name getNRProducts 
     * @return List<Product2> List of all NR products
     */
    @TestVisible
    private List<Product2> getNRProducts() {

        List<Id> targetProductIds = new List<Id>();
        List<Id> pbepProductIds = new List<Id>();

        CRM_Batch_Size__c targetBatchSizeInstance = CRM_Batch_Size__c.getInstance('Target Limit In Auto NR Batch');
        Integer defaultTargetLimit = targetBatchSizeInstance != null ? (Integer) targetBatchSizeInstance.Batch_Size__c : 10000;

        // Process on Account Plan records for Non-Germany Users
        for (Account_Plan__c accountPlanInstance : [
                SELECT
                    Id,
                    Customer__c,
                    Country_Plan__c,
                    Country_Plan__r.NR_Product__c,
                    Country_Plan__r.RecordTypeId,
                    PublishedTarget__c,
                    Target_Revenue_Has_Changed__c,
                    NR_Version__c,
                    Customer__r.Sales_Organization__c,
                    Customer__r.Digital_Country_Code__c,
                    //Country_Plan__r.NR_Product__r.SAP_Sales_Org__c,
                    // US274 : France Changes
                    Target_Quantity__c // , Country_Plan__r.Release_Type__c
                FROM
                    Account_Plan__c
                WHERE
                    Target_Revenue_Has_Changed__c = true
                    AND Customer__c != null
                    AND Country_Plan__c != null
                    //AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c != null
                    AND Country_Plan__r.NR_Product__c != null
                    AND Country_Plan__r.NR_Product__r.RecordTypeId != null
                    //AND PublishedTarget__c != null
                    AND (Customer__r.Digital_Country_Code__c != null)
                    AND Customer__r.Digital_Country_Code__c NOT IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES
                    /*
                    Commented Germany Code Changes
                    AND Customer__r.Sales_Organization__c !=: CRM_AppConstants.TERRITORY_GERMANY_CODE
                    //AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c !=: CRM_AppConstants.TERRITORY_GERMANY_CODE
                    AND Customer__r.Sales_Organization__c !=: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                    //AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c !=: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                    */
                    AND Country_Plan__r.RecordTypeId =: CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE
                    AND Customer__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                    AND (
                        Customer__r.Games_Digital__c = true OR
                        Customer__r.Video_Digital__c = true OR
                        (Customer__r.Music_Digital__c = true AND Customer__r.Digital_Country_Code__c =: CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                    )
                    AND Country_Plan__r.NR_Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                LIMIT :defaultTargetLimit
        ]) {
            targetProductIds.add(accountPlanInstance.Country_Plan__r.NR_Product__c);
            // Map used to reset the flags based on Products which are processed properly thats why Product should be as key
            /*if (this.mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
                 this.mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
            } else {
                this.mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
            }

            //if (accountPlanInstance.Customer__r.Sales_Organization__c == accountPlanInstance.Country_Plan__r.NR_Product__r.SAP_Sales_Org__c) {

            // For France, Target Quantity will be calculated from Account Plan.Target Quantity.
            // If its not specified then also Deal Products needs to be created with 0 value
            // For UK, Published Target should be present. If not present then deal Product will be created with target Quantity 1
            if (
                // US274 : France Changes
                CRM_AppConstants.FRANCE_SALES_ORGS.contains(accountPlanInstance.Customer__r.Sales_Organization__c) ||
                CRM_AppConstants.FRANCE_DIGITAL_COUNTRY_CODES.contains(accountPlanInstance.Customer__r.Digital_Country_Code__c) ||
                // US155 : UK & US352 : Germany Changes : Now applicable only for UK as Germany code removed
                (
                    !CRM_AppConstants.FRANCE_SALES_ORGS.contains(accountPlanInstance.Customer__r.Sales_Organization__c) &&
                    !CRM_AppConstants.FRANCE_DIGITAL_COUNTRY_CODES.contains(accountPlanInstance.Customer__r.Digital_Country_Code__c) &&
                    accountPlanInstance.PublishedTarget__c != null
                )
            ) {
                // Unique key used to distinguish whether Scenario 3 present for Product and Account being processed
                String uniqueKey = accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c;
                if (!this.setProductAndAccountIdForTargets.contains(uniqueKey)) {
                    this.setProductAndAccountIdForTargets.add(uniqueKey);
                }
            }
            //}*/
        }
        //System.debug('---this.mapProductIdToAccountPlanList----->'+this.mapProductIdToAccountPlanList);

        // Process on Target records for Germany Users
        // Commented Germany Code Changes
        for (Target__c targetInstance : [
                SELECT
                    Id, Account__c, Product__c,
                    Target__c, Target_Units__c, Target_Revenue_Has_Changed__c,
                    NR_Version__c,
                    Account__r.Sales_Organization__c,
                    Product__r.RecordTypeId,
                    Account_Plan_Lookup__c
                    //,Product__r.SAP_Sales_Org__c
                FROM
                    Target__c
                WHERE
                    Target_Revenue_Has_Changed__c = true
                    AND Account__c != null
                    AND Product__c != null
                    AND (Target__c != null OR Target_Units__c != null)
                    AND Account__r.Digital_Country_Code__c != null
                    //AND Product__r.SAP_Sales_Org__c != null
                    AND Account__r.Digital_Country_Code__c IN: CRM_AppConstants.NR_WITH_GERMANY_LIKE_DIGITAL_COUNTRY_CODES
                    /*AND 
                    (
                        (
                            Account__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_GERMANY_CODE
                            //AND Product__r.SAP_Sales_Org__c =: CRM_AppConstants.TERRITORY_GERMANY_CODE
                        )
                        OR
                        (
                            Account__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                            //AND Product__r.SAP_Sales_Org__c =: CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                        )
                    )*/
                    AND Account__r.RecordTypeId =: CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                    AND (Account__r.Games_Digital__c = true OR Account__r.Video_Digital__c = true)
                    AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                LIMIT :defaultTargetLimit
        ]) {
            targetProductIds.add(targetInstance.Product__c);
            // Map used to reset the flags based on Products which are processed properly thats why Product should be as key
            /*if (this.mapProductIdToTargetList.containsKey(targetInstance.Product__c)) {
                 this.mapProductIdToTargetList.get(targetInstance.Product__c).add(targetInstance);
            } else {
                this.mapProductIdToTargetList.put(targetInstance.Product__c, new List<Target__c>{targetInstance});
            }

            // Unique key used to distinguish whether Scenario 3 present for Product and Account being processed
            String uniqueKey = targetInstance.Product__c + '-' + targetInstance.Account__c;
            if (!this.setProductAndAccountIdForTargets.contains(uniqueKey)) {
                 this.setProductAndAccountIdForTargets.add(uniqueKey);
            }*/
        }
        System.debug('---this.mapProductIdToTargetList----->'+this.mapProductIdToTargetList);
        System.debug('-targetProductIds-->'+targetProductIds);

        List<Id> pbepProductIdsForScenario4 = new List<Id>();
        Date nowDay = System.Today();
        for (Pricebook_Entry_Period__c pbepInstance : [
                SELECT
                    Id, Product__c, Start_Date__c, Product__r.RecordTypeId,Previous_Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Price_Book__c, End_Date__c, List_Price__c, Account_Price__c,New_Release__c, CurrencyIsoCode, Process_NR_Batch__c,
                    Minimum_Price__c, Retail_Price__c , Material_Price_Group__c 
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                    AND Start_Date__c >=: nowDay
                    AND New_Release__c = true
                    AND isDuplicate__c = false
                    AND (Process_NR_Batch__c = true OR Product__c IN: targetProductIds)
                    ORDER BY Start_Date__c,CreatedDate, Product__c, Price_Book__c, CurrencyISOCode ASC
        ]) {
            pbepProductIds.add(pbepInstance.Product__c);
            String key = pbepInstance.Product__c + '-' + pbepInstance.Price_Book__c + '-' + pbepInstance.CurrencyISOCode;
            if (!this.mapIdToPBEPInstance.containsKey(key)) {
                this.mapIdToPBEPInstance.put(key, pbepInstance);
            }
            if (pbepInstance.Process_NR_Batch__c) {
                pbepProductIdsForScenario4.add(pbepInstance.Product__c);
            }
        }
        System.debug('-pbepProductIds-->'+pbepProductIds);

        // Process on product records whose Record Type = "Product", Type = "New Release",
        // StreeDate and Target Revenue has been updated
        String queryString =
            'SELECT ' +
                'Id, ' +
                'Name, '+
                'Type__c, ' +
                'Street_Date__c, ' +
                'Previous_Street_Date__c, ' +
                'CurrencyIsoCode, ' +
                'Exclusive_Customer__c, ' +
                'Street_Date_Has_Changed__c, '+
                'Product_Type__c, ' +
                'Product_Format__c, ' +
                'NR_Product_Created__c, '+
                'Product_Price_Group__c, '+
                'IsActive, '+
                'NR_Version__c, '+
                'RecordTypeId, '+
                'Product2.Product_Market__c '+
            'FROM ' +
                'Product2 ' +
            'WHERE ' +
                'RecordTypeId = \'' + CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL + '\'' +
                ' AND Type__c != null'+
                ' AND IsActive = true'+
                //' AND id = \'01t2D000001DXjN\''+
                ' AND Exclusive_Customer__c = null';
        if (!pbepProductIds.isEmpty() && pbepProductIds.size() > 0) {
            queryString += ' AND ( Id IN (\'' + String.join(pbepProductIds, '\',\'') + '\'))';
        }
           queryString += ' AND ('+
                                'NR_Product_Created__c = true' +
                            ' OR ' +
                                'Street_Date_Has_Changed__c = true';
        if (!targetProductIds.isEmpty() && targetProductIds.size() > 0) {
            queryString += ' OR ( Id IN (\'' + String.join(targetProductIds, '\',\'') + '\'))';
        }
        if (!pbepProductIdsForScenario4.isEmpty() && pbepProductIdsForScenario4.size() > 0) {
            queryString += ' OR ( Id IN (\'' + String.join(pbepProductIdsForScenario4, '\',\'') + '\'))';
        }

        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Product Limit In Auto NR Batch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 500;
        queryString += ') Order by CreatedDate DESC LIMIT ' + defaultBatchSize;
        System.debug('---queryString----->'+queryString);
        return Database.query(queryString);
    }
}