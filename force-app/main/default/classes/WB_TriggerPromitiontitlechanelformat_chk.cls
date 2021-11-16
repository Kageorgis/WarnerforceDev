/* Prajakta - CTS : 5/5/16 : Commented method code as handler is getting called from inactive trigger */

public with sharing class WB_TriggerPromitiontitlechanelformat_chk{

    public static void beforeupdatepromotiontitle(){
    /*
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
         
                if(newrpromotitilevals[a].PromotionID__c == promotion_detls[b].id){
                    if(newrpromotitilevals[a].Channel__c != promotion_detls[b].Channels__c && newrpromotitilevals[a].Channel__c != null ){
                        newrpromotitilevals[a].Name.adderror('Please select vaid channel') ;  
                    }
             
                    if(newrpromotitilevals[a].Format__c != promotion_detls[b].Formats__c && newrpromotitilevals[a].Format__c != null ){
                        newrpromotitilevals[a].Name.adderror('Please select vaid format') ;  
                    }
                }
            } // For loop for b
        } // For loop for a
    */
    }
}