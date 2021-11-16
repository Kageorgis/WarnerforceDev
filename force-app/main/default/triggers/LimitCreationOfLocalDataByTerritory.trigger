/*******************************************************************************************************************************************
* File Name     :   LimitCreationOfLocalDataByTerritory 
* Description   :   trigger on Local_Title__c .
* @author       :   CTS
* Modification Log
* Created Date  :   
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.     15/01/2018        Astha Singh          ER-1305  
********************************************************************************************************************************************/
trigger LimitCreationOfLocalDataByTerritory on Local_Title__c (before insert,before update) {
    
    //ER-002170 :  Variable added to avoid recursion to fix too many query rows.    
    if(WB_LocalTitleTriggerHandler.recursiveUpdate || WB_LocalTitleTriggerHandler.recursiveUpdateLongLocalRating)
        return;
    
    map<Id, Local_Title__c> ltMap;
    set<Id> localTitleIds = new Set<Id>();
    Boolean isCaptionRequiredEmpty = false;
    
    //this section inserted by Andrew 3/12 - to set value of Rights_Group__c
    //create a map of locale and rights groups
    List<Rights_Group__c> ll = [Select Country_Code__c, Language_Code__c, Rights_Group__c FROM Rights_Group__c];
    Map<String, String> localeMap = new Map<String, String>();
    
    for (Rights_Group__c c:ll){
        localeMap.put(c.Language_Code__c+'_'+c.Country_Code__c, c.Rights_Group__c);
    }
    
    for(Local_Title__c lt : Trigger.New){
        String key = lt.Language_Code__c+'_'+lt.Country_Code2__c;
        lt.Rights_Group__c = localeMap.get(key);
        if(lt.Caption_Required__c == null || lt.Caption_Required__c == ''){
            isCaptionRequiredEmpty = true;
        }
    }
    
    //List<Id> newLocalTitleIds = new List<Id>();
    //List<String> newLocalTitleCountry = new List<String>();
    Set<String> matchCountryId = new Set<String>();
    String LoggedInUserProfileName;
    //list<Local_Title__c> lst_oldlocaldatarecs = new list<Local_Title__c>();
    //list<Local_Title__c> lst_newlocaldatarecs = new list<Local_Title__c>();
    
    /*if(Trigger.isUpdate && Trigger.isBefore){
        WB_ChangedFieldsIdentifierClass.checkForLocalData(); commented by Imran on 6 March
    }*/
    if(Trigger.isUpdate){ // Added logic to prevent user from updating video version.
       //WB_PreventvversionUpdateonlocaldata.updatevideoversionlocaldata();
    }
     
    List <User> userDetail = [
        SELECT Profile.Name, id, UserType,Territory__c FROM User
         WHERE id = :Userinfo.getUserId()
    ];
    
    for(User u:userDetail){
        LoggedInUserProfileName = u.Profile.Name;
    }
    /***as per discussion with Millon, commenting this code as profile does not exists in the system. This is done as a part of ER-390
    if(LoggedInUserProfileName  == 'WB - Release Maintainer'){
        List<Country__c> countryDetail = [Select id,name,Territory__c FROM Country__c];
        
        for(Country__c c:countryDetail) {
            for(User u:userDetail){
                if(c.Territory__c == u.Territory__c){
                    matchCountryId.add(c.Id);
                 }
            }
        }
        
        integer mismatchCount=0;
        String errorMsg;
        
        if(matchCountryId.size() > 0) {
            for(String mcId:matchCountryId){
                for (Local_Title__c newLocalTitle:Trigger.new) {
                    if(mcId != newLocalTitle.Country__c){
                        mismatchCount++;
                        if(matchCountryId.size() == mismatchCount){
                            errorMsg = ' Not able to create record for ' + newLocalTitle.Country__c;
                            newLocalTitle.Country__c.addError('Selected Country’s territory does not match with logged in user’s territory');
                        }
                    }
                    else{
                        system.debug('Match found');
                    }
                }
            }
        }
        else{
            for (Local_Title__c newLocalTitle:Trigger.new) {
                errorMsg = ' Not able to create record for ' + newLocalTitle.Country__c;
                newLocalTitle.Country__c.addError('Selected Country’s territory does not match with logged in user’s territory');
            }
        }
    }
    //ER-390 commenting Finish****/
    //shalini- ER-000023
   
    if(isCaptionRequiredEmpty){
        Map<Id,Country__c>countryIdMap = new Map<Id,Country__c>([select id, name from Country__c where name like'%USA']);
        Map<Id,Language__c> languageMap = new Map<Id,Language__c>([select id, name from Language__c where name like'%English']);
        
        if(countryIdMap != null && countryIdMap.size() > 0 && languageMap != null && languageMap.size() > 0 ){
            for(Local_Title__c objLT: Trigger.new){       
                if(objLT.Caption_Required__c == null || objLT.Caption_Required__c == ''){
                    objLT.Caption_Required__c=(countryIdMap.containsKey(objLT.Country__c) && languageMap.containsKey(objLT.Language__c))?'Yes':'No';
                }
            }
        }
    }
    
    if(trigger.isbefore && trigger.isinsert){
        WB_LocalTitleTriggerHandler.assignDefaultPlaylist(trigger.new);// ER :10 : Assign Default playlist(Version - 1, Status - Active).
        WB_LocalTitleTriggerHandler.setQueueToOwner(trigger.new); // Added By Preeti : CRRTS Phase 2  
        WB_LocalTitleTriggerHandler.setSDSQueueToOwner(trigger.new);
    }
    
    //*********ER-1305 : Start******************
    
    if(trigger.isbefore && (trigger.isinsert || trigger.isupdate))
    {
        WB_LocalTitleTriggerHandler.setLongLocalRating(trigger.new, trigger.old);
        if(trigger.isupdate){                                                //   changes by soumitra start
	         for(Local_Title__c objTitle : trigger.new) {                                 
	            Local_Title__c oldTitle = trigger.oldMap.get(objTitle.Id);
	            boolean bIsChanged = (objTitle.DisplayStudioOverride__c != oldTitle.DisplayStudioOverride__c && (objTitle.HBO_Owner__c != null || objTitle.Turner_Owner__c != null));
	            if (bIsChanged) {
	                objTitle.IsDisplayStudioUpdated__c=true;
	            }   
	        }                                                                            //   changes by soumitra end
        }
    }
    //*********ER-1305 : End******************

}