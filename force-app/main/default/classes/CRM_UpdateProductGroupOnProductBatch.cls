global class CRM_UpdateProductGroupOnProductBatch implements Database.Batchable<SObject> {
        
    global Database.QueryLocator start(Database.BatchableContext context){
       //--W-017601 Added Product_owner__c,Product_Market_Entry__c,SAP_Sales_Org__c field in soql for JV project--//
        String qry = 'Select Id,Product_Format__c,Franchise_Type__c,Local_Title__c,Type__c,Product_Genre__c,Product_Label__c,Product_Market__c,Special_Version__c,Country_Code__c,Product_Price_Group__c,RecordTypeId,Display_Studio__c,Product_owner__c,Product_Market_Entry__c,SAP_Sales_Org__c From Product2 Where Process_Product_Group__c = true';
        return Database.getQueryLocator(qry);
    }
    
    global void execute(Database.BatchableContext context, List<Sobject> scope){
        List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();
        
        List<Product2> lstUpdatedProducts = CRM_ProductHandler.updateProductGroupOnProduct((List<Product2>)scope);
        System.debug('#lstUpdatedProducts' + lstUpdatedProducts);
        if(!lstUpdatedProducts.isEmpty()){
            Database.SaveResult[] result = Database.Update(lstUpdatedProducts, false);
            Product2 prod = new Product2();
            for(Integer i=0; i < result.size(); i++ ){
                prod = lstUpdatedProducts[i];
                if(!result[i].isSuccess()){
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = CRM_ProductHandler.logAnException(result[i].getErrors(), result[i].getId(), 'Error found while updating Product Group on Product=' + string.valueOf(prod.id));
                    errorLogs.addAll(errorLogInstance);
                }
            }
        }
        if(!errorLogs.isEmpty())
            CRM_ErrorLogger.logError(errorLogs);
    }
    
    global void finish(Database.BatchableContext context){}
       
}