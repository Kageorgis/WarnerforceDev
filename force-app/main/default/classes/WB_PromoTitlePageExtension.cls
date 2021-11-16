public with sharing class WB_PromoTitlePageExtension {
    /*
    public ApexPages.Standardcontroller std;
    public string message {get;set;}
    public boolean editLI {get;set;}
    public string DoomedItem {get;set;}
    public integer maxName {get;set;}
    public string PromId {get;set;}
    public string titleId {get;set;}
    public string titleName {get;set;}
    
    //list of items
    public List<Promotion_Title__c> LineItems {get;set;}
    
    public WB_PromoTitlePageExtension(ApexPages.StandardController stdCtrl){
        std=stdCtrl;
        editLI=false;
        PromId=stdCtrl.getRecord().Id;
        LineItems = [Select Id, Title__r.Name, Video_Version__c, Content_Type__c, Genre__c,
            Comments__c, EST_3DHD_Pre_Promo_Consumer_Price__c, EST_3DHD_Pre_Promo_Wholesale_Cost__c,
            EST_3DHD_Promotion_Consumer_Price__c, EST_3DHD_Promotion_Wholesale_Cost__c,
            EST_3DHD_TPR_Price_Tier__c, EST_HD_Pre_Promo_Consumer_Price__c, EST_HD_Pre_Promo_Wholesale_Cost__c,
            EST_HD_Promotion_Consumer_Price__c, EST_HD_Promotion_Wholesale_Cost__c, EST_HD_TPR_Price_Tier__c,
            EST_SD_Consumer_Price__c, EST_SD_Pre_Promo_Consumer_Price__c, EST_SD_Pre_Promo_Wholesale_Cost__c,
            EST_SD_TPR_Price_Tier__c, EST_SD_Wholesale_Cost__c, Other_Expense_Details__c, Other_Expenses__c,
            Retailer_Product_ID__c, VOD_3DHD_Pre_Promo_Consumer_Price__c, VOD_3DHD_Pre_Promo_Wholesale_Cost__c,
            VOD_3DHD_Promotion_Consumer_Price__c, VOD_3DHD_Promotion_Wholesale_Cost__c, VOD_3DHD_TPR_Price_Tier__c,
            VOD_HD_Pre_Promo_Consumer_Price__c, VOD_HD_Pre_Promo_Wholesale_Cost__c, VOD_HD_Promotion_Consumer_Price__c,
            VOD_HD_TPR_Price_Tier__c, VOD_HD_Wholesale_Cost__c, VOD_SD_Pre_Promo_Consumer_Price__c,
            VOD_SD_Pre_Promo_Wholesale_Cost__c, VOD_SD_Promotion_Consumer_Price__c,
            VOD_SD_Promotion_Wholesale_Cost__c, VOD_SD_TPR_Price_Tier__c
            From Promotion_Title__c Where PromotionID__c =:PromId  ];
    }

    public PageReference Save() {
        //Save line items
        update LineItems;
        PageReference pageRef = new PageReference(ApexPages.currentPage().getURL());
        pageRef.getParameters().clear();
        pageRef.setRedirect(true);
        return pageRef;

    }
    
    public PageReference delItem(){
    Promotion_Title__c DItem = new Promotion_Title__c(id=DoomedItem);
    Delete DItem;
    PageReference pageRef = new PageReference(ApexPages.currentPage().getURL());
    pageRef.getParameters().clear();
    pageRef.setRedirect(true);
    return pageRef;
    }
    
    public PageReference newItem(){
        Promotion_Title__c item = new Promotion_Title__c();
        item.PromotionID__c=PromId;
        //item.Video_Version__c='';
        //item.Content_Type__c='';
        //item.Genre__c='';
//        item.Title__c=ApexPages.currentPage().getElementById('titleId').value;
//        insert item;
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.getParameters().clear();
        pageRef.setRedirect(true);

        return pageRef;   
    }
*/
}