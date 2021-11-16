/**
   @Author Cognizant
   @name CRM_UploadDealProductsController
   @CreateDate 25 Jan 2016
   @Description This class is used to upload (update/insert) the deal products.
   @Version <1.0>
   @reference Requirement no 83
*/
global with sharing class CRM_UploadDealProductsController {
    
    public Id dealId;
    public Opportunity opp;
    public static ApexPages.StandardController theController;
    public static Integer totalFailedRecords;
    //US#909 Ankita Do not add Quantity column on Addproduct page 
    public boolean displayQtyCol{get; set;} 
    /* variable to hold available Coop Balance */
    public Double coopBalanceFromBudget {get; set;}
    public Double coopRequestedDealAmount {get; set;}
    public boolean isGerman{get; set;}
    public Boolean isPageReadOnly {get; set;}
    public Boolean isEstimateAvailableOnDealAndDp {get; set;}
    public String handsontableversion{get; set;}
    public String show{get; set;}
    //US : 750
    public static Map<String, String> PRODUCT_SAP_DIST_CHAIN_STATUS = getAllSAPDistChainStatus();
    public static Set<String> setSDCS = new Set<String>(system.label.CRM_SAP_Dist_chain_product_Status.split(','));
    public static String dateFormat =  getUserDateFormat().replace('mm','MM');
    public Boolean isExpanded{get; set;}
    
    //US : 936 - for sales org 2500(USA), 2504(MEXICO) and 2403(CANADA) and DE#4412 added CurrencyIsoCode field in Query
    global Boolean getisUSCANMEXTerritory() {
      if (opp == null) {
            opp = [select id,CurrencyIsoCode, Sales_Organisation__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName from Opportunity where id=: dealId];
        }
      if(opp.RecordTypeId !=null && opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && CRM_AppConstants.US_SALES_ORGS.contains(opp.Sales_Organisation__c))
        return true;
      return false;
    }
    
    //US : 989
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    } 
    
    /*  
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global static String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    
    /**
    *  @Description - method to get all Product SAP Dist Chain Status
    *  @name  getAllSAPDistChainStatus 
    */
    public static map<String,String> getAllSAPDistChainStatus(){
        Map<String, String> mapPDCS = new Map<String, String>();
        for(Schema.PicklistEntry f : Product2.SAP_Dist_chain_product_Status__c.getDescribe().getPicklistValues()){
            mapPDCS.put(f.getValue(),f.getLabel());
        }
        return mapPDCS;
    } 
    
    //US : 750
    private static void updateValidationMessgae(OpportunityLineItemWrapper lineItemWrapper,String validationMsg){
        String sdcs = lineItemWrapper.lineItemRecord.Product2.SAP_Dist_chain_product_Status__c;
        Time myTime = Time.newInstance(0,0,0,0);
        DateTime tempDate = lineItemWrapper.lineItemRecord.Product2.Distribution_Chain_Valid_From_Date__c != null ? 
                        DateTime.newInstance(lineItemWrapper.lineItemRecord.Product2.Distribution_Chain_Valid_From_Date__c,myTime) : null;
        String dcvd = tempDate != null ? tempDate.format(dateFormat) : '';
        
        if(!setSDCS.contains(sdcs) && PRODUCT_SAP_DIST_CHAIN_STATUS.containsKey(sdcs) && PRODUCT_SAP_DIST_CHAIN_STATUS.get(sdcs) != null){
            lineItemWrapper.validation = String.format(
                                                        System.Label.CRM_SAP_Dist_chain_product_Status_Error_Msg,
                                                        new String[] {
                                                            '\''+PRODUCT_SAP_DIST_CHAIN_STATUS.get(sdcs)+'\'',
                                                            '\''+(dcvd != null ? dcvd : '')+'\''}
                                                        );
            lineItemWrapper.isWarningRec = true; //US : 994
        }else{
            lineItemWrapper.validation = validationMsg;
            lineItemWrapper.isWarningRec = false; //US : 994
        }
    }
    
    /**
    *  @Description - constructor
    *  @name  CRM_UploadDealProductsController 
    */
    global CRM_UploadDealProductsController(ApexPages.StandardController stdController) {
        dealId = stdController.getId();
        theController = stdController;
        show = apexpages.currentpage().getparameters().get('show');
        isExpanded = apexpages.currentpage().getparameters().get('isExpanded') != 'true' ? false : true;
        
        /* Fetch the CoOp information including available balance */
        if(dealId != null) {
            Opportunity[] listDeals = [select Id, Amount, StageName, RecordTypeId, Co_op_Requested_Amount__c,/* US#954 Ankita US Games Coop_Budget__r.Co_op_Balance__c,*/ 
                            Account.Sales_Organization__c, Account.Digital_Country_Code__c,Last_Published_Date__c,NR_Deal_Unique_Key__c //US#598
                            from Opportunity 
                            where Id =: dealId ];
                            
            if(!listDeals.isEmpty()) {
                Opportunity deal = listDeals[0];
                coopRequestedDealAmount = deal.Co_op_Requested_Amount__c != null ? deal.Co_op_Requested_Amount__c : 0;
                //US#954 Ankita US Games 
                //coopBalanceFromBudget = deal.Coop_Budget__r.Co_op_Balance__c != null ? deal.Coop_Budget__r.Co_op_Balance__c : 0;
                
                isEstimateAvailableOnDealAndDp = (deal.Amount > 0); 
                
                // Set if page is read Only
                isPageReadOnly = (deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED || deal.stageName == CRM_AppConstants.OPPORTUNITY_STAGE_CLOSED)
                                && ( 
                                    (deal.Account.Sales_Organization__c != CRM_AppConstants.TERRITORY_FRANCE_CODE) 
                                    || (deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_FRANCE_CODE && deal.Last_Published_Date__c==null)
                                    );
                
                // set isGerman flag if deal is related to DE
                isGerman = (
                    (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                    ||
                    (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(deal.Account.Digital_Country_Code__c))
                );
            }
            //US#909 Ankita Do not add Quantity column on Addproduct page
            displayQtyCol =false;
        }
          handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
    }
    
    
    /**
     * Method to fetch picklist values for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     * @param first_val First value to be displayed along with the picklist values
     */
    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getFilterPicklistValues(
            String object_name,
            String field_name,
            String first_val
    ) {
        return CRM_AddProductsHelper.getFilterPicklistValues(object_name, field_name, first_val);
    }
    
    /**
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class OpportunityLineItemWrapper {
        public OpportunityLineItem lineItemRecord;
        public Decimal totalPrice;
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public boolean previouslySelectedForRemoval=false;
        public DigitalDealWrapper digital=new DigitalDealWrapper();
        public String strReason = '';
        public Decimal nCoopRequestedAmount;
        public String strComments = '';
        public Integer rowIndex;
        public Boolean overridePricing=false;
        //ER-003026
        public String isContUnderMinFinance;
        public String isContUnderMinSales;
        
        // totalFailedRecords: Number of failed records during (insert/update/delete) operations to be displayed on VF page
        // totalFailedRecords will be taken from first wrapper record always by VF javascript 
        public Integer numFailedRecords;
        //US#598
        global Boolean isUnTargetedDealProd =false;
        
        //US : 994 
        public string recrodStatus='';
        public boolean isWarningRec=false;
    }
     
     /**
    *  @Description - inner wrapper class
    *  @name  DigitalDealWrapper 
    */
     global class DigitalDealWrapper{
        public String videoVersion;
        public String channel;
        public String format;
        public String language;
        public String retailerProductId;
        //#767
        public String vendorId;
        public Integer posQuantity;  //ER-004333
     }
     
    global boolean getDigitalDeal() {
        if (opp == null) {
            opp = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        if(opp.RecordTypeId!=null && opp.RecordType.Name!= null && opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
            //isDigitalDeal = true;
            return true;
        }
        return false;
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

        /*if (currentUserLocale.contains('en-')) {
            currentUserLocale = currentUserLocale.substringBefore('-');
        }*/
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }

    // #3074: ENHANCEMENT - Request ability to enter ePOS Quantity in Upload/Extract page (for consignment customers only)
    global boolean getIsConsignmentCustomer(){
        if (opp == null) {
            opp = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        if (opp.AccountId != null && opp.Account.Consignment_Customer__c){
            return true;
        }else{
            return false;
        }
    }
    
    global boolean getShowCoopFields(){
        if (opp == null) {
            opp = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Market_Type__c,Account.Sales_Organization__c, Co_op_Closed__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        String territorys;
        if(opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
            territorys = CRM_Hide_Coop_Fields__c.getInstance(opp.RecordType.DeveloperName) != null ? CRM_Hide_Coop_Fields__c.getInstance(opp.RecordType.DeveloperName).Upload_Extract_Territory__c : '';
        }else{
            territorys = CRM_Hide_Coop_Fields__c.getInstance('Deal') != null ? CRM_Hide_Coop_Fields__c.getInstance('Deal').Upload_Extract_Territory__c : '';
        }
        Set<String> setOfTerritorys = new Set<String>(territorys.split(';'));
        if(!setOfTerritorys.isEmpty()){
            if(setOfTerritorys.contains(opp.Sales_Organisation__c) || setOfTerritorys.contains(opp.Account.Digital_Country_Code__c))
                 return true;
        }
        return false;
    }

    global boolean getIsJapanRentalDeal(){
        if (opp == null) {
            opp = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Account.Sales_Organization__c ,Co_op_Closed__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        Boolean isJapanTerritory = (
            (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && opp.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                ||
            (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && opp.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
        );
        //Boolean isJapanRental = isJapanTerritory && dealProduct.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;

        return isJapanTerritory && opp.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
    }
    
    //#767
       global boolean getIsUSCANDeal(){
        system.debug('Inside getIsUSCANDeal');
        if (opp == null) {
            opp = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Account.Sales_Organization__c ,Co_op_Closed__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        Boolean isUSCANTerritory =            
            (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && (opp.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE||
            opp.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE));
       system.debug('isUSCANTerritory '+isUSCANTerritory);
        return isUSCANTerritory;
    }
    
     global Boolean getIsCoOpClosed(){
        if (opp == null) {
            opp = [SELECT id, NR_Deal_Unique_Key__c, Pricebook2Id,Account.Sales_Organization__c , Sales_Organisation__c,Co_op_Closed__c,
                        Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c,
                        Account.Consignment_Customer__c 
                        FROM Opportunity 
                        WHERE id=: dealId];
        }
                     
        Boolean isGerman = (
                    (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (opp.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || opp.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                    ||
                    (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(opp.Account.Digital_Country_Code__c))
                );
        
        if(opp.Co_op_Closed__c == true && isGerman == true ){
            return true;
        }else{
            return false;
        } 
    }
    
    global boolean getIsNRDeal(){
        if (opp == null) {
            opp = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        return (opp.NR_Deal_Unique_Key__c != null) ? true: false;
    }
    
    /*global boolean getIsUKSalesOrg() {
        if (opp == null) {
            opp = [select id, Pricebook2Id, Sales_Organisation__c, RecordTypeId, RecordType.Name,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        if(
            opp.Sales_Organisation__c == CRM_AppConstants.TERRITORY_UK_CODE ||
            (
                opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL &&
                opp.AccountId != null &&
                (
                    opp.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    opp.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
                )
            )
        ) {
            return true;
        }
        return false;
    }*/
    
    /**
     *  Method to fetch the Deal Product from DealId  
     *  @name getOpportunityLineItems
     *  @param Id opportunityId
     *  @return CRM_UploadDealProductsController.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<OpportunityLineItemWrapper> getOpportunityLineItems(Id oppId) {
        // Construct a list of Opportunity Line Items
        List<OpportunityLineItemWrapper> returnWrapperList = new List<OpportunityLineItemWrapper>();
        // Find what products are in the Deal
        try{
                if(CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c) {
                    throw new CRM_ProductPricingHandler.CRM_Exception(Label.CRM_Deal_Entry_NoAccessError);
                }
                for(OpportunityLineItem lineItem:
                        [SELECT Name,ListPrice, toLabel(Reason__c),Opportunity.Digital_Country_Code__c,ListPrice__c, PriceBookEntryId, product2.Universal_Picture_Code__c,Promoted_Price__c, Customer_Retail_Price__c,Permanent_Price_Tier__c,Account_Price__c,//US#663 - added new field on page prem. price tier and account price #767
                         Opportunity.RecordTypeId,Opportunity.RecordType.Name ,Opportunity.NR_Deal_Unique_Key__c,Decay_Curve_Template__c, Pricebook_Entry_Period__r.Retailer_Product_ID__c,Pricebook_Entry_Period__r.Vendor_ID__c,Pricebook_Entry_Period__c,Decay_Curve_Template_Name__c,Discount,Initial_Quantity__c,
                         unitprice, quantity, Opportunity.Pricebook2Id, Opportunity.CurrencyISOCode, Opportunity.Name,product2.ProductCode,Price_Tier__c,product2.Street_Date__c,Target_Quantity__c,Product2.SAP_Dist_chain_product_Status__c,Product2.Distribution_Chain_Valid_From_Date__c, // US: 750
                         Replen_Quantity__c,POS_Quantity__c,Actual_Quantity__c,Product2Id, Product2.External_Id__c,Product2.Name,OpportunityId,ProductCode,Product2.Type__c, /*Coop_Requested_Amount_NR__c,*/ Comments__c, P_L_Quantity__c,toLabel(Format__c),//Defect4200: added foramt field
                         Actual_Revenue__c,POS_Revenue__c,Total_Quantity__c,//US#598
                         // Japan
                         //ER-003026 start Add the Min Contribution % (Sales) & (Finance) Flags on Upload/Extract page
                         Contribution_is_under_Minimum_Finance__c,Contribution_is_under_Minimum_Sales__c,
                         //US#1011
                         Opportunity.Account.Digital_Country_Code__c, Opportunity.Sales_Organisation__c, Opportunity.Market_Type__c,Product2.Product_Type__c,Co_op_Requested_Amount__c,
                         NR__c, Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c, Override_Pricing__c, Description //Added by Harshad for US1028
                         FROM OpportunityLineItem
                         WHERE OpportunityId = :oppId AND (Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL OR Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL)
                         ORDER BY Product2.Name,Product2.ProductCode]
                 ) {
                            OpportunityLineItemWrapper lineItemWrapper = new OpportunityLineItemWrapper();
                            lineItemWrapper.existingId = lineItem.id;
                            lineItemWrapper.lineItemRecord = lineItem;
                            lineItemWrapper.strReason = lineItem.Reason__c;
                            lineItemWrapper.nCoopRequestedAmount = lineItem.Co_op_Requested_Amount__c;
                            lineItemWrapper.strComments = lineItem.Comments__c;
                            lineItemWrapper.overridePricing = lineItem.Override_Pricing__c;
                            lineItemWrapper.recrodStatus = ''; //US : 994
                            //ER-003026 start
                            lineItemWrapper.isContUnderMinFinance = lineItem.Contribution_is_under_Minimum_Finance__c ?CRM_AppConstants.CHECKBOX_YES:CRM_AppConstants.CHECKBOX_NO;
                            lineItemWrapper.isContUnderMinSales = lineItem.Contribution_is_under_Minimum_Sales__c ?CRM_AppConstants.CHECKBOX_YES:CRM_AppConstants.CHECKBOX_NO;
                            //ER-003026 end
                            updateValidationMessgae(lineItemWrapper,'');
                            
                        //CountryCode(of Deal)_Language_VideoVersion_Channel_Format
                        //GBR_en_6000098798_EST_3DHD
                        //(USD, en, 6000098798, EST, 3DHD)
                    if(lineItem.opportunity.RecordTypeId!=null && lineItem.opportunity != null && lineItem.opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                        if( lineItem.Product2.External_Id__c!=null && lineItem.Product2.External_Id__c.contains('_')) {
                                    string[] split= lineItem.Product2.External_Id__c.split('_');           
                                    system.debug('***********'+split);
                                    lineItemWrapper.digital.language = split.size()>1?split[1]:'';
                                    lineItemWrapper.digital.videoVersion = split.size()>2?split[2]:'';
                                    lineItemWrapper.digital.channel = split.size()>3?split[3]:'';
                                    lineItemWrapper.digital.format = split.size()>4?split[4]:'';
                            }
                            lineItemWrapper.digital.retailerProductId = lineItem.Pricebook_Entry_Period__c!=null ? lineItem.Pricebook_Entry_Period__r.Retailer_Product_ID__c:'';    //#767
                            lineItemWrapper.digital.vendorId = lineItem.Pricebook_Entry_Period__c!=null ? lineItem.Pricebook_Entry_Period__r.Vendor_ID__c:'';                            
                            lineItemWrapper.digital.posQuantity = Integer.valueOf(lineItem.POS_Quantity__c);     //ER-004333
                    }
                        //US#598 starts
                        if((lineItem.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (lineItem.Opportunity.NR_Deal_Unique_Key__c!=null || lineItem.Opportunity.NR_Deal_Unique_Key__c!='')) &&
                            ((lineItem.Actual_Revenue__c == 0 || lineItem.Actual_Revenue__c == NULL) &&
                             (lineItem.POS_Revenue__c == 0 || lineItem.POS_Revenue__c == NULL) && 
                             (lineItem.Target_Quantity__c == 0 || lineItem.Target_Quantity__c == NULL) &&
                             (lineItem.Total_Quantity__c == 0 || lineItem.Total_Quantity__c == NULL))){
                               lineItemWrapper.isUnTargetedDealProd = true; 
                        }
                        //US#598 end
                            
                            returnWrapperList.add(lineItemWrapper);
                }
                //returnWrapperList.sort();
        }
        catch(Exception e) {
                logException(oppId,e);
                throw new CRM_ProductPricingHandler.CRM_Exception(e.getMessage());
        }
        return returnWrapperList;
    }

    public static void logException(Id oppId,Exception e){
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.recordId = oppId;
                    // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
                    errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
                    errorLog.lineNumber = String.valueOf(e.getLineNumber());
                    errorLog.errorMessage = e.getMessage();
                    errorLog.stackTrace = e.getStackTraceString();
                    
                    // Call the logError method which will insert all errors into CRM_Error_Log__c object
                    CRM_ErrorLogger.logError(errorLog);
    }
    
     /**
        *  Description-Method fetches the Price Book Entry Period's for the respective Products where the ,Vendor Id,Retailer Id ,Currency and PriceBook matches with that of Digital Deal
        *  @name-fetchProductsFromPBEP
        * SINC2287784 Resolved issue for 50001 start
        */
        public static Set<Id> fetchProductsFromPBEP(Id pbId,Date dealStartDate,Date dealEndDate,String currencyISOCode, Set<String> setOfVendorIds , Set<String> setOfRetailerProductIds ,Set<String> combination1Set,Set<String> combination2Set) {
            //Boolean vendorflag=false;
            Set<Id> setProductIds = new Set<Id>();
            
             String soqlString = 'SELECT Product__c FROM Pricebook_Entry_Period__c'+
                                 ' WHERE Price_book__c =: pbId'+
                                 ' AND currencyISOCode =:currencyISOCode';
             if ((combination1Set.size()>0 || combination2Set.size()>0)){
                soqlString+=' AND (Vendor_ID__c IN:setOfVendorIds OR Retailer_Product_ID__c IN: setOfRetailerProductIds OR Product__r.External_Id__c IN: combination1Set) AND ( Product__r.Product_Format__c IN: combination2Set OR Product__r.Local_Title__r.Language_Code__c IN: combination2Set OR Product__r.Product_Market__c IN: combination2Set)';
            }
            soqlString+=' limit 50000';
            system.debug('====soqlString================'+soqlString);
            list<Pricebook_Entry_Period__c> pbepEntries = database.query(soqlString);
            
            //US#895 -commented code as a part of us to remove reference of suggested price (Suggested_Price__c, )
            for(Pricebook_Entry_Period__c pbep : pbepEntries) { 
                setProductIds.add(pbep.Product__c);
            }
            return setProductIds;
        }
    
    /**
     *  Method to fetch priceBookEntries for Physical/Digital deals corresponding to a combination  
     *  @name getPricebookEntriesPhysical
     *  @param Pricebook, currencyISOCode, combination list and type of Deal
     *  @return map<String,PricebookEntry>
     *  @throws None
     */
    global static map<String,PricebookEntry> getPricebookEntries(Set<Id> setOfProdIds, Id pbId,String currencyISOCode, Set<String> combination1Set,Set<String> combination2Set,Boolean isDealDigital) {
        system.debug('In method getPricebookEntries @@@');
            map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
            String soqlString = 'Select id, UnitPrice,PriceBook2.name,product2Id,product2.Universal_Picture_Code__c,Pricebook2Id,currencyISOCode,product2.Street_Date__c,'+ //product2.Product_Market__c,'+
                                ' product2.Type__c,product2.name,product2.External_Id__c,product2.productCode, product2.Product_Type__c, IsActive,product2.recordtypeId, product2.Product_Format__c, product2.IsActive, product2.SAP_Dist_chain_product_Status__c,product2.Distribution_Chain_Valid_From_Date__c'+
                                ' From PricebookEntry'+
                                ' where Pricebook2Id =: pbId'+
                                ' AND Pricebook2Id != null AND product2Id != null' +
                                ' AND currencyISOCode =:currencyISOCode'+
                                ' AND isActive = true';
            if ((combination1Set.size()>0 || combination2Set.size()>0)){
                if(isDealDigital) {
                         soqlString+=' AND Product2Id IN: setOfProdIds AND (product2.External_Id__c IN: combination1Set  OR product2.Product_Format__c IN: combination2Set OR product2.Local_Title__r.Language_Code__c IN: combination2Set OR product2.Product_Market__c IN: combination2Set)';
                } 
                else {
                    soqlString+=' AND (product2.productCode IN: combination1Set OR product2.Universal_Picture_Code__c IN: combination2Set)';
                }
            }
            soqlString+=' limit 50000';
            system.debug('====pbId=='+pbId);
            system.debug('====soqlString================'+soqlString);
            list<PricebookEntry> pbEntries = database.query(soqlString);
            
            system.debug('Query 1 on PricebookEntry @@@ => count = ' + pbEntries.size());

            for(PricebookEntry pbEntry : pbEntries) {
                if(isDealDigital) {
                    if(pbEntry.product2.External_Id__c!=null)pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.product2.External_Id__c.toLowercase(),pbEntry);
                    if(pbEntry.product2.Product_Format__c!=null)pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.product2.Product_Format__c.toLowercase(),pbEntry);
                    pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+string.valueOf(pbEntry.product2Id).toLowercase()+'_'+pbEntry.currencyISOCode,pbEntry);
                }
                else {
                    if(pbEntry.product2.productCode != null && pbEntry.product2.productCode != '') {
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_'+pbEntry.product2.productCode.toLowercase()+'_',pbEntry);
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_'+pbEntry.product2.productCode.toLowercase()+'_null',pbEntry);
                    }
                    if(pbEntry.product2.Universal_Picture_Code__c != null && pbEntry.product2.Universal_Picture_Code__c != '') {
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'__'+pbEntry.product2.Universal_Picture_Code__c.toLowercase(),pbEntry);
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_null_'+pbEntry.product2.Universal_Picture_Code__c.toLowercase(),pbEntry);
                    }
                    if(pbEntry.product2.productCode != null && pbEntry.product2.productCode != '' && pbEntry.product2.Universal_Picture_Code__c!=null && pbEntry.product2.Universal_Picture_Code__c !='') {
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_'+pbEntry.product2.productCode.toLowercase()+'_'+pbEntry.product2.Universal_Picture_Code__c.toLowercase(),pbEntry);
                    }
                }
            }
            return pricebookEntryMap;
    }
    
    
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
     */
     
    global static void updateDMLResult(list<Database.SaveResult> results, list<OpportunityLineItemWrapper> dmlList,String successResultString) {
            // set of Ids of inserted/updated records
            set<Id> recordIdSet = new set<Id>();
            system.debug('===============dmlList================'+dmlList);
            
            for(Integer i=0;i<results.size();i++){
                    OpportunityLineItemWrapper lineItemWrapper = dmlList.get(i);
                    //lineItemWrapper.lineItemRecord = dmlList.get(i);
                    lineItemWrapper.isRowModified =false;    
                       
                    if (results.get(i).isSuccess()){
                        lineItemWrapper.existingId = results.get(i).getId();
                        lineItemWrapper.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                        updateValidationMessgae(lineItemWrapper,successResultString);
                        
                        recordIdSet.add(lineItemWrapper.existingId);
                    }
                    else if (!results.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = results.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        lineItemWrapper.validation = failedDML;
                        lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        lineItemWrapper.isWarningRec = false; //US : 994
                        totalFailedRecords++;
                        lineItemWrapper.existingId = dmlList.get(i).lineItemRecord.Id;
                        
                        //Defect : 4433 
                        //Upload Extract page Issue for not persisting entered value when error occurs
                        /*if(lineItemWrapper.existingId!=null) {
                            recordIdSet.add(lineItemWrapper.existingId);
                        }*/
                    }
                    //returnWrapperList.add(lineItemWrapper);
            }
            
            // fetch all modified lineItems from database with populated formula fields
            map<Id,OpportunityLineItem> lineItems = 
            new map<Id,OpportunityLineItem>([SELECT Name, opportunity.RecordTypeId,opportunity.RecordType.Name,Opportunity.Digital_Country_Code__c,ListPrice,ListPrice__c,Account_Price__c,Permanent_Price_Tier__c,//US#663 - added account price and Permanent_Price_Tier__c
                                             PriceBookEntryId, Decay_Curve_Template__c, Decay_Curve_Template_Name__c,Discount,Initial_Quantity__c,Product2.Street_Date__c,
                                             unitprice, quantity, Opportunity.Product_Type__c ,Pricebook_Entry_Period__c,Pricebook_Entry_Period__r.Retailer_Product_ID__c,Pricebook_Entry_Period__r.Vendor_ID__c,Opportunity.Pricebook2Id, Opportunity.CurrencyISOCode, Opportunity.Name,
                                             product2.ProductCode,Replen_Quantity__c,POS_Quantity__c,Product2.External_Id__c,Actual_Quantity__c,Product2Id,Price_Tier__c, Product2.Name, Target_Quantity__c,Product2.SAP_Dist_chain_product_Status__c,Product2.Distribution_Chain_Valid_From_Date__c,  // US : 750
                                              OpportunityId,ProductCode,product2.Universal_Picture_Code__c,Product2.Type__c,Promoted_Price__c,Customer_Retail_Price__c, toLabel(Reason__c), Comments__c, /*Coop_Requested_Amount_NR__c,*/Co_op_Requested_Amount__c, P_L_Quantity__c,toLabel(Format__c),//Defect4200: added foramt field
                                              //ER-003026 start Add the Min Contribution % (Sales) & (Finance) Flags on Upload/Extract page
                                             Contribution_is_under_Minimum_Finance__c,Contribution_is_under_Minimum_Sales__c,
                                             // Japan
                                             Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c, Product2.Product_Type__c, Override_Pricing__c, Description //Added by Harshad for US1028
                                             FROM OpportunityLineItem
                                             WHERE Id IN: recordIdSet AND (Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL OR Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL)
                                             ORDER BY Product2.Name]);
            
            system.debug('LineItems key set --->'+lineItems.keyset());
                                                         
            for(OpportunityLineItemWrapper wrapper:dmlList) {
                if(lineItems.containsKey(wrapper.existingId)) {
                    wrapper.lineItemRecord = lineItems.get(wrapper.existingId);
                    wrapper.overridePricing = wrapper.lineItemRecord.Override_Pricing__c;
                    if(wrapper.lineItemRecord.opportunity.RecordTypeId != null && wrapper.lineItemRecord.opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
                    wrapper.digital.retailerProductId = wrapper.lineItemRecord.Pricebook_Entry_Period__c!=null?wrapper.lineItemRecord.Pricebook_Entry_Period__r.Retailer_Product_ID__c:'';
                    wrapper.digital.vendorId = wrapper.lineItemRecord.Pricebook_Entry_Period__c!=null?wrapper.lineItemRecord.Pricebook_Entry_Period__r.Vendor_ID__c:'';                     //#767
                        if(wrapper.lineItemRecord.Product2.External_Id__c!=null && wrapper.lineItemRecord.Product2.External_Id__c.contains('_')) {
                        string[] split= wrapper.lineItemRecord.Product2.External_Id__c.split('_');           
                        wrapper.digital.language = split.size()>1?split[1]:'';
                        wrapper.digital.videoVersion = split.size()>2?split[2]:'';
                        wrapper.digital.channel = split.size()>3?split[3]:'';
                        wrapper.digital.format = split.size()>4?split[4]:'';
                    }
                 }else{
                     //ER-003026 start Add the Min Contribution % (Sales) & (Finance) Flags on Upload/Extract page
                    wrapper.lineItemRecord = lineItems.get(wrapper.existingId);
                    wrapper.isContUnderMinFinance = wrapper.lineItemRecord.Contribution_is_under_Minimum_Finance__c ?CRM_AppConstants.CHECKBOX_YES:CRM_AppConstants.CHECKBOX_NO;
                    wrapper.isContUnderMinSales = wrapper.lineItemRecord.Contribution_is_under_Minimum_Sales__c ?CRM_AppConstants.CHECKBOX_YES:CRM_AppConstants.CHECKBOX_NO;
                  //ER-003026 end Add the Min Contribution % (Sales) & (Finance) Flags on Upload/Extract page
                
                }
            }
    }
    }
  
    // added as a part of US916
    global static Map<String,String> getReasonPicklistValues(){
        Map<String,String> setReasonsMap = new Map<String,String>();
        
        Schema.DescribeFieldResult fieldResult = Opportunity.Reason__c.getDescribe();
        List<Schema.PicklistEntry> pleReasons = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pleReason: pleReasons){
            setReasonsMap.put(pleReason.getLabel(), pleReason.getValue());
        }
        return setReasonsMap;
    }


     /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setOpportunityLineItems
     *  @param CRM_UploadDealProductsController.OpportunityLineItemWrapper[] and Opportunity Id
     *  @return sorted CRM_UploadDealProductsController.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<OpportunityLineItemWrapper> setOpportunityLineItems(List<OpportunityLineItemWrapper> lineItemWrapperList,Id oppId, boolean isDigitalDeal) {
        
        if(CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c) {
                    throw new CRM_ProductPricingHandler.CRM_Exception(Label.CRM_Deal_Entry_NoAccessError);
        }
        totalFailedRecords = 0;
        // set the index for each line item
        for(Integer i=0; i< lineItemWrapperList.size(); i++) {
            lineItemWrapperList[i].rowIndex = i;
        }
        
        // Commit the targets to Account_Product__c 
        List<OpportunityLineItemWrapper> listLiWrappersToInsert = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItem> listLineItemsToInsert = new List<OpportunityLineItem>(); // For making DML operation 
        List<OpportunityLineItemWrapper> listLiWrappersToUpdate = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItem> listLineItemsToUpdate = new List<OpportunityLineItem>(); // For making DML operation
        
        List<OpportunityLineItemWrapper> listLiWrappersToDelete = new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItemWrapper> unitPricefromPBEPList = new List<OpportunityLineItemWrapper>();
         
        Set<String> productCodeSet = new Set<String>();
        Set<String> productUPCSet = new Set<String>();
        Set<String> digitalCombinationSet = new Set<String>();
        Set<String> digitalCombinationFormatChannelLangSet = new Set<String>();
        set<id> productIds = new set<id>();
        
        map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
        CRM_ProductPricingHandler pricingHandler;
        CRM_SearchProductHandler productSearch;

        try{
                Opportunity opportunity = [select id,NR_Deal_Unique_Key__c,Digital_Country_Code__c, RecordType.DeveloperName, Account.Revenue_Share__c, Market_Type__c, RecordTypeId, Sales_Organisation__c,Account.Digital_Country_Code__c,Start_Date__c,CloseDate,Pricebook2Id,Product_Type__c ,AccountId,CurrencyISOCode from Opportunity where Id =: oppId];
                String territorys;
                if(opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
                    territorys = CRM_Hide_Coop_Fields__c.getInstance(opportunity.RecordType.DeveloperName) != null ? CRM_Hide_Coop_Fields__c.getInstance(opportunity.RecordType.DeveloperName).Upload_Extract_Territory__c : '';
                }else{
                    territorys = CRM_Hide_Coop_Fields__c.getInstance('Deal') != null ? CRM_Hide_Coop_Fields__c.getInstance('Deal').Upload_Extract_Territory__c : '';
                }
                Set<String> setOfTerritorys = new Set<String>(territorys.split(';'));
                Boolean showCoopFields = false;
                if(!setOfTerritorys.isEmpty()){
                    if(setOfTerritorys.contains(opportunity.Sales_Organisation__c) || setOfTerritorys.contains(opportunity.Account.Digital_Country_Code__c)) {
                        showCoopFields = true;
                    }
                }
                Boolean isJapanRentalDeal = (
                    (opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                    ||
                    (opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                ) && opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                Boolean isRevenueShareAccount = opportunity.Account.Revenue_Share__c;
                Map<String, Id> mapDecayCurveyTemplateNameToId = new Map<String, Id>();
                List<Decay_Curve_Template__c> decayCurveyTemplateList =
                    [
                        SELECT Id, Name FROM Decay_Curve_Template__c
                        WHERE Status__c =: CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE AND CurrencyIsoCode =: opportunity.CurrencyIsoCode
                    ];
                for (Decay_Curve_Template__c decayCurve : decayCurveyTemplateList) {
                    mapDecayCurveyTemplateNameToId.put(decayCurve.Name, decayCurve.Id);
                }

                // separate list of records to create/update
                OpportunityLineItem objLineItem = new OpportunityLineItem();

                Map<String, String> setReasonPicklistValues = getReasonPicklistValues();
                System.debug('--setReasonPicklistValues-->'+setReasonPicklistValues);
                
                //US:936:US Games
                Boolean isUSCANMEXTerritory = (opportunity.RecordTypeId !=null && opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && 
                                               CRM_AppConstants.US_SALES_ORGS.contains(opportunity.Sales_Organisation__c));
                 //SINC2287784 Resolved issue for 50001 start
                Set<Id> setOfProdIds =new Set<Id>();
                Set<String> setOfVendorIds = new Set<String>();
                Set<String> setOfRetailerProductIds = new Set<String>();
                //SINC2287784 Resolved issue for 50001 end
                for (OpportunityLineItemWrapper wrapper : lineItemWrapperList) {
                    if (!isJapanRentalDeal) {
                    //US#172 - added check to throw error when promo price is null only if price tier is not present
                        if (!isUSCANMEXTerritory && wrapper.lineItemRecord.Promoted_Price__c == null && wrapper.lineItemRecord.Price_Tier__c == null && wrapper.isRowRemoved != true) {                           
                            wrapper.validation = System.Label.CRM_Enter_Value_For_Promoted_Price;
                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                            totalFailedRecords++;
                            continue;
                        } /*else {
                            Decimal promoPrice = wrapper.lineItemRecord.Promoted_Price__c;
                            wrapper.lineItemRecord.Promoted_Price__c = promoPrice.setScale(2);
                        }*/
                        //US#172 - added check to throw error when promo price is null only if price tier is not present -end
                    } 
                        // if any change is made then only consider it for update/insert, else leave it as it is
                        if(wrapper.isRowRemoved!=null && wrapper.isRowRemoved == true){
                                system.debug('===============listDeleted=======wrapper========='+wrapper);
                                listLiWrappersToDelete.add(wrapper);
                        }
                        else if(wrapper.isRowModified == true) {
                            if(
                                    setReasonPicklistValues != null && 
                                    wrapper != null && wrapper.lineItemRecord != null && 
                                    (
                                        (
                                            wrapper.lineItemRecord.Reason__c != null && setReasonPicklistValues.containsKey(wrapper.lineItemRecord.Reason__c)
                                        ) || 
                                        (!showCoopFields && wrapper.lineItemRecord.Reason__c == null) || 
                                        (
                                            showCoopFields && 
                                            (
                                                wrapper.lineItemRecord.Co_op_Requested_Amount__c <= 0 ||
                                                wrapper.lineItemRecord.Co_op_Requested_Amount__c == null ||
                                                (wrapper.lineItemRecord.Co_op_Requested_Amount__c > 0 && wrapper.lineItemRecord.Reason__c != null)
                                            )
                                        )
                                    )
                            ) {
                                wrapper.lineItemRecord.Reason__c = setReasonPicklistValues.get(wrapper.lineItemRecord.Reason__c);

                                // Exiting record getting updated
                                if (wrapper.lineItemRecord.Id != null ) {

                                    if (isJapanRentalDeal) {
                                        if (!isRevenueShareAccount && (wrapper.lineItemRecord.Handling_Fee__c == null || wrapper.lineItemRecord.Handling_Fee__c == 0)) {
                                            wrapper.validation = System.Label.CRM_Enter_Value_For_Handling_Fee;
                                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                            totalFailedRecords++;
                                            continue;
                                        } else if(isRevenueShareAccount) {
                                            if (wrapper.lineItemRecord.Handling_Fee__c == null) {
                                                wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                totalFailedRecords++;
                                                continue;
                                            } else if (wrapper.overridePricing) {
                                                if (wrapper.lineItemRecord.Rental_Price__c == null || wrapper.lineItemRecord.Rental_Price__c == 0) {
                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                } else if (wrapper.lineItemRecord.Revenue_Share__c == null || wrapper.lineItemRecord.Revenue_Share__c == 0) {
                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                } else if (wrapper.lineItemRecord.Number_of_Rentals_per_Unit__c == null || wrapper.lineItemRecord.Number_of_Rentals_per_Unit__c == 0) {
                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                } else if (wrapper.lineItemRecord.Final_Purchase_Price__c == null || wrapper.lineItemRecord.Final_Purchase_Price__c == 0) {
                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                } else if (wrapper.lineItemRecord.Final_Purchase__c == null || wrapper.lineItemRecord.Final_Purchase__c == 0) {
                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                }  else if(wrapper.lineItemRecord.Decay_Curve_Template_Name__c == null || wrapper.lineItemRecord.Decay_Curve_Template_Name__c == '') {
                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Decay_Curve_Template_Japan;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                }
                                            }
                                        }

                                        if (
                                                wrapper.lineItemRecord.Decay_Curve_Template_Name__c == null || wrapper.lineItemRecord.Decay_Curve_Template_Name__c == ''
                                        ) {
                                            wrapper.lineItemRecord.Decay_Curve_Template__c = null;
                                        } else if (
                                                mapDecayCurveyTemplateNameToId.containsKey(wrapper.lineItemRecord.Decay_Curve_Template_Name__c) &&
                                                mapDecayCurveyTemplateNameToId.get(wrapper.lineItemRecord.Decay_Curve_Template_Name__c) != null
                                        ) {
                                            wrapper.lineItemRecord.Decay_Curve_Template__c = mapDecayCurveyTemplateNameToId.get(wrapper.lineItemRecord.Decay_Curve_Template_Name__c);
                                        }  else if (wrapper.overridePricing) {
                                            wrapper.validation = System.Label.CRM_Enter_Valid_Decay_Curve_Template_Name;
                                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                            totalFailedRecords++;
                                            continue;
                                        }
                                    }

                                    listLiWrappersToUpdate.add(wrapper);
                                    listLineItemsToUpdate.add(wrapper.lineItemRecord);

                                }
                                else {
                                    if(isDigitalDeal){
                                          //SINC2287784 Resolved issue for 50001 start
                                        if(wrapper.digital.retailerProductId != null ){
                                            setOfRetailerProductIds.add(wrapper.digital.retailerProductId == ''?'':wrapper.digital.retailerProductId);
                                        }
                                        if(wrapper.digital.vendorId != null){
                                            setOfVendorIds.add(wrapper.digital.vendorId == ''?'':wrapper.digital.vendorId);
                                        }
                                        //SINC2287784 Resolved issue for 50001 start
                                        
                                        if((wrapper.digital.videoVersion == null || wrapper.digital.videoVersion == '') &&
                                           (wrapper.digital.retailerProductId == null || wrapper.digital.retailerProductId == '') && 
                                           (wrapper.digital.vendorId == null || wrapper.digital.vendorId == '')
                                        ){
                                             wrapper.validation = system.label.CRM_Digital_deal_Validation_For_UploadExtract;
                                             wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                             totalFailedRecords++;
                                             continue;
                                        }
                                        if((wrapper.digital.format == null || wrapper.digital.format == '') ||
                                           (wrapper.digital.channel == null || wrapper.digital.channel == '') || 
                                           (wrapper.digital.language == null || wrapper.digital.language == '')
                                        ){
                                             wrapper.validation = system.label.CRM_Digital_deal_Format_Language_Channel_Validation;
                                             wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                             totalFailedRecords++;
                                             continue;
                                        }
                                    
                                        //CountryCode(of Deal)_Language_VideoVersion_Channel_Format
                                        if(wrapper.digital.videoVersion!=null && wrapper.digital.videoVersion!='') {
                                            digitalCombinationSet.add(opportunity.Digital_Country_Code__c+'_'+wrapper.digital.language+'_'+wrapper.digital.videoVersion+'_'+wrapper.digital.channel+'_'+wrapper.digital.format);
                                        }
                                      //  else{
                                            if (wrapper.digital.format!=null && wrapper.digital.format!='')
                                                digitalCombinationFormatChannelLangSet.add(wrapper.digital.format);
                                            if (wrapper.digital.channel!=null && wrapper.digital.channel!='')
                                                digitalCombinationFormatChannelLangSet.add(wrapper.digital.channel);
                                            if (wrapper.digital.language!=null && wrapper.digital.language!='')
                                                digitalCombinationFormatChannelLangSet.add(wrapper.digital.language);
                                      //  }
                                    } 
                                    else {
                                        if(wrapper.lineItemRecord.Product2.ProductCode!=null)
                                            productCodeSet.add(wrapper.lineItemRecord.Product2.ProductCode);
                                            
                                        if(wrapper.lineItemRecord.product2.Universal_Picture_Code__c!=null)
                                            productUPCSet.add(wrapper.lineItemRecord.product2.Universal_Picture_Code__c);
                                    }
                                    
                                    listLiWrappersToInsert.add(wrapper);
                                    listLineItemsToInsert.add(wrapper.lineItemRecord);
                                }
                            }
                            else {
                                String reasonPicklistValues = '';
                                List<String> picklistValues = new List<String>(setReasonPicklistValues.keySet());
                                for (Integer i = 0; i < picklistValues.size(); i++) {
                                    String reasonValues = picklistValues[i];
                                    reasonPicklistValues += '\'' + reasonValues + '\'';
                                    if (i < picklistValues.size()-1) {
                                        reasonPicklistValues += ' or ';
                                    }
                                }
                                wrapper.validation = String.format(System.Label.CRM_Upload_Message_Incorrect_Reason, new String[]{ reasonPicklistValues });
                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                totalFailedRecords++;
                            }
                        }
                        else { // no modification done to existing rows
                            
                            //US : 750
                            updateValidationMessgae(wrapper,'');
                            
                            //US : 994
                            wrapper.recrodStatus = ''; 
                        }
                }
                
                if(!listLineItemsToUpdate.isEmpty()) {
                    // update changed rows
                    list<Database.SaveResult> updateResults = Database.update(listLineItemsToUpdate,false);
                    system.debug('====listLiWrappersToUpdate===========lineItems================'+listLiWrappersToUpdate);
                    
                    updateDMLResult(updateResults,listLiWrappersToUpdate,Label.CRM_Upload_Message_Updated);
                }
                
                // for new records
                if(!listLiWrappersToInsert.isEmpty()) {
                        String combination;
                        
                        if(isDigitalDeal) {
                             //SINC2287784 Resolved issue for 50001 start
                             setOfProdIds = fetchProductsFromPBEP(opportunity.Pricebook2Id,opportunity.Start_Date__c,opportunity.CloseDate,opportunity.CurrencyISOCode, setOfVendorIds,setOfRetailerProductIds,digitalCombinationSet,digitalCombinationFormatChannelLangSet);             
                            //SINC2287784 Resolved issue for 50001 end
                            pricebookEntryMap = getPricebookEntries(setOfProdIds,opportunity.Pricebook2Id,opportunity.CurrencyISOCode,digitalCombinationSet,digitalCombinationFormatChannelLangSet,true);
                        }
                        else {
                             pricebookEntryMap = getPricebookEntries(setOfProdIds,opportunity.Pricebook2Id,opportunity.CurrencyISOCode,productCodeSet,productUPCSet,false);
                        }    
                        // prepare list of DealWrappers to get the pricebook entry period details
                        for(PricebookEntry pbEntry:pricebookEntryMap.values()) {
                                     productIds.add(pbEntry.product2Id);
                        }
                        if(productIds.size() > 0) {
                            productSearch = new CRM_SearchProductHandler(opportunity,productIds);
                            
                            pricingHandler = new CRM_ProductPricingHandler();
                            pricingHandler.setAccountIds = new Set<Id>{opportunity.AccountId};
                            pricingHandler.initializeAccountDetails();
                            pricingHandler.mapProductDetails = productSearch.mapProductDetails;
                            pricingHandler.mapDatedPricebookEntries = productSearch.mapDatedPricebookEntries;
                        }
                        
                        listLiWrappersToInsert.clear();
                        listLineItemsToInsert.clear();
                        
                        for (OpportunityLineItemWrapper wrapper : lineItemWrapperList) {
                                if(isDigitalDeal) {
                                    if(wrapper.digital.videoVersion!=null && wrapper.digital.videoVersion!='') {
                                        combination = opportunity.Digital_Country_Code__c+'_'+wrapper.digital.language+'_'+wrapper.digital.videoVersion+'_'+wrapper.digital.channel+'_'+wrapper.digital.format;
                                        combination = opportunity.Pricebook2Id+'_'+combination.tolowercase();
                                    }
                                    else if(wrapper.digital.format!=null && wrapper.digital.format!='') {
                                        combination = wrapper.digital.format+'_'+opportunity.currencyISOCode;
                                        combination = opportunity.Pricebook2Id+'_'+combination.tolowercase();
                                    }
                                }
                                else {
                                    combination = wrapper.lineItemRecord.product2.productCode+'_'+wrapper.lineItemRecord.product2.Universal_Picture_Code__c;
                                    combination = opportunity.Pricebook2Id+'_'+opportunity.currencyISOCode+'_'+combination.tolowercase();
                                }
                                // if row is new record
                                if(wrapper.isRowModified==true && wrapper.lineItemRecord.Id == null) {
                                            wrapper.lineItemRecord.opportunity = null;
                                            wrapper.validation = '';
                                            DealWrapper productSearchDealWrp = new DealWrapper();
                                            productSearchDealWrp.dealId = oppId;
                                            productSearchDealWrp.accountId = opportunity.AccountId;
                                            productSearchDealWrp.dealCurrency = opportunity.currencyISOCode;
                                            productSearchDealWrp.pricebookId = opportunity.pricebook2Id;
                                            productSearchDealWrp.dealStartDate = opportunity.Start_Date__c;
                                            productSearchDealWrp.dealEndDate  = opportunity.CloseDate;
                                            if (isDigitalDeal) {
                                                productSearchDealWrp.productFormat  = wrapper.digital.format;
                                                productSearchDealWrp.retailerProductId  = wrapper.digital.retailerProductId;
                                                productSearchDealWrp.vendorId  = wrapper.digital.vendorId;
                                                productSearchDealWrp.channel = wrapper.digital.channel;
                                                productSearchDealWrp.language = wrapper.digital.language;
                                            }
                                            Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();
                                            //if(isDigitalDeal && wrapper.digital.retailerProductId!=null && wrapper.digital.retailerProductId!='') 
                                            //#767 modified condition to search products by entering Vendorid or retailerProductId
                                            if(isDigitalDeal && (
                                               (wrapper.digital.retailerProductId != null && wrapper.digital.retailerProductId != '') ||
                                               (wrapper.digital.vendorId != null && wrapper.digital.vendorId != '')) 
                                            ){
                                                
                                                if(productSearch == null){
                                                    wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                }
                                                pbep = productSearch.getProductRetailerPricebookEntryPeriod(productSearchDealWrp);
                                                //if no pbep exists then throw error
                                                //if product PBEP Start Date does not lie in deal dates, then throw error
                                                if(pbep==null) {
                                                   wrapper.validation = Label.CRM_Upload_Message_PBEP;
                                                   wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    totalFailedRecords++;
                                                    continue;
                                                }
                                                combination = opportunity.Pricebook2Id+'_'+string.valueOf(pbep.Product__c).toLowerCase() + '_' + pbep.CurrencyISOCode;
                                            }
                                            // if pricebook exists for given combination
                                            if(pricebookEntryMap!=null && pricebookEntryMap.containsKey(combination)) {
                                                    wrapper.lineItemRecord.PriceBookEntryId = pricebookEntryMap.get(combination).id;
                                                    wrapper.lineItemRecord.Product2 = pricebookEntryMap.get(combination).Product2;
                                                    wrapper.lineItemRecord.Product2.SAP_Dist_chain_product_Status__c = pricebookEntryMap.get(combination).Product2.SAP_Dist_chain_product_Status__c;
                                                    wrapper.lineItemRecord.Product2.Distribution_Chain_Valid_From_Date__c = pricebookEntryMap.get(combination).Product2.Distribution_Chain_Valid_From_Date__c;
                                                    CRM_ProductPricingHandler.DealWrapper pricingHandlerDealWrp = new CRM_ProductPricingHandler.DealWrapper();
                                                    pricingHandlerDealWrp.dealId = oppId;
                                                    pricingHandlerDealWrp.accountId = opportunity.AccountId;
                                                    pricingHandlerDealWrp.dealCurrency = opportunity.currencyISOCode;
                                                    pricingHandlerDealWrp.pricebookId = opportunity.pricebook2Id;
                                                    pricingHandlerDealWrp.dealStartDate = opportunity.Start_Date__c;
                                                    pricingHandlerDealWrp.dealEndDate  = opportunity.CloseDate;
                                                    pricingHandlerDealWrp.productId = pricebookEntryMap.get(combination).Product2Id;
                                                    
                                                    // Requirement: #3239
                                                    if (pricebookEntryMap != null && pricebookEntryMap.containsKey(combination) && pricebookEntryMap.get(combination) != null && pricebookEntryMap.get(combination).product2 != null && pricebookEntryMap.get(combination).product2.IsActive == false){
                                                        wrapper.validation = Label.CRM_Upload_Message_Product_Not_Active;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                        totalFailedRecords++;
                                                        continue;
                                                    }
                                                    
                                                    //US#788 start Ability to have UNBW Products in Opportunity Ankita
                                                    String productType = pricebookEntryMap.get(combination).Product2.Type__c;
                                                    if(opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL 
                                                        && productType ==  CRM_AppConstants.UNBW_PRODUCT_TYPE){
                                                       wrapper.validation = Label.CRM_UNBW_Products_Error; 
                                                       wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                       totalFailedRecords++;
                                                       continue;
                                                    }   
                                                    //End 
                                                    
                                                    //if product is not of same type as of deal then throw error 
                                                    String recTypeId = pricebookEntryMap.get(combination).product2.recordtypeId;
                                                    
                                                    if((isDigitalDeal && recTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL)||(!isDigitalDeal && recTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL)){
                                                    }
                                                    else {
                                                        wrapper.validation = Label.CRM_Upload_Message_Type_Mismatch;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                        totalFailedRecords++;
                                                        continue;
                                                    }
                                                    
                                                    if(pricingHandler == null){
                                                    system.debug('Error#3');
                                                        wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                        totalFailedRecords++;
                                                        continue;
                                                    }
                                                    pbep = pricingHandler.getProductDatedPricebookEntryPeriod(pricingHandlerDealWrp);

                                                    //if no pbep exists then throw error
                                                    //if product PBEP Start Date does not lie in deal dates, then throw error
                                                    if(pbep==null) {
                                                        wrapper.validation = Label.CRM_Upload_Message_PBEP;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                        totalFailedRecords++;
                                                        continue;
                                                    }
                                                    
                                                    //JAPAN US : 480
                                                    /*if(opportunity.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                                                       opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL &&
                                                       opportunity.Market_Type__c != pricebookEntryMap.get(combination).Product2.Product_Market__c){
                                                            
                                                            wrapper.validation = Label.CRM_Upload_Message_Not_Valid_Product_Market;
                                                            totalFailedRecords++;
                                                            continue;
                                                    }*/

                                                    if (isJapanRentalDeal) {

                                                        if (opportunity.NR_Deal_Unique_Key__c == null) {
                                                            wrapper.lineItemRecord.Override_Pricing__c = true;
                                                            if (!isRevenueShareAccount && (wrapper.lineItemRecord.Handling_Fee__c == null || wrapper.lineItemRecord.Handling_Fee__c ==  0)) {
                                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Handling_Fee;
                                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                    totalFailedRecords++;
                                                                    continue;
                                                            } else if(isRevenueShareAccount) {
                                                                if (wrapper.lineItemRecord.Handling_Fee__c == null) {
                                                                    wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                    totalFailedRecords++;
                                                                    continue;
                                                                } else if (wrapper.lineItemRecord.Override_Pricing__c) {
                                                                    if (wrapper.lineItemRecord.Rental_Price__c == null || wrapper.lineItemRecord.Rental_Price__c == 0) {
                                                                        wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                        totalFailedRecords++;
                                                                        continue;
                                                                    } else if (wrapper.lineItemRecord.Revenue_Share__c == null || wrapper.lineItemRecord.Revenue_Share__c == 0) {
                                                                        wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                        totalFailedRecords++;
                                                                        continue;
                                                                    } else if (wrapper.lineItemRecord.Number_of_Rentals_per_Unit__c == null || wrapper.lineItemRecord.Number_of_Rentals_per_Unit__c == 0) {
                                                                        wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                        totalFailedRecords++;
                                                                        continue;
                                                                    } else if (wrapper.lineItemRecord.Final_Purchase_Price__c == null || wrapper.lineItemRecord.Final_Purchase_Price__c == 0) {
                                                                        wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                        totalFailedRecords++;
                                                                        continue;
                                                                    } else if (wrapper.lineItemRecord.Final_Purchase__c == null || wrapper.lineItemRecord.Final_Purchase__c == 0) {
                                                                        wrapper.validation = System.Label.CRM_Enter_Value_For_Rental_Fields;
                                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                        totalFailedRecords++;
                                                                        continue;
                                                                    }  else if(wrapper.lineItemRecord.Decay_Curve_Template_Name__c == null || wrapper.lineItemRecord.Decay_Curve_Template_Name__c == '') {
                                                                        wrapper.validation = System.Label.CRM_Enter_Value_For_Decay_Curve_Template_Japan;
                                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                        totalFailedRecords++;
                                                                        continue;
                                                                    } else if (
                                                                            wrapper.lineItemRecord.Decay_Curve_Template_Name__c != null && wrapper.lineItemRecord.Decay_Curve_Template_Name__c != '' &&
                                                                            mapDecayCurveyTemplateNameToId.containsKey(wrapper.lineItemRecord.Decay_Curve_Template_Name__c) &&
                                                                            mapDecayCurveyTemplateNameToId.get(wrapper.lineItemRecord.Decay_Curve_Template_Name__c) != null
                                                                    ) {
                                                                            wrapper.lineItemRecord.Decay_Curve_Template__c = mapDecayCurveyTemplateNameToId.get(wrapper.lineItemRecord.Decay_Curve_Template_Name__c);
                                                                    } else if (isRevenueShareAccount && wrapper.lineItemRecord.Override_Pricing__c) {
                                                                            wrapper.validation = System.Label.CRM_Enter_Valid_Decay_Curve_Template_Name;
                                                                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                            totalFailedRecords++;
                                                                            continue;
                                                                    }
                                                                }
                                                            }
                                                        }/* else {
                                                            wrapper.lineItemRecord.Override_Pricing__c = false;
                                                        }*/
                                                    }

                                                    wrapper.lineItemRecord.Pricebook_Entry_Period__c=pbep.id;
                                                    wrapper.lineItemRecord.Quantity = 1; // defaults quantity to 1 
                                                    wrapper.lineItemRecord.opportunityid = oppId;

                                                    if(wrapper.lineItemRecord.unitprice==null) { // if user has not provided unit price then get it from pricebook entry period
                                                               wrapper.lineItemRecord.unitprice = pricingHandler.getAccountPrice(pricingHandlerDealWrp,pbep);
                                                               /* Remove as a part of DE#4768
                                                               if(wrapper.lineItemRecord.unitprice == 0 && !isDigitalDeal) {
                                                                    wrapper.validation =Label.CRM_Upload_Message_Not_Valid_Price;
                                                                    totalFailedRecords++;
                                                               }
                                                               else {
                                                               */
                                                                    listLiWrappersToInsert.add(wrapper);
                                                                    //listLineItemsToInsert.add(wrapper.lineItemRecord);
                                                                    OpportunityLineItem dp = wrapper.lineItemRecord.clone(false,true,true,true);
                                                                    dp.product2 = null;
                                                                    listLineItemsToInsert.add(dp); // Should be enabled for Api version 41
                                                               //}
                                                     }
                                                    /* 
                                                    Remove as a part of DE#4768
                                                    else if(wrapper.lineItemRecord.unitprice == 0 && !isDigitalDeal){//US#788 start
                                                        wrapper.validation =Label.CRM_Upload_Message_Not_Valid_Price;
                                                        totalFailedRecords++;//US#788 end
                                                    }
                                                    */
                                                    else {
                                                        listLiWrappersToInsert.add(wrapper);
                                                        //listLineItemsToInsert.add(wrapper.lineItemRecord);
                                                        OpportunityLineItem dp = wrapper.lineItemRecord.clone(false,true,true,true);
                                                        dp.product2 = null;
                                                        listLineItemsToInsert.add(dp); // Should be enabled for Api version 41
                                                    }
                                            }
                                            else { // pricebook or product not found
                                             system.debug('Error#4');
                                                wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                totalFailedRecords++;
                                            }
                                }
                        }
                        
                        if(!listLineItemsToInsert.isEmpty()) {
                            // Insert the list of new deal product 
                            list<Database.SaveResult> insertResults = Database.insert(listLineItemsToInsert,false);
                            updateDMLResult(insertResults,listLiWrappersToInsert,Label.CRM_Upload_Message_Created);
                        }
                }
                
                if(!listLiWrappersToDelete.isEmpty()) {
                   Integer[] lstRowIndexToRemove = deleteOpportunityLineItems(listLiWrappersToDelete);
                   
                   for(Integer i= lstRowIndexToRemove.size()-1; i >=0; i--) {
                       Integer indexToRemove = lstRowIndexToRemove[i];
                       system.debug('Row Index to be removed -->'+indexToRemove);
                       system.debug('Row Index Item to be removed -->'+lineItemWrapperList[indexToRemove]);
                       lineItemWrapperList.remove(indexToRemove);
                   }
                }
        }
        catch(Exception e) {
            logException(oppId,e);
            throw e;
        }
        
        if(!lineItemWrapperList.isEmpty()) {
            lineItemWrapperList[0].numFailedRecords = totalFailedRecords;
        }
        system.debug('totalFailedRecords---------->'+totalFailedRecords);
        return lineItemWrapperList;
    }
    
    /**
     *  Method to fetch user input and perform delete operation on existing records
     *  @name deleteOpportunityLineItems
     *  @param CRM_UploadDealProductsController.OpportunityLineItemWrapper[] and Opportunity Id
     *  @return Integer[] list of row indexes to be removed from original list
     *  @throws None
     */
     
    //@RemoteAction
    global static Integer[] deleteOpportunityLineItems(List<OpportunityLineItemWrapper> lstLiWrappersToDelete) {
        
        List<OpportunityLineItem> listLineItemsToRemove = new List<OpportunityLineItem>();
        List<OpportunityLineItemWrapper> listLiWrappersToRemove = new List<OpportunityLineItemWrapper>();
        
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        
        Id OppId;
        if(lstLiWrappersToDelete!=null) {
            for (OpportunityLineItemWrapper wrapper : lstLiWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    OppId = wrapper.lineItemRecord.opportunityid;
                    wrapper.isRowRemoved =false;
                    wrapper.isRowModified =false;
                    
                    listLiWrappersToRemove.add(wrapper);                    
                    listLineItemsToRemove.add(wrapper.lineItemRecord);
                }
                else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }        
            }
        }
        try {
            list<Database.DeleteResult> deleteLiResults = Database.delete(listLineItemsToRemove,false);
            
            for(Integer i=0; i < deleteLiResults.size(); i++){
                OpportunityLineItemWrapper lineItemWrapper = listLiWrappersToRemove.get(i);
                lineItemWrapper.isRowModified =false;
                lineItemWrapper.isRowRemoved =false;
                
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    system.debug('Failed ID remove -'+listLiWrappersToRemove.get(i));
                    
                    lineItemWrapper.existingId = listLineItemsToRemove.get(i).Id;
                    lineItemWrapper.validation = failedDML;
                    lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                    totalFailedRecords++;
                }
                else {
                    lstRowIndexToRemove.add(lineItemWrapper.rowIndex);
                }
            }
        }
        catch(Exception e) {
            logException(OppId,e);
            
            for(Integer i=0; i < listLiWrappersToRemove.size(); i++){
                OpportunityLineItemWrapper lineItemWrapper = listLiWrappersToRemove[i];
                lineItemWrapper.isRowModified =false;
                lineItemWrapper.existingId = lineItemWrapper.lineItemRecord.Id;
                lineItemWrapper.validation = e.getMessage();
                lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                totalFailedRecords++;
            }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove;
    }
    
    
    public class CRM_SearchProductHandler {
        public Map<String,Pricebook_Entry_Period__c[]> mapRetailerPricebookEntries;  //rmn
        public Map<String,Pricebook_Entry_Period__c[]> mapDatedPricebookEntries;  
        public Map<Id,Product2> mapProductDetails;
        private Set<String> setCurrencyCodes = new Set<String>();
        private Set<Id> productIds = new Set<Id>();
        private Set<Id> setPricebookIds = new Set<Id>();
        public Set<Id> setAccountIds = new Set<Id>();
        public Date dealStartDate ; //  SINC2287784 Resolved issue for 50001 start
        public Date dealEndDate ;  //SINC2287784 Resolved issue for 50001 start
    
        /**
        *  Description-Constructor uses the DealWrapper to prepare Sets of information like ProductId's,PriceBooks,CurrencyCodes etc
        *  @name-CRM_ProductPricingHandler
        *  @param-DealWrappers - The wrapper is created in DealProductHandler class
        */
        public CRM_SearchProductHandler(Opportunity opp,Set<Id> productIds) {
            if(opp.CloseDate == null) {
                    throw new CRM_ProductPricingHandler.CRM_Exception(Label.CRM_Upload_Message_Incorrect_Deal_Order_End_Date);
                }
            setPricebookIds.add(opp.pricebook2Id);
            setCurrencyCodes.add(opp.currencyISOCode);
            setAccountIds.add(opp.AccountId);
            dealStartDate = opp.Start_Date__c;  //SINC2287784 Resolved issue for 50001 start
            dealEndDate = opp.CloseDate;  //SINC2287784 Resolved issue for 50001 start
            this.productIds =  productIds;
            //Defect # 4435 
            Boolean isDigitalDeal = (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL);
            initializePricebookEntryPeriodRetailerData(isDigitalDeal);// added by Raman
        }
        public CRM_SearchProductHandler() {}
    
        
        //US#174 - Rmn
        /**
        *  Description-Method fetches the Price Book Entry Period's for the respective Products where the Currency and PriceBook matches with that of Deal
        *  @name-initializePricebookEntryPeriodData
        */
        private void initializePricebookEntryPeriodRetailerData(Boolean isDigitalDeal) {
            //Boolean vendorflag=false;
            mapRetailerPricebookEntries = new Map<String,Pricebook_Entry_Period__c[]>();
            mapDatedPricebookEntries = new Map<String,Pricebook_Entry_Period__c[]>();
            mapProductDetails = new Map<Id,Product2>();
            //US#895 -commented code as a part of us to remove reference of suggested price (Suggested_Price__c, )
            for(Pricebook_Entry_Period__c pbep : [select Id, Price_Book__c, Product__c, Product__r.Product_Format__c, Product__r.Product_Type__c, CurrencyISOCode, Start_Date__c, End_Date__c, List_Price__c, Client_Avail__r.Local_Data_Category_Picklist__c,Product__r.Product_Price_Group__c,
                                                    Minimum_Price__c,Account_Price__c,Retail_Price__c,Retailer_Product_ID__c,Vendor_ID__c,Product__r.Local_Title__r.Language_Code__c,Product__r.Product_Market__c,Material_Price_Group__c 
                                          FROM Pricebook_Entry_Period__c
                                          WHERE Price_Book__c != null AND Product__c != null AND Price_Book__c IN: setPricebookIds
                                          AND CurrencyISOCode IN: setCurrencyCodes AND Product__c IN :productIds
                                          AND Start_Date__c <=: dealEndDate AND End_Date__c >=: dealStartDate   
                                                    order by Price_Book__c, Product__c, CurrencyISOCode, Start_Date__c]) {
                                
                mapProductDetails.put(pbep.Product__c, pbep.Product__r);
                
                //Unique Key with combination of Product,PriceBook and CurrencyISO Code is  created to get limited matching records
              String mapDatedKey = pbep.Product__c + '-'+ pbep.Price_Book__c + '-' + pbep.CurrencyISOCode;
                fillMap(mapDatedPricebookEntries, mapDatedKey, pbep);
                
                //Defect : 4435 : Below Code should be executed for the Digital deals only
                if(isDigitalDeal){
                    String productFormat = pbep.Product__r.Product_Format__c != null ? pbep.Product__r.Product_Format__c.toLowercase() : null;
                    String language = pbep.Product__r.Local_Title__r.Language_Code__c != null ?  pbep.Product__r.Local_Title__r.Language_Code__c.toLowercase() : null;
                    system.debug('product : '+pbep.Product__r);
                    system.debug('local title : '+pbep.Product__r.Local_Title__r);
                    system.debug('language code : '+pbep.Product__r.Local_Title__r.Language_Code__c);
                    system.debug('pbep : '+pbep);
                    system.debug('language : '+language);
                    String channel = pbep.Product__r.Product_Market__c != null ? pbep.Product__r.Product_Market__c.toLowercase() : null;
                    
                  //Unique Key with combination of Retailer Product ID, Format and CurrencyISO Code is  created to get limited matching records
                    String mapRecKey;
                    if(pbep.Retailer_Product_ID__c!=null || pbep.Retailer_Product_ID__c!=''){
                      mapRecKey = pbep.Retailer_Product_ID__c+'-'+productFormat+'-'+pbep.CurrencyISOCode.toLowercase()+'-'+language+'-'+channel;
                    fillMap(mapRetailerPricebookEntries, mapRecKey, pbep);
                    }
        
              /* Req767
              *  Description-For US And Canada :Method fetches the Price Book Entry Period's for the respective Products where the Currency and PriceBook matches with that of Deal
              */
                 if(pbep.Vendor_ID__c!=null || pbep.Vendor_ID__c!=''){
                      //Unique Key with combination of Retailer Product ID, Format and CurrencyISO Code is  created to get limited matching records
                      mapRecKey = pbep.Vendor_ID__c+'-'+productFormat+'-'+pbep.CurrencyISOCode.toLowercase()+'-'+language+'-'+channel;
               fillMap(mapRetailerPricebookEntries, mapRecKey, pbep);
                  }
              }
          }
        }
            
             
        public void fillMap(Map<String,Pricebook_Entry_Period__c[]> mapPBEPs, String key, Pricebook_Entry_Period__c value) {
          if(!mapPBEPs.containsKey(key)){
                mapPBEPs.put(key, new Pricebook_Entry_Period__c[]{value});
          }     
            else{ 
                mapPBEPs.get(key).add(value);
            }
        }
        
        /**
        *  Description-Method fetches the Price Book Entry Period's for the respective Products where the Currency and PriceBook matches with that of Deal
        *  @name-getProductDatedPricebookEntry
        *  @param-Deal Wrapper 
        *  @return-productPricebookEntryPeriod-After the required comparisons are made the applicable Pricebook Entry Period for a Product is returned
        */
        public Pricebook_Entry_Period__c getProductRetailerPricebookEntryPeriod(DealWrapper dw) {
            
            String mapRecKey = dw.retailerProductId+'-'+dw.productFormat.toLowercase()+'-'+dw.dealCurrency.toLowercase()+'-'+dw.language.toLowercase()+'-'+dw.channel.toLowercase();
            
            //767
            if(dw.vendorId != null && dw.vendorId != ''){
                mapRecKey = dw.vendorId+'-'+dw.productFormat.toLowercase()+'-'+dw.dealCurrency.toLowercase()+'-'+dw.language.toLowercase()+'-'+dw.channel.toLowercase();
            }
            Pricebook_Entry_Period__c productPricebookEntryPeriod;
            if(mapRetailerPricebookEntries.containsKey(mapRecKey)) {
                for(Pricebook_Entry_Period__c pbep : mapRetailerPricebookEntries.get(mapRecKey)){
                    //Comparing dates of Price Book Entry Period with that of Deal Start Date
                    // PBEP Date should overlap with the Deal Dates (if multiple overlaps then pick the first PBEP record)
                    if(pbep.Start_Date__c <= dw.dealEndDate && pbep.End_Date__c >= dw.dealStartDate ) {
                        productPricebookEntryPeriod = new Pricebook_Entry_Period__c();
                        productPricebookEntryPeriod = pbep;
                        break;
                    }
                } 
            }
            return productPricebookEntryPeriod;
        }
        //US#174 - Rmn
    }
    
     /**
     *  Method to export CSV file
     *  @name exportCSVFile
     *  @param List<String> excelHeaderNames
     *  @return PageReference - Redirect URL
     *  @throws None
     */
     
    @RemoteAction
    global static PageReference exportCSVFile(List<String> excelHeaderNames) {
        String urlLocatorPage = '/apex/CRM_ExportCSVFileFromUploadExtract';
        PageReference pageref = new PageReference(urlLocatorPage);
        pageref.getParameters().put('excelHeaderNames',String.join(excelHeaderNames,','));
        system.debug('excelHeaderNames : '+excelHeaderNames);
        return pageref;
    }
    
    /**
     *  US : 909 - Sprint 2 user story for US Games and athor territorys
     *  @Description -Method to feach products list for AddSearchProduct screen
     *  @name getProductsForAddSearchProductScreen
     *  @param Id oppId,Id pricebookId
     *  @return List<product2> - List of Products
     *  @throws None
     */
    @RemoteAction
    global static List<productSearchWrapper> getProductsForAddSearchProductScreen(Id dealId, String pricebookId, String quickSearchText) { 
        List<Opportunity> deals;
        List<CRM_DataObjects.ProductItem> items = new List<CRM_DataObjects.ProductItem>();
        List<productSearchWrapper> prodWrapList = new  List<productSearchWrapper>();
        Set<Id> existingProdIds = new Set<Id>();
        
        if(dealId != null){
            deals = [SELECT id, Start_Date__c, AccountId,Account.Digital_Country_Code__c, Market_Type__c,RecordTypeId, CurrencyIsoCode, StageName, Account.Sales_Organization__c, Bundle__c, CloseDate,Account.Price_Book__r.Country__c,
                            Sales_Organisation__c,Bundle__r.RecordTypeId,Pricebook2Id,(Select Id,Product2Id From OpportunityLineItems)
                    FROM Opportunity 
                    WHERE Id =:dealId limit 1];
                    
            if(!deals.isEmpty()){
                
                if(deals[0].OpportunityLineItems != null && !deals[0].OpportunityLineItems.isEmpty()){
                    for(OpportunityLineItem dp : deals[0].OpportunityLineItems){
                        existingProdIds.add(dp.Product2Id);
                    }
                }
                
                CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
                dealOrOrder.salesOrg = deals[0].Account.Sales_Organization__c;
                dealOrOrder.currencyCode = deals[0].CurrencyIsoCode;
                dealOrOrder.startDate = deals[0].Start_Date__c;
                dealOrOrder.bundleId = deals[0].Bundle__c;
                dealOrOrder.accountId = deals[0].AccountId;
                dealOrOrder.endDate = deals[0].CloseDate;
                dealOrOrder.recordType = CRM_AppConstants.OPPORTUNITY_OBJECT;
                dealOrOrder.dealRecord = deals[0];
                
                CRM_DataObjects.SearchFilters filters = new CRM_DataObjects.SearchFilters();
                filters.text = quickSearchText;
                filters.sortByField = 'Product2.Name';
                filters.sortOrder = 'ASC';
                filters.pageCount = 1;
                
                items = CRM_AddProductsHelper.searchProducts(dealOrOrder, pricebookId, filters);
                Integer numOfRecord = CRM_Batch_Size__c.getInstance('CRM_UploadExtract_ProdSrch_Rec_Lmt') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('CRM_UploadExtract_ProdSrch_Rec_Lmt').Batch_Size__c) : 50;
                
                for(integer i=0;i<items.size();i++){
                    
                    productSearchWrapper prodWrap = new productSearchWrapper();
                    prodWrap.product = items[i];
                    if(!existingProdIds.contains(prodWrap.product.productId)){
                        
                        OpportunityLineItemWrapper dealProdWrap = new OpportunityLineItemWrapper();
                        OpportunityLineItem dp = new OpportunityLineItem();
                        Product2 prod = new Product2();
                        
                        if(deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL){
                            prod.ProductCode = prodWrap.product.productCode != null ? prodWrap.product.productCode : '';
                            prod.Universal_Picture_Code__c = prodWrap.product.universalProductCode != null ? prodWrap.product.universalProductCode : '';
                        }else if(deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL){
                            if( prodWrap.product.externalId !=null && prodWrap.product.externalId.contains('_')){
                                    string[] split= prodWrap.product.externalId.split('_');           
                                    dealProdWrap.digital.language = split.size()>1?split[1]:'';
                                    dealProdWrap.digital.videoVersion = split.size()>2?split[2]:'';
                                    dealProdWrap.digital.channel = split.size()>3?split[3]:'';
                                    dealProdWrap.digital.format = split.size()>4?split[4]:'';
                            }
                        }
                        
                        prod.Name = prodWrap.product.name != null ?  prodWrap.product.name : '';   
                        dp.Product2 = prod;
                        dealProdWrap.lineItemRecord = dp;
                        prodWrap.isSelected = false;
                        prodWrap.dealProdWrap = dealProdWrap;
                        prodWrapList.add(prodWrap);
                        
                        if(prodWrapList.size() == numOfRecord){
                            break;
                        }
                    }
                }
            }
        }
        return prodWrapList;
    }
    
    /**
    *  US : 909 - Sprint 2 user story for US Games and athor territorys
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class productSearchWrapper {
        public CRM_DataObjects.ProductItem product;
        public OpportunityLineItemWrapper dealProdWrap;
        public boolean isSelected = false;
    }

    /**
    *  Description-Wrapper to store the Deal and DealProduct information
    *  @name-DealWrapper 
    */
    public class DealWrapper {
        public Id dealId;
        public Id accountId;
        public String dealCurrency;
        public Id pricebookId;
        public Date dealStartDate;
        public Date dealEndDate;
        
        // Optional to provide
        public string productFormat; //rmn
        
        //Optional to provide
        public string retailerProductId; //rmn
        
        //#767
        public string vendorId;
        public String channel;
        public String format;
        public String language;
  
  }
    public class CRM_Exception extends Exception {}
    
    // Added as a part of DE#4412
    
    global Integer getCurrencyDecimalPlaces()
    {
        Integer decimalPlaces;
        String oppCurrencyCode;
        Integer defaultDecimalPlaces = 2;
        
        List<CurrencyType> currencies = [SELECT ConversionRate,CreatedById,CreatedDate,DecimalPlaces,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType];
        
        Map<string, Integer> currencyMap = new Map<string, Integer>();
        for(CurrencyType curr: currencies){
            currencyMap.put(curr.IsoCode, curr.DecimalPlaces);
        }
        
        if (opp.CurrencyIsoCode != null ){
               oppCurrencyCode = opp.CurrencyIsoCode;
        }
        
        if(oppCurrencyCode != null && currencyMap!= null && currencyMap.containsKey(oppCurrencyCode)){
            decimalPlaces = currencyMap.get(oppCurrencyCode);
            return decimalPlaces;
        }
        
        return defaultDecimalPlaces;
    }
    
    //US397 - Check UK territory and hide list price and account price, display for other territories.
    public boolean getIsUKPhysical(){
        if (opp == null) {
            opp = [select id, Sales_Organisation__c,CurrencyIsoCode,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Opportunity where id=: dealId];
        }
      if(opp.RecordTypeId !=null && opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && CRM_AppConstants.TERRITORY_UK_CODE == opp.Sales_Organisation__c)
        return true;
      return false;
        
    }
    // code end of DE#4412
    
    
}