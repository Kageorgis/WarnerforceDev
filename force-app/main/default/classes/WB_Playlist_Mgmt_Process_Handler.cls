public class WB_Playlist_Mgmt_Process_Handler {
    
    set<String> setClientAvails = new set<String>();
    set<Id> TitleRecords =new set<Id>();
    set<Id> Country =new set<Id>();
    set<Id> Language =new set<Id>();
    set<Id> playlistIDs = new set<Id>();  
    List<Playlist_Content__c> RelatedTitleRecords = New list<Playlist_Content__c>();  
    Set<Local_Title__c> createLocalData = new Set<Local_Title__c>();
    set<Id> setRPIds =new set<Id>();
    Set<Id> setClientIds = new set<Id>();
    Map<String,Local_Title__c> mapExistingLocalDatas = new Map<String,Local_Title__c>();
    Map<Id,Decimal> mapEpisodeTitleSequenceNu = new Map<Id,Decimal>();
    
    public void CreateLocalData(List<Client_Avail__c> scope){
        
        for(Client_Avail__c s : scope){
            playlistIDs.add(s.Playlist__c);
            Country.add(s.Commercial_Avail__r.Country_Lookup__c);
            Language.add(s.Commercial_Avail__r.Languages__c);
            setClientIds.add(s.Client__c);
            setRPIds.add(s.Commercial_Avail__c);
        }
        RelatedTitleRecords = [SELECT ID, Content_Title__c, Playlist__c, Title_Name__c,Content_Title__r.MPM_Long_Desc__c,Content_Title__r.Synopsis__c FROM Playlist_Content__c WHERE Playlist__c IN: playlistIDs];
        for(Playlist_Content__c PCRecords : RelatedTitleRecords){
          TitleRecords.add(PCRecords.Content_Title__c);    
        }
    
        set<String> LocalData = New set<String>();
        for(Local_Title__c localTitleRecords : [SELECT id, Country__c, Language__c, Title__c,Parent_Local_Data__c FROM Local_Title__c WHERE Title__c IN :TitleRecords AND Country__c IN :Country AND Language__c IN :Language AND External_Company__c = Null]){
           LocalData.add((localTitleRecords.Title__c+'#!#'+localTitleRecords.Country__c +'#!#'+localTitleRecords.Language__c).trim()); 
           mapExistingLocalDatas.put((localTitleRecords.Title__c+'#!#'+localTitleRecords.Country__c +'#!#'+localTitleRecords.Language__c).trim(),localTitleRecords);
        }
        
        for(Client_Avail__c CARecord : scope){
            for(Playlist_Content__c PCRecords : RelatedTitleRecords){
                TitleRecords.add(PCRecords.Content_Title__c);    
                if(PCRecords.Playlist__c == CARecord.Playlist__c){
                    //String keyString = CARecord.ID +'#!#'+ PCRecords.Content_Title__c +'#!#'+ CARecord.Commercial_Avail__r.Country_Lookup__c +'#!#'+ CARecord.Commercial_Avail__r.Languages__c;
                    String keyString = PCRecords.Content_Title__c +'#!#'+ CARecord.Commercial_Avail__r.Country_Lookup__c +'#!#'+ CARecord.Commercial_Avail__r.Languages__c;
                    if(!LocalData.contains(keyString.trim())){
                        Local_Title__c LT = New Local_Title__c();
                        LT.Name = ((PCRecords.Title_Name__c.length() > 80) ? PCRecords.Title_Name__c.substring(0,80) : PCRecords.Title_Name__c);     //SINC0916173
                        LT.Title__c =  keyString.split('#!#')[0];
                        LT.Country__c =  keyString.split('#!#')[1];
                        LT.Language__c =  keyString.split('#!#')[2];
                        //LT.Readiness__c = 'Requires Review';
                        LT.Parent_Local_Data__c = CARecord.Local_Title__c;
                        LT.Local_Edit_Required__c = 'No';
                        //LT.Category__c ='';
                        LT.Category__c = CARecord.Local_Title__r.Local_Category__c;
                        //LT.Rights_Group__c = 'Country Rights Group';
                        LT.ADS__c = 'No';
                        if(CARecord.Release_Plan_Country__c == Label.WB_USA_Label)
                            LT.Caption_Required__c = 'Yes';
                        else
                            LT.Caption_Required__c = 'No';
                        LT.Local_Rating__c = CARecord.Local_Title__r.Local_Rating__c;
                        LT.Local_Rating_System__c = CARecord.Local_Title__r.Local_Rating_System__c;
                        LT.Local_Title__c = PCRecords.Content_Title__r.MPM_Long_Desc__c;
                        LT.Local_Synopsis__c = PCRecords.Content_Title__r.Synopsis__c;
                       createLocalData.add(LT);
                    }
                    else
                    {
                        Local_Title__c LT = mapExistingLocalDatas.get(keyString.trim());
                        if(LT.Parent_Local_Data__c == null)
                            LT.Parent_Local_Data__c = '';
                        if(LT.Parent_Local_Data__c != '' && LT.Parent_Local_Data__c != null)
                        {
                            LT.Parent_Local_Data__c = LT.Parent_Local_Data__c.trim();
                            if(!LT.Parent_Local_Data__c.contains(CARecord.Local_Title__c))
                                LT.Parent_Local_Data__c += ',';
                        }
                        if(!LT.Parent_Local_Data__c.contains(CARecord.Local_Title__c))
                            LT.Parent_Local_Data__c  += CARecord.Local_Title__c;
                        LT.Category__c = CARecord.Local_Title__r.Local_Category__c;
                        createLocalData.add(LT);
                    }
                }
            }
        }
        list<Local_Title__c> DML_NewLocalData = New list<Local_Title__c>();
        DML_NewLocalData.addAll(createLocalData);
        upsert DML_NewLocalData;
    }
    
    /* Method used to create or link client avail for Episode title if
        1. Season Client Avail created
        2. Playlist for Season client avail changed
        3. Content for Playlist changed
        
        Note : This method will accept list of client avail but will process only first client avail record in list.
    */
    public void CreateClientAvails(List<Client_Avail__c> listSeasonClientAvails){
        Map<Id,Set<Id>> mapPlaylistTitleIds = new Map<Id,Set<Id>>(); // Store Playlist and related content title in map.
        set<id> contentTitleIds = new set<id>(); // Store all title ids comes from Playlist content title.
        List<Client_Avail__c> toUpsertEpisodeCARecords = new List<Client_Avail__c>(); // List used to store and insert client avail records.
        //List<Client_Avail__c> toUpdateEpisodeCARecords = new List<Client_Avail__c>(); // List used to store and update the Client avail records
        Map<String,Local_Title__c> mapLocalTitles = new Map<String,Local_Title__c>(); // Store title id and related local data(for same Country and Language of Season Client Avail)
        Boolean categoryValidation=false;
        Boolean errorlogged = false;
        Map<String,Integer> episodeCACountMap = new Map<String,Integer>();
        List<Playlist_Content__c> playlistContentList = new List<Playlist_Content__c>();
        Integer playListContentCount;
        set<Id> titleIds = new set<Id>();
        // Get first record of Client avail from list.
        Client_Avail__c ca = listSeasonClientAvails[0];
        try{
        
        if(ca.Playlist__c != null)
        {
            playlistContentList = [SELECT id,Content_Title__c,Content_Sequence__c,Playlist__c from Playlist_Content__c where Playlist__c =: ca.Playlist__c];
            playListContentCount = playlistContentList.size();
            for(Playlist_Content__c pc : playlistContentList)
            {   
                if(!mapPlaylistTitleIds.containskey(pc.Playlist__c))
                    mapPlaylistTitleIds.put(pc.Playlist__c,new set<Id>());
                mapPlaylistTitleIds.get(pc.Playlist__c).add(pc.Content_Title__c);
                contentTitleIds.add(pc.Content_Title__c);
                mapEpisodeTitleSequenceNu.put(pc.Content_Title__c,pc.Content_Sequence__c);
            }    
        }
        Map<Id,Title__c> mapContentTitles = new Map<Id,Title__c>([SELECT id,Global_Category__c,US_TV_Air_Date__c from Title__c where id in: contentTitleIds]);
        
         
        // Fetch all matching child client avail records and store them in map with title id as key
        Map<Id,Client_Avail__c> mapTitleIDChildCA = new Map<Id,Client_Avail__c>();
        for(Client_Avail__c childCA : [SELECT id,Client__c,Title__c,Status__c,Local_Title__r.Local_BD_Release_Date__c,End_Date__c,Local_Data_Category_Picklist__c,Title__r.US_TV_Air_Date__c,Count_Announcement_Record__c
                  FROM Client_Avail__c 
                  WHERE Commercial_Avail__c =: ca.Commercial_Avail__c
                  AND Client__c =: ca.Client__c 
                  AND Avail_Type__c = 'Automated'])
        {
            if(childCA.End_Date__c == ca.End_Date__c){
                mapTitleIDChildCA.put(childCA.Title__c,childCA);
            }else if(ca.Playlist__r.Episode_End_Date_Calc__c != Null){
                mapTitleIDChildCA.put(childCA.Title__c,childCA);
            }
            system.debug(LoggingLevel.INFO,'mapTitleIDChildCA:'+mapTitleIDChildCA);
        }
        
            
        // Get matching Local Data for content titles.
        for(Local_Title__c lt : [Select id,Title__c,Name,Language__c,Country__c,Local_BD_Release_Date__c,Local_TV_Air_Date__c,  //Local_TV_Air_Date_Audio__c,Local_TV_Air_Date_Sub__c,
                            Local_Category__c,Country__r.TV_Day_After_US_Offset__c,Country__r.TV_Day_After_Local_Offset__c 
            FROM Local_Title__c WHERE Title__c in: contentTitleIds
            AND Language__c =: ca.Commercial_Avail__r.Languages__c AND Country__c =: ca.Commercial_Avail__r.Country_Lookup__c AND External_Company__c = Null])
        {
            mapLocalTitles.put(''+lt.Title__c+lt.Language__c+lt.Country__c,lt);
        }
        // Check category for season client avail.
        if(ca.Local_Data_Category_Picklist__c == 'TV Day After US' || ca.Local_Data_Category_Picklist__c == 'TV Day After Local')
            categoryValidation=true;

        // Create Episode client avails if Season Client avail inserted.
        if(ca.Recalculate_Playlist_Avails__c == 'Insert'){
            if(ca.Playlist__c != null && mapPlaylistTitleIds.containsKey(ca.Playlist__c))
            {
                for(Id titleId : mapPlaylistTitleIds.get(ca.Playlist__c))
                {
                    Local_Title__c localData = mapLocalTitles.get(''+titleId+ca.Commercial_Avail__r.Languages__c+ca.Commercial_Avail__r.Country_Lookup__c);
                   
                    if(localData.Local_Category__c != null && localData.Local_Category__c.contains('TV'))
                    {
                        Boolean bdDateAvailable=false;
                        Boolean byPassCalc = false;
                        Client_Avail__c childCA;
                        //Date respectiveAirDate = calculateStartDate(localData,ca.RP_Language_Type__c);
                       
                        // check if record is already exist for Content title and update the values.
                        if(mapTitleIDChildCA.containsKey(titleId)){
                            childCA = mapTitleIDChildCA.get(titleId);
                            childCA.Status__c = ca.Status__c;
                            childCA.Parent_Client_Avail__c = ca.id;
                            
                            byPassCalc = bypassEpisodeAvail(childCA);
                        }
                        
                        // Else create new client avail record for content title.
                        else{
                            
                            childCA = cloneClientAvail(ca,titleId);
                            childCA.Local_Title__c = localData.id;
                            childCA.Local_Data_Category_Picklist__c = localData.Local_Category__c;
                        }
                        
                        if(ca.Playlist__r.Recalculate_Sequence__c == True){
                         childCA.Episode_Number_Override__c = mapEpisodeTitleSequenceNu.get(localData.Title__c);
                        } else{
                          childCA.Episode_Number_Override__c = Null;   
                        }
                       
                        //ER-004158 - Add field "Episode End Date Calc" to Playlist - changes - calculateStartDateANDStatus added within if condition to skip if Episode CA End Date is expired
                        if(!byPassCalc){
                            childCA = calculateStartDateANDStatus(localData,ca,mapContentTitles.get(titleId),childCA,true);
                        }
                        toUpsertEpisodeCARecords.add(childCA);
                    }
                }
            }
        }
        
        Map<Id,Client_Avail__c> mapChildClientAvails = new Map<Id,Client_Avail__c>();
        Set<Id> playlistContentRemovedSet = new Set<Id>();
        //Map<Id,Client_Avail__c> mapPlaylistContentRemoved = new  Map<Id,Client_Avail__c>();
        List<Client_Avail__c> allChildCA = [SELECT id,Status__C,Local_Title__r.Title__c,Title__c from Client_Avail__c where Parent_Client_Avail__c =: ca.id];

        for(Client_Avail__c childCA : [SELECT id,Status__C,Title__c from Client_Avail__c where Parent_Client_Avail__c =: ca.id])
                mapChildClientAvails.put(childCA.Title__c,childCA);
                
        /* Create or update episode client avail if Playlist field changed for Season Client Avail record.*/
        // Add or remove Client avail for newly added or removed from Playlist content.
        if(ca.Recalculate_Playlist_Avails__c == 'Update Playlist' || ca.Recalculate_Playlist_Avails__c == 'Update Playlist Content')
        {   
            
            
            for(Playlist_Content__c pc : [SELECT id,Content_Sequence__c,Content_Title__c FROM Playlist_Content__c WHERE Playlist__c =: ca.Playlist__c])
                titleIds.add(pc.Content_Title__c);
            
            
            // Compare playlist content for new and old playllist of Client avail. If content is not available in new playlist then update it's status.
            for(Id titleId : returnDifferentId(mapChildClientAvails.keyset(),titleIds)){
                toUpsertEpisodeCARecords.add(new Client_Avail__c(id=mapChildClientAvails.get(titleId).id,Status__C = 'Cancelled',Episode_Number_Override__c = Null,Parent_Client_Avail__c=null));
                playlistContentRemovedSet.add(mapChildClientAvails.get(titleId).id);
            }
                
            
            for(Client_Avail__c ChildCARecord:allChildCA)
             {
                 if(!playlistContentRemovedSet.contains(ChildCARecord.Id)){
                    if(ca.Playlist__r.Recalculate_Sequence__c == True){
                     ChildCARecord.Episode_Number_Override__c = mapEpisodeTitleSequenceNu.get(ChildCARecord.Local_Title__r.Title__c);
                    } else{
                      ChildCARecord.Episode_Number_Override__c = Null;   
                     } 
                     toUpsertEpisodeCARecords.add(ChildCARecord);
                 }
                 
                 //
             }
            
            // Compare playlist content for new and old playllist of Client avail, And create new client avails if found new content.
            for(Id titleId : returnDifferentId(titleIds,mapChildClientAvails.keyset()))
            {
                Local_Title__c localData = mapLocalTitles.get(''+titleId+ca.Commercial_Avail__r.Languages__c+ca.Commercial_Avail__r.Country_Lookup__c);
               
                if(localData.Local_Category__c != null && localData.Local_Category__c.contains('TV'))
                {
                    Boolean bdDateAvailable=false;
                    Boolean byPassCalc = false;
                    Client_Avail__c childCA;
                    //Date respectiveAirDate = calculateStartDate(localData,ca.RP_Language_Type__c);
                    if(mapTitleIDChildCA.containsKey(titleId)){
                        childCA = mapTitleIDChildCA.get(titleId);
                        childCA.Status__c = ca.Status__c;
                        childCA.Parent_Client_Avail__c = ca.id;
                        byPassCalc = bypassEpisodeAvail(childCA);
                            
                    }
                    else{
                        
                        childCA = cloneClientAvail(ca,titleId);
                        childCA.Local_Title__c = localData.id;
                        childCA.Local_Data_Category_Picklist__c = localData.Local_Category__c;
                    }
                    
                    if(ca.Playlist__r.Recalculate_Sequence__c == True){
                        childCA.Episode_Number_Override__c = mapEpisodeTitleSequenceNu.get(localData.Title__c);
                    } else{
                          childCA.Episode_Number_Override__c = Null;   
                    }
                   //ER-004158 - Add field "Episode End Date Calc" to Playlist - changes - calculateStartDateANDStatus added within if condition to skip if Episode CA End Date is expired
                    if(!byPassCalc){
                        childCA = calculateStartDateANDStatus(localData,ca,mapContentTitles.get(titleId),childCA,true);
                    }
                    
                    //if(!categoryValidation || (categoryValidation && bdDateAvailable))
                    toUpsertEpisodeCARecords.add(childCA);
                }
            }
            
        }
        
        if(ca.Recalculate_Playlist_Avails__c == 'Update Local Data'){

            if(mapPlaylistTitleIds != null && ca.Playlist__c != null && mapPlaylistTitleIds.containsKey(ca.Playlist__c))
            {
                for(Id titleId : mapPlaylistTitleIds.get(ca.Playlist__c))
                {
                    Local_Title__c localData = mapLocalTitles.get(''+titleId+ca.Commercial_Avail__r.Languages__c+ca.Commercial_Avail__r.Country_Lookup__c);
                    /*if(localData.Local_Category__c != null && localData.Local_Category__c.contains('TV'))
                    {*/
                    Boolean bdDateAvailable=false;
                    Boolean byPassCalc = false;
                    // Check if is there existing client avail available for matching Release plan and client value. If yes then update
                    // the start date of existing avail.
                    Client_Avail__c childCA;
                    //Date respectiveAirDate = calculateStartDate(localData,ca.RP_Language_Type__c);
                    if(mapTitleIDChildCA.containsKey(titleId)){
                        childCA = mapTitleIDChildCA.get(titleId);
                        childCA.Status__c = ca.Status__c;
                        childCA.Parent_Client_Avail__c = ca.id;
                        byPassCalc = bypassEpisodeAvail(childCA);
                    }
                    else{
                        
                        childCA = cloneClientAvail(ca,titleId);
                        childCA.Local_Title__c = localData.id;
                        childCA.Local_Data_Category_Picklist__c = localData.Local_Category__c;
                    }
                   
                    //ER-004158 - Add field "Episode End Date Calc" to Playlist - changes - calculateStartDateANDStatus added within if condition to skip if Episode CA End Date is expired
                    if(!byPassCalc){
                        childCA = calculateStartDateANDStatus(localData,ca,mapContentTitles.get(titleId),childCA,true);
                    }
                    
                    toUpsertEpisodeCARecords.add(childCA);
                    //}
                }
            }
            
            
        }
        // Insert/update list of newly created/updated client avails for Episode Titles
        
        if(toUpsertEpisodeCARecords != null && toUpsertEpisodeCARecords.size() > 0){
            List<String> errorMessages = new List<String>();
            String errorMessageValue = '';
            Database.UpsertResult[] upsertResultList = Database.upsert(toUpsertEpisodeCARecords,false);
            if(upsertResultList.size()>0){
                for(Database.UpsertResult sr : upsertResultList) {
                    String errorMessage = '';
                    if(!sr.isSuccess()){
                       List<Database.Error> errors = sr.getErrors();
                       for(Database.Error err : errors){
                           errorMessage += err.getMessage();
                          }
                          errorMessages.add(errorMessage);
                           
                    }
                } 
                    
            }
            
            if(errorMessages.size() > 0){
                for(String errorValue : errorMessages){
                    if(errorMessageValue == ''){
                        errorMessageValue += errorValue;
                   }else if(!errorMessageValue.equals(errorMessageValue)){
                        errorMessageValue += ''+errorValue;
                   }
                        
                }
                errorlogged = true;
                createErrorLog(ca,errorMessageValue,errorMessageValue);
            } 
        }
        UpdateEpisodeAvails(ca);        //ER-820: Method Invocation
        // Change Recalculate Playlist Avails status to null.
        ca.Recalculate_Playlist_Avails__c = '';
        ca.Recalculation_Status__c=false;
        update ca;
         
    }catch(Exception error){
        system.debug('Exception e:'+error);
        createErrorLog(ca,error.getMessage(),error.getStackTraceString()); 
    }
        
        
        
     try{   
        Client_Avail__c caEpisodeCount = [Select (Select Id from Child_Client_Avails__r) from Client_Avail__c where Id =: ca.Id];
        Integer episodeCACount = caEpisodeCount.Child_Client_Avails__r.size();  
        
        String errorMessage = '';
        Boolean isErrorLocalCategory = false;
        if(episodeCACount!=null && playListContentCount!=null && !errorlogged){
            if(playListContentCount!= episodeCACount ){
                
                errorMessage = 'Episodes are not generated successfully. Please recalculate.';
                
                if(ca.Local_Title__r.Local_Category__c!=null && !ca.Local_Title__r.Local_Category__c.contains('TV')){
                    errorMessage = 'Invalid category : '+ca.Local_Title__r.Local_Category__c;
                    //isErrorLocalCategory = true;
                }
                if(ca.Status__c == 'Confirmed' && ca.Episode_Price_Tier__c == 'TBD' ){
                   
                    if(errorMessage != ''){
                        errorMessage = errorMessage +' and Episode Price Tier is TBD on Season Avail';
                    }else
                       errorMessage = 'Episode Price Tier is TBD on Season Avail'; 
                }
                
                createErrorLog(ca,errorMessage,errorMessage);
            }
        }
     }catch(Exception ex){
        system.debug('Exception e:'+ex);
        createErrorLog(ca,ex.getMessage(),ex.getStackTraceString());
     }
        
        
}
    public static void createErrorLog(Client_Avail__c ca,String errorMessage,String errorMessageLongValue){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
         errorLogInstance.recordId = ca.Id;
         errorLogInstance.errorCategory = 'Episode Calculation';
         errorLogInstance.errorDescription = errorMessage.left(252);
         errorLogInstance.errorDescriptionLong = errorMessageLongValue.left(32000); 
         errorLogInstance.objectName = ca.Id.getSObjectType().getDescribe().getName();
         errorLogInstance.account = ca.Client__c;
         errorLogs.add(errorLogInstance);
         WB_CAS_ErrorLogger.logError(errorLogs);
         
    }
 
    
    /*-----------------ER-820: Start------------------------------------------*/
    public void UpdateEpisodeAvails(Client_Avail__c seasonAvail)
    {
        Set<Client_Avail__c> uniqueAvailSet = new Set<Client_Avail__c>();
        List<Client_Avail__c> episodeAvailsToUpdate = new List<Client_Avail__c>();
        
        //Get Season Avail From The List
        if(seasonAvail.Recalculate_Playlist_Avails__c == 'Update Episode Avails')
        {
            List<Client_Avail__c> childEpisodeClientAvails = [Select id, status__c,Local_Data_Category_Picklist__c,Current_Title_Category__c,Name,Title_Content_Type__c,Start_Date__c,End_Date__C,Parent_Client_Avail__c,Local_Title__r.Local_Category__c,Lock_Pricing_Update__c,Price_Tier_Text__c,Local_Title__r.Local_TV_Air_Date__c
                                                              FROM Client_Avail__c 
                                                              where Parent_Client_Avail__c =: seasonAvail.id];
            if(childEpisodeClientAvails != null && childEpisodeClientAvails.size() > 0)
                for(Client_Avail__c clientAvail : childEpisodeClientAvails)
                {
                    //Update Status
                    if(seasonAvail.Status__c == 'Confirmed' || seasonAvail.Status__c == 'Tentative')
                    {
                        if(clientAvail.Start_Date__c != clientAvail.End_Date__c)// && clientAvail.Price_Tier_Text__c != 'TBD')    
                            clientAvail.Status__c = seasonAvail.Status__C;
                    }
                    else
                        clientAvail.Status__c = seasonAvail.Status__C;
                    
                    //Update Start Date   
                    if(seasonAvail.Start_Date__c >= clientAvail.Start_Date__c) //&& !Label.WB_TV_Episode_Categories.contains(clientAvail.Local_Title__r.Local_Category__c)) 
                        clientAvail.Start_Date__c = seasonAvail.Start_Date__c ;
                   
                    //ER-004158 - Add field "Episode End Date Calc" to Playlist - changes - End Date assignment added in if statement
                    //if(!(seasonAvail.Playlist__r.Episode_End_Date_Calc__c != Null && Label.WB_TV_Episode_Categories.contains(clientAvail.Local_Data_Category_Picklist__c))){
                    if((clientAvail.End_Date__c > seasonAvail.End_Date__c) ||(!(seasonAvail.Playlist__r.Episode_End_Date_Calc__c != Null && Label.WB_TV_Episode_Categories.contains(clientAvail.Local_Data_Category_Picklist__c)))){
                        clientAvail.End_Date__C = seasonAvail.End_Date__c;
                    }
                    
                    
                    //ER-001037  
                    if(seasonAvail.Start_Date__c != NULL && clientAvail.Start_Date__c != NULL) {
                        if( seasonAvail.Start_Date__c <= clientAvail.Start_Date__c ) {
                            if(clientAvail.Local_Data_Category_Picklist__c != NULL){
                                if(clientAvail.Local_Data_Category_Picklist__c.equalsIgnoreCase('TV Catalog') ||
                                     clientAvail.Local_Data_Category_Picklist__c.equalsIgnoreCase('TV New Release')){
                                    clientAvail.Start_Date__c = seasonAvail.Start_Date__c;
                                }
                            }
                        }
                    }
                    if(clientAvail.Start_Date__C > seasonAvail.End_Date__C)
                    {
                        clientAvail.Start_Date__C = seasonAvail.End_Date__C;
                        if(clientAvail.Status__c != 'Draft') // Do not update the status to cancelled if the previous status was in Draft.
                            clientAvail.Status__c = 'Cancelled';
                    }
                   
                    uniqueAvailSet.add(clientAvail);
                        
                }
            if(uniqueAvailSet != NULL && uniqueAvailSet.size() > 0)
                episodeAvailsToUpdate.addAll(uniqueAvailSet);
            Database.update(episodeAvailsToUpdate, false);
            
        }
        
    }
    /*----------------ER-820: End---------------------------------------------*/
    
    // Method return set of ids which are not available in second set
    public Set<Id> returnDifferentId(Set<Id> firstSet, Set<Id> secondSet)
    {
        Set<Id> uniqueIdSet = new Set<Id>();
        for(Id element : firstSet)
        {
            if(!secondSet.contains(element))
                uniqueIdSet.add(element);
        }
        return uniqueIdSet;
    }
    
    public Client_Avail__c cloneClientAvail(Client_Avail__c oldClientAvail,Id titleId)
    {
        Client_Avail__c newClientAvail = oldClientAvail.clone(false,false,false,false);
        newClientAvail.Parent_Client_Avail__c = oldClientAvail.id;
        newClientAvail.Title__c = titleId;
        newClientAvail.Recalculate_Playlist_Avails__c='';
        newClientAvail.Recalculation_Status__c=false;
        newClientAvail.Avail_Type__c='Automated';
        newClientAvail.Playlist__c=null;
        newClientAvail.Announce_Date__c=null;
        newClientAvail.RP_Synch__c=false;
        newClientAvail.Price_Tier_Text__c=oldClientAvail.Episode_Price_Tier__c;
        newClientAvail.Price__c=oldClientAvail.Episode_Price__c;
        newClientAvail.Episode_Price_Tier__c='';
        newClientAvail.Episode_Price__c=null;
        newClientAvail.EC_Available__c = null;
        if(oldClientAvail.CA_CRM_Country__c){
            newClientAvail.CA_Rate_Card__c = oldClientAvail.Episode_Rate_Card__c;
            newClientAvail.Pricing__c = Null;
            newClientAvail.Episode_Rate_Card__c = Null;
            newClientAvail.Episode_Pricing__c = Null;
        }else{
            newClientAvail.Pricing__c = oldClientAvail.Episode_Pricing__c;
            newClientAvail.Episode_Pricing__c = Null;
        }
        
        
        return newClientAvail;
        
    }
    
    /*public Date calculateStartDate(Local_Title__c localTitle,String langType)
    {
        if(langType == 'Sub')
            return localTitle.Local_TV_Air_Date_Sub__c;
        else if(langType == 'Audio')
            return localTitle.Local_TV_Air_Date_Audio__c;
        else if(langType == 'Sub & Audio')
            return localTitle.Local_TV_Air_Date__c;
        return null;
    }*/
    
    public Client_Avail__c calculateStartDateANDStatus(Local_Title__c localTitle,Client_Avail__c parentca,Title__c title,Client_Avail__c childCA,Boolean localDataUpdateFlag){
        
        //ER-006440 - Exclude non DAUS/DAL episode avails in start date recalcualtion process
        if(Label.WB_TV_Episode_Categories.contains(localTitle.Local_Category__c) && Label.WB_TV_Episode_Categories.contains(childCA.Local_Data_Category_Picklist__c)){
            
            Date airDate;
            Date compareDate = Date.newInstance(2049, 12, 31);
            String category='';
            
            if(localDataUpdateFlag)
                category = childCA.Local_Data_Category_Picklist__c;
            else
                category = localTitle.Local_Category__c;
            
            //if(category == 'TV Day After US' && childCA.Title__r.US_TV_Air_Date__c != null ) //&& localTitle.Country__r.TV_Day_After_US_Offset__c != null 
            if(category == 'TV Day After US' && title.US_TV_Air_Date__c != null ) //&& localTitle.Country__r.TV_Day_After_US_Offset__c != null 
                airDate = title.US_TV_Air_Date__c + ((localTitle.Country__r.TV_Day_After_US_Offset__c != null) ? Integer.valueof(localTitle.Country__r.TV_Day_After_US_Offset__c) : 0);
            else if(category == 'TV Day After Local' && localTitle.Local_TV_Air_Date__c != null ) //&& localTitle.Country__r.TV_Day_After_Local_Offset__c != null 
                airDate = localTitle.Local_TV_Air_Date__c + ((localTitle.Country__r.TV_Day_After_Local_Offset__c != null) ? Integer.valueof(localTitle.Country__r.TV_Day_After_Local_Offset__c) : 0);
            
            if(airDate != null && airDate != compareDate && airdate <= parentca.End_Date__c){
                if(airdate >= parentca.Start_Date__c)
                    childCA.Start_Date__c = airDate;
                else
                    childCA.Start_Date__c = parentca.Start_Date__c;
            }
            else{
                childCA.Start_Date__c = parentca.End_Date__c;
            }

            //if(parentca.Status__c != 'Draft' && parentca.Status__c != 'Cancelled' && parentca.Status__c != 'Not Releasing'){
            if(airDate == null || airDate == compareDate){
               
               childCA.Status__c = 'Draft';
                //ER-002723  - Move Episode Avail Status to Tentative when Broadcast date is deleted change
                if(airDate == Null && childCA.Count_Announcement_Record__c > 0){
                    if(parentca.Status__c == 'Confirmed')
                        childCA.Status__c = 'Tentative';  
                    else 
                        childCA.Status__c = parentca.Status__c;
                }
                        
            }
            else
                childCA.Status__c = parentca.Status__c;
            
             //ER-004158 - Add field "Episode End Date Calc" to Playlist - changes - End Date Calculation 
            if(parentca.Playlist__r.Episode_End_Date_Calc__c != Null && airDate != Null ){
                childCA.End_Date__c = childCA.Start_Date__c.addDays(Integer.valueOf(parentca.Playlist__r.Episode_End_Date_Calc__c));
            }else{
                childCA.End_Date__c = parentca.End_Date__c;
            }
            
        }
        
        return childCA;
    }
    
    public Boolean bypassEpisodeAvail(Client_Avail__c ca){
        
        Boolean bypass = false;
        if(ca.End_Date__c < Date.Today()){
            bypass = true;
        }
        
        return bypass;
        
    }
        /* Method to support multiple Client avail records
    public void createClientAvailsForMultipleSeasonCA(List<Client_Avail__c> listClientAvails)
    {
        
    }*/
}