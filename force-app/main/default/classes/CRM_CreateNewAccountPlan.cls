/** 
 * Author: Anupama & Aditi Satpute
 * Description: Class used to perform logic for following functionality :
                1. Create / update Account Plan records based on Account Split Template added in Country Plan
                2. Update Account Plan Records with target Revenue Has Changed based on some fields updated on Country Plan
 * Date Created: 16th March 2016
 * Version: 1
 */
public without sharing Class CRM_CreateNewAccountPlan{

    //Map of Template Id vs the List of Account Splits
    public static Map <Id, List<Account_Split__c>> mapTargetSplitAccountSplit;
    //public static set <Id> targetSplitTemplateId = new set <Id>();
    //public static set<Id> countryPlanId = new set<Id>();
    public static List<Target_Split_Template__c> lsttagetSplttemplate = new List<Target_Split_Template__c>();
    public static List<Account_Plan__c> newAccountPlanList;
    //public static Map<String, Account_Plan__c> mapAccTSTvsAccPlan =new Map <String, Account_Plan__c>();
    
    //DEFECT : #3731    Set of ID of country plan from which account plan is to be deleted before creating new
    public static Set<Id> deleteAccPlanCountryPlanID = new Set<Id>();

    //Map to get the country plan in case the account plan insertion/updation fails
    public static Map<id, Country_Plan__c> mapCP = new Map<Id, Country_Plan__c>(); 

    /***
    Purpose    : Prepare the account Plan
    Parameters : Trigger.OldMap , Trigger.NewMap
    Return     : Void
    ***/
    public static void prepareAccountPlan(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans) {
        mapCP  = mapNewCountryPlans;  
        set<Id> countryPlanId = new set<Id>();  
        Set <Id> targetSplitTemplateId = new Set <Id>();
        for (Country_Plan__c newPlan : mapNewCountryPlans.values()) {
            // In case of update
            if (mapOldCountryPlans!=null && mapOldCountryPlans.containsKey(newPlan.id)){
                Country_Plan__c  oldPlan = mapOldCountryPlans.get(newPlan.Id);
                // Check if the template id has been changed
                if(oldPlan.Target_Split_Template__c!= newPlan.Target_Split_Template__c){
                    if (newPlan.Target_Split_Template__c != null) {
                        targetSplitTemplateId.add(newPlan.Target_Split_Template__c);
                        countryPlanId.add(newPlan.Id);
                    }
                    //#3731: On Change of Target Split Template, Country Plan Id is added to set
                    //DEF#3848
                    /*if (oldPlan.Target_Split_Template__c!=null) {
                        deleteAccPlanCountryPlanID.add(newPlan.Id);
                    }*/
                }
            } else {
                if (newPlan.Target_Split_Template__c != null) {
                    targetSplitTemplateId.add(newPlan.Target_Split_Template__c);
                    countryPlanId.add(newPlan.Id);
                }
            }
        }
        
        //#3731 : If any Template is changed
        /*if(deleteAccPlanCountryPlanID!=null && !deleteAccPlanCountryPlanID.isEmpty()){
            deleteAccountPlan(mapNewCountryPlans);
        }*/
        
        // If any Template is changed
        if (targetSplitTemplateId!=null && !targetSplitTemplateId.isEmpty()) {
            createAccountPlan(targetSplitTemplateId, countryPlanId);
        }
    }
    
    
    /*********************************************************************
    Purpose    : Delete the account Plan on Target Split Template Change
    Parameters : None
    Return     : Void
    DEFECT     : #3731
    ********************************************************************
    public static void deleteAccountPlan(Map<Id,Country_Plan__c> mapNewCountryPlans){
        List<Account_Plan__c> lstAccPlan = new List<Account_Plan__c>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<OpportunityLineItem> lstDealItems = new List<OpportunityLineItem>(); 
        List<Target__c> targetList = new List<Target__c>();
        Set<Id> CountryPlanIds = new Set<Id>();
        Set<Id> accountPlanIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Map<Id,List<Target__c>> mapAccountPlanIdToTargetList = new Map<Id,List<Target__c>>();
        
        lstAccPlan = [SELECT id,Country_Plan__r.Nr_Product__c,Customer__c 
                            FROM Account_Plan__c 
                            WHERE Country_Plan__c 
                            IN :deleteAccPlanCountryPlanID];
        //DEF#3848 Delete Target with no Deal Product on Target split Template change on Country Plan 
        //If Deal product exists then throw an error that cannot change the Target Split Template.
        //Fetch all targets with the Account Plan related to the Country Plan where Product is not null
        targetList = [SELECT id,Account__c,Product__c,Account_Plan_Lookup__c 
                            FROM Target__c 
                            WHERE Account_Plan_Lookup__c 
                            IN :lstAccPlan 
                            AND Product__c != null];
        //create a map for Account plan to list of Targets                  
        for(Target__c target : targetList){
            setAccountIds.add(target.Account__c);
            setProductIds.add(target.Product__c);
            if(mapAccountPlanIdToTargetList.containsKey(target.Account_Plan_Lookup__c)){
                mapAccountPlanIdToTargetList.get(target.Account_Plan_Lookup__c).add(target);
            }else{
                mapAccountPlanIdToTargetList.put(target.Account_Plan_Lookup__c,new List<Target__c>{target});
            }
        }
        //Fetch all the Deal Products which are present in Targets and for the related Accounts
        Set<id> dealProdIds =new Set<Id>();
        lstDealItems = [SELECT ID,Product2Id FROM OpportunityLineItem 
                                WHERE Product2Id IN :setProductIds 
                                AND Opportunity.AccountId IN :setAccountIds];
        for(OpportunityLineItem oppoLineItem : lstDealItems){
            dealProdIds.add(oppoLineItem.Product2Id);
        }
        
        targetList = new List<Target__c>();
        for(Account_Plan__c ap: lstAccPlan){
            if(ap.Country_Plan__c!= null && mapNewCountryPlans.containsKey(ap.Country_Plan__c)){
                Country_Plan__c countryPlan = mapNewCountryPlans.get(ap.Country_Plan__c);
                if(dealProdIds.contains(ap.Country_Plan__r.Nr_Product__c) && countryPlan.Country__c != CRM_AppConstants.FRANCE_COUNTRY){
                    //If Deal Product found for the Country Plan then throw an error.
                    mapNewCountryPlans.get(ap.Country_Plan__c).addError(System.Label.CRM_Cannot_Change_Target_Split_Template);
                }else{
                    //Else delete the account plans and targets
                    CountryPlanIds.add(ap.Country_Plan__c);
                    accountPlanIds.add(ap.Id);
                    if(mapAccountPlanIdToTargetList.containsKey(ap.Id)){
                        targetList.addAll(mapAccountPlanIdToTargetList.get(ap.Id));
                    }
                }
            }
        } 
        
        //Deleting Target associated with the accountPlan getting deleted.
        if(targetList!=null && !targetList.isEmpty()){
           delete targetList;
        }
        
        if(accountPlanIds!=null && !accountPlanIds.isEmpty()){ 
            List<Id> accPlanIds = new List<Id>();
            accPlanIds.addall(accountPlanIds);
            //Delete all the Existing Account Plan on the Country Plan
            Database.DeleteResult[] deleteResultList = Database.Delete(accPlanIds,false);
            for (Integer i = 0; i < deleteResultList.size(); i++) {
                Database.DeleteResult deleteResultInstance = deleteResultList[i];
                if (!deleteResultInstance.isSuccess()) {
                    for (Database.Error err : deleteResultInstance.getErrors()) {
                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DELETE_ACCOUNT_PLAN ;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                } 
            } 
        }//End of If 
        
        List<Country_Plan__c> lstCountryPlans = new List<Country_Plan__c>();        
        for(Country_Plan__c 
        cp: [SELECT Id,Approve_Deletion_of_All_Account_Plan__c FROM Country_Plan__c WHERE Id IN:CountryPlanIds]){
            cp.Approve_Deletion_of_All_Account_Plan__c = false;
            lstCountryPlans.add(cp);
        }
       update lstCountryPlans;
        //Error Logging
        if (!listErrorLog.isEmpty()) {
                CRM_ErrorLogger.logError(listErrorLog);
        }
        
    }//End of Function*/
   

    /*********************************************************************
    Purpose    : Delete account Plan / Target / Deal Product on Target Split Template Change
    Parameters : None
    Return     : Void
    REQ     : #628
    ********************************************************************/
    public static void deleteOldRecords(List<Country_Plan__c> lstCountryPlan, Map<String, Account_Plan__c> mapAccTSTvsAccPlan){
        Savepoint sp = Database.setSavepoint();
        try {
            if (mapAccTSTvsAccPlan != null && mapAccTSTvsAccPlan.size() > 0 && mapAccTSTvsAccPlan.values().size() > 0) {
                Map<String, Id> mapUniqueKeyToCountryPlanId = new Map<String, Id>();

                for (Account_Plan__c accPlan : mapAccTSTvsAccPlan.values()) {   
                    mapUniqueKeyToCountryPlanId.put(accPlan.Customer__c + '-' + accPlan.Country_Plan__r.NR_Product__c, accPlan.Country_Plan__c);
                }
  
                //Added this field in the SOQL query NR_Deal_Product_Unique_Key__c
                //Fetch all the Deal Products which are present in Targets and for the related Accounts
                List<OpportunityLineItem> lstDealItems =
                    [
                        SELECT ID,Product2Id, Opportunity.Bypass_Committed_Deals__c, Opportunity.StageName, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItem 
                        WHERE NR_Deal_Product_Unique_Key__c != null AND NR_Deal_Product_Unique_Key__c IN: mapUniqueKeyToCountryPlanId.keySet()
                    ];

                /*Map<Id, Opportunity> committedDealsMap = new Map<Id,Opportunity>();
                for (OpportunityLineItem oppLineItem : lstDealItems) {
                    if (oppLineItem.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                        if (!committedDealsMap.containsKey(oppLineItem.OpportunityId)) {
                            committedDealsMap.put(oppLineItem.OpportunityId, oppLineItem.Opportunity);
                        }
                    }
                }

                if(committedDealsMap.size() > 0){
                    for(Opportunity deal : committedDealsMap.values()) {
                        deal.Bypass_Committed_Deals__c = System.now();
                    }
                    update committedDealsMap.values();
                }*/
                List<CRM_Default_Configuration__c> lstCDCCS = [Select Id,ByPassValidation__c From CRM_Default_Configuration__c Limit 1];
          if(!lstCDCCS.isEmpty()){
              lstCDCCS[0].ByPassValidation__c = true;
              update lstCDCCS;
                }

                //delete lstDealItems;
                if (null != lstDealItems && !lstDealItems.isEmpty()) {
                    Database.DeleteResult[] result = Database.delete(lstDealItems, false);
                    List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                    for (Integer i=0; i < result.size(); i++ ) {
                        if (!result[i].isSuccess()) {
                            for (Database.Error err : result[i].getErrors()) {

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
                            if (!listErrorLog.isEmpty()) {
                                CRM_ErrorLogger.logError(listErrorLog);
                            }
                            Database.Error error = result.get(i).getErrors().get(0);
                            String failedDML = error.getMessage(); 
                            OpportunityLineItem oppLineItem = lstDealItems[i];
                            mapCP.get(mapUniqueKeyToCountryPlanId.get(oppLineItem.NR_Deal_Product_Unique_Key__c)).addError(
                                String.format(
                                    System.Label.CRM_Opportunity_Line_Item_Delete_Failure_Msg,
                                    new String[] {
                                        failedDML
                                    }
                                )
                            );
                        }
                    }
                }
   
                /*if(committedDealsMap.values().size() > 0){
                    for(Opportunity deal : committedDealsMap.values()) {
                        deal.Bypass_Committed_Deals__c = null;
                    }
                    update committedDealsMap.values();
                }*/
        
        if(!lstCDCCS.isEmpty()){
              lstCDCCS[0].ByPassValidation__c = false;
              update lstCDCCS;
                }

                //DEF#3848 Delete Target with no Deal Product on Target split Template change on Country Plan 
                //If Deal product exists then throw an error that cannot change the Target Split Template.
                //Fetch all targets with the Account Plan related to the Country Plan where Product is not null
                List<Target__c> targetList = [SELECT id,Account__c,Product__c,Account_Plan_Lookup__r.Country_Plan__c, Account_Plan_Lookup__c 
                            FROM Target__c 
                            WHERE Account_Plan_Lookup__c IN :mapAccTSTvsAccPlan.values()
                            // Defect#4622 - added below line to delete orphan targets for catalog and NR both earlier it was only for NR
                            AND (Product__c != null OR Product_Group__c != null)];
                            //AND Product__c != null];
                Map<Id, Id> mapTargetIdToCountryPlanId = new Map<Id, Id>();
                for (Target__c target : targetList) {
                    mapTargetIdToCountryPlanId.put(target.Id, target.Account_Plan_Lookup__r.Country_Plan__c);
                }

                // Deleting Target associated with the accountPlan getting deleted.
                if(targetList!=null && !targetList.isEmpty()){
                    List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                    Database.DeleteResult[] result = Database.delete(targetList, false);
                    for (Integer i=0; i < result.size(); i++ ) {
                        if (!result[i].isSuccess()) {
                            for (Database.Error err : result[i].getErrors()) {

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
                            if (!listErrorLog.isEmpty()) {
                                CRM_ErrorLogger.logError(listErrorLog);
                            }

                            Database.Error error = result.get(i).getErrors().get(0);
                            String failedDML = error.getMessage(); 
                            Target__c target = targetList[i];
                            mapCP.get(mapTargetIdToCountryPlanId.get(target.Id)).addError(
                                String.format(
                                    System.Label.CRM_Target_Delete_Failure_Msg,
                                    new String[] {
                                        failedDML
                                    }
                                )
                            );
                        }
                    }
                }
                // Deleting Account Plan associated with the accountPlan getting deleted.
                if(mapAccTSTvsAccPlan!=null && !mapAccTSTvsAccPlan.isEmpty()){ 
                    List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                    Database.DeleteResult[] result = Database.delete(mapAccTSTvsAccPlan.values(), false);
                    for (Integer i=0; i < result.size(); i++ ) {
                        if (!result[i].isSuccess()) {
                            for (Database.Error err : result[i].getErrors()) {

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
                            if (!listErrorLog.isEmpty()) {
                                CRM_ErrorLogger.logError(listErrorLog);
                            }

                            Database.Error error = result.get(i).getErrors().get(0);
                            String failedDML = error.getMessage(); 
                            Account_Plan__c accountPlan = mapAccTSTvsAccPlan.values()[i];
                            mapCP.get(accountPlan.Country_Plan__c).addError(
                                String.format(
                                    System.Label.CRM_Account_Plan_Delete_Failure_Msg,
                                    new String[] {
                                        failedDML
                                    }
                                )
                            );
                        }
                    }
                }//End of If 

                //update lstCountryPlans;
                for(Country_Plan__c cp: lstCountryPlan){
                    cp.Approve_Deletion_of_All_Account_Plan__c = false;
                }
                if (!lstCountryPlan.isEmpty()) {
                    List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                    Database.SaveResult[] result = Database.update(lstCountryPlan, false);
                    for (Integer i=0; i < result.size(); i++ ) {
                        if (!result[i].isSuccess()) {
                            for (Database.Error err : result[i].getErrors()) {

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
                            if (!listErrorLog.isEmpty()) {
                                CRM_ErrorLogger.logError(listErrorLog);
                            }

                            Database.Error error = result.get(i).getErrors().get(0);
                            String failedDML = error.getMessage(); 
                            Country_Plan__c countryPlan = lstCountryPlan[i];
                            mapCP.get(countryPlan.Id).addError(
                                String.format(
                                    System.Label.CRM_Country_Plan_Update_Failure_Msg,
                                    new String[] {
                                        failedDML
                                    }
                                )
                            );
                        }
                    }
                }
            }

            // Insert New / Update Account Plans
            if (!newAccountPlanList.isEmpty()) {
                List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                Database.UpsertResult[] result = Database.Upsert(newAccountPlanList,Account_Plan__c.Id, false);
                for (Integer i=0; i < result.size(); i++ ) {
                    if (!result[i].isSuccess()) {
                        for (Database.Error err : result[i].getErrors()) {

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        if (!listErrorLog.isEmpty()) {
                            CRM_ErrorLogger.logError(listErrorLog);
                        }

                        Database.Error error = result.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        mapCP.get(newAccountPlanList[i].Country_Plan__c).addError(
                            String.format(
                                System.Label.CRM_Account_Plan_Upsert_Failure_Msg,
                                new String[] {
                                    failedDML
                                }
                            )
                        );
                    }
                }
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CHANGE_TARGET_SPLIT_TEMPLATE;
            errorLog.lineNumber = String.valueOf(ex.getLineNumber());
            errorLog.errorMessage = ex.getMessage().left(200);
            errorLog.stackTrace = ex.getStackTraceString();

            // Call the logError method which will insert all errors into CRM_Error_Log__c object
            CRM_ErrorLogger.logError(errorLog);
            throw new CRM_CreateNewAccountPlanException (ex.getMessage());
        }
    }

    /***
    Purpose    : Insert the account Plan
    Parameters : None
    Return     : Void
    ***/
    public static void createAccountPlan(Set<Id> targetSplitTemplateId, set<Id> countryPlanId){
        System.debug('Inside the method createAccountPlan');
        String rentalRecordTypeAP = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL; //Schema.SObjectType.Account_Plan__c.getRecordTypeInfosByName().get('Rental').getRecordTypeId();
        String sellThroughRecordTypeAP = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH; //Schema.SObjectType.Account_Plan__c.getRecordTypeInfosByName().get('Sell Through').getRecordTypeId();
        system.debug('Rental RT==>>'+rentalRecordTypeAP +'Sell Through RT==>'+sellThroughRecordTypeAP );
        // Key of Map -- combination of Account id and Template id
        String strKey = '';
        Account_Plan__c acctPlan; 
        List <Country_Plan__c> lstCountryPlan = new List<Country_Plan__c>();
        Map<String, Account_Plan__c> mapAccTSTvsAccPlan =new Map <String, Account_Plan__c>();
        Map<Id,Account_Split__c> mapAccountIdToAccountSplits = new Map<Id,Account_Split__c>();
        
        // Prepare the Map of Template Id vs the List of account splits
        mapTargetSplitAccountSplit = new Map <Id, List<Account_Split__c>>(); 
        for (Account_Split__c accountSplit :[select id, Account__c, Share__c, Target_Split_Template__c,Target_Split_Template__r.Automatically_Split_to_Ship_To__c,Final_Purchase__c,
                                            Final_Purchase_Price__c,Handling_Fee__c,Number_of_Rentals_per_Unit__c,Rental_Price__c,
                                            Revenue_Share__c,Decay_Curve__c,CurrencyIsoCode,RecordType.name  //Tushar: Added fields in SOQL Japan#482
                                            from Account_Split__c where Target_Split_Template__c IN:targetSplitTemplateId]) {
            
            if (mapTargetSplitAccountSplit.containsKey(accountSplit.Target_Split_Template__c)){
                mapTargetSplitAccountSplit.get(accountSplit.Target_Split_Template__c).add(accountSplit);
            } else{
                mapTargetSplitAccountSplit.put(AccountSplit.Target_Split_Template__c,new List<Account_Split__c>{accountSplit});
            }
            
            //US:527 : Account split template change
            if(accountSplit.Target_Split_Template__r.Automatically_Split_to_Ship_To__c){
                mapAccountIdToAccountSplits.put(accountSplit.Account__c,accountSplit);
            }
        }
        
        //US:527 : Get All Shipt To Accounts related to Sold To 
        if(mapAccountIdToAccountSplits.size() > 0){
            for(Account acc : [Select Id,Account_Split_Share__c,RecordTypeId,Sold_To_Customer__c From Account Where Sold_To_Customer__c IN :mapAccountIdToAccountSplits.keySet() AND Account_Split_Share__c != null]){
                Account_Split__c soldToAccountSplit;
                if(mapAccountIdToAccountSplits.containsKey(acc.Sold_To_Customer__c)){
                    soldToAccountSplit = mapAccountIdToAccountSplits.get(acc.Sold_To_Customer__c);
                    populateTargetSplitAccountSplitMap(acc,soldToAccountSplit);
                }
            }
        }
        // Get the List of country plans and the account plans
        //Tushar: Added fields in SOQL Japan#482
        lstCountryPlan =[select id,Target_Split_Template__c,(select id,Customer__c, Country_Plan__c,Country_Plan__r.NR_Product__c, Country_Plan__r.Target_Split_Template__c,Share__c,
                         Final_Purchase__c, Final_Purchase_Price__c, Handling_Fee__c, Number_of_Rentals_per_Unit__c, Rental_Price__c,CurrencyIsoCode,
                         RecordTypeId,Revenue_Share__c,Decay_Curve_Template__c from Account_Plans__r) from Country_Plan__c where Id IN:countryPlanId];
        System.debug('countryPlanId --> '+countryPlanId);
        System.debug('lstCountryPlan size --> '+lstCountryPlan.size());
        // Prepare Map Key ==> Account+TST id and Value ==> Account Plan
        for (Country_Plan__c countryPlan:lstCountryPlan) {
            for (Account_Plan__c accPl: countryPlan.Account_Plans__r ) {
                strKey = String.valueOf(countryPlan.Id) + String.valueOf(accPl.Customer__c) + String.ValueOf(accPl.Country_Plan__r.Target_Split_Template__c);
                System.debug('strKey '+strKey);
                mapAccTSTvsAccPlan.put(strKey,accPl);
            }
        }
        newAccountPlanList = new List<Account_Plan__c>();   
        // Iterating through each country plan
        for (Country_Plan__c countryPlan:lstCountryPlan){
            if (mapTargetSplitAccountSplit.containsKey(countryPlan.Target_Split_Template__c)){
                // Iterate through the account splits
                for (Account_Split__c acctSplit : mapTargetSplitAccountSplit.get(countryPlan.Target_Split_Template__c)) {
                    // If Account plan already exists
                    //Currency Change Error for Country Plan
                    if (countryPlan.Account_Plans__r!= Null && !countryPlan.Account_Plans__r.isempty()) {
                        // If account plan matches for same account and template id
                        //Tushar: Added mapping in SOQL Japan#482
                        String strUniqueKey = String.valueOf(countryPlan.Id) + String.valueOf(acctSplit.Account__c) + String.valueOf(countryPlan.Target_Split_Template__c);
                        System.debug('strUniqueKey --> '+strUniqueKey);
                        if (mapAccTSTvsAccPlan.containsKey(strUniqueKey)) {
                            // Update the accPlan
                            acctPlan= mapAccTSTvsAccPlan.get(strUniqueKey);
                            acctPlan.share__c = acctSplit.Share__c;
                            acctPlan.Final_Purchase__c = acctSplit.Final_Purchase__c;
                            acctPlan.Handling_Fee__c = acctSplit.Handling_Fee__c;
                            acctPlan.Final_Purchase_Price__c = acctSplit.Final_Purchase_Price__c;
                            acctPlan.Number_of_Rentals_per_Unit__c = acctSplit.Number_of_Rentals_per_Unit__c;
                            acctPlan.Rental_Price__c = acctSplit.Rental_Price__c;
                            acctPlan.Revenue_Share__c = acctSplit.Revenue_Share__c;
                            acctPlan.Decay_Curve_Template__c = acctSplit.Decay_Curve__c;
                            acctPlan.CurrencyIsoCode = acctSplit.CurrencyIsoCode;
                            if(acctSplit.RecordType.Name == CRM_AppConstants.RENTAL_ACCOUNT_SPLIT){
                                    acctPlan.RecordTypeId = String.valueOf(rentalRecordTypeAP).substring(0, 15);
                            }else{
                            acctPlan.RecordTypeId = String.valueOf(sellThroughRecordTypeAP).substring(0, 15); 
                            } 
                            mapAccTSTvsAccPlan.remove(strUniqueKey);
                        }else{
                            // Create new account plan 
                            //Tushar: Added fields in SOQL Japan#482
                            acctPlan = new Account_Plan__c();
                            acctPlan.Country_Plan__c = countryPlan.Id;
                            acctPlan.Customer__c = acctSplit.Account__c;
                            acctPlan.Share__c = acctSplit.Share__c;
                            acctPlan.Final_Purchase__c = acctSplit.Final_Purchase__c;
                            acctPlan.Handling_Fee__c = acctSplit.Handling_Fee__c;
                            acctPlan.Final_Purchase_Price__c = acctSplit.Final_Purchase_Price__c;
                            acctPlan.Number_of_Rentals_per_Unit__c = acctSplit.Number_of_Rentals_per_Unit__c;
                            acctPlan.Rental_Price__c = acctSplit.Rental_Price__c;
                            acctPlan.Revenue_Share__c = acctSplit.Revenue_Share__c;
                            acctPlan.Decay_Curve_Template__c = acctSplit.Decay_Curve__c;
                            acctPlan.CurrencyIsoCode = acctSplit.CurrencyIsoCode;
                            if(acctSplit.RecordType.Name == CRM_AppConstants.RENTAL_ACCOUNT_SPLIT){
                                    acctPlan.RecordTypeId = String.valueOf(rentalRecordTypeAP).substring(0, 15);
                            }else{
                            acctPlan.RecordTypeId = String.valueOf(sellThroughRecordTypeAP).substring(0, 15); 
                            }  
                        }
                      } else {
                            acctPlan = new Account_Plan__c();
                            acctPlan.Country_Plan__c = countryPlan.Id;
                            acctPlan.Customer__c = acctSplit.Account__c;
                            acctPlan.Share__c = acctSplit.Share__c;
                            acctPlan.Final_Purchase__c = acctSplit.Final_Purchase__c;
                            acctPlan.Handling_Fee__c = acctSplit.Handling_Fee__c;
                            acctPlan.Final_Purchase_Price__c = acctSplit.Final_Purchase_Price__c;
                            acctPlan.Number_of_Rentals_per_Unit__c = acctSplit.Number_of_Rentals_per_Unit__c;
                            acctPlan.Rental_Price__c = acctSplit.Rental_Price__c;
                            acctPlan.Revenue_Share__c = acctSplit.Revenue_Share__c;
                            acctPlan.Decay_Curve_Template__c = acctSplit.Decay_Curve__c;
                            acctPlan.CurrencyIsoCode = acctSplit.CurrencyIsoCode;
                            if(acctSplit.RecordType.Name == CRM_AppConstants.RENTAL_ACCOUNT_SPLIT){
                                    acctPlan.RecordTypeId = String.valueOf(rentalRecordTypeAP).substring(0, 15);
                            }else{
                            acctPlan.RecordTypeId = String.valueOf(sellThroughRecordTypeAP).substring(0, 15); 
                            }  
                    } // End of Account plan already exists
                    newAccountPlanList.add(acctPlan);
                } // End of account split loop
            } // End of if
        } // Rnd of country plan loop

        // Delete the old Account Plans related records
        deleteOldRecords(lstCountryPlan, mapAccTSTvsAccPlan);

    } // End of method

    /**
     * @Description - 1. Method process all updated Country Plans and update corresponding Account Plan record's Target Revenue has changed
                      field only if Stretch_Target__c and Target_Quantity__c fields on Country Plan
                      are updated for Release Type Automatic and records linked to France Physical Products
                      2. This method is processed separately because if Split Template is changed then Account Plan Customer
                      could change and on that basis below functionality needs to be decided
     * @name updateAccountPlanToSetTargetRevenueHasChanged 
     * @param mapOldCountryPlans - Map of Country Plan records with old data
     * @param mapNewCountryPlans - Map of Country Plan records with new data
     * @return void
     */
    public static void updateAccountPlanToSetTargetRevenueHasChanged(
            Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans
    ) {
        System.debug('--mapNewCountryPlans.keySet()-->'+mapNewCountryPlans.keySet());
        List<Country_Plan__c> lstCountryPlan = [
            SELECT
                Id, RecordTypeId, RecordType.DeveloperName, NR_Product__c, NR_Product__r.RecordTypeId, NR_Product__r.Product_Type__c, // Release_Type__c,
                NR_Product__r.RecordType.DeveloperName, Stretch_Target__c, Target_Quantity__c,NR_Product__r.Exclusive_Customer__c,
                NR_Product__r.NR_Product_Created__c,Street_Date__c, NR_Product__r.Type__c, NR_Product__r.isActive,
                (
                    SELECT
                        Id, Customer__c, NR_Version__c, Country_Plan__c, Target_Quantity__c, Target_Revenue_Has_Changed__c, Customer__r.Digital_Country_Code__c,
                        Customer__r.Sales_Organization__c, Customer__r.RecordTypeId, Customer__r.Price_Book__c, Customer__r.Status__c,
                        Customer__r.Video_Digital__c, Customer__r.Video_Physical__c, Customer__r.Games_Physical__c, Customer__r.Games_Digital__c,
                        isValidAccountPlanForNR__c // US JAPAN : 561
                    FROM
                        Account_Plans__r
                    WHERE
                        Customer__c != null // AND Customer__r.Sales_Organization__c != null
                       // AND Customer__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_FRANCE_CODE
                )
            FROM Country_Plan__c
            WHERE
                Id IN: mapNewCountryPlans.keySet() AND RecordTypeId =: CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE
                AND NR_Product__c != null
                //AND NR_Product__r.SAP_Sales_Org__c != null AND NR_Product__r.SAP_Sales_Org__c =: CRM_AppConstants.TERRITORY_FRANCE_CODE
                //AND NR_Product__r.NR_Product_Created__c = false
        ];

        System.debug('--lstCountryPlan--->'+lstCountryPlan);
        List<Account_Plan__c> lstAccountPlanToUpdate = new List<Account_Plan__c>();
        for (Country_Plan__c countryPlanInstance : lstCountryPlan) {
            if (isValidCountryPlan(countryPlanInstance, mapOldCountryPlans, mapNewCountryPlans)) {
                for (Account_Plan__c accountPlanInstance : countryPlanInstance.Account_Plans__r) {
                    // if (isValidAccountPlan(countryPlanInstance, accountPlanInstance)) {
                    // US JAPAN : 561
                    if (accountPlanInstance.isValidAccountPlanForNR__c) {
                        // Here we update the NR Version and Target Revenue has changed fields. 'NR_Version__c' would be set back to '0' by the batch.
                        accountPlanInstance.Target_Revenue_Has_Changed__c = true;
                        accountPlanInstance.NR_Version__c = accountPlanInstance.NR_Version__c == null ? 0 : accountPlanInstance.NR_Version__c;
                        accountPlanInstance.NR_Version__c += 1;
                        lstAccountPlanToUpdate.add(accountPlanInstance);
                    }
                }
            }
        }

        System.debug('--lstAccountPlanToUpdate--->'+lstAccountPlanToUpdate);
        if (!lstAccountPlanToUpdate.isEmpty()) {
            List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
            Database.SaveResult[] saveResultList = Database.update(lstAccountPlanToUpdate, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                if (!saveResultInstance.isSuccess()) {

                    for (Database.Error err : saveResultInstance.getErrors()) {

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_UPDATE_ACCOUNT_PLAN;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                }
            }

            System.debug('--listErrorLog--->'+listErrorLog);
            // Inserts all errors into database
            if (!listErrorLog.isEmpty()) {
                CRM_ErrorLogger.logError(listErrorLog);
            }
        }
    }

    private static Boolean isValidCountryPlan(
            Country_Plan__c countryPlanInstance,
            Map<Id, Country_Plan__c> mapOldCountryPlans,
            Map<Id, Country_Plan__c> mapNewCountryPlans
    ) {
        Boolean isValidCP = false;
        Date conditionApplicableDate = Date.newInstance(2016, 10, 01);
        if (
            !mapOldCountryPlans.isEmpty() && mapOldCountryPlans.containsKey(countryPlanInstance.Id) &&
            mapOldCountryPlans.get(countryPlanInstance.Id) != null && 
            !mapNewCountryPlans.isEmpty() && mapNewCountryPlans.containsKey(countryPlanInstance.Id) &&
            mapNewCountryPlans.get(countryPlanInstance.Id) != null && 
            (
                mapNewCountryPlans.get(countryPlanInstance.Id).Target_Revenue__c != mapOldCountryPlans.get(countryPlanInstance.Id).Target_Revenue__c ||
                mapNewCountryPlans.get(countryPlanInstance.Id).Target_Quantity__c != mapOldCountryPlans.get(countryPlanInstance.Id).Target_Quantity__c ||
                mapNewCountryPlans.get(countryPlanInstance.Id).Stretch_Target__c != mapOldCountryPlans.get(countryPlanInstance.Id).Stretch_Target__c
            ) &&
            //countryPlanInstance.NR_Product__r.SAP_Sales_Org__c != null &&
            //countryPlanInstance.NR_Product__r.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE &&
            countryPlanInstance.NR_Product__r.isActive == true &&
            countryPlanInstance.NR_Product__r.Exclusive_Customer__c == null &&
            countryPlanInstance.NR_Product__r.NR_Product_Created__c == false && 
            (
                countryPlanInstance.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL ||
                (
                    countryPlanInstance.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                    countryPlanInstance.Street_Date__c >= conditionApplicableDate &&
                    countryPlanInstance.Street_Date__c > System.Today() &&
                    countryPlanInstance.NR_Product__r.Product_Type__c == CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE
                )
            )
        ) {
            isValidCP = true;
            System.debug('--isValidCP->');
        }
        return isValidCP;
    }

    /**
     * @US:527
     * @Description - Method to populate mapTargetSplitAccountSplit Map 
     * @name populateTargetSplitAccountSplitMap 
     * @param acc - Account instance
     * @param acctSplit - Account_Split__c instance
     * @return void
     */
    private static void populateTargetSplitAccountSplitMap(Account acc,Account_Split__c soldToAccSplit){
        
        Account_Split__c shipToAccSplit = createAccountSplit(acc,soldToAccSplit);
        
        if (mapTargetSplitAccountSplit.containsKey(soldToAccSplit.Target_Split_Template__c)){
            mapTargetSplitAccountSplit.get(soldToAccSplit.Target_Split_Template__c).add(shipToAccSplit);
        } else{
            mapTargetSplitAccountSplit.put(soldToAccSplit.Target_Split_Template__c,new List<Account_Split__c>{shipToAccSplit});
        }
    }
    
    /**
     * @US:527
     * @Description - Method to Create Account Split Instance
     * @name createAccountSplit 
     * @param acc - Account instance
     * @param acctSplit - Account_Split__c instance
     * @return Account_Split__c
     */
    private static Account_Split__c createAccountSplit(Account acc,Account_Split__c soldToAccSplit){
        Account_Split__c accSplit = new Account_Split__c();
        accSplit.share__c = (acc.Account_Split_Share__c*(soldToAccSplit.Share__c != null ? soldToAccSplit.Share__c : 0))/100;
        accSplit.Account__c = acc.Id;
        accSplit.Final_Purchase__c = soldToAccSplit.Final_Purchase__c;
        accSplit.Handling_Fee__c = soldToAccSplit.Handling_Fee__c;
        accSplit.Final_Purchase_Price__c = soldToAccSplit.Final_Purchase_Price__c;
        accSplit.Number_of_Rentals_per_Unit__c = soldToAccSplit.Number_of_Rentals_per_Unit__c;
        accSplit.Rental_Price__c = soldToAccSplit.Rental_Price__c;
        accSplit.Revenue_Share__c = soldToAccSplit.Revenue_Share__c;
        accSplit.Decay_Curve__c = soldToAccSplit.Decay_Curve__c;
        accSplit.CurrencyIsoCode = soldToAccSplit.CurrencyIsoCode;
        if(soldToAccSplit.RecordType.Name != null) {
            accSplit.RecordType = new RecordType();  
            accSplit.RecordType.Name = soldToAccSplit.RecordType.Name;
        }
        return accSplit;
    }
    
    /***
    Purpose    : Requirement#479 : Update (Is NR Product ? = TRUE,Product Price Group = NR) Linked NR Product fields
    Parameters : Trigger.OldMap , Trigger.NewMap
    Return     : Void
    **
    public static void updateNRProductFields(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans){
        Set<Id> setProductIds = new Set<Id>();
        List<Product2> lstPoroductToUpdate = new List<Product2>();
        
        Date todayDate = System.Today();
        for(Country_Plan__c cp : mapNewCountryPlans.values()){
            if(cp.RecordTypeId == CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE && cp.NR_Product__c != null && cp.Country__c == CRM_AppConstants.FRANCE_COUNTRY){
                setProductIds.add(cp.NR_Product__c);
            }
        }
        if(!setProductIds.isEmpty()){
            for(Product2 prod : [Select Id,Is_NR_Product__c,Release_Category__c,Product_Price_Group__c,NR_Product_Created__c,Street_Date__c
                                 From Product2 
                                 Where Id IN :setProductIds AND Street_Date__c > :todayDate]){
                    prod.Is_NR_Product__c = true;
                    //prod.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
                    //prod.Product_Price_Group__c  = CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE;
                    lstPoroductToUpdate.add(prod);
            }
            
            if(!lstPoroductToUpdate.isEmpty()){
                update lstPoroductToUpdate;
            }
        }
    }*/
    
    /*private static Boolean isValidAccountPlan(Country_Plan__c countryPlanInstance, Account_Plan__c accountPlanInstance) {
        Boolean isValidAP = false;
        if (
                accountPlanInstance.Customer__r.Price_Book__c != null &&
                (
                    (
                        countryPlanInstance.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                        accountPlanInstance.Customer__r.Sales_Organization__c != null &&
                        (
                            CRM_AppConstants.FRANCE_WITHOUT_BENELUX_SALES_ORGS.contains(accountPlanInstance.Customer__r.Sales_Organization__c)
                        )
                    ) ||
                    (
                        countryPlanInstance.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                        accountPlanInstance.Customer__r.Digital_Country_Code__c != null &&
                        CRM_AppConstants.FRANCE_WITHOUT_BENELUX_DIGITAL_COUNTRY_CODES.contains(accountPlanInstance.Customer__r.Digital_Country_Code__c)
                    )
                ) &&
                (
                    (
                        countryPlanInstance.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                        accountPlanInstance.Customer__r.Status__c == CRM_AppConstants.ACCOUNT_STATUS_ACTIVE &&
                        accountPlanInstance.Customer__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO &&
                        (
                            (
                                accountPlanInstance.Customer__r.Video_Digital__c == true &&
                                countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE
                            ) ||
                            (
                                accountPlanInstance.Customer__r.Games_Digital__c == true &&
                                countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE
                            )
                        ) &&
                        accountPlanInstance.Customer__r.Video_Physical__c == false &&
                        accountPlanInstance.Customer__r.Games_Physical__c == false
                    ) ||
                    (
                        countryPlanInstance.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL &&
                        (
                            (
                                !CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(accountPlanInstance.Customer__r.Sales_Organization__c) &&
                                accountPlanInstance.Customer__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                            ) ||
                            (
                                CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(accountPlanInstance.Customer__r.Sales_Organization__c) &&
                                (
                                    accountPlanInstance.Customer__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO ||
                                    accountPlanInstance.Customer__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO
                                )
                            )
                        ) &&
                        (
                            accountPlanInstance.Customer__r.Status__c == CRM_AppConstants.ACCOUNT_STATUS_ACTIVE || 
                            accountPlanInstance.Customer__r.Status__c == CRM_AppConstants.ACCOUNT_STATUS_BLOCKED 
                        ) &&
                        (
                            (
                                accountPlanInstance.Customer__r.Video_Physical__c == true &&
                                countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE
                            ) ||
                            (
                                accountPlanInstance.Customer__r.Games_Physical__c == true &&
                                countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE
                            )
                        ) &&
                        accountPlanInstance.Customer__r.Video_Digital__c == false &&
                        accountPlanInstance.Customer__r.Games_Digital__c == false
                    )
                )
        ) {
            isValidAP = true;
            system.debug('IsvalidAP-->'+isValidAP);
        }
        return isValidAP;
    }*/

    public class CRM_CreateNewAccountPlanException extends Exception {
    }
}