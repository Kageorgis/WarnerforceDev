/**
   @Author Cognizant (Dilip Mistry)
   @name CRM_PublishAssortmentsController
   @CreateDate 10 Aug 2016
   @Description Batch job (Final Step)as part of Publish Assortment Logic to
                1) Update the deal satges to Commited/Planned as per assortment status
                2) Update the Last Publish Date on published assortment
                3) Send the confirmation email
   @Version <1.0>
*/
global without sharing class CRM_BatchPublishAssortmentFinalActions implements Database.Batchable<Opportunity>, Database.Stateful{
    global Bundle__c assortment;
    // Key -> Unique Publish Key, Value --> StageName
    global Map<String,String> mapFinalDealsStageChanges = new Map<String,String>();
    global CRM_PublishAssortmentHelper.PublishError[] publishErrors;
    
    /*BATCH START METHOD*/
    global Opportunity[] start(Database.BatchableContext BC){ 
        return [select Id, AccountId, Account.AccountNumber, StageName, UniquePublishKey__c from Opportunity where UniquePublishKey__c IN: mapFinalDealsStageChanges.keySet() ];
    }
    
    
    /*BATCH EXECUTE METHOD*/
    global void execute(Database.BatchableContext BC, List<Opportunity> listDealsForStageChange){
        for(Opportunity deal : listDealsForStageChange) {
            deal.StageName = mapFinalDealsStageChanges.get(deal.UniquePublishKey__c);
            deal.Last_Published_Date__c = System.today();
        }
        
        Database.SaveResult[] dealUpdateResults = Database.update(listDealsForStageChange, false);
        
        for(Integer i=0; i< dealUpdateResults.size(); i++) {
            if(!dealUpdateResults[i].isSuccess()) {
                CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
                err.AccountNumber = listDealsForStageChange[i].Account.AccountNumber;
                err.error = dealUpdateResults[i].getErrors().get(0).getMessage();
                
                publishErrors.add(err);
            }
        }
    }
    
    /*BATCH FINISH METHOD*/
    global void finish(Database.BatchableContext BC){
        try {
            CRM_PublishAssortmentHelper.updateAssortment(assortment);
        }
        catch(Exception ex) {
            CRM_PublishAssortmentHelper.PublishError err = new CRM_PublishAssortmentHelper.PublishError();
            err.error = ex.getMessage();
            
            publishErrors.add(err);
        }
        CRM_PublishAssortmentHelper.sendCompletionEmail(assortment, publishErrors);
    }
}