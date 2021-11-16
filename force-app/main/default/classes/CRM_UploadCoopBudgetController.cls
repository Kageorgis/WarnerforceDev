/**
   @Author Cognizant
   @name CRM_UploadCoopBudgetController
   @CreateDate 11 Nov 2017
   @Description This class is used to upload (update/insert) the deal and deal products through Co-op Budget.
   @Version <1.0>
   @reference Requirement no 905 (US Games)
*/
global with sharing class CRM_UploadCoopBudgetController {

    public String handsontableversion{get; set;}
    
    global CRM_UploadCoopBudgetController() {
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
    }

    global Integer getChunkSizeForSaveCoopBudgets() {
        return CRM_Batch_Size__c.getInstance('Upload Co-op Budget Tactic Records') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('Upload Co-op Budget Tactic Records').Batch_Size__c) : 150;
    }

    //US : 989
    public boolean getUserLocaleForCSV(){
        String availableLocales =CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c != null ? CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c : '';
        List<String> lstAvailableLocales = availableLocales.split(',');
        Set<String> setOfLocales = new Set<String>();
        setOfLocales.addall(lstAvailableLocales);
        if(setOfLocales.contains(getUserLocale() )){
            return true;
        }else{
            return false;
        }
    } 
    
     /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
          if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        } 
        return currentUserLocale;
    }

    /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setOpportunityLineItems
     *  @param CRM_UploadDealProductsController.OpportunityLineItemWrapper[] and Opportunity Id
     *  @return sorted CRM_UploadDealProductsController.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static FinalCoopBudgetWrapper upsertCoopBudgets(List<CoopBudgetWrapper> cooBudgetWrapperList) {
        
        FinalCoopBudgetWrapper finalCoopBudgetWrap = new FinalCoopBudgetWrapper();
        List<CoopBudgetWrapper> successBudgetWrapList = new List<CoopBudgetWrapper>();
        List<CoopBudgetWrapper> failedBudgetWrapList = new List<CoopBudgetWrapper>();
        List<CoopBudgetWrapper> filteredCoopBudgets = new List<CoopBudgetWrapper>(); 
        
        //Defect : 4576 : update modified records only
        List<CoopBudgetWrapper> nonModifiedBugets = new List<CoopBudgetWrapper>();
        
        Set<String> setAccountNumberUniqueKey = new Set<String>();
        Set<String> setProductCode = new Set<String>();
        Set<String> setCalendarMonth = new Set<String>();
        
        for(CoopBudgetWrapper budgetWrap : cooBudgetWrapperList){
            
            //Defect : 4576 : update modified records only
			//DEF#4843 994
            if(budgetWrap.isRowModified!=null && budgetWrap.isRowModified){
                if(
                    budgetWrap.accountNumber == null || budgetWrap.accountNumber == '' || 
                    budgetWrap.salesOrg == null || budgetWrap.salesOrg == '' ||
                    budgetWrap.productCode == null || budgetWrap.productCode == '' ||
                    budgetWrap.calendarMonth == null || budgetWrap.calendarMonth == '' ||
                    budgetWrap.budgetAmount == null  //DEF#4729 : Make quantity Field mandatory on grid
                ){
                    budgetWrap.validation = system.label.CRM_UploadBudget_Account_Product_CalendarMonth_validation;
                    budgetWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                    failedBudgetWrapList.add(budgetWrap);
                    continue;
                }
                
                if(budgetWrap.calendarMonth != null && budgetWrap.calendarMonth != ''){
                    List<String> monthAndYear = budgetWrap.calendarMonth.split('-');
                    if(!(monthAndYear.size() == 2 && monthAndYear[0].length() == 4 && monthAndYear[1].length() == 2)){
                        budgetWrap.validation = system.label.CRM_UploadBudget_Invalid_CalendarMonth_Format;
                        budgetWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        failedBudgetWrapList.add(budgetWrap);
                        continue;
                    }else{
                        Integer month = integer.valueof(monthAndYear[1]);
                        Integer year = integer.valueof(monthAndYear[0]);
                        if(month == 0 || month > 12 || year == 0){
                            budgetWrap.validation = system.label.CRM_UploadBudge_Invalid_Calendar_Month_And_Year;
                            budgetWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                            failedBudgetWrapList.add(budgetWrap);
                            continue;
                        }
                    }
                }
                filteredCoopBudgets.add(budgetWrap);
                setAccountNumberUniqueKey.add(budgetWrap.accountNumber +'-'+budgetWrap.salesOrg);
                setProductCode.add(budgetWrap.productCode);
            }else{
                budgetWrap.validation = '';
                budgetWrap.recrodStatus = ''; // DEF#4843 994US 994
                nonModifiedBugets.add(budgetWrap);
            }
        }
        
        if(!setAccountNumberUniqueKey.isEmpty() && !setProductCode.isEmpty()){
            
            Map<String,Account> mapOfAccounts = new Map<String,Account>() ;
            Set<Id> setPriceBooks = new Set<Id>();
            Set<String> setCurrencyIsoCode = new Set<String>();
            
            for(Account acc : [SELECT Id,Name,AccountNumber,CurrencyIsoCode,Price_Book__c, Sales_Organization__c
                               From Account 
                               WHERE 
                               AccountNumber != null AND Sales_Organization__c != null
                               AND (Status__c = :CRM_AppConstants.ACCOUNT_STATUS_ACTIVE OR Status__c = :CRM_AppConstants.ACCOUNT_STATUS_BLOCKED)
                               AND Unique_Territory__c IN :setAccountNumberUniqueKey 
                               AND Storefront__c = null
                               AND Price_Book__c != null]){
                mapOfAccounts.put(acc.AccountNumber + '-' + acc.Sales_Organization__c,acc);
                setPriceBooks.add(acc.Price_Book__c);
                setCurrencyIsoCode.add(acc.CurrencyIsoCode);
            }
            
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>();
            Set<String> setProdcutCode = new Set<String>();
            
            for(PricebookEntry pbEntry : [SELECT Id,Product2.ProductCode,Product2Id,Pricebook2Id,CurrencyIsoCode,PRoduct2.SAP_Dist_chain_product_Status__c
                                          From PricebookEntry
                                          WHERE Product2.ProductCode IN :setProductCode AND isActive = true AND Pricebook2Id != null AND Product2Id != null AND
                                          Pricebook2Id IN :setPriceBooks AND CurrencyIsoCode IN :setCurrencyIsoCode]){
                                         
                String strKey = pbEntry.Pricebook2Id+'-'+pbEntry.Product2.ProductCode+'-'+pbEntry.CurrencyIsoCode;
                mapOfProductCodeToPB.put(strKey,pbEntry);
                setProdcutCode.add(pbEntry.Product2.ProductCode);
            }
            
            List<CoopBudgetWrapper> listCBs = new List<CoopBudgetWrapper>();
            List<Coop_Budget__c> listUpsertCoopBudget = new  List<Coop_Budget__c>();
            
            for(CoopBudgetWrapper budgetWrap : filteredCoopBudgets){
                
                Id accountId = mapOfAccounts.containsKey(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg) ? mapOfAccounts.get(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg).Id : null;
                if(accountId == null){
                    budgetWrap.validation = system.label.CRM_UploadBudget_Account_Not_found;
                    budgetWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                    failedBudgetWrapList.add(budgetWrap);
                    continue;
                }/*else{
                    Account acc =  mapOfAccounts.get(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg);
                    if(acc.Status__c != CRM_AppConstants.ACCOUNT_STATUS_ACTIVE){
                        budgetWrap.validation = system.label.CRM_UploadBudget_Account_Not_Active;
                        failedBudgetWrapList.add(budgetWrap);
                        continue;
                    }
                }*/
                
                Id ProductID;
                if(setProdcutCode.contains(budgetWrap.productCode)){
                    String mapKey =  mapOfAccounts.get(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg).Price_Book__c+'-'+budgetWrap.productCode+'-'+mapOfAccounts.get(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg).CurrencyIsoCode;
                    if(mapOfProductCodeToPB.containsKey(mapKey)){
                        PricebookEntry pbe = mapOfProductCodeToPB.get(mapKey);
                        ProductID = pbe.Product2Id;
                        if(!CRM_AppConstants.sAPdistChainProductStatus.contains(pbe.Product2.SAP_Dist_chain_product_Status__c)){
                            budgetWrap.validation = system.label.CRM_UploadBudget_Invalid_SAP_Dist_Chain_Status;
                            budgetWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                            failedBudgetWrapList.add(budgetWrap);
                            continue;
                        }
                    }
                }
                if(ProductID == null){
                    budgetWrap.validation = system.label.CRM_UploadBudget_Product_Not_found;
                    budgetWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                    failedBudgetWrapList.add(budgetWrap);
                    continue;
                }
                 
                Coop_Budget__c cb = new Coop_Budget__c();
                cb.Amount__c = budgetWrap.budgetAmount;
                cb.Customer__c = accountId;
                cb.CurrencyIsoCode = mapOfAccounts.get(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg).CurrencyIsoCode;
                cb.Calendar_Month__c = budgetWrap.calendarMonth.trim();
                cb.Product__c = ProductID;
                cb.Event_Name__c = (budgetWrap.eventName != null && budgetWrap.eventName != '') ? budgetWrap.eventName.trim() : CRM_AppConstants.COOP_BUDGET_DEFAULT_EVENT_NAME;
                cb.Unique_Key__c = String.valueOf(accountId)+'-'+cb.Calendar_Month__c+'-'+String.valueOf(ProductID)+'-'+cb.Event_Name__c.toLowerCase();
                cb.name =  mapOfAccounts.get(budgetWrap.accountNumber + '-' + budgetWrap.salesOrg).name+'-'+cb.Calendar_Month__c+'-'+budgetWrap.productCode+'-'+cb.Event_Name__c;
                
                listUpsertCoopBudget.add(cb);
                listCBs.add(budgetWrap);
            }
            
            if(!listUpsertCoopBudget.isEmpty()){
                List<CRM_Default_Configuration__c> lstDefaultConfig = [Select Id,ByPassAutoTradeSpendDeal__c From CRM_Default_Configuration__c Limit 1];
                if (!lstDefaultConfig.isEmpty()) {
                    lstDefaultConfig[0].ByPassAutoTradeSpendDeal__c = true;
                    update lstDefaultConfig;
                }
                Database.UpsertResult[] result = Database.Upsert(listUpsertCoopBudget, Coop_Budget__c.Unique_Key__c, false);
                upsertDMLResultForCoopBudgets(result,successBudgetWrapList,failedBudgetWrapList,listCBs);
                if (!lstDefaultConfig.isEmpty()) {
                    lstDefaultConfig[0].ByPassAutoTradeSpendDeal__c = false;
                    update lstDefaultConfig;
                }
            }
        }
    
    //Defect : 4576 : update modified records only
        successBudgetWrapList.addAll(nonModifiedBugets);
        
        finalCoopBudgetWrap.successBudgetWrapList = successBudgetWrapList;
        finalCoopBudgetWrap.failedBudgetWrapList = failedBudgetWrapList;
        return finalCoopBudgetWrap;
    }
    
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
    */
    global static void upsertDMLResultForCoopBudgets(list<Database.UpsertResult> results,List<CoopBudgetWrapper> successBudgetWrapList,List<CoopBudgetWrapper> failedBudgetWrapList,List<CoopBudgetWrapper> listCBs) {
        for(Integer i=0;i<results.size();i++){
            CoopBudgetWrapper cbWrap = listCBs.get(i);
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage().containsIgnoreCase(CRM_AppConstants.DUPPLICATE_RECORD_ERROR_MESSAGE) ? System.label.CRM_UploadBudget_Duplicate_Coop_Budgets : error.getMessage();
                cbWrap.validation = failedDML;
                cbWrap.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                failedBudgetWrapList.add(cbWrap);
            }else{
                if(results[i].isCreated()){
                    cbWrap.validation = System.label.CRM_Upload_Message_Created;
                    cbWrap.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                }else{
                    cbWrap.validation = System.label.CRM_Upload_Message_Updated;
                    cbWrap.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                }
                
                //Defect : 4576 : update modified records only
                cbWrap.isRowModified = false;
                
                successBudgetWrapList.add(cbWrap);
            }
        }
    }
    
    /**
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class CoopBudgetWrapper{
        
        //Defect : 4576 : update modified records only
        public boolean isRowModified = false;
        
        public Decimal budgetAmount;
        public String accountNumber = '';
        public String salesOrg = '';
        public String productCode = '';
        public String calendarMonth = '';
        public String eventName = '';
        public String validation = '';
        //US : 994 
        public string recrodStatus='';
    }
    
    /**
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class FinalCoopBudgetWrapper{
        List<CoopBudgetWrapper> successBudgetWrapList = new List<CoopBudgetWrapper>();
        List<CoopBudgetWrapper> failedBudgetWrapList = new List<CoopBudgetWrapper>();
    }
     //US : 989
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    } 
}