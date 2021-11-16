/*
Class Name   : WB_TitleSearchControllerSelectable_Test 
Description  : This class is to do code coverage for WB_TitleSearchControllerSelectable class    
Created By   : Cognizant Technology Solutions - Rashmi
Created On   : DEC 2014

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
*/

@isTest 
private class WB_TitleSearchControllerSelectable_Test{
   
     static testMethod void TitleSearchControllerSelectableChk() {
         
         String DigPicklist;
         String PhyPicklist;
         List<Title__c> titleList = new List<Title__c>();
         
         MPM__c mpm = new MPM__c(Name='TestMPM10Nov', MPM_Family_Desc__c='TestMPMfamily',MPM_Number__c='12345');
         insert mpm ;
         
         Title__c title = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',Formats__c='Hd',
         MPM__c=mpm.id,Digital_Planning__c='Yes', Physical_Planning__c='No',Season__c='Winter',studio__c ='WARNER BROS.');
         
         titleList.add(title);
         insert titleList;
         
         WB_TitleSearchControllerSelectable controller = new WB_TitleSearchControllerSelectable ();    
         
         ApexPages.currentPage().getParameters().put('title',title.id); 
         ApexPages.currentPage().getParameters().put('mpm',mpm.id); 
         ApexPages.currentPage().getParameters().put('season',title.Season__c); 
         ApexPages.currentPage().getParameters().put('digitalPlanning',title.Digital_Planning__c); 
         ApexPages.currentPage().getParameters().put('physicalPlanning',title.Physical_Planning__c); 
         ApexPages.currentPage().getParameters().put('vv',title.Video_Version__c);
         ApexPages.currentPage().getParameters().put('studio',title.studio__c); 
         
         Test.StartTest();
             controller.getDigPicklist();
             for(Title__c titleLst:titleList){
                 DigPicklist = titleLst.Digital_Planning__c;
             }
         
             controller.getPhyPicklist();
             for(Title__c titleLst:titleList){
                 PhyPicklist = titleLst.Physical_Planning__c;
             }
            
            WB_TitleSearchControllerSelectable.cTitle wrapperTitleSelected = new WB_TitleSearchControllerSelectable.cTitle(title);
            //CH01
            wrapperTitleSelected.selected = true;
            //system.assert(wrapperTitleSelected.selected);
            
            controller.runSearch();
            //system.assertNotEquals(wrapperTitleSelected, null);
            controller.titles.add(title);
            //system.assertEquals(controller.titles.size(),1);
            
            controller.createRP();
            controller.toggleSort();
            controller.Beginning();
            controller.Previous();
            controller.Next();
            controller.End();
            controller.getDisablePrevious();
            controller.getDisableNext();
            controller.getTotal_size();
            controller.DigPicklist.add('one');
            controller.DigPicklist.add('two');
            controller.PhyPicklist.add('one');
            controller.PhyPicklist.add('two');            
            /*ER-007018-controller.studio.add('one');
            controller.studio.add('two');*/
            
         Test.StopTest();
     }
     
     static testMethod void TitleSearchControllerSelectableChk_TitleWithOr() {
         
         String DigPicklist;
         String PhyPicklist;
         List<Title__c> titleList = new List<Title__c>();
         
         MPM__c mpm = new MPM__c(Name='TestMPM10Nov', MPM_Family_Desc__c='TestMPMfamily',MPM_Number__c='12345');
         insert mpm ;
         
         Title__c title = new Title__c(Name='10 Items or Less (2006)', Video_Version__c='123456787',Formats__c='Hd',
         MPM__c=mpm.id,Digital_Planning__c='Yes', Physical_Planning__c='No',Season__c='Winter',studio__c ='WARNER BROS.');
         
         titleList.add(title);
         insert titleList;
         
         WB_TitleSearchControllerSelectable controller = new WB_TitleSearchControllerSelectable ();    
         
         ApexPages.currentPage().getParameters().put('title',title.name); 
         ApexPages.currentPage().getParameters().put('mpm',mpm.id); 
         ApexPages.currentPage().getParameters().put('season',title.Season__c); 
         ApexPages.currentPage().getParameters().put('digitalPlanning',title.Digital_Planning__c); 
         ApexPages.currentPage().getParameters().put('physicalPlanning',title.Physical_Planning__c);
         ApexPages.currentPage().getParameters().put('vv',title.Video_Version__c);
         ApexPages.currentPage().getParameters().put('studio',title.studio__c); 
         Test.StartTest();
             controller.getDigPicklist();
             for(Title__c titleLst:titleList){
                 DigPicklist = titleLst.Digital_Planning__c;
             }
         
         	 controller.getPhyPicklist();
             for(Title__c titleLst:titleList){
                 PhyPicklist = titleLst.Physical_Planning__c;
             }	
            
            WB_TitleSearchControllerSelectable.cTitle wrapperTitleSelected = new WB_TitleSearchControllerSelectable.cTitle(title);
            //CH01
            wrapperTitleSelected.selected = true;
            //system.assert(wrapperTitleSelected.selected);
            
            controller.runSearch();
            //system.assertNotEquals(wrapperTitleSelected, null);
            controller.titles.add(title);
            //system.assertEquals(controller.titles.size(),1);
            
            controller.createRP();
            controller.toggleSort();
            controller.Beginning();
            controller.Previous();
            controller.Next();
            controller.End();
            controller.getDisablePrevious();
            controller.getDisableNext();
            controller.getTotal_size();
            controller.DigPicklist.add('one');
            controller.DigPicklist.add('two');
            controller.PhyPicklist.add('one');
            controller.PhyPicklist.add('two');            
            /*ER-007018-controller.studio.add('one');
            controller.studio.add('two');*/
            
         Test.StopTest();
     }
}