global class CRM_CreatePBEPBatch implements Database.Batchable<sObject>, Database.stateful {
    List<String> lstCountries = new List<String>();
    Product_Creation_Batch_Setting__c ProductCreationSetting = Product_Creation_Batch_Setting__c.getInstance('Default');
    Boolean GenerateCRMProducts = ProductCreationSetting.Generate_CRM_Product__c;
    ID soldToRecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;

    global CRM_CreatePBEPBatch(List<String> lCountries) {
        lstCountries = lCountries;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String strQuery = 'SELECT Id FROM Client_Avail__c WHERE Country_Code_3__c IN : lstCountries';
		String strQuery ='SELECT Id FROM Client_Avail__c WHERE Commercial_Avail__r.Product__c != Null AND'+
            			' Storefront__r.CRM_Account__r.RecordTypeID =: soldToRecordTypeID AND'+
            		  	' Commercial_Avail__r.Country_Lookup__r.Generate_CRM_Product__c =: GenerateCRMProducts AND'+
            			' Commercial_Avail__r.Country_Code__c IN :lstCountries';
        return Database.getQuerylocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Avail__c> scope){
        if(scope != null && !scope.isEmpty()){
				WB_PBEP_Product_CreationHandler wbPBEP = new WB_PBEP_Product_CreationHandler();
				wbPBEP.insertOrUpdatePriceBookEntryPeriod(scope);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}