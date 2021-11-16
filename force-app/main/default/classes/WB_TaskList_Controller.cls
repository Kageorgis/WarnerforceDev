/**
*  Description    :   Extention Class used for Task list page. It shows all task pending for logged in user.
*  Author         :   Prachi Gadewar
   Emp ID         :   489635
*  Date           :   11 â Sep- 2015
*  
*  =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                               Date                                       Comment
*                                                                                  CHO1
   Shekhar                              09/29/2015                                 CH02- Update status of Multiple records using Inline editing
*            
*  
*/

public with sharing class WB_TaskList_Controller {

   

   
    public List<SelectOption> listActiveUserOptions{get; set;} // Get all Active user from user object and show in drop down through this proprerty
    public String selectedSortType{get; set;} // Used to get value for selected sort option.
    public List<SelectOption> listSortOptions{   // Get all possible selected options. 
        get
        {
            List<SelectOption> listSortOptions = new List<SelectOption>();
            listSortOptions.add(new SelectOption('Duedate', 'Due Date'));
            listSortOptions.add(new SelectOption('LanguageName', 'Language Name'));
            listSortOptions.add(new SelectOption('TitleName', 'Title'));
            listSortOptions.add(new SelectOption('videoVersionNumber', 'Video Version'));
            return listSortOptions ;
        }     
        set;
    } 
    public Boolean AllSelected{get; set;}
    public Id selectedUserId{get; set;} 
    public Id selectedUserBottomId{get; set;}
    public Boolean showTable{get; set;}
    public List<WB_TaskWrapper> listAllTask{get; set;} // Used to show all open task for logged in user
    public List<WB_TaskWrapper> listTaskController{get; set;} // New list used to show records thorugh pagination
    WB_CustomTaskIterable obj; // Custom iterable class object used for custom pagination
    Map<Id,Available_Languages__c> mapAvailLanguage; // Map contains Available languages 
    
    // Constructor prepares the List of task which open for logged in user for Available languages.
    public WB_TaskList_Controller() 
    {
        set<Id> setAvailLang = new set<Id>(); // Used to store available language ids for those tasks are created.
        listAllTask = new List<WB_TaskWrapper>();
        listActiveUserOptions = new List<SelectOption>();
        showTable=false;
        listActiveUserOptions.add(new SelectOption('','--None--')); // Added None value in User dropdown list
        
        // Get All active users.
        Set<String> setNames = new Set<String>();
        for(WB_User_for_Task_List__c userInSetting : [Select id,name from WB_User_for_Task_List__c])
        {
            setNames.add(userInSetting.Name);
        }
        for(User user : [Select id,Name from User where Name in: setNames])
        {
            listActiveUserOptions.add(new SelectOption(user.id,user.name));  
        }
        
        // Get All task which areassiged to logged in user, Type is available language and status is not completed
        List<Task> listTasks = [SELECT Id,IsHighPriority,OwnerId,Status,WhoId,Subject,WhatId,ActivityDate,AccountId,Priority 
                                FROM Task WHERE What.Type='Available_Languages__c' AND OwnerId =: UserInfo.getUserId() AND Status != 'Completed'
                                Order by ActivityDate];
        // Prepare a set of Avaibale Language id for those tasks created.                                                                               
        for(Task task : listTasks)
        {
            setAvailLang.add(task.WhatId);
        }
        
        // Get All Available Language records for those tasks created.
        mapAvailLanguage = new Map<Id,Available_Languages__c>([Select id,Name,Language__c,Language__r.Name,Language_Types__c,Title__c,Title__r.Name,Title__r.Video_Version__c,GPP_Status__c,Mastering_Reason_Code__c
                                                               FROM Available_Languages__c where id in: setAvailLang]);
        // Create a wrapper list which needs to have task record, language name, video version number etc.
        for(Task task : listTasks)
        {
            listAllTask.add(new WB_TaskWrapper(task,mapAvailLanguage.get(task.whatId).Language__r.Name,
                                               mapAvailLanguage.get(task.whatId))
            );
        }
        // Used to set pagination.
        if(listAllTask != null && listAllTask.size() > 0)
        {
            showTable=true;
            obj = new WB_CustomTaskIterable(listAllTask); 
            //obj.setPageSize = 10;
            obj.setPageSize = Integer.valueof(Label.TaskList_Pagination_Size);
            next();       
        }  
    }
    
    // Get sorted list as per selected sorted type.
    public PageReference sortedList()
    {
        if(selectedSortType != 'Duedate')
        {
            WB_TaskWrapper taskwrapperinst = new WB_TaskWrapper(selectedSortType);
            listAllTask.sort();
        }        
        else
        {
            listAllTask.clear();
            for(Task task : [SELECT Id,IsHighPriority,OwnerId,Status,WhoId,Subject,WhatId,ActivityDate,AccountId,Priority
                         FROM Task WHERE What.Type='Available_Languages__c' AND OwnerId =: UserInfo.getUserId() AND Status != 'Completed'
                         Order by ActivityDate])
            {
                listAllTask.add(new WB_TaskWrapper(task,mapAvailLanguage.get(task.whatId).Language__r.Name,
                                                   mapAvailLanguage.get(task.whatId))
                );
            }
        }
        obj = new WB_CustomTaskIterable(listAllTask); 
        obj.setPageSize = Integer.valueof(Label.TaskList_Pagination_Size);
        next();
        return null;
    }
    
   // Method called, when new status of multiple records are edited using Inline editing- CH02
    public PageReference UpdateStatus() {
      

        List<Task> toUpdateTask = new List<Task>();
        for(WB_TaskWrapper taskw : listAllTask)
        {
            if(taskw.isSelected)
            {
                Task taskInstanceNeedsToUpdate = taskw.taskInstnace;
                toUpdateTask.add(taskInstanceNeedsToUpdate );
            }
        }
        
        if(toUpdateTask.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Task_list_Status_Update));  
            return null; 
        }
        else 
        {
            try{
                update toUpdateTask;
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e);
            }
        }
         PageReference pRef = new PageReference(ApexPages.currentPage().getUrl());
         return pRef;
    }

   
    // Method gets called when user wants to change the owner.
    public PageReference ChangeOwner()
    {
        PageReference pRef = new PageReference(ApexPages.currentPage().getUrl());
        pRef.setRedirect(true);

        system.debug('-----------selectedUserId------------'+selectedUserId +' - '+selectedUserBottomId);
        List<Task> toUpdateTask = new List<Task>();
        for(WB_TaskWrapper taskw : listAllTask)
        {
            system.debug('-----------taskw------------'+taskw.isselected);
            if(taskw.isSelected)
            {
                Task taskInstanceNeedsToUpdate = taskw.taskInstnace;
                if(selectedUserId != null) {
                    taskInstanceNeedsToUpdate.OwnerId = selectedUserId;
                }else{
                    taskInstanceNeedsToUpdate.OwnerId = selectedUserBottomId;
                }
                toUpdateTask.add(taskInstanceNeedsToUpdate);
            }
        }  
        if(selectedUserId == null && selectedUserBottomId == null)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Task_List_Select_User_Error));  
            return null; 
        }
        if(toUpdateTask.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Task_List_select_task_record_to_change_owner_error));  
            return null; 
        }
        else 
        {
            try{
                update toUpdateTask;
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e);
            }
        }
         return pRef;
         
    }
    
    public void SelectAllTask()
    {
        for(WB_TaskWrapper task : listTaskController)
        {
            task.isselected=AllSelected;
        }
    }
    // All pagination methods and properties.
    public Boolean hasNext {
        get 
        {
            return obj.hasNext();
        }
        set;
    }    
    public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
    }    
    public void next() 
    {
        listTaskController = obj.next();
    }
    
    public void previous() 
    {
        listTaskController = obj.previous();
    }      
    public void First()
    {
        while(HasPrevious)
            if(obj != null && HasPrevious)
                listTaskController = obj.previous();
            else 
                break;
    }    
    public void Last()
    {
        while(HasNext)
            if(obj != null && HasNext)
                listTaskController = obj.next();
            else 
                break;
    }
}