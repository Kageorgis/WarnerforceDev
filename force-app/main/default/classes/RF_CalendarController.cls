public class RF_CalendarController {

    public static String getListIds() {
        String calendarIds ='';
        set<String> stdCalendars = new Set<String>();
        stdCalendars.add('TV - PST');
        stdCalendars.add('Catalog - PST');
        stdCalendars.add('SDS - PST');
        stdCalendars.add('Theatrical - PST');
        stdCalendars.add('Theatrical - EST');
        stdCalendars.add('SDS - EST');
        stdCalendars.add('Catalog - EST');
        stdCalendars.add('TV - EST');
        stdCalendars.add('Theatrical - VOD');
        stdCalendars.add('TV - VOD');
        stdCalendars.add('Catalog - VOD');
        stdCalendars.add('SDS - VOD');
        List<SLCA2__CA_Calendar__c> stdCalendarIds = [SELECT Id FROM SLCA2__CA_Calendar__c where Name IN :stdCalendars];
        for(SLCA2__CA_Calendar__c ca : stdCalendarIds){
            calendarIds = calendarIds + ca.Id + ',';
        }
        Set<String> grpCalendars = new Set<String>();
        grpCalendars.add('EST');
        grpCalendars.add('PST');
        grpCalendars.add('VOD');
        grpCalendars.add('Theatrical');
        grpCalendars.add('TV');
        grpCalendars.add('Catalog');
        grpCalendars.add('SDS');
        List<SLCA2__CA_Groups__c> grpCalendarIds = [SELECT Id FROM SLCA2__CA_Groups__c where Name IN :grpCalendars];
        if(grpCalendarIds.size()!=0){
            for(SLCA2__CA_Groups__c ca : grpCalendarIds){
                calendarIds = calendarIds + ca.Id + ',';
            }
        }
        Set<String> webCalendars = new Set<String>();
        webCalendars.add('Public Holiday');
        List<SLCA2__CA_WebCalendar__c> webCalendarIds = [SELECT Id FROM SLCA2__CA_WebCalendar__c where Name IN :webCalendars];
        if(webCalendarIds .size()!=0){
            for(SLCA2__CA_WebCalendar__c  ca : webCalendarIds ){
                calendarIds = calendarIds + ca.Id + ',';
            }
        }
        if(calendarIds.length()>1){
        calendarIds = calendarIds.substring(0, calendarIds.length()-1);
        }
        return calendarIds;
    }

}