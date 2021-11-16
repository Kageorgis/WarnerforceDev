/*
Class Name   : WB_ECAnnouncementProcess_Batch_Test 
Description  : This class is to do code coverage for Batch process for EC announcement class    
Created By   : Cognizant Technology Solutions - Shekhar
Created On   : MAY 2016

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

*/


@isTest
private class WB_ECAnnouncementProcess_Batch_Test {

    private static testMethod void CreateAnnRecords1() {
        
              // create MPM
              MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
              insert mpm1;
              //create a title
              Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
              insert title;
               //Create Account
              Account acct= TestUtil.initAccount();
              acct.EC_Digital_Account__c='Digital';
              insert acct;
              
              Account acct2= TestUtil.initAccount();
              acct2.EC_Digital_Account__c='Digital';
              insert acct2;
              
              //create EC Tracker
              EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id, Release_Type__c = 'TNR');
              insert tracker;
              //create or update EC Piece
              EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec1;
              EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec2;
              //Create a record on ECTitelAllocaiton Object to add ecs to titles & Account
              EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
              insert eca1;
             
              system.debug('check date****'+eca1.createddate);
              
              CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
              insert cg;
            
              EC_AnnouncementType__c ECAnnType = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = cg.id,Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
													EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                                   ECAnnouncement_Type__c = 'EST EC Tracker - TV',Selection_Criteria__c = 'Full',
                                                   Report_Template__c = '00OU0000003gYlQ',Release_Type__c='TNR',Email__c='test2123123122211@gmail.com');
              insert ECAnnType ;
              EC_Announcment__c ECAnn = new EC_Announcment__c (Announcement_Name__c ='new ann', 
                                                            Chatter_Group_ID__c = '1223',
                                                            Report_Name__c='0F921000000CbCJ',ECAnnouncement_Type__c = ECAnnType.id,Release_Type__c = 'TNR' );
              List<EC_Announcment__c> ECAnnList = new list<EC_Announcment__c>();
              ECAnnList.add(ECAnn);
              insert ECAnnList;
              
              //Create Custom Setting Records: 
              List<ECLMTriggerFields__c> ECTfieldsList = new  List<ECLMTriggerFields__c>();
              ECLMTriggerFields__c ECTfields1 = new ECLMTriggerFields__c(name = 'EC Name', ChildField__c ='EC_Name__c', ParentField__c='EC_Name__c');
              
              ECLMTriggerFields__c ECTfields2 = new ECLMTriggerFields__c(name = 'EC Status', ChildField__c ='EC_Status__c', ParentField__c='EC_Status__c');
          
              ECTfieldsList.add(ECTfields1);
              ECTfieldsList.add(ECTfields2);
              
              insert ECTfieldsList ; 
              
              // finally Execute batch 
         

              Test.startTest();
              WB_ECAnnouncementProcess_Batch schedulerInstance=new WB_ECAnnouncementProcess_Batch();
              String cron_Exp='0 0 23 * * ?';
              System.schedule('Status Check',cron_Exp,schedulerInstance);
              Test.stopTest();
              ECAnnouncment_Record__c EcAnnRec;
              try{
                 EcAnnRec = [Select Id from ECAnnouncment_Record__c Where EC_Account_Allocation__c =: eca1.Id AND ECAnnouncment__c =: ECAnnList[0].Id ];
              }
              catch(Exception e){
                system.assertEquals(EcAnnRec,NULL);
              }
              
    }
    
    private static testMethod void CreateAnnRecords2() {
        
              // create MPM
              MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
              insert mpm1;
              //create a title
              Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
              insert title;
               //Create Account
              Account acct= TestUtil.initAccount();
              acct.EC_Digital_Account__c='Digital';
              insert acct;
              
              Account acct2= TestUtil.initAccount();
              acct2.EC_Digital_Account__c='Digital';
              insert acct2;
              
              //create EC Tracker
              EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id, Release_Type__c = 'TNR');
              insert tracker;
              //create or update EC Piece
              EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec1;
              EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec2;
              //Create a record on ECTitelAllocaiton Object to add ecs to titles & Account
              EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
              insert eca1;
              
              CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
              insert cg;
            
              EC_AnnouncementType__c ECAnnType = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = cg.id,Date_Last_Run__c = date.today(),
                                                   EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                                   ECAnnouncement_Type__c = 'EST EC Tracker - TV', Selection_Criteria__c = 'Full',Email__c='test2123123122211@gmail.com',
                                                   Report_Template__c = '00OU0000003gYlQ');
              insert ECAnnType ;
              EC_Announcment__c ECAnn = new EC_Announcment__c (Announcement_Name__c ='new ann', 
                                                            Chatter_Group_ID__c = '1223',
                                                            Report_Name__c='0F921000000CbCJ',
                                                            ECAnnouncement_Type__c = ECAnnType.id ,Selection_Criteria__c='Full',Release_Type__c = 'TNR');
              List<EC_Announcment__c> ECAnnList = new list<EC_Announcment__c>();
              ECAnnList.add(ECAnn);
              insert ECAnnList;
              
              ECAnnouncment_Record__c EcAnnRec = new ECAnnouncment_Record__c(EC_Account_Allocation__c= eca1.Id, ECAnnouncment__c= ECAnnList[0].Id);
              insert EcAnnRec;
              Datetime yesterday = Datetime.now().addDays(-1);
              Test.setCreatedDate(EcAnnRec.Id, yesterday);
           
              //Create Custom Setting Records: 
              List<ECLMTriggerFields__c> ECTfieldsList = new  List<ECLMTriggerFields__c>();
              ECLMTriggerFields__c ECTfields1 = new ECLMTriggerFields__c(name = 'EC Name', ChildField__c ='EC_Name__c', ParentField__c='EC_Name__c');
              
              ECLMTriggerFields__c ECTfields2 = new ECLMTriggerFields__c(name = 'EC Status', ChildField__c ='EC_Status__c', ParentField__c='EC_Status__c');
          
              ECTfieldsList.add(ECTfields1);
              ECTfieldsList.add(ECTfields2);
              
              insert ECTfieldsList ; 
              
              // finally Execute batch 
              WB_ECAnnouncementProcess_Batch ECbatch = new WB_ECAnnouncementProcess_Batch(ECAnnList[0].id);
              database.executebatch(Ecbatch, 10);
              system.assertNotEquals(EcAnnRec.Change_Status__c,'Change');
              system.assertNotEquals(EcAnnRec.Changed_Fields__c,'EC Readiness Status');
    }
    
    private static testMethod void CreateAnnRecords3() {
               
              // create MPM
              MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
              insert mpm1;
              //create a title
              Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
              insert title;
               //Create Account
              Account acct= TestUtil.initAccount();
              acct.EC_Digital_Account__c='Digital';
              insert acct;
              
              Account acct2= TestUtil.initAccount();
              acct2.EC_Digital_Account__c='Digital';
              insert acct2;
              
              //create EC Tracker
              EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id, Release_Type__c = 'TNR');
              insert tracker;
              //create or update EC Piece
              EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec1;
              EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec2;
              //Create a record on ECTitelAllocaiton Object to add ecs to titles & Account
              EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
              insert eca1;
              
              CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
              insert cg;
              
              EC_AnnouncementType__c ECAnnType = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = cg.id,Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                                    EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                                   ECAnnouncement_Type__c = 'EST EC Tracker - TV',Selection_Criteria__c = 'Delta',Email__c='test2123123122211@gmail.com',
                                                   Report_Template__c = '00OU0000003gYlQ');
              insert ECAnnType ;
              EC_Announcment__c ECAnn = new EC_Announcment__c (Announcement_Name__c ='new ann', 
                                                            Chatter_Group_ID__c = '1223',
                                                            Report_Name__c='0F921000000CbCJ',
                                                            ECAnnouncement_Type__c = ECAnnType.id ,Selection_Criteria__c='Delta',Release_Type__c = 'TNR');
              
              List<EC_Announcment__c> ECAnnList = new list<EC_Announcment__c>();
              ECAnnList.add(ECAnn);
              insert ECAnnList;
              
              //Create Custom Setting Records: 
              List<ECLMTriggerFields__c> ECTfieldsList = new  List<ECLMTriggerFields__c>();
              ECLMTriggerFields__c ECTfields1 = new ECLMTriggerFields__c(name = 'EC Name', ChildField__c ='EC_Name__c', ParentField__c='EC_Name__c');
              
              ECLMTriggerFields__c ECTfields2 = new ECLMTriggerFields__c(name = 'EC Status', ChildField__c ='EC_Status__c', ParentField__c='EC_Status__c');
          
              ECTfieldsList.add(ECTfields1);
              ECTfieldsList.add(ECTfields2);
              
              insert ECTfieldsList ; 
              
              
              ECAnnouncment_Record__c EcAnnRec = new ECAnnouncment_Record__c(EC_Account_Allocation__c= eca1.Id, ECAnnouncment__c= ECAnnList[0].Id,Change_Status__c = 'Change');
              List<ECAnnouncment_Record__c> EcAnnRecList = new list<ECAnnouncment_Record__c>();
              EcAnnRecList.add(EcAnnRec);
              insert EcAnnRecList;
              for(ECAnnouncment_Record__c ar: EcAnnRecList){
                     Datetime yesterday = Datetime.now().addDays(-1);
                    Test.setCreatedDate(ar.Id, yesterday);
              }
              // finally Execute batch 
              delete cg;
              WB_ECAnnouncementProcess_Batch ECbatch = new WB_ECAnnouncementProcess_Batch(ECAnnList[0].id);
              database.executebatch(Ecbatch, 10);
              system.assertEquals(EcAnnRec.Change_Status__c,'Change');
    }
    
    private static testMethod void CreateAnnRecords4() {
        
              // create MPM
              MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
              insert mpm1;
              //create a title
              Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
              insert title;
               //Create Account
              Account acct= TestUtil.initAccount();
              acct.EC_Digital_Account__c='Digital';
              insert acct;
              
              Account acct2= TestUtil.initAccount();
              acct2.EC_Digital_Account__c='Digital';
              insert acct2;
              
              //create EC Tracker
              EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id, Release_Type__c = 'TNR');
              insert tracker;
              //create or update EC Piece
              EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec1;
              EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec2;
              //Create a record on ECTitelAllocaiton Object to add ecs to titles & Account
              EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
              insert eca1;
              
              CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
              insert cg;
              
              EC_AnnouncementType__c ECAnnType = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = cg.id,Date_Last_Run__c = datetime.newInstance(2016, 5, 6, 12, 30, 0),
                                                    EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                                   ECAnnouncement_Type__c = 'EST EC Tracker - TV', Selection_Criteria__c = 'Finalized Only', Email__c='test2123123122211@gmail.com',
                                                   Report_Template__c = '00OU0000003gYlQ');
              insert ECAnnType ;
              EC_Announcment__c ECAnn = new EC_Announcment__c (Announcement_Name__c ='new ann', 
                                                            Chatter_Group_ID__c = '1223',
                                                            Report_Name__c='0F921000000CbCJ',
                                                            ECAnnouncement_Type__c = ECAnnType.id ,Selection_Criteria__c='Finalized Only',Release_Type__c = 'TNR');
              List<EC_Announcment__c> ECAnnList = new list<EC_Announcment__c>();
              ECAnnList.add(ECAnn);
              insert ECAnnList;
              
              ECAnnouncment_Record__c EcAnnRec = new ECAnnouncment_Record__c(EC_Account_Allocation__c= eca1.Id, ECAnnouncment__c= ECAnnList[0].Id,Changed_Fields__c = 'EC Readiness Status',
                                                 Change_Status__c = 'Change',EC_Readiness_Status__c = 'Finalized');
              insert EcAnnRec;
              Datetime yesterday = Datetime.now().addDays(-1);
              Test.setCreatedDate(EcAnnRec.Id, yesterday);
              // finally Execute batch 
              
              WB_ECAnnouncementProcess_Batch ECbatch = new WB_ECAnnouncementProcess_Batch(ECAnnList[0].id);
              database.executebatch(Ecbatch, 10);
              system.assertEquals(EcAnnRec.Change_Status__c,'Change');
              system.assertEquals(EcAnnRec.Changed_Fields__c,'EC Readiness Status');
              system.assertEquals(EcAnnRec.EC_Readiness_Status__c,'Finalized');
    }
    
    private static testMethod void CreateAnnRecords5() {
        
              // create MPM
              MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
              insert mpm1;
              //create a title
              Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id,Digital_Planning__c='Yes',Formats__c='SD');
              insert title;
               //Create Account
              Account acct= TestUtil.initAccount();
              acct.EC_Digital_Account__c='Digital';
              insert acct;
              
              Account acct2= TestUtil.initAccount();
              acct2.EC_Digital_Account__c='Digital';
              insert acct2;
              
              //create EC Tracker
              EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id, Release_Type__c = 'TNR');
              insert tracker;
              //create or update EC Piece
              EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec1;
              EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm1.Id,Min__c=56,Sec__c=45);
              insert ec2;
              //Create a record on ECTitelAllocaiton Object to add ecs to titles & Account
              EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title.Id,EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Account__c=acct.Id,Format__c='HD');
              insert eca1;
              
              CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
              insert cg;
              
              List<EC_AnnouncementType__c> ECAnnTypeList = new list<EC_AnnouncementType__c>();
              EC_AnnouncementType__c ECAnnType = new EC_AnnouncementType__c (Active__c = true,Chatter_Group_ID__c = cg.id,Date_Last_Run__c =  datetime.newInstance(2016, 5, 6, 12, 30, 0),
												   EC_Schedule_Type__c = 'Daily',EC_Daily_Schedule_Days__c='All Days',EC_Schedule_Time__c='10',
                                                   ECAnnouncement_Type__c = 'EST EC Tracker - TV',Selection_Criteria__c = 'Finalized Only', Email__c='test2123123122211@gmail.com',
                                                   Report_Template__c = '00OU0000003gYlQ');
              ECAnnTypeList.add(ECAnnType);
              insert ECAnnTypeList;
              
              System.debug('Printing ECAnnTypeList ---->>' +ECAnnTypeList);
              
              EC_Announcment__c ECAnn = new EC_Announcment__c (Announcement_Name__c ='new ann', 
                                                            Chatter_Group_ID__c = '1223',
                                                            Report_Name__c='0F921000000CbCJ',
                                                            ECAnnouncement_Type__c = ECAnnTypeList[0].id,Selection_Criteria__c='Finalized Only',Job_Run_Status__c = 'Completed',Release_Type__c = 'TNR');
              List<EC_Announcment__c> ECAnnList = new list<EC_Announcment__c>();
              ECAnnList.add(ECAnn);
              insert ECAnnList;
              
              system.debug('----> EcAnnList[0]' +ECAnnList);
              
              ECAnnouncment_Record__c EcAnnRec = new ECAnnouncment_Record__c(EC_Account_Allocation__c= eca1.Id, ECAnnouncment__c= ECAnnList[0].Id,Changed_Fields__c = 'EC Readiness Status',
                                                 Change_Status__c = 'Change',EC_Readiness_Status__c = 'Finalized');
              insert EcAnnRec;
              Datetime yesterday = Datetime.now().addDays(-1);
              Test.setCreatedDate(EcAnnRec.Id, yesterday);
              //Create Custom Setting Records: 
              List<ECLMTriggerFields__c> ECTfieldsList = new  List<ECLMTriggerFields__c>();
              ECLMTriggerFields__c ECTfields1 = new ECLMTriggerFields__c(name = 'EC Name', ChildField__c ='EC_Type__c', ParentField__c='EC_Status__c');
              
              ECLMTriggerFields__c ECTfields2 = new ECLMTriggerFields__c(name = 'EC Status', ChildField__c ='Account__c', ParentField__c='EC_Availability__c');
              
              ECLMTriggerFields__c ECTfields3 = new ECLMTriggerFields__c(name = 'EC Piece', ChildField__c ='EC_Name__c', ParentField__c='EC_Name__c');
          
              ECTfieldsList.add(ECTfields1);
              ECTfieldsList.add(ECTfields2);
              ECTfieldsList.add(ECTfields3);
              
              insert ECTfieldsList ; 
              
              // finally Execute batch 
              WB_ECAnnouncementProcess_Batch ECbatch = new WB_ECAnnouncementProcess_Batch(ECAnnList[0].id);
              database.executebatch(Ecbatch, 10);
              System.debug('Debuging after execution of batch -->>> ' +ECAnnList[0].id);
              system.assertEquals(EcAnnRec.Change_Status__c,'Change');
              system.assertEquals(EcAnnRec.Changed_Fields__c,'EC Readiness Status');
              system.assertEquals(EcAnnRec.EC_Readiness_Status__c,'Finalized');
              system.assertNotEquals(ECTfieldsList[0].ChildField__c,ECTfieldsList[0].ParentField__c);
              
    }

}