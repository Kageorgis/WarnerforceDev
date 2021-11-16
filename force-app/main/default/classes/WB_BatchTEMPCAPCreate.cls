public class WB_BatchTEMPCAPCreate implements Database.Batchable<sObject>{
    Set<Id> ptdIds = new Set<Id>();
    Id promoId;
    
    public WB_BatchTEMPCAPCreate(Set<Id> ptdIds,Id promoId)
    {
        this.ptdIds = ptdIds;
        this.promoId = promoId;
    }
    
    public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id, Promotion_Title__r.PromotionId__c,Wholsale_Price__c,
                                         Price_Tier__c,Promotion_Title__r.PromotionId__r.Name,
                                         Promotion_Title__r.PromotionId__r.Start_Date__c,
                                         Promotion_Title__r.PromotionId__r.End_Date__c,Client_Avail_Names__c,
                                         Client_Avail_Count__c,Rate_Card__c
                                         FROM Promotion_Title_Detail__c
                                         WHERE Id IN :ptdIds]
                                       );
    }
    
    public void execute(Database.BatchableContext BC, List<Promotion_Title_Detail__c> lstPTD)
    {
        List<WB_ClientAvailTempPriceWrapper> clientAvailTempPriceWrapperList = new List<WB_ClientAvailTempPriceWrapper>();
        List<String> caNames = new List<String>();
        for(Promotion_Title_Detail__c ptd: lstPTD){
            List<String> caNameSplit = new List<String>();
            caNameSplit = ptd.Client_Avail_Names__c.split(';');
            caNames.addAll(caNameSplit);
        }
        System.debug('caNames==='+caNames);
        Map<String,Id> mapCANameId = new map<String,Id>();
        for(Client_Avail__c ca : [SELECT Id,Name FROM Client_Avail__c WHERE Name IN :caNames])
        {
            mapCANameId.put(ca.Name,ca.Id);
        }
        for(Promotion_Title_Detail__c ptd: lstPTD){
            for(String caName : ptd.Client_Avail_Names__c.split(';'))
            {
                WB_ClientAvailTempPriceWrapper tempPriceWrapper = new WB_ClientAvailTempPriceWrapper();
                tempPriceWrapper.clientAvailId = mapCANameId.get(caName);
                tempPriceWrapper.promoTitleDetailId = ptd.id;
                tempPriceWrapper.promotionId=ptd.Promotion_Title__r.PromotionId__c;
                tempPriceWrapper.price = ptd.Wholsale_Price__c; // Promo Price
                tempPriceWrapper.priceTier = ptd.Price_Tier__c; 
                tempPriceWrapper.priceStartDate = ptd.Promotion_Title__r.PromotionId__r.Start_Date__c; //pricing start date
                tempPriceWrapper.priceEndDate = ptd.Promotion_Title__r.PromotionId__r.End_Date__c; // Pricing End Date
                tempPriceWrapper.priceType = 'TEMP'; //Default 
                tempPriceWrapper.priceStatus = 'Active'; //Default
                tempPriceWrapper.promotionStatus = 'Committed';
                tempPriceWrapper.rateCardId = ptd.Rate_Card__c;
                clientAvailTempPriceWrapperList.add(tempPriceWrapper);
            }
        }
        System.debug('clientAvailTempPriceWrapperList==='+clientAvailTempPriceWrapperList.size()); 
        /*WB_Promo_ClientAvailTempPriceHelper CAPhelper = new WB_Promo_ClientAvailTempPriceHelper(); 
		CAPhelper.upsertTempPrice(clientAvailTempPriceWrapperList);*/
        WB_ClientAvailTempPriceHelper CAPhelper = new WB_ClientAvailTempPriceHelper(); 
        CAPhelper.upsertPromoTempPrice(clientAvailTempPriceWrapperList,true);
    }
    
    public void finish(Database.BatchableContext BC)
    {
        //deleteOrEndDateTempPrice
        AsyncApexJob apexJob = [SELECT Id, NumberOfErrors, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
            //String[] toAddresses = new String[] {'Suraj.Thakur@wbconsultant.com'};
            mail.setSubject('Promotion Commit Batch Process Status');
        
        mail.setToAddresses(toAddresses);
        
        String emailBody = 'Promotion Commit Batch Process completed.\n'+
            'Records processed ' + apexJob.TotalJobItems + ' with '+ apexJob.NumberOfErrors + ' failures.\n'+
            'Please click on the below link for the Promotion Record:\n'+
            URL.getSalesforceBaseUrl().toExternalForm() +'/' + promoId;
        mail.setPlainTextBody(emailBody);
        Promotion__c promo = [SELECT Id,Committed_Date__c,Status__c FROM Promotion__c WHERE Id = :promoId];
        promo.Committed_Date__c = System.now();
        promo.Status__c = 'Committed';
        update promo;
        List<Client_Avail_Price__c> lstCAPs =[Select Id FROM Client_Avail_Price__c Where Promotion__c = :promoId AND Promotion_Title_Detail__c = null];
        WB_ClientAvailTempPriceHelper.deleteOrEndDateTempPrice(lstCAPs);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}