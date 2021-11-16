/*******************************************************************************************************************************************
* File Name     :   WB_Batch_CA_Upload
* Description   :   
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21 Oct.2015       CTS                 ER-000069 : Created the class.
* 2.0       
********************************************************************************************************************************************/

public class WB_Batch_CA_Upload implements Database.Batchable<sObject>,Database.Stateful
{
    Id caUploadId;
    //CA_Upload__c caUploadParentRecord;
    User loggedInUser;
    Boolean updateFlag;
    Map<String,Country__c> mapCountryMapNameId = new Map<String,Country__c>();
    Map<String,Id> mapLanguageMapNameId = new Map<String,Id>();
    Map<String,Account> mapAccountMapNameId = new Map<String,Account>();
    set<Id> CAUploadIds = new set<Id>();
    
    public WB_Batch_CA_Upload(Id cuId)
    {
       caUploadId = cuId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){   
         
        Set<String> setAccountName = new set<String>();
        for(Country__c country : [Select id,name,Territory__c from Country__c])
            mapCountryMapNameId.put(country.Name,country);
        for(Language__c lang : [Select id,name from Language__c])
            mapLanguageMapNameId .put(lang.Name,lang.id);
            
        updateFlag=false; 
        
        loggedInUser = [select id,Territory__c,Profile.Name from User where id in (Select CreatedbyId from CA_Upload__c where id =: caUploadId) limit 1];
        String queryString ='SELECT CA_Upload__r.name,Account_Name__c,Category__c,CA_upload_status__c,CA_Upload__c,Channel__c,Country__c,End_Date__c,Episode_Price_Tier__c,'
        +'Episode_SR_Price__c,Episode_WS_Cost__c,Format__c,Id,Language_Type__c,Language__c,Local_Data_No_Of_Episodes__c,Local_Data_Rating__c,'
        +'Local_Edit_Required__c,Name,Notes__c,Pre_Order_Date__c,New_Price_Code__c,Price_Tier__c,SR_Price__c,Start_Date__c,Status__c,Suppression_Date__c,'
        +'Title_Name__c,Errors__c,Video_Version__c,WS_Cost__c,Change_Context__c,Client_Title_ID__c,Announce_Override__c,Vendor_ID__c FROM CA_Upload_Record__c'
        //+' WHERE CA_Upload__c =: caUploadId and CA_upload_status__c = null order by createddate';
        +' Where CA_Upload__r.Upload_Status__c = \'Waiting to Process\' and CA_upload_status__c = null and CA_Upload__c =: caUploadId order by CA_Upload__c';
            
        List<Account> listAccount = [Select id,Name,Customer_Focus__c from Account where Type in ('Global','Local')];
        for(Account accountRec : listAccount)
            mapAccountMapNameId.put(accountRec.name,accountRec);
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<CA_Upload_Record__c> scope){
    
        if(updateFlag != null && !updateFlag)
        {
            CA_Upload__c caupload = new CA_Upload__c(id=caUploadId,Upload_Status__c='Processing');
            update caupload;
            updateFlag=true;
        }
        
        Boolean ErrorOcccured = false; 
        // Sets used to get common combination for Query.
        set<String> setTitleName = new Set<String>();
        set<String> setVVNumber = new Set<String>();
        set<String> setLangName = new Set<String>();
        set<String> setLangType = new Set<String>();
        set<String> setChannels = new Set<String>();
        set<String> setFormats = new Set<String>();
        set<String> setCountries = new Set<String>();
        set<String> setAccounts = new Set<String>();
        set<String> setContentTypes = new Set<String>();
        set<String> setPriceCodes = new Set<String>();
        
        // Maps used to compare data in client avail and release plan.
        Map<String,Title__c> mapTitleNameRecord = new Map<String,Title__c>();
        Map<String,Title__c> mapTitleVVCARecord = new Map<String,Title__c>();
        Map<String,Map<String,String>> mapLangAndType = new Map<String,Map<String,String>>();
        Map<String,Map<String,Map<String,set<String>>>> mapFormat = new Map<String,Map<String,Map<String,set<String>>>>();  //Map<Title,Map<Lang,Map<country,Set<Format>>>>
        Map<String,Map<String,Map<String,set<String>>>> mapChannel = new Map<String,Map<String,Map<String,set<String>>>>();  //Map<Title,Map<Lang,Map<country,Set<Channel>>>>
        Map<String,Map<String,Map<String,Map<String,Map<String,List<Commercial_Avail__c>>>>>> mapDates = new Map<String,Map<String,Map<String,Map<String,Map<String,List<Commercial_Avail__c>>>>>>(); //Map<Title,Map<Lang,Map<country,Map<Format,Map<Channel,Commercial_Avail__c>>>>>>
        Map<id,CA_Upload_Record__c> mapCARecords = new Map<id,CA_Upload_Record__c>();
        Map<id,Integer> countErrorMessages = new Map<id,Integer>();
        Map<id,Boolean> flagErrorMessages = new Map<id,Boolean>();
        
        Map<String,WB_RateCardHelper.PriceKeyWrapper> caPriceWrapperMap = new Map<String,WB_RateCardHelper.PriceKeyWrapper>();
        // Map contains newly created client avails to check date overlapping in new client avail
        // VV,Language,Format,Country,Channel,Account,Client Avail 
        Map<String,Map<String,Map<String,Map<String,Map<String,Map<String,List<Client_Avail__c>>>>>>> mapNewClientAvails = new Map<String,Map<String,Map<String,Map<String,Map<String,Map<String,List<Client_Avail__c>>>>>>>();
        
        // Used to create and link Client avail records.
        Map<CA_Upload_Record__c,Commercial_Avail__c> mapCARecordRPRecord = new Map<CA_Upload_Record__c,Commercial_Avail__c>();
        Map<CA_Upload_Record__c,Client_Avail__c> mapClientAvailTobeInsert = new Map<CA_Upload_Record__c,Client_Avail__c>();
        List<CA_Upload_Record__c> listTobeUpdateCARecord = new List<CA_Upload_Record__c>();
        
        //ER-003060 - Storefront Language Preferences changes - Start
        List<Language_Preference__c> languagePrefSet = new List<Language_Preference__c>();
        Map<String,String> countryLangPrefLevelMap = new Map<String,String>();
        Map<String,Map<String,Set<String>>> sfLangPrefLangMap = new Map<String,Map<String,Set<String>>>();
        Set<String> titleIdSet = new Set<String>();
        List<Available_Languages__c> availableLangSet = new List<Available_Languages__c>();
        Map<String,Map<String,Map<String,String>>> titleCountryAvlLangLevelMap = new Map<String,Map<String,Map<String,String>>>();
        
        //ER-003060 - Storefront Language Preferences changes - End
    
        // Get alll possible combination for selected CA upload records.
        for(CA_Upload_Record__c record : scope)
        {
            CAUploadIds.add(record.CA_Upload__c);
            if(record.Video_Version__c != null) setVVNumber.add(record.Video_Version__c);
            if(record.Language__c != null) setLangName.add(record.Language__c);
            if(record.Language_Type__c != null) setLangType.add(record.Language_Type__c);
            if(record.Channel__c != null) setChannels.add(record.Channel__c);
            if(record.Format__c != null) setFormats.add(record.Format__c);
            if(record.Country__c != null) setCountries.add(record.Country__c);
            if(record.Account_Name__c != null) setAccounts.add(record.Account_Name__c);
            countErrorMessages.put(record.id,1);
        }

        // Prepare Title Map Name with Id which will used to fetch id based on title Name.
        for(Title__c title : [Select id,Name,Video_Version__c,Content_Type__c,Digital_Planning__c,Clear_to_avail__c,First_Available_Date__c from Title__c where Video_Version__c in: setVVNumber])
        {
            mapTitleNameRecord.put(title.Name,title);
            mapTitleVVCARecord.put(title.Video_Version__c,title);
            setTitleName.add(title.Name);
        }
        
        //ER-003060 - Storefront Language Preferences changes - Start
        languagePrefSet = [SELECT Id,Name,Level__c,Country__c,Language__c,Type__c FROM Language_Preference__c WHERE Country__r.Name IN :setCountries AND Type__c =: Label.WB_Language_Preference_Type_Country];

        // Prepare map of Title and their related Language and Language Types.
        for(Available_Languages__c availLang : [Select id,Title__r.name,Title__r.Video_Version__c,Language__r.name,Language_Types__c,Title__c from Available_Languages__c where Title__r.Video_Version__c in: setVVNumber and Language__r.name in: setLangName and Clear_to_avail__c = true])
        {   
            //Removed old logic related to lang type - Prachi - 18-12-2015
            if(!mapLangAndType.containskey(availLang.Title__r.Video_Version__c)) 
                mapLangAndType.put(availLang.Title__r.Video_Version__c,new Map<String,String>());
            //mapLangAndType.get(availLang.Title__r.Video_Version__c).add(availLang.Language__r.name);*/
            if(mapLangAndType.get(availLang.Title__r.Video_Version__c).containskey(availLang.Language__r.name))
                mapLangAndType.get(availLang.Title__r.Video_Version__c).put(availLang.Language__r.name,'Sub & Audio');
            else    
                mapLangAndType.get(availLang.Title__r.Video_Version__c).put(availLang.Language__r.name,availLang.Language_Types__c);

            //ER-003060 - Storefront Language Preferences changes - Start
            for(Language_Preference__c langPrefRec : languagePrefSet){
                if(langPrefRec.Language__c == availLang.Language__c){
                    if(!titleCountryAvlLangLevelMap.containsKey(availLang.Title__c)){
                        titleCountryAvlLangLevelMap.put(availLang.Title__c,new Map<String,Map<String,String>>());
                    }
                    if(!titleCountryAvlLangLevelMap.get(availLang.Title__c).containsKey(langPrefRec.Country__c)){
                        titleCountryAvlLangLevelMap.get(availLang.Title__c).put(langPrefRec.Country__c,new Map<String,String>());
                    }
                    if(!titleCountryAvlLangLevelMap.get(availLang.Title__c).get(langPrefRec.Country__c).containsKey(availLang.Language__c)){
                        titleCountryAvlLangLevelMap.get(availLang.Title__c).get(langPrefRec.Country__c).put(availLang.Language__c,langPrefRec.Level__c);
                    }
                }
            }
            //ER-003060 - Storefront Language Preferences changes - End
            
        }
        Map<String,Map<String,Map<String,Local_Title__c>>> mapLocalTitle = new Map<String,Map<String,Map<String,Local_Title__c>>>();
        
        // Prepare Map of Local Data records
        for(Local_Title__c localTitle : [SELECT Language__r.name, Country__r.name,Local_Episodes__c,Local_Edit_Required__c,Num_Local_Episodes__c,Local_Rating__c,Price_Code__c,Rating_Code__c,Title__r.Video_Version__c FROM Local_Title__c where Title__r.Video_Version__c in: setVVNumber AND External_Company__c = Null])
        {
            if(!mapLocalTitle.containskey(localTitle.Title__r.Video_Version__c))
                mapLocalTitle.put(localTitle.Title__r.Video_Version__c,new Map<String,Map<String,Local_Title__c>>());
            if(!mapLocalTitle.get(localTitle.Title__r.Video_Version__c).containskey(localTitle.Language__r.name))
                mapLocalTitle.get(localTitle.Title__r.Video_Version__c).put(localTitle.Language__r.name,new Map<String,Local_Title__c>());                
            if(!mapLocalTitle.get(localTitle.Title__r.Video_Version__c).get(localTitle.Language__r.name).containskey(localTitle.Country__r.name))
                mapLocalTitle.get(localTitle.Title__r.Video_Version__c).get(localTitle.Language__r.name).put(localTitle.Country__r.name,localTitle);
        }             
        // Prepare Maps which will used to compare the CA upload records with Releas plans records.
        for(Commercial_Avail__c releaseplan : [Select id,Title__r.Video_Version__c,name,Country_Lookup__c,Languages__c,Languages__r.Name,Language_Type__c,Country_Lookup__r.Name,Format__c,Channel__c,Title__r.Content_Type__c,Start_Date__c,
                                End_Date__c,Status__c,Local_Title__r.Price_Code__c,Local_Title__r.Local_Edit_Required__c,Local_Title__r.Num_Local_Episodes__c,Local_Title__r.Local_Rating__c,Exclusive_Date__c
                                from Commercial_Avail__c where Title__c in: mapTitleNameRecord.values() 
                                AND Languages__r.Name in : setLangName AND Language_Type__c in: setLangType AND Country_Lookup__r.Name in: setCountries])
        {
            if(!mapFormat.containskey(releaseplan.Title__r.Video_Version__c))
            {
                mapFormat.put(releaseplan.Title__r.Video_Version__c,new Map<String,Map<String,set<String>>>());
                mapChannel.put(releaseplan.Title__r.Video_Version__c,new Map<String,Map<String,set<String>>>());
                mapDates.put(releaseplan.Title__r.Video_Version__c,new Map<String,Map<String,Map<String,Map<String,List<Commercial_Avail__c>>>>>());
            }
            if(!mapFormat.get(releaseplan.Title__r.Video_Version__c).containskey(releaseplan.Languages__r.Name))
            {
                mapFormat.get(releaseplan.Title__r.Video_Version__c).put(releaseplan.Languages__r.Name,new Map<String,set<String>>());
                mapChannel.get(releaseplan.Title__r.Video_Version__c).put(releaseplan.Languages__r.Name,new Map<String,set<String>>());
                mapDates.get(releaseplan.Title__r.Video_Version__c).put(releaseplan.Languages__r.Name,new Map<String,Map<String,Map<String,List<Commercial_Avail__c>>>>());
            }
            if(!mapFormat.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).containskey(releaseplan.Country_Lookup__r.Name))
            {
                mapFormat.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).put(releaseplan.Country_Lookup__r.Name,new set<String>());
                mapChannel.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).put(releaseplan.Country_Lookup__r.Name,new set<String>());
                mapDates.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).put(releaseplan.Country_Lookup__r.Name,new Map<String,Map<String,List<Commercial_Avail__c>>>());
            }
            mapFormat.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).add(releaseplan.Format__c);
            mapChannel.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).add(releaseplan.Channel__c);
            if(!mapDates.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).containskey(releaseplan.Format__c))
                mapDates.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).put(releaseplan.Format__c,new Map<String,List<Commercial_Avail__c>>());
            if(!mapDates.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).get(releaseplan.Format__c).containskey(releaseplan.Channel__c))
                mapDates.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).get(releaseplan.Format__c).put(releaseplan.Channel__c,new List<Commercial_Avail__c>());
            mapDates.get(releaseplan.Title__r.Video_Version__c).get(releaseplan.Languages__r.Name).get(releaseplan.Country_Lookup__r.Name).get(releaseplan.Format__c).get(releaseplan.Channel__c).add(releaseplan);
        }
        
        // Get Storefront records to perform storefront related validation
        Map<String,Map<string,Set<String>>> mapCountryAccountChannelsSF = new Map<String,Map<string,Set<String>>>();
        Map<String,Map<string,Set<String>>> mapCountryAccountFormatsSF = new Map<String,Map<string,Set<String>>>();
        Map<String,Map<string,Set<String>>> mapCountryAccountCTsSF = new Map<String,Map<string,Set<String>>>();
        Map<String,Map<string,Agreement__c>> mapCountryAccountSF = new Map<String,Map<string,Agreement__c>>();
        Map<Id,Id> mapCAUploadRecordIdSFId = new Map<Id,Id>();
        
        //added by Tejasvini Mar Release 2018
        Map<String,Agreement__c> mapStorefront = new Map<String,Agreement__c>();

        for(Agreement__c sf : [Select id,Status__c,Channel_Picklist__c,Format__c,Content_Type__c,Country__r.Name,Account__c,Account__r.Name,Selected_Combination__c,CRM_Storefront__c,
                               (SELECT Id, Country__c, Language__c, Level__c, Type__c,Account__c FROM Language_Preferences__r WHERE Type__c =: Label.WB_Language_Preference_Type_Storefront) //ER-003060 - Storefront Language Preferences changes - inner Query added
                               from Agreement__c where Country__r.name in: setCountries AND Account__r.Name in: setAccounts])
        {
            if(!mapCountryAccountSF.containskey(sf.Country__r.Name))
                mapCountryAccountSF.put(sf.Country__r.Name,new Map<string,Agreement__c>());
            mapCountryAccountSF.get(sf.Country__r.Name).put(sf.Account__r.Name,sf);
            
            
            if(sf.Channel_Picklist__c != null)
            {
                if(!mapCountryAccountChannelsSF.containskey(sf.Country__c))
                    mapCountryAccountChannelsSF.put(sf.Country__r.Name,new Map<string,Set<String>>());
                if(!mapCountryAccountChannelsSF.get(sf.Country__r.Name).containskey(sf.Account__r.Name))
                    mapCountryAccountChannelsSF.get(sf.Country__r.Name).put(sf.Account__r.Name,new Set<String>());
                mapCountryAccountChannelsSF.get(sf.Country__r.Name).get(sf.Account__r.Name).addall(sf.Channel_Picklist__c.split(';'));
            }
            if(sf.Format__c != null)
            {
                if(!mapCountryAccountFormatsSF.containskey(sf.Country__r.Name))
                    mapCountryAccountFormatsSF.put(sf.Country__r.Name,new Map<string,Set<String>>());
                if(!mapCountryAccountFormatsSF.get(sf.Country__r.Name).containskey(sf.Account__r.Name))
                    mapCountryAccountFormatsSF.get(sf.Country__r.Name).put(sf.Account__r.Name,new Set<String>());
                mapCountryAccountFormatsSF.get(sf.Country__r.Name).get(sf.Account__r.Name).addall(sf.Format__c.split(';'));
            }
            if(sf.Content_Type__c != null)
            {
                if(!mapCountryAccountCTsSF.containskey(sf.Country__r.Name))
                    mapCountryAccountCTsSF.put(sf.Country__r.Name,new Map<string,Set<String>>());
                if(!mapCountryAccountCTsSF.get(sf.Country__r.Name).containskey(sf.Account__r.Name))
                    mapCountryAccountCTsSF.get(sf.Country__r.Name).put(sf.Account__r.Name,new Set<String>());
                mapCountryAccountCTsSF.get(sf.Country__r.Name).get(sf.Account__r.Name).addall(sf.Content_Type__c.split(';'));
            }

            //ER-003060 - Storefront Language Preferences changes - Start
            if(sf.Language_Preferences__r != Null && sf.Language_Preferences__r.size()>0){
                Integer i=0;
                Set<String> higherLangSet = new Set<String>();
                Language_Preference__c prevLangPrefRecord = new Language_Preference__c();
                String prevLanguageId = '';
                for(Language_Preference__c langRec : sf.Language_Preferences__r){
                   
                  //Map - StorefrontId - Language - Set of Higher Language

                   if(!sfLangPrefLangMap.containsKey(sf.Id)){
                       sfLangPrefLangMap.put(sf.Id,new Map<String,Set<String>>());
                   }
                   if(!sfLangPrefLangMap.get(sf.Id).containsKey(langRec.Language__c)){
                       sfLangPrefLangMap.get(sf.Id).put(langRec.Language__c,new Set<String>());
                   }
                   if(i != 0 && (higherLangSet != Null && higherLangSet.size()>0) && (prevLangPrefRecord.Level__c < langRec.Level__c)){
                       sfLangPrefLangMap.get(sf.Id).get(langRec.Language__c).addAll(higherLangSet);
                   }
                   higherLangSet.add(langRec.Language__c);
                   prevLangPrefRecord = langRec;
                   i++;
               }
               
           }  //ER-003060 - Storefront Language Preferences changes - End 
        }
        
        setTitleName.clear();
        setVVNumber.clear();
        setLangName.clear();
        setLangType.clear();
        
        
        // Get all values available in Category Picklist.
        Set<String> setCategogyPicklistValues = new Set<String>();
        for( Schema.PicklistEntry f : Client_Avail__c.Local_Data_Category_Picklist__c.getDescribe().getPicklistValues())
            setCategogyPicklistValues.add(f.getValue());
            
        // Get all values available in Change Context Picklist.
        Set<String> setChangeContextPicklistValues = new Set<String>();
        for( Schema.PicklistEntry f : Client_Avail__c.Change_Context__c.getDescribe().getPicklistValues())
            setChangeContextPicklistValues.add(f.getValue());
         
         // Get all values available in Announce override Picklist.
        Set<String> setAnnOverridePicklistValues = new Set<String>();
        for( Schema.PicklistEntry f : Client_Avail__c.Announce_Override__c.getDescribe().getPicklistValues())
            setAnnOverridePicklistValues.add(f.getValue());
            
        for(CA_Upload_Record__c record : scope){
            if(mapTitleVVCARecord!= null && mapTitleVVCARecord.containskey(record.Video_Version__c) && record.Video_Version__c != null){
                setContentTypes.add(mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c);
                if(mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c.contains('Season')){
                    setContentTypes.add('Episode');
                }
            }
        }
         
        // Get Matching Pricing records for Validation.
        Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>> mapPricingRecords = getPricingRecords(setAccounts,setChannels,setFormats,setCountries,setContentTypes);
        
        
        // Process All CA upload records and give proper errors if any difference or looks like missing.
        for(CA_Upload_Record__c record : scope)
        {
            String Error_Messages='';
            Integer Count=countErrorMessages.get(record.id);
            flagErrorMessages.put(record.id,false);
            try{
            
            // Check for Country
            if(record.Country__c != null && !mapCountryMapNameId.containskey(record.Country__c))
                Error_Messages += count++ + Label.WB_Batch_Error_Country_Not_Available+'\n';
            
            // Check if country Territory is matching with User's terriotory
            if(loggedInUser.Profile.Name ==System.Label.WB_Territory_Release_Planner && loggedInUser.Territory__c != null && loggedInUser.Territory__c != mapCountryMapNameId.get(record.Country__c).Territory__c)
                Error_Messages += count++ + Label.WB_Batch_Error_Territory_Not_Matching+'\n';    
                
            // Check for Language
            if(record.Language__c != null && !mapLanguageMapNameId.containskey(record.Language__c))
                Error_Messages += count++ + Label.WB_Batch_Error_Language_Not_Available+'\n';
                
            // Added all Manadatory fields related validations.
            // Give error if Video version is not available.
            if(record.Video_Version__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_VV_Mandatory+'\n';
                
            // Give error if Country is not available.
            if(record.Country__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Country_Mandatory+'\n';
                
            // Give error if Account is not available.
            if(record.Account_Name__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Account_Mandatory+'\n';
            
            // Give error if Start Date is not available.
            if(record.Start_Date__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_StartDate_Mandatory+'\n';
            
            // Give error if End Date is not available.
            if(record.End_Date__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_EndDate_Mandatory+'\n';
            
            // Give error if Status is not available.
            if(record.Status__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Status_Mandatory+'\n';
            
            // Give error if Language Type is not available.
            if(record.Language_Type__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Language_Type_Mandatory+'\n';
            
            // Give error if Format is not available.
            if(record.Format__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Format_Mandatory+'\n';
            
            // Give error if Channel is not available.
            if(record.Channel__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Channel_Mandatory+'\n';
               
            // Check for Account, give error it is active or not
            /*-----------------Commenting For SINC0999957-----------------
            if(record.Account_Name__c != null && mapAccountMapNameId != null && mapAccountMapNameId.containskey(record.Account_Name__c))  
            {
                if(mapAccountMapNameId.get(record.Account_Name__c).Customer_Focus__c != 'Active')
                    Error_Messages += count++ + Label.WB_Batch_Error_Account_Not_Active+'\n';  
            }
            else if(record.Account_Name__c != null)
                Error_Messages += count++ + Label.WB_Batch_Error_Account_Not_Available+'\n';  
            /------------------Commenting For SINC0999957-----------------*/
            
            
            // Check for existing Title present in salesforce or not
            if(mapTitleVVCARecord!= null && mapTitleVVCARecord.containskey(record.Video_Version__c) && record.Video_Version__c != null)
            {
                //setContentTypes.add(mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c);
                if(mapLangAndType != null && mapLangAndType.containsKey(record.Video_Version__c) && mapLangAndType.get(record.Video_Version__c).containsKey(record.Language__c) )
                {
                    if(record.Language_Type__c != null && record.Language__c != null && !mapLangAndType.get(record.Video_Version__c).get(record.Language__c).contains(record.Language_Type__c))
                        Error_Messages += count++ + Label.WB_Batch_Error_Language_Not_Matching+'\n';
                }
                else if(record.Language_Type__c != null && record.Language__c != null)
                    Error_Messages += count++ + Label.WB_Batch_Error_Language_Not_Matching+'\n';
            }
            else if((mapTitleVVCARecord == null || !mapTitleVVCARecord.containsKey(record.Video_Version__c)) && record.Video_Version__c != null)
                Error_Messages += count++ + Label.WB_Batch_Error_VV_Not_Available+'\n';
            
            // Check for release plan record
            if(Error_Messages == '')
            {
                /*if(mapFormat != null &&
                    mapFormat.get(record.Video_Version__c) != null &&
                    mapFormat.get(record.Video_Version__c).get(record.Language__c) != null &&
                    mapFormat.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c) != null)
                {
                    if(!mapFormat.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).contains(record.Format__c))
                        Error_Messages += count++ + Label.WB_Batch_Error_RP_Format_Wrong+'\n';
                }
                if(mapChannel != null &&
                    mapChannel.get(record.Video_Version__c) != null &&
                    mapChannel.get(record.Video_Version__c).get(record.Language__c) != null &&
                    mapChannel.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c) != null)
                {
                    if(!mapChannel.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).contains(record.Channel__c))
                        Error_Messages += count++ + Label.WB_Batch_Error_RP_Channel_Wrong+'\n';
                }*/
                
                /*if(Error_Messages == '')
                {*/
                    Boolean RPStatusVR = false;
                    Boolean RPMatching=false;
                    Boolean RPFirstAvailIncorrect = false;
                    if(mapDates != null 
                    && mapDates.get(record.Video_Version__c) != null 
                    && mapDates.get(record.Video_Version__c).get(record.Language__c) != null 
                    && mapDates.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c) != null 
                    && mapDates.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).get(record.Format__c) != null 
                    && mapDates.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c) != null
                    && mapDates.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).size() > 0)
                    {   
                        for(Commercial_Avail__c matchingReleasePlan : mapDates.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c))
                        {
                            if(matchingReleasePlan.Start_Date__c <= record.Start_Date__c &&
                               matchingReleasePlan.End_Date__c >= record.End_Date__c)
                            {
                               if(mapTitleVVCARecord.get(record.Video_Version__c).First_Available_Date__c != null && matchingReleasePlan.Exclusive_Date__c < mapTitleVVCARecord.get(record.Video_Version__c).First_Available_Date__c)
                                    RPFirstAvailIncorrect = true;
                                mapCARecordRPRecord.put(record,matchingReleasePlan); 
                                RPMatching=true;
                                if(matchingReleasePlan.Status__c == 'Confirmed' || matchingReleasePlan.Status__c == 'Tentative')
                                {
                                    setPriceCodes.add(matchingReleasePlan.Local_Title__r.Price_Code__c);
                                    RPStatusVR = true;
                                    break;
                                }
                            }
                        }
                        if(!RPMatching && !RPStatusVR)
                            Error_Messages += count++ + Label.WB_Batch_Error_CA_Dates_Within_RP_Dates+'\n';
                        if(RPMatching && !RPStatusVR)
                            Error_Messages += count++ + Label.WB_Batch_Error_RP_should_Confirmed_or_Tentative+'\n';
                    }   
                    if(!RPMatching && Error_Messages == '')
                        Error_Messages += count++ + Label.WB_Batch_Error_RP_Not_Found+'\n';
                    if(mapTitleVVCARecord.get(record.Video_Version__c).Digital_Planning__c != 'Yes')
                        Error_Messages += count++ + Label.WB_Batch_Error_Title_Digital_Planning_Error+'\n';
                    if(!mapTitleVVCARecord.get(record.Video_Version__c).Clear_to_avail__c)
                        Error_Messages += count++ + Label.WB_Batch_Error_Title_Clear_to_Avail_Mandatory+'\n'; 
                    if(RPFirstAvailIncorrect)
                        Error_Messages += count++ + Label.WB_Batch_Incorrect_FirstAvailDate+'\n';                     
              
            }
            
            // If release plan not available and local data record present then  preform Validations on comparision of Local Data fields matches
            if(!mapCARecordRPRecord.containsKey(record) && record.Video_Version__c != null && (record.Local_Edit_Required__c != null || record.Local_Data_Rating__c != null || record.Local_Data_No_Of_Episodes__c != null))
            {
                if(mapLocalTitle != null && 
                   mapLocalTitle.containsKey(record.Video_Version__c) && 
                   mapLocalTitle.get(record.Video_Version__c).containsKey(record.Language__c) &&
                   mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).containsKey(record.Country__c))
                {
                    Local_Title__c localTitle = mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c);
                    if(record.Local_Edit_Required__c != null && localTitle.Local_Edit_Required__c != record.Local_Edit_Required__c) 
                        Error_Messages += count++ + Label.WB_Batch_Error_Local_Data_Req_not_matching_with_Local_Data+'\n';  
                    if(record.Local_Data_Rating__c != null && localTitle.Local_Rating__c != record.Local_Data_Rating__c) 
                        Error_Messages += count++ + Label.WB_Batch_Error_Local_Data_Rating_not_matching_with_Local_Data+'\n';  
                    if(record.Local_Data_No_Of_Episodes__c != null && localTitle.Num_Local_Episodes__c != Decimal.valueof(record.Local_Data_No_Of_Episodes__c)) 
                        Error_Messages += count++ + Label.WB_Batch_Error_Num_od_Episode_not_matching_with_Local_Data+'\n';
                }
            }
            
            
            
            
            // Check status for inserting client avail
            if(record.Status__c != 'Draft' && record.Status__c != 'Confirmed' && record.Status__c != 'Tentative')
                Error_Messages += count++ + Label.WB_Batch_Error_CA_Status_must_be_Draft+'\n';
            
            //Release Plan Status must be confirmed if CA status is confirmed  added by Tejasvini ER   
            if(mapCARecordRPRecord.get(record) != null && record.Status__c == 'Confirmed' && mapCARecordRPRecord.get(record).Status__c != 'Confirmed')
                Error_Messages += count++ + ' . Status of Release Plan corresponding to Client Avail must be Confirmed'+'\n';
                
            // Validation to check if Active storefront available or not if available then assign storefront to Client Avail to field.
            if(mapCountryAccountSF != null && mapCountryAccountSF.containskey(record.Country__c) && mapCountryAccountSF.get(record.Country__c).containskey(record.Account_Name__c) && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c) != null)
            {   
                Boolean isStorefrontError = false;
                // Check channel is available on matching Storefront
                if(record.Channel__c != null && mapCountryAccountChannelsSF == null || mapCountryAccountChannelsSF.size() == 0){
                    isStorefrontError = true;
                    Error_Messages += count++ + Label.WB_Batch_Error_Channel_wrong_in_Storefront+'\n';
                }else if(record.Channel__c != null && mapCountryAccountChannelsSF != null && mapCountryAccountChannelsSF.containskey(record.Country__c) && mapCountryAccountChannelsSF.get(record.Country__c).containskey(record.Account_Name__c) && !mapCountryAccountChannelsSF.get(record.Country__c).get(record.Account_Name__c).contains(record.Channel__c)){
                    isStorefrontError = true;
                    Error_Messages += count++ + Label.WB_Batch_Error_Channel_wrong_in_Storefront+'\n';
                }
                
                // Check Format is available on matching Storefront    
                if(record.Format__c != null && mapCountryAccountFormatsSF == null || mapCountryAccountFormatsSF.size() == 0){
                    isStorefrontError = true;
                    Error_Messages += count++ + Label.WB_Batch_Error_Format_wrong_in_Storefront+'\n';
                }else if(record.Format__c != null && mapCountryAccountFormatsSF != null && mapCountryAccountFormatsSF.containskey(record.Country__c) && mapCountryAccountFormatsSF.get(record.Country__c).containskey(record.Account_Name__c) && !mapCountryAccountFormatsSF.get(record.Country__c).get(record.Account_Name__c).contains(record.Format__c)){
                    isStorefrontError = true;
                    Error_Messages += count++ + Label.WB_Batch_Error_Format_wrong_in_Storefront+'\n';
                }
                // Check content type of VV is available on matching Storefront. 
                if(record.Video_Version__c != null && mapTitleVVCARecord.get(record.Video_Version__c) != null)
                {
                    if(mapCountryAccountCTsSF == null || mapCountryAccountCTsSF.size() == 0){
                        isStorefrontError = true;
                        Error_Messages += count++ + Label.WB_Batch_Error_CT_wrong_in_Storefront+'\n';
                    }else if(mapCountryAccountCTsSF.containskey(record.Country__c) && mapCountryAccountCTsSF.get(record.Country__c).containskey(record.Account_Name__c) && !mapCountryAccountCTsSF.get(record.Country__c).get(record.Account_Name__c).contains(mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c) ){
                        isStorefrontError = true;
                        Error_Messages += count++ + Label.WB_Batch_Error_CT_wrong_in_Storefront+'\n'; 
                    }
                }
                
                if(mapCountryAccountSF != null && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).Status__c == 'Active'){
                    mapCAUploadRecordIdSFId.put(record.id,mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).id);
                    //added by Tejasvini Mar Release 2018
                    if(!isStorefrontError){
                        mapStorefront.put(record.id,mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c));
                    }
                    
                    
                }else
                    Error_Messages += count++ + Label.WB_Batch_Error_SF_Status+'\n';
            }
            else if(record.Country__c != null && record.Account_Name__c != null && record.Video_Version__c != null)
                Error_Messages += count++ + Label.WB_Batch_Error_Storefront_Not_Available+'\n';
    
            
            // Add basic validation rules for client avail here.
            if(record.Start_Date__c > record.End_Date__c)
                Error_Messages += count++ + Label.WB_Batch_Error_Start_Date_not_End_Date+'\n';   
                
            // Category picklist value validation
            if(record.Category__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_Category_Field_Mandatory+'\n';
            else if(setCategogyPicklistValues != null && !setCategogyPicklistValues.contains(record.Category__c))
                Error_Messages += count++ + Label.WB_Batch_Error_Category_value_is_wrong+'\n';
            
            // Change Context Picklist value validation
            if(setChangeContextPicklistValues != null && record.Change_Context__c != null && !setChangeContextPicklistValues.contains(record.Change_Context__c))
                Error_Messages += count++ + Label.WB_Batch_Error_Change_Context_value_is_wrong+'\n';
            
            // Check Announce Override value validation
            if(setAnnOverridePicklistValues != null && record.Announce_Override__c != null && !setAnnOverridePicklistValues.contains(record.Announce_Override__c))
                Error_Messages += count++ + Label.WB_Batch_Error_Announce_Override_value_is_wrong+'\n';
            
            
            Boolean isMatchPresent = false;
            
            //New Price Code changes Start
            
            
                
                // Need to perform all validations comes through excel sheet.
            
            //WS Cost and Price Tier are mutually exclusive.
            if(record.WS_Cost__c != null && record.Price_Tier__c != null)
                Error_Messages += count++ + Label.WB_Batch_Error_Enter_Either_Price_Tier_or_WS_cost+'\n';
               
            //Episode WS Cost and Episode Price Tier are mutually exclusive.
            if(record.Episode_Price_Tier__c != null && record.Episode_WS_Cost__c != null)
                Error_Messages += count++ + Label.WB_Batch_Error_Enter_Either_Price_Tier_or_WS_cost_Episode+'\n';
                
            //New Price Code present other pricing values should be blank.
             /*ER-003373--> if(record.New_Price_Code__c != null &&  (record.WS_Cost__c != null||record.Price_Tier__c != null ||record.Episode_Price_Tier__c != null||record.Episode_WS_Cost__c != null || record.SR_Price__c != null || record.Episode_SR_Price__c != null)) */
            /*ER-003373--> New Code -- if Condition */
            if(record.New_Price_Code__c != null &&  (record.WS_Cost__c != null||record.Price_Tier__c != null ||record.Episode_Price_Tier__c != null||record.Episode_WS_Cost__c != null || record.Episode_SR_Price__c != null))
                Error_Messages += count++ + '. New Price Code value is present other Pricing values must be blank.' +'\n';
                
                
            //If WS Cost present, validate WS Code 
            if(record.WS_Cost__c != null && record.Price_Tier__c == null && record.New_Price_Code__c == null){
                if(record.WS_Cost__c != null && Decimal.valueof(record.WS_Cost__c) < 0){
                        Error_Messages += count++ + Label.WB_Batch_Error_WS_cost_should_be_positive_number+'\n';
                    }
            }
            
            Boolean isCRMCountrySF = false;
            if(mapCountryAccountSF != Null && mapCountryAccountSF.containskey(record.Country__c) && mapCountryAccountSF.get(record.Country__c).containskey(record.Account_Name__c) && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c) != null && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).CRM_Storefront__c ){
                isCRMCountrySF = true;
            }     
            //If Price Tier present, validate Price Tier
            if(record.WS_Cost__c == null && record.Price_Tier__c != null && record.New_Price_Code__c == null){
                if(mapCARecordRPRecord.get(record) != null){
                    isMatchPresent = validatePricing(record,mapPricingRecords,mapCARecordRPRecord,'Price Tier',null); 
                    if(!isMatchPresent && !(isCRMCountrySF)){
                        Error_Messages += count++ + '. No match found for the given Price Tier in the Pricing table.'+'\n';  
                    }
                }
                
            }
            
            if(record.Episode_WS_Cost__c == Null && record.Episode_Price_Tier__c != Null && (mapCARecordRPRecord.get(record) != null && mapCARecordRPRecord.get(record).Title__r.Content_Type__c.contains('Season'))){
                isMatchPresent = validatePricing(record,mapPricingRecords,mapCARecordRPRecord,'Episode Price Tier',null); 
                if(!isMatchPresent && !(isCRMCountrySF)){
                    Error_Messages += count++ + '. No match found for the given Episode Price Tier in the Pricing table.'+'\n';  
                }
                
            }
                    
            //New Price Code Present then check whether it is valid.
            if(record.WS_Cost__c == null && record.Price_Tier__c == null && record.New_Price_Code__c != null){
                if(mapCARecordRPRecord.get(record) != null){
                    isMatchPresent = validatePricing(record,mapPricingRecords,mapCARecordRPRecord,'New Price Code',null);
                    if(!isMatchPresent){
                        Error_Messages += count++ + '. No match found for the given New Price Code in the Pricing table.'+'\n'; 
                    }
                    
                }
                
                 
                 //New Price Code, WS Cost and Price Tier is null then check Local Title.Price Code value whether its valid.   
            }else if(record.WS_Cost__c == null && record.Price_Tier__c == null && record.New_Price_Code__c == null){
                if(mapLocalTitle != null && 
                   mapLocalTitle.containsKey(record.Video_Version__c) && 
                   mapLocalTitle.get(record.Video_Version__c).containsKey(record.Language__c) &&
                   mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).containsKey(record.Country__c))
                {
                    Local_Title__c localTitle = mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c);
                    
                     //Error to enter atleast one value.   
                    if(localTitle.Price_Code__c == null){
                        Error_Messages += count++ + '. Either New Price Code value or Local Title Price Code Value must be present.'+'\n';
                        
                    }else{
                        
                        if(mapCARecordRPRecord.get(record) != null){
                            isMatchPresent = validatePricing(record,mapPricingRecords,mapCARecordRPRecord,'Local Title Price Code',localTitle);
                            if(!isMatchPresent){
                                Error_Messages += count++ + '. No match found for the given Local Title Price Code in the Pricing table.'+'\n'; 
                            }
                        }
                        
                        
                    }
                        
                }
                
            }
            
                //New Price Code Changes End
            
                
               
            /*if(record.WS_Cost__c != null && Decimal.valueof(record.WS_Cost__c) < 0)
                Error_Messages += count++ + Label.WB_Batch_Error_WS_cost_should_be_positive_number+'\n';*/
             
            /* Removed validation as per discussion with Nalin 12-10-2015
            if(record.Local_Data_No_Of_Episodes__c == null && mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c != 'Season')
                Error_Messages += count++ + Label.WB_Batch_Error_Season_and_no_of_Episode_validation+'\n';*/
            if(record.Local_Data_No_Of_Episodes__c != null && Decimal.valueof(record.Local_Data_No_Of_Episodes__c) < 0)
                Error_Messages += count++ + Label.WB_Batch_Error_no_of_Episode_Valid_number+'\n';
            
            // Removed this validation - Prachi - 18-12-2015
            /* Episode related validations from Excel sheet
            if(mapTitleVVCARecord.get(record.Video_Version__c) != null && (mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c == 'Episode' || mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c == 'Season' ))
            {
                if(record.Episode_Price_Tier__c == null && record.Episode_WS_Cost__c == null)
                    Error_Messages += count++ + Label.WB_Batch_Error_Episode_VV_should_have_values+'\n';
                if(record.Price_Tier__c != null || record.WS_Cost__c != null)
                    Error_Messages += count++ + Label.WB_Batch_Error_Episode_VV_Validation+'\n';
            }*/
            
            if(record.Video_Version__c != null && mapTitleVVCARecord.get(record.Video_Version__c) != null)
            {
                    /* Changed condition as per validation rule on client avail - Prachi - 18-12-2015
                    if(record.Episode_Price_Tier__c != null || record.Episode_WS_Cost__c != null)*/
                    if(mapTitleVVCARecord.get(record.Video_Version__c).Content_Type__c != 'Season' && (record.Episode_Price_Tier__c != null || record.Episode_WS_Cost__c != null))
                        Error_Messages += count++ + Label.WB_Batch_Error_VV_not_Episode_Validation+'\n';
                    //if(record.Price_Tier__c == null && record.WS_Cost__c == null )
                        //Error_Messages += count++ + Label.WB_Batch_Error_VV_not_Episode_Validation2+'\n';
                        
            }
            
            // Removed vice versa condition - Prachi - 18-12-2015
            if(record.Suppression_Date__c != null)
            {
                if(record.Pre_Order_Date__c == null)
                Error_Messages += count++ + Label.WB_Batch_Error_APO_Date_Validation+'\n';    
            }
            // Removed else - Prachi - 18-12-2015
            if(record.Pre_Order_Date__c != null && record.Suppression_Date__c != null && record.Suppression_Date__c < record.Pre_Order_Date__c)
                Error_Messages += count++ + Label.WB_Batch_Error_APO_Date_Validation2+'\n';
            
            if(record.Start_Date__c != null && record.Suppression_Date__c != null && record.Start_Date__c < record.Suppression_Date__c)
                Error_Messages += count++ + Label.WB_Batch_Error_APO_Date_Validation3+'\n';

             
                
            if(Error_Messages != '')
            {
                flagErrorMessages.put(record.id,true);
                CA_Upload_Record__c rec = new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Failed',Errors__c=Error_Messages);
                if(mapTitleVVCARecord.containsKey(record.Video_Version__c))
                    rec.Title_Name__c = mapTitleVVCARecord.get(record.Video_Version__c).Name;
                mapCARecords.put(record.id,rec);
                
                //listTobeUpdateCARecord.add(new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Failed',Errors__c=Error_Messages));
            }
            countErrorMessages.put(record.id,count);
        }catch(Exception e)
        {
            CA_Upload_Record__c rec = new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Failed',Errors__c=e.getmessage()+'\n'+Error_Messages);
            update rec;
        }
        
            
        }
        
        // Get all existing client avails available for matched Release plans
        Map<Id,List<Client_Avail__c>> mapRPClientAvailList = new Map<Id,List<Client_Avail__c>>();
        List<Client_Avail__C> ListAllOtherClientAvails = new List<Client_Avail__C>();
        for(Client_Avail__C oldClientAvail : [Select id,Name,Commercial_Avail__c,Start_Date__c,End_Date__c,Client__r.Name from Client_Avail__c where Commercial_Avail__c in: mapCARecordRPRecord.values()])
        {
            if(!mapRPClientAvailList.containskey(oldClientAvail.Commercial_Avail__c))
                mapRPClientAvailList.put(oldClientAvail.Commercial_Avail__c,new List<Client_Avail__c>());
            mapRPClientAvailList.get(oldClientAvail.Commercial_Avail__c).add(oldClientAvail);
        }
        // Get Matching Pricing records for Validation.
       // Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>> mapPricingRecords = getPricingRecords(setAccounts,setChannels,setFormats,setCountries,setContentTypes);
        
        // Validations performed with Existing Client Avails and Passes to create an Client Avail Record.
        for(CA_Upload_Record__c record : mapCARecordRPRecord.keySet())
        {
            String Error_Messages='';
            Integer Count=countErrorMessages.get(record.id);
            Client_Avail__c newClientAvail = new Client_Avail__c();
            try{
            
            // Validations on comparision of Local Data fields matches
            if(record.Local_Edit_Required__c != null || record.Local_Data_Rating__c != null || record.Local_Data_No_Of_Episodes__c != null)
            {
                Commercial_Avail__c matchingReleaseplan = mapCARecordRPRecord.get(record);
                if(record.Local_Edit_Required__c != null && matchingReleaseplan.Local_Title__r.Local_Edit_Required__c != record.Local_Edit_Required__c) 
                    Error_Messages += count++ + Label.WB_Batch_Error_Local_Data_Req_not_matching_with_Local_Data+'\n';  
                if(record.Local_Data_Rating__c != null && matchingReleaseplan.Local_Title__r.Local_Rating__c != record.Local_Data_Rating__c) 
                    Error_Messages += count++ + Label.WB_Batch_Error_Local_Data_Rating_not_matching_with_Local_Data+'\n';  
                if(record.Local_Data_No_Of_Episodes__c != null && matchingReleaseplan.Local_Title__r.Num_Local_Episodes__c != Decimal.valueof(record.Local_Data_No_Of_Episodes__c)) 
                    Error_Messages += count++ + Label.WB_Batch_Error_Num_od_Episode_not_matching_with_Local_Data+'\n';
            }
            
            // Validation regarding Date Overlapping.
            if(mapRPClientAvailList.get(mapCARecordRPRecord.get(record).id) != null && mapRPClientAvailList.get(mapCARecordRPRecord.get(record).id).size() > 0)
            {
                for(Client_Avail__c existingClientAvail : mapRPClientAvailList.get(mapCARecordRPRecord.get(record).id))
                {
                    if(existingClientAvail.Client__r.Name == record.Account_Name__c)
                    {
                        if(record.Start_Date__c == existingClientAvail.Start_Date__c || record.End_Date__c == existingClientAvail.End_Date__c)
                        {
                            Error_Messages += Count++ + Label.WB_Batch_Error_CA_available_for_Dates+'\n';
                            break;
                        }
                        else if(!(record.Start_Date__c >= existingClientAvail.End_Date__c || record.End_Date__c <= existingClientAvail.Start_Date__c))
                        {    
                            Error_Messages += Count++ + Label.WB_Batch_Error_CA_dates_Overlapping+'\n';  
                            break;
                        }
                    }
                }
            }
            
            // Validation if Price Tier is not null and Status is Confirmed. 
           /* if(record.Price_Tier__c != null && record.Price_Tier__c != '' && record.Status__c=='Confirmed')
            {
                Boolean pricingAvailable = false;
                String AccountId = String.valueof(mapAccountMapNameId.get(record.Account_Name__c).id);
                if(mapPricingRecords != null 
                && mapPricingRecords.get(record.Account_Name__c) != null 
                && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c) != null 
                && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c) != null 
                && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c) != null 
                && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get(mapCARecordRPRecord.get(record).Title__r.Content_Type__c) != null)
                {
                    for(Pricing__c MatchingPricing : mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get(mapCARecordRPRecord.get(record).Title__r.Content_Type__c))
                    {
                        if(MatchingPricing.Price_Tier__c == record.Price_Tier__c)
                        {    
                            pricingAvailable = true;
                            newClientAvail.Pricing__c = MatchingPricing.Id;
                            break;
                        }
                    }
                    if(pricingAvailable)
                        newClientAvail.Price_Tier_Text__c=record.Price_Tier__c;
                    else
                        Error_Messages += count++ + '. '+Label.WB_Batch_Error_Price_Tier_Value_Not_Matching+'.\n';
                }
                else
                    Error_Messages += count++ + Label.WB_Batch_Error_No_Pricing_Entry+'\n';
                
            }*/
            
            // Check for Date overlapping with new Client Avails.   
            // VV,Language,Format,Country,Channel,Account,Client Avail 
            if(mapNewClientAvails != null &&
               mapNewClientAvails.get(record.Video_Version__c) != null &&
               mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c) != null &&
               mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c) != null &&
               mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c) != null &&
               mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).get(record.Channel__c) != null &&
               mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).get(record.Channel__c).get(record.Account_Name__c) != null)
            {
                   for(Client_Avail__c newCA : mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).get(record.Channel__c).get(record.Account_Name__c))
                   {
                        if(record.Start_Date__c == newCA.Start_Date__c || record.End_Date__c == newCA.End_Date__c)
                        {
                            Error_Messages += Count++ + Label.WB_Batch_Error_CA_available_for_Dates+'\n';
                            break;
                        }
                        else if(!(record.Start_Date__c >= newCA.End_Date__c || record.End_Date__c <= newCA.Start_Date__c))
                        {    
                            Error_Messages += Count++ + Label.WB_Batch_Error_CA_dates_Overlapping+'\n';  
                            break;
                        }
                   }
            }
            
            Boolean errorValue;
            //Storefront selected combination available check  added by Tejasvini Mar Release 2018
            if(mapStorefront.get(record.id) != null){
                errorValue = WB_PriceUtility.availableCombination(mapCARecordRPRecord.get(record),mapStorefront.get(record.id));
                if(errorValue){
                    Error_Messages += Count++ + '. Storefront does not contain the selected channel,format or content type combination.'+'\n';
                }
            }

            //ER-003060 - Storefront Language Preferences changes - Start
            
            if(mapCountryAccountSF != null && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).Language_Preferences__r != Null
            && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).Language_Preferences__r.size()>0){
            
                String errorForCAUpload = '';
                List<String> errorList = new List<String>();

                Boolean isSFLangPref = WB_CreateClientAvail_Controller.checkStorefrontLangPreference(mapCARecordRPRecord.get(record),mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c),Null,sfLangPrefLangMap,titleCountryAvlLangLevelMap,Null,Null,Null,errorList);
                if(isSFLangPref){
                    String errorMsg = mapCARecordRPRecord.get(record).Name+' - Language - '+mapCARecordRPRecord.get(record).Languages__r.Name+' - '+ errorList[0]+' - ';

                    errorMsg = errorMsg + mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).Account__r.Name;

                    Error_Messages += Count++ +'. ' +errorMsg + '\n';
                    
                }
             
            }
        //ER-003060 - Storefront Language Preferences changes - End
           
            
            // Check if any error comes during validation perfor above.
            if(Error_Messages == '' && !flagErrorMessages.get(record.id))
            {
                
                newClientAvail.Commercial_Avail__c=mapCARecordRPRecord.get(record).id;
                newClientAvail.Start_Date__c=record.Start_Date__c;
                newClientAvail.End_Date__c=record.End_Date__c;
                newClientAvail.APO_Date__c = record.Pre_Order_Date__c;
                newClientAvail.Announce_Date__c = record.Suppression_Date__c;
                newClientAvail.Status__c = record.Status__c;
                newClientAvail.Client__c = mapAccountMapNameId.get(record.Account_Name__c).id;
                newClientAvail.Local_Data_Category_Picklist__c = record.Category__c;
                newClientAvail.Storefront__c = mapCAUploadRecordIdSFId.get(record.id);
                
                Boolean isCRMCountry = false;
                if(mapCountryAccountSF != Null && mapCountryAccountSF.containskey(record.Country__c) && mapCountryAccountSF.get(record.Country__c).containskey(record.Account_Name__c) && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c) != null && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).CRM_Storefront__c){
                    isCRMCountry = true;
                }
                
                if(record.New_Price_Code__c != null){
                     
                    assignPricingValues(record,mapPricingRecords,newClientAvail,mapCARecordRPRecord,null,'New Price Code');
                    /*ER-003373  Episode SR Price Field on CA--> if(isCRMCountry){
                        newClientAvail.SR_Price__c = Null; 
                        newClientAvail.SR_Per_Episode__c = Null; 
                    }*/
                }
                if(record.New_Price_Code__c == null && record.Price_Tier__c == null && record.WS_Cost__c == null){
                    if(mapLocalTitle != null && 
                       mapLocalTitle.containsKey(record.Video_Version__c) && 
                       mapLocalTitle.get(record.Video_Version__c).containsKey(record.Language__c) &&
                       mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).containsKey(record.Country__c)){
                        Local_Title__c localTitle = mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c);
                        
                        if(localTitle != null){
                            newClientAvail.Local_Title__c = localTitle.Id;
                            assignPricingValues(record,mapPricingRecords,newClientAvail,mapCARecordRPRecord,localTitle,'Local Title Price Code');
                           /*ER-003373  Episode SR Price Field on CA-->  if(isCRMCountry){
                               newClientAvail.SR_Price__c = Null;
                                newClientAvail.SR_Per_Episode__c = Null; 
                            }*/
                        }
                       
                   }    
                }
                
                if(newClientAvail.Local_Title__c == null && (mapLocalTitle != null && mapLocalTitle.containsKey(record.Video_Version__c) && 
                       mapLocalTitle.get(record.Video_Version__c).containsKey(record.Language__c) &&
                       mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).containsKey(record.Country__c))){
                        
                        newClientAvail.Local_Title__c = mapLocalTitle.get(record.Video_Version__c).get(record.Language__c).get(record.Country__c).Id;   
               }
                
                if(record.Price_Tier__c != null){
                  newClientAvail.Price_Tier_Text__c = record.Price_Tier__c;
                  assignPricingValues(record,mapPricingRecords,newClientAvail,mapCARecordRPRecord,null,'Price Tier');
                 /*ER-003373  Episode SR Price Field on CA-->  if(isCRMCountry){
                        newClientAvail.SR_Price__c = Null; 
                        newClientAvail.SR_Per_Episode__c = Null;
                    }*/
                }
                
                if(record.WS_Cost__c != null) newClientAvail.Price__c = Decimal.valueOf(record.WS_Cost__c);
               /*ER-003373-->  if(record.SR_Price__c != null) newClientAvail.SR_Price__c = Decimal.valueOf(record.SR_Price__c);
               */
                if(record.Notes__c != null) newClientAvail.Comments__c = record.Notes__c;
               /*ER-003373  Episode SR Price Field on CA-->   if(record.Episode_SR_Price__c != null) newClientAvail.SR_Per_Episode__c = Decimal.valueOf(record.Episode_SR_Price__c); */
                if(record.Episode_WS_Cost__c != null) newClientAvail.Episode_Price__c = Decimal.valueOf(record.Episode_WS_Cost__c);
                
                if(record.Episode_Price_Tier__c != null){
                    newClientAvail.Episode_Price_Tier__c = record.Episode_Price_Tier__c;
                    assignPricingValues(record,mapPricingRecords,newClientAvail,mapCARecordRPRecord,null,'Episode Price Tier');
                } 
                
                if(record.Change_Context__c != null) newClientAvail.Change_Context__c = record.Change_Context__c;
                if(record.Client_Title_ID__c != null) newClientAvail.Client_Title_ID__c = record.Client_Title_ID__c;
                if(record.Announce_Override__c != null) newClientAvail.Announce_Override__c = record.Announce_Override__c;
                if(record.Vendor_ID__c != null) newClientAvail.Vendor_ID__c = record.Vendor_ID__c;
                newClientAvail.Batch_Id__c = record.CA_Upload__r.name;
                
                if((record.Start_Date__c != NULL && (record.Start_Date__c != mapCARecordRPRecord.get(record).Start_Date__c)) ||(record.End_Date__c != NULL && (record.End_Date__c != mapCARecordRPRecord.get(record).End_Date__c)) ){
                    newClientAvail.RP_Synch__c = false;
                }
                //newClientAvail.RP_Synch__c = false;
                
                //Map<String,Map<String,Map<String,Map<String,Map<String,Map<String,List<Client_Avail__c>>>>>>>
                if(!mapNewClientAvails.containskey(record.Video_Version__c))
                    mapNewClientAvails.put(record.Video_Version__c,new Map<String,Map<String,Map<String,Map<String,Map<String,List<Client_Avail__c>>>>>>());
                if(!mapNewClientAvails.get(record.Video_Version__c).containskey(record.Language__c))
                    mapNewClientAvails.get(record.Video_Version__c).put(record.Language__c,new Map<String,Map<String,Map<String,Map<String,List<Client_Avail__c>>>>>());
                if(!mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).containskey(record.Format__c))
                    mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).put(record.Format__c,new Map<String,Map<String,Map<String,List<Client_Avail__c>>>>());
                if(!mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).containskey(record.Country__c))
                    mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).put(record.Country__c,new Map<String,Map<String,List<Client_Avail__c>>>());
                if(!mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).containskey(record.Channel__c))
                    mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).put(record.Channel__c,new Map<String,List<Client_Avail__c>>());
                if(!mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).get(record.Channel__c).containskey(record.Account_Name__c))
                    mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).get(record.Channel__c).put(record.Account_Name__c,new List<Client_Avail__c>()); 
                mapNewClientAvails.get(record.Video_Version__c).get(record.Language__c).get(record.Format__c).get(record.Country__c).get(record.Channel__c).get(record.Account_Name__c).add(newClientAvail);
                
                mapClientAvailTobeInsert.put(record,newClientAvail);
            }
            else
                if(mapCARecords.containskey(record.id))
                    mapCARecords.get(record.id).Errors__c += Error_Messages;
                else
                    mapCARecords.put(record.id,new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Failed',Errors__c=Error_Messages,Title_Name__c = mapTitleVVCARecord.get(record.Video_Version__c).Name)); 
        
            countErrorMessages.put(record.id,count);
            }catch(Exception e)
            {
                CA_Upload_Record__c rec = new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Failed',Errors__c=e.getmessage()+'\n'+Error_Messages);
                update rec;
            }
        }
        //ER-1139 Return to Window changes start
        List<Commercial_Avail__c> releasePlanList = new List<Commercial_Avail__c>();
        List<Client_Avail__c> caList = new List<Client_Avail__c>();
        
        if(mapCARecordRPRecord.values().size()>0){
            releasePlanList.addAll(mapCARecordRPRecord.values()); 
        }
        
        //Rate Card changes 
        Map<String,List<Rate_Card__c>> rateCardMap = new Map<String,List<Rate_Card__c>>();
        Map<String,List<CA_Upload_Record__c>> caUploadKeyMap = new Map<String,List<CA_Upload_Record__c>>(); 
        
        if((mapClientAvailTobeInsert != Null && mapClientAvailTobeInsert.size()>0) && (mapCARecordRPRecord != Null && mapCARecordRPRecord.size()>0)){
          
          for(CA_Upload_Record__c record : mapClientAvailTobeInsert.keySet()){
            Boolean isCRMCountry = false;
            if(mapCountryAccountSF != Null && mapCountryAccountSF.containskey(record.Country__c) && mapCountryAccountSF.get(record.Country__c).containskey(record.Account_Name__c) && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c) != null && mapCountryAccountSF.get(record.Country__c).get(record.Account_Name__c).CRM_Storefront__c){
                isCRMCountry = true;
            }
            if((mapClientAvailTobeInsert.get(record) != Null)){
                if(isCRMCountry){
                    caPriceWrapperMap.putAll(WB_CreateClientAvail_Controller.getCAPriceWrapperMap(mapCARecordRPRecord.get(record),mapClientAvailTobeInsert.get(record)));
                }
            }
            
            if((isCRMCountry) && (mapCARecordRPRecord.get(record) != Null && (mapClientAvailTobeInsert.get(record).Price_Tier_Text__c != Null && mapClientAvailTobeInsert.get(record).Price_Tier_Text__c != '' && mapClientAvailTobeInsert.get(record).Price_Tier_Text__c != 'TBD') || mapClientAvailTobeInsert.get(record).Price__c != Null )){
              String rcKey = mapClientAvailTobeInsert.get(record).Client__c +'_'+mapCARecordRPRecord.get(record).Country_Lookup__c+'_'+mapCARecordRPRecord.get(record).Channel__c+'_'+mapCARecordRPRecord.get(record).Format__c;
              String rcKeyEp;
              if(mapCARecordRPRecord.get(record).Title__r.Content_Type__c.contains('Season')){
                  
                  rcKeyEp = rcKey +'_Episode';
                  
                  if(mapClientAvailTobeInsert.get(record).Episode_Price_Tier__c != Null && mapClientAvailTobeInsert.get(record).Episode_Price_Tier__c != '' && mapClientAvailTobeInsert.get(record).Episode_Price_Tier__c != 'TBD'){
                      rcKeyEp = rcKeyEp+'_'+mapClientAvailTobeInsert.get(record).Episode_Price_Tier__c;
                  }else if(mapClientAvailTobeInsert.get(record).Episode_Price__c != Null){
                      rcKeyEp = rcKeyEp+'_'+mapClientAvailTobeInsert.get(record).Episode_Price__c;
                  }
                  rcKeyEp = rcKeyEp.toUpperCase();
              }
              
              rcKey = rcKey +'_'+mapCARecordRPRecord.get(record).Title__r.Content_Type__c;
              
              if(mapClientAvailTobeInsert.get(record).Price_Tier_Text__c != Null && mapClientAvailTobeInsert.get(record).Price_Tier_Text__c != '' && mapClientAvailTobeInsert.get(record).Price_Tier_Text__c != 'TBD'){
                 
                  rcKey = rcKey+'_'+mapClientAvailTobeInsert.get(record).Price_Tier_Text__c;
              }else if(mapClientAvailTobeInsert.get(record).Price__c != Null){
                rcKey = rcKey+'_'+mapClientAvailTobeInsert.get(record).Price__c;
              }
              
              rcKey = rcKey.toUpperCase();
              
            
              if(!caUploadKeyMap.containsKey(rcKey)){
                caUploadKeyMap.put(rcKey,new List<CA_Upload_Record__c>{record});
              }else{
                caUploadKeyMap.get(rcKey).add(record);
              }
              
              if(rcKeyEp != Null && rcKeyEp != ''){
                  if(!caUploadKeyMap.containsKey(rcKeyEp)){
                    caUploadKeyMap.put(rcKeyEp,new List<CA_Upload_Record__c>{record});
                  }else{
                    caUploadKeyMap.get(rcKeyEp).add(record);
                  }
              }
            }
          }
        }
        if(caPriceWrapperMap != Null && caPriceWrapperMap.size()>0){
      rateCardMap = WB_RateCardHelper.getRateCard(caPriceWrapperMap.values(),false,false);
      Map<String,List<Client_Avail__c>> processedCA = new Map<String,List<Client_Avail__c>>();
      for(String key : WB_CreateClientAvail_Controller.keyCAMap.keySet()){
        for(Client_Avail__c ca : WB_CreateClientAvail_Controller.keyCAMap.get(key)){
          Boolean rcFound=false;
          Boolean rcEpFound = false;
          ca.Pricing__c = Null;
          if(key.contains('EPISODE')){
            rcFound = true;
          }else{
            rcEpFound = true;
          }
          if(rateCardMap != null && rateCardMap.size()>0 && rateCardMap.get(key) != null){
            for(Rate_Card__c caRC : rateCardMap.get(key)){
              
              if(ca.Start_Date__c >= caRC.Start_Date__c && ca.Start_Date__c <= caRC.End_Date__c){
                if(key.contains('EPISODE')){
                  ca.Episode_Rate_Card__c = caRC.Id;
                  ca.Episode_Pricing__c = Null;
                  rcEpFound = true;
                  break;
                }else{
                  ca.CA_Rate_Card__c = caRC.Id;
                  rcFound = true;
          /*ER-003373--> 
                  if(caRC.SRP__c != Null && ca.SR_Price__c == Null){
                    ca.SR_Price__c = caRC.SRP__c; 
                  }*/
                    break;
                }
              
              }
            }
            
          }
          String error;
          if((!rcFound && (ca.CA_Rate_Card__c == Null && (ca.Price__c == Null )))||(!rcEpFound && (ca.Episode_Rate_Card__c == Null && (ca.Episode_Price__c == Null)))){
            if((!rcFound && (ca.CA_Rate_Card__c == Null && (ca.Price__c == Null)))){
              error = 'Price Tier not found on the rate card table'+'\n';
            }
            if(!rcEpFound && (ca.Episode_Rate_Card__c == Null && ca.Episode_Price__c == Null)){
              error = 'Episode Price Tier not found on the rate card table'+'\n';
            }
            if(error != Null && error != ''){
              if((caUploadKeyMap != Null && caUploadKeyMap.size()>0)){
                  if(caUploadKeyMap.containsKey(key) && caUploadKeyMap.get(key) != Null){
                  for(CA_Upload_Record__c record : caUploadKeyMap.get(key)){
                    if(mapCARecords != Null){
                      if(mapCARecords.containsKey(record.id)){
                        CA_Upload_Record__c rec = mapCARecords.get(record.id);
                        if(rec.Errors__c != Null && rec.Errors__c != ''){
                          rec.Errors__c = rec.Errors__c +'2. '+error;
                        }
                      }else{
                        CA_Upload_Record__c rec = new CA_Upload_Record__c(id = record.id,CA_upload_status__c ='Failed',Errors__c = '1. '+error);
                        if(mapTitleVVCARecord.containsKey(record.Video_Version__c))
                          rec.Title_Name__c = mapTitleVVCARecord.get(record.Video_Version__c).Name;
                        mapCARecords.put(record.id,rec);
                      }
                    }
                    if((mapClientAvailTobeInsert != Null && mapClientAvailTobeInsert.size()>0) && mapClientAvailTobeInsert.containsKey(record)){
                      mapClientAvailTobeInsert.remove(record);
                    }
                  }
                }
                
              }
            }
            
          }
          
          
        }  
        
      }
    }
        
        if(mapClientAvailTobeInsert.values().size()>0){
            caList.addAll(mapClientAvailTobeInsert.values());
            
        }
        if((releasePlanList != null && releasePlanList.size()>0) && (caList != null && caList.size()>0)){
            WB_PriceUtility.setReturnToWindowFlag(releasePlanList,caList);
        }
        //ER-1139 Return to Window changes end
        
        mapCountryAccountChannelsSF.clear();
        mapCountryAccountFormatsSF.clear();
        mapCountryAccountCTsSF.clear();
        mapCountryAccountSF.clear();
        
        Database.Saveresult[] saveResult_CActivity  = Database.insert(mapClientAvailTobeInsert.values(), false);
        Integer i=0;
        set<Id> setLocalTitle = new set<Id>();
        List<Local_Title__c> listToUpdateLocalTitle = new List<Local_Title__c>();
        for (Database.SaveResult sr : saveResult_CActivity ) {            
            if (sr.isSuccess()) {
                String Message = '';
                CA_Upload_Record__c record = new List<CA_Upload_Record__c>(mapClientAvailTobeInsert.keyset())[i++];
                mapCARecords.put(record.id,new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Successful',Errors__c='',Client_Avail_Record_Id__c=sr.getId(),Title_Name__c = mapTitleVVCARecord.get(record.Video_Version__c).Name));
                //listTobeUpdateCARecord.add(new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Successful',Errors__c='',Client_Avail_Record_Id__c=sr.getId()));
                /*if(!setLocalTitle.contains(mapCARecordRPRecord.get(record).Local_Title__c) && (record.Local_Edit_Required__c != null || record.Local_Data_Rating__c != null || record.Local_Data_No_Of_Episodes__c != null))
                {
                    setLocalTitle.add(mapCARecordRPRecord.get(record).Local_Title__c);
                    Local_Title__c localTitle = new Local_Title__c();
                    localTitle.id = mapCARecordRPRecord.get(record).Local_Title__c;
                    if(record.Local_Edit_Required__c != null) localTitle.Local_Edit_Required__c = record.Local_Edit_Required__c;
                    if(record.Local_Data_Rating__c != null) localTitle.Local_Rating__c = record.Local_Data_Rating__c;
                    if(record.Local_Data_No_Of_Episodes__c != null) localTitle.Num_Local_Episodes__c = Decimal.valueof(record.Local_Data_No_Of_Episodes__c);
                    listToUpdateLocalTitle.add(localTitle);
                }*/
            }
            else {
                String error ='';
                // Operation failed, so get all errors  
                for(Database.Error err : sr.getErrors()) {     
                    error += err.getMessage();
                }
                CA_Upload_Record__c record = new List<CA_Upload_Record__c>(mapClientAvailTobeInsert.keyset())[i++];
                mapCARecords.put(record.id,new CA_Upload_Record__c(id=record.id,CA_upload_status__c='Failed',Errors__c=error,Title_Name__c = mapTitleVVCARecord.get(record.Video_Version__c).Name));
                //listTobeUpdateCARecord.add(new CA_Upload_Record__c(id=new List<CA_Upload_Record__c>(mapClientAvailTobeInsert.keyset())[i++].id,CA_upload_status__c='Failed',Errors__c=error));   
            }
        }
        /*if(listToUpdateLocalTitle != null && listToUpdateLocalTitle.size()>0)
            Database.Saveresult[] saveResult_CActivity1  = Database.update(listToUpdateLocalTitle);*/
        update mapCARecords.values();
    }
     
    
    public void finish(Database.BatchableContext BC){
        
        List<CA_Upload__c> listCAUploadRecords = [Select id,Upload_Status__c,No_of_Unprocessed_Records__c from CA_Upload__c where id in: CAUploadIds
                                                  AND No_of_Unprocessed_Records__c = 0];
        for(CA_Upload__c upload : listCAUploadRecords)
        {
            upload.Upload_Status__c = 'Preparing File';
        }
        Database.update(listCAUploadRecords,false);
        
        WB_Batch_Playlist_Mgmt_Process c = new WB_Batch_Playlist_Mgmt_Process();
        database.executebatch(c,1);
        
    }
    
    public void assignPricingValues(CA_Upload_Record__c record,Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>> mapPricingRecords,Client_Avail__c caRec,Map<CA_Upload_Record__c,Commercial_Avail__c> mapCARecordRPRecord,Local_Title__c localTitleRec,String value){
        
        if(mapPricingRecords != null 
        && mapPricingRecords.get(record.Account_Name__c) != null 
            && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c) != null 
            && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c) != null 
            && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c) != null)
        {
            //Episode Price Tier
        if(value == 'Episode Price Tier' && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get('Episode') != null){
          for(Pricing__c pricingMatchRec : mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get('Episode')){
            
            if((record.Episode_Price_Tier__c != Null && record.Episode_Price_Tier__c !='') && (record.Episode_Price_Tier__c == pricingMatchRec.Price_Tier__c) && ((pricingMatchRec.Price_Code_Status__c == 'Validation Only' || pricingMatchRec.Price_Code_Status__c == 'Active'))){
              caRec.Episode_Pricing__c = pricingMatchRec.Id;
            }
            
          }
        }else{ 
          
          if(mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get(mapCARecordRPRecord.get(record).Title__r.Content_Type__c) != null){
            
            for(Pricing__c pricingMatchRec : mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get(mapCARecordRPRecord.get(record).Title__r.Content_Type__c))
            {  
              //New Price Code or Local Data Price Code
              if(((record.New_Price_Code__c != null && record.New_Price_Code__c != '') && pricingMatchRec.Price_Code_Status__c == 'Active' && record.New_Price_Code__c == pricingMatchRec.Name) || 
                (record.New_Price_Code__c == null &&  localTitleRec != Null && (localTitleRec.Price_Code__c != null && localTitleRec.Price_Code__c == pricingMatchRec.Name) && (pricingMatchRec.Price_Code_Status__c == 'Active'))  ){
                 
                caRec.Pricing__c = pricingMatchRec.Id;
                if(record.New_Price_Code__c != null){
                  caRec.New_Price_Code__c = record.New_Price_Code__c;
                }else if(record.New_Price_Code__c == null && localTitleRec.Price_Code__c != null){
                  caRec.New_Price_Code__c = localTitleRec.Price_Code__c;
                }
                
                if(pricingMatchRec.Price_Tier__c != null)
                  caRec.Price_Tier_Text__c = pricingMatchRec.Price_Tier__c;
                
                if(pricingMatchRec.WS_Price__c != null)
                  caRec.Price__c = pricingMatchRec.WS_Price__c;
                // SR Price
        /* ER-003373  Episode SR Price Field on CA-->
                if(pricingMatchRec.SR_Price__c != null)
                  caRec.SR_Price__c = pricingMatchRec.SR_Price__c;
        
                //Episode SR Price
                if(pricingMatchRec.SR_Per_Episode__c != null)
                  caRec.SR_Per_Episode__c = pricingMatchRec.SR_Per_Episode__c; */
                //Episode changes
                if(mapCARecordRPRecord.get(record).Title__r.Content_Type__c == 'Season'){
                    List<Pricing__c> episodePricingList = new List<Pricing__c>();
                  episodePricingList = mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get('Episode');
                  Pricing__c episodePricingRec = WB_CreateClientAvail_Controller.fetchEpisodePricing(pricingMatchRec,episodePricingList);
                  if(episodePricingRec != Null){
                    caRec.Episode_Pricing__c = episodePricingRec.Id;
                    caRec.Episode_Price__c = episodePricingRec.WS_Price__c;
                    caRec.Episode_Price_Tier__c = episodePricingRec.Price_Tier__c;
                  }
                }
                
              }  
              
              //Price Tier Manually
              if((record.Price_Tier__c != Null && record.Price_Tier__c !='') && (record.Price_Tier__c == pricingMatchRec.Price_Tier__c) && ((pricingMatchRec.Price_Code_Status__c == 'Validation Only' || pricingMatchRec.Price_Code_Status__c == 'Active'))){
                caRec.Pricing__c = pricingMatchRec.Id;
                
              }
                
            }
          }
        }
        }
        
    }
    
    public static Boolean validatePricing(CA_Upload_Record__c record,Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>> mapPricingRecords,Map<CA_Upload_Record__c,Commercial_Avail__c> mapCARecordRPRecord,String value,Local_Title__c localTitleRec){
        Boolean isMatchFound = false;
        if(mapPricingRecords != null 
        && mapPricingRecords.get(record.Account_Name__c) != null 
        && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c) != null 
        && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c) != null 
        && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c) != null){
           
           if( value == 'Episode Price Tier' && mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get('Episode') != null){
          
          for(Pricing__c pricingMatchRec : mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get('Episode')){
            if( (record.Episode_Price_Tier__c != Null && record.Episode_Price_Tier__c !='')&& (record.Episode_Price_Tier__c == pricingMatchRec.Price_Tier__c) && ((pricingMatchRec.Price_Code_Status__c == 'Validation Only' || pricingMatchRec.Price_Code_Status__c == 'Active'))){
              isMatchFound = true;
              return  isMatchFound;
            }
          }
        }else{
          
          if(mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get(mapCARecordRPRecord.get(record).Title__r.Content_Type__c) != null){
            for(Pricing__c pricingMatchRec : mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get(mapCARecordRPRecord.get(record).Title__r.Content_Type__c)){
              
              if((value == 'New Price Code' && (record.New_Price_Code__c != null && record.New_Price_Code__c != '') && pricingMatchRec.Price_Code_Status__c == 'Active' && record.New_Price_Code__c == pricingMatchRec.Name) || 
                (value == 'Local Title Price Code' && record.New_Price_Code__c == null &&  localTitleRec != Null && (localTitleRec.Price_Code__c != null && localTitleRec.Price_Code__c == pricingMatchRec.Name) && (pricingMatchRec.Price_Code_Status__c == 'Active'))){
                
                isMatchFound = true;
                //Episode changes
                if(mapCARecordRPRecord.get(record).Title__r.Content_Type__c.contains('Season') ){
                  List<Pricing__c> episodePricingList = new List<Pricing__c>();
                  episodePricingList = mapPricingRecords.get(record.Account_Name__c).get(record.Country__c).get(record.Format__c).get(record.Channel__c).get('Episode');
                  Pricing__c episodePricingRec = WB_CreateClientAvail_Controller.fetchEpisodePricing(pricingMatchRec,episodePricingList);
                  if(episodePricingRec == Null){
                    isMatchFound = false;
                  }else if(episodePricingRec != Null && episodePricingRec.Price_Code_Status__c != 'Active'){
                    isMatchFound = false;
                  }
                  
                }
                  
                return  isMatchFound;
                  
              }
              if(value == 'Price Tier' &&(record.Price_Tier__c != Null && record.Price_Tier__c !='') && (pricingMatchRec.Price_Code_Status__c == 'Validation Only' || pricingMatchRec.Price_Code_Status__c == 'Active')&& record.Price_Tier__c == pricingMatchRec.Price_Tier__c){
                isMatchFound = true;
                return  isMatchFound;
              }
            }
          }
        }  
        }
        
      return  isMatchFound;
            
    }
    
    // Get Pricing records for provided set of combination.
    // Method accepts input parameters like : 
    // 1. Set Of Accounts
    // 2. Set Of Channel
    // 3. Set Of Formats
    // 4. Set Of Country
    // 5. Set Of Content Type
    // 6. Set Of Price_Code__c
    public static Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>> getPricingRecords(set<String> setAccounts,
                                                                                                                   set<String> setChannels,
                                                                                                                   set<String> setFormats,
                                                                                                                   set<String> setCountries,
                                                                                                                   set<String> setContentTypes)
    {
        // Account Name,Country,Format,Channel,Content Type,PriceCode.
        Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>> mapPricingRecords = new Map<String,Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>>();
        
        Set<String> priceCodeStatus = new Set<String>{'Active','Validation Only'};
        List<Pricing__c> listPricing = [SELECT Id,Account__c,Account__r.Name, Channel__c,Format__c,Content_Type__c,Country__c,Country__r.Name,Name,Price_Tier__c,WS_Price__c,SR_Price__c,SR_Per_Episode__c,Episode_Price__c,Episode_Price_Tier__c,Price_Code_Status__c FROM Pricing__c
                                        WHERE Account__r.Name in: setAccounts AND Channel__c in: setChannels AND Format__c in: setFormats
                                        AND Country__r.Name in: setCountries AND Content_Type__c in: setContentTypes AND Price_Code_Status__c IN :priceCodeStatus];
        
        if(listPricing != null && listPricing.size() > 0)
        {
            for(Pricing__c pricingRecord : listPricing)
            {
                // Add account
                if(!mapPricingRecords.containskey(pricingRecord.Account__r.Name)){
                    mapPricingRecords.put(pricingRecord.Account__r.Name,new Map<String,Map<String,Map<String,Map<String,List<Pricing__c>>>>>());
                }
                // Add Country Name    
                if(mapPricingRecords != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name)!= null 
                    && !mapPricingRecords.get(pricingRecord.Account__r.Name).containskey(pricingRecord.Country__r.Name)){
                    mapPricingRecords.get(pricingRecord.Account__r.Name).put(pricingRecord.Country__r.Name,new Map<String,Map<String,Map<String,List<Pricing__c>>>>());
                }
                // Add Format
                if(mapPricingRecords != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name) != null 
                    && !mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).containskey(pricingRecord.Format__c)){
                    mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).put(pricingRecord.Format__c,new Map<String,Map<String,List<Pricing__c>>>());
                }    
                // Add Channel
                if(mapPricingRecords != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get (pricingRecord.Format__c) != null 
                    && !mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).containskey(pricingRecord.Channel__c)){
                    mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).put(pricingRecord.Channel__c,new Map<String,List<Pricing__c>>());
                }
                // Add Content Type
                if(mapPricingRecords != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get (pricingRecord.Format__c) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c) != null 
                    && !mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).containskey(pricingRecord.Content_Type__c)){
                    mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).put(pricingRecord.Content_Type__c,new List<Pricing__c>());
                }
                mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).add(pricingRecord);
                
                
                /* Add Price code
                if(mapPricingRecords != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get (pricingRecord.Format__c) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c) != null 
                    && mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c)!= null
                    && !mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).containskey(pricingRecord.Name)){
                    mapPricingRecords.get(pricingRecord.Account__r.Name).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).put(pricingRecord.Name,pricingRecord);    
                }*/
                // Add related Price Tier values for related combination.    
                //mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).get(pricingRecord.Name).add(pricingRecord.Price_Tier__c);  
            }
        }
        return mapPricingRecords;
    }
    
}