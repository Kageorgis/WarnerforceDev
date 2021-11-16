/******* 
Name:WB_StorefrontAssociateClientAvail
Creation Date- 29 Oct 2014
Last Modified Date -
Last Modified by  - 
Description- Automatically Associate A Storefront to a Client Avail Upon Creation of a Client Avail
Author- Imran Hussain
*******/

public with sharing class WB_StorefrontAssociateClientAvail{
    
    public static void storefrontAssociateWithClientAvailBefore(){
            List<Client_Avail__c> lst_client_avails = new List<Client_Avail__c>();
            List<Id> lst_accounts = new List<Id>();
            Set<String> lst_countries = new Set<String>();
            List<String> lst_CommericalAvailsIds = new List<String>();
            List<Agreement__c> lst_Storefornts = new List<Agreement__c>();
            lst_client_avails  = trigger.new;
            set<id> caIdsList = new set<id>();
            set<id> storefrontListCount= new set<id>();
            integer counter=0;  
            Boolean isStorefrontNull = false;          
            for(Client_Avail__c  calists: lst_client_avails){
                caIdsList.add(calists.Commercial_Avail__c);
                if(calists.storefront__c == Null){
                	isStorefrontNull = true;
                }
                if(calists.storefront__c!=null){
                counter++;
                }
            }
            if(!isStorefrontNull)
            	return;
            	
           
            //start channel,format,content type
            Map<Id,Commercial_Avail__c> mapLstCommercialAvail = new Map<Id,Commercial_Avail__c>([SELECT Id,Name,
                                                              Title__r.Content_Type__c,
                                                              Channel__c,Country_Lookup__c,
                                                              Format__c
                                                              FROM Commercial_Avail__C
                                                              WHERE Id IN: caIdsList]);
            list<Commercial_Avail__C> lst_Commercial_Avail = mapLstCommercialAvail.values();
                                                              
            
            for(integer i=0;i<lst_client_avails.size();i++){
                lst_accounts.add(lst_client_avails[i].Client__c);
                lst_countries.add(lst_client_avails[i].Release_Plan_Country__c);
                
            }
            
            Map<Id,Agreement__c> mapLstStorefronts = new Map<Id,Agreement__c>([SELECT Id,Name,Account__c,Channel_Picklist__c,Content_Type__c,Format__c,Country__c,CountryName__c,Status__c From Agreement__c WHERE Country__r.name IN:lst_countries 
                           AND Account__c IN:lst_accounts]);
            lst_Storefornts = mapLstStorefronts.values();

            map<id,set<string>> mapStorefrontChannels = new  map<id,set<string>>();//Map for distinguish which channel is for which storefront
            map<id,set<string>> mapstorefrontFormats = new  map<id,set<string>>();
            map<id,set<string>> mapstorefrontContentTypes = new  map<id,set<string>>();
            
                                                          
            for(Agreement__c strfrnt : lst_Storefornts){
                set<string> storefrontChannels = new set<string>();//intialize here otherwise it will have old channel valuw for previous storefront
                list<string> storefrontChannels2 = new list<string>();//For Split
                if(strfrnt.Channel_Picklist__c!=null){
                    storefrontChannels2=strfrnt.Channel_Picklist__c.toLowerCase().split(';');            
                    storefrontChannels.addAll(storefrontChannels2);
                    mapStorefrontChannels.put(strfrnt.Id,storefrontChannels);
                }
                    set<string> storefrontContentTypes = new set<string>();
                    list<string> storefrontContentTypes2 = new list<string>();
                if(strfrnt.Content_Type__c!=null){
                    storefrontContentTypes2=strfrnt.Content_Type__c.toLowerCase().split(';');
                    storefrontContentTypes.addAll(storefrontContentTypes2);
                    mapstorefrontContentTypes.put(strfrnt.Id,storefrontContentTypes);
                }
                set<string> storefrontFormats = new set<string>();
                list<string> storefrontFormats2 = new list<string>();
                if(strfrnt.Format__c!=null){
                    storefrontFormats2=strfrnt.Format__c.toLowerCase().split(';');
                    storefrontFormats.addAll(storefrontFormats2);
                    mapstorefrontFormats.put(strfrnt.Id,storefrontFormats);
                }
            }
            
            
                boolean chkFlag = false;
                boolean chkStatus = false; // Active status for storefront is only apllicable on creation of client avail Defect 145
            for(Client_Avail__c clientAvails: lst_client_avails){    
                for (Commercial_Avail__c ca: lst_Commercial_Avail){
                    for(Agreement__c  agreement: lst_Storefornts ){
                        if(clientAvails.Commercial_Avail__c == ca.Id && clientAvails.Client__c == agreement.Account__c){
                            if(ca.Country_Lookup__c== agreement.Country__c ){ 
                                   if( mapStorefrontChannels.size() != 0 && mapstorefrontFormats.size()!= 0&& mapstorefrontContentTypes.size()!= 0){
                                    if( mapStorefrontChannels.get(agreement.Id) != null && mapstorefrontFormats.get(agreement.Id)!= null&& mapstorefrontContentTypes.get(agreement.Id)!= null){
                                        if(agreement.Status__c == 'Active'){
                                            chkStatus = true ;
                                           if(mapStorefrontChannels.get(agreement.Id).contains(ca.Channel__c.toLowerCase()) && 
                                              mapstorefrontFormats.get(agreement.Id).contains(ca.Format__c.toLowerCase()) &&
                                              mapstorefrontContentTypes.get(agreement.Id).contains(ca.Title__r.Content_Type__c.toLowerCase())){
                                              
                                                chkFlag = true;
                                                clientAvails.Storefront__c = agreement.Id;
                                                
                                            }
                                        }
                                   }
                               } 
                        }
                      }  
                }
            }
         }   
            //end channel,format,content type
                             
            for(integer i=0;i<lst_client_avails.size();i++){
                lst_accounts.add(lst_client_avails[i].Client__c);
                lst_countries.add(lst_client_avails[i].Release_Plan_Country__c);
                
            }
        
        
        if(lst_Storefornts.size() == 0){
            lst_client_avails[0].Storefront__c.addError('No Storefornt is available for selected Release Plan country and Account');
        }
        if(chkStatus == false){
            lst_client_avails[0].Storefront__c.addError('Please check  Status of the Storefront');
        }     
        if(chkFlag == false && chkStatus == true){
            lst_client_avails[0].Storefront__c.addError('Please check Channel,Format,Content Type ');
        } 
    }
    
    public static void storefrontAssociateWithClientAvailBeforeUpdate(){
            List<Client_Avail__c> lst_client_avails = new List<Client_Avail__c>();
            List<Id> lst_accounts = new List<Id>();
            Set<String> lst_countries = new Set<String>();
            List<String> lst_CommericalAvailsIds = new List<String>();
            List<Agreement__c> lst_Storefornts = new List<Agreement__c>();
            
            lst_client_avails  = trigger.new;
            set<id> caIdsList = new set<id>();
            set<id> storefrontListCount= new set<id>();
            integer counter=0;            
            Boolean isEitherSFOrRP = false;
            for(Client_Avail__c  calists: lst_client_avails){
                Client_Avail__c oldAvail = (Client_Avail__c)trigger.oldMap.get(calists.Id);
                caIdsList.add(calists.Commercial_Avail__c);
                if((calists.Storefront__c == Null) || (calists.Commercial_Avail__c != oldAvail.Commercial_Avail__c)){
                	isEitherSFOrRP = true;
                }
               
            }
            if(!isEitherSFOrRP)
            	return;
            //start channel,format,content type
            Map<Id,Commercial_Avail__c> mapLstCommercial2 = new Map<id,Commercial_Avail__c>([SELECT Id,Name,
                                                              Title__r.Content_Type__c,
                                                              Channel__c,Country_Lookup__c,
                                                              Format__c
                                                              FROM Commercial_Avail__C
                                                              WHERE Id IN: caIdsList]);
             list<Commercial_Avail__C> lst_Commercial_Avail = mapLstCommercial2.values();
                                                              
            
            for(integer i=0;i<lst_client_avails.size();i++){
                lst_accounts.add(lst_client_avails[i].Client__c);
                lst_countries.add(lst_client_avails[i].Release_Plan_Country__c);
                
            }
            
            Map<Id,Agreement__c> mapLstStorefronts2 = new Map<Id,Agreement__c>([SELECT Id,Name,Account__c,Channel_Picklist__c,Content_Type__c,Format__c,Country__c,CountryName__c,Status__c From Agreement__c WHERE Country__r.name IN:lst_countries 
                           AND Account__c IN:lst_accounts]);
            lst_Storefornts = mapLstStorefronts2.values();

            map<id,set<string>> mapStorefrontChannels = new  map<id,set<string>>();//Map for distinguish which channel is for which storefront
            map<id,set<string>> mapstorefrontFormats = new  map<id,set<string>>();
            map<id,set<string>> mapstorefrontContentTypes = new  map<id,set<string>>();
            
       
            for(Agreement__c strfrnt : lst_Storefornts){
                set<string> storefrontChannels = new set<string>();//intialize here otherwise it will have old channel valuw for previous storefront
                list<string> storefrontChannels2 = new list<string>();//For Split
                if(strfrnt.Channel_Picklist__c!=null){
                    storefrontChannels2=strfrnt.Channel_Picklist__c.toLowerCase().split(';');            
                    storefrontChannels.addAll(storefrontChannels2);
                    mapStorefrontChannels.put(strfrnt.Id,storefrontChannels);
                }
                    set<string> storefrontContentTypes = new set<string>();
                    list<string> storefrontContentTypes2 = new list<string>();
                if(strfrnt.Content_Type__c!=null){
                    storefrontContentTypes2=strfrnt.Content_Type__c.toLowerCase().split(';');
                    storefrontContentTypes.addAll(storefrontContentTypes2);
                    mapstorefrontContentTypes.put(strfrnt.Id,storefrontContentTypes);
                }
                set<string> storefrontFormats = new set<string>();
                list<string> storefrontFormats2 = new list<string>();
                if(strfrnt.Format__c!=null){
                    storefrontFormats2=strfrnt.Format__c.toLowerCase().split(';');
                    storefrontFormats.addAll(storefrontFormats2);
                    mapstorefrontFormats.put(strfrnt.Id,storefrontFormats);
                }
            }
            
               boolean chkFlag = false;
                for(Client_Avail__c clientAvails: lst_client_avails){    
                for (Commercial_Avail__c ca: lst_Commercial_Avail){
                    for(Agreement__c  agreement: lst_Storefornts ){
                        if(clientAvails.Commercial_Avail__c == ca.Id && clientAvails.Client__c == agreement.Account__c){
                            if(ca.Country_Lookup__c== agreement.Country__c){ 
                                   if( mapStorefrontChannels.size() != 0 && mapstorefrontFormats.size()!= 0&& mapstorefrontContentTypes.size()!= 0){
                                    if( mapStorefrontChannels.get(agreement.Id) != null && mapstorefrontFormats.get(agreement.Id)!= null && mapstorefrontContentTypes.get(agreement.Id)!= null){
                                       if(mapStorefrontChannels.get(agreement.Id).contains(ca.Channel__c.toLowerCase()) && 
                                          mapstorefrontFormats.get(agreement.Id).contains(ca.Format__c.toLowerCase()) &&
                                          mapstorefrontContentTypes.get(agreement.Id).contains(ca.Title__r.Content_Type__c.toLowerCase())){
                                          
                                            chkFlag = true;
                                            clientAvails.Storefront__c = agreement.Id;
                                            
                                    }
                                   }
                               } 
                        }
                      }  
                }
            }
         }   
            //end channel,format,content type
                             
            for(integer i=0;i<lst_client_avails.size();i++){
                lst_accounts.add(lst_client_avails[i].Client__c);
                lst_countries.add(lst_client_avails[i].Release_Plan_Country__c);
                
            }
        
        
        if(lst_Storefornts.size() == 0){
            lst_client_avails[0].Storefront__c.addError('No Storefornt is available for selected Release Plan country and Account');
        }
        // Commented by Shalini to remove the storefront error on Client Avail Edit - ER-000031
        if(!chkFlag){
            //lst_client_avails[0].Storefront__c.addError('Please check Channel,Format,Content Type ');

        } 
        
    }
    
    
    // CH 07: ECLM : Populate EC Available field based on the values entered in fields.
    public static void PopulateECAvailField(List<Client_Avail__c> CAList)
    {
        set<Id> setStorefrontIds = new set<Id>();
        set<Id> setReleasePlanIds = new set<Id>();
        set<Id> setTitleIds = new set<Id>();
        set<Id> setAccountIds = new set<Id>();
        set<String> setFormats = new set<String>();
        for(Client_Avail__c clientAvail : CAList)
        {
            setReleasePlanIds.add(clientAvail.Commercial_Avail__c);
            setStorefrontIds.add(clientAvail.Storefront__c);
            setAccountIds.add(clientAvail.Client__c);
        }
        Map<Id,Agreement__c> storefrontMap = new Map<Id,Agreement__c>([Select id,Formats_with_EC__c from Agreement__c where id =: setStorefrontIds]);
        Map<Id,Commercial_Avail__c> ReleaseplanMap = new Map<Id,Commercial_Avail__c>([Select id,Title__c,Channel__c,Format__c from Commercial_Avail__c where id =: setReleasePlanIds]);
        Map<Id,List<EC_Title_Allocation__c>> mapTitleECAllocation = new Map<Id,List<EC_Title_Allocation__c>>();
        // Store Account Id,Title Id,Format and respective EC Account Allocation reocords.
        Map<Id,Map<Id,Map<String,set<EC_Account_Allocation__c>>>> mapAccountTitleFormatECAllocation = new Map<Id,Map<Id,Map<String,set<EC_Account_Allocation__c>>>>();
        for(Commercial_Avail__c rp : ReleaseplanMap.values())
        {
            setFormats.add(rp.Format__c);
            setTitleIds.add(rp.Title__c);
        }
        
        // Get All EC Account Allocation records for processing client avails
        for(EC_Account_Allocation__c accAllocation : [SELECT id,Account__c,Format__c,Title__c FROM EC_Account_Allocation__c 
                                                      WHERE Account__c in: setAccountIds 
                                                      AND Format__c in: setFormats 
                                                      AND Title__c in: setTitleIds])
        {
            if(!mapAccountTitleFormatECAllocation.containskey(accAllocation.Account__c))
                mapAccountTitleFormatECAllocation.put(accAllocation.Account__c, new Map<Id,Map<String,set<EC_Account_Allocation__c>>>());
            if(!mapAccountTitleFormatECAllocation.get(accAllocation.Account__c).containskey(accAllocation.Title__c))
                mapAccountTitleFormatECAllocation.get(accAllocation.Account__c).put(accAllocation.Title__c, new Map<String,set<EC_Account_Allocation__c>>());
            if(!mapAccountTitleFormatECAllocation.get(accAllocation.Account__c).get(accAllocation.Title__c).containskey(accAllocation.Format__c))
                mapAccountTitleFormatECAllocation.get(accAllocation.Account__c).get(accAllocation.Title__c).put(accAllocation.Format__c ,new set<EC_Account_Allocation__c>());
            mapAccountTitleFormatECAllocation.get(accAllocation.Account__c).get(accAllocation.Title__c).get(accAllocation.Format__c).add(accAllocation);
        }
            
        // Process Client Avail Records
        for(Client_Avail__c clientAvail : CAList)
        {
            // if Client avail not created from Reprice wizard then check for EC Available.
            if(!clientAvail.Created_From_RePrice_Flag__c)
            {
                if(ReleaseplanMap.get(clientAvail.commercial_avail__c).Channel__c == 'EST')
                {
                    //system.debug('=============First Condition Satisfied=============');
                    //SINC1125828 - Added first part in below if condition.
                    if(storefrontMap.get(clientAvail.Storefront__c) != null && storefrontMap.get(clientAvail.Storefront__c).Formats_with_EC__c != null)
                    {
                        Set<String> setECFormats = new Set<String>(storefrontMap.get(clientAvail.Storefront__c).Formats_with_EC__c.split(';'));
                        if(setECFormats.contains(ReleaseplanMap.get(clientAvail.commercial_avail__c).Format__c))
                        {
                            //system.debug('=============Second Condition Satisfied=============');

                            if(mapAccountTitleFormatECAllocation.containskey(clientAvail.Client__c) && 
                                mapAccountTitleFormatECAllocation.get(clientAvail.Client__c).containskey(ReleaseplanMap.get(clientAvail.commercial_avail__c).Title__c) &&
                                mapAccountTitleFormatECAllocation.get(clientAvail.Client__c).get(ReleaseplanMap.get(clientAvail.commercial_avail__c).Title__c).containskey(ReleaseplanMap.get(clientAvail.commercial_avail__c).Format__c) &&
                                mapAccountTitleFormatECAllocation.get(clientAvail.Client__c).get(ReleaseplanMap.get(clientAvail.commercial_avail__c).Title__c).get(ReleaseplanMap.get(clientAvail.commercial_avail__c).Format__c).size() > 0)
                            {
                                //system.debug('=============Third & Forth Condition Satisfied=============');
                                clientAvail.EC_Available__c='Yes';
                            }
                        }
                    }
                }
            }
        }
    }
    
}