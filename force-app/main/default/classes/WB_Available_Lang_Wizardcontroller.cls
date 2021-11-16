/******* 
Name:WB_Available_Lang_Wizardcontroller
Creation Date- 01 Dec 2014
Last Modified Date - 01 Dec 2014
Last Modified by  - 
Description- 
Author- Tejas
*******/
public with sharing class WB_Available_Lang_Wizardcontroller {
        public string selLang {get;set;}
        public string titleid{get;set;}
        public set<string> titleids; 
        public list <Available_Languages__c> availablelang_lst; 
        public list <Language__c> alllang_lst {get;set;}
        public list<availableLangDispalyWrapper> availLangDisplay{get;set;}
        public List<SelectOption> options = new List<SelectOption>();
        public String listvals {get; set;}        
        public map<string,string> langIdTypes;
        public String theValue{ get;set;}
        public map<string,string> langTypeMap;
        public set<string> availList;
        
        
            public WB_Available_Lang_Wizardcontroller(ApexPages.StandardSetController controller) {
                        langTypeMap= new map<string,string>();           
            titleid='';
            langIdTypes=new map<string,string>();
             titleid = ApexPages.currentPage().getParameters().get('ID');      
             
              availablelang_lst = [SELECT id,name,Language__c,Language__r.Name,Language_Types__c
                                   FROM Available_Languages__c
                                   WHERE Title__c = :titleid order by Name
                                  ];
               availList= new set<string>();
              for(Available_Languages__c availLang:availablelang_lst){
                availList.add(availLang.Language__c);
                langTypeMap.put(availLang.Language__c,availLang.Language_Types__c);
              }
           
              
             //alllang_lst = [SELECT ID, name FROM Language__c order by Name];-- commented by Rashmi on 5th Feb to all the order by condition on Language_Order__c
             alllang_lst = [SELECT ID, name FROM Language__c where Language_Order__c != 0 order by Language_Order__c,name];
             availLangDisplay = new list<availableLangDispalyWrapper>();
             for (Language__c allLang:alllang_lst){             
                        if(availList.contains(allLang.Id)){                        
                          availableLangDispalyWrapper langDisplayRec= new  availableLangDispalyWrapper();
                          langDisplayRec.availLangList=allLang; 
                          langDisplayRec.defaultNone =allLang.id+'none';  
                          langDisplayRec.audioSelected =allLang.id+'Audio';  
                          langDisplayRec.subSelected =allLang.id+'Sub';  
                          langDisplayRec.subAudioSelected =allLang.id+'Sub & Audio'; 
                          langDisplayRec.flag='checked'; 
                          langDisplayRec.LangType= langTypeMap.get(allLang.Id);                   
                          availLangDisplay.add(langDisplayRec);                          
                        }  else{
                          availableLangDispalyWrapper langDisplayRec= new  availableLangDispalyWrapper();
                          langDisplayRec.availLangList=allLang; 
                          langDisplayRec.defaultNone =allLang.id+'none';  
                          langDisplayRec.audioSelected =allLang.id+'Audio';  
                          langDisplayRec.subSelected =allLang.id+'Sub';  
                          langDisplayRec.subAudioSelected =allLang.id+'Sub & Audio';                           
                          langDisplayRec.LangType= '';                                                  
                          availLangDisplay.add(langDisplayRec); 
                        }
                }   
                 
         
          } 
        
        // wrapper class 
        public class availableLangDispalyWrapper{
                public Language__c availLangList {get;set;}
                public string defaultNone {get;set;}
                public string audioSelected {get;set;}
                public string subSelected {get;set;}
                public string subAudioSelected {get;set;}
                public string flag{get;set;}
                public string LangType{get;set;}
                
                 
        
                
        } 
                
       Public void selection(){       
       
        String selParam =theValue;     
        string Id='';
        string langType='';
        list<String> lstSelLangIds = selParam.split(',');       
        
        if(selParam !=''){
            for(string selLangList:lstSelLangIds){
                id= selLangList.substring(0,18);
                langType= selLangList.substring(18);
                langIdTypes.put(id,langType);  
            }
        }
        
          SelectedLang(); 
        
         
        }
        
        public void SelectedLang(){
        system.debug('in selectedLang');
        list<string> availLangIds= new list<string>();
        for(string key:langIdTypes.keyset()){
            availLangIds.add(key);
        }
        list<Available_Languages__c> titleUpdate = new list<Available_Languages__c>();
        for(string key:langIdTypes.keyset()){
                        integer counter=0;
                for(Available_Languages__c availLang:availablelang_lst){
                        if(key==availLang.Language__c){
                    Available_Languages__c titleLangUpdate= new Available_Languages__c(); 
                    titleLangUpdate.Id=availLang.Id;                   
                    titleLangUpdate.Language_Types__c=langIdTypes.get(key);
                    titleUpdate.add(titleLangUpdate);
                                counter++;
                        } 
                        }if(counter==0){
                                Available_Languages__c titleLangUpdate= new Available_Languages__c();
                                titleLangUpdate.title__c=titleid ;
                    titleLangUpdate.Language__c=key;
                    titleLangUpdate.Language_Types__c=langIdTypes.get(key);
                    titleUpdate.add(titleLangUpdate);
                        }
        }
        
        try{
                //insert titleUpdate;
                upsert titleUpdate ;
        }catch(exception e){
            system.debug('An exception occured'+e);
        }
        
        }
        
        
        public pageReference cancel(){
            
              pageReference pageRef= new pageReference('/'+titleid);          
              return pageRef;
            
        }
        

        public pageReference post(){
            if(theValue==null ||theValue==''){
                        return null;
            }else{
            selection();            
            pageReference pageRef= new pageReference('/'+titleid);          
            return pageRef;
                }
                return null;
            
        }

}