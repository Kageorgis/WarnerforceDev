/*
Created By - Cognizant Team
Created Date - 4/18/2017
Description - to update Owner field on Pricing record based on Digital Owner from the country object
*/

public class WB_PricingTriggerHandler {
    
    //ER-955
    //Method is used to update Owner field on Pricing record
    public static void setQueueToOwner(List<Pricing__c> listPricing){
         
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        
        if(listPricing != NULL && listPricing.size()> 0){
            for( Pricing__c pricing : listPricing){
                if(pricing.Country__c != NULL)
                setCountryid.add(pricing.Country__c);
            }    
            if(setCountryid != null && setCountryid.size() > 0){
                Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, Digital_Owner__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
                for(Pricing__c pricing : listPricing){
                   if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(pricing.Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(pricing.Country__c).Digital_Owner__c).Value__c != null){
                        pricing.OwnerId = allQueuesetting.get(mapCountry.get(pricing.Country__c).Digital_Owner__c).Value__c;
                    }
                    
                }
               
            }
        }
    }

}