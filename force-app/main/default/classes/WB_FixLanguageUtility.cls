/*=============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                               Date                                       Comment
*  Purushottam Gupta                  23/05/2017                                 Code for Fix Language Utility
*/
global class WB_FixLanguageUtility{
    global Static Boolean isFixUtility = false;
    
    webservice static String processFixLangauges(List<String> lstRPId){
        try{
            isFixUtility = true;
            Map<Id,Commercial_Avail__c> mapCommAvail = new Map<Id,Commercial_Avail__c>();
            Set<Id> setCountryId = new Set<Id>();
            Set<Id> setTitleId = new Set<Id>();
            Map<Id,List<Language_Preference__c>> mapLangPref = new Map<Id,List<Language_Preference__c>>();
            Map<Id, List<Available_Languages__c>> mapAvailLang = new Map<Id,List<Available_Languages__c>>();
            map<Id,String> mapNonFixRP = new map<Id,String>();
            String struplicateRP;
            
            for(Commercial_Avail__c  commAvail : [SELECT Id, Name, Languages__c, Country_Lookup__c, Title__c, Language_Type__c, Channel__c, Format__c, Start_Date__c, End_Date__c, Status__c  FROM Commercial_Avail__c WHERE Id IN: lstRPId]){
                if(commAvail.Status__c == 'Confirmed')
                    mapNonFixRP.put(commAvail.Id,commAvail.Id+'::cta');
                else{
                    mapCommAvail.put(commAvail.Id, commAvail);
                    setCountryId.add(commAvail.Country_Lookup__c);
                    setTitleId.add(commAvail.Title__c);
                }
            }
            
            // getting all release plan releated to all the title
            List<Commercial_Avail__c>  lstAllCommAvail = new List<Commercial_Avail__c>([SELECT Id, Name, Languages__c, Country_Lookup__c, Title__c, Language_Type__c, Channel__c, Format__c, Start_Date__c, End_Date__c, Status__c  
                                                          FROM Commercial_Avail__c 
                                                          WHERE Title__c IN: setTitleId
                                                          AND Id NOT IN : mapCommAvail.keySet()]);
                
            
            //gettting langauge prefernce releated to country
            for(Language_Preference__c langPref : [Select Id, Level__c, Country__c, Language__c FROM Language_Preference__c WHERE Country__c IN :setCountryId AND Type__c =: Label.WB_Language_Preference_Type_Country ORDER BY Level__c]){
                if(mapLangPref.size() > 0 && mapLangPref.containsKey(langPref.Country__c)){
                    List<Language_Preference__c> lstLangPref = new List<Language_Preference__c>();
                    lstLangPref.addAll(mapLangPref.get(langPref.Country__c));
                    lstLangPref.add(langPref);
                    mapLangPref.put(langPref.Country__c, lstLangPref);
                }
                else
                    mapLangPref.put(langPref.Country__c, new List<Language_Preference__c>{langPref});
            }
            
            //getting clear to avail availabel lanagauge 
            for(Available_Languages__c availLang : [Select Id, Clear_to_Avail__c, Provisional__c, Language__c, Title__c, Language_Types__c  FROM Available_Languages__c WHERE Title__c IN :setTitleId AND (Clear_to_Avail__c = True OR Provisional__c = True)]){
                if(mapAvailLang.size() > 0 && mapAvailLang.containsKey(availLang.Title__c)){
                    List<Available_Languages__c> lstAvailLang = new List<Available_Languages__c>();
                    lstAvailLang.addAll(mapAvailLang.get(availLang.Title__c));
                    lstAvailLang.add(availLang);
                    mapAvailLang.put(availLang.Title__c, lstAvailLang);
                }
                else
                    mapAvailLang.put(availLang.Title__c, new List<Available_Languages__c>{availLang});
            }
            
            if(mapCommAvail != null && mapCommAvail.size() > 0){
                if(mapLangPref != null && mapLangPref.size() > 0 && mapAvailLang != null && mapAvailLang.size() > 0){
                    
                    for(Commercial_Avail__c commAvail : mapCommAvail.Values()){
                        String strLangType;
                        Id curtRPLang = commAvail.Languages__c;
                        
                        if(mapAvailLang.containsKey(commAvail.Title__c) && mapLangPref.containsKey(commAvail.Country_Lookup__c)){
                            List<Available_Languages__c> lstAvailLang = mapAvailLang.get(commAvail.Title__c);
                            List<Language_Preference__c> lstLangPref = mapLangPref.get(commAvail.Country_Lookup__c);
                            
                            for(Language_Preference__c langPref : lstLangPref){
                                //Fixing langauge type if both the langauge type is clear to avail
                                if(strLangType == null || strLangType == 'Provisional'){
                                    for(Available_Languages__c availlang : lstAvailLang){
                                        if(availlang.Language__c == langPref.Language__c){
                                            if(availlang.Provisional__c){
                                                strLangType = 'Provisional';
                                                break;
                                            }
                                            else{
                                                strLangType = (strLangType == 'Sub' ||  strLangType == 'Audio') ? 'Sub & Audio' : availlang.Language_Types__c;
                                                commAvail.Language_Type__c = strLangType;
                                                commAvail.Languages__c = availlang.Language__c;
                                            }
                                        }
                                    }
                                }
                            }
                            if(strLangType == 'Provisional'){
                                commAvail.Language_Type__c = 'Provisional';
                                commAvail.Languages__c = curtRPLang;
                            }
                            system.debug('**test3'+commAvail.Language_Type__c);
                            system.debug('**test4'+commAvail.Languages__c);
                        }
                    }
                }
                system.debug('**mapCommAvail'+mapCommAvail);
                //Find duplidate record after fix language utility
                // Finding duplicate record while fixing language type
                if(lstAllCommAvail != null && lstAllCommAvail.size() > 0){
                    for(Commercial_Avail__c commAvail : mapCommAvail.Values()){
                        for(Commercial_Avail__c ca : lstAllCommAvail){
                            if(commAvail.Channel__c == ca.Channel__c && commAvail.Format__c == ca.Format__c && commAvail.Country_Lookup__c == ca.Country_Lookup__c
                                && commAvail.Title__c == ca.Title__c && commAvail.Languages__c == ca.Languages__c && commAvail.Language_Type__c == ca.Language_Type__c){
                                
                                if((commAvail.Start_Date__c==null && commAvail.End_Date__c==null && ca.Start_Date__c==null && ca.End_Date__c==null)){
                                    mapNonFixRP.put(commAvail.Id,commAvail.Id+'::cpyrd~'+ca.Id+'~'+ca.Name);
                                    mapCommAvail.remove(commAvail.Id);
                                }
                                else if(((commAvail.Start_Date__c >= ca.Start_Date__c && commAvail.Start_Date__c <= ca.End_Date__c)) 
                                   ||((commAvail.End_Date__c >= ca.Start_Date__c && commAvail.End_Date__c <= ca.End_Date__c ))
                                   ||(commAvail.Start_Date__c < ca.Start_Date__c && commAvail.End_Date__c > ca.End_Date__c)
                                  ){
                                      mapNonFixRP.put(commAvail.Id,commAvail.Id+'::cpyrd~'+ca.Id+'~'+ca.Name);
                                      mapCommAvail.remove(commAvail.Id);
                                  }
                            }
                        }
                    }
                }
            }
            system.debug('**mapNonFixRP'+mapNonFixRP); 
            if(mapNonFixRP != null && mapNonFixRP.size() > 0)
                struplicateRP = String.join(mapNonFixRP.values(), ',');
            
            system.debug('**mapCommAvail'+mapCommAvail);    
            if(mapCommAvail != null && mapCommAvail.size() > 0)
                update mapCommAvail.Values();
                
            return struplicateRP != null ? struplicateRP : 'successful';
        }
        catch(exception ex){
            return 'Exception: '+ex.getmessage();
        }
    }
}