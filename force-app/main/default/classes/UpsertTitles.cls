/*****************************************************************************
 * Class Name:      UpsertTitles
 * Description:     Inbound Apex Web Services to update WB Title object and 
 *                  related objects received from WB legacy systems 
 *
 * Author:          Date:           Description
 * Jason Cook       9/4/2014        Created initial version of class
 * Jason Cook       9/12/2014       Updated to add Localized titles
 *                                  Updated to add additional parameter values
 * Andrew Hilsher   10/21/2014      Removed LocalTitle
 *****************************************************************************/
 
global class UpsertTitles
{
     // Global list of titles after mapping of data
     global static List<Title__c> listOfTitles = new List<Title__c>();
    
    // Class definition of the inbound title object for de-serialization
     global class TitleDetails 
     {
        // String names match SFDC API Names for associated objects (Title__c or MPM__c)
        webService String IDOC_Number;                  // Captures/store IDOC #
        webService String Family_MPM;                   // Maps to ECC:???
        webService String Video_Version;                // Maps to ECC:MARA-MATNR (external id)
        webService String Title_Name;                   // Maps to ECC:MAKT-MAKTX
        //this status gets updated to active or inactive based upon the deletion indicator - processed at broker
        webService String Status;                       // Maps to ECC:MVKE-VMSTA
        webService String Content_Type;                 // Maps to ECC:MARA_ZZVERCATID
        webService String Production_Year;              // Maps to MSB:???
        webService String Alias;                        // Maps to ECC:???
        //webService String Title_Type;                 // Maps to IPM or MSB:???
        webService String MPM_Number;                   // Maps to ECC:MARA-ZZMPMNBR (external id)
        webService String MPM_Long_Desc;                // Maps to ECC:MAKT-MAKTX (translation in MQ)
        webService String MPM_Short_Desc;               // Maps to ECC:MAKT-MAKTX (translation in MQ)
        webService String MPM_Family_Desc;
        webService String Abstract_EIDR;                // Maps to MSB:???
        //webService String Business_Unit;              // Maps to ???:???
        webService String Synopsis;                     // Maps to ECC:???
        webService String Short_Synopsis;               // Maps to ECC:???
        webService String Genre;                        // Maps to ECC:???
        //webService Integer Run_Time;                  // Maps to IPM:???
        //webService Date First_Available_Date;             // Maps to ???:???
        webService String Season;                       // Maps to ECC:???
        webService Integer Episode;                     // Maps to ECC:???
        webService String Episode_Description;
        //webService String US_Rating_System;               // Maps to ECC:???
        webService String US_Rating;                    // Maps to ECC:???
        //webService Date US_Theatrical_Release_Date;       // Maps to IPM:???
        //webService Decimal US_Box_Office;             // Maps to IPM:???
        //webService Date US_TV_Air_Date;                   // Maps to IPM:???
        //webService Date US_Pay_TV_Start_Date;         // Maps to IPM:???
        //webService Date US_DVD_Release_Date;          // Maps to IPM:???
        //webService Date US_BD_Release_Date;               // Maps to IPM:???
        //webService String Digital_Deal_Type;          // Maps to IPM:???
        //webService String Film_Color;                 // Maps to IPM:???
        webService String Studio;                       // Maps to ECC:???
        //webService String Talent;                     // Maps to MSB:???
        webService String Original_Language;            // Maps to ???:???
        webService String Film_Color;                   // Maps to MSB:???
        //webService String Deletion_Indicator;
        
     }
     
      // Class definition of the returned data struction
     global class ResponseMessage 
     {
        webService String SFId;                         // IDOC that was processed
        webService String IDOC_Number;                  // IDOC that was processed
        webService Boolean Message_Result;              // True/False indicator of success
        webService String Error_Message;                // Detailed message of failure
        webService String Video_Version;                // Video Version that caused the failure
        webService String MPM_Short_Desc;               //MPM Short Description value -> String/null
     }
     
    /**************************************************************************
     * Method Name:     createTitle
     * Description:     Exposed as a web service to insert/update title data
     * Parameters:      Accepts a List of TitleInfo object for deserialization
     * Returns:         Error/success responses
     **************************************************************************/
     webservice static List<ResponseMessage> createTitle (List<TitleDetails> TitleInfo)
     {
        System.debug ('Entered createTitle method');
        
        // Echo data received to debug logs
        System.debug ('Echo data stream received: ' + TitleInfo);
        
        // Create Error Log and Transaction Log lists for auditing purposes and response object array
        List <Transaction_Log__c> listOfTransactions = new List<Transaction_Log__c>();
        List <Error_Log__c> listOfErrors = new List<Error_Log__c>();
        List <ResponseMessage> responses = new List<ResponseMessage>();
        
        // Loop control variable to retrieve relevant data points
        Integer counter = 0;
        
        // Perform mapping of records
        mapDataValues(TitleInfo);
        
        System.debug ('Echo size of listOfTitles if not null');
        // If global list of data is not empty, perform upsert
        if (listOfTitles != null && listOfTitles.size() > 0)
        {
            System.debug ('Echo size of listOfTitles if not null' + listOfTitles.size());
         
            // Perform list of title update using Database DML methods
            Database.upsertResult[] results = Database.upsert (listOfTitles, Title__c.Video_Version__c, false);
            
            // Loop through to check results
            for (Database.upsertResult sr : results)
            {
                system.debug('SR =====> ' + sr);
                // Create a generic response object with IDOC #
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IDOC_Number = TitleInfo[counter].IDOC_Number;
                aRespMsg.Video_Version = TitleInfo[counter].Video_Version;
                aRespMsg.MPM_Short_Desc = TitleInfo[counter].MPM_Short_Desc;
                aRespMsg.Message_Result = sr.isSuccess();
                //aRespMsg.SFId = sr.getId(); //Added by Mahesh. Need to confirm whether we can add it or not
                
                // Log all records to transaction table
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (TitleInfo[counter].IDOC_Number, sr.isSuccess(), 'createTitle', TitleInfo[counter]);
                
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
                        aErrLog = createErrorLog (TitleInfo[counter].IDOC_Number, 'createTitle', aRespMsg.Error_Message, TitleInfo[counter]);
                
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
    private static void mapDataValues (List<TitleDetails> TitleInfo)
    {
        System.debug ('Entered mapDataValues method');

        //sriniz changes start for ER-65
        List<String> videoVersions = new List<String>();
        for (integer j=0; j<titleInfo.size(); j++)
            videoVersions.add(TitleInfo[j].Video_Version);
        
        // Map of Title based on Video version.
        Map<String,Title__c> mapVVToTitle = new Map<String,Title__c>();
        for(Title__c objTitle : [Select Id, Name, Video_Version__c, Content_Type__c from Title__c WHERE Video_Version__c IN :videoVersions]) {
            mapVVToTitle.put(objTitle.Video_Version__c, objTitle);
        }
        //sriniz changes end for ER-65
        
        //SINC0547965 changes start
        Set<String> MpmNumbers = new Set<String>();
        for(TitleDetails t : TitleInfo)
            MpmNumbers.add(t.MPM_Number);
                Map<String,MPM__c> mpmRecMap = new Map<String,MPM__c>();
                List <MPM__c> mpmlist = [Select Id,MPM_Short_Desc__c,MPM_Number__c from MPM__c Where MPM_Number__c IN : MpmNumbers];
            for(MPM__c m : mpmlist){
                mpmRecMap.put(m.MPM_Number__c,m);
            }
        //SINC0547965 changes finish
        
        // Map the values received to create new object
        for (integer i=0; i<TitleInfo.size(); i++)
        {
            System.debug('Executing for loop...' + i);
            // Create variables to hold local values of records
            Title__c aTitle = new Title__c();
            MPM__c aMPM = new MPM__c();
    
            if (TitleInfo[i].MPM_Number != null)
            {
                aMPM.Name = TitleInfo[i].MPM_Number;
                aMPM.MPM_Number__c = TitleInfo[i].MPM_Number; //it is in here twice because this field is the ext id
                //aMPM.Abstract_EIDR__c = TitleInfo[i].Abstract_EIDR;                
                //aMPM.MPM_Short_Desc__c = TitleInfo[i].MPM_Short_Desc;   //Commented for SINC0547965
                aMPM.Family_MPM_Number__c = TitleInfo[i].Family_MPM;
                aMPM.MPM_Family_Desc__c = TitleInfo[i].MPM_Family_Desc;
                //aMPM.Production_Year__c = TitleInfo[i].Production_Year;
                //aMPM.Film_Color__c = TitleInfo[i].Film_Color;
                
                //SINC0547965 changes start
                    if(mpmRecMap.containsKey(TitleInfo[i].MPM_Number)){
                        if(mpmRecMap.get(TitleInfo[i].MPM_Number).MPM_Short_Desc__c == null ){
                            aMPM.MPM_Short_Desc__c = TitleInfo[i].MPM_Short_Desc;
                        }
                    }
                    else
                    aMPM.MPM_Short_Desc__c = TitleInfo[i].MPM_Short_Desc;
                //SINC0547965 changes finish
                    
                upsert aMPM MPM_Number__c;
            }
            // Focus on items to add to title object first, TODO: ***checking for null values
            aTitle.MPM__c = aMPM.id;
            aTitle.Name = TitleInfo[i].Title_Name;
            aTitle.MPM_Family_Desc__c = TitleInfo[i].MPM_Family_Desc;
            //aTitle.Family_MPM__c = TitleInfo[i].Family_MPM;
            aTitle.Video_Version__c = TitleInfo[i].Video_Version;
            aTitle.Status__c = TitleInfo[i].Status;
            
            //sriniz changes start for ER-65
            String titleContentType = '';
            if(mapVVToTitle.containsKey(TitleInfo[i].Video_Version)) {
                titleContentType = mapVVToTitle.get(TitleInfo[i].Video_Version).Content_Type__c;
                //Condition modified on 29-Dec-2016 for SINC0707454
                if(titleContentType == NULL || (titleContentType != NULL && !titleContentType.contains('Collection'))){
                    aTitle.Content_Type__c = TitleInfo[i].Content_Type;
                }
            } else {
                aTitle.Content_Type__c = TitleInfo[i].Content_Type;
            }
            //sriniz changes end for ER-65
            
      /* Commented By Milon
            if (!TitleInfo[i].Content_Type.equals('Feature') && !TitleInfo[i].Content_Type.equals('Season')) {
                aTitle.Digital_Planning__c = 'No';
            }
            else {
                aTitle.Digital_Planning__c = 'Yes';
            }
      */
         //   if (TitleInfo[i].Deletion_Indicator.equals('X')) {
         //       aTitle.Status__c = 'Cancelled';
         //   }
         //   else {
         //       aTitle.Status__c = 'Active';
         //   }
            //aTitle.MPM_Long_Desc__c = TitleInfo[i].MPM_Long_Desc;
            // Implemented by shalini for String too Large error 
            
            aTitle.MPM_Long_Desc__c = (TitleInfo[i].MPM_Long_Desc.length() > 255) ? TitleInfo[i].MPM_Long_Desc.substring(0,254) : TitleInfo[i].MPM_Long_Desc;
            
            //aTitle.Title_Type__c = TitleInfo[i].Title_Type;
            //aTitle.Business_Unit__c = TitleInfo[i].Business_Unit;
            aTitle.Synopsis__c = TitleInfo[i].Synopsis;
            aTitle.Short_Synopsis__c = TitleInfo[i].Short_Synopsis;
            aTitle.Genre__c = TitleInfo[i].Genre;
            //aTitle.Run_Time__c = TitleInfo[i].Run_Time;
            //aTitle.First_Available_Date__c = TitleInfo[i].First_Available_Date;
            aTitle.Season__c = TitleInfo[i].Season;
            
            aTitle.Episode__c = (TitleInfo[i].Episode==0) ? null : TitleInfo[i].Episode;
            
            aTitle.Episode_Description__c = TitleInfo[i].Episode_Description;
            //aTitle.US_Rating_System__c = TitleInfo[i].US_Rating_System;
            aTitle.US_Rating__c = TitleInfo[i].US_Rating;
            //aTitle.US_Theatrical_Release_Date__c = TitleInfo[i].US_Theatrical_Release_Date;
            //aTitle.US_Box_Office__c = TitleInfo[i].US_Box_Office;
            //aTitle.US_TV_Air_Date__c = TitleInfo[i].US_TV_Air_Date;
            //aTitle.US_Pay_TV_Start_Date__c = TitleInfo[i].US_Pay_TV_Start_Date;
            //aTitle.US_DVD_Release_Date__c = TitleInfo[i].US_DVD_Release_Date;
            //aTitle.US_BD_Release_Date__c = TitleInfo[i].US_BD_Release_Date;
            //aTitle.Digital_Deal_Type__c = TitleInfo[i].Digital_Deal_Type;
            //aTitle.Film_Color__c = TitleInfo[i].Film_Color;
            aTitle.Studio__c = TitleInfo[i].Studio;
            //aTitle.Talent__c = TitleInfo[i].Talent;
            //following line commented because of changing  original language text feild to lookup feild
            //  aTitle.Original_Language__c = TitleInfo[i].Original_Language;

            // Add record just created as new record in application
            listOfTitles.add(aTitle);
            
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
    private static Transaction_Log__c createTransactionLog (String idoc, Boolean isSuccess, String methodName, TitleDetails TitleInfo)
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
    private static Error_Log__c createErrorLog (String idoc, String methodName, String errMessage, TitleDetails TitleInfo)
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
}