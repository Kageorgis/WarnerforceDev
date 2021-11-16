/**
   @Author Cognizant
   @name CRM_ProductMoreInfoController
   @CreateDate 27 Nov 2015
   @Description This class will be use to show the product related information in popup window
   @Version <1.0>
   @reference Requirement no 04, 13
*/

global with sharing class CRM_ProductMoreInfoController{

    //public list<String> years{get;set;}
    public ProductInfo productInformation {get; set;}
    CRM_ProductPricingHandler.DealWrapper currentDealWrapper;
    public String errorMessage {get; set;}
    public String accountID{get;set;}
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    static Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
    public boolean isGerman{get; set;}
    
    //US : 624
    public string MPMId;
    /**
     *  Constructor
     *  @name CRM_ProductMoreInfo
     *  @param None
     *  @return None
     *  @throws Exception on UI
     */
    public CRM_ProductMoreInfoController(){
        // Get URL Parameter
        String dealOrOrderID =  ApexPages.CurrentPage().getParameters().get('dealOrOrderID');
        dealOrOrderID = (dealOrOrderID == 'null' ? null : dealOrOrderID);
        String priceBookEntryID =  ApexPages.CurrentPage().getParameters().get('priceBookEntryID');
          
        System.debug('dealOrOrderID--->'+dealOrOrderID);
        
        // Get Product Information using pricebookentry id
        PriceBookEntry pricebookEntry = getPriceBookEntry(priceBookEntryID); 
        
        //US : 624
        if(pricebookEntry.product2.Local_Title__r.Title__r.MPM__c != null){
            MPMId = pricebookEntry.product2.Local_Title__r.Title__r.MPM__c;
        }
        
        // Get productdate from deal or order id
        PricebookInfo currentPriceBookInfo = getPriceBookInfo(dealOrOrderID, pricebookEntry); 
        
        // Create Product Information Wrapper
        productInformation = new ProductInfo(pricebookEntry, currentPriceBookInfo.startDate);
                
        // Get dated pricebookentry for the product if available 
        /*Pricebook_Entry_Period__c pricebookEntryPeriod = getPriceBookEntryPeriod(currentPriceBookInfo, pricebookEntry.product2.ID);
        
        // Update the product information if dated price is available
        if(pricebookEntryPeriod != null){
            productInformation.listPrice = pricebookEntryPeriod.List_Price__c;                
            productInformation.currencyIsoCode = pricebookEntryPeriod.CurrencyIsoCode;
        }*/
        CRM_ProductPricingHandler pricingHandler;
        Pricebook_Entry_Period__c pbep;
       // Update Product Information
        if(currentDealWrapper != null){

            // Format the decimal value so that it converts value locale wise
            pricingHandler = new CRM_ProductPricingHandler(new List<CRM_ProductPricingHandler.DealWrapper>{currentDealWrapper});
            Decimal listPrice = pricingHandler.getProductDatedListPrice(currentDealWrapper);
            if (listPrice != null) {
                productInformation.listPrice = listPrice.format();
            }
            Decimal accountPrice = pricingHandler.getAccountPrice(currentDealWrapper);
            if (accountPrice != null) {
                productInformation.accountPrice = accountPrice.format();
            }

            pbep = pricingHandler.getProductDatedPricebookEntryPeriod(currentDealWrapper);
            if(pbep != null && pbep.Retail_Price__c != null){
                productInformation.retailPrice = pbep.Retail_Price__c.format();
                
            }
        }
        //Update Release Date of Productbased on RecordType of Product
        if (productInformation.Product.RecordTypeId == digitalProductRecordTypeId) {
            if(currentDealWrapper != null && pricingHandler != null){
                if(pbep != null && pbep.Start_Date__c != null){
                    productInformation.releaseDate = pbep.Start_Date__c;
                    productInformation.releaseCategory = pbep.Client_Avail__r.Local_Data_Category_Picklist__c;
                }
            }
        }else if (productInformation.Product.RecordTypeId == physicalProductRecordTypeId) {
            productInformation.releaseDate = productInformation.Product.Street_Date__c;
            productInformation.releaseCategory = productInformation.Product.Release_Category__c;
        }
    }
    
    global Boolean getIsProductSearchScreen() {
    	return (accountID != null ? false : true);
    }
    
    /**
     *  This method returns price book entry with product details 
     *  @name getPriceBookEntry
     *  @param String priceBookEntryID
     *  @return PriceBookEntry
     *  @throws None
     */
    @TestVisible
    private PriceBookEntry getPriceBookEntry(String priceBookEntryID){        
        return  [SELECT CurrencyIsoCode, UnitPrice, product2.ID, product2.ProductCode, tolabel(product2.SAP_Dist_chain_product_Status__c),tolabel(product2.Plant_Specific_Material_Status__c)/*US#232: adde new field*/, product2.Long_Description__c,
                tolabel(product2.Release_Category__c), tolabel(product2.Product_Format__c), tolabel(product2.Product_Genre__c), product2.Product_Media_Quantity__c, 
                product2.Product_Owner__c, tolabel(product2.Product_Language_Code__c), product2.Product_Type__c, product2.Street_Date__c, 
                product2.Universal_Picture_Code__c, product2.Product_Weight__c, product2.Product_Height__c, product2.Product_Depth__c, 
                product2.Product_Width__c, tolabel(product2.Case_Type__c), tolabel(product2.External_Material_Group__c), tolabel(product2.Franchise_Type__c), 
                product2.Local_Title__r.Local_BD_Release_Date__c, product2.Local_Title__r.Local_Box_Office__c, 
                product2.Local_Title__r.Local_DVD_Release_Date__c, product2.Local_Title__r.Local_Label__c, product2.Local_Title__r.Topics__c,
                product2.Local_Title__r.Local_Pay_TV_Start_Date__c, product2.Local_Title__r.Local_Rating__c, product2.Local_Title__r.Talent__c,
                product2.Local_Title__r.Local_Rating_System__c, product2.Local_Title__r.Local_Run_Time__c,product2.Recommended_Price__c,  
                product2.Local_Title__r.Local_Season__c, product2.Local_Title__r.Local_Synopsis__c, product2.Items_in_Stock__c,
                product2.Local_Title__r.Local_TV_Air_Date__c, product2.Local_Title__r.Local_Theatrical_Release_Date__c, 
                product2.Local_Title__r.Num_Local_Episodes__c, product2.Local_Title__r.Title_Content_Type__c, product2.Date_of_Stock_Level__c,
                product2.Local_Title__r.Title_MPM_F__c, product2.Local_Title__r.Title_VV_F__c, product2.Name, product2.Cut_Off_Period_Weeks__c,
                product2.Local_Title__r.Region__c, product2.Local_Title__r.UV_Published_Date__c, product2.Delivery_Lead_Days__c,
                product2.Product_Group__r.Name, product2.Similar_Title_1__c, product2.Similar_Title_2__c, product2.Similar_Title_3__c, tolabel(product2.Type__c),
                product2.Similar_Title_1__r.Name, product2.Similar_Title_2__r.Name, product2.Similar_Title_3__r.Name, Product2.RecordTypeId, Product2.Exclusive_Customer__c,
                product2.Local_Title__r.Title__r.MPM__c, Product2.Exclusive_Product_Flag__c //US #445: Customer Exclusive flag on the Product Detail pop-up
        		, Pricebook2Id, Pricebook2.CurrencyISOCode, Pricebook2.Business_Unit__c // US#525 : added for Product Search screen 
        		FROM PriceBookEntry WHERE ID =: priceBookEntryID];
    }

    
    /**
     *  This method returns price book info such as price book id, currency code and start date
     *  @name getPriceBookInfo
     *  @param ID dealOrOrderID 
     *  @param ID productID
     *  @return PricebookInfo
     *  @throws None
     */
    
    private PricebookInfo getPriceBookInfo(String dealOrOrderID, PricebookEntry pbe){ 
    	System.debug('dealOrOrderID 2--->'+dealOrOrderID);
    	// US-525 : when invoked from Search Screen page (order/deal/bundle) will not be associated
    	if(String.isBlank(dealOrOrderID)) {
    		System.debug('dealOrOrderID returning--->'+dealOrOrderID);
    		
    		currentDealWrapper = new CRM_ProductPricingHandler.DealWrapper();
            currentDealWrapper.accountId = null;
            accountID = null;
            currentDealWrapper.dealCurrency = pbe.CurrencyISOCode;
            currentDealWrapper.productId = pbe.product2.ID;
            currentDealWrapper.pricebookId = pbe.Pricebook2Id;
            currentDealWrapper.dealStartDate = System.today();
            currentDealWrapper.dealEndDate = System.today();
			
            return new PricebookInfo(currentDealWrapper.dealStartDate, currentDealWrapper.dealEndDate, pbe.Pricebook2Id, pbe.CurrencyIsoCode);
    	}
    	
        String objectName = ((Id)dealOrOrderID).getSObjectType().getDescribe().getName();
        
        // Get deal start date
        if(objectName.equalsIgnoreCase(CRM_AppConstants.OPPORTUNITY_OBJECT)){     
            currentDealWrapper = new CRM_ProductPricingHandler.DealWrapper();
            
            Opportunity deal = [SELECT ID, Start_Date__c, CurrencyIsoCode, Pricebook2ID, AccountID, CloseDate, Account.Sales_Organization__c,Account.Digital_Country_Code__c,RecordTypeId FROM Opportunity WHERE ID =: dealOrOrderID];     
            
            currentDealWrapper.dealId = deal.ID;
            accountID = deal.AccountID;
            currentDealWrapper.accountId = deal.AccountID;
            currentDealWrapper.dealCurrency = deal.CurrencyIsoCode;
            currentDealWrapper.productId = pbe.product2.ID;
            currentDealWrapper.pricebookId = deal.Pricebook2ID;
            currentDealWrapper.dealStartDate = deal.Start_Date__c;
            currentDealWrapper.dealEndDate = deal.CloseDate;
            
            isGerman = ((deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || deal.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                        ||
                       (deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(deal.Account.Digital_Country_Code__c)));
        
            
            return new PricebookInfo(deal.Start_Date__c, deal.CloseDate, deal.Pricebook2ID, deal.CurrencyIsoCode);
        
         // Get deal order date
        }else if(objectName.equalsIgnoreCase(CRM_AppConstants.ORDER_OBJECT)){
            currentDealWrapper = new CRM_ProductPricingHandler.DealWrapper();
            Order currentOrder = [SELECT EffectiveDate, CurrencyIsoCode, Pricebook2ID, AccountId, EndDate FROM Order WHERE ID =: dealOrOrderID];

            currentDealWrapper.accountId = currentOrder.AccountId;
            currentDealWrapper.dealCurrency = currentOrder.CurrencyIsoCode;
            currentDealWrapper.productId = pbe.product2.ID;
            currentDealWrapper.pricebookId = currentOrder.Pricebook2ID;
            currentDealWrapper.dealStartDate = currentOrder.EffectiveDate;
            currentDealWrapper.dealEndDate = currentOrder.EndDate;

            return new PricebookInfo(currentOrder.EffectiveDate, currentOrder.EndDate, currentOrder.Pricebook2ID, currentOrder.CurrencyIsoCode);
        
         // Get deal bundle date
        }else if(objectName.equalsIgnoreCase(CRM_AppConstants.BUNDLE_OBJECT)){
            Bundle__c currentBundle = [SELECT Start_Date__c, CurrencyIsoCode, Price_Book__c, End_Date__c FROM Bundle__c WHERE ID =: dealOrOrderID];
            return new PricebookInfo(currentBundle.Start_Date__c, currentBundle.End_Date__c, currentBundle.Price_Book__c, currentBundle.CurrencyIsoCode);
        }
        return null;
    }
    
    /**
     *  This method returns stock level from account product
     *  @name getStockLevel
     *  @param ID productID
     *  @return String
     *  @throws None
     */
    
    @TestVisible
    private Decimal getStockLevel(ID productID){ 
        List<Account_Product__c> accountProducts = new List<Account_Product__c>();
        
        accountProducts = [SELECT Stock_Level__c FROM Account_Product__c WHERE Product__c =: productID Limit 1];
        
        if(!accountProducts.isEmpty()){              
            return accountProducts[0].Stock_Level__c;
        }
        
        return 0;
    }
    
    @RemoteAction 
    static global list<String> getYears(String accountID, String productId, Boolean allCustomers){
        list<String> years = new list<String>();
        String condition='';
        String dealRecordType_Actuals = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
        String dealRecordType_POS_Actuals = CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS;
        if(!allCustomers) {
            condition='OpportunityLineItem.Opportunity.AccountID =: accountID AND';
        }
        String soql = 'SELECT calendar_year(ScheduleDate) calYear '+
                      'FROM OpportunityLineItemSchedule '+
                      'WHERE '+condition+' (OpportunityLineItem.Opportunity.RecordTypeID =: dealRecordType_Actuals '+
                      'OR OpportunityLineItem.Opportunity.RecordTypeID =: dealRecordType_POS_Actuals) '+
                      'AND OpportunityLineItem.Product2Id =:productId '+
                      'GROUP BY calendar_year(ScheduleDate) '+
                      'ORDER BY calendar_year(ScheduleDate) DESC '+
                      'LIMIT 50000';
        list<AggregateResult> resultList = Database.query(soql);
        for(AggregateResult ar:resultList){
            years.add(String.valueof(ar.get('calYear')));
        }
        system.debug('=============years1===================='+years);
        return years;
    } 
    /**
     *  This method returns similar titles data from deal schedule
     *  @name getOrderHistory
     *  @param Integer year, String accountID
     *  @return CRM_DataObjects.SimilarTitles
     *  @throws None
     */
    
    @RemoteAction
    static global CRM_DataObjects.OrderHistory getOrderHistory(Integer year, String accountID, String productId, Boolean allCustomers){
            String chartDataCurrency = [select Id, DefaultCurrencyIsoCode from User where Id=:Userinfo.getUserid() LIMIT 1][0].DefaultCurrencyIsoCode;
            System.debug('accountID---->'+accountID);
        
            List<Decimal> posActuals = new List<Decimal>();
            List<Decimal> actuals = new List<Decimal>();
            Decimal revenue = null; 
            Integer monthNum = null;
            String prdctId = null;
            String condition='';
            String dealRecordType_Actuals = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
            String dealRecordType_POS_Actuals = CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS;
            
            if(!allCustomers) {
                condition='OpportunityLineItem.Opportunity.AccountId =: accountID AND';
            }
            for(Integer i=0; i < 12; i++) {
                posActuals.add(0);
                actuals.add(0);
            }
            
            String soql = 'SELECT OpportunityLineItem.Opportunity.RecordTypeID RecType, calendar_month(ScheduleDate) monthNum, SUM(Revenue) actRev '+
                          'From OpportunityLineItemSchedule '+
                          'WHERE '+condition+' (OpportunityLineItem.Opportunity.RecordTypeID =: dealRecordType_Actuals '+
                          'OR OpportunityLineItem.Opportunity.RecordTypeID =: dealRecordType_POS_Actuals) '+
                          'AND calendar_year(ScheduleDate) =: year '+
                          'AND OpportunityLineItem.Product2Id =:productId '+
                          'GROUP BY OpportunityLineItem.Opportunity.RecordTypeID, calendar_month(ScheduleDate) '+
                          'LIMIT 50000';
            list<AggregateResult> resultList = Database.query(soql);
            
            for(AggregateResult currentResult: resultList){ 
                
                revenue = (Decimal) currentResult.get('actRev');
                // convert the currency if it is set (other than default org currency)
                if(chartDataCurrency != null) {
                    revenue = CRM_ApplicationUtility.convertOrgCurrency(revenue, chartDataCurrency);
                }
                
                revenue = revenue.setScale(2);
                
                monthNum = Integer.valueOf(currentResult.get('monthNum'));
                //prdctId = String.valueOf(currentResult.get('prd')); 
                //System.debug('prdctId===> ' + prdctId);  
               if(currentResult.get('RecType') == CRM_RecordTypeUtil.RT_DEAL_ACTUALS){
                   actuals[monthNum-1] =  revenue;
               }
               else if(currentResult.get('RecType') == CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS ) {
                   posActuals[monthNum-1] =  revenue;
               }
           }
           
           CRM_DataObjects.OrderHistory orderWrapper = new CRM_DataObjects.OrderHistory();
           orderWrapper.posActuals = posActuals;
           orderWrapper.actuals = actuals;
           orderWrapper.months = new List<String>{};
           
           System.debug('actuals===> ' + actuals);  
           System.debug('posActuals===> ' + posActuals);
           
           DateTime dt = System.now();
           for(Integer i = 1; i<= 12; i++) {
               orderWrapper.months.add(DateTime.newInstance(dt.year(), i, 1).format('MMM'));
           }
           
           System.debug('orderWrapper==============> ' + orderWrapper);
           System.debug('orderWrapper.months ==============> ' + orderWrapper.months);
           return orderWrapper;        
    }
    
     /**
     *  US : 264 
     *  This method returns list of MPM Talent recrods related to MPM recrod presetn on title of Product
     *  @name getMPMTalentInfo
     *  @return List<MPM_Talent__c>
     *  @throws None
     */
     global List<MPM_Talent__c> getMPMTalentInfo(){
        List<MPM_Talent__c> mpmTalentList = new List<MPM_Talent__c>();
        if(MPMId != null){
            mpmTalentList = [SELECT Id,Character__c,Credit_Sequence__c,MPM__c,Role__c,Talent__r.name FROM MPM_Talent__c WHERE MPM__c =:MPMId ORDER BY Credit_Sequence__c];
        }
        return mpmTalentList;
    }
    
    public class ProductInfo{
        public String listPrice {get; set;}
        public String accountPrice {get; set;}
        public String retailPrice {get; set;}
        public String currencyIsoCode {get; set;}
        public Product2 product {get; set;}
        public String cutOffDate {get; set;}
        public Decimal stockLevel {get; set;}
        //public String customerLastOrderDate{get; set;}
        //public Decimal customerLastOrderVolume{get; set;}
        //public String orderHistoryJSON{get; set;}
        //public String similarTitlesJSON{get; set;}
        public Date releaseDate{get; set;}
        public String releaseCategory{get; set;}
        /*public ProductInfo(){
                
        }*/
        
        public ProductInfo (PriceBookEntry currentPriceBookEntry, Date opportunityStartDate){           
            //this.listPrice = currentPriceBookEntry.UnitPrice;
            this.currencyIsoCode = currentPriceBookEntry.CurrencyIsoCode;
            this.product = currentPriceBookEntry.Product2;
            this.cutOffDate = getCutOffDate(currentPriceBookEntry.Product2, opportunityStartDate) != null ? getCutOffDate(currentPriceBookEntry.Product2, opportunityStartDate).format() : 'NA';              
        }   
        
        private Date getCutOffDate(Product2 product, Date opportunityStartDate){  
            Integer itemStocks = product.Items_in_Stock__c == null ? 0 : (Integer)product.Items_in_Stock__c;
            Integer leadDays = product.Delivery_Lead_Days__c == null ? 0 : (Integer)product.Delivery_Lead_Days__c;
            Integer cutOffPeriod = product.Cut_Off_Period_Weeks__c == null ? 0 : (Integer)product.Cut_Off_Period_Weeks__c;
            
            if(opportunityStartDate != null){
                if(itemStocks > 0){
                    return (opportunityStartDate.addDays( - leadDays));
                }else{
                    return (opportunityStartDate.addDays( - (Integer)(cutOffPeriod * 7)));
                }
            }
            
            return null;
        }
    }
    
    class PricebookInfo{
        Date startDate;
        Date endDate;
        ID priceBookID;
        String currencyCode;
        
        public PricebookInfo(Date startDate, Date endDate, ID priceBookID, String currencyCode){
            this.startDate = startDate;
            this.endDate = endDate;
            this.priceBookID = priceBookID;
            this.currencyCode = currencyCode;
        }
    }
    
    
    global class OrderHistoryWrapper{
        List<String> months;
        List<Decimal> posActuals;
        List<Decimal> actuals;         
    }
}