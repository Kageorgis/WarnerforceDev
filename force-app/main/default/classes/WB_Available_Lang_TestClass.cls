/*****************************************************************************
 WB_Available_Lang_TestClass 
Creation Date- 16 Dec 2014
Last Modified Date - 
Last Modified by  -
Description- Test class for WB_Available_Lang_Wizardcontroller
Author- Rashmi
 *****************************************************************************/
@isTest
public class WB_Available_Lang_TestClass {
    static testMethod void WB_Available_Lang(){
         Test.startTest();
         
         MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
         
         // Test Title
         Title__c testTitle = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
          insert testTitle; 
          
          // Test Language
          list<Language__c> languageList= new list<Language__c>();
        Language__c Language = new Language__c (Name='TestLanguage1',Language_Order__c =1);
        Language__c Language1 = new Language__c (Name='TestLanguage2',Language_Order__c = 2);
        languageList.add(Language);
        languageList.add(Language1);
        insert languageList;
        
         // Test Available language on Test Title
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=testTitle.Id);
        insert availLangTitle;
        
        ApexPages.currentPage().getParameters().put('id', testTitle.Id); 
        list<Available_Languages__c> availLang= new list<Available_Languages__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(availLang);  
        WB_Available_Lang_Wizardcontroller controller = new WB_Available_Lang_Wizardcontroller (sc); 
        controller.theValue= Language.id+'Sub'+','+Language1.id+'Audio';
        controller.post();
        controller.cancel();
                               
        Test.stopTest();
        
    }

}