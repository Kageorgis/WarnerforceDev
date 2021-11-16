/******* 
Name:WB_CreateClientAvail_Controller
Creation Date- 5 May2014
Last Modified Date - 21 May 2014
Last Modified by  - Tejas
Description- Controller for the Bulk record creation of Client Avail from Commercial Avail view list
Author- Rashmi Singh
Last Modified Date - 29 Dec 2017
Last Modified by  - Purushottam
Description- As per part of CRRT Phase 2 requirement
*******/

public with sharing class WB_CreateClientAvail_Controller {
    
    integer countExcpetionRec=0;
    public integer count {get;set;}
    //public Client_Avail__c obj;
    public String theValue{ get;set;}
    public Boolean contentTypeValue{ get;set;}
    public Boolean confirmCAValue{get;set;}
    
    public string availids;
    public List<Commercial_Avail__c> commercial_avallst{set; get;}
    
    public List<List<Commercial_Avail__c>> commercial_avallst_new{set; get;}
    
    public List<Client_Avail__c> clientavail_lst{set; get;}
    public list<Client_Avail__c> finalclientavail_lst{set; get;}
    public integer selectedCommercialCount{get;set;}// For Scrolling bar
    public boolean commercialScroller{get;set;}// For Scrolling bar    
    public set<string> commercialAvailIds {get;set;}    
    public List<string> commercialAvailStatus {get;set;}
    
    public List<Account> all_accountslist {get;set;} //for Accounts display in list format 29thSep
    public List<accountwrapper> selectedAccountslistwrap{get; set;} // for selected Accounts display in list format 29thSep
    
    public List<Account> selected_accountslist {get;set;} //// for selected Accounts after being checked 29thSep   
    public list<string> TitleContentType = new list<string>();// added for checking Title content Type have season or not
    public set<string> commercialCountry= new set<string>();// for fetching list of countries from selected commercial
    public list<Agreement__c> selectedStorefronts{get;set;}//for fetching storefront list for selected Account
    public set<string> storefrontChannels= new set<string>();//for selectedStorefronts channels
    public set<string> storefrontFormats= new set<string>();//for selectedStorefronts Formats
    public set<string> storefrontContentTypes= new set<string>();//for selectedStorefronts contentTypes
    public map<id,set<string>> mapStorefrontChannels = new  map<id,set<string>>();//Map for distinguish which channel is for which storefront
    public map<id,set<string>> mapstorefrontFormats = new  map<id,set<string>>();
    public map<id,set<string>> mapstorefrontContentTypes = new  map<id,set<string>>();
    public list<string> selectedCommContry = new list<string>();//28thOct,for displaying selected accounts
    public list<Agreement__c> selectedCommStorefront = new list<Agreement__c>();//28thOct,for getting list of storefront whose country equal to release plan countries
    public list<string> selectedStoreAccntIds = new list<string>();//28thOct,for getting account ids from selected storefront records
    public list<User> userDetail = new list<User>();//28thOct, for release plan maitainer profile
    public list<Pricing__c> listPricingTable =new list<Pricing__c>();//2ndNov, for pricing table logic
    public set<string> listReleaseplanClientCreate = new set<string>();//4th nov, list of commercial avil whose client avail can be created
    public boolean flagReleaseMaintainer ;//14thNov, flag for ReleaseMaintainer error message change.
    public boolean flagReleaseMaintainerForRPStatus ;//16 jan
    public list<Client_Avail_Exception__c> clientAvailException_list{get; set;}
    //public Boolean isStartOverrideDate;
    
    public List<releaseplanwrapper2> notMatchedCommercialWrap_list2 {get;set;}
    // added on 12 Jan 2014
    set<string> releaseLocalPriceCod = new set<string>(); 
    set<string> releasePlanChannel = new set<string>();
    set<string> releasePlanFormat = new set<string>();
    public set<string> commAvailIdsList{get; set;}   
    public boolean forceBatchProcessChk{get;set;}
    public String msgA{get;set;}
    public String msgB{get;set;}
    
    public Client_Avail__c obj {get; set;} //Mahesh - Changed variable to Get;Set;
    public Client_Avail__c CA;
    public string str{get;set;} //Mahesh
    public String CAMessage{get;set;}
    public String[] sortedPricingName{get; set;} 
    public Boolean displayPopUp{get; set;}  
    public string selectPriceCode;
    public string selectedValue{get;set;}
    public string flag{get;set;}
    public list<Pricing__c> list_SelectedPricing{get; set;}
    public set<string> distinctPriceCodeSet {get; set;}
    public String paramValue{get;set;}
    public list<Pricing__c> newPriceCodeList =new list<Pricing__c>();
    public Map<String,pricingWrapper> selectedPricingMapwrap{get; set;}
    public Map<String,localDataWrapper> selectedlocalDataMapWrap{get; set;}
    public String errorPricingMsg{get; set;}
    public String priceCodekey{get;set;}
    public Map<String,List<SelectOption>> selectedPriceCode_Map{get;set;}
    public Map<String,Local_Title__c> localDataUpdateMap = new Map<String,Local_Title__c>();
    public Map<String,WB_RateCardHelper.PriceKeyWrapper> caPriceWrapperMap = new Map<String,WB_RateCardHelper.PriceKeyWrapper>();
    public static Map<String,String> keyRPMap = new Map<String,String>(); 
    public static Map<String,List<Client_Avail__c>> keyCAMap = new Map<String,List<Client_Avail__c>>();  
    
    //ER-003060 - Storefront Language Preferences changes - Start
    public List<Language_Preference__c> languagePrefSet = new List<Language_Preference__c>();
    public Map<String,String> countryLangPrefLevelMap = new Map<String,String>();
    public Map<String,Map<String,Set<Language_Preference__c>>> sfLangLangPrefMap = new Map<String,Map<String,Set<Language_Preference__c>>>();
    public Map<String,Map<String,Set<String>>> sfLangPrefLangMap = new Map<String,Map<String,Set<String>>>();
    public Set<String> titleIdSet = new Set<String>();
    public List<Available_Languages__c> availableLangSet = new List<Available_Languages__c>();
    public Map<String,Map<String,Map<String,String>>> titleCountryAvlLangLevelMap = new Map<String,Map<String,Map<String,String>>>();
    
    //ER-003060 - Storefront Language Preferences changes - End
    
    List<SelectOption> categories = new List<SelectOption>();
    
    public WB_CreateClientAvail_Controller(){
    populateCategories();
    }
    
    public WB_CreateClientAvail_Controller(ApexPages.StandardSetController controller) {
       populateCategories();
    }
    
    public class accountwrapper{
        
        public Account acc{get; set;}
        public Boolean selected {get;set;}
        
    }
    
    public class releaseplanwrapper2{
        public commercial_avail__c releaseplan{get; set;}
        public Agreement__c storefront{get; set;}
        public string reasonMsg{get;set;}
        public string uniqueName{get;set;}
        public string accountName{get; set;}
    }
    
    public class pricingWrapper{
      public String channel{get; set;}
      public String format{get; set;}
      public String wsp{ set; get;}
      public String episodeWSP{get; set;}
      public String errorMsg{get;set;}
      public String contentType{get;set;}
      public String localDataId{get;set;}
    }
    
    public class localDataWrapper{
      public commercial_avail__c releaseplan{get; set;}
      public String newPriceCode{get; set;}
      public String categoryOverrideVal{get; set;}
      public Client_Avail__c ca{get;set;}
      public String error{get; set;}
      public Boolean isManualCode{get;set;}
      public Boolean isPopupCode{get;set;}
      
      public localDataWrapper(){
        
      }
      public localDataWrapper(String err){
        this.error = err;
      }
    
    }
    
    // function for the checking the account selected value
    
    public Pagereference getSelected(){
        selected_accountslist.clear();
        
        selected_accountslist = new List<Account>();
        for(accountwrapper accwrapper : selectedAccountslistwrap){
            if(accwrapper.selected == true){
                selected_accountslist.add(accwrapper.acc);
            }
        }
        return null;
    }
    
    public list<Client_Avail__c> batchIdGeneration(list<Client_Avail__c> list_TobeUpdate){
        
        list<Batch_Ids_Customsetting__c> clientAvailBatchId_lst = [
            SELECT Id,Name,CA_Batch_Id__c,CA_Created_Date__c,CA_User_Detail__c 
            FROM Batch_Ids_Customsetting__c for update
        ];
        
        //list<string> spltBatch = clientAvailBatchId_lst[0].CA_Batch_Id__c.split('_');
        integer incremnt = integer.ValueOf(clientAvailBatchId_lst[0].CA_Batch_Id__c);
        incremnt++;
        string finalBatchId = String.valueOf(incremnt);
        
        clientAvailBatchId_lst[0].Name = userDetail[0].Id;
        clientAvailBatchId_lst[0].CA_Batch_Id__c = finalBatchId ;
        clientAvailBatchId_lst[0].CA_Created_Date__c = system.now();
        clientAvailBatchId_lst[0].CA_User_Detail__c = userDetail[0].Id;
        
        Database.Upsertresult[] saveBatchResult  = Database.upsert(clientAvailBatchId_lst, false);
        if(saveBatchResult[0].isSuccess()){
            userDetail[0].CA_Batch_Id__c = clientAvailBatchId_lst[0].CA_Batch_Id__c;
            update userDetail[0];
        }
        
        for(Client_Avail__c client :list_TobeUpdate){
            client.Batch_Id__c = clientAvailBatchId_lst[0].CA_Batch_Id__c;
        }
        return list_TobeUpdate ;
    }
    
    public string batchIdForApexBatch(){
        
        list<Batch_Ids_Customsetting__c> clientAvailBatchId_lst = [
            Select Id,Name,CA_Batch_Id__c,CA_Created_Date__c,CA_User_Detail__c
            from Batch_Ids_Customsetting__c for update
        ];
        
        //list<string> spltBatch = clientAvailBatchId_lst[0].CA_Batch_Id__c.split('_');
        integer incremnt = integer.ValueOf(clientAvailBatchId_lst[0].CA_Batch_Id__c);
        incremnt++;
        string finalBatchId = String.valueOf(incremnt);
        
        clientAvailBatchId_lst[0].Name = userDetail[0].Id;
        clientAvailBatchId_lst[0].CA_Batch_Id__c = finalBatchId ;
        clientAvailBatchId_lst[0].CA_Created_Date__c = system.now();
        clientAvailBatchId_lst[0].CA_User_Detail__c = userDetail[0].Id;
        
        Database.Upsertresult[] saveBatchResult  = Database.upsert(clientAvailBatchId_lst, false);
        if(saveBatchResult[0].isSuccess()){
            userDetail[0].CA_Batch_Id__c = clientAvailBatchId_lst[0].CA_Batch_Id__c;
            update userDetail[0];
        }
        return finalBatchId ;
    }
    
    
    /****** Method invoked on click of save button ******/ 
    
    public Pagereference bulksave(){
        GetSelected(); //updated on 3/24/2017  SINC0903890
        integer recordCount= selected_accountslist.size()*commAvailIdsList.size();
        notMatchedCommercialWrap_list2= new List<releaseplanwrapper2>();
        finalclientavail_lst = new List<Client_Avail__c>();
        clientavail_lst = new List<Client_Avail__c>();
        String selParam =theValue;   
        string selectedStatus=obj.status__c;
        
        //added by shalini for ER-323
        string selectedChangeContext = obj.Change_Context__c;
        //boolean selectedForceBatch = isStartOverrideDate;
        Date newOverrideDate = obj.Client_Start_Ovver__c;
        String newPriceCodeValue = obj.New_Price_Code__c;
        // Adding get selected
        //getSelected();
        
        Set<String> newPriceCodeSet = new Set<String>();
        Set<String> localDataCategorySet = new Set<String>();
        
        if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
            for(localDataWrapper ldVal : selectedlocalDataMapWrap.values()){
                if((ldVal.error != Null && ldVal.error != '') && ((ldVal.newPriceCode != Null && ldVal.newPriceCode != '') || (ldVal.ca.Local_Data_Category_Picklist__c != Null && ldVal.ca.Local_Data_Category_Picklist__c != ''))){
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter valid Data.'));
                  return Null;
                }
                if(ldVal.newPriceCode != Null && ldVal.newPriceCode != ''){
                    newPriceCodeSet.add(ldVal.newPriceCode);
                }else{
                  newPriceCodeSet.add(ldVal.releaseplan.Local_Title__r.Price_Code__c);
                }
                if(ldVal.ca.Local_Data_Category_Picklist__c != Null && ldVal.ca.Local_Data_Category_Picklist__c != ''){
                  localDataCategorySet.add(ldVal.ca.Local_Data_Category_Picklist__c);
                }
            }
        }
        
        
        if((selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0) && (selectedPricingMapwrap != Null && selectedPricingMapwrap.size()>0)){
          for(localDataWrapper ldVal : selectedlocalDataMapWrap.values()){
            for(pricingWrapper pc :selectedPricingMapwrap.values()){
              if((pc.errorMsg != Null && pc.errorMsg != '') && ((pc.wsp != Null && pc.wsp != '')||(pc.episodeWSP != Null && pc.episodeWSP != ''))){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter valid Data.'));
                  return Null;
              }
              
              if(ldVal.releaseplan.Local_Title__c == pc.localDataId){
                
                if((ldVal.newPriceCode != Null && ldVal.newPriceCode != '')&& (pc.wsp != Null && pc.wsp != '')){
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter either Price Code or WSP.'));
                  return Null;
                }
              }
            }
          }
        }
        
        
        if(newOverrideDate != NULL && obj.End_Date__c != NULL && (obj.End_Date__c <= newOverrideDate)){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Client End Override date must be greater than Client Start Override'));
          return Null;
        }
        
        
        list<string> commercialIds= new list<string>();
        commercialIds.addAll(commAvailIdsList);
        
        if(recordCount>=200 || forceBatchProcessChk == true)
        {
            msgB = (forceBatchProcessChk == true)
                ? 'Your request has been submitted for batch processing.  You will receive an e-mail notification with further instructions once it’s complete.'
                : '';
            msgA = (forceBatchProcessChk == true)
                ? ''
                : 'As your selection of RP’s and Clients will generate a large volume, your request will be handled via batch processing.';
            /*
if(forceBatchProcessChk == true)
{
msgB = 'Your request has been submitted for batch processing.  You will receive an e-mail notification with further instructions once it’s complete.';
msgA = '';
}
else
{
msgA = 'As your selection of RP’s and Clients will generate a large volume, your request will be handled via batch processing.';
msgB = '';
}
*/
            list<string> selectedCommIds = commercialIds; 
            list<account> selectedAccounts = selected_accountslist;
            
            string lstRunBatchId= batchIdForApexBatch();
            Id batchInstanceId = Database.executeBatch(new CABatchProcess (selectedCommIds,selectedAccounts,obj,lstRunBatchId,selectedPricingMapwrap,selectedlocalDataMapWrap), 10);
            
            //Pagereference PageRef = new Pagereference('/apex/WB_ClientAvail_Redirect');        
            Pagereference PageRef = new Pagereference('/apex/WB_BatchProcessEmailNotification');
            return PageRef; 
        }
        else{
            //for pricing table
            //code for pricing table
            
            //Advanced Pricing ER-002254
            newPriceCodeList = [
              SELECT id,Name,Account__c,Channel__c,Content_Type__c,Country__c,Effective_Date__c,Episode_Price__c,Episode_Price_Tier__c,
                Format__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,WS_Price__c
                FROM Pricing__c
                WHERE Name =: newPriceCodeSet AND Price_Code_Status__c =:'Active'
            ];
            
           
            selectedStorefronts = [
                SELECT Id,Name,Account__c,Account__r.Name,Pricing_Currency__c,Country__c,Channel_Picklist__c,Format__c,Content_Type__c,Status__c,Selected_Combination__c,CRM_Storefront__c,HBO_SAP_Customer__c,Turner_SAP_Customer__c,SAP_Customer_Number__c,
                (SELECT Id, Country__c, Language__c, Level__c, Type__c,Language__r.Name,Account__c FROM Language_Preferences__r WHERE Type__c =: Label.WB_Language_Preference_Type_Storefront ORDER BY Level__c ASC) //ER-003060 - Storefront Language Preferences changes - inner Query added
                FROM Agreement__c
                WHERE Account__c IN :selected_accountslist AND Country__c IN :commercialCountry
            ];
            list<client_avail__c> DateList = [
                SELECT id,Name,client__r.name,Commercial_Avail__r.Name,End_Date__c,Start_Date__c,Commercial_Avail__r.Start_Date__c,
                Commercial_Avail__r.End_Date__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,Release_Plan_Country__c,
                Release_Plan_Title__c,Client__c,Storefront__c,Client_Start_Ovver__c
                FROM client_avail__c
                WHERE Commercial_Avail__c IN :commAvailIdsList AND Client__c IN :selected_accountslist
            ];
            if(selectedStorefronts.size()==0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.No_storefronts_were_found));
            }
            
            //ER-003060 - Storefront Language Preferences changes - Start

            availableLangSet = [SELECT Id,Name,Language__c,Title__c FROM Available_Languages__c WHERE Title__c IN : titleIdSet AND Clear_to_avail__c = True];
            languagePrefSet = [SELECT Id,Name,Level__c,Country__c,Language__c,Type__c FROM Language_Preference__c WHERE Country__c IN :commercialCountry AND Type__c =: Label.WB_Language_Preference_Type_Country];

            if((availableLangSet != Null && availableLangSet.size()>0) && languagePrefSet != Null && languagePrefSet.size()>0 ){
                for(Language_Preference__c langPrefRec : languagePrefSet){
                    for(Available_Languages__c avlLangRec : availableLangSet){
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
            }
            //Storefront logic end   
            set<string> commercialAvailIds = new set<string>();    
            set<string> clientCommercialIds = new set<string>();
            Set<client_avail__c> sfMisMatchCAList = new Set<client_avail__c>();
            Map<String,Map<String,Set<String>>> mapErrorRPAccount = new Map<String,Map<String,Set<String>>>();

            //ER-003060 - Storefront Language Preferences changes 
           Map<String,Map<String,Map<String,Set<String>>>> mapErrorRPSFLangPref = new Map<String,Map<String,Map<String,Set<String>>>>();
            
            for(Commercial_Avail__c vCommercialAvails : commercial_avallst){ 
                //CRRT Phase6: Client avails shall not be created for Provisional Release Plans
                if(vCommercialAvails.Language_Type__c != 'Provisional'){
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
                                                       if(vCommercialAvails.id == CAOverlapRec.commercial_avail__c && acc.Id == CAOverlapRec.client__c){
                                                           
                                                           Boolean isOverlap = checkOverlapping(newOverrideDate,obj.End_Date__c,vCommercialAvails.Start_Date__c,vCommercialAvails.End_Date__c,CAOverlapRec.Start_Date__c,CAOverlapRec.End_Date__c);
                                                           if(isOverlap == True){
                                                              countOverlap++; 
                                                           }
                                                           
                                                       } 
                                                   }

                                                   //ER-003060 - Storefront Language Preferences changes - Start
                                                   if(selectStrfront.Language_Preferences__r != Null && selectStrfront.Language_Preferences__r.size()>0){
                                                    
                                                        Boolean isSFLangPref = checkStorefrontLangPreference(vCommercialAvails,selectStrfront,mapErrorRPSFLangPref,sfLangPrefLangMap,titleCountryAvlLangLevelMap,countExcpetionRec,notMatchedCommercialWrap_list2,acc,Null);
                                                        if(isSFLangPref)
                                                          break;
                                                   }
                                                   //ER-003060 - Storefront Language Preferences changes - End

                                                   if(countOverlap>0){
                                                       countExcpetionRec++;
                                                       releaseplanwrapper2 real= new releaseplanwrapper2();    
                                                       string str =  vCommercialAvails.Id+string.valueof(countExcpetionRec); 
                                                       String errorMessage =  'Client avail is present with selected dates';
                                                       clientAvailCreationError(real,str,errorMessage,vCommercialAvails,Null);     
                                                       real.accountName = selectStrfront.Account__r.Name;
                                                       notMatchedCommercialWrap_list2.add(real);
                                                       
                                                   }
                                                   else {
                                                       Client_avail__c ClientAvail = new client_avail__c();
                                                       
                                                       Boolean isPricingAssigned = false;
                                                       String localDatakey = vCommercialAvails.Title__r.Video_Version__c+vCommercialAvails.Country_Lookup__r.Name+vCommercialAvails.Languages__r.Name;
                                                       String pricingkey = vCommercialAvails.Channel__c+vCommercialAvails.Format__c;
                                                       Boolean isWSPAssigned = false;
                                                       
                                                       if(selectedPricingMapwrap != Null && selectedPricingMapwrap.size()>0){
                                                          
                                                           Decimal wspInputVAl;
                                                           Decimal episodeWspInputVAl;
                                                           assignCAValues(vCommercialAvails,ClientAvail,Null,selectStrfront,obj,selectedlocalDataMapWrap);
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
                                                          
                                                            if(selectedlocalDataMapWrap.containsKey(localDatakey)  ){
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
                                                                        assignCAValues(vCommercialAvails,ClientAvail,pricingRec,selectStrfront,obj,selectedlocalDataMapWrap);
                                                                        priceCodeCounter++;
                                                                        isPricingAssigned = true;
                                                                        if(vCommercialAvails.Title__r.Content_Type__c == 'SEASON' ){
                                                                            Pricing__c episodePricingRec = fetchEpisodePricing(pricingRec,newPriceCodeList);
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
                                                                    assignCAValues(vCommercialAvails,ClientAvail,Null,selectStrfront,obj,selectedlocalDataMapWrap);
                                                                    isPricingAssigned = true;
                                                                }
                                                            }
                                                        }
                                                       //code for when pricing list equal to zero
                                                       else if(!(isWSPAssigned || isPricingAssigned )){
                                                            assignCAValues(vCommercialAvails,ClientAvail,Null,selectStrfront,obj,selectedlocalDataMapWrap);
                                                       }
                                                       Boolean errorValue;
                                                       //added by Tejasvini Mar Release 2018
                                                       errorValue = WB_PriceUtility.availableCombination(vCommercialAvails,selectStrfront);
                                                       if(errorValue){
                                                           sfMisMatchCAList.add(ClientAvail);
                                                       }else{
                                                            Boolean isCRMCountry = false;
                                                            if(selectStrfront.CRM_Storefront__c){
                                                                isCRMCountry = true;
                                                            }
                                                           clientavail_lst.add(ClientAvail);
                                                           if(isCRMCountry){
                                                               caPriceWrapperMap.putAll(getCAPriceWrapperMap(vCommercialAvails,ClientAvail));
                                                           }
                                                           
                                                       }
                                                   }
                                               }
                                            else{
                                                countExcpetionRec++;
                                                releaseplanwrapper2 real= new releaseplanwrapper2();    
                                                string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                                                String errorMessage =  'Storefront doesnot contain the channel,format or content type';
                                                clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc); 
                                                notMatchedCommercialWrap_list2.add(real);
                                            }
                                        }else{
                                            countExcpetionRec++;
                                            releaseplanwrapper2 real= new releaseplanwrapper2();    
                                            string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);  
                                            String errorMessage =  'Storefront doesnot contain the channel,format or content type';
                                            clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);   
                                            notMatchedCommercialWrap_list2.add(real);
                                        }
                                    }
                                }else{
                                    countExcpetionRec++;
                                    releaseplanwrapper2 real= new releaseplanwrapper2();    
                                    string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);  
                                    String errorMessage =  'Storefront status is Inactive';
                                    clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);   
                                    notMatchedCommercialWrap_list2.add(real);
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                        if(countStorefronts==0){
                            countExcpetionRec++;
                            releaseplanwrapper2 real= new releaseplanwrapper2();    
                            string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                            String errorMessage =  'Storefront is not present';
                            clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);
                            notMatchedCommercialWrap_list2.add(real);
                        }
                    }
                    commercialAvailIds.add(vCommercialAvails.Id);
                }
                else{//CRRT Phase6: Client avails shall not be created for Provisional Release Plans
                    countExcpetionRec++;
                    releaseplanwrapper2 real= new releaseplanwrapper2();    
                    string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                    String errorMessage =  'Client avails can not be created for Provisional Release Plans';
                    clientAvailCreationError(real,str,errorMessage,vCommercialAvails,Null); 
                    notMatchedCommercialWrap_list2.add(real);
                }
            }
            clientCommercialIds= new set<string>();//Commercial Avail Ids whose  client avails are going to created.
            
            if(clientavail_lst != null && clientavail_lst.size()>0){
                
                for(client_avail__c clientCommRec:clientavail_lst){
                    clientCommercialIds.add(clientCommRec.Commercial_Avail__c);
                }
                
                for(string commIds:commercialAvailIds){
                    if(clientCommercialIds.contains(commIds)){
                        listReleaseplanClientCreate.add(commIds);
                    }
                }
                finalclientavail_lst.addAll(clientavail_lst);
                WB_PriceUtility.setReturnToWindowFlag(commercial_avallst,finalclientavail_lst);
            }
            //Generating final list of client avail whose going to insert.
            //Code for custom setting : first delete the existing record then :record insertion 
            
            integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];
            
            if(clientExceptionCount > 0){
                List<Client_Avail_Exception__c> existing = [SELECT Id From Client_Avail_Exception__c where User_Detail__c =:userDetail[0].Id];
                
                delete existing;
            }
            
            list<Client_Avail_Exception__c> clientAvailException_list = new list<Client_Avail_Exception__c>();
            List<Id> caIds = new List<Id>();
            
            for(releaseplanwrapper2 relwrap :notMatchedCommercialWrap_list2){
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
                Set<Client_Avail__c> caInsertSet = new Set<Client_Avail__c>();
                caInsertSet.addAll(finalclientavail_lst);
                finalclientavail_lst.clear();
                finalclientavail_lst.addAll(caInsertSet);
                
                if(caPriceWrapperMap != Null && caPriceWrapperMap.size()>0){
                    rateCardMap = WB_RateCardHelper.getRateCard(caPriceWrapperMap.values(),false,false);
                    if(keyCAMap != Null && keyCAMap.size()>0){
                        for(String key : keyCAMap.keySet()){
                            for(Client_Avail__c ca : keyCAMap.get(key)){
                              //ER-003373  Episode SR Price Field on CA --> caRec.SR_Per_Episode__c=  ca.SR_Per_Episode__c = Null;
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
                                           /*ER-003373--> ca.SR_Price__c = caRC.SRP__c; */
                                            rcFound = true;
                                            break;
                                        }
                                    }
                                }
                          
                                if((!rcFound && ca.Price__c == Null) || (!rcEpFound && ca.Episode_Price__c == Null)){
                                    if(!rcFound && ca.Price__c == Null){
                                        ca.Price_Tier_Text__c = 'TBD';
                                       /*ER-003373--> ca.SR_Price__c= Null; */
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
                //  }
                }
                if(finalclientavail_lst != null && finalclientavail_lst.size() > 0) {
                    ApexPages.getMessages().clear(); 
                    list<Client_Avail__c>finalclientavail_lstTobeUpdate = batchIdGeneration(finalclientavail_lst);
                    //WB_DataThreshold_Client flagStatus= new WB_DataThreshold_Client();
                    //flagStatus.setWizardflag();
                    wizardRunFlag__c flagStatus= new  wizardRunFlag__c();
                    wizardRunFlag__c flagList= [select id, name, WizardFlag__c from wizardRunFlag__c where name='FlagValue']; 
                    flagStatus.id= flagList.id;
                    flagStatus.name=flagList.name;
                    flagStatus.WizardFlag__c='true';
                    update flagStatus;
                   
                    //finalclientavail_lstTobeUpdate[0].New_Content_Type__c = 'Feature';  //Added by Akash Temp
                    Database.Saveresult[] saveResult  = Database.insert(finalclientavail_lstTobeUpdate, false);
                    
                    if(clientAvailException_list.size()!=0){
                        Database.Saveresult[] saveExceptionResult  = Database.insert(clientAvailException_list, false);
                        
                    }
                    
                    //Added for : SINC1941490 - Client Avail Creation Wizard Error
                    integer numOfFailRec = 0;
                    for(Integer i=0; i<saveResult.size(); i++){
                        if (!saveResult.get(i).isSuccess()){
                            numOfFailRec++;
                            system.debug(LoggingLevel.INFO,'Error--> : '+saveResult.get(i).getErrors()[0].getMessage());
                        }
                        /*else
                            caIds.add(saveResult.get(i).getId()); //06/27/2016 sriniz*/
                    }
                    
                    //Added By Ketan
                    if(numOfFailRec == finalclientavail_lstTobeUpdate.size()){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Unable to create Client Avails. Client Avails already exist for selected Account(s) or Invalid Avail/Price data.'));
                        numOfFailRec = 0;
                        return null;
                    }
                    //Id batchInstanceId = Database.executeBatch(new WB_Batch_Playlist_Mngmt_Process(caIds), 1);  
                    Pagereference PageRef = new Pagereference('/apex/WB_Grid');
                    Pageref.getParameters().put('al','true');
                    Pageref.getParameters().put('obj','Client_Avail__c');
                    Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
                    Pageref.getParameters().put('CF_QP_filterValue',userDetail[0].CA_Batch_Id__c);
                    Pageref.setRedirect(true);
                    return PageRef;
                }
                else{
                
                  Boolean errorMsgFlag = false;
                  if(mapErrorRPAccount != Null && mapErrorRPAccount.size()>0){
                    
                        errorMsgFlag = true;
                        for(String error : mapErrorRPAccount.keySet()){
                            String errorMsg = error;
                            for(String rpName : mapErrorRPAccount.get(error).keySet()){
                                errorMsg = error+' - '+rpName;
                                Integer i = 0;
                                for(String accName:mapErrorRPAccount.get(error).get(rpName)){
                                    if(i==0)
                                        errorMsg = errorMsg + ' - '+accName;
                                    
                                    if(i>=1){
                                        errorMsg = errorMsg + ' , '+accName;
                                    }
                                    
                                    i= i +1;
                                        
                                }
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errorMsg));
                            }
                        }
                    }

                    //ER-003060 - Storefront Language Preferences changes - Start
                    if(mapErrorRPSFLangPref != Null && mapErrorRPSFLangPref.size()>0){
                        errorMsgFlag = true;
                        for(String rpName : mapErrorRPSFLangPref.keySet()){
                            String errorMsg = rpName+' - Language - '; 
                            for(String langName : mapErrorRPSFLangPref.get(rpName).keySet()){
                                //errorMsg = errorMsg + langName+ ' - not present on Storefront Language Preferences for Account';

                                for(String errorValue : mapErrorRPSFLangPref.get(rpName).get(langName).keySet()){
                                    errorMsg = errorMsg + langName+' - '+errorValue+' - ';
                                    Integer i = 0;
                                    for(String accName:mapErrorRPSFLangPref.get(rpName).get(langName).get(errorValue)){
                                        if(i==0)
                                            errorMsg = errorMsg +accName;
                                        
                                        if(i>=1){
                                            errorMsg = errorMsg + ' , '+accName;
                                        }
                                        
                                        i= i +1;
                                    }
                                
                                        
                                }

                            }
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errorMsg));
                        }

                    }
                    //ER-003060 - Storefront Language Preferences changes - End
                    
                    //added by Tejasvini Mar Release 2018
                    if((sfMisMatchCAList != null && sfMisMatchCAList.size()>0)){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Storefront does not contain the selected channel,format or content type combination.'));
                    }else if(!errorMsgFlag){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Create_Client_Avail_No_storefront));
                    }
                        
                }
            } 
            catch(Exception e) {
                System.debug(LoggingLevel.INFO,'The following exception has occurred: ' + e.getMessage());
            }
        }
        return null ;
    }
    
    /****** Method invoked on click of cancel button ******/    
    public pageReference bulkcancel(){
        
        pageReference PageRef = new Pagereference(System.Label.Cancle);
        return PageRef;
        
    }
    
    public void deleteExceptionedRecords(){
        selected_accountslist  = new List<Account>();
        commAvailIdsList = new set<string>();
        all_accountslist = new List<Account>();
        count=0;
        flagReleaseMaintainer =false;
        flagReleaseMaintainerForRPStatus = false;
        clientavail_lst = new list<Client_Avail__c>();
        finalclientavail_lst = new list<Client_Avail__c>();
        selectedStorefronts = new list<Agreement__c>();
        obj = new Client_Avail__c();//Mahesh : Initialized because we removed standard controller
        
        availids = ApexPages.currentPage().getParameters().get('ID');
        
        //Mahesh - Passing all selected Ids to availids if Ids are not coming from URL parameters
        availids = (availids == null || availids == '') ? str : availids;
        
        
        /* ER-417 : Start */
        String UniqueId = ApexPages.currentPage().getParameters().get('UNIQUEID');
        if(UniqueId != null && UniqueId != ''){
            
            List<Client_Avail_Id_Store__c> CAIDStoreList = [
                select Id, ID_Store__c
                from Client_Avail_Id_Store__c
                where Key__c = :UniqueId limit 1
            ];
            if(CAIDStoreList != null && CAIDStoreList.size() > 0){
                availids = CAIDStoreList[0].ID_Store__c;//CAIDStoreList[0].ID_Store__c.split(',');
            }
        }
        /* ER-417 : End */
        
        
        list<String> lstCommercialIds = availids.split(',');
        
        //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You have selected - ' + lstCommercialIds.size() + ' RP Ids.'));
        
        obj.status__c ='Draft';//Assigning default value to status    
        
        //Adding these status value ,so in the selection of Release Plans it will only select the record whose status is Tentative,Confirmed,Planned
        commercialAvailStatus = new list<string>();
        commercialAvailStatus.add('Confirmed');
        commercialAvailStatus.add('Tentative');
        
        /**28th Oct 2014 Code for release maitainer profile : checking wthere the territory of release plan country is equals to user territory***/
        
        userDetail = [SELECT id,Name,ProfileId,Profile.Name,UserType,Territory__c,CA_Batch_Id__c  from User where id =: Userinfo.getUserId()];
        
        for(User u :userDetail){
            
            if(u.Profile.Name ==System.Label.WB_Territory_Release_Planner){
                
                list<string> userTerritory = new list<string>();
                userTerritory.add(u.Territory__c);
                // added Local_Category__c field in the below query -- shalini for ER-356
                commercial_avallst = [
                    SELECT id, name,Format__c,Channel__c,Country_Lookup__c,Country_Lookup__r.Name,Country_Lookup__r.Generate_CRM_Product__c,Languages__c,Languages__r.Name,Language_Type__c,
                    Country_Group__c,Title__c,Start_Date__c,End_Date__c,Status__c,Title__r.Content_Type__c,Title__r.Clear_to_Avail__c,
                    Title__r.Name,Local_Title__r.Price_Code__c,Local_Title__r.Category__c,Local_Title__r.Local_Category__c,Title__r.Territory__c,Title__r.Video_Version__c,Local_Title__r.LocalDisplayStudio__c
                    FROM Commercial_Avail__c 
                    WHERE id IN :lstCommercialIds  AND Status__c IN:commercialAvailStatus AND Title__r.Clear_to_Avail__c =: true
                ];
                
                if(commercial_avallst.size() == 0){
                    flagReleaseMaintainerForRPStatus = true;
                }
                else{
                    
                    // added Local_Category__c field in the below query -- shalini for ER-356
                    commercial_avallst = [
                        SELECT id, name,Format__c,Channel__c,Country_Lookup__c,Country_Lookup__r.Name,Country_Lookup__r.Generate_CRM_Product__c,Languages__c,Languages__r.Name,Language_Type__c,
                        Country_Group__c,Title__c,Start_Date__c,End_Date__c,Status__c,Title__r.Content_Type__c,Title__r.Clear_to_Avail__c,
                        Title__r.Name,Local_Title__r.Price_Code__c,Local_Title__r.Category__c,Local_Title__r.Local_Category__c,Title__r.Territory__c,Title__r.Video_Version__c,Local_Title__r.LocalDisplayStudio__c
                        FROM Commercial_Avail__c 
                        WHERE Id IN :lstCommercialIds AND Status__c IN:commercialAvailStatus 
                        AND Country_Lookup__r.Territory__c IN: userTerritory AND Title__r.Clear_to_Avail__c = true
                    ];
                    
                    if(commercial_avallst.size() == 0){
                        flagReleaseMaintainer = true;
                    }
                    //flagReleaseMaintainer = true;
                }
            }
            else{
                
                // added Local_Category__c field in the below query -- shalini for ER-356
                commercial_avallst =    [   SELECT  id, name,Format__c,Channel__c,Country_Lookup__c,Country_Lookup__r.Name,Country_Lookup__r.Generate_CRM_Product__c,Languages__c,Languages__r.Name,Language_Type__c,Country_Group__c,Title__c,Start_Date__c,
                                         End_Date__c,Status__c,Title__r.Content_Type__c,Title__r.Name,Title__r.Clear_to_Avail__c,Local_Title__c,
                                         Local_Title__r.Price_Code__c,Local_Title__r.Category__c,
                                         Local_Title__r.Local_Category__c,Title__r.Video_Version__c,Local_Title__r.LocalDisplayStudio__c
                                         FROM  Commercial_Avail__c  WHERE  id IN :lstCommercialIds  
                                         AND Status__c IN:commercialAvailStatus 
                                         AND Title__r.Clear_to_Avail__c =:true];
            }
        }
        
        commercial_avallst_new = new List<List<Commercial_Avail__c>>(); /* Mahesh : ER-000050 Changes*/
        List<Commercial_Avail__c> tempCommAvailList = new List<Commercial_Avail__c>();
        
        selectedPricingMapwrap = new Map<String,pricingWrapper>();
        selectedlocalDataMapWrap = new Map<String,localDataWrapper>();
        
        //Code for filtering Account list in the page 28th Oct 2014      
        for(Commercial_Avail__c vCommercialAvails : commercial_avallst){
            pricingWrapper pcWrap = new pricingWrapper(); 
            localDataWrapper ldWrap = new localDataWrapper();
            /* Mahesh : ER-000050 Changes start */
            if(tempCommAvailList.size() <= 500){
                tempCommAvailList.add(vCommercialAvails);
            }
            else{
                commercial_avallst_new.add(tempCommAvailList);
                tempCommAvailList = new List<Commercial_Avail__c>();
                tempCommAvailList.add(vCommercialAvails);
            }
            /* Mahesh : ER-000050 Changes end */
            
            
            selectedCommContry.add(vCommercialAvails.Country_Lookup__c);
            // added on 12 jan 2014
            
            if(vCommercialAvails.Status__c == 'Tentative')
                confirmCAValue = true;
            else
                confirmCAValue = false;
            
            if(vCommercialAvails.Title__r.Content_Type__c == Label.Collection_Features){
                contentTypeValue = true;
            }
            TitleContentType.add(vCommercialAvails.Title__r.Content_Type__c);
            commercialCountry.add(vCommercialAvails.Country_Lookup__c);
            releaseLocalPriceCod.add(vCommercialAvails.Local_Title__r.Price_Code__c);
            releasePlanChannel.add(vCommercialAvails.Channel__c);
            releasePlanFormat.add(vCommercialAvails.Format__c); 
            commAvailIdsList.add(vCommercialAvails.Id); 
            titleIdSet.add(vCommercialAvails.Title__c);   //ER-003060 - Storefront Language Preferences changes
            pcWrap.channel = vCommercialAvails.Channel__c;
            pcWrap.format = vCommercialAvails.Format__c;
            pcWrap.wsp = '';
            pcWrap.errorMsg = '';
            pcWrap.episodeWSP = '';
            pcWrap.contentType = vCommercialAvails.Title__r.Content_Type__c;
            pcWrap.localDataId = vCommercialAvails.Local_Title__c;
            ldWrap.releaseplan = vCommercialAvails;
            ldWrap.ca = new Client_Avail__c();
            ldWrap.error = '';
            ldWrap.isPopupCode = false;
            String key = pcWrap.channel + pcWrap.format;
            if(!selectedPricingMapwrap.containsKey(key)){
                selectedPricingMapwrap.put(key,pcWrap);
            }
            String ldKey = vCommercialAvails.Title__r.Video_Version__c+vCommercialAvails.Country_Lookup__r.Name + vCommercialAvails.Languages__r.Name;
            if(!selectedlocalDataMapWrap.containsKey(ldKey)){
                selectedlocalDataMapWrap.put(ldKey,ldWrap);
            }
            
        }
        commercial_avallst_new.add(tempCommAvailList);/* Mahesh : ER-000050 Changes*/
        
        selectedCommStorefront =[SELECT id,Name,Country__c,Account__c,Status__c from Agreement__c where Country__c IN:selectedCommContry 
                                 and Status__c =:'Active'];
        
        for(Agreement__c storefrnt :selectedCommStorefront){
            selectedStoreAccntIds.add(storefrnt.Account__c);    
        }
        
        all_accountslist =[SELECT id,Name,Type,Territory__c,Platform__c FROM Account where id IN:selectedStoreAccntIds 
                           AND RecordType.Name =: System.Label.AccRecordType ORDER BY Name];
        //For Commercial avail Scrolling Bar
        
        selectedCommercialCount=commercial_avallst.size();
        count =selectedCommercialCount;
        if(selectedCommercialCount > 10){
            commercialScroller = true;
        }else commercialScroller =false;
        
        if(all_accountslist.size()==0 && selectedCommercialCount!=0 ){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'For selected Release Plans storefront is not available'));
        }
        
        //For Account in list format 29th September
        
        selectedAccountslistwrap=new list<accountwrapper >();
        for(Account acciterate:all_accountslist ){
            accountwrapper acct= new accountwrapper();
            acct.acc =acciterate;
            acct.selected =false;
            selectedAccountslistwrap.add(acct);
        }
        
        //For showing error message when user selected Release plan records not having status Tentative,Confirmed,Planned
        // Imran (16 Jan 15) 
        if(selectedCommercialCount == 0 && flagReleaseMaintainer == false){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Create_Client_Avail_release_plan_status));
        }
        
        if(flagReleaseMaintainerForRPStatus){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Create_Client_Avail_release_plan_status));
        } 
        if(flagReleaseMaintainer){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'User is not allowed to create record for Release Plans outside of their  Territory'));
        }
        /* End : Constructor code ends here (ER-000050) */
        integer clientExceptionCount = [SELECT count() FROM Client_Avail_Exception__c];
        
        if(clientExceptionCount > 0){
            List<Client_Avail_Exception__c> existing = [SELECT Id From Client_Avail_Exception__c where User_Detail__c =:userDetail[0].Id];
            
            delete existing;
        }
    }
    
    public pageReference validateComponents(){
        String rpIDValue = '';
        String accountIDValue = '';
        
        if(commercial_avallst  != null){
            for(Commercial_Avail__c rpRec : commercial_avallst){
                rpIDValue += rpRec.Id+'#';
            }
        }
        
        if(selected_accountslist  != null){
            for(Account accRec : selected_accountslist){
                accountIDValue += accRec.Id+'#';
            }
        }else {
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select atleast one Account value.'));
        }
        
        String caOverrideDate = '';
        if(obj.Client_Start_Ovver__c != null){
            caOverrideDate = String.valueOf(obj.Client_Start_Ovver__c);
        }
        
        Pagereference pageRef = new Pagereference('/apex/WB_Bundle_Avail_Validation');
        pageRef.getParameters().put('rpIds',rpIDValue);
        pageRef.getParameters().put('clientIds',accountIDValue);
        pageRef.getParameters().put('date',caOverrideDate);
        
        return pageRef;
    } 
    
    //Display Message on CA Status
    public void displayCAMessage(){
        
        if(obj.Status__c == 'Confirmed' && confirmCAValue){
            CAMessage = 'Release Plan will be confirmed';
        }else
            CAMessage = '';
        
    }
    
    public pageReference batchProcessEmailNotificationOkBtn()
    {
        Pagereference PageRef = new Pagereference(System.Label.Redirect_to_All_Client_avail);                 
        return PageRef;
    }
    
    //Mahesh - 26 May
    public pagereference pageRedirect(){
        Pagereference PageRef = new Pagereference('/apex/WB_Grid');
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj','Client_Avail__c');
        Pageref.getParameters().put('CF_QP_filterField','Batch_Id__c');
        Pageref.getParameters().put('CF_QP_filterValue',userDetail[0].CA_Batch_Id__c);
        return PageRef;
    }   
    
   public PageReference validateManualPriceCode(){
      
      String key = System.currentPagereference().getParameters().get('priceCodekey');
      String rp = System.currentPagereference().getParameters().get('paramValue');
      String priceCodeName = '';
      Set<String> contentTypeSet = new Set<String>();
        Set<String> countrySet = new Set<String>();
      if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
        if(selectedlocalDataMapWrap.containsKey(key)){
          if(selectedlocalDataMapWrap.get(key).newPriceCode != Null){ 
              if(selectedlocalDataMapWrap.get(key).newPriceCode == '' && selectedlocalDataMapWrap.get(key).error != ''){
                localDataWrapper ld = selectedlocalDataMapWrap.get(key);
                ld.error = '';
                selectedlocalDataMapWrap.put(key,ld);
              }else if(selectedlocalDataMapWrap.get(key).newPriceCode != ''){
                  priceCodeName = selectedlocalDataMapWrap.get(key).newPriceCode;
                localDataWrapper ld1 = selectedlocalDataMapWrap.get(key);
                ld1.isManualCode = true;
                selectedlocalDataMapWrap.put(key,ld1);
                      for(Commercial_Avail__c rpRec : commercial_avallst){
                          if(rp == rpRec.Id){
                            contentTypeSet.add(rpRec.Title__r.Content_Type__c);
                            countrySet.add(rpRec.Country_Lookup__c);
                          }
                        }
                        List<Pricing__c> pricingList = new List<Pricing__c>();
                        pricingList = [SELECT id,Name,Account__c,Account__r.Name,Channel__c,Content_Type__c,Country__c,Country__r.Name,Effective_Date__c,Episode_Price__c,
                                               Format__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,Storefront_Currency__c,WS_Price__c  FROM Pricing__c WHERE
                                               Content_Type__c IN:contentTypeSet AND Country__c IN:countrySet AND Price_Code_Status__c = 'Active' AND Name=:priceCodeName ORDER BY Name ASC];
                      if(pricingList.size() == 0){
                        if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
                                if(selectedlocalDataMapWrap.containsKey(key) ){
                                    localDataWrapper ld = selectedlocalDataMapWrap.get(key);
                            ld.error = 'Invalid Price Code.';
                            selectedlocalDataMapWrap.put(key,ld);
                                }
                            }
                      }else{
                        if(selectedlocalDataMapWrap.containsKey(key)  && selectedlocalDataMapWrap.get(key).error !=''){
                                    localDataWrapper ld = selectedlocalDataMapWrap.get(key);
                            ld.error = '';
                            selectedlocalDataMapWrap.put(key,ld);
                                }
                      }
                    }
          }
        }
      }
      return Null;
    }
    
    public PageReference getPriceCode(){
        set<string> list_TitleContentType = new set<string>();
        set<string> list_LocalCountry = new set<string>();
        sortedPricingName = new List<String>();
        selectedPriceCode_Map = new Map<String,List<SelectOption>>();
        String val_PriceCOde = System.currentPagereference().getParameters().get('priceCOde_Value');
        displayPopUp=false;
        Set<String> contentTypeSet = new Set<String>();
        Set<String> countrySet = new Set<String>();
        Set<String> channelSet = new Set<String>();
        Set<String> formatSet = new Set<String>();
       
        distinctPriceCodeSet = new set<string>();
        for(Commercial_Avail__c rpRec : commercial_avallst){
          if(paramValue == rpRec.Id){
            contentTypeSet.add(rpRec.Title__r.Content_Type__c);
            countrySet.add(rpRec.Country_Lookup__c);
            channelSet.add(rpRec.Channel__c);
            formatSet.add(rpRec.Format__c);
          }
        }
        flag= val_PriceCOde;
        list_SelectedPricing =[SELECT id,Name,Account__c,Account__r.Name,Channel__c,Content_Type__c,Country__c,Country__r.Name,Effective_Date__c,Episode_Price__c,
                               Format__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,Storefront_Currency__c,WS_Price__c  FROM Pricing__c WHERE
                               Content_Type__c IN:contentTypeSet AND Country__c IN:countrySet AND Price_Code_Status__c = 'Active' ORDER BY Name ASC];
        if(list_SelectedPricing != Null && list_SelectedPricing.size()>0){
            for(Pricing__c price :list_SelectedPricing ){
                if(distinctPriceCodeSet.add(price.Name)){
                    sortedPricingName.add(price.Name);
                    if(!selectedPriceCode_Map.containsKey(priceCodekey)){
                        selectedPriceCode_Map.put(priceCodekey,new List<SelectOption>{ new SelectOption(price.Name,price.Name)});
                    }else{
                        selectedPriceCode_Map.get(priceCodekey).add(new SelectOption(price.Name,price.Name));
                    }
                }
                if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
                  if(selectedlocalDataMapWrap.containsKey(priceCodekey) ){
                      localDataWrapper ld = selectedlocalDataMapWrap.get(priceCodekey);
              selectedlocalDataMapWrap.put(priceCodekey,ld);
                  }
              }
            }
            displayPopUp=true;
        }else {
            if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
                if(selectedlocalDataMapWrap.containsKey(priceCodekey)){
                    selectedlocalDataMapWrap.get(priceCodekey).error = 'No Price Code available for selected Combination.';
                }
            }
        }
        return Null;
    }
    
    public void selectcon(){
        String selPricingId_1= System.currentPagereference().getParameters().get('pId');
        selectPriceCode = selPricingId_1;
    }
    
    public PageReference cancelPopUp(){
        displayPopUp=false;
        return null;
    }
    
    public void updatePriceCode(){
        String currentSelPriceCode  = System.currentPagereference().getParameters().get('currentSelPriceCode');
        if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
            if(selectedlocalDataMapWrap.containsKey(currentSelPriceCode)){
                selectedlocalDataMapWrap.get(currentSelPriceCode).newPriceCode = selectPriceCode;
                selectedlocalDataMapWrap.get(currentSelPriceCode).error = '';
            }
        }
        displayPopUp=false;
    }
    
    public void changeCategory(){
        String key =  System.currentPagereference().getParameters().get('keyVal');
        String contentType =  System.currentPagereference().getParameters().get('contentType');
        String CatVal_1=  System.currentPagereference().getParameters().get('CatVal');
        String catVal = selectedlocalDataMapWrap.get(key).ca.Local_Data_Category_Picklist__c;
        if((contentType == 'Season' || contentType == 'Episode')&& (catVal != Null && !catVal.contains('TV'))){
          if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
                if(selectedlocalDataMapWrap.containsKey(key)){
                  localDataWrapper ld = selectedlocalDataMapWrap.get(key);
                  ld.error = 'Invalid Category for TV Titles.';
                  selectedlocalDataMapWrap.put(key,ld);
                }
            }
        }else if(!(contentType == 'Season' || contentType == 'Episode') && (catVal != Null && catVal.contains('TV'))){
          if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
                if(selectedlocalDataMapWrap.containsKey(key)){
                    localDataWrapper ld = selectedlocalDataMapWrap.get(key);
                  ld.error = 'Invalid Category for Non TV Titles.';
                  selectedlocalDataMapWrap.put(key,ld);
                }
            }
        }else{
          if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
            if(selectedlocalDataMapWrap.containsKey(key)){
              localDataWrapper ld = selectedlocalDataMapWrap.get(key);
              ld.error = '';
              selectedlocalDataMapWrap.put(key,ld);
            }
          }
        }
    }
    
    public static void clientAvailCreationError(releaseplanwrapper2 real,String str,String errorMessage,Commercial_Avail__c vCommercialAvails,Account acc){
      real.releaseplan = vCommercialAvails;   
      if(acc != Null){
        real.accountName = acc.name;
      }         
        real.reasonMsg = errorMessage;
        real.uniqueName = str;
    }
    
    public void pricingError(){
        
        String key_val = System.currentPagereference().getParameters().get('key');
        Decimal wspValue;
        Boolean isNumericVal; 
        String wsp;
        String episodeWSP_val;
        Boolean isZero;
        
        if(key_val != Null){
            pricingWrapper pw = selectedPricingMapwrap.get(key_val);
           wsp = selectedPricingMapwrap.get(key_val).wsp;
           episodeWSP_val = selectedPricingMapwrap.get(key_val).episodeWSP;
           if(wsp != Null && wsp == ''){
               if(selectedPricingMapwrap.get(key_val).errorMsg != ''){
                   pw.errorMsg = '';
                    selectedPricingMapwrap.put(key_val,pw);
               }else if(episodeWSP_val != ''&& episodeWSP_val != Null && selectedPricingMapwrap.get(key_val).contentType != 'Season'){
                   pw.errorMsg = 'Episode WSP is not valid for the Title Content Type';
                selectedPricingMapwrap.put(key_val,pw);
               }
           }
           if( wsp != Null && wsp != ''){
              if(wsp == '0'){
                  pw.errorMsg = 'WSP must be greater than 0';
                selectedPricingMapwrap.put(key_val,pw);
              }else{
                isNumericVal = isNumeric(wsp);
                  if( isNumericVal && (wsp != Null || wsp != '')){
                      try{
                        wspValue = Decimal.valueOf(wsp);
                        if(selectedPricingMapwrap.get(key_val).errorMsg != ''){
                            pw.errorMsg = '';
                            selectedPricingMapwrap.put(key_val,pw);
                        }
                        if((episodeWSP_val != Null && episodeWSP_val == '') && selectedPricingMapwrap.get(key_val).contentType == 'Season'){
                               pw.errorMsg = 'Please provide Episode WSP for Content Type Season';
                             selectedPricingMapwrap.put(key_val,pw);
                         
                          }else if((episodeWSP_val != Null && episodeWSP_val != '') && selectedPricingMapwrap.get(key_val).errorMsg != ''){
                               pw.errorMsg = '';
                             selectedPricingMapwrap.put(key_val,pw);
                          }
                      }catch(Exception e){
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'WSP must be greater than 0 '));
                      }
                      
                  }else if(!isNumericVal){
                      pw.errorMsg = 'Please enter a valid value.';
                    selectedPricingMapwrap.put(key_val,pw);
                  }else if(wspValue != Null && wspValue <= 0){
                      pw.errorMsg = 'WSP must be greater than 0 ';
                    selectedPricingMapwrap.put(key_val,pw);
                  }else{
                      pw.errorMsg = '';
                    selectedPricingMapwrap.put(key_val,pw);
                  }
              }
            }
         }
    }
    
    public void pricingEpisodeWSPError(){
        String key_val = System.currentPagereference().getParameters().get('key');
        Decimal episodeWSPValue;
        Boolean isNumericVal;
        String episodeWSP_val;
        Boolean isZero;
        
        if(key_val != Null){
           episodeWSP_val = selectedPricingMapwrap.get(key_val).episodeWSP;
           pricingWrapper pw = selectedPricingMapwrap.get(key_val);
           if((episodeWSP_val != Null && episodeWSP_val == '') && (selectedPricingMapwrap.get(key_val).errorMsg != Null && selectedPricingMapwrap.get(key_val).errorMsg != '')){
             pw.errorMsg = '';
              selectedPricingMapwrap.put(key_val,pw);
           }
           else if(episodeWSP_val != ''&& episodeWSP_val != Null){
               if(selectedPricingMapwrap.get(key_val).contentType != 'Season'){
                 pw.errorMsg = 'Episode WSP is not valid for the Title Content Type';
                selectedPricingMapwrap.put(key_val,pw);
               }
               else if((selectedPricingMapwrap.get(key_val).wsp != Null && selectedPricingMapwrap.get(key_val).wsp == '') && selectedPricingMapwrap.get(key_val).contentType == 'Season'){
                  pw.errorMsg = 'WSP is required when Episode WSP is provided.';
                selectedPricingMapwrap.put(key_val,pw);
              }else if(episodeWSP_val == '0'){
              pw.errorMsg = 'Episode WSP must be greater than 0';
                selectedPricingMapwrap.put(key_val,pw);
            }else {
                   isNumericVal = isNumeric(episodeWSP_val);
                  if( isNumericVal && (episodeWSP_val != Null || episodeWSP_val != '')){
                      episodeWSPValue = Decimal.valueOf(episodeWSP_val);
                  }
                  if(!isNumericVal){
                      pw.errorMsg = 'Please enter a valid value.';
                    selectedPricingMapwrap.put(key_val,pw);
                  }else if(episodeWSPValue != Null && episodeWSPValue <= 0){
                      pw.errorMsg = 'Episode WSP must be greater than 0 ';
                    selectedPricingMapwrap.put(key_val,pw);
                  }else{
                      pw.errorMsg = '';
                    selectedPricingMapwrap.put(key_val,pw);
                  }
              }
          }
         }
    }
    
    public Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
    private void populateCategories(){
      categories.add(new SelectOption('','--None--'));
      categories.add(new SelectOption('Theatrical New Release','Theatrical New Release'));
        categories.add(new SelectOption('Direct To Video New Release','Direct To Video New Release'));
        categories.add(new SelectOption('Catalog New To Format','Catalog New To Format'));
    categories.add(new SelectOption('Catalog','Catalog'));
    categories.add(new SelectOption('TV Catalog','TV Catalog'));
    categories.add(new SelectOption('TV New Release','TV New Release'));
    categories.add(new SelectOption('TV Day After US','TV Day After US'));
    categories.add(new SelectOption('TV Day After Local','TV Day After Local'));
    categories.add(new SelectOption('TBD','TBD'));  
    }
    
    public List<SelectOption> getCategories() {
        return categories;
    }
        
    public static void assignCAValues(Commercial_Avail__c vCommercialAvails,Client_Avail__c caRec,Pricing__c pricingRec,Agreement__c selectStrfront,Client_Avail__c obj,Map<String,localDataWrapper> selectedlocalDataMapWrap){
        if(pricingRec != Null){
            caRec.Pricing__c = pricingRec.Id;
            caRec.Price_Tier_Text__c= pricingRec.Price_Tier__c;
            caRec.Price__c= pricingRec.WS_Price__c;
            /*ER-003373--> caRec.SR_Price__c= pricingRec.SR_Price__c; */
            if(vCommercialAvails.Title__r.Content_Type__c == 'Season'){
                caRec.Episode_Price__c= pricingRec.Episode_Price__c;
                //ER-003373  Episode SR Price Field on CA--> caRec.SR_Per_Episode__c= pricingRec.SR_Per_Episode__c; 
                caRec.Episode_Price_Tier__c= pricingRec.Episode_Price_Tier__c;
            }
            if(pricingRec.Price_Tier__c == Null && pricingRec.WS_Price__c == Null){
                caRec.Price_Tier_Text__c= 'TBD';
                caRec.status__c = 'Tentative';
            }else
                caRec.status__c = obj.status__c;
        }else{
            caRec.Price_Tier_Text__c= 'TBD';
            if(obj.status__c == 'Confirmed' ){
                caRec.status__c = 'Tentative'; 
            }
            else 
               caRec.status__c = obj.status__c;
        }
        
        if(obj.Client_Start_Ovver__c !=null && obj.Client_Start_Ovver__c > vCommercialAvails.Start_Date__c){
            caRec.Start_Date__c = obj.Client_Start_Ovver__c;
        }else{
            caRec.Start_Date__c = vCommercialAvails.Start_Date__c;
        }
        
        //Advanced Pricing ER-002254 new End Date Override changes
        if(obj.End_Date__c != NULL && obj.End_Date__c < vCommercialAvails.End_Date__c){
          caRec.End_Date__c = obj.End_Date__c;
        }else{
            caRec.End_Date__c = vCommercialAvails.End_Date__c;
        }
                                                                    
        if((caRec.Start_Date__c != NULL && (caRec.Start_Date__c != vCommercialAvails.Start_Date__c)) ||(obj.End_Date__c != NULL && (obj.End_Date__c != vCommercialAvails.End_Date__c)) ){
            caRec.RP_Synch__c = false;
        }
        caRec.Change_Context__c=obj.Change_Context__c; 
        caRec.client__c = selectStrfront.Account__c;
        caRec.Storefront__c= selectStrfront.Id;
        
        //Advanced Pricing ER-002254 new Category Override changes
        String key = vCommercialAvails.Title__r.Video_Version__c + vCommercialAvails.Country_Lookup__r.Name + vCommercialAvails.Languages__r.Name;
        Boolean isNewCategoryOverride = false;
        if(selectedlocalDataMapWrap != Null && selectedlocalDataMapWrap.size()>0){
        if(selectedlocalDataMapWrap.containsKey(key) && selectedlocalDataMapWrap.get(key).ca.Local_Data_Category_Picklist__c != Null){
          isNewCategoryOverride = true;
        }
      }
      
        if(isNewCategoryOverride){
          caRec.Local_Data_Category_Picklist__c = selectedlocalDataMapWrap.get(key).ca.Local_Data_Category_Picklist__c;
        }
        else if(vCommercialAvails.Local_Title__r.Local_Category__c != null && vCommercialAvails.Local_Title__r.Local_Category__c!='')        
            caRec.Local_Data_Category_Picklist__c= vCommercialAvails.Local_Title__r.Local_Category__c;
        else
            caRec.Local_Data_Category_Picklist__c='TBD';
        
        caRec.Commercial_Avail__c = vCommercialAvails.id;
        caRec.Local_Title__c = vCommercialAvails.Local_Title__c;
        
    }
    
    public static Boolean checkOverlapping(Date startOverride,Date endOverride,Date rpStartDate,Date rpEndDate,Date existingCAStartDate,Date existingCAEndDate){
      if(startOverride == Null){
        startOverride = rpStartDate;
      }
      if(endOverride == Null){
        endOverride = rpEndDate;
      }
      /*if(((existingCAStartDate < startOverride) 
      && ((startOverride < existingCAEndDate && existingCAEndDate < endOverride) || (startOverride < endOverride && endOverride < existingCAEndDate)))
      || ((startOverride < existingCAStartDate) 
      && ((existingCAStartDate < existingCAEndDate && existingCAEndDate < endOverride) || (existingCAStartDate < endOverride && endOverride < existingCAStartDate)))) {
          return True;
    }
    else 
        return False;*/
    
    //Added For : SINC1941490 - Client Avail Creation Wizard Error
      return  (startOverride <= endOverride && startOverride <= existingCAEndDate && endOverride >= existingCAStartDate);      
    }
    
    public static Map<String,WB_RateCardHelper.PriceKeyWrapper> getCAPriceWrapperMap(Commercial_Avail__c releasePlanRec,Client_Avail__c ca){
      Map<String,WB_RateCardHelper.PriceKeyWrapper> caMap = new Map<String,WB_RateCardHelper.PriceKeyWrapper>();
      if((ca != Null ) && releasePlanRec != Null){
        WB_RateCardHelper.PriceKeyWrapper wrapper = new WB_RateCardHelper.PriceKeyWrapper();
        
        if(((ca.Price_Tier_Text__c != Null && ca.Price_Tier_Text__c != '' && ca.Price_Tier_Text__c != 'TBD') || ca.Price__c != Null )){ 
          wrapper.accountId = ca.Client__c;
          wrapper.countryId = releasePlanRec.Country_Lookup__c;
          wrapper.channel = releasePlanRec.Channel__c;
          wrapper.format = releasePlanRec.Format__c;
          wrapper.contentType = releasePlanRec.Title__r.Content_Type__c;
          
          String rcKey = ca.Client__c +'_'+releasePlanRec.Country_Lookup__c+'_'+releasePlanRec.Channel__c+'_'+releasePlanRec.Format__c;
          String rcKey_ep;
          
          //Episode Content changes
          if(releasePlanRec.Title__r.Content_Type__c == 'Season'){
              rcKey_ep = rcKey +'_Episode';
              
          }
          
          rcKey = rcKey + '_'+releasePlanRec.Title__r.Content_Type__c;
          
          
          if(ca.Price_Tier_Text__c != Null && ca.Price_Tier_Text__c != '' && ca.Price_Tier_Text__c != 'TBD'){
            wrapper.priceTier = ca.Price_Tier_Text__c;
            rcKey = rcKey +'_'+ca.Price_Tier_Text__c;
          }else if(ca.Price__c != Null){
            if((ca.Price__c.scale() <2)|| (ca.Price__c.scale() >2)){
                ca.Price__c = ca.Price__c.setScale(2);
            }
            wrapper.wsp = ca.Price__c;
            rcKey = rcKey +'_'+ca.Price__c;
          }
        
          rcKey = rcKey.toUpperCase();
          //Episode Content changes
          
          WB_RateCardHelper.PriceKeyWrapper wrapperEp = wrapper.clone();
          if(releasePlanRec.Title__r.Content_Type__c == 'Season'){
              wrapperEp.contentType = 'Episode';
              if(ca.Episode_Price_Tier__c != Null && ca.Episode_Price_Tier__c != '' && ca.Episode_Price_Tier__c != 'TBD'){
                  wrapperEp.priceTier = ca.Episode_Price_Tier__c;
                  wrapperEp.wsp = Null;
                  rcKey_ep = rcKey_ep +'_'+ca.Episode_Price_Tier__c;
              }else if(ca.Episode_Price__c != Null){
                if((ca.Episode_Price__c.scale() <2)|| (ca.Episode_Price__c.scale() >2)){
                    ca.Episode_Price__c = ca.Episode_Price__c.setScale(2);
                }
                wrapperEp.wsp = ca.Episode_Price__c;
                rcKey_ep = rcKey_ep +'_'+ca.Episode_Price__c;
                wrapperEp.priceTier = Null;
              }
              rcKey_ep = rcKey_ep.toUpperCase();
          }
          
          if(caMap != Null){
              caMap.put(rcKey,wrapper);
              if(rcKey_ep != Null && wrapperEp != Null){
                caMap.put(rcKey_ep,wrapperEp);
                
            }
          }
          
          if(!keyCAMap.containsKey(rcKey)){
            keyCAMap.put(rcKey,new List<Client_Avail__c>{ca});
          }else{
            keyCAMap.get(rcKey).add(ca);
          }
          
          //Episode Content changes
          if(rcKey_ep != Null ){
            if(!keyCAMap.containsKey(rcKey_ep)){
                keyCAMap.put(rcKey_ep,new List<Client_Avail__c>{ca});
            }else{
                keyCAMap.get(rcKey_ep).add(ca);
            }
          }
          
        }
      }
      
      return caMap;
    }
    
    public static Pricing__c fetchEpisodePricing(Pricing__c pricingRec,List<Pricing__c> newPriceCodeList){
        
        Pricing__c episodePricingRec ;
        for(Pricing__c rec:newPriceCodeList){
            if(rec.Content_Type__c == 'Episode' && rec.Country__c== pricingRec.Country__c &&
                rec.Account__c == pricingRec.Account__c && rec.Name == pricingRec.Name 
                && rec.Format__c== pricingRec.Format__c && rec.Channel__c== pricingRec.Channel__c ){
                episodePricingRec = rec;
                break;
            }
        }
        
        if(episodePricingRec != Null){
            return episodePricingRec;
        }else 
            return Null;
    }

    //ER-003060 - Storefront Language Preferences changes
    public static Boolean checkStorefrontLangPreference(Commercial_Avail__c vCommercialAvails,Agreement__c selectStrfront,Map<String,Map<String,Map<String,Set<String>>>> mapErrorRPSFLangPref,Map<String,Map<String,Set<String>>> sfLangPrefLangMap,Map<String,Map<String,Map<String,String>>> titleCountryAvlLangLevelMap,Integer countExcpetionRec,List<releaseplanwrapper2> notMatchedCommercialWrap_list2,Account acc,List<String> errorList){
        
        Integer countLangPref = 0;
        Boolean isSFLangPrefException = false;
        Boolean isSFAccountMatch = false;
        Boolean isSFAccountLangPrefLevelMatch = false;

        Boolean isSFlangPrefMatch = false;
        Boolean isSFHigherLangAvailable = false;
        for(Language_Preference__c langRec : selectStrfront.Language_Preferences__r){
            if(sfLangPrefLangMap != Null && sfLangPrefLangMap.get(selectStrfront.Id) != Null && sfLangPrefLangMap.get(selectStrfront.Id).get(langRec.Language__c) != Null &&
               (langRec.Language__c == vCommercialAvails.Languages__c)){
                isSFlangPrefMatch = true; 
                Set<String> higherLangSFSet = sfLangPrefLangMap.get(selectStrfront.Id).get(vCommercialAvails.Languages__c);
                if(higherLangSFSet != Null && higherLangSFSet.size()>0){
                    for(String higherLangId : higherLangSFSet){
                        if(titleCountryAvlLangLevelMap != Null && titleCountryAvlLangLevelMap.get(vCommercialAvails.Title__c) != Null && 
                            titleCountryAvlLangLevelMap.get(vCommercialAvails.Title__c).get(vCommercialAvails.Country_Lookup__c) != Null ){
                            
                            for(String langId : titleCountryAvlLangLevelMap.get(vCommercialAvails.Title__c).get(vCommercialAvails.Country_Lookup__c).keySet()){

                                if(langId == higherLangId){
                                    isSFHigherLangAvailable = true;
                                    break;
                                }
                            }
                                
        
                        }
                    }
                        
                }
            }
        }
        
       if((isSFlangPrefMatch && isSFHigherLangAvailable) || (!isSFlangPrefMatch)){ 
            //Exception code

            String error = '';
            if(isSFlangPrefMatch && isSFHigherLangAvailable){
                error = 'Higher Priority Language available on Title for Account';
            }else if(!isSFlangPrefMatch){
                error = 'not present on Storefront Language Preferences for Account';
            }

            //To track at CA Upload record level
            if(errorList != Null){
                errorList.add(error);
            }
            if(mapErrorRPSFLangPref != Null){
                if(!mapErrorRPSFLangPref.containsKey(vCommercialAvails.Name)){
                    mapErrorRPSFLangPref.put(vCommercialAvails.Name,new Map<String,Map<String,Set<String>>>());
                }
                if(!mapErrorRPSFLangPref.get(vCommercialAvails.Name).containsKey(vCommercialAvails.Languages__r.Name)){
                    mapErrorRPSFLangPref.get(vCommercialAvails.Name).put(vCommercialAvails.Languages__r.Name,new Map<String,Set<String>>());
                }
                if(!mapErrorRPSFLangPref.get(vCommercialAvails.Name).get(vCommercialAvails.Languages__r.Name).containsKey(error)){
                    mapErrorRPSFLangPref.get(vCommercialAvails.Name).get(vCommercialAvails.Languages__r.Name).put(error,new Set<String>());
                }
                if(!mapErrorRPSFLangPref.get(vCommercialAvails.Name).get(vCommercialAvails.Languages__r.Name).get(error).contains(selectStrfront.Account__r.Name)){
                    mapErrorRPSFLangPref.get(vCommercialAvails.Name).get(vCommercialAvails.Languages__r.Name).get(error).add(selectStrfront.Account__r.Name);
                }
            }
            
            isSFLangPrefException = true;
            if(isSFLangPrefException && notMatchedCommercialWrap_list2 != Null){
                countExcpetionRec++;
                WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                string str = vCommercialAvails.Id+string.valueof(countExcpetionRec); 
                String errorMessage = ''; 
                if(isSFlangPrefMatch && isSFHigherLangAvailable){
                    errorMessage = vCommercialAvails.Name + ' - '+vCommercialAvails.Languages__r.Name+' - Higher Priority Language available on Title for Account - '+ selectStrfront.Account__r.Name;
                }else if(!isSFlangPrefMatch){
                    errorMessage = vCommercialAvails.Name + ' - '+vCommercialAvails.Languages__r.Name+' - not present on Storefront Language Preferences for Account - '+ selectStrfront.Account__r.Name;
                }
                WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);
                notMatchedCommercialWrap_list2.add(real);
            }
            
            
        }

        return isSFLangPrefException;
    }
    
 
}