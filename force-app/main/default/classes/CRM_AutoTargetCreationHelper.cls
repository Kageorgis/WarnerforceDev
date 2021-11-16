/***************************************************************************************************************************************************************
   @Author: Cognizant
   @name: CRM_AutoTargetCreationHelper
   @CreateDate: 14/9/2016
   @Description: This class provides the logic required to generate Plans which will create automatic Target.
   @Version: 1.0
   @reference: Requirement No. 369

***************************************************************************************************************************************************************/

public with sharing class CRM_AutoTargetCreationHelper{
  
    /*Map of Auto Target Custom Setting : Region*/
    public static Map<String,set<String>> mapOfNameRegionForAutoTarget = new Map<String,set<String>>();
    /*Map of all GL Calendar*/
    public static Map<String,List<GL_Calendar__c>> mapAllGlCalander = new Map<String,List<GL_Calendar__c>>();
    
    /*US-997: Map of all GLCalendar with key in this format: 2018-09*/
    public static Map<String,GL_Calendar__c> mapAllReleaseCalander = new Map<String,GL_Calendar__c>();
    
    
    /*Map of External Id and Country Plan*/ 
    public static Map<String,Country_Plan__c> mapCountryPlan = new Map<String,Country_Plan__c>();
    /*Map of Country plan Target and Account plan External Id and Country Plan*/ 
    public static Map<String,Country_Plan__c> mapCPTandAPExternalIdCountryPlan = new Map<String,Country_Plan__c>();
    /*Map of Product and Country Plan*/
    public static Map<Id,Country_Plan__c> mapProdCountryPlan = new Map<Id,Country_Plan__c>();
    /*Map of Country Plan and Account*/
    public static Map<Id,List<Account>> mapCountryPlanAccount = new Map<Id,List<Account>>();
    /*List of Error Log*/
    public static List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
    
    /*Set of the Product failed for error handling*/
    public static set<Id> failedProd = new set<Id>();
     /*Set of the Accounts failed for error handling*/
    public static set<Id> failedAccounts = new set<Id>();
    /*mapAllStartDateGlCalander Map (Key ==> StartDate ,Valuer = GL Calander Instence)*/
    public static Map<String,GL_Calendar__c>  mapAllStartDateGlCalander = new Map<String,GL_Calendar__c>();
    static GL_Calendar__c previousGlCalander;
    
    /** 
    *  @description: - Method is invoked from CRM_AutoTargetCreationProductInsertBatch which will process Accounts
    *  for creation of Country Plan, Country Plan Target, Account Plan and Account Plan Target and resets the Pending Country Plan Creation flag on Product.
    *  @name: helperFunctionsToBeInvokedFromProdBatch
    *  @param: List<Account> accountList - List of Accounts in the scope
    *          Map<Id, Product2> mapProductsToBeProcessed - Map of products to be processed with Pending Country Plan Creation =true.
    *  @return: void
    */
    public static set<Id> helperFunctionsToBeInvokedFromProdBatch(List<Account> accountList,Map<Id, Product2> mapProductsToBeProcessed){
        set<String> setPbepKey = new set<String>();
        set<Id> countryPlanIds = new set<Id>();
        set<Id> accountPlanIds = new set<Id>();
        //Create unique key for products to be processed
        
        try{
                setPbepKey = prepareMapWithExistingPBEP(mapProductsToBeProcessed.values());    
                //Fetch the Custom Setting for Auto Target for Region
                fetchAutoTargetCustomSettingForRegion();
                //Fetch all Gl Calendars
                fetchAllRecordsOfGLCalender();
                //Generate map of Country Plan and related Product
                fetchExistingCountryPlanAndPrepareMap(mapProductsToBeProcessed.keySet());
                //prepareProdCPMap(existingCountryPlansFetchedList);
                //insert Country Plans
                insertCountryPlanList(mapProductsToBeProcessed,accountList,setPbepKey);
                //insert Country Plan Target
                insertCountryPlanTargetList(mapProductsToBeProcessed);
                //insert Account Plan 
                insertAccountPlanList(mapProductsToBeProcessed,countryPlanIds,accountPlanIds,true);
                //insert Account Plan Target
                List<Country_Plan__c> countryPlanFetchedList = fetchCountryPlans(countryPlanIds,accountPlanIds);
                if(countryPlanFetchedList != null && countryPlanFetchedList.size() > 0){
                    List<Target__c> accountPlanTargetList = new List<Target__c>();
                    system.debug('countryPlanFetchedList'+countryPlanFetchedList);
                    accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlanFetchedList);
                    system.debug('accountPlanTargetList'+accountPlanTargetList);
                    if(accountPlanTargetList != null && accountPlanTargetList.size() > 0){
                        insertAccountPlanTarget(accountPlanTargetList,true);
                    }
                }
        }
        catch(Exception ex) {
            // Error Logging
        
            CRM_ErrorLogger.ErrorLog errlog = new CRM_ErrorLogger.ErrorLog();
            errlog.functionalModule = 'Auto Target Creation Product Batch';
            errlog.className = 'CRM_AutoTargetCreationProductInsertBatch';
            errlog.lineNumber =  String.valueOf(ex.getLineNumber());
            errlog.errorMessage = ex.getMessage();
            errlog.stackTrace = ex.getStackTraceString();
            errorLogs.add(errlog);
        }
        CRM_ErrorLogger.logError(errorLogs); 
        
        return new Set<Id>(failedProd);
    }
    
    /** 
    *  @description: - Method is invoked from CRM_AutoTargetCreationAccountInsertBatch which will process products 
    *  for creation of Account Plan and Account Plan Target or set the Pending Country Plan Creation flag on Product.
    *  @name: helperFunctionsToBeInvokedFromAccountBatch
    *  @param: List<Account> accountList - List of Accounts to be processed with Pending Account Plan Creation =true
    *          Map<Id, Product2> mapProductsToBeProcessed - Map of products to be processed.
    *  @return: void
    */
    public static set<Id> helperFunctionsToBeInvokedFromAccountBatch(List<Account> accountList,Map<Id, Product2> mapProductsToBeProcessed){
        set<Id> countryPlanIds = new set<Id>();
        set<Id> accountPlanIds = new set<Id>();
        set<String> setPbepKey = new set<String>();
        try{
                //Create unique key for products to be processed
                setPbepKey = prepareMapWithExistingPBEP(mapProductsToBeProcessed.values());
                //Generate map of Country Plan and related Product
                fetchExistingCountryPlanAndPrepareMap(mapProductsToBeProcessed.keySet());
                //Fetch the Custom Setting for Auto Target for Region
                fetchAutoTargetCustomSettingForRegion();
                //Fetch all GL Calendars
                fetchAllRecordsOfGLCalender(); 
                //Validate if CP exists or not for the Products and process accordingly
                validateDataForAccPlanCreation(accountList,mapProductsToBeProcessed,setPbepKey);
                //insert Account Plan
                insertAccountPlanList(mapProductsToBeProcessed,countryPlanIds,accountPlanIds,false);
                //insert Account Plan Target
                List<Country_Plan__c> countryPlanFetchedList = fetchCountryPlans(countryPlanIds,accountPlanIds);
                if(countryPlanFetchedList != null && countryPlanFetchedList.size() > 0){
                    List<Target__c> accountPlanTargetList = new List<Target__c>();
                    accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlanFetchedList);
                    if(accountPlanTargetList != null && accountPlanTargetList.size() > 0){
                        insertAccountPlanTarget(accountPlanTargetList,false);
                    }
                }
        }
        catch(Exception ex) {
            // Error Logging
        
            CRM_ErrorLogger.ErrorLog errlog = new CRM_ErrorLogger.ErrorLog();
            errlog.functionalModule = 'Auto Target Creation Account Batch';
            errlog.className = 'CRM_AutoTargetCreationAccInsertBatch';
            errlog.lineNumber =  String.valueOf(ex.getLineNumber());
            errlog.errorMessage = ex.getMessage();
            errlog.stackTrace = ex.getStackTraceString();
            errorLogs.add(errlog);
        }
        CRM_ErrorLogger.logError(errorLogs); 
        
        return new Set<Id>(failedAccounts);
    }
    
    /** 
    *  @description: - This method is used to check if Country Plan exists for Product then create map for of Country Plan and Product
    *  for Account Plan and Account Plan Target creation else set the Pending Country Plan Creation flag on Product to TRUE.
    *  @name: validateDataForAccPlanCreation
    *  @param: List<Account> accountList - List of Accounts with Pending_Account_Plan_Creation__c =true
    *          Map<Id, Product2> mapProductsToBeProcessed - Map of Products which have PBEP entry
    *          set<String> setPbepKey - Set of string that will hold Unique key of Product2 ,Pricebook and CurrencyISOCode
    *  @return: void
    */
    
    private static void validateDataForAccPlanCreation(List<Account> accountList, Map<Id, Product2> mapProductsToBeProcessed,set<String> setPbepKey)
    {
        Map<String,List<Account>> mapOfTypeKeyAccList = prepareMapOfTypeKeyAccList(accountList);  
        Set<String> regions = new Set<String>();
        map<id,Product2> mapOfProductToUpdate=new map<id,Product2>();
        if(mapOfNameRegionForAutoTarget.containsKey(CRM_AppConstants.Account_Plan) && mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Account_Plan) != null){
            regions = mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Account_Plan);
        }
         system.debug('In helperFunctionsToBeInvokedFromAccountBatch...........'+mapOfTypeKeyAccList+regions );
        for(Product2 productRec : mapProductsToBeProcessed.values())
        {
            if(regions.contains(productRec.Local_Title__r.Country__r.Country_Code2__c))
            {
                if(mapOfTypeKeyAccList.containsKey(productRec.Type__c)
                && (!mapProdCountryPlan.containsKey(productRec.id)) 
                && !productRec.Pending_Country_Plan_Creation__c){
                    productRec.Pending_Country_Plan_Creation__c=true;
                    mapOfProductToUpdate.put(productRec.id,productRec);
                }else{
                    prepareMapForApCreation(productRec,mapOfTypeKeyAccList,setPbepKey);
                }
            }
        }
         //Update the Products for which Country Plan creation is required
         updateProductForFlag(mapOfProductToUpdate);
    }
    
    /** 
    *  @description: - This method is used to check if Country Plan does not exist for Product then set the Pending Country Plan Creation flag on Product to TRUE and update Products.
    *  @name: updateProductForFlag
    *  @return: void
    */ 
    private static void updateProductForFlag(map<id,Product2> mapOfProductToUpdate)
    {
        //Update the Products for which Country Plan creation is required
        if (!mapOfProductToUpdate.isEmpty()) {
            Database.SaveResult[] saveResultList =  Database.update (mapOfProductToUpdate.values(),false);
            
            for(Integer i=0; i < saveResultList.size(); i++ ){
                if(!saveResultList[i].isSuccess()){

                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(saveResultList[i].getErrors(), saveResultList[i].getId(), 'Country Plan does not exists for : Product =' + string.valueOf(mapOfProductToUpdate.get(saveResultList[i].getid())));
                    errorLogs.addAll(errorLogInstance); 
                } 
            }
        } 
    } 

    /**
    *  @description: Method to retrieve the custom setting Auto Target Creation. 
    *  @name: fetchAutoTargetCustomSettingForRegion
    *  @return: Map<String,String>
    */
    public static Map<String,Set<String>> fetchAutoTargetCustomSettingForRegion(){
        //Map<String,Set<String>> mapOfNameRegionForAutoTargetLocal = new Map<String,Set<String>>();
        List<Auto_Target_Creation__c> autoCreationList = Auto_Target_Creation__c.getall().values();

        for(Auto_Target_Creation__c autoCreateRecord : autoCreationList){ 
            if(autoCreateRecord.name!=null && autoCreateRecord.region__c!=null){
                Set<String> setOfRegions = new Set<String>();
                setOfRegions.addAll(autoCreateRecord.region__c.split(','));
                mapOfNameRegionForAutoTarget.put(autoCreateRecord.name,setOfRegions);
            }
        }
        autoCreationList.clear();
        return mapOfNameRegionForAutoTarget;
    }  
    
    /** 
    *  @description: Method to retrieve records of GL calender with the specified date  
    *  @name: fetchGLCalenderForDate
    *  @param: Date releaseDate: to find the valid GL calendar for the date, US-997: Additional parameter for checking the productType
    *  @return: GL_Calendar__c 
    */
    public static GL_Calendar__c fetchGLCalenderForDate(Date releaseDate, String productType)
    {
        //Map<String,GL_Calendar__c> mapOfAllGLCalendar = CRM_AutoTargetCreationProductInsertBatch.mapAllGlCalander ;
        GL_Calendar__c glCalender = new GL_Calendar__c();
        String Key = String.Valueof(releaseDate.year());
        if(!mapAllGlCalander.isEmpty() && mapAllGlCalander.containsKey(Key)){
            for(GL_Calendar__c glCal: mapAllGlCalander.get(Key))
            {
                if(releaseDate >= glCal.Start_Date__c && releaseDate <= glCal.End_Date__c )
                {
                    //US-997 - Start
                    //Check if GL Period > Calendar Period then the Target periods should start begin from 1 Gl Period earlier
                    if((productType == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE || productType == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE) && 
                        IsGLPeriodGreaterThanCalendar(glCal.Name, releaseDate))
                    {
                        //Fetch the calendar one month prior
                        Gl_Calendar__c priorCalendar = mapAllReleaseCalander.get(Key + '-' + String.valueOf(releaseDate.month()));
                        //GL_Calendar__c priorCalendar = [select id , name, month__c, Year__c, End_Date__c  from GL_Calendar__c where month__c =: String.valueOf(releaseDate.month()) and Year__c =: Key];
                        system.debug('****priorCalendar***'+priorCalendar);
                        glCalender = priorCalendar;                                                        
                    }
                    else
                    {
                    	glCalender = glCal;
                	}
                    //US-997 - End
                    //glCalender = glCal;
            	}
        	}
        }
        system.debug('****glCalender'+glCalender);
        return  glCalender ; 
    }  
    
    /*
    US: 997
    This checks if the Gl Period is greater than the calendar period
    */
    public static Boolean IsGLPeriodGreaterThanCalendar(string glCal, Date releaseDate){
        //Check the year if its same and then check the month
        
        if(integer.valueof(glCal.substring(0,4)) == integer.Valueof(releaseDate.year())){
            return (integer.valueof(glCal.substring(5, 7)) > integer.valueof(releaseDate.month())) ? true: false;
        }
        else
        {
            //This case will happen for months that falls in december - 12
            //ex: GL Period: 2019-01 and Release Date: 24/12/2018
            return (integer.valueof(glCal.substring(0,4)) > integer.valueOf(releaseDate.year())) ? true : false;
        }
    }
    
    /** 
    *  @description:  Method to retrieve all records of GL calender
    *  @name: fetchAllRecordsOfGLCalender
    *  @return: GL_Calendar__c 
    */
    public static Map<String,List<GL_Calendar__c>> fetchAllRecordsOfGLCalender()
    {
        List<GL_Calendar__c> listOfGlCalendar=[SELECT  Name, Month__c,Year__c,Start_Date__c,End_Date__c FROM GL_Calendar__c WHERE Month__c!=NULL AND Year__c!=NULL order by createddate];
        //Map<String,Gl_Calendar__c> mapOfKeyAndGLCalender =new Map<String,Gl_Calendar__c>();
        List<GL_Calendar__c> allGlCaleders =new List<GL_Calendar__c>();
        for(GL_Calendar__c glCalender : listOfGlCalendar)
        {
            String key = String.ValueOf(glCalender.Year__c);
            
            //US:997 - Start
            String calendarKey = String.ValueOf(glCalender.Year__c) + '-' + String.ValueOf(glCalender.Month__c);
            if(!mapAllReleaseCalander.containsKey(calendarKey))
            {
                mapAllReleaseCalander.put(calendarKey,glCalender);
            }
            
            //US:997 - End
            
            
            if(!mapAllGlCalander.containsKey(key))
            { 
                mapAllGlCalander.put(key,new List<GL_Calendar__c>{glCalender});
            }else{ 
                mapAllGlCalander.get(key).add(glCalender);            
            }
            
            if(glCalender.Start_Date__c != null && glCalender.End_Date__c != null){
                //Check Start Date and End Date year are not same 
                if(glCalender.Start_Date__c.year() != glCalender.End_Date__c.year() && 
                    (glCalender.Start_Date__c.year() == (glCalender.End_Date__c.year() - 1)))
                    {
                        String lastkey = String.ValueOf(glCalender.Start_Date__c.year());
                
                        //US:997-Start
                        String lastCalendarKey = String.ValueOf(glCalender.Start_Date__c.year()) + '-' + String.ValueOf(glCalender.Start_Date__c.month());
                        if(!mapAllReleaseCalander.containsKey(lastkey)){ 
                            mapAllReleaseCalander.put(lastkey, glCalender);
                        }
                        //US:997-End
                    if(!mapAllGlCalander.containsKey(lastkey)){ 
                        mapAllGlCalander.put(lastkey,new List<GL_Calendar__c>{glCalender});
                    }else{ 
                        mapAllGlCalander.get(lastkey).add(glCalender);            
                    }
                }
            }
            
            if(glCalender.Start_Date__c != null){
                 mapAllStartDateGlCalander.put(String.valueOf(glCalender.Start_Date__c),glCalender);
            }
        }  
        return  mapAllGlCalander; 
    }
    
    /** 
    *  @description: - This method is used to generate unique key of(Product +Pricebook +CurrencyCode by identifying Products with PBEP entry.
    *  @name: prepareMapWithExistingPBEP
    *  @param: List<Product2> lstProducts - List of Products for generating the unique key.
    *  @return: set<String>
    */
    public static set<String> prepareMapWithExistingPBEP(List<Product2> lstProducts) {
        set<String> setPBEPKeyLoacal = new set<String>();
        for (Product2 productInstance : lstProducts) {
            if (productInstance.Pricebook_Entry_Periods__r != null && productInstance.Pricebook_Entry_Periods__r.size() > 0) {
                for (Pricebook_Entry_Period__c pbep : productInstance.Pricebook_Entry_Periods__r) {
                    String key = pbep.Product__c + '-' + pbep.Price_Book__c + '-' + pbep.CurrencyISOCode;
                    setPBEPKeyLoacal.add(key);
                }
            }
        }
        return setPBEPKeyLoacal;
    }
    
    /** 
    *  @description: - This method is used to insert Country Plan based on the products.
    *  @name: insertCountryPlanList
    *  @param: Map<Id, Product2> mapProductsToBeProcessed - Map of Products for whom Country Plan is to be created
              List<Account> accountList -List of Accounts to map with the product to be processed. 
              set<String> setPbepKey - Set of Unique key for Country Plan insertion.
    *  @return: void
    */ 
    public static void insertCountryPlanList(Map<Id, Product2> mapProductsToBeProcessed,List<Account> accountList,set<String> setPbepKey){
        Map<String,List<Account>> mapOfTypeKeyAccList = prepareMapOfTypeKeyAccList(accountList);
        
        generateCountryPlanList(mapProductsToBeProcessed,mapOfTypeKeyAccList,setPbepKey);
        list<Country_Plan__c> cpListLocal = new list<Country_Plan__c>();
        cpListLocal = mapCountryPlan.values();
        
        if(cpListLocal != null && cpListLocal.size() > 0){
             //Defect 3776 Changed Upsert to Insert 
             Database.SaveResult[] result = Database.Insert(mapCountryPlan.values(), false);
             
             for(Integer i=0; i < result.size(); i++ ){
                Country_Plan__c cpInstance = new Country_Plan__c();
                cpInstance = cpListLocal[i];
                
                if(!result[i].isSuccess()){
                    //CRM_AutoTargetCreationProductInsertBatch.failedProd.add(cpInstance.NR_Product__c);
                    failedProd.add(cpInstance.NR_Product__c);
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(result[i].getErrors(), result[i].getId(), 'Country Plan : Prod =' + string.valueOf(cpInstance.NR_Product__c) );
                    errorLogs.addAll(errorLogInstance);
                }
            }
        }
    }
    
    /** 
    *  @description:  This method is used to insert Country Plan by checking region and validate unique key of(Product +Pricebook +CurrencyCode) 
    *  by identifying Products with PBEP entry for Account Plan creation
    *  @name: generateCountryPlanList
    *  @param: Map<Id, Product2> mapProductsToBeProcessed - Map of Products for whom Country Plan is to be created
              List<Account> accountList -List of Accounts to map with the product to be processed. 
              set<String> setPbepKey - Set of Unique key for Country Plan insertion.
    *  @return: void
    */
    public static void generateCountryPlanList(Map<Id, Product2> mapProductsToBeProcessed,Map<String,List<Account>> mapOfTypeKeyAccList,set<String> setPbepKey) {
        if(mapOfNameRegionForAutoTarget.containsKey(CRM_AppConstants.Country_Plan) && mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Country_Plan) != null){
            set<string> regions = mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Country_Plan);
            for(Product2 prod : mapProductsToBeProcessed.values()){
                system.debug('In prod...........'+prod);
                if(regions.contains(prod.Local_Title__r.Country__r.Country_Code2__c)){
                    system.debug('In prod.Local_Title__r.Country__r.Country_Code2__c...........'+prod.Local_Title__r.Country__r.Country_Code2__c);
                    if(!mapProdCountryPlan.containsKey(prod.id)){
                        system.debug('In prod.id...........'+prod.id);
                        Country_Plan__c countryPlanInstance = new Country_Plan__c();
                        countryPlanInstance = mapCountryPlanValues(prod);
                        mapCountryPlan.put(countryPlanInstance.External_Id__c,countryPlanInstance);
                        mapProdCountryPlan.put(prod.id,countryPlanInstance);
                    }
                    prepareMapForApCreation(prod,mapOfTypeKeyAccList,setPbepKey);
                }
            } 
        }
    }
    
    /** 
    *  @description: - This method is used to map of fields of Country Plan for insertion.
    *  @name: mapCountryPlanValues
    *  @param: Product2 prod - Products for unique key creation 
    *  @return: Country_Plan__c
    */
    private static Country_Plan__c mapCountryPlanValues(Product2 productInstance) {
        Country_Plan__c countryPlan = new Country_Plan__c();
        countryPlan.Name = productInstance.Local_Title__r.Country__r.Country_Code2__c +'-' + productInstance.External_Id__c;
        countryPlan.Year__c = string.valueof(productInstance.Street_Date__c.year());
        countryPlan.NR_Product__c = productInstance.Id;
        countryPlan.External_Id__c = productInstance.External_Id__c;//productInstance.Local_Title__r.Country__r.Country_Code2__c +'-' + productInstance.External_Id__c;
        countryPlan.RecordTypeId = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE;
        countryPlan.CurrencyIsoCode = productInstance.Local_Title__r.Country__r.currencyISOCode;
        countryPlan.Country__c = productInstance.Local_Title__r.Country__r.Name;
        
        return countryPlan;
       
    }
    
    /** 
    *  @description:  This method is used to generate map of Product and related all the valid Accounts by validating unique key of(Product +Pricebook +CurrencyCode) 
    *  by identifying Products with PBEP entry for Account Plan creation
    *  @name: prepareMapForApCreation
    *  @param: Product2 prod - Products for unique key creation
              List<Account> mapOfTypeKeyAccList -List of Accounts to map with the product to be processed. 
              set<String> setPbepKey - Set of Unique key for Country Plan insertion.
    *  @return: void
    */
    private static void prepareMapForApCreation(Product2 prod,Map<String,List<Account>> mapOfTypeKeyAccList,set<String> setPbepKey){
                    
        List<Account> accountListLocal = new List<Account>();
        if(mapOfTypeKeyAccList.containsKey(prod.Type__c)){
            accountListLocal = mapOfTypeKeyAccList.get(prod.Type__c);
        }
        
        for(Account acc : accountListLocal){
            String pbepKey = prod.id + '-' + acc.Price_Book__c + '-' + prod.Local_Title__r.Country__r.CurrencyISOCode;
            if(setPbepKey.contains(pbepKey)){
                //mapCountryPlanAccount.put(prod.id,acc);
                if (mapCountryPlanAccount.containsKey(prod.id)) {
                    mapCountryPlanAccount.get(prod.id).add(acc);
                } else {
                    mapCountryPlanAccount.put(prod.id, new List<Account> {acc});
                }
            }
        } 
    } 
    
    /** 
    *  @description: This method is used to insert CountryPlanTarget for the Products to be processed.
    *  @name: insertCountryPlanTargetList
    *  @param: Map<Id, Product2> mapProductsToBeProcessed - Products to be processed.
    *  @return: void
    */ 
    
    public static void insertCountryPlanTargetList(Map<Id, Product2> mapProductsToBeProcessed){
        
        Set<String> existingExternalIds = new Set<String>();
        List<Country_Plan_Target__c> cptInsertList = new List<Country_Plan_Target__c>();
        List<Country_Plan_Target__c> countryPlanTargetList = generateCountryPlanTargetList(mapProductsToBeProcessed);
        //Defect 3776  
        fetchExistingCountryPlanTargetandPrepareMap(mapCPTandAPExternalIdCountryPlan.keySet(),existingExternalIds);
        
        for(Country_Plan_Target__c cpt : countryPlanTargetList){
            if(!existingExternalIds.contains(cpt.External_Id__c)){
                cptInsertList.add(cpt);
            }
        }
        //Defect 3776  
        system.debug('countryPlanTargetList'+countryPlanTargetList);
        system.debug('cptInsertList'+cptInsertList);
        if(cptInsertList != null && cptInsertList.size() > 0){
             //Database.UpsertResult[] result = Database.Upsert(countryPlanTargetList, Country_Plan_Target__c.External_Id__c, false);
             //Defect 3776  
             Database.SaveResult[] result = Database.insert(cptInsertList,false);
             Country_Plan_Target__c cptInstance = new Country_Plan_Target__c(); 
             Country_Plan__c cpInstance = new Country_Plan__c();
             for(Integer i=0; i < result.size(); i++ ){
                cptInstance = cptInsertList[i];
                if(mapCPTandAPExternalIdCountryPlan.containsKey(cptInstance.External_Id__c)){
                    cpInstance = mapCPTandAPExternalIdCountryPlan.get(cptInstance.External_Id__c);
                }
                
                if(!result[i].isSuccess()){
                    //CRM_AutoTargetCreationProductInsertBatch.failedProd.add(cpInstance.NR_Product__c);
                    failedProd.add(cpInstance.NR_Product__c);
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(result[i].getErrors(), result[i].getId(), 'Country Plan Target : Prod =' + string.valueOf(cpInstance.NR_Product__r.Id) );
                    errorLogs.addAll(errorLogInstance);
                }
            }
        }
    }    
    
    /** 
    *  @description: This method is used to generate the CountryPlanTargetlist for insertion by validating the Region 
    *  and the Country Plan that exist for the Products to be processed.
    *  @name: generateCountryPlanTargetList
    *  @param: Map<Id, Product2> mapProductsToBeProcessed - Products to be processed.
    *  @return: void
    */ 
    public static  List<Country_Plan_Target__c> generateCountryPlanTargetList(Map<Id, Product2> mapProductsToBeProcessed) {
        List<Country_Plan_Target__c> countryPlanTargetList = new List<Country_Plan_Target__c>();
        if(mapOfNameRegionForAutoTarget.containsKey(CRM_AppConstants.Country_Plan_Target) && mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Country_Plan_Target) != null){
            set<string> regions = mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Country_Plan_Target);
            Integer i=0;
            Country_Plan_Target__c countryPlanTargetInstance = new Country_Plan_Target__c();
            Product2 prodInstance;
            for(Country_Plan__c countryPlan : mapCountryPlan.values()){
                if(mapProductsToBeProcessed.containsKey(countryPlan.NR_Product__c)){
                    prodInstance = mapProductsToBeProcessed.get(countryPlan.NR_Product__c);
                    if(regions.contains(prodInstance.Local_Title__r.Country__r.Country_Code2__c) && countryPlan.id != null){
                        for(i=0; i<3 ;i++){
                            countryPlanTargetInstance = new Country_Plan_Target__c();
                            countryPlanTargetInstance = mapCountryPlanTargetValues(prodInstance,countryPlan,i);
                            if(countryPlanTargetInstance != null && countryPlanTargetInstance.External_Id__c != null){
                                countryPlanTargetList.add(countryPlanTargetInstance);
                                mapCPTandAPExternalIdCountryPlan.put(countryPlanTargetInstance.External_Id__c,countryPlan);
                            }
                        }
                    }
                }
            }
        }
        return countryPlanTargetList;
    }
    
    /** 
    *  @description: This method is used to map fields of Country Plan Target for insertion.
    *  @name: prepareMapForApCreation
    *  @param: Product2 prodInstance - Product to be processed .
              Country_Plan__c countryPlanInstance - Country Plan for mapping the look up in Country Plan Target for insertion 
              Integer i- for External Id creation.
    *  @return: Country_Plan_Target__c
    */ 
    private static Country_Plan_Target__c mapCountryPlanTargetValues(Product2 prodInstance,Country_Plan__c countryPlanInstance, Integer i) {
        Country_Plan_Target__c countryPlanTargetInstance = new Country_Plan_Target__c();
        GL_Calendar__c glcalander = new GL_Calendar__c();
        //system.debug('previousGlCalander : '+previousGlCalander+fetchGLCalenderForDate(prodInstance.Street_Date__c.addMonths(i)));
        if(i == 0){
            //US: 997 - Start
            glcalander = fetchGLCalenderForDate(prodInstance.Street_Date__c.addMonths(i), prodInstance.Type__c);
            previousGlCalander = glcalander;
        }
        
        // Defect 3772 added null check
        else if(previousGlCalander != null && PreviousGlcalander.End_Date__c != null){
            Date nextStartDate = PreviousGlcalander.End_Date__c.addDays(1);
            
            if(mapAllStartDateGlCalander.containsKey(String.valueOf(nextStartDate))){
                   glcalander =  mapAllStartDateGlCalander.get(String.valueOf(nextStartDate));
                   previousGlCalander = glcalander;
            }
        }
        
        if(countryPlanInstance != null && countryPlanInstance.id != null && prodInstance.Street_Date__c != null &&  glcalander != null && glcalander.Id != null){
            CountryPlanTargetInstance.Target__c = 0;
            countryPlanTargetInstance.Country_Plan__c = countryPlanInstance.Id;
            countryPlanTargetInstance.CurrencyIsoCode = countryPlanInstance.CurrencyIsoCode;
            countryPlanTargetInstance.GL_Calendar__c = glcalander.Id;
            countryPlanTargetInstance.External_Id__c = countryPlanInstance.External_Id__c +'-' + glcalander.month__c; 
            //countryPlanTargetInstance.External_Id__c = countryPlanInstance.Id +'__' + string.valueof(glcalander.Start_Date__c)+'_'+string.valueof(glcalander.End_Date__c); 
            //system.debug('countryPlanTargetInstance.External_Id__c'+countryPlanTargetInstance.External_Id__c);
        }
        return countryPlanTargetInstance;
    }  
    
    /** 
    *  @description: This method is used to map Type(GAMES DIGITAL ,VIDEO DIGITAL ,GAMES PHYSICAL ,VIDEO PHYSICAL ) with Account.   
    *  @name: prepareMapOfTypeKeyAccList
    *  @param: List<Account> accountList - List of Account for creation of Map
    *  @return: Map<String,List<Account>>
    */ 
    public static Map<String,List<Account>> prepareMapOfTypeKeyAccList(List<Account> accountList){
        Map<String,List<Account>> mapOfTypeKeyAccListLocal = new Map<String,List<Account>>();
        mapOfTypeKeyAccListLocal.put(CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE,new List<Account>());
        mapOfTypeKeyAccListLocal.put(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE,new List<Account>());
        mapOfTypeKeyAccListLocal.put(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE,new List<Account>());
        mapOfTypeKeyAccListLocal.put(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE,new List<Account>());
        for(Account acc : accountList){
            
            if(acc.Games_Digital__c){
                mapOfTypeKeyAccListLocal.get(CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE).add(acc);
            }
            if(acc.Games_Physical__c){
                mapOfTypeKeyAccListLocal.get(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE).add(acc);
            }
            if(acc.Video_Digital__c){
                mapOfTypeKeyAccListLocal.get(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE).add(acc);
            }
            if(acc.Video_Physical__c){
                mapOfTypeKeyAccListLocal.get(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE).add(acc);
            }
        }
        return mapOfTypeKeyAccListLocal;
    }
    
    /** 
    *  @description: This method is used to insert Account Plan for valid Account   
    *  @name: insertAccountPlanList
    *  @param: Map<Id, Product2> mapProductsToBeProcessed - Map of products to be processed 
              Set<Id> countryPlanIds - Set of Country Plans for generating valid account Plan list
              Set<Id> accountPlanIds - Set of Account plan for Account Plan Target generation
              Boolean isFromProductBatch - Checks whether called from Product batch or Account Batch
    *  @return: Map<String,List<Account>>
    */   
    public static set<Id> insertAccountPlanList(Map<Id, Product2> mapProductsToBeProcessed,set<Id> countryPlanIds,set<Id> accountPlanIds,Boolean isFromProductBatch){
        
        Set<String> existingExternalIds = new Set<String>();
        List<Account_Plan__c> apInsertList = new List<Account_Plan__c>();
        List<Account_Plan__c> accountPlanList = new  List<Account_Plan__c>();
        
        accountPlanList = generateAcountPlanList(mapProductsToBeProcessed);
        //Defect 3776  
        fetchExistingAccountandPrepareMap(mapCPTandAPExternalIdCountryPlan.keySet(),existingExternalIds);
        
        for(Account_Plan__c ap : accountPlanList){
            if(!existingExternalIds.contains(ap.External_Id__c)){
                apInsertList.add(ap);
            }
        }
        //Defect 3776  
        system.debug('apInsertList'+apInsertList);

        if(accountPlanList != null && accountPlanList.size() > 0){
            //Defect 3776               
             Database.SaveResult[] result = Database.Insert(apInsertList, false);
             for(Integer i=0; i < result.size(); i++ ){
                Account_Plan__c accntPlanInstance = new Account_Plan__c();
                Country_Plan__c cpInstance = new Country_Plan__c();
                accntPlanInstance = apInsertList[i];
                if(!result[i].isSuccess()){
                    if(mapCPTandAPExternalIdCountryPlan.containsKey(accntPlanInstance.External_Id__c)){
                        cpInstance = mapCPTandAPExternalIdCountryPlan.get(accntPlanInstance.External_Id__c);
                    }
                    
                    if(isFromProductBatch){
                        //CRM_AutoTargetCreationProductInsertBatch.failedProd.add(cpInstance.NR_Product__c);
                        failedProd.add(cpInstance.NR_Product__c);
                    }else {
                        //CRM_AutoTargetCreationAccountInsertBatch.failedAccounts.add(accntPlanInstance.Customer__c);
                        failedAccounts.add(accntPlanInstance.Customer__c);
                    }
                    
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(result[i].getErrors(), result[i].getId(), 'Account Plan  : Prod =' + string.valueOf(cpInstance.NR_Product__r.Id) );
                    errorLogs.addAll(errorLogInstance);
                }
                else{
                    countryPlanIds.add(accntPlanInstance.Country_Plan__c);
                    accountPlanIds.add(result[i].getId());
                }
            }
        }
        return countryPlanIds;
    }
    
    /** 
    *  @description: This method is used to map fields for Account Plan by validating the Region and Country Plan
    *  @name: generateAcountPlanList
    *  @param: Map<Id, Product2> mapProductsToBeProcessed - Map of products to be processed  
    *  @return: Map<String,List<Account>>
    */   
    public static List<Account_Plan__c> generateAcountPlanList(Map<Id, Product2> mapProductsToBeProcessed) {
        List<Account_Plan__c> accountPlanList = new  List<Account_Plan__c>();
        Country_Plan__c countryPlan = new Country_Plan__c();
        if(mapOfNameRegionForAutoTarget.containsKey(CRM_AppConstants.Account_Plan) && mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Account_Plan) != null){
            set<string> regions = mapOfNameRegionForAutoTarget.get(CRM_AppConstants.Account_Plan);
            List<Account> accListLocal = new List<Account>();
            Product2 prodInstance;
            for(Id prodId : mapCountryPlanAccount.keySet()){
                
                if(mapProdCountryPlan.containsKey(prodId) && mapProductsToBeProcessed.containsKey(prodId)){
                    accListLocal = mapCountryPlanAccount.get(prodId);
                    countryPlan = mapProdCountryPlan.get(prodId);
                    prodInstance = mapProductsToBeProcessed.get(prodId);
                    if(regions.contains(prodInstance.Local_Title__r.Country__r.Country_Code2__c)){
                        for(Account acc : accListLocal){
                            Account_Plan__c accountPlanInstance = new Account_Plan__c();
                            accountPlanInstance.Share__c = 0;
                            accountPlanInstance.Country_Plan__c = countryPlan.Id;
                            accountPlanInstance.CurrencyIsoCode = countryPlan.CurrencyIsoCode;
                            accountPlanInstance.Customer__c = acc.Id;
                            accountPlanInstance.External_Id__c = countryPlan.External_Id__c +'-' + acc.External_Id__c;
                            accountPlanList.add(accountPlanInstance);
                            mapCPTandAPExternalIdCountryPlan.put(accountPlanInstance.External_Id__c,countryPlan);
                        }
                    }
                }
            }
        }
        return accountPlanList;
    }
    
    /** 
    *  @description: This is a generic method is used to get list of Country Plans for valid Account Plans and Country Plan Targets
    *  @name: fetchCountryPlans
    *  @param: set<Id> countryPlanIds - Set of Country Plans  
              set<Id> accountPlanIds - Set of Account Plans
    *  @return: List<Country_Plan__c>
    */  
    public static List<Country_Plan__c> fetchCountryPlans(set<Id> countryPlanIds,set<Id> accountPlanIds) {
        List<Country_Plan__c> newCountryPlansFetchedList = new List<Country_Plan__c>();
        
        newCountryPlansFetchedList = [SELECT Id, Name, RecordType.DeveloperName,RecordTypeId,NR_Product__c,Product_Group1__c,NR_Product__r.Title_Country__c,
                                                Last_Auto_Allocated_Date__c,
                                                (SELECT Id,Name,End_Date__c,Start_Date__c,GL_Calendar__c,Stretch_Target__c,Target__c,Returns_Target__c,
                                                        Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c,Target_Quantity__c,Stretch_Target_Quantity__c
                                                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c),
                                                (SELECT Id, RecordTypeId, Name, CurrencyISOCode, Share__c,Total_Target__c,Target_Quantity__c,Product_Group__c,Customer__c,Returns_Share__c,
                                                        Billing_Adjustment_Share__c,Country_Plan__r.Id,Country_Plan__r.Name 
                                                        FROM Account_Plans__r Where Id IN : accountPlanIds)
                                      FROM Country_Plan__c Where Id IN : countryPlanIds];
        
        return newCountryPlansFetchedList;
        
    }
    
    /** 
    *  @description: This is a generic method is used to get map of Country Plans for Products to be processed
    *  @name: fetchExistingCountryPlanAndPrepareMap
    *  @param: set<Id> ProductIds - Set of Products to be processed  
    *  @return: void
    */  
    public static void fetchExistingCountryPlanAndPrepareMap(set<Id> productIds) {
        List<Country_Plan__c> existingCountryPlansFetchedList = new List<Country_Plan__c>();
        existingCountryPlansFetchedList = [SELECT Id, Name, RecordType.DeveloperName,External_Id__c,RecordTypeId,CurrencyIsoCode,NR_Product__c,
                                                  Product_Group1__c,NR_Product__r.Title_Country__c,NR_Product__r.Local_Title__r.Country__r.Country_Code2__c
                                                  FROM Country_Plan__c 
                                                  WHERE NR_Product__c IN : productIds and External_Id__c != null ORDER BY createddate];
        for(Country_Plan__c existingCountryPlan : existingCountryPlansFetchedList ){
            mapProdCountryPlan.put(existingCountryPlan.NR_Product__c,existingCountryPlan);
        }  
    }
    
    //Defect 3776  
    /** 
    *  @description: This is a generic method is used to get map of existing Country Plan Targets
    *  @name: fetchExistingCountryPlanTargetandPrepareMap
    *  @param: set<String> ExternalIds - Set of ExternalIds to be processed  
    *  @return: void
    */  
    public static void fetchExistingCountryPlanTargetandPrepareMap(Set<String> externalIds,Set<String> existingExternalIds) {
        List<Country_Plan_Target__c> existingCountryPlanTargetsFetchedList = new List<Country_Plan_Target__c>();
        existingCountryPlanTargetsFetchedList = [SELECT Id, External_Id__c FROM Country_Plan_Target__c 
                                                  WHERE External_Id__c IN : externalIds and External_Id__c != null ORDER BY createddate];
        for(Country_Plan_Target__c existingCountryPlanTarget : existingCountryPlanTargetsFetchedList ){
            existingExternalIds.add(existingCountryPlanTarget.External_Id__c);
        }  
    }
    
    //Defect 3776  
    /** 
    *  @description: This is a generic method is used to get map of existing Account Plan
    *  @name: fetchExistingAccountandPrepareMap
    *  @param: set<String> ExternalIds - Set of ExternalIds to be processed  
    *  @return: void
    */  
    public static void fetchExistingAccountandPrepareMap(Set<String> externalIds,Set<String> existingExternalIds) {
        List<Account_Plan__c> existingAccountPlanFetchedList = new List<Account_Plan__c>();
        existingAccountPlanFetchedList = [SELECT Id, External_Id__c FROM Account_Plan__c 
                                                  WHERE External_Id__c IN : externalIds and External_Id__c != null ORDER BY createddate];
        for(Account_Plan__c existingAccountPlan : existingAccountPlanFetchedList ){
            existingExternalIds.add(existingAccountPlan.External_Id__c);
        }  
    }
    
    
    /** 
    *  @description: This method is used to insert Account Plan Target.
    *  @name: insertAccountPlanTarget
    *  @param: List<Target__c> accountPlanTargetList -Account Plan Targets to be inserted.
              Boolean isFromProductBatch - Checks if the method is called from Product or Account Batch
    *  @return: void
    */  
    public static void insertAccountPlanTarget(List<Target__c> accountPlanTargetList,Boolean isFromProductBatch){
        
        if(accountPlanTargetList != null && accountPlanTargetList.size() > 0){
             Database.UpsertResult[] result = Database.Upsert(accountPlanTargetList, Target__c.Unique_Key__c, false);
             for(Integer i=0; i < result.size(); i++ ){
                Target__c targetInstance = accountPlanTargetList[i];
                if(!result[i].isSuccess()){
        
                    if(isFromProductBatch){
                        //CRM_AutoTargetCreationProductInsertBatch.failedProd.add(targetInstance.Product__c);
                        failedProd.add(targetInstance.Product__c);
                    }else {
                        //CRM_AutoTargetCreationAccountInsertBatch.failedAccounts.add(targetInstance.Account__c);
                        failedAccounts.add(targetInstance.Account__c);
                    }
                    
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = logAnException(result[i].getErrors(), result[i].getId(), 'Target  : Prod =' + string.valueOf(targetInstance.Product__c) );
                    errorLogs.addAll(errorLogInstance);
                }
            }
        }
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
        
        errorLogInstance.functionalModule = 'Auto Target Creation Product Batch';
        errorLogInstance.className = 'CRM_AutoTargetCreationProductInsertBatch';
        
        statusCode += ' Error Code: ' + String.valueOf(errorInstance.getStatusCode());
        errorMessage += ' Error Message: ' + errorInstance.getMessage() + ' : EntityName: ' + entityName;

        errorLogInstance.lineNumber = lineNumber;
        errorLogInstance.errorMessage = errorMessage.left(200);
        errorLogInstance.stackTrace = statusCode;
        return errorLogInstance;
    }       
}