/**
   @Author-Cognizant Technology Solutions
   @name-CRM_ProductPricingHandler
   @CreateDate-<Date>
   @Description-The class is used to calculates the Account Price on Deal Product using applicable List Price and Discount Percentage.
   @Description-The List Price is retrieved from the Price Book Entry Period of Product being added as Deal Product
   @Description-The Discount Percentage on File Discounts are fetched from the Accounts linked to Opportunity directly or indirectly.
   @Version-1.0
   @reference-None
  */ 
public with sharing class CRM_ProductPricingHandler {
    public Map<String,Pricebook_Entry_Period__c[]> mapDatedPricebookEntries; 
    public Map<Id,Product2> mapProductDetails;
    public Map<String,Pricebook_Entry_Period__c[]> mapRetailerPricebookEntries;  //rmn
    private Map<Id, Account> mapAllAccountWithFDs;
    private Set<String> setCurrencyCodes = new Set<String>();
    private Set<Id> setProductsIds = new Set<Id>();
    private Set<Id> setPricebookIds = new Set<Id>();
    public Set<Id> setAccountIds = new Set<Id>();

    /**
    *  Description-Constructor uses the DealWrapper to prepare Sets of information like ProductId's,PriceBooks,CurrencyCodes etc
    *  @name-CRM_ProductPricingHandler
    *  @param-DealWrappers - The wrapper is created in DealProductHandler class
    */
    public CRM_ProductPricingHandler(DealWrapper[] listDealWrappers) {
       for(DealWrapper dw : listDealWrappers) {
            if(dw.dealEndDate == null) {
                throw new CRM_ProductPricingHandler.CRM_Exception('Please set the Deal/Order End Date');
            }
            setProductsIds.add(dw.productId);
            setPricebookIds.add(dw.pricebookId);
            setCurrencyCodes.add(dw.dealCurrency);
            setAccountIds.add(dw.accountId);
        }       
        initializePricebookEntryPeriodData();
        initializeAccountDetails();
    }
    public CRM_ProductPricingHandler() {
    }

    public class CRM_Exception extends Exception {}

    /**
    *  Description-Method fetches all the File Discounts for directly and indirectly related accounts to a Deal
    *  @name-initializeAccountDetails
    */
    public void initializeAccountDetails() {
        mapAllAccountWithFDs = new Map<Id,Account>();           
        for(Account acc: [select Id, Name, Sales_Organization__c, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId
                    from Account 
                    where Id IN :setAccountIds ]){            
            mapAllAccountWithFDs.put(acc.Id, null);
            mapAllAccountWithFDs.put(acc.ParentId, null);
            mapAllAccountWithFDs.put(acc.Parent.ParentId, null);
            mapAllAccountWithFDs.put(acc.Parent.Parent.ParentId, null);
            mapAllAccountWithFDs.put(acc.Parent.Parent.Parent.ParentId, null);
            mapAllAccountWithFDs.put(acc.Parent.Parent.Parent.Parent.ParentId, null);
        }
        mapAllAccountWithFDs = new Map<Id,Account>([select Id, Name, ParentId, Sales_Organization__c,
                (SELECT Name, Customer__c, Discount_Percent__c, Start_Date__c, End_Date__c, Product_Type__c, Format__c, Priority_Promotion__c from File_Discounts__r)
                from Account where Id IN: mapAllAccountWithFDs.keySet()]);              
    }
    
    /**
    *  Description-Method used to calculate account price for a deal product based on the list price and its file discount
    *  @name-getAccountPrice
    *  @param-Deal Wrapper is passed as parameter to other methods to get the list Price and the Discount Percentage from File Discounts
    *  @return-A decimal/double value called account Price is returned to set on Deal Prodcut.
    */
    public Decimal getAccountPrice(DealWrapper dw) {
        Pricebook_Entry_Period__c pbep = getProductDatedPricebookEntryPeriod(dw);
        return getAccountPrice(dw, pbep);
    }
    
    
    /** Defect#4554 : Discription - method used to get file discount on click of refresh prices button on deal
     * @name-getFileDiscount
     * @param-deal wrapper is passed as parameter to other method  to get the fiel discount.
     * @return- decimal value called file discount for deal product
     */
     public Decimal getFileDiscount(DealWrapper dw){
         Pricebook_Entry_Period__c pbep = getProductDatedPricebookEntryPeriod(dw);
         return getFileDiscountPercentage(dw, pbep);
     }
     
    /**
    *  Description-Method used to calculate account price for a deal product based on the list price and its file discount
    *  @name-getAccountPrice
    *  @param-dw Deal Wrapper is passed as parameter to other methods to get the list Price and the Discount Percentage from File Discounts
    *  @param- pbep Pricebook Entry Period instance for calculating Account Price
    *  @return-A decimal/double value called account Price is returned to set on Deal Prodcut.
    */
    public Decimal getAccountPrice(DealWrapper dw, Pricebook_Entry_Period__c pbep) {
        Decimal listPrice = pbep!=null?pbep.List_Price__c:null;
        Decimal accountPrice = pbep!=null?pbep.Account_Price__c:null;
        if(accountPrice == null) {
            listPrice = listPrice == null ? 0 : listPrice;
            Decimal fileDisc = getFileDiscountPercentage(dw, pbep);
            fileDisc = fileDisc == null ? 0 : fileDisc;
            accountPrice = listPrice * (1-(fileDisc/100));
        }
        return accountPrice;
    }

    /**
    *  @Description- Method used to pass appropriate parameters to getFileDiscountPercentage method which identifies the applicable File Discounts
    *  @Description-  
    *  @name-getFileDiscountPercentage
    *  @param-Deal Wrapper - The parameter is passed to other method to get root level account and is used to get the account associated to deal from the collection created by other method in class
    *  @param-Pricebook_Entry_Period__c - This parameter is used to fetch Material Price Group for file discount calculation
    */
    public Decimal getFileDiscountPercentage(DealWrapper dw, Pricebook_Entry_Period__c pbep) {
        Account acc = mapAllAccountWithFDs.get(dw.accountId);
        Product2 prod = mapProductDetails.get(dw.productId);
        Date startDt = dw.dealStartDate;
        Decimal fileDiscPerc;

        Account rootAcc = getRootLevelAccuont(acc);
        // First check the priority promotion on rootLevel account
        fileDiscPerc = getFileDiscountPercentage(rootAcc, prod, startDt, true, pbep);
        if(fileDiscPerc == null) {
            fileDiscPerc = getFileDiscountPercentage(acc, prod, startDt, false, pbep);
        }

        fileDiscPerc = (fileDiscPerc== null ? 0 : fileDiscPerc);
        return fileDiscPerc;
    }

    /**
    *  Description-Method identifies the top level account in hierarchy
    *  @name-getRootLevelAccuont
    *  @param-The directly associated account to the deal is fetched and passed as parater to the method
    *  @return-The Top level account in hierachy associated to the Deal indirectly is identified and returned 
    */
    private Account getRootLevelAccuont(Account a) {
        if(a!= null && a.ParentId != null) {
            if(mapAllAccountWithFDs.containsKey(a.ParentId)) {
                a =  mapAllAccountWithFDs.get(a.ParentId);
                return getRootLevelAccuont(a);
            }
        }
        
        return a;
    }
    
    /**
    *  Description-Method return the applicable Discount Percent after multiple criteria comparisons
    *  @name-getFileDiscountPercentage
    *  @param-Account-The top level account in hierarchy is passed
    *  @param-Product-The Product having information about Product like Product Type,Format etc and the list price from Price Book Entry Period of Product
    *  @param-startDt-Deal/Opportunity Start Date
    *  @param-priorityCheck-Boolean flag true means that the File Discounts is associated to Account which has the Priority Promotions flag as True.
    *  @return-Decimal/Double Discount Percentage value is returned.
    */
    public Decimal getFileDiscountPercentage(Account acc, Product2 prd, Date startDt, Boolean priorityCheck, Pricebook_Entry_Period__c pbep) {
        Decimal fileDiscPerc;
        // check file discount for the current level account
        if(acc != null && prd != null && acc.File_Discounts__r != null) {
            String priceGroup = pbep != null && pbep.Material_Price_Group__c != null ? pbep.Material_Price_Group__c : prd.Product_Price_Group__c;
            for(File_Discount__c fd : acc.File_Discounts__r) {
                if(!priorityCheck || fd.Priority_Promotion__c == true) {
                    //Comparing File Discount's Format and Type with Product Type and Format of Product being added as Deal Product
                    if(fd.Product_Type__c == priceGroup && fd.Format__c == prd.Product_Format__c && fd.Start_Date__c <= startDt && startDt <= fd.End_Date__c ) {
                        fileDiscPerc = fd.Discount_Percent__c;
                        break;
                    }
                }
            }
        }
        
        // priority check will be only perform for top level account and that too for PriorityPromotion calculation
        if(!priorityCheck) {
            // if file discount not found, get the same from the account at level above in hierarchy. 
            if(fileDiscPerc == null && acc != null && acc.ParentId != null && mapAllAccountWithFDs.containsKey(acc.ParentId)) {
                acc = mapAllAccountWithFDs.get(acc.ParentId);
                fileDiscPerc = getFileDiscountPercentage(acc, prd, startDt, false, pbep);
            }
        }
        
        return fileDiscPerc;
    }
    
    /**
    *  Description-Method prepares a collection of Products and List Price fetched from Price Book Entry Period
    *  @name-getProductDatedListPrice
    *  @param-Deal Wrapper 
    *  @return-productListPrice-After the required comparisons are made the applicable List Price for a Product is returned
    */
    public Decimal getProductDatedListPrice(DealWrapper dw) {
        String mapRecKey = dw.productId + '-'+ dw.pricebookId + '-' + dw.dealCurrency;
            
        Decimal productListPrice = 0;
        if(mapDatedPricebookEntries.containsKey(mapRecKey)) {
            for(Pricebook_Entry_Period__c pbep : mapDatedPricebookEntries.get(mapRecKey)){
                //Comparing dates of Price Book Entry Period with that of Deal Start Date
                
                if(pbep.Start_Date__c <= dw.dealEndDate && pbep.End_Date__c >= dw.dealStartDate  && pbep.List_Price__c != null) {
                    productListPrice = pbep.List_Price__c;
                    break;
                }
            } 
        }
        return productListPrice;
    }
     
    /**
    *  Description-Method fetches the Price Book Entry Period's for the respective Products where the Currency and PriceBook matches with that of Deal
    *  @name-initializePricebookEntryPeriodData
    */
    private void initializePricebookEntryPeriodData() {
        mapDatedPricebookEntries = new Map<String,Pricebook_Entry_Period__c[]>();
        mapProductDetails = new Map<Id,Product2>();
        
        for(Pricebook_Entry_Period__c pbep : [select Id, Price_Book__c, Product__c, Product__r.Product_Price_Group__c ,Product__r.Product_Format__c, Product__r.Product_Type__c, CurrencyISOCode, Start_Date__c, End_Date__c, List_Price__c, Client_Avail__r.Local_Data_Category_Picklist__c,
                            Minimum_Price__c,Account_Price__c,Retail_Price__c, Material_Price_Group__c, SR_Price__c,Vendor_ID__c //#768 Suggested_Price__c, //US#895 -commneted code as a part of us to remove reference of suggested price
                            from Pricebook_Entry_Period__c
                            where Price_Book__c != null and Product__c != null and 
                                Price_Book__c IN: setPricebookIds and Product__c IN: setProductsIds and CurrencyISOCode IN: setCurrencyCodes 
                            order by Price_Book__c, Product__c, CurrencyISOCode, Start_Date__c, CreatedDate]) {
                                
            //Unique Key with combination of Product,PriceBook and CurrencyISO Code is  created to get limited matching records
            String mapRecKey = pbep.Product__c + '-'+ pbep.Price_Book__c + '-' + pbep.CurrencyISOCode;
            if(!mapDatedPricebookEntries.containsKey(mapRecKey)){
                mapDatedPricebookEntries.put(mapRecKey, new Pricebook_Entry_Period__c[]{});
            }
            
            mapProductDetails.put(pbep.Product__c, pbep.Product__r);
            mapDatedPricebookEntries.get(mapRecKey).add(pbep);
        }
    }
    
   
    
    /**
    *  Description-Wrapper to store the Deal and DealProduct information
    *  @name-DealWrapper 
    */
    public class DealWrapper {
        public Id dealId;
        public Id accountId;
        public String dealCurrency;
        public Id productId;
        public Id pricebookId;
        public Date dealStartDate;
        public Date dealEndDate;
        public Id dealRecordTypeId;
        public Id assoertmentRTId; 
         
        // Optional to provide
        public OpportunityLineItem dealProduct;
        
        public Bundle_Product__c bundleProduct;
        
        //Optional to provide
        public OrderItem orderProduct;

    }
    
    //US#33 - Neha
    /**
    *  Description-Method fetches the Price Book Entry Period's for the respective Products where the Currency and PriceBook matches with that of Deal
    *  @name-getProductDatedPricebookEntry
    *  @param-Deal Wrapper 
    *  @return-productPricebookEntryPeriod-After the required comparisons are made the applicable Pricebook Entry Period for a Product is returned
    */
    public Pricebook_Entry_Period__c getProductDatedPricebookEntryPeriod(DealWrapper dw) {
        String mapRecKey = dw.productId + '-'+ dw.pricebookId + '-' + dw.dealCurrency;
        Pricebook_Entry_Period__c productPricebookEntryPeriod;
        if(mapDatedPricebookEntries.containsKey(mapRecKey)) {
            for(Pricebook_Entry_Period__c pbep : mapDatedPricebookEntries.get(mapRecKey)){
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
    //US#33 - Neha
    
    
}