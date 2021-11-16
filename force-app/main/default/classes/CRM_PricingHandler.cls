/**
   @Author-Cognizant Technology Solutions
   @name-CRM_PricingHandler
   @CreateDate-<14 april 2016>
   @Description-The class is used to Update Client Avails on update of pricing fields
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_PricingHandler{

   /**
    *  @Description - This method call the update pricing fields functionality for update operation respectively
    *  @name - UpdateClientAvailOnPricingChanged
    *  @return - void
    **/
     public void UpdateClientAvailOnPricingChanged(Map<Id,Pricing__c> mapOldPricingObj, Map<Id,Pricing__c> mapNewPricingObj) {
        
           Map<Id,Pricing__c> mapPricingObj = new Map<Id,Pricing__c>{};
           Map<Id,Client_Avail__c> mapClientAvailFetched = new Map<Id,Client_Avail__c>();
           List<Pricebook_Entry_Period__c> pbepListFetched = new List<Pricebook_Entry_Period__c>();
           List<Pricebook_Entry_Period__c> pbepListUpdated = new List<Pricebook_Entry_Period__c>();
           Map<Id,Client_Avail_Price__c> mapClientAvailPriceFetched = new Map<Id,Client_Avail_Price__c>();
           try{
               for(Pricing__c newPrices : mapNewPricingObj.values()) {
                   if(newPrices.Account_Price__c != mapOldPricingObj.get(newPrices.Id).Account_Price__c || newPrices.List_Price__c != mapOldPricingObj.get(newPrices.Id).List_Price__c
                    || newPrices.Minimum_Price__c != mapOldPricingObj.get(newPrices.Id).Minimum_Price__c) { // //US#895 -commneted code as a part of us to remove reference of suggested price. (|| newPrices.Suggested_Price__c != mapOldPricingObj.get(newPrices.Id).Suggested_Price__c)
                    mapPricingObj.put(newPrices.id,newPrices);
                    }
                }
                
                if(mapPricingObj.size() > 0 ){
                    //mapClientAvailFetched = getClientAvails(mapPricingObj);                           /* Commented by Akash*/
                    mapClientAvailPriceFetched = getClientAvailPricing(mapPricingObj);                  /* Added by Akash*/
                    if(!mapClientAvailPriceFetched.isEmpty()){
                        //pbepListFetched = getPriceBookEnteryPeriods(mapClientAvailFetched);           /* Commented by Akash*/
                        pbepListFetched = getPriceBookEnteryPeriods(mapClientAvailPriceFetched);        /* Added by Akash*/
                        if(!pbepListFetched.isEmpty()) {
                            //pbepListUpdated = updatePBEPs(mapClientAvailFetched,pbepListFetched);     /* Commented by Akash*/
                            pbepListUpdated = updatePBEPs(mapClientAvailPriceFetched,pbepListFetched);  /* Added by Akash*/ 
                        }
                        if(!pbepListUpdated.isEmpty()) {
                            update pbepListUpdated ;
                        }
                    }
                }
            }
            catch(Exception e){
                logAnException(e,null);
            }
    }    
     
    /**
        *  @Description - The method set all the date fields on PBEPS
        *  @name - updatePBEPs
        *  @return - return a collection of updated PBEP
    */
    /*Method commented by akash : Start
    public List<Pricebook_Entry_Period__c> updatePBEPs(Map<Id,Client_Avail__c> mapClientAvails, Pricebook_Entry_Period__c[] listPBEPs ) {
            
            Client_Avail__c currentClientAvail;
            for(Pricebook_Entry_Period__c pbep : listPBEPs) {
                 currentClientAvail = mapClientAvails.get(pbep.Client_Avail__c);
                 pbep.Account_Price__c = currentClientAvail.Pricing__r.Account_Price__c;
                 pbep.List_Price__c = currentClientAvail.Pricing__r.List_Price__c;
                 pbep.Minimum_Price__c = currentClientAvail.Pricing__r.Minimum_Price__c;
                 pbep.Suggested_Price__c = currentClientAvail.Pricing__r.Suggested_Price__c;
        }
     
        return listPBEPs;     
    }
    Method Commented by Akash : End*/
    
    /**
        *  @Description - The method prepares a (list) collection of Client Avails
        *  @return - return a collection of Client Avail Information
    */
    /*Method commented by akash : Start
    private Map<Id,Client_Avail__c> getClientAvails(Map<Id,Pricing__c> mapPricingObj) {
    
        Map<Id,Client_Avail__c> mapClientAvails = new Map<Id,Client_Avail__c>();
        
        mapClientAvails = new Map<Id,Client_Avail__c>([select Id, Pricing__c,Pricing__r.Account_Price__c,
                      Pricing__r.List_Price__c,Pricing__r.Minimum_Price__c,Pricing__r.Suggested_Price__c from Client_Avail__c where Pricing__c IN: mapPricingObj.keySet()]);
                        
        return mapClientAvails;
    }
    Method commented by akash : End */
    
    /**
        *  @Description - The method prepares a (list) collection of PBEP
        *  @return - return a collection of PBEP Information
    */
    /*Method Commented by Akash : Start
    private List<Pricebook_Entry_Period__c> getPriceBookEnteryPeriods(Map<Id,Client_Avail__c> mapClientAvails) {
    
        List<Pricebook_Entry_Period__c> listPBEPs = new List<Pricebook_Entry_Period__c>();
        
        listPBEPs = [select Id, Start_Date__c,End_Date__c,Client_Avail__c from Pricebook_Entry_Period__c
                        where Client_Avail__c IN: mapClientAvails.keySet()];
                        
        return listPBEPs;
    }
    Method Commented by Akash : End*/
    
    //Method added by Akash : Start
    public List<Pricebook_Entry_Period__c> updatePBEPs(Map<Id,Client_Avail_Price__c> mapClientAvailsprice, Pricebook_Entry_Period__c[] listPBEPs ) {
            
            Client_Avail_Price__c currentClientAvailPrice;
            for(Pricebook_Entry_Period__c pbep : listPBEPs) {
                 currentClientAvailPrice = mapClientAvailsprice.get(pbep.Client_Avail_Price__c);
                 pbep.Account_Price__c = currentClientAvailPrice.Pricing__r.Account_Price__c;
                 pbep.List_Price__c = currentClientAvailPrice.Pricing__r.List_Price__c;
                 pbep.Minimum_Price__c = currentClientAvailPrice.Pricing__r.Minimum_Price__c;
                 pbep.Suggested_Price__c = currentClientAvailPrice.Pricing__r.Suggested_Price__c;
        }
        return listPBEPs;     
    }
    //Method added by Akash : End
    
    //Method added by Akash : Start
     private Map<Id,Client_Avail_Price__c> getClientAvailPricing(Map<Id,Pricing__c> mapPricingObj) {
    
        Map<Id,Client_Avail_Price__c> mapClientAvailsprice = new Map<Id,Client_Avail_Price__c>();
        
        mapClientAvailsprice = new Map<Id,Client_Avail_Price__c>([select Id, Pricing__c,Pricing__r.Account_Price__c,
                      Pricing__r.List_Price__c,Pricing__r.Minimum_Price__c,Pricing__r.Suggested_Price__c from Client_Avail_Price__c where Pricing__c IN: mapPricingObj.keySet() AND CAP_CRM_Country__c = false]);
                      
        return mapClientAvailsprice;
    }
    //Method added by Akash : End
    
    //Method added by Akash : Start
    private List<Pricebook_Entry_Period__c> getPriceBookEnteryPeriods(Map<Id,Client_Avail_Price__c> mapClientAvailsprice) {
    
        List<Pricebook_Entry_Period__c> listPBEPs = new List<Pricebook_Entry_Period__c>();
        
        listPBEPs = [select Id, Start_Date__c,End_Date__c,Client_Avail_Price__c from Pricebook_Entry_Period__c
                        where Client_Avail_Price__c IN: mapClientAvailsprice.keySet()];
                      
        return listPBEPs;
    }
    //Method added by Akash : End
    
   /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public void logAnException(Exception ex, Id recordId){
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        errorLogInstance.functionalModule = 'CRM_PricingHandler';
        if(ex != null){ 
        errorLogInstance.errorMessage = ex.getMessage();}
        CRM_ErrorLogger.logError(errorLogInstance);     
    }
}