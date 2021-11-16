@isTest(seeAllData=false)
public class WB_TaskList_Controller_Test
{
    public static UtilityClass_Test  utilClass = new UtilityClass_Test();    
    public static testmethod void testMethod1()
    {
        MPM__c mpm=new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        Task_Group_Counter__c tgc = Task_Group_Counter__c.getOrgDefaults();
        tgc.Counter__c = 1;
        insert tgc;
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Title__c title = (Title__c )utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        Language__c lang = (Language__c)utilClass.createTestRecord(utilClass.setUpData(new Language__c(),0));
        //Available_Languages__c availLang = (Available_Languages__c)utilClass.createTestRecord(utilClass.setUpData(new Available_Languages__c(), 0));
        List<Title__C> titles = [Select id,content_type__c,Video_Version__c from Title__c];
        titles[0].Name ='sdbhksjdjsbdjbsjdbnfjsbdfbsdjfbsjbjksdbfjbsdfsddf';
        titles[0].content_type__c='Episode';
        titles[0].Video_Version__c ='6000047545';
        update titles;
        
        Available_Languages__c availLang = new Available_Languages__c();
        availLang.Language_Types__c='Sub';
        availLang.Title__c=titles[0].id;
        availLang.Language__c =[select id from Language__c limit 1].id;
        availLang.Mastering_Reason_Code__c='Fixes Required';
        availLang.Mastering_Cost__c=225;
        availLang.Clear_to_Avail__c=false;
        listAvailLang.add(availLang);
        
        Available_Languages__c availLang1 = new Available_Languages__c();
        availLang1.Title__c=titles[0].id;
        availLang1.Language__c =[select id from Language__c limit 1].id;
        availLang1.Language_Types__c='Audio';
        availLang1.Mastering_Reason_Code__c='Fixes Required';
        availLang1.Mastering_Cost__c=225;
        availLang1.Clear_to_Avail__c=false;
        listAvailLang.add(availLang1);
        upsert listAvailLang;
        
        List<WB_User_for_Task_List__c> listSetting = new List<WB_User_for_Task_List__c>();
        listSetting.add(new WB_User_for_Task_List__c(Name='Alessandra Piovera',Priority__c=1));
        listSetting.add(new WB_User_for_Task_List__c(Name='Cybelle Sato',Priority__c=2));
        insert listSetting;
        
        Test.starttest();
        List<Task> taskList = new List<Task>();
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task1',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task2',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task3',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task4',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task5',Status='Not Started',Priority='Normal',WhatId=availLang.id));        
        insert taskList;
        
       // Task task = [Select id,ownerid from Task limit 1];
        User u = [select id from User where id =: taskList[0].ownerId];
        System.runAs(u){
            WB_TaskList_Controller controller = new WB_TaskList_Controller();
            PageReference pageRef = Page.WB_TaskList;
            Test.setCurrentPage(pageRef);
            List<SelectOption> listSortOptionsTest = controller.listSortOptions;
            controller.selectedSortType='LanguageName';
            controller.sortedList();
            controller.selectedSortType='videoVersionNumber';
            controller.sortedList();
            controller.selectedSortType='TitleName';
            controller.sortedList();
            controller.selectedSortType='DueDate';
            controller.sortedList();
            controller.AllSelected=true;
            controller.SelectAllTask();
            controller.ChangeOwner();
            controller.selectedUserId=u.id;
            controller.ChangeOwner();
            controller.listAllTask[0].isSelected=true;
            controller.ChangeOwner();
            controller.listAllTask[0].isSelected=true;
            controller.UpdateStatus();
            Task task1 = [Select id,ownerId from Task where id =: controller.listAllTask[0].taskInstnace.id];
            system.assertequals(u.id,task1.ownerid);
        }
        test.stoptest();
    }
    
    public static testmethod void testMethod2()
    {
        Task_Group_Counter__c tgc = Task_Group_Counter__c.getOrgDefaults();
        tgc.Counter__c = 1;
        insert tgc;
        //Available_Languages__c availLang = (Available_Languages__c)utilClass.createTestRecord(utilClass.setUpData(new Available_Languages__c(), 0));
        Title__c title = (Title__c )utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
        Language__c lang = (Language__c)utilClass.createTestRecord(utilClass.setUpData(new Language__c(),0));
        
        Available_Languages__c availLang = new Available_Languages__c();
        availLang.Language_Types__c='Sub';
        availLang.Title__c=title.id;
        availLang.Language__c =lang.id;
        availLang.Mastering_Reason_Code__c='Fixes Required';
        availLang.Mastering_Cost__c=225;
        availLang.Clear_to_Avail__c=false;
        insert availLang;
        title.content_type__c='Episode';
        title.Video_Version__c ='6000047545';
        update title;
        
        List<Task> taskList = new List<Task>();
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task1',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task2',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task3',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task4',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task5',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task6',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task7',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task8',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task9',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task10',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task11',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task12',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task13',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task14',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task15',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task16',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task17',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task18',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task19',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task20',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        taskList.add(new Task(OwnerId = UserInfo.getUserId(),Subject='test task21',Status='Not Started',Priority='Normal',WhatId=availLang.id));
        
        insert taskList;
        WB_TaskList_Controller controller = new WB_TaskList_Controller();
        PageReference pageRef = Page.WB_TaskList;
        Test.setCurrentPage(pageRef);
        Test.starttest();
        controller.next();
        controller.First();
        controller.Last(); 
        controller.AllSelected=true;
        controller.SelectAllTask();
        system.assertequals(controller.listTaskController.size(),1);       
        controller.previous();
        Test.stoptest();
    }
}