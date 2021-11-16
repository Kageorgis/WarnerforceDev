/**
   @Author-Cognizant Technology Solutions
   @name-CRM_PBEPHandler
   @CreateDate- 11 mar 2016
   @Description-
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_PBEPHandler{

    /**
    *  @Description - This method call the update deal product fields functionality for insert - update operation respectively
    *  @name - updateDealProductPrices
    *  @return - void
    *
    public void generatePBEPList(Map<Id,Pricebook_Entry_Period__c> oldPBEPMap, Pricebook_Entry_Period__c[] newPBEPList) {
        
        if(oldPBEPMap!= null || oldPBEPMap.size() > 0) {
           List<Pricebook_Entry_Period__c> listImpactedPBEP = new List<Pricebook_Entry_Period__c>();
            
            for(Pricebook_Entry_Period__c newPBEP : newPBEPList) {
                if(newPBEP.List_Price__c != oldPBEPMap.get(newPBEP.Id).List_Price__c || newPBEP.Account_Price__c != oldPBEPMap.get(newPBEP.Id).Account_Price__c) {
                    listImpactedPBEP.add(newPBEP);
                }
            }
            
            if(!listImpactedPBEP.isEmpty()){
            fetchDealProduct(listImpactedPBEP);
            }
        }
    }
    */
    /**
    *  @Description - This method call the update deal product fields functionality for insert - update operation respectively
    *  @name - updateDealProductPrices
    *  @return - void
    *
    public void fetchDealProduct(Pricebook_Entry_Period__c[] listImpactedPBEP) {
        
        Map<Id,Pricebook_Entry_Period__c> mapImpactedPBEP = new Map<Id,Pricebook_Entry_Period__c>();
        List<OpportunityLineItem> listAffectedDealProduct = new List<OpportunityLineItem>();
        
        for(Pricebook_Entry_Period__c newPBEP : listImpactedPBEP) {
        mapImpactedPBEP.put(newPBEP.Id,newPBEP);
        }
        
        listAffectedDealProduct = [Select Id,Pricebook_Entry_Period__c,Target_Quantity__c,Quantity
        from OpportunityLineItem Where Opportunity.StageName = :CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT and Pricebook_Entry_Period__c in:mapImpactedPBEP.keySet()];
            
        if(listAffectedDealProduct != null && listAffectedDealProduct.size() > 0) {
            generateDealProductPricingWrapper(listAffectedDealProduct,mapImpactedPBEP);
        }
    }
    */
        
    /**
    *  @Description - This method prepares data specific to Costing and invokes the related functionality.
    *  @name - generateDealProductPricingWrapper
    *  @return - void
    *
    public void generateDealProductPricingWrapper(List<OpportunityLineItem> lstDealProduct,Map<Id,Pricebook_Entry_Period__c> mapImpactedPBEP){
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        Map<Id,Opportunity> mapDeals = getOpportunities(lstDealProduct);

        CRM_ProductPricingHandler.DealWrapper dw;
        
        for(OpportunityLineItem oli : lstDealProduct) {
            dw = new CRM_ProductPricingHandler.DealWrapper();
            dw.dealId = oli.OpportunityId;
            dw.accountId = mapDeals.get(oli.OpportunityId).AccountId;
            dw.dealCurrency = mapDeals.get(oli.OpportunityId).CurrencyISOCode;
            dw.productId = oli.Product2Id;
            dw.pricebookId = mapDeals.get(oli.OpportunityId).Pricebook2Id;
            dw.dealStartDate = mapDeals.get(oli.OpportunityId).Start_Date__c;
            dw.dealProduct = oli;
            listDealWrappers.add(dw);               
        }
        
        Map<Id,Account_Plan__c[]> mapAccountPlans = initializeAccountPlans(lstDealProduct);
        if(!listDealWrappers.isEmpty() && mapAccountPlans != null && mapAccountPlans.size() > 0){    
           updateQuantity(listDealWrappers,mapAccountPlans);
        }
    }
    */
    /**
        *  @Description - The method set all the quantity on Deal Product
        *  @name - updateQuantity
        *  @return - void
    
    public void updateQuantity(CRM_ProductPricingHandler.DealWrapper[] listDealWrappers,Map<Id,Account_Plan__c[]> mapAccountPlans) {
        
        List<OpportunityLineItem> lstDealProduct = new List<OpportunityLineItem>();
        if(!listDealWrappers.isEmpty()){
            CRM_ProductPricingHandler instance = new CRM_ProductPricingHandler(listDealWrappers);
            
            for(CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers) {
                
                // for update
                Account_Plan__c accntPlan = getAccountPlan(dw,mapAccountPlans);
                Decimal accntPrice = instance.getAccountPrice(dw);
                if( accntPlan != null && accntPrice > 0 ){
                     dw.dealProduct.Quantity = accntPlan.Published_Target__c / accntPrice;
                     dw.dealProduct.Target_Quantity__c = accntPlan.Published_Target__c / accntPrice;
                     lstDealProduct.add(dw.dealProduct);
                }
            }
            
          if(!lstDealProduct.isEmpty()){
          update lstDealProduct;
          }
        }
    }
    */
    /**
        *  @Description - The method prepares a (map) collection of Deal Id and the Information of Deal
        *  @name - getOpportunities
        *  @return - return a collection of Deal Id and Deal Information
    
    private Map<Id,Opportunity> getOpportunities(OpportunityLineItem[] dealProds) {
        Map<Id,Opportunity> mapOppLineItems = new Map<Id,Opportunity>();
         
        for(OpportunityLineItem oli : dealProds) {
            mapOppLineItems.put(oli.OpportunityId, null);
        }
        
        mapOppLineItems = new Map<Id,Opportunity>([select Id, Start_Date__c, Pricebook2Id, CurrencyISOCode, AccountId
                        from Opportunity 
                        where Id IN: mapOppLineItems.keySet()]);
                        
        return mapOppLineItems;
    }
    */
    /**
        *  @Description - The method prepares a (map) collection of Account Plan Id and the Information of Account Plans
        *  @name - getAccountPlans
        *  @return - return a collection of ccount Plan Id and Account Plan Information
    
    private Map<Id,Account_Plan__c[]> initializeAccountPlans(OpportunityLineItem[] dealProds) {
        Map<Id,Account_Plan__c[]> mapDatedAccountPlans = new Map<Id,Account_Plan__c[]>();
         
        for(OpportunityLineItem oli : dealProds) {
           if(oli.Opportunity != null && oli.Opportunity.AccountId != null)
           {
           mapDatedAccountPlans.put(oli.Opportunity.AccountId, null);
           }
        }
        
        for(Account_Plan__c ap : [select Id, Published_Target__c from Account_Plan__c where Customer__c IN: mapDatedAccountPlans.keySet()]){
            if(!mapDatedAccountPlans.containsKey(ap.Customer__c)){
                mapDatedAccountPlans.put(ap.Customer__c, new Account_Plan__c[]{});
            }
            mapDatedAccountPlans.get(ap.Customer__c).add(ap);
        }
                        
        return mapDatedAccountPlans;
    }
    */
    /**
    *  Description-Method fetches the Account Plan for the respective Deal Product where the start date and end date of plan lies within that of Deal
    *  @name-getProductDatedPricebookEntry
    *  @param-Deal Wrapper 
    *  @return-productPricebookEntryPeriod-After the required comparisons are made the applicable Pricebook Entry Period for a Product is returned
    
    public Account_Plan__c getAccountPlan(CRM_ProductPricingHandler.DealWrapper dw, Map<Id,Account_Plan__c[]> mapAccountPlans) {
            
        Account_Plan__c accountPlan = new Account_Plan__c();
        if(mapAccountPlans.containsKey(dw.accountId)) {
            for(Account_Plan__c accntPlan : mapAccountPlans.get(dw.accountId)){
                //Comparing dates of Account Plan with that of Deal Start Date
                if(dw.dealStartDate <= accntPlan.Start_Date__c && accntPlan.Start_Date__c <= dw.dealEndDate ) {
                    
                    accountPlan = accntPlan;
                    break;
                }
            } 
        }
        
        return accountPlan;
    }
    */
    /**
        *  @Description - The method updates Deal Product if it is invalid
        *  @name - updateInvalidDealProducts
        *  @return - returns void
    
    public void updateInvalidDealProducts(Map<Id,Pricebook_Entry_Period__c> newPBEPMap) {
        list<OpportunityLineItem> updateDealProductsList = new list<OpportunityLineItem>();
        try {
                for(OpportunityLineItem dealProduct: [select id, ListPrice__c, Invalid_Deal_Product__c,Pricebook_Entry_Period__r.Start_Date__c,
                                                     Pricebook_Entry_Period__r.List_Price__c, Opportunity.Start_Date__c, Opportunity.CloseDate, Pricebook_Entry_Period__c,
                                                     OpportunityId
                                                     from OpportunityLineItem
                                                     where Pricebook_Entry_Period__c IN: newPBEPMap.keySet() limit 50000]) {
                    if(!(dealProduct.Pricebook_Entry_Period__r.Start_Date__c >=  dealProduct.Opportunity.Start_Date__c && 
                        dealProduct.Pricebook_Entry_Period__r.Start_Date__c < dealProduct.Opportunity.CloseDate) ||
                        (dealProduct.Pricebook_Entry_Period__r.List_Price__c!=null && 
                        dealProduct.ListPrice__c !=  dealProduct.Pricebook_Entry_Period__r.List_Price__c)) {
                        if(!dealProduct.Invalid_Deal_Product__c) {
                            dealProduct.Invalid_Deal_Product__c=true;
                            updateDealProductsList.add(dealProduct);    
                        }
                    }
                    else {
                        if(dealProduct.Invalid_Deal_Product__c) {
                            dealProduct.Invalid_Deal_Product__c=false;
                            updateDealProductsList.add(dealProduct);    
                        }
                    }
                    system.debug('==updateDealProductsList=='+updateDealProductsList);
                }
                if(updateDealProductsList.size()>0)
                    update updateDealProductsList;
                }
        catch(Exception  e){
            logAnException(e,null);
        }
    }
    */

    /**
     * Future Method called from PBEP After Update
     */
    public void setDuplicatePBEPFuture(Map<Id,Pricebook_Entry_Period__c> mapOldProducts, List<Pricebook_Entry_Period__c> lstNewPBEP) {
        Set<String> keySet = new Set<String>();
        Set<Id> setPBEPIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setPricebookIds = new Set<Id>();

        // 1. Prepare the unique Key and query the PBEP records from database so that if needed the existing records can be modified with isDuplicate flag
        for (Pricebook_Entry_Period__c newPBEPInstance : lstNewPBEP) {
            if (newPBEPInstance.Product__c != null && newPBEPInstance.Price_Book__c != null && newPBEPInstance.New_Release__c && newPBEPInstance.Start_Date__c > System.today()) {
                if (
                        (mapOldProducts.isEmpty() && mapOldProducts.size() == 0) ||
                        (
                            mapOldProducts.containsKey(newPBEPInstance.Id) &&
                            (
                                mapOldProducts.get(newPBEPInstance.Id).New_Release__c != newPBEPInstance.New_Release__c ||
                                (
                                    mapOldProducts.get(newPBEPInstance.Id).Start_Date__c != newPBEPInstance.Start_Date__c &&
                                    (
                                        (mapOldProducts.get(newPBEPInstance.Id).Start_Date__c.year() != newPBEPInstance.Start_Date__c.year()) ||
                                        (mapOldProducts.get(newPBEPInstance.Id).Start_Date__c.month() != newPBEPInstance.Start_Date__c.month())
                                    )
                                )
                            )
                        )
                ) {
                    String productId = String.ValueOf(newPBEPInstance.Product__c).length() == 18 ? String.ValueOf(newPBEPInstance.Product__c).substring(0, 15) : String.ValueOf(newPBEPInstance.Product__c);
                    String pricebookId = String.ValueOf(newPBEPInstance.Price_Book__c).length() == 18 ? String.ValueOf(newPBEPInstance.Price_Book__c).substring(0, 15) : String.ValueOf(newPBEPInstance.Price_Book__c);
                    keySet.add(productId + '-' + pricebookId + '-' + newPBEPInstance.CurrencyIsoCode);
                    setPBEPIds.add(newPBEPInstance.Id);
                    setProductIds.add(newPBEPInstance.Product__c);
                    setPricebookIds.add(newPBEPInstance.Price_Book__c);
                }
            }
        }
        System.debug('--setPBEPIds->'+setPBEPIds);
        if (!setPBEPIds.isEmpty()) {
            //ER-006500 - batch failure due to error :AsyncException: Future method -->Start
            if(System.isBatch()){
                setDuplicatePBEPByBatch(keySet, setPBEPIds, setProductIds, setPricebookIds);
            }
            else{
                setDuplicatePBEP(keySet, setPBEPIds, setProductIds, setPricebookIds);
            }
            //ER-006500 - batch failure due to error :AsyncException: Future method -->End
        }
    }

    /**
     * Code changes required : On Pbep insert / update
     * 1.Take the product and PB for that pbep(trigger.new) Query on NR pbep with that product and PB and with sorted by start date and created date asc
     * 2.Prepare map of key (prodId + currency + pricebook) and values as another map of pbepid as key to priority order as value only for those PBEP 
         whose startDate > today -> Map<String, Map<Id, Decimal>>>
     * 3.Query on nr deal product with above product and PB and prepare map with pbep's productid + currency + pricebook to deal Products count
     * 4.Loop on trigger.new pbep instances
        a.If existing deal Product found for that pbep's productid+ currency + pricebook
            - in case of insert we can mark that pbep record as IsDuplicate = true
            - in case of update we need to check deal product.pbepid != pbepid and then we can mark as IsDuplicate = true
        b.If existing deal Product not found then,
            - get the list of pbeps from map with key prodid + currency + pricebook -> get the order of pbep being processed if its 
              order is 1 set IsDuplicate = false and if the order is not 1 then set as IsDuplicate = true
     */
    @future
    public static void setDuplicatePBEP(Set<String> keySet, Set<Id> newPBEPIds, Set<Id> setProductIds, Set<Id> setPricebookIds) {
        Map<String, Map<Id, Decimal>> mapUniqueKeyToMapOfPBEPIdToPriorityOrder = new Map<String, Map<Id, Decimal>>();
        Map<String, Set<Id>> mapUniqueKeyToDealProductsPBEPId = new Map<String, Set<Id>>();
        Map<Id, Pricebook_Entry_Period__c> updateExistingPBEPMap = new Map<Id, Pricebook_Entry_Period__c>();
        Map<Id, Product2> mapUpdateExistingProduct = new Map<Id, Product2>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<Pricebook_Entry_Period__c> lstNewPBEP = new List<Pricebook_Entry_Period__c>();

        if (keySet != null && keySet.size() > 0) {
            Map<Id, Pricebook_Entry_Period__c> mapExistingPBEPs = new Map<Id, Pricebook_Entry_Period__c>([
                    SELECT Id, Key__c, isDuplicate__c, New_Release__c, Start_Date__c, Product__c, Product__r.Street_Date_Has_Changed__c
                    FROM Pricebook_Entry_Period__c
                    WHERE Key__c IN: keySet
                    AND New_Release__c = true
                    AND Product__c IN: setProductIds
                    AND Price_Book__c IN: setPricebookIds
                    ORDER BY Key__c, Start_Date__c ASC
            ]);

            // 2. Prepare a Map of existing PBEPs so that Priority can be decided
            Map<String, Integer> mapValidPbepFound = new Map<String, Integer>();
            for (Pricebook_Entry_Period__c existingPBEPInstance : mapExistingPBEPs.values()) {
                if (newPBEPIds.contains(existingPBEPInstance.Id)) {
                    lstNewPBEP.add(existingPBEPInstance);
                }

                if (!mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(existingPBEPInstance.Key__c)) {
                    mapValidPbepFound.put(existingPBEPInstance.Key__c, 0);
                    Map<Id, Decimal> mapPBEPIdToPriorityOrder = new Map<Id, Decimal>();
                    if (existingPBEPInstance.Start_Date__c > System.today() &&  mapValidPbepFound.containsKey(existingPBEPInstance.Key__c)) {
                        Integer validPBEPFound = mapValidPbepFound.get(existingPBEPInstance.Key__c);
                        validPBEPFound =+ 1;
                        mapValidPbepFound.put(existingPBEPInstance.Key__c, validPBEPFound);
                        mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 1);
                    } else {
                        mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                    }
                    mapUniqueKeyToMapOfPBEPIdToPriorityOrder.put(existingPBEPInstance.Key__c, mapPBEPIdToPriorityOrder);
                } else {
                    Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(existingPBEPInstance.Key__c);
                    if (!mapPBEPIdToPriorityOrder.containsKey(existingPBEPInstance.Id)) {
                        if (existingPBEPInstance.Start_Date__c > System.today() &&  mapValidPbepFound.containsKey(existingPBEPInstance.Key__c) && mapValidPbepFound.get(existingPBEPInstance.Key__c) == 0) {
                            Integer validPBEPFound = mapValidPbepFound.get(existingPBEPInstance.Key__c);
                            validPBEPFound =+ 1;
                            mapValidPbepFound.put(existingPBEPInstance.Key__c, validPBEPFound);
                            mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 1);
                        } else {
                            mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                        }
                    }
                    //mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                    mapUniqueKeyToMapOfPBEPIdToPriorityOrder.put(existingPBEPInstance.Key__c, mapPBEPIdToPriorityOrder);
                }
            }

            // 3. Prepare a Map of existing Deal Products so that the PBEP isDuplicate flag can be set properly
            List<OpportunityLineItem> existingDealProducts = [
                    SELECT Id, Key__c, Pricebook_Entry_Period__c
                    FROM OpportunityLineItem 
                    WHERE Key__c IN: keySet
                    AND Product2Id IN: setProductIds
                    AND NR_Deal_Product_Unique_Key__c != null
                    AND Opportunity.NR_Deal_Unique_Key__c != null
            ];

            for (OpportunityLineItem dealProduct : existingDealProducts) {
                if (!mapUniqueKeyToDealProductsPBEPId.containsKey(dealProduct.Key__c)) {
                    mapUniqueKeyToDealProductsPBEPId.put(dealProduct.Key__c, new Set<Id>{dealProduct.Pricebook_Entry_Period__c});
                } else {
                    mapUniqueKeyToDealProductsPBEPId.get(dealProduct.Key__c).add(dealProduct.Pricebook_Entry_Period__c);
                }
            }

            // 4. Set the isDuplicate flags based on deal product present or not
            for (Pricebook_Entry_Period__c newPBEPInstance : lstNewPBEP) {
                if (newPBEPInstance.New_Release__c && newPBEPInstance.Start_Date__c > System.today()) {
                    if (mapUniqueKeyToDealProductsPBEPId.containsKey(newPBEPInstance.Key__c) && mapUniqueKeyToDealProductsPBEPId.get(newPBEPInstance.Key__c) != null) {
                        // Before Insert

                                if (mapUniqueKeyToDealProductsPBEPId.containsKey(newPBEPInstance.Key__c)) {

                                    // Set of PBEP with same unique Key but has different Date ranges for which deal Products are present. Only one should be present
                                    Set<Id> setPBEPIds = mapUniqueKeyToDealProductsPBEPId.get(newPBEPInstance.Key__c);

                                    // The PBEP which is modified is set isDuplicate false only if it has any deal Product present
                                    if (mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Key__c)) {
                                        Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(newPBEPInstance.Key__c);
                                        if (mapPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Id)) {

                                            //if (setPBEPIds.contains(newPBEPInstance.Id)) {
                                            for (Id pbepId : mapPBEPIdToPriorityOrder.keySet()) {
                                                if (mapExistingPBEPs.containsKey(pbepId)) {
                                                    Pricebook_Entry_Period__c existingPBEP = mapExistingPBEPs.get(pbepId);
                                                    Decimal priorityOrder = mapPBEPIdToPriorityOrder.get(pbepId);

                                                    if (priorityOrder == 1) {
                                                        if (pbepId == newPBEPInstance.Id && newPBEPInstance.isDuplicate__c) {
                                                            newPBEPInstance.isDuplicate__c = false;
                                                            newPBEPInstance.Process_NR_Batch__c = true;
                                                            if (!setPBEPIds.contains(newPBEPInstance.Id)) {
                                                                if (newPBEPInstance.Product__c != null && !newPBEPInstance.Product__r.Street_Date_Has_Changed__c) {

                                                                    newPBEPInstance.Product__r.Street_Date_Has_Changed__c = true;
                                                                    newPBEPInstance.Product__r.NR_Product_Created__c = false;

                                                                    if (!mapUpdateExistingProduct.containsKey(newPBEPInstance.Product__c)) {
                                                                        mapUpdateExistingProduct.put(newPBEPInstance.Product__c, newPBEPInstance.Product__r);
                                                                    }
                                                                }
                                                            }
                                                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);

                                                        } else if (pbepId == newPBEPInstance.Id && !newPBEPInstance.isDuplicate__c) {
                                                            newPBEPInstance.Process_NR_Batch__c = true;
                                                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                                        } else if (pbepId == existingPBEP.Id && existingPBEP.isDuplicate__c) {

                                                            existingPBEP.isDuplicate__c = false;
                                                            existingPBEP.Process_NR_Batch__c = true;

                                                            // Move the existing deal Product only if the modified PBEP date range is moved less than the deal product PBEP
                                                            // PBEP1 - PBEP2 - PBEP3 -> DP present for PBEP2. Todays date is > PBEP2 and PBEP 1 moved after PBEP2. DP is moved to PBEP1
                                                            if (!setPBEPIds.contains(existingPBEP.Id) && newPBEPInstance.Start_Date__c > existingPBEP.Start_Date__c) {
                                                                if (existingPBEP.Product__c != null && !existingPBEP.Product__r.Street_Date_Has_Changed__c) {
                                                                    existingPBEP.Product__r.Street_Date_Has_Changed__c = true;
                                                                    existingPBEP.Product__r.NR_Product_Created__c = false;

                                                                    if (!mapUpdateExistingProduct.containsKey(existingPBEP.Product__c)) {
                                                                        mapUpdateExistingProduct.put(existingPBEP.Product__c, existingPBEP.Product__r);
                                                                    }
                                                                }
                                                            }
                                                            newPBEPInstance.isDuplicate__c = true;
                                                            newPBEPInstance.Process_NR_Batch__c = false;
                                                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                                            updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                                        }
                                                    } else {
                                                        if (!existingPBEP.isDuplicate__c) {
                                                            existingPBEP.isDuplicate__c = true;
                                                            existingPBEP.Process_NR_Batch__c = false;
                                                            updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                    } else {
                        if (mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Key__c)) {

                            Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(newPBEPInstance.Key__c);
                            if (mapPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Id)) {
                                for (Id pbepId : mapPBEPIdToPriorityOrder.keySet()) {
                                    if (mapExistingPBEPs.containsKey(pbepId)) {
                                        Pricebook_Entry_Period__c existingPBEP = mapExistingPBEPs.get(pbepId);
                                        Decimal priorityOrder = mapPBEPIdToPriorityOrder.get(pbepId);

                                        // If no existing deal product present then set isDuplicate as flase only for those PBEP which is 
                                        // first with NR = true and whose Start Date is > today
                                        if (priorityOrder == 1) {
                                            if (pbepId == newPBEPInstance.Id && newPBEPInstance.isDuplicate__c) {

                                                newPBEPInstance.isDuplicate__c = false;
                                                newPBEPInstance.Process_NR_Batch__c = true;
                                                if (newPBEPInstance.Product__c != null && !newPBEPInstance.Product__r.Street_Date_Has_Changed__c) {
                                                    newPBEPInstance.Product__r.Street_Date_Has_Changed__c = true;
                                                    newPBEPInstance.Product__r.NR_Product_Created__c = false;

                                                    if (!mapUpdateExistingProduct.containsKey(newPBEPInstance.Product__c)) {
                                                        mapUpdateExistingProduct.put(newPBEPInstance.Product__c, newPBEPInstance.Product__r);
                                                    }
                                                }
                                                updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                            } else if (pbepId == existingPBEP.Id && existingPBEP.isDuplicate__c) {
                                                existingPBEP.isDuplicate__c = false;
                                                existingPBEP.Process_NR_Batch__c = true;
                                                if (existingPBEP.Product__c != null && !existingPBEP.Product__r.Street_Date_Has_Changed__c) {
                                                    existingPBEP.Product__r.Street_Date_Has_Changed__c = true;
                                                    existingPBEP.Product__r.NR_Product_Created__c = false;

                                                    if (!mapUpdateExistingProduct.containsKey(existingPBEP.Product__c)) {
                                                        mapUpdateExistingProduct.put(existingPBEP.Product__c, existingPBEP.Product__r);
                                                    }
                                                }
                                                updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                            }
                                        } else {
                                            if (pbepId == newPBEPInstance.Id) {
                                                newPBEPInstance.isDuplicate__c = true;
                                                newPBEPInstance.Process_NR_Batch__c = false;
                                                updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                            } else if (pbepId == existingPBEP.Id && !existingPBEP.isDuplicate__c) {
                                                // Exiting future PBEP needs to be updated to Duplicate true as a new valid
                                                // PBEP is updated such that the PBEP is at first priority
                                                existingPBEP.isDuplicate__c = true;
                                                existingPBEP.Process_NR_Batch__c = false;
                                                updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // New valid PBEP is inserted and no existing deal Product and no existing PBEP present so set isDuplicate = false
                            newPBEPInstance.isDuplicate__c = false;
                            newPBEPInstance.Process_NR_Batch__c = true;
                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                        }
                    }
                }
            }

            System.debug('-updateExistingPBEPMap.size()---->'+updateExistingPBEPMap.size());
            if (!updateExistingPBEPMap.isEmpty()) {
                Database.SaveResult[] saveResultList = Database.update(updateExistingPBEPMap.values(), false);
                // Error handling
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Pricebook_Entry_Period__c pbepInstance = updateExistingPBEPMap.values()[i];
                    if (!saveResultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = pbepInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DUPLICATE_PBEP_UPDATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                    }
                }
            }

            System.debug('-mapUpdateExistingProduct.size()---->'+mapUpdateExistingProduct.size());
            if (!mapUpdateExistingProduct.isEmpty() && mapUpdateExistingProduct.size() > 0) {
                Database.SaveResult[] saveResultList = Database.update(mapUpdateExistingProduct.values(), false);
                // Error handling
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Product2 productInstance = mapUpdateExistingProduct.values()[i];
                    if (!saveResultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = productInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DUPLICATE_PBEP_PRODUCT_UPDATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                    }
                }
            }

            if (!listErrorLog.isEmpty()) {
                // Inserts all errors into database
                CRM_ErrorLogger.logError(listErrorLog);
            }
        }
    }
    
        /**
     * Code changes required : On Pbep insert / update
     * 1.Take the product and PB for that pbep(trigger.new) Query on NR pbep with that product and PB and with sorted by start date and created date asc
     * 2.Prepare map of key (prodId + currency + pricebook) and values as another map of pbepid as key to priority order as value only for those PBEP 
         whose startDate > today -> Map<String, Map<Id, Decimal>>>
     * 3.Query on nr deal product with above product and PB and prepare map with pbep's productid + currency + pricebook to deal Products count
     * 4.Loop on trigger.new pbep instances
        a.If existing deal Product found for that pbep's productid+ currency + pricebook
            - in case of insert we can mark that pbep record as IsDuplicate = true
            - in case of update we need to check deal product.pbepid != pbepid and then we can mark as IsDuplicate = true
        b.If existing deal Product not found then,
            - get the list of pbeps from map with key prodid + currency + pricebook -> get the order of pbep being processed if its 
              order is 1 set IsDuplicate = false and if the order is not 1 then set as IsDuplicate = true
     */
     //ER-006500 - batch failure due to error :AsyncException: Future method -->Method added to be executed in batch context
    public static void setDuplicatePBEPByBatch(Set<String> keySet, Set<Id> newPBEPIds, Set<Id> setProductIds, Set<Id> setPricebookIds) {
        Map<String, Map<Id, Decimal>> mapUniqueKeyToMapOfPBEPIdToPriorityOrder = new Map<String, Map<Id, Decimal>>();
        Map<String, Set<Id>> mapUniqueKeyToDealProductsPBEPId = new Map<String, Set<Id>>();
        Map<Id, Pricebook_Entry_Period__c> updateExistingPBEPMap = new Map<Id, Pricebook_Entry_Period__c>();
        Map<Id, Product2> mapUpdateExistingProduct = new Map<Id, Product2>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<Pricebook_Entry_Period__c> lstNewPBEP = new List<Pricebook_Entry_Period__c>();

        if (keySet != null && keySet.size() > 0) {
            Map<Id, Pricebook_Entry_Period__c> mapExistingPBEPs = new Map<Id, Pricebook_Entry_Period__c>([
                    SELECT Id, Key__c, isDuplicate__c, New_Release__c, Start_Date__c, Product__c, Product__r.Street_Date_Has_Changed__c
                    FROM Pricebook_Entry_Period__c
                    WHERE Key__c IN: keySet
                    AND New_Release__c = true
                    AND Product__c IN: setProductIds
                    AND Price_Book__c IN: setPricebookIds
                    ORDER BY Key__c, Start_Date__c ASC
            ]);

            // 2. Prepare a Map of existing PBEPs so that Priority can be decided
            Map<String, Integer> mapValidPbepFound = new Map<String, Integer>();
            for (Pricebook_Entry_Period__c existingPBEPInstance : mapExistingPBEPs.values()) {
                if (newPBEPIds.contains(existingPBEPInstance.Id)) {
                    lstNewPBEP.add(existingPBEPInstance);
                }

                if (!mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(existingPBEPInstance.Key__c)) {
                    mapValidPbepFound.put(existingPBEPInstance.Key__c, 0);
                    Map<Id, Decimal> mapPBEPIdToPriorityOrder = new Map<Id, Decimal>();
                    if (existingPBEPInstance.Start_Date__c > System.today() &&  mapValidPbepFound.containsKey(existingPBEPInstance.Key__c)) {
                        Integer validPBEPFound = mapValidPbepFound.get(existingPBEPInstance.Key__c);
                        validPBEPFound =+ 1;
                        mapValidPbepFound.put(existingPBEPInstance.Key__c, validPBEPFound);
                        mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 1);
                    } else {
                        mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                    }
                    mapUniqueKeyToMapOfPBEPIdToPriorityOrder.put(existingPBEPInstance.Key__c, mapPBEPIdToPriorityOrder);
                } else {
                    Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(existingPBEPInstance.Key__c);
                    if (!mapPBEPIdToPriorityOrder.containsKey(existingPBEPInstance.Id)) {
                        if (existingPBEPInstance.Start_Date__c > System.today() &&  mapValidPbepFound.containsKey(existingPBEPInstance.Key__c) && mapValidPbepFound.get(existingPBEPInstance.Key__c) == 0) {
                            Integer validPBEPFound = mapValidPbepFound.get(existingPBEPInstance.Key__c);
                            validPBEPFound =+ 1;
                            mapValidPbepFound.put(existingPBEPInstance.Key__c, validPBEPFound);
                            mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 1);
                        } else {
                            mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                        }
                    }
                    //mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                    mapUniqueKeyToMapOfPBEPIdToPriorityOrder.put(existingPBEPInstance.Key__c, mapPBEPIdToPriorityOrder);
                }
            }

            // 3. Prepare a Map of existing Deal Products so that the PBEP isDuplicate flag can be set properly
            List<OpportunityLineItem> existingDealProducts = [
                    SELECT Id, Key__c, Pricebook_Entry_Period__c
                    FROM OpportunityLineItem 
                    WHERE Key__c IN: keySet
                    AND Product2Id IN: setProductIds
                    AND NR_Deal_Product_Unique_Key__c != null
                    AND Opportunity.NR_Deal_Unique_Key__c != null
            ];

            for (OpportunityLineItem dealProduct : existingDealProducts) {
                if (!mapUniqueKeyToDealProductsPBEPId.containsKey(dealProduct.Key__c)) {
                    mapUniqueKeyToDealProductsPBEPId.put(dealProduct.Key__c, new Set<Id>{dealProduct.Pricebook_Entry_Period__c});
                } else {
                    mapUniqueKeyToDealProductsPBEPId.get(dealProduct.Key__c).add(dealProduct.Pricebook_Entry_Period__c);
                }
            }

            // 4. Set the isDuplicate flags based on deal product present or not
            for (Pricebook_Entry_Period__c newPBEPInstance : lstNewPBEP) {
                if (newPBEPInstance.New_Release__c && newPBEPInstance.Start_Date__c > System.today()) {
                    if (mapUniqueKeyToDealProductsPBEPId.containsKey(newPBEPInstance.Key__c) && mapUniqueKeyToDealProductsPBEPId.get(newPBEPInstance.Key__c) != null) {
                        // Before Insert

                                if (mapUniqueKeyToDealProductsPBEPId.containsKey(newPBEPInstance.Key__c)) {

                                    // Set of PBEP with same unique Key but has different Date ranges for which deal Products are present. Only one should be present
                                    Set<Id> setPBEPIds = mapUniqueKeyToDealProductsPBEPId.get(newPBEPInstance.Key__c);

                                    // The PBEP which is modified is set isDuplicate false only if it has any deal Product present
                                    if (mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Key__c)) {
                                        Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(newPBEPInstance.Key__c);
                                        if (mapPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Id)) {

                                            //if (setPBEPIds.contains(newPBEPInstance.Id)) {
                                            for (Id pbepId : mapPBEPIdToPriorityOrder.keySet()) {
                                                if (mapExistingPBEPs.containsKey(pbepId)) {
                                                    Pricebook_Entry_Period__c existingPBEP = mapExistingPBEPs.get(pbepId);
                                                    Decimal priorityOrder = mapPBEPIdToPriorityOrder.get(pbepId);

                                                    if (priorityOrder == 1) {
                                                        if (pbepId == newPBEPInstance.Id && newPBEPInstance.isDuplicate__c) {
                                                            newPBEPInstance.isDuplicate__c = false;
                                                            newPBEPInstance.Process_NR_Batch__c = true;
                                                            if (!setPBEPIds.contains(newPBEPInstance.Id)) {
                                                                if (newPBEPInstance.Product__c != null && !newPBEPInstance.Product__r.Street_Date_Has_Changed__c) {

                                                                    newPBEPInstance.Product__r.Street_Date_Has_Changed__c = true;
                                                                    newPBEPInstance.Product__r.NR_Product_Created__c = false;

                                                                    if (!mapUpdateExistingProduct.containsKey(newPBEPInstance.Product__c)) {
                                                                        mapUpdateExistingProduct.put(newPBEPInstance.Product__c, newPBEPInstance.Product__r);
                                                                    }
                                                                }
                                                            }
                                                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);

                                                        } else if (pbepId == newPBEPInstance.Id && !newPBEPInstance.isDuplicate__c) {
                                                            newPBEPInstance.Process_NR_Batch__c = true;
                                                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                                        } else if (pbepId == existingPBEP.Id && existingPBEP.isDuplicate__c) {

                                                            existingPBEP.isDuplicate__c = false;
                                                            existingPBEP.Process_NR_Batch__c = true;

                                                            // Move the existing deal Product only if the modified PBEP date range is moved less than the deal product PBEP
                                                            // PBEP1 - PBEP2 - PBEP3 -> DP present for PBEP2. Todays date is > PBEP2 and PBEP 1 moved after PBEP2. DP is moved to PBEP1
                                                            if (!setPBEPIds.contains(existingPBEP.Id) && newPBEPInstance.Start_Date__c > existingPBEP.Start_Date__c) {
                                                                if (existingPBEP.Product__c != null && !existingPBEP.Product__r.Street_Date_Has_Changed__c) {
                                                                    existingPBEP.Product__r.Street_Date_Has_Changed__c = true;
                                                                    existingPBEP.Product__r.NR_Product_Created__c = false;

                                                                    if (!mapUpdateExistingProduct.containsKey(existingPBEP.Product__c)) {
                                                                        mapUpdateExistingProduct.put(existingPBEP.Product__c, existingPBEP.Product__r);
                                                                    }
                                                                }
                                                            }
                                                            newPBEPInstance.isDuplicate__c = true;
                                                            newPBEPInstance.Process_NR_Batch__c = false;
                                                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                                            updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                                        }
                                                    } else {
                                                        if (!existingPBEP.isDuplicate__c) {
                                                            existingPBEP.isDuplicate__c = true;
                                                            existingPBEP.Process_NR_Batch__c = false;
                                                            updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                    } else {
                        if (mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Key__c)) {

                            Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(newPBEPInstance.Key__c);
                            if (mapPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Id)) {
                                for (Id pbepId : mapPBEPIdToPriorityOrder.keySet()) {
                                    if (mapExistingPBEPs.containsKey(pbepId)) {
                                        Pricebook_Entry_Period__c existingPBEP = mapExistingPBEPs.get(pbepId);
                                        Decimal priorityOrder = mapPBEPIdToPriorityOrder.get(pbepId);

                                        // If no existing deal product present then set isDuplicate as flase only for those PBEP which is 
                                        // first with NR = true and whose Start Date is > today
                                        if (priorityOrder == 1) {
                                            if (pbepId == newPBEPInstance.Id && newPBEPInstance.isDuplicate__c) {

                                                newPBEPInstance.isDuplicate__c = false;
                                                newPBEPInstance.Process_NR_Batch__c = true;
                                                if (newPBEPInstance.Product__c != null && !newPBEPInstance.Product__r.Street_Date_Has_Changed__c) {
                                                    newPBEPInstance.Product__r.Street_Date_Has_Changed__c = true;
                                                    newPBEPInstance.Product__r.NR_Product_Created__c = false;

                                                    if (!mapUpdateExistingProduct.containsKey(newPBEPInstance.Product__c)) {
                                                        mapUpdateExistingProduct.put(newPBEPInstance.Product__c, newPBEPInstance.Product__r);
                                                    }
                                                }
                                                updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                            } else if (pbepId == existingPBEP.Id && existingPBEP.isDuplicate__c) {
                                                existingPBEP.isDuplicate__c = false;
                                                existingPBEP.Process_NR_Batch__c = true;
                                                if (existingPBEP.Product__c != null && !existingPBEP.Product__r.Street_Date_Has_Changed__c) {
                                                    existingPBEP.Product__r.Street_Date_Has_Changed__c = true;
                                                    existingPBEP.Product__r.NR_Product_Created__c = false;

                                                    if (!mapUpdateExistingProduct.containsKey(existingPBEP.Product__c)) {
                                                        mapUpdateExistingProduct.put(existingPBEP.Product__c, existingPBEP.Product__r);
                                                    }
                                                }
                                                updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                            }
                                        } else {
                                            if (pbepId == newPBEPInstance.Id) {
                                                newPBEPInstance.isDuplicate__c = true;
                                                newPBEPInstance.Process_NR_Batch__c = false;
                                                updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                                            } else if (pbepId == existingPBEP.Id && !existingPBEP.isDuplicate__c) {
                                                // Exiting future PBEP needs to be updated to Duplicate true as a new valid
                                                // PBEP is updated such that the PBEP is at first priority
                                                existingPBEP.isDuplicate__c = true;
                                                existingPBEP.Process_NR_Batch__c = false;
                                                updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // New valid PBEP is inserted and no existing deal Product and no existing PBEP present so set isDuplicate = false
                            newPBEPInstance.isDuplicate__c = false;
                            newPBEPInstance.Process_NR_Batch__c = true;
                            updateExistingPBEPMap.put(newPBEPInstance.Id, newPBEPInstance);
                        }
                    }
                }
            }

            System.debug('-updateExistingPBEPMap.size()---->'+updateExistingPBEPMap.size());
            if (!updateExistingPBEPMap.isEmpty()) {
                Database.SaveResult[] saveResultList = Database.update(updateExistingPBEPMap.values(), false);
                // Error handling
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Pricebook_Entry_Period__c pbepInstance = updateExistingPBEPMap.values()[i];
                    if (!saveResultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = pbepInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DUPLICATE_PBEP_UPDATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                    }
                }
            }

            System.debug('-mapUpdateExistingProduct.size()---->'+mapUpdateExistingProduct.size());
            if (!mapUpdateExistingProduct.isEmpty() && mapUpdateExistingProduct.size() > 0) {
                Database.SaveResult[] saveResultList = Database.update(mapUpdateExistingProduct.values(), false);
                // Error handling
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Product2 productInstance = mapUpdateExistingProduct.values()[i];
                    if (!saveResultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = productInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DUPLICATE_PBEP_PRODUCT_UPDATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                    }
                }
            }

            if (!listErrorLog.isEmpty()) {
                // Inserts all errors into database
                CRM_ErrorLogger.logError(listErrorLog);
            }
        }
    }
    //ER-006500 - batch failure due to error :AsyncException: Future method -->End

    /**
     * Code changes required : On Pbep insert / update
     * 1.Take the product and PB for that pbep(trigger.new) Query on NR pbep with that product and PB and with sorted by start date and created date asc
     * 2.Prepare map of key (prodId + currency + pricebook) and values as another map of pbepid as key to priority order as value only for those PBEP 
         whose startDate > today -> Map<String, Map<Id, Decimal>>>
     * 3.Query on nr deal product with above product and PB and prepare map with pbep's productid + currency + pricebook to deal Products count
     * 4.Loop on trigger.new pbep instances
        a.If existing deal Product found for that pbep's productid+ currency + pricebook
            - in case of insert we can mark that pbep record as IsDuplicate = true
            - in case of update we need to check deal product.pbepid != pbepid and then we can mark as IsDuplicate = true
        b.If existing deal Product not found then,
            - get the list of pbeps from map with key prodid + currency + pricebook -> get the order of pbep being processed if its 
              order is 1 set IsDuplicate = false and if the order is not 1 then set as IsDuplicate = true
     */
    public void setDuplicatePBEP(Map<Id,Pricebook_Entry_Period__c> mapOldProducts, List<Pricebook_Entry_Period__c> lstNewPBEP) {
        Set<String> keySet = new Set<String>();
        Map<String, Map<Id, Decimal>> mapUniqueKeyToMapOfPBEPIdToPriorityOrder = new Map<String, Map<Id, Decimal>>();
        Map<String, Set<Id>> mapUniqueKeyToDealProductsPBEPId = new Map<String, Set<Id>>();
        Map<Id, Pricebook_Entry_Period__c> updateExistingPBEPMap = new Map<Id, Pricebook_Entry_Period__c>();
        Map<Id, Product2> mapUpdateExistingProduct = new Map<Id, Product2>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setPricebookIds = new Set<Id>();

        // 1. Prepare the unique Key and query the PBEP records from database so that if needed the existing records can be modified with isDuplicate flag
        for (Pricebook_Entry_Period__c newPBEPInstance : lstNewPBEP) {
            if (newPBEPInstance.Product__c != null && newPBEPInstance.Price_Book__c != null && newPBEPInstance.New_Release__c && newPBEPInstance.Start_Date__c > System.today()) {
                if ((mapOldProducts.isEmpty() && mapOldProducts.size() == 0)) {
                    String productId = String.ValueOf(newPBEPInstance.Product__c).length() == 18 ? String.ValueOf(newPBEPInstance.Product__c).substring(0, 15) : String.ValueOf(newPBEPInstance.Product__c);
                    String pricebookId = String.ValueOf(newPBEPInstance.Price_Book__c).length() == 18 ? String.ValueOf(newPBEPInstance.Price_Book__c).substring(0, 15) : String.ValueOf(newPBEPInstance.Price_Book__c);
                    keySet.add(productId + '-' + pricebookId + '-' + newPBEPInstance.CurrencyIsoCode);
                    setPricebookIds.add(newPBEPInstance.Price_Book__c);
                    setProductIds.add(newPBEPInstance.Product__c);
                }
            }
        }

        if (keySet != null && keySet.size() > 0) {
            Map<Id, Pricebook_Entry_Period__c> mapExistingPBEPs = new Map<Id, Pricebook_Entry_Period__c>([
                    SELECT Id, Key__c, isDuplicate__c, Start_Date__c, Product__c, Product__r.Street_Date_Has_Changed__c
                    FROM Pricebook_Entry_Period__c
                    WHERE Key__c IN: keySet
                    AND New_Release__c = true
                    AND Product__c IN: setProductIds
                    AND Price_Book__c IN: setPricebookIds
                    ORDER BY Key__c, Start_Date__c ASC
            ]);

            // 2. Prepare a Map of existing PBEPs so that Priority can be decided
            Map<String, Integer> mapValidPbepFound = new Map<String, Integer>();
            for (Pricebook_Entry_Period__c existingPBEPInstance : mapExistingPBEPs.values()) {
                if (!mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(existingPBEPInstance.Key__c)) {
                    mapValidPbepFound.put(existingPBEPInstance.Key__c, 0);
                    Map<Id, Decimal> mapPBEPIdToPriorityOrder = new Map<Id, Decimal>();
                    if (existingPBEPInstance.Start_Date__c > System.today() &&  mapValidPbepFound.containsKey(existingPBEPInstance.Key__c)) {
                        Integer validPBEPFound = mapValidPbepFound.get(existingPBEPInstance.Key__c);
                        validPBEPFound =+ 1;
                        mapValidPbepFound.put(existingPBEPInstance.Key__c, validPBEPFound);
                        mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 1);
                    } else {
                        mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                    }
                    mapUniqueKeyToMapOfPBEPIdToPriorityOrder.put(existingPBEPInstance.Key__c, mapPBEPIdToPriorityOrder);
                } else {
                    Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(existingPBEPInstance.Key__c);
                    if (!mapPBEPIdToPriorityOrder.containsKey(existingPBEPInstance.Id)) {
                        if (existingPBEPInstance.Start_Date__c > System.today() &&  mapValidPbepFound.containsKey(existingPBEPInstance.Key__c) && mapValidPbepFound.get(existingPBEPInstance.Key__c) == 0) {
                            Integer validPBEPFound = mapValidPbepFound.get(existingPBEPInstance.Key__c);
                            validPBEPFound =+ 1;
                            mapValidPbepFound.put(existingPBEPInstance.Key__c, validPBEPFound);
                            mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 1);
                        } else {
                            mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                        }
                    }
                    //mapPBEPIdToPriorityOrder.put(existingPBEPInstance.Id, 0);
                    mapUniqueKeyToMapOfPBEPIdToPriorityOrder.put(existingPBEPInstance.Key__c, mapPBEPIdToPriorityOrder);
                }
            }

            // 3. Prepare a Map of existing Deal Products so that the PBEP isDuplicate flag can be set properly
            List<OpportunityLineItem> existingDealProducts = [
                    SELECT Id, Key__c, Pricebook_Entry_Period__c
                    FROM OpportunityLineItem 
                    WHERE Key__c IN: keySet
                    AND Product2Id IN: setProductIds
                    AND NR_Deal_Product_Unique_Key__c != null
                    AND Opportunity.NR_Deal_Unique_Key__c != null
            ];

            for (OpportunityLineItem dealProduct : existingDealProducts) {
                if (!mapUniqueKeyToDealProductsPBEPId.containsKey(dealProduct.Key__c)) {
                    mapUniqueKeyToDealProductsPBEPId.put(dealProduct.Key__c, new Set<Id>{dealProduct.Pricebook_Entry_Period__c});
                } else {
                    mapUniqueKeyToDealProductsPBEPId.get(dealProduct.Key__c).add(dealProduct.Pricebook_Entry_Period__c);
                }
            }

            // 4. Set the isDuplicate flags based on deal product present or not
            for (Pricebook_Entry_Period__c newPBEPInstance : lstNewPBEP) {
                if (newPBEPInstance.New_Release__c && newPBEPInstance.Start_Date__c > System.today()) {
                    if (mapUniqueKeyToDealProductsPBEPId.containsKey(newPBEPInstance.Key__c) && mapUniqueKeyToDealProductsPBEPId.get(newPBEPInstance.Key__c) != null) {
                        // Before Insert
                        if (mapOldProducts.isEmpty() && mapOldProducts.size() == 0) {
                            // Set duplicate for newly added PBEP considering that always a new PBEP is inserted with Date range which is greater than the existing PBEP
                            newPBEPInstance.isDuplicate__c = true;
                        }
                    } else {
                        if (mapUniqueKeyToMapOfPBEPIdToPriorityOrder.containsKey(newPBEPInstance.Key__c)) {
                            Map<Id, Decimal> mapPBEPIdToPriorityOrder = mapUniqueKeyToMapOfPBEPIdToPriorityOrder.get(newPBEPInstance.Key__c);
                            for (Id pbepId : mapPBEPIdToPriorityOrder.keySet()) {
                                if (mapExistingPBEPs.containsKey(pbepId)) {
                                    Pricebook_Entry_Period__c existingPBEP = mapExistingPBEPs.get(pbepId);
                                    Decimal priorityOrder = mapPBEPIdToPriorityOrder.get(pbepId);

                                    if (priorityOrder == 1) {
                                        if (existingPBEP.Start_Date__c > System.today() && existingPBEP.Start_Date__c < newPBEPInstance.Start_Date__c) {
                                            newPBEPInstance.isDuplicate__c = true;
                                            if (existingPBEP.isDuplicate__c) {
                                                existingPBEP.isDuplicate__c = false;
                                                existingPBEP.Process_NR_Batch__c = true;
                                                updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                                if (existingPBEP.Product__c != null && !existingPBEP.Product__r.Street_Date_Has_Changed__c) {
                                                    existingPBEP.Product__r.NR_Product_Created__c = true;

                                                    if (!mapUpdateExistingProduct.containsKey(existingPBEP.Product__c)) {
                                                        mapUpdateExistingProduct.put(existingPBEP.Product__c, existingPBEP.Product__r);
                                                    }
                                                }
                                            }
                                        } else if (existingPBEP.Start_Date__c > System.today() && existingPBEP.Start_Date__c > newPBEPInstance.Start_Date__c) {
                                            newPBEPInstance.isDuplicate__c = false;
                                            existingPBEP.isDuplicate__c = true;
                                            existingPBEP.Process_NR_Batch__c = false;
                                            updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                        }
                                    } else {
                                        if (!existingPBEP.isDuplicate__c && existingPBEP.Start_Date__c < System.today() && existingPBEP.Start_Date__c < newPBEPInstance.Start_Date__c) {
                                            newPBEPInstance.isDuplicate__c = false;
                                            existingPBEP.isDuplicate__c = true;
                                            existingPBEP.Process_NR_Batch__c = false;
                                            updateExistingPBEPMap.put(existingPBEP.Id, existingPBEP);
                                        }
                                    }
                                }
                            }
                        } else {
                            // New valid PBEP is inserted and no existing deal Product and no existing PBEP present so set isDuplicate = false
                            newPBEPInstance.isDuplicate__c = false;
                        }
                    }
                }
            }

            System.debug('-updateExistingPBEPMap.size()-in before insert--->'+updateExistingPBEPMap.size());
            if (!updateExistingPBEPMap.isEmpty()) {
                Database.SaveResult[] saveResultList = Database.update(updateExistingPBEPMap.values(), false);
                // Error handling
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Pricebook_Entry_Period__c pbepInstance = updateExistingPBEPMap.values()[i];
                    if (!saveResultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = pbepInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DUPLICATE_PBEP_UPDATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                    }
                }
            }

            System.debug('-mapUpdateExistingProduct.size()---->'+mapUpdateExistingProduct.size());
            if (!mapUpdateExistingProduct.isEmpty() && mapUpdateExistingProduct.size() > 0) {
                Database.SaveResult[] saveResultList = Database.update(mapUpdateExistingProduct.values(), false);
                // Error handling
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Product2 productInstance = mapUpdateExistingProduct.values()[i];
                    if (!saveResultInstance.isSuccess()) {

                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = productInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DUPLICATE_PBEP_PRODUCT_UPDATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                    }
                }
            }

            if (!listErrorLog.isEmpty()) {
                // Inserts all errors into database
                CRM_ErrorLogger.logError(listErrorLog);
            }
        }
    }

    /**
     * This method is used to populate the product set.
     * @name: recalculateDealProductSchedule
     * @param:  Map<Id,Pricebook_Entry_Period__c> (Old PriceBook Entry period records)
     * @param:  List<Pricebook_Entry_Period__c> ( New List Of PriceBook Entry period records)
     * @return null
     * @throws exception-
     */
    public void recalculateDealProductSchedule(Map<Id,Pricebook_Entry_Period__c> mapOldPBEP,List<Pricebook_Entry_Period__c> lstNewPBEP) {
         Set<Id> updatedPbepProdIdSet = new Set<Id>();
        List<Product2> lstProduct = new List<Product2>();
        
        for (Pricebook_Entry_Period__c newPBEP : lstNewPBEP) {
            Pricebook_Entry_Period__c oldPBEP = mapOldPBEP.get(newPBEP.Id);
            if(oldPBEP.Start_Date__c != newPBEP.Start_Date__c && newPBEP.New_Release__c) {
                updatedPbepProdIdSet.add(newPBEP.Product__c);
            }
        }
        if (updatedPbepProdIdSet != null && updatedPbepProdIdSet.size() > 0) {

            // Set the flag for Batch to pick the products for schedule recalculation
            //CRM_AutoEstablishSchedulesHelper.createDealProductSchedule(new Set<Id>(), updatedPbepProdIdSet);
            lstProduct = [SELECT Id,RecalculateSchedules__c from Product2
                          WHERE Id in :updatedPbepProdIdSet AND RecalculateSchedules__c = false ];
            for(Product2 prod : lstProduct){
                prod.RecalculateSchedules__c = true;
            }
            
            if(lstProduct.size()>0 && lstProduct != null ){
                update lstProduct;
            }
             
        }
    }

    /**
     * This method is used to populate the NR_Product_Created__c field of product associated to Digital PBEP.
     * @name: populateNRProductCreatedOfProductForDigitalPBEP
     * @param: List<Pricebook_Entry_Period__c> ( New List Of PriceBook Entry period records)
     * @return void
     * @throws exception-None
     */
    public void populateNRProductCreatedOfProductForDigitalPBEP(List<Pricebook_Entry_Period__c> lstNewPBEP) {
        Set<Id> filteredProductIdsSet = new Set<Id>();
        List<Product2> productsToBeUpdated = new List<Product2>();
        for (Pricebook_Entry_Period__c pbep : lstNewPBEP) {
            if (
                    pbep.Product__c != null &&
                    pbep.New_Release__c &&
                    pbep.isDuplicate__c == false &&
                    pbep.Start_Date__c != null &&
                    pbep.Start_Date__c > System.today() &&
                    (pbep.List_Price__c != null || pbep.Account_Price__c != null)
            ) {
                filteredProductIdsSet.add(pbep.Product__c);
            }
        }
        System.debug('--filteredProductIdsSet->'+filteredProductIdsSet);

        if (!filteredProductIdsSet.isEmpty()) {
            for (Product2 productInstance : 
                [
                    SELECT Id, NR_Product_Created__c,Street_Date_Has_Changed__c, RecordTypeId, Type__c, Country_Code__c 
                    FROM Product2
                    WHERE
                        Id IN: filteredProductIdsSet
                        AND RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                        AND (
                            Type__c =: CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE OR
                            Type__c =: CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE OR
                            (
                                Country_Code__c =: CRM_AppConstants.JAPAN_COUNTRY_CODE AND
                                Type__c =: CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE
                            )
                        )
                        AND isActive = true
                        AND Exclusive_Customer__c = null
                ]
            ) {
                if (productInstance.Street_Date_Has_Changed__c) {
                    productInstance.NR_Product_Created__c = false;
                } else {
                    productInstance.NR_Product_Created__c = true;
                }
                productsToBeUpdated.add(productInstance);
            }

            try {
                System.debug('--productsToBeUpdated->'+productsToBeUpdated);
                if (productsToBeUpdated != null && !productsToBeUpdated.isEmpty()) {
                    update productsToBeUpdated;
                }
            } catch (Exception ex) {
                System.debug('----exception-->'+productsToBeUpdated);
                logAnException(ex, null, CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS);
            }
        }
    }

    /**
     * This method is used to populate the Street_Date_Has_Changed__c field of product associated to
     * Digital PBEP where New Release = true and its Start Date is changed to different month or year.
     * @name: populateStreetdateChangedOfProductForDigitalPBEP
     * @param: List<Pricebook_Entry_Period__c> ( New List Of PriceBook Entry period records)
     * @return void
     * @throws exception-None
     */
    public void populateStreetdateChangedOfProductForDigitalPBEP(Map<Id, Pricebook_Entry_Period__c> mapOldPBEP, List<Pricebook_Entry_Period__c> lstNewPBEP) {
        Set<Id> filteredProductIdsSetScenario2 = new Set<Id>();
        Set<Id> filteredProductIdsSetScenario1 = new Set<Id>();
        List<Product2> productsToBeUpdated = new List<Product2>();
        for (Pricebook_Entry_Period__c newPBEP : lstNewPBEP) {
            Pricebook_Entry_Period__c oldPBEP = mapOldPBEP.get(newPBEP.Id);
            if (
                    newPBEP.Product__c != null &&
                    newPBEP.isDuplicate__c == false &&
                    newPBEP.New_Release__c && newPBEP.Start_Date__c != null &&
                    newPBEP.Start_Date__c > System.today()
            ) {
                if (
                    oldPBEP.Start_Date__c != newPBEP.Start_Date__c
                    /*&&
                    (
                        (oldPBEP.Start_Date__c.year() != newPBEP.Start_Date__c.year()) ||
                        (oldPBEP.Start_Date__c.month() != newPBEP.Start_Date__c.month())
                    )*/
                ) {
                    filteredProductIdsSetScenario2.add(newPBEP.Product__c);
                } else if (!oldPBEP.New_Release__c && newPBEP.New_Release__c) {
                    filteredProductIdsSetScenario1.add(newPBEP.Product__c);
                }
            }
        }
        System.debug('-filteredProductIdsSetScenario1--->'+filteredProductIdsSetScenario1);
        System.debug('-filteredProductIdsSetScenario2--->'+filteredProductIdsSetScenario2);

        if (!filteredProductIdsSetScenario1.isEmpty() || !filteredProductIdsSetScenario2.isEmpty()) {
            for (Product2 productInstance : 
                    [
                        SELECT Id, Street_Date_Has_Changed__c, NR_Product_Created__c, NR_Version__c
                            FROM Product2
                        WHERE
                            (
                                Id IN: filteredProductIdsSetScenario1 OR
                                Id IN: filteredProductIdsSetScenario2
                            )
                            AND RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                            AND (
                                Type__c =: CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE OR
                                Type__c =: CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE OR
                                (
                                    Country_Code__c =: CRM_AppConstants.JAPAN_COUNTRY_CODE AND
                                    Type__c =: CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE
                                )
                            )
                            AND isActive = true
                            AND Exclusive_Customer__c = null
                    ]
            ) {
                if (filteredProductIdsSetScenario1.contains(productInstance.Id)) {
                    if (!productInstance.Street_Date_Has_Changed__c) {
                        productInstance.NR_Product_Created__c = true;
                        productsToBeUpdated.add(productInstance);
                    }
                } else if (filteredProductIdsSetScenario2.contains(productInstance.Id)) {
                    if (productInstance.NR_Product_Created__c) {
                        productInstance.NR_Product_Created__c = false;
                    }
                    Integer version = productInstance.NR_Version__c != null ? Integer.valueOf(productInstance.NR_Version__c) : 0;
                    productInstance.Street_Date_Has_Changed__c = true;
                    productInstance.NR_Version__c = version++;
                    productsToBeUpdated.add(productInstance);
                }
            }

            System.debug('----productsToBeUpdated.size()-->'+productsToBeUpdated.size());
            try {
                if (productsToBeUpdated != null && !productsToBeUpdated.isEmpty()) {
                    update productsToBeUpdated;
                }
            } catch (Exception ex) {
                System.debug('----exception-->'+productsToBeUpdated);
                logAnException(ex, null, CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS);
            }
        }
    }

     /**
     * This method is used to create Price Book Entry
     * @name: createPBENTRYForNewPBEPeriod
     * @param: List<Pricebook_Entry_Period__c> lstNewPBEP ( New List Of PriceBook Entry period records)
     * @return void
     * @throws exception-None
     */
    public void createPBENTRYForNewPBEPeriod(List<Pricebook_Entry_Period__c> lstNewPBEP) {
        
        Id standardPriceBookId = null;
        Set<String> prdPriceCurrSet = new Set<String>();
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        List<Database.SaveResult> insertResult = new List<Database.SaveResult>();
        Map<Integer,Pricebook_Entry_Period__c> mapPBEP = new Map<Integer,Pricebook_Entry_Period__c>();
        set<Pricebook_Entry_Period__c> setPBEP = new set<Pricebook_Entry_Period__c>();
        //Defect#4715 - add the actual error instead of custom label error.Label.CRM_Error_On_PBEP
        // create a map as key and error message and another map to hold PBEP, so that we can get the exact error message when something goes wrong
        //if a map kye is Id and something fails for this key, we get the error message from another Map for key ID
        map<Id,String> errorMapPBEP = new map<Id,String>();
        //Defect#4715 ends
        PricebookEntry PBEntry;
        //PricebookEntry standardPBEntry;
        Pricebook_Entry_Period__c currentPeriod;
    
        String priceBookEntryUnique ;
        String productID;
        String currencyCode;
        String priceBook;
    
        
         if(Test.isRunningTest()) {
                standardPriceBookId = Test.getStandardPricebookId();
            }
            else {
                List<PriceBook2> listPriceBook2 = getStandardPricebook();
                standardPriceBookId = listPriceBook2 != null && listPriceBook2.size() > 0 ? listPriceBook2[0].Id : null;
            }
        
        //-------------
        
        //Add predifined pricebook entries
        prdPriceCurrSet = getPriceBookEntries(lstNewPBEP,standardPriceBookId);
        //-------------
         Integer i = 0;
         // Create Price book entry 
         for(Pricebook_Entry_Period__c pbep : lstNewPBEP){
             
             //creating standard price book entry if dont exist 
             productID = pbep.Product__c ;
             currencyCode = pbep.CurrencyIsoCode ;
             priceBook = standardPriceBookId ;
             priceBookEntryUnique = productID + priceBook + currencyCode ;
            
            if(!prdPriceCurrSet.contains(priceBookEntryUnique)) {
                PBEntry = mapPBE(priceBook,productId,currencyCode);
                lstPriceBookEntry.add(PBEntry);
                prdPriceCurrSet.add(priceBookEntryUnique);
                mapPBEP.put(i,pbep);
                i++;
            }
                
            //creating custom price book entry if dont exist 
            priceBook = pbep.Price_Book__c ;
            priceBookEntryUnique = productID + priceBook + currencyCode ;
        
            if(!prdPriceCurrSet.contains(priceBookEntryUnique)) {
                PBEntry = mapPBE(priceBook,productId,currencyCode);
                lstPriceBookEntry.add(PBEntry);
                prdPriceCurrSet.add(priceBookEntryUnique);
                mapPBEP.put(i,pbep);
                i++;
            }
         }
        //System.debug('mapPBEP*** ------------->' + mapPBEP);
        System.debug('prdPriceCurrSet ------------->' + prdPriceCurrSet );
        try {
                if (lstPriceBookEntry != null && !lstPriceBookEntry.IsEmpty()){
                    insertResult = database.insert(lstPriceBookEntry, false);
                    
                    //Defect#4715 added paramter as 'errorMapPBEP'
                    setPBEP = createErrorLogList(insertResult, 'Price Book Entry',mapPBEP,errorMapPBEP);
                }
        } catch (Exception ex) {
            System.debug('----exception-->'+ ex);
            logAnException(ex, null, CRM_AppConstants.FUNCTIONAL_MODULE_CAS_PRODUCT_CREATION_BATCH);
        }
        //System.debug('setPBEP*** ------------->' + setPBEP);
        for(Pricebook_Entry_Period__c pbepError : setPBEP){
            //Defect#4715 added message from database.error
            pbepError.addError(errorMapPBEP.get(pbepError.Id));
            //Defect#4715 ends
        }
    }
    
    /**
 *  Fetch the existing priceBookEntry for the said combination
 *  @name getPriceBookEntries
 *  @param Set<String> uniqueKey
 *  @return List of PriceBookEntries
 *  @throws Exception None
 */

private Set<String> getPriceBookEntries(List<Pricebook_Entry_Period__c> lstNewPBEP, Id standardPriceBookId){
    
    Set<String> setCurrencyCodes = new Set<String>();
    Set<Id> setProductsIds = new Set<Id>();
    Set<Id> setPricebookIds = new Set<Id>();
    Set<String> prdPriceCurrSet = new Set<String>();
    
    //Standard
    setPricebookIds.add(standardPriceBookId);
    
    //Creating set of product, pricebooks, currencies t fetch the PriceBookEntries
    for(Pricebook_Entry_Period__c pbep : lstNewPBEP){

        setProductsIds.add(pbep.Product__c);
        setPricebookIds.add(pbep.Price_Book__c);
        setCurrencyCodes.add(pbep.CurrencyIsoCode);
    }
    
    Map<String,PricebookEntry> mapPriceBookEntries = new Map<String,PricebookEntry>();
    List<PricebookEntry> pbentry = new List<PricebookEntry>();
                                
    for(PricebookEntry pbe : [select Id, Product2Id, CurrencyIsoCode, Pricebook2Id from PricebookEntry where Pricebook2Id != null and Product2Id != null and 
                                Pricebook2Id IN: setPricebookIds and Product2Id IN: setProductsIds and CurrencyISOCode IN: setCurrencyCodes]) {
                                
        //Unique Key with combination of Product,PriceBook and CurrencyISO Code is  created to get limited matching records
        String mapRecKey = String.valueOf(pbe.Product2Id) + String.valueOf(pbe.Pricebook2Id) + pbe.CurrencyIsoCode;
        if(!prdPriceCurrSet.contains(mapRecKey)){
            prdPriceCurrSet.add(mapRecKey);
        }
    }      
    //System.debug('prdPriceCurrSet query ------------->' + prdPriceCurrSet );
    return prdPriceCurrSet;
}

    public List<Pricebook2> getStandardPricebook() {

        List<Pricebook2> standardPricebookList = [SELECT ID FROM Pricebook2 WHERE IsStandard = true];//isActive = true
        return standardPricebookList;
    }

    public PricebookEntry mapPBE(String priceBook,String productId,String currencyCode){
        PricebookEntry customPBEntry = new PricebookEntry();
        customPBEntry.IsActive = true;
        customPBEntry.Product2Id = productId;       
        customPBEntry.CurrencyIsoCode = currencyCode;
        customPBEntry.UnitPrice = 0;
        customPBEntry.Pricebook2Id = priceBook;
        return customPBEntry;
    }

    public set<Pricebook_Entry_Period__c> createErrorLogList(List<Database.SaveResult> insertResult, String entityName,Map<Integer,Pricebook_Entry_Period__c> mapPBEP,map<Id,string> errorMapPBEP){
    
        set<Pricebook_Entry_Period__c> setPBEP = new set<Pricebook_Entry_Period__c>();
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        Integer i;
        Database.SaveResult sr;
        for(i=0 ; i < insertResult.size() ; i++) {
            sr = insertResult[i];
        //for(Database.SaveResult sr : insertResult) {
            if(!sr.isSuccess()){
                CRM_ErrorLogger.ErrorLog errorLogInstance = logAnException(sr.getErrors(), sr.getId(), entityName);
                errorLogs.add(errorLogInstance);
                //System.debug('inside error *** ------------->' + i);
                if(mapPBEP != null && mapPBEP.containsKey(i)){
                    setPBEP.add(mapPBEP.get(i));
                    //defect4715 changes - 
                    for(Database.Error err : sr.getErrors()){
                        errorMapPBEP.put(mapPBEP.get(i).Id,err.getMessage().left(200));
                    }
                    //Defect#4715 ends
                }
            }
        }

        CRM_ErrorLogger.logError(errorLogs); 
        return setPBEP;
    }

    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    private void logAnException(Exception ex, Id recordId, String moduleName){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null)
            errorLogInstance.recordId = recordId;
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLogInstance.functionalModule = moduleName;
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();
        listErrorLog.add(errorLogInstance);
        CRM_ErrorLogger.logError(listErrorLog);
    }

    /*
     *  This method will take the exception occured as an input and forward it to the common utility class. 
     *  @name: logAnException
     *  @param: Exception ex
     *  @return: void 
     */
    public CRM_ErrorLogger.ErrorLog logAnException(List<Database.Error> errors, Id recordId, String entityName){
        String lineNumber = '';
        String errorMessage = '';
        String statusCode = '';
        
        //List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        
        if (recordId != null) {
            errorLogInstance.recordId = recordId;
        }
        
        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CAS_PRODUCT_CREATION_BATCH;
        errorLogInstance.className = 'CRM_PBEPHandler';
        
        for(Database.Error err : errors){
            //lineNumber += ' Line Number: ' + String.valueOf(err.getLineNumber());
            //stackTrace += ' Stack Trace: ' + err.getStackTraceString();
            statusCode += ' Error Code: ' + String.valueOf(err.getStatusCode());
            errorMessage += ' Error Message: ' + err.getMessage().left(200) + '**entityName: ' + entityName;
        }
        errorLogInstance.lineNumber = lineNumber;
        errorLogInstance.errorMessage = errorMessage;
        errorLogInstance.stackTrace = statusCode;
        //errorLogInstance.stackTrace = stackTrace;
        return errorLogInstance;
    }
    
}