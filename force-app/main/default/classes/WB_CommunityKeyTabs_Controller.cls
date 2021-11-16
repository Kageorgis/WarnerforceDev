/******* 
Name: WB_CommunityKeyTabs_Controller
Creation Date- 9 March 2017
Description- Controller for for Key Release paln and Key Rights Tabs used in WB RRT Community
Author- Purushottam Gupta

09/17/2019 updated  by hari -  for vendor grid replaced Deluxe with vendor 
*******/
public with sharing class WB_CommunityKeyTabs_Controller{
    Public String keyRPTab1 {get;set;}
    Public String keyRPTab2 {get;set;}
    Public String keyRPTab3 {get;set;}
    Public String keyRPTab4 {get;set;}
    Public String keyRightTab1 {get;set;}
    Public String keyRightTab2 {get;set;}
    Public String keyRightTab3 {get;set;}
    Public String keyRightTab4 {get;set;}
    
    Public String releasPlanGrid {get;set;}
    Public String rightsGrid {get;set;}
    Public String rrtGrid {get;set;}
    Public String vendorGrid {get;set;}
    
    public WB_CommunityKeyTabs_Controller(){
        
        for(PowerLoader__QueryPanelTemplate__c queryPnlTemp : [SELECT Id, Name, PowerLoader__Query_Panel_Name__c FROM PowerLoader__QueryPanelTemplate__c
                                                               WHERE PowerLoader__Query_Panel_Name__c IN ('Key_Release_Plan_RRT','Key_Rights_RRT')])
        {
            if(queryPnlTemp.PowerLoader__Query_Panel_Name__c == 'Key_Release_Plan_RRT'){
                if(queryPnlTemp.Name == 'Require Action')
                    keyRPTab1 = queryPnlTemp.Id;
                else if(queryPnlTemp.Name == 'Upcoming')
                    keyRPTab2 = queryPnlTemp.Id;
                else if(queryPnlTemp.Name == 'Recent')
                    keyRPTab3 = queryPnlTemp.Id;
                else if(queryPnlTemp.Name == 'Not Releasing')
                    keyRPTab4 = queryPnlTemp.Id;
            }
            else if(queryPnlTemp.PowerLoader__Query_Panel_Name__c == 'Key_Rights_RRT'){
                if(queryPnlTemp.Name == 'Upcoming')
                    keyRightTab1 = queryPnlTemp.Id;
                else if(queryPnlTemp.Name == 'Recent')
                    keyRightTab2 = queryPnlTemp.Id;
                else if(queryPnlTemp.Name == 'Expiring')
                    keyRightTab3 = queryPnlTemp.Id;
                else if(queryPnlTemp.Name == 'Changed In Last 30 Days')
                    keyRightTab4 = queryPnlTemp.Id;
            }
        }
        
        for(PowerGrid__Grid__c grid : [SELECT Id, Name FROM PowerGrid__Grid__c WHERE Name IN ('Key Release Plan Grid','Key Rights Grid','RRT Grid','Vendor Grid')])
        {
            if(grid.Name == 'Key Release Plan Grid')
                releasPlanGrid = grid.Id;
            else if(grid.Name == 'Key Rights Grid')
                rightsGrid = grid.Id;
            else if(grid.Name == 'RRT Grid')
                rrtGrid = grid.Id;
            else if(grid.Name == 'Vendor Grid')
                vendorGrid = grid.Id;
        }
    }
}