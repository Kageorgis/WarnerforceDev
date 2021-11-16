@isTest(seeAllData=false)
private class CRM_DigitalAssortments_Test {

    static Map<Integer, Pricebook2> mapPB = null;
    static List<Account> lstAccounts = null;
    static List <Product2> lstProds = null;
    static List <PricebookEntry> lstPricebookEntries;
    static List<Bundle__c> lstAssortments;
    static List<Assortment_Account__c> lstAssortmentAccounts;
    static List<Bundle_Product__c> lstAssortmentProducts;
    static Map<Id, Id> mapAccountPB = new Map<Id, Id>();
    static Map<Id, Set<Id>> mapPBProduct = new Map<Id, Set<Id>>();

   private static void createPricebooks() {
        Integer pbCount = 4;
        List <Pricebook2> lstPB = CRM_TestDataFactory.createPricebooks(pbCount, False);
        //List <Pricebook2> lstPB = CRM_TestDataFactory.createPricebooksForPBEP(pbCount, False,'Digital');
        lstPB[pbCount - 1].Name = 'PB - National';
        lstPB[pbCount - 1].External_Id__c = 'PB - National';
        insert lstPB;    //   lstPB ===> {PB1, PB2, PB3, PB - National}
                        
        List <Pricebook2> lstPBInsert = [SELECT Id, Name,Product_Type__c FROM Pricebook2];
        system.debug('lstPBInsert ----------'+lstPBInsert);
        system.assertEquals(pbCount, lstPBInsert.size());
        
        mapPB = new Map<Integer, Pricebook2>();
        for(Pricebook2 pb : lstPBInsert) {
            if(pb.Name.contains('National'))
                mapPB.put(0, pb);
            else if(pb.Name.contains('1'))
                mapPB.put(1, pb);
            else if(pb.Name.contains('2'))
                mapPB.put(2, pb);
            else if(pb.Name.contains('3'))
                mapPB.put(3, pb);
        }
        
        //mapPB ===> {{0, PB - National},{1, PB1},{2, PB2},{3, PB3}}
    }
    
    private static void createAccounts() {
        lstAccounts = CRM_TestDataFactory.createAccounts(3, false);
        Integer counter = 1;
        for(Account acc : lstAccounts) {
            acc.Name = 'Acc ' + counter;
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            acc.Price_Book__c = mapPB.get(counter++).Id;
        }
        insert lstAccounts;    //    lstAccounts ===> {Acc 1, Acc 2, Acc 3}
        
        List <Account> lstAccInsert = [SELECT Id, Name, Price_Book__c  FROM Account];
        system.assertEquals(3, lstAccInsert.size());
        
        for(Account acc : lstAccInsert){
            mapAccountPB.put(acc.Id, acc.Price_Book__c);
        } //    mapAccountPB ===> {{Acc 1 Id, PB1 Id}, {Acc 2 Id, PB2 Id}, {Acc 3 Id, PB3 Id}}
    }
    
    private static void createProducts() {
        lstProds = CRM_TestDataFactory.createProducts(20, true);//  lstProdInsert ===> {Product 1, Product 2, ... Product 20}
        //lstProds = CRM_TestDataFactory.createProducts(20, True); 
        List <Product2> lstProdInsert = [SELECT Id, Name,CurrencyIsoCode FROM Product2];
        system.assertEquals(20, lstProdInsert .size());
    }
    
    private static List <Product2> getProducts(Set<String> prodNames) {
        return [SELECT Id, Name,CurrencyIsoCode FROM Product2 Where Name in : prodNames];
    }
    
    private static Pricebook2 getPricebook(String name) {
        String query = 'SELECT Id, Name FROM Pricebook2 Where Name =\'' + name + '\'';
        Pricebook2 pb = Database.query(query);
        return pb;
    }
    
    private static void createStandardPriceBookEntries() {
        List<Product2> lstProducts = [SELECT Id, Name FROM Product2];
        CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        //CRM_TestDataFactory.createPriceBookEntries(lstProds, 1, true);
    }
    
    private static void createPriceBookEntries() {
        createStandardPriceBookEntries();
        lstPricebookEntries = new List<PricebookEntry>();
        List <Product2> lstProduct1 = getProducts(new Set<String> {'Product 1', 'Product 2', 'Product 3', 'Product 4', 'Product 5'});
        List <Product2> lstProduct2 = getProducts(new Set<String> {'Product 6', 'Product 7', 'Product 8', 'Product 9', 'Product 10'});
        List <Product2> lstProduct3 = getProducts(new Set<String> {'Product 11', 'Product 12', 'Product 13', 'Product 14', 'Product 15'});
        List <Product2> lstProduct4 = getProducts(new Set<String> {'Product 16', 'Product 17', 'Product 18', 'Product 19', 'Product 20'});
        List <Product2> lstProduct13 = new List<Product2>();
        lstProduct13.addAll(lstProduct1);
        //lstProduct13.addAll(lstProduct2);
        lstProduct13.addAll(lstProduct3);
        List <Product2> lstProduct24 = new List<Product2>();
        lstProduct24.addAll(lstProduct2);
        lstProduct24.addAll(lstProduct4);
        List <Product2> lstProduct1234 = new List<Product2>();
        lstProduct1234.addAll(lstProduct1);
        lstProduct1234.addAll(lstProduct2);
        lstProduct1234.addAll(lstProduct3);
        lstProduct1234.addAll(lstProduct4);
        List<PricebookEntry> lstPricebookEntries1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct13, 1, False);
        List<PricebookEntry> lstPricebookEntries2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct24, 1, False);
         
        Pricebook2 pb1 = getPricebook('PB1');
        Pricebook2 pb2 = getPricebook('PB2');
        Pricebook2 pb3 = getPricebook('PB3');
        Pricebook2 pbNational = getPricebook('PB - National');
        
        List<Pricebook2> pb = [SELECT Id, Name FROM Pricebook2];
        
        mapPB = new Map<Integer, Pricebook2>();
        Integer counter = 0; 
        for(Pricebook2 p:pb){
            mapPB.put(counter,p);
            counter++;
        }
        lstPricebookEntries.addAll(changePricebook(lstPricebookEntries1, pb1));
        lstPricebookEntries.addAll(changePricebook(lstPricebookEntries2, pb2));
       
        insert lstPricebookEntries;
        
        //  PB1 ===> Prod 1, ... Prod 5, Prod 11,... Prod 15
        //  PB2 ===> Prod 6, ... Prod 10, Prod 11,... Prod 15
        //  PB3 ===> Prod 16, ... Prod 20,
        
        List <PricebookEntry> lstPBEInsert = [SELECT Id, Name, Pricebook2Id, Product2Id FROM PricebookEntry];
        system.assertEquals(40, lstPBEInsert.size());
        system.debug('lstPBEInsert -------------------'+lstPBEInsert);
        for(PricebookEntry pbe : lstPBEInsert){
            Set<Id> setProd = mapPBProduct.get(pbe.Pricebook2Id);
            if(setProd == null)
                setProd = new Set<Id>();
                
            setProd.add(pbe.Product2Id);    
            mapPBProduct.put(pbe.Pricebook2Id, setProd);  
        }
        
        //  mapPBProduct ===> {PB1 Id, {Prod 1, ... Prod 5, Prod 11,... Prod 15}, ...}
        
        Date startDate1 = Date.Today().addMonths(-6);
        Date endDate1 = Date.Today().addMonths(-3);
        Date startDate2 = Date.Today().addMonths(-3).addDays(1);
        Date endDate2 = Date.Today().addMonths(3);
        Date startDate3 = Date.Today().addMonths(3).addDays(1);
        Date endDate3 = Date.Today().addMonths(24);
        
        //  If Current Date = 9/13/2017
        //  startDate1 = 3/13/2017
        //  endDate1 = 6/13/2017
        //  startDate2 = 6/14/2017
        //  endDate2 = 12/13/2017
        //  startDate3 = 12/14/2017
        //  endDate3 = 9/13/2019
        //  getRandomPrice => Any number between 11 and 20 
        
        List<Pricebook_Entry_Period__c> lstPBEPs = new List<Pricebook_Entry_Period__c> ();
        
        
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct1,2,false));
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct2,2,false));
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct13, pb1, startDate3, endDate3, getRandomPrice()));
        
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct24, pb2, startDate1, endDate1, getRandomPrice()));
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct24, pb2, startDate2, endDate2, getRandomPrice()));
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct24, pb2, startDate3, endDate3, getRandomPrice()));
        
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct4, pb3, startDate1, endDate1, getRandomPrice()));
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct4, pb3, startDate2, endDate2, getRandomPrice()));
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct4, pb3, startDate3, endDate3, getRandomPrice()));
        
        lstPBEPs.addAll(CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct1234, pbNational, startDate1, endDate3, getRandomPrice()));
        
        insert lstPBEPs;
        
        List <Pricebook_Entry_Period__c> lstPBEPInsert = [SELECT Id, Name FROM Pricebook_Entry_Period__c];
        system.assertEquals(95, lstPBEPInsert.size());
    }
    
    private static List<PricebookEntry> changePricebook(List<PricebookEntry> lstPricebookEntries, Pricebook2 pb) {
        for(PricebookEntry pbe : lstPricebookEntries) {
            pbe.Pricebook2Id = pb.Id;
        }
        return lstPricebookEntries;
    }
    
    private static Double getRandomPrice() {
        return Math.floor((Math.random() * (20-11)) + 11);
    }
    
    private static void createAssortments() {
        lstAssortments = CRM_TestDataFactory.createBundles(1, false);
        //lstAssortments[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
        lstAssortments[0].Name = 'Test Assortment';
        lstAssortments[0].RecordTypeId = CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortments[0].Promo_Start_Date__c = Date.today().addDays(1);
        lstAssortments[0].Promo_End_Date__c = Date.today().addDays(30);
        lstAssortments[0].Start_Date__c = Date.today().addDays(1);
        lstAssortments[0].Automatically_Add_Products__c = True;
        lstAssortments[0].Assortment_Status__c = 'Active';
        lstAssortments[0].Price_Book__c = mapPB.get(0).Id;  //  National Pricebook
        insert lstAssortments;  //  lstAssortments ===> {Test Assortment{PB = PB - National}}
        
        List <Bundle__c> lstAssortmentInsert = [SELECT Id, Name, Assortment_Status__c,Price_Book__r.Product_Type__c FROM Bundle__c];
        system.assertEquals(1, lstAssortmentInsert.size());
        system.assertEquals('Active', lstAssortmentInsert[0].Assortment_Status__c );
        
        
        lstAssortmentAccounts = new List<Assortment_Account__c>();
        for (Account acc : lstAccounts) {
            if(acc.name.contains('1') || acc.name.contains('2')) {
                system.debug('test assortment account -------------');
                Assortment_Account__c bAcc = new Assortment_Account__c();
                bAcc.Assortment__c = lstAssortments[0].Id;
                bAcc.Account__c = acc.Id;
                lstAssortmentAccounts.add(bAcc);
            }
        }

        insert lstAssortmentAccounts;
        //  lstAssortmentAccounts ===> {Test Assortment - Acc 1, Test Assortment - Acc 2, Test Assortment - Acc 3}
        
        List <Assortment_Account__c> lstAssortmentAccountInsert = [SELECT Id, Name FROM Assortment_Account__c];
        system.assertEquals(2, lstAssortmentAccountInsert.size());
        
        lstAssortmentProducts = new List<Bundle_Product__c>();

        for (Product2 prod : lstProds) {
            Bundle_Product__c bProd = new Bundle_Product__c();
            bProd.Bundle__c = lstAssortments[0].Id;
            bProd.Product__c = prod .Id;
            bProd.List_Price__c = 20;
            bProd.Assortment_Price__c = 10;
            
            lstAssortmentProducts.add(bProd);
        }
        
        insert lstAssortmentProducts;
        //  lstAssortmentProducts ===> {Test Assortment - Product 1, Test Assortment - Product 2, ..., Test Assortment - Product 20}
        
        List <Bundle_Product__c> lstAssortmentProductInsert = [SELECT Id, Name FROM Bundle_Product__c];
        system.assertEquals(20, lstAssortmentProductInsert.size());
    }
    
    private static void setupData() {
        createPricebooks(); //  creates 3 pricebooks
        createAccounts();   //  creates 3 accounts
        createProducts();   //  creates 20 products
        createPriceBookEntries();  //creates PBE in standard and 3 custom pricebooks, along with PBEPs for 3 pricebooks
        createAssortments();    //  creates 1 assortment, 3 assortment accounts, 20 assortment products
    }
    
    static testMethod void testPublishAssortment() {
        setupData();
        Test.startTest();
        
        Apexpages.StandardController stdCon = new Apexpages.StandardController(lstAssortments[0]);
        CRM_PublishAssortmentsController controller = new CRM_PublishAssortmentsController(stdCon);
        system.debug('mapPB --------------------'+mapPB.get(0).Id+'mapPBProduct ---'+mapPBProduct.get(mapPB.get(0).Id));
        CRM_PublishAssortmentsController.publishAssortment(lstAssortments[0].Id);
        Test.stopTest();
        
        List <Opportunity> lstDeals = [SELECT Id, Name, AccountId, (Select Id, Name, OpportunityId, Product2Id From OpportunityLineItems) FROM Opportunity];
        system.assertEquals(2, lstDeals.size());
        
        Set<Id> setPB3Prods = mapPBProduct.get(mapPB.get(0).Id);

        for(Opportunity deal : lstDeals) {  //  iterate over created deals
            system.assertNotEquals(null,deal.AccountId);
            Set<Id> setProd = mapPBProduct.get(mapAccountPB.get(deal.AccountId));   //  get set of products from deal=>account=>pricebook
            for(OpportunityLineItem dealProd : deal.OpportunityLineItems) {
                system.assertEquals(True, setProd.contains(dealProd.Product2Id));   //  compare deal product with corresponding PB products
                system.assertNotEquals(True, setPB3Prods.contains(dealProd.Product2Id));    //  compare deal product with PB3 products
            }
        }
    }

}