/**
   @Author Cognizant
   @name CRM_MultiUploadOrderController_Test
   @CreateDate 02 Nov 2016
   @Description Test class for CRM_MultiUploadExtractOrderController  
   @Version <1.0>
   @reference Requirement no 476
  */

@isTest 
public class CRM_MultiUploadOrderController_Test{ 
    public static String accountString ='';
    public static String custPOString ='';
    public static String productString ='';
    public static List<String> lstOfUploadedOrders = new List<String>();
    public static List<Order> lstParentOrders =new  List<Order>();
    public static List<Account> lstParentAccount =  new List<account>(); 
    public static List<Account> lstShipToAccount = new List<account>();
    public static List<Product2> products = new List<Product2>();
    public static List<String> indiListOfProdUPC  = new List<String>();
    public static List<String> indiListOfProd  = new List<String>();
    public static List<Pricebook_Entry_Period__c> pbeList = new List<Pricebook_Entry_Period__c>();
    public static List<PricebookEntry> pbEntries = new List<PricebookEntry>();
    public static List<Product_Group__c> pgs = new List<Product_Group__c>();
    public static List<Local_Title__c> ltList = new List<Local_Title__c>();
    
     
    public @testSetup static void prepareTestDataForBulkUpload(){
            
            //Create local data for product creation 
            List<Country__c> countryList = new List<Country__c>();
            Country__c japan = TestUtil.createCountry('Japan', 'JPY', 'JPY');
            countryList.add(japan);
            insert countryList;
            system.assertEquals(1,countryList.size()); 
            
            List<Title__c> titleList = new List<Title__c>();
            titleList.add(TestUtil.createTitle('M Title', '123456'));
            titleList[0].Digital_Planning__c = 'Yes';
            titleList[0].Formats__c = 'HD';
            titleList[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
            insert titleList[0];
            system.assertEquals(1,titleList.size()); 
            
            List<Language__c> lList = new List<Language__c>();
            Language__c japanLang = TestUtil.createLanguage('Japanese', 'JPY',1);
            lList.add(japanLang);
            insert lList;  
            system.assertEquals(1,lList.size());
           
            Local_Title__c LT = new Local_Title__c();
            system.debug( ' countryList[0]:::' + countryList +'lList[0]::'+lList[0]+'titleList[0]:::'+titleList[0].id);
            LT = TestUtil.createLocalData('20001', countryList[0], lList[0], 'JPY', titleList[0].Id); 
            ltList.add(LT); 
            insert ltList;
            system.assertEquals(1,ltList.size()); 
         
            // Create Product Group and Products with UPC Code and Product Code
            pgs = CRM_TestDataFactory.createProductGroups(1, true);
            system.assertEquals(1,pgs.size());
           
    }
    
    public static void createDataForMultiOrderWithoutPBEP(){
        Id multiOrderRecordTypeId = CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER;
        Id shipToRecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
        Id soldToRecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO; 
        //Create Parent Account
        lstParentAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstParentAccount[0].recordTypeId = soldToRecordTypeId;
        lstParentAccount[0].CurrencyIsoCode = 'JPY';  
        lstParentAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstParentAccount;
        system.assertEquals(1,lstParentAccount.size());
        system.debug('lstParentAccount::'+lstParentAccount);    
        
        //Create Ship To Child Accounts 
        lstShipToAccount = CRM_TestDataFactory.createAccounts(10, false);
        for(Integer i = 0; i < lstShipToAccount.size(); i++) {
            lstShipToAccount[i].recordTypeId = shipToRecordTypeId;
            lstShipToAccount[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            lstShipToAccount[i].Sold_to_customer__c= lstParentAccount[0].id;
            lstShipToAccount[i].AccountNumber = 'TestAccount'+i;
            if(accountString == '') {
                accountString='TestAccount'+i;
            }else {
                accountString+=',TestAccount'+i; 
            }
            if(custPOString == '') {
                custPOString ='Cust PO'+i;
            }else {
                custPOString+=',Cust PO'+i;
            }
        }
        insert lstShipToAccount;
        system.assertEquals(10,lstShipToAccount.size()); 
        
        //Create Parent Order
        lstParentOrders = CRM_TestDataFactory.createOrders(lstParentAccount, 1, false);
        lstParentOrders[0].CurrencyIsoCode = 'JPY';  
        lstParentOrders[0].Customer_PO_Number__c = '6564658757'; 
        lstParentOrders[0].recordTypeId =multiOrderRecordTypeId;
        insert lstParentOrders;
        system.assertEquals(1,lstParentOrders.size()); 
        system.debug('lstParentOrders:::::::::::'+lstParentOrders[0]); 
        
        pgs =[SELECT ID FROM Product_Group__c Limit 1];
        products = CRM_TestDataFactory.createProducts(pgs,10,false); 
        ltList =[SELECT ID FROM Local_Title__c limit 1];
        
        for(Integer i = 0; i < products.size(); i++) { 
            products[i].Universal_Picture_Code__c = 'Test_ProdUPC'+i;
            products[i].ProductCode = 'Test_ProdCode'+i;
            products[i].Product_Market__c=CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            products[i].recordtypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            products[i].Type__c = 'Games Physical';
            products[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            products[i].Plant_Specific_Material_Status__c = '04';
            if(productString=='') {
                productString='Test_ProdUPC'+i; 
            }else {
                productString+=','+'Test_ProdUPC'+i; 
            }  
            indiListOfProd.add('Test_ProdCode'+i); 
            indiListOfProdUPC.add('Test_ProdUPC'+i);
            products[i].Local_Title__c = ltList[0].ID;
        }
        insert products; 
        system.assertEquals(10,products.size()); 
        
        lstOfUploadedOrders =new List<String>();
        for(String prod:indiListOfProdUPC){
            String prodQty =  prod;
            for(Integer i = 1; i <= 10; i++) {
                prodQty+=','+i  ; 
            }
            lstOfUploadedOrders.add('['+prodQty+']'); 
        }
        system.debug('lstOfUploadedOrders::'+lstOfUploadedOrders);
        system.debug('productString:::'+productString);   
    }
    
    static void createDataForMultiOrderWithPbep(){
        createDataForMultiOrderWithoutPBEP(); 
        pbEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, false);
        for(PricebookEntry pbRec :pbEntries) {
            pbRec.CurrencyISOCode ='JPY';
        }
        insert pbEntries;
        system.assertEquals(10,pbEntries.size());
            
        pbeList=CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
        for(Pricebook_Entry_Period__c pbeRec :pbeList) {
            pbeRec.CurrencyISOCode ='JPY';
        }
        insert pbeList;
        system.assertEquals(10,pbeList.size());  
    }
    
    static void createProductQtyDataForGrid()
    {
       for(Integer i = 0 ; i < 10 ; i++) {
            if(productString=='') {
                productString='Test_ProdCode'+i; 
            }else {
                productString+=','+'Test_ProdCode'+i; 
            }
        }
        
        lstOfUploadedOrders =new List<String>();
        for(String prod:indiListOfProd){
            String prodQty =  prod;
            for(Integer i = 1; i <= 10; i++) {
                prodQty+=','+i  ; 
            }
            lstOfUploadedOrders.add('['+prodQty+']'); 
        }  
    }
    
    static List<Order> getOrders(){
        List<Order> lstOrders = CRM_TestDataFactory.createOrders(lstShipToAccount, 1, false);
        Integer index=0;
        for(Order ordRec : lstOrders) {
            if(index < 10){
                ordRec.CurrencyIsoCode='JPY'; 
                ordRec.Multi_order__c=lstParentOrders[0].id; 
                ordRec.Customer_PO_Number__c = 'Cust PO'+index; 
                ordRec.Ship_To_Account__c = lstShipToAccount[index].id;
                ordRec.AccountId=lstParentOrders[0].AccountId;
                ordRec.RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_STANDARD;
                index++;
            }
        }
        insert lstOrders; 
        system.assertEquals(10, lstOrders.size());
        return lstOrders;
    }
    //************************************************Test Methods****************************************************************************************
    
    static testMethod void testCRM_MultiUploadWithProdUpcEan() {
       createDataForMultiOrderWithPbep(); 
       Test.startTest();
        PageReference pageRef = Page.CRM_MultiUploadExtractOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',lstParentOrders[0].id);
        ApexPages.standardController controller = new ApexPages.standardController(lstParentOrders[0]);
        CRM_MultiUploadExtractOrderController mctrler = new  CRM_MultiUploadExtractOrderController(controller);
        Order parentOrder =[SELECT ID FROM Order WHERE recordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER LIMIT 1]; 
        CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
        map<String,List<String>> validationmap = CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(parentOrder.Id),false);
        system.debug('testCRM_MultiUploadWithProdUpcEan validationmap::'+validationmap);
        system.assertEquals(0, validationmap.size()); 
        mctrler.getChunkSizeForSaveOrders();
        mctrler.getChunkSizeForRemoveRow();
       Test.stopTest();  
    }   
    
    static testMethod void testCRM_MultiUploadWithProductCodes() {
        createDataForMultiOrderWithPbep(); 
        productString='';
        createProductQtyDataForGrid();  
        Test.startTest();
            CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = new  CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass();
            initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
            system.debug('testCRM_MultiUploadWithProductCodes::::'+initialWrapInstance);
            map<String,List<String>> validationmap =  CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].id),false);
            system.debug('testCRM_MultiUploadWithProductCodes:::validationmap:'+validationmap);
            system.assertEquals(0, validationmap.size());
         Test.stopTest(); 
    }
    
    static testMethod void testCRM_MultiUploadWithProdUpcEanWithZeroQty() { 
       createDataForMultiOrderWithPbep(); 
       List<Order> lstOrders = getOrders();
       system.assertEquals(10, lstOrders.size());
       Test.startTest();
        CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
        system.debug('testCRM_MultiUploadWithProdUpcEanWithoutPBEP::::'+initialWrapInstance);
        map<String,List<String>> validationmap = CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].id),false);
        system.debug('testCRM_MultiUploadWithProdUpcEanWithoutPBEP validationmap::'+validationmap);
        system.assertEquals(0, validationmap.size());
        CRM_MultiUploadExtractOrderController.getOrdersAndOrderLineItems(lstParentOrders[0].id);
        
        //100 Child Order Products + 10 Multi Order Products 
        system.assertEquals(110,[Select count() From OrderItem]);
       Test.stopTest(); 
    }
    
     static testMethod void testCRM_MultiUploadGetOrdersAndOrderLineItemsProCode() { 
       createDataForMultiOrderWithPbep(); 
       productString='';
       for(Integer i = 0 ; i < 10 ; i++) {
            if(productString=='') {
                productString='Test_ProdCode'+i; 
            }else {
                productString+=','+'Test_ProdCode'+i; 
            }
        }
       
       List<Order> lstOrders = getOrders();
       system.assertEquals(10, lstOrders.size());  
         
       List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(pbEntries, lstOrders, 2, true);
       system.assertEquals(10, lstOrderProduct.size());   
       system.assertEquals(1,lstParentOrders.size());
       lstParentOrders[0].Order_Product_Sequence__c=productString;   
       lstParentOrders[0].Order_Account_Sequence__c=accountString;
       update lstParentOrders[0];
       Test.startTest();
        CRM_MultiUploadExtractOrderController.MultiOrderWrapper wrapper = CRM_MultiUploadExtractOrderController.getOrdersAndOrderLineItems(lstParentOrders[0].id);
        system.debug('testCRM_MultiUploadWithProdUpcEan wrapper::::'+wrapper.setAccNumber.size()+'---'+wrapper.setProdForOrders.size());
        system.assertEquals(10, wrapper.setAccNumber.size());
        system.assertEquals(10, wrapper.setProdForOrders.size());
        system.assertEquals(10, wrapper.maoOfAccNumToCusPONum.size());
        system.assertEquals(10, wrapper.mapOfProdToMapOfAccQty.size()); 
       Test.stopTest(); 
    }
    static testMethod void testCRM_MultiUploadGetOrdersAndOrderLineItemForUPC() { 
       createDataForMultiOrderWithPbep();  
       
       List<Order> lstOrders = getOrders();
       system.assertEquals(10, lstOrders.size());  
         
       List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(pbEntries, lstOrders, 2, true);
       system.assertEquals(10, lstOrderProduct.size());   
       system.assertEquals(1,lstParentOrders.size());
       lstParentOrders[0].Order_Product_Sequence__c=productString;   
       lstParentOrders[0].Order_Account_Sequence__c=accountString;
       update lstParentOrders[0];
       Test.startTest();
        CRM_MultiUploadExtractOrderController.MultiOrderWrapper wrapper = CRM_MultiUploadExtractOrderController.getOrdersAndOrderLineItems(lstParentOrders[0].id);
        system.debug('testCRM_MultiUploadWithProdUpcEan wrapper::::'+wrapper.setAccNumber.size()+'---'+wrapper.mapOfProdToMapOfAccQty.size());
        system.assertEquals(10, wrapper.setAccNumber.size());
        system.assertEquals(10, wrapper.setProdForOrders.size());
        system.assertEquals(10, wrapper.maoOfAccNumToCusPONum.size());
        system.assertEquals(10, wrapper.mapOfProdToMapOfAccQty.size()); 
       Test.stopTest(); 
    }
    
    static testMethod void testCRM_MultiUploadWithProdUpcEanWithoutPBEP() {
        createDataForMultiOrderWithoutPBEP(); 
        accountString = 'TestAccount0';
        productString = 'Test_ProdUPC0';
        custPOString = 'Cust PO0';
        lstOfUploadedOrders = new List<String>();
        lstOfUploadedOrders.add('['+productString+',0]');
        
        Test.startTest();
            CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
            system.debug('testCRM_MultiUploadWithProdUpcEanWithoutPBEP::::'+initialWrapInstance);
            map<String,List<String>> validationmap = CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].id),false);
            system.debug('testCRM_MultiUploadWithProdUpcEanWithoutPBEP validationmap::'+validationmap);
            if(!validationmap.isEmpty()) {
                System.AssertEquals(1,validationmap.size());
                System.AssertEquals(validationmap.get('2-0'),new List<String>{'Product or valid PriceBookEntry in product does not exist.'}); 
            }  
        CRM_MultiUploadExtractOrderController.getOrdersAndOrderLineItems(lstParentOrders[0].id);
       Test.stopTest(); 
    }
    
    static testMethod void testCRM_MultiUploadValidations() {
        createDataForMultiOrderWithPbep(); 
        List<Order> lstOrders = getOrders();
        system.assertEquals(10, lstOrders.size());
        /********************************Account Validations*********************************************************/ 
        //Validate duplicate account
        accountString+=',TestAccount1'; 
        custPOString+=',CusPoForDuplicateAcc'; 
        //Validate invalid account
        accountString+=',AccNotExist';  
        custPOString+=',CusPoForAccNotExist'; 
        //Validate if Account is not Physical
        lstShipToAccount[3].Games_Physical__c=false;
        lstShipToAccount[3].Video_Physical__c=false; 
        lstShipToAccount[3].Music_Physical__c=false;
       /********************************Product Validations*********************************************************/ 
        //Validate product when is IsActive =false
        products[2].IsActive = false;
        //product not of physical type
        products[4].Type__c = 'Video Digital';
        //product not of Active type for SAP Dist Channel 
        products[5].SAP_Dist_chain_product_Status__c = '40';
        //Product Plant Specific Material Status is not valida (It should be 04=Active , 02=Released for 3rd Party & 05=Sell-down/Sell-Off)
        products[6].Plant_Specific_Material_Status__c = '03';
        //Validate duplicate product
        productString+=',Test_ProdUPC1'; 
        //Validate invalid product
        productString+=',ProdNotExist';
        //Validate duplicate Product code
        productString+=',Test_ProdCode1';  
        productString=productString.trim(); 
        accountString=accountString.trim();
        List<Product2> lstOfProductToUpdate = new List<Product2>{products[2],products[4],products[5],products[6]};
        update lstOfProductToUpdate; 
        update lstShipToAccount[3];
         
        Test.startTest();  
            CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = new  CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass();
            initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
            map<String,List<String>> validationmap = initialWrapInstance.mapOfProAccValidatinosWrap;
            system.debug('testCRM_MultiUploadValidations validationmap::::::'+validationmap);
            System.AssertEquals(12,validationmap.size());
            if(!validationmap.isEmpty()) { 
                System.AssertEquals(new List<String>{System.Label.CRM_MultiOrder_Duplicate_Account}, validationmap.get('0-2'));//,new List<String>{'Duplicate Account Found.'});
                System.AssertEquals(new List<String>{System.Label.CRM_MultiOrder_Duplicate_Account}, validationmap.get('0-11'));//,new List<String>{'Duplicate Account Found.'});
                System.AssertEquals(new List<String>{System.Label.CRM_Account_Not_Exist}, validationmap.get('0-12'));//,new List<String>{'Account does not exist.'});
                System.AssertEquals(new List<String>{System.Label.CRM_Not_Valid_Account}, validationmap.get('0-4'));//,new List<String>{'Ship to Account cannot be of digital type.'}); 
                System.AssertEquals(new List<String>{System.Label.CRM_MultiOrder_Duplicate_Product_Found}, validationmap.get('12-0'));//,new List<String>{'Duplicate product found.'});
                System.AssertEquals(new List<String>{System.Label.CRM_Product_Not_Exist}, validationmap.get('13-0'));//,new List<String>{'Product or valid PriceBookEntry in product does not exist.'});
                System.AssertEquals(new List<String>{System.Label.CRM_MultiOrder_Duplicate_Product_FoundWithUPC_Code + ' Test_ProdUPC1'}, validationmap.get('14-0'));//,new List<String>{'Duplicate Product found with Test_ProdUPC1'});
                System.AssertEquals(new List<String>{System.Label.CRM_MultiOrder_Duplicate_Product_Found}, validationmap.get('3-0'));//,new List<String>{'Duplicate product found.'}); 
                System.AssertEquals(new List<String>{System.Label.CRM_SAP_Dist_chain_product_Status_Not_Valid}, validationmap.get('7-0'));//,new List<String>{'SAP Distribution Chain Product Status should be Active / On Hold / Initial for Product'});
                System.AssertEquals(new List<String>{System.Label.CRM_Plant_Specific_Material_Status_Not_Valid}, validationmap.get('8-0'));//,new List<String>{'Plant Specific Material Status should be Active / Released for 3rd Party / Sell-down/Sell-Off for Product.'}); 
                System.AssertEquals(new List<String>{System.Label.CRM_Product_Not_Physical}, validationmap.get('6-0'));//,new List<String>{'Product cannot be of Digital type.'}); 
                System.AssertEquals(new List<String>{System.Label.CRM_Product_Is_Not_Active}, validationmap.get('4-0'));//,new List<String>{'Product is not Active.'});
            }
            system.debug('testCRM_MultiUploadExtractOrderCtrl3:::::::'+initialWrapInstance);
            CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].id),false);
        Test.stopTest();
    }
    
    static testMethod void testCRM_MultiUploadWithExistingOrdersAndOrdProducts() {
        createDataForMultiOrderWithPbep(); 
        List<String> lstProdString = productString.split(',');
        List<String> lstAccString = accountString.split(',');
        List<String> tempList = new List<String>(lstOfUploadedOrders);
        List<String> lstCPO = custPOString.split(',');
        lstOfUploadedOrders = new List<String>();
        productString = lstProdString[0];
        accountString = lstAccString[0];
        custPOString = lstCPO[0];
        lstOfUploadedOrders.add(tempList[0]);
        for(integer i=1;i<5;i++){
        	productString += ','+lstProdString[i];
        	accountString += ','+lstAccString[i];
        	custPOString += ','+lstCPO[i];
        	lstOfUploadedOrders.add(tempList[i]);
        }
        system.assertEquals(5,lstOfUploadedOrders.size());
        lstParentOrders[0].Order_Product_Sequence__c=productString;   
        lstParentOrders[0].Order_Account_Sequence__c=accountString;
        update lstParentOrders; 
        
        Test.startTest();
            CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = new  CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass();
            initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
            map<String,List<String>> validationmap = CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].id),false);
            system.assertEquals(0, validationmap.size());
            system.assertEquals(30,[Select count() From OrderItem]);
        Test.stopTest();
    }
    
    static testMethod void testCRM_MultiUploadWithParentOrderAccValidation() {
        createDataForMultiOrderWithPbep(); 
        List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstAccount;
        
        lstShipToAccount[0].ParentId = lstShipToAccount[0].Sold_To_Customer__c;
        lstShipToAccount[0].Sold_To_Customer__c  = lstAccount[0].id;
        lstShipToAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        update lstShipToAccount[0];
        
        lstParentOrders[0].Order_Product_Sequence__c = productString;   
        lstParentOrders[0].Order_Account_Sequence__c = accountString;
        update lstParentOrders; 
        
        Test.startTest();
            CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = new  CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass();
            initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
            system.debug('testCRM_MultiUploadExtractOrderCtrl4:::::::'+initialWrapInstance);
            map<String,List<String>> validationmap = initialWrapInstance.mapOfProAccValidatinosWrap;
            system.debug('validationmap::::::'+validationmap);
            //System.AssertEquals(1,validationmap.size());
            if(!validationmap.isEmpty()){
                System.AssertEquals(validationmap.get('0-1'),new List<String>{'Child Order Sold to Customer Account does not match Parent Order Account'});
            }  
            CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].id),false);
        Test.stopTest();
    }
     
    static testMethod void testCRM_MultiUploadDeleteRow() {
        createDataForMultiOrderWithPbep(); 
        productString='';
        createProductQtyDataForGrid();
        lstParentOrders[0].Order_Product_Sequence__c=productString;  
        lstParentOrders[0].Order_Account_Sequence__c=accountString; 
        update lstParentOrders;  
       
        //create orders
        List<Order> lstOrders = getOrders();
        system.assertEquals(10, lstOrders.size());
        //create order products         
        List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(pbEntries, lstOrders, 2, true);
        system.assertEquals(10, lstOrderProduct.size());
        
        Test.startTest(); 
            Set<String> removedProducts = CRM_MultiUploadExtractOrderController.removeOrderProducts(productString,String.valueof(lstParentOrders[0].id)); 
            system.assertEquals(0,[Select Count() From OrderItem where Order.Multi_Order__c =: lstParentOrders[0].id]); 
        Test.stopTest();
    }   
    
    //US#585 (Japan)
   
    
    static testMethod void generateMultiOrderFromDeal_Test() {
    	
    	CRM_Multiorder_Functionality__c mfc = new CRM_Multiorder_Functionality__c();
    	mfc.ByPassValidation__c = false;
    	mfc.Sales_Organization__c = '8003';
    	insert mfc;
    	
    	List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d) + 'abc@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');
    	
        
    	
    	createDataForMultiOrderWithPbep();
    	List<Order> lstParentOrder = [Select Id From Order];
    	Delete lstParentOrder;
    	
    	// Create Opportunity records
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstParentAccount, 1,false);
        lstOpportunity[0].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE; 
        lstOpportunity[0].CurrencyISOCode ='JPY';
        insert lstOpportunity;
        
        ApexPages.standardController controller = new ApexPages.standardController(lstOpportunity[0]);
        CRM_GenerateMultiOrderFromDealController pg = new CRM_GenerateMultiOrderFromDealController(controller); 
        system.assertEquals(false,pg.isCommittedDeal,'Deal Should be committed');
        system.assertEquals(false,pg.isRevenueShareAccount,'For Rental Deal Account should be Revenue Share'); 
        system.assertEquals(false,pg.isRentalDealForRevenueShareAccount,'For Revenue Share Account Deal Market Type should be Rental'); 
        
        // Create Deal Product records
        List<OpportunityLineItem> lstDealProduct = new List<OpportunityLineItem>();
        for(PricebookEntry pbe : pbEntries){
        	OpportunityLineItem objDealProduct = new OpportunityLineItem();
            objDealProduct.OpportunityId = lstOpportunity[0].Id;
            objDealProduct.PricebookEntryId = pbe.Id;
            objDealProduct.Quantity = 1;
            objDealProduct.UnitPrice = 14.10;
            lstDealProduct.add(objDealProduct);
        }
        insert lstDealProduct;
        system.assertEquals(10,[Select Count() From OpportunityLineItem]);
        
        lstParentAccount[0].Revenue_Share__c = True;
        update lstParentAccount;
        
        system.runAs(testUser){
            lstOpportunity[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstOpportunity;
        }
        
        
        Test.startTest();
        
        controller = new ApexPages.standardController(lstOpportunity[0]);
        pg = new CRM_GenerateMultiOrderFromDealController(controller); 
        CRM_GenerateMultiOrderFromDealController.generateMultiOrder(lstOpportunity[0].Id,lstParentAccount[0].Id,lstOpportunity[0].CurrencyIsoCode,lstOpportunity[0].Sales_Organisation__c,pg.isRevenueShareAccount);
        
        lstParentOrders = [Select Id From Order Where Multi_Order__c = null];
        System.assertEquals(1,lstParentOrders.size(),'Generated Multi Order');
        
        
        
        CRM_MultiUploadExtractOrderController.CRM_InitialWrapperClass initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
        map<String,List<String>> validationmap = initialWrapInstance.mapOfProAccValidatinosWrap;
        system.assertEquals(validationmap.get('0-1'),new List<String>{System.label.CRM_Account_Not_Revenue_Share_ShipToType});
        
        for(Account acc : lstShipToAccount){
        	acc.Revenue_Share__c = true;
        }
        update lstShipToAccount;
        
        initialWrapInstance = CRM_MultiUploadExtractOrderController.getInitialValidations(accountString,productString,custPOString,String.valueof(lstParentOrders[0].id));
        validationmap = initialWrapInstance.mapOfProAccValidatinosWrap;
        system.assertEquals(11,[Select Count() From Order],'Total Orders including Multi Order');
        validationmap = CRM_MultiUploadExtractOrderController.createOrdersAndOrderProducts(initialWrapInstance,lstOfUploadedOrders,String.valueof(lstParentOrders[0].Id),false);
        
        //100 Child Order Products and 10 Parent Order Products
        system.assertEquals(110,[Select count() From OrderItem]);
        for(OrderItem oi : [Select Quantity From OrderItem Where OrderId = :lstParentOrders[0].Id]){
        	system.assertEquals(55,oi.Quantity,'Parent Order Products Quantity');
        }
        
        //Activate Order
        lstParentOrders[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        update lstParentOrders;
        
        
        
        Test.stopTest();
        for(OpportunityLineItem oppLI : [Select Id,Product2.ProductCode,Initial_Quantity__c	 From OpportunityLineItem]){
        	system.assertEquals(55,oppLI.Initial_Quantity__c,'Updated Initial Quantity');
        }
        
    }
}