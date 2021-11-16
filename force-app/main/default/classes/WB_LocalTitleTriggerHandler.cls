/*******************************************************************************************************************************************
* File Name     :   WB_LocalTitleTriggerHandler
* Description   :   Handler class for WB_LocalTitleTrigger
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
*                                               ER-473 
* 1.0     28 March 2016      CTS                Handler class to update the 'Changes' field on Title object when 'Key Dates' section fields gets updates in Local data object.
* 2.0     13th dec 2016      Preeti(CTS)        CRRTS phase 2 requirment, added method setQueueToOwner()
* 3.0     08 DEC 2017        Astha Singh        ER-1305 - Add Controlled Vocabulary to Rating Systems and Ratings
* 4.0     17 Jan 2018        Trupti             SINC1435031
* 5.0     9/27/2018          Astha Singh        SINC1724150 
* 6.0     06/19/2019         Mayank Desai       ER-003047 Change to US DVD Release Date on Title Object
********************************************************************************************************************************************/




public class WB_LocalTitleTriggerHandler {
    
    //Result List
    public List<Title__c> ResultList = new List<Title__c>();
    public Title__c parentTitle = new Title__c();
    //public List<Local_Title__c> newLocalTitleList;
    public Map<Id,Title__c> NewTitleMap = new Map<Id,Title__c>();
    // Create a set of Title Ids
    public Set<String> SetTitleID = new Set<String>();
    // Add unique title Id's to List
    public List<Title__c> ListTitleId = new List<Title__c>();
    
    // ER 473 changes :- Insert the 'Changes' field values on Title object when one of the below fields gets updates in Local Data object.
    public void OnInsert(List<Local_Title__c> newLocalTitleList){
        
        for(Local_Title__c LocTitle : newLocalTitleList){
            SetTitleID.add(LocTitle.Title__c);
        }
        
        for(Title__c title: [select ID,US_Theatrical_Release_Date_New__c,US_BD_Release_Date__c,US_TV_Air_Date__c,US_UV_Publish_Date__c,US_Box_Office__c,US_DVD_Release_Date__c,US_Pay_TV_Start_Date__c,TV_Title__c,Season__c,Episode__c,Season_Override__c,Episode_Override__c from Title__c where ID IN : SetTitleID]){
            ListTitleId.add(title);  
            NewTitleMap.put(title.id, title);
        }
        
        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ Start**/
        Map<id,Local_Title__c> mapLocalData = new Map<id,Local_Title__c>([select id,Name,Title__c,Country__r.Name,Language__r.Name,Local_Theatrical_Release_Date__c,Local_BD_Release_Date__c,Local_TV_Air_Date__c,
                                                                          UV_Published_Date__c,Local_Box_Office__c,Local_DVD_Release_Date__c,Local_Pay_TV_Start_Date__c, Initial_Physical_Release_Date__c, Initial_VOD_Release_Date__c, Initial_EST_Release_Date__c,ATOM_Season__c,ATOM_Episode__c from Local_Title__c where id in: newLocalTitleList]);                        
        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ End**/        
        
        for(Local_Title__c localTitle : newLocalTitleList){
            Local_Title__c tempLocTitle = mapLocalData.get(localTitle.id);
            if(tempLocTitle.Country__r.Name == Label.Country_USA && tempLocTitle.Language__r.Name == Label.Language_English && localTitle.External_Company__c == null){ //ER-003047 - Changes
                /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ Start**/
                parentTitle = NewTitleMap.get(localTitle.Title__c);
                if(parentTitle!=null){   
                    if((localTitle.Local_Theatrical_Release_Date__c !=NULL || localTitle.Local_Box_Office__c != NULL || localTitle.Local_DVD_Release_Date__c != NULL || localTitle.Initial_Physical_Release_Date__c != NULL || localTitle.Initial_VOD_Release_Date__c != NULL || localTitle.Initial_EST_Release_Date__c != NULL || localTitle.TV_Title__c != NULL ||localTitle.Local_Pay_TV_Start_Date__c != NULL 
                        || (localTitle.ATOM_Season__c != Null && !parentTitle.Season_Override__c) || (localTitle.ATOM_Episode__c != Null && !parentTitle.Episode_Override__c) ) || (Label.Value_True_Or_False == 'true')){
                        
                        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ END**/
                        
                        parentTitle.US_Theatrical_Release_Date_New__c = localTitle.Local_Theatrical_Release_Date__c;
                        parentTitle.US_BD_Release_Date__c = localTitle.Local_BD_Release_Date__c;
                        parentTitle.US_TV_Air_Date__c = localTitle.Local_TV_Air_Date__c;
                        parentTitle.US_UV_Publish_Date__c = localTitle.UV_Published_Date__c;
                        parentTitle.US_Box_Office__c = localTitle.Local_Box_Office__c;
                        
                        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ Start**/
                        Date USDVDReleaseDate;
                        if(localTitle.Initial_Physical_Release_Date__c !=NULL){
                            USDVDReleaseDate=localTitle.Initial_Physical_Release_Date__c ;
                        }
                        else if(localTitle.Local_DVD_Release_Date__c!=NULL){
                            USDVDReleaseDate=localTitle.Local_DVD_Release_Date__c;
                        }
                        else if(localTitle.Initial_VOD_Release_Date__c!=NULL){
                            USDVDReleaseDate=localTitle.Initial_VOD_Release_Date__c;
                        }
                        else{
                            USDVDReleaseDate=localTitle.Initial_EST_Release_Date__c;
                        }
                        //parentTitle.US_DVD_Release_Date__c = localTitle.Local_DVD_Release_Date__c;
                        parentTitle.US_DVD_Release_Date__c = USDVDReleaseDate;
                        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ End**/
                        
                        parentTitle.US_Pay_TV_Start_Date__c = localTitle.Local_Pay_TV_Start_Date__c;
                        parentTitle.TV_Title__c = localTitle.TV_Title__c;
                        
                        // ER-003023 - Source Local Data Season & Episode from ATOM Product API - change - by Tejasvini Start
                        if(localTitle.ATOM_Season__c != Null && !parentTitle.Season_Override__c){
                            parentTitle.Season__c = String.valueOf(localTitle.ATOM_Season__c.intValue());
                        }
                        if(localTitle.ATOM_Episode__c != Null && !parentTitle.Episode_Override__c){
                            parentTitle.Episode__c = localTitle.ATOM_Episode__c;
                        }
                        // ER-003023 - Source Local Data Season & Episode from ATOM Product API - change - by Tejasvini End
                        
                        ResultList.add(parentTitle);
                    }
                }
            }
            
        }
        if(ResultList.size()>0)
            Database.update(ResultList); 
    }
    
    // ER 473 changes :- Updates the 'Changes' field values on Title object when one of the below fields gets updates in Local Data object.
    public void OnUpdate(List<Local_Title__c> newLocalTitleList, Map<Id,Local_Title__c> OldLocMap){
        
        SetTitleID.clear();
        
        if(newLocalTitleList !=null && newLocalTitleList.size()>0){
            for(Local_Title__c LocTitle : newLocalTitleList){
                SetTitleID.add(LocTitle.Title__c);
            }
        }
        
        for(Title__c title: [select ID,US_Theatrical_Release_Date_New__c,US_BD_Release_Date__c,US_TV_Air_Date__c,US_UV_Publish_Date__c,US_Box_Office__c,US_DVD_Release_Date__c,US_Pay_TV_Start_Date__c,TV_Title__c,Season__c,Episode__c,Season_Override__c,Episode_Override__c from Title__c where ID IN : SetTitleID]){
            ListTitleId.add(title);
            NewTitleMap.put(title.id, title);
        }
        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ Start**/
        Map<id,Local_Title__c> mapLocalData = new Map<id,Local_Title__c>([select id,Name,Title__c,Country__r.Name,Language__r.Name,Local_Theatrical_Release_Date__c,Local_BD_Release_Date__c,Local_TV_Air_Date__c,
                                                                          UV_Published_Date__c,Local_Box_Office__c,Local_DVD_Release_Date__c,Local_Pay_TV_Start_Date__c, Initial_Physical_Release_Date__c, Initial_VOD_Release_Date__c, Initial_EST_Release_Date__c,ATOM_Season__c,ATOM_Episode__c from Local_Title__c where id in: newLocalTitleList]);
        /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ End**/                                            
        for(Local_Title__c objLocal : newLocalTitleList) {
            
            Local_Title__c tempLocTitle = mapLocalData.get(objLocal.id);
            
            if(tempLocTitle.Country__r.Name == Label.Country_USA && tempLocTitle.Language__r.Name == Label.Language_English && objLocal.External_Company__c == null){ //ER-003047 - Changes
                parentTitle = NewTitleMap.get(objLocal.Title__c);
                if(parentTitle!=null){
                    if((objLocal.Local_Theatrical_Release_Date__c!=OldLocMap.get(objLocal.Id).Local_Theatrical_Release_Date__c ||
                        objLocal.Local_BD_Release_Date__c!=OldLocMap.get(objLocal.Id).Local_BD_Release_Date__c || 
                        objLocal.Local_TV_Air_Date__c!=OldLocMap.get(objLocal.Id).Local_TV_Air_Date__c ||
                        objLocal.UV_Published_Date__c!=OldLocMap.get(objLocal.Id).UV_Published_Date__c ||
                        objLocal.Local_Box_Office__c!=OldLocMap.get(objLocal.Id).Local_Box_Office__c ||
                        objLocal.Local_Pay_TV_Start_Date__c!=OldLocMap.get(objLocal.Id).Local_Pay_TV_Start_Date__c ) || 
                       (Label.Value_True_Or_False == 'true') || 
                       objLocal.TV_Title__c!=OldLocMap.get(objLocal.Id).TV_Title__c ||
                       /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ Start**/
                       objLocal.Initial_Physical_Release_Date__c!=OldLocMap.get(objLocal.Id).Initial_Physical_Release_Date__c ||
                       objLocal.Local_DVD_Release_Date__c!=OldLocMap.get(objLocal.Id).Local_DVD_Release_Date__c ||
                       objLocal.Initial_VOD_Release_Date__c!=OldLocMap.get(objLocal.Id).Initial_VOD_Release_Date__c ||
                       objLocal.Initial_EST_Release_Date__c!=OldLocMap.get(objLocal.Id).Initial_EST_Release_Date__c ||
                       /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ End**/
                       (objLocal.ATOM_Season__c != OldLocMap.get(objLocal.Id).ATOM_Season__c && !parentTitle.Season_Override__c) ||
                       (objLocal.ATOM_Episode__c != OldLocMap.get(objLocal.Id).ATOM_Episode__c && !parentTitle.Episode_Override__c)
                      ){
                          
                          parentTitle.US_Theatrical_Release_Date_New__c = objLocal.Local_Theatrical_Release_Date__c;
                          parentTitle.US_BD_Release_Date__c = objLocal.Local_BD_Release_Date__c;
                          parentTitle.US_TV_Air_Date__c = objLocal.Local_TV_Air_Date__c;
                          parentTitle.US_UV_Publish_Date__c = objLocal.UV_Published_Date__c;
                          parentTitle.US_Box_Office__c = objLocal.Local_Box_Office__c;
                          /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ Start**/
                          Date USDVDReleaseDate;
                          if(objLocal.Initial_Physical_Release_Date__c !=NULL){
                              USDVDReleaseDate=objLocal.Initial_Physical_Release_Date__c ;
                          }
                          else if(objLocal.Local_DVD_Release_Date__c!=NULL){
                              USDVDReleaseDate=objLocal.Local_DVD_Release_Date__c;
                          }
                          else if(objLocal.Initial_VOD_Release_Date__c!=NULL){
                              USDVDReleaseDate=objLocal.Initial_VOD_Release_Date__c;
                          }
                          else{
                              USDVDReleaseDate=objLocal.Initial_EST_Release_Date__c;
                          }
                          parentTitle.US_DVD_Release_Date__c = USDVDReleaseDate;
                          //parentTitle.US_DVD_Release_Date__c = objLocal.Local_DVD_Release_Date__c;
                          /**Changed by Mayank Desai for ER-003047 on 06/25/2019+ End**/
                          parentTitle.US_Pay_TV_Start_Date__c = objLocal.Local_Pay_TV_Start_Date__c;
                          parentTitle.TV_Title__c = objLocal.TV_Title__c;
                          
                          // ER-003023 - Source Local Data Season & Episode from ATOM Product API - change - by Tejasvini Start
                          if(objLocal.ATOM_Season__c != OldLocMap.get(objLocal.Id).ATOM_Season__c && !parentTitle.Season_Override__c){
                              if(objLocal.ATOM_Season__c == Null ){
                                  parentTitle.Season__c = String.valueOf(objLocal.ATOM_Season__c);
                              }
                              if(objLocal.ATOM_Season__c != Null ){
                                  parentTitle.Season__c = String.valueOf(objLocal.ATOM_Season__c.intValue());
                              }
                          }
                          if(objLocal.ATOM_Episode__c != OldLocMap.get(objLocal.Id).ATOM_Episode__c && !parentTitle.Episode_Override__c){
                              parentTitle.Episode__c = objLocal.ATOM_Episode__c;
                          }
                          // ER-003023 - Source Local Data Season & Episode from ATOM Product API - change - by Tejasvini End
                          ResultList.add(parentTitle);
                      }
                }
            }
        }
        if(ResultList.size()>0)
            Database.update (ResultList);
    }
    
    // ER-10 : Assign id of Playlist version 1 of Title to Local Title Playlist field.
    public static void assignDefaultPlaylist(List<Local_Title__c> listLocalTitles)
    {
        set<Id> titleIds = new set<Id>();
        Map<Id,Playlist__c> mapTitlePlaylist = new Map<Id,Playlist__c>();
        for(Local_Title__c localaTitle : listLocalTitles)
            titleIds.add(localaTitle.Title__c);
        for(Playlist__c playlist : [SELECT id,Parent_Title__c,Parent_Title__r.Content_Type__C,Playlist_Status__c from Playlist__c 
                                    where Parent_Title__c in: titleIds and version_number__C = 1
                                    AND Parent_Title__r.Content_Type__C in: Label.WB_Playlist_Content_Type_Labels.split(',')  
                                    AND Playlist_Status__c = 'Active'])
        {
            mapTitlePlaylist.put(playlist.Parent_Title__c,playlist);
        }
        if(mapTitlePlaylist != null && mapTitlePlaylist.size() > 0)
        {
            for(Local_Title__c localaTitle : listLocalTitles)
            {
                if(mapTitlePlaylist.containskey(localaTitle.Title__c))
                    localaTitle.Playlist__c = mapTitlePlaylist.get(localaTitle.Title__c).id;
            }
        }
    }
    
    // ER - 10 : On changes of Local BD Release date on Episode Local Data, reset recalculate flag in Season Client avail.
    public void resetClientAvailFlag(List<Local_Title__c> listLocalTitles){
        List<Local_Title__c> listFetchedLocalTitles = [SELECT id,Country__r.name, Language__r.name,Title_Content_Type__c,Local_TV_Air_Date__c,Title__c,Local_Category__c,Parent_Local_Data__c
                                                       FROM Local_Title__c where id in: listLocalTitles];
        Map<Id,Client_Avail__c> toUpdateClientAvailsMap = new Map<Id,Client_Avail__c>();
        List<Title__c> toUpdateTitles = new List<Title__c>();
        Set<Id> setLocalTitlesLocalCategory = new Set<Id>();
        List<Id> caIds = new List<Id>();
        Set<String> listPossibleStatus = new Set<String>(Label.WB_Client_Avail_Status.split(','));
        
        for(Local_Title__c lt : listFetchedLocalTitles)
        {
            Local_Title__c oldLt = (Local_Title__c)trigger.oldmap.get(lt.id);
            if(lt.Title_Content_Type__c == 'Episode'){
                if(lt.Local_TV_Air_Date__c != oldLt.Local_TV_Air_Date__c && lt.Country__r.name == 'USA' && lt.Language__r.name == 'English')
                    toUpdateTitles.add(new Title__c(id=lt.Title__c,US_TV_Air_Date__c=lt.Local_TV_Air_Date__c));
                else if(lt.Local_TV_Air_Date__c != oldLt.Local_TV_Air_Date__c)
                    setLocalTitlesLocalCategory.add(lt.id);
            }
        }
        if(toUpdateTitles.size() > 0){
            update toUpdateTitles;
            List<Client_Avail__c> listCAUpdateFlag = new List<Client_Avail__c>();
            for(Client_Avail__c clientAvail : [Select id,Recalculate_Playlist_Avails__c,Parent_Client_Avail__c from Client_Avail__c 
                                               where Local_Title__c in (Select id from Local_Title__c where Title__c in: toUpdateTitles)
                                               AND Local_Data_Category_Picklist__c = 'TV Day After US' AND Parent_Client_Avail__c != null 
                                               AND Parent_Client_Avail__r.Status__c in: listPossibleStatus 
                                               AND (CA_Lifecycle__c = 'Active Future' OR CA_Lifecycle__c = 'Active Current')]){
                                                   if(!toUpdateClientAvailsMap.containsKey(clientAvail.Parent_Client_Avail__c) && clientAvail.Parent_Client_Avail__c != null){    
                                                       toUpdateClientAvailsMap.put(clientAvail.Parent_Client_Avail__c,new Client_Avail__c(id=clientAvail.Parent_Client_Avail__c,Recalculate_Playlist_Avails__c = 'Update Local Data',Recalculation_Status__c=false));
                                                   }
                                               }
        }
        if(setLocalTitlesLocalCategory.size() > 0){
            for(Client_Avail__c clientAvail : [Select id,Recalculate_Playlist_Avails__c,Parent_Client_Avail__c 
                                               FROM Client_Avail__c WHERE Local_Title__c in: setLocalTitlesLocalCategory 
                                               AND Local_Data_Category_Picklist__c = 'TV Day After Local' AND Parent_Client_Avail__c != null
                                               AND Parent_Client_Avail__r.Status__c in: listPossibleStatus
                                               AND (CA_Lifecycle__c = 'Active Future' OR CA_Lifecycle__c = 'Active Current')]){
                                                   if(!toUpdateClientAvailsMap.containsKey(clientAvail.Parent_Client_Avail__c)){
                                                       toUpdateClientAvailsMap.put(clientAvail.Parent_Client_Avail__c,new Client_Avail__c(id=clientAvail.Parent_Client_Avail__c,Recalculate_Playlist_Avails__c = 'Update Local Data',Recalculation_Status__c=false));
                                                   }
                                               }
            
        }
        //update toUpdateClientAvailsMap.values(); 
        WB_ClientAvailPriceHandler.recursiveUpdate = true;//SINC1590762 
        Database.Saveresult[] saveResult  = Database.update(toUpdateClientAvailsMap.values(), false);
        WB_ClientAvailPriceHandler.recursiveUpdate = false;//SINC1590762
    }
    
    // ER:10 : Method used to update the Playlist value on related Release plan of Local Data
    public void changePlaylistValueInRPs(List<Local_Title__c> listLocalTitles,String action)
    {
        Map<id,Local_Title__c> mapLocaTitles = (Map<id,Local_Title__c>)trigger.newmap;
        List<commercial_avail__c> listReleaseplans = new List<commercial_avail__c>();
        Set<Id> localTitleIds = new Set<Id>();
        
        for(Local_Title__c lt : listLocalTitles){
            
            Local_Title__c oldLt;
            if(action == 'Update')
                oldLt = (Local_Title__c)trigger.oldmap.get(lt.id);
            if(action == 'Insert' || (action == 'Update' && oldLt.Playlist__c != lt.Playlist__c))
                localTitleIds.add(lt.id);
        }
        if(localTitleIds != null && !localTitleIds.isEmpty()){ //CRRT Team added this to avoid too many soql query for RP creation.
            for(commercial_avail__c rp : [SELECT id,Playlist__c,Local_Title__c from Commercial_avail__c where Local_Title__c in: localTitleIds
                                          AND Lock_Playlist_Update__c=false]){
                                              listReleaseplans.add(new Commercial_avail__c(id = rp.id,Playlist__c = mapLocaTitles.get(rp.Local_Title__c).Playlist__c));
                                          }
        }
        try{
            update listReleaseplans;
        }
        catch(exception e){
            listLocalTitles[0].adderror(e.getmessage());
        }
    }
    
    //ER-006850 - CAS-Restrict SDS Local Data records visibility to all CAS and ECLM business user - Start
    public static void setSDSQueueToOwner(List<Local_Title__c> listLocalTitles){
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        
        if(listLocalTitles != null && listLocalTitles.size() > 0){
            for(Local_Title__c LocalDatawithcountry: listLocalTitles){
                if(LocalDatawithcountry.Country__c != null)
                    setCountryid.add(LocalDatawithcountry.Country__c);
            }
            if(setCountryid != null && setCountryid.size() > 0){
                Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, SDS_Owner__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
                for(Local_Title__c LocalData: listLocalTitles){
                    if(LocalData.Country__c != null && LocalData.External_Company__c != null){
                        if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(LocalData.Country__c).SDS_Owner__c) != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).SDS_Owner__c).Value__c != null){
                            LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).SDS_Owner__c).Value__c;
                        }
                    }
                }
            }
        }
    }
    //ER-006850 - CAS-Restrict SDS Local Data records visibility to all CAS and ECLM business user - End
    
    public static void setQueueToOwner(List<Local_Title__c> listLocalTitles){
        Map<string, WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        set<id> setCountryid = new set<id>();
        
        if(listLocalTitles != null && listLocalTitles.size() > 0){
            for(Local_Title__c LocalDatawithcountry: listLocalTitles){
                if(LocalDatawithcountry.Country__c != null)
                    setCountryid.add(LocalDatawithcountry.Country__c);
            }
            if(setCountryid != null && setCountryid.size() > 0){
                Map<Id, Country__c> mapCountry = new Map<ID, Country__c>([SELECT Id, Name, Digital_Owner__c, Physical_Owner__c,HBO_Override__c,Turner_Override__c FROM Country__c Where Id IN: setCountryid LIMIT 10000]);
                for(Local_Title__c LocalData: listLocalTitles){
                    
                    if(LocalData.External_Company__c != null)
                        continue;
                    //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
                    Boolean hboTurnerFlag = true; 
                    Map<String,WB_HBO_TURNER_Countries__c> mapHBOTURNERCountries = WB_HBO_TURNER_Countries__c.getAll();
                    if(mapHBOTURNERCountries.containsKey(LocalData.CountryF__c)){
                        String hboOverrideStudios = Label.HBOVal;
                        List<String> listHBOOverrideStudios = hboOverrideStudios.split(',');
                        String hboTurnerStudios = Label.TurnerVal;
                        List<String> listHBOTurnerStudios = hboTurnerStudios.split(',');
                        Boolean overrideFlag = false;
                        Boolean turnerFlag = false;
                        if(listHBOOverrideStudios.contains(LocalData.LocalDisplayStudio__c)){
                            overrideFlag = true;
                        }
                        else if(listHBOTurnerStudios.contains(LocalData.LocalDisplayStudio__c)){
                            turnerFlag = true;
                        }
                        if(overrideFlag){
                            LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).HBO_Override__c).Value__c;
                        } else if(turnerFlag){
                            LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).Turner_Override__c).Value__c;
                        } else{
                            hboTurnerFlag = false;
                        }
                    } else{
                        hboTurnerFlag = false;
                    }
                    if(!hboTurnerFlag){
                        //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
                        if(LocalData.Title_Physical_Planning__c == 'Yes' && LocalData.Country__c != null){
                            if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c) != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c).Value__c != null){
                                LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).Physical_Owner__c).Value__c;
                            }
                        }
                        //else if(LocalData.Title_Digital_Planning__c == 'Yes' && LocalData.Country__c != null){
                        else if(LocalData.Country__c != null){
                            if(allQueuesetting != null && allQueuesetting.size() > 0 && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c).Value__c != null){
                                LocalData.OwnerId = allQueuesetting.get(mapCountry.get(LocalData.Country__c).Digital_Owner__c).Value__c;
                            }
                        }
                    }
                }
                //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) START
            }
            //ER-003578(HBO/Turner - Restrict Village Roadshow Access for HBO) END
        }
    }
    
    //***********************ER-1305 Add Controlled Vocabulary to Rating Systems and Ratings : Start************************
    public static void setLongLocalRating(List<Local_Title__c> newLocalTitleList, List<Local_Title__c> oldLocalTitleList)
    {
        
        Map<String, String> mapDRSRwithLR = new Map<String, String>();                  
        List<Ratings__c> lstRatingTable = [SELECT Id,Content_Type__c,Rating_System__c,Long_Local_Rating__c,Rating_ID__c,
                                           Short_Local_Rating__c,Language__c FROM Ratings__c];
        map<String,Set<String>> mapRSwithRC = new map<String,Set<String>>();
        
        for(Ratings__c rating: lstRatingTable){
            //String key = rating.Content_Type__c+rating.Rating_System__c+rating.Short_Local_Rating__c;
            if(rating.Rating_System__c!=null && rating.Short_Local_Rating__c!=null && rating.Language__c!=null){
                String key = rating.Rating_System__c+rating.Short_Local_Rating__c+ rating.Language__c;
                if(rating.Long_Local_Rating__c!=null)
                    mapDRSRwithLR.put(key.toUpperCase(),rating.Long_Local_Rating__c);
                else
                    mapDRSRwithLR.put(key.toUpperCase(),rating.Short_Local_Rating__c);
                
                if(!mapRSwithRC.isEmpty() && mapRSwithRC.containsKey(rating.Rating_System__c.toUpperCase()))
                    mapRSwithRC.get(rating.Rating_System__c.toUpperCase()).add(rating.Short_Local_Rating__c.toUpperCase());
                else{
                    Set<String> listRelatedRCode = new Set<String>();
                    listRelatedRCode.add(rating.Short_Local_Rating__c.toUpperCase());
                    mapRSwithRC.put(rating.Rating_System__c.toUpperCase(),listRelatedRCode);
                } 
                
            }  
        }
        
        map<Id,Id> mapLDIdwithCountryID = new map<Id,Id>();
        for(Local_Title__c ltitle: newLocalTitleList){                
            mapLDIdwithCountryID.put(ltitle.Id,ltitle.Country__c);
        }
        Map<Id, Country__c> mapCountryDetail =  new Map<ID, Country__c>([SELECT ID,Name,Default_Feature_Rating_Systems__c,Valid_Rating_Systems__c,Default_TV_Rating_System__c 
                                                                         FROM Country__c WHERE Id IN :mapLDIdwithCountryID.values()]);
        
        
        setAllRatings(newLocalTitleList,mapCountryDetail);
        
        
        for(Local_Title__c ltitle: newLocalTitleList){
            
            Local_Title__c oldltitle = new Local_Title__c();
            if(trigger.isUpdate){
                oldltitle = (Local_Title__c)trigger.oldMap.get(ltitle.Id); 
            } 
            
            if( !mapLDIdwithCountryID.isEmpty() && mapLDIdwithCountryID.get(ltitle.id)!=null){
                if(!mapCountryDetail.isEmpty() && mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id))!=null){
                    Set<String> listRatings = new Set<String>();
                    if(mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id)).Valid_Rating_Systems__c!=null){                            
                        listRatings.addAll(mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id)).Valid_Rating_Systems__c.split(';'));
                    }
                    if(mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id)).Default_Feature_Rating_Systems__c!=null){
                        listRatings.add(mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id)).Default_Feature_Rating_Systems__c);
                    }
                    if(mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id)).Default_TV_Rating_System__c!=null){
                        listRatings.add(mapCountryDetail.get(mapLDIdwithCountryID.get(ltitle.Id)).Default_TV_Rating_System__c);
                    }
                    
                    Set<String> upperCaseRatings = new Set<String>(); 
                    for(String s : listRatings){
                        upperCaseRatings.add(s.toUpperCase());
                    }
                    listRatings.clear();
                    listRatings.addAll(upperCaseRatings);
                    
                    if(!lstRatingTable.isEmpty() && ltitle.Local_Rating_System__c!=null && ltitle.Local_Rating__c!=null && (ltitle.Local_Rating_System__c!=oldltitle.Local_Rating_System__c ||ltitle.Local_Rating__c !=oldltitle.Local_Rating__c ||ltitle.Rating_Reason__c !=oldltitle.Rating_Reason__c )){
                        if(!mapRSwithRC.isEmpty() && mapRSwithRC.containsKey(ltitle.Local_Rating_System__c.toUpperCase())){
                            if(!mapRSwithRC.get(ltitle.Local_Rating_System__c.toUpperCase()).isEmpty()){
                                if(!listRatings.isEmpty())
                                {  
                                    if(listRatings.contains(ltitle.Local_Rating_System__c.toUpperCase()))
                                    {
                                        ltitle.Digital_Rating_System__c=ltitle.Local_Rating_System__c;
                                        //commented by Hari -  As of now buisness dont want  physical ratings and system   to populate  with atom values 
                                        //ltitle.Physical_Rating_System__c=ltitle.Local_Rating_System__c;
                                        if(!String.isBlank(ltitle.Local_Rating__c)){
                                            if(mapRSwithRC.get(ltitle.Local_Rating_System__c.toUpperCase()).contains(ltitle.Local_Rating__c.toUpperCase())){
                                                ltitle.Digital_Rating_Short__c=ltitle.Local_Rating__c;
                                                if(ltitle.Rating_Reason__c!=null)
                                                    ltitle.Digital_Rating_Reason__c= ltitle.Rating_Reason__c;//SINC1724150 
                                                //commented by Hari -  As of now buisness dont want  physical ratings and system to populate  with atom values 
                                                // ltitle.Physical_Rating_Short__c=ltitle.Local_Rating__c;
                                            }
                                        }
                                    }
                                    
                                }   
                            }
                        }
                    }
                    
                    if(!listRatings.isEmpty()){
                        
                        if(ltitle.Digital_Rating_System__c!=null && ltitle.Language__c!=null && (trigger.isInsert ||(trigger.isUpdate && (ltitle.Digital_Rating_System__c!=oldltitle.Digital_Rating_System__c||ltitle.Digital_Rating_Short__c!=oldltitle.Digital_Rating_Short__c) ))){
                            if(listRatings.contains(ltitle.Digital_Rating_System__c.toUpperCase())){
                                if(ltitle.Digital_Rating_Short__c!=null){                                     
                                    String ratingKey = ltitle.Digital_Rating_System__c+ltitle.Digital_Rating_Short__c+ltitle.Language__c;
                                    if(mapDRSRwithLR.containsKey(ratingKey.toUpperCase()) && mapDRSRwithLR.get(ratingKey.toUpperCase())!=null)                                            
                                        ltitle.Digital_Rating_Long__c=mapDRSRwithLR.get(ratingKey.toUpperCase());
                                    else
                                        ltitle.Digital_Rating_Long__c=ltitle.Digital_Rating_Short__c;
                                }
                            }
                            else{                                             
                                ltitle.addError(' The rating system you selected does not match the allowable rating system for this country. ');
                            }
                        }
                        if(ltitle.Digital_Rating_System__c==null){
                            ltitle.Digital_Rating_Long__c=null;
                        }
                        if(ltitle.Physical_Rating_System__c!=null && (trigger.isInsert ||(trigger.isUpdate && (ltitle.Physical_Rating_System__c!=oldltitle.Physical_Rating_System__c || ltitle.Physical_Rating_Short__c!=oldltitle.Physical_Rating_Short__c))) ){
                            if(listRatings.contains(ltitle.Physical_Rating_System__c.toUpperCase())){
                                if(ltitle.Physical_Rating_Short__c!=null){
                                    // updated by hariduring testing of ER-002595 Dec-14-2018  : fix for Post production Physical long rating population issue added  "+ltitle.Language__c" below.
                                    String ratingKey = ltitle.Physical_Rating_System__c+ltitle.Physical_Rating_Short__c+ltitle.Language__c;                                            
                                    if(mapDRSRwithLR.containsKey(ratingKey.toUpperCase()) && mapDRSRwithLR.get(ratingKey.toUpperCase())!=null)
                                        ltitle.Physical_Rating_Long__c=mapDRSRwithLR.get(ratingKey.toUpperCase());
                                    else
                                        ltitle.Physical_Rating_Long__c=ltitle.Physical_Rating_Short__c;
                                }
                            }
                            else{
                                ltitle.addError(' The rating system you selected does not match the allowable rating system for this country. ');
                                system.debug('2nd case');
                            }
                        }
                        if(ltitle.Physical_Rating_System__c==null){
                            ltitle.Physical_Rating_Long__c=null;
                        }
                        
                    }
                    
                }
            }
        }
        
        //ER-002170 :  Variable added to avoid recursion to fix too many query rows.
        recursiveUpdateLongLocalRating = true;
    }
    
    public static void setAllRatings(List<Local_Title__c> newLocalTitleList, Map<Id, Country__c> mapCountryDetail ){
        for(Local_Title__c lt : newLocalTitleList){
            
            String contentType='';
            if(lt.Title_Content_Type__c!=null){
                if(lt.Title_Content_Type__c.equalsIgnoreCase('Collection TV') ||lt.Title_Content_Type__c.equalsIgnoreCase('Episode')||
                   lt.Title_Content_Type__c.equalsIgnoreCase('Season')){
                       contentType='TV';   
                   }
                else if(lt.Title_Content_Type__c.equalsIgnoreCase('Collection Features') ||lt.Title_Content_Type__c.equalsIgnoreCase('Feature')){               
                    contentType='Feature';  
                } 
            }
            if(!String.isBlank(contentType)){
                if(!mapCountryDetail.isEmpty() && mapCountryDetail.get(lt.Country__c)!=null ){
                    if(trigger.isInsert){
                        if(contentType.equalsIgnorecase('Feature')){
                            if(mapCountryDetail.get(lt.Country__c).Default_Feature_Rating_Systems__c!=null){
                                
                                //lt.Digital_Rating_System__c=mapCountryDetail.get(lt.Country__c).Default_Feature_Rating_Systems__c;
                                //lt.Physical_Rating_System__c=mapCountryDetail.get(lt.Country__c).Default_Feature_Rating_Systems__c;
                            }
                        }
                        else{
                            if(mapCountryDetail.get(lt.Country__c).Default_TV_Rating_System__c!=null){                            
                                //lt.Digital_Rating_System__c=mapCountryDetail.get(lt.Country__c).Default_TV_Rating_System__c;                            
                                //lt.Physical_Rating_System__c=mapCountryDetail.get(lt.Country__c).Default_TV_Rating_System__c;
                            }
                        }
                    } 
                }
            }
            
            if(lt.Physical_Rating_System__c !=null && lt.Physical_Rating_Short__c!=null && lt.Digital_Rating_System__c==null){
                lt.Digital_Rating_System__c=lt.Physical_Rating_System__c ;
                lt.Digital_Rating_Short__c=lt.Physical_Rating_Short__c;
                if(!String.isBlank(lt.Physical_Rating_Reason__c))
                    lt.Digital_Rating_Reason__c=lt.Physical_Rating_Reason__c;
                
            }
        } 
    }
    
    //*************************ER-1305 Add Controlled Vocabulary to Rating Systems and Ratings : End****************************
    
    
    //SINC1435031 
    //Added On - 1/17/2018
    public void updateisReleaseDatesChangedFlag(List<Local_Title__c> newLT){
        for(Local_Title__c localData: newLT){
            if(trigger.isUpdate){
                Local_Title__c oldLocalData = (Local_Title__c)trigger.oldMap.get(localData.Id);
                
                if(localData.Initial_Physical_Release_Date__c != oldLocalData.Initial_Physical_Release_Date__c) 
                    localData.isReleaseDatesChanged__c = true;
                else if(localData.Initial_Physical_Release_Date__c== null && localData.Local_DVD_Release_Date__c != oldLocalData.Local_DVD_Release_Date__c )
                    localData.isReleaseDatesChanged__c = true;      
                else if(localData.Initial_Physical_Release_Date__c== null && localData.Local_DVD_Release_Date__c== null && localData.Initial_VOD_Release_Date__c != oldLocalData.Initial_VOD_Release_Date__c)
                    localData.isReleaseDatesChanged__c = true;
                else if (localData.Initial_Physical_Release_Date__c== null && localData.Local_DVD_Release_Date__c== null && localData.Initial_VOD_Release_Date__c== null && localData.Initial_EST_Release_Date__c != oldLocalData.Initial_EST_Release_Date__c )
                    localData.isReleaseDatesChanged__c = true; 
            }
            if(trigger.isInsert && (localData.Initial_Physical_Release_Date__c != null || localData.Local_DVD_Release_Date__c != null || localData.Initial_VOD_Release_Date__c != null || localData.Initial_EST_Release_Date__c != NULL))
                localData.isReleaseDatesChanged__c = true;
        }
    }
    
    public void  validatePriceCode(Map<Id,Local_Title__c> newMap,Map<Id,Local_Title__c> oldMap){
        
        if(WB_ClientAvailPriceHandler.recursiveUpdate || WB_ClientAvailPriceHandler.recursiveInsert || WB_ClientAvailPriceHandler.recursiveDelete || WB_ClientAvailPriceHandler.isCADateChange){
            return;
        }
        
        List<String> countries = new List<String>();
        List<String> contentTypes = new List<String>();
        List<String> priceCodes = new List<String>();
        Map<String,Local_Title__c> ltMap = new Map<String,Local_Title__c>();
        
        for(Id recId:newMap.keySet()){
            Local_Title__c newRec = newMap.get(recId);
            Local_Title__c oldRec = oldMap.get(recId);
            if((newRec.Title_Content_Type__c == 'Feature' || newRec.Title_Content_Type__c == 'Season') &&
               newRec.Price_Code__c != null && newRec.Price_Code__c.trim().length() > 0 && newRec.Price_Code__c != oldRec.Price_Code__c){
                   countries.add(newRec.Country__c);
                   contentTypes.add(newRec.Title_Content_Type__c);
                   priceCodes.add(newRec.Price_Code__c);
                   
                   ltMap.put((newRec.Country__c+newRec.Title_Content_Type__c+newRec.Price_Code__c).toUpperCase(),newRec);
               }
        }
        
        if(ltMap.size() > 0){
            Profile prof = [Select Id,Name from Profile Where Id=:Userinfo.getProfileId() Limit 1];
            if(prof == null || prof.Name == 'SFDC System' || prof.Name =='SAP Integration API Only' ||  prof.Name =='SFDC Sales Services' 
               || prof.Name == 'System Administrator' || prof.Name == 'SFDC Support Level 1' || prof.Name == 'SFDC Support Level 2')
                return;
            
            List<Pricing__c> pricingList = [Select Id,Name,Country__c,Content_Type__c From Pricing__c Where Country__c IN :countries AND Name IN :priceCodes AND Content_Type__c IN :contentTypes AND Price_Code_Status__c = 'Active'];
            Map<String,Pricing__c> pricingMap = new Map<String,Pricing__c>();
            for(Pricing__c pricing:pricingList){
                pricingMap.put((pricing.Country__c+pricing.Content_Type__c+pricing.Name).toUpperCase(),pricing);
            }
            
            for(String key:ltMap.keySet()){
                if(pricingMap.get(key) == null){
                    Local_Title__c lt = ltMap.get(key);
                    lt.addError('Invalid price code '+lt.Price_Code__c);                    
                }   
            }
        }
        
    }
    
    public void validateLocalTitleLongDescriptionUpdate(Map<Id,Local_Title__c> newMap,Map<Id,Local_Title__c> oldMap){
        
        Profile prof = [Select Id,Name from Profile Where Id=:Userinfo.getProfileId() Limit 1];
        
        for(Local_Title__c localDataRec :newMap.values()){
            Local_Title__c oldRec = oldMap.get(localDataRec.Id);
            
            if(localDataRec.Local_Title__c != oldRec.Local_Title__c && localDataRec.Readiness__c == 'Confirmed' && prof != Null){
                
                if(prof.Name == 'SAP Integration API Only'){
                    localDataRec.Local_Title__c = oldRec.Local_Title__c;
                }else if(localDataRec.Readiness__c == oldRec.Readiness__c)
                    localDataRec.addError('Please change Local Title Status to \'Pending\' to update Local Title Long Description.');
            }
        }
    }
    
    public void populateLocalTitleStatus(List<Local_Title__c> newLT){
        for(Local_Title__c localData: newLT){
            if(localData.Local_Title_Status__c != Null){
                localData.Readiness__c = localData.Local_Title_Status__c;
            }  
        }
    }
    
    public static boolean recursiveUpdate = false;
    //ER-002170 :  Variable added to avoid recursion to fix too many query rows.
    public static boolean recursiveUpdateLongLocalRating = false;
    public static set<Id> processedRecIds = new set<Id>();
}