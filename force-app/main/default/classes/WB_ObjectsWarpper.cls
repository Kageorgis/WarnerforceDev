global class WB_ObjectsWarpper {
    
    /*Wrapper to set search critera filters*/
    global class SearchFilters {

        global PicklistOption[] EADFormats;
        global PicklistOption[] EADChannel;
        global String countryName;
        global String EADVideoVersion;
        global String EADTitle;
        global String EADMPM;
        global PicklistOption[] WBTerritory;
        global PicklistOption[] EADSource;
        
    }
    
    /*wrapper to set picklist value */
    global class PicklistOption {
        global String label;
        global String value;
        global Boolean selected;
        
        global PicklistOption(String val, String lbl) {
            label = lbl;
            value = val;
            selected = false;
        }
    } 
    
    /**
    * Wrapper Class to store Picklist values
    */
    global class PicklistWrapper{
        
        PicklistVal channelValues;
        PicklistVal formatValues;
        PicklistVal WBTerritoryValues;
        PicklistVal countryValues;
        PicklistVal statusValues;
        PicklistVal sourceValues;
        
        global PicklistWrapper(
                               PicklistVal channelValues,
                               PicklistVal formatValues,
                               PicklistVal WBTerritoryValues,
                               PicklistVal countryValues,
                               PicklistVal statusValues,
                               PicklistVal sourceValues)
        {
            this.channelValues = channelValues;
            this.formatValues = formatValues;
            this.WBTerritoryValues = WBTerritoryValues;
            this.countryValues = countryValues;
            this.statusValues = statusValues;
            this.sourceValues = sourceValues;
        }
    } 
    /**
    *  @Description - wrapper class
    *  @name  RateCardWrapper 
    */
    global class PicklistVal{
        List<String> picklist = new List<String>();
        List<WB_ObjectsWarpper.PicklistOption> filterPicklist = new List<WB_ObjectsWarpper.PicklistOption>();
        
        global picklistVal(List<String> picklist,List<WB_ObjectsWarpper.PicklistOption> filterPicklist){
            this.picklist = picklist;
            this.filterPicklist = filterPicklist;
        }
    }
}