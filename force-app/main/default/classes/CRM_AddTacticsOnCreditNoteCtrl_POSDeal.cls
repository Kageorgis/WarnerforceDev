/**
   @Author Accenture
   @name CRM_AddTacticsOnCreditNoteCtrl_POSDeal 
   @CreateDate 29 APR 2020
   @Description controller for vf to add deal products on credit Note record
   @Version <1.0>
   @reference
*/
global with sharing class CRM_AddTacticsOnCreditNoteCtrl_POSDeal {
    public boolean isReadOnly{get; set;}
    public static Integer totalFailedRecords;
    
    /* 
     * Constructor with StandardController as parameter
     */
    public CRM_AddTacticsOnCreditNoteCtrl_POSDeal(ApexPages.StandardController stdCon) {
        Id cnId = ApexPages.currentPage().getParameters().get('id');
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId LIMIT 1].Name ;
        
        if(cnId != null){
            List<Credit_Note__c> lstCreditNote = new List<Credit_Note__c>();
            lstCreditNote = [SELECT Status__c FROM Credit_Note__C WHERE Id =:cnId LIMIT 1];
            if(!lstCreditNote .isEmpty()){
                if(lstCreditNote[0].Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED ||
                   	CRM_AppConstants.CRM_UPLOAD_EXTRACT_READ_ONLY_PROFILES.contains(profileName)){
                    isReadOnly = true;
                }
            }
        }
    }
      /**
     *  Method to fetch deal Products to be displayed on credit note record
     *  @name getTactics
     *  @param creditNoteId,cnAccountId - Id of the creditNote and account for which deal Productss needs to fetched
     *  @param recordTypeId - record Type Id Of Credit Note,filter - Filter Wrapper added by user
     *  @return DealProductWrapper[] - list of Deal Products to be made available for user selection
     */
    @RemoteAction
    global static DealProductWrapper[] getTactics(Id creditNoteId, 
                                                  Id cnAccountId, Id recordTypeId,DealProducSearchFiltertWrapper filter, String coopReason) {
        List<DealProductWrapper> lstDealProducts = new List<DealProductWrapper>();
        Set<String> failedORRejectedStatus = new Set<String>{CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED, 
            												 CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED_IN_SAP};
        Set<String> usSalesOrgs = new Set<String>(CRM_AppConstants.US_SALES_ORGS);
        //Added For CRM-JV
        usSalesOrgs.add(CRM_AppConstants.TERRITORY_SDS_US_CODE);
        usSalesOrgs.add(CRM_AppConstants.TERRITORY_SDS_CANADA_CODE);                                              
        String strQuery = 'SELECT Id,Name,OpportunityId,Opportunity.Id,Opportunity.Name,Opportunity.Deal_Code__c,Co_op_Actual_Amount__c,Start_Date__c,End_Date__c,'+
            'Account_Name__c,Product_Code__c,Product2.name,Product2Id,Customer_Reference__c,Reason__c,Status__c,Comments__c,POS_Actual__c,POS_Forecast__c,'+
            'Commitment_Number__c,POS_Rebate__c,POS_Quantity__c,Co_op_Requested_Amount__c,Actual_Spend_Amount__c'+
            ' FROM OpportunityLineItem'+ 
            ' WHERE Status__c = \''+CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED+'\''+
            ' AND Opportunity.AccountId = \''+cnAccountId+'\''+
            ' AND Opportunity.Sales_Organisation__c IN :usSalesOrgs'+
            ' AND Reason__c = :coopReason'+
            ' AND Opportunity.RecordType.DeveloperName = \''+
              CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL+'\''+
            ' AND ('+
            '(Credit_Note_Item__c = null) OR '+
            '(Credit_Note_Item__c != null AND Credit_Note_Item__r.Credit_Note__r.Status__c IN :failedORRejectedStatus)'+
            ')';
        if(recordTypeId == CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL){
        	strQuery += ' AND Co_op_Actual_Amount__c > 0';
        }else if(RecordTypeId == CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL_REVERSE){
        	strQuery += ' AND Co_op_Actual_Amount__c < 0';
        }
        if(filter != null){
            if(filter.startDateFrom != null) {
                date startdate = date.newinstance(filter.startDateFrom.year(), filter.startDateFrom.month(), filter.startDateFrom.day());
                strQuery += ' AND Start_Date__c >= :startdate';
                if(filter.endDateTo != null){
                     date enddate = date.newinstance(filter.endDateTo.year(), filter.endDateTo.month(), filter.endDateTo.day());
                     strQuery += ' AND End_Date__c <= :enddate';
                }
            }
        }
        strQuery += ' ORDER BY Start_Date__c ASC LIMIT 50000';
        if(creditNoteId != null && cnAccountId != null){
            for(OpportunityLineItem dealProduct : Database.query(strQuery)) {
                DealProductWrapper dealProdwrapper = new DealProductWrapper();
                dealProdwrapper.isSelected = false;
                dealProdwrapper.dealPorduct = dealProduct;
                dealProdwrapper.startDate = dealProduct.Start_Date__c;
                dealProdwrapper.endDate = dealProduct.End_Date__c;
                lstDealProducts.add(dealProdwrapper);
            }
        }
        return lstDealProducts;
    }

    /**
     *  Method to upsert Credit Note Items
     *  @name createCreditNoteItems
     *  @param cnId,lstDealWrapper,listDealIds - Id of the creditNote and deals for which creditNoteItems need to created
     *  @return FinalResultWrapper - Wrapper including Set of Deal Product Ids for Which Credit Note Items gets created.
     */
    @RemoteAction
    global static FinalResultWrapper createCreditNoteItems(Id cnId, List<OpportunityLineItem> lstDealProducts,
                                                           List<Id> listDealIds,String cnCurremcy) {
        FinalResultWrapper frw = new FinalResultWrapper();
        Map<String, DealCreditNote__c> existingDealCreditNote = getExistingDealCreditNote(cnId,listDealIds);
        insertDealCreditNote(cnId,listDealIds,existingDealCreditNote,cnCurremcy);
        Map<Id,OpportunityLineItem> mapDealProducts = new Map<Id,OpportunityLineItem>();  //Defect ID : 4716
        List<Credit_Note_Item__c> listCreditNoteItemsToCreate = new List<Credit_Note_Item__c>();
        if(!lstDealProducts.isEmpty()){
            //Defect ID : 4716 
            for(OpportunityLineItem opplt : lstDealProducts){
                mapDealProducts.put(opplt.Id,opplt);
                Credit_Note_Item__c credNoteItem = new Credit_Note_Item__c();
                credNoteItem.Credit_Note__c = cnId;
                credNoteItem.Deal__c = opplt.OpportunityId;
                credNoteItem.Deal_Product_Id__c = opplt.Id;
                credNoteItem.Deal_Product_Name__c = opplt.Name;
                credNoteItem.Requested_Co_op_Amount__c = opplt.Co_op_Requested_Amount__c;
                if(opplt.Co_op_Actual_Amount__c < 0){
                    credNoteItem.Amount__c = (opplt.Co_op_Actual_Amount__c)*(-1);
                }else{
                    credNoteItem.Amount__c = opplt.Co_op_Actual_Amount__c;
                }
                credNoteItem.Unique_Id__c = cnId+'-'+opplt.OpportunityId+'-'+opplt.Id;
                credNoteItem.Product__c = opplt.Product2Id;
                credNoteItem.CurrencyIsoCode = cnCurremcy;
                credNoteItem.Comments__c = opplt.Comments__c;
                credNoteItem.Commitment_Number__c = String.valueOf(opplt.Commitment_Number__c);
                credNoteItem.Reason__c = opplt.Reason__c;
                credNoteItem.Customer_Reference_Number__c = opplt.Customer_Reference__c;
                credNoteItem.End_Date__c = opplt.End_Date__c;
                credNoteItem.Start_Date__c = opplt.Start_Date__c;
                credNoteItem.POS_Actuals__c = opplt.POS_Actual__c;
                credNoteItem.POS_Forecast__c = opplt.POS_Forecast__c;
                credNoteItem.POS_Rebate__c = opplt.POS_Rebate__c;
                credNoteItem.POS_Quantity__c = opplt.POS_Quantity__c;
                credNoteItem.Status__c = opplt.Status__c;
                credNoteItem.Requested_Co_op_Amount__c = opplt.Co_op_Actual_Amount__c;
                listCreditNoteItemsToCreate.add(credNoteItem);
            }            
            List<Database.UpsertResult> results = Database.upsert(listCreditNoteItemsToCreate,Credit_Note_Item__c.Unique_Id__c,false);
            List<OpportunityLineItem> lstDealProductsToUpdate = new List<OpportunityLineItem>();
            for(Integer i=0;i<results.size();i++){
                if (!results.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = results.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    frw.numFailedRecords++;
                }else{
                    Credit_Note_Item__c cni = listCreditNoteItemsToCreate.get(i);
                    if(mapDealProducts.containsKey(cni.Deal_Product_Id__c)){
                        OpportunityLineItem dealpro = mapDealProducts.get(cni.Deal_Product_Id__c);
                        dealpro.Credit_Note_Item__c = cni.Id;
                        lstDealProductsToUpdate.add(dealpro);
                        frw.sucessfullyProcessedDpIds.add(cni.Deal_Product_Id__c);
                    }
                }
            }
            if(!lstDealProductsToUpdate.isEmpty()){
                Database.SaveResult[] result = Database.Update(lstDealProductsToUpdate, false);
                List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
                for(Integer i=0; i < result.size(); i++ ){
                    OpportunityLineItem dealProduct = lstDealProductsToUpdate[i];
                    if(!result[i].isSuccess()){
                        listErrorLog = logAnException(result[i].getErrors(),dealProduct);
                    }
                }
                if(!listErrorLog.isEmpty()){
                    CRM_ErrorLogger.logError(listErrorLog);
                }
            }
        }
        return frw;
    }
    
    /**
     *  Method to insert DealCreditNote record
     *  @name insertDealCreditNote
     *  @param cnId,listDealIds,mapDealCreditNote - Id of the creditNote and deals for which DealCreditNote need to created
     *  @return none
     */
    private static void insertDealCreditNote(Id cnId,List<Id> listDealIds,
                                             Map<String,DealCreditNote__c> mapDealCreditNote,String cnCurremcy){
        Map<String,DealCreditNote__c> mapOfNewDealCreditNote   = new Map<String,DealCreditNote__c>();
        if(!listDealIds.isEmpty()){
            for(Id dealId: listDealIds){
                String currDealCreditNoteKey = dealId+'-'+cnId;
                if(!mapDealCreditNote.containsKey(currDealCreditNoteKey)){
                    DealCreditNote__c dealCreditNote = new DealCreditNote__c();
                    dealCreditNote.Opportunity__c = dealId;
                    dealCreditNote.Credit_Note__c = cnId;
                    dealCreditNote.Unique_Key__c = currDealCreditNoteKey;
                    dealCreditNote.CurrencyIsoCode = cnCurremcy;
                    mapOfNewDealCreditNote.put(dealCreditNote.Unique_Key__c,dealCreditNote);
                }
            }
        }
        if(!mapOfNewDealCreditNote.isEmpty()){
            try{
                Database.insert(mapOfNewDealCreditNote.values());
            }catch(system.DmlException de){
                throw new CRM_AddTacticsOnCreditNoteControllerException(de.getMessage());                
            }
        }
    }

    /**
     *  Method to fetch existing junction object record
     *  @name getExistingDealCreditNote
     *  @param cnId,listDealIds - Id of the creditNote and deals for which existing DealCreditNote__c need to be checked
     *  @return Map<String, DealCreditNote__c> - Map of the DealCreditNote__c records
     */
    private static Map<String, DealCreditNote__c> getExistingDealCreditNote(Id cnId,List<Id> listDealIds){
        Map<String, DealCreditNote__c> mapCurrentDealCreditNotes = new Map<String, DealCreditNote__c>();
        //Fetch existing DealCreditNote record for DealId and CreditNoteId combination
        for(DealCreditNote__c dealCredNote  : [SELECT Id, Opportunity__c, Credit_Note__c
                                                FROM DealCreditNote__c
                                                WHERE Credit_Note__c = :cnId AND Opportunity__c IN :listDealIds LIMIT 50000] ){
            String recordKey = dealCredNote.Opportunity__c+'-'+dealCredNote.Credit_Note__c;
            mapCurrentDealCreditNotes.put(recordKey, dealCredNote);
        }
        return mapCurrentDealCreditNotes;
    }
    
    
   /* Wrapper class to be used as javascript remoting object */
    global without sharing class DealProductWrapper {
        global Boolean isSelected {get;set;}
        global OpportunityLineItem dealPorduct {get;set;}
        global Date startDate {get;set;}
        global Date endDate {get;set;}
    }
    
    /* Wrapper class to be used as javascript remoting object */
    global without sharing class DealProducSearchFiltertWrapper {
        global date startDateFrom;
        global date endDateTo;
    }
    
    /* Wrapper class to be used as javascript remoting object */
    global without sharing class FinalResultWrapper {
        public Integer numFailedRecords = 0; 
        public Set<Id> sucessfullyProcessedDpIds = new Set<Id>(); 
    }
    
    /**
     * Method to get logged in uSer Locale Language code
     */
    global String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
    
    /**
     * Method to get user locale lowoer case
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
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
    *  @Description - Exception class
    *  @name  CRM_AddTacticsOnCreditNoteControllerException 
    */
    public without sharing class CRM_AddTacticsOnCreditNoteControllerException extends Exception {} 
    
   /** 
    *  @description: - This method is used to add Exception log for Deal product
    *  @name: logAnException
    *  @return: void
    */ 
    public static List<CRM_ErrorLogger.ErrorLog> logAnException(List<Database.Error> errors, OpportunityLineItem dealProduct){
        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = new list<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        for(Database.Error err : errors){
            errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_ADD_TACTICS_ON_CNT;
            errorLogInstance.recordId = dealProduct.Id;
            errorLogInstance.className = 'CRM_AddTacticsOnCreditNoteController';
            errorLogInstance.lineNumber = '';
            String errormsg = dealProduct.OpportunityId+' :: '+dealProduct.Name+' :: '+err.getMessage();
            errorLogInstance.errorMessage = errormsg.length() > 255 ? errormsg.substring(0, 255) : errormsg;
            errorLogInstance.stackTrace = ' Error Code: ' + String.valueOf(err.getStatusCode());
            errorLogInstanceList.add(errorLogInstance);
        }
        return errorLogInstanceList;
    }
    
    /**
     * Method to fetch CRM_Max_Product_Limit__c to fetch Product limit
     * Added for Pagination
     */
    global Integer getmaxTacticLimit() {
        return CRM_Max_Product_Limit__c.getInstance('Add_Tactics_On_CN') != null ? 
            		Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Add_Tactics_On_CN').Count__c) : 50;
    }
    
     /** 
     *  Method to fetch Chunk Size For Trade Tactics
     *  @name getChunkSizeForTradeTactics
     *  @param None
     *  @return Chunk size in Integer
     *  @throws None
     */
    global Integer getChunkSizeForTradeTactics() {
        return CRM_Batch_Size__c.getInstance('CRM Add Tactic Chunk Size') != null ? 
            	Integer.valueOf(CRM_Batch_Size__c.getInstance('CRM Add Tactic Chunk Size').Batch_Size__c) : 100;
    }
    
}