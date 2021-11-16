/**
   @Author Accenture
   @name CRM_UploadExtractCreditNoteItem_POSDeal
   @CreateDate 30 Apr 2020
   @Description This class is used to upload (update/insert) the Credit Note Items /products US#925.
   @Version <1.0>
*/
global with sharing class CRM_UploadExtractCreditNoteItem_POSDeal{

    public Boolean isPageReadOnly {get; set;}
    public Boolean importBtnReadOnly {get; set;}
    public Boolean editableFieldsReadOnly {get; set;}
    public Id creditNoteId;
    public static Integer totalFailedRecords;
    public String handsontableversion{get; set;}
    public String profileName;
    public Boolean exportBtnReadOnly {get; set;}
    
    /** 
    *  @Description - constructor
    *  @name  CRM_UploadExtractCreditNoteItem  
    */ 
    global CRM_UploadExtractCreditNoteItem_POSDeal(ApexPages.StandardController stdController) {
        creditNoteId = stdController.getId();
        List<Credit_Note__c> lstCreditNote = [SELECT id, Account__r.Digital_Country_Code__c, CurrencyISOCode,Status__c FROM Credit_Note__c 
                                              WHERE Id =: creditNoteId LIMIT 1];
        isPageReadOnly = lstCreditNote[0].Status__c ==  CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED ? true :false;
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
        Id profileId=userinfo.getProfileId();
        profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        editableFieldsReadOnly = CRM_AppConstants.CRM_UPLOAD_EXTRACT_READ_ONLY_PROFILES.contains(profileName)?true:false;
        importBtnReadOnly = (lstCreditNote[0].Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED || editableFieldsReadOnly) ? true :false;
        List<Credit_Note_Item__c> cniRecordList = [SELECT Id FROM Credit_Note_Item__c WHERE Credit_Note__c=:creditNoteId LIMIT 1];
        exportBtnReadOnly = cniRecordList.size()==0?true:false;
    }
    
    /** 
     *  Method to upload credit note item records as per the json data received from uploading the csv file
     *  @name excelUploadPOSCreditNoteItem
     *  @param String listStr, String creditNoteId
     *  @return List<String>
     *  @throws None
     */
    public static List<String> excelUploadPOSCreditNoteItem(String listStr, String creditNoteId) {
        List<String> errList= new List<String>();    
        try{
            List<CreditNoteItemImportWrapper> result = importCreditNoteItems(listStr, creditNoteId);
            for(CreditNoteItemImportWrapper recordWrapper : result){
                if (recordWrapper.isError){
                    String jsonstr='{"validation" : "'+ recordWrapper.validation+'", "record":'+JSON.serialize(recordWrapper.lineItem)+'}';
                    errList.add(jsonstr);
                }
            }
        }catch(Exception excep) {
            throw new CRM_UploadCreditNoteItem_POSDealException(excep.getMessage());       
        }
        return errList;
    }
    
    /** 
     *  Method to parse the JSON payload containing the deal product records, validate it, process the successful ones and create credit note item records for those, update deal products back with the credit note item reference
     *  @name importCreditNoteItems
     *  @param String creditNoteItemRecords, String creditNoteId
     *  @return CreditNoteItemImportWrapper
     *  @throws None
     */
    public static List<CreditNoteItemImportWrapper> importCreditNoteItems(String creditNoteItemRecords, String creditNoteId ){
        Set<Id> dealIdSet = new Set<Id>(); //Variable to store all Deal Ids i.e. Opportunity Ids
        Set<String> dealCodeSet = new Set<String>(); //Variable to store all Deal Codes
        Set<Id> creditNoteProcessDealIdSet = new Set<Id>(); //Variable to store all Deal Ids i.e. Opportunity Ids, for all the line items which can be processed from the import file i.e. no validation errors
        Set<String> invalidDealIdProductCodeSet = new Set<String>(); //Variable to store the invalid Deal Id and Product Code combination
        Map<String, String> dealCodedealIdMap = new Map<String, String>(); //Variable to store the Deal Code (as key) vs Deal Id (as value)
        Map<String, String> dealIdProductIdImportMap = new Map<String, String>(); //Variable to store the Deal Id and Product Code combination (as key) and validation messages (as value)
        Map<String, String> dealIdProductIdDetailsMap = new Map<String, String>(); //Variable to store the Deal Id and Product Code combination (as key) and deal product i.e. line items values as we get the import file (as value)
        Map<String, String> cNoteLI_UK_dealProductCode = new Map<String, String>(); //Variable to store the credit note item unique key (as key) and Deal Id and Product Code combination (as value) for all the products for which credit note items can be created (no validation errors)
        Map<String, String> cNoteUniqueKeyDealProductId = new Map<String, String>(); //Variable to store the credit note item unique key (as key) and deal product Id (as value)
        List<Credit_Note_Item__c> creditNoteItemUploadList = new List<Credit_Note_Item__c>(); //Variable to store the credit note item records which will be processed (upsert)
        List<CreditNoteItemImportWrapper> creditNoteItems = new List<CreditNoteItemImportWrapper>(); //Variable to deserialize the JSON received as input, containing the records (deal products) to be processed
        List<DealCreditNote__c> dealCreditNoteCreateList = new List<DealCreditNote__c>(); //Variable to store the deal credit note records which will be processed (upsert)
        List<Database.UpsertResult> creditNoteItemUpsertResult = new List<Database.UpsertResult>(); //Variable to store the credit note item upsert records result
        List<Database.UpsertResult> dealCreditNoteUpsertResult = new List<Database.UpsertResult>(); //Variable to store the deal credit note upsert records result
        List<OpportunityLineItem> optyLineItemUpdateList = new List<OpportunityLineItem>(); //Variable to store the deal product records which will be updated with the credit note item reference
        Credit_Note__c cNote = [SELECT Id, Co_op_Reason__c, Account__c, CurrencyIsoCode, Credit_Note_Type__c, RecordType.DeveloperName 
                                FROM Credit_Note__c WHERE Id =: creditNoteId LIMIT 1];
        creditNoteItems = (List<CreditNoteItemImportWrapper>)System.JSON.deserialize(creditNoteItemRecords, List<CreditNoteItemImportWrapper>.class);
        
        for(CreditNoteItemImportWrapper cniwrap : creditNoteItems){
               dealCodeSet.add(cniwrap.lineItem.Deal_Code__c);
        }
        
        for(Opportunity opp : [Select Id, Deal_Code__c FROM Opportunity WHERE Deal_Code__c IN:dealCodeSet]){
            dealCodedealIdMap.put(opp.Deal_Code__c, opp.Id);
        }
        
        for(CreditNoteItemImportWrapper cniwrap : creditNoteItems){
            dealIdSet.add(dealCodedealIdMap.get(cniwrap.lineItem.Deal_Code__c));
            dealIdProductIdImportMap.put(dealCodedealIdMap.get(cniwrap.lineItem.Deal_Code__c) + '-' + cniwrap.lineItem.ProductCode__c, '');
            dealIdProductIdDetailsMap.put(dealCodedealIdMap.get(cniwrap.lineItem.Deal_Code__c) + '-' + cniwrap.lineItem.ProductCode__c, 
                                          (cniwrap.lineItem.Reason__c == null?'null':cniwrap.lineItem.Reason__c) + '|' +
                                          (cniwrap.lineItem.Requested_Co_op_Amount__c == null?0:cniwrap.lineItem.Requested_Co_op_Amount__c) + '|'+ 
                                          (cniwrap.lineItem.Customer_Reference_Number__c== null?'null':cniwrap.lineItem.Customer_Reference_Number__c) + '|'+
                                          (cniwrap.lineItem.Comments__c== null?'null':cniwrap.lineItem.Comments__c));
        }
        
        CreditNoteItemProcessDetailsWrapper cNoteWrap = validateCreditNoteItemRecords(dealIdSet, dealIdProductIdImportMap, dealIdProductIdDetailsMap, cNote);
        creditNoteProcessDealIdSet = cNoteWrap.creditNoteProcessDealIdSet;
        cNoteUniqueKeyDealProductId = cNoteWrap.cNoteUniqueKeyDealProductId;
        cNoteLI_UK_dealProductCode = cNoteWrap.cNoteLI_UK_dealProductCode;
        creditNoteItemUploadList = cNoteWrap.creditNoteItemUploadList;
        
        if(!creditNoteItemUploadList.isEmpty()){
            try{
                dealCreditNoteCreateList = buildDealCreditNoteItemRecord(creditNoteProcessDealIdSet, cNote);
                dealCreditNoteUpsertResult = Database.upsert(dealCreditNoteCreateList,DealCreditNote__c.Unique_Key__c,false);
                creditNoteItemUpsertResult = Database.upsert(creditNoteItemUploadList,Credit_Note_Item__c.Unique_Id__c,false);
                for(Integer i=0;i<creditNoteItemUpsertResult.size();i++){
                    if (!creditNoteItemUpsertResult.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = creditNoteItemUpsertResult.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        Credit_Note_Item__c cni = (Credit_Note_Item__c)creditNoteItemUploadList.get(i);
                        String dealProductCode = cNoteLI_UK_dealProductCode.get(cni.Unique_Id__c);
                        dealIdProductIdImportMap.put(dealProductCode, failedDML);
                    }else{
                        Credit_Note_Item__c cni = (Credit_Note_Item__c)creditNoteItemUploadList.get(i);
                        Id dealProductId = cNoteUniqueKeyDealProductId.get(cni.Unique_Id__c);
                        OpportunityLineItem oli = new OpportunityLineItem(Id = dealProductId, Credit_Note_Item__c = cni.Id, 
                                                                          Co_op_Actual_Amount__c = (cNote.Credit_Note_Type__c == CRM_AppConstants.CREDIT_NOTE_TYPE_REVERSAL)?cni.Amount__c*(-1):cni.Amount__c);
                        optyLineItemUpdateList.add(oli);
                    }
                }
                if(!optyLineItemUpdateList.isEmpty()){
                    Database.SaveResult[] result = Database.Update(optyLineItemUpdateList, false);
                }
            } catch(Exception excep) {
                throw new CRM_UploadCreditNoteItem_POSDealException(excep.getMessage());          
            }
        }
        for(CreditNoteItemImportWrapper cniwrap : creditNoteItems){
            String validationErrorMessage = dealIdProductIdImportMap.get(dealCodedealIdMap.get(cniwrap.lineItem.Deal_Code__c) + '-' + cniwrap.lineItem.ProductCode__c);
            if(String.isNotBlank(validationErrorMessage) && validationErrorMessage!='Validation Success!'){
                cniwrap.isError = true;
                cniwrap.validation = validationErrorMessage;
            }else if(String.isBlank(validationErrorMessage)){
                cniwrap.isError = true;
                cniwrap.validation = Label.CRM_CreditNote_UploadExtract_InvalidDealIdProductCode;
            }
        }
        return creditNoteItems;
    }
    
    /** 
     *  Method to validate the Credit Note Item records to be processed and for successful records, prepare the list to process it (upsert) 
     *  @name validateCreditNoteItemRecords
     *  @param Set<Id> dealIdSet, Map<String, String> dealIdProductIdImportMap, Map<String, String> dealIdProductIdDetailsMap, Credit_Note__c cNote
     *  @return CreditNoteItemProcessDetailsWrapper
     *  @throws None
     */
    private static CreditNoteItemProcessDetailsWrapper validateCreditNoteItemRecords(Set<Id> dealIdSet, Map<String, String> dealIdProductIdImportMap, 
                                                                                     Map<String, String> dealIdProductIdDetailsMap, Credit_Note__c cNote){
        CreditNoteItemProcessDetailsWrapper cNoteItemWrapper = new CreditNoteItemProcessDetailsWrapper();
        Set<String> failedORRejectedStatus = new Set<String>{CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED, CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED_IN_SAP};
        Set<String> usSalesOrgs = new Set<String>(CRM_AppConstants.US_SALES_ORGS);
        //Added For CRM-JV
        usSalesOrgs.add(CRM_AppConstants.TERRITORY_SDS_US_CODE);
        usSalesOrgs.add(CRM_AppConstants.TERRITORY_SDS_CANADA_CODE);                                                                                  
        for(OpportunityLineItem oli : [Select Id, OpportunityId, Start_Date__c, End_Date__c, 
                                       ProductCode, Product2Id, Opportunity.AccountId, 
                                       Status__c, Accruing_Tactic__c, Reason__c, Credit_Note_Item__c, 
                                       Credit_Note_Item__r.Credit_Note__r.Status__c,
                                       Opportunity.Sales_Organisation__c, POS_Quantity__c, POS_Rebate__c, 
                                       Product2.Name, Name, Co_op_Actual_Amount__c, Actual_Spend_Amount__c,
                                       Opportunity.StageName, Opportunity.RecordType.DeveloperName  
                                       FROM OpportunityLineItem 
                                       WHERE OpportunityId IN:dealIdSet LIMIT 50000]){
                                           if(dealIdProductIdImportMap.containsKey(oli.OpportunityId+'-'+oli.ProductCode)){
                                               String[] splitArray = dealIdProductIdDetailsMap.get(oli.OpportunityId+'-'+oli.ProductCode).split('\\|');
                                               if(oli.Credit_Note_Item__c!=null && !failedORRejectedStatus.contains(oli.Credit_Note_Item__r.Credit_Note__r.Status__c)){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_CreditNoteExists);
                                               }else if(oli.Opportunity.RecordType.DeveloperName!=CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_OnlyPhysicalPOSDeals);
                                               }else if(oli.Opportunity.StageName!=CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_DealStatusCommitted);
                                               }else if(oli.Opportunity.AccountId!=cNote.Account__c){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_DifferentAccount);
                                               }/*else if(!oli.Accruing_Tactic__c){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_AccruingTacticTrue);
                                               }*/else if(!usSalesOrgs.contains(oli.Opportunity.Sales_Organisation__c)){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_DealSalesOrgUS);
                                               }else if(oli.Reason__c != splitArray[0] && cNote.Co_op_Reason__c != splitArray[0]){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_DifferentCoOpReason);
                                               }else if((splitArray[1]!= String.ValueOf(0) && cNote.RecordType.DeveloperName == CRM_AppConstants.CREDIT_NOTE_PHYSICAL_RC_API_NAME && Double.valueOf(splitArray[1])< 0)||
                                                       (cNote.RecordType.DeveloperName == CRM_AppConstants.CREDIT_NOTE_PHYSICAL_RC_API_NAME && oli.Co_op_Actual_Amount__c < 0)){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_NoNegativeAmount);
                                               }else if((splitArray[1]!= String.ValueOf(0) && cNote.RecordType.DeveloperName == CRM_AppConstants.CREDIT_NOTE_PHYSICAL_REVERSE_RC_API_NAME && Double.valueOf(splitArray[1]) > 0)||
                                                       (cNote.RecordType.DeveloperName == CRM_AppConstants.CREDIT_NOTE_PHYSICAL_REVERSE_RC_API_NAME && oli.Co_op_Actual_Amount__c > 0)){
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, Label.CRM_CreditNote_UploadExtract_NoPositiveAmount);}
                                               else{
                                                   dealIdProductIdImportMap.put(oli.OpportunityId+'-'+oli.ProductCode, 'Validation Success!');
                                                   Credit_Note_Item__c cniRecord = buildCreditNoteItemRecord(oli, cNote, splitArray);
                                                   cNoteItemWrapper.creditNoteProcessDealIdSet.add(oli.OpportunityId);
                                                   cNoteItemWrapper.cNoteUniqueKeyDealProductId.put(cniRecord.Unique_Id__c, oli.Id);
                                                   cNoteItemWrapper.cNoteLI_UK_dealProductCode.put(cniRecord.Unique_Id__c, oli.OpportunityId+'-'+oli.ProductCode);
                                                   cNoteItemWrapper.creditNoteItemUploadList.add(cniRecord);
                                               }
                                           }
                                       }
        return cNoteItemWrapper;
    }
    
    /** 
     *  Method to build the Credit Note Item records to be processed (upsert) 
     *  @name buildCreditNoteItemRecord
     *  @param OpportunityLineItem oli, Credit_Note__c cNote, String[] splitArray
     *  @return Credit_Note_Item__c
     *  @throws None
     */
    private static Credit_Note_Item__c buildCreditNoteItemRecord(OpportunityLineItem oli, Credit_Note__c cNote, String[] splitArray){
        Credit_Note_Item__c cniRecord = new Credit_Note_Item__c();
        oli.Co_op_Actual_Amount__c = oli.Co_op_Actual_Amount__c < 0?oli.Co_op_Actual_Amount__c *(-1):oli.Co_op_Actual_Amount__c;
        
        if(splitArray[1] != String.ValueOf(0)){
            if(Double.valueOf(splitArray[1]) < 0){
                splitArray[1] = String.ValueOf(Double.valueOf(splitArray[1]) * (-1)); 
            }else{
                splitArray[1] = splitArray[1];
            }
        }
        cniRecord.Deal__c = oli.OpportunityId;
        cniRecord.Start_Date__c = oli.Start_Date__c;
        cniRecord.End_Date__c = oli.End_Date__c;
        cniRecord.Unique_Id__c = cNote.Id+'-'+oli.OpportunityId+'-'+oli.Id;
        cniRecord.Amount__c = splitArray[1]==String.valueOf(0)?oli.Co_op_Actual_Amount__c:Double.valueOf(splitArray[1]);
        cniRecord.Requested_Co_op_Amount__c = cniRecord.Amount__c;
        cniRecord.Customer_Reference_Number__c = splitArray[2]=='null'?'':splitArray[2];
        cniRecord.Credit_Note__c = cNote.Id;
        cniRecord.Product__c = oli.Product2Id;
        cniRecord.POS_Quantity__c = oli.POS_Quantity__c;
        cniRecord.POS_Rebate__c = oli.POS_Rebate__c;
        cniRecord.Reason__c = splitArray[0]=='null'?cNote.Co_op_Reason__c:splitArray[0];
        cniRecord.Deal_Product_Id__c = oli.Id;
        cniRecord.Deal_Product_Name__c = oli.Name;
        cniRecord.Deal_Product__c = oli.Product2.Name;
        cniRecord.Comments__c = splitArray[3]=='null'?'':splitArray[3];
        return cniRecord;
    }
    
    /** 
     *  Method to build the Deal Credit Note Item records to be processed (upsert) 
     *  @name buildDealCreditNoteItemRecord
     *  @param Set<Id> creditNoteProcessDealIdSet, Credit_Note__c cNote
     *  @return List<DealCreditNote__c>
     *  @throws None
     */
    private static List<DealCreditNote__c> buildDealCreditNoteItemRecord(Set<Id> creditNoteProcessDealIdSet, Credit_Note__c cNote){
        List<DealCreditNote__c> dealCreditNoteCreateList = new List<DealCreditNote__c>();
        for(Id dealId: creditNoteProcessDealIdSet){
            DealCreditNote__c dealCreditNote = new DealCreditNote__c();
            dealCreditNote.Opportunity__c = dealId;
            dealCreditNote.Credit_Note__c = cNote.Id;
            dealCreditNote.Unique_Key__c = dealId+'-'+cNote.Id;
            dealCreditNote.CurrencyIsoCode = cNote.CurrencyIsoCode;
            dealCreditNoteCreateList.add(dealCreditNote);
        }
        return dealCreditNoteCreateList;
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
    /**
    * Method to get logged in uSer Locale
    */
    public boolean getUserLocaleForCSV(){
        String availableLocales = CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c != null ?
                                        CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c : '';
        List<String> lstAvailableLocales = availableLocales.split(',');
        Set<String> setOfLocales = new Set<String>();
        setOfLocales.addall(lstAvailableLocales);
        if(setOfLocales.contains(getUserLocale() )){
            return true;
        }else{
            return false;
        }
    } 
    //End - US : 989
    
    /** 
     *  Method to fetch the Deal Product from DealId  
     *  @name getChunkSizeForTradeTactics
     *  @param None
     *  @return Chunk size in Integer
     *  @throws None
     */
    global Integer getChunkSizeForCreditNoteItems() {
        return CRM_Batch_Size__c.getInstance('Upload Credit Note Items Records') != null ? 
                                        Integer.valueOf(CRM_Batch_Size__c.getInstance('Upload Credit Note Items Records').Batch_Size__c) : 100;
    }
    
    /** 
     *  Method to fetch the Deal Product from DealId  
     *  @name getOpportunityLineItems
     *  @param Id opportunityId
     *  @return CRM_UploadExtractCreditNoteItem.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<CreditNoteItemWrapper> getCreditNoteLineItemTactics(Id creditNoteId) {
        // Construct a list of Credit Note Item 
        List<CreditNoteItemWrapper> returnWrapperList = new List<CreditNoteItemWrapper>();
        // Find what products are in the Deal
        try{ 
            for(Credit_Note_Item__c lineItem: [SELECT Deal__r.Name, Amount__c, Comments__c, 
                                               Commitment_Number__c, Credit_Note__c, CurrencyIsoCode, Deal_Product_Id__c,
                                               Customer_Reference_Number__c, Deal_Product_Name__c, Deal_Product__c, Deal__c, End_Date__c, Id, Name, POS_Actuals__c,
                                               POS_Forecast__c, POS_Rebate__c, POS_Quantity__c, ProductCode__c, Product__r.name, Product__c, Reason__c,
                                               Requested_Co_op_Amount__c, Start_Date__c, Status__c, Deal__r.Deal_Code__c 
                                               FROM Credit_Note_Item__c
                                               WHERE Credit_Note__c = :creditNoteId 
                                               ORDER BY Deal_Product_Name__c LIMIT 50000]
               ){
                   CreditNoteItemWrapper lineItemWrapper =  mapCreditNoteItemFields(lineItem);
                   returnWrapperList.add(lineItemWrapper);
               } 
        }
        catch(Exception excep) {
            throw new CRM_UploadCreditNoteItem_POSDealException(excep.getMessage());
        } 
        return returnWrapperList;
    }
    
    /** 
     *  Method to MAP tactic fields to the wrapper from Deal Product  
     *  @name  mapCreditNoteItemFields
     *  @param OpportunityLineItem lineItem
     *  @return CRM_UploadExtractCreditNoteItem.CreditNoteItemWrapper 
     *  @throws None
     */
    private static CreditNoteItemWrapper mapCreditNoteItemFields(Credit_Note_Item__c lineItem){
        CreditNoteItemWrapper lineItemWrapper = new CreditNoteItemWrapper();
        lineItemWrapper.existingId = lineItem.id;
        lineItemWrapper.productCode = lineItem.ProductCode__c == null ? '' : lineItem.ProductCode__c;
        lineItemWrapper.dealName = lineItem.Deal__r.Name == null ? '' : lineItem.Deal__r.Name;
        lineItemWrapper.dealCode = lineItem.Deal__r.Deal_Code__c;
        lineItemWrapper.productName = lineItem.Product__r.name == null ? '' : lineItem.Product__r.name;
        lineItemWrapper.commitmentNum =  lineItem.Commitment_Number__c;
        lineItemWrapper.startDate = String.valueOf(lineItem.Start_date__c);
        lineItemWrapper.endDate = String.valueOf(lineItem.End_date__c);
        lineItemWrapper.coopReason = lineItem.Reason__c == null ? '' : lineItem.Reason__c ;
        lineItemWrapper.coopComments = lineItem.Comments__c== null ? '' : lineItem.Comments__c;
        lineItemWrapper.posRebate = lineItem.POS_Rebate__c;
        lineItemWrapper.posQuantity = lineItem.POS_Quantity__c;
        lineItemWrapper.posForecast = lineItem.POS_Forecast__c ;
        lineItemWrapper.coopReqAmount = lineItem.Requested_Co_op_Amount__c;
        lineItemWrapper.posActual= lineItem.POS_Actuals__c; 
        lineItemWrapper.dealProductId = lineItem.Deal_Product_Id__c;
        lineItemWrapper.coopActualAmt = lineItem.Amount__c == null ? 0 :(lineItem.Amount__c.SetScale(2));
        lineItemWrapper.custReference = lineItem.Customer_Reference_Number__c == null ? '' : lineItem.Customer_Reference_Number__c;
        lineItemWrapper.status = lineItem.Status__c== null ? '' : lineItem.Status__c;
        return lineItemWrapper;
    }
    
    /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setOpportunityLineItems
     *  @param CRM_UploadExtractCreditNoteItem.CreditNoteItemWrapper[] and Opportunity Id
     *  @return CreditNoteItemWrapper with successful upsert and failed records 
     *  @throws None
     */
    @RemoteAction
    global static List<CreditNoteItemWrapper> setCreditNoteLineItems(List<CreditNoteItemWrapper>tacticWrapperList, Id creditNoteId) {
        List<CreditNoteItemWrapper> lstToUpdateCNoteItemWrap = new List<CreditNoteItemWrapper>();
        List<Credit_Note_Item__c> lstToUpdateCreditNoteItem = new List<Credit_Note_Item__c>();
        List<CreditNoteItemWrapper> listLiWrappersToDelete = new List<CreditNoteItemWrapper>();
        List<OpportunityLineItem> optyLineItemUpdateList = new List<OpportunityLineItem>();  
        totalFailedRecords = 0;
        //Get Credit_Note__c Details like CurrencyCode,Pricebook and existing Deal products for the ProductCode
        List<Credit_Note__c> lstCreditNote = [SELECT id, Account__r.Digital_Country_Code__c, CurrencyISOCode,Status__c, Credit_Note_Type__c 
                                              FROM Credit_Note__c WHERE Id =: creditNoteId LIMIT 1];
        if(!lstCreditNote.isEmpty()){
            Credit_Note__c creditNote = lstCreditNote[0];
            // set the index for each line item
            for(Integer i=0; i< tacticWrapperList.size(); i++) {
                tacticWrapperList[i].rowIndex = i;
            }
            // Get all the product codes and set the validation if any of the mandatory fields are not entered.
            for(CreditNoteItemWrapper tacticWrapper : tacticWrapperList){
                if(tacticWrapper.isRowRemoved!=null && tacticWrapper.isRowRemoved == true){ 
                    listLiWrappersToDelete.add(tacticWrapper);  
                }  
            }  
            //---------------------------------Delete Row Functionality begins-----------------------------------------------------//
            if(!listLiWrappersToDelete.isEmpty()) {
               Integer[] lstRowIndexToRemove =  deleteCreditNoteLineItems(listLiWrappersToDelete,creditNote.Id);
                for(Integer i= lstRowIndexToRemove.size()-1; i >=0; i--) {
                    Integer indexToRemove = lstRowIndexToRemove[i];
                    tacticWrapperList.remove(indexToRemove);
                }
            }
            //---------------------------------Delete Row Functionality ends-----------------------------------------------------//
            for(CreditNoteItemWrapper tacticRecord : tacticWrapperList){
                if(tacticRecord.isRowModified != null && tacticRecord.isRowModified == true && (tacticRecord.validation == null  || tacticRecord.validation == '')){
                    Credit_Note_Item__c tacticItem = new Credit_Note_Item__c();
                    tacticItem.Id=tacticRecord.existingId;
                    tacticItem.Amount__c = tacticRecord.coopActualAmt == null ? tacticRecord.coopActualAmt : (tacticRecord.coopActualAmt.SetScale(2));
                        tacticItem.Requested_Co_op_Amount__c = tacticItem.Amount__c;
                    tacticItem.Customer_Reference_Number__c = tacticRecord.custReference;
                    tacticItem.Comments__c = tacticRecord.coopComments;
                    lstToUpdateCreditNoteItem.add(tacticItem);  
                    lstToUpdateCNoteItemWrap.add(tacticRecord);
                    OpportunityLineItem oli = new OpportunityLineItem(Id = tacticRecord.dealProductId, 
                                                                      Co_op_Actual_Amount__c = (creditNote.Credit_Note_Type__c == CRM_AppConstants.CREDIT_NOTE_TYPE_REVERSAL)?tacticItem.Amount__c*(-1):tacticItem.Amount__c);
                    optyLineItemUpdateList.add(oli);
                }
            }
            
            if(!lstToUpdateCreditNoteItem.isEmpty()){
                Database.SaveResult[] result = Database.Update(lstToUpdateCreditNoteItem, false);
                Database.SaveResult[] optyLineItemUpdateResult = Database.Update(optyLineItemUpdateList, false);
                upsertDMLResultForTactics(result,lstToUpdateCNoteItemWrap,creditNote.Id);
            }
            //--------------------------------Upsert for Product Code Functionality Ends--------------------------------------// 
            if(!tacticWrapperList.isEmpty()) {
                tacticWrapperList[0].numFailedRecords = totalFailedRecords;
            } 
        }
        return tacticWrapperList; 
    }  
     
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
    */
    global static void upsertDMLResultForTactics(list<Database.SaveResult> results, 
                                                 List<CreditNoteItemWrapper> tacticWrapperList,
                                                 Id creditNoteId) {
        Map<Id,Credit_Note_Item__c> mapTacticRecords = new Map<Id,Credit_Note_Item__c> ([SELECT Amount__c,Comments__c,
                                                                                            Commitment_Number__c,Credit_Note__c,CurrencyIsoCode,Customer_Reference_Number__c,
                                                                                            Deal_Product_Id__c,Deal_Product_Name__c,Deal_Product__c,Deal__c,End_Date__c,Id,Name,POS_Actuals__c,
                                                                                            POS_Forecast__c,POS_Rebate__c,ProductCode__c,Product__c,Reason__c,Requested_Co_op_Amount__c,Start_Date__c,Status__c
                                                                                            FROM Credit_Note_Item__c
                                                                                            WHERE Credit_Note__c = :creditNoteId 
                                                                                            AND Credit_Note__r.Status__c =: CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED 
                                                                                            ORDER BY Deal_Product_Name__c LIMIT 50000]);

        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                totalFailedRecords++;
                tacticWrapperList.get(i).validation = failedDML;
                tacticWrapperList.get(i).recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
            }else{
                if(mapTacticRecords.containsKey(results.get(i).Id)){
                    Decimal coopActualAmount = (mapTacticRecords.get(results.get(i).Id).Amount__c) == null ?
                        (mapTacticRecords.get(results.get(i).Id).Amount__c) : (mapTacticRecords.get(results.get(i).Id).Amount__c.SetScale(2));
                            tacticWrapperList.get(i).existingId = results.get(i).getId(); 
                    tacticWrapperList.get(i).validation = System.label.CRM_Upload_Message_Updated;
                    tacticWrapperList.get(i).custReference = mapTacticRecords.get(results.get(i).Id).Customer_Reference_Number__c;
                    tacticWrapperList.get(i).status = mapTacticRecords.get(results.get(i).Id).Status__c; 
                    tacticWrapperList.get(i).coopActualAmt = coopActualAmount;
                    tacticWrapperList.get(i).isRowModified = false; 
                    tacticWrapperList.get(i).recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                }
            }
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
     *  Method to fetch user input and perform delete operation on existing records
     *  @name deleteCreditNoteLineItems
     *  @param CRM_UploadDealProductsController.CreditNoteItemWrapper[] and Opportunity Id
     *  @return Integer[] list of row indexes to be removed from original list
     *  @throws None
     */ 
    global static Integer[] deleteCreditNoteLineItems(List<CreditNoteItemWrapper> lstLiWrappersToDelete,Id creditNoteid) {
        List<Id> listLineItemsToRemove = new List<Id>();
        List<CreditNoteItemWrapper> listLiWrappersToRemove = new List<CreditNoteItemWrapper>(); 
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        Id cNoteId;
        if(lstLiWrappersToDelete!=null) {
            for (CreditNoteItemWrapper wrapper : lstLiWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    cNoteId = creditNoteid;
                    wrapper.isRowRemoved  = false;
                    wrapper.isRowModified = false;
                    listLiWrappersToRemove.add(wrapper);                    
                    listLineItemsToRemove.add(wrapper.existingId);
                }
                else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }
            }
        }
        try {
            list<Database.DeleteResult> deleteLiResults = Database.delete(listLineItemsToRemove,false);
            for(Integer i=0; i < deleteLiResults.size(); i++){
                CreditNoteItemWrapper lineItemWrapper = listLiWrappersToRemove.get(i);
                lineItemWrapper.isRowModified = false;
                lineItemWrapper.isRowRemoved = false;
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    totalFailedRecords++;
                    lineItemWrapper.existingId = listLineItemsToRemove[0];
                    lineItemWrapper.validation = failedDML;
                    lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                } else {
                    lstRowIndexToRemove.add(lineItemWrapper.rowIndex);
                }
            }
        }catch(Exception e) {
            logException(cNoteId,e);
            for(Integer i=0; i < listLiWrappersToRemove.size(); i++){
                CreditNoteItemWrapper lineItemWrapper = listLiWrappersToRemove[i];
                lineItemWrapper.isRowModified = false;
                lineItemWrapper.existingId = lineItemWrapper.existingId;
                lineItemWrapper.validation = e.getMessage();
                lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
            }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove;
    }
    
    /** 
     *  Method to log exception 
     *  @name  logException
     *  @param Id creditNoteId,Exception e
     *  @return none 
     *  @throws None
     */
    public static void logException(Id creditNoteId,Exception e){
        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
        errorLog.recordId = creditNoteId;
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
        errorLog.lineNumber = String.valueOf(e.getLineNumber());
        errorLog.errorMessage = e.getMessage();
        errorLog.stackTrace = e.getStackTraceString(); 
        // Call the logError method which will insert all errors into CRM_Error_Log__c object
        CRM_ErrorLogger.logError(errorLog);
    }

    /**
    *  @Description - wrapper class
    *  @name  CreditNoteItemWrapper 
    */
    global class CreditNoteItemWrapper {
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public Integer rowIndex;
        public boolean previouslySelectedForRemoval=false;
        public String  productCode='';
        public String  productName='';
        public String  commitmentNum='';
        public String  startDate ;
        public String  endDate ;
        public String  coopReason='';
        public String  coopComments='';
        public Decimal posRebate;
        public Decimal posQuantity;
        public Decimal posForecast;
        public Decimal coopReqAmount;
        public Decimal posActual;
        public Decimal coopActualAmt;
        public String  status='';
        public String  custReference='';
        public Integer numFailedRecords;  
        //US : 994 
        public string recrodStatus='';
        public string dealName ='';
        public String dealProductId = '';
        public String dealCode = '';
    }
    
    /**
    *  @Description - wrapper class for Credit Note Item data import (as received in the form of JSON payload) and storing validation error details
    *  @name  CreditNoteItemWrapper 
    */
    global class CreditNoteItemImportWrapper {
        public String validation='';
        public boolean isError=false;
        public Credit_Note_Item__c lineItem;
    }
    
    /**
    *  @Description - wrapper class for storing deal, deal Product, credit note item details which will be processed
    *  @name  CreditNoteItemProcessDetailsWrapper 
    */
    global class CreditNoteItemProcessDetailsWrapper {
        public Set<Id> creditNoteProcessDealIdSet = new Set<Id>();
        public Map<String, String> cNoteUniqueKeyDealProductId = new Map<String, String>();
        public Map<String, String> cNoteLI_UK_dealProductCode = new Map<String, String>();
        public List<Credit_Note_Item__c> creditNoteItemUploadList = new List<Credit_Note_Item__c>();
    }
    
    /**
    *  @Description - Exception class
    *  @name  CRM_UploadCreditNoteItem_POSDealException 
    */
    global without sharing class CRM_UploadCreditNoteItem_POSDealException extends Exception {}
}