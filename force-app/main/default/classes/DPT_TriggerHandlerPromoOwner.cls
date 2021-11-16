/******************
Created By : Navjyoti
Pupose : Promotion owner Check before update/insert Promotion

*********/
public with sharing class DPT_TriggerHandlerPromoOwner{
    public static void CheckPromoOwnerBeforeInsert(){
        list<Promotion__c> lst_trigger_newPromo = new list<Promotion__c> ();
        list<Promotion__c> lst_trigger_oldPromo = new list<Promotion__c> ();
        
        set<string> profileNames = new set<string>();
        list<string> userId = new list<string>();
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
        
        for(Promotion__c promo : lst_trigger_newPromo){
            userId.add(promo.Promotion_Owner__c);
            //acountId.add(promo.Account__c);
        }
        
        list_AccountRoles =[  SELECT id,Name,Account__c,Role__c,User__c  from Account_Role__c where Account__c IN: acountId and User__c IN:userId AND Role__c includes ('Promoter')];
        system.debug('@@@list_AccountRoles'+list_AccountRoles);
        
        list<User> userDetail = [   SELECT id,ProfileId,Profile.Name,Territory__c  from User where id IN: userId ];
        
        for(Promotion__c promo : lst_trigger_newPromo){
            integer counter =0;
            if(promo.Promotion_Owner__c != null){               
                for(User uc :userDetail){
                    if(uc.id == promo.Promotion_Owner__c){
                        if(profileNames.contains(uc.Profile.Name)){
                            flagProfile = true;
                            system.debug('@@flagProfile'+flagProfile);
                        }
                        else{
                            promo.adderror(' Please check the Promotion Owner Profile');
                        }
                    }
                }//Profile check end
                for(Account_Role__c acntRl :list_AccountRoles){
                    if(/*acntRl.Account__c == promo.Account__c && */acntRl.User__c == promo.Promotion_Owner__c){
                    counter++;  
                    }
                }
                if(counter == 0){
                    promo.adderror(' Please add Promotion Owner to the Account Role');
                }
                
            }
        }//outer loop   
        
        
    }
    public static void CheckPromoOwnerBeforeUpdate(){
        list<Promotion__c> lst_trigger_newPromo = new list<Promotion__c> ();
        list<Promotion__c> lst_trigger_oldPromo = new list<Promotion__c> ();
        
        set<string> profileNames = new set<string>();
        list<string> userId = new list<string>();
        list<string> acountId = new list<string>();
        list<Account_Role__c> list_AccountRoles = new list<Account_Role__c>();      
        boolean flagProfile = false ;       
        
        lst_trigger_newPromo = trigger.new;
        lst_trigger_oldPromo = trigger.old;
        
        //Adding profile names
        profileNames.add('WB - Territory Avails Planner');
        profileNames.add('WB - Client Avail Planner');
        profileNames.add('WB - Digital Sales'); 
        profileNames.add ('System Administrator');  
        
        for(Promotion__c promo : lst_trigger_newPromo){
            userId.add(promo.Promotion_Owner__c);
            //acountId.add(promo.Account__c );
        }
        
        list_AccountRoles =[  SELECT id,Name,Account__c,Role__c,User__c  from Account_Role__c where Account__c IN: acountId and User__c IN:userId AND Role__c includes ('Promoter')];
        system.debug('@@@list_AccountRoles'+list_AccountRoles);
        
        list<User> userDetail = [   SELECT id,ProfileId,Profile.Name,Territory__c  from User where id IN: userId ];
        
        for(Integer i =0;i<lst_trigger_newPromo.size();i++){
            //Promotion__c promo : lst_trigger_newPromo
            integer counter =0;
            if(lst_trigger_newPromo[i].Promotion_Owner__c != null ){             
                for(User uc :userDetail){
                    if(uc.id == lst_trigger_newPromo[i].Promotion_Owner__c){
                        if(profileNames.contains(uc.Profile.Name)){
                            flagProfile = true;
                            system.debug('@@flagProfile'+flagProfile);
                        }
                        else{
                            lst_trigger_newPromo[i].adderror(' Please check the Promotion Owner Profile');
                        }
                    }
                }//Profile check end
                for(Account_Role__c acntRl :list_AccountRoles){
                    if(/*acntRl.Account__c == lst_trigger_newPromo[i].Account__c && */ acntRl.User__c == lst_trigger_newPromo[i].Promotion_Owner__c){
                    counter++;  
                    }
                }
                if(counter == 0){
                    lst_trigger_newPromo[i].adderror(' Please add Promotion Owner to the Account Role');
                }
                
            }
        }//outer loop   
        
        
    }
}