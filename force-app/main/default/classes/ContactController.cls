public class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(String accountIdValue){
        try{
            User userRec = [SELECT Id, WBCP_Access_Role__c,Country,User_License_Type__c FROM User WHERE Id =: UserInfo.getUserId()];
            List<Contact> contactRecs = [SELECT Id, FirstName, LastName, Name, Email, CP_Territory__c, CP_Region__c, Phone, Title FROM Contact WHERE AccountId = : accountIdValue];
            if(userRec != null && !contactRecs.isEmpty() && userRec.User_License_Type__c.equalsIgnoreCase(CP_ProductUtility.WBCP_SALESFORCE_PLATFORM) && !String.isEmpty(userRec.WBCP_Access_Role__c) && !userRec.WBCP_Access_Role__c.equalsIgnoreCase(CP_ProductUtility.WBCP_GLOBAL)){
                List<Contact> returnedContactRecs = new List<Contact>();
                if(userRec.WBCP_Access_Role__c.equalsIgnoreCase(CP_ProductUtility.WBCP_LOCAL)){
                    for(Contact contRec : contactRecs){
                        if(contRec.CP_Territory__c != null && contRec.CP_Territory__c.contains(userRec.Country)){
                            returnedContactRecs.add(contRec);
                        }
                    }
                }else if(userRec.WBCP_Access_Role__c.equalsIgnoreCase(CP_ProductUtility.WBCP_REGIONAL)){
                    Map<String,WBCP_TerritoryData__c> territoryMapping = WBCP_TerritoryData__c.getAll();
                    String userCountryRegion = CP_ProductUtility.getRegionValue(userRec.Country,territoryMapping);
                    for(Contact contRec : contactRecs){
                        if(!String.isEmpty(contRec.CP_Region__c) && contRec.CP_Region__c.contains(userCountryRegion)){  
                            returnedContactRecs.add(contRec);
                        }
                    }
                }
                return returnedContactRecs;
            }else{
                return contactRecs;
            }
            
        } catch (Exception ex){
            throw new AuraHandledException('Forced error');
        }
    }
    
    /*class RecordTypeInfoCustom{
        String recordTypeId = '';
        String name = '';
        //String label = '';
        String recordTypeDes = '';
        
        RecordTypeInfoCustom(String recordTypeId, String name,String recordTypeDes){
            this.recordTypeId = recordTypeId;
        	this.name = name;
        	//this.label = label;
        	this.recordTypeDes = recordTypeDes;
        }
    }

    @AuraEnabled(cacheable=true)
    public static void getRecordType(String objName){
        SObjectType sObjType = ((SObject) Type.forName(objName).newInstance()).getSObjectType();
        List<RecordTypeInfoCustom> recordTypeInfoData = new List<RecordTypeInfoCustom>();
        for(RecordTypeInfo info: sObjType.getDescribe().getRecordTypeInfos()) {
            System.debug('info:::'+info);
            if(info.isAvailable()) {
                recordTypeInfoData.add(new RecordTypeInfoCustom(info.getRecordTypeId(), info.getName(), ''));
            }
        }
    }*/

    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContactsForListView(){
        try{
            User userRec = [SELECT Id, WBCP_Access_Role__c,Country,User_License_Type__c FROM User WHERE Id =: UserInfo.getUserId()];
            Map<Id,Account> mapAccRecs = new Map<Id,Account>([SELECT Id FROM Account WHERE RecordType.Name = :CP_ProductUtility.WBCP_LICENSEE]);
            List<Contact> contactRecs = [SELECT Id, Name, AccountId, Account.Name, Account.Site, Phone, Email, Owner.Name, CP_Territory__c, CP_Region__c FROM Contact WHERE AccountId IN :mapAccRecs.keySet()];
            if(userRec != null && !contactRecs.isEmpty() && userRec.User_License_Type__c.equalsIgnoreCase(CP_ProductUtility.WBCP_SALESFORCE_PLATFORM) && !String.isEmpty(userRec.WBCP_Access_Role__c) && !userRec.WBCP_Access_Role__c.equalsIgnoreCase(CP_ProductUtility.WBCP_GLOBAL)){
                List<Contact> returnedContactRecs = new List<Contact>();
                if(userRec.WBCP_Access_Role__c.equalsIgnoreCase(CP_ProductUtility.WBCP_LOCAL)){
                    for(Contact contRec : contactRecs){
                        if(contRec.CP_Territory__c != null && contRec.CP_Territory__c.contains(userRec.Country)){
                            returnedContactRecs.add(contRec);
                        }
                    }
                }else if(userRec.WBCP_Access_Role__c.equalsIgnoreCase(CP_ProductUtility.WBCP_REGIONAL)){
                    Map<String,WBCP_TerritoryData__c> territoryMapping = WBCP_TerritoryData__c.getAll();
                    String userCountryRegion = CP_ProductUtility.getRegionValue(userRec.Country,territoryMapping);
                    for(Contact contRec : contactRecs){
                        if(!String.isEmpty(contRec.CP_Region__c) && contRec.CP_Region__c.contains(userCountryRegion)){  
                            returnedContactRecs.add(contRec);
                        }
                    }
                }
                return returnedContactRecs;
            }else{
                return contactRecs;
            }
            
        } catch (Exception ex){
            throw new AuraHandledException('Forced error');
        }
    }
}