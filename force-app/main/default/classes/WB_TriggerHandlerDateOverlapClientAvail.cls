/******* 
Name:WB_TriggerHandlerDateOverlapClientAvail
Creation Date- 4th Sept'2014
Description- Controller for handling trigger on client avail for Date Overlap
Author- Rashmi Singh
*******/
public with sharing class WB_TriggerHandlerDateOverlapClientAvail{
    //ER-955
    //Updated on 4/17/2017
    Public static void assignOwner(List<Client_Avail__c> listClientAvailRecs)
    {
        //System.debug('Inside CA Owner method');
        //List<Client_Avail__c> listClientAvailRecs = trigger.new ;
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<String> setCountryName = new set<String>();
        //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
        Set<Id> localDataIds = new Set<Id>();
        //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
        
        if(listClientAvailRecs != null && listClientAvailRecs.size() > 0){
            for(Client_Avail__c clientAvailWithCountry: listClientAvailRecs){
                if(clientAvailWithCountry.Release_Plan_Country__c != null)
                    setCountryName.add(clientAvailWithCountry.Release_Plan_Country__c);
                //Added for Query of Local Data - ER-003578
                localDataIds.add(clientAvailWithCountry.Local_Title__c);
            }
            //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
            Map<Id,Local_Title__c> mapIdLocalData = new Map<Id,Local_Title__c>([SELECT Id,LocalDisplayStudio__c FROM Local_Title__c WHERE Id IN :localDataIds LIMIT 50000]);
            //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
            //System.debug('mapIdLocalData'+mapIdLocalData);
            if(setCountryName != null && setCountryName.size() > 0){ 
                Map<String, Country__c> mapCountry = new Map<String, Country__c>();
                //HBO_Override__c & Turner_Override__c Fields Added for below Query - ER-003578
                List<Country__c> lstCountries = [SELECT Id, Name, Digital_Owner__c, Physical_Owner__c,HBO_Override__c,Turner_Override__c FROM Country__c Where Name IN: setCountryName LIMIT 10000];
                for(Country__c country : lstCountries)
                    mapCountry.put(country.Name,country);
                for(Client_Avail__c clientAvail: listClientAvailRecs){
                    //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
                    Boolean hboTurnerFlag = true;
                    Map<String,WB_HBO_TURNER_Countries__c> mapHBOTURNERCountries = WB_HBO_TURNER_Countries__c.getAll();
                    if(mapHBOTURNERCountries.containsKey(clientAvail.Release_Plan_Country__c)){
                        String hboOverrideStudios = Label.HBOVal;
                        List<String> listHBOOverrideStudios = hboOverrideStudios.split(',');
                        String hboTurnerStudios = Label.TurnerVal;
                        List<String> listHBOTurnerStudios = hboTurnerStudios.split(',');
                        Boolean overrideFlag = false;
                        Boolean turnerFlag = false;
                        if(listHBOOverrideStudios.contains(mapIdLocalData.get(clientAvail.Local_Title__c).LocalDisplayStudio__c)){
                            overrideFlag = true;
                        }
                        else if(listHBOTurnerStudios.contains(mapIdLocalData.get(clientAvail.Local_Title__c).LocalDisplayStudio__c)){
                            turnerFlag = true;
                        }
                        
                        if(overrideFlag){
                            clientAvail.OwnerId = allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).HBO_Override__c).Value__c;
                            //System.debug('clientAvail.OwnerId'+clientAvail.OwnerId);
                        } else if(turnerFlag){
                            clientAvail.OwnerId = allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Turner_Override__c).Value__c;
                            //System.debug('clientAvail.OwnerId'+clientAvail.OwnerId);
                        } else{
                            hboTurnerFlag = false;
                        }
                    } else{
                        hboTurnerFlag = false;
                    }
                    if(!hboTurnerFlag){
                        //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
                        if(clientAvail.Title_Physical_Planning__c == 'Yes' && clientAvail.Release_Plan_Country__c != null){
                            if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Physical_Owner__c) != null && allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Physical_Owner__c).Value__c != null){
                                clientAvail.OwnerId = allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Physical_Owner__c).Value__c;
                                //System.debug('clientAvail.OwnerId'+clientAvail.OwnerId);
                            }
                        }
                        else if(clientAvail.Title_Digital_Planning__c == 'Yes' && clientAvail.Release_Plan_Country__c != null){
                            if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Digital_Owner__c).Value__c != null){
                                clientAvail.OwnerId = allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Digital_Owner__c).Value__c;
                                //System.debug('clientAvail.OwnerId'+clientAvail.OwnerId);
                            }
                        }
                        else{
                            if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Digital_Owner__c).Value__c != null){
                                clientAvail.OwnerId = allQueuesetting.get(mapCountry.get(clientAvail.Release_Plan_Country__c).Digital_Owner__c).Value__c;
                                //System.debug('clientAvail.OwnerId'+clientAvail.OwnerId);
                            }
                        }
                    }
                    //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
                //System.debug('clientAvail.OwnerId'+clientAvail.OwnerId);
                }
                
                //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
            }
        }
    }
    /*//ER-820: Method for ownership assignment. Replaces workflows.
Public static void assignOwner()
{
List<Client_Avail__c> availList = trigger.new;
for(Client_Avail__c cAvail : availList)
{
if(cAvail.Territory__c != '' || cAvail.Territory__c != NULL)
{
if(cAvail.Territory__c == 'APAC Licensee Group')
cAvail.ownerId = system.label.Queue_APACLicenseeQ;
else if(cAvail.Territory__c == 'Brazil')
cAvail.ownerId = system.label.Queue_BrazilQ;
else if(cAvail.Territory__c == 'China')
cAvail.ownerId = system.label.Queue_ChinaQ;
else if(cAvail.Territory__c == 'EMEA Licensee Group')
cAvail.ownerId = system.label.Queue_EMEALicenseeQ;
else if(cAvail.Territory__c == 'France')
cAvail.ownerId = system.label.Queue_FranceQ;
else if(cAvail.Territory__c == 'Germany')
cAvail.ownerId = system.label.Queue_GermanyQ;
else if(cAvail.Territory__c == 'Home Office')
cAvail.ownerId = system.label.Queue_HomeOfficeQ;
else if(cAvail.Territory__c == 'Italy')
cAvail.ownerId = system.label.Queue_ItalyQ;
else if(cAvail.Territory__c == 'Japan')
cAvail.ownerId = system.label.Queue_JapanQ;
else if(cAvail.Territory__c == 'Korea')
cAvail.ownerId = system.label.Queue_KoreaQ;
else if(cAvail.Territory__c == 'Mexico')
cAvail.ownerId = system.label.Queue_MexicoQ;
else if(cAvail.Territory__c == 'Nordic')
cAvail.ownerId = system.label.Queue_NordicQ;
else if(cAvail.Territory__c == 'Spain')
cAvail.ownerId = system.label.Queue_SpainQ;
else if(cAvail.Territory__c == 'United Kingdom')
cAvail.ownerId = system.label.Queue_UK_Q;
else if(cAvail.Territory__c == 'USA')
cAvail.ownerId = system.label.Queue_USA_Q;


}
}
}*/
    
    
    public static void dateOverlapBeforeupdate (List<Client_Avail__c> newClientAvails,List<Client_Avail__c> oldClientAvails) {
        
        list<string> selectedCommercialId = new list<string>();
        list<string> selectedTitle = new list<string>() ;
        list<string> selectedChannels = new list<string>() ;
        list<string> selectedFormats = new list<string>();
        list<string> selectedLanguage= new list<string>();
        //list<string> selectedLanguageType = new list<string>();
        list<string> selectedCountry = new list<string>();
        list<string> selectedClient = new list<string>();
        list<string> selectedClId = new list<string>();
        list<Client_Avail__c> lst_trigger_clientAvail = new list<Client_Avail__c>();
        list<Client_Avail__c> lst_oldtrigger_clientAvail = new list<Client_Avail__c>();
        list<Client_Avail__c> lst_trigger_clientAvailNew = new list<Client_Avail__c>();
        lst_trigger_clientAvailNew  = newClientAvails;//trigger.new;  // will be used for comparing records with each for Date overlap 
        list<User> userDetail = new list<User>();
        boolean flagReleaseMaintainer = false;
        
        lst_trigger_clientAvail = newClientAvails;//trigger.new;
        lst_oldtrigger_clientAvail = oldClientAvails;
        //System.debug('CA OLD ----'+lst_oldtrigger_clientAvail);
        //System.debug('CA NEW ----'+lst_trigger_clientAvail);
        
        //User Info validation for release maitainer profile
        Map<Id,User> mapUserDetail = new Map<Id,User>([SELECT id,ProfileId,Profile.Name,UserType,Territory__c  from User where id =: Userinfo.getUserId()]);
        userDetail =mapUserDetail.values();
        //system.debug('@@@userDetail'+userDetail);
        
        //start date must be less then end date.
        /*for(Integer a=0;a<lst_trigger_clientAvail.size();a++){
if(lst_trigger_clientAvail[a].Start_Date__c > lst_trigger_clientAvail[a].End_Date__c ){
// Criteria 1
system.debug('Criteria  for start date greater than end date');
lst_trigger_clientAvail[a].Start_Date__c.adderror('Start date cannot be greater than End date');
}
}*/
        
        for(integer i=0;i<lst_trigger_clientAvail.size();i++){
            selectedCommercialId.add(lst_trigger_clientAvail[i].Commercial_Avail__c);
            selectedClient.add(lst_trigger_clientAvail[i].Client__c);
        }
        
        // system.debug('commercial Ids in update function '+selectedCommercialId);
        //system.debug('@@@selectedClient in update function '+selectedClient);
        
        Map<Id,commercial_avail__c> mapSelectedCommercialAvails = new Map<Id,commercial_avail__c>([
            select id
            , channel__c
            , End_Date__c
            , Start_Date__c
            , Title__c
            , Title__r.Name
            , format__c
            , Country_Lookup__c
            , Country_Lookup__r.Name
            , Country_Lookup__r.Territory__c
            , Languages__c
            , Languages__r.Name
            , language_type__c 
            from commercial_avail__C 
            where Id IN:selectedCommercialId
        ]);
        list<commercial_avail__c> selectedCommercialAvails= mapSelectedCommercialAvails.values();
        
        //system.debug('selected comm avails in update function'+selectedCommercialAvails);
        
        for(integer i=0;i<selectedCommercialAvails.size();i++){
            /***We didnt check wether any of this field for any commercial is blank... need to check in testing wethere it will through Null pointer exception:24th oct****/
            selectedChannels.add(selectedCommercialAvails[i].channel__c);
            selectedTitle.add(selectedCommercialAvails[i].Title__r.Name);
            selectedFormats.add(selectedCommercialAvails[i].format__c);
            selectedLanguage.add(selectedCommercialAvails[i].Languages__r.Name);
            //selectedLanguageType.add(selectedCommercialAvails[i].language_type__c);
            selectedCountry.add(selectedCommercialAvails[i].Country_Lookup__r.Name);
            selectedClId.add(lst_trigger_clientAvail[i].Id);
        }
        
        /*list<client_avail__c> DateList=[select id,End_Date__c,Start_Date__c, Commercial_Avail__r.Start_Date__c,Commercial_Avail__r.End_Date__c,
Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,Release_Plan_Country__c,
Release_Plan_Title__c,Client__c from client_avail__c where Release_Plan_Channel__c IN:selectedChannels 
AND Release_Plan_Format__c IN:selectedFormats AND Release_Plan_Language__c IN:selectedLanguage AND
Release_Plan_Country__c IN:selectedCountry  AND Release_Plan_Title__c IN :selectedTitle AND 
client__c IN :selectedClient ];*/
        Map<Id,client_avail__c> mapDateList = new Map<Id,client_avail__c>([
            select id
            , End_Date__c
            , Start_Date__c
            , Commercial_Avail__r.Start_Date__c
            , Commercial_Avail__r.End_Date__c
            , Release_Plan_Channel__c
            , Release_Plan_Format__c
            , Release_Plan_Language__c
            , Release_Plan_Country__c
            , Release_Plan_Title__c
            , Client__c  
            from client_avail__c
            where Client__c IN :selectedClient AND Commercial_Avail__c IN: selectedCommercialId
            AND (Avail_Type__c != 'Automated' OR Avail_Type__c = null) // Added condition to bypass episode client avails created by batch(ER-10)
        ]);
        list<client_avail__c> DateList = mapDateList.values();
        
        set<client_avail__c> DateList1 = new set<client_avail__c>();
        DateList1.addAll(DateList);
        
        for(client_avail__c clientAvailRec : DateList1 ){
            for(client_avail__c clientSelected:lst_trigger_clientAvail){ 
                if(clientAvailRec.id==clientSelected.id){
                    DateList1.remove(clientAvailRec);
                    //system.debug('DateList1 is in for loop---->' + DateList1); 
                }
            }
        }
        DateList.clear();
        DateList.addAll(DateList1);
        
        //system.debug('DateList is---->' + DateList); 
        //system.debug('DateList1 is---->' + DateList1); 
        
        //checking whether user's territory is equals to release plan country territory 
        //system.debug('@@@beforeflagReleaseMaintainer'+flagReleaseMaintainer);
        for(commercial_avail__C commers :selectedCommercialAvails){
            for(User u :userDetail){
                if(u.Profile.Name ==System.Label.WB_Territory_Release_Planner){
                    if (commers.Country_Lookup__r.Territory__c != u.Territory__c){
                        flagReleaseMaintainer =true;
                    }
                }
            }
        }
        //system.debug('@@@afterflagReleaseMaintainer'+flagReleaseMaintainer);
        if(flagReleaseMaintainer != true){
            //System.debug('CA OLD 1 ----'+lst_oldtrigger_clientAvail);
            //System.debug('CA NEW 2 ----'+lst_trigger_clientAvail);
            for (integer k =0;k<lst_oldtrigger_clientAvail.size();k++){
                //added by shalini to include CA validations only when RP synch is off --for ER-000119
                //if(lst_trigger_clientAvail[k].RP_Synch__c == false){ - Mahesh
                if( (lst_oldtrigger_clientAvail[k].Start_Date__c != lst_trigger_clientAvail[k].Start_Date__c) ||
                   (lst_oldtrigger_clientAvail[k].End_Date__c != lst_trigger_clientAvail[k].End_Date__c) ||
                   (lst_oldtrigger_clientAvail[k].Commercial_Avail__c != lst_trigger_clientAvail[k].Commercial_Avail__c) ||
                   (lst_oldtrigger_clientAvail[k].Client__c != lst_trigger_clientAvail[k].Client__c) ||
                   (lst_oldtrigger_clientAvail[k].RP_Synch__c == false && lst_trigger_clientAvail[k].RP_Synch__c == true) //Added - Mahesh
                  ){
                      //SINC1028269  29 Jun,14
                      if(lst_oldtrigger_clientAvail[k].RP_Synch__c == false && lst_trigger_clientAvail[k].RP_Synch__c == true){
                          lst_trigger_clientAvail[k].Start_Date__c=lst_trigger_clientAvail[k].Release_Plan_Start_Date__c;
                          lst_trigger_clientAvail[k].End_Date__c=lst_trigger_clientAvail[k].Release_Plan_End_Date__c;
                      }
                      /*****i think in above if condition in place of OR there will AND****Nav 24th Oct */
                      for(integer n=0;n<lst_trigger_clientAvail.size();n++){
                          for(Integer s =0;s<selectedCommercialAvails.size();s++){
                              //system.debug('Before date list loop');
                              if(lst_trigger_clientAvail[n].Start_Date__c == null && lst_trigger_clientAvail[n].End_Date__c==null){
                                  lst_trigger_clientAvail[n].Start_Date__c =selectedCommercialAvails[s].Start_Date__c;
                                  lst_trigger_clientAvail[n].End_Date__c =selectedCommercialAvails[s].End_Date__c;
                              }
                              //system.debug('DateList size is' + DateList.size()+'dATELIST is -----'+DateList); 
                              //system.debug('lst_trigger_clientAvail[n] start date----'+lst_trigger_clientAvail[n].Start_Date__c);
                              //system.debug('lst_trigger_clientAvail[n] End_Date__c----'+lst_trigger_clientAvail[n].End_Date__c);
                              //system.debug('lst_trigger_clientAvail[n] client__c----'+lst_trigger_clientAvail[n].client__c);
                              //system.debug('lst_trigger_clientAvail[n] Commercial_Avail__c----'+lst_trigger_clientAvail[n].Commercial_Avail__c);
                              //system.debug('lst_oldtrigger_clientAvail[k]Start_Date__c----'+lst_oldtrigger_clientAvail[k].Start_Date__c);
                              //system.debug('lst_oldtrigger_clientAvail[k] End_Date__c----'+lst_oldtrigger_clientAvail[k].End_Date__c);
                              
                              //system.debug('selectedCommercialAvails[s].Id---------'+selectedCommercialAvails[s].Id);
                              if(DateList.size()!= 0){
                                  for(integer i=0;i<DateList.size();i++){
                                      //System.debug('Santanu Error1');
                                      if(DateList[i].Commercial_Avail__c ==selectedCommercialAvails[s].Id && lst_trigger_clientAvail[n].Commercial_Avail__c == selectedCommercialAvails[s].Id &&
                                         DateList[i].client__c == lst_trigger_clientAvail[n].client__c){
                                             //System.debug('Santanu Error3');
                                             /* added by shalini for ER-119 
if(lst_trigger_clientAvail[n].Id == lst_oldtrigger_clientAvail[k].Id){
if(lst_trigger_clientAvail[n].Start_Date__c == lst_oldtrigger_clientAvail[k].Start_Date__c || lst_trigger_clientAvail[n].End_Date__c== lst_oldtrigger_clientAvail[k].End_Date__c){ 
lst_trigger_clientAvail[n] .addError('Client avail is present with selected dates, Please select different start and End Dates');
}
}//Added by Milon

Finally commented by Milon*/
                                             /*end of code for ER-119*/
                                             if(lst_trigger_clientAvail[n].Start_Date__c==DateList[i].Start_Date__c && lst_trigger_clientAvail[n].End_Date__c==DateList[i].End_Date__c && lst_trigger_clientAvail[n].Avail_Type__c != 'Automated'){ // ER-10 : Added Avail Type condition 
                                                 
                                                 lst_trigger_clientAvail[n] .addError('Client avail is present with selected dates, Please select different start and End Dates');
                                             }
                                             else if(lst_trigger_clientAvail[n].Start_Date__c > lst_trigger_clientAvail[n].End_Date__c  && lst_trigger_clientAvail[n].Avail_Type__c != 'Automated'){ // ER-10 : Added Avail Type condition 
                                                 // Criteria 1
                                                 //system.debug('Criteria 1');
                                                 lst_trigger_clientAvail[n].Start_Date__c.adderror('Start date cannot be greater than End date');
                                             }
                                             else if(!((lst_trigger_clientAvail[n].Start_Date__c >= DateList[i].End_Date__c)||(lst_trigger_clientAvail[n].End_Date__c <=DateList[i].Start_Date__c))  && lst_trigger_clientAvail[n].Avail_Type__c != 'Automated'){ // ER-10 : Added Avail Type condition 
                                                 //system.debug('common Criteria in update');
                                                 //system.debug('lst_trigger_clientAvail[n].Start_Date__c--------'+lst_trigger_clientAvail[n].Start_Date__c);
                                                 //system.debug('DateList[i].End_Date__c--------'+DateList[i].End_Date__c);
                                                 //system.debug('DateList[i].Start_Date__c--------'+DateList[i].Start_Date__c);
                                                 //system.debug('lst_trigger_clientAvail[n].End_Date__c--------'+lst_trigger_clientAvail[n].End_Date__c);
                                                 
                                                 lst_trigger_clientAvail[n].Start_Date__c.adderror('Start date is overlapping with existing record');
                                                 lst_trigger_clientAvail[n].End_Date__c.adderror('End date is overlapping with existing record');
                                             }
                                             else  if (!((selectedCommercialAvails[s].Start_Date__c <=lst_trigger_clientAvail[n].Start_Date__c && lst_trigger_clientAvail[n].Start_Date__c <= selectedCommercialAvails[s].End_Date__c)
                                                         && (selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].End_Date__c && lst_trigger_clientAvail[n].End_Date__c <= selectedCommercialAvails[s].End_Date__c))){ 
                                                             
                                                             //system.debug(LoggingLevel.Error,'date is greate than end of commercial avail');
                                                             lst_trigger_clientAvail[n].Start_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                                             lst_trigger_clientAvail[n].End_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                                         }
                                         }
                                  }
                              }// End inner for loop
                              else {
                                  if(lst_trigger_clientAvail[n].Commercial_Avail__c == selectedCommercialAvails[s].Id){
                                      if (!((selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].Start_Date__c && lst_trigger_clientAvail[n].Start_Date__c <= selectedCommercialAvails[s].End_Date__c)
                                            && (selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].End_Date__c && lst_trigger_clientAvail[n].End_Date__c <= selectedCommercialAvails[s].End_Date__c))){ 
                                                //system.debug(LoggingLevel.Error,'Im here..sriniz 123');
                                                //Removed hardcoded index for SINC0955653
                                                lst_trigger_clientAvail[n].Start_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                                lst_trigger_clientAvail[n].End_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                            }
                                  }
                              }
                              
                              /* Start - Prajakta - Added on 15/3/2015 - SINC0424326 - Now is Good (Start Date > End date for client Avail)*/
                              if(lst_trigger_clientAvail[n].Start_Date__c > lst_trigger_clientAvail[n].End_Date__c) {
                                  lst_trigger_clientAvail[n].Start_Date__c.addError('Start date cannot be greater than End date');
                              }
                              /* End - Prajakta */
                              
                              /* 119 logic starts here - Mahesh */
                              if( (lst_oldtrigger_clientAvail[k].Start_Date__c != null && lst_oldtrigger_clientAvail[k].End_Date__c !=null) && 
                                 ( (lst_oldtrigger_clientAvail[k].Start_Date__c != lst_trigger_clientAvail[k].Start_Date__c) ||
                                  (lst_oldtrigger_clientAvail[k].End_Date__c != lst_trigger_clientAvail[k].End_Date__c)
                                 ) &&
                                 ( (lst_trigger_clientAvail[k].Start_Date__c != selectedCommercialAvails[s].Start_Date__c) ||
                                  (lst_trigger_clientAvail[k].End_Date__c != selectedCommercialAvails[s].End_Date__c)
                                 )
                                ){
                                    if((lst_trigger_clientAvail[k].Start_Date__c < selectedCommercialAvails[s].Start_Date__c &&
                                        lst_trigger_clientAvail[k].Start_Date__c <selectedCommercialAvails[s].End_Date__c) 
                                       && (lst_trigger_clientAvail[k].End_Date__c > selectedCommercialAvails[s].Start_Date__c &&
                                           lst_trigger_clientAvail[k].End_Date__c > selectedCommercialAvails[s].End_Date__c)
                                      ){
                                          //system.debug(LoggingLevel.Error,'Im here..sriniz 124');
                                          lst_trigger_clientAvail[k].Start_Date__c.addError('Client Avail Dates must be between Release Plan Dates');
                                          lst_trigger_clientAvail[k].End_Date__c.addError('Client Avail Dates must be between Release Plan Dates');
                                      }else
                                          lst_trigger_clientAvail[k].RP_Synch__c = false;
                                    //System.debug('RP Synch after --------'+lst_trigger_clientAvail[k].RP_Synch__c);
                                }
                              /* 119 logic Ends here - Mahesh */
                          } // Ending selected commercial avail loop inside
                          
                          //Duplicate issue Bug fix - shekhar
                          For(integer cl=0;cl<lst_trigger_clientAvailNew.size();cl++) {
                              if (lst_trigger_clientAvail[n].Commercial_Avail__c == lst_trigger_clientAvailNew[cl].Commercial_Avail__c  
                                  && lst_trigger_clientAvail[n].client__c == lst_trigger_clientAvailNew[cl].client__c  
                                  && lst_trigger_clientAvail[n].id != lst_trigger_clientAvailNew[cl].id 
                                  && lst_trigger_clientAvail[n].Title__c == lst_trigger_clientAvailNew[cl].Title__c){ // ER: 10 Added condition for Avail type
                                      if(!((lst_trigger_clientAvail[n].Start_Date__c > lst_trigger_clientAvailNew[cl].End_Date__c)||(lst_trigger_clientAvail[n].End_Date__c <lst_trigger_clientAvailNew[cl].Start_Date__c )))
                                          lst_trigger_clientAvail[n].addError('Either Start date or End date overlapping with one the record currently being updated'  );
                                  }   
                          }
                      }
                  }
                //}//added by shalini for ER-119 - Mahesh
                /*
//else condition for RP synch checked
else{
for(Integer s =0;s<selectedCommercialAvails.size();s++){
if( (lst_oldtrigger_clientAvail[k].Start_Date__c != null && lst_oldtrigger_clientAvail[k].End_Date__c !=null) && 
((lst_oldtrigger_clientAvail[k].Start_Date__c != lst_trigger_clientAvail[k].Start_Date__c) ||
(lst_oldtrigger_clientAvail[k].End_Date__c != lst_trigger_clientAvail[k].End_Date__c)
) && 
(   (lst_trigger_clientAvail[k].Start_Date__c != selectedCommercialAvails[s].Start_Date__c) || 
(lst_trigger_clientAvail[k].End_Date__c != selectedCommercialAvails[s].End_Date__c))
){
if(     (lst_trigger_clientAvail[k].Start_Date__c < selectedCommercialAvails[s].Start_Date__c &&
lst_trigger_clientAvail[k].Start_Date__c <selectedCommercialAvails[s].End_Date__c) 
&&  (lst_trigger_clientAvail[k].End_Date__c > selectedCommercialAvails[s].Start_Date__c &&
lst_trigger_clientAvail[k].End_Date__c > selectedCommercialAvails[s].End_Date__c)
){
lst_trigger_clientAvail[k].Start_Date__c.addError('Client Avail Dates must be between Release Plan Dates');
lst_trigger_clientAvail[k].End_Date__c.addError('Client Avail Dates must be between Release Plan Dates');
}else
lst_trigger_clientAvail[k].RP_Synch__c = false;
System.debug('RP Synch after --------'+lst_trigger_clientAvail[k].RP_Synch__c);
}
}
}
//ER-119 added by shalini to sysnch the Client avail dates with RP dates after the RP sycnh is turn on 
system.debug('Inside before update first consition------'+lst_oldtrigger_clientAvail[k].RP_Synch__c );
system.debug('Inside before update TO be value------'+lst_trigger_clientAvail[k].RP_Synch__c );
if(lst_oldtrigger_clientAvail[k].RP_Synch__c == false && lst_trigger_clientAvail[k].RP_Synch__c == true){
//sybch CA dates with RP sates
lst_trigger_clientAvail[k].Start_Date__c=lst_trigger_clientAvail[k].Release_Plan_Start_Date__c;
lst_trigger_clientAvail[k].End_Date__c=lst_trigger_clientAvail[k].Release_Plan_End_Date__c;
}
*/
            }
        }else
            lst_trigger_clientAvail[0] .addError('Client avail for this Release plan cannot be created'); // only applicable when Client is created through standard way  // added by Tejas old for loop end
        
        selectedCommercialAvails.clear();
        DateList.clear();
        selectedChannels.clear();
        selectedFormats.clear();
        selectedLanguage.clear();
        // selectedLanguageType.clear();
        selectedCountry.clear();
        
    }// End of function  
    
    
    public static void dateOverlapBeforeinsert(){
        
        //system.debug('Inside trigger insert method');
        list<string> selectedCommercialId = new list<string>();
        list<string> selectedTitle = new list<string>() ;
        list<string> selectedChannels = new list<string>() ;
        list<string> selectedFormats = new list<string>();
        list<string> selectedLanguage= new list<string>();
        // list<string> selectedLanguageType = new list<string>();
        list<string> selectedCountry = new list<string>();
        list<string> selectedClient = new list<string>();
        boolean flagReleaseMaintainer = false;
        boolean flagClientAvailstartEnd = false;
        list<User> userDetail = new list<User>();
        
        
        list<Client_Avail__c> lst_trigger_clientAvail = new list<Client_Avail__c>();
        //system.debug('trigger.new in insert 890807'+trigger.new +'****'+trigger.new.size());
        
        lst_trigger_clientAvail = trigger.new;
        
        //User Info validation for release maitainer profile
        Map<Id,User> mapUserDetail2 = new Map<Id,User>([SELECT id,ProfileId,Profile.Name,UserType,Territory__c  from User where id =: Userinfo.getUserId()]);
        userDetail = mapUserDetail2.values();
        //system.debug('@@@userDetail'+userDetail);
        
        for(Integer a=0;a<lst_trigger_clientAvail.size();a++){
            if(lst_trigger_clientAvail[a].Start_Date__c > lst_trigger_clientAvail[a].End_Date__c ){
                // Criteria 1
                lst_trigger_clientAvail[a].Start_Date__c.adderror('Start date cannot be greater than End date');
            }
        }  //ended
        
        for(integer i=0;i<lst_trigger_clientAvail.size();i++){
            selectedCommercialId.add(lst_trigger_clientAvail[i].Commercial_Avail__c);
            selectedClient.add(lst_trigger_clientAvail[i].Client__c);       
        }
        
        Map<Id,commercial_avail__c> mapSelectedCommercialAvails2 = new Map<Id,commercial_avail__c>([select Id, Name
                                                                                                    , channel__c, format__c
                                                                                                    , End_Date__c, Start_Date__c
                                                                                                    , Title__c, Title__r.Name
                                                                                                    , Country_Lookup__c, Country_Lookup__r.Name, Country_Lookup__r.Territory__c
                                                                                                    , Languages__c, Languages__r.Name, language_type__c 
                                                                                                    from commercial_avail__C 
                                                                                                    where id IN:selectedCommercialId]);
        list<commercial_avail__c> selectedCommercialAvails= mapSelectedCommercialAvails2.values();
        
        for(integer i=0;i<selectedCommercialAvails.size();i++){
            selectedChannels.add(selectedCommercialAvails[i].channel__c);
            selectedTitle.add(selectedCommercialAvails[i].Title__r.Name);
            selectedFormats.add(selectedCommercialAvails[i].format__c);
            selectedLanguage.add(selectedCommercialAvails[i].Languages__r.Name);
            // selectedLanguageType.add(selectedCommercialAvails[i].language_type__c);
            selectedCountry.add(selectedCommercialAvails[i].Country_Lookup__r.Name);
        }
        
        /*list<client_avail__c> DateList=[select id,End_Date__c,Start_Date__c,Commercial_Avail__r.Start_Date__c,Commercial_Avail__r.End_Date__c,Release_Plan_Channel__c,Release_Plan_Format__c,
Release_Plan_Language__c,Release_Plan_Country__c,Release_Plan_Title__c,Client__c  
from client_avail__c where Release_Plan_Channel__c IN:selectedChannels  AND Release_Plan_Format__c IN: selectedFormats AND Release_Plan_Language__c IN :selectedLanguage AND 
Release_Plan_Country__c IN:selectedCountry AND Release_Plan_Title__c IN :selectedTitle AND Client__c IN :selectedClient];*/
        
        Map<Id,client_avail__c> mapDateList2 = new Map<Id,client_avail__c>([SELECT Id, Client__c  
                                                                            , End_Date__c, Start_Date__c
                                                                            , Commercial_Avail__r.Start_Date__c ,Commercial_Avail__r.End_Date__c
                                                                            , Release_Plan_Channel__c, Release_Plan_Format__c
                                                                            , Release_Plan_Language__c, Release_Plan_Country__c, Release_Plan_Title__c
                                                                            ,Avail_Type__c,Title__c // ER: 10 : added Avail type in SOQL  
                                                                            FROM client_avail__c 
                                                                            WHERE Client__c IN :selectedClient 
                                                                            AND Commercial_Avail__c IN: selectedCommercialId]);
        list<client_avail__c> DateList= mapDateList2.values();                              
        //system.debug('print date'+DateList);
        
        //checking whether user's territory is equals to release plan country territory 
        //System.debug('@@@beforeflagReleaseMaintainer'+flagReleaseMaintainer);
        for(commercial_avail__C commers :selectedCommercialAvails){
            for(User u :userDetail){
                if(u.Profile.Name ==System.Label.WB_Territory_Release_Planner){
                    if (commers.Country_Lookup__r.Territory__c  != u.Territory__c){
                        flagReleaseMaintainer =true;
                    }   
                }
            }
        }
        //System.debug('@@@afterflagReleaseMaintainer'+flagReleaseMaintainer); 
        
        //code for manually creating client avail,when user doesn't enter the start date and end date,single client avail record
        
        for(integer n=0;n<lst_trigger_clientAvail.size();n++){
            if(lst_trigger_clientAvail[n].Start_Date__c ==Null && lst_trigger_clientAvail[n].End_Date__c == Null ){
                flagClientAvailstartEnd = true;
            }
        }
        
        //Code for date overlapp within the batch records
        /*   if(lst_trigger_clientAvail.size()>1){
for(integer i=0;i<lst_trigger_clientAvail.size() ;i++){
for(integer n =i+1 ; n< lst_trigger_clientAvail.size();i++){
if(lst_trigger_clientAvail[i].Client__c == lst_trigger_clientAvail[n].Client__c && lst_trigger_clientAvail[i].Commercial_Avail__c == lst_trigger_clientAvail[n].Commercial_Avail__c){
if(lst_trigger_clientAvail[i].Start_Date__c != null && lst_trigger_clientAvail[i].End_Date__c != null && lst_trigger_clientAvail[n].Start_Date__c != null && lst_trigger_clientAvail[n].End_Date__c != null){
if(lst_trigger_clientAvail[i].Start_Date__c > lst_trigger_clientAvail[n].End_Date__c || lst_trigger_clientAvail[i].End_Date__c <lst_trigger_clientAvail[n].Start_Date__c ){
}else{
lst_trigger_clientAvail[i].Start_Date__c.adderror('Date Overlap in the selected list of records') ;

}
}
}
}
}
}
*/
        
        if(flagReleaseMaintainer != true){
            
            for(integer n=0;n<lst_trigger_clientAvail.size();n++){      
                //added by shalini to include CA validations only when RP synch is off --for ER-000119
                //system.debug('lst_trigger_clientAvail[n].RP_Synch__c ======'+lst_trigger_clientAvail[n].RP_Synch__c);
                if(lst_trigger_clientAvail[n].RP_Synch__c == false){
                    for(Integer s =0;s<selectedCommercialAvails.size();s++){
                        //assigning the release plan values to client avail.
                        if(lst_trigger_clientAvail[n].Start_Date__c == null && lst_trigger_clientAvail[n].End_Date__c==null){
                            lst_trigger_clientAvail[n].Start_Date__c =selectedCommercialAvails[s].Start_Date__c;
                            lst_trigger_clientAvail[n].End_Date__c =selectedCommercialAvails[s].End_Date__c;
                        }
                        if(DateList.size()!= 0){
                            for(integer i=0;i<DateList.size();i++){
                                if(DateList[i].Commercial_Avail__c ==selectedCommercialAvails[s].Id 
                                   && lst_trigger_clientAvail[n].Commercial_Avail__c == selectedCommercialAvails[s].Id 
                                   && DateList[i].client__c == lst_trigger_clientAvail[n].client__c) 
                                {
                                    // added by rashmi on 7 dec2014
                                    //system.debug('lst_trigger_clientAvail[n].Start_Date__c' + lst_trigger_clientAvail[n].Start_Date__c);
                                    //system.debug('lst_trigger_clientAvail[n].End_Date__c' + lst_trigger_clientAvail[n].End_Date__c);
                                    //system.debug('DateList[i].Start_Date__c' + DateList[i].Start_Date__c); 
                                    //system.debug('DateList[i].End_Date__c' + DateList[i].End_Date__c);
                                    
                                    if(lst_trigger_clientAvail[n].Start_Date__c==DateList[i].Start_Date__c && lst_trigger_clientAvail[n].End_Date__c==DateList[i].End_Date__c && lst_trigger_clientAvail[n].Avail_Type__c==DateList[i].Avail_Type__c && lst_trigger_clientAvail[n].Title__c==DateList[i].Title__c) { // ER: 10 : Added condition for Episode and Season client avails            
                                        lst_trigger_clientAvail[n] .addError('Client avail is present with selected dates');                                     
                                    }
                                    else if(lst_trigger_clientAvail[n].Start_Date__c > lst_trigger_clientAvail[n].End_Date__c){ 
                                        // Criteria 1
                                        //system.debug('Criteria 1');
                                        //system.debug('lst_trigger_clientAvail[n].Start_Date__c' + lst_trigger_clientAvail[n].Start_Date__c);    
                                        lst_trigger_clientAvail[n].Start_Date__c.adderror('Start date cannot be greater than End date');
                                    }
                                    else if(!((lst_trigger_clientAvail[n].Start_Date__c >= DateList[i].End_Date__c)||(lst_trigger_clientAvail[n].End_Date__c <=DateList[i].Start_Date__c )) && lst_trigger_clientAvail[n].Avail_Type__c != 'Automated'){ // ER-10 : Added Avail Type condition
                                        //system.debug('common Criteria in update');
                                        lst_trigger_clientAvail[n].Start_Date__c.adderror('Start date is overlapping with existing record');
                                        lst_trigger_clientAvail[n].End_Date__c.adderror('End date is overlapping with existing record');
                                        //system.debug('lst_trigger_clientAvail[n].Start_Date__c' + lst_trigger_clientAvail[n].Start_Date__c);
                                        //system.debug('DateList[i].End_Date__c' + DateList[i].End_Date__c);
                                        //system.debug('lst_trigger_clientAvail[n].End_Date__c' + lst_trigger_clientAvail[n].End_Date__c);
                                        //system.debug('DateList[i].Start_Date__c' + DateList[i].Start_Date__c);
                                    }
                                    
                                    else if(!((selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].Start_Date__c 
                                               && lst_trigger_clientAvail[n].Start_Date__c <= selectedCommercialAvails[s].End_Date__c)
                                              && (selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].End_Date__c 
                                                  && lst_trigger_clientAvail[n].End_Date__c <= selectedCommercialAvails[s].End_Date__c)) 
                                            && (lst_trigger_clientAvail[n].Avail_Type__c != 'Automated' || lst_trigger_clientAvail[n].Avail_Type__c == null || lst_trigger_clientAvail[n].Avail_Type__c == ''))  // ER-10 : Added Avail Type condition
                                    { 
                                        //system.debug('date is greater than end of commercial avail loop1');
                                        //system.debug('selectedCommercialAvails[s].Start_Date__c-- loop1' + selectedCommercialAvails[s].Start_Date__c);
                                        //system.debug('selectedCommercialAvails[s].End_Date__c-- loop1' + selectedCommercialAvails[s].End_Date__c);         
                                        //system.debug('lst_trigger_clientAvail[n].Start_Date__c-- loop1' + lst_trigger_clientAvail[n].Start_Date__c); 
                                        //system.debug('lst_trigger_clientAvail[n].End_Date__c-- loop1' + lst_trigger_clientAvail[n].End_Date__c);         
                                        lst_trigger_clientAvail[n].Start_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                        lst_trigger_clientAvail[n].End_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                    }
                                }
                            }
                        }else {  
                            
                            if(lst_trigger_clientAvail[n].Commercial_Avail__c == selectedCommercialAvails[s].Id ) { 
                                
                                if  (!((selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].Start_Date__c
                                        && lst_trigger_clientAvail[n].Start_Date__c <= selectedCommercialAvails[s].End_Date__c)
                                       && (selectedCommercialAvails[s].Start_Date__c <= lst_trigger_clientAvail[n].End_Date__c 
                                           && lst_trigger_clientAvail[n].End_Date__c <= selectedCommercialAvails[s].End_Date__c))) 
                                { 
                                    //system.debug('date is greate than end of commercial avail loop2');
                                    //system.debug('selectedCommercialAvails[s].Start_Date__c---loop2' + selectedCommercialAvails[s].Start_Date__c);
                                    //system.debug('selectedCommercialAvails[s].End_Date__c---loop2' + selectedCommercialAvails[s].End_Date__c);         
                                    //system.debug('lst_trigger_clientAvail[n].Start_Date__c---loop2' + lst_trigger_clientAvail[n].Start_Date__c); 
                                    //system.debug('lst_trigger_clientAvail[n].End_Date__c---loop2' + lst_trigger_clientAvail[n].End_Date__c);   
                                    //Removed hardcoded index for SINC0955653
                                    lst_trigger_clientAvail[n].Start_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                    lst_trigger_clientAvail[n].End_Date__c.adderror('Client Avails Dates must be between Release Plan Dates');
                                }   
                            }
                        }    
                    }
                }
            }  
        }   
        else 
            lst_trigger_clientAvail[0] .addError('Client avail for this Release plan cannot be created'); // only applicable when Client is created through standard way
        
        selectedCommercialAvails.clear();
        DateList.clear();
        selectedChannels.clear();
        selectedFormats.clear();
        selectedLanguage.clear();    
        selectedCountry.clear();
    }
    // End of function  
    
    public static void deleteClientAvail(List<Client_Avail__c> caList){
        
        List<Client_Avail__c> caListToUpdate  = new List<Client_Avail__c>();
        List<Id> childCAListToDelete  = new List<Id>();
        // Delete client avail before it is announced by profiles;Global Title Planner, Territory Release Planners and Client Avail Planners 
        set<Id> setClientAvailIds = new set<Id>();
        //list<User> userDetail = new list<User>();
        //userDetail =[Select id,ProfileId,Profile.Name,UserType,Territory__c  from User where id =: Userinfo.getUserId() ];  
        
        try{
            Map<Id,List<Announcement_Record__c>> clientAvailAnnouncementMap = new Map<Id,List<Announcement_Record__c>>();
            List<Announcement_Record__c> announcementRecordLst = new List<Announcement_Record__c>();
            for (Client_Avail__c carec : caList){
                setClientAvailIds.add(carec.id);
            }
            
            //ER-1289 Cascade Delete from Season to Episode 
            Map<Id,List<Client_Avail__c>> mapChildClientAvails = new Map<Id,List<Client_Avail__c>>();
            for(Client_Avail__c childCA : [SELECT id,Status__C,Title__c,Name,Parent_Client_Avail__c,Title_Content_Type__c from Client_Avail__c where Parent_Client_Avail__c IN : setClientAvailIds AND Title_Content_Type__c =: 'Episode'])
            {
                if(!mapChildClientAvails.containsKey(childCA.Parent_Client_Avail__c))
                    mapChildClientAvails.put(childCA.Parent_Client_Avail__c,new List<Client_Avail__c>());
                mapChildClientAvails.get(childCA.Parent_Client_Avail__c).add(childCA);
            }
            
            Map<Id,Announcement_Record__c> mapAnnouncementRecordLst = new Map<Id,Announcement_Record__c>([select id, name, client_avail__c from Announcement_Record__c where client_avail__c in :setClientAvailIds]);
            if(mapAnnouncementRecordLst.size()>0)
                announcementRecordLst = mapAnnouncementRecordLst.values();
            
            if(announcementRecordLst != Null && announcementRecordLst.size()>0){   
                for(Announcement_Record__c announcement : announcementRecordLst ){
                    
                    if(!clientAvailAnnouncementMap.containsKey(announcement.Client_Avail__c)){
                        List<Announcement_Record__c> announcementLst = new List<Announcement_Record__c>();
                        announcementLst.add(announcement) ;   
                        clientAvailAnnouncementMap.put(announcement.Client_Avail__c, announcementLst);
                    }
                    else{
                        clientAvailAnnouncementMap.get(announcement.Client_Avail__c).add(announcement);
                    }
                }
            }
            
            for(Client_Avail__c ca : caList){
                if(clientAvailAnnouncementMap.get(ca.id) !=null && clientAvailAnnouncementMap.get(ca.id).size() > 0){
                    ca.addError('Client Avail cannot be deleted as it has associated Announcement Records ');
                }else if(mapChildClientAvails!=null && mapChildClientAvails.size()>0){      //ER-1289 Cascade Delete from Season to Episode
                    List<Client_Avail__c> childCARec = mapChildClientAvails.get(ca.Id);
                    if(childCARec != null && childCARec.size()>0){
                        for(Client_Avail__c childCA : childCARec){
                            //System.debug(LoggingLevel.INFO,'####CA to be deleted:'+childCA.Name);
                            //System.debug(LoggingLevel.INFO,'####CA Content Type:'+childCA.Title_Content_Type__c);
                            childCAListToDelete.add(childCA.Id);
                        }
                    }
                    
                    
                }
            }
            
            //ER-1289 Cascade Delete from Season to Episode
            if(childCAListToDelete != null && childCAListToDelete.size()>0){
                Database.DeleteResult[] deleteResult = Database.delete(childCAListToDelete, false);
                for(Integer index=0;index<deleteResult.size();index++){
                    Database.DeleteResult deleteResultRec = deleteResult[index]; 
                    if(!deleteResultRec.isSuccess()){
                        for(Database.Error err : deleteResultRec.getErrors()) {
                            System.debug(LoggingLevel.INFO,'Delete CAP Result Error ->'+ err.getMessage());
                        }
                    }
                }
            }
            
        }catch(Exception Ex){
            system.debug('Exception :'+Ex);
        }
    }//end deleteClientAvail
    
    
    //ER-820 (post implementation changes): Moved Client Avails Workflow field updates into trigger
    public static void CalculateAPODate(List<Client_Avail__c> listClientAvail, map<Id,Client_Avail__c> oldMap){
        for(Client_Avail__c CA : listClientAvail) 
        {
            if(trigger.isBefore)
            { 
                
                if(trigger.isinsert || trigger.isupdate){
                    
                    if(trigger.isinsert){
                        //Episode Price Tier to default to TBD
                        if(CA.Title_Content_Type__c == 'Season' && CA.Episode_Price__c == NULL && String.isBlank(CA.Episode_Price_Tier__c))
                            CA.Episode_Price_Tier__c = 'TBD';
                        
                        //Update new Season Client Avail Confirmed To Tentative
                        /*if(CA.Status__c == 'Confirmed' && CA.Playlist__c != NULL  && CA.Title_Content_Type__c != 'Season')
CA.Status__c = 'Tentative';*/
                        //SINC1717532 - With valid Episode Price Tier or WSP value allow user to create CA with confimred status
                        if(CA.Status__c == 'Confirmed' && CA.Episode_Price_Tier__c == 'TBD'){
                            CA.Status__c = 'Tentative';
                        }    
                    }
                    
                    //Calculate APO Date
                    if(CA.APO__c == 'Yes'){
                        if(trigger.isUpdate){
                            if(CA.APO_Date__c != oldMap.get(CA.Id).APO_Date__c){
                                CA.addError('Pre-Order date can\'t be changed when APO flag is Yes.');
                            }
                        }
                        
                        //APO_Date__c
                        if(CA.APO_Date_Override__c != NULL)
                            CA.APO_Date__c = CA.APO_Date_Override__c;
                        else if(CA.Local_Title_Theatrical_Release__c != NULL){
                            //system.debug('CA.APO_Days_Override__c*****'+CA.APO_Days_Override__c);
                            if(CA.APO_Days_Override__c != NULL)
                                CA.APO_Date__c = CA.Local_Title_Theatrical_Release__c.addDays(CA.APO_Days_Override__c.intValue());
                            else
                                CA.APO_Date__c = CA.Local_Title_Theatrical_Release__c;
                        }
                        
                        //ER-004240 - Turn off APO when TRD is blank
                        Integer  diffDate = Date.today().daysBetween(CA.Start_Date__c);                            
                        if(CA.APO_Date_Override__c == NULL && CA.Release_Plan_Channel__c == 'EST' && 
                            diffDate > 0 && CA.Local_Title_Theatrical_Release__c == NULL){ //diffDate greater than 0 means Avails Start Date is in Future
                                CA.APO__c = NULL;
                                CA.APO_Date__c = NULL;
                                CA.Announce_Date__c = NULL;
                        }
                         
                        //SINC1036263 - Updated on 28 jun,17
                        //Calculate Suppression End Date
                        if(CA.fCommercial_Avail_APO__c == 'Yes' &&  CA.fStorefront_APO__c == 'Yes') 
                        {
                            //Calculate Suppression End Date
                            if(CA.Suppression_Date_Override__c != NULL){
                                CA.Announce_Date__c = CA.Suppression_Date_Override__c;
                            }
                            else 
                            {
                                if(CA.Start_Date__c == NULL && CA.Local_Title_Theatrical_Release__c != NULL){
                                    CA.Announce_Date__c = CA.Local_Title_Theatrical_Release__c.addDays(90);
                                }
                                else
                                {
                                    if(CA.Suppression_Days_Override_Formula__c != NULL)
                                        CA.Announce_Date__c = CA.Start_Date__c.addDays(- (CA.Suppression_Days_Override_Formula__c.intValue()));
                                    else
                                        CA.Announce_Date__c = CA.Start_Date__c;
                                }
                            }
                            //Update Suppression Days Override
                            if(CA.Suppression_Days_Override__c == NULL && CA.Suppression_Days_Override_Formula__c != NULL){
                                CA.Suppression_Days_Override__c = CA.Suppression_Days_Override_Formula__c;
                            }
                        }
                        
                    }
                    //Remove APO Fields
                    if(trigger.isupdate)
                    {
                        if((CA.APO__c == ''|| CA.APO__c == NULL) && oldMap.get(CA.Id).APO__c == 'Yes')
                        {
                            CA.APO_Date__c = NULL;
                            CA.APO_Days_Override__c = NULL;
                            CA.Suppression_Date_Override__c = NULL;
                            CA.Suppression_Days_Override__c = NULL;
                            CA.Announce_Date__c = NULL;
                            CA.APO_Date_Override__c = NULL;
                        }
                    }
                }
            }
        }
    }
    
    // ER-10 methods added by Prachi
    // Set flag to Ready to Process if Client avail inserted with Playlist value.
    // Set Title field with Release plan title if Title is null.
    public static void RecalculatePlaylistFlagBeforeInsert(List<Client_Avail__c> listClientAvail)
    {
        //system.debug('####******'+listClientAvail); 
        set<Id> releasePlanIds = new set<Id>();
        Boolean callBatch = false;
        for(Client_Avail__c clientAvail : listClientAvail)
        {
            if(clientAvail.Title__c == null || clientAvail.Local_Title__c == null)
                releasePlanIds.add(clientAvail.Commercial_Avail__c);
        }
        
        Map<Id,Commercial_Avail__c> mapReleaseplans = new Map<Id,Commercial_Avail__c>([Select id,Title__c,Local_Title__r.Playlist__C,Playlist__C,Title__r.Content_Type__C,Local_Title__c 
                                                                                       FROM Commercial_Avail__c where id in: releasePlanIds]);
        for(Client_Avail__c clientAvail : listClientAvail)
        {
            if(mapReleaseplans.containskey(clientAvail.Commercial_Avail__c) 
               && mapReleaseplans.get(clientAvail.Commercial_Avail__c).Title__r.Content_Type__C == 'Season')
            {
                if(clientAvail.Playlist__c != null || mapReleaseplans.get(clientAvail.Commercial_Avail__c).Playlist__C != null)
                {
                    Set<String> listPossibleStatus = new Set<String>(Label.WB_Client_Avail_Status.split(','));
                    if(listPossibleStatus.contains(clientAvail.Status__c))
                    {
                        clientAvail.Recalculate_Playlist_Avails__c = 'Insert';
                        clientAvail.Recalculation_Status__c=false;
                        callBatch = true;
                    }
                    if(clientAvail.Playlist__c == null && clientAvail.Title__c == null)
                        clientAvail.Playlist__c = mapReleaseplans.get(clientAvail.Commercial_Avail__c).Playlist__C;
                }
            }
            if(clientAvail.Title__c == null)
                clientAvail.Title__c = mapReleaseplans.get(clientAvail.Commercial_Avail__c).Title__c;
            if(clientAvail.Local_Title__c == null)
                clientAvail.Local_Title__c = mapReleaseplans.get(clientAvail.Commercial_Avail__c).Local_Title__c;
            // ER-606 : If Playlist is null on CA, Copy Playlist value from release plan .
            if(clientAvail.Playlist__c == null 
               && mapReleaseplans.containskey(clientAvail.Commercial_Avail__c) 
               && mapReleaseplans.get(clientAvail.Commercial_Avail__c).Playlist__C != null) 
                clientAvail.Playlist__c = mapReleaseplans.get(clientAvail.Commercial_Avail__c).Playlist__C;
            //ER-1524
            if(clientAvail.Title_Content_Type__c == 'Collection Features' && clientAvail.Playlist__c != NULL){
                clientAvail.Recalculate_Playlist_Avails__c = 'Insert';
                clientAvail.Recalculation_Status__c=false;
                callBatch = true;
            }
        }
        //system.debug('***********listClientAvail***********'+listClientAvail);
        if(callBatch && !system.isBatch()){
            Datetime ScheduleTime = system.now().addSeconds(40);
            String cronExp = ScheduleTime.second()+' '+ScheduleTime.minute()+' '+ScheduleTime.hour()+' '+ScheduleTime.day()+' '+ScheduleTime.month()+' ? '+ScheduleTime.year();
            String SchedulerName = 'EAs:'+system.now() + ' ' + system.now().millisecond() +' I';//+' '+userinfo.get();
            Id scheduleid = System.schedule(SchedulerName, cronExp, new WB_Batch_Playlist_Mgmt_Process(SchedulerName));
            Episode_Avails_Scheduler__c csetting = new Episode_Avails_Scheduler__c(name = SchedulerName,Scheduler_id__c=scheduleid);
            insert csetting;
        }
    }
    
    //ER-10 : 
    // Reset flag to Ready to Process if Playlist value changed. Set Title field with Release plan title if Title is null.
    public static void RecalculatePlaylistFlagBeforeUpdate(List<Client_Avail__c> listClientAvail)
    {   
        set<Id> releasePlanIds = new set<Id>();
        //set<Id> clientAvailIds = new set<Id>();
        Boolean callBatch = false;
        for(Client_Avail__c clientAvail : listClientAvail)
        {
            /*-----------ER-820: START------------------*/
            if(clientAvail.Recalculate_Playlist_Avails__c == 'Update Episode Avails' && clientAvail.Recalculation_Status__c == false)
                callBatch = true;
            /*----------ER-820: END---------------------*/
            Client_Avail__c oldCARecord = (Client_Avail__c)trigger.oldmap.get(clientAvail.id);
            Set<String> listPossibleStatus = new Set<String>(Label.WB_Client_Avail_Status.split(','));
            if(clientAvail.Playlist__c != oldCARecord.Playlist__c && listPossibleStatus.contains(clientAvail.Status__c) && (clientAvail.Title_Content_Type__c == 'Season' || clientAvail.Title_Content_Type__c == 'Collection Features' )) // ER 606 : set recalculation flag if Content type should be season 
            {
                //clientAvailIds.add(clientAvail.id);
                clientAvail.Recalculate_Playlist_Avails__c = 'Update Playlist';
                clientAvail.Recalculation_Status__c=false;
                callBatch = true;
            }
            if(clientAvail.Title__c == null || clientAvail.Local_Title__c == null)
                releasePlanIds.add(clientAvail.Commercial_Avail__c);
            
        }
        Map<Id,Commercial_Avail__c> mapReleaseplans = new Map<Id,Commercial_Avail__c>([Select id,Title__c,Local_Title__c from Commercial_Avail__c where id in: releasePlanIds]);
        for(Client_Avail__c clientAvail : listClientAvail)
        {
            if(clientAvail.Title__c == null)
                clientAvail.Title__c = mapReleaseplans.get(clientAvail.Commercial_Avail__c).Title__c;
            if(clientAvail.Local_Title__c == null)
                clientAvail.Local_Title__c = mapReleaseplans.get(clientAvail.Commercial_Avail__c).Local_Title__c;
        }
        if(callBatch && !system.isBatch()){
            Datetime ScheduleTime = system.now().addSeconds(40);
            String cronExp = ScheduleTime.second()+' '+ScheduleTime.minute()+' '+ScheduleTime.hour()+' '+ScheduleTime.day()+' '+ScheduleTime.month()+' ? '+ScheduleTime.year();
            String SchedulerName = 'EAs:'+system.now() + ' ' + system.now().millisecond() +' U';//+' '+userinfo.getUserId();
            Id scheduleid = System.schedule(SchedulerName, cronExp, new WB_Batch_Playlist_Mgmt_Process(SchedulerName));
            Episode_Avails_Scheduler__c csetting = new Episode_Avails_Scheduler__c(name = SchedulerName,Scheduler_id__c=scheduleid);
            insert csetting;
        }
        
    }
    
    
    //ER-10 :  Change status of episode client avails if Status changed for Season title client avails.
    public static void ChangeEpisodeCAFields(List<Client_Avail__c> listClientAvails, Map<Id,Client_Avail__c> newMapAvails)
    {
        Boolean errorFlag = false;
        Boolean pendingEpisodeActivity = false;
        Set<Id> availIds = new Set<Id>();
        for(Client_Avail__c clientAvail : listClientAvails)
        {
            Client_Avail__c oldCARecord = (Client_Avail__c)trigger.oldmap.get(clientAvail.id);
            if((clientAvail.Status__c != oldCARecord.Status__c || 
                clientAvail.Start_Date__c != oldCARecord.Start_Date__c ||
                clientAvail.End_Date__C != oldCARecord.End_Date__C 
                //clientAvail.Price_Tier_Text__c != oldCARecord.Price_Tier_Text__c ||
                //clientAvail.SR_Price__c != oldCARecord.SR_Price__c ||
                //clientAvail.Price__c != oldCARecord.Price__c ||
                //clientAvail.Episode_Price_Tier__c != oldCARecord.Episode_Price_Tier__c ||
                //clientAvail.Episode_Price__c != oldCARecord.Episode_Price__c
               ) && clientAvail.Title_Content_Type__c == 'Season' && clientAvail.Playlist__c != null)
                availIds.add(clientAvail.id);
            /*
else if(oldCARecord.Recalculate_Playlist_Avails__c != null && oldCARecord.Recalculate_Playlist_Avails__c != '' && oldCARecord.Recalculate_Playlist_Avails__c != 'Insert'){
pendingEpisodeActivity = true;
clientAvail.addError('Another episode activity is pending for the client avail...please try again in 10 mins ');
break;
}
*/
        }
        
        if(availIds.size() > 0)
        {
            //system.debug(LoggingLevel.Info,'availIds******'+availIds);
            List<Client_Avail__c> childEpisodeClientAvails = [Select id, Price_Tier_Text__c, Parent_Client_Avail__c, Start_Date__c, End_Date__c, Status__c, 
                                                              Lock_Pricing_Update__c
                                                              FROM Client_Avail__c 
                                                              where Title_Content_Type__c = 'Episode' 
                                                              AND Local_Data_Category_Picklist__c LIKE 'TV%' AND Parent_Client_Avail__c in: availIds];
            if(childEpisodeClientAvails != null && childEpisodeClientAvails.size() > 0)
                for(Client_Avail__c clientAvail : childEpisodeClientAvails)
            {
                if(
                    (newMapAvails.get(clientAvail.Parent_Client_Avail__c).Status__c == 'Confirmed' && clientAvail.Start_Date__c != clientAvail.End_Date__c && 
                     clientAvail.Lock_Pricing_Update__c == false && newMapAvails.get(clientAvail.Parent_Client_Avail__c).Episode_Price_Tier__c != NULL && 
                     newMapAvails.get(clientAvail.Parent_Client_Avail__c).Episode_Price_Tier__c.tolowerCase() == 'tbd')
                    ||
                    (newMapAvails.get(clientAvail.Parent_Client_Avail__c).Status__c == 'Confirmed' && clientAvail.Start_Date__c != clientAvail.End_Date__c && 
                     clientAvail.Lock_Pricing_Update__c == true && clientAvail.Price_Tier_Text__c != NULL && clientAvail.Price_Tier_Text__c.tolowerCase() == 'tbd')
                )
                {
                    errorFlag = true;
                    break;
                }
            }
            
        }
        
        if(!errorFlag)
        {
            for(Client_Avail__c ca : listClientAvails){
                Client_Avail__c oldCARecord = (Client_Avail__c)trigger.oldmap.get(ca.id);
                if(availIds.contains(ca.Id) && oldCARecord.Recalculate_Playlist_Avails__c != 'Insert')
                {
                    ca.Recalculate_Playlist_Avails__c = 'Update Episode Avails';
                    ca.Recalculation_Status__c = false;
                }
            }
            
        }
        else
            for(Client_Avail__c ca : listClientAvails)
            ca.addError('Season Avails with a Playlist cannot be confirmed with a TBD Episode Price Tier.');
    }
    
    //ER-006802 -- Round CA WSP price to 2 decimal places on insert 
	public static void roundPricingtwoDigit(List<Client_Avail__c> lstCARecords){        
    	for(Client_Avail__c caRecordBeforeInsert:lstCARecords){  
         	Decimal wsp = caRecordBeforeInsert.Price__c;
         	Decimal episodeWsp=caRecordBeforeInsert.Episode_Price__c;
        	if(wsp != NULL && wsp.scale()>2 ){          
                Decimal roundedWSP = wsp.setScale(2);
                caRecordBeforeInsert.Price__c = roundedWSP;            
        	}
        	if(episodeWsp != NULL && episodeWsp.scale()>2){            
                Decimal roundedEpisodeWSP = episodeWsp.setScale(2);
                caRecordBeforeInsert.Episode_Price__c = roundedEpisodeWSP;
        	} 
    	}  
	}
	//ER-006802
}