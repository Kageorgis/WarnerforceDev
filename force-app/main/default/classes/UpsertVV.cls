/*****************************************************************************
 * Class Name:      UpsertVV
 * Description:     Inbound Apex Web Services to update WB Local Data object and 
 *                  related objects received from WB legacy systems 
 *
 * Author:          Date:           Description
 * Andrew Hilsher   11/17/2014      First Draft
 * CTS              8/5/2016        ER-000665: Add Rating Reason to Local Data
 *****************************************************************************/
 
global class UpsertVV
{
     // Global list of titles after mapping of data
     global static List<Local_Title__c> listOfTitles = new List<Local_Title__c>();
     // Create Error Log and Transaction Log lists for auditing purposes and response object array
     static List <Transaction_Log__c> listOfTransactions = new List<Transaction_Log__c>();
     static List <Error_Log__c> listOfErrors = new List<Error_Log__c>();
     static List <ResponseMessage> responses = new List<ResponseMessage>();
    // Class definition of the inbound title object for de-serialization
     global class LocalTitleDetails 
     {
        // String names match SFDC API Names for associated objects (Title__c or MPM__c)
        //webService String IDOC_Number;                  // Captures/store IDOC #  
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
     * Method Name:     createVV
     * Description:     Exposed as a web service to insert/update title data
     * Parameters:      Accepts a List of TitleInfo object for deserialization
     * Returns:         Error/success responses
     **************************************************************************/
     webservice static List<ResponseMessage> createVV (List<LocalTitleDetails> TitleInfo)
     {
        System.debug ('Entered createVV method');
        List<String>lstVideoVersion = new List<String>();
        // Echo data received to debug logs
        System.debug ('Echo data stream received: ' + TitleInfo);
        //Get a list of Countries               
        List<Country__c> cl = [Select ID, Name, Country_Code2__c FROM Country__c];       
        Map<String, String> countryMap = new Map<String, String>();
        for (Country__c c:cl)
        {
            countryMap.put(c.Country_Code2__c, c.Id);       
        }
        
        //added by shalini - fetch list of video versions from the title info
         for(LocalTitleDetails ltDetail: TitleInfo){
            lstVideoVersion.add(ltDetail.Video_Version);
        }
        
        //added by shalini - to query the list of Titles by filtering  the video versions from the title info                 
        List<Title__c> tl = [Select ID, Name, Video_Version__c FROM Title__c where Video_Version__c IN : lstVideoVersion];       
        Map<String, Title__c> titleMap = new Map<String, Title__c>();
        for (Title__c t:tl)
        {
            titleMap.put(t.Video_Version__c, t);       
        }
        //Get a list of Languages
        List<Language__c> ll = [Select Id, Name, Language_Code_2__c FROM Language__c];
        Map<String, String> languageMap = new Map<String, String>();    
        for (Language__c l:ll)
        {
            languageMap.put(l.Language_Code_2__c.toLowerCase(), l.Id);              
        } 
        
        // Loop control variable to retrieve relevant data points
        Integer counter = 0;
         
        // Perform mapping of records
        mapDataValues(TitleInfo, countryMap, languageMap, titleMap);
        
        System.debug ('Echo size of listOfTitles if not null');
        // If global list of data is not empty, perform upsert
        if (listOfTitles != null && listOfTitles.size() > 0)
        {
            System.debug ('Echo size of listOfTitles if not null' + listOfTitles.size());
            System.debug ('listOfTitles if not null' + listOfTitles);
         
            //Remove duplicate records from a list
            listOfTitles = removeDuplicates(listOfTitles);
            
            // Perform list of title update using Database DML methods
            Database.upsertResult[] results = Database.upsert (listOfTitles, Local_Title__c.Key__c, false);
            
            // Loop through to check results
            for (Database.upsertResult sr : results)
            {
                system.debug('results ===: ' + sr.isSuccess());
                // Create a generic response object with IDOC #
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = TitleInfo[counter].IntegrationID;
                aRespMsg.Video_Version = TitleInfo[counter].Video_Version;
                aRespMsg.Message_Result = sr.isSuccess();
                
                // Log all records to transaction table
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (TitleInfo[counter].IntegrationID, sr.isSuccess(), 'createVV', TitleInfo[counter]);
                
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
                        aErrLog = createErrorLog (TitleInfo[counter].IntegrationID, 'createVV', aRespMsg.Error_Message, TitleInfo[counter]);
                
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
    private static void mapDataValues (List<LocalTitleDetails> TitleInfo, Map<String, String> countryMap, Map<String, String> languageMap, Map<String, Title__c> titleMap)
    {
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
        // Map the values received to create new object
        for (integer i=0; i<TitleInfo.size(); i++)
        {
            System.debug('Executing for loop...' + i);
            // Create variables to hold local values of records
            Local_Title__c aTitle = new Local_Title__c();       
            if(TitleInfo[i].Locale != Null && TitleInfo[i].Locale != '' && TitleInfo[i].Video_Version != Null && TitleInfo[i].Video_Version != '')
            {
                //get country and language code from locale
                //ER - 553 Start
                if(localeMap.containsKey(TitleInfo[i].Locale)){
                    languageCode = localeMap.get(TitleInfo[i].Locale).Language_Code__c;
                    countryCode = localeMap.get(TitleInfo[i].Locale).Country_Code__c;
                }
                else{
                    languageCode = TitleInfo[i].Locale.substringBefore('_').toLowerCase();
                    countryCode = TitleInfo[i].Locale.substringAfter('_');
                }
                /*
                else{
                    languageCode = TitleInfo[i].Locale.substringBefore('_').toLowerCase();
                    countryCode = TitleInfo[i].Locale.substringAfter('_');
                    //check to see if you need to change the language to those special cases, ie. Latam Spanish,
                    // or french canadian or brasilian portugese
                    
                    if (countryCode.equalsIgnoreCase('CA')&&languageCode.equalsIgnoreCase('fr')) 
                        languageCode='cf';
                    if (countryCode.equalsIgnoreCase('BR')&&languageCode.equalsIgnoreCase('pt')) 
                        languageCode='bp';
                    if (!countryCode.equalsIgnoreCase('ES')&&(languageCode.equalsIgnoreCase('es'))||languageCode.equalsIgnoreCase('ce')) 
                        languageCode='sp';
                }*///ER - 553 End
                
                String vv=TitleInfo[i].Video_Version;
                String key=vv+'_'+languageCode.toLowerCase()+'_'+countryCode;
                
                // Focus on items to add to title object first, TODO: ***checking for null values
                //added by shalini for updating local title ids that have salesforce id
                /*if(aTitle.Name.startsWithIgnoreCase('a0K')){
                    aTitle.Name = TitleInfo[i].Title_Name;
                }else*/
                
                if(TitleInfo[i].Local_Title_Name != null){
                    aTitle.Name = TitleInfo[i].Local_Title_Name.left(80);  //this changed .name is only 80 char 
                    aTitle.Local_Title__c = TitleInfo[i].Local_Title_Name; //full title name is stored here
                }
                
                /*ER-293 added by shalini for assigning Local title name same as Title Name */
                if(TitleInfo[i].Local_Title_Name == null || TitleInfo[i].Local_Title_Name.length() == 0){
                    aTitle.Name = titleMap.get(vv).Name.left(80);  //this changed .name is only 80 char 
                    aTitle.Local_Title__c = titleMap.get(vv).Name; //full title name is stored here
                }
                /* end of ER-293 enhancement*/
                //aTitle.Video_Version__c = vv;
                
                if(countryMap.containsKey(countryCode) && countryMap.get(countryCode) != null){
                    aTitle.Country__c = countryMap.get(countryCode);     //lookup mapping to get the id of this country code
                }
                
                if(languageMap.containsKey(languageCode) && languageMap.get(languageCode) != null){
                    aTitle.Language__c = languageMap.get(languageCode);  //lookup mapping to get the id of this language code
                }
                if(titleMap.containsKey(vv) && titleMap.get(vv) != null){
                    aTitle.Title__c = titleMap.get(vv).Id;  //lookup mapping to get the id of this language code
                }
                //aTitle.Locale__c = TitleInfo[i].Locale;
                
                if (TitleInfo[i].Status!=null && TitleInfo[i].Status!='') {
                    aTitle.Status__c = TitleInfo[i].Status;
                }
                
                if(TitleInfo[i].Local_Rating_System != null && TitleInfo[i].Local_Rating_System != ''){
                    aTitle.Local_Rating_System__c = TitleInfo[i].Local_Rating_System;
                }
                
                //ER-000665 : Add Rating Reason to Local Data
                if(TitleInfo[i].Local_Rating_Comment != null && TitleInfo[i].Local_Rating_Comment != ''){
                     aTitle.Rating_Reason__c = TitleInfo[i].Local_Rating_Comment;
                }
                
                aTitle.Key__c = key;
                
                if(TitleInfo[i].Local_Rating != null && TitleInfo[i].Local_Rating != ''){
                    aTitle.Local_Rating__c = TitleInfo[i].Local_Rating;
                }
                
                if(TitleInfo[i].Local_Synopsis != null && TitleInfo[i].Local_Synopsis != ''){
                    aTitle.Local_Synopsis__c = TitleInfo[i].Local_Synopsis;
                }
                /* added by shalini -- er- 272 MSB will not update this field
                if (TitleInfo[i].Local_DVD_Release_Date != Null && TitleInfo[i].Local_DVD_Release_Date != ''){
                   
                   // aTitle.Local_DVD_Release_Date__c = date.valueof(TitleInfo[i].Local_DVD_Release_Date);
                }*/
                
                // Add record just created as new record in application
                //ER-547: Start
                if(TitleInfo[i].TV_Title != null && TitleInfo[i].TV_Title != '')
                {
                    aTitle.TV_Title__c = TitleInfo[i].TV_Title;
                }
                
                if(countryCode.equalsIgnoreCase('US') || countryCode.equalsIgnoreCase('CA'))
                // aTitle.Local_TV_Air_Date__c = TitleInfo[i].TV_Title != null ? Date.valueOf(TitleInfo[i].Local_TV_Air_Date) : NULL;
                   aTitle.Local_TV_Air_Date__c = TitleInfo[i].Local_TV_Air_Date != null && TitleInfo[i].Local_TV_Air_Date != ''  ? Date.valueOf(TitleInfo[i].Local_TV_Air_Date) : NULL; 
                /*----Commenting For SINC0933686 - Start----
                //ER-000734 start
                else 
                    aTitle.Local_TV_Air_Date__c = null;
                //ER-000734 end
                ------Commenting For SINC0933686 - Start-----*/
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
                listOfTitles.add(aTitle);
            }
            else
            {
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = TitleInfo[i].IntegrationID;
                aRespMsg.Video_Version = TitleInfo[i].Video_Version;
                aRespMsg.Message_Result = false;
                aRespMsg.Error_Message = 'Video_Version or Locale is missing!';
                responses.add(aRespMsg);
                
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (TitleInfo[i].IntegrationID, false, 'createVV.mapDataValues', TitleInfo[i]);
                listOfTransactions.add(aTLog);
                
                Error_Log__c aErrLog = new Error_log__c();
                aErrLog = createErrorLog (TitleInfo[i].IntegrationID, 'createVV.mapDataValues', 'Video_Version or Locale is missing!', TitleInfo[i]);
                listOfErrors.add(aErrLog);
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
    
    /* Added by Mahesh on 07/27/2015 to remove Duplicates : EL# on QA - EL-0002853 and many more with same error message*/
    private static List<Local_Title__c> removeDuplicates(List<Local_Title__c> pListOfTitles){
        map<String, Local_Title__c> localTitleMap = new map<String, Local_Title__c>();
        for(Local_Title__c localTitle : pListOfTitles){
            SYSTEM.DEBUG('MAP kEY ====> ' + localTitle.Key__c);
            localTitleMap.put(localTitle.Key__c, localTitle);
        }
        return localTitleMap.values();
    }
}