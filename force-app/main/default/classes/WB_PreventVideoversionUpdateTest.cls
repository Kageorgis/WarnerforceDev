/*
Class Name   : WB_PreventVideoversionUpdateTest 
Description  : This class is to do code coverage for WB_PreventvideoversionUpdateController class    
Created By   : Cognizant Technology Solutions - Prajakta Sanap
Created On   : MARCH 2016

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
CH02	Added value for format field of title							Preeti jha											12/26/2016
*/

@isTest
private class WB_PreventVideoversionUpdateTest {
     
    public static Account acctGoogle;
    public static Title__c objTitle;
    public static User objUser;
    
    static testMethod void updateVideoVersion() {
        
        Profile objProfile = TestUtil.initProfile('WB - Global Title Planner');
        objUser = TestUtil.initUser(objProfile.Id);
        insert objUser;
        
        System.runas(objUser) {
            acctGoogle = TestUtil.initAccount();
            insert acctGoogle;
            
            objTitle = TestUtil.initTitle('TestGoogle', '6000047545');
            objTitle.formats__c = 'SD';
            insert objTitle;
                        
            Test.startTest();
                WB_PreventvideoversionUpdateController cont = new WB_PreventvideoversionUpdateController();
                cont.userDetail.add(objUser);
                system.assertNotEquals(cont.userDetail[0].Id,null);
                objTitle.Video_Version__c = '6000047555';
                update objTitle;
                
                system.assertNotEquals(objUser.Profile.Name,'SAP Integration API Only');
                system.assertNotEquals(objUser.Profile.Name,'System Administrator');
                list<Title__c> lst_oldtitlerecs = new list<Title__c>();
                list<Title__c> lst_newtitlerecs = new list<Title__c>();
                
                lst_oldtitlerecs.add(objTitle);
                lst_newtitlerecs = [Select Id, Video_Version__c from Title__c LIMIT 1];
                system.assertNotEquals(lst_oldtitlerecs[0].Video_Version__c,lst_newtitlerecs[0].Video_Version__c);
            Test.stopTest();
        }
    }
}