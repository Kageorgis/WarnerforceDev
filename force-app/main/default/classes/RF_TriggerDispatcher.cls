/*========================================================================================================
* @author  Ajit Singh
* @date    16/09/2020
* @description: This class will be called from the RF/CAR Trigger and then will redirect to the correct Handler
      
==========================================================================================================*/
public with sharing class RF_TriggerDispatcher{

        public static void run(RF_TriggerInterface handler, String ObjectName){
    
       /*
        * Fetch the Trigger Setting Custom Metadata Records and check in which context Trigger can be executed.
        */ 
        List<RF_Trigger_Setting__mdt> triggerSettingList = new List<RF_Trigger_Setting__mdt>();
          system.debug('objectName:'+objectName);
        triggerSettingList = [Select Id, RF_Disabled__c,Trigger_Bypass_Profiles__c,Label, RF_Before_Update__c, RF_Before_Insert__c, RF_Before_Delete__c,
                              RF_After_Update__c, RF_After_Undelete__c, RF_After_Insert__c, RF_After_Delete__c, Prevent_Recurssion__c
                              From RF_Trigger_Setting__mdt  Where Label =: objectName];
            system.debug('triggerSettingList:'+triggerSettingList);
        
        execute(handler, triggerSettingList);
       
    }

     private static void execute(RF_TriggerInterface handler, List<RF_Trigger_Setting__mdt> triggerSetting){
         /*
        * Check from Custom Metadata setting whether it's enabled or not. Exit in case it's disabled.
       */
         if(triggerSetting !=null && triggerSetting.size() > 0){
             Id profileId=userinfo.getProfileId();
             String userprofileName=[Select Id,Name from Profile where Id=:profileId].Name;
                         
            List<String> byPassProfileNameList = new List<String>();
            List<string> profileNameFromMetadata= new List<String>();
             if(triggerSetting[0].Trigger_Bypass_Profiles__c!=null){
               byPassProfileNameList = triggerSetting[0].Trigger_Bypass_Profiles__c.split(',');
             }
            for(String profiles : byPassProfileNameList){
                 profileNameFromMetadata.add(profiles);
            }
            system.debug('disable trigger condition:'+profileNameFromMetadata.contains(userprofileName));
            system.debug('triggerSetting[0].RF_Disabled__c '+triggerSetting[0].RF_Disabled__c); 
            if(triggerSetting[0].RF_Disabled__c || profileNameFromMetadata.contains(userprofileName)){
             return ; 
             }
            }else{
         
             //proper trigger related exception to be thrown. It's temporary   
             throw new IllegalArgumentException('No Trigger Setting found! Please create an entry for Trigger Settings Object');

        }
        
        /*
        * If trigger is executing in before context then route to the befor context methods
       */
        if(Trigger.isBefore){
            system.debug('IN BEFORE DISPACTHER '+Trigger.isInsert +triggerSetting[0].RF_Before_Insert__c);
            if(Trigger.isInsert && triggerSetting[0].RF_Before_Insert__c){
                handler.BeforeInsert(Trigger.New);
            }
            if(Trigger.isUpdate && triggerSetting[0].RF_Before_Update__c){
                handler.BeforeUpdate(Trigger.NewMap, Trigger.oldMap);
            }
           /* if(Trigger.isDelete && triggerSetting[0].RF_Before_Delete__c){
                handler.BeforeDelete(Trigger.old, Trigger.oldMap);
            }*/
        } 
        
       /*
        * If trigger is executing in after context then route to the after context methods
        */
        If(Trigger.isAfter){
            if(Trigger.isInsert && triggerSetting[0].RF_After_Insert__c){
                handler.AfterInsert(Trigger.new, Trigger.newMap);  
            }
            
            
            /* If trigger is executing in After Update Context then Check 
               if the field have been changed or not if not do not call the hanlder
               in order to prevent the recursion
           */
           
           If(Trigger.isUpdate && triggerSetting[0].RF_After_Update__c){
               
                Map<Id, sObject> newItemsMap = new map<Id, sObject>();
                Map<Id, sObject> oldItemsMap = new map<Id, sObject>();
                List<String> fieldAPINameList = new List<String>();
               
              system.debug('Prevent_Recurssion__c:'+triggerSetting[0].Prevent_Recurssion__c);
               //if want to capture the update only on particluar field update
               if(triggerSetting[0].Prevent_Recurssion__c !=null){
                   fieldAPINameList = triggerSetting[0].Prevent_Recurssion__c.split(',');
                   system.debug('fieldAPINameList----->'+fieldAPINameList);
                   for(sObject obj : Trigger.NewMap.Values()){
                    for(String field : fieldAPINameList){
                        if(obj.get(field.trim()) != Trigger.oldMap.get(obj.Id).get(field.trim())){
                            
                            if(!newItemsMap.containsKey(obj.Id))
                                newItemsMap.put(obj.Id, obj);
                            if(!oldItemsMap.containsKey(obj.Id))
                                oldItemsMap.put(obj.id, Trigger.oldMap.get(obj.Id));
                        }
                    }
                }
                   handler.AfterUpdate(newItemsMap, oldItemsMap);
               }
               //to capture the update on any field update
               else
                   handler.AfterUpdate(trigger.newMap, trigger.OldMap);
                
            }
            
            
         /*   If(Trigger.isDelete && triggerSetting[0].RF_After_Delete__c){
                handler.AfterDelete(Trigger.oldMap);
            }
            If(Trigger.isUndelete && triggerSetting[0].RF_After_Undelete__c){
                handler.AfterUndelete(Trigger.new, Trigger.newMap);
            }*/
            
        }
    }
    
}