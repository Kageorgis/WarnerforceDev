/**
   @Author-Cognizant Technology Solutions
   @name-CRMJV_CloneDealCtrl
   @CreateDate-Date> 15 June 2021
   @Description- Class to cover different scenarios that will occur on clone functionality for SDS and S2S
   @Version-<1.0>
   @reference-ER-007269
  */

public with sharing class CRMJV_CloneDealCtrl{

    public String dealRecordTypeName{get; set;}
    public String dealSalesOrg{get; set;}
    public Boolean isProfileReadOnly{get; set;}

    public CRMJV_CloneDealCtrl(Apexpages.StandardController stdCon){
        if (stdCon.getId() != null){
            List<Opportunity> lstOpportunity = [SELECT RecordType.DeveloperName,Sales_Organisation__c FROM Opportunity WHERE Id = :stdCon.getId()];
            if (!lstOpportunity.isEmpty()){
                dealRecordTypeName = lstOpportunity[0].RecordType.DeveloperName;
                dealSalesOrg = lstOpportunity[0].Sales_Organisation__c;
            }
            isProfileReadOnly = profileReadOnly();
        }
    }

    /** 
    *  @Description Method to fetch object level permissions for logged in user 
    *  @name profileReadOnly
    *  @param None
    *  @return boolean yes or no
    *  @throws None
    */
    private static Boolean profileReadOnly(){
        Boolean returnVal = false;
        List<ObjectPermissions> objPermissions = CRM_UploadComponentController.getPermissionDetails('Opportunity');
        if(objPermissions[0].PermissionsCreate == false || objPermissions[0].PermissionsEdit == false ||
                objPermissions[0].PermissionsDelete == false){
            returnVal = true;
        }
        return returnVal;
    }

    /** 
    *  @Description Method to clone existing deal to new deal with specific values 
    *  @name cloneDeal
    *  @param dealId - id of current deal to clone, dealWrapper - contain user input account details
    *  @return Id - cloned deal id
    *  @throws validation messasges  
    */
    @RemoteAction
    public static Opportunity cloneDeal(Id dealId, DealWrapper dealWrapper){
        List<Opportunity> lstOpportunity = [SELECT Id,NR_Deal_Unique_Key__c,Sales_Organisation__c,Clone_Deal__c FROM Opportunity WHERE Id = :dealId];

        //Ability to clone deals and change account
        Account dealAccount = getAccount(dealWrapper.accountId);

        if(!lstOpportunity.isEmpty()){
            //check for cloning already in progress
            if(lstOpportunity[0].Clone_Deal__c){
                throw new CRMJV_CloneDealException(System.Label.CRMJV_Clone_Deal_Batch_Inprogress);
            }

            //Prevent "NR" Deal Clonning.
            if(lstOpportunity[0].NR_Deal_Unique_Key__c != null){
                throw new CRMJV_CloneDealException(System.Label.CRM_NR_Deals_Cannot_Be_Cloned_Error);
            }

            //Account is mandatory
            if(dealWrapper.accountId == null){
                throw new CRMJV_CloneDealException(System.Label.CRM_Clone_Deal_Account_Is_Mandatory_Error);
            }

            //check for account pricebook
            if(dealAccount != null && dealAccount.Price_Book__c == null){
                throw new CRMJV_CloneDealException(System.label.CRM_PriceBook_Not_Present_On_Account);
            }

            //check for Sales org different in Account and deal
            if(dealAccount != null && lstOpportunity[0].Sales_Organisation__c != dealAccount.Sales_Organization__c){
                throw new CRMJV_CloneDealException(System.label.CRMJV_Clone_Deal_Current_Selected_Account_Territory_Different);
            }
        }
        String SOQL_DEAL_QUERY = 'SELECT ' + String.join(getDealFieldsToCopy(), ', ');
        SOQL_DEAL_QUERY += ' FROM Opportunity';
        SOQL_DEAL_QUERY += ' WHERE Id=\''+ dealId +'\'';

        Opportunity[] listDeals = (Opportunity[]) Database.Query(SOQL_DEAL_QUERY);
        listDeals[0].Id = null;
        listDeals[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        listDeals[0].Name = listDeals[0].Name + ' - ' + DateTime.now().getTime();
        listDeals[0].AccountId = dealWrapper.accountId;
        listDeals[0].Admin_Status__c = CRM_AppConstants.OPPORTUNITY_ADMIN_STATUS_NEW;
        if(dealAccount != null && dealAccount.Price_Book__c != null){
            listDeals[0].PriceBook2Id = dealAccount.Price_Book__c;
        }

        Savepoint sp = Database.setSavepoint();
        try{
            CRM_ApplicationUtility.isJVDealCloneBatch = true;
            lstOpportunity[0].Clone_Deal__c = true;
            update lstOpportunity[0];

            insert listDeals;
        }catch(System.DMLException de){
            Database.RollBack(sp);
            throw new CRMJV_CloneDealException(de.getDmlMessage(0));
        }
        return listDeals[0];
    }

    /** 
    *  @Description Method to clone existing deal products to new deal with specific values 
    *  @name cloneDealProducts
    *  @param dealId - id of cloned deal, dealProdIds - existing deal products to clone
    *  @return None 
    *  @throws None
    */
    @RemoteAction 
    public static void cloneDealProducts(Id clonedDealId, Id currentDealId){
        System.debug('@@ClonedId-->'+clonedDealId+'--CurrentDealId-->'+currentDealId);
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('SDSJVCloneDealProductBatch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 200;

        CRMJV_CloneDealProductsBatch batchInstance = new CRMJV_CloneDealProductsBatch();
        batchInstance.clonedDealId = clonedDealId;
        batchInstance.currentDealId = currentDealId;
        Database.executebatch(batchInstance, defaultBatchSize);
    }

    /** 
    *  @Description Method to fetch account details which is selected by user
    *  @name getAccount
    *  @param accountId - id of user input account
    *  @return Account - account details
    *  @throws None
    */
    private static Account getAccount(Id accountId){
        Account dealAccount = null; 
        List<account> dealAccountList = [Select Id,Price_Book__c,CurrencyIsoCode,Sales_Organization__c,Class_of_Trade__c From Account Where ID =: accountId limit 1];
        if(!dealAccountList.isEmpty()){
            dealAccount = dealAccountList[0];
        }
        return dealAccount;
    }

    /** 
    *  @Description Method to clone existing deal products to new deal with specific values 
    *  @name getSaveErrors
    *  @param saveResults - save result of deal products, listDealProducts - list of deal products to clone
    *  @return ProductSaveError - list of validation/errors 
    *  @throws None
    */
    public static ProductSaveError[] getSaveErrors(Database.SaveResult[] saveResults, OpportunityLineItem[] listDealProducts){
        ProductSaveError[] errors = new ProductSaveError[]{};

        for(Integer i=0; i<saveResults.size(); i++){
            if(!saveResults[i].isSuccess()){
                OpportunityLineItem oliInstance = listDealProducts[i];

                ProductSaveError err = new ProductSaveError();
                //err.productCode = oliInstance.Product2.ProductCode;
                //err.productName = oliInstance.Product2.Name;
                err.error = saveResults[i].getErrors()[0].getMessage();
                err.lineitem = oliInstance;
                errors.add(err);
            }
        }
        return errors;
    }

    /** 
    *  @Description Method to fetch list of fields to be copy in clone for Opportunity object 
    *  @name getDealFieldsToCopy
    *  @param None
    *  @return String[] - list of fields to copy
    *  @throws None
    */
    public static String[] getDealFieldsToCopy(){
        String[] listDealFields = new String[]{};

        Set<String> setDealAllFields = getSObjectFields('Opportunity');
        Set<String> setDealFieldsToExclude = getFieldsToExclude('Opportunity');

        setDealAllFields.removeAll(setDealFieldsToExclude);

        listDealFields.addAll(setDealAllFields);
        return listDealFields;
    }

    /** 
    *  @Description Method to fetch list of fields to be copy in clone for OpportunityLineItem object 
    *  @name getDealFieldsToCopy
    *  @param None
    *  @return String[] - list of fields to copy
    *  @throws None
    */
    public static String[] getDealProductFieldsToCopy(){
        String[] listDealProdFields = new String[]{};

        Set<String> setDealProdAllFields = getSObjectFields('OpportunityLineItem');
        Set<String> setDealProdFieldsToExclude = getFieldsToExclude('OpportunityLineItem');

        setDealProdAllFields.removeAll(setDealProdFieldsToExclude);

        if(!setDealProdAllFields.contains('Product2Id')){
            setDealProdAllFields.add('Product2Id');
        }
        if(!setDealProdAllFields.contains('Deal_Record_Type__c')){
            setDealProdAllFields.add('Deal_Record_Type__c');
        }
        setDealProdAllFields.add('Product2.productCode');
        setDealProdAllFields.add('Product2.Product_Market__c');
        setDealProdAllFields.add('Product2.Product_Format__c');
        setDealProdAllFields.add('Product2.Product_Language_Code__c');
        setDealProdAllFields.add('Product2.Name');

        setDealProdAllFields.add('Opportunity.Start_Date__c');
        setDealProdAllFields.add('Opportunity.CloseDate');
        setDealProdAllFields.add('Opportunity.Pricebook2Id');

        listDealProdFields.addAll(setDealProdAllFields);
        return listDealProdFields;
    }

    /** 
    *  @Description Method to fetch list of fields of object 
    *  @name getSObjectFields
    *  @param objectName - Name of object name to get fields
    *  @return Set<String> - set of field names of object
    *  @throws None
    */
    public static Set<String> getSObjectFields(String objectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        Set<String> setAllFields = new Set<String>();

        for(Schema.SObjectField sfield : fieldMap.Values()){
            Schema.describeFieldResult dfield = sfield.getDescribe();

            if(!dfield.isAutoNumber() && !dfield.isCalculated() && dfield.isCreateable()){
                setAllFields.add(dfield.getName());
            }
        }
        return setAllFields;
    }

    /** 
    *  @Description Method to fetch list of fields of object those are in CRMJV_ExcludeFieldsInClone fieldset
    *  @name getFieldsFromFieldset
    *  @param objName - Name of object name to get fields
    *  @return List<Schema.FieldSetMember> - list of field names those are in CRMJV_ExcludeFieldsInClone fieldset
    *  @throws None
    */
    public static List<Schema.FieldSetMember> getFieldsFromFieldset (String objName){
        if(objName.equals('Opportunity'))
            return SObjectTYpe.Opportunity.FieldSets.CRMJV_ExcludeFieldsInClone.getFields();
        else if(objName.equals('OpportunityLineItem'))
            return SObjectTYpe.OpportunityLineItem.FieldSets.CRMJV_ExcludeFieldsInClone.getFields();
        return null;    
    }

    /** 
    *  @Description Method to fetch list of fields to exclude in clone
    *  @name getFieldsToExclude
    *  @param objectName - Name of object name to get fields
    *  @return Set<String> - list of field names to exclude
    *  @throws None
    */
    public static Set<String> getFieldsToExclude(String objectName){
        Set<String> fieldsToExclude = new Set<String>();
        for (Schema.FieldSetMember field : getFieldsFromFieldset(objectName)) 
            fieldsToExclude.add(field.getFieldPath());
        return fieldsToExclude;
    }
    
    /**
    * @Description Method to fetch PricebookEntry details for particular Products and PriceBooks for deal product creation
    * @name fetchPriceBookEntryForProduct
    * @param lstProdCode - list of product code, priceBookId- pricebook id, currencyCode - currency code
    * @return Map<String, PricebookEntry> - map of PEB with key
    * @throws None
    */
    public static Map<String, PricebookEntry> fetchPriceBookEntryForProduct(List<String> lstProdCode, Id priceBookId, String currencyCode){
        Map<String, PricebookEntry> mapPriceBookEntry = new Map<String, PricebookEntry>();

        for(PricebookEntry pricBkEntry : [SELECT Product2Id, Product2.ProductCode, Pricebook2Id, UnitPrice, CurrencyIsoCode, IsActive
                FROM PriceBookEntry
                WHERE Product2.ProductCode IN: lstProdCode AND 
                    Pricebook2Id =: priceBookId AND 
                    CurrencyISOCode =: currencyCode AND 
                    IsActive = true]){
            mapPriceBookEntry.put(pricBkEntry.Pricebook2Id + '-' + pricBkEntry.Product2.ProductCode + '-' + pricBkEntry.CurrencyIsoCode, pricBkEntry);
        }
        return mapPriceBookEntry;
    }

    public class CRMJV_CloneDealException extends Exception {}
    
    public class DealWrapper{
        public Id dealId {get;set;}
        public Id accountId {get;set;}
        public String accountName {get;set;}
    }
    
    public class ProductSaveError{
        public String error {get;set;}
        public OpportunityLineItem lineitem {get;set;}
    }
}