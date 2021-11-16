/**
   @Author Cognizant Team
   @name CRM_GenerateAssortementAccount_Test  
   @CreateDate 
   @Description Test class for CRM_GenerateAssortementAccount_Test 
   @Version <1.0>
   @reference Requirement no 237
  */
@isTest
private class CRM_GenerateAssortementAccount_Test {

    /**
     *  Test Method to Create New Assortment Account
     *  @name createAssortmentAccountTest
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void createAccountPlanTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
        
            Account acc = New Account();
            acc.Name = 'WB Account';
            acc.Price_Book__c = System.Test.getStandardPricebookId();
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acc;
            system.assertNotEquals(null, acc.id);
            
            Account acc1 = New Account();
            acc1.Name = 'WB Account New';
            acc1.Price_Book__c = System.Test.getStandardPricebookId();
            acc1.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acc1;
            system.assertNotEquals(null, acc1.id);
        
            Target_Split_Template__c targetspiltTmp = new Target_Split_Template__c();
            targetspiltTmp.Name = 'Test Target Split template';
            insert targetspiltTmp;
            system.assertNotEquals(null, targetspiltTmp.id);
            
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acc.Id;
            acctSplit.Share__c = 25;
            acctSplit.Target_Split_Template__c = targetspiltTmp.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id);
            
            Account_Split__c acctSplit1 = new Account_Split__c();
            acctSplit1.Account__c = acc1.Id;
            acctSplit1.Share__c = 35;
            acctSplit1.Target_Split_Template__c = targetspiltTmp.Id;
            insert acctSplit1;
            system.assertNotEquals(null, acctSplit1.id);
            
            Bundle__c assortment = new Bundle__c ();
            assortment.Name = 'Test Assortment';
            assortment.Account_Split_Template__c = targetspiltTmp.Id;
            assortment.End_Date__c = system.today().adddays(1);
            assortment.Start_Date__c = system.today();
            insert assortment;
            system.assertNotEquals(null, assortment.id);
            
            list<Assortment_Account__c> lstAssAccount = new list<Assortment_Account__c>([Select id,Share__c,account__c from Assortment_Account__c]);
            system.debug('======>>>>>>'+lstAssAccount );
            system.assertEquals(2,lstAssAccount.size());
            for(Assortment_Account__c assacc : lstAssAccount ){
                if(assacc.account__c == acc.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
                if(assacc.account__c == acc1.Id){
                    system.assertEquals(35,assacc.Share__c);
                }
            }
        }
    }
    
    /**
     *  create Test Data to insert the Account plan where accounts are not matching and update existing where Account gets match
     *  @name upsertAccountPlanTest
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void upsertAccountPlanTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'bassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser1@testorg.com');
        system.runAs(testUser){
            
            /*Account Creation*/
            Account acct = New Account();
            acct.Name = 'WB Account test';
            acct.Price_Book__c = System.Test.getStandardPricebookId();
            acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct;
            system.assertNotEquals(null, acct.id);
        
            Account acct1 = New Account();
            acct1.Name = 'Amazone Account';
            acct1.Price_Book__c = System.Test.getStandardPricebookId();
            acct1.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct1;
            system.assertNotEquals(null, acct1.id);
            
            Account acct2 = New Account();
            acct2.Name = 'WB Bros Test Account';
            acct2.Price_Book__c = System.Test.getStandardPricebookId();
            acct2.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct2;
            system.assertNotEquals(null, acct2.id);
        
            /*Target Split template*/
            Target_Split_Template__c targetspiltTmp1 = new Target_Split_Template__c();
            targetspiltTmp1.Name = 'Test Target Split template';
            insert targetspiltTmp1;
            system.assertNotEquals(null, targetspiltTmp1.id);
            
            /*Account Splits related to Target Split Templates*/ 
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acct1.Id;
            acctSplit.Share__c = 25;
            acctSplit.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id);
        
            Account_Split__c acctSplit2 = new Account_Split__c();
            acctSplit2.Account__c = acct2.Id;
            acctSplit2.Share__c = 25;
            acctSplit2.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit2;
            system.assertNotEquals(null, acctSplit2.id);
            
            /*Assortment Account*/
            Bundle__c assortment = new Bundle__c();
            assortment.Name = 'Test New Assortment';
            assortment.End_Date__c = system.today().adddays(1);
            assortment.Start_Date__c = system.today();
            insert assortment;
            system.assertNotEquals(null, assortment.id);
        
            Assortment_Account__c assAcct = New Assortment_Account__c();
            assAcct.Assortment__c = assortment.Id;
            assAcct.Share__c = 10;
            assAcct.Account__c = acct1.id;
            insert assAcct;
            system.assertNotEquals(null, assAcct.id);
            
            assortment.Account_Split_Template__c = targetspiltTmp1.Id;
            update assortment;
            
            list<Assortment_Account__c> lstAssAccount = new list<Assortment_Account__c>([Select id,Share__c,account__c from Assortment_Account__c]);
            system.debug('======>>>>>>'+lstAssAccount);
            system.assertEquals(2,lstAssAccount.size());
            for(Assortment_Account__c assacc : lstAssAccount ){
                if(assacc.account__c == acct1.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
                if(assacc.account__c == acct2.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
            }
        }
    }
    
    /**
     *  create Test Data to insert the Account plan where accounts are not matching and update existing where Account gets match
     *  @name upsertAccountPlanTest
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void updateAccountPlanTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'bassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser1@testorg.com');
        system.runAs(testUser){
            
            /*Account Creation*/
            Account acct = New Account();
            acct.Name = 'WB Account test';
            acct.Price_Book__c = System.Test.getStandardPricebookId();
            acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acct.Planning_Customer__c = true;
            insert acct;
            system.assertNotEquals(null, acct.id);
            
            Account acct1 = New Account();
            acct1.Name = 'Amazone Account';
            acct1.Price_Book__c = System.Test.getStandardPricebookId();
            acct1.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct1;
            system.assertNotEquals(null, acct1.id);
            
            Account acct2 = New Account();
            acct2.Name = 'WB Bros Test Account';
            acct2.Price_Book__c = System.Test.getStandardPricebookId();
            acct2.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct2;
            system.assertNotEquals(null, acct2.id);
        
            Account acct3 = New Account();
            acct3.Name = 'WB test Account';
            acct3.Price_Book__c = System.Test.getStandardPricebookId();
            acct3.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct3;
            system.assertNotEquals(null, acct3.id);
            
            /*Target Split template*/
            Target_Split_Template__c targetspiltTmp1 = new Target_Split_Template__c();
            targetspiltTmp1.Name = 'Test Target Split template';
            insert targetspiltTmp1;
            system.assertNotEquals(null, targetspiltTmp1.id);
            
            /*Account Splits related to Target Split Templates*/ 
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acct1.Id;
            acctSplit.Share__c = 25;
            acctSplit.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id);
        
            Account_Split__c acctSplit2 = new Account_Split__c();
            acctSplit2.Account__c = acct2.Id;
            acctSplit2.Share__c = 25;
            acctSplit2.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit2;
            system.assertNotEquals(null, acctSplit2.id);
            
            /*Target Split template*/
            Target_Split_Template__c targetspiltTmp2 = new Target_Split_Template__c();
            targetspiltTmp2.Name = 'Test Target Split template';
            insert targetspiltTmp2;
            system.assertNotEquals(null, targetspiltTmp2.id);
            
            /*Account Splits related to Target Split Templates*/ 
            Account_Split__c acctSplit3 = new Account_Split__c();
            acctSplit3.Account__c = acct.Id;
            acctSplit3.Share__c = 25;
            acctSplit3.Target_Split_Template__c = targetspiltTmp2.Id;
            insert acctSplit3;
            system.assertNotEquals(null, acctSplit3.id);
        
            Account_Split__c acctSplit4 = new Account_Split__c();
            acctSplit4.Account__c = acct3.Id;
            acctSplit4.Share__c = 25;
            acctSplit4.Target_Split_Template__c = targetspiltTmp2.Id;
            insert acctSplit4;
            system.assertNotEquals(null, acctSplit4.id);
            
            /*Assortment Account*/
            Bundle__c assortment = new Bundle__c();
            assortment.Name = 'Test New Assortment';
            assortment.Account_Split_Template__c = targetspiltTmp1.Id;
            assortment.End_Date__c = system.today().adddays(1);
            assortment.Start_Date__c = system.today();
            insert assortment;
            system.assertNotEquals(null, assortment.id);
            
            
            List<Account> lstAccounts = new List<Account>();
            lstAccounts.add(acct);
            
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
            for(Opportunity opty: lstOpportunity) { 
                opty.Bundle__c = assortment.Id;
                opty.UniquePublishkey__c = assortment.Id + '-' + acct1.Id;
            }
            insert lstOpportunity;
            
            list<Assortment_Account__c> lstAssAccount = new list<Assortment_Account__c>([Select id,Share__c,account__c from Assortment_Account__c]);
            system.debug('##lstAssAccount'+lstAssAccount);
            system.assertEquals(2,lstAssAccount.size());
            for(Assortment_Account__c assacc : lstAssAccount ){
                if(assacc.account__c == acct1.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
                if(assacc.account__c == acct2.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
            }           
            
            Test.StartTest();
            
            //update Account_Split_Template__c on Assortment
            assortment.Account_Split_Template__c = targetspiltTmp2.Id;
            update assortment;
            
            Test.StopTest();
                        
            list<Assortment_Account__c> lstAssAccount2 = new list<Assortment_Account__c>([Select id,Share__c,account__c from Assortment_Account__c]);
            system.debug('###lstAssAccount2'+lstAssAccount2);
            system.assertEquals(2,lstAssAccount2.size());
            for(Assortment_Account__c assacc : lstAssAccount2 ){
                if(assacc.account__c == acct1.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
                if(assacc.account__c == acct2.Id){
                    system.assertEquals(25,assacc.Share__c);
                }
            }        
            
            Opportunity opty = [Select Id, StageName from Opportunity where Id =: lstOpportunity[0].Id limit 1];
            system.assertEquals('Cancelled',opty.StageName);
        }
    }   
    /**
     *  create Test Data to update the Assortment Products 
     *  @name updateAssotmentAccounts
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void updateAssotmentProductsTest(){  
        Id soldToRecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        accounts[0].recordTypeId = soldToRecordTypeId;
        insert accounts;
            
        //create bundle
        List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(2, false);
        lstBundles[0].CurrencyIsoCode = 'EUR';
        lstBundles[1].CurrencyIsoCode = 'EUR';
        lstBundles[0].End_Date__c = system.today()+30;
        lstBundles[1].End_Date__c = system.today()+30;
		lstBundles[0].Automatically_Add_Products__c = false;
		lstBundles[1].Automatically_Add_Products__c = false;
        insert lstBundles;
        system.debug('===lstBundles=created=='+lstBundles);
		
		List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 3, false);
        products[0].productCode= 'code1';
        products[0].Universal_Picture_Code__c ='upc1';
        products[1].productCode='code2';
        products[1].Universal_Picture_Code__c='upc2';
        products[2].productCode='code3';
        products[2].Universal_Picture_Code__c='upc3';
        insert products; 
		
		List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstBundles, products, 1, true);
        system.assertEquals(6,lstBundlesProduct.size());		
        
		Test.StartTest();            
        //update Automatically_Add_Products__c on Assortment
        lstBundles[0].Automatically_Add_Products__c = true;
        update lstBundles[0];            
        Test.StopTest();
		
		system.assertEquals(3,[select count() from Bundle_Product__c where Bundle__c =: lstBundles[0].Id AND Automatically_Add_Product__c = true]);
    } 
    
    //US : 801 : Account Split Change
    static void CreateDataForAutomaticallySplitToShipToTest() {
      List<Account> lstSoldToAccounts = CRM_TestDataFactory.createAccounts(3,true);
        List<Account> lstAllAccounts = new List<Account>();
        for (Account soldToAcc : lstSoldToAccounts) {
            soldToAcc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            soldToAcc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            
            integer i = 0;
            List<Account> lstShipToAccounts = CRM_TestDataFactory.createAccounts(5,true);
          for (Account shipToAcc : lstShipToAccounts) {
              i++;
              if (shipToAcc.Games_Physical__c) {
                  shipToAcc.Games_Physical__c = false;
              }
              shipToAcc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
              shipToAcc.Sold_To_Customer__c = soldToAcc.Id;
              if(i < 4){
                shipToAcc.Account_Split_Share__c = 20;
              }
              shipToAcc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
          }
          lstAllAccounts.addAll(lstShipToAccounts);
      }
      lstAllAccounts.addAll(lstSoldToAccounts);
        update lstAllAccounts;
        System.assertEquals(3, lstSoldToAccounts.size());
        System.assertEquals(18, lstAllAccounts.size());
        
        List<Target_Split_Template__c> lstTargetSplitTemplate = CRM_TestDataFactory.createTargetSplitTemplate(2,false);
        lstTargetSplitTemplate[0].Automatically_Split_to_Ship_To__c = true;
        insert lstTargetSplitTemplate;
        
        List<Account_Split__c> lstAccountSplits = CRM_TestDataFactory.createAccountSplit(lstSoldToAccounts,new List<Target_Split_Template__c>{lstTargetSplitTemplate[0]},lstSoldToAccounts.size(),true);
        
        lstAccountSplits = CRM_TestDataFactory.createAccountSplit(new List<Account>{lstSoldToAccounts[0]},new 
        List<Target_Split_Template__c>{lstTargetSplitTemplate[1]},1,true);
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp, lstSoldToAccounts);
        System.assertEquals(3, lstProduct.size());
        for (Product2 prod : lstProduct) {
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                prod.Street_Date__c = System.today() + 32;
            }
            prod.NR_Product_Created__c = false;
        }
        update lstProduct;
        System.assertEquals(3, lstProduct.size());
  }
  
  //US : 801 : Account Split Change
  static testmethod void automaticallySplitToshipTo_Test(){
    CreateDataForAutomaticallySplitToShipToTest();
    List<Product2> lstProduct = [Select Id From Product2 Limit 1];
    List<Target_Split_Template__c> lstTSTs = [Select Id From Target_Split_Template__c Where Automatically_Split_to_Ship_To__c = true];
    
     PriceBook2 pb = new PriceBook2();
    pb.Name = 'Test FR';
    pb.External_Id__c = '6007-10';
    pb.Business_Unit__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
    insert pb;
   
    List<Bundle__c> lstAssortment = CRM_TestDataFactory.createBundles(1, false);
    lstAssortment[0].Name = 'Test1 Campaign Bundle';
    lstAssortment[0].Price_Book__c = pb.id;
    lstAssortment[0].Campaign_Type__c = 'Trade Promotion';
    lstAssortment[0].Promo_Start_Date__c = Date.today().addDays(1);
    lstAssortment[0].Promo_End_Date__c = Date.today().addDays(30);
    lstAssortment[0].High_Level_Target__c = 20000;
    lstAssortment[0].Average_Price__c = 65000;
    lstAssortment[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
    lstAssortment[0].CurrencyIsoCode = 'EUR';
    lstAssortment[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;

    if(!lstTSTs.isEmpty())
    lstAssortment[0].Account_Split_Template__c = lstTSTs[0].Id;
    
    
    Test.startTest();

    insert lstAssortment;
    system.assertEquals(1,lstAssortment.size());
        
        List<Account> lstShipToAccWithSharePerc = [Select Id From Account Where Account_Split_Share__c != null];
        System.assertEquals(9, lstShipToAccWithSharePerc.size(),'All ShipTos which have Account_Split_Share__c not equal to null');
        
        List<Assortment_Account__c> listAssortmentacc = [SELECT Id,Share__c,Assortment__c,Account__r.RecordTypeId FROM Assortment_Account__c where Assortment__c =:lstAssortment[0].Id];
        System.assertEquals(12, listAssortmentacc.size(),'Total num of Assortment Account created under the Assortment (9 (For Ship To) + 3 (For Parent Sold To) = 12 )');
        
        for(Assortment_Account__c ap : listAssortmentacc){
          if(ap.Account__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO){
            System.assertEquals(2,ap.Share__c);
          }else{
            System.assertEquals(10,ap.Share__c);
          }
        }
        Test.stopTest();
  }
}