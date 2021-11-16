/**
*  Description    :   Extention Class to update Schedule Announcemen types selected from list view
*  Author         :   Prachi Gadewar
   Emp ID         :   489635
*  Date           :   10 – Aug- 2015
*  
*  =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                               Date                                       Comment
*                                                                                   CHO1
*            
*  
*/


public with sharing class WB_Manage_ScheduleInfo_Controller {
    
    public Boolean showTable{get; set;} // Flag used to hide table of no announcement types available to update.
    Set<Announcement_Rule__c> setAnnouncementTypeToProcess; // Used to show announcements types in VF page.
    public List<Announcement_Rule__c> listAnnouncementTypeToProcess{get; set;}
    public Announcement_Rule__c announcementObj; // Standard controller instance
    public List<String> lstAnnouncementTypeId= new List<String>();     // List Instantiated  and changed it to public
    List<Announcement_Rule__c> listAnnouncementTypeToupdate;
    Integer countAllAnnouncementTypes=0;
    Integer countElligibleAnnouncementTypes=0;
    String param;
    String nonElligibleAnnouncementTypes;
    Map<Id,List<Announcement_Rule__c>> mapAccountAnnouncementType = new Map<Id,List<Announcement_Rule__c>>();
    String pgref = '/a0k';
    
    //****************************  Added for ER - 3332   **************************************************
    public ApexPages.StandardSetController controller1;     
    public List<Announcement_Rule__c> selectedAR1{get;set;} 
    public integer selectedARsize1{get;set;}                
    
    // Constructor contains following steps:
    // 1. Get all announcement type Ids
    // 2. Get accounts associated with announcement types and check if logged in user is an announcer for selected accounts.
    // 3. Filter all Announcement types for above filtered accounts.
    public WB_Manage_ScheduleInfo_Controller(ApexPages.StandardSetController controller) {
        
       //============================ Added for ER - 3332 =====================================================
        this.controller1 = controller;  
        List<sObject> recordsList = controller1.getRecords();
        string objectName = String.valueOf(recordsList.getSObjectType());
        selectedAR1 = (List<Announcement_Rule__c>) controller1.getSelected();
        selectedARsize1 = selectedAR1.size();
        if(objectName == 'Announcement_Rule__c' && selectedARsize1>0){
            for ( Announcement_Rule__c ars1 : (List<Announcement_Rule__c>) controller1.getSelected() )
            {
               lstAnnouncementTypeId.add(ars1.Id);
            }
        }
       //====================================================================================================== 
        
        List<Announcement_Rule__c> listAnnouncementType;
        setAnnouncementTypeToProcess = new Set<Announcement_Rule__c>();
        listAnnouncementTypeToProcess = new list<Announcement_Rule__c>();
        nonElligibleAnnouncementTypes='';
        announcementObj = (Announcement_Rule__c)controller.getRecord();
        announcementObj.Active__c=true;
        String announcementTypeIds = ApexPages.currentPage().getParameters().get('ID');
        param = ApexPages.currentPage().getParameters().get('param');
        if(announcementTypeIds !=null){  
            showTable = true;          
            lstAnnouncementTypeId = announcementTypeIds.split(',');
            countAllAnnouncementTypes = lstAnnouncementTypeId.size();
        
            try
            {
                // Query to get all announcement types for passed ids.
                for(Announcement_Rule__c annType : [SELECT id, Name, Announcement_Type__c, Weekly_Monthly_Schedule_Days__c, Account__c, Schedule_Type__c, Schedule_Time__c, Active__c,Daily_Schedule_Days__c
                                        FROM Announcement_Rule__c
                                        WHERE Id IN: lstAnnouncementTypeId])
                {
                    // Create a map of Account id and their associated Announcement Types.
                    if(!mapAccountAnnouncementType.containskey(annType.Account__c))
                    {
                        mapAccountAnnouncementType.put(annType.Account__c,new List<Announcement_Rule__c>());                        
                    }
                    nonElligibleAnnouncementTypes += annType.Name+', ';
                    mapAccountAnnouncementType.get(annType.Account__c).add(annType);
                    system.debug('******mapAccountAnnouncementType'+mapAccountAnnouncementType);
                }
                
                // Check if logged in user is asn announcer for selected accounts. 
                for(Account_Role__c accountRole : [SELECT id, Account__c, User__c, Role__c FROM Account_Role__c 
                                                   WHERE Account__c in: mapAccountAnnouncementType.keyset() AND USER__c =: userinfo.getuserId() AND Role__c includes('Announcer')])
                {
                    countElligibleAnnouncementTypes += mapAccountAnnouncementType.get(accountRole.Account__c).size();
                    setAnnouncementTypeToProcess.addall(mapAccountAnnouncementType.get(accountRole.Account__c));
                    for(Announcement_Rule__c annType : mapAccountAnnouncementType.get(accountRole.Account__c))
                        nonElligibleAnnouncementTypes = nonElligibleAnnouncementTypes.remove(annType.Name+', ');
                }
                listAnnouncementTypeToProcess.addall(setAnnouncementTypeToProcess);
                // Form , seperated announcement types name used to show in message.
                nonElligibleAnnouncementTypes  = nonElligibleAnnouncementTypes.removeEnd(', ');
                Integer count = countAllAnnouncementTypes - countElligibleAnnouncementTypes;
            
                if(count == countAllAnnouncementTypes)
                {
                    showTable = false;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Manage_Schedule_No_Announcement_Records));                
                }
                else if(nonElligibleAnnouncementTypes != '')
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, String.format(Label.Manage_Schedule_Some_Announcement_Type_Warning,new List<String>{nonElligibleAnnouncementTypes}))); 
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, ''+count+' out of '+countAllAnnouncementTypes+' announcement type(s) are not available to update as logged in user is not Announcer for selected accounts.')); 
                }
            }
            catch(QueryException qe) {
                System.debug('The following exception has occurred: ' + qe.getMessage());    
            }
        }
    }
    
    // Update Announcement typs with specified information on Page.
    public PageReference UpdateRecords()
    {
        pageReference PageRef= new Pagereference('');
        listAnnouncementTypeToupdate = new List<Announcement_Rule__c>();
        if(param=='AnnocementTypeListView'){
            PageRef = new Pagereference(System.Label.Announcement_Type_Home_Page);    
        }
        else{
            PageRef = new Pagereference(pgref);
        }
        for(Announcement_Rule__c annType : listAnnouncementTypeToProcess)
        {
            Announcement_Rule__c newAnnType = new Announcement_Rule__c();
            newAnnType.id = annType.id;
            newAnnType.Schedule_Type__c = announcementObj.Schedule_Type__c;
            newAnnType.Daily_Schedule_Days__c = announcementObj.Daily_Schedule_Days__c;
            newAnnType.Weekly_Monthly_Schedule_Days__c = announcementObj.Weekly_Monthly_Schedule_Days__c;
            newAnnType.Schedule_Time__c = announcementObj.Schedule_Time__c;
            newAnnType.Active__c = announcementObj.Active__c;
            listAnnouncementTypeToupdate.add(newAnnType);
        }
        try{
            update listAnnouncementTypeToupdate;
            return pageRef;
        }
        Catch(Exception e)
        {
            
            ApexPages.addMessages(e);               
        }  
        return null;   
        
    }
    
    // Go back to previous page. 
    public PageReference Cancel()
    {
        pageReference PageRef= new Pagereference('');
         
        if(param=='AnnocementTypeListView'){
            PageRef = new Pagereference(System.Label.Announcement_Type_Home_Page);    
        }
        else{
            PageRef = new Pagereference(pgref);
        }
        
        return pageRef;
    }

}