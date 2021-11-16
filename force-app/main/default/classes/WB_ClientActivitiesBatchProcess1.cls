global without sharing class WB_ClientActivitiesBatchProcess1 implements Database.Batchable<sObject>, database.stateful{
    
    global String Query ;
    global set<Id> announementIdSet = new set<Id>() ; 
    
    public List<Announcement_Rule__c> announcementRuleList = new List<Announcement_Rule__c>();
    public map<Id,set< ID >> announcementRecordMap = new map<Id,set< ID >>();
    
    list<Client_Avail__c> clientAvails = new list<Client_Avail__c>();  
    public list<Announcement__c> annList= new list<Announcement__c>();
    list<string> annIdList = new list<string>();    
    @testvisible Map<String,Exception> badDataAvails = new Map<String,Exception>();
        
    set<Id> accountIdSet            = new set<Id>();
    set<String> contentTypeSet      = new set<String>();
    set<String> statusSet           = new set<String>();
    set<String> channelSet          = new set<String>();
    set<Id> countryGroupSet         = new set<Id>();
    set<String> statusValues        = new set<String>{'Change','Price Start','Price End','Price Change'};
    id annIdNew ;
    public Id announementId ;
    String cs = 'Start Date';
    String ce = 'End Date';
    Integer monthOfRunDate = Date.Today().month();
    date firstDate = Date.Today().toStartOfMonth();
    date endDate = firstDate.addDays(100);
    Integer numberOfDays = Date.daysInMonth(endDate.year(), endDate.month());
    date rolling90EndDate = Date.newInstance(endDate.year(), endDate.month(), numberOfDays);
    date framedStart =  Date.Today().addDays(-45);
    date framedEnd =  Date.Today().addDays(120);
    date annExecu = Date.Today();    
    date canPeriodMAL =  Date.Today().addDays(-45); //ER-993         
    
    List<Announcement_Trigger_Field__c> annFieldsList = null;
    global WB_compareLastAndFromDates1 compare = null;
    global WB_ClientActivitiesBatchProcess1 ( Id announementId, List<Announcement_Rule__c> announcementTypeList,List<Announcement_Trigger_Field__c> annFields){ 
        //announcementRuleList = announcementTypeList;
        //announementIdSet = announementId;
        this.announementId =announementId;
        annFieldsList = annFields;
        compare = new WB_compareLastAndFromDates1(annFieldsList);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){  
          
        announementIdSet.add(announementId);
        annIdNew = announementId;
        // Newly created announcement
        annList =[ SELECT id, Batch_Job_Id__c,Announcement_Type__c,Account__c, Content_type__c, Status__c, Channels__c, Country_Group__c, Selection_Criteria__c,Full_Extract__c from Announcement__c where Id  =: announementId];
        if(annList.size() > 0){
        	annList[0].Batch_Job_Id__c = bc.getJobId(); //WBTINC0257293 
        	update annList;
        }
        
        announcementRuleList = [SELECT id, name,Announcement_Type__c,Selection_Criteria__c,Date_Last_Run__c,Full_Extract__c,Include_Promotional_Price__c,Announcement_Price_Type__c,
                                            Account__c,Content_Type__c,Statuses__c,Channels__c,Country_Group__c,Report_ID__c,
                                            Report_Template__c,Email_Template__c,createdDate,Account__r.Name,Optional_Triggers__c,
                                            (select id,From_Date__c,Run_Date__c from Announcements__r order by createddate desc)
                                            FROM Announcement_Rule__c
                                            WHERE Id =: annList[0].Announcement_Type__c];
        
        // fetching filter criteria to find client avails for announcement
        accountIdSet.add(annList[0].Account__c);
        for(String ct : annList[0].Content_Type__c.split(';')){
            contentTypeSet.add(ct);
        }
        for(String ct : annList[0].Status__c.split(';')){
            statusSet.add(ct);
        }
        for(String ct : annList[0].Channels__c.split(';')){
            channelSet.add(ct);
        }
        countryGroupSet.add(annList[0].Country_Group__c);  
        
        //Query = 'SELECT Id,Release_Plan_Title__c, Client__c, Title_Content_Type__c, Release_Plan_Channel__c,Release_Plan_Country__c, Local_Data__c, Local_Data_Rating__c,Local_Data_Rating_System__c, EMA_LocalData_Season__c,Local_Data_Num_of_Episodes__c,Local_Title_Version_EIDR__c, Title_Abstract_EIDR__c,RP_Language_Type__c,Start_Date__c,End_Date__c,Status__c,APO_Date__c,Announce_Date__c,Local_Title_DVD_Release_Dt__c,Local_Title_Theatrical_Release__c,Local_Data_Category_Picklist__c,Price_Tier_Text__c,Price__c,Episode_Price_Tier__c,Episode_Price__c,(Select Id,Announcement_Run_Date__c,Announcement__c,Title__c,Local_Title__c,Local_Rating__c,Local_Rating_System__c,Local_Season__c,Local_Episode_Count__c,Abstract_EIDR__c,Version_EIDR__c,Language_Type__c,Client_Start__c,Client_End__c,Status__c,Pre_Order_Date__c,Suppression_End_Date__c,Local_DVD_Release_Date__c,Local_Theatrical_Release_Date__c,Category__c,Price_Tier__c,WS_Cost__c,Episode_Price_Tier__c,Episode_Price__c from Announcement_Client_Avails__r  order by createddate desc )FROM Client_Avail__c WHERE Client__c in :accountIdset AND  Commercial_Avail__r.Title__r.Content_Type__c in :contentTypeSet AND Status__c in :statusSet AND Commercial_Avail__r.Channel__c in :channelSet';
        /*
          Action : Inner query on Announcements Records is removed from the query of Scope
                   Reason : As there were too many records in this query, batch was failing before start because of CPU time limit exceeded exception.
                   So, wrote new query for Client Avails in execute method*/
        /*Change_Context__c field added in below query by shalini for ER-323*/   
        Query = 'SELECT Id,Release_Plan_Title__c, Client__c, CA_Content_Type__c,Change_Context__c, Release_Plan_Channel__c,Release_Plan_Country__c, Local_Data__c, Local_Data_Rating__c,Local_Data_Rating_System__c, EMA_LocalData_Season__c,Local_Data_Num_of_Episodes__c,Local_Title_Version_EIDR__c, Title_Abstract_EIDR__c,RP_Language_Type__c,Start_Date__c,End_Date__c,Status__c,APO_Date__c,Announce_Date__c,Local_DVD_Release_Date__c,Local_Title_Theatrical_Release__c,Local_Data_Category_Picklist__c,Price_Tier_Text__c,Price__c,Episode_Price_Tier__c,Episode_Price__c,First_Announcement_Change_Status__c,EMA_DMA_ID_Formula__c FROM Client_Avail__c WHERE Client__c in :accountIdset AND  CA_Content_Type__c in :contentTypeSet AND Status__c in :statusSet AND Commercial_Avail__r.Channel__c in :channelSet ';
        System.debug(LoggingLevel.INFO,'The Problem Query : '+Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, list<Client_Avail__c> scope){
      
      Map<Id,Boolean> mapOfCAAnnCheck = new Map<Id,Boolean>(); //ER-006900
      List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
        Map<String,String> caChangedFieldsMap = new Map<String,String>();
        clientAvails = [SELECT Id,
                            Release_Plan_Title__c, 
                            Client__c,
                            Name,
                            Title_Alias__c,
                            CA_Content_Type__c, 
                            Release_Plan_Channel__c,
                            Release_Plan_Country__c, 
                            Local_Data__c, 
                            Local_Data_Rating__c,
                            Local_Data_Rating_System__c, 
                            EMA_LocalData_Season__c,
                            Local_Data_Num_of_Episodes__c,
                            Local_Title_Version_EIDR__c, 
                            Title_Abstract_EIDR__c,
                            RP_Language_Type__c,
                            Start_Date__c,
                            End_Date__c,Status__c,
                            Announce_Override__c,
                            APO_Date__c,
                            Announce_Date__c,
                            Local_DVD_Release_Date__c,  //Local DVD Release Date Changed //ER-1043                     
                            Local_Title_Theatrical_Release__c,
                            Local_Data_Category_Picklist__c,
                            Local_Edit_Version__c,                          /*added on 27-Dec-2016 for ER-844*/
                            Price_Tier_Text__c,
                            Price__c,
                            Episode_Price_Tier__c,
                            Episode_Price__c,
                            Episode_Number__c,                              /*Added For RCE: ER-1037*/
                            Title__c,
                            Local_Title__r.Title__c,
                            Title_Video_Version__c,
                            EMA_LicenseType__c,
                            Playlist__c,
                            Playlist__r.Episode_End_Date_Calc__c,
                            First_Announcement_Change_Status__c,          //ER-1139 Return to Window changes
                            //added by shalini for ER-323
                            Change_Context__c,
                            EMA_DMA_ID_Formula__c,
                            EC_Available__c,Vendor_ID__c,
                            Client_Title_ID__c,EMA_BundleALIDs__c,
                            UPC__c,Local_Data_TV_Air_Date__c,
                            EMA_RatingReason__c,Title_ALID__c,
                            EMA_AltID__c,Local_TitleName__c,
                            CA_LifeCycle__c,                         //ER-006900
                            (Select id,Client_Avail__c,Price_Tier__c,Price__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,
                                Effective_Date__c,Expiry_Date__c,Pricing__c,Type__c,CAP_Lifecycle__c,RecordTypeId,RecordType.Name,
                                CA_LifeCycle__c,CA_End_Date__c //ER-993
                              FROM Client_Avail_Prices__r ORDER BY Effective_Date__c,RecordType.Name ASC
                            ),// Sprint 2 change
                            (
                                SELECT Id,Announcement_Run_Date__c,
                                    Announcement__c,
                                    Title__c,
                                    Local_Title__c,
                                    Global_Title__c,
                                    Local_Rating__c,
                                    Local_Rating_System__c,
                                    Local_Season__c,
                                    Local_Episode_Count__c,
                                    Local_Edit_Required__c,                 /*added on 27-Dec-2016 for ER-844*/
                                    Abstract_EIDR__c,
                                    Version_EIDR__c,
                                    Language_Type__c,
                                    Client_Start__c,
                                    Client_End__c,
                                    Status__c,
                                    Pre_Order_Date__c,
                                    Suppression_End_Date__c,
                                    Local_DVD_Release_Date__c,
                                    Local_Theatrical_Release_Date__c,
                                    Category__c,Price_Tier__c,
                                    WS_Cost__c,
                                    Episode_Number__c,                      /*Added for RCE: ER-1037*/
                                    Episode_Price_Tier__c,
                                    Announce_Override__c, //ER-993
                                    Change_Status__c, //ER-993
                                    Episode_Price__c,Change_Context__c,
                                    client_avail__c,Client_Avail_Price__c,
                                    CAP_Comment__c,CAP_Id__c,
                                    EMA_MA_ID__c,EC_Available_Flag__c,Vendor_ID__c,
                                    Retailer_Product_ID__c,Bundle_ALID__c,
                                    UPC__c,Local_TV_Air_Date__c,
                                    Rating_Reason__c,ALID__c,
                                    Alt_ID__c,Changed_Fields__c
                                FROM Announcement_Client_Avails__r  
                                WHERE (NOT Sales_Channel__c LIKE 'PO%')  
                                AND Change_Status__c != NULL //ER-993
                                ORDER BY createddate DESC Limit 50
                             )
                            FROM Client_Avail__c 
                            WHERE Id in :scope
        ];
        
        
        map<Id,set<String>> countryMap  = new map<Id,set<String>>(); // Map of Country Group Id and Related Country Names Set
        list<Announcement_Record__c> annRecordListFinal = new list<Announcement_Record__c>();
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>() ;
        
        Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord = new Map<String,Announcement_Record__c>();
        Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord_PreOrder = new Map<String,Announcement_Record__c>();
    Map<Id,Client_Avail__c> caPreOrderMap = new Map<Id,Client_Avail__c>();
        countryMap = getCountryMap();
        Boolean isTempPrice = false;
        
        
        if(announcementRuleList != null && announcementRuleList.size() > 0){
            
            if(announcementRuleList[0].Announcement_Price_Type__c != null && announcementRuleList[0].Announcement_Price_Type__c.contains('TEMP') && announcementRuleList[0].Announcement_Price_Type__c.contains('PERM')){
                
                isTempPrice = true;
            }
        }
        
        Map<Id,String> caErrorMap = new Map<Id,String>();
        
        List<String> preorderCAPIds = new List<String>();
        List<String> preorderCAIds = new List<String>();
        for(Client_Avail__c CA : clientAvails){
          for(Client_Avail_Price__c cap : CA.Client_Avail_Prices__r){
            if(cap.Effective_Date__c < CA.Start_Date__c){
              preorderCAPIds.add(cap.Id);
              preorderCAIds.add(CA.Id);
            }
          }
          	//ER-006900
          	if(CA.CA_LifeCycle__c.containsOnly('Active Future') && CA.Announcement_Client_Avails__r != null && CA.Announcement_Client_Avails__r.size() > 0){
            	mapOfCAAnnCheck.put(CA.Id,true);    
        	}
        }
        if(preorderCAPIds != null && preorderCAPIds.size()>0){
            caPreOrderMap = getPreOrderAnnouncementRecords(preorderCAIds,preorderCAPIds);
        }
        // Iterate through the list of Client Avails with Announcement Records
        for(Client_Avail__c CA : clientAvails){
            try{
                list<Announcement_Record__c> clientActivityList = new list<Announcement_Record__c>();
                list<Announcement_Record__c> finalClientActivityList = new list<Announcement_Record__c>();
                Boolean startEndChangedFalg = false;
                Boolean isLastInList = false;
                
                Set<String> mergedCapSet = new Set<String>();
                List<Client_Avail_Price__c> preOrderCAPList;
                
                if(annList[0].Country_Group__c != null && CA.Release_Plan_Country__c!= null  && countryMap!= null){
                  if(!countryMap.get(annList[0].Country_Group__c).contains(CA.Release_Plan_Country__c))
                    continue;
                }
                
                if(CA.Playlist__c != Null && CA.Playlist__r.Episode_End_Date_Calc__c != Null)
                    continue;
                        
                //Temp only changes start
                if((announcementRuleList[0].Announcement_Price_Type__c == null || announcementRuleList[0].Announcement_Price_Type__c == '' )|| announcementRuleList[0].Announcement_Price_Type__c != 'TEMP'){
                    capList = compare.getOrderedCAPList(CA,isTempPrice);
                    mapCAANDCAPAnnRecord = compare.populateCAPAnnouncementRecords(CA,capList,mergedCapSet);
                    if(caPreOrderMap != null && caPreOrderMap.get(CA.Id) != null){
                      mapCAANDCAPAnnRecord_PreOrder = compare.populateCAPAnnouncementRecords(caPreOrderMap.get(CA.Id),capList,mergedCapSet);
                    }
                }else if(announcementRuleList[0].Announcement_Price_Type__c.containsOnly('TEMP')){
                    capList.clear();
                    for(Client_Avail_Price__c tempCap: CA.Client_Avail_Prices__r){
                        if(tempCap.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME ){
                          capList.add(tempCap);  
                        }
                    }
                    
                }//Temp only changes end
                
                
                // End:  sprint 2 changes
                Integer CAPcount = 0;
                Boolean isInsertAnnRec = false;
                if(annList != null && annList.size() > 0){// Sprint 2 change
                    for(Client_Avail_Price__c cap : capList){// Sprint 2 change
                        String keyCAP = String.valueof(ca.id)+String.valueof(cap.id)+String.valueof(cap.Effective_Date__c);
                        
                        // If Announcement CG is NOT NULL, then CA Country shoud be in CG of Announcement
                        /*if(annList[0].Country_Group__c != null && CA.Release_Plan_Country__c!= null  && countryMap!= null){
                            if(!countryMap.get(annList[0].Country_Group__c).contains(CA.Release_Plan_Country__c))
                                continue;
                        }*/
                      
                        if(annList[0].Account__c == CA.Client__c && 
                           annList[0].Content_Type__c.contains(CA.CA_Content_Type__c) &&
                           annList[0].Status__c.contains(CA.Status__c) && 
                           annList[0].Channels__c.contains(CA.Release_Plan_Channel__c)){
                             
                            //PreOrder change
                            preOrderCAPList = new List<Client_Avail_Price__c>();
                            if(cap.Effective_Date__c < CA.Start_Date__c){
                              
                              mapCAANDCAPAnnRecord.put(keyCAP,mapCAANDCAPAnnRecord_PreOrder.get(keyCAP)); 
                              if(((announcementRuleList[0].Announcement_Price_Type__c == null || announcementRuleList[0].Announcement_Price_Type__c == '' )
                                                      || announcementRuleList[0].Announcement_Price_Type__c != 'TEMP')){
                              
                                if(annList[0].Selection_Criteria__c == 'Framed Delta' || annList[0].Selection_Criteria__c == 'Delta'){
                                  preOrderCAPList.add(cap);
                                }
                                continue;
                              }
                            }
                             
                              //TPP only changes start
                             if(announcementRuleList != null && announcementRuleList.size() > 0 && announcementRuleList[0].Announcement_Price_Type__c != null && announcementRuleList[0].Announcement_Price_Type__c.containsOnly('TEMP') && cap.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME ){
                                if(( cap.Effective_Date__c >= framedStart && cap.Effective_Date__c <= framedEnd ) || ( cap.Expiry_Date__c >= framedStart && cap.Expiry_Date__c <= framedEnd )){
                                    Announcement_Record__c clientActivity = new Announcement_Record__c();
                                    clientActivity.Announcement__c = annList[0].id; 
                                    clientActivity.Client_Avail__c = cap.Client_Avail__c;
                                    clientActivity.Client_Avail_Price__c = cap.id;
                                    clientActivity.Client_Start__c = cap.Effective_Date__c;
                                    clientActivity.Client_End__c = cap.Expiry_Date__c;
                                    clientActivity.Playlist__c = CA.Playlist__c;
                                    clientActivity.Change_Status__c = '';
                                    
                                    compare.assignCaCapValues(CA,clientActivity);
                                    
                                    clientActivityList.add(clientActivity);
                                    
                                               
                                }  
                            }//TPP only changes end
                            else if(CA.Announcement_Client_Avails__r.size() < 1 && !(annList[0].Selection_Criteria__c == 'AFE' || annList[0].Selection_Criteria__c == 'Active Full Extract')){
                                  
                                 /* //ER-993 start
                                 if(annList[0].Selection_Criteria__c == 'MAL' || annList[0].Selection_Criteria__c == 'Master Avails List')
                                     continue;
                                 //ER-993 end */
                                 
                                 Announcement_Record__c clientActivity = new Announcement_Record__c();
                                 clientActivity.Announcement__c = annList[0].Id;
                                 clientActivity.Client_Avail__c = CA.Id;
                                 clientActivity.Playlist__c = CA.Playlist__c;
                                 clientActivity.Client_Avail_Price__c = cap.id;
                                 clientActivity.Client_Start__c = cap.Effective_Date__c;
                                 clientActivity.Client_End__c = cap.Expiry_Date__c;  //CAP Release2 sprint 1 changes
                                 
                                 compare.assignCaCapValues(CA,clientActivity);
                                 
                                 //CAPcount == 0 &&
                                 if((cap.Effective_Date__c == CA.Start_Date__c || cap.Type__c == 'First' )){ //CAP Release2 sprint 1 changes
                                     if(CA.First_Announcement_Change_Status__c == 'Return'){   //ER-1139 Return to Window changes start
                                        clientActivity.Change_Status__c = 'Return';
                                     }else 
                                        clientActivity.Change_Status__c = 'New';               //ER-1139 Return to Window changes end
                                 }else{
                                     clientActivity.Change_Status__c = 'Price Start';
                                 }
                                 
                                 if(CA.Status__c == 'Cancelled' && CA.Status__c != 'Force')
                                     clientActivity.Announce_Override__c = 'Suppress';
        
                                 //ER-000290 Stopping New 
                                 If( annList[0].Selection_Criteria__c == 'Framed Delta' || annList[0].Selection_Criteria__c == 'Framed Full' || annList[0].Selection_Criteria__c == '90 Day Rolling'){
                                    
                                    if( ( annList[0].Selection_Criteria__c == 'Framed Delta' || annList[0].Selection_Criteria__c == 'Framed Full' ) && 
                                        ( CA.APO_Date__c >= framedStart && 
                                          CA.APO_Date__c <= framedEnd && cap.Type__c == WB_PriceUtility.FIRST && cap.Effective_Date__c > annExecu ) ||
                                        ( cap.Effective_Date__c >= framedStart && cap.Effective_Date__c <= framedEnd ) ||
                                        ( cap.Expiry_Date__c >= framedStart && cap.Expiry_Date__c <= framedEnd )
                                      ){
                                            clientActivityList.add(clientActivity);
                                        } else if(annList[0].Selection_Criteria__c == '90 Day Rolling' && 
                                                  ( ( cap.Effective_Date__c == CA.Start_Date__c) || ( ( cap.Effective_Date__c >= firstDate && cap.Effective_Date__c <= rolling90EndDate ) ||
                                                    ( cap.Expiry_Date__c >= firstDate && cap.Expiry_Date__c <= rolling90EndDate )||
                                                    ( CA.APO_Date__c >= firstDate && CA.APO_Date__c <= rolling90EndDate && 
                                                   cap.Type__c == WB_PriceUtility.FIRST && cap.Effective_Date__c > annExecu ) ) )
                                        ){
                                            clientActivityList.add(clientActivity);  
                                        }else if( CA.Announce_Override__c == 'Force' || CA.Announce_Override__c == 'Suppress' ){ //ER-ER-000452
                                             isInsertAnnRec = compare.checkForForceOrSuppress(CA,cap,null,annList[0],CAPcount);
                                             if(isInsertAnnRec)
                                                clientActivityList.add(clientActivity); 
                                             
                                            
                                        }
                                 }else {
                                    clientActivityList.add(clientActivity); 
                                 }
                            }
                             else if( CA.Announcement_Client_Avails__r.size() >= 1 && annList[0].Selection_Criteria__c == 'Delta' ){
                            
                                system.debug(LoggingLevel.INFO,'=== Delta ===:');
                                
                                Announcement_Record__c clientActivity = compare.compareLastAndFromDates(CA,annList[0],announcementRuleList,cap,mapCAANDCAPAnnRecord.get(keyCAP),false);
                                if(clientActivity!=null){
                                    if((clientActivity.Change_Status__c =='No Change' || statusValues.contains(clientActivity.Change_Status__c )) ){
                                       clientActivityList.add(clientActivity);
                                    }else if( CA.Announce_Override__c == 'Force' || CA.Announce_Override__c == 'Suppress' ){ //ER-ER-000452
                                        isInsertAnnRec = compare.checkForForceOrSuppress(CA,cap,mapCAANDCAPAnnRecord.get(keyCAP),annList[0],CAPcount);
                                        if(isInsertAnnRec)
                                            clientActivityList.add(clientActivity); 
                                    }    
                                }
                                if((cap.Effective_Date__c > CA.Start_Date__c) ){
                                    WB_PriceUtility.announcementRecordChanges(clientActivity);
                                }
                                
                             }
                             else if( CA.Announcement_Client_Avails__r.size() >= 1 && annList[0].Selection_Criteria__c == '90 Day Rolling' ){
                              
                                
                                system.debug(LoggingLevel.INFO,'=== 90 Day Rolling ===:');
                               
                                if( cap.Expiry_Date__c > framedEnd ){
                                    isLastInList = true;
                                }
                                
                                Announcement_Record__c clientActivity = compare.compareLastAndFromDates(CA,annList[0],announcementRuleList,cap,mapCAANDCAPAnnRecord.get(keyCAP),isLastInList);
                                if(clientActivity!=null){
                                   
                                    if ( (clientActivity.Change_Status__c =='No Change' || statusValues.contains(clientActivity.Change_Status__c ) ) && 
                                               ( ( cap.Effective_Date__c >= firstDate && cap.Effective_Date__c <= rolling90EndDate ) ||
                                                 ( cap.Expiry_Date__c >= firstDate && cap.Expiry_Date__c <= rolling90EndDate )||
                                                 ( CA.APO_Date__c >= firstDate && CA.APO_Date__c <= rolling90EndDate && 
                                                   cap.Type__c == WB_PriceUtility.FIRST && cap.Effective_Date__c > annExecu )
                                               )
                                             ){
                                        clientActivityList.add(clientActivity);                     
                                    }else if(CA.Announce_Override__c == 'Force' || CA.Announce_Override__c == 'Suppress'){ //ER-ER-000452
                                        isInsertAnnRec = compare.checkForForceOrSuppress(CA,cap,mapCAANDCAPAnnRecord.get(keyCAP),annList[0],CAPcount);
                                        if(isInsertAnnRec)
                                            clientActivityList.add(clientActivity); 
                                    }else if(clientActivity.Changed_Fields__c != null){ //Start Change - ER-006439 - Capture CA Start Date and End Date change in 90 Day Rolling announcements
                                    	if(clientActivity.Changed_Fields__c.contains(cs) && cap.Effective_Date__c == CA.Start_Date__c){
                                            //Avail Start Date Changed. Announce all previously announced CAPs (include Active Current CAP even it was not announced earlier).
                                            addStartChangeAnnouncementRecords(clientActivityList,CA,mapCAANDCAPAnnRecord,framedEnd,annList[0],announcementRuleList,capList);
                                            startEndChangedFalg = true;
                                            break;
                                        }else if(clientActivity.Changed_Fields__c.contains(ce)  && (cap.Expiry_Date__c == CA.End_Date__c || isLastInList) && mapCAANDCAPAnnRecord.get(keyCAP).Client_End__c != CA.End_Date__c){
                                            //Avail End Date Changed. Announce all previously announced CAPs
                                            clientActivityList.clear();
                                            addEndChangeAnnouncementRecords(clientActivityList,CA,mapCAANDCAPAnnRecord,framedEnd,annList[0],announcementRuleList,cap,capList);
                                            startEndChangedFalg = true;
                                            break;
                                        }   
                                    }
                                    //End Change - //ER-006439 - Capture CA Start Date and End Date change in 90 Day Rolling announcements
                                    
                                    if((cap.Effective_Date__c > CA.Start_Date__c) ){
                                        WB_PriceUtility.announcementRecordChanges(clientActivity);
                                    }
                                }
                            }
                            else if(CA.Announcement_Client_Avails__r.size() >= 1 && annList[0].Selection_Criteria__c == 'Framed Delta'){
                                
                                
                                System.debug(LoggingLevel.INFO,'=== Framed Delta ===:');
                                 
                                if( cap.Expiry_Date__c > framedEnd ){
                                    isLastInList = true;
                                }
                                
                                Announcement_Record__c clientActivity = compare.compareLastAndFromDates(CA,annList[0],announcementRuleList,cap,mapCAANDCAPAnnRecord.get(keyCAP),isLastInList);
                                if(clientActivity!=null){
                                     if(
                                         ( (clientActivity.Change_Status__c =='No Change' || statusValues.contains(clientActivity.Change_Status__c ) )  &&
                                           ( ( CA.APO_Date__c >= framedStart && CA.APO_Date__c <= framedEnd && cap.Type__c == WB_PriceUtility.FIRST && cap.Effective_Date__c > annExecu ) ||
                                             ( cap.Effective_Date__c >= framedStart && cap.Effective_Date__c <= framedEnd ) ||
                                             ( cap.Expiry_Date__c >= framedStart && cap.Expiry_Date__c <= framedEnd ) 
                                            )  
                                        )  
                                     ){
                                        //Adding all the Delta
                                        clientActivityList.add(clientActivity);
                                    }else if(CA.Announce_Override__c == 'Force' || CA.Announce_Override__c == 'Suppress') { //ER-ER-000452
                                        isInsertAnnRec = compare.checkForForceOrSuppress(CA,cap,mapCAANDCAPAnnRecord.get(keyCAP),annList[0],CAPcount);
                                        if(isInsertAnnRec)
                                            clientActivityList.add(clientActivity); 
                                    }else if((cap.Expiry_Date__c < framedStart || cap.Effective_Date__c > framedEnd || (cap.Effective_Date__c < framedStart && cap.Expiry_Date__c > framedEnd)) && clientActivity.Changed_Fields__c != null){
                                        if(cap.Type__c == 'First' &&   clientActivity.Changed_Fields__c.contains(cs)){
                                            //Avail Start Date Changed. Announce all previously announced CAPs (include Active Current CAP even it was not announced earlier).
                                            addStartChangeAnnouncementRecords(clientActivityList,CA,mapCAANDCAPAnnRecord,framedEnd,annList[0],announcementRuleList,capList);
                                            startEndChangedFalg = true;
                                            break;
                                        }else if(clientActivity.Changed_Fields__c.contains(ce)  && (cap.Expiry_Date__c == CA.End_Date__c || isLastInList) && mapCAANDCAPAnnRecord.get(keyCAP).Client_End__c != CA.End_Date__c){
                                            //Avail End Date Changed. Announce all previously announced CAPs
                                            clientActivityList.clear();
                                            addEndChangeAnnouncementRecords(clientActivityList,CA,mapCAANDCAPAnnRecord,framedEnd,annList[0],announcementRuleList,cap,capList);
                                            startEndChangedFalg = true;
                                            break;
                                        }   
                                    }
                                    
                                    if((cap.Effective_Date__c > CA.Start_Date__c) ){
                                        WB_PriceUtility.announcementRecordChanges(clientActivity);
                                    }
                                }
                            }else if(CA.Announcement_Client_Avails__r.size() >= 1 && annList[0].Selection_Criteria__c == 'Framed Full'){
                               
                                System.debug(LoggingLevel.INFO,'=== Framed Full ===:');
                                
                                if( cap.Expiry_Date__c > framedEnd ){
                                    isLastInList = true;
                                }
                                
                                Announcement_Record__c clientActivity = compare.compareLastAndFromDates(CA,annList[0],announcementRuleList,cap,mapCAANDCAPAnnRecord.get(keyCAP),isLastInList);
                                
                                if(clientActivity!=null){
                                    if( (
                                            ( CA.APO_Date__c >= framedStart && CA.APO_Date__c <= framedEnd && cap.Type__c == WB_PriceUtility.FIRST && cap.Effective_Date__c > annExecu ) ||
                                            ( cap.Effective_Date__c >= framedStart && cap.Effective_Date__c <= framedEnd ) ||
                                            ( cap.Expiry_Date__c >= framedStart && cap.Expiry_Date__c <= framedEnd ) 
                                        ) 
                                     ){
                                        //Adding all the Delta
                                        clientActivityList.add(clientActivity);
                                    }else if(CA.Announce_Override__c == 'Force' || CA.Announce_Override__c == 'Suppress'){ //ER-ER-000452
                                        isInsertAnnRec = compare.checkForForceOrSuppress(CA,cap,mapCAANDCAPAnnRecord.get(keyCAP),annList[0],CAPcount);
                                        if(isInsertAnnRec)
                                            clientActivityList.add(clientActivity); 
                                    }else if((cap.Expiry_Date__c < framedStart || cap.Effective_Date__c > framedEnd || (cap.Effective_Date__c < framedStart && cap.Expiry_Date__c > framedEnd)) && clientActivity.Changed_Fields__c != null){
                                        if(cap.Type__c == 'First' &&  clientActivity.Changed_Fields__c.contains(cs)){
                                            //Avail Start Date Changed. Announce all previously announced CAPs (include Active Current CAP even it was not announced earlier).
                                            addStartChangeAnnouncementRecords(clientActivityList,CA,mapCAANDCAPAnnRecord,framedEnd,annList[0],announcementRuleList,capList);
                                            startEndChangedFalg = true;
                                            break;
                                        }else if(clientActivity.Changed_Fields__c.contains(ce) && (cap.Expiry_Date__c == CA.End_Date__c || isLastInList) && mapCAANDCAPAnnRecord.get(keyCAP).Client_End__c != CA.End_Date__c){
                                            //Avail End Date Changed. Announce all previously announced CAPs
                                            clientActivityList.clear();
                                            addEndChangeAnnouncementRecords(clientActivityList,CA,mapCAANDCAPAnnRecord,framedEnd,annList[0],announcementRuleList,cap,capList);
                                            startEndChangedFalg = true;
                                            break;
                                        }   
                                    } 
                                    
                                    if((cap.Effective_Date__c > CA.Start_Date__c) ){
                                        WB_PriceUtility.announcementRecordChanges(clientActivity);
                                    }
                                }
                            }
                            ////////////////////ER-000290 - END
              //CA.Announcement_Client_Avails__r.size() >= 1
                            else if(( annList[0].Selection_Criteria__c == 'AFE' || annList[0].Selection_Criteria__c == 'Active Full Extract' ) ){
                            
                                
                               system.debug(LoggingLevel.INFO,'=== AFE OR Active Full Extract ===:');
                               
                                Announcement_Record__c clientActivity = new Announcement_Record__c();
                                if( (cap.CA_LifeCycle__c.containsOnly('History Expired') && cap.Expiry_Date__c == cap.CA_End_Date__c && cap.CA_End_Date__c >= canPeriodMAL && cap.CA_End_Date__c <= annExecu) //CA Lifecycle - History Expired
                                || (cap.CA_LifeCycle__c.containsOnly('Active Current') && //CA Lifecycle - Active Current
                                     ( //(cap.CAP_Lifecycle__c.containsOnly('History Expired') && (cap.Expiry_Date__c >= framedStart && cap.Expiry_Date__c <= framedEnd)) ||
                                        cap.CAP_Lifecycle__c.containsOnly('Active Current') || 
                                       (cap.CAP_Lifecycle__c.containsOnly('Active Future') && (cap.Effective_Date__c <= framedEnd || mapCAANDCAPAnnRecord.get(keyCAP) != null)) //ER-006900 Changes
                                     )
                                   )
                                 || (cap.CA_LifeCycle__c.containsOnly('Active Future') &&  //CA Lifecycle - Active Future
                                        ((CA.APO_Date__c >= framedStart && CA.APO_Date__c <= framedEnd && cap.Type__c == WB_PriceUtility.FIRST && cap.Effective_Date__c > annExecu) || 
                                          cap.Effective_Date__c <= framedEnd || 
                                         (cap.Effective_Date__c > framedEnd && (mapOfCAAnnCheck.containsKey(CA.Id) && mapOfCAAnnCheck.get(CA.Id)) && cap.Effective_Date__c == CA.Start_Date__c)) //ER-006900
                                    )
                                ){
                                  clientActivity.Announcement__c = annList[0].id; 
                                    clientActivity.Client_Avail__c = cap.Client_Avail__c;
                                    clientActivity.Client_Avail_Price__c = cap.id;
                                    clientActivity.Client_Start__c = cap.Effective_Date__c;
                                    clientActivity.Client_End__c = cap.Expiry_Date__c;
                                    clientActivity.Playlist__c = CA.Playlist__c;
                                    
                                    compare.assignCaCapValues(CA,clientActivity);
                                  clientActivityList.add(clientActivity);
                                }

                                
                            }
                            //break; // Sprint 2 change 
                       }
                       
                        CAPcount++;  
                        WB_CAS_ErrorLogger.logError(errorLogs);
                        
                        
                    }
                }
                //Temp only changes 
                if(announcementRuleList[0].Announcement_Price_Type__c != NULL && announcementRuleList[0].Announcement_Price_Type__c.containsOnly('TEMP')){
                        annRecordListFinal.addAll(clientActivityList);
                }else{
                    for(Integer index=0;index < clientActivityList.size();index++){
                    Announcement_Record__c annRecForLabel = clientActivityList[index];
                    if(annRecForLabel != Null){
              if(index == 0){
                          compare.caChangesOnAnnouncementRecords(annRecForLabel,caChangedFieldsMap);
                        }else if(annRecForLabel.Change_Status__c == 'Price Start' && (annRecForLabel.Changed_Fields__c == '' || annRecForLabel.Changed_Fields__c == null)){
                          if(caChangedFieldsMap.get(annRecForLabel.Client_Avail__c) != null)
                              annRecForLabel.Changed_Fields__c = caChangedFieldsMap.get(annRecForLabel.Client_Avail__c);
                        }
          }
                  }
                  finalClientActivityList = finalAnnouncementRecordList(clientActivityList,CA,mapCAANDCAPAnnRecord,annList[0],startEndChangedFalg,capList,mergedCapSet);
                    annRecordListFinal.addAll(finalClientActivityList);
                    if((finalClientActivityList != null && finalClientActivityList.size() == 0 ) && (annList[0].Selection_Criteria__c == 'Framed Delta' || annList[0].Selection_Criteria__c == 'Delta')){
                      List<Announcement_Record__c> annRecforPreOrderList = new List<Announcement_Record__c>();
                      annRecforPreOrderList = compare.createARForPreOrderCAP(CA,mapCAANDCAPAnnRecord,annList[0],announcementRuleList,capList,annFieldsList,statusValues);
                      if(annRecforPreOrderList != null && annRecforPreOrderList.size()>0){
                          annRecordListFinal.addAll(annRecforPreOrderList);
                      }
                      
                    }
                } 
            }catch(Exception e){
                System.debug(LOGGINGLEVEL.INFO,'Stack Trace -> '+e.getStackTraceString());
                system.debug(LoggingLevel.INFO,'Exception in working with Avail: '+CA+ ' - Exception Reason: '+e);
                caErrorMap.put(CA.Id, e.getMessage());
                badDataAvails.put(CA.Name,e);
            }
        }
        
      
      if(annRecordListFinal != null && annRecordListFinal.size()>0){
    
      List<Client_Avail__c> caErrorList = new  List<Client_Avail__c>();
      
    WB_ClientAvailPriceHandler.recursiveInsert = true;
      Database.Saveresult[] saveResult_CActivity = Database.insert(annRecordListFinal, false);
      for(Integer index = 0; index < saveResult_CActivity.size();index++){
      
    Database.SaveResult insertResult = saveResult_CActivity[index];
        if(!insertResult.isSuccess()){
          String errorMessage = '';
          Id caId;
          for(Database.Error err : insertResult.getErrors()) {
                  errorMessage += err.getMessage();
              }
          caId = annRecordListFinal[index].Client_Avail__c;
          if(!caErrorMap.containsKey(caId))
                  caErrorMap.put(caId, errorMessage);
              
        }
      }
      
      integer count =0;
          For(Database.Saveresult s : saveResult_CActivity)
          {
              if(s.isSuccess())
                  count++;
              else
                  system.debug(s.getErrors());
          }
           system.debug(LoggingLevel.INFO,'countBatch ===: ' + count);
      
      }
      
      
      if(caErrorMap != null && caErrorMap.size()>0){
        WB_compareLastAndFromDates1.createErrorLog(caErrorMap,'Announcement Error');
    }
        
   }
    
   public List<Announcement_Record__c> finalAnnouncementRecordList(List<Announcement_Record__c> clientActivityList,Client_Avail__c CA,Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord,Announcement__c announcement,Boolean startEndChangedFalg,List<Client_Avail_Price__c> capList,Set<String> mergedCapSet){
       Map<Id,List<Announcement_Record__c>> mapCAANDAnnRecord = new Map<Id,List<Announcement_Record__c>>();
       list<Announcement_Record__c> annRecordList = new list<Announcement_Record__c>();
       list<Announcement_Record__c> annRecordFramedDeltaList = new list<Announcement_Record__c>();
       Map<String,Client_Avail_Price__c> mapAnnRecCAP = new Map<String,Client_Avail_Price__c>();
    
       List<Announcement_Record__c> annRecList =  clientActivityList;
       if(annRecList!=null && annRecList.size()>0){
            Integer annRecCount=0;
            Announcement_Record__c lastAnnouncement = annRecList[annRecList.size()-1];
            Client_Avail_Price__c capAfterLast = null;
            Client_Avail_Price__c capOfLastAnnRec = null;
            
            
            for(Client_Avail_Price__c capPrice : capList){
                
                if(capPrice.Effective_Date__c < CA.Start_Date__c){
                    continue; 
                }
                
                for(Announcement_Record__c checkCap :annRecList){
                    if(checkCap.Client_Avail_Price__c == capPrice.Id && capPrice.Effective_Date__c == checkCap.Client_Start__c){
                        String key = checkCap.Client_Avail_Price__c+String.valueOf(checkCap.Client_Start__c);
                        mapAnnRecCAP.put(key,capPrice);
                        if(mergedCapSet.contains(CA.Id+key) && !(announcement.Selection_Criteria__c == 'AFE' || announcement.Selection_Criteria__c == 'Active Full Extract')){
                            checkCap.Change_Status__c = 'Price Change'; 
                        }
                        
                     }
                }
                
                if(capOfLastAnnRec != null  && capPrice.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME){
                    capAfterLast =  capPrice;   
                }
                
                if(capOfLastAnnRec == null && capPrice.Id == lastAnnouncement.Client_Avail_Price__c && capPrice.Effective_Date__c ==  lastAnnouncement.Client_Start__c){
                    capOfLastAnnRec  =  capPrice;
                }
            } 
            
            System.debug(LoggingLevel.INFO,'Announcement Records After status Change'+annRecList);
            
            
            Announcement_Record__c annRecOutsideFrame = null;
            if(lastAnnouncement.Client_End__c != CA.End_Date__c && announcement.Selection_Criteria__c != 'Delta'){
                Client_Avail_Price__c lastCap = mapAnnRecCAP.get(lastAnnouncement.Client_Avail_Price__c+String.valueOf(lastAnnouncement.Client_Start__c));
                if(lastCap.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME || capAfterLast == null){
                    String prevAnnRecKey = String.valueOf(lastAnnouncement.Client_Avail__c);
                    prevAnnRecKey += String.valueOf(lastAnnouncement.Client_Avail_Price__c);
                    prevAnnRecKey += lastCap!= null?String.valueOf(lastCap.Effective_Date__c):''; 
                    Announcement_Record__c prevAnnRec = mapCAANDCAPAnnRecord.get(prevAnnRecKey);
                    WB_compareLastAndFromDates1.updateAnnouncementEndDate(announcement,CA,lastAnnouncement,prevAnnRec);
                }else{
                    //WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
                    String keyCAP = String.valueof(capAfterLast.Client_Avail__c)+String.valueof(capAfterLast.id)+String.valueof(capAfterLast.Effective_Date__c);
                    Announcement_Record__c prevAnnRec = mapCAANDCAPAnnRecord.get(keyCAP);
                    annRecOutsideFrame = compare.compareLastAndFromDates(CA,announcement,announcementRuleList,capAfterLast,prevAnnRec,true);
                    
                    if(annRecOutsideFrame.Client_End__c != CA.End_Date__c)
                        WB_compareLastAndFromDates1.updateAnnouncementEndDate(announcement,CA,annRecOutsideFrame,prevAnnRec);
                    
                    annRecList.add(annRecOutsideFrame);
                    mapAnnRecCAP.put(capAfterLast.Id+String.valueOf(capAfterLast.Effective_Date__c),capAfterLast);
                }
            }
            
            for(Announcement_Record__c annR :annRecList){
                   
                if( CA.Announce_Override__c == 'Force' || CA.Announce_Override__c == 'Suppress' ){
                    annRecordList.add(annR); 
                }else if( ( announcement.Selection_Criteria__c == '90 Day Rolling' )||
                          ( announcement.Selection_Criteria__c == 'Framed Full' )||
                          ( announcement.Selection_Criteria__c == 'AFE' || announcement.Selection_Criteria__c == 'Active Full Extract' )
                        ){
                     annRecordList.add(annR); 
                }else if(announcement.Selection_Criteria__c == 'Framed Delta' ||  announcement.Selection_Criteria__c == 'Delta'  ){
                    if(startEndChangedFalg){
                        annRecordList.add(annR);
                    }else{
                        annRecordFramedDeltaList.add(annR);
                        
                    }
                }
                    
                annRecCount++;
                    
            }  
                    
            //only for Framed Delta Changes
            Boolean isChange = false;
            Boolean addAPONoChange = false;
            list<Announcement_Record__c> tempFramedDeltaList = new list<Announcement_Record__c>();
            list<Announcement_Record__c> annRecordFramedDeltaFinalList = new list<Announcement_Record__c>();
            
          // if( announcement.Selection_Criteria__c == 'Framed Delta' ){
                for(Announcement_Record__c annRecFramedDelta: annRecordFramedDeltaList){ 
                    if((announcement.Selection_Criteria__c == 'Framed Delta' || announcement.Selection_Criteria__c == 'Delta')){
                         // If Announcement Record list has Changed Values add it directly
                         if( (annRecFramedDelta.Change_Status__c != 'No Change' )){    
                             annRecordFramedDeltaFinalList.add(annRecFramedDelta);
                             isChange = true; //List has changed value add no change if any in window
                         }else if( ( annRecFramedDelta.Change_Status__c == 'No Change' ) 
                                    ){
                                   
                              String keyValue = annRecFramedDelta.Client_Avail_Price__c+String.valueOf(annRecFramedDelta.Client_Start__c);
                              if(isChange && (( announcement.Selection_Criteria__c == 'Framed Delta' && ( ( mapAnnRecCAP.get(keyValue).Effective_Date__c >= framedStart  && mapAnnRecCAP.get(keyValue).Effective_Date__c <= framedEnd) ||
                                               ( mapAnnRecCAP.get(keyValue).Expiry_Date__c >= framedStart  &&  mapAnnRecCAP.get(keyValue).Expiry_Date__c <= framedEnd ) ||
                                               annRecFramedDelta == annRecOutsideFrame ) ) ||
                                              ( announcement.Selection_Criteria__c == 'Delta')
                                             )
                               ){
                                 annRecordFramedDeltaFinalList.add(annRecFramedDelta);
                             }else if(!isChange &&  ( (announcement.Selection_Criteria__c == 'Framed Delta' && ( mapAnnRecCAP.get(keyValue).Effective_Date__c >= framedStart  && mapAnnRecCAP.get(keyValue).Effective_Date__c <= framedEnd) ||
                                                       ( mapAnnRecCAP.get(keyValue).Expiry_Date__c >= framedStart  &&  mapAnnRecCAP.get(keyValue).Expiry_Date__c <= framedEnd ) ||
                                                        annRecFramedDelta == annRecOutsideFrame ) ||
                                                     ( announcement.Selection_Criteria__c == 'Delta')
                                                    )
                             ){
                                tempFramedDeltaList.add(annRecFramedDelta);
                             }
                         }
                    }
                }
               
               //If last record comes as isChange and temporary List needs to be added
                if( isChange && tempFramedDeltaList!= null && tempFramedDeltaList.size()>0 ){
                    annRecordFramedDeltaFinalList.addAll(tempFramedDeltaList);
                }
            //}
            
            //Complete FramedDelta List needs to be added back to AnnouncementRecordList
            if( annRecordFramedDeltaFinalList!=null && annRecordFramedDeltaFinalList.size()>0 ){
                annRecordList.addAll(annRecordFramedDeltaFinalList);
            }
            //End of Framed Delta
        }
        
       return annRecordList; 
              
   }
         
   public void addStartChangeAnnouncementRecords(List<Announcement_Record__c> clientActivityList,Client_Avail__c CA,Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord,Date frameEnd,Announcement__c announcement, List<Announcement_Rule__c> announcementRuleList,List<Client_Avail_Price__c> capList){
        for(Client_Avail_Price__c cap : capList){
            try{
                
                if(cap.Effective_Date__c < CA.Start_Date__c){
                    continue; 
                }
                
                Boolean isLastInList = false;
                if( cap.Expiry_Date__c > framedEnd ){
                    isLastInList = true;
                }
                
                String keyCAP = String.valueof(CA.id)+String.valueof(cap.id)+String.valueOf(cap.Effective_Date__c);
                Announcement_Record__c prevAnnRecord = mapCAANDCAPAnnRecord.get(keyCAP);
                Announcement_Record__c currentAnnRecord = compare.compareLastAndFromDates(CA,announcement,announcementRuleList,cap,prevAnnRecord,isLastInList);
                ///*cap.CAP_Lifecycle__c != 'Active Future'*/
                
                if( currentAnnRecord != Null && (cap.Effective_Date__c <= System.today() || prevAnnRecord != null || cap.Effective_Date__c <= framedEnd))
                    clientActivityList.add(currentAnnRecord);   
                if(isLastInList)
                    break;
              
            }catch(Exception ex){
                System.debug(LOGGINGLEVEL.INFO,'Exception occurred in addAnnouncementRecords -> '+ex.getMessage());
            }
        }
   }         
           
   public void addEndChangeAnnouncementRecords(List<Announcement_Record__c> clientActivityList,Client_Avail__c CA,Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord,Date frameEnd,Announcement__c announcement, List<Announcement_Rule__c> announcementRuleList,Client_Avail_Price__c lastCap,List<Client_Avail_Price__c> capList){
        //WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
        for(Client_Avail_Price__c cap : capList){
            try{
                
                if(cap.Effective_Date__c < CA.Start_Date__c){
                    continue; 
                }
                Boolean isLastInList = false;
                if( cap.Expiry_Date__c > framedEnd ){
                    isLastInList = true;
                }
                
                String keyCAP = String.valueof(CA.id)+String.valueof(cap.id)+String.valueOf(cap.Effective_Date__c);
                Announcement_Record__c prevAnnRecord = mapCAANDCAPAnnRecord.get(keyCAP);
                Announcement_Record__c currentAnnRecord = compare.compareLastAndFromDates(CA,announcement,announcementRuleList,cap,prevAnnRecord,isLastInList);
                
                if(currentAnnRecord != Null)
                    clientActivityList.add(currentAnnRecord);
                if(cap.Id == lastCap.Id) 
                    break;                 
            }catch(Exception ex){
                System.debug(LOGGINGLEVEL.INFO,'Exception occurred in addAnnouncementRecords -> '+ex.getMessage());
            }
        }
   }
   
   public Map<Id,Client_Avail__c> getPreOrderAnnouncementRecords(List<String> preorderCAIds,List<String> preorderCAPIds){
     
       Map<Id,Client_Avail__c> preOrderCAList = new Map<Id,Client_Avail__c>([SELECT Id,
                         (Select id,Client_Avail__c,Price_Tier__c,Price__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,
                                Effective_Date__c,Expiry_Date__c,Pricing__c,Type__c,CAP_Lifecycle__c,RecordTypeId,RecordType.Name,
                                CA_LifeCycle__c,CA_End_Date__c
                          FROM Client_Avail_Prices__r Where Id IN :preorderCAPIds ORDER BY Effective_Date__c,RecordType.Name ASC
                         ),
                        (
                            SELECT Id,Announcement_Run_Date__c,
                                Announcement__c,
                                Title__c,
                                Local_Title__c,
                                Global_Title__c,
                                Local_Rating__c,
                                Local_Rating_System__c,
                                Local_Season__c,
                                Local_Episode_Count__c,
                                Local_Edit_Required__c,                 
                                Abstract_EIDR__c,
                                Version_EIDR__c,
                                Language_Type__c,
                                Client_Start__c,
                                Client_End__c,
                                Status__c,
                                Pre_Order_Date__c,
                                Suppression_End_Date__c,
                                Local_DVD_Release_Date__c,
                                Local_Theatrical_Release_Date__c,
                                Category__c,Price_Tier__c,
                                WS_Cost__c,
                                Episode_Number__c,                      
                                Episode_Price_Tier__c,
                                Announce_Override__c, 
                                Change_Status__c, 
                                Episode_Price__c,Change_Context__c,
                                client_avail__c,Client_Avail_Price__c,
                                CAP_Comment__c,CAP_Id__c,
                                EMA_MA_ID__c,EC_Available_Flag__c,Vendor_ID__c,
                                Retailer_Product_ID__c,Bundle_ALID__c,
                                UPC__c,Local_TV_Air_Date__c,
                                Rating_Reason__c,ALID__c,
                                Alt_ID__c,Changed_Fields__c
                            FROM Announcement_Client_Avails__r  
                            WHERE Sales_Channel__c LIKE 'PO%'  
                            AND Change_Status__c != NULL AND Client_Avail_Price__r.Id IN :preorderCAPIds
                            ORDER BY createddate DESC Limit 50
                         )
                        FROM Client_Avail__c 
                        WHERE Id in :preorderCAIds
                  ]);
        
        return preOrderCAList;
   }
   
   public map<Id,set<String>> getCountryMap(){
        map<Id,set<String>> countryMap  = new map<Id,set<String>>();
        for(Country_Group_Country__c cgc : [SELECT Id, Country__c, Country_Group__c, Country__r.Name FROM Country_Group_Country__c Where Country_Group__c = :annList[0].Country_Group__c]){
            if(countryMap.get(cgc.Country_Group__c) != null){
                countryMap.get(cgc.Country_Group__c).add(cgc.Country__r.Name);
            }else{
                countryMap.put(cgc.Country_Group__c, new set<String>{cgc.Country__r.Name});
            }
        }
        return countryMap;
    }
   
   global void finish(Database.BatchableContext BC){
    
    if(badDataAvails.size() != 0){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage ();
            message.setSubject ('Failed Avails in Announcement');
            //message.setPlainTextBody ('Below avails have got failed in Announcement due to bad data...\n\n'+badDataAvails);
            //message.setToAddresses (new String[] {'Amy-Beth.Chamberlin@warnerbros.com'});
            String body = 'Below avails have got failed in Announcement due to bad data...<br/><br/>';

            body += '<html><style> table { border-collapse: collapse; width: 50%;}  table, td, th { border: 1px solid black;} th {height: 30px;}</style>';
            body += '<table><tr><th>Client Avail Name</th><th>Exception error for Client Avail</th></tr>';
            
            for(String caname  : badDataAvails.keyset())
                body += '<tr><td>'+caname+'</td><td>'+badDataAvails.get(caname)+'</td></tr>';
            
            body += '</table></html>';

            message.sethtmlbody (body);
            //message.setToAddresses (new String[] {'Venkatanarayana.Dangeti@wbconsultant.com'});
            //Messaging.sendEmail (new Messaging.SingleEmailMessage [] {message});
            
            message.setToAddresses (new String[] {'Amy-Beth.Chamberlin@warnerbros.com'});
            message.setCcAddresses (new String[] {'David.Williams@warnerbros.com','Venkatanarayana.Dangeti@wbconsultant.com','Srinivas.Choula@wbconsultant.com','Tushar.Bhute@wbconsultant.com'});
            //message.setCcAddresses (new String[] {'prachi.gadewar@cognizant.com'});
            organization org = [SELECT id,isSandbox from organization];
            If(!org.isSandbox)
                Messaging.sendEmail (new Messaging.SingleEmailMessage [] {message});                    
    }
    
    //ER-993 start
    List<Announcement__c> ann = [SELECT id,Selection_Criteria__c,Announcement_Price_Type__c,File_Format__c,Announcement_Record_Count__c FROM Announcement__c WHERE Id IN :annList];
    Boolean isMAL = false;
    
    //Temp only changes
    Boolean isOnlyTemp = false;
    
    if(ann[0].Selection_Criteria__c == 'Active Full Extract' || ann[0].Selection_Criteria__c == 'AFE') isMAL = true;
    
    //Temp only changes
    if(ann[0].Announcement_Price_Type__c != null && ann[0].Announcement_Price_Type__c.containsOnly('TEMP')) isOnlyTemp = true;
    
    if(isOnlyTemp){
      List<Announcement__c> annoucementListUpdate = new List<Announcement__c>();
      for(Announcement__c annRec : ann){
        annRec.Job_Run_Status__c = 'Pending';//ER-000384
        /*if(annRec.File_Format__c=='CSV' && annRec.Announcement_Record_Count__c < 2000){
              annRec.File_Status__c = 'Ready';
        }*/ if(annRec.Announcement_Record_Count__c > WB_Announcement_Util.XLS_LIMIT || (annRec.File_Format__c=='CSV' && annRec.Announcement_Record_Count__c > WB_Announcement_Util.CSV_LIMIT)){
              annRec.File_Status__c = 'Ready';
        }else {
              annRec.File_Status__c = 'Pending';
        }
        
        annoucementListUpdate.add(annRec);
       }
       
       update annoucementListUpdate;
         
      Database.executeBatch(new WB_GenerateReportBatchProcess (announementIdSet), 10);
    }
    else if(isMAL) Database.executeBatch(new WB_Announcement_PreOrders(annList,announcementRuleList,announementIdSet,annFieldsList), 200);
    else 
        Database.executeBatch(new WB_Announcement_Collections (annList,announcementRuleList,announementIdSet,annFieldsList), 1);  
    //ER-993 end
    

   }
   

}