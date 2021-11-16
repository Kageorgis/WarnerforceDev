/*
Created By : Preeti jha(CTS)
Date: 13th Dec 2016
Description: CRRTS Phase 2
*/

public class WB_RightsTriggerHandler {

    public static void validateRightsAndSetQueueAsOwner(List<Rights__c> listRights){
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<string> setRightsGroup = new set<string>();
        
        //Valid Rights Group picklist value on rights object
        set<String> setRightsGroupPickListValues = new set<String>();
        Schema.DescribeFieldResult rytsGrpFields = Rights__c.Rights_Group__c.getDescribe();
        list<Schema.PicklistEntry> rytsGrpValue = rytsGrpFields.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : rytsGrpValue){
            setRightsGroupPickListValues.add(pickListVal.getLabel());
        } 
        
        //Valid Channel picklist value on rights object
        set<String> setChannelPickListValues = new set<String>();
        Schema.DescribeFieldResult chlFields = Rights__c.Channel__c.getDescribe();
        list<Schema.PicklistEntry> chlValue = chlFields.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : chlValue){
            setChannelPickListValues.add(pickListVal.getLabel());
        } 
        
        //Valid Status picklist value on rights object
        set<String> setStatusPickListValues = new set<String>();
        Schema.DescribeFieldResult statusField = Rights__c.Status__c.getDescribe();
        list<Schema.PicklistEntry> statusValue = statusField.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : statusValue){
            setStatusPickListValues.add(pickListVal.getLabel());
        } 
        
        //Valid Source picklist value on rights object
        set<String> setSourcePickListValues = new set<String>();
        Schema.DescribeFieldResult sourceField = Rights__c.Source__c.getDescribe();
        list<Schema.PicklistEntry> sourceValue = sourceField.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : sourceValue){
            setSourcePickListValues.add(pickListVal.getLabel());
        } 
        
        if(listRights != null && listRights.size() > 0){
            for(Rights__c rights: listRights){
                setRightsGroup.add(rights.Rights_Group__c);
            }
            
            Map<string, List<Rights_Group__c>> mapLocales = new Map<string, List<Rights_Group__c>>();
            for(Rights_Group__c locale : [SELECT Id, Name, Rights_Group__c, Digital_Rights_Owner__c, Physical_Rights_Owner__c, Rights_Locale__c, Country__r.Channel__c
                                            FROM Rights_Group__c WHERE Rights_Group__c IN: setRightsGroup])
            {
                if (mapLocales.containsKey(locale.Rights_Group__c))
                {
                    mapLocales.get(locale.Rights_Group__c).add(locale);
                }
                else{
                     mapLocales.put(locale.Rights_Group__c,new List<Rights_Group__c> {locale});
                }
            }
            Boolean checkTriggerUpdate = (Trigger.isExecuting && Trigger.isUpdate)? True:False; //ER-007044
            for(Rights__c rights: listRights)
            {
                //Added condition to validate rights group value
                String strError;
                if(!setChannelPickListValues.contains(rights.Channel__c))
                    strError = 'Invalid Channel : '+rights.Channel__c;
                if(!setStatusPickListValues.contains(rights.Status__c))
                    strError = (strError == null) ? 'Invalid Status : '+rights.Status__c : strError + ', Status : '+rights.Status__c;
                if(!setSourcePickListValues.contains(rights.Source__c))
                    strError = (strError == null) ? 'Invalid Source : '+rights.Source__c : strError + ', Source : '+rights.Source__c;
                if(!(rights.Rights_Group__c).equalsIgnoreCase('us') && !setRightsGroupPickListValues.contains(rights.Rights_Group__c))
                    strError = (strError == null) ? 'Invalid Rights Group : '+rights.Rights_Group__c : strError + ', Rights Group : '+rights.Rights_Group__c;
                else if(mapLocales.size() > 0 && mapLocales.containsKey(rights.Rights_Group__c) && mapLocales.get(rights.Rights_Group__c) != null)
                {
                    Boolean isValidChnl = False;
                    /*ER-007044*--start*/
                    if(checkTriggerUpdate){
                        isValidChnl = true;
                    }                    
                    /*ER-007044*--end*/                   
                    
                    for(Rights_Group__c locale : mapLocales.get(rights.Rights_Group__c)){
                        //Added condition for validating  if channel is not assigned to countries associated with rights group.
                        if((locale.Country__r.Channel__c) != null && (locale.Country__r.Channel__c).contains(rights.Channel__c)){
                            isValidChnl = true;
                            //Assigning Physical owner
                            if(rights.Channel__c == 'Physical' && locale.Rights_Locale__c){
                                if(allQueuesetting != null && allQueuesetting.get(locale.Physical_Rights_Owner__c) != null && allQueuesetting.get(locale.Physical_Rights_Owner__c).Value__c != null){
                                    rights.OwnerId = allQueuesetting.get(locale.Physical_Rights_Owner__c).Value__c;
                                    break;
                                }
                            }
                            //Assigning digital owner
                            //else if(rights.Channel__c != 'Physical' && locale.Rights_Locale__c){
                            else if(locale.Rights_Locale__c){
                                if(allQueuesetting != null && allQueuesetting.get(locale.Digital_Rights_Owner__c) != null && allQueuesetting.get(locale.Digital_Rights_Owner__c).Value__c != null){
                                    rights.OwnerId = allQueuesetting.get(locale.Digital_Rights_Owner__c).Value__c;
                                    break;
                               }
                            }
                        }
                    }
                    //Error message if channel is not assigned to countries associated with rights group.
                    if(!isValidChnl){
                        rights.addError('The Channel '+rights.Channel__c+' is not assigned to countries associated with Rights Group : '+rights.Rights_Group__c);
                    }
                }
                if(strError != '' && strError != null)
                    rights.addError(strError);
            }
        }
    }
    
    
    //Added under ER-000862  Add Region, Market Group & WB Territory to Rights Object
    //Description: Copy Region, market Group & WB Territory values form locale to rights objects
    public static void setMarketRegionTerritory(List<Rights__c> listRights){
        
        set<string> setRightsGroup = new set<string>();
        for(Rights__c rights: listRights){
            setRightsGroup.add(rights.Rights_Group__c);
        }
        map<String, List<Rights_Group__c>> mapRGwithLocale = new map<String, List<Rights_Group__c>>(); 
        for(Rights_Group__c locale : [SELECT Id, Name, Rights_Group__c, Digital_Rights_Owner__c, Physical_Rights_Owner__c, Rights_Locale__c, 
                                            Country__r.Channel__c,Territory__c,Region__c,Market_Group__c
                                            FROM Rights_Group__c WHERE Rights_Group__c IN: setRightsGroup and Rights_Locale__c=true]){
            
            if (mapRGwithLocale.containsKey(locale.Rights_Group__c)){
                mapRGwithLocale.get(locale.Rights_Group__c).add(locale);
            }
            else{
                mapRGwithLocale.put(locale.Rights_Group__c,new List<Rights_Group__c> {locale});
            }
        } 
        for(Rights__c recRight :listRights){
            if(recRight.Rights_Group__c!=null && !mapRGwithLocale.isEmpty()  && mapRGwithLocale.get(recRight.Rights_Group__c)!= NULL && mapRGwithLocale.get(recRight.Rights_Group__c).size()>0){  
                if(mapRGwithLocale.get(recRight.Rights_Group__c).size()==1){
                    for(Rights_Group__c checkedRight:mapRGwithLocale.get(recRight.Rights_Group__c)){
                        recRight.Lead_Locale__c = checkedRight.Id;
                        /*if(checkedRight.Territory__c!=null)
                            recRight.text_WB_Territory__c = checkedRight.Territory__c;
                        if(checkedRight.Region__c!=null)
                            recRight.Region__c = checkedRight.Region__c ;
                        if(checkedRight.Market_Group__c!=null)                      
                            recRight.Market_Group__c = checkedRight.Market_Group__c;*/                        
                    }
                }
            }
        }            
    }
    //Added under ER-004371  Remove Deletion Permissions for WB Legal Profile on Rights Object
    //Description: Restrict profiles other than Admin & Support profiles from deleting Rights object.
    public static void restrictDeletionOfRightsRecords (List<Rights__c> listRights){
        String ProfileID = UserInfo.getProfileId();
        set<string> admSupProfiles = new set<string>(Label.WB_Admin_Support_Profiles.split(';'));
        for (Rights__c rights: listRights){
            If(!(admSupProfiles.contains(ProfileID))){
                rights.addError(system.label.WB_Rights_Delete_Validation_Msg);
            }
        }
    }
}