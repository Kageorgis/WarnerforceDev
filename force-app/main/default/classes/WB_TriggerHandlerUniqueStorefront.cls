/******* 
Name:WB_TriggerHandlerUniqueStorefront
Creation Date- 8th Sept'2014
Description- Trigger Handler for Unique ness of Storefront
Author- Navjyoti Mohanta
********/

public with sharing class WB_TriggerHandlerUniqueStorefront{
    
    //ER-955
    //Created - 4/18/2017
    
    //Method is used to update Owner field on Storefront record
    public static void setQueueToOwner(List<Agreement__c> listStorefront){
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        
        if(listStorefront != NULL && listStorefront.size()> 0){
            for( Agreement__c storefront : listStorefront ){
                if(storefront.Country__c != NULL)
                setCountryid.add(storefront.Country__c);
            }    
            if(setCountryid != null && setCountryid.size() > 0){
                Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, Digital_Owner__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
                for(Agreement__c storefront : listStorefront){
                    if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(storefront.Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(storefront.Country__c).Digital_Owner__c).Value__c != null){
                        storefront.OwnerId = allQueuesetting.get(mapCountry.get(storefront.Country__c).Digital_Owner__c).Value__c;
                    }
                }
            }
        }
    }
    
    public static void UniqueStorefront(){
        list<Agreement__c> storefrontList = new list<Agreement__c>();
        list<Agreement__c> existingStorefrontList = new list<Agreement__c>();
        list<string> selectedAcc = new list<string>();
        list<string> selectedCountry = new list<string>();
        storefrontList =Trigger.new;
            for(integer i=0;i<storefrontList.size();i++ ){
            selectedAcc.add(storefrontList[i].Account__c);
            selectedCountry .add(storefrontList[i].Country__c);
            }
        existingStorefrontList =[SELECT id,Account__c,Country__c  FROM Agreement__c where Account__c in:selectedAcc and Country__c in: selectedCountry  ];
        
         if(existingStorefrontList.size()>0 ){
           if(existingStorefrontList.size()>=storefrontList.size()){
            for(integer i=0;i<existingStorefrontList.size();i++){
                for(integer j=0;j<storefrontList.size();j++){
                    if(existingStorefrontList[i].Account__c == storefrontList[j].Account__c &&
                       existingStorefrontList[i].country__c == storefrontList[j].Country__c){
                       storefrontList[j].addError('Please select the different combination of Country and Account ');
                    }
                }    
            }        
         }  
         
        else{
         
            for(integer i=0;i<storefrontList.size();i++){
                for(integer j=0;j<existingStorefrontList.size();j++){
                    if(storefrontList[i].Account__c == existingStorefrontList[j].Account__c &&
                       storefrontList[i].country__c == existingStorefrontList[j].Country__c){
                           storefrontList[i].addError('Please select the different combination of Country and Account ');
                    }
                }    
            }        
        }  
       } 
        
    }
    public static void UniqueStorefrontOnUpdate(){
    
        list<Agreement__c> newStorefrontList = new list<Agreement__c>();
        list<Agreement__c> oldStorefrontList = new list<Agreement__c>();
        list<Agreement__c> existingStorefrontList = new list<Agreement__c>();

        list<string> selectedNewAcc = new list<string>();
        list<string> selectedNewCountry = new list<string>();
        list<string> selectedOldAcc = new list<string>();
        list<string> selectedOldCountry = new list<string>();
        boolean nochangeFlag= false;
        
        newStorefrontList =Trigger.new;
        oldStorefrontList =Trigger.old;
        
        
           for(integer i=0;i<newStorefrontList.size();i++ ){
            selectedNewAcc.add(newStorefrontList [i].Account__c);
            selectedNewCountry.add(newStorefrontList [i].Country__c);
            }
            
            
         for(integer i=0;i<oldStorefrontList.size();i++ ){
            selectedOldAcc.add(oldStorefrontList [i].Account__c);
            selectedOldCountry.add(oldStorefrontList [i].Country__c);
            }
            
       
       existingStorefrontList =[SELECT id,Account__c,Country__c  FROM Agreement__c where 
                                Account__c in: selectedNewAcc and Country__c in: selectedNewCountry];     
       
        for(integer a=0; a< newStorefrontList.size();a++)
        {   
                        
             if(selectedNewAcc[a] !=selectedOldAcc[a] || selectedNewCountry[a]!=selectedOldCountry[a])
             {
                nochangeFlag= true;
             }  
         }  
         
            if(nochangeFlag){
             for(integer i=0;i<existingStorefrontList.size();i++){
                for(integer j=0;j<newStorefrontList.size();j++){
                    
                    if(existingStorefrontList[i].Account__c == newStorefrontList[j].Account__c &&
                       existingStorefrontList[i].country__c == newStorefrontList[j].Country__c){
                       newStorefrontList[j].addError('Please select the different combination of Country and Account !!!');
                    }
                }    
            } 
          }   
         
    }
    
    public static void assignChannelFormatValues(Map<Id,Agreement__c> oldMap,List<Agreement__c> storefrontNewList){
        
        if(storefrontNewList != Null && storefrontNewList.size()>0){
            
            if(oldMap != Null){
                
                for(Agreement__c newSfRec : storefrontNewList){
                    
                    Agreement__c oldSfRec = oldMap.get(newSfRec.Id);
                    if(oldSfRec.Channel_Picklist__c != newSfRec.Channel_Picklist__c){
                        newSfRec.Channels_Values__c = newSfRec.Channel_Picklist__c;
                    }
                    
                    if(oldSfRec.Format__c != newSfRec.Format__c){
                        newSfRec.Formats_Values__c = newSfRec.Format__c;
                    }
                    
                    if(oldSfRec.Content_Type__c != newSfRec.Content_Type__c){
                        newSfRec.ContentType_Values__c = newSfRec.Content_Type__c;
                    }
                    
                    if(oldSfRec.HDR__c != newSfRec.HDR__c){
                        newSfRec.HDR_Values__c = newSfRec.HDR__c;
                    }
                    
                }
                
            }else{
                for(Agreement__c newSfRec : storefrontNewList){
                    newSfRec.Channels_Values__c = newSfRec.Channel_Picklist__c;
                    newSfRec.Formats_Values__c = newSfRec.Format__c;
                    newSfRec.ContentType_Values__c = newSfRec.Content_Type__c;
                    newSfRec.HDR_Values__c = newSfRec.HDR__c;
                }
                
            }
            
        }
    }
    
}