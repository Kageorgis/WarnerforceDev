/*
Version- 1.0
Creation Date- 6 DEC 2016
Author- Preeti Jha
Description- As per CRRTS Phase 2 requirment, this controller has the functionality of Copy Cleared languages.
*/

public with sharing class WB_Copy_Language_RL_Controller {
    public List<wrapperGetTitle> TitleList {get; set;}
    string titleid;
    public String strSearch {get;set;}
    public String searchValue{get;set;}
    public Map<Id,Available_Languages__c> mapUniqLang;
    public Map<Id,Available_Languages__c> mapUniqProvLang;
    
    public WB_Copy_Language_RL_Controller(){
        titleid = ApexPages.currentPage().getParameters().get('id');
    }

    public List<wrapperGetTitle> getTitles() {
         if(TitleList == null) {
            TitleList = new List<wrapperGetTitle>();
            mapUniqLang = new Map<Id,Available_Languages__c>();
            mapUniqProvLang = new Map<Id,Available_Languages__c>();
            Title__c currentTitle = [SELECT Id, Name,MPM__c FROM Title__c WHERE Id=: titleid];
            List<String> titleName = currentTitle.Name.split(' ');
            strSearch = titleName[0];
            String s = searchValue == null ||searchValue==''?strSearch:searchValue; 
            List<Title__c> displayTitle = new List<Title__c>();
            
            List<CopyLanguageQueryLimitSize__c> queryLimit = CopyLanguageQueryLimitSize__c.getall().values();
            Integer limitSize;
            
            if(queryLimit.size() > 0)
                limitSize= Integer.valueOf(String.valueOf(Math.roundToLong(queryLimit[0].Copy_Language_Query_Limit_Size__c)));
            else
                limitSize = 700;
                
            if(searchValue == null || searchValue == ''){
                displayTitle = [select Id, Name,Video_Version__c,MPM__c,Episode__c,Digital_Planning__c,Physical_Planning__c,(Select Id, Language__c,Clear_to_Avail__c, Provisional__c from Available_Languages__r where (Clear_to_Avail__c = true OR Provisional__c = true) ) from Title__c where id !=: titleid and MPM__c=:currentTitle.MPM__c order by lastModifiedDate Desc limit :limitSize];
            }
            else{
                displayTitle = [select Id, Name,Video_Version__c,MPM__c, MPM__r.Name,Episode__c,Digital_Planning__c,Physical_Planning__c,(Select Id, Language__c,Clear_to_Avail__c, Provisional__c from Available_Languages__r where (Clear_to_Avail__c = true OR Provisional__c = true) ) from Title__c where id !=: titleid and (Name Like: '%'+searchValue+'%' OR Video_Version__c Like: '%'+searchValue+'%' OR MPM__r.Name Like: '%'+searchValue+'%' Or Digital_Planning__c Like: '%'+searchValue+'%' Or Physical_Planning__c Like: '%'+searchValue+'%') order by lastModifiedDate Desc limit :limitSize];
            }
            
            for(Title__c title: displayTitle) {
                
                for(Available_Languages__c availLang : title.Available_Languages__r){
                    if(availLang.Clear_to_Avail__c == true)
                        mapUniqLang.put(availLang.Language__c,availLang);//This is map and hence it will always have unique values
                    if(availLang.Provisional__c == true)
                        mapUniqProvLang.put(availLang.Language__c,availLang);//This is map and hence it will always have unique values 
                }
                
                Decimal countLang = mapUniqLang.size();
                Decimal provCount = mapUniqProvLang.size();
                mapUniqLang = new Map<Id,Available_Languages__c>();
                mapUniqProvLang = new Map<Id,Available_Languages__c>();
                
                TitleList.add(new wrapperGetTitle(title,countLang,provCount));
            } 
        }
        return TitleList;
    }

    public void doSearch(){
        TitleList = null;
        getTitles();
        
        /*TitleList = new List<wrapperGetTitle>();
        mapUniqLang = new Map<Id,Available_Languages__c>(); 
        
        for(Title__c title: [select Id, Name,Video_Version__c,MPM__c,Episode__c,Digital_Planning__c,Physical_Planning__c,(Select Id, Language__c from Available_Languages__r) from Title__c where id !=: titleid AND Name Like: '%'+searchValue+'%' order by lastModifiedDate Desc]) {
                
            for(Available_Languages__c availLang : title.Available_Languages__r){
                mapUniqLang.put(availLang.Language__c,availLang);//This is map and hence it will always have unique values 
            }
            Decimal countLang = mapUniqLang.size();
            mapUniqLang = new Map<Id,Available_Languages__c>();
            system.debug('countLang'+countLang);
            TitleList.add(new wrapperGetTitle(title,countLang));
                
            }*/        
    }

    public PageReference processSelected() {
        List<Title__c> selectedTitles = new List<Title__c>();
        
        for(wrapperGetTitle wrapperTitle: getTitles()) {
            if(wrapperTitle.isChecked == true) {
                selectedTitles.add(wrapperTitle.titles);
            }
        }
        string titleid = ApexPages.currentPage().getParameters().get('id');
        
        //List<Available_Languages__c> availLanguageList = [select id, Name,Title__c,GPP_Owner__r.Id, Mastering_Owner__r.Id, Mastering_IDS_Notes__c,Mastering_Reason_Code__c, Mastering_Cost__c, Language_Types__c, Language__c,GPP_Owner__c,GPP_Notes__c,GPP_status__c,Clear_to_Avail__c,Provisional__c from Available_Languages__c where Title__c IN: selectedTitles];
        //SINC1142119 : Resolved language type required exception
        List<Available_Languages__c> availLanguageList = [select id, Name,Title__c,GPP_Owner__r.Id, Mastering_Owner__r.Id, Mastering_IDS_Notes__c,Mastering_Reason_Code__c, Mastering_Cost__c, Language_Types__c, Language__c,GPP_Owner__c,GPP_Notes__c,GPP_status__c,Clear_to_Avail__c,Provisional__c from Available_Languages__c where Title__c IN: selectedTitles AND GPP_status__c != 'Research Requested' AND Language_Types__c != null];
        set<Available_Languages__c> copyAvailLang = new set<Available_Languages__c>();
        
        list<Available_Languages__c> finalAvailLangList = new list<Available_Languages__c>();
        //List<Available_Languages__c> availLanguageCurrentTitle = [select id, Name,Title__c,GPP_Owner__r.Id, Mastering_Owner__r.Id, Mastering_IDS_Notes__c,Mastering_Reason_Code__c, Mastering_Cost__c, Language_Types__c, Language__c,GPP_Owner__c,GPP_Notes__c,GPP_status__c,Clear_to_Avail__c,Provisional__c from Available_Languages__c where Title__c =: titleid];
        //SINC1142119 : Resolved language type required exception
        List<Available_Languages__c> availLanguageCurrentTitle = [select id, Name,Title__c,GPP_Owner__r.Id, Mastering_Owner__r.Id, Mastering_IDS_Notes__c,Mastering_Reason_Code__c, Mastering_Cost__c, Language_Types__c, Language__c,GPP_Owner__c,GPP_Notes__c,GPP_status__c,Clear_to_Avail__c,Provisional__c from Available_Languages__c where Title__c =: titleid AND GPP_status__c != 'Research Requested' AND Language_Types__c != null];
         
        set<id> setExistingId = new set<id>();
        set<string> setDuplicateLang = new set<string>();
        
        for(Available_Languages__c availLang: availLanguageList) { 
            
            if(!setDuplicateLang.contains(availLang.Language__c)){
                Available_Languages__c availLanguage = new Available_Languages__c();
                
                for(Available_Languages__c existingLang : availLanguageCurrentTitle){
                                
                        if(existingLang.Language__c == availLang.Language__c && existingLang.Language_Types__c == availLang.Language_Types__c){
                            //if(!setExistingId.contains(existingLang.Id)){
                                availLanguage.Id = existingLang.Id;
                                //setExistingId.add(existingLang.Id);
                                setDuplicateLang.add(existingLang.Language__c+availLang.Language_Types__c);
                                break;
                            //}
                        }
                        else{
                            availLanguage.Title__c = titleid;
                            availLanguage.Language__c = availLang.Language__c;
                            setDuplicateLang.add(availLang.Language__c+availLang.Language_Types__c);
                        }
                        
                }
                if(availLanguageCurrentTitle.size() == 0){
                    availLanguage.Title__c = titleid;
                    availLanguage.Language__c = availLang.Language__c;
                    setDuplicateLang.add(availLang.Language__c+availLang.Language_Types__c);
                }
                
                availLanguage.Language_Types__c = availLang.Language_Types__c;
                availLanguage.Clear_to_Avail__c = availLang.Clear_to_Avail__c;
                availLanguage.Provisional__c = availLang.Provisional__c;
                availLanguage.GPP_Notes__c = availLang.GPP_Notes__c;
                availLanguage.GPP_Owner__c = availLang.GPP_Owner__r.Id;
                availLanguage.GPP_status__c = availLang.GPP_status__c;
                availLanguage.Language_Types__c = availLang.Language_Types__c;
                availLanguage.Mastering_Cost__c = availLang.Mastering_Cost__c;
                availLanguage.Mastering_IDS_Notes__c = availLang.Mastering_IDS_Notes__c;
                availLanguage.Mastering_Reason_Code__c = availLang.Mastering_Reason_Code__c;
                availLanguage.Mastering_Owner__c = availLang.Mastering_Owner__r.Id;
                
                copyAvailLang.add(availLanguage);
            }
        }
        
        try{
            if(copyAvailLang != null && copyAvailLang.Size() > 0){
                finalAvailLangList.addAll(copyAvailLang);
                Upsert finalAvailLangList;
            }
            TitleList=null; // we need this line if we performed a write operation  because getContacts gets a fresh list now
            pageReference pageRef= new pageReference('/'+titleId); 
            return pageRef;
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            system.debug('An exception occured'+e);
            return null;
        }
    }

    public PageReference Cancel(){
        pageReference pageRef= new pageReference('/'+titleId); 
        return pageRef;
    }

    public class wrapperGetTitle{
        public Title__c titles {get;set;}
        public Boolean isChecked {get;set;}
        public Decimal countLang {get;set;}
        public Decimal provisionalCount {get;set;}    
        
        public wrappergetTitle(Title__c title, Decimal count, Decimal provCount){
            titles = title;
            isChecked = false;
            countLang = count;
            provisionalCount = provCount;
            
        }
    }
}