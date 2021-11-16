/*
Class Name   : WB_Announcementype_Handler
Description  : This class is the Trigger Handler class for the Announcement Type object             
Created By   : Cognizant Technology Solutions - Shekhar Vinayak
Created On   : 10th Aug 2015

Change History:
--------------------------------------------------------------------------------------------------------------------------------------------------
Sr#             Description                                                 Updated By                                     Updated On
--------------------------------------------------------------------------------------------------------------------------------------------------
CH01     Added method validateAnnouncer() that validates                     Tushar Bhute                                    [8/11/2015]
       if a user scheduling announcement types to generate
       announcements is added to associated account with 
       announcer role.
CH02     Added logic which handles for Daily option while scheduling         Prachi Gadewar                                  [8/17/2015]
       the Announcement types.
*/

public class WB_Announcementype_Handler implements WB_iTrigger{
   
    Map<String,Integer> mapDays = new Map<String,Integer>(); // Map used to get number for specified day.
    
    List<Id> accIds = new List<Id>(); //List to hold accountIds of new or updated Announcement types
    List<Account_Role__c> accRoles; //List to hold Account roles for accounts associated with the announcement types in trigger 
    List<Announcement_Rule__c> annTypeList; //List to hold all new or updated announcement types from trigger
    //List<Announcement_Rule__c> annTypeList;
    Map<Id,String> authMap = new Map<Id,String>(); //Holds account Ids for accounts where current user is added as an announcer
    public static Set<String> finalMismatchColVals = new Set<String>();
    
     /////////////////////////////////BEFORE EVENT FUNCTIONS/////////////////////////////////////
    
    public void bulkBefore() {   
        // Prepare map values for days.  
        //CH01
        mapDays.put('Sunday',0);
        mapDays.put('Monday',1);
        mapDays.put('Tuesday',2);
        mapDays.put('Wednesday',3);
        mapDays.put('Thursday',4);
        mapDays.put('Friday',5);
        mapDays.put('Saturday',6);
   }
    
      
    public void beforeInsert(SObject so) {
       //CH01
        Announcement_Rule__c annType = (Announcement_Rule__c)so;
        if(annType.Active__c)
        {
            if(annType.Schedule_Type__c == 'Monthly')
                annType.Schedule_Date_And_Time__c = calculateDateForMonthly(Integer.valueof(annType.Weekly_Monthly_Schedule_Days__c),Integer.ValueOf(annType.Schedule_Time__c));
            else if(annType.Schedule_Type__c == 'Weekly' || annType.Schedule_Type__c == 'Monthly')
                annType.Schedule_Date_And_Time__c = calculateDateForWeekly(mapDays.get(annType.Weekly_Monthly_Schedule_Days__c),annType.Schedule_Time__c);
            else if(annType.Schedule_Type__c == 'Daily')
                annType.Schedule_Date_And_Time__c = calculateDateForDaily(annType.Daily_Schedule_Days__c,annType.Schedule_Time__c);
            annType.Processing_Time_Zone__c = UserInfo.getTimeZone().getID();
        }    
    }
    
    /**
    * beforeUpdate
    *
    * This method is called iteratively for each record to be updated during a BEFORE
    * trigger.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {
        // Get new and old announcement records.
        Announcement_Rule__c oldAnnType = (Announcement_Rule__c)oldSo;
        Announcement_Rule__c newAnnType = (Announcement_Rule__c)so;
        
        if(oldAnnType.Optional_Triggers__c != newAnnType.Optional_Triggers__c){
            system.debug(LoggingLevel.INFO,'Optional Trigger fields changed..');
            system.debug(LoggingLevel.INFO,'Report_Template__c:'+newAnnType.Report_Template__c);
            checkOptionalFieldsInReport(newAnnType);
        }
        
        
        // If any schedule related field updated then run the logic.
       //CH01 
        if(newAnnType.Active__c)
        {
            
            if(oldAnnType.Weekly_Monthly_Schedule_Days__c != newAnnType.Weekly_Monthly_Schedule_Days__c || 
               oldAnnType.Daily_Schedule_Days__c != newAnnType.Daily_Schedule_Days__c || 
               oldAnnType.Schedule_Type__c != newAnnType.Schedule_Type__c || 
               oldAnnType.Schedule_Time__c!= newAnnType.Schedule_Time__c ||
               oldAnnType.Active__c!= newAnnType.Active__c)
            {
                newAnnType.Processing_Time_Zone__c = UserInfo.getTimeZone().getID();
                // Execute logic if Schedule type monthly. Logic is seperated from weekly as input for Schedule Day is different for Weekely and monthly.
                if(newAnnType.Schedule_Type__c == 'Monthly')
                    newAnnType.Schedule_Date_And_Time__c = calculateDateForMonthly(Integer.valueof(newAnnType.Weekly_Monthly_Schedule_Days__c),Integer.ValueOf(newAnnType.Schedule_Time__c));
                // Else part covers for both Weekely and Bi-Weekely.    
                else if(newAnnType.Schedule_Type__c == 'Weekly' || newAnnType.Schedule_Type__c == 'Bi-Weekly')
                    newAnnType.Schedule_Date_And_Time__c = calculateDateForWeekly(mapDays.get(newAnnType.Weekly_Monthly_Schedule_Days__c),newAnnType.Schedule_Time__c);
                // CH02
                else if(newAnnType.Schedule_Type__c == 'Daily')
                    newAnnType.Schedule_Date_And_Time__c = calculateDateForDaily(newAnnType.Daily_Schedule_Days__c,newAnnType.Schedule_Time__c);
            }
        
            if(oldAnnType.Job_Processing_Status__c == 'Processing' && newAnnType.Job_Processing_Status__c == null)
            {
                if(newAnnType.Schedule_Type__c == 'Monthly')
                    newAnnType.Schedule_Date_And_Time__c = newAnnType.Schedule_Date_And_Time__c.addMonths(1);
                else if(newAnnType.Schedule_Type__c == 'Weekly')
                    newAnnType.Schedule_Date_And_Time__c = newAnnType.Schedule_Date_And_Time__c+7;
                else if(newAnnType.Schedule_Type__c == 'Bi-Weekly')
                    newAnnType.Schedule_Date_And_Time__c = newAnnType.Schedule_Date_And_Time__c+14;
                // CH02
                else if(newAnnType.Schedule_Type__c == 'Daily')
                    newAnnType.Schedule_Date_And_Time__c = calculateDateForDaily(newAnnType.Daily_Schedule_Days__c,''+oldAnnType.Schedule_Date_And_Time__c.hour());  //newAnnType.Schedule_Time__c // Issue Fixed
            }
        }
        else
        {
            newAnnType.Schedule_Date_And_Time__c = null;
        }
        
        //convert time zone to PST as per the users locale
        /*
        if(UserInfo.getTimeZone().getID() == 'Europe/Paris' || UserInfo.getTimeZone().getID() == 'Europe/Berlin' || UserInfo.getTimeZone().getID() == 'Europe/Rome'){
            system.debug('im adjusting time');
            //newAnnType.Schedule_Date_And_Time__c = (newAnnType.Schedule_Date_And_Time__c - (1/1.6));
            newAnnType.Schedule_Date_And_Time__c = newAnnType.Schedule_Date_And_Time__c.addhours(-15);
        } else if(UserInfo.getTimeZone().getID() == 'Asia/Tokyo' || UserInfo.getTimeZone().getID() == 'Asia/Seoul'){
            system.debug('im adjusting time');
            newAnnType.Schedule_Date_And_Time__c = (newAnnType.Schedule_Date_And_Time__c - (1/3000.0));
        } else if(UserInfo.getTimeZone().getID() == 'Europe/London'){
            system.debug('im adjusting time');
            newAnnType.Schedule_Date_And_Time__c = (newAnnType.Schedule_Date_And_Time__c.addhours(8));
        } else if(UserInfo.getTimeZone().getID() == 'America/Mexico_City'){
            system.debug('im adjusting time');
            newAnnType.Schedule_Date_And_Time__c = (newAnnType.Schedule_Date_And_Time__c.addhours(16));
        } */

    }
    
    public void beforeDelete(SObject oldso) { 
    
    }
   
   
   //////////////////////////////////// After Event function ////////////////////////////////////////
   
    public void bulkAfter() {
      //CH02
       annTypeList = [SELECT Id,Account__c,Account__r.Name,Active__c,Daily_Schedule_Days__c,Name,Schedule_Time__c,Schedule_Date_And_Time__c,Job_Processing_Status__c,Schedule_Type__c FROM Announcement_Rule__c WHERE Id =:trigger.new];
       
       for (Announcement_Rule__c a : annTypeList)
       {
           if(a.Active__c)
               accIds.add(a.Account__c);
       }
       accRoles = [SELECT id, Account__c, Role__c, User__c FROM Account_Role__c WHERE Account__c in: accIds AND Role__c includes ( 'Announcer' ) AND User__c = :Userinfo.getUserId() ];//
       for(Account_Role__c accRole : accRoles)
       {
           authMap.put(accRole.Account__c,'Yes');
       }
    }  
  
  
    public void afterInsert(SObject so) {
        //CH02
        Announcement_Rule__c annType = (Announcement_Rule__c)so;
        if(annType.Active__c)
        {
            validateAnnouncer(); //Validates if the user is added to associated account with announcer role
        }
    }
    
    public void afterUpdate(SObject oldso, SObject So ) {
         //CH02
         // Get new and old announcement records.
        Announcement_Rule__c oldAnnType = (Announcement_Rule__c)oldSo;
        Announcement_Rule__c newAnnType = (Announcement_Rule__c)so;
        
        // If any schedule related field updated then run the logic.
       //CH01 
        if(newAnnType.Active__c)
        {
            if(oldAnnType.Weekly_Monthly_Schedule_Days__c != newAnnType.Weekly_Monthly_Schedule_Days__c || 
               oldAnnType.Daily_Schedule_Days__c != newAnnType.Daily_Schedule_Days__c || 
               oldAnnType.Schedule_Type__c != newAnnType.Schedule_Type__c || 
               oldAnnType.Schedule_Time__c!= newAnnType.Schedule_Time__c ||
               oldAnnType.Active__c!= newAnnType.Active__c)
                validateAnnouncer(); //Validates if the user is added to associated account with announcer role
        }
    }
    
    public void afterDelete(SObject oldso) { 
    }
    
    //////////////////////////////// FINAL FUNCTION, DO MOST OF INSERT/UPDATE HERE ////////////////////////////////
    
    public void andFinally() { 
    
    }
    
    public static void checkOptionalFieldsInReport(Announcement_Rule__c annType){
        
        Set<String> reportTemplateFields = new Set<String>();
        Set<String> mismatchValSet = new Set<String>();
        List<Announcement_Trigger_Field__c> optionalTriggerFields = new List<Announcement_Trigger_Field__c>();
        Set<String> apiMatchingReportSet = new Set<String>();
        Map<String,String> apiMatchingReportMap = new Map<String,String>();
            
        
        //Get API Name of all fields from Ann.trigger Obj
        optionalTriggerFields = [SELECT Id,Name,Source_API__c,Destination_API__c,Report_API__c from Announcement_Trigger_Field__c];
        
        if(annType != null){
            //system.debug(LoggingLevel.INFO,'annType:'+annType);
            
            //Report Template fields from Announcement Type Object
            if(annType.Report_Template_fields__c != null){
                for(String val : annType.Report_Template_fields__c.split(',')){
                    val = val.trim();
                    reportTemplateFields.add(val);
                }
            }
            
            
            if(reportTemplateFields != null && reportTemplateFields.size()>0){
                //system.debug(LoggingLevel.INFO,'reportTemplateFields:'+reportTemplateFields);
                for(Announcement_Trigger_Field__c optionalFieldVal : optionalTriggerFields){
                    
                    if(reportTemplateFields.contains(optionalFieldVal.Source_API__c)){
                        //system.debug(LoggingLevel.INFO,'optionalFieldVal.Source_API__c:'+optionalFieldVal.Source_API__c);
                        if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                            apiMatchingReportMap.put(optionalFieldVal.Name,optionalFieldVal.Source_API__c);
                        }
                        //apiMatchingReportSet.add(optionalFieldVal.Source_API__c);
                    }else if(reportTemplateFields.contains(optionalFieldVal.Destination_API__c)){
                        //system.debug(LoggingLevel.INFO,'optionalFieldVal.Destination_API__c:'+optionalFieldVal.Destination_API__c);
                        if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                            apiMatchingReportMap.put(optionalFieldVal.Name,optionalFieldVal.Destination_API__c);
                        }
                       // apiMatchingReportSet.add(optionalFieldVal.Destination_API__c);
                    }else if(optionalFieldVal.Report_API__c != null  ){
                        if(optionalFieldVal.Report_API__c.contains(', ')){
                            for(String value : optionalFieldVal.Report_API__c.split(',')){
                                value = value.trim();
                                if(reportTemplateFields.contains(value)){
                                    if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                                        apiMatchingReportMap.put(optionalFieldVal.Name,value);
                                    }
                                }
                                
                            }    
                        }else if(!optionalFieldVal.Report_API__c.contains(', ')){
                            if(reportTemplateFields.contains(optionalFieldVal.Report_API__c)){
                                if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                                    apiMatchingReportMap.put(optionalFieldVal.Name,optionalFieldVal.Report_API__c);
                                }
                            }
                        }
                        
                    }
                }
            }
            
            if(apiMatchingReportMap != null && apiMatchingReportMap.size()>0){
            
                //system.debug(LoggingLevel.INFO,'apiMatchingReportMap:'+apiMatchingReportMap);
                if(annType.Optional_Triggers__c != null){
                    //system.debug(LoggingLevel.INFO,'annType.Optional_Triggers__c:'+annType.Optional_Triggers__c);
                    for(String value : annType.Optional_Triggers__c.split(';')){
                        value = value.trim();
                        //system.debug(LoggingLevel.INFO,'value:'+value);
                        Set<String> apiSet = new Set<String>();
                        apiSet = apiMatchingReportMap.keySet();
                       // system.debug(LoggingLevel.INFO,'apiSet:'+apiSet);
                        
                        if(!apiSet.contains(value)){
                            //system.debug('Mismatch');
                            //system.debug('Mismatch value:'+apiMatchingReportMap.get(value));
                            //mismatchValSet.add(apiMatchingReportMap.get(value));
                            mismatchValSet.add(value);
                        }
                       
                    }
                    
                }
            }
            
            if(mismatchValSet != null && mismatchValSet.size()>0){
                //system.debug('mismatchValSet:'+mismatchValSet);
                annType.addError('Announcement Trigger Field Not Present On Selected Report: '+mismatchValSet);
            }
        }
        //return false;
    }
    
    
    
   
   /*The below method use to display error msg to user if selected Report Template fields are not available in Announcement Trigger obj*/
   
   //Method added by Akash : Start
   /*public static Boolean checkReportTemplatefields(ID currAnnTypeId,String reportTemplateID){
       
       Set<String> reportTemplate = new Set<String>();
       List<String> uniqueColumnval = new List<String>();
       Set<String> FinalFilteredStr = new Set<String>();
       List<String> matchValList = new List<String>();
       //String s2 = ''; 
       String reportId = null;
       
       List<Announcement_Trigger_Field__c> allFields = new List<Announcement_Trigger_Field__c>();
       
       Announcement_Rule__c currRec = [SELECT Id,Name,Optional_Triggers__c,Report_Template__c from Announcement_Rule__c Where Id =: currAnnTypeId];
       System.debug('Current Ann Type--->> ' +currRec);
       reportTemplate.add(currRec.Report_Template__c);      //Get Report Template value present on Current Ann.Type record
       
       System.debug('Printing reportTemplate Name--->> ' +reportTemplate);
       
     
       
       //Newly Added
       Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportTemplateID);
       Reports.ReportMetadata reportMd = describe.getReportMetadata();
       Reports.ReportResults reportResults = Reports.ReportManager.runReport(reportTemplateID, reportMd,true);
       System.debug('ReportResults--->> ' +reportResults);
       //Newly Added
       
       //Get the report extended metadata
       Reports.ReportExtendedMetadata rmd =   reportResults.getReportExtendedMetadata();
       System.debug('Detail columns: ' + reportMd.getDetailColumns());
       uniqueColumnval.addAll(reportMd.getDetailColumns());
       System.debug('uniqueColumnval--->> ' +uniqueColumnval);
       
     
       //Get Report columns API Name values
       for(String s : uniqueColumnval){
           String s2 = '';
           s2 =  s.substringAfter('.');
           FinalFilteredStr.add(s2);
        }
       
        //Get matched API Name value from Ann.Trigger Obj by comparing Lable values
        if(currRec!= NULL){
            
            //Get Optional Trigger Field values
            String[] tmpString = currRec.Optional_Triggers__c.split(';');       //Spliting values by ;
            
            //Get API Name of all fields from Ann.trigger Obj
            allFields = [SELECT Id,Name,Source_API__c,Destination_API__c from Announcement_Trigger_Field__c];
            
            for(String s : tmpString){
                for(Announcement_Trigger_Field__c atf : allFields){
                    if(s==atf.Name){
                        //matchVal.put(s, atf.Destination_API__c);
                        matchValList.add(atf.Destination_API__c);
                    }
                }
            }
            
        }
        
        Set<String> fieldsNotPresentSet = new Set<String>();
        for(String objAPIVal : matchValList){
            Boolean result = FinalFilteredStr.contains(objAPIVal);
            if(!FinalFilteredStr.contains(objAPIVal)){
                fieldsNotPresentSet.add(objAPIVal);
            }
            if(result==false){
                finalMismatchColVals.add(objAPIVal);
            }
        }
        
        system.debug('fieldsNotPresentSet:'+fieldsNotPresentSet);
        //If Ann.Trigger obj field API name values does not match with Report Column's API Name values
        if(fieldsNotPresentSet!=NULL && fieldsNotPresentSet.size() >0){
            System.debug('Announcement Trigger Field Column Not Present On Report--->>'+fieldsNotPresentSet);
            return true;
        }
        
        return false;
   }*/
   //Method added by Akash : End
   
   
   ///////////////////////// Helper functions for events ////////////////////////////////////////
   
    // Method Accpet parameters next Schedule Day and time stored in record.

    public DateTime calculateDateForMonthly(Integer nextScheduleDay, Integer nextScheduleTime)
    {
        Integer nextRunMonth = system.today().month();
        Integer nextRunYear = system.today().year();
        if(system.today().day() > nextScheduleDay)
        {
            if(system.today().month() == 12) // Logic i
            {
                nextRunMonth = 1;
                nextRunYear++;
            }
            else
                nextRunMonth++;
        }
        DateTime nextRunDateTime = DateTime.newInstance(nextRunYear,nextRunMonth,nextScheduleDay,nextScheduleTime,0,0);
        return nextRunDateTime;
    }
    
    public Datetime calculateDateForWeekly(Integer nextRunDay, String nextRunTime)
    {
        system.debug('****system.debug(system.today().day())****'+system.today().day());
        system.debug('****System.today().toStartOfWeek().day())****'+system.today().toStartOfWeek().day());
        Integer currentDay = mapDays.get(DateTime.now().format('EEEE')); // Issue Fixed
        //Integer currentDay = system.today().day() - System.today().toStartOfWeek().day();
        system.debug('****currentDay****'+currentDay);
        Integer nextRunTimeInt = Integer.ValueOf(nextRunTime);
        system.debug('****nextRunTimeInt****'+nextRunTimeInt);
        Integer countAddDays = Math.MOD((7 - currentDay + nextRunDay),7);
        system.debug('****countAddDays****'+countAddDays);
        if(countAddDays == 0 && system.now().hour() > nextRunTimeInt)
            countAddDays += 7;                
        Date nextRunDate = system.today()+countAddDays;
        DateTime nextRunDateTime = DateTime.newInstance(nextRunDate.year(), nextRunDate.month(), nextRunDate.day(), nextRunTimeInt, 0, 0);
        system.debug(LoggingLevel.Info,'nextRunDateTime...'+nextRunDateTime);
        return nextRunDateTime;
    }
    // CH02 
    public DateTime calculateDateForDaily(String days,String nextRunTime)
    {
        Datetime nextRunDate;
        Integer smallNumber;
        Integer nextRunTimeInt = Integer.valueof(nextRunTime);
        List<String> splittedDays = days.split(';');
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=dt.format('EEEE');
        if(splittedDays.size() == 1 && splittedDays[0] == 'All Days')
        {
            if(system.now().hour() >= nextRunTimeInt)
                nextRunDate = System.now()+1;
            else
                nextRunDate = System.now();
        }
        else
        {
            Boolean sameDayFlag=false;
            Map<String,Integer> mapDaysAndNumber = returnMapOfDaysAndNumber(system.now().format('EEEE'));
            for(String day : splittedDays)
            {
                if(smallNumber == null && mapDaysAndNumber.get(dayOfWeek) != mapDaysAndNumber.get(day))
                    smallNumber = mapDaysAndNumber.get(day);
                if(mapDaysAndNumber.get(dayOfWeek) == mapDaysAndNumber.get(day))
                    sameDayFlag = true;
                else if(smallNumber != null && mapDaysAndNumber.get(day) < smallNumber)
                    smallNumber = mapDaysAndNumber.get(day);
            } 
            if(sameDayFlag && system.now().hour() >= Integer.valueOf(nextRunTime) && smallNumber == null)
                smallNumber = 7;
            else if(sameDayFlag && system.now().hour() < Integer.valueOf(nextRunTime))
                smallNumber = 0;
            System.debug('***smallNumber : '+smallNumber);
            nextRunDate = System.now()+smallNumber;
        }
        DateTime nextRunDateTime = DateTime.newInstance(nextRunDate.year(), nextRunDate.month(), nextRunDate.day(), Integer.valueOf(nextRunTime), 0, 0);
        return nextRunDateTime;
    }
    //CH02
    Public void validateAnnouncer()
    {
        For(Announcement_Rule__c annRule: annTypeList)
        {  
            system.debug('*******authMap : '+authMap);
            if(annRule.Active__c && authMap.get(annRule.Account__c) != 'Yes'){
                Announcement_Rule__c a = (Announcement_Rule__c)trigger.newMap.get(annRule.Id);
                a.addError('You are not added as an announcer on account '+annRule.Account__r.Name+' '+'Hence you are unauthorized to generate announcement for announcement type '+a.Name+'.');
            }
        }
    
        
    }
   //CH01  
    public Map<String,Integer> returnMapOfDaysAndNumber(String dayOfWeek)
    {
        Map<string,Integer> mpDaytoNumber = new Map<string,Integer>() ; 
        if(dayOfWeek == 'Sunday')
        {
          mpDaytoNumber.put('Monday', 1);
          mpDaytoNumber.put('Tuesday', 2);
          mpDaytoNumber.put('Wednesday', 3);
          mpDaytoNumber.put('Thursday', 4);
          mpDaytoNumber.put('Friday', 5);
          mpDaytoNumber.put('Saturday', 6);
          mpDaytoNumber.put('Sunday', 0);
        }
        else if(dayOfWeek == 'Monday')
        {
          mpDaytoNumber.put('Monday', 0);
          mpDaytoNumber.put('Tuesday', 1);
          mpDaytoNumber.put('Wednesday', 2);
          mpDaytoNumber.put('Thursday', 3);
          mpDaytoNumber.put('Friday', 4);
          mpDaytoNumber.put('Saturday', 5);
          mpDaytoNumber.put('Sunday', 6);
        }
        else if(dayOfWeek == 'Tuesday')
        {
          mpDaytoNumber.put('Monday', 6);
          mpDaytoNumber.put('Tuesday', 0);
          mpDaytoNumber.put('Wednesday', 1);
          mpDaytoNumber.put('Thursday', 2);
          mpDaytoNumber.put('Friday', 3);
          mpDaytoNumber.put('Saturday', 4);
          mpDaytoNumber.put('Sunday', 5);
         
        }
         
        else if(dayOfWeek == 'Wednesday')
        {
          mpDaytoNumber.put('Monday', 5);
          mpDaytoNumber.put('Tuesday', 6);
          mpDaytoNumber.put('Wednesday', 0);
          mpDaytoNumber.put('Thursday', 1);
          mpDaytoNumber.put('Friday', 2);
          mpDaytoNumber.put('Saturday', 3);
          mpDaytoNumber.put('Sunday', 4);
         
        }
        else if(dayOfWeek == 'Thursday')
        {
          mpDaytoNumber.put('Monday',4 );
          mpDaytoNumber.put('Tuesday', 5);
          mpDaytoNumber.put('Wednesday', 6);
          mpDaytoNumber.put('Thursday', 0);
          mpDaytoNumber.put('Friday', 1);
          mpDaytoNumber.put('Saturday', 2);
          mpDaytoNumber.put('Sunday', 3);
        }
        else if(dayOfWeek == 'Friday')
        {
          mpDaytoNumber.put('Monday', 3);
          mpDaytoNumber.put('Tuesday', 4);
          mpDaytoNumber.put('Wednesday', 5);
          mpDaytoNumber.put('Thursday', 6);
          mpDaytoNumber.put('Friday', 0);
          mpDaytoNumber.put('Saturday', 1);
          mpDaytoNumber.put('Sunday', 2);
        }
        else if(dayOfWeek == 'Saturday')
        {
          mpDaytoNumber.put('Monday', 2);
          mpDaytoNumber.put('Tuesday', 3);
          mpDaytoNumber.put('Wednesday', 4);
          mpDaytoNumber.put('Thursday', 5);
          mpDaytoNumber.put('Friday', 6);
          mpDaytoNumber.put('Saturday', 0);
          mpDaytoNumber.put('Sunday', 1);
        }
        return mpDaytoNumber;
        
    }
}