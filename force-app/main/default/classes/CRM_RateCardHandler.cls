/**
   @Author-Cognizant Technology Solutions
   @name-CRM_RateCardHandler
   @CreateDate- 17 April 2018
   @Description- This Handler Apex class is used to check overlapping date logic and Storefront linking to Rate Card.
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_RateCardHandler{
    /**
    *  @Description - Method to check overlapping of Rate card dates / Link Storefront to Rate card / Set Invalid Capability flag on Rate card
    *  @name - ValidateOverlapping
    *  @return - void
    */
    public static void ValidateOverlapping(Map<Id,Rate_Card__c > mapOldRC, List<Rate_Card__c> newRCLists) {
        
        //Set of Strorefront to get "Selected Combination" List
        Set<Id> storefrontIds = new Set<Id>();
        List<Rate_Card__c> filteredRCList = new List<Rate_Card__c>();
        
        // Sets used to link Storefront to Rate Card record
        Set<Id> accountIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
    
        // Sets used to find potentially overlapping records
    	Set<String> existingKeys = new Set<String>();
    	Set<Id> existingIds = new Set<Id>();
    
    	// Add values to the sets
    	for (Rate_Card__c rc : newRCLists) {
    	    
    		existingKeys.add(rc.Combination_Key__c);
    		existingIds.add(rc.Id);
            
            //On insert fill set to link Strorefront
            if(mapOldRC == null){
                accountIds.add(rc.Account__c);
                countryIds.add(rc.Country__c);
            }
            
            //Fill Set to get Strorefront
            Rate_Card__c oldRc = mapOldRC != null ? mapOldRC.get(rc.Id) : null;
            if(oldRc != null && (rc.Content_Type__c != oldRc.Content_Type__c || rc.Format__c != oldRc.Format__c || rc.Channel__c != oldRc.Channel__c)){
                storefrontIds.add(rc.Storefront__c);
                filteredRCList.add(rc);
            }
    	}
    
        // Link Storefronts to RCs
        if(!accountIds.isEmpty() && !countryIds.isEmpty()){
            linkStorefrontToRCRecords(accountIds,countryIds,newRCLists,filteredRCList,storefrontIds);
        }
        
        // Set Invalid Capability flag on Rate card
        if(!storefrontIds.isEmpty()){
            Map<Id,Agreement__c> storefrontMap = new Map<Id,Agreement__c>([SELECT Id,Selected_Combination__c FROM Agreement__c WHERE Id IN :storefrontIds]);
            setInvalidCapabilityFlag(storefrontMap,filteredRCList);
        }
    
    	// Collate existing potential matching records into a map
    	Map<String,List<Rate_Card__c>> existingRcs = new Map<String,List<Rate_Card__c>>();
    	/*ER-002518*/
    	for (Rate_Card__c rc : [SELECT WSP1__c,Rate_Card_Type__c,Combination_Key__c, Id, Storefront__c, Content_Type__c, Channel__c,
    								Format__c, Price_Tier__c, Start_Date__c, End_Date__c, Name
    	                       FROM Rate_Card__c
    	                       WHERE Combination_Key__c IN :existingKeys
    	                       AND Id NOT IN :existingIds]) {
    		
        	if (existingRcs.containsKey(rc.Combination_Key__c)) {
        		existingRcs.get(rc.Combination_Key__c).add(rc);
        	} else {
        		existingRcs.put(rc.Combination_Key__c, new List<Rate_Card__c> {rc} );
        	}
    	}
    	// Check new / updated record to see if they overlap with other existing records
    	for (Rate_Card__c rc : newRCLists) {
    	    String key='';
    	    /*ER-002518 start*/
    	    if(rc.Rate_Card_Type__c ==  System.Label.CRM_Rate_Card_Type_WSP || rc.Rate_Card_Type__c ==  System.Label.CRM_Rate_Card_Type_WSP_Split){ // ER-002742
    	        key = String.valueOf(rc.Account__c).left(15) + '-' + String.valueOf(rc.Country__c).left(15) + '-' + rc.Channel__c + '-' +String.valueOf( rc.WSP1__c);
    	    }else{
    	        key = String.valueOf(rc.Account__c).left(15) + '-' + String.valueOf(rc.Country__c).left(15) + '-' + rc.Channel__c + '-' + rc.Price_Tier__c;
    	    }
    	    /*ER-002518 end*/
    	    if (existingRcs.containsKey(key)) {
    			for (Rate_Card__c potentialMatch : existingRcs.get(rc.Combination_Key__c)) {
    				if (checkOverlapping(rc, potentialMatch)) {
    					// If duplicate is found then add error
    					rc.addError( potentialMatch.Id == null ?
    					    System.Label.CRM_Rate_Card_Overlapping_Date_Error_With_New_RC_Message :
    					    String.format(System.Label.CRM_Rate_Card_Overlapping_Date_Error_Message,
					                      new String[] {
					                          potentialMatch.name,
					                          potentialMatch.Start_Date__c.format(),
					                          potentialMatch.End_Date__c.format()
					                      })
    					);
    					
    					// Also error the record it matches with if it's also new
    					if (potentialMatch.Id == null)
    					    potentialMatch.addError(System.Label.CRM_Rate_Card_Overlapping_Date_Error_With_New_RC_Message);
    				}
    			}
    			
    			// Add rate card to map being checked
    			existingRcs.get(key).add(rc);
    		}else{
    		    // Add rate card to map being checked
    		    existingRcs.put(key, new List<Rate_Card__c> {rc} );
    		}
    	}
    }
    
    /**
    *  @Description - Checks two rate cards and returns true if they overlap.
    *  @name - checkOverlapping
    *  @param - Rate_Card__c - First rate card record
    *  @param - Rate_Card__c - Second rate card record
    *  @return - Boolean Returns TRUE if rc1 overlaps with rc2
    */
    
    private static Boolean checkOverlapping(Rate_Card__c rc1, Rate_Card__c rc2) {
    	return rc1.Storefront__c == rc2.Storefront__c && 
    		   rc1.Price_Tier__c == rc2.Price_Tier__c && 
    	       (rc1.Content_Type__c == CRM_AppConstants.CONTENT_TYPE_OR_FORMAT_ALL_VALUE || rc2.Content_Type__c == CRM_AppConstants.CONTENT_TYPE_OR_FORMAT_ALL_VALUE || rc1.Content_Type__c == rc2.Content_Type__c) &&
    	       (rc1.Format__c == CRM_AppConstants.CONTENT_TYPE_OR_FORMAT_ALL_VALUE || rc2.Format__c == CRM_AppConstants.CONTENT_TYPE_OR_FORMAT_ALL_VALUE || rc1.Format__c == rc2.Format__c) &&
    	       rc1.Start_Date__c <= rc2.End_Date__c &&
    	       rc1.End_Date__c >= rc2.Start_Date__c;
    }
    
    /**
    * Name: linkStorefrontToRCRecords
    * Purpose: This function is used to link Storefront to RC records
    */
    private static void linkStorefrontToRCRecords(Set<Id> accountIds,Set<Id> countryIds,list<Rate_Card__c> newRCLists,List<Rate_Card__c> successRc,Set<Id> sfIds) {
        Map<String,List<Agreement__c>> mapOfAccCountryToStf = new Map<String,List<Agreement__c>>();
        
        for(Agreement__c stf : [SELECT Id,Account__c,Country__c
                                FROM Agreement__c
                                WHERE Account__c IN :accountIds AND Country__c IN :countryIds]) {
            String mapKey = stf.Account__c+'-'+stf.Country__c;
            
        	if (mapOfAccCountryToStf.containsKey(mapKey)) {
        		mapOfAccCountryToStf.get(mapKey).add(stf);
        	} else {
        		mapOfAccCountryToStf.put(mapKey, new List<Agreement__c> {stf} );
        	}
        }
        
        for(Rate_Card__c rc : newRCLists) {
            String mapKey = rc.Account__c+'-'+rc.Country__c;
            if(mapOfAccCountryToStf.containsKey(mapKey)) {
                List<Agreement__c> storefrontList = mapOfAccCountryToStf.get(mapKey);
                if(storefrontList.size() > 1){
                    rc.addError(System.label.CRM_Rate_Card_More_Than_One_Storefront_Found);
                }else{
                    rc.Storefront__c = storefrontList[0].Id;
                    successRc.add(rc);
                    sfIds.add(storefrontList[0].Id);
                }
            } else {
                rc.addError(System.label.CRM_Rate_Card_Valid_Storefront_Not_found);
            }
        }
    }
    
    /**
    *  @Description - Set Invalid Capability flag on Rate card based on Selected Combinations on Linked Storefront
    *  @name - setInvalidCapabilityFlag
    *  @param - Set<Id> - Storefront Id Set
    *  @param - list<Rate_Card__c> - List of filtered Rate cards
    *  @return - none
    */
    public static void setInvalidCapabilityFlag(Map<Id,Agreement__c> storefrontMap, List<Rate_Card__c> newRCLists) {
        for(Rate_Card__c rc : newRCLists){
            if(storefrontMap.containsKey(rc.Storefront__c)){
                String selCom = storefrontMap.get(rc.Storefront__c).Selected_Combination__c != null ? storefrontMap.get(rc.Storefront__c).Selected_Combination__c : '';
                String rcCom = (rc.Content_Type__c == CRM_AppConstants.CONTENT_TYPE_OR_FORMAT_ALL_VALUE ? '' : rc.Content_Type__c)+'_'+rc.Channel__c+'_'+(rc.Format__c == CRM_AppConstants.CONTENT_TYPE_OR_FORMAT_ALL_VALUE ? '' : rc.Format__c);
                if(selCom != ''){
                    rc.Invalid_Capability__c = !selCom.contains(rcCom);
                }else{
                    rc.Invalid_Capability__c = true;
                }
            }
        }
    }
}