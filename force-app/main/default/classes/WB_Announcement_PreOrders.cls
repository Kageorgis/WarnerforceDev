global without sharing class WB_Announcement_PreOrders implements Database.Batchable<sObject>, database.stateful{
    

    list<Announcement__c> annList= new list<Announcement__c>();
    set<Id> announementIdSet = new set<Id>() ; 
    List<Announcement_Rule__c> announcementRuleList = new List<Announcement_Rule__c>();
    map<id,Announcement_Record__c> preOrderList = new map<id,Announcement_Record__c>();
    
    Date annExecu = Date.Today();
    Boolean isMAL = false; //ER-993    
	global WB_compareLastAndFromDates1 compare = null;
	
	List<Announcement_Trigger_Field__c> annFieldsList = null;
    global WB_Announcement_PreOrders(list<Announcement__c> annList, List<Announcement_Rule__c> announcementRuleList, set<Id> announementIdSet,List<Announcement_Trigger_Field__c> annFields){
        this.annList = annList;
        this.announementIdSet = announementIdSet;
        this.announcementRuleList = announcementRuleList;
        annFieldsList = annFields;
        compare = new WB_compareLastAndFromDates1(annFieldsList);
        //compare = new WB_compareLastAndFromDates1();
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
                                                Client_Avail__r.Start_Date__c,
                                                EMA_MA_ID__c
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
        
        list<Client_Avail__c> clientAvails = new list<Client_Avail__c>();
        
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
                            Local_Edit_Version__c,                         
                            Price_Tier_Text__c,
                            Price__c,
                            Episode_Price_Tier__c,
                            Episode_Price__c,
                            Episode_Number__c,                            
                            Title__c,
                            Local_Title__r.Title__c,
                            Title_Video_Version__c,
                            EMA_LicenseType__c,
                            Playlist__c,
                            First_Announcement_Change_Status__c,          
                            Change_Context__c,
                            EMA_DMA_ID_Formula__c,
                            EC_Available__c,Vendor_ID__c,
                            Client_Title_ID__c,EMA_BundleALIDs__c,
                            UPC__c,Local_Data_TV_Air_Date__c,
                            EMA_RatingReason__c,Title_ALID__c,
                            EMA_AltID__c,Local_TitleName__c,
                            (Select id,Client_Avail__c,Price_Tier__c,Price__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,
                                Effective_Date__c,Expiry_Date__c,Pricing__c,Type__c,CAP_Lifecycle__c,RecordTypeId,RecordType.Name,
                                CA_LifeCycle__c,CA_End_Date__c 
                              FROM Client_Avail_Prices__r ORDER BY Effective_Date__c,RecordType.Name ASC
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
                                    Alt_ID__c
                                FROM Announcement_Client_Avails__r  
                                WHERE Change_Status__c != NULL AND
                                id NOT IN :inScopeArIds
                                ORDER BY createddate DESC Limit 50
                             )
                            FROM Client_Avail__c 
                            WHERE Id in :clientAvailIds
        ];
        
         
         List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>() ;
         Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord = new Map<String,Announcement_Record__c>();
         Map<String,Announcement_Record__c> mapCAANDCAPAnnRecordPreOrder ;
         Map<String,Announcement_Record__c> mapCAANDCAPAnnRecordMAL ;
         Map<String,Announcement_Record__c> mapMALCAPAnnRecord = new Map<String,Announcement_Record__c>();
         Map<String,List<Client_Avail_Price__c>> caPreOrderCAPMap = new Map<String,List<Client_Avail_Price__c>>(); 
         Map<String,List<Client_Avail_Price__c>> caMalCAPMap = new Map<String,List<Client_Avail_Price__c>>();
         Map<String,Client_Avail_Price__c> caFirstCAPAnnRecord = new Map<String,Client_Avail_Price__c>(); 
         Map<Id,Client_Avail__c> caMap = new Map<id,Client_Avail__c>();
         Boolean isTempPrice = false;
         
         if(announcementRuleList != null && announcementRuleList.size() > 0){
            
            if(announcementRuleList[0].Announcement_Price_Type__c != null && announcementRuleList[0].Announcement_Price_Type__c.contains('TEMP') && announcementRuleList[0].Announcement_Price_Type__c.contains('PERM')){
                
                isTempPrice = true;
            }
         }
        
         for(Client_Avail__c caRecord : clientAvails){
         	
         	Set<String> mergedCapSet = new Set<String>();
         	
         	List<Client_Avail_Price__c> preOrderCapList = new List<Client_Avail_Price__c>() ;
         	List<Client_Avail_Price__c> malCapList = new List<Client_Avail_Price__c>() ;
         	if((announcementRuleList[0].Announcement_Price_Type__c == null || announcementRuleList[0].Announcement_Price_Type__c == '' )|| announcementRuleList[0].Announcement_Price_Type__c != 'TEMP'){
                capList = compare.getOrderedCAPList(caRecord,isTempPrice);
                for(Client_Avail_Price__c cap:capList){
                	if(!caMap.containsKey(caRecord.Id)){
                		caMap.put(caRecord.Id,caRecord);
                	}
                	if(cap.Effective_Date__c < caRecord.Start_Date__c){
                		if(!caPreOrderCAPMap.containsKey(caRecord.Id)){
                			caPreOrderCAPMap.put(caRecord.Id,new List<Client_Avail_Price__c>{cap});
                		}else{
                			caPreOrderCAPMap.get(caRecord.Id).add(cap);
                		}
                		preOrderCapList.add(cap);
                	}else{
                		if(cap.Effective_Date__c == caRecord.Start_Date__c){
                			caFirstCAPAnnRecord.put(caRecord.Id,cap);
                		}
                		
                		if(isMAL){
                			malCapList.add(cap);
                			/*if(!caMalCAPMap.containsKey(caRecord.Id)){
                				caMalCAPMap.put(caRecord.Id,new List<Client_Avail_Price__c>{cap});
                			}else{
                				caMalCAPMap.get(caRecord.Id).add(cap);
                			}*/
                		}
                	}
                	
                	
                }
                
                if(preOrderCapList != null && preOrderCapList.size()>0){
                	mapCAANDCAPAnnRecordPreOrder = compare.populateCAPAnnouncementRecords(caRecord,preOrderCapList,mergedCapSet);
                
                	mapCAANDCAPAnnRecord.putAll(mapCAANDCAPAnnRecordPreOrder);
                }
                if(isMAL){
                	
                	if(malCapList != null && malCapList.size()>0){
                		mapCAANDCAPAnnRecordMAL = compare.populateCAPAnnouncementRecords(caRecord,malCapList,mergedCapSet);
                		mapMALCAPAnnRecord.putALL(mapCAANDCAPAnnRecordMAL);
                		mapCAANDCAPAnnRecord.putAll(mapCAANDCAPAnnRecordMAL);
                	}
                	
                }
            }
         }
         
         
         
         if(isMAL){
         	/*for(Announcement_Record__c ar : [Select Id,Client_Avail__c,Client_Avail_Price__c from Announcement_Record__c where id NOT IN :inScopeArIds AND Client_Avail_Price__c IN :capIds AND (NOT Sales_Channel__c LIKE 'PO%') AND Announce_Override__c != 'Suppress' ORDER BY createddate])
                capToARMap.put(ar.Client_Avail_Price__c,ar);*/
         	
         	
         	for(Announcement_Record__c ar : scope){
         		if(ar.Client_Start__c > annExecu){
         		
         			//if(caMalCAPMap.containsKey(ar.Client_Avail__r.Id)){
         			//if(capToARMap.get(ar.Client_Avail_Price__c) != null){
         				
         			
	          			if(caPreOrderCAPMap.containsKey(ar.Client_Avail__r.Id)){
          					if(caPreOrderCAPMap.get(ar.Client_Avail__r.Id) != null && caPreOrderCAPMap.get(ar.Client_Avail__r.Id).size()>0){
          						for(Client_Avail_Price__c cap:caPreOrderCAPMap.get(ar.Client_Avail__r.Id)){
		          					String keyCAP = String.valueof(ar.Client_Avail__r.Id)+String.valueof(cap.id)+String.valueof(cap.Effective_Date__c);
		          					if( caMap.get(ar.Client_Avail__r.Id).APO_Date__c != null){
		         						Announcement_Record__c clientActivity = ar.clone(false,false,false,false);
				                    	setAnnouncementRecordValues(clientActivity,ar,caMap,cap);
				                    	clientActivity.Change_Status__c = '';
				                    	clientActivity.Changed_Fields__c = '';
				                    	clientActivityList.add(clientActivity);
         							}
          						}
          					}
	          			}
	          			Boolean isModified = WB_PriceUtility.announcementRecordChanges(ar);
                      	if(isModified){
                      	   clientActivityList.add(ar);
                      	}
	          
         			//}
         		}
         	}
         }else
         
         for(Announcement_Record__c ar : scope){
          	
          	if(ar.Client_Start__c > annExecu){
          		Boolean alreadyInAnnouncement = false; 
          		if(caPreOrderCAPMap.containsKey(ar.Client_Avail__r.Id)){
          			if(caPreOrderCAPMap.get(ar.Client_Avail__r.Id) != null && caPreOrderCAPMap.get(ar.Client_Avail__r.Id).size()>0){
          				for(Client_Avail_Price__c cap:caPreOrderCAPMap.get(ar.Client_Avail__r.Id)){
          				    String keyCAP = String.valueof(ar.Client_Avail__r.Id)+String.valueof(cap.id)+String.valueof(cap.Effective_Date__c);
	          				Announcement_Record__c clientActivity = new Announcement_Record__c();
	          				
	          				if( mapCAANDCAPAnnRecord.get(keyCAP) == null){
	          					if(ar.Pre_Order_Date__c != null){
	          						//If standard announcement was never announced - which means that the pre order was never announced - and both are being announced now
		          					if(ar.Change_Status__c == 'New'){
		          					    clientActivity = ar.clone(false,false,false,false);
			                    		setAnnouncementRecordValues(clientActivity,ar,caMap,cap);
			                    		if(cap.Effective_Date__c == caMap.get(ar.Client_Avail__r.Id).APO_Date__c){
			                    			clientActivity.Change_Status__c = 'New';
			                    		}else
			                    			clientActivity.Change_Status__c = 'Price Start';
			                        	clientActivity.Changed_Fields__c = '';
			                        	clientActivityList.add(clientActivity);
			                        	alreadyInAnnouncement = true;
			                        	
		          					}else if(ar.Change_Status__c == 'No Change'){
		          						clientActivity = ar.clone(false,false,false,false);
			                    		setAnnouncementRecordValues(clientActivity,ar,caMap,cap);
			                    		clientActivity.Change_Status__c = 'Price Start';
			                        	clientActivity.Changed_Fields__c = ar.Changed_Fields__c;
			                        	clientActivityList.add(clientActivity);
			                        	alreadyInAnnouncement = true;
		          					}
		          					
		          					//If standard announcement was issued in past but no pre order announcement, now the pre order date has been updated - requires a pre order announcement as 'new'
		          					if(ar.Changed_Fields__c != null){
			                    		clientActivity = ar.clone(false,false,false,false);
			                    		setAnnouncementRecordValues(clientActivity,ar,caMap,cap);
			                    		if(cap.Effective_Date__c == caMap.get(ar.Client_Avail__r.Id).APO_Date__c){
			                    			clientActivity.Change_Status__c = 'New';
			                    		}else
			                    			clientActivity.Change_Status__c = 'Price Start';
			                    		//clientActivity.Change_Status__c = ar.Change_Status__c; //New value to be modified
			                    		clientActivity.Changed_Fields__c = ar.Changed_Fields__c;
			                        	clientActivityList.add(clientActivity);
			                        	alreadyInAnnouncement = true;
		          						
		          					}
	          					}
	          					
	          					
	          					
	          				}
	                    	
	          				if(mapCAANDCAPAnnRecord.get(keyCAP) != null){
	          					if(ar.Pre_Order_Date__c != null){
	          						clientActivity = compare.compareLastAndFromDates(caMap.get(ar.Client_Avail__r.Id),annList[0],announcementRuleList,cap,mapCAANDCAPAnnRecord.get(keyCAP),false);
	          						if(clientActivity != null){
	          							clientActivity.Client_Avail__c = ar.Client_Avail__r.Id;
	          						
	          							setAnnouncementRecordValues(clientActivity,ar,caMap,cap);
		                    			clientActivity.Change_Status__c = clientActivity.Change_Status__c;
		                    			clientActivity.Changed_Fields__c = clientActivity.Changed_Fields__c;
										clientActivity.EMA_Entry_Type__c = ar.EMA_Entry_Type__c;
		                        		clientActivityList.add(clientActivity);
		                        		alreadyInAnnouncement = true;
	          						}
	          					}
	          				}
	          				
	          				
	          			}
          			}
          		}else if(ar.Changed_Fields__c != null && caPreOrderCAPMap.get(ar.Client_Avail__r.Id) == null && ar.Pre_Order_Date__c == null && (ar.Changed_Fields__c.contains(preOrderDate))){
          			Announcement_Record__c preOrderClientActivity = new Announcement_Record__c();
          			Client_Avail_Price__c firstCap = caFirstCAPAnnRecord.get(ar.Client_Avail__r.Id);
          			if(caMap.get(ar.Client_Avail__r.Id) != null && caMap.get(ar.Client_Avail__r.Id).Announcement_Client_Avails__r != null && caMap.get(ar.Client_Avail__r.Id).Announcement_Client_Avails__r.size()>0){
          				for(Announcement_Record__c firstAr : caMap.get(ar.Client_Avail__r.Id).Announcement_Client_Avails__r){
	          				if(firstAr.Client_Avail_Price__c == firstCap.Id){
	          					system.debug(LoggingLevel.INFO,'AR:'+firstAr);
	          					preOrderClientActivity = firstAr;
	          					break;
	          				}
	          			}
          			}
          			
          			
          			Announcement_Record__c clientActivity = new Announcement_Record__c();
          			clientActivity = ar.clone(false,false,false,false);
          			if(preOrderClientActivity.Pre_Order_Date__c != null){
          				clientActivity.Pre_Order_Date__c = preOrderClientActivity.Pre_Order_Date__c;
			        	clientActivity.Client_Start__c = preOrderClientActivity.Pre_Order_Date__c;
          			}else{
          				clientActivity.Pre_Order_Date__c = ar.Client_Start__c.addDays(-1);
			        	clientActivity.Client_Start__c = ar.Client_Start__c.addDays(-1);
          			}
          			clientActivity.Client_End__c = ar.Client_Start__c.addDays(-1);
			        clientActivity.Sales_Channel__c= 'PO'+caMap.get(ar.Client_Avail__r.Id).EMA_LicenseType__c;
			        clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
			        clientActivity.Change_Status__c = 'Change';
			        clientActivity.Status__c = 'Cancelled';
			        clientActivity.Changed_Fields__c= 'Status';
			        clientActivity.Announce_Override__c = ar.Announce_Override__c;
			        clientActivity.Category__c = ar.Category__c;
			        clientActivity.WS_Cost__c = ar.WS_Cost__c;
			        clientActivity.Price_Tier__c = ar.Price_Tier__c;
			        clientActivity.Episode_Price__c = ar.Episode_Price__c;
			        clientActivity.Episode_Price_Tier__c = ar.Episode_Price_Tier__c;
			        if(ar.Announcement__r.Full_Extract__c == true)
			           clientActivity.Announce_Override__c = 'Suppress';
			        clientActivityList.add(clientActivity);
			   }
          		
          		
          	}
          	Boolean isModified = WB_PriceUtility.announcementRecordChanges(ar);
          	if(isModified){
          	   clientActivityList.add(ar);
          	}
          	System.debug(LoggingLevel.INFO,'Within PreOrder clientActivityList:'+clientActivityList);
         }
          
        integer count =0;
        if(clientActivityList.size() > 0){
        	Map<Id,String> caErrorMap = new Map<Id,String>();
			List<Client_Avail__c> caErrorList = new  List<Client_Avail__c>();
			WB_ClientAvailPriceHandler.recursiveInsert = true;
			Database.UpsertResult[] upsertResult_CActivity = Database.upsert(clientActivityList, false);
			for(Integer index = 0; index < upsertResult_CActivity.size();index++){
			
				Database.UpsertResult insertResult = upsertResult_CActivity[index];
				if(!insertResult.isSuccess()){
					String errorMessage = '';
					Id caId;
					for(Database.Error err : insertResult.getErrors()) {
			            errorMessage += err.getMessage();
			        }
					caId = clientActivityList[index].Client_Avail__c;
					if(!caErrorMap.containsKey(caId))
			            caErrorMap.put(caId, errorMessage);
			        
				}
			}
			
			For(Database.UpsertResult s : upsertResult_CActivity){
            if(s.isSuccess())
                count++;
            else
                system.debug(s.getErrors());
            }
			
			
			if(caErrorMap != null && caErrorMap.size()>0){
				WB_compareLastAndFromDates1.createErrorLog(caErrorMap,'	PreOrder');
			}
        }
        
         
    }
    
    public void setAnnouncementRecordValues(Announcement_Record__c clientActivity,Announcement_Record__c annRec,Map<Id,Client_Avail__c> caMap,Client_Avail_Price__c cap){
    	
    	clientActivity.Pre_Order_Date__c = caMap.get(annRec.Client_Avail__r.Id).APO_Date__c;
    	clientActivity.Sales_Channel__c= 'PO'+caMap.get(annRec.Client_Avail__r.Id).EMA_LicenseType__c;
        clientActivity.EMA_License_Type__c = clientActivity.Sales_Channel__c;
        clientActivity.Announce_Override__c = annRec.Announce_Override__c;
        clientActivity.Category__c = caMap.get(annRec.Client_Avail__r.Id).Local_Data_Category_Picklist__c;
        
        //CAP values
        clientActivity.Client_Avail_Price__c = cap.Id;
        clientActivity.WS_Cost__c = cap.Price__c;
        clientActivity.Price_Tier__c = cap.Price_Tier__c;
        clientActivity.Episode_Price__c = cap.Episode_Price__c;
        clientActivity.Episode_Price_Tier__c= cap.Episode_Price_Tier__c;
        clientActivity.Client_Start__c = cap.Effective_Date__c;
        clientActivity.Client_End__c = cap.Expiry_Date__c;
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
    /*if(annNew.File_Format__c=='CSV' && annNew.Announcement_Record_Count__c < 2000){
          ann.File_Status__c = 'Ready';
    }*/ if(annNew.Announcement_Record_Count__c > WB_Announcement_Util.XLS_LIMIT || (annNew.File_Format__c=='CSV' && annNew.Announcement_Record_Count__c > WB_Announcement_Util.CSV_LIMIT)){
          ann.File_Status__c = 'Ready';
    }else {
          ann.File_Status__c = 'Pending';
    }
    annoucementListUpdate.add(ann);
    
   }
        
    update annoucementListUpdate;  
    if (!Test.IsRunningTest()){
    	String batchInstanceId = Database.executeBatch(new WB_GenerateReportBatchProcess (announementIdSet), 10);
    	if(!batchInstanceId.startsWith('707')){
    		batchInstanceId = Database.executeBatch(new WB_GenerateReportBatchProcess (announementIdSet), 10);
    		if(!batchInstanceId.startsWith('707')){
    			generateCASErrorLog('Announcement Error','Announcement__c','WB_Announcement_PreOrders : Flex Queue Lock Issue - Database.executeBatch() returns 000000000000000',announementIdSet);
    		}
    	}
    }
    
  
   }
	public static void generateCASErrorLog(String errorCategory,String objectName,String errorDescription, set<Id> announementIdSet){
        
        WB_CAS_ErrorLogger.ErrorLog casErrorLog = new  WB_CAS_ErrorLogger.ErrorLog();
        casErrorLog.errorCategory = errorCategory;
        casErrorLog.objectName = objectName;
        casErrorLog.errorDescription = errorDescription;
        casErrorLog.errorDescriptionLong = 'Error Announcement Ids: '+String.join(new List<Id>(announementIdSet),',');
        WB_CAS_ErrorLogger.logError(casErrorLog); 
    }
    
    
}