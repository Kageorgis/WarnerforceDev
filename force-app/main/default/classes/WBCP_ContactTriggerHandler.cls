/*
   @Author: Tejasvini Telangi
   @name WBCP_ContactTriggerHandler
   @CreateDate 21 March 2021
   @Description: Apex Class to handle Territory changes and auto populating Region value.
   @Version 52
  */
public class WBCP_ContactTriggerHandler{
   
    public static void populateRegionValue(List<Contact> newContactList,Map<Id,Contact> oldMap,String operation){
        
        List<Contact> contactList = new List<Contact>();
        Set<String> accountSet = new Set<String>();
        
        String recTypeId = CP_ProductUtility.getRecordTypeId(Contact.getSobjectType(),CP_ProductUtility.WBCP_LICENSEE_CONTACT); 
        
        if(newContactList != Null && newContactList.size()>0){
            for(Contact conRec : newContactList){
                
               if(conRec.RecordTypeId != recTypeId)
               	continue;
                
                if(conRec.CP_Territory__c == Null || conRec.CP_Territory__c ==''){
                    conRec.addError(CP_ProductUtility.WBCP_TERRITORY_ERROR);
                }

                if(conRec.CP_Territory__c != Null){
                    if(conRec.CP_Territory__c.contains('All') && !conRec.CP_Territory__c.containsOnly('All')){
                        conRec.addError(CP_ProductUtility.WBCP_TERRITORY_ALL_ERROR);
                    }
                    if(operation == 'Insert'){
                        if(conRec.CP_Territory__c.contains('All')){
                            accountSet.add(conRec.AccountId);
                        }
                        contactList.add(conRec);
                    } 
                    if(operation == 'Update'){
                        Contact oldContactRec = (Contact)oldMap.get(conRec.Id);
                        if(conRec.CP_Territory__c != oldContactRec.CP_Territory__c){
                            if(conRec.CP_Territory__c.contains('All')){
                                accountSet.add(conRec.AccountId);
                            }
                            contactList.add(conRec);
                        }
                    }
                }
            }
        }
        
        if(contactList.size()>0 && contactList != Null){
            WBCP_ContactTriggerHandler.populateRegionValueLogic(contactList,accountSet,operation);
        }
        
    }
    
    public static void populateRegionValueLogic(List<Contact> contactListToProcess,Set<String> accountSet,String operation){
        
        String regionValue = '';
        Map<Id,Account> accountMap;
        Map<String,WBCP_TerritoryData__c> territoryMapping = WBCP_TerritoryData__c.getAll();
        if(contactListToProcess.size()>0 && contactListToProcess != Null){
            for(Contact conRec : contactListToProcess){
               if(conRec.CP_Territory__c.contains('All')){
                    String regions = '';
                    if(regionValue == '' && conRec.CP_Territory__c.equals('All')){   //Exception scenario -- If Contact is created with All and no country is specified on Account
                        regionValue = CP_ProductUtility.WBCP_ALL_REGION;
                    }
                }else if(conRec.CP_Territory__c.contains(';')){
                    String[] territoryList = conRec.CP_Territory__c.split(';');
                    for(String territoryName : territoryList){
                        if(regionValue != ''){
                            if(regionValue.contains(CP_ProductUtility.getRegionValue(territoryName,territoryMapping))){
                                continue;
                            }else{
                                List<String> regionList = new List<String>();
                                regionList.add(regionValue);
                                regionList.add(CP_ProductUtility.getRegionValue(territoryName,territoryMapping));
                                regionList.sort();

                                regionValue = String.join(regionList,';');
                            }
                        }
                        if(regionValue == ''){
                            regionValue = CP_ProductUtility.getRegionValue(territoryName,territoryMapping);
                        }
                   }
                }else{
                    regionValue = CP_ProductUtility.getRegionValue(conRec.CP_Territory__c,territoryMapping);
                }
                conRec.CP_Region__c = regionValue;
                system.debug(LoggingLevel.INFO,'conRec.CP_Region__c:'+conRec.CP_Region__c);
            }
        }
    }
    
    public static void updateAccountTerritoryRegions(List<Contact> newContactList,Map<Id,Contact> oldMap,String operation){
        Set<String> accountSet = new Set<String>();
        String recTypeId = CP_ProductUtility.getRecordTypeId(Contact.getSobjectType(),CP_ProductUtility.WBCP_LICENSEE_CONTACT); 
       
        if(newContactList != Null && newContactList.size()>0){
            for(Contact conRec : newContactList){
                Contact oldContactRec;
                if(conRec.RecordTypeId != recTypeId)
                  continue;
                
                if(conRec.CP_Territory__c != Null && operation == 'Insert'){
                    accountSet.add(conRec.AccountId);
                } 
                if(operation == 'Update'){
                    oldContactRec = (Contact)oldMap.get(conRec.Id);
                    if(conRec.CP_Territory__c != oldContactRec.CP_Territory__c){
                        accountSet.add(conRec.AccountId);
                    }
                }
            }
        }
        if(operation == 'Delete'){
            if(oldMap !=  Null){
                for(Id conRecOldId : oldMap.keySet()){
                    accountSet.add(oldMap.get(conRecOldId).AccountId);
                }
            }
        }
        
        if(accountSet.size()>0 && accountSet != Null){
            WBCP_ContactTriggerHandler.updateAccountRecords(accountSet);
        }
    }
    
    public static void updateAccountRecords(Set<String> accountSet){
       
        Map<Id,Account> accountMap;
        List<Account> updateAccountList = new List<Account>();
         
        if(accountSet != Null && accountSet.size()>0){
            accountMap = new Map<Id,Account>([Select Id,cp_Territories__c,cp_Regions__c,(Select Id,CP_Region__c,CP_Territory__c FROM Contacts) FROM Account WHERE Id IN:accountSet]);
        }
        
        if(accountMap != Null){
            for(Id accId : accountMap.keySet()){
            	String territories = '';
                String regions = '';
                Set<String> territoriesSet = new Set<String>();
                Set<String> regionsSet = new Set<String>();
                for(Contact conRec : accountMap.get(accId).Contacts){
                    if(conRec.CP_Territory__c  != Null && conRec.CP_Region__c != Null){
                        if(conRec.CP_Territory__c.contains(';')){
                            String[] territoryValues = conRec.CP_Territory__c.split(';');
                            for(String value :territoryValues){
                                territoriesSet.add(value);
                            }
                        }else{
                            territoriesSet.add(conRec.CP_Territory__c);
                        }
                        if(conRec.CP_Region__c.contains(';')){
                            String[] regionValues = conRec.CP_Region__c.split(';');
                            for(String value :regionValues){
                                regionsSet.add(value);
                            }
                        }else{
                            regionsSet.add(conRec.CP_Region__c);
                        }
                    }
                }

                if(territoriesSet != Null){
                    List<String> territoriesList = new List<String>();
                    territoriesList.addAll(territoriesSet);
                    territoriesList.sort();
                    if(territoriesList.contains('All')){
                        Integer index = territoriesList.indexOf('All');
                        territoriesList.remove(index);
                    }
                    if(territoriesList != Null && territoriesList.size()>0){
                        territories = String.join(territoriesList,';');
                    }
                    
                    if(territories != ''){
                        accountMap.get(accId).cp_Territories__c = territories;
                    }
                }
                if(regionsSet != Null){
                    List<String> regionsList = new List<String>();
                    regionsList.addAll(regionsSet);
                    regionsList.sort();
                    regions = String.join(regionsList,';');
                    if(regions != ''){
                        accountMap.get(accId).cp_Regions__c = regions;
                    }
                }
                updateAccountList.add(accountMap.get(accId));
            }
        }
        
        try{
           if(updateAccountList != Null && updateAccountList.size() > 0){
               Database.SaveResult[] updateResultList = Database.update(updateAccountList,false);
           }
        }catch(Exception e){
            System.debug(LoggingLevel.INFO,'Exception in updateAccount '+e.getMessage());
        }
    } 
  
    public static boolean recursiveUpdate = false;

}