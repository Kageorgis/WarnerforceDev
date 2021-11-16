/**
   @Author: Cognizant Technology Solutions
   @name: CRM_AddProductsHelper
   @CreateDate: Nov 01, 2015
   @Description:  Helper class to filter the product based on the search inputs applied by user on the add products page and return the result 
   @Version - 1.0
   @reference: None
  */
  global with sharing class CRM_AddProductsHelper {
    
    /**
    *  @Description - method to get the picklist values for a given sobject field
    *  @name  getFilterPicklistValues 
    *  @param  object_name - name of the custom/standard object to retrieve picklist values
    *  @param  field_name - name of the custom/standard field to retrieve picklist values
    *  @param  first_val - value to be used as the first option for the picklist
    *  @return CRM_DataObjects.PicklistOption[] - list of picklist options for the selected custom field for the object 
    */
    static Id digitalProductRecordType = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    public static final Integer maxCount = CRM_Max_Product_Limit__c.getInstance('Add_Products') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Add_Products').Count__c) : 0;
    public static Integer maxPageCount = 1;
    public static Boolean showErrorMsg = false;
    public static CRM_DataObjects.PicklistOption[] getFilterPicklistValues(String object_name, String field_name, String first_val) {
      List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>(); //new list for holding all of the picklist options
      
      if (first_val != null && first_val.trim() != '') { //if there is a first value being provided
         options.add(new CRM_DataObjects.PicklistOption('',first_val)); //add the first option
      }
      
      Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add(new CRM_DataObjects.PicklistOption(a.getValue(), a.getLabel())); //add the value and label to our final list
      }
      return (options); //return the List
    }
    
    /**
    *  @Defect #4619 - Show default filter on page layout on add products page. 
    *  @Description - method to get the picklist values for a given sobject field
    *  @name  getFilterPicklistValuesWithRequestedObject 
    *  @param  object_name - name of the custom/standard object to retrieve picklist values
    *  @param  field_name - name of the custom/standard field to retrieve picklist values
    *  @param  first_val - value to be used as the first option for the picklist
    *  @param  requestedObject - From which object this is being called. 
    *  @return CRM_DataObjects.PicklistOption[] - list of picklist options for the selected custom field for the object 
    */
    public static CRM_DataObjects.PicklistOption[] getFilterPicklistValuesWithRequestedObject(String object_name, String field_name, String first_val, String requestedObject,string PricebookType) {
      List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>(); //new list for holding all of the picklist options
      
      if (first_val != null && first_val.trim() != '') { //if there is a first value being provided
         options.add(new CRM_DataObjects.PicklistOption('',first_val)); //add the first option
      }
      
      Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            CRM_DataObjects.PicklistOption picObj = new CRM_DataObjects.PicklistOption(a.getValue(), a.getLabel());
            if(PricebookType!= null && 
            PricebookType == CRM_AppConstants.PRICEBOOK_PRODUCT_TYPE_PHYSICAL && 
            requestedObject == CRM_AppConstants.BUNDLE_OBJECT && 
            ((  field_name == CRM_AppConstants.PRODUCT_FIELD_SAP_DIST_CHAIN_PRODUCT_STATUS && 
                CRM_AppConstants.distChainProdStatus.contains(a.getValue())) || 
                (field_name == CRM_AppConstants.PRODUCT_FIELD_PLANT_SPECIFIC_MATERIAL_STATUS) && 
                CRM_AppConstants.plantSpecificMaterialStatus.contains(a.getValue()))
            ){
                picObj.selected = true;
            }
            options.add(picObj); //add the value and label to our final list
      }
      return (options); //return the List
    }
    
    /**
    *  @Description - method to search the salesforce products from a pricebook based on the applied filters
    *  @name  searchProducts 
    *  @param  dealOrOrder - dealOrOrder details for which product will be searched based on the start date
    *  @param  pricebookId - Id of the pricebook where products to be searched
    *  @param  filters - product search filters
    *  @return CRM_DataObjects.ProductItem[] - list of ProductItems which macthed the applied filters
    */
    public static CRM_DataObjects.ProductItem[] searchProducts(CRM_DataObjects.ParentRecord dealOrOrder, Id pricebookId, CRM_DataObjects.SearchFilters filters) {
        //Integer maxPageCount = 1;
        Boolean isFilterPresent = false;
       // PricebookEntry[] fetchedPriceBookEntries= queryPricebookentries(dealOrOrder, pricebookId, filters);
        //System.debug('--fetchedPriceBookEntries.size()->'+fetchedPriceBookEntries.size());
        PricebookEntry[] priceBookEntries = queryPricebookentries(dealOrOrder, pricebookId, filters);
        //System.debug('Pricebook Products================>'+ priceBookEntries );
        System.debug('--priceBookEntries.size()->'+priceBookEntries.size());
        Set<Id> setProductIds = new Set<Id>();
        Map<String, PricebookEntry> mapUniqueKeyToPricebookInstance = new Map<String, PricebookEntry>();
        
        for(PricebookEntry pbe : priceBookEntries) {
            //System.debug('-pbe-->'+pbe);
            String key = (pbe.Product2Id + '-' + pricebookId +'-'+ pbe.CurrencyIsoCode).toLowercase();
            //System.debug('-key--->'+key);            
            setProductIds.add(pbe.Product2Id);
            if (!mapUniqueKeyToPricebookInstance.containsKey(key)) {
                mapUniqueKeyToPricebookInstance.put(key, pbe);
            }
        }

        /* COMPEX FILTERING PROCESS STARTS */
        // Map to hold the dated list-price for each product
        Map<String,Pricebook_Entry_Period__c> mapPriceBookEntryPeriod = new Map<String,Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> filteredPBEPList = new List<Pricebook_Entry_Period__c>();
        /*List<Pricebook_Entry_Period__c> fetchedPBEPList = [
                                SELECT Id, Product__c, List_Price__c, Price_Book__c, CurrencyISOCode, End_Date__c, Account_Price__c
                                FROM Pricebook_Entry_Period__c
                                WHERE Price_Book__c =: pricebookId
                                AND Start_Date__c <= :dealOrOrder.endDate
                                AND End_Date__c >= :dealOrOrder.startDate
                                AND CurrencyIsoCode =:dealOrOrder.CurrencyCode 
                                AND Product__c IN: setProductIds
                                Order By Price_Book__c, Product__c, CurrencyISOCode, Start_Date__c, CreatedDate];*/

        Date startDate = dealOrOrder.startDate;
        Date endDate = dealOrOrder.endDate;
        List<Pricebook_Entry_Period__c> fetchedPBEPList = new List<Pricebook_Entry_Period__c>();

        if (startDate != null && endDate != null) {
            String startDateStr = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('yyyy-MM-dd');
            String endDateStr = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('yyyy-MM-dd');

            String pbepQueryString = 'SELECT Id, Product__c, List_Price__c, Product__r.Name, Product__r.Street_Date__c, Price_Book__c, CurrencyISOCode, Start_Date__c, End_Date__c, Account_Price__c ' +
                                'FROM Pricebook_Entry_Period__c ' +
                                ' WHERE Price_Book__c = \'' + pricebookId + '\'' +
                                ' AND Start_Date__c <= ' + endDateStr  +
                                ' AND End_Date__c >= ' + startDateStr +
                                ' AND CurrencyIsoCode = \'' +  dealOrOrder.CurrencyCode + '\'' +
                                ' AND Product__c IN: setProductIds ';            
            System.debug('--filters->'+filters);
            if(filters.sortByField != null && filters.sortByField != ''){
                String fieldToSort = 'Order By ';
                if (filters.sortByField == 'Product2.Name') {
                    fieldToSort += ' Product__r.Name';
                } else if (filters.sortByField == 'Product2.Street_Date__c'){
                    fieldToSort += ' Product__r.Street_Date__c ';
                } else {
                    fieldToSort += ' Price_Book__c, CurrencyISOCode, Start_Date__c, CreatedDate ';
                }
                pbepQueryString += fieldToSort + ' ' + filters.sortOrder;
                pbepQueryString += ' NULLS LAST';
            }
            
            System.debug('--pbepQueryString-->'+pbepQueryString);
            
            for (Pricebook_Entry_Period__c pbep : (List<Pricebook_Entry_Period__c>) Database.query(pbepQueryString)) {
                String key = (pbep.Product__c + '-'+ pricebookId + '-'+ pbep.CurrencyISOCode).toLowercase();
                if(!mapPriceBookEntryPeriod.containsKey(key)){
                    fetchedPBEPList.add(pbep);
                }                
            }
        }
        //(List<Pricebook_Entry_Period__c>) Database.query(pbepQueryString);
        System.debug('fetchedPBEPList::'+fetchedPBEPList);
        System.debug('filters::'+filters);
        if(
                //filters != null && ((filters.streetDate != null && !filters.streetDate.isEmpty()) ||
                //Japan Us : 317 && Defect : 4325
                filters != null && (filters.StreetDateFrom != null ||
                filters.showAvailedProductsOnly == true ||
                (filters.listPriceFrom != null || filters.listPriceTo != null) || filters.fullMatchMaterialNumber == true)
        ) {
            filteredPBEPList = fetchedPBEPList;
            isFilterPresent = true;
        } else {
            if (fetchedPBEPList.size() > 0 && !fetchedPBEPList.isEmpty() && maxCount != null && maxCount > 0 && fetchedPBEPList.size() > maxCount) {
                maxPageCount = Integer.valueOf(Math.ceil((Decimal)fetchedPBEPList.size() / (Decimal)maxCount));
            } else {
                maxPageCount = 1;
            }
            
            if (filters.pageCount <= maxPageCount) {
                
                Integer recordStartCount = (maxCount*filters.pageCount) - maxCount ; 
                Integer recordEndCount = maxPageCount == filters.pageCount ? fetchedPBEPList.size() : maxCount*filters.pageCount;
                
                for(Integer i=recordStartCount ; i< recordEndCount; i++){
                    filteredPBEPList.add(fetchedPBEPList[i]);
                }
            }
        }
        System.debug('--filteredPBEPList.size()-->'+filteredPBEPList.size());                   
        /*for(Pricebook_Entry_Period__c pbePeriod : ){
            String recKey = (pbePeriod.Price_Book__c + '-' + pbePeriod.Product__c + '-' + pbePeriod.CurrencyISOCode).toLowercase();
            System.debug('-pbePeriod-->'+pbePeriod);
            if(!mapPriceBookEntryPeriod.containsKey(recKey)){
                mapPriceBookEntryPeriod.put(recKey, pbePeriod);
                System.debug('In If::'+mapPriceBookEntryPeriod);
            }
        }
        System.debug('-mapPriceBookEntryPeriod-->'+mapPriceBookEntryPeriod);*/
        Map <String, CRM_DataObjects.ProductItem> finalFilteredProductsMap = new Map<String, CRM_DataObjects.ProductItem>{};
        Integer filterCount = 0;
        
        // Then look through all items on the related pricebook
        for(Pricebook_Entry_Period__c pbePeriod : filteredPBEPList){
        //for (PricebookEntry pe : priceBookEntries ) {
            String key = (pbePeriod.Product__c + '-'+ pricebookId + '-'+ pbePeriod.CurrencyISOCode).toLowercase();          
            
            if (mapUniqueKeyToPricebookInstance.containskey(key)) {
                PricebookEntry pe = mapUniqueKeyToPricebookInstance.get(key);
                Boolean isDigitalProd = CRM_ApplicationUtility.isDigitalProduct(pe.Product2);
                Boolean isListPriceMatch = true;
                Boolean isAvailedProductsMatch = true;
                Boolean isProductStreetDateFilterMatch = true;
                //String recKeyFromPE = (pricebookId + '-' + pe.Product2Id + '-' + dealOrOrder.currencyCode).toLowercase();
                //Boolean hasPriceBookEntryPeriod = mapPriceBookEntryPeriod.containsKey(recKeyFromPE);

                //All Products must have PriceBookEntryPeriod
                //if(hasPriceBookEntryPeriod) {
                if(pbePeriod.Account_Price__c != null){
                    pe.UnitPrice =  pbePeriod.Account_Price__c;
                }else{
                    pe.UnitPrice =  pbePeriod.List_Price__c;
                }
                if (isFilterPresent && filters != null) {
                
                    //if(filters.streetDate != null && !filters.streetDate.isEmpty())
                    //US(Japan) : 317
                    if(filters.StreetDateFrom != null){
                        if(!isDigitalProd) {
                            if(!(//pe.Product2.Street_Date__c > System.TODAY() 
                                //&& pe.Product2.Street_Date__c <= System.TODAY().addDays(Integer.valueOf(filters.streetDate[0].value))))
                                //US(Japan) : 317 && Defect : 4325
                                pe.Product2.Street_Date__c > filters.StreetDateFrom && ((filters.StreetDateTo != null && pe.Product2.Street_Date__c <= filters.StreetDateTo) || filters.StreetDateTo == null))){
                                    isProductStreetDateFilterMatch = false;
                            }
                        }else if(isDigitalProd){
                            if(!(//pbePeriod.Start_Date__c > System.TODAY() 
                                //&& pbePeriod.Start_Date__c <= System.TODAY().addDays(Integer.valueOf(filters.streetDate[0].value))))
                                //US(Japan) : 317 && Defect : 4325
                                pe.Product2.Street_Date__c > filters.StreetDateFrom && ((filters.StreetDateTo != null && pe.Product2.Street_Date__c <= filters.StreetDateTo) || filters.StreetDateTo == null))){
                                    isProductStreetDateFilterMatch = false;
                            }
                        }
                    }
                    // Remove the digital product from search result if it is not availed 
                    if(filters.showAvailedProductsOnly == true && isDigitalProd) {
                        isAvailedProductsMatch = false;
                    }
    
                    // filter the product only if it has non-null price tag and meet the applied list price filter    
                    if((pe.UnitPrice == null && (filters.listPriceFrom != null || filters.listPriceTo != null)) 
                       || (filters.listPriceFrom != null && pe.UnitPrice < filters.listPriceFrom) 
                       || (filters.listPriceTo != null && pe.UnitPrice > filters.listPriceTo)) {
                            isListPriceMatch = false;
                    }
                }
                system.debug('Boolean Var : '+isListPriceMatch+'--'+isAvailedProductsMatch+'--'+isProductStreetDateFilterMatch+'--'+!isFilterPresent);
                // add the product to list if list price matched the applied filter (if any)
                
                if((isListPriceMatch && isAvailedProductsMatch && isProductStreetDateFilterMatch) || !isFilterPresent) {
                    if (isFilterPresent) {
                        filterCount++;
                        
                       if (filterCount > maxCount) {
                            showErrorMsg = true;
                            break;
                        }

                    }
                    CRM_DataObjects.ProductItem newItem = getProductItem(pe, dealOrOrder.startDate, dealOrOrder.recordType);
                    if (!finalFilteredProductsMap.containsKey(key)) {
                        finalFilteredProductsMap.put(key, newItem);
                    }
                }
            }
        }
        System.debug('finalFilteredProducts.size()::'+finalFilteredProductsMap.size());
        return finalFilteredProductsMap.values();
    }
    
    private static CRM_DataObjects.ProductItem getProductItem(PricebookEntry pe, Date startDate, string recordType) {
        // Create new item and initialise basic details
        CRM_DataObjects.ProductItem newItem = new CRM_DataObjects.ProductItem();

        newItem.productId = pe.Product2Id;
        newItem.stockQty = (Integer) pe.Product2.Items_in_Stock__c;
        newItem.name = pe.Product2.Name;
        newItem.productCode = pe.Product2.productCode;
        newItem.streetDate = pe.Product2.Street_Date__c;
        newItem.imageUrl = null; // Populated cia client side web service
        newItem.pricebookEntryId = pe.Id;
        newItem.listPrice = pe.UnitPrice;
        //Start - US#1015:Product language column
        newItem.languageCode = pe.Product2.Product_Language_Code__c;
        //End - US#1015:Product language column
        newItem.recommendedPrice = pe.Product2.Recommended_Price__c; 
        newItem.currencyCode = pe.CurrencyISOCode;
        newItem.format = pe.Product2.Product_Format__c;
        newItem.releaseDate = pe.Product2.Return_End_Date__c;
        
        //JAPAN-US:480 Deal Product Filter Variables
        newItem.productMarket = pe.Product2.Product_Market__c != null ? pe.Product2.Product_Market__c : '';
        newItem.productType = pe.Product2.Product_Type__c != null ? pe.Product2.Product_Type__c : '';

        //Order Product Filter Variables
        newItem.plantSpecificMaterialStatus = pe.Product2.Plant_Specific_Material_Status__c != null ? pe.Product2.Plant_Specific_Material_Status__c : '';
        newItem.sAPDistChainProductStatus = pe.Product2.SAP_Dist_chain_product_Status__c!= null ? pe.Product2.SAP_Dist_chain_product_Status__c : '';
        
        //Added for Req 199 for adding particular UPC / Material Number
        newItem.universalProductCode = pe.Product2.Universal_Picture_Code__c;
        newItem.externalId = pe.Product2.External_Id__c;
        newItem.salesOrg = pe.Product2.SAP_Sales_Org__c;
        newItem.distriButionChannel = pe.Product2.SAP_Distribution_Id__c;
        //Added for Req 199 for adding particular UPC / Material Number
       
       // Is product linked to local title, if so get details used to generate image
        if (pe.Product2.Local_Title__r != null) {
            newItem.videoVersion = pe.Product2.Local_Title__r.Title_VV_F__c;
            newItem.countryCode = pe.Product2.Local_Title__r.CountryCodeForImage__c.toUpperCase();
            newItem.languageCode = pe.Product2.Local_Title__r.LanguageCodeForImage__c.toUpperCase();
        }

        /*Red Border Enhancement in Add Product Page All Terrritory
        newItem.ExclusiveCustomerFlag = pe.Product2.Exclusive_Product_Flag__c ;
        */
         
        /* STOCK WARNING INDICATOR DISPLAY LOGIC */
        // get the cutoff date
        Date cutOffDate;
        try {
            if(pe.Product2.Items_in_Stock__c > 0) {
                cutOffDate = startDate.addDays((Integer)pe.Product2.Delivery_Lead_Days__c * -1);
            }
            else {
                cutOffDate = startDate.addDays( (Integer)pe.Product2.Cut_Off_Period_Weeks__c * -7);
            }
        }
        catch(Exception ex) {
        }
        
        newItem.stockWarning = false;
        
        newItem.SAPAndPlantStatusWarning = false;
        
        //warning indicator for physical product is based on the cutoff date while it is based on the client-avails for the digital product
        // for physical : If no items in stock or Cut off date of the product < Today() -> Show a warning alert
        Boolean isDigitalProduct = CRM_ApplicationUtility.isDigitalProduct(pe.Product2);
        if((isDigitalProduct && pe.UnitPrice == null) || 
            (!isDigitalProduct && (pe.Product2.Items_in_Stock__c == null || pe.Product2.Items_in_Stock__c == 0 
                                    || (cutOffDate != null && cutOffDate < System.Today()))) ) {
                                        
                newItem.stockWarning = true;
        }
        if(recordType !=null && recordType == CRM_AppConstants.BUNDLE_OBJECT && (pe.Product2.Plant_Specific_Material_Status__c != null && pe.Product2.Plant_Specific_Material_Status__c != CRM_AppConstants.PRODUCT_PLANT_STATUS_ACTIVE && 
            pe.Product2.Plant_Specific_Material_Status__c != CRM_AppConstants.PRODUCT_PLANT_STATUS_SELL_DOWN && 
            pe.Product2.Plant_Specific_Material_Status__c != CRM_AppConstants.PRODUCT_PLANT_STATUS_RELEASE_THIRDPARTY && 
            pe.Product2.Plant_Specific_Material_Status__c != CRM_AppConstants.PRODUCT_PLANT_STATUS_INITIAL) ||
            (pe.Product2.SAP_Dist_chain_product_Status__c != null && pe.Product2.SAP_Dist_chain_product_Status__c != CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE && 
             pe.Product2.SAP_Dist_chain_product_Status__c != CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_INITIAL && 
             pe.Product2.SAP_Dist_chain_product_Status__c != CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ONHOLD)
            ) {
                                        
                newItem.SAPAndPlantStatusWarning = true;
        }
        return newItem;
    }
    
    /**
    *  @Description - 
    *  @name  queryPricebookentries 
    *  @param  dealOrOrder - deal information (includes Start Date, AccountId, SAP Sales Org etc)
    *  @param  pricebookId - id of the pricebook associated to the deal
    *  @param  filters - filters to be applied on the search result / query
    *  @return PricebookEntry[] - list of pricebook entries matching the applied filters as well as the background filters
    */
    private static PricebookEntry[] queryPricebookentries(CRM_DataObjects.ParentRecord dealOrOrder, Id pricebookId, CRM_DataObjects.SearchFilters filters) {
        String salesOrg = dealOrOrder.salesOrg; 
        String currencyCode = dealOrOrder.currencyCode;
        Date startDate = dealOrOrder.startDate;
        Id bundleId = dealOrOrder.bundleId;
        Id accountId = dealOrOrder.accountId;
        String recordType= dealOrOrder.recordType;
        String[] soqlFilters = new String[]{};
        String[] userDefinedFilters = new String[]{};
        Set<Id> setBundleProductIds = new Set<Id>();
        //US#4363 - created new variable to get countrycode of pricebook
        string pricebookCountryCode;
        // Start - DEF#4143 -> Moved filtering code here from controller
        Boolean orderProductFilterFlag = false;
        Boolean orderProductFilterForRevShareFlag = false;
        Boolean returnOrderProductFilterFlag = false;
        Boolean orderProductFilterForReturnEndDateFlag = false;
        Boolean dealProductFilterFlag = false;

        // 01 =Active , 04 =On Hold & 11=Initial & 05 ,Z5 for Non-Returnable all territory
        Set<String> distChainProdStatus = new Set<String>{'01','04','11','05','Z5'};

        // 04=Active , 02=Released for 3rd Party & 05=Sell-down/Sell-Off 
        Set<String> sAPDistChainProductStatus = new Set<String>{'04','02','05'};

        // DEF#4114
        List<String> distChainProdStatusForReturns =
            new List<String>{
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_Z5,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_05,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_INITIAL
            };

        //--ER-007379 create list of valid SAP D Chain Status Active, Non-Returnable, Initial, Product Allocation for SDS--Start--//
        List<String> validSAPDistChainProductStatusForSDS =
            new List<String>{
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_INITIAL,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_PRODUCT_ALLOCATION,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_05
            };
        //--ER-007379 create list of valid SAP D CHain Status Active, Non-Returnable, Initial, Product Allocation for SDS--End--//

        Set<Id> setRecordIds;
        // Conditions for Orders Records
        if(dealOrOrder.orderRecord != null ){
            //Defect#4363- get countrycode of pricebook.
            pricebookCountryCode = dealOrOrder.orderRecord.Account.Price_Book__r.Country__c;
            if(dealOrOrder.orderRecord.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_STANDARD)
                orderProductFilterFlag = true;
            else if(dealOrOrder.orderRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE  
               && dealOrOrder.orderRecord.Account.Revenue_share__c == true && dealOrOrder.orderRecord.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_REV_SHARE
               && (dealOrOrder.orderRecord.OpportunityId == NULL || (dealOrOrder.orderRecord.OpportunityId != NULL &&
                dealOrOrder.orderRecord.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE))
            ) {
                orderProductFilterForRevShareFlag = true; 
            }
            if (
                    dealOrOrder.orderRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                    (orderProductFilterFlag || orderProductFilterForRevShareFlag)
            ) {
                sAPDistChainProductStatus.add(CRM_AppConstants.PRODUCT_PLANT_STATUS_INITIAL);
            }
            // DEF#4114
            if (dealOrOrder.orderRecord.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN) {
                returnOrderProductFilterFlag = true;

                //US#570 - flag set to true for FR orders with 'RETURN' record type.
                if(dealOrOrder.orderRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE){
                    orderProductFilterForReturnEndDateFlag = true;
                }

                // DEF#4219
                if(
                        dealOrOrder.orderRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE ||
                        dealOrOrder.orderRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                ) {
                    orderProductFilterForReturnEndDateFlag = true;
                }

            }
        } else if (dealOrOrder.dealRecord != null ) {
            //Defect#4363- get countrycode of pricebook.
            pricebookCountryCode = dealOrOrder.dealRecord.Account.Price_Book__r.Country__c; 
            if(dealOrOrder.dealRecord.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && (dealOrOrder.dealRecord.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL)){
                dealProductFilterFlag = true;
            }
        }
        //Defect#4363 
        if(dealOrOrder.bundleRecord != null){
            //Monika - Defect#4363
            pricebookCountryCode = dealOrOrder.bundleRecord.Price_Book__r.Country__c;
        }
        // End - DEF#4143 -> Moved filtering code here from controller
 
/*===Query Updated for Red Border Requirement==============*/  
        String SOQL_QUERY = 'SELECT Id, Product2Id, CurrencyIsoCode, Product2.Name, Product2.Street_Date__c, Product2.Product_Genre__c,'
                        + ' Product2.Local_Title__r.CountryCodeForImage__c,'
                        + ' Product2.Local_Title__r.LanguageCodeForImage__c, '
                        + ' Product2.recordtypeId, ' //Product2.Exclusive_Product_Flag__c,'
                        + ' Product2.Local_Title__r.Title_VV_F__c, UnitPrice, Product2.Recommended_Price__c,Product2.Return_End_Date__c, Product2.ProductCode,'
                        + ' Product2.Type__c, Product2.Items_in_Stock__c, Product2.Franchise_Type__c,'
                        + ' Product2.Delivery_Lead_Days__c, Product2.Cut_Off_Period_Weeks__c,Product2.Product_Market__c,Product2.Product_Type__c,'
                        + ' Product2.External_Id__c, Product2.Universal_Picture_Code__c, Product2.SAP_Sales_Org__c, Product2.SAP_Distribution_Id__c,Product2.SAP_Dist_chain_product_Status__c,Product2.Plant_Specific_Material_Status__c,'
                        + ' Pricebook2.CurrencyISOCode, toLabel(Product2.Product_Format__c),'
                        + ' Product2.Product_Language_Code__c'//US#1015:Product language
                        + ' FROM PricebookEntry';
        
        soqlFilters.add('Pricebook2Id = \''+ pricebookId +'\'');
        soqlFilters.add('IsActive = true');
        soqlFilters.add('Product2.IsActive = true');
        soqlFilters.add('Product2.SAP_Material_Type__c <> \'SBOM\'');
        soqlFilters.add('(Product2.recordtypeId = \''+CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL +'\' OR Product2.recordtypeId = \''+CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL+'\')');
        //soqlFilters.add('Product2.SAP_Sales_Org__c = \''+ salesOrg +'\'');
        soqlFilters.add('CurrencyIsoCode = \''+ currencyCode +'\'');
        
        if(AccountId != null) {
            soqlFilters.add('(Product2.Exclusive_Customer__c = null OR Product2.Exclusive_Customer__c= \''+ AccountId +'\')');
        }
        
        // Start - DEF#4143 -> Moved filtering code here from controller
        if (recordType!= null && recordType == CRM_AppConstants.ORDER_OBJECT && dealOrOrder.orderRecord != null) {

            if (orderProductFilterFlag || orderProductFilterForRevShareFlag) {
                if (orderProductFilterForRevShareFlag) {
                    soqlFilters.add('(Product2.Product_Market__c = \''+CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE+'\')');
                }
                //US#788 start for UNBW products visible for Italy Products 
                if(dealOrOrder.orderRecord.Sales_Organisation__c != CRM_AppConstants.TERRITORY_ITALY_CODE){
                    soqlFilters.add('((Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');
                    soqlFilters.add('(Product2.Plant_Specific_Material_Status__c IN:sAPDistChainProductStatus)');
                    soqlFilters.add('(Product2.SAP_Dist_chain_product_Status__c IN:distChainProdStatus))');
                }else{
                    soqlFilters.add('(Product2.Plant_Specific_Material_Status__c IN:sAPDistChainProductStatus OR Product2.Type__c = \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');
                    soqlFilters.add('(Product2.SAP_Dist_chain_product_Status__c IN:distChainProdStatus OR Product2.Type__c = \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');
                }//US#788 end for UNBW products visible for Italy Products 
            } else if(returnOrderProductFilterFlag) {
                String orderCreatedDateStr = DateTime.newInstance(dealOrOrder.orderRecord.CreatedDate.year(),dealOrOrder.orderRecord.CreatedDate.month(),dealOrOrder.orderRecord.CreatedDate.day()).format('yyyy-MM-dd');
                if(orderProductFilterForReturnEndDateFlag) {
                    //US#570
                    soqlFilters.add('(Product2.Return_End_Date__c = null OR Product2.Return_End_Date__c >= '+orderCreatedDateStr+')');
                }
                //US#788 start for UNBW products visible for Italy Products 
                if(dealOrOrder.orderRecord.Sales_Organisation__c != CRM_AppConstants.TERRITORY_ITALY_CODE){
                    distChainProdStatusForReturns.add(CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_LOST_RIGHTS);
                    soqlFilters.add('((Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');
                    // DEF#4114
                    soqlFilters.add('(Product2.SAP_Dist_chain_product_Status__c NOT IN:distChainProdStatusForReturns))');
                } else {
                    soqlFilters.add('((Product2.SAP_Dist_chain_product_Status__c NOT IN:distChainProdStatusForReturns AND Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\') OR Product2.Type__c = \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');
                } //US#788 end for UNBW products visible for Italy Products 
            }
        } else if (recordType != null && recordType == CRM_AppConstants.OPPORTUNITY_OBJECT && dealOrOrder.dealRecord != null) {
            //JAPAN-US:480
            // No other condition check as need to allow Manual NR deal products for Rental Deals - DEF#3977
            if (dealProductFilterFlag) {
                soqlFilters.add('(Product2.Product_Market__c = \''+dealOrOrder.dealRecord.Market_Type__c+'\')');
            }
            //US#788 for UNBW products not visible for Deal
            soqlFilters.add('(Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');
        }
        //US#788 Assortment start for UNBW products not visible for RT_Promotional_Assortment
        if( recordType !=null && recordType == CRM_AppConstants.BUNDLE_OBJECT && dealOrOrder.bundleId != null &&
                dealOrOrder.bundleRecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment){
            soqlFilters.add('(Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\')');    
        }//end
    
        // End - DEF#4143 -> Moved filtering code here from controller
        // US#525 Change: added default filters for 'Product Search Screen'
        Pricebook2[] listPricebooks = [select Id, Name, Product_Type__c from Pricebook2 where Id =:pricebookId ];
        //system.debug('--recordType--'+recordType+'--listPricebooks[0].Product_Type__c--'+listPricebooks[0].Product_Type__c+'--salesOrg--'+salesOrg+'--CRM_AppConstants.BUNDLE_OBJECT--'+CRM_AppConstants.BUNDLE_OBJECT+'--CRM_AppConstants.TERRITORY_FRANCE_CODE--'+CRM_AppConstants.TERRITORY_FRANCE_CODE);
        Boolean useDefaultFilters = ((recordType == null && listPricebooks[0].Product_Type__c == 'Physical' )|| (recordType != null && recordType == CRM_AppConstants.BUNDLE_OBJECT));

        //US#232: filter on product by distribution chain status, plant status.  && US#788
        if((filters.plantStatus == null || filters.plantStatus.isEmpty()) && useDefaultFilters){
            soqlFilters.add('(Product2.Type__c = \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\' OR (Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE +'\' AND (Product2.Plant_Specific_Material_Status__c = null OR (Product2.Plant_Specific_Material_Status__c = \''+CRM_AppConstants.PRODUCT_PLANT_STATUS_ACTIVE +'\' OR Product2.Plant_Specific_Material_Status__c = \''+CRM_AppConstants.PRODUCT_PLANT_STATUS_RELEASE_THIRDPARTY +'\' OR Product2.Plant_Specific_Material_Status__c = \''+CRM_AppConstants.PRODUCT_PLANT_STATUS_INITIAL +'\' OR Product2.Plant_Specific_Material_Status__c = \''+CRM_AppConstants.PRODUCT_PLANT_STATUS_SELL_DOWN +'\'))))');   
        }
        //system.debug('inside fileter SAP dist. chain'+filters.distChainProdStatus +' --------useDefaultFilters --------'+useDefaultFilters);
        if((filters.distChainProdStatus == null || filters.distChainProdStatus.isEmpty()) && useDefaultFilters){
            //system.debug('inside fileter SAP dist. chain');
            //--ER-007379 added if check for SDS related pricebook selected for search SDS product--//
            if(salesOrg != null && (salesOrg == CRM_AppConstants.TERRITORY_SDS_US_CODE || salesOrg == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
                soqlFilters.add('(Product2.Type__c = \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\' OR (Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\' AND (Product2.SAP_Dist_chain_product_Status__c IN: validSAPDistChainProductStatusForSDS)))');            
            }else{
                soqlFilters.add('(Product2.Type__c = \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\' OR (Product2.Type__c != \''+CRM_AppConstants.UNBW_PRODUCT_TYPE+'\' AND (Product2.SAP_Dist_chain_product_Status__c = null OR (Product2.SAP_Dist_chain_product_Status__c = \''+CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE +'\' OR Product2.SAP_Dist_chain_product_Status__c = \''+CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_INITIAL +'\' OR Product2.SAP_Dist_chain_product_Status__c = \''+CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ONHOLD+'\'))))');        
            }
        }
        //US#788 end
        //end US#232
        // When StartDate of the Deal is available
        /*if(startDate != null) {
            // then 
            // 1. Check that the Product's street Date should be earlier than the Deal Start Date
            String startDateStr = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('yyyy-MM-dd');
            soqlFilters.add('Product2.Street_Date__c <= '+startDateStr);
        }*/
        
        //DEF#4325
        if(filters != null) {
            if(filters.streetDateFrom != null) {
                date sd = date.newinstance(filters.StreetDateFrom.year(), filters.StreetDateFrom.month(), filters.StreetDateFrom.day());
                userDefinedFilters.add('Product2.Street_Date__c > :sd');
                if(filters.streetDateTo != null){
                     date ed = date.newinstance(filters.streetDateTo.year(), filters.streetDateTo.month(), filters.streetDateTo.day());
                     userDefinedFilters.add('Product2.Street_Date__c <= :ed');
                }
            }
            
            if(filters.title != null && filters.title != '') {
                filters.title = String.escapeSingleQuotes(filters.title);
                userDefinedFilters.add('Product2.Name like \'%'+ filters.title +'%\'');
            }
            if(filters.materialNumber != null && filters.materialNumber != '') {
                if(filters.fullMatchMaterialNumber == true ) {
                    userDefinedFilters.add('(Product2.ProductCode = \''+ filters.materialNumber +'\' OR Product2.Universal_Picture_Code__c = \''+ filters.materialNumber +'\')');
                }
                else {
                    userDefinedFilters.add('Product2.ProductCode like \'%'+ filters.materialNumber +'%\'');
                }
            }
            if(filters.productMarkets != null && !filters.productMarkets.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Product_Market__c', filters.productMarkets);
                userDefinedFilters.add(picklistFilter);
            }
            if(filters.productFormats != null && !filters.productFormats.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Product_Format__c', filters.productFormats);
                userDefinedFilters.add(picklistFilter);
            }
            System.debug('--filters.prodLanguages->'+filters.prodLanguages);
            if(filters.prodLanguages != null && !filters.prodLanguages.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Product_Language_Code__c', filters.prodLanguages);
                userDefinedFilters.add(picklistFilter);
            }
            if(filters.franchiseTypes != null && !filters.franchiseTypes.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Franchise_Type__c', filters.franchiseTypes);
                userDefinedFilters.add(picklistFilter);
            }
            if(filters.productTypes != null && !filters.productTypes.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Type__c', filters.productTypes);
                userDefinedFilters.add(picklistFilter);
            }
            if(filters.distChainProdStatus != null && !filters.distChainProdStatus.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.SAP_Dist_chain_product_Status__c', filters.distChainProdStatus);
                userDefinedFilters.add(picklistFilter);
            }
            if(filters.releaseCategories != null && !filters.releaseCategories.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Release_Category__c', filters.releaseCategories);
                userDefinedFilters.add(picklistFilter);
            }
            
            if(filters.productGenres != null && !filters.productGenres.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Product_Genre__c', filters.productGenres);
                userDefinedFilters.add(picklistFilter);
            }
            
            if(filters.productRatings != null && !filters.productRatings.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Product_Rating__c', filters.productRatings);
                //US#288 - Ability to get the into the Product ratings from the Local Title object.
                String picklistFilter2 = getPicklistQueryFilter('Product2.Secondary_Rating__c', filters.productRatings);                
                userDefinedFilters.add('('+picklistFilter+'OR'+picklistFilter2+')');
            }
            
            if(filters.contentTypes != null && !filters.contentTypes.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Local_Title__r.Title_Content_Type__c', filters.contentTypes);
                userDefinedFilters.add(picklistFilter);
            }
             //US#232: filter on product by distribution chain status, plant status.
            if(filters.plantStatus != null && !filters.plantStatus.isEmpty()) {
                String picklistFilter = getPicklistQueryFilter('Product2.Plant_Specific_Material_Status__c', filters.plantStatus);
                system.debug('Filter value -->'+picklistFilter);
                userDefinedFilters.add(picklistFilter);
            }
            /*if(filters.isMarketingMaterial == true) {
                soqlFilters.add('Product2.Marketing_Material__c = '+ filters.isMarketingMaterial +'');
            }*/
            
            if(filters.recommendedPriceFrom != null) {
                userDefinedFilters.add('Product2.Recommended_Price__c >= '+ filters.recommendedPriceFrom +'');
            }
            if(filters.recommendedPriceTo != null) {
                userDefinedFilters.add('Product2.Recommended_Price__c <= '+ filters.recommendedPriceTo +'');
            }

            if(bundleId != null && filters.bundleProductsOnly != null && filters.bundleProductsOnly == true){
                for(Bundle_Product__c bProd : [select Id, Product__c from Bundle_Product__c where Bundle__c =: bundleId ]) {
                    setBundleProductIds.add(bProd.Product__c);
                }
                
                userDefinedFilters.add('Product2Id IN :setBundleProductIds');
            }
            
            if(filters.text != null && filters.text.trim() != '' && filters.text.length() >=2) {
                //Defect#4363 - added extra parameter of pricebookCountryCode in method call
                setRecordIds = getQuickSearchRecords(filters.text,pricebookId,pricebookCountryCode);
                system.debug('********setRecordIds'+setRecordIds);
                //setRecordIds = getQuickSearchRecords(filters.text,pricebookId);
                //userDefinedFilters.add('(Product2Id IN :setRecordIds OR Product2.Local_Title__c IN: setRecordIds)');
                userDefinedFilters.add('(Product2Id IN :setRecordIds OR Product2.Local_Title__c IN: setRecordIds OR Product2.Local_Title__r.Title__r.MPM__c IN :setRecordIds)');
            }
            //Defect #3601 Time Out Issue
            
            if(userDefinedFilters.size() > 0 || Test.isRunningTest()){
                soqlFilters.addAll(userDefinedFilters);
            }
            else {
                soqlFilters.add('Id = Null');
            }
            
        }
        
        if(!soqlFilters.isEmpty()) {
            SOQL_QUERY += ' WHERE ' + String.join(soqlFilters, ' and ');
        }
        
        if(filters.sortByField != null && filters.sortByField != ''){
            SOQL_QUERY += ' ORDER BY ' + filters.sortByField + ' ' + filters.sortOrder;
        }
        
        SOQL_QUERY += ' LIMIT 40000';
        
        System.debug('SOQL_QUERY----------->'+SOQL_QUERY);
        
        //List<PricebookEntry> lstPBE = null;//new List<PricebookEntry>();
        
        /*try{
            System.debug('------lstPBE-----'+lstPBE);
            lstPBE = (List<PricebookEntry>) Database.query(SOQL_QUERY);
        }
        catch(Exception ex){
            System.debug('------Exception Handled and Caught-----'+ex.getMessage());
        }
        System.debug('------lstPBE1-----'+lstPBE);
        return lstPBE;*/
        
        
        return (PricebookEntry[]) Database.query(SOQL_QUERY);
    }
    
    /**
    *  @Description - method to query/sosl the Product, Local Data (including tags and topics) and return the combined matching record ids  
    *  @name  getPicklistQueryFilter 
    *  @param  quickSearchText - search string 
    *  @return Set<Id> - set of ids of records (product, local data, tags and topics) whcih matched the search string 
    */
    private static Set<Id> getQuickSearchRecords(String quickSearchText,Id PricebookId,string pricebookCountryCode) {// Defect#4363 -add parameter string pricebookCountryCode
        Set<Id> setMtachingRecordIds = new Set<Id>();
        List<String> lstQuickSearchText = new List<String>();
        system.debug('********'+quickSearchText+'*****'+PricebookId+'*****'+pricebookCountryCode);
        if(quickSearchText != null && quickSearchText.trim() != '') {
            quickSearchText = String.escapeSingleQuotes(quickSearchText);
            
            //String sosl_search = quickSearchText;
            
            //Added by Harshad for US 1014 
            String sosl_search = '';
            lstQuickSearchText = quickSearchText.split('\\n');
            for(String str : lstQuickSearchText){
                System.debug('str----'+str);
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
            //String SOSL_QUERY = 'FIND {'+ sosl_search +'} IN ALL FIELDS RETURNING Product2(Id,CurrencyIsoCode Where CurrencyIsoCode =:CurrencyIsoCode), Local_Title__c(Id,CurrencyIsoCode), Pricebook_Entry_Period__c(Product__c,CurrencyIsoCode)';
            String SOSL_QUERY_PRODUCT = 'FIND {'+ sosl_search +'} RETURNING Product2(Id) WITH PricebookId = \''+ pricebookId +'\'';
            System.debug('SOSL_QUERY_PRODUCT******'+SOSL_QUERY_PRODUCT);
            setMtachingRecordIds.addAll(getProductAndLocalDataIds(SOSL_QUERY_PRODUCT));
            
            //Added by Harshad for US 1014 
            if(sosl_search.length() > 4000)
                throw new CRM_AddProductHelperException(Label.CRM_SOSL_Search_String_Limit_Reached);
            
            system.debug('pricebookCountryCode --------'+pricebookCountryCode);
            // SEARCH RESULTS FROM LOCAL DATA
            //Defect:4363 : added where clause in query to get data specific to user territory.
            //Defect:4363 : added where clause in query to get data specific to user territory. '+ setCountryCodes +'
            String SOSL_QUERY_LOCALDATA = 'FIND {'+ sosl_search +'} RETURNING Local_Title__c(Id WHERE Country_Code__c =\''+pricebookCountryCode+'\')';
            //String SOSL_QUERY_LOCALDATA = 'FIND {'+ sosl_search +'} RETURNING Local_Title__c(Id WHERE Country_Code2__c IN (\'' + String.join(setCountryCodes, '\',\'') + '\'))';
            system.debug('SOSL_QUERY_LOCALDATA ---------'+SOSL_QUERY_LOCALDATA);
            system.debug('lstQuickSearchText ---------'+lstQuickSearchText.size());
            
            setMtachingRecordIds.addAll(getProductAndLocalDataIds(SOSL_QUERY_LOCALDATA));
            
            // SEARCH RESULTS FROM PBEP
            String SOSL_QUERY_PBEP = 'FIND {'+ sosl_search +'} RETURNING Pricebook_Entry_Period__c(Product__c Where Price_Book__c = \''+PricebookId+'\')';
            setMtachingRecordIds.addAll(getProductAndLocalDataIds(SOSL_QUERY_PBEP));
            
            // SEARCH RESULTS FROM MPM
            String SOSL_QUERY_MPMNumber = 'FIND {'+ sosl_search +'} RETURNING MPM__c(Id)';
            setMtachingRecordIds.addAll(getProductAndLocalDataIds(SOSL_QUERY_MPMNumber));
            if(lstQuickSearchText.size() == 1){ //Added if condition by Harshad for US 1014
            // RESULTS LOCAL_TITLES DATE with MATCHING TOPICS
                for(TopicAssignment topicAsgmnt: [Select Topic.Description, Topic.Name, TopicId, Id, EntityType, EntityKeyPrefix, EntityId 
                            From TopicAssignment 
                            where EntityType = 'Local_Title' and Topic.Name like :('%'+quickSearchText+'%') ]) {
                    
                    setMtachingRecordIds.add(topicAsgmnt.EntityId);
                }
                
                // RESULTS LOCAL_TITLES DATE with MATCHING TAGS
                for(Local_Title__Tag tag : [Select Type, TagDefinitionId, Name, ItemId, Id 
                            From Local_Title__Tag
                            where Name like : ('%'+quickSearchText+'%') ]) {
        
                    setMtachingRecordIds.add(tag.ItemId);
                }
                
                //Added Code For US : 263 : Search products based on related talent
                for(MPM_Talent__c mt : [SELECT MPM__c 
                                        FROM MPM_Talent__c 
                                        WHERE Character__c LIKE :('% '+quickSearchText+' %') OR Character__c LIKE :(quickSearchText+' %') OR
                                        Character__c LIKE :('% '+quickSearchText) OR Character__c = :quickSearchText OR Talent__r.name LIKE :('% '+quickSearchText+' %') OR 
                                        Talent__r.name LIKE :(quickSearchText+' %') OR Talent__r.name LIKE :('% '+quickSearchText) OR Talent__r.name = :quickSearchText]
                ){
                    setMtachingRecordIds.add(mt.MPM__c);
                }
            }    
        }
        System.debug('setMtachingRecordIds::'+setMtachingRecordIds);
        return setMtachingRecordIds;
    }
    
    /* - added method to get values from custom setting*/
     /**
    *  @Description - Defect:4363 method to get values from custom setting
    *  @name  getCustomSettingRecords
    *  @param  FieldAPIName and profile permission
    *  @return List<String> - List of product code for user profile
    */
    private static List<String> getCustomSettingRecords(String fieldAPIName, String ProfilePermissions){
      
        List<String> lstCSRecords = new List<String>();
        String csRecord;
        if(fieldAPIName == 'Product_Country_Code__c'){
            csRecord  = CRM_Profile_Based_Country_Identification__c.getInstance(ProfilePermissions) != null ? CRM_Profile_Based_Country_Identification__c.getInstance(ProfilePermissions).Product_Country_Code__c : null;
        }
        if(csRecord != null){                              
            lstCSRecords = csRecord.split(',');            
            system.debug('lstCSRecords -->'+lstCSRecords);
        }
        return lstCSRecords;
    }
    
     /**
    *  @Description - method to Run SOSL Query
    *  @name  getProductAndLocalDataIds
    *  @param  SOSL_Query - SOSL query to retrive products and Local Data Ids
    *  @return Set<Id> - Set Of Product and Local Data Ids
    */
    private static Set<Id> getProductAndLocalDataIds(String SOSL_QUERY){
        //List<List<SObject>> searchResult = Search.query(SOSL_QUERY);
        //Added by Harshad for US 1014
        List<List<SObject>> searchResult = null;
        try{
            searchResult= Search.query(SOSL_QUERY);
        }
        catch(SearchException searchEx){
            throw new CRM_AddProductHelperException(Label.CRM_SOSL_Search_String_Limit_Reached);
           // System.assert(false);
        }
        system.debug('******SOSL_QUERY'+SOSL_QUERY+'******searchResult'+searchResult);
        Set<Id> setMtachingRecordIds = new Set<Id>();
        
        for(Sobject[] listObj : searchResult) {
            for(sobject sobj : listObj) {
                if(sobj.getSObjectType() == Pricebook_Entry_Period__c.sObjectType){
                    //System.debug('486 ProductIDs :::: '+(Id)sobj.get('Product__c'));
                    setMtachingRecordIds.add((Id)sobj.get('Product__c'));
                }else{
                    system.debug('*****in else');
                    /*if(sobj.getSObjectType() == Product2.sObjectType)
                        System.debug('ProductIDs :::: '+(Id)sobj.get('Id'));
                    else
                        System.debug('LocalDataIDs :::: '+(Id)sobj.get('Id'));*/
                    setMtachingRecordIds.add((Id)sobj.get('Id'));
                }
            }
        }
        system.debug('******setMtachingRecordIds'+setMtachingRecordIds);
        return setMtachingRecordIds;
    }
    
    /**
    *  @Description - method to create a where clause condition for a multiselect picklist
    *  @name  getPicklistQueryFilter 
    *  @param  fieldName - picklist field to filter search result 
    *  @param  selectedOptions - list of selected options
    *  @return String - where clause condition to add in the query to filter on selected picklist values
    */
    private static String getPicklistQueryFilter(String fieldName, CRM_DataObjects.PicklistOption[] selectedOptions) {
        String queryFilter;
        String[] conditions = new String[]{};
        
        if(selectedOptions != null && !selectedOptions.isEmpty()) {
            for(CRM_DataObjects.PicklistOption opt : selectedOptions) {
                conditions.add(' '+fieldName+'= \''+ opt.value +'\' ');
            }
        }
        
        if(!conditions.isEmpty()) {
            queryFilter = ' ('+ String.join(conditions,' OR ') +' )';
        }
        
        return queryFilter;
    }
    
    public static Boolean getPreventAddProductsFlag(){
        return (CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c == true ? true : false);
    }
    //Added By Harshad for US 1014
    global class CRM_AddProductHelperException extends Exception {}
}