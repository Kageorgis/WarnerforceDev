global without sharing class WB_Announcement_Collections implements Database.Batchable<sObject>, database.stateful{
    
    global String Query ; 
    list<Announcement__c> annList= new list<Announcement__c>();
    set<Id> announementIdSet = new set<Id>() ; 
    List<Announcement_Rule__c> announcementRuleList = new List<Announcement_Rule__c>();
    global Map<String,Collection_Announcement_Record__c> collAnnSet = new Map<String,Collection_Announcement_Record__c>();
    global List<Collection_Announcement_Record__c> collAnnList = new List<Collection_Announcement_Record__c>();
	
	List<Announcement_Trigger_Field__c> annFieldsList = null;
    global WB_Announcement_Collections(list<Announcement__c> annList, List<Announcement_Rule__c> announcementRuleList, set<Id> announementIdSet,List<Announcement_Trigger_Field__c> annFields){
        this.annList = annList;
        this.announementIdSet = announementIdSet;
        this.announcementRuleList = announcementRuleList;
        annFieldsList = annFields;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        String Query = 'SELECT Id, Announcement__c, Client_Avail__c, Client_Avail__r.Client__c, Client_Avail__r.Id, Client_Avail__r.Title_Video_Version__c, Client_Avail__r.Release_Plan_Country__c, Status__c, Playlist__c FROM Announcement_Record__c WHERE Playlist__c != null AND Announcement__c IN :annList';
        return Database.getQueryLocator(Query);
    }
                            
    global void execute(Database.BatchableContext BC, list<Announcement_Record__c> scope){
        
        Map<Id,Announcement_Record__c> clinetAvailIdAnnRec = new Map<Id,Announcement_Record__c>();
        Set<Id> collectionClinetAvailIds = new Set<Id>();
        Set<Id> collectionTitleIds = new Set<Id>();
        Set<Id> componentTitleIds = new Set<Id>();
        Set<Id> clientId = new Set<Id>();
        Set<String> subKey = new Set<String>();
        //ER-006817 
		 Set<String> stAccounts = new Set<String>();
         Set<String> stCountries = new Set<String>();
         Set<String> stLanguages = new Set<String>();
         Set<String> stChannels = new Set<String>();
         Set<String> stFormats = new Set<String>();
        
        Set<Id> allCAIds = new Set<Id>();
        Set<Id> allPlaylistIds = new Set<Id>();
        for(Announcement_Record__c ar1 : scope) {
            allCAIds.add(ar1.Client_Avail__c);
            clinetAvailIdAnnRec.put(ar1.Client_Avail__c,ar1);
            if(ar1.Playlist__c != null)
                allPlaylistIds.add(ar1.Playlist__c);
        }
		
        for(Client_Avail__c allCA : [SELECT Id,Client__c,AccountF__c,Commercial_Avail__r.Title__r.Id,CA_Content_Type__c,Release_Plan_Country__c,Release_Plan_Language__c,RP_Language_Type__c,Release_Plan_Channel__c,Release_Plan_Format__c FROM Client_Avail__c WHERE id IN :allCAIds]){
            if(String.valueOf(allCA.CA_Content_Type__c).contains('Collection')){
                collectionClinetAvailIds.add(allCA.Id);
                collectionTitleIds.add(allCA.Commercial_Avail__r.Title__r.Id);
                subKey.add(allCA.AccountF__c+'_'+allCA.Release_Plan_Country__c+'_'+allCA.Release_Plan_Language__c+'_'+allCA.RP_Language_Type__c+'_'+allCA.Release_Plan_Channel__c+'_'+allCA.Release_Plan_Format__c);
                    //ER-006817 
                   stAccounts.add(allCA.AccountF__c);
                   stCountries.add(allCA.Release_Plan_Country__c);
                   stLanguages.add(allCA.Release_Plan_Language__c);
                   stChannels.add(allCA.Release_Plan_Channel__c);
                   stFormats.add( allCA.Release_Plan_Format__c);                       
                    //ER-006817     

            }
        }

        List<Playlist__c> playlistTitles = [SELECT Id,Parent_Title__c,Version_Number__c,(SELECT Id,Content_Title__c,Content_Title__r.Id,Content_VV__c FROM Playlist_Content__r) FROM Playlist__c WHERE Parent_Title__r.Id IN :collectionTitleIds AND Id IN :allPlaylistIds];
        for(Playlist__c pt : playlistTitles)
            for(Playlist_Content__c pc : pt.Playlist_Content__r)
                componentTitleIds.add(pc.Content_Title__r.Id);

        List<Client_Avail__c> collectionClinetAvails = [SELECT id,AccountF__c,Commercial_Avail__r.Title__r.Id,Release_Plan_Title__c,Title_Video_Version__c,Client_Title_ID__c,Release_Plan_Country__c,Release_Plan_Language__c,Release_Plan_Channel__c,Release_Plan_Format__c,UPC__c,RP_Language_Type__c FROM Client_Avail__c WHERE Id IN :collectionClinetAvailIds AND SubKey__c IN :subKey AND CA_Lifecycle__c like 'Active%'];  
       //ER-006817--Start--   List<Client_Avail__c> componentClinetAvails = [SELECT id,AccountF__c,Commercial_Avail__r.Title__r.Id,Release_Plan_Title__c,Title_Video_Version__c,Client_Title_ID__c,Release_Plan_Country__c,Release_Plan_Language__c,Release_Plan_Channel__c,Release_Plan_Format__c,UPC__c FROM Client_Avail__c WHERE Commercial_Avail__r.Title__r.Id IN :componentTitleIds AND SubKey__c IN :subKey AND CA_Lifecycle__c like 'Active%'];        
        List<Client_Avail__c> componentClinetAvails = [SELECT id,AccountF__c,Commercial_Avail__r.Title__r.Id,Release_Plan_Title__c,Title_Video_Version__c,Client_Title_ID__c,Release_Plan_Country__c,Release_Plan_Language__c,Release_Plan_Channel__c,Release_Plan_Format__c,UPC__c FROM Client_Avail__c WHERE Commercial_Avail__r.Title__r.Id IN :componentTitleIds AND
                                                       AccountF__c IN :stAccounts
                                                       AND Release_Plan_Country__c IN :stCountries
                                                       AND Release_Plan_Language__c IN :stLanguages
                                                       AND Release_Plan_Channel__c IN :stChannels
                                                       AND Release_Plan_Format__c IN :stFormats
                                                       AND CA_Lifecycle__c like 'Active%'];        
        // SubKey__c IN :subKey
        //ER-006817--End--
       
       /*ER-006817
        Map<Id,Playlist_Content__c> pcMap = new Map<Id,Playlist_Content__c>([SELECT Id,Playlist__r.Parent_Title__r.Id,Content_Title__r.Id FROM Playlist_Content__c WHERE Content_Title__r.Id IN :componentTitleIds]);
        */
        Set<Id> stPlstCntParentTitle = new Set<Id>();

        for(Playlist_Content__c pc : [SELECT Id,Playlist__r.Parent_Title__r.Id,Content_Title__r.Id FROM Playlist_Content__c WHERE Content_Title__r.Id IN :componentTitleIds]){
            stPlstCntParentTitle.add(pc.Playlist__r.Parent_Title__r.Id);
        }
        


        for(Client_Avail__c coll : collectionClinetAvails){
            for(Client_Avail__c comp : componentClinetAvails){
            //ER-006817    for(Playlist_Content__c pc : pcMap.values()){
               
                //if(comp.Commercial_Avail__r.Title__r.Id == coll.Commercial_Avail__r.Title__r.Id && comp.AccountF__c == coll.AccountF__c && comp.Release_Plan_Country__c == coll.Release_Plan_Country__c && comp.Release_Plan_Language__c == coll.Release_Plan_Language__c && comp.Release_Plan_Channel__c == coll.Release_Plan_Channel__c && comp.Release_Plan_Format__c == coll.Release_Plan_Format__c){
                    if(stPlstCntParentTitle.contains(coll.Commercial_Avail__r.Title__r.Id) && comp.AccountF__c == coll.AccountF__c && comp.Release_Plan_Country__c == coll.Release_Plan_Country__c && comp.Release_Plan_Language__c == coll.Release_Plan_Language__c && comp.Release_Plan_Channel__c == coll.Release_Plan_Channel__c && comp.Release_Plan_Format__c == coll.Release_Plan_Format__c){

                    Collection_Announcement_Record__c collAnnRec = new Collection_Announcement_Record__c();
                    collAnnRec.Announcement__c = clinetAvailIdAnnRec.get(coll.Id).Announcement__c;
                    collAnnRec.Collection_Client_Avail_Id__c = clinetAvailIdAnnRec.get(coll.Id).Client_Avail__c;
                    collAnnRec.Account__c = coll.AccountF__c;
                    collAnnRec.Collection_Title__c = coll.Release_Plan_Title__c;
                    collAnnRec.Collection_Video_Version__c = coll.Title_Video_Version__c;
                    collAnnRec.Collection_UPC__c = coll.UPC__c;
                    collAnnRec.Collection_Retailer_Product_ID__c = coll.Client_Title_ID__c;
                    collAnnRec.Country__c = coll.Release_Plan_Country__c;
                    collAnnRec.Sales_Channel__c = coll.Release_Plan_Channel__c;
                    collAnnRec.Format__c = coll.Release_Plan_Format__c;
                    collAnnRec.Component_Title__c = comp.Release_Plan_Title__c;
                    collAnnRec.Component_Video_Version__c = comp.Title_Video_Version__c;
                    collAnnRec.Component_UPC__c = comp.UPC__c;
                    collAnnRec.Component_Retailer_Product_ID__c = comp.Client_Title_ID__c; 
                    collAnnRec.Component_Client_Avail_Id__c = comp.Id;
                    String strKey = collAnnRec.Account__c+collAnnRec.Collection_Title__c+collAnnRec.Collection_Video_Version__c+collAnnRec.Collection_Retailer_Product_ID__c+collAnnRec.Country__c+collAnnRec.Sales_Channel__c+collAnnRec.Format__c+collAnnRec.Component_Title__c+collAnnRec.Component_Video_Version__c+coll.Release_Plan_Language__c+coll.RP_Language_Type__c;
			
                    collAnnSet.put(strKey,collAnnRec);
                    //collAnnRec.Account__c+collAnnRec.Collection_Title__c+collAnnRec.Collection_Video_Version__c+collAnnRec.Collection_Retailer_Product_ID__c+collAnnRec.Country__c+collAnnRec.Sales_Channel__c+collAnnRec.Format__c+collAnnRec.Component_Title__c+collAnnRec.Component_Video_Version__c
                }
               // }
            }
        }
        
   }


   global void finish(Database.BatchableContext BC){
       
              
        collAnnList = collAnnSet.values();
		
		WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.Saveresult[] saveResult_collAnnList  = Database.insert(collAnnList, false);
		
		String batchId;
        if(announcementRuleList[0].Full_Extract__c == true)
            batchId = Database.executeBatch(new WB_Announcement_Full_Extract1 (annList,announcementRuleList,announementIdSet,annFieldsList), 200);
        else
          	batchId = Database.executeBatch(new WB_Announcement_PreOrders (annList,announcementRuleList,announementIdSet,annFieldsList), 200);
       
        if(!batchId.startsWith('707')){ 
       		if(announcementRuleList[0].Full_Extract__c == true)
	            batchId = Database.executeBatch(new WB_Announcement_Full_Extract1 (annList,announcementRuleList,announementIdSet,annFieldsList), 200);
	        else
	          	batchId = Database.executeBatch(new WB_Announcement_PreOrders (annList,announcementRuleList,announementIdSet,annFieldsList), 200);
       
       		if(!batchId.startsWith('707'))
                WB_Announcement_PreOrders.generateCASErrorLog('Announcement Error','Announcement__c','WB_Announcement_Collections : Flex Queue Lock Issue - Database.executeBatch() returns 000000000000000',announementIdSet);
        }
       // else 
           // Database.executeBatch(new WB_Announcement_Pre_Orders (annList,announcementRuleList,announementIdSet), 200);  
   }

}