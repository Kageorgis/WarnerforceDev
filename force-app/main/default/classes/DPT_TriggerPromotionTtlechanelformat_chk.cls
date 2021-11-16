public with sharing class DPT_TriggerPromotionTtlechanelformat_chk{

 public static void beforeupdatepromotiontitle(){
 
  list<Promotion_Title__c> newrpromotitilevals = new list<Promotion_Title__c>();
  list<Promotion_Title__c> oldpromotitilevals = new list<Promotion_Title__c>();
  list<Promotion__c> promotion_detls = new list<Promotion__c>();
  list<string> lst_promotions = new list<string>();
  
  system.debug('Inside WB_TriggerPromitiontitlechanelformat_chk on update event');
  system.debug('trigger.new'+trigger.new);
  system.debug('trigger.old'+trigger.old);
  
  newrpromotitilevals = trigger.new;
  oldpromotitilevals = trigger.old;
  
  for(integer i=0;i<newrpromotitilevals.size();i++){
  lst_promotions.add(newrpromotitilevals[i].PromotionID__c);
  
  }
  system.debug('lst_promotions ##'+lst_promotions);
  
  promotion_detls = [select id,name,Channels__c,Formats__c from Promotion__c where id IN :lst_promotions];
   
   system.debug('promotion_detls @@'+promotion_detls); 
   
   for(integer a=0;a<newrpromotitilevals.size();a++){
     for(integer b=0;b<promotion_detls.size();b++){
     
        //Channel for promotion detls is multi select picklist, Channel for promotitle is just picklist
        set<string> promoChannels = new set<string>();
        list<string> promoChannels2 = new list<string>();
        if( promotion_detls[b].Channels__c !=NULL){
            promoChannels2=promotion_detls[b].Channels__c.split(';'); 
            promoChannels.addAll(promoChannels2);
        
        }
        
         
         String titleChannel = String.valueOf(newrpromotitilevals[a].Channel__c);
         
         if(newrpromotitilevals[a].PromotionID__c == promotion_detls[b].id){
           
           if(!promoChannels.contains(titleChannel) && newrpromotitilevals[a].Channel__c != null ){  
              newrpromotitilevals[a].Name.adderror('The Channel selected is not valid for this promotion.') ;  
           }
         
         //Format for promotion detls is multi select picklist, Format for promo title is just picklist
         
         set<string> promoFormats = new set<string>();
        list<string> promoFormats2 = new list<string>();
        if(promotion_detls[b].Formats__c != NULL){
            promoFormats2=promotion_detls[b].Formats__c.split(';'); 
            promoFormats.addAll(promoFormats2);
         
        }
        
         String titleFormat = String.valueOf(newrpromotitilevals[a].Format__c);
         
         
         if(!promoFormats.contains(titleFormat) && newrpromotitilevals[a].Format__c != null ){  
              newrpromotitilevals[a].Name.adderror('The Format selected is not valid for this promotion.') ;  
           }
         
         }
     
     } // For loop for b
        
   } // For loop for a
   
   
   
 
 }

}