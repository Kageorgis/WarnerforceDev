/**
   @Author Cognizant
   @CreateDate 13 Mar 2018
   @name CRM_UpdateAllTradeTactics
   @Description This class is used to update the deal products US#975.
   @Version <1.0>
   @reference Requirement no 975 US Games
*/
global with sharing class CRM_UpdateAllTradeTactics {
    public static Integer totalFailedRecords;  
    public static Integer noOfFilters =0;

     /** 
    *  @Description - constructor 
    *  @name  CRM_UploadExtractTradeTactics 
    */ 
    global CRM_UpdateAllTradeTactics() {}
    
    
    /** 
     *  Method to fetch the Deal Product from DealId  
     *  @name getChunkSizeForTradeTactics
     *  @param None
     *  @return Chunk size in Integer
     *  @throws None
     */
    global Integer getChunkSizeForTradeTactics() {
        return CRM_Batch_Size__c.getInstance('Upload Deal Tactics Records') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('Upload Deal Tactics Records').Batch_Size__c) : 100;
    }
    
    /** 
     *  Method to form the query common for the Deal Product 
     *  @name getTacticQuery
     *  @param None
     *  @return QueryString
     *  @throws None
     */
    public static String getTacticQuery(CRM_DataObjects.SearchFilters filters,String coopReason){
        
         String queryString =   'SELECT Id,Opportunity.Id,Opportunity.StageName,Opportunity.Deal_Code__c,Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.AccountId,Opportunity.Name,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c,Credit_Note_Item__c,Credit_Note_Item__r.Credit_Note__r.Status__c, '+
                                'POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c,Product2.Video_Version__c,Product2.Local_Title__r.Name '+
                                'FROM OpportunityLineItem '+  
                                ' WHERE Opportunity.RecordTypeId =\''+ CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND +'\''+
                                'AND Status__c!=\''+ CRM_AppConstants.TACTIC_STATUS_BUDGET +'\'';
        
        if(filters.streetDateFrom != null){
            noOfFilters++;
            String strDateFrom = DateTime.newInstance(filters.streetDateFrom.year(),filters.streetDateFrom.month(),filters.streetDateFrom.day()).format('yyyy-MM-dd');
            queryString += ' AND Start_Date__c >= '+strDateFrom+'';
        } 
        
        if(filters.streetDateTo != null){
            noOfFilters++;
            system.debug('filters.streetDateTo : '+filters.streetDateTo);
            String strDateTo = DateTime.newInstance(filters.streetDateTo.year(),filters.streetDateTo.month(),filters.streetDateTo.day()).format('yyyy-MM-dd');
            queryString += ' AND End_Date__c <= '+strDateTo+'';
        }
        
        if(coopReason !=null && coopReason != ''){
          noOfFilters++;
          queryString += ' AND Reason__c =\''+coopReason+'\'';
        }
        return queryString;
    }
    
    /** 
     *  Method to fetch the Deal Product from DealId  
     *  @name getOpportunityLineItems
     *  @param Id opportunityId
     *  @return CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static FinalWrapper getOpportunityLineItemTactics(CRM_DataObjects.SearchFilters filters,String coopReason) {
        // Construct a list of Opportunity Line Items
        List<OpportunityLineItemWrapper> returnWrapperList = new List<OpportunityLineItemWrapper>();
        //US975 starts
        Set<Id> recordIds =new  Set<Id>(); 
        Boolean quickSearchTextEntered = (filters.text != null && filters.text.trim() != '') ? true : false;
        String queryString = getTacticQuery(filters,coopReason);  
        Map<String,Decimal> mapOfDPVVToTotalCBA = new Map<String,Decimal>();
        List<OpportunityLineItem> lstDealProduct = new List<OpportunityLineItem>();
        Integer maxNoOfFiltersPresent =4;
        //Check for Commitment_Number__c ,Digital_Membership__c and Customer_Reference__c  first.
        Integer maxCount = CRM_Max_Product_Limit__c.getInstance('Muti Tactic Planning') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Muti Tactic Planning').Count__c) : 200;
        
        if(quickSearchTextEntered){
            noOfFilters++;
            String queryUsingLike ='';
            queryUsingLike += ' AND (Commitment_Number__c LIKE \'%'+filters.text+'%\'' ;
            queryUsingLike += ' OR Digital_Membership__c LIKE \'%'+filters.text+'%\'';
            queryUsingLike += ' OR Customer_Reference__c LIKE \'%'+filters.text+'%\')'; 
            queryString += queryUsingLike;
        } 
        queryString += ' ORDER BY Product2.Name Limit : maxCount';
        lstDealProduct = Database.query(queryString);
        
        //If Deal Product not found then seach in account and products
        if(lstDealProduct.size() == 0){
            queryString = getTacticQuery(filters,coopReason); 
            recordIds = getAccountOrProductIds(filters.text);
            queryString += ' AND (Product2Id IN :recordIds OR Opportunity.AccountId IN: recordIds) ORDER BY Product2.Name Limit : maxCount'; 
            lstDealProduct = Database.query(queryString);   
        } 
        
        system.debug('queryString::::::::::::::'+queryString);
        Set<Id> oppIds = new Set<Id>();
        if(lstDealProduct.size() >0){
            for(OpportunityLineItem lineItem : lstDealProduct) { 
                oppIds.add(lineItem.Opportunity.Id);
                OpportunityLineItemWrapper lineItemWrapper = mapTacticFields(lineItem);
                returnWrapperList.add(lineItemWrapper);
            }
        
            OpportunityLineItem[] listDealProducts = [SELECT Id,Opportunity.Id,Opportunity.Deal_Code__c,Co_op_Budget__c
                                                                    ,Product2.Video_Version__c
                                                                    FROM OpportunityLineItem 
                                                                    WHERE OpportunityId IN: oppIds 
                                                                    AND Status__c =:CRM_AppConstants.TACTIC_STATUS_BUDGET];
            Decimal totalCoopBudget =0; 
            if(!listDealProducts.isEmpty()){
                for(OpportunityLineItem dp : listDealProducts){ 
                    if(dp.Co_op_Budget__c != null){ 
                        if(!mapOfDPVVToTotalCBA.containsKey(dp.Opportunity.Deal_Code__c+'_'+dp.Product2.Video_Version__c)){
                            mapOfDPVVToTotalCBA.put(dp.Opportunity.Deal_Code__c + '_'+ dp.Product2.Video_Version__c,dp.Co_op_Budget__c);
                        }else{
                            Decimal coopBudget = mapOfDPVVToTotalCBA.get(dp.Opportunity.Deal_Code__c + '_' + dp.Product2.Video_Version__c) + dp.Co_op_Budget__c;
                            mapOfDPVVToTotalCBA.put(dp.Opportunity.Deal_Code__c + '_' + dp.Product2.Video_Version__c,coopBudget);
                        }
                    }
                }
            }
        }
        FinalWrapper finalWrap =new FinalWrapper();
        finalWrap.mapOfDPVVToTotalCBAA =mapOfDPVVToTotalCBA;
        finalWrap.dealProdWrap =returnWrapperList;
        if(lstDealProduct.size() == maxCount){
            finalWrap.maxLimitExceeded = true;
        }
        return finalWrap;
    }
    
     /*
     *  Method to get productIds or AccountIds containing the search text.  
     *  @name getAccountOrProductIds
     *  @param search text, and search criteria(by product or by account)
     *  @return set of Ids containing search text.
     *  @throws None
    */
    //US#975  start
    public static set<Id> getAccountOrProductIds(string quickSearchText){
   
        Set<Id> setMtachingRecordIds = new Set<Id>();
        String QUERY_PRODUCT_ACCOUNT;
        String sosl_search;
        
        if(quickSearchText != null && quickSearchText.trim() != ''){
            quickSearchText = String.escapeSingleQuotes(quickSearchText);
            
            sosl_search = quickSearchText;
            sosl_search = sosl_search.replace(':', '\\:');
            sosl_search = sosl_search.replace('-', '\\-');
            sosl_search = sosl_search.replace('+', '\\+');
            sosl_search = sosl_search.replace('&', '\\&');
            sosl_search = sosl_search.replace('!', '\\!');
            sosl_search = sosl_search.replace('^', '\\^');
            //String QUERY_PRODUCT;
            
            Set<String> setUSSalesOrg = CRM_AppConstants.US_SALES_ORGS; 
            List<Pricebook2> lstPricebooks = [SELECT Id,name FROM Pricebook2 WHERE Product_Type__c = 'Physical' AND Country__c IN ( 'USA','Can','Mex')];
            
            List<List<SObject>> searchResult = new List<List<SObject>>();
            if(lstPricebooks.size() == 3){
                String SOSL_QUERY_PRODUCT1 = 'FIND {'+ sosl_search +'} RETURNING Product2(Id,Name, ProductCode, Product_Format__c) WITH PricebookId = \''+ lstPricebooks[0].Id +'\'';
                String SOSL_QUERY_PRODUCT2 = 'FIND {'+ sosl_search +'} RETURNING Product2(Id,Name, ProductCode, Product_Format__c) WITH PricebookId = \''+ lstPricebooks[1].Id +'\'';
                String SOSL_QUERY_PRODUCT3 = 'FIND {'+ sosl_search +'} RETURNING Product2(Id,Name, ProductCode, Product_Format__c) WITH PricebookId = \''+ lstPricebooks[2].Id +'\'';
                QUERY_PRODUCT_ACCOUNT = 'FIND {'+sosl_search+'} IN ALL FIELDS RETURNING Account(Id, Name, AccountNumber WHERE Price_Book__c IN: lstPricebooks )';
                
                searchResult = Search.query(QUERY_PRODUCT_ACCOUNT);
                List<List<SObject>> searchResultProduct1 = Search.query(SOSL_QUERY_PRODUCT1);
                List<List<SObject>> searchResultProduct2 = Search.query(SOSL_QUERY_PRODUCT2);
                List<List<SObject>> searchResultProduct3 = Search.query(SOSL_QUERY_PRODUCT3);
                searchResult.addall(searchResultProduct1);
                searchResult.addall(searchResultProduct2);
                searchResult.addall(searchResultProduct3);
            }
            
            for(sObject[] listObj : searchResult) {
                for(sObject sobj : listObj) {
                   if(String.valueOf(sobj.getSObjectType()) == 'Product2'){    
                       string productCode = (string)sobj.get('ProductCode') !=null? (string)sobj.get('ProductCode') :'';
                       string productName = (string)sobj.get('Name') !=null ? (string)sobj.get('Name') : '';
                       string productFormat = (string)sobj.get('Product_Format__c') !=null ? (string)sobj.get('Product_Format__c') : '';

                       if((productCode.containsIgnoreCase(quickSearchText) || productName.containsIgnoreCase(quickSearchText) || productFormat.containsIgnoreCase(quickSearchText))){
                         setMtachingRecordIds.add((Id)sobj.get('Id'));
                       }
                    }else if(String.valueOf(sobj.getSObjectType()) == 'Account'){ 
                        string accountNumber = (string)sobj.get('AccountNumber') !=null ? (string)sobj.get('AccountNumber') :'';
                        string accountName = (string)sobj.get('Name') !=null ? (string)sobj.get('Name') : ''; 
                        if((accountNumber.containsIgnoreCase(quickSearchText) || accountName.containsIgnoreCase(quickSearchText))){
                            setMtachingRecordIds.add((Id)sobj.get('Id'));
                        }
                    }           
                }
            }
        }
        return setMtachingRecordIds;
    }
    
    
    /** 
     *  Method to MAP tactic fields to the wrapper from Deal Product  
     *  @name mapTacticFields
     *  @param OpportunityLineItem lineItem
     *  @return CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper 
     *  @throws None
     */
    private static OpportunityLineItemWrapper mapTacticFields(OpportunityLineItem lineItem){
        OpportunityLineItemWrapper lineItemWrapper = new OpportunityLineItemWrapper();
            lineItemWrapper.existingId = lineItem.id;
            lineItemWrapper.productCode = lineItem.Product_Code__c;
            lineItemWrapper.productName = lineItem.Product2.name;
            lineItemWrapper.commitmentNum = lineItem.Commitment_Number__c;
            lineItemWrapper.startDate = String.valueOf(lineItem.Start_date__c);
            lineItemWrapper.endDate = String.valueOf(lineItem.End_date__c);
            lineItemWrapper.coopReason = lineItem.Reason__c ;
            lineItemWrapper.coopComments = lineItem.Comments__c == null ? '' : lineItem.Comments__c; //Defect:4714
            lineItemWrapper.posRebate = lineItem.POS_Rebate__c;
            lineItemWrapper.posForecast = lineItem.POS_Forecast__c ;
            lineItemWrapper.coopReqAmount = lineItem.Co_op_Requested_Amount__c == null ? lineItem.Co_op_Requested_Amount__c : (lineItem.Co_op_Requested_Amount__c.SetScale(2));
            lineItemWrapper.posActual= lineItem.Pos_actual__c;
            lineItemWrapper.coopActualAmt = lineItem.Co_op_Actual_Amount__c == null ? lineItem.Co_op_Actual_Amount__c : (lineItem.Co_op_Actual_Amount__c.SetScale(2));
            lineItemWrapper.status = lineItem.Status__c;
            lineItemWrapper.custReference = lineItem.Customer_Reference__c == null ? '' : lineItem.Customer_Reference__c; //Defect:4714
            lineItemWrapper.digitalMembership = lineItem.Digital_Membership__c == null ? '' : lineItem.Digital_Membership__c;  //Defect:4714
            lineItemWrapper.accruingTactic = lineItem.Accruing_Tactic__c;
            lineItemWrapper.videoVersion = lineItem.Product2.Video_Version__c;
            lineItemWrapper.localTitleName = lineItem.Product2.Local_Title__r.Name; 
            lineItemWrapper.deal = lineItem.Opportunity;
            
            if(lineItem.Credit_Note_Item__c != null && 
               (lineItem.Credit_Note_Item__r.Credit_Note__r.Status__c != CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_FAILED &&
                lineItem.Credit_Note_Item__r.Credit_Note__r.Status__c != CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED_IN_SAP)
             ){
                lineItemWrapper.isValidCreditNoteItemLinked = true;
            }
            return lineItemWrapper;
    }
    
    /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setOpportunityLineItems
     *  @param CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper[] and Opportunity Id
     *  @return sorted CRM_UploadExtractTradeTactics.FinalOpportunityLineItemWrapper[] with successful Update and failed records
     *  @throws None 
     */
    @RemoteAction
    global static List<OpportunityLineItemWrapper> setOpportunityLineItemTactics(List<OpportunityLineItemWrapper> tacticWrapperList, Boolean isTFMUser) { 
        
        List<OpportunityLineItemWrapper> lstToUpdateTactics =new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItem> tacticItemsToUpdate = new List<OpportunityLineItem>(); 
        Set<Id> setOfTacticIds = new Set<Id>();
        Set<Opportunity> setOfDeals = new Set<Opportunity>();
        Set<String> setOfDealCurrency = new Set<String>();
        Set<Id> setOfDealPricebooks = new Set<Id>();
        // 01 =Active ,11=Initial & 06=Cutout 
        Set<String> sAPdistChainProductStatus = new Set<String>{'01','11','06'};
        Set<String> setProductCode = new Set<String>();
        Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>();
        totalFailedRecords = 0; 
                  
        // set the index for each line item
        for(Integer i=0; i< tacticWrapperList.size(); i++) {
            tacticWrapperList[i].rowIndex = i;
        }
            
        // Get all the product codes and set the validation if any of the mandatory fields are not entered.
        for(OpportunityLineItemWrapper tacticWrapper : tacticWrapperList){
              if(tacticWrapper.isRowModified !=null && tacticWrapper.isRowModified == true){
                
                //Defect #4677 - TACTICS - The error message displayed in upload/extract when the deal stage is 'Awaiting Approval'
                if(tacticWrapper.deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                    tacticWrapper.validation = system.label.CRM_Validation_For_deal_Products_IN_Awaiting_Approval_stage;
                    tacticWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                
                //----------------Validation 1: Check for Valid productCode,startDate,endDate,coopReason  ---------------------------------
                if(tacticWrapper.productCode == null || tacticWrapper.startDate == null || tacticWrapper.endDate == null || tacticWrapper.coopReason == null ||
                   tacticWrapper.productCode == '' || tacticWrapper.startDate == '' || tacticWrapper.endDate == '' || tacticWrapper.coopReason == '' ){
                        tacticWrapper.validation = system.label.CRM_UploadExtractTactic_MandatoryFields_Validation;
                        tacticWrapper.errorOccured = true;
                        totalFailedRecords++;
                        continue;
                }
                
                if(tacticWrapper.existingId != null){
                    if(tacticWrapper.accruingTactic && !CRM_AppConstants.ACCRUING_TACTIC_REASONS.contains(tacticWrapper.coopReason)){
                        tacticWrapper.validation = system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg;
                        tacticWrapper.errorOccured = true;
                        totalFailedRecords++;
                        continue;
                    }else if(!tacticWrapper.accruingTactic && !CRM_AppConstants.NON_ACCRUING_TACTIC_REASONS.contains(tacticWrapper.coopReason)){
                        tacticWrapper.validation = system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg;
                        tacticWrapper.errorOccured = true;
                        totalFailedRecords++;
                        continue;
                    }
                }else if(!CRM_AppConstants.NON_ACCRUING_TACTIC_REASONS.contains(tacticWrapper.coopReason) && !CRM_AppConstants.ACCRUING_TACTIC_REASONS.contains(tacticWrapper.coopReason)){
                    tacticWrapper.validation = system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg;
                    tacticWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                
                if( 
                    tacticWrapper.coopReason == CRM_AppConstants.REASON_POS_REBATE && 
                    (
                        (
                            (
                                tacticWrapper.deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED ||
                                tacticWrapper.deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED
                            ) && 
                            tacticWrapper.Status == CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED && 
                            (
                                (!isTFMUser && tacticWrapper.coopReqAmount == tacticWrapper.coopActualAmt)  
                            )
                        )
                    ) && 
                    (
                        tacticWrapper.posRebate == null ||
                        tacticWrapper.posForecast == null
                    )
                ){
                    tacticWrapper.validation = system.label.CRM_Pos_Rebate_Forecast_Man;
                    tacticWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                } else if( 
                    tacticWrapper.coopReason != CRM_AppConstants.REASON_POS_REBATE && 
                    tacticWrapper.coopReason != CRM_AppConstants.REASON_DIGITAL_WB_PROMO && 
                    tacticWrapper.coopReason != CRM_AppConstants.REASON_DIGITAL_SITE_PROMO &&
					//ER-006847 - Add Co-op Reason Tactic: Digital – Subscription
                    tacticWrapper.coopReason != CRM_AppConstants.REASON_DIGITAL_SUBSCRIPTION && 
                    tacticWrapper.posRebate != null
                ){
                    tacticWrapper.validation = System.Label.CRM_Non_Pos_Rebate_Error;
                    tacticWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                
                if(tacticWrapper.deal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                    tacticWrapper.validation = system.label.CRM_Validation_For_deal_Products_IN_Awaiting_Approval_stage;
                    tacticWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                setProductCode.add(tacticWrapper.productCode);
                setOfDealCurrency.add(tacticWrapper.deal.CurrencyIsoCode);
                setOfDealPricebooks.add(tacticWrapper.deal.Pricebook2Id);
            }
        }  
            
        //--------------------------------Update for Product Code Functionality begins--------------------------------------//    
        //Get PricebookEntry for the entered ProductCodes for valid Deal Pricebook and Currency
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        lstPricebookEntry = getValidPricebookEntryForProductCodes(setProductCode,setOfDealCurrency,setOfDealPricebooks);
         
        if(!lstPricebookEntry.isEmpty()){
            for(PricebookEntry pbEntry : lstPricebookEntry){ 
                String strKey = pbEntry.Pricebook2Id+'-'+pbEntry.Product2.ProductCode+'-'+pbEntry.CurrencyIsoCode;
                mapOfProductCodeToPB.put(strKey,pbEntry);
            }
        }
            
        for(OpportunityLineItemWrapper tacticRecord : tacticWrapperList){
             if(tacticRecord.isRowModified !=null && tacticRecord.isRowModified == true && (tacticRecord.validation == null || tacticRecord.validation == '')){
            
                OpportunityLineItem tacticItem = new OpportunityLineItem();
                //Form the key and check if PricebookEntry exists for the Product Code and we can add Duplicate Deal Products
                String key = tacticRecord.deal.Pricebook2Id+'-'+tacticRecord.productCode+'-'+tacticRecord.deal.CurrencyIsoCode;
                if(mapOfProductCodeToPB.containsKey(key)){
                        
                    Opportunity oppoRecord = tacticRecord.deal;
                    tacticItem.Id=tacticRecord.existingId;
                    //}
                    tacticItem.Start_Date__c =  date.parse(tacticRecord.startDate);
                    tacticItem.End_Date__c =  date.parse(tacticRecord.endDate);
                    tacticItem.Co_op_Requested_Amount__c = tacticRecord.coopReqAmount == null ? tacticRecord.coopReqAmount :(tacticRecord.coopReqAmount.SetScale(2));
                    tacticItem.Co_op_Actual_Amount__c = tacticRecord.coopActualAmt == null ? tacticRecord.coopActualAmt : (tacticRecord.coopActualAmt.SetScale(2));
                    tacticItem.Pos_actual__c = tacticRecord.posActual;
                    tacticItem.Customer_Reference__c = tacticRecord.custReference;
                    tacticItem.POS_Rebate__c = tacticRecord.posRebate;
                    tacticItem.POS_Forecast__c = tacticRecord.posForecast;
                    tacticItem.Reason__c = tacticRecord.coopReason;
                    tacticItem.Comments__c = tacticRecord.coopComments; 
                    tacticItem.Digital_Membership__c = tacticRecord.digitalMembership;
                    if(tacticRecord.status == CRM_AppConstants.DEAL_PRODUCT_STATUS_CANCELLED){
                        tacticItem.Is_Canceled__c = true;
                        tacticItem.Co_op_Actual_Amount__c = 0;
                    }
                    setOfTacticIds.add(tacticItem.Id);
                    setOfDeals.add(tacticRecord.deal);
                    tacticItemsToUpdate.add(tacticItem);  
                    lstToUpdateTactics.add(tacticRecord);
                }else{
                    //---------------------Validation 3 : Product or valid PriceBookEntry in product does not exist.-----------------
                    tacticRecord.validation =System.Label.CRM_Product_Not_Exist;
                    tacticRecord.errorOccured = true;
                    totalFailedRecords++;
                    continue; 
                }
            }
        }
        if(!tacticItemsToUpdate.isEmpty()){
                Database.SaveResult[]  result = Database.Update(tacticItemsToUpdate, false);
                system.debug('------------------>'+result);
                updateDMLResultForTactics(result,lstToUpdateTactics,setOfTacticIds,setOfDeals);
        }
        //--------------------------------Update for Product Code Functionality Ends--------------------------------------// 
        
        
        if(!tacticWrapperList.isEmpty()) {
            tacticWrapperList[0].numFailedRecords = totalFailedRecords;
        } 
        
        return tacticWrapperList; 
    } 
    
    /**
     *  Method to fetch Valid PricebookEntry For ProductCodes 
     *  @name setOpportunityLineItems
     *  @param Opportunity opportunityObject,Set<String> setProductCode
     *  @return Fetched List<PricebookEntry>
     *  @throws None
    **/ 
    private static List<PricebookEntry> getValidPricebookEntryForProductCodes(Set<String> setProductCode,Set<String> setOfDealCurrency ,Set<Id> setOfDealPricebooks){
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        lstPricebookEntry = [SELECT Id,Product2.ProductCode,Product2.Id,Pricebook2Id,CurrencyIsoCode,Product2.SAP_Dist_chain_product_Status__c
                                    FROM PricebookEntry
                                    WHERE Product2.ProductCode IN :setProductCode 
                                    AND isActive = true 
                                    AND Pricebook2Id IN: setOfDealPricebooks 
                                    AND CurrencyIsoCode IN: setOfDealCurrency];
        return lstPricebookEntry;
    }
    
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
    */
    global static void updateDMLResultForTactics(Database.SaveResult[] results,List<OpportunityLineItemWrapper> tacticWrapperList,Set<Id> setOfTacticIds, Set<Opportunity> setOfDeals) {
        Map<Id,OpportunityLineItem> mapTacticRecords = new Map<Id,OpportunityLineItem> ([SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Digital_Membership__c,
                                                                                                    Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c,Accruing_Tactic__c 
                                                                                                    ,POS_Rebate__c,POS_Forecast__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c
                                                                                                FROM OpportunityLineItem
                                                                                                WHERE Id IN: setOfTacticIds
                                                                                                AND OpportunityId IN :setOfDeals 
                                                                                                AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                                                                AND Status__c!='Budget'
                                                                                                ORDER BY Product2.Name]);
        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                totalFailedRecords++;
                tacticWrapperList.get(i).validation = failedDML;
                tacticWrapperList.get(i).errorOccured = true;
            }else{
                tacticWrapperList.get(i).existingId = results.get(i).getId();
                tacticWrapperList.get(i).errorOccured = false;
                tacticWrapperList.get(i).validation = System.label.CRM_Upload_Message_Updated;
                tacticWrapperList.get(i).productName = mapTacticRecords.get(results.get(i).Id).Product2.name;
                tacticWrapperList.get(i).commitmentNum = mapTacticRecords.get(results.get(i).Id).Commitment_Number__c; 
                tacticWrapperList.get(i).status = mapTacticRecords.get(results.get(i).Id).Status__c; 
                tacticWrapperList.get(i).accruingTactic = mapTacticRecords.get(results.get(i).Id).Accruing_Tactic__c;
                tacticWrapperList.get(i).isRowModified = false;
                tacticWrapperList.get(i).isStatusCancelledLocally = false;
                tacticWrapperList.get(i).prevStatusBeforeCancelLocally = '';
            }
        }  
    } 
     
     /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }  
        return currentUserLocale;
    }
    /**
     * Method to get logged in uSer Locale Language code
     */
    global String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
     global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }
    
    /*  
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
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
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public Integer rowIndex;
        public boolean previouslySelectedForRemoval=false;
        public Opportunity deal ; // US#975
        public String  productCode='';
        public String  productName='';
        public String commitmentNum='';
        public String  startDate ;
        public String  endDate ;
        public String  coopReason='';
        public String  coopComments='';
        public Decimal posRebate;
        public Decimal posForecast;
        public Decimal coopReqAmount;
        public Decimal posActual;
        public Decimal coopActualAmt;
        public String  status='';
        public String  custReference='';
        public String  digitalMembership='';
        public Integer numFailedRecords; 
        public boolean accruingTactic =false;
        public boolean isValidCreditNoteItemLinked = false;
        public String videoVersion = '';
        public string localTitleName = '';
        public boolean errorOccured = false;
        // DEF#4676
        public boolean isStatusCancelledLocally = false;
        public String prevStatusBeforeCancelLocally;
       
    } 
    /**
    *  US : 909 - Sprint 2 US Games
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class FinalWrapper {
        public Map<String,Decimal> mapOfDPVVToTotalCBAA; //US#975
        public List<OpportunityLineItemWrapper> dealProdWrap;
        public Boolean maxLimitExceeded=false;
    }
}