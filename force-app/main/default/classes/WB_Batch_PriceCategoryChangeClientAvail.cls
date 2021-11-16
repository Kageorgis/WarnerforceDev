public class WB_Batch_PriceCategoryChangeClientAvail implements Database.Batchable<sObject>,Database.Stateful {
    public List<CAS_Error_Log__c> lstCasErrorLog = new List<CAS_Error_Log__c>();
    public Map<String,CAS_Error_Log__c> rpIdCASErrorLogMap = new Map<String,CAS_Error_Log__c>();
    public List<Rate_Card__c> rcList = new List<Rate_Card__c>();
    
    public WB_Batch_PriceCategoryChangeClientAvail(){
        rcList = [Select Id,RC_Category__c from Rate_Card__c where SystemModStamp = LAST_N_DAYS:1];
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	Set<String> rateCardIdSet = new Set<String>();
        Date currentDate = System.today();
        
        for(Rate_Card__c rt :rcList){
            rateCardIdSet.add(rt.Id);
        }
        
        String queryString = 'Select Id,Name,Effective_Date__c,Client_Avail__c,Expiry_Date__c,Price__c,Title_Content_Type__c,RecordTypeId,RC_Category__c, CAP_Rate_Card__c,CA_Start_Date__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Category__c FROM Client_Avail_Price__c Where CAP_Rate_Card__c IN :rateCardIdSet AND Title_Content_Type__c=\'Feature\'';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Client_Avail_Price__c> scope){
        WB_ClientAvailPriceHandler.updateCatalogCAPRequiredOnCA(scope,Null,'Batch');
    }
    
    public void finish(Database.BatchableContext BC){}
}