/************
Created By : Navjyoti
Purpose : Check whether logdin user have permission to Update or Edit the Promotions
**********************/
public with sharing class DPT_TriggerHandlerPromoCreation{
    public static void CheckPromoCreatBeforeInsert(){
        list<Promotion__c> lst_trigger_newPromo = new list<Promotion__c> ();
        list<Promotion__c> lst_trigger_oldPromo = new list<Promotion__c> ();
        
        set<string> profileNames = new set<string>();
        String userId ;
        list<string> acountId = new list<string>();
        list<Account_Role__c> list_AccountRoles = new list<Account_Role__c>();      
        boolean flagProfile = false ;       
        
        lst_trigger_newPromo = trigger.new;
        lst_trigger_oldPromo = trigger.old;
        
        //Adding profile names
        profileNames.add ('WB - Territory Avails Planner');
        profileNames.add ('WB - Client Avail Planner');
        profileNames.add ('WB - Digital Sales'); 
        profileNames.add ('System Administrator');
        
        userId = Userinfo.getUserId();
        for(Promotion__c promo : lst_trigger_newPromo){            
            //acountId.add(promo.Account__c);
        }
        
        list_AccountRoles =[  SELECT id,Name,Account__c,Role__c,User__c  from Account_Role__c where Account__c IN: acountId and User__c =:userId AND Role__c includes ('Promoter')];
        system.debug('@@@list_AccountRoles'+list_AccountRoles);
        
        list<User> userDetail = [   SELECT id,ProfileId,Profile.Name,Territory__c  from User where id =: userId ];
        
        for(Promotion__c promo : lst_trigger_newPromo){
            integer counter =0;
            for(Account_Role__c acntRl :list_AccountRoles){
                if(/*acntRl.Account__c == promo.Account__c &&*/ acntRl.User__c == userDetail[0].Id){
                    counter++;  
                }
            }
            if(counter == 0){
                promo.adderror(' You donot have account role for this Account');
            }
            //Profile check
            if(profileNames.contains(userDetail[0].Profile.Name)){
                flagProfile = true;
                system.debug('@@flagProfile'+flagProfile);
            }
            else{
                promo.adderror(' Your profile is not authorized to create Promotions');
            }
        }//outer loop 
        
        
    }
    public static void CheckPromoCreatBeforeUpdate(){
        list<Promotion__c> lst_trigger_newPromo = new list<Promotion__c> ();
        list<Promotion__c> lst_trigger_oldPromo = new list<Promotion__c> ();
        
        set<string> profileNames = new set<string>();
        String userId ;
        list<string> acountId = new list<string>();
        list<Account_Role__c> list_AccountRoles = new list<Account_Role__c>();      
        boolean flagProfile = false ;       
        
        lst_trigger_newPromo = trigger.new;
        lst_trigger_oldPromo = trigger.old;
        
        //Adding profile names
        profileNames.add ('WB - Territory Avails Planner');
        profileNames.add ('WB - Client Avail Planner');
        profileNames.add ('WB - Digital Sales'); 
        profileNames.add ('System Administrator');  
        
        userId = Userinfo.getUserId();
        for(Promotion__c promo : lst_trigger_newPromo){            
            //acountId.add(promo.Account__c);
        }
        
        list_AccountRoles =[  SELECT id,Name,Account__c,Role__c,User__c  from Account_Role__c where Account__c IN: acountId and User__c =:userId AND Role__c includes ('Promoter')];
        system.debug('@@@list_AccountRoles'+list_AccountRoles);
        
        list<User> userDetail = [   SELECT id,ProfileId,Profile.Name,Territory__c  from User where id =: userId ];
        
        for(Promotion__c promo : lst_trigger_newPromo){
            integer counter =0;
            for(Account_Role__c acntRl :list_AccountRoles){
                if(/*acntRl.Account__c == promo.Account__c &&*/ acntRl.User__c == userDetail[0].Id){
                    counter++;  
                }
            }
            if(counter == 0){
                promo.adderror(' You donot have account role for this Account');
            }
            //Profile check
            if(profileNames.contains(userDetail[0].Profile.Name)){
                flagProfile = true;
                system.debug('@@flagProfile'+flagProfile);
            }
            else{
                promo.adderror(' Your profile is not authorized to update Promotions');
            }
        }//outer loop 
        // If account is changed then delete all the previous promotion countries records.
        list<string> promoIdsDel = new list<string>();
        for(Promotion__c promoNew : lst_trigger_newPromo){            
            for(Promotion__c promoOld : lst_trigger_oldPromo){
                //if(promoNew.account__c != promoOld.account__c)
                {
                    promoIdsDel.add(promoOld.Id);
                }
            }
        }
        list<Promotion_Countries__c> promoCountriesToDel = new list<Promotion_Countries__c>();
        promoCountriesToDel = [select id from Promotion_Countries__c where PromotionID__c IN:promoIdsDel];
        if(promoCountriesToDel.size() != 0 && promoCountriesToDel != NULL){
            Database.DeleteResult[] deleteResult  = Database.delete(promoCountriesToDel, false); 
        }
        
        
    }
}