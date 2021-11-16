global class WB_CommitPromotionController {
    global Id promotionId{get;set;}
    global String handsontableversion{get; set;}
    global Decimal ptPTDChunkSize{get; set;}
    global Decimal commitThresholdSize{get; set;}
    
    global WB_CommitPromotionController(ApexPages.StandardController ctrl ){
        Map<String, WB_Promotion_Limits__c> promoLimits = WB_Promotion_Limits__c.getAll();
        promotionId = ctrl.getId();
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().HandsonTable_Pro_Version__c;
        ptPTDChunkSize = promoLimits.get('Commit PTD Chunk Size').Limit_Size__c;
        commitThresholdSize = promoLimits.get('Commit Batch Process Threshold').Limit_Size__c;
    }
    
    @RemoteAction
    global static void callPromotionCommitBatch(Map<Id,Promotion_Title_Detail__c> mapPTDRecs,Id promotionId)
    {
        Promotion__c promoRec = [SELECT Id,Promotion_Number__c FROM Promotion__c WHERE Id = :promotionId];
        /*Map<Id, Promotion_Title__c> mapPromoTitle = new Map<Id, Promotion_Title__c>([SELECT ID FROM Promotion_Title__c WHERE PromotionID__c = :promoRec.Id]);
System.debug('mapPromoTitle==='+mapPromoTitle.keySet());*/
        /*Map<Id,Promotion_Title_Detail__c> mapPTDRecs = new Map<Id,Promotion_Title_Detail__c>(
[SELECT ID
FROM Promotion_Title_Detail__c
WHERE Promotion_Title__c != null AND Status__c = 'Pass' AND Promotion__c = :promoRec.Id]
);*/
        System.debug('mapPTDRecs==='+mapPTDRecs);
        Database.executeBatch(new WB_BatchTEMPCAPCreate(mapPTDRecs.keySet(),promoRec.Id),10);
    }
    
    @RemoteAction
    global static void createTEMPCAP(Id promotionId)
    {
        Map<Id,Promotion_Title_Detail__c> mapPTDRecs = new Map<Id,Promotion_Title_Detail__c>(
            [SELECT ID, Promotion_Title__r.PromotionID__c,Wholsale_Price__c,Price_Tier__c,Promotion_Title__r.PromotionID__r.Name,
             Promotion_Title__r.PromotionID__r.Start_Date__c,Promotion_Title__r.PromotionID__r.End_Date__c,Client_Avail_Names__c,
             Client_Avail_Count__c, Account__c, Country__c, Channel__c, Format__c, Title__r.Content_Type__c,Rate_Card__c
             FROM Promotion_Title_Detail__c
             WHERE Promotion__c = :promotionId AND Status__c = 'Pass' LIMIT 50000]
        );
        System.debug('mapPTDRecs==='+mapPTDRecs);
        List<WB_ClientAvailTempPriceWrapper> clientAvailTempPriceWrapperList = new List<WB_ClientAvailTempPriceWrapper>();
        List<String> caNames = new List<String>();
        for(Promotion_Title_Detail__c ptd: mapPTDRecs.values()){
            List<String> caNameSplit = new List<String>();
            caNameSplit = ptd.Client_Avail_Names__c.split(';');
            caNames.addAll(caNameSplit);
        }
        System.debug('caNames==='+caNames);
        Map<String,Id> mapCANameId = new map<String,Id>();
        for(Client_Avail__c ca : [SELECT Id,Name FROM Client_Avail__c WHERE Name IN :caNames  LIMIT 50000])
        {
            mapCANameId.put(ca.Name,ca.Id);
        }
        for(Promotion_Title_Detail__c ptd: mapPTDRecs.values())
        {
            for(String caName : ptd.Client_Avail_Names__c.split(';'))
            {
                System.debug('caName==='+caName);
                if(caName != null || caName != '')
                    //if((caName != null || caName != '') && caName != 'CA-0001491699')
                {
                    WB_ClientAvailTempPriceWrapper tempPriceWrapper = new WB_ClientAvailTempPriceWrapper();
                    tempPriceWrapper.clientAvailID = mapCANameId.get(caName);
                    tempPriceWrapper.promoTitleDetailID = ptd.id;
                    tempPriceWrapper.promoTitleDetailRec = ptd;
                    tempPriceWrapper.promotionId=ptd.Promotion_Title__r.PromotionID__c;
                    tempPriceWrapper.price = ptd.Wholsale_Price__c; // Promo Price
                    tempPriceWrapper.priceTier = ptd.Price_Tier__c; 
                    tempPriceWrapper.priceStartDate = ptd.Promotion_Title__r.PromotionID__r.Start_Date__c; //pricing start date
                    tempPriceWrapper.priceEndDate = ptd.Promotion_Title__r.PromotionID__r.End_Date__c; // Pricing End Date
                    tempPriceWrapper.priceType = 'TEMP'; //Default 
                    tempPriceWrapper.priceStatus = 'Active'; //Default
                    tempPriceWrapper.promotionStatus = 'Committed';
                    tempPriceWrapper.rateCardId = ptd.Rate_Card__c;
                    clientAvailTempPriceWrapperList.add(tempPriceWrapper);
                }
            }
        }
        System.debug('clientAvailTempPriceWrapperList==='+clientAvailTempPriceWrapperList); 
        WB_ClientAvailTempPriceHelper CAPhelper = new WB_ClientAvailTempPriceHelper(); 
        CAPhelper.upsertPromoTempPrice(clientAvailTempPriceWrapperList,false);
        Promotion__c promo = [SELECT Id,Committed_Date__c,Status__c FROM Promotion__c WHERE Id = :promotionId];
        promo.Committed_Date__c = System.now();
        promo.Status__c = 'Committed';
        update promo;        
    }
    
    @RemoteAction
    global static MapPTDWrapper findDeltaPTD(Id promotionId, Decimal commitThresholdSize)
    {
        Boolean isError = false;
        Map<String, TempPTDRecWrapper> mapPTDRecs = new Map<String, TempPTDRecWrapper>();
        WB_ValidatePromotionController.MapWrapper mapWrapperObj = WB_ValidatePromotionController.fetchPromoTitleRec(promotionId,true);
        List<String> lstPTDIds = mapWrapperObj.upsertedKeys;
        Integer countPTD= database.countQuery('SELECT count() FROM Promotion_Title_Detail__c WHERE Promotion__c = \''+promotionId+'\'');
        
        /*if(countPTD > 50000)
{
Double loopLimit = Math.ceil(countPTD/50000);
for(Integer i=0 ; i<loopLimit ; i++)
{
Integer offsetVal = (i*50000);
for(Promotion_Title_Detail__c ptdRec : [SELECT Id,PTDKey__c,Price_Tier__c,Wholsale_Price__c FROM Promotion_Title_Detail__c WHERE Promotion__c = :promotionId LIMIT 50000 OFFSET :offsetVal])
{
mapPTDRecs.put(ptdRec.PTDKey__c, new TempPTDRecWrapper(ptdRec));
}
}
}
else
{
for(Promotion_Title_Detail__c ptdRec : [SELECT Id,PTDKey__c,Price_Tier__c,Wholsale_Price__c,Status__c FROM Promotion_Title_Detail__c WHERE Promotion__c = :promotionId])
{
mapPTDRecs.put(ptdRec.PTDKey__c, new TempPTDRecWrapper(ptdRec));
if(ptdRec.Status__c.equals('Error'))
{
isError = true;
}
}
}*/
        
        if(countPTD > commitThresholdSize)
        {
            Database.executeBatch(new WB_PromotionValidateBatch(promotionId,lstPTDIds,mapWrapperObj.mapNameCountry,mapWrapperObj.mapNameAccount,mapWrapperObj.mapNameSF,mapWrapperObj.ptIDs),10);
            return new MapPTDWrapper(isError,true);
        }
        else
        {
            lstPTDIds.addAll(WB_ValidatePromotionController.createlstPromoTitleDetail(
                promotionId,mapWrapperObj.mapNameCountry,mapWrapperObj.mapNameAccount,mapWrapperObj.mapNameSF,new List<Id>(mapWrapperObj.ptIDs),true
            ));
            
            Database.delete([SELECT Id FROM Promotion_Title_Detail__c WHERE Id= :promotionId AND PTDKey__c NOT IN :lstPTDIds]);
            Integer countPTDError = database.countQuery('SELECT count() FROM Promotion_Title_Detail__c WHERE Promotion__c = \''+promotionId+'\' AND Status__c=\'Error\'');
            if(countPTDError > 0)
            {
                isError = true;
            }
            MapPTDWrapper mapPTDWrapperObj = new MapPTDWrapper(isError,false);
            return mapPTDWrapperObj;
        }
    }
    
    @RemoteAction
    global static Boolean cancelTempCAPs(Id promotionId)
    {
        List<Client_Avail_Price__c> lstCAPs = [SELECT Id FROM Client_Avail_Price__c WHERE Promotion__c = :promotionId LIMIT 50000];
        if(!lstCAPs.isEmpty())
        {
            return WB_ClientAvailTempPriceHelper.deleteOrEndDateTempPrice(lstCAPs);
        }
        return true;
    }
    
    global class MapPTDWrapper
    {
        Boolean isError;
        Boolean isCountMore;
        MapPTDWrapper(Boolean isError, Boolean isCountMore)
        {
            this.isError = isError;
            this.isCountMore = isCountMore;
        }
    }
    
    global class TempPTDRecWrapper{
        global Promotion_Title_Detail__c ptdRec;
        global Boolean isDelete;
        
        global TempPTDRecWrapper(Promotion_Title_Detail__c ptdRec)
        {
            this.ptdRec = ptdRec;
            this.isDelete = true;
        }
    }
}