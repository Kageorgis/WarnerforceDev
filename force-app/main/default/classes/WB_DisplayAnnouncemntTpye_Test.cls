/*****************************************************************************
 * Class Name:      WB_DisplayAnnouncemntTpye_Test
 * Description:     Test Class for WB_Display_AnnouncemntTpye class
 *
 * Author:          Date:          Description
 * Rashmi          16-Feb-2014      First Draft 
 * Prajakta         4-May-2016      Updated
 * krishna         4-May -2016      coverage increase added new test method.
 *****************************************************************************/
@isTest
public class WB_DisplayAnnouncemntTpye_Test{
        static testMethod void displayAnnouncemntTpyeMethod(){
        
        Test.startTest(); 
        Account acc= TestUtil.createAccount('Test');
        List<Announcement_Rule__c> announcementRules = new List<Announcement_Rule__c >();
        for(Integer i=1;i<210;i++) {
           Announcement_Rule__c announcement = TestUtil.createAnnouncementType(acc.Id);
           announcement.Announcement_Type__c= 'Testing'+i;
           announcementRules.add(announcement);
        }
        insert announcementRules;
        ApexPages.currentPage().getParameters().put('ID', acc.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc );
        WB_Display_AnnouncementType_Controller testCon= new WB_Display_AnnouncementType_Controller(sc);
        WB_Display_AnnouncementType_Controller.announcementTypeWrapper annTypewrapper = new WB_Display_AnnouncementType_Controller.announcementTypeWrapper();
        System.assertEquals(annTypewrapper.isSelected,false);
        WB_Display_AnnouncementType_Controller.announcementTypeWrapper annTypewrapper2 = new WB_Display_AnnouncementType_Controller.announcementTypeWrapper(new announcement_Rule__c(Announcement_Type__c='Test1'));
        System.assertEquals(annTypewrapper2.announcementTypeRec.Announcement_Type__c,'Test1');
        System.assertEquals(annTypewrapper2.isSelected,false);
        List<WB_Display_AnnouncementType_Controller.announcementTypeWrapper> selectedList = testCon.getannouncementTypesDisplayed();
        testCon.getdisplayPagination();
        testCon.getReDirect();
        testCon.redirectToMoreAnnTypes();
        testCon.first();
        testCon.last();
        testCon.next();
        testCon.previous();
        testCon.hasNext = true;
        testCon.hasPrevious = true;
        testCon.pageNumber = 1;
        announcement_Rule__c rule = [Select Id,Account__c from announcement_Rule__c  where Id=:announcementRules[0].Id];
        PageReference pageRef = new PageReference('/'+rule.Account__c);
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('announcementTypeIdId',rule.Id);
        testCon.deleteAnnouncementType();
        for(WB_Display_AnnouncementType_Controller.announcementTypeWrapper wrap : selectedList) {
            wrap.isSelected = true;
        }
        testCon.generateAnnouncements();
       System.assertEquals(testCon.getdisplayPagination(),true);
        System.assertEquals(testCon.getReDirect(),true);

        Test.stopTest(); 
        }

    static testMethod void displayAnnouncemntTpyeMethod1(){
        Test.startTest(); 
        Account acc1 = TestUtil.createAccount('Test');
        Announcement_Rule__c announcement = TestUtil.createAnnouncementType(acc1.Id);
        announcement.Announcement_Type__c= 'Testing1';
        insert announcement;
        ApexPages.currentPage().getParameters().put('ID', acc1.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(acc1 );
        WB_Display_AnnouncementType_Controller testCon1 = new WB_Display_AnnouncementType_Controller(sc1);
        System.assertEquals(testCon1.getdisplayPagination(),false);
        System.assertEquals(testCon1.getReDirect(),false);
        Test.stopTest();
    }
}