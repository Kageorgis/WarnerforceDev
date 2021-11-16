/* =============================================================================================
*  Author                               Date                                       Comment
*  Mahesh Hirugade                      27/08/2015                                 Initial Draft
*  Prachi Gadewar                       5/10/2015                                  CH01: Added code to support ER: Language Readiness changes.
*  Purushottam                          16/12/2016                                 As a part of CRRT Phase 2 requirment
*  Preeti jha                           31/1/2017                                  Crrt Phase 3: Confirmed Partial Rights should be included only when user SELECT the popup as yes.
*  Purushottam Gupta                    28/03/2018                                 ER-001181   Apply TTB Reason Code to TBA Status  
*/

public class WB_Batch_ReleasePlanWizard implements Database.Batchable<sObject>,Database.Stateful{
    
    String queryString=''; // Query string used to get scope in Execute method.
    list<String> lstTitleIds  ;
    list<string> lstCountryIds;
    list<WB_CreateCommercialAvail_Controller.channelWrapper> channelGridList;
    
    list<Available_Languages__c> titleAvailableLangList;
    Map<Id,Title__c> titleList; // changed list to map
    public list<Release_Plan_Exceptions__c> releasePlanExceptionList;
    list<Commercial_Avail__c> recordsCreated;
    
    map<Id,set<availablelangType>> titleId_availLangTypeSetMap;
    map<Id,set<string>> countryChannelAvailable;
    map<id, date> firstAvalTitleDateMap;
    map<id, date> expirationDateTitleMap;
    Map<Id,set<string>> titleFormats;
    
    public integer countExcpetionRec = 0;
    public boolean seperateLanguageTypeChk = false;//359
    public boolean englishOnlyChk = false;//359
    public set<String> selectedTitleFormatSet;//359
    Language__c objEngLang;//359
    public String ConfirmedPartialAllow;
    
    public Set<Id> setNewRPId;
    
    User userDetail;
    
    Set<Id> setMPMId;
    
    Map<String, String> mapRightsGrp;
    List<Rights__c> lstRights;
    
    private Integer newRPCount, failedRPCount;
    Boolean isRightToCreateRPChk;
    Boolean provisionalLang;
    
    public WB_Batch_ReleasePlanWizard(list<string> pTitleIdList, list<string> pCountryIdList, list<WB_CreateCommercialAvail_Controller.channelWrapper> pChannelGridList,Map<String, String> pMapRightsGrp, List<Rights__c> pLstRights, Set<String> pSelectedFormatStrSet, Boolean pIsRightToCreateRPChk, String ConfirmedPartial, Boolean pProvisionalLang){
        newRPCount = 0; failedRPCount = 0;
        isRightToCreateRPChk = pIsRightToCreateRPChk;
        provisionalLang = pProvisionalLang;
        userDetail = [SELECT id, ProfileId, Profile.Name, UserType, Territory__c, RP_Batch_Id__c from User where id =: Userinfo.getUserId()];
        List<Language__c> engLangList = [select Id, Name, Language_Order__c, Language_Code_2__c from Language__c where Name = 'English'];//359
        objEngLang  = (engLangList != null && engLangList.size() > 0) ? engLangList[0] : new Language__c();
        
        lstTitleIds = pTitleIdList;
        lstCountryIds = pCountryIdList;
        channelGridList = pChannelGridList;
        
        titleFormats = new map<Id,set<string>>(); 
        firstAvalTitleDateMap= new map<Id,date>(); 
        expirationDateTitleMap = new map<Id,date>();
        releasePlanExceptionList = new list<Release_Plan_Exceptions__c>();
        selectedTitleFormatSet = pSelectedFormatStrSet;//359
        
        ConfirmedPartialAllow = ConfirmedPartial;
        integer noFormatCount=0;
        setMPMId = new Set<Id>(); 
        setNewRPId = new Set<Id>();
        mapRightsGrp = pMapRightsGrp;
        lstRights = pLstRights;
        
        titleList= new Map<Id,Title__c>([ SELECT id, name,Expiration_Date__c,Abstract_EIDR_formula__c, Title_Type__c,First_Available_Date__c,Production_Year_formula__c, 
                                        MPM__c,Video_Version__c,Studio__c,Genre__c,Short_Synopsis__c,Formats__c,(SELECT id FROM Available_Languages__r)
                                        FROM Title__c 
                                        WHERE Id IN:pTitleIdList and (Digital_Planning__c='Yes' or Physical_Planning__c='Yes')
                                        ]);
        
        List<Id> lstMPMID = new List<Id>();
        
        for(Title__c objTitle: titleList.values()){ 
            lstMPMID.add(objTitle.MPM__c);
            set<string> formatSet = new set<string>();
            //vvlistString = vvlistString + objTitle.Video_Version__c +',';
            
            if(objTitle.Formats__c != null && objTitle.Formats__c != ''){
                for(String format : objTitle.Formats__c.split(';')){
                    formatSet.add(format);
                }
                titleFormats.put(objTitle.Id, formatSet);
                system.debug('*******titleFormats:'+titleFormats);
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
        
        if(releasePlanExceptionList != null && releasePlanExceptionList.size() > 0 ){
            Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        queryString = 'SELECT Id, Channel__c, Name, Country_Code2__c from Country__c where Id IN: lstCountryIds';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Country__c> scope){
        
        map<Id, Country__c> countryMap = new map<Id, Country__c>(scope);
        Map<Id,Language__c> languageMap = new map<Id, Language__c>([Select id,name from Language__c]);
        Map<Id,Title__c> mapDPTitle = new Map<Id,Title__c>([SELECT Id, Name, Digital_Planning__c, Physical_Planning__c, Video_Version__c, Formats__c FROM Title__c WHERE Id IN: lstTitleIds]);        
        map<Id,list<langPriority>> countryLanguagePrefered;
        list<Language_Preference__c> countryPreferedLanguage;
        list<string> noAvailLangtitlesLst= new list<string>();
        
        //releasePlanExceptionList = new list<Release_Plan_Exceptions__c>();
        
        /** Started--Map for title, and available language **/
        titleAvailableLangList = new list<Available_Languages__c>([select id,Language_Types__c,Language__c,Title__c,Clear_to_Avail__c,Provisional__c 
                                                                    from Available_Languages__c
                                                                    where Title__c IN:lstTitleIds 
                                                                    AND (Clear_to_Avail__c = TRUE OR Provisional__c = TRUE)]);
        titleId_availLangTypeSetMap = new map<Id,set<availableLangType>>();
        
        for(Available_Languages__c availableLang : titleAvailableLangList){
            availableLangType avLangType = new availableLangType();
            //avLangType.langType = availableLang.language_types__c;
            // CH01 - if Clear to avail check then only add the language type in list. which will needs to create release plan.
            /*if(availableLang.Clear_to_Avail__c)
                avLangType.langType = availableLang.language_types__c;*/
        //Updated if condition - SINC1501424
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
        list<Country__c> selectedCountryList = new list<Country__c>([select id,Channel__c,name from Country__c where ID IN:countryMap.keySet()]);
        countryChannelAvailable = new map<Id,set<string>>();
        
        for(Country__c availableCountry : scope){
            set<string> channelCountryListUnique = new set<string>();
            string channelStr = availableCountry.Channel__c;
            
            if(channelStr!=null && channelStr != ''){
                string[] channelSplit = channelStr.split(';');
                for(integer i=0;i<channelSplit.size();i++){
                    channelCountryListUnique.add(channelSplit[i]);
                }
                countryChannelAvailable.put(availableCountry.Id,channelCountryListUnique);
            }
            else{
                for(Title__c titleRec : titleList.values()){
                    Release_Plan_Exceptions__c rpExceptionRec = new Release_Plan_Exceptions__c();
                    countExcpetionRec++;
                    rpExceptionRec.name = userInfo.getUserId() + string.valueof(countExcpetionRec);
                    rpExceptionRec.Title__c = titleRec.name;
                    rpExceptionRec.Video_Version__c=titleRec.Video_Version__c;
                    rpExceptionRec.Country__c = availableCountry.name;
                    rpExceptionRec.Reason__c = 'Country has not been associated with any channel';
                    rpExceptionRec.User_Detail__c = userInfo.getUserId();
                    releasePlanExceptionList.add(rpExceptionRec);
                }
            }
        }
        /** Ended--Map for country, and channel**/
        
        /** Started--Map for country, and language preference **/
        countryPreferedLanguage = new list<Language_Preference__c>([ select id,Language__c, Language__r.Name,Level__c,Country__c, Country__r.Name, Physical_Only__c
                                                                    from Language_Preference__c
                                                                    where Country__c IN:countryMap.keySet() order by Level__c
                                                                   ]);
        countryLanguagePrefered = new map<Id,list<langPriority>>();
        
        for(Language_Preference__c preferedLanguage : countryPreferedLanguage){
            langPriority langLevel =new langPriority();
            langLevel.priority = preferedLanguage.Level__c;
            langLevel.preferedLang = preferedLanguage.Language__c;
            langLevel.preferedLangName = preferedLanguage.Language__r.Name; // Added in CRRT Phase 7 release
            langLevel.preferedCntyName = preferedLanguage.Country__r.Name;// Added in CRRT Phase 7 release
            langLevel.isPhysical = preferedLanguage.Physical_Only__c;
            
            if(countryLanguagePrefered != null && countryLanguagePrefered.containsKey(preferedLanguage.Country__c)){
                countryLanguagePrefered.get(preferedLanguage.Country__c).add(langLevel);
            }
            else{
                countryLanguagePrefered.put(preferedLanguage.Country__c, new list<langPriority>{langLevel});
            }
        }
        /** Ended--Map for country, and language preference **/
        
        //Start : Part of clientList method - Need to move this block of code in another method        
        recordsCreated= new list<Commercial_Avail__c>();
        
        for(string titleId : lstTitleIds){
            
            //Create release plans here as like Client List method
            set<availableLangType> titleAvailLangLst = new set<availableLangType>();
            set<string> titleFormatSet= new set<string>();
            titleAvailLangLst = titleId_availLangTypeSetMap.get(titleId);
            
            set<string>titleAvailLang =new set<string>();
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
            
            integer countOfPreferedLang=0;
            integer countOfPriorityLang2=0;
            integer countOfPriorityLang3=0;
            
            Set<string> setTitleFormat = new Set<string>();
            list<String> lstTitleFormat = new list<String>();
            
            if(mapDPTitle.get(titleId).Formats__c != null){
                lstTitleFormat = (mapDPTitle.get(titleId).Formats__c).split(';');
                setTitleFormat.addAll(lstTitleFormat);
            }
            
            for(string countryId : countryMap.keySet()){
                integer countPreferedLangForCountry= 0;
                set<string> countryChannelSet= new set<string>();
                list<langPriority> countryPreferedLangLst = new list<langPriority>();
                countryPreferedLangLst = countryLanguagePrefered.get(countryId);
                
                countOfPreferedLang = 0;
                countOfPriorityLang2 = 0;
                countOfPriorityLang3 = 0;
                
                if(countryChannelAvailable.get(countryId)!=null){
                    countryChannelSet = countryChannelAvailable.get(countryId);
                }
                if(!countryChannelSet.isEmpty() ){
                    if(countryPreferedLangLst!=null){
                        Integer idx = 0;// CRRt Phase 7: for getting preference language level
                        for(langPriority objLangPriority:countryPreferedLangLst){//START: Language Priority FOR LOOp
                            //Logic added on 4/25/2017
                            countPreferedLangForCountry++;
                            if(countPreferedLangForCountry > 1 && englishOnlyChk){
                                break;
                            }
                          //End of Logic
                            idx++;
                            //pasting code here : Start
                            for(string countryChannelRec:countryChannelSet){
                                //for(string selectedformat:titleFormatSet){
                                for(string selectedformat:selectedTitleFormatSet){
                                    if((countryChannelRec == 'EST' && (selectedformat == 'VR'|| selectedformat == 'HD+DVD' || selectedformat == 'HD+BD')) || selectedformat != 'VR'|| selectedformat != 'HD+DVD' || selectedformat != 'HD+BD'){
                                        // as per CRRT phase2 requirement
                                        if((mapDPTitle.get(titleId).Digital_Planning__c == 'Yes' && (selectedformat == 'SD' ||selectedformat == 'HD' || selectedformat == '3DHD' || selectedformat == '4K UHD' || selectedformat == 'VR' || selectedformat == 'HD+DVD' || selectedformat == 'HD+BD') && countryChannelRec != 'Physical') 
                                           || (mapDPTitle.get(titleId).Physical_Planning__c == 'Yes' && (selectedformat == 'BD' ||selectedformat == 'DVD' || selectedformat == '3DBD' || selectedformat == '4KBD') && countryChannelRec == 'Physical'))
                                        {  
                                            system.debug('****setTitleFormat:'+setTitleFormat+'*****selectedformat:'+selectedformat);
                                            if(setTitleFormat.size() > 0 && setTitleFormat.contains(selectedformat)){
                                                Boolean isClearAvail = false;
                                                /*---- Start : English Only Logic ----*/
                                                system.debug('^^^^^'+ englishOnlyChk +'^^^^^'+ objLangPriority.priority +'^^^^^'+objLangPriority.isPhysical+'^^^^^'+countryChannelRec);
                                                 system.debug('&&&titleAvailLangLst:'+titleAvailLangLst);
                                                if(englishOnlyChk || (objLangPriority.priority =='0' && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical'))){     
                                                    //if(objLangPriority.preferedLang == objEngLang.Id){    //Commented for SINC0906572 
                                                        //SINC0906572  CRRT ReleasePlan bug Fix for  april go live.
                                                        // Condition for to don't create Release Plan for english if Language Pref is Physical only
                                                        //if((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical'){
                                                            set<string> langTypes= new set<string>();
                                                             
                                                            for(availableLangType titleLangList:titleAvailLangLst){
                                                                system.debug('####titleLangList.availableLanguage:'+titleLangList.availableLanguage+'#####bjLangPriority.preferedLang:'+objLangPriority.preferedLang+'####titleLangList.langType:'+titleLangList.langType  +'@@@@@@'+ objEngLang.Id);
                                                                if(((englishOnlyChk && titleLangList.availableLanguage == objEngLang.Id) || (!englishOnlyChk && titleLangList.availableLanguage == objLangPriority.preferedLang)) && titleLangList.langType != null){ //CH01: && condition added //CH02 : Changed for SINC0906572
                                                                    langTypes.add(titleLangList.langType);
                                                                }
                                                            }
                                                        system.debug('####channelGridList:'+channelGridList + '@@@@@' + countryChannelRec);
                                                            for(WB_CreateCommercialAvail_Controller.channelWrapper objChannelGrid :channelGridList) {
                                                                
                                                                if(countryChannelRec==objChannelGrid.countryChannel) {
                                                                    Boolean langTypeFlag = false;
                                                                    
                                                                    for(string availLangTypes : langTypes){//ER-359 : Added new for loop
                                                                        if(langTypeFlag == false)
                                                                        {
                                                                            Commercial_Avail__c record=new Commercial_Avail__c();
                                                                            record.Country_Lookup__c= countryId;
                                                                            record.Format__c=selectedformat;
                                                                            record.Title__c= titleId;
                                                                            //record.language_type__c= availLangTypes;
                                                                            // CH01- Start - Check types available in set of LangTypes for the selected title.
                                                                            system.debug('*******langTypes:'+langTypes+'size:'+langTypes.size());
                                                                            if(langTypes.size()==0)
                                                                                record.language_type__c = null;
                                                                            else if(langTypes.size()==1){
                                                                                //CRRT Phase7: Added Provisional language type
                                                                                if(langTypes.contains('Provisional') && !provisionalLang)
                                                                                    isClearAvail = true;
                                                                                else{
                                                                                    //CRRT Phase7: Added Provisional language type
                                                                                    isClearAvail = false;
                                                                                    if(langTypes.contains('Provisional') && provisionalLang)
                                                                                        record.language_type__c = 'Provisional';
                                                                                    else
                                                                                        record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                }
                                                                            }
                                                                            /*
                                                                                else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                record.language_type__c= 'Sub & Audio';
                                                                                */
                                                                                //CRRT Phase7: Added Provisional language type
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
                                                                                        else if(langTypes.contains('Provisional') && (langTypes.contains('Audio') || langTypes.contains('Sub')))//CRRT Phase7: Added Provisional language type
                                                                                            record.language_type__c = langTypes.contains('Audio') ? 'Audio' : 'Sub';
                                                                                        else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                            record.language_type__c= 'Sub & Audio';
                                                                                    }
                                                                                        
                                                                                    langTypeFlag = true;
                                                                                }
                                                                            }
                                                                            // CH01- End
                                                                            if(!isClearAvail){// CRRT Phase7: Don't create release plan if language english is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                                record.Languages__c= englishOnlyChk ? objEngLang.Id : objLangPriority.preferedLang; //CH02 : Changed for SINC0906572
                                                                                record.channel__c=countryChannelRec;
                                                                                //system.assert(false,objChannelGrid);
                                                                                if(objChannelGrid.additionalInfo.Status__c=='Draft'|| objChannelGrid.additionalInfo.Status__c=='Open'){
                                                                                    if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null){
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            record.Start_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                            record.Start_Date__c=System.Today();
                                                                                        }
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c= expirationDateTitleMap.get(titleId);
                                                                                        }else
                                                                                            record.Rights_End__c= date.newInstance(2049, 12, 31);
                                                                                            
                                                                                        record.End_Date__c=record.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    } 
                                                                                    else if(objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null && objChannelGrid.additionalInfo.Start_Date__c!=null && objChannelGrid.additionalInfo.End_Date__c!=null){
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else 
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                        
                                                                                        date myDate = date.newInstance(2049, 12, 31);
                                                                                        String dayString = myDate.format();
                                                                                        
                                                                                        record.Rights_End__c = (expirationDateTitleMap.get(titleId)!=null) ? expirationDateTitleMap.get(titleId) : date.parse(dayString);
                                                                                        
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    }
                                                                                    /*Added for SINC0466215*/                     
                                                                                    else if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c !=null && objChannelGrid.additionalInfo.Rights_End__c ==null){
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c= expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.newInstance(2049, 12, 31);
                                                                                            
                                                                                        record.End_Date__c=record.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                        /*Added for SINC0466215*/                     
                                                                                        
                                                                                    } 
                                                                                    else if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c !=null){
                                                                                            record.Rights_End__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                            record.End_Date__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                            
                                                                                            if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                                record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            } else {
                                                                                                record.Exclusive_Date__c=System.Today();
                                                                                            }
                                                                                            record.Start_Date__c=record.Exclusive_Date__c;
                                                                                            record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                        }
                                                                                    else if(objChannelGrid.additionalInfo.Exclusive_Date__c !=null && objChannelGrid.additionalInfo.Rights_End__c !=null && objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null){
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.End_Date__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                        record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    }
                                                                                    else {
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                        record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    }
                                                                                }
                                                                                else if(objChannelGrid.additionalInfo.Status__c!=null && objChannelGrid.additionalInfo.Status__c!='Not Releasing' ){
                                                                                    if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null){
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            record.Start_Date__c =firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                            record.Start_Date__c =System.Today();
                                                                                        }
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c=date.parse('12/31/2049'); 
                                                                                            
                                                                                        record.End_Date__c= record.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    } 
                                                                                    else if(objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null && objChannelGrid.additionalInfo.Start_Date__c!=null && objChannelGrid.additionalInfo.End_Date__c!=null){
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                       
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse('12/31/2049');
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    } 
                                                                                    
                                                                                    else if(objChannelGrid.additionalInfo.Exclusive_Date__c !=null && objChannelGrid.additionalInfo.Rights_End__c !=null && objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null){
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.End_Date__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                        record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    }
                                                                                    else {
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                        record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    }
                                                                                }
                                                                                else if(objChannelGrid.additionalInfo.Status__c=='Not Releasing'){
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                    record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
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
                                                                                rpExceptionRec.Language__c=englishOnlyChk ? objEngLang.Name : objLangPriority.preferedLangName;
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
                                                        //}
                                                    //}
                                                }
                                                /*---- End : English Only Logic ----*/
                                                if(!englishOnlyChk && titleAvailLang.contains(objLangPriority.preferedLang)){//ER-359 - Added condition !englishOnlyChk &&
                                                    if(objLangPriority.priority=='1' && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical')){
                                                        set<string> langTypes= new set<string>();
                                                        
                                                        for(availableLangType titleLangList:titleAvailLangLst){
                                                            if(titleLangList.availableLanguage==objLangPriority.preferedLang&& titleLangList.langType != null){ //CH01: && condition added
                                                                langTypes.add(titleLangList.langType);
                                                            }
                                                        }
                                                        
                                                        for(WB_CreateCommercialAvail_Controller.channelWrapper objChannelGrid :channelGridList) {
                                                            
                                                            if(countryChannelRec==objChannelGrid.countryChannel) {
                                                                
                                                                Boolean langTypeFlag = false;
                                                                for(string availLangTypes : langTypes){//ER-359 : Added new for loop
                                                                    if(langTypeFlag == false)
                                                                    {
                                                                        Commercial_Avail__c record=new Commercial_Avail__c();
                                                                        record.Country_Lookup__c= countryId;
                                                                        record.Format__c=selectedformat;
                                                                        record.Title__c= titleId;
                                                                        //record.language_type__c= availLangTypes;
                                                                        if(langTypes.size()==0)
                                                                            record.language_type__c= null;
                                                                        else if(langTypes.size()==1){
                                                                            //CRRT Phase7: Added Provisional language type
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
                                                                        /*
                                                                            else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                            record.language_type__c= 'Sub & Audio';
                                                                            */
                                                                            //CRRT Phase7: Added Provisional language type
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
                                                                        
                                                                        if(!isClearAvail){// CRRT Phase7: Don't create release plan if preferenece language at level 1 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                            record.Languages__c= objLangPriority.preferedLang;
                                                                            record.channel__c=countryChannelRec;
                                                                            
                                                                            if(objChannelGrid.additionalInfo.Status__c=='Draft'|| objChannelGrid.additionalInfo.Status__c=='Open'){
                                                                                if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null){
                                                                                    if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                        record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        record.Start_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                    }
                                                                                    else {
                                                                                        record.Exclusive_Date__c=System.Today();
                                                                                        record.Start_Date__c=System.Today();
                                                                                    }
                                                                                    if(expirationDateTitleMap.get(titleId)!=null){
                                                                                        record.Rights_End__c= expirationDateTitleMap.get(titleId);
                                                                                    }
                                                                                    else
                                                                                        record.Rights_End__c= date.newInstance(2049, 12, 31);
                                                                                        
                                                                                    record.End_Date__c=record.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
                                                                                else if(objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null && objChannelGrid.additionalInfo.Start_Date__c!=null && objChannelGrid.additionalInfo.End_Date__c!=null){
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                    
                                                                                    if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                        record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                    }
                                                                                    else 
                                                                                        record.Exclusive_Date__c=System.Today();
                                                                                    
                                                                                    date myDate = date.newInstance(2049, 12, 31);
                                                                                    String dayString = myDate.format();
                                                                                    
                                                                                    record.Rights_End__c = (expirationDateTitleMap.get(titleId)!=null) ? expirationDateTitleMap.get(titleId) : date.parse(dayString);
                                                                                    
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                    /*Added for SINC0466215*/                     
                                                                                    
                                                                                } 
                                                                                else if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c !=null && objChannelGrid.additionalInfo.Rights_End__c ==null){
                                                                                        record.Start_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                        
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c= expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.newInstance(2049, 12, 31);
                                                                                            
                                                                                        record.End_Date__c=record.Rights_End__c;
                                                                                        record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                        /*Added for SINC0466215*/                     
                                                                                    
                                                                                } 
                                                                                else if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c !=null){
                                                                                    record.Rights_End__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    
                                                                                    if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                        record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                    } 
                                                                                    else {
                                                                                        record.Exclusive_Date__c=System.Today();
                                                                                    }
                                                                                    
                                                                                    record.Start_Date__c=record.Exclusive_Date__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
                                                                                else if(objChannelGrid.additionalInfo.Exclusive_Date__c !=null && objChannelGrid.additionalInfo.Rights_End__c !=null && objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null){
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
                                                                                else {
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                    record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
                                                                            }
                                                                            else if(objChannelGrid.additionalInfo.Status__c!=null && objChannelGrid.additionalInfo.Status__c!='Not Releasing' ){
                                                                                if(objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null && objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null){
                                                                                    if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                        record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        record.Start_Date__c =firstAvalTitleDateMap.get(titleId);
                                                                                    }
                                                                                    else {
                                                                                        record.Exclusive_Date__c=System.Today();
                                                                                        
                                                                                        record.Start_Date__c =System.Today();
                                                                                    }
                                                                                    if(expirationDateTitleMap.get(titleId)!=null){
                                                                                        record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                    }
                                                                                    else
                                                                                        record.Rights_End__c=date.parse('12/31/2049'); 
                                                                                    
                                                                                    record.End_Date__c= record.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                } 
                                                                                else if(objChannelGrid.additionalInfo.Exclusive_Date__c ==null && objChannelGrid.additionalInfo.Rights_End__c ==null && objChannelGrid.additionalInfo.Start_Date__c!=null && objChannelGrid.additionalInfo.End_Date__c!=null){
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                    
                                                                                    if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                        record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                    }
                                                                                    else
                                                                                        record.Exclusive_Date__c=System.Today();
                                                                                    if(expirationDateTitleMap.get(titleId)!=null){
                                                                                        record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                    }
                                                                                    else
                                                                                        record.Rights_End__c= date.parse('12/31/2049');
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                } 
                                                                                else if(objChannelGrid.additionalInfo.Exclusive_Date__c !=null && objChannelGrid.additionalInfo.Rights_End__c !=null && objChannelGrid.additionalInfo.Start_Date__c==null && objChannelGrid.additionalInfo.End_Date__c==null){
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
                                                                                else {
                                                                                    record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                    record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                    record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                    record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                    record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                                }
                                                                            }
                                                                            else if(objChannelGrid.additionalInfo.Status__c=='Not Releasing'){
                                                                                record.Start_Date__c=objChannelGrid.additionalInfo.Start_Date__c;
                                                                                record.End_Date__c=objChannelGrid.additionalInfo.End_Date__c;
                                                                                record.Exclusive_Date__c=objChannelGrid.additionalInfo.Exclusive_Date__c;
                                                                                record.Rights_End__c= objChannelGrid.additionalInfo.Rights_End__c;
                                                                                record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                            }
                                                                            record.reason_code__c=objChannelGrid.additionalInfo.reason_code__c;
                                                                            record.Comments__c=objChannelGrid.additionalInfo.Comments__c;
                                                                            record.status__c=objChannelGrid.additionalInfo.Status__c;
                                                                            recordsCreated.add(record);
                                                                            
                                                                            countOfPreferedLang=countOfPreferedLang+1;
                                                                        }
                                                                         // CRRT Phase 7: Added Provisional type exception, if preference language at level 1 is provisional
                                                                        else if(isClearAvail && provisionalLang && countryPreferedLangLst.size() == 1){
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
                                                    if(((objLangPriority.priority=='2' && countOfPreferedLang==0 )|| (isClearAvail && provisionalLang)) && ((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical')){
                                                        
                                                        set<string> langTypes= new set<string>();
                                                        
                                                        for(availableLangType titleLangList : titleAvailLangLst){
                                                            if(!isClearAvail && titleLangList.availableLanguage==objLangPriority.preferedLang && titleLangList.langType != null){ //CH01: && condition added
                                                                langTypes.add(titleLangList.langType);
                                                            }
                                                            // CRRT Phase7: create release plan for preferenece language at level 2 if labguage at level 1 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                            else if(isClearAvail && titleLangList.availableLanguage == countryPreferedLangLst[idx].preferedLang && titleLangList.langType != null){ 
                                                                langTypes.add(titleLangList.langType);
                                                            }
                                                        }
                                                        
                                                        for(WB_CreateCommercialAvail_Controller.channelWrapper channelLst:channelGridList){
                                                            if(countryChannelRec==channelLst.countryChannel){ 
                                                                if(!(channelLst.additionalInfo.Status__c=='Not Releasing' || channelLst.additionalInfo.Status__c=='Moratorium')){
                                                                    Boolean langTypeFlag = false;
                                                                    
                                                                    for(string availLangTypes : langTypes){//ER-359 : Added new for loop
                                                                        if(langTypeFlag == false)
                                                                        {
                                                                            Commercial_Avail__c record=new Commercial_Avail__c();
                                                                            record.Country_Lookup__c= countryId;
                                                                            record.Format__c=selectedformat;
                                                                            record.Title__c= titleId;
                                                                            //record.language_type__c= availLangTypes;
                                                                            // CH01- Start - Check types available in set of LangTypes for the selected title.
                                                                           
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
                                                                            /*
                                                                            else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                            record.language_type__c= 'Sub & Audio';
                                                                            */
                                                                            //CRRT Phase7: Added Provisional language type
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
                                                                           
                                                                            // CH01 - End
                                                                            if(!isClearAvail){// CRRT Phase7: Don't create release plan if preferenece language at level 2 is Provisional and "Include Provisional Languages" is not checked on Release plan wizard
                                                                                record.Languages__c= (objLangPriority.priority == '1') ? countryPreferedLangLst[idx].preferedLang : objLangPriority.preferedLang;
                                                                                record.channel__c=countryChannelRec;
                                                                                
                                                                                if(channelLst.additionalInfo.Status__c=='Draft'|| channelLst.additionalInfo.Status__c=='Open'){
                                                                                    if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null){
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            //ER-000053 - Added by shalini
                                                                                            record.Start_Date__c =firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                            record.Start_Date__c =System.Today();
                                                                                        }
                                                                                        
                                                                                        date myDate = date.newInstance(2049, 12, 31);
                                                                                        String dayString = myDate.format();
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse(dayString);
                                                                                            
                                                                                        //ER-000053 - Added by shalini
                                                                                        record.End_Date__c= record.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null && channelLst.additionalInfo.Start_Date__c!=null && channelLst.additionalInfo.End_Date__c!=null){
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                        
                                                                                        date myDate = date.newInstance(2049, 12, 31);
                                                                                        String dayString = myDate.format();
                                                                                        
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse (dayString);
                                                                                            
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                        /*Added for SINC0466215*/                       
                                                                                        
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c !=null && channelLst.additionalInfo.Rights_End__c ==null){
                                                                                            record.Start_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                            record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                            
                                                                                            if(expirationDateTitleMap.get(titleId)!=null){
                                                                                                record.Rights_End__c= expirationDateTitleMap.get(titleId);
                                                                                            }
                                                                                            else
                                                                                                record.Rights_End__c= date.newInstance(2049, 12, 31);
                                                                                                
                                                                                            record.End_Date__c=record.Rights_End__c;
                                                                                            record.status__c=channelLst.additionalInfo.Status__c;
                                                                                            /*Added for SINC0466215*/                     
                                                                                        
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c !=null){
                                                                                        record.Rights_End__c=channelLst.additionalInfo.Rights_End__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.Rights_End__c;
                                                                                       
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        } else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                        }
                                                                                        record.Start_Date__c=record.Exclusive_Date__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    }
                                                                                    else {
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= channelLst.additionalInfo.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                        }
                                                                                }
                                                                                else if(channelLst.additionalInfo.Status__c!=null && channelLst.additionalInfo.Status__c!='Not Releasing' ){
                                                                                    if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null){
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            //ER-000053 added by shalini
                                                                                            record.Start_Date__c= firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                            //ER-000053 added by shalini
                                                                                            record.Start_Date__c= System.Today();
                                                                                        }
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }else
                                                                                            record.Rights_End__c=date.parse('12/31/2049');
                                                                                        //ER-000053 added by shalini
                                                                                        record.End_Date__c =record.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null && channelLst.additionalInfo.Start_Date__c!=null && channelLst.additionalInfo.End_Date__c!=null){
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else record.Exclusive_Date__c=System.Today();
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse('12/31/2049');
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    }
                                                                                    else {
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= channelLst.additionalInfo.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    }
                                                                                }
                                                                                record.reason_code__c=channelLst.additionalInfo.reason_code__c;
                                                                                record.Comments__c=channelLst.additionalInfo.Comments__c;
                                                                                record.status__c=channelLst.additionalInfo.Status__c;
                                                                                recordsCreated.add(record);
                                                                                
                                                                                countOfPriorityLang2=countOfPriorityLang2+1;
                                                                            }
                                                                            // CRRT Phase 7: Added Provisional type exception, if preference language at level 2 is provisional
                                                                            else if(isClearAvail && provisionalLang && ((objLangPriority.priority=='1' && countryPreferedLangLst.size() == 2) || (objLangPriority.priority=='2' && countryPreferedLangLst.size() == 1))){
                                                                                Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                                                                                countExcpetionRec++;
                                                                                rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                                                                rpExceptionRec.Title__c = mapDPTitle.get(titleId).Name;
                                                                                rpExceptionRec.Country__c=objLangPriority.preferedCntyName;
                                                                                rpExceptionRec.Language__c= (objLangPriority.priority == '1') ? countryPreferedLangLst[idx].preferedLangName : objLangPriority.preferedLangName;
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
                                                            else if(isClearAvail && titleLangList.availableLanguage == countryPreferedLangLst[idx].preferedLang && titleLangList.langType != null){ 
                                                                langTypes.add(titleLangList.langType);
                                                            }
                                                        }
                                                        
                                                        for(WB_CreateCommercialAvail_Controller.channelWrapper channelLst:channelGridList){
                                                            if(countryChannelRec==channelLst.countryChannel){ 
                                                                if(!(channelLst.additionalInfo.Status__c=='Not Releasing' || channelLst.additionalInfo.Status__c=='Moratorium')){
                                                                    Boolean langTypeFlag = false;
                                                                    
                                                                    for(string availLangTypes : langTypes){//ER-359 : Added new for loop
                                                                        if(langTypeFlag == false)
                                                                        {
                                                                            Commercial_Avail__c record=new Commercial_Avail__c();
                                                                            record.Country_Lookup__c= countryId;
                                                                            record.Format__c=selectedformat;
                                                                            record.Title__c= titleId;
                                                                            //record.language_type__c= availLangTypes;
                                                                            // CH01- Start - Check types available in set of LangTypes for the selected title.
                                                                           
                                                                            // CH01 - Start: - Check types available in set of LangTypes for the selected title.
                                                                            //CRRT Phase7: Added Provisional language type
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
                                                                            /*
                                                                                else if(langTypes.contains('Audio') && langTypes.contains('Sub'))
                                                                                record.language_type__c= 'Sub & Audio';
                                                                                */
                                                                                //CRRT Phase7: Added Provisional language type
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
                                                                                record.Languages__c= (objLangPriority.priority != '3') ? countryPreferedLangLst[idx].preferedLang : objLangPriority.preferedLang;
                                                                                record.channel__c=countryChannelRec;
                                                                                
                                                                                if(channelLst.additionalInfo.Status__c=='Draft'|| channelLst.additionalInfo.Status__c=='Open'){
                                                                                    if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null){
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            //ER-000053 - Added by shalini
                                                                                            record.Start_Date__c =firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                            record.Start_Date__c =System.Today();
                                                                                        }
                                                                                        
                                                                                        date myDate = date.newInstance(2049, 12, 31);
                                                                                        String dayString = myDate.format();
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse(dayString);
                                                                                            
                                                                                        //ER-000053 - Added by shalini
                                                                                        record.End_Date__c= record.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null && channelLst.additionalInfo.Start_Date__c!=null && channelLst.additionalInfo.End_Date__c!=null){
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                        
                                                                                        date myDate = date.newInstance(2049, 12, 31);
                                                                                        String dayString = myDate.format();
                                                                                        
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse (dayString);
                                                                                            
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                        /*Added for SINC0466215*/                       
                                                                                        
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c !=null && channelLst.additionalInfo.Rights_End__c ==null){
                                                                                            record.Start_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                            record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                            
                                                                                            if(expirationDateTitleMap.get(titleId)!=null){
                                                                                                record.Rights_End__c= expirationDateTitleMap.get(titleId);
                                                                                            }
                                                                                            else
                                                                                                record.Rights_End__c= date.newInstance(2049, 12, 31);
                                                                                                
                                                                                            record.End_Date__c=record.Rights_End__c;
                                                                                            record.status__c=channelLst.additionalInfo.Status__c;
                                                                                            /*Added for SINC0466215*/                     
                                                                                        
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c !=null){
                                                                                        record.Rights_End__c=channelLst.additionalInfo.Rights_End__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.Rights_End__c;
                                                                                       
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        } else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                        }
                                                                                        record.Start_Date__c=record.Exclusive_Date__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    }
                                                                                    else {
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= channelLst.additionalInfo.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                        }
                                                                                }
                                                                                else if(channelLst.additionalInfo.Status__c!=null && channelLst.additionalInfo.Status__c!='Not Releasing' ){
                                                                                    if(channelLst.additionalInfo.Start_Date__c==null && channelLst.additionalInfo.End_Date__c==null && channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null){
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                            //ER-000053 added by shalini
                                                                                            record.Start_Date__c= firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else {
                                                                                            record.Exclusive_Date__c=System.Today();
                                                                                            //ER-000053 added by shalini
                                                                                            record.Start_Date__c= System.Today();
                                                                                        }
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }else
                                                                                            record.Rights_End__c=date.parse('12/31/2049');
                                                                                        //ER-000053 added by shalini
                                                                                        record.End_Date__c =record.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    } 
                                                                                    else if(channelLst.additionalInfo.Exclusive_Date__c ==null && channelLst.additionalInfo.Rights_End__c ==null && channelLst.additionalInfo.Start_Date__c!=null && channelLst.additionalInfo.End_Date__c!=null){
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        
                                                                                        if(firstAvalTitleDateMap.get(titleId) !=null){
                                                                                            record.Exclusive_Date__c=firstAvalTitleDateMap.get(titleId);
                                                                                        }
                                                                                        else record.Exclusive_Date__c=System.Today();
                                                                                        //ER-000089 - shalini
                                                                                        if(expirationDateTitleMap.get(titleId)!=null){
                                                                                            record.Rights_End__c=expirationDateTitleMap.get(titleId);
                                                                                        }
                                                                                        else
                                                                                            record.Rights_End__c= date.parse('12/31/2049');
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    }
                                                                                    else {
                                                                                        record.Start_Date__c=channelLst.additionalInfo.Start_Date__c;
                                                                                        record.End_Date__c=channelLst.additionalInfo.End_Date__c;
                                                                                        record.Exclusive_Date__c=channelLst.additionalInfo.Exclusive_Date__c;
                                                                                        record.Rights_End__c= channelLst.additionalInfo.Rights_End__c;
                                                                                        record.status__c=channelLst.additionalInfo.Status__c;
                                                                                    }
                                                                                }
                                                                                record.reason_code__c=channelLst.additionalInfo.reason_code__c;
                                                                                record.Comments__c=channelLst.additionalInfo.Comments__c;
                                                                                record.status__c=channelLst.additionalInfo.Status__c;
                                                                                recordsCreated.add(record);
                                                                                
                                                                                countOfPriorityLang3=countOfPriorityLang3+1;
                                                                            }
                                                                            // CRRT Phase 7: Added Provisional type exception, if preference language at level 3 is provisional
                                                                            else if(isClearAvail && provisionalLang && ((objLangPriority.priority=='1' && countryPreferedLangLst.size() == 3) || (objLangPriority.priority=='2' && countryPreferedLangLst.size() == 2) || (objLangPriority.priority=='3' && countryPreferedLangLst.size() == 1))){// CRRT Phase 7: Added Provisional type exception
                                                                                Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                                                                                countExcpetionRec++;
                                                                                rpExceptionRec.name=userDetail.id+ string.valueof(countExcpetionRec);
                                                                                rpExceptionRec.Title__c = mapDPTitle.get(titleId).Name;
                                                                                rpExceptionRec.Country__c=objLangPriority.preferedCntyName;
                                                                                rpExceptionRec.Language__c=(objLangPriority.priority !='3') ? countryPreferedLangLst[idx].preferedLangName : objLangPriority.preferedLangName;
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
                                                else {
                                                    if((!objLangPriority.isPhysical && countryChannelRec != 'Physical') || countryChannelRec == 'Physical'){
                                                        set<string> langDiff= new set<string>();
                                                        for(WB_CreateCommercialAvail_Controller.channelWrapper channelLst :channelGridList) {
                                                            if(countryChannelRec==channelLst.countryChannel){
                                                                if(!(channelLst.additionalInfo.Status__c=='Not Releasing' || channelLst.additionalInfo.Status__c=='Moratorium')){
                                                                } 
                                                                else {
                                                                    Commercial_Avail__c record=new Commercial_Avail__c();
                                                                    record.Country_Lookup__c= countryId;
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
                            //pasting code here : End
                        }
                    }
                }
            }
        }
        //End   : Part of clientList method
        list<Commercial_Avail__c> lstFinalCommAvail = new list<Commercial_Avail__c>();
        Map<Id,Language__c> languageIdMap = new Map<Id,Language__c>([SELECT id,name, Language_Code_2__c FROM Language__c]);
        
         
        //Added query on Title BOM object to find out the BOM records under title
        //ER-000959 : Enable VBOM rights record type
        Set<Id> setTleWithBOM = new Set<Id>();
        for(Title_BOM__c bom : [SELECT Id, Title__c FROM Title_BOM__c WHERE Title__c IN:lstTitleIds])
            setTleWithBOM.add(bom.Title__c);
        
        //As per CRRT Phase 2 requirment By Purushottam (CTS)
        // Release plan creation on the basis condition based on "Use Rights To Create Release Plans" check field in Release Plan wizard.
        // Start     
        
        if(recordsCreated !=null && recordsCreated.size() > 0 && isRightToCreateRPChk == True){                    
            List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
            Map<String,Rights__c> mapVBOMRights = new Map<String,Rights__c>();
            Map<String,Rights__c> mapMPMRights = new Map<String,Rights__c>();
            
            if(lstRights != null && lstRights.size() > 0){
                for(Rights__c ryt: lstRights){
                    if(ryt.RecordType.Name == 'VBOM')
                        mapVBOMRights.put(ryt.Video_Version__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);
                    else
                        mapMPMRights.put(ryt.MPM__c+'_'+ryt.Rights_Group__c+'_'+ryt.Channel__c,ryt);
                }
            }
            
            for(Commercial_Avail__c commAvl : recordsCreated)
            { 
                countExcpetionRec++;
                Release_Plan_Exceptions__c rpExpnRec = new Release_Plan_Exceptions__c();
                rpExpnRec.name = userDetail.id + string.valueof(countExcpetionRec);
                rpExpnRec.Title__c = titleList.get(commAvl.Title__c).Name;
                rpExpnRec.Video_Version__c = titleList.get(commAvl.Title__c).Video_Version__c;
                rpExpnRec.Country__c = countryMap.get(commAvl.Country_Lookup__c).Name;                        
                rpExpnRec.User_Detail__c = userDetail.id;
                
                String strVV = titleList.get(commAvl.Title__c).Video_Version__c;
                String strMPM = titleList.get(commAvl.Title__c).MPM__c;
                Date fstAvailDt = titleList.get(commAvl.Title__c).First_Available_Date__c;
                //Country code
                String strCntyCd = countryMap.containsKey(commAvl.Country_Lookup__c) ? countryMap.get(commAvl.Country_Lookup__c).Country_Code2__c : '';    
                String strLangCd = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Language_Code_2__c : '';
                String strLangName = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Name : '';
                
               if(mapMPMRights != null && mapMPMRights.size() > 0){ 
                    String strRytGrp = mapRightsGrp.containsKey(strLangCd+'_'+strCntyCd) ? mapRightsGrp.get(strLangCd+'_'+strCntyCd) : ''; 
                    Rights__c ryt;
                    
                    if(setTleWithBOM.size() > 0 && setTleWithBOM.contains(commAvl.Title__c) && mapVBOMRights.size() > 0 && mapVBOMRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c))
                        ryt = mapVBOMRights.get(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c);
                    if(ryt == null && mapMPMRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c))
                        ryt = mapMPMRights.get(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c); 
                        
                    if(ryt != null){
                        
                        //if(ConfirmedPartialAllow == 'NR' || ConfirmedPartialAllow == 'Yes' || (ryt.Status__c != 'TBA' && ryt.Status__c != 'Confirmed Partial' && ryt.Status__c != 'Tentative Partial' && ryt.Status__c != 'Tentative' && ConfirmedPartialAllow == 'No')){
                            
                        // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                        if(ConfirmedPartialAllow == 'NR' || ConfirmedPartialAllow == 'Yes' || (ryt.Status__c != 'TBA' && ryt.Status__c != 'Confirmed Partial' && ryt.Status__c != 'Tentative' && ryt.Status__c != 'Tentative Partial' &&
                         ConfirmedPartialAllow == 'No' && ryt.Status__c !='TBA Partial')){//Added 'TBA Partial' status
                                    
                            if(strMPM == ryt.MPM__c && commAvl.Channel__c == ryt.Channel__c && strRytGrp == ryt.Rights_Group__c){           
                                //If First avail date is not blank on title
                                if(fstAvailDt != null){    
                                    //Do not create a release plan if First Avail Date id greater than all the right window of matching rights record.
                                    if((fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null) || (ryt.Rights_End_5__c == null && fstAvailDt > ryt.Rights_End_4__c && ryt.Rights_End_4__c != null)  || (ryt.Rights_End_4__c == null && fstAvailDt > ryt.Rights_End_3__c && ryt.Rights_End_3__c != null) 
                                       || (ryt.Rights_End_3__c == null && fstAvailDt > ryt.Rights_End_2__c && ryt.Rights_End_2__c != null) || (ryt.Rights_End_2__c == null && fstAvailDt > ryt.Rights_End__c && ryt.Rights_End__c != null)){
                                           rpExpnRec.Language__c = strLangName;
                                           rpExpnRec.Channel__c = commAvl.Channel__c;
                                           rpExpnRec.Format__c = commAvl.Format__c;
                                           rpExpnRec.Reason__c = 'Release Plan was not created since First Available Date is greater than Rights End.';
                                           releasePlanExceptionList.add(rpExpnRec);
                                       }  
                                    // create release plan only when matching rights record status is Confirmed, Tentative, Confirmed Partial or TBA.
                                    else{
                                        //if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'TBA' || ryt.Status__c == 'Tentative Partial'){    //crrt phase 3 changes                               
                                        // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                        if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA' || ryt.Status__c == 'Confirmed TBA'
                                        || ryt.Status__c =='TBA Partial'){//Added 'TBA Partial' status
                                        
                                            if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null){
                                                Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                                commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                                commAvlNew.Format__c = commAvl.Format__c;
                                                commAvlNew.Title__c = commAvl.Title__c;
                                                commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                                commAvlNew.Languages__c = commAvl.Languages__c;
                                                commAvlNew.Channel__c = commAvl.Channel__c;
                                                commAvlNew.Comments__c = commAvl.Comments__c;
                                                commAvlNew.Rights_ID__c = ryt.Id;
                                                commAvlNew.Start_Date__c = null;
                                                commAvlNew.End_Date__c = null;
                                                //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                                // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                                commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                                ) ? 'Open' : 'Draft';
                                                commAvlNew.Reason_Code__c = null;                                           
                                                //Create a release plan when the First avail date falling between 1st right window and 1st rights window is not expired.
                                                if(fstAvailDt >= ryt.Rights_Start__c && fstAvailDt <= ryt.Rights_End__c && ryt.Rights_End__c >= System.Today()){
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : fstAvailDt;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);                                            }    
                                                //Create a release plan when the First avail < 1st right window and 1st rights window is not expired.
                                                else if(fstAvailDt < ryt.Rights_Start__c && ryt.Rights_End__c >= System.Today()){
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start__c;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }  
                                            } 
                                            if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null){
                                                Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                                commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                                commAvlNew.Format__c = commAvl.Format__c;
                                                commAvlNew.Title__c = commAvl.Title__c;
                                                commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                                commAvlNew.Languages__c = commAvl.Languages__c;
                                                commAvlNew.Channel__c = commAvl.Channel__c;
                                                commAvlNew.Comments__c = commAvl.Comments__c;
                                                commAvlNew.Rights_ID__c = ryt.Id;
                                                commAvlNew.Start_Date__c = null;
                                                commAvlNew.End_Date__c = null;
                                                //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                                // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                                commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                                ) ? 'Open' : 'Draft';
                                                commAvlNew.Reason_Code__c = null;
                                                //Create a release plan when the First avail date falling between 2nd right window and 2nd rights window is not expired.
                                                if(fstAvailDt >= ryt.Rights_Start_2__c && fstAvailDt <= ryt.Rights_End_2__c && ryt.Rights_End_2__c >= System.Today()){                                                                
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : fstAvailDt;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_2__c;    //Added 'TBA Partial' status                                                            
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                                //Create a release plan when the First avail < 2nd right window and 2nd rights window is not expired.
                                                else if(fstAvailDt < ryt.Rights_Start_2__c && ryt.Rights_End_2__c > System.Today()){
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_2__c;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_2__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                            } 
                                            if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null){
                                                Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                                commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                                commAvlNew.Format__c = commAvl.Format__c;
                                                commAvlNew.Title__c = commAvl.Title__c;
                                                commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                                commAvlNew.Languages__c = commAvl.Languages__c;
                                                commAvlNew.Channel__c = commAvl.Channel__c;
                                                commAvlNew.Comments__c = commAvl.Comments__c;
                                                commAvlNew.Rights_ID__c = ryt.Id;                                                            
                                                commAvlNew.Start_Date__c = null;
                                                commAvlNew.End_Date__c = null;
                                                //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                                // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                                commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                                ) ? 'Open' : 'Draft';
                                                            
                                                commAvlNew.Reason_Code__c = null;
                                                //Create a release plan when the First avail date falling between 3rd right window and 3rd rights window is not expired.
                                                if(fstAvailDt >= ryt.Rights_Start_3__c && fstAvailDt <= ryt.Rights_End_3__c && ryt.Rights_End_3__c >= System.Today()){                                                                
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : fstAvailDt;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_3__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                                //Create a release plan when the First avail < 3rd right window and 3rd rights window is not expired.
                                                else if(fstAvailDt < ryt.Rights_Start_3__c && ryt.Rights_End_3__c > System.Today()){
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_3__c;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_3__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                            } 
                                            if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null){
                                                Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                                commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                                commAvlNew.Format__c = commAvl.Format__c;
                                                commAvlNew.Title__c = commAvl.Title__c;
                                                commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                                commAvlNew.Languages__c = commAvl.Languages__c;
                                                commAvlNew.Channel__c = commAvl.Channel__c;
                                                commAvlNew.Comments__c = commAvl.Comments__c;
                                                commAvlNew.Rights_ID__c = ryt.Id;                                                            
                                                commAvlNew.Start_Date__c = null;
                                                commAvlNew.End_Date__c = null;
                                                //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                                // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                                commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                                ) ? 'Open' : 'Draft';
                                                commAvlNew.Reason_Code__c = null;
                                                //Create a release plan when the First avail date falling between 4th right window and 4th rights window is not expired.
                                                if(fstAvailDt >= ryt.Rights_Start_4__c && fstAvailDt <= ryt.Rights_End_4__c && ryt.Rights_End_4__c >= System.Today()){                                                                
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : fstAvailDt;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_4__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                                //Create a release plan when the First avail < 4th right window and 4th rights window is not expired.
                                                else if(fstAvailDt < ryt.Rights_Start_4__c && ryt.Rights_End_4__c > System.Today()){
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_4__c;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_4__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                            } 
                                            if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null){
                                                Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                                commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                                commAvlNew.Format__c = commAvl.Format__c;
                                                commAvlNew.Title__c = commAvl.Title__c;
                                                commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                                commAvlNew.Languages__c = commAvl.Languages__c;
                                                commAvlNew.Channel__c = commAvl.Channel__c;
                                                commAvlNew.Comments__c = commAvl.Comments__c;
                                                commAvlNew.Rights_ID__c = ryt.Id;                                                            
                                                commAvlNew.Start_Date__c = null;
                                                commAvlNew.End_Date__c = null;
                                                //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                                // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                                commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                                ) ? 'Open' : 'Draft';
                                                commAvlNew.Reason_Code__c = null;
                                                //Create a release plan when the First avail date falling between 5th right window and 5th rights window is not expired.
                                                if(fstAvailDt >= ryt.Rights_Start_5__c && fstAvailDt <= ryt.Rights_End_5__c && ryt.Rights_End_5__c >= System.Today()){                                                                
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : fstAvailDt;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_5__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }
                                                //Create a release plan when the First avail < 5th right window and 5th rights window is not expired.
                                                else if(fstAvailDt < ryt.Rights_Start_5__c && ryt.Rights_End_5__c > System.Today()){
                                                    commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_5__c;//Added 'TBA Partial' status
                                                    commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_5__c;//Added 'TBA Partial' status
                                                    lstCommAvail.add(commAvlNew);
                                                }                                                            
                                            }
                                            //Do not create release plan if no rights window.
                                            if(ryt.Rights_End__c == null){
                                                Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                                commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                                commAvlNew.Format__c = commAvl.Format__c;
                                                commAvlNew.Title__c = commAvl.Title__c;
                                                commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                                commAvlNew.Languages__c = commAvl.Languages__c;
                                                commAvlNew.Channel__c = commAvl.Channel__c;
                                                commAvlNew.Comments__c = commAvl.Comments__c;
                                                commAvlNew.Rights_ID__c = ryt.Id;                                                            
                                                commAvlNew.Start_Date__c = null;
                                                commAvlNew.End_Date__c = null;
                                                //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                                // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                                commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                                ) ? 'Open' : 'Draft';
                                                commAvlNew.Reason_Code__c = null;                                                          
                                                commAvlNew.Exclusive_Date__c =  null;
                                                commAvlNew.Rights_End__c =  null ;
                                                lstCommAvail.add(commAvlNew);                                                                 
                                            }     
                                        }
                                        //Do not create release plan if matching rights record status is Researching, No Rights or Expired.
                                        //if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){                                                                          
                                        // Added No Rights TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                        if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights' || ryt.RT_Lifecycle__c == 'No Rights TBA'){                                                    
                                            rpExpnRec.Language__c = strLangName;
                                            rpExpnRec.Channel__c = commAvl.Channel__c;
                                            rpExpnRec.Format__c = commAvl.Format__c;
                                            rpExpnRec.Reason__c = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights' || ryt.Status__c == 'No Rights TBA') ? 'Release plans are not created since rights status is No Right.' : 'Release Plan was not created since rights have expired.';//Added 'No Rights TBA' status  
                                            releasePlanExceptionList.add(rpExpnRec); 
                                        }
                                    }
                                }
                                //If First avail date is blank on title only when status is Confirmed, Tentative, Confirmed Partial or TBA.
                                else if(fstAvailDt == null){
                                    //if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial'  || ryt.Status__c == 'TBA' || ryt.Status__c == 'Tentative Partial'){ //CRRT Phase 3 changes
                                    // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                    if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA' ||
                                      ryt.Status__c =='TBA Partial' || ryt.Status__c == 'Confirmed TBA'){//Added 'TBA Partial' status
                                                
                                        if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null && ryt.Rights_End__c >= System.Today()){
                                            Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                            commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                            commAvlNew.Format__c = commAvl.Format__c;
                                            commAvlNew.Title__c = commAvl.Title__c;
                                            commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                            commAvlNew.Languages__c = commAvl.Languages__c;
                                            commAvlNew.Channel__c = commAvl.Channel__c;
                                            commAvlNew.Comments__c = commAvl.Comments__c;
                                            commAvlNew.Rights_ID__c = ryt.Id;
                                            commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start__c;//Added 'TBA Partial' status
                                            commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End__c;//Added 'TBA Partial' status
                                            commAvlNew.Start_Date__c = null;
                                            commAvlNew.End_Date__c = null;
                                            //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                            // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                            commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                            ) ? 'Open' : 'Draft';
                                            commAvlNew.Reason_Code__c = null;
                                            lstCommAvail.add(commAvlNew);
                                        } 
                                        if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null && ryt.Rights_End_2__c >= System.Today()){
                                            Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                            commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                            commAvlNew.Format__c = commAvl.Format__c;
                                            commAvlNew.Title__c = commAvl.Title__c;
                                            commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                            commAvlNew.Languages__c = commAvl.Languages__c;
                                            commAvlNew.Channel__c = commAvl.Channel__c;
                                            commAvlNew.Comments__c = commAvl.Comments__c;
                                            commAvlNew.Rights_ID__c = ryt.Id;
                                            commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_2__c;//Added 'TBA Partial' status
                                            commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_2__c;//Added 'TBA Partial' status
                                            commAvlNew.Start_Date__c = null;
                                            commAvlNew.End_Date__c = null;
                                            //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                            // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                            commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                            ) ? 'Open' : 'Draft';
                                            commAvlNew.Reason_Code__c = null;
                                            lstCommAvail.add(commAvlNew);
                                        } 
                                        if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null && ryt.Rights_End_3__c >= System.Today()){
                                            Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                            commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                            commAvlNew.Format__c = commAvl.Format__c;
                                            commAvlNew.Title__c = commAvl.Title__c;
                                            commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                            commAvlNew.Languages__c = commAvl.Languages__c;
                                            commAvlNew.Channel__c = commAvl.Channel__c;
                                            commAvlNew.Comments__c = commAvl.Comments__c;
                                            commAvlNew.Rights_ID__c = ryt.Id;
                                            commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_3__c;//Added 'TBA Partial' status
                                            commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_3__c;//Added 'TBA Partial' status
                                            commAvlNew.Start_Date__c = null;
                                            commAvlNew.End_Date__c = null;
                                            //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                            // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                            commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                            ) ? 'Open' : 'Draft';
                                            commAvlNew.Reason_Code__c = null;
                                            lstCommAvail.add(commAvlNew);
                                        } 
                                        if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null && ryt.Rights_End_4__c >= System.Today()){
                                            Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                            commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                            commAvlNew.Format__c = commAvl.Format__c;
                                            commAvlNew.Title__c = commAvl.Title__c;
                                            commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                            commAvlNew.Languages__c = commAvl.Languages__c;
                                            commAvlNew.Channel__c = commAvl.Channel__c;
                                            commAvlNew.Comments__c = commAvl.Comments__c;
                                            commAvlNew.Rights_ID__c = ryt.Id;
                                            commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_4__c;//Added 'TBA Partial' status
                                            commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_4__c;//Added 'TBA Partial' status
                                            commAvlNew.Start_Date__c = null;
                                            commAvlNew.End_Date__c = null;
                                            //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                            // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                            commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                            ) ? 'Open' : 'Draft';
                                            commAvlNew.Reason_Code__c = null;
                                            lstCommAvail.add(commAvlNew);
                                        } 
                                        if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null && ryt.Rights_End_5__c >= System.Today()){
                                            Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
                                            commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
                                            commAvlNew.Format__c = commAvl.Format__c;
                                            commAvlNew.Title__c = commAvl.Title__c;
                                            commAvlNew.Language_Type__c = commAvl.Language_Type__c;
                                            commAvlNew.Languages__c = commAvl.Languages__c;
                                            commAvlNew.Channel__c = commAvl.Channel__c;
                                            commAvlNew.Comments__c = commAvl.Comments__c;
                                            commAvlNew.Rights_ID__c = ryt.Id;
                                            commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_Start_5__c;//Added 'TBA Partial' status
                                            commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : ryt.Rights_End_5__c;//Added 'TBA Partial' status
                                            commAvlNew.Start_Date__c = null;
                                            commAvlNew.End_Date__c = null;
                                            //commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial') ? 'Open' : 'Draft';
                                            // Added Confirmed TBA, Tentative TBA, Confirmed Partial TBA and Tentative Partial TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                            commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                            ) ? 'Open' : 'Draft';
                                            commAvlNew.Reason_Code__c = null;
                                            lstCommAvail.add(commAvlNew);
                                        }     
                                    }
                                    //if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){
                                    // Added No Rights TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                    if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights' || ryt.RT_Lifecycle__c == 'No Rights TBA'){      
                                        rpExpnRec.Language__c = strLangName;
                                        rpExpnRec.Channel__c = commAvl.Channel__c;
                                        rpExpnRec.Format__c = commAvl.Format__c;
                                        //rpExpnRec.Reason__c = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights') ? 'Release plans are not created since rights status is No Right.' : 'Release Plan was not created since rights have expired.';
                                        // Added No Rights TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                                        rpExpnRec.Reason__c = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights' || ryt.RT_Lifecycle__c == 'No Rights TBA') ? 'Release plans are not created since rights status is No Right or No Rights TBA.' : 'Release Plan was not created since rights have expired.';
                                        releasePlanExceptionList.add(rpExpnRec);
                                    }
                                }  
                            } 
                        }
                        
                    } 
                    else{
                        //Do not create release plan if no right found.
                        rpExpnRec.Language__c = strLangName;
                        rpExpnRec.Format__c = commAvl.Format__c;
                        rpExpnRec.Channel__c = commAvl.Channel__c;
                        //rpExpnRec.Reason__c = 'Release Plan not created since no rights are found in CAS.';
                        // Added No Rights TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                        rpExpnRec.Reason__c = 'Release Plan not created since No Rights or No Rights TBA are found in CAS.';
                        releasePlanExceptionList.add(rpExpnRec);                                                         
                    } 
                }
                else {   
                    //Do not create release plan if MPM is empty.
                    //rpExpnRec.Reason__c = 'Release Plan not created since either no rights are found in CAS or MPM is empty.';
                    // Added No Rights TBA as part of ER-001181   Apply TTB Reason Code to TBA Status
                    rpExpnRec.Reason__c = 'Release Plan not created since No Rights or No Rights TBA are found in CAS.';
                    releasePlanExceptionList.add(rpExpnRec);
                } 
            } 
            if(lstCommAvail != null && lstCommAvail.size() > 0){
                lstFinalCommAvail = commAvailLstValidated (lstCommAvail); 
            } 
        } 
        // Existing functionality if "Use Rights To Create Release Plans" is unchecked.
        else if(recordsCreated !=null && recordsCreated.size() > 0 && isRightToCreateRPChk == False){
            lstFinalCommAvail= commAvailLstValidated (recordsCreated);
        }
        // End
        
        list<Commercial_Avail__c>  commercialAvailListInsert= new  list<Commercial_Avail__c>();
        commercialAvailListInsert = batchIdGeneration(lstFinalCommAvail);
        
        if(commercialAvailListInsert !=null && commercialAvailListInsert.size() >0  && releasePlanExceptionList.size()==0){
            try{
                Database.Saveresult[] saveResult  = Database.insert(commercialAvailListInsert, false);
                
                // Start : Updated code as per new request : Validate collection RPs if Playlist is not availale for collection.
                Integer successCount = 0, failureCount = 0, count=0;
                
                for(count=0 ; count < saveResult.size() ; count++){
                    Database.Saveresult SR = saveResult[count];
                    if(SR.isSuccess()){
                        successCount++;
                        setNewRPId.add(SR.getId());
                    }
                    else{
                        failureCount++; 
                        countExcpetionRec++;
                        Database.Error error = SR.getErrors().get(0);
                        Release_Plan_Exceptions__c rpExceptionRec = new Release_Plan_Exceptions__c();
                        rpExceptionRec.name = userDetail.id + string.valueof(countExcpetionRec);
                        rpExceptionRec.Title__c = titleList.get(commercialAvailListInsert[count].Title__c).Name;
                        rpExceptionRec.Video_Version__c=titleList.get(commercialAvailListInsert[count].Title__c).Video_Version__c;
                        rpExceptionRec.Channel__c = commercialAvailListInsert[count].Channel__c;
                        rpExceptionRec.Format__c = commercialAvailListInsert[count].Format__c;
                        rpExceptionRec.Country__c = countryMap.get(commercialAvailListInsert[count].Country_Lookup__c).Name;
                        rpExceptionRec.Language__c = languageMap.get(commercialAvailListInsert[count].Languages__c).Name;
                        rpExceptionRec.Reason__c = error.getMessage();
                        rpExceptionRec.User_Detail__c = userDetail.id;
                        releasePlanExceptionList.add(rpExceptionRec);  
                    }
                }
                
                if(releasePlanExceptionList.size() > 0)
                    Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);
                // END.                
                newRPCount = newRPCount + successCount;
                failedRPCount = failedRPCount + failureCount;
                
                //pageReference PageRef = new Pagereference(System.label.Re_direct_Commercal_Avail_Wizard);
                
                //as per CRRT pahse 2 requirement
                PageReference PageRef = new Pagereference('/apex/WB_Grid');
                Pageref.getParameters().put('al','true');
                Pageref.getParameters().put('obj','Commercial_Avail__c');
                Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
                Pageref.getParameters().put('CF_QP_filterValue',userDetail.RP_Batch_Id__c);
                PageRef.setredirect(false);
                //return PageRef;
            }catch(Exception e){
                System.debug('Exception while Inserting Release Plan ---'+e.getMessage());
            }
        } else if(commercialAvailListInsert !=null && commercialAvailListInsert.size()>0 && releasePlanExceptionList.size()!=0 ){
            try{
                Database.Saveresult[] saveResult  = Database.insert(commercialAvailListInsert, false);
                
                // Start : Updated code as per new request : Validate collection RPs if Playlist is not availale for collection.
                Integer successCount = 0, failureCount = 0, count=0;
                
                for(count=0 ; count < saveResult.size() ; count++){
                    Database.Saveresult SR = saveResult[count];
                    if(SR.isSuccess())
                        successCount++;
                    else{
                        failureCount++; 
                        countExcpetionRec++;
                        Database.Error error = SR.getErrors().get(0);
                        Release_Plan_Exceptions__c rpExceptionRec = new Release_Plan_Exceptions__c();
                        rpExceptionRec.name = userDetail.id + string.valueof(countExcpetionRec);
                        rpExceptionRec.Title__c = titleList.get(commercialAvailListInsert[count].Title__c).Name;
                        rpExceptionRec.Video_Version__c=titleList.get(commercialAvailListInsert[count].Title__c).Video_Version__c;
                        rpExceptionRec.Channel__c = commercialAvailListInsert[count].Channel__c;
                        rpExceptionRec.Format__c = commercialAvailListInsert[count].Format__c;
                        rpExceptionRec.Country__c = countryMap.get(commercialAvailListInsert[count].Country_Lookup__c).Name;
                        rpExceptionRec.Language__c = languageMap.get(commercialAvailListInsert[count].Languages__c).Name;
                        rpExceptionRec.Reason__c = error.getMessage();
                        rpExceptionRec.User_Detail__c = userDetail.id;
                        releasePlanExceptionList.add(rpExceptionRec);  
                    }
                }
                // END
                
                Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);
                newRPCount = newRPCount + successCount;
                failedRPCount = failedRPCount + failureCount;
                
                pageReference PageRef = new Pagereference('/apex/WB_RP_Redirect');
                PageRef.setredirect(false);
                //return PageRef;
            }catch(Exception e){
                system.debug('Exception caught----'+e.getMessage());
            }
        }else if(releasePlanExceptionList.size()!=0){// && channelGridValidationFlag == true)
            try{
                Database.Saveresult[] saveExceptionResult  = Database.insert(releasePlanExceptionList, false);
            }catch(Exception e){
                system.debug('Exception caught----'+e.getMessage());
            }
            pageReference PageRef = new Pagereference('/apex/WB_RP_Redirect');
            PageRef.setredirect(false);
            //return PageRef;
        }
        
    }//End : FINISH()
    
    public void finish(Database.BatchableContext BC){
        /*
AsyncApexJob a = [
SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
FROM AsyncApexJob WHERE Id = :BC.getJobId()
];
String plainText = '';
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {a.CreatedBy.Email};
mail.setToAddresses(toAddresses);
mail.setSubject('Release Plans batch status: ' + a.Status);
plainText = 'We have processed total ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n';
plainText = plainText + '\nTotal Release plans created are : ' + newRPCount;
plainText = plainText + '\nTotal Release plans failed are : ' + failedRPCount;
plainText = '\n\nPlease click on the link to view the records : ' + System.label.Re_direct_Commercal_Avail_Wizard;
mail.setPlainTextBody(plainText);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
*/
        //--------------------------------------------------------------------------------------------------------------------------
        
        integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];
        string header = 'Title, Avails Start, Avails End, Video Version, Channel, Country, Language, Language Type, Format, Reason, Release Plan Id, Release Start, Release End, Status, Exception with ExistingRecord, Old RP Records, User Detail  \n';
        string finalstr = header ;
        
        //CRRT Phase 3
        //Database.executeBatch(new WB_Batch_UpdateMPMReleaseDate(setNewRPId));
        //end
        
        for(Release_Plan_Exceptions__c rpExceptionOut_lst: releasePlanExceptionList)
        {
            string recordString = '"'+rpExceptionOut_lst.Title__c+'","'
                +rpExceptionOut_lst.Avails_Start__c+'","'
                +rpExceptionOut_lst.Avails_End__c+'","'
                +rpExceptionOut_lst.Video_Version__c+'","'
                +rpExceptionOut_lst.Channel__c+'","'
                +rpExceptionOut_lst.Country__c+'","'
                +rpExceptionOut_lst.Language__c+'","'
                +rpExceptionOut_lst.Language_Type__c+'","'
                +rpExceptionOut_lst.Format__c+'","'
                +rpExceptionOut_lst.Reason__c+'","'
                +rpExceptionOut_lst.Release_Plan_Id__c+'","'
                +rpExceptionOut_lst.Release_Start_Date__c+'","'
                +rpExceptionOut_lst.Release_End_Date__c+'","'
                +rpExceptionOut_lst.Status__c+'","'
                +rpExceptionOut_lst.Exception_with_ExistingRecord__c+'","'
                +rpExceptionOut_lst.Old_RP_Records__c+'","'
                +rpExceptionOut_lst.User_Detail__c+'","'
                +'"\n';
            finalstr = finalstr +recordString;
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= 'RP.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        // Email the Batch Job's submitter that the Job is finished.
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            
            String subject ='Release Plan Exception out CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        String strWbGrid = '/apex/WB_Grid?al=true&CF_QP_filterField=Batch_Id__c&CF_QP_filterValue='+userDetail.RP_Batch_Id__c+'&obj=Commercial_Avail__c';
        
        /* if(failedRPCount == 0){
//email.setPlainTextBody('If you�ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
email.setPlainTextBody('If you�ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + strWbGrid + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
}
else if(failedRPCount == (newRPCount + failedRPCount)){
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review.');
}
else{
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
//email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review. Few records are created successfully, you can see records by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review. Few records are created successfully, you can see records by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + strWbGrid + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
}*/
        if(releasePlanExceptionList == null || releasePlanExceptionList.size() == 0){
            //email.setPlainTextBody('If you�ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
            email.setPlainTextBody('If you�ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + strWbGrid + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
        }
        else if(releasePlanExceptionList != null && releasePlanExceptionList.size() > 0){
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review. Few records are created successfully, you can see records by clicking on the link \n'+ System.Label.Re_direct_Commercal_Avail_Wizard + strWbGrid + '\n If, however, you�ve created more records since you ran the wizard which initiated this batch process,those records won�t be available.');// You can see this batch�s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
        }
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
    public class availableLangType{
        string langType{get;set;}
        string availableLanguage{get;set;}
    }
    
    public class langPriority{
        string priority{get;set;}
        string preferedLang{get;set;}
        string preferedLangName{get;set;}//Added in CRRT Phase 7 release
        string preferedCntyName{get;set;}//Added in CRRT Phase 7 release
        Boolean isPhysical{get;set;}
    }
    public class channelWrapper{
        public string countryChannel{get;set;}
        public Commercial_Avail__c additionalInfo{get;set;}
        public Integer delIndent {get;set;}
        public Integer addIndent {get;set;}
        public boolean renderExclusiveDate{get;set;}
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
        boolean validationFlag= true;
        
        for(integer i=0;i<commercialAvailList.size();i++){
            lst_selectedtitle.add(commercialAvailList[i].Title__c);
            lst_selectedcountry.add(commercialAvailList[i].Country_Lookup__c);
            lst_selectedchannel.add(commercialAvailList[i].Channel__c);
            lst_selectedformat.add(commercialAvailList[i].Format__c);
            lst_selectedlanguage.add(commercialAvailList[i].Languages__c);
        }
        
        lst_selectedcommercial_aval = [
            SELECT id, name,Title__c,Title__r.name, Title__r.Video_Version__c,Country_Lookup__c,Country_Lookup__r.name,Channel__c,Format__c,Languages__c,
            Languages__r.name,Language_Type__c,End_Date__c,Start_Date__c
            FROM Commercial_Avail__c 
            WHERE Title__c IN :lst_selectedtitle AND Country_Lookup__c IN :lst_selectedcountry AND Channel__c IN :lst_selectedchannel 
            AND Format__c IN :lst_selectedformat
            AND Languages__c IN :lst_selectedlanguage
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
                    rpExceptionRec.name=userDetail.Id+ string.valueof(countExcpetionRec);
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
                    rpExceptionRec.User_Detail__c=userDetail.Id;
                    releasePlanExceptionList.add(rpExceptionRec);
                    countOverLap++;
                    //commercialAvailList.remove(i);
                    break;
                }//ended
                // added by rashmi on 9th sept
                else if(commercialAvailList[i].channel__c==lst_selectedcommercial_aval[j].channel__c 
                        &&  commercialAvailList[i].format__c==lst_selectedcommercial_aval[j].format__c 
                        && commercialAvailList[i].country_lookup__c==lst_selectedcommercial_aval[j].country_lookup__c 
                        &&  commercialAvailList[i].title__c ==lst_selectedcommercial_aval[j].title__c 
                        && commercialAvailList[i].Languages__c==lst_selectedcommercial_aval[j].Languages__c 
                       ){                    
                           if((lst_selectedcommercial_aval[j].Start_Date__c==null && lst_selectedcommercial_aval[j].End_Date__c==null && commercialAvailList[i].Start_Date__c==null && commercialAvailList[i].End_Date__c==null)){
                               //  || ((lst_selectedcommercial_aval[j].Start_Date__c==null && lst_selectedcommercial_aval[j].End_Date__c==null) || (commercialAvailList[i].Start_Date__c==null && commercialAvailList[i].End_Date__c==null))
                               
                               validationFlag=false;
                               countExcpetionRec++;
                               rpExceptionRec.name=userDetail.Id+ string.valueof(countExcpetionRec);
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
                               rpExceptionRec.User_Detail__c=userDetail.Id;
                               releasePlanExceptionList.add(rpExceptionRec);
                               countOverLap++;
                               //commercialAvailList.remove(i);
                               break;
                           }
                           else if(
                               ((commercialAvailList[i].Start_Date__c >= lst_selectedcommercial_aval[j].Start_Date__c && commercialAvailList[i].Start_Date__c <= lst_selectedcommercial_aval[j].End_Date__c)) 
                               ||((commercialAvailList[i].End_Date__c >=lst_selectedcommercial_aval[j].Start_Date__c && commercialAvailList[i].End_Date__c <= lst_selectedcommercial_aval[j].End_Date__c ))
                               ||(commercialAvailList[i].Start_Date__c < lst_selectedcommercial_aval[j].Start_Date__c && commercialAvailList[i].End_Date__c > lst_selectedcommercial_aval[j].End_Date__c)
                           ){
                               validationFlag=false;
                               //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Release_Plan_Date_Overlap+' '+'to'+' '+lst_selectedcommercial_aval[j].name));
                               countExcpetionRec++;
                               rpExceptionRec.name=userDetail.Id+ string.valueof(countExcpetionRec);
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
                               rpExceptionRec.User_Detail__c=userDetail.Id;
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
    
    /**batch id  creation method **/
    public list<Commercial_Avail__c> batchIdGeneration(list<Commercial_Avail__c> list_TobeUpdate){
        
        list<Batch_Ids_Customsetting__c> clientAvailBatchId_lst = [
            SELECT Id,Name,CA_Batch_Id__c,RP_Batch_Id__c,RP_Created_Date__c,CA_User_Detail__c
            FROM Batch_Ids_Customsetting__c for update
        ];
        
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
}