/****
Name:WB_PreventvideoversionUpdateController
Creation Date- 14 Nov 2014
Last Modified Date - 14 Nov 2014
Last Modified by  - Imran on 4 Dec 2014
Author- Tejas Mulye
Description-     This is trigger class which prevent user from editing video version of title means 
                 it will overwrite new Video version value by old value.
****/

public with sharing class WB_PreventvideoversionUpdateController{
    
    public List<User> userDetail = new List<User>();
    public static void updatevideoversion(){
    
        String LoggedInUserProfileName;
        List <User> userDetail = [SELECT Profile.Name, id, UserType,Territory__c FROM User  
                                  WHERE id = :Userinfo.getUserId()];
    
        for(User u:userDetail){
            LoggedInUserProfileName = u.Profile.Name;
       }
       
     
     if(LoggedInUserProfileName  != Label.Integration_Profile && LoggedInUserProfileName  != Label.System_Administrator){
         list<Title__c> lst_oldtitlerecs = new list<Title__c>();
         list<Title__c> lst_newtitlerecs = new list<Title__c>();
         
         lst_oldtitlerecs = trigger.old;
         lst_newtitlerecs = trigger.new;
         
        for(integer i=0;i<lst_newtitlerecs.size();i++){
            //for(integer y=0;y<lst_oldtitlerecs.size();y++){
                Title__c oldTitle = (Title__c)trigger.oldmap.get(lst_newtitlerecs[i].id);
                if(lst_newtitlerecs[i].Video_Version__c != oldTitle.Video_Version__c){
                    lst_newtitlerecs[i].Video_Version__c = oldTitle.Video_Version__c;
                } 
           // }
        }
      }
    }
    
    /*
     Author: Preeti jha
     Date: 13th dec 2016
     Description: CRRTS Phase 2
    */
    public static void setQueueToLocalDataOwner(List<Title__c> lstTitle){
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        List<Local_Title__c> listLocalDataUpdate = new List<Local_Title__c>();
        List<Local_Title__c> listSDSLocalDataUpdate = new List<Local_Title__c>();
        
        List<Local_Title__c> listLocalTitles = [Select Id,Title_Physical_Planning__c,Title_Digital_Planning__c,Country__c,OwnerId,HBO_Owner__c,Turner_Owner__c,External_Company__c from Local_Title__c where Title__c IN: lstTitle limit 10000];
        if(lstTitle != null && lstTitle.size() > 0){
            for(Local_Title__c LocalData: listLocalTitles){
                setCountryid.add(LocalData.Country__c);
                
            }
            Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, Digital_Owner__c, Physical_Owner__c,HBO_Override__c,Turner_Override__c,SDS_Owner__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
            for(Local_Title__c LocalData:listLocalTitles ){
                //ER-006850 - CAS-Restrict SDS Local Data records visibility to all CAS and ECLM business user
                if(LocalData.External_Company__c != Null){
                    if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(LocalData.Country__c).SDS_Owner__c) != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).SDS_Owner__c).Value__c != null){
                        LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).SDS_Owner__c).Value__c;
                        listSDSLocalDataUpdate.add(LocalData);
                    }
                    continue;
                }
			    if(LocalData.HBO_Owner__c != null || LocalData.Turner_Owner__c != null)
			        continue;
                if(LocalData.Title_Physical_Planning__c == 'Yes'){
                    if(allQueuesetting != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c) != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c).Value__c != null){
                        if(LocalData.OwnerId != allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c).Value__c){
                            LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c).Value__c;
                            listLocalDataUpdate.add(LocalData);
                        }
                        
                    }
                }
                else{
                    if(allQueuesetting != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c).Value__c != null){
                        if(LocalData.OwnerId != allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c).Value__c){
                            LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c).Value__c;
                            listLocalDataUpdate.add(LocalData);
                        }
                        
                    }
                }
            }
        }

        if(listSDSLocalDataUpdate != Null && listSDSLocalDataUpdate.size()>0){
            listLocalDataUpdate.addAll(listSDSLocalDataUpdate);
        }

        if(listLocalDataUpdate != Null && listLocalDataUpdate.size()>0){
            update listLocalDataUpdate;
        }
    }
}