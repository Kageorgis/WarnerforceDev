public class massCPUploaderApexController {
    @AuraEnabled
    public static LookupWrapper getLookupValues(){

        LookupWrapper returnListWrapper =new LookupWrapper();
        List<Account> retAccounts = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' ORDER BY Name];
        List<Property__c> propRecs = [SELECT Id,Name FROM Property__c];
        List<User> u = [SELECT Name, Account.Name, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        WBCP_Country__c defCountry = [SELECT Id, Name FROM WBCP_Country__c WHERE Name ='United States'];
      //  List<Category_Dependecy__mdt> catMap = [SELECT Label,Category__c,Sub_Category__c,LOB__c,LOB_Type_c__c,NAM_Sub_Category__c,NAM_Category__c FROM Category_Dependecy__mdt ORDER BY Sub_Category__c];
        List<String> retVals = new List<String>();
        List<String> propVals = new List<String>();
        List<String> catVals = new List<String>();
        List<String> subVals = new List<String>();
        String accountId = '';
        System.debug('accId = ' + u[0].Account.Name);
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
        for(Category_Dependecy__mdt cat:[SELECT Label,Category__c,Sub_Category__c,LOB__c,LOB_Type_c__c,NAM_Sub_Category__c,NAM_Category__c FROM Category_Dependecy__mdt ORDER BY NAM_Sub_Category__c]){
            String catVal = cat.Category__c;
            catVals.add(catVal);
            String subVal = cat.Sub_Category__c;
            subVals.add(subVal);
        }
        returnListWrapper.subValues = subVals;
        returnListWrapper.catValues = catVals;
        returnListWrapper.retValues = retVals;
        returnListWrapper.propValues = propVals;
        returnListWrapper.defaultLicensee = accountId;
        returnListWrapper.defaultCountry = defCountry.Name;
        System.debug(returnListWrapper);
        return returnListWrapper;
    }
    public class LookupWrapper{
        @auraEnabled public List<String> subValues {get; set;}
        @auraEnabled public List<String> catValues {get; set;}
        @auraEnabled public List<String> retValues {get; set;}
        @auraEnabled public List<String> propValues {get; set;}
        @auraEnabled public String defaultLicensee {get; set;}
        @auraEnabled public String defaultCountry {get; set;}
    }
	@AuraEnabled
    public static List<ProductWrapper> saveRecordsApexMethod(List<ProductWrapper> productWrapperTableData){
        System.debug('productWrapperTableData :-- ' + productWrapperTableData);

        if(!productWrapperTableData.isEmpty()){
            System.debug('productWrapperTableData :-- ' + productWrapperTableData.size());
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
                    System.debug('obj.Licensee_Name ##### '+obj.Licensee_Name);
                    System.debug('obj.Country @@@ '+obj.Country);
                    accountNames.add(obj.Licensee_Name);
                }
               //  Retailer Lookup
                  if(!String.isBlank(obj.Retailer)){
                    System.debug('obj.Retailer #####-- '+obj.Retailer);
                    System.debug('obj.Country @@@ '+obj.Country);
                    retailerNames.add(obj.Retailer);
                }
                if(!String.isBlank(obj.Licensed_Property)){
                    System.debug('obj.Licensed_Property #####-- '+obj.Licensed_Property);
                    propertyNames.add(obj.Licensed_Property);
                }

                if(!String.isBlank(obj.Buyer_Name)){
                    String conName = obj.Buyer_Name.replaceAll('\\s+','');
                    System.debug('conName ===>'+conName);
                    contactNames.add(conName);
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
               System.debug('GTINCountMap -- >> '+GTINCountMap);
            }
            
            Map<String,Account> mapAccountsData = new Map<String,Account>();
            if(!accountNames.isEmpty()){
                System.debug('accountNames size-- '+ accountNames.size());
                for(Account accObj : [SELECT Id, Name FROM Account WHERE Name IN :accountNames]){
                    mapAccountsData.put(accObj.Name,accObj);
                }
                System.debug('accountNames in map **-- '+ accountNames);
            }
            Map<String,Account> mapRetailersData = new Map<String,Account>();
            if(!retailerNames.isEmpty()){
                System.debug('retailerNames size-- '+ retailerNames.size());
                for(Account retObj : [SELECT Id, Name FROM Account WHERE Name IN :retailerNames AND RecordType.Name = 'WBCP Retailer']){
                    System.debug('MM - RetObj'+retObj);
                    mapRetailersData.put(retObj.Name,retObj);
                }
                System.debug('retailerNames in map **-- '+ retailerNames);
            }
            System.debug('contactNames -- ' + contactNames);
            System.debug('contactNames -- ' + contactNames);
            Map<String,Contact> mapContactData = new Map<String,Contact>();
            if(!contactNames.isEmpty()){
                for(Contact contObj : [SELECT Id, Name FROM Contact WHERE Contact_Name__c IN :contactNames]){
                    mapContactData.put(contObj.Name,contObj);
                }
            }
			System.debug('mapContactData -->> ' + mapContactData);
            
            Map<String,WBCP_Country__c> mapCountryData = new Map<String,WBCP_Country__c>();
            System.debug('countryNames.isEmpty() '+countryNames);
            if(!countryNames.isEmpty()){
                for(WBCP_Country__c countryObj : [SELECT Id, Name FROM WBCP_Country__c WHERE Name IN :countryNames]){
                    System.debug('countryObj ' + countryObj);
                    mapCountryData.put(countryObj.Name,countryObj);
                }
            }

            //  Property Lookup
            Map<String,Property__c> mapPropertiesData = new Map<String,Property__c>();
            if(!propertyNames.isEmpty()){
                System.debug('propertyNames size-- '+ propertyNames.size());
                for(Property__c propObj : [SELECT Id, Name FROM Property__c WHERE Name IN :propertyNames]){
                    System.debug('MM - propObj'+propObj);
                    mapPropertiesData.put(propObj.Name,propObj);
                }
                System.debug('propertyNames in map **-- '+ propertyNames);
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
            System.debug('upcNumbers --> '+ upcNumbers);
            if(!upcNumbers.isEmpty()){
                for(StarLabs_Product__c starLabProductObj : [SELECT Id, UPC__c FROM StarLabs_Product__c WHERE UPC__c IN :upcNumbers]){
                    System.debug('starLabProductObj ' + starLabProductObj);
                    mapUPCData.put(starLabProductObj.UPC__c,starLabProductObj);
                }
            }
			System.debug('mapUPCData --->> '+ mapUPCData);
            
            //List<String> lpPickVal = Label.Licensed_Property_Picklist_Values.split(';');
            //List<String> ctPickVal = Label.Category_Picklist_Values.split(';');
            //List<String> retPickVal = Label.Retailer_Picklist_Values.split(';');
          //  List<String> sc1PickVal = Label.Sub_Category_Picklist_Values_1.split(';');
            //List<String> sc2PickVal = Label.Sub_Category_Picklist_Values_2.split(';');
            List<String> demoPickVal = Label.Demo_Picklist_Values.split(';');
            
            List<ProductWrapper> InvalidProductWrapper = new List<ProductWrapper>();
            List<ProductWrapper> successProductWrapper = new List<ProductWrapper>();       
            List<ProductWrapper> errorProductWrapper = new List<ProductWrapper>();
            List<ProductWrapper> toBeInserted = productWrapperTableData;
           
            //-------------- Validation -------------------------------------------------------------
            for(ProductWrapper productWrapperObj : productWrapperTableData){
                if(productWrapperObj.isInserted != True && productWrapperObj.isRowRemoved != True){
                   String str = '';
                   String GTINSKU = productWrapperObj.GTIN + productWrapperObj.Retailer_SKU;
                   System.debug('GTINSKU -->' + GTINSKU);
                    
                    if(String.isBlank(productWrapperObj.Licensee_Name) || (!String.isBlank(productWrapperObj.Licensee_Name) && (productWrapperObj.Licensee_Name).length() > 80)){
                    	str = ' Please enter Licensee name.';
                	}
                    
                    if(String.isBlank(productWrapperObj.Country) || (!String.isBlank(productWrapperObj.Country) && (productWrapperObj.Country).length() > 80)){
                    	str = Str + ' Please enter Country name.';
                	}
                    
                    if(String.isBlank(productWrapperObj.GTIN)){
                    	str = Str + ' The GTIN you entered is not valid, Please check the number and re-enter.';
                	}
                    
                    if(!String.isBlank(productWrapperObj.GTIN) && GTINCountMap.containsKey(GTINSKU) && GTINCountMap.get(GTINSKU) > 1){
                        str = Str + ' Duplicate record found, combination of GTIN and Retilaer SKU should be unique.';                          
                	}
                    
                    if(String.isBlank(productWrapperObj.MPN)){
                    	str = Str + ' The MPN you entered is not valid, Please check the number and re-enter.';
                	}
                    
                    // Retailer picklist-- 
                    System.debug('MM -- productWrapperObj.Retailer -->'+ productWrapperObj.Retailer);
                    if(String.isBlank(productWrapperObj.Retailer) || (!String.isBlank(productWrapperObj.Retailer) && (productWrapperObj.Retailer).length() > 80)){
                        System.debug('In if...');
                    	str = Str + ' Please enter Retailer.';
                	}
                    // Retailer picklist--
                    System.debug('MM -- productWrapperObj.Licensed_Property -->'+ productWrapperObj.Licensed_Property);
                    if(String.isBlank(productWrapperObj.Licensed_Property) || (!String.isBlank(productWrapperObj.Licensed_Property) && (productWrapperObj.Licensed_Property).length() > 80)){
                        System.debug('In if...');
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

                    if(String.isBlank(productWrapperObj.Sub_Category) || String.isBlank(productWrapperObj.Demo) || !demoPickVal.contains(productWrapperObj.Demo)){
                        str =str + ' Please check the picklist values of Sub Category, Demo.';
                    }
                    
                    if(!String.isBlank(productWrapperObj.Set_Date) && !String.isBlank(productWrapperObj.Retired_Date)){
                    	Date setDate = 	Date.parse(productWrapperObj.Set_Date);
                        Date retiredDate = 	Date.parse(productWrapperObj.Retired_Date);
                        System.debug('setDate -->> '+setDate);
                        System.debug('retiredDate -->> '+retiredDate);
                        if(setDate >= retiredDate){
                            str =str + ' Retired Date should be greater than Set Date';
                        }
                    }
                    
                    if(!String.isBlank(productWrapperObj.Flow_through_Start_Date) && !String.isBlank(productWrapperObj.Flow_through_End_Date)){
                    	Date startDate = 	Date.parse(productWrapperObj.Flow_through_Start_Date);
                        Date endDate = 	Date.parse(productWrapperObj.Flow_through_End_Date);
                        System.debug('startDate -->> '+startDate);
                        System.debug('endDate -->> '+endDate);
                        if(startDate >= endDate){
                            str =str + ' Flow-through Start Date should be greater than Flow-through End Date';
                        }
                    }
                    
                    if(!String.isBlank(productWrapperObj.Promotional_Start_Date) && !String.isBlank(productWrapperObj.Promotional_End_Date)){
                    	Date startDate = 	Date.parse(productWrapperObj.Promotional_Start_Date);
                        Date endDate = 	Date.parse(productWrapperObj.Promotional_End_Date);
                        System.debug('startDate -->> '+startDate);
                        System.debug('endDate -->> '+endDate);
                        if(startDate >= endDate){
                            str =str + ' Promotional Start Date should be greater than Promotional End Date';
                        }
                    }
                    System.debug('productWrapperObj.validation==>'+productWrapperObj.validation);
                	System.debug('str==> '+str);
                    
                    productWrapperObj.validation = str;
                	productWrapperObj.errorOccured = false;                    
                    System.debug('productWrapperObj.validation==>'+productWrapperObj.validation);
                    
                    if(!String.isBlank(productWrapperObj.validation)){
                        System.debug('inside error==> '+ productWrapperObj.validation);
                        productWrapperObj.errorOccured = true;
                        errorProductWrapper.add(productWrapperObj);
                    }else{
                        System.debug('inside success==>');
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
                    	
                        System.debug('Success productWrapperObj.Licensee_Name ' + productWrapperObj.Licensee_Name);
                        if(!String.isBlank(productWrapperObj.Licensee_Name) && mapAccountsData.containsKey(productWrapperObj.Licensee_Name)){
                            System.debug('ID --- '+ mapAccountsData.get(productWrapperObj.Licensee_Name).Id);
                            productObj.Licensee__c = mapAccountsData.get(productWrapperObj.Licensee_Name).Id;
                            System.debug('productObj.Licensee__c --- '+ productObj.Licensee__c);
                		}
                        
                        System.debug('Success productWrapperObj.Country ' + productWrapperObj.Country);
                        System.debug('mapCountryData ' + mapCountryData.values());
                        if(!String.isBlank(productWrapperObj.Country) && mapCountryData.containsKey(productWrapperObj.Country)){
                            System.debug('CountryID --- '+ mapCountryData.get(productWrapperObj.Country).Id);
                            productObj.WBCP_Country__c = mapCountryData.get(productWrapperObj.Country).Id;
                		}
                        
                        System.debug('productWrapperObj.GTIN --' + productWrapperObj.GTIN);
                    	productObj.GTIN__c = productWrapperObj.GTIN;
                    	productObj.MPN__c = productWrapperObj.MPN;
                      
                        
                      //  Retailer Lookup
                        System.debug('Success productWrapperObj.Retailer ' + productWrapperObj.Retailer);
                        if(!String.isBlank(productWrapperObj.Retailer) && mapRetailersData.containsKey(productWrapperObj.Retailer)){
                            System.debug('RETAILER ID --- '+ mapRetailersData.get(productWrapperObj.Retailer).Id);
                            System.debug('RETAILER Name --- '+ mapRetailersData.get(productWrapperObj.Retailer).Name);

                            productObj.cp_Retailer_Description__c = mapRetailersData.get(productWrapperObj.Retailer).Id;
                            System.debug('productObj.cp_Retailer_Description__c --- '+ productObj.cp_Retailer_Description__c);
                        }

                        
                        // Retailer picklist
                    	//productObj.cp_Retailer_Description__c = productWrapperObj.Retailer;
                        if(mapRetailersData.get(productWrapperObj.Retailer).Name.contains('Other')){
                            productObj.Retailer_SKU__c = 'Other';

                        }
                        else{
                            productObj.Retailer_SKU__c = productWrapperObj.Retailer_SKU;

                        }

                        if(!String.isBlank(productWrapperObj.Buyer_Name) && mapContactData.containsKey(productWrapperObj.Buyer_Name)){
                            productObj.Buyer_Name__c = mapContactData.get(productWrapperObj.Buyer_Name).Id;
                        }
                        //Property Lookup
                        System.debug('Success productWrapperObj.Licensed_Property ' + productWrapperObj.Licensed_Property);
                        if(!String.isBlank(productWrapperObj.Licensed_Property) && mapPropertiesData.containsKey(productWrapperObj.Licensed_Property)){
                            System.debug('PROPERTY ID --- '+ mapPropertiesData.get(productWrapperObj.Licensed_Property).Id);
                            System.debug('Property Name --- '+ mapPropertiesData.get(productWrapperObj.Licensed_Property).Name);

                            productObj.cp_Licensed_Property__c = mapPropertiesData.get(productWrapperObj.Licensed_Property).Id;
                            System.debug('productObj.cp_Licensed_Property__c --- '+ productObj.cp_Licensed_Property__c);
                        }
//                        productObj.Licensed_Property__c = productWrapperObj.Licensed_Property;
                        productObj.Item_Descrption__c = productWrapperObj.Item_Description;
                        productObj.Category__c = productWrapperObj.Category;
                        productObj.Sub_Category__c = productWrapperObj.Sub_Category;
						//productObj.Buyer_Name__c = productWrapperObj.Buyer_Name;
						productObj.Retail_price_of_product__c = productWrapperObj.RSP;
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
                        
                        // LOB
                        //productObj.LOB__c = Label.Product_LOB_Value;
                        
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
                            //productObj.UPC__c = productWrapperObj.GTIN;
                            productObj.UPC_in_Starlab__c = True;
                        }
                        if(!String.isBlank(productWrapperObj.GTIN) && !mapUPCData.containsKey(productWrapperObj.GTIN)) { 
                            //productObj.UPC__c = productWrapperObj.GTIN;
                        }
                        //System.debug('productObj.UPC__c --> '+ productObj.UPC__c);
                        System.debug('productObj.UPC_in_Starlab__c --> '+ productObj.UPC_in_Starlab__c);
                        
                        insertProductData.add(productObj);
                    }                    
                }
            }
            //-------------- Success -------------------------------------------------------------
            
            //-------------- Insertion -------------------------------------------------------------
            System.debug('START INSERT SinsertProductData -- '+ insertProductData);
            if(!insertProductData.isEmpty()){            
                List<Database.SaveResult> dataBaseResult;
                Set<Id> errorRecIds = new Set<Id>();
                Map<String,String> mapErrRecName = new Map<String,String>();
                try{
                    dataBaseResult = Database.insert(insertProductData,false);                    
                    successProductWrapper.clear();                    
                    System.debug('dataBaseResult ----' + dataBaseResult);
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
                System.debug('errorRecIds --> '+ errorRecIds);
                if(!errorRecIds.isEmpty()){
                    for(CP_Product__c obj : [Select Id, Name FROM CP_Product__c WHERE Id IN :errorRecIds]){
                        mapErrRecName.put(String.valueOf(obj.Id).left(15), obj.Name);
                    }
                }
                System.debug('mapErrRecName -- > '+mapErrRecName);                
                
                for(Integer i=0; i<dataBaseResult.size(); i++){
                    System.debug('insertProductData[i] == ' + insertProductData[i]);                    
                    CP_Product__c product = insertProductData[i];                    
                    ProductWrapper productWrapperObj = new ProductWrapper();
                    System.debug('I ------------ ' + i);
                    if(product.Licensee__c != null){
                        System.debug('productWrapperTableData[i].Licensee -- ' + productWrapperTableData[i].Licensee_Name);                      
                        productWrapperObj.Licensee_Name = productWrapperTableData[i].Licensee_Name;                        
                    }
                    if(product.WBCP_Country__c != null){
                        System.debug('productWrapperTableData[i].Country -- ' + productWrapperTableData[i].Country);
                        productWrapperObj.Country = productWrapperTableData[i].Country;                        
                    }
                    
                    productWrapperObj.GTIN = product.GTIN__c;
                    productWrapperObj.MPN = product.MPN__c;
                    

                    if(product.cp_Retailer_Description__c != null){
                        productWrapperObj.Retailer = productWrapperTableData[i].Retailer;
                    }

                  //  productWrapperObj.Retailer = product.cp_Retailer_Description__c;
                    productWrapperObj.Retailer_SKU = product.Retailer_SKU__c;
                    
                    if(product.Buyer_Name__c != null){
                        productWrapperObj.Buyer_Name = productWrapperTableData[i].Buyer_Name;
                    }
                    if(product.cp_Licensed_Property__c != null){
                        System.debug('productWrapperTableData[i].Licensed_Property-- ' + productWrapperTableData[i].Licensed_Property);

                        productWrapperObj.Licensed_Property = productWrapperTableData[i].Licensed_Property;
                    }
                  //  productWrapperObj.Licensed_Property = product.Licensed_Property__c;
                    productWrapperObj.Item_Description = product.Item_Descrption__c;
                    productWrapperObj.Category = product.Category__c;
                    //productWrapperObj.Buyer_Name = product.Buyer_Name__c;
                    productWrapperObj.RSP = product.Retail_price_of_product__c;
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
                        System.debug('product.GTIN__c != null --> '+product.GTIN__c);
                        System.debug('product.UPC_in_Starlab__c --> '+product.UPC_in_Starlab__c);
                        //productWrapperObj.UPC = product.UPC__c;                        
                        if(!product.UPC_in_Starlab__c){
                            productWrapperObj.upcErrorOccured = True;
                        }
                    }else{
                        System.debug('product.UPC__c != null <--> '+product.GTIN__c);
                        System.debug('product.UPC_in_Starlab__c <--> '+product.UPC_in_Starlab__c);
                        productWrapperObj.upcErrorOccured = False;
                    }

                    if (!dataBaseResult[i].isSuccess()){
                        Database.Error error = dataBaseResult[i].getErrors().get(0);
                        String errorMessage = '';
                        Boolean flag = false;
                        System.debug('productWrapperObj.validation ==>>' + error);
                        System.debug('productWrapperObj.validation ==>>' + error.getMessage().contains('duplicate value found: CP_Product_Key__c'));
                        if(error.getMessage().contains('duplicate value found: CP_Product_Key__c')){
                            System.debug('mapErrRecName************ '+mapErrRecName );
                            System.debug('mapErrRecName************ '+mapErrRecName.containsKey(error.getMessage().substringAfter('id: ')));                            
                            if(!mapErrRecName.isEmpty() && mapErrRecName.containsKey(error.getMessage().substringAfter('id: '))){                                      
                                errorMessage = error.getMessage().replace(error.getMessage().substringAfter('id: '), mapErrRecName.get(error.getMessage().substringAfter('id: ')));
                                flag = true;
                            }
                        }
                        //productWrapperObj.validation = error.getMessage();
                        System.debug('productWrapperObj.validation = error.getMessage(); ' + productWrapperObj.validation);
                        if(flag){
                            productWrapperObj.validation = errorMessage;
                        }else{
                            productWrapperObj.validation = error.getMessage();
                        }                        
                        System.debug('productWrapperObj.validation ==>>' + productWrapperObj.validation);
                        productWrapperObj.errorOccured = true;
                        errorProductWrapper.add(productWrapperObj);
                    }
                    else{
                        // upcErrorOccured
                        System.debug('upcErrorOccured <--> '+productWrapperObj.upcErrorOccured);
                        if(productWrapperObj.upcErrorOccured != null && productWrapperObj.upcErrorOccured){
                            productWrapperObj.validation = 'Product created successfully, But UPC not present in starlab';
                        }else{
                         	productWrapperObj.validation = 'Product created successfully';   
                        }
                        //productWrapperObj.validation = 'Product created successfully';   
                        productWrapperObj.errorOccured = false;
                        productWrapperObj.isInserted = true;
                        successProductWrapper.add(productWrapperObj);
                    }
                }
            }
            
            if(!errorProductWrapper.isEmpty()){
                 System.debug('errorProductWrapper'+errorProductWrapper);
            	returnProductWrapper.addAll(errorProductWrapper);    
            }
            
            if(!successProductWrapper.isEmpty()){
            	returnProductWrapper.addAll(successProductWrapper);    
            }
            
            System.debug('returnProductWrapper'+returnProductWrapper);
            System.debug('returnProductWrapper.size()'+returnProductWrapper.size());
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
        //@auraEnabled public String Retailer {get; set;} //LookUp Account
        @auraEnabled public String Retailer {get; set;} // Picklist Values
        @auraEnabled public String Retailer_SKU {get; set;}
        @auraEnabled public String Licensed_Property {get; set;}
        @auraEnabled public String Item_Description {get; set;} 
        @auraEnabled public String Category {get; set;}
        @auraEnabled public String Sub_Category {get; set;}
        @auraEnabled public String Buyer_Name {get; set;} //LookUp Contact
        @auraEnabled public Decimal RSP {get; set;}
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
        
        //@auraEnabled public String UPC {get; set;} //UPC
        @auraEnabled public Boolean upcErrorOccured {get; set;}
        
        @auraEnabled public String Validation {get; set;}        
        @auraEnabled public Boolean errorOccured {get; set;}
        @auraEnabled public Boolean isRowRemoved {get; set;}
        @auraEnabled public Boolean isInserted {get; set;}
        
    }
    public class AuraHandledException extends Exception {}


}