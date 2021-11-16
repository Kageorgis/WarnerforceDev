/**
   @Author Cognizant Technology Solutions
   @name WB_EAD_Grid_Controller
   @CreateDate 8 MAY 2018
   @Description This class will be use to create/Edit EAD records.
   @Version <1.0>
   @reference ER - 
*/
global with sharing class WB_EAD_Grid_Controller{
    
    public static ApexPages.StandardController theController;
    public static Integer totalFailedRecords;
    //JSON String to convert picklistWrap object into string
    public String pickWrapJSONString{get; set;}
    
    /**
    * Method to get logged in uSer Locale
    */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }  
        return currentUserLocale;
    }
    
    /**
    * Method to get logged in uSer Locale Language code
    */
    global String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
    
    /**
    * Method to get logged in uSer Locale in Lower case
    */
    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }
    
    /**  
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    } 
    
    /** 
     *  Method to fetch the chunk size  
     *  @name getChunkSizeForRateCards
     *  @param None
     *  @return Chunk size in Integer
     *  @throws None
     */
    global Integer getChunkSizeForEADRecords() {
        return 100;
    }
    
    /** 
     *  Method to fetch the custom setting record to set boolean flag which make grid Editable / Read only for logged in user
     *  @name getIsGridInReadOnlyMode
     *  @param None
     *  @return boolean flag for earliestAvailDate edit access 
     *  @throws None
     */
    global Boolean getEADEditAccess() {
        return (Schema.sObjectType.Earliest_Avail_Date__c.isCreateable() || Schema.sObjectType.Earliest_Avail_Date__c.isUpdateable());
    }
    
    //ER-002186: handsontable get licence key
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    }
    
    /** 
    *  @Description - constructor 
    */ 
    global WB_EAD_Grid_Controller(){
        WB_ObjectsWarpper.PicklistWrapper picklistWrap = new WB_ObjectsWarpper.PicklistWrapper(
        
        getFilterPicklistValues('Earliest_Avail_Date__c', 'Channel__c'),
        getFilterPicklistValues('Earliest_Avail_Date__c', 'Format__c'),
        getFilterPicklistValues('Country__c', 'Territory__c'),
        getFilterPicklistValues('Earliest_Avail_Date__c', 'Country__c'),
        getFilterPicklistValues('Earliest_Avail_Date__c', 'Status__c'),
        getFilterPicklistValues('Earliest_Avail_Date__c', 'Source__c'));
        pickWrapJSONString = JSON.serialize(picklistWrap);

    }
    global WB_EAD_Grid_Controller (ApexPages.Standardcontroller stdCon) {
        
    }
    /**
     *  Method to fetch EAD records based on search criteria  
     *  @name getEADRecords
     *  @param Search criteria
     *  @return WB_EAD_Grid_Controller.EarliestAvailDatesWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<EarliestAvailDatesWrapper> getEADRecords(WB_ObjectsWarpper.SearchFilters filters) { 
        
        Integer maxCount;
        maxCount = WB_Max_Record_Limit__c.getInstance('EAD Grid Record Count') != null ?  Integer.valueOf(WB_Max_Record_Limit__c.getInstance('EAD Grid Record Count').count__c) : 1000;
        
        Integer additonalCount = maxCount + 100;
        
        String EADTitleVal = '%' + filters.EADTitle + '%';
        
        
        List<Earliest_Avail_Date__c> lstEADRecords = new List<Earliest_Avail_Date__c>();
        
        List<EarliestAvailDatesWrapper> wrapperEADRecords = new List<EarliestAvailDatesWrapper>();

        String queryString = '';
        Set<String> setFormats = new Set<String>();
        Set<String> setChannels = new Set<String>();
        Set<String> setCountrys = new Set<String>();
        Set<String> setWBTerritories = new Set<String>();
        Set<String> setSource = new Set<String>();
        
        //Prepare picklist filter values set from Picklist Option
        if(filters.EADFormats !=null){
            setFormats = getPicklistValueSet(filters.EADFormats);}
        if(filters.EADChannel !=null){
            setChannels = getPicklistValueSet(filters.EADChannel);}
        if(filters.WBTerritory !=null){
            setWBTerritories = getPicklistValueSet(filters.WBTerritory);}
        if(filters.EADSource !=null){
            setSource = getPicklistValueSet(filters.EADSource);}
        
        system.debug('setWBTerritories ------------------'+setWBTerritories);
        system.debug('setFormats ------------------'+setFormats);
        
        if(filters != null){
         
            queryString = 'SELECT Id,Name,toLabel(Channel__c),Title__c,Country__c,Country__r.Name,toLabel(Country__r.Territory__c),Earliest_Avail_Date__c,toLabel(Format__c),MPM__c,Source__c,Status__c,Title__r.Name,Video_Version__c' +
                            ' FROM Earliest_Avail_Date__c WHERE Name != null';
            if(filters.EADVideoVersion !=null){
                queryString += ' AND Video_Version__c = \'' + filters.EADVideoVersion + '\'';
            }
            if(filters.EADTitle !=null){
                queryString += ' AND Title__r.name Like \'' + String.escapeSingleQuotes(EADTitleVal) + '\' '; 
            }
            if(filters.EADMPM !=null){
                queryString += ' AND MPM__c = \'' + filters.EADMPM + '\'';
            }
            if(!setChannels.isEmpty()){
                queryString +=  ' AND (Channel__c IN :setChannels)';
            }
            if(!setFormats.isEmpty()){
                queryString +=  ' AND (Format__c IN :setFormats)';
            }
            if(filters.countryName != null && filters.countryName != ''){
               queryString +=  ' AND Country__c = \'' + filters.countryName + '\''; 
            }
            if(!setWBTerritories.isEmpty()){
                queryString +=  ' AND (Country__r.Territory__c IN :setWBTerritories)';  
            }
            if(!setSource.isEmpty()){
                queryString +=  ' AND (Source__c IN :setSource)';  
            }
            
            queryString +=' LIMIT :additonalCount';
            system.debug('queryString ------------------'+queryString);
            lstEADRecords = database.Query(queryString);

            if(!lstEADRecords.isEmpty()){
                for(Earliest_Avail_Date__c ead : lstEADRecords){
                    if(wrapperEADRecords.size() == maxCount){
                        wrapperEADRecords[0].maxLimitExceededMsg = String.format(System.Label.WB_EAD_Record_Max_Limit_Msg,new String[] {string.valueof(maxCount)});
                        break;
                    }
                    EarliestAvailDatesWrapper eadWrap = mapWrapperFields(ead);
                    system.debug('eadWrap:::::'+eadWrap);
                    wrapperEADRecords.add(eadWrap);
                }
            }else{
                EarliestAvailDatesWrapper wrapperObj =new EarliestAvailDatesWrapper();
                wrapperObj.maxLimitExceededMsg= System.Label.WB_No_Records_Found_Massage;
                wrapperEADRecords.add(wrapperObj);
            }
           
        }
        return wrapperEADRecords;
            
    }
    
    /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setEADRecords
     *  @param WB_EAD_Grid_Controller.EarliestAvailDatesWrapper[]
     *  @return sorted WB_EAD_Grid_Controller.EarliestAvailDatesWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<EarliestAvailDatesWrapper> setEADRecords(List<EarliestAvailDatesWrapper> listEADRecords) {

        List<Earliest_Avail_Date__c> listeadRecordToUpsert = new List<Earliest_Avail_Date__c>();
        List<EarliestAvailDatesWrapper> listeadWrappersToUpsert = new List<EarliestAvailDatesWrapper>();

        Map<String,Title__c> mapTitlesRecords = new Map<String,Title__c>();
        Map<String,Country__c> mapCountryRecords = new Map<String,Country__c>();
        
        Set<String> setTitleRecords = new Set<String>();
        Set<String> setCountryRecords = new Set<String>();
        
        totalFailedRecords = 0;
        integer index = 0;
        
        
        for(EarliestAvailDatesWrapper eadWrapper : listEADRecords){
            eadWrapper.rowIndex = index;
            index++;
            if(eadWrapper.isRowModified !=null && eadWrapper.isRowModified == true){
                setTitleRecords.add(eadWrapper.videoVersion);
                setCountryRecords.add(eadWrapper.country);
            }
        }
        
        if(!setTitleRecords.isEmpty()){
            for(Title__c titles : [SELECT id,name,MPM__c,Video_Version__c from Title__c WHERE Video_Version__c IN: setTitleRecords]){
                mapTitlesRecords.put(titles.Video_Version__c,titles);
            }
        }
        if(!setCountryRecords.isEmpty()){
            //ER-002250 - new EAD related changes : added coutnrycode 2 field in query
            for(Country__c c : [SELECT Id,Name,Country_Code2__c,Territory__c FROM Country__c WHERE Name IN :setCountryRecords]){
                mapCountryRecords.put(c.name,c);
            }
        }

        //Prepare picklist filter values set from Picklist Option
        Map<String,String> mapCountryPiclistValues = getPicklistValueFromLabelMap('Country__c', 'Territory__c');
        Map<String,String> mapFormatPiclistValues = getPicklistValueFromLabelMap('Earliest_Avail_Date__c', 'Format__c');
        Map<String,String> mapChannelPicklistValues = getPicklistValueFromLabelMap('Earliest_Avail_Date__c', 'Channel__c');
        Map<String,String> mapStatusPicklistValues = getPicklistValueFromLabelMap('Earliest_Avail_Date__c', 'Status__c');
        
        for(EarliestAvailDatesWrapper wrapper : listEADRecords){
            if(wrapper.isRowModified !=null && wrapper.isRowModified == true){
                Earliest_Avail_Date__c objEADRecord = new Earliest_Avail_Date__c();
                try{
                   objEADRecord = createNewRecord(wrapper,mapFormatPiclistValues,mapChannelPicklistValues,mapTitlesRecords,mapCountryRecords,mapStatusPicklistValues);
                }catch(System.Exception e){
                    system.debug('e.line number ------------'+e.getLineNumber()+'-------------'+e.getMessage());
                    wrapper.validation = e.getMessage();
                    wrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                if (!(mapTitlesRecords.containsKey(wrapper.videoVersion))){
                    wrapper.validation = system.Label.WB_Invalid_Video_Version_error;
                    wrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }else if (!mapCountryRecords.containsKey(wrapper.country)){
                    wrapper.validation = system.Label.WB_Invalid_Country_error;
                    wrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                else if(!mapFormatPiclistValues.containsKey(wrapper.format)){
                    wrapper.validation = system.Label.WB_EAD_Invalid_Format_Error;
                    wrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                else if(!mapChannelPicklistValues.containsKey(wrapper.channel)){
                    wrapper.validation = System.Label.WB_EAD_Invalid_Channel_Error;
                    wrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                else if(!mapStatusPicklistValues.containsKey(wrapper.status)){
                    wrapper.validation = System.label.WB_EAD_Invalid_Status_Error;
                    wrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                else{
                    objEADRecord.Country__c = mapCountryRecords.get(wrapper.country).Id;
                }
                listeadRecordToUpsert.add(objEADRecord);
                listeadWrappersToUpsert.add(wrapper);
                system.debug('wrapper -----------'+wrapper);
            }
            
        }
        system.debug('listeadRecordToUpsert ===================='+listeadRecordToUpsert);
        if(!listeadRecordToUpsert.isEmpty()){
            Database.UpsertResult[] result = Database.Upsert(listeadRecordToUpsert, false);
            //ER-002250 : added new paramter in method to send country map to get country code 2 to form key 
            updateDMLResult(result,listeadWrappersToUpsert,mapCountryRecords);
        }
        
        if(!listEADRecords.isEmpty()) {
            listEADRecords[0].numFailedRecords = totalFailedRecords;
        } 
        system.debug('listEADRecords -----------------'+listEADRecords);
        return listEADRecords;

    }
    
    /**
    *@Name : createNewRecord
    *@Param: wrapper,country list,channel list,format list
    *@return : new EAD record
    *@Discription: create or update teh EAD record based on criteria
    */
    
    private static Earliest_Avail_Date__c createNewRecord(EarliestAvailDatesWrapper eadWrapper,map<String,String> mapChannel ,map<String,String> mapFormat,map<String,Title__c> mapTitle,map<String,Country__c> mapcountry,map<String,String> mapStatus){
        
        system.debug('eadWrapper -----------------'+eadWrapper);
        
        Earliest_Avail_Date__c eadRecord = new Earliest_Avail_Date__c();
        if(eadWrapper.existingId != null){
            eadRecord.id = eadWrapper.existingId;
        }
        eadRecord.Channel__c = mapChannel.containsKey(eadWrapper.channel) ? mapChannel.get(eadWrapper.channel) : eadWrapper.channel;
        eadRecord.Format__c = mapFormat.containsKey(eadWrapper.format) ? mapFormat.get(eadWrapper.format) : eadWrapper.format;
        eadRecord.Earliest_Avail_Date__c = eadWrapper.earliestAvailDate <> null ? date.parse(eadWrapper.earliestAvailDate) : null;
        eadRecord.Source__c = system.Label.WB_EAD_Source_Manual;
        eadRecord.Country__c = mapcountry.containsKey(eadWrapper.country) ? mapcountry.get(eadWrapper.country).Id : null;
        eadRecord.Status__c = mapStatus.containsKey(eadWrapper.status) ? mapStatus.get(eadWrapper.status) : null;
        eadRecord.Title__c = mapTitle.containsKey(eadWrapper.videoVersion) ? mapTitle.get(eadWrapper.videoVersion).Id : null;
   
        return eadRecord;
    }
    
    /**
    *@name: updateDMLResult
    *@discription: method to perform DML operations
    *@Parameters: Database.saveResult and list of wrapper
    */ 
    public static void updateDMLResult(list<Database.UpsertResult> results,List<EarliestAvailDatesWrapper> wrapperToUpsert,Map<String,Country__c> mapCountryRecords){
        Map<Id,EarliestAvailDatesWrapper> successRecMap = new Map<Id,EarliestAvailDatesWrapper>();
        system.debug('wrapperToUpsert -------'+wrapperToUpsert);
        //ER-002250 : map to get failed records with key
        Map<String,EarliestAvailDatesWrapper> mapFailedEADwithKeys = new Map<String,EarliestAvailDatesWrapper>();
        
        for(Integer i=0;i<results.size();i++){
            
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML;
                String key;
                if(((error.getMessage()).contains('insufficient access rights on object'))){
                    failedDML = system.Label.WB_EAD_Access_error;
                }
                else if((error.getMessage()).contains('duplicate value found')){
                        failedDML = system.Label.WB_EAD_Already_Exist;
                        //ER-002250 : code to form a key for failed records.
                        string countryCode = mapCountryRecords.get(wrapperToUpsert.get(i).country).Country_Code2__c;
                        key = wrapperToUpsert.get(i).videoVersion+'_'+countryCode+'_'+wrapperToUpsert.get(i).channel+'_'+wrapperToUpsert.get(i).format;
                }
                else{
                    failedDML = error.getMessage();
                }
                
                totalFailedRecords++;
                wrapperToUpsert.get(i).validation = failedDML;
                wrapperToUpsert.get(i).errorOccured = true;
                //ER-002250 : fill the failed record map againest key
                mapFailedEADwithKeys.put(key,wrapperToUpsert.get(i));
                system.debug('mapFailedEADwithKeys -------'+mapFailedEADwithKeys);
            }else{
                wrapperToUpsert.get(i).existingId = results.get(i).getId();
                wrapperToUpsert.get(i).errorOccured = false;
                wrapperToUpsert.get(i).isRowModified = false;
                if(results[i].isCreated()){
                    wrapperToUpsert.get(i).validation = System.label.WB_Upload_Message_Created;
                }else{
                    wrapperToUpsert.get(i).validation = System.label.WB_Upload_Message_Updated;
                }
            }
            successRecMap.put(results.get(i).getId(),wrapperToUpsert.get(i));
        }
        
        //ER-002250 : commented the if condition to query only for success records and added a filter to query failed records as well.
        //if(!successRecMap.values().isEmpty()){
            for(Earliest_Avail_Date__c ead : [SELECT Id,Name,Channel__c,Title__c,Country__c,Country__r.Name,Country__r.Country_Code2__c,Earliest_Avail_Date__c,toLabel(Country__r.Territory__c),Format__c,MPM__c,Source__c,Status__c,Title__r.Name,Video_Version__c
                                              From Earliest_Avail_Date__c Where Id IN :successRecMap.keySet() OR Key__c IN : mapFailedEADwithKeys.keySet()]){
                system.debug('ead ----------'+ead);
                string key = ead.Video_Version__c+'_'+ead.Country__r.Country_Code2__c+'_'+ead.Channel__c+'_'+ead.Format__c;
                if(successRecMap.containsKey(ead.Id)){
                    successRecMap.get(ead.Id).WBTerritory = ead.Country__r.Territory__c;
                    successRecMap.get(ead.Id).title = ead.Title__r.Name;
                    successRecMap.get(ead.Id).channel = ead.Channel__c;
                    successRecMap.get(ead.Id).format = ead.Format__c;
                    successRecMap.get(ead.Id).name = ead.Name;
                    //successRecMap.get(ead.Id).earliestAvailDate = String.valueOf(ead.Earliest_Avail_Date__c);
                    successRecMap.get(ead.Id).MPM = ead.MPM__c;
                    successRecMap.get(ead.Id).source = ead.Source__c;
                    successRecMap.get(ead.Id).status = ead.Status__c;
                    successRecMap.get(ead.Id).videoVersion = ead.Video_Version__c;
                }
                //ER-002250 : New EAD changes to bulk update by copy paste
                if(mapFailedEADwithKeys.containsKey(key)){
                    system.debug('map failed records');
                    mapFailedEADwithKeys.get(key).existingId = ead.Id;
                    mapFailedEADwithKeys.get(key).WBTerritory = ead.Country__r.Territory__c;
                    mapFailedEADwithKeys.get(key).title = ead.Title__r.Name;
                    mapFailedEADwithKeys.get(key).channel = ead.Channel__c;
                    mapFailedEADwithKeys.get(key).format = ead.Format__c;
                    mapFailedEADwithKeys.get(key).name = ead.Name;
                    mapFailedEADwithKeys.get(key).MPM = ead.MPM__c;
                    mapFailedEADwithKeys.get(key).source = ead.Source__c;
                    mapFailedEADwithKeys.get(key).status = ead.Status__c;
                    mapFailedEADwithKeys.get(key).videoVersion = ead.Video_Version__c;
                }
                //ER-002250 - end
            }
        //}
    }
    
     /**
    *  @Description - wrapper class
    *  @name  EarliestAvailDatesWrapper 
    */
    global class EarliestAvailDatesWrapper {
        public String validation = '';
        public Id existingId;
        public boolean isRowModified = false;
        public Integer rowIndex = 0;
        public String  country = '';
        public String channel = '';
        public String  format = '';
        public String MPM ='';
        public String  earliestAvailDate;
        public String source = ''; 
        public String title = ''; 
        public String status = ''; 
        public String videoVersion = ''; 
        public String WBTerritory = '';
        public boolean errorOccured = false;
        public Integer numFailedRecords;
        public String maxLimitExceededMsg = '';
        public String name = '';
    }
    
    /** 
    *  Method to MAP EAD Record fields to the wrapper 
    *  @name mapWrapperFields
    *  @param Earliest_Avail_Date__c ead
    *  @return EarliestAvailDatesWrapper 
    *  @throws None
    */
    private static EarliestAvailDatesWrapper mapWrapperFields(Earliest_Avail_Date__c ead){
        system.debug('ead -----------'+ead);
        EarliestAvailDatesWrapper eadWrap = new EarliestAvailDatesWrapper();
        eadWrap.existingId = ead.id;
        eadWrap.name = ead.Name;
        eadWrap.title = ead.Title__r.Name;
        eadWrap.country = ead.Country__r.name;
        eadWrap.status = ead.Status__c;
        eadWrap.channel = ead.Channel__c;
        eadWrap.earliestAvailDate = String.valueOf(ead.Earliest_Avail_Date__c);
        eadWrap.format = ead.Format__c;
        eadWrap.source = ead.Source__c;
        eadWrap.WBTerritory = ead.Country__r.Territory__c;
        eadWrap.MPM = ead.MPM__c;
        eadWrap.videoVersion = ead.Video_Version__c;
        return eadWrap;
    }
  
    
    /**
     * Method to fetch picklist values for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     */
    global static WB_ObjectsWarpper.PicklistVal getFilterPicklistValues(String object_name, String field_name) {
      
      List<WB_ObjectsWarpper.PicklistOption> options = new List<WB_ObjectsWarpper.PicklistOption>();
      List<String> piclistVales = new List<String>(); 
      if(field_name == 'Territory__c'){
          for(Country__c c : [Select Id,Name,Territory__c From Country__c ORDER BY Name]){
              piclistVales.add(c.Territory__c);
              //piclistVales.add(c.Name);
          }
      }
      if(field_name == 'Country__c'){
          for(Country__c c : [Select Id,Name,Territory__c From Country__c ORDER BY Name]){
              //piclistVales.add(c.Territory__c);
              piclistVales.add(c.Name);
          }
      }else{
          Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
          List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
          
          for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                if(field_name != 'Format__c' && field_name != 'Channel__c'){
                    piclistVales.add(a.getLabel()); //add the value and label to our final list
                    options.add(new WB_ObjectsWarpper.PicklistOption(a.getValue(), a.getLabel()));
                }
                if((field_name == 'Channel__c' && a.getLabel() != 'Physical') || (field_name == 'Format__c' && a.getLabel() != '4KBD' && a.getLabel() != 'DVD' && a.getLabel() != '3DBD' && a.getLabel() != 'BD')){
                    piclistVales.add(a.getLabel()); //add the value and label to our final list
                    options.add(new WB_ObjectsWarpper.PicklistOption(a.getValue(), a.getLabel()));
                }
          }
      }
      WB_ObjectsWarpper.PicklistVal pickWrap = new WB_ObjectsWarpper.PicklistVal(piclistVales,options);
      return pickWrap; //return the List
    }
   
    /**
     *  Method to fill picklist set with values.  
     *  @name getPicklistValueSet
     *  @param WB_ObjectsWarpper.PicklistOption[] picklistOptions
     *  @return set of Strign containing picklist values.
     *  @throws None
    */
    public static set<String> getPicklistValueSet(WB_ObjectsWarpper.PicklistOption[] picklistOptions){
        Set<String> picklistValSet = new Set<String>();
        for(WB_ObjectsWarpper.PicklistOption po : picklistOptions){
            picklistValSet.add(po.value);
        }
        return picklistValSet;
    } 
    
    /**
     * Method to get picklist value for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     * @param pickLabel picklist label
     * @return Map<String,String> - Map of picklist label vs Value
     */
    private static Map<String,String> getPicklistValueFromLabelMap(String object_name, String field_name) {
        Map<String,String> picklistMap = new Map<String,String>();
        Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            picklistMap.put(a.getLabel(),a.getValue());
        }
        return picklistMap;
    }
    
    /**
     *  Method to export CSV file
     *  @name exportCSVFile
     *  @param List<String> excelHeaderNames
     *  @return PageReference - Redirect URL
     *  @throws None
     */
     
    @RemoteAction
    global static PageReference exportCSVFile(List<String> excelHeaderNames) {
        String urlLocatorPage = '/apex/CRM_ExportCSVFileFromUploadExtract';
        PageReference pageref = new PageReference(urlLocatorPage);
        pageref.getParameters().put('excelHeaderNames',String.join(excelHeaderNames,','));
        system.debug('excelHeaderNames : '+excelHeaderNames);
        return pageref;
    }
}