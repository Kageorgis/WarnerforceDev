public with sharing class CRM_CloneDealCtrl {
    public String dealRecordTypeName{get; set;}
    //US #486: Clone Deal to another Account
    public CRM_CloneDealCtrl(Apexpages.StandardController stdCon) {
        if (stdCon.getId() != null) {
            List<Opportunity> lstOpportunity = [SELECT RecordType.DeveloperName FROM Opportunity WHERE Id = :stdCon.getId()];
            if (!lstOpportunity.isEmpty() && lstOpportunity[0].RecordType.DeveloperName != null) {
                dealRecordTypeName = lstOpportunity[0].RecordType.DeveloperName;
            }
        }
    }
    
    @RemoteAction 
    public static Id cloneDeal(Id dealId, DealWrapper dealWrapper) {
        //US #486: Clone Deal to another Account
        Boolean isBeneluxDeal;
        //Prevent "NR" Deal Clonning.
        Boolean isNRDeal;
        List<Opportunity> lstOpportunity = [SELECT NR_Deal_Unique_Key__c, Sales_Organisation__c, Bundle__c, Market_Type__c FROM Opportunity WHERE Id = :dealId];
        if (!lstOpportunity.isEmpty()) {
            isBeneluxDeal = (CRM_AppConstants.BENELUX_SALES_ORGS.contains(lstOpportunity[0].Sales_Organisation__c))? true: false;
            //Prevent "Rental" Deal Clonning.
            isNRDeal = (lstOpportunity[0].NR_Deal_Unique_Key__c != null) ? true: false;
            if(isBeneluxDeal){
                List<Assortment_Account__c> lstAssortmentAccount = [Select Account__c From Assortment_Account__c Where Assortment__c = :lstOpportunity[0].Bundle__c];
                Set<Id> setAssortmentAccount = new Set<Id>();
                if(!lstAssortmentAccount.isEmpty()){
                    for(Assortment_Account__c assortmentAccount: lstAssortmentAccount){
                        setAssortmentAccount.add(assortmentAccount.Account__c);
                    }
                    //Account is mandatory(moved outside the if)
                    //if(dealWrapper.accountId == Null){
                        //throw new CRM_CloneDealException(Label.CRM_Clone_Deal_Account_Is_Mandatory_Error);
                    //}
                    if(!setAssortmentAccount.contains(dealWrapper.accountId)){
                        throw new CRM_CloneDealException(Label.CRM_Clone_Deal_Account_Error);
                    }
                }               
            }
            //Prevent "NR" Deal Clonning.
            if(isNRDeal){
                throw new CRM_CloneDealException(Label.CRM_NR_Deals_Cannot_Be_Cloned_Error);
            }
            //Account is mandatory
            if(dealWrapper.accountId == Null){
                throw new CRM_CloneDealException(Label.CRM_Clone_Deal_Account_Is_Mandatory_Error);
            }
        }        
        String SOQL_DEAL_QUERY = 'SELECT ' + String.join(getDealFieldsToCopy(), ', ');
        SOQL_DEAL_QUERY += ' FROM Opportunity';
        SOQL_DEAL_QUERY += ' WHERE Id=\''+ dealId +'\'';
        
        Opportunity[] listDeals = (Opportunity[]) Database.Query(SOQL_DEAL_QUERY);
        listDeals[0].Id = null;
        listDeals[0].StageName = 'Planned';
        listDeals[0].Name = listDeals[0].Name + ' - ' + DateTime.now().getTime() ;
        //US #486: Clone Deal to another Account
        listDeals[0].AccountId = dealWrapper.accountId;
        
        //US : 815 : Ability to clone deals and change account
        Account dealAccount = getAccount(dealWrapper.accountId);
        if(dealAccount != null && dealAccount.Price_Book__c != null){
            listDeals[0].PriceBook2Id = dealAccount.Price_Book__c;
        }else{
            throw new CRM_CloneDealException(System.label.CRM_PriceBook_Not_Present_On_Account);
        }
       
        try{
            insert listDeals;
        }catch(System.DMLException de){
            throw new CRM_CloneDealException(de.getDmlMessage(0));
        }
        
        return listDeals[0].Id;
    }
    
    @RemoteAction 
    public static ProductSaveError[] cloneDealProducts(Id clonedDealId, Id[] dealProdIds, Id dealAccountId) {
        
        //US : 815 : Ability to clone deals and change account
        Id priceBookId;
        String CurrencyIsoCode;
        CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
        Account dealAccount = getAccount(dealAccountId);
        if(dealAccount != null){
            priceBookId = dealAccount.Price_Book__c;
            CurrencyIsoCode = dealAccount.CurrencyIsoCode;
        }
        
        ProductSaveError[] errors = new ProductSaveError[]{};
        Map<Id,OpportunityLineItem> mapOfDealProduct = new Map<Id,OpportunityLineItem>();
        //Added for US1021 - Clone Deal to an Account in a different country - Start
        Map<String,OpportunityLineItem> mapOfProductCodeToDealProduct = new Map<String,OpportunityLineItem>();
        Map<String,List<OpportunityLineItem>> mapOfProductCodeToDealProductList = new Map<String,List<OpportunityLineItem>>(); //WBCTASK000161574
        List<String> lstProdCode = new List<String>();
        List<String> lstMarketType = new List<String>();
        //List<String> lstLang = new List<String>();
        List<String> lstFormat = new List<String>();
        // Added for US1021 - Clone Deal to an Account in a different country - End
        
        String SOQL_DEALPROD_QUERY = 'SELECT ' + String.join(getDealProductFieldsToCopy(), ', ');
        SOQL_DEALPROD_QUERY += ' FROM OpportunityLineItem';
        SOQL_DEALPROD_QUERY += ' WHERE Id=:dealProdIds';
        
        OpportunityLineItem[] listDealProducts = (OpportunityLineItem[]) Database.Query(SOQL_DEALPROD_QUERY);
        for(OpportunityLineItem dealProd : listDealProducts) {
            dealProd.Id = null;
            dealProd.OpportunityId = clonedDealId;
            mapOfDealProduct.put(dealProd.Product2Id,dealProd);
            //Added for US1021 - Clone Deal to an Account in a different country - Start
            String key = dealProd.Product2.ProductCode + dealProd.Product2.Product_Market__c /*+ dealProd.Product2.Product_Language_Code__c*/ + dealProd.Product2.Product_Format__c;
            mapOfProductCodeToDealProduct.put(key,dealProd);
            //WBCTASK000161574 - START
            if(mapOfProductCodeToDealProductList.containsKey(key)) {
                mapOfProductCodeToDealProductList.get(key).add(dealProd);
            }
            else{
                mapOfProductCodeToDealProductList.put(key,new List<OpportunityLineItem>{dealProd});
            }
            //WBCTASK000161574 - END
            lstProdCode.add(dealProd.Product2.ProductCode);
            lstMarketType.add(dealProd.Product2.Product_Market__c);
            //lstLang.add(dealProd.Product2.Product_Language_Code__c);
            lstFormat.add(dealProd.Product2.Product_Format__c);
            //Added for US1021 - Clone Deal to an Account in a different country - End
        }
        CRM_ProductPricingHandler intance = new CRM_ProductPricingHandler();
        //Modified for US1021 - Clone Deal to an Account in a different country - Start
        intance.mapDatedPricebookEntries = initializePricebookEntryPeriodData(lstProdCode,lstMarketType/*,lstLang*/,lstFormat,priceBookId,CurrencyIsoCode);
        //Modified for US1021 - Clone Deal to an Account in a different country - End
        
        listDealProducts = new OpportunityLineItem[]{};
        if(mapOfDealProduct.size() > 0 && priceBookId != null){
            //Modified for US1021 - Clone Deal to an Account in a different country - Start
        Map<String, List<PriceBookEntry>> mapPBE = new Map<String, List<PriceBookEntry>>(); 
            for(PriceBookEntry pbe : [Select Id,Product2Id,Product2.ProductCode,Product2.Product_Market__c,Product2.Product_Format__c,Product2.Product_Language_Code__c
                              From PriceBookEntry Where Product2.ProductCode IN :lstProdCode 
                              AND Product2.Product_Market__c IN : lstMarketType 
                              /*AND Product2.Product_Language_Code__c IN :lstLang*/
                              AND Product2.Product_Format__c IN :lstFormat 
                              AND PriceBook2Id = :priceBookId AND CurrencyIsoCode = :CurrencyIsoCode]){
                    String pbeKey = pbe.Product2.ProductCode + pbe.Product2.Product_Market__c + pbe.Product2.Product_Format__c;       
                    if(mapPBE.containsKey(pbeKey)){
                        mapPBE.get(pbeKey).add(pbe);
                    }else{
                        List<PriceBookEntry> lstPbe = new List<PriceBookEntry>();
                        lstPbe.add(pbe);
                        mapPBE.put(pbeKey,lstPbe);
                    }
                    
            }       
            for(List<OpportunityLineItem> dpList : mapOfProductCodeToDealProductList.values()){ //WBCTASK000161574 - THIS OUTER LOOP FOR CLONE DEAL ISSUE
                for(OpportunityLineItem oli : dpList){
                    PriceBookEntry pbe = new PriceBookEntry();
                    pbe = null;
                    String dpKey = oli.Product2.ProductCode + oli.Product2.Product_Market__c /*+ oli.Product2.Product_Language_Code__c*/ + oli.Product2.Product_Format__c;                  
                    
                    if(mapPBE.containsKey(dpKey)){
                        for(PriceBookEntry pricebookEntry : mapPBE.get(dpKey)){
                            system.debug(' oli.Product2.Product_Language_Code__c '+oli.Product2.Product_Language_Code__c);
                            system.debug(' pricebookEntry.Product2.Product_Language_Code__c '+pricebookEntry.Product2.Product_Language_Code__c);
                            if(oli.Product2.Product_Language_Code__c.toUpperCase() == pricebookEntry.Product2.Product_Language_Code__c.toUpperCase())
                                pbe = pricebookEntry;               
                        }                 
                        if(pbe == null){
                            pbe = (mapPBE.get(dpKey)).get(0);
                        }
                    } 
                    if(pbe != null){
                        //OpportunityLineItem oppLI = mapOfProductCodeToDealProduct.get(dpKey);
                        dw.dealId = oli.OpportunityId;
                        dw.accountId = dealAccountId;
                        dw.productId = pbe.Product2Id;                      
                        dw.pricebookId = priceBookId;
                        dw.dealCurrency = CurrencyIsoCode;
                        dw.dealEndDate = oli.Opportunity.CloseDate;
                        dw.dealStartDate = oli.Opportunity.Start_Date__c;
                    }
                        Pricebook_Entry_Period__c pbep = intance.getProductDatedPricebookEntryPeriod(dw);
                         
                        if(pbep != null && pbe != null){
                            if(mapOfProductCodeToDealProductList.containsKey(dpKey)){
                                 oli.PriceBookEntryId = pbe.Id;
                                 oli.Product2Id = pbe.Product2Id;
                                listDealProducts.add(oli);
                                if(mapOfProductCodeToDealProduct.containsKey(dpKey)){
                                    mapOfProductCodeToDealProduct.remove(dpKey);
                                }
                            }   
                        }else{
                            ProductSaveError err = new ProductSaveError();
                            err.productCode = oli.Product2.ProductCode;
                            err.productName = oli.Product2.Name;
                            err.error = system.label.CRM_Upload_Message_PBEP;
                            errors.add(err);
                            if(mapOfProductCodeToDealProduct.containsKey(dpKey)){
                                mapOfProductCodeToDealProduct.remove(dpKey);
                            }
                        } 
                }
            }
         }   
        
        if(mapOfProductCodeToDealProduct.size() > 0){
            for(OpportunityLineItem oli : mapOfProductCodeToDealProduct.values()){
                ProductSaveError err = new ProductSaveError();
                err.productCode = oli.Product2.ProductCode;
                err.productName = oli.Product2.Name;
                err.error = system.label.CRM_Clone_deal_Product_Error_Msg;
                errors.add(err);
            }
        }
        //Modified for US1021 - Clone Deal to an Account in a different country - End    
        if(!listDealProducts.isEmpty()){
            Database.SaveResult[] prodInsertResults = Database.insert(listDealProducts, false);
            errors.addAll(getSaveErrors(prodInsertResults, listDealProducts));
        }
        return errors;
    }
    
    //US : 815 : Ability to clone deals and change account
    private static Account getAccount(Id accountId){
        List<account> dealAccount = [Select Id,Price_Book__c,CurrencyIsoCode From Account Where ID = :accountId limit 1];
        if(!dealAccount.isEmpty())
            return dealAccount[0];
        else
            return null;
    }
    
    
    //US : 815 : Ability to clone deals and change account
    private static ProductSaveError[] getSaveErrors(Database.SaveResult[] saveResults, OpportunityLineItem[] listDealProducts) {
        ProductSaveError[] errors = new ProductSaveError[]{};
        Map<Id,String> mapPricebookEntryError = new Map<Id,String>(); 
         
        for(Integer i=0; i< saveResults.size(); i++) {
            if(!saveResults[i].isSuccess()) {
                mapPricebookEntryError.put(listDealProducts[i].PricebookEntryId, saveResults[i].getErrors()[0].getMessage());
            }
        }
        if(!mapPricebookEntryError.isEmpty()) {
            for(PricebookEntry pbe : [select Id, Product2.ProductCode, Product2.Name
                        from PricebookEntry where Id IN: mapPricebookEntryError.keySet() ]) {
                
                ProductSaveError err = new ProductSaveError();
                err.productCode = pbe.Product2.ProductCode;
                err.productName = pbe.Product2.Name;
                err.error = mapPricebookEntryError.get(pbe.Id);
                
                //WBCTASK000161574 - START - CHANGING ERROR MESSAGE TO USER UNDERSTANDABLE FORM
                if(err.error.contains(Label.CRM_Duplicate_Value_Error)){
                    err.error = Label.CRM_Assortment_Product_Not_Found;
                }
                //WBCTASK000161574 - END
                errors.add(err);
            }
        }
        
        return errors;
    }
    
    //US #486: Clone Deal to another Account
    public class DealWrapper {
        public Id dealId {get;set;}
        public Id accountId {get;set;}
        public String accountName {get;set;}
    }
    
    public class ProductSaveError {
        public String productCode {get;set;}
        public String productName {get;set;}
        public String error {get;set;}
    }
    
    public static String[] getDealFieldsToCopy() {
        String[] listDealFields = new String[]{};
        
        Set<String> setDealAllFields = getSObjectFields('Opportunity');
        Set<String> setDealFieldsToExclude = getFieldsToExclude('Opportunity');
        
        setDealAllFields.removeAll(setDealFieldsToExclude);
        
        listDealFields.addAll(setDealAllFields);
        System.debug('listDealFields-->'+listDealFields);
        return listDealFields;
    }
    
    
    public static String[] getDealProductFieldsToCopy() {
        String[] listDealProdFields = new String[]{};
        
        Set<String> setDealProdAllFields = getSObjectFields('OpportunityLineItem');
        Set<String> setDealProdFieldsToExclude = getFieldsToExclude('OpportunityLineItem');
        
        setDealProdAllFields.removeAll(setDealProdFieldsToExclude);
        
        //US : 815 : Ability to clone deals and change account
        if(!setDealProdAllFields.contains('Product2Id')){
            setDealProdAllFields.add('Product2Id');
        }
        setDealProdAllFields.add('Product2.productCode');
         //Added for US1021 - Clone Deal to an Account in a different country - Start
        setDealProdAllFields.add('Product2.Product_Market__c');
        setDealProdAllFields.add('Product2.Product_Format__c');
        setDealProdAllFields.add('Product2.Product_Language_Code__c');
         //Added for US1021 - Clone Deal to an Account in a different country - End
        setDealProdAllFields.add('Product2.Name');
        setDealProdAllFields.add('Opportunity.Start_Date__c');
        setDealProdAllFields.add('Opportunity.CloseDate');
        
        listDealProdFields.addAll(setDealProdAllFields);
        return listDealProdFields;
    }
    
    private static Set<String> getSObjectFields(String objectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        Set<String> setAllFields = new Set<String>();
        
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            Schema.describeFieldResult dfield = sfield.getDescribe();

            if(!dfield.isAutoNumber() && !dfield.isCalculated() && dfield.isCreateable() ) {
                setAllFields.add(dfield.getName());
            }
        }
        
        return setAllFields;
    }
    
    private static List<Schema.FieldSetMember> getFieldsFromFieldset (String objName) {
        if(objName.equals('Opportunity'))
            return SObjectTYpe.Opportunity.FieldSets.ExcludeFieldsInClone.getFields();
        else if(objName.equals('OpportunityLineItem'))
            return SObjectTYpe.OpportunityLineItem.FieldSets.ExcludeFieldsInClone.getFields();
            
        return null;    
    }
    
    private static Set<String> getFieldsToExclude(String objectName) {
        Set<String> fieldsToExclude = new Set<String>();
        
        for (Schema.FieldSetMember field : getFieldsFromFieldset(objectName)) 
            fieldsToExclude.add(field.getFieldPath());
                
        return fieldsToExclude;
    }
    
    public class CRM_CloneDealException extends Exception {}
    //Modified for US1021 - Clone Deal to an Account in a different country - Start
    private static Map<String,Pricebook_Entry_Period__c[]> initializePricebookEntryPeriodData(List<String> lstProdCode,List<String> lstMarketType/*,List<String> lstLang*/,List<String> lstFormat,Id pricebookId,String currencyIdoCode) {
        Map<String,Pricebook_Entry_Period__c[]> mapDatedPricebookEntries = new Map<String,Pricebook_Entry_Period__c[]>();
                   
        for(Pricebook_Entry_Period__c pbep : [select Id, Price_Book__c, Product__c, Product__r.Product_Price_Group__c ,Product__r.Product_Format__c, Product__r.Product_Type__c, CurrencyISOCode, Start_Date__c, End_Date__c, List_Price__c, Client_Avail__r.Local_Data_Category_Picklist__c,
                            Minimum_Price__c,Account_Price__c,Suggested_Price__c,Retail_Price__c, Material_Price_Group__c, Product__r.ProductCode, Product__r.Product_Market__c, Product__r.Product_Language_Code__c 
                            from Pricebook_Entry_Period__c
                            where Price_Book__c != null and Product__c != null and 
                                Price_Book__c = :pricebookId and Product__r.ProductCode IN :lstProdCode and Product__r.Product_Market__c IN :lstMarketType /*and Product__r.Product_Language_Code__c IN :lstLang*/ and Product__r.Product_Format__c IN :lstFormat and CurrencyISOCode = :currencyIdoCode 
                            order by Price_Book__c, Product__c, CurrencyISOCode, Start_Date__c, CreatedDate]) {
     //Modified for US1021 - Clone Deal to an Account in a different country - End                           
            //Unique Key with combination of Product,PriceBook and CurrencyISO Code is  created to get limited matching records
            String mapRecKey = pbep.Product__c + '-'+ pbep.Price_Book__c + '-' + pbep.CurrencyISOCode;
            if(!mapDatedPricebookEntries.containsKey(mapRecKey)){
                mapDatedPricebookEntries.put(mapRecKey, new Pricebook_Entry_Period__c[]{});
            }
            
            mapDatedPricebookEntries.get(mapRecKey).add(pbep);
        }
        
        return mapDatedPricebookEntries;
    }    
}