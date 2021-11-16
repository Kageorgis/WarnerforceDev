/**
@Author Accenture
@name CRM_UploadExtractCrdtNoteItem_POSD_Test
@CreateDate 16 Jan 2018
@Description Test class for CRM_UploadExtractCreditNoteItem_POSDeal
@Version <1.0>
@reference Requirement no 
*/

@isTest
private class CRM_UploadExtractCrdtNoteItem_POSD_Test {
    /**
*  Create Test Data. 
*  @name createTestData
*  @param None 
*  @return None
*  @throws None
*  @see com.ac.sample.SuperObject#get
*/
    public static List<Account> lstAccount;
    public static List<Opportunity> lstOpportunity;
    public static List<OpportunityLineItem> lstDealProductsWithOpportunities;
    
    public static void createTestData(User testUser,String command) {
        //Creating Account
        lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        insert lstAccount;
        System.assertEquals(1, lstAccount.size(), 'Account Created');

        System.runAs(testUser){
            //Creating Opportunity
            lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 3, false);
            Integer count = 0;
            for (Opportunity deal: lstOpportunity){
                deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
                deal.Start_Date__c = system.today();
                deal.Customer_Delivery_Date__c = system.today() + 1;
                deal.Promo_Start_Date__c = system.today() + 2;
                deal.Deal_Code__c = '123456789'+String.valueOf(count);
                count+=1;
            }
            insert lstOpportunity;
            System.assertEquals(3, lstOpportunity.size(), 'Opportunities Created');
            
            //Creating Product Group
            List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
            System.assertEquals(1, lstProductGroup.size(), 'Product Group Created');
            
            //Creating Product
            List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true);
            lstProduct[0].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_US_CODE;
            update lstProduct;
            System.assertEquals(1, lstProduct.size(), 'Product Created');
            
            //Creating PricebookEntry
            List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
            System.assertEquals(1, lstPriceBookEntries.size(), 'Pricebook Entries Created');
            CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct,1,true);
            
            //Creating Opportunity Line Item (Deal Products)*/ 
            if(command =='Activation'){
                lstDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstOpportunity, 10, false);
                
                for(integer i=0;i<lstDealProductsWithOpportunities.size();i++) {
                    lstDealProductsWithOpportunities[i].Reason__c = 'Display';
                    lstDealProductsWithOpportunities[i].POS_Rebate__c = 10;
                    lstDealProductsWithOpportunities[i].POS_Quantity__c = 2;
                    lstDealProductsWithOpportunities[i].POS_Forecast__c = 20;
                    lstDealProductsWithOpportunities[i].Co_op_Requested_Amount__c = 10;
                    lstDealProductsWithOpportunities[i].Co_op_Actual_Amount__c = 10;
                    lstDealProductsWithOpportunities[i].Customer_Reference__c = 'CR34378';
                    lstDealProductsWithOpportunities[i].Digital_Membership__c = 'DM34535';
                    lstDealProductsWithOpportunities[i].Start_date__c =lstOpportunity[0].Start_date__c;
                    lstDealProductsWithOpportunities[i].Comments__c = 'Testing Testing';
                    lstDealProductsWithOpportunities[i].End_date__c = lstOpportunity[0].CloseDate; 
                    //lstDealProductsWithOpportunities[i].PricebookEntryId = lstPriceBookEntries[0].Id;
                }
                lstDealProductsWithOpportunities[8].Co_op_Actual_Amount__c = 0;
                lstDealProductsWithOpportunities[7].Co_op_Actual_Amount__c = -100;
                insert lstDealProductsWithOpportunities; 
                System.assertEquals(30, lstDealProductsWithOpportunities.size(), 'Deal Products Created');   
            }
            
            for(Opportunity deal: lstOpportunity){
                deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update lstOpportunity;
            
            System.assertEquals(3, [Select Count() From Opportunity Where StageName = :CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED and id in: lstOpportunity], 'Committed Deals');
            List<Credit_Note__c> lstCredits =new List<Credit_Note__c>();
            Credit_Note__c objCreditNote = new Credit_Note__c();
            objCreditNote.CurrencyIsoCode = 'USD';
            objCreditNote.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_STANDARD;
            objCreditNote.PO_Number__c = 'CNPO Number';
            objCreditNote.Status__c = 'Planned'; // Status cannot be 'Ready To Pay' while creating CN
            objCreditNote.Amount__c = 100000;
            objCreditNote.Credit_Note_Type__c = 'ZMD';
            objCreditNote.account__c=lstAccount[0].id;
            insert objCreditNote;
            lstCredits.add(objCreditNote);
            System.assertEquals(1, [Select Count() From Credit_Note__c Where id in:lstCredits]);
        }
    }
    
    @isTest
    static void creditNoteGetItems_Test(){
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds =new List<Id>();
            List<OpportunityLineItem> dpList =new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_UploadExtractCreditNoteItem_POSDeal obj = new CRM_UploadExtractCreditNoteItem_POSDeal(scc);
            Boolean userLocale = obj.getUserLocaleForCSV();
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> returnWrapperList = CRM_UploadExtractCreditNoteItem_POSDeal.getCreditNoteLineItemTactics(cnn.id);
            system.assertEquals(30,returnWrapperList.size());
        }
        Test.stopTest();
    }
    
    @isTest
    static void creditNoteSetItems_Test(){
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds =new List<Id>();
            List<OpportunityLineItem> dpList =new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_UploadExtractCreditNoteItem_POSDeal obj = new CRM_UploadExtractCreditNoteItem_POSDeal(scc);
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> wrapperList  = CRM_UploadExtractCreditNoteItem_POSDeal.getCreditNoteLineItemTactics(cnn.id);
            for(CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper wrapper :wrapperList ){
                wrapper.coopActualAmt =123;
                wrapper.isRowModified =true;   
            }
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> returnWrapperList = CRM_UploadExtractCreditNoteItem_POSDeal.setCreditNoteLineItems(wrapperList,cnn.Id);
            String licenseKey = obj.getHandsonTable_Pro_Licencekey();
            Test.stopTest();
        }
    }
    
    @isTest
    static void creditNoteSetItemsValidation_Test(){
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds =new List<Id>();
            List<OpportunityLineItem> dpList =new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_UploadExtractCreditNoteItem_POSDeal obj = new CRM_UploadExtractCreditNoteItem_POSDeal(scc);
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> wrapperList  = CRM_UploadExtractCreditNoteItem_POSDeal.getCreditNoteLineItemTactics(cnn.id);
            for(CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper wrapper :wrapperList ){
                wrapper.coopActualAmt = -123;
                wrapper.isRowModified =true;   
            }
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> returnWrapperList = CRM_UploadExtractCreditNoteItem_POSDeal.setCreditNoteLineItems(wrapperList,cnn.Id);
            for(CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper wrapp :returnWrapperList){
                system.assertEquals('Invalid Amount. Negative amount cannot be inserted.', wrapp.validation);
            }
            Test.stopTest();
        }
    }
    @isTest
    static void creditNoteSetItemsDelValidation_Test(){
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds =new List<Id>();
            List<OpportunityLineItem> dpList =new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){ 
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
            CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
            CRM_UploadExtractCreditNoteItem_POSDeal obj1 = new CRM_UploadExtractCreditNoteItem_POSDeal(scc);
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> wrapperList  = CRM_UploadExtractCreditNoteItem_POSDeal.getCreditNoteLineItemTactics(cnn.id);
            
            for(CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper wrapper :wrapperList ){
                wrapper.isRowRemoved =true;   
            }
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> returnWrapperList = CRM_UploadExtractCreditNoteItem_POSDeal.setCreditNoteLineItems(wrapperList,cnn.Id);
            for(CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper wrapp :returnWrapperList){
                system.assertEquals('Ready to Pay/Paid/Failed/Rejected In SAP/Received In SAP Credit Note Can not be modified.', wrapp.validation);
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void creditNoteDeleteItems_Test(){
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds =new List<Id>();
            List<OpportunityLineItem> dpList =new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_UploadExtractCreditNoteItem_POSDeal obj = new CRM_UploadExtractCreditNoteItem_POSDeal(scc);
            obj.getUserLocale();
            obj.getUserDateFormat();
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> wrapperList  = CRM_UploadExtractCreditNoteItem_POSDeal.getCreditNoteLineItemTactics(cnn.id);
            for(CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper wrapper :wrapperList ){
                wrapper.isRowRemoved =true;   
            }
            Integer chunkSize = obj.getChunkSizeForCreditNoteItems();
            list<CRM_UploadExtractCreditNoteItem_POSDeal.CreditNoteItemWrapper> returnWrapperList = CRM_UploadExtractCreditNoteItem_POSDeal.setCreditNoteLineItems(wrapperList,cnn.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.Co_op_Reason__c = 'Display';
            update cnn;
            Opportunity opp = [Select Id FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name, Reason__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal__c":"'+opp.Id+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error1_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.Co_op_Reason__c = 'Display';
            update cnn;
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name, Reason__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"Feature","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error2_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.Co_op_Reason__c = 'Display';
            update cnn;
            Opportunity opp = [Select Id FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name, Reason__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+oppLineItem.Id+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error3_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.Co_op_Reason__c = 'Display';
            update cnn;
            
            Opportunity opp = new Opportunity();
            opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update opp;

            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name, Reason__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error4_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            insert lstAccount;
            
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.Co_op_Reason__c = 'Display';
            cnn.Account__c = lstAccount[0].Id;
            update cnn;
            
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name, Reason__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error5_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();        
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.Co_op_Reason__c = 'Display';
            update cnn;
            
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name, Reason__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            
            input = '[{"lineItem":{"Deal__c":"'+opp.Id+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error6_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL_REVERSE;
            cnn.Credit_Note_Type__c ='ZMD';
            update cnn;
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name,Reason__c,Co_op_Actual_Amount__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Requested_Co_op_Amount__c":"'+oppLineItem.Co_op_Actual_Amount__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    
    @isTest
    static void excelUploadPOSCreditNoteItem_Error7_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL_REVERSE;
            cnn.Credit_Note_Type__c ='ZMD';
            update cnn;
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name,Reason__c,Co_op_Actual_Amount__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id and Co_op_Actual_Amount__c = 0  LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Requested_Co_op_Amount__c":"'+oppLineItem.Co_op_Actual_Amount__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }

    @isTest
    static void excelUploadPOSCreditNoteItem_Error8_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL;
            cnn.Credit_Note_Type__c ='ZMC';
            update cnn;
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name,Reason__c,Co_op_Actual_Amount__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id and Co_op_Actual_Amount__c < 0  LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Requested_Co_op_Amount__c":"'+oppLineItem.Co_op_Actual_Amount__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 1);
        }
    }
    @isTest
    static void excelUploadPOSCreditNoteItem_NoError_Test(){
        List<String> outputList= new List<String>();
        createTestData(createUser(),'Activation');
        User u = [Select Id FROM User Where FirstName = 'Test' AND LastName = 'User' AND IsActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            cnn.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL;
            update cnn;
            Opportunity opp = [Select Id, Deal_Code__c FROM Opportunity LIMIT 1];
            OpportunityLineItem oppLineItem = [Select Id, Product_Code__c, Product2.Name,Reason__c,Co_op_Actual_Amount__c FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
            System.debug('oppLineItem = ' + oppLineItem);
            String input = '[{"lineItem":{"Deal_Code__c":"'+opp.Deal_Code__c+'","ProductCode__c":"'+oppLineItem.Product_Code__c+'","Requested_Co_op_Amount__c":"'+oppLineItem.Co_op_Actual_Amount__c+'","Product Name":"'+oppLineItem.Product2.Name+'","Reason__c":"'+oppLineItem.Reason__c+'","Customer_Reference_Number__c":"12345","Promo Start Date":"4/15/20","Promo End Date":"6/30/20","POS Quantity":"4","POS Rebate":"23"},"isRowModified":true,"isError":false}]';
            outputList = CRM_UploadExtractCreditNoteItem_POSDeal.excelUploadPOSCreditNoteItem(input, cnn.Id);
            System.debug('outputList = ' + outputList);
            Test.stopTest();
            
            System.assertEquals(outputList.size(), 0);
        }
    }

    static User createUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        
        Date d = System.today();
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
            ByPassValidationRule__c = true
        );
        return testUser;
    }
}