/***************************************************************************************************************************************************************
   @Author: Cognizant Team
   @name: CRM_DealProductCOPHandler
   @CreateDate: 10th Nov 2015
   @Description: To complete the COP feature under requirement no: 17 
   @Version: 1.0
   @reference: classes: Trigger: CRM_DealProduct

***************************************************************************************************************************************************************/

public with sharing class CRM_DealProductCOPHandler
 {    

    Map<Id, List<Contribution_Item__c>> mapContributionTemplateIdWithContributionItemList = new Map<Id, List<Contribution_Item__c>>();
    Map<Id, Product2> mapProdIdProduct = new Map<Id, Product2>();
    Map<Id, Opportunity> mapDealIdWithDealObj = new Map<Id, Opportunity>();
    Map<string,COP_ContributionTemplateNProductFields__c> mapCustomSettingCTDP = new Map<string,COP_ContributionTemplateNProductFields__c>();
    Map<String, CRM_COP_Common_Values__c> mapCommonCOPCustSetting = new Map<String, CRM_COP_Common_Values__c>();
    Map<string,COP_ContributionItemFields__c> mapCustomSettingCIDP = new Map<string,COP_ContributionItemFields__c>();    
    set<String> setDealProductFields = new set<String>();
    Map<string,COP_ContributionTemplateNProductFields__c> mapCTNP = new Map<string,COP_ContributionTemplateNProductFields__c>();
    
    public void calculateCOP(List<OpportunityLineItem> lstDealProduct)
    {
      List<Id> lstProductIds = new List<Id>(); 
      List<Id> lstOpportunityIds = new List<Id>();
      
        if (lstDealProduct != null && !lstDealProduct.isEmpty())
        {
        
            for (OpportunityLineItem objDealProduct : lstDealProduct)
            {
                            
                if (objDealProduct.Product2Id != null && objDealProduct.OpportunityId != null)
                {
                    objDealProduct.Unique_Product_ID__c=null;
                    lstProductIds.add(objDealProduct.Product2Id);
                    lstOpportunityIds.add(objDealProduct.OpportunityId);
                }
                            
            }
          
            if (lstOpportunityIds != null && lstProductIds != null)
            {
                        
                processDealProduct(lstOpportunityIds,lstProductIds, lstDealProduct);
            
            }
        }
      
    }    


    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public void logAnException(Exception ex, Id recordId){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null)
            errorLogInstance.recordId = recordId;
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLogInstance.functionalModule = 'CRM_DealProductCOPHandler';
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();
        listErrorLog.add(errorLogInstance);     
    }
    
    /*
    *  The method that is being called from trigger factory. This method will take the inputs from trigger
    *  factory and will process the DealProducts 
    *  @name: processDealProduct
    *  @param: List<Id> lstOpportunityIds, List<Id> lstProductIds, List<OpportunityLineItem> lstDealProduct
    *  @return: List<OpportunityLineItem>
    */
    public List<OpportunityLineItem> processDealProduct(List<Id> lstOpportunityIds, List<Id> lstProductIds,
                                                        List<OpportunityLineItem> lstDealProduct){
       try{        
            populateMaps(getOpportunityAndContributionTemplate(lstOpportunityIds), getProducts(lstProductIds));
            populateDealProductsFromCTNProducts(lstDealProduct);
        }catch(Exception ex){           
           logAnException(ex, null);
       }
        
        return populateDealProductsFromCI(lstDealProduct);
    }
    
/***********************************************************************************************************************************/
        
    /*
    *  The function takes list of opportunity ids as an input and returns List of opportunities as an output. 
    *  @name: getOpportunityAndContributionTemplate
    *  @param: List<Id> lstOpportunityIds
    *  @return: List<Opportunity>
    */    
    private List<Opportunity> getOpportunityAndContributionTemplate(List<Id> lstOpportunityIds) {            
        List<Opportunity> lstDeal = new List<Opportunity>();
        if (lstOpportunityIds != null && !lstOpportunityIds.IsEmpty()){
            try{
                lstDeal = [SELECT Id, Name, CloseDate, AccountId, Account.Contribution_Template__c,Account.Contribution_Template__r.Id, 
                                Account.Contribution_Template__r.Scrappage__c, Account.Contribution_Template__r.Music_Clearence_Fees__c, 
                                Account.Contribution_Template__r.PAP__c, Account.Contribution_Template__r.Merchandising__c,
                                Account.Contribution_Template__r.Agency_Fees__c, Account.Contribution_Template__r.Print_Point_of_Sale__c,
                                Account.Contribution_Template__r.Cash_Discounts__c, Account.Contribution_Template__r.Bad_Debts__c,
                                Account.Contribution_Template__r.Sales_Allowance__c, Account.Contribution_Template__r.Markdowns__c,
                                Account.Contribution_Template__r.Pricing_Query__c, Account.Contribution_Template__r.Annual_Terms_Rebate__c,
                                Account.Contribution_Template__r.MDF__c, Account.Contribution_Template__r.Space__c,
                                Account.Contribution_Template__r.Inventory_Obsolescence__c, Account.Contribution_Template__r.Tagging__c,
                                Account.Contribution_Template__r.COGs__c, Account.Contribution_Template__r.Returns__c,
                                Account.Contribution_Template__r.Tax_Rate__c,
                                Account.Contribution_Template__r.Coop__c, Account.Contribution_Template__r.Distribution_Cost__c,
                                Account.Sales_Organization__c FROM Opportunity WHERE ID IN :lstOpportunityIds];
            }catch(QueryException QEx){
                logAnException(QEx, null);
            }catch(NoAccessException AEx){
                logAnException(AEx, null);
            }
            
        }                       
        
        return lstDeal;
    }    

/***************************************************************************************************************************************************************/
    
   /*
    *  This method populates the DealProduct with default values from associated Contribution Template and Product 
    *  @name: populateDealProductsFromCTNProducts
    *  @param: List<OpportunityLineItem> lstDealProduct
    *  @return: void
    */        
    private void populateDealProductsFromCTNProducts(List<OpportunityLineItem> lstDealProduct){
        try{               
            //mapCustomSettingCTDP = COP_ContributionTemplateNProductFields__c.getAll();
            for(COP_ContributionTemplateNProductFields__c csCOPCTNPFields: COP_ContributionTemplateNProductFields__c.getAll().values()){
                mapCTNP.put(csCOPCTNPFields.ContributionTemplateOrProduct_Field__c + '-' + csCOPCTNPFields.RelatedCustomObject__c, csCOPCTNPFields);
            }

            //setDealProductFields = mapCustomSettingCTDP.keySet();
            setDealProductFields = mapCTNP.keySet();

            mapCommonCOPCustSetting = CRM_COP_Common_Values__c.getAll();
            for (OpportunityLineItem objDealProduct : lstDealProduct){
                populateDealProductsFromCommonCOPCustSetting(objDealProduct);
                populateDealProductsFromCT(objDealProduct);
                populateDealProductsFromProducts(objDealProduct);
            }
        }catch(Exception ex){
            logAnException(ex, null);
        }
    }
    
/***************************************************************************************************************************************************************/     
     
    /*
    *  This function populates the Deal Product fields with corresponding Contribution Template Fields that are being listed in the custom setting 
    *  @name: populateDealProductsFromCT
    *  @param: OpportunityLineItem objDealProduct
    *  @return: void
    */
    
    private void populateDealProductsFromCommonCOPCustSetting(OpportunityLineItem objDealProduct){        
        Opportunity objDeal = null;
    
        if (mapDealIdWithDealObj.containsKey(objDealProduct.OpportunityId))
            objDeal = mapDealIdWithDealObj.get(objDealProduct.OpportunityId);
        
        if (objDeal != null  && objDeal.Account != null && mapCommonCOPCustSetting != null && mapCommonCOPCustSetting.size() > 0){
            if (mapCommonCOPCustSetting.containsKey(objDeal.Account.Sales_Organization__c)){
                objDealProduct.Gema__c = mapCommonCOPCustSetting.get(objDeal.Account.Sales_Organization__c).Gema__c;
                objDealProduct.Gross_receipt_taxes_FFA__c = mapCommonCOPCustSetting.get(objDeal.Account.Sales_Organization__c).Gross_receipt_taxes_FFA__c;
                objDealProduct.Doubtful_Accounts__c = mapCommonCOPCustSetting.get(objDeal.Account.Sales_Organization__c).Doubtful_Accounts__c;
            }    
        }        
    }     
     
/***************************************************************************************************************************************************************/     
       
     
/***************************************************************************************************************************************************************/     
     
    /*
    *  This function populates the Deal Product fields with corresponding Contribution Tenplate Fields that are being listed in the custom setting 
    *  @name: populateDealProductsFromCT
    *  @param: OpportunityLineItem objDealProduct
    *  @return: void
    */
    private void populateDealProductsFromCT(OpportunityLineItem objDealProduct){
        Opportunity objDeal = null;
        if (mapDealIdWithDealObj.containsKey(objDealProduct.OpportunityId))
            objDeal = mapDealIdWithDealObj.get(objDealProduct.OpportunityId);
                    
        if (objDeal != null && objDealProduct.OpportunityId == objDeal.Id && objDeal.Account != null && objDeal.Account.Contribution_Template__r != null){
            Contribution_Template__c objContributionTemplate = (Contribution_Template__c)objDeal.getSobject(CRM_AppConstants.ACCOUNT_API_NAME).getSobject(CRM_AppConstants.CONTRIBUTION_TEMPLATE_R);     
            setDealProductValues(CRM_AppConstants.CONTRIBUTION_TEMPLATE_LABEL, CRM_AppConstants.CONTRIBUTION_TEMPLATE_API_NAME, objContributionTemplate, objDealProduct);
        }
    }  

/***************************************************************************************************************************************************************/

    /*
    *  This function populates the Deal Product fields with corresponding Product fields that are being listed in the custom setting 
    *  @name: populateDealProductsFromProducts
    *  @param: OpportunityLineItem objDealProduct
    *  @return: void
    */
    private void populateDealProductsFromProducts(OpportunityLineItem objDealProduct){
        Product2 objProduct = null;
        if (mapProdIdProduct.containsKey(objDealProduct.Product2Id))
            objProduct = mapProdIdProduct.get(objDealProduct.Product2Id);

        setDealProductValues(CRM_AppConstants.PRODUCT_LABEL, CRM_AppConstants.PRODUCT_API_NAME, objProduct, objDealProduct);     
    }

/***************************************************************************************************************************************************************/

    /*
    *  This function actually iterates through the fields listed in custom setting and assigns it to corresponding fields in Deal Product 
    *  @name: setDealProductValues
    *  @param: String objLabel, String objAPIName, SObject sourceObj, OpportunityLineItem objDealProduct
    *  @return: void
    */        
    private void setDealProductValues(String objLabel, String objAPIName, SObject sourceObj, OpportunityLineItem objDealProduct) {
        if (sourceObj != null && objDealProduct != null && setDealProductFields != null){
            try{
                for (String strCTField : setDealProductFields){   

                    if (mapCTNP != null && mapCTNP.containsKey(strCTField) && mapCTNP.get(strCTField) != null && (mapCTNP.get(strCTField).RelatedCustomObject__c == objLabel || 
                        mapCTNP.get(strCTField).RelatedCustomObject__c == objAPIName)) {
                        if (mapDealIdWithDealObj != null && mapDealIdWithDealObj.containsKey(objDealProduct.OpportunityId)) {
                            Opportunity objDeal = mapDealIdWithDealObj.get(objDealProduct.OpportunityId);

                            if (objDeal != null && sourceObj.getSObjectType() == Contribution_Template__c.sObjectType && objDeal.Account != null && 
                                ((mapCTNP.get(strCTField).DE__c == true && (objDeal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || objDeal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE)) ||
                                (mapCTNP.get(strCTField).UK__c == true && objDeal.Account.Sales_Organization__c != CRM_AppConstants.TERRITORY_FRANCE_CODE) || 
                                (mapCTNP.get(strCTField).FR__c == true && objDeal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE) )){
                                Contribution_Template__c objContributionTemplate = (Contribution_Template__c)sourceObj;
                                objDealProduct.put(mapCTNP.get(strCTField).ContributionTemplateOrProduct_Field__c, objContributionTemplate.get(mapCTNP.get(strCTField).ContributionTemplateOrProduct_Field__c));
                            }
                            if(objDeal != null && sourceObj.getSObjectType() == Product2.sObjectType && objDeal.Account != null &&
                                ((mapCTNP.get(strCTField).DE__c == true && (objDeal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || objDeal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE)) ||
                                (mapCTNP.get(strCTField).UK__c == true && objDeal.Account.Sales_Organization__c != CRM_AppConstants.TERRITORY_FRANCE_CODE) || 
                                (mapCTNP.get(strCTField).FR__c == true && objDeal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE && objDealProduct.get(mapCTNP.get(strCTField).ContributionTemplateOrProduct_Field__c) == null))){
                                Product2 objProduct = (Product2)sourceObj;
                                objDealProduct.put(mapCTNP.get(strCTField).ContributionTemplateOrProduct_Field__c, objProduct.get(mapCTNP.get(strCTField).ContributionTemplateOrProduct_Field__c));
                            }
                        }
                    }
                }
            }catch(Exception ex){
                logAnException(ex, null);
            }
        }
    }

/***************************************************************************************************************************************************************/

    /*
    *  This method takes the list of product IDs as an input and returns the list of products 
    *  @name: getProducts
    *  @param: 1] List<Id> lstProductIDs
    *  @return: List<Product2> 
    */
    private List<Product2> getProducts(List<Id> lstProductIDs){
        List<Product2> lstProduct = new List<Product2>();        
        if (lstProductIDs != null && !lstProductIDs.IsEmpty())         
            lstProduct = [SELECT Id, Franchise_Type__c, Production_Cost__c, Product_Type__c, Distribution_Cost__c, Master_Negative__c,  
                Royalty_Fee_Fixed__c, Royalty_Fee__c, FFA__c, Product_Format__c FROM Product2 WHERE Id IN: lstProductIDs];
        
        return lstProduct;
    }    

/***************************************************************************************************************************************************************/

    /*
    *  Here we populate the globally declared maps for further usage in business logic 
    *  @name: populateMaps
    *  @param: 1] List<Opportunity> lstDealAndContributionTemplates 2] List<Product2> lstProduct
    *  @return: void 
    */
    private void populateMaps(List<Opportunity> lstDealAndContributionTemplates, List<Product2> lstProduct){
        List<Contribution_Item__c> lstContributionItem = getContributionItems(lstDealAndContributionTemplates);
         
        // Creating Map of <Contribution Template Id, Contribution Item List>
        for (Contribution_Item__c objContributionItem : lstContributionItem){
            Id parentCT = objContributionItem.Contribution_Template__c;
            if (mapContributionTemplateIdWithContributionItemList.containsKey(parentCT)){
                List<Contribution_Item__c> lstTempContributionItem = mapContributionTemplateIdWithContributionItemList.get(parentCT);
                lstTempContributionItem.add(objContributionItem);
                mapContributionTemplateIdWithContributionItemList.put(parentCT, lstTempContributionItem);
            }else{
                List<Contribution_Item__c> lstTempContributionItem = new List<Contribution_Item__c>();
                lstTempContributionItem.add(objContributionItem);
                mapContributionTemplateIdWithContributionItemList.put(parentCT, lstTempContributionItem);
            }
        }                    

        // Creating Map of <Product Id, Product>
        for (Product2 objProduct : lstProduct)
            mapProdIdProduct.put(objProduct.Id, objProduct);        
    }    

/***************************************************************************************************************************************************************/

    /*
    *  Fetch Contribution Items 
    *  @name: getContributionItems
    *  @param: 1] List<Opportunity> lstDealAndContributionTemplates
    *  @return: List<Contribution_Item__c>
    */
    private List<Contribution_Item__c> getContributionItems(List<Opportunity> lstDealAndContributionTemplates){
      Set<Id> setContributionTemplateIDs = getContributionTemplateIds(lstDealAndContributionTemplates);
      List<Contribution_Item__c> lstContributionItem = new  List<Contribution_Item__c>();
      
        if (setContributionTemplateIDs != null && !setContributionTemplateIDs.IsEmpty()){
            try{
                lstContributionItem = [SELECT Franchise__c, Merchandising__c , Returns__c, Coop__c, Sales_Allowance__c, Product_Type__c, Start_Date__c, End_Date__c, 
                    Scrappage__c, PAP__c, Contribution_Template__c, Agency_Fees__c, Annual_Terms_Rebate__c, Bad_Debts__c, Cash_Discounts__c, COGs__c,
                    Inventory_Obsolescence__c, Markdowns__c, Max_Additional_Discount__c, MDF__c, Music_Clearence_Fees__c, Pricing_Query__c, Format__c, 
                    Min_Contribution_Finance__c, Min_Contribution_Sales__c,                    
                    Print_Point_of_Sale__c, Space__c, Tagging__c, Tax_Rate__c, Distribution_Cost__c
                    FROM Contribution_Item__c WHERE Contribution_Template__c IN: setContributionTemplateIDs];
            }catch(Exception ex){
                logAnException(ex, null);
            }
        }
        return lstContributionItem;
    }

/***************************************************************************************************************************************************************/
    
    /*
    *  Returns a set of Contribution Template Ids which is derived from the list of Deal Products. 
    *  @name: getContributionTemplateIds
    *  @param: 1] List<Opportunity> lstDealAndContributionTemplates
    *  @return: set<Id>
    */
    private set<Id> getContributionTemplateIds(List<Opportunity> lstDealAndContributionTemplates) {
        // Creating a set to be used in query and populating a global map for further use.
        Set<Id> setContributionTemplateIDs = new Set<Id>();
        if(lstDealAndContributionTemplates != null)
        {
            for(Opportunity objDeal : lstDealAndContributionTemplates){
                if (objDeal.Account != null && objDeal.Account.Contribution_Template__c != null){
                    setContributionTemplateIDs.add(objDeal.Account.Contribution_Template__r.Id);
                    mapDealIdWithDealObj.put(objDeal.Id, objDeal);            
                }                 
            } 
            
        }        
       
        return setContributionTemplateIDs;
    }

/***************************************************************************************************************************************************************/
    
    /*
    *  This method collects contribution Item and product related to every Deal Product and dispatches it for further processing. 
    *  @name: populateDealProductsFromCI
    *  @param: 1] List<OpportunityLineItem> lstDealProduct
    *  @return: List<OpportunityLineItem>
    */
    private List<OpportunityLineItem> populateDealProductsFromCI(List<OpportunityLineItem> lstDealProduct){                      
        for(OpportunityLineItem objDealProduct : lstDealProduct){
            if (mapDealIdWithDealObj.containsKey(objDealProduct.OpportunityId)){
                Opportunity objDeal = mapDealIdWithDealObj.get(objDealProduct.OpportunityId);           
                if (objDeal != null && objDeal.Account != null && objDeal.Account.Contribution_Template__c != null && objDeal.Account.Contribution_Template__r.Id != null && mapContributionTemplateIdWithContributionItemList != null && 
                    mapContributionTemplateIdWithContributionItemList.containsKey(objDeal.Account.Contribution_Template__r.Id) && mapProdIdProduct.containsKey(objDealProduct.Product2Id)){
                
                    Product2 objProduct = mapProdIdProduct.get(objDealProduct.Product2Id);                                    
                    List<Contribution_Item__c> lstContriItem = mapContributionTemplateIdWithContributionItemList.get(objDeal.Account.Contribution_Template__r.Id);
          
                        if (lstContriItem != null && !lstContriItem.IsEmpty() && objProduct != null && objDeal != null)
                            populatingDealProductAfterMatch(objDealProduct, getMatchingContributionItem(lstContriItem, objProduct, objDeal));                    
                    }
            }
        }
      return lstDealProduct;
    }

/***************************************************************************************************************************************************************/

    /*
    *  This method finds the matching records from contribution Item and dispatches it for getting the fields populated. 
    *  @name: getMatchingContributionItem
    *  @param: 1] List<Contribution_Item__c> lstContriItem 2] Product2 objProduct
    *  @return: Contribution_Item__c
    */
    private Contribution_Item__c getMatchingContributionItem(List<Contribution_Item__c> lstContriItem, Product2 objProduct, Opportunity objDeal){
        Contribution_Item__c objContriItemTmp = null;
        
        for(Contribution_Item__c objContriItem : lstContriItem){                                 
            if (objProduct != null && objContriItem != null && objProduct.Product_Type__c != null && objContriItem.Product_Type__c != null && objProduct.Product_Type__c == objContriItem.Product_Type__c){                                                               
        
                if(objContriItem.Franchise__c != null && objProduct.Franchise_Type__c != null && objProduct.Franchise_Type__c == objContriItem.Franchise__c)
                    return objContriItem;
                    
                if(objContriItem.Format__c != null && objProduct.Product_Format__c != null && objProduct.Product_Format__c == objContriItem.Format__c)
                    return objContriItem;                   
          
                if (objContriItem.Franchise__c == null && objContriItem.Format__c == null)
                    objContriItemTmp = objContriItem;
            }
        }
        return objContriItemTmp;
    }

/***************************************************************************************************************************************************************/

    /*
    *  Populates Deal Product object in case match is found with Contribution Item. Fields to be populated are identified from Custom setting. 
    *  @name: populatingDealProductAfterMatch
    *  @param: 1] OpportunityLineItem objDealProduct 2] Contribution_Item__c objContriItem
    *  @return: void
    */    
    private void populatingDealProductAfterMatch(OpportunityLineItem objDealProduct, Contribution_Item__c objContriItem){
        try{
            mapCustomSettingCIDP = COP_ContributionItemFields__c.getAll();                

            if(mapCustomSettingCIDP != null){
              set<String> setContributionItemFields = mapCustomSettingCIDP.keySet();       
              
              for(String strContributionItemField : setContributionItemFields){
                  if (objContriItem != null && mapCustomSettingCIDP != null && mapCustomSettingCIDP.containsKey(strContributionItemField) && mapCustomSettingCIDP.get(strContributionItemField).ContributionItemField__c != null)
                      objDealProduct.put(strContributionItemField, objContriItem.get(mapCustomSettingCIDP.get(strContributionItemField).ContributionItemField__c));
              }
          }
        }catch(Exception ex){
            logAnException(ex, null);
        }
    }

/***************************************************************************************************************************************************************/

}// End of Class Definition