/**
   @Author Cognizant
   @name CRM_UploadExtractCreditNoteItem
   @CreateDate 19 Dec 2017
   @Description This class is used to upload (update/insert) the Credit Note Items /products US#925.
   @Version <1.0>
   @reference Requirement no 925 US Games
*/
global with sharing class CRM_UploadExtractCreditNoteItem{

    public Boolean isPageReadOnly {get; set;}
    public Id creditNoteId;
    public static Integer totalFailedRecords;  
    public String handsontableversion{get; set;}  
    /** 
    *  @Description - constructor
    *  @name  CRM_UploadExtractCreditNoteItem  
    */ 
    global CRM_UploadExtractCreditNoteItem(ApexPages.StandardController stdController) {
        creditNoteId = stdController.getId();
        List<Credit_Note__c> lstCreditNote = [SELECT id,Account__r.Digital_Country_Code__c,
                                                    CurrencyISOCode,Status__c 
                                                   FROM Credit_Note__c 
                                                   WHERE Id =: creditNoteId];
        isPageReadOnly = lstCreditNote[0].Status__c ==  CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED ? true :false;                                   
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;                               
    }
    
	//Start - US : 989
	public string getHandsonTable_Pro_Licencekey (){
		return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
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
	//End - US : 989
    
    /** 
     *  Method to fetch the Deal Product from DealId  
     *  @name getChunkSizeForTradeTactics
     *  @param None
     *  @return Chunk size in Integer
     *  @throws None
     */
    global Integer getChunkSizeForCreditNoteItems() {
        return CRM_Batch_Size__c.getInstance('Upload Credit Note Items Records') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('Upload Credit Note Items Records').Batch_Size__c) : 100;
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
            for(Credit_Note_Item__c lineItem:
                    [SELECT Amount__c,Comments__c,Commitment_Number__c,Credit_Note__c,CurrencyIsoCode,Customer_Reference_Number__c,
                            Deal_Product_Id__c,Deal_Product_Name__c,Deal_Product__c,Deal__c,End_Date__c,Id,Name,POS_Actuals__c,
                            POS_Forecast__c,POS_Rebate__c,ProductCode__c,Product__r.name,Product__c,Reason__c,Requested_Co_op_Amount__c,Start_Date__c,Status__c
                            FROM Credit_Note_Item__c
                            WHERE Credit_Note__c = :creditNoteId 
                            ORDER BY Deal_Product_Name__c]
             ){
                        CreditNoteItemWrapper lineItemWrapper =  mapCreditNoteItemFields(lineItem);
                        returnWrapperList.add(lineItemWrapper);
            } 
         }
        catch(Exception e) {}
        system.debug('list-----------'+returnWrapperList); 
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
            
            //Defect : 4717
            lineItemWrapper.productCode = lineItem.ProductCode__c == null ? '' : lineItem.ProductCode__c;
            lineItemWrapper.productName = lineItem.Product__r.name == null ? '' : lineItem.Product__r.name;
            lineItemWrapper.commitmentNum =  lineItem.Commitment_Number__c;
            lineItemWrapper.startDate = String.valueOf(lineItem.Start_date__c);
            lineItemWrapper.endDate = String.valueOf(lineItem.End_date__c);
            
            //Defect : 4717
            lineItemWrapper.coopReason = lineItem.Reason__c == null ? '' : lineItem.Reason__c ;
            lineItemWrapper.coopComments = lineItem.Comments__c== null ? '' : lineItem.Comments__c;
            lineItemWrapper.posRebate = lineItem.POS_Rebate__c;
            lineItemWrapper.posForecast = lineItem.POS_Forecast__c ;
            lineItemWrapper.coopReqAmount = lineItem.Requested_Co_op_Amount__c;
            lineItemWrapper.posActual= lineItem.POS_Actuals__c; 
            lineItemWrapper.coopActualAmt = lineItem.Amount__c == null ? lineItem.Amount__c :(lineItem.Amount__c.SetScale(2));
            
            //Defect : 4717
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
    global static List<CreditNoteItemWrapper> setCreditNoteLineItems(List<CreditNoteItemWrapper> tacticWrapperList,Id creditNoteId) { 
        
        List<CreditNoteItemWrapper> lstToUpdateCNoteItemWrap =new List<CreditNoteItemWrapper>();
        List<Credit_Note_Item__c> lstToUpdateCreditNoteItem = new List<Credit_Note_Item__c>();  
        List<CreditNoteItemWrapper> listLiWrappersToDelete = new List<CreditNoteItemWrapper>();
        totalFailedRecords = 0;
        
        //Get Credit_Note__c Details like CurrencyCode,Pricebook and existing Deal products for the ProductCode
        List<Credit_Note__c> lstCreditNote = [SELECT id,Account__r.Digital_Country_Code__c,
                                                    CurrencyISOCode,Status__c 
                                                   FROM Credit_Note__c 
                                                   WHERE Id =: creditNoteId];
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
               if(tacticRecord.isRowModified !=null && tacticRecord.isRowModified == true && (tacticRecord.validation == null || tacticRecord.validation == '')){
             Credit_Note_Item__c tacticItem = new Credit_Note_Item__c();
            tacticItem.Id=tacticRecord.existingId;
            tacticItem.Amount__c = tacticRecord.coopActualAmt == null ? tacticRecord.coopActualAmt : (tacticRecord.coopActualAmt.SetScale(2)); 
            tacticItem.Customer_Reference_Number__c = tacticRecord.custReference;
            lstToUpdateCreditNoteItem.add(tacticItem);  
            lstToUpdateCNoteItemWrap.add(tacticRecord); 
          }
            }
      
      if(!lstToUpdateCreditNoteItem.isEmpty()){
        Database.SaveResult[] result = Database.Update(lstToUpdateCreditNoteItem, false);
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
    global static void upsertDMLResultForTactics(list<Database.SaveResult> results,List<CreditNoteItemWrapper> tacticWrapperList,Id creditNoteId) {
        Map<Id,Credit_Note_Item__c> mapTacticRecords = new Map<Id,Credit_Note_Item__c> ([SELECT Amount__c,Comments__c,Commitment_Number__c,Credit_Note__c,CurrencyIsoCode,Customer_Reference_Number__c,
                                                                                            Deal_Product_Id__c,Deal_Product_Name__c,Deal_Product__c,Deal__c,End_Date__c,Id,Name,POS_Actuals__c,
                                                                                            POS_Forecast__c,POS_Rebate__c,ProductCode__c,Product__c,Reason__c,Requested_Co_op_Amount__c,Start_Date__c,Status__c
                                                                                            FROM Credit_Note_Item__c
                                                                                            WHERE Credit_Note__c = :creditNoteId 
                                                                                            AND Credit_Note__r.Status__c =: CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED 
                                                                                            ORDER BY Deal_Product_Name__c]);
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
                    Decimal coopActualAmount = (mapTacticRecords.get(results.get(i).Id).Amount__c) == null ?(mapTacticRecords.get(results.get(i).Id).Amount__c) : (mapTacticRecords.get(results.get(i).Id).Amount__c.SetScale(2));
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
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }  
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
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
                    system.debug('Failed ID remove -'+listLiWrappersToRemove.get(i));
                    
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
        public Decimal posForecast;
        public Decimal coopReqAmount;
        public Decimal posActual;
        public Decimal coopActualAmt;
        public String  status='';
        public String  custReference='';
        public Integer numFailedRecords;  
        //US : 994 
        public string recrodStatus='';
    }  
}