@isTest
private class CRM_GeneratePBEP_Test{ 
    public static List<Pricebook_Entry_Period__c> lstPriceBookPeriod = null;
    public static List<Product2> lstProducts = new List<Product2>();
    public static List<Product_Group__c> lstProductGroup = CRM_TestDataTemplate.createProductGroups(1,true);
    
    public static testMethod void test_GeneratePBEP(){
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),1,1, true, false);
        for (Pricebook_Entry_Period__c pbjPBEP: lstPriceBookPeriod){
            pbjPBEP.Account_Price__c = 500;
            //pbjPBEP.Suggested_Price__c = 400;
            pbjPBEP.List_Price__c = 450;
        }
        
        insert lstPriceBookPeriod;
        
        delete [Select id from pricebookentry];
        
        CRM_Default_Configuration__c settingsInsatnce = CRM_Default_Configuration__c.getOrgDefaults();
        settingsInsatnce.PBEP_CreatedByUser__c = UserInfo.getUserId();
        upsert settingsInsatnce CRM_Default_Configuration__c.Id;
        
        
        CRM_GeneratePBEP objGeneratePBEP = new CRM_GeneratePBEP();
        Test.startTest();
            Database.executeBatch(objGeneratePBEP);
        Test.stopTest();
        
        system.assertEquals([Select count() from pricebookentry],1,'PriceBookEntry successfuly inserted');
    }


}