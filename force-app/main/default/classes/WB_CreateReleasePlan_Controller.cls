public with sharing class WB_CreateReleasePlan_Controller{
        
        public boolean grpCountriesFound{get;set;}
        public boolean noCountryFound{get;set;}
        public boolean Flag;
        public boolean titleScroller{get;set;}
        public boolean channelGridFlag{get;set;}
        public boolean noChannelFlag{get;set;}
        public boolean titleDisplayed{get;set;}
        public boolean titleMessageRendered{get;set;}
        public boolean stdPage{get;set;}
        public boolean mismatch_titles;
        public boolean noFormatFlag{get;set;}
        public boolean noAvailLang{get;set;}
        public boolean noExceptionFlag{get;set;}
        public boolean noSelectedCountry{get;set;}
        public boolean isBatchProcessing{get;set;}
        public boolean TerritoryMatch{get;set;}
        public boolean englishOnlyChk{get;set;}//ER-359
        public boolean seperateLanguageTypeChk{get;set;}//ER-359
        
        public string NoCountryFoundMsg{get;set;}
        public string grpCountriesFoundMsg{get;set;}
        public string vvlistString {set;get;} //Added by Milon for ER-000116
        public string titleIdRedir{get;set;}
        public string titleIds{get;set;}
        public String param{get;set;}
        public string titleMessage{get;set;}
        public string titleIdsMpm{get;set;}
        public string ChannelGridMessage{get;set;}
        
        // Multi select Country
        public SelectOption[] selectedCountriesRecords { get; set; }
        public SelectOption[] allCountries{ get; set; }
        public SelectOption[] selectedCountries { get; set; }
        public SelectOption[] allFormats{get;set;} //ER-180
        public SelectOption[] selectedFormats{get;set;} //ER-180
        
        public list<Integer> countLang{get;set;}
        public List<Title__c> titleList{set;get;}
        public list<titleLangCount> titleListDisplayed{get;set;}
        public list<channelWrapper> channelGridList{get;set;}
        
        public Integer toDelIdent{get;set;}
        public Integer toAddIdent {get;set;}
        
        public Id countryGrpId;
        public Boolean isRightToCreateRPChk {get; set;}
        public Boolean isRightToCreateRPEND {get; set;}
        public String ConfirmedPartialAllow {get; set;}
        public Boolean ConfirmedPartialPresent {get; set;}
        
        public Boolean provisionalLang {get; set;}
        public Commercial_Avail__c obj ;
        
        list<country_groups__c> countryGrpCountries;
        list<Country_Group_Country__c> countryGroupCountriesList;
        list<string> FormatIdList= new list<string>(); 
        list<string> CountryIdList = new list<string>();
        list<Commercial_Avail__c> commercialAvailList= new list<Commercial_Avail__c>();
        list<string> displayedchannelIds = new list<string>();
        list<String> lstTitleIdsnew;
        list<String> lstTitleIds;
        list<Available_Languages__c> titleAvailableLangList;
        list<string> countryAvailableChannel;
        list<Language_Preference__c> countryPreferedLanguage;
        list<string> languageToPopulate;
        //list<User> userDetail;
        list<Commercial_Avail__c> recordsCreated;
        List<Title__c> noCommercialTitle;
        public static list<Release_Plan_Exceptions__c> releasePlanExceptionList = new list<Release_Plan_Exceptions__c>();
        
        map<Id,set<string>> countryChannelAvailable;
        map<Id,list<langPriority>> countryLanguagePrefered;
        map<Id,set<availablelangType>> titleId_availLangTypeSetMap;
        Map<Id,set<string>> titleFormats;
        map<id, date> firstAvalTitleDateMap;
        map<id, date> expirationDateTitleMap;
        Map<Id,Title__c> titleIdMap;//ER-359
        Map<Id,Country__c> CountryIdMap;//ER-359
        Map<Id,List<Language_Preference__c>> CountryPreferedLangMap;//ER-359
        Map<Id,List<Available_Languages__c>> availableLanguageMap ;//ER-359
        
        set<string> selectedTitleIds;
        set<string> ChannelDisplay;
        set<string> ChannelDisplayId;
        
        set<String> selectedTitleFormatSet;//ER-359
        
        boolean FlagCountryGrp;
        boolean FlagCountries;
        boolean flagReqFields;
        boolean flagstartdate;
        boolean flagenddate; 
        boolean flagDates;
        boolean profileFlag;
        boolean channelGridValidationFlag = true;
        
        integer selectedTitleCount;
        integer countExcpetionRec = 0;
        User userDetail;
        
        list<Id> setMPMId;
        list<String> VideoVersionSet;
        Map<String, String> mapRightsGrp;
        List<Rights__c> lstRights;
        
        // for converting Country group lookup field into picklist on Release plan wizard - Purushottam 8-12-16
        public List<selectOption> getCountryGroup() {      
            List<selectOption> options = new List<selectOption>(); 
            options.add(new selectOption('', '')); 
            for (Country_Groups__c cntryGrp :[SELECT Id, Name FROM Country_Groups__c ORDER BY Name]){ 
                options.add(new selectOption(cntryGrp.Id, cntryGrp.Name)); 
            }
            return options;     
        }
        
        public WB_CreateReleasePlan_Controller(ApexPages.StandardSetController controller) {
            ConfirmedPartialPresent = false;
            isBatchProcessing = false;
            noExceptionFlag = true;
            noSelectedCountry = false;
            //relExceptionList = new list<Release_Plan_Exceptions__c>();
            noFormatFlag = false;
            noAvailLang = false;
            lstTitleIdsnew = new list<string>();
            titleIdRedir = '';
            stdPage = false;
            titleDisplayed = true;
            profileFlag = false;
            mismatch_titles = false;
            channelGridFlag = false;
            titleMessageRendered = false;
            TerritoryMatch = false;
            englishOnlyChk = false;//ER-359
            seperateLanguageTypeChk = false;//ER-359
            
            titleListDisplayed= new list<titleLangCount>();
            countLang = new list<Integer>();
            selectedCountriesRecords = new list<SelectOption>();
            allCountries = new list<SelectOption>();
            selectedFormats = new list<SelectOption>();
            selectedTitleFormatSet = new set<String>();//ER-359
            
            allFormats = new List<SelectOption>();
            lstTitleIds= new list<string>();
            
            integer countAvailLanguage = 0;
            integer countAvailLang = 0;
            
            integer countProvLanguage = 0;
            
            isRightToCreateRPChk = false;
            isRightToCreateRPEND = false;
            provisionalLang = false;//CRRT Sprint 6
            
            //List<String> lstTitleIds = new List<String>();
            list<country__c> availableCountryList = new list<country__c>();
            // CH01-Created a map to store count of Avail Lang per title.
            Map<String,Integer> mapAvailaLangCount = new Map<String,Integer>();
            Map<String,Integer> mapProvLangCount = new Map<String,Integer>();
            
            userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
            profileFlag = userDetail.Profile.Name.equalsIgnoreCase(System.Label.WB_Territory_Release_Planner) ? true : false;
            
            availableCountryList = (profileFlag) 
                ? [select Id, name from country__c where Status__c='Active' AND territory__c =:userDetail.Territory__c order by name]
                : [select Id, name from country__c where Status__c='Active' order by name];              
                    
                    for(Country__c country : availableCountryList){
                        allCountries.add(new SelectOption(country.Id, country.Name));                    
                    }
            
            try{
                titleIds = ApexPages.currentPage().getParameters().get('ID');
            }
            catch(Exception e){
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please don\'t refresh the page, as selection will be lost'));
            }
            
            if(titleIds!=null){
                lstTitleIdsnew = titleIds.split(','); 
                param= ApexPages.currentPage().getParameters().get('param');
                obj= (Commercial_Avail__c) controller.getRecord();
                
                if(param=='std'){
                    titleIdRedir= lstTitleIdsnew[0];
                }
                
                titleList= [SELECT id, name,Expiration_Date__c,Abstract_EIDR_formula__c, Title_Type__c,First_Available_Date__c,Production_Year_formula__c, 
                            MPM__c,Video_Version__c,Studio__c,Genre__c,Short_Synopsis__c,Formats__c,Content_Type__c,(SELECT id FROM Available_Languages__r),MPM__r.Generic__c
                            FROM Title__c 
                            WHERE Id IN:lstTitleIdsnew and (Digital_Planning__c='Yes' or Physical_Planning__c ='Yes')
                            ];
                
                // CH01- start: Query to get Available Language count for Title
                for(AggregateResult availLang :  [SELECT Title__c, Clear_to_Avail__c, Provisional__c, COUNT_DISTINCT(Language__c) FROM Available_Languages__c where Title__c IN:lstTitleIdsnew AND (Clear_to_Avail__c = TRUE OR Provisional__c = TRUE) group by title__c,Clear_to_Avail__c, Provisional__c])
                {
                    if(availLang.get('Clear_to_Avail__c') == TRUE){
                        mapAvailaLangCount.put(String.valueof(availLang.get('Title__c')),Integer.valueof(availLang.get('expr0')));
                    }
                    if(availLang.get('Provisional__c') == TRUE){//CRRT Phase7 : Added new column in releas plan wizard in section List of selected titles
                        mapProvLangCount.put(String.valueof(availLang.get('Title__c')),Integer.valueof(availLang.get('expr0')));
                    }
                }
                // CH01-End
            }
            try{
                if(titleList != null && titleList.size() != 0 && lstTitleIdsnew!= null){
                    if(titleList.size()<lstTitleIdsnew.size() ){
                        integer titleCount = lstTitleIdsnew.size() - titleList.size();
                        titleMessageRendered = true;
                        titleMessage = 'Out of '+' '+lstTitleIdsnew.size()+' '+'selected titles,'+' '+ titleCount+' '+ 'cannot create Release Plans as Digital Planning is not Yes';
                    }
                }
            }
            catch(Exception e){
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please don\'t refresh the page, as selection will be lost'));
                noFormatFlag= true;
            }
            
            titleScroller = (titleList!=null && titleList.size() > 10) ? true : false;
            
            try{
                if(titleList != null && titleList.size() != 0){
                    for(Title__c objTitle : titleList){
                        lstTitleIds.add(objTitle.Id);
                        // CH01 - start: comment out Previous code, added new one to calculate and set count of Avail Lang.
                        /*countAvailLanguage = objTitle.Available_Languages__r.size();
                        if(countAvailLanguage!=0){
                        countAvailLang++;
                        }*/
                        
                        if(mapAvailaLangCount.size() > 0 && mapAvailaLangCount.containskey(objTitle.Id))
                        {
                            countAvailLanguage = mapAvailaLangCount.get(objTitle.Id);
                            countAvailLang++;
                        }
                        else
                            countAvailLanguage = 0;
                        
                        if(mapProvLangCount.size() > 0 && mapProvLangCount.containskey(objTitle.Id))
                        {
                            countProvLanguage = mapProvLangCount.get(objTitle.Id);
                            countAvailLang++;
                        }
                        else
                            countProvLanguage = 0;
                        
                        // CH01 - end
                        titleLangCount titleDisplay=new titleLangCount();
                        titleDisplay.titlesDispalyed = objTitle;
                        titleDisplay.countLangAvailable = countAvailLanguage;
                        titleDisplay.countLangProvisional = countProvLanguage;
                        titleListDisplayed.add(titleDisplay); 
                    }
                    
                    //Added for passing the titleListDisplayed id to display MPM
                    for(titleLangCount til :titleListDisplayed){
                        if(titleIdsMpm == null){
                            titleIdsMpm = til.titlesDispalyed.Id ;
                        }
                        else
                            titleIdsMpm = titleIdsMpm +','+til.titlesDispalyed.Id;
                    }
                    
                    if(countAvailLang==0){
                        noAvailLang=true;
                    }
                    // added on 13 nov
                    if(noAvailLang){
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Available/Provisional Languages found for all selected titles.Please update selected titles with Languages'));
                    }
                    
                    titleFormats = new map<Id,set<string>>(); 
                    firstAvalTitleDateMap= new map<Id,date>(); 
                    expirationDateTitleMap = new map<Id,date>();
                    
                    integer noFormatCount=0;
                    vvlistString ='';
                    titleIdMap = new map<Id,Title__c>();//Included for ER-359
                    availableLanguageMap = new map<Id,List<Available_Languages__c>>();//180
                    set<string> formatSet = new set<string>();
                    setMPMId = new list<Id>(); // include in crrt phase 2
                    VideoVersionSet = new list<String>(); 
                    List<String> lstVV = new List<String>();
                    List<Id> lstMPMID = new List<Id>();
                    
                    for(Title__c objTitle: titleList){
                        lstMPMID.add(objTitle.MPM__c);
                        lstVV.add(objTitle.Video_Version__c);
                        //Included for ER-359
                        titleIdMap.put(objTitle.Id,objTitle);
                        availableLanguageMap.put(objTitle.Id,objTitle.Available_Languages__r);//ER-359
                        //end
                        
                        vvlistString = vvlistString + objTitle.Video_Version__c +',';
                        
                        if(objTitle.Formats__c != null && objTitle.Formats__c != ''){
                            for(String format : objTitle.Formats__c.split(';')){
                                formatSet.add(format);
                            }
                            titleFormats.put(objTitle.Id, formatSet);
                        }
                        else{
                            noFormatCount++;
                            Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                            countExcpetionRec++;
                            rpExceptionRec.name= Userinfo.getUserId() + string.valueof(countExcpetionRec) ;
                            rpExceptionRec.Title__c=objTitle.name;
                            rpExceptionRec.Video_Version__c=objTitle.Video_Version__c;
                            rpExceptionRec.Reason__c='Title is not available in any formats.';
                            rpExceptionRec.User_Detail__c=Userinfo.getUserId(); 
                            releasePlanExceptionList.add(rpExceptionRec);
                        }
                        if(objTitle.First_Available_Date__c != null)
                            firstAvalTitleDateMap.put(objTitle.Id,objTitle.First_Available_Date__c);
                        if(objTitle.Expiration_Date__c != null)
                            expirationDateTitleMap.put(objTitle.Id,objTitle.Expiration_Date__c);
                    }
                    setMPMId.addAll(lstMPMID);
                    VideoVersionSet.addAll(lstVV);
                    
                    for(String format: formatSet){
                        selectedFormats.add(new SelectOption(format,format));
                    }
                    
                    // added by shalini for Territory title validation for Territory Release planner profile users
                    if(userDetail.Profile.Name==System.Label.WB_Territory_Release_Planner){
                        integer countTitleTerr=0;
                        List<Title__c> titleDetail = [Select id,name,Territory__c,Video_Version__c FROM Title__c where Territory__c != :userDetail.Territory__c and id in:titleList];
                        for(Title__c title : titleDetail){
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Selected Titleâ€™s territory does not match with logged in userâ€™s territory'));
                            TerritoryMatch = true;
                        }
                    }
                    vvlistString =  vvlistString.removeEnd(',');
                    if(noFormatCount==titleList.size()) {
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Available Formats found for all selected titles.Please update selected titles with Format values'));
                        noFormatFlag = true;
                    }
                }
                else{
                    titleDisplayed=false;
                }         
            }
            catch(Exception Ex){
                system.debug('Ex ====: ' + Ex.getMessage());
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please don\'t refresh the page, as selection will be lost'));
                noFormatFlag= true;
            }
        }
        
        // As part of CRRT Phase 3: Alert to user if rights have confirm partial or tentative status
        // As part of CRRT Phase7: Alert to user if rights have tentative partial status
        public void chkRightsStatus(){ 
            if(provisionalLang && seperateLanguageTypeChk){// Added in CRRT Phase 7
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Release Plan can not be created if both \'Include Provisional Languages\' and \'Separate Language Types\' are checked.'));
            }
            else{
                if(selectedCountriesRecords != null){
                    for(SelectOption s5 : selectedCountriesRecords){
                        string selectedCountrieslistIds= s5.getValue();
                        CountryIdList.add(selectedCountrieslistIds);
                    }
                }
                List<Rights_Group__c> lstRightsGrp = [Select Id, Name, Rights_Group__c FROM Rights_Group__c WHERE Country__c IN:CountryIdList LIMIT 1000];
                mapRightsGrp = new Map<String, String>();   
                
                for (Rights_Group__c rytGrp : lstRightsGrp){
                    mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
                }
                
                List<String> lstRytGrp = mapRightsGrp.values();
                Set<String> setChnl = new Set<String>();
                for(channelWrapper chl : channelGridList){
                    setChnl.add(chl.countryChannel);
                }
                lstRights = new List<Rights__c>([SELECT Id, MPM__c, Channel__c, Rights_Group__c, Status__c, Rights_Start__c, Rights_Start_2__c, Rights_Start_3__c
                                                 , Rights_Start_4__c, Rights_Start_5__c, Rights_End__c, Rights_End_2__c, Rights_End_3__c, Rights_End_4__c, 
                                                 Rights_End_5__c, RT_Lifecycle__c,RecordType.Name,RecordTypeId,Title__r.MPM__r.Generic__c,Video_Version__c
                                                 FROM Rights__c 
                                                 WHERE  (MPM__c IN: setMPMId OR Video_Version__c IN: VideoVersionSet)  AND Channel__c IN:setChnl AND Rights_Group__c IN: lstRytGrp LIMIT 1000]);        
                
                for(Rights__c ryt : lstRights){
                    //if(ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative'  || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA'){
                    // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                    if(ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative'  || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA' ||
                     ryt.Status__c =='TBA Partial'){//Added 'TBA Partial' status
                        ConfirmedPartialPresent = True;
                        break;
                    }            
                }      
            }
        }
        
        public pageReference bulksave() {
            if(provisionalLang && seperateLanguageTypeChk){// Added in CRRT Phase7
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Release Plan can not be created if both \'Include Provisional Languages\' and \'Separate Language Types\' are checked.'));
            }
            else{
                /** Delete custom setting records for Release_Plan_Exceptions__c if present for logged in user**/
                list<Release_Plan_Exceptions__c> rpExceptionRecDelete= new list<Release_Plan_Exceptions__c>();
                rpExceptionRecDelete=[select id from Release_Plan_Exceptions__c where User_Detail__c=:Userinfo.getUserId()];
                
                if(rpExceptionRecDelete.size() != 0){
                    try{
                        Database.DeleteResult[] saveResult = Database.delete(rpExceptionRecDelete, false);
                    }
                    catch(exception e){
                        system.debug('An Exception Occured' + e);
                    }
                }
                /** ended-- **/
                if(commercialAvailList != null)
                    commercialAvailList.clear();
                    
                CountryIdList.clear();
                flagReqFields = True;
                flagstartdate = True;
                flagenddate = True;
                flagDates = true;
                integer formatCount = 0;
                boolean statusFlag = true;
                
                if(selectedCountriesRecords != null){
                    for(SelectOption s5 : selectedCountriesRecords){
                        string selectedCountrieslistIds= s5.getValue();
                        CountryIdList.add(selectedCountrieslistIds);
                    }
                }
                flagReqFields  = (CountryIdList.size()== 0) ? false : true;
                
                /** Started--Map for title, and available language **/
                titleAvailableLangList = new list<Available_Languages__c>([select id,Language_Types__c,Language__c,Title__c,Clear_to_Avail__c,Provisional__c from Available_Languages__c where Title__c IN:lstTitleIds AND (Provisional__c = TRUE OR Clear_to_Avail__c = TRUE) LIMIT 1000]);
                titleId_availLangTypeSetMap = new map<Id,set<availableLangType>>();
                
                for(Available_Languages__c availableLang : titleAvailableLangList){
                    availableLangType avLangType = new availableLangType();
                    // CH01 - if Clear to avail check then only add the language type in list. which will needs to create release plan.
                    //CRRT Sprint6: Added condition of Provisional language type
                    if(availableLang.Provisional__c || availableLang.Clear_to_Avail__c)
                        avLangType.langType = (availableLang.Provisional__c) ? 'Provisional' : availableLang.language_types__c;
                    else 
                        avLangType.langType = null; 
                        
                    avLangType.availableLanguage= availableLang.Language__c;
                    
                    if(titleId_availLangTypeSetMap != null && titleId_availLangTypeSetMap.containsKey(availableLang.Title__c)){
                        titleId_availLangTypeSetMap.get(availableLang.Title__c).add(avLangType);
                    }
                    else{
                        titleId_availLangTypeSetMap.put(availableLang.Title__c, new set<availableLangType>{avLangType});
                    }
                }
                /** Ended--Map for title, and available language **/
                
                /** Started--Map for country, and channel**/
                list<Country__c> selectedCountryList = new list<Country__c>([select id,Channel__c,name, Country_Code2__c,RP_AutoCalc_Default__c,(Select Id, Country__c, Language__c, Level__c, Type__c From Language_Preferences__r WHERE Type__c =: Label.WB_Language_Preference_Type_Country) from Country__c where ID IN:CountryIdList LIMIT 1000]);
                countryChannelAvailable = new map<Id,set<string>>();
                //Start : ER-359
                CountryIdMap = new map<Id,Country__c>();
                CountryPreferedLangMap = new map<Id,List<Language_Preference__c>>();
                
                for(Country__c Country:selectedCountryList){
                    CountryIdMap.put(Country.Id,Country);
                    CountryPreferedLangMap.put(Country.Id,Country.Language_Preferences__r);
                }
                //End           
                for(string countryId : CountryIdList ){
                    integer countCountry = 0;
                    set<string> channelCountryListunique = new set<string>();
                    
                    for(Country__c availableCountry : selectedCountryList){
                        string channelStr = availableCountry.Channel__c;
                        
                        if(channelStr!=null){
                            string[] channelSplit = channelStr.split(';');
                            
                            if(countryId == availableCountry.ID){
                                for(integer i=0;i<channelSplit.size();i++){
                                    channelCountryListunique.add(channelSplit[i]);
                                }
                                countryChannelAvailable.put(countryId,channelCountryListunique);
                                countCountry++;
                            }
                        }
                    }
                    
                    if(countCountry == 0){
                        for(Country__c selectedCountry : selectedCountryList){
                            if(countryId==selectedCountry.ID){
                                for(title__c titleRec:titleList){
                                    countExcpetionRec++;
                                    Release_Plan_Exceptions__c rpExceptionRec = new Release_Plan_Exceptions__c();
                                    rpExceptionRec.name = userDetail.id + string.valueof(countExcpetionRec);
                                    rpExceptionRec.Title__c = titleRec.name;
                                    rpExceptionRec.Video_Version__c=titleRec.Video_Version__c;
                                    rpExceptionRec.Country__c = selectedCountry.name;
                                    rpExceptionRec.Reason__c = 'Country has not been associated with any channel';
                                    rpExceptionRec.User_Detail__c = userDetail.id;
                                    releasePlanExceptionList.add(rpExceptionRec);
                                }
                            }
                        }
                    }
                }
                /** Ended--Map for country, and channel**/
                
                /** Started--Map for country, and language preference **/
                countryPreferedLanguage = new list<Language_Preference__c>([select id,Language__c, Language__r.Name,Level__c,Country__c, Country__r.Name, Physical_Only__c
                                                                            from Language_Preference__c
                                                                            where Country__c IN:CountryIdList AND Type__c =: Label.WB_Language_Preference_Type_Country order by Level__c LIMIT 1000]);
                
                countryLanguagePrefered = new map<Id,list<langPriority>>();
                
                for(Language_Preference__c preferedLanguage:countryPreferedLanguage){
                    langPriority langLevel=new langPriority();
                    langLevel.priority= preferedLanguage.Level__c;
                    langLevel.preferedLang= preferedLanguage.Language__c;
                    langLevel.preferedLangName = preferedLanguage.Language__r.Name; // Added in CRRT Phase 7 release
                    langLevel.preferedCntyName = preferedLanguage.Country__r.Name;// Added in CRRT Phase 7 release
                    langLevel.isPhysical= preferedLanguage.Physical_Only__c;
                    
                    if(countryLanguagePrefered != null && countryLanguagePrefered.containsKey(preferedLanguage.Country__c)){
                        countryLanguagePrefered.get(preferedLanguage.Country__c).add(langLevel);
                    }
                    else{
                        countryLanguagePrefered.put(preferedLanguage.Country__c, new list<langPriority>{langLevel});
                    }
                }
                /** Ended--Map for country, and language preference **/
                
                //Calculate threshold = title * country * formats * channel
                /* Start : Threshold calculation */
                Integer formatsCount = 1, titleCount = 1, countryCount = 1, channelCount = 1, availableLangCount = 1, threshold = 1;
                if(titleFormats != null && titleFormats.size() > 0){
                    for(set<string> formatSet : titleFormats.values()){
                        formatsCount += formatSet.size();
                    }
                }
                titleCount = (titleFormats.keySet().size()>0) ? titleFormats.keySet().size() : titleCount;
                countryCount = (countryChannelAvailable.keySet().size() > 0) ? countryChannelAvailable.keySet().size() : countryCount;
                channelCount = (channelGridList.size()>0) ? channelGridList.size() : channelCount;
                availableLangCount = titleId_availLangTypeSetMap.size() > 0 ? titleId_availLangTypeSetMap.size() : availableLangCount;
                threshold = titleCount * formatsCount * countryCount * channelCount;
                /* End : Threshold calculation */
                
                //ER-359 : Start
                for(SelectOption objSelectOp : selectedFormats){
                    selectedTitleFormatSet.add(objSelectOp.getValue());
                }
                //ER-359 : End
                if(threshold > 500){
                //if(threshold < 500){
                    isBatchProcessing = true;
                    WB_Batch_ReleasePlanWizard_New batchInstance = new WB_Batch_ReleasePlanWizard_New(lstTitleIds,CountryIdList,channelGridList,mapRightsGrp,lstRights,selectedTitleFormatSet,isRightToCreateRPChk, isRightToCreateRPEND,ConfirmedPartialAllow,provisionalLang);
                    batchInstance.seperateLanguageTypeChk = seperateLanguageTypeChk;//359
                    batchInstance.englishOnlyChk = englishOnlyChk;//359
                    batchInstance.selectedTitleFormatSet = selectedTitleFormatSet;//359
                    
                    database.executeBatch(batchInstance, 1);
                }
                else {
                    mismatch_titles=false;
                    isBatchProcessing = false;
                    
                    if(flagReqFields){
                        commercialAvailList = clientList(lstTitleIds ,CountryIdList); 
                        Map<Id,Language__c> languageIdMap = new Map<Id,Language__c>([SELECT Id,Name, Language_Code_2__c FROM Language__c]);
                        list<Commercial_Avail__c> lstFinalCommAvail = new list<Commercial_Avail__c>();
                        
                        //As per CRRT Phase 2 requirment By Purushottam (CTS)
                        // Release plan creation on the basis condition based on "Use Rights To Create Release Plans" check field in Release Plan wizard.
                        // Start     
                        
                        if(commercialAvailList !=null && commercialAvailList.size() > 0 && isRightToCreateRPChk && isRightToCreateRPEND ){ 
                            List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
                            Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
                            
                            if(lstRights != null && lstRights.size() > 0){
                                for(Rights__c ryt: lstRights){
                                    if(ryt.RecordType.Name == 'VBOM')
                                         mapRights.put(ryt.Video_Version__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);
                                    else     
                                         mapRights.put(ryt.MPM__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);                            
                                }
                            }
                            lstCommAvail= WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail, titleIdMap, CountryIdMap, languageIdMap, countExcpetionRec, 
                            ConfirmedPartialAllow, mapRights, mapRightsGrp);
                            if(lstCommAvail != null && lstCommAvail.size() > 0){
                                lstFinalCommAvail = commAvailLstValidated (lstCommAvail); 
                            } 
                        }  
                        else if(commercialAvailList !=null && commercialAvailList.size() > 0 && isRightToCreateRPChk && !isRightToCreateRPEND ){ 
                            List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
                            Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
                            
                            if(lstRights != null && lstRights.size() > 0){
                                for(Rights__c ryt: lstRights){
                                    if(ryt.RecordType.Name == 'VBOM')
                                         mapRights.put(ryt.Video_Version__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);
                                    else     
                                         mapRights.put(ryt.MPM__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);                            
                                }
                            }
                            lstCommAvail= WB_CreateReleasePLan_Helper.returnProcessedRP_case2(commercialAvailList,userDetail, titleIdMap, CountryIdMap, languageIdMap, countExcpetionRec, 
                            ConfirmedPartialAllow, mapRights, mapRightsGrp);
                            
                            if(lstCommAvail != null && lstCommAvail.size() > 0){
                                lstFinalCommAvail = commAvailLstValidated (lstCommAvail); 
                            } 
                        }  
                        else if(commercialAvailList !=null && commercialAvailList.size() > 0 && !isRightToCreateRPChk && isRightToCreateRPEND ){ 
                            List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
                            Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
                            
                            if(lstRights != null && lstRights.size() > 0){
                                for(Rights__c ryt: lstRights){
                                    if(ryt.RecordType.Name == 'VBOM')
                                         mapRights.put(ryt.Video_Version__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);
                                    else     
                                         mapRights.put(ryt.MPM__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);                            
                                }
                            }
                            
                            lstCommAvail= WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail, titleIdMap, CountryIdMap, languageIdMap, countExcpetionRec, 
                            ConfirmedPartialAllow, mapRights, mapRightsGrp);
                            
                            if(lstCommAvail != null && lstCommAvail.size() > 0){
                                lstFinalCommAvail = commAvailLstValidated (lstCommAvail); 
                            } 
                        }  
                        else if(commercialAvailList !=null && commercialAvailList.size() > 0 && !isRightToCreateRPChk && !isRightToCreateRPEND ){
                            lstFinalCommAvail= commAvailLstValidated (commercialAvailList);
                        }                 
                        //End
                        
                        boolean titleNotFound= true;                 
                        list<Commercial_Avail__c>  commercialAvailListInsert= new  list<Commercial_Avail__c>();
                        commercialAvailListInsert= batchIdGeneration(lstFinalCommAvail); 
                        if(commercialAvailListInsert !=null && commercialAvailListInsert.size() > 0 && releasePlanExceptionList.size() == 0){
                            try{ 
                                Database.Saveresult[] saveResult  = Database.insert(commercialAvailListInsert, false);
                                Integer i;                        
                                // Default_Standard_Objects__c : Code updated by Prachi to validate Release plan if playlist is not available
                                for(i=0 ; i < saveResult.size() ; i++){
                                    if(!saveResult[i].isSuccess()){
                                        Database.Error error = saveResult[i].getErrors().get(0);
                                        countExcpetionRec++;
                                        Release_Plan_Exceptions__c rpExceptionRec = new Release_Plan_Exceptions__c();
                                        rpExceptionRec.name = userDetail.id + string.valueof(countExcpetionRec);
                                        rpExceptionRec.Title__c = titleIdMap.get(commercialAvailListInsert[i].Title__c).Name;
                                        rpExceptionRec.Video_Version__c=titleIdMap.get(commercialAvailListInsert[i].Title__c).Video_Version__c;
                                        rpExceptionRec.Channel__c = commercialAvailListInsert[i].Channel__c;
                                        rpExceptionRec.Format__c = commercialAvailListInsert[i].Format__c;
                                        rpExceptionRec.Country__c = CountryIdMap.get(commercialAvailListInsert[i].Country_Lookup__c).Name;
                                        rpExceptionRec.Language__c = languageIdMap.get(commercialAvailListInsert[i].Languages__c).Name;
                                        rpExceptionRec.Reason__c = error.getMessage();
                                        rpExceptionRec.User_Detail__c = userDetail.id;
                                        releasePlanExceptionList.add(rpExceptionRec);              
                                    }
                                }
                                
                                if(releasePlanExceptionList.size() > 0)
                                {
                                    Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);
                                    PageReference PageRef = new Pagereference('/apex/WB_RP_Redirect');
                                    PageRef.setredirect(false);
                                    return PageRef;
                                }
                                else{                            
                                    //PageRef = new Pagereference(System.label.Re_direct_Commercal_Avail_Wizard);
                                    
                                    //As a part CRRT Pahse 2 requirement
                                    PageReference PageRef = new Pagereference('/apex/WB_Grid');
                                    Pageref.getParameters().put('al','true');
                                    Pageref.getParameters().put('obj','Commercial_Avail__c');
                                    Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
                                    Pageref.getParameters().put('CF_QP_filterValue',userDetail.RP_Batch_Id__c);
                                    Pageref.setRedirect(false);
                                    return PageRef;
                                }
                                // END.
                            }
                            catch(Exception e){
                                System.debug('Exception while Inserting Release Plan ---'+e.getMessage());
                            }
                        }
                        else if(commercialAvailListInsert !=null && commercialAvailListInsert.size()>0 && releasePlanExceptionList.size() > 0 ){
                            try{
                                Database.Saveresult[] saveResult  = Database.insert(commercialAvailListInsert, false);
                                Integer i;
                                for(i=0 ; i < saveResult.size() ; i++){
                                    if(!saveResult[i].isSuccess()){
                                        Database.Error error = saveResult[i].getErrors().get(0);
                                        countExcpetionRec++;
                                        Release_Plan_Exceptions__c rpExceptionRec = new Release_Plan_Exceptions__c();
                                        rpExceptionRec.name = userDetail.id + string.valueof(countExcpetionRec);
                                        rpExceptionRec.Title__c = titleIdMap.get(commercialAvailListInsert[i].Title__c).Name;
                                        rpExceptionRec.Video_Version__c=titleIdMap.get(commercialAvailListInsert[i].Title__c).Video_Version__c;
                                        rpExceptionRec.Reason__c = error.getMessage();
                                        rpExceptionRec.User_Detail__c = userDetail.id;
                                        releasePlanExceptionList.add(rpExceptionRec);  
                                    }
                                }                       
                                Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);                        
                                PageReference PageRef = new Pagereference('/apex/WB_RP_Redirect');                      
                                PageRef.setredirect(false);
                                return PageRef;
                            }
                            catch(Exception e){
                                system.debug('Exception caught----'+e.getMessage());
                            }
                        }
                        else if(channelGridValidationFlag == true && releasePlanExceptionList.size() > 0){
                            try{
                                Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);
                            }
                            catch(Exception e){
                                system.debug('Exception caught----'+e.getMessage());
                            }
                            PageReference PageRef = new Pagereference('/apex/WB_RP_Redirect');                   
                            PageRef.setredirect(false);
                            return PageRef;
                        }
                    } 
                    else {
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.ReleasePlan_Mandatory_Fields));
                    }
                    clearList();
                    return null;
                }       
            }
            return null;
        }
        
        /**batch id  creation method **/
        public list<Commercial_avail__c> batchIdGeneration(list<Commercial_avail__c> list_TobeUpdate){
            
            list<Batch_Ids_Customsetting__c> clientAvailBatchId_lst = [Select Id,Name,RP_Batch_Id__c,RP_Created_Date__c,CA_User_Detail__c from 
                                                                       Batch_Ids_Customsetting__c for update];
            
            integer incremnt = integer.ValueOf(clientAvailBatchId_lst[0].RP_Batch_Id__c);
            incremnt++;
            string finalBatchId = String.valueOf(incremnt);
            
            clientAvailBatchId_lst[0].Name = userDetail.Id;
            clientAvailBatchId_lst[0].RP_Batch_Id__c = finalBatchId;
            clientAvailBatchId_lst[0].RP_Created_Date__c = system.now();
            clientAvailBatchId_lst[0].CA_User_Detail__c = userDetail.Id;
            Database.Upsertresult[] saveBatchResult  = Database.upsert(clientAvailBatchId_lst, false);
            
            if(saveBatchResult[0].isSuccess()){ 
                userDetail.RP_Batch_Id__c = clientAvailBatchId_lst[0].RP_Batch_Id__c;
                update userDetail;
            }
            
            for(Commercial_Avail__c client :list_TobeUpdate){
                client.Batch_Id__c = clientAvailBatchId_lst[0].RP_Batch_Id__c;
            }
            return list_TobeUpdate ;
        }
        
        public list<Commercial_Avail__c> commAvailLstValidated (list<Commercial_Avail__c> commercialAvailList){
            list<Commercial_Avail__c> finalReleasePlanList= new list<Commercial_Avail__c>();
            list<Commercial_Avail__c> lst_selectedcommercial_aval = new list<Commercial_Avail__c>();
            list <string> lst_selectedtitle = new list<string>();
            //set<string> lst_selectedtitle1 = new set<string>();
            list<string> lst_selectedcountry = new list<string>();
            list<string> lst_selectedchannel = new list<string>();
            list<string> lst_selectedformat = new list<string>();
            list<string> lst_selectedlanguage = new list<string>();
            list<string> lst_selectedlanguageType = new list<string>();//ER-359
            list<Date> lst_selectedAvailStart = new list<Date>();
            list<Date> lst_selectedAvailEnd = new list<Date>();
            
            boolean validationFlag= true;
            
            for(integer i=0;i<commercialAvailList.size();i++){
                lst_selectedtitle.add(commercialAvailList[i].Title__c);
                lst_selectedcountry.add(commercialAvailList[i].Country_Lookup__c);
                lst_selectedchannel.add(commercialAvailList[i].Channel__c);
                lst_selectedformat.add(commercialAvailList[i].Format__c);
                lst_selectedlanguage.add(commercialAvailList[i].Languages__c);
                lst_selectedlanguageType.add(commercialAvailList[i].Language_Type__c);//ER-359
            }
            
            lst_selectedcommercial_aval = [SELECT id, name,Title__c,Title__r.name, Title__r.Video_Version__c,Country_Lookup__c,Country_Lookup__r.name,Channel__c,Format__c,
                                            Languages__c,Languages__r.name,Language_Type__c,End_Date__c,Start_Date__c
                                            FROM Commercial_Avail__c 
                                            WHERE Title__c IN :lst_selectedtitle AND Country_Lookup__c IN :lst_selectedcountry
                                            AND Channel__c IN :lst_selectedchannel 
                                            AND Format__c IN :lst_selectedformat
                                            AND Languages__c IN :lst_selectedlanguage
                                            AND Language_Type__c IN :lst_selectedlanguageType//ER-359
                                            ];
             
            for(integer i=0;i<commercialAvailList.size();i++){
                integer countOverLap= 0;
                
                for(integer j=0; j < lst_selectedcommercial_aval.size(); j++){
                    //started
                    Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                    
                    if(commercialAvailList[i].Start_Date__c > commercialAvailList[i].End_Date__c ){
                        // Criteria 1
                        //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Start date cannot be greater than End date'));
                        validationFlag=false;
                        countExcpetionRec++;
                        rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                        rpExceptionRec.Title__c=lst_selectedcommercial_aval[j].Title__r.name;
                        rpExceptionRec.Video_Version__c=lst_selectedcommercial_aval[j].Title__r.Video_Version__c;
                        rpExceptionRec.Country__c=lst_selectedcommercial_aval[j].Country_Lookup__r.name;
                        rpExceptionRec.Language__c=lst_selectedcommercial_aval[j].Languages__r.name;
                        rpExceptionRec.Channel__c=commercialAvailList[i].Channel__c;
                        rpExceptionRec.Format__c=commercialAvailList[i].Format__c;
                        rpExceptionRec.Avails_Start__c=commercialAvailList[i].Exclusive_Date__c;
                        rpExceptionRec.Avails_End__c=commercialAvailList[i].Rights_End__c;
                        rpExceptionRec.Release_Start_Date__c=commercialAvailList[i].Start_Date__c;
                        rpExceptionRec.Release_End_Date__c=commercialAvailList[i].End_Date__c;
                        rpExceptionRec.Status__c=commercialAvailList[i].Status__c;
                        rpExceptionRec.Reason__c='Start date is greater than End date';
                        rpExceptionRec.User_Detail__c=userDetail.id;
                        releasePlanExceptionList.add(rpExceptionRec);
                        countOverLap++;
                        //commercialAvailList.remove(i);
                        break;
                    }//ended
                    // added by rashmi on 9th sept
                    else if(commercialAvailList[i].channel__c==lst_selectedcommercial_aval[j].channel__c &&
                            commercialAvailList[i].format__c==lst_selectedcommercial_aval[j].format__c &&
                            commercialAvailList[i].country_lookup__c==lst_selectedcommercial_aval[j].country_lookup__c &&
                            commercialAvailList[i].title__c ==lst_selectedcommercial_aval[j].title__c &&
                            commercialAvailList[i].Languages__c==lst_selectedcommercial_aval[j].Languages__c &&
                            commercialAvailList[i].Language_Type__c==lst_selectedcommercial_aval[j].Language_Type__c
                           ){                           
                               if((lst_selectedcommercial_aval[j].Start_Date__c==null && lst_selectedcommercial_aval[j].End_Date__c==null && commercialAvailList[i].Start_Date__c==null && commercialAvailList[i].End_Date__c==null)){
                                   validationFlag=false;
                                   countExcpetionRec++;
                                   rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                   rpExceptionRec.Title__c=lst_selectedcommercial_aval[j].Title__r.name;
                                   rpExceptionRec.Video_Version__c=lst_selectedcommercial_aval[j].Title__r.Video_Version__c;
                                   rpExceptionRec.Country__c=lst_selectedcommercial_aval[j].Country_Lookup__r.name;
                                   rpExceptionRec.Language__c=lst_selectedcommercial_aval[j].Languages__r.name;
                                   rpExceptionRec.Channel__c=commercialAvailList[i].Channel__c;
                                   rpExceptionRec.Format__c=commercialAvailList[i].Format__c;
                                   rpExceptionRec.Avails_Start__c=commercialAvailList[i].Exclusive_Date__c;
                                   rpExceptionRec.Avails_End__c=commercialAvailList[i].Rights_End__c;
                                   rpExceptionRec.Release_Start_Date__c=commercialAvailList[i].Start_Date__c;
                                   rpExceptionRec.Release_End_Date__c=commercialAvailList[i].End_Date__c;
                                   rpExceptionRec.Status__c=commercialAvailList[i].Status__c;
                                   rpExceptionRec.Reason__c='Following overlapping periods  have been found with-'+lst_selectedcommercial_aval[j].name;
                                   rpExceptionRec.User_Detail__c=userDetail.id;
                                   releasePlanExceptionList.add(rpExceptionRec);
                                   
                                   countOverLap++;
                                   
                                   break;
                               }
                               else if(((commercialAvailList[i].Start_Date__c >= lst_selectedcommercial_aval[j].Start_Date__c && commercialAvailList[i].Start_Date__c <= lst_selectedcommercial_aval[j].End_Date__c)) 
                                       ||((commercialAvailList[i].End_Date__c >=lst_selectedcommercial_aval[j].Start_Date__c && commercialAvailList[i].End_Date__c <= lst_selectedcommercial_aval[j].End_Date__c ))
                                       ||(commercialAvailList[i].Start_Date__c < lst_selectedcommercial_aval[j].Start_Date__c && commercialAvailList[i].End_Date__c > lst_selectedcommercial_aval[j].End_Date__c)
                                      ){
                                          validationFlag=false;
                                          countExcpetionRec++;
                                          rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                          rpExceptionRec.Title__c=lst_selectedcommercial_aval[j].Title__r.name;
                                          rpExceptionRec.Video_Version__c=lst_selectedcommercial_aval[j].Title__r.Video_Version__c;
                                          rpExceptionRec.Country__c=lst_selectedcommercial_aval[j].Country_Lookup__r.name;
                                          rpExceptionRec.Language__c=lst_selectedcommercial_aval[j].Languages__r.name;
                                          rpExceptionRec.Channel__c=commercialAvailList[i].Channel__c;
                                          rpExceptionRec.Format__c=commercialAvailList[i].Format__c;
                                          rpExceptionRec.Avails_Start__c=commercialAvailList[i].Exclusive_Date__c;
                                          rpExceptionRec.Avails_End__c=commercialAvailList[i].Rights_End__c;
                                          rpExceptionRec.Release_Start_Date__c=commercialAvailList[i].Start_Date__c;
                                          rpExceptionRec.Release_End_Date__c=commercialAvailList[i].End_Date__c;
                                          rpExceptionRec.Status__c=commercialAvailList[i].Status__c;  
                                          rpExceptionRec.Reason__c='Following overlapping periods  have been found with-'+lst_selectedcommercial_aval[j].name;
                                          rpExceptionRec.User_Detail__c=userDetail.id;
                                          releasePlanExceptionList.add(rpExceptionRec);
                                          countOverLap++;
                                          break;
                                      }
                           }
                }// End of inner for loop
                if(countOverLap==0){
                    finalReleasePlanList.add(commercialAvailList[i]);
                }
            }
            return finalReleasePlanList;
        }
        
        public boolean channelGridValidation(){
            
            boolean channelValidationFlag = false;
            boolean channelRightDatesValidationFlag = false;
            boolean channelRightReleaseDatesValidationFlag = false;
            boolean channelStatusBothDateRequiredFlag = false;
            boolean channelStatusRightDateRequiredFlag = false;
            boolean channelStatusReleaseDateRequiredFlag = false;
            boolean channelStatusReleaseDateBoth=false;
            boolean channelStatusReasonCodeReqFlag=false;
            boolean dateValidationErrorFlag=true;
            if((isRightToCreateRPEND && isRightToCreateRPChk) ||(!isRightToCreateRPEND && !isRightToCreateRPChk)){
                for(channelWrapper channelRecItr :channelGridList) {
                    if(channelRecItr.additionalInfo.Start_Date__c > channelRecItr.additionalInfo.End_Date__c){
                        channelValidationFlag=true;
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Start_End_Date_Err));
                    }
                    else {
                        for(channelWrapper channelComp:channelGridList){ 
                            if(channelRecItr.additionalInfo.Start_Date__c!=null && channelComp.additionalInfo.End_Date__c!=null &&  channelRecItr.additionalInfo.End_Date__c!= null && channelComp.additionalInfo.Start_Date__c !=null ) {  
                                if(channelComp.countryChannel==channelRecItr.countryChannel && channelComp.addIndent != channelRecItr.addIndent  ){
                                    if(channelRecItr.additionalInfo.Start_Date__c > channelComp.additionalInfo.End_Date__c || channelRecItr.additionalInfo.End_Date__c <channelComp.additionalInfo.Start_Date__c ){
                                        
                                    }else {
                                        channelValidationFlag=true;
                                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Plan_Date_Overlap));
                                    }
                                }
                            }
                        }
                    }
                    //Right End Date must be greater then right start date
                    if(channelRecItr.additionalInfo.Start_Date__c > channelRecItr.additionalInfo.End_Date__c ){
                        dateValidationErrorFlag=true;
                        channelValidationFlag=true;
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Start_End_Date_Err));
                    }
                    else if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Rights_End__c){
                        dateValidationErrorFlag=true;
                        channelValidationFlag=true;
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Right_Start_End_Date_Err));
                    }
                    else if(channelRecItr.additionalInfo.Status__c== 'Tentative' || channelRecItr.additionalInfo.Status__c== 'Confirmed'||channelRecItr.additionalInfo.Status__c== 'Moratorium'){
                        if(channelRecItr.additionalInfo.Exclusive_Date__c== Null || channelRecItr.additionalInfo.Rights_End__c == Null ||
                           channelRecItr.additionalInfo.Start_Date__c == Null || channelRecItr.additionalInfo.End_Date__c ==Null){
                               dateValidationErrorFlag=true;
                               channelValidationFlag=true;
                               Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Right_Dates_Reqd+''+'-'+''+ 'Tentative/Confirmed/Moratorium'));
                           } 
                           else if(channelRecItr.additionalInfo.Exclusive_Date__c!= Null && channelRecItr.additionalInfo.Rights_End__c!= Null && 
                                     channelRecItr.additionalInfo.Start_Date__c!= Null && channelRecItr.additionalInfo.End_Date__c!=Null){
                                         if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Start_Date__c || channelRecItr.additionalInfo.End_Date__c >channelRecItr.additionalInfo.Rights_End__c){
                                             dateValidationErrorFlag=true;
                                             channelValidationFlag=true;
                                             Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Tentative/Confirmed/Moratorium'));
                                         }
                                     }
                    }
                    else if(channelRecItr.additionalInfo.Status__c== 'Draft' || channelRecItr.additionalInfo.Status__c== 'Open'){
                        if(channelRecItr.additionalInfo.Exclusive_Date__c== Null || channelRecItr.additionalInfo.Rights_End__c == Null ){
                        dateValidationErrorFlag=true;
                        channelValidationFlag=true;
                        Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Right_Dates_Reqd_Err+''+'-'+''+'Draft/Open'));
                        }
                        if((channelRecItr.additionalInfo.start_date__c==null && channelRecItr.additionalInfo.end_date__c!=null)||(channelRecItr.additionalInfo.start_date__c!=null && channelRecItr.additionalInfo.end_date__c==null)){
                            dateValidationErrorFlag=true;
                            channelValidationFlag=true;
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Both_Rel_Dates_Err+''+'-'+''+'Draft/Open'));
                        } 
                        else if (channelRecItr.additionalInfo.Exclusive_Date__c!= Null && channelRecItr.additionalInfo.Rights_End__c!= Null && 
                                   channelRecItr.additionalInfo.Start_Date__c!= Null && channelRecItr.additionalInfo.End_Date__c!=Null){
                                       if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Start_Date__c || channelRecItr.additionalInfo.End_Date__c >channelRecItr.additionalInfo.Rights_End__c){
                                           dateValidationErrorFlag=true;
                                           channelValidationFlag=true;
                                           Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Draft/Open'));
                                       }
                                   }
                    } 
                    else if(channelRecItr.additionalInfo.Status__c== 'Not Releasing'){
                        if(channelRecItr.additionalInfo.Start_Date__c == Null || channelRecItr.additionalInfo.End_Date__c == Null ){
                            dateValidationErrorFlag=true;
                            channelValidationFlag=true;
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Dates_Reqd_Err+''+'-'+''+'Not Releasing'));
                        }
                        else if((channelRecItr.additionalInfo.Exclusive_Date__c ==null && channelRecItr.additionalInfo.Rights_End__c !=null)||(channelRecItr.additionalInfo.Exclusive_Date__c !=null && channelRecItr.additionalInfo.Rights_End__c ==null)){
                            dateValidationErrorFlag=true;
                            channelValidationFlag=true;
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Both_Rel_Dates_Err+''+'-'+''+'Not Releasing'));
                        }
                        else if(channelRecItr.additionalInfo.Exclusive_Date__c!= Null && channelRecItr.additionalInfo.Rights_End__c!= Null && 
                                 channelRecItr.additionalInfo.Start_Date__c!= Null && channelRecItr.additionalInfo.End_Date__c!=Null){
                                     if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Start_Date__c || channelRecItr.additionalInfo.End_Date__c >channelRecItr.additionalInfo.Rights_End__c){
                                         dateValidationErrorFlag=true;
                                         channelValidationFlag=true;
                                         Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Not Releasing'));
                                     }
                                 }
                        if(channelRecItr.additionalInfo.reason_code__c== null){
                            dateValidationErrorFlag=true;
                            channelValidationFlag=true;
                            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Reason_Code_Err+''+'-'+''+'Not Releasing'));
                        }
                    }
                }
            }
            else if((isRightToCreateRPEND && !isRightToCreateRPChk) ||(!isRightToCreateRPEND && isRightToCreateRPChk)){
                for(channelWrapper channelRecItr :channelGridList){
                
                if(channelRecItr.additionalInfo.Start_Date__c > channelRecItr.additionalInfo.End_Date__c){
                    channelValidationFlag=true;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Start_End_Date_Err));
                }
                else {
                    for(channelWrapper channelComp:channelGridList){ 
                        if(channelRecItr.additionalInfo.Start_Date__c!=null && channelComp.additionalInfo.End_Date__c!=null &&  channelRecItr.additionalInfo.End_Date__c!= null && channelComp.additionalInfo.Start_Date__c !=null ) {  
                            if(channelComp.countryChannel==channelRecItr.countryChannel && channelComp.addIndent != channelRecItr.addIndent  ){
                                if(channelRecItr.additionalInfo.Start_Date__c > channelComp.additionalInfo.End_Date__c || channelRecItr.additionalInfo.End_Date__c <channelComp.additionalInfo.Start_Date__c ){
                                    
                                }else {
                                    channelValidationFlag=true;
                                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Plan_Date_Overlap));
                                }
                            }
                        }
                    }
                }
                //Right End Date must be greater then right start date
                if(channelRecItr.additionalInfo.Start_Date__c > channelRecItr.additionalInfo.End_Date__c ){
                    dateValidationErrorFlag=true;
                    channelValidationFlag=true;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Start_End_Date_Err));
                }
                else if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Rights_End__c){
                    dateValidationErrorFlag=true;
                    channelValidationFlag=true;
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Right_Start_End_Date_Err));
                }
                else if(channelRecItr.additionalInfo.Status__c== 'Tentative' || channelRecItr.additionalInfo.Status__c== 'Confirmed'||channelRecItr.additionalInfo.Status__c== 'Moratorium'){
                    
                    if(isRightToCreateRPEND){ //Validate Start Dates            
            if(channelRecItr.additionalInfo.Exclusive_Date__c== Null || channelRecItr.additionalInfo.Start_Date__c == Null){
                 dateValidationErrorFlag=true;
                 channelValidationFlag=true;
                 Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Right_Dates_Reqd+''+'-'+''+ 'Tentative/Confirmed/Moratorium'));
            } 
            else if(channelRecItr.additionalInfo.Exclusive_Date__c!= Null && channelRecItr.additionalInfo.Start_Date__c!= Null ){
              if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Start_Date__c){
                dateValidationErrorFlag=true;
                channelValidationFlag=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Tentative/Confirmed/Moratorium'));
              }
            }            
          }
          else if(isRightToCreateRPChk){ //Validate End Dates            
            if(channelRecItr.additionalInfo.Rights_End__c == Null || channelRecItr.additionalInfo.End_Date__c ==Null){
                 dateValidationErrorFlag=true;
                 channelValidationFlag=true;
                 Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Right_Dates_Reqd+''+'-'+''+ 'Tentative/Confirmed/Moratorium'));
            } 
            else if(channelRecItr.additionalInfo.Rights_End__c!= Null && channelRecItr.additionalInfo.End_Date__c!=Null){
              if(channelRecItr.additionalInfo.End_Date__c >channelRecItr.additionalInfo.Rights_End__c){
                dateValidationErrorFlag=true;
                channelValidationFlag=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Tentative/Confirmed/Moratorium'));
              }
            }
          
          }          
        }
                else if(channelRecItr.additionalInfo.Status__c== 'Draft' || channelRecItr.additionalInfo.Status__c== 'Open'){
                    
          if(isRightToCreateRPEND){//Validate Start Dates              
            if(channelRecItr.additionalInfo.Exclusive_Date__c== Null ){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Right_Dates_Reqd_Err+''+'-'+''+'Draft/Open'));
            }
            /*
            if((channelRecItr.additionalInfo.start_date__c==null && channelRecItr.additionalInfo.end_date__c!=null)||(channelRecItr.additionalInfo.start_date__c!=null && channelRecItr.additionalInfo.end_date__c==null)){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Both_Rel_Dates_Err+''+'-'+''+'Draft/Open'));
            }*/ 
            else if (channelRecItr.additionalInfo.Exclusive_Date__c!= Null && channelRecItr.additionalInfo.Start_Date__c!= Null){
              if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Start_Date__c ){
                dateValidationErrorFlag=true;
                channelValidationFlag=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Draft/Open'));
              }
            }
          
          }
          else if(isRightToCreateRPChk){//Validate End Dates  
            
            if(channelRecItr.additionalInfo.Rights_End__c == Null ){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Right_Dates_Reqd_Err+''+'-'+''+'Draft/Open'));
            }
            /*if((channelRecItr.additionalInfo.start_date__c==null && channelRecItr.additionalInfo.end_date__c!=null)||(channelRecItr.additionalInfo.start_date__c!=null && channelRecItr.additionalInfo.end_date__c==null)){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Both_Rel_Dates_Err+''+'-'+''+'Draft/Open'));
            }*/ 
            else if (channelRecItr.additionalInfo.Rights_End__c!= Null && channelRecItr.additionalInfo.End_Date__c!=Null){
              if( channelRecItr.additionalInfo.End_Date__c >channelRecItr.additionalInfo.Rights_End__c){
                dateValidationErrorFlag=true;
                channelValidationFlag=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Draft/Open'));
              }
            }
          
          }
          
          
        } 
                else if(channelRecItr.additionalInfo.Status__c== 'Not Releasing'){
                    if(isRightToCreateRPEND){//Validate Start Dates
          
            if(channelRecItr.additionalInfo.Start_Date__c == Null){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Dates_Reqd_Err+''+'-'+''+'Not Releasing'));
            }
            /*else if((channelRecItr.additionalInfo.Exclusive_Date__c ==null && channelRecItr.additionalInfo.Rights_End__c !=null)||(channelRecItr.additionalInfo.Exclusive_Date__c !=null && channelRecItr.additionalInfo.Rights_End__c ==null)){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Both_Rel_Dates_Err+''+'-'+''+'Not Releasing'));
            }*/
            else if(channelRecItr.additionalInfo.Exclusive_Date__c!= Null && channelRecItr.additionalInfo.Start_Date__c!= Null){
              if(channelRecItr.additionalInfo.Exclusive_Date__c > channelRecItr.additionalInfo.Start_Date__c){
                dateValidationErrorFlag=true;
                channelValidationFlag=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Not Releasing'));
              }
            }
            if(channelRecItr.additionalInfo.reason_code__c== null){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Reason_Code_Err+''+'-'+''+'Not Releasing'));
            }
          
          }
          else if(isRightToCreateRPChk){// Validate End Date
            
            if(channelRecItr.additionalInfo.End_Date__c == Null ){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Dates_Reqd_Err+''+'-'+''+'Not Releasing'));
            }
            /*else if((channelRecItr.additionalInfo.Exclusive_Date__c ==null && channelRecItr.additionalInfo.Rights_End__c !=null)||(channelRecItr.additionalInfo.Exclusive_Date__c !=null && channelRecItr.additionalInfo.Rights_End__c ==null)){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Both_Rel_Dates_Err+''+'-'+''+'Not Releasing'));
            }*/
            else if(channelRecItr.additionalInfo.Rights_End__c!= Null && channelRecItr.additionalInfo.End_Date__c!=Null){
              if(channelRecItr.additionalInfo.End_Date__c >channelRecItr.additionalInfo.Rights_End__c){
                dateValidationErrorFlag=true;
                channelValidationFlag=true;
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Rgt_Date_Range+''+'-'+''+'Not Releasing'));
              }
            }
            if(channelRecItr.additionalInfo.reason_code__c== null){
              dateValidationErrorFlag=true;
              channelValidationFlag=true;
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Rel_Reason_Code_Err+''+'-'+''+'Not Releasing'));
            }
            
          }            
          
        }
      }
                
            }
            
            channelGridValidationFlag = (channelValidationFlag== true) ? false : true;
            
            return channelValidationFlag;
        }
        
        public list<Commercial_Avail__c> clientList(list<string> titleIds, list<string> countryIdList){
            //recordsCreated.clear();
            // Added for ER-180 
            Set<String> selectedFormatStrSet = new Set<String>(); //ER-180
            for(SelectOption selectFormats : selectedFormats){
                selectedFormatStrSet.add(selectFormats.getValue());
            }
            
            integer countOfPreferedLang=0;
            integer countOfPriorityLang2=0;
            integer countOfPriorityLang3=0;
            recordsCreated= new list<Commercial_Avail__c>();
            boolean channelValidationFlag = false;
            boolean channelRightDatesValidationFlag = false;
            
            boolean channelStatusBothDateRequiredFlag = false;
            boolean channelStatusRightDateRequiredFlag = false;
            boolean channelStatusReleaseDateRequiredFlag = false;
            boolean channelStatusReleaseDateBoth=false;
            boolean channelStatusReasonCodeReqFlag=false;
            boolean dateValidationErrorFlag=false;
            boolean channelGridValidation= channelGridValidation();
            dateValidationErrorFlag= channelGridValidation;
            list<string> noAvailLangtitlesLst= new list<string>();
            // Checking Date Overlap 
            List<Language__c> engLangList = [select Id, Name, Language_Order__c, Language_Code_2__c from Language__c where Name = 'English'];//359
            Language__c objEngLang = (engLangList != null && engLangList.size() > 0) ? engLangList[0] : new Language__c();
            Map<Id,Title__c> mapDPTitle = new Map<Id,Title__c>([SELECT Id, Name,Content_Type__c,Digital_Planning__c, Physical_Planning__c,Video_Version__c, Formats__c FROM Title__c WHERE Id IN: titleIds]);        
            
            if(dateValidationErrorFlag==false) {
                for(string titleId:titleIds){
                    set<string>titleAvailLang =new set<string>();
                    set<availableLangType> titleAvailLangLst = new set<availableLangType>();
                    set<string> titleFormatSet= new set<string>();
                    titleAvailLangLst = titleId_availLangTypeSetMap.get(titleId);
                    
                    if(titleAvailLangLst!=null){
                        for(availableLangType titleLangList:titleAvailLangLst){
                            titleAvailLang.add(titleLangList.availableLanguage);
                        }
                    }
                    else{
                        noAvailLangtitlesLst.add(titleId);
                    }
                    
                    if(titleFormats.get(titleId)!=null){
                        titleFormatSet=titleFormats.get(titleId);
                    }
                    
                    Set<string> setTitleFormat = new Set<string>();
                    list<String> lstTitleFormat = new list<String>();
                    
                    if(mapDPTitle.get(titleId).Formats__c != null){
                        lstTitleFormat = (mapDPTitle.get(titleId).Formats__c).split(';');
                        setTitleFormat.addAll(lstTitleFormat);
                    }
                    for(string countryId : countryIdList) {
                        integer countPreferedLangForCountry=0;
                        set<string> countryChannelSet= new set<string>();
                        list<langPriority> countPreferedLang= new list<langPriority>();
                        countPreferedLang=countryLanguagePrefered.get(countryId);
                        
                        if(countryChannelAvailable.get(countryId)!=null){
                            countryChannelSet=countryChannelAvailable.get(countryId);
                        }
                        
                        countOfPreferedLang = 0;
                        countOfPriorityLang2 = 0;
                        countOfPriorityLang3 = 0;
                        
                        if(!countryChannelSet.isEmpty() ){
                            if(countPreferedLang!=null){
                                Integer idx = 0; // CRRt Phase 7: for getting preference language level
                                for(langPriority objLangPriority : countPreferedLang){//START: Language Priority FOR LOOp  
                                    //Logic added on 5/18/2018
                                    countPreferedLangForCountry++;
                                    if(countPreferedLangForCountry > 1 && englishOnlyChk){
                                        break;
                                    }
                                  //End of Logic
                                    idx++;
                                    for(string countryChannelRec : countryChannelSet){
                                        for(string selectedformat : selectedTitleFormatSet){
                                            if((countryChannelRec == 'EST' && (selectedformat == 'VR'|| selectedformat == 'HD+DVD' || selectedformat == 'HD+BD')) || selectedformat != 'VR'|| selectedformat != 'HD+DVD' || selectedformat != 'HD+BD'){
                                                // as per CRRT phase2 requirement
                                                if((mapDPTitle.get(titleId).Digital_Planning__c == 'Yes' && (selectedformat == 'SD' ||selectedformat == 'HD' || selectedformat == '3DHD' || selectedformat == '4K UHD' || selectedformat == 'VR' || selectedformat == 'HD+DVD'|| selectedformat == 'HD+BD') && countryChannelRec != 'Physical') 
                                                   || (mapDPTitle.get(titleId).Physical_Planning__c == 'Yes' && (selectedformat == 'BD' ||selectedformat == 'DVD' || selectedformat == '3DBD' || selectedformat == '4KBD') && countryChannelRec == 'Physical'))
                                                {  
                                                    if(setTitleFormat.size() > 0 && setTitleFormat.contains(selectedformat)){
                                                        Boolean isClearAvail = false;
                                                        
                                                        if(englishOnlyChk || (objLangPriority.priority =='0' && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical'))){     
                                                                    set<string> langTypes= new set<string>();                                        
                                                                    for(availableLangType titleLangList:titleAvailLangLst){
                                                                        if(((englishOnlyChk && titleLangList.availableLanguage == objEngLang.Id) || (!englishOnlyChk && titleLangList.availableLanguage == objLangPriority.preferedLang)) && titleLangList.langType != null){ //CH01: && condition added //CH02 : Changed for SINC0906572
                                                                            langTypes.add(titleLangList.langType);
                                                                        }
                                                                    }
                                                                    for(channelWrapper objChannelGrid :channelGridList) {                                                    
                                                                        if(countryChannelRec==objChannelGrid.countryChannel) {                                                        
                                                                            boolean langTypeFlag = false;
                                                                            for(string availLangTypes : langTypes){//ER-359 : Added new for loop                                                            
                                                                                if(!langTypeFlag)
                                                                                {
                                                                                    Commercial_Avail__c record=new Commercial_Avail__c();
                                                                                    record.Country_Lookup__c= countryId;
                                                                                    //ER-006428 - Automated Release Date Based on Theatrical Window - Start
                                                                                    if(CountryIdMap.get(countryId) != Null && objChannelGrid.countryChannel != 'Hotel' && mapDPTitle.get(titleId).Content_Type__c == 'Feature'){
                                                                                        record.RP_AutoCalc__c = CountryIdMap.get(countryId).RP_AutoCalc_Default__c; 
                                                                                    }
                                                                                    if(objChannelGrid.countryChannel == 'Physical'){
                                                                                        record.GPP_Avail_Start__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    }
                                                                                    //ER-006428 - Automated Release Date Based on Theatrical Window - End
                                                                                    record.Format__c=selectedformat;
                                                                                    record.Title__c= titleId;
                                                                                    if(langTypes.size()==0)
                                                                                        record.language_type__c = null;
                                                                                    else if(langTypes.size()==1){
                                                                                        if(langTypes.contains('Provisional') && !provisionalLang)
                                                                                            isClearAvail = true;
                                                                                        else{
                                                                                            isClearAvail = false;
                                                                                            if(langTypes.contains('Provisional') && provisionalLang)
                                                                                                record.language_type__c = 'Provisional';
                                                                                            else
                                                                                                record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                        }
                                                                                    }
                                                                                    else if(langTypes.size() > 1){
                                                                                        if(seperateLanguageTypeChk)
                                                                                            record.language_type__c= availLangTypes;
                                                                                        else{
                                                                                            if(!provisionalLang && !langTypes.contains('Audio') && !langTypes.contains('Sub'))//CRRT Phase7: Added Provisional language type
                                                                                                isClearAvail = true;
                                                                                            else{
                                                                                                isClearAvail = false;
                                                                                                if(provisionalLang && langTypes.contains('Provisional'))//CRRT Phase7: Added Provisional language type
                                                                                                    record.language_type__c = 'Provisional';
                                                                                                else if(!provisionalLang && langTypes.contains('Provisional') && (langTypes.contains('Audio') || langTypes.contains('Sub')))//CRRT Phase7: Added Provisional language type
                                                                                                    record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                                else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                                    record.language_type__c= 'Sub & Audio';
                                                                                            }
                                                                                            langTypeFlag = true;
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    if(!isClearAvail){
                                                                                        record.Languages__c= englishOnlyChk ? objEngLang.Id : objLangPriority.preferedLang; //CH02 : Changed for SINC0906572
                                                                                        record.channel__c=countryChannelRec;
                                                                                        //~~~~~~~NEW COMMON METHOD: START~~~~~~~~~~~~~~~~~
                                                                                        populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        //~~~~~~~NEW COMMON METHOD: END~~~~~~~~~~~~~~~~~
                                                                                        record.reason_code__c=objChannelGrid.additionalInfo.reason_code__c;
                                                                                        record.Comments__c=objChannelGrid.additionalInfo.Comments__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                        recordsCreated.add(record);
                                                                                    }
                                                                                    else if(isClearAvail && provisionalLang){// CRRT Phase 7: Added Provisional type exception
                                                                                        Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                                                                                        countExcpetionRec++;
                                                                                        rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                                                                        rpExceptionRec.Title__c = mapDPTitle.get(titleId).Name;
                                                                                        rpExceptionRec.Country__c=objLangPriority.preferedCntyName;
                                                                                        rpExceptionRec.Language__c = englishOnlyChk ? objEngLang.Name : objLangPriority.preferedLangName;
                                                                                        rpExceptionRec.Channel__c=countryChannelRec;
                                                                                        rpExceptionRec.Format__c=selectedformat;
                                                                                        rpExceptionRec.Status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                        rpExceptionRec.Reason__c='Release Plan could not be created because selected country does not have any clear to avail language.';
                                                                                        rpExceptionRec.User_Detail__c=userDetail.id;
                                                                                        releasePlanExceptionList.add(rpExceptionRec);
                                                                                    }
                                                                                }
                                                                            }
                                                                        }                                                  
                                                                    //}
                                                                //}
                                                            }
                                                        }
                                                        if(!englishOnlyChk && titleAvailLang.contains(objLangPriority.preferedLang)){ 
                                                            if(objLangPriority.priority=='1' && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical')){
                                                                set<string> langTypes= new set<string>();
                                                                
                                                                for(availableLangType titleLangList:titleAvailLangLst){
                                                                    if(titleLangList.availableLanguage==objLangPriority.preferedLang && titleLangList.langType != null){ //CH01: && condition added
                                                                        langTypes.add(titleLangList.langType);
                                                                    }
                                                                }
                                                                for(channelWrapper objChannelGrid :channelGridList) {
                                                                    if(countryChannelRec == objChannelGrid.countryChannel) {     
                                                                        boolean langTypeFlag = false;
                                                                        for(string availLangTypes : langTypes){
                                                                            if(!langTypeFlag)
                                                                            {
                                                                                Commercial_Avail__c record=new Commercial_Avail__c();
                                                                                record.Country_Lookup__c= countryId;
                                                                                //ER-006428 - Automated Release Date Based on Theatrical Window - Start
                                                                                if(CountryIdMap.get(countryId) != Null && objChannelGrid.countryChannel != 'Hotel' && mapDPTitle.get(titleId).Content_Type__c == 'Feature'){
                                                                                    record.RP_AutoCalc__c = CountryIdMap.get(countryId).RP_AutoCalc_Default__c; 
                                                                                }
                                                                                if(objChannelGrid.countryChannel == 'Physical'){
                                                                                    record.GPP_Avail_Start__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                }
                                                                                //ER-006428 - Automated Release Date Based on Theatrical Window - End
                                                                                record.Format__c=selectedformat;
                                                                                record.Title__c= titleId;
                                                                                
                                                                                
                                                                                if(langTypes.size()==0)
                                                                                    record.language_type__c= null;
                                                                                else if(langTypes.size()==1){
                                                                                    if(langTypes.contains('Provisional') && !provisionalLang){
                                                                                        isClearAvail = true;
                                                                                        countOfPreferedLang=countOfPreferedLang+1;
                                                                                    }
                                                                                    else{
                                                                                        isClearAvail = false;
                                                                                        if(langTypes.contains('Provisional') && provisionalLang)
                                                                                            record.language_type__c = 'Provisional';
                                                                                        else
                                                                                            record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                    }
                                                                                }
                                                                                else if(langTypes.size() > 1){
                                                                                    if(seperateLanguageTypeChk)
                                                                                        record.language_type__c= availLangTypes;
                                                                                    else{
                                                                                        if(!provisionalLang && !langTypes.contains('Audio') && !langTypes.contains('Sub')){//CRRT Phase7: Added Provisional language type
                                                                                            isClearAvail = true;
                                                                                            countOfPreferedLang=countOfPreferedLang+1;
                                                                                        }
                                                                                        else{
                                                                                            isClearAvail = false;
                                                                                            if(provisionalLang && langTypes.contains('Provisional'))//CRRT Phase7: Added Provisional language type
                                                                                                record.language_type__c = 'Provisional';
                                                                                            else if(langTypes.contains('Provisional') && (langTypes.contains('Audio') || langTypes.contains('Sub')))//CRRT Phase7: Added Provisional language type
                                                                                                record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                            else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                                record.language_type__c= 'Sub & Audio';
                                                                                        }
                                                                                            
                                                                                        langTypeFlag = true;
                                                                                    }
                                                                                }
                                                                                if(!isClearAvail){
                                                                                    record.Languages__c= objLangPriority.preferedLang;
                                                                                    record.channel__c=countryChannelRec;
                                                                                    
                                                                                    //~~~~~~~NEW COMMON METHOD: START~~~~~~~~~~~~~~~~~
                                                                                    populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                    //~~~~~~~NEW COMMON METHOD: END~~~~~~~~~~~~~~~~~
                                                                                    
                                                                                    record.reason_code__c=objChannelGrid.additionalInfo.reason_code__c;
                                                                                    record.Comments__c=objChannelGrid.additionalInfo.Comments__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    recordsCreated.add(record);
                                                                                    countOfPreferedLang=countOfPreferedLang+1;
                                                                                }
                                                                                // CRRT Phase 7: Added Provisional type exception, if preference language at level 1 is provisional
                                                                                else if(isClearAvail && provisionalLang && countPreferedLang.size() == 1){
                                                                                    isClearAvail = false;
                                                                                    Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                                                                                    countExcpetionRec++;
                                                                                    rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                                                                    rpExceptionRec.Title__c = mapDPTitle.get(titleId).Name;
                                                                                    rpExceptionRec.Country__c=objLangPriority.preferedCntyName;
                                                                                    rpExceptionRec.Language__c=objLangPriority.preferedLangName;
                                                                                    rpExceptionRec.Channel__c=countryChannelRec;
                                                                                    rpExceptionRec.Format__c=selectedformat;
                                                                                    rpExceptionRec.Status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    rpExceptionRec.Reason__c='Release Plan could not be created because selected country does not have any clear to avail language.';
                                                                                    rpExceptionRec.User_Detail__c=userDetail.id;
                                                                                    releasePlanExceptionList.add(rpExceptionRec);
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            if(((objLangPriority.priority=='2' && countOfPreferedLang==0 ) || (isClearAvail  && provisionalLang)) && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical')){
                                                                set<string> langTypes= new set<string>();
                                                               
                                                                for(availableLangType titleLangList : titleAvailLangLst){
                                                                    if(!isClearAvail && titleLangList.availableLanguage==objLangPriority.preferedLang && titleLangList.langType != null){ //CH01: && condition added
                                                                        langTypes.add(titleLangList.langType);
                                                                    }
                                                                    // CRRT Phase7: create release plan for preferenece language at level 2 if labguage at level 1 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                    else if(isClearAvail && titleLangList.availableLanguage == countPreferedLang[idx].preferedLang && titleLangList.langType != null){ 
                                                                        langTypes.add(titleLangList.langType);
                                                                    }
                                                                }
                                                                
                                                                for(channelWrapper channelLst:channelGridList){
                                                                    if(countryChannelRec==channelLst.countryChannel){ 
                                                                        if(!(channelLst.additionalInfo.Status__c=='Not Releasing' || channelLst.additionalInfo.Status__c=='Moratorium')){
                                                                            Boolean langTypeFlag = false;
                                                                            for(string availLangTypes : langTypes){//ER-359 : Added new for loop
                                                                                if(!langTypeFlag)
                                                                                {
                                                                                    Commercial_Avail__c record=new Commercial_Avail__c();
                                                                                    record.Country_Lookup__c= countryId;
                                                                                    //ER-006428 - Automated Release Date Based on Theatrical Window - Start
                                                                                    if(CountryIdMap.get(countryId) != Null && channelLst.countryChannel != 'Hotel' && mapDPTitle.get(titleId).Content_Type__c == 'Feature'){
                                                                                        record.RP_AutoCalc__c = CountryIdMap.get(countryId).RP_AutoCalc_Default__c; 
                                                                                    }
                                                                                    if(channelLst.countryChannel == 'Physical'){
                                                                                        record.GPP_Avail_Start__c = channelLst.additionalInfo.Exclusive_Date__c;
                                                                                    }
                                                                                    //ER-006428 - Automated Release Date Based on Theatrical Window - End
                                                                                    record.Format__c=selectedformat;
                                                                                    record.Title__c= titleId;
                                                                                    // CH01 - Start: - Check types available in set of LangTypes for the selected title.
                                                                                    
                                                                                    if(langTypes.size()==0)
                                                                                        record.language_type__c= null;
                                                                                    else if(langTypes.size()==1){
                                                                                        //CRRT Phase7: Added Provisional language type
                                                                                        if(langTypes.contains('Provisional') && !provisionalLang){
                                                                                            isClearAvail = true;
                                                                                            countOfPriorityLang2=countOfPriorityLang2+1;
                                                                                        }
                                                                                        else{
                                                                                            isClearAvail = false;
                                                                                            if(langTypes.contains('Provisional') && provisionalLang)
                                                                                                record.language_type__c = 'Provisional';
                                                                                            else
                                                                                                record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                        }
                                                                                    }
                                                                                    else if(langTypes.size() > 1){
                                                                                        if(seperateLanguageTypeChk)
                                                                                            record.language_type__c= availLangTypes;
                                                                                        else{
                                                                                            if(!provisionalLang && !langTypes.contains('Audio') && !langTypes.contains('Sub')){//CRRT Phase7: Added Provisional language type
                                                                                                isClearAvail = true;
                                                                                                countOfPriorityLang2=countOfPriorityLang2+1;
                                                                                            }
                                                                                            else{
                                                                                                isClearAvail = false;
                                                                                                if(provisionalLang && langTypes.contains('Provisional'))//CRRT Phase7: Added Provisional language type
                                                                                                    record.language_type__c = 'Provisional';
                                                                                                else if(langTypes.contains('Provisional') && (langTypes.contains('Audio') || langTypes.contains('Sub')))//CRRT Phase7: Added Provisional language type
                                                                                                    record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                                else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                                    record.language_type__c= 'Sub & Audio';
                                                                                            }
                                                                                                
                                                                                            langTypeFlag = true;
                                                                                        }
                                                                                    }
                                                                                    if(!isClearAvail){// CRRT Phase7: Don't create release plan if preferenece language at level 2 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                                        record.Languages__c= (objLangPriority.priority == '1') ? countPreferedLang[idx].preferedLang : objLangPriority.preferedLang;
                                                                                        record.channel__c=countryChannelRec;
                                                                                        
                                                                                        //~~~~~~~NEW COMMON METHOD: START~~~~~~~~~~~~~~~~~
                                                                                        populateFromChannelGrid(channelLst, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,channelLst.additionalInfo.Status__c );
                                                                                        //~~~~~~~NEW COMMON METHOD: END~~~~~~~~~~~~~~~~~~~
                                                                                        
                                                                                        record.reason_code__c=channelLst.additionalInfo.reason_code__c;
                                                                                        record.Comments__c=channelLst.additionalInfo.Comments__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                        recordsCreated.add(record);
                                                                                        
                                                                                        countOfPriorityLang2=countOfPriorityLang2+1;
                                                                                    }
                                                                                    // CRRT Phase 7: Added Provisional type exception, if preference language at level 2 is provisional
                                                                                    else if(isClearAvail && provisionalLang && ((objLangPriority.priority=='1' && countPreferedLang.size() == 2) || (objLangPriority.priority=='2' && countPreferedLang.size() == 1))){
                                                                                        isClearAvail = false;
                                                                                        Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                                                                                        countExcpetionRec++;
                                                                                        rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                                                                        rpExceptionRec.Title__c = mapDPTitle.get(titleId).Name;
                                                                                        rpExceptionRec.Country__c=objLangPriority.preferedCntyName;
                                                                                        rpExceptionRec.Language__c= (objLangPriority.priority == '1') ? countPreferedLang[idx].preferedLangName : objLangPriority.preferedLangName;
                                                                                        rpExceptionRec.Channel__c=countryChannelRec;
                                                                                        rpExceptionRec.Format__c=selectedformat;
                                                                                        rpExceptionRec.Status__c=channelLst.additionalInfo.Status__c;
                                                                                        rpExceptionRec.Reason__c='Release Plan could not be created because selected country does not have any clear to avail language.';
                                                                                        rpExceptionRec.User_Detail__c=userDetail.id;
                                                                                        releasePlanExceptionList.add(rpExceptionRec);
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            if(((objLangPriority.priority=='3' && countOfPreferedLang == 0 && countOfPriorityLang2==0) || (isClearAvail && provisionalLang)) && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical')){
                                                                set<string> langTypes= new set<string>();
                                                                idx = objLangPriority.priority=='1'?2:idx;
                                                                
                                                                for(availableLangType titleLangList : titleAvailLangLst){
                                                                    if(!isClearAvail && titleLangList.availableLanguage==objLangPriority.preferedLang && titleLangList.langType != null){ //CH01: && condition added
                                                                        langTypes.add(titleLangList.langType);
                                                                    }
                                                                    // CRRT Phase7: create release plan for preferenece language at level 3 if labguage at level 2 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                    else if(isClearAvail && titleLangList.availableLanguage == countPreferedLang[idx].preferedLang && titleLangList.langType != null){ 
                                                                        langTypes.add(titleLangList.langType);
                                                                    }
                                                                }
                                                                
                                                                for(channelWrapper channelLst:channelGridList){
                                                                    if(countryChannelRec==channelLst.countryChannel){ 
                                                                        if(!(channelLst.additionalInfo.Status__c=='Not Releasing' || channelLst.additionalInfo.Status__c=='Moratorium')){
                                                                            Boolean langTypeFlag = false;
                                                                            for(string availLangTypes : langTypes){//ER-359 : Added new for loop
                                                                                if(!langTypeFlag)
                                                                                {
                                                                                    Commercial_Avail__c record=new Commercial_Avail__c();
                                                                                    record.Country_Lookup__c= countryId;
                                                                                    //ER-006428 - Automated Release Date Based on Theatrical Window - Start
                                                                                    if(CountryIdMap.get(countryId) != Null && channelLst.countryChannel != 'Hotel' && mapDPTitle.get(titleId).Content_Type__c == 'Feature'){
                                                                                        record.RP_AutoCalc__c = CountryIdMap.get(countryId).RP_AutoCalc_Default__c; 
                                                                                    }
                                                                                    if(channelLst.countryChannel == 'Physical'){
                                                                                        record.GPP_Avail_Start__c = channelLst.additionalInfo.Exclusive_Date__c;
                                                                                    }
                                                                                    //ER-006428 - Automated Release Date Based on Theatrical Window - End
                                                                                    record.Format__c=selectedformat;
                                                                                    record.Title__c= titleId;
                                                                                   
                                                                                    // CH01 - Start: - Check types available in set of LangTypes for the selected title.
                                                                                    if(langTypes.size()==0)
                                                                                        record.language_type__c= null;
                                                                                    else if(langTypes.size()==1){
                                                                                        if(langTypes.contains('Provisional') && !provisionalLang){//CRRT Phase7: Added Provisional language type
                                                                                            isClearAvail = true;
                                                                                            countOfPriorityLang3=countOfPriorityLang3+1;
                                                                                        }
                                                                                        else{
                                                                                            isClearAvail = false;
                                                                                            if(langTypes.contains('Provisional') && provisionalLang)//CRRT Phase7: Added Provisional language type
                                                                                                record.language_type__c = 'Provisional';
                                                                                            else
                                                                                                record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                        }
                                                                                    }
                                                                                    else if(langTypes.size() > 1){
                                                                                        if(seperateLanguageTypeChk)
                                                                                            record.language_type__c= availLangTypes;
                                                                                        else{
                                                                                            if(!provisionalLang && !langTypes.contains('Audio') && !langTypes.contains('Sub')){//CRRT Phase7: Added Provisional language type
                                                                                                isClearAvail = true;
                                                                                                countOfPriorityLang3=countOfPriorityLang3+1;
                                                                                            }
                                                                                            else{
                                                                                                isClearAvail = false;
                                                                                                if(provisionalLang && langTypes.contains('Provisional'))//CRRT Phase7: Added Provisional language type
                                                                                                    record.language_type__c = 'Provisional';
                                                                                                else if(langTypes.contains('Provisional') && (langTypes.contains('Audio') || langTypes.contains('Sub')))//CRRT Phase7: Added Provisional language type
                                                                                                    record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                                else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                                    record.language_type__c= 'Sub & Audio';
                                                                                            }
                                                                                                
                                                                                            langTypeFlag = true;
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    // CH01 - End
                                                                                    
                                                                                    if(!isClearAvail){// CRRT Phase7: Don't create release plan if preferenece language at level 3 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                                        record.Languages__c= (objLangPriority.priority != '3') ? countPreferedLang[idx].preferedLang : objLangPriority.preferedLang;
                                                                                        record.channel__c=countryChannelRec;
                                                                                    
                                                                                        //~~~~~~~NEW COMMON METHOD: START~~~~~~~~~~~~~~~~~
                                                                                        populateFromChannelGrid(channelLst, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,channelLst.additionalInfo.Status__c );
                                                                                        //~~~~~~~NEW COMMON METHOD: END~~~~~~~~~~~~~~~~~~~
                                                                                        
                                                                                        record.reason_code__c=channelLst.additionalInfo.reason_code__c;
                                                                                        record.Comments__c=channelLst.additionalInfo.Comments__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                        recordsCreated.add(record);
                                                                                        
                                                                                        countOfPriorityLang3=countOfPriorityLang3+1;
                                                                                    }
                                                                                    // CRRT Phase 7: Added Provisional type exception, if preference language at level 3 is provisional
                                                                                    else if(isClearAvail && provisionalLang && ((objLangPriority.priority=='1' && countPreferedLang.size() == 3) || (objLangPriority.priority=='2' && countPreferedLang.size() == 2) || (objLangPriority.priority=='3' && countPreferedLang.size() == 1))){
                                                                                        isClearAvail = false;
                                                                                        Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                                                                                        countExcpetionRec++;
                                                                                        rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                                                                        rpExceptionRec.Title__c = mapDPTitle.get(titleId).Name;
                                                                                        rpExceptionRec.Country__c=objLangPriority.preferedCntyName;
                                                                                        rpExceptionRec.Language__c=(objLangPriority.priority !='3') ? countPreferedLang[idx].preferedLangName : objLangPriority.preferedLangName;
                                                                                        rpExceptionRec.Channel__c=countryChannelRec;
                                                                                        rpExceptionRec.Format__c=selectedformat;
                                                                                        rpExceptionRec.Status__c=channelLst.additionalInfo.Status__c;
                                                                                        rpExceptionRec.Reason__c='Release Plan could not be created because selected country does not have any clear to avail language.';
                                                                                        rpExceptionRec.User_Detail__c=userDetail.id;
                                                                                        releasePlanExceptionList.add(rpExceptionRec);
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } 
                                                        else{
                                                            if((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical'){
                                                                if(objLangPriority.priority=='1'){
                                                                    set<string> langDiff= new set<string>();
                                                                    
                                                                    for(channelWrapper channelLst :channelGridList) {
                                                                        
                                                                        if(countryChannelRec == channelLst.countryChannel){
                                                                            //SINC2063808: Release Plans Missing Language Type (Removed the Moratorium status check)
                                                                            if(!(channelLst.additionalInfo.Status__c=='Not Releasing')){ // || channelLst.additionalInfo.Status__c=='Moratorium')){
                                                                            }else {  
                                                                                Commercial_Avail__c record=new Commercial_Avail__c();
                                                                                record.Country_Lookup__c= countryId;
                                                                                //ER-006428 - Automated Release Date Based on Theatrical Window - Start
                                                                                if(CountryIdMap.get(countryId) != Null && channelLst.countryChannel != 'Hotel' && mapDPTitle.get(titleId).Content_Type__c == 'Feature'){
                                                                                    record.RP_AutoCalc__c = CountryIdMap.get(countryId).RP_AutoCalc_Default__c; 
                                                                                }
                                                                                if(channelLst.countryChannel == 'Physical'){
                                                                                    record.GPP_Avail_Start__c = channelLst.additionalInfo.Exclusive_Date__c;
                                                                                }
                                                                                //ER-006428 - Automated Release Date Based on Theatrical Window - End
                                                                                record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                record.Rights_End__c=channelLst.additionalInfo.Rights_End__c;
                                                                                record.Format__c=selectedformat;
                                                                                record.Title__c= titleId;
                                                                                record.Languages__c= objLangPriority.preferedLang;
                                                                                record.channel__c=countryChannelRec;
                                                                                record.status__c=channelLst.additionalInfo.Status__c;
                                                                                record.reason_code__c=channelLst.additionalInfo.reason_code__c;
                                                                                record.Comments__c=channelLst.additionalInfo.Comments__c;
                                                                                recordsCreated.add(record);
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }//END : Language Priority FOR LOOp                            
                            }
                            else{
                                if(countryLanguagePrefered.isempty()){
                                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_plan_No_Language_Found));
                                }
                            }
                        }
                    }
                }
            }      
            if(noAvailLangtitlesLst.size()!=0){
                list<title__c> exceptionRecordList= new list<title__c>();
                exceptionRecordList=[select id, name, Video_Version__c from title__c where id IN:noAvailLangtitlesLst];
                for(title__c exceptionRec :exceptionRecordList){
                    Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                    countExcpetionRec++;
                    rpExceptionRec.name= userDetail.id+string.valueof(countExcpetionRec) ;
                    rpExceptionRec.Title__c=exceptionRec.name;
                    rpExceptionRec.Video_Version__c=exceptionRec.Video_Version__c;
                    rpExceptionRec.Reason__c='Title doesn\'t have any available language';
                    rpExceptionRec.User_Detail__c=userDetail.id;
                    releasePlanExceptionList.add(rpExceptionRec);
                }
            }
            if(recordsCreated.size() == 0 && !Apexpages.hasMessages()) {
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Either language is not available on this title for selected country or Selected country language preference level not between 1-3.'));
                return null;
            }
            else
                return recordsCreated;
        }
        
        public list<Commercial_Avail__c> mapRightsDate(list<Commercial_Avail__c> commList){
            map<commercial_avail__c,Id> mapRPrightGroups= new  map<commercial_avail__c,Id>(); 
            set<string> countryList= new set<string>();
            set<string> langList= new set<string>();        
            set<string> mpmList= new set<string>();     
            boolean exactMatch = false;
            boolean partialMatch1 = false;
            boolean partialMatch2 = false;
            List<id> lstTitleIdsnew = new List<id>();
            Set<String> rightGroup = new Set<String>();
            Set<String> rightChannel = new Set<String>();
            
            for (commercial_avail__c ca : commList){
                lstTitleIdsnew.add(ca.title__c);
                rightGroup.add(ca.Rights_GroupF__c);
                rightChannel.add(ca.Channel__c);
            }
            List<title__c> titleList = [SELECT id, name,MPM__c,Video_Version__c FROM Title__c WHERE Id IN:lstTitleIdsnew ];
            Map<ID, ID> mapRPwithMPM = new Map<ID, ID>();
            for(commercial_avail__c commRec:commList){
                for(title__c titleRec:titleList){
                    if(titleRec.id==commRec.title__c){
                        countryList.add(commRec.Country_Lookup__c);
                        langList.add(commRec.Languages__c);
                        
                        mpmList.add(titleRec.MPM__c);
                        mapRPwithMPM.put(commRec.Id, titleRec.MPM__c);
                    }
                }
            }
            
            list<Rights__c> rightList = new list<Rights__c>();
            rightList=[Select Name,id,Channel__c,MPM__c,Rights_End__c,Rights_Group__c,Rights_Start__c
                       from Rights__c  where  MPM__c IN :mpmList AND Rights_Group__c in :rightGroup
                       AND Channel__c in :rightChannel
                       ORDER BY LastModifiedDate DESC];
            
            for(commercial_avail__c objRP:commList){
                Boolean isPefectFound =false;
                Boolean isPefectFound1 =false;
                Boolean isPefectFound2 =false;
                Boolean isPefectFound3 =false;
                for(Rights__c objRight:rightList){   
                    if(mapRPwithMPM.get(objRP.ID) != null && objRP.Channel__c != null && objRP.Rights_GroupF__c != null &&
                       objRP.Exclusive_Date__c != null && objRP.Rights_End__c!= null && objRight.Rights_Group__c!= null && 
                       objRight.Channel__c != null && objRight.MPM__c != null && mapRPwithMPM.get(objRP.ID) == objRight.MPM__c &&
                       objRP.Channel__c==objRight.Channel__c && objRP.Rights_GroupF__c ==objRight.Rights_Group__c){
                           if(objRight.Rights_Start__c!=null && objRight.Rights_End__c!=null){
                               if(objRP.Exclusive_Date__c <= objRight.Rights_End__c && objRP.Rights_End__c >= objRight.Rights_Start__c){
                                   objRP.Rights_ID__c = objRight.Id;
                                   isPefectFound = true;
                                   break;
                               } else {
                                   if(!isPefectFound){
                                       objRP.Rights_ID__c = objRight.Id;
                                       isPefectFound1  = true;
                                    }
                               }
                           }else{
                               if(!isPefectFound1){
                                   objRP.Rights_ID__c = objRight.Id;
                                   isPefectFound2 = true;  
                                }
                           }
                       }else if(!(isPefectFound || isPefectFound1 || isPefectFound2) && mapRPwithMPM.get(objRP.ID) ==objRight.MPM__c && objRight.Channel__c==null && objRight.Rights_Group__c==null){
                           objRP.Rights_ID__c = objRight.Id;
                           isPefectFound3 = true; 
                       } else if(!(isPefectFound || isPefectFound1 || isPefectFound2 || isPefectFound3)) {
                           objRP.Rights_ID__c = null;
                        } 
                }
                
            }
            
            return commList;
            
        }
        
        /****** Method invoked on click of cancel button ******/ 
        public pagereference cancel(){
            pageReference PageRef= new Pagereference('');
            if(param=='std'){
                PageRef = new Pagereference('/'+titleIdRedir);
            }
            else if(param=='search'){
                PageRef = new Pagereference(System.Label.Re_Direct_to_Title_Search);
            }
            else PageRef = new Pagereference(System.Label.Cancle_Commercial_Avails);
            return PageRef;
        }
        
        public void clearList(){
            CountryIdList.clear();
            displayedchannelIds.clear();
            FormatIdList.clear();
            
        }    
        
        public void delWrapper(){        
            Integer toDelPos=-1;
            for (Integer idx=0; idx<channelGridList .size(); idx++){
                if (channelGridList[idx].delIndent==toDelIdent){
                    toDelPos=idx;
                }
            }
            if (-1!=toDelPos){
                channelGridList.remove(toDelPos);
            }
        }
        
        // Added by Imran on 24 Oct 2014 to get channel in sequence as per user story:327
        public void addWrapper(){
            
            List<channelWrapper> tempList = new channelWrapper[channelGridList.size()+1];
            integer matchIndex = -1;
            
            for (Integer idx=0; idx< channelGridList.size(); idx++){
                if (channelGridList[idx].addIndent == toAddIdent){
                    matchIndex = idx;
                    tempList[matchIndex] = channelGridList[idx];
                    
                    channelWrapper addChannelRec= new channelWrapper();
                    addChannelRec.countryChannel= channelGridList[idx].countryChannel; 
                    Commercial_Avail__c addCommChannel= new Commercial_Avail__c();
                    addCommChannel.status__c='Draft';
                    addChannelRec.additionalInfo= addCommChannel;
                    
                    if(channelGridList[idx].countryChannel=='EST'){
                        addChannelRec.renderExclusiveDate=true;
                    } else addChannelRec.renderExclusiveDate=false;
                    
                    addChannelRec.delIndent=channelGridList.size()+1;
                    addChannelRec.addIndent= channelGridList.size()+1;
                    tempList[++matchIndex] = addChannelRec;
                } else{
                    if(matchIndex<0){
                        tempList[idx] = channelGridList[idx];
                    }else{
                        tempList[++matchIndex] =channelGridList[idx];
                    }
                }
            }
            
            channelGridList.clear();
            channelGridList.addAll(tempList);
        }
        
        /*********Methode for Country Group and Country**************/
        public void findCountry(){
            
            list<string> selectedCountryIds= new list<string>();
            countryGrpId= obj.Country_Group__c;
            if(countryGrpId !=null){
                countryGrpCountries= [select Name from country_groups__c  where id=:countryGrpId];
                list<Country_Group_Country__c> country_group_countryIds= new list<Country_Group_Country__c>();
                country_group_countryIds=[SELECT Id FROM Country_Group_Country__c where country_Group__c=:countryGrpId AND Country__r.Status__c='Active'];
                
                list<string> Country_grp_countryIds= new list<string>();
                for(integer i=0;i<country_group_countryIds.size();i++){
                    Country_grp_countryIds.add(country_group_countryIds[i].Id);
                }
                
                list<Country_Group_Country__c> selectedcountryList= new list<Country_Group_Country__c>();
                selectedcountryList=[SELECT Country__c FROM Country_Group_Country__c where id IN:Country_grp_countryIds];
                
                for(integer n=0;n<selectedcountryList.size();n++){
                    selectedCountryIds.add(selectedcountryList[n].Country__c);
                }
                for(Country_Groups__c countryGroup : countryGrpCountries){
                    countryGroupCountriesList = countryGroup.Country_Group_Countries__r;
                }
                
                if(Country_grp_countryIds.isEmpty()){
                    noCountryFound=true;
                    grpCountriesFound=false;
                    NoCountryFoundMsg=System.Label.ReleasePlan_NoCountry_for_CountryGrp;
                }
                if(!Country_grp_countryIds.isEmpty()){
                    noCountryFound=false;
                    grpCountriesFound=true;
                    grpCountriesFoundMsg=System.label.ReleasePlan_Country_For_CountryGrp+countryGrpCountries[0].Name;
                }
            }
            
            list<country__c> conList=[select id, name from country__c where id IN:selectedCountryIds];
            
            for(country__c country:conList){
                selectedCountriesRecords.add(new SelectOption(country.Id, country.Name));
            }
            
            list<country__c> allConList= [select Id, name from country__c order by name];
            
            
            Set<SelectOption> selectedCountries = new Set<SelectOption>(selectedCountriesRecords);
            /**CRRTs changes Starts here **/
            /**  Commented as per CRRTs Phase 2 requirment:Available country list showing duplicate countries **/
            /**  Added as per CRRTs Phase 2 requirment:Available country list not showing duplicate countries **/
            Integer j = 0;
            while (j < allCountries.size())
            {
                if(selectedCountries.contains(allCountries.get(j))){
                    allCountries.remove(j);
                    
                }
                else{
                    j++;
                }
            }
            doSort(allCountries,FieldToSort.Label);
            
            /**CRRTs changes Ends here **/
            Set<SelectOption> selectedUniqueCountries = new Set<SelectOption>(selectedCountriesRecords);
            selectedCountriesRecords.clear();
            selectedCountriesRecords.addAll(selectedUniqueCountries);
            FlagCountryGrp=false;
            FlagCountries=true;
            list<string> channelcountryList= new list<string>();
            for(integer i=0;i<selectedCountriesRecords.size();i++){
                channelcountryList.add(selectedCountriesRecords[i].getvalue());
            }
            doSort(selectedCountriesRecords,FieldToSort.Label);
            list<Country__c> countryChannelListNew= new list<Country__c> ();
            countryChannelListNew= [SELECT Channel__c FROM Country__c WHERE ID IN:channelcountryList];
            
            ChannelDisplay= new set<string>();
            set<string> ChannelDisplayId= new set<string>();
            for(Country__c conChannel:countryChannelListNew){
                ChannelDisplay.add(conChannel.channel__c);
                ChannelDisplayId.add(conChannel.channel__c);
            }
            displayedchannelIds.addAll(ChannelDisplayId);
        }
        /**CRRTs changes Starts here **/
        Public enum FieldToSort {
            Label, Value
                }
        
        public static void doSort(List<Selectoption> opts, FieldToSort sortField) {
            
            Map<String, Selectoption> mapping = new Map<String, Selectoption>();
            // Suffix to avoid duplicate values like same labels or values are in inbound list 
            Integer suffix = 1;
            for (Selectoption opt : opts) {
                if (sortField == FieldToSort.Label) {
                    mapping.put(    
                        (opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
                        opt);   
                } else {
                    mapping.put(    
                        (opt.getValue() + suffix++), // Key using Label + Suffix Counter  
                        opt);   
                }
            }
            List<String> sortKeys = new List<String>();
            sortKeys.addAll(mapping.keySet());
            sortKeys.sort();
            // clear the original collection to rebuilt it
            opts.clear();
            
            for (String key : sortKeys) {
                opts.add(mapping.get(key));
            }
        }
        /**CRRTs changes Ends here **/
        
        public pageReference viewRightsRedirect(){
            pageReference pageRef= new pageReference('/apex/WB_MpmReleasePlanExportPage');
            return pageRef;
        }
        
        public pageReference Channelgrid(){
            if(provisionalLang && seperateLanguageTypeChk){// Added in CRRT Phase 7
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Release Plan can not be created if both \'Include Provisional Languages\' and \'Separate Language Types\' are checked.'));
            }
            else{
                Boolean digiFlag = False;
                Boolean phyFlag = False;
                Boolean onlyEST = false;
                
                for(SelectOption selOp : selectedFormats){
                    if((selOp.getValue() == 'VR') || (selOp.getValue() == 'HD+BD') || (selOp.getValue() == 'HD+DVD'))
                        onlyEST = True;
                    else if((selOp.getValue() == 'SD') || (selOp.getValue() == 'HD') || (selOp.getValue() == '3DHD') || (selOp.getValue() == '4K UHD'))
                        digiFlag = True;
                    else if((selOp.getValue() == 'BD') || (selOp.getValue() == 'DVD') || (selOp.getValue() == '3DBD') || (selOp.getValue() == '4KBD'))
                        phyFlag = True;
                }
                
                date myDate = date.newInstance(2049, 12, 31);
                String dayString = myDate.format();
                ChannelGridMessage= system.label.ChannelGridMessage_On_Release_Plan+'-'+ dayString;
                CountryIdList.clear();
                channelGridFlag=true;
                noChannelFlag=false;
                noSelectedCountry=false;
                if(noFormatFlag==false && noAvailLang==false){
                    if(selectedCountriesRecords.size()!= 0){
                        for(SelectOption s5:selectedCountriesRecords ){
                            string selectedCountrieslistIds= s5.getValue();
                            CountryIdList.add(selectedCountrieslistIds);
                        }
                        list<country__c> countryAvailableChannelNew = new list<Country__c>();
                        countryAvailableChannelNew=[select id,Channel__c from Country__c where ID IN:CountryIdList];
                        
                        list<string> channelFinalList= new list<string>();
                        list<string> channelListSplit;
                        set<string> channelGridFinalList= new set<string>();
                        if(countryAvailableChannelNew.size()!=0){
                            for(country__c channelItr : countryAvailableChannelNew ){
                                string str= channelItr.Channel__c;
                                if(str!=null){
                                    channelListSplit= new list<string>();
                                    channelListSplit= str.split(';');
                                    
                                    for(integer i=0;i<channelListSplit.size();i++){
                                            if(digiFlag && phyFlag)
                                                channelGridFinalList.add(channelListSplit[i]);
                                            else if(onlyEST && !digiFlag && !phyFlag && channelListSplit[i] == 'EST')
                                                channelGridFinalList.add(channelListSplit[i]);
                                            else if(onlyEST && !digiFlag && phyFlag && (channelListSplit[i] == 'Physical' || channelListSplit[i] == 'EST'))
                                                channelGridFinalList.add(channelListSplit[i]);
                                            else if(!onlyEST && !digiFlag && phyFlag && channelListSplit[i] == 'Physical')
                                                channelGridFinalList.add(channelListSplit[i]);
                                            else if(digiFlag && !phyFlag && channelListSplit[i] != 'Physical')
                                                channelGridFinalList.add(channelListSplit[i]);
                                    }
                                }
                            }
                        } else{
                            channelGridFlag=false;
                            noChannelFlag=true;
                        }
                        countryAvailableChannel= new list<string>();
                        countryAvailableChannel.addAll(channelGridFinalList);
                        Integer itrDel=0;
                        Integer itrAdd=0;
                        channelGridList= new list<channelWrapper>();
                        set<string> channelName= new set<string>();
                        
                        for(string channelListIterate:countryAvailableChannel ){
                            if(!channelName.contains(channelListIterate)){
                                channelName.add(channelListIterate);     
                                channelWrapper channelRec= new channelWrapper();
                                channelRec.countryChannel=channelListIterate;
                                channelRec.additionalInfo= new Commercial_Avail__c();
                                if(isRightToCreateRPChk == true ||isRightToCreateRPEND==true)
                                    channelRec.additionalInfo.status__c='';
                                else
                                    channelRec.additionalInfo.status__c='Draft';
                                
                                channelRec.renderExclusiveDate = (channelListIterate=='EST') ? true : false;                        
                                channelRec.delIndent= itrDel++; 
                                channelRec.addIndent= itrAdd++;
                                channelGridList.add(channelRec);
                            }
                        }
                        
                        if(countryAvailableChannel.size()==0){
                            channelGridFlag=false;
                            noChannelFlag=true;
                            noSelectedCountry=false;
                        }
                    } else{
                        channelGridFlag=false;
                        noChannelFlag=false;
                        noSelectedCountry=true;
                    }
                }else {
                    channelGridFlag=false;
                    noChannelFlag=false;
                    noSelectedCountry=true;
                }
            }
            return null;
        }
        
        public class langPriority{
            string priority{get;set;}
            string preferedLang{get;set;}
            string preferedLangName{get;set;}
            string preferedCntyName{get;set;}
            Boolean isPhysical {get; set;}
        }
        
        public class titleLangCount{
            public Title__c titlesDispalyed{get;set;}
            public Integer countLangAvailable{get;set;}
            public string reasonForFailure{get;set;}
            public Integer countLangProvisional{get;set;}
        }
        
        public class availableLangType{
            string langType{get;set;}
            string availableLanguage{get;set;}
        }
        
        public class channelWrapper{
            public string countryChannel{get;set;}
            public Commercial_Avail__c additionalInfo{get;set;}
            public Integer delIndent {get;set;}
            public Integer addIndent {get;set;}
            public boolean renderExclusiveDate{get;set;}
        }
        
        public void populateFromChannelGrid(channelWrapper  objChannelGrid, map<id, date> firstAvalTitleDateMap, map<id, date> expirationDateTitleMap, string  titleId, Commercial_Avail__c  record,String gridstatus ){
          
          if(gridStatus=='Draft'|| gridStatus=='Open'||(gridStatus!=null && gridStatus!='Not Releasing')){
              if (objChannelGrid.additionalInfo.Start_Date__c == null && objChannelGrid.additionalInfo.End_Date__c == null && objChannelGrid.additionalInfo.Exclusive_Date__c == null && objChannelGrid.additionalInfo.Rights_End__c == null) {
                if(firstAvalTitleDateMap.get(titleId) != null) {
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId);
                  record.Start_Date__c = firstAvalTitleDateMap.get(titleId);
                } 
                else{
                  record.Exclusive_Date__c = System.Today();
                  record.Start_Date__c = System.Today();
                }
                if(expirationDateTitleMap.get(titleId) != null) {
                    record.Rights_End__c = expirationDateTitleMap.get(titleId);
                } 
                else
                  record.Rights_End__c = date.newInstance(2049, 12, 31);
                record.End_Date__c = record.Rights_End__c;
                record.status__c = objChannelGrid.additionalInfo.Status__c;
                
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c == null && objChannelGrid.additionalInfo.End_Date__c != null && objChannelGrid.additionalInfo.Exclusive_Date__c == null && objChannelGrid.additionalInfo.Rights_End__c != null) {
                if(firstAvalTitleDateMap.get(titleId) != null) {
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId);
                  record.Start_Date__c = record.Exclusive_Date__c;
                } 
                else{
                  record.Exclusive_Date__c = System.Today();
                  record.Start_Date__c = System.Today();
                }
                if(expirationDateTitleMap.get(titleId) != null) {
                  record.Rights_End__c = expirationDateTitleMap.get(titleId) < objChannelGrid.additionalInfo.Rights_End__c ? expirationDateTitleMap.get(titleId) : objChannelGrid.additionalInfo.Rights_End__c;
                  record.End_Date__c = expirationDateTitleMap.get(titleId) < objChannelGrid.additionalInfo.End_Date__c ? expirationDateTitleMap.get(titleId) : objChannelGrid.additionalInfo.End_Date__c;
                } 
                else{
                  record.Rights_End__c = objChannelGrid.additionalInfo.Rights_End__c;
                  record.End_Date__c = objChannelGrid.additionalInfo.End_Date__c;
                }
                record.status__c = objChannelGrid.additionalInfo.Status__c;
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c == null && objChannelGrid.additionalInfo.End_Date__c == null && objChannelGrid.additionalInfo.Exclusive_Date__c == null && objChannelGrid.additionalInfo.Rights_End__c != null) {
                
                record.End_Date__c = null;
                    if(expirationDateTitleMap.get(titleId)!=null){
                        record.Rights_End__c = expirationDateTitleMap.get(titleId) < objChannelGrid.additionalInfo.Rights_End__c ? expirationDateTitleMap.get(titleId) : objChannelGrid.additionalInfo.Rights_End__c;
                    }
                    else{
                        record.Rights_End__c = objChannelGrid.additionalInfo.Rights_End__c ;
                    }
                if(firstAvalTitleDateMap.get(titleId) != null) {
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId);
                } 
                else{
                  record.Exclusive_Date__c = System.Today();
                }
                record.Start_Date__c = null;
                record.status__c = objChannelGrid.additionalInfo.Status__c;
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c != null && objChannelGrid.additionalInfo.End_Date__c == null && objChannelGrid.additionalInfo.Exclusive_Date__c != null && objChannelGrid.additionalInfo.Rights_End__c == null) {
                if(firstAvalTitleDateMap.get(titleId) != null){
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId) > objChannelGrid.additionalInfo.Exclusive_Date__c ? firstAvalTitleDateMap.get(titleId) : objChannelGrid.additionalInfo.Exclusive_Date__c;
                  record.Start_Date__c = firstAvalTitleDateMap.get(titleId) > objChannelGrid.additionalInfo.Start_Date__c ? firstAvalTitleDateMap.get(titleId) : objChannelGrid.additionalInfo.Start_Date__c;
                }
                else{
                  record.Exclusive_Date__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                  record.Start_Date__c = objChannelGrid.additionalInfo.Start_Date__c;
                }
                if(expirationDateTitleMap.get(titleId) != null) {
                  record.Rights_End__c = expirationDateTitleMap.get(titleId);
                  record.End_Date__c = expirationDateTitleMap.get(titleId);
                }
                else{
                  record.Rights_End__c = date.newInstance(2049, 12, 31);
                  record.End_Date__c = record.Rights_End__c;
                }
                record.status__c = objChannelGrid.additionalInfo.Status__c;
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c == null && objChannelGrid.additionalInfo.End_Date__c == null && objChannelGrid.additionalInfo.Exclusive_Date__c != null && objChannelGrid.additionalInfo.Rights_End__c == null) {
                
                if(firstAvalTitleDateMap.get(titleId)!=null){
                    record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId) > objChannelGrid.additionalInfo.Exclusive_Date__c ? firstAvalTitleDateMap.get(titleId) : objChannelGrid.additionalInfo.Exclusive_Date__c;
                }
                else
                    record.Exclusive_Date__c= objChannelGrid.additionalInfo.Exclusive_Date__c;
                record.Start_Date__c = null;
                
                if (expirationDateTitleMap.get(titleId) != null) {
                    
                  record.Rights_End__c = expirationDateTitleMap.get(titleId);
                }
                else
                  record.Rights_End__c = date.newInstance(2049, 12, 31);
            
                record.End_Date__c = null;
                record.status__c = objChannelGrid.additionalInfo.Status__c;    
            
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c != null && objChannelGrid.additionalInfo.End_Date__c != null && objChannelGrid.additionalInfo.Exclusive_Date__c != null && objChannelGrid.additionalInfo.Rights_End__c != null) {
                if (firstAvalTitleDateMap.get(titleId) != null){
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId) > objChannelGrid.additionalInfo.Exclusive_Date__c ? firstAvalTitleDateMap.get(titleId) : objChannelGrid.additionalInfo.Exclusive_Date__c;
                  record.Start_Date__c = firstAvalTitleDateMap.get(titleId) > objChannelGrid.additionalInfo.Start_Date__c ? firstAvalTitleDateMap.get(titleId) : objChannelGrid.additionalInfo.Start_Date__c;
                } 
                else{
                  record.Exclusive_Date__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                  record.Start_Date__c = objChannelGrid.additionalInfo.Start_Date__c;
                }
                if(expirationDateTitleMap.get(titleId) != null){
                  record.Rights_End__c = expirationDateTitleMap.get(titleId) < objChannelGrid.additionalInfo.Rights_End__c ? expirationDateTitleMap.get(titleId) : objChannelGrid.additionalInfo.Rights_End__c;
                  record.End_Date__c = expirationDateTitleMap.get(titleId) < objChannelGrid.additionalInfo.End_Date__c ? expirationDateTitleMap.get(titleId) : objChannelGrid.additionalInfo.End_Date__c;
                } 
                else{
                  record.Rights_End__c = objChannelGrid.additionalInfo.Rights_End__c;
                  record.End_Date__c = objChannelGrid.additionalInfo.End_Date__c;
                }
                record.status__c = objChannelGrid.additionalInfo.Status__c;
                record.Reason_Code__c = objChannelGrid.additionalInfo.Reason_Code__c;
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c != null && objChannelGrid.additionalInfo.End_Date__c != null && objChannelGrid.additionalInfo.Exclusive_Date__c == null && objChannelGrid.additionalInfo.Rights_End__c == null) {
                record.Start_Date__c = objChannelGrid.additionalInfo.Start_Date__c;
                record.End_Date__c = objChannelGrid.additionalInfo.End_Date__c;
            
                if (firstAvalTitleDateMap.get(titleId) != null) {
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId);
                } 
                else
                  record.Exclusive_Date__c = System.Today();
                date myDate = date.newInstance(2049, 12, 31);
                String dayString = myDate.format();
            
                record.Rights_End__c = (expirationDateTitleMap.get(titleId) != null) ? expirationDateTitleMap.get(titleId) : date.parse(dayString);
            
                record.status__c = objChannelGrid.additionalInfo.Status__c;
              } 
              else if(objChannelGrid.additionalInfo.Start_Date__c == null && objChannelGrid.additionalInfo.End_Date__c == null && objChannelGrid.additionalInfo.Exclusive_Date__c != null && objChannelGrid.additionalInfo.Rights_End__c != null) {
                record.Start_Date__c = objChannelGrid.additionalInfo.Start_Date__c;
                record.End_Date__c = objChannelGrid.additionalInfo.End_Date__c;
                record.Exclusive_Date__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                record.Rights_End__c = objChannelGrid.additionalInfo.Rights_End__c;
                record.status__c = objChannelGrid.additionalInfo.Status__c;
              } 
              else if((objChannelGrid.additionalInfo.Start_Date__c == null || objChannelGrid.additionalInfo.End_Date__c == null) && objChannelGrid.additionalInfo.Exclusive_Date__c != null && objChannelGrid.additionalInfo.Rights_End__c != null){
                if (firstAvalTitleDateMap.get(titleId) != null) {
                  record.Exclusive_Date__c = firstAvalTitleDateMap.get(titleId) > objChannelGrid.additionalInfo.Exclusive_Date__c ? firstAvalTitleDateMap.get(titleId) : objChannelGrid.additionalInfo.Exclusive_Date__c;
                  record.Start_Date__c = null;
                } 
                else{
                  record.Exclusive_Date__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                  record.Start_Date__c = null;
                }
                if (expirationDateTitleMap.get(titleId) != null) {
                  record.Rights_End__c = expirationDateTitleMap.get(titleId) < objChannelGrid.additionalInfo.Rights_End__c ? expirationDateTitleMap.get(titleId) : objChannelGrid.additionalInfo.Rights_End__c;
                  record.End_Date__c = null;
                } 
                else{
                  record.Rights_End__c = objChannelGrid.additionalInfo.Rights_End__c;
                  record.End_Date__c = null;
                }
            
                record.status__c = objChannelGrid.additionalInfo.Status__c;
                record.Reason_Code__c = objChannelGrid.additionalInfo.Reason_Code__c;
              } 
              else{
                record.Start_Date__c = objChannelGrid.additionalInfo.Start_Date__c;
                record.End_Date__c = objChannelGrid.additionalInfo.End_Date__c;
                record.Exclusive_Date__c = objChannelGrid.additionalInfo.Exclusive_Date__c;
                record.Rights_End__c = objChannelGrid.additionalInfo.Rights_End__c;
                record.status__c = objChannelGrid.additionalInfo.Status__c;
              }
          }
          else if(gridStatus=='Not Releasing'){
                record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                record.status__c=objChannelGrid.additionalInfo.Status__c;
            } 
        }
        
        
    }