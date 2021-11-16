/*
Class Name   : WB_CreateECAnnouncements_CC_Test 
Description  : This class is to do code coverage for WB_CreateECAnnouncements_CC class    
Created By   : Cognizant Technology Solutions - Akash
Created On   : MAY 2016

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

*/
 
@isTest
public class  WB_CreateECAnnouncements_CC_Test {
    
     static testMethod void CreateECAnnouncment_Test(){
         
         List<EC_AnnouncementType__c> ecAnnTypeList = new List<EC_AnnouncementType__c>();
          EC_AnnouncementType__c ecAnnTypeRec = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                            EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                            ECAnnouncement_Type__c = 'EST EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                            Report_Template__c = '00OU0000003gYlQ');
            ecAnnTypeList.add(ecAnnTypeRec);
            
            EC_AnnouncementType__c ecAnnTypeRec1 = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                            EC_Schedule_Type__c = 'Weekly',EC_Weekly_Monthly_Schedule_Days__c='Monday',EC_Schedule_Time__c='10',
                                            ECAnnouncement_Type__c = 'VODi EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                            Report_Template__c = '00OU0000003gYlQ');
            ecAnnTypeList.add(ecAnnTypeRec1);
            
            EC_AnnouncementType__c ecAnnTypeRec2 = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                            EC_Schedule_Type__c = 'Monthly',EC_Weekly_Monthly_Schedule_Days__c='25',EC_Schedule_Time__c='10',
                                            ECAnnouncement_Type__c = 'Hotel EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                            Report_Template__c = '00OU0000003gYlQ');
            ecAnnTypeList.add(ecAnnTypeRec2);
            
             insert ecAnnTypeList ; 
         Test.startTest();
             Integer DaysDiff;
             DaysDiff = ecAnnTypeList[0].Date_Last_Run__c.Date().daysBetween(Date.today());
             WB_CreateECAnnouncements_CC controller = new WB_CreateECAnnouncements_CC();
             controller.WB_CreateECAnnouncements_CC();
             controller.selectAnnouncementType();
             controller.CreateECAnnouncment(ecAnnTypeList);
         Test.stopTest();
     }
     
     // This testMethod will throw an error because of wrong data in field,wil be used to test exception condition
    static testMethod void CreateECAnnouncment_Test2(){
           
         
            EC_AnnouncementType__c ECAnnType = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                                   EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='Monday;Tuesday',EC_Schedule_Time__c='15',
                                                   ECAnnouncement_Type__c = 'EST EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                                   Report_Template__c = '00OU0000003gYlQ');
            insert ECAnnType ;
            EC_Announcment__c ECAnn = new EC_Announcment__c (Announcement_Name__c ='new ann', 
                                                            Chatter_Group_ID__c = '1223',
                                                            Report_Name__c='0F921000000CbCJ',ECAnnouncement_Type__c = '0F921000000CbCJ' );
            List<EC_Announcment__c> ECAnnList = new list<EC_Announcment__c>();
            List<EC_AnnouncementType__c > lstECAnnType = new list<EC_AnnouncementType__c >();
            ECAnnList.add(ECAnn);
            lstECAnnType.add(ECAnnType);
           
             
         Test.startTest();
            Integer DaysDiff;
             //DaysDiff = ECAnnType.Date_Last_Run__c.Date().daysBetween(Date.today());
            WB_CreateECAnnouncements_CC controller = new WB_CreateECAnnouncements_CC();
            controller.saveAnnouncment(ECAnnList,lstECAnnType);
            System.assertEquals(null, ECAnn.Id);
         Test.stopTest();
     }
     
     static testMethod void ECAnnouncmentUpdate_Test(){
         
         List<EC_AnnouncementType__c> ecAnnTypeList = new List<EC_AnnouncementType__c>();
          EC_AnnouncementType__c ecAnnTypeRec = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                            EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                            ECAnnouncement_Type__c = 'EST EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                            Job_Processing_Status__c = 'Processing',
                                            Report_Template__c = '00OU0000003gYlQ');
            ecAnnTypeList.add(ecAnnTypeRec);
            
            EC_AnnouncementType__c ecAnnTypeRec1 = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                            EC_Schedule_Type__c = 'Weekly',EC_Weekly_Monthly_Schedule_Days__c='Monday',EC_Schedule_Time__c='10',
                                            ECAnnouncement_Type__c = 'VODi EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                            Job_Processing_Status__c = 'Processing',
                                            Report_Template__c = '00OU0000003gYlQ');
            ecAnnTypeList.add(ecAnnTypeRec1);
            
            EC_AnnouncementType__c ecAnnTypeRec2 = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = '0F921000000CbCJ',Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                            EC_Schedule_Type__c = 'Monthly',EC_Weekly_Monthly_Schedule_Days__c='25',EC_Schedule_Time__c='10',
                                            ECAnnouncement_Type__c = 'Hotel EC Tracker - TV',Release_Type__c = 'TNR',Selection_Criteria__c = 'Full',
                                            Job_Processing_Status__c = 'Processing',
                                            Report_Template__c = '00OU0000003gYlQ');
            ecAnnTypeList.add(ecAnnTypeRec2);
            
             insert ecAnnTypeList ; 
         Test.startTest();
            ecAnnTypeList[0].EC_Schedule_Type__c = 'Weekly';
            ecAnnTypeList[0].EC_Weekly_Monthly_Schedule_Days__c='Monday';
            ecAnnTypeList[0].EC_Schedule_Time__c='10';
            ecAnnTypeList[0].Job_Processing_Status__c =Null;
            
            ecAnnTypeList[1].EC_Schedule_Type__c = 'Monthly';
            ecAnnTypeList[1].EC_Weekly_Monthly_Schedule_Days__c='25';
            ecAnnTypeList[1].EC_Schedule_Time__c='10';
            ecAnnTypeList[1].Job_Processing_Status__c =Null;
            
            ecAnnTypeList[2].EC_Schedule_Type__c = 'Daily';
            ecAnnTypeList[2].EC_Daily_Schedule_Days__c='All Days';
            ecAnnTypeList[2].EC_Schedule_Time__c='10';
            ecAnnTypeList[2].Job_Processing_Status__c =Null;
            
            
            update ecAnnTypeList;
           //  Integer DaysDiff;
            // DaysDiff = ecAnnTypeList[0].Date_Last_Run__c.Date().daysBetween(Date.today());
             WB_CreateECAnnouncements_CC controller = new WB_CreateECAnnouncements_CC();
             controller.WB_CreateECAnnouncements_CC();
             controller.selectAnnouncementType();
             controller.CreateECAnnouncment(ecAnnTypeList);
         Test.stopTest();
     }
}