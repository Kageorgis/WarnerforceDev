/*
Class Name   : WB_Announcementype_Handler_Test
Description  :  Test Class for Trigger on Announcement_Rule__c object             
Created By   : Cognizant Technology Solutions - Prachi/Shekhar
Created On   : 17th Aug 2015

Change History:
--------------------------------------------------------------------------------------------------------------------------------------------------
Sr#             Description                                                 Updated By                                     Updated On
--------------------------------------------------------------------------------------------------------------------------------------------------
*/


@isTest(seeAllData=false)
private class WB_Announcementype_Handler_Test{
      
    // This class will be used to create Test Data and will be used by all Test methods created in this class.
    public static UtilityClass_Test  utilClass = new UtilityClass_Test();    
    
    testmethod static void TestingReturnMapMethodInClass() 
    {
        test.starttest();
        WB_Announcementype_Handler announceHandler = new WB_Announcementype_Handler();
        Map<string,Integer> mpDaytoNumber = new Map<string,Integer>() ; 
        
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Sunday');
        system.assertEquals(mpDaytoNumber.get('Monday'), 1);
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Monday');
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Tuesday'); 
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Wednesday'); 
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Thursday'); 
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Friday'); 
        system.assertEquals(mpDaytoNumber.get('Monday'), 3);
        mpDaytoNumber = announceHandler.returnMapOfDaysAndNumber('Saturday'); 
        test.stoptest();

    }
    
     testmethod  static void  TestingAnnouncementTypeInsertion() 
    {
     
      test.starttest();
        System.runAs(utilClass.getUserFromProfile('System Administrator')){        
          
            Account_Role__c aRole  = (Account_Role__c)utilClass.createTestRecord(utilClass.setUpData(new Account_Role__c(), 0));
           
            list<Announcement_Rule__c> listAnnType = (list<Announcement_Rule__c>)utilClass.addMultiTestRecordsinList(new Announcement_Rule__c(), 6);
           
           
            listAnnType[1].Schedule_Type__c = 'Daily';
            listAnnType[1].Daily_Schedule_Days__c='All Days';
            listAnnType[1].Schedule_Time__c='10';   
            listAnnType[1].Job_Processing_Status__c='Processing';
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
            
            list<Announcement_Rule__c> annlistNew =  [select Schedule_Date_And_Time__c, Schedule_Time__c from Announcement_Rule__c where Id = : listAnnType]; 
            if(annlistNew.size() > 0 ) 
            { 
                For( Announcement_Rule__c an : annlistNew)
                {
                    system.debug('system.now().hour()=' + system.now().hour());
                    if(an.Schedule_Time__c == '10')
                        if(system.now().hour() >= 10) 
                            system.assertEquals( datetime.newinstance(Date.today()+1, Time.newInstance(10, 0, 0, 0)),an.Schedule_Date_And_Time__c);
                        else 
                            system.assertEquals( datetime.newinstance(Date.today(), Time.newInstance(10, 0, 0, 0)),an.Schedule_Date_And_Time__c);
                }
            }
        
            listAnnType[1].Job_Processing_Status__c=null;
            listAnnType[2].Schedule_Time__c='20'; 
            listAnnType[3].Schedule_Type__c='Monthly';
            listAnnType[4].Schedule_Type__c='Weekly';
            
            update listAnnType;
         }
         test.stoptest();
        
        
    }
    
    
}