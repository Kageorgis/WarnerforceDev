@isTest
public class NavigationUtilityClass_Test {
    
    
    
       
    @isTest static void testgetTabsMetaData() {
        
      List<NavigationUtilityClass.TabInfo> tabDetailsList = new List<NavigationUtilityClass.TabInfo>();  
        Set<String> tabsSet = new Set<String>{'Re-Price Wizard','Price-Update Wizard','EAD Maintenance','Title Groups','Rate Cards','Title Search','MPM Search','Import Client Avails'};
        
         tabDetailsList=NavigationUtilityClass.getTabsMetaData();  
        
        System.assertEquals(8,tabDetailsList.size());
     
    }
}