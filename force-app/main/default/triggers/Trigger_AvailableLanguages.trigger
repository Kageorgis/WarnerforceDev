trigger Trigger_AvailableLanguages on Available_Languages__c (before delete) 
{
    if(trigger.isdelete && trigger.isbefore)
    {
        List<Task> listTask = [Select id from Task where Whatid in: Trigger.old];
        if(listTask != null)
            delete listTask;
    }
}