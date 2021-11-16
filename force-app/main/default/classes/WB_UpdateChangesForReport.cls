/*
Handler used : WB_ClientAvailDateOverlap.trigger
Description : It is used to update 'Changes' and 'Last Run' fields on client avail.
              Last Run will get value of the Last Run of the 'Client Avails with Account-Title' report.
              Changes field will het updated when any of the following field gets updated.
                1.  Country             - Release Plan      
                2.  Rating Required     - Country
                3.  Local Rating        - Local Data                    Done
                4.  Rating Compliance   - Release Plan & Local Data
                5.  Local Title         - Client_Avail                  Done
                6.  Price Tier          - Client_Avail                  Done
                7.  Format              - Release Plan
                8.  Local Theatrical Release Date   - Local Data        Done
                9.  APO Date (Pre-Order Date)       - Client_Avail      Done
                10. Suppression End Date            - Client_Avail      Done
                11. Vid Number (for Account = Apple)- Client_Avail      
                12. EST Date (Client Start date)    - Client_Avail      Done

*/

public class WB_UpdateChangesForReport {
    
    
    // For following fields on client avail : 
    // Local Title, Price Tier, APO Date, Suppression End Date, EST Date
    public static void updateLastRunChange(List<Client_Avail__c> newList, map<Id, Client_Avail__c> oldMap)
    {
        set<Id> clientAvailIdSet = new set<Id>();
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        
        for (Client_Avail__c objCA : newList) {
            Client_Avail__c oldCA = oldMap.get(objCA.Id);
            if(objCA.APO__c == 'Yes' && 
              (objCA.Price_Tier_Text__c != oldCA.Price_Tier_Text__c || objCA.APO_Date__c != oldCA.APO_Date__c || objCA.Start_Date__c != oldCA.Start_Date__c
                || objCA.Announce_Date__c != oldCA.Announce_Date__c || objCA.Local_Title__c != oldCA.Local_Title__c)) {
                clientAvailList.add(objCA);
            } 
        }
        //system.debug('------clientAvailList---ss----'+clientAvailList);
        
        if(clientAvailList.size() > 0) {
            Map<Id,Report> reportListMap = new Map<Id,Report>([Select Id, Name, DeveloperName, lastRunDate from Report where Id =: Label.APO_Client_Avail_Report]);
            List<Report> reportList = reportListMap.values();
            
            if(reportList.size() > 0) {
                
                for(Client_Avail__c objCA : clientAvailList) {
                    
                    Client_Avail__c oldCA = oldMap.get(objCA.Id);
                    if(objCA.Last_Run__c != reportList[0].lastRunDate) {
                        objCA.Last_Run__c = reportList[0].lastRunDate;          // Updated the Last Run
                        objCA.Changes__c = null;
                    }
                    
                    if(oldCA != null) {
                        if(objCA.Last_Run__c == reportList[0].lastRunDate) {
                            if(objCA.Price_Tier_Text__c != oldCA.Price_Tier_Text__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Price Tier') ? objCA.Changes__c : objCA.Changes__c + ', Price Tier') : 'Price Tier');
                            }
                            if(objCA.APO_Date__c != oldCA.APO_Date__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('APO Date') ? objCA.Changes__c : objCA.Changes__c + ', APO Date') : 'APO Date');
                            }
                            if(objCA.Start_Date__c != oldCA.Start_Date__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Start Date') ? objCA.Changes__c : objCA.Changes__c + ', Start Date') : 'Start Date');
                            }
                            if(objCA.Announce_Date__c != oldCA.Announce_Date__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Suppression End Date') ? objCA.Changes__c : objCA.Changes__c + ', Suppression End Date') : 'Suppression End Date');
                            }
                            if(objCA.Local_Title__c != oldCA.Local_Title__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Local Title') ? objCA.Changes__c : objCA.Changes__c + ', Local Title') : 'Local Title');
                            }
                        }
                    }
                }
            }
        }
    }
    
    // For following fields on Local Data : 
    // Local Rating, Local Theatrical Release Date
    public static void updateChangesByLocalData(List<Local_Title__c> newList, map<Id, Local_Title__c> oldMap)
    {
        set<Id> setLocalTitleId = new set<Id>();
        List<Local_Title__c> localTitleList = new List<Local_Title__c>();
        
        integer count = 0;
        for(Local_Title__c objLocal : newList) {
            Local_Title__c oldLocal = oldMap.get(objLocal.Id);
            if(objLocal.Local_Rating__c != oldLocal.Local_Rating__c || objLocal.Local_Theatrical_Release_Date__c != oldLocal.Local_Theatrical_Release_Date__c){
                setLocalTitleId.add(objLocal.Id);
                localTitleList.add(objLocal);
                if(objLocal.Local_Theatrical_Release_Date__c != oldLocal.Local_Theatrical_Release_Date__c){
                    count ++;
            	}
        	}
        }
        if(setLocalTitleId.size() > 0) {
            Map<Id,Report> reportListMap = new Map<Id,Report>([Select Id, Name, DeveloperName, lastRunDate from Report where Id =: Label.APO_Client_Avail_Report]);
            List<Report> reportList = reportListMap.values();
            
            if(reportList.size() > 0) {
                Map<Id,Client_Avail__c> clientAvailListMap = new Map<Id,Client_Avail__c>([Select Id, Changes__c, Local_Title__c, Last_Run__c from Client_Avail__c where Local_Title__c IN: setLocalTitleId]);
                List<Client_Avail__c> clientAvailList = clientAvailListMap.values();
                
                map<Id, List<Client_Avail__c>> mapIdToClientAvailList = new map<Id, List<Client_Avail__c>>();
                for(Client_Avail__c objCA : clientAvailList){
                    List<Client_Avail__c> lstCA = new List<Client_Avail__c>();
                    if(mapIdToClientAvailList.containsKey(objCA.Local_Title__c)) {
                        lstCA = mapIdToClientAvailList.get(objCA.Local_Title__c);
                        lstCA.add(objCA);
                    } else {
                        lstCA.add(objCA);
                    }
                    mapIdToClientAvailList.put(objCA.Local_Title__c, lstCA);
                }
                //system.debug('------mapIdToClientAvailList-------'+mapIdToClientAvailList);
                
                List<Client_Avail__c> updatedClientAvailList = new List<Client_Avail__c>();
                for(Local_Title__c objLT : localTitleList) {
                    if(mapIdToClientAvailList.containsKey(objLT.Id)) {
                        
                        Local_Title__c oldLT = oldMap.get(objLT.Id);
                        List<Client_Avail__c> CAlist = mapIdToClientAvailList.get(objLT.Id);
                        
                        for(Client_Avail__c objCA : CAlist) {
                            
                            if(objCA.Last_Run__c != reportList[0].lastRunDate) {
                                objCA.Last_Run__c = reportList[0].lastRunDate;          // Updated the Last Run
                                objCA.Changes__c = null;
                            }
                            if(oldLT != null && objLT.Local_Rating__c != oldLT.Local_Rating__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Local Rating') ? objCA.Changes__c : objCA.Changes__c + ', Local Rating') : 'Local Rating');
                            }
                            if(oldLT != null && objLT.Local_Theatrical_Release_Date__c != oldLT.Local_Theatrical_Release_Date__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Local Theatrical Release Date') ? objCA.Changes__c : objCA.Changes__c + ', Local Theatrical Release Date') : 'Local Theatrical Release Date');
                            }
                            updatedClientAvailList.add(objCA);
                        }
                    }
                }
                
                Boolean bypassFlag = (UserInfo.getName()==Label.SFDC_Integration_User && count == 0) ? true : false;
                if(bypassFlag){
                     WB_ClientAvailPriceHandler.recursiveUpdate = true;//WBTINC0207320 
                }
                database.update(updatedClientAvailList, false);
                if(WB_ClientAvailPriceHandler.recursiveUpdate){
                	WB_ClientAvailPriceHandler.recursiveUpdate = false;
            	}
        	}
    	}
    }
    
/*
    public static void updateChangesByReleasePlan(List<Commercial_Avail__c> newList, map<Id, Commercial_Avail__c> oldMap){
        
        set<Id> setReleasePlanId = new set<Id>();
        List<Commercial_Avail__c> releasePlanList = new List<Commercial_Avail__c>();
        
        for(Commercial_Avail__c objRP : newList) {
            Commercial_Avail__c oldRP = oldMap.get(objRP.Id);
            if(objRP.Format__c != oldRP.Format__c || objRP.Country_Lookup__c != oldRP.Country_Lookup__c){
                setReleasePlanId.add(objRP.Id);
                releasePlanList.add(objRP);
            }
        }
        system.debug('------setReleasePlanId-------'+setReleasePlanId);
        
        if(setReleasePlanId.size() > 0) {
            List<Report> reportList = [Select Id, Name, DeveloperName, lastRunDate from Report where DeveloperName =: 'Client_Avails_with_Account_Title'];
            
            if(reportList.size() > 0) {
                List<Client_Avail__c> clientAvailList = [Select Id, Changes__c, Last_Run__c, Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c IN: setReleasePlanId];
                
                map<Id, List<Client_Avail__c>> mapIdToClientAvailList = new map<Id, List<Client_Avail__c>>();
                for(Client_Avail__c objCA : clientAvailList){
                    List<Client_Avail__c> lstCA = new List<Client_Avail__c>();
                    if(mapIdToClientAvailList.containsKey(objCA.Commercial_Avail__c)) {
                        lstCA = mapIdToClientAvailList.get(objCA.Commercial_Avail__c);
                        lstCA.add(objCA);
                    } else {
                        lstCA.add(objCA);
                    }
                    mapIdToClientAvailList.put(objCA.Commercial_Avail__c, lstCA);
                }
                system.debug('------mapIdToClientAvailList-------'+mapIdToClientAvailList);
                
                List<Client_Avail__c> updatedClientAvailList = new List<Client_Avail__c>();
                for(Commercial_Avail__c objRP : releasePlanList) {
                    if(mapIdToClientAvailList.containsKey(objRP.Id)) {
                        List<Client_Avail__c> CAlist = mapIdToClientAvailList.get(objRP.Id);
                        Commercial_Avail__c oldRP = oldMap.get(objRP.Id);
                        
                        for(Client_Avail__c objCA : CAlist) {
                            if(objCA.Last_Run__c != reportList[0].lastRunDate) {
                                objCA.Last_Run__c = reportList[0].lastRunDate;          // Updated the Last Run
                                objCA.Changes__c = null;
                            }
                            if(oldRP != null && objRP.Format__c != oldRP.Format__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Format') ? objCA.Changes__c : objCA.Changes__c + ', Format') : 'Format');
                            }
                            if(oldRP != null && objRP.Country_Lookup__c != oldRP.Country_Lookup__c) {
                                objCA.Changes__c = (objCA.Changes__c != null ? (objCA.Changes__c.contains('Country') ? objCA.Changes__c : objCA.Changes__c + ', Country') : 'Country');
                            }
                            updatedClientAvailList.add(objCA);
                        }
                    }
                }
                system.debug('------updatedClientAvailList-------'+updatedClientAvailList.size()+' - '+updatedClientAvailList);
                database.update(updatedClientAvailList, false);
            }
        }
    }
    
    public static void updateChangesByCountry(List<Country__c> newList, map<Id, Country__c> oldMap)
    {
        set<Id> setCountryId = new set<Id>();
        
        for(Country__c objCountry : newList) {
            Country__c oldCountry = oldMap.get(objCountry.Id);
            if(objCountry.Rating_Required__c != oldCountry.Rating_Required__c){
                
            }
        }
        
    }  */
    
}