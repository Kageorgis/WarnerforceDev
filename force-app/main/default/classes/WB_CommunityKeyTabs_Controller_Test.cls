/*
 Created by: Purushottam Gupta
 Created On: 27th April 2017
 */
@isTest
private class WB_CommunityKeyTabs_Controller_Test {
    static testmethod void TestCommunityTab() {
        // Insert Grid
        List<PowerGrid__Grid__c> grid = new List<PowerGrid__Grid__c>();
        grid.add(new PowerGrid__Grid__c(Name = 'Key Release Plan Grid'));
        grid.add(new PowerGrid__Grid__c(Name = 'Key Rights Grid'));
        grid.add(new PowerGrid__Grid__c(Name = 'RRT Grid'));        
        insert grid;
        
        // Insert Query panel Template
        List<PowerLoader__Query_Panel__c> queryPanel = new List<PowerLoader__Query_Panel__c>();
        queryPanel.add(new PowerLoader__Query_Panel__c(Name = 'Key_Release_Plan_RRT'));
        queryPanel.add(new PowerLoader__Query_Panel__c(Name = 'Key_Rights_RRT'));
        insert queryPanel;
            
        // Insert Query panel Template
        List<PowerLoader__QueryPanelTemplate__c> queryPanelTemp = new List<PowerLoader__QueryPanelTemplate__c>();
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Require Action', PowerLoader__Query_Panel_Name__c = 'Key_Release_Plan_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Upcoming', PowerLoader__Query_Panel_Name__c = 'Key_Release_Plan_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Recent', PowerLoader__Query_Panel_Name__c = 'Key_Release_Plan_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Not Releasing', PowerLoader__Query_Panel_Name__c = 'Key_Release_Plan_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Upcoming', PowerLoader__Query_Panel_Name__c = 'Key_Rights_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Recent', PowerLoader__Query_Panel_Name__c = 'Key_Rights_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Expiring', PowerLoader__Query_Panel_Name__c = 'Key_Rights_RRT'));
        queryPanelTemp.add(new PowerLoader__QueryPanelTemplate__c(Name = 'Changed In Last 30 Days', PowerLoader__Query_Panel_Name__c = 'Key_Rights_RRT'));
        insert queryPanelTemp;
        
        WB_CommunityKeyTabs_Controller obj = new WB_CommunityKeyTabs_Controller();
    }
}