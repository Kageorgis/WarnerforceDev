/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_MoveCountryPlanTargetsService
   @CreateDate 23 May 2016
   @Description This Serive class is responsible for all logic related to following functionality
                1. Automatic moving Country Plan Targets to appropriate GL Calendars whenever Product Street date Changes for both Physical and Digital
                2. Auto allocate Account Plan targets based on updated GL Calendar
   @Version <1.0>
   @reference Requirement no 185
*/
public with sharing class CRM_MoveCountryPlanTargetsService {

    /**
     * @Description - Method to process all Country Plan with NR Product records
     * @name processCountryPlanRecords
     * @param lstNRCountryPlan List of all NR Country Plan
     * @param setAllProcessedProductIds Set of Product Ids for which Country Plans are processed
     */
     // start WBTINC0118165  
    public Map<Date, GL_Calendar__c> mapStreetDateToGLCalendar = new Map<Date, GL_Calendar__c>();
   // end WBTINC0118165 
   public static List<CRM_MoveCountryPlanTargetsServiceException> processCountryPlanRecords(
            List<Country_Plan__c> lstNRCountryPlan,
            Set<Id> setAllProcessedProductIds
    ) {
        List<CRM_MoveCountryPlanTargetsServiceException> lstExceptions = new List<CRM_MoveCountryPlanTargetsServiceException>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Map<Integer, List<GL_Calendar__c>> mapDateToGLCalendarList = new Map<Integer, List<GL_Calendar__c>>();
        Map<String, GL_Calendar__c> mapDateToGLCalendarInstance = new Map<String, GL_Calendar__c>();
        Set<Integer> setProductStreetDateYear = new Set<Integer>();
        Map<Id, Country_Plan__c> mapCountryPlanIdToInstance = new Map<Id, Country_Plan__c>();
        Map<Id, List<Country_Plan_Target__c>> mapCountryPlanIdToTargets = new Map<Id, List<Country_Plan_Target__c>>();
        Map<Id, Integer> mapCPTargetIdToUpdatedDateDiffrence = new Map<Id, Integer>();
        List<Country_Plan__c> lstCountryPlanToAutoAllocate = new List<Country_Plan__c>();
    
      try {
            
            // Process all Country Plan records and decide which Country Plan Targets needs to be Updated
            for (Country_Plan__c countryPlanInstance : lstNRCountryPlan) {
                
                // Map required to fetch Country Plans from Country Plan Targets to AutoAllocate Account Plan Targets
                mapCountryPlanIdToInstance.put(countryPlanInstance.Id, countryPlanInstance);

                // Get all the Products for which Country Plans are being processed so that those Products can be updated to reset the Flag
                setAllProcessedProductIds.add(countryPlanInstance.NR_Product__c);

                // Get the Street Dates for which GL Calendar needs to be fetched
                setProductStreetDateYear.add(Integer.valueOf(countryPlanInstance.Street_Date__c.year()));
        // start WBTINC0118165 
        if(countryPlanInstance.Street_Date__c.month() == 12)
          setProductStreetDateYear.add(Integer.valueOf(countryPlanInstance.Street_Date__c.year() + 1));
        // end WBTINC0118165 
                Date previousDate;
                for (Integer i = 0; i < countryPlanInstance.Country_Plan_Targets__r.size() ; i ++) {
                    Country_Plan_Target__c cpt = countryPlanInstance.Country_Plan_Targets__r[i];

                    // Update GL Calendar only if the Street Date doesn't lies between first Target Start and End Dates. Targets Sorted By Start Date ASC
                    if (i == 0 && (!(countryPlanInstance.Street_date__c >= cpt.Start_date__c && countryPlanInstance.Street_Date__c <= cpt.End_Date__c)
                      || ((countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE || countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE) 
                        && countryPlanInstance.NR_Product__r.Local_Title__r.Country__r.Country_Code2__c == CRM_AppConstants.UK_COUNTRY_CODE))) {
          
                        mapCountryPlanIdToTargets.put(countryPlanInstance.Id, countryPlanInstance.Country_Plan_Targets__r);
                        previousDate = cpt.Start_date__c;

                    } else if (previousDate != null) {
                        Integer monthDiffrence = previousDate.monthsBetween(cpt.Start_date__c);
                        
                        // Set the Map with diffrences between month for all remaining Country Plan Targets in order to decide which
                        // GL Calendar needs to be updated for these Targets
                        mapCPTargetIdToUpdatedDateDiffrence.put(cpt.Id, monthDiffrence);
                        previousDate = cpt.Start_date__c;
                    } else {
                        break;
                    }
                }
            }
            
            // Fetch all existing GL Calendar records and prepare required Maps
            // start WBTINC0118165 
            Map<Date, GL_Calendar__c> mapStreetDateToGLCalendar = fetchGLCalendar(setProductStreetDateYear, mapDateToGLCalendarList, mapDateToGLCalendarInstance, lstNRCountryPlan);
      // end WBTINC0118165 
            // Set appropriate GL Calendar to update Country Plan Targets
            List<Country_Plan_Target__c> lstUpdateCountryPlanTarget =
                setGLCalendarOnCountryPlanTargets(
                    mapCountryPlanIdToInstance,
                    mapCountryPlanIdToTargets,
                    mapCPTargetIdToUpdatedDateDiffrence,
                    mapDateToGLCalendarList,
                    mapDateToGLCalendarInstance, // start WBTINC0118165 
                    mapStreetDateToGLCalendar  // start WBTINC0118165 
                );

            // Update Country Plan Targets with appropriate GL Calendar
            lstCountryPlanToAutoAllocate =
                updateCountryPlanTargets(lstUpdateCountryPlanTarget, listErrorLog, lstExceptions);

        } catch (Exception e) {

            // Save the error in database
            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
            errorLog.lineNumber = String.valueOf(e.getLineNumber());
            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_MOVE_GL_Calendar_ON_COUNTRY_PLAN;
            errorLog.errorMessage = e.getMessage().left(200);
            errorLog.stackTrace = e.getStackTraceString();
            listErrorLog.add(errorLog);

            // Adding Exception
            lstExceptions.add(
                new CRM_MoveCountryPlanTargetsServiceException(
                    null,
                    new List<String>{e.getMessage()}
                )
            );
        }

        // Auto allocate Account Plan Targets based on the updated Country Plan Targets
        autoAllocateAccountPlanTargets(lstCountryPlanToAutoAllocate, listErrorLog, lstExceptions);

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
        return lstExceptions;
    }

    /**
     * @Description - Method to fetch all existing GL Calendar records and prepare required Maps
     * @name fetchGLCalendar
     * @param setProductStreetDateYear Set of all Product Street Date Year for which Steert Date is changed
     * @param mapDateToGLCalendarList Map of Year to List of GL Calendar
     * @param mapDateToGLCalendarInstance Map of Unique Month and Year along with GL Calendar instance
     */
     // start WBTINC0118165 
    private static Map<Date, GL_Calendar__c> fetchGLCalendar(
            Set<Integer> setProductStreetDateYear,
            Map<Integer, List<GL_Calendar__c>> mapDateToGLCalendarList,
            Map<String, GL_Calendar__c> mapDateToGLCalendarInstance,
            List<Country_Plan__c> lstNRCountryPlan
    ) {
        Map<Date, GL_Calendar__c> mapStreetDateToGLCalendar = new Map<Date, GL_Calendar__c>();
        // end WBTINC0118165 
        // Fetch all GL Calendars
        List<GL_Calendar__c> calendarList = [
            SELECT
                Id, Name, Start_Date__c, End_Date__c, Type__c, Month__c, Year__c, Period__c, Quarter__c
            FROM GL_Calendar__c
            ORDER BY Start_Date__c, CreatedDate
            LIMIT 50000
        ];

        for (GL_Calendar__c gl : calendarList) {

            // Prepare a map with GL Calendar Year as its Key for Street Date that is changed along with List of related GL Calendars as its values
            // This is required because First updated Country Plan Target record Dates needs to be compared with GL Calendar Start and End Dates
            // to decide which is the appropriate GL Calendar for First Country Plan Target
            // Eg : Product Street Date : 2016-02-24 falls in 2016-02 GL Calender while 2016-02-25 falls in 2016-03 GL Calender

            if (gl.Year__c != null && setProductStreetDateYear.contains(Integer.valueOf(gl.Year__c))) {
                Integer key = Integer.valueOf(gl.Year__c);
                if (!mapDateToGLCalendarList.containsKey(key)) {
                    mapDateToGLCalendarList.put(key, new List<GL_Calendar__c> {gl});
                } else {
                    mapDateToGLCalendarList.get(key).add(gl);
                }
            }

            // Prepare a map with unique Key of GL Calendar along with its instance
            // This is required to get appropriate GL Calendar for Remaining Country Plan Target based on Year and Month
            // which is calculated by maintaining appropriate differences between Previous GL calendars
            if (gl.Year__c != null && gl.Month__c != null) {
                mapDateToGLCalendarInstance.put(Integer.valueOf(gl.Year__c) + '-' + Integer.valueOf(gl.Month__c), gl);
            }
      // start WBTINC0118165 
      for(Country_Plan__c countryPlanInstance : lstNRCountryPlan){
        if(countryPlanInstance.Street_Date__c >= gl.Start_Date__c && countryPlanInstance.Street_Date__c <= gl.End_Date__c){
          mapStreetDateToGLCalendar.put(countryPlanInstance.Street_Date__c, gl);
        }
      }
        }
        
        return mapStreetDateToGLCalendar;
        // end WBTINC0118165 
    }

    /**
     * @Description - Method to set appropriate GL Calendar for Country Plan Targets
     * @name setGLCalendarOnCountryPlanTargets
     * @param mapCountryPlanIdToInstance Map of Country Plan Id to Instance
     * @param mapCountryPlanIdToTargets Map of Country Plan Id to list of Country Plan Targets
     * @param mapCPTargetIdToUpdatedDateDiffrence Map of Country Plan Target along with its difference between previous GL Calendar
     * @param mapDateToGLCalendarList Map of Year to List of GL Calendar
     * @param mapDateToGLCalendarInstance Map of Unique Month and Year along with GL Calendar instance
     */
    private static List<Country_Plan_Target__c> setGLCalendarOnCountryPlanTargets(
            Map<Id, Country_Plan__c> mapCountryPlanIdToInstance,
            Map<Id, List<Country_Plan_Target__c>> mapCountryPlanIdToTargets,
            Map<Id, Integer> mapCPTargetIdToUpdatedDateDiffrence,
            Map<Integer, List<GL_Calendar__c>> mapDateToGLCalendarList,
            Map<String, GL_Calendar__c> mapDateToGLCalendarInstance, // start WBTINC0118165 
            Map<Date, GL_Calendar__c> mapStreetDateToGLCalendar // start WBTINC0118165 
    ) {
        List<Country_Plan_Target__c> lstUpdateCountryPlanTarget = new List<Country_Plan_Target__c>();
        for (Id countryPlanId : mapCountryPlanIdToTargets.keySet()) {
            Country_Plan__c countryPlanInstance = mapCountryPlanIdToInstance.get(countryPlanId);
            GL_Calendar__c previousCalendar;

            for (Integer i=0; i < mapCountryPlanIdToTargets.get(countryPlanId).size(); i++) {
                Country_Plan_Target__c countryPlanTargetInstance = mapCountryPlanIdToTargets.get(countryPlanId)[i];
                GL_Calendar__c calendarToUpdate;

                if (i == 0) {
                // start WBTINC0118165 
                    GL_Calendar__c glCalendarAsPerStreetDate = mapStreetDateToGLCalendar.get(countryPlanInstance.Street_date__c);
          Date dateToUpdate = countryPlanInstance.Street_date__c;
          
                    // Get all GL Calendars for the Year of updated Street Date
                    if(glCalendarAsPerStreetDate != null && mapDateToGLCalendarList.containsKey(Integer.valueOf(glCalendarAsPerStreetDate.Year__c))
                       && mapDateToGLCalendarList.get(Integer.valueOf(glCalendarAsPerStreetDate.Year__c)) != null) {
                        List<GL_Calendar__c> calendarList = mapDateToGLCalendarList.get(Integer.valueOf(glCalendarAsPerStreetDate.Year__c));
            // end WBTINC0118165 
                        // Process on the GL Calendar and fetch the the appropriate record
                        for (GL_Calendar__c calendarInstance : calendarList) {
                                //US: 997 - Start
                            if((countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE || countryPlanInstance.NR_Product__r.Type__c == CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE) 
                               && countryPlanInstance.NR_Product__r.Local_Title__r.Country__r.Country_Code2__c == CRM_AppConstants.UK_COUNTRY_CODE) {
                                    //Fetch the calendar one month prior
                if(mapDateToGLCalendarInstance.containsKey(String.valueOf(dateToUpdate.year()) + '-' + String.valueOf(dateToUpdate.month()))) {
                                        previousCalendar = calendarToUpdate = mapDateToGLCalendarInstance.get(String.valueOf(dateToUpdate.year()) + '-' + String.valueOf(dateToUpdate.month()));
                                    }
                                } //US: 997 - End
                            else if (calendarInstance.Start_date__c <= countryPlanInstance.Street_date__c && CalendarInstance.End_Date__c >= countryPlanInstance.Street_date__c) { // start WBTINC0118165 
                                  calendarToUpdate = calendarInstance;
                                  previousCalendar = calendarToUpdate;
                                  break;
                              }
                          }
                      }
                } else if (previousCalendar != null) {
                    if (mapCPTargetIdToUpdatedDateDiffrence.containsKey(countryPlanTargetInstance.Id)) {

                     Integer monthDiffrence = mapCPTargetIdToUpdatedDateDiffrence.get(countryPlanTargetInstance.Id);
                        Integer year = Integer.valueOf(previousCalendar.Year__c);
                        Integer month = Integer.valueOf(previousCalendar.Month__c);
                        //WBCTASK000092650 start for Duplicate External Id
                        if(monthDiffrence == 0 || monthDiffrence >= 2 ){//WBCTASK000139643 Issue with mapping of GL calendar to CPT where gap of current release date and new release date is greater than 2
                            monthDiffrence = 1; 
                        }
                        //WBCTASK000092650  end for Duplicate External Id
                        if (month != null && year != null && monthDiffrence != null) {
                            String monthYear = getYearAndMonth(month, year, monthDiffrence);
                            
                            if (mapDateToGLCalendarInstance.containsKey(monthYear)) {
                                calendarToUpdate = mapDateToGLCalendarInstance.get(monthYear);
                                previousCalendar = calendarToUpdate;
                            }
                        }
                    }
                }

                // Assign the approproate GL Calendar for Country Plan Target that needs to be updated
                if (calendarToUpdate != null) {
                    countryPlanTargetInstance.GL_Calendar__c = calendarToUpdate.Id;
                    lstUpdateCountryPlanTarget.add(countryPlanTargetInstance);
                }
            }
        }
        return lstUpdateCountryPlanTarget;
    }

    /**
     * @Description - Method to update Country Plan Targets and log errors
     * @name updateCountryPlanTargets
     * @param lstUpdateCountryPlanTarget List of Country plan Target that needs to be updated
     * @param listErrorLog List of Error Logs to be inserted into database which are generated while updating the Country Plan Records
     * @param lstExceptions List of Exception that needs to be mailed which are generated while updating the Country Plan Records
     * @return List<Country_Plan__c> Return List of Country Plans for which Account Plan Targets needs to be allocated
     */
    @TestVisible
    private static List<Country_Plan__c> updateCountryPlanTargets(
            List<Country_Plan_Target__c>  lstUpdateCountryPlanTarget,
            List<CRM_ErrorLogger.ErrorLog> listErrorLog,
            List<CRM_MoveCountryPlanTargetsServiceException> lstExceptions
    ) {
        List<Country_Plan__c> lstCountryPlanToAutoAllocate = new List<Country_Plan__c>();
        Set<Id> countryPlanIds = new Set<Id>();
        if (!lstUpdateCountryPlanTarget.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(lstUpdateCountryPlanTarget, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Country_Plan_Target__c countryPlansTargetInstance = lstUpdateCountryPlanTarget[i];
                if (countryPlansTargetInstance != null) {
                    if (saveResultInstance.isSuccess()) {
                        countryPlanIds.add(countryPlansTargetInstance.Country_Plan__c);
                    } else {
                        countryPlanIds.remove(countryPlansTargetInstance.Country_Plan__c);
                        // Log error
                        List<String> lstErrors = new List<String>();
                        for (Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = countryPlansTargetInstance.Country_Plan__r.NR_Product__c;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_MOVE_GL_Calendar_ON_COUNTRY_PLAN;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        lstExceptions.add(
                            new CRM_MoveCountryPlanTargetsServiceException(
                                countryPlansTargetInstance.Country_Plan__r.NR_Product__c,
                                lstErrors
                            )
                        );
                    }
                }
            }

            // Prepare Country Plan list to send for auto allocate only for successfully processed Country plan Targets
            // Need to query again as the Formula fields need to be populated with updated values
            if (countryPlanIds != null && countryPlanIds.size() > 0) {
                lstCountryPlanToAutoAllocate =
                    [
                        SELECT
                            Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
                            (
                                SELECT
                                    Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                                    GL_Calendar__r.Month__c, GL_Calendar__r.Year__c, Returns_Target__c, Billing_Adjustment_Target__c, Returns_Forecast__c, Billing_Adjustment_Forecast__c,Target_Quantity__c,Stretch_Target_Quantity__c
                                FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                            ),
                            (
                                SELECT 
                                    Id, RecordTypeId, Name, CurrencyISOCode, Share__c, Total_Target__c, Target_Quantity__c, Product_Group__c, Customer__c, Returns_Share__c, Billing_Adjustment_Share__c,Country_Plan__r.Id,Country_Plan__r.Name 
                                From Account_Plans__r
                            )
                        FROM Country_Plan__c
                        WHERE Id IN: countryPlanIds AND NR_Product__c != null
                    ];
            }
        }
        return lstCountryPlanToAutoAllocate;
    }

    /**
     * @Description - Method to allocate all Account Plan Targets based on updated Country Plan Targets
     * @name autoAllocateAccountPlanTargets
     * @param lstCountryPlanToAutoAllocate List of Country Plan records for which Country Plan Targets are successfully updated
     * @param listErrorLog List of Error Logs to be inserted into database which are generated while updating the Country Plan Records
     * @param lstExceptions List of Exception that needs to be mailed which are generated while updating the Country Plan Records
     */
    @TestVisible
    private static void autoAllocateAccountPlanTargets(
            List<Country_Plan__c> lstCountryPlanToAutoAllocate,
            List<CRM_ErrorLogger.ErrorLog> listErrorLog,
            List<CRM_MoveCountryPlanTargetsServiceException> lstExceptions
    ) {
        try {
            // Call Auto Allocate Account Plan Targets
            List<Target__c> accountPlanTargetList = new List<Target__c>();
            //US#962 - added a flag as false to skip to modify revenue and units on targets
            accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(lstCountryPlanToAutoAllocate,false);

            if (!accountPlanTargetList.isEmpty()) {
                // upsert accountPlanTargetList Unique_Key__c;
                Database.UpsertResult[] result = Database.Upsert(accountPlanTargetList, Target__c.Unique_Key__c, false);

                for (Integer i = 0; i < result.size(); i++) {
                    Database.UpsertResult resultInstance = result[i];
                    Target__c targetInstance = accountPlanTargetList[i];

                    if (!resultInstance.isSuccess()) {

                        // Add these errors in Error wrapper Class and prepare a list of same
                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        lstErrors.add(System.Label.CRM_Account_Plan_Target_Upsert_Failed_Msg);

                        for (Database.Error err : resultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database with Account Plan Id as when insert Target fails it will not have Id
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = targetInstance.Account_Plan_Lookup__c;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_MOVE_GL_Calendar_ON_COUNTRY_PLAN;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }

                        lstExceptions.add(
                            new CRM_MoveCountryPlanTargetsServiceException(
                                targetInstance.Product__c,
                                lstErrors
                            )
                        );
                    }
                }
            }
        } catch (Exception e) {

            List<String> lstErrors = new List<String>();
            lstErrors.add(System.Label.CRM_Account_Plan_Target_Upsert_Failed_Msg);
            lstErrors.add(e.getMessage());

            // Save the error in database
            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
            errorLog.lineNumber = String.valueOf(e.getLineNumber());
            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_MOVE_GL_Calendar_ON_COUNTRY_PLAN;
            errorLog.errorMessage = e.getMessage().left(200);
            errorLog.stackTrace = e.getStackTraceString();
            listErrorLog.add(errorLog);

            //Adding Exception
            lstExceptions.add(
                new CRM_MoveCountryPlanTargetsServiceException(
                    null,
                    lstErrors
                )
            );
        }
    }

    /**
     * @Description - Method to get appropriate year and month of GL Calendar to be updated
     * @name getYearAndMonth
     * @param month - Previous GL Calender Month
     * @param year - Previous GL Calender Year
     * @param monthDiffrence - Difference between previous GL Calendar months that needs to be added to get the new GL Calendar month and year
     * @return String - Return the updated year and month for which GL Calendar needs to be fetched
     */
    private static String getYearAndMonth(Integer month, Integer year, Integer monthDiffrence) {
        while(monthDiffrence > 0) {
            month++;
            monthDiffrence--;

            // Increase the Year and reset the month to start from new year once the month gets greater than 12
            if (month == 13) {
                year++;
                month = 1;
            }
        }
        return year + '-' + month;
    }

    /**
     * @Description - Class for Exception Handling
     * @name CRM_MoveCountryPlanTargetsServiceException
     */
    public class CRM_MoveCountryPlanTargetsServiceException extends Exception {
        public Id recordId;
        public List<String> lstErrors;
        public CRM_MoveCountryPlanTargetsServiceException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }
}