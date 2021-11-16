/*******************************************************************************************************************************************
* File Name     :   WB_ClientAvailsDateCheckHandler
* Description   :   Handler to check start date and end date of Client Avails at the time of creation from Release plans
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     5 Nov.2015        CTS                 ER-000065 : Created the class.
* 2.0                                           This handler checks for the error if the scenario is like below :
*                                               One bundle exists with multiple Collection titles having multiple release plans with multiple client avails each.
*                                               If we try to create client avails for the bundles release plan, it checks if the Start Date and End Date of the 
*                                               Release Plan is in between the start & end date of all its respective collection titles client avails.
* 3.0     23 Dec.2016       CTS                 ER-000886 : Pricing association logic modified                                                
********************************************************************************************************************************************/

public class WB_ClientAvailsDateCheckHandler {
    
   
    
    public static void checkDatesValidation (List<Client_Avail__c> newList) {
        set<String> setOfBundle = new set<String>();
        set<String> setOfTitle = new set<String>();
        set<Id> setOfPlaylistIds = new set<Id>();
        set<String> setCountry = new Set<string>();
        Set<Id> setAccount = new Set<Id>();
        Set<String> setLanguage = new Set<string>();
        Set<String> setFormat = new Set<string>();
        Set<String> setChannel = new Set<string>();
        List<Client_Avail__c> newClientAvailList = new List<Client_Avail__c>();
        
        //Created set of all the bundles
        for(Client_Avail__c objCA : newList) {
            if((objCA.Title_Content_Type__c == Label.Collection_Features || objCA.Title_Content_Type__c == Label.Collection_TV) && objCA.Playlist__c != null) {
                setOfBundle.add(objCA.Release_Plan_Title__c);
                setOfPlaylistIds.add(objCA.Playlist__c);
                newClientAvailList.add(objCA);
                setCountry.add(objCA.Release_Plan_Country__c);
                setFormat.add(objCA.Release_Plan_Format__c);
                setLanguage.add(objCA.Release_Plan_Language__c);
                setChannel.add(objCA.Release_Plan_Channel__c);
                setAccount.add(objCA.Client__c);
            }
        }
        if(setOfBundle.size() > 0 && setOfPlaylistIds.size() > 0) {
            // Map used to store the collection related to feature titles
            Map<String,Set<String>> contentCollectionTitleSet = new Map<String,Set<String>>();
            
            // Map used to store the feature avails respective with collection titles 
            Map<String, map<String, Map<String, List<Client_Avail__c>>>> mapClientAvails = new map<String, map<String, Map<String, List<Client_Avail__c>>>>();
            // Added by Mayank Desai for SINC2160482 on 03/12/2019 + Start
            Set<String> SetVideoVersion= new set<String>();

            for(Playlist_Content__c content : [SELECT id,Content_Title__r.Name,Playlist__r.Parent_Title__r.Name, Content_VV__c 
                                                FROM Playlist_Content__c 
                                                WHERE Playlist__c in: setOfPlaylistIds])
           
            {   if(!contentCollectionTitleSet.containsKey(content.Content_Title__r.Name))
                    contentCollectionTitleSet.put(content.Content_Title__r.Name,new Set<String>());
                contentCollectionTitleSet.get(content.Content_Title__r.Name).add(content.Playlist__r.Parent_Title__r.Name);
                SetVideoVersion.add(content.Content_VV__c);
                // Added by Mayank Desai for SINC2160482 on 03/12/2019 + End
                if(!mapClientAvails.containsKey(content.Playlist__r.Parent_Title__r.Name )) {
                    mapClientAvails.put(content.Playlist__r.Parent_Title__r.Name , new map<String, Map<String, List<Client_Avail__c>>>());
                }
                if(!mapClientAvails.get(content.Playlist__r.Parent_Title__r.Name).containsKey(content.Content_Title__r.Name)) {
                    mapClientAvails.get(content.Playlist__r.Parent_Title__r.Name).put(content.Content_Title__r.Name, new Map<String, List<Client_Avail__c>>());
                }
                                                    
            }
            List<String> caLifeCycles = new List<String>{'Active Future','Active Current'};
            Map<Id,Client_Avail__c> mapExistingCAList = new Map<Id,Client_Avail__c>([SELECT Id, Name , Start_Date__c , End_Date__c , Client__c , Release_Plan_Country__c, Release_Plan_Title__c,
                                                                                    Release_Plan_Language__c , Release_Plan_Format__c , Title_Content_Type__c , 
                                                                                    Release_Plan_Channel__c,RP_Language_Type__c,Status__c,
                                                                                    Commercial_Avail__c, Commercial_Avail__r.Name, Commercial_Avail__r.Title__r.Name
                                                                                    FROM Client_Avail__c 
                                                                                    WHERE Commercial_Avail__r.Title__r.Name IN: contentCollectionTitleSet.keyset()
                                                                                    // Added by Mayank Desai for SINC2160482 on 03/12/2019
                                                                                    AND Commercial_Avail__r.Title__r.Video_Version__c IN: SetVideoVersion
                                                                                    //SINC1824078
                                                                                    //AND Release_Plan_Country__c IN: setCountry
                                                                                    AND Release_Plan_Format__c IN: setFormat
                                                                                    AND Release_Plan_Language__c IN: setLanguage
                                                                                    AND Release_Plan_Channel__c IN: setChannel
                                                                                    AND Client__c IN: setAccount
                                                                                    //SINC2114097 To fetch Avails with Status__c as Tentative or Confirmed for the component titles
                                                                                    AND Status__c IN ('Tentative','Confirmed')
                                                                                    AND CA_Lifecycle__c IN: caLifeCycles
                                                                                    //ENd of SINC1824078
                                                                                    order by Start_Date__c ASC]);
                                                                                    
            // List of all the client avails for whose Collection Title we are creating client avail 
            List<Client_Avail__c> existingCAList = mapExistingCAList.values();
            // where Title__c in (Select Content_Title__c from Playlist_Content__c where  )
            
            // Created map which contains Collection Title => List<Title> => (Combination of Client, Country, Format, Channel) => List<Client Avail>
            
            for(Client_Avail__c objCA : existingCAList){
                
                
                        String strCAKey = objCA.Client__c + objCA.Release_Plan_Country__c +objCA.Release_Plan_Language__c+ objCA.Release_Plan_Format__c + objCA.Release_Plan_Channel__c;//+ objCA.Status__c;
                        
                        for(String collectionTitle : contentCollectionTitleSet.get(objCA.Commercial_Avail__r.Title__r.Name)){
                    
                        if(!mapClientAvails.get(collectionTitle).get(objCA.Commercial_Avail__r.Title__r.Name).containsKey(strCAKey)) {
                            mapClientAvails.get(collectionTitle).get(objCA.Commercial_Avail__r.Title__r.Name).put(strCAKey, new List<Client_Avail__c>()); 
                        }
                        
                        mapClientAvails.get(collectionTitle).get(objCA.Commercial_Avail__r.Title__r.Name).get(strCAKey).add(objCA);
                    }
                    
                }
            
            // Created set of error message strings depending of errors to be displayed
            set<String> lstErrorEndString = new set<String>();
            set<String> lstErrorStartString = new set<String>();
            set<String> lstErrorSEString = new set<String>();
            set<String> lstErrorGapString = new set<String>();
            set<String> lstErrorStatusString = new set<String>();
            
            map<String, set<String>> mapStrTolstError = new map<String, set<String>>();
            map<String, set<String>> mapStrToStatuslstError = new map<String, set<String>>();
           
            for(Client_Avail__c objNewCA : newClientAvailList) {
                Boolean isEitherCompStatus = false;
                String NewCAKey = objNewCA.Client__c + objNewCA.Release_Plan_Country__c +objNewCA.Release_Plan_Language__c 
                                + objNewCA.Release_Plan_Format__c + objNewCA.Release_Plan_Channel__c;// + objNewCA.Status__c;
                //String NewCAKey = objNewCA.Client__c + objNewCA.Release_Plan_Country__c + objNewCA.Release_Plan_Format__c + objNewCA.Release_Plan_Channel__c;
                String BundleKeyStr = objNewCA.Release_Plan_Title__c;
                set<String> gapTitles = new set<String>();
                if(mapClientAvails.size() > 0 && mapClientAvails.containsKey(BundleKeyStr)) {
                    for(String strTitle : mapClientAvails.get(BundleKeyStr).keyset()) {
                       if(mapClientAvails.get(BundleKeyStr).get(strTitle) != null && mapClientAvails.get(BundleKeyStr).get(strTitle).get(NewCAKey) != null) {
                            List<Client_Avail__c> lstClientAvails = mapClientAvails.get(BundleKeyStr).get(strTitle).get(NewCAKey);
                            Map<String,String> mapDateTitle = new Map<String,String>();
                            //Map<String,String> mapDateTitle = new Map<String,String>();
                            if(lstClientAvails.size() > 0) {
                                
                                // Checking if the Client Avails with same combination of Account, Country, Format, Channel are having gap in between dates
                                for(integer i=0; i < (lstClientAvails.size() - 1); i++){
                                   if(lstClientAvails[i].End_Date__c.daysBetween(lstClientAvails[i+1].Start_Date__c) > 1 && lstClientAvails[i].End_Date__c >= objNewCA.Start_Date__c){
                                        lstErrorGapString.add(objNewCA.Release_Plan_Title__c +' ---> ' + strTitle);
                                        gapTitles.add(strTitle);
                                    }
                                } 
                                //SINC1584525            
                                for(Client_Avail__c componentCA:lstClientAvails ){
                                   if(componentCA.Status__c == 'Tentative'){
                                       isEitherCompStatus = true;
                                   }
                                   if(!(componentCA.Status__c == 'Tentative' || componentCA.Status__c == 'Confirmed')) {
                                       lstErrorStatusString.add(objNewCA.Release_Plan_Title__c +' ---> ' + strTitle);
                                   }
                                }//END_OF_SINC1584525 
                                Date sDate = lstClientAvails[0].Start_Date__c;
                                Date eDate = lstClientAvails[(lstClientAvails.size()-1)].End_Date__c;
                                 // If no gap is exists between client avail dates, check it the Start & End dates are aligning
                                if(!gapTitles.contains(strTitle)) {
                                    if(objNewCA.Start_Date__c < sDate && objNewCA.End_Date__c > eDate) {
                                        mapDateTitle.Put('StartEndDate', strTitle);
                                    }
                                    else if(objNewCA.Start_Date__c < sDate) {
                                        mapDateTitle.Put('StartDate', strTitle);
                                    }
                                    else if(objNewCA.End_Date__c > eDate) {
                                        mapDateTitle.Put('EndDate', strTitle);
                                    }
                                }
                            } else {
                                objNewCA.addError('Client Avail can not be created.');
                            }
                            
                            // Added error in the List<String>
                            if(mapDateTitle.containsKey('StartEndDate'))
                                lstErrorSEString.add(objNewCA.Release_Plan_Title__c +' ---> '+ mapDateTitle.get('StartEndDate'));
                            if(mapDateTitle.containsKey('StartDate'))
                                lstErrorStartString.add(objNewCA.Release_Plan_Title__c +' ---> '+ mapDateTitle.get('StartDate'));
                            if(mapDateTitle.containsKey('EndDate'))
                                lstErrorEndString.add(objNewCA.Release_Plan_Title__c +' ---> '+ mapDateTitle.get('EndDate'));
                        } else {
                            objNewCA.addError(Label.Client_Avail_can_not_be_created);
                        }
                    }
                    
                    if(isEitherCompStatus && objNewCA.Status__c == 'Confirmed'){
                        objNewCA.Status__c = 'Tentative';
                    }
                } else {
                    objNewCA.addError(Label.No_Client_Avail_exists);
                }
            }
            if(lstErrorGapString.size() > 0)
                mapStrTolstError.put('Gap', lstErrorGapString);
            if(lstErrorSEString.size() > 0)
                mapStrTolstError.put('StartEnd', lstErrorSEString);
            if(lstErrorStartString.size() > 0)
                mapStrTolstError.put('Start', lstErrorStartString);
            if(lstErrorEndString.size() > 0)    
                mapStrTolstError.put('End', lstErrorEndString);
            //SINC1584525 
            if(lstErrorStatusString.size() > 0)
                mapStrTolstError.put('Status', lstErrorStatusString);
            
            
            // Displayed error on the page according to its type.
            for(Client_Avail__c objNewCA : newClientAvailList) {
                //SINC1977266 (Added Null check for Batch_Id__c)
                if(objNewCA.Batch_Id__c != null && objNewCA.Batch_Id__c.contains('CAU')){
                    String finalstring = '';
                    if(mapStrTolstError.containsKey('Gap')) {
                        finalstring +=Label.Gap_between_the_dates;
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('Gap')) {
                            finalstring += ' '+i+'.'+s;
                            if(i < mapStrTolstError.get('Gap').size())
                                i++;
                        }
                    }
                
                    if(mapStrTolstError.containsKey('StartEnd')) {
                        finalstring += ' '+Label.Start_End_date_align_msg;
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('StartEnd')) {
                            finalstring +=  ' '+i+'.'+s;
                            if(i < mapStrTolstError.get('StartEnd').size())
                                i++;
                        }
                    }
                    if(mapStrTolstError.containsKey('Start')) {
                        finalstring += ' '+Label.Start_date_align_msg;
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('Start')) {
                            finalstring +=  ' '+i+'.'+s;
                            if(i < mapStrTolstError.get('Start').size())
                                i++;
                        }
                    }
                    
                    if(mapStrTolstError.containsKey('End')) {
                        Integer i = 1;
                        finalstring += ' '+Label.End_date_align_msg;
                        for(String s : mapStrTolstError.get('End')) {
                            finalstring +=  ' '+i+'.'+s;
                            if(i < mapStrTolstError.get('End').size())
                                i++;
                        }
                    }
                    
                    //SINC1584525
                    if(mapStrTolstError.containsKey('Status')) {
                        finalstring += ' '+Label.Invalid_Status_Msg;
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('Status')) {
                            finalstring += ' '+i+'.'+s;
                            if(i < mapStrTolstError.get('Status').size())
                                i++;
                        }
                    }
                    //ER-006752 - Import Client Avails error (Collection Features upload)
                    if(finalstring != ''){
                       objNewCA.addError(finalstring);
                    }
                }//END_OF_IF
                else{
                    if(mapStrTolstError.containsKey('Gap')) {
                        objNewCA.addError(Label.Gap_between_the_dates);
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('Gap')) {
                            objNewCA.addError(i + '. ' + s);
                            if(i < mapStrTolstError.get('Gap').size())
                                i++;
                        }
                        if(mapStrTolstError.containsKey('StartEnd') || mapStrTolstError.containsKey('Start') || mapStrTolstError.containsKey('End'))
                            objNewCA.addError('---------------------------------------------------------------------------------------------------------------------------------------------------------------- ');
                    }
                
                    if(mapStrTolstError.containsKey('StartEnd')) {
                        objNewCA.addError(Label.Start_End_date_align_msg);
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('StartEnd')) {
                            objNewCA.addError(i + '. ' + s);
                            if(i < mapStrTolstError.get('StartEnd').size())
                                i++;
                        }
                        if(mapStrTolstError.containsKey('Start') || mapStrTolstError.containsKey('End'))
                            objNewCA.addError('---------------------------------------------------------------------------------------------------------------------------------------------------------------- ');
                    }
                    if(mapStrTolstError.containsKey('Start')) {
                        objNewCA.addError(Label.Start_date_align_msg);
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('Start')) {
                            objNewCA.addError(i + '. ' + s);
                            if(i < mapStrTolstError.get('Start').size())
                                i++;
                        }
                        if(mapStrTolstError.containsKey('End'))
                            objNewCA.addError(' ---------------------------------------------------------------------------------------------------------------------------------------------------------------- ');
                    }
                    String finalstring = '';
                    if(mapStrTolstError.containsKey('End')) {
                        objNewCA.addError(Label.End_date_align_msg);
                        Integer i = 1;
                        finalstring += Label.End_date_align_msg;
                        for(String s : mapStrTolstError.get('End')) {
                            objNewCA.addError(i + '. ' + s);
                            if(i < mapStrTolstError.get('End').size())
                                i++;
                        }
                    }
                    //SINC1584525
                    if(mapStrTolstError.containsKey('Status')) {
                        objNewCA.addError(Label.Invalid_Status_Msg);
                        Integer i = 1;
                        for(String s : mapStrTolstError.get('Status')) {
                            objNewCA.addError(i + '.' + s);
                            if(i < mapStrTolstError.get('Status').size())
                                i++;
                        }
                    }
                }
                
             }//END_OF_FOR
        }
    }
    
    //ER-476: Update Pricing Lookup
    //Logic Modified By Trupti For ER-886
    public static void updatePricing(List<Client_Avail__c> newAvails, map<Id,Client_Avail__c> oldMap)
    {
        List<Pricing__c> lstPricingTiers = new List<Pricing__c>();
        List<Client_Avail__c> availsInScope = new List<Client_Avail__c>();
        Map<String,Pricing__c> allPriceTiers = new Map<String,Pricing__c>();
        List<Client_Avail__c> caRateCardNullList = new List<Client_Avail__c>();
        for(Client_Avail__c clientAvail : newAvails)
        {
            /*SINC1557841 
            Updated on 16 March,2018*/
            //if(clientAvail.Status__c == 'Confirmed') 
                if(clientAvail.Pricing__c == NULL && clientAvail.Price_Tier_Text__c != null && !clientAvail.CA_CRM_Country__c)
                    availsInScope.add(clientAvail);
                if(clientAvail.CA_Rate_Card__c == Null && clientAvail.CA_CRM_Country__c && ((clientAvail.Price_Tier_Text__c != Null && clientAvail.Price_Tier_Text__c != '' && clientAvail.Price_Tier_Text__c != 'TBD') || clientAvail.Price__c != Null)){
                    caRateCardNullList.add(clientAvail);
                }
        }
        if(availsInScope != NULL && availsInScope.size()>0)
        {
            Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(availsInScope);
            Map<Id,List<Pricing__c>> mapCAwithPricingRecords = new Map<Id,List<Pricing__c>>();
             
            for(Client_Avail__c ca : availsInScope)
            {
                if(ca.Price_Tier_Text__c != null || ca.Price_Tier_Text__c != '')
                {
                    if(mapPricingRecords != null && mapPricingRecords.size() > 0)
                    {
                        if(mapPricingRecords.get(ca.Client__c) != null &&
                        mapPricingRecords.get(ca.Client__c).get(ca.Release_Plan_Country__c) != null &&
                        mapPricingRecords.get(ca.Client__c).get(ca.Release_Plan_Country__c).get(ca.Release_Plan_Format__c) != null &&
                        mapPricingRecords.get(ca.Client__c).get(ca.Release_Plan_Country__c).get(ca.Release_Plan_Format__c).get(ca.Release_Plan_Channel__c) != null &&
                        mapPricingRecords.get(ca.Client__c).get(ca.Release_Plan_Country__c).get(ca.Release_Plan_Format__c).get(ca.Release_Plan_Channel__c).get(ca.Title_Content_Type__c) != null)
                        {
                            //get matching pricing records in the list
                            allPriceTiers = mapPricingRecords.get(ca.Client__c).get(ca.Release_Plan_Country__c).get(ca.Release_Plan_Format__c).get(ca.Release_Plan_Channel__c).get(ca.Title_Content_Type__c);
                            lstPricingTiers = allPriceTiers.values();
                            
                            for(Pricing__c pricing :lstPricingTiers) 
                            {
                                if(pricing.Price_Tier__c != null && pricing.Price_Tier__c != ''){
                                    if(ca.Price_Tier_Text__c == pricing.Price_Tier__c) {
                                        if(!mapCAwithPricingRecords.containsKey(ca.Id))
                                            mapCAwithPricingRecords.put(ca.Id, new List<pricing__c>());
                                        mapCAwithPricingRecords.get(ca.Id).add(pricing);
                                        
                                            
                                    }
                                }
                            }
                                
                            //if(mapCAwithPricingRecords.get(ca.Id) !=NULL)
                              //  system.debug('mapCAwithPricingRecords***'+mapCAwithPricingRecords.get(ca.Id).size()+'   Id***'+ca.Id);
                            
                            if(mapCAwithPricingRecords.get(ca.Id)!= NULL){
                                Integer count = 0;
                                for(Pricing__c p: mapCAwithPricingRecords.get(ca.Id)) {
                                   if(p.Account_Price__c != NULL) {
                                         ca.Pricing__c = p.Id;
                                         break;
                                    } 
                                    else
                                        count++;
                                }
                                if(count == mapCAwithPricingRecords.get(ca.Id).size()){
                                    ca.Pricing__c = mapCAwithPricingRecords.get(ca.Id)[0].Id;
                                }
                            }
                             
                            /*SINC1557841 
                            Updated on 16 March,2018*/
                            /*else{
                                //ca.Pricing__c = NULL;
                            }*/
                        }
                    }
                }
                /*SINC1557841 
                Updated on 16 March,2018*/
                //Delink the existing pricing lookup in CA 
                /*else 
                    ca.Pricing__c = NULL;*/
            }
        }
        
        if(caRateCardNullList != Null && caRateCardNullList.size()>0){
            WB_RateCardHelper.assignRateCardToCA(caRateCardNullList);
        }
    }   
}