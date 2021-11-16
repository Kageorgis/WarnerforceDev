/******* 
WB_MPMSearchControllerTest
Creation Date- 19 Nov 2014
Description- This class is to do code coverage for WB_MPMSearchController
Author- Harika Bondalapati
*******/
@isTest
public with sharing class WB_MPMSearchControllerTest{
    static testMethod void WB_MPMSearchControllerTestMethod() {
         // create MPM
         List<MPM__c> mpmList= new List<MPM__c>();
          MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family1',MPM_Short_Desc__c='Disney',MPM_Number__c='123456');   
          mpmList.add(mpm1);
          MPM__c mpm2 = new MPM__c(Name='34567',MPM_Family_Desc__c='Potter',MPM_Short_Desc__c='Harry Potter',MPM_Number__c='34567');   
          mpmList.add(mpm2);
          MPM__c mpm3 = new MPM__c(Name='56789',MPM_Family_Desc__c='Potter',MPM_Short_Desc__c='Harry Potter2',MPM_Number__c='56789');   
          mpmList.add(mpm3);
          insert mpmList;
          Custom_Entered_Values__c cs = new Custom_Entered_Values__c(Name='MPMLookup',Field_Name__c='MPM__c',Object_Name__c='EC_Tracker__c',User_Entered_Value__c='00NJ0000001hOvc');
          insert cs;
          
          Test.startTest();
              PageReference pageRef = Page.WB_MPMSearch;
              Test.setCurrentPage(pageRef);
              ApexPages.currentPage().getParameters().put('mpmnumber',mpm2.Name);
              //ApexPages.currentPage().getParameters().put('Sdesc','');
              WB_MPMSearchController con = new WB_MPMSearchController();
              con.selectedtype = 'TNR_TCAT_Record_Type';
              con.Count = 3;
              WB_MPMSearchController.cMPM wrapperMPM = new WB_MPMSearchController.cMPM(mpm2);
              wrapperMPM.selected = true;
              system.debug('wrapperMPM--->>'+wrapperMPM);
              WB_MPMSearchController.cMPM wrapperMPM2 = new WB_MPMSearchController.cMPM(mpm3);
              WB_MPMSearchController.cMPM wrapperMPM3 = new WB_MPMSearchController.cMPM(mpm1);
              List<WB_MPMSearchController.cMPM> cMPMs4 = new List<WB_MPMSearchController.cMPM>();
              cMPMs4.add(wrapperMPM);
              cMPMs4.add(wrapperMPM2);
              cMPMs4.add(wrapperMPM3);
              con.cMPMs = cMPMs4;
              con.createECT();
              
               con.getShowbutton();
               con.toggleSort();
              con.runSearch();
              con.redirectUser();
          Test.stopTest();
    }
    static testMethod void WB_MPMSearchControllerTestMethod2() {
         // create MPM
         List<MPM__c> mpmList= new List<MPM__c>();
          MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family1',MPM_Short_Desc__c='Disney',MPM_Number__c='123456');   
          mpmList.add(mpm1);
          MPM__c mpm2 = new MPM__c(Name='34567',MPM_Family_Desc__c='Potter',MPM_Short_Desc__c='Harry Potter',MPM_Number__c='34567');   
          mpmList.add(mpm2);
          MPM__c mpm3 = new MPM__c(Name='56789',MPM_Family_Desc__c='Potter',MPM_Short_Desc__c='Harry Potter2',MPM_Number__c='56789');   
          mpmList.add(mpm3);
          insert mpmList;
          Custom_Entered_Values__c cs = new Custom_Entered_Values__c(Name='MPMLookup',Field_Name__c='MPM__c',Object_Name__c='EC_Tracker__c',User_Entered_Value__c='00NJ0000001hOvc');
          insert cs;
          
          Test.startTest();
              PageReference pageRef = Page.WB_MPMSearch;
              Test.setCurrentPage(pageRef);
              ApexPages.currentPage().getParameters().put('mpmnumber','');
              ApexPages.currentPage().getParameters().put('Sdesc',mpm2.MPM_Short_Desc__c);
              WB_MPMSearchController con = new WB_MPMSearchController();
              con.selectedtype = 'TNR_TCAT_Record_Type';
              con.Count = 3;
              WB_MPMSearchController.cMPM wrapperMPM = new WB_MPMSearchController.cMPM(mpm2);
              wrapperMPM.selected = true;
              WB_MPMSearchController.cMPM wrapperMPM2 = new WB_MPMSearchController.cMPM(mpm3);
              wrapperMPM2.selected = true;
              WB_MPMSearchController.cMPM wrapperMPM3 = new WB_MPMSearchController.cMPM(mpm1);
              system.debug('wrapperMPM--->>'+wrapperMPM);
              system.debug('wrapperMPM2--->>'+wrapperMPM2);
              List<WB_MPMSearchController.cMPM> cMPMs3 = new List<WB_MPMSearchController.cMPM>();
              cMPMs3.add(wrapperMPM);
              cMPMs3.add(wrapperMPM2);
              cMPMs3.add(wrapperMPM3);
              con.cMPMs = cMPMs3;
              con.createECT();
              
               con.getShowbutton();
               con.toggleSort();
              con.runSearch();
              con.redirectUser();
          Test.stopTest();
    }
     static testMethod void WB_MPMSearchControllerTestMethod3() {
         // create MPM
         List<MPM__c> mpmList= new List<MPM__c>();
          MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family1',MPM_Short_Desc__c='Disney',MPM_Number__c='123456');   
          mpmList.add(mpm1);
          MPM__c mpm2 = new MPM__c(Name='34567',MPM_Family_Desc__c='Potter',MPM_Short_Desc__c='Harry Potter',MPM_Number__c='34567');   
          mpmList.add(mpm2);
          MPM__c mpm3 = new MPM__c(Name='56789',MPM_Family_Desc__c='Potter',MPM_Short_Desc__c='Harry Potter2',MPM_Number__c='56789');   
          mpmList.add(mpm3);
          insert mpmList;
          Custom_Entered_Values__c cs = new Custom_Entered_Values__c(Name='MPMLookup',Field_Name__c='MPM__c',Object_Name__c='EC_Tracker__c',User_Entered_Value__c='00NJ0000001hOvc');
          insert cs;
          
          Test.startTest();
              PageReference pageRef = Page.WB_MPMSearch;
              Test.setCurrentPage(pageRef);
              ApexPages.currentPage().getParameters().put('mpmnumber','');
              ApexPages.currentPage().getParameters().put('Sdesc','');
              WB_MPMSearchController con = new WB_MPMSearchController();
              con.selectedtype = 'TNR_TCAT_Record_Type';
              con.Count = 3;
              WB_MPMSearchController.cMPM wrapperMPM = new WB_MPMSearchController.cMPM(mpm2);
              wrapperMPM.selected = true;
              system.debug('wrapperMPM--->>'+wrapperMPM);
              WB_MPMSearchController.cMPM wrapperMPM2 = new WB_MPMSearchController.cMPM(mpm3);
              WB_MPMSearchController.cMPM wrapperMPM3 = new WB_MPMSearchController.cMPM(mpm1);
              List<WB_MPMSearchController.cMPM> cMPMs4 = new List<WB_MPMSearchController.cMPM>();
              cMPMs4.add(wrapperMPM);
              cMPMs4.add(wrapperMPM2);
              cMPMs4.add(wrapperMPM3);
              con.cMPMs = cMPMs4;
              con.createECT();
              
               con.getShowbutton();
               con.toggleSort();
              con.runSearch();
              con.redirectUser();
          Test.stopTest();
    }
}