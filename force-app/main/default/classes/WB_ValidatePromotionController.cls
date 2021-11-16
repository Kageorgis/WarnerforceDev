global class WB_ValidatePromotionController{
    global static Map<String,List<Client_Avail__c>> mapKeyClientAvail = new Map<String,List<Client_Avail__c>>();
    global static Map<String, Client_Avail_Price__c> mapCAP = new Map<String, Client_Avail_Price__c>();
    global Id promotionId{get;set;}
    global String handsontableversion{get; set;}
    global Decimal ptChunkSize{get; set;}
    
    
    /* Constructor to get Id of pormotion from URL 
* get handson license key and version to apply 
*/
    Global WB_ValidatePromotionController(ApexPages.StandardController ctrl ){
        Map<String, WB_Promotion_Limits__c> promoLimits = WB_Promotion_Limits__c.getAll();
        promotionId = ctrl.getId();
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().HandsonTable_Pro_Version__c;
        ptChunkSize = promoLimits.get('Validate PT Chunk Size').Limit_Size__c;
    }
    
    //Method to Delete PTD for the passed Promotion Record Id
    @RemoteAction 
    global static void deletelstPromoTitleDetail(Id promotionId){
        System.debug('In deletelstPromoTitleDetail');
        List<Promotion_Title_Detail__c> lstPTD = [SELECT Id FROM Promotion_Title_Detail__c WHERE Promotion__c =: promotionId LIMIT 50000];
        if(!lstPTD.isEmpty())
            DELETE lstPTD;
    }
    
    //Method to Fetch/Create/Return the PTs, Accounts, Countries & SFs for the passed Promotion Record Id and Do Inital Validation till SFs
    @RemoteAction 
    global static MapWrapper fetchPromoTitleRec(Id promotionId, Boolean insertFlag){
        List<String> lstUpsertedKeys = new List<String>();
        List<Promotion_Title_Detail__c> lstPromoTitlesForUpsertion = new List<Promotion_Title_Detail__c>();
        Map<String, Country__c> mapNameCountry = new Map<String, Country__c>();
        Map<String, Account> mapNameAccount = new Map<String, Account>();
        Map<String, Agreement__c> mapNameSF = new Map<String, Agreement__c>();
        List<String> lstAllCountryName = new List<String>();
        List<String> lstAllAccountName = new List<String>();
        Promotion__c promoREC = [SELECT Id,Promotion_Number__c,Account_Multipicklist__c,Country__c FROM Promotion__c WHERE Id = :promotionId];
        System.debug('promoREC==='+promoREC);
        
        
        lstAllAccountName.addAll(promoREC.Account_Multipicklist__c.split(';'));
        lstAllCountryName.addAll(promoREC.Country__c.split(';'));
        
        System.debug('inside fetchPromoTitleRec mapNameCountry==='+mapNameCountry);
        //Mapping country name with id
        for(Country__c country : [SELECT Id,Name,Status__c FROM Country__c WHERE NAME IN :lstAllCountryName LIMIT 50000]){
            mapNameCountry.put(country.Name, country);
        }
        
        for(Account acc : [SELECT Id,Name,Type,RecordType.Name FROM Account WHERE NAME IN :lstAllAccountName LIMIT 50000]){
            mapNameAccount.put(acc.Name, acc);
        }
        
        for(Agreement__c sfRec : [SELECT Id,Account__c,Account__r.Name,Country__r.Name,Status__c,Content_Type__c,Format__c,Channel_Picklist__c,WSP_Currency__c,CRM_Storefront__c FROM Agreement__c WHERE Country__r.Name IN: lstAllCountryName AND Account__r.Name IN :lstAllAccountName LIMIT 50000])
        {
            mapNameSF.put(sfRec.Account__r.Name+'_'+sfRec.Country__r.Name, sfRec);
        }
        
        Promotion_Title_Detail__c ptdREC;
        for(String accName : mapNameAccount.keySet())
        {
            ptdREC = null;
            System.debug('accName==='+accName);
            if(!mapNameAccount.get(accName).RecordType.Name.equals('Digital Client'))
            {
                ptdREC = new Promotion_Title_Detail__c();
                ptdREC.Status__c = 'Warning';
                ptdREC.Comments__c = 'The Account’s record type must be set to Digital Client';
            }
            else if(mapNameAccount.get(accName).Type == null || (mapNameAccount.get(accName).Type != null && !(mapNameAccount.get(accName).Type.equals('Global') || mapNameAccount.get(accName).Type.equals('Local'))))
            {
                ptdREC = new Promotion_Title_Detail__c();
                ptdREC.Status__c = 'Warning';
                ptdREC.Comments__c = 'The Account type must be set to Global or Local';
            }
            if(ptdREC != null)
            {
                System.debug('In mapNameAccount');
                ptdREC.Account__c = mapNameAccount.get(accName).Id;
                ptdREC.Promotion__c = promoREC.Id;
                ptdREC.PTDKey__c = promoREC.Promotion_Number__c+'_'+mapNameAccount.get(accName).Name;
                lstPromoTitlesForUpsertion.add(ptdREC);
                lstUpsertedKeys.add(ptdREC.PTDKey__c);
                mapNameAccount.remove(accName);
            }
        }
        
        for(String countryName : mapNameCountry.keySet())
        {
            ptdREC = null;
            System.debug('countryName==='+countryName);
            if(mapNameCountry.get(countryName).Status__c == null || (mapNameCountry.get(countryName).Status__c != null && !mapNameCountry.get(countryName).Status__c.equals('Active')))
            {
                ptdREC = new Promotion_Title_Detail__c();
                ptdREC.Status__c = 'Warning';
                ptdREC.Comments__c = 'The country selected does not have an Active status';
            }
            if(ptdREC != null)
            {
                System.debug('In mapNameCountry');
                ptdREC.Country__c = mapNameCountry.get(countryName).Id;
                ptdREC.Promotion__c = promoREC.Id;
                ptdREC.PTDKey__c = promoREC.Promotion_Number__c+'_'+mapNameCountry.get(countryName).Name;
                lstPromoTitlesForUpsertion.add(ptdREC);
                lstUpsertedKeys.add(ptdREC.PTDKey__c);
                mapNameCountry.remove(countryName);
            }
        }
        
        for(String accName : mapNameAccount.keySet())
        {
            System.debug('accName==='+accName);
            for(String countryName : mapNameCountry.keySet())
            {
                ptdREC = null;
                System.debug('countryName==='+countryName);
                if(!mapNameSF.containsKey(accName+'_'+countryName))
                {
                    ptdREC = new Promotion_Title_Detail__c();
                    ptdREC.Status__c = 'Warning';
                    ptdREC.Comments__c = 'The selected Country/Account combination does not have an active Storefront.';
                }
                else if(mapNameSF.get(accName+'_'+countryName).Status__c == null || (mapNameSF.get(accName+'_'+countryName).Status__c != null && !mapNameSF.get(accName+'_'+countryName).Status__c.equals('Active')))
                {
                    ptdREC = new Promotion_Title_Detail__c();
                    ptdREC.Status__c = 'Warning';
                    ptdREC.Comments__c = 'The selected Country/Account combination does not have an active Storefront.';
                }
                if(ptdREC != null)
                {
                    ptdREC.Account__c = mapNameAccount.get(accName).Id;
                    ptdREC.Country__c = mapNameCountry.get(countryName).Id;
                    ptdREC.Promotion__c = promoREC.Id;
                    ptdREC.PTDKey__c = promoREC.Promotion_Number__c+'_'+mapNameAccount.get(accName).Name+'_'+mapNameCountry.get(countryName).Name;
                    lstPromoTitlesForUpsertion.add(ptdREC);
                    lstUpsertedKeys.add(ptdREC.PTDKey__c);
                    mapNameSF.remove(accName+'_'+countryName);
                }
            }
        }
        
        System.debug('mapNameAccount.keySet()==='+mapNameAccount.keySet());
        System.debug('mapNameCountry.keyset()==='+mapNameCountry.keyset());
        
        if(!lstPromoTitlesForUpsertion.isEmpty() && insertFlag)
        {
            System.debug('lstPromoTitlesForUpsertion==='+lstPromoTitlesForUpsertion);
            //Database.upsert(lstPromoTitlesForUpsertion,Promotion_Title_Detail__c.Fields.PTDKey__c,true);
            Database.upsertResult[] upsertedResults = Database.upsert(lstPromoTitlesForUpsertion,Promotion_Title_Detail__c.Fields.PTDKey__c,true);
        }
        
        Set<Id> ptIDs = new Set<Id>();
        for(Promotion_Title__c pt : [SELECT Id
                                     FROM Promotion_Title__c
                                     WHERE PromotionID__c=:promotionId LIMIT 50000])
        {
            ptIDs.add(pt.Id);
        }
        
        MapWrapper mapWrapperObject = new MapWrapper(mapNameCountry,mapNameAccount,mapNameSF,ptIDs,lstUpsertedKeys);
        System.debug('mapWrapperObject==='+mapWrapperObject);
        return mapWrapperObject;
    }
    
    //Method to Create/Return PTDs for the passed Promotion Record Id/Accounts/Countries/SFs/VVs and Do Inital and PTD Validations
    @RemoteAction 
    global static List<String> createlstPromoTitleDetail(
        Id promotionId,Map<String, Country__c> mapNameCountry,Map<String, Account> mapNameAccount,Map<String, Agreement__c> mapNameSF,List<Id> ptIDs,
        Boolean insertFlag
    )
    {
        Database.upsertResult[] upsertedResults;
        List<Promotion_Title_Detail__c> lstPromoTitlesForUpsertion = new List<Promotion_Title_Detail__c>();
        Map<String,Title__c> videoVersionsToTitleRec = new Map<String,Title__c>();
        Set<String> setPriceCode = new Set<String>();
        Map<String, Pricing__c> mapPriceCodePricing = new Map<String, Pricing__c>();
        Set<String> setPriceTier = new Set<String>();
        Map<String, List<Rate_Card__c>> mapPriceTierRC = new Map<String, List<Rate_Card__c>>();
        List<String> listCAPKey = new List<String>();
        Map<String, WB_Promotion_Formats__c> promotFormatMap = WB_Promotion_Formats__c.getAll();
        List<String> vvEpisodes = new List<String>();
        Map<String,List<Playlist_Content__c>> vvEpisodePlaylistContentMap = new Map<String,List<Playlist_Content__c>>();
        Promotion__c promoREC = [SELECT Id,Promotion_Number__c,Account_Multipicklist__c,Country__c,Status__c,Last_Validated__c FROM Promotion__c WHERE Id = :promotionId];
        List<String> lstUpsertedKeys = new List<String>();
        
        System.debug('mapNameAccount.keySet()==='+mapNameAccount.keySet());
        System.debug('mapNameCountry.keyset()==='+mapNameCountry.keyset());
        System.debug('ptIDs==='+ptIDs);
        
        //Set<String> setPromotionVVs = new Set<String>();
        Set<String> setPromotionChannels = new Set<String>();
        Set<String> setPromotionFormats = new Set<String>();
        Set<String> setPromotionContentTypes = new Set<String>();
        Map<String,List<Promotion_Title__c>> mapvvPT = new Map<String,List<Promotion_Title__c>>();
        
        List<Promotion_Title__c> lstPromotionTitles = [SELECT ID,Name,Channel__c,Price_Tier__c,Video_Version__c,
                                                       Format__c , WSP__c, Price_Code__c,PromotionID__r.End_Date__c, PromotionID__r.Start_Date__c,PromotionID__r.Promotion_Number__c,
                                                       Title__r.Content_Type__c,Title__r.Video_Version__c,WSP_Currency__c
                                                       FROM Promotion_Title__c WHERE PromotionID__c=:promotionId AND Id IN :ptIDs LIMIT 50000];
        
        for(Promotion_Title__c pt : lstPromotionTitles ){
            if(mapvvPT.containsKey(pt.Title__r.Video_Version__c))
            {
                mapvvPT.get(pt.Title__r.Video_Version__c).add(pt);
            }
            else
            {
                mapvvPT.put(pt.Title__r.Video_Version__c,new List<Promotion_Title__c>{pt});
            }
            
            //setPromotionVVs.add(pt.Video_Version__c);
            if(pt.Title__r.Content_Type__c == 'Episode')
            {
                vvEpisodes.add(pt.Title__r.Video_Version__c);
            }
            setPromotionChannels.add(pt.Channel__c);
            setPromotionFormats.add(pt.Format__c);
            setPromotionContentTypes.add(pt.Title__r.Content_Type__c);
            setPriceCode.add(pt.Price_Code__c);
            setPriceTier.add(pt.Price_Tier__c);
        }
        if(!vvEpisodes.isEmpty())
        {
            for(Playlist_Content__c playContent : [SELECT Id,Playlist__c,Playlist__r.Parent_Title__r.Digital_Planning__c,Playlist__r.Parent_Title__r.Clear_to_Avail__c,Playlist__r.Parent_Title__r.Formats__c,Content_VV__c FROM Playlist_Content__c WHERE Content_VV__c IN :vvEpisodes LIMIT 50000])
            {
                if(vvEpisodePlaylistContentMap.containsKey(playContent.Content_VV__c))
                {
                    vvEpisodePlaylistContentMap.get(playContent.Content_VV__c).add(playContent);
                } else{
                    vvEpisodePlaylistContentMap.put(playContent.Content_VV__c,new List<Playlist_Content__c>{playContent});
                }
            }
        }
        
        for(Pricing__c price : [SELECT Id,Name,Price_Tier__c,WS_Price__c,Account__c,Account__r.Name,Country__c,Country__r.Name,Channel__c,
                                Format__c,Content_Type__c,Price_Code_Status__c
                                FROM Pricing__c
                                WHERE Name IN :setPriceCode AND Account__r.Name IN :mapNameAccount.keySet()
                                AND Country__r.Name IN :mapNameCountry.keyset() LIMIT 50000
                               ])
        {
            if(price.Price_Tier__c != '' && price.Price_Tier__c != null)
            {
                setPriceTier.add(price.Price_Tier__c);
            }
            mapPriceCodePricing.put(price.Name+'_'+price.Content_Type__c+'_'+price.Account__r.Name+'_'+price.Country__r.Name+'_'+price.Format__c+'_'+price.Channel__c, price);
        }
        
        for(Rate_Card__c rc : [SELECT Id,Price_Tier__c,Start_Date__c,End_Date__c,Account__c,Account__r.Name,Country__c,Country__r.Name,Channel__c,
                               Format__c,Content_Type__c
                               FROM Rate_Card__c
                               WHERE Price_Tier__c IN :setPriceTier AND Account__r.Name IN :mapNameAccount.keySet()
                               AND Country__r.Name IN :mapNameCountry.keyset() AND Rate_Card_Type__c != 'WSP' AND Rate_Card_Type__c != 'WSP/Split'
                               AND RC_Lifecycle__c LIKE '%Active%' LIMIT 50000
                              ])
        {
            if(rc.Price_Tier__c != '' && rc.Price_Tier__c != null)
            {
                if(mapPriceTierRC.containsKey(rc.Price_Tier__c+'_'+rc.Content_Type__c+'_'+rc.Account__r.Name+'_'+rc.Country__r.Name+'_'+rc.Format__c+'_'+rc.Channel__c))
                {
                    mapPriceTierRC.get(rc.Price_Tier__c+'_'+rc.Content_Type__c+'_'+rc.Account__r.Name+'_'+rc.Country__r.Name+'_'+rc.Format__c+'_'+rc.Channel__c).add(rc);
                }
                else
                {
                    mapPriceTierRC.put(rc.Price_Tier__c+'_'+rc.Content_Type__c+'_'+rc.Account__r.Name+'_'+rc.Country__r.Name+'_'+rc.Format__c+'_'+rc.Channel__c,new List<Rate_Card__c>{rc});
                }
            }
        }
        
        for(Title__c titleRec : [SELECT id,Name,Video_Version__c,Formats__c,Digital_Planning__c,Clear_to_Avail__c,
                                 Content_Type__c FROM Title__c where Video_Version__c IN: mapvvPT.keySet() LIMIT 50000
                                ])
        {
            videoVersionsToTitleRec.put(titleRec.Video_Version__c,titleRec);
        }
        System.debug('videoVersionsToTitleRec==='+videoVersionsToTitleRec);
        
        for(Client_Avail_Price__c cap : [SELECT Account__c,Title_Video_Version__c,Country__c,Client_Avail_Channel__c,Client_Avail_Format__c,
                                         Effective_Date__c,Expiry_Date__c,Id,RecordTypeId
                                         FROM Client_Avail_Price__c
                                         WHERE Account__c IN :mapNameAccount.keySet() AND Title_Video_Version__c IN :mapvvPT.keySet()
                                         AND Country__c IN :mapNameCountry.keySet() AND RecordType.Name = 'TEMP' AND Promotion__c != null AND Promotion__c != :promoREC.Id
                                         LIMIT 50000
                                        ])
        {
            listCAPKey.add(cap.Account__c+'_'+cap.Title_Video_Version__c+'_'+cap.Country__c+'_'+cap.Client_Avail_Channel__c+'_'+cap.Client_Avail_Format__c);
            mapCAP.put(cap.Account__c+'_'+cap.Title_Video_Version__c+'_'+cap.Country__c+'_'+cap.Client_Avail_Channel__c+'_'+cap.Client_Avail_Format__c,cap);
        }               
        System.debug('mapCAP==='+mapCAP);
        System.debug('listCAPKey==='+listCAPKey);
        
        System.debug('mapvvPT.keySet()==='+mapvvPT.keySet());
        System.debug('mapNameAccount.keySet()==='+mapNameAccount.keySet());
        System.debug('mapNameCountry.keyset()==='+mapNameCountry.keyset());
        System.debug('setPromotionChannels==='+setPromotionChannels);
        System.debug('setPromotionFormats==='+setPromotionFormats);
        System.debug('setPromotionContentTypes==='+setPromotionContentTypes);
        
        
        for(Client_Avail__c ca : [SELECT ID,Name, Start_Date__c,End_Date__c,SubKey__c,Title_Video_Version__c,Title_Content_Type__c,Status__c,
                                  Client__r.Name,Release_Plan_Country__c,Release_Plan_Channel__c,Release_Plan_Format__c
                                  FROM Client_Avail__c
                                  WHERE Title_Video_Version__c IN :mapvvPT.keySet() AND Client__r.Name IN  :mapNameAccount.keySet()
                                  AND Release_Plan_Country__c IN: mapNameCountry.keyset() AND Title_Content_Type__c IN :setPromotionContentTypes
                                  LIMIT 50000])
        {
            String keyCA= ca.Client__r.Name+'_'+ca.Title_Video_Version__c+'_'+ca.Release_Plan_Country__c+'_'+ca.Release_Plan_Format__c+'_'+ca.Release_Plan_Channel__c;
            System.debug('keyCA==='+keyCA);
            if(mapKeyClientAvail !=null && mapKeyClientAvail.containsKey(keyCA))
            {
                mapKeyClientAvail.get(keyCA).add(ca);
            }
            else
            {
                mapKeyClientAvail.put(keyCA, new List<Client_Avail__c>{ca});
            }
        }
        System.debug('mapKeyClientAvail==='+mapKeyClientAvail);
        
        try{
            if(!mapNameAccount.keySet().isEmpty() && !mapNameCountry.keySet().isEmpty() && !lstPromotionTitles.isEmpty())
            {
                for(String vvNumber :mapvvPT.keySet())
                {
                    System.debug('vvNumber==='+vvNumber);
                    Promotion_Title_Detail__c promoTitleDetailVideoVersion = new Promotion_Title_Detail__c();
                    promoTitleDetailVideoVersion.Promotion__c = promoREC.Id;
                    promoTitleDetailVideoVersion.Video_Version__c = vvNumber;
                    promoTitleDetailVideoVersion.Title__c = videoVersionsToTitleRec.get(vvNumber).Id;
                    promoTitleDetailVideoVersion.PTDKey__c = promoREC.Promotion_Number__c+'_'+vvNumber;
                    Boolean inDigiPlanning = true;
                    if(videoVersionsToTitleRec.get(vvNumber).Digital_Planning__c == null || (videoVersionsToTitleRec.get(vvNumber).Digital_Planning__c != null && !videoVersionsToTitleRec.get(vvNumber).Digital_Planning__c.equals('Yes')))
                    {
                        if(videoVersionsToTitleRec.get(vvNumber).Content_Type__c.equals('Episode'))
                        {
                            if(vvEpisodePlaylistContentMap.containsKey(vvNumber))
                            {
                                Integer countPlayCont = 0;
                                for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(vvNumber)){
                                    if(playCont.Playlist__r.Parent_Title__r.Digital_Planning__c == null || (playCont.Playlist__r.Parent_Title__r.Digital_Planning__c != null && !playCont.Playlist__r.Parent_Title__r.Digital_Planning__c.equals('Yes'))){
                                        countPlayCont++;
                                    }
                                }
                                if(countPlayCont == vvEpisodePlaylistContentMap.get(vvNumber).size())
                                {
                                    promoTitleDetailVideoVersion.Status__c = 'Warning';
                                    promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have Digital Planning set to yes on the Title Record.';
                                    lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                                    lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                                    inDigiPlanning = false;
                                }
                                /*if(vvEpisodePlaylistContentMap.get(vvNumber).Playlist__r.Parent_Title__r.Digital_Planning__c == null || (vvEpisodePlaylistContentMap.get(vvNumber).Playlist__r.Parent_Title__r.Digital_Planning__c != null && !vvEpisodePlaylistContentMap.get(vvNumber).Playlist__r.Parent_Title__r.Digital_Planning__c.equals('Yes')))
                                {
                                    promoTitleDetailVideoVersion.Status__c = 'Warning';
                                    promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have Digital Planning set to yes on the Title Record.';
                                    lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                                    lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                                    inDigiPlanning = false;
                                }*/
                            }
                            else
                            {
                                promoTitleDetailVideoVersion.Status__c = 'Warning';
                                promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have Digital Planning set to yes on the Title Record.';
                                lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                                lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                                inDigiPlanning = false;
                            }
                        }
                        else
                        {
                            promoTitleDetailVideoVersion.Status__c = 'Warning';
                            promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have Digital Planning set to yes on the Title Record.';
                            lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                            lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                            inDigiPlanning = false;
                        }
                    }
                    Boolean inClearToAvail = true;
                    if(inDigiPlanning && videoVersionsToTitleRec.get(vvNumber).Clear_To_Avail__c != true)
                    {
                        if(videoVersionsToTitleRec.get(vvNumber).Content_Type__c.equals('Episode'))
                        {
                            if(vvEpisodePlaylistContentMap.containsKey(vvNumber))
                            {
                                Integer countPlayCont = 0;
                                for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(vvNumber)){
                                    if(playCont.Playlist__r.Parent_Title__r.Clear_To_Avail__c != true){
                                        countPlayCont++;
                                    }
                                }
                                if(countPlayCont == vvEpisodePlaylistContentMap.get(vvNumber).size())
                                {
                                    promoTitleDetailVideoVersion.Status__c = 'Warning';
                                    promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have the cleared to avail flag checked in the Title record.';
                                    lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                                    lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                                    inDigiPlanning = false;
                                }
                                /*if(vvEpisodePlaylistContentMap.get(vvNumber).Playlist__r.Parent_Title__r.Clear_To_Avail__c != true)
                                {
                                    promoTitleDetailVideoVersion.Status__c = 'Warning';
                                    promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have the cleared to avail flag checked in the Title record.';
                                    lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                                    lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                                    inDigiPlanning = false;
                                }*/
                            }
                            else
                            {
                                promoTitleDetailVideoVersion.Status__c = 'Warning';
                                promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have the cleared to avail flag checked in the Title record.';
                                lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                                lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                                inDigiPlanning = false;
                            }
                        }
                        else
                        {
                            promoTitleDetailVideoVersion.Status__c = 'Warning';
                            promoTitleDetailVideoVersion.Comments__c = 'The video version selected does not have the cleared to avail flag checked in the Title record.';
                            lstPromoTitlesForUpsertion.add(promoTitleDetailVideoVersion);
                            lstUpsertedKeys.add(promoTitleDetailVideoVersion.PTDKey__c);
                            inClearToAvail = false;
                        }
                    }
                    if(inClearToAvail && inDigiPlanning)
                    {
                        for(Promotion_Title__c pt : mapvvPT.get(vvNumber))
                        {
                            Boolean inFormat = true;
                            System.debug('pt==='+pt);
                            String format= pt.Format__c;
                            Promotion_Title_Detail__c promoTitleDetailFormat = new Promotion_Title_Detail__c();
                            promoTitleDetailFormat.Promotion__c = promoTitleDetailVideoVersion.Promotion__c;
                            promoTitleDetailFormat.Video_Version__c = promoTitleDetailVideoVersion.Video_Version__c;
                            promoTitleDetailFormat.PTDKey__c = promoTitleDetailVideoVersion.PTDKey__c;
                            promoTitleDetailFormat.Title__c = promoTitleDetailVideoVersion.Title__c;
                            promoTitleDetailFormat.Format__c = format;
                            if(format != 'All' && format != 'All 2D')
                            {
                                if(!videoVersionsToTitleRec.get(vvNumber).Content_Type__c.equals('Episode'))
                                {
                                    List<String> lstformats = new List<String>();
                                    if(videoVersionsToTitleRec.get(vvNumber).Formats__c != null && videoVersionsToTitleRec.get(vvNumber).Formats__c != '')
                                    {
                                        lstformats = videoVersionsToTitleRec.get(vvNumber).Formats__c.split(';');
                                    }
                                    if(!lstformats.contains(format))
                                    {
                                        promoTitleDetailFormat.PTDKey__c = promoTitleDetailFormat.PTDKey__c+'_'+format;
                                        promoTitleDetailFormat.Status__c = 'Warning';
                                        promoTitleDetailFormat.Comments__c = 'The format selected is not an available format for this title.';
                                        lstPromoTitlesForUpsertion.add(promoTitleDetailFormat);
                                        lstUpsertedKeys.add(promoTitleDetailFormat.PTDKey__c);
                                        inFormat = false;
                                    }
                                }
                                else if(videoVersionsToTitleRec.get(vvNumber).Content_Type__c.equals('Episode'))
                                {
                                    List<String> lstformats = new List<String>();
                                    if(videoVersionsToTitleRec.get(vvNumber).Formats__c != null && videoVersionsToTitleRec.get(vvNumber).Formats__c != '')
                                    {
                                        lstformats = videoVersionsToTitleRec.get(vvNumber).Formats__c.split(';');
                                    }
                                    if(lstformats.isEmpty() && vvEpisodePlaylistContentMap.containsKey(vvNumber))
                                    {
                                        //lstformats = vvEpisodePlaylistContentMap.get(vvNumber).Playlist__r.Parent_Title__r.Formats__c.split(';');
                                        for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(vvNumber))
                                        {
                                            if(playCont.Playlist__r.Parent_Title__r.Formats__c != null && playCont.Playlist__r.Parent_Title__r.Formats__c != '')
                                            {
                                                lstformats.addAll(playCont.Playlist__r.Parent_Title__r.Formats__c.split(';'));
                                            }
                                        }
                                    }
                                    Set<String> setFormats = new Set<String>(lstformats);
                                    if(!setFormats.contains(format))
                                    {
                                        promoTitleDetailFormat.PTDKey__c = promoTitleDetailFormat.PTDKey__c+'_'+format;
                                        promoTitleDetailFormat.Status__c = 'Warning';
                                        promoTitleDetailFormat.Comments__c = 'The format selected is not an available format for this title.';
                                        lstPromoTitlesForUpsertion.add(promoTitleDetailFormat);
                                        lstUpsertedKeys.add(promoTitleDetailFormat.PTDKey__c);
                                        inFormat = false;
                                    }
                                }
                            }
                            if(inFormat)
                            {
                                for(String accName : mapNameAccount.keySet())
                                {
                                    System.debug('accName==='+accName);
                                    for(String countryName : mapNameCountry.keySet())
                                    {
                                        System.debug('countryName==='+countryName);
                                        if(mapNameSF.containsKey(accName+'_'+countryName))
                                        {
                                            Promotion_Title_Detail__c promoTitleDetailAccCountry = new Promotion_Title_Detail__c();
                                            promoTitleDetailAccCountry.Promotion__c = promoTitleDetailFormat.Promotion__c;
                                            promoTitleDetailAccCountry.Video_Version__c = promoTitleDetailFormat.Video_Version__c;
                                            promoTitleDetailAccCountry.Account__c = mapNameAccount.get(accName).Id;
                                            promoTitleDetailAccCountry.Format__c = promoTitleDetailFormat.Format__c;
                                            promoTitleDetailAccCountry.Country__c = mapNameCountry.get(countryName).Id;
                                            promoTitleDetailAccCountry.Title__c = promoTitleDetailFormat.Title__c;
                                            promoTitleDetailAccCountry.PTDKey__c = promoREC.Promotion_Number__c+'_'+
                                                mapNameAccount.get(accName).Name+'_'+mapNameCountry.get(countryName).Name+'_'+
                                                vvNumber;
                                            Promotion_Title_Detail__c ptdREC;
                                            if(format != 'All' && format != 'All 2D')
                                            {
                                                promoTitleDetailAccCountry.PTDKey__c = promoTitleDetailAccCountry.PTDKey__c+'_'+format;
                                                ptdREC = new Promotion_Title_Detail__c();
                                                ptdREC = createPDTRec(
                                                    promotionId,pt,promoTitleDetailAccCountry,format,accName,countryName,mapNameSF,mapPriceCodePricing,
                                                    mapPriceTierRC
                                                );
                                                lstPromoTitlesForUpsertion.add(ptdREC);
                                                lstUpsertedKeys.add(ptdREC.PTDKey__c);
                                            }
                                            else if(format.equals('All') || format.equals('All 2D'))
                                            {
                                                System.debug('Custom Setting Data==='+promotFormatMap.get(format).Formats__c.split(','));
                                                for(String formatRec : promotFormatMap.get(format).Formats__c.split(','))
                                                {
                                                    System.debug('formatRec==='+formatRec);
                                                    if(!videoVersionsToTitleRec.get(vvNumber).Content_Type__c.equals('Episode')
                                                       &&
                                                       !lstUpsertedKeys.contains(promoTitleDetailAccCountry.PTDKey__c+'_'+formatRec+'_'+pt.Channel__c))
                                                    {
                                                        if(videoVersionsToTitleRec.get(pt.Video_Version__c).Formats__c != null)
                                                        {
                                                            List<String> lstformats = videoVersionsToTitleRec.get(pt.Video_Version__c).Formats__c.split(';');
                                                            System.debug('lstformats==='+lstformats);
                                                            if(lstformats.contains(formatRec))
                                                            {
                                                                System.debug('formatRec==='+formatRec);
                                                                promoTitleDetailAccCountry.PTDKey__c = promoTitleDetailAccCountry.PTDKey__c+
                                                                    '_'+formatRec;
                                                                ptdREC = new Promotion_Title_Detail__c();
                                                                ptdREC = createPDTRec(
                                                                    promotionId,pt,promoTitleDetailAccCountry,formatRec,accName,countryName,mapNameSF,
                                                                    mapPriceCodePricing,mapPriceTierRC
                                                                );
                                                                System.debug('ptdREC==='+ptdREC);
                                                                lstPromoTitlesForUpsertion.add(ptdREC);
                                                                lstUpsertedKeys.add(ptdREC.PTDKey__c);
                                                            }
                                                        }
                                                    }
                                                    else if(videoVersionsToTitleRec.get(vvNumber).Content_Type__c.equals('Episode')
                                                            &&
                                                            !lstUpsertedKeys.contains(promoTitleDetailAccCountry.PTDKey__c+'_'+formatRec+'_'+pt.Channel__c))
                                                    {
                                                        //List<String> lstformats = new List<String>();
                                                        Set<String> setFormats = new Set<String>();
                                                        if(videoVersionsToTitleRec.get(vvNumber).Formats__c != null && videoVersionsToTitleRec.get(vvNumber).Formats__c != '')
                                                        {
                                                            setFormats = new Set<String>(videoVersionsToTitleRec.get(vvNumber).Formats__c.split(';'));
                                                        }
                                                        if(setFormats.isEmpty() && vvEpisodePlaylistContentMap.containsKey(vvNumber))
                                                        {
                                                            //lstformats = vvEpisodePlaylistContentMap.get(vvNumber).Playlist__r.Parent_Title__r.Formats__c.split(';');
                                                            for(Playlist_Content__c playCont : vvEpisodePlaylistContentMap.get(vvNumber))
                                                            {
                                                                setFormats = new Set<String>();
                                                                if(playCont.Playlist__r.Parent_Title__r.Formats__c != null && playCont.Playlist__r.Parent_Title__r.Formats__c != '')
                                                                {
                                                                    setFormats = new Set<String>(playCont.Playlist__r.Parent_Title__r.Formats__c.split(';'));
                                                                }
                                                                if(setFormats.contains(format))
                                                                {
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                        if(!setFormats.isEmpty())
                                                        {
                                                            if(setFormats.contains(formatRec))
                                                            {
                                                                promoTitleDetailAccCountry.PTDKey__c = promoTitleDetailAccCountry.PTDKey__c+
                                                                    '_'+formatRec;
                                                                ptdREC = new Promotion_Title_Detail__c();
                                                                ptdREC = createPDTRec(
                                                                    promotionId,pt,promoTitleDetailAccCountry,formatRec,accName,countryName,mapNameSF,
                                                                    mapPriceCodePricing,mapPriceTierRC
                                                                );
                                                                System.debug('ptdREC==='+ptdREC);
                                                                lstPromoTitlesForUpsertion.add(ptdREC);
                                                                lstUpsertedKeys.add(ptdREC.PTDKey__c);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(!lstPromoTitlesForUpsertion.isEmpty() && insertFlag)    
            {
                upsertedResults = Database.upsert(lstPromoTitlesForUpsertion,Promotion_Title_Detail__c.Fields.PTDKey__c,true);
                if(promoRec.Status__c == 'Draft')
                {
                    promoRec.Status__c = 'In Progress';
                }
                promoRec.Last_Validated__c = System.now();
                UPDATE promoRec;
            }
        }
        catch(Exception e){
            throw e; 
        }
        System.debug('lstUpsertedIds==='+lstUpsertedKeys);
        return lstUpsertedKeys ; 
    }
    
    /*Method to create PDT Record with status and comment, return the reference
* Method name : createPDTRec
* Parameter : promotionId,pt,format,accName,countryName,mapNameCountry,mapNameAccount,mapKeyClientAvail,videoVersionsToTitleRec,mapNameSF,
mapPriceCodePricing,mapPriceTierRC
* Return : PTD refrence
*/
    static Promotion_Title_Detail__c createPDTRec(
        Id promotionId,Promotion_Title__c pt,Promotion_Title_Detail__c promoTitleDetail,String format,
        String accName, String countryName,Map<String,Agreement__c> mapNameSF,
        Map<String,Pricing__c> mapPriceCodePricing,Map<String,List<Rate_Card__c>> mapPriceTierRC
    )
    {
        String keyPDT = accName+'_'+pt.Video_Version__c+'_'+countryName+'_'+format+'_'+pt.Channel__c;
        Promotion_Title_Detail__c localPromoTitleDetail = new Promotion_Title_Detail__c();
        localPromoTitleDetail.Promotion__c = promoTitleDetail.Promotion__c;
        localPromoTitleDetail.Video_Version__c = promoTitleDetail.Video_Version__c;
        localPromoTitleDetail.Account__c = promoTitleDetail.Account__c;
        localPromoTitleDetail.Country__c = promoTitleDetail.Country__c;
        localPromoTitleDetail.Title__c = promoTitleDetail.Title__c;
        localPromoTitleDetail.Content_Type__c = pt.Title__r.Content_Type__c;
        localPromoTitleDetail.Promotion_Title__c = pt.id;
        localPromoTitleDetail.Format__c = format;
        localPromoTitleDetail.Channel__c = pt.Channel__c;
        //localPromoTitleDetail.PTDKey__c = promoTitleDetail.PTDKey__c+'_'+pt.Channel__c;
        localPromoTitleDetail.PTDKey__c = pt.PromotionID__r.Promotion_Number__c+'_'+accName+'_'+countryName+'_'+pt.Title__r.Video_Version__c+'_'+format+'_'+pt.Channel__c;
        
        Boolean sfFlag = true;
        if(
            (
                !String.isBlank(mapNameSF.get(accName+'_'+countryName).Content_Type__c)
                &&
                !mapNameSF.get(accName+'_'+countryName).Content_Type__c.contains(pt.Title__r.Content_Type__c)
            )
            ||
            (
                !String.isBlank(mapNameSF.get(accName+'_'+countryName).Channel_Picklist__c)
                &&
                !mapNameSF.get(accName+'_'+countryName).Channel_Picklist__c.contains(pt.Channel__c)
            )
        )
        {
            sfFlag = false;
        }
        
        if(sfFlag && !String.isBlank(mapNameSF.get(accName+'_'+countryName).Format__c))
        {
            List<String> listFormat = mapNameSF.get(accName+'_'+countryName).Format__c.split(';');
            
            if(!listFormat.contains(format))
            {
                sfFlag = false;
            }
        }
        if(sfFlag)
        {
            if(String.isBlank(pt.Price_Code__c))
            {
                localPromoTitleDetail.Price_Tier__c = pt.Price_Tier__c;
                localPromoTitleDetail.Wholsale_Price__c = pt.WSP__c;
            }
            else
            {
                if(
                    mapPriceCodePricing.containsKey(pt.Price_Code__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_'+format+'_'+pt.Channel__c)
                    &&
                    (
                        mapPriceCodePricing.get(pt.Price_Code__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_'+format+'_'+pt.Channel__c).Price_Code_Status__c != null
                        &&
                        mapPriceCodePricing.get(pt.Price_Code__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_'+format+'_'+pt.Channel__c).Price_Code_Status__c.equals('Active')
                    )
                )
                {
                    Pricing__c price = mapPriceCodePricing.get(pt.Price_Code__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_'+format+'_'+pt.Channel__c);
                    localPromoTitleDetail.Price_Tier__c = price.Price_Tier__c;
                    localPromoTitleDetail.Wholsale_Price__c = price.WS_Price__c ;
                }
                else
                {
                    localPromoTitleDetail.Price_Tier__c = null;
                    localPromoTitleDetail.Wholsale_Price__c = null;
                }
            }
            System.debug('keyPDT==='+keyPDT);
            if(mapKeyClientAvail.containsKey(keyPDT) && mapKeyClientAvail.get(keyPDT)!=null)
            {
                System.debug('mapKeyClientAvail keyPDT size'+mapKeyClientAvail.get(keyPDT).size());
                Integer countCANotConfirmed = 0;
                List<Client_Avail__c> confirmedCAList = new List<Client_Avail__c>();
                for(Client_Avail__c ca : mapKeyClientAvail.get(keyPDT)){
                    if(ca.status__c == 'Confirmed'){
                        confirmedCAList.add(ca);
                    }
                }
                if(!confirmedCAList.isEmpty())
                {
                    System.debug('confirmedCAList==='+confirmedCAList);
                    Client_Avail__c earliestCA = confirmedCAList[0];
                    Client_Avail__c latestCA = confirmedCAList[0];
                    List<Client_Avail__c> confirmedCAListWithinDates = new List<Client_Avail__c>();
                    for(Client_Avail__c ca : confirmedCAList)
                    {
                        if(ca.Start_Date__c <=  pt.PromotionID__r.End_Date__c && ca.End_Date__c >= pt.PromotionID__r.Start_Date__c)
                        {
                            confirmedCAListWithinDates.add(ca);
                            if(ca.Start_Date__c < earliestCA.Start_Date__c)
                            {
                                earliestCA = ca;
                            }
                            if(ca.End_Date__c > latestCA.End_Date__c)
                            {
                                latestCA = ca;
                            }
                        }
                    }
                    System.debug('earliestCA==='+earliestCA.Name);
                    System.debug('latestCA==='+latestCA.Name);
                    if(!confirmedCAListWithinDates.isEmpty() && earliestCA.Start_Date__c <=  pt.PromotionID__r.End_Date__c && latestCA.End_Date__c >= pt.PromotionID__r.Start_Date__c)
                    {
                        if(!String.isBlank(pt.Price_Code__c) && String.isBlank(localPromoTitleDetail.Price_Tier__c) && String.isBlank(String.valueOf(localPromoTitleDetail.Wholsale_Price__c)))
                        {
                            localPromoTitleDetail.Status__c = 'Error';
                            localPromoTitleDetail.Comments__c='Price Code Not Found';
                        }
                        else if(!String.isBlank(localPromoTitleDetail.Price_Tier__c) && !String.isBlank(String.valueOf(localPromoTitleDetail.Wholsale_Price__c)))
                        {
                            localPromoTitleDetail.Status__c = 'Error';
                            localPromoTitleDetail.Comments__c='Both Price Tier and WSP Cannot Be Populated';
                        }
                        else
                        {
                            Boolean pcFlag = true;
                            if(!String.isBlank(String.valueOf(localPromoTitleDetail.Wholsale_Price__c)))
                            {
                                if(mapNameSF.get(accName+'_'+countryName).WSP_Currency__c == null || mapNameSF.get(accName+'_'+countryName).WSP_Currency__c == '')
                                {
                                    pcFlag = false;
                                    localPromoTitleDetail.WSP_Currency__c = pt.WSP_Currency__c;
                                    localPromoTitleDetail.Status__c = 'Error';
                                    localPromoTitleDetail.Comments__c='Invalid WSP Currency';
                                }
                                else if(String.isBlank(pt.Price_Code__c))
                                {
                                    if(!mapNameSF.get(accName+'_'+countryName).WSP_Currency__c.equals(pt.WSP_Currency__c))
                                    {
                                        pcFlag = false;
                                        localPromoTitleDetail.WSP_Currency__c = pt.WSP_Currency__c;
                                        localPromoTitleDetail.Status__c = 'Error';
                                        localPromoTitleDetail.Comments__c='Invalid WSP Currency';
                                    }
                                }
                            }
                            if(pcFlag)
                            {
                                if(String.isBlank(pt.Price_Code__c))
                                {
                                    localPromoTitleDetail.WSP_Currency__c = pt.WSP_Currency__c;
                                }
                                else
                                {
                                    localPromoTitleDetail.WSP_Currency__c = mapNameSF.get(accName+'_'+countryName).WSP_Currency__c;
                                }
                                System.debug('mapPriceTierRC==='+mapPriceTierRC);
                                Boolean rcFlag = true;
                                //Boolean rcNotEnabledFlag = false;
                                if(String.isBlank(localPromoTitleDetail.Price_Tier__c))
                                {
                                    rcFlag = false;
                                }
                                else if(!String.isBlank(localPromoTitleDetail.Price_Tier__c))
                                {
                                    /*if(mapNameSF.get(accName+'_'+countryName).CRM_Storefront__c == FALSE)
{
rcNotEnabledFlag = true;
}*/
                                    System.debug('In format not blank');
                                    if(mapPriceTierRC.containsKey(localPromoTitleDetail.Price_Tier__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_'+format+'_'+pt.Channel__c))
                                    {
                                        System.debug('In format');
                                        List<Rate_Card__c> lstRC = mapPriceTierRC.get(localPromoTitleDetail.Price_Tier__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_'+format+'_'+pt.Channel__c);
                                        for(Rate_Card__c rc : lstRC)
                                        {
                                            if(
                                                (pt.PromotionID__r.Start_Date__c >= rc.Start_Date__c && pt.PromotionID__r.Start_Date__c <= rc.End_Date__c)
                                                ||
                                                (earliestCA.Start_Date__c >= rc.Start_Date__c && earliestCA.Start_Date__c <= rc.End_Date__c)
                                            )
                                            {
                                                rcFlag = false;
                                                localPromoTitleDetail.Rate_Card__c = rc.Id;
                                                break;
                                            }
                                        }
                                    }
                                    else if(mapPriceTierRC.containsKey(localPromoTitleDetail.Price_Tier__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_All_'+pt.Channel__c))
                                    {
                                        System.debug('In format All');
                                        List<Rate_Card__c> lstRC = mapPriceTierRC.get(localPromoTitleDetail.Price_Tier__c+'_'+localPromoTitleDetail.Content_Type__c+'_'+accName+'_'+countryName+'_All_'+pt.Channel__c);
                                        for(Rate_Card__c rc : lstRC)
                                        {
                                            if(
                                                (pt.PromotionID__r.Start_Date__c >= rc.Start_Date__c && pt.PromotionID__r.Start_Date__c <= rc.End_Date__c)
                                                ||
                                                (earliestCA.Start_Date__c >= rc.Start_Date__c && earliestCA.Start_Date__c <= rc.End_Date__c)
                                            )
                                            {
                                                System.debug('In if');
                                                rcFlag = false;
                                                localPromoTitleDetail.Rate_Card__c = rc.Id;
                                                break;
                                            }
                                        }
                                    }
                                }
                                /*if(rcNotEnabledFlag)
{
if(rcFlag)
{
localPromoTitleDetail.Status__c = 'Error';
localPromoTitleDetail.Comments__c='Price Tier is Invalid and Rate Card is Not Enabled for the Storefront';
}
else
{
localPromoTitleDetail.Status__c = 'Error';
localPromoTitleDetail.Comments__c='Price Tier is valid, but Rate Card is Not Enabled for the Storefront';
}
}
else */
                                if(rcFlag)
                                {
                                    localPromoTitleDetail.Status__c = 'Error';
                                    localPromoTitleDetail.Comments__c='Invalid Price Tier';
                                }
                                else
                                {
                                    List<Client_Avail__c> notPassCAs= new List<Client_Avail__c>();
                                    List<Client_Avail__c> passCAs= new List<Client_Avail__c>();
                                    for(Client_Avail__c ca : confirmedCAListWithinDates)
                                    {
                                        if(ca.Start_Date__c <= pt.PromotionID__r.Start_Date__c && ca.End_Date__c >= pt.PromotionID__r.End_Date__c)
                                        {
                                            notPassCAs.add(ca);
                                        }
                                        else
                                        {
                                            passCAs.add(ca);
                                        }
                                    }
                                    if(passCAs.isEmpty())
                                    {
                                        localPromoTitleDetail.Client_Avail_Names__c= '';
                                        for(Client_Avail__c ca : notPassCAs)
                                        {
                                            localPromoTitleDetail.Client_Avail_Names__c += (ca.Name+';');
                                        }
                                        localPromoTitleDetail.Client_Avail_Count__c = notPassCAs.size();
                                        if(
                                            mapCAP.containsKey(accName+'_'+pt.Video_Version__c+'_'+countryName+'_'+pt.Channel__c+'_'+format)
                                            &&
                                            mapCAP.get(accName+'_'+pt.Video_Version__c+'_'+countryName+'_'+pt.Channel__c+'_'+format).Effective_Date__c <= pt.PromotionID__r.End_Date__c
                                            &&
                                            mapCAP.get(accName+'_'+pt.Video_Version__c+'_'+countryName+'_'+pt.Channel__c+'_'+format).Expiry_Date__c >= pt.PromotionID__r.Start_Date__c
                                        )
                                        {
                                            localPromoTitleDetail.Status__c = 'Pass';
                                            localPromoTitleDetail.Comments__c='Overlapping Promotion Present';
                                        }
                                        else
                                        {
                                            localPromoTitleDetail.Status__c = 'Pass';
                                            localPromoTitleDetail.Comments__c='';
                                        }
                                    }
                                    else
                                    {
                                        localPromoTitleDetail.Client_Avail_Names__c= '';
                                        for(Client_Avail__c ca : passCAs)
                                        {
                                            localPromoTitleDetail.Client_Avail_Names__c += (ca.Name+';');
                                        }
                                        if(!notPassCAs.isEmpty())
                                        {
                                            for(Client_Avail__c ca : notPassCAs)
                                            {
                                                localPromoTitleDetail.Client_Avail_Names__c += (ca.Name+';');
                                            }
                                        }
                                        localPromoTitleDetail.Client_Avail_Count__c = passCAs.size();
                                        localPromoTitleDetail.Status__c = 'Pass';
                                        localPromoTitleDetail.Comments__c='The Client Avails window is not active for the entire Promotion window';
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        localPromoTitleDetail.Status__c = 'Warning';
                        localPromoTitleDetail.Comments__c='No Client Avails Within Promotion Date';
                    }                        
                }
                else
                {
                    localPromoTitleDetail.Status__c = 'Warning';
                    localPromoTitleDetail.Comments__c='No Confirmed Client Avails';
                }
            }
            else
            {
                localPromoTitleDetail.Client_Avail__c = null;
                localPromoTitleDetail.Status__c = 'Warning';
                localPromoTitleDetail.Comments__c='No Client Avails';
                System.debug('Warning No Client Avails');
            }
        }
        else
        {
            localPromoTitleDetail.Status__c = 'Warning';
            localPromoTitleDetail.Comments__c='Storefront does not have Content Type/Channel/Format';
        }
        System.debug('promoTitleDetailStatus__c==='+promoTitleDetail.Status__c);
        System.debug('localPromoTitleDetail==='+localPromoTitleDetail);
        return localPromoTitleDetail;
    }
    
    /*Method to create PDT Record with status and comment, return the reference
* Method name : deletePTDs
* Parameter : Promotion Id,List Of Upserted PTDs in createlstPromoTitleDetail
* Return : PTD refrence
*/
    @RemoteAction
    global static Boolean deletePTDs(Id promotionId, List<String> lstUpsertedKeys)
    {
        AggregateResult[] groupedResults  = [SELECT count(id)cnt  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND PTDKey__c NOT IN :lstUpsertedKeys];
        Integer countPTD = (Integer)groupedResults[0].get('cnt');
        if(countPTD > 0)
        {
            List<Promotion_Title_Detail__c> lstPTDs = [SELECT Id  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId AND PTDKey__c NOT IN :lstUpsertedKeys LIMIT 10000];
            Database.delete(lstPTDs);
        }
        if(countPTD > 10000)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    /*Method to create PDT Record with status and comment, return the reference
* Method name : findDeltaPTDValidate
* Parameter : Promotion Id,List Of Upserted PTDs in createlstPromoTitleDetail
* Return : PTD refrence
*/
    @RemoteAction
    //global static List<Promotion_Title_Detail__c> findDeltaPTDValidate(Id promotionId, List<Promotion_Title_Detail__c> lstUpsertPTD)
    global static Boolean findDeltaPTDValidate(Id promotionId)
    {
        /*System.debug('lstUpsertPTD==='+lstUpsertPTD);

Map<String, WB_CommitPromotionController.TempPTDRecWrapper> mapPTDRecs = new Map<String, WB_CommitPromotionController.TempPTDRecWrapper>();
List<Promotion_Title_Detail__c> lstPTDUpsertRecs = new List<Promotion_Title_Detail__c>();
List<Promotion_Title_Detail__c> lstPTDDeleteRecs = new List<Promotion_Title_Detail__c>();
List<Promotion_Title_Detail__c> lstPTDDatabaseRecs = [SELECT Id,PTDKey__c,Price_Tier__c,Wholsale_Price__c  FROM  Promotion_Title_Detail__c WHERE Promotion__c = :promotionId];
if(!lstPTDDatabaseRecs.isEmpty())
{
for(Promotion_Title_Detail__c ptdRec : lstPTDDatabaseRecs)
{
mapPTDRecs.put(ptdRec.PTDKey__c, new WB_CommitPromotionController.TempPTDRecWrapper(ptdRec));
}

for(Promotion_Title_Detail__c ptdRec : lstUpsertPTD)
{
if(mapPTDRecs.containsKey(ptdRec.PTDKey__c))
{
ptdRec.id = mapPTDRecs.get(ptdRec.PTDKey__c).ptdRec.Id;
if(ptdRec.Price_Tier__c != null && ptdRec.Price_Tier__c != '')
{
ptdRec.Wholsale_Price__c  = null;
}
else if(ptdRec.Wholsale_Price__c != null)
{
ptdRec.Price_Tier__c = null;
}
else
{
ptdRec.Price_Tier__c = null;
ptdRec.Wholsale_Price__c  = null;
}

mapPTDRecs.get(ptdRec.PTDKey__c).isDelete = false;
lstPTDUpsertRecs.add(ptdRec);
}
else
{
lstPTDUpsertRecs.add(ptdRec);
}
}

System.debug('lstPTDUpsertRecs==='+lstPTDUpsertRecs);

for(WB_CommitPromotionController.TempPTDRecWrapper tempWrapRec : mapPTDRecs.values())
{
if(tempWrapRec.isDelete == true)
{
lstPTDDeleteRecs.add(tempWrapRec.ptdRec);
}
}

System.debug('lstPTDDeleteRecs==='+lstPTDDeleteRecs);

if(!lstPTDDeleteRecs.isEmpty())
{
Database.delete(lstPTDDeleteRecs);
}
}
else
{
lstPTDUpsertRecs.addAll(lstUpsertPTD);
}
if(!lstPTDUpsertRecs.isEmpty())
{
Database.upsert(lstPTDUpsertRecs);*/
        Promotion__c promoRec = [SELECT Id,Status__c,Last_Validated__c FROM Promotion__c WHERE Id = :promotionId];
        if(promoRec.Status__c == 'Draft')
        {
            promoRec.Status__c = 'In Progress';
        }
        promoRec.Last_Validated__c = System.now();
        UPDATE promoRec;
        //}
        
        //return lstPTDUpsertRecs;
        return true;
    }
    
    //Wrapper for PTD
    global class PromotionTitleDetailWrapper{
        public String ptName;
        public String status;
        public String channel;
        public String format;
        public String accountName;
        public String country;
        Public String comments;
        public String titleName;
        public String EpisodePriceTier;
        public String PriceTier;
        public String ClientAvail;
        public String ContentType;
        Public String Language; 
        public String Promotion;
        public String PromotionTitle;
        public String WSP;
        public String ClientAvailName;
        public String LanguageName;
        public String PromotionName;
        public String PromotionTitleName;
    }
    
    //Wrapper for fetchPTD method Country/Account/SF/VV/List of PTD
    global class MapWrapper 
    {
        global Map<String, Country__c> mapNameCountry = new Map<String, Country__c>();
        global Map<String, Account> mapNameAccount = new Map<String, Account>();
        global Map<String, Agreement__c> mapNameSF = new Map<String, Agreement__c>();
        global Set<Id> ptIDs = new Set<Id>();
        global List<String> upsertedKeys = new List<String>();
        
        global MapWrapper(Map<String, Country__c> mapNameCountry,Map<String, Account> mapNameAccount,Map<String, Agreement__c> mapNameSF,
                          Set<ID> ptIDs,List<String> upsertedKeys)
        {
            this.mapNameCountry = mapNameCountry;
            this.mapNameAccount = mapNameAccount;
            this.mapNameSF = mapNameSF;
            this.ptIDs = ptIDs;
            this.upsertedKeys = upsertedKeys;
        }
    }
}