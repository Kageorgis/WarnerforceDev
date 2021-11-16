/**
   @Author: Cognizant
   @name: WB_SFS_Report_Controllerr
   @CreateDate: 28 June 2020
   @Description: This class is used to get SFS Report Data. 
   @Version <1.0>
   @reference: ER-004177
*/
global with sharing class WB_SFS_Report_Controllerr {
    
    /**
     *  Method to get SFS Records
     *  @name getSFSReportData
     *  @param String CAPIDs and FilterWrap - To get SFS records based on value of CAPIDs and FilterWrapper.
     *  @return List of wrapper record - List<SFSDataWrapper>
     *  @throws None
    */
    @RemoteAction 
    global static List<SFSDataWrapper> getSFSReportData(List<String> capIds,FilterWrapper filterWrap) {
        
        Integer chunksize = getBatchSizeCount();
        Integer recordLimit = getRecordLimit();
        Integer recLmt = ((capIds.size() + chunksize) < recordLimit) ? chunksize : (chunksize + 1);
        system.debug('recordLimit : '+recordLimit+'------'+capIds.size()+'----------'+recLmt);
        system.debug('chunksize :'+chunksize);
        Boolean flagForPreOrder = false;
        List<SFSDataWrapper> sfsDataWrapList = new List<SFSDataWrapper>();
        Set<Id> setMtachingRecordIds = getSearchedRecordIds(filterWrap.title);
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        
        String soqlStr = 'Select Id,Client_Avail__r.Local_Title__r.Title__c,Client_Avail__r.UPC__c,Client_Avail__r.Local_Title__r.Name,Client_Avail__r.Local_Title__r.Title__r.Series__c,Client_Avail__r.Local_Title__r.Title__r.Digital_Material__c,'+
                         'Client_Avail__r.Commercial_Avail__r.Country_Lookup__c,Client_Avail__r.Title_MPM__c,Client_Avail__r.Release_Plan_Language__c,Client_Avail__r.Country_Code_3__c,Client_Avail__r.Title_Content_Type__c,Category__c,'+
                         'Accounting_Category__c,Pre_Order__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code2__c,Client_Avail__r.Title_Video_Version__c,Client_Avail__r.Release_Plan_Channel__c,Client_Avail__r.Release_Plan_Format__c,Price_Tier__c,Effective_Date__c,Expiry_Date__c'+
                         ' From Client_Avail_Price__c';
                         
        List<String> filterQuery = new List<String>();
        if(filterWrap.countryId != null && filterWrap.countryId != ''){
            String qf = '(Client_Avail__r.Commercial_Avail__r.Country_Lookup__c = \''+filterWrap.countryId+'\')';
            filterQuery.add(qf);
        }
        if(filterWrap.accountId != null && filterWrap.accountId != ''){
            String qf = '(Client_Avail__r.Client__c = \''+filterWrap.accountId+'\')';
            filterQuery.add(qf);
        }
        if(filterWrap.fromDate != null){
           system.debug('filterWrap.fromDate : '+filterWrap.fromDate);
           String availDateFrom = DateTime.newInstance(filterWrap.fromDate.year(),filterWrap.fromDate.month(),filterWrap.fromDate.day()).format('yyyy-MM-dd');
           String qf = '(Effective_Date__c >= '+availDateFrom+')';
           filterQuery.add(qf);
        } 
        if(filterWrap.toDate != null){
           system.debug('filterWrap.toDate : '+filterWrap.toDate);
           String availDateTo = DateTime.newInstance(filterWrap.toDate.year(),filterWrap.toDate.month(),filterWrap.toDate.day()).format('yyyy-MM-dd');
           String qf = '(Expiry_Date__c <= '+availDateTo+')';
           filterQuery.add(qf);
        } 
        if(setMtachingRecordIds.size() > 0){
            String qf = '(Client_Avail__r.Local_Title__r.Title__c IN :setMtachingRecordIds)';
            filterQuery.add(qf);
        }
        
        String preQ = '(Pre_Order__c =: flagForPreOrder)';
        filterQuery.add(preQ);
        
        if(filterQuery.size() > 0){
            soqlStr += ' WHERE '+String.join(filterQuery, ' AND '); 
            soqlStr += ' AND Id NOT IN :capIds ORDER BY Client_Avail__r.Client__r.Name,Client_Avail__r.Release_Plan_Country__c LIMIT :recLmt';
            capList = Database.query(soqlStr);
        }
        system.debug('recLmt====>'+recLmt);
        system.debug('soqlStr====>'+soqlStr);
        Set<Id> titleIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        Set<String> channels = new Set<String>();
        Set<String> formats = new Set<String>();
        
        for(Client_Avail_Price__c capRec : capList){
            titleIds.add(capRec.Client_Avail__r.Local_Title__r.Title__c);
            countryIds.add(capRec.Client_Avail__r.Commercial_Avail__r.Country_Lookup__c);
            channels.add(capRec.Client_Avail__r.Release_Plan_Channel__c);
            formats.add(capRec.Client_Avail__r.Release_Plan_Format__c);
        }
        
        Map<string,Earliest_Avail_Date__c> eadRecMap = getMatchingEADRecords(titleIds,countryIds,channels,formats);
        
        WB_ClientAvailPriceHandler priceHandler = new WB_ClientAvailPriceHandler();
        Map<string,String> availableCatgryMap = priceHandler.getAccountingCategoryData();
        
        for(Client_Avail_Price__c capRec : capList){
            SFSDataWrapper sfsWrap = new SFSDataWrapper();
            mapWrapperFields(capRec,sfsWrap,eadRecMap,availableCatgryMap,priceHandler);
            sfsDataWrapList.add(sfsWrap);
        }
        
        system.debug('Total Rec : '+(capIds.size() + capList.size()));
        if(recordLimit < (capIds.size() + capList.size())){
              sfsDataWrapList[0].maxLimitExceededMsg = String.format(System.Label.WB_EAD_Record_Max_Limit_Msg,new String[] {string.valueof(recordLimit)});
        }
        
        return sfsDataWrapList;
    }
    
    private static Map<string,Earliest_Avail_Date__c> getMatchingEADRecords(Set<Id> titleIds,Set<Id> countryIds,Set<String> channels,Set<String> formats){
        Map<string,Earliest_Avail_Date__c> mapOfEAD = new Map<string,Earliest_Avail_Date__c>();
        //List<Earliest_Avail_Date__c> eadreclist = new List<Earliest_Avail_Date__c>();
        for(Earliest_Avail_Date__c eadRec : [Select Id,Video_Version__c,Country_Code_2__c,Channel__c,Format__c,Earliest_Avail_Date__c 
                                             From Earliest_Avail_Date__c 
                                             WHERE Title__c IN :titleIds AND Country__c IN :countryIds AND Channel__c IN :channels AND Format__c IN :formats]){
            String key = eadRec.Video_Version__c+'_'+eadRec.Country_Code_2__c.toLowerCase()+'_'+eadRec.Channel__c.toLowerCase()+'_'+eadRec.Format__c.toLowerCase();
            mapOfEAD.put(key,eadRec);
            //eadreclist.add(eadRec);                                 
            
        }
        //system.debug('eadreclistSize===>'+eadreclist.size());
        return mapOfEAD;
    }
    
    /**
     *  Method to get title record Ids containing the search text.  
     *  @name getSearchedRecordIds
     *  @param String searchText - To search Title based on value
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
            
            
            String SOSL_QUERY = 'FIND {'+ sosl_search +'} IN ALL FIELDS RETURNING Title__c(Id,Name)';
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
    * Method to get Record Limit for Page
    */
    global static Integer getRecordLimit(){
        return WB_Max_Record_Limit__c.getInstance('SFS Report Data Count') != null ?  Integer.valueOf(WB_Max_Record_Limit__c.getInstance('SFS Report Data Count').count__c) : 25000;
    }
    
    /** 
     * Method to get chunksize
     */
    global static Integer getBatchSizeCount() {
        return WB_Max_Record_Limit__c.getInstance('SFS Report Chunk Size') != null ?  Integer.valueOf(WB_Max_Record_Limit__c.getInstance('SFS Report Chunk Size').count__c) : 1000;
    }
    
    
    /**
    * Method to get logged in uSer Locale
    */
    global static String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }  
        return currentUserLocale;
    }
    
    /**
    * Method to get logged in uSer Locale Language code
    */
    global static String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
    
    /**
    * Method to get logged in uSer Locale in Lower case
    */
    global static String getUserLocaleLowerCase() {
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
    global static String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    } 
    
    public static string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    }
    
     /** 
    *  Method to MAP CAP fields to the wrapper 
    *  @name mapWrapperFields
    *  @param Client_Avail_Price__c capRec,SFSDataWrapper sfsWrap, Map<string,Earliest_Avail_Date__c> eadRecMap
    *  @return None 
    *  @throws None
    **/
    private static void mapWrapperFields(Client_Avail_Price__c capRec,SFSDataWrapper sfsWrap, Map<string,Earliest_Avail_Date__c> eadRecMap,Map<string,String> availableCatgryMap,WB_ClientAvailPriceHandler priceHandler){
        sfsWrap.capId = capRec.Id;
        sfsWrap.UPC = capRec.Client_Avail__r.UPC__c;
        sfsWrap.ProductName = capRec.Client_Avail__r.Local_Title__r.Name;
        sfsWrap.seriesName = capRec.Client_Avail__r.Local_Title__r.Title__r.Series__c;
        sfsWrap.materialNumber = capRec.Client_Avail__r.Local_Title__r.Title__r.Digital_Material__c;
        sfsWrap.MPM = capRec.Client_Avail__r.Title_MPM__c;
        if(capRec.Accounting_Category__c != null)
        {
            sfsWrap.boxOffCategory = capRec.Accounting_Category__c;
        }
        else
        {
            priceHandler.assignAccountingCategory(availableCatgryMap,capRec,capRec.Client_Avail__r.Title_Content_Type__c,capRec.Category__c);
            sfsWrap.boxOffCategory = capRec.Accounting_Category__c;
        }
        
        sfsWrap.language = capRec.Client_Avail__r.Release_Plan_Language__c;
        sfsWrap.territory = capRec.Client_Avail__r.Country_Code_3__c;
        if(Film_CT.contains(capRec.Client_Avail__r.Title_Content_Type__c)){
            sfsWrap.productType = 'Film';
        }
        if(TV_CT.contains(capRec.Client_Avail__r.Title_Content_Type__c)){
            sfsWrap.productType = 'TV';
        }
        sfsWrap.salesChannel = VOD_CHANNEL.contains(capRec.Client_Avail__r.Release_Plan_Channel__c) ? 'VOD' : capRec.Client_Avail__r.Release_Plan_Channel__c;
        sfsWrap.platform = CHANNEL_PLATFORM_MAP.containsKey(capRec.Client_Avail__r.Release_Plan_Channel__c) ? CHANNEL_PLATFORM_MAP.get(capRec.Client_Avail__r.Release_Plan_Channel__c) : '';
        sfsWrap.resolution = capRec.Client_Avail__r.Release_Plan_Format__c.containsIgnoreCase('UHD') ? '4K' : capRec.Client_Avail__r.Release_Plan_Format__c;
        sfsWrap.pricingTier = capRec.Price_Tier__c;
        
        String key = capRec.Client_Avail__r.Title_Video_Version__c+'_'+capRec.Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code2__c.toLowerCase()+'_'+capRec.Client_Avail__r.Release_Plan_Channel__c.toLowerCase()+'_'+capRec.Client_Avail__r.Release_Plan_Format__c.toLowerCase(); 
        sfsWrap.releaseDate = eadRecMap.containsKey(key) ? String.valueOf(eadRecMap.get(key).Earliest_Avail_Date__c) : null;
        sfsWrap.startDate = capRec.Effective_Date__c != null ? String.valueOf(capRec.Effective_Date__c) : null;
        sfsWrap.endDate = capRec.Expiry_Date__c != null ? String.valueOf(capRec.Expiry_Date__c) : null;
    }
    
    /**
    *  @Description - wrapper class
    *  @name  RateCardWrapper 
    */
    global class SFSDataWrapper{
        global Id capId;
        global String UPC = '';
        global String ProductName = '';
        global String seriesName = '';
        global String materialNumber = '';
        global String MPM = '';
        global String exclusivity = '';
        global String boxOffCategory = '';
        global String admissions = '';
        global String language = ''; 
        global String territory = '';
        global String productType = '';
        global String salesChannel = '';
        global String platform = '';
        global String resolution = '';
        global String productTier = '';
        global String pricingTier = '';
        global String releaseDate = '';
        global String availYear = '';
        global String startDate = '';
        global String endDate = '';
        global String status = '';
        global String deliveryDate = '';
        global String invoiceDate = '';
        global String holdBackDate = '';
        global String pricingException = '';
        global String mGMethod = '';
        global String pricingMethod = '';
        global String curr = ''; 
        global String revSplit = ''; 
        global String MWP_MLFPB = '';
        global String buyRate = '';
        global String mGAmount = '';
        global String contractTitleId = '';
        global String action = '';
        global String contractId = '';
        global String maxLimitExceededMsg = '';
    } 
    
    /* Wrapper class to be used as javascript remoting object */
    global class FilterWrapper {
        global string accountId;
        global string countryId;
        global string title;
        global date fromDate;
        global date toDate;
    }
    
    global static final Set<String> Film_CT = new Set<String>{'Collection Features','Feature'};
    global static final Set<String> TV_CT = new Set<String>{'Collection TV','Season','Episode'};
    global static final Set<String> VOD_CHANNEL = new Set<String>{'VODi','VODc','Hotel'};
    global static final map<String,String> CHANNEL_PLATFORM_MAP = new map<String,String>{
        'EST'            => 'PC',
        'VODc'         => 'STB',
        'VODi'         => 'PC',
        'Hotel'         => 'HTL',
        'PPV'			=> 'STB'
    };
}