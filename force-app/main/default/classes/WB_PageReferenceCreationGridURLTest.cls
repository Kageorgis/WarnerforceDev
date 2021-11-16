@isTest
public with sharing class WB_PageReferenceCreationGridURLTest {
    
    public static testMethod void getTentativeRPTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        pageref.getParameters().put('al','true');
        pageref.getParameters().put('obj','Commercial_Avail__c');
        pageref.getParameters().put('CF_QP_Tentative_RP_Territory','Yes');
        pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getTentativeRPTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getTentativeRPAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        pageref.getParameters().put('al','true');
        pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_Tentative_RP_All','Yes');
        pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getTentativeRPAllUrl();
        Test.StopTest();
    }

    public static testMethod void getTentativeCATerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_Tentative_CA_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getTentativeCATerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getTentativeCAAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_Tentative_CA_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getTentativeCAAllUrl();
        Test.StopTest();
    }

    public static testMethod void getOpenRPTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_Open_RP_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getOpenRPTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getOpenRPAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_Open_RP_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getOpenRPAllUrl();
        Test.StopTest();
    }

    public static testMethod void getRightsCheckRPTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_RightsCheck_RP_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getRightsCheckRPTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getRightsCheckRPAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_RightsCheck_RP_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getRightsCheckRPAllUrl();
        Test.StopTest();
    }

    public static testMethod void getEarlyEndingRPTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_EarlyEnding_RP_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getEarlyEndingRPTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getEarlyEndingRPAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_EarlyEnding_RP_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getEarlyEndingRPAllUrl();
        Test.StopTest();
    }
    
    public static testMethod void getEarlyEndingCATerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_EarlyEnd_CA_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getEarlyEndingCATerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getEarlyEndingCAAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_EarlyEnd_CA_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getEarlyEndingCAAllUrl();
        Test.StopTest();
    }

    public static testMethod void getTitleAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Title__c');
        Pageref.getParameters().put('CF_QP_Title_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Title__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getTitleAllUrl();
        Test.StopTest();
    }

    public static testMethod void getTitleTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Title__c');
        Pageref.getParameters().put('CF_QP_Title_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Title__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getTitleTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getWithoutCARPTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        pageref.getParameters().put('al','true');
        pageref.getParameters().put('obj','Commercial_Avail__c');
        pageref.getParameters().put('CF_QP_Without_CA_RP_Territory','Yes');
        pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getWithoutCARPTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getWithoutCARPAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Commercial_Avail__c');
        Pageref.getParameters().put('CF_QP_Without_CA_RP_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getWithoutCARPAllUrl();
        Test.StopTest();
    }

    public static testMethod void getDraftCATerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_Draft_CA_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getDraftCATerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getDraftCAAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_Draft_CA_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getDraftCAAllUrl();
        Test.StopTest();
    }

    public static testMethod void getNRRepriceCATerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_NR_Reprice_CA_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getNRRepriceCATerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getNRRepriceCAAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_NR_Reprice_CA_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getNRRepriceCAAllUrl();
        Test.StopTest();
    }

    public static testMethod void getRepriceReminderTerritoryUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_Reprice_Reminder_Territory','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getRepriceReminderTerritoryUrl();
        Test.StopTest();
    }

    public static testMethod void getRepriceReminderAllUrlTest() {
        PageReference pageref = Page.PQ_Grid;
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_Reprice_Reminder_All','Yes');
        Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        Test.setCurrentPage(pageref);
        Test.StartTest();
        WB_PageReferenceCreationGridURL.getRepriceReminderAllUrl();
        Test.StopTest();
    }

}