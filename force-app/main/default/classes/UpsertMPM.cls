/*****************************************************************************
 * Class Name:      UpsertMPM
 * Description:     Inbound Apex Web Services to update WB MPM Rel Date object and 
 *                  related objects received from WB legacy systems 
 *
 * Author:          Date:           Description
 * Andrew Hilsher   12/10/2014      First Draft
 *****************************************************************************/
 
global class UpsertMPM
{
     // Global list of titles after mapping of data
     global static List<MPM_Release_Date__c> listOfMPMrds = new List<MPM_Release_Date__c>();
    
     global static map<String, MPMrdDetails> mpmRdDetailMap = new map<String, MPMrdDetails>();
     // Create Error Log and Transaction Log lists for auditing purposes and response object array
     global static List <Transaction_Log__c> listOfTransactions = new List<Transaction_Log__c>();
     global static List <Error_Log__c> listOfErrors = new List<Error_Log__c>();
     global static List <ResponseMessage> responses = new List<ResponseMessage>();
    // Class definition of the inbound title object for de-serialization
     global class MPMrdDetails 
     {
        // String names match SFDC API Names for associated objects (MPM_Release_Date__c or MPM__c)
        webservice String IntegrationID;                 
        webservice String Abstract_EIDR;     
        webservice String Production_Year;
        webservice String Title_Name;
        webservice String Film_Color;                                           
        webservice String MPM_Number;                
        webservice String MPM_Status;               //maps to MPM Status;
        webservice String Record_Status;        //Active or Inactive;  if inactive it means soft delete.
        webservice list<ReleaseDetail> ReleaseDetailList;       
     }
     
     global class ReleaseDetail
     {
        webservice String Country_2_Code;                       // Maps to ECC:country code
        webservice String Theatrical_Release_Date;   
        webservice String TV_Airing_Date;          

     }
     
      // Class definition of the returned data struction
     global class ResponseMessage 
     {
        webservice String IntegrationID;                  // item that was processed
        webservice Boolean Message_Result;              // True/False indicator of success
        webservice String Error_Message;                // Detailed message of failure
        webservice String MPM_Number;                           // MPM that caused the failure
     }
     
    /************************************************************************** 
     * Method Name:     createMPMrd
     * Description:     Exposed as a web service to insert/update title data
     * Parameters:      Accepts a List of MPMinfo object for deserialization
     * Returns:         Error/success responses
     **************************************************************************/
     webservice static List<ResponseMessage> createMPMrd (List<MPMrdDetails> MPMinfo)
     {
        System.debug ('Entered createMPMrd method');
        
        // Echo data received to debug logs
        System.debug ('Echo data stream received: ' + MPMinfo.size());

        //Get a list of Countries               
        List<Country__c> cl = [Select ID, Name, Country_Code2__c FROM Country__c];       
        Map<String, String> countryMap = new Map<String, String>();
        for (Country__c c:cl)
        {
            countryMap.put(c.Country_Code2__c, c.Id);       
        }        
        
        // Loop control variable to retrieve relevant data points
        Integer counter = 0;
        
        // Perform mapping of records
        mapDataValues(MPMinfo, countryMap);
        
        System.debug ('Echo size of listOfMPMrds if not null');
        // If global list of data is not empty, perform upsert
        if (listOfMPMrds != null && listOfMPMrds.size() > 0)
        {
            System.debug ('Echo size of listOfMPMrds if not null' + listOfMPMrds.size());
         
            // Perform list of title update using Database DML methods
            Database.upsertResult[] results = Database.upsert (listOfMPMrds, MPM_Release_Date__c.Key__c, false);
            set<String> mpmNumberSet = new set<String>();
            // Loop through to check results
            for (Database.upsertResult sr : results)
            {
                // Create a generic response object with IDOC #
                MPMrdDetails mpmRd = mpmRdDetailMap.get(listOfMPMrds[counter].Key__c);
                if(!mpmNumberSet.contains(mpmRd.MPM_Number))
                {
                    ResponseMessage aRespMsg = new ResponseMessage();
                    aRespMsg.IntegrationID = mpmRd.IntegrationID;
                    aRespMsg.MPM_Number = mpmRd.MPM_Number;
                    aRespMsg.Message_Result = sr.isSuccess();
                    
                    // Log all records to transaction table
                    Transaction_Log__c aTLog = new Transaction_log__c();
                    aTLog = createTransactionLog (mpmRd.IntegrationID, sr.isSuccess(), 'createMPMrd', mpmRd);
                    
                    // Check if success and build error log if appropriate or success response
                    if (!sr.isSuccess())
                    {
                        for (Database.Error err : sr.getErrors())
                        {
                            // Update response
                            aRespMsg.Error_Message = err.getStatusCode() + ':' + err.getMessage();
                            
                            // Create Error Log Entry
                            Error_Log__c aErrLog = new Error_log__c();
                            aErrLog = createErrorLog (mpmRd.IntegrationID, 'createMPMrd', aRespMsg.Error_Message, mpmRd);
                    
                            // Echo error message to the debug log
                            System.debug ('Unable to upsert record: ' + err.getStatusCode() + ':' + err.getMessage());
                            
                            // Add to Error Log list
                            listOfErrors.add(aErrLog);
                        }
                    }
                    responses.add(aRespMsg);
                    listOfTransactions.add(aTLog);
                    mpmNumberSet.add(mpmRd.MPM_Number);
                }
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
    private static void mapDataValues (List<MPMrdDetails> MPMinfo, map<string,string> countryMap)
    {
        System.debug ('Entered mapDataValues method');

        list<MPM__c> MPMList = new list<MPM__c>();
        set<String> mpmNumberSet = new set<String>();
        map<String, Id> mpmIdMap = new map<String, Id>(); //key = mpm number ; value = mpm id
        set<String> duplicateMpmNumberSet = new set<String>(); // To handle duplicat records with same MPM Number(External Id)
        // Map the values received to create new object
        
        // Start X: Find records with duplicate MPM Numbers
        for (MPMrdDetails mpmDetail : MPMinfo)
        {	
			if(mpmNumberSet.contains(mpmDetail.MPM_Number))
				duplicateMpmNumberSet.add(mpmDetail.MPM_Number);
			else
				mpmNumberSet.add(mpmDetail.MPM_Number);
        }
        //End X
        //Start A: Upsert parent MPM__C records
        mpmNumberSet.clear();
        for (MPMrdDetails mpmDetail : MPMinfo)
        {
            if(!duplicateMpmNumberSet.contains(mpmDetail.MPM_Number)) // If not duplicate, proceed..else give error msg
            {
                if(mpmDetail.MPM_Number.trim().length() == 7){
                    MPM__c aMPM = new MPM__c();
                    aMPM.Name = mpmDetail.MPM_Number;
                    aMPM.MPM_Number__c = mpmDetail.MPM_Number; //it is in here twice because this field is the ext id
                    if (mpmDetail.Abstract_EIDR!=null) {
                        aMPM.Abstract_EIDR__c = mpmDetail.Abstract_EIDR;
                    }
                    if (mpmDetail.MPM_Status!=null) {
                        aMPM.Status__c = mpmDetail.MPM_Status;
                    }
                    if (mpmDetail.Film_Color!=null) {
                        aMPM.Film_Color__c = mpmDetail.Film_Color;
                    }
                    if (mpmDetail.Production_Year!=null) {
                        aMPM.Production_Year__c = mpmDetail.Production_Year;
                    }
                    if (mpmDetail.Title_Name!=null) {
                        aMPM.MPM_Short_Desc__c = mpmDetail.Title_Name;
                    }
                    mpmNumberSet.add(mpmDetail.MPM_Number);
                    MPMList.add(aMPM); 
                }
                else {
                    Error_Log__c aErrLog = new Error_log__c();
                    aErrLog = createErrorLog (mpmDetail.IntegrationID, 'createMPMRd.mapDataValues', 'Incorrect MPM Number !', mpmDetail);
                    listOfErrors.add(aErrLog);
                }
                
            }
            else
            {
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = mpmDetail.IntegrationID;
                aRespMsg.MPM_Number = mpmDetail.MPM_Number;
                aRespMsg.Message_Result = false;
                aRespMsg.Error_Message = 'Duplicate External Id : MPM Number!';
                responses.add(aRespMsg);
                
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (mpmDetail.IntegrationID, false, 'createMPMRd.mapDataValues', mpmDetail);
                listOfTransactions.add(aTLog);
                
                Error_Log__c aErrLog = new Error_log__c();
                aErrLog = createErrorLog (mpmDetail.IntegrationID, 'createMPMRd.mapDataValues', 'Duplicate External Id : MPM Number!', mpmDetail);
                listOfErrors.add(aErrLog);
            }
        }
        upsert MPMList MPM_Number__c;
        //End A
        
        for(MPM__c mpm : [select Id, MPM_Number__c from MPM__c where MPM_Number__c in :mpmNumberSet])
        {
            mpmIdMap.put(mpm.MPM_Number__c, mpm.Id);
        }

        for (MPMrdDetails mpmDetail : MPMinfo)
        {
            if(duplicateMpmNumberSet.contains(mpmDetail.MPM_Number) || mpmDetail.MPM_Number.trim().length() != 7 ) //If duplicate MPM Number Or Length != 7, skip processing releaseDetails
            {
                continue;
            }
        // To successfully process MPM records even if ReleaseDetail is not avialable
            if(mpmDetail.ReleaseDetailList != null && 
               mpmDetail.ReleaseDetailList[0].Country_2_Code != null && 
               mpmDetail.ReleaseDetailList[0].Theatrical_Release_Date != null &&
               mpmDetail.ReleaseDetailList[0].TV_Airing_Date != null
              )
            {
                for(ReleaseDetail rd : mpmDetail.ReleaseDetailList)
                {
                    System.debug('User Debug releaseDetails : ' + rd);
                    MPM_Release_Date__c mpmRd = new MPM_Release_Date__c();
                    mpmRd.MPM__c = mpmIdMap.get(mpmDetail.MPM_Number);
    
                    if (rd.Country_2_Code!=null && rd.Country_2_Code!='')
                    {
                        mpmRd.Key__c = mpmDetail.MPM_Number + '_' + rd.Country_2_Code;   
                        mpmRd.Country__c = countryMap.get(rd.Country_2_Code);
                    }      
                    mpmRd.Record_Status__c = mpmDetail.Record_Status;
                    mpmRd.MPM_status__c = mpmDetail.MPM_Status;
                    
                    if(mpmDetail.Record_Status == 'Inactive')
                    {
                        mpmRd.Theatrical_Release_Date__c = null;
                        mpmRd.TV_Airing_Date__c = null;
                    }  
                    else
                    {
                        mpmRd.Theatrical_Release_Date__c = (rd.Theatrical_Release_Date!=null && rd.Theatrical_Release_Date != '') ? date.valueOf(rd.Theatrical_Release_Date) : NULL;        //Modified for SINC0964682  
            
                        if (rd.TV_Airing_Date != null && rd.TV_Airing_Date != '')
                        {
                            mpmRd.TV_Airing_Date__c = date.valueOf(rd.TV_Airing_Date);
                        }
                    }
                    mpmRdDetailMap.put(mpmRd.Key__c, mpmDetail);
                    listOfMPMrds.add(mpmRd);
                }
            }
            else
            {
                ResponseMessage aRespMsg = new ResponseMessage();
                aRespMsg.IntegrationID = mpmDetail .IntegrationID;
                aRespMsg.MPM_Number = mpmDetail .MPM_Number;
                aRespMsg.Message_Result = true;
                // Log all records to transaction table
                Transaction_Log__c aTLog = new Transaction_log__c();
                aTLog = createTransactionLog (mpmDetail .IntegrationID, true, 'createMPMrd.mapDataValues', mpmDetail );

                responses.add(aRespMsg);
                listOfTransactions.add(aTLog);
            }
        }

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
    private static Transaction_Log__c createTransactionLog (String idoc, Boolean isSuccess, String methodName, MPMrdDetails MPMinfo)
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
        if (MPMinfo != null)
        {
            aLog.Input_Message__c = MPMinfo.toString();
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
    private static Error_Log__c createErrorLog (String idoc, String methodName, String errMessage, MPMrdDetails MPMinfo)
    {
        // Create new Transaction Log record for insert / return
        Error_Log__c aLog = new Error_Log__c (IDOC__c = idoc, Invoked_Method__c = methodName, Error_Message__c = errMessage);
            
        // Set String value
        if (MPMinfo != null)
        {
            aLog.Input_Message__c = MPMinfo.toString(); //MPMinfo;
        }

        // Return Transaction Log record created
        return aLog;
    }
}