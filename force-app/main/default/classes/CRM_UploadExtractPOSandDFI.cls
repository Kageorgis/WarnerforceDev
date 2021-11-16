/**
@Author Accenture
@name CRM_UploadExtractPOSandDFI
@CreateDate  Mar 2020
@Description This class is used to upload (update/insert) the deal products for POS and DFI deals.
@Version <1.0>
*/
global with sharing class CRM_UploadExtractPOSandDFI {
    public String handsontableversion{get; set;}
    //--W-017642-Added to get isJVSalesOrg boolean flag for JV product-Start--//
    public Opportunity deal;
    //--W-017642-Added to get isJVSalesOrg boolean flag for JV product-End--//
    //--W-017676- isExpanded Added for CRMJV Planning deal-End--//
    public Boolean isExpanded{get; set;}
    
    
/** 
*  @Description - constructor 
*  @name  CRM_UploadExtractTradeTactics 
*/ 
    global CRM_UploadExtractPOSandDFI(ApexPages.StandardController stdController) {
        Id dealId = stdController.getId();
        //--W-017642-Added for retrive deal record to check SalesOrg for JV product-Start--//
        //--W-017676- isExpanded Added for CRMJV Planning deal-End--//
        isExpanded = apexpages.currentpage().getparameters().get('isExpanded') != 'true' ? false : true;
        deal = new Opportunity();
        if(dealId != null){
            List<Opportunity> listDeals = [select Id,Account.Sales_Organization__c,RecordTypeId,RecordType.Name,StageName from Opportunity where Id =: dealId];
            if(!listDeals.isEmpty()){
                deal = listDeals[0];
            }
        }
        //--W-017642-Added for retrive deal record to check SalesOrg for JV product-Start--//
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
    }
    /** 
*  Method to fetch object level permissions for logged in user 
*  @name profileReadOnly
*  @param None
*  @return boolean yes or no
*  @throws None
*/
    @RemoteAction
    public static Boolean profileReadOnly(){
        List<ObjectPermissions> objPermissions = CRM_UploadComponentController.getPermissionDetails('Opportunity');
        if(objPermissions[0].PermissionsCreate == false || objPermissions[0].PermissionsEdit == false ||
                            objPermissions[0].PermissionsDelete == false){
            return true;
        }else{
            return false;
        }
        
    }
/** 
*  Method to fetch the Deal Product from DealId  
*  @name getChunkSizeForTradeTactics
*  @param None
*  @return Chunk size in Integer
*  @throws None
*/
    global Integer getChunkSizeForTradeTactics() {
        return CRM_Batch_Size__c.getInstance('Upload Deal Tactics Records') != null ?
                Integer.valueOf(CRM_Batch_Size__c.getInstance('Upload Deal Tactics Records').Batch_Size__c) : 100;
    }
    /** 
*  Method to fetch the HandsonTable Licence Key  
*  @name getHandsonTable_Pro_Licencekey
*  @param None
*  @return String HandsonTable Licence Key
*  @throws None
*/
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ?
                CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    } 
    /*  
*  name getUserDateFormat: e.g. M/d/yyyy
*  param none
*  return string
*  throw none
*/  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    /**
* Method to get logged in uSer Locale
*/
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        try{
            if (currentUserLocale.contains('_')) {
                currentUserLocale = currentUserLocale.replace( '_', '-');
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return currentUserLocale;
    }
    /** 
*  Method to fetch the Deal Products for a Deal  
*  @name getopplt
*  @param Object Name, FieldSet Name, Deal Id
*  @return Class DataTableResponse
*  @throws None
*/
    @RemoteAction
    public static String getopplt(String sObjectName, String fieldSetName, String dealId){ 
        // Get the fields from FieldSet
        DataTableResponse response = new DataTableResponse();
        try{
            Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            List<DataTableColumns> dataColumns = new List<DataTableColumns>();
            List<String> fieldsToQuery = new List<String>();
            for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
                String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
                // This way we can set the type of a column
                // We do not get the exact type from schema object which matches to lightning:datatable component structure
                // Create a wrapper instance and store label, fieldname and type.
                DataTableColumns datacols = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                 String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                 dataType);
                dataColumns.add(datacols);
                fieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
            }
            // Form an SOQL to fetch the data - Set the wrapper instance and return as response
            if(! dataColumns.isEmpty()){            
                response.dataTableColumns = dataColumns;
                String query = 'SELECT Id, ' + String.join(fieldsToQuery, ',') + 
                                ' FROM '+sObjectName +' where Opportunity.Id =:  dealId LIMIT 50000';
                response.dataTableData = Database.query(query);
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return JSON.serialize(response);
    }
    
/** 
*  Class wrapper Class
*  Wrapper class to hold Columns with headers
*  @name DataTableColumns
*/
    public without sharing class DataTableColumns {
        public String label {get;set;}
        public String fieldName {get;set;}
        public String type {get;set;}
       /* 
        *   Create and set three variables label, fieldname and type as required by the lightning:datatable
        */
        public DataTableColumns(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
        }
    }
    
/** 
*  Class wrapper Class
*  Wrapper class to hold Columns with headers
*  @name DataTableResponse
*/
    public  without sharing class DataTableResponse {
        public List<DataTableColumns> dataTableColumns {get;set;}
        public List<sObject> dataTableData {get;set;} 
        /*
         *  Create and set two variable dataTableColumns and dataTableData to display the lightning:datatable
         */
        public DataTableResponse(){
            dataTableColumns = new List<DataTableColumns>();
            dataTableData = new List<sObject>();
        }
    }
    
/** 
*  Method save POS and DFI on Handson Table
*  @name posAndDFIRecords
*  @param recordsList, Deal Id
*  @return String
*/
    @RemoteAction
    public static String posAndDFIRecords(String recordsList, String dealId){
        
        List<OpportunityLineItemWrapper> dealLIREC = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItemWrapper> editedRecords = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItemWrapper> deleteRecords = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItemWrapper> dealLineItems= new List<OpportunityLineItemWrapper>();
        try{
            dealLineItems = (List<OpportunityLineItemWrapper>)
                                System.JSON.deserialize(recordsList,List<OpportunityLineItemWrapper>.class);
           for(OpportunityLineItemWrapper dealLI : dealLineItems ){
                if((dealLI.isRowModified == true && dealLI.isRowRemoved == false) || (dealLI.isRowModified == null)){
                    editedRecords.add(dealLI);
                }
                if(dealLI.isRowRemoved == true){
                    deleteRecords.add(dealLI);
                }    
            }
            
            dealLIREC = savePOSAndDFIDealLineItems(JSON.serialize(editedRecords),dealId,false);
            List<OpportunityLineItemWrapper> dealDeleteRec = deletedRecordsPOSandDFI(JSON.serialize(deleteRecords),dealId);
            if(dealDeleteRec.size() > 0){
                for(OpportunityLineItemWrapper delErrRec : dealDeleteRec){
                    if(delErrRec.isError == true && delErrRec.validation != ''){
                        dealLIREC.add(delErrRec); 
                    }
                }   
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return JSON.serialize(dealLIREC);
    }
    
/** 
*  Method to save deal Products  
*  @name savePOSAndDFIDealLineItems
*  @param new Deal Products, Deal Id
*  @return Wrapper List
*  @throws None
*/
    @RemoteAction
    public static List<OpportunityLineItemWrapper> savePOSAndDFIDealLineItems(String listStr, String dealId,boolean isExcelUpload){
        List<OpportunityLineItemWrapper> dealLineItems= new List<OpportunityLineItemWrapper>();
        try{
            List<OpportunityLineItem> dealLineItemsToUpsert= new List<OpportunityLineItem>();
            List<String> errorResult= new List<String>();
            Set<String> setProductCode = new Set<String>();
            Opportunity opportunity = [SELECT id,RecordTypeId,RecordType.Name,Sales_Organisation__c,
                                       Account.Digital_Country_Code__c,StageName,Account.Class_of_Trade__c,
                                       Pricebook2Id,AccountId,CurrencyISOCode,External_Id__c, CloseDate,Start_Date__c 
                                       FROM Opportunity 
                                       WHERE Id =: dealId LIMIT 50000];
            String recordTypeName = opportunity.RecordType.Name;
            String[] fieldSetArray = recordTypeName.replace('/','').split(' ');
            
            //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-Start--//
            String fieldSetName = '';
            if(opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || 
                    opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE){
                fieldSetName = String.join(fieldSetArray, '') + '_JV_fieldSetName';
            }else{
                fieldSetName = String.join(fieldSetArray, '') + '_fieldSetName';
            }            
            //--W-017642-Added if condition to check JV sales org and set JV related fieldset name for JV project-End--//

            Set<String> productCodeSet = new Set<String>();
            Set<String> duplicateProductCodes = new Set<String>();
            Set<String> commitmentNumberSet = new Set<String>();
            dealLineItems = (List<OpportunityLineItemWrapper>)
                System.JSON.deserialize(listStr,List<OpportunityLineItemWrapper>.class);
            system.debug('@@dealLineItems-->'+dealLineItems.size());
            for(OpportunityLineItemWrapper recordWrapper : dealLineItems){
                OpportunityLineItem record = recordWrapper.lineItem;
                if(record.Commitment_Number__c!=null){
                    commitmentNumberSet.add(record.Commitment_Number__c);
                }
                if(record.Product_Code__c!=null)
                    setProductCode.add(record.Product_Code__c.trim());
            }
            Map<String,PricebookEntry> mapOfProductCodeToPB = getValidMapPricebookEntryForProductCodes(opportunity,setProductCode);
            //       Map<String, list<Pricebook_Entry_Period__c>> mapUniqueKeyToValidPBEP = getValidPBEPForProduct(opportunity, setProductCode);
            Map<String,String> commitmentNumberIdMap = new Map<String,String>();
            for(OpportunityLineItem lineItem: [select Id,Commitment_Number__c,Product_Code__c from OpportunityLineItem where opportunityId =: dealId and Commitment_Number__c IN :commitmentNumberSet]){
                String key = lineItem.Commitment_Number__c + lineItem.Product_Code__c;
                commitmentNumberIdMap.put(key,lineItem.Id);
            }
            for(OpportunityLineItemWrapper recordWrapper : dealLineItems){
                if(recordWrapper.isRowModified!=null && recordWrapper.isRowModified  == true){
                    OpportunityLineItem record = recordWrapper.lineItem;
                    if(record.Id==null && (record.Commitment_Number__c==null || record.Commitment_Number__c=='')){
                        String key = opportunity.Pricebook2Id+'-'+record.Product_Code__c+'-'+opportunity.CurrencyIsoCode;
                        if(mapOfProductCodeToPB.containsKey(key)){
                            record.OpportunityId =dealId;
                            record.PricebookEntryId = mapOfProductCodeToPB.get(key).Id;
                            record.Quantity =1;
                            record.TotalPrice=0;
                            record.Unique_Product_ID__c = dealId + '-' + record.Product_Code__c;
                            record.Co_op_Actual_Amount__c = (record.Co_op_Actual_Amount__c!=null &&
                                                             record.Co_op_Actual_Amount__c != 0)?record.Co_op_Actual_Amount__c:
                            (record.POS_Quantity__c!=null?record.POS_Quantity__c:0)*(record.POS_Rebate__c!=null?
                                                                                     record.POS_Rebate__c:0);
                            
                        }else{
                            recordWrapper.validation=System.Label.CRM_Product_Not_Exist;
                            recordWrapper.isError=true;
                        }
                    }else if(record.Id==null && record.Commitment_Number__c !=null){
                        String key = record.Commitment_Number__c +record.Product_Code__c;
                        if(commitmentNumberIdMap.containsKey(key)){
                            record.Co_op_Actual_Amount__c = (record.Co_op_Actual_Amount__c!=null &&
                                                             record.Co_op_Actual_Amount__c != 0)?record.Co_op_Actual_Amount__c: 
                            (record.POS_Quantity__c!=null?record.POS_Quantity__c:0)*(record.POS_Rebate__c!=null?
                                                                                     record.POS_Rebate__c:0);
                            record.Id =commitmentNumberIdMap.get(key);
                            // dealLineItemsToUpsert.add(record);
                        }else{
                            recordWrapper.validation=System.Label.CRM_Wrong_Commitment_Number_Upload;
                            recordWrapper.isError=true;
                        }
                    }
                    else{
                        record.Co_op_Actual_Amount__c = (record.Co_op_Actual_Amount__c!=null &&
                                                         record.Co_op_Actual_Amount__c != 0)?record.Co_op_Actual_Amount__c:
                        (record.POS_Quantity__c!=null?record.POS_Quantity__c:0)*(record.POS_Rebate__c!=null?
                                                                                 record.POS_Rebate__c:0);
                        // dealLineItemsToUpsert.add(record);
                    }
                    
                    if(recordWrapper.isError == null || recordWrapper.isError  == false){
                        dealLineItemsToUpsert.add(record);
                    }
                }
            }
            
            Database.UpsertResult[] result = Database.Upsert(dealLineItemsToUpsert, false);
            if(isExcelUpload){
                dealLineItems = addErrorValidation(result,dealLineItems);
            }else{
                dealLineItems = addLineitemValidation(result,dealLineItems,dealId,fieldSetName);
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return dealLineItems;
    }
    
/** 
*  Method to save deal Products from Excel  
*  @name excelUploadPOSAndDFI
*  @param listStr, Deal Id
*  @return List of Strings
*/
    public static List<String> excelUploadPOSAndDFI(String listStr, String dealId){
        List<String> errList= new List<String>();
        try{
            List<OpportunityLineItemWrapper> result = savePOSAndDFIDealLineItems(listStr, dealId,true);
            for(OpportunityLineItemWrapper recordWrapper : result){
                if (recordWrapper.isError){
                    String jsonstr='{"validation" : "'+ recordWrapper.validation+'", "record":'+JSON.serialize(recordWrapper.lineItem)+'}';
                    errList.add(jsonstr);
                }
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return errList;
    }
    
/**
*  Method to fetch Valid Pricebook_Entry_Period__c For ProductCodes 
*  @name getValidMapPricebookEntryForProductCodes
*  @param Opportunity opportunityObject,Set<String> setProductCode
*  @return map of Pricebook_Entry_Period__c with unique key 
*  @throws None
**/ 
    private static Map<String,PricebookEntry> getValidMapPricebookEntryForProductCodes(Opportunity opportunity,Set<String> setProductCode){
        Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>();
        try{
            for(PricebookEntry pbEntry : [SELECT Id,Product2.ProductCode,Product2.Id,Product2.Name,Pricebook2Id,
                                          CurrencyIsoCode,Product2.SAP_Dist_chain_product_Status__c
                                 FROM PricebookEntry
                                 WHERE Product2.ProductCode IN :setProductCode 
                                 AND isActive = true 
                                 AND Pricebook2Id =:opportunity.Pricebook2Id 
                                 AND CurrencyIsoCode =:opportunity.CurrencyISOCode LIMIT 50000]){ 
                String strKey = pbEntry.Pricebook2Id+'-'+pbEntry.Product2.ProductCode+'-'+pbEntry.CurrencyIsoCode;
                mapOfProductCodeToPB.put(strKey,pbEntry);
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return mapOfProductCodeToPB;        
    }
    
/**
*  Method to get Validation errors
*  @name addErrorValidation
*  @param result of upsert,list of lineitemwrapper
*  @return  list of lineitemwrapper
*  @throws None
**/ 
    private static List<OpportunityLineItemWrapper> addErrorValidation(list<Database.UpsertResult>  results,
                                                                       List<OpportunityLineItemWrapper> dealLineItems){
        Integer i=0;
        for(OpportunityLineItemWrapper recordWrapper : dealLineItems){
            if((recordWrapper.isError == null || recordWrapper.isError  == false) && 
                            (recordWrapper.isRowModified!=null && recordWrapper.isRowModified  == true)){
               if(results.size() > 0){
                if (!results.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = results.get(i).getErrors().get(0);
                    recordWrapper.validation=error.getMessage();
                    recordWrapper.isError=true;  
                    recordWrapper.recrodStatus = 'error';
                    }
                }
                i++;
            }
        }
        return dealLineItems;
    }
    
/**
*  Method to get Validation errors
*  @name addLineitemValidation
*  @param result of upsert,list of lineitemwrapper
*  @return  list of lineitemwrapper
*  @throws None
**/ 
    private static List<OpportunityLineItemWrapper> addLineitemValidation(list<Database.UpsertResult>  results,
                                                                          List<OpportunityLineItemWrapper> dealLineItems,
                                                                          String dealId,String fieldSetName ){
        Integer i=0;
        Map<Id,OpportunityLineItem> mapPOSandDFI = new Map<Id,OpportunityLineItem>();
        String dataTableResponse = CRM_UploadExtractPOSandDFI.getopplt('OpportunityLineItem', fieldSetName, dealId);
        DataTableResponse dataTable = (DataTableResponse)
                                        System.JSON.deserialize(dataTableResponse,DataTableResponse.class);
        List<OpportunityLineItem> opItems = dataTable.dataTableData;
        for(OpportunityLineItem oppltrec : opItems){
            mapPOSandDFI.put(oppltrec.Id , oppltrec);
        }
        List<String> fieldApis = new List<String>();
        for(DataTableColumns dTable : dataTable.dataTableColumns){
            fieldApis.add(dTable.fieldName);
        }
        List<OpportunityLineItemWrapper> testDealLineItems = new List<OpportunityLineItemWrapper>();
        for(OpportunityLineItemWrapper recordWrapper : dealLineItems){
            system.debug('@@Wrapper-->'+recordWrapper.isError+'--'+recordWrapper.isRowModified);
            if((recordWrapper.isError == null || recordWrapper.isError  == false) &&
                        (recordWrapper.isRowModified!=null && recordWrapper.isRowModified  == true)){
                if (!results.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = results.get(i).getErrors().get(0);
                    recordWrapper.validation=error.getMessage();
                    recordWrapper.isError=true;
                    recordWrapper.recrodStatus = 'error';
                }else {
                    recordWrapper.existingId = results.get(i).getId();
                    recordWrapper.validation = '';
                    recordWrapper.isError = false;
                    recordWrapper.recrodStatus = 'success';
                    recordWrapper.lineItem = mapPOSandDFI.get(results.get(i).getId());
                }
                i++;
            }
        }
        return dealLineItems;
    }
/**
*  Method to fetch Valid Pricebook_Entry_Period__c For ProductCodes 
*  @name getValidPBEPForProduct
*  @param Opportunity opportunityObject,Set<String> setProductCode
*  @return map of list of Pricebook_Entry_Period__c with unique key 
*  @throws None
**/ 
     private static Map<String, List<Pricebook_Entry_Period__c>> getValidPBEPForProduct(Opportunity opportunity,Set<String> setProductCode){
        Map<String, List<Pricebook_Entry_Period__c>> mapUniqueKeyToValidPBEP = new Map<String, List<Pricebook_Entry_Period__c>>();
        List<Pricebook_Entry_Period__c> pbepList =new List<Pricebook_Entry_Period__c>();
        Set<String> priceType =  new Set<String>();
            priceType.add('PROMOTION');
            priceType.add('DEALER');
            priceType.add(opportunity.Account.Class_of_Trade__c);        
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Product__r.ProductCode, CurrencyIsoCode, Price_Book__c, Start_Date__c, End_Date__c,Price_Type__c  
                                              FROM Pricebook_Entry_Period__c
                                              WHERE Product__r.ProductCode IN : setProductCode 
                                              AND Price_Book__c =: opportunity.Pricebook2Id 
                                              AND CurrencyIsoCode =: opportunity.CurrencyISOCode
                                              AND Price_Type__c IN :priceType  
                                              AND Start_Date__c <=: opportunity.CloseDate
                                              AND End_Date__c >=: opportunity.Start_Date__c
                                              ORDER BY Start_Date__c DESC LIMIT 50000]) {                                              
                                                  String priceTypeStr = pbep.Price_Type__c !=null? '-' + pbep.Price_Type__c.toUpperCase():'';
                                                  String strKey = pbep.Product__r.ProductCode + '-' + pbep.Price_Book__c + '-' + pbep.CurrencyIsoCode + priceTypeStr ;                                                                                                                 
                                                  if(!mapUniqueKeyToValidPBEP.containsKey(strKey)){
                                                      pbepList =new List<Pricebook_Entry_Period__c>();                                                    
                                                  }else{
                                                      pbepList = mapUniqueKeyToValidPBEP.get( strKey);                                                    
                                                  }
                                                  pbepList.add(pbep);
                                                  mapUniqueKeyToValidPBEP.put(strKey, pbepList);
                                              }
                                             
        return mapUniqueKeyToValidPBEP;
    }
    /** 
*  Method to fetch the picklist values from the field
*  @name getselectOptions
*  @param SObjectName and FieldName
*  @return List of Picklist Values
*  @throws none
*/
    @RemoteAction
    public static List < String > getselectOptions(string objObject, string fld,String recordType, String isJVSalesOrg) {
        List<String> allOpts = new List<String>();
        try{
        if(fld.contains('.')){
            List<String> str = fld.split('\\.');
            objObject = str[0];
            fld = str[1];
        }
            
        sObject obj = Schema.getGlobalDescribe().get(objObject).newSObject();
        Schema.sObjectType objType = obj.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();            
        for (Schema.PicklistEntry a: values) {
            
            if(recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL) && 
               (System.Label.POS_DFI_Reason_PickList_Values).contains(a.getValue())){
                   allOpts.add(a.getValue());
               } //ER-007552- Check CoopReason if Deal is from SDS
            else if('TRUE'.equalsIgnoreCase(isJVSalesOrg) && recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL) && 
                    (System.Label.CRMJV_POS_DFI_Reason_PickList_Values).contains(a.getValue())){
                        allOpts.add(a.getValue());
                    }
            else if(recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DFI_DEAL) &&
                    (System.Label.CRM_DFI_Reason_Picklist_Values).contains(a.getValue())){
                        allOpts.add(a.getValue());
                    }
            else if((!fld.equals(System.Label.CRM_Reason) && (!fld.equals(System.Label.CRM_Account_Fund_Segment)))
                    || ((fld.equals(System.Label.CRM_Account_Fund_Segment) && 
                         recordType.equals(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL))) ){
                             allOpts.add(a.getValue());
                         }
        }
        allOpts.sort();
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return allOpts;
    }

/**
*  @Description - wrapper class
*  @name  OpportunityLineItemWrapper 
*/
    global without sharing class OpportunityLineItemWrapper {
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public Integer rowIndex;
        public boolean isError=false;
        public boolean previouslySelectedForRemoval=false;
        public String recrodStatus = '';
        public OpportunityLineItem lineItem;
        /*
         * Constructor for Wrapper class without arguments 
         */
        public OpportunityLineItemWrapper(){
            this.lineItem = lineItem;
            this.isRowModified = isRowModified;
            this.isRowRemoved = isRowRemoved;
            this.recrodStatus = recrodStatus;
        }
        /* 
         * Constructor for Wrapper Class
         */
        public OpportunityLineItemWrapper(OpportunityLineItem opLineItem, 
                                          Boolean rowModified, 
                                          Boolean rowRemoved,
                                          String recrodStatus){
            this.lineItem = opLineItem;
            this.isRowModified = rowModified;
            this.isRowRemoved = rowRemoved;
            this.recrodStatus = recrodStatus;
        }
    }
/**
*  Method to Delete the records
*  @name deletedRecordsPOSandDFI
*  @param listStr,dealId
*  @return  list of lineitemwrapper
*  @throws None
**/ 
    @AuraEnabled
    public static List<OpportunityLineItemWrapper> deletedRecordsPOSandDFI(String listStr, String dealId){
        List<OpportunityLineItemWrapper> deleteLineItems= new List<OpportunityLineItemWrapper>();
        try{
            List<OpportunityLineItem> delList = new List<OpportunityLineItem>();
            deleteLineItems = (List<OpportunityLineItemWrapper>)
                                System.JSON.deserialize(listStr,List<OpportunityLineItemWrapper>.class);
            for(Integer i = 0 ; i < deleteLineItems.size() ; i++){
                if(deleteLineItems[i].isRowRemoved!=null && deleteLineItems[i].isRowRemoved  == true){
                    OpportunityLineItem record = deleteLineItems[i].lineItem;
                    if(record.Id != null){
                        delList.add(record);
                    }else{
                        deleteLineItems.remove(i); 
                    }
                }
            }
            Database.DeleteResult[] result = Database.delete(delList, false);
            deleteLineItems = addDeleteErrorValidation(result,deleteLineItems);
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return deleteLineItems;
    }
/**
*  Method to add Delete validation errors
*  @name addDeleteErrorValidation
*  @param result of delete,list of lineitemwrappers
*  @return  list of lineitemwrapper
*  @throws None
**/ 
    private static List<OpportunityLineItemWrapper> addDeleteErrorValidation(
                                                                            list<Database.DeleteResult>  results,
                                                                             List<OpportunityLineItemWrapper> deleteLineItems ){
        Integer i=0;
        for(OpportunityLineItemWrapper recordWrapper : deleteLineItems){
            if((recordWrapper.isError  == null || recordWrapper.isError  == false) &&
                    (recordWrapper.isRowRemoved!=null && recordWrapper.isRowRemoved  == true)){
                if (!results.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = results.get(i).getErrors().get(0);
                    recordWrapper.validation=error.getMessage();
                    recordWrapper.isError=true;
                    recordWrapper.recrodStatus = 'error';
                }
                i++;
            }
        }
        return deleteLineItems;
    }
    
/**
*  Method to get the products in add products
*  @name getProductsForAddSearchProductScreen
*  @param pricebookId,quickSearchText,dealCurrency,dealAccountName,startDate,endDate,recordType
*  @return  list of productSearchWrapper
*  @throws None
**/ 
    @RemoteAction
    global static List<productSearchWrapper> getProductsForAddSearchProductScreen(
                                                                                Id pricebookId, 
                                                                                String quickSearchText, 
                                                                                String dealCurrency,
                                                                                String dealAccountName,
                                                                                String startDate, 
                                                                                String endDate,
                                                                                String recordType) { 
        List<productSearchWrapper> lstProducts = new List<productSearchWrapper>();
        List<String> lstQuickSearchText = new List<String>();
        Set<String> sAPdistChainProductStatus = new Set<String>{'01','40','05','11','Z5'};
        Set<String> salesOrg = new Set<String>{'2500','2403','2504',CRM_AppConstants.TERRITORY_SDS_US_CODE,CRM_AppConstants.TERRITORY_SDS_CANADA_CODE};        //--Added JV related org for W-017583--//
        try{    
            Integer recordLimit = CRM_Batch_Size__c.getInstance('CRM_UploadExtract_ProdSrch_Rec_Lmt') != null
                                                ? Integer.valueOf(CRM_Batch_Size__c.getInstance('CRM_UploadExtract_ProdSrch_Rec_Lmt').Batch_Size__c) : 50;
            if(quickSearchText != null && quickSearchText.trim() != '') {
                quickSearchText = String.escapeSingleQuotes(quickSearchText); 
                String sosl_search = '';
                lstQuickSearchText = quickSearchText.split('\\n');
                for(String str : lstQuickSearchText){
                    if(str != ''){
                        sosl_search += '(' + str + ')';
                        sosl_search += ' OR ';
                    }
                } 
                sosl_search = sosl_search.Substring(0,sosl_search.length()-4);
                if(lstQuickSearchText.size() == 1){
                    sosl_search = quickSearchText;
                }
                sosl_search = sosl_search.replace(':', '\\:');
                sosl_search = sosl_search.replace('-', '\\-');
                sosl_search = sosl_search.replace('+', '\\+');
                sosl_search = sosl_search.replace('&', '\\&');
                sosl_search = sosl_search.replace('!', '\\!');
                sosl_search = sosl_search.replace('^', '\\^');
                // SEARCH RESULTS FROM PRODUCTS
                String SOSL_QUERY_PRODUCT = '';
                if(recordType == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL){
                    SOSL_QUERY_PRODUCT = 'FIND {'+ sosl_search +'} IN ALL FIELDS'+
                        ' RETURNING Product2(Id,Name,ProductCode,toLabel(Product2.Product_Format__c),'+
                        ' Street_date__c,Video_Version__c,Local_Title__r.Name'+
                        ' Where SAP_Sales_Org__c IN :salesOrg AND CurrencyISOCode = :dealCurrency AND '+
                        ' isActive = true ORDER BY Name ASC) WITH PricebookId = \''+ pricebookId +'\' LIMIT '+String.valueOf(recordLimit);
                }else{
                    SOSL_QUERY_PRODUCT = 'FIND {'+ sosl_search +'} IN ALL FIELDS'+
                        ' RETURNING Product2(Id,Name,ProductCode,toLabel(Product2.Product_Format__c),'+
                        ' Street_date__c,Video_Version__c,Local_Title__r.Name'+
                        ' Where SAP_Sales_Org__c IN :salesOrg AND SAP_Dist_chain_product_Status__c IN :sAPdistChainProductStatus'+
                        ' AND CurrencyISOCode = :dealCurrency AND isActive = true ORDER BY Name ASC)'+
                        ' WITH PricebookId = \''+ pricebookId +'\' LIMIT '+String.valueOf(recordLimit);
                }
                if(sosl_search.length() > 4000){
                    throw new CRM_UploadExtractPOSandDFIException(Label.CRM_SOSL_Search_String_Limit_Reached);
                }
                List<List<SObject>> searchResult = Search.query(SOSL_QUERY_PRODUCT);
                for(Sobject[] listObj : searchResult) {
                    for(sobject sobj : listObj) {
                        productSearchWrapper productSearchWrap = new productSearchWrapper();
                        Product2 prod = (Product2)sobj;
                        CRM_DataObjects.ProductItem prodItem = new CRM_DataObjects.ProductItem();
                        prodItem.name = prod.name;
                        prodItem.productId = prod.Id;
                        prodItem.productCode = prod.ProductCode;
                        prodItem.streetDate = prod.Street_Date__c;
                        prodItem.format = prod.Product_Format__c;
                        productSearchWrap.product = prodItem;
                        OpportunityLineItemWrapper prodWrap = new OpportunityLineItemWrapper();
                        String str ='{"Product_Code__c" : "'+productSearchWrap.product.ProductCode+'"}';
                        prodWrap.isRowModified =true;
                        prodWrap.lineItem = (OpportunityLineItem)System.JSON.deserialize(str,OpportunityLineItem.class);
                        productSearchWrap.dealProdWrap = prodWrap;
                        productSearchWrap.isSelected = false;
                        lstProducts.add(productSearchWrap);
                    }
                }
            }
        }catch(Exception execp){
            throw new CRM_UploadExtractPOSandDFIException(execp.getMessage());
        }
        return lstProducts;
    }
    
/**
*  @Description - wrapper class
*  @name  OpportunityLineItemWrapper 
*/
    global without sharing class productSearchWrapper {
        public CRM_DataObjects.ProductItem product;
        public OpportunityLineItemWrapper dealProdWrap;
        public boolean isSelected = false;
    }
    
/**
*  @Description - Exception class
*  @name  CRM_UploadExtractPOSandDFIException 
*/
    global without sharing class CRM_UploadExtractPOSandDFIException extends Exception {}
    
    /**
    *  Method to reprice price book entry period for all deal products
*  @name repriceDealProduct
*  @param List of Opportunity
*  @return none
*  @throws List<String> to identified is reprice is in bulk process and outcome used in the flow to show message for WBCTASK000295555
    */
    @InvocableMethod (Label = 'Reprice Deal Product')
    public static List<String> repriceDealProduct(List<Opportunity> oppList){
        //--WBCTASK000295555--Added to hold flag for bulk reprice process--Start--//
        List<String> isBulkRepriceProcess = new List<String>();
        //--WBCTASK000295555--Added to hold flag for bulk reprice process--End--//
        Set<String> setProductCode = new Set<String>();
        List<OpportunityLineItem> dealLineItemsToUpsert= new List<OpportunityLineItem>();
        List<OpportunityLineItem> OppLineItems =new List<OpportunityLineItem>();
        String accountCOT ='';
        Opportunity opportunity = [SELECT id,RecordTypeId,RecordType.Name,Sales_Organisation__c,
                                   Account.Digital_Country_Code__c,StageName,Account.Class_of_Trade__c,
                                   Pricebook2Id,Pricebook2.Name,AccountId,CurrencyISOCode,External_Id__c, CloseDate,Start_Date__c 
                                   FROM Opportunity 
                                   WHERE Id =:oppList[0].Id LIMIT 1];
        for(OpportunityLineItem lineItem : [SELECT Id,Product_Code__c,Start_Date__c,End_Date__c,Pricebook_Entry_Period__c ,ListPrice__c from OpportunityLineItem where OpportunityId=:opportunity.Id]){
            setProductCode.add(lineItem.Product_Code__c);
            OppLineItems.add(lineItem);
        }   
        system.debug('@@OppLineItems-->'+OppLineItems.size());            
        accountCOT = opportunity.Account.Class_of_Trade__c !=null? opportunity.Account.Class_of_Trade__c.toUpperCase():'';
        Map<String, list<Pricebook_Entry_Period__c>> mapUniqueKeyToValidPBEP = getValidPBEPForProduct(opportunity, setProductCode);
        for(OpportunityLineItem record : OppLineItems){
            Boolean isUpdate =false;
            String strKey = accountCOT!=null?record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode+'-'  + accountCOT:record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode;
            if ( accountCOT!='RETAIL COST' && accountCOT!='MENU' && mapUniqueKeyToValidPBEP.containsKey(strKey)){
            //if ( mapUniqueKeyToValidPBEP.containsKey(strKey)){                
                list<Pricebook_Entry_Period__c> pbepList = mapUniqueKeyToValidPBEP.get(strKey);
                if(pbepList!=null){                   
                    for(Pricebook_Entry_Period__c pbep :pbepList){
                        if(pbep.Price_Type__c.toUpperCase()== accountCOT && record.Start_Date__c >=pbep.Start_Date__c && record.End_Date__c<=pbep.End_Date__c){
                            if( record.Pricebook_Entry_Period__c != pbep.Id){
                                record.Pricebook_Entry_Period__c = pbep.Id;     
                                isUpdate=true;
                            }else if(record.Pricebook_Entry_Period__c == pbep.Id && accountCOT=='RETAIL COST'){
                                 isUpdate=true;
                            }
                            break;
                        }
                    }  
                }
            }   
            strKey = record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode  + '-' + 'PROMOTION';
            list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
            if ( mapUniqueKeyToValidPBEP.containsKey(strKey)){
                pbepList = mapUniqueKeyToValidPBEP.get(strKey);               
            }
            strKey = record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode  + '-' + 'DEALER';
            if ( mapUniqueKeyToValidPBEP.containsKey(strKey)){                
               pbepList.addAll(mapUniqueKeyToValidPBEP.get(strKey));
            }
            if (pbepList!=null){
                for(Pricebook_Entry_Period__c pbep :pbepList){ 
                    if(record.Start_Date__c >=pbep.Start_Date__c && record.End_Date__c<=pbep.End_Date__c){
                        if(record.ListPrice__c  != pbep.List_Price__c){
                            record.ListPrice__c = pbep.List_Price__c;                           
                              isUpdate=(accountCOT=='RETAIL COST' || accountCOT=='MENU')?isUpdate: true;                                    
                        }                        
                        if (((accountCOT=='RETAIL COST' || accountCOT=='MENU')&& !isUpdate) || opportunity.Pricebook2.Name == 'WB Non-IP - US' || opportunity.Pricebook2.Name =='WB Non-IP - CA'){
                              record.Pricebook_Entry_Period__c = pbep.Id;  
                              isUpdate=true;                             
                        }                        
                        break;
                    }
                }
            }
            if (isUpdate){                
                dealLineItemsToUpsert.add(record);
            }
        }
        system.debug('@@dealLineItemsToUpsert-->'+dealLineItemsToUpsert.size());
        if(dealLineItemsToUpsert!=null){
            if(dealLineItemsToUpsert.size() <= Integer.valueOf(System.Label.CRM_Excel_Batch_Input)) {
                //--WBCTASK000295555--Added to hold flag as false becuase of not bulk reprice process--Start--//
                isBulkRepriceProcess.add('false');
                //--WBCTASK000295555--Added to hold flag as false becuase of not bulk reprice process--End--//
                ApexUtil.isTriggerInvoked = true;
                Database.UpsertResult[] result = Database.Upsert(dealLineItemsToUpsert, false);         
            }else {
                //--WBCTASK000295555--Added to hold flag as false becuase of bulk reprice process and apply newlogic to divide in chunks--Start--//
                isBulkRepriceProcess.add('true');

                Integer chunk = 100;
                List<Map<String,String>> uploadObjectList = new List<Map<String,String>>();
                List<OpportunityLineItem> slicearray = new List<OpportunityLineItem>();
                for(Integer i=0; i<(dealLineItemsToUpsert.size() / chunk)+1; i++){
                    slicearray = new List<OpportunityLineItem>();
                    for(Integer j=(i*chunk); (j<(i*chunk)+chunk) && j<dealLineItemsToUpsert.size(); j++){
                        slicearray.add(dealLineItemsToUpsert[j]);
                    }
                    if(!slicearray.isEmpty()){
                        Map<String,String> uploadObjectMap = new Map<String,String>();
                        uploadObjectMap.put('ObjectName__c',System.Label.CRM_Reprice_OpportunityLineItem_Name);
                        uploadObjectMap.put('InputObjectData__c',JSON.serialize(slicearray));
                        uploadObjectMap.put('DealId__c',opportunity.Id);
                        uploadObjectMap.put('status__c',System.Label.CRM_InProgressLabel);
                        uploadObjectMap.put('Total_Count__C',String.valueOf(slicearray.size()));
                        uploadObjectList.add(uploadObjectMap);
                    }
                }
                //--WBCTASK000295555--Added to hold flag as false becuase of bulk reprice process and apply newlogic to divide in chunks--End--//

                system.debug('@@uploadObjectList-->'+uploadObjectList.size());
                String parentId = ImportExcelController.uploadObjects(JSON.serialize(uploadObjectList),System.Label.CRM_Reprice_OpportunityLineItem_Name,String.valueOf(opportunity.Id),dealLineItemsToUpsert.size());
                if (parentId!=null){
                    Opportunity opp = opportunity;
                    opp.IsRepriceStarted__c=true;
                    database.update(opp);
                }
            }
        }
        return isBulkRepriceProcess;
    }
    
    /**
     *  Method to call reprice for bulk products from batch
*  @name updateBulkRepriceDealProducts
*  @param List of Opportunity product
*  @return none
*  @throws none
     * */
     public static void updateBulkRepriceDealProducts(String listStr){
          List<OpportunityLineItem> dealLineItemsToUpsert = (List<OpportunityLineItem>)
                                    System.JSON.deserialize(listStr,List<OpportunityLineItem>.class);
          ApexUtil.isTriggerInvoked = true;
          Database.UpsertResult[] result = Database.Upsert(dealLineItemsToUpsert, false);       
     }
    
/**
    *  Method to add price book entry period for all deal products on before insert and update trigger
*  @name addPBEPforDealProducts
*  @param List of Opportunity product
*  @return none
*  @throws none
    */    
    public static void addPBEPforDealProducts(OpportunityLineItem[] lineItemList){
        Set<String> setProductCode = new Set<String>();
        String dealId = '';
        for(OpportunityLineItem record : lineItemList){
            setProductCode.add(record.Product_Code__c);
            dealId= record.OpportunityId;
        }
        
        Opportunity opportunity = [SELECT id,RecordTypeId,RecordType.Name,Sales_Organisation__c,
                                   Account.Digital_Country_Code__c,StageName,Account.Class_of_Trade__c,
                                   Pricebook2Id,Pricebook2.Name,AccountId,CurrencyISOCode,External_Id__c, CloseDate,Start_Date__c 
                                   FROM Opportunity 
                                   WHERE Id =: dealId LIMIT 1];
        String accountCOT = opportunity.Account.Class_of_Trade__c !=null? opportunity.Account.Class_of_Trade__c.toUpperCase():'';
        Map<String, list<Pricebook_Entry_Period__c>> mapUniqueKeyToValidPBEP = getValidPBEPForProduct(opportunity, setProductCode);
        for(OpportunityLineItem record : lineItemList){
            String strKey = accountCOT != null ?record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode + '-'+ accountCOT:record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode ;                            
            Boolean isPBEP=false;
            //if ( mapUniqueKeyToValidPBEP.containsKey(strKey)){
            if ( accountCOT!='RETAIL COST' && accountCOT!='MENU' && mapUniqueKeyToValidPBEP.containsKey(strKey)){
                list<Pricebook_Entry_Period__c> pbepList = mapUniqueKeyToValidPBEP.get(strKey);
                if(pbepList !=null) {
                    for(Pricebook_Entry_Period__c pbep :pbepList){
                        if(pbep.Price_Type__c.toUpperCase() == accountCOT && record.Start_Date__c >= pbep.Start_Date__c && record.End_Date__c <= pbep.End_Date__c){
                            record.Pricebook_Entry_Period__c = pbep.Id;
                            isPBEP=true;
                            break;
                            //record.ListPrice__c = mapUniqueKeyToValidPBEP.get(strKey).List_Price__c;
                        }
                    }
                }
            }
            strKey = record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode  + '-' + 'PROMOTION';
            list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
            if ( mapUniqueKeyToValidPBEP.containsKey(strKey)){
                pbepList = mapUniqueKeyToValidPBEP.get(strKey);
            }
            strKey = record.Product_Code__c +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode  + '-' + 'DEALER';
            if ( mapUniqueKeyToValidPBEP.containsKey(strKey)){
                pbepList.addAll(mapUniqueKeyToValidPBEP.get(strKey));
            } 
            if(pbepList!=null) {
                for(Pricebook_Entry_Period__c pbep :pbepList){
                    if(record.Start_Date__c >= pbep.Start_Date__c && record.End_Date__c <= pbep.End_Date__c){
                        record.ListPrice__c = pbep.List_Price__c;
                        if (((accountCOT=='RETAIL COST' || accountCOT=='MENU')&& !isPBEP) || opportunity.Pricebook2.Name == 'WB Non-IP - US' || opportunity.Pricebook2.Name =='WB Non-IP - CA'){
                            record.Pricebook_Entry_Period__c = pbep.Id;   
                            isPBEP=true;                            
                        }
                        break;                                
                    }
                }
            }
            
            if(!isPBEP){
                record.addError(System.Label.CRM_Upload_Message_PBEP);
            }
        }
    }

    //--ER-007325--move validation rule in code for deleting newly added dp from revised deal for DFI/POS for SDS S2S--Start--//
    //--ER-007676--check for all DPs in cancel, not allow to submit--Start--//
    /**
    *  Method to allow newly added deal product to delete from revised deal 
    *  @name validateDealProductBeforeCancelAndDelete
    *  @param lineItemList - List of Opportunity product
    *  @param isDelete - flag to identify action delete or insert/update
    *  @return none
    *  @throws none
    **/
    public static void validateDealProductBeforeCancelAndDelete(List<OpportunityLineItem> lineItemList, boolean isDelete){
        Boolean allowToProcess = true;
        for(OpportunityLineItem record: lineItemList){
            if(isDelete){       //--ER-007325-validate on Delete DPs action--//
                if(record.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL){
                    if(record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || 
                            record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED || 
                            (record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED && 
                                record.Credit_Note_Item__c != null)){
                        allowToProcess = false;
                        record.addError(System.Label.CRMJV_POSDeal_Restrict_ProductDeletion);
                    }
                }
                if(record.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL){
                    if(String.isBlank(record.NR_Deal_Product_Unique_Key__c) && 
                            !record.Is_Product_Added_To_Revised_Deal__c && 
                            (record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || 
                                record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED || 
                                record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED)){
                        allowToProcess = false;
                        record.addError(System.Label.CRMJV_DFIDeal_Restrict_ProductDeletion);
                    }
                }
            }else{       //--ER-007676-validate on cancel DPs in Insert/Update action--//
                if(record.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL && 
                        record.DFI_Status__c == CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL){
                    if(record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED){
                        allowToProcess = false;
                        record.addError(System.Label.CRMJV_Planned_DFIDeal_Restrict_ProductCancel);
                    }else if(record.Deal_Stage_Name__c == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED &&
                            record.Is_Product_Added_To_Revised_Deal__c){
                        allowToProcess = false;
                        record.addError(System.Label.CRMJV_Revised_DFIDeal_Restrict_ProductCancel);   
                    }
                }
            }
        }
        if(!allowToProcess){
            return;
        }
    }
    //--ER-007325--move validation rule in code for deleting newly added dp from revised deal for DFI/POS for SDS S2S--End--//
    //--ER-007676--check for all DPs in cancel, not allow to submit--End--//

    //--W-017642-Added to get isJVSalesOrg boolean flag for JV product-Start--//
    global Boolean getIsJVSalesOrg(){
        Boolean JVorg = false;
        if(deal != null && deal.Account != null && (deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || 
                        deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
            JVorg = true;
        }
        return JVorg;
    }
    //--W-017642-Added to get isJVSalesOrg boolean flag for JV product-End--//
    
    //Added to get isNRDealJV boolean flag for CRM-JV -Start--//
    global Boolean getIsNRDealJV(){
        Boolean NR_Deal = false;
        if(deal.StageName ==CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT  && deal!= null && deal.Account != null && (deal.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DFI_DEAL || deal.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_PLANNING_DEAL || deal.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_POS_DEAL) && (deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || 
                        deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
            NR_Deal = true;
        }
        return NR_Deal;
    }
    //Added to get isNRDealJV boolean flag for CRM-JV -END--//
}