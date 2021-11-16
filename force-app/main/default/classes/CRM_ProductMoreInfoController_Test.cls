/**
   @Author Cognizant
   @name CRM_ProductMoreInfoController_Test
   @CreateDate 11 Dec 2015
   @Description Test class for CRM_ProductMoreInfoController
   @Version <1.0>
   @reference Requirement no 04, 13
  */

@isTest(SeeAllData=false)
private class CRM_ProductMoreInfoController_Test{
    
   /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */


    static void createTestData() {
        List<Account> accts = CRM_TestDataFactory.createAccounts(1, false);   
        accts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        insert accts;
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true); 
        List<PricebookEntry> priceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> pbentryperiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        List<Opportunity> opportunities = CRM_TestDataFactory.createOpportunitiesWithAccounts(accts, 1,true); 
        for (Opportunity opp : opportunities) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS;
        }
        update opportunities;
        List<OpportunityLineItem> opportunitiesLineItem = CRM_TestDataFactory.createDealProductsWithOpportunities(priceBookEntries, opportunities, 1, true);  
        List<Bundle__c> bundle = CRM_TestDataFactory.createBundles(1, true);
        List<Order> order = CRM_TestDataFactory.createOrders(accts, 1, true);
        //CRM_TestDataFactory.createOpportunitySchedule(opportunitiesLineItem, 2, true);
        List<Account_Product__c> accProd = CRM_TestDataFactory.createAccountProduct(accts, lstProduct, false);
        accProd[0].External_Id__c ='6000-10-12004756-1000544943';
        insert accProd;
    }
    
 
    
   
    
    static testMethod void orderHistory(){
       createTestData();
       User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        //System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
        //System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);
        
        String accountID = System.currentPageReference().getParameters().put('accountID', [Select ID FROM Account][0].ID);
        Integer year = 5;  
        Boolean allCustomers = true;
        //String condition = 'OpportunityLineItem.Opportunity.AccountID =: accountID';
        List<AggregateResult> currentResult= [SELECT OpportunityLineItem.Opportunity.RecordTypeID RecType,calendar_month(ScheduleDate) monthNum, SUM(OpportunityLineItem.Actual_Revenue__c) actRev
                          From OpportunityLineItemSchedule 
                          WHERE OpportunityLineItem.Opportunity.AccountID =: accountID AND (OpportunityLineItem.Opportunity.RecordTypeID =: CRM_RecordTypeUtil.RT_DEAL_ACTUALS
                          OR OpportunityLineItem.Opportunity.RecordTypeID =: CRM_RecordTypeUtil.RT_DEAL_POS_ACTUALS) 
                          AND calendar_year(ScheduleDate) =: year  
                          GROUP BY OpportunityLineItem.Opportunity.RecordTypeID, calendar_month(ScheduleDate) 
                          LIMIT 50000];
       Integer revenue;
       Id prodId = [Select ID FROM Product2][0].ID;
       
       //CRM_ProductMoreInfoController moreinfo = new CRM_ProductMoreInfoController();
       CRM_ProductMoreInfoController.getOrderHistory(year,accountID,prodId,allCustomers);
       for(AggregateResult agg : currentResult){
           revenue = Integer.valueOf(agg.get('actRev'));
       System.debug('revenue==> ' + revenue);    
       System.debug('actRev==> ' + Integer.valueOf(agg.get('actRev')));
       System.assertEquals(56, Integer.valueOf(agg.get('actRev')));
       System.assertEquals(2, Integer.valueOf(agg.get('calMonth')));
       }
                   

        
    } 
    
    static testMethod void StockLevel(){
      createTestData();
      User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
      
      Id productID = System.currentPageReference().getParameters().put('productID', [Select ID FROM Product2][0].ID); 
      System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
      System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);  
      
      CRM_ProductMoreInfoController moreinfo = new CRM_ProductMoreInfoController();
      moreinfo.getStockLevel(productID);
      
      System.assert(moreinfo.productInformation.product != null, 'Product Information Should not be Empty');
      System.assertEquals(12,[SELECT Stock_Level__c FROM Account_Product__c][0].Stock_Level__c);
      
      
    }
    
    
    /*static testMethod void SimilarTitles(){
      createTestData();
      User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
      
      Id productID = System.currentPageReference().getParameters().put('productID', [Select ID FROM Product2][0].ID); 
      System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
      System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);  

      CRM_ProductMoreInfoController.getTitles(productID);
      CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
      System.assert(controllerInstance.productInformation.product != null, 'Product Information Should not be Empty');

    }*/
    
    static testMethod void years(){
       
       createTestData();
       Id prodId = [Select ID FROM Product2][0].ID;
       User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
       String accountID = System.currentPageReference().getParameters().put('accountID', [Select ID FROM Account][0].ID); 
       Boolean allCustomers = true;
       Integer year = 5;
       List<AggregateResult> opp = [SELECT ID,calendar_year(ScheduleDate) calYear FROM OpportunityLineItemSchedule GROUP BY ID,calendar_year(ScheduleDate) LIMIT 1];
       CRM_ProductMoreInfoController.getYears(accountID,prodId,allCustomers);
       
       
       for(AggregateResult agg : opp){
        System.assertEquals('2016',String.valueOf(agg.get('calYear')));
       }
    }
   
   
    /**
    *  Test 1: Test Product Pop Up For Deal Product. 
    *  @name dealPopup
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */ 
    static testMethod void dealPopup() {
        createTestData();
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_ProductMoreinfo')); 
            
            System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
            System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);
            System.currentPageReference().getParameters().put('accountID', [Select ID FROM Account][0].ID);
            //System.currentPageReference().getParameters().put('year', [Select ID FROM Account][0].ID);
            
            CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
            
            System.assert(controllerInstance.productInformation.product != null, 'Product Information Should not be Empty');
        }
    }
    
    /**
     *  Test 2: Test Product Pop Up For Order Product. 
     *  @name orderPopup
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */

    static testMethod void orderPopup() {
        createTestData();
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_ProductMoreinfo')); 
            
            System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM order][0].ID);
            System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);
            System.currentPageReference().getParameters().put('accountID', [Select ID FROM Account][0].ID);
            
            CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
            
            System.assert(controllerInstance.productInformation.product != null, 'Product Information Should not be Empty');
        }
    }
    
    /**
     *  Test 3: Test Product Pop Up For Bundle Product. 
     *  @name bundlePopup
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */

    static testMethod void bundlePopup() {
        createTestData();
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_ProductMoreinfo')); 
            
            System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Bundle__c][0].ID);
            System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);
            System.currentPageReference().getParameters().put('accountID', [Select ID FROM Account][0].ID);
            
            CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
            
            System.assert(controllerInstance.productInformation.product != null, 'Product Information Should not be Empty');
        }
    }
    
    /**
     *  Test 4: Test Product Pop Up For Deal Product with file discount. 
     *  @name dealPopupWithDiscount
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */

    static testMethod void dealPopupWithDiscount() { 
        createTestData();
        
        Pricebook_Entry_Period__c currentDiscount = [SELECT ID FROM Pricebook_Entry_Period__c Limit 1];
        currentDiscount.Start_Date__c = Date.today() - 3;
        update currentDiscount;
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        System.runAs(u) {       
            Test.setCurrentPageReference(new PageReference('Page.CRM_ProductMoreinfo')); 
            
            System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
            System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);
            System.currentPageReference().getParameters().put('accountID', [Select ID FROM Account][0].ID);
             
            CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
            
            System.assert(controllerInstance.productInformation.product != null, 'Product Information Should not be Empty');
        }
    }
    
    /**
     *  Test 5: Test Product Pop Up For Deal Product when product is out of stock. 
     *  @name outOfStockPopup
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */

    static testMethod void outOfStockPopup() {
        createTestData();
        
            Delete [Select ID FROM Account_Product__c];
            Product2 currentProduct = [SELECT ID FROM Product2 Limit 1];
            //currentProduct.Items_in_Stock__c = 0; 
            update currentProduct;
            
            User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
            
            System.runAs(u) {
                Test.setCurrentPageReference(new PageReference('Page.CRM_ProductMoreinfo')); 
                
                System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
                System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);
                
                CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
                
                System.assert(controllerInstance.productInformation.product != null, 'Product Information Should not be Empty');
            }
    }
    
    /**
     *  Test 6: Test Product Pop Up for Invalid Scenario. 
     *  @name negativeTest
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */
    static testMethod void negativeTest() {
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_ProductMoreinfo')); 
            
            Id dealOrOrderID = System.currentPageReference().getParameters().put('dealOrOrderID',[SELECT ID FROM Opportunity][0].ID); 
            String priceBookEntryID = System.currentPageReference().getParameters().put('priceBookEntryID',[Select ID FROM PricebookEntry][0].ID);
             
            CRM_ProductMoreInfoController controllerInstance = new CRM_ProductMoreInfoController();
            
            try{
               controllerInstance.getPriceBookEntry(null); 
            }
            catch(Exception e){
                 System.assertEquals('List has no rows for assignment to SObject',e.getMessage());
            }
            /*controllerInstance.productInformation.similarTitlesJSON = '';
            controllerInstance.productInformation.customerLastOrderDate = ''; 
            controllerInstance.productInformation.customerLastOrderVolume = 0;
            controllerInstance.productInformation.orderHistoryJSON = '';
            CRM_ProductMoreInfoController.getTitles([Select ID FROM Product2][0].ID);*/
            
           
            
        }
      } 
    
    
    /**
     *  Test 7: Show Talent info For Product
     *  @name showTalentInfoForProduct_Test
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */
    static testMethod void showTalentInfoForProduct_Test() {
        
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
      
        Id productID = System.currentPageReference().getParameters().put('productID', [Select ID FROM Product2][0].ID); 
        System.currentPageReference().getParameters().put('dealOrOrderID', [Select ID FROM Opportunity][0].ID);
        System.currentPageReference().getParameters().put('priceBookEntryID', [Select ID FROM PricebookEntry][0].ID);  
        
        List<Account> accts = CRM_TestDataFactory.createAccounts(1, false);   
        accts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        insert accts;
        
        List<Talent__c> talents = new List<Talent__c>();
        for(integer i=0; i<5 ; i++){
            Talent__c talentRec = new Talent__c();
            talentRec.Name = 'Test Talent Record - '+i;
            talentRec.Talent_Id__c = 'Test '+i;
            talents.add(talentRec);
        }
        insert talents;
        
        MPM__c mpmRec = new MPM__c();
        mpmRec.name = '2071869';
        mpmRec.MPM_Number__c = '123456';
        insert mpmRec;
        
        List<MPM_Talent__c> mpmTalents = new List<MPM_Talent__c>();
        for(integer i=0; i<5 ; i++){
            MPM_Talent__c mpmTal = new MPM_Talent__c();
            mpmTal.MPM__c = mpmRec.Id;
            mpmTal.Talent__c = talents[i].Id;
            mpmTal.Character__c = 'Char - '+i;
            mpmTal.Role__c = 'Actor';
            mpmTal.Credit_Sequence__c = i;
            mpmTal.Key__c = 'Test MPM '+i;
            mpmTalents.add(mpmTal);
        }
        insert mpmTalents;
        
        CRM_ProductMoreInfoController ctrl = new CRM_ProductMoreInfoController();
        ctrl.MPMId = mpmRec.Id;
        List<MPM_Talent__c> listOfMPMTalents = ctrl.getMPMTalentInfo();
        system.assertEquals(listOfMPMTalents.size(),5,'Five MPM Talent records');
      } 
    
}