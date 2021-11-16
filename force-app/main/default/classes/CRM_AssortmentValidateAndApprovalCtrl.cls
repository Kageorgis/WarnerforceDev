/**     /**
@Author: Cognizant Technology Solutions
@name: CRM_AssortmentValidateAndApprovalCtrl
@CreateDate: June 14, 2016         @CreateDate 16 Nov 2016
@Description:  Controller class to check for overlapping assortment.
@Version - 1.0 – to only be availed for non-Approved deals
@reference: None           @Version <1.0>
*/
Global with sharing class CRM_AssortmentValidateAndApprovalCtrl{

 static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;

 public static set < String > statusValues = new set < String > {
  CRM_AppConstants.ASSORTMENT_STATUS_APPROVED,
  CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL,
  CRM_AppConstants.ASSORTMENT_STATUS_DRAFT //US#529 - get overlapping assortment with draft status.
 };
 public final ApexPages.StandardController theController;

 public static Bundle__c assortmentRecord {
  get;
  set;
 }
 public static list < Bundle_Product__c > assortmentRecordProducts;
 public static list < Assortment_Account__c > assortmentRecordAccounts;
 public static boolean raiseAlert;
 public static list < String > warningsList = new list < String > ();
 public static string isValidate;
 public static boolean overlappingDraftAssFound; //US#529 - created new variable to check if overlapping draft assortments present
 public static set<Id> OverlappingApprovedAssortmentSet = new set<Id>(); //US#529 - set to collect ovrlapping draft assortments
 //public static map<Id,list<Bundle_Product__c>> overlappingAssortmentProductsMap {get;set;} 

 /**
  *  @Description - constructor, checks for entry criteria before submitting record for approval, gathers data for further checks
  *  @name  CRM_AssortmentApproval 
  */
 public CRM_AssortmentValidateAndApprovalCtrl(ApexPages.StandardController stdCon) {
  raiseAlert = false;
  isValidate = ApexPages.currentPage().getParameters().get('isOnlyValidate');  

  if (stdCon.getId() != null) {
   List < Bundle__c > lstAssortment = [SELECT id, name, Start_Date__c, End_Date__c, Assortment_Status__c,RecordTypeId,Price_Book__r.Business_Unit__c,
    (SELECT id, name, List_Price__c, Assortment_Price__c, Bundle__r.Assortment_Status__c, Product__c, Product__r.recordtypeId, Product__r.Type__c FROM Bundle_Products__r),
    (SELECT id, name, Account__c FROM Assortment_Accounts__r)
    FROM Bundle__c
    WHERE id = : stdCon.getId()
   ];
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
    
    global Boolean isValidateButtonClicked{
        get{
            if(isValidate == 'true'){
                system.debug('validate clicked');
            return true;
            }
            else{
                 system.debug('approve clicked');
            return false;}
        }
        
    }

 /**
  *  Method to get overlapimg assortment
  *  @name getOverlappingAssProducts
  *  @param Id assortId
  *  @return assortmentWrapper
  *  @throws None
  */

 @RemoteAction
 global static assortmentWrapper getOverlappingAssProducts(Id assortId,string isValidateTrue) {
  Set < Id > assortmentProductsSet = new Set < Id > ();
  Set < Id > assortmentAccountsSet = new Set < Id > ();
  Map < Id, list < AssortmentProductWrapper >> mapIdToAssProductWrappers = new Map < Id, list < AssortmentProductWrapper >> ();
  AssortmentWrapper assortmentWrapper = new AssortmentWrapper();
  Map < Id, List < Bundle_Product__c >> mapoverlappingAssProducts = new Map < Id, List < Bundle_Product__c >> ();
  map < id, Bundle__c > overlappingAssortsMap = new map < id, Bundle__c > ();
  String assCampaignType;
  String TerritoryType ='';
  Boolean isonlyValidate;
  Boolean assAccSendToOtc = false;
  Boolean isBeneluxAssortment = false;
  
  if(isValidateTrue =='true'){
    isonlyValidate = true;   
  }else{
     isonlyValidate = false;  
  }
  try {
   raiseAlert = false;
   String result = preApprovalProcessCheckPoint(assortId,isonlyValidate);
   System.debug('result::' + result);
   if (!String.isBlank(result)) {
    throw new CRM_AssortmentApprovalException(result);
   }
   List<Bundle__c> lstAssortment = getAssortment(assortId);
   Bundle__c assort1 = lstAssortment != null && lstAssortment.size() > 0 ? lstAssortment[0] : null;

   if (assort1 != null) {

    assCampaignType = assort1.Campaign_Type__c;
    
    if(assort1.Price_Book__r.Business_Unit__c==CRM_AppConstants.TERRITORY_NETHERLAND_CODE || assort1.Price_Book__r.Business_Unit__c==CRM_AppConstants.TERRITORY_BELGIUM_CODE){
        isBeneluxAssortment = true;
    }
    
    for (Bundle_Product__c assPro: assort1.Bundle_Products__r) {
     assortmentProductsSet.add(assPro.Product__c);
     if (!assPro.Product__r.IsActive || assPro.Product_Status__c != 'Active') {
     //US#531 - changed label text to show exact status for assortment.
      warningsList.add(assPro.Product__r.Name+' : '+Label.CRM_Assort_Approval_Product_Inactive+' '+assPro.Product_Status__c);
     }
    }
    Set<String> territoryCodeSet = new Set<String>();
    for (Assortment_Account__c assAcc: assort1.Assortment_Accounts__r) {
     if (assAcc.Send_To_OTC__c == true) {
      assAccSendToOtc = true;
      //Defect#3699 Fix:Get the assortment account with send to OTC flag checked.
      assortmentAccountsSet.add(assAcc.Account__c);
     }
    
     /*defect#3836 : start - code to check the territory code for the assortment.*/
     if(assAcc.Account__c != null && assAcc.Account__r.Sales_Organization__c!=null && assAcc.Account__r.Sales_Organization__c==CRM_AppConstants.TERRITORY_BELGIUM_CODE){
         //TerritoryType = 'BE';
         territoryCodeSet.add(CRM_AppConstants.BELGIUM_COUNTRY_CODE);
             
     }
     if(assAcc.Account__c != null && assAcc.Account__r.Sales_Organization__c!=null && assAcc.Account__r.Sales_Organization__c==CRM_AppConstants.TERRITORY_NETHERLAND_CODE){
         //TerritoryType = 'NL';
         territoryCodeSet.add(CRM_AppConstants.NETHERLANDS_COUNTRY_CODE);    
     }
     
    }
    if(territoryCodeSet!=null && !territoryCodeSet.isEmpty())
    {
        for(String tCode: territoryCodeSet){
            if(TerritoryType==null){
                TerritoryType = tCode;
            }
            else{
                TerritoryType = TerritoryType + tCode;
            }
            System.debug('TerritoryType==============================LINE149'+TerritoryType);
        }
    }
    /*defect#3836 : stop */
    // Defect#3699:Added condition to check if Assortment Account size greater than 0
    if (!assAccSendToOtc && assort1.Campaign_Type__c != CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL && assort1.Assortment_Accounts__r.size() > 0) {
         system.debug('flag values checked is -->'+isonlyValidate);
         if(isonlyValidate){
            warningsList.add(Label.CRM_Assort_Approval_Atleast_One_Account_Send_to_OTC);
         }
         else{
            throw new CRM_AssortmentApprovalException(Label.CRM_Assort_Approval_Atleast_One_Account_Send_to_OTC);    
         }
    }
    
    //US#958 - added warning messsage if FR assortment does not have Couponing Discount and Couponing Redemption Rate % not present dusring approval
    if(assort1.Price_Book__r.Business_Unit__c==CRM_AppConstants.TERRITORY_FRANCE_CODE && assort1.Couponing_Discount__c == null){
        warningsList.add(Label.CRM_Assortment_Couponing_discount_or_redumption_rate_is_null);
    }
    //US#958 - end
    system.debug('===assortmentAccountsSet===' + assortmentAccountsSet);
    //}
    //assortmentAccountsMap = new Map<Id, Assortment_Account__c>(assort1.Assortment_Accounts__r);
   }

   if (assort1.Assortment_Accounts__r.size() > 0 && assortmentProductsSet.size() > 0) {
        //method call to Fetch overlapped Prducts for the overlapping assortments with different assortment Prices.
        mapIdToAssProductWrappers = fetchOverlappedProductsForAssortment(assortmentAccountsSet, assortmentProductsSet, assort1);
    
        system.debug('==============mapIdToAssProductWrappers===============' + mapIdToAssProductWrappers);
        if (mapIdToAssProductWrappers.size() > 0 && isBeneluxAssortment) {
         raiseAlert = true;
        }
        if (mapIdToAssProductWrappers.size() > 0 && OverlappingApprovedAssortmentSet.size() > 0 && !isBeneluxAssortment) { //US#529- added hceck to show error when any of the assortment with approved status found.
         raiseAlert = true;
        }
        else if(mapIdToAssProductWrappers.size() > 0 && OverlappingApprovedAssortmentSet.size() <= 0 && !isBeneluxAssortment){ ////US#529 - show warning if overlapping assortment with draft status found.
            warningsList.add(label.CRM_Assortment_with_draft_status_found); 
            overlappingDraftAssFound = true;
        }
        
        if ((lstAssortment[0].Product_Share__c != 100) && (lstAssortment[0].Product_Share__c != 0)) {
            if(isonlyValidate){
                warningsList.add(Label.CRM_Assortment_Product_Share_Percent_should_be_100_or_0);
            }
            else{
                throw new CRM_AssortmentApprovalException(Label.CRM_Assortment_Product_Share_Percent_should_be_100_or_0);
            }
        }
        if(!raiseAlert && warningsList.size() <= 0 && !isonlyValidate) {        
            callStandardApprovalProcess(assortId,TerritoryType);      
        }
   } else if (assortmentProductsSet.size() == 0) {
        throw new CRM_AssortmentApprovalException(Label.CRM_No_Products_found_for_assortment);
   } else if (assort1.Assortment_Accounts__r.size() == 0) {
        throw new CRM_AssortmentApprovalException(Label.CRM_No_Accounts_found_for_assortment);
   }
  } catch (Exception e) {
       logAnException(e, assortId);
       throw new CRM_AssortmentApprovalException(e.getMessage());
  }
  AssortmentWrapper.showMessage = raiseAlert;
  AssortmentWrapper.mapWrapper = mapIdToAssProductWrappers;
  AssortmentWrapper.assortWarnings = warningsList;
  AssortmentWrapper.isOverlappingDraftAssort = overlappingDraftAssFound;//US#529 - added variable to set true if overlapping assortment with draft status found.
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
  if (dt != null) {
   return (Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0))).format('MM/dd/yyyy');
   //return dt.format();
  }
  return null;
 }
 
  /**            /**
     *  Method to call the standard approval process for assortment         
     *  @name SubmitForApproval     
     *  @param Id assortmentId      
     *  @throws none        
     */     
    @RemoteAction       
    global static void SubmitAssortmentForApproval(Id assortId){        
        try{        
            /*defect#3836 : start - code to check the territory code for the assortment.*/
            List<Bundle__c> lstAssortment = getAssortment(assortId);
            Set<String> territoryCodeSet = new Set<String>();
            string TerritoryType ='';
            Bundle__c assort1 = lstAssortment != null && lstAssortment.size() > 0 ? lstAssortment[0] : null;
            for (Assortment_Account__c assAcc: assort1.Assortment_Accounts__r) {             
                if(assAcc.Account__c != null && assAcc.Account__r.Sales_Organization__c!=null && assAcc.Account__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE){
                    //TerritoryType = 'BE'; 
                    territoryCodeSet.add(CRM_AppConstants.BELGIUM_COUNTRY_CODE);   
                }
                if(assAcc.Account__c != null && assAcc.Account__r.Sales_Organization__c!=null && assAcc.Account__r.Sales_Organization__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE){
                    //TerritoryType = 'NL';
                    territoryCodeSet.add(CRM_AppConstants.NETHERLANDS_COUNTRY_CODE);    
                }
            }
            if(territoryCodeSet !=null && !territoryCodeSet.isEmpty()){
                for(String tCode: territoryCodeSet){
                    if(TerritoryType==null){
                        TerritoryType = tCode;
                    }
                    else{
                        TerritoryType = TerritoryType + tCode;
                    }
                    System.debug('TerritoryType==============================LINE253'+TerritoryType);
                }
            }
            /*defect#3836 : stop */
            callStandardApprovalProcess(assortId,TerritoryType);      
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
  CRM_DataObjects.ProductToEdit[] listProducts = new CRM_DataObjects.ProductToEdit[] {};
  List < Bundle_product__c > lstAssProducts = new List < Bundle_product__c > ();
  for (Bundle_product__c assortProduct: [select
    // Line Item  Fields
    id, name, Bundle__r.name, List_Price__c, Assortment_Price__c, Bundle__r.Assortment_Status__c, Product__r.recordtypeId,Product__r.SAP_Material_Type__c, Product__c, Product__r.Name, Product__r.Type__c
    from Bundle_product__c where Bundle__c = : assortmentId
   ]) {
   lstAssProducts.add(assortProduct);
  }
  for (Bundle_product__c assortProduct: lstAssProducts) {

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
    global static void callStandardApprovalProcess(Id assID,String territoryType){       
            Bundle__c assForApproval;       
            Bundle__c assortment = new Bundle__c(Id=assID);     
            assortment.Validated__c = true;
            /*defect#3836 :start */
            if(territoryType.contains(CRM_AppConstants.BELGIUM_COUNTRY_CODE) && !territoryType.contains(CRM_AppConstants.NETHERLANDS_COUNTRY_CODE)){
                assortment.Territory_Code__c =CRM_AppConstants.BELGIUM_COUNTRY_CODE;
            }
            else if(territoryType.contains(CRM_AppConstants.NETHERLANDS_COUNTRY_CODE) && !territoryType.contains(CRM_AppConstants.BELGIUM_COUNTRY_CODE)){
                assortment.Territory_Code__c =CRM_AppConstants.NETHERLANDS_COUNTRY_CODE;
            }
            else if(territoryType.contains(CRM_AppConstants.BELGIUM_COUNTRY_CODE) && territoryType.contains(CRM_AppConstants.NETHERLANDS_COUNTRY_CODE)){
                assortment.Territory_Code__c = CRM_AppConstants.BENELUX_COUNTRY_CODE;
            }
            /*defect#3836 :stop */     
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
 public static void logAnException(Exception ex, Id recordId) {
  List < CRM_ErrorLogger.ErrorLog > listErrorLog = new List < CRM_ErrorLogger.ErrorLog > ();
  CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
  if (recordId != null)
   errorLogInstance.recordId = recordId;
  // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
  errorLogInstance.functionalModule = 'CRM_Assortment_Validation_and_Approval';
  errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
  errorLogInstance.errorMessage = ex.getMessage();
  errorLogInstance.stackTrace = ex.getStackTraceString();
  listErrorLog.add(errorLogInstance);
 }

 /**
  *  @Description - wrapper class
  *  @name  DealProductWrapper 
  */
 global class AssortmentProductWrapper {
  public Bundle_Product__c assProductRecord;
  public String assStartDate;
  public String assEndDate;
  //public Boolean isChanged=false;
 }

 /**
  *  @Description - wrapper class
  *  @name  DealProductWrapper 
  */
 global class AssortmentWrapper {
  public Boolean showMessage = false;
  public map < Id, list < AssortmentProductWrapper >> mapWrapper;
  public List < string > assortWarnings;
  public Boolean isOverlappingDraftAssort;//US#529
 }

 public class CRM_AssortmentApprovalException extends Exception {}

 @RemoteAction
 global static String preApprovalProcessCheckPoint(Id assId,Boolean isonlyValidate) {
  Bundle__c assortment;
  String status;
  Decimal configCount;
  List < Bundle__c > lstAssortment = new List < Bundle__c > ();
  lstAssortment = [SELECT Assortment_Status__c, id, Config_Count__c FROM Bundle__c WHERE Id = : assId];

  if (!lstAssortment.isEmpty()) {
   assortment = lstAssortment.get(0);
   status = assortment.Assortment_Status__c;
   configCount = assortment.Config_Count__c;
   System.debug('@#@#@#@#@# ass.Assortment_Status__c: ' + assortment.Assortment_Status__c);
  }

  String strReturn = '';

  if (String.isNotBlank(status) && isonlyValidate) {
   if (!(status.equalsIgnoreCase(CRM_AppConstants.ASSORTMENT_STATUS_PENDING_CHANGES)) && !(status.equalsIgnoreCase(CRM_AppConstants.ASSORTMENT_STATUS_DRAFT)) ) {
       strReturn = Label.CRM_Assortment_is_not_in_Draft_Stage;
   }
   if (configCount <= 0) {
        warningsList.add(Label.CRM_Submit_for_approval_error_for_no_config);
        System.debug('@#@#@#@#@# warningsList ' + warningsList);
   }
  }
  if (String.isNotBlank(status) && !isonlyValidate) {

   if (!(status.equalsIgnoreCase(CRM_AppConstants.ASSORTMENT_STATUS_PENDING_CHANGES)) && !(status.equalsIgnoreCase(CRM_AppConstants.ASSORTMENT_STATUS_DRAFT)) ) {
      strReturn = Label.CRM_Assortment_is_not_in_Draft_Stage;
   }
   else if (configCount <= 0) {
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
  list < Bundle__c > assortmentList = new list < Bundle__c > ();
  try {
   assortmentList = [Select Id, Assortment_Status__c from Bundle__c where(Id IN: assortmentIds)];

   if (!assortmentList.isEmpty() && (assortmentList[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED || assortmentList[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL)) {
    throw new CRM_AssortmentApprovalException(Label.CRM_Approved_assortment_cannot_be_edited_validated);
   }

   List < Bundle_Product__c > listProductsToUpdate = new List < Bundle_Product__c > {};
   List < CRM_ProductPricingHandler.DealWrapper > listAssortmentWrappers = new List < CRM_ProductPricingHandler.DealWrapper > {};

   // get the list of associated assortment products
   List < Bundle_Product__c > listAssortmentProducts = [Select Id, Product__c, Bundle__c, List_Price__c, Assortment_Price__c, Bundle__r.Id, Bundle__r.CurrencyISOCode,
    Bundle__r.Price_Book__c, Bundle__r.Start_Date__c, Bundle__r.End_Date__c from Bundle_Product__c
    where(Bundle__c IN: assortmentIds)
   ];

   if (listAssortmentProducts.isEmpty()) {
    throw new CRM_AssortmentApprovalException(Label.CRM_No_Products_found_for_assortment);
   }

   // create and populate a list of assortment wrappers to calculate the pricing                   
   for (Bundle_Product__c assortmentProduct: listAssortmentProducts) {
    listAssortmentWrappers.add(createAssortmentWrapper(assortmentProduct));
   }

   // Instanciate pricing handler to calcualte the updated price of the products 
   CRM_ProductPricingHandler pricingHandler = new CRM_ProductPricingHandler(listAssortmentWrappers);
   for (CRM_ProductPricingHandler.DealWrapper dw: listAssortmentWrappers) {
    Decimal listPrice = pricingHandler.getProductDatedListPrice(dw);
    Boolean isUpdateflag = false;
    if (dw.bundleProduct.List_Price__c == dw.bundleProduct.Assortment_Price__c) {
     dw.bundleProduct.Assortment_Price__c = listPrice;
     isUpdateflag = true;
    }
    if (dw.bundleProduct.List_Price__c != listPrice) {
     dw.bundleProduct.List_Price__c = listPrice;
     isUpdateflag = true;
    }
    if (isUpdateflag) {
     listProductsToUpdate.add(dw.bundleProduct);
    } else {
     throw new CRM_AssortmentApprovalException(Label.CRM_Validation_msg_prices_are_upto_date);
    }
   }

   // Update the list of assortment products which have undergone price-change 
   if (!listProductsToUpdate.isEmpty()) {
    system.debug('******listProductsToUpdate' + listProductsToUpdate);
    update listProductsToUpdate;
   }
  } catch (System.DMLException e) {
   for (Integer i = 0; i < e.getNumDml(); i++) {
    // Process exception here
    logAnException(e, assortmentList[0].Id);
    throw new CRM_AssortmentApprovalException(e.getDmlMessage(i));
   }
  } catch (Exception ex) {
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

 /**
  *  Method Defination to fetch overlapping assortments. 
  *  @name fetchOverlappingAssortment
  *  @param String assCampaignType,Id assortId,Set<Id> assortmentAccountsSet,Set<Id> assortmentProductsSet,Date starDate,Date endDate
  *  @return List<Bundle__c>
  *  @throws None
  */
 public static List < Bundle__c > fetchOverlappingAssortment(String assCampaignType, Id assortId, Set < Id > assortmentAccountsSet, Set < Id > assortmentProductsSet, Date starDate, Date endDate) {
   List < Bundle__c > overlappingAssortList = new List < Bundle__c > ();
   if (assCampaignType == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL) {
    overlappingAssortList = [SELECT id, name, Start_Date__c, End_Date__c, Assortment_Status__c, Campaign_Type__c,
     (SELECT id, name, List_Price__c, Bundle__r.name, Assortment_Price__c, Bundle__r.Assortment_Status__c, Product__c, Product__r.recordtypeId,Product__r.SAP_Material_Type__c, Product__r.Type__c,
      Bundle__r.Start_Date__c, Bundle__r.End_Date__c FROM Bundle_Products__r where Product__c IN: assortmentProductsSet)
     FROM Bundle__c
     WHERE Assortment_Status__c IN: statusValues and id != : assortId and Campaign_Type__c = : assCampaignType AND Start_Date__c <= : endDate AND End_Date__c >= : starDate
     ORDER BY Name
    ];
   } else {
    overlappingAssortList = [SELECT id, name, Start_Date__c, End_Date__c, Assortment_Status__c, Campaign_Type__c,
     (SELECT id, name, List_Price__c, Bundle__r.name, Assortment_Price__c, Bundle__r.Assortment_Status__c, Product__c, Product__r.recordtypeId,Product__r.SAP_Material_Type__c, Product__r.Type__c,
      Bundle__r.Start_Date__c, Bundle__r.End_Date__c FROM Bundle_Products__r where Product__c IN: assortmentProductsSet),
     (SELECT id, name, Account__c, Send_To_OTC__c FROM Assortment_Accounts__r where Send_To_OTC__c = true AND Account__c IN: assortmentAccountsSet)
     FROM Bundle__c
     WHERE Assortment_Status__c IN: statusValues and id != : assortId and Campaign_Type__c != : CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL AND Start_Date__c <= : endDate AND End_Date__c >= : starDate
     ORDER BY Name
    ];
   }
   return overlappingAssortList;
  }
  /**
   *  Method Defination to fetch all the overlapped assortment Products with different assortment prices for overlappied assortment. 
   *  @name fetchOverlappedProductsForAssortment
   *  @param Bundle__c assortId,set of Assortment_Account id,set of Assortment product ids.
   *  @return Map<Id, list<AssortmentProductWrapper>>
   *  @throws None
   */

 public static Map < Id, list < AssortmentProductWrapper >> fetchOverlappedProductsForAssortment(set < Id > assortmentAccountsSet, set < Id > assortmentProductsSet, Bundle__c assort1) {
  Map < Id, List < Bundle_Product__c >> mapoverlappingAssProducts = new Map < Id, List < Bundle_Product__c >> ();
  Map < Id, list < AssortmentProductWrapper >> mapIdToAssProductWrappers = new Map < Id, list < AssortmentProductWrapper >> ();
  //US#529 - check overlapping assortment with draft status - start
  Map < Id, list < AssortmentProductWrapper >> mapIdToAssProductWrappersWithDraft = new Map < Id, list < AssortmentProductWrapper >> ();
  //US#529 - check overlapping assortment with draft status - end
  List < Bundle__c > overlappingAssortList = new List < Bundle__c > ();
  Boolean isBeneluxAssortment = false;
  if(assort1.Price_Book__r.Business_Unit__c==CRM_AppConstants.TERRITORY_NETHERLAND_CODE || assort1.Price_Book__r.Business_Unit__c==CRM_AppConstants.TERRITORY_BELGIUM_CODE){
        isBeneluxAssortment = true;
  }
  overlappingAssortList = fetchOverlappingAssortment(assort1.Campaign_Type__c, assort1.Id, assortmentAccountsSet, assortmentProductsSet, assort1.Start_Date__c, assort1.End_Date__c);
  
  for (Bundle__c assortment2: overlappingAssortList) {
   
   if (assortment2.Assortment_Accounts__r.size() > 0 || assort1.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL) {

    if (assortment2.Bundle_Products__r.size() > 0) {

     for (Bundle_Product__c assProduct: assortment2.Bundle_Products__r) {
      if (mapoverlappingAssProducts.containsKey(assProduct.Product__c)) {
       mapoverlappingAssProducts.get(assProduct.Product__c).add(assProduct);
      } else {
       mapoverlappingAssProducts.put(assProduct.Product__c, new List < Bundle_Product__c > {
        assProduct
       });
      }
     }
     //overlappingAssortsMap.put(assortment2.id,assortment2);
    }
   }
  }
  // if there are overalapping assortments
  if (mapoverlappingAssProducts.size() > 0) {
   //get all assProducts to compare
   for (Bundle_Product__c assortProduct1: assort1.Bundle_Products__r) {

    if (mapoverlappingAssProducts.containsKey(assortProduct1.Product__c)) {
     for (Bundle_Product__c assortProduct2: mapoverlappingAssProducts.get(assortProduct1.Product__c)) {

      if (assortProduct1.Product__c == assortProduct2.Product__c) {
       if (assortProduct1.Assortment_Price__c != assortProduct2.Assortment_Price__c && isBeneluxAssortment) { 
       if(assortProduct2.Bundle__r.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED || assortProduct2.Bundle__r.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL){
            OverlappingApprovedAssortmentSet.add(assortProduct2.Bundle__c);
            AssortmentProductWrapper wrp = new AssortmentProductWrapper();
            wrp.assProductRecord = assortProduct2;
            wrp.assStartDate = convertDateToString(assortProduct2.Bundle__r.Start_Date__c);
            wrp.assEndDate = convertDateToString(assortProduct2.Bundle__r.End_Date__c);        
            if (!mapIdToAssProductWrappers.containsKey(assortProduct1.Product__c)) {
               mapIdToAssProductWrappers.put(assortProduct1.Product__c, new list < AssortmentProductWrapper > {
                  wrp
                 });
            } else {
                 mapIdToAssProductWrappers.get(assortProduct1.Product__c).add(wrp);
            }  
        }      
       }              
       if(!isBeneluxAssortment && assortProduct1.Product__r.SAP_Material_Type__c != CRM_AppConstants.UNBW_SAP_MATERIAL_TYPE){
        //US#529 - check overlapping assortment with draft status - start      
        if(assortProduct2.Bundle__r.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED || assortProduct2.Bundle__r.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL){
            system.debug('Approved assortment found');
            OverlappingApprovedAssortmentSet.add(assortProduct2.Bundle__c);
        }
        //US#529 - check overlapping assortment with draft status - end       
        AssortmentProductWrapper wrp = new AssortmentProductWrapper();
        wrp.assProductRecord = assortProduct2;
        wrp.assStartDate = convertDateToString(assortProduct2.Bundle__r.Start_Date__c);
        wrp.assEndDate = convertDateToString(assortProduct2.Bundle__r.End_Date__c);
        if(OverlappingApprovedAssortmentSet.size() > 0){ ////US#529 - check overlapping assortment with draft status- added this if condtion
            if (!mapIdToAssProductWrappers.containsKey(assortProduct1.Product__c)) {
             mapIdToAssProductWrappers.put(assortProduct1.Product__c, new list < AssortmentProductWrapper > {
              wrp
             });
            } else {
             mapIdToAssProductWrappers.get(assortProduct1.Product__c).add(wrp);
            }
        }
        //US#529 - check overlapping assortment with draft status -start
        if(OverlappingApprovedAssortmentSet.size() <= 0){
            if (!mapIdToAssProductWrappersWithDraft.containsKey(assortProduct1.Product__c)) {
             mapIdToAssProductWrappersWithDraft.put(assortProduct1.Product__c, new list < AssortmentProductWrapper > {
              wrp
             });
            } else {
             mapIdToAssProductWrappersWithDraft.get(assortProduct1.Product__c).add(wrp);
            }
        }
        //US#529 - check overlapping assortment with draft status - end
       }

      }
     }
    }

   }
   system.debug('=====mapIdToAssProductWrappers===========mapIdToAssProductWrappers===============' + mapIdToAssProductWrappers);
   //US#529 - check overlapping assortment with draft status
   system.debug('=====mapIdToAssProductWrappersWithDraft===========mapIdToAssProductWrappersWithDraft===============' + mapIdToAssProductWrappersWithDraft);
  }

  //US#529 - check overlapping assortment with draft status(added if else to return list base on status) 
  if(OverlappingApprovedAssortmentSet.size() > 0){
    return mapIdToAssProductWrappers;
  }
  else{
    return mapIdToAssProductWrappersWithDraft;
  }
 }

 public static List<Bundle__c> getAssortment(Id assortId){
    List < Bundle__c > lstAssortment = [SELECT id, name, Start_Date__c, End_Date__c, Pricing_Account__c, Campaign_Type__c, Product_Share__c, Assortment_Status__c,Publish_In_Progress__c,Price_Book__r.Business_Unit__c,
    Couponing_Discount__c,Couponing_Redemption_Rate__c,//US#958 - added teo new fields to query
    (SELECT id, name, List_Price__c, Assortment_Price__c,Bundle__r.name, Bundle__r.Assortment_Status__c, Product_Status__c, Product__c, Product__r.recordtypeId, Product__r.Type__c,Product__r.SAP_Material_Type__c, Product__r.Name, Product__r.IsActive FROM Bundle_Products__r),
    (SELECT id, name, Account__c, Send_To_OTC__c,Account__r.External_Id__c,Account__r.Sales_Organization__c FROM Assortment_Accounts__r)
    FROM Bundle__c
    WHERE id = : assortId
   ];
   return lstAssortment;
 } 
}