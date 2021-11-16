@isTest
private class TaskGroupTriggerTest {
    @isTest static void test() {
        Id taskWBSFRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('WBSF Tasks').getRecordTypeId();
        Account account = new Account(
            Name = 'account'
        );
        insert account;
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'WBSF Studio - Standard User' LIMIT 1];
        User user = new User(
            ProfileId = profile.Id,
            Username = 'testUser@nanoknee.mir',
            Email = 'testUser@nanoknee.mir',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser',
            LastName = 'Tester'
        );
        insert user;
        Task_Group_Counter__c tgc = Task_Group_Counter__c.getOrgDefaults();
        tgc.Counter__c = 1;
        insert tgc;
        List<Task> testTasks = new List<Task>();
        Task testTask1 = new Task(
            OwnerId = UserInfo.getUserId(),
            WhatId = account.Id,
            Subject = 'testTask',
            Status = 'Not Started',
            RecordTypeId = taskWBSFRecordTypeId,
            ActivityDate = Date.today()
        );
        testTasks.add(testTask1);
        Task testTask2 = new Task(
            OwnerId = user.Id,
            WhatId = account.Id,
            Subject = 'testTask',
            Status = 'Not Started',
            RecordTypeId = taskWBSFRecordTypeId,
            ActivityDate = Date.today()
        );
        testTasks.add(testTask2);
        insert testTasks;
        for(Task updateTask : testTasks) updateTask.Status = 'Completed';
        update testTasks;
    }
}