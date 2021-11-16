public class CABatchProcess implements Database.Batchable<sObject>,Database.Stateful{
   public String Query;   
   public list<string> lstCommercialIds;
   public list<account> selected_accountslist;
   public string selectedstatus;
   //added by shalini for ER-323
   public String selectedChangeContext;
   public string myWizardLastRunId;
   public list<Client_Avail_Exception__c> clientAvailException_list = new list<Client_Avail_Exception__c>();
   public integer countExcpetionRec;
   list<Client_Avail__c> finalclientavail_lst = new list<Client_Avail__c>();
   public list<User> userDetail = new list<User>();
   public Client_Avail__c obj {get; set;}
   //global Boolean isForcebatch;
   public Date newCAStartdate;
   public Map<String,WB_CreateClientAvail_Controller.pricingWrapper> selectedPricingMapwrap;
   public Map<String,WB_CreateClientAvail_Controller.localDataWrapper> selectedlocalDataMapWrap;
   public WB_CreateClientAvail_Controller wb = new WB_CreateClientAvail_Controller();
   public Map<String,Local_Title__c> localDataUpdateMap = new Map<String,Local_Title__c>();
   public Map<String,WB_RateCardHelper.PriceKeyWrapper> caPriceWrapperMap = new Map<String,WB_RateCardHelper.PriceKeyWrapper>();
   //ER-003060 - Storefront Language Preferences changes - Start
   public List<Language_Preference__c> languagePrefSet = new List<Language_Preference__c>();
   public Map<String,String> countryLangPrefLevelMap = new Map<String,String>();
   public Map<String,Map<String,Set<Language_Preference__c>>> sfLangLangPrefMap = new Map<String,Map<String,Set<Language_Preference__c>>>();
   public Map<String,Map<String,Set<String>>> sfLangPrefLangMap = new Map<String,Map<String,Set<String>>>();
   public Set<String> titleIdSet = new Set<String>(); 
   public List<Available_Languages__c> availableLangSet = new List<Available_Languages__c>();
   public Map<String,Map<String,Map<String,String>>> titleCountryAvlLangLevelMap = new Map<String,Map<String,Map<String,String>>>();
    
   //ER-003060 - Storefront Language Preferences changes - End
   
   public CABatchProcess(Map<String,WB_CreateClientAvail_Controller.pricingWrapper> pw){
     
   }
   
   public CABatchProcess(list<string> commercialIds, list<account> accList,Client_Avail__c ca,string lastRunId, Map<String,WB_CreateClientAvail_Controller.pricingWrapper> pw, Map<String,WB_CreateClientAvail_Controller.localDataWrapper> ldw){
     
       lstCommercialIds = commercialIds;
       selected_accountslist = accList;
       obj = ca;
       selectedPricingMapwrap = pw;
       selectedlocalDataMapWrap = ldw;
       myWizardLastRunId=lastRunId;
       userDetail =[  SELECT id,Name,ProfileId,Profile.Name,UserType,Territory__c,CA_Batch_Id__c,Email   from User where id =: Userinfo.getUserId() ];                                                  
        countExcpetionRec = 0;
   }
   
   public CABatchProcess ( list<string> commercialIds, list<account> accList,string status,string changeContext,string lastRunId,Date newOverrideDate){
        
             lstCommercialIds = commercialIds;
             selected_accountslist = accList;
             selectedstatus=status;
             newCAStartdate = newOverrideDate;
             //added by shalini for ER-323
             selectedChangeContext= changeContext;
             myWizardLastRunId=lastRunId;
             userDetail =[  SELECT id,Name,ProfileId,Profile.Name,UserType,Territory__c,CA_Batch_Id__c,Email   from User where id =: Userinfo.getUserId() ];                                                  
             countExcpetionRec = 0;
    }

   public Database.QueryLocator start(Database.BatchableContext BC){
       //added Local_Title__r.Local_Category__c in below query for ER-356 by shalini
       Query = ' SELECT  id, name,Format__c,Channel__c,Country_Lookup__c,Country_Lookup__r.Name,Country_Lookup__r.Generate_CRM_Product__c,Languages__c,Languages__r.Name,Language_Type__c,Country_Group__c,Title__c,Start_Date__c,End_Date__c,Status__c,Title__r.Content_Type__c,Title__r.Name,Local_Title__c,Local_Title__r.Price_Code__c,Local_Title__r.Category__c,Title__r.Territory__c,Local_Title__r.Local_Category__c,Title__r.Video_Version__c,Local_Title__r.LocalDisplayStudio__c from commercial_avail__c where Id IN :lstCommercialIds';
      return Database.getQueryLocator(Query);
   }

   public void execute(Database.BatchableContext BC, List<commercial_avail__c> scope){       
        set<string> TitleContentType = new set<string>();
        set<string> commercialCountry= new set<string>();
        set<string> releaseLocalPriceCod = new set<string>(); 
        set<string> releasePlanChannel = new set<string>();
        set<string> releasePlanFormat = new set<string>();
        list<Agreement__c> selectedStorefronts = new list<Agreement__c>();
        list<Pricing__c> listPricingTable =new list<Pricing__c>();
        list<Pricing__c> newPriceCodeList =new list<Pricing__c>();
        list<Client_Avail__c> clientavail_lst = new list<Client_Avail__c>();
         map<id,set<string>> mapStorefrontChannels = new  map<id,set<string>>();//Map for distinguish which channel is for which storefront
         map<id,set<string>> mapstorefrontFormats = new  map<id,set<string>>();
         map<id,set<string>> mapstorefrontContentTypes = new  map<id,set<string>>();
         WB_CreateClientAvail_Controller wb = new WB_CreateClientAvail_Controller();
         
         list<WB_CreateClientAvail_Controller.releaseplanwrapper2> notMatchedCommercialWrap_list2 = new list<WB_CreateClientAvail_Controller.releaseplanwrapper2>(); 
         set<string> commercialAvailIds = new set<string>();  
         finalclientavail_lst = new list<Client_Avail__c>();
         
       for(commercial_avail__c selCommAvails : scope){          
            TitleContentType.add(selCommAvails .Title__r.Content_Type__c);
            commercialCountry.add(selCommAvails .Country_Lookup__c);
            releaseLocalPriceCod.add(selCommAvails .Local_Title__r.Price_Code__c);
            releasePlanChannel.add(selCommAvails .Channel__c);
            releasePlanFormat.add(selCommAvails.Format__c); 
          
      } 
      
      Set<String> newPriceCodeSet = new Set<String>();
      Set<String> localDataCategorySet = new Set<String>();
      for(WB_CreateClientAvail_Controller.localDataWrapper ldVal : selectedlocalDataMapWrap.values()){
        if(ldVal.newPriceCode != Null && ldVal.newPriceCode != ''){
          newPriceCodeSet.add(ldVal.newPriceCode);
        }else{
          newPriceCodeSet.add(ldVal.releaseplan.Local_Title__r.Price_Code__c);
        }
        if(ldVal.ca.Local_Data_Category_Picklist__c != Null && ldVal.ca.Local_Data_Category_Picklist__c != ''){
          localDataCategorySet.add(ldVal.ca.Local_Data_Category_Picklist__c);
        }
      }
        
      selectedStorefronts = [SELECT Id,Name,Account__c,Status__c,Account__r.Name,Pricing_Currency__c,Country__c,Channel_Picklist__c,Format__c,Content_Type__c,Selected_Combination__c,CRM_Storefront__c,HBO_SAP_Customer__c,Turner_SAP_Customer__c,SAP_Customer_Number__c,
                            (SELECT Id, Country__c, Language__c, Level__c, Type__c,Language__r.Name,Account__c FROM Language_Preferences__r WHERE Type__c =: Label.WB_Language_Preference_Type_Storefront) //ER-003060 - Storefront Language Preferences changes - inner Query added
                            FROM Agreement__c WHERE Account__c IN:selected_accountslist AND Country__c IN:commercialCountry];
      
      //added Local_Title__r.Local_Category__c in below query for ER-356 by shalini
      list<client_avail__c> DateList=[select id,Name,client__r.name,Commercial_Avail__r.Name,End_Date__c,Start_Date__c,Commercial_Avail__r.Start_Date__c,Commercial_Avail__r.End_Date__c,Release_Plan_Channel__c,
                                        Release_Plan_Format__c,Release_Plan_Language__c,Release_Plan_Country__c,Release_Plan_Title__c,Local_Title__r.Local_Category__c,Client__c,Storefront__c,Client_Start_Ovver__c from client_avail__c where 
                                        Commercial_Avail__c IN:lstCommercialIds AND Client__c IN :selected_accountslist];
      
                                       
      newPriceCodeList = [SELECT id,Name,Account__c,Channel__c,Content_Type__c,Country__c,Effective_Date__c,Episode_Price__c,Episode_Price_Tier__c,Format__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,WS_Price__c
                        from Pricing__c where  Name IN:newPriceCodeSet AND Price_Code_Status__c =:'Active'];  
      //and Content_Type__c IN:TitleContentType Account__c IN: selected_accountslist and Country__c IN: commercialCountry and and Channel__c IN:releasePlanChannel and Format__c IN:releasePlanFormat AND 
      
      //ER-003060 - Storefront Language Preferences changes - Start
      availableLangSet = [SELECT Id,Name,Language__c,Title__c FROM Available_Languages__c WHERE Title__c IN : titleIdSet];
      languagePrefSet = [SELECT Id,Name,Level__c,Country__c,Language__c,Type__c FROM Language_Preference__c WHERE Country__c IN :commercialCountry AND Type__c =: Label.WB_Language_Preference_Type_Country];

      if((availableLangSet != Null && availableLangSet.size()>0) && languagePrefSet != Null && languagePrefSet.size()>0 ){
        for(Available_Languages__c avlLangRec : availableLangSet){
            for(Language_Preference__c langPrefRec : languagePrefSet){
                if(avlLangRec.Language__c == langPrefRec.Language__c){
                    if(!titleCountryAvlLangLevelMap.containsKey(avlLangRec.Title__c)){
                        titleCountryAvlLangLevelMap.put(avlLangRec.Title__c,new Map<String,Map<String,String>>());
                    }

                    if(!titleCountryAvlLangLevelMap.get(avlLangRec.Title__c).containsKey(langPrefRec.Country__c)){
                        titleCountryAvlLangLevelMap.get(avlLangRec.Title__c).put(langPrefRec.Country__c,new Map<String,String>());
                    }
                    if(!titleCountryAvlLangLevelMap.get(avlLangRec.Title__c).get(langPrefRec.Country__c).containsKey(avlLangRec.Language__c)){
                        titleCountryAvlLangLevelMap.get(avlLangRec.Title__c).get(langPrefRec.Country__c).put(avlLangRec.Language__c,langPrefRec.Level__c);
                    }
                }
            }
        }
    }

      for(Language_Preference__c langPrefRec : languagePrefSet){

        String key = langPrefRec.Country__c+'_'+langPrefRec.Language__c;
        countryLangPrefLevelMap.put(key,langPrefRec.Level__c);
      }
      //ER-003060 - Storefront Language Preferences changes - End

      for(Agreement__c strfrnt : selectedStorefronts ){
        
        set<string> storefrontChannels = new set<string>();//intialize here otherwise it will have old channel valuw for previous storefront
        list<string> storefrontChannels2 = new list<string>();//For Split
        set<string> storefrontFormats = new set<string>();
        list<string> storefrontFormats2 = new list<string>();
        set<string> storefrontContentTypes = new set<string>();
        list<string> storefrontContentTypes2 = new list<string>();
        
        if(strfrnt.Channel_Picklist__c!=null){
            storefrontChannels2=strfrnt.Channel_Picklist__c.toLowerCase().split(';');         
            storefrontChannels.addAll(storefrontChannels2);
            mapStorefrontChannels.put(strfrnt.Id,storefrontChannels);
        }
        if(strfrnt.Format__c!=null){
            storefrontFormats2=strfrnt.Format__c.toLowerCase().split(';');
            storefrontFormats.addAll(storefrontFormats2);
            mapstorefrontFormats.put(strfrnt.Id,storefrontFormats);
        }
        if(strfrnt.Content_Type__c!=null){
           
            storefrontContentTypes2=strfrnt.Content_Type__c.toLowerCase().split(';');
            storefrontContentTypes.addAll(storefrontContentTypes2);
            mapstorefrontContentTypes.put(strfrnt.Id,storefrontContentTypes);
        }

        //ER-003060 - Storefront Language Preferences changes - Start
                 if(strfrnt.Language_Preferences__r != Null && strfrnt.Language_Preferences__r.size()>0){
                     Integer i=0;
                     Set<String> higherLangSet = new Set<String>();
                     Language_Preference__c prevLangPrefRecord = new Language_Preference__c();
                     String prevLanguageId = '';
                    for(Language_Preference__c langRec : strfrnt.Language_Preferences__r){
                        
                       /* if(!sfLangLangPrefMap.containsKey(strfrnt.Id)){
                            sfLangLangPrefMap.put(strfrnt.Id,new Map<String,Set<Language_Preference__c>>());
                        }
                        if(!sfLangLangPrefMap.get(strfrnt.Id).containsKey(langRec.Language__c)){
                            sfLangLangPrefMap.get(strfrnt.Id).put(langRec.Language__c,new Set<Language_Preference__c>());
                        }
                        if(!sfLangLangPrefMap.get(strfrnt.Id).get(langRec.Language__c).contains(langRec)){
                            sfLangLangPrefMap.get(strfrnt.Id).get(langRec.Language__c).add(langRec);
                        }*/

                        //Map - StorefrontId - Language - Set of Higher Language

                        if(!sfLangPrefLangMap.containsKey(strfrnt.Id)){
                            sfLangPrefLangMap.put(strfrnt.Id,new Map<String,Set<String>>());
                        }
                        if(!sfLangPrefLangMap.get(strfrnt.Id).containsKey(langRec.Language__c)){
                            sfLangPrefLangMap.get(strfrnt.Id).put(langRec.Language__c,new Set<String>());
                        }
                        if(i != 0 && (higherLangSet != Null && higherLangSet.size()>0) && (prevLangPrefRecord.Level__c < langRec.Level__c)){
                            sfLangPrefLangMap.get(strfrnt.Id).get(langRec.Language__c).addAll(higherLangSet);
                        }
                        higherLangSet.add(langRec.Language__c);
                        prevLangPrefRecord = langRec;
                        i++;
                    }
                    
                }  //ER-003060 - Storefront Language Preferences changes - End
        
    } // storefront map ended
    Map<String,Map<String,Set<String>>> mapErrorRPAccount = new Map<String,Map<String,Set<String>>>();
    //ER-003060 - Storefront Language Preferences changes 
    Map<String,Map<String,Map<String,Set<String>>>> mapErrorRPSFLangPref = new Map<String,Map<String,Map<String,Set<String>>>>();

    for(Commercial_Avail__c vCommercialAvails : scope){
        for(account acc:selected_accountslist){
            integer countStorefronts=0;
            for(Agreement__c selectStrfront : selectedStorefronts ){ 
                if(vCommercialAvails.Country_Lookup__c == selectStrfront.Country__c && acc.id==selectStrfront.Account__c){
                    countStorefronts++;
                    if(selectStrfront.Status__c == 'Active'){
                    if( mapStorefrontChannels.size() != 0 && mapstorefrontFormats.size()!= 0 && mapstorefrontContentTypes.size()!= 0){
                        if(mapStorefrontChannels.get(selectStrfront.Id)!= Null && mapstorefrontFormats.get(selectStrfront.Id)!=Null && mapstorefrontContentTypes.get(selectStrfront.Id)!= Null && vCommercialAvails.Channel__c!=null && vCommercialAvails.Format__c!=null && vCommercialAvails.Title__r.Content_Type__c!=null){ 
                            if(mapStorefrontChannels.get(selectStrfront.Id).contains(vCommercialAvails.Channel__c.toLowerCase()) && mapstorefrontFormats.get(selectStrfront.Id).contains(vCommercialAvails.Format__c.toLowerCase())
                            && mapstorefrontContentTypes.get(selectStrfront.Id).contains(vCommercialAvails.Title__r.Content_Type__c.toLowerCase())){
                               
                                integer countOverlap=0;
                                
                                Boolean isContractProviderNotEnabled = WB_PriceUtility.checkContractProvider(vCommercialAvails,selectStrfront,mapErrorRPAccount,acc,countExcpetionRec,notMatchedCommercialWrap_list2);
                                if(isContractProviderNotEnabled)
                                    break;
                                for(client_avail__c CAOverlapRec :DateList) {
                                  
                                    if(vCommercialAvails.id== CAOverlapRec.commercial_avail__c && acc.Id== CAOverlapRec.client__c){                                     
                                      if(vCommercialAvails.id == CAOverlapRec.commercial_avail__c && acc.Id == CAOverlapRec.client__c){
                                          Boolean isOverlap = WB_CreateClientAvail_Controller.checkOverlapping(obj.Client_Start_Ovver__c,obj.End_Date__c,vCommercialAvails.Start_Date__c,vCommercialAvails.End_Date__c,CAOverlapRec.Start_Date__c,CAOverlapRec.End_Date__c);
                                            if(isOverlap == True){
                                                countOverlap++; 
                                            }
                                        } 
                                       
                                    }
                                 
                                }
                                //ER-003060 - Storefront Language Preferences changes - Start
                                if(selectStrfront.Language_Preferences__r != Null && selectStrfront.Language_Preferences__r.size()>0){
                                 
                                   Boolean isSFLangPref = WB_CreateClientAvail_Controller.checkStorefrontLangPreference(vCommercialAvails,selectStrfront,mapErrorRPSFLangPref,sfLangPrefLangMap,titleCountryAvlLangLevelMap,countExcpetionRec,notMatchedCommercialWrap_list2,acc,Null);
                                     if(isSFLangPref)
                                       break;
                                }
                                //ER-003060 - Storefront Language Preferences changes - End

                                if(countOverlap>0){
                                    countExcpetionRec++;
                                    WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                                    string str =  vCommercialAvails.Id+string.valueof(countExcpetionRec); 
                                    String errorMessage =  'Client avail is present with selected dates';
                                    WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,Null);
                                    real.accountName = selectStrfront.Account__r.Name;
                                    notMatchedCommercialWrap_list2.add(real);
                                }else{
                                    Client_avail__c ClientAvail = new client_avail__c();
                                    String localDatakey = vCommercialAvails.Title__r.Video_Version__c+vCommercialAvails.Country_Lookup__r.Name+vCommercialAvails.Languages__r.Name;
                                    String pricingkey = vCommercialAvails.Channel__c+vCommercialAvails.Format__c;
                                    Boolean isPricingAssigned = false;
                                    Boolean isWSPAssigned = false;
                                    if(selectedPricingMapwrap != Null && selectedPricingMapwrap.size()>0){
                                      Decimal wspInputVAl;
                                        Decimal episodeWspInputVAl;
                                        //SINC1977266 : Assiging Batch Id field value 
                                        ClientAvail.Batch_Id__c=myWizardLastRunId;
                                        WB_CreateClientAvail_Controller.assignCAValues(vCommercialAvails,ClientAvail,Null,selectStrfront,obj,selectedlocalDataMapWrap);
                                          if(selectedPricingMapwrap.containsKey(pricingkey) && selectedPricingMapwrap.get(pricingkey) != Null){
                                              if(selectedPricingMapwrap.get(pricingkey).wsp != Null && selectedPricingMapwrap.get(pricingkey).wsp != ''){
                                                  isWSPAssigned = true;
                                                    wspInputVAl = Decimal.valueOf(selectedPricingMapwrap.get(pricingkey).wsp);
                                                    ClientAvail.Price__c = wspInputVAl;
                                                }
                                                if(selectedPricingMapwrap.get(pricingkey).episodeWSP != Null && selectedPricingMapwrap.get(pricingkey).episodeWSP != ''){
                                                  episodeWspInputVAl = Decimal.valueOf(selectedPricingMapwrap.get(pricingkey).episodeWSP);
                                                    ClientAvail.Episode_Price__c = episodeWspInputVAl;
                                                }
                                                ClientAvail.Price_Tier_Text__c = '';
                                                ClientAvail.status__c = obj.status__c;
                                            }
                                    }
                                    
                                    //Advanced Pricing ER-002254 new Price Code changes
                                    if((newPriceCodeList != Null && newPriceCodeList.size()>0) || (localDataCategorySet != Null && localDataCategorySet.size()>0)){
                                        Integer priceCodeCounter=0;
                                        Local_Title__c localDataObj = new Local_Title__c(); 
                                        Boolean isPriceCodeChange = false;
                                        Boolean isCategoryOverrideChange = false;
                                        String newPriceCode_Value;
                                        String assignPriceCode;
                                        if(selectedlocalDataMapWrap.containsKey(localDatakey)){
                                        localDataObj.Id = vCommercialAvails.Local_Title__c;
                                        if(selectedlocalDataMapWrap.get(localDatakey).newPriceCode != Null && selectedlocalDataMapWrap.get(localDatakey).newPriceCode != ''){
                                            localDataObj.Price_Code__c = selectedlocalDataMapWrap.get(localDatakey).newPriceCode;
                                            isPriceCodeChange = true;
                                            newPriceCode_Value = selectedlocalDataMapWrap.get(localDatakey).newPriceCode;
                                            if(newPriceCode_Value != Null && newPriceCode_Value !=''){
                                                                        ClientAvail.New_Price_Code__c = newPriceCode_Value;
                                                                    }
                                        }
                                        if(selectedlocalDataMapWrap.get(localDatakey).ca.Local_Data_Category_Picklist__c != Null && selectedlocalDataMapWrap.get(localDatakey).ca.Local_Data_Category_Picklist__c != ''){
                                            localDataObj.Category__c = selectedlocalDataMapWrap.get(localDatakey).ca.Local_Data_Category_Picklist__c;
                                            isCategoryOverrideChange = true;
                                        }
                                        if(isPriceCodeChange || isCategoryOverrideChange){
                                            if(localDataUpdateMap != Null){
                                            localDataUpdateMap.put(localDataObj.Id,localDataObj);
                                            }
                                        }
                                        }
                                        if(!isWSPAssigned){
                                        if(newPriceCode_Value != Null && newPriceCode_Value !=''){
                                            assignPriceCode = newPriceCode_Value;
                                        }else{
                                            assignPriceCode = vCommercialAvails.Local_Title__r.Price_Code__c;
                                        }
                                        for(Pricing__c pricingRec : newPriceCodeList){
                                            if(pricingRec.Content_Type__c == vCommercialAvails.Title__r.Content_Type__c && pricingRec.Country__c== vCommercialAvails.Country_Lookup__c &&
                                            pricingRec.Account__c == selectStrfront.Account__c && pricingRec.Name == assignPriceCode 
                                            && pricingRec.Format__c== vCommercialAvails.Format__c && pricingRec.Channel__c== vCommercialAvails.Channel__c){
                                            WB_CreateClientAvail_Controller.assignCAValues(vCommercialAvails,ClientAvail,pricingRec,selectStrfront,obj,selectedlocalDataMapWrap);
                                            priceCodeCounter++;
                                            isPricingAssigned = true;
                                            if(vCommercialAvails.Title__r.Content_Type__c == 'SEASON'){
                                                Pricing__c episodePricingRec = WB_CreateClientAvail_Controller.fetchEpisodePricing(pricingRec,newPriceCodeList);
                                                                            ClientAvail.Episode_Price__c = Null;
                                                ClientAvail.Episode_Price_Tier__c = Null;
                                                if(episodePricingRec != Null){
                                                                                ClientAvail.Episode_Pricing__c = episodePricingRec.Id;
                                                                                ClientAvail.Episode_Price__c = episodePricingRec.WS_Price__c;
                                                                                ClientAvail.Episode_Price_Tier__c = episodePricingRec.Price_Tier__c;
                                                                            }else{
                                                                                ClientAvail.Episode_Price_Tier__c = 'TBD';
                                                                            }
                                                                        }
                                            }
                                        }
                                        if(priceCodeCounter==0){
                                            WB_CreateClientAvail_Controller.assignCAValues(vCommercialAvails,ClientAvail,Null,selectStrfront,obj,selectedlocalDataMapWrap);
                                            isPricingAssigned = true;
                                        }
                                        }
                                    }
                                    else if(!(isWSPAssigned || isPricingAssigned )){
                                      WB_CreateClientAvail_Controller.assignCAValues(vCommercialAvails,ClientAvail,Null,selectStrfront,obj,selectedlocalDataMapWrap);  
                                    }
                                    //added by Tejasvini Mar Release 2018
                                    Boolean errorValue;
                                    errorValue = WB_PriceUtility.availableCombination(vCommercialAvails,selectStrfront);
                                    if(errorValue){
                                        countExcpetionRec++;
                                        WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                                        string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                                        String errorMessage =  'Storefront doesnot contain the channel,format or content type';
                                        WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc); 
                                        notMatchedCommercialWrap_list2.add(real);
                                            //sfMisMatchCAList.add(ClientAvail);
                                    }else{
                                        Boolean isCRMCountry = false;
                                        if(selectStrfront.CRM_Storefront__c){
                                            isCRMCountry = true;
                                        }
                                        clientavail_lst.add(ClientAvail);
                                        if(isCRMCountry){
                                            caPriceWrapperMap.putAll(WB_CreateClientAvail_Controller.getCAPriceWrapperMap(vCommercialAvails,ClientAvail));
                                        }
                                          
                                    }
                                }
                            }
                            else{
                              countExcpetionRec++;
                                WB_CreateClientAvail_Controller.releaseplanwrapper2 real = new WB_CreateClientAvail_Controller.releaseplanwrapper2();
                                string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                                String errorMessage =  'Storefront doesnot contain the channel,format or content type';
                                WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc); 
                                notMatchedCommercialWrap_list2.add(real);
                            }
                        }
                        else{
                          countExcpetionRec++;
                            WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                            string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);  
                            String errorMessage =  'Storefront doesnot contain the channel,format or content type';
                            WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);   
                            notMatchedCommercialWrap_list2.add(real);
                        }
                    }
                }else{
                        countExcpetionRec++;
                        WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                        string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);  
                        String errorMessage =  'Storefront status is Inactive';
                        WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);   
                        notMatchedCommercialWrap_list2.add(real);
                        
                    }
                    }
                }
                if(countStorefronts==0){
                    countExcpetionRec++;
                    WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                    string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                    String errorMessage =  'Storefront is not present';
                    WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);
                    notMatchedCommercialWrap_list2.add(real);
                }
    
        }
        commercialAvailIds.add(vCommercialAvails.Id);
    }  
        
        finalclientavail_lst.addAll(clientavail_lst);
        //set return to window flag
        WB_PriceUtility.setReturnToWindowFlag(scope,finalclientavail_lst);
       
        for(WB_CreateClientAvail_Controller.releaseplanwrapper2 relwrap :notMatchedCommercialWrap_list2){
            Client_Avail_Exception__c clientExcep = new Client_Avail_Exception__c();
            clientExcep.Name = relwrap.uniqueName;
            clientExcep.Account__c = relwrap.accountName;
            clientExcep.User_Detail__c = userDetail[0].Id;                       
            clientExcep.Release_Plan_Number__c = relwrap.releaseplan.Name;
            clientExcep.Title__c = relwrap.releaseplan.Title__r.Name;
            clientExcep.Content_Type__c = relwrap.releaseplan.Title__r.Content_Type__c;
            clientExcep.Country__c = relwrap.releaseplan.Country_Lookup__r.Name;
            clientExcep.Language__c = relwrap.releaseplan.Languages__r.Name;
            clientExcep.Language_Type__c = relwrap.releaseplan.Language_Type__c;
            clientExcep.Channel__c = relwrap.releaseplan.channel__c;
            clientExcep.Format__c = relwrap.releaseplan.format__c;
            clientExcep.Avail_Start__c = relwrap.releaseplan.Start_Date__c;
            clientExcep.Avail_End__c = relwrap.releaseplan.End_Date__c;
            clientExcep.Status__c = relwrap.releaseplan.Status__c;
            clientExcep.Reason__c = relwrap.reasonMsg;
            clientAvailException_list.Add(clientExcep);
         
        } 
     
      try {
        
        if(localDataUpdateMap != Null && localDataUpdateMap.size()>0){
          Database.Saveresult[] saveResult_LocalData  = Database.update(localDataUpdateMap.values(), false);
        }
        WB_LocalTitleTriggerHandler.recursiveUpdate = true;
        
        Map<String,List<Rate_Card__c>> rateCardMap = new Map<String,List<Rate_Card__c>>();
        if(caPriceWrapperMap != Null && caPriceWrapperMap.size()>0){
          rateCardMap = WB_RateCardHelper.getRateCard(caPriceWrapperMap.values(),false,false);
        //    if(rateCardMap != Null && rateCardMap.size()>0){
                if(WB_CreateClientAvail_Controller.keyCAMap != Null && WB_CreateClientAvail_Controller.keyCAMap.size()>0){
                 for(String key : WB_CreateClientAvail_Controller.keyCAMap.keySet()){
                for(Client_Avail__c ca : WB_CreateClientAvail_Controller.keyCAMap.get(key)){
                 //ER-003373  Episode SR Price Field on CA-->   ca.SR_Per_Episode__c = Null;
                      ca.Pricing__c = Null;
                      ca.Episode_Pricing__c = Null;
                      Boolean rcFound=false;
                      Boolean rcEpFound=false;
                      if(key.contains('EPISODE')){
                        rcFound = true;
                      }else{
                        rcEpFound = true;
                      }
                      if(rateCardMap != null && rateCardMap.containsKey(key) && rateCardMap.get(key) != Null){
                           for(Rate_Card__c caRC : rateCardMap.get(key)){
                               if(ca.Start_Date__c >= caRC.Start_Date__c && ca.Start_Date__c <= caRC.End_Date__c){
                                   if(key.contains('EPISODE')){
                                            ca.Episode_Rate_Card__c = caRC.Id;
                                            rcEpFound = true;
                                            break;
                                    }
                                   ca.CA_Rate_Card__c = caRC.Id;
                                   /*ER-003373-->     ca.SR_Price__c = caRC.SRP__c; */
                                   rcFound = true;
                                   break;
                               }
                           }
                     }
                      
                      if((!rcFound && ca.Price__c == Null) || (!rcEpFound && ca.Episode_Price__c == Null)){
                          if(!rcFound && ca.Price__c == Null){
                                    ca.Price_Tier_Text__c = 'TBD';
                                     /*ER-003373-->      ca.SR_Price__c= Null; */
                                }
                                if(!rcEpFound && ca.Episode_Price__c == Null){
                                    ca.Episode_Price_Tier__c = 'TBD';
                                }
                                if(ca.status__c == 'Confirmed' ){
                                    ca.status__c = 'Tentative'; 
                                }
                            }
                     }
              }
               }
        //    }
        }
        
        if(finalclientavail_lst != null && finalclientavail_lst.size() > 0) {               
            
            Database.Saveresult[] saveResult  = Database.insert(finalclientavail_lst, false);
                      
        }
        
      }catch(Exception e){
        System.debug('The following exception has occurred: ' + e.getMessage());
      }
      try{
        if(clientAvailException_list.size()!=0){
            Database.Saveresult[] saveExceptionResult  = Database.insert(clientAvailException_list, false);
       
        }
      }catch(Exception e){
            System.debug('The following exception has occurred in exception list insertion: ' + e.getMessage());        
      }
   }

   public void finish(Database.BatchableContext BC){
    
    integer totalExpectedCA = lstCommercialIds.size()*selected_accountslist.size();  
    integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];   
    if(clientExceptionCount > 0){
        //List<Client_Avail_Exception__c> existing = [SELECT Id From Client_Avail_Exception__c where User_Detail__c =:userDetail[0].Id];
        //delete existing;
        //system.debug('existing  ' + existing);
    }
  
    string header = 'Release Plan Number, Title , Account, Content Type, Country, Language, Language Type, Channel, Format, Client Start, Client End, Status, Reason  \n';
    string finalstr = header ;
    for(Client_Avail_Exception__c caExceptionOut_lst: clientAvailException_list)
    {
    
           //string recordString = '"'+caExceptionOut_lst.Release_Plan_Number__c+'","'+caExceptionOut_lst.Title__c+'","'+caExceptionOut_lst.Account__c+'","'+caExceptionOut_lst.Content_Type__c +'"\n';
           string recordString = '"'+caExceptionOut_lst.Release_Plan_Number__c+'","'
                                    +caExceptionOut_lst.Title__c+'","'
                                     +caExceptionOut_lst.Account__c+'","'
                                     +caExceptionOut_lst.Content_Type__c+'","'
                                     +caExceptionOut_lst.Country__c+'","'
                                     +caExceptionOut_lst.Language__c+'","'
                                     +caExceptionOut_lst.Language_Type__c+'","'
                                     +caExceptionOut_lst.Channel__c+'","'
                                     +caExceptionOut_lst.Format__c+'","'
                                     +caExceptionOut_lst.Avail_Start__c+'","'
                                     +caExceptionOut_lst.Avail_End__c+'","'
                                     +caExceptionOut_lst.Status__c+'","'
                                     +caExceptionOut_lst.Reason__c+'","'
                                     +'"\n';
           finalstr = finalstr +recordString;
    }
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
    blob csvBlob = Blob.valueOf(finalstr);
    string csvname= 'CA.csv';
    csvAttc.setFileName(csvname);
    csvAttc.setBody(csvBlob);
    Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  
    TotalJobItems, CreatedBy.Email, ExtendedStatus  
    from AsyncApexJob where Id = :BC.getJobId()];  
    // Email the Batch Job's submitter that the Job is finished.
    String[] toAddresses = new String[] {a.CreatedBy.Email}; 

    String subject ='Client Avail Exception out CSV';
    email.setSubject(subject);
    email.setToAddresses( toAddresses );
    
    if(totalExpectedCA == finalclientavail_lst.size()){
        email.setPlainTextBody('If you’ve not run the Wizard since you initiated this run, you should be able to see records created by clicking on the link \n'+ System.Label.My_Latest_Wizard_Run + '\n If, however, you’ve created more records since you ran the wizard which initiated this batch process,those records won’t be available. You can see this batch’s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
    }
    else if(totalExpectedCA == clientAvailException_list.size()){      
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review.');
    }
    else{
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody('Those records which could not be created (exceptions) are included in an attachment to this message for the user to review. Few records are created successfully, you can see records by clicking on the link \n'+ System.Label.My_Latest_Wizard_Run + '\n If, however, you’ve created more records since you ran the wizard which initiated this batch process,those records won’t be available. You can see this batch’s records by filtering on batch id < ' + myWizardLastRunId + ' > in a Client Avail view');
    }
   
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    
   
   }
   
    
}