public with sharing class NavigationUtilityClass {
    
   
    @AuraEnabled(cacheable=true)
    public static List<TabInfo> getTabsMetaData(){
		
		
		
		Map<String,TabInfo> appMenuItemMap = new Map<String,TabInfo>();
		Set<String> tabsSet = new Set<String>{'Re-Price Wizard','Price-Update Wizard','EAD Maintenance','Title Groups','Rate Cards','Title Search','MPM Search','Import Client Avails'};
		List<TabInfo> tabDetailsList = new List<TabInfo>();
		
		String urlInstance = String.valueof(System.URL.getSalesforceBaseURL()).replace('Url:[delegate=','').replace(']','');
		system.debug('urlInstance :'+urlInstance);
		
		for(String tabName : tabsSet){
			
			TabInfo tabInfoRec = new TabInfo();
			if(appMenuItemMap!= Null && appMenuItemMap.containsKey(tabName))
                continue;
			if(tabName == 'Re-Price Wizard'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01r0B000000kHji&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom40_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			
			if(tabName == 'Price-Update Wizard'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01r0B000000kHjn&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom16_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			
			if(tabName == 'EAD Maintenance'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01r0B000000Unym&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom63_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			if(tabName == 'Title Groups'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/a3x/o';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom93_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			} 
			
			if(tabName == 'Rate Cards'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01r0B000000UnrC&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom83_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			if(tabName == 'Title Search'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01rU0000000UZKZ&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom49_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			if(tabName == 'MPM Search'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01rU0000000Ubpl&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom10_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			if(tabName == 'Import Client Avails'){
				tabInfoRec.label = tabName;
                tabInfoRec.url = urlInstance +'/servlet/servlet.Integration?lid=01rU0000000UhWH&ic=1&linkToken=VmpFPSxNakF4T1MweE1pMHdOMVF3TmpvME1UbzFNUzQyTmpoYSxVZGZaMW1xM044S1I3WWZEYnVpeEcwLFlXWmtNR0po';
                tabInfoRec.iconUrl = urlInstance +'/img/icon/t4v35/custom/custom74_120.png';
				appMenuItemMap.put(String.valueOf(tabInfoRec.label),tabInfoRec);
			}
			
		}
		
        tabDetailsList = appMenuItemMap.values();
        return tabDetailsList;
    }


    public class TabInfo{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String iconUrl{get;set;}

       
    }
}