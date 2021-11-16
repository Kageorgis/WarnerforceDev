/*******************************************************************************************************************************************
* File Name     :   WB_UpdateTaskOwnerHandler
* Description   :   Language Readiness - reassigned task owners to be remembered for future tasks
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4 Dec.2015        CTS                 ER-000399 : Created the class.
* 2.0       
********************************************************************************************************************************************/


public class WB_UpdateTaskOwnerHandler {
    
    // To update the respective Owner fields on Available langauge if someone change the owner of task
    public static void updateOwnerFields (List<Task> newList, map<Id,Task> oldMap) {
        
        set<Id> setAvailLanguageId = new set<Id>();
        List<Available_Languages__c> updateAvailLangList = new List<Available_Languages__c>();
        
        for(Task objTask : newList) {
            if (oldMap != null && objTask.OwnerId != oldMap.get(objTask.Id).OwnerId) { 
                setAvailLanguageId.add(objTask.WhatId);
            }
        }
        system.debug('------setAvailLanguageId---------'+setAvailLanguageId);
        
        if(setAvailLanguageId.size() > 0) {
            
            List<Available_Languages__c> availLangList = [Select Id, GPP_Owner__c, Mastering_Owner__c from Available_Languages__c where Id IN: setAvailLanguageId];
            
            List<Task> availTaskList = [Select Id, Subject, OwnerId, WhatId, LastModifiedDate from Task where WhatId IN: availLangList order by LastModifiedDate DESC];
            
            map<Id, List<Task>> mapALIdTotaskList = new map<Id, List<Task>>();
            for(Task objTask : availTaskList) {
                List<Task> taskList = new List<Task>();
                if(mapALIdTotaskList.containsKey(objTask.WhatId)) {
                    taskList = mapALIdTotaskList.get(objTask.WhatId);
                    taskList.add(objTask);
                } else {
                    taskList.add(objTask);
                }
                mapALIdTotaskList.put(objTask.WhatId, taskList);
            }
            system.debug('-------mapALIdTotaskList---------'+mapALIdTotaskList);
            
            for(Available_Languages__c objAL : availLangList) {
                if(mapALIdTotaskList.containsKey(objAL.Id)) {
                    List<Task> tasks = mapALIdTotaskList.get(objAL.Id);
                    if(tasks.size() > 0) {
                        //tasks.sort();
                        if(tasks[0].Subject.contains('GPP'))
                            objAL.GPP_Owner__c = tasks[0].OwnerId;
                        if(tasks[0].Subject.contains('Mastering') || tasks[0].Subject.contains('IDS'))
                            objAL.Mastering_Owner__c = tasks[0].OwnerId;
                        updateAvailLangList.add(objAL);
                    }
                }
            }
            system.debug('-------updateAvailLangList---------'+updateAvailLangList);
            
            if(updateAvailLangList.size() > 0) 
                update updateAvailLangList;
        }
    }
    
    // To update the owner with the value in respective field on available language 
    public static void updateTaskOwner (List<Task> newList) {
        set<Id> setAvailLanguageId = new set<Id>();
        List<Task> updateTaskList = new List<Task>();
        
        for(Task objTask : newList) {
            if (objTask.OwnerId != NULL) { 
                setAvailLanguageId.add(objTask.WhatId);
            } 
        }
        system.debug('------setAvailLanguageId---------'+setAvailLanguageId);
        
        if(setAvailLanguageId.size() > 0) {
            map<Id,Available_Languages__c> availLangMap = new map<Id,Available_Languages__c>([Select Id, GPP_Owner__c, Mastering_Owner__c 
                                                                                                from Available_Languages__c where Id IN: setAvailLanguageId]);
            system.debug('------availLangMap---------'+availLangMap);
            
            for(Task objTask : newList) {
                if(availLangMap != null && availLangMap.containsKey(objTask.WhatId)) {
                    if(objTask.Subject.contains('GPP') && availLangMap.get(objTask.WhatId).GPP_Owner__c != null)
                        objTask.OwnerId = availLangMap.get(objTask.WhatId).GPP_Owner__c;
                    if((objTask.Subject.contains('Mastering') || objTask.Subject.contains('IDS')) && availLangMap.get(objTask.WhatId).Mastering_Owner__c != null)
                        objTask.OwnerId = availLangMap.get(objTask.WhatId).Mastering_Owner__c;
                }
                system.debug('------objTask---------'+objTask);
            }
        }
    }
}