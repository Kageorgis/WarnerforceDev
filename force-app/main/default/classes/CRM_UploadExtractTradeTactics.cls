/**
   @Author Cognizant
   @name CRM_UploadExtractTradeTactics
   @CreateDate 22 Nov 2017
   @Description This class is used to upload (update/insert) the deal products US#907.
   @Version <1.0>
   @reference Requirement no 907/910 US Games
*/
global with sharing class CRM_UploadExtractTradeTactics {

    global boolean isAutomaticDeal{get; set;}
    global Decimal totalCoopBudget{get; set;}
    global Map<String,Decimal> mapOfVVToTotalCBA{get; set;}
    public boolean displayQtyCol{get; set;} 
    public static Integer totalFailedRecords;  
    public String handsontableversion{get; set;}
     /** 
    *  @Description - constructor 
    *  @name  CRM_UploadExtractTradeTactics 
    */ 
    global CRM_UploadExtractTradeTactics(ApexPages.StandardController stdController) {
        Id dealId = stdController.getId();
        isAutomaticDeal = false;
        totalCoopBudget = 0;
        mapOfVVToTotalCBA = new Map<String,Decimal>();
         
        if (dealId != null) {
            List<Opportunity> lstOpportunity = [SELECT Id, stageName, Sales_Organisation__c, RecordTypeId FROM Opportunity WHERE Id = :dealId];
            if(lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND){
                 displayQtyCol = true;  
            }
            
            OpportunityLineItem[] listDealProducts = [SELECT Id,Co_op_Budget__c,Product2.Video_Version__c
                                        FROM OpportunityLineItem 
                                        WHERE OpportunityId =: dealId AND Status__c =:CRM_AppConstants.TACTIC_STATUS_BUDGET];
            if(!listDealProducts.isEmpty()){
                isAutomaticDeal = true;
                for(OpportunityLineItem dp : listDealProducts){
                    if(dp.Co_op_Budget__c != null){
                        totalCoopBudget += dp.Co_op_Budget__c;
                        if(!mapOfVVToTotalCBA.containsKey(dp.Product2.Video_Version__c)){
                            mapOfVVToTotalCBA.put(dp.Product2.Video_Version__c,dp.Co_op_Budget__c);
                        }else{
                            Decimal coopBudget = mapOfVVToTotalCBA.get(dp.Product2.Video_Version__c) + dp.Co_op_Budget__c;
                            mapOfVVToTotalCBA.put(dp.Product2.Video_Version__c,coopBudget);
                        }
                    }
                }
            }     
        }
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
    }
    
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
     *  Method to fetch the Deal Product from DealId  
     *  @name getOpportunityLineItems
     *  @param Id opportunityId
     *  @return CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<OpportunityLineItemWrapper> getOpportunityLineItemTactics(Id oppId) {
        // Construct a list of Opportunity Line Items
        List<OpportunityLineItemWrapper> returnWrapperList = new List<OpportunityLineItemWrapper>();
        // Find what products are in the Deal
        /* if(CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c) {
          throw new CRM_ProductPricingHandler.CRM_Exception(Label.CRM_Deal_Entry_NoAccessError);
        }*/
        for(OpportunityLineItem lineItem:
              [SELECT id,Opportunity.Account.Name,Approved_By__c,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c,Credit_Note_Item__c,Credit_Note_Item__r.Credit_Note__r.Status__c,
                                POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c,Product2.Video_Version__c,Product2.Local_Title__r.Name
                                FROM OpportunityLineItem
                                WHERE OpportunityId = :oppId 
                                AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                ORDER BY Product2.Name]
        ) {
                            
          OpportunityLineItemWrapper lineItemWrapper = mapTacticFields(lineItem);
            returnWrapperList.add(lineItemWrapper);
        } 
        return returnWrapperList;
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
            lineItemWrapper.accountName = lineItem.Opportunity.Account.Name;
            lineItemWrapper.productCode = lineItem.Product_Code__c;
            lineItemWrapper.productName = lineItem.Product2.name;
            lineItemWrapper.commitmentNum = lineItem.Commitment_Number__c;
            lineItemWrapper.startDate = String.valueOf(lineItem.Start_date__c);
            lineItemWrapper.endDate = String.valueOf(lineItem.End_date__c);
            lineItemWrapper.coopReason = lineItem.Reason__c ;
            lineItemWrapper.coopComments = lineItem.Comments__c == null ? '' : lineItem.Comments__c; //Defect:4714
            lineItemWrapper.approvedBy = lineItem.Approved_By__c == null ? '' : lineItem.Approved_By__c; //US#995
            lineItemWrapper.posRebate = lineItem.POS_Rebate__c;
            lineItemWrapper.posForecast = lineItem.POS_Forecast__c ;
            lineItemWrapper.coopReqAmount = lineItem.Co_op_Requested_Amount__c == null ? lineItem.Co_op_Requested_Amount__c : (lineItem.Co_op_Requested_Amount__c.SetScale(2));
            lineItemWrapper.posActual= lineItem.Pos_actual__c;
            lineItemWrapper.coopActualAmt = lineItem.Co_op_Actual_Amount__c == null ? lineItem.Co_op_Actual_Amount__c : (lineItem.Co_op_Actual_Amount__c.SetScale(2));
            lineItemWrapper.status = lineItem.Status__c;
            lineItemWrapper.custReference = lineItem.Customer_Reference__c == null ? '' : lineItem.Customer_Reference__c; //Defect:4717
            lineItemWrapper.digitalMembership = lineItem.Digital_Membership__c == null ? '' : lineItem.Digital_Membership__c;  //Defect:4717
            lineItemWrapper.accruingTactic = lineItem.Accruing_Tactic__c;
            lineItemWrapper.videoVersion = lineItem.Product2.Video_Version__c;
            lineItemWrapper.localTitleName = lineItem.Product2.Local_Title__r.Name;
            
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
     *  @return sorted CRM_UploadExtractTradeTactics.FinalOpportunityLineItemWrapper[] with successful upserta nd failed records
     *  @throws None 
     */
    @RemoteAction
    global static List<OpportunityLineItemWrapper> setOpportunityLineItemTactics(List<OpportunityLineItemWrapper> tacticWrapperList,Id oppId, Boolean isTFMUser) { 
     
     List<OpportunityLineItemWrapper> lstToUpsertTactics =new List<OpportunityLineItemWrapper>();
        List<OpportunityLineItem> tacticItemsToUpsert = new List<OpportunityLineItem>(); 
        // 01 =Active ,11=Initial & 06=Cutout 
        Set<String> sAPdistChainProductStatus = new Set<String>{'01','11','06'};
        Set<String> setProductCode = new Set<String>();
        Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>();
        List<OpportunityLineItemWrapper> listLiWrappersToDelete = new List<OpportunityLineItemWrapper>();
        totalFailedRecords = 0;
        
        //Get Opportunity Details like CurrencyCode,Pricebook and existing Deal products for the ProductCode
        List<Opportunity> lstOpportunity = [SELECT id,RecordTypeId, Sales_Organisation__c,Account.Digital_Country_Code__c,StageName,
                                          Pricebook2Id,AccountId,CurrencyISOCode,External_Id__c,
                                          CloseDate,Start_Date__c //US#983 - Added by Nilesh
                                   FROM Opportunity 
                                   WHERE Id =: oppId];
         if(!lstOpportunity.isEmpty()){
            Opportunity opportunity = lstOpportunity[0];
                                       
            // set the index for each line item
            for(Integer i=0; i< tacticWrapperList.size(); i++) {
                tacticWrapperList[i].rowIndex = i;
            }
            
            // Get all the product codes and set the validation if any of the mandatory fields are not entered.
            for(OpportunityLineItemWrapper tacticWrapper : tacticWrapperList){
                tacticWrapper.recrodStatus = ''; // US 994
                tacticWrapper.validation = '';
                tacticWrapper.errorOccured = false;
                if(tacticWrapper.isRowRemoved!=null && tacticWrapper.isRowRemoved == true){
                    if(opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                        tacticWrapper.validation = system.label.CRM_Validation_For_deal_Products_IN_Awaiting_Approval_stage;
                        tacticWrapper.errorOccured = true;
                        tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        continue;
                    }
                    listLiWrappersToDelete.add(tacticWrapper); 
                    
                }else if(tacticWrapper.isRowModified !=null && tacticWrapper.isRowModified == true){
                   
                   //Defect #4677 - TACTICS - The error message displayed in upload/extract when the deal stage is 'Awaiting Approval'
                    if(opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                        tacticWrapper.validation = system.label.CRM_Validation_For_deal_Products_IN_Awaiting_Approval_stage;
                        tacticWrapper.errorOccured = true;
                        tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        continue;
                    }
                    
                    //----------------Validation 1: Check for Valid productCode,startDate,endDate,coopReason  ---------------------------------
                    if(tacticWrapper.productCode == null || tacticWrapper.startDate == null || tacticWrapper.endDate == null || tacticWrapper.coopReason == null ||
                       tacticWrapper.productCode == '' || tacticWrapper.startDate == '' || tacticWrapper.endDate == '' || tacticWrapper.coopReason == '' ){
                            tacticWrapper.validation = system.label.CRM_UploadExtractTactic_MandatoryFields_Validation;
                            tacticWrapper.errorOccured = true;
                            tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                            totalFailedRecords++;
                            continue;
                    }
                    
                    Set<String> setNonAccruingTactics = new Set<String>((Label.CRM_Non_Accruing_Tactics).split(';'));
                    Set<String> setAccruingTactics = new Set<String>((Label.CRM_Accruing_Tactics).split(';'));
                    if(tacticWrapper.existingId != null){
                        if(tacticWrapper.accruingTactic && !setAccruingTactics.contains(tacticWrapper.coopReason)){
                            System.debug('Inside Error Condition1 ');
                            tacticWrapper.validation = system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg;
                            tacticWrapper.errorOccured = true;
                            tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                            totalFailedRecords++;
                            continue;
                        }else if(!tacticWrapper.accruingTactic && !setNonAccruingTactics.contains(tacticWrapper.coopReason)){
                            System.debug('Inside Error Condition2 ');
                            tacticWrapper.validation = system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg;
                            tacticWrapper.errorOccured = true;
                            tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                            totalFailedRecords++;
                            continue;
                        }
                    }else if(!setNonAccruingTactics.contains(tacticWrapper.coopReason) && !setAccruingTactics.contains(tacticWrapper.coopReason)){
                        System.debug('Inside Error Condition3 ');
                        tacticWrapper.validation = system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg;
                        tacticWrapper.errorOccured = true;
                        tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        continue;
                    }
                    
                    if( 
                        tacticWrapper.coopReason == CRM_AppConstants.REASON_POS_REBATE && 
                        (
                            //opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED || 
                            (
                                (
                                    opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED ||
                                    opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_REVISED
                                ) && 
                                tacticWrapper.Status == CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED && 
                                (
                                    (!isTFMUser && tacticWrapper.coopReqAmount == tacticWrapper.coopActualAmt) 
                                    /*||
                                    (
                                        isTFMUser && 
                                        (
                                            (tacticWrapper.coopActualAmt == null) || 
                                            (tacticWrapper.coopReqAmount != null && tacticWrapper.coopReqAmount == tacticWrapper.coopActualAmt)
                                        )
                                    )*/
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
                        tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        continue;
                    } else if( 
                        tacticWrapper.coopReason != CRM_AppConstants.REASON_POS_REBATE && 
                        tacticWrapper.coopReason != CRM_AppConstants.REASON_DIGITAL_WB_PROMO && 
                        tacticWrapper.coopReason != CRM_AppConstants.REASON_DIGITAL_SITE_PROMO &&
						//ER-006847 - Add Co-op Reason Tactic: Digital – Subscription
                        tacticWrapper.coopReason != CRM_AppConstants.REASON_DIGITAL_SUBSCRIPTION &&
                        tacticWrapper.coopReason != CRM_AppConstants.REASON_CANADA_POS_REBATE && 
                        tacticWrapper.posRebate != null
                    ){
                        tacticWrapper.validation = System.Label.CRM_Non_Pos_Rebate_Error;
                        tacticWrapper.errorOccured = true;
                        tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        continue;
                    }
                    
                    if(opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_AWAITING_APPROVAL){
                        tacticWrapper.validation = system.label.CRM_Validation_For_deal_Products_IN_Awaiting_Approval_stage;
                        tacticWrapper.errorOccured = true;
                        tacticWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                        continue;
                    }
                     // SINC1913628 Product code with spaces
                    tacticWrapper.productCode = tacticWrapper.productCode == '' ? tacticWrapper.productCode : tacticWrapper.productCode.trim();
                    setProductCode.add(tacticWrapper.productCode);
                }
            }   
            //---------------------------------Delete Row Functionality begins-----------------------------------------------------//
            if(!listLiWrappersToDelete.isEmpty()) {
               Integer[] lstRowIndexToRemove =  deleteOpportunityLineItems(listLiWrappersToDelete,opportunity.Id);
                for(Integer i= lstRowIndexToRemove.size()-1; i >=0; i--) {
                       Integer indexToRemove = lstRowIndexToRemove[i];
                       system.debug('Row Index to be removed -->'+indexToRemove);
                       system.debug('Row Index Item to be removed -->'+tacticWrapperList[indexToRemove]);
                       tacticWrapperList.remove(indexToRemove);
                }
            }
            //---------------------------------Delete Row Functionality ends-----------------------------------------------------//
            
            //--------------------------------Upsert for Product Code Functionality begins--------------------------------------//    
            //Get PricebookEntry for the entered ProductCodes for valid Deal Pricebook and Currency
            List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
            lstPricebookEntry = getValidPricebookEntryForProductCodes(opportunity,setProductCode);
             
            if(!lstPricebookEntry.isEmpty()){
                for(PricebookEntry pbEntry : lstPricebookEntry){ 
                    String strKey = pbEntry.Pricebook2Id+'-'+pbEntry.Product2.ProductCode+'-'+pbEntry.CurrencyIsoCode;
                    mapOfProductCodeToPB.put(strKey,pbEntry);
                }
            }
            /*US-983: Start - Added by Nilesh */
            Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP = getValidPBEPForProduct(opportunity, setProductCode);
            /*US-983: End - Added by Nilesh */
            
            for(OpportunityLineItemWrapper tacticRecord : tacticWrapperList){
                 if(tacticRecord.isRowModified !=null && tacticRecord.isRowModified == true && (tacticRecord.validation == null || tacticRecord.validation == '')){
      
      OpportunityLineItem tacticItem = new OpportunityLineItem();
          //Form the key and check if PricebookEntry exists for the Product Code and we can add Duplicate Deal Products
          String key = opportunity.Pricebook2Id+'-'+tacticRecord.productCode+'-'+opportunity.CurrencyIsoCode;
          if(mapOfProductCodeToPB.containsKey(key)){
            //----------------Validation 2: Check for Valid Sap Dist Chain product Status ---------------------------------
      //DEF#4721 - Allow user to update tactics (added tacticRecord.existingId == null) 
      if(tacticRecord.existingId == null && !sAPdistChainProductStatus.contains(mapOfProductCodeToPB.get(key).Product2.SAP_Dist_chain_product_Status__c)){
              tacticRecord.validation =System.Label.CRM_UploadBudget_Invalid_SAP_Dist_Chain_Status;
              tacticRecord.errorOccured = true;
              tacticRecord.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
              totalFailedRecords++;
              continue;
            }
              
            if(tacticRecord.existingId == null){
              tacticItem.OpportunityId =opportunity.id;
              tacticItem.PricebookEntryId = mapOfProductCodeToPB.get(key).Id;
              tacticItem.Quantity =1;
              tacticItem.TotalPrice=0;
              
        /*US-983: Start - Added by Nilesh */
        String strKey = tacticRecord.productCode +'-'+ opportunity.Pricebook2Id +'-'+ opportunity.CurrencyIsoCode;
        if(mapUniqueKeyToValidPBEP.containsKey(strKey)) {
          tacticItem.Pricebook_Entry_Period__c = mapUniqueKeyToValidPBEP.get(strKey).Id;
          tacticItem.ListPrice__c = mapUniqueKeyToValidPBEP.get(strKey).List_Price__c;
        }
        else {
          tacticItem.ListPrice__c = 0;
        }
        /*US-983: End - Added by Nilesh */
              
            }else{
              tacticItem.Id=tacticRecord.existingId;
            }
            tacticItem.Start_Date__c =  date.parse(tacticRecord.startDate);
            tacticItem.End_Date__c =  date.parse(tacticRecord.endDate);
            tacticItem.Co_op_Requested_Amount__c = tacticRecord.coopReqAmount == null ? tacticRecord.coopReqAmount :(tacticRecord.coopReqAmount.SetScale(2));
            // When to allow actual amount to be entered.Need to move to handler before insert/update
            tacticItem.Co_op_Actual_Amount__c = tacticRecord.coopActualAmt == null ? tacticRecord.coopActualAmt : (tacticRecord.coopActualAmt.SetScale(2));
            tacticItem.Pos_actual__c = tacticRecord.posActual;
            tacticItem.Customer_Reference__c = tacticRecord.custReference;
            tacticItem.POS_Rebate__c = tacticRecord.posRebate;
            tacticItem.POS_Forecast__c = tacticRecord.posForecast;
            tacticItem.Reason__c = tacticRecord.coopReason;
            tacticItem.Comments__c = tacticRecord.coopComments; 
            tacticItem.Approved_By__c = tacticRecord.approvedBy; //US#995
            tacticItem.Digital_Membership__c = tacticRecord.digitalMembership;
            if(tacticRecord.status == CRM_AppConstants.DEAL_PRODUCT_STATUS_CANCELLED){
                tacticItem.Is_Canceled__c = true;
                tacticItem.Co_op_Actual_Amount__c = 0;
            }
            tacticItemsToUpsert.add(tacticItem);  
            lstToUpsertTactics.add(tacticRecord);
          }else{
            //---------------------Validation 3 : Product or valid PriceBookEntry in product does not exist.-----------------
            tacticRecord.validation =System.Label.CRM_Product_Not_Exist;
            tacticRecord.errorOccured = true;
            tacticRecord.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
            totalFailedRecords++;
            continue; 
            }
        }
      }
      if(!tacticItemsToUpsert.isEmpty()){
          Database.UpsertResult[] result = Database.Upsert(tacticItemsToUpsert, false);
          upsertDMLResultForTactics(result,lstToUpsertTactics,opportunity.Id);
      }
      //--------------------------------Upsert for Product Code Functionality Ends--------------------------------------// 
      
      if(!tacticWrapperList.isEmpty()) {
                tacticWrapperList[0].numFailedRecords = totalFailedRecords;
            } 
        }
        return tacticWrapperList; 
    } 
    
    /**
     *  US# 983 - Added by Nilesh
     *  Method to fetch Valid Pricebook_Entry_Period__c For ProductCodes 
     *  @name getValidPBEPForProduct
     *  @param Opportunity opportunityObject,Set<String> setProductCode
     *  @return map of Pricebook_Entry_Period__c with unique key 
     *  @throws None
    **/ 
    private static Map<String, Pricebook_Entry_Period__c> getValidPBEPForProduct(Opportunity opportunity,Set<String> setProductCode){
    Map<String, Pricebook_Entry_Period__c> mapUniqueKeyToValidPBEP = new Map<String, Pricebook_Entry_Period__c>();
    for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Product__r.ProductCode, CurrencyIsoCode, Price_Book__c  
                        FROM Pricebook_Entry_Period__c
                           WHERE Product__r.ProductCode IN : setProductCode 
                         AND Price_Book__c =: opportunity.Pricebook2Id 
                         AND CurrencyIsoCode =: opportunity.CurrencyISOCode
                         AND Start_Date__c <=: opportunity.CloseDate
                         AND End_Date__c >=: opportunity.Start_Date__c
                      ORDER BY CreatedDate DESC]) {
      String strKey = pbep.Product__r.ProductCode + '-' + pbep.Price_Book__c + '-' + pbep.CurrencyIsoCode;
      if(!mapUniqueKeyToValidPBEP.containsKey(strKey))
        mapUniqueKeyToValidPBEP.put(strKey, pbep);
    }
    return mapUniqueKeyToValidPBEP;
    }
    
    /**
     *  Method to fetch Valid PricebookEntry For ProductCodes 
     *  @name setOpportunityLineItems
     *  @param Opportunity opportunityObject,Set<String> setProductCode
     *  @return Fetched List<PricebookEntry>
     *  @throws None
    **/ 
    private static List<PricebookEntry> getValidPricebookEntryForProductCodes(Opportunity opportunity,Set<String> setProductCode){
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        lstPricebookEntry = [SELECT Id,Product2.ProductCode,Product2.Id,Pricebook2Id,CurrencyIsoCode,Product2.SAP_Dist_chain_product_Status__c
                                    FROM PricebookEntry
                                    WHERE Product2.ProductCode IN :setProductCode 
                                    AND isActive = true 
                                    AND Pricebook2Id =:opportunity.Pricebook2Id 
                                    AND CurrencyIsoCode =:opportunity.CurrencyISOCode];
        return lstPricebookEntry;
        
    }
    
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
    */
    global static void upsertDMLResultForTactics(list<Database.UpsertResult> results,List<OpportunityLineItemWrapper> tacticWrapperList,Id opportunityId) {
        Map<Id,OpportunityLineItem> mapTacticRecords = new Map<Id,OpportunityLineItem> ([SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Digital_Membership__c,
                                                        Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c,Accruing_Tactic__c 
                                                        ,POS_Rebate__c,POS_Forecast__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c
                                                        FROM OpportunityLineItem
                                                        WHERE opportunityId =:opportunityId AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND AND Status__c!='Budget'
                                                        ORDER BY Product2.Name]);
        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                totalFailedRecords++;
                tacticWrapperList.get(i).validation = failedDML;
                tacticWrapperList.get(i).errorOccured = true;
                tacticWrapperList.get(i).recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
            }else{
                tacticWrapperList.get(i).existingId = results.get(i).getId();
                tacticWrapperList.get(i).errorOccured = false;
                tacticWrapperList.get(i).recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                if(results[i].isCreated()){
                    tacticWrapperList.get(i).validation = System.label.CRM_Upload_Message_Created;
                }else{
                    tacticWrapperList.get(i).validation = System.label.CRM_Upload_Message_Updated;
                } 
                tacticWrapperList.get(i).productName = mapTacticRecords.get(results.get(i).Id).Product2.name;
                tacticWrapperList.get(i).accountName = mapTacticRecords.get(results.get(i).Id).Opportunity.Account.Name; 
                tacticWrapperList.get(i).commitmentNum = mapTacticRecords.get(results.get(i).Id).Commitment_Number__c; 
                tacticWrapperList.get(i).status = mapTacticRecords.get(results.get(i).Id).Status__c; 
                tacticWrapperList.get(i).accruingTactic = mapTacticRecords.get(results.get(i).Id).Accruing_Tactic__c;
                tacticWrapperList.get(i).isRowModified = false;
                // DEF#4676
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
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }  
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
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
     *  Method to fetch user input and perform delete operation on existing records
     *  @name deleteOpportunityLineItems
     *  @param CRM_UploadDealProductsController.OpportunityLineItemWrapper[] and Opportunity Id
     *  @return Integer[] list of row indexes to be removed from original list
     *  @throws None
     */ 
    global static Integer[] deleteOpportunityLineItems(List<OpportunityLineItemWrapper> lstLiWrappersToDelete,Id opportunityid) {
        List<Id> listLineItemsToRemove = new List<Id>();
        List<OpportunityLineItemWrapper> listLiWrappersToRemove = new List<OpportunityLineItemWrapper>(); 
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        Id OppId;
        
        if(lstLiWrappersToDelete!=null) {
            for (OpportunityLineItemWrapper wrapper : lstLiWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    OppId = opportunityid;
                    wrapper.isRowRemoved  = false;
                    wrapper.isRowModified = false;
                    wrapper.errorOccured = false;
                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                    listLiWrappersToRemove.add(wrapper);                    
                    listLineItemsToRemove.add(wrapper.existingId);
                }
                else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }
            }
        }
        try {
            
            list<Database.DeleteResult> deleteLiResults = Database.delete(listLineItemsToRemove,false);
            
            for(Integer i=0; i < deleteLiResults.size(); i++){
                OpportunityLineItemWrapper lineItemWrapper = listLiWrappersToRemove.get(i);
                lineItemWrapper.isRowModified = false;
                lineItemWrapper.isRowRemoved = false;
                
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    totalFailedRecords++;
                    system.debug('Failed ID remove -'+listLiWrappersToRemove.get(i));
                    
                    lineItemWrapper.existingId = listLineItemsToRemove[0];
                    lineItemWrapper.validation = failedDML;
                    lineItemWrapper.errorOccured = true;
                    lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                 } else {
                    lstRowIndexToRemove.add(lineItemWrapper.rowIndex);
                }
            }
        }catch(Exception e) {
            logException(OppId,e);
            
            for(Integer i=0; i < listLiWrappersToRemove.size(); i++){
                OpportunityLineItemWrapper lineItemWrapper = listLiWrappersToRemove[i];
                lineItemWrapper.isRowModified = false;
                lineItemWrapper.existingId = lineItemWrapper.existingId;
                lineItemWrapper.validation = e.getMessage();
                lineItemWrapper.errorOccured = true;
                lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
             }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove;
    }
    
    public static void logException(Id oppId,Exception e){
                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                errorLog.recordId = oppId;
                // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
                errorLog.lineNumber = String.valueOf(e.getLineNumber());
                errorLog.errorMessage = e.getMessage();
                errorLog.stackTrace = e.getStackTraceString(); 
                // Call the logError method which will insert all errors into CRM_Error_Log__c object
                CRM_ErrorLogger.logError(errorLog);
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
        public String  accountName='';
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
        //US#995 add approver to Tactic
        public String approvedBy = '';
        
        //US : 994 
        public string recrodStatus='';
    } 
    
    /**
     *  US : 909 - Sprint 2 US Games
     *  Method to feach products list for AddSearchProduct screen
     *  @name getProductsForAddSearchProductScreen
     *  @param Id oppId,Id pricebookId
     *  @return List<product2> - List of Products
     *  @throws None
     */
    @RemoteAction
    global static List<productSearchWrapper> getProductsForAddSearchProductScreen(Id pricebookId, String quickSearchText, String dealCurrency, String dealAccountName, String startDate, String endDate) { 
        List<productSearchWrapper> lstProducts = new List<productSearchWrapper>();
        List<String> lstQuickSearchText = new List<String>();
        // 01 =Active ,11=Initial & 06=Cutout 
        Set<String> sAPdistChainProductStatus = new Set<String>{'01','11','06'};
        Integer recordLimit = CRM_Batch_Size__c.getInstance('CRM_UploadExtract_ProdSrch_Rec_Lmt') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('CRM_UploadExtract_ProdSrch_Rec_Lmt').Batch_Size__c) : 50;
        
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
            String SOSL_QUERY_PRODUCT = 'FIND {'+ sosl_search +'} IN ALL FIELDS'+
                                        ' RETURNING Product2(Id,Name,ProductCode,toLabel(Product2.Product_Format__c),Street_date__c,Video_Version__c,Local_Title__r.Name'+
                                        ' Where SAP_Dist_chain_product_Status__c IN :sAPdistChainProductStatus AND CurrencyISOCode = :dealCurrency AND isActive = true ORDER BY Name ASC) WITH PricebookId = \''+ pricebookId +'\' LIMIT '+String.valueOf(recordLimit);
            
            //Added By Harshad for US 1014
            if(sosl_search.length() > 4000)
                throw new CRM_UploadExtractTardeTacticsException(Label.CRM_SOSL_Search_String_Limit_Reached);
            
            List<List<SObject>> searchResult = Search.query(SOSL_QUERY_PRODUCT);
            
            for(Sobject[] listObj : searchResult) {
                for(sobject sobj : listObj) {
                    productSearchWrapper productSearchWrap = new productSearchWrapper();
                    
                    Product2 prod = (Product2)sobj;
                    CRM_DataObjects.ProductItem prodItem = new CRM_DataObjects.ProductItem();
                    
                    prodItem.name = prod.name;
                    prodItem.productId = prod.Id;
                    prodItem.productCode = prod.ProductCode;
                    prodItem.streetDate = prod.Street_Date__c;
                    prodItem.format = prod.Product_Format__c;
                    productSearchWrap.product = prodItem;
                    
                    OpportunityLineItemWrapper prodWrap = new OpportunityLineItemWrapper();
                    prodWrap.accountName = dealAccountName;
                    prodWrap.productCode = productSearchWrap.product.ProductCode;
                    prodWrap.productName = productSearchWrap.product.Name;
                    prodWrap.startDate = startDate;
                    prodWrap.endDate = endDate;
                    prodWrap.status = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
                    prodWrap.isRowModified =true;
                    prodWrap.videoVersion = prod.Video_Version__c;
                    prodWrap.localTitleName = prod.Local_Title__r.Name;
                    
                    //Defect : 4717
                    prodWrap.coopComments =  '';
                    prodWrap.custReference = ''; 
                    prodWrap.approvedBy = ''; //US#995
                    prodWrap.digitalMembership = '';
                    prodWrap.validation = '';
                    prodWrap.recrodStatus = ''; //US : 994
                    productSearchWrap.dealProdWrap = prodWrap;
                    productSearchWrap.isSelected = false;
                    lstProducts.add(productSearchWrap);
                }
            }
        }
        return lstProducts;
    }
    
    //US : 989
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    } 
    /**
    * Method to get logged in uSer Locale in Lower case
    */
    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }
    
    /**
    *  US : 909 - Sprint 2 US Games
    *  @Description - wrapper class
    *  @name  OpportunityLineItemWrapper 
    */
    global class productSearchWrapper {
        public CRM_DataObjects.ProductItem product;
        public OpportunityLineItemWrapper dealProdWrap;
        public boolean isSelected = false;
    }
    //Added By Harshad for US 1014
    global class CRM_UploadExtractTardeTacticsException extends Exception {}
}