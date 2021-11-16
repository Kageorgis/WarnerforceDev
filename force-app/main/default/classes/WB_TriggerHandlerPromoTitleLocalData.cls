/******* 
WB_TriggerHandlerPromoTitleLocalData
Creation Date- 6 Nov 2014
Description- This class is to update the local data field value on Promotion title object based on the countries selected in Promotion Object
Author- Harika Bondalapati
*******/
public with sharing class WB_TriggerHandlerPromoTitleLocalData{
  
  public static void storeLocalDataWithPromotionTitle(List<Promotion_Title__c> listnew){
     List<Country__c> countryId = new List<Country__c>();
     List<Promotion__c> promotionRecord = new List<Promotion__c>(); 
     List<String> Countries = new List<String>();
     List<Promotion_Title__c> updateList = new List<Promotion_Title__c>();
     Integer count = 0;
     List<Local_Title__c> LocalList = new List<Local_Title__c>();
     List<Title__c> TitleList = new List<Title__c>();
     
    system.debug('listnew--->>>'+listnew);
     
     for(Promotion_Title__c promo:listnew){
       //get genre from Title Object
      TitleList = [select Id,Genre__c from Title__c where Id=:promo.Title__c limit 1];
      for(Title__c tl:TitleList){
          String genr = tl.Genre__c;
           promo.Genre__c = genr;
      }
      
      //get channel & format values from Promotion object
      promotionRecord = [select Id,Country__c,Formats__c,Channels__c from Promotion__c where Id=:promo.PromotionID__c limit 1];
      for(Promotion__c prom:promotionRecord){
         /* String channel = prom.Channels__c;
          promo.Channel__c = channel;
          String format = prom.Formats__c;
          promo.Format__c = format;
         */ String countrys = null;
          countrys = prom.Country__c;
          if(countrys!=null){
              Countries = countrys.split(',');
              system.debug('Countries--->>>'+Countries);
          }else{
             promo.Local_Name__c = null;
          }
      }
      
      //get the country Id from country object
      
      if(Countries.size()>0 && Countries!=null){
          countryId = [select Id from Country__c where Name IN:Countries];
      
        
      //Get Local Name from Local Data Object
      if(countryId.size()>0 && countryId!=null){
          LocalList = [select Id,Name,Title__c,Country__c,Language__c from Local_Title__c where Title__c=:promo.Title__c AND Country__c IN:countryId AND External_Company__c = Null];
      }
      system.debug('LocalList--->>>'+LocalList);
      
      //Removing the duplicate Languages
      Set<Id> localRecords = new Set<Id>();
      system.debug('localRecords--->>>'+localRecords);
      promo.Local_Name__c = null;
      for(Local_Title__c lt:LocalList){
        if(promo.Local_Name__c!=null && LocalList.size()>count && !(localRecords.contains(lt.Language__c))){
            promo.Local_Name__c = promo.Local_Name__c + ';' + lt.Name;
            localRecords.add(lt.Language__c);
        }else if(LocalList.size()>count && !(localRecords.contains(lt.Language__c))){
            promo.Local_Name__c = lt.Name;
            localRecords.add(lt.Language__c);
        }
        system.debug('LocalList.size--->>>'+LocalList.size());
        system.debug('count--->>>'+count);
        count = count+1;
      }
      system.debug('promo.Local_Name__c--->>>'+promo.Local_Name__c);
      }
     }
    
     
   }
   
}