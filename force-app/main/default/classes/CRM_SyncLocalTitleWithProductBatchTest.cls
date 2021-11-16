@isTest(SeeAllData=false) 
public class CRM_SyncLocalTitleWithProductBatchTest{

    @testsetup
    public static void createTestData(){
        Integer recordToInseret = 120;
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        mainAccountForStoreFront[0].CurrencyISOCode = 'GBP';
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(new List<String>{'UK'}, 1, true);
        List<Language__c> lstLanguages = CRM_TestDataFactory.createLanguages(1, true);      
        
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(recordToInseret, true); //Name = 'TestTitle-' + index,
        
        List<Local_Title__c> lstLocalTitles = createLocalTitles(lstCountries, lstLanguages, recordToInseret);
        //List<Local_Title__c> lstLocalTitles = CRM_TestDataFactory.createLocalData(lstCountries, recordToInseret, false);
        Local_Title__c lt;
        for(Integer i = 0; i < lstLocalTitles.size(); i++){
            lt = lstLocalTitles[i];
            lt.Name = lstTitles[i].Name;
            lt.Title__c = lstTitles[i].Id;
        }
        insert lstLocalTitles;
        System.assertEquals(recordToInseret, [SELECT Id FROM Local_Title__c].size());
        
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, lstTitles, lstCountries, true);        

        Test.startTest();
        List<Commercial_Avail__c> lstReleasePlans = CRM_TestDataFactory.createReleasePlans(recordToInseret, lstTitles, storefronts, lstLocalTitles, lstCountries, lstLanguages, true);
        /*
        Commercial_Avail__c ca;
        for(Integer i = 0; i < lstReleasePlans.size(); i++){
            ca = lstReleasePlans[i];
            ca.Product__c = prds[i].Id;
        }
        insert lstReleasePlans;
        */
        Test.stopTest();
        List<Product2> prds = [SELECT Id FROM Product2 Where recordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL];
        System.debug('@@total-->'+prds.size());
        
        
        List<Product2> lstDigitalProducts = CRM_TestDataFactory.createProducts(recordToInseret, false); //objProduct.Name = 'Product ' + (index + 1);
        Product2 pd;
        for(Integer i = 0; i < lstDigitalProducts.size(); i++){
            pd = lstDigitalProducts[i];
            pd.Name = lstLocalTitles[i].Name;
            pd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            pd.Local_Title__c = lstLocalTitles[i].Id;           
            if(i <= 39){
                pd.Type__c = 'Video Digital';
            }else if(i >= 40 && i < 79){
                pd.Type__c = 'Games Digital';
            }else{
                pd.Type__c = 'Music Digital';
            }
            pd.Release_Plan__c = lstReleasePlans[i].Id;
        }
        insert lstDigitalProducts;
        
        
        List<Product2> prds1 = [SELECT Id FROM Product2 Where recordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL];
        System.debug('@@total1-->'+prds1.size());
        

        List<Product2> lstPhysicalProducts = CRM_TestDataFactory.createProducts(100, false);
        Product2 pd1;
        for(Integer i = 0; i < lstPhysicalProducts.size(); i++){
            pd1 = lstPhysicalProducts[i];           
            pd1.Local_Title__c = lstLocalTitles[i].Id;
            pd1.Name = lstLocalTitles[i].Name;
            pd1.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            pd1.Type__c = 'Video Physical';
        }
        insert lstPhysicalProducts;
        System.assertEquals(100, [SELECT Id FROM Product2 Where recordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL].size());        
    }
    
    public static testMethod void testLocalTitleAndProductWithSameName(){
    
        Test.startTest();
        CRM_SyncLocalTitleWithProductBatch batchInstance = new CRM_SyncLocalTitleWithProductBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id,Is_Product_Name_change_required__c FROM Product2 Where Is_Product_Name_change_required__c = true].size());
    }
    
    public static testMethod void testLocalTitleAndProductWithDifferentName(){
        
        List<Local_Title__c> lstLocalTitlesToUpdate = new List<Local_Title__c>();
        for(Local_Title__c lt: [Select Id,Name From Local_Title__c Limit 100]){
            lt.Name = lt.Name + '_Test';
            lstLocalTitlesToUpdate.add(lt);
        }
        update lstLocalTitlesToUpdate;

        Test.startTest();
        CRM_SyncLocalTitleWithProductBatch batchInstance = new CRM_SyncLocalTitleWithProductBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        System.assertEquals(0, [SELECT Id,Is_Product_Name_change_required__c FROM Product2 Where Is_Product_Name_change_required__c = true].size());
    }
    
    public static testMethod void testLocalTitleAndProductWithBlankFormatOrMarket(){
        Set<Id> prodIdSet = new Set<Id>();
        List<Product2> lstProductToUpdate = new List<Product2>();
        for(Product2 p: [Select Id,Name,Product_Market__c, Product_Format__c From Product2 Limit 50]){
            p.Product_Market__c = '';
            p.Product_Format__c = '';
            lstProductToUpdate.add(p);
            prodIdSet.add(p.Id);
        }
        update lstProductToUpdate;

        Test.startTest();
        CRM_SyncLocalTitleWithProductBatch batchInstance = new CRM_SyncLocalTitleWithProductBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        System.assertEquals(50, [SELECT Id From CRM_Error_Log__c Where Error_Record_Id__c in: prodIdSet].size());
    }
    
    public static testMethod void testPoductUpdateError(){
        Set<Id> prodIdSet = new Set<Id>();
        List<Product2> lstProductToUpdate = new List<Product2>();
        for(Product2 p: [Select Id,Name,ProductCode,Type__c,Release_Plan__c,Product_Market__c, Product_Format__c, Local_Title__c,Local_Title__r.Name,Is_Product_Name_change_required__c,CurrencyIsoCode From Product2 Limit 1]){
            p.CurrencyIsoCode = 'INR';
            lstProductToUpdate.add(p);
            prodIdSet.add(p.Id);
        }       

        Test.startTest();
        Database.BatchableContext BC;
        CRM_SyncLocalTitleWithProductBatch batchInstance = new CRM_SyncLocalTitleWithProductBatch();
        batchInstance.execute(BC, lstProductToUpdate);
        //Database.executeBatch(batchInstance);
        Test.stopTest();
        System.assertEquals(1, [SELECT Id From CRM_Error_Log__c Where Error_Record_Id__c in: prodIdSet].size());
    }
    
    public static List<Local_Title__c> createLocalTitles(List<Country__c> countries, List<Language__c> languages, Integer noOfRecords){
        List<Local_Title__c> localTitles = new List<Local_Title__c>();
    
        for(Integer index = 0 ; index < noOfRecords ; index++){    
            Local_Title__c objLocalData = new Local_Title__c();
            objLocalData.Name = 'Test ' + countries[0].Name;
            objLocalData.Country__c = countries[0].Id;
            objLocalData.Language__c = languages[0].Id;
            localTitles.add(objLocalData);
        }
        return localTitles;
    }
}