public class WB_PBEP_Product_CreationHandler {
    
    static Set<String> clientAvailLocalDataCategorySet = new Set<string>();
    static Set<String> releasePlanStatus = new Set<string>{WB_PriceUtility.STATUS_CONF,WB_PriceUtility.STATUS_TENTVE};
    static {
        String categoryLabel = System.Label.CRM_Client_Avail_Local_Data_Category;
        if(categoryLabel != null){
            clientAvailLocalDataCategorySet.addAll(categoryLabel.split(';'));
        }
    }
        
    public void assignProductToReleasePlan(List<Commercial_Avail__c> releasePlanTriggerList){
        
        WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = true;//Setting flag to 'true' to avoid recursive update of RP
        try{
            List<String> releasePlanList = new List<String>();
        
            for(Commercial_Avail__c releasePlan:releasePlanTriggerList){
                if(releasePlan.Product__c == null){
                    releasePlanList.add(releasePlan.Id);
                }           
            }
            
            if(releasePlanList.isEmpty())
                return;
            
            WB_Pricing_Settings__c  productSetting = WB_Pricing_Settings__c.getInstance('Create Product');
            if(productSetting != null && productSetting.Future__c == true && productSetting.Threshold__c != null && releasePlanList.size() > productSetting.Threshold__c){
                    assignProductToReleasePlanFuture(releasePlanList);
            }else{ 
                createProducts(releasePlanList);
            }
            
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception while creating Product '+ex.getMessage());
        }
        WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = false;//Re-Setting flag
    }
    
    //Akash : New method Start
    public void updateAssignedProductsFromRP(List<Commercial_Avail__c> releasePlanTriggerList,Map<Id,Commercial_Avail__c> releasePlanOldMap){
        WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = true;//Setting flag to 'true' to avoid recursive update of RP
        Set<String> ExtenalIdSet = new Set<String>();
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
	    List<Product2> lstProdUpdated = new List<Product2>();
	    
	    
	    List<Product2> productList = new List<Product2>();
	    List<Commercial_Avail__c> rpTobeAssigned = new List<Commercial_Avail__c>();
	    
	    Set<String> rpCountry = new Set<String>();
	    Set<String> rpLang = new Set<String>(); 
	    Set<String> rpVV = new Set<String>();
	    Set<String> rpChanel = new Set<String>();
	    Set<String> rpFormat = new Set<String>();
	    Map<String,Product2> productMap = new Map<String,Product2>();
	    
        try{
            List<String> releasePlanList = new List<String>();
            Map<Id,Commercial_Avail__c> rpTobeUpdated = new Map<Id,Commercial_Avail__c>();
            
             rpTobeUpdated = New Map<Id,Commercial_Avail__c>([Select id,name,Start_Date__c,Country_Lookup__c,Country_Code__c,Country_Lookup__r.Country_Code__c,
                                                             Languages__c,Languages__r.Name,Languages__r.Language_Code_2__c,Title_Video_Version__c,Channel__c,Format__c 
                                                             from Commercial_Avail__c 
                                                             where id IN : releasePlanTriggerList]);   //Fetching All RP's
            if(rpTobeUpdated.values().size() != null && rpTobeUpdated.values().size()>0){
                for(Commercial_Avail__c releasePlan:rpTobeUpdated.values()){
                    //SINC1727900 - 7/23/2018
                    //Excluded below logic for adding key values into Set from if criteria
                    rpCountry.add(releasePlan.Country_Lookup__r.Country_Code__c);
				    rpLang.add(releasePlan.Languages__r.Language_Code_2__c );
				    rpVV.add(releasePlan.Title_Video_Version__c);
				    rpChanel.add(releasePlan.Channel__c);
				    rpFormat.add(releasePlan.Format__c);
                    if( releasePlan != null && releasePlanOldMap != null && releasePlanOldMap.get(releasePlan.Id) != null){
                            if(releasePlan.Start_Date__c != null && releasePlanOldMap.get(releasePlan.Id).Start_Date__c != null 
                                && releasePlan.Start_Date__c != releasePlanOldMap.get(releasePlan.Id).Start_Date__c) {
                                    String externalId = getExternalId(releasePlan);	
            					    ExtenalIdSet.add(externalId);
            					    
            					    /*rpCountry.add(releasePlan.Country_Lookup__r.Country_Code__c);
            					    //rpLang.add(releasePlan.Languages__r.Language_Code_2__c );
            					    rpVV.add(releasePlan.Title_Video_Version__c);
            					    rpChanel.add(releasePlan.Channel__c);
            					    rpFormat.add(releasePlan.Format__c);*/
            			    }
            			    
                     }   
                     //SINC1727900 - 7/23/2018
                     else if( releasePlanOldMap == null ){
            			    String externalId = getExternalId(releasePlan);	
    					    ExtenalIdSet.add(externalId);    
    			     }
    			 }
            }
            if(!ExtenalIdSet.isEmpty()){ 
		        productList = getProducts(ExtenalIdSet); //Fetching the product against external id if exist
			 	for(Commercial_Avail__c rp : rpTobeUpdated.values()){ 
			 	    if(productList.size() != null && productList.size()>0){
			 	         for(Product2 prod : productList){
                            if(prod.External_Id__c != null && prod.Release_Plan__c == rp.Id && prod.Street_Date__c != rp.Start_Date__c){//If current rp to be updated is same as product's rp
				 		        prod.Street_Date__c = rp.Start_Date__c;       //update product's release date same as rp's start date
				 		  	    lstProdUpdated.add(prod);
				 		  	}
				 		  	if(prod.Release_Plan__c == NULL){ //Updated Condition on 6/15/2018 - SINC1727900
			 		  	        if(!productMap.containsKey(prod.External_Id__c))
			 		  	            productMap.put(prod.External_Id__c,prod);
				 		  	}
				 		 }
			 	    }
	            }
		    }
			Product_Creation_Batch_Setting__c pbSetting = Product_Creation_Batch_Setting__c.getInstance('Default');
			boolean CRMflag;
			if(pbSetting != null && pbSetting.Generate_CRM_Product__c!=false){
			    CRMflag = true;
			}
			
			rpTobeAssigned = [Select id,Start_Date__c,Country_Lookup__r.Country_Code__c,Languages__r.Language_Code_2__c,Title_Video_Version__c,
                                    Channel__c,Format__c from Commercial_Avail__c Where 
	 		  	                     Country_Lookup__r.Country_Code__c IN : rpCountry AND
	 		  	                     Languages__r.Language_Code_2__c IN : rpLang AND
	 		  	                     Title_Video_Version__c IN : rpVV AND
	 		  	                     Channel__c IN : rpChanel AND
	 		  	                     Country_Lookup__r.Generate_CRM_Product__c =: CRMflag AND
	 		  	                     Format__c IN : rpFormat ORDER BY Start_Date__c ASC];	   
	 		
	 		
	 		Map<String,List<Commercial_Avail__c>> rpExternalIDMap = new Map<String,List<Commercial_Avail__c>>();
	 		
	 		if(rpTobeAssigned!=null && rpTobeAssigned.size()>0){
	 		    for(Commercial_Avail__c rpRec : rpTobeAssigned ){
	 		        String key = getExternalId(rpRec);
	 		        if(!rpExternalIDMap.containsKey(key) ){
	 		            rpExternalIDMap.put(key,new List<Commercial_Avail__c>{rpRec});
	 		        }
	 		    }
	 		}
	 		for(Product2 productRec:productMap.values()){
	 		    if(productRec.Release_Plan__c == null && rpExternalIDMap.get(productRec.External_Id__c) != null) {
	 		        productRec.Release_Plan__c = rpExternalIDMap.get(productRec.External_Id__c)[0].Id;
	 		        productRec.Street_Date__c = rpExternalIDMap.get(productRec.External_Id__c)[0].Start_Date__c;
	 		        lstProdUpdated.add(productRec);
	 		    }
	 		}
	 		
	 		//if(!lstProdUpdated.isEmpty()){ 
             if(lstProdUpdated != NULL && lstProdUpdated.size()> 0){
                Database.SaveResult[] UpdateResult = Database.update(lstProdUpdated, false);
                createErrorLogList(UpdateResult,'Products',errorLogs);
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception while updating Product '+ex.getMessage());
            
        }
        WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = false;//Re-Setting flag
     }
    //Akash : New method Finish
    
    @future
    public static void assignProductToReleasePlanFuture(List<String> releasePlanList){
        WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = true;//Setting flag to 'true' avoid recursive update of RP
        try{ 
            WB_PBEP_Product_CreationHandler pbepProdHandler = new WB_PBEP_Product_CreationHandler();        
            pbepProdHandler.createProducts(releasePlanList);
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception while creating Product '+ex.getMessage());
        }
        WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = false;//Re-Setting flag
    }
    
    private void createProducts(List<String> releasePlanList){
        Map<String,Product2> mapProductExist = new Map<String,Product2>();
        Map<String,Product2> newProductsMap = new Map<String,Product2>();
        Set<String> setExtenalId = new Set<String>();
        Map<String,Commercial_Avail__c> releasePlanMap = new Map<String,Commercial_Avail__c>();
        List<Commercial_Avail__c> updatedReleasePlans = new List<Commercial_Avail__c>();
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        //List<Commercial_Avail__c> releasePlanList = new List<Commercial_Avail__c>();
        
        /*for(Commercial_Avail__c releasePlan:releasePlanTriggerList){
            if(releasePlan.Product__c == null){// && releasePlan.Status__c == CRM_AppConstants.CRM_Client_Avail_Status_Confirmed)
                releasePlanList.add(releasePlan);
            }           
        }
        
        if(releasePlanList.isEmpty())
            return;
        */
            
        String queryString = getReleasePlanQuery(releasePlanList);
        List<Commercial_Avail__c> retrievedReleasePlanList = Database.query(queryString);
                
        for(Commercial_Avail__c currentRelease : retrievedReleasePlanList){
            String externalId = getExternalId(currentRelease);
            setExtenalId.add(externalId);
            releasePlanMap.put(currentRelease.Id,currentRelease);
        }
        if(!setExtenalId.isEmpty()){ 
            List<Product2> productList = getProducts(setExtenalId); //Fetching the product against external id if exist
            for(Product2 prod : productList){
                if(prod.External_Id__c != null){
                    mapProductExist.put(prod.External_Id__c,prod);
                }
            }
        }
    
        for(String currentReleaseId : releasePlanMap.keySet()){
           Commercial_Avail__c currentRelease = releasePlanMap.get(currentReleaseId);
           String externalId = getExternalId(currentRelease);
           if(!mapProductExist.containskey(externalId)){
                Product2 currentProduct = new Product2();
                currentProduct.External_Id__c = externalId;
                doMappingFromReleasePlanToProduct(currentProduct, currentRelease);
                newProductsMap.put(externalId,currentProduct);
            }
            updatedReleasePlans.add(currentRelease);
        }
        
        if(!newProductsMap.values().isEmpty()){
            Database.SaveResult[] insertUpdateResult = Database.insert(newProductsMap.values(), false);
            createErrorLogList(insertUpdateResult,'Products',errorLogs);
        }
        
        for(Commercial_Avail__c currentRelease : updatedReleasePlans){
            String externalId = getExternalId(currentRelease);
            if(String.isNotBlank(externalId) && newProductsMap.containsKey(externalId) && newProductsMap.get(externalId).Id != null) {
                currentRelease.Product__c = newProductsMap.get(externalId).Id;
            }else if(!mapProductExist.isEmpty() && mapProductExist.containsKey(externalId) && mapProductExist.get(externalId).Id != null){
                currentRelease.Product__c = mapProductExist.get(externalId).Id;
            }
        }
        
        if(!updatedReleasePlans.isEmpty()){
            Database.SaveResult[] insertUpdateResult = Database.update(updatedReleasePlans, false);
            createErrorLogList(insertUpdateResult,'Release Plans',errorLogs);
        }
                
        CRM_ErrorLogger.logError(errorLogs); 
    }
    
    private void doMappingFromReleasePlanToProduct(Product2 currentProduct, Commercial_Avail__c currentRelease) {
        if(currentRelease.Local_Title__r != null && currentRelease.Local_Title__r.Name != null && currentRelease.Local_Title__r.Title_VV_F__c != null ) {
            currentProduct.Name = currentRelease.Local_Title__r.Name + '(' + currentRelease.Channel__c + '/' + currentRelease.Format__c + ')';
            currentProduct.ProductCode = currentRelease.Local_Title__r.Title_VV_F__c;
        }
        currentProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        currentProduct.Release_Plan__c = currentRelease.ID;
        currentProduct.Street_Date__c = currentRelease.Start_Date__c;
        currentProduct.Local_Title__c = currentRelease.Local_Title__c;
        currentProduct.Short_Description__c = currentProduct.Name;
        currentProduct.Product_Format__c = currentRelease.Format__c;
        currentProduct.Product_Market__c = currentRelease.Channel__c;
        currentProduct.Product_Genre__c = currentRelease.Title__r.Genre__c;
        currentProduct.Product_Language_Code__c = currentRelease.Languages__r.Language_Code_2__c ;
        currentProduct.isActive = true;
        currentProduct.CanUseRevenueSchedule = true;
        currentProduct.CanUseQuantitySchedule = true;
    }
    
    /**
     *  Fetch the existing products for the said combination
     */
    private List<Product2> getProducts(Set<String> setExtenalId){
        List<Product2> lstProd = new List<Product2>();
        lstProd = [Select Id,External_Id__c,Release_Plan__c,Street_Date__c from Product2 where External_Id__c in: setExtenalId];
        system.debug('lstProd:'+lstProd);
        return lstProd;      
    }

    /**
     *  Create External ID for new product
     */
    private String getExternalId(Commercial_Avail__c releasePlan){
        String externalId = null;
        if (releasePlan != null){
            if(String.isNotBlank(releasePlan.Country_Lookup__r.Country_Code__c) || String.isNotBlank(releasePlan.Languages__r.Language_Code_2__c) || 
                String.isNotBlank(releasePlan.Title_Video_Version__c) || String.isNotBlank(releasePlan.Channel__c) || String.isNotBlank(releasePlan.Format__c)) {
                    
                externalId = releasePlan.Country_Lookup__r.Country_Code__c + '_' + releasePlan.Languages__r.Language_Code_2__c + '_';
                externalId += releasePlan.Title_Video_Version__c + '_' + releasePlan.Channel__c + '_' + releasePlan.Format__c;
            }
        }
        return externalId;      
    }
    
    public static void createErrorLogList(List<Database.SaveResult> insertResult, String entityName,List<CRM_ErrorLogger.ErrorLog> errorLogs){
        for(Database.SaveResult sr : insertResult) {
            if(!sr.isSuccess()){
                CRM_ErrorLogger.ErrorLog errorLogInstance = logAnException(sr.getErrors(), sr.getId(), entityName);
                errorLogs.add(errorLogInstance);
            }              
        }
    }


    /**
     * This method will take the exception occured as an input and forward it to the common utility class. 
     */
    public static CRM_ErrorLogger.ErrorLog logAnException(List<Database.Error> errors, Id recordId, String entityName){
        String lineNumber = '';
        String errorMessage = '';
        String statusCode = '';
        
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        if (recordId != null) {
            errorLogInstance.recordId = recordId;
        }
        
        errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_CAS_PRODUCT_CREATION_BATCH;
        errorLogInstance.className = 'CRM_CreateProductsAndPBEPBatch';
        
        for(Database.Error err : errors){
            statusCode += ' Error Code: ' + String.valueOf(err.getStatusCode());
            errorMessage += ' Error Message: ' + err.getMessage().left(200) + '**entityName: ' + entityName;
        }
        errorLogInstance.lineNumber = lineNumber;
        errorLogInstance.errorMessage = errorMessage;
        errorLogInstance.stackTrace = statusCode;
        return errorLogInstance;
    }
    
    public String getReleasePlanQuery(List<String> releasePlanList){
        
        Product_Creation_Batch_Setting__c setting = Product_Creation_Batch_Setting__c.getInstance('Default');
        String strQuery = 'SELECT ID, OwnerId, Country_Lookup__r.Country_Code__c, Title_Video_Version__c, Start_Date__c, End_Date__c, Title_Content_Type__c, ';
        strQuery += ' Channel__c, Format__c, Local_Title__r.Name, Local_Title__r.Local_Synopsis__c, Languages__r.Language_Code_2__c, Title__r.Genre__c, ';
        strQuery += ' Local_Title__r.Title_VV_F__c,Product__c  FROM Commercial_Avail__c';
        strQuery += ' WHERE (Product__c = null';
        strQuery += ' AND Country_Lookup__c != null';
        strQuery += ' AND Country_Lookup__r.Country_Code__c != null';
        if(setting != null && setting.Generate_CRM_Product__c != false){
            strQuery += ' AND Country_Lookup__r.Generate_CRM_Product__c = ' + setting.Generate_CRM_Product__c;
        }
        strQuery += ' AND Languages__c != null';
        strQuery += ' AND Languages__r.Language_Code_2__c != null';
        strQuery += ' AND Title_Video_Version__c != null';
        strQuery += ' AND Channel__c != null';
        strQuery += ' AND Channel__c != \'Physical\'';
        strQuery += ' AND Local_Title__c != null';
        strQuery += ' AND Title__c != null';
        strQuery += ' AND Title__r.Clear_to_Avail__c = true';
        strQuery += ' AND Title__r.Digital_Planning__c = \'Yes\'';
        strQuery += ' AND End_Date__c != null';
        strQuery += ' AND End_Date__c > today';
        strQuery += ' AND Status__c In : releasePlanStatus';
        
    //    strQuery += ' AND Status__c = \''+ CRM_AppConstants.CRM_Client_Avail_Status_Confirmed + '\' ';
        strQuery += ' AND Format__c != null) ';
        strQuery += ' AND Id In :releasePlanList '; 
        strQuery += ' ORDER BY CreatedDate DESC ';
         
        System.debug('strQuery ------------->'+strQuery );
        
        return strQuery;
    }
    
    
    public void insertOrUpdatePriceBookEntryPeriod(List<Client_Avail__c> caList){
        List<String> caIdList = new List<String>();
        for(Client_Avail__c caRecord:caList){
            caIdList.add(caRecord.Id);
        }
        
        managePriceBookEntryPeriod(caIdList);       
    }
    
    public void insertOrUpdatePriceBookEntryPeriod(List<Client_Avail_Price__c> capList){
        List<String> caIdList = new List<String>();
        for(Client_Avail_Price__c capRecord:capList){
            caIdList.add(capRecord.Client_Avail__c);
        }
        
        managePriceBookEntryPeriod(caIdList);
    }
    
    
    public void managePriceBookEntryPeriod(List<String> caIdList){
        ID soldToRecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        
        String queryString = getClientAvailPriceQuery(soldToRecordTypeID,ppRecTypeId);
        
        queryString = queryString + ' AND Client_Avail__c in :caIdList';
        
        /*if(queryEpisodes){
            queryString = queryString + ' AND (Client_Avail__c in :caIdList OR Client_Avail__r.Parent_Client_Avail__c in :caIdList)';
        }else{
            queryString = queryString + ' AND Client_Avail__c in :caIdList';
        }*/
        
        List<Client_Avail_Price__c> retrievedCAPList = Database.query(queryString);
        upsertPriceBookEntryPeriod(retrievedCAPList);
        
        deletePriceBookEntryPeriod(caIdList);
    }
    
    
    private void upsertPriceBookEntryPeriod(List<Client_Avail_Price__c> retrievedCAPList){
        
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        List<Pricebook_Entry_Period__c> pbepInsertList = new List<Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> pbepUpdateList = new List<Pricebook_Entry_Period__c>();
         
        for(Client_Avail_Price__c capRecord:retrievedCAPList){
            if(capRecord.Pricebook_Entry_Periods__r == null || capRecord.Pricebook_Entry_Periods__r.size() == 0){ //Insert
                if(capRecord.Client_Avail__r.Status__c == WB_PriceUtility.STATUS_CONF || capRecord.Client_Avail__r.Status__c == WB_PriceUtility.STATUS_TENTVE){
                    Pricebook_Entry_Period__c pbepRecord = createPBEP(capRecord);
                    pbepInsertList.add(pbepRecord);
                }
            }else{ //Update
                Pricebook_Entry_Period__c pbepRecord = capRecord.Pricebook_Entry_Periods__r[0];
                Boolean US_CAN = capRecord.Client_Avail__r.Release_Plan_Country__c == CRM_AppConstants.USA_Country || capRecord.Client_Avail__r.Release_Plan_Country__c == CRM_AppConstants.CANADA_Country;
                /*ER-003373--> Decimal caSRPrice = capRecord.Client_Avail__r.SR_Price__c; */
                Decimal rcSRPrice = capRecord.CAP_Rate_Card__r.SRP__c;
                
                if(pbepRecord != null && 
                    ((pbepRecord.Start_Date__c != capRecord.Effective_Date__c 
                     || pbepRecord.End_Date__c != capRecord.Expiry_Date__c
                     || pbepRecord.Retailer_Product_ID__c != capRecord.Client_Avail__r.Client_Title_ID__c
                     || (capRecord.Price__c != null && (pbepRecord.Account_Price__c != capRecord.Price__c ||
                                                        pbepRecord.List_Price__c != null ||
                                                        pbepRecord.Minimum_Price__c != null 
                                                        )
                        )
                     || (!capRecord.CAP_CRM_Country__c && capRecord.Pricing__c != null && (pbepRecord.Account_Price__c != capRecord.Pricing__r.Account_Price__c ||
                                                        pbepRecord.List_Price__c != capRecord.Pricing__r.List_Price__c ||
                                                        pbepRecord.Minimum_Price__c != capRecord.Pricing__r.Minimum_Price__c  
                                                        )
                        )
                     || (capRecord.CAP_CRM_Country__c && capRecord.CAP_Rate_Card__c != null && pbepRecord.Account_Price__c != WB_RateCardHelper.getStepPrice(capRecord)
                        )
                     || pbepRecord.New_Release__c != clientAvailLocalDataCategorySet.contains(capRecord.Category__c))
                     || ( US_CAN && //#776 Country check for US & Canada
                         
                         /*ER-003373--> ((!capRecord.CAP_CRM_Country__c && ((caSRPrice != null && pbepRecord.SR_Price__c != caSRPrice) || (caSRPrice == null && pbepRecord.SR_Price__c != capRecord.Pricing__r.SR_Price__c)))
                         	|| (capRecord.CAP_CRM_Country__c && ((rcSRPrice != null && pbepRecord.SR_Price__c != rcSRPrice) || (rcSRPrice == null && pbepRecord.SR_Price__c != caSRPrice))) 
                         	|| pbepRecord.Vendor_ID__c != capRecord.Vendor_Id__c)
                         
                         */
							((rcSRPrice != null && pbepRecord.SR_Price__c != rcSRPrice) || pbepRecord.Vendor_ID__c != capRecord.Vendor_Id__c)
                        
                        ))){
                    	//ER-003373--> New Code end
                     assignPBEPValues(pbepRecord,capRecord,WB_PriceUtility.UPDATE_OP);
                     pbepUpdateList.add(pbepRecord);
                  
                }
            }
        }
        
        if(!pbepUpdateList.isEmpty()){
            Database.SaveResult[] updateResult = Database.update(pbepUpdateList,false);
            createErrorLogList(updateResult, 'Price Book Entry Period',errorLogs);
        }
        
        if(!pbepInsertList.isEmpty()){
            WB_Pricing_Settings__c  pbepSetting = WB_Pricing_Settings__c.getInstance('Create PBEP');
            if(pbepSetting != null && pbepSetting.Future__c == true && pbepSetting.Threshold__c != null && pbepInsertList.size() > pbepSetting.Threshold__c){
                    insertPriceBookEntryPeriodFuture(JSON.serialize(pbepInsertList));
            }else{
                Database.SaveResult[] insertResult = Database.insert(pbepInsertList,false);
                createErrorLogList(insertResult, 'Price Book Entry Period',errorLogs);  
            }
        }
            
        CRM_ErrorLogger.logError(errorLogs);
    }
    
    //@TestVisible
    private Pricebook_Entry_Period__c createPBEP(Client_Avail_Price__c capRecord){
        Pricebook_Entry_Period__c pbepRecord = new Pricebook_Entry_Period__c();
        assignPBEPValues(pbepRecord,capRecord,WB_PriceUtility.INSERT_OP);
        return pbepRecord;
    }
    
    @TestVisible
    private void assignPBEPValues(Pricebook_Entry_Period__c pbepRecord, Client_Avail_Price__c capRecord,String operation){
        
        if(capRecord.Price__c > 0){
            pbepRecord.Account_Price__c = capRecord.Price__c;
            pbepRecord.List_Price__c = null;
            pbepRecord.Minimum_Price__c = null;
            pbepRecord.Pricing__c = null;
            pbepRecord.Rate_Card__c = capRecord.CAP_Rate_Card__c; 
        }else if(!capRecord.CAP_CRM_Country__c && capRecord.Pricing__r != null){
            pbepRecord.Pricing__c = capRecord.Pricing__c;
            pbepRecord.Account_Price__c = capRecord.Pricing__r.Account_Price__c;
            pbepRecord.List_Price__c = capRecord.Pricing__r.List_Price__c;
            pbepRecord.Minimum_Price__c = capRecord.Pricing__r.Minimum_Price__c;
            pbepRecord.Rate_Card__c = null; 
        }else if(capRecord.CAP_CRM_Country__c && capRecord.CAP_Rate_Card__r != null){
            pbepRecord.Rate_Card__c = capRecord.CAP_Rate_Card__c;
            pbepRecord.Account_Price__c = WB_RateCardHelper.getStepPrice(capRecord);
            pbepRecord.List_Price__c = pbepRecord.Account_Price__c; //need to review
            pbepRecord.Minimum_Price__c = pbepRecord.Account_Price__c;//need to review  
            pbepRecord.Pricing__c = null;
        }
        
        //#776 Changes to Populate PBEP with SR Price and Vendor ID
        if((capRecord.Client_Avail__r.Release_Plan_Country__c == CRM_AppConstants.USA_Country)||(capRecord.Client_Avail__r.Release_Plan_Country__c == CRM_AppConstants.CANADA_Country)){
            
            if(!capRecord.CAP_CRM_Country__c){
            	/*ER-003373--> if(capRecord.Client_Avail__r.SR_Price__c != null && capRecord.Client_Avail__r.SR_Price__c > 0){
                	pbepRecord.SR_Price__c = capRecord.Client_Avail__r.SR_Price__c;
	            }else{
	                pbepRecord.SR_Price__c = capRecord.Pricing__r.SR_Price__c ;
	            }*/
                
				//ER-003373--> New Code start
	               pbepRecord.SR_Price__c = capRecord.Pricing__r.SR_Price__c ;
				//ER-003373--> New Code end
				
            }else{
            	if(capRecord.CAP_Rate_Card__r.SRP__c != null && capRecord.CAP_Rate_Card__r.SRP__c > 0){
                	pbepRecord.SR_Price__c = capRecord.CAP_Rate_Card__r.SRP__c;
	            }
                
                /*ER-003373-->
                else{
	                pbepRecord.SR_Price__c = capRecord.Client_Avail__r.SR_Price__c ;
	            }*/
                
            }

            pbepRecord.Vendor_ID__c = capRecord.Vendor_Id__c; 
        }
        //#776 Change ends
        
        pbepRecord.Start_Date__c = capRecord.Effective_Date__c;
        pbepRecord.End_Date__c = capRecord.Expiry_Date__c;
        //pbepRecord.New_Release__c = clientAvailLocalDataCategorySet.contains(capRecord.Category__c);
        if(capRecord.Type__c == 'First' && clientAvailLocalDataCategorySet.contains(capRecord.Category__c) ){
            pbepRecord.New_Release__c = true;
        }else
            pbepRecord.New_Release__c = false;
            
        pbepRecord.Retailer_Product_ID__c = capRecord.Client_Avail__r.Client_Title_ID__c;
            
        if(operation == WB_PriceUtility.INSERT_OP){
            pbepRecord.CurrencyIsoCode = capRecord.Client_Avail__r.Storefront__r.CRM_Account__r.CurrencyIsoCode;
            pbepRecord.Client_Avail__c = capRecord.Client_Avail__c;
            pbepRecord.Client_Avail_Price__c = capRecord.ID;                                
            pbepRecord.Price_Book__c = capRecord.Client_Avail__r.Storefront__r.CRM_Account__r.Price_Book__c;
            pbepRecord.Product__c = capRecord.Client_Avail__r.Commercial_Avail__r.Product__c;
        }
         
    }
    
    @future
    public static void insertPriceBookEntryPeriodFuture(String pbepList){
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        List<Pricebook_Entry_Period__c> pbepInsertList = (List<Pricebook_Entry_Period__c>)JSON.deserialize(pbepList,List<Pricebook_Entry_Period__c>.class);
        Database.SaveResult[] insertResult = Database.insert(pbepInsertList,false);
        createErrorLogList(insertResult, 'Price Book Entry Period',errorLogs);
        CRM_ErrorLogger.logError(errorLogs);
    }
    
    private void deletePriceBookEntryPeriod(List<String> caIDList){
    	
    	if(caIDList != null && caIDList.size() > 0){
	        List<Pricebook_Entry_Period__c> toBeDeletedPBEPList = [Select Id FROM Pricebook_Entry_Period__c WHERE Client_Avail__c IN :caIDList and Client_Avail_Price__c = null];
	        Database.DeleteResult[] deleteReults = Database.delete(toBeDeletedPBEPList,false);
    	}
        
    }
    
    public String getClientAvailPriceQuery(ID soldToRecordTypeID,ID ppRecTypeId){
    
        Product_Creation_Batch_Setting__c setting = Product_Creation_Batch_Setting__c.getInstance('Default');
        
        String strQuery = 'SELECT ID, Name,Client_Avail__c,Type__c, Client_Avail__r.Storefront__r.CRM_Account__r.Price_Book__c, Client_Avail__r.Storefront__r.CRM_Account__r.CurrencyIsoCode, Client_Avail__r.Storefront__r.CurrencyIsoCode,'; 
        strQuery += 'Pricing__r.Account_Price__c,Pricing__r.List_Price__c,Pricing__r.Minimum_Price__c, Client_Avail__r.Commercial_Avail__r.Product__c, ';
        strQuery += 'Effective_Date__c, Expiry_Date__c, Category__c,Client_Avail__r.Client_Title_ID__c,Price__c,Pricing__c,Client_Avail__r.Status__c,Pricing__r.SR_Price__c,Client_Avail__r.SR_Price__c,SR_Price__c,Vendor_Id__c,Client_Avail__r.Release_Plan_Country__c,';    //#776 Added SR Price, Vendor Id, Release Plan Country and Pricing.SR Price
        strQuery += 'CAP_Rate_Card__c,CAP_Rate_Card__r.Step_Pricing__c,CAP_Rate_Card__r.WSP1__c,CAP_Rate_Card__r.WSP2__c,CAP_Rate_Card__r.WSP3__c,CAP_Rate_Card__r.Step1_Length_Months__c,CAP_Rate_Card__r.Step2_Length_Months__c,CAP_Rate_Card__r.SRP__c,CA_Local_DVD_Rel_Date__c,CAP_CRM_Country__c,';
        strQuery += '(Select Id,Start_Date__c,End_Date__c,Retailer_Product_ID__c,Account_Price__c,New_Release__c,List_Price__c,Minimum_Price__c,SR_Price__c,Vendor_ID__c From Pricebook_Entry_Periods__r) FROM Client_Avail_Price__c '; //#776 Added SR Price, Vendor Id
        strQuery += ' WHERE Client_Avail__r.Storefront__c != null';
        strQuery += ' AND Client_Avail__r.Storefront__r.CRM_Account__c != null';
        strQuery += ' AND Client_Avail__r.Commercial_Avail__c != null';
        strQuery += ' AND Client_Avail__r.Commercial_Avail__r.Product__c != null';
        if(setting != null && setting.Generate_CRM_Product__c != null){
            strQuery += ' AND Client_Avail__r.Commercial_Avail__r.Country_Lookup__c != null';
            strQuery += ' AND Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Generate_CRM_Product__c = ' + setting.Generate_CRM_Product__c;
        }
        
        //Defect # 3976
        strQuery += ' AND Client_Avail__r.Title_Content_Type__c != \''+ CRM_AppConstants.EPISODE_CONTENT_TYPE + '\' ';
        strQuery += ' AND Client_Avail__r.Storefront__r.CRM_Account__r.RecordTypeID =: soldToRecordTypeID';
        strQuery += ' AND Client_Avail__r.Storefront__r.CRM_Account__r.CurrencyIsoCode != null';
        strQuery += ' AND (Client_Avail__r.Storefront__r.CRM_Account__r.Price_Book__c != null OR Price__c > 0)';
        strQuery += ' AND RecordTypeID = :ppRecTypeId';
        
        System.debug('strQuery ------------->'+strQuery );
    
        return strQuery;
    }
}