public without sharing class WB_Announcement_Confirmation_Controller {
    
    public string announcementTypeIds{get;set;}
    public List<String> lstAnnouncementTypeId = new List<String>(); //  List Instantiated
    public List<Announcement_Rule__c> announcementRuleList{set;get;}   // list of selected Announcement Types list
    public List<Announcement__c> announcementRecordCreateList = new List<Announcement__c>();        //list to use to create Announcements
    public List<Announcement_Rule__c> announcementRuleFinalList{set;get;}        //final list to use to create Announcements
    public transient List<User> currentUser = new list<User>();
    public transient Set<Id> accountSet= new Set<Id>();        // set of Account ids from selected Announcement Rules records
    public transient List<Account_Role__c> accountAnnouncerList = new List<Account_Role__c>();
    public boolean announcementRuleDisplay{get;set;}
    public string announcementRuleMessage{get;set;}
    public boolean announcementRuleRendered{get;set;}
    public boolean InternalOnlyCheck{get;set;}    
    public string announcementName;
    public string accountIdRedir{get;set;}
    public String param{get;set;}
    public set<Id> annoucementIds = new set<Id>();
    public transient map<Id, Announcement_Record__c> clientAvailAnnRecordMap = new map<Id, Announcement_Record__c>();
    public transient map<Id,set< ID >> announcementRecordMap = new map<Id,set< ID >>();
    public Map<Id,List<Announcement_Receipient__c>> mapAnnoucementTypeRecepeients = new Map<Id,List<Announcement_Receipient__c>>();
    public Set<ID> setAnnoucementTypeIds = new Set<ID>();
    
    //****************************  Added for ER - 3332   **********************************************
    public ApexPages.StandardSetController controller1;     
    public List<Announcement_Rule__c> selectedAR{get;set;} 
    public integer selectedARsize{get;set;}                
    
    public WB_Announcement_Confirmation_Controller() {
    }  
    public WB_Announcement_Confirmation_Controller(ApexPages.StandardSetController controller) {
    //============================ Added for ER - 3332 ==================================================
        this.controller1 = controller;  
        List<sObject> recordsList = controller1.getRecords();
        string objectName = String.valueOf(recordsList.getSObjectType());
        
        selectedAR = controller1.getSelected();  //(List<Announcement_Rule__c>) 
        system.debug('selectedAR=============>>>'+selectedAR);
        selectedARsize = selectedAR.size();
        if(objectName == 'Announcement_Rule__c' && selectedARsize>0){
            for ( Announcement_Rule__c ars : (List<Announcement_Rule__c>) controller1.getSelected() )
            {
               lstAnnouncementTypeId.add(ars.Id);
            }
        }
    //====================================================================================================
        
        announcementRuleDisplay = true;
        announcementRuleRendered = false;
        accountIdRedir = '';
        announcementRuleFinalList = new List<Announcement_Rule__c>();
        announcementTypeIds = ApexPages.currentPage().getParameters().get('ID');
        system.debug('announcementTypeIds****'+announcementTypeIds);
        if(announcementTypeIds !=null){
            lstAnnouncementTypeId = announcementTypeIds.split(',');
        }
        if(lstAnnouncementTypeId!= null && lstAnnouncementTypeId.size() > 0){    
        try{
                announcementRuleList= [SELECT id, name,Announcement_Type__c,Selection_Criteria__c,Date_Last_Run__c,Announcement_Price_Type__c,
                                        Account__c,Content_Type__c,Statuses__c,Channels__c,Country_Group__c,Report_ID__c,
                                        Report_Template__c,Email_Template__c,createdDate,Account__r.Name,File_Format__c,Full_Extract__c,Announcement_Date_Format__c,Optional_Triggers__c,Separate_Files_By_Contract__c,(select id,From_Date__c,Run_Date__c from Announcements__r order by createddate desc)
                                        FROM Announcement_Rule__c
                                        WHERE Id IN: lstAnnouncementTypeId];
                system.debug('announcementRuleList****'+announcementRuleList);
        }
        catch(QueryException qe) {
            System.debug('The following exception has occurred: ' + qe.getMessage());    
        }
        
        
         param= ApexPages.currentPage().getParameters().get('param');
         
         if(param == null){
           accountIdRedir= announcementRuleList[0].Account__c;
        }
        
        for(Announcement_Rule__c annRuleList: announcementRuleList){
            accountSet.add(annRuleList.Account__c);
        }
        try{
                accountAnnouncerList = [SELECT id,Account__c
                                        FROM Account_Role__c
                                        WHERE Account__c IN: accountSet
                                        AND Role__c includes( 'Announcer' )
                                        AND User__c=: Userinfo.getUserId()];
        }
        catch(QueryException qe) {
            System.debug('The following exception has occurred: ' + qe.getMessage());    
        }
        
        for(Announcement_Rule__c AnnRule: announcementRuleList){
            for(Account_Role__c acctAnnouncer:accountAnnouncerList ){
                if(AnnRule.Account__c == acctAnnouncer.Account__c){
                    announcementRuleFinalList.add(AnnRule);
                }
            }
        }  
 
       
        if(accountAnnouncerList != null && accountAnnouncerList.size() > 0){
            if(announcementRuleList.size() > announcementRuleFinalList.size()){
                integer announcementRuleCount= announcementRuleList.size()- announcementRuleFinalList.size();
                announcementRuleRendered = true;
                announcementRuleMessage ='Out of '+' '+announcementRuleList.size()+' '+'selected Announcement Rules,'+' '+ announcementRuleCount+' '+'cannot create Announcement' ;
                
            }
        }
        else{
            System.debug('*********************************************************  '); 
            announcementRuleDisplay = false;
            
        }
        
        //ER-1710
        for(Announcement_Rule__c type: announcementRuleFinalList )
            setAnnoucementTypeIds.add(type.Id);
            
        for(Announcement_Receipient__c receipient: [Select Id,Email__c,Announcement_Type__c 
                                                    from Announcement_Receipient__c 
                                                    where Announcement_Type__c IN:setAnnoucementTypeIds]) {
            if(!mapAnnoucementTypeRecepeients.containsKey(receipient.Announcement_Type__c))
                mapAnnoucementTypeRecepeients.put(receipient.Announcement_Type__c,New List<Announcement_Receipient__c>());
                mapAnnoucementTypeRecepeients.get(receipient.Announcement_Type__c).add(receipient);
        }
        system.debug('mapAnnoucementTypeRecepeients****'+mapAnnoucementTypeRecepeients);
    }
    }
     public pagereference cancel(){
        
         pageReference PageRef= new Pagereference('');
         
         if(param=='AnnocementTypeListView'){
            PageRef = new Pagereference(System.Label.Announcement_Type_Home_Page);
            
        }
        else if (param=='AccountListView')
        {
            PageRef = new Pagereference(System.Label.Announcement_Type_Home_Page);
        }
        else{
            PageRef = new Pagereference('/'+accountIdRedir);
        }
         
         return PageRef;
    }
    
   
   public void GenerateAnnouncements(){
        announcementCreation(); // This function is used to create Announcements
        
   }
   
   public pagereference announcementCreation() {
    
        for(Announcement_Rule__c announcementRule: announcementRuleFinalList){
            Announcement__c announcementRecord = new Announcement__c();
            String strReceipientEmail = '';
            announcementRecord.Announcement_Type__c          = announcementRule.Id;
            announcementRecord.Account__c                    = announcementRule.Account__c;
            announcementRecord.Selection_Criteria__c         = announcementRule.Selection_Criteria__c;
            announcementRecord.Announcement_Price_Type__c    = announcementRule.Announcement_Price_Type__c;
            announcementRecord.Content_Type__c               = announcementRule.Content_Type__c;
            announcementRecord.Status__c                     = announcementRule.Statuses__c;
            announcementRecord.Channels__c                   = announcementRule.Channels__c;
            announcementRecord.File_Format__c                = announcementRule.File_Format__c;
            announcementRecord.File_Status__c                = 'TBD';
            announcementRecord.Country_Group__c              = announcementRule.Country_Group__c;
            announcementRecord.Report_Id__c                  = announcementRule.Report_ID__c;
            announcementRecord.Report_Name__c                = announcementRule.Report_Template__c;
            announcementRecord.Email_Template__c             = announcementRule.Email_Template__c;
            announcementRecord.Job_Run_Status__c             = 'In Progress';
            announcementRecord.Full_Extract__c               = announcementRule.Full_Extract__c;
            announcementRecord.Announcement_Date_Format__c   = announcementRule.Announcement_Date_Format__c;
            announcementRecord.Selected_Fields__c            = announcementRule.Optional_Triggers__c;   //Added by Akash
			announcementRecord.Separate_Files_By_Contract__c = announcementRule.Separate_Files_By_Contract__c;
                
            //dateTime dt                               = announcementRule.Date_Last_Run__c;   
            dateTime dt                               = Datetime.now(); 
            
            if(dt != null){
                String strConvertedDate = dt.format('yyyy-MM-dd');             
                announcementName   = announcementRule.Announcement_Type__c + ' ' + strConvertedDate; //-- commented by Rashmi*/
            }
            else
                announcementName   = announcementRule.Announcement_Type__c;

            if(InternalOnlyCheck == true){
                announcementName = announcementName + ' Internal';
                announcementRecord.Internal__c = true;      
                announcementRecord.Announced_User__c = UserInfo.getUserId();         
            }    

            announcementRecord.Name__c = announcementName;
            
            //ER-1710
            if(mapAnnoucementTypeRecepeients.get(announcementRule.Id) != NULL){
                
                List<Announcement_Receipient__c> lstReceipients = mapAnnoucementTypeRecepeients.get(announcementRule.Id);
                for(Announcement_Receipient__c receipient: lstReceipients){
                    if(receipient.Email__c != '' || receipient.Email__c != NULL)
                        strReceipientEmail += receipient.Email__c+';';
                }
                strReceipientEmail = strReceipientEmail.removeEnd(';');
                strReceipientEmail = strReceipientEmail.trim();
            }
            announcementRecord.Recipient_Emails__c = strReceipientEmail;
            //#END ER-1710
            system.debug('announcementRecord****'+announcementRecord);
            announcementRecordCreateList.add(announcementRecord);
            //ER-993 start
            //Delete previous MAL AR records. Commented below on 03/07 as per SINC1540368
            /*if(announcementRule.Selection_Criteria__c == 'Master Avails List' || announcementRule.Selection_Criteria__c == 'MAL')
                Id batchInstanceId1 = Database.executeBatch(new WB_DeleteMALARRecs(announcementRule.Id), 200);  
            */    
            //ER-993 End

       }
      

       if(announcementRecordCreateList != null && announcementRecordCreateList.size() > 0){
       	   List<Announcement_Trigger_Field__c> annFields = [Select Id,Name,Changed_Field__c,Changed_Status__c,Destination_API__c,Destination_Object__c,Source_API__c,Source_Object__c,Trigger_Status__c,TV__c,Feature__c FROM Announcement_Trigger_Field__c];
           try{
              Database.Saveresult[] saveResult  = Database.insert(announcementRecordCreateList, false);
              
              for(Database.Saveresult annInsertedRec: saveResult)
              {
                if(annInsertedRec.isSuccess())
                        //annoucementIds.add(annInsertedRec.id); 
                     //Create client activity
                     Id batchInstanceId = Database.executeBatch(new WB_ClientActivitiesBatchProcess1 (annInsertedRec.id,announcementRuleList,annFields), 200);  
                     
                     //** Rashmi .. its me Milon commented the below line. When you start working please change it
                     // Id batchInstanceId = Database.executeBatch(new WB_ClientActivitiesBatchProcessTestLimit (annInsertedRec.id,announcementRuleList), 1000);  
              }
              
              //Create client activity
              
              //Id batchInstanceId = Database.executeBatch(new WB_ClientActivitiesBatchProcess (annoucementIds,announcementRuleList), 200); 
              
              
           }
           catch(DmlException dmlex){
               System.debug('The following exception has occurred: ' + dmlex.getMessage());
           }
           
           
           pageReference  PageRef = new Pagereference(System.Label.Announcement_Type_Home_Page);
          
           return PageRef;
              
       } // if block where checking announcementRecordCreateList list is not empty     
       
       return null; 
       
   }    //announcementCreation() end
   
    
    
}