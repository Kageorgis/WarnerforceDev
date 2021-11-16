/**
*  @Author Cognizant
*  @name CRM_InsertPBEPOnProductListPriceBatch
*  @CreateDate 12 Jan 2017
*  @Description This batch class will automate the creation of PricebookEntryPeriod based on EUR /GBP list Price on Product
*  @Version <1.0>
*  @reference Requirement no 562
*/
    
global class CRM_InsertPBEPOnProductListPriceBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    public Map<Id,List<Pricebook_Entry_Period__c>> mapProductToPbepIds = new Map<Id,List<Pricebook_Entry_Period__c>>();
    public Map<Id, Product2> mapImpactedUKProducts = new Map<Id, Product2>();
    global final List<CRM_InsertPBEPOnProductListPriceBatchException> lstExceptions =
        new List<CRM_InsertPBEPOnProductListPriceBatchException>(); 
    public String queryString='';
    
    /**
    * Start method of batch process which will process Product related to the latest created account.
    */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        queryString = 'SELECT CurrencyIsoCode,Id,IsActive,Pricebook2.Id,Pricebook2.International__c,Product2.International_Product__c,Product2.Type__c, '+ 
                                                'Product2.Id,Product2.UK_List_Price_EUR__c, Product2.Name, '+
                                                'Product2.EUR_Price_Book_Entry_Period_Created__c, '+         
                                                'Product2.UK_List_Price_GBP__c,Product2.Franchise_Type__c, '+
                                                'Product2.GBP_Price_Book_Entry_Period_Created__c, '+
                                                'Product2.Product_Format__c,UnitPrice '+
                                                'FROM PricebookEntry '+
                                                'WHERE Product2.Exclusive_Product_Flag__c = false '+
                                                    ' AND Product2.Product_Format__c != null '+
                                                    ' AND Product2.Street_Date__c > Today '+
                                                    ' AND Product2.Franchise_Type__c != null '+
                                                    ' AND Product2.SAP_Sales_Org__c = \''+ CRM_AppConstants.TERRITORY_UK_CODE +'\'' +
                                                    ' AND (Product2.Type__c = \''+ CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE +'\'' +
                                                    ' OR Product2.Type__c = \''+ CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE+'\')' +
                                                    ' AND (Product2.EUR_Price_Book_Entry_Period_Created__c = false OR Product2.GBP_Price_Book_Entry_Period_Created__c = false)'+
                                                    ' AND UnitPrice > 0 ';
        if(Test.isRunningTest()){
            queryString +=  ' AND Pricebook2Id = \'' + Test.getStandardPricebookId()+'\'';
        } else {
            queryString +=' AND Pricebook2.IsStandard =true '+ 
                          ' ORDER BY Product2.id';
        } 
        system.debug('queryString .....'+queryString);                                            
        return Database.getQueryLocator(queryString); 
    }
    
    /*Execute method to process the Products */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
       
        Set<String> setDefaultPricingKey = new Set<String>();
        List<PricebookEntry> lstScopePricebookEntries = (List<PricebookEntry>)scope;
        Map<Id,List<PricebookEntry>> mapProductToPbEntries = new Map<Id,List<PricebookEntry>>();
        system.debug('lstScopePricebookEntries' + lstScopePricebookEntries);
        
        for(PricebookEntry pbEntryRec :lstScopePricebookEntries){
            mapImpactedUKProducts.put(pbEntryRec.Product2.Id, pbEntryRec.Product2);
            if(mapProductToPbEntries.containsKey(pbEntryRec.Product2.Id)){
                mapProductToPbEntries.get(pbEntryRec.Product2.Id).add(pbEntryRec);
            }else{
                mapProductToPbEntries.put(pbEntryRec.Product2.Id,new List<PricebookEntry>{pbEntryRec});
            } 
            // Generate unique key of Product_Format__c + Franchise_Type__c + Currency Code GBP/EUR for Fetching DEFAULT PRICING
            if(pbEntryRec.Product2.EUR_Price_Book_Entry_Period_Created__c == false){
                setDefaultPricingKey.add(pbEntryRec.Product2.Product_Format__c + pbEntryRec.Product2.Franchise_Type__c + CRM_AppConstants.EUR_CURRENCY_CODE);
            }
            if(pbEntryRec.Product2.GBP_Price_Book_Entry_Period_Created__c == false){
                setDefaultPricingKey.add(pbEntryRec.Product2.Product_Format__c + pbEntryRec.Product2.Franchise_Type__c + CRM_AppConstants.GBP_CURRENCY_CODE);
            }
        }
        // Identify the List Price for the product and set the PBEP fields
        if(!mapImpactedUKProducts.isEmpty()){
            identifyListPrice(setDefaultPricingKey,mapImpactedUKProducts,mapProductToPbEntries);
        }
    } 
    
    /**
     *  @Description - US 562 : Logic to identify the List Price
     *  @name - identifyListPrice
     *  @param - set<String> setDefaultPricingKey, Map<Id, Product2> mapImpactedUKProducts
     *  @return - void
    **/ 
    @TestVisible
    private void identifyListPrice(set<String> setDefaultPricingKey, Map<Id, Product2> mapImpactedUKProducts ,Map<Id,List<PricebookEntry>> mapProductToPbEntries){
       
        List<Pricebook_Entry_Period__c> lstPBEPToInsert = new List<Pricebook_Entry_Period__c>();
        // Fetch Default Pricing records with the unique identifier   
        Map<String, Default_Pricing__c> mapKeydefaultPricingRec = fetchDefaultPricingRecords(setDefaultPricingKey);
        // Fetch all active UK PriceBook records 
        
        Map<String,Map<Id,Boolean>> mapTypePriceBookIdList = fetchActiveUKPriceBooks();   
        List<PricebookEntry> lstPricebookEntry = new  List<PricebookEntry>();
        for(Product2 prod : mapImpactedUKProducts.values()){
            if(mapProductToPbEntries.containsKey(prod.id)){
               lstPricebookEntry = mapProductToPbEntries.get(prod.id);
            }
            //Check if List Price for EUR exists for the product then look over the Price books
            for(PricebookEntry pbeRec : lstPricebookEntry ){
                if(prod.EUR_Price_Book_Entry_Period_Created__c == false && pbeRec.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE ){
                    if(mapTypePriceBookIdList.containskey(prod.Type__c+CRM_AppConstants.EUR_CURRENCY_CODE )){
                        Map<Id,Boolean> mapPricebookToInternational = mapTypePriceBookIdList.get(prod.Type__c+CRM_AppConstants.EUR_CURRENCY_CODE);
                        for(Id pricebookId : mapPricebookToInternational.keySet()){
                           if((prod.International_Product__c && mapPricebookToInternational.get(pricebookId)) 
                            || (!prod.International_Product__c && !mapPricebookToInternational.get(pricebookId))){
                                Pricebook_Entry_Period__c pbepInstance =  createPBEPInstance(prod,pricebookId,pbeRec.UnitPrice,mapKeydefaultPricingRec,CRM_AppConstants.EUR_CURRENCY_CODE);
                                lstPBEPToInsert.add(pbepInstance);  
                            }
                        }
                    }
                }
                 //Check if List Price for GBP exists for the product then look over the Price books
                if(prod.GBP_Price_Book_Entry_Period_Created__c == false && pbeRec.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE ){
                    if(mapTypePriceBookIdList.containskey(prod.Type__c+CRM_AppConstants.GBP_CURRENCY_CODE)){
                        Map<Id,Boolean> mapPricebookToInternational = mapTypePriceBookIdList.get(prod.Type__c+CRM_AppConstants.GBP_CURRENCY_CODE);
                        for(Id pricebookId : mapPricebookToInternational.keySet()){
                            if((prod.International_Product__c && mapPricebookToInternational.get(pricebookId)) 
                            || (!prod.International_Product__c && !mapPricebookToInternational.get(pricebookId))){
                                Pricebook_Entry_Period__c pbepInstance =  createPBEPInstance(prod,pricebookId,pbeRec.UnitPrice,mapKeydefaultPricingRec,CRM_AppConstants.GBP_CURRENCY_CODE);
                                lstPBEPToInsert.add(pbepInstance); 
                            }
                        }
                    }
                }
            }
              system.debug('lstPBEPToInsert::::::::'+lstPBEPToInsert);
        }
        if(!lstPBEPToInsert.isEmpty()){ 
            insertPBEP(lstPBEPToInsert);
        } 
    }
    
    /**
     *  @Description - US 562 : Fetch Default pricing for the newly inserted UK products
     *  @name - mapPBEPListPriceGBPOrEUR
     *  @param - Product2 prod, Id pricebookId,Decimal pbeListPrice, String currencyCodeGBPOrEUR
     *  @return - void
    **/
    @TestVisible
    private Pricebook_Entry_Period__c createPBEPInstance(Product2 prod, Id pricebookId, Decimal pbeListPrice, Map<String, Default_Pricing__c> mapKeydefaultPricingRec, String currencyCodeGBPOrEUR){
        //Set the Start date and End date as per the detail design under Req 450
        Decimal listPrice = 0, accountPrice ;
        Date startdate = date.newInstance(system.today().year(), 1, 1);
        Date enddate = date.newInstance(2100, 12, 31);
        String key = prod.Product_Format__c + prod.Franchise_Type__c + currencyCodeGBPOrEUR + pricebookId; 
        Pricebook_Entry_Period__c pbepInstance = new Pricebook_Entry_Period__c(); 
        // Check if Default Pricing exists for the Product then set the account price.
        if(mapKeydefaultPricingRec.containsKey(key)){
            Default_Pricing__c defaultPricingRec = mapKeydefaultPricingRec.get(key);
            accountPrice = defaultPricingRec.Default_Price__c != null ? defaultPricingRec.Default_Price__c : null;
        }  
        //Set the list price of PBEP from the Product GBP List Price
        listPrice = pbeListPrice;
        pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate,currencyCodeGBPOrEUR); 
        return pbepInstance;
    }
    
    /**
     *  @Description - US 562 : Map PBEP fields
     *  @name - mapPBEPFields
     *  @param - Product2 prod, Id pricebookId, Decimal listPrice, Date startdate, Date myEnddate
     *  @return - Pricebook_Entry_Period__c
    **/ 
    @TestVisible
    private static Pricebook_Entry_Period__c mapPBEPFields(Product2 prod, Id pricebookId, Decimal listPrice, Decimal accountPrice, Date startdate, Date enddate, String currencyCode){       
        Pricebook_Entry_Period__c pbepInstance = new Pricebook_Entry_Period__c(); 
        pbepInstance.Price_Book__c = pricebookId;
        pbepInstance.List_Price__c = listPrice;
        pbepInstance.Account_Price__c = accountPrice;
        pbepInstance.Product__c =  prod.Id;
        pbepInstance.End_Date__c = enddate;
        pbepInstance.Start_Date__c = startdate;
        pbepInstance.CurrencyIsoCode = currencyCode; 
        return pbepInstance;
    } 
    
    /**
     *  @Description - US 562 : Fetch Default pricing for the newly inserted UK products
     *  @name - fetchDefaultPricingRecords
     *  @param - mapKeyDefaultPricing - Map of unique key and there defauly pricing records.
     *  @return - void
    **/ 
    @TestVisible
    private static Map<String, Default_Pricing__c> fetchDefaultPricingRecords(set<String> setDefaultPricingKey){
        
        List<Default_Pricing__c> defaultPricingList = new List<Default_Pricing__c>();
        Map<String, Default_Pricing__c> mapKeydefaultPricingRec = new Map<String, Default_Pricing__c>();
        
        if(setDefaultPricingKey.size() > 0){
              defaultPricingList = [SELECT Id,Default_Price__c,Price_Book__c,Format__c,
                                            Franchise_Type__c,Unique_Identifier__c 
                                            FROM Default_Pricing__c 
                                            WHERE Price_Book__c != null 
                                            AND Price_Book__r.Business_Unit__c =: CRM_AppConstants.TERRITORY_UK_CODE 
                                            AND Price_Book__r.IsActive = true 
                                            AND Unique_Identifier__c in: setDefaultPricingKey 
                                            ORDER BY createddate];
        } 
        for(Default_Pricing__c defaultPricingRec : defaultPricingList){
            if(defaultPricingRec.Price_Book__c != null){
                mapKeydefaultPricingRec.put(defaultPricingRec.Unique_Identifier__c + defaultPricingRec.Price_Book__c,defaultPricingRec);
            }
        }
        return mapKeydefaultPricingRec;
    }
    
     /**
     *  @Description - US 562 : Fetch all active UK PriceBooks
     *  @name - fetchActiveUKPriceBooks
     *  @param - void
     *  @return - List<PriceBook2>
     **/ 
    @TestVisible
    private static Map<String,map<Id,Boolean>> fetchActiveUKPriceBooks(){
        
        map<Id,Boolean> mapVideoPhysicalEURPBIdsToInter = new  map<Id,Boolean>();
        map<Id,Boolean> mapGamesPhysicalEURPBIdsToInter = new  map<Id,Boolean>();
        map<Id,Boolean> mapVideoPhysicalGBPPBIdsToInter = new  map<Id,Boolean>();
        map<Id,Boolean> mapGamesPhysicalGBPPBIdsToInter = new  map<Id,Boolean>();
        
        //defect#4769 - Added a filter at the end of query to stop creating prices for WHV UK (UK) as these will be created by SAP-> Informatica-> Salesforce-PBEP
        List<Account> accList = [SELECT Id,CurrencyIsoCode,Price_Book__c,Price_Book__r.International__c,Video_Physical__c,Games_Physical__c, Price_Book__r.Name
                        FROM Account 
                            WHERE (Video_Physical__c = true or Games_Physical__c = true) 
                            AND Price_Book__r.Business_Unit__c =: CRM_AppConstants.TERRITORY_UK_CODE 
                            AND Price_Book__r.IsActive = true
                            AND Price_Book__r.Name != 'WHV UK (UK)'];
        
        //Map<String,Set<Id>> mapTypePriceBookIdList = new Map<String,Set<Id>>();
        Map<String,map<Id,Boolean>> mapTypePriceBookIdList = new Map<String,map<Id,Boolean>>();
        Set<Id> videoPhysicalEURPBIds = new Set<Id>();
        Set<Id> gamesPhysicalEURPBIds = new Set<Id>();
        Set<Id> videoPhysicalGBPPBIds = new Set<Id>();
        Set<Id> gamesPhysicalGBPPBIds = new Set<Id>();
        
        for(Account acc : accList){
            if(acc.Video_Physical__c == true){
                if(acc.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                   mapVideoPhysicalEURPBIdsToInter.put(acc.Price_Book__c,acc.Price_Book__r.International__c);
                }else if(acc.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                   mapVideoPhysicalGBPPBIdsToInter.put(acc.Price_Book__c,acc.Price_Book__r.International__c);
                }
            }
            if(acc.Games_Physical__c == true){
                if(acc.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                    mapGamesPhysicalEURPBIdsToInter.put(acc.Price_Book__c,acc.Price_Book__r.International__c);
                }else if(acc.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                    mapGamesPhysicalGBPPBIdsToInter.put(acc.Price_Book__c,acc.Price_Book__r.International__c);
                }
            }
        }
        
        mapTypePriceBookIdList.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.EUR_CURRENCY_CODE, mapVideoPhysicalEURPBIdsToInter);
        mapTypePriceBookIdList.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.GBP_CURRENCY_CODE, mapVideoPhysicalGBPPBIdsToInter);
        mapTypePriceBookIdList.put(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.EUR_CURRENCY_CODE, mapGamesPhysicalEURPBIdsToInter);
        mapTypePriceBookIdList.put(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.GBP_CURRENCY_CODE, mapGamesPhysicalGBPPBIdsToInter);
        
        return mapTypePriceBookIdList;
    }
    
    /**
     *  @Description - US 562 : Insert PBEP records
     *  @name - insertPBEP
     *  @param - List<Pricebook_Entry_Period__c>
     *  @return - void
    **/ 
    @TestVisible  
    private void insertPBEP(List<Pricebook_Entry_Period__c> insertListPBEP){
        
        List<Pricebook_Entry_Period__c> successListPBEP = new List<Pricebook_Entry_Period__c>(); 
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Database.SaveResult[] saveResultList =  Database.insert(insertListPBEP,false); 
        
        for(Integer i=0; i < saveResultList.size(); i++ ){
            List<String> lstErrors = new List<String>();
            Pricebook_Entry_Period__c pbepRec = insertListPBEP[i];
            Database.SaveResult saveResultInstance = saveResultList[i];
            if(!saveResultInstance.isSuccess()){ 
                for(Database.Error err : saveResultInstance.getErrors()) {
                    lstErrors.add(err.getMessage());
                    // Save the error in database
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.recordId = pbepRec.Product__c;
                    errorLog.functionalModule = 'Insert PBEP for Product with Standard Price';
                    errorLog.errorMessage = err.getMessage().left(200);
                    listErrorLog.add(errorLog);
                }
                lstExceptions.add(new CRM_InsertPBEPOnProductListPriceBatchException( insertListPBEP[i].Product__c, lstErrors));
            } 
            else{
                successListPBEP.add(insertListPBEP[i]); 
                if(mapProductToPbepIds.containsKey(pbepRec.Product__c)){
                    mapProductToPbepIds.get(pbepRec.Product__c).add(pbepRec); 
                }else{
                    mapProductToPbepIds.put(pbepRec.Product__c,new List<Pricebook_Entry_Period__c>{pbepRec});
                }
            } 
        } 
        CRM_ErrorLogger.logError(listErrorLog); 
        CRM_PBEPHandler pbepHandlerInstance = new CRM_PBEPHandler();
        CRM_Default_Configuration__c setting = CRM_Default_Configuration__c.getOrgDefaults();
        if(setting.Informatica_User_Id__c != null && (Id)(setting.Informatica_User_Id__c) == UserInfo.getUserId() && successListPBEP != null && successListPBEP.size() > 0 ){
            pbepHandlerInstance.createPBENTRYForNewPBEPeriod(successListPBEP);
        } 
    }   
        
    /**
    * Finish method of batch process.
    */ 
    global void finish(Database.BatchableContext BC){ 
        List<Product2> productListToUpdate =[SELECT Id,EUR_Price_Book_Entry_Period_Created__c,
                                                    GBP_Price_Book_Entry_Period_Created__c 
                                                FROM Product2
                                                WHERE Id IN: mapProductToPbepIds.keySet()];
        if(!productListToUpdate.isEmpty())
        {
           for(Product2 prod : productListToUpdate){
                List<Pricebook_Entry_Period__c> lstPBEPEntries = mapProductToPbepIds.get(prod.Id);
                for(Pricebook_Entry_Period__c pbepRecord : lstPBEPEntries){
                    if(pbepRecord.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE && prod.EUR_Price_Book_Entry_Period_Created__c == false){
                        prod.EUR_Price_Book_Entry_Period_Created__c = true;  
                    }
                    if(pbepRecord.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE && prod.GBP_Price_Book_Entry_Period_Created__c == false){
                        prod.GBP_Price_Book_Entry_Period_Created__c = true;
                    }
                }
           }
           updateProductsForSuccessfulPbep(productListToUpdate); 
        }
        sendMail();
    }
    
    /**
     *  @Description - US 562 : Update Product pbep created checkboxes
     *  @name - updateProdFuture
     *  @param - List<Product2>
     *  @return - void
     **/ 
     @TestVisible
     private void updateProductsForSuccessfulPbep(List<Product2> updateProdList){

        List<String> lstErrors = new List<String>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();

        Database.SaveResult[] saveResultList =  Database.update(updateProdList,false);      
         for(Integer i=0; i < saveResultList.size(); i++ ){
            Product2 prodRec = updateProdList[i];
            if(!saveResultList[i].isSuccess()){
                 Database.SaveResult saveResultInstance = saveResultList[i];
                 for(Database.Error err : saveResultInstance.getErrors()) {
                    lstErrors.add(err.getMessage());

                    // Save the error in database
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.recordId = prodRec.Id;
                    errorLog.functionalModule = 'Insert PBEP for Product with Standard Price';
                    errorLog.errorMessage = err.getMessage().left(200);
                    listErrorLog.add(errorLog);
                } 
             lstExceptions.add(new CRM_InsertPBEPOnProductListPriceBatchException( prodRec.Id, lstErrors)); 
            } 
        }  
        CRM_ErrorLogger.logError(listErrorLog);
    }
    
    /**
     * @Description - Method to send mail to logged in User for all the details of processed / non processed products
     * @name sendMail
     */
    private void sendMail() {

        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        //Get emailIds from Custom setting
        sendTo = BatchStatusNotification.getBatchNotificationRecipients(CRM_AppConstants.Entity_CRM);
        if(!sendTo.isEmpty()) {
            mail.setToAddresses(sendTo);
        }

        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName('Insert PBEP On Product List Price Batch');

        // Step 4. Set email contents - you can use variables!
        mail.setSubject('Failure list of Products with Standard PriceBooks not processed');

        String body = '';
        body = '<html>';
        body += '<body>';
        if(!lstExceptions.isEmpty()){
            body += '<table border = 1>';
            body += '<tr>';
            body += '<th>' + 'Products' + '</th>';
            body += '<th>' + 'Failure Messages' + '</th>';
            body += '</tr>';
            System.debug('---this.lstExceptions------>'+lstExceptions);
            for (CRM_InsertPBEPOnProductListPriceBatchException excp : lstExceptions) {
                System.debug('---excp------>'+excp);
                body += '<tr>';
                if(excp.recordId != null){
                    if (this.mapImpactedUKProducts.containsKey(excp.recordId) && this.mapImpactedUKProducts.get(excp.recordId).Name != null) {
                       body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + this.mapImpactedUKProducts.get(excp.recordId).Name + '</a></td>';
                    } else {
                        body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                    }
                }else{
                    body +='<td></td>';
                } 
                if(!excp.lstErrors.isEmpty()){
                body += '<td>' + excp.lstErrors[0] + '</td>';}
                body += '</tr>';
                if (excp.lstErrors.size() > 1) {
                   body += '<tr>';
                   for (Integer i = 1; i < excp.lstErrors.size(); i++) {
                        body += '<td>' + excp.lstErrors[i] + '</td>';
                   }
                   body += '</tr>';
                } 
            }
            body += '<table>';
        } else {
            body +='All records processed successfully';
        }
        body += '</body>';
        body += '</html>';
        mail.setHtmlBody(body);

        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }  
    
    /**
    * @Description - Class for Exception Handling
    * @name CRM_AutoPhysicalNRDealCreationServiceException
    */ 
    public class CRM_InsertPBEPOnProductListPriceBatchException extends Exception {
        public Id recordId;
        public List<String> lstErrors ;
        public CRM_InsertPBEPOnProductListPriceBatchException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }
}