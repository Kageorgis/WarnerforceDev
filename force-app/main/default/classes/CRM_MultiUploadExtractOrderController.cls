/**
   @Author Cognizant
   @name CRM_MultiUploadExtractOrderController
   @CreateDate 12 Oct 2016
   @Description This class is used to upload (update/insert) the Order and Order products.
   @Version <1.0>
   @reference Requirement no 476
*/
global with sharing class CRM_MultiUploadExtractOrderController{
    
    public Id parentMultiOrderId{get; set;}
    public static Map<String,Id> mapOfAccNumAccount ;
    public static List<Order> lstParentOrder;
    public static  Map<Id,Account> mapOfAccountsForOrders;
    public static map<string,List<Id>> mapOfProdCodeProdId = new map<string,List<Id>>();
    public static map<string,List<id>> mapOfUpcEanProdId = new map<string,List<Id>>();
    public static Set<String> setOfAccounts;
    public static Map<String,Order> mapOfAccNumToSucessOrder;
    public static Set<Id> setPricebookIds; 
    public static List<String> lstAccNumberOfSuccessOrders;
    public static Set<String> setOfProducts;
    public static Map<String,String> mapOfProIndex;
    public static Map<String,String> mapOfAccIndex;
    public static Map<String,List<String>> mapOfProAccValidatinos = new Map<String,List<String>>();
    public static Map<Id,String> mapOfOrderIdToAccountNumber;
    public static map<Integer,String> mapOfIndexAcc;
    public static final String VALIDATION_FOR_PRODUCT = 'Product';
    public static final String VALIDATION_FOR_ACCOUNT = 'Account';
    public static List<String> lstCustomerPONumbers;
    public static map<String,String> mapOfAccNumCustNum;
    public static set<String> modefiedProCodeUPCNum = new Set<String>();
    public static boolean updateAccSeqFlag = true;
    static Datetime startTime;
    static Datetime endTime;
    //Defect#4409 - Nilesh, code change for japan specific error message
    public Boolean isJapan {get;set;}
    public String handsontableversion{get; set;}
    
    /**
    *  @Description - constructor
    *  @name  CRM_MultiUploadExtractOrderController 
    */
    global CRM_MultiUploadExtractOrderController(ApexPages.StandardController stdController) {
        isJapan = false;
        parentMultiOrderId =  stdController.getId();
        //Defect#4409 - Nilesh, code change for japan specific error message
        if(parentMultiOrderId != null){
            List<Order> parentOrder = [Select Id,Sales_Organisation__c From Order Where Id =: parentMultiOrderId];
            if(!parentOrder.isEmpty() && parentOrder[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE){
                isJapan = true;
            }
        }
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;  
    }
    
    //Start - US : 989
	public string getHandsonTable_Pro_Licencekey (){
		return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
	}
	//End - US : 989
    
     //US : 989
    public boolean getUserLocaleForCSV(){
        String availableLocales =CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c != null ? CRM_Default_Configuration__c.getOrgDefaults().User_Locale__c : '';
        List<String> lstAvailableLocales = availableLocales.split(',');
        Set<String> setOfLocales = new Set<String>();
        setOfLocales.addall(lstAvailableLocales);
        if(setOfLocales.contains(getUserLocale() )){
            return true;
        }else{
            return false;
        }
    } 
    
    
    @RemoteAction
    global static CRM_InitialWrapperClass getInitialValidations(String accountString,String productString,String customerPoNumberString,String parentOrderId){
         startTime = system.now();
         system.debug('getInitialValidations startTime '+startTime);
         CRM_InitialWrapperClass initialWrapInstance = new CRM_InitialWrapperClass();
         if(accountString == '' || productString == '' || customerPoNumberString == ''){
            initialWrapInstance.errorMsgForEmptyFirstRowColAndSecondRow = system.label.CRM_MultiOrder_Empty_RowCol_Msg;
            return initialWrapInstance;
         }
         mapOfProAccValidatinos = new Map<String,List<String>>();
         mapOfProIndex= new Map<String,String>();
         mapOfAccIndex = new Map<String,String>();
         mapOfAccNumAccount = new Map<String,Id>();
         mapOfIndexAcc = new Map<Integer,String>();
         mapOfAccNumCustNum = new Map<String,String>();
         lstCustomerPONumbers =new List<String>();
         lstCustomerPONumbers = customerPoNumberString.split(',');
         //system.debug('lstCustomerPONumbers::'+lstCustomerPONumbers);
         //system.debug('productString::'+productString);
          
         setOfAccounts = getTraversedListString(true,accountString,mapOfAccIndex,mapOfProAccValidatinos);
         setOfProducts = getTraversedListString(false,productString,mapOfProIndex,mapOfProAccValidatinos);
         //system.debug('Before getInitialValidations mapOfProAccValidatinos:::'+mapOfProAccValidatinos);

         //Get Parent Order and the account
         lstParentOrder = getParentOrder(parentOrderId);   
         Set<String> setOfProductCodeOfDp = new Set<String>();
         Set<String> setOfUPCEANNumOfDp = new Set<String>();
         boolean isDealPresent = false;
         if(lstParentOrder.size() > 0 && lstParentOrder[0].OpportunityId != null && (lstParentOrder[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER || lstParentOrder[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE)){
            isDealPresent = true;
            getAllDealProductAndUPCEANNum(initialWrapInstance,lstParentOrder[0].OpportunityId,setOfProductCodeOfDp,setOfUPCEANNumOfDp);
         }
         populateProductsFromProductCodeOrUpcEan(lstParentOrder[0],setOfProductCodeOfDp,setOfUPCEANNumOfDp,isDealPresent);
         validateProduct();

         //Create Orders based on the Accounts in the grid
         mapOfAccountsForOrders = new Map<Id,Account>(getShipToAccountsFromAccNumber(setOfAccounts)); 
         for(Account acc : mapOfAccountsForOrders.values()){
            mapOfAccNumAccount.put(acc.AccountNumber,acc.Id);
         } 
         validateAccount();
        
         if(mapOfProAccValidatinos.size() > 0 || initialWrapInstance.errorMsgRelatedDp != ''){
            initialWrapInstance.mapOfProAccValidatinosWrap = mapOfProAccValidatinos;
            return initialWrapInstance;
         }
         
         if(!lstParentOrder.isEmpty()){
            Map<id,Order> mapAccountIdOrder = getMapOfAccountIdAndExistingOrders(setOfAccounts,lstParentOrder[0].id); 
            Map<id,Order> mapOfOrdersTobeInserted = createNewOrUpdateExistingOrders(mapAccountIdOrder) ;
         
            Set<id> setOrderIds =new Set<id>();
            if(!mapOfOrdersTobeInserted.isEmpty()){
                Database.UpsertResult[] srList = Database.upsert(mapOfOrdersTobeInserted.values(),false); 
                for (Integer i = 0; i < srList.size(); i++) {
                    Database.UpsertResult saveResultInstance = srList[i];
                    Order orderInstance = mapOfOrdersTobeInserted.values()[i];
                    if (saveResultInstance.isSuccess()) { 
                        setOrderIds.add(orderInstance.id);  
                    }else{
                        // Operation failed, so get all errors       
                        for(Database.Error err : saveResultInstance.getErrors()) { 
                            ////system.debug('err.getMessage() ::: '+err.getMessage());
                            String accountNumber = mapOfAccountsForOrders.get(orderInstance.Ship_To_Account__c).AccountNumber; 
                            addValidations(VALIDATION_FOR_ACCOUNT,err.getMessage(),mapOfAccIndex.get(accountNumber));
                        } 
                    }
                }
            }
            
            setPricebookIds = new Set<Id>();
            mapOfAccNumToSucessOrder = new Map<String,Order>();
            mapOfOrderIdToAccountNumber = new Map<Id,String>();
            List<String> sucessOrderAccountNumber = new List<String>();
            //List<String> sucessOrderCustomerPONumber = new List<String>();
            if(!setOrderIds.isEmpty()){
                for(Order orderRec: [SELECT Customer_PO_Number__c,Multi_Order__c,
                                            CurrencyIsoCode,PriceBook2Id,Ship_To_Account__c,
                                            Ship_To_Account__r.AccountNumber 
                                            FROM Order 
                                            WHERE Id IN: setOrderIds]){
                     //Ankita Changes Required
                     mapOfAccNumToSucessOrder.put(orderRec.Ship_To_Account__r.AccountNumber,orderRec);
                     sucessOrderAccountNumber.add(orderRec.Ship_To_Account__r.AccountNumber);
                     //sucessOrderCustomerPONumber.add(orderRec.Customer_PO_Number__c);
                     setPricebookIds.add(orderRec.PriceBook2Id);
                     mapOfOrderIdToAccountNumber.put(orderRec.Id,orderRec.Ship_To_Account__r.AccountNumber);
                }
            }
            updateParentOrderAccSeq(sucessOrderAccountNumber);
            if(mapOfProAccValidatinos.size() > 0){
                initialWrapInstance.mapOfProAccValidatinosWrap = mapOfProAccValidatinos;
                return initialWrapInstance;
            }
            initialWrapInstance.mapOfAccIndexWrap = mapOfAccIndex;
            initialWrapInstance.mapOfAccNumToSucessOrderWrap = mapOfAccNumToSucessOrder;
            initialWrapInstance.setPricebookIdsWrap = new List<Id>(setPricebookIds);
            initialWrapInstance.mapOfOrderIdToAccountNumberWrap = mapOfOrderIdToAccountNumber;
            initialWrapInstance.mapOfIndexAccWrap = mapOfIndexAcc;
            initialWrapInstance.mapOfProIndexWrap = mapOfProIndex;
            initialWrapInstance.mapOfProdCodeProdIdWrap = mapOfProdCodeProdId;
            initialWrapInstance.mapOfUpcEanProdIdWrap = mapOfUpcEanProdId;
            initialWrapInstance.validationFlag = true;
        }
        endTime = system.now();
        system.debug('createOrdersAndOrderProducts endTime '+endTime);
        system.debug('createOrdersAndOrderProducts Diff '+((endTime.getTime()/1000) - (startTime.getTime()/1000)));
        return initialWrapInstance;
    }
     
    @RemoteAction
    global static Map<String,List<String>> createOrdersAndOrderProducts(CRM_InitialWrapperClass initialWrapInstance,List<String> lstOfUploadedOrders,String parentOrderId,Boolean lastChunkFlag) {
        startTime = system.now();
        system.debug('createOrdersAndOrderProducts startTime '+startTime);
        Database.UpsertResult[]  srList;  
        mapOfAccIndex = initialWrapInstance.mapOfAccIndexWrap;
        mapOfIndexAcc = initialWrapInstance.mapOfIndexAccWrap;
        setPricebookIds = new Set<Id>(initialWrapInstance.setPricebookIdsWrap);
        mapOfOrderIdToAccountNumber = initialWrapInstance.mapOfOrderIdToAccountNumberWrap;
        mapOfAccNumToSucessOrder = initialWrapInstance.mapOfAccNumToSucessOrderWrap;
        mapOfProIndex = initialWrapInstance.mapOfProIndexWrap;
        mapOfProdCodeProdId = initialWrapInstance.mapOfProdCodeProdIdWrap;
        mapOfUpcEanProdId = initialWrapInstance.mapOfUpcEanProdIdWrap;
        lstParentOrder = getParentOrder(parentOrderId);
        
        system.debug('Time : 171 : '+system.now());
        //Start: Create map of Product Code/ Product UPC/EAN  and Product  
        map<String,List<OrderWrapper>> mapOfAccIdWrapper = getOrderWrapperMapofAccIdToOrderWrapper(lstOfUploadedOrders);
        system.debug('Time : 175 : '+system.now());
        List<String> lstProdNumberOfSuccessOrderProd = createOrderProducts(initialWrapInstance,mapOfAccIdWrapper);
        system.debug('Time : 177 : '+system.now());

        updateParentOrderProdSeq(lstProdNumberOfSuccessOrderProd,parentOrderId); 
        
        //Delete Child Orders having zero order Products
        if(lastChunkFlag)
            deleteChildOrders();
        endTime = system.now();
        system.debug('createOrdersAndOrderProducts endTime '+endTime);
        system.debug('createOrdersAndOrderProducts Diff '+((endTime.getTime()/1000) - (startTime.getTime()/1000)));
        return mapOfProAccValidatinos;
    }//end method
  
  //US#585
    private static void getAllDealProductAndUPCEANNum(CRM_InitialWrapperClass initialWrapInstance,Id dealId,Set<String> setOfProductCodeOfDp,Set<String> setOfUPCEANNumOfDp){
        List<OpportunityLineItem> lstDealProduct = [Select Id,product2.ProductCode,product2.Universal_Picture_Code__c From OpportunityLineItem Where OpportunityId = :dealId];
        if(!lstDealProduct.isEmpty()){
            for(OpportunityLineItem dp : lstDealProduct){
                setOfProductCodeOfDp.add(dp.product2.ProductCode);    
                if(dp.product2.Universal_Picture_Code__c != null)
                    setOfUPCEANNumOfDp.add(dp.product2.Universal_Picture_Code__c);
            }
        }else{
            initialWrapInstance.errorMsgRelatedDp = system.label.CRM_MultiOrder_No_Deal_Products;
        }
   }
   private static void deleteChildOrders(){
          List<Order> zeroOrderProductsOrders = [Select Id From Order 
                              Where Multi_Order__c =: lstParentOrder[0].Id AND 
                              Count_of_Order_Product__c = 0 AND (RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_STANDARD OR RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_RETURN OR RecordTypeId = :CRM_RecordTypeUtil.RT_ORDER_REV_SHARE)];
          if(!zeroOrderProductsOrders.isEmpty()){
            updateAccSeqFlag = false;
            delete zeroOrderProductsOrders;
            updateAccSeqFlag = true;
         }
   }
   
   private static void updateParentOrderAccSeq(List<String> sucessOrderAccountNumbher){
        Set<String> setOfAccountSequence =new Set<String>();
        if(lstParentOrder[0].Order_Account_Sequence__c != null) { 
            setOfAccountSequence.addall(lstParentOrder[0].Order_Account_Sequence__c.split(','));
        }
        if(!sucessOrderAccountNumbher.isEmpty()) {
             for(String accNum : sucessOrderAccountNumbher) {
                if(lstParentOrder[0].Order_Account_Sequence__c == null) {
                    lstParentOrder[0].Order_Account_Sequence__c=accNum;
                } else if(!setOfAccountSequence.contains(accNum)) {
                    lstParentOrder[0].Order_Account_Sequence__c = lstParentOrder[0].Order_Account_Sequence__c+','+accNum;        
                } 
            }
        }
        update lstParentOrder;
   }
    
   private static void addValidations(String validationFor,String errorMsg,String index){
        if(index != null){  
            String tempIndex;
            //system.debug('index:::::'+index+'errorMsg:::::'+errorMsg );
            if(validationFor == VALIDATION_FOR_ACCOUNT)
                tempIndex = '0-'+index;
            else if(validationFor == VALIDATION_FOR_PRODUCT )
                tempIndex = index+'-0';
                
            ////system.debug('tempIndex:::::'+tempIndex+'::::::'+mapOfProAccValidatinos.keySet());
            
            if(mapOfProAccValidatinos.containsKey(tempIndex)){
                Set<String> setOfErrorMsg = new Set<String>(mapOfProAccValidatinos.get(tempIndex));
                if(!((setOfErrorMsg.contains(System.Label.CRM_MultiOrder_Duplicate_Account) 
                        || setOfErrorMsg.contains(System.Label.CRM_MultiOrder_Duplicate_Product_Found)) 
                        && (errorMsg.equalsIgnoreCase(System.label.CRM_Account_Not_Exist) 
                        || errorMsg.equalsIgnoreCase(System.label.CRM_Product_Not_Exist)
                        || errorMsg.equalsIgnoreCase(System.label.CRM_Product_Not_Exist)
                        || errorMsg.contains(System.label.CRM_MultiOrder_Duplicate_Product_FoundWithUPC_Code))))
                            mapOfProAccValidatinos.get(tempIndex).add(errorMsg);
            }else{
                mapOfProAccValidatinos.put(tempIndex,new List<String>{errorMsg});
            }
        }
        
   }
   
   private static void addValidationsForOrderProduct(String errorMsg,String productKey,String accountKey){
       ////system.debug('productKey '+productKey);
       ////system.debug('accountKey '+accountKey);
       if(mapOfProIndex != null && mapOfAccIndex != null){
           String productIndex = (mapOfProIndex.containsKey(productKey) && mapOfProIndex.get(productKey) != null) ? mapOfProIndex.get(productKey) : '';
           String accountIndex = (mapOfAccIndex.containsKey(accountKey) && mapOfAccIndex.get(accountKey) != null) ? mapOfAccIndex.get(accountKey) : '';
           
           ////system.debug('accountIndex '+accountIndex );
           ////system.debug('productIndex '+productIndex);
           
           
           if(productIndex != '' && accountIndex != ''){
                String indexOfOrderProduct = productIndex+'-'+accountIndex;
                ////system.debug('indexOfOrderProduct :::::'+indexOfOrderProduct );    
                if(mapOfProAccValidatinos.containsKey(indexOfOrderProduct )){
                    mapOfProAccValidatinos.get(indexOfOrderProduct ).add(errorMsg);
                }else{
                    mapOfProAccValidatinos.put(indexOfOrderProduct,new List<String>{errorMsg});
                }
           }
       }
   }
   
   private static void validateAccount(){
       for(String key : mapOfAccIndex.KeySet()){
            ////system.debug('Account key :::::'+key);
            if(!mapOfAccNumAccount.containsKey(key)){
                addValidations(VALIDATION_FOR_ACCOUNT,System.label.CRM_Account_Not_Exist,mapOfAccIndex.get(key));
            }else{
                if(mapOfAccountsForOrders.get(mapOfAccNumAccount.get(key)).RecordTypeId != CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO && mapOfAccNumAccount.get(key) != lstParentOrder[0].Account.Id){
                    addValidations(VALIDATION_FOR_ACCOUNT,System.label.CRM_Account_Not_ShipToType,mapOfAccIndex.get(key));
                }else if(lstParentOrder[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE && !mapOfAccountsForOrders.get(mapOfAccNumAccount.get(key)).Revenue_Share__c && mapOfAccNumAccount.get(key) != lstParentOrder[0].Account.Id){
                  addValidations(VALIDATION_FOR_ACCOUNT,System.label.CRM_Account_Not_Revenue_Share_ShipToType,mapOfAccIndex.get(key));
                }else if(!mapOfAccountsForOrders.get(mapOfAccNumAccount.get(key)).Video_Physical__c && 
                     !mapOfAccountsForOrders.get(mapOfAccNumAccount.get(key)).Games_Physical__c && 
                     !mapOfAccountsForOrders.get(mapOfAccNumAccount.get(key)).Music_Physical__c){
                  addValidations(VALIDATION_FOR_ACCOUNT,System.label.CRM_Not_Valid_Account,mapOfAccIndex.get(key));              
                }
            }
        }
   }
   
  private static void validateProduct(){
       for(String key : mapOfProIndex.KeySet()){
            if(!mapOfProdCodeProdId.containsKey(key) && !mapOfUpcEanProdId.containsKey(key)){
                addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Product_Not_Exist,mapOfProIndex.get(key));
            } 
        }  
   }

   private static void updateParentOrderProdSeq(List<String> lstProdNumberOfSuccessOrderProd,String parentOrderId){
        /*Start: Update Parent Order with Account Sequence and Product Number Sequence */
        boolean productUpdateFlag = false;
        Set<String> setOfProductSequence =new Set<String>();
        lstParentOrder = getParentOrder(parentOrderId);
        if(lstParentOrder[0].Order_Product_Sequence__c!=null) {
            setOfProductSequence.addall(lstParentOrder[0].Order_Product_Sequence__c.split(','));
        }
        if(!lstProdNumberOfSuccessOrderProd.isEmpty())
        {
            for(String prodNum:lstProdNumberOfSuccessOrderProd){
                if(lstParentOrder[0].Order_Product_Sequence__c==null) {
                    productUpdateFlag = true;
                    lstParentOrder[0].Order_Product_Sequence__c = prodNum;
                } else if(!setOfProductSequence.contains(prodNum)){
                    productUpdateFlag = true;
                    lstParentOrder[0].Order_Product_Sequence__c = lstParentOrder[0].Order_Product_Sequence__c+','+prodNum;
                }
            }
        }
        if(productUpdateFlag)
            Database.update(lstParentOrder,false);
        ////system.debug('lstParentOrder[0].Order_Product_Sequence__c::::::::'+lstParentOrder[0].Order_Product_Sequence__c+'lstParentOrder[0].Order_Account_Sequence__c ::::'+lstParentOrder[0].Order_Account_Sequence__c );
   }
   
   private static Set<String>  getTraversedListString(Boolean flagForAcc,String StringToBeTraversed,Map<String,String> mapOfProAccIndexNumber,Map<String,List<String>> mapOfProAccValidation){
        Set<String> setOfProdCodeOrAccNum = new Set<String>(StringToBeTraversed.split(','));
        integer indexOfAccPro = flagForAcc ? 0 : 1;
        for(String indiValue : StringToBeTraversed.split(',')){
            indexOfAccPro++;
            //system.debug('Acc-Pro '+indexOfAccPro+'----'+indiValue);
            if(!mapOfProAccIndexNumber.containsKey(indiValue)){
                mapOfProAccIndexNumber.put(indiValue,String.ValueOf(indexOfAccPro));
                if(flagForAcc){
                    mapOfIndexAcc.put(indexOfAccPro,indiValue);
                    if(!mapOfAccNumCustNum.containsKey(indiValue) && !lstCustomerPONumbers.isEmpty()){
                         mapOfAccNumCustNum.put(indiValue,lstCustomerPONumbers.get(indexOfAccPro-1));
                    }
                }
            }else{
                String firstDuplicateKey;
                String secondDuplicateKey;
                String validation;
                if(flagForAcc){
                    if(mapOfProAccIndexNumber.get(indiValue) != null)
                        firstDuplicateKey = '0-'+mapOfProAccIndexNumber.get(indiValue);
                    secondDuplicateKey = '0-'+String.ValueOf(indexOfAccPro);
                    validation = System.Label.CRM_MultiOrder_Duplicate_Account;
                }else{
                    if(mapOfProAccIndexNumber.get(indiValue) != null)
                        firstDuplicateKey = mapOfProAccIndexNumber.get(indiValue)+'-0';
                    secondDuplicateKey = String.ValueOf(indexOfAccPro)+'-0';
                    validation = System.Label.CRM_MultiOrder_Duplicate_Product_Found;
                }
                if(firstDuplicateKey != null && !mapOfProAccValidation.containsKey(firstDuplicateKey))
                    mapOfProAccValidation.put(firstDuplicateKey,new List<String>{validation});
                    if(!mapOfProAccValidation.containsKey(secondDuplicateKey)){
                mapOfProAccValidation.put(secondDuplicateKey,new List<String>{validation});}
            }
        }
        return setOfProdCodeOrAccNum;
   }
   
   private static List<Order> getParentOrder(Id parentOrderId)
   {
        return [SELECT Sales_Organisation__c, RecordTypeId, Account.Id ,OpportunityId, Account.RecordTypeId,Account.AccountNumber, Account.Price_Book__c,EffectiveDate ,Pricebook2Id,Reason__c,
                CurrencyIsoCode,EndDate,id,Customer_PO_Number__c,Requested_Delivery_Date__c,Order_Account_Sequence__c ,Order_Product_Sequence__c  
                FROM Order 
                WHERE /*RecordTypeId =:CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER
                AND*/ Account.RecordTypeId=:CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO
                AND ID =:parentOrderId];
   }
   
   private static List<Account> getShipToAccountsFromAccNumber(Set<String> setOfAccountNumbers){
        List<Account> lstAccounts=  [SELECT ID,NAME,Sold_to_customer__r.RecordTypeId,RecordTypeId, Price_Book__c ,AccountNumber,Video_Physical__c,Games_Physical__c,Music_Physical__c,Revenue_Share__c,Sales_Organization__c
                                    FROM Account 
                                    WHERE AccountNumber IN :setOfAccountNumbers];
                                    //AND RecordTypeId=:CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO];
        return lstAccounts;
   }
   
   private static void populateProductsFromProductCodeOrUpcEan(Order parentOrder,Set<String> setOfProductCodeOfDp,Set<String> setOfUPCEANNumOfDp,Boolean isDealPresent){
        // 01 =Active , 04 =On Hold & 11=Initial & 05 ,Z5 for Non-Returnable 
        Set<String> sAPdistChainProductStatus = new Set<String>{'01','04','11','05','Z5'};

        // 04=Active , 02=Released for 3rd Party & 05=Sell-down/Sell-Off
        Set<String> plantSpecificMaterialStatus = new Set<String>{'04','02','05'};

        // DEF#4114
        Set<String> distChainProdStatusForReturns =
            new Set<String>{
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_Z5,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_05,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_INITIAL
            };

        if (parentOrder.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) {
            plantSpecificMaterialStatus.add(CRM_AppConstants.PRODUCT_PLANT_STATUS_INITIAL);
        }
        
        //Defect#4404
        distChainProdStatusForReturns.add(CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_LOST_RIGHTS);
        // Restrict lost Rights only for territories apart from Italy
        /*if (parentOrder.Sales_Organisation__c != CRM_AppConstants.TERRITORY_ITALY_CODE) {
            distChainProdStatusForReturns.add(CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_LOST_RIGHTS);
        }*/

        map<String,String> mapProdIdProdNum =new map<string,string>();

        // Set Dist Chain Status not allowed in error message dynamically
        Map<String,String> setDistChainStatusMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Product2.SAP_Dist_chain_product_Status__c.getDescribe();
        List<Schema.PicklistEntry> distChainStatus = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry status: distChainStatus){
            setDistChainStatusMap.put(status.getValue(), status.getLabel());
        }
        
        String sapDistChainAllowedValues = '';
        Integer countRecords = 0;
        Set<String> removeDuplicateValues = new Set<String>();
        for (String distChainStatusCode : distChainProdStatusForReturns) {
            if (setDistChainStatusMap.containsKey(distChainStatusCode)) {
                String distChainStatusValue = setDistChainStatusMap.get(distChainStatusCode);
                if (!removeDuplicateValues.contains(distChainStatusValue)) {
                    removeDuplicateValues.add(distChainStatusValue);
                    sapDistChainAllowedValues += distChainStatusValue;
                    if (countRecords < distChainProdStatusForReturns.size()-1) {
                        sapDistChainAllowedValues += ' / ';
                    }
                }
            }
            countRecords++;
        }

        String queryString = 'SELECT ID,Product2Id,Product2.NAME,Product2.CurrencyIsoCode,Product2.ProductCode,Product2.Universal_Picture_Code__c,Product2.isActive,' +
                             'Product2.Type__c,Product2.SAP_Dist_chain_product_Status__c,Product2.Plant_Specific_Material_Status__c,Product2.Product_Market__c,' +
                             'Product2.Return_End_Date__c, Product2.SAP_Sales_Org__c ' +
                             'FROM PricebookEntry WHERE Pricebook2Id = \'' + parentOrder.Account.Price_Book__c +'\' AND (Product2.ProductCode IN: setOfProducts OR Product2.Universal_Picture_Code__c IN: setOfProducts) ';
                             if (parentOrder.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) {
                                 queryString += 'AND (Product2.Product_Market__c = \'' +  CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE +'\'OR Product2.Product_Market__c = \''+ CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE+'\' )';
                             }
                            
        system.debug('queryString::::'+queryString);                     
		for(PricebookEntry pbe: Database.query(queryString))
        {
            
            if(setOfProducts.contains(pbe.Product2.ProductCode)){ 
              if(!mapProdIdProdNum.containskey(pbe.Product2Id)){
                    mapProdIdProdNum.put(pbe.Product2Id,pbe.Product2.ProductCode);
                }  
                if(!mapOfProdCodeProdId.containsKey(pbe.Product2.ProductCode)){
                    mapOfProdCodeProdId.put(pbe.Product2.ProductCode,new List<Id>{pbe.Product2Id});
                }else{
                    mapOfProdCodeProdId.get(pbe.Product2.ProductCode).add(pbe.Product2Id);
                }
                if(isDealPresent && !setOfProductCodeOfDp.contains(pbe.Product2.ProductCode)){
                    addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_MultiOrder_Proudct_Not_Available_In_Deal,mapOfProIndex.get(pbe.Product2.ProductCode));
                }else{
                    if(!pbe.Product2.isActive){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Product_Is_Not_Active,mapOfProIndex.get(pbe.Product2.ProductCode));
                   }
               		if(pbe.Product2.Type__c != CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE && 
					   pbe.Product2.Type__c != CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE && 
					   pbe.Product2.Type__c != CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE &&
					   pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE
					){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Product_Not_Physical,mapOfProIndex.get(pbe.Product2.ProductCode));
                  }
                    if(parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE && pbe.Product2.Product_Market__c != CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Rental_Product_For_Revenue_Share_Multi_Order,mapOfProIndex.get(pbe.Product2.ProductCode));
                  }
                  if (parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER || parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE) {
                      /*if(pbe.Product2.SAP_Dist_chain_product_Status__c != CRM_AppConstants.SAP_DIST_CHAIN_PRODUCT_ACTIVE_STATUS){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_SAP_Dist_chain_product_Status_Not_Active,mapOfProIndex.get(pbe.Product2.ProductCode));
                      }*/
                    	//US#788 UNBW Changes
                    	if(!sAPdistChainProductStatus.contains(pbe.Product2.SAP_Dist_chain_product_Status__c) && pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE ){
                        addValidations(VALIDATION_FOR_PRODUCT,System.Label.CRM_SAP_Dist_chain_product_Status_Not_Valid,mapOfProIndex.get(pbe.Product2.ProductCode));
                      }
                    	//US#788 UNBW Changes
                    	if (!plantSpecificMaterialStatus.contains(pbe.Product2.Plant_Specific_Material_Status__c) && pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE ) {
                         addValidations(VALIDATION_FOR_PRODUCT,System.Label.CRM_Plant_Specific_Material_Status_Not_Valid,mapOfProIndex.get(pbe.Product2.ProductCode));
                      }
                  } else if (parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN) {
                        //US#788 UNBW Changes
                        if(distChainProdStatusForReturns.contains(pbe.Product2.SAP_Dist_chain_product_Status__c) && pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE){
                            addValidations(VALIDATION_FOR_PRODUCT,String.format(System.Label.CRM_SAP_Dist_chain_product_Status_Not_Valid_For_Returns, new String[]{ sapDistChainAllowedValues }),mapOfProIndex.get(pbe.Product2.ProductCode));
                        }
                        // DEF#4219
                        if (
                                (
                                    parentOrder.Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE ||
                                    parentOrder.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                                ) &&
                                pbe.Product2.Return_End_Date__c != null && pbe.Product2.Return_End_Date__c < System.today()
                        ) {
                            addValidations(VALIDATION_FOR_PRODUCT, System.Label.CRM_Valid_Product_Return_End_Date, mapOfProIndex.get(pbe.Product2.ProductCode));
                        }
                    }
                }
            }
            if(setOfProducts.contains(pbe.Product2.Universal_Picture_Code__c)){
                if(!mapOfUpcEanProdId.containsKey(pbe.Product2.Universal_Picture_Code__c)){
                    mapOfUpcEanProdId.put(pbe.Product2.Universal_Picture_Code__c,new List<Id>{pbe.Product2Id});
                }else{
                    mapOfUpcEanProdId.get(pbe.Product2.Universal_Picture_Code__c).add(pbe.Product2Id);
                }
                if(isDealPresent && !setOfUPCEANNumOfDp.contains(pbe.Product2.Universal_Picture_Code__c)){
                    addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_MultiOrder_Proudct_Not_Available_In_Deal,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                }else{
                    if(!pbe.Product2.isActive){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Product_Is_Not_Active,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                  }
                	if(pbe.Product2.Type__c != CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE && 
					   pbe.Product2.Type__c != CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE && 
					   pbe.Product2.Type__c != CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE &&
					   pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE
					){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Product_Not_Physical,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                  }
                    if(parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE && pbe.Product2.Product_Market__c != CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_Rental_Product_For_Revenue_Share_Multi_Order,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                  }
                  if (parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER || parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE) {
                    /*if(pbe.Product2.SAP_Dist_chain_product_Status__c != CRM_AppConstants.SAP_DIST_CHAIN_PRODUCT_ACTIVE_STATUS){
                        addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_SAP_Dist_chain_product_Status_Not_Active,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                      }*/
                    	//US#788 UNBW Changes
                   		if(!sAPdistChainProductStatus.contains(pbe.Product2.SAP_Dist_chain_product_Status__c) && pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE){
                        addValidations(VALIDATION_FOR_PRODUCT,System.Label.CRM_SAP_Dist_chain_product_Status_Not_Valid,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                      }
                    	//US#788 UNBW Changes
                    	if(!plantSpecificMaterialStatus.contains(pbe.Product2.Plant_Specific_Material_Status__c) && pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE) {
                        addValidations(VALIDATION_FOR_PRODUCT,System.Label.CRM_Plant_Specific_Material_Status_Not_Valid,mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                      }
                  } else if (parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN) {
                        //US#788 UNBW Changes
                    	if(distChainProdStatusForReturns.contains(pbe.Product2.SAP_Dist_chain_product_Status__c) && pbe.Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE){
                            addValidations(VALIDATION_FOR_PRODUCT,String.format(System.Label.CRM_SAP_Dist_chain_product_Status_Not_Valid_For_Returns, new String[]{ sapDistChainAllowedValues }),mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                      }
                        // DEF#4219
                        if (
                                (
                                    parentOrder.Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE ||
                                    parentOrder.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE
                                ) &&
                                pbe.Product2.Return_End_Date__c != null && pbe.Product2.Return_End_Date__c < System.today()
                        ) {
                            addValidations(VALIDATION_FOR_PRODUCT, System.Label.CRM_Valid_Product_Return_End_Date, mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                        }
                    }
                }
                if(mapProdIdProdNum.containskey(pbe.Product2Id)){
                   addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_MultiOrder_Duplicate_Product_FoundWithUPC_Code + ' ' + mapProdIdProdNum.get(pbe.Product2Id),mapOfProIndex.get(pbe.Product2.Universal_Picture_Code__c));
                   addValidations(VALIDATION_FOR_PRODUCT,System.label.CRM_MultiOrder_Duplicate_Product_FoundWithUPC_Code + ' ' + pbe.Product2.Universal_Picture_Code__c,mapOfProIndex.get(mapProdIdProdNum.get(pbe.Product2Id)));
                   if(setOfProducts.contains(pbe.Product2.Universal_Picture_Code__c))
                       setOfProducts.remove(pbe.Product2.Universal_Picture_Code__c); 
                }
                
            }
        }
   }
   
   private static Map<id,Order> getMapOfAccountIdAndExistingOrders(Set<String> setOfAccountNumbers, Id parentOrderId ){
        Map<id,Order> mapAccountIdOrderLocal = new map<id,Order>();
        List<Order> lstExistingOrders= [SELECT id, EffectiveDate,Config__c,Pricebook2Id, Customer_PO_Number__c,
                                            CurrencyIsoCode, Ship_to_Account__r.Price_Book__c,Account.Sales_Organization__c, EndDate,RecordTypeId,
                                            Ship_To_Account__c,Ship_To_Account__r.AccountNumber
                                            FROM Order 
                                            WHERE Ship_To_Account__r.AccountNumber IN :setOfAccountNumbers
                                            AND Multi_Order__c =: parentOrderId]; 
        //Ankita changes required to change account id to ship to account id
        if(!lstExistingOrders.isEmpty()){
            for(Order existingOrder : lstExistingOrders){
                if(!mapAccountIdOrderLocal.containsKey(existingOrder.Ship_To_Account__c)){
                        mapAccountIdOrderLocal.put(existingOrder.Ship_To_Account__c,existingOrder);
                }
            }
        }
        return mapAccountIdOrderLocal;
   }
   
   private static Map<id,Order> createNewOrUpdateExistingOrders(Map<id,Order> mapAccountIdOrder){ 
        Map<id,Order> mapOfOrdersToInsertOrUpdate = new Map<id,Order>();
        Order orderRecord ;
        for(Account accountRecord: mapOfAccountsForOrders.values())  {
            mapOfOrdersToInsertOrUpdate.put(accountRecord.id, getOrder(mapAccountIdOrder, accountRecord,lstParentOrder[0]));
        }
        return mapOfOrdersToInsertOrUpdate;
   }
   
   //check if child orders exists then assign the same order.
   private static Order getOrder(Map<id,Order> mapAccountIdOrder, Account accountRecord,Order parentOrder)
   {
       Order orderRecord = new Order();
       if(mapAccountIdOrder.containsKey(accountRecord.id)) {
            ////system.debug('In If.............'+mapAccountIdOrder);
            orderRecord = mapAccountIdOrder.get(accountRecord.id); 
            orderRecord.Customer_PO_Number__c = mapOfAccNumCustNum.get(accountRecord.AccountNumber);   
       } else {  
            ////system.debug('In else.............'+mapAccountIdOrder);
            //Ankita: Swap the account and ship to account 
            orderRecord = new Order();
            orderRecord.AccountId = parentOrder.AccountId;
            if (parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN) {
                if(parentOrder.Reason__c != null)
                    orderRecord.Reason__c = parentOrder.Reason__c;
                orderRecord.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_RETURN;
            } else if(parentOrder.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_REVENUE_SHARE){
              orderRecord.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_REV_SHARE;
            } else {
                orderRecord.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_STANDARD;
            }
            orderRecord.EffectiveDate = parentOrder.EffectiveDate;
            orderRecord.Customer_PO_Number__c = mapOfAccNumCustNum.get(accountRecord.AccountNumber); 
            orderRecord.Ship_To_Account__c = accountRecord.id;
            orderRecord.Status = 'Open';
            orderRecord.Multi_Order__c = parentOrder.id;
            orderRecord.CurrencyIsoCode = parentOrder.CurrencyIsoCode;  
        }
        return orderRecord;
   }
   
   private static map<String,List<OrderWrapper>> getOrderWrapperMapofAccIdToOrderWrapper(List<String> lstOfUploadedOrders){
        /*Start: Create Wrapper for Order Products */
        map<String,List<OrderWrapper>> mapOfAccIdWrapper = new map<String,List<OrderWrapper>>();
        OrderWrapper orderWrapper;
       
        for(String indiUploadedRow : lstOfUploadedOrders) {
            ////system.debug('indiUploadedRow  : '+indiUploadedRow);
            List<String> lstOfIndiUploadedProCell = indiUploadedRow.split(',');
            ////system.debug('lstOfIndiUploadedProCell ===> ' + lstOfIndiUploadedProCell); 
            for(Integer j = 1,i = lstOfIndiUploadedProCell.size() ; j < i ; j++) {   
                ////system.debug('before lstOfIndiUploadedProCell['+j+'] ===> ' + lstOfIndiUploadedProCell[j]);
                lstOfIndiUploadedProCell[0]=lstOfIndiUploadedProCell[0].replace('[','');
                lstOfIndiUploadedProCell[0]= lstOfIndiUploadedProCell[0].trim().replace(']','');
                lstOfIndiUploadedProCell[j]=lstOfIndiUploadedProCell[j].replace('[','');
                lstOfIndiUploadedProCell[j]= lstOfIndiUploadedProCell[j].trim().replace(']','');
                //system.debug('After lstOfIndiUploadedProCell['+j+'] ===> ' + lstOfIndiUploadedProCell[j]);
                
                //create a wrapper 
                    
                if(mapOfIndexAcc.containsKey(j)) {
                    orderWrapper = new OrderWrapper(); 
                    orderWrapper.proRecord = String.valueOf(lstOfIndiUploadedProCell[0]).trim();
                    modefiedProCodeUPCNum.add(orderWrapper.proRecord);
                    orderWrapper.quantity   =  (lstOfIndiUploadedProCell[j].trim() != '' && lstOfIndiUploadedProCell[j].trim() != 'null') ? Decimal.valueOf(lstOfIndiUploadedProCell[j].trim()) : 0;
                    orderWrapper.accountNumber = mapOfIndexAcc.get(j);
                    if(!mapOfAccIdWrapper.containskey(mapOfIndexAcc.get(j))){
                        mapOfAccIdWrapper.put(mapOfIndexAcc.get(j),new List<OrderWrapper> {orderWrapper});
                    }else{
                        mapOfAccIdWrapper.get(mapOfIndexAcc.get(j)).add(orderWrapper);
                    }
                } 
                
            }//inner for 
            //system.debug('mapOfAccIdWrapper===>'+mapOfAccIdWrapper);
        }
        return mapOfAccIdWrapper;
   }
   
   private static List<Pricebook_Entry_Period__c> getPBEPEntriesForProducts(Order parentOrderRecord,List<Id> lstProductWithPBEEntry)
   {
        Date startDate = parentOrderRecord.EffectiveDate;
        Date endDate = parentOrderRecord.EndDate;    
        return ([SELECT Id, Product__c, List_Price__c, Product__r.Name, Product__r.Street_Date__c, Price_Book__c, 
                                                                    CurrencyISOCode, Start_Date__c, End_Date__c, Account_Price__c 
                                                                    FROM Pricebook_Entry_Period__c
                                                                    WHERE Price_Book__c IN:setPricebookIds
                                                                    AND CurrencyIsoCode != null 
                                                                    AND Start_Date__c <=: endDate
                                                                    AND End_Date__c >=: startDate
                                                                    AND Product__c IN: lstProductWithPBEEntry]); 
   }
   private static map<String,OrderItem>  getMapOfExistingOrderProducts(Order parentOrderRecord,Map<id,id> mapPbeIdProductId){
    map<String,OrderItem> mapOfKeyOrderItemExisting = new Map<String,OrderItem>();   
    List<OrderItem> existingOrderProducts = [SELECT ID,PricebookEntryId,PricebookEntry.Product2.Universal_Picture_Code__c,Quantity,
                                                        PricebookEntry.Product2.ProductCode,OrderId,Order.Pricebook2Id,Order.CurrencyIsoCode 
                                                        FROM OrderItem 
                                                        WHERE (PricebookEntry.Product2.Universal_Picture_Code__c IN :modefiedProCodeUPCNum OR PricebookEntry.Product2.ProductCode IN :modefiedProCodeUPCNum)
                                                        AND (Order.Multi_Order__C =: parentOrderRecord.Id OR OrderId =: parentOrderRecord.Id)]; 
      
       for(OrderItem orderItemRec :existingOrderProducts)
       {
           if(mapPbeIdProductId.containsKey(orderItemRec.PricebookEntryId))
           {
                String key = (orderItemRec.OrderId+'-'+mapPbeIdProductId.get(orderItemRec.PricebookEntryId)+'-'+orderItemRec.Order.Pricebook2Id+'-'+orderItemRec.Order.CurrencyIsoCode).toLowercase();
                if(!mapOfKeyOrderItemExisting.containsKey(key))
                {
                    mapOfKeyOrderItemExisting.put(key,orderItemRec);
                }
           }
       }
       
       return mapOfKeyOrderItemExisting;
   }
   
    public static List<String> createOrderProducts(CRM_InitialWrapperClass initialWrapInstance,map<String,List<OrderWrapper>> mapOfAccIdWrapper)
    {
        system.debug('Time : 513 : createOrderProducts : '+system.now());     
        map<id,PricebookEntry> mapIdPriceBookEntries = new map<id,PricebookEntry>(queryPricebookentries(lstParentOrder[0]));
        Map<String,Id> mapProdUniqueKeyPricebookIds = new Map<String,Id>();
        Map<id,id> mapPbeIdProductId =new Map<id,id>();
        Map<String,List<Pricebook_Entry_Period__c>> mapUniqueKeyToPBEPList = new Map<String,List<Pricebook_Entry_Period__c>>();  
        Set<String> setProdNumberOfSuccessOrderProd = new Set<String>();
        
        for(PricebookEntry pbe : mapIdPriceBookEntries.values()) {
            String key = (pbe.Product2Id + '-' + pbe.Pricebook2Id +'-'+ pbe.CurrencyIsoCode).toLowercase();
            if(!mapProdUniqueKeyPricebookIds.containsKey(key)){
                mapProdUniqueKeyPricebookIds.put(key,pbe.id);
            }
            if(!mapPbeIdProductId.containsKey(pbe.id)){
                mapPbeIdProductId.put(pbe.id,pbe.Product2Id);
            } 
        }
        
        List< Pricebook_Entry_Period__c> pbepListForProducts = getPBEPEntriesForProducts(lstParentOrder[0], mapPbeIdProductId.values());
        for (Pricebook_Entry_Period__c pbep : pbepListForProducts) {
            String key = (pbep.Product__c + '-' + pbep.Price_Book__c +'-'+ pbep.CurrencyIsoCode).toLowercase();
            if (!mapUniqueKeyToPBEPList.containsKey(key)) {
                mapUniqueKeyToPBEPList.put(key, new List<Pricebook_Entry_Period__c>{pbep});
            }else{
                mapUniqueKeyToPBEPList.get(key).add(pbep); 
            }
        }       
        List<OrderItem> zeroQuantityOrderProducts = new List<OrderItem>();
        Map<String,OrderItem> mapOfKeyOrderItemExisting = getMapOfExistingOrderProducts(lstParentOrder[0], mapPbeIdProductId);
        Map<Id,Decimal> mapOfOldProductQuantity = new Map<Id,Decimal> ();
        
        system.debug('Time : 519 : createOrderProducts : '+system.now());
        
        List<OrderItem> lstOrderLineToInsert =new List<OrderItem>();
        for(Order orderRec : mapOfAccNumToSucessOrder.values()){ 
            if(mapOfAccIdWrapper.containsKey(orderRec.Ship_To_Account__r.AccountNumber)){
                for(OrderWrapper orWrap: mapOfAccIdWrapper.get(orderRec.Ship_To_Account__r.AccountNumber)){
                    List<Id> productIdList =new List<Id>();
                    if(mapOfProdCodeProdId.containskey(orWrap.proRecord))
                    {
                        productIdList =  mapOfProdCodeProdId.get(orWrap.proRecord);  
                    }else  if(mapOfUpcEanProdId.containskey(orWrap.proRecord)){
                        productIdList =  mapOfUpcEanProdId.get(orWrap.proRecord);  
                    } 
                    if(!productIdList.isEmpty()){
                        
                        for(Id productId : productIdList){
                            String key= (productId + '-' + orderRec.Pricebook2Id +'-'+ orderRec.CurrencyIsoCode).toLowercase();
                        
                            if(mapUniqueKeyToPBEPList.containsKey(key) && mapProdUniqueKeyPricebookIds.containsKey(key))
                            {
                                setProdNumberOfSuccessOrderProd.add(orWrap.proRecord);
                                //Check if existing Order product exists
                                if(mapOfKeyOrderItemExisting.containsKey((orderRec.id+'-'+key).toLowercase()))
                                {
                                    OrderItem existingOrderItem = mapOfKeyOrderItemExisting.get((orderRec.id+'-'+key).toLowercase());
                                    //system.debug('Existing : '+existingOrderItem.Quantity+'-----'+orWrap.quantity);
                                    if(orWrap.quantity != 0){
                                        if(existingOrderItem.Quantity != orWrap.quantity){
                                            mapOfOldProductQuantity.put(existingOrderItem.Id,existingOrderItem.Quantity);
                                            existingOrderItem.Quantity = orWrap.quantity;
                                            lstOrderLineToInsert.add(existingOrderItem);
                                        }
                                    }else{
                                        //system.debug('existingOrderItem : '+existingOrderItem);
                                        zeroQuantityOrderProducts.add(existingOrderItem);
                                    }
                                }else{
                                    //system.debug('orWrap.quantity : '+orWrap.quantity);
                                    if(orWrap.quantity != 0){
                                        lstOrderLineToInsert.add(new OrderItem(
                                                                    OrderId = orderRec.id,
                                                                    PricebookEntryId = mapProdUniqueKeyPricebookIds.get(key),
                                                                    Quantity = orWrap.quantity 
                                                                    )); 
                                    }
                                } 
                            }else{
                             
                                String prodductKey = orWrap.proRecord;
                                 //system.debug('prodductKey :::::::::::'+prodductKey );
                                String accountKey = orderRec.Ship_To_Account__r.AccountNumber;
                                addValidationsForOrderProduct(System.label.CRM_MultiOrder_PriceBookEntryPeriod_Not_Found,prodductKey,accountKey );
                            }
                        } 
                    }
                }
            }
        }
        system.debug('Time : 568 : createOrderProducts : '+system.now());
        //Insert Child order products
        List<String> lstProdNumberOfSuccessOrderProd = new List<String>();
        Map<Id,Decimal> mapOfProdIdTotalQtyForParent = new Map<Id,Decimal> ();
        if(!lstOrderLineToInsert.isEmpty())
        {
            system.debug('Time : 576 : createOrderProducts : '+system.now());
            Database.UpsertResult[]  srList =  database.upsert(lstOrderLineToInsert,false);
            system.debug('Time : 578 : createOrderProducts : '+system.now());
            for (Integer i = 0; i < srList.size(); i++) {
                Database.UpsertResult saveResultInstance = srList[i];
                OrderItem orderItemInstance = lstOrderLineToInsert[i];
                if (saveResultInstance.isSuccess()) {
                    if(mapPbeIdProductId.containsKey(orderItemInstance.PricebookEntryId)) {  
                        Decimal diffOfQuantity = mapOfOldProductQuantity.containsKey(orderItemInstance.Id) ? (orderItemInstance.Quantity - mapOfOldProductQuantity.get(orderItemInstance.Id)) : orderItemInstance.Quantity;
                        //system.debug('orderItemInstance :: '+orderItemInstance.Id+'----'+diffOfQuantity);
                        if(!mapOfProdIdTotalQtyForParent.containsKey(mapPbeIdProductId.get(orderItemInstance.PricebookEntryId))){
                            mapOfProdIdTotalQtyForParent.put(mapPbeIdProductId.get(orderItemInstance.PricebookEntryId),diffOfQuantity);
                        }else {
                            Decimal qtyProduct = mapOfProdIdTotalQtyForParent.get(mapPbeIdProductId.get(orderItemInstance.PricebookEntryId)); 
                            mapOfProdIdTotalQtyForParent.put(mapPbeIdProductId.get(orderItemInstance.PricebookEntryId),(qtyProduct+diffOfQuantity));
                        }
                    }
                }else{
                    String productCode = mapIdPriceBookEntries.get(orderItemInstance.PricebookEntryId).Product2.ProductCode;
                    String upcCode = mapIdPriceBookEntries.get(orderItemInstance.PricebookEntryId).Product2.Universal_Picture_Code__c;
                    String productKey = '';
                    if(mapOfProdCodeProdId.containskey(productCode)){
                        productKey =  productCode;  
                    }else  if(mapOfUpcEanProdId.containskey(upcCode)){
                        productKey =  upcCode;  
                    }
                    for(Database.Error err : saveResultInstance.getErrors()) {
                        addValidationsForOrderProduct(err.getMessage(),productKey,mapOfOrderIdToAccountNumber.get(orderItemInstance.OrderId));
                    }
                }
            }
         }//end if
         system.debug('Time : 616 : createOrderProducts : '+system.now()); 
         if(!zeroQuantityOrderProducts.isEmpty()){
            delete zeroQuantityOrderProducts;
         }      
         insertParentOrderProducts(mapOfProdIdTotalQtyForParent,mapOfKeyOrderItemExisting,lstParentOrder[0],mapProdUniqueKeyPricebookIds);
         system.debug('Time : 620 : createOrderProducts : '+system.now());  
         lstProdNumberOfSuccessOrderProd.addall(setProdNumberOfSuccessOrderProd); 
         system.debug('Time : 622 : createOrderProducts : '+system.now());  
         return lstProdNumberOfSuccessOrderProd;
    }
    
    private static void insertParentOrderProducts(Map<Id,Decimal> mapOfProdIdTotalQtyForParent, map<String,OrderItem>  mapOfKeyOrderItemExisting,Order parentOrderRecord,Map<String,Id>mapProdUniqueKeyPricebookIds)
    {
        List<OrderItem> lstParentOrderLineToInsert =new List<OrderItem>();
        if(!mapOfProdIdTotalQtyForParent.isEmpty()) {   
            for(Id productId :mapOfProdIdTotalQtyForParent.keySet()){
                String key= (productId + '-' + parentOrderRecord.Pricebook2Id +'-'+ parentOrderRecord.CurrencyIsoCode).toLowercase();
                 ////system.debug('In parent insert::key::'+key);
                if(mapProdUniqueKeyPricebookIds.containsKey(key)) {
                    if(mapOfKeyOrderItemExisting.containsKey((parentOrderRecord.Id+'-'+key).toLowercase())) {
                       
                         OrderItem existingOrderItem = mapOfKeyOrderItemExisting.get((parentOrderRecord.id+'-'+key).toLowercase());
                               existingOrderItem.Quantity += mapOfProdIdTotalQtyForParent.get(productId) == null ? 0 : mapOfProdIdTotalQtyForParent.get(productId);
                               lstParentOrderLineToInsert.add(existingOrderItem); 
                    }else {
                        lstParentOrderLineToInsert.add(new OrderItem(
                                                            OrderId = parentOrderRecord.id,
                                                            PricebookEntryId = mapProdUniqueKeyPricebookIds.get(key),
                                                            Quantity = mapOfProdIdTotalQtyForParent.get(productId) == null?0:mapOfProdIdTotalQtyForParent.get(productId)
                                                            ));  
                    }
                } 
            }
        }
        /*End: Create map for Parent Order Product  creation*/
        /*Start: Insert Parent Order Product */
        if(!lstParentOrderLineToInsert.isEmpty()) {
          Database.UpsertResult[]  srList =Database.upsert(lstParentOrderLineToInsert,false); 
          for (Integer i = 0; i < srList.size(); i++) {
               Database.UpsertResult saveResultInstance = srList[i];
                if (!saveResultInstance.isSuccess()) {
                     for(Database.Error err : saveResultInstance.getErrors()) {
                         throw new CRM_MultiUploadExtractOrderControllerException(err.getMessage());
                     }
                }
            } 
        } 
    }
    
    
    /*get pricebook entries*/
    private static List<PricebookEntry> queryPricebookentries(Order parentOrderRecord) {
        
       String queryString = 'SELECT Id, Product2.Id, CurrencyIsoCode, Product2.Name, Product2.Street_Date__c, Product2.Product_Genre__c,'+
                            ' Product2.Local_Title__r.CountryCodeForImage__c,'+
                            ' Product2.Local_Title__r.LanguageCodeForImage__c,'+
                            ' Product2.recordtypeId,Product2.Local_Title__r.Title_VV_F__c, UnitPrice, Product2.Recommended_Price__c, Product2.ProductCode,'+
                            ' Product2.Type__c, Product2.Items_in_Stock__c, Product2.Franchise_Type__c,'+
                            ' Product2.Delivery_Lead_Days__c, Product2.Cut_Off_Period_Weeks__c, '+
                            ' Product2.External_Id__c, Product2.Universal_Picture_Code__c, Product2.SAP_Sales_Org__c, Product2.SAP_Distribution_Id__c,'+
                            ' Product2.SAP_Dist_chain_product_Status__c,Product2.Plant_Specific_Material_Status__c,'+
                            ' Pricebook2.CurrencyISOCode, Product2.Product_Format__c'+
                            ' FROM PricebookEntry'+
                            ' WHERE Pricebook2Id IN:setPricebookIds'+
                            ' AND IsActive = true AND Product2.IsActive = true'+
                            ' AND ( Product2.Type__c = \'' +CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE +'\' OR'+
                            ' Product2.Type__c= \'' + CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE+'\' OR'+
                            ' Product2.Type__c= \'' +CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE +'\' OR'+
                            ' (Product2.Type__c = \'' +CRM_AppConstants.UNBW_PRODUCT_TYPE+ '\' AND Product2.SAP_Sales_Org__c =\''+CRM_AppConstants.TERRITORY_ITALY_CODE+'\'))'+
                            ' AND Product2.SAP_Material_Type__c != \'SBOM\''+
                            ' AND Product2.recordtypeId = \'' + CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL+'\''+
                            ' AND (Product2.ProductCode IN: modefiedProCodeUPCNum OR Product2.Universal_Picture_Code__c IN: modefiedProCodeUPCNum)'+
                            ' AND CurrencyIsoCode = \'' +parentOrderRecord.CurrencyIsoCode+'\'';
        					
                             if (parentOrderRecord.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE) {
                                queryString +=  ' AND (Product2.Product_Market__c = \'' +  CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE + '\'' +
                                                ' OR Product2.Product_Market__c = \''+ CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE +'\')';
                                 
                             }
                            
           system.debug('pbep queryString********************'+queryString);    
       return (Database.query(queryString));
    }
    
    @RemoteAction
    public static  MultiOrderWrapper  getOrdersAndOrderLineItems(Id orderId){
        List<Order> lstParentOrderRecord =[SELECT Order_Account_Sequence__c,Order_Product_Sequence__c,Count_of_Order_Product__c
                                           FROM Order 
                                           WHERE id = :orderId];
        List<Order> lstChildOrders = [Select Ship_To_Account__r.AccountNumber,Order.Customer_PO_Number__c From Order Where Multi_Order__c = :orderId];
        MultiOrderWrapper lineItemWrapper = new MultiOrderWrapper(); 
        if(!lstChildOrders.isEmpty()){
            if(!lstParentOrderRecord.isEmpty()){
                if(lstParentOrderRecord[0].Order_Account_Sequence__c !=null){
                    lineItemWrapper.setAccNumber.addall(lstParentOrderRecord[0].Order_Account_Sequence__c.split(','));
                }
                if(lstParentOrderRecord[0].Order_Product_Sequence__c !=null){
                    lineItemWrapper.setProdForOrders.addall(lstParentOrderRecord[0].Order_Product_Sequence__c.split(','));
                }
            }
            for(Order orderObj : lstChildOrders){
                lineItemWrapper.maoOfAccNumToCusPONum.put(orderObj.Ship_To_Account__r.AccountNumber,orderObj.Customer_PO_Number__c);
            }
            
            List<OrderItem> childOrderProducts = [SELECT Order.Customer_PO_Number__c,Order.Ship_To_Account__r.AccountNumber,PricebookEntry.Product2Id,PricebookEntry.Product2.Universal_Picture_Code__c,PricebookEntry.Product2.ProductCode,Quantity FROM OrderItem Where Order.Multi_Order__c = :orderId];
            for(OrderItem lineItem : childOrderProducts ){ 
                Decimal orderProductQuantity = lineItem.Quantity;
                if( lineItemWrapper.setProdForOrders.contains(lineItem.PricebookEntry.Product2.Universal_Picture_Code__c))
                {
                    if(!lineItemWrapper.mapOfProdToMapOfAccQty.containsKey(lineItem.PricebookEntry.Product2.Universal_Picture_Code__c)){   
                        map<String,Decimal>  mapOfAccIdQty = new map<String,Decimal>(); 
                        mapOfAccIdQty.put(lineItem.Order.Ship_To_Account__r.AccountNumber,orderProductQuantity);
                        lineItemWrapper.mapOfProdToMapOfAccQty.put(lineItem.PricebookEntry.Product2.Universal_Picture_Code__c,mapOfAccIdQty);
                    }else{
                        map<String,Decimal> temp = lineItemWrapper.mapOfProdToMapOfAccQty.get(lineItem.PricebookEntry.Product2.Universal_Picture_Code__c);
                        temp.put(lineItem.Order.Ship_To_Account__r.AccountNumber,orderProductQuantity);
                        lineItemWrapper.mapOfProdToMapOfAccQty.put(lineItem.PricebookEntry.Product2.Universal_Picture_Code__c,temp);
                    }
                }else{
                    if(!lineItemWrapper.mapOfProdToMapOfAccQty.containsKey(lineItem.PricebookEntry.Product2.ProductCode)){   
                        map<String,Decimal>  mapOfAccIdQty = new map<String,Decimal>(); 
                        mapOfAccIdQty.put(lineItem.Order.Ship_To_Account__r.AccountNumber,orderProductQuantity);
                        lineItemWrapper.mapOfProdToMapOfAccQty.put(lineItem.PricebookEntry.Product2.ProductCode,mapOfAccIdQty);
                    }else{
                        map<String,Decimal> temp = lineItemWrapper.mapOfProdToMapOfAccQty.get(lineItem.PricebookEntry.Product2.ProductCode);
                        temp.put(lineItem.Order.Ship_To_Account__r.AccountNumber,orderProductQuantity);
                        lineItemWrapper.mapOfProdToMapOfAccQty.put(lineItem.PricebookEntry.Product2.ProductCode,temp);
                    } 
                }
            }
        }else{
            boolean updateFlag = false;
            if(lstParentOrderRecord[0].Order_Account_Sequence__c != null && lstParentOrderRecord[0].Order_Account_Sequence__c != ''){
                updateFlag = true;
                lstParentOrderRecord[0].Order_Account_Sequence__c = '';
            }
            if(lstParentOrderRecord[0].Order_Product_Sequence__c != null && lstParentOrderRecord[0].Order_Product_Sequence__c != ''){
                updateFlag = true;
                lstParentOrderRecord[0].Order_Product_Sequence__c = '';
            }
            if(updateFlag)
                update lstParentOrderRecord;
        }
        ////system.debug('lineItemWrapper::::::::'+lineItemWrapper); 
        return lineItemWrapper ;
    }
    
    @RemoteAction
    public static Set<String> removeOrderProducts(String productString,String parentMultiOrderId){
        Set<String> sucessFullyDeletedProduct = new Set<String>();
        Set<String> setOfProductCodeOrUPCCode = new Set<String>(productString.split(','));
        if(parentMultiOrderId != null && !setOfProductCodeOrUPCCode.isEmpty()){
           List<OrderItem> lstDeleteOrderItems = [Select Id,PricebookEntry.Product2.ProductCode,PricebookEntry.Product2.Universal_Picture_Code__c From orderItem
                                                  Where (Order.Multi_Order__c =: parentMultiOrderId OR OrderId =: parentMultiOrderId)
                                                  AND (PricebookEntry.Product2.ProductCode IN: setOfProductCodeOrUPCCode OR PricebookEntry.Product2.Universal_Picture_Code__c IN: setOfProductCodeOrUPCCode)];
           
           if(lstDeleteOrderItems.size() > 0){
               Database.DeleteResult[]  deleteList = Database.delete(lstDeleteOrderItems,false); 
               for (Integer i = 0; i < deleteList.size(); i++) {
                    OrderItem orderItemInstance = lstDeleteOrderItems[i];
                    Database.DeleteResult deleteResultInstance = deleteList[i];
                    if (!deleteResultInstance.isSuccess()) {
                         for(Database.Error err : deleteResultInstance.getErrors()) {
                             throw new CRM_MultiUploadExtractOrderControllerException(err.getMessage());
                         }
                    }
               } 
           }
           if(setOfProductCodeOrUPCCode.size() > 0)
               updateParentOrderProductSequence(setOfProductCodeOrUPCCode,parentMultiOrderId);
        }
        return setOfProductCodeOrUPCCode;
    }
    
    private static void updateParentOrderProductSequence(Set<String> setOfProductCodeOrUPCCode,String parentMultiOrderId){
        List<Order> multiOrder = new List<Order>();
        multiOrder=[select Id,Order_Product_Sequence__c From Order Where Id =: parentMultiOrderId Limit 1];
        if(!multiOrder.isEmpty() && multiOrder[0].Order_Product_Sequence__c != null){
            Set<String> productSequence =  new Set<String>(multiOrder[0].Order_Product_Sequence__c.split(','));
            for(String prodSeq : setOfProductCodeOrUPCCode){
                if(productSequence.contains(prodSeq))
                    productSequence.remove(prodSeq);
            }
            
            String productSequenceString = '';
            if(!productSequence.isEmpty()){
                List<String> tempLst = new List<String>(productSequence);
                productSequenceString = String.join(tempLst,',');
            }
            multiOrder[0].Order_Product_Sequence__c = productSequenceString;
            update multiOrder;
        }
    }
    
    global Integer getChunkSizeForSaveOrders() {
        return CRM_Multiorder_ChunkSizes__c.getInstance('Save_Orders') != null ? Integer.valueOf(CRM_Multiorder_ChunkSizes__c.getInstance('Save_Orders').Total_Products_For_One_Chunk__c) : 1600;
    }
    
    global Integer getChunkSizeForRemoveRow() {
        return CRM_Multiorder_ChunkSizes__c.getInstance('Remove_Row') != null ? Integer.valueOf(CRM_Multiorder_ChunkSizes__c.getInstance('Remove_Row').Total_Products_For_One_Chunk__c) : 4000;
    }
     
    public String getResourceURL() {
        String currentUserLocale = UserInfo.getLocale();
        String resourceName = CRM_MultiOrder_Templates__c.getInstance(currentUserLocale) != null ? CRM_MultiOrder_Templates__c.getInstance(currentUserLocale).Template_API_Name__c : 'CRM_MultiOrder_Template_EN';
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                             FROM StaticResource 
                                             WHERE Name = :resourceName LIMIT 1];
                        
        if(!resourceList.isEmpty()) {
           String namespace = resourceList[0].NamespacePrefix;
           return '/resource/' 
              + resourceList[0].SystemModStamp.getTime() + '/' 
              + (namespace != null && namespace != '' ? namespace + '__' : '') 
              + resourceName; 
        } else return '';
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

    global class OrderWrapper{
        public String proRecord;
        public String accountNumber;
        public Decimal quantity;
        public OrderWrapper(){}
    }
    
    global class MultiOrderWrapper{
        public Set<String> setAccNumber;
        public Set<String> setProdForOrders;
        //public Set<String> setCustPoNumForOrders;
        public Map<String,Map<String,Decimal>> mapOfProdToMapOfAccQty;
        public map<String,String> maoOfAccNumToCusPONum;
        public MultiOrderWrapper()
        {
            maoOfAccNumToCusPONum = new Map<String,String>();
            setAccNumber=new Set<String>();
            setProdForOrders=new Set<String>();
            //setCustPoNumForOrders=new Set<String>();
            mapOfProdToMapOfAccQty=new Map<String,Map<String,Decimal>>();
        }
    }
    
    public class CRM_MultiUploadExtractOrderControllerException extends Exception {}  
    
    global class CRM_InitialWrapperClass{
        public boolean validationflag = false;
        public List<Id> setPricebookIdsWrap = new List<Id>();
        public map<string,List<Id>> mapOfProdCodeProdIdWrap = new map<string,List<Id>>();
        public map<string,List<id>> mapOfUpcEanProdIdWrap = new map<string,List<id>>();
        public map<String,Order> mapOfAccNumToSucessOrderWrap = new map<String,Order>();
        public map<Id,String> mapOfOrderIdToAccountNumberWrap = new map<Id,String>();
        public map<String,String> mapOfProIndexWrap = new map<String,String>();
        public map<integer,String> mapOfIndexAccWrap = new map<integer,String>();
        public map<String,List<String>> mapOfProAccValidatinosWrap = new map<String,List<String>>();
        public Map<String,String> mapOfAccIndexWrap = new Map<String,String>();
        public String errorMsgForEmptyFirstRowColAndSecondRow = '';
        public String errorMsgRelatedDp = '';
        public CRM_InitialWrapperClass(){}
    }
}