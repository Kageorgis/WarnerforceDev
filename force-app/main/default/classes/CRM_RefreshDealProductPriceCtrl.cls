/**
   @Author Cognizant
   @name CRM_RefreshDealProductPriceCtrl
   @CreateDate 07 Jan 2016
   @Description - to update deal-product prices if a product is subsequently availed 
                – to only be availed for non-Approved deals
   @Version <1.0>
   @reference Requirement#170
*/

global with sharing class CRM_RefreshDealProductPriceCtrl {
    
    global CRM_RefreshDealProductPriceCtrl(ApexPages.StandardController stdCon){}
    
    /**
     *  method to refresh/update the pricing details for the products associated to incoming deal ids
     *  @name refreshProductPrices
     *  @param dealIds - Ids of the deals where product pricing details to be refreshed
     */
    @RemoteAction 
    global static void refreshProductPrices(Id[] dealIds) {
        try {
        
            if(CRM_Functional_Permissions__c.getInstance().Refresh_Deal_Product_Permission__c) {
                throw new PricingUpdateException(Label.CRM_Refersh_NoAccessError);
            }
            Opportunity[] dealList = [Select Id, StageName,Market_Type__c,Sales_Organisation__c from Opportunity where (Id IN:dealIds)];
            
            if(!dealList.isEmpty() && (dealList[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || dealList[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)){
                throw new PricingUpdateException(Label.CRM_RefreshProductPrice_DealStageError);
            }
            
            //US#895 - throw validation to prevent users from refreshing pricing if the Product Market Type in the deal is Rental
            if(!dealList.isEmpty() && dealList[0].Market_Type__c == CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE && dealList[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE){
                throw new PricingUpdateException(Label.CRM_RefreshProductPrice_MarketTypeError);
            }

            OpportunityLineItem[] listProductsToUpdate = new OpportunityLineItem[]{};
            CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
            //List<OpportunityLineItemSchedule> lstDealProductScheduleToDelete = new List<OpportunityLineItemSchedule>();
            Map<Id, OpportunityLineItem> mapDealProductIdToInstance = new Map<Id, OpportunityLineItem>();
            Map<String,Account_Plan__c> mapDatedAccountPlansFetched = new Map<String,Account_Plan__c>();
            
            //US#895 - get Sales org or Digital country code for which restrict the refresh promo price based on Account price.
            string salesOrgsToRestrict = (CRM_Restrict_Refresh_Deal_Product_Prices__c.getInstance('Restrict Refresh prices on DP') != null)?CRM_Restrict_Refresh_Deal_Product_Prices__c.getInstance('Restrict Refresh prices on DP').Sales_Organisation__c:null;
            Set<String> setsalesOrgsToRestrict = new Set<String>(salesOrgsToRestrict.split(';'));
            
            string digitalCountryCodeToRestrict = (CRM_Restrict_Refresh_Deal_Product_Prices__c.getInstance('Restrict Refresh prices on DP') != null)?CRM_Restrict_Refresh_Deal_Product_Prices__c.getInstance('Restrict Refresh prices on DP').Digital_Country_Code__c:null;
            Set<String> setdigitalCountryCodeToRestrict = new Set<String>(digitalCountryCodeToRestrict.split(';'));
           
            //US#895 - end
            
            // get the list of associated deal products
            //US#1004 start
            OpportunityLineItem[] listDealProducts = [Select Id,Invalid_Deal_Product__c,Price_Tier__c ,Pricebook_Entry_Period__r.Client_Avail__r.Local_DVD_Release_Date__c, /*US#1004*/Quantity,OpportunityId, Opportunity.Pricebook2Id, Opportunity.Start_Date__c,
                               Opportunity.AccountId, Opportunity.RecordTypeId,Opportunity.CurrencyISOCOde,Opportunity.Sales_Organisation__c,Opportunity.Storefront_Account__c,Opportunity.Account.Digital_Country_Code__c,Pricing__c,product2.Country_Code__c ,product2.Product_Format__c,product2.Tittle_Content_Type__c ,product2.Product_Market__c ,//US#895  
                               Opportunity.CloseDate, Manually_Schedule__c,Product2Id, UnitPrice, ListPrice__c ,Minimum_Price__c,Customer_Retail_Price__c,Replen_Quantity__c,Target_Quantity__c,File_Discount__c,//Added for Defect#4554
                               promoted_Price__c,Account_Price__c,Discount,Pricebook_Entry_Period__c, Product2.RecordTypeId,Opportunity.StageName,NR_Deal_Product_Unique_Key__c,UniquePublishKey__c,
                               (Select Id, Type,OpportunityLineItemId, Description, Quantity, ScheduleDate, Revenue  From OpportunityLineItemSchedules)
                               from OpportunityLineItem
                               where (OpportunityId IN:dealIds) AND ((Opportunity.StageName =: CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT and NR_Deal_Product_Unique_Key__c = null) OR 
                                (Opportunity.StageName !=: CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT))];
            
			//US#1004 end
            if(listDealProducts.isEmpty()){
                throw new PricingUpdateException(Label.CRM_RefreshProductPrice_NoDealProductsError);
            }
            else{
                mapDatedAccountPlansFetched = initializeAccountPlans(listDealProducts);
            }
			 //US#1004 start
            Map<Id,Integer> mapDealProductAge = new Map<Id,Integer>();
            Map<Id,Boolean> mapDealProIdPromoPricingChange =new Map<id,Boolean>();
            //Get all New Products into Map for throwing validation error message.
            Map<Id,OpportunityLineItem> mapNewDealProducts = new map<Id,OpportunityLineItem>(listDealProducts);
            //Fetch all Deal Product required field for key creation only for Digital Deals
            map<Id,OpportunityLineItem> mapDealProducts = new map<Id,OpportunityLineItem>();
            map<Id,Opportunity> mapOfDeals = new map<Id,Opportunity>();
            Set<Id> setAccountIds =new Set<Id>();
            List<OpportunityLineItem> filteredDealProds = new List<OpportunityLineItem>();
            //US#1004 end
            // create and populate a list of deal wrappers to calculate the pricing                   
            for(OpportunityLineItem oli : listDealProducts) {
              //US1004 ankita start
                if(oli.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && oli.Price_Tier__c != null ){
                
                    if(oli.Opportunity.Storefront_Account__c!= null){   
    	                        setAccountIds.add(oli.Opportunity.Storefront_Account__c);
    	                        mapOfDeals.put(oli.OpportunityId,oli.Opportunity);
                    }
                    filteredDealProds.add(oli);
    	            mapDealProIdPromoPricingChange.put(oli.Id,true); 
    	            if(oli.Pricebook_Entry_Period__r.Client_Avail__r.Local_DVD_Release_Date__c !=null ){
    					Date locaDataDate = oli.Pricebook_Entry_Period__r.Client_Avail__r.Local_DVD_Release_Date__c;
    					Integer monthsBetween = math.abs(locaDataDate.monthsBetween(oli.Opportunity.Start_Date__c));
    					Date dealStartDate = oli.Opportunity.Start_Date__c;
    					if((dealStartDate.day() < locaDataDate.day() && dealStartDate > locaDataDate) || 
    						   (locaDataDate.day() < dealStartDate.day() && locaDataDate > dealStartDate)  
    					){
    						monthsBetween--;
    					}
    					mapDealProductAge.put(oli.id,monthsBetween);
    				}
                }
                 
                listDealWrappers.add(createDealWrapper(oli));
            //US1004 ankita end
            }
            //US1004 ankita start Call the PricingUtility method to validate and throw the error message if any.
            CRM_PricingUtility.validatePricing(mapOfDeals,setAccountIds, filteredDealProds,mapNewDealProducts,mapDealProIdPromoPricingChange,mapDealProductAge);
            //US1004 ankita end
            
            // Instantiate pricing handler to calcualte the updated price of the products 
            CRM_ProductPricingHandler pricingHandler = new CRM_ProductPricingHandler(listDealWrappers);
            for(CRM_ProductPricingHandler.DealWrapper dw : listDealWrappers) {
                Pricebook_Entry_Period__c pbep = pricingHandler.getProductDatedPricebookEntryPeriod(dw);
                
                // if the new price is different than the current price for a deal product, update it and mark the
                // product for update with new prices
                if (pbep != null) {
                    Boolean isUpdateflag = false;  
                    if(dw.dealProduct.Pricebook_Entry_Period__c != pbep.id)
                    {
                        dw.dealProduct.Pricebook_Entry_Period__c = pbep.id;

                        // Recalculate automatic schedules for all manually created NR Deal Products related to Digital Products
                        if (dw.dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && !dw.dealProduct.Manually_Schedule__c) {
                            mapDealProductIdToInstance.put(dw.dealProduct.Id, dw.dealProduct);
                        }
                        isUpdateflag = true;
                    }
                    Decimal listPrice = 
                        dw.dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                        ? (pbep.Account_Price__c != null ? pbep.Account_Price__c : pbep.List_Price__c)
                        : pbep.List_Price__c;
                    if(dw.dealProduct.ListPrice__c != listPrice)
                    {
                        dw.dealProduct.ListPrice__c = listPrice;
                        isUpdateflag = true;
                    }
                    if(dw.dealProduct.Minimum_Price__c != pbep.Minimum_Price__c)
                    {
                        dw.dealProduct.Minimum_Price__c = pbep.Minimum_Price__c;
                        isUpdateflag = true;
                    }
                    if(dw.dealProduct.Customer_Retail_Price__c != pbep.Retail_Price__c)
                    {
                        dw.dealProduct.Customer_Retail_Price__c = pbep.Retail_Price__c;
                        isUpdateflag = true;
                    }
                    Decimal accntPrice = pricingHandler.getAccountPrice(dw);
                    if(dw.dealProduct.Account_Price__c != accntPrice && dw.dealProduct.UniquePublishKey__c == null)
                    {
                        dw.dealProduct.Account_Price__c = accntPrice;
                        isUpdateflag = true;
                    }
                    
                    //Defect#4554 : Update file discount on deal product on refresh prices button - start
                    Decimal fileDiscount = pricingHandler.getFileDiscount(dw);
                    //defect#4718 - removed the condition dw.dealProduct.NR_Deal_Product_Unique_Key__c == null 
                    if(fileDiscount != null && dw.dealProduct.UniquePublishKey__c == null 
                    &&  
                       (!setsalesOrgsToRestrict.isEmpty() && 
                        !setdigitalCountryCodeToRestrict.isEmpty() &&
                        !setsalesOrgsToRestrict.contains(dw.dealProduct.Opportunity.Sales_Organisation__c) &&
                        !setdigitalCountryCodeToRestrict.contains(dw.dealProduct.Opportunity.Account.Digital_Country_Code__c)
                       )
                    ){
                        dw.dealProduct.File_Discount__c = fileDiscount;
                        isUpdateflag = true;
                    }
                    //Defect#4554 : end
                    
                    //US#895 - Promoted Price on Deal Products after refreshing prices should show the new account price -start 
                    system.debug('sales ogr---'+setsalesOrgsToRestrict.contains(dw.dealProduct.Opportunity.Sales_Organisation__c));
                    //US#1004 start
                    if(dw.dealProduct.UniquePublishKey__c == null && 
                        dw.dealProduct.Product2.RecordTypeId != CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                        (!setsalesOrgsToRestrict.isEmpty() && 
                      //  !setdigitalCountryCodeToRestrict.isEmpty() && 
                        !setsalesOrgsToRestrict.contains(dw.dealProduct.Opportunity.Sales_Organisation__c) //&&
                    //US#1004 changes to comment !setdigitalCountryCodeToRestrict.contains(dw.dealProduct.Opportunity.Account.Digital_Country_Code__c)
                       )
                    )
                    {
                        dw.dealProduct.promoted_Price__c = dw.dealProduct.Account_Price__c;
                        isUpdateflag = true;
                    }
                    if(dw.dealProduct.Price_Tier__c !=null && dw.dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL ){
                        isUpdateflag = true;
                    }//US#1004 end
                    
                    //US#895 - end
                    
                    // As discussed with mark dated 13 april we are scarpping these
                    // if user has changed the promo price 
                    /*if(((dw.dealProduct.Discount==null) || (dw.dealProduct.Discount==0))  && !dw.dealProduct.Manually_Schedule__c)
                    {
                        if(dw.dealProduct.OpportunityLineItemSchedules != null && dw.dealProduct.OpportunityLineItemSchedules.size() > 0) {
                            lstDealProductScheduleToDelete.addAll(dw.dealProduct.OpportunityLineItemSchedules);
                        }
                        mapDealProductIdToInstanceFuture.put(dw.dealProduct.Id, dw.dealProduct);

                        //dw.dealProduct.promoted_Price__c =  (pbep.Suggested_Price__c != null ? pbep.Suggested_Price__c :  dw.dealProduct.Account_Price__c);
                        dw.dealProduct.promoted_Price__c =  dw.dealProduct.Account_Price__c;
                        dw.dealProduct.UnitPrice = dw.dealProduct.promoted_Price__c;
                        system.debug('******dw.dealProduct.UnitPrice'+dw.dealProduct.UnitPrice);
                        system.debug('******dw.dealProduct.promoted_Price__c'+dw.dealProduct.promoted_Price__c);
                        isUpdateflag = true;                        
                    }*/
                    
                    //*****quantity update
                    Decimal calculatedQuantity = 0;
                    String KeyAccntProduct = dw.dealProduct.Opportunity.AccountId + ''+ dw.dealProduct.Product2ID;
                    Account_Plan__c accountPlanInstance = new Account_Plan__c();
                    if (
                            ((dw.dealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT && dw.dealProduct.NR_Deal_Product_Unique_Key__c == null) || 
                            (dw.dealProduct.Opportunity.StageName != CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT && dw.dealProduct.NR_Deal_Product_Unique_Key__c != null)) && 
                            mapDatedAccountPlansFetched.containsKey(KeyAccntProduct)
                    ) { /*
                        if (
                                ((dw.dealProduct.OpportunityLineItemSchedules.size() == 0 && dw.dealProduct.Manually_Schedule__c) ||
                                !dw.dealProduct.Manually_Schedule__c)
                        ) {  */
                            accountPlanInstance = mapDatedAccountPlansFetched.get(KeyAccntProduct);
                            if (
                                    accountPlanInstance != null && accountPlanInstance.PublishedTarget__c != null &&
                                    dw.dealProduct.Account_Price__c != null && dw.dealProduct.Account_Price__c > 0 &&
                                    accountPlanInstance.PublishedTarget__c > 0
                            ) {
                                calculatedQuantity = Math.ceil(accountPlanInstance.PublishedTarget__c / dw.dealProduct.Account_Price__c);
                                System.debug('--in deal prod if-->');
                            } 
                            /*else {
                                    System.debug('--in deal prod else-->');
                                    // Set quantity 1 if target record or its target revenue value is not present
                                    calculatedQuantity = 1;
                                 }*/
                            System.debug('calculatedQuantity--->'+calculatedQuantity);
                            //UAT DEFECT NO 3051
                            if(calculatedQuantity > 0) {
                                  dw.dealProduct.Target_Quantity__c = calculatedQuantity;
                            }
                            /*if (!dw.dealProduct.Manually_Schedule__c && dw.dealProduct.OpportunityLineItemSchedules.size() > 0 && calculatedQuantity > 0){
                                    System.debug('--in Quantity if-->');
                                    dw.dealProduct.Replen_Quantity__c = calculatedQuantity;
                                    dw.dealProduct.Target_Quantity__c = calculatedQuantity;
                            }
                            else {
                                  System.debug('--in Quantity else-->');
                                  if(calculatedQuantity > 0) {
                                  dw.dealProduct.Quantity = calculatedQuantity;
                                  dw.dealProduct.Target_Quantity__c = calculatedQuantity;
                                  }
                                }*/
                        //}
                    }
//****

                    // NR deal products should always get updated because we are calling it from batch
                    if(isUpdateflag) {
                        if(dw.dealProduct.Invalid_Deal_Product__c == true) {
                            dw.dealProduct.Invalid_Deal_Product__c = false;
                        }
                        listProductsToUpdate.add(dw.dealProduct);
                    }
                }
                
            }
            /*if(lstDealProductScheduleToDelete != null && !lstDealProductScheduleToDelete.isEmpty()){
                system.debug('******lstDealProductScheduleToDelete'+lstDealProductScheduleToDelete);
                delete lstDealProductScheduleToDelete;
            }*/

            // Update the list of deal products which have undergone price-change 
            if(!listProductsToUpdate.isEmpty()) {
                system.debug('******listProductsToUpdate'+listProductsToUpdate);
                update listProductsToUpdate;
            }

            if (mapDealProductIdToInstance.size() > 0){
                if(!test.isRunningTest()){
                    system.debug('****** inside  *******');
                    CRM_AutoEstablishSchedulesHelper.createDealProductSchedule(mapDealProductIdToInstance.keySet(), new Set<Id>());
                }
            }
        }
        
        catch(System.DMLException e){
           for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                throw new PricingUpdateException(e.getDmlMessage(i));
            }
        }
        catch(Exception ex) {
            // Error Logging
            CRM_ErrorLogger.ErrorLog errlog = new CRM_ErrorLogger.ErrorLog();
            //errlog.recordId = dealIds[0];
            errlog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS; // 
            errlog.lineNumber =  String.valueOf(ex.getLineNumber());
            errlog.errorMessage = ex.getMessage();
            errlog.stackTrace = ex.getStackTraceString();
            CRM_ErrorLogger.logError(errlog);
            throw new PricingUpdateException(ex.getMessage());
            //throw ex;
        }
    }
    
    private static CRM_ProductPricingHandler.DealWrapper createDealWrapper(OpportunityLineItem dealProd) {
        CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
        dw.dealId = dealProd.OpportunityId;
        dw.accountId = dealProd.Opportunity.AccountId;
        dw.dealCurrency = dealProd.Opportunity.CurrencyISOCode;
        dw.productId = dealProd.Product2Id;
        dw.pricebookId = dealProd.Opportunity.Pricebook2Id;
        dw.dealStartDate = dealProd.Opportunity.Start_Date__c;
        dw.dealEndDate = dealProd.Opportunity.CloseDate;
        dw.dealProduct = dealProd;
        return dw; 
    }
    
    /**
        *  @Description - The method prepares a (map) collection of Account Plan Id and the Information of Account Plans
        *  @name - getAccountPlans
        *  @return - return a collection of account Plan Id and Account Plan Information
    */
    private static Map<String,Account_Plan__c> initializeAccountPlans(List<OpportunityLineItem> dealProds) {
        Set<Id> accountSet = new Set<Id>();
        Set<Id> prodSet = new Set<Id>();
        Map<String,Account_Plan__c> mapDatedAccountPlans = new Map<String,Account_Plan__c>();
        String key;
         
        for(OpportunityLineItem oli : dealProds) {
           if(oli.Opportunity != null && oli.Opportunity.AccountId != null)
           {
           accountSet.add(oli.Opportunity.AccountId);
           prodSet.add(oli.Product2ID);
           }
        }
        
        /*List<Account_Plan__c> apList = [select Id, PublishedTarget__c from Account_Plan__c where Customer__c IN: accountSet
        and Country_Plan__r.RecordTypeId =: CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE and Country_Plan__r.NR_Product__c IN: prodSet
        ORDER BY CreatedDate ASC LIMIT 1];*/
        
        for(Account_Plan__c ap : [select Id,Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c from Account_Plan__c where Customer__c IN: accountSet
        and Country_Plan__c != null AND Country_Plan__r.RecordTypeId =: CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE and Country_Plan__r.NR_Product__c IN: prodSet
        ORDER BY CreatedDate]){
            key = ap.Customer__c + ''+ ap.Country_Plan__r.NR_Product__c;
            if(!mapDatedAccountPlans.containsKey(key)){            
                mapDatedAccountPlans.put(key, ap);
            }
            //mapDatedAccountPlans.get(ap.Customer__c).add(ap);
        }                  
        return mapDatedAccountPlans;
    }
    
    
    private class FutureSchedulesWrapper {
        OpportunityLineItemSchedule schedule;
    }
    
    global class PricingUpdateException extends Exception {}
    
}