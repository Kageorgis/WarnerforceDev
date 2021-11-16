@isTest(seeAllData=false)
private class WB_ScheduleAnnouncements_Test{
    
    // This class will be used to create Test Data and will be used by all Test methods created in this class.
    public static UtilityClass_Test  utilClass = new UtilityClass_Test();    
    
    testmethod  static void  testMethod1() 
    {
        list<Announcement_Rule__c> listAnnType;
        System.runAs(utilClass.getUserFromProfile('System Administrator')){        
          
            Account_Role__c aRole  = (Account_Role__c)utilClass.createTestRecord(utilClass.setUpData(new Account_Role__c(), 0));
           
            listAnnType = (list<Announcement_Rule__c>)utilClass.addMultiTestRecordsinList(new Announcement_Rule__c(), 6);
           
           
            listAnnType[1].Schedule_Type__c = 'Daily';
            listAnnType[1].Daily_Schedule_Days__c='All Days';
            listAnnType[1].Schedule_Time__c='10';   
            listAnnType[1].Active__c = true;
             listAnnType[1].Job_Processing_Status__c = 'Processing';
            
            
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
            Datetime scheduleDateTime = system.now()-1;
            listAnnType[1].Schedule_Date_And_Time__c=scheduleDateTime;
            listAnnType[2].Schedule_Date_And_Time__c=scheduleDateTime; 
            listAnnType[3].Schedule_Date_And_Time__c=scheduleDateTime;
            listAnnType[4].Schedule_Date_And_Time__c=scheduleDateTime;
            
            update listAnnType;
            
            Contact contactRec = new Contact();
            contactRec.lastname='Test';
            contactRec.Email = 'Test@gmail.com';
            insert contactRec;
      
            List<Announcement_Receipient__c> lstReceipient = new List<Announcement_Receipient__c>();
            lstReceipient.add(new Announcement_Receipient__c(Announcement_Type__c = listAnnType[0].Id,Contact__c = contactRec.Id,TO_CC_BCC__c = 'TO'));
            lstReceipient.add(new Announcement_Receipient__c(Announcement_Type__c = listAnnType[1].Id,Contact__c = contactRec.Id,TO_CC_BCC__c = 'TO'));
            lstReceipient.add(new Announcement_Receipient__c(Announcement_Type__c = listAnnType[2].Id,Contact__c = contactRec.Id,TO_CC_BCC__c = 'TO'));
            lstReceipient.add(new Announcement_Receipient__c(Announcement_Type__c = listAnnType[3].Id,Contact__c = contactRec.Id,TO_CC_BCC__c = 'TO'));
            lstReceipient.add(new Announcement_Receipient__c(Announcement_Type__c = listAnnType[4].Id,Contact__c = contactRec.Id,TO_CC_BCC__c = 'TO'));
            insert lstReceipient;
        }
        test.starttest();
        WB_ScheduleAnnouncements newSch = new WB_ScheduleAnnouncements();
        String newdate = system.now().second()+' '+system.now().minute()+' '+system.now().hour()+' * * ?';
        system.schedule('Test Announcement Scheduler Check', newdate , newSch);
        test.Stoptest();
    }
 }