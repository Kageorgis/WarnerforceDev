global without sharing class WB_Announcement_Pre_Orders implements Database.Batchable<sObject>, database.stateful{
    

    list<Announcement__c> annList= new list<Announcement__c>();
    set<Id> announementIdSet = new set<Id>() ; 
    List<Announcement_Rule__c> announcementRuleList = new List<Announcement_Rule__c>();
    map<id,Announcement_Record__c> preOrderList = new map<id,Announcement_Record__c>();
    Date annExecu = Date.Today();
    Boolean isMAL = false; //ER-993    

    global WB_Announcement_Pre_Orders(list<Announcement__c> annList, List<Announcement_Rule__c> announcementRuleList, set<Id> announementIdSet){
        this.annList = annList;
        this.announementIdSet = announementIdSet;
        this.announcementRuleList = announcementRuleList;
        //ER-993 start
        List<Announcement__c> ann = [SELECT id,Selection_Criteria__c FROM Announcement__c WHERE Id IN :annList];
        if(ann[0].Selection_Criteria__c == 'Active Full Extract' || ann[0].Selection_Criteria__c == 'AFE') isMAL = true;
        //ER-993 end
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        return Database.getQueryLocator([SELECT Id, 
                                                Client_Avail__c, 
                                                Client_Avail__r.Client__c, 
                                                Client_Avail__r.Id, 
                                                Abstract_EIDR__c,
                                                Account__c,
                                                Announcement_Date__c,
                                                Announcement_Name__c,
                                                Announcement__c,
                                                Announcement_Run_Date__c,
                                                Announce_Override__c,
                                                Change_Context__c,
                                                Changed_Fields__c,
                                                Change_Status__c,
                                                Channel__c,
                                                Client_End__c,
                                                Client_Start__c, 
                                                Country__c,
                                                Version_EIDR__c,
                                                EMA_EntryType__c,
                                                EMA_Entry_Type__c,
                                                EMA_License_Type__c,
                                                Episode_Price__c,
                                                Episode_Price_Tier__c,
                                                Format__c,
                                                Global_Title__c,
                                                Language__c,
                                                Language_Type__c,
                                                Local_DVD_Release_Date__c,
                                                Local_Episode_Count__c,
                                                Local_Edit_Required__c,                 //Added on 08-Feb-2017 for ER-844.
                                                Local_Rating__c,
                                                Local_Rating_System__c,
                                                Local_Season__c,
                                                Local_Theatrical_Release_Date__c,
                                                Local_Title__c,
                                                Pre_Order_Date__c, 
                                                Price_Tier__c,
                                                Sales_Channel__c,
                                                Status__c,
                                                Suppression_End_Date__c,
                                                Title__c,
                                                Category__c,
                                                WS_Cost__c,
                                                zAnnouncement_Number__c,
                                                zClient_Avail__c,
                                                zWB_Territory__c,
                                                Announcement__r.Full_Extract__c,
                                                Client_Avail_Price__r.Effective_Date__c,
                                                 Client_Avail__r.Start_Date__c
                                           FROM Announcement_Record__c 
                                          WHERE Announcement__c IN :annList
                                          AND Client_Avail_Price__r.Type__c = :WB_PriceUtility.FIRST Order By Client_Avail_Price__c,Client_Avail_Price__r.Effective_Date__c
                                                    /*AND ((Pre_Order_Date__c != null AND (Changed_Fields__c LIKE '%re Order Dat%' OR Changed_Fields__c LIKE '%lient Star%' OR Change_Status__c = 'New')) OR
                                                         (Pre_Order_Date__c = null AND Changed_Fields__c LIKE '%re Order Dat%')) */
                                                  ]);
                                                  
    }
    
    global void execute(Database.BatchableContext BC, list<Announcement_Record__c> scope){
        
        List<Id> clientAvailIds = new List<Id>();
        Set<Id> capIds = new Set<Id>(); //ER-993
        Set<Id> inScopeArIds = new Set<Id>(); //ER-993
        Map<Id,Announcement_Record__c> capToARMap = new Map<Id,Announcement_Record__c>(); //ER-993
        list<Announcement_Record__c> clientActivityList = new list<Announcement_Record__c>();
        Map<Id,Announcement_Record__c> annRecMap = new Map<Id,Announcement_Record__c>();
        set<String> statusValues  = new set<String>{'Change','Price Start','Price End','Price Change'};
        String preOrderDate = 'Pre Order Date';
        //String preOrderDate = 'Start Date';
        String cs = 'Start Date';
        String ce = 'End Date';
        String status = 'Status';
        
        for(Announcement_Record__c ar : scope){
            inScopeArIds.add(ar.Id); //ER-993
            capIds.add(ar.Client_Avail_Price__c); //ER-993
            clientAvailIds.add(ar.Client_Avail__r.Id);
        }
        
        Map<Id,Client_Avail__c> clientAvails = new Map<id,Client_Avail__c>([SELECT Id, APO_Date__c, Start_Date__c, End_Date__c, EMA_LicenseType__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c FROM Client_Avail__c WHERE Id IN :clientAvailIds]);
       
        
        for(Announcement_Record__c pAnn :  [Select Id,Sales_Channel__c,Client_Avail__c,Pre_Order_Date__c,Client_Start__c,Client_End__c,Category__c,WS_Cost__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c from Announcement_Record__c where Client_Avail__c IN :clientAvailIds AND Sales_Channel__c LIKE 'PO%' AND Announce_Override__c != 'Suppress' ORDER BY createddate])
            preOrderList.put(pAnn.Client_Avail__c,pAnn);
        
        
        //ER-993 start
        if(isMAL){
            for(Announcement_Record__c ar : [Select Id,Client_Avail__c,Client_Avail_Price__c from Announcement_Record__c where id NOT IN :inScopeArIds AND Client_Avail_Price__c IN :capIds AND (NOT Sales_Channel__c LIKE 'PO%') AND Announce_Override__c != 'Suppress' ORDER BY createddate])
                capToARMap.put(ar.Client_Avail_Price__c,ar);
            for(Announcement_Record__c ar : scope){
               
               if(annRecMap.containsKey(ar.Client_Avail__r.Id)){
                continue;
               }else if(ar.Client_Avail_Price__r.Effective_Date__c == ar.Client_Avail__r.Start_Date__c){
                annRecMap.put(ar.Client_Avail__r.Id,ar);
               }
                if(ar.Client_Start__c > annExecu){
                    if(capToARMap.get(ar.Client_Avail_Price__c) != null && clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c != null){
                        Announcement_Record__c clientActivity = new Announcement_Record__c();
                        clientActivity = ar.clone(false,false,false,false);
                        clientActivity.Pre_Order_Date__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                        clientActivity.Client_Start__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                        clientActivity.Client_End__c = clientAvails.get(ar.Client_Avail__r.Id).Start_Date__c.addDays(-1) ;
                        clientActivity.Sales_Channel__c= 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                        clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                        clientActivity.Change_Status__c = '';
                        clientActivity.Changed_Fields__c = '';
                        clientActivity.Announce_Override__c = ar.Announce_Override__c;
                        //clientActivity.Category__c = clientAvails.get(ar.Client_Avail__r.Id).Local_Data_Category_Picklist__c;//SINC1585908
                        setPriceValues(clientActivity,clientAvails.get(ar.Client_Avail__r.Id)); //ER - SINC0886386
                        clientActivityList.add(clientActivity);
                    }
                }
            }
        } else
        //ER-993 end
        for(Announcement_Record__c ar : scope){
            
            if(annRecMap.containsKey(ar.Client_Avail__r.Id)){
                 continue;
             }else if(ar.Client_Avail_Price__r.Effective_Date__c == ar.Client_Avail__r.Start_Date__c){
                annRecMap.put(ar.Client_Avail__r.Id,ar);
            }
            
            if(ar.Client_Start__c > annExecu){
                Boolean alreadyInAnnouncement = false; //ER-963
                //If standard announcement was never announced - which means that the pre order was never announced - and both are being announced now
               
                if(ar.Pre_Order_Date__c != null && ar.Change_Status__c == 'New' && preOrderList.get(ar.Client_Avail__r.Id) == null){
                    
                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                    clientActivity = ar.clone(false,false,false,false);
                    clientActivity.Pre_Order_Date__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_Start__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_End__c = clientAvails.get(ar.Client_Avail__r.Id).Start_Date__c.addDays(-1) ;
                    clientActivity.Sales_Channel__c= 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                    clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                    clientActivity.Change_Status__c = 'New';
                    clientActivity.Changed_Fields__c=' ';
                    clientActivity.Announce_Override__c = ar.Announce_Override__c;
                    //clientActivity.Category__c = clientAvails.get(ar.Client_Avail__r.Id).Local_Data_Category_Picklist__c;//SINC1585908
                    setPriceValues(clientActivity,clientAvails.get(ar.Client_Avail__r.Id)); //ER - SINC0886386
                    clientActivityList.add(clientActivity);
                    alreadyInAnnouncement = true; //ER-963
                }
                
                //If standard announcement was issued in past but no pre order announcement, now the pre order date has been updated - requires a pre order announcement as 'new'
                //Tejasvini modified PreOrder condition
                if(ar.Changed_Fields__c != null && ar.Changed_Fields__c.contains(preOrderDate) && preOrderList.get(ar.Client_Avail__r.Id) == null && ar.Pre_Order_Date__c != null && (statusValues.contains(ar.Change_Status__c ))){
                   
                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                    clientActivity = ar.clone(false,false,false,false);
                    clientActivity.Pre_Order_Date__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_Start__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_End__c = clientAvails.get(ar.Client_Avail__r.Id).Start_Date__c.addDays(-1) ;
                    clientActivity.Sales_Channel__c= 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                    clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                    clientActivity.Change_Status__c = 'New';
                    clientActivity.Changed_Fields__c = ar.Changed_Fields__c;
                    clientActivity.Announce_Override__c = ar.Announce_Override__c;
                    //clientActivity.Category__c = clientAvails.get(ar.Client_Avail__r.Id).Local_Data_Category_Picklist__c;//SINC1585908
                    setPriceValues(clientActivity,clientAvails.get(ar.Client_Avail__r.Id)); //ER - SINC0886386
                    clientActivityList.add(clientActivity);
                    alreadyInAnnouncement = true; //ER-963
                }
                
                //If standard announcement and preorder were issued in past, now there is no change in standard avail (framed full).
                if((ar.Changed_Fields__c == null && preOrderList.get(ar.Client_Avail__r.Id) != null && ar.Pre_Order_Date__c != null && ar.Change_Status__c == 'No Change' )){
                    
                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                    clientActivity = ar.clone(false,false,false,false);
                    clientActivity.Pre_Order_Date__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_Start__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_End__c = clientAvails.get(ar.Client_Avail__r.Id).Start_Date__c.addDays(-1) ;
                    clientActivity.Sales_Channel__c= 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                    clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                    clientActivity.Change_Status__c = clientActivity.Change_Status__c;
                    clientActivity.Changed_Fields__c=' ';
                    clientActivity.Announce_Override__c = ar.Announce_Override__c;
                    //clientActivity.Category__c = clientAvails.get(ar.Client_Avail__r.Id).Local_Data_Category_Picklist__c;//SINC1585908
                    setPriceValues(clientActivity,clientAvails.get(ar.Client_Avail__r.Id)); //ER - SINC0886386
                    clientActivityList.add(clientActivity);
                    alreadyInAnnouncement = true; //ER-963
                }
                
                // Pre-Order date changed and Pre-Order Avail was already announced - issue a PO change announcement
                // Client Avail Start Date changed and Pre-Order Avail was already announced - issue a PO change announcement
                //Tejasvini modified PreOrder condition
                if(ar.Changed_Fields__c != null && preOrderList.get(ar.Client_Avail__r.Id) != null && ar.Pre_Order_Date__c != null && (statusValues.contains(ar.Change_Status__c )) && 
                  (ar.Changed_Fields__c.contains(preOrderDate) || ar.Changed_Fields__c.contains(cs) || ar.Changed_Fields__c.contains(status))){
                   
                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                    String changedFields = '';
                    clientActivity = ar.clone(false,false,false,false);
                    clientActivity.Pre_Order_Date__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_Start__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_End__c = clientAvails.get(ar.Client_Avail__r.Id).Start_Date__c.addDays(-1) ;
                    clientActivity.Sales_Channel__c = 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                    clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                    clientActivity.Change_Status__c = 'Change';
                    clientActivity.Changed_Fields__c = ar.Changed_Fields__c;
                    clientActivity.Announce_Override__c = ar.Announce_Override__c;
                    //clientActivity.Category__c = clientAvails.get(ar.Client_Avail__r.Id).Local_Data_Category_Picklist__c;///SINC1585908
                    setPriceValues(clientActivity,clientAvails.get(ar.Client_Avail__r.Id)); //ER - SINC0886386
                    /*if(ar.Changed_Fields__c.contains(preOrderDate) && !ar.Changed_Fields__c.contains(cs))
                        changedFields = 'Start Date';*/
                    if(ar.Changed_Fields__c.contains(cs) && !ar.Changed_Fields__c.contains(ce))
                        changedFields = ', End Date';
                        
                    clientActivity.Changed_Fields__c = clientActivity.Changed_Fields__c + changedFields;
                    /*if(ar.Changed_Fields__c.contains(cs) && ar.Changed_Fields__c.contains(preOrderDate))
                        clientActivity.Changed_Fields__c =  'Pre Order Date, Start Date, End Date';*/
                        
                    //Tejasvini modified PreOrder condition
                    /*if(ar.Changed_Fields__c.countMatches(preOrderDate) == 1 && ar.IsPreOrderDateChanged__c)
                        clientActivity.Changed_Fields__c = preOrderDate +','+cs;
                    if(ar.Changed_Fields__c.countMatches(cs) == 1 && !(ar.Changed_Fields__c.contains(preOrderDate) && ar.IsPreOrderDateChanged__c))
                        clientActivity.Changed_Fields__c = ce;
                    if(ar.Changed_Fields__c.countMatches(preOrderDate) == 2 && ar.IsPreOrderDateChanged__c)
                        clientActivity.Changed_Fields__c = cs+','+preOrderDate+','+ce;
                    if(ar.Changed_Fields__c.contains(status))
                        clientActivity.Changed_Fields__c = (clientActivity.Changed_Fields__c == '') ? 'Status' : clientActivity.Changed_Fields__c + ', Status';*/
                    clientActivityList.add(clientActivity);
                    alreadyInAnnouncement = true; //ER-963
                }
                
                // Pre Order has been issued in past, now the Pre Order date has been removed - need to issue the Pre Order cancellation
                if(ar.Changed_Fields__c != null && preOrderList.get(ar.Client_Avail__r.Id) != null && ar.Pre_Order_Date__c == null && 
                  (statusValues.contains(ar.Change_Status__c )) && ar.Changed_Fields__c.contains(preOrderDate) ){
                    
                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                    clientActivity = ar.clone(false,false,false,false);
                    clientActivity.Pre_Order_Date__c = preOrderList.get(ar.Client_Avail__r.Id).Pre_Order_Date__c;
                    clientActivity.Client_Start__c = preOrderList.get(ar.Client_Avail__r.Id).Client_Start__c;
                    clientActivity.Client_End__c = preOrderList.get(ar.Client_Avail__r.Id).Client_End__c;
                    clientActivity.Sales_Channel__c= 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                    clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                    clientActivity.Change_Status__c = 'Change';
                    clientActivity.Status__c = 'Cancelled';
                    clientActivity.Changed_Fields__c= 'Status';
                    clientActivity.Announce_Override__c = ar.Announce_Override__c;
                    //clientActivity.Category__c = preOrderList.get(ar.Client_Avail__r.Id).Category__c;//SINC1585908
                    //clientActivity.WS_Cost__c = preOrderList.get(ar.Client_Avail__r.Id).WS_Cost__c;//SINC1585908
                    //clientActivity.Price_Tier__c = preOrderList.get(ar.Client_Avail__r.Id).Price_Tier__c;//SINC1585908
                    clientActivity.Episode_Price__c = preOrderList.get(ar.Client_Avail__r.Id).Episode_Price__c;
                    clientActivity.Episode_Price_Tier__c=preOrderList.get(ar.Client_Avail__r.Id).Episode_Price_Tier__c;
                    
                    
                    if(ar.Announcement__r.Full_Extract__c == true)
                        clientActivity.Announce_Override__c = 'Suppress';
                    clientActivityList.add(clientActivity);
                    alreadyInAnnouncement = true; //ER-963
                }
                
                //ER-963 start - Sriniz
                //Announce pre-order always, along with regular EST and if it wasnt already included in the announcement for the reasons in above if statements - ER-963
                if(!alreadyInAnnouncement && ar.Pre_Order_Date__c != null){
                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                    clientActivity = ar.clone(false,false,false,false);
                    clientActivity.Pre_Order_Date__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_Start__c = clientAvails.get(ar.Client_Avail__r.Id).APO_Date__c;
                    clientActivity.Client_End__c = clientAvails.get(ar.Client_Avail__r.Id).Start_Date__c.addDays(-1) ;
                    clientActivity.Sales_Channel__c= 'PO'+clientAvails.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
                    clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
                    clientActivity.Change_Status__c = ar.Change_Status__c;
                    clientActivity.Changed_Fields__c = ar.Changed_Fields__c;
                    clientActivity.Announce_Override__c = ar.Announce_Override__c;
                    clientActivityList.add(clientActivity);
                    alreadyInAnnouncement = true;
                }
                //ER-963 end - Sriniz
                
            }
        }
    
        system.debug('clientActivityList ===: ' + clientActivityList.size());         
        Database.Saveresult[] saveResult_CActivity = Database.insert(clientActivityList, false);
        system.debug('saveResult_CActivity ===: ' + saveResult_CActivity.size());

        integer count =0;
        For(Database.Saveresult s : saveResult_CActivity){
            if(s.isSuccess())
                count++;
            else
                system.debug(s.getErrors());
            }
        system.debug('countBatch ===: ' + count);
         
    }
    
    public void setPriceValues(Announcement_Record__c clientActivity,Client_Avail__c caRecord){
        //Changes for ER - SINC0886386
        //clientActivity.WS_Cost__c = caRecord.Price__c; //SINC1585908
        //clientActivity.Price_Tier__c = caRecord.Price_Tier_Text__c;//SINC1585908
        //clientActivity.Episode_Price__c = caRecord.Episode_Price__c;//SINC1585908
        //clientActivity.Episode_Price_Tier__c= caRecord.Episode_Price_Tier__c;//SINC1585908
    }
    
    global void finish(Database.BatchableContext BC){
    //updating job status on announcement
    list<Announcement__c> annoucementListUpdate = new list<Announcement__c>();
    AsyncApexJob a = [Select Id, CompletedDate,Status, NumberOfErrors, JobItemsProcessed,  
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :BC.getJobId()];
   for(Announcement__c ann : annList){
    ann.Job_Run_Status__c = 'Pending';//ER-000384
    Announcement__c annNew = [SELECT File_Format__c,Announcement_Record_Count__c  FROM Announcement__c where id=:ann.id];
    System.debug('annNew.File_Format__c :'+annNew.File_Format__c);
    System.debug('annNew.Announcement_Record_Count__c :'+annNew.Announcement_Record_Count__c);
    if(annNew.File_Format__c=='CSV' && annNew.Announcement_Record_Count__c < 2000){
          ann.File_Status__c = 'Ready';
    } if(annNew.Announcement_Record_Count__c > 25000){
          ann.File_Status__c = 'Ready';
    }else {
          ann.File_Status__c = 'Pending';
    }
    annoucementListUpdate.add(ann);
    
   }
        
    update annoucementListUpdate;  
    if (!Test.IsRunningTest()){
            Id batchInstanceId = Database.executeBatch(new WB_GenerateReportBatchProcess (announementIdSet), 10);
    }
    
  
   }

}