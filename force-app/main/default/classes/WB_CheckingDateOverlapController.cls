/******* 
Name:WB_CheckingDateOverlapController
Creation Date- 03 Sept 2014
Last Modified Date - 05 Sept 2014
Last Modified by  - Tejas
Description- This is trigger class to check whether entered date is getting overlapped with existing commercial avail record.
Author- Tejas Mulye
*******/

public class WB_CheckingDateOverlapController{
    public static boolean isFirstTime = true;
    public static boolean isRunning_BatchMRMRollup = false; 
    
    public static void Chkoverlap_beforeupdate()
    {
        list<User> userDetail = new list<User>();
        //added by shalini for ER-119
        list<Commercial_Avail__c> lst_selectedcommercial_aval = new list<Commercial_Avail__c>();
        list<Commercial_Avail__c> lst_trigger_avail = new list<Commercial_Avail__c>();
        list<Commercial_Avail__c> lst_oldtrigger_avail = new list<Commercial_Avail__c>();
        list<Client_Avail__c> lst_client_avail = new list<Client_Avail__c>(); // Added by Tejas 31 Oct
        
        list<string> lst_selectedtitle = new list<string>(); 
        list<string> lst_selectedcountry = new list<string>();
        list<string> lst_selectedchannel = new list<string>();
        list<string> lst_selectedformat = new list<string>();
        list<string> lst_selectedlanguage = new list<string>();
        list<string> lst_selectedlanguagetype = new list<string>();//ER-359
        list<string> lst_selectedId = new list<string>();
        list<Available_Languages__c> lst_available_languages = new list<Available_Languages__c>();
        list<string> lst_titles = new list<string>();
        
        map<id,set<string>> map_languages = new map<id,set<string>>();
        map<id,set<string>> map_languagesType = new map<id,set<string>>();
        
        Set<id> validatedRps = new Set<id>();           //Added for SINC - Prevent duplicates 08/29
        
        boolean nochangeFlag= true;
        boolean flagReleaseMaintainer =false;
        
        lst_trigger_avail = trigger.new;
        lst_oldtrigger_avail = trigger.old;
        
        /*Migraated Workflow Logic For Field Update - Start*/
        for(Commercial_Avail__c cAvail : lst_trigger_avail)
        {
            cAvail.zTitleStudio_Search__c = cAvail.fTitleStudio_Search__c;
            cAvail.zReleasePlanLookup_Title__c = cAvail.fReleasePlanLookup_Title__c;
        }
        /*Migraated Workflow Logic For Field Update - End*/
        
        for(integer i=0;i<lst_trigger_avail.size();i++){
            
            lst_selectedtitle.add(lst_trigger_avail[i].Title__c);
            lst_selectedcountry.add(lst_trigger_avail[i].Country_Lookup__c);
            lst_selectedchannel.add(lst_trigger_avail[i].Channel__c);
            lst_selectedformat.add(lst_trigger_avail[i].Format__c);
            lst_selectedlanguage.add(lst_trigger_avail[i].Languages__c);
            lst_selectedId.add(lst_trigger_avail[i].Id);
            lst_selectedlanguagetype.add(lst_trigger_avail[i].Language_Type__c);//ER-359
        }
        set<string> availLangList= new set<string>();
        set<string> availLangTypeList= new set<string>();
        
        /*Start A : Validate the Language and Language type of CA with that of Title*/
        //Below map -> map<Title_Id, map<TitleLangId, LangType>>
        map<Id, map<Id, set<String>>> titleLanguageMap = new map<Id, map<Id, set<String>>>();
        
        for(Available_Languages__c AL : [SELECT Id, Title__c, Language__c, Language_Types__c, Language__r.name, Provisional__c FROM Available_Languages__c WHERE Title__c = :lst_selectedtitle and (Clear_To_Avail__c=true or Provisional__c = true)])
        {
            // CAS2 dev team : Added logic to set the lang type as Sub & Audio if 2 records found for matching Language by CAS2 dev team
            if(titleLanguageMap.containsKey(AL.Title__c)){
                /*map<Id, String> langMap = titleLanguageMap.get(AL.Title__c);
langMap.put(AL.Language__c, AL.Language_Types__c);
titleLanguageMap.put(AL.Title__c,langMap);*/
                if(titleLanguageMap.get(AL.Title__c).containskey(AL.Language__c)){
                    if(!AL.Provisional__c)
                        titleLanguageMap.get(AL.Title__c).get(AL.Language__c).add(AL.Language_Types__c);
                    else
                        titleLanguageMap.get(AL.Title__c).get(AL.Language__c).add('Provisional');
                }
                else
                {
                    titleLanguageMap.get(AL.Title__c).put(AL.Language__c,new set<String>());   
                    if(!AL.Provisional__c)
                        titleLanguageMap.get(AL.Title__c).get(AL.Language__c).add(AL.Language_Types__c);
                    else
                        titleLanguageMap.get(AL.Title__c).get(AL.Language__c).add('Provisional');
                }
                //END           
            }
            else{
                map<Id, set<String>> langMap = new map<Id, set<String>>();
                langMap.put(AL.Language__c, new set<String>());
                if(!AL.Provisional__c)
                    langMap.get(AL.Language__c).add(AL.Language_Types__c);
                else
                    langMap.get(AL.Language__c).add('Provisional');
                titleLanguageMap.put(AL.Title__c,langMap);
            }
        }
        


       // ER-006700--Start  
       Map<Id,Title__c> mapIdTitle = null;
       Boolean releasePlannerUsrFlag = false;
        //WB - Territory Avail Planner profile & permission set Ids
        Set<String> territoryRPIds = new Set<String>(System.Label.WB_Territory_Avail_Planner_IDs.split(';')); 

        //Profile check for logged in User
        if(territoryRPIds.contains(userinfo.getProfileId())){   
            releasePlannerUsrFlag =true;
        }

        //PermissionSet check for logged in User
        if(!releasePlannerUsrFlag){
          for(PermissionSetAssignment psa : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userinfo.getUserId()]){
                if(territoryRPIds.contains(psa.PermissionSetId)){
                    releasePlannerUsrFlag = true;
                }
          }
         }
          
        if(releasePlannerUsrFlag){
            mapIdTitle = new Map<Id,Title__c>([SELECT Id,Territory__c FROM Title__c WHERE Id IN :lst_selectedtitle LIMIT 50000]);
        }
       // ER-006700--End   
       
        for(Commercial_Avail__c CA : lst_trigger_avail){

            // ER-006700--Start   
            if(releasePlannerUsrFlag == true && mapIdTitle.containsKey(CA.Title__c)){
                Title__c ttl = mapIdTitle.get(CA.Title__c);
                if(CA.User_Territory__c != ttl.Territory__c){
                  CA.addError(System.Label.RP_Update_Error_Msg_For_Territory_Avail_Planner_Users);
                }
          }  
        // ER-006700--End   


            //Only if status is changed to Tentative or Confirmed
            Commercial_Avail__c oldCA = (Commercial_Avail__c)trigger.oldMap.get(CA.Id);
            if(CA.Status__c != oldCA.Status__c && (CA.Status__c == 'Tentative' || CA.Status__c == 'Confirmed'))
            {
                map<Id, set<String>> langMap = titleLanguageMap.get(CA.Title__c);
                if(langMap == Null) // Title does not have any available language
                {
                    CA.addError('There is no available language for the selected title!');
                }
                else
                {
                    if(!langMap.containsKey(CA.Languages__c)) //If Language is not in Available Langs of Title
                    {
                        CA.addError('Language is not matching with Available languages in Title');
                    }
                    else 
                    {   
                        if(CA.Language_Type__c == 'Sub & Audio')
                        {
                            if( langMap.get(CA.Languages__c).size() < 2)
                                CA.addError('Language type is not matching with Available languages in Title');
                        }
                        else if(!langMap.get(CA.Languages__c).contains(CA.Language_Type__c)) //If Language Type doesnt match with Available Lang in Title
                        {
                            CA.addError('Language type is not matching with Available languages in Title');
                        }
                    }
                }
            }
        }
        /*END A*/
        
        /*lst_available_languages = [SELECT Id,Title__c,Language__c,Language_Types__c FROM Available_Languages__c WHERE Title__c =: lst_selectedtitle];

for(string titleList: lst_selectedtitle){
for(integer i=0;i<lst_available_languages .size();i++){
if(titleList == lst_available_languages[i].Title__c){
availLangList.add(lst_available_languages[i].Language__c);
availLangTypeList.add(lst_available_languages[i].Language_Types__c );
//map_languages.put(lst_available_languages[i].Title__c,lst_available_languages[i].Language__c);
//map_languagesType.put(lst_available_languages[i].Title__c,lst_available_languages[i].Language_Types__c);
}
}
map_languages.put(titleList,availLangList);
map_languagesType.put(titleList,availLangTypeList);   
}
*/
        
        if(!WB_FixLanguageUtility.isFixUtility){//CRRT Pahse7: Avoid this validation for Fix Language Utility functionality
            for(Integer i =0;i<lst_trigger_avail.size();i++){
                if(    (lst_trigger_avail[i].Channel__c!=lst_oldtrigger_avail[i].Channel__c
                        || lst_trigger_avail[i].Format__c!=lst_oldtrigger_avail[i].Format__c
                        || lst_trigger_avail[i].Country_Lookup__c!=lst_oldtrigger_avail[i].Country_Lookup__c
                        || lst_trigger_avail[i].Languages__c!=lst_oldtrigger_avail[i].Languages__c) && !validatedRps.contains(lst_trigger_avail[i].id)
                   // || lst_trigger_avail[i].Language_Type__c!=lst_oldtrigger_avail[i].Language_Type__c//ER-359
                  ){
                      //lst_trigger_avail[i].adderror('You cannot modify Country/Language/Channel/Format/Language Type');
                      lst_trigger_avail[i].adderror('You cannot modify Country/Language/Channel/Format');
                      validatedRps.add(lst_trigger_avail[i].id);
                      //nochangeFlag = false;                 //Flag removed for SINC - Prevent duplicates 08/29
                  }
                
                /* if(lst_oldtrigger_avail[i].Reason_Code__c=='Language Not Available' && (lst_trigger_avail[i].Status__c=='Tentative' || lst_trigger_avail[i].Status__c=='Confirmed')){
for(integer j=0;j<lst_available_languages.size();j++){                     
if(lst_trigger_avail[i].Language_Type__c != lst_available_languages[j].Language_Types__c &&
lst_trigger_avail[i].Languages__c != lst_available_languages[j].Language__c ){
if(!(map_languages.get(lst_trigger_avail[i].Title__c).contains(lst_trigger_avail[i].Languages__c) &&
map_languagesType.get(lst_trigger_avail[i].Title__c).contains(lst_trigger_avail[i].Language_Type__c))){

lst_trigger_avail[i].adderror('You cannot modify Status');
}
}
}   
}*/
            }  
        }
        
        //User Info validation for release maitainer profile
        //userDetail = [SELECT id,ProfileId,Profile.Name,UserType,Territory__c from User where id =: Userinfo.getUserId()];         //Commenting the query as associated usage has been previously commented 08/29
        
        //List<Country__c> countryDetail = [Select id,name,Territory__c FROM Country__c where Territory__c =:userDetail[0].Territory__c];         //Commenting the query as associated usage has been previously commented 08/29
        
        /* ER-000081  Added by shalini to validate Ttitle's territory 
Mahesh - Commented below block from line 145 to 193 for deployment of ER-119 and to avoid deployment of ER-81 * /
List<Title__c> titleDetail = [Select id,name,Territory__c FROM Title__c where Territory__c =:userDetail[0].Territory__c and id in:lst_selectedtitle];       

if(userDetail[0].Profile.Name==System.Label.WB_Territory_Release_Planner){

for(Commercial_Avail__c releasePlan:lst_trigger_avail){
integer countCountryTerr=0;
for(Country__c con:countryDetail){
if(releasePlan.Country_Lookup__c==con.ID){
countCountryTerr++;
}
}
if(countCountryTerr==0){
//releasePlan.Country_Lookup__c.addError('Selected Country’s territory does not match with logged in user’s territory');
}

/* Start - Added by shalini to validate Title's territory* /
integer countTitleTerr=0;
for(Title__c title : titleDetail){
if(releasePlan.Title__c == title.ID){
countTitleTerr++;
}
}
if(countTitleTerr==0){
releasePlan.Title__c.addError('Selected Title’s territory does not match with logged in user’s territory');
}
/* End - Added by shalini to validate Title's territory* /
}

/* Added by shalini to validate Title's territory*
for(Commercial_Avail__c releasePlan:lst_trigger_avail){
integer countTitleTerr=0;
for(Title__c title:titleDetail){
if(releasePlan.Title__c==title.ID){
countTitleTerr++;
}
}
if(countTitleTerr==0){
If(WB_SplitReleaseplanController.bypassTerritoryTitleValidationFromTrigger == false){
releasePlan.Title__c.addError('Selected Title’s territory does not match with logged in user’s territory');
}
}
}
* /
}
*/
        // End new logic
        
        /*
//SINC0596533 Start
userDetail = [SELECT id,ProfileId,Profile.Name,UserType,Territory__c from User where id =: Userinfo.getUserId()];       
Set<ID> setRRP = new Set<ID>();
for(Commercial_Avail__c rp : lst_trigger_avail){
setRRP.add(rp.Id);
}
Map<ID, Commercial_Avail__c> mapRPTitleTerritory  = new Map<ID, Commercial_Avail__c>([Select ID, Title__r.Territory__c from Commercial_Avail__c where Id in : setRRP]);
if(userDetail[0].Profile.Name != System.Label.System_Administrator && userDetail[0].Profile.Name != System.Label.WB_Global_Title_Planner){
for(Commercial_Avail__c releasePlan:lst_trigger_avail){            
if(mapRPTitleTerritory.get(releasePlan.Id).Title__r.Territory__c != userDetail[0].Territory__c){
if(WB_SplitReleaseplanController.bypassTerritoryTitleValidationFromTrigger == false){
releasePlan.Title__c.addError('Selected Title’s territory does not match with logged in user’s territory');
}
}

}

}
//SINC0596533 End 
*/
        
        //Added Start end end date check
        //boolean dateValidationErrorFlag= false;           //Removed for SINC - Prevent duplicates 08/29
        
        
        for(Integer i =0;i<lst_trigger_avail.size();i++){
            if(lst_trigger_avail[i].Start_Date__c > lst_trigger_avail[i].End_Date__c && !validatedRps.contains(lst_trigger_avail[i].id)){
                
                lst_trigger_avail[i].Start_Date__c.adderror('Release Start date cannot be greater than Release End date');
                validatedRps.add(lst_trigger_avail[i].id);
                //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
            }else if(lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Rights_End__c && !validatedRps.contains(lst_trigger_avail[i].id)){
                //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                lst_trigger_avail[i].Exclusive_Date__c.adderror(' Avail Start Date cannot be greater than Avail End Date');
                validatedRps.add(lst_trigger_avail[i].id);
                
            }else if(lst_trigger_avail[i].Status__c== 'Tentative' || lst_trigger_avail[i].Status__c== 'Confirmed'||lst_trigger_avail[i].Status__c== 'Moratorium'){
                
                if( (lst_trigger_avail[i].Exclusive_Date__c== Null || lst_trigger_avail[i].Rights_End__c == Null ||
                     lst_trigger_avail[i].Start_Date__c == Null || lst_trigger_avail[i].End_Date__c ==Null) && !validatedRps.contains(lst_trigger_avail[i].id)){
                         
                         //dateValidationErrorFlag=true;             //Removed for SINC - Prevent duplicates 08/29
                         lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates and Avail Dates are required for selected status- Tentative/Confirmed/Moratorium');
                         validatedRps.add(lst_trigger_avail[i].id);
                     }
                else if(lst_trigger_avail[i].Exclusive_Date__c!= Null && lst_trigger_avail[i].Rights_End__c!= Null && 
                        lst_trigger_avail[i].Start_Date__c!= Null && lst_trigger_avail[i].End_Date__c!=Null){
                            
                            if((lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Start_Date__c || lst_trigger_avail[i].End_Date__c >lst_trigger_avail[i].Rights_End__c) && !validatedRps.contains(lst_trigger_avail[i].id))
                            {
                                //dateValidationErrorFlag=true;             //Removed for SINC - Prevent duplicates 08/29
                                lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates must lie within Avail Dates for selected status- Tentative/Confirmed/Moratorium');
                                validatedRps.add(lst_trigger_avail[i].id);
                            }
                        }
            }else if(lst_trigger_avail[i].Status__c== 'Draft' || lst_trigger_avail[i].Status__c== 'Open'){
                /*if(lst_trigger_avail[i].Exclusive_Date__c== Null || lst_trigger_avail[i].Rights_End__c == Null ){
dateValidationErrorFlag=true;
lst_trigger_avail[i].Exclusive_Date__c.adderror(' Avail Dates are required for the selected status- Draft/Open');
} else if((lst_trigger_avail[i].start_date__c==null && lst_trigger_avail[i].end_date__c!=null)||(lst_trigger_avail[i].start_date__c!=null && lst_trigger_avail[i].end_date__c==null)){
dateValidationErrorFlag=true;
lst_trigger_avail[i].start_date__c.adderror(' Please select both Release Start Date and Release End Date for selected status- Draft/Open ');
}*/
                if (lst_trigger_avail[i].Exclusive_Date__c!= Null && lst_trigger_avail[i].Rights_End__c!= Null && 
                    lst_trigger_avail[i].Start_Date__c!= Null && lst_trigger_avail[i].End_Date__c!=Null){
                        
                        if((lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Start_Date__c || lst_trigger_avail[i].End_Date__c >lst_trigger_avail[i].Rights_End__c) && !validatedRps.contains(lst_trigger_avail[i].id))
                        {
                            //dateValidationErrorFlag=true;             //Removed for SINC - Prevent duplicates 08/29
                            lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates must lie within Avail Dates');
                            validatedRps.add(lst_trigger_avail[i].id);
                        }
                    }
            } else if(lst_trigger_avail[i].Status__c== 'Not Releasing'){
                if(lst_trigger_avail[i].reason_code__c== null && !validatedRps.contains(lst_trigger_avail[i].id))
                {
                    //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                    lst_trigger_avail[i].reason_code__c.adderror(' Reason Code is required for selected status- Not Releasing');
                    validatedRps.add(lst_trigger_avail[i].id);
                } else if(lst_trigger_avail[i].reason_code__c!= null){
                    if((lst_trigger_avail[i].Start_Date__c == Null || lst_trigger_avail[i].End_Date__c == Null) && !validatedRps.contains(lst_trigger_avail[i].id) ){
                        //dateValidationErrorFlag=true;     //Removed for SINC - Prevent duplicates 08/29
                        lst_trigger_avail[i].start_date__c.adderror(' Release Dates  are required for selected status- Not Releasing');
                        validatedRps.add(lst_trigger_avail[i].id);
                        //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' Right Start Date is greater than Release start Date OR Release End Date is greate than Right End Date'));
                    }else if(((lst_trigger_avail[i].Exclusive_Date__c !=null && lst_trigger_avail[i].Rights_End__c ==null)||(lst_trigger_avail[i].Exclusive_Date__c ==null && lst_trigger_avail[i].Rights_End__c !=null)) && !validatedRps.contains(lst_trigger_avail[i].id)){
                        //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                        lst_trigger_avail[i].reason_code__c.adderror(' Release Dates must lie within Avail Dates for selected status- Not Releasing');
                        validatedRps.add(lst_trigger_avail[i].id);
                    }else if(lst_trigger_avail[i].Exclusive_Date__c!= Null && lst_trigger_avail[i].Rights_End__c!= Null && 
                             lst_trigger_avail[i].Start_Date__c!= Null && lst_trigger_avail[i].End_Date__c!=Null){
                                 
                                 if((lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Start_Date__c || lst_trigger_avail[i].End_Date__c >lst_trigger_avail[i].Rights_End__c) && !validatedRps.contains(lst_trigger_avail[i].id)){
                                     //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                                     lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates must lie within Avail Dates for selected status- Not Releasing');            
                                     validatedRps.add(lst_trigger_avail[i].id);
                                 }
                             }
                }
                else if(lst_trigger_avail[i].reason_code__c=='Language Not Available'){
                    //dateValidationErrorFlag=true;
                    //lst_trigger_avail[i].reason_code__c.adderror(' Reason Code is required for selected status- Not Releasing');
                }
            }
        }
        
        map<id,Commercial_Avail__c> map_lst_selectedcommercial_aval = new map<id,Commercial_Avail__c>([
            SELECT id, name,Title__c,Country_Lookup__c,Channel__c,Format__c,Languages__c,Language_Type__c,End_Date__c,Start_Date__c
            FROM Commercial_Avail__c
            WHERE Title__c IN :lst_selectedtitle AND Country_Lookup__c IN :lst_selectedcountry 
            AND Channel__c IN :lst_selectedchannel
            AND Format__c IN :lst_selectedformat 
            AND Languages__c IN :lst_selectedlanguage 
            AND Language_Type__c IN :lst_selectedlanguagetype //ER-359
            AND Id NOT IN :lst_selectedId
        ]);
        lst_selectedcommercial_aval = map_lst_selectedcommercial_aval.values();
        
        //added by shalini for ER-000119
        if(lst_selectedId != null && lst_selectedId.size() > 0)
        {
            map<id,Client_Avail__c> map_lst_client_avail = new map<id,Client_Avail__c>([
                SELECT id, name, Start_Date__c, RP_Synch__c, End_Date__c, Commercial_Avail__c, Status__c
                FROM Client_Avail__c
                WHERE Commercial_Avail__c IN :lst_selectedId
                AND Avail_Type__c != 'Automated' //03/09/2017 Sriniz
            ]);
            lst_client_avail = map_lst_client_avail.values();
        }
        
        //Defect 129 ,Additional feature on updating release plan status 
        for(Integer i =0;i<lst_trigger_avail.size();i++){
            for(integer n=0; n<lst_client_avail.size();n++){
                if(lst_trigger_avail[i].Id == lst_client_avail[n].Commercial_Avail__c &&lst_trigger_avail[i].Status__c == 'Not Releasing'){
                    if(lst_client_avail[n].Status__c == 'Not Available' || lst_client_avail[n].Status__c == 'Cancelled'){
                        system.debug('Defect 129 new feature');
                    }else{
                        lst_trigger_avail[i].Status__c.adderror('Please change the status of Client Avails to Not Available or Cancelled');
                        validatedRps.add(lst_trigger_avail[i].id);
                    }
                }
            }
        }
        
        //ER-119 
        
        
        
        //boolean dateOverlap=false;                //Removed for SINC - Prevent duplicates 08/29
        for(Integer i =0;i<lst_trigger_avail.size();i++)
        {
            //boolean sameDateFlag= false;       
            boolean withinListOverlap=false;
            Commercial_Avail__c oldRP = (Commercial_Avail__c)trigger.oldMap.get(lst_trigger_avail[i].id);
            
            if(oldRP != NULL && 
               (oldRP.Start_Date__c == lst_trigger_avail[i].Start_Date__c) && 
               (oldRP.End_Date__c == lst_trigger_avail[i].End_Date__c) && 
               (oldRP.Exclusive_Date__c == lst_trigger_avail[i].Exclusive_Date__c) && 
               (oldRP.Rights_End__c == lst_trigger_avail[i].Rights_End__c))
                //sameDateFlag = true;
                continue;
            
            for(Integer n =i+1;n<lst_trigger_avail.size();n++)
            {
                if(lst_trigger_avail[i].Start_Date__c != null && lst_trigger_avail[n].End_Date__c != null && lst_trigger_avail[i].End_Date__c != null && lst_trigger_avail[n].Start_Date__c!=null )
                {
                    if(lst_trigger_avail[i].channel__c== lst_trigger_avail[n].channel__c &&lst_trigger_avail[i].format__c== lst_trigger_avail[n].format__c && lst_trigger_avail[i].languages__c== lst_trigger_avail[n].languages__c && lst_trigger_avail[i].country_lookup__c== lst_trigger_avail[n].country_lookup__c && lst_trigger_avail[i].title__c== lst_trigger_avail[n].title__c )
                    {
                        // lst_trigger_avail[i].Start_Date__c.adderror('Date Overlap in the selected list of records') ; 
                        if(lst_trigger_avail[i].Start_Date__c > lst_trigger_avail[n].End_Date__c || lst_trigger_avail[i].End_Date__c <lst_trigger_avail[n].Start_Date__c )
                        {
                            
                        }else{
                            lst_trigger_avail[i].Start_Date__c.adderror('Date Overlap in the selected list of records') ; 
                            withinListOverlap=true;
                        }
                    }
                }
            }
            if(withinListOverlap == false)
            {
                for(integer j=0;j<lst_selectedcommercial_aval.size();j++)
                {
                    //started
                    if(lst_trigger_avail[i].Start_Date__c > lst_trigger_avail[i].End_Date__c )
                        lst_trigger_avail[i].Start_Date__c.adderror('Start date cannot be greater than End date');
                    else if(
                        lst_trigger_avail[i].channel__c==lst_selectedcommercial_aval[j].channel__c &&
                        lst_trigger_avail[i].format__c==lst_selectedcommercial_aval[j].format__c &&
                        lst_trigger_avail[i].Languages__c==lst_selectedcommercial_aval[j].Languages__c &&
                        lst_trigger_avail[i].Country_Lookup__c==lst_selectedcommercial_aval[j].Country_Lookup__c &&
                        lst_trigger_avail[i].Title__c==lst_selectedcommercial_aval[j].Title__c &&
                        lst_trigger_avail[i].Language_Type__c==lst_selectedcommercial_aval[j].Language_Type__c//ER-359
                    )
                    {
                        
                        if(lst_trigger_avail[i].Start_Date__c==null && lst_selectedcommercial_aval[j].Start_Date__c==null && lst_trigger_avail[i].End_Date__c==null && lst_selectedcommercial_aval[j].End_Date__c==null)
                        {
                        lst_trigger_avail[i].Start_Date__c.adderror(System.Label.Release_Plan_Date_Overlap+' '+'to'+' '+lst_selectedcommercial_aval[j].name) ;    
                        }
                        else  if( ((lst_trigger_avail[i].Start_Date__c >= lst_selectedcommercial_aval[j].Start_Date__c && lst_trigger_avail[i].Start_Date__c <= lst_selectedcommercial_aval[j].End_Date__c)) 
                                 ||((lst_trigger_avail[i].End_Date__c >=lst_selectedcommercial_aval[j].Start_Date__c && lst_trigger_avail[i].End_Date__c <= lst_selectedcommercial_aval[j].End_Date__c ))
                                 ||(lst_trigger_avail[i].Start_Date__c < lst_selectedcommercial_aval[j].Start_Date__c && lst_trigger_avail[i].End_Date__c > lst_selectedcommercial_aval[j].End_Date__c) )
                            lst_trigger_avail[i].Start_Date__c.adderror(System.Label.Release_Plan_Date_Overlap+' '+'to'+' '+lst_selectedcommercial_aval[j].name) ; 
                        
                    } 
                }
            }// End of inner for loop
            
            for(integer n=0; n<lst_client_avail.size();n++)
            {
                if(lst_trigger_avail[i].Id == lst_client_avail[n].Commercial_Avail__c){
                    
                    //added by shalini for ER-000119
                    if((lst_trigger_avail[i].Start_Date__c > lst_client_avail[n].Start_Date__c ||lst_trigger_avail[i].End_Date__c < lst_client_avail[n].End_Date__c)&& (lst_client_avail[n].RP_Synch__c == false)){                                     
                        lst_trigger_avail[i].Start_Date__c.adderror('Client Avails cannnot be synched as one of the Client Avails has RP Sync false and it will be invalid in this process.');
                    }
                }
            }
            
            
        } // End of outer for loop
        
        validatedRps.clear();
        lst_selectedcommercial_aval.clear();
        lst_client_avail.clear();
        lst_selectedtitle.clear();
        lst_selectedcountry.clear();
        lst_selectedchannel.clear();
        lst_selectedlanguage.clear();
        lst_selectedformat.clear();
        lst_selectedlanguagetype.clear();
        lst_selectedId.clear();
        
    }  // End of function
    
    public static void Chkoverlap_afterinsert(){
        
        list<User> userDetail = new list<User>();
        list<Commercial_Avail__c> lst_selectedcommercial_aval = new list<Commercial_Avail__c>();
        list<Commercial_Avail__c> lst_trigger_avail = new list<Commercial_Avail__c>();
        list <string> lst_selectedtitle = new list<string>();
        //set<string> lst_selectedtitle1 = new set<string>();
        list<string> lst_selectedcountry = new list<string>();
        list<string> lst_selectedchannel = new list<string>();
        list<string> lst_selectedformat = new list<string>();
        list<string> lst_selectedlanguage = new list<string>();
        list<string> lst_selectedlanguagetype = new list<string>();//ER-359
        boolean flagReleaseMaintainer =false;
        
        lst_trigger_avail = trigger.new;
        
        /*Migrated Workflow Logic For Field Update - Start*/
        for(Commercial_Avail__c cAvail : lst_trigger_avail)
        {
            cAvail.zTitleStudio_Search__c = cAvail.fTitleStudio_Search__c;
            cAvail.zReleasePlanLookup_Title__c = cAvail.fReleasePlanLookup_Title__c;
        }
        /*Migrated Workflow Logic For Field Update - End*/
        
        for(integer i=0;i<lst_trigger_avail.size();i++){
            //lst_selectedtitle1.add(lst_trigger_avail[i].Title__c);
            lst_selectedtitle.add(lst_trigger_avail[i].Title__c);
            lst_selectedcountry.add(lst_trigger_avail[i].Country_Lookup__c);
            lst_selectedchannel.add(lst_trigger_avail[i].Channel__c);
            lst_selectedformat.add(lst_trigger_avail[i].Format__c);
            lst_selectedlanguage.add(lst_trigger_avail[i].Languages__c);
            lst_selectedlanguagetype.add(lst_trigger_avail[i].Language_Type__c);//ER-359
        }
        //User Info validation for release maitainer profile
        map<Id,User> userDetailMap = new map<Id,User>([SELECT id,ProfileId,Profile.Name,UserType,Territory__c,isGPPPermissionSetAssigned__c from User where id =: Userinfo.getUserId()]);
        userDetail = userDetailMap.values();
        
        //start new logic
        Set<String> matchTerritory = new Set<String>();
        Set<String> matchCountryName = new Set<String>();
        Set<String> matchCountryId = new Set<String>();
        
        map<id,Country__c> countryDetailMap = new map<id, Country__c>([Select id,name,Territory__c FROM Country__c where Territory__c =:userDetail[0].Territory__c]);
        List<Country__c> countryDetail = countryDetailMap.values();
        
        /* ER-000081  Added by shalini to validate Ttitle's territory*/
        List<Title__c> titleDetail;
        if(lst_selectedtitle != null && lst_selectedtitle.size() > 0)
            titleDetail = [Select id,name,Territory__c FROM Title__c where Territory__c =:userDetail[0].Territory__c and id in:lst_selectedtitle];       
        
        if(userDetail.get(0).Profile.Name != System.Label.WB_CAS_Administrator && (userDetail.get(0).Profile.Name != System.Label.WB_Global_Title_Planner && userDetail.get(0).isGPPPermissionSetAssigned__c !=true) && userDetail.get(0).Profile.Name != System.Label.WB_System_Administrator){
            for(Commercial_Avail__c releasePlan:lst_trigger_avail){
                integer countCountryTerr=0;
                for(Country__c con:countryDetail){
                    if(releasePlan.Country_Lookup__c==con.ID){
                        countCountryTerr++;
                    }
                }
                if(countCountryTerr==0){
                    //releasePlan.Country_Lookup__c.addError('Selected Country’s territory does not match with logged in user’s territory');
                }
                
                /* Start - Added by shalini to validate Title's territory*/
                integer countTitleTerr=0;
                for(Title__c title : titleDetail){
                    if(releasePlan.Title__c == title.ID){
                        countTitleTerr++;
                    }
                }
                if(countTitleTerr==0){
                    If(WB_SplitReleaseplanController.bypassTerritoryTitleValidationFromTrigger == false){                    
                        releasePlan.Title__c.addError('Selected Title’s territory does not match with logged in user’s territory');
                    }
                }
                /* End - Added by shalini to validate Title's territory*/
            }
            
            /* Added by shalini to validate Title's territory*
for(Commercial_Avail__c releasePlan:lst_trigger_avail){
integer countTitleTerr=0;
for(Title__c title:titleDetail){
if(releasePlan.Title__c==title.ID){
countTitleTerr++;
}
}
if(countTitleTerr==0){
If(WB_SplitReleaseplanController.bypassTerritoryTitleValidationFromTrigger == false){
releasePlan.Title__c.addError('Selected Title’s territory does not match with logged in user’s territory');
}
}
}
*/
        }
        // End new logic
        
        //boolean dateValidationErrorFlag= false;           //Removed for SINC - Prevent duplicates 08/30
        if(flagReleaseMaintainer == false){
            //Added for Start end end date check
            for(Integer i =0;i<lst_trigger_avail.size();i++){
                if(lst_trigger_avail[i].Start_Date__c > lst_trigger_avail[i].End_Date__c )
                {
                    // Criteria 1
                    //dateValidationErrorFlag=true;       //Removed for SINC - Prevent duplicates 08/29
                    lst_trigger_avail[i].Start_Date__c.adderror('Release Start date cannot be greater than Release End date');
                    continue;
                }
                else if(lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Rights_End__c)
                {
                    //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                    lst_trigger_avail[i].Exclusive_Date__c.adderror(' Avail Start Date cannot be greater than Avail End Date');
                    continue;
                }
                else if(lst_trigger_avail[i].Status__c== 'Tentative' || lst_trigger_avail[i].Status__c== 'Confirmed'||lst_trigger_avail[i].Status__c== 'Moratorium')
                {
                    if(lst_trigger_avail[i].Exclusive_Date__c== Null || lst_trigger_avail[i].Rights_End__c == Null ||
                       lst_trigger_avail[i].Start_Date__c == Null || lst_trigger_avail[i].End_Date__c ==Null)
                    {
                        //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                        lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates and Avail Dates are required for selected status- Tentative/Confirmed/Moratorium');
                        continue;
                    }
                    else if(lst_trigger_avail[i].Exclusive_Date__c!= Null && lst_trigger_avail[i].Rights_End__c!= Null && 
                            lst_trigger_avail[i].Start_Date__c!= Null && lst_trigger_avail[i].End_Date__c!=Null)
                    {
                        if(lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Start_Date__c || lst_trigger_avail[i].End_Date__c >lst_trigger_avail[i].Rights_End__c)
                        {
                            //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                            lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates must lie within Avail Dates for selected status- Tentative/Confirmed/Moratorium');
                            continue;
                        }
                    }
                }
                else if(lst_trigger_avail[i].Status__c== 'Draft' || lst_trigger_avail[i].Status__c== 'Open')
                {
                    /*if(lst_trigger_avail[i].Exclusive_Date__c== Null || lst_trigger_avail[i].Rights_End__c == Null ){
dateValidationErrorFlag=true;
lst_trigger_avail[i].Exclusive_Date__c.adderror(' Avail Start Dates are required for the selected status- Draft/Open');
} else if((lst_trigger_avail[i].start_date__c==null && lst_trigger_avail[i].end_date__c!=null)||(lst_trigger_avail[i].start_date__c!=null && lst_trigger_avail[i].end_date__c==null)){
dateValidationErrorFlag=true;
lst_trigger_avail[i].start_date__c.adderror(' Please select both Release Start Date and Release End Date for selected status- Draft/Open');
}*/
                    if (lst_trigger_avail[i].Exclusive_Date__c!= Null && lst_trigger_avail[i].Rights_End__c!= Null && 
                        lst_trigger_avail[i].Start_Date__c!= Null && lst_trigger_avail[i].End_Date__c!=Null)
                    {
                        if(lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Start_Date__c || lst_trigger_avail[i].End_Date__c >lst_trigger_avail[i].Rights_End__c)
                        {
                            //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                            lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates must lie within Avail Dates for selected status- Draft/Open');
                            
                        }
                    }
                } 
                else if(lst_trigger_avail[i].Status__c== 'Not Releasing')
                {
                    if(lst_trigger_avail[i].reason_code__c == null)
                    {
                        //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                        lst_trigger_avail[i].reason_code__c.adderror(' Reason Code is required for selected status- Not Releasing');
                    }
                    else if(lst_trigger_avail[i].reason_code__c!= null)
                    { //defect116
                        if(lst_trigger_avail[i].Start_Date__c == Null || lst_trigger_avail[i].End_Date__c == Null )
                        {
                            //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                            lst_trigger_avail[i].start_date__c.adderror(' Release Dates  are required for selected status- Not Releasing');
                            //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' Right Start Date is greater than Release start Date OR Release End Date is greate than Right End Date'));
                        }
                        else if((lst_trigger_avail[i].Exclusive_Date__c !=null && lst_trigger_avail[i].Rights_End__c ==null)||
                                (lst_trigger_avail[i].Exclusive_Date__c ==null && lst_trigger_avail[i].Rights_End__c !=null))
                        {
                            //dateValidationErrorFlag=true;         //Removed for SINC - Prevent duplicates 08/29
                            lst_trigger_avail[i].reason_code__c.adderror(' Release Dates must lie within Avail Dates for selected status- Not Releasing');
                        }
                        else if(lst_trigger_avail[i].Exclusive_Date__c!= Null && lst_trigger_avail[i].Rights_End__c!= Null && 
                                lst_trigger_avail[i].Start_Date__c!= Null && lst_trigger_avail[i].End_Date__c!=Null)
                        {
                            if(lst_trigger_avail[i].Exclusive_Date__c > lst_trigger_avail[i].Start_Date__c || lst_trigger_avail[i].End_Date__c >lst_trigger_avail[i].Rights_End__c){
                                //dateValidationErrorFlag=true;          //Removed for SINC - Prevent duplicates 08/29
                                lst_trigger_avail[i].Exclusive_Date__c.adderror(' Release Dates must lie within Avail Dates for selected status- Not Releasing');
                            }
                        }
                    }
                    else if(lst_trigger_avail[i].reason_code__c=='Language Not Available'){
                        //dateValidationErrorFlag=true;
                        //lst_trigger_avail[i].reason_code__c.adderror(' Reason Code is required for selected status- Not Releasing');
                    }
                }
            }//ended  
            
            map<id,Commercial_Avail__c> map_lst_selectedcommercial_aval = new map<id,Commercial_Avail__c>([
                SELECT id, name,Title__c,Country_Lookup__c,Channel__c,Format__c,Languages__c,Language_Type__c,End_Date__c,Start_Date__c,Exclusive_Date__c,Rights_End__c
                FROM Commercial_Avail__c 
                WHERE Title__c IN :lst_selectedtitle
                AND Country_Lookup__c IN :lst_selectedcountry
                AND Channel__c IN :lst_selectedchannel 
                AND Format__c IN :lst_selectedformat
                AND Languages__c IN :lst_selectedlanguage
                AND Language_Type__c IN :lst_selectedlanguagetype //ER-359
            ]);
            lst_selectedcommercial_aval = map_lst_selectedcommercial_aval.values();
            
            
            for(Integer i =0;i<lst_trigger_avail.size();i++)
            {
                boolean withinListOverlap=false;
                for(Integer n =i+1;n<lst_trigger_avail.size();n++)
                {
                    if(lst_trigger_avail[i].Start_Date__c != null && lst_trigger_avail[n].End_Date__c != null && lst_trigger_avail[i].End_Date__c != null && lst_trigger_avail[n].Start_Date__c!=null )
                    {
                        if( lst_trigger_avail[i].channel__c         == lst_trigger_avail[n].channel__c          &&
                           lst_trigger_avail[i].format__c          == lst_trigger_avail[n].format__c           &&
                           lst_trigger_avail[i].languages__c       == lst_trigger_avail[n].languages__c        &&
                           lst_trigger_avail[i].country_lookup__c  == lst_trigger_avail[n].country_lookup__c   &&
                           lst_trigger_avail[i].title__c           == lst_trigger_avail[n].title__c            &&
                           lst_trigger_avail[i].language_type__c   == lst_trigger_avail[n].language_type__c//ER-359 : Mahesh 
                          ){
                              // lst_trigger_avail[i].Start_Date__c.adderror('Date Overlap in the selected list of records') ; 
                              if(lst_trigger_avail[i].Start_Date__c > lst_trigger_avail[n].End_Date__c || lst_trigger_avail[i].End_Date__c <lst_trigger_avail[n].Start_Date__c ){
                                  
                              }else {
                                  lst_trigger_avail[i].Start_Date__c.adderror('Date Overlap in the selected list of records') ;
                                  withinListOverlap=true;
                              }
                          }
                    }
                }
                if(withinListOverlap==false){
                    //system.debug('withinListOverlap*** In Test'+withinListOverlap);
                    for(integer j=0;j<lst_selectedcommercial_aval.size();j++)
                    {
                        // added by Tejas 1 Oct
                        if(lst_trigger_avail[i].End_Date_In_Perpetuity__c == true){
                            lst_trigger_avail[i].End_Date__c = date.parse('12/31/2049');
                        }
                        
                        if(lst_trigger_avail[i].Start_Date__c > lst_trigger_avail[i].End_Date__c )
                            lst_trigger_avail[i].Start_Date__c.adderror('Start date cannot be greater than End date');
                        // added by rashmi on 9th sept
                        else if(lst_trigger_avail[i].channel__c==lst_selectedcommercial_aval[j].channel__c &&
                                lst_trigger_avail[i].format__c==lst_selectedcommercial_aval[j].format__c &&
                                lst_trigger_avail[i].Languages__c==lst_selectedcommercial_aval[j].Languages__c &&
                                lst_trigger_avail[i].Country_Lookup__c==lst_selectedcommercial_aval[j].Country_Lookup__c &&
                                lst_trigger_avail[i].Title__c==lst_selectedcommercial_aval[j].Title__c &&
                                lst_trigger_avail[i].Language_Type__c==lst_selectedcommercial_aval[j].Language_Type__c//ER-359
                               ){
                                   
                                   if(lst_trigger_avail[i].Start_Date__c==null && lst_selectedcommercial_aval[j].Start_Date__c==null && lst_trigger_avail[i].End_Date__c==null && lst_selectedcommercial_aval[j].End_Date__c==null){
                                       lst_trigger_avail[i].Start_Date__c.adderror(System.Label.Release_Plan_Date_Overlap+' '+' to '+' '+lst_selectedcommercial_aval[j].name) ; 
                                   }
                                   /*ER-003468 CA Overlapping Check If RP Blank for Duplicate RP Creation Problem*/
                                  else if((lst_trigger_avail[i].Start_Date__c==null || lst_selectedcommercial_aval[j].Start_Date__c==null  )&& ((lst_trigger_avail[i].End_Date__c==null||lst_trigger_avail[i].End_Date__c==date.parse('12/31/2049'))||(lst_selectedcommercial_aval[j].End_Date__c==null ||lst_selectedcommercial_aval[j].End_Date__c==date.parse('12/31/2049'))))
                                   {
                                       if(((lst_trigger_avail[i].Exclusive_Date__c >= lst_selectedcommercial_aval[j].Exclusive_Date__c && 
                                             lst_trigger_avail[i].Exclusive_Date__c <= lst_selectedcommercial_aval[j].Rights_End__c)) 
                                           ||((lst_trigger_avail[i].Rights_End__c >=lst_selectedcommercial_aval[j].Exclusive_Date__c && lst_trigger_avail[i].Rights_End__c <= lst_selectedcommercial_aval[j].Rights_End__c ))
                                           ||(lst_trigger_avail[i].Exclusive_Date__c < lst_selectedcommercial_aval[j].Exclusive_Date__c && lst_trigger_avail[i].Rights_End__c > lst_selectedcommercial_aval[j].Rights_End__c)
                                          ){
                                              
                                              lst_trigger_avail[i].Exclusive_Date__c.adderror('Avails Overlapping Found: '+System.Label.Release_Plan_Date_Overlap+' '+'to'+' '+lst_selectedcommercial_aval[j].name) ; 
                                          }
                                               
                                   }           
                                   /* ER-003468 CA Overlapping check if RP Blank  END*/
                                                                    
                                   else if(((lst_trigger_avail[i].Start_Date__c >= lst_selectedcommercial_aval[j].Start_Date__c && 
                                             lst_trigger_avail[i].Start_Date__c <= lst_selectedcommercial_aval[j].End_Date__c)) 
                                           ||((lst_trigger_avail[i].End_Date__c >=lst_selectedcommercial_aval[j].Start_Date__c && lst_trigger_avail[i].End_Date__c <= lst_selectedcommercial_aval[j].End_Date__c ))
                                           ||(lst_trigger_avail[i].Start_Date__c < lst_selectedcommercial_aval[j].Start_Date__c && lst_trigger_avail[i].End_Date__c > lst_selectedcommercial_aval[j].End_Date__c)
                                          ){
                                              lst_trigger_avail[i].Start_Date__c.adderror(System.Label.Release_Plan_Date_Overlap+' '+'to'+' '+lst_selectedcommercial_aval[j].name) ; 
                                          }
                               }
                    }// End of inner for loopok
                }
            } // End of outer for loop
            
        }
    }
    // function end
    
    // Added code for local data creation
    /*public static void localdatacreation(){
        
        // Addded logic to create local data
        list<User> userDetail = new list<User>();
        map<Id,Id> commTitleIds= new map<Id,Id>();
        map<Id,Title__c> titleNames= new map<Id,Title__c>();
        map<Id,string> titleVideoVersion= new map<Id,string>();
        list<string> localTitleIds= new list<string>(); 
        list<Local_Title__c> lst_localtitles = new list<Local_Title__c>(); // Added for local data
        list<Local_Title__c> lst_localtitlescreated = new list<Local_Title__c>();
        set<Local_Title__c> lst_localtitlescreatedUnique = new set<Local_Title__c>();
        list<Local_Title__c> lst_localtitlescreatedNew = new list<Local_Title__c>();
        set<Local_Title__c> lst_localtitlescreatedNewUnique = new set<Local_Title__c>(); // Added for local data
        list<Title__c> lst_titlename = new list<Title__c>(); // Added for local data
        list<string> lst_localtitleids = new list<string>(); // Added for local data
        list<Commercial_Avail__c> lst_trigger_avail = new list<Commercial_Avail__c>();
        
        list <string> lst_selectedtitle = new list<string>();
        //set<string> lst_selectedtitle1 = new set<string>();
        list<string> lst_selectedcountry = new list<string>();
        list<string> lst_selectedchannel = new list<string>();
        list<string> lst_selectedformat = new list<string>();
        list<string> lst_selectedlanguage = new list<string>();
        list<string> lst_selectedlanguagetype = new list<string>();//ER-359
        
        Map<id,Local_Title__c> toUpdateLocalTitles = new Map<id,Local_Title__c>(); // ER-10:Playlist
        Map<id,Playlist__c> mapTitleIdPlaylist = new Map<id,Playlist__c>();// ER-10:Playlist
        integer caCount;
        
        lst_trigger_avail = trigger.new;
        
        for(integer i=0;i<lst_trigger_avail.size();i++){
            commTitleIds.put(lst_trigger_avail[i].Id,lst_trigger_avail[i].Title__c);
            //lst_selectedtitle1.add(lst_trigger_avail[i].Title__c);
            lst_selectedtitle.add(lst_trigger_avail[i].Title__c);
            lst_selectedcountry.add(lst_trigger_avail[i].Country_Lookup__c);
            lst_selectedchannel.add(lst_trigger_avail[i].Channel__c);
            lst_selectedformat.add(lst_trigger_avail[i].Format__c);
            lst_selectedlanguage.add(lst_trigger_avail[i].Languages__c);
            lst_selectedlanguagetype.add(lst_trigger_avail[i].Language_Type__c);//ER-359
        }
        
        userDetail =[   SELECT id,ProfileId,Profile.Name,UserType,Territory__c  from User where id =: Userinfo.getUserId() ];
        
        
        lst_localtitles = [SELECT id,name,Title__c,Title__r.Name,Title__r.Content_Type__c,Country__c,Language__c,Readiness__c,Playlist__c //ER:10 : Added Playlist field in query
                           FROM Local_Title__c
                           WHERE Title__c IN :lst_selectedtitle AND Country__c IN :lst_selectedcountry AND  Language__c IN :lst_selectedlanguage 
                          ];
        
        
        // START : Added by Prachi for ER-10:Playlist
        if(lst_selectedtitle != null && lst_selectedtitle.size() > 0){
            for(Playlist__c playlist : [SELECT id,Name,Parent_Title__c from Playlist__c where Version_Number__c = 1 and Parent_Title__c in: lst_selectedtitle
                                        AND Playlist_Status__c = 'Active'])
                mapTitleIdPlaylist.put(playlist.Parent_Title__c,playlist);
            // END
            lst_titlename = [Select name,id,video_version__c,Content_Type__c from Title__c where id IN :lst_selectedtitle];
            
            if(lst_titlename != null && lst_titlename.size() > 0){ 
                for(Title__c lt:lst_titlename){
                    titleNames.put(lt.Id,lt);
                    titleVideoVersion.put(lt.Id,lt.video_version__c);
                }
            }
        }
        
        set<commercial_avail__c> updateCommAvail= new set<commercial_avail__c>();
        list<commercial_avail__c> updateCommAvailFinal=new list<commercial_avail__c>();
        //list<string> commIds= new list<string>();
        set<string> commIds= new set<string>(); 
        if(lst_localtitles.size() == 0){
            for (integer j=0;j<lst_trigger_avail.size();j++){
                string commIdMap= commTitleIds.get(lst_trigger_avail[j].Id);
                string localTitleName=titleNames.get(commIdMap).Name;
                string localVideoVersion=titleVideoVersion.get(commIdMap);
                commIds.add(lst_trigger_avail[j].Id);
                Local_Title__c  localrec = new Local_Title__c();
                localrec.Title__c = lst_selectedtitle[j];
                localrec.Country__c = lst_selectedcountry[j];
                localrec.Language__c  = lst_selectedlanguage[j];
                localrec.Local_Title__c = lst_trigger_avail[j].Title_Alias__c != null ? lst_trigger_avail[j].Title_Alias__c : localTitleName; // Added as part of ER-003828
                localrec.name = localrec.Local_Title__c.length() > 80 ? localrec.Local_Title__c.substring(0,80) : localrec.Local_Title__c; // Added as part of ER-003828
                
                //localrec.Readiness__c = 'Requires Review';
                
                // START : Added by Prachi for ER-10:Playlist
                if(mapTitleIdPlaylist != null && mapTitleIdPlaylist.size() > 0 && mapTitleIdPlaylist.containskey(lst_selectedtitle[j]))
                {                   
                    localrec.Playlist__c = mapTitleIdPlaylist.get(lst_selectedtitle[j]).Id;
                    updateCommAvail.add(new commercial_avail__c(id=lst_trigger_avail[j].Id,
                                                                Playlist__c = mapTitleIdPlaylist.get(lst_selectedtitle[j]).id,Rights_ID__c = lst_trigger_avail[j].Rights_ID__c));
                }
                
                // Start : ER-702 : RP Wizard: Validate Playlist for Feature Collection
                else{
                    if(titleNames.get(commIdMap).Content_Type__c == 'Collection Features')
                        lst_trigger_avail[j].adderror(Label.WB_Playlist_Validation_on_Release_Plan+' '+localTitleName+'.');
                }
                // END
                
                //localrec.Video_Version__c= localVideoVersion;
                
                lst_localtitlescreatedUnique.add(localrec);
            }
            lst_localtitlescreated.addAll(lst_localtitlescreatedUnique);
            if (lst_localtitlescreated!= null && lst_localtitlescreated.size() > 0){
                try{
                    Database.Saveresult[] saveResult  = Database.insert(lst_localtitlescreated, true);
                    for (Database.SaveResult sr : saveResult  ) {
                        localTitleIds.add(sr.getId());
                    }
                }
                catch(Exception Ex){
                    system.debug('=============== Exception : ' + Ex.getMessage());
                }
            }   
        }
        else{
            for(integer a=0;a<lst_trigger_avail.size();a++){
                caCount = 0;
                for(Local_Title__c lt:lst_localtitles){
                    if(lst_trigger_avail[a].Title__c == lt.Title__c && lst_trigger_avail[a].Country_Lookup__c == lt.country__c 
                       && lst_trigger_avail[a].Languages__c == lt.language__c){
                           commercial_avail__c newRec= new commercial_avail__c();
                           newRec.Id= lst_trigger_avail[a].Id;
                           newRec.Local_Title__c=lt.Id;
                           newRec.Rights_ID__c = lst_trigger_avail[a].Rights_ID__c;
                           if(lt.Playlist__c != null)
                               newRec.Playlist__c = lt.Playlist__c;
                           //START: ER: 10 := Set default playlist in Local Data Playlist lookup.
                           if( mapTitleIdPlaylist != null && mapTitleIdPlaylist.size() > 0 && mapTitleIdPlaylist.containskey(lst_trigger_avail[a].Title__c))
                           {
                               if(lt.Playlist__c == null && !toUpdateLocalTitles.containsKey(lt.Id))
                               {
                                   Id playlistId= mapTitleIdPlaylist.get(lst_trigger_avail[a].Title__c).id;
                                   toUpdateLocalTitles.put(lt.Id,new Local_Title__c(id=lt.Id,Playlist__c=playlistId));
                                   newRec.Playlist__c = playlistId;
                               }
                               else if(toUpdateLocalTitles.containsKey(lt.Id))
                                   newRec.Playlist__c = toUpdateLocalTitles.get(lt.id).Playlist__c;
                           }
                           // Start : ER-702 : RP Wizard: Validate Playlist for Feature Collection
                           else{
                               if(lt.Title__r.Content_Type__c == 'Collection Features')
                                   lst_trigger_avail[a].adderror(Label.WB_Playlist_Validation_on_Release_Plan+' '+lt.Title__r.Name+'.');
                           }
                           updateCommAvail.add(newRec);
                           // END
                           //lst_trigger_avail[a].Title__c = lt.Id;
                           caCount++;
                           break;
                       }
                }
                
                if(caCount == 0){
                    string commIdMap= commTitleIds.get(lst_trigger_avail[a].Id);
                    string localTitleName=titleNames.get(commIdMap).Name;
                    string localVideoVersion=titleVideoVersion.get(commIdMap);
                    commIds.add(lst_trigger_avail[a].Id);
                    Local_Title__c  localrec = new Local_Title__c();
                    localrec.Title__c = lst_trigger_avail[a].Title__c;
                    localrec.Country__c = lst_trigger_avail[a].Country_Lookup__c;
                    localrec.Language__c  = lst_trigger_avail[a].Languages__c;
                    localrec.Local_Title__c = lst_trigger_avail[a].Title_Alias__c != null ? lst_trigger_avail[a].Title_Alias__c : localTitleName; // Added as part of ER-003828
                    localrec.name = localrec.Local_Title__c.length() > 80 ? localrec.Local_Title__c.substring(0,80) : localrec.Local_Title__c; // Added as part of ER-003828
                    //localrec.Readiness__c = 'Requires Review';
                    
                    // START : Added by Prachi for ER-10 : Playlist
                    if(mapTitleIdPlaylist != null && mapTitleIdPlaylist.size() > 0 && mapTitleIdPlaylist.containskey(lst_trigger_avail[a].Title__c))
                    {
                        localrec.Playlist__c = mapTitleIdPlaylist.get(lst_trigger_avail[a].Title__c).id;
                        updateCommAvail.add(new commercial_avail__c(id=lst_trigger_avail[a].Id,
                                                                    Playlist__c = mapTitleIdPlaylist.get(lst_trigger_avail[a].Title__c).id,Rights_ID__c = lst_trigger_avail[a].Rights_ID__c));
                    }
                    // END
                    
                    //localrec.Video_Version__c= localVideoVersion; 
                    lst_localtitlescreatedNewUnique.add(localrec);
                    //lst_localtitlescreatedNew.add(localrec);
                }
            }
        }
        lst_localtitlescreatedNew.addAll(lst_localtitlescreatedNewUnique);
        updateCommAvailFinal.addAll(updateCommAvail);

        try{
            if (updateCommAvailFinal!= null && updateCommAvailFinal.size() > 0){
                Database.Saveresult[] saveResult  = Database.update(updateCommAvailFinal, false);
            }
        }
        catch(exception e){
            system.debug('The error message to print'+e);
        }

        //update updateCommAvailFinal;
        try{  
            if (lst_localtitlescreatedNew!= null && lst_localtitlescreatedNew.size() > 0){
                Database.Saveresult[] saveResult  = Database.insert(lst_localtitlescreatedNew, false);
                for (Database.SaveResult sr : saveResult  ) {
                    localTitleIds.add(sr.getId());
                }   
            }
            update toUpdateLocalTitles.values(); // ER: 10
        }catch(exception e){
            system.debug('The error message to printlst_localtitlescreatedNew'+e);
        }
        list<Local_Title__c> insertedLocalTitles = new list<Local_Title__c>();
        list<commercial_avail__c> insertedReleasePlans = new list<commercial_avail__c>();
        
        if(localTitleIds != null && localTitleIds.size() > 0){
            insertedLocalTitles =[SELECT id,name,Title__c,Country__c,Language__c 
                                  FROM Local_Title__c
                                  WHERE Id IN:localTitleIds];
        }
        if(commIds != null && commIds.size() > 0){
            insertedReleasePlans=[SELECT Id,name,Title__c,Country_Lookup__c,Languages__c,Release_Locale__c,MPM_Release_Date_Key__c
                                  FROM commercial_avail__c
                                  WHERE Id IN:commIds];
        }
        
        set<commercial_avail__c> commUpdateUnique= new set<commercial_avail__c>();
        list<commercial_avail__c> commUpdate= new list<commercial_avail__c>();
        
        for(integer i=0;i<insertedReleasePlans.size();i++){
            for(integer n=0;n<insertedLocalTitles.size();n++){
                if((insertedReleasePlans[i].Country_Lookup__c==insertedLocalTitles[n].Country__c)&& (insertedReleasePlans[i].Title__c==insertedLocalTitles[n].Title__c)&&(insertedReleasePlans[i].Languages__c==insertedLocalTitles[n].Language__c)){                   
                    commercial_avail__c updateRec = new commercial_avail__c();
                    updateRec.Id= insertedReleasePlans[i].Id;
                    updateRec.Local_Title__c=insertedLocalTitles[n].Id;
                    commUpdateUnique.add(updateRec);
                }
            }
        }
        commUpdate.addAll(commUpdateUnique);
        System.debug('commUpdate==='+commUpdate);
        update commUpdate;
    }*/
    
    //Add shell local title if RP (Language , Country & Title) updated - ER-003991
    public static void localdatacreation(map<Id,Commercial_Avail__c> mapOfTriggerRPsOld,list<Commercial_Avail__c> lstOfTriggerRPsNew){
        List<Commercial_Avail__c> listofRPs = new List<Commercial_Avail__c>();
        for(Commercial_Avail__c rp : lstOfTriggerRPsNew){
            Commercial_Avail__c oldRP = mapOfTriggerRPsOld.get(rp.Id);
            if(rp.Country_Lookup__c != oldRP.Country_Lookup__c || rp.Languages__c != oldRP.Languages__c || rp.Title__c != oldRP.Title__c){
            	rp.Release_Locale__c  = null; //ER-007425
                listofRPs.add(rp);
            }
        }
        if(!listofRPs.isEmpty()){
            localdatacreation(listofRPs);
        }
    }
    
    //Add shell local titles for Release Plan if Local Title is not present in system - ER-003991
    public static void localdatacreation(list<Commercial_Avail__c> lstOfTriggerRPs){
    	set<Id> titleIds = new set<Id>();
    	set<Id> countryIds = new set<Id>();	
    	set<Id> languageIds = new set<Id>();
    	Map<String,Local_Title__c> mapOfExistingLTs = new Map<String,Local_Title__c>();
    	
    	for(Commercial_Avail__c rp : lstOfTriggerRPs){
    		titleIds.add(rp.Title__c);
    		countryIds.add(rp.Country_Lookup__c);
    		languageIds.add(rp.Languages__c);
    	}
    	
    	Map<Id,Playlist__c> mapTitleIdPlaylist = new Map<Id,Playlist__c>();
    	Map<Id,Title__c> mapOfTitle = new Map<Id,Title__c>();
    	
    	//Playlist Map of TitleId & Playlist__c
    	if(titleIds != null && titleIds.size() > 0){
    		for(Playlist__c playlist : [SELECT id,Name,Parent_Title__c 
    									FROM Playlist__c 
    									WHERE Version_Number__c = 1 and Parent_Title__c in: titleIds AND Playlist_Status__c = 'Active']){
    			mapTitleIdPlaylist.put(playlist.Parent_Title__c,playlist);
    		}
    		mapOfTitle = new Map<Id,Title__c>([Select Name,id,Content_Type__c from Title__c where Id IN :titleIds]);
    	}
    	
    		
    	
    	for(Local_Title__c lt : [SELECT id,name,Title__c,Title__r.Name,Title__r.Content_Type__c,Country__c,Language__c,Readiness__c,Playlist__c,Key__c
    				   FROM Local_Title__c
    				   WHERE Title__c IN :titleIds AND Country__c IN :countryIds AND  Language__c IN :languageIds AND External_Company__c = Null]){
    		String key = lt.Title__c+'_'+lt.Country__c+'_'+lt.Language__c;
    		mapOfExistingLTs.put(key,lt);
    	}
        
        List<Commercial_Avail__c> lstOfRPNewLT = new List<Commercial_Avail__c>();
    	Map<String,Local_Title__c> ltToUpsert = new Map<String,Local_Title__c>();
    	
    	for(Commercial_Avail__c rpRec : lstOfTriggerRPs){
    		String key = rpRec.Title__c+'_'+rpRec.Country_Lookup__c+'_'+rpRec.Languages__c;
    		Local_Title__c matchingLT;
    		if(mapOfExistingLTs.containskey(key)){
    			matchingLT = mapOfExistingLTs.get(key);
    			rpRec.Local_Title__c = matchingLT.Id;
    			
    			if(matchingLT.Playlist__c != null && rpRec.Playlist__c != matchingLT.Playlist__c){
    				rpRec.Playlist__c = matchingLT.Playlist__c;
    			}
    			
    			if(mapTitleIdPlaylist != null && mapTitleIdPlaylist.size() > 0 && mapTitleIdPlaylist.containskey(rpRec.Title__c)){
    				if(matchingLT.Playlist__c == null){
    					matchingLT.Playlist__c = mapTitleIdPlaylist.get(rpRec.Title__c).Id;
    					rpRec.Playlist__c = matchingLT.Playlist__c;
    					ltToUpsert.put(key,matchingLT);
    				}
    			}else{
    			   if(matchingLT.Title__r.Content_Type__c == 'Collection Features')
    				   rpRec.adderror(Label.WB_Playlist_Validation_on_Release_Plan+' '+matchingLT.Title__r.Name+'.');
    		    }
    		}else{
    			if(!ltToUpsert.containskey(key)){
    				matchingLT = new Local_Title__c();
    				matchingLT.Title__c = rpRec.Title__c;
    				matchingLT.Country__c = rpRec.Country_Lookup__c;
    				matchingLT.Language__c  = rpRec.Languages__c;
    				matchingLT.Local_Title__c = rpRec.Title_Alias__c != null ? rpRec.Title_Alias__c : mapOfTitle.get(rpRec.Title__c).name; // Added as part of ER-003828
    				matchingLT.name = matchingLT.Local_Title__c.length() > 80 ? matchingLT.Local_Title__c.substring(0,80) : matchingLT.Local_Title__c; // Added as part of ER-003828
    				matchingLT.Key__c = rpRec.Title_Video_Version__c+'_'+rpRec.Language_Code2__c+'_'+rpRec.Country_Code2__c;
    				if(mapTitleIdPlaylist != null && mapTitleIdPlaylist.size() > 0 && mapTitleIdPlaylist.containskey(rpRec.Title__c)){
    					matchingLT.Playlist__c = mapTitleIdPlaylist.get(rpRec.Title__c).Id;
    				}	
    				ltToUpsert.put(key,matchingLT);
    			}
    			lstOfRPNewLT.add(rpRec);
    		}
    	}
    	
    	if(ltToUpsert.values().size() > 0){
    		List<Local_Title__c> lstAllLTs = ltToUpsert.values();
    		Database.UpsertResult[] results = Database.upsert(lstAllLTs, Local_Title__c.Key__c);
    		for(Integer index = 0, size = results.size(); index < size; index++) {
    			if(results[index].isSuccess()) {
    				if(results[index].isCreated()) {
    					System.debug(lstAllLTs[index].Key__c+' was created');
    				} else {
    					System.debug(lstAllLTs[index].Key__c+' was updated');
    				}
    			}
    		}
    	}
    	
    	for(Commercial_Avail__c rp : lstOfRPNewLT){
    		String key = rp.Title__c+'_'+rp.Country_Lookup__c+'_'+rp.Languages__c;
    		if(ltToUpsert.containskey(key)){
    			rp.Local_Title__c = ltToUpsert.get(key).Id;
    			if(ltToUpsert.get(key).Playlist__c != null && rp.Playlist__c != ltToUpsert.get(key).Playlist__c){
    				rp.Playlist__c = ltToUpsert.get(key).Playlist__c;
    			}
    		}
    	}
    }
    
    // ER:10 := Update related client avails Playlist value. 
    public static void changePlaylistValueInRelatedCAs(List<commercial_avail__c> listReleasePlans,String action){
        
        Map<id,commercial_avail__c> mapReleaseplans = (Map<id,commercial_avail__c>)trigger.newmap;
        List<Client_Avail__c> listClientAvails = new List<Client_Avail__c>();
        Set<Id> releaseplanIds = new Set<Id>();
        
        for(commercial_avail__c rp : listReleasePlans){
            
            commercial_avail__c oldLt;
            if(action == 'Update')
                oldLt = (commercial_avail__c)trigger.oldmap.get(rp.id);
            if(action == 'Insert' || (action == 'Update' && oldLt.Playlist__c != rp.Playlist__c))
                releaseplanIds.add(rp.id);
        }
        for(Client_Avail__c ca : [SELECT id,Playlist__c,Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c in: releaseplanIds AND Parent_Client_avail__c = null 
                                  AND Lock_Playlist_Update__c=false AND (CA_Lifecycle__c = 'Active Future' OR CA_Lifecycle__c = 'Active Current')]){
                                      listClientAvails.add(new Client_Avail__c(id = ca.id,Playlist__c = mapReleaseplans.get(ca.Commercial_Avail__c).Playlist__c));
                                  }
        try{
            update listClientAvails;
        }
        catch(exception e){
            listReleasePlans[0].adderror(e.getmessage());
        }
    }
    /*
Author: Preeti jha
Date: 13th dec 2016
Description: CRRTS Phase 2
*/
    public static void setQueueToOwner(List<Commercial_Avail__c> listReleasePlan){
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
        Set<Id> localDataIds = new Set<Id>();
        Set<Id> titleIds = new Set<Id>();
        //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
        if(listReleasePlan != null && listReleasePlan.size() > 0){
            for(Commercial_Avail__c LocalData: listReleasePlan){
                setCountryid.add(LocalData.Country_Lookup__c);
                //Added for Query of Local Data and Title - ER-003578
                localDataIds.add(LocalData.Local_Title__c);
                titleIds.add(LocalData.Title__c);
            }
            Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, Digital_Owner__c, Physical_Owner__c,HBO_Override__c,Turner_Override__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
            //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
            Map<Id,Local_Title__c> mapIdLocalData = new Map<Id,Local_Title__c>([SELECT Id,LocalDisplayStudio__c FROM Local_Title__c WHERE Id IN :localDataIds LIMIT 50000]);
            Map<Id,Title__c> mapIdTitle = new Map<Id,Title__c>([SELECT Id,Display_StudioValue__c FROM Title__c WHERE Id IN :titleIds LIMIT 50000]);
            //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
            for(Commercial_Avail__c releasePlan: listReleasePlan){
                /* if(releasePlan.Title_Physical_Planning__c == 'Yes'){
if(allQueuesetting != null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Physical_Owner__c) != null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Physical_Owner__c).Value__c != null){
releasePlan.OwnerId = allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Physical_Owner__c).Value__c;
}
}
else{
if(allQueuesetting != null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Digital_Owner__c).Value__c != null){
releasePlan.OwnerId = allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Digital_Owner__c).Value__c;
}
}*/
                //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
                Boolean hboTurnerFlag = true;
                Map<String,WB_HBO_TURNER_Countries__c> mapHBOTURNERCountries = WB_HBO_TURNER_Countries__c.getAll();
                if(mapHBOTURNERCountries.containsKey(releasePlan.Country_Formula__c)){
                    String hboOverrideStudios = Label.HBOVal;
                    List<String> listHBOOverrideStudios = hboOverrideStudios.split(',');
                    String hboTurnerStudios = Label.TurnerVal;
                    List<String> listHBOTurnerStudios = hboTurnerStudios.split(',');
                    Boolean overrideFlag = false;
                    Boolean turnerFlag = false;
                    System.debug('releasePlan.Local_Title__c==='+releasePlan.Local_Title__c);
                    if(releasePlan.Local_Title__c != null){
                        if(listHBOOverrideStudios.contains(mapIdLocalData.get(releasePlan.Local_Title__c).LocalDisplayStudio__c)){
                            overrideFlag = true;
                        }
                        else if(listHBOTurnerStudios.contains(mapIdLocalData.get(releasePlan.Local_Title__c).LocalDisplayStudio__c)){
                            turnerFlag = true;
                        }
                    } else{
                        if(listHBOOverrideStudios.contains(mapIdTitle.get(releasePlan.Title__c).Display_StudioValue__c)){
                            overrideFlag = true;
                        }
                        else if(listHBOTurnerStudios.contains(mapIdTitle.get(releasePlan.Title__c).Display_StudioValue__c)){
                            turnerFlag = true;
                        }
                    }
                    if(overrideFlag){
                        releasePlan.OwnerId = allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).HBO_Override__c).Value__c;
                    } else if(turnerFlag){
                        releasePlan.OwnerId = allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Turner_Override__c).Value__c;
                    } else{
                        hboTurnerFlag = false;
                    }
                } else{
                    hboTurnerFlag = false;
                }
                if(!hboTurnerFlag){
                    //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
                    // ER-1680 Starts
                    if(releasePlan.Channel__c=='Physical'){
                        if(allQueuesetting!=null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Physical_Owner__c)!=null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Physical_Owner__c).Value__c!=null)
                            releasePlan.OwnerId = allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Physical_Owner__c).Value__c;
                    }  
                    else if(releasePlan.Channel__c=='EST'|| releasePlan.Channel__c=='Hotel'|| releasePlan.Channel__c=='PPV'|| releasePlan.Channel__c=='VODc' || releasePlan.Channel__c=='VODi'){
                        if(allQueuesetting!=null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Digital_Owner__c)!=null && allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Digital_Owner__c).Value__c!=null)
                            releasePlan.OwnerId = allQueuesetting.get(mapCountry.get(releasePlan.Country_Lookup__c).Digital_Owner__c).Value__c;
                    }
                    // ER-1680 Ends/ ER-1680 Ends
                    //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
                }
                //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
                //ER-002239 Start
                /*  if(releasePlan.MPM_Release_Date_Key__c == null && releasePlan.MRD_ID__c != null && releasePlan.MPMRD_Status__c != null && releasePlan.MPMRD_Status__c == 'Cancel'){
releasePlan.MRD_ID__c = null;
}*/  
                //ER-002239 End
            }
        }
    }
    
    /*
Author: Purushottam Gupta
Date: 27th Jan 2017
Description: As a part of CRRTS Phase 3: Dynamic update/create MPM Release Date on update/create of Release Plan and DVD Lacal Data on update/create of MPM Release Date    
*/
    //Start CRRT Phase 3 
    //Update MPM Release Date Key field on Update/Create Release Plan object only when associated Title have genric MPM 
    public static void UpdateRPMPMReleaseDateKey(List<Commercial_Avail__c> lstNewReleasePlan, map<Id,Commercial_Avail__c> mapOldReleasePlan){
        set<Id> setCount = new set<Id>();
        set<Id> setLang = new set<Id>();
        for(Commercial_Avail__c newRP : lstNewReleasePlan){
            newRP.Release_Locale__c = newRP.Title_Generic_MPM_Number__c != null ? newRP.Release_Locale__c : '';
            if(newRP.Release_Locale__c == null && newRP.Title_Generic_MPM_Number__c != null && newRP.Country_Lookup__c != null && newRP.Languages__c != null){
                setCount.add(newRP.Country_Lookup__c);
                setLang.add(newRP.Languages__c);
            }
            //set rollup flag on update
            if((newRP.Exclusive_Date__c != mapOldReleasePlan.get(newRP.Id).Exclusive_Date__c || newRP.Rights_End__c != mapOldReleasePlan.get(newRP.Id).Rights_End__c
                || newRP.Start_Date__c != mapOldReleasePlan.get(newRP.Id).Start_Date__c || newRP.End_Date__c != mapOldReleasePlan.get(newRP.Id).End_Date__c 
                || newRP.Status__c != mapOldReleasePlan.get(newRP.Id).Status__c) && newRP.MPM_Release_Date_Key__c != null  ){ //|| newRP.RP_MPMRD_Mismatch__c
                    newRP.MRD_Roll_up__c = True;
                }
            //ER-002239 Start
            /*if(newRP.MPM_Release_Date_Key__c == null && newRP.MRD_ID__c != null && newRP.MPMRD_Status__c != null && newRP.MPMRD_Status__c == 'Cancel'){
newRP.MRD_ID__c = null;
}*/
            //ER-002239 End
        }   
        
        if(setCount != null && setCount.size() > 0 && setLang != null && setLang.size() > 0){
            List<Rights_Group__c> lstLocale = new List<Rights_Group__c>([SELECT Release_Locale__c, Country__c, Language__c FROM Rights_Group__c WHERE Country__c IN:(setCount) AND Language__c IN:(setLang) LIMIT 50000]);        
            for(Commercial_Avail__c newRP: lstNewReleasePlan){
                for(Rights_Group__c locale : lstLocale){
                    if((newRP.Country_Lookup__c == locale.Country__c) && (newRP.Languages__c == locale.Language__c) && newRP.Title_Generic_MPM_Number__c != null){
                        //newRP.Release_Locale__c = locale.Release_Locale__c;
                        newRP.Release_Locale__c = newRP.Title_Generic_MPM_Number__c != null ? locale.Release_Locale__c : '';       
                        newRP.MRD_Roll_up__c = True;
                        break;
                    }
                }
         	}
        }
        
        //ER-007534 - Changes to update MRD Roll Up flag based on Premium Window field changes
        for(Commercial_Avail__c newRP: lstNewReleasePlan){
            
            if(newRP.Premium_Window__c != mapOldReleasePlan.get(newRP.Id).Premium_Window__c){
                if((newRP.Premium_Window__c && newRP.MRD_ID__c != null) || !newRP.Premium_Window__c){
                    newRP.MRD_Roll_up__c = true;
                }else{
                    newRP.MRD_Roll_up__c = false;
                }
            }
        }
    }      
    
    //Update MPM Release Date on Update/create of Release Plan
    public static void UpdateMRMReleaseDate(List<Commercial_Avail__c> lstReleasePlan){       
        try
        {
            // Activate the flag to deactivate release plan trigger after MRD roll-up 
            WB_CheckingDateOverlapController.isRunning_BatchMRMRollup = true;
            
            Set<Id> setMPM = new Set<Id>();
            Set<String> setMPMRelDateKey = new Set<String>();
            Set<Id> setCountry = new Set<Id>();
            Map<String,List<Commercial_Avail__c>> mapMPMList = new Map<String,List<Commercial_Avail__c>>();
            List<Commercial_Avail__c> premiumRPs = new List<Commercial_Avail__c>(); //ER-007534
            
            for(Commercial_Avail__c relPlan : lstReleasePlan){
                // Set of MPM Release Date Key      
                if(relPlan.MPM_Release_Date_Key__c != null){
                    setMPMRelDateKey.add(relPlan.MPM_Release_Date_Key__c);
                    setCountry.add(relPlan.Country_Lookup__c);
                }
                //ER-007534
                if(relPlan.Premium_Window__c){
                    premiumRPs.add(relPlan);
                }
            }
            
            if(setMPMRelDateKey != null && setMPMRelDateKey.size() > 0){
                // Getting all the RP having same MPM release date key       
                
                // Creating MPM of MPM release date key and there associated release plan
                for(Commercial_Avail__c commAvail : [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c, MRD_Roll_up__c,
                                                     MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,
                                                     Local_Title__r.Local_Theatrical_Release_Date__c, Local_Title__r.Local_TV_Air_Date__c
                                                     FROM Commercial_Avail__c 
                                                     WHERE Country_Lookup__c IN: (setCountry) AND MPM_Release_Date_Key__c IN: (setMPMRelDateKey) AND Premium_Window__c = False LIMIT 50000]) //ER-007534
                {
                    //Set of all MPM
                    setMPM.add(commAvail.Title__r.MPM__c);
                    
                    if(mapMPMList == null && mapMPMList.size() == 0){
                        mapMPMList.put(commAvail.MPM_Release_Date_Key__c,new List<Commercial_Avail__c>{commAvail});
                    }
                    else{
                        if(mapMPMList.containsKey(commAvail.MPM_Release_Date_Key__c)){
                            List<Commercial_Avail__c> lstRP = mapMPMList.get(commAvail.MPM_Release_Date_Key__c);
                            lstRP.add(commAvail);
                            mapMPMList.put(commAvail.MPM_Release_Date_Key__c,lstRP);
                        }
                        else{
                            mapMPMList.put(commAvail.MPM_Release_Date_Key__c,new List<Commercial_Avail__c>{commAvail});
                        }
                    }
                } 
            }
            
            //ER-007534
            List<Commercial_Avail__c> premiumRPsToCancelMRD = new List<Commercial_Avail__c>();
            for(Commercial_Avail__c pRP : premiumRPs){
                if(!mapMPMList.containsKey(pRP.MPM_Release_Date_Key__c)){
                    premiumRPsToCancelMRD.add(pRP);
                }    
            }
            
            if(mapMPMList != null && mapMPMList.size() > 0){            
                map<String,Commercial_Avail__c> mapMPM = new map<String,Commercial_Avail__c>();
                
                // fetching appropriate RP record for updating/create MPM Release Date
                for(string keyRP : mapMPMList.keySet() ) {
                    
                    // fetching appropriate RP record for update/create MPM Release Date if same key belong to more then 1 RP
                    //if(mapMPMList.get(keyRP).size() > 1){
                    //Condition as per the CRRT Phase7 requirement changes.
                    List<Commercial_Avail__c> lstRP = mapMPMList.get(keyRP);
                    Integer statusPriority = 0;
                    
                    for(Commercial_Avail__c commAvl : lstRP){
                        if(commAvl.Start_Date__c != null || commAvl.Exclusive_Date__c != null){
                            if(commAvl.Status__c == 'Confirmed' && statusPriority <= 5){
                                if(statusPriority == 5){
                                    //ER-002170 start
                                    if(commAvl.Start_Date__c != null){
                                        if(commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
                                            //keyStartDate.put(keyRP,commAvl.Start_Date__c)
                                            mapMPM.put(keyRP,commAvl); 
                                        }
                                    }
                                    else{
                                        if(commAvl.Exclusive_Date__c != null){
                                            if(commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
                                                //keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c);
                                                mapMPM.put(keyRP,commAvl);
                                            }
                                        }                      
                                    }
                                    //ER-002170 end
                                    /*  if(commAvl.Start_Date__c != null && commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
mapMPM.put(keyRP,commAvl); 
}else if(commAvl.Exclusive_Date__c != null && commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
mapMPM.put(keyRP,commAvl);
} */
                                }
                                else{
                                    mapMPM.put(keyRP,commAvl); 
                                    //keyStartDate.put(keyRP,commAvl.Start_Date__c); 
                                    //keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c); 
                                }  
                                statusPriority = 5;
                            }
                            else if(commAvl.Status__c == 'Tentative' && statusPriority <= 4){
                                if(statusPriority == 4){
                                    //ER-002170 start
                                    if(commAvl.Start_Date__c != null){
                                        if(commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
                                            //keyStartDate.put(keyRP,commAvl.Start_Date__c)
                                            mapMPM.put(keyRP,commAvl); 
                                        }
                                    }
                                    else{
                                        if(commAvl.Exclusive_Date__c != null){
                                            if(commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
                                                //keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c);
                                                mapMPM.put(keyRP,commAvl);
                                            }
                                        }                      
                                    }
                                    //ER-002170 end
                                    /*if(commAvl.Start_Date__c != null){
if(commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
keyStartDate.put(keyRP,commAvl.Start_Date__c);                         
}
}
if(commAvl.Exclusive_Date__c != null){
if(commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c); 
}  
}
if(commAvl.Start_Date__c != null && commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c)
mapMPM.put(keyRP,commAvl); 
else if(commAvl.Exclusive_Date__c != null && commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c)
mapMPM.put(keyRP,commAvl);*/
                                    
                                }
                                else
                                    mapMPM.put(keyRP,commAvl);     
                                statusPriority = 4;
                            }
                            else if(commAvl.Status__c == 'Not Releasing' && statusPriority <= 3){
                                if(statusPriority == 3){
                                    //ER-002170 start
                                    if(commAvl.Start_Date__c != null){
                                        if(commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
                                            //keyStartDate.put(keyRP,commAvl.Start_Date__c)
                                            mapMPM.put(keyRP,commAvl); 
                                        }
                                    }
                                    else{
                                        if(commAvl.Exclusive_Date__c != null){
                                            if(commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
                                                //keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c);
                                                mapMPM.put(keyRP,commAvl);
                                            }
                                        }                      
                                    }
                                    //ER-002170 end
                                }
                                else
                                    mapMPM.put(keyRP,commAvl); 
                                statusPriority = 3;
                            }
                            else if(commAvl.Status__c == 'Open' && statusPriority <= 2){
                                if(statusPriority == 2){
                                    //ER-002170 start
                                    if(commAvl.Start_Date__c != null){
                                        if(commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
                                            //keyStartDate.put(keyRP,commAvl.Start_Date__c)
                                            mapMPM.put(keyRP,commAvl); 
                                        }
                                    }
                                    else{
                                        if(commAvl.Exclusive_Date__c != null){
                                            if(commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
                                                //keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c);
                                                mapMPM.put(keyRP,commAvl);
                                            }
                                        }                      
                                    }
                                    //ER-002170 end
                                }
                                else
                                    mapMPM.put(keyRP,commAvl); 
                                statusPriority = 2;
                            }
                            else if(commAvl.Status__c == 'Draft' && statusPriority <= 1){
                                if(statusPriority == 1){
                                    //ER-002170 start
                                    if(commAvl.Start_Date__c != null){
                                        if(commAvl.Start_Date__c < mapMPM.get(keyRP).Start_Date__c){
                                            //keyStartDate.put(keyRP,commAvl.Start_Date__c)
                                            mapMPM.put(keyRP,commAvl); 
                                        }
                                    }
                                    else{
                                        if(commAvl.Exclusive_Date__c != null){
                                            if(commAvl.Exclusive_Date__c < mapMPM.get(keyRP).Exclusive_Date__c){
                                                //keyExclusiveDate.put(keyRP,commAvl.Exclusive_Date__c);
                                                mapMPM.put(keyRP,commAvl);
                                            }
                                        }                      
                                    }
                                    //ER-002170 end
                                }
                                else
                                    mapMPM.put(keyRP,commAvl);    
                                statusPriority = 1;
                            }
                            //Unchecked rollup field
                            commAvl.MRD_Roll_up__c = False;
                        }
                    }
                }  
                
                if(mapMPM != null && mapMPM.size() > 0 ){
                    List<MPM_Release_Date__c> lstMPMReleaseDateNew = new List<MPM_Release_Date__c>();
                    Map<String,MPM_Release_Date__c> mapMPMReleaseDate = new Map<String,MPM_Release_Date__c>();
                    Map<String,MPM_Release_Date__c> mapUpdateOptOut = new Map<String,MPM_Release_Date__c>();
                    // Creating and updating/create MPM Release Date
                    // 
                    for(MPM_Release_Date__c mpmRelDate : [SELECT Id, Key__c, MPM__c, Locale__c, Channel__c, Format__c, Language__c, Country__c, Avail_Start__c, Release_Start__c, Release_Status__c, Record_Status__c, EAI_Processing_Status__c, Opt_Out_Status__c, Opt_Out_Date__c, Earliest_Release_Plan_ID__c
                                                          FROM MPM_Release_Date__c 
                                                          WHERE MPM__c IN: (setMPM)
                                                          AND Channel__c != null
                                                          AND Format__c != null
                                                          AND Key__c != null
                                                          AND Record_Status__c = 'Active' LIMIT 50000]){
                                                              //WHERE Key__c IN: (mapMPM.keySet())]){
                                                              mpmRelDate.EAI_Processing_Status__c = 'Ready To Process';
                                                              //updated by Hari to convert key to uppercase
                                                              // updated by hari  for CAS to IPM bug fix
                                                              mapMPMReleaseDate.put(mpmRelDate.Key__c,mpmRelDate);  
                                                          }
                    if(mapMPMReleaseDate != null && mapMPMReleaseDate.size() > 0){     
                        for(string key : mapMPM.keySet() ) {                        
                            // Update MPM release date if its avaiable
                            if(mapMPMReleaseDate.containsKey(key)){
                                mapMPMReleaseDate.get(key).Earliest_Release_Plan_ID__c = mapMPM.get(key).Id;
                                mapMPMReleaseDate.get(key).Avail_Start__c = mapMPM.get(key).Exclusive_Date__c;
                                mapMPMReleaseDate.get(key).Release_Start__c =  mapMPM.get(key).Start_Date__c;
                                //ER-002734 Start
                                //Code commented, to stop TRD from Local Date to flow on MRD. Now the TRD will from 2 Key MRD to 4 Key MRD.
                                //mapMPMReleaseDate.get(key).Theatrical_Release_Date__c =  mapMPM.get(key).Local_Title__r.Local_Theatrical_Release_Date__c;
                                //mapMPMReleaseDate.get(key).TV_Airing_Date__c =  mapMPM.get(key).Local_Title__r.Local_TV_Air_Date__c;
                                //ER-002734 End
                                if((mapMPMReleaseDate.get(key).Release_Status__c =='Cancel' || mapMPMReleaseDate.get(key).Release_Status__c =='Open' || mapMPMReleaseDate.get(key).Release_Status__c =='Tentative' 
                                    || mapMPMReleaseDate.get(key).Release_Status__c =='Confirmed'|| mapMPMReleaseDate.get(key).Release_Status__c == 'Not Releasing') 
                                   && mapMPM.get(key).Status__c == 'Draft')
                                    mapMPMReleaseDate.get(key).Release_Status__c =  'Cancel';
                                else
                                    mapMPMReleaseDate.get(key).Release_Status__c =  mapMPM.get(key).Status__c;
                                
                                if(mapMPMReleaseDate.get(key).Locale__c != null && (mapMPMReleaseDate.get(key).Locale__c).startsWith('na_'))
                                    mapMPMReleaseDate.get(key).Language__c = null;
                                else
                                    mapMPMReleaseDate.get(key).Language__c = mapMPM.get(key).Languages__c;
                                
                                //add record in Opt Out map for update
                                mapUpdateOptOut.put(key,mapMPMReleaseDate.get(key));
                            }
                            // Cretae MPM release date if its not avaiable
                            else{
                                MPM_Release_Date__c newMPMRelDt = new MPM_Release_Date__c();
                                newMPMRelDt.Earliest_Release_Plan_ID__c = mapMPM.get(key).Id;
                                newMPMRelDt.Avail_Start__c = mapMPM.get(key).Exclusive_Date__c;
                                newMPMRelDt.Release_Start__c = mapMPM.get(key).Start_Date__c;
                                newMPMRelDt.Release_Status__c = mapMPM.get(key).Status__c;
                                newMPMRelDt.MPM__c = mapMPM.get(key).Title__r.MPM__c;
                                newMPMRelDt.Channel__c = mapMPM.get(key).Channel__c;
                                newMPMRelDt.Format__c = mapMPM.get(key).Format__c;                            
                                newMPMRelDt.Country__c = mapMPM.get(key).Country_Lookup__c;  
                                newMPMRelDt.Locale__c = mapMPM.get(key).Release_Locale__c;
                                //ER-002734 Start
                                //Code commented, to stop TRD from Local Date to flow on MRD. Now the TRD will from 2 Key MRD to 4 Key MRD.
                                //newMPMRelDt.Theatrical_Release_Date__c =  mapMPM.get(key).Local_Title__r.Local_Theatrical_Release_Date__c;
                                //newMPMRelDt.TV_Airing_Date__c =  mapMPM.get(key).Local_Title__r.Local_TV_Air_Date__c;
                                //ER-002734 End
                                if(newMPMRelDt.Locale__c!= null && (newMPMRelDt.Locale__c).startsWith('na_'))
                                    newMPMRelDt.Language__c = null;
                                else
                                    newMPMRelDt.Language__c = mapMPM.get(key).Languages__c;
                                newMPMRelDt.Record_Status__c = 'Active';
                                newMPMRelDt.EAI_Processing_Status__c = 'Ready To Process';
                                lstMPMReleaseDateNew.add(newMPMRelDt);                       
                            }
                        }     
                        
                        Database.Saveresult[] updateResults = Database.update(mapMPMReleaseDate.values(),false);
                        for(Integer index = 0;index < updateResults.size();index++){
                            Database.SaveResult updateResult = updateResults[index]; 
                            if(!updateResult.isSuccess()){
                                for(Database.Error err : updateResult.getErrors()) {
                                    System.debug('Exception: MPMrd Update ->'+ err.getMessage());
                                    break;
                                }
                            }
                        }
                    }   
                    else{
                        for(String key : mapMPM.keySet() ) {
                            MPM_Release_Date__c newMPMRelDt = new MPM_Release_Date__c(); 
                            newMPMRelDt.Earliest_Release_Plan_ID__c = mapMPM.get(key).Id;
                            newMPMRelDt.Avail_Start__c = mapMPM.get(key).Exclusive_Date__c;
                            newMPMRelDt.Release_Start__c = mapMPM.get(key).Start_Date__c;
                            newMPMRelDt.Release_Status__c = mapMPM.get(key).Status__c;
                            newMPMRelDt.MPM__c = mapMPM.get(key).Title__r.MPM__c;
                            newMPMRelDt.Channel__c = mapMPM.get(key).Channel__c;
                            newMPMRelDt.Format__c = mapMPM.get(key).Format__c;
                            newMPMRelDt.Country__c = mapMPM.get(key).Country_Lookup__c;  
                            newMPMRelDt.Locale__c = mapMPM.get(key).Release_Locale__c;
                            //ER-002734 Start
                            //Code commented, to stop TRD from Local Date to flow on MRD. Now the TRD will from 2 Key MRD to 4 Key MRD.
                            //newMPMRelDt.Theatrical_Release_Date__c =  mapMPM.get(key).Local_Title__r.Local_Theatrical_Release_Date__c;
                            //newMPMRelDt.TV_Airing_Date__c =  mapMPM.get(key).Local_Title__r.Local_TV_Air_Date__c;
                            //ER-002734 End
                            if((newMPMRelDt.Locale__c).startsWith('na_'))
                                newMPMRelDt.Language__c = null;
                            else
                                newMPMRelDt.Language__c = mapMPM.get(key).Languages__c;                         
                            newMPMRelDt.Record_Status__c = 'Active';
                            newMPMRelDt.EAI_Processing_Status__c = 'Ready To Process';
                            lstMPMReleaseDateNew.add(newMPMRelDt); 
                        }                    
                    }
                    if(lstMPMReleaseDateNew != null && lstMPMReleaseDateNew.size() > 0){
                        // updated by hari  for CAS to IPM bug fix
                        Database.Saveresult[] insertResults = Database.insert(lstMPMReleaseDateNew,false);
                        for(Integer index=0;index<insertResults.size();index++){
                            Database.SaveResult insertResult = insertResults[index]; 
                            if(!insertResult.isSuccess()){
                                for(Database.Error err : insertResult.getErrors()) {
                                    System.debug('Exception: MPMrd Insert ->'+ err.getMessage());
                                    System.debug('record is Error ->'+ lstMPMReleaseDateNew[index]);
                                    break;
                                }
                            }
                        }
                        //updated by hari  for CAS to IPM bug fix
                    }

					//ER-003201 Start
                    //Snippet added to flow TRD from 2 Key MRDs to 4 Key MRDs as per the MPM and Country passesd
                    if((setMPM != null && setMPM.size()>0) && (setCountry != null && setCountry.size()>0))
                    {
                        WB_UntrackedMarketMRDCreation.trdRollUp2KeyTo4Key(setMPM,setCountry);
                    }
                    //ER-003201 End
                     //update optout status
                    if(lstMPMReleaseDateNew != null && lstMPMReleaseDateNew.size() > 0 && mapUpdateOptOut != null && mapUpdateOptOut.size() > 0){
                        lstMPMReleaseDateNew.addAll(mapUpdateOptOut.values());
                        UpdateOptOutStatus(lstMPMReleaseDateNew);
                    }
                    //ER-003201 Start
                    //Code added as the control was not going in the condition due to check of null for mapUpdateOptOut Map
                    else if(lstMPMReleaseDateNew != null && lstMPMReleaseDateNew.size() > 0 && mapUpdateOptOut != null && mapUpdateOptOut.size() == 0){
                        //else if(lstMPMReleaseDateNew != null && lstMPMReleaseDateNew.size() > 0 && mapUpdateOptOut == null && mapUpdateOptOut.size() == 0){
                        //ER-003201 End
                        UpdateOptOutStatus(lstMPMReleaseDateNew);
                    }
                    else if(lstMPMReleaseDateNew.size() == 0 && mapUpdateOptOut != null && mapUpdateOptOut.size() > 0){
                        UpdateOptOutStatus(mapUpdateOptOut.values());
                    }
                }
            }
            
            //ER-007534
            UpdateMRMReleaseDateToCancel(premiumRPsToCancelMRD);
        }
        catch(Exception ex){
            System.debug('Error while creating/updating MPM Releasedate records '+ ex);
        }
    }
    
    //ER-002239 Start
    public static void UpdateMRMReleaseDateToCancel(List<Commercial_Avail__c> lstReleasePlan){  
        try{
            WB_CheckingDateOverlapController.isRunning_BatchMRMRollup = true; //De-activate RP trigger
            Set<Id> setMPMRelDateWithOutKey = new Set<Id>();
            list<Commercial_Avail__c> updateReleasePlanToRemoveMPMRD = new list<Commercial_Avail__c>();
            list<Commercial_Avail__c> updateReleasePlanToRemoveMPMRD2 = new list<Commercial_Avail__c>();
            
            for(Commercial_Avail__c relPlan : lstReleasePlan){
                //if(relPlan.MPM_Release_Date_Key__c == null && relPlan.MRD_ID__c != null)
                setMPMRelDateWithOutKey.add(relPlan.MRD_ID__c);  
                
            }
            
            
            if(setMPMRelDateWithOutKey != null && setMPMRelDateWithOutKey.size() > 0){ 
                Map<Id,MPM_Release_Date__c> mapMPMReleaseDateToCancel = new Map<Id,MPM_Release_Date__c>();  
                for(MPM_Release_Date__c mpmRelDate : [SELECT Id, Release_Status__c
                                                      FROM MPM_Release_Date__c 
                                                      WHERE ID IN: (setMPMRelDateWithOutKey)
                                                      
                                                      LIMIT 10000]){
                                                          mpmRelDate.Release_Status__c =  'Cancel';
                                                          mapMPMReleaseDateToCancel.put(mpmRelDate.Id,mpmRelDate);  
                                                          
                                                      }
                if(mapMPMReleaseDateToCancel != null && mapMPMReleaseDateToCancel.size() > 0){
                    Database.Saveresult[] updateResults = Database.update(mapMPMReleaseDateToCancel.values(),false);
                    for(Integer index = 0;index < updateResults.size();index++){
                        Database.SaveResult updateResult = updateResults[index]; 
                        if(!updateResult.isSuccess()){
                            for(Database.Error err : updateResult.getErrors()) {
                                System.debug('Exception: MPMrd Update ->'+ err.getMessage());
                                break;
                            }
                        }
                    }
                }
                
                for(Commercial_Avail__c relPlan : [SELECT Id, MRD_Roll_up__c, MPM_Release_Date_Key__c FROM Commercial_Avail__c WHERE MRD_ID__c IN: (setMPMRelDateWithOutKey) AND MRD_ID__r.Release_Status__c = 'Cancel' AND (MPM_Release_Date_Key__c = null OR Premium_Window__c = True)  LIMIT 10000]){ //ER-007534
                    relPlan.MRD_ID__c = null;
                    relPlan.MRD_Roll_up__c = false; //ER-007534
                    
                    if(updateReleasePlanToRemoveMPMRD.size() < 5000){
                        updateReleasePlanToRemoveMPMRD.add(relPlan);
                    }
                    else if(updateReleasePlanToRemoveMPMRD2.size() < 5000){
                        updateReleasePlanToRemoveMPMRD2.add(relPlan);
                    }
                    
                }
                
                if(updateReleasePlanToRemoveMPMRD != null && updateReleasePlanToRemoveMPMRD.size() > 0){        
                    Database.Saveresult[] rpUpdateResults = Database.update(updateReleasePlanToRemoveMPMRD,false);
                    for(Integer index = 0;index < rpUpdateResults.size();index++){
                        Database.SaveResult updateResult = rpUpdateResults[index]; 
                        if(!updateResult.isSuccess()){
                            for(Database.Error err : updateResult.getErrors()) {
                                System.debug('Exception: RP Update ->'+ err.getMessage());
                                break;
                            }
                        }
                    }  
                }
                
                if(updateReleasePlanToRemoveMPMRD2 != null && updateReleasePlanToRemoveMPMRD2.size() > 0){
                    Database.Saveresult[] rpUpdateResults2 = Database.update(updateReleasePlanToRemoveMPMRD2,false);
                    for(Integer index = 0;index < rpUpdateResults2.size();index++){
                        Database.SaveResult updateResult = rpUpdateResults2[index]; 
                        if(!updateResult.isSuccess()){
                            for(Database.Error err : updateResult.getErrors()) {
                                System.debug('Exception: RP Update ->'+ err.getMessage());
                                break;
                            }
                        }
                    } 
                }
                
            }  
            
            WB_CheckingDateOverlapController.isRunning_BatchMRMRollup = false; //activate RP trigger
        }catch(Exception ex){
            System.debug('Error while creating/updating MPM Releasedate records '+ ex);
        }
    }
    //ER-002239 End
    
    public static void UpdateLocalData(Set<Id> lstMPMRelDateId){  
        List<MPM_Release_Date__c> lstMPMRelDate = new List<MPM_Release_Date__c>([SELECT Id, MPM__c, Locale__c, Record_Status__c, Format__c, Release_Status__c, Release_Start__c FROM MPM_Release_Date__c WHERE Id IN: (lstMPMRelDateId) LIMIT 50000]);
        
        Set<String> setMPM = new Set<String>();
        Set<String> setRelLocale = new Set<String>();
        //Date dtReleaseStart;
        set<String> setLocalKey = new set<String>();
        
        for(MPM_Release_Date__c mpmRelDt : lstMPMRelDate){
            setMPM.add(mpmRelDt.MPM__c);
            setRelLocale.add(mpmRelDt.Locale__c);
        }
        
        if(setMPM != null && setMPM.size() > 0 && setRelLocale != null && setRelLocale.size() > 0){
            List<Title__c> lstRP = new List<Title__c>([SELECT ID, MPM__c, Video_Version__c FROM Title__c WHERE MPM__c IN: (setMPM) AND Video_Version__c != null LIMIT 50000]);
            List<Rights_Group__c> lstLocale = new List<Rights_Group__c>([SELECT ID, Name FROM Rights_Group__c WHERE Release_Locale__c IN: (setRelLocale) LIMIT 50000]);
            
            if(lstRP != null && lstRP.size() > 0 && lstLocale != null && lstLocale.size() > 0){
                for(Title__c rp : lstRP){
                    for(Rights_Group__c locale : lstLocale){
                        setLocalKey.add(rp.Video_Version__c + '_' + (locale.Name).toLowerCase()); 
                    }
                }
            }                 
        }
        
        if(setLocalKey != null && setLocalKey.size() > 0){
            List<Local_Title__c> lstLocalData = new List<Local_Title__c>([SELECT Id, Key__c, Local_DVD_Release_Date__c FROM Local_Title__c WHERE Key__c IN: (setLocalKey) AND External_Company__c = Null LIMIT 50000]);
            
            if(lstLocalData != null && lstLocalData.size() > 0){
                for(Local_Title__c locTle : lstLocalData){        
                    locTle.Initial_Physical_Release_Date__c =null;
                }
                
                Database.Saveresult[] updateResults = Database.update(lstLocalData,false);
                for(Integer index=0;index<updateResults.size();index++){
                    Database.SaveResult updateResult = updateResults[index]; 
                    if(!updateResult.isSuccess()){
                        for(Database.Error err : updateResult.getErrors()) {
                            System.debug('Exception: Local Data Update ->'+ err.getMessage());
                            break;
                        }
                    }
                }
            }            
        } 
    }
    
    //End CRRT Phase 3
    
    /*
Method: UpdateReleaseStatus and UpdateOptOutStatus
Created by: Preeti Jha
Created date: 5th May 2017
Description: INTRODUCE CANCEL STATUS TO MPM RELEASE DATE OBJECT and Update Opt Out Status field.
*/
    public static void UpdateReleaseStatus(Map<Id,MPM_Release_Date__c> mapMPMReleaseDateOld, List<MPM_Release_Date__c> lstMPMReleaseDateNew){
        if( lstMPMReleaseDateNew.size() > 0 && lstMPMReleaseDateNew != null){
            for(MPM_Release_Date__c mpmReleaseDate : lstMPMReleaseDateNew){
                if(mpmReleaseDate.Record_Status__c == 'Active'){
                    if(mpmReleaseDate.Release_Status__c != mapMPMReleaseDateOld.get(mpmReleaseDate.Id).Release_Status__c){
                        if((mapMPMReleaseDateOld.get(mpmReleaseDate.Id).Release_Status__c =='Open' || mapMPMReleaseDateOld.get(mpmReleaseDate.Id).Release_Status__c =='Tentative' || mapMPMReleaseDateOld.get(mpmReleaseDate.Id).Release_Status__c =='Confirmed' || mapMPMReleaseDateOld.get(mpmReleaseDate.Id).Release_Status__c =='Not Releasing') && mpmReleaseDate.Release_Status__c =='Draft' ){
                            mpmReleaseDate.Release_Status__c ='Cancel';
                        }
                    }
                }
            }
        }
    }
    
    //For updating MPMrd optout status
    public static void UpdateOptOutStatus(List<MPM_Release_Date__c> lstNewMPMReleaseDateNew){
        //ER-003201 Start
        //Code added to get key and mrd from passed MRD list
        List<MPM_Release_Date__c> lstMPMReleaseDateNew = new List<MPM_Release_Date__c>();
        Set<Id> setMRDId = new Set<Id>();
        for(MPM_Release_Date__c mrd : lstNewMPMReleaseDateNew)
            setMRDId.add(mrd.Id);
        for(MPM_Release_Date__c mrd : [SELECT Id,Key__c,Locale__c,MPM__c,Country__c,Channel__c,Format__c,Release_Status__c,Opt_Out_Status__c,Opt_Out_Date__c FROM MPM_Release_Date__c WHERE Id IN :setMRDId])
            lstMPMReleaseDateNew.add(mrd);
        //ER-003201 End
        isFirstTime = false;
        set<Id> setMPMId = new set<Id>();
        set<String> setRelLocaleId = new set<String>();
        
        Map<String,MPM_Release_Date__c> mpmNewMap = new Map<String,MPM_Release_Date__c>();
        Map<String,String> statusMap = new Map<String,String>();
        
        Map<Id,String> mapUpdatedMPMRDKey = new Map<Id,String>();
        set<Id> setUpdatedMRDCntry = new set<Id>();
        
        Map<String,Id> mapMPMRDId = new Map<String,Id>();
        
        for(MPM_Release_Date__c mpmRelDt : lstMPMReleaseDateNew){
            setMPMId.add(mpmRelDt.MPM__c);
            setRelLocaleId.add(mpmRelDt.Locale__c);
            
            String key = mpmRelDt.MPM__c + '_' + mpmRelDt.Locale__c +'_'+ mpmRelDt.Channel__c;
            mpmNewMap.put(key,mpmRelDt);
            
            mapMPMRDId.put(mpmRelDt.Key__c,mpmRelDt.Id);
            
            if(mpmRelDt.Key__c != null){
                mapUpdatedMPMRDKey.put(mpmRelDt.Id, mpmRelDt.Key__c);
                setUpdatedMRDCntry.add(mpmRelDt.Country__c);
            }
        }
        
        
        List<MPM_Release_Date__c> mpmRDByMPMLocal = new List<MPM_Release_Date__c>([SELECT Id, MPM__c, Key__c, Format__c,Locale__c, Channel__c, Opt_Out_Status__c, Release_Status__c, Record_Status__c,Opt_Out_Date__c
                                                                                   FROM MPM_Release_Date__c 
                                                                                   WHERE MPM__c IN :setMPMId 
                                                                                   AND Locale__c IN : setRelLocaleId
                                                                                   AND Channel__c != null 
                                                                                   AND Format__c != null LIMIT 50000]);
        
        if(mpmRDByMPMLocal != null && mpmRDByMPMLocal.size() >0){
            map<Id,MPM_Release_Date__c> mapMPMReleaseDtUpt = new map<Id,MPM_Release_Date__c>();
            map<String,Boolean> mapSetOptOutYes = new map<String,Boolean>();
            set<Id> setMPMReleasedateId = new set<Id>();
            
            for(MPM_Release_Date__c mpmRD : mpmRDByMPMLocal){
                String subKey = mpmRD.MPM__c + '_' + mpmRD.Locale__c +'_'+ mpmRD.Channel__c;
                if(mpmNewMap.get(subKey) == null) continue;
                
                if(mpmRD.Format__c != '4KBD'){
                    if(mpmRD.Release_Status__c == 'Not Releasing'){
                        if(statusMap.get(subKey) == 'Not Releasing' || statusMap.get(subKey) == null){
                            statusMap.put(subKey,'Not Releasing');
                        }else{
                            statusMap.put(subKey,'Releasing');
                        }
                    }else{
                        if(statusMap.get(subKey) != null && statusMap.get(subKey) != 'Blank'){
                            statusMap.put(subKey,'Releasing');
                        }else{
                            statusMap.put(subKey,'Blank');
                        }
                    }
                }
            }
            for(MPM_Release_Date__c mpmRD : mpmRDByMPMLocal){
                String subKey = mpmRD.MPM__c + '_' + mpmRD.Locale__c +'_'+ mpmRD.Channel__c;
                
                if(mpmNewMap.get(subKey) == null) continue;
                
                if(mpmRD.Format__c != '4KBD'){
                    if(statusMap.get(subKey) != 'Blank'){
                        if(statusMap.get(subKey) == 'Not Releasing'){
                            // ER-001327 - MPM out status Post Production change,Fix for CAs To IPM interface.
                            if(mpmRD.Opt_Out_Date__c == null)
                            {
                                mpmRD.Opt_Out_Status__c = 'Yes';
                                mpmRD.Opt_Out_Date__c = System.Today();
                            }
                        }else{
                            mpmRD.Opt_Out_Status__c = 'No';
                            mpmRD.Opt_Out_Date__c = null;
                        }
                    }else{
                        mpmRD.Opt_Out_Status__c = 'No';
                        mpmRD.Opt_Out_Date__c = null;
                    }
                    
                    mapMPMReleaseDtUpt.put(mpmRD.Id,mpmRD);
                }
                
                if(mpmRD.Channel__c == 'Physical' && mpmRD.Release_Status__c == 'Cancel')
                    setMPMReleasedateId.add(mpmRD.Id);
            }
            
            if(mapMPMReleaseDtUpt != null || mapMPMReleaseDtUpt.size() > 0){
                Database.Saveresult[] updateResults = Database.update(mapMPMReleaseDtUpt.values(),false);
                for(Integer index=0;index<updateResults.size();index++){
                    Database.SaveResult updateResult = updateResults[index]; 
                    if(!updateResult.isSuccess()){
                        mapUpdatedMPMRDKey.remove(updateResult.getId());
                        for(Database.Error err : updateResult.getErrors()) {
                            System.debug('Exception: MPMrd Opt Out Update ->'+ err.getMessage());
                            break;
                        }
                    }
                }
            }
            
            //Set all releated RP MRD_Roll_up__c field to unchecked
            list<Commercial_Avail__c> lstUpdateRP = new list<Commercial_Avail__c>();
            list<Commercial_Avail__c> lstUpdateRP2 = new list<Commercial_Avail__c>();
            for(Commercial_Avail__c rp : [SELECT Id, MRD_Roll_up__c, MPM_Release_Date_Key__c, Country_Lookup__c,Premium_Window__c FROM Commercial_Avail__c WHERE Country_Lookup__c IN : (setUpdatedMRDCntry) AND MPM_Release_Date_Key__c IN: (mapUpdatedMPMRDKey.values()) LIMIT 50000]){
                rp.MRD_Roll_up__c = FALSE;
                rp.MRD_ID__c = (mapMPMRDId.containsKey(rp.MPM_Release_Date_Key__c) && !rp.Premium_Window__c)  ? mapMPMRDId.get(rp.MPM_Release_Date_Key__c) : null ; //ER-007534
                
                if(lstUpdateRP.size() < 10000)
                    lstUpdateRP.add(rp);
                else if(lstUpdateRP2.size() < 10000)
                    lstUpdateRP2.add(rp);
            }
            
            Database.Saveresult[] rpUpdateResults = Database.update(lstUpdateRP,false);
            for(Integer index = 0;index < rpUpdateResults.size();index++){
                Database.SaveResult updateResult = rpUpdateResults[index]; 
                if(!updateResult.isSuccess()){
                    for(Database.Error err : updateResult.getErrors()) {
                        System.debug('Exception: RP Update ->'+ err.getMessage());
                        break;
                    }
                }
            }  
            
            if(lstUpdateRP2 != null && lstUpdateRP2.size() > 0){
                Database.Saveresult[] rpUpdateResults2 = Database.update(lstUpdateRP2,false);
                for(Integer index = 0;index < rpUpdateResults2.size();index++){
                    Database.SaveResult updateResult = rpUpdateResults2[index]; 
                    if(!updateResult.isSuccess()){
                        for(Database.Error err : updateResult.getErrors()) {
                            System.debug('Exception: RP Update ->'+ err.getMessage());
                            break;
                        }
                    }
                } 
            }
            
            // Deactivate the flag to activate release plan trigger after MRD roll-up 
            WB_CheckingDateOverlapController.isRunning_BatchMRMRollup = false;
            
            //Update local data
            if(setMPMReleasedateId != null && setMPMReleasedateId.size() > 0 )
                UpdateLocalData(setMPMReleasedateId);
        }
        
    }   
    
    //ER-007484 - Map Release Locale to Release Plan on Insert Operation
    public static void addReleaseLocalOnRP(List<Commercial_Avail__c> lstNewReleasePlan){
        set<Id> setCount = new set<Id>();
        set<Id> setLang = new set<Id>();
        for(Commercial_Avail__c newRP : lstNewReleasePlan){
            if(newRP.Title_Generic_MPM_Number__c != null && newRP.Country_Lookup__c != null && newRP.Languages__c != null){
                setCount.add(newRP.Country_Lookup__c);
                setLang.add(newRP.Languages__c);
            }
        }
        
        if(setCount.size() > 0 && setLang.size() > 0){
            Map<String,String> localeMap = new Map<String,String>();
            for(Rights_Group__c lc : [SELECT Release_Locale__c, Country__c, Language__c FROM Rights_Group__c WHERE Country__c IN:(setCount) AND Language__c IN:(setLang) LIMIT 50000]){
                if(lc.Country__c != null && lc.Language__c != null){
                    localeMap.put(lc.Country__c+'_'+lc.Language__c,lc.Release_Locale__c);
                }
            }
            for(Commercial_Avail__c newRP: lstNewReleasePlan){
                String lcKey = newRP.Country_Lookup__c+'_'+newRP.Languages__c;
                if(localeMap.containsKey(lcKey)){   
                    newRP.Release_Locale__c = newRP.Title_Generic_MPM_Number__c != null ? localeMap.get(lcKey) : null;       
                    newRP.MRD_Roll_up__c = (newRP.Title_Generic_MPM_Number__c != null && !newRP.Premium_Window__c) ? True : False;
                }
            }
        }
    }       
}