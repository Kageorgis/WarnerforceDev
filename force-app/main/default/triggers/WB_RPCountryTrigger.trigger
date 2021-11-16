trigger WB_RPCountryTrigger on Release_Planning_Country_Content__c (before insert, before update) {
    if(trigger.isBefore && trigger.isInsert) {
		List<Country__c> Countrylist = [SELECT ID, Name from Country__c];              
        for (Release_Planning_Country_Content__c RPC : trigger.new) {
            for (Country__c c : Countrylist) {
            	if (c.name == RPC.Record_Type_Name__c) 
            		{RPC.Country__c = c.id;
                 	break;}
            }
        }
    } 
    
    if(trigger.isBefore && trigger.isUpdate) {
		List<Country__c> Countrylist = [SELECT ID, Name from Country__c];
		for (Release_Planning_Country_Content__c RPC : trigger.new) {
            if (RPC.RecordTypeId != trigger.oldmap.get(RPC.Id).RecordTypeId) {	
                for (Country__c c : Countrylist) {
                    if (c.name == RPC.Record_Type_Name__c) 
                        {RPC.Country__c = c.id;
                        break;}
                }
            }
        }        
    }      
}