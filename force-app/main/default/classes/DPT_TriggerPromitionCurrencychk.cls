public with sharing class DPT_TriggerPromitionCurrencychk{

 public static void beforeupdatepromotion(){
 
  list<string> currencyval = new list<string>();
  list<string> accounts = new list<string>();
  list<Agreement__c> storefront = new list<Agreement__c>();
  
  list<Promotion__c> newvalues = new list<Promotion__c>();
  list<Promotion__c> oldvlaues = new list<Promotion__c>();
  
   system.debug('Inside TriggerPromitionCurrencychk class update event');
   system.debug('Trigger.new --->'+Trigger.new);
   system.debug('Trigger.old --->'+Trigger.old);
   
   newvalues = Trigger.new;
   oldvlaues = Trigger.old;
    
   for(integer i=0;i<newvalues.size();i++){
     //accounts.add(newvalues[i].Account__c);
     //currencyval.add(newvalues[i].Currency__c.substring(0,3)); 
  } 
  system.debug('currencyval ***'+currencyval);
  system.debug('accounts ***'+accounts);
  
  storefront = [select id, name,Country__c from Agreement__c where Account__c IN :accounts AND Pricing_Currency__c like :currencyval];
     
  system.debug('storefront  ***'+storefront );
   
   for(integer a=0;a<newvalues.size();a++){
   system.debug('inside if loop final chk');
     if(storefront.size() == 0){
        newvalues[a].name.adderror('The currency selected is not valid on the selected account') ;  
     }
   
   }
     
 } // End of function for update
 
 public static void beforeinsertpromotion(){
 
  list<string> currencyval = new list<string>();
  list<string> accounts = new list<string>();
  list<Agreement__c> storefront = new list<Agreement__c>();
  
  list<Promotion__c> newvalues = new list<Promotion__c>();
  list<Promotion__c> oldvlaues = new list<Promotion__c>();
  
   system.debug('Inside TriggerPromitionCurrencychk class insert event');
   system.debug('Trigger.new --->'+Trigger.new);
   system.debug('Trigger.old --->'+Trigger.old);
   
   newvalues = Trigger.new;
   oldvlaues = Trigger.old;
    
   for(integer i=0;i<newvalues.size();i++){
     //accounts.add(newvalues[i].Account__c);
     //currencyval.add(newvalues[i].Currency__c.substring(0,3)); 
  } 
  system.debug('currencyval ***'+currencyval);
  system.debug('accounts ***'+accounts);
  
  storefront = [select id, name,Country__c from Agreement__c where Account__c IN :accounts AND Pricing_Currency__c like :currencyval];
     
  system.debug('storefront  ***'+storefront );
   
   for(integer a=0;a<newvalues.size();a++){
   system.debug('inside if loop final chk');
     if(storefront.size() == 0){
        newvalues[a].name.adderror('The currency selected is not valid on the selected account') ;  
     }
   
   }
 
 
 
 
 }
 
 
}