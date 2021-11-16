global without sharing class CRM_BatchPublishAssortmentCancelSAPDeals implements Database.Batchable<OpportunityLineItem>, Database.Stateful {
    
     global Bundle__c assortment;
     global Map<Id, Opportunity> cancelDealMap;
     global CRM_PublishAssortmentHelper.PublishError[] publishErrors = new CRM_PublishAssortmentHelper.PublishError[]{};
     
     public static final Integer PUBLISH_BATCH_SIZE = 100;
     public List<OpportunityLineItem> lstOppLineItem;
     public List<Opportunity> lstDealsToUpdate = new List<Opportunity>();
     public List<OpportunityLineItem> lstDealProductsToUpdate = new List<OpportunityLineItem>();
     public Database.SaveResult[] updateResult;
     
     /*BATCH START METHOD*/
    global List<OpportunityLineItem> start(Database.BatchableContext BC){
        for(Opportunity deal : cancelDealMap.values()) {
            deal.UniquePublishKey__c = null;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            deal.Last_Published_Date__c = System.now();
            lstDealsToUpdate.add(deal);
        }
        updateResult = Database.update(lstDealsToUpdate);
        logDealUpdateErrors(lstDealsToUpdate, updateResult);
        lstOppLineItem = new List<OpportunityLineItem>([SELECT Id, UniquePublishKey__c, Last_Published_Date__c FROM OpportunityLineItem WHERE Opportunity.Id IN: cancelDealMap.keySet()]);
        return lstOppLineItem;
    }
    
    /*BATCH EXECUTE METHOD*/
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> lstDealProducts){
        
        for(OpportunityLineItem oli : lstDealProducts){
            oli.UniquePublishKey__c = null;
            oli.Last_Published_Date__c = System.now();
            lstDealProductsToUpdate.add(oli);
        }
       updateResult = Database.update(lstDealProductsToUpdate);
       logDealProductsUpdateErrors(lstDealProductsToUpdate, updateResult);
    }
    
     /*BATCH FINISH METHOD*/
    global void finish(Database.BatchableContext BC){
        CRM_BatchPublishAssortmentDeals batchProcessDeals = new CRM_BatchPublishAssortmentDeals();
        batchProcessDeals.assortment = this.assortment;
        batchProcessDeals.publishErrors = this.publishErrors;
        Database.executeBatch(batchProcessDeals, PUBLISH_BATCH_SIZE);
    }
    
    private void logDealUpdateErrors(Opportunity[] cancelDeals,  Database.SaveResult[] updateDealResults) {
        for(Integer i=0; i < updateDealResults.size(); i++) {
            if(!updateDealResults[i].isSuccess()) {
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.AccountNumber = cancelDeals[i].Account.AccountNumber;
                err.error = updateDealResults[i].getErrors().get(0).getMessage();
                
                publishErrors.add(err);
            }
        }
    }
    
     private void logDealProductsUpdateErrors(OpportunityLineItem[] dealProducts, Database.SaveResult[] updateDealProductResults) {
        for(Integer i=0; i < updateDealProductResults.size(); i++) {
            if(!updateDealProductResults[i].isSuccess()) {
                
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.AccountNumber = dealProducts[i].Opportunity.Assortment_Account__r.Account_Number__c;
                err.error = updateDealProductResults[i].getErrors().get(0).getMessage();
                
                publishErrors.add(err);
            }
        }
    }
}