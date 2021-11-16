/**
   @Author: Cognizant Technology Solutions
   @name: CRM_AssortmentApprovalCtrl
   @CreateDate: June 14, 2016
   @Description:  Controller class to check for overlapping assortment.
   @Version - 1.0
   @reference: None
  */
global with sharing class CRM_AssortmentApprovalCtrl{
    
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    
    public static set<String> statusValues = new set<String>{CRM_AppConstants.ASSORTMENT_STATUS_APPROVED ,CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL };
    public final ApexPages.StandardController theController;
    
    public static Bundle__c assortmentRecord {get;set;}
    public static list<Bundle_Product__c> assortmentRecordProducts;
    public static list<Assortment_Account__c> assortmentRecordAccounts;
    public static boolean raiseAlert;
    //public static map<Id,list<Bundle_Product__c>> overlappingAssortmentProductsMap {get;set;} 
    
    /**
    *  @Description - constructor, checks for entry criteria before submitting record for approval, gathers data for further checks
    *  @name  CRM_AssortmentApproval 
    */   
    public CRM_AssortmentApprovalCtrl(ApexPages.StandardController stdCon){
            raiseAlert = false;
            
            if (stdCon.getId() != null) {
                List<Bundle__c> lstAssortment =
                                 [SELECT id, name,RecordTypeId,Price_Book__r.Business_Unit__c, Start_Date__c, End_Date__c, Assortment_Status__c,
                                  (SELECT id,name, List_Price__c, Assortment_Price__c,Bundle__r.Assortment_Status__c, Product__c,Product__r.recordtypeId,Product__r.Type__c FROM Bundle_Products__r),
                                  (SELECT id,name,Account__c FROM Assortment_Accounts__r)
                                 FROM Bundle__c
                                 WHERE id = :stdCon.getId()];
                if (!lstAssortment.isEmpty()) {
                    assortmentRecord = lstAssortment[0];
                    assortmentRecordProducts = assortmentRecord.Bundle_Products__r;
                    assortmentRecordAccounts = assortmentRecord.Assortment_Accounts__r;
                    
                }
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    //Defect#3711 :added flag to check if the assortment is of benelux and of campaign assortment record type.
    global Boolean isAssortBexCampaignType{
        get{
            if(assortmentRecord.Price_Book__r!=null && assortmentRecord.Price_Book__r.Business_Unit__c==CRM_AppConstants.TERRITORY_NETHERLAND_CODE && assortmentRecord.RecordTypeId==CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN){
                return true;
            }
            return false;
        }
    }
    
    /**
     *  Method to get overlapimg assortment
     *  @name getOverlappingAssProducts
     *  @param Id assortId
     *  @return CRM_ValidateAssortmentCtrl.assortmentWrapper
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_ValidateAssortmentCtrl.assortmentWrapper getOverlappingAssProducts(Id assortId) {
        Set<Id> assortmentProductsSet = new Set<Id>();
        Set<Id> assortmentAccountsSet = new Set<Id>();
        Map<Id, list<CRM_ValidateAssortmentCtrl.AssortmentProductWrapper>> mapIdToAssProductWrappers = new Map<Id,list<CRM_ValidateAssortmentCtrl.AssortmentProductWrapper>>();
        CRM_ValidateAssortmentCtrl.AssortmentWrapper assortmentWrapper = new CRM_ValidateAssortmentCtrl.AssortmentWrapper();
        Map<Id, List<Bundle_Product__c>> mapoverlappingAssProducts  = new Map<Id, List<Bundle_Product__c>>();
        map<id, Bundle__c> overlappingAssortsMap = new map<id, Bundle__c>();
        String assCampaignType;
        Boolean assAccSendToOtc = false;
        try {
            raiseAlert = false;
            String result = preApprovalProcessCheckPoint(assortId);
            System.debug('result::'+result);
            if(!String.isBlank(result)){
                throw new CRM_AssortmentApprovalException(result);
            }
            List<Bundle__c> lstAssortment =
                                 [SELECT id, name, Start_Date__c, End_Date__c, Pricing_Account__c, Campaign_Type__c, Product_Share__c ,Assortment_Status__c,
                                  (SELECT id,name, List_Price__c, Assortment_Price__c,Bundle__r.Assortment_Status__c, Product__c,Product__r.recordtypeId,Product__r.Type__c FROM Bundle_Products__r),
                                  (SELECT id,name,Account__c,Send_To_OTC__c FROM Assortment_Accounts__r)
                                 FROM Bundle__c
                                 WHERE id = :assortId];
            Bundle__c assort1 =  lstAssortment != null && lstAssortment.size()>0?lstAssortment[0]:null;  
            system.debug(assort1);

            system.debug('===assort1.Assortment_Status__c==='+assort1.Assortment_Status__c);
            system.debug('===assort1.Start_Date__c==='+assort1.Start_Date__c);
            
            if (assort1 != null) {
                
                assCampaignType = assort1.Campaign_Type__c;
                for(Bundle_Product__c assPro : assort1.Bundle_Products__r){
                        assortmentProductsSet.add(assPro.Product__c);
                }
                //assortmentProductsMap = new Map<Id,Bundle_Product__c>(assort1.Bundle_Products__r);
                /*if(assort1.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL && assort1.Pricing_Account__c != null){
                        assortmentAccountsSet.add(assort1.Pricing_Account__c);
                }
                else 
                if(assort1.Campaign_Type__c != CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL){*/
                for(Assortment_Account__c assAcc : assort1.Assortment_Accounts__r){
                    if(assAcc.Send_To_OTC__c == true){
                        assAccSendToOtc = true;
                        //Defect#3699 Fix:Get the assortment account with send to OTC flag checked.
                        assortmentAccountsSet.add(assAcc.Account__c);
                    }
                    //assortmentAccountsSet.add(assAcc.Account__c);
                }
                // Defect#3699:Added condition to check if Assortment Account size greater than 0
                if(!assAccSendToOtc && assort1.Campaign_Type__c != CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL && assort1.Assortment_Accounts__r.size() > 0){
                  throw new CRM_AssortmentApprovalException(Label.CRM_Assort_Approval_Atleast_One_Account_Send_to_OTC);
                }
                
                //}
                //assortmentAccountsMap = new Map<Id, Assortment_Account__c>(assort1.Assortment_Accounts__r);
            }
             system.debug('===assortmentAccountsSet==='+assortmentAccountsSet);
             system.debug('===assortmentProductsSet==='+assortmentProductsSet);
            //defect#3699:assortmentAccountsSet.size() condition removed and added 'assort1.Assortment_Accounts__r.size()'this check.
            if(assort1.Assortment_Accounts__r.size() > 0 && assortmentProductsSet.size() > 0){
                //method call to Fetch overlapped Prducts for the overlapping assortments with different assortment Prices.
                mapIdToAssProductWrappers = CRM_ValidateAssortmentCtrl.fetchOverlappedProductsForAssortment(assortmentAccountsSet,assortmentProductsSet,assort1);
            
                     if(mapIdToAssProductWrappers.size() > 0){
                        raiseAlert =true;
                    }
                    system.debug('==============raiseAlert==============='+raiseAlert+'===assortId==='+assortId);
                    //system.debug('==============mapIdToAssProductWrappers==============='+mapIdToAssProductWrappers);
                    system.debug('==============(lstAssortment[0].Product_Share__c==============='+lstAssortment[0].Product_Share__c);
                    if(!raiseAlert) {
                        if((lstAssortment[0].Product_Share__c != 100) && (lstAssortment[0].Product_Share__c != 0)){
                               throw new CRM_AssortmentApprovalException(Label.CRM_Assortment_Product_Share_Percent_should_be_100_or_0);
                        }
                        callStandardApprovalProcess(assortId);
                    }
            }
            
            else if(assortmentProductsSet.size() == 0){
                throw new CRM_AssortmentApprovalException(Label.CRM_No_Products_found_for_assortment);
            }
            else if(assort1.Assortment_Accounts__r.size() == 0){
                throw new CRM_AssortmentApprovalException(Label.CRM_No_Accounts_found_for_assortment);
            }
        }
        catch(Exception e){
            logAnException(e, assortId); 
            throw new CRM_AssortmentApprovalException(e.getMessage());
        }
        AssortmentWrapper.showMessage = raiseAlert;
        AssortmentWrapper.mapWrapper = mapIdToAssProductWrappers;
      return AssortmentWrapper;
    }
    
    
    /**
     *  Method to convert Date datatype into String datatype
     *  @name convertDateToString
     *  @param Date dt
     *  @return String
     *  @throws None
     */
    
    public static String convertDateToString(Date dt) {
        if(dt != null) {
            return (Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0))).format('MM/dd/yyyy');
            //return dt.format();
        }       
        return null;
    }
    
     /**
     *  Method to call the standard approval process for assortment 
     *  @name SubmitForApproval
     *  @param Id assortmentId
     *  @throws none
     */
    @RemoteAction
    global static void SubmitAssortmentForApproval(Id assortId){
        try{
            callStandardApprovalProcess(assortId);
        }
        catch(Exception e){
                    logAnException(e, assortId); 
                    throw new CRM_AssortmentApprovalException(e.getMessage());
        }
    }
    
     /**
     *  Method to fetch the Assortment Product from AssortmentId which is called from EditProductsCtrl.js 
     *  @name getLineItems
     *  @param Id assortmentId
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.ProductToEdit[] getLineItems(Id assortmentId) {
        CRM_DataObjects.ProductToEdit[] listProducts = new CRM_DataObjects.ProductToEdit[]{};
        List<Bundle_product__c> lstAssProducts = new List<Bundle_product__c>();
        for(Bundle_product__c assortProduct : [select 
                                 // Line Item  Fields
                                  id,name,Bundle__r.name, List_Price__c, Assortment_Price__c,Bundle__r.Assortment_Status__c, Product__r.recordtypeId,Product__c,Product__r.Name,Product__r.Type__c
                                 from Bundle_product__c where Bundle__c = : assortmentId]){
            lstAssProducts.add(assortProduct);
        }
        for(Bundle_product__c  assortProduct : lstAssProducts) {

            CRM_DataObjects.ProductToEdit prod = new CRM_DataObjects.ProductToEdit();
            prod.productId = assortProduct.Product__c;
            prod.productName = assortProduct.Product__r.Name;
            prod.lineItemId = assortProduct.id;
            prod.promotedPrice = assortProduct.Assortment_Price__c;
            prod.accountPrice = assortProduct.Assortment_Price__c;            
            listProducts.add(prod);
        }

        return listProducts;
    }
    
    /**
    *  @Description - method to perform approval process and then redirect control back to Deal standard detail page
    *  @name  goBackToAss 
    */
    global static void callStandardApprovalProcess(Id assID){
            Bundle__c assForApproval;
            Bundle__c assortment = new Bundle__c(Id=assID);
            assortment.Validated__c = true;
            update assortment;
            //list<Bundle_Product__c> updateAssProducts = new list<Bundle_Product__c>();
            if (String.isNotBlank(assID))
            {
                    try
                        {                           
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setObjectId(assID);
                            Approval.ProcessResult result = Approval.process(req);
                        }
                    catch(System.DMLException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            // Process exception here
                            logAnException(e, assID); 
                            throw new CRM_AssortmentApprovalException(e.getDmlMessage(i));
                        }
                    }
                    catch(Exception e)
                        {
                            logAnException(e, assID);
                            system.debug(e.getMessage());
                            throw new CRM_AssortmentApprovalException(e.getMessage());
                        }   
            }
    }
    
    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public static void logAnException(Exception ex, Id recordId){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null)
            errorLogInstance.recordId = recordId;
        // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
        errorLogInstance.functionalModule = 'CRM_Assortment_Approval';
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();
        listErrorLog.add(errorLogInstance);     
    }
    
    /**
    *  @Description - wrapper class
    *  @name  DealProductWrapper 
    */
    global class AssortmentProductWrapper{
        public Bundle_Product__c assProductRecord;
        public String assStartDate;
        public String assEndDate;
        //public Boolean isChanged=false;
    }
    
    /**
    *  @Description - wrapper class
    *  @name  DealProductWrapper 
    */
    global class AssortmentWrapper{
        public Boolean showMessage=false;
        public map<Id,list<AssortmentProductWrapper>> mapWrapper;
    }
    
    public class CRM_AssortmentApprovalException extends Exception {
    }
    
    @RemoteAction 
    global static String preApprovalProcessCheckPoint(Id assId) 
    {
        Bundle__c assortment; 
        String status;
        Decimal configCount;
        List<Bundle__c> lstAssortment = new List<Bundle__c>();
        lstAssortment = [SELECT Assortment_Status__c,id,Config_Count__c FROM Bundle__c WHERE Id =: assId];
        
        if(!lstAssortment.isEmpty())
        {
            assortment = lstAssortment.get(0);
            status = assortment.Assortment_Status__c;
            configCount = assortment.Config_Count__c;
            System.debug('@#@#@#@#@# ass.Assortment_Status__c: ' + assortment.Assortment_Status__c);
        }
       
        String strReturn = '';

        if (String.isNotBlank(status))
        {
            if(!(status.equalsIgnoreCase(CRM_AppConstants.ASSORTMENT_STATUS_DRAFT))) 
            {             
                strReturn = Label.CRM_Assortment_is_not_in_Draft_Stage ;
            }
            else if(configCount <= 0) {
                strReturn = Label.CRM_Submit_for_approval_error_for_no_config;
            }
        }        
        return strReturn;
    }
    
        /**
     *  method to refresh/update the pricing details for the products associated to incoming assortment ids
     *  @name refreshAssortmentProductPrices
     *  @param assortmentIds - Ids of the assortment where product pricing details to be refreshed
     */
    @RemoteAction 
    global static void refreshProductPrices(Id[] assortmentIds) {
            list<Bundle__c> assortmentList = new list<Bundle__c>();
        try{
            assortmentList = [Select Id, Assortment_Status__c from Bundle__c where (Id IN:assortmentIds)];
            
            if(!assortmentList.isEmpty() && (assortmentList[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED || assortmentList[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL)){
                throw new CRM_AssortmentApprovalException(Label.CRM_Approved_assortment_cannot_be_edited_validated);
            }
            
            List<Bundle_Product__c> listProductsToUpdate = new List<Bundle_Product__c>{};
            List<CRM_ProductPricingHandler.DealWrapper> listAssortmentWrappers = new List<CRM_ProductPricingHandler.DealWrapper>{};

            // get the list of associated assortment products
            List<Bundle_Product__c> listAssortmentProducts = [Select Id,Product__c,Bundle__c,List_Price__c,Assortment_Price__c,Bundle__r.Id,Bundle__r.CurrencyISOCode,
                                                 Bundle__r.Price_Book__c,Bundle__r.Start_Date__c,Bundle__r.End_Date__c from Bundle_Product__c
                               where (Bundle__c IN:assortmentIds)];
       
            if(listAssortmentProducts.isEmpty()){
                throw new CRM_AssortmentApprovalException(Label.CRM_No_Products_found_for_assortment);
            }

            // create and populate a list of assortment wrappers to calculate the pricing                   
            for(Bundle_Product__c assortmentProduct : listAssortmentProducts) {                
                listAssortmentWrappers.add(createAssortmentWrapper(assortmentProduct));
            }
            
            // Instanciate pricing handler to calcualte the updated price of the products 
            CRM_ProductPricingHandler pricingHandler = new CRM_ProductPricingHandler(listAssortmentWrappers);
            for(CRM_ProductPricingHandler.DealWrapper dw : listAssortmentWrappers) {
                Decimal listPrice = pricingHandler.getProductDatedListPrice(dw);
                    Boolean isUpdateflag = false;  
                    if(dw.bundleProduct.List_Price__c == dw.bundleProduct.Assortment_Price__c)
                    {
                        dw.bundleProduct.Assortment_Price__c = listPrice;
                        isUpdateflag = true;
                    }
                    if(dw.bundleProduct.List_Price__c != listPrice)
                    {
                        dw.bundleProduct.List_Price__c = listPrice;
                        isUpdateflag = true;
                    }
                    if(isUpdateflag) {
                        listProductsToUpdate.add(dw.bundleProduct);
                    }
                    else{
                        throw new CRM_AssortmentApprovalException(Label.CRM_Validation_msg_prices_are_upto_date);
                    }
            }            
            
            // Update the list of assortment products which have undergone price-change 
            if(!listProductsToUpdate.isEmpty()) {
                system.debug('******listProductsToUpdate'+listProductsToUpdate);
                update listProductsToUpdate;
            }
        }
        
        catch(System.DMLException e){
           for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                logAnException(e, assortmentList[0].Id);
                throw new CRM_AssortmentApprovalException(e.getDmlMessage(i));
            }
        }
        catch(Exception ex) {
            // Error Logging
            logAnException(ex, assortmentList[0].Id);
            throw new CRM_AssortmentApprovalException(ex.getMessage());
        }
    }
    
    private static CRM_ProductPricingHandler.DealWrapper createAssortmentWrapper(Bundle_Product__c assortmentProd) {
        CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
        dw.dealId = assortmentProd.Bundle__r.Id;
        //dw.accountId = assortmentProd.Opportunity.AccountId;
        dw.dealCurrency = assortmentProd.Bundle__r.CurrencyISOCode;
        dw.productId = assortmentProd.Product__c;
        dw.pricebookId = assortmentProd.Bundle__r.Price_Book__c;
        dw.dealStartDate = assortmentProd.Bundle__r.Start_Date__c;
        dw.dealEndDate = assortmentProd.Bundle__r.End_Date__c;
        dw.bundleProduct = assortmentProd;
        return dw; 
    }    
    
   
}