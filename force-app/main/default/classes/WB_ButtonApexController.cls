public class WB_ButtonApexController {
    
    @AuraEnabled
    public static Promotion__c getRecord(Id promotionId)
    {
        Promotion__c promo = [
            SELECT Account_Multipicklist__c,/*Account__c,*/Channels__c,/*Client_Avail__c,*/Committed_Date__c,/*Country_Group_Id__c,
            Country_Group__c,*/Country__c,CreatedById,CreatedDate,CurrencyIsoCode,/*Currency__c,*/Description__c,End_Date__c,
            Formats__c,Id,IsDeleted,Last_Updated__c,Last_Validated__c,/*Max_Retail_Price__c,Name,Offer_Details__c,
            Placement_Specifics__c,Presidium_Siebel_Number__c,Promoted_Product_Visibility__c,Promotion_Approver__c,*/
            Promotion_Grouping__c,Promotion_Number__c,Promotion_Title_Count__c,OwnerId,/*Promotion_Owner__c,Saleforce_Promotion_Number__c,*/Start_Date__c,Status__c,
            (SELECT Id FROM Promotion_Titles__r),(SELECT Id,Status__c FROM Promotion_Title_Details__r WHERE Status__c = 'Error')
            FROM Promotion__c
            WHERE Id = :promotionId
        ];
        return promo;
    }    
    
    @AuraEnabled
    public static void deleteRecord(Promotion__c promotionRec)
    {
        List<Promotion_Title_Detail__c> lstPTD = [SELECT Id FROM Promotion_Title_Detail__c WHERE Promotion__c = :promotionRec.Id];
        if(!lstPTD.isEmpty())
        {
            DELETE lstPTD;
        }
        List<Promotion_Title__c> lstPT = [SELECT Id FROM Promotion_Title__c WHERE PromotionID__c = :promotionRec.Id];
        if(!lstPT.isEmpty())
        {
			DELETE lstPT;
        }
        List<Client_Avail_Price__c> lstCAPs = [SELECT Id FROM Client_Avail_Price__c WHERE Promotion__c = :promotionRec.Id];
        if(!lstCAPs.isEmpty())
        {
			DELETE lstCAPs;
        }
        DELETE promotionRec;
    }
    
    @AuraEnabled
    public static void updateRecord(Promotion__c promo)
    {
        WB_CommitPromotionController.cancelTempCAPs(promo.Id);
        promo.Committed_Date__c = System.now();
        UPDATE promo;
    }
    
}