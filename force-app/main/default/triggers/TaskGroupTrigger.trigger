trigger TaskGroupTrigger on Task (after insert, after update) {
    Id taskWBSFRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('WBSF Tasks').getRecordTypeId();
    List<Task> taskList = new List<Task>();
    if(trigger.isInsert){
        Task_Group_Counter__c tgc = Task_Group_Counter__c.getOrgDefaults();
        Integer counter = Integer.valueOf(tgc.Counter__c) + 1;
        
        Task taskAux;
        for(Task t : trigger.new){
            if(t.RecordTypeId == taskWBSFRecordTypeId){
                taskAux = new Task();
                taskAux.Id = t.Id;
                taskAux.Counter_ID__c = counter;
                taskList.add(taskAux);
            }
        }
        
        if(taskList.size()>0){
            ApexUtil.isTaskTriggerInvoked = true;
            update taskList;
            tgc.Counter__c = counter + 1;
            update tgc;
            ApexUtil.isTaskTriggerInvoked = false;
        }
    }else{
        if(ApexUtil.isTaskTriggerInvoked == false){
            Set<Integer> counterSet = new Set<Integer>();
            for(Task t : trigger.new){
                if(t.RecordTypeId == taskWBSFRecordTypeId && t.Counter_ID__c!=null && t.Status == 'Completed' && t.Status != trigger.oldMap.get(t.Id).Status){
                    counterSet.add(Integer.valueOf(t.Counter_ID__c));
                }
            }
			system.debug(counterSet);
            for(Task t : [Select Id From Task WHERE Counter_ID__c IN: counterSet]){
                t.Status = 'Completed';
                taskList.add(t);
            }
            system.debug(taskList);
            if(taskList.size()>0){
                ApexUtil.isTaskTriggerInvoked = true;
                update taskList;
                ApexUtil.isTaskTriggerInvoked = false;
            }
        }
    }
}