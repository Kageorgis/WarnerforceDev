global class UpsertGap
{
     // Global list of titles after mapping of data
     global static List<Local_Title__c> listOfTitles = new List<Local_Title__c>();
     // Create Error Log and Transaction Log lists for auditing purposes and response object array
     global static List <Transaction_Log__c> listOfTransactions = new List<Transaction_Log__c>();
     global static List <Error_Log__c> listOfErrors = new List<Error_Log__c>();
     global static List <ResponseMessage> responses = new List<ResponseMessage>();
    // Class definition of the inbound title object for de-serialization
     global class LocalTitleDetails 
     {
        // String names match SFDC API Names for associated objects (Title__c or MPM__c)
        webService String IntegrationID;      
        webService String Local_Rating_Comment;
        webService String Video_Version;                // Maps to ECC:Video Version Number
        webService String Country;                      // Maps to ECC:Country
        webService String Language;                     // Maps to ECC:Language
        webService String Locale;                       // Maps to ECC:Locale
        webService String Local_Title_Name;             // Maps to MSB:Localized Title Name
        webService String Local_Rating_System;          // Maps to ECC:Local Rating System
        webService String Local_Rating;                 // Maps to ECC:Local Rating
        webService String Local_Synopsis;               // Maps to ECC:Local Synopsis
        webService String Local_DVD_Release_Date;       // Maps to ECC:DVD Release Date
        webService String Status;                       // Active or Inactive
        webService String Title_Name;
         //ER-547: Start
        webService String TV_Title;                     // Maps to MSB:episode_title_name
        webService String Local_TV_Air_Date;            // Maps to MSB:episode_broadcast_date
        webService String Local_Season;                 // Maps to MSB:season_number
        webService String Local_Episodes;               // Maps to MSB:episode_number
        //ER-547: End
     }
     
      // Class definition of the returned data struction
     global class ResponseMessage 
     {
        webService String IntegrationID;                  // IDOC that was processed
        webService Boolean Message_Result;              // True/False indicator of success
        webService String Error_Message;                // Detailed message of failure
        webService String Video_Version;                // Video Version that caused the failure
     }
     
    /**************************************************************************
     * Method Name:     createGap
     * Description:     Exposed as a web service to insert/update title data
     * Parameters:      Accepts a List of TitleInfo object for deserialization
     * Returns:         Error/success responses
     **************************************************************************/
     webservice static List<ResponseMessage> createGap (List<LocalTitleDetails> TitleInfo)
     {
        System.debug ('Entered createGap method');
        
        // Echo data received to debug logs
        System.debug ('Echo data stream received: ' + TitleInfo);
        //Get a list of Countries               
        List<Country__c> cl = [Select ID, Name, Country_Code2__c FROM Country__c];       
        Map<String, String> countryMap = new Map<String, String>();
        for (Country__c c:cl)
        {
            countryMap.put(c.Country_Code2__c, c.Id);       
        }
        //Get a list of Languages
        List<Language__c> ll = [Select Id, Name, Language_Code_2__c FROM Language__c];
        Map<String, String> languageMap = new Map<String, String>();    
        for (Language__c l:ll)
        {
            languageMap.put(l.Language_Code_2__c.toLowerCase(), l.Id);              
        } 
        
        //Get a list of GAP locales and parent locales
        List<GAP_Locale__c> gapl = [Select Id, Locale__c, Parent_Locale__c FROM GAP_Locale__c WHERE GAP_Locale__c = true];
        Map<String, String> gapMap = new Map<String, String>(); 
        for (GAP_Locale__c g:gapl)
        {
            gapMap.put(g.Locale__c, g.Parent_Locale__c);                
        }                   
        
        system.debug('cl===========> ' + cl);
        system.debug('ll===========> ' + ll);
        system.debug('gapl===========> ' + gapl);
        
        
        // Loop control variable to retrieve relevant data points
        Integer counter = 0;
        
        // Perform mapping of records
        mapDataValues(TitleInfo, countryMap, languageMap, gapMap);
        
        System.debug ('Echo size of listOfTitles if not null : size : ' + listOfTitles);
        // If global list of data is not empty, perform upsert
        if (listOfTitles != null && listOfTitles.size() > 0)
        {
            System.debug ('Echo size of listOfTitles if not null' + listOfTitles.size());
            //Mahesh : Remove duplicate records from a list
            listOfTitles = removeDuplicates(listOfTitles);
            
            system.debug('listOfTitles =====> ' + listOfTitles);
            
            
            // Perform list of title update using Database DML methods
            Database.upsertResult[] results = Database.upsert (listOfTitles, Local_Title__c.Key__c, false);
            
            // Loop through to check results
            for (Database.upsertResult sr : results)
            {
                // Create a generic response object with IDOC #
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = TitleInfo[counter].IntegrationID;
                aRespMsg.Video_Version = TitleInfo[counter].Video_Version;
                aRespMsg.Message_Result = sr.isSuccess();                
                
                // Log all records to transaction table
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (TitleInfo[counter].IntegrationID, sr.isSuccess(), 'createGap', TitleInfo[counter]);
                
                // Check if success and build error log if appropriate or success response
                if (!sr.isSuccess())
                {
                    // Failed upsert and need to update response with error message and log error message - could be multiple
                    for (Database.Error err : sr.getErrors())
                    {
                        // Update response
                        aRespMsg.Error_Message = err.getStatusCode() + ':' + err.getMessage();
                        
                        // Create Error Log Entry
                        Error_Log__c aErrLog = new Error_log__c();
                        aErrLog = createErrorLog (TitleInfo[counter].IntegrationID, 'createGap', aRespMsg.Error_Message, TitleInfo[counter]);
                
                        // Echo error message to the debug log
                        System.debug ('Unable to upsert record: ' + err.getStatusCode() + ':' + err.getMessage());
                        
                        // Add to Error Log list
                        listOfErrors.add(aErrLog);
                    }
                }
                // Add response message for return                
                
                responses.add(aRespMsg);
                
                // Add Transaction Log to array for insert
                listOfTransactions.add(aTLog);
                
                // Increment counter
                counter++;
            }
            
        }
       
        try
        {
            // Add the list of transactions
            if (listOfTransactions != null && listOfTransactions.size() > 0)
            {
                insert listOfTransactions;
            }
            
            if (listOfErrors != null && listOfErrors.size() > 0)
            {
                insert listOfErrors;
            }
        }
        catch (Exception ex)
        {
            // Failed attempting upsert
            System.debug ('Unable to insert records for transactions or errors with message: ' + ex.getMessage());
        }
        
        System.debug ('Finished processing');
        // Reply with success/error responses as required
        return responses;
    }
    
    /**************************************************************************
     * Method Name:     mapDataValues
     * Description:     Used to map received elements to necessary objects
     * Parameters:      List of Title Info to use in mapping
     * Return Values:   Updates the global list of items
     **************************************************************************/
    private static void mapDataValues (List<LocalTitleDetails> TitleInfo, Map<String, String> countryMap, Map<String, String> languageMap, Map<String, String> gapMap)
    {
        System.debug ('Entered mapDataValues method ' + TitleInfo.size());
        set<String> parentKeySet = new set<String>();
        map<String, Local_Title__c> parentLocalTitleMap = new map<String, Local_Title__c>();
        //video version
        Set<String> vvSet = new Set<String>();
        map<String,Title__c> titleVVMap = new map<String,Title__c>();
        
        //ER - 553 Start
        //List<Locale_Map__c> localeList = new List<Locale_Map__c>([SELECT Id,Name,Country_Code__c,Language_Code__c FROM Locale_Map__c]);
        List<Locale_Map__c> localeList = Locale_Map__c.getAll().values();
        Map<String,Locale_Map__c> localeMap = new Map<String,Locale_Map__c> ();
        String languageCode;
        String countryCode;
        for(Locale_Map__c locale : localeList){
                localeMap.put(locale.Name,locale);
        }
        //ER - 553 End
        
        // Create collection of keys
        for(LocalTitleDetails ltd : titleInfo)
        {
            if(ltd.Locale != Null && ltd.Locale != '' && ltd.Video_Version != Null && ltd.Video_Version != '')
            {
                //ER - 553 Start
                if(localeMap.containsKey(ltd.Locale)){
                    languageCode = localeMap.get(ltd.Locale).Language_Code__c;
                    countryCode = localeMap.get(ltd.Locale).Country_Code__c;
                }
                else{
                    languageCode = ltd.Locale.substringBefore('_').toLowerCase();
                    countryCode = ltd.Locale.substringAfter('_');   
                }
                /*
                else{
                    languageCode = ltd.Locale.substringBefore('_').toLowerCase();
                    countryCode = ltd.Locale.substringAfter('_');
                    //check to see if you need to change the language to those special cases, ie. Latam Spanish,
                    // or french canadian or brasilian portugese  -  these changes were made to the gap table already.
                    if (countryCode.equalsIgnoreCase('CA')&&languageCode.equalsIgnoreCase('fr')) 
                        languageCode='cf';
                    if (countryCode.equalsIgnoreCase('BR')&&languageCode.equalsIgnoreCase('pt')) 
                        languageCode='bp';
                    if (!countryCode.equalsIgnoreCase('ES')&&(languageCode.equalsIgnoreCase('es'))) 
                        languageCode='sp';
                }
                *///ER - 553 End
                
                //get parent locale
                String gapLocale = languageCode.toLowerCase() + '_' + countryCode.toUpperCase();
                System.debug ('DEBUG ALH++++++++++++++++++++++++ gapLocale='+gapLocale);            
                String pLocale = gapMap.get(gapLocale);
                //set new local title to parents info, all fields
                String vv=ltd.Video_Version;
                String key=vv+'_'+languageCode.toLowerCase()+'_'+countryCode.toUpperCase();         
                String pkey = vv+'_'+pLocale;
                parentKeySet.add(pKey);
            }
            else
            {
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = ltd.IntegrationID;
                aRespMsg.Video_Version = ltd.Video_Version;
                aRespMsg.Message_Result = false;
                aRespMsg.Error_Message = 'Video_Version or Locale is missing!';
                responses.add(aRespMsg);
                
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (ltd.IntegrationID, false, 'createGap.mapDataValues', ltd);
                listOfTransactions.add(aTLog);
                
                Error_Log__c aErrLog = new Error_log__c();
                aErrLog = createErrorLog (ltd.IntegrationID, 'createGap.mapDataValues', 'Video_Version or Locale is missing!', ltd);
                listOfErrors.add(aErrLog);
            }
            vvSet.add(ltd.Video_Version);
            
        }
        System.debug('DEBUG parentKeySet : ' + parentKeySet);
        System.debug('DEBUG vvList : ' + vvSet);
         
        //fetch list of titles based on recieved Video versions
        List<Title__c> titleLst = [select id,name,Video_Version__c from Title__c where  Video_Version__c =:vvSet];
        for(Title__c titleRec: titleLst){
            titleVVMap.put(titleRec.Video_Version__c,titleRec);
        }
        System.debug('List of title for video version is ----'+titleLst);
        // Get all local titles with parent key
        for(Local_Title__c parentLTD : [Select Id, Name, ALID__c, Caption_Exclusion_Reason__c, Caption_Included_picklist__c,Caption_Required__c,
                Category__c, CID__c, Country__c, Key__c, Language__c,
                Local_BD_Release_Date__c, Local_Box_Office__c, Local_DVD_Release_Date__c, Local_Episodes__c,
                Num_Local_Episodes__c, Local_Label__c, Local_Licensor__c, Local_Pay_TV_Start_Date__c, Local_Rating__c,
                Local_Rating_System__c, Rating_Reason__c, Local_Run_Time__c, Local_Season__c, Local_Synopsis__c, Local_Theatrical_Release_Date__c,
                Local_Title__c, Local_TV_Air_Date__c, Price_Code__c, Readiness__c, Status__c, Title__c,
                UV_Published_Date__c, /*Version_EIDR__c,*/ Title_VV_F__c, TV_Title__c
                FROM Local_Title__c WHERE Key__c in :parentKeySet])
        {
            parentLocalTitleMap.put(parentLTD.Key__c, parentLTD);
            system.debug('parentLocalTitleMap ====> ' + parentLocalTitleMap.size() + ' : ' + parentLocalTitleMap);
        } 
        
        system.debug('TitleInfo.size() ====> ' + TitleInfo.size());
        // Map the values received to create new object
        for (integer i=0; i<TitleInfo.size(); i++)
        {
            // Skip if VV or Locale is absent. Error has been logged in upper 'for' loop
            if(TitleInfo[i].Locale != Null && TitleInfo[i].Locale != '' && TitleInfo[i].Video_Version != Null && TitleInfo[i].Video_Version != '')
            {
                System.debug('Executing for loop...' + i);
                // Create variables to hold local values of records
                Local_Title__c aTitle = new Local_Title__c();       
                
                //ER - 553 Start
                //get country and language code from locale
                if(localeMap.containsKey(TitleInfo[i].Locale)){
                    languageCode = localeMap.get(TitleInfo[i].Locale).Language_Code__c;
                    countryCode = localeMap.get(TitleInfo[i].Locale).Country_Code__c;
                    
                }
                else{
                    languageCode = TitleInfo[i].Locale.substringBefore('_').toLowerCase();
                    countryCode = TitleInfo[i].Locale.substringAfter('_');
                    //check to see if you need to change the language to those special cases, ie. Latam Spanish,
                    // or french canadian or brasilian portugese  -  these changes were made to the gap table already.
                    /*
                    if (countryCode.equalsIgnoreCase('CA')&&languageCode.equalsIgnoreCase('fr')) 
                        languageCode='cf';
                    if (countryCode.equalsIgnoreCase('BR')&&languageCode.equalsIgnoreCase('pt')) 
                        languageCode='bp';
                    if (!countryCode.equalsIgnoreCase('ES')&&(languageCode.equalsIgnoreCase('es'))) 
                        languageCode='sp';
                    */
                }
                //ER - 553 End
                //get parent locale
                String gapLocale = languageCode.toLowerCase() + '_' + countryCode.toUpperCase();
                String pLocale = gapMap.get(gapLocale);
                //set new local title to parents info, all fields
                String vv=TitleInfo[i].Video_Version;
                String key=vv+'_'+languageCode.toLowerCase()+'_'+countryCode.toUpperCase();         
                String pkey = vv+'_'+pLocale;
                
                Local_Title__c pLD =  parentLocalTitleMap.get(pKey.toLowerCase());
                
                if(pLD != null )
                {
                    if (pLD.Status__c!=null) {
                        aTitle.Status__c = pLD.Status__c;
                    }
                    if (pLD.ALID__c!=null){
                        aTitle.ALID__c = pLD.ALID__c;
                    }
                    if (pLD.Caption_Exclusion_Reason__c!=null) {
                        aTitle.Caption_Exclusion_Reason__c = pLD.Caption_Exclusion_Reason__c;
                    }
                    if (pLD.Caption_Included_picklist__c!=null) {
                        aTitle.Caption_Included_picklist__c = pLD.Caption_Included_picklist__c;
                    }
                    
                    if (pLD.Caption_Required__c!=null){
                        aTitle.Caption_Required__c = pLD.Caption_Required__c;
                    }
                    
                    if (pLD.Category__c!=null) {
                        aTitle.Category__c = pLD.Category__c;
                    }
                    if (pLD.CID__c!=null) {
                        aTitle.CID__c = pLD.CID__c;
                    }
                  //if (pLD.Country_Code__c!=null) {
                  //    aTitle.Country_Code__c = pLD.Country_Code__c;
                  //}
                  //if (pLD.Language_Code__c!=null) {
                  //    aTitle.Language_Code__c = pLD.Language_Code__c;
                  //}
                    if (pLD.Local_BD_Release_Date__c!=null) {
                        aTitle.Local_BD_Release_Date__c = pLD.Local_BD_Release_Date__c;
                    }
                    if (pLD.Local_Box_Office__c!=null) {
                        aTitle.Local_Box_Office__c = pLD.Local_Box_Office__c;
                    }
                    if (pLD.Local_Episodes__c!=null) {
                        aTitle.Local_Episodes__c = pLD.Local_Episodes__c;
                    }
                    if (pLD.Num_Local_Episodes__c!=null) {
                        aTitle.Num_Local_Episodes__c = pLD.Num_Local_Episodes__c;
                    }
                    if (pLD.Local_Label__c!=null) {
                        aTitle.Local_Label__c = pLD.Local_Label__c;
                    }
                    if (pLD.Local_Licensor__c!=null) {
                        aTitle.Local_Licensor__c = pLD.Local_Licensor__c;
                    }
                    if (pLD.Local_Pay_TV_Start_Date__c!=null) {
                        aTitle.Local_Pay_TV_Start_Date__c = pLD.Local_Pay_TV_Start_Date__c;
                    }
                    if (pLD.Local_Run_Time__c!=null) {
                        aTitle.Local_Run_Time__c = pLD.Local_Run_Time__c;
                    }
                    if (pLD.Local_Season__c!=null) {
                        aTitle.Local_Season__c = pLD.Local_Season__c;
                    }
                    /*if (pLD.Local_Theatrical_Release_Date__c!=null) {
                        //aTitle.Local_Theatrical_Release_Date__c = pLD.Local_Theatrical_Release_Date__c;
                    }*/
                    /*-----Commenting For SINC0933686 : Start------
                    //ER-1001 start
                    if (pLD.Local_TV_Air_Date__c!=null && countryCode.equalsIgnoreCase('US')) {
                        aTitle.Local_TV_Air_Date__c = pLD.Local_TV_Air_Date__c;
                    }
                    //ER-1001 end
                    -------Commenting For SINC0933686 : End--------*/
                    /*if (pLD.Price_Code__c!=null) {
                        aTitle.Price_Code__c = pLD.Price_Code__c;
                    }*/
                    if (pLD.Readiness__c!=null) {
                        aTitle.Readiness__c = pLD.Readiness__c;
                    }
                    if (pLD.Status__c!=null) {
                        aTitle.Status__c = pLD.Status__c;
                    }
                    //if (pLD.Territory__c!=null) {
                    //aTitle.Territory__c = pLD.Territory__c;
                    //}
                    if (pLD.Title__c!=null) {
                        aTitle.Title__c = pLD.Title__c;
                    }
                    if (pLD.UV_Published_Date__c!=null) {
                        aTitle.UV_Published_Date__c = pLD.UV_Published_Date__c;
                    }
                    /* ER-1214 - turn off gap LD EIDR update by taking the parent LD EIDR
                    if (pLD.Version_EIDR__c!=null) {
                        aTitle.Version_EIDR__c = pLD.Version_EIDR__c;
                    }
                    */
                    //if (pLD.Video_Version__c!=null) {
                    //aTitle.Video_Version__c = pLD.Video_Version__c;
                    //}
                    if (pLD.Local_Title__c != null) {
                        
                        aTitle.Name = pLD.Local_Title__c.left(80);  //this changed .name is only 80 char 
                        aTitle.Local_Title__c = pLD.Local_Title__c; //full title name is stored here
                    }
                    //aTitle.Video_Version__c = pLD.Video_Version__c;
                    if (countryMap.get(countryCode)!=null) {
                        aTitle.Country__c = countryMap.get(countryCode); 
                    }    //lookup mapping to get the id of this country code
                    if (languageMap.get(languageCode)!=null) {
                        aTitle.Language__c = languageMap.get(languageCode);  //lookup mapping to get the id of this language code
                    }
                    if (pLD.Local_Rating_System__c!=null) {
                        aTitle.Local_Rating_System__c = pLD.Local_Rating_System__c;
                    }
                    //ER-000665 : Add Rating Reason to Local Data
                    if (pLD.Rating_Reason__c!=null) {
                        aTitle.Rating_Reason__c = pLD.Rating_Reason__c;
                    }
                    aTitle.Key__c = vv+'_'+gapLocale;
                    if (pLD.Local_Rating__c!=null) {
                        aTitle.Local_Rating__c = pLD.Local_Rating__c;
                    }
                    if (pLD.Local_Synopsis__c!=null) {
                        aTitle.Local_Synopsis__c = pLD.Local_Synopsis__c;
                    }
                    /*ER-272 -- MSB will no update this field... added by shalini
                    if (pLD.Local_DVD_Release_Date__c!=null) {
                        //aTitle.Local_DVD_Release_Date__c = pLD.Local_DVD_Release_Date__c;
                    }*/
                    /* ER - 293 added by shalini -- assign title and Local title Name and description same as Title by fetching video version*/
                    if(pLD.Title__c == null){
                        aTitle.Title__c = titleVVMap.get(vv).Id;
                    }
                    if(pLD.Local_Title__c == null){
                        aTitle.Name = titleVVMap.get(vv).Name.left(80);  //this changed .name is only 80 char 
                        aTitle.Local_Title__c = titleVVMap.get(vv).Name; //full title name is stored here
                    }
                    /* end of ER-293 enhancement*/
                    //ER-547: Start
                    if(pLD.TV_Title__c != null)
                    {
                        aTitle.TV_Title__c = pLD.TV_Title__c;
                    }
                    //ER-547: End
                }
                //overwrite fields that are not null from gap record
                    if (TitleInfo[i].Local_Title_Name != null  && TitleInfo[i].Local_Title_Name.length()>0) {
                        aTitle.Name = TitleInfo[i].Local_Title_Name.left(80);  //this changed .name is only 80 char 
                        aTitle.Local_Title__c = TitleInfo[i].Local_Title_Name; //full title name is stored here
                    }
                    /* ER - 293 added by shalini -- assign title and Local title Name and description same as Title by fetching video version*/
                    if (TitleInfo[i].Local_Title_Name == null || TitleInfo[i].Local_Title_Name.length() == 0) {
                        aTitle.Name = titleVVMap.get(vv).Name.left(80);  //this changed .name is only 80 char 
                        aTitle.Local_Title__c = titleVVMap.get(vv).Name; //full title name is stored here
                        System.debug('assigned Local title name and description is----'+aTitle.Local_Title__c);
                    }
                    /* end of ER-293 enhancement*/
                    if (TitleInfo[i].Local_Rating_System.length()>0) {
                        aTitle.Local_Rating_System__c = TitleInfo[i].Local_Rating_System;
                    }
                    //ER-000665 : Add Rating Reason to Local Data
                    if (TitleInfo[i].Local_Rating_Comment != null && TitleInfo[i].Local_Rating_Comment.length()>0) {
                        aTitle.Rating_Reason__c = TitleInfo[i].Local_Rating_Comment;
                    }
                    if (TitleInfo[i].Local_Rating.length()>0) {
                        aTitle.Local_Rating__c = TitleInfo[i].Local_Rating;
                    }
                    //added by shalini to link title with local title
                    if (TitleInfo[i].Title_Name != null && TitleInfo[i].Title_Name.length()>0) {
                        aTitle.Title__c = TitleInfo[i].Title_Name;
                    }
                    /* ER - 293 added by shalini -- assign title and Local title Name and description same as Title by fetching video version*/
                    if (TitleInfo[i].Title_Name == null || TitleInfo[i].Title_Name.length()== 0) {
                        aTitle.Title__c = titleVVMap.get(vv).Id;
                        System.debug('Title Name recieved from MAp is ----'+aTitle.Title__c); 
                    }
                    /* end of ER-293 enhancement*/
                    if (TitleInfo[i].Local_Synopsis.length()>0) {
                        aTitle.Local_Synopsis__c = TitleInfo[i].Local_Synopsis;
                    }
                    //if (vv!=null) {
                    //aTitle.Video_Version__c = vv;
                    //}
                    if (TitleInfo[i].Status!=null) {
                        aTitle.Status__c = TitleInfo[i].Status;
                    }
                    if (countryMap.get(countryCode)!=null) {
                        aTitle.Country__c = countryMap.get(countryCode);     //lookup mapping to get the id of this country code
                    }
                    if (languageMap.get(languageCode)!=null) {
                        aTitle.Language__c = languageMap.get(languageCode);  //lookup mapping to get the id of this language code
                    }
                    if (key!=null) {
                        aTitle.Key__c = key;
                    }
                    //ER-547: Start
                    if(TitleInfo[i].TV_Title != null && TitleInfo[i].TV_Title != '')
                    {
                        aTitle.TV_Title__c = TitleInfo[i].TV_Title;
                    }
                    /*-------Commenting For SINC0933686 : Start--------------
                    //ER-1001 Start
                    if(TitleInfo[i].Local_TV_Air_Date != null && TitleInfo[i].Local_TV_Air_Date != '' && countryCode.equalsIgnoreCase('US'))
                    {
                        aTitle.Local_TV_Air_Date__c = Date.valueOf(TitleInfo[i].Local_TV_Air_Date);
                    }
                    //ER-1001 End
                    
                    //ER-000734 start
                    else
                        aTitle.Local_TV_Air_Date__c= null;
                    //ER-000734 end    
                    ---------Commenting For SINC0933686 : End---------------*/
                    if(TitleInfo[i].Local_Season != null && TitleInfo[i].Local_Season != '')
                    {
                        if(TitleInfo[i].Local_Season == '0')
                            aTitle.Local_Season__c = null;
                        else
                            aTitle.Local_Season__c = TitleInfo[i].Local_Season;
                    }
                    if(TitleInfo[i].Local_Episodes != null && TitleInfo[i].Local_Episodes != '')
                    {
                        if(TitleInfo[i].Local_Episodes == '0')
                            aTitle.Local_Episodes__c = null;
                        else
                            aTitle.Local_Episodes__c = Integer.valueOf(TitleInfo[i].Local_Episodes);
                    }
                    //ER-547: End
                    
                    /*ER-272 MSB will not update this field -- added by shalini
                    if (TitleInfo[i].Local_DVD_Release_Date.length()>5) {
                        //if date is mm-dd-yyyy
                        
                        if (TitleInfo[i].Local_DVD_Release_Date.indexOf('/',0)==2) {
                            //aTitle.Local_DVD_Release_Date__c = date.parse(TitleInfo[i].Local_DVD_Release_Date);
                        }
                    else {    //if date is yyyy-mm-dd
                          
                        //aTitle.Local_DVD_Release_Date__c = date.valueOf(TitleInfo[i].Local_DVD_Release_Date);
                    }
                }*/
                // Add record just created as new record in application
                listOfTitles.add(aTitle);
            }
        }
        System.debug ('Finished processing data in mapDataValues');
    }
    
    
    /**************************************************************************
     * Method Name:     createTransactionLog
     * Description:     Create a log record as a copy of the transaction 
     *                  received for tracking and historical purposes - should 
     *                  be set up to archive eventually
     * Parameters:      IDOC, Success/Failure Values, Related Record if Error,
     *                  Method Invoked, Record being logged Title 
     * Return Values:   void
     **************************************************************************/
    private static Transaction_Log__c createTransactionLog (String idoc, Boolean isSuccess, String methodName, LocalTitleDetails TitleInfo)
    {
        // Create new Transaction Log record for insert / return
        Transaction_Log__c aLog = new Transaction_Log__c (IDOC__c = idoc, Invoked_Method__c = methodName);
        
        // Set status value
        if (isSuccess)
        {
            aLog.Status__c = 'Success';
        }
        else
        {
            aLog.Status__c = 'Failure';
        }
        // Set String value
        if (TitleInfo != null)
        {
            aLog.Input_Message__c = TitleInfo.toString();
        }

        // Return Transaction Log record created
        return aLog;
    }
    
    /**************************************************************************
     * Method Name:     createErrorLog
     * Description:     Create a log record as a copy of the transaction 
     *                  received for those records that failed - should 
     *                  be set up to archive eventually
     * Parameters:      IDOC, Method Invoked, Error Message, Record that failed
     *                  Title 
     * Return Values:   An Error Log record
     **************************************************************************/
    private static Error_Log__c createErrorLog (String idoc, String methodName, String errMessage, LocalTitleDetails TitleInfo)
    {
        // Create new Transaction Log record for insert / return
        Error_Log__c aLog = new Error_Log__c (IDOC__c = idoc, Invoked_Method__c = methodName, Error_Message__c = errMessage);
            
        // Set String value
        if (TitleInfo != null)
        {
            aLog.Input_Message__c = TitleInfo.toString(); //TitleInfo;
        }

        // Return Transaction Log record created
        return aLog;
    }
    /* Added by Mahesh to remove Duplicates : EL# on QA - EL-0001856*/
    private static List<Local_Title__c> removeDuplicates(List<Local_Title__c> pListOfTitles){
        map<String, Local_Title__c> localTitleMap = new map<String, Local_Title__c>();
        for(Local_Title__c localTitle : pListOfTitles){
            SYSTEM.DEBUG('MAP kEY ====> ' + localTitle.Key__c);
            localTitleMap.put(localTitle.Key__c, localTitle);
        }
        return localTitleMap.values();
    }
}