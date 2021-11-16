global class WB_ValidatePromoNewController{
    global Id promotionId{get;set;}
    global Promotion__c promotionrecord{get;set;}
    global String handsontableversion{get; set;}
    global List<PromotionTitleDetailWrapper> ptdRecs{get; set;}
	global String recordTypeVal{get; set;}
    
    /* Contractor to get Id of pormotion from URL 
* get handson license key and version to apply 
*/

    Global WB_ValidatePromoNewController(ApexPages.StandardController ctrl ){
        promotionId = ctrl.getId();
        promotionrecord = [select id, promotion_number__c from Promotion__c where id =:promotionId];
        ptdRecs = getPTDRecords(promotionId,recordTypeVal);
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().HandsonTable_Pro_Version__c;
        
    }

        global WB_ValidatePromoNewController(){
        recordTypeVal = Apexpages.currentPage().getParameters().get('recTypeVal');
        promotionId = Apexpages.currentPage().getParameters().get('promoId');
        ptdRecs = getPTDRecords(promotionId,recordTypeVal);
    }
    /*Method to show error records,all records ,warning records and pass records based on filter applied
* method name :getPTDRecords
* parameter :PromotionId and Record Type 
* Return : list of PTD Records
*/
    @RemoteAction
    global static List<PromotionTitleDetailWrapper> getPTDRecords(Id promotionId,String recordTypeVal){
        System.debug('In getPTDRecords');
        List<Promotion_Title_Detail__c> promoTD = new List<Promotion_Title_Detail__c>();
        List<PromotionTitleDetailWrapper> wrapperToReturnAllRec = new List<PromotionTitleDetailWrapper> ();
        List<PromotionTitleDetailWrapper> wrapperToReturnErrorRec = new List<PromotionTitleDetailWrapper> ();
        List<PromotionTitleDetailWrapper> wrapperToReturnWarningRec = new List<PromotionTitleDetailWrapper> ();
        List<PromotionTitleDetailWrapper> wrapperToReturnPassRec = new List<PromotionTitleDetailWrapper> ();
        
        String queryString = 'SELECT Id,name,Account__c,Account__r.name, Channel__c,Country__c,Country__r.name,Format__c,Promotion_Title__c,Title__c,Status__c,Comments__c,'+
            +'Title__r.Name,Price_Tier__c,WSP_Currency__c,Client_Avail__c,Title__r.Content_Type__c,Client_Avail_Count__c,Promotion__c,Wholsale_Price__c,'+
            +'Client_Avail__r.Name,Title__r.Video_Version__c,Promotion_Title__r.Price_Code__c,Promotion__r.Name, Promotion_Title__r.Name'+
            ' FROM Promotion_Title_Detail__c WHERE Promotion__c = :promotionId';
        promoTD = Database.query(queryString);                         
        system.debug('All records ----'+promoTD.size());
        system.debug('recordTypeVal  ----'+recordTypeVal);
        
        if(recordTypeVal == 'AllRec'){
            for(Promotion_Title_Detail__c ptdRec : promoTD){
                PromotionTitleDetailWrapper pt = mapFields(ptdRec);
                wrapperToReturnAllRec.add(pt);
            }
            return wrapperToReturnAllRec;
        }
        
        else if(recordTypeVal == 'ErrorRec'){
            for(Promotion_Title_Detail__c ptdRec : promoTD){
                if(ptdRec.Status__c == 'Error'){
                    PromotionTitleDetailWrapper pt = mapFields(ptdRec);
                    wrapperToReturnErrorRec.add(pt);
                }
            }
            return wrapperToReturnErrorRec;
        }
        
        
        else if(recordTypeVal == 'WarningRec'){
            for(Promotion_Title_Detail__c ptdRec : promoTD){
                if(ptdRec.Status__c == 'Warning'){
                    PromotionTitleDetailWrapper pt = mapFields(ptdRec);
                    wrapperToReturnWarningRec.add(pt);
                }
            }
            return wrapperToReturnWarningRec;
        }
        
        else if(recordTypeVal == 'PassRec'){
            for(Promotion_Title_Detail__c ptdRec : promoTD){
                if(ptdRec.Status__c == 'Pass'){
                    PromotionTitleDetailWrapper pt = mapFields(ptdRec);
                    wrapperToReturnPassRec.add(pt);
                }
            }
            return wrapperToReturnPassRec;
        }
        else{
            return null;
        }
        
    }
    
    public static PromotionTitleDetailWrapper mapFields(Promotion_Title_Detail__c ptdRec){
        PromotionTitleDetailWrapper pt = new PromotionTitleDetailWrapper();
        // pt.ptName = ptdRec.name;
        
        pt.accountName = ptdRec.Account__r.Name;
        pt.titleName = ptdRec.Title__r.Name;
        pt.videoversion=ptdRec.Title__r.Video_Version__c;
        pt.ContentType = ptdRec.Title__r.Content_Type__c;
        pt.country = ptdRec.Country__r.Name;
        pt.channel = ptdRec.Channel__c;
        pt.format = ptdRec.Format__c;
        pt.pricecode= ptdRec.Promotion_Title__r.Price_Code__c;
        pt.PriceTier = ptdRec.Price_Tier__c;
        pt.WSP = String.valueOf(ptdRec.Wholsale_Price__c);
        pt.StorefrontWSPCurrency = ptdRec.WSP_Currency__c;
        pt.ClientAvailCount = String.valueOf(ptdRec.Client_Avail_Count__c);
        pt.PromotionName = ptdRec.Promotion__r.Name;
        pt.PromotionTitleName = ptdRec.Promotion_Title__r.Name;
        pt.status = ptdRec.Status__c;
        pt.comments = ptdRec.Comments__c;
        
        
        
        // pt.EpisodePriceTier = ptdRec.Episode_Price_Tier__c;
        
        
        
       // pt.Language = ptdRec.Language__c;
        //pt.Promotion = ptdRec.Promotion__c;
        //pt.PromotionTitle = ptdRec.Promotion_Title__c;
        
        //pt.ClientAvailName = ptdRec.Client_Avail__r.Name;
       // pt.LanguageName = ptdRec.Language__r.Name;
        
        return pt;
    }
    
    global class PromotionTitleDetailWrapper{
        // public String ptName;
        public String status;
        public String channel;
        public String format;
        public String accountName;
        public String videoversion;
        public String country;
        // Public String comments;
        public String pricecode;
        public String titleName;
       // public String EpisodePriceTier;
        public String PriceTier;
        public String ClientAvailCount;
        public String ContentType;
         Public String Language; 
        // public String Promotion;
        // public String PromotionTitle;
        public String WSP;
        //  public String ClientAvailName;
        //public String LanguageName;
        public String PromotionName;
        public String PromotionTitleName;
        public String comments;
        public String StorefrontWSPCurrency;
    }
}