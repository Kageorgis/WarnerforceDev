/*******************************************************************************************************************************************
* File Name     :   WB_ECTracker
* Description   :   Handler class for WB_ECTrackerTrigger
* @author       :   Dennis Cho
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
*                                               ER-776 
* 1.0     16 Aug 2017       Dennis Cho          Handler class to populate Title and Local Data on creation of EC Tracker.
* 2.0     12 Feb 2019		Dennis Cho			Populate EC Tracker Long Synopsis from Title level Synopsis
********************************************************************************************************************************************/

public class WB_ECTracker {
    
    public static void insertECTracker(List<EC_Tracker__c> lstTrackers){
		
        Title__c derivedTitle = new Title__c();
        Local_Title__c derivedLD = new Local_Title__c();
        
        Set<Id> mpmIdSet = new Set<Id>();
        Set<Id> titleIdSet = new Set<Id>();
        for(EC_Tracker__c Tracker : lstTrackers)
            mpmIdSet.add(Tracker.MPM__c);
        
        List<Title__c> seasonTitleList = [SELECT Id, Name, MPM__c, Synopsis__c from Title__c where MPM__c IN :mpmIdSet and Content_Type__c = 'Season' and 
									Digital_Planning__c = 'Yes' and (NOT Name Like '%3D%') and (NOT Name Like '%UHD%') and 
									(NOT Name Like '%BD%') and (NOT Name Like '%VR%')];
        
        List<Title__c> featureTitleList = [SELECT Id, Name, MPM__c, Synopsis__c from Title__c where MPM__c IN :mpmIdSet and Content_Type__c = 'Feature' and 
									Digital_Planning__c = 'Yes' and (NOT Name Like '%3D%') and (NOT Name Like '%UHD%') and 
									(NOT Name Like '%BD%') and (NOT Name Like '%VR%')];
        
        for(Title__c title : seasonTitleList)
            titleIdSet.add(title.Id);
        
        for(Title__c title : featureTitleList)
            titleIdSet.add(title.Id);
        
        List<Local_Title__c> ldList = [SELECT Id, Name, Short_Synopsis__c, Local_Synopsis__c, Copyright__c, Title__c from Local_Title__c where Title__c IN :titleIdSet
                                 and Country__r.Name = 'USA' and Language__r.Name = 'English' and External_Company__c = Null];
        
        for(EC_Tracker__c Tracker : lstTrackers) {         
            DerivedTitle = null;
            DerivedLD = null; 
            system.debug('------Tracker_insert---------'+Tracker.Name);
            system.debug('------MPM_insert---------'+Tracker.MPM_Short_Description__c);
            if (!Tracker.MPM_Short_Description__c.contains('UNEXPLODED'))  {
                if (Tracker.Release_Type__c == 'Franchise - TV' || 
                    Tracker.Release_Type__c == 'Franchise - Family & Animation DTV (Episodic)') {
                	for(Title__c title : seasonTitleList){
                    	if(title.MPM__c == Tracker.MPM__c){
                        	derivedTitle = title;
                            break;
                        }
                	}
                }
                else {
                    for(Title__c title : featureTitleList){
                        if(title.MPM__c == Tracker.MPM__c){
                        	derivedTitle = title;
                        	break;
                        }
                    }
                }
                if (DerivedTitle != null){
                    for(Local_Title__c ld : ldList)
                        if(DerivedTitle.Id == ld.Title__c){
                    		derivedLD = ld;
                            break;
                        }
                }
            }
            if (derivedTitle != null){
            	Tracker.Title__c = derivedTitle.Id;
                Tracker.Long_Synopsis__c = derivedTitle.Synopsis__c;
                system.debug('------DerivedTitle_insert---------'+derivedTitle.Name);
        	}
        	if (derivedLD != null){
            	Tracker.Local_Data__c = derivedLD.Id;
                Tracker.Short_Synopsis__c = derivedLD.Short_Synopsis__c;
                Tracker.Copyright__c = derivedLD.Copyright__c;
                system.debug('------DerivedLD_insert---------'+derivedLD.Name);
            }   
        }
    }
    
        public static void updateECTracker(List<EC_Tracker__c> lstTrackers){
		
            Title__c derivedTitle = new Title__c();
            Local_Title__c derivedLD = new Local_Title__c();
            
            Set<Id> titleIdSet = new Set<Id>();
            for(EC_Tracker__c Tracker : lstTrackers)
                titleIdSet.add(Tracker.Title__c);
                                                                                          
            List<Title__c> TitleList = [SELECT Id, Synopsis__c from Title__c where Id IN :titleIdSet];
            
            List<Local_Title__c> ldList = [SELECT Id, Name, Short_Synopsis__c, Local_Synopsis__c, Copyright__c, Title__c from Local_Title__c where Title__c IN :titleIdSet
                                     and Country__r.Name = 'USA' and Language__r.Name = 'English' and External_Company__c = Null];
            
            for(EC_Tracker__c Tracker : lstTrackers) {         
                derivedTitle = null;
                DerivedLD = null; 
                system.debug('------Tracker_update---------'+Tracker.Name);
                if (Tracker.Title__c != null){
                    for (Title__c tl : Titlelist)
                        if (Tracker.Title__c == tl.Id){
                            derivedTitle = tl;
                            break;
                        } 		
                    for(Local_Title__c ld : ldList)
                        if(Tracker.Title__c == ld.Title__c){
                            derivedLD = ld;
                            break;
                        }
                	Tracker.Long_Synopsis__c = derivedTitle.Synopsis__c;
                }                
                if (derivedLD != null){
                    Tracker.Local_Data__c = derivedLD.Id;
                    Tracker.Short_Synopsis__c = derivedLD.Short_Synopsis__c;
                    Tracker.Copyright__c = derivedLD.Copyright__c;
                    system.debug('------DerivedLD_update---------'+derivedLD.Name);
                }
                else {
                	Tracker.Local_Data__c = null;
                    Tracker.Short_Synopsis__c = null;
                    }
            }
        }   
}