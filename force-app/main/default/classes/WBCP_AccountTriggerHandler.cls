public without sharing class WBCP_AccountTriggerHandler {

    public static void shareAccountRecords(List<Account> newAccountList,Map<Id,Account> oldMap,Map<Id,User> newUserMap,String instance){
 
         Set<String> accountIdSet = new Set<String>();
         List<Account> iterateAccountList = new List<Account>();
         Map<Id,Account> accountMap;
         Map<Id,User> userMap;
         List<AccountShare> existingAccountShareList;
         String licenseeRecTypeId = CP_ProductUtility.getRecordTypeId(Account.getSobjectType(),CP_ProductUtility.WBCP_LICENSEE); 
         Boolean isAccountLicensee = false;
         Boolean isAccountRetailer = false;
 
         if(instance == CP_ProductUtility.WBCP_TRIGGER){
             if(newAccountList.size()>0 && newAccountList != Null){
                 for(Account accRec : newAccountList){
                     if(accRec.RecordTypeId == licenseeRecTypeId){
                         Account oldAccountRec = (Account)oldMap.get(accRec.Id);
                         if(accRec.cp_Territories__c != Null && accRec.cp_Territories__c != oldAccountRec.cp_Territories__c){
                             isAccountLicensee = true;
                             iterateAccountList.add(accRec);
                             accountIdSet.add(accRec.Id);
                         }
                    }
                }
             }
         }else if(instance == CP_ProductUtility.WBCP_BATCH){
            iterateAccountList = [SELECT Id,Name,cp_Territories__c,cp_Regions__c,OwnerId,RecordTypeId FROM Account WHERE RecordTypeId =:licenseeRecTypeId ORDER BY Name];
         }
         
         Set<String> profileSet = new Set<string>{CP_ProductUtility.WBCP_ADMIN_LICENSEE_PROFILE,CP_ProductUtility.WBCP_PLAT_LICENSEE_PROFILE};
         
         if(instance == CP_ProductUtility.WBCP_TRIGGER){
             userMap = new Map<Id,User>([SELECT Id,User_License_Type__c,WBCP_Access_Role__c,UserRoleId,UserRole.Name,Country FROM User WHERE User_License_Type__c =: CP_ProductUtility.WBCP_SALESFORCE_PLATFORM AND isActive = True AND WBCP_Access_Role__c != Null AND WBCP_Access_Role__c !=:CP_ProductUtility.WBCP_GLOBAL AND Profile.Name IN: profileSet]);
         }else if(instance == CP_ProductUtility.WBCP_BATCH){
             if(newuserMap != Null && newuserMap.size()>0){
                 userMap = new Map<Id,User>();
                 userMap= newuserMap;
             }
         }
         
         Map<String,WBCP_TerritoryData__c> territoryMapping = WBCP_TerritoryData__c.getAll();
         Map<String,Map<String,String>> userIdAccounIdAccountShareMap = new Map<String,Map<String,String>>();
         
         if(isAccountLicensee){
             existingAccountShareList = new List<AccountShare>([SELECT Id,AccountId,UserOrGroupId,AccountAccessLevel FROM AccountShare WHERE UserOrGroupId IN : userMap.keySet() AND AccountId IN : accountIdSet ]);
            
             for(AccountShare accShareRecord : existingAccountShareList){
                 if(!userIdAccounIdAccountShareMap.containsKey(accShareRecord.UserOrGroupId)){
                     userIdAccounIdAccountShareMap.put(accShareRecord.UserOrGroupId,new Map<String,String>());
                 }
                 if(!userIdAccounIdAccountShareMap.get(accShareRecord.UserOrGroupId).containsKey(accShareRecord.AccountId)){
                     userIdAccounIdAccountShareMap.get(accShareRecord.UserOrGroupId).put(accShareRecord.AccountId,accShareRecord.Id);
                 }
             }
         }
         
         List<AccountShare> accountShareList = new List<AccountShare>();
         List<Id> deleteAccountShareIdList = new List<Id>();
 
         try{
             if(iterateAccountList != Null && iterateAccountList.size()>0){
                 for(Account accRec : iterateAccountList){
                     AccountShare accShareRec ;
                     if(userMap != Null && userMap.size()>0){
                         for(User userRecord : userMap.values()){
                             if(accRec.OwnerId == userRecord.Id)
                                 continue;
                             if(userRecord.WBCP_Access_Role__c == CP_ProductUtility.WBCP_LOCAL){
                                    
                                     //Check if AccountShare record matching with User Id and Account Id is present
                                     if(userIdAccounIdAccountShareMap != Null && userIdAccounIdAccountShareMap.containsKey(userRecord.Id) && userIdAccounIdAccountShareMap.get(userRecord.Id).containsKey(accRec.Id)){
                                         //Check Account Territory doesn't contain User Country  
                                         if(accRec.cp_Territories__c != Null && !accRec.cp_Territories__c.contains(userRecord.Country)){
                                             deleteAccountShareIdList.add(userIdAccounIdAccountShareMap.get(userRecord.Id).get(accRec.Id));
                                         }
                                         //Check if AccountShare record matching with User Id and Account Id is not present
                                     }else if(userIdAccounIdAccountShareMap != Null && (userIdAccounIdAccountShareMap.containsKey(userRecord.Id) && !userIdAccounIdAccountShareMap.get(userRecord.Id).containsKey(accRec.Id) ||
                                             !userIdAccounIdAccountShareMap.containsKey(userRecord.Id))){
                                         //Check Account Territory contains User Country  
                                         if(accRec.cp_Territories__c != Null && accRec.cp_Territories__c.contains(userRecord.Country)){
                                             accShareRec = new AccountShare();
                                             WBCP_AccountTriggerHandler.assignShareRecordValues(accShareRec,accRec.Id,userRecord);
                                             accountShareList.add(accShareRec);
                                         }
                                     }
                                 }else if(userRecord.WBCP_Access_Role__c == CP_ProductUtility.WBCP_REGIONAL){
                                     String userCountryRegion = CP_ProductUtility.getRegionValue(userRecord.Country,territoryMapping);
                                     if(userCountryRegion != Null){
                                         //Check if AccountShare record matching with User Id and Account Id is present
                                         if(userIdAccounIdAccountShareMap != Null && userIdAccounIdAccountShareMap.containsKey(userRecord.Id) && userIdAccounIdAccountShareMap.get(userRecord.Id).containsKey(accRec.Id)){
                                             //Check Account Region doesn't contain User Country's Region
                                             if(accRec.cp_Regions__c != Null && !accRec.cp_Regions__c.contains(userCountryRegion)){
                                                 deleteAccountShareIdList.add(userIdAccounIdAccountShareMap.get(userRecord.Id).get(accRec.Id));
                                             }
                                             //Check if AccountShare record matching with User Id and Account Id is not present
                                         }else if(userIdAccounIdAccountShareMap != Null && (userIdAccounIdAccountShareMap.containsKey(userRecord.Id) && !userIdAccounIdAccountShareMap.get(userRecord.Id).containsKey(accRec.Id) ||
                                             !userIdAccounIdAccountShareMap.containsKey(userRecord.Id))){
                                             //Check Account Region contains User Country's Region 
                                             if(accRec.cp_Regions__c != Null && accRec.cp_Regions__c.contains(userCountryRegion)){
                                                 accShareRec = new AccountShare();
                                                 WBCP_AccountTriggerHandler.assignShareRecordValues(accShareRec,accRec.Id,userRecord);
                                                 accountShareList.add(accShareRec);
                                             }
                                         }
                                     }
                                 }
                         }
                     }
                 }
             }
             
             if(accountShareList != Null && accountShareList.size()>0){
                 Database.SaveResult[] saveResultList = Database.insert(accountShareList,false);
                 Integer i=0;
                 // Process the save results
                 for(Database.SaveResult sr : saveResultList){
                     if(!sr.isSuccess()){
                         Database.Error err = sr.getErrors()[0];
                         system.debug(LoggingLevel.INFO,'Error in AccountShare Insert:'+err);
                     }
                     i++;
                 }
             }
     
             if(deleteAccountShareIdList != Null && deleteAccountShareIdList.size()>0){
                 Database.DeleteResult[] deleteResults = Database.delete(deleteAccountShareIdList, true);
                 for(Database.DeleteResult dr : deleteResults) {                   
                     if (!dr.isSuccess()) {
                         for(Database.Error err : dr.getErrors()) {
                             system.debug(LoggingLevel.INFO,'Error in AccountShare Delete:'+err);
                         }
                     }
                 }
             }
         }catch(Exception e){
             system.debug(LoggingLevel.INFO,'Exception in AccountShare:'+e);
         }
     }
 
     public static void assignShareRecordValues(AccountShare accShareRec, Id accId,User userRecord){
         accShareRec.AccountId = accId;
         accShareRec.UserOrGroupId = userRecord.Id;
         accShareRec.AccountAccessLevel = 'Edit';
         accShareRec.CaseAccessLevel = 'None';
     accShareRec.OpportunityAccessLevel = 'None';
     }
 }