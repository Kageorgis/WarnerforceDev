@isTest
private class CRM_DealProductCOPHandler_Test{     

/*********************************************** Scenario 1 ***************************************************************************/

    static testmethod void unitTestWithProductTypeFranchiseMatch(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();
        List<Id> lstDPID = new List<Id>();
        List<Contribution_Template__c> lstContributionTemplate;    
    
        //Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplatesScenario1(CRM_TestDataFactory.createContributionTemplates(1, false));
        for(Contribution_Template__c ct : lstContributionTemplate)        
            System.assertNotEquals(null, ct.Id, 'Error while creating Contribution Template.');     
                      
        //Create Account objects and populate.
        lstAccounts = modifyAndInsertAccounts(CRM_TestDataFactory.createAccounts(1, false), lstContributionTemplate);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');        
         
            
        lstContributionItem = modifyAndInsertContributionItemsScenario1(CRM_TestDataFactory.createContributionItems(lstContributionTemplate, 3, false));        
        for (Contribution_Item__c objContriItem : lstContributionItem)
            System.assertNotEquals(null, objContriItem.Id, 'Error While creating Contribution Items');
    
        lstProduct = modifyAndInsertProductsScenario1(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false));
        for (Product2 objProduct : lstProduct)    
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');
                
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);        
                
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;
    
        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');
    
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        createCustomSettingsCOPCommonValues();        
            Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
            System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());        
            
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);    
                // Fetch and print the stamped Deal Product Objects             
                List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                   Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                   Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
                System.debug('========> lstDP: ' + lstDP.size());
                System.debug('========> lstDealProduct.size(): ' + lstDealProduct.size());
                System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
                Test.stopTest();        
        }
    }
 
 
     private static List<Contribution_Template__c> modifyAndInsertContributionTemplatesScenario1(List<Contribution_Template__c> lstContributionTemplates){
        
         if (lstContributionTemplates != null && lstContributionTemplates.size() > 0){
            lstContributionTemplates[0].Coop__c = 1.8;
            lstContributionTemplates[0].Merchandising__c = 1.7;
            lstContributionTemplates[0].Returns__c = 2.60;
            lstContributionTemplates[0].Sales_Allowance__c = 0.65;
            lstContributionTemplates[0].PAP__c = 0.25;
         }
         
         insert lstContributionTemplates;
         return lstContributionTemplates;         
     }
 
     private static List<Product2> modifyAndInsertProductsScenario1(List<Product2> lstProducts){
         
         lstProducts[0].Distribution_Cost__c = 100000;
         lstProducts[0].Production_Cost__c = 700000;
         lstProducts[0].Royalty_Fee_Fixed__c = 100;
         lstProducts[0].Master_Negative__c = 20;         
         lstProducts[0].Franchise_Type__c = 'TV';
                  
         insert lstProducts;
         return lstProducts;
     }
 
    private static List<Contribution_Item__c> modifyAndInsertContributionItemsScenario1(List<Contribution_Item__c> lstContributionItem){    
     
        if(lstContributionItem != null && lstContributionItem.size() > 0){
            lstContributionItem[0].Coop__c = 1.6;
            lstContributionItem[0].Merchandising__c = 1.28;
            lstContributionItem[0].Returns__c = 1.80;
            lstContributionItem[0].Sales_Allowance__c = 15.00;
            lstContributionItem[0].Product_Type__c = 'LB';
            lstContributionItem[0].Franchise__c = null;        
            lstContributionItem[0].PAP__c = 1.42;
            
            lstContributionItem[1].Coop__c = 3.0;
            lstContributionItem[1].Merchandising__c = 4.0;
            lstContributionItem[1].Returns__c = 1.0;
            lstContributionItem[1].Sales_Allowance__c = 2.0;
            lstContributionItem[1].Product_Type__c = 'LB';            
            lstContributionItem[1].PAP__c = 1.0;
                        
            lstContributionItem[2].Coop__c = 0;
            lstContributionItem[2].Merchandising__c = 0;
            lstContributionItem[2].Returns__c = 0;
            lstContributionItem[2].Sales_Allowance__c = 0;
            lstContributionItem[2].Product_Type__c = 'LB';            
            lstContributionItem[2].Franchise__c = 'HBO';
            lstContributionItem[2].PAP__c = 0;            
        }
        insert lstContributionItem;
        return  lstContributionItem;             
     
    }
    
    /*
    *   This method takes the list of Accounts as an Input, makes some changes, inserts it into the database and returns it.
    *  @name - modifyAndInsertAccounts
    *  @param - List of Accounts
    *  @return <parameter> - List of Accounts
    *  @throws exception - 
    */                   
    private static List<Account> modifyAndInsertAccounts(List<Account> lstAccounts, List<Contribution_Template__c> lstContributionTemplate) {
        for (Integer nAcct = 0; nAcct < lstAccounts.size(); nAcct++)
            lstAccounts[nAcct].Contribution_Template__c = lstContributionTemplate[nAcct].Id;
             
        insert lstAccounts; 
        return lstAccounts;
    }    
    
     
/*********************************************** End of Scenario 1 ***************************************************************************/     
     
/*********************************************** Scenario 2 ***************************************************************************/     


    static testmethod void unitTestWithoutContributionItem(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();
        List<Id> lstDPID = new List<Id>();
        List<Contribution_Template__c> lstContributionTemplate;    
                
        //Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplatesScenario2(CRM_TestDataFactory.createContributionTemplates(1, false));
        for(Contribution_Template__c ct : lstContributionTemplate)        
            System.assertNotEquals(null, ct.Id, 'Error while creating Contribution Template.');                
    
            
        //Create Account objects and populate.
        lstAccounts = modifyAndInsertAccounts(CRM_TestDataFactory.createAccounts(1, false), lstContributionTemplate);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');        
            
                    
        lstProduct = modifyAndInsertProductsScenario2(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false));
        for (Product2 objProduct : lstProduct)
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');       
                
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);   
        
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;   
                
    
        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');
    
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
                
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);        
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);
        
            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP);
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            Test.stopTest();        
        }
    }
 
 
     private static List<Contribution_Template__c> modifyAndInsertContributionTemplatesScenario2(List<Contribution_Template__c> lstContributionTemplates){
         if (lstContributionTemplates != null && lstContributionTemplates.size() > 0){
            lstContributionTemplates[0].Coop__c = 0.22;
            lstContributionTemplates[0].Merchandising__c = 0.77;
            lstContributionTemplates[0].Returns__c = 0.24;
            lstContributionTemplates[0].Sales_Allowance__c = 1.21;
            lstContributionTemplates[0].PAP__c = 0.11;
         }
         
         insert lstContributionTemplates;
         return lstContributionTemplates;
         
     }
 
     private static List<Product2> modifyAndInsertProductsScenario2(List<Product2> lstProducts){
         
         lstProducts[0].Distribution_Cost__c = 100000;
         lstProducts[0].Production_Cost__c = 700000;
         lstProducts[0].Royalty_Fee_Fixed__c = 100;
         lstProducts[0].Master_Negative__c = 20;         
         lstProducts[0].Franchise_Type__c = 'TV';
                  
         insert lstProducts;
         return lstProducts;
     }


/*********************************************** End of Scenario 2 ***************************************************************************/


/*********************************************** Scenario 3 ***************************************************************************/


    static testmethod void unitTestWithTwoProductTypeMatchAndOneFranchiseMatch(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();
        List<Id> lstDPID = new List<Id>();
        List<Contribution_Template__c> lstContributionTemplate;     
            
        //Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplatesScenario3(CRM_TestDataFactory.createContributionTemplates(1, false));
        for(Contribution_Template__c ct : lstContributionTemplate)        
            System.assertNotEquals(null, ct.Id, 'Error while creating Contribution Template.');     
    
        //Create Account objects and populate.
        lstAccounts = modifyAndInsertAccounts(CRM_TestDataFactory.createAccounts(1, false), lstContributionTemplate);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');        
        
        lstContributionItem = modifyAndInsertContributionItemsScenario3(CRM_TestDataFactory.createContributionItems(lstContributionTemplate, 3, false));        
        for (Contribution_Item__c objContriItem : lstContributionItem)
            System.assertNotEquals(null, objContriItem.Id, 'Error While creating Contribution Items');

        lstProduct = modifyAndInsertProductsScenario3(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false));
        for (Product2 objProduct : lstProduct)            
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');        
            
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);  
        
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;

        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');
       
        
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
        
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);
    
            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP);
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            Test.stopTest();        
        }
    }
 
 
     private static List<Contribution_Template__c> modifyAndInsertContributionTemplatesScenario3(List<Contribution_Template__c> lstContributionTemplates){
         if (lstContributionTemplates != null && lstContributionTemplates.size() > 0){
            lstContributionTemplates[0].Coop__c = 1.8;
            lstContributionTemplates[0].Merchandising__c = 1.70;
            lstContributionTemplates[0].Returns__c = 2.60;
            lstContributionTemplates[0].Sales_Allowance__c = 0.65;
            lstContributionTemplates[0].PAP__c = 0.25;
         }
         
         insert lstContributionTemplates;    
         return lstContributionTemplates;         
     }
 
     private static List<Product2> modifyAndInsertProductsScenario3(List<Product2> lstProducts){
         
         lstProducts[0].Distribution_Cost__c = 10;
         lstProducts[0].Production_Cost__c = 100;
         lstProducts[0].Royalty_Fee_Fixed__c = 20;
         lstProducts[0].Master_Negative__c = 2;         
         lstProducts[0].Franchise_Type__c = 'TV';
                  
         insert lstProducts;
         return lstProducts;
     }
 
    private static List<Contribution_Item__c> modifyAndInsertContributionItemsScenario3(List<Contribution_Item__c> lstContributionItem){
     
        if(lstContributionItem != null && lstContributionItem.size() > 0){
        
        
            lstContributionItem[0].Coop__c = 1.6;
            lstContributionItem[0].Merchandising__c = 1.28;
            lstContributionItem[0].Returns__c = 1.80;
            lstContributionItem[0].Sales_Allowance__c = 15.00;
            lstContributionItem[0].Product_Type__c = 'LB';
            lstContributionItem[0].Franchise__c = 'TV';        
            lstContributionItem[0].PAP__c = 1.42;
            
            lstContributionItem[1].Coop__c = 3.0;
            lstContributionItem[1].Merchandising__c = 4.0;
            lstContributionItem[1].Returns__c = 1.0;
            lstContributionItem[1].Sales_Allowance__c = 2.0;
            lstContributionItem[1].Product_Type__c = 'NR';
            lstContributionItem[1].Franchise__c = 'TV';
            lstContributionItem[1].PAP__c = 1.0;
                        
            lstContributionItem[2].Coop__c = 4.0;
            lstContributionItem[2].Merchandising__c = 5.0;
            lstContributionItem[2].Returns__c = 2.0;
            lstContributionItem[2].Sales_Allowance__c = 4.0;
            lstContributionItem[2].Product_Type__c = 'LB';            
            lstContributionItem[2].Franchise__c = 'HBO';
            lstContributionItem[2].PAP__c = 0;            
        }
        insert lstContributionItem;
        return  lstContributionItem;             
     
    }


/*********************************************** End of Scenario 3 ***************************************************************************/



/*********************************************** Scenario 4 ***************************************************************************/

    static testmethod void unitTestWithOneFranchiseMatchAndTwoProductTypeMatch(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();
        List<Id> lstDPID = new List<Id>();
        List<Contribution_Template__c> lstContributionTemplate;    
                
        //Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplatesScenario4(CRM_TestDataFactory.createContributionTemplates(1, false));
        for(Contribution_Template__c ct : lstContributionTemplate)        
            System.assertNotEquals(null, ct.Id, 'Error while creating Contribution Template.');                
    
            
        //Create Account objects and populate.
        lstAccounts = modifyAndInsertAccounts(CRM_TestDataFactory.createAccounts(1, false), lstContributionTemplate);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');        
        
        lstContributionItem = modifyAndInsertContributionItemsScenario4(CRM_TestDataFactory.createContributionItems(lstContributionTemplate, 2, false));        
        for (Contribution_Item__c objContriItem : lstContributionItem)
            System.assertNotEquals(null, objContriItem.Id, 'Error While creating Contribution Items');

        lstProduct = modifyAndInsertProductsScenario4(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false));
        for (Product2 objProduct : lstProduct)
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');        
            
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);        
            
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;    

        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');        
        
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
                
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);

            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP);
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            Test.stopTest();        
        }
    }
 
 
     private static List<Contribution_Template__c> modifyAndInsertContributionTemplatesScenario4(List<Contribution_Template__c> lstContributionTemplates){
         if (lstContributionTemplates != null && lstContributionTemplates.size() > 0){
            lstContributionTemplates[0].Coop__c = 1.8;
            lstContributionTemplates[0].Merchandising__c = 1.7;
            lstContributionTemplates[0].Returns__c = 2.60;
            lstContributionTemplates[0].Sales_Allowance__c = 0.65;
            lstContributionTemplates[0].PAP__c = 0.25;
         }
         
         insert lstContributionTemplates;
         return lstContributionTemplates;
         
     }
 
     private static List<Product2> modifyAndInsertProductsScenario4(List<Product2> lstProducts){
         
         lstProducts[0].Distribution_Cost__c = 50000;
         lstProducts[0].Production_Cost__c = 5000000;
         lstProducts[0].Royalty_Fee_Fixed__c = 25000;
         lstProducts[0].Master_Negative__c = 35421;         
         lstProducts[0].Franchise_Type__c = 'TV';
                  
         insert lstProducts;
         return lstProducts;
     }
 
    private static List<Contribution_Item__c> modifyAndInsertContributionItemsScenario4(List<Contribution_Item__c> lstContributionItem){
     
        if(lstContributionItem != null && lstContributionItem.size() > 0){
            lstContributionItem[0].Coop__c = 0.65;
            lstContributionItem[0].Merchandising__c = 0.85;
            lstContributionItem[0].Returns__c = 0.25;
            lstContributionItem[0].Sales_Allowance__c = 0.45;
            lstContributionItem[0].Product_Type__c = 'LB';
            lstContributionItem[0].Franchise__c = 'TV';        
            lstContributionItem[0].PAP__c = 0.66;
            
            lstContributionItem[1].Coop__c = 0.35;
            lstContributionItem[1].Merchandising__c = 0.45;
            lstContributionItem[1].Returns__c = 0.15;
            lstContributionItem[1].Sales_Allowance__c = 0.25;
            lstContributionItem[1].Product_Type__c = 'NR';
            lstContributionItem[1].PAP__c = 0.85;
          
        }
        
        insert lstContributionItem;
        return  lstContributionItem;                  
    }
     
/*********************************************** End of Scenario 4 ***************************************************************************/     



/*********************************************** Scenario 5 ***************************************************************************/

    static testmethod void unitTestWithOnlyProductTypeMatch(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();
        List<Id> lstDPID = new List<Id>();
        List<Contribution_Template__c> lstContributionTemplate;    
            
        //Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplatesScenario5(CRM_TestDataFactory.createContributionTemplates(1, false));
        for(Contribution_Template__c ct : lstContributionTemplate)        
            System.assertNotEquals(null, ct.Id, 'Error while creating Contribution Template.');                
    
            
        //Create Account objects and populate.
        lstAccounts = modifyAndInsertAccounts(CRM_TestDataFactory.createAccounts(1, false), lstContributionTemplate);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');        
            
        lstContributionItem = modifyAndInsertContributionItemsScenario5(CRM_TestDataFactory.createContributionItems(lstContributionTemplate, 2, false));        
        for (Contribution_Item__c objContriItem : lstContributionItem)
            System.assertNotEquals(null, objContriItem.Id, 'Error While creating Contribution Items');
    
        lstProduct = modifyAndInsertProductsScenario5(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false));
        for (Product2 objProduct : lstProduct)
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');   
                
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);        
         
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;       
    
        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');
        
        
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
                
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);
    
            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP);
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            Test.stopTest();        
        }
    }
 
 
    private static List<Contribution_Template__c> modifyAndInsertContributionTemplatesScenario5(List<Contribution_Template__c> lstContributionTemplates){
        if (lstContributionTemplates != null && lstContributionTemplates.size() > 0){
            lstContributionTemplates[0].Coop__c = 1.8;
            lstContributionTemplates[0].Merchandising__c = 1.7;
            lstContributionTemplates[0].Returns__c = 2.60;
            lstContributionTemplates[0].Sales_Allowance__c = 0.65;
            lstContributionTemplates[0].PAP__c = 0.25;
         }
         
         insert lstContributionTemplates;         
         return lstContributionTemplates;         
     }
 
     private static List<Product2> modifyAndInsertProductsScenario5(List<Product2> lstProducts){
         
         lstProducts[0].Distribution_Cost__c = 800000;
         lstProducts[0].Production_Cost__c = 8000000;
         lstProducts[0].Royalty_Fee_Fixed__c = 28473;
         lstProducts[0].Master_Negative__c = 2873;         
         lstProducts[0].Franchise_Type__c = 'X1';
         
         insert lstProducts;
         return lstProducts;
     }
 
    private static List<Contribution_Item__c> modifyAndInsertContributionItemsScenario5(List<Contribution_Item__c> lstContributionItem){

        if(lstContributionItem != null && lstContributionItem.size() > 0){
            lstContributionItem[0].Coop__c = 1.54;
            lstContributionItem[0].Merchandising__c = 0.83;
            lstContributionItem[0].Returns__c = 1.23;
            lstContributionItem[0].Sales_Allowance__c = 0.34;
            lstContributionItem[0].Product_Type__c = 'LB';            
            lstContributionItem[0].PAP__c = 2.0;
            
            lstContributionItem[1].Coop__c = 0.65;
            lstContributionItem[1].Merchandising__c = 1.34;
            lstContributionItem[1].Returns__c = 0.23;
            lstContributionItem[1].Sales_Allowance__c = 0.56;
            lstContributionItem[1].Product_Type__c = 'LB';
            lstContributionItem[1].Franchise__c = 'X2';
            lstContributionItem[1].PAP__c = 2.10;          
        }
        
        insert lstContributionItem;
        return  lstContributionItem;             
     
    }
     
/*********************************************** End of Scenario 5 ***************************************************************************/     


/*********************************************** Scenario 6 ***************************************************************************/

    static testmethod void UnitTestWithMultipleMatches(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();
        List<Id> lstDPID = new List<Id>();
                
        //Create Account objects and populate.
        lstAccounts = CRM_TestDataFactory.createAccounts(1, true);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');        
        
        lstProduct = modifyAndInsertProductsScenario6(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false));
        for (Product2 objProduct : lstProduct)
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');
            
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);        
        
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;    

        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');    
        
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
                
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);
    
            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP);
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            Test.stopTest();        
        }
    }

 
    private static List<Product2> modifyAndInsertProductsScenario6(List<Product2> lstProducts){
         
         lstProducts[0].Distribution_Cost__c = 5000;
         lstProducts[0].Production_Cost__c = 8000;
         lstProducts[0].Royalty_Fee_Fixed__c = 200;
         lstProducts[0].Master_Negative__c = 200;         
         lstProducts[0].Franchise_Type__c = 'X1';
         
         insert lstProducts;
         return lstProducts;
     }
 

     
/*********************************************** End of Scenario 6 ***************************************************************************/     



/************************************************ Bulk Scenario ************************************************************************************/

    static testmethod void testBulkCOP(){
        List<Id> lstDPID = new List<Id>();
        List<Account> lstAccounts = null;
        List<Contribution_Item__c> lstContributionItem = null;
        List<Product2> lstProduct = null;
        List<Contribution_Template__c> lstContributionTemplate;    
            
        // Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplate(CRM_TestDataFactory.createContributionTemplates(5, false));        
        for(Contribution_Template__c ct : lstContributionTemplate)        
            System.assertNotEquals(null, ct.Id, 'Error while creating Contribution Template.');
        
        //Create Account objects and populate.
        lstAccounts = modifyAndInsertAccountsScenarioBulk(CRM_TestDataFactory.createAccounts(5, false), lstContributionTemplate);
        for (Account acct : lstAccounts)      
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');
                       
        
        // Create Contribution Item objetcts and populate
        lstContributionItem = modifyAndInsertContributionItems(CRM_TestDataFactory.createContributionItems(lstContributionTemplate, 3, false));
        for (Contribution_Item__c objContriItem : lstContributionItem)
            System.assertNotEquals(null, objContriItem.Id, 'Error While creating Contribution Items');
                        
        
        // Create Product Groups and Products
        lstProduct = modifyAndInsertProducts(CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(2, true), 10, false));
        for (Product2 objProduct : lstProduct)
            System.assertNotEquals(null, objProduct.Id, 'Error while creating Products');
        
        
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);
        
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;
        
        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2,true);
        System.assertEquals(10, lstOpportunity.size(), 'Error while creating Opportunities');
        
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
                
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 20, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);
    
            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP.size());
            System.debug('========> lstDealProduct: ' + lstDealProduct.size());
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            Test.stopTest();
        }
    }

    /*
    *  This method populates the Contribution Template Objects and insert the list of Contribution Templates received. 
    *  @name - modifyAndInsertContributionTemplate
    *  @param - This takes List<Contribution_Template__c> as an input to populate the data as per test cases.
    *  @return <parameter> - List of Contribution_Template__c
    *  @throws exception - 
    */               
    private static List<Contribution_Template__c> modifyAndInsertContributionTemplate(List<Contribution_Template__c> lstContributionTemplateTmp){
        lstContributionTemplateTmp[0].Coop__c = 0.1;
        lstContributionTemplateTmp[0].Merchandising__c = 0.11;
        lstContributionTemplateTmp[0].Returns__c = 0.12;
        lstContributionTemplateTmp[0].Sales_Allowance__c = 0.13;

        lstContributionTemplateTmp[1].Coop__c = 0.2;
        lstContributionTemplateTmp[1].Merchandising__c = 0.21;
        lstContributionTemplateTmp[1].Returns__c = 0.22;
        lstContributionTemplateTmp[1].Sales_Allowance__c = 0.23;
        
        lstContributionTemplateTmp[2].Coop__c = 0.31;
        lstContributionTemplateTmp[2].Merchandising__c = 0.31;
        lstContributionTemplateTmp[2].Returns__c = 0.32;
        lstContributionTemplateTmp[2].Sales_Allowance__c = 0.33;
                
        lstContributionTemplateTmp[3].Coop__c = 0.4;
        lstContributionTemplateTmp[3].Merchandising__c = 0.41;
        lstContributionTemplateTmp[3].Returns__c = 0.42;
        lstContributionTemplateTmp[3].Sales_Allowance__c = 0.43;
        
        lstContributionTemplateTmp[4].Coop__c = null;
        lstContributionTemplateTmp[4].Merchandising__c = null;
        lstContributionTemplateTmp[4].Returns__c = null;
        lstContributionTemplateTmp[4].Sales_Allowance__c = null;
        
        insert lstContributionTemplateTmp;
        return lstContributionTemplateTmp;
    }

    /*
    *   This method takes the list of Accounts as an Input, makes some changes, inserts it into the database and returns it.
    *  @name - modifyAndInsertAccounts
    *  @param - List of Accounts
    *  @return <parameter> - List of Accounts
    *  @throws exception - 
    */                   
    private static List<Account> modifyAndInsertAccountsScenarioBulk(List<Account> lstAccounts, List<Contribution_Template__c> lstContributionTemplate) {
        for (Integer nAcct = 0; nAcct < (lstAccounts.size() - 1); nAcct++)
            lstAccounts[nAcct].Contribution_Template__c = lstContributionTemplate[nAcct].Id;
             
        insert lstAccounts; 
        return lstAccounts;
    }

    /*
    *   This method populates the Contribution Item Objects and inserts those into the database.
    *  @name - modifyAndInsertContributionItems
    *  @param - List of Contribution Item
    *  @return <parameter> - List of Contribution Item
    *  @throws exception - 
    */                       
     
    private static List<Contribution_Item__c> modifyAndInsertContributionItems(List<Contribution_Item__c> lstContributionItem){
        lstContributionItem[0].Coop__c = 1.1;
        lstContributionItem[0].Merchandising__c = 1.11;
        lstContributionItem[0].Returns__c = 1.12;
        lstContributionItem[0].Sales_Allowance__c = 1.13;
        lstContributionItem[0].Product_Type__c = 'Catalog';
        lstContributionItem[0].Franchise__c = 'TV';        
        
        lstContributionItem[1].Coop__c = 1.14;
        lstContributionItem[1].Merchandising__c = 1.15;
        lstContributionItem[1].Returns__c = 1.16;
        lstContributionItem[1].Sales_Allowance__c = 1.17;
        lstContributionItem[1].Product_Type__c = 'New Release';
        lstContributionItem[1].Franchise__c = 'HBO';        
        
        lstContributionItem[2].Coop__c = 1.8;
        lstContributionItem[2].Merchandising__c = 1.19;
        lstContributionItem[2].Returns__c = 1.15;
        lstContributionItem[2].Sales_Allowance__c = 1.16;
        lstContributionItem[2].Product_Type__c = '';
        lstContributionItem[2].Franchise__c = 'TV';        
        
        lstContributionItem[3].Coop__c = 1.2;
        lstContributionItem[3].Merchandising__c = 1.21;
        lstContributionItem[3].Returns__c = 1.22;
        lstContributionItem[3].Sales_Allowance__c = 1.23;
        lstContributionItem[3].Product_Type__c = 'New Release';
        lstContributionItem[3].Franchise__c = 'HBO';        
        
        lstContributionItem[4].Coop__c = 1.24;
        lstContributionItem[4].Merchandising__c = 1.25;
        lstContributionItem[4].Returns__c = 1.26;
        lstContributionItem[4].Sales_Allowance__c = 1.27;
        lstContributionItem[4].Product_Type__c = 'Catalog';
        lstContributionItem[4].Franchise__c = '';

        lstContributionItem[5].Coop__c = 1.28;
        lstContributionItem[5].Merchandising__c = 1.29;
        lstContributionItem[5].Returns__c = 1.23;
        lstContributionItem[5].Sales_Allowance__c = 1.24;
        lstContributionItem[5].Product_Type__c = 'Catalog';
        lstContributionItem[5].Franchise__c = 'TV';        
        
        lstContributionItem[6].Coop__c = 1.3;
        lstContributionItem[6].Merchandising__c = 1.31;
        lstContributionItem[6].Returns__c = 1.32;
        lstContributionItem[6].Sales_Allowance__c = 1.33;
        lstContributionItem[6].Product_Type__c = 'New Release';
        lstContributionItem[6].Franchise__c = 'HBO';       
       
        lstContributionItem[7].Coop__c = 1.34;
        lstContributionItem[7].Merchandising__c = 1.35;
        lstContributionItem[7].Returns__c = 1.36;
        lstContributionItem[7].Sales_Allowance__c = 1.37;
        lstContributionItem[7].Product_Type__c = 'Catalog';
        lstContributionItem[7].Franchise__c = '';        
        
        lstContributionItem[8].Coop__c = 1.38;
        lstContributionItem[8].Merchandising__c = 1.39;
        lstContributionItem[8].Returns__c = 1.34;
        lstContributionItem[8].Sales_Allowance__c = 1.35;               
        lstContributionItem[8].Product_Type__c = 'New Release';
        lstContributionItem[8].Franchise__c = 'HBO';

        insert lstContributionItem;
        return  lstContributionItem;
    }

    /*
    *   This method populates the Products created and inserts those into the database.
    *  @name - modifyAndInsertProducts
    *  @param - List<Product2>
    *  @return <parameter> - List<Product2>
    *  @throws exception - 
    */        
    private static List<Product2> modifyAndInsertProducts(List<Product2> lstProduct){
        lstProduct[0].Production_Cost__c = 1111111;
        lstProduct[0].Distribution_Cost__c = 1111112;
        lstProduct[0].Franchise_Type__c = 'TV';     
        lstProduct[0].Master_Negative__c = 1111113;
        lstProduct[0].Royalty_Fee_Fixed__c = 1114;
        
        lstProduct[1].Production_Cost__c = 2222221;
        lstProduct[1].Distribution_Cost__c = 2222221;
        lstProduct[1].Franchise_Type__c = 'TV';     
        lstProduct[1].Master_Negative__c = 2223;
        lstProduct[1].Royalty_Fee_Fixed__c = 2224;
        
        lstProduct[2].Production_Cost__c = 3333331;
        lstProduct[2].Distribution_Cost__c = 3333332;
        lstProduct[2].Franchise_Type__c = 'TV';     
        lstProduct[2].Master_Negative__c = 3333;
        lstProduct[2].Royalty_Fee_Fixed__c = 3334;
        
        lstProduct[3].Production_Cost__c = 4444441;
        lstProduct[3].Distribution_Cost__c = 4444442;
        lstProduct[3].Franchise_Type__c = 'TV';     
        lstProduct[3].Master_Negative__c = 4443;
        lstProduct[3].Royalty_Fee_Fixed__c = 4444;
    
        lstProduct[4].Production_Cost__c = 5555551;
        lstProduct[4].Distribution_Cost__c = 5555552;
        lstProduct[4].Franchise_Type__c = 'TV';     
        lstProduct[4].Master_Negative__c = 5553;
        lstProduct[4].Royalty_Fee_Fixed__c = 5554;
        
        lstProduct[5].Production_Cost__c = 6666661;
        lstProduct[5].Distribution_Cost__c = 6666662;
        lstProduct[5].Franchise_Type__c = 'TV';     
        lstProduct[5].Master_Negative__c = 6663;
        lstProduct[5].Royalty_Fee_Fixed__c = 6664;
    
        lstProduct[6].Production_Cost__c = 7777771;
        lstProduct[6].Distribution_Cost__c = 7777772;
        lstProduct[6].Franchise_Type__c = 'X1';     
        lstProduct[6].Master_Negative__c = 7773;
        lstProduct[6].Royalty_Fee_Fixed__c = 7774;
        
        lstProduct[7].Production_Cost__c = 8888881;
        lstProduct[7].Distribution_Cost__c = 8888882;
        lstProduct[7].Franchise_Type__c = 'X1';     
        lstProduct[7].Master_Negative__c = 8883;
        lstProduct[7].Royalty_Fee_Fixed__c = 8884;
        
        lstProduct[8].Production_Cost__c = 9999991;
        lstProduct[8].Distribution_Cost__c = 9999992;
        lstProduct[8].Franchise_Type__c = 'X1';     
        lstProduct[8].Master_Negative__c = 9993;
        lstProduct[8].Royalty_Fee_Fixed__c = 9994;
        
        lstProduct[9].Production_Cost__c = 121212;
        lstProduct[9].Distribution_Cost__c = 232323;
        lstProduct[9].Franchise_Type__c = 'X1';     
        lstProduct[9].Master_Negative__c = 3434343;
        lstProduct[9].Royalty_Fee_Fixed__c = 454545;
                                                                                
        insert lstProduct;
        return lstProduct;
    }


/************************************************ End of Bulk Scenario ***************************************************************************************/
    /*
    *   This method creates the custom settings and required in the code and inserts it in the database.
    *  @name - createCustomSettingsCTNProd
    *  @param - NA
    *  @return <parameter> - List<COP_ContributionTemplateNProductFields__c> 
    *  @throws exception - 
    */    
    private static List<COP_ContributionTemplateNProductFields__c> createCustomSettingsCTNProd(){
        List<COP_ContributionTemplateNProductFields__c> lstCustSettingContriNProd = new List<COP_ContributionTemplateNProductFields__c>();    
          
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd1 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd1.Name = 'Coop__c';
        objCustSettingCTProd1.ContributionTemplateOrProduct_Field__c = 'Coop__c';
        objCustSettingCTProd1.RelatedCustomObject__c = 'Contribution Template';
        objCustSettingCTProd1.UK__c = true;
        objCustSettingCTProd1.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd1);
    
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd2 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd2.Name = 'Distribution_Cost__c';
        objCustSettingCTProd2.ContributionTemplateOrProduct_Field__c = 'Distribution_Cost__c';
        objCustSettingCTProd2.RelatedCustomObject__c = 'Product';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd2);
                
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd3 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd3.Name = 'Master_Negative__c';
        objCustSettingCTProd3.ContributionTemplateOrProduct_Field__c = 'Master_Negative__c';
        objCustSettingCTProd3.RelatedCustomObject__c = 'Product';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd3);      
    
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd4 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd4.Name = 'Merchandising__c';
        objCustSettingCTProd4.ContributionTemplateOrProduct_Field__c = 'Merchandising__c';
        objCustSettingCTProd4.RelatedCustomObject__c = 'Contribution Template';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd4);
          
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd5 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd5.Name = 'Production_Cost__c';
        objCustSettingCTProd5.ContributionTemplateOrProduct_Field__c = 'Production_Cost__c';
        objCustSettingCTProd5.RelatedCustomObject__c = 'Product';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd5);      
          
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd6 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd6.Name = 'Returns__c';
        objCustSettingCTProd6.ContributionTemplateOrProduct_Field__c = 'Returns__c';
        objCustSettingCTProd6.RelatedCustomObject__c = 'Contribution Template';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd6);      
      
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd7 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd7.Name = 'Royalty_Fee_Fixed__c';
        objCustSettingCTProd7.ContributionTemplateOrProduct_Field__c = 'Royalty_Fee_Fixed__c';
        objCustSettingCTProd7.RelatedCustomObject__c = 'Product';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd7);

        COP_ContributionTemplateNProductFields__c objCustSettingCTProd8 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd8.Name = 'Sales_Allowance__c';
        objCustSettingCTProd8.ContributionTemplateOrProduct_Field__c = 'Sales_Allowance__c';
        objCustSettingCTProd8.RelatedCustomObject__c = 'Contribution Template';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd8);

        COP_ContributionTemplateNProductFields__c objCustSettingCTProd9 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd9.Name = 'Cash_Discounts__c';
        objCustSettingCTProd9.ContributionTemplateOrProduct_Field__c = 'Cash_Discounts__c';
        objCustSettingCTProd9.RelatedCustomObject__c = 'Contribution_Template__c';
        objCustSettingCTProd2.UK__c = False;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd9);
        
        COP_ContributionTemplateNProductFields__c objCustSettingCTProd10 = new COP_ContributionTemplateNProductFields__c();
        objCustSettingCTProd10.Name = 'Distribution Cost';
        objCustSettingCTProd10.ContributionTemplateOrProduct_Field__c = 'Distribution_Cost__c';
        objCustSettingCTProd10.RelatedCustomObject__c = 'Contribution_Template__c';
        objCustSettingCTProd2.UK__c = true;
        objCustSettingCTProd2.FR__c = true;
        lstCustSettingContriNProd.add(objCustSettingCTProd10);
        
        if(!lstCustSettingContriNProd.isEmpty()){
            insert lstCustSettingContriNProd;
        }
      
        return lstCustSettingContriNProd;
    }
/*
    *  This method creates the custom settings and required in the code and inserts it in the database.
    *  @name - createCustomSettingsCI
    *  @param - NA
    *  @return <parameter> - List<COP_ContributionItemFields__c> 
    *  @throws exception - 
    */        
    private static List<CRM_COP_Common_Values__c> createCustomSettingsCOPCommonValues(){
        List<CRM_COP_Common_Values__c> lstCustomSettingCOPCommonValues = new List<CRM_COP_Common_Values__c>();
        CRM_COP_Common_Values__c objCustSettingCOPCommonValues1 = new CRM_COP_Common_Values__c();
        objCustSettingCOPCommonValues1.Name = '6014';
        objCustSettingCOPCommonValues1.Doubtful_Accounts__c = 30;
        objCustSettingCOPCommonValues1.Gema__c = 10;
        objCustSettingCOPCommonValues1.Gross_receipt_taxes_FFA__c = 20;                
        lstCustomSettingCOPCommonValues.add(objCustSettingCOPCommonValues1);
        
        /*CRM_DE_COP_Common_Values__c objCustSettingCOPCommonValues2 = new CRM_DE_COP_Common_Values__c();
        objCustSettingCOPCommonValues2.Name = 'Gema';
        objCustSettingCOPCommonValues2.Value__c = 10;
        lstCustomSettingDECommonValues.add(objCustSettingCOPCommonValues2);

        CRM_DE_COP_Common_Values__c objCustSettingCOPCommonValues3 = new CRM_DE_COP_Common_Values__c();
        objCustSettingCOPCommonValues3.Name = 'Gross receipt taxes (FFA)';
        objCustSettingCOPCommonValues3.Value__c = 20;
        lstCustomSettingDECommonValues.add(objCustSettingCOPCommonValues3); */
        
        insert lstCustomSettingCOPCommonValues;
        
        return lstCustomSettingCOPCommonValues;
    }    
    
    /*
    *  This method creates the custom settings and required in the code and inserts it in the database.
    *  @name - createCustomSettingsCI
    *  @param - NA
    *  @return <parameter> - List<COP_ContributionItemFields__c> 
    *  @throws exception - 
    */        
    private static List<COP_ContributionItemFields__c> createCustomSettingsCI(){
    
        List<COP_ContributionItemFields__c> lstCustomSettingCI = new List<COP_ContributionItemFields__c>(); 
            
        COP_ContributionItemFields__c objCustomSettingCI1 = new COP_ContributionItemFields__c();
        objCustomSettingCI1.Name = 'Coop__c';
        objCustomSettingCI1.ContributionItemField__c = 'Coop__c';
        lstCustomSettingCI.add(objCustomSettingCI1);
    
        COP_ContributionItemFields__c objCustomSettingCI2 = new COP_ContributionItemFields__c();
        objCustomSettingCI2.Name = 'Merchandising__c';
        objCustomSettingCI2.ContributionItemField__c = 'Merchandising__c';
        lstCustomSettingCI.add(objCustomSettingCI2);
        
        COP_ContributionItemFields__c objCustomSettingCI3 = new COP_ContributionItemFields__c();
        objCustomSettingCI3.Name = 'Returns__c';
        objCustomSettingCI3.ContributionItemField__c = 'Returns__c';
        lstCustomSettingCI.add(objCustomSettingCI3);        
            
        COP_ContributionItemFields__c objCustomSettingCI4 = new COP_ContributionItemFields__c();
        objCustomSettingCI4.Name = 'Sales_Allowance__c';
        objCustomSettingCI4.ContributionItemField__c = 'Sales_Allowance__c';
        lstCustomSettingCI.add(objCustomSettingCI4);
        
        COP_ContributionItemFields__c objCustomSettingCI5 = new COP_ContributionItemFields__c();
        objCustomSettingCI5.Name = 'PAP__c';
        objCustomSettingCI5.ContributionItemField__c = 'PAP__c';
        lstCustomSettingCI.add(objCustomSettingCI5);        
        
        insert lstCustomSettingCI;
        
        return lstCustomSettingCI;
    }    
    
    private static List<Contribution_Item__c> modifyAndInsertContributionItemsScenario8(List<Contribution_Item__c> lstContributionItem){    
     
        if(lstContributionItem != null && lstContributionItem.size() > 0){
            lstContributionItem[0].Coop__c = 1.6;
            lstContributionItem[0].Merchandising__c = 1.28;
            lstContributionItem[0].Returns__c = 1.80;
            lstContributionItem[0].Sales_Allowance__c = 15.00;
            lstContributionItem[0].Sales_Allowance__c = 15.00;
            lstContributionItem[0].Product_Type__c = 'LB';
            lstContributionItem[0].Franchise__c = null;        
            lstContributionItem[0].PAP__c = 1.42;
            
            lstContributionItem[1].Coop__c = 3.0;
            lstContributionItem[1].Merchandising__c = 4.0;
            lstContributionItem[1].Returns__c = 1.0;
            lstContributionItem[1].Sales_Allowance__c = 15.00;
            lstContributionItem[1].Sales_Allowance__c = 15.00;
            lstContributionItem[1].Product_Type__c = 'LB';            
            lstContributionItem[1].PAP__c = 1.0;
                        
            lstContributionItem[2].Coop__c = 0;
            lstContributionItem[2].Merchandising__c = 0;
            lstContributionItem[2].Returns__c = 0;
            lstContributionItem[2].Sales_Allowance__c = 15.00;
            lstContributionItem[2].Sales_Allowance__c = 15.00;
            lstContributionItem[2].Product_Type__c = 'NR';            
            lstContributionItem[2].Franchise__c = 'HBO';
            lstContributionItem[2].Format__c = '3DHD';
            lstContributionItem[2].PAP__c = 0;            
        }
        insert lstContributionItem;
        return  lstContributionItem;             
     
    }

     private static List<Contribution_Template__c> modifyAndInsertContributionTemplatesScenario8(List<Contribution_Template__c> lstContributionTemplates){
        
         if (lstContributionTemplates != null && lstContributionTemplates.size() > 0){
            lstContributionTemplates[0].Coop__c = 1.8;
            lstContributionTemplates[0].Merchandising__c = 1.7;
            lstContributionTemplates[0].Sales_Allowance__c = 0.65;
            lstContributionTemplates[0].PAP__c = 0.25;
            lstContributionTemplates[0].Cash_Discounts__c = 5.5;
            lstContributionTemplates[0].Returns__c = 6.5;
            lstContributionTemplates[0].Distribution_Cost__c = 2.5;
         }
         
         insert lstContributionTemplates;
         return lstContributionTemplates;         
     }  

    static testmethod void unitTestWithFranceMatches(){
    
        List<Account> lstAccounts = new List<Account>();
        List<Contribution_Item__c> lstContributionItem = new List<Contribution_Item__c>();
        List<Product2> lstProduct = new List<Product2>();        
        List<Contribution_Template__c> lstContributionTemplate;    
        
        List<Id> lstDPID = new List<Id>();
        //Create Contribution Template Objects and populate the data
        lstContributionTemplate = modifyAndInsertContributionTemplatesScenario8(CRM_TestDataFactory.createContributionTemplates(1, false));
        
        lstContributionItem = modifyAndInsertContributionItemsScenario8(CRM_TestDataFactory.createContributionItems(lstContributionTemplate, 3, false));
        
        //Create Account objects and populate.
        lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        for (Account objAcct : lstAccounts){
            objAcct.Sales_Organization__c = '6007';
            objAcct.Contribution_Template__c = lstContributionTemplate[0].Id;
        }       
        insert lstAccounts;
        
        lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1, true), 1, false);
        for (Product2 objProduct : lstProduct){
            objProduct.Product_Format__c = '3DHD';
            //objProduct.Distribution_Cost__c = 1111;
            objProduct.Production_Cost__c = 2222;
        }
        insert lstProduct;
        
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1, true);        
            
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;    

        // Create Opportunity objects
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
        for (Opportunity opp : lstOpportunity){
            opp.Customer_Delivery_Date__c = opp.Promo_Start_Date__c;
        }
        insert lstOpportunity;
        System.assertEquals(1, lstOpportunity.size(), 'Error while creating Opportunities');    
        
        // Create Custom settings.
        createCustomSettingsCTNProd();
        createCustomSettingsCI();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCTDP = COP_ContributionItemFields__c.getAll();
        Map<string,COP_ContributionItemFields__c> mapCustomSettingCIDP = COP_ContributionItemFields__c.getAll();
        
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCTDP.size());
        System.debug('#################################### mapCustomSettingCTDP size: ' + mapCustomSettingCIDP.size());
                
        User usr = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];      
        System.runAs(usr){
            Test.startTest();        
            // Create Deal Product objects
            List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
            for (OpportunityLineItem objDP : lstDealProduct)
                lstDPID.add(objDP.Id);
    
            // Fetch and print the stamped Deal Product Objects             
            List<OpportunityLineItem> lstDP = [select Coop__c, Merchandising__c, Returns__c, Sales_Allowance__c,
                                                Production_Cost__c, Distribution_Cost__c, Master_Negative__c,
                                                Royalty_Fee_Fixed__c FROM OpportunityLineItem WHERE Id IN: lstDPID];
            System.debug('========> lstDP: ' + lstDP);
            System.assertEquals(lstDealProduct.size(), lstDP.size(), 'Error in creating OpportunityLineItems');
            for (OpportunityLineItem objDealProduct: lstDP){
                System.assertEquals(objDealProduct.Sales_Allowance__c, lstContributionItem[0].Sales_Allowance__c, 'Error in calculating sales allowance');                
                System.assertEquals(lstContributionItem[0].Distribution_Cost__c, objDealProduct.Distribution_Cost__c , 'Error in calculating Distribution_Cost__c');
            }
            Test.stopTest();        
        }
    }    
    
}