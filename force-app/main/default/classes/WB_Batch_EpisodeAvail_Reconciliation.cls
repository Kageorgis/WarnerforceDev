global class WB_Batch_EpisodeAvail_Reconciliation implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    String query = null;
    
    
    /* Start ******** Scheduler Methods************/ 
    global WB_Batch_EpisodeAvail_Reconciliation(){
        
    }
    
    global void execute (SchedulableContext ctx){
        Database.executeBatch(new WB_Batch_EpisodeAvail_Reconciliation('Episode Reconciliation'),5);      
    }
    
    /* End ******* Scheduler Methods************ */
    
    
    global WB_Batch_EpisodeAvail_Reconciliation(String name){
        
        /*
        	Select Id,Name,Title_Content_Type__c,Title_Video_Version__c,Release_Plan_Title__c,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,Release_Plan_Format__c, Release_Plan_Language__c, RP_Language_Type__c, Local_Data_Category_Picklist__c, Price__c,Price_Tier_Text__c,Status__c,Start_Date__c,End_Date__c   From Client_AVail__c Where Title_Content_Type__c = 'Episode'  AND END_DATE__c > TODAY  AND Parent_Client_Avail__c != null  AND Status__c = 'Draft'  AND Parent_Client_Avail__r.Local_Data_Category_Picklist__c IN ('TV Day After US','TV Day After Local')  AND  ((Local_Data_Category_Picklist__c = 'TV Day After Local' AND Local_Title__r.Local_TV_Air_Date__c != null) OR  (Local_Data_Category_Picklist__c = 'TV Day After US' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null) OR  (Local_Title__r.Category__c = 'TV Day After Local' AND Local_Title__r.Local_TV_Air_Date__c != null) OR  (Local_Title__r.Category__c = 'TV Day After US' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null)  )  AND Parent_Client_Avail__r.Status__c IN ('Tentative','Confirmed')  AND Price_Tier_Text__c != 'TBD'  AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future') 
        	
        */
        query = 'Select Id,Name,Local_Data_Category_Picklist__c,Start_Date__c,Status__c,Price_Tier_Text__c,Price__c, '+
        			'Local_Title__r.Title__r.US_TV_Air_Date__c,Local_Title__r.Country__r.TV_Day_After_US_Offset__c, '+
        			'Local_Title__r.Local_TV_Air_Date__c,Local_Title__r.Country__r.TV_Day_After_Local_Offset__c, '+
        			'Parent_Client_Avail__r.Status__c,Parent_Client_Avail__r.Start_Date__c,Parent_Client_Avail__r.End_Date__c,Parent_Client_Avail__c,Parent_Client_Avail__r.Local_Data_Category_Picklist__c '+
        			' From Client_AVail__c Where Title_Content_Type__c = \'Episode\' '+ 
                    ' AND END_DATE__c > TODAY '+
                    ' AND Parent_Client_Avail__c != null '+ 
                    ' AND Status__c = \'Draft\' '+ 
                    ' AND Parent_Client_Avail__r.Local_Data_Category_Picklist__c IN (\'TV Day After US\',\'TV Day After Local\') '+ 
                    ' AND '+
                    ' ((Local_Data_Category_Picklist__c = \'TV Day After Local\' AND Local_Title__r.Local_TV_Air_Date__c != null) OR '+  
                     ' (Local_Data_Category_Picklist__c = \'TV Day After US\' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null) '+
                   //  ' (Local_Title__r.Category__c = \'TV Day After Local\' AND Local_Title__r.Local_TV_Air_Date__c != null) OR '+
                   //  ' (Local_Title__r.Category__c = \'TV Day After US\' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null) '+
                    ' ) '+
                    ' AND Parent_Client_Avail__r.Status__c IN (\'Tentative\',\'Confirmed\') '+
                    ' AND Price_Tier_Text__c != \'TBD\' '+
                    ' AND (CA_LifeCycle__c = \'Active Current\' OR CA_LifeCycle__c = \'Active Future\') ';
                
        System.debug(LoggingLevel.INFO,'Query :'+query);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Printing Query-->>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Client_AVail__c> scope){
        
        Date compareDate = Date.newInstance(2049, 12, 31);
        List<Client_AVail__c> caTobeUpdated = new List<Client_AVail__c>();
        
        for(Client_AVail__c ca : scope){
        	Date airDate = null;
        	
            if(ca.Parent_Client_Avail__c != null){
            	
            	String parentCategory = ca.Parent_Client_Avail__r.Local_Data_Category_Picklist__c;
            	
            	if(!(parentCategory == 'TV Day After US' || parentCategory == 'TV Day After Local'))
            		continue;
            	
                if(ca.Local_Data_Category_Picklist__c == 'TV Day After US' && ca.Local_Title__r.Title__r.US_TV_Air_Date__c != null ){
                    airDate = ca.Local_Title__r.Title__r.US_TV_Air_Date__c  + ((ca.Local_Title__r.Country__r.TV_Day_After_US_Offset__c != null) ? Integer.valueof(ca.Local_Title__r.Country__r.TV_Day_After_US_Offset__c) : 0);
                }
                else if(ca.Local_Data_Category_Picklist__c == 'TV Day After Local' && ca.Local_Title__r.Local_TV_Air_Date__c != null ){
                    airDate = ca.Local_Title__r.Local_TV_Air_Date__c + ((ca.Local_Title__r.Country__r.TV_Day_After_Local_Offset__c != null) ? Integer.valueof(ca.Local_Title__r.Country__r.TV_Day_After_Local_Offset__c) : 0);
                }
                    
               if(airDate != null && airDate != compareDate && airdate <= ca.Parent_Client_Avail__r.End_Date__c){
                    if(airdate >= ca.Parent_Client_Avail__r.Start_Date__c)
                        ca.Start_Date__c = airDate;
                    else
                        ca.Start_Date__c = ca.Parent_Client_Avail__r.Start_Date__c;
                        
                    ca.Status__c = ca.Parent_Client_Avail__r.Status__c;
                    
                    caTobeUpdated.add(ca);      
               }
                   
            }
            
        }
        
        if(caTobeUpdated.size() > 0)
        	Database.update(caTobeUpdated, false);
        
    }
    
    global void finish(Database.BatchableContext BC){
        
       
    }
}