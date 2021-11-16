/**
*  Description    :   Test class for WB_Available_Lang_Wizardcontroller_New
*  Author         :   Prachi Gadewar
   Emp ID         :   458725
*  Date           :   31 – Aug- 2015
*  
* =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                          Date                         Comment
*  Prachi Gadewar                  31/8/2015                    
*                                                               
*            
*  
*/

@isTest(seeAllData=false)
public  with sharing class WB_Available_Lang_Wizardcontroller_Test{
   
 public static UtilityClass_Test  utilClass = new UtilityClass_Test(); 
 
 testmethod  static void  testMethod1() {
        test.starttest();
        System.runAs(utilClass.getUserFromProfile('System Administrator')) {
  
             list<Language__c > langList  = (list<Language__c >)utilClass.addMultiTestRecordsinList(new Language__c (), 3);
             insert langList;
             
             Language__c Language = New Language__c();
             Language.Name = 'English';
             Language.Language_Order__c = 1;
             insert Language;
             
             WB_Available_Languages__c lang1 = new WB_Available_Languages__c();
             lang1.Name = 'testLanguage';
             lang1.Audio__c = true;
             lang1.Sub__c = true;
             insert lang1;
             
             Title__c title = (Title__c )utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
             /*List<Available_Languages__c> availList = (list<Available_Languages__c>)utilClass.addMultiTestRecordsinList(new Available_Languages__c(), 3);
             availList[0].Title__c = title.Id;
             availList[0].Clear_to_Avail__c = true;
             availList[0].Language__c = langList[0].id;
             availList[0].Language_Types__c ='Sub';
             
             availList[1].Title__c = title.Id;
             availList[1].Clear_to_Avail__c = true;
             availList[1].Language__c = langList[0].id;
             availList[1].Language_Types__c ='Audio';
             
             availList[2].Title__c = title.Id;
             availList[2].Clear_to_Avail__c = true;
             availList[2].Language__c = langList[1].id;
             availList[2].Language_Types__c ='Sub';
             
             insert availList;*/
             //System.assertNotEquals(null, availList,'');
             List<Title__c> titles = new List<Title__c>();
             titles.add(title);
             Test.setCurrentPageReference(Page.WB_Available_Lang_Wizardpage_New);
             ApexPages.CurrentPage().getparameters().put('id', title.id);
             ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titles);
             WB_Available_Lang_Wizardcontroller_New availLangWzdCtrl = new WB_Available_Lang_Wizardcontroller_New (sc);
             pageReference ref;
             ref = availLangWzdCtrl.SaveRecords();
             System.assertNotEquals(null, ref ,'');
             
             availLangWzdCtrl.availableLangDispLst[0].avlLang.Clear_to_Avail__c = true;
             ref = availLangWzdCtrl.SaveRecords();
             
             ref = availLangWzdCtrl.Cancel();
             System.assertNotEquals(null, ref ,'');
             
             WB_Available_Lang_Wizardcontroller_New availLangWzdCtrl1 = new WB_Available_Lang_Wizardcontroller_New (sc);
             availLangWzdCtrl.availableLangDispLst[0].avlLang.Clear_to_Avail__c = false;
             availLangWzdCtrl.availableLangDispLst[1].avlLang.Clear_to_Avail__c = true;
             ref = availLangWzdCtrl.SaveRecords();
             System.assertNotEquals(null, ref ,'');

        }
 }       


}