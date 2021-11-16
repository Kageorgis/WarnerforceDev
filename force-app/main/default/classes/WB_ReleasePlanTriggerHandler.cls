/*
***********************************************************************************************************************************************************************************************
*    Author    Date        Comments
*    CTS      16-Mar-2016  Trigger Handler For Release Plan
                
***********************************************************************************************************************************************************************************************
*/

public class WB_ReleasePlanTriggerHandler
{
    //Created For Checking Duplicates Within the List Of Records Being Inserted/Updated - Hot Fix - 21-Oct-2016
    public void CheckDupsInList(Map<Id,Commercial_Avail__c> oldMap, Map<Id,Commercial_Avail__c> newMap, List<Commercial_Avail__c> newRecords)
    {
        Map<String,Set<Commercial_Avail__c>> keyValuesMap = new Map<String,Set<Commercial_Avail__c>>();
        for(Commercial_Avail__c rp :newRecords)
        {
            if(rp.Title__c != NULL && rp.Channel__c != NULL && rp.Format__c != NULL && rp.Country_Lookup__c != NULL && rp.Languages__c != NULL && rp.Language_Type__c != NULL)
            {
                String keyValue = rp.Title__c+rp.Channel__c+rp.Format__c+rp.Country_Lookup__c+rp.Languages__c+rp.Language_Type__c;
                if(!keyValuesMap.containsKey(keyValue))
                    keyValuesMap.put(keyValue, new Set<Commercial_Avail__c>());
                keyValuesMap.get(keyValue).add(rp);
            }
               
        }
        
        for(Commercial_Avail__c rpNew :newRecords)
        {
            String matchKey = rpNew.Title__c+rpNew.Channel__c+rpNew.Format__c+rpNew.Country_Lookup__c+rpNew.Languages__c+rpNew.Language_Type__c;
            if(rpNew.Start_Date__c != NULL && rpNew.End_Date__c != NULL && keyValuesMap.containsKey(matchKey) && keyValuesMap.get(matchKey) != NULL && keyValuesMap.get(matchKey).size() > 1)
            {
                for(Commercial_Avail__c rPlan : keyValuesMap.get(matchKey))
                {
                    if(rpNew.Id != rPlan.Id)
                    {
                        if( (rpNew.Start_Date__c <= rPlan.End_Date__c) && (rpNew.End_Date__c >= rPlan.Start_Date__c) )
                            rpNew.addError('Insert/Update Of This Release Plan Will Result In Creation Of Duplicates');
                    }
                }
            }
        }
    }
    
    public void langTypeChange(Map<Id,Commercial_Avail__c> oldRpMap, List<Commercial_Avail__c> newReleasePlans)
    {
        Set<String> channelSet = new Set<String>();
        set<String> formatSet = new set<String>();
        set<String> countrySet = new set<String>();
        set<String> langSet = new set<String>();
        set<String> langTypeSet = new set<String>();
        set<String> titleIds = new set<String>();
        set<String> inScopeIds = new set<String>();
        
        Set<Commercial_Avail__c> scopeList = new Set<Commercial_Avail__c>();
        Set<Commercial_Avail__c> scopeList2 = new Set<Commercial_Avail__c>();
        
        map<id,map<id,set<String>>> langTypeMap =  new map<id,map<id,set<String>>>();
        map<String,set<Commercial_Avail__c>> releasePlanMap = new map<String,set<Commercial_Avail__c>>();
        
        list<Available_Languages__c> al = new List<Available_Languages__c>();
        list<Commercial_Avail__c> compareList = new list<Commercial_Avail__c>();
        
        Date startDateMin = Date.newInstance(2060, 01, 01);
        Date endDateMax = Date.newInstance(1900, 01, 01);
        
        for(Commercial_Avail__c rp : newReleasePlans)
        {
            //Migraated Workflow Logic For Field Update
            if(oldRpMap.get(rp.Id).Status__c == 'Not Releasing' && rp.Status__c != 'Not Releasing')
                rp.Reason_Code__c = '';
                
            system.debug('*****new:'+rp.Language_Type__c);
            system.debug('*****oldMap:'+oldRpMap.get(rp.Id).Language_Type__c);
            if(rp.Language_Type__c != oldRpMap.get(rp.Id).Language_Type__c)
            {
                scopeList.add(rp);
                channelSet.add(rp.Channel__c);
                formatSet.add(rp.Format__c);
                countrySet.add(rp.Country_Lookup__c);
                langSet.add(rp.Languages__c);
                langTypeSet.add(rp.Language_Type__c);
                titleIds.add(rp.Title__c);
                system.debug('*****Inside Scope Loop');
                
            }
       
        }
        
        if(scopeList != NULL && scopeList.size() > 0)
        {
            al = [SELECT Id, Title__c, Language__c, Language_Types__c, Language__r.name FROM Available_Languages__c WHERE Title__c = :titleIds and Clear_To_Avail__c=true];
            for(Available_Languages__c avl : al)
            {
                if(langTypeMap.containsKey(avl.Title__c))
                {
                    if(langTypeMap.get(avl.Title__c).containsKey(avl.Language__c))
                        langTypeMap.get(avl.Title__c).get(avl.Language__c).add(avl.Language_Types__c);
                    else
                    {
                        langTypeMap.get(avl.Title__c).put(avl.Language__c,new set<String>());
                        langTypeMap.get(avl.Title__c).get(avl.Language__c).add(avl.Language_Types__c);
                    }
                }
                else
                {
                    map<Id,Set<String>> typeMap = new map<Id,Set<String>>();
                    typeMap.put(avl.Language__c,new Set<String>());
                    typeMap.get(avl.Language__c).add(avl.Language_Types__c);
                    langTypeMap.put(avl.Title__c,typeMap);
                }
                
            
            }
            
            for(Commercial_Avail__c ca : scopeList)
            {
                if(!langTypeMap.get(ca.Title__c).containsKey(ca.Languages__c))
                    ca.Language_Type__c.addError('Language type does not exist in Title for selected language');
                else
                {
                    if(ca.Language_Type__c == 'Sub & Audio' && (!langTypeMap.get(ca.Title__c).get(ca.Languages__c).contains('Audio') || !langTypeMap.get(ca.Title__c).get(ca.Languages__c).contains('Sub')))
                    ca.Language_Type__c.addError('Language type is not matching with Available languages in Title');
                    else if(ca.Language_Type__c != 'Sub & Audio' && !langTypeMap.get(ca.Title__c).get(ca.Languages__c).contains(ca.Language_Type__c))
                        ca.Language_Type__c.addError('Language type is not matching with Available languages in Title');
                    else
                    {
                        scopeList2.add(ca);
                        inScopeIds.add(ca.Id);
                        
                        if(ca.Start_Date__c < startDateMin)
                            startDateMin = ca.Start_Date__c;
                        if(ca.End_Date__c > endDateMax)
                            endDateMax = ca.End_Date__c;
                       
                    }
                }
                
            }
            
            if(inScopeIds != NULL && inScopeIds.size() > 0)
            {
                compareList = [select id, Channel__c, Country_Lookup__c, Format__c, Title__c, Languages__c, Language_Type__c, Start_Date__c, End_Date__c
                              from Commercial_Avail__c where Channel__c =: channelSet AND Format__c =: formatSet AND Country_Lookup__c =: countrySet AND
                              Languages__c =: langSet AND Language_Type__c =: langTypeSet AND Title__c =: titleIds AND Id !=: inScopeIds AND Start_Date__c != NULL
                              AND End_Date__c != NULL];
                system.debug('*****Compare List:'+compareList);
                for(Commercial_Avail__c ca2 : compareList)
                {
                    String matchKey = ca2.Title__c+ca2.Channel__c+ca2.Format__c+ca2.Country_Lookup__c+ca2.Languages__c+ca2.Language_Type__c;
                    if(!releasePlanMap.containsKey(matchKey))
                        releasePlanMap.put(matchKey,new set<Commercial_Avail__c>());
                    releasePlanMap.get(matchKey).add(ca2);
                }
                
                for(Commercial_Avail__c validPlans : scopeList2)
                {
                    if(validPlans.Start_Date__c != NULL && validPlans.End_Date__c != NULL)
                    {
                        String key = validPlans.Title__c+validPlans.Channel__c+validPlans.Format__c+validPlans.Country_Lookup__c+validPlans.Languages__c+validPlans.Language_Type__c;
                        if(releasePlanMap.containsKey(key))
                        {
                            for(Commercial_Avail__c caDup : releasePlanMap.get(key))
                            {
                                if(validPlans.Start_Date__c <= caDup.End_Date__c && validPlans.End_Date__c >= caDup.Start_Date__c)
                                    validPlans.Language_Type__c.addError('One or More Release Plans With Matching attributes Already Exist For Start & End Date Window');
                            }
                        } 
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
    

}