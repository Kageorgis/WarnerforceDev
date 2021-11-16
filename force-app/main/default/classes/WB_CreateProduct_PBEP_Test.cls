@isTest(SeeAllData=false)
public class WB_CreateProduct_PBEP_Test {
    
    @testsetup  
    public static void createTestData(){ 
        WB_PBEP_Product_CreationHandler pbepProdHandler = new WB_PBEP_Product_CreationHandler();
        List<Commercial_Avail__c> listRPRecords = [SELECT Id,Name,Product__c FROM Commercial_Avail__c];
        pbepProdHandler.assignProductToReleasePlan(listRPRecords);
        pbepProdHandler.updateAssignedProductsFromRP(listRPRecords,null);
        
        List<Client_Avail_Price__c> caList = [SELECT Id,Client_Avail__c FROM Client_Avail_Price__c];
        pbepProdHandler.insertOrUpdatePriceBookEntryPeriod(caList);
    }
}