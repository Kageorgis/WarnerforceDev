/**
*  Description    :   Extention Class to view available languages records in title as a related list.
*  Author         :   Prachi Gadewar
   Emp ID         :   489635
*  Date           :   31 – Aug- 2015
*  
*  =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                          Date                         Comment
*  Prachi Gadewar                  31/8/2015                    CHO1: Changed requirement: Available language related list which contains the langauge name and
*                                                               Type fields and 2 records for a language for Audo and Subtitile will be shown as Sub & Audio.
*            
*  
*/

public with sharing class WB_Available_Language_RL_Controller {
    public List<Available_Languages__c> availablelang_lst;
    public Id LangAvailId{get; set;}
    public String titleId{get; set;}
    public String message{get; set;}
    public set<Id> langIdSet{get; set;}
    public Map<Id,String> langIdAndNameMap{get; set;}
    public Map<Id,String> langNameAndCTAMap{get; set;}
    public Map<Id,String> langNameAndProvisionalMap{get; set;}
    
    public WB_Available_Language_RL_Controller(ApexPages.StandardController controller) {
        titleId = ApexPages.currentPage().getParameters().get('id');
    }
    public List<Available_Languages__c> getAvailablelang_lst()
    {
        langIdSet = new set<Id>();
        langIdAndNameMap = new Map<Id,String>();
        langNameAndCTAMap = new Map<Id,String>();
        langNameAndProvisionalMap = new Map<Id,String>();
        
        // Get he list of Available languages for selected title whose Clear to Avail is true.
        availablelang_lst = [SELECT id,name,Language__c,Language__r.Name,Language_Types__c,Clear_to_Avail__c,Provisional__c,GPP_status__c,Mastering_Cost__c,Mastering_Reason_Code__c
                             FROM Available_Languages__c
                             WHERE Title__c = :titleId AND (Clear_to_Avail__c= true OR Provisional__c = true) order by Language__r.Name,Language_Types__c
                           ];
        // CHO1 : Start
        for(Available_Languages__c availLang: availablelang_lst)
        {
            if(!langIdAndNameMap.containskey(availLang.Language__c))
            {
                langIdSet.add(availLang.Language__c);
                langIdAndNameMap.put(availLang.Language__c,availLang.Language__r.Name);
                
                if(availLang.Clear_to_Avail__c){
                    langNameAndCTAMap.put(availLang.Language__c,availLang.Language_Types__c);
                    langNameAndProvisionalMap.put(availLang.Language__c,'');
                }
                //CRRT Phase 7: Added condition for provisional type
                if(availLang.Provisional__c){
                    langNameAndCTAMap.put(availLang.Language__c,'');
                    langNameAndProvisionalMap.put(availLang.Language__c,availLang.Language_Types__c);
                }
            }
            else
            {
                if(availLang.Clear_to_Avail__c){
                    if(langNameAndCTAMap.get(availLang.Language__c) != ''){
                        langNameAndCTAMap.put(availLang.Language__c,'Sub & Audio');
                        langNameAndProvisionalMap.put(availLang.Language__c,'');
                    }
                    else
                        langNameAndCTAMap.put(availLang.Language__c,availLang.Language_Types__c);
                }
                //CRRT Phase 7: Added condition for provisional type
                if(availLang.Provisional__c){
                    if(langNameAndProvisionalMap.get(availLang.Language__c) != ''){
                        langNameAndCTAMap.put(availLang.Language__c,'');
                        langNameAndProvisionalMap.put(availLang.Language__c,'Sub & Audio');
                    }
                    else
                        langNameAndProvisionalMap.put(availLang.Language__c,availLang.Language_Types__c);
                }
            }
        }
        // CHO1 : End
        if(availablelang_lst.size() == 0)
            message = 'No records to display.';
        return availablelang_lst;                            
    }
    public Pagereference NewAvailLanguage()
    {
        Pagereference pageRef = new Pagereference('/apex/WB_Available_Lang_Wizardpage_New?id='+titleId);
        //pageRef.getparameters().put('inline', '0');
        pageRef.setRedirect(true);
        return pageRef;
    }
    /*public void DeleteRecord()
    {
        system.debug('LangAvailId : '+LangAvailId);
        Available_Languages__c availLang = new Available_Languages__c();
        availLang.id = LangAvailId;
        delete availLang;
    }*/

}