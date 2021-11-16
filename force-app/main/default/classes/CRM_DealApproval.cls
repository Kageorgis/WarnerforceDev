/**
   @Author: Cognizant Technology Solutions
   @name: CRM_DealApproval
   @CreateDate: Jan 06, 2016
   @Description:  Controller class to check for entry criteria and further checks before sending a Deal for approval.
   @Version - 1.0
   @reference: None
  */
global with sharing class CRM_DealApproval{
    
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    
    public static set<String> stageValues = new set<String>{CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED,CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL,CRM_AppConstants.OPPORTUNITY_STAGE_REVISED,CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED};
    public final ApexPages.StandardController theController;
    
    //Defect#4093 (German UAT)
    public static string OpportunityStartDate{get; set;}
    public static string OpportunityCloseDate{get; set;}
    
    public static Opportunity dealRecord {get;set;}
    public static list<OpportunityLineItem> dealRecordProducts;
    
    //US#207 
     public static Map<String,List<String>> clientIDMessageMap = new Map<String,List<String>>();
     public static boolean validationError = false;
     public static list <String> warningsList = new list <String>();
     public static Map<String,List<OpportunityLineItem>> messageCASDealProductIdMap = new Map<String,List<OpportunityLineItem>>();
 
    //US#354 - added new variabel for alert
    public static boolean PBEPDatesMissmatchAlert;
    public static boolean raiseAlert;
    public static map<Id,list<OpportunityLineItem>> overlappingDealProductsMap {get;set;} 
    
    /**
    *  @Description - constructor, checks for entry criteria before submitting record for approval, gathers data for further checks
    *  @name  CRM_DealApproval 
    */   
    public CRM_DealApproval(ApexPages.StandardController stdCon){
            raiseAlert = false;
            if (stdCon.getId() != null) {
                List<Opportunity> lstOpportunity =
                                 [SELECT id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,Account.Send_Pricing_to_CAS__c,RecordTypeId,
                                  (SELECT id,name, discount,OpportunityId,Opportunity.name,Opportunity.Start_Date__c,Opportunity.CloseDate,Product2.Name, CurrencyIsoCode,ProductCode,
                                  UnitPrice, Account_Price__c,Promoted_Price__c, ListPrice__c,Opportunity.StageName, Product2.recordtypeId,Product2.Type__c FROM OpportunityLineItems)
                                 FROM Opportunity
                                 WHERE id = :stdCon.getId()];
                if (!lstOpportunity.isEmpty()) {
                    dealRecord = lstOpportunity[0];
                    
                     //Defect#4093 (German UAT)
                    OpportunityStartDate = convertDateToString(dealRecord.Start_Date__c);
                    OpportunityCloseDate = convertDateToString(dealRecord.CloseDate);
                    
                    dealRecordProducts = dealRecord.OpportunityLineItems;
                }
            }
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    global Boolean isTerritoryFrance {
        get {
                if( dealRecord!=null && dealRecord.account.Sales_Organization__c==CRM_AppConstants.TERRITORY_FRANCE_CODE) {
                        return true;
                }
                return false;
        }
    }
    
     /**
     *  Method to fetch the Deal Product from DealId which is called from EditProductsCtrl.js 
     *  @name getLineItems
     *  @param Id opportunityId
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.ProductToEdit[] getLineItems(Id opportunityId) {
        CRM_DataObjects.ProductToEdit[] listProducts = new CRM_DataObjects.ProductToEdit[]{};
        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem>();
        Map<Id, CRM_DataObjects.DealProdWrapper> mapIdToDealProductWrappers = new Map<Id, CRM_DataObjects.DealProdWrapper>();
        for(OpportunityLineItem dealProduct : [select 
                                 // Line Item  Fields
                                 Id, P_L_Decay_Curve_Template__c, P_L_Quantity__c, /*Allocation_Override__c,*/ Product2.Local_Title__r.Language_Code__c, toLabel(Product2.Product_Language_Code__c), 
                                 POS_Quantity__c, ListPrice, ListPrice__c, Cut_off_date__c, Quantity, Account_Price__c, PricebookEntryId,Product2.RecordTypeId,
                                 Product2.Name,ProductCode, Product2.Id,  toLabel(Product2.Product_Format__c), currencyISOCode,Target_Quantity__c, Manually_Schedule__c,////US#895 -commneted code as a part of us to remove reference of suggested price
                                 Minimum_Price__c, toLabel(Product2.Release_Category__c), Product2.Product_Type__c, Product2.Street_Date__c, Customer_Retail_Price__c, Decay_Curve_Template__r.Name, 
                                 Approved_Qty__c, ServiceDate, Returns__c, Sales_Allowance__c, Coop__c, Merchandising__c, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c,
                                 Product2.Distribution_Cost__c, Product2.Production_Cost__c, Product2.Royalty_Fee_Fixed__c, /*Coop_Requested_Amount_NR__c,*/ Reason__c, Comments__c,
                                 Product2.Master_Negative__c,/*Product2.Marketing_Material__c,*/ TotalPrice, Total_COP__c, Est_Contribution__c, Opportunity.RecordTypeId, Opportunity.StageName, Product2.Type__c,
                                 Customer_Sales_Revenue__c, Customer_Contribution__c, Override_COP__c, Discount, Minimum_Contribution__c, PAP__c,Opportunity.Sales_Organisation__c,
                                 P_L_Decay_Curve_Template__r.Name,Promoted_Price__c,
                                 // Opportunity related Account Fields
                                 Opportunity.Account.Consignment_Customer__c,Opportunity.PriceBook2Id,Opportunity.Start_Date__c,Opportunity.CloseDate
                                 from OpportunityLineItem where OpportunityId = : opportunityId]){
            lstDealProducts.add(dealProduct);
        }
        for(OpportunityLineItem dealProduct : lstDealProducts) {

            //Defect#4597 - changed type of promoted price from double to decimal.
            Decimal promotedPrice = 0;
            Double replenQuantity = 0;
            CRM_DataObjects.ProductToEdit prod = new CRM_DataObjects.ProductToEdit();

            if ((dealProduct.Initial_Quantity__c == null || dealProduct.Initial_Quantity__c == 0) && dealProduct.Replen_Quantity__c == null) {
                replenQuantity = dealProduct.Quantity;
            } else {
                replenQuantity = dealProduct.Replen_Quantity__c; 
            }
            prod.lineItemId = dealProduct.Id;
            prod.pricebookEntryId = dealProduct.PricebookEntryId;
            prod.productId = dealProduct.Product2.Id;
            prod.productName = dealProduct.Product2.Name;
            prod.format = dealProduct.Product2.Product_Format__c;
            prod.productCode = dealProduct.ProductCode;
            prod.posQuantity = dealProduct.POS_Quantity__c;
            prod.totalQty = dealProduct.Quantity;
            prod.listPrice = dealProduct.ListPrice__c; // list price calculated from Pricebook Entry Period Object
            //US#895 -commneted code as a part of us to remove reference of suggested price
            //prod.suggestedPrice = dealProduct.Suggested_Price__c;
            prod.accountPrice = dealProduct.Account_Price__c;
            prod.minimumPrice = dealProduct.Minimum_Price__c;
            prod.pap = dealProduct.PAP__c;
            prod.languageCode = dealProduct.Product2.Product_Language_Code__c != null ? dealProduct.Product2.Product_Language_Code__c.toUppercase() : 'NA';
            if(dealProduct.Discount > 0.00){
                prod.discount = dealProduct.Discount;
            }else{
                prod.discount = 0.00;
            }
            if (dealProduct.Promoted_Price__c == null) {
                if(dealProduct.Account_Price__c > 0.00 && dealProduct.Discount > 0.00){
                    promotedPrice = dealProduct.Account_Price__c *(1-dealProduct.Discount/100);
                }else{
                    promotedPrice = dealProduct.Account_Price__c != null ? dealProduct.Account_Price__c : 0;
                }
            } else {
                promotedPrice = dealProduct.Promoted_Price__c;
            }
            //Defect#4597 - Code to added to setScale to 2 decimal places after value for promoted Price.
            prod.promotedPrice = promotedPrice.SetScale(2);
            //prod.promotedPrice = promotedPrice;
            prod.startDate = convertDateToString(dealProduct.ServiceDate);
            prod.approvedQty = dealProduct.Approved_Qty__c;
            prod.customerRetailPrice = dealProduct.Customer_Retail_Price__c;
            prod.cutOffDate = convertDateToString(dealProduct.Cut_off_date__c);
            prod.returns = dealProduct.Returns__c;
            prod.salesAllowance = dealProduct.Sales_Allowance__c;
            prod.totalPrice = dealProduct.Replen_Quantity__c != null && promotedPrice != null ? dealProduct.Replen_Quantity__c * promotedPrice : 0;
            prod.totalCOP = dealProduct.Total_COP__c;
            prod.currencyCode = dealProduct.currencyISOCode;
            prod.dealOrOrderId = opportunityId;            
            prod.targetUnit = dealProduct.Target_Quantity__c;
            prod.initialQuantity = dealProduct.Initial_Quantity__c;
            prod.replenQuantity = replenQuantity;
            prod.isManuallySchedule = dealProduct.Manually_Schedule__c;
            
            listProducts.add(prod);
        }
        return listProducts;
    }
    
    /**
     *  Method to fetch the Deal Product from DealId which is called from EditProductsCtrl.js 
     *  @name getLineItems
     *  @param Id opportunityId
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction 
    global static DealWrapper getOverlappingDealProducts(Id oppId) {
        Map<Id, list<DealProductWrapper>> mapIdToDealProductWrappers = new Map<Id,list<DealProductWrapper>>();
        DealWrapper dealWrapper = new DealWrapper();
        //list<OpportunityLineItem> overlappingDealProductList = new list<OpportunityLineItem>();
        Map<Id, List<OpportunityLineItem>> mapoverlappingDealProducts  = new Map<Id, List<OpportunityLineItem>>();
        map<id, Opportunity> overlappingDealsMap = new map<id, Opportunity>();
        try {
            raiseAlert = false;
            String result = preApprovalProcessCheckPoint(oppId);
            System.debug('result::'+result);
            if(!String.isBlank(result)){
                throw new CRM_DealApprovalException(result);
            }
            List<Opportunity> lstOpportunity =
                                     [SELECT id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,account.Digital_Country_Code__c,StageName,Sales_Organisation__c,Account.Send_Pricing_to_CAS__c,RecordTypeId,
                                      (SELECT id,name, discount,OpportunityId,Opportunity.name,Opportunity.Start_Date__c,Opportunity.CloseDate,Product2.Name, CurrencyIsoCode,ProductCode,
                                      UnitPrice, Account_Price__c,Promoted_Price__c, ListPrice__c,Opportunity.StageName, Product2.RecordTypeId,Product2.Type__c,Pricebook_Entry_Period__r.Client_Avail__c,Price_Tier__c,Opportunity.CurrencyIsoCode,Opportunity.RecordTypeId FROM OpportunityLineItems)
                                     FROM Opportunity
                                     WHERE id = :oppId]; //US#207 field added account.Send_Pricing_to_CAS__c
            Opportunity deal1 =  lstOpportunity!=null && lstOpportunity.size()>0?lstOpportunity[0]:null;  
            //US#207 - lineitemrecord list
            
            date startDate = deal1.Start_Date__c; // added as a part of DE#4759
            date endDate = deal1.CloseDate; // added as a part of DE#4759
            
            List<OpportunityLineItem> lstLineItemsRecord = deal1.OpportunityLineItems;
            
               
             
            List<OpportunityLineItem> oppLineItemMapList = new List<OpportunityLineItem>();
            map<Id,List<OpportunityLineItem>> dealProductDealMap = new map<Id,List<OpportunityLineItem>>();
            map<Id,Opportunity> mapIdToDealInstance = new map<Id,Opportunity>([SELECT id, Name, StageName, AccountId, Start_Date__c, CloseDate 
                    FROM Opportunity
                    WHERE AccountId = :deal1.accountId and StageName IN: stageValues and  id != :oppId and
                    ((Start_Date__c <=: startDate and  CloseDate >=:  startDate) or
                        (Start_Date__c  <=: endDate  and CloseDate  >=: endDate))
                    ORDER BY Name ]);
            

            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>([SELECT id, OpportunityId,Opportunity.Name,Opportunity.Start_Date__c,discount,
                                        Opportunity.CloseDate, Promoted_Price__c,ListPrice__c,name,Account_Price__c, Product2.Name,ProductCode,
                                        Opportunity.StageName, CurrencyIsoCode, UnitPrice,Pricebook_Entry_Period__r.Client_Avail__c,Price_Tier__c FROM OpportunityLineItem where OpportunityId IN : mapIdToDealInstance.keySet()]);

            for (OpportunityLineItem oppLineItem : oppLineItemList) {
                if (mapIdToDealInstance.containsKey(oppLineItem.OpportunityId)) {
                    Opportunity deal = mapIdToDealInstance.get(oppLineItem.OpportunityId);
                    if(oppLineItem.OpportunityId == deal.id){
                        if (!dealProductDealMap.containsKey(deal.Id)) {
                            dealProductDealMap.put(deal.id, new List<OpportunityLineItem>{oppLineItem});
                        } else {
                            dealProductDealMap.get(deal.id).add(oppLineItem);
                        }
                    }
                }
            }

            for(Opportunity deal2 : mapIdToDealInstance.values()){

            	/*if((deal1.Start_Date__c >= deal2.Start_Date__c && deal1.Start_Date__c <= deal2.CloseDate) ||
                   (deal1.CloseDate >= deal2.Start_Date__c && deal1.CloseDate <= deal2.CloseDate)) {
                	// Comment out this line and put it in above query while fetching records as a part of DE#4759 */
                    if(dealProductDealMap.containsKey(deal2.id) && (dealProductDealMap.get(deal2.id)).size() > 0) {
                        for(OpportunityLineItem dealProduct : dealProductDealMap.get(deal2.id)){
                            
                            if (mapoverlappingDealProducts.containsKey(dealProduct.Product2Id)) {
                                mapoverlappingDealProducts.get(dealProduct.Product2Id).add(dealProduct);
                            } else {
                                mapoverlappingDealProducts.put(dealProduct.Product2Id, new List<OpportunityLineItem> {dealProduct});
                            }
                        }
                        overlappingDealsMap.put(deal2.id,deal2);
                    }
                //}
            }
                  
                
            // if there are overalapping deals
            if(mapoverlappingDealProducts.size()>0) {
                 dealWrapper.lstLineItemWrapper = new List<CRM_DataObjects.ProductToEdit>();
                //get all dealProducts to compare
                for(OpportunityLineItem dealProduct1: deal1.OpportunityLineItems) {
                    if(mapoverlappingDealProducts.containsKey(dealProduct1.Product2Id)){
                         for(OpportunityLineItem dealProduct2: mapoverlappingDealProducts.get(dealProduct1.Product2Id)) {
                            if(dealProduct1.Product2Id == dealProduct2.Product2Id) {
                               
                                if(dealProduct1.Promoted_Price__c != dealProduct2.Promoted_Price__c && deal1.Sales_Organisation__c!=CRM_AppConstants.TERRITORY_GERMANY_CODE && deal1.Sales_Organisation__c!=CRM_AppConstants.TERRITORY_SWITZERLAND_CODE &&  !CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(deal1.account.Digital_Country_Code__c)) {
                                    raiseAlert = true;
                                }
                               
                                //US#436
                                if(deal1.Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || deal1.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE || CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(deal1.account.Digital_Country_Code__c)){
                                    raiseAlert = true;
                                }
                                DealProductWrapper wrp = new DealProductWrapper();
                                wrp.lineItemRecord = dealProduct2;
                                wrp.oppStartDate = convertDateToString(dealProduct2.Opportunity.Start_Date__c);
                                wrp.oppCloseDate = convertDateToString(dealProduct2.Opportunity.CloseDate);
                                if(!mapIdToDealProductWrappers.containsKey(dealProduct1.Product2Id)) {
                                //ankita RTASK1880945  start
                                Decimal promotedPrice = 0;
                                CRM_DataObjects.ProductToEdit prod = new CRM_DataObjects.ProductToEdit();
                                prod.lineItemId = dealProduct1.Id;
                                prod.productId = dealProduct1.Product2.Id;
                                if (dealProduct1.Promoted_Price__c == null) {
                                    if(dealProduct1.Account_Price__c > 0.00 && dealProduct1.Discount > 0.00){
                                        promotedPrice = dealProduct1.Account_Price__c *(1-dealProduct1.Discount/100);
                                    }else{
                                        promotedPrice = dealProduct1.Account_Price__c != null ? dealProduct1.Account_Price__c : 0;
                                    }
                                } else {
                                    promotedPrice = dealProduct1.Promoted_Price__c;
                                }
                                prod.productName = dealProduct1.Product2.Name;
                                //Defect#4597 - Code to added to setScale to 2 decimal places after value for promoted Price.
                                prod.promotedPrice = promotedPrice.SetScale(2);
                                
                                dealWrapper.lstLineItemWrapper.add(prod);
                                //ankita RTASK1880945 end
                                     mapIdToDealProductWrappers.put(dealProduct1.Product2Id,new list<DealProductWrapper>{wrp});
                                }
                                else {
                                     mapIdToDealProductWrappers.get(dealProduct1.Product2Id).add(wrp);
                                }
                            }
                        }
                    }
                }
            }
           //US#207 start 
           if(deal1 != null && deal1.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && deal1.account.Send_Pricing_to_CAS__c == true){
                getDealPricingValidated(dealWrapper,lstLineItemsRecord); //oppLineItemList
           }
            //US#207 end
            if(!raiseAlert && !validationError) { //Added check for SAP API validation error.
                 callStandardApprovalProcess(oppId);
            }
        }
        catch(Exception e){
            logAnException(e, oppId); 
            throw new CRM_DealApprovalException(e.getMessage());
        }
        dealWrapper.showMessage = raiseAlert;
        dealWrapper.mapWrapper = mapIdToDealProductWrappers;
       
      return dealWrapper;
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
            //Defect#4093 (German UAT)
            String dateFormat = CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
            return (Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0))).format(dateFormat);
            //return dt.format();
        }       
        return null;
    }
    
    /**
    *  @Description - method to perform approval process and then redirect control back to Deal standard detail page
    *  @name  goBackToDeal 
    */
    
    @RemoteAction
    global static void saveLineItems(Id opportunityId, List<CRM_DataObjects.ProductToEdit> products){
            list<OpportunityLineItem> updateDealProducts = new list<OpportunityLineItem>();
            try {   
                    if(products != null && !products.isEmpty()) {
                        // Get all current products
                        Map<Id,OpportunityLineItem> mapCurrentDealProducts = new Map<Id,OpportunityLineItem>(
                                                                  [SELECT Id, Opportunity.account.Sales_Organization__c, POS_Quantity__c,P_L_Quantity__c, P_L_Decay_Curve_Template__c,PAP__c, PricebookEntryId, Quantity, Discount, Customer_Retail_Price__c, UnitPrice, Returns__c, Sales_Allowance__c,
                                                                  Promoted_Price__c,Coop__c, Merchandising__c, Product2.Distribution_Cost__c, Product2.Production_Cost__c, Product2.Royalty_Fee_Fixed__c, Opportunity.stagename,
                                                                  Product2.Master_Negative__c, Opportunity.RecordTypeId,
                                                                  (Select Id, Type,OpportunityLineItemId, Description, Quantity, ScheduleDate, Revenue  From OpportunityLineItemSchedules)
                                                                  FROM OpportunityLineItem
                                                                  WHERE OpportunityId = :opportunityId]);
                                                                  
                        // Run through list of records to update and track the upsert records
                        List<OpportunityLineItem> lstDealProducttoUpdate = new List<OpportunityLineItem>();
    					for (CRM_DataObjects.ProductToEdit x : products) {
                            if (mapCurrentDealProducts.containsKey(x.lineItemId)) {
                                OpportunityLineItem dealProduct = mapCurrentDealProducts.get(x.lineItemId);
                                    
                                    if (x.promotedPrice == null) {
                                        throw new CRM_DealApprovalException(System.Label.CRM_Enter_Value_For_Promoted_Price);
                                    } else if(x.promotedPrice != dealProduct.Promoted_Price__c){
                                        system.debug('==Inside Elseif Different Promoted Price ==');
                                        Decimal promoPrice = x.promotedPrice;
                                        dealProduct.Promoted_Price__c = promoPrice.setScale(2);
                                        lstDealProducttoUpdate.add(dealProduct);
                                    }
                                    //lstDealProducttoUpdate.add(dealProduct);
                            }
                        }
                        
                        if(lstDealProducttoUpdate != null && !lstDealProducttoUpdate.isEmpty()){
                            update lstDealProducttoUpdate;
                        }
                    }
                    callStandardApprovalProcess(opportunityId);
            }
            catch(System.DMLException e){
               for (Integer i = 0; i < e.getNumDml(); i++) {
                    throw new CRM_DealApprovalException(e.getDmlMessage(i));
                }
            }
            catch(Exception e){
                    logAnException(e, opportunityId); 
                    throw new CRM_DealApprovalException(e.getMessage());
            }
    }
	
	/**
    *  @Description - method to perform approval process and then redirect control back to Deal standard detail page
    *  @name  goBackToDeal 
    */
    global static void callStandardApprovalProcess(Id dealID){
            //#US 463
            updateMinimumContribution(dealID);
            list<OpportunityLineItem> updateDealProducts = new list<OpportunityLineItem>();
            //createNewApprovalProcess(dealID);
            
            // Below Lines are Commented as a part of DE#4766
            // create the new approval request to submit
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(dealID);
            // submit the approval request for processing
            //system.debug('*********dealID'+dealID);
            Approval.ProcessResult result = Approval.process(req);
            //system.debug('*********result'+result);
            // display if the reqeust was successful
    }
    
    
    
    // added as a part of DE#4766 Code Start
    
    @future
    global static void createNewApprovalProcess(Id dealID) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(dealID);
            // submit the approval request for processing
            system.debug('*********dealID'+dealID);
            Approval.ProcessResult result = Approval.process(req);
    }
    
    // added as a part of DE#4766 Code End
    
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
        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
        errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
        errorLogInstance.errorMessage = ex.getMessage();
        errorLogInstance.stackTrace = ex.getStackTraceString();
        listErrorLog.add(errorLogInstance);     
    }
    
    /**
    *  @Description - wrapper class
    *  @name  DealProductWrapper 
    */
    global class DealProductWrapper{
        public OpportunityLineItem lineItemRecord;
        public String oppStartDate;
        public String oppCloseDate;
        //US#354 -added two new fields.
        public String PBEPStartDate;
        public String PBEPCloseDate;
        public Boolean isChanged=false;
    }
    
    /**
    *  @Description - wrapper class
    *  @name  DealProductWrapper 
    */
    global class DealWrapper{
        public Boolean showMessage=false;
        public map<Id,list<DealProductWrapper>> mapWrapper;
        public List<CRM_DataObjects.ProductToEdit> lstLineItemWrapper;
        //US#207
        public List<String> CASErrorList;
        public Map<String,List<OpportunityLineItem>> errorCASDealProductMap; 
    }
    
    /**
    *  @Description - #US 463 method to update the minimum contribution field in opportunity
    *  @name  goBackToDeal 
    **/
    global static void updateMinimumContribution(Id dealID) {
        if (dealID != null) {
            List < Opportunity > lstOpportunity = [SELECT id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c, StageName, RecordTypeId,Account.Digital_Country_Code__c,
                                                   User__c,Bundle__r.User__c ,Minimum_Contribution__c,Minimum_Contribution_Finance__c,Minimum_Contribution_Sales__c,
                                                   (SELECT id,name,Contribution__c,Min_Contribution_Finance__c,Min_Contribution_Sales__c FROM OpportunityLineItems) 
                                                   FROM Opportunity 
                                                   WHERE id = : dealID];
        
            if (!lstOpportunity.isEmpty()) {
                dealRecord = lstOpportunity[0];
                //US#394(Germany)
                Boolean isGerman = ((lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                                    ||
                                    (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(lstOpportunity[0].Account.Digital_Country_Code__c)));
                Boolean isNLOrBE =  (dealRecord.account.Sales_Organization__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE || dealRecord.account.Sales_Organization__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE);                
                if(isGerman || isNLOrBE){
                    Decimal minPerc;
                    Decimal minPriceFinance;
                    Decimal minPriceSales;
                    for (OpportunityLineItem oppLineItem: lstOpportunity[0].OpportunityLineItems) {
                        if(isNLOrBE){
                            minPerc = getMinimumContrubutionPrice(minPerc,oppLineItem.Contribution__c);
                        }else if(isGerman){//US#394(Germany)
                            minPriceFinance = getMinimumContrubutionPrice(minPriceFinance,oppLineItem.Min_Contribution_Finance__c);
                            minPriceSales = getMinimumContrubutionPrice(minPriceSales,oppLineItem.Min_Contribution_Sales__c);
                        }
                    }
                    if(isNLOrBE && minPerc != null){
                        lstOpportunity[0].Minimum_Contribution__c = minPerc;
                    }else if (isGerman){ //US#394(Germany)
                        if(minPriceFinance != null)
                            lstOpportunity[0].Minimum_Contribution_Finance__c = minPriceFinance;
                        if(minPriceSales != null)
                            lstOpportunity[0].Minimum_Contribution_Sales__c = minPriceSales;
                    }
                    update lstOpportunity[0];
                }
                //Ankita US#810 start Copy Assortment Selected Approval User to Deal --> Approval user for Approval Process
                if(lstOpportunity[0].Bundle__r.User__c != null && (lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE
                    || lstOpportunity[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE)){
                    lstOpportunity[0].User__c = lstOpportunity[0].Bundle__r.User__c; 
                    update lstOpportunity[0];
                }  // US#810 End  
            }
        }
    }
    
    /**
    *  @Description - #US 394 method to get the minimum contribution Price from Deal Product
    *  @name  goBackToDeal 
    **/
    private static Decimal getMinimumContrubutionPrice(Decimal minPrice,Decimal dealProductMinPrice){
        if (minPrice == null) {
            minPrice = dealProductMinPrice;
        } else if (minPrice > dealProductMinPrice) {
            minPrice = dealProductMinPrice;
        }
        return minPrice;
    }
    
    @RemoteAction 
    global static String preApprovalProcessCheckPoint(Id oppId) 
    {
        Opportunity opp; 
        String stage;
        Date pricingStartDate;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Sales_Organisation__c, Account.Digital_Country_Code__c, RecordTypeId, StageName, Start_Date__c, Sent_To_SAP__c, Allow_Backdated_Pricing__c, HasOpportunityLineItem, RecordType.Name, RecordType.DeveloperName, OwnerId, CreatedById FROM Opportunity WHERE Id =: oppId];
        Boolean isGerman = (
            (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (lstOpportunity[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || lstOpportunity[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
            ||
            (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(lstOpportunity[0].Account.Digital_Country_Code__c))
        );

        List<User> runningUser = new List<User>();
        runningUser = [SELECT Id,Profile.Name,isActive FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        if (runningUser != null && runningUser.size() > 0){
            if(runningUser[0].Profile.Name.contains('Finance') && !isGerman){
                return Label.CRM_Deal_Approval_Incorrect_Profile;
            }else if(!lstOpportunity.isEmpty() && runningUser[0].Id != lstOpportunity[0].OwnerId && runningUser[0].Id != lstOpportunity[0].CreatedById && lstOpportunity[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE){
                return Label.CRM_Deal_Approval_Incorrect_User;
            }
        }
        
        //US #516: Restrict 'CRM - Marketing FR/BX' to submit FR Deal for Approval
        if(!lstOpportunity.isEmpty() && lstOpportunity[0].Sales_Organisation__c != null && lstOpportunity[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE && runningUser != null && runningUser.size() > 0 && runningUser[0].Profile.Name.equals(CRM_AppConstants.PROFILE_CRM_Marketing_FR_BX)){
            return Label.CRM_Deal_Approval_Incorrect_Profile_Error;
        }
        
        if(!lstOpportunity.isEmpty())
        {
            opp = lstOpportunity.get(0);
            stage = opp.StageName;
            pricingStartDate = opp.Start_Date__c;
        }
       
        String strReturn = '';
        if (String.isNotBlank(stage))
        {
            if (opp != null && opp.RecordType != null && !(opp.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DIGITAL_DEAL ||opp.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DEAL)){
                strReturn = Label.CRM_Deal_Approval_Incorrect_RecordType;
            }
            else if(!(stage.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED)|| stage.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED))) 
            {             
                strReturn = Label.CRM_Msg_Deal_Approval_Incorrect_Stage;
            }
            else if (pricingStartDate == null )// || ! (pricingStartDate >= system.today()) )
            {
                strReturn = Label.CRM_Msg_Deal_Approval_Incorrect_PricingDate;
            }
            else if (  !(opp.Allow_Backdated_Pricing__c) && pricingStartDate != null &&  pricingStartDate < system.today() && opp.Sent_To_SAP__c == null)
            {
                strReturn = Label.CRM_Msg_Deal_Approval_Incorrect_PricingDate;
            }
            else if(opp != null && opp.HasOpportunityLineItem == false && (opp.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DIGITAL_DEAL || opp.RecordType.Name == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_PHYSICAL_DEAL )){
                strReturn = Label.CRM_Msg_Deal_Approval_No_DealProduct;
            }
            else if ((stage.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED)|| 
                stage.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED)) && pricingStartDate != null && pricingStartDate >= system.today())
            {
                 if(opp!=null && opp.OpportunityLineItems.size()>0) {
                    for(OpportunityLineItem dl: opp.OpportunityLineItems) {
                        if(dl.Product2Id!=null) {
                            if(dl.ListPrice__c==0 && dl.Product2.RecordTypeId == digitalProductRecordTypeId) {
                                strReturn = Label.CRM_Client_UnAvail_Message;
                            }
                        }
                    }
                }
            }
        } 
        return strReturn;
	}
    
    
	  /**
	  *  @Description - #US 354 method to get deal products where the deal pricing dates are outside of the PBEP
	  *  @name  getPBEPMissMatchDealProducts
	  *  @param -  OpportunityId 
	  */ 
	 @RemoteAction
	 global static DealWrapper getPBEPMissMatchDealProducts(Id oppId) {
	  Map <Id,list<DealProductWrapper>> mapIdToPBEPMissMatchDealProductWrappers = new Map <Id,list<DealProductWrapper>>();
	  DealWrapper dealWrapper = new DealWrapper();
	  Map <Id,List<OpportunityLineItem>> mapPBEPMissMatchDealProducts = new Map <Id,List <OpportunityLineItem>>();
	  map < id, Opportunity > overlappingDealsMap = new map < id, Opportunity > ();
	      try {
	       PBEPDatesMissmatchAlert = false;
	       
	       List < Opportunity > lstOpportunity = [SELECT id, name, Start_Date__c, CloseDate,
	        (SELECT id, name, OpportunityId, Opportunity.name, Opportunity.Start_Date__c,NR_Deal_Product_Unique_Key__c, Opportunity.CloseDate, Product2.Name,Pricebook_Entry_Period__r.Start_Date__c,
	         Pricebook_Entry_Period__r.End_Date__c,Opportunity.StageName, Product2.RecordTypeId FROM OpportunityLineItems) FROM Opportunity WHERE id = : oppId AND RecordTypeId=:CRM_RecordTypeUtil.RT_DEAL_PHYSICAL];
	         
	       Opportunity deal1 = lstOpportunity != null && lstOpportunity.size() > 0 ? lstOpportunity[0] : null;
	       
	       List < OpportunityLineItem > oppLineItemMapList = new List < OpportunityLineItem > ();
	       map < Id, List < OpportunityLineItem >> dealProductDealMap = new map < Id, List < OpportunityLineItem >> ();
	
	       List <OpportunityLineItem> oppLineItemList = new List <OpportunityLineItem>();
	       if(deal1 != null && deal1.OpportunityLineItems != null && deal1.OpportunityLineItems.size() > 0)
	           oppLineItemList = deal1.OpportunityLineItems;
	       
	       for (OpportunityLineItem oppLineItem: oppLineItemList) {
	                if(oppLineItem.NR_Deal_Product_Unique_Key__c == null && (oppLineItem.Opportunity.Start_Date__c < oppLineItem.Pricebook_Entry_Period__r.Start_Date__c || oppLineItem.Opportunity.CloseDate > oppLineItem.Pricebook_Entry_Period__r.End_Date__c)){
	                    PBEPDatesMissmatchAlert = true;
	                    DealProductWrapper wrp = new DealProductWrapper();
	                    wrp.lineItemRecord = oppLineItem;
	                    wrp.oppStartDate = convertDateToString(oppLineItem.Opportunity.Start_Date__c);
	                    wrp.oppCloseDate = convertDateToString(oppLineItem.Opportunity.CloseDate);
	                    wrp.PBEPStartDate = convertDateToString(oppLineItem.Pricebook_Entry_Period__r.Start_Date__c);
	                    wrp.PBEPCloseDate = convertDateToString(oppLineItem.Pricebook_Entry_Period__r.End_Date__c);
	                    if (!mapIdToPBEPMissMatchDealProductWrappers.containsKey(oppLineItem.Product2Id)) {
	                     mapIdToPBEPMissMatchDealProductWrappers.put(oppLineItem.Product2Id, new list < DealProductWrapper > {
	                      wrp
	                     });
	                    } else {
	                     mapIdToPBEPMissMatchDealProductWrappers.get(oppLineItem.Product2Id).add(wrp);
	                    }
	                }
	       }
	       dealWrapper.showMessage = PBEPDatesMissmatchAlert;
	       dealWrapper.mapWrapper = mapIdToPBEPMissMatchDealProductWrappers;
	       return dealWrapper;
	     }
	     catch (Exception e) {
	        logAnException(e, oppId);
	        throw new CRM_DealApprovalException(e.getMessage());
	     }
	 }
 	
 	//***Change in approval process -End
    public class CRM_DealApprovalException extends Exception {
    }
    
  /**
  *  @Description US#207 Method to validate deal pricing 
  *  @name getDealPricingValidated
  *  @param OpportunityLineItem Records
  *  @return map of error massage along with DealProduct ID.
  *  @throws None
  */
  @RemoteAction
  global static void getDealPricingValidated(DealWrapper dealWrapper,List <OpportunityLineItem> oppLineItemList){
    
    try{    
       List<WB_ClientAvailTempPriceWrapper> WB_ClientAvailTempPriceWrapperList = new List<WB_ClientAvailTempPriceWrapper>();
       List<WB_ClientAvailTempPriceWrapper> lstResultWrapper = new List<WB_ClientAvailTempPriceWrapper>();
       map<Id,OpportunityLineItem> mapIdWithLineitems = new map<Id,OpportunityLineItem>();
       for (OpportunityLineItem oppLineItem: oppLineItemList) {
            
            mapIdWithLineitems.put(oppLineItem.Id,oppLineItem);
                   
            WB_ClientAvailTempPriceWrapper tempPriceWrapper = new WB_ClientAvailTempPriceWrapper();
            tempPriceWrapper.clientAvailID = oppLineItem.Pricebook_Entry_Period__r.Client_Avail__c; 
            tempPriceWrapper.price = oppLineItem.Promoted_Price__c; // Promo Price
            tempPriceWrapper.priceTier = oppLineItem.Price_Tier__c; // Price Tier
            tempPriceWrapper.priceStartDate = oppLineItem.Opportunity.Start_Date__c!=null ? oppLineItem.Opportunity.Start_Date__c:null; //pricing start date
            tempPriceWrapper.priceEndDate = oppLineItem.Opportunity.CloseDate!=null ? oppLineItem.Opportunity.CloseDate:null; // Pricing End Date 
            tempPriceWrapper.dealID = oppLineItem.OpportunityId; // Deal Id
            tempPriceWrapper.priceType = 'TEMP';  //Default 
            tempPriceWrapper.currencyCode = oppLineItem.Opportunity.CurrencyIsoCode!=null ? oppLineItem.Opportunity.CurrencyIsoCode:null;   
            tempPriceWrapper.priceStatus = 'Active'; //Default 
            tempPriceWrapper.dealProductID = oppLineItem.Id;
            
            WB_ClientAvailTempPriceWrapperList.add(tempPriceWrapper);
            
       }
       
        WB_ClientAvailTempPriceHelper  tempPriceWrapper  = new WB_ClientAvailTempPriceHelper ();
        if(WB_ClientAvailTempPriceWrapperList != null)
            lstResultWrapper = tempPriceWrapper.validateTempPrice(WB_ClientAvailTempPriceWrapperList); 
        List<String> errorMsgCASList = new List<String> ();             
                   
        for(WB_ClientAvailTempPriceWrapper tempWrap:lstResultWrapper){
            if(tempWrap.status == 'Failed'){
                List<OpportunityLineItem> dealProIDList = new List<OpportunityLineItem> ();
                for(String msg : tempWrap.messages){
                    if(messageCASDealProductIdMap.containsKey(msg) && mapIdWithLineitems !=null && mapIdWithLineitems.size() > 0){
                        messageCASDealProductIdMap.get(msg).add(mapIdWithLineitems.get(tempWrap.dealProductID));
                    }else{ 
                        dealProIDList.add(mapIdWithLineitems.get(tempWrap.dealProductID));
                        messageCASDealProductIdMap.put(msg,dealProIDList);
                        
                    } 
                }
            }
        } 
        for(String err:messageCASDealProductIdMap.keySet()){  
            if(messageCASDealProductIdMap.get(err) != null ){
                validationError = true;
                errorMsgCASList.add(err);
                
            }
        }
        dealWrapper.CASErrorList = errorMsgCASList;
        dealWrapper.errorCASDealProductMap = messageCASDealProductIdMap;
    }
    catch (Exception e) {
    
    } 
  }
    
    /* Defect#4093 (German UAT)
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
}