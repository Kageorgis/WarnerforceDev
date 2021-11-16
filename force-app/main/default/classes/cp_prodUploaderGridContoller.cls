/**
* Created by XMMORENO on 5/26/2020.
*/

public with sharing class cp_prodUploaderGridContoller {
    
    @AuraEnabled
    public static List<contentDocument> fetchContentDocument(){
        return [Select id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument WHERE Title ='UPC Collection Template - XLSX' OR Title = 'UPC Collection Template - CSV'  ];
    }
    
    @AuraEnabled
    public static List<String> getFieldSet(String sObjectName){
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        List<String> fieldSetList = new List<String>();        
        Schema.FieldSet fs2 = Schema.SObjectType.CP_Product__c.fieldSets.cp_Default_Product_Fields;
        List<Schema.FieldSetMember> fields =
            Schema.SObjectType.CP_Product__c.fieldSets.cp_Default_Product_Fields.getFields();
        for(Schema.FieldSetMember m:fields){
            fieldSetList.add(String.valueOf(m.getSObjectField()));
        }
        return fieldSetList;
    }
    
    @AuraEnabled
    public static LookupWrapper getLookupValues(){        
        LookupWrapper returnListWrapper =new LookupWrapper();
        List<Account> retAccounts = [SELECT Id, Name FROM Account WHERE RecordType.Name =: CP_ProductUtility.WBCP_RETAILER ORDER BY Name];
        List<Property__c> propRecs = [SELECT Id,Name FROM Property__c ORDER BY Name];
        List<WBCP_Country__c> countryRecs = [SELECT Id,Name FROM WBCP_Country__c ORDER BY Name];
        List<User> u = [SELECT Name,contactId, Account.Name, AccountId,User_License_Type__c,WBCP_Access_Role__c,Country FROM User WHERE Id = :UserInfo.getUserId()];
        WBCP_Country__c defCountry = [SELECT Id, Name, Country_Code__c FROM WBCP_Country__c WHERE Name ='United States'];
        List<String> retVals = new List<String>();
        List<String> propVals = new List<String>();
        List<String> countryVals = new List<String>();
        List<String> licenseeVals = new List<String>();
        String accountId = '';
        if(!u.isEmpty()) {
            accountId = u[0].Account.Name;
            //AccountId is populated if you run this as a community user /portal users .For admin Users this value is null ((((
        }
        for(Account ret:retAccounts){
            String newVal = ret.Name;
            retVals.add(newVal);
        }
        for(Property__c prop:propRecs){
            String propVal = prop.Name;
            propVals.add(propVal);
        }
                
        cp_prodUploaderGridContoller.populateLicenseeValues(licenseeVals,u[0]);
        cp_prodUploaderGridContoller.populateCountryValues(countryVals,u[0]);
        
        List<String> demoVals = getPicklistEntries('CP_Product__c', 'Demo__c');
        List<String> genderVals = getPicklistEntries('CP_Product__c', 'Gender__c');
        List<String> prodVals = getPicklistEntries('CP_Product__c', 'Product_Status__c');
        List<String> subVals = getPicklistEntries('CP_Product__c', 'Sub_Category__c');
        List<String> catVals = getPicklistEntries('CP_Product__c', 'cp_Category_NAM__c');
        List<String> flowVals = getPicklistEntries('CP_Product__c', 'Flow_Through_Flag__c');
        List<String> promoVals = getPicklistEntries('CP_Product__c', 'Promotional_Flag__c');
        returnListWrapper.prodValues = prodVals;
        returnListWrapper.genderValues = genderVals;
        returnListWrapper.demoValues = demoVals;
        returnListWrapper.subValues = subVals;
        returnListWrapper.catValues = catVals;
        returnListWrapper.retValues = retVals;
        returnListWrapper.propValues = propVals;
        returnListWrapper.countryValues = countryVals;
        returnListWrapper.licenseeValues = licenseeVals;
        returnListWrapper.defaultLicensee = accountId;
        returnListWrapper.defaultCountry = defCountry.Name;
        returnListWrapper.flowValues = flowVals;
        returnListWrapper.promoValues = promoVals;
        return returnListWrapper;
    }
    
    public static void addAllCountries(List<String> countryVals){
        List<WBCP_Country__c> countryRecs = [SELECT Id,Name FROM WBCP_Country__c ORDER BY Name];
        for(WBCP_Country__c country:countryRecs){
            countryVals.add(country.Name);
        }
    }

    public static void populateLicenseeValues(List<String> licenseeVals,User userRec){
        
        Map<String,List<String>> regionLicenseesMap = new Map<String,List<String>>();
        Map<String,List<String>> territoryLicenseesMap = new Map<String,List<String>>();

        system.debug(LoggingLevel.INFO,'userRec:'+userRec);
        
        
        List<Account> accountRecList = [SELECT Id,Name,cp_Territories__c,cp_Regions__c FROM Account WHERE RecordType.Name =: CP_ProductUtility.WBCP_LICENSEE ORDER BY Name];
        Set<String> allAccountSet = new Set<String>();
        if(accountRecList != Null && accountRecList.size()>0){
            for(Account accRec : accountRecList){
                //all Accounts Names
                allAccountSet.add(accRec.Name);

                //territory wise Account Names
                if(accRec.cp_Territories__c != Null && accRec.cp_Territories__c != ''){
                    String[] territoryValues = accRec.cp_Territories__c.split(';');
                    for(String territory : territoryValues){
                        if(territoryLicenseesMap != Null){
                            if(!territoryLicenseesMap.containsKey(territory)){
                                territoryLicenseesMap.put(territory,new List<String>{accRec.Name});
                            }else{
                                territoryLicenseesMap.get(territory).add(accRec.Name);
                            }
                        }
                    }
                    system.debug(LoggingLevel.INFO,'territoryLicenseesMap:'+territoryLicenseesMap);
                }

                //account Names as per Region
                if(accRec.cp_Regions__c != Null && accRec.cp_Regions__c != ''){
                    String[] regionValues = accRec.cp_Regions__c.split(';');
                    for(String regionName : regionValues){
                        if(regionLicenseesMap != Null){
                            if(!regionLicenseesMap.containsKey(regionName)){
                                regionLicenseesMap.put(regionName,new List<String>{accRec.Name});
                            }else{
                                regionLicenseesMap.get(regionName).add(accRec.Name);
                            }
                        }
                    }
                }
            }
        }
        if(userRec.User_License_Type__c == CP_ProductUtility.WBCP_SALESFORCE_PLATFORM && userRec.WBCP_Access_Role__c != Null){
            if(userRec.WBCP_Access_Role__c == CP_ProductUtility.WBCP_GLOBAL){
                if(allAccountSet != Null && allAccountSet.size()>0){
                    licenseeVals.addAll(allAccountSet);
                }
            }else if(userRec.WBCP_Access_Role__c == CP_ProductUtility.WBCP_REGIONAL){
                if(userRec.Country != Null){
                    WBCP_TerritoryData__c record = WBCP_TerritoryData__c.getValues(userRec.Country);
                    if(regionLicenseesMap != Null && regionLicenseesMap.containsKey(record.Destination_Region__c)){
                        licenseeVals.addAll(regionLicenseesMap.get(record.Destination_Region__c));
                    }
                }
            }else if(userRec.WBCP_Access_Role__c == CP_ProductUtility.WBCP_LOCAL){
                if(userRec.Country != Null && territoryLicenseesMap != Null && territoryLicenseesMap.containsKey(userRec.Country)){        
                    licenseeVals.addAll(territoryLicenseesMap.get(userRec.Country));
                }
            }
        }else{
            if(allAccountSet != Null && allAccountSet.size()>0){
                licenseeVals.addAll(allAccountSet);
            }
        }
    }
    
    //Limit Country drop down to show values specific to the Licensee country/territory - LOCAL/REGIONAL/GLOBAL - Internal or External
    public static void populateCountryValues(List<String> countryVals,User userRec){
        Contact contactRec;
        List<WBCP_TerritoryData__c> territoryRegionList = WBCP_TerritoryData__c.getAll().values();
        Map<String,List<String>> regionTerritoriesMap = new Map<String,List<String>>();
        for(WBCP_TerritoryData__c rec : territoryRegionList){
            if(!regionTerritoriesMap.containsKey(rec.Destination_Region__c)){
                regionTerritoriesMap.put(rec.Destination_Region__c,new List<String>{rec.Name});
            }else{
                regionTerritoriesMap.get(rec.Destination_Region__c).add(rec.Name);
            }
        }
        
        if(userRec.User_License_Type__c == 'Customer Community Plus' && userRec.WBCP_Access_Role__c != Null){
            contactRec =  [SELECT Id,CP_Region__c,CP_Territory__c FROM Contact WHERE Id =: userRec.contactId ];
            if(userRec.WBCP_Access_Role__c == 'Local'){
                if(contactRec.CP_Territory__c != Null){
                    countryVals.add(contactRec.CP_Territory__c);
                }
            }else if(userRec.WBCP_Access_Role__c == 'Regional'){
                if(contactRec.CP_Territory__c != Null && contactRec.CP_Region__c != Null){
                    if(regionTerritoriesMap != Null && regionTerritoriesMap.containsKey(contactRec.CP_Region__c)){
                        countryVals.addAll(regionTerritoriesMap.get(contactRec.CP_Region__c));
                    }
                }
            }else if(userRec.WBCP_Access_Role__c == 'Global'){
                cp_prodUploaderGridContoller.addAllCountries(countryVals);
            }
        }else if(userRec.User_License_Type__c == 'Salesforce Platform' && userRec.WBCP_Access_Role__c != Null){
                if(userRec.WBCP_Access_Role__c == 'Local'){
                    if(userRec.Country != Null){
                        countryVals.add(userRec.Country);
                    }
                }else if(userRec.WBCP_Access_Role__c == 'Regional'){
                    WBCP_TerritoryData__c record = WBCP_TerritoryData__c.getValues(userRec.Country);
                    if(regionTerritoriesMap != Null && regionTerritoriesMap.containsKey(record.Destination_Region__c)){
                        countryVals.addAll(regionTerritoriesMap.get(record.Destination_Region__c));
                    }
                }else if(userRec.WBCP_Access_Role__c == 'Global'){
                    cp_prodUploaderGridContoller.addAllCountries(countryVals);
                }
        }else{
            cp_prodUploaderGridContoller.addAllCountries(countryVals);
        }
    }
    
    public class LookupWrapper{
        @auraEnabled public List<String> promoValues {get; set;}
        @auraEnabled public List<String> flowValues {get; set;}
        @auraEnabled public List<String> prodValues {get; set;}
        @auraEnabled public List<String> genderValues {get; set;}
        @auraEnabled public List<String> demoValues {get; set;}
        @auraEnabled public List<String> subValues {get; set;}
        @auraEnabled public List<String> catValues {get; set;}
        @auraEnabled public List<String> retValues {get; set;}
        @auraEnabled public List<String> propValues {get; set;}
        @auraEnabled public List<String> countryValues {get; set;}
        @auraEnabled public List<String> licenseeValues {get; set;}
        @auraEnabled public String defaultLicensee {get; set;}
        @auraEnabled public String defaultCountry {get; set;}
    }
    
    public static List<String> getPicklistEntries(String objectName, String fieldName){
        List<String> pleVals = new List<String>();        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p: ple){
            String pVal = p.getValue();
            pleVals.add(pVal);
        }
        return pleVals;
    }
    
    @AuraEnabled
    public static List<ProductWrapper> saveProducts(List<ProductWrapper> productWrapperTableData){
        //System.debug('productWrapperTableData :-- ' + productWrapperTableData);  
         List<User> user = [SELECT Name,contactId, Account.Name, AccountId,User_License_Type__c,WBCP_Access_Role__c,Country FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        
        if(!productWrapperTableData.isEmpty()){
            List<ProductWrapper> returnProductWrapper =new List<ProductWrapper>();
            List<CP_Product__c> insertProductData =new List<CP_Product__c>();
            List<String> accountNames = new List<String>();
            List<String> retailerNames = new List<String>();
            List<String> propertyNames = new List<String>();
            List<String> contactNames = new List<String>();
            List<String> countryNames = new List<String>();
            List<String> upcNumbers = new List<String>(); // list of upc(GTIN) no
            Map<String, Integer> GTINCountMap = new Map<String, Integer>();
            
            for(ProductWrapper Obj : productWrapperTableData){
                if(!String.isBlank(obj.Licensee_Name)){
                    accountNames.add(obj.Licensee_Name);
                }
                else {
                  if(user.size() > 0 && user[0].contactId != null) {
                     accountNames.add(user[0].Account.Name);
                  }
                }
                //  Retailer Lookup
                if(!String.isBlank(obj.Retailer)){
                    retailerNames.add(obj.Retailer);
                }
                if(!String.isBlank(obj.Licensed_Property)){
                    propertyNames.add(obj.Licensed_Property);
                }                               
                if(!String.isBlank(obj.Country)){
                    countryNames.add(obj.Country);
                }
                /*if(!String.isBlank(obj.UPC)){ //added upc in list
                upcNumbers.add(obj.UPC);
                }*/
                if(!String.isBlank(obj.GTIN)){ //added upc (GTIN) in list
                    upcNumbers.add(obj.GTIN);
                }
                if(!String.isBlank(obj.GTIN)){
                    String GTIN_Retailer_SKU = obj.GTIN + obj.Retailer_SKU;
                    if(!GTINCountMap.containsKey(GTIN_Retailer_SKU)){
                        GTINCountMap.put(GTIN_Retailer_SKU, 1);
                    }else{
                        GTINCountMap.put(GTIN_Retailer_SKU, GTINCountMap.get(GTIN_Retailer_SKU) + 1);
                    }
                }
            }
            
            Map<String,Account> mapAccountsData = new Map<String,Account>();
            if(!accountNames.isEmpty()){
                for(Account accObj : [SELECT Id, Name FROM Account WHERE Name LIKE :accountNames]){
                    mapAccountsData.put(accObj.Name,accObj);
                }
            }
            Map<String,Account> mapRetailersData = new Map<String,Account>();
            if(!retailerNames.isEmpty()){
                for(Account retObj : [SELECT Id, Name FROM Account WHERE Name IN :retailerNames AND RecordType.Name = 'WBCP Retailer']){
                    mapRetailersData.put(retObj.Name,retObj);
                }
            }
            Map<String,Contact> mapContactData = new Map<String,Contact>();
            if(!contactNames.isEmpty()){
                for(Contact contObj : [SELECT Id, Name FROM Contact WHERE Contact_Name__c IN :contactNames]){
                    mapContactData.put(contObj.Name,contObj);
                }
            }           
            Map<String,WBCP_Country__c> mapCountryData = new Map<String,WBCP_Country__c>();
            if(!countryNames.isEmpty()){
                for(WBCP_Country__c countryObj : [SELECT Id, Name FROM WBCP_Country__c WHERE Name LIKE :countryNames]){
                    mapCountryData.put(countryObj.Name,countryObj);
                }
            }            
            //  Property Lookup
            Map<String,Property__c> mapPropertiesData = new Map<String,Property__c>();
            if(!propertyNames.isEmpty()){
                for(Property__c propObj : [SELECT Id, Name FROM Property__c WHERE Name LIKE :propertyNames]){
                    mapPropertiesData.put(propObj.Name,propObj);
                }
            }
            
            /*
            Map<String,StarLabs_Product__c> mapUPCData = new Map<String,StarLabs_Product__c>();
            System.debug('upcNumbers --> '+ upcNumbers);
            if(!upcNumbers.isEmpty()){
            for(StarLabs_Product__c starLabProductObj : [SELECT Id, UPC__c FROM StarLabs_Product__c WHERE UPC__c IN :upcNumbers]){
            System.debug('starLabProductObj ' + starLabProductObj);
            mapUPCData.put(starLabProductObj.UPC__c,starLabProductObj);
            }
            }
            System.debug('mapUPCData --->> '+ mapUPCData);*/
            
            /*------ UPC (GTIN) Logic ------*/
            Map<String,StarLabs_Product__c> mapUPCData = new Map<String,StarLabs_Product__c>();
            if(!upcNumbers.isEmpty()){
                for(StarLabs_Product__c starLabProductObj : [SELECT Id, UPC__c FROM StarLabs_Product__c WHERE UPC__c IN :upcNumbers]){
                    mapUPCData.put(starLabProductObj.UPC__c,starLabProductObj);
                }
            }
            
            //List<String> lpPickVal = Label.Licensed_Property_Picklist_Values.split(';');
            //List<String> ctPickVal = Label.Category_Picklist_Values.split(';');
            //List<String> retPickVal = Label.Retailer_Picklist_Values.split(';');
            //  List<String> sc1PickVal = Label.Sub_Category_Picklist_Values_1.split(';');
            //List<String> sc2PickVal = Label.Sub_Category_Picklist_Values_2.split(';');
            //  List<String> demoPickVal = Label.Demo_Picklist_Values.split(';');
            
            List<ProductWrapper> InvalidProductWrapper = new List<ProductWrapper>();
            List<ProductWrapper> successProductWrapper = new List<ProductWrapper>();
            List<ProductWrapper> errorProductWrapper = new List<ProductWrapper>();
            List<ProductWrapper> toBeInserted = productWrapperTableData;
            
            //-------------- Validation -------------------------------------------------------------
            
            
            for(ProductWrapper productWrapperObj : productWrapperTableData){                
                if(productWrapperObj.isInserted != True && productWrapperObj.isRowRemoved != True){
                    String str = '';
                    String GTINSKU = productWrapperObj.GTIN +productWrapperObj.MPN+productWrapperObj.Retailer_SKU;
                    
                    if(user.size() >0 && user[0].contactId !=null)
                    {
                       productWrapperObj.Licensee_Name = user[0].Account.Name; 
                    }
                    if(String.isBlank(productWrapperObj.Licensee_Name) || (!String.isBlank(productWrapperObj.Licensee_Name) && (productWrapperObj.Licensee_Name).length() > 80)){
                        str = 'Please enter Licensee name.';
                    }                    
                    if(String.isBlank(productWrapperObj.Country) || (!String.isBlank(productWrapperObj.Country) && (productWrapperObj.Country).length() > 80)){
                        str = Str + 'Please enter Country name.';
                    }                    
                    if(String.isBlank(productWrapperObj.GTIN)){
                        str = Str + ' The GTIN you entered is not valid, Please check the number and re-enter.';
                    }                    
                    if(!String.isBlank(productWrapperObj.GTIN) && GTINCountMap.containsKey(GTINSKU) && GTINCountMap.get(GTINSKU) > 1){
                        str = Str + ' Duplicate record found, combination of GTIN and MPN Retailer SKU should be unique.';
                    }                    
                    if(String.isBlank(productWrapperObj.MPN)){
                        str = Str + ' The MPN you entered is not valid, Please check the number and re-enter.';
                    }
                    if(String.isBlank(productWrapperObj.MPN_Description)){
                        str = Str + ' Please enter MPN Description.';
                    }                    
                    // Retailer picklist--
                    if(String.isBlank(productWrapperObj.Retailer) || (!String.isBlank(productWrapperObj.Retailer) && (productWrapperObj.Retailer).length() > 80)){
                        str = Str + ' Please enter Retailer.';
                    }
                    // Retailer picklist--
                    if(String.isBlank(productWrapperObj.Licensed_Property) || (!String.isBlank(productWrapperObj.Licensed_Property) && (productWrapperObj.Licensed_Property).length() > 80)){
                        str = Str + ' Please enter a Property.';
                    }                    
                    // Retailer SKU--
                    if(String.isBlank(productWrapperObj.Retailer_SKU)){
                        str = Str + ' Please enter Retailer SKU.';
                    }                    
                    // Item Desc --
                    if(String.isBlank(productWrapperObj.Item_Description)){
                        str = Str + ' Please enter Item Description.';
                    }                    
                    // Size -- Size
                    if(String.isBlank(productWrapperObj.Size)){
                        str = Str + ' Please enter Size.';
                    }                   
                    if(String.isBlank(productWrapperObj.Sub_Category)){
                        str =str + ' Please check the picklist values of Sub Category';
                    }                    
                    if(!String.isBlank(productWrapperObj.Set_Date) && !String.isBlank(productWrapperObj.Retired_Date)){
                        Date setDate =   Date.parse(productWrapperObj.Set_Date);
                        Date retiredDate =   Date.parse(productWrapperObj.Retired_Date);
                        if(setDate >= retiredDate){
                            str =str + ' Retired Date should be greater than Set Date';
                        }
                    }                    
                    if(!String.isBlank(productWrapperObj.Flow_through_Start_Date) && !String.isBlank(productWrapperObj.Flow_through_End_Date)){
                        Date startDate =   Date.parse(productWrapperObj.Flow_through_Start_Date);
                        Date endDate =   Date.parse(productWrapperObj.Flow_through_End_Date);
                        if(startDate >= endDate){
                            str =str + ' Flow-through Start Date should be greater than Flow-through End Date';
                        }
                    }                    
                    if(!String.isBlank(productWrapperObj.Promotional_Start_Date) && !String.isBlank(productWrapperObj.Promotional_End_Date)){
                        Date startDate =   Date.parse(productWrapperObj.Promotional_Start_Date);
                        Date endDate =   Date.parse(productWrapperObj.Promotional_End_Date);
                        if(startDate >= endDate){
                            str =str + ' Promotional Start Date should be greater than Promotional End Date';
                        }
                    }
                    //RSP value validation
                    if(String.isNotBlank(productWrapperObj.RSP)){
                        if(cp_prodUploaderGridContoller.validateRSP(productWrapperObj.RSP.trim().remove('$'))){
                            str = str + ' The RSP you entered is not valid, Please check the RSP value and re-enter.';
                        }
                    }
                    productWrapperObj.validation = str;
                    productWrapperObj.CP_Product_Key = productWrapperObj.GTIN+'_'+productWrapperObj.MPN+'_'+productWrapperObj.Retailer_SKU;
                    productWrapperObj.errorOccured = false;
                    
                    if(!String.isBlank(productWrapperObj.validation)){
                        productWrapperObj.errorOccured = true;
                        errorProductWrapper.add(productWrapperObj);
                    }else{
                        productWrapperObj.errorOccured = false;
                        successProductWrapper.add(productWrapperObj);
                    }
                }
            }
            //-------------- Validation -------------------------------------------------------------
            //-------------- Success -------------------------------------------------------------
            if(successProductWrapper.size() > 0){
                for(ProductWrapper productWrapperObj : successProductWrapper){
                    if(productWrapperObj.errorOccured == false){
                        CP_Product__c productObj = new CP_Product__c(); 
                        productObj.Submission_Type__c = 'UPC';                       
                        if(!String.isBlank(productWrapperObj.Licensee_Name) && mapAccountsData.containsKey(productWrapperObj.Licensee_Name)){
                            productObj.Licensee__c = mapAccountsData.get(productWrapperObj.Licensee_Name).Id;
                        }                        
                        if(!String.isBlank(productWrapperObj.Country) && mapCountryData.containsKey(productWrapperObj.Country)){
                            productObj.WBCP_Country__c = mapCountryData.get(productWrapperObj.Country).Id;
                        }
                        productObj.GTIN__c = productWrapperObj.GTIN;
                        productObj.MPN__c = productWrapperObj.MPN;
                        productObj.cp_MPN_Description__c = productWrapperObj.MPN_Description;
                        //  Retailer Lookup
                        if(!String.isBlank(productWrapperObj.Retailer) && mapRetailersData.containsKey(productWrapperObj.Retailer)){
                            productObj.cp_Retailer_Description__c = mapRetailersData.get(productWrapperObj.Retailer).Id;
                        }
                        productObj.Retailer_SKU__c = productWrapperObj.Retailer_SKU;
                        // Retailer picklist
                        /*
                        if(!String.isBlank(productWrapperObj.Buyer_Name) && mapContactData.containsKey(productWrapperObj.Buyer_Name)){
                        productObj.Buyer_Name__c = mapContactData.get(productWrapperObj.Buyer_Name).Id;
                        }
                        */
                        //Property Lookup
                        if(!String.isBlank(productWrapperObj.Licensed_Property) && mapPropertiesData.containsKey(productWrapperObj.Licensed_Property)){
                            productObj.cp_Licensed_Property__c = mapPropertiesData.get(productWrapperObj.Licensed_Property).Id;
                        }
                        
                        productObj.Item_Descrption__c = productWrapperObj.Item_Description;
                        productObj.cp_Category_NAM__c = productWrapperObj.Category;
                        productObj.Sub_Category__c = productWrapperObj.Sub_Category;
                        productObj.cp_Buyer_Name__c = productWrapperObj.Buyer_Name;
                        
                        //RSP value assignment
                        if(String.isNotBlank(productWrapperObj.RSP)){
                            String rspVal = (productWrapperObj.RSP.trim()).remove('$');
                            if(String.isNotBlank(rspVal)){
                                productObj.Retail_price_of_product__c = Decimal.valueOf(rspVal.replaceAll(',', ''));
                            }                                                        
                        }                        
                                                
                        productObj.Gender__c = productWrapperObj.Gender;
                        productObj.Demo__c = productWrapperObj.Demo;
                        productObj.Size__c = productWrapperObj.Size;
                        productObj.Product_Status__c = productWrapperObj.Product_Status;
                        
                        if(!String.isBlank(productWrapperObj.Set_Date)){
                            productObj.Set_Date__c = Date.parse(productWrapperObj.Set_Date);
                        }                        
                        if(!String.isBlank(productWrapperObj.Retired_Date)){
                            productObj.Retire_Date__c = Date.parse(productWrapperObj.Retired_Date);
                        }
                        // Date Uploaded
                        productObj.UPC_Upload_Date__c = DateTime.parse(Datetime.now().format());
                        productObj.Flow_Through_Flag__c = productWrapperObj.Flow_through_Flag;
                        if(!String.isBlank(productWrapperObj.Flow_through_Start_Date)){
                            productObj.Flow_Through_Start_Date__c = Date.parse(productWrapperObj.Flow_through_Start_Date);
                        }
                        if(!String.isBlank(productWrapperObj.Flow_through_End_Date)){
                            productObj.Flow_Through_End_Date__c = Date.parse(productWrapperObj.Flow_through_End_Date);
                        }
                        productObj.Promotional_Flag__c = productWrapperObj.Promotional_Flag;
                        if(!String.isBlank(productWrapperObj.Promotional_Start_Date)){
                            productObj.Promotional_Start_Date__c = Date.parse(productWrapperObj.Promotional_Start_Date);
                        }
                        if(!String.isBlank(productWrapperObj.Promotional_End_Date)){
                            productObj.Promotional_End_Date__c = Date.parse(productWrapperObj.Promotional_End_Date);
                        }
                        
                        /*
                        //check upc validation
                        if(!String.isBlank(productWrapperObj.upc) && mapUPCData.containsKey(productWrapperObj.upc)) {
                        productObj.UPC__c = productWrapperObj.UPC;
                        productObj.UPC_in_Starlab__c = True;
                        }
                        if(!String.isBlank(productWrapperObj.upc) && !mapUPCData.containsKey(productWrapperObj.upc)) {
                        productObj.UPC__c = productWrapperObj.UPC;
                        }
                        System.debug('productObj.UPC__c --> '+ productObj.UPC__c);
                        System.debug('productObj.UPC_in_Starlab__c --> '+ productObj.UPC_in_Starlab__c);
                        */

                        //check UPC(GTIN) validation
                        if(!String.isBlank(productWrapperObj.GTIN) && mapUPCData.containsKey(productWrapperObj.GTIN)) {
                            productObj.UPC_in_Starlab__c = True;
                        }
                        if(!String.isBlank(productWrapperObj.GTIN) && !mapUPCData.containsKey(productWrapperObj.GTIN)) {
                            //productObj.UPC__c = productWrapperObj.GTIN;
                        }

                        insertProductData.add(productObj);
                    }
                }
            }
            //-------------- Success -------------------------------------------------------------            
            //-------------- Insertion -------------------------------------------------------------
            if(!insertProductData.isEmpty()){
                List<Database.SaveResult> dataBaseResult;
                Set<Id> errorRecIds = new Set<Id>();
                Map<String,String> mapErrRecName = new Map<String,String>();
                try{
                    dataBaseResult = Database.insert(insertProductData,false);
                    successProductWrapper.clear();
                }catch(Exception ex){
                    throw new AuraHandledException('EXCEPTION: '+ex.getMessage());
                }                
                for(Database.SaveResult res : dataBaseResult){
                    if(!res.isSuccess()){
                        Database.Error error = res.getErrors().get(0);
                        String errorMsg = error.getMessage();
                        if(errorMsg.contains('CP_Product_Key__c')){
                            errorRecIds.add(errorMsg.substringAfter('id: '));
                        }
                    }
                }
                if(!errorRecIds.isEmpty()){
                    for(CP_Product__c obj : CP_ProductUtility.getErrorRecProductsName(errorRecIds)){
                        mapErrRecName.put(String.valueOf(obj.Id).left(15), obj.Name);
                    }
                }                
                for(Integer i=0; i<dataBaseResult.size(); i++){
                    CP_Product__c product = insertProductData[i];
                    ProductWrapper productWrapperObj = new ProductWrapper();
                    if(product.Licensee__c != null){
                        productWrapperObj.Licensee_Name = productWrapperTableData[i].Licensee_Name;
                    }
                    if(product.WBCP_Country__c != null){
                        productWrapperObj.Country = productWrapperTableData[i].Country;
                    }
                    productWrapperObj.GTIN = product.GTIN__c;
                    productWrapperObj.MPN = product.MPN__c;
                    productWrapperObj.MPN_Description = product.cp_MPN_Description__c;
                    if(product.cp_Retailer_Description__c != null){
                        productWrapperObj.Retailer = product.cp_Retailer_Description__c;
                    }
                    productWrapperObj.Retailer_SKU = product.Retailer_SKU__c;
                    if(product.cp_Buyer_Name__c != null){
                        productWrapperObj.Buyer_Name = productWrapperTableData[i].Buyer_Name;
                    }
                    if(product.cp_Licensed_Property__c != null){
                        productWrapperObj.Licensed_Property = product.cp_Licensed_Property__c;
                    }
                    productWrapperObj.Item_Description = product.Item_Descrption__c;
                    productWrapperObj.Category = product.Category__c;
                    productWrapperObj.Buyer_Name = product.cp_Buyer_Name__c;
                    productWrapperObj.RSP = String.valueOf(product.Retail_price_of_product__c)!= null ? '$' + String.valueOf(product.Retail_price_of_product__c) : '';
                    productWrapperObj.Sub_Category = product.Sub_Category__c;
                    productWrapperObj.Gender = product.Gender__c;
                    productWrapperObj.Demo = product.Demo__c;
                    productWrapperObj.Size = product.Size__c;
                    if(product.Set_Date__c != null){
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(product.Set_Date__c,myTime);
                        productWrapperObj.Set_Date = dt.format('M/d/YYYY');
                    }
                    if(product.Retire_Date__c != null){
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(product.Retire_Date__c,myTime);
                        productWrapperObj.Retired_Date = dt.format('M/d/YYYY');
                    }
                    productWrapperObj.Product_Status = product.Product_Status__c;
                    productWrapperObj.Flow_through_Flag = product.Flow_Through_Flag__c;
                    if(product.Flow_Through_Start_Date__c != null){
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(product.Flow_Through_Start_Date__c,myTime);
                        productWrapperObj.Flow_through_Start_Date = dt.format('M/d/YYYY');
                    }
                    if(product.Flow_through_End_Date__c != null){
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(product.Flow_through_End_Date__c,myTime);
                        productWrapperObj.Flow_through_End_Date = dt.format('M/d/YYYY');
                    }
                    productWrapperObj.Promotional_Flag = product.Promotional_Flag__c;
                    if(product.Promotional_Start_Date__c != null){
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(product.Promotional_Start_Date__c,myTime);
                        productWrapperObj.Promotional_Start_Date = dt.format('M/d/YYYY');
                    }
                    if(product.Promotional_End_Date__c != null){
                        Time myTime = Time.newInstance(0, 0, 0, 0);
                        DateTime dt = DateTime.newInstance(product.Promotional_End_Date__c,myTime);
                        productWrapperObj.Promotional_End_Date = dt.format('M/d/YYYY');
                    }
                    //upc check
                    /*if(product.UPC__c != null){
                    System.debug('product.UPC__c != null --> '+product.UPC__c);
                    System.debug('product.UPC_in_Starlab__c --> '+product.UPC_in_Starlab__c);
                    productWrapperObj.UPC = product.UPC__c;
                    if(!product.UPC_in_Starlab__c){
                    productWrapperObj.upcErrorOccured = True;
                    }
                    }else{
                    System.debug('product.UPC__c != null <--> '+product.UPC__c);
                    System.debug('product.UPC_in_Starlab__c <--> '+product.UPC_in_Starlab__c);
                    productWrapperObj.upcErrorOccured = False;
                    }
                    */
                    //upc(GTIN) check
                    if(product.GTIN__c != null){
                        if(!product.UPC_in_Starlab__c){
                            productWrapperObj.upcErrorOccured = True;
                        }
                    }else{
                        productWrapperObj.upcErrorOccured = False;
                    }
                    if (!dataBaseResult[i].isSuccess()){
                        Database.Error error = dataBaseResult[i].getErrors().get(0);
                        String errorMessage = '';
                        Boolean flag = false;
                        String[] errFields = error.getFields();
                        if(error.getMessage().contains('duplicate value found: CP_Product_Key__c')){
                            if(!mapErrRecName.isEmpty() && mapErrRecName.containsKey(error.getMessage().substringAfter('id: '))){
                                errorMessage = String.format(system.label.WBCP_CP_Product_Duplicates_Error_Msg, new String[] {mapErrRecName.get(error.getMessage().substringAfter('id: '))});
                                flag = true;
                            }
                        }
                        if(flag){
                            productWrapperObj.validation = errorMessage;
                        }else{
                            productWrapperObj.validation = error.getMessage();
                        }
                        productWrapperObj.errFields = errFields;
                        productWrapperObj.Licensee_Name = productWrapperTableData[i].Licensee_Name;
                        productWrapperObj.Country = productWrapperTableData[i].Country;
                        productWrapperObj.Retailer = productWrapperTableData[i].Retailer;
                        productWrapperObj.Retailer_SKU = productWrapperTableData[i].Retailer_SKU;
                        productWrapperObj.Licensed_Property = productWrapperTableData[i].Licensed_Property;
                        productWrapperObj.errorOccured = true;
                        errorProductWrapper.add(productWrapperObj);
                    }
                    else{
                        if(productWrapperObj.upcErrorOccured != null && productWrapperObj.upcErrorOccured){
                            productWrapperObj.validation = 'Product created successfully, But UPC not present in starlab';
                        }else{
                            productWrapperObj.validation = 'Product created successfully';
                        }
                        productWrapperObj.errorOccured = false;
                        productWrapperObj.isInserted = true;
                        successProductWrapper.add(productWrapperObj);
                    }
                }
            }
            if(!errorProductWrapper.isEmpty()){
                returnProductWrapper.addAll(errorProductWrapper);
            }
            if(!successProductWrapper.isEmpty()){
                returnProductWrapper.addAll(successProductWrapper);
            }
            return returnProductWrapper;
            //-------------- Insertion -------------------------------------------------------------
        }else{
            throw new AuraHandledException('No Data Entered');
        }
    }
    
    public class ProductWrapper{
        @auraEnabled public String Licensee_Name {get; set;} //LookUp Account
        @auraEnabled public String Country {get; set;}
        @auraEnabled public String GTIN {get; set;}
        @auraEnabled public String MPN {get; set;}
        @auraEnabled public String MPN_Description {get; set;}
        @auraEnabled public String Retailer {get; set;} // Picklist Values
        @auraEnabled public String Retailer_SKU {get; set;}
        @auraEnabled public String Licensed_Property {get; set;}
        @auraEnabled public String Item_Description {get; set;}
        @auraEnabled public String Category {get; set;}
        @auraEnabled public String Sub_Category {get; set;}
        @auraEnabled public String Buyer_Name {get; set;} //LookUp Contact
        @auraEnabled public String RSP {get; set;}
        @auraEnabled public String Gender {get; set;}
        @auraEnabled public String Demo {get; set;}
        @auraEnabled public String Size {get; set;}
        @auraEnabled public String Set_Date {get; set;} //Date
        @auraEnabled public String Retired_Date {get; set;} //Date
        @auraEnabled public String Product_Status {get; set;}
        @auraEnabled public String Flow_through_Flag {get; set;}
        @auraEnabled public String Flow_through_Start_Date {get; set;} //Date
        @auraEnabled public String Flow_through_End_Date {get; set;} //Date
        @auraEnabled public String Promotional_Flag {get; set;}
        @auraEnabled public String Promotional_Start_Date {get; set;} //Date
        @auraEnabled public String Promotional_End_Date {get; set;} //Date
        @auraEnabled public String CP_Product_Key {get; set;}
        @auraEnabled public Boolean upcErrorOccured {get; set;}
        @auraEnabled public Integer rowIndex {get; set;}
        @auraEnabled public String Validation {get; set;}
        @auraEnabled public String[] errFields {get; set;}
        @auraEnabled public Boolean errorOccured {get; set;}
        @auraEnabled public Boolean isRowRemoved {get; set;}
        @auraEnabled public Boolean isInserted {get; set;}
    }
    
    static Boolean validateRSP(String qty){
        if(qty != null && qty.trim().length() > 0){
            try{
                Decimal d = Decimal.valueOf(qty.replaceAll(',', ''));
            }catch(system.Exception e){
                return true;
            }    
        }
        return false;
    }
    
    public class AuraHandledException extends Exception {}
}