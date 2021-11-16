/*****************************************************************************
 * Class Name:      UpdateEditVersion
 * Description:     Inbound Apex Web Services to update WB Local Data object and
 *                  related objects received from WB legacy systems 
 *
 * Author:          Date:           Description
 * Mahesh Hirugade  07/22/2015      First Draft
 *****************************************************************************/
global class UpdateEditVersion {
    
    global static List<Local_Title__c> titlesToBeUpdated = new List<Local_Title__c>();
    global static List<Local_Title__c> titleUVdateToBeUpdated = new List<Local_Title__c>();
    global static List<Local_Title__c> titlesToBeUpserted = new List<Local_Title__c>();
    
    //Set of Video_Versions that do not match with any of the record in Salesforce
    global static set<String> vvNotFoundSet = new set<String>();
    
    // Create Error Log and Transaction Log lists for auditing purposes and response object array
    global static List <Transaction_Log__c> listOfTransactions = new List<Transaction_Log__c>();
    global static List <Error_Log__c> listOfErrors = new List<Error_Log__c>();
    global static List <ResponseMessage> responses = new List<ResponseMessage>();
    
    private static map<String, LocalTitleDetails> videoVersionMap = new map<String, LocalTitleDetails>();//Mahesh : May be not in use - Check and delete
    private static map<String, LocalTitleDetails> vvLocalTitleMap;
    
    private static map<String, Local_Title__c> key_LocalTitleMap = new map<String, Local_Title__c>();
    
    // Class definition of the inbound title object for de-serialization
    global class LocalTitleDetails
    {
        // String names match SFDC API Names for associated objects (Title__c or MPM__c)
        webservice String IntegrationID;                // Captures/store IDOC #
        webservice String Video_Version;                // Maps to ECC:Video Version Number
        webservice String ALID;                         // Maps to MSB:Asset_Logical_Identifier
        webservice String CID;                          // Maps to ECC:Content_Idendifier
        webservice String Version_EIDR;                 // Maps to ECC:Version_EIDR
        webservice String Status;                       // Active or Inactive. if inactive then del cid,alid,uvdate.
        webservice list<LocalePublishDate> LocalePublishDateList;
        webservice List<Territory> TerritoryList;
    }
     
    global class Territory
    {
        webservice String Territory;                    // Maps to ECC:Locale
    }
    
    global class LocalePublishDate
    {
        webservice String Locale;                       // Maps to ECC:Locale
        webservice String UV_Published_Date;            // Maps to ECC:UV_Coordinator_Is_Published_Date
    }
    
    // Class definition of the returned data struction
    global class ResponseMessage
    {
        webservice String IntegrationID;                // IDOC that was processed
        webservice Boolean Message_Result;              // True/False indicator of success
        webservice String Error_Message;                // Detailed message of failure
        webservice String Video_Version;                // Video Version that caused the failure
    }
    
    /**************************************************************************
     * Method Name:     updateEditVersion
     * Description:     Exposed as a web service to insert/update title data
     * Parameters:      Accepts a List of TitleInfo object for deserialization
     * Returns:         Error/success responses
    **************************************************************************/
    webservice static List<ResponseMessage> updateEditVersion (List<LocalTitleDetails> TitleInfo)
    {
        vvLocalTitleMap = new map<String, LocalTitleDetails>();
        
        Integer counter;
        
        map<String, Country__c> countryMap = new map<String, Country__c>();
        map<String, String> languageMap = new map<String, String>();
        
        //Get a list of Countries
        //List<Country__c> cl = [Select ID, Name, Country_Code2__c FROM Country__c];
        for (Country__c c:[Select ID, Name, Country_Code2__c FROM Country__c]){
            countryMap.put(c.Country_Code2__c, c);
        }
        
        //Get a list of Languages
        //List<Language__c> ll = [Select Id, Name, Language_Code_2__c FROM Language__c];
        for (Language__c l:[Select Id, Name, Language_Code_2__c FROM Language__c]){
            languageMap.put((l.Language_Code_2__c).toLowerCase(), l.Id);
        }
        
        // Perform mapping of records
        mapDataValues(TitleInfo, languageMap, CountryMap);
        
        // If titlesToBeUpdated is not empty, perform update
        if (titlesToBeUpdated != null && titlesToBeUpdated.size() > 0)
        {
            counter = 0;
            set<String> integrationIdSet = new set<String>();
            // Perform list of title update using Database DML methods
            Database.saveResult[] results = Database.update(titlesToBeUpdated,false);
            
            for (Database.saveResult sr : results)
            {
                //LocalTitleDetails ltd = videoVersionMap.get(titlesToBeUpdated[counter].Title_VV_F__c);
                LocalTitleDetails ltd = vvLocalTitleMap.get(titlesToBeUpdated[counter].Title_VV_F__c);
                
                if(ltd != null && !integrationIdSet.contains(ltd.IntegrationID))
                {
                    ResponseMessage aRespMsg = new ResponseMessage();
                    aRespMsg.IntegrationID = ltd.IntegrationID;
                    aRespMsg.Video_Version = ltd.Video_Version;
                    aRespMsg.Message_Result = sr.isSuccess();
                    system.debug('response msg' + aRespMsg);
                    
                    // Log all records to transaction table
                    Transaction_Log__c aTLog = new Transaction_log__c();
                    aTLog = createTransactionLog (ltd.IntegrationID, sr.isSuccess(), 'updateEditVersion', ltd);
                    system.debug('Transaction log ' + aTLog);
                    
                    // Check if success and build error log if appropriate or success response
                    if (!sr.isSuccess())
                    {
                        // Failed upsert and need to update response with error message and log error message - could be multiple
                        for (Database.Error err : sr.getErrors())
                        {
                            aRespMsg.Error_Message = err.getStatusCode() + ':' + err.getMessage();
                            // Create Error Log Entry
                            Error_Log__c aErrLog = new Error_log__c();
                            aErrLog = createErrorLog (ltd.IntegrationID, 'updateEditVersion', aRespMsg.Error_Message, ltd);
                            System.debug ('Unable to upsert record: ' + err.getStatusCode() + ':' + err.getMessage());
                            listOfErrors.add(aErrLog);
                        }
                    }
                    responses.add(aRespMsg);
                    listOfTransactions.add(aTLog);
                    integrationIdSet.add(ltd.IntegrationID);
                }
                counter++;
            }
        }
        
        // If no record found with given video_version
        if(vvNotFoundSet.size() > 0)
        {
            for(String vv : vvNotFoundSet)
            {
                LocalTitleDetails ltd = vvLocalTitleMap.get(vv);
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = ltd.IntegrationID;
                aRespMsg.Video_Version = ltd.Video_Version;
                aRespMsg.Message_Result = false;
                aRespMsg.Error_Message = 'No matching record found!';
                
                // Log all records to transaction table
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (ltd.IntegrationID, false, 'updateEditVersion', ltd);
                
                Error_Log__c aErrLog = new Error_log__c();
                aErrLog = createErrorLog (ltd.IntegrationID, 'updateEditVersion', aRespMsg.Error_Message, ltd);

                listOfErrors.add(aErrLog);
                responses.add(aRespMsg);
                listOfTransactions.add(aTLog);
            }
        }
        
        try
        {
            // Add the list of transactions
            if (listOfTransactions != null && listOfTransactions.size() > 0){
                insert listOfTransactions;
            }
            
            if (listOfErrors != null && listOfErrors.size() > 0){
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
    public static void mapDataValues (List<LocalTitleDetails> TitleInfo, map<String,String> languageMap, map<String,Country__c> CountryMap)
    {
        set<string> pubDateLDKeySet = new set<string>();
        set<String> territorySet = new set<String>();
        set<String> videoVersionSet = new set<String>();
        set<String> TSTrueVVSet = new set<String>();
        set<String> TSFalseVVSet = new set<String>();
        
        set<String> vvFoundSet = new set<String>();
        
        List<Local_Title__c> localTitleTrritoryList;
        
        for(LocalTitleDetails LT : TitleInfo)
        {
            vvLocalTitleMap.put(LT.Video_Version,LT);
            
            if(LT.Video_Version != Null && LT.Video_Version != ''){
                
                if( (LT.TerritoryList == null || LT.TerritoryList.size() == 0) ||
                    (LT.TerritoryList.size() == 1 && (LT.TerritoryList[0].Territory == null || LT.TerritoryList[0].Territory.equalsIgnoreCase('NULL') || LT.TerritoryList[0].Territory == ''))
                ){
                    
                    TSFalseVVSet.add(LT.Video_Version);
                }
                else {
                    for(Territory objTerritory : LT.TerritoryList){
                        if(objTerritory.Territory.length() == 2 && countryMap.containsKey(objTerritory.Territory)){
                            Country__c objCountry = countryMap.get(objTerritory.Territory);
                            territorySet.add(objCountry.Name);
                        }else{
                            territorySet.add(objTerritory.Territory.trim());
                        }
                        territorySet.add(objTerritory.Territory.trim());
                        TSTrueVVSet.add(LT.Video_Version);
                    }
                }
                
                if(LT.LocalePublishDateList != null){
                    for(LocalePublishDate lpd : LT.LocalePublishDateList){
                        pubDateLDKeySet.add(prepareKey(lpd, LT.Video_Version));
                    }
                }
            }
            else
            {
                if(LT.LocalePublishDateList != null){
                    for(LocalePublishDate lpd : LT.LocalePublishDateList){
                        
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = LT.IntegrationID;
                aRespMsg.Video_Version = LT.Video_Version;
                
                aRespMsg.Message_Result = false;
                aRespMsg.Error_Message = 'Local data not available in SFDC ' + prepareKey(lpd,LT.Video_Version);
                system.debug('local data' + aRespMsg);
                responses.add(aRespMsg);
                
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (LT.IntegrationID, false, 'updateEditVersion.mapDataValues', LT);
                listOfTransactions.add(aTLog);
                
                Error_Log__c aErrLog = new Error_log__c();
                aErrLog = createErrorLog (LT.IntegrationID, 'updateEditVersion.mapDataValues', 'Local data not available in SFDC ' + prepareKey(lpd,LT.Video_Version),LT);
                system.debug('local data 2' + aErrLog);
                listOfErrors.add(aErrLog);
                }
             }
                
           }
        }
        
        if(territorySet != null && territorySet.size() > 0){
            
            localTitleTrritoryList = new List<Local_Title__c>([
                select Id, Key__c, Territory_Specific__c, Title_VV_F__c
                  from Local_Title__c
                 where Title_VV_F__c IN :vvLocalTitleMap.keySet()
                   AND Country__r.Name IN :territorySet
            ]);
            
            
            //If has Territory Specific Data then query all and update with TS = True
            if(localTitleTrritoryList != null && localTitleTrritoryList.size() > 0){
                for(Local_Title__c objLT : localTitleTrritoryList){
                    vvFoundSet.add(objLT.Title_VV_F__c);
                    LocalTitleDetails ltd = vvLocalTitleMap.get(objLT.Title_VV_F__c);
                    
                    //objLT.Version_EIDR__c = ltd.Version_EIDR;
                    objLT.Territory_Specific__c = true;
                    
                    if(ltd.Status == 'Inactive'){
                        objLT.ALID__c = null;
                        objLT.CID__c = null;
                    }
                    else{
                        objLT.ALID__c = ltd.ALID;
                        objLT.CID__c = ltd.CID;
                    }
                    titlesToBeUpdated.add(objLT);
                }
            }
        }
        
        system.debug('Before TSFalseVVSet ===: ' + TSFalseVVSet);
        //IF TS data not present, only update ALID, CLID and Edit EIDR
        if(TSFalseVVSet != null && TSFalseVVSet.size() > 0){
            system.debug('TSFalseVVSet ===: ' + TSFalseVVSet);
            List<Local_Title__c> TSFalseVVList = [select Id, Key__c, Territory_Specific__c, Title_VV_F__c from Local_Title__c where Title_VV_F__c IN :TSFalseVVSet and Territory_Specific__c = false];
            system.debug('TSFalseVVList ===: ' + TSFalseVVList.size());
            
            for(Local_Title__c objLT : TSFalseVVList){
                
                system.debug('check local title ' + objLT);
                vvFoundSet.add(objLT.Title_VV_F__c);
                system.debug('check vvFoundSet ' + vvFoundSet);
                LocalTitleDetails ltd = vvLocalTitleMap.get(objLT.Title_VV_F__c);
                system.debug('check vvLocalTitleMap ' + vvLocalTitleMap);
                //objLT.Version_EIDR__c = ltd.Version_EIDR;
                if(ltd.Status == 'Inactive'){
                    objLT.ALID__c = null;
                    objLT.CID__c = null;
                }
                else{
                    objLT.ALID__c = ltd.ALID;
                    objLT.CID__c = ltd.CID;
                }
                titlesToBeUpdated.add(objLT);
            }
        }
        
        system.debug('pubDateLDKeySet ==: ' + pubDateLDKeySet);
        system.debug('Query results ==: ' + [select Id, Key__c, Country__c, Country__r.Name, Territory_Specific__c, Title_VV_F__c from Local_Title__c where Key__c IN :pubDateLDKeySet]);
        
        if(pubDateLDKeySet != null && pubDateLDKeySet.size() > 0){
            Map<Id,Local_Title__c> mapLocalTitle=new Map<Id,Local_Title__c>();
            LocalTitleDetails LT=new LocalTitleDetails();
            for(Local_Title__c objLT : [select Id, Key__c, Country__c, Country__r.Name, Territory_Specific__c, Title_VV_F__c, UV_Published_Date__c from Local_Title__c where Key__c IN :pubDateLDKeySet]){
                vvFoundSet.add(objLT.Title_VV_F__c);
                 LT = vvLocalTitleMap.get(objLT.Title_VV_F__c);
                
                if(LT != null && LT.LocalePublishDateList != null && LT.LocalePublishDateList.size() >0){
                    for(LocalePublishDate lpd : LT.LocalePublishDateList)
                    {
                        if(    lpd.Locale.substringAfter('_') != null && lpd.Locale.substringAfter('_') != '' 
                            && countryMap.containsKey(lpd.Locale.substringAfter('_').toUpperCase()) 
                            && countryMap.get(lpd.Locale.substringAfter('_').toUpperCase()).Id == objLT.Country__c
                        ){
                            if(LT.Status == 'Inactive'){
                                objLT.UV_Published_Date__c = null;
                                mapLocalTitle.put(objLT.Id,objLT);
                            }else{
                                //if(objLT.UV_Published_Date__c != null)
                                    objLT.UV_Published_Date__c = Date.valueOf(lpd.UV_Published_Date);
                                    mapLocalTitle.put(objLT.Id,objLT);
                            }
                           
                        }
                    }
               }
               
            }
            titleUVdateToBeUpdated.addAll(mapLocalTitle.values());
            if (titleUVdateToBeUpdated != null && titleUVdateToBeUpdated.size() > 0){
                Integer UVcounter;
                UVcounter = 0;
                set<String> integrationIdSet = new set<String>();
            
                //Perform list of title update using Database DML methods
                Database.saveResult[] UVresults = Database.update(titleUVdateToBeUpdated,false);
                system.debug('titleUVdateToBeUpdated ' + titleUVdateToBeUpdated);
                
                for (Database.saveResult Uvsr : UVresults)
                {
                    
                    if(LT!= null && !integrationIdSet.contains(LT.IntegrationID))
                    {
                        ResponseMessage aRespMsg = new ResponseMessage();
                        aRespMsg.IntegrationID = LT.IntegrationID;
                        aRespMsg.Video_Version = LT.Video_Version;
                        aRespMsg.Message_Result = Uvsr.isSuccess();
                        system.debug('response msg' + aRespMsg);
                        
                        // Log all records to transaction table
                        
                        Transaction_Log__c aTLog = new Transaction_log__c();
                        aTLog = createTransactionLog (LT.IntegrationID, Uvsr.isSuccess(), 'updateEditVersion', LT);
                        system.debug('Transaction log ' + aTLog);
                        
                        // Check if success and build error log if appropriate or success response
                        if (!Uvsr.isSuccess())
                        {
                            // Failed upsert and need to update response with error message and log error message - could be multiple
                            for (Database.Error err : Uvsr.getErrors())
                            {
                                aRespMsg.Error_Message = err.getStatusCode() + ':' + err.getMessage();
                                // Create Error Log Entry
                                Error_Log__c aErrLog = new Error_log__c();
                                aErrLog = createErrorLog (LT.IntegrationID, 'updateEditVersion', aRespMsg.Error_Message, LT);
                                System.debug ('Unable to upsert record: ' + err.getStatusCode() + ':' + err.getMessage());
                                listOfErrors.add(aErrLog);
                            }
                        }
                        responses.add(aRespMsg);
                        listOfTransactions.add(aTLog);
                        integrationIdSet.add(LT.IntegrationID);
                    }
                    
                    UVcounter++;
                }
            }
        }
        
        set<string> clonevvLocalTitleMapKeySet = vvLocalTitleMap.keySet().clone();
        
        system.debug('vvLocalTitleMap===: ' + vvLocalTitleMap);
        system.debug('clonevvLocalTitleMapKeySet===: ' + clonevvLocalTitleMapKeySet);
        system.debug('vvFoundSet===: ' + vvFoundSet);
        
        vvNotFoundSet = clonevvLocalTitleMapKeySet;
        vvNotFoundSet.removeAll(vvFoundSet);
        
        system.debug('vvNotFoundSet===: ' + vvNotFoundSet);
    }
    
    /**************************************************************************
     * Method Name:     prepareKey
     * Description:     Prepares a key which is combination of Video Version,
                        Language Code and Country code
     * Parameters:      LocalePublishDate, Video Version
     * Return Values:   A key which is combination of Video Version, Language
                        Code and Country code
    **************************************************************************/
    private static string prepareKey(LocalePublishDate lpd, String video_version){
        //ER - 553 Start
        //List<Locale_Map__c> localeList = new List<Locale_Map__c>([SELECT Id,Name,Country_Code__c,Language_Code__c FROM Locale_Map__c]);
        List<Locale_Map__c> localeList = Locale_Map__c.getAll().Values();
        Map<String,Locale_Map__c> localeMap = new Map<String,Locale_Map__c> ();
        String languageCode;
        String countryCode;
        for(Locale_Map__c locale : localeList){
                localeMap.put(locale.Name,locale);
        }
        if(localeMap.containsKey(lpd.Locale)){
            languageCode = localeMap.get(lpd.Locale).Language_Code__c;
            countryCode = localeMap.get(lpd.Locale).Country_Code__c;
        }
        else{
            languageCode = lpd.Locale.substringBefore('_');
            countryCode = lpd.Locale.substringAfter('_');
        }
        /*
        else
        {
            languageCode = lpd.Locale.substringBefore('_');
            countryCode = lpd.Locale.substringAfter('_');
            if (countryCode.equalsIgnoreCase('CA')&&languageCode.equalsIgnoreCase('fr')) 
                languageCode='cf';
            if (countryCode.equalsIgnoreCase('BR')&&languageCode.equalsIgnoreCase('pt')) 
                languageCode='bp';
            if (!countryCode.equalsIgnoreCase('ES')&&(languageCode.equalsIgnoreCase('es'))||languageCode.equalsIgnoreCase('ce')) 
                languageCode='sp'; 
        }
        *///ER - 553 End
            return video_version+'_'+languageCode+'_'+countryCode;
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
        Transaction_Log__c aLog = new Transaction_Log__c (IDOC__c = idoc, Invoked_Method__c = methodName);
        if (isSuccess)
        {
            aLog.Status__c = 'Success';
        }
        else
        {
            aLog.Status__c = 'Failure';
        }
        if (TitleInfo != null)
        {
            aLog.Input_Message__c = TitleInfo.toString();
        }
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
        Error_Log__c aLog = new Error_Log__c (IDOC__c = idoc, Invoked_Method__c = methodName, Error_Message__c = errMessage);
        if (TitleInfo != null)
        {
            aLog.Input_Message__c = TitleInfo.toString(); //TitleInfo;
        }
        return aLog;
    }
}