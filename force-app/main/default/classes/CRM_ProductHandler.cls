global with sharing class CRM_ProductHandler{
    Public static boolean isFuture = false;
    public static void updateProdctType(Map<Id,Product2> mapOldProducts, List<Product2> lstNewProducts){
        if(mapOldProducts == null || mapOldProducts.size() == 0) {
               assignProductType(lstNewProducts);
        } 
        else {
            List<Product2> listImpactedProducts = new List<Product2>();
            
            for(Product2 newProd : lstNewProducts) {
            system.debug('new --- '+newProd.RecordTypeId);
            system.debug('old --- '+mapOldProducts.get(newProd.Id).RecordTypeId);
            system.debug('new --- '+newProd.Local_Title__c);
            system.debug('old -- '+mapOldProducts.get(newProd.Id).Local_Title__c);
                if((newProd.RecordTypeId != mapOldProducts.get(newProd.Id).RecordTypeId) || (newProd.Local_Title__c != mapOldProducts.get(newProd.Id).Local_Title__c) 
                    || (newProd.SAP_Material_Type__c != mapOldProducts.get(newProd.Id).SAP_Material_Type__c)) {
                    listImpactedProducts.add(newProd);
                }
            }
            
            if(!listImpactedProducts.isEmpty()){
                assignProductType(listImpactedProducts);
            }
        }        
    }
    
    public static void assignProductType(List<Product2> lstNewProducts){
    
    for(Product2 prod : lstNewProducts){
            
        if(CRM_AppConstants.CRM_ProductRecordTypes.contains(prod.RecordTypeId)){
                
            if((prod.Country_Code__c == CRM_AppConstants.JAPAN_COUNTRY_CODE) && (prod.Tittle_Content_Type__c == CRM_AppConstants.MUSIC_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == null)){
                    prod.Type__c = CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE;
            }
                else if((prod.Tittle_Content_Type__c != CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == null)) {
                         prod.Type__c = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
                }  
                    else if((prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) && (prod.Tittle_Content_Type__c == CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == null )){
                             prod.Type__c = CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE;
                    }
                        else if(prod.SAP_Material_Type__c == CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE && prod.Tittle_Content_Type__c == CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE){
                                 prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                                 prod.Type__c = CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE;
                        }
                            else if((prod.Country_Code__c == CRM_AppConstants.JAPAN_COUNTRY_CODE) && prod.SAP_Material_Type__c == CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE && prod.Tittle_Content_Type__c == CRM_AppConstants.MUSIC_TITTLE_CONTENT_TYPE){
                                prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                                prod.Type__c = CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE;
                            }
                                else if((prod.Tittle_Content_Type__c == CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == CRM_AppConstants.FERT_SAP_MATERIAL_TYPE)){
                                         prod.Type__c = CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE ;
                                }
                                    else if((prod.Country_Code__c == CRM_AppConstants.JAPAN_COUNTRY_CODE) && (prod.Tittle_Content_Type__c == CRM_AppConstants.MUSIC_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == CRM_AppConstants.FERT_SAP_MATERIAL_TYPE)){
                                        prod.Type__c = CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE;
                                    }
                                        else if((prod.Tittle_Content_Type__c != CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == CRM_AppConstants.FERT_SAP_MATERIAL_TYPE)){
                                            prod.Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
                                        }
                                            else if((prod.Tittle_Content_Type__c != CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE) && (prod.SAP_Material_Type__c == CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE)){
                                                prod.Type__c = CRM_AppConstants.SBOM_PRODUCT_TYPE;
                                            }
                                                else if(prod.SAP_Material_Type__c == CRM_AppConstants.UNBW_SAP_MATERIAL_TYPE){
                                                        prod.Type__c = CRM_AppConstants.UNBW_PRODUCT_TYPE;
                                                }
            }
        }
    }
    
    /**
     *  @Description - Req. #393 (FR): Update Product Material Type if there is a associated BOM.
     *         -  
     *  @name - updateProdctMaterialType
     *  @param - mapOldProducts - Map of Product2 Old values
     *  @param - lstNewProducts - list of Product2 new values
     *  @return - void
     **/ 
    public static void updateProdctMaterialType(Map<Id,Product2> mapOldProducts, List<Product2> lstNewProducts){
        // Map to hold Product2 where SAP_Material_Type__c has changed.  
        Map<Id, Product2> mapImpactedProducts = new Map<Id, Product2>();
      
        for(Product2 product : lstNewProducts) {
            // Populating mapImpactedProducts
            //Defect: #3580. Product Pack Type should be Multi Pack. 
            if(CRM_AppConstants.CRM_ProductRecordTypes.contains(product.RecordTypeId) && product.SAP_Material_Type__c != mapOldProducts.get(product.Id).SAP_Material_Type__c && product.Pack_Type__c == CRM_AppConstants.PRODUCT_PACK_TYPE_MultiPack) {
                mapImpactedProducts.put(product.Id, product);
            }
        }

        if(!mapImpactedProducts.isEmpty()) {
            //Get BOM records related to Product2 where SAP_Material_Type__c has changed. 
            for(BOM__c bomRec : [Select Id, Parent_Product__c From BOM__c where Parent_Product__c IN:mapImpactedProducts.keySet() ]){
                //Logic to check if a Product is associated to a BOM
                if(mapImpactedProducts.containskey(bomRec.Parent_Product__c)) {
                    mapImpactedProducts.get(bomRec.Parent_Product__c).SAP_Material_Type__c = CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE;
                }
            }
        }
    }
    
    /**
     *  @Description - Defect 3438 (FR): Insert PBEP for SBOM or UNBW products.
     *  @name - insertPBEP
     *  @param - mapOldProducts - Map of Product2 Old values
     *  @param - lstNewProducts - list of Product2 new values
     *  @return - void
     **/ 
    public static void insertPBEP(Map<Id,Product2> mapOldProducts,List<Product2> lstNewProducts){
        // Map to hold Product2 where SAP_Material_Type__c is UNBW   
        Map<Id, Product2> mapImpactedProducts = new Map<Id, Product2>();
        Map<Id, Product2> mapImpactedUKProducts = new Map<Id, Product2>();
        Map<String, Id> mapSalesOrgPriceBook = new Map<String, Id>();     
        //Map<String, list<Id>> mapSalesOrgListPriceBooks = new Map<String, list<Id>>();
        set<String> setDefaultPricingKey = new set<String>();
          
        for(Product2 product : lstNewProducts) {
            
            if(CRM_AppConstants.CRM_ProductRecordTypes.contains(product.RecordTypeId)){
                
                system.debug('*In UK PBEP creation block***11'+product.Exclusive_Product_Flag__c + product.SAP_Sales_Org__c + product.Product_Format__c + product.Franchise_Type__c + 
                         product.SAP_Sales_Org__c + product.Type__c);

                // Populating mapImpactedProducts 
                if((mapOldProducts == null) && (product.SAP_Material_Type__c == CRM_AppConstants.UNBW_SAP_MATERIAL_TYPE)){
                  mapImpactedProducts.put(product.Id, product);
                  if(product.SAP_Sales_Org__c != null && product.SAP_Distribution_Id__c != null){
                      mapSalesOrgPriceBook.put(product.SAP_Sales_Org__c+'-'+product.SAP_Distribution_Id__c, null);
                      system.debug('*##***');
                  }
                }
    
                //#US 450 - Start
                else if(product.Exclusive_Product_Flag__c == false && product.SAP_Sales_Org__c != null && product.Product_Format__c != null && product.Franchise_Type__c != null 
                             && product.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_UK_CODE && (product.Type__c == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE || product.Type__c == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE)
                             && ((product.UK_List_Price_EUR__c != null && product.EUR_Price_Book_Entry_Period_Created__c == false)
                                    || (product.UK_List_Price_GBP__c != null && product.GBP_Price_Book_Entry_Period_Created__c == false))){
                    mapImpactedUKProducts.put(product.Id, product);
                    if(product.UK_List_Price_EUR__c != null && product.EUR_Price_Book_Entry_Period_Created__c == false){
                        setDefaultPricingKey.add(product.Product_Format__c+product.Franchise_Type__c+'EUR');
                    }
                    if(product.UK_List_Price_GBP__c != null && product.GBP_Price_Book_Entry_Period_Created__c == false){
                        setDefaultPricingKey.add(product.Product_Format__c+product.Franchise_Type__c+'GBP');
                    }
                    system.debug('*In UK PBEP creation block***');
                }
                //#US 450 - End
            }
        }
          
        if(mapImpactedProducts != null && mapImpactedProducts.size() > 0){
            mapInsertPBEPAndPBE(mapImpactedProducts,mapSalesOrgPriceBook);
        }
          
        //#US 450 - Start
        if(mapImpactedUKProducts != null && mapImpactedUKProducts.size() > 0){
            identifyListPrice(setDefaultPricingKey,mapImpactedUKProducts);
        }
        //#US 450 - End
          
      }
      
      
     /**
     *  @Description - US 450 : Fetch Default pricing for the newly inserted UK products
     *  @name - fetchDefaultPricingRecords
     *  @param - mapKeyDefaultPricing - Map of unique key and there defauly pricing records.
     *  @return - void
     **/ 
    public static Map<String, Default_Pricing__c> fetchDefaultPricingRecords(set<String> setDefaultPricingKey){
        
        List<Default_Pricing__c> defaultPricingList = new List<Default_Pricing__c>();
        Map<String, Default_Pricing__c> mapKeydefaultPricingRec = new Map<String, Default_Pricing__c>();
        
        if(setDefaultPricingKey.size() > 0){
              defaultPricingList = [Select Id,Default_Price__c,Price_Book__c,Format__c,Franchise_Type__c,Unique_Identifier__c 
                                        from Default_Pricing__c where Price_Book__c != null and Price_Book__r.Business_Unit__c =: CRM_AppConstants.TERRITORY_UK_CODE and Price_Book__r.IsActive = true and 
                                           Unique_Identifier__c in: setDefaultPricingKey order by createddate];
        }
          
        for(Default_Pricing__c defaultPricingRec : defaultPricingList){
            if(defaultPricingRec.Price_Book__c != null){
                mapKeydefaultPricingRec.put(defaultPricingRec.Unique_Identifier__c+defaultPricingRec.Price_Book__c,defaultPricingRec);
            }
        }
        
        return mapKeydefaultPricingRec;
          
    }
    
    /**
     *  @Description - US 450 : Fetch all active UK PriceBooks
     *  @name - fetchActiveUKPriceBooks
     *  @param - void
     *  @return - List<PriceBook2>
     **/ 
    public static Map<String,Set<Id>> fetchActiveUKPriceBooks(){
        
        List<Account> accList = new List<Account>();
        accList = [Select Id,CurrencyIsoCode,Price_Book__c,Video_Physical__c,Games_Physical__c from Account where (Video_Physical__c = true or Games_Physical__c = true) 
                        and Price_Book__r.Business_Unit__c =: CRM_AppConstants.TERRITORY_UK_CODE and Price_Book__r.IsActive = true];
        
        Map<String,Set<Id>> mapTypePriceBookIdList = new Map<String,Set<Id>>();
        Set<Id> videoPhysicalEURPBIds = new Set<Id>();
        Set<Id> gamesPhysicalEURPBIds = new Set<Id>();
        Set<Id> videoPhysicalGBPPBIds = new Set<Id>();
        Set<Id> gamesPhysicalGBPPBIds = new Set<Id>();
        
        for(Account acc : accList){
            if(acc.Video_Physical__c == true){
                if(acc.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                    videoPhysicalEURPBIds.add(acc.Price_Book__c);
                }
                else if(acc.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                    videoPhysicalGBPPBIds.add(acc.Price_Book__c);
                }
            }
            if(acc.Games_Physical__c == true){
                 if(acc.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                    gamesPhysicalEURPBIds.add(acc.Price_Book__c);
                }
                else if(acc.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                    gamesPhysicalGBPPBIds.add(acc.Price_Book__c);
                }
            }
        }
        
        mapTypePriceBookIdList.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.EUR_CURRENCY_CODE, videoPhysicalEURPBIds);
        mapTypePriceBookIdList.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.GBP_CURRENCY_CODE, videoPhysicalGBPPBIds);
        mapTypePriceBookIdList.put(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.EUR_CURRENCY_CODE, gamesPhysicalEURPBIds);
        mapTypePriceBookIdList.put(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE+CRM_AppConstants.GBP_CURRENCY_CODE, gamesPhysicalGBPPBIds);

        return mapTypePriceBookIdList;
    }
    
    /**
     *  @Description - US 450 : Logic to identify the List Price
     *  @name - identifyListPrice
     *  @param - set<String> setDefaultPricingKey
     *  @return - void
     **/ 
    public static void identifyListPrice(set<String> setDefaultPricingKey, Map<Id, Product2> mapImpactedUKProducts){
        
        Map<String, Default_Pricing__c> mapKeydefaultPricingRec = fetchDefaultPricingRecords(setDefaultPricingKey);
        Map<String,Set<Id>> mapTypePriceBookIdList = fetchActiveUKPriceBooks();
        List<Pricebook_Entry_Period__c> insertListPBEP = new List<Pricebook_Entry_Period__c>();
        Boolean updateProdGBP;
        Boolean updateProdEUR;
        Set<Id> prodUpdateSetEUR = new Set<Id>();
        Set<Id> prodUpdateSetGBP = new Set<Id>();
        
        Date startdate = date.newInstance(system.today().year(), 1, 1);
        Date enddate = date.newInstance(2100, 12, 31);
        
        for(Product2 prod : mapImpactedUKProducts.values()){
            updateProdGBP = false;
            updateProdEUR = false;
            if(prod.UK_List_Price_EUR__c != null && prod.EUR_Price_Book_Entry_Period_Created__c == false){
                for(Id pricebookId : mapTypePriceBookIdList.get(prod.Type__c+CRM_AppConstants.EUR_CURRENCY_CODE)){
                
                    Decimal listPrice = 0, accountPrice;
                    String key = prod.Product_Format__c + prod.Franchise_Type__c + CRM_AppConstants.EUR_CURRENCY_CODE + pricebookId;
                    Pricebook_Entry_Period__c pbepInstance = new Pricebook_Entry_Period__c();
                    
                    // Default Pricing Check key : TEXT(Format__c) & TEXT(Franchise_Type__c) & TEXT(CurrencyIsoCode) + Price_Book__c
                    
                    /*
                    Ankita : Commented the code so as to check if Default Pricing exists for the Price book if yes then copy Default price to Account Price 
                             of PBEP and List Price will be always copied from Product. Earlier Default price was copied in List Price now it will be account price.
                    if(mapKeydefaultPricingRec.containsKey(key)){
                        Default_Pricing__c defaultPricingRec = mapKeydefaultPricingRec.get(key);
                        listPrice = defaultPricingRec.Default_Price__c != null ? defaultPricingRec.Default_Price__c : 0;
                        pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate, CRM_AppConstants.EUR_CURRENCY_CODE);
                        insertListPBEP.add(pbepInstance);
                        //prod.EUR_Price_Book_Entry_Period_Created__c = true;
                        updateProdEUR = true;
                    }
                    else{
                        listPrice = prod.UK_List_Price_EUR__c;
                        pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate, CRM_AppConstants.EUR_CURRENCY_CODE);
                        insertListPBEP.add(pbepInstance);
                        //prod.EUR_Price_Book_Entry_Period_Created__c = true;
                        updateProdEUR = true;
                    }*/
                    if(mapKeydefaultPricingRec.containsKey(key)){
                        Default_Pricing__c defaultPricingRec = mapKeydefaultPricingRec.get(key);
                        accountPrice = defaultPricingRec.Default_Price__c != null ? defaultPricingRec.Default_Price__c : null; 
                    }
                    listPrice = prod.UK_List_Price_EUR__c;
                    pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate, CRM_AppConstants.EUR_CURRENCY_CODE);
                    insertListPBEP.add(pbepInstance);
                    updateProdEUR = true;
                }
                if(updateProdEUR){
                    prodUpdateSetEUR.add(prod.Id);
                }
            }
            if(prod.UK_List_Price_GBP__c != null && prod.GBP_Price_Book_Entry_Period_Created__c == false){
                for(Id pricebookId : mapTypePriceBookIdList.get(prod.Type__c+CRM_AppConstants.GBP_CURRENCY_CODE)){
                
                    Decimal listPrice = 0, accountPrice ;
                    String key = prod.Product_Format__c + prod.Franchise_Type__c + CRM_AppConstants.GBP_CURRENCY_CODE + pricebookId;
                    Pricebook_Entry_Period__c pbepInstance = new Pricebook_Entry_Period__c();
                    
                    // Default Pricing Check key : TEXT(Format__c) & TEXT(Franchise_Type__c) & TEXT(CurrencyIsoCode) + Price_Book__c
                       
                  /*  
                   Ankita : Commented the code so as to check if Default Pricing exists for the Price book if yes then copy Default price to Account Price 
                             of PBEP and List Price will be always copied from Product. Earlier Default price was copied in List Price now it will be account price.
                    if(mapKeydefaultPricingRec.containsKey(key)){
                        Default_Pricing__c defaultPricingRec = mapKeydefaultPricingRec.get(key);
                        listPrice = defaultPricingRec.Default_Price__c != null ? defaultPricingRec.Default_Price__c : 0;
                        pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate,CRM_AppConstants.GBP_CURRENCY_CODE);
                        insertListPBEP.add(pbepInstance);
                        //prod.GBP_Price_Book_Entry_Period_Created__c = true;
                        updateProdGBP = true;
                    }
                     else{
                        listPrice = prod.UK_List_Price_GBP__c;
                        pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate,CRM_AppConstants.GBP_CURRENCY_CODE);
                        insertListPBEP.add(pbepInstance);
                        //prod.GBP_Price_Book_Entry_Period_Created__c = true;
                        updateProdGBP = true;
                    }*/
                    if(mapKeydefaultPricingRec.containsKey(key)){
                        Default_Pricing__c defaultPricingRec = mapKeydefaultPricingRec.get(key);
                        accountPrice = defaultPricingRec.Default_Price__c != null ? defaultPricingRec.Default_Price__c : null;
                    }  
                    listPrice = prod.UK_List_Price_GBP__c;
                    pbepInstance = mapPBEPFields(prod, pricebookId, listPrice, accountPrice, startdate, enddate,CRM_AppConstants.GBP_CURRENCY_CODE);
                    insertListPBEP.add(pbepInstance);
                    updateProdGBP = true;
                }
                if(updateProdGBP){
                    prodUpdateSetGBP.add(prod.Id);
                }
            }
        }
        
        if(insertListPBEP != null && insertListPBEP.size() > 0){
            isFuture = true;
            insertPBEP(insertListPBEP);
        }
        system.debug('test prodUpdateSetEUR'+prodUpdateSetEUR );    
        if(prodUpdateSetEUR != null && prodUpdateSetEUR.size() > 0){
            updateProdFuture(false,prodUpdateSetEUR);
        }
        system.debug('test prodUpdateSetGBP'+prodUpdateSetGBP );    
        if(prodUpdateSetGBP != null && prodUpdateSetGBP.size() > 0){
            updateProdFuture(true,prodUpdateSetGBP);
        }
    }
    
    /**
     *  @Description - US 450 : Insert PBEP records
     *  @name - insertPBEP
     *  @param - List<Pricebook_Entry_Period__c>
     *  @return - void
     **/ 
    public static void insertPBEP(List<Pricebook_Entry_Period__c> insertListPBEP){
        
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        List<Pricebook_Entry_Period__c> successListPBEP = new List<Pricebook_Entry_Period__c>();
        Database.SaveResult[] saveResultList =  Database.insert(insertListPBEP,false);
            
            for(Integer i=0; i < saveResultList.size(); i++ ){
                if(!saveResultList[i].isSuccess()){

                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(saveResultList[i].getErrors(), saveResultList[i].getId(), 'Error while inserting PBEP for : Product =' + string.valueOf(insertListPBEP[i].Id));
                    errorLogs.addAll(errorLogInstance); 
                } 
                else{
                    successListPBEP.add(insertListPBEP[i]);
                }
            }
            
        CRM_ErrorLogger.logError(errorLogs); 
        CRM_PBEPHandler pbepHandlerInstance = new CRM_PBEPHandler();
        CRM_Default_Configuration__c setting = CRM_Default_Configuration__c.getOrgDefaults();
        if(setting.Informatica_User_Id__c != null && (Id)(setting.Informatica_User_Id__c) == UserInfo.getUserId() && successListPBEP != null && successListPBEP.size() > 0 ){
            pbepHandlerInstance.createPBENTRYForNewPBEPeriod(successListPBEP);
        }
        system.debug('End of insertion PBEP');
    }
    
    /**
     *  @Description - US 450 : Map PBEP fields
     *  @name - mapPBEPFields
     *  @param - Product2 prod, Id pricebookId, Decimal listPrice, Date startdate, Date myEnddate
     *  @return - Pricebook_Entry_Period__c
     **/ 
    public static Pricebook_Entry_Period__c mapPBEPFields(Product2 prod, Id pricebookId, Decimal listPrice, Decimal accountPrice, Date startdate, Date enddate, String currencyCode){       
        Pricebook_Entry_Period__c pbepInstance = new Pricebook_Entry_Period__c(); 
        pbepInstance.Price_Book__c = pricebookId;
        pbepInstance.List_Price__c = listPrice;
        pbepInstance.Account_Price__c = accountPrice;
        pbepInstance.Product__c = prod.Id;
        pbepInstance.End_Date__c = enddate;
        pbepInstance.Start_Date__c = startdate;
        pbepInstance.CurrencyIsoCode = currencyCode; 
        return pbepInstance;
    }
    
    /**
     *  @Description - US 450 : Update Product pbep created checkboxes
     *  @name - updateProdFuture
     *  @param - List<Product2>
     *  @return - void
     **/ 
    @Future
    public static void updateProdFuture(Boolean isGBP, Set<Id> prodUpdateSet){
        
        isFuture = true;
        system.debug('test prodUpdateSet'+prodUpdateSet );
        system.debug('test isGBP'+isGBP );
        
        List<Product2> updateProdList = new List<Product2>();
        if(isGBP){
            updateProdList = [Select Id,GBP_Price_Book_Entry_Period_Created__c from Product2 where Id in:prodUpdateSet];
            for(Product2 prodInst : updateProdList){
                prodInst.GBP_Price_Book_Entry_Period_Created__c = true;
            }
        }
        else{
            updateProdList = [Select Id,EUR_Price_Book_Entry_Period_Created__c from Product2 where Id in:prodUpdateSet];
            for(Product2 prodInst : updateProdList){
                prodInst.EUR_Price_Book_Entry_Period_Created__c = true;
            }
        }
        system.debug('test updateProdList'+updateProdList );

        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        Database.SaveResult[] saveResultList =  Database.update(updateProdList,false);
            
            for(Integer i=0; i < saveResultList.size(); i++ ){
                if(!saveResultList[i].isSuccess()){

                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(saveResultList[i].getErrors(), saveResultList[i].getId(), 'Error while updating the Product =' + string.valueOf(updateProdList[i].Id));
                    errorLogs.addAll(errorLogInstance); 
                } 
            }
        system.debug('test errorLogs'+errorLogs );    
        CRM_ErrorLogger.logError(errorLogs);
    }
    
     /**
     *  @Description - US : 480 (JAPAN): The Product Market field (sell through or rental) should not be change once a type of product is added
     *  @name - restrictToModifyProductMarket
     *  @param - mapOldProducts - Map of Product2 Old values
     *  @param - lstNewProducts - list of Product2 new values
     *  @return - void
     **/ 
     public static void restrictToModifyProductMarket(Map<Id,Product2> mapOldProducts, List<Product2> lstNewProducts){
         //Product Market Value set ( 1 --> RENTAL , 2 --> SELL THROUGH)
         Set<String> productMarkets = new Set<String>{'1','2'}; 
         Set<Id> productIds = new Set<Id>();
         
         //Preper Set Of ProductIds Which have (OLd and New)Product Market equal to 'RENTAL' OR 'SELL THROUGH'
         for(Product2 prod : lstNewProducts){
             if(CRM_AppConstants.CRM_ProductRecordTypes.contains(prod.RecordTypeId) && prod.Product_Market__c != mapOldProducts.get(prod.Id).Product_Market__c && 
               (productMarkets.contains(prod.Product_Market__c) || productMarkets.contains(mapOldProducts.get(prod.Id).Product_Market__c))){
                    productIds.add(prod.Id); 
             }
             
             //Requirement#479 : Update Release Category  = 'New Release' for NR Product having Is NR Product flag true.
             /*if(prod.Is_NR_Product__c && prod.Release_Category__c != mapOldProducts.get(prod.Id).Release_Category__c && 
                prod.Release_Category__c == CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG && 
                mapOldProducts.get(prod.Id).Release_Category__c == CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE &&
                prod.Country_Code__c == CRM_AppConstants.FRANCE_COUNTRY_CODE){
                    prod.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
                    prod.Product_Price_Group__c  = CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE;
             }*/
         }
         
         if(productIds.size() > 0){
         
             //Get Deal Products related to above products
             List<OpportunityLineItem> oppLIList = [SELECT Id
                                                    FROM OpportunityLineItem
                                                    WHERE Product2Id IN :productIds AND Opportunity.Market_Type__c != null AND
                                                    Opportunity.Sales_Organisation__c =: CRM_AppConstants.TERRITORY_JAPAN_CODE AND 
                                                    Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL];
                                                    
             //If Product assigned to deal then throw Validation Error
             if(oppLIList.size() > 0){
                 lstNewProducts[0].addError(System.Label.CRM_Restrict_Modification_of_Product_Market);
             }  
         }
     }

     /**
     *  @Description - Defect 3438 (FR): Insert PBEP for SBOM or UNBW products.
     *  @name - mapInsertPBEPAndPBE
     *  @param - mapImpactedProducts - Map of Product2 impacted values
     *  @return - void
     **/ 
    public static void mapInsertPBEPAndPBE(Map<Id,Product2> mapImpactedProducts,Map<String, Id> mapSalesOrgPriceBook){
          
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        date myStartdate ;
        date myEnddate ;
        system.debug('*#mapImpactedProducts#***'+mapImpactedProducts);
        if(mapSalesOrgPriceBook.size() > 0){
            priceBookList = [Select Id,External_Id__c from PriceBook2 where External_Id__c in: mapSalesOrgPriceBook.keySet()];
        }
          
        for(PriceBook2 pb : priceBookList){
              
            if(pb.External_Id__c != null && mapSalesOrgPriceBook.containskey(pb.External_Id__c)){
                mapSalesOrgPriceBook.put(pb.External_Id__c,pb.Id);
            }
        }
          
        if(!mapImpactedProducts.isEmpty() && priceBookList.size() > 0) {
            //Generate PBEP for related Product2 where SAP_Material_Type__c is SBOM or UNBW. 
            List<Pricebook_Entry_Period__c> insertListPBEP = new List<Pricebook_Entry_Period__c>();
            Pricebook_Entry_Period__c newPBEP;
                    
            CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance();
            if(defaultConfiguration.PBEP_Start_Date__c != null){
                myStartdate = defaultConfiguration.PBEP_Start_Date__c;
            }
            else{
                myStartdate = system.today() - 1;
            }
            if(defaultConfiguration.PBEP_End_Date__c != null){
                myEnddate = defaultConfiguration.PBEP_End_Date__c;
            } 
            else{
                myEnddate = system.today();
            }
            
            for(Product2 prod : mapImpactedProducts.values()){
                String priceBookKey = null;
                if(prod.SAP_Sales_Org__c != null && prod.SAP_Distribution_Id__c != null){
                   priceBookKey = prod.SAP_Sales_Org__c+'-'+prod.SAP_Distribution_Id__c;
                }
             
              //pbep mappings 
              if(priceBookKey != null && mapSalesOrgPriceBook.containskey(priceBookKey) && mapSalesOrgPriceBook.get(priceBookKey) != null){
                  newPBEP = new Pricebook_Entry_Period__c();
                 
                  newPBEP.Price_Book__c = mapSalesOrgPriceBook.get(priceBookKey);
                  newPBEP.Account_Price__c = 0;
                  newPBEP.List_Price__c = 0;
                  newPBEP.Minimum_Price__c = 0;
                  //newPBEP.Suggested_Price__c = 0;
                  newPBEP.Product__c = prod.Id;
                  newPBEP.End_Date__c = myEnddate;
                  newPBEP.Start_Date__c = myStartdate;
                  newPBEP.CurrencyIsoCode = prod.CurrencyIsoCode;
                  insertListPBEP.add(newPBEP);
              }
            }
            try{
                if(insertListPBEP.size() > 0){
                    List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
                    List<Pricebook_Entry_Period__c> successListPBEP = new List<Pricebook_Entry_Period__c>();
                    Database.SaveResult[] saveResultList =  Database.insert(insertListPBEP,false);
                    
                    for(Integer i=0; i < saveResultList.size(); i++ ){
                        if(!saveResultList[i].isSuccess()){
        
                            List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(saveResultList[i].getErrors(), saveResultList[i].getId(), 'Error while inserting PBEP for : Product =' + string.valueOf(insertListPBEP[i].Id));
                            errorLogs.addAll(errorLogInstance); 
                        } 
                        else{
                            successListPBEP.add(insertListPBEP[i]);
                        }
                    }
                
                    CRM_ErrorLogger.logError(errorLogs); 
                    CRM_PBEPHandler pbepHandlerInstance = new CRM_PBEPHandler();
                    CRM_Default_Configuration__c setting = CRM_Default_Configuration__c.getOrgDefaults();
                    pbepHandlerInstance.createPBENTRYForNewPBEPeriod(successListPBEP);
                    system.debug('End of insertion PBEP');
                }
            }
            catch(Exception e){
                logAnException(e,null);
                system.debug('Error message in insertion of PBEP :'+e.getmessage());
            }
            
        }
    }
     /**
     *  Added by  - Tushar Mudgal
     *  @Description - US#304 (Update product group on Product)
     *  @name - updateProductGroupOnProduct
     *  @param - 
     *  @return - void
     **/ 
     public static List<Product2> updateProductGroupOnProduct(List<Product2> lstProduct){
        List<CRM_Product_Group_Update__c> csAllValues = CRM_Product_Group_Update__c.getAll().values();
        Map<String, CRM_Product_Group_Update__c> mapCType = new Map<String, CRM_Product_Group_Update__c>();
        ProductGroupRule[] productGroupAssignmentRules = new ProductGroupRule[]{};
        Map<ID,Local_Title__c> mapLocalTile;
        List<Product2> lstProductToUpdate = new List<Product2>();
         
        for(CRM_Product_Group_Update__c csValues : csAllValues){
            String countryTypeKey = '^';
            countryTypeKey += csValues.Country__c + '-' +  csValues.Type__c;
            countryTypeKey += '-'+(csValues.Format__c != null ? csValues.Format__c : '(.*)');
            countryTypeKey += '-'+(csValues.Franchise__c != null ? csValues.Franchise__c : '(.*)');
            countryTypeKey += '-'+(csValues.Content_Type__c != null ? csValues.Content_Type__c : '(.*)');
            countryTypeKey += '-'+(csValues.Product_Genre__c != null ? csValues.Product_Genre__c : '(.*)');
            countryTypeKey += '-'+(csValues.Product_Label__c != null ? csValues.Product_Label__c : '(.*)');
            countryTypeKey += '-'+(csValues.Product_owner__c != null ? csValues.Product_owner__c : '(.*)');        //--W-017601 Added sales org to create key for JV project--//
            countryTypeKey += '-'+(csValues.Product_Market_Entry__c != null ? csValues.Product_Market_Entry__c : '(.*)');        //--W-017601 Added sales org to create key for JV project--//
            countryTypeKey += '-'+(csValues.Product_Market__c != null ? csValues.Product_Market__c : '(.*)');
            countryTypeKey += '-'+(csValues.Product_Price_Group__c != null ? csValues.Product_Price_Group__c : '(.*)');
            countryTypeKey += '-'+(csValues.Special_Version__c != null ? csValues.Special_Version__c : '(.*)');
            countryTypeKey += '-'+(csValues.Display_Label__c != null ? csValues.Display_Label__c : '(.*)');
            countryTypeKey += '-'+(csValues.Sales_Org__c != null ? csValues.Sales_Org__c : '(.*)');        //--W-017601 Added sales org to create key for JV project--//
            countryTypeKey += '$'; 
            mapCType.put(countryTypeKey,csValues);
            
            productGroupAssignmentRules.add(new ProductGroupRule(countryTypeKey,csValues));
            system.debug('countryTypeKey : '+countryTypeKey);
        }
        
        if(!productGroupAssignmentRules.isEmpty())
            productGroupAssignmentRules.sort();
        
        system.debug('mapCType::::::::'+mapCType);
        mapLocalTile = new Map<ID,Local_Title__c>();   // Map of Local Title ID and Local Title List
        for(Product2 objProd:lstProduct){
            if(CRM_AppConstants.CRM_ProductRecordTypes.contains(objProd.RecordTypeId)){
                mapLocalTile.put(objProd.Local_Title__c,null);
            }
        }
        
        if(!mapLocalTile.KeySet().isEmpty()){
            mapLocalTile = new Map<ID,Local_Title__c>(    //Query to fetch Local Title list using above map.keySet() 
                          [Select Id,Country_Code2__c,Title__r.Content_Type__c
                           FROM Local_Title__c
                           WHERE Id IN : mapLocalTile.KeySet()
                          ]); 
        }
        
        if(mapLocalTile != Null)
        {               
            for(Product2 prod:lstProduct){
                        
                Local_Title__c localTitleObj = mapLocalTile.get(prod.Local_Title__c);  
                    
                if(localTitleObj!=Null){
                    //Key creation from Local Title and Product Type
                    string productKey = localTitleObj.Country_Code2__c +'-'+prod.Type__c 
                                        + '-' + prod.Product_Format__c + '-' + prod.Franchise_Type__c
                                        + '-' + localTitleObj.Title__r.Content_Type__c 
                                        + '-' + prod.Product_Genre__c ;
                                        //Ankita starts JV Product Group having additional label
                                        if(prod.Product_Label__c != null && prod.Product_Label__c != '' && 
                                                (prod.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_SDS_US_CODE || prod.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_SDS_CANADA_CODE)){
                                            if(prod.Product_Label__c.contains(System.Label.CRMJV_VIZ_Product_Label)){
                                                productKey += '-' +System.Label.CRMJV_VIZ_Product_Label;
                                            }else if(prod.Product_Label__c.contains(System.Label.CRMJV_BBC_Product_Label)){
                                                productKey += '-' +System.Label.CRMJV_BBC_Product_Label;
                                            }else if(prod.Product_Label__c.contains(System.Label.CRMJV_HBO_Product_Label)){
                                                productKey += '-' +System.Label.CRMJV_HBO_Product_Label;
                                            }else{
                                                productKey += '-' + prod.Product_Label__c;
                                            }
                                        }else{
                                            productKey += '-' + prod.Product_Label__c;
                                        }
                                        //Ankita ends JV Product Group having additional label
                                        productKey += '-' + prod.Product_owner__c +'-' +  prod.Product_market_entry__c + '-'+prod.Product_Market__c        //--W-017601 Added sales org to create key for JV project--//
                                        + '-' + prod.Product_Price_Group__c + '-' + prod.Special_Version__c + '-' + prod.Display_Studio__c
                                        + '-' + prod.SAP_Sales_Org__c;        //--W-017601 Added sales org to create key for JV project--//
                    
                    system.debug('Product Key ===>>>'+ productKey);
                   
                    for(ProductGroupRule pgAssignmentRule : productGroupAssignmentRules){
                        Pattern regexPattern = Pattern.compile(pgAssignmentRule.ruleKey);
                        Matcher regexMatcher = regexPattern.matcher(productKey);
                       // system.debug('regexMatcher'+regexMatcher+'---'+regexMatcher.matches());
                        
                        if(regexMatcher.matches()){
                            CRM_Product_Group_Update__c rule = pgAssignmentRule.rule;
                            system.debug('After this to update==>>'+rule.ID__c);
                            prod.Product_Group__c = rule.ID__c;
                            //CRM_ProductHandler.isFuture = true;
                            prod.Process_Product_Group__c = false;
                            lstProductToUpdate.add(prod); 
                            break;
                        }
                    }
                    /*if(null != mapCType && mapCType.containsKey(productKey)){
                        system.debug('Inside this to update==>>');
                        prod.Product_Group__c = mapCType.get(productKey).ID__c;
                        system.debug('After this to update==>>');
                    }else
                        prod.Product_Group__c =null;*/
                }
            }
        }
        return lstProductToUpdate;
    } 
        
        /**
        *  @Description - Method to collect the product where 'Delete_Product__c' flag is true to delete the product.       
        *  @name - deleteProducts
        *  @return nothing
        *  @defect 3676 
        */
       /* public static void deleteProducts(Map<Id,Product2> mapOldProducts,List<Product2> lstNewProducts){
            set<Id> productIdsToDelete = new set<Id>();
            
            for(Product2 product : lstNewProducts){
                system.debug('values :-->'+product.Delete_Product__c+'Old map value -->'+mapOldProducts.get(product.id).Delete_Product__c);
                if(product.Delete_Product__c != mapOldProducts.get(product.id).Delete_Product__c && product.Delete_Product__c == true){
                    system.debug('Inside block');
                    productIdsToDelete.add(Product.id);
                }   
            }
            system.debug('size of list-->'+productIdsToDelete.size());
            if(productIdsToDelete.size() > 0){//!productIdsToDelete.isEmpty()
                system.debug('inside method call');
                deleteFlagedProductsFuture(productIdsToDelete);
            }
        }
        */
        /**
        *  @Description - Method to delete flaged products from SFDC when deleted from informatica.      
        *  @name - deleteFlagedProducts
        *  @return nothing
        *  @defect 3676 
        */
       /* @future(callout=true)
        public static void deleteFlagedProductsFuture(set<Id> productIds){
            List<Product2> lstProductsToDelete = new List<Product2>();
            
            for(Id prodId : productIds){
                Product2 Product = new Product2(Id=prodId);
                lstProductsToDelete.add(Product);
            }
            
            if(lstProductsToDelete.size() > 0){
                try{
                     delete lstProductsToDelete;
                }
                catch(Exception e){
                     logAnException(e, null);
                }
            }   
        }
        */
        /*
        *  This method will take the exception occured as an input and forward it to the common utility class. 
        *  @name: logAnException
        *  @param: Exception ex
        *  @return: void 
        */
        public static void logAnException(Exception ex, Id recordId){
            CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
            if (recordId != null){
                errorLogInstance.recordId = recordId;
            }
            // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
            errorLogInstance.functionalModule = 'CRM_ProductHandler';
            errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
            errorLogInstance.errorMessage = ex.getMessage();
            errorLogInstance.stackTrace = ex.getStackTraceString();
    
            // Call the logError method which will insert all errors into CRM_Error_Log__c object
            CRM_ErrorLogger.logError(errorLogInstance);     
        }
        
        /**
        *  @description: This method will take the exception occured as an input and forward it to the common utility class. 
        *  @name: logAnException
        *  @param: Exception ex
        *  @return: void 
        */
        public static List<CRM_ErrorLogger.ErrorLog> logAnException(List<Database.Error> errors, Id recordId, String entityName){
    
            List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = new list<CRM_ErrorLogger.ErrorLog>();
            CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
            
            for(Database.Error err : errors){
              errorLogInstance = errorLogging(err,recordId,entityName);
              errorLogInstanceList.add(errorLogInstance);
            }
            return errorLogInstanceList;
        }
        
        /**
    *  @description: This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public static CRM_ErrorLogger.ErrorLog errorLogging(Database.Error errorInstance, Id recordId, String entityName){
        String lineNumber = '';
        String errorMessage = '';
        String statusCode = '';
        
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        
        if (recordId != null) {
            errorLogInstance.recordId = recordId;
        }
        
        errorLogInstance.functionalModule = 'PBEP creation for UK products';
        errorLogInstance.className = 'CRM_ProductHandler';
        
        statusCode += ' Error Code: ' + String.valueOf(errorInstance.getStatusCode());
        errorMessage += ' Error Message: ' + errorInstance.getMessage() + ' : EntityName: ' + entityName;

        errorLogInstance.lineNumber = lineNumber;
        errorLogInstance.errorMessage = errorMessage.left(200);
        errorLogInstance.stackTrace = statusCode;
        return errorLogInstance;
    } 

    global class ProductGroupRule implements Comparable {
        public String ruleKey {get;set;}
        public CRM_Product_Group_Update__c rule {get;set;}
        
        global ProductGroupRule(String key, CRM_Product_Group_Update__c rule){
            this.rule = rule;
            this.ruleKey = key;
        }
        
        global Integer compareTo(object compareTo) {
            if(rule.Order__c == ((ProductGroupRule)compareTo).rule.Order__c){
                return 0;
            }
            else if(rule.Order__c > ((ProductGroupRule)compareTo).rule.Order__c){
                return 1;
            }
            
            return -1;
        }
    } 
}