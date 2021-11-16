@isTest(seeAllData=false)
/*
   @Author Cognizant
   @name CRM_PDFAttachmentFromSAPToOrder_Test 
   @CreateDate 13 OCT 2016
   @Description Test Class of CRM_PDFAttachmentFromSAPToOrder
   @Version <1.0>
   @reference Requirement no 474(JAPAN)
*/
public with sharing class CRM_PDFAttachmentFromSAPToOrder_Test {
   /*
      @name handleInboundEmailPositiveTest(Positive Test)
      @param None
      @return None
      @throws None
      @see com.ac.sample.SuperObject#get
  */ 
  static Id multiOrderReturnId;
  static void createdata(){
        //Create Parent Account
        List<Account> lstParentAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstParentAccount[0].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstParentAccount[0].CurrencyIsoCode = 'JPY';  
        lstParentAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstParentAccount;
        system.assertEquals(1,lstParentAccount.size());
        
        //Create Ship To Child Accounts 
        List<Account> lstShipToAccount = CRM_TestDataFactory.createAccounts(3, false);
        for(Integer i = 0; i < lstShipToAccount.size(); i++) {
            lstShipToAccount[i].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
            lstShipToAccount[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            lstShipToAccount[i].Sold_to_customer__c= lstParentAccount[0].id;
            lstShipToAccount[i].AccountNumber = 'TestAccount'+i;
        }
        insert lstShipToAccount;
        system.assertEquals(3,lstShipToAccount.size()); 
        
        List<Order> lstMultiOrderReturn = CRM_TestDataFactory.createOrders(lstParentAccount,1,false);
        lstMultiOrderReturn[0].CurrencyIsoCode = 'JPY';  
        lstMultiOrderReturn[0].Customer_PO_Number__c = '6564658757'; 
        lstMultiOrderReturn[0].recordTypeId = CRM_RecordTypeUtil.RT_ORDER_MULTI_ORDER_RETURN;
        insert lstMultiOrderReturn;
        multiOrderReturnId = lstMultiOrderReturn[0].Id;
        system.assertEquals(1,lstMultiOrderReturn.size()); 
        
        //Order
        List<Order> lstOrder = CRM_TestDataFactory.createOrders(lstParentAccount,3,false);
        for(integer i=0;i<3;i++){
            lstOrder[i].RecordTypeID = CRM_RecordTypeUtil.RT_ORDER_RETURN;
            lstOrder[i].Ship_To_Account__c = lstShipToAccount[i].Id;
            lstOrder[i].CurrencyIsoCode = 'JPY';
            if(i>0){
                lstOrder[i].Multi_Order__c = lstMultiOrderReturn[0].Id;
            }
        }
        insert lstOrder;
        system.assertEquals(3, lstOrder.size());
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        system.assertEquals(1, lstProductGroup.size());
        
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false); 
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProduct[0].Universal_Picture_Code__c = 'Test_ProdUPC';
        lstProduct[0].ProductCode = 'Test_ProdCode';
        lstProduct[0].Product_Market__c=CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        lstProduct[0].Type__c = 'Games Physical';
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        lstProduct[0].CurrencyIsoCode = 'JPY';  
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        lstPriceBookEntries[0].CurrencyIsoCode = 'JPY';  
        insert lstPriceBookEntries;
        system.assertEquals(1, lstPriceBookEntries.size());
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false); 
        lstPriceBookEntryPeriod[0].CurrencyIsoCode = 'JPY'; 
        insert lstPriceBookEntryPeriod;
        system.assertEquals(1, lstPriceBookEntryPeriod.size());
        
        List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstOrder, 1, true);
        List<OrderItem> lstMultiOrderReturnProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstMultiOrderReturn, 1, true);
        
        lstOrder[0].status = CRM_AppConstants.ORDER_STAGE_In_SAP;
        lstMultiOrderReturn[0].status = CRM_AppConstants.ORDER_STAGE_In_SAP;
        List<Order> tempList = new List<Order>{lstOrder[0],lstMultiOrderReturn[0]};
        update tempList;
        
        List<Order> childOrders = [Select Id,status From Order Where RecordTypeId = :CRM_RecordTypeUtil.RT_ORDER_RETURN];
        for(order o : childOrders){
        	o.status = CRM_AppConstants.ORDER_STAGE_In_SAP;
        }
        update childOrders;
        system.assertEquals(3, lstOrderProduct.size());
        
  }
  static testMethod void multiReturnOrderPositiveTest(){
        
        User u = createUser();
        
        Test.startTest();
        System.runAs(u) {
          createdata();
            // Create a new email and envelope object.
	        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
	        
	        List<Order> orderList = [Select Id,OrderNumber From Order Where Multi_Order__c != null]; 
	        
	        //Set Subject 
	        email.Subject = orderList[0].OrderNumber+'-'+'10.00 - Testing - InboundEmail';
	        
	        //Set Attachment
	        CRM_PDFAttachmentFromSAPToOrder  inboundEmail = new CRM_PDFAttachmentFromSAPToOrder();
	        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
	        attachment.body = Blob.valueof('Testing Inbound Email Setvice');
	        attachment.fileName = 'Testing Email Attachment.pdf';
	        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{attachment};
	        
	        // Call the CRM_PDFAttachmentFromSAPToOrder class and test it with the data in the test method.
	        Messaging.InboundEmailResult inboundResult = inboundEmail.handleInboundEmail(email,env);
	        system.assert(inboundResult.success);
	        
            List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :multiOrderReturnId];
            System.assertEquals(0,processInstances.size(),'Multi Order Return should not Submitted for Approval');
            //Assert LPFR Return Value is updated 
            system.assertEquals(10.00,[Select LPFR_Return_Value__C From Order Where Id =:orderList[0].Id].LPFR_Return_Value__C);
	        
            //Set Subject 
	        email.Subject = orderList[1].OrderNumber+'-'+'20.00 - Testing - InboundEmail';
	        
	        //Set Attachment
	        attachment = new Messaging.InboundEmail.BinaryAttachment();
	        attachment.body = Blob.valueof('Testing Inbound Email Setvice');
	        attachment.fileName = 'Testing Email Attachment.pdf';
	        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{attachment};
	        
	        // Call the CRM_PDFAttachmentFromSAPToOrder class and test it with the data in the test method.
	        inboundResult = inboundEmail.handleInboundEmail(email,env);
	        system.assert(inboundResult.success);
	        
            processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :multiOrderReturnId];
            System.assertEquals(1,processInstances.size(),'Multi Order Return should Submitted for Approval');
            
            //Assert LPFR Return Value is updated for Child Return Order
            system.assertEquals(20.00,[Select LPFR_Return_Value__C From Order Where Id =:orderList[1].Id].LPFR_Return_Value__C);
            
	        //Assert LPFR Return Value is updated for Multi Order Return
            system.assertEquals(30.00,[Select LPFR_Return_Value__C From Order Where Id =:multiOrderReturnId].LPFR_Return_Value__C);
            
        }
        Test.stopTest();
  }
  
  static testMethod void singalReturnOrderPositiveTest(){
        User u = createUser();
        Test.startTest();
        System.runAs(u) {
            createdata();
	        // Create a new email and envelope object.
	        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
	        
	        List<Order> orderList = [Select Id,OrderNumber From Order Where Multi_Order__c = null]; 
	              
	        //Set Subject 
	        email.Subject = orderList[0].OrderNumber+'-'+'10.00 - Testing - InboundEmail';
	        
	        // Call the CRM_PDFAttachmentFromSAPToOrder class and test it with the data in the test method.
	        CRM_PDFAttachmentFromSAPToOrder  inboundEmail = new CRM_PDFAttachmentFromSAPToOrder();
	        Messaging.InboundEmailResult inboundResult1 = inboundEmail.handleInboundEmail(email,env);
	        for(CRM_Error_Log__c errorMessage : [Select Message__c From CRM_Error_Log__c Where Functional_Module__c =: CRM_AppConstants.FUNCTIONAL_MODULE_PDF_FROM_SAP_TO_RETURNORDER limit 1]){
	            system.assert(errorMessage.Message__c.contains('PDF Attachment not found'));
	        }
	        
	        //Set Attachment
	        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
	        attachment.body = Blob.valueof('Testing Inbound Email Setvice');
	        attachment.fileName = 'Testing Email Attachment.pdf';
	        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{attachment};
	        
	        // Call the CRM_PDFAttachmentFromSAPToOrder class and test it with the data in the test method.
	        Messaging.InboundEmailResult inboundResult2 = inboundEmail.handleInboundEmail(email,env);
	        system.assert(inboundResult2.success);
        
            //Assert LPFR Return Value is updated 
            system.assertEquals(10.00,[Select LPFR_Return_Value__C From Order Where Id =:orderList[0].Id].LPFR_Return_Value__C);
	        //Assert Attachment added in Order
	        Integer attachmentCount = [Select Count() From Attachment Where parentId =: orderList[0].ID];
	        system.assertEquals(attachmentCount,1);
        }
        Test.stopTest();
  }
  
  
  /*
      @name handleInboundEmailNegativeTest(Negative Test)
      @param None
      @return None
      @throws None
      @see com.ac.sample.SuperObject#get
  */ 
  static testMethod void handleInboundEmailNegativeTest(){
       
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        
        // Call the CRM_PDFAttachmentFromSAPToOrder class and test it with the data in the test method.
        CRM_PDFAttachmentFromSAPToOrder inboundEmail = new CRM_PDFAttachmentFromSAPToOrder ();
        Messaging.InboundEmailResult inboundResult1 = inboundEmail.handleInboundEmail(email,env);
        
        //Set Subject 
        email.Subject = '0000123 - Testing - InboundEmail';
        
        //Set Attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = Blob.valueof('Testing Inbound Email Setvice');
        attachment.fileName = 'Testing Email Attachment';
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{attachment};
        Messaging.InboundEmailResult inboundResult2 = inboundEmail.handleInboundEmail(email,env);
        
        //Assert Attachment added in Order
        Integer attachmentCount = [Select Count() From Attachment];
        system.assertEquals(attachmentCount,0);
  }
  
  static user createUser(){
      list<user> userlist = new list<user>();
  		List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User manager = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'manager@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id
        );
        userlist.add(manager);
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true,
            ManagerId = manager.Id
        );
        userlist.add(testUser);
        User orderApprover = new User(
            FirstName = 'Order',
            LastName = 'Aprover User',
            Username = 'orderApprover@test.com',
            Email = 'orderApprover@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id
        );
        userlist.add(orderApprover);
        insert userlist;
        System.assert(testUser.Id != null, 'User should get created');
        return testUser;
  }
}