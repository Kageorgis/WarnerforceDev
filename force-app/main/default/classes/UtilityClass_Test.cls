/*
Class Name   : UtilityClass_Test 
Description  :  This class will be used to create Test Data for various objects and perform CRUD operations             
Created By   : Cognizant Technology Solutions - Shekhar Vinayak
Created On   : 20th Aug 2015

Change History:
--------------------------------------------------------------------------------------------------------------------------------------------------
Sr#             Description                                                 Updated By                                     Updated On
--------------------------------------------------------------------------------------------------------------------------------------------------
*/


@isTest
Public class UtilityClass_Test  {
      
      public static sObject sObj;
       public static Utility_DMLOperationTest dmlOperation = new Utility_DMLOperationTest();
       
       public Id cGroupId = ( (Country_Groups__c)createTestRecord(setUpData(new Country_Groups__c(), 0))).Id;
       public Id AccountId;
       public Id LanguageId;
       public Id TitleId;
       
       
       
       //public Id AccountId = ( (account)createTestRecord(setUpData(new account(), 0))).Id;

     public sObject setUpData(sObject tempSObj, integer i){
               
              //  If(AccountId==null)
              //  AccountId = ( (account)createTestRecord(setUpData(new account(), 0))).Id;
                
               // if(LanguageId==null)
               // LanguageId = ( (Language__c)createTestRecord(setUpData(new Language__c(), 0))).Id;
                
               // if(TitleId==null)
               // TitleId = ( (Title__c)createTestRecord(setUpData(new Title__c(), 0))).Id;
                Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
                String sObjName = tempSObj.getSObjectType().getDescribe().getName();
                string[] divName = sObjName.split('__');
                if(divName.size() >= 3)
                {
                    sObjName = divName[divName.size()-2] + '__' + divName[divName.size()-1];
                } 
                
               if('Account'.equalsIgnoreCase(sObjName))
                {  
                Account acc = new account() ;
                acc.name = 'testGoogle';
                acc.recordtypeId = rtypeId;
                sObj  = acc;
                }
                
                 if('Country__c'.equalsIgnoreCase(sObjName))
                {  
                Country__c country1 = new Country__c() ;
                country1.name = 'testFrance';
                country1.Country_Code2__c ='TR';
                country1.Country_Code__c='TF';
                sObj  = country1;
                }
                
                
                if('Country_Groups__c'.equalsIgnoreCase(sObjName))
                {  
                Country_Groups__c cGroup = new Country_Groups__c() ;
                cGroup.name = 'testGoogle';
                cGroup.NameUnique__c ='UniqueNameTest' +System.now().millisecond()+(Integer)Math.random()*100;
                sObj  = cGroup;
            
                }
                
                if('Account_Role__c'.equalsIgnoreCase(sObjName))
                {  
                Account_Role__c aroleUser = new Account_Role__c() ;
             
                aroleUser.Role__c ='Announcer';
                aroleUser.User__c  = UserInfo.getUserId();
                   if (AccountId==null)
                   AccountId= ( (account)createTestRecord(setUpData(new account(), 0))).Id;
                 aroleUser.Account__c  =AccountId;
                sObj  = aroleUser;
                }
                
                 if('Announcement_Rule__c'.equalsIgnoreCase(sObjName))
                {  
                Announcement_Rule__c annType = new Announcement_Rule__c() ;
                   if (AccountId==null)
                   AccountId= ( (account)createTestRecord(setUpData(new account(), 0))).Id;
                annType.Account__c = AccountId;
                annType.Announcement_Type__c ='NewType' + string.valueOf(i);
                annType.DesignatedApprover__c =UserInfo.getUserId();
                annType.Country_Group__c =  cGroupId ;
                sObj  = annType;
                }
                
                if('Language__c'.equalsIgnoreCase(sObjName))
                {  
                    Language__c lang = new Language__c();
                    lang.Name = 'testLanguage';
                    lang.Language_Order__c = 0;
                    sObj = lang;
                }
                
                if('Title__c'.equalsIgnoreCase(sObjName))
                {  
                    Title__c titles = new Title__c();
                    titles.Name = 'testTitle';
                    sObj = titles;
                }
                
                if('Available_Languages__c'.equalsIgnoreCase(sObjName))
                {  
                    Available_Languages__c availLang = new Available_Languages__c();
                    if(LanguageId==null)
                    LanguageId = ( (Language__c)createTestRecord(setUpData(new Language__c(), 0))).Id;
                    availLang.Language__c = LanguageId;
                      
                   if(TitleId==null)
                      TitleId = ( (Title__c)createTestRecord(setUpData(new Title__c(), 0))).Id;
                    availLang.Title__c = TitleId ;
                    sObj = availLang; 
                } 
                  
          return sObj; 

  } 
  
    public  sObject createTestRecord(sObject sObjLocal){       
                dmlOperation.insertObject(sObjLocal);
                return sObjLocal;
            }
    
    //Note , this method doesn't insert records in Database, userful when you require to make changes in some or all records in list, before inserting them in database        
   public  List<sObject> addMultiTestRecordsinList(sObject sObjLocal, integer noOfRecords){
               
                List<sObject> sObjList = new List<sObject>();  
                for(integer i=0; i < noOfRecords; i++){
                    sObjList.add(setUpData(sObjLocal, i) );  
                }
                
                
              return sObjList;
            }
     //note : different from above, actually insert all records in database;      
     public  List<sObject> insertMultiTestRecord(sObject sObjLocal, integer noOfRecords){
               
                List<sObject> sObjList = new List<sObject>();  
                for(integer i=0; i < noOfRecords; i++){
                    sObjList.add(setUpData(sObjLocal, i) );  
                }
                
                
              return dmlOperation.multiInsertObject(sObjList); 
            }
            
      public  sObject updateTestRecord(sObject sObjLocal){
                
                return dmlOperation.updateObject(sObjLocal);
            }    
            
            public  sObject[] updateMultiTestRecord(List<sObject> sObjLocalList){
                return dmlOperation.multiUpdateObject(sObjLocalList);
            }    
            
            public  void deleteTestRecord(sObject sObjLocal){
                dmlOperation.deleteObject(sObjLocal);
            }
            
            public  void deleteMultiTestRecord(sObject[] sObjLocal){
                dmlOperation.deleteMultiObject(sObjLocal);
            }    
            
     /* Get User from Salesforce or Create a User */
    public User getUserFromProfile(String profileName){ 
                 
                User user1 =  new User(); 
                if(profileName == 'System Administrator'){
                    user1 = [SELECT Id,Name,Email,username,profileId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]; 
                } else if (profileName.contains('abc') || profileName.contains('xyz')){
                    User sysUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
                     
                     List<Profile> p = [SELECT Id, name FROM Profile WHERE Name=: profileName limit 1];  
                    
                     if(p != null && p.size()>0){
                         user1 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p[0].Id, 
                            TimeZoneSidKey='America/Los_Angeles',IsActive= true, UserName='newuser_cts'+System.now().millisecond()+(Integer)Math.random()*100+'@testorg.com');
                             
                             system.runAs(sysUser) { 
                                insert user1;
                                
                               user1 =  [SELECT Id,Name,userName,Email,ProfileId,Alias FROM User where id=: user1.Id];
                            } 
                     }
                     else{
                          user1=  null;
                     }
                }
            return user1;
    }
    
       
}