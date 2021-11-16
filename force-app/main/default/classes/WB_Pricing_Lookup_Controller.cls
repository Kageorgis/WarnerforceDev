public with sharing class WB_Pricing_Lookup_Controller{
    public string flag{get;set;}
    public List<pricing__c> selectcon;
    public string selectPriceCode;    
    public string localRecord;
    public Local_Title__c obj;
    public list<Local_Title__c> list_LocalData = new list<Local_Title__c>();
    public set<string> list_TitleContentType = new set<string>();
    public set<string> list_LocalCountry = new set<string>();
    public list<Pricing__c> list_SelectedPricing{get; set;}    
    public list<Pricing__c>selectedPricinglist{get; set;}
    public string defaultPrice{ get; set; }
    public set<string> distinctPriceCodeSet {get; set;}
    public list<string> distinctPriceCodeList {get; set;} // added on 5 Jan 2015
    public list<string> ListOfNames = new list<string>(); // added on 5 Jan 2015
    public String[] sortedPricingName {get; set;} 
    
    
public WB_Pricing_Lookup_Controller(ApexPages.StandardController controller){
   distinctPriceCodeList = new  list<string>();
    list_SelectedPricing = new  list<Pricing__c>();
    distinctPriceCodeSet = new set<string>();
    sortedPricingName = new List<String>();      
    localRecord =ApexPages.currentPage().getParameters().get('ID');
    obj= (Local_Title__c) controller.getRecord();
    list_LocalData = [SELECT Name,Title__c,Country__c,Title__r.Content_Type__c,Price_Code__c FROM Local_Title__c WHERE id =:localRecord];
   
     flag= list_LocalData[0].Price_Code__c;
     
    for(Local_Title__c local :list_LocalData){
        list_TitleContentType.add(local.Title__r.Content_Type__c);
        list_LocalCountry.add(local.Country__c);
    }
    list_SelectedPricing =[SELECT id,Name,Account__c,Account__r.Name,Channel__c,Content_Type__c,Country__c,Country__r.Name,Effective_Date__c,Episode_Price__c,
                            Format__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,Storefront_Currency__c,WS_Price__c  FROM Pricing__c WHERE
                            Content_Type__c IN:list_TitleContentType AND Country__c IN:list_LocalCountry AND Price_Code_Status__c = 'Active' ORDER BY Name ASC ];

   for(Pricing__c price :list_SelectedPricing ){
        if(distinctPriceCodeSet.add(price.Name)){
            sortedPricingName.add(price.Name);
        }
        
           
    } 
  
        
}

    Public void selectcon(){
        String selcontactid = System.currentPagereference().getParameters().get('conid');
        selectPriceCode = selcontactid;
        
        }
       public List<Pricing__c> getCountry() {
            return selectedPricinglist;
        }
        
        Public List<Pricing__c> getselectedPrice(){
        return selectcon;
    }

    public pageReference addCountry(){
        obj.Price_Code__c=selectPriceCode;
        try{
            update obj;
            
        }
        catch(Exception e){
        }
        pageReference pageRef= new pageReference(system.label.Redirect_Commercial_Avail_Details+localRecord );
        return pageRef;
    }
    public pageReference addCountryCancel(){
        pageReference pageRef= new pageReference(system.label.Redirect_Commercial_Avail_Details+localRecord );
        return pageRef;
    }
   
}