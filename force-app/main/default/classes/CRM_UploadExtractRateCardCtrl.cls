/**
   @Author: Cognizant
   @name: CRM_UploadExtractRateCardCtrl
   @CreateDate: 18 April 2018
   @Description: This class is used to search,Edit,Insert and Delete the Rate cards records. 
   @Version <1.0>
   @reference: Requirement no. 984 - Advance Promo Pricing Project.
*/
global with sharing class CRM_UploadExtractRateCardCtrl{
    
    //JSON String to convert picklistWrap object into string
    public String pickWrapJSONString{get; set;}
    public static Integer totalFailedRecords;
    /** 
    *  @Description - constructor 
    *  @name  CRM_UploadExtractRateCardCtrl
    */ 
    global CRM_UploadExtractRateCardCtrl() {
        PicklistWrapper picklistWrap = new PicklistWrapper(
                                                getFilterPicklistValues('Rate_Card__c', 'Country__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'Content_Type__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'Channel__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'Format__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'SRP_Currency__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'Rate_Card_Type__c'),
                                                getFilterPicklistValues('Country__c', 'Territory__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'RC_Lifecycle__c'),
                                                getFilterPicklistValues('Rate_Card__c', 'RC_Category__c')); //ER-007015
        pickWrapJSONString = JSON.serialize(picklistWrap);
    } 
    
    /**
     *  Method to get RC Records
     *  @name getRateCardRecords
     *  @param String searchText - To search RC records based on value, Boolean excludeExpiredRc - To filter RC Record based on RC Life Cycle field
     *  @return List of wrapper record - List<RateCardWrapper>
     *  @throws None
    */
    @RemoteAction 
    global static List<RateCardWrapper> getRateCardRecords(FilterWrapper filterWrap) {
        
        Integer maxCount = CRM_Max_Product_Limit__c.getInstance('Rate Card Upload Extract') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Rate Card Upload Extract').Count__c) : 1000;
        Integer additonalCount = maxCount + 100;
        
        //Prepare picklist filter values set from Picklist Option
        Set<String> contentTypeSet = getPicklistValueSet(filterWrap.contentType);
        Set<String> formatSet = getPicklistValueSet(filterWrap.format);
        Set<String> channelSet = getPicklistValueSet(filterWrap.channel);
        Set<String> WBTerritorySet = getPicklistValueSet(filterWrap.WBTerritory);
        Set<String> RCLifecycleSet = getPicklistValueSet(filterWrap.RCLifecycle);
        Set<String> RCCtegorySet = getPicklistValueSet(filterWrap.RCCategory); //ER-007015
        
        List<RateCardWrapper> rcWrapList = new List<RateCardWrapper>();
        Set<Id> setMtachingRecordIds = getSearchedRecordIds(filterWrap.text);
        
        String soqlStr = 'Select Id,Name,Account__c,Split__c,Account__r.Name,toLabel(Content_Type__c),toLabel(Channel__c),toLabel(Format__c),Price_Tier__c,WSP1__c,WSP2__c,WSP3__c,Storefront__r.Pricing_Currency__c,'+
                         'Accounting_Category__c,SRP__c,SRP_Currency__c,WSP_Currency__c,toLabel(Rate_Card_Type__c),Start_Date__c,End_Date__c,Storefront__r.WSP_Currency__c,Comments__c,'+
                         'RC_Lifecycle__c,WB_Territory__c,RC_Category__c,Country__c,Country__r.name,Invalid_Capability__c,Storefront__r.Selected_Combination__c'+
                         ' FROM Rate_Card__C WHERE Account__c != null AND Country__c != null';
        
        if(filterWrap.countryId != null && filterWrap.countryId != ''){
            soqlStr +=  ' AND (Country__c = \''+filterWrap.countryId+'\')';
        }
        if(!contentTypeSet.isEmpty()){
            soqlStr +=  ' AND (Content_Type__c IN :contentTypeSet)';
        }
        if(!formatSet.isEmpty()){
            soqlStr +=  ' AND (Format__c IN :formatSet)';
        }
        if(!WBTerritorySet.isEmpty()){
            soqlStr +=  ' AND (WB_Territory__c IN :WBTerritorySet)';
        }
        if(!channelSet.isEmpty()){
            soqlStr +=  ' AND (Channel__c IN :channelSet)';
        }
        if(!RCLifecycleSet.isEmpty()){
            soqlStr +=  ' AND (RC_Lifecycle__c IN :RCLifecycleSet)';
        }
        if(filterWrap.text != null && filterWrap.text != ''){
            soqlStr +=  ' AND (Account__c IN :setMtachingRecordIds)';
        }
        
        //ER-007015 - Start
        if(!RCCtegorySet.isEmpty()){
            soqlStr +=  ' AND (RC_Category__c IN :RCCtegorySet)';
        }
        //ER-007015 - End
        
        soqlStr += ' ORDER BY Account__r.Name,Country__r.name,Content_Type__c,Channel__c,Format__c,Price_Tier__c LIMIT :additonalCount';
        
        List<Rate_Card__c> lstRateCard = new List<Rate_Card__c>();
        lstRateCard = Database.query(soqlStr);
        if(!lstRateCard.isEmpty()){
            for(Rate_Card__c rc : lstRateCard){
                if(rcWrapList.size() == maxCount){
                    rcWrapList[0].maxLimitExceededMsg = String.format(System.Label.CRM_Rate_Card_Max_Limit_Msg,new String[] {string.valueof(maxCount)});
                    break;
                }
                RateCardWrapper rcWrap = mapWrapperFields(rc);
                rcWrapList.add(rcWrap);
            }
        }else{
            RateCardWrapper wrapperObj =new RateCardWrapper();
            wrapperObj.maxLimitExceededMsg= System.Label.CRM_No_Records_Found_For_NR_Mass_Update;
            rcWrapList.add(wrapperObj);
        }
        
        system.debug('rcWrapList==============>'+rcWrapList[0].rcCategory);
        return rcWrapList;
    }
    
    /**
     *  Method to get account or country or Rate Card recrods Id containing the search text.  
     *  @name getAccountOrProductIds
     *  @param String searchText - To search RC records based on value, Boolean excludeExpiredRc - To filter RC Record based on RC Life Cycle field
     *  @return set of Ids containing search text.
     *  @throws None
    */
    public static set<Id> getSearchedRecordIds(string quickSearchText){
   
        Set<Id> setMtachingRecordIds = new Set<Id>();
        String sosl_search;
        
        if(quickSearchText != null && quickSearchText.trim() != ''){
            quickSearchText = String.escapeSingleQuotes(quickSearchText);
            
            sosl_search = quickSearchText;
            sosl_search = sosl_search.replace(':', '\\:');
            sosl_search = sosl_search.replace('-', '\\-');
            sosl_search = sosl_search.replace('+', '\\+');
            sosl_search = sosl_search.replace('&', '\\&');
            sosl_search = sosl_search.replace('!', '\\!');
            sosl_search = sosl_search.replace('^', '\\^');
            
            
            String SOSL_QUERY = 'FIND {'+ sosl_search +'} IN ALL FIELDS RETURNING Account(Id,AccountNumber,Name)';
            List<List<SObject>> searchResult = Search.query(SOSL_QUERY);
            
            for(sObject[] listObj : searchResult) {
                for(sObject sobj : listObj) {
                    string accountName = (string)sobj.get('Name') !=null ? (string)sobj.get('Name') : ''; 
                    if(accountName.containsIgnoreCase(quickSearchText)){
                        setMtachingRecordIds.add((Id)sobj.get('Id'));
                    }
                }
            }
        }
        return setMtachingRecordIds;
    }
    
    /**
     *  Method to save Rate Cards in System
     *  @name saveRateCards
     *  @param List<RateCardWrapper> rateCardWrapList - wrapper list of RateCards
     *  @return List<RateCardWrapper> - wrapper list of RateCards
     *  @throws None
    */
    @RemoteAction 
    public static List<RateCardWrapper> saveRateCards(List<RateCardWrapper> rateCardWrapList){
        
        List<RateCardWrapper> listRCWrappersToDelete = new List<RateCardWrapper>();
        List<Rate_Card__c> listRCRecordToUpsert = new List<Rate_Card__c>();
        List<RateCardWrapper> listRCWrappersToUpsert = new List<RateCardWrapper>();
        
        Map<String,List<Id>> mapOfAccNameToId = new Map<String,List<Id>>();
        Map<String,Id> mapOfCountrToId = new Map<String,Id>();
        
        Set<String> accountNameSet = new Set<String>();
        Set<String> countryNameSet = new Set<String>();
        
        totalFailedRecords = 0;
        integer index = 0;
        
        for(RateCardWrapper rcWrapper : rateCardWrapList){
            rcWrapper.rowIndex = index;
            index++;
            if(rcWrapper.isRowRemoved !=null && rcWrapper.isRowRemoved == true){
                listRCWrappersToDelete.add(rcWrapper); 
            }else if(rcWrapper.isRowModified !=null && rcWrapper.isRowModified == true){
                accountNameSet.add(rcWrapper.accountName);
                countryNameSet.add(rcWrapper.country);
            }
        }
        
        if(!accountNameSet.isEmpty() && !countryNameSet.isEmpty()){
            for(Account acc : [SELECT Id,Name FROM Account WHERE Name IN :accountNameSet AND RecordTypeId = :CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT]){
                if(mapOfAccNameToId.containsKey(acc.name)){
                    mapOfAccNameToId.get(acc.name.toLowerCase()).add(acc.Id);
                }else{
                    mapOfAccNameToId.put(acc.name.toLowerCase(),new List<Id>{acc.Id});
                }
            }
            for(Country__c c : [SELECT Id,Name FROM Country__c WHERE Name IN :countryNameSet]){
                mapOfCountrToId.put(c.name,c.Id);
            }
        }
         if(!listRCWrappersToDelete.isEmpty()){
            Integer[] lstRowIndexToRemove =  deleteRateCards(listRCWrappersToDelete);
            for(Integer i= lstRowIndexToRemove.size()-1; i >=0; i--) {
                   Integer indexToRemove = lstRowIndexToRemove[i];
                   rateCardWrapList.remove(indexToRemove);
            }
        }
        
        //Prepare picklist filter values set from Picklist Option
        Map<String,String> rateCardTypeMap = getPicklistValueFromLabelMap('Rate_Card__c', 'Rate_Card_Type__c');
        Map<String,String> contentTypeMap = getPicklistValueFromLabelMap('Rate_Card__c', 'Content_Type__c');
        Map<String,String> formatMap = getPicklistValueFromLabelMap('Rate_Card__c', 'Channel__c');
        Map<String,String> channelMap = getPicklistValueFromLabelMap('Rate_Card__c', 'Format__c');
        
        
        for(RateCardWrapper rcWrapper : rateCardWrapList){
            
            if(rcWrapper.isRowModified !=null && rcWrapper.isRowModified == true){
                Rate_Card__c rcObj = new Rate_Card__c();
                try{
                   rcObj = createRcRecord(rcWrapper,rateCardTypeMap,contentTypeMap,formatMap,channelMap);
                }catch(System.Exception e){
                    rcWrapper.validation = e.getMessage();
                    rcWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }
                if (!mapOfAccNameToId.containsKey(rcWrapper.accountName.toLowerCase())){
                    rcWrapper.validation = system.label.CRM_Rate_Cear_Account_Not_found;
                    rcWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }else if (!mapOfCountrToId.containsKey(rcWrapper.country)){
                    rcWrapper.validation = system.label.CRM_Rate_card_Country_Not_Found;
                    rcWrapper.errorOccured = true;
                    totalFailedRecords++;
                    continue;
                }else{
                    if(mapOfAccNameToId.get(rcWrapper.accountName.toLowerCase()).size() > 1){
                        rcWrapper.validation = system.label.CRM_Rate_Card_Multiple_Account_found;
                        rcWrapper.errorOccured = true;
                        totalFailedRecords++;
                        continue;
                    }else{
                        rcObj.Account__c = mapOfAccNameToId.get(rcWrapper.accountName.toLowerCase())[0];
                    }
                    rcObj.Country__c = mapOfCountrToId.get(rcWrapper.country);
                }
                listRCRecordToUpsert.add(rcObj);
                listRCWrappersToUpsert.add(rcWrapper);
            }
        }
        
        if(!listRCRecordToUpsert.isEmpty()){
            Database.UpsertResult[] result = Database.Upsert(listRCRecordToUpsert, false);
            upsertDMLResultForRCRecords(result,listRCWrappersToUpsert);
        }
        
        if(!rateCardWrapList.isEmpty()) {
            rateCardWrapList[0].numFailedRecords = totalFailedRecords;
        } 
        
        return rateCardWrapList;
    }
    
    /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name upsertDMLResultForRCRecords
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
    */
    global static void upsertDMLResultForRCRecords(list<Database.UpsertResult> results,List<RateCardWrapper> rcWrapList) {
        Map<Id,RateCardWrapper> successRecMap = new Map<Id,RateCardWrapper>();
        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                totalFailedRecords++;
                rcWrapList.get(i).validation = failedDML;
                rcWrapList.get(i).errorOccured = true;
            }else{
                rcWrapList.get(i).existingId = results.get(i).getId();
                rcWrapList.get(i).errorOccured = false;
                rcWrapList.get(i).isRowModified = false;
                if(results[i].isCreated()){
                    rcWrapList.get(i).validation = System.label.CRM_Upload_Message_Created;
                }else{
                    rcWrapList.get(i).validation = System.label.CRM_Upload_Message_Updated;
                }
                successRecMap.put(results.get(i).getId(),rcWrapList.get(i));
            }
        }
        if(!successRecMap.values().isEmpty()){
            for(Rate_Card__c rc : [Select Id,Name,WB_Territory__c,Invalid_Capability__c,Storefront__r.Selected_Combination__c,Storefront__r.Pricing_Currency__c,
                                   Storefront__r.WSP_Currency__c,RC_Category__c,RC_Lifecycle__c From Rate_Card__c Where Id IN :successRecMap.keySet()]){
                if(successRecMap.containsKey(rc.Id)){
                    successRecMap.get(rc.Id).WBTerritory = rc.WB_Territory__c;
                    successRecMap.get(rc.Id).SFWSPCurrency = rc.Storefront__r.WSP_Currency__c;
                    successRecMap.get(rc.Id).SFSRPCurrency = rc.Storefront__r.Pricing_Currency__c;
                    successRecMap.get(rc.Id).SFSRPCurrency = rc.Storefront__r.Pricing_Currency__c;
                    successRecMap.get(rc.Id).name = rc.Name;
                    successRecMap.get(rc.Id).invalidCapability = rc.Invalid_Capability__c;
                    successRecMap.get(rc.Id).sfSelCom = rc.Storefront__r.Selected_Combination__c;
                    successRecMap.get(rc.Id).RCLifecycle = rc.RC_Lifecycle__c;
                }
            }
        }
    }
    
    /**
     *  Method to fetch user input and perform delete operation on existing records
     *  @name deleteRateCards
     *  @param List<RateCardWrapper> lstRCWrappersToDelete
     *  @return Integer[] list of row indexes to be removed from original list
     *  @throws None
     */ 
    global static Integer[] deleteRateCards(List<RateCardWrapper> lstRCWrappersToDelete) {
        
        List<Id> listRCIdsToRemove = new List<Id>();
        List<RateCardWrapper> listRCWrappersToRemove = new List<RateCardWrapper>(); 
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        
        if(lstRCWrappersToDelete!=null) {
            for (RateCardWrapper wrapper : lstRCWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    wrapper.isRowRemoved  = false;
                    wrapper.errorOccured = false;
                    
                    listRCWrappersToRemove.add(wrapper);                    
                    listRCIdsToRemove.add(wrapper.existingId);
                }
                else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }
            }
            
            list<Database.DeleteResult> deleteLiResults = Database.delete(listRCIdsToRemove,false);
            for(Integer i=0; i < deleteLiResults.size(); i++){
                RateCardWrapper rcWrapper = listRCWrappersToRemove.get(i);
                rcWrapper.isRowRemoved = false;
                
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    totalFailedRecords++;
                    
                    rcWrapper.validation = failedDML;
                    rcWrapper.errorOccured = true;
                 } else {
                    lstRowIndexToRemove.add(rcWrapper.rowIndex);
                }
            }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove;
    }
    
    /**
     *  Method to fill picklist set with values.  
     *  @name getPicklistValueSet
     *  @param CRM_DataObjects.PicklistOption[] picklistOptions
     *  @return set of Strign containing picklist values.
     *  @throws None
    */
    //US#975  start
    public static set<String> getPicklistValueSet(CRM_DataObjects.PicklistOption[] picklistOptions){
        Set<String> picklistValSet = new Set<String>();
        if(picklistOptions != null){
            for(CRM_DataObjects.PicklistOption po : picklistOptions){
                picklistValSet.add(po.value);
            }
        }
        return picklistValSet;
    }
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
     * Method to fetch picklist values for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     */
    global static PicklistVal getFilterPicklistValues(String object_name, String field_name) {
      
      List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();
      List<String> piclistVales = new List<String>(); 
      
      if(field_name == 'Country__c'){
          for(Country__c c : [Select Id,Name From Country__c ORDER BY Name]){
              piclistVales.add(c.Name);
          }
      }else if(field_name == 'RC_Lifecycle__c'){
          options.add(new CRM_DataObjects.PicklistOption(System.label.CRM_RC_Life_Cycle_Active_Current,System.label.CRM_RC_Life_Cycle_Active_Current));
          options.add(new CRM_DataObjects.PicklistOption(System.label.CRM_RC_Life_Cycle_Active_Future,System.label.CRM_RC_Life_Cycle_Active_Future));
          options.add(new CRM_DataObjects.PicklistOption(System.label.CRM_RC_Life_Cycle_History_Expired,System.label.CRM_RC_Life_Cycle_History_Expired));
      }else{
          Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
          List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
          
          for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                piclistVales.add(a.getLabel()); //add the value and label to our final list
                options.add(new CRM_DataObjects.PicklistOption(a.getValue(), a.getLabel()));
          }
      }
      PicklistVal pickWrap = new PicklistVal(piclistVales,options);
      return pickWrap; //return the List
    }
    
     /** 
     *  Method to fetch the chunk size  
     *  @name getChunkSizeForRateCards
     *  @param None
     *  @return Chunk size in Integer
     *  @throws None
     */
    global Integer getChunkSizeForRateCards() {
        return CRM_Batch_Size__c.getInstance('Upload Rate Card Records Chunk Size') != null ? Integer.valueOf(CRM_Batch_Size__c.getInstance('Upload Rate Card Records Chunk Size').Batch_Size__c) : 100;
    }
    
    /** 
     *  Method to fetch the custom setting record to set boolean flag which make grid Editable / Read only for logged in user
     *  @name getIsGridInReadOnlyMode
     *  @param None
     *  @return boolean flag for RateCard edit access 
     *  @throws None
     */
    global Boolean getRCEditAccess() {
        return (Schema.sObjectType.Rate_Card__c.isCreateable() || Schema.sObjectType.Rate_Card__c.isUpdateable() || Schema.sObjectType.Rate_Card__c.isDeletable());
    }
    
    /** 
    *  Method to MAP RC Record fields to the wrapper 
    *  @name mapWrapperFields
    *  @param Rate_Card__c rc
    *  @return RateCardWrapper 
    *  @throws None
    */
    private static RateCardWrapper mapWrapperFields(Rate_Card__c rc){
        RateCardWrapper rcWrap = new RateCardWrapper();
        rcWrap.existingId = rc.id;
        rcWrap.name = rc.Name;
        rcWrap.accountName = rc.Account__r.Name;
        rcWrap.country = rc.Country__r.name;
        rcWrap.contentType = rc.Content_Type__c;
        rcWrap.channel = rc.Channel__c;
        rcWrap.startDate = String.valueOf(rc.Start_date__c);
        rcWrap.endDate = String.valueOf(rc.End_date__c);
        rcWrap.format = rc.Format__c;
        rcWrap.priceTier = rc.Price_Tier__c;
        rcWrap.WSP1 = rc.WSP1__c;
        rcWrap.WSP2 = rc.WSP2__c ;
        rcWrap.WSP3 = rc.WSP3__c;
        rcWrap.SRP = rc.SRP__c;
        rcWrap.split = rc.Split__c;/*ER-002742 Add Split % */
        rcWrap.SRPCurrency = rc.SRP_Currency__c;
        rcWrap.WSPCurrency = rc.WSP_Currency__c;
        rcWrap.rateCardType = rc.Rate_Card_Type__c;
        rcWrap.RCLifecycle = rc.RC_Lifecycle__c;
        rcWrap.WBTerritory = rc.WB_Territory__c;
        rcWrap.accountingCategory = rc.Accounting_Category__c;
        rcWrap.SFWSPCurrency = rc.Storefront__r.WSP_Currency__c;
        rcWrap.SFSRPCurrency = rc.Storefront__r.Pricing_Currency__c;
        rcWrap.comments = rc.Comments__c;
        rcWrap.invalidCapability = rc.Invalid_Capability__c;
        rcWrap.sfSelCom = rc.Storefront__r.Selected_Combination__c;
        rcWrap.rcCategory = rc.RC_Category__c;
        return rcWrap;
    }
    
    /** 
    *  Method the wrapper field values to RC records
    *  @name createRcRecord
    *  @param RateCardWrapper rcWrap - Wrapper record
    *  @return Rate_Card__c 
    *  @throws None
    */
    private static Rate_Card__c createRcRecord(RateCardWrapper rcWrap,Map<String,String> rctMap,Map<String,String> ctMap,Map<String,String> chMap,Map<String,String> fMap){
        Rate_Card__c rc = new Rate_Card__c();
        if(rcWrap.existingId != null){
            rc.id = rcWrap.existingId;
        }
        rc.Content_Type__c = ctMap.containsKey(rcWrap.contentType) ? ctMap.get(rcWrap.contentType) : rcWrap.contentType;
        rc.Channel__c = chMap.containsKey(rcWrap.channel) ? chMap.get(rcWrap.channel) : rcWrap.channel;
        rc.Format__c = fMap.containsKey(rcWrap.format) ? fMap.get(rcWrap.format) : rcWrap.format;
        rc.Rate_Card_Type__c = rctMap.containsKey(rcWrap.rateCardType) ? rctMap.get(rcWrap.rateCardType) : rcWrap.rateCardType;
        rc.Start_date__c = date.parse(rcWrap.startDate); 
        rc.End_date__c = date.parse(rcWrap.endDate);
        rc.Price_Tier__c = rcWrap.priceTier;
        rc.WSP1__c = rcWrap.WSP1 != null ? rcWrap.WSP1.SetScale(2) : rcWrap.WSP1;
        rc.WSP2__c = rcWrap.WSP2 != null ? rcWrap.WSP2.SetScale(2) : rcWrap.WSP2;
        rc.WSP3__c = rcWrap.WSP3 != null ? rcWrap.WSP3.SetScale(2) : rcWrap.WSP3;
        rc.SRP__c = rcWrap.SRP != null ? rcWrap.SRP.SetScale(2) : rcWrap.SRP;
        rc.Split__c = rcWrap.split != null ? rcWrap.split.SetScale(2) : rcWrap.split; /*ER-002742 Add Split %*/
        rc.SRP_Currency__c = rcWrap.SRPCurrency;
        rc.WSP_Currency__c = rcWrap.WSPCurrency;
        rc.Accounting_Category__c = rcWrap.accountingCategory;
        rc.RC_Category__c = rcWrap.rcCategory;
        rc.Comments__c =  rcWrap.comments;
        return rc;
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
    * Wrapper Class to store Picklist values
    */
    public class PicklistWrapper{
        
        PicklistVal countryValues;
        PicklistVal contentTypeValues;
        PicklistVal channelValues;
        PicklistVal formatValues;
        PicklistVal currencyValues;
        PicklistVal rateCardTypeValues;
        PicklistVal WBTerritoryValues;
        PicklistVal RCLifecycle;
        PicklistVal RCCategory; //ER-007015
        
        public PicklistWrapper(PicklistVal countryValues,
                               PicklistVal contentTypeValues,
                               PicklistVal channelValues,
                               PicklistVal formatValues,
                               PicklistVal currencyValues,
                               PicklistVal rateCardTypeValues,
                               PicklistVal WBTerritoryValues,
                               PicklistVal RCLifecycle,
                               PicklistVal RCCategory)
        {
            this.countryValues = countryValues;
            this.contentTypeValues = contentTypeValues;
            this.channelValues = channelValues;
            this.formatValues = formatValues;
            this.currencyValues = currencyValues;
            this.rateCardTypeValues = rateCardTypeValues;
            this.WBTerritoryValues = WBTerritoryValues;
            this.RCLifecycle = RCLifecycle;
            this.RCCategory = RCCategory; //ER-007015
        }
    }
    
    /**
    *  @Description - Picklist class
    *  @name  PicklistVal 
    */
    global class PicklistVal{
        List<String> picklist = new List<String>();
        List<CRM_DataObjects.PicklistOption> filterPicklist = new List<CRM_DataObjects.PicklistOption>();
        
        public picklistVal(List<String> picklist,List<CRM_DataObjects.PicklistOption> filterPicklist){
            this.picklist = picklist;
            this.filterPicklist = filterPicklist;
        }
    }
    
    /**
    *  @Description - wrapper class
    *  @name  RateCardWrapper 
    */
    global class RateCardWrapper {
        public String validation = '';
        public Id existingId;
        public boolean isRowModified = false;
        public boolean isRowRemoved = false;
        public Integer rowIndex = 0;
        public String  accountName = ''; 
        public String  country = '';
        public String  contentType = '';
        public String channel = '';
        public String  format = '';
        public String  priceTier = '';
        public Decimal  WSP1;
        public Decimal  WSP2;
        public Decimal WSP3;
        public String accountingCategory = '';
        public String rcCategory = ''; /*ER-006659 RC Category %*/
        public Decimal SRP;
        public Decimal split;/*ER-002742 Add Split %*/
        public String SRPCurrency = '';
        public String WSPCurrency = '';
        public String  rateCardType = '';
        public String  startDate;
        public String  endDate;
        public String RCLifecycle = ''; 
        public String WBTerritory = '';
        public boolean errorOccured = false;
        public Integer numFailedRecords;
        public String maxLimitExceededMsg = '';
        public String SFSRPCurrency = '';
        public String SFWSPCurrency = '';
        public String comments = '';
        public String name = '';
        public boolean invalidCapability = false;
        public String sfSelCom = '';
    } 
    
    /* Wrapper class to be used as javascript remoting object */
    global class FilterWrapper {
        global string text;
        global string countryId;
        global CRM_DataObjects.PicklistOption[] contentType;
        global CRM_DataObjects.PicklistOption[] channel;
        global CRM_DataObjects.PicklistOption[] format;
        global CRM_DataObjects.PicklistOption[] WBTerritory;
        global CRM_DataObjects.PicklistOption[] RCLifecycle;
        global CRM_DataObjects.PicklistOption[] RCCategory; //ER-007015
    }
}