/**
   @Author Cognizant
   @name CRM_OrderHandler_Test
   @CreateDate 07 Jul 2016
   @Description Test class for CRM_OrderHandler
   @Version <1.0>
  */

@isTest(SeeAllData=false)
private class CRM_OrderHandler_Test{
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    public static List<Order> lstOrder;
    public static List<Order> lstParentOrder ;
    public static List<Order> lstChildOrders;
    
    static void createTestData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);   
        Id tempRecordType = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        lstAccounts[0].RecordTypeID = tempRecordType;
        lstAccounts[0].Planning_Customer__c = True;
        lstAccounts[0].Status__c = 'N';
        lstAccounts[1].RecordTypeID = tempRecordType;
        lstAccounts[1].Planning_Customer__c = True;
        lstAccounts[1].Status__c = 'N'; 
        upsert lstAccounts;   
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false); 
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = new List<Pricebook_Entry_Period__c>();
        for(Pricebook_Entry_Period__c pbep : CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false)){
            pbep.Start_Date__c = System.today()+1;
            lstPriceBookEntryPeriiod.add(pbep);
        }
        insert lstPriceBookEntryPeriiod;
        System.debug('lstPriceBookEntryPeriiod::'+lstPriceBookEntryPeriiod);
        lstOrder = CRM_TestDataFactory.createOrders(lstAccounts, 2,true);  
        List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstOrder, 1, true);
    } 
    static testmethod void generateAttachPDF_test() {
         createTestData();
        Test.StartTest();
        
        lstOrder[0].Status = 'Submitted';
        lstOrder[0].Confirm__c = true;
        lstOrder[0].Customer_PO_Number__c ='345355';
        lstOrder[0].Confirmation_Email__c = 'TestEmail@Test.com';
        upsert lstOrder;
        
        Test.StopTest();
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:lstOrder[0].id];
        System.assertEquals(1, attachments.size());
    }
    
    static testmethod void UpdateCustomTotalPriceOnOrederProduct_test() {
        List<Bundle__c> assortments = CRM_TestDataFactory.createBundles(1,true);
        
        //Create SBOM Config
        Config__c sbomConfig= CRM_TestDataFactory.createConfig(assortments[0]);
        
        //create VRAC Config
        Config__c vracConfig = new Config__c();
        vracConfig .RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_VRAC;
        vracConfig .Assortment__c = assortments[0].Id;
        
        List<Config__c> configs = new List<Config__c>{sbomConfig,vracConfig};
        insert configs;
        
        createTestData();
        
        List<Order> oldOrderListr = [select Id,TotalAmount,Order_Amount__c From Order Where Id IN :lstOrder];
        
        //One Oreder Product having Total Quantity = 1 and UnitPrice = 14.10 ==> Total Price = (1 * 14.10)
        //Initially standard Order Amount and Custom Order Amount are equals where config__c is null.
        system.assertEquals(oldOrderListr[0].TotalAmount ,oldOrderListr[0].Order_Amount__c);
        
        //case -1 Trigger not fire
        //add SBOM Config and SBOM Quantity 
        lstOrder[0].Quantity__c = 1;
        lstOrder[0].Config__c = sbomConfig.id;
        update lstOrder;
        
        List<Order> newOrderListr1 = [select Id,TotalAmount,Order_Amount__c From Order Where Id IN :lstOrder];
        List<OrderItem> oiList1 = [Select Id,OrderId,Total_Quantity__c,UnitPrice,Total_Price__c From OrderItem Where Order.Id IN :newOrderListr1];
        
        //Assert Total Price equal to (Total Quantity * UnitPrice) ==> (1 * 14.10)
        system.assertEquals(oiList1[0].Total_Price__c , (oiList1[0].Total_Quantity__c * oiList1[0].UnitPrice));
        
        //One Order Product under Order, Order Amount = Total_Price__c
        system.assertEquals(newOrderListr1[0].Order_Amount__c,oiList1[0].Total_Price__c);
        //standard Order Amount and Custom Order Amount are equals
        system.assertEquals(newOrderListr1[0].Order_Amount__c,newOrderListr1[0].TotalAmount);
        
        //case -2 Trigger fired
        //add SBOM Config and SBOM Quantity 
        lstOrder[0].Quantity__c = 5;
        lstOrder[0].Config__c = sbomConfig.id;
        update lstOrder;
        
        List<Order> newOrderListr2 = [select Id,TotalAmount,Order_Amount__c From Order Where Id IN :lstOrder];
        List<OrderItem> oiList2 = [Select Id,OrderId,Total_Quantity__c,UnitPrice,Total_Price__c From OrderItem Where Order.Id IN :newOrderListr2];
        
        //Assert Total Price equal to (Total Quantity * UnitPrice) ==> (5 * 14.10)
        system.assertEquals(oiList2[0].Total_Price__c , (oiList2[0].Total_Quantity__c * oiList2[0].UnitPrice));
        
        //One Order Product under Order, Order Amount = Total_Price__c of Order Product
        system.assertEquals(newOrderListr2[0].Order_Amount__c,oiList2[0].Total_Price__c);
        
        
        //Case -3 add VRAC Config on Order where Standard and Custom Order Amount are same
        lstOrder[0].Config__c = vracConfig.id;
        update lstOrder;
        
        List<Order> newOrderListr3 = [select Id,TotalAmount,Order_Amount__c From Order Where Id IN :lstOrder];
        List<OrderItem> oiList3 = [Select Id,OrderId,Quantity,Total_Quantity__c,UnitPrice,Total_Price__c From OrderItem Where Order.Id IN :newOrderListr3];
        
        //Assert Custom Total Price equal to Standard TotalPrice (Quantity * UnitPrice)
        system.assertEquals(oiList3[0].Total_Price__c , (oiList3[0].Quantity * oiList3[0].UnitPrice));
        
        //Assert Custom Order Amount equal to Standard OrderAmount
        system.assertEquals(newOrderListr3[0].Order_Amount__c,newOrderListr3[0].TotalAmount);
    } 
        
    public static List<PricebookEntry> createPriceBookEntries(List<Product2> lstProduct, Integer numPBEntriesPerProduct, Boolean shouldInsert, String CurrencyIsoCode){
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        Id standardPricebookId = System.Test.getStandardPricebookId();     
        for(Integer nProductCount = 0; nProductCount < lstProduct.size(); nProductCount++){         
            if (numPBEntriesPerProduct == null)
                numPBEntriesPerProduct = 1;
                
            for (Integer oppCount = 0; oppCount < numPBEntriesPerProduct; oppCount++) {
                PricebookEntry objPriceBookEntry = new PricebookEntry();
                objPriceBookEntry.UseStandardPrice = false;
                objPriceBookEntry.UnitPrice = 10.00 * (oppCount + 1);
                objPriceBookEntry.CurrencyIsoCode = CurrencyIsoCode;
                objPriceBookEntry.Product2Id = lstProduct[nProductCount].Id;                
                objPriceBookEntry.IsActive = true;
                objPriceBookEntry.Pricebook2Id = standardPricebookId;
                lstPricebookEntry.add(objPriceBookEntry);
            }
        }
        if (shouldInsert && lstPricebookEntry != null && lstPricebookEntry.size() > 0)
            insert lstPricebookEntry;
            System.assertNotEquals(null,lstPricebookEntry);
        
        return lstPricebookEntry;
    }
    /* Creating OrderProducts*/
    public static List<OrderItem> createOrderProductWithOrder(List<PricebookEntry> lstPriceBookEntry, List<Order> lstOrders,
                                                              Integer numOrderPerOrderProduct, Boolean shouldInsert){
        List<OrderItem> lstOrderProduct = new List<OrderItem>();
        ID idPriceBookEntry;
        if (lstPriceBookEntry != null && lstPriceBookEntry.size() > 0){
            for (Integer nOrderProdCount = 0; nOrderProdCount < lstOrders.size(); nOrderProdCount ++){
                for(Integer orderProdPBEP = 0 ;  orderProdPBEP < lstPriceBookEntry.size() ; orderProdPBEP++){
                
                    OrderItem objOrderProduct = new OrderItem();
                    objOrderProduct.OrderId = lstOrders[nOrderProdCount].Id;
                        
                    /*if (lstPriceBookEntry.size() >= (nOrderProdCount + 1))
                        idPriceBookEntry = lstPriceBookEntry[nOrderProdCount].Id;*/
                          
                    objOrderProduct.PricebookEntryId = lstPriceBookEntry[orderProdPBEP].Id;
                    objOrderProduct.Quantity = 1;
                    objOrderProduct.UnitPrice = 14.10;                
                    lstOrderProduct.add(objOrderProduct);
                }
            }
        }
        if (lstOrderProduct != null && lstOrderProduct.size() > 0 && shouldInsert){
            insert lstOrderProduct;
            System.assertNotEquals(null,lstOrderProduct);
        }
        
        return lstOrderProduct;        
    }
    /*Create Data for Multi Order for Japan*/
     
    static void createMultiOrderTestData(Id parentOrderRTId,Id childOrderRTID,String salseOrg,String CurrencyISOCode){
        //create parent account
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstParentAccounts[0].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstParentAccounts[0].Sales_Organization__c = salseOrg; //CRM_AppConstants.TERRITORY_JAPAN_CODE;
        lstParentAccounts[0].AccountNumber='11118';
        lstParentAccounts[0].CurrencyISOCode = CurrencyISOCode;
        insert lstParentAccounts;
        System.assertEquals(1,lstParentAccounts.size());
        
        //create parent order
        lstParentOrder = CRM_TestDataFactory.createOrders(lstParentAccounts,1,false);  
        
        //parent order
        lstParentOrder[0].RecordTypeId = parentOrderRTId;
        lstParentOrder[0].AccountId = lstParentAccounts[0].Id;
        lstParentOrder[0].CurrencyISOCode=CurrencyISOCode; //'JPY';
        lstParentOrder[0].Customer_PO_Number__c ='5441221';
        insert lstParentOrder[0]; 
        
        //create child ship to accounts 
        List<Account> lstChildAccounts = CRM_TestDataFactory.createAccounts(10, false); 
        for(Integer i=0;i<lstChildAccounts.size();i++){
            lstChildAccounts[i].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
            lstChildAccounts[i].Sales_Organization__c =salseOrg;
            lstChildAccounts[i].Sold_to_customer__c= lstParentAccounts[0].id;
            lstChildAccounts[i].AccountNumber = 'TestAccount'+i;
            lstChildAccounts[i].CurrencyISOCode=CurrencyISOCode;
            lstChildAccounts[i].BillingCountryCode = 'TH';
            lstChildAccounts[i].BillingLatitude = 22.33;
            lstChildAccounts[i].BillingLongitude = 33.33;
            lstChildAccounts[i].BillingPostalCode = '242342';
            lstChildAccounts[i].BillingCity = 'Bangkok'; 
            lstChildAccounts[i].BillingStreet = 'Bangkok street';
            lstChildAccounts[i].BillingCountry = 'Thailand'; 
            if(lstChildAccounts[i].Sales_Organization__c == '6014'){
                  lstChildAccounts[i].ship_to__c = true;
            }
        }
        insert lstChildAccounts ;
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1,lstProductGroup.size());
        
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup,10,false);
        System.assertEquals(10,lstProduct.size());
        
        for(Integer i = 0; i < lstProduct.size(); i++) { 
            lstProduct[i].Universal_Picture_Code__c = 'Test_ProdUPC'+i;
            lstProduct[i].ProductCode = 'Test_ProdCode'+i;
            lstProduct[i].Product_Market__c=CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            lstProduct[i].recordtypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            lstProduct[i].Type__c = 'Games Physical';
            lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        }
        insert lstProduct; 
        
        List<PricebookEntry> lstPriceBookEntries  = createPriceBookEntries(lstProduct, 1, true,CurrencyIsoCode);
        System.assertEquals(10,[select id ,currencyisocode from PricebookEntry].size());
        
        List<Pricebook_Entry_Period__c >  lstPriceBookEntryPeriod = new List<Pricebook_Entry_Period__c>();
        for(Pricebook_Entry_Period__c pbep : CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false)){
            pbep.Start_Date__c = System.today()+1;
            pbep.CurrencyISOCode=CurrencyIsoCode;
            lstPriceBookEntryPeriod.add(pbep);
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(10,[select id ,currencyisocode from Pricebook_Entry_Period__c ].size());
        //System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        
        //create child ship to orders
        lstChildOrders = CRM_TestDataFactory.createOrders(lstChildAccounts ,1,false);  
        for(integer i=0 ; i < lstChildOrders.size() ; i++){
            lstChildOrders[i].RecordTypeId = childOrderRTID;
            lstChildOrders[i].Multi_Order__c = lstParentOrder[0].Id;
            lstChildOrders[i].AccountId=lstParentAccounts[0].Id;
            lstChildOrders[i].Ship_To_Account__c = lstChildAccounts[i].Id;
            lstChildOrders[i].Customer_PO_Number__c ='5441221'+i;
            lstChildOrders[i].CurrencyISOCode = CurrencyISOCode;//'JPY';
        }
        insert lstChildOrders;  
        //system.debug('lstChildOrders:::::::::'+lstChildOrders[0]);
        list<order> insertedOrd = [SELECT id,BillingCountry,BillingCountryCode ,BillingLatitude,BillingLongitude,BillingPostalCode,BillingCity,BillingStreet FROM order]; 
        System.assertEquals(10, lstChildOrders.size(),'Child Order List Size'); 
        
        /*for(Integer i=1;i<insertedOrd.size();i++){
            System.assertEquals('TH', insertedOrd[i].BillingCountryCode); 
            System.assertEquals(22.33, insertedOrd[i].BillingLatitude); 
            System.assertEquals(33.33, insertedOrd[i].BillingLongitude); 
            System.assertEquals('242342', insertedOrd[i].BillingPostalCode); 
            System.assertEquals('Bangkok', insertedOrd[i].BillingCity); 
            System.assertEquals('Bangkok street', insertedOrd[i].BillingStreet); 
            System.assertEquals('Thailand', insertedOrd[i].BillingCountry); 
        }*/
               
        List<OrderItem> lstOrderProduct = createOrderProductWithOrder(lstPriceBookEntries, lstChildOrders , 1, true);//Create ChildOrderItem
        List<OrderItem> listParentOrderItem = new List<OrderItem>();//Create ParentOrderItem 
        Map<Id,List<OrderItem>> mapPBEAndChildOrderItem = new Map<Id,List<OrderItem>>();
        for(Integer i=0;i<lstOrderProduct.size();i++){
            OrderItem objOrderProduct = new OrderItem();
            objOrderProduct.OrderId = lstParentOrder[0].Id;
            objOrderProduct.PricebookEntryId = lstOrderProduct[i].PricebookEntryId;
            objOrderProduct.Quantity = lstOrderProduct[i].Quantity;
            objOrderProduct.UnitPrice = lstOrderProduct[i].UnitPrice;                
            if(mapPBEAndChildOrderItem.containsKey(lstOrderProduct[i].PricebookEntryId)){
                (mapPBEAndChildOrderItem.get(lstOrderProduct[i].PricebookEntryId)).add(objOrderProduct);
            }
            else{
                listParentOrderItem = new List<OrderItem>();
                listParentOrderItem.add(objOrderProduct);
                mapPBEAndChildOrderItem.put(lstOrderProduct[i].PricebookEntryId, listParentOrderItem);
            } 
        }
        system.assertequals(10,mapPBEAndChildOrderItem.size());
        List<OrderItem> lstInsertParentOrderItem = new List<OrderItem>();
        for(Id pbeId : mapPBEAndChildOrderItem.keySet()){
            List<OrderItem> lstOI = mapPBEAndChildOrderItem.get(pbeId);
            OrderItem parentOI = new OrderItem();
            parentOI.PricebookEntryId=pbeId;
            parentOI.OrderId = lstParentOrder[0].Id;
            for(OrderItem childOrderItem: lstOI){
                if(null!=parentOI.Quantity){
                    parentOI.Quantity = parentOI.Quantity + childOrderItem.Quantity;
                }else{
                    parentOI.Quantity = childOrderItem.Quantity;
                    parentOI.UnitPrice = childOrderItem.UnitPrice;
                }
            }
            lstInsertParentOrderItem.add(parentOI);
        }
        insert lstInsertParentOrderItem;
        System.assertEquals(10, lstInsertParentOrderItem.size(),'Parent Order Item size');
        System.assertEquals(100,lstOrderProduct.size(),'Child Order Product size');
        
        //Create Account Sequence
        List<Id> lstAccountId = new List<Id>();
        for(integer i=0;i<lstParentOrder.size();i++){
            lstAccountId.add(lstParentOrder[i].accountId);
        }
        List<Account> lstAccNumber=[Select AccountNumber from Account where id in :lstAccountId];
        List<String> lstAccountSequence = new List<String>();
        for(Account a : lstAccNumber){
            lstAccountSequence.add(a.AccountNumber);
        }
        String accountSequence = String.join(lstAccountSequence,',');
        lstParentOrder[0].Order_Account_Sequence__c=accountSequence;
        
        //Create Product Sequence
        List<String> lstProdSequence = new List<String>();
        for(Product2 prod : lstProduct){
            lstProdSequence.add(prod.ProductCode);
        }
        lstParentOrder[0].Order_Product_Sequence__c = String.join(lstProdSequence, ',');
        update lstParentOrder[0];
        //System.assertEquals(100,lstOrder.size(),'Child Order Product size');
    }
    
     /**
    *  Test 3: Test to approve/reject all child Orders. 
    *  Expected: Approve/Reject All Related Child Orders of Parent Multi Order Return
    *  @name approveOrRejectAllChildOrders_Test
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void approveOrRejectAllChildOrders_Test(){
    
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_JAPAN_CODE,'JPY');
        List<Order> parentMultiOrder = [Select Id,Status,ActivatedDate,ActivatedById From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentMultiOrder.size(),'One Parent Multi Order Return');
        parentMultiOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        
        Test.StartTest();
        CRM_AppConstants.orderActivateFlag = True;
        update parentMultiOrder;
        parentMultiOrder[0].Return_Approval__c = CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL;
        CRM_AppConstants.orderActivateFlag = True;
        update parentMultiOrder;
        Test.StopTest();
        
        List<Order> lstChildOrder = [Select Id,Return_Approval__c From Order Where Multi_Order__c =: parentMultiOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Return Order');
        for(Order oObj : lstChildOrder){
            system.assertEquals(CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL,oObj.Return_Approval__c,'All Child Orders should be approved');
        }
    }
     /**
    *  Test 3: Test to delete child orders when parent orders are deleted. 
    *  Expected: Delete all associated child orders
    *  @name deleteChildOrderTest
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void deleteChildOrderTest(){
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER,CRM_RecordTypeUtil.RT_ORDER_STANDARD,CRM_AppConstants.TERRITORY_JAPAN_CODE,'JPY');
        Test.startTest();
        
        delete lstParentOrder[0];
        Test.stopTest();
        
        List<Order> lstChildOrder = [Select Id,Status From Order Where Multi_Order__c =: lstParentOrder[0].Id];
        System.assertEquals(0, lstChildOrder.size(),'Child Order is Deleted');
    }
    
    static testmethod void updateParentOrderQuantityRollupTest(){
       createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER,CRM_RecordTypeUtil.RT_ORDER_STANDARD,CRM_AppConstants.TERRITORY_JAPAN_CODE,'JPY');
        Test.startTest();
        String accountSequence = lstParentOrder[0].Order_Account_Sequence__c;
        //System.debug('Account Sequence before delete'+accountSequence); //11118
        List<OrderItem> lstchildOrderItem= [Select Id,Quantity,pricebookentryId from OrderItem where orderid =:lstChildOrders[0].Id];
        //System.debug('lstchildOrderItem===>'+lstchildOrderItem.size());
        System.assertEquals(lstchildOrderItem.size(),10); 
        delete lstChildOrders[0];
        System.assertEquals(9,[select id from order where id in:lstChildOrders].size());  
        List<OrderItem> lstParentOrderItem= [Select Id,Quantity from OrderItem 
                                                    where orderid =:lstParentOrder[0].Id 
                                                    and pricebookentryid=:lstchildOrderItem[0].pricebookentryId];
        //System.debug('lstParentOrderItem===>'+lstParentOrderItem);
        //System.debug('Account Sequence after delete' + lstParentOrder[0].Order_Account_Sequence__c); 
        System.assertEquals(9, lstParentOrderItem[0].Quantity, 'Quantity reduced after deletion rollup');
        System.assertEquals(accountSequence, lstParentOrder[0].Order_Account_Sequence__c, 'Account Sequence is updated');
        
        List<Order> lstDeleteOrders = new List<Order>();
        for(integer i=2;i<lstChildOrders.size();i++){
            lstDeleteOrders.add(lstChildOrders[i]);
        }
        database.delete(lstChildOrders,false);
        System.assertEquals(0, [select id from order where id in :lstDeleteOrders].size());
        System.assertEquals(0, [select id from orderitem where orderid  !=:lstParentOrder[0].Id ].size());
        
        List<OrderItem> lstCheckParentOrderItemDeleted = new List<OrderItem>();
        lstCheckParentOrderItemDeleted = [Select Id,Quantity from OrderItem where orderid =:lstParentOrder[0].Id];
        //System.debug('lstCheckParentOrderItemDeleted'+lstCheckParentOrderItemDeleted);
        System.assertEquals(0, [Select Id,Quantity from OrderItem where orderid =:lstParentOrder[0].Id].size(), 'All Order Items deleted');
        Test.stopTest();
    }
    
     /**
    *  Test 3: Test to Update Status of Multi Return Order To In SAP
    *  Expected: Parent Multi Order Return Status Should be In SAP When its one of child return order's Status chsnges to In SAP 
    *  @name multiOrderReturnInSAPStatus_Test
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void multiOrderActivateAndReturnInSAPStatus_Test(){
    
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_JAPAN_CODE,'JPY');
        List<Order> parentOrder = [Select Id,Status,ActivatedDate,ActivatedById From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentOrder.size(),'One Parent Multi Order Return');
        parentOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        Test.StartTest();
        CRM_AppConstants.orderActivateFlag = True;
        update parentOrder;
        Test.StopTest();
        
        List<Order> lstChildOrder = [Select Id,Status From Order Where Multi_Order__c =: parentOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Order');
        for(Order oObj : lstChildOrder){
            system.assertEquals(oObj.Status,CRM_AppConstants.ORDER_STAGE_SUBMITTED,'All Child Orders should be activated');
        }
        
        lstChildOrder[0].status = CRM_AppConstants.ORDER_STAGE_In_SAP;
        CRM_AppConstants.orderActivateFlag = True;
        update lstChildOrder[0];
        
        parentOrder = [Select Id,Status From Order Where Id =:parentOrder[0].Id];
        system.assertEquals(CRM_AppConstants.ORDER_STAGE_In_SAP, parentOrder[0].status,'Multi Order Return status should be In SAP');
        
    }
    
     /**
    *  Test 3: Test to Submit Return Order For Approval
    *  Expected: Parent Multi Order Return/Single Return Order Should be send for approval
    *  @name multiOrderReturnInSAPStatus_Test
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void multiReturnAndSingleReturnOrderSubmitForApproval(){
        createUser();
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_JAPAN_CODE,'JPY');
        List<Order> parentOrder = [Select Id,Status,ActivatedDate,ActivatedById From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentOrder.size(),'One Parent Multi Order Return');
        parentOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        parentOrder[0].LPFR_Return_Value__c = 100;
        Test.StartTest();
        CRM_AppConstants.orderActivateFlag = True;
        update parentOrder;
        Test.StopTest();
        
        List<Order> lstChildOrder = [Select Id,Status From Order Where Multi_Order__c =: parentOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Order');
        for(Order oObj : lstChildOrder){
            system.assertEquals(oObj.Status,CRM_AppConstants.ORDER_STAGE_SUBMITTED,'All Child Orders should be activated');
            oObj.status = CRM_AppConstants.ORDER_STAGE_In_SAP;
            oObj.LPFR_Return_Value__c = 100;
        }
        
        CRM_AppConstants.orderActivateFlag = True;
        update lstChildOrder;
        
        parentOrder = [Select Id,Status From Order Where Id =:parentOrder[0].Id];
        system.assertEquals(CRM_AppConstants.ORDER_STAGE_In_SAP, parentOrder[0].status,'Multi Order Return status should be In SAP');
        
        List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :parentOrder[0].id];
        System.assertEquals(processInstances.size(),1);
    }
    
    static testmethod void AutoUpdateShipToTest(){
        //createTestData();
        
        //create parent account
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstParentAccounts[0].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstParentAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        lstParentAccounts[0].AccountNumber='11118';
        insert lstParentAccounts;
        System.assertEquals(1,lstParentAccounts.size());
        
        List<Account> childAccounts = CRM_TestDataFactory.createAccounts(1, false);
        childAccounts[0].RecordTypeId  = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
        childAccounts[0].Sold_To_Customer__c = lstParentAccounts[0].Id;
        childAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        childAccounts[0].AccountNumber='11118';
        childAccounts[0].Ship_to__c=true;
        insert childAccounts;
                
        Test.startTest();
        lstOrder = CRM_TestDataFactory.createOrders(lstParentAccounts,1,true);      
        Test.stopTest();
        List<Order> orderRec = [select Id,AccountId,Ship_To_Account__c from Order];
        system.assertEquals(childAccounts[0].Id,orderRec[0].Ship_To_Account__c);        
       
    }
    
    /*static testmethod void germanyReturnOrderAutoApproval(){ //Commented for ER-006683
        createUser();
        Id accountOwnerId = [Select Id From User Where FirstName = 'Account' AND LastName = 'Owner User'].Id;
        Id orderApproverId = [Select Id From User Where FirstName = 'Order' AND LastName = 'Aprover User'].Id;
        Test.startTest();
        
        List<CRM_Germany_Approval_Rule__c> lstGCS = new List<CRM_Germany_Approval_Rule__c>();
        for(integer i=0;i<2;i++){
            CRM_Germany_Approval_Rule__c gcs = new CRM_Germany_Approval_Rule__c();
            gcs.name = 'GAR '+i;
            gcs.Account_Owner__c = String.valueOf(accountOwnerId); 
            if(i==0){
                gcs.Approval_Limit_From__c = 1;
                gcs.Approval_Limit_To__c = 10000;
                gcs.Auto_Approve__c = True;
            }else{
                gcs.Approval_Limit_From__c = 10000;
                gcs.Approval_Limit_To__c = 15000;
                gcs.Auto_Approve__c = false;
                gcs.Approver__c = String.valueOf(orderApproverId);
            }
            lstGCS.add(gcs);
        }
        insert lstGCS;
        
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_GERMANY_CODE,'EUR');
        Account parentAccount = [Select Id,OwnerId From Account Where RecordTypeId  = :CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO Limit 1];
        parentAccount.OwnerId = accountOwnerId;
        update parentAccount;
        
        List<Order> parentOrder = [Select Id,Status,ActivatedDate,ActivatedById From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentOrder.size(),'One Parent Multi Order Return');
        parentOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        parentOrder[0].LPFR_Return_Value__c = 0;
        CRM_AppConstants.orderActivateFlag = True;
        update parentOrder;
        
        List<Order> lstChildOrder = [Select Id,Status From Order Where Multi_Order__c =: parentOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Order');
        for(Order oObj : lstChildOrder){
            system.assertEquals(oObj.Status,CRM_AppConstants.ORDER_STAGE_SUBMITTED,'All Child Orders should be activated');
            oObj.status = CRM_AppConstants.ORDER_STAGE_In_SAP;
            oObj.LPFR_Return_Value__c = 100;
        }
        
        CRM_AppConstants.orderActivateFlag = True;
        update lstChildOrder;
        
        for(Order orderObj : [Select Return_Approval__c From Order]){
          //  system.assertEquals(CRM_AppConstants.RETURN_ORDER_RETURN_APPROVAL,orderObj.Return_Approval__c,'Order should auto aprove');
        }
        
        Test.stopTest();
    }
    
    static testmethod void germanyReturnOrderAutoApproval_US992(){
        createUser();
        Id accountOwnerId = [Select Id From User Where FirstName = 'Account' AND LastName = 'Owner User'].Id;
        Id orderApproverId = [Select Id From User Where FirstName = 'Order' AND LastName = 'Aprover User'].Id;
        Test.startTest();
        
        List<CRM_Germany_Approval_Rule__c> lstGCS = new List<CRM_Germany_Approval_Rule__c>();
        for(integer i=0;i<2;i++){
            CRM_Germany_Approval_Rule__c gcs = new CRM_Germany_Approval_Rule__c();
            gcs.name = 'GAR '+i;
            gcs.Account_Owner__c = String.valueOf(accountOwnerId);
            if(i==0){
                gcs.Approval_Limit_From__c = 0;
                gcs.Approval_Limit_To__c = 10000;
                gcs.Auto_Approve__c = True;
            }else{
                gcs.Approval_Limit_From__c = 10000;
                gcs.Approval_Limit_To__c = 15000;
                gcs.Auto_Approve__c = false;
                gcs.Approver__c = String.valueOf(orderApproverId);
            }
            lstGCS.add(gcs);
        }
        insert lstGCS;
        
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_GERMANY_CODE,'EUR');
        Account parentAccount = [Select Id,OwnerId From Account Where RecordTypeId  = :CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO Limit 1];
        parentAccount.OwnerId = accountOwnerId;
        update parentAccount;
        
        List<Order> parentOrder = [Select Id,Status,ActivatedDate,ActivatedById From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentOrder.size(),'One Parent Multi Order Return');
        parentOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        parentOrder[0].LPFR_Return_Value__c = 200;
        CRM_AppConstants.orderActivateFlag = True;
        update parentOrder;
        
        List<Order> lstChildOrder = [Select Id,Status From Order Where Multi_Order__c =: parentOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Order');
        CRM_AppConstants.orderActivateFlag = True;
        for(Order oObj : lstChildOrder){
            system.assertEquals(oObj.Status,CRM_AppConstants.ORDER_STAGE_SUBMITTED,'All Child Orders should be activated');
            oObj.status = CRM_AppConstants.ORDER_STAGE_SUBMITTED; 
            oObj.LPFR_Return_Value__c = 100; 
        } 
        update lstChildOrder;
        
        for(Order oObj : lstChildOrder){
            oObj.status = CRM_AppConstants.ORDER_STAGE_In_SAP;
            oObj.LPFR_Return_Value__c = 100;
        }
        update lstChildOrder; 
        
        
        List<OrderHistory> lstOrderhistory =[SELECT CreatedById,Field,Id,IsDeleted,NewValue,OldValue,OrderId 
                                                FROM OrderHistory 
                                                WHERE orderid IN: lstChildOrder 
                                                AND Field ='Status'];
        for(OrderHistory orderHisRec :lstOrderhistory ){
            if(orderHisRec.OldValue == CRM_AppConstants.ORDER_STATUS_OPEN && orderHisRec.NewValue == CRM_AppConstants.ORDER_STAGE_SUBMITTED){
             } 
        }
         
        List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :parentOrder[0].id];
        System.assertEquals(processInstances.size(),1);
        for(Order orderObj : [Select Return_Approval__c From Order]){
            system.assertEquals('Awaiting Approval',orderObj.Return_Approval__c,'Order should auto aprove');
        } 
        Test.stopTest();
    }
    
    static testmethod void germanyReturnOrderApproval(){
        createUser();
        Id accountOwnerId = [Select Id From User Where FirstName = 'Account' AND LastName = 'Owner User'].Id;
        Id orderApproverId = [Select Id From User Where FirstName = 'Order' AND LastName = 'Aprover User'].Id;
        Test.startTest();
        
        List<CRM_Germany_Approval_Rule__c> lstGCS = new List<CRM_Germany_Approval_Rule__c>();
        for(integer i=0;i<2;i++){
            CRM_Germany_Approval_Rule__c gcs = new CRM_Germany_Approval_Rule__c();
            gcs.name = 'GAR '+i;
            gcs.Account_Owner__c = String.valueOf(accountOwnerId);
            if(i==0){
                gcs.Approval_Limit_From__c = 0;
                gcs.Approval_Limit_To__c = 10000;
                gcs.Auto_Approve__c = True;
            }else{
                gcs.Approval_Limit_From__c = 10000;
                gcs.Approval_Limit_To__c = 15000;
                gcs.Auto_Approve__c = false;
                gcs.Approver__c = String.valueOf(orderApproverId);
            }
            lstGCS.add(gcs);
        }
        insert lstGCS;
        
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_GERMANY_CODE,'EUR');
        Account parentAccount = [Select Id,OwnerId From Account Where RecordTypeId  = :CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO Limit 1];
        parentAccount.OwnerId = accountOwnerId;
        update parentAccount;
        
        List<Order> parentOrder = [Select Id,Status,ActivatedDate,ActivatedById From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentOrder.size(),'One Parent Multi Order Return');
        parentOrder[0].Status = CRM_AppConstants.ORDER_STAGE_SUBMITTED;
        parentOrder[0].LPFR_Return_Value__c = 11000;
        CRM_AppConstants.orderActivateFlag = True;
        update parentOrder;
        
        List<Order> lstChildOrder = [Select Id,Status From Order Where Multi_Order__c =: parentOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Order');
        for(Order oObj : lstChildOrder){
            system.assertEquals(oObj.Status,CRM_AppConstants.ORDER_STAGE_SUBMITTED,'All Child Orders should be activated');
            oObj.status = CRM_AppConstants.ORDER_STAGE_In_SAP;
            oObj.LPFR_Return_Value__c = 110;
        }
        
        CRM_AppConstants.orderActivateFlag = True;
        update lstChildOrder;
        
        Test.stopTest();
        
        List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :parentOrder[0].id];
        System.assertEquals(processInstances.size(),1);
    }*/ //Commented for ER-006683
    
    static user createUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User accountOwner = new User(
            FirstName = 'Account',
            LastName = 'Owner User',
            Username = 'accountOwner.wbtest@test.com',
            Email = 'accountOwner@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id
        );
        insert accountOwner;
        System.assert(accountOwner.Id != null, 'User should get created');
        
        User orderApprover = new User(
            FirstName = 'Order',
            LastName = 'Aprover User',
            Username = 'orderApprover.wbtest@test.com',
            Email = 'orderApprover@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id
        );
        insert orderApprover;
        System.assert(orderApprover.Id != null, 'User should get created');
        
        return orderApprover;
  }
  
  /**
   * Defect#4542 - Auto populate requested delivery date on child orde from parent order on update of requested delivery date on parent order.
   * Method : AutoUpdateEffectiveDateOnChildOrders
   **/
  static testmethod void AutoUpdateEffectiveDateOnChildOrders(){
        createUser();
        Id accountOwnerId = [Select Id From User Where FirstName = 'Account' AND LastName = 'Owner User'].Id;
        Id orderApproverId = [Select Id From User Where FirstName = 'Order' AND LastName = 'Aprover User'].Id;
        Test.startTest();
        createMultiOrderTestData(CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN,CRM_RecordTypeUtil.RT_ORDER_RETURN,CRM_AppConstants.TERRITORY_GERMANY_CODE,'EUR');
        Account parentAccount = [Select Id,OwnerId From Account Where RecordTypeId  = :CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO Limit 1];
        parentAccount.OwnerId = accountOwnerId;
        update parentAccount;
        
        List<Order> parentOrder = [Select Id,EffectiveDate From Order Where RecordTypeId =: CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN Limit 1];
        System.assertEquals(1,parentOrder.size(),'One Parent Multi Order Return');

        parentOrder[0].EffectiveDate = system.today()+12;
        update parentOrder;

        List<Order> lstChildOrder = [Select Id,EffectiveDate,Multi_Order__r.EffectiveDate From Order Where Multi_Order__c =: parentOrder[0].Id];
        System.assertEquals(10,lstChildOrder.size(),'All Child Order');
        
        for(Order orderObj : lstChildOrder){
            orderObj.EffectiveDate = system.today()+12;
        }
        update lstChildOrder;
        
        parentOrder[0].EffectiveDate = system.today()+30;
        update parentOrder;
        
        Test.stopTest();
        
        for(Order orderObj : lstChildOrder){
            system.assertEquals(orderObj.Multi_Order__r.EffectiveDate,orderObj.EffectiveDate);
        }
        
    }
}