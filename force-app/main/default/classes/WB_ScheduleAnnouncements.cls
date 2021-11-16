global class WB_ScheduleAnnouncements implements schedulable{


global void execute(SchedulableContext sc){

 WB_CreateAnnouncements ca=new WB_CreateAnnouncements();
 ca.selectAnnouncementRecords();

}


}