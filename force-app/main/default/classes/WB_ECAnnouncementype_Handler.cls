public class WB_ECAnnouncementype_Handler implements WB_ITrigger{
    
    Map<String,Integer> mapDays = new Map<String,Integer>(); // Map used to get number for specified day.
    List<Id> accIds = new List<Id>(); //List to hold accountIds of new or updated Announcement types
    List<Account_Role__c> accRoles; //List to hold Account roles for accounts associated with the announcement types in trigger 
    List<Announcement_Rule__c> annTypeList; //List to hold all new or updated announcement types from trigger
    //List<Announcement_Rule__c> annTypeList;
    Map<Id,String> authMap = new Map<Id,String>(); //Holds account Ids for accounts where current user is added as an announcer
    WB_Announcementype_Handler wb = new WB_Announcementype_Handler();
    WB_CreateECAnnouncements_CC wcreateAnn = new WB_CreateECAnnouncements_CC();
    
    public void bulkBefore(){
        
        mapDays.put('Sunday',0);
        mapDays.put('Monday',1);
        mapDays.put('Tuesday',2);
        mapDays.put('Wednesday',3);
        mapDays.put('Thursday',4);
        mapDays.put('Friday',5);
        mapDays.put('Saturday',6);
    }
    
    public void bulkAfter() {
    }
    
    public void beforeInsert(SObject so) {
        
        EC_AnnouncementType__c ecAnnType = (EC_AnnouncementType__c)so;
        if(ecAnnType.Active__c)
        {
            if(ecAnnType.EC_Schedule_Type__c == 'Monthly')
                ecAnnType.EC_Schedule_Date_And_Time__c = wb.calculateDateForMonthly(Integer.valueof(ecAnnType.EC_Weekly_Monthly_Schedule_Days__c),Integer.ValueOf(ecAnnType.EC_Schedule_Time__c));
            else if(ecAnnType.EC_Schedule_Type__c == 'Weekly' || ecAnnType.EC_Schedule_Type__c == 'Monthly')
                ecAnnType.EC_Schedule_Date_And_Time__c = wcreateAnn.calculateDateForWeekly(mapDays.get(ecAnnType.EC_Weekly_Monthly_Schedule_Days__c),ecAnnType.EC_Schedule_Time__c,mapDays);
            else if(ecAnnType.EC_Schedule_Type__c == 'Daily')
                ecAnnType.EC_Schedule_Date_And_Time__c = wb.calculateDateForDaily(ecAnnType.EC_Daily_Schedule_Days__c,ecAnnType.EC_Schedule_Time__c);
            ecAnnType.EC_Processing_Time_Zone__c = UserInfo.getTimeZone().getID();
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
        // Get new and old announcement records.
        EC_AnnouncementType__c oldECAnnType = (EC_AnnouncementType__c)oldSo;
        EC_AnnouncementType__c newECAnnType = (EC_AnnouncementType__c)so;
        
        // If any schedule related field updated then run the logic.
       //CH01 
        if(newECAnnType.Active__c)
        {
            
            if(oldECAnnType.EC_Weekly_Monthly_Schedule_Days__c != newECAnnType.EC_Weekly_Monthly_Schedule_Days__c || 
               oldECAnnType.EC_Daily_Schedule_Days__c != newECAnnType.EC_Daily_Schedule_Days__c || 
               oldECAnnType.EC_Schedule_Type__c != newECAnnType.EC_Schedule_Type__c || 
               oldECAnnType.EC_Schedule_Time__c!= newECAnnType.EC_Schedule_Time__c ||
               oldECAnnType.Active__c!= newECAnnType.Active__c)
            {
                newECAnnType.EC_Processing_Time_Zone__c = UserInfo.getTimeZone().getID();
                // Execute logic if Schedule type monthly. Logic is seperated from weekly as input for Schedule Day is different for Weekely and monthly.
                if(newECAnnType.EC_Schedule_Type__c == 'Monthly')
                    newECAnnType.EC_Schedule_Date_And_Time__c = wb.calculateDateForMonthly(Integer.valueof(newECAnnType.EC_Weekly_Monthly_Schedule_Days__c),Integer.ValueOf(newECAnnType.EC_Schedule_Time__c));
                // Else part covers for both Weekely and Bi-Weekely.    
                else if(newECAnnType.EC_Schedule_Type__c == 'Weekly' || newECAnnType.EC_Schedule_Type__c == 'Bi-Weekly')
                    newECAnnType.EC_Schedule_Date_And_Time__c = wcreateAnn.calculateDateForWeekly(mapDays.get(newECAnnType.EC_Weekly_Monthly_Schedule_Days__c),newECAnnType.EC_Schedule_Time__c,mapDays);
                // CH02
                else if(newECAnnType.EC_Schedule_Type__c == 'Daily')
                    newECAnnType.EC_Schedule_Date_And_Time__c = wb.calculateDateForDaily(newECAnnType.EC_Daily_Schedule_Days__c,newECAnnType.EC_Schedule_Time__c);
            }
        
            if(oldECAnnType.Job_Processing_Status__c == 'Processing' && newECAnnType.Job_Processing_Status__c == null)
            {
                if(newECAnnType.EC_Schedule_Type__c == 'Monthly')
                    newECAnnType.EC_Schedule_Date_And_Time__c = newECAnnType.EC_Schedule_Date_And_Time__c.addMonths(1);
                else if(newECAnnType.EC_Schedule_Type__c == 'Weekly')
                    newECAnnType.EC_Schedule_Date_And_Time__c = newECAnnType.EC_Schedule_Date_And_Time__c+7;
                else if(newECAnnType.EC_Schedule_Type__c == 'Bi-Weekly')
                    newECAnnType.EC_Schedule_Date_And_Time__c = newECAnnType.EC_Schedule_Date_And_Time__c+14;
                // CH02
                else if(newECAnnType.EC_Schedule_Type__c == 'Daily')
                    newECAnnType.EC_Schedule_Date_And_Time__c = wb.calculateDateForDaily(newECAnnType.EC_Daily_Schedule_Days__c,''+oldECAnnType.EC_Schedule_Date_And_Time__c.hour());  //newECAnnType.EC_Schedule_Time__c // Issue Fixed
            }
        }
        else
        {
            newECAnnType.EC_Schedule_Date_And_Time__c = null;
        }
    }
    
    public void beforeDelete(SObject oldso) { 
    
    }
    
    public void afterInsert(SObject so) {
    }
    
    public void afterUpdate(SObject oldso, SObject So ) {
    }
    
    public void afterDelete(SObject oldso) { 
    }
    
    public static void checkOptionalFieldsInReport(Announcement_Rule__c annType){
    }
    
    public void andFinally() { 
    
    }
}