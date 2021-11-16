/**
   @Author-Cognizant Technology Solutions
   @name-CRM_DealHandler
   @CreateDate- 14 Mar 2016
   @Description-
   @Version-1.0
   @reference-None
*/
// Added without sharing so that user can follow the records for others as well without giving Modify All permission
public without sharing class CRM_CoopBudgetHandler {
    
    /**
    *  @Description - Method to upsert Deal and Deal products
    *  @name - upsertDealAndDealProducts
    *  @return - void
    */
    public static void upsertDealAndDealProducts(Map<Id,Coop_Budget__c > oldMapCoopBudgets,Map<Id,Coop_Budget__c > newMapCoopBudgets) {
        
        List<Coop_Budget__c> lstCoopBudgets = new List<Coop_Budget__c>();
        for(Coop_Budget__c cb : newMapCoopBudgets.values()){
            if(cb.Customer__c != null && cb.Product__c != null && cb.Calendar_Month__c != null && cb.Event_Name__c != null && cb.Amount__c != null){
                if(oldMapCoopBudgets != null && 
                   (cb.Customer__c != oldMapCoopBudgets.get(cb.id).Customer__c || cb.Product__c != oldMapCoopBudgets.get(cb.id).Product__c ||
                    cb.Calendar_Month__c != oldMapCoopBudgets.get(cb.id).Calendar_Month__c || cb.Event_Name__c != oldMapCoopBudgets.get(cb.id).Event_Name__c ||
                    cb.Amount__c != oldMapCoopBudgets.get(cb.id).Amount__c)
                ){
                    lstCoopBudgets.add(cb);
                }else{
                    lstCoopBudgets.add(cb);
                }
            }
        }
        
        if(!lstCoopBudgets.isEmpty()){
            createOrUpdateDealAndDealProducts(lstCoopBudgets,newMapCoopBudgets);
        }
    }
    
    /**
    *  @Description - Method to upsert Deal and Deal products
    *  @name - createOrUpdateDealAndDealProducts
    *  @return - void
    */
    public static void createOrUpdateDealAndDealProducts(List<Coop_Budget__c> lstCoopBudgets,Map<Id,Coop_Budget__c > newMapCoopBudgets) {
        
        Map<String, Opportunity> mapDealIdToInstance = new Map<String, Opportunity>();
        Set<Id> setSuccessDealIds = new Set<Id>();
        Map<String,Coop_Budget__c> mapDealIdToCoopBudgets = new Map<String,Coop_Budget__c>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> priceBookIds = new Set<Id>();
        Set<String> setCurrencyISOCodes = new Set<String>();
        Map<String,PricebookEntry> mapOfPricebookEntries = new Map<String,PricebookEntry>();
        Map<String, List<Coop_Budget__c>> mapDealUniqueKeyToCoopBudgetList = new Map<String, List<Coop_Budget__c>>();
        
        //Create Deals
        for(Coop_Budget__c cb : lstCoopBudgets){
            String uniqueKey = cb.Customer__c +'-'+ cb.Calendar_Month__c +'-'+ cb.Event_Name__c.toLowerCase();
            if (!mapDealIdToInstance.containsKey(uniqueKey)) {
                Opportunity deal = new Opportunity();
                deal.name = getDealName(cb);
                //deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
                deal.recordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
                deal.accountId = cb.Customer__c;
                deal.currencyISOCode = cb.currencyISOCode;
                deal.External_Id__c = uniqueKey;
                deal.Promo_Start_Date__c = getCalendarMonthtDate(cb,true);
                deal.Promo_End_Date__c = getCalendarMonthtDate(cb,false);
                deal.Start_Date__c = getCalendarMonthtDate(cb,true);
                deal.CloseDate = getCalendarMonthtDate(cb,false);
                deal.OwnerId = Id.valueOf(cb.Account_Games_Owner__c);
                mapDealIdToInstance.put(uniqueKey, deal);
            }
            if (mapDealUniqueKeyToCoopBudgetList.containsKey(uniqueKey)) {
                mapDealUniqueKeyToCoopBudgetList.get(uniqueKey).add(cb);
            } else {
                mapDealUniqueKeyToCoopBudgetList.put(uniqueKey, new List<Coop_Budget__c>{cb});
            }
        }
        System.debug('--mapDealIdToInstance-->'+mapDealIdToInstance);

        //Upsert deals
        if(!mapDealIdToInstance.isEmpty()){
            Database.UpsertResult[] result = Database.Upsert(mapDealIdToInstance.values(), Opportunity.External_Id__c, false);
            upsertDMLResultForDeals(result,mapDealIdToInstance.values(),setSuccessDealIds,mapDealUniqueKeyToCoopBudgetList,mapDealIdToCoopBudgets,productIds,priceBookIds,setCurrencyISOCodes);
        }
        
        if(!setSuccessDealIds.isEmpty()){
            
            mapOfPricebookEntries = getPricebookEntries(productIds,priceBookIds,setCurrencyISOCodes);
            
            //Create deal products
            List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lstExistingDealProducts = [SELECT Id, Opportunity.External_Id__c, Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :setSuccessDealIds];
            Map<String, OpportunityLineItem> mapEsitingDealProducts = new Map<String, OpportunityLineItem>();
            for (OpportunityLineItem dealProduct : lstExistingDealProducts) {
                mapEsitingDealProducts.put(dealProduct.Opportunity.External_Id__c +'-'+ dealProduct.Product2Id, dealProduct);
            }
            System.debug('--mapEsitingDealProducts--->'+mapEsitingDealProducts);
            
            for(Opportunity opp : [SELECT Id,Pricebook2Id,currencyISOCode,AccountId,Start_Date__c,CloseDate,External_Id__c From Opportunity WHERE Id IN :setSuccessDealIds]){
                List<Coop_Budget__c> cbList = mapDealUniqueKeyToCoopBudgetList.containsKey(opp.External_Id__c) ? mapDealUniqueKeyToCoopBudgetList.get(opp.External_Id__c) : null;
                System.debug('--cbList--->'+cbList);
                if(!cbList.isEmpty()){
                    for (Coop_Budget__c cb : cbList) {
                        String mapKey = opp.Pricebook2Id+'-'+cb.Product__c+'-'+opp.currencyISOCode;
                        if(mapOfPricebookEntries.containsKey(mapKey)){
                            OpportunityLineItem dp = new OpportunityLineItem();
                            dp.OpportunityId = opp.Id;
                            dp.Co_op_Budget__c = cb.Amount__c;
                            dp.Start_Date__c = opp.Start_Date__c;
                            dp.End_Date__c = opp.CloseDate;
                            dp.Reason__c = CRM_AppConstants.COOP_REASON_BUDGET;
                            dp.External_Id__c = opp.External_Id__c+'-'+cb.Product__c;
                            if (!mapEsitingDealProducts.containsKey(dp.External_Id__c)) {
                                dp.PricebookEntryId = mapOfPricebookEntries.get(mapKey).Id;
                                dp.Product2Id = cb.Product__c;
                            }
                            dp.quantity = 1;
                            dp.unitprice = 0;
                            lstDealProducts.add(dp);
                        }else{
                            cb.addError(system.label.CRM_Upload_Message_NotFound);
                        }
                    }
                }
            }
            
            //upsert deal products
            if(!lstDealProducts.isEmpty()){
                Database.UpsertResult[] result = Database.Upsert(lstDealProducts, OpportunityLineItem.External_Id__c, false);
                upsertDMLResultForDealProducts(result,lstDealProducts,mapDealIdToCoopBudgets);
            }
        }
    }
    
    /**
    *  @Description - Method to make deal name
    *  @name - getDealName
    *  @return - String
    */
    public Static String getDealName(Coop_Budget__c cb){
        List<String> lstMC = cb.Calendar_Month__c.split('-');
        String calendarMonth = (lstMC.size() > 1 ? (lstMC[1]+'-') : '')+(lstMC.size() > 0 ? lstMC[0] : '');
        String dealName = cb.Account_Name__c+(cb.Event_Name__c != CRM_AppConstants.COOP_BUDGET_DEFAULT_EVENT_NAME ? ('-'+cb.Event_Name__c) : '')+'-'+calendarMonth;
        return dealName;
    }
    
     /**
    *  @Description - Method to get start and end date of calendar month
    *  @name - getCalendarMonthtDate
    *  @return - Date
    */
    public Static Date getCalendarMonthtDate(Coop_Budget__c cb,Boolean isStartDateReturn){
        List<String> monthAndYear = cb.Calendar_Month__c.split('-');
        Date calendarDate;
        if(monthAndYear.size() == 2 && monthAndYear[0].length() == 4 && monthAndYear[1].length() == 2){
            if(isStartDateReturn){
                calendarDate = date.valueOf(cb.Calendar_Month__c+'-1');
            }else{
                Integer numberOfDays = Date.daysInMonth(Integer.valueof(monthAndYear[0]),Integer.valueof(monthAndYear[1]));
                calendarDate = Date.newInstance(Integer.valueof(monthAndYear[0]),Integer.valueof(monthAndYear[1]), numberOfDays);
            }
        }
        return calendarDate;
    }
    
     /**
     *  Method to upsert success/failure result on the record after dml-insert/update  
     *  @name upsertDMLResultForDeals
     *  @return None
     *  @throws None
    */
    public static void upsertDMLResultForDeals(
            list<Database.UpsertResult> results,List<Opportunity> lstDeals,Set<Id> setSuccessDealIds,
            Map<String, List<Coop_Budget__c>> mapDealUniqueKeyToCoopBudgetList,Map<String,Coop_Budget__c> mapDealIdToCoopBudgets,
            Set<Id> productIds,Set<Id> priceBookIds,Set<String> setCurrencyISOCodes) {
                
        for(Integer i=0;i<results.size();i++){
            Opportunity deal = lstDeals.get(i);
            List<Coop_Budget__c> cbList = mapDealUniqueKeyToCoopBudgetList.get(deal.External_Id__c);
            
            for (Coop_Budget__c cb : cbList) {
                if (!results.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = results.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    System.debug('--deal failedDML-->'+failedDML);
                    cb.addError(failedDML);

                }else{
                    setSuccessDealIds.add(deal.Id);
                    mapDealIdToCoopBudgets.put(deal.Id + '-' + cb.Product__c, cb);
                    productIds.add(cb.Product__c);
                    priceBookIds.add(cb.Account_Pricebook__c);
                    setCurrencyISOCodes.add(cb.currencyISOCode);
                }
            }
        }
    }
    
    /**
     *  Method to upsert success/failure result on the record after dml-insert/update  
     *  @name upsertDMLResultForDealProducts
     *  @return None
     *  @throws None
    */
    public static void upsertDMLResultForDealProducts(
            list<Database.UpsertResult> results,List<OpportunityLineItem> lstDealProducts,Map<String,Coop_Budget__c> mapDealIdToCoopBudgets) {
                
        for(Integer i=0;i<results.size();i++){
            OpportunityLineItem dealProduct = lstDealProducts.get(i);
            Coop_Budget__c cb = 
                mapDealIdToCoopBudgets.containsKey(dealProduct.OpportunityId +'-'+dealProduct.Product2Id) 
                ? mapDealIdToCoopBudgets.get(dealProduct.OpportunityId +'-'+dealProduct.Product2Id) 
                : null;
            System.debug('--cb-->'+cb);
            if (!results.get(i).isSuccess() && cb != null){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                System.debug('-deal product-failedDML-->'+failedDML);
                cb.addError(failedDML);
            }
        }
    }
    
    /**
     *  Method to fetch priceBookEntries   
     *  @name getPricebookEntries
     *  @param productIds, setCurrencyISOCodes, priceBokIds set 
     *  @return map<String,PricebookEntry>
     *  @throws None
     */
    public static map<String,PricebookEntry> getPricebookEntries(Set<Id> productIds,Set<Id> priceBokIds,Set<String> setCurrencyISOCodes) {
        map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
        for(PricebookEntry pbEntry : [SELECT Id,Product2.ProductCode,Product2Id,Pricebook2Id,CurrencyIsoCode 
                                      From PricebookEntry 
                                      WHERE Product2Id IN :productIds AND isActive = true AND 
                                      Pricebook2Id IN :priceBokIds AND CurrencyIsoCode IN :setCurrencyISOCodes]) {
            String strKey = pbEntry.Pricebook2Id+'-'+pbEntry.Product2Id+'-'+pbEntry.CurrencyIsoCode;
            pricebookEntryMap.put(strKey,pbEntry);
        }
        return pricebookEntryMap;
    }
}