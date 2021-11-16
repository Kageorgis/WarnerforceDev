@isTest
public class WB_Manage_ScheduleInfo_Controller_Test
{
    public static UtilityClass_Test  utilClass = new UtilityClass_Test();    
    public static testmethod void testMethod1()
    {
        System.runAs(utilClass.getUserFromProfile('System Administrator')){        
          
            Account_Role__c aRole  = (Account_Role__c)utilClass.createTestRecord(utilClass.setUpData(new Account_Role__c(), 0));
           
            list<Announcement_Rule__c> listAnnType = (list<Announcement_Rule__c>)utilClass.addMultiTestRecordsinList(new Announcement_Rule__c(), 6);
           
           
            listAnnType[1].Schedule_Type__c = 'Daily';
            listAnnType[1].Daily_Schedule_Days__c='All Days';
            listAnnType[1].Schedule_Time__c='10';   
            listAnnType[1].Active__c = true;
            
            listAnnType[2].Schedule_Type__c = 'Daily';
            listAnnType[2].Daily_Schedule_Days__c='Monday;Tuesday';
            listAnnType[2].Schedule_Time__c='15';   
            listAnnType[2].Active__c = true;
            
            listAnnType[3].Schedule_Type__c = 'Bi-Weekly';
            listAnnType[3].Weekly_Monthly_Schedule_Days__c='Monday';
            listAnnType[3].Schedule_Time__c='02';  
            listAnnType[3].Job_Processing_Status__c=null;
            listAnnType[3].Active__c = true;
            
            listAnnType[4].Schedule_Type__c = 'Monthly';
            listAnnType[4].Weekly_Monthly_Schedule_Days__c='25';
            listAnnType[4].Schedule_Time__c='08';  
            listAnnType[4].Job_Processing_Status__c=null;
            listAnnType[4].Active__c = true;
            
            listAnnType[5].Schedule_Type__c = 'Weekly';
            listAnnType[5].Weekly_Monthly_Schedule_Days__c='Monday';
            listAnnType[5].Schedule_Time__c='11';  
            listAnnType[5].Job_Processing_Status__c=null;
            listAnnType[5].Active__c = true;
            
            insert listAnnType;

            Test.startTest();
 
            PageReference pageRef = Page.WB_AnnouncementFormat;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', listAnnType[0].Id+','+listAnnType[1].id);
            List<Announcement_Rule__c> listAnnouncementTypes = new List<Announcement_Rule__c>();
            listAnnouncementTypes.add(listAnnType[0]);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listAnnouncementTypes);
            WB_Manage_ScheduleInfo_Controller controller = new WB_Manage_ScheduleInfo_Controller(sc);
            controller.UpdateRecords();
            controller.Cancel();
            ApexPages.currentPage().getParameters().put('id',null);
            ApexPages.currentPage().getParameters().put('param', 'AnnocementTypeListView');
            ApexPages.StandardSetController sc1 = new ApexPages.StandardSetController(listAnnouncementTypes);
            WB_Manage_ScheduleInfo_Controller controller1 = new WB_Manage_ScheduleInfo_Controller(sc1);
            controller1.UpdateRecords();
            controller1.Cancel();
            system.assertequals(controller.showTable,true);
        }
        Test.stopTest();
              
    }
}