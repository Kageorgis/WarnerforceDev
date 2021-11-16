/**
*  Description    :   Test Class for WB_Available_Language_RL_Controller
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
public with sharing class WB_Available_Language_RL_Controller_Test {

 public static UtilityClass_Test  utilClass = new UtilityClass_Test(); 
 
 testmethod  static void  testMethod1() {
        test.starttest();
        System.runAs(utilClass.getUserFromProfile('System Administrator')) {
             
             List<Available_Languages__c> resAvailList = new List<Available_Languages__c>();
             Language__c lang  = (Language__c)utilClass.createTestRecord(utilClass.setUpData(new Language__c (),0));
             Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl3');
             insert Language2;

             Title__c titles  = (Title__c )utilClass.createTestRecord(utilClass.setUpData(new Title__c (),0));
             List<Available_Languages__c> availList = new List<Available_Languages__c>();
             Available_Languages__c al = new Available_Languages__c();
             al.Title__c = titles.Id;
             al.Clear_to_Avail__c = true;
             al.Language__c = lang.id;
             al.Language_Types__c = 'Audio';
             availList.add(al);

             Available_Languages__c al1 = new Available_Languages__c();
             al1.Title__c = titles.Id;
             al1.Provisional__c = true;
             al1.Language__c = Language2.id;
             al1.Language_Types__c = 'Audio';
             availList.add(al1);

             
             Available_Languages__c al2 = new Available_Languages__c();
             al2.Title__c = titles.Id;
             al2.Provisional__c = true;
             al2.Language__c = Language2.id;
             al2.Language_Types__c = 'Sub';
             availList.add(al2);
             
             insert availList;
            
             System.assertNotEquals(null, availList,'');
             
             Test.setCurrentPageReference(Page.WB_Available_Language_RL);
             ApexPages.CurrentPage().getparameters().put('Id', titles.id);
             ApexPages.StandardController sc = new ApexPages.standardController(titles);
             WB_Available_Language_RL_Controller availLangCtrl = new WB_Available_Language_RL_Controller(sc);
             Id langId = availLangCtrl.LangAvailId;
             String message = availLangCtrl.message;
             resAvailList = availLangCtrl.getAvailablelang_lst();
             System.assertNotEquals(null, resAvailList ,'');
             
             Pagereference pg = availLangCtrl.NewAvailLanguage();
             System.assertNotEquals(null,pg,'');
             
             
        
        }
        test.stoptest();
    }

}