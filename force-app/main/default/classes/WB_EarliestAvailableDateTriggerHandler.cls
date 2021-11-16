/*
Created Date - 25th April'2017
Created By - Cognizant Team
*/

public with sharing class WB_EarliestAvailableDateTriggerHandler {
    
    public static void setQueueToOwner(){
        List<Earliest_Avail_Date__c> listEarliestReleaseDt = new List<Earliest_Avail_Date__c>();
        listEarliestReleaseDt = Trigger.new;
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        if(listEarliestReleaseDt != NULL && listEarliestReleaseDt.size()> 0){
            for(Earliest_Avail_Date__c earlistRelDtRec: listEarliestReleaseDt){
                setCountryid.add(earlistRelDtRec.Country__c);
            }
            if(setCountryid != NULL && setCountryid.size()> 0){
                Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, Digital_Owner__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
                System.debug('mapCountry+++++++++++++'+mapCountry);
                for(Earliest_Avail_Date__c earlistRelDtRec: listEarliestReleaseDt){
                    if(allQueuesetting != null && allQueuesetting.size() > 0 && earlistRelDtRec.Country__c != NULL && allQueuesetting.get(mapCountry.get(earlistRelDtRec.Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(earlistRelDtRec.Country__c).Digital_Owner__c).Value__c != null){
                        earlistRelDtRec.OwnerId = allQueuesetting.get(mapCountry.get(earlistRelDtRec.Country__c).Digital_Owner__c).Value__c;
                    }
                }
            }
        }
    }
    
    //ER-002250 : EAD Changes to update source of EAD to manual if record is updated by any business user..
    public static void updateEADSource(List<Earliest_Avail_Date__c> listEADRecords){
        Map<Id,WB_EarliestAvailDatesourceUpdate__c> mapProfileToCustomSettingRec = new Map<Id,WB_EarliestAvailDatesourceUpdate__c>();
        List<WB_EarliestAvailDatesourceUpdate__c> listCustomSettingRecords = [SELECT SetupOwner.Name,Name,SetupOwnerId, WB_EAD_Do_Not_Overrride_Source_Field__c 
                                                                              FROM WB_EarliestAvailDatesourceUpdate__c];
        for(WB_EarliestAvailDatesourceUpdate__c eadCustomSetting : listCustomSettingRecords){
                 mapProfileToCustomSettingRec.put(eadCustomSetting.SetupOwnerId,eadCustomSetting);
        }
        id usersProfileId = userinfo.getProfileId();
        
        for(Earliest_Avail_Date__c eadRecord : listEADRecords){
            if(!mapProfileToCustomSettingRec.containsKey(usersProfileId) || mapProfileToCustomSettingRec.get(usersProfileId).WB_EAD_Do_Not_Overrride_Source_Field__c == false){
                eadRecord.Source__c = 'Manual';    
            }   
        }
    }
}