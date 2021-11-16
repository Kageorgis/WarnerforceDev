/**
   @Author-Cognizant Technology Solutions
   @name-CRM_DealHandler
   @CreateDate- 14 Mar 2016
   @Description-
   @Version-1.0
   @reference-None
*/

// Added without sharing so that user can follow the records for others as well without giving Modify All permission
public without sharing class CRM_DealHandler {
    // static User currentUser = [select Id, Name from User where Id =: Userinfo.getUserId()];
    public static Boolean isFirstRun = true;
    /**
    *  @Description - Method to add deal owner as record follower every time when 1) a new deal is created 2) Deal owner is changed
    *  @name - autoCreateRecordFollower
    *  @return - void
    */
    public static void autoCreateRecordFollower(Map<Id,Opportunity> mapOldDeals, Opportunity[] newDeals) {
        Map<Id,Id> mapDealOwnerIds = new Map<Id,Id>();
        // Create a map of chatter record subscriptions
        Map<String,EntitySubscription> mapDealSubscription = new Map<String,EntitySubscription>();
        
        // iterate over each new deal record and check if the owner is changed 
        for(Opportunity deal : newDeals) {
            if( deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE && 
            (trigger.isInsert || (trigger.isUpdate && deal.OwnerId != mapOldDeals.get(deal.Id).OwnerId))) {
                mapDealOwnerIds.put(deal.Id, deal.OwnerId);
                mapDealSubscription.put(deal.Id +'-'+ deal.OwnerId, new EntitySubscription(ParentId=deal.Id, SubscriberId=deal.OwnerId));
            }
        }
        
        if(!mapDealOwnerIds.isEmpty()) {
            // Fetch the existing subscriptions and 
            // Added Limit to query to avoid the error "EntitySubscription only allows security evaluation for non-admin users when LIMIT is specified and at most 1000"
            // See the link "https://help.salesforce.com/apex/HTViewSolution?id=000181365&language=en_US" for more details
            for(EntitySubscription subscription : [select id, ParentId, SubscriberId
                                from EntitySubscription
                                where SubscriberId IN:mapDealOwnerIds.values() and ParentId IN: mapDealOwnerIds.keySet()
                                limit 1000]) {
                
                String subsKey = subscription.ParentId + '-' + subscription.SubscriberId;
                
                if(mapDealSubscription.containsKey(subsKey)) {
                    mapDealSubscription.put(subsKey, subscription);
                }
            }
        }
        // Upsert the subscriptions
        if(!mapDealSubscription.isEmpty()) {
            List<EntitySubscription> newsubscriptions = new List<EntitySubscription>();
            
            for(EntitySubscription subscription : newsubscriptions) {
                if(subscription.Id == null) {
                    newsubscriptions.add(subscription);
                }
            }
            
            if(!newsubscriptions.isEmpty()) {
                Database.insert(newsubscriptions, false);
            }
        }
    }
    
    /**
    *  @Description - Method to check scheduleRevenueChanged flag on linked Account when Stage or Amount change or New Deal created
    *  @name - checkScheduleRevenueChangedFlagOnAccount
    *  @return - void
    */
    public static void checkScheduleRevenueChangedFlagOnAccount(Set<Id> setOfAccountIds){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<Account> lstAccounts = new List<Account>();
        lstAccounts = [SELECT Id,scheduleRevenueChanged__c FROM Account WHERE Id IN :setOfAccountIds AND scheduleRevenueChanged__c = false];
        for(Account acc : lstAccounts){
            acc.scheduleRevenueChanged__c = true;
        }
        
        if(!lstAccounts.isEmpty()){
            Database.SaveResult[] result = Database.Update(lstAccounts, false);
            for(Integer i=0; i < result.size(); i++ ){
                if(!result[i].isSuccess()){
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = CRM_DealHandler.logAnException(result[i].getErrors(),result[i].getId(),'CRM_DealHandler','CRM_DealHandler');
                    listErrorLog.addAll(errorLogInstanceList);
                }
            }
            
            if(!listErrorLog.isEmpty())
                CRM_ErrorLogger.logError(listErrorLog); 
        }
            
    }
    
    /**
    *  @Description - Method to clear the deal code if deal is cloned OR Deal_Code manually populated by user
    *               this will help workflow rule "CRM - Update Deal Code on Deal" to copy AutoNumber in deal code when Deal code is blank
    *  @name - clearDealCode
    *  @return - void
    */
    public void clearDealCode(Opportunity[] newDeals) {
        CRM_Default_Configuration__c defConfig = CRM_Default_Configuration__c.getOrgDefaults();
        if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 ) {
            User currentUser = CRM_ApplicationUtility.runningUser[0];
            Boolean isInformaticaUser = (defConfig != null && ((Id) defConfig.Informatica_User_Id__c) == currentUser.Id);
            Boolean isDataMigrationUser =  (currentUser.Name.equalsIgnoreCase('Siebel Data Migration'));

            for (Opportunity deal : newDeals) {

                // update deal code for all the deal expect deal coming from informatica/Siebel with deal code. 
                if (!( (isInformaticaUser || isDataMigrationUser) && deal.Deal_Code__c != null)) {
                    // Blank out the Deal_Code__c so that workflow can update it with Auto_Number__c 
                    deal.Deal_Code__c = null;
                    deal.Sent_To_SAP__c = null; // defect 3238
                }
            }
        }
    }

    /**
    *  @Description - this method will do the following (in case of Before Insert/Update for Physical POS/Physical DFI Deal only):
    *               1.  Validate the Pricebook selected against the Deal
    *                   a.  2500 Sales Org for WBIE - US/WB Non-IP - US Pricebooks
    *                   b.  2403 Sales Org for WBIE - CAN/WB Non-IP - CA Pricebooks
    *               2.  Set the Deal Currency Code based on the selected Account's currency code
    *               3.  For Committed Deals, if there exists a SAP Deal value, set Admin Status to Complete
    *               4.  If an Account is selected on Deal which contains Video Physical as false, show error on UI
    *  @name - beforeInsertUpdatePhysicalPOSDFIDeal
    *  @return - void
    */
    public void beforeInsertUpdatePhysicalPOSDFIDeal(Set<Id> accountIdSet, Set<Id> pricebookIdSet, List<Opportunity> newDealList) {
        Map<Id, String> accountSalesOrgMap = new Map<Id, String>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, String> pricebookMap = new Map<Id, String>();
        Map<String, String> accountSalesOrgPBMap = new Map<String, String>();
        
        for(Account acc : [select Id, Sales_Organization__c, CurrencyIsoCode, Video_Physical__c from Account where Id IN :accountIdSet]){
            accountSalesOrgMap.put(acc.Id, acc.Sales_Organization__c);
            accountMap.put(acc.Id, acc);
        }
        
        for(Pricebook2 pb : [select Id, Name from Pricebook2 WHERE Id IN: pricebookIdSet]){
            pricebookMap.put(pb.Id, pb.Name);
        }
        
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        for(Physical_POS_DFI_Deal_Pricebook_Entry__mdt cmeta : [Select Id, Account_Sales_Org__c, Pricebook_Name__c, Is_Active__c 
                                                                FROM Physical_POS_DFI_Deal_Pricebook_Entry__mdt
                                                                WHERE Is_Active__c = true AND Account_Sales_Org__c IN: accountSalesOrgMap.values()]){
                                                                    accountSalesOrgPBMap.put(cmeta.Pricebook_Name__c, cmeta.Account_Sales_Org__c);
                                                                }
        
        for(Opportunity deal : newDealList){
            Boolean error = accountSalesOrgPBMap.get(pricebookMap.get(deal.Pricebook2Id)) == accountSalesOrgMap.get(deal.AccountId)?false:true;
            if(error){
               if(accountSalesOrgMap.get(deal.AccountId) == CRM_AppConstants.TERRITORY_SDS_US_CODE || 
                  accountSalesOrgMap.get(deal.AccountId) ==CRM_AppConstants.TERRITORY_SDS_CANADA_CODE){
                  deal.addError(Label.CRM_Deal_SDS_Pricebook_Selection_Validation_Msg);
               }
                else
                {
                     deal.addError(Label.CRM_Deal_Pricebook_Selection_Validation_Msg);
                }
               
            }
            deal.CurrencyIsoCode = accountMap.get(deal.AccountId).CurrencyIsoCode;
            
            if(profileName!=CRM_AppConstants.SALES_ADMIN_PROFILE_NAME && (deal.StageName==CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || (deal.SAP_Deal__c!=null && deal.StageName==CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED)) ){
                //--ER-007269 - check isJVDealCloneBatch static value and skip to update admin status in cloneing deal on orginal deal--//
                if(!CRM_ApplicationUtility.isJVDealCloneBatch){
                    deal.SAP_DFI_Deal_Error_Msg__c=null;
                    deal.Admin_Status__c = CRM_AppConstants.DEAL_ADMIN_STATUS_SENT_TO_SAP;
                    deal.Sent_To_SAP__c=null;
                }
            }
            if(!accountMap.get(deal.AccountId).Video_Physical__c){
                deal.addError(Label.CRM_Wrong_Account_Selected);
            }
        }
    }
   
    /**
     *  @Description - The method updates Deal Product if it is invalid and when it deal is committed
     *  @name - updateDealProducts
     *  @return - returns void
     */
    public void updateDealProducts(Map<Id,Opportunity> oldDealMap,Map<Id,Opportunity> newDealMap) {
        list<OpportunityLineItem> updateDealProductsList = new list<OpportunityLineItem>();
        Map<Id,OpportunityLineItem> mapOfOPDealProducts = new Map<Id,OpportunityLineItem>();
        Set<Id> dealIDs = new Set<Id>();
        Set<Id> setOfOPDealIds = new Set<Id>();
        
        //Set of Account Id to Update flag scheduleRevenueChanged
        Set<Id> setOfAccountIds = new Set<Id>();
        
        // Set<Id> committedDealIDs = new Set<Id>();
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        try {   
                // if Deal Start Date or Close Date is changed
                for (Opportunity deal : newDealMap.values()) {
                    /*if (
                            oldDealMap.get(deal.id).StageName != newDealMap.get(deal.id).StageName &&
                            (deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED ||
                            deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED) 
                    ) {
                        committedDealIDs.add(deal.id);
                    } else */
                    if (
                            oldDealMap.get(deal.id).Start_Date__c != newDealMap.get(deal.id).Start_Date__c || 
                            oldDealMap.get(deal.id).CloseDate != newDealMap.get(deal.id).CloseDate
                    ) {
                        dealIDs.add(deal.id);
                    }
          //Fill Set with AccountIds of deals whose stage is changed
          if(oldDealMap != null && deal.StageName != oldDealMap.get(deal.Id).StageName && 
                  (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL)){
                    setOfAccountIds.add(deal.AccountId);
                }
                
                    //US#612 (Japan) : Update Override Pricing Checkbox on Deal Products if Deal override checkbox is checked
                    if(deal.Override_Pricing__c && deal.Override_Pricing__c != oldDealMap.get(deal.Id).Override_Pricing__c &&
                       deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
                        setOfOPDealIds.add(deal.Id);
                    }
                }

        //Check Account scheduleRevenueChanged Flag 
            if(!setOfAccountIds.isEmpty())
                checkScheduleRevenueChangedFlagOnAccount(setOfAccountIds);
          
                System.debug('--dealIDs-->'+dealIDs);
                if ((dealIDs != null && dealIDs.size() > 0) || (!setOfOPDealIds.isEmpty())) {
                    // For applicable deals, find deal products and prepare dealWrapper List
                    for(OpportunityLineItem dealProduct: [select id, ListPrice__c, Account_Price__c,Customer_Retail_Price__c,Minimum_Price__c,Invalid_Deal_Product__c,Pricebook_Entry_Period__r.Start_Date__c,
                                                     Pricebook_Entry_Period__r.List_Price__c, Opportunity.Start_Date__c, Opportunity.CloseDate, Pricebook_Entry_Period__c,//Suggested_Price__c,Pricebook_Entry_Period__r.Suggested_Price__c, -//US#895 -commneted code as a part of us to remove reference of suggested price
                                                     Pricebook_Entry_Period__r.Retail_Price__c, Pricebook_Entry_Period__r.Account_Price__c, Pricebook_Entry_Period__r.Minimum_Price__c,
                                                     OpportunityId, Product2Id, Opportunity.StageName, Override_Pricing__c
                                                     from OpportunityLineItem
                                                     where (OpportunityId IN: dealIDs OR OpportunityId IN: setOfOPDealIds) limit 10000]
                    ) {
                        if(setOfOPDealIds.contains(dealProduct.OpportunityId) && !dealProduct.Override_Pricing__c){
                            dealProduct.Override_Pricing__c = true;
                            mapOfOPDealProducts.put(dealProduct.Id,dealProduct);
                        }
                        //--Added for JV sales org to skip execution for updating invalid deal product flag--//
                        if(dealIDs.contains(dealProduct.OpportunityId) && 
                                !(newDealMap.get(dealProduct.OpportunityId).Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE ||
                                newDealMap.get(dealProduct.OpportunityId).Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
                            CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
                            dw.dealId = dealProduct.OpportunityId;
                            dw.accountId = newDealMap.get(dealProduct.OpportunityId).AccountId;
                            dw.dealCurrency = newDealMap.get(dealProduct.OpportunityId).CurrencyISOCode;
                            dw.productId = dealProduct.Product2Id;
                            dw.pricebookId = newDealMap.get(dealProduct.OpportunityId).Pricebook2Id;
                            dw.dealStartDate = newDealMap.get(dealProduct.OpportunityId).Start_Date__c;
                            dw.dealEndDate = newDealMap.get(dealProduct.OpportunityId).CloseDate;
                            dw.dealProduct = dealProduct;
                            dw.dealRecordTypeId = newDealMap.get(dealProduct.OpportunityId).RecordTypeId;
                            listDealWrappers.add(dw);
                        }
                    }
                }

                //--CPU Time Limit--added isbatch and isPublishAssortmentDealsBatch variable condition--RTC--//
                system.debug('@@isPublishAssortmentDealsBatch-->'+System.isBatch()+'-'+CRM_ApplicationUtility.isPublishAssortmentDealsBatch);
                if(!(System.isBatch() && CRM_ApplicationUtility.isPublishAssortmentDealsBatch)){
                    if (!listDealWrappers.isEmpty()) {
                        CRM_ProductPricingHandler instance = new CRM_ProductPricingHandler(listDealWrappers);
    
                        // Verify the deal product contains valid PBEP and set invalidDealProduct flag accordingly
                        for (CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers) {
                            Pricebook_Entry_Period__c pbep = instance.getProductDatedPricebookEntryPeriod(dw);
                            if (pbep != null) {
                                if (dw.dealProduct.Pricebook_Entry_Period__c != pbep.Id) {
                                    // If already not set then set the flag as conditions are true    
                                    if (!dw.dealProduct.Invalid_Deal_Product__c) {
                                        dw.dealProduct.Invalid_Deal_Product__c = true;
                                        mapOfOPDealProducts.put(dw.dealProduct.Id,dw.dealProduct);    
                                    }
                                } else {
                                    // If conditions are not true and flag is set then make it false
                                    if(dw.dealProduct.Invalid_Deal_Product__c) {
                                        dw.dealProduct.Invalid_Deal_Product__c = false;
                                        mapOfOPDealProducts.put(dw.dealProduct.Id,dw.dealProduct);     
                                    }   
                                }
                            
                            } else {
                                if (!dw.dealProduct.Invalid_Deal_Product__c) {
                                    dw.dealProduct.Invalid_Deal_Product__c = true;
                                    mapOfOPDealProducts.put(dw.dealProduct.Id,dw.dealProduct);  
                                }
                            }
                        }
                    }
                }

                if (mapOfOPDealProducts.size() > 0) {
                    update mapOfOPDealProducts.values();
                }
        } catch(Exception  e) {
            logAnException(e, null);
        }
    }
    
    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public void logAnException(Exception ex, Id recordId){
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null)
            errorLogInstance.recordId = recordId;
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLogInstance.functionalModule = 'CRM_DealHandler';
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();

        // Call the logError method which will insert all errors into CRM_Error_Log__c object
        CRM_ErrorLogger.logError(errorLogInstance);     
    }
    
    /**
    *  @Description - Method to Stop user from Deleting Deal once it is sent to SAP         
    *  @name - deleteDealError
    *  @return 
    */
    public void deleteDealError(Map<Id, Opportunity> mapOldDeals){
    
        String errorMessage = Label.CRM_Deal_Delete_Error;
        String errorForHighLevelTarget = Label.CRM_Promotional_Assortment_Deal_Error;
        String errorDigitalDeal = Label.CRM_DigitalDeal_Committed_Error; //US#579
        
        CRM_Functional_Permissions__c functionalPermission = CRM_Functional_Permissions__c.getInstance();
        Boolean isDeletePermission = (functionalPermission != null && (functionalPermission.Delete_Deal_Permission__c) == True);
        Set<Id> tradeSpendDealIds = new Set<Id>();
      
        for(Opportunity deal : mapOldDeals.values()){
            // If Sent to SAP is not null then user can not be able to Delete Deal
            if(!(isDeletePermission) && (deal.Sent_To_SAP__c != Null)) {
                //Show an error to user, You can not delete the Deal
                deal.addError(errorMessage);
            }
            // Defect#3704 to restrict Deal Deletion if assortment associated to that deal is Promotional/Campaign Type
            
            else if(deal.Assortment_Record_Type__c != null && 
                        (deal.Assortment_Record_Type__c.equalsIgnoreCase(CRM_AppConstants.PROMOTIONAL_ASSORTMENT) ||
                            deal.Assortment_Record_Type__c.equalsIgnoreCase(CRM_AppConstants.CAMPAIGN_ASSORTMENT))){
                deal.addError(errorForHighLevelTarget);
            }
             //US#579 prevent deletion of committed digital deals
            else if(deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && deal.Last_Approved_Date__c !=null){
                deal.addError(errorDigitalDeal);
            }            
            // Req#905
            else if (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND) {
                if (deal.External_Id__c != null) {
                    deal.addError(System.Label.CRM_Auto_Trade_Spend_Deal_Delete_Error);
                } else if (deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                    deal.addError(System.Label.CRM_Trade_Spend_Committed_Deal_Delete_Error);
                } else {
                    tradeSpendDealIds.add(deal.Id);
                }
            }
        }
        // Req#905
        if (!tradeSpendDealIds.isEmpty()) {
            List<DealCreditNote__c> lstCreditNotes = [SELECT Id, Opportunity__c FROM DealCreditNote__c WHERE Opportunity__c IN: tradeSpendDealIds];
            Set<Id> dealIdsWithCreditNote = new Set<Id>();
            for (DealCreditNote__c creditNote : lstCreditNotes) {
                dealIdsWithCreditNote.add(creditNote.Opportunity__c);
            }
            
            if (!dealIdsWithCreditNote.isEmpty()) {
                for (Id dealId : dealIdsWithCreditNote) {
                    mapOldDeals.get(dealId).addError(System.Label.CRM_Trade_Spend_Deal_With_Credit_Note_Delete_Error);
                }
            }
        }
    }    

    /**
    *  @Description - Method to update Opportunity before Insert/update         
    *  @name - updateDealFromAccount
    *  @return 
    */
   /**
    *  @Description - Method to update Opportunity before Insert/update         
    *  @name - updateDealFromAccount
    *  @return 
    */
    public void updateDealFromAccount(Opportunity[] newDeals){
        set<Id> accountIds = new set<Id>();
        for(Opportunity deal : newDeals){
            accountIds.add(deal.AccountId);
        }
        if(!accountIds.IsEmpty())
        {
            //Defect#4364: added CurrencyIsoCode in query of account.
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Primary_Approver__c,Secondary_approver__c,
                                                            Tertiary_Approver__c, No_Pricing__c, No_Demand__c,CurrencyIsoCode FROM Account WHERE Id IN :accountIds]);
                                                            
            for(Opportunity dealnew : newDeals)
            {
                if(accountMap.containsKey(dealnew.AccountId))
                {
                     dealnew.Primary_Approver__c = accountMap.get(dealnew.AccountId).Primary_Approver__c;
                     dealnew.Secondary_approver__c = accountMap.get(dealnew.AccountId).Secondary_approver__c;
                     dealnew.Tertiary_Approver__c = accountMap.get(dealnew.AccountId).Tertiary_Approver__c ;
                     
                     //Defect#4364 : Default the currency of the deal to the currency of the Account
                     dealnew.CurrencyIsoCode = accountMap.get(dealnew.AccountId).CurrencyIsoCode;
                     if (dealnew.NR_Deal_Unique_Key__c != null) {
                        dealnew.No_Pricing__c = accountMap.get(dealnew.AccountId).No_Pricing__c;
                        dealnew.No_Demand__c = accountMap.get(dealnew.AccountId).No_Demand__c;
                     }
                }
                if(dealnew.Market_Type__c == null && dealnew.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && dealnew.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                    dealnew.Market_Type__c = CRM_AppConstants.PRODUCT_SELL_THROUGH_MARKET_TYPE;
                }
                if(dealnew.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE && dealnew.NR_Deal_Unique_Key__c == null && 
                   dealnew.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && dealnew.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
                    dealnew.Override_Pricing__c = true;
                    dealnew.isHandlingFeeChanged__c = true;
                }
            }                                
        }                                               
    }
    /* @US#490 
       @Description - Method to update the product group values o  opportunity when a deal product is inserted or deleted from deal
    *  @name - UpdateDealProductGroupOnDeal
    *  @param - Map of deal products
    *  @returns - Null
    */
    public void UpdateDealProductGroupOnDeal(Map<Id,Opportunity> mapOldDeals,Map<Id,Opportunity> mapNewDeals){
        
        map<Id,set<String>> dealIdAndDealProdGrupMap = new map<Id,set<String>>();
        
        //ER-006666 Update the Product Franchise Type Field on Deal when a deal is inserted or updated
        map<id,set<string>> uniqueFranchiseMap = new Map<id,set<string>>();
        //ER-006745 Update the Product Market Entry Field on Deal when a deal is inserted or updated
        map<id,set<string>> uniqueProductMarketEntryMap = new Map<id,set<string>>();
        set<Id> dealIdsToUpdate = new set<Id>();
        List<Opportunity> dealProducts =new List<Opportunity>();
        set<String> uniqueDealProductGrup = new set<String>();
        //ER-006666
        set<String> uniqueFranchiseGrup = new set<String>();
        //ER-006745
        set<String> uniqueProductMarketEntry = new set<String>();
        //US#207 starts
        Set<Id> dealIdsToUpsert = new Set<Id>();
        List<WB_ClientAvailTempPriceWrapper> wb_ClientAvailTempPriceWrapperList = new List<WB_ClientAvailTempPriceWrapper>();
        //US#207 ends 
        
        for(Opportunity deals : mapNewDeals.values()){
            system.debug('old stage-->'+mapOldDeals.get(deals.id).StageName);
            system.debug('new stage-->'+deals.StageName);
            if(mapOldDeals!=null && mapOldDeals.get(deals.id).StageName != deals.StageName && deals.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                    dealIdsToUpdate.add(deals.id);
                    system.debug('Deal Values for Update -->'+dealIdsToUpdate);  
            }
            //US#207 starts
            //Get all Deal whose stage has been Updated to "Committed"
            if(mapOldDeals!=null 
                    && mapOldDeals.get(deals.id).StageName != deals.StageName 
                    && (deals.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || deals.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED)
                    && deals.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
                dealIdsToUpsert.add(deals.id);
        }
            //US#207 ends
        }
        Map<id,OpportunityLineItem> mapIdDealProduct = new Map<id,OpportunityLineItem>();
        if(!dealIdsToUpsert.isEmpty() || !dealIdsToUpdate.isEmpty()){
        for(OpportunityLineItem objDealProduct: [SELECT Id,OpportunityId,Opportunity.Account.Send_Pricing_to_CAS__c, Opportunity.Pricebook_Account__c,
                                                                Price_is_Minimum__c ,Product2.Product_Group__r.External_Id__c,
                                                                Product2.name,Pricebook_Entry_Period__r.Client_Avail__c,Promoted_Price__c,
                                                                Price_Tier__c,Opportunity.Start_Date__c,Opportunity.StageName,
                                                                Opportunity.CloseDate,Opportunity.CurrencyIsoCode,Opportunity.Owner.Email,
                                                                product2.Franchise_Type__c,product2.Product_Market_Entry__c,product2.Product_Group__r.Country__c 
                                                                FROM OpportunityLineItem 
                                                                WHERE (OpportunityId IN: dealIdsToUpdate AND (Price_is_Minimum__c = true OR Opportunity.Pricebook_Account__c =: System.Label.CRM_Deal_Pricebook_Account_UK_EA ) )
                                                                OR (OpportunityId IN: dealIdsToUpsert AND Opportunity.Account.Send_Pricing_to_CAS__c = true)]){ //US#207 
            
            //ER-006422: Fetched Opportunity.Pricebook_Account__c in Query also added it in Where Clause. Updated the if condition to check Opportunity.Pricebook_Account__c equal to UK - EA.                                                    

            
            if(dealIdsToUpdate.contains(objDealProduct.OpportunityId) && (objDealProduct.Price_is_Minimum__c == true || objDealProduct.Opportunity.Pricebook_Account__c ==  System.Label.CRM_Deal_Pricebook_Account_UK_EA)){
            uniqueDealProductGrup.add(objDealProduct.Product2.Product_Group__r.External_Id__c);
            //ER-006666
            uniqueFranchiseGrup.add(objDealProduct.product2.Product_Group__r.External_Id__c+':'+objDealProduct.product2.Franchise_Type__c);
            //ER-006745
            //ER-ER-007020 Start
            //ER-ER-007020 Start
            if(!String.isBlank(objDealProduct.product2.Product_Market_Entry__c)){
                if(objDealProduct.product2.Product_Market_Entry__c.toLowercase() == system.label.CRM_New_To_Format)
                {
                    uniqueProductMarketEntry.add(objDealProduct.product2.Product_Group__r.Country__c + ':' +objDealProduct.product2.Product_Market_Entry__c);
                }
              else
              {
                  uniqueProductMarketEntry.add(system.label.CRM_United_Kingdom + ':' +objDealProduct.product2.Product_Group__r.External_Id__c);
              }
            }else{
                  uniqueProductMarketEntry.add(system.label.CRM_United_Kingdom + ':' +objDealProduct.product2.Product_Group__r.External_Id__c);
            }
            ////ER-ER-007020 end
            dealIdAndDealProdGrupMap.put(objDealProduct.OpportunityId,uniqueDealProductGrup);
            //ER-006666
            uniqueFranchiseMap.put(objDealProduct.opportunityId,uniqueFranchiseGrup);
            //ER-006745
            uniqueProductMarketEntryMap.put(objDealProduct.opportunityId,uniqueProductMarketEntry);//ER-ER-007020 
            system.debug('Deal product group Values for Update -->'+dealIdAndDealProdGrupMap);
            }else if(dealIdsToUpsert.contains(objDealProduct.OpportunityId) && objDealProduct.Opportunity.Account.Send_Pricing_to_CAS__c == true){ // //US#207 
                mapIdDealProduct.put(objDealProduct.id,objDealProduct);
        }
        } 
        }
        system.debug('mapIdDealProduct ---->'+mapIdDealProduct);                                            
        //US#207 starts
        //Fill the details required for the CAS wrapper with Deal product details.
        for(OpportunityLineItem objDealPro: mapIdDealProduct.values()){
            WB_ClientAvailTempPriceWrapper tempPriceWrapper = new WB_ClientAvailTempPriceWrapper();
            tempPriceWrapper.clientAvailID = objDealPro.Pricebook_Entry_Period__r.Client_Avail__c; 
            tempPriceWrapper.price = objDealPro.Promoted_Price__c; // Promo Price
            tempPriceWrapper.priceTier = objDealPro.Price_Tier__c; // Price Tier
            tempPriceWrapper.priceStartDate = objDealPro.Opportunity.Start_Date__c!=null ? objDealPro.Opportunity.Start_Date__c:null; //pricing start date
            tempPriceWrapper.priceEndDate = objDealPro.Opportunity.CloseDate!=null ? objDealPro.Opportunity.CloseDate:null; // Pricing End Date 
            tempPriceWrapper.dealID = objDealPro.OpportunityId; // Deal Id
            tempPriceWrapper.priceType = 'TEMP';  //Default 
            tempPriceWrapper.dealProductID = objDealPro.id; // Deal Product Id
            tempPriceWrapper.currencyCode = objDealPro.Opportunity.CurrencyIsoCode!=null ? objDealPro.Opportunity.CurrencyIsoCode:null;   //Deal Currency 
            tempPriceWrapper.priceStatus = 'Active'; //Default 
            //SINC1954595   start
            if(dealIdsToUpsert.contains(objDealPro.OpportunityId)){
                tempPriceWrapper.dealStatus = mapNewDeals.get(objDealPro.OpportunityId).StageName; //Opportunity Deal Stage
                 system.debug('**********  tempPriceWrapper.dealStatus *****'+  tempPriceWrapper.dealStatus );
            }
            //SINC1954595   end
            wb_ClientAvailTempPriceWrapperList.add(tempPriceWrapper);
        }
        
        //Call out to CAS upsert helper method.
            WB_ClientAvailTempPriceHelper  tempPriceWrapper  = new WB_ClientAvailTempPriceHelper (); 
            List<WB_ClientAvailTempPriceWrapper> lstResultWrapper = new List<WB_ClientAvailTempPriceWrapper>();
            if(wb_ClientAvailTempPriceWrapperList != null && !wb_ClientAvailTempPriceWrapperList.isEmpty() && wb_ClientAvailTempPriceWrapperList.size()>0){      
                lstResultWrapper = tempPriceWrapper.upsertTempPrice(wb_ClientAvailTempPriceWrapperList); 
            }  
        //If while updating Errors are found for the Deal Product then Send the mail to the Deal Owner and set the stage of Deal to "Rejected".
        Map<Id,List<CRM_DealUpdateException>> mapDealIdExceptionWrapper = new Map<id,List<CRM_DealUpdateException>>(); 
        for(WB_ClientAvailTempPriceWrapper tempWrap:lstResultWrapper){
            if(tempWrap.status == 'Failed' && dealIdsToUpsert.contains(tempWrap.dealId)){
                system.debug('**********Failed record found *****');
                CRM_DealUpdateException wrapObj = new CRM_DealUpdateException(tempWrap.dealProductID, mapIdDealProduct.get(tempWrap.dealProductID).Product2.name, mapIdDealProduct.get(tempWrap.dealProductID).Opportunity.Owner.Email,tempWrap.messages);
                if(mapDealIdExceptionWrapper.containsKey(tempWrap.dealID)){
                    mapDealIdExceptionWrapper.get(tempWrap.dealID).add(wrapObj);
                }else{
                    mapDealIdExceptionWrapper.put(tempWrap.dealID, new List<CRM_DealUpdateException>{wrapObj});
                }
                mapNewDeals.get(tempWrap.dealId).StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REJECTED;
            }
        }
        
        if(!mapDealIdExceptionWrapper.isEmpty()){ 
            for(Id dealId :mapDealIdExceptionWrapper.KeySet()){
                sendMail(dealId,mapDealIdExceptionWrapper.get(dealId),mapNewDeals); 
            }
        }
         //US#207 ends  
        
        system.debug('map value to update -->'+dealIdAndDealProdGrupMap.keyset());
        for(Opportunity opp : mapNewDeals.values()){
            if((dealIdAndDealProdGrupMap != null && dealIdAndDealProdGrupMap.containsKey(opp.Id)) && (uniqueFranchiseMap != null && uniqueFranchiseMap.containsKey(opp.Id)) &&(uniqueProductMarketEntryMap != null && uniqueProductMarketEntryMap.containsKey(opp.Id))){
                String uniqueDealProdGrupString = '';
                //ER-006666
                String uniqueFranchiseString ='';
                //ER-006745
              String uniqueProductMarketEntryString = '';
                for(string prodGrp : dealIdAndDealProdGrupMap.get(opp.Id)){
                    uniqueDealProdGrupString += prodGrp + ';' ;
                }
                //ER-006666
                 for(string FranchiseGrp : uniqueFranchiseMap.get(opp.Id)){
                    uniqueFranchiseString += FranchiseGrp +';' ;
                }
                //ER-006745
                for(string productMarketEntry : uniqueProductMarketEntryMap.get(opp.Id)){
                    uniqueProductMarketEntryString += productMarketEntry +';' ;
                }
                opp.Deal_Product_Group__c = uniqueDealProdGrupString.subString(0,uniqueDealProdGrupString.length() - 1);
                //ER-006666
                opp.Product_Franchise_Type__c = uniqueFranchiseString.subString(0,uniqueFranchiseString.length() - 1);
                //ER-006745
                opp.Product_Market_Entry__c = uniqueProductMarketEntryString.subString(0,uniqueProductMarketEntryString.length() - 1);
                system.debug('Deal product group  -->'+opp.Deal_Product_Group__c);
            }
        }
    }
    //US#207 start
    public class CRM_DealUpdateException extends Exception {
        //public Id dealId;
        public Id dealProdId;
        public String dealProdName;
        public String dealOwnerEmail; 
        public List<String> lstErrors;
        public CRM_DealUpdateException(Id dealProdId, String dealProdName, String dealOwnerEmail,List<String> lstErrors){
            this.dealProdId = dealProdId;
            this.dealProdName = dealProdName;
            this.dealOwnerEmail =dealOwnerEmail;
            this.lstErrors = lstErrors;
        }
    }
    
     /**
     * @Description - Method to send mail to logged in User for all the details of processed / non processed Deals
     * @name sendMail
     */
    private void sendMail(Id dealId ,List<CRM_DealUpdateException> exceptionWrapper,Map<Id,Opportunity> mapNewDeals) {

        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
       
        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail()); 

        // Step 4. Set email contents - you can use variables!
        mail.setSubject(System.Label.CRM_ErrorCommittingDeal);
        
        String dealName  = '';
        String body = '';
        
        body = '<html>';
        body += '<body>';
        //Step 5 Create the error table
        if(!exceptionWrapper.isEmpty()){
                dealName = 'Deal : <a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + dealId + '>' + mapNewDeals.get(dealId).name + '</a> could not be Committed. <br/><br/>';
                body += '<table border = 1>';
                body += '<tr>';
                body += '<th>' + System.Label.CRM_NR_Batch_Products_Column_Name + '</th>';
                body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
                body += '</tr>';
                mail.setSenderDisplayName('Deal: '+ mapNewDeals.get(dealId).name);
                sendTo.add(exceptionWrapper[0].dealOwnerEmail);
                if(!sendTo.isEmpty()) {
                    mail.setToAddresses(sendTo); 
                }
            
                for (CRM_DealUpdateException excp : exceptionWrapper) {
                    body += '<tr>';
                    
                    if(dealId != null){
                        body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.dealProdId + '>' +excp.dealProdName + '</a></td>';
                    }else{
                        body +='<td></td>';
                    }  
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
        }  
        body += '</body>';
        body += '</html>';
        body = dealName +body;
        mail.setHtmlBody(body); 
         
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    //US#207 Ends
    
    
    public void updateLineItemsForCommittedDeals(Map<Id,Opportunity> mapOldDeals,Map<Id,Opportunity> mapNewDeals) {
        system.debug('isFirstRun'+isFirstRun);
        if(!isFirstRun) {
            return;
        }
        
        isFirstRun = false;
        Set<Id> setCommittedDeals = new Set<Id>();
        Set<Id> setDealIdForRoyaltyFeeUpdate = new Set<Id>();
        
        for(Opportunity newDeal : mapNewDeals.values()) {
            Opportunity oldDeal = mapOldDeals.get(newDeal.Id);
            
            if(newDeal.StageName != oldDeal.StageName && newDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
                setCommittedDeals.add(newDeal.Id);
            }
            
            if(newDeal.Couponing_Discount__c != oldDeal.Couponing_Discount__c ||
               newDeal.Tax_Rate__c != oldDeal.Tax_Rate__c ||
               newDeal.Couponing_Redemption_Rate__c != oldDeal.Couponing_Redemption_Rate__c){
                 setDealIdForRoyaltyFeeUpdate.add(newDeal.Id);
        }
        }
        
        
        Map<ID,OpportunityLineItem> mapDPWithID = new Map<Id,OpportunityLineItem>();
        
        // For all the committed deals, do the following:
        // 1. update the Approved Quantity
        // 2. Reset UK Approval related flags 
        if(!setCommittedDeals.isEmpty() || !setDealIdForRoyaltyFeeUpdate.isEmpty()) {
            for (OpportunityLineItem dealProduct : [SELECT Id, OpportunityId, Approved_Qty__c, Initial_Quantity__c, 
                   Cut_off_date__c, Deal_Committed_Date__c, Royalty_Fee_Fixed__c , Royalty_Fee_Cost__c
                   FROM OpportunityLineItem WHERE OpportunityId IN: setCommittedDeals OR OpportunityId IN: setDealIdForRoyaltyFeeUpdate]) {
              if(setCommittedDeals.contains(dealProduct.OpportunityId)){ 
                Opportunity dealRec = mapNewDeals.get(dealProduct.OpportunityId);
                
                Boolean doUpdateApprovedQty = (dealProduct.Cut_off_date__c>=System.today() && dealProduct.Approved_Qty__c!=dealProduct.Initial_Quantity__c);
                Boolean doResetFlags = ((dealRec.UK_Approvers_Cat_FEATURE__c > 0 
                                   || dealRec.UK_Approvers_NR_FEATURE__c > 0
                                   || dealRec.Product_Price_Is_Under_Minimum__c > 0
                                   || dealRec.Product_Contribution_Is_Under_Minimum__c > 0)
                                   && dealRec.Sales_Organisation__c != CRM_AppConstants.TERRITORY_FRANCE_CODE
                                   && dealRec.Sales_Organisation__c != CRM_AppConstants.TERRITORY_NETHERLAND_CODE
                                   && dealRec.Sales_Organisation__c != CRM_AppConstants.TERRITORY_BELGIUM_CODE);
                
                if(doUpdateApprovedQty) {
                    dealProduct.Approved_Qty__c = dealProduct.Initial_Quantity__c;
                }
                
                if(doResetFlags) {
                    dealProduct.UK_Approvers_NR_FEATURE__c = false;
                    dealProduct.UK_Approvers_Cat_FEATURE__c = false;
                    dealProduct.Price_is_Minimum__c = false;
                    dealProduct.Contribution_is_Minimum__c = false;
                }
                
                if(doUpdateApprovedQty || doResetFlags) {
                   mapDPWithID.put(dealProduct.id, dealProduct);
                }
            }
                if(setDealIdForRoyaltyFeeUpdate.contains(dealProduct.OpportunityId)) {
                  dealProduct.Royalty_Fee_Fixed__c = dealProduct.Royalty_Fee_Cost__c;
                  mapDPWithID.put(dealProduct.id, dealProduct);
              }  
            }
            
            // Update the remaining deal products
            if(!mapDPWithID.values().isEmpty()) {
                // use async Queueable calls to update Deal Products 
                System.enqueueJob(new CRM_AsyncUpdateDealProducts(mapDPWithID.values()));
            }
        }
    }
    
     /* @US#Germany#CreditNote 
       @Description - Method to update the Budget on Deal
    *  @name - UpdateDealBudget
    *  @param - Map of deal products
    *  @returns - Null
    */
    public void UpdateDealBudget(Map<Id,Opportunity> mapOldDeals,List<Opportunity> lstNewDeals){
      List<Coop_Budget__c> lstCoopBudget = new List<Coop_Budget__c>();
      Map<Id,List<Opportunity>> mapAccountIdToDealList = new Map<Id,List<Opportunity>>();
      String currentUserEmailAddress = UserInfo.getUserEmail();
      String currentUserName = '/ '+UserInfo.getFirstName()+' '+UserInfo.getLastName();
      
      //US : 902 : UK Deal Approval Process changes
      String currentUserId =  UserInfo.getUserId();
      String jamesJacksonId = CRM_UK_Approval_process_submitter__c.getOrgDefaults().James_Jackson_Id__c;
      
      //Defect#4364 : Default the currency of the deal to the currency of the Account - start 
          set<Id> setDealAccountIds = new set<Id>();
          map<Id,Account> dealAccIdToAccountmap;
          
          for(Opportunity deal : lstNewDeals){
              if(mapOldDeals != null && deal.AccountID != mapOldDeals.get(deal.Id).AccountId){
                setDealAccountIds.add(deal.AccountID);
              }
          }
          
          if(setDealAccountIds != null && setDealAccountIds.size() > 0){
            dealAccIdToAccountmap = new map<Id,Account>([select Id,CurrencyIsoCode from Account where Id IN: setDealAccountIds]);
            system.debug('dealAccIdToAccountmap map value --> '+dealAccIdToAccountmap);
          }  
      
      //Defect#4364 : Default the currency of the deal to the currency of the Account - end
      
      for(Opportunity deal : lstNewDeals){
        if(mapOldDeals != null){
          if(
             (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) &&
                 (
                    deal.Promo_Start_Date__c != mapOldDeals.get(deal.Id).Promo_Start_Date__c ||
                    deal.AccountID != mapOldDeals.get(deal.Id).AccountId ||
                    (
                        deal.RecordTypeId != mapOldDeals.get(deal.Id).RecordTypeId &&
                        mapOldDeals.get(deal.Id).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL &&
                        deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL
                    )
                ) && 
               deal.Promo_Start_Date__c != null && deal.AccountID != null
          ){
            if(mapAccountIdToDealList.containsKey(deal.AccountId)){
              mapAccountIdToDealList.get(deal.AccountId).add(deal);
            }else{
              mapAccountIdToDealList.put(deal.AccountId,new List<Opportunity>{deal});
            }
          }
          
          //Defect#4364 : Default the currency of the deal to the currency of the Account
              if(dealAccIdToAccountmap != null && dealAccIdToAccountmap.containsKey(deal.AccountId)){
                  deal.CurrencyIsoCode = dealAccIdToAccountmap.get(deal.AccountId).CurrencyIsoCode;
              }
          
             //Set Name and email Id of Current user if deal owner and deal submitter are different while Submitting the deal for approval 
             //Both fields are used in Deal Approval Email templates in order to send mail to inital submitter and deal owner
             if(deal.Owner_Email_Id__c != currentUserEmailAddress){
               deal.Initial_Submitter__c = currentUserEmailAddress;
               deal.Initial_Submitter_Name__c = currentUserName;
             }else if (deal.Owner_Email_Id__c == currentUserEmailAddress){
               deal.Initial_Submitter__c = null;
               deal.Initial_Submitter_Name__c = null;
             }
                
                //US : 902 : UK Deal Approval Process changes
                Boolean isUKDeal = (
                            (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_UK_CODE))
                            ||
                            (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && (deal.Account_Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE || deal.Account_Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE))
                        );
           
            //US : 902 : UK Deal Approval Process changes             
                if(deal.StageName != mapOldDeals.get(deal.Id).StageName && deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL &&
                   isUKDeal && currentUserId.contains(jamesJacksonId)){
                    deal.Is_Deal_Submitted_By_James_Jackson__c = true;
                }
          
        }else{
          
          //US : 902 : UK Deal Approval Process changes
          deal.Is_Deal_Submitted_By_James_Jackson__c = false;
          if((deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL || deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) &&
              deal.Promo_Start_Date__c != null){
            if(mapAccountIdToDealList.containsKey(deal.AccountId)){
              mapAccountIdToDealList.get(deal.AccountId).add(deal);
            }else{
              mapAccountIdToDealList.put(deal.AccountId,new List<Opportunity>{deal});
            }
          }
        }
        
        //Defect #4415: Overide Pricing checkbox is not automatically checked for JP
        if(mapOldDeals != null && mapOldDeals.get(deal.Id).Market_Type__c == CRM_AppConstants.PRODUCT_SELL_THROUGH_MARKET_TYPE && 
                    deal.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE && deal.NR_Deal_Unique_Key__c == null && 
                    deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
            deal.Override_Pricing__c = true;
            deal.isHandlingFeeChanged__c = true;   
        }
        else if(mapOldDeals != null && mapOldDeals.get(deal.Id).Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE && 
                    deal.Market_Type__c == CRM_AppConstants.PRODUCT_SELL_THROUGH_MARKET_TYPE && deal.NR_Deal_Unique_Key__c == null && 
                    deal.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
            deal.Override_Pricing__c = false;
            deal.isHandlingFeeChanged__c = false;   
        }
      }
      
      if(mapAccountIdToDealList.size() > 0){
        lstCoopBudget = [Select Id,Customer__c,Start_Date__c,End_Date__c From Coop_Budget__c WHERE Customer__c IN :mapAccountIdToDealList.keySet() AND Start_Date__c != null AND End_Date__c != null];
        system.debug('lstCoopBudget :  '+lstCoopBudget);
        for(Coop_Budget__c budget : lstCoopBudget){
          if(mapAccountIdToDealList.containsKey(budget.Customer__c)){
            for(Opportunity deal : mapAccountIdToDealList.get(budget.Customer__c)){
              system.debug('Check condition : '+(budget.Start_Date__c <= deal.Promo_Start_Date__c && budget.End_Date__c >= deal.Promo_Start_Date__c));
              if(budget.Start_Date__c <= deal.Promo_Start_Date__c && budget.End_Date__c >= deal.Promo_Start_Date__c){
                deal.Coop_Budget__c = budget.Id;
              }
            }
          }
        }
      }
    }
  
    
        /* @US#Games 
        *    Description - Method to Post in chatter when co-op spend more than 50000
        *    Added as a part of US930
        */
        public void addChatterPostUSGames(Map<Id,Opportunity> mapOldDeals,Map<Id,Opportunity> mapNewDeals){
            List<id> setOfDealId = new List<id>();
            
            string groupId;

            CRM_Batch_Size__c objGame = CRM_Batch_Size__c.getValues('CRM_US_Games_Chatter_Post_Amount_Limit');
            
            Integer amountLimit = objGame != null ? Integer.valueOf(objGame.Batch_Size__c) : 50000;
            
            List<String> args = new String[]{'0','number','###,###,##0.00'};
            String formatedAmount = String.format(amountLimit.format(), args);
            
            for(Opportunity oppobj : mapNewDeals.values()){                
                if(
                    oppobj.Co_op_Actual_Amount__c != mapOldDeals.get(oppobj.Id).Co_op_Actual_Amount__c && 
                    oppobj.Last_Approved_Co_op_Amount__c != null &&
                   (( mapOldDeals.get(oppobj.Id).Co_op_Actual_Amount__c - oppobj.Last_Approved_Co_op_Amount__c) < amountLimit) &&
                   ((oppobj.Co_op_Actual_Amount__c - oppobj.Last_Approved_Co_op_Amount__c) > amountLimit)
                ){
                    setOfDealId.add(oppobj.Id);
                    
                }
            }
            
            List<CollaborationGroup> cg = [select id,Name from CollaborationGroup where Name =: CRM_AppConstants.COLLABORATIONGROUP_CHATTERPOST LIMIT 1];
            
            if(cg.size() > 0){
                groupId = cg[0].Id;
            }
            
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            if(setOfDealId.Size() > 0 && groupId != null){
                
                for(integer i=0;i<setOfDealId.size();i++){
                    
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
                    mentionSegmentInput.id = groupId;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
        
                    textSegmentInput.text = Label.USGamesPostChatterMessage +' '+'$'+formatedAmount;
                    messageBodyInput.messageSegments.add(textSegmentInput);
        
                    feedItemInput.body = messageBodyInput;
                    
                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                    
                    feedItemInput.subjectId = setOfDealId[i];
                    
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                    batchInputs.add(batchInput);
                }
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        }

    /** 
    *  @description: - This method is used to add Exception log for Deal product
    *  @name: logAnException
    *  @return: void
    */ 
    public static List<CRM_ErrorLogger.ErrorLog> logAnException(List<Database.Error> errors, Id recordId, String functionalModule,String className){
        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = new list<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        for(Database.Error err : errors){
            errorLogInstance.recordId = recordId;
            errorLogInstance.functionalModule = functionalModule;
            errorLogInstance.className = className;
            errorLogInstance.lineNumber = '';
            errorLogInstance.errorMessage = ' Error Message: ' +err.getMessage();
            errorLogInstance.stackTrace = ' Error Code: ' + String.valueOf(err.getStatusCode());
            errorLogInstanceList.add(errorLogInstance);
        }
        return errorLogInstanceList;
    }
}