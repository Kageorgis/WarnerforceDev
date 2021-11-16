public class WB_PromotionValidateBatch implements Database.Batchable<sObject>,Database.Stateful{
    Id promotionId;
    Map<String, Country__c> mapNameCountry = new Map<String, Country__c>();
    Map<String, Account> mapNameAccount = new Map<String, Account>();
    Map<String, Agreement__c> mapNameSF = new Map<String, Agreement__c>();
    Set<Id> ptIDs = new Set<Id>();
    List<String> upsertedPTDKeys = new List<Id>();
    
    public WB_PromotionValidateBatch(Id promotionId,List<String> upsertedPTDKeys,Map<String, Country__c> mapNameCountry,Map<String, Account> mapNameAccount,Map<String, Agreement__c> mapNameSF,Set<Id> ptIDs)
    {
        this.promotionId = promotionId;
        this.upsertedPTDKeys = upsertedPTDKeys;
        this.mapNameCountry = mapNameCountry;
        this.mapNameAccount = mapNameAccount;
        this.mapNameSF = mapNameSF;
        this.ptIDs = ptIDs;
    }
    
    public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id FROM Promotion_Title__c WHERE Id IN :ptIDs]);
    }
    
    public void execute(Database.BatchableContext BC, List<Promotion_Title__c> ptRecs)
    {
        List<Id> batchPTIDs = new List<Id>();
        for(Promotion_Title__c title : ptRecs)
        {
            batchPTIDs.add(title.Id);
        }
        upsertedPTDKeys.addAll(WB_ValidatePromotionController.createlstPromoTitleDetail(
            promotionId,mapNameCountry,mapNameAccount,mapNameSF,batchPTIDs,true));
    }
    
    public void finish(Database.BatchableContext BC)
    {
        System.debug('upsertedPTDKeys==='+upsertedPTDKeys);
        //String query = 'SELECT count() FROM Promotion_Title_Detail__c WHERE Promotion__c = \''+promotionId+'\' AND PTDKey__c NOT IN '+upsertedPTDKeys;
        //System.debug('query==='+query);
        //Integer countPTD = database.countQuery(query);
        Boolean deleteResult = true;
        while(deleteResult)
        {
            deleteResult = WB_ValidatePromotionController.deletePTDs(promotionId,upsertedPTDKeys);
        }
        /*AggregateResult[] groupedResults  = [SELECT count(id)cnt  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND PTDKey__c NOT IN :upsertedPTDKeys];
        Integer countPTD = (Integer)groupedResults[0].get('cnt');
        System.debug('countPTD==='+countPTD);
        if(countPTD > 10000)
        {
            Double loopLimit = Math.ceil(countPTD/10000);
            for(Integer i=0 ; i<loopLimit ; i++)
            {
                Integer offsetVal = (i*10000);
                List<Promotion_Title_Detail__c> lstPTDs = [SELECT Id,PTDKey__c FROM Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND PTDKey__c NOT IN :upsertedPTDKeys LIMIT 10000 OFFSET :offsetVal];
                Database.delete(lstPTDs);
            }
        }
        else
        {
            List<Promotion_Title_Detail__c> lstPTDs = [SELECT Id  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND PTDKey__c NOT IN :upsertedPTDKeys];
            Database.delete(lstPTDs);
        }
        */
        /*List<Promotion_Title_Detail__c> lstPTDs = [SELECT Id  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND PTDKey__c NOT IN :insertedPTDKey];
        if(!lstPTDs.isEmpty())
        {
            Database.delete(lstPTDs);
        }*/
        if([SELECT count()  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND Status__c = 'Error'] != 0)
        {
            AsyncApexJob apexJob = [SELECT Id, NumberOfErrors, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
                //String[] toAddresses = new String[] {'Suraj.Thakur@wbconsultant.com'};
                mail.setSubject('Promotion Commit Batch Process Failed');
            
            mail.setToAddresses(toAddresses);
            
            String emailBody = 'Promotion Commit Batch Process Failed,as we have errors on below Promotion Record, Validate the Record again:\n'+
                URL.getSalesforceBaseUrl().toExternalForm() +'/' + promotionId;
            mail.setPlainTextBody(emailBody);
            //List<Client_Avail_Price__c> lstCAPs =[Select Id FROM Client_Avail_Price__c Where Promotion__c = :promoId AND Promotion_Title_Detail__c = null];
            //WB_ClientAvailTempPriceHelper.deleteOrEndDateTempPrice(lstCAPs);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else
        {
            Integer countPTDPass = database.countQuery('SELECT count() FROM Promotion_Title_Detail__c WHERE Promotion__c = \''+promotionId+'\' AND Status__c = \'Pass\'');
            Map<Id,Promotion_Title_Detail__c> mapPassPTDRecs = new Map<Id,Promotion_Title_Detail__c>();
            if(countPTDPass > 50000)
            {
                Double loopLimit = Math.ceil(countPTDPass/50000);
                for(Integer i=0 ; i<loopLimit ; i++)
                {
                    Integer offsetVal = (i*50000);
                    mapPassPTDRecs.putAll(new Map<Id,Promotion_Title_Detail__c>([SELECT ID FROM Promotion_Title_Detail__c WHERE Status__c = 'Pass' AND Promotion__c = :promotionId LIMIT 50000 OFFSET :offsetVal]));
                }
            }
            else
            {
                mapPassPTDRecs.putAll(new Map<Id,Promotion_Title_Detail__c>([SELECT ID FROM Promotion_Title_Detail__c WHERE Status__c = 'Pass' AND Promotion__c = :promotionId ]));
            }
            
            /*Map<Id,Promotion_Title_Detail__c> mapPassPTDRecs = new Map<Id,Promotion_Title_Detail__c>(
                [SELECT ID
                 FROM Promotion_Title_Detail__c
                 WHERE Status__c = 'Pass' AND Promotion__c = :promotionId]
            );*/
            WB_CommitPromotionController.callPromotionCommitBatch(mapPassPTDRecs,promotionId);
        }
        
    }
}