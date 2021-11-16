/**
@Author Cognizant
@name WB_UploadPromotionTitlesController
@CreateDate 25th Dec 2018
@Description WB_UploadPromotionTitlesController class is created to insert/update promotion title records in system. 
@Version <1.0>
@reference Requirement ER-002559
*/
global class WB_UploadPromotionTitlesController {
    
    //JSON String to convert picklistWrap object into string
    public String pickWrapJSONString{get; set;}
    public String handsontableversion{get; set;}
    public Id promotionId; 
    public String show{get; set;}
    public static Integer totalFailedRecords;
    public static Promotion__c promoRec ;
    public Decimal ptSizeLimit{get; set;}
    public Decimal ptPTChunkSize{get; set;}
    
    global WB_UploadPromotionTitlesController(ApexPages.Standardcontroller stdCon) {
        Map<String, WB_Promotion_Limits__c> promoLimits = WB_Promotion_Limits__c.getAll();
        promotionId = stdCon.getId();
        show = apexpages.currentpage().getparameters().get('show');
        System.debug('Constructor promotionId==='+promotionId);
        List<Promotion__c> promotionList =  [SELECT Id,Name,Channels__c,Formats__c,Country__c FROM Promotion__c WHERE Id =: promotionId];
        System.debug('Constructor promotionList==='+promotionList);
        promoRec = new Promotion__c();
        promoRec = promotionList[0];
        ptSizeLimit = promoLimits.get('Promotion Titles Size Limit').Limit_Size__c;
        ptPTChunkSize = promoLimits.get('Save PT Chunk Size').Limit_Size__c;
        system.debug('promoRec:'+promoRec);
        PicklistWrapper picklistWrap = new PicklistWrapper(
            getFilterPicklistValues('Promotion_Title__c', 'Channel__c'),
            getFilterPicklistValues('Promotion_Title__c', 'Format__c'),
        	getFilterPicklistValues('Promotion_Title__c', 'WSP_Currency__c'));
        pickWrapJSONString = JSON.serialize(picklistWrap);
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().HandsonTable_Pro_Version__c;
    }
    global WB_UploadPromotionTitlesController(){
        
        PicklistWrapper picklistWrap = new PicklistWrapper(
            getFilterPicklistValues('Promotion_Title__c', 'Channel__c'),
            getFilterPicklistValues('Promotion_Title__c', 'Format__c'),
        	getFilterPicklistValues('Promotion_Title__c', 'WSP_Currency__c'));
        pickWrapJSONString = JSON.serialize(picklistWrap);
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().HandsonTable_Pro_Version__c;        
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
*  name getUserDateFormat: e.g. M/d/yyyy
*  param none
*  return string
*  throw none
*/  
    global String getUserDateFormat(){
        //return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
        return null;
    }

    /**
* Method to get logged in uSer Locale in Lower case
*/
    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }
    
    /* get license key */
    global string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    }
    
    /**
* method to fetch all child promotion titles
* method name : getPromotionTitleRecords
* param: promotion id and fitler based on which records needs t be shown
* return: list of wrapper of promotion title
*/
    @RemoteAction 
    global static List<PromotionTitleWrapper> getPromotionTitleRecords(ID promotionId,FilterWrapper filters)
    {
        List<PromotionTitleWrapper> returnWrapperList = new List<PromotionTitleWrapper>();
        List<Promotion_Title__c> promotionTitlesList = new List<Promotion_Title__c>();
        Set<String> formatSet = new Set<String>();
        Set<String> vvSet = new Set<String>();
        Set<String> channelSet = new Set<String>();
        try{
            if(filters != null){
                formatSet = getPicklistValueSet(filters.format);
                vvSet = new Set<String>(filters.vvText);
                channelSet = getPicklistValueSet(filters.channel);
            }
            
            String queryString = 'SELECT id, name,PromotionID__c,PromotionID__r.Country__c,Title__c,Title__r.Name,toLabel(Channel__c),toLabel(Format__c),Title__r.Video_Version__c,WSP__c,Price_Tier__c,Price_Code__c,Vendor_ID__c,Retailer_ID__c,WSP_Currency__c'+
                ' FROM Promotion_Title__c WHERE PromotionID__c =:promotionId';
            
            if(!formatSet.isEmpty()){
                queryString +=  ' AND (Format__c IN :formatSet)';
            }
            if(!channelSet.isEmpty()){
                queryString +=  ' AND (Channel__c IN :channelSet)';
            }
            if(!vvSet.isEmpty()){
                queryString+= ' AND (Video_Version__c IN: vvSet)';
            }
            queryString+= ' LIMIT 50000';
            system.debug('queryString ----------'+queryString);
            
            promotionTitlesList = Database.query(queryString);
            
            for(Promotion_Title__c promotionTitle : promotionTitlesList){
                
                PromotionTitleWrapper lineItemWrapper = new PromotionTitleWrapper();
                lineItemWrapper.existingId = promotionTitle.id;
                lineItemWrapper.channel = promotionTitle.Channel__c;
                lineItemWrapper.format = promotionTitle.Format__c;
                lineItemWrapper.title = promotionTitle.Title__r.Name;
                lineItemWrapper.videoVersion = promotionTitle.Title__r.Video_Version__c;
                lineItemWrapper.priceCode = promotionTitle.Price_Code__c;
                lineItemWrapper.priceTier = promotionTitle.Price_Tier__c;
                lineItemWrapper.WSP = promotionTitle.WSP__c;
                lineItemWrapper.wspCurrency = promotionTitle.WSP_Currency__c;
                lineItemWrapper.vendorId = promotionTitle.Vendor_ID__c;
                lineItemWrapper.retailerId = promotionTitle.Retailer_ID__c;
                lineItemWrapper.PromotionId = promotionTitle.PromotionID__c; 
                returnWrapperList.add(lineItemWrapper);
            }
            
        }
        catch(Exception e) {
            system.debug('Exception -: '+e);
            throw e;
        }
        return returnWrapperList;
    }
    
    /**
*  Method to save promotion title records in System
*  @name savePromotionTitles
*  @param List<PromotionTitleWrapper> PromotionTitleWrapList - wrapper list of PromotionTitles
*  @return List<PromotionTitleWrapper> - wrapper list of PromotionTitles
*  @throws None
*/
    @RemoteAction 
    global static List<PromotionTitleWrapper> savePromotionTitleRecords(List<PromotionTitleWrapper> PromotionTitleWrapList,String promotionId){
        
        List<PromotionTitleWrapper> listpromotionTitleWrappersToDelete = new List<PromotionTitleWrapper>();
        List<Promotion_Title__c> listPTRecordToUpsert = new List<Promotion_Title__c>();
        List<PromotionTitleWrapper> listPTWrappersToUpsert = new List<PromotionTitleWrapper>();
        Set<String> videoVersions = new Set<String>();
        Set<String> vvChannelFormatKey = new Set<String>();
        Set<String> pChannelFormatKey = new Set<String>();
        Map<String,Title__c> videoVersionsToTitleRec = new Map<String,Title__c>();
        List<String> vvEpisodes = new List<String>();
        Map<String,List<Playlist_Content__c>> vvEpisodePlaylistContentMap = new Map<String,List<Playlist_Content__c>>();
        Map<String,PromotionTitleWrapper> mapPromoTitleWrapper = new Map<String,PromotionTitleWrapper>();
        List<PromotionTitleWrapper> prmoTitleWrapperToReturn = new List<PromotionTitleWrapper>();
        List<PromotionTitleWrapper> invalidFormatRecords = new List<PromotionTitleWrapper>();
        Set<String> setRetId= new Set<String>();
        Set<String> setVenId= new Set<String>();
        Map<String,String> mapVVCARetId = new Map<String,String>();
        Map<String,String> mapVVCAVenId = new Map<String,String>();
        List<String> promoTitleKey = new List<String>();
        List<String> accNames = new List<String>();
        List<String> countNames = new List<String>();
        
        Promotion__c promotionRec = [SELECT Id,Name,Formats__c,Channels__c,Country__c,Account_Multipicklist__c,Promotion_Number__c FROM Promotion__c where Id =: promotionId];
        System.debug('promotionRec==='+promotionRec);
        
        Map<String,String> formatMap = getPicklistValueFromLabelMap('Promotion_Title__c', 'Format__c');
        Map<String,String> channelMap = getPicklistValueFromLabelMap('Promotion_Title__c', 'Channel__c');
        
        map<String, Promotion_Title__c> mapPromotionTitleKeyWithRecord = new map<String, Promotion_Title__c>();
        
        totalFailedRecords = 0;
        integer index = 0;
        
        //Logic For RetailerId,VendorId START
        for(PromotionTitleWrapper promotionTitleWrapper : PromotionTitleWrapList)
        {
            if(promotionTitleWrapper.existingId == null)
            {
                if((promotionTitleWrapper.vendorId != null && promotionTitleWrapper.vendorId != '') && (promotionTitleWrapper.videoVersion == null || promotionTitleWrapper.videoVersion == ''))
                {
                    setVenId.add(promotionTitleWrapper.vendorId);
                }
                else if((promotionTitleWrapper.retailerId != null && promotionTitleWrapper.retailerId != '') && (promotionTitleWrapper.videoVersion == null || promotionTitleWrapper.videoVersion == ''))
                {
                    setRetId.add(promotionTitleWrapper.retailerId);
                }
            }
        }
        if(!String.isBlank(promotionRec.Account_Multipicklist__c) && !String.isBlank(promotionRec.Country__c))
        {
            accNames = promotionRec.Account_Multipicklist__c.split(';');
            countNames = promotionRec.Country__c.split(';');
            String queryCA = 'SELECT Id,Title_Video_Version__c,Client_Title_ID__c,Vendor_ID__c,Client__r.Name FROM Client_Avail__c WHERE (Client_Title_ID__c IN :setRetId OR Vendor_ID__c IN :setVenId)'+
                'AND Client__r.Name IN :accNames AND Release_Plan_Country__c IN :countNames LIMIT 50000';
            for( Client_Avail__c ca : Database.query(queryCA)){
                System.debug('In Client Avail');
                videoVersions.add(ca.Title_Video_Version__c);
                if(ca.Client_Title_ID__c != null){
                    mapVVCARetId.put(ca.Client_Title_ID__c,ca.Title_Video_Version__c);
                }
                if(ca.Vendor_ID__c != null){
                    mapVVCAVenId.put(ca.Vendor_ID__c,ca.Title_Video_Version__c);
                }
            }
            System.debug('mapVVCARetId==='+mapVVCARetId);
            System.debug('mapVVCAVenId==='+mapVVCAVenId);
            for(PromotionTitleWrapper promotionTitleWrapper : PromotionTitleWrapList)
            {
                if(promotionTitleWrapper.existingId == null)
                {
                    if((promotionTitleWrapper.vendorId != null && promotionTitleWrapper.vendorId != '') && (promotionTitleWrapper.videoVersion == null || promotionTitleWrapper.videoVersion == '')){
                        System.debug('In vendorId');
                        if(mapVVCAVenId.containsKey(promotionTitleWrapper.vendorId)){
                            promotionTitleWrapper.videoVersion = mapVVCAVenId.get(promotionTitleWrapper.vendorId);
                        } else{
                            promotionTitleWrapper.recordStatus = 'Error';
                            promotionTitleWrapper.errorOccured = true;
                            promotionTitleWrapper.validation = 'Vendor Id not found for selected Account and country combination.';
                            totalFailedRecords++;
                            invalidFormatRecords.add(promotionTitleWrapper);
                            promotionTitleWrapper.isRowModified = false;
                        }
                    }else if((promotionTitleWrapper.retailerId != null && promotionTitleWrapper.retailerId != '') && (promotionTitleWrapper.videoVersion == null || promotionTitleWrapper.videoVersion == '')){
                        System.debug('In retailerId');
                        if(mapVVCARetId.containsKey(promotionTitleWrapper.retailerId)){
                            promotionTitleWrapper.videoVersion = mapVVCARetId.get(promotionTitleWrapper.retailerId);
                        } else{
                            promotionTitleWrapper.recordStatus = 'Error';
                            promotionTitleWrapper.errorOccured = true;
                            promotionTitleWrapper.validation = 'Retailer Id not found for selected Account and country combination.';
                            totalFailedRecords++;
                            invalidFormatRecords.add(promotionTitleWrapper);
                            promotionTitleWrapper.isRowModified = false;
                        }
                    }
                }
            }
        } else{
            for(PromotionTitleWrapper promotionTitleWrapper : PromotionTitleWrapList){
                if(promotionTitleWrapper.existingId == null){
                    if((promotionTitleWrapper.vendorId != null && promotionTitleWrapper.vendorId != '') && (promotionTitleWrapper.videoVersion == null || promotionTitleWrapper.videoVersion == '')){
                        promotionTitleWrapper.recordStatus = 'Error';
                        promotionTitleWrapper.errorOccured = true;
                        promotionTitleWrapper.validation = 'At least one account and country should be present if Vendor Id is populated.';
                        totalFailedRecords++;
                        invalidFormatRecords.add(promotionTitleWrapper);
                        promotionTitleWrapper.isRowModified = false;
                    } else if((promotionTitleWrapper.retailerId != null && promotionTitleWrapper.retailerId != '') && (promotionTitleWrapper.videoVersion == null || promotionTitleWrapper.videoVersion == '')){
                        promotionTitleWrapper.recordStatus = 'Error';
                        promotionTitleWrapper.errorOccured = true;
                        promotionTitleWrapper.validation = 'At least one account and country should be present if Retailer Id is populated.';
                        totalFailedRecords++;
                        invalidFormatRecords.add(promotionTitleWrapper);
                        promotionTitleWrapper.isRowModified = false;
                    }
                }
            }
        }
        //Logic For RetailerId,VendorId END
        
        System.debug('PromotionTitleWrapList==='+PromotionTitleWrapList);
        for(PromotionTitleWrapper promotionTitleWrapper : PromotionTitleWrapList){
            if(promotionTitleWrapper.isRowRemoved !=null && promotionTitleWrapper.isRowRemoved == true){
                listpromotionTitleWrappersToDelete.add(promotionTitleWrapper); 
            }
            if(promotionTitleWrapper.videoVersion != null || promotionTitleWrapper.videoVersion != '')
                videoVersions.add(promotionTitleWrapper.videoVersion);
            if(promotionTitleWrapper.videoVersion != null && promotionTitleWrapper.channel != null && promotionTitleWrapper.format != null){
                vvChannelFormatKey.add(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+promotionTitleWrapper.format);
            }
            if(promotionTitleWrapper.existingId != null){
                promotionTitleWrapper.isUpdated = true;
            } else{
                promotionTitleWrapper.isUpdated = false; 
            }
            promotionTitleWrapper.rowIndex = index;
            index++;
        }
        System.debug('videoVersions==='+videoVersions);
        
        //Fetch all Title Records
        for(Title__c titleRec : [SELECT id,Name,Video_Version__c,Formats__c,Digital_Planning__c,Clear_to_Avail__c,Content_Type__c FROM Title__c where Video_Version__c IN: videoVersions LIMIT 50000]){
            videoVersionsToTitleRec.put(titleRec.Video_Version__c,titleRec);
            if(titleRec.Content_Type__c == 'Episode'){
                vvEpisodes.add(titleRec.Video_Version__c);
            }
        }
        System.debug('videoVersionsToTitleRec==='+videoVersionsToTitleRec);
        
        if(!vvEpisodes.isEmpty()){
            for(Playlist_Content__c playContent : [SELECT Id,Playlist__c,Playlist__r.Parent_Title__r.Digital_Planning__c,Playlist__r.Parent_Title__r.Clear_to_Avail__c,Playlist__r.Parent_Title__r.Formats__c,Content_VV__c FROM Playlist_Content__c WHERE Content_VV__c IN :vvEpisodes LIMIT 50000]){
                if(vvEpisodePlaylistContentMap.containsKey(playContent.Content_VV__c))
                {
                    vvEpisodePlaylistContentMap.get(playContent.Content_VV__c).add(playContent);
                } else{
                    vvEpisodePlaylistContentMap.put(playContent.Content_VV__c,new List<Playlist_Content__c>{playContent});
                }
            }
        }
        
        //Deletion of Promotion Title Records
        if(!listpromotionTitleWrappersToDelete.isEmpty()){
            Integer[] lstRowIndexToRemove =  deletePromotionTitles(listpromotionTitleWrappersToDelete);
            for(Integer i= lstRowIndexToRemove.size()-1; i >=0; i--) {
                Integer indexToRemove = lstRowIndexToRemove[i];
                PromotionTitleWrapList.remove(indexToRemove);
            }
        }
        
        //Fetch Existing Promotion Title Records on Promotion
        for(Promotion_Title__c promotionTitle : [SELECT Id,Video_Version__c,Promo_Title_Key__c,Channel__c,Format__c FROM Promotion_Title__c WHERE PromotionId__c =: promotionId LIMIT 50000]){
            mapPromotionTitleKeyWithRecord.put(promotionTitle.Promo_Title_Key__c,promotionTitle);
            promoTitleKey.add(promotionTitle.Video_Version__c+'_'+promotionTitle.Channel__c+'_'+promotionTitle.Format__c);
        }
        System.debug('mapPromotionTitleKeyWithRecord==='+mapPromotionTitleKeyWithRecord);
        
        Map<String, WB_Promotion_Formats__c> promotFormatMap = WB_Promotion_Formats__c.getAll();
        
        //Logic to check all validation for Entering a VV in Hands-on Table START
        for(PromotionTitleWrapper promotionTitleWrapper : PromotionTitleWrapList){
            System.debug('for promotionTitleWrapper==='+promotionTitleWrapper);
            Promotion_Title__c ptObj = new Promotion_Title__c();
            if(promotionTitleWrapper.isRowModified == null || promotionTitleWrapper.isRowModified == false){
                if(!promotionTitleWrapper.errorOccured){
                    prmoTitleWrapperToReturn.add(promotionTitleWrapper);
                }
            } else{
                //Need to create new record logic START
                if(promotionTitleWrapper.isUpdated == false){                    
                    System.debug('for isUpdated false==='+promotionTitleWrapper);
                    if(promotionTitleWrapper.isRowModified !=null && promotionTitleWrapper.isRowModified == true){
                        System.debug('for isRowModified not null isRowModified true==='+promotionTitleWrapper);
                        //VV# is there or not
                        if( !videoVersionsToTitleRec.isEmpty() && videoVersionsToTitleRec.containsKey(promotionTitleWrapper.videoVersion) && channelMap.containsKey(promotionTitleWrapper.channel) && formatMap.containsKey(promotionTitleWrapper.format) )
                        {
                            Boolean flagEpisodeCheck = true;
                            Boolean flagDigiPlan = false;
                            Boolean flagClearToAvail = false;
                            System.debug('1st If');
                            //Check for Digital Planning and Clear to Avail
                            if( videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c != 'Episode')
                            {
                                System.debug('In Episode Check 1');
                                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c == null || !videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c.equals('Yes')){
                                    flagEpisodeCheck = false;
                                    flagDigiPlan = true;
                                } else if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Clear_to_Avail__c != true){
                                    flagEpisodeCheck = false;
                                    flagClearToAvail = true;
                                }
                            }
                            else if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                            {
                                System.debug('In Episode Check 2:'+vvEpisodePlaylistContentMap);
                                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c == null || !videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c.equals('Yes')){
                                    if(!vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion)){
                                        flagEpisodeCheck = false;
                                        flagDigiPlan = true;
                                    } else{
                                        Integer countPlayCont = 0;
                                        for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion)){
                                            if(playCont.Playlist__r.Parent_Title__r.Digital_Planning__c == null || !playCont.Playlist__r.Parent_Title__r.Digital_Planning__c.equals('Yes')){
                                                countPlayCont++;
                                            }
                                        }
                                        if(countPlayCont == vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).size())
                                        {
                                            flagEpisodeCheck = false;
                                            flagClearToAvail = true;
                                        }
                                    }
                                }
                                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Clear_to_Avail__c != true)
                                {
                                    if(!vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion)){
                                        flagEpisodeCheck = false;
                                        flagClearToAvail = true;
                                    } else{
                                        Integer countPlayCont = 0;
                                        for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                                        {
                                            if(playCont.Playlist__r.Parent_Title__r.Clear_to_Avail__c != true){
                                                countPlayCont++;
                                            }
                                        }
                                        if(countPlayCont == vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).size()){
                                            flagEpisodeCheck = false;
                                            flagClearToAvail = true;
                                        }
                                    }
                                }
                            }
                            if(flagEpisodeCheck)
                            {
                                //Boolean flagFormatCheck = true;
                                System.debug('2nd If');
                                //Check for Format
                                Boolean flagFormatCheck = formatValidation(promotionTitleWrapper,promotFormatMap,promoTitleKey,videoVersionsToTitleRec,vvEpisodePlaylistContentMap);
                                if(flagFormatCheck)
                                {
                                    //Check for WSP if Not Episode
                                    Boolean wspFlagIfZero = true;
                                    if(!videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                                    {
                                        if(promotionTitleWrapper.WSP != null && promotionTitleWrapper.WSP == 0)
                                        {
                                            wspFlagIfZero = false;
                                        }
                                    }
                                    if(wspFlagIfZero)
                                    {
                                        try{
                                            System.debug('channelMap==='+channelMap.keySet());
                                            System.debug('formatMap==='+formatMap.keySet() );
                                            
                                            String chValue = channelMap.get(promotionTitleWrapper.channel);  
                                            String frValue = formatMap.get(promotionTitleWrapper.format); 
                                            
                                            System.debug('chValue==='+chValue);
                                            System.debug('frValue==='+frValue);
                                            System.debug('promoRec==='+promoRec);
                                            ptObj = createPTRecord(promotionTitleWrapper,chValue,frValue,videoVersionsToTitleRec,promotionId,mapPromotionTitleKeyWithRecord,promotionRec);
                                            System.debug('Created Promo Title Rec 1 ptObj==='+ptObj);
                                        }catch(System.Exception e){
                                            System.debug('e.getMessage();'+e.getMessage());
                                            promotionTitleWrapper.validation = e.getMessage();
                                            promotionTitleWrapper.recordStatus ='Error';
                                            promotionTitleWrapper.errorOccured = true;
                                            totalFailedRecords++;
                                            continue;
                                        }
                                        System.debug('ptObj==='+ptObj);
                                        //If record can been Successfully Created
                                        if(ptObj != null)
                                        {
                                            System.debug('In PTObj If condition');
                                            listPTRecordToUpsert.add(ptObj);
                                            
                                            System.debug('promotionTitleWrapper.videoVersion==='+promotionTitleWrapper.videoVersion);
                                            System.debug('ptObj.Title__c==='+ptObj.Title__c);
                                            System.debug('ptObj.Video_Version__c==='+ptObj.Video_Version__c);
                                            PromotionTitleWrapper lineItemWrapper = new PromotionTitleWrapper();
                                            lineItemWrapper.channel = ptObj.Channel__c;
                                            lineItemWrapper.format = ptObj.Format__c;
                                            lineItemWrapper.title = videoVersionsToTitleRec.containsKey(promotionTitleWrapper.videoVersion) ? videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Name : null;
                                            //lineItemWrapper.videoVersion = mapPromotionTitleKeyWithRecord.containsKey(ptObj.Video_Version__c).Video_Version__c;
                                            lineItemWrapper.videoVersion = promotionTitleWrapper.videoVersion;
                                            lineItemWrapper.priceCode = ptObj.Price_Code__c;
                                            lineItemWrapper.priceTier = ptObj.Price_Tier__c;
                                            lineItemWrapper.WSP = ptObj.WSP__c;
                                            lineItemWrapper.wspCurrency = ptObj.WSP_Currency__c;
                                            lineItemWrapper.vendorId = ptObj.Vendor_ID__c;
                                            lineItemWrapper.retailerId = ptObj.Retailer_ID__c;
                                            lineItemWrapper.PromotionId = ptObj.PromotionID__c; 
                                            System.debug('for lineItemWrapper==='+lineItemWrapper);
                                            listPTWrappersToUpsert.add(lineItemWrapper);
                                            System.debug('for listPTWrappersToUpsert==='+listPTWrappersToUpsert);
                                            promoTitleKey.add(lineItemWrapper.videoVersion+'_'+lineItemWrapper.channel+'_'+lineItemWrapper.format);
                                        }
                                    }
                                    else
                                    {
                                        promotionTitleWrapper.recordStatus = 'Error';
                                        promotionTitleWrapper.errorOccured = true;
                                        promotionTitleWrapper.validation = 'Non Episodic Titles can\'t have Zero as WSP.';
                                        totalFailedRecords++;
                                        invalidFormatRecords.add(promotionTitleWrapper);
                                    }
                                }
                                else
                                {
                                    promotionTitleWrapper.recordStatus = 'Error';
                                    promotionTitleWrapper.errorOccured = true;
                                    System.debug('promoTitleKey2==='+promoTitleKey);
                                    System.debug('Key==='+(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel));
                                    if(
                                        (promotionTitleWrapper.format != 'All' && promotionTitleWrapper.format != 'All 2D')
                                        &&
                                        !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+promotionTitleWrapper.format)
                                        &&
                                        !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All')
                                        &&
                                        !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D')
                                    )
                                    {
                                        promotionTitleWrapper.validation = 'Format not present on Video Version\'s Title.';
                                    }
                                    else
                                    {
                                        promotionTitleWrapper.validation = 'This format is included already for this title video version channel format combination.';
                                    }
                                    totalFailedRecords++;
                                    invalidFormatRecords.add(promotionTitleWrapper);
                                }
                            }
                            else
                            {
                                promotionTitleWrapper.recordStatus = 'Error';
                                promotionTitleWrapper.errorOccured = true;
                                if(!flagDigiPlan && !flagClearToAvail)
                                {
                                    promotionTitleWrapper.validation = 'Video Version\'s Content Type is Episode, season Titles not found.';
                                }
                                else if(flagDigiPlan && flagClearToAvail)
                                {
                                    promotionTitleWrapper.validation = 'Digital planning and Clear to Avail must be set on the Video Version’s Title.';
                                }
                                else if(flagDigiPlan)
                                {
                                    promotionTitleWrapper.validation = 'Digital planning must be set on the Video Version’s Title.';
                                }
                                else if(flagClearToAvail)
                                {
                                    promotionTitleWrapper.validation = 'Clear to Avail must be set on the Video Version’s Title.';
                                }
                                totalFailedRecords++;
                                invalidFormatRecords.add(promotionTitleWrapper);
                            }
                        }
                        else
                        {
                            promotionTitleWrapper.recordStatus = 'Error';
                            promotionTitleWrapper.errorOccured = true;
                            if(videoVersionsToTitleRec.isEmpty() || !videoVersionsToTitleRec.containsKey(promotionTitleWrapper.videoVersion))
                            {
                                promotionTitleWrapper.validation = 'This Video Version is not present in System';
                            }
                            else if(!channelMap.containsKey(promotionTitleWrapper.channel) || !formatMap.containsKey(promotionTitleWrapper.format))
                            {
                                if(!channelMap.containsKey(promotionTitleWrapper.channel) && !formatMap.containsKey(promotionTitleWrapper.format))
                                {
                                    promotionTitleWrapper.validation = 'Invalid Format and Channel';
                                }
                                else if(!formatMap.containsKey(promotionTitleWrapper.format))
                                {
                                    promotionTitleWrapper.validation = 'Invalid Format';
                                }
                                else if(!channelMap.containsKey(promotionTitleWrapper.channel))
                                {
                                    promotionTitleWrapper.validation = 'Invalid Channel';
                                }
                            }
                            totalFailedRecords++;
                            invalidFormatRecords.add(promotionTitleWrapper);
                        }
                    }
                }
                //Need to create new record logic END
                
                //Modify Existing record logic START
                //else if(promotionTitleWrapper.isRowModified == true && promotionTitleWrapper.isUpdated == true){
                else if(promotionTitleWrapper.isRowModified == true)
                {
                    System.debug('for isRowModified true isUpdated true==='+promotionTitleWrapper);
                    try
                    {
                        Boolean flagEpisodeCheck = true;
                        Boolean flagDigiPlan = false;
                        Boolean flagClearToAvail = false;
                        System.debug('1st If');
                        //Check for Digital Planning and Clear to Avail
                        if( videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c != 'Episode')
                        {
                            System.debug('In Episode Check 1');
                            if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c == null || !videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c.equals('Yes'))
                            {
                                flagEpisodeCheck = false;
								flagDigiPlan = true;
                            }
                            if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Clear_to_Avail__c != true)
                            {
                                flagEpisodeCheck = false;
                                flagClearToAvail = true;
                            }
                        }
                        else if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                        {
                            System.debug('In Episode Check 2:'+vvEpisodePlaylistContentMap);
                            if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c == null || !videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Digital_Planning__c.equals('Yes'))
                            {
                                if(!vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion))
                                {
                                    flagEpisodeCheck = false;
                                    flagDigiPlan = true;
                                }
                                else
                                {
                                    Integer countPlayCont = 0;
                                    for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                                    {
                                        if(playCont.Playlist__r.Parent_Title__r.Digital_Planning__c == null || !playCont.Playlist__r.Parent_Title__r.Digital_Planning__c.equals('Yes'))
                                        {
                                            countPlayCont++;
                                        }
                                    }
                                    if(countPlayCont == vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).size())
                                    {
                                        flagEpisodeCheck = false;
                                        flagClearToAvail = true;
                                    }
                                }
                            }
                            if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Clear_to_Avail__c != true)
                            {
                                if(!vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion))
                                {
                                    flagEpisodeCheck = false;
                                    flagClearToAvail = true;
                                }
                                else
                                {
                                    Integer countPlayCont = 0;
                                    for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                                    {
                                        if(playCont.Playlist__r.Parent_Title__r.Clear_to_Avail__c != true)
                                        {
                                            countPlayCont++;
                                        }
                                    }
                                    if(countPlayCont == vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).size())
                                    {
                                        flagEpisodeCheck = false;
                                        flagClearToAvail = true;
                                    }
                                }
                            }
                        }
                        if(flagEpisodeCheck)
                        {
                            Boolean flagFormatCheck = true;
                            System.debug('In 2nd If');
                            //Check for Format
                            if(promotionTitleWrapper.format == 'All')
                            {
                                if(promotFormatMap.containsKey(promotionTitleWrapper.format))
                                {
                                    Integer countAllFormat = 0;
                                    for(String formatRec : promotFormatMap.get(promotionTitleWrapper.format).Formats__c.split(','))
                                    {
                                        if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+formatRec))
                                        {
                                            countAllFormat++;
                                        }
                                    }
                                    if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D'))
                                    {
                                        countAllFormat++;
                                    }
                                    if(countAllFormat > 1)
                                    {
                                        flagFormatCheck = false;
                                    }
                                }
                            }
                            else if(promotionTitleWrapper.format == 'All 2D')
                            {
                                if(promotFormatMap.containsKey(promotionTitleWrapper.format))
                                {
                                    Integer countAllFormat = 0;
                                    for(String formatRec : promotFormatMap.get(promotionTitleWrapper.format).Formats__c.split(','))
                                    {
                                        if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+formatRec))
                                        {
                                            countAllFormat++;
                                        }
                                    }
                                    if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All'))
                                    {
                                        countAllFormat++;
                                    }
                                    if(countAllFormat > 1)
                                    {
                                        flagFormatCheck = false;
                                    }
                                } 
                            }
                            else if((promotionTitleWrapper.format != 'All' || promotionTitleWrapper.format != 'All 2D') && (!promoTitleKey.isEmpty() && (!promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All') || !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D'))))
                            {
                                System.debug('In Episode Format');
                                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                                {
                                    List<String> lstFormats = new List<String>();
                                    if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != null && videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != '')
                                    {
                                    	lstFormats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                                    }
                                    if(lstFormats.isEmpty() && vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion))
                                    {
                                        //lstFormats = vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).Playlist__r.Parent_Title__r.Formats__c.split(';');
                                        for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                                        {
                                            if(playCont.Playlist__r.Parent_Title__r.Formats__c != null && playCont.Playlist__r.Parent_Title__r.Formats__c != '')
                                            {
                                                lstFormats.addAll(playCont.Playlist__r.Parent_Title__r.Formats__c.split(';'));
                                            }
                                        }
                                    }
                                    else if(lstFormats.isEmpty())
                                    {
                                        flagFormatCheck = false;
                                    }
                                    if(!lstFormats.contains(promotionTitleWrapper.format))
                                    {
                                        flagFormatCheck = false;
                                    }
                                }
                                else if(!videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                                {
                                    List<String> lstFormats =  videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                                    if(!lstFormats.contains(promotionTitleWrapper.format))
                                    {
                                        flagFormatCheck = false;
                                    }
                                }
                            }
                            if(flagFormatCheck)
                            {
                                //Check for WSP if Not Episode
                                Boolean wspFlagIfZero = true;
                                if(!videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                                {
                                    if(promotionTitleWrapper.WSP != null && promotionTitleWrapper.WSP == 0)
                                    {
                                        wspFlagIfZero = false;
                                    }
                                }
                                if(wspFlagIfZero)
                                {
                                    ptObj = createPTRecord(promotionTitleWrapper,null,null,videoVersionsToTitleRec,promotionId,mapPromotionTitleKeyWithRecord,promotionRec);
                                    System.debug('Create Promo Title Rec 2 ptObj==='+ptObj);
                                }
                                else
                                {
                                    ptobj = null;
                                    promotionTitleWrapper.recordStatus = 'Error';
                                    promotionTitleWrapper.errorOccured = true;
                                    promotionTitleWrapper.validation = 'Non Episodic Titles can\'t have Zero as WSP.';
                                    totalFailedRecords++;
                                    invalidFormatRecords.add(promotionTitleWrapper);
                                }
                            }
                            else
                            {
                                ptobj = null;
                                promotionTitleWrapper.recordStatus = 'Error';
                                promotionTitleWrapper.errorOccured = true;
                                System.debug('promoTitleKey2==='+promoTitleKey);
                                System.debug('Key==='+(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel));
                                if((promotionTitleWrapper.format != 'All' && promotionTitleWrapper.format != 'All 2D') && !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+promotionTitleWrapper.format))
                                {
                                    promotionTitleWrapper.validation = 'Format Not present on Video Version\'s Title.';
                                }
                                else
                                {
                                    promotionTitleWrapper.validation = 'This format is included already for this title video version channel format combination.';
                                }
                                totalFailedRecords++;
                                invalidFormatRecords.add(promotionTitleWrapper);
                            }
                        }
                        else
                        {
                            ptobj = null;
                            promotionTitleWrapper.recordStatus = 'Error';
                            promotionTitleWrapper.errorOccured = true;
                            System.debug('promoTitleKey2==='+promoTitleKey);
                            System.debug('Key==='+(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel));
                            if(!flagDigiPlan && !flagClearToAvail)
                            {
                                promotionTitleWrapper.validation = 'Video Version\'s Content Type is Episode, season Titles not found.';
                            }
                            else if(flagDigiPlan && flagClearToAvail)
                            {
                                promotionTitleWrapper.validation = 'Digital planning and Clear to Avail must be set on the Video Version’s Title.';
                            }
                            else if(flagDigiPlan)
                            {
                                promotionTitleWrapper.validation = 'Digital planning must be set on the Video Version’s Title.';
                            }
                            else if(flagClearToAvail)
                            {
                                promotionTitleWrapper.validation = 'Clear to Avail must be set on the Video Version’s Title.';
                            }
                            totalFailedRecords++;
                            invalidFormatRecords.add(promotionTitleWrapper);
                        }
                    }
                    catch(System.Exception e)
                    {
                        promotionTitleWrapper.validation = e.getMessage();
                        promotionTitleWrapper.recordStatus ='Error';
                        promotionTitleWrapper.errorOccured = true;
                        totalFailedRecords++;
                        continue;
                    }
                    //If record has been Successfully Validated
                    if(ptObj != null)
                    {
                        listPTRecordToUpsert.add(ptObj);
                        listPTWrappersToUpsert.add(promotionTitleWrapper);
                    }
                }
                //Modify Existing record logic END
            }
        }
        //Logic to check all validation for Entering a VV in Hands-on Table END
        
        System.debug('listPTRecordToUpsert==='+listPTRecordToUpsert);
        System.debug('listPTRecordToUpsert size==='+listPTRecordToUpsert.size());
        //Upsert Logic
        if(!listPTRecordToUpsert.isEmpty()){
            for(Promotion_Title__c rec : listPTRecordToUpsert)
            {
                system.debug('rec==='+rec);
            }
            Database.UpsertResult[] result = Database.Upsert(listPTRecordToUpsert, false);
            System.debug('result==='+result);
            System.debug('listPTRecordToUpsert==='+listPTRecordToUpsert);
            mapPromoTitleWrapper = upsertDMLResultForPTRecords(result,listPTWrappersToUpsert);
            System.debug('listPTWrappersToUpsert==='+listPTWrappersToUpsert);
            System.debug('mapPromoTitleWrapper==='+mapPromoTitleWrapper);
        }
        if(!PromotionTitleWrapList.isEmpty()) {
            PromotionTitleWrapList[0].numFailedRecords = totalFailedRecords;
        } 
        prmoTitleWrapperToReturn.addAll(mapPromoTitleWrapper.values());
        prmoTitleWrapperToReturn.addAll(invalidFormatRecords);
        System.debug('prmoTitleWrapperToReturn==='+prmoTitleWrapperToReturn);
        for(PromotionTitleWrapper rec : prmoTitleWrapperToReturn)
        {
            System.debug('rec==='+ rec);
        }
        return prmoTitleWrapperToReturn;
    }
    
    
    /**
*  Method to check if entered format is Valid
*  @name formatValidation
*  @return Boolean
*/
    static Boolean formatValidation(PromotionTitleWrapper promotionTitleWrapper,Map<String,WB_Promotion_Formats__c> promotFormatMap,List<String> promoTitleKey,Map<String,Title__c> videoVersionsToTitleRec,Map<String,List<Playlist_Content__c>> vvEpisodePlaylistContentMap)
    {
        Boolean flagFormatCheck = true;
        if(promotionTitleWrapper.format == 'All')
        {
            System.debug('In All');
            if(promotFormatMap.containsKey(promotionTitleWrapper.format))
            {
                for(String formatRec : promotFormatMap.get(promotionTitleWrapper.format).Formats__c.split(','))
                {
                    if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+formatRec))
                    {
                        flagFormatCheck = false;
                        break;
                    }
                }
                if(flagFormatCheck && promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D'))
                {
                    flagFormatCheck = false;
                }
            }                                        
        }
        else if(promotionTitleWrapper.format == 'All 2D')
        {
            System.debug('In All 2D');
            if(promotFormatMap.containsKey(promotionTitleWrapper.format))
            {
                for(String formatRec : promotFormatMap.get(promotionTitleWrapper.format).Formats__c.split(','))
                {
                    if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+formatRec))
                    {
                        flagFormatCheck = false;
                        break;
                    }
                }
                if(flagFormatCheck && promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All'))
                {
                    flagFormatCheck = false;
                }
                else if(promotFormatMap.get(promotionTitleWrapper.format).Formats__c.contains(promotionTitleWrapper.format))
                {
                    flagFormatCheck = false;
                }
            } 
        }
        else if
            (
                (promotionTitleWrapper.format != 'All' || promotionTitleWrapper.format != 'All 2D')
                &&
                (
                    promoTitleKey.isEmpty()
                )
            )
        {
            System.debug('In 1st PT');
            if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
            {
                List<String> lstformats = new List<String>();
                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != null && videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != '')
                {
                	lstformats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                }
                if(lstformats.isEmpty() && vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion))
                {
                    //lstformats = vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).Playlist__r.Parent_Title__r.Formats__c.split(';');
                    for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                    {
                        if(playCont.Playlist__r.Parent_Title__r.Formats__c != null && playCont.Playlist__r.Parent_Title__r.Formats__c != '')
                        {
                            lstFormats.addAll(playCont.Playlist__r.Parent_Title__r.Formats__c.split(';'));
                        }
                    }
                }
                else if(lstformats.isEmpty())
                {
                    flagFormatCheck = false;
                }
                if(!lstformats.contains(promotionTitleWrapper.format))
                {
                    flagFormatCheck = false;
                }
            }
            else if(!videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
            {
                List<String> lstformats = new List<String>();
				if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != null && videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != '')
                {
                	lstformats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                }
                if(!lstformats.contains(promotionTitleWrapper.format))
                {
                    flagFormatCheck = false;
                }
            }
        }
        else if
            (
                (promotionTitleWrapper.format != 'All' || promotionTitleWrapper.format != 'All 2D')
                &&
                (
                    !promoTitleKey.isEmpty()
                    &&
                    !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All')
                    &&
                    !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D')
                    &&
                    !promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+promotionTitleWrapper.format)
                )
            )
        {
            System.debug('In Not 1st PT');
            if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
            {
                List<String> lstformats =new List<String>();
                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != null && videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != '')
                {
                	lstformats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                    System.debug('In Episode Format==='+lstformats);
                }
                System.debug('Is Episode Present==='+vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion));
                if(lstformats.isEmpty() && vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion))
                {
                    //lstformats = vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).Playlist__r.Parent_Title__r.Formats__c.split(';');
                    for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                    {
                        if(playCont.Playlist__r.Parent_Title__r.Formats__c != null && playCont.Playlist__r.Parent_Title__r.Formats__c != '')
                        {
                            lstFormats.addAll(playCont.Playlist__r.Parent_Title__r.Formats__c.split(';'));
                        }
                    }
                }
                else if(lstformats.isEmpty())
                {
                    flagFormatCheck = false;
                    System.debug('In Format Empty===');
                }
                if(!lstformats.contains(promotionTitleWrapper.format))
                {
                    flagFormatCheck = false;
                }
                System.debug('flagFormatCheck==='+flagFormatCheck);
            }
            else if(!videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
            {
                List<String> lstformats = new List<String>();
                if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != null && videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != '')
                {
                	lstformats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                }
                if(!lstformats.contains(promotionTitleWrapper.format))
                {
                    flagFormatCheck = false;
                }
            }
        }
        else if
            (
                (promotionTitleWrapper.format != 'All' || promotionTitleWrapper.format != 'All 2D')
                &&
                (
                    !promoTitleKey.isEmpty()
                    &&
                    (
                        promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All')
                        ||
                        promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D')
                        ||
                        promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+promotionTitleWrapper.format)
                    )
                )
            )
        {
            System.debug('In Not 1st PT But All/All 2D Present');
            if(
                promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All') == true
                ||
                promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_'+promotionTitleWrapper.format) == true
            )
            {
                flagFormatCheck = false;
            }
            else if(promoTitleKey.contains(promotionTitleWrapper.videoVersion+'_'+promotionTitleWrapper.channel+'_All 2D') == true)
            {
                for(String formatRec : promotFormatMap.get('All 2D').Formats__c.split(','))
                {
                    if(promotionTitleWrapper.format.equals(formatRec))
                    {
                        flagFormatCheck = false;
                        break;
                    }
                }
                if(!flagFormatCheck)
                {
                    if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                    {
                        List<String> lstformats = new List<String>();
                        if(videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != null && videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c != '')
                        {
                        	lstformats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                        }
                        if(lstformats.isEmpty() && vvEpisodePlaylistContentMap.containsKey(promotionTitleWrapper.videoVersion))
                        {
                            //lstformats = vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion).Playlist__r.Parent_Title__r.Formats__c.split(';');
                            for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(promotionTitleWrapper.videoVersion))
                            {
                                if(playCont.Playlist__r.Parent_Title__r.Formats__c != null && playCont.Playlist__r.Parent_Title__r.Formats__c != '')
                                {
                                    lstFormats.addAll(playCont.Playlist__r.Parent_Title__r.Formats__c.split(';'));
                                }
                            }
                        }
                        else if(lstformats.isEmpty())
                        {
                            flagFormatCheck = false;
                        }
                        if(!lstformats.contains(promotionTitleWrapper.format))
                        {
                            flagFormatCheck = false;
                        }
                    }
                    else if(!videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Content_Type__c.equals('Episode'))
                    {
                        List<String> lstformats = videoVersionsToTitleRec.get(promotionTitleWrapper.videoVersion).Formats__c.split(';');
                        if(!lstformats.contains(promotionTitleWrapper.format))
                        {
                            flagFormatCheck = false;
                        }
                    }
                }
            }
        }
        return flagFormatCheck;
    }
    
    
    /**
*  Method to update success/failure result on the record after dml-insert/update  
*  @name upsertDMLResultForPTRecords
*  @param results, actual list on which dml is performed and string
*  @return None
*  @throws None
*/
    global static Map<String,PromotionTitleWrapper> upsertDMLResultForPTRecords(list<Database.UpsertResult> results,List<PromotionTitleWrapper> ptWrapList)
    {
        Map<String,PromotionTitleWrapper> successRecMap = new Map<String,PromotionTitleWrapper>();
        Map<String,PromotionTitleWrapper> failedRecMap = new Map<String,PromotionTitleWrapper>();
        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                System.debug('ptWrapList.get(i)'+ptWrapList.get(i));
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                totalFailedRecords++;
                if(failedDML.contains('Promo_Title_Key__c') && failedDML.contains('duplicate value'))
                {
                    ptWrapList.get(i).validation = 'Combination for '+ ptWrapList.get(i).videoVersion +'_'+ ptWrapList.get(i).channel +'_'+ ptWrapList.get(i).format +' already exist';
                }
                else
                {
                    ptWrapList.get(i).validation = failedDML;
                }
                ptWrapList.get(i).recordStatus = 'Error';
                ptWrapList.get(i).errorOccured = true;
                failedRecMap.put('error'+i,ptWrapList.get(i));
            }else{
                ptWrapList.get(i).existingId = results.get(i).getId();
                ptWrapList.get(i).errorOccured = false;
                ptWrapList.get(i).isRowModified = false;
                if(results[i].isCreated()){
                    ptWrapList.get(i).validation = System.label.WB_Promotion_Sucess;
                    ptWrapList.get(i).recordStatus = 'Success';
                }else{
                    //ptWrapList.get(i).validation = System.label.CRM_Upload_Message_Updated;
                    ptWrapList.get(i).validation = System.label.WB_Promotion_Sucess;
                    ptWrapList.get(i).recordStatus = 'Success';
                }
                successRecMap.put(results.get(i).getId(),ptWrapList.get(i));
            }
            //successRecMap.put(results.get(i).getId(),ptWrapList.get(i));
        }
        System.debug('successRecMap==='+successRecMap.keySet());
        System.debug('successRecMap==='+successRecMap.size());
        if(!successRecMap.values().isEmpty()){
            for(Promotion_Title__c pt : [Select Id,Name,Channel__c,Format__c,WSP__c,Title__c,Title__r.Name,Title__r.Video_Version__c,Price_Tier__c,Price_Code__c,Vendor_ID__c,Retailer_ID__c,WSP_Currency__c From Promotion_Title__c WHERE Id IN: successRecMap.keySet()]){
                System.debug('pt==='+pt);
                if(successRecMap.containsKey(pt.Id)){
                    successRecMap.get(pt.Id).videoVersion = pt.Title__r.Video_Version__c;
                    successRecMap.get(pt.Id).channel = pt.Channel__c;
                    successRecMap.get(pt.Id).format = pt.Format__c;
                    successRecMap.get(pt.Id).WSP = pt.WSP__c;
                    successRecMap.get(pt.Id).wspCurrency = pt.WSP_Currency__c;
                    successRecMap.get(pt.Id).title = pt.Title__r.name;
                    successRecMap.get(pt.Id).priceTier = pt.Price_Tier__c;
                    successRecMap.get(pt.Id).priceCode = pt.Price_Code__c;
                    successRecMap.get(pt.Id).vendorId = pt.Vendor_ID__c;
                    successRecMap.get(pt.Id).retailerId = pt.Retailer_ID__c;
                }
            }
        }
        successRecMap.putAll(failedRecMap);
        return successRecMap;
    }
    
    /**
*  Method to fetch user input and perform delete operation on existing records
*  @name deletePromotionTitles
*  @param List<PromotionTitleWrapper> lstPTWrappersToDelete
*  @return Integer[] list of row indexes to be removed from original list
*  @throws None
*/ 
    global static Integer[] deletePromotionTitles(List<PromotionTitleWrapper> lstPTWrappersToDelete)
    {
        List<Id> listRCIdsToRemove = new List<Id>();
        List<PromotionTitleWrapper> listPTWrappersToRemove = new List<PromotionTitleWrapper>(); 
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        
        if(lstPTWrappersToDelete!=null) {
            for (PromotionTitleWrapper wrapper : lstPTWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    wrapper.isRowRemoved  = false;
                    wrapper.errorOccured = false;
                    
                    listPTWrappersToRemove.add(wrapper);                    
                    listRCIdsToRemove.add(wrapper.existingId);
                }
                else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }
            }
            
            list<Database.DeleteResult> deleteLiResults = Database.delete(listRCIdsToRemove,false);
            for(Integer i=0; i < deleteLiResults.size(); i++){
                PromotionTitleWrapper ptWrapper = listPTWrappersToRemove.get(i);
                ptWrapper.isRowRemoved = false;
                
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    totalFailedRecords++;
                    
                    ptWrapper.validation = failedDML;
                    ptWrapper.recordStatus = CRM_AppConstants.ERROR_MSG;
                    ptWrapper.errorOccured = true;
                } else {
                    lstRowIndexToRemove.add(ptWrapper.rowIndex);
                }
            }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove; 
    }
    
    /** 
*  Method the wrapper field values to PT records
*  @name createPTRecord
*  @param PromotionTitleWrapper ptWrap - Wrapper record
*  @return Promotion_Title__c 
*  @throws None
*/
    private static Promotion_Title__c createPTRecord(PromotionTitleWrapper ptWrap,String channel,String format,Map<String,Title__c> videoVersionsToTitleRec,String promoId,map<String, Promotion_Title__c> mapPromotionTitleKeyWithRecord,Promotion__c promotionRec)
    {
        System.debug('In createPTRecord');
        System.debug('In promotionRec.Name==='+promotionRec);
        System.debug('In ptWrap.videoVersion==='+ptWrap.videoVersion);
        System.debug('In channel==='+channel);
        System.debug('In format==='+format);
        String wrapperKey = promotionRec.Promotion_Number__c+'_'+ptWrap.videoVersion+'_'+channel+'_'+format;
        //String wrapperKey = promoRec.Name+'_'+ptWrap.videoVersion+'_'+channel+'_'+format;
        Promotion_Title__c promoTitle = new Promotion_Title__c();
        
        if(!mapPromotionTitleKeyWithRecord.containsKey(wrapperKey) && channel != null && format != null && ptWrap.existingId == null && ptWrap.isUpdated == false){
            System.debug('mapPromotionTitleKeyWithRecord containsKey');
            promoTitle.Title__c = (videoVersionsToTitleRec.containsKey(ptWrap.videoVersion)) ? videoVersionsToTitleRec.get(ptWrap.videoVersion).Id : null;
            promoTitle.PromotionID__c = promoId;
            promoTitle.Channel__c = channel;
            promoTitle.Format__c = format;
            promoTitle.Price_Tier__c = ptWrap.priceTier;
            promoTitle.Price_Code__c = ptWrap.pricecode;
            promoTitle.Vendor_ID__c = ptWrap.vendorId;
            promoTitle.Retailer_ID__c = ptWrap.retailerId;
            promoTitle.WSP__c = ptWrap.WSP != null ? ptWrap.WSP.SetScale(2) : ptWrap.WSP;
            promoTitle.WSP_Currency__c = ptWrap.wspCurrency;
            return promoTitle;
        }
        else if(mapPromotionTitleKeyWithRecord.containsKey(wrapperKey) && ptWrap.existingId == null){
            System.debug('mapPromotionTitleKeyWithRecord containsKey 2');
            promoTitle.Title__c = (videoVersionsToTitleRec.containsKey(ptWrap.videoVersion)) ? videoVersionsToTitleRec.get(ptWrap.videoVersion).Id : null;
            promoTitle.PromotionID__c = promoId;
            promoTitle.Channel__c = channel;
            promoTitle.Format__c = format;
            promoTitle.Price_Tier__c = ptWrap.priceTier;
            promoTitle.Price_Code__c = ptWrap.pricecode;
            promoTitle.Vendor_ID__c = ptWrap.vendorId;
            promoTitle.Retailer_ID__c = ptWrap.retailerId;
            promoTitle.WSP__c = ptWrap.WSP != null ? ptWrap.WSP.SetScale(2) : ptWrap.WSP;
            promoTitle.WSP_Currency__c = ptWrap.wspCurrency;
            return promoTitle;
        }
        else if(ptWrap.existingId != null && channel == null && format == null && ptWrap.isUpdated == true){
            System.debug('mapPromotionTitleKeyWithRecord containsKey elseif');
            promoTitle.id = ptWrap.existingId;
            promoTitle.Channel__c = ptWrap.channel;
            promoTitle.Format__c = ptWrap.format;
            promoTitle.Price_Tier__c = ptWrap.priceTier;
            promoTitle.Price_Tier__c = ptWrap.priceTier;
            promoTitle.Price_Code__c = ptWrap.priceCode;
            promoTitle.Vendor_ID__c = ptWrap.vendorId;
            promoTitle.Retailer_ID__c = ptWrap.retailerId;
            promoTitle.WSP__c = ptWrap.WSP != null ? ptWrap.WSP.SetScale(2) : ptWrap.WSP;
            promoTitle.WSP_Currency__c = ptWrap.wspCurrency;
            return promoTitle;
        }
        else{
            System.debug('mapPromotionTitleKeyWithRecord containsKey else return null');
            return null;
        }
    }
    
    /**
* Method to fetch picklist values for specified object and field
* @param object_name Object name for whose field we need the picklist values
* @param field_name Field name for which picklist fields need to be fetched
*/
    global static PicklistVal getFilterPicklistValues(String object_name, String field_name)
    {
        List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();
        List<String> picklistValues = new List<String>(); 
        
        Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            picklistValues.add(a.getLabel()); //add the value and label to our final list
            options.add(new CRM_DataObjects.PicklistOption(a.getValue(), a.getLabel()));
        }
        PicklistVal pickWrap = new PicklistVal(picklistValues,options);
        return pickWrap; //return the List
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
*  @Description - wrapper class
*  @name  PromotionTitleWrapper 
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
*  Method to fill picklist set with values.  
*  @name getPicklistValueSet
*  @param CRM_DataObjects.PicklistOption[] picklistOptions
*  @return set of Strign containing picklist values.
*  @throws None
*/
    global static set<String> getPicklistValueSet(CRM_DataObjects.PicklistOption[] picklistOptions){
        Set<String> picklistValSet = new Set<String>();
        
        if(picklistOptions != null){
            for(CRM_DataObjects.PicklistOption po : picklistOptions){
                picklistValSet.add(po.value);
            }
        }
        return picklistValSet;
    }
    /**
* Wrapper Class to store Picklist values
*/
    global class PicklistWrapper{
        
        PicklistVal channelValues;
        PicklistVal formatValues;
        PicklistVal wspCurrencyValues;
        
        public PicklistWrapper(PicklistVal channelValues,
                               PicklistVal formatValues,PicklistVal wspCurrencyValues)
        {
            this.channelValues = channelValues;
            this.formatValues = formatValues;
            this.wspCurrencyValues = wspCurrencyValues;
        }
    }
    
    /**
* Wrapper Class to store data to and from Handson Table
*/
    global class PromotionTitleWrapper{
        public String format;
        public String channel;
        public String currencyCode;
        public String title;
        public String existingId;
        public String priceTier;
        public String videoVersion;
        public String priceCode;
        public String vendorId;
        public Decimal SRP;
        public String retailerId;
        public Decimal WSP;
        public String wspCurrency;
        public String PromoTitleName;
        public Promotion_Title__c promoTitle;
        public String validation = '';
        public boolean isRowModified = false;
        public boolean isRowRemoved = false;
        Public boolean isUpdated = false;
        public Integer rowIndex = 0;
        public boolean errorOccured = false;
        public Integer numFailedRecords;
        public String maxLimitExceededMsg = '';
        public String recordStatus;
        public String promotionId;
    }
    /* Wrapper class to be used as javascript remoting object */
    global class FilterWrapper {
        global CRM_DataObjects.PicklistOption[] channel;
        global CRM_DataObjects.PicklistOption[] format;
        global List<String> vvText;
    }
}