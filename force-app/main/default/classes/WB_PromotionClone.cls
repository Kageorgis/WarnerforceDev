public class WB_PromotionClone {
    
    //public Id owner {get; set;}
    public Id Id { get; set; }
    public Promotion__c promo { get; set; }
    //constructor to get the Case record
    public WB_PromotionClone(ApexPages.StandardController controller) {
        //Promotion__c cloneRec = promo.clone();
        //Id = promo.Id;
        Id = controller.getId();
        promo =  [SELECT Name,OwnerId,Start_Date__c,End_Date__c,/*Promotion_Owner__c,*/Description__c,Status__c,Promotion_Grouping__c
                  FROM Promotion__c
                  WHERE Id = :Id];
        System.debug('Id==='+Id);
        //System.debug('The Promotion record: ' + promo);
        //System.debug('The Cloned Promotion record: ' + cloneRec);
        //owner = promo.Promotion_Owner__c;
    }
    
    //Method that can is called from the Visual Force page action attribute
    public PageReference clonePromotion() {
        //System.debug('Promotion Owner: ' + owner);
        System.debug('Promotion Id: ' + Id);
        Promotion__c promoRec = [SELECT Name,OwnerId,Start_Date__c,End_Date__c,/*Promotion_Owner__c,*/Description__c,Status__c,Promotion_Grouping__c,Promotion_Number__c,Account_Multipicklist__c,Country__c
                                 FROM Promotion__c
                                 WHERE Id = :Id];
        Promotion__c parentRec = cloneParentRecord(promoRec);
        
        insert parentRec;
        List<Promotion_Title__c> lstPromoTitle = [SELECT Title__c,Format__c,Channel__c,Price_Code__c,Vendor_ID__c,Price_Tier__c,WSP__c,WSP_Currency__c,/*SRP__c,*/Promo_Title_Key__c,PromotionID__c,Title__r.Video_Version__c
                                                  FROM Promotion_Title__c
                                                  WHERE PromotionID__c = :Id];
        if(!lstPromoTitle.isEmpty())
        {
            List<Promotion_Title__c> lstClonedPromoTitleRecs = cloneChildRecords(lstPromoTitle,parentRec);
            try
            {
                insert lstClonedPromoTitleRecs;
            }
            catch(Exception e)
            {
                delete parentRec;
                System.debug('Exception==='+e.getMessage());
                PageReference pageRef = new PageReference('/apex/WB_PromotionClone?id='+promoRec.Id);
                System.debug('pageRef==='+pageRef);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        System.debug('ParentRec Promotion Id: ' + parentRec.Id);
        PageReference pageRef = new PageReference('/'+parentRec.Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the case page
    }
    
    Promotion__c cloneParentRecord(Promotion__c parentRec)
    {
        Promotion__c cloneRec = new Promotion__c();
        cloneRec.Name = parentRec.Name+' Cloned '+(Integer.valueof((Math.random() * 100)));
        cloneRec.OwnerId = parentRec.OwnerId;
        cloneRec.Start_Date__c = System.today();
        cloneRec.End_Date__c = System.today();
        //cloneRec.Promotion_Owner__c = parentRec.Promotion_Owner__c;
        cloneRec.Description__c = parentRec.Description__c;
        cloneRec.Status__c = 'Draft';
        cloneRec.Promotion_Grouping__c = parentRec.Promotion_Grouping__c;
        cloneRec.Account_Multipicklist__c = parentRec.Account_Multipicklist__c;
        cloneRec.Country__c = parentRec.Country__c;
        
        return cloneRec;
    }
    
    List<Promotion_Title__c> cloneChildRecords(List<Promotion_Title__c> childRecs,Promotion__c parentRec)
    {
        List<Promotion_Title__c> clonedChildRecs = new List<Promotion_Title__c>();
        for(Promotion_Title__c pTRec : childRecs)
        {
            Promotion_Title__c clonedPTRec = new Promotion_Title__c();
            clonedPTRec.PromotionID__c = parentRec.Id;
            clonedPTRec.Title__c = pTRec.Title__c;
            clonedPTRec.Format__c = pTRec.Format__c;
            clonedPTRec.Channel__c = pTRec.Channel__c;
            clonedPTRec.Price_Code__c = pTRec.Price_Code__c;
            clonedPTRec.Vendor_ID__c = pTRec.Vendor_ID__c;
            clonedPTRec.Price_Tier__c = pTRec.Price_Tier__c;
            clonedPTRec.WSP__c = pTRec.WSP__c;
            clonedPTRec.WSP_Currency__c=pTRec.WSP_Currency__c;
            //clonedPTRec.SRP__c = pTRec.SRP__c;
            clonedPTRec.Promo_Title_Key__c = parentRec.Name+'_'+pTRec.Title__r.Video_Version__c+'_'+pTRec.Channel__c+'_'+pTRec.Format__c;
            
            clonedChildRecs.add(clonedPTRec);
        }
        return clonedChildRecs;
    }
}