/*
*
* Ishwar  12-Jan-15 1st Draft (When MPM_Release_Date__c is updated/created, all the Local_Title__c records related
*                              to the Title__c of MPM__c should be updated with the givn Theatrical and TV Airing Date
*                              based on the country given in MPM_Release_Date__c)
*/
trigger MPMReleaseDateTrigger on MPM_Release_Date__c (after insert, after update, before insert, before update)
{
    //map<MPM_Id, map<MPMRD_Country, MPM RD>> : Map with MPM id as key and all 
    map<Id, map<Id, MPM_Release_Date__c>> MPMMap = new map<Id, map<Id, MPM_Release_Date__c>>();
    list<Local_Title__c> localTitlesToBeUpdated = new list<Local_Title__c>();    
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert || trigger.isUpdate)
        {
            // Start : create MPMMap
            for(MPM_Release_Date__c mrd : trigger.new)
            {
                if(MPMMap.get(mrd.MPM__c) == null)
                {
                    map<Id, MPM_Release_Date__c> mpmReleaseDateMap = new map<Id, MPM_Release_Date__c>();
                    mpmReleaseDateMap.put(mrd.Country__c, mrd);
                    MPMMap.put(mrd.MPM__c, mpmReleaseDateMap);
                }
                else
                {
                    map<Id, MPM_Release_Date__c> mpmReleaseDateMap = MPMMap.get(mrd.MPM__c);
                    mpmReleaseDateMap.put(mrd.Country__c, mrd);
                    MPMMap.put(mrd.MPM__c, mpmReleaseDateMap);
                }                
            }
            // End : Create MPMMap
          
            list<Local_Title__c> localTitleList = new list<Local_Title__c>();
            map<id,Title__c> titleMap = new map<id,Title__c>([select id from Title__c where MPM__c in :MPMMap.keySet()]);

            localTitleList = [select Id, Local_Theatrical_Release_Date__c, Local_TV_Air_Date__c, Title__r.MPM__c, Country__c from Local_Title__c where Title__c in :titleMap.keySet()];
            
            for(Local_Title__c LT : localTitleList)
            {
                map<Id, MPM_Release_Date__c> mpmReleaseDateMap = MPMMap.get(LT.Title__r.MPM__c);
                MPM_Release_Date__c mrd = mpmReleaseDateMap.get(LT.Country__c);

                if(mrd != null)
                {
                    LT.Local_Theatrical_Release_Date__c = mrd.Theatrical_Release_Date__c;
                    localTitlesToBeUpdated.add(LT);
                    
                    /*Commented for ER-671
                    if(mrd.Theatrical_Release_Date__c != null)
                    {
                        LT.Local_Theatrical_Release_Date__c = mrd.Theatrical_Release_Date__c;
                        localTitlesToBeUpdated.add(LT);
                    }*/
                    
                    //Commented for ER-547
                    /*
                    if(mrd.TV_Airing_Date__c != null)
                    {
                        LT.Local_TV_Air_Date__c = mrd.TV_Airing_Date__c;
                    }
                    if(mrd.Theatrical_Release_Date__c != null || mrd.TV_Airing_Date__c != null)
                    {
                        localTitlesToBeUpdated.add(LT);
                    }
                    */
                }
            }         
            //CRRT Phase 3
            if(System.isBatch())
                WB_CheckingDateOverlapController.UpdateLocalDataSync((trigger.newMap).keySet());// CRRT Phase 3 
            else
                WB_CheckingDateOverlapController.UpdateLocalDataAsyn((trigger.newMap).keySet());// CRRT Phase 3         
            
        }
        if(localTitlesToBeUpdated.size() > 0)
        {
            update localTitlesToBeUpdated;
        }
    }  // End isAfter logic
    
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            
        }
    }
    
}