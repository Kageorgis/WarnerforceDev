global class WB_Update_Price_Tier_Handler
{
    WebService static String updateSingleClientAvailPriceTier(String recordId)
    {
        if(recordId != null)
        {
            try
            {
                List<Client_Avail__c> listClientAvail = new List<Client_Avail__c>([SELECT id,Price_Code__c,Name,Price_Tier_Text__c,Client__c,Price__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,Title_Content_Type__c,Local_Title__r.Price_Code__c from Client_Avail__c where id =: recordId]);
                /*Pricing__c pricingRecord = [Select id,Price_Tier__c from Pricing__c 
                                            where Account__c=: listClientAvail[0].Client__c
                                            AND Country__r.Name=: listClientAvail[0].Release_Plan_Country__c
                                            AND Channel__c=: listClientAvail[0].Release_Plan_Channel__c
                                            AND Format__c=: listClientAvail[0].Release_Plan_Format__c
                                            AND Content_Type__c=: listClientAvail[0].Title_Content_Type__c
                                            AND Name=: listClientAvail[0].Local_Title__r.Price_Code__c LIMIT 1];
                 if(pricingRecord != null)
                 {
                     listClientAvail[0].Price_Tier_Text__c = pricingrecord.Price_Tier__c;
                     update listClientAvail;
                     return 'Record updated successfully.';
                 }
                
                if(listClientAvail[0].Price__c != null)
                    return 'Price Tier cant be updated if WS Cost exist.';
                 */
                 
                  /*  Long startTime = DateTime.now().getTime();
                    Long finishTime = DateTime.now().getTime();
                    while ((finishTime - startTime) < 5000) {
                       //sleep for 9s
                      finishTime = DateTime.now().getTime(); 
                    } */
                   // System.assertEquals(Integer.valueOf((finishTime - startTime) / 1000), 9);
                   // System.debug('>>> Done from ' + startTime + ' to ' + finishTime);
                 
                 
                if(listClientAvail[0].Local_Title__r.Price_Code__c == null || listClientAvail[0].Local_Title__r.Price_Code__c == '')
                    return Label.WB_Price_code_Not_Available; //+ '(' + listClientAvail[0].Name + ')';
                Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = getPricingRecordsByPriceCode(listClientAvail);
                if(mapPricingRecords != null && mapPricingRecords.size() > 0)
                {           
                    Pricing__c pricingrecord = mapPricingRecords.get(listClientAvail[0].Client__c).get(listClientAvail[0].Release_Plan_Country__c).get(listClientAvail[0].Release_Plan_Format__c).get(listClientAvail[0].Release_Plan_Channel__c).get(listClientAvail[0].Title_Content_Type__c).get(listClientAvail[0].Local_Title__r.Price_Code__c);
                    if(pricingrecord != null)
                    {
                        listClientAvail[0].Price_Tier_Text__c = pricingrecord.Price_Tier__c;
                        listClientAvail[0].Price__c = pricingrecord.WS_Price__c;
                        listClientAvail[0].SR_Price__c = pricingrecord.SR_Price__c;
                        listClientAvail[0].Episode_Price_Tier__c = pricingrecord.Episode_Price_Tier__c;
                        listClientAvail[0].Episode_Price__c = pricingrecord.Episode_Price__c;
                        listClientAvail[0].SR_Per_Episode__c = pricingrecord.SR_Per_Episode__c;                                                                                                
                        update listClientAvail;
                        return Label.WB_Client_Avail_Record_Updated; //+ '(' + listClientAvail[0].Name + ')';
                    }
                    else
                        return Label.WB_Pricing_Record_Not_Available;  //+ '(' + listClientAvail[0].Name + ')'; 
                } 
                else
                    return Label.WB_Pricing_Record_Not_Available; //+ '(' + listClientAvail[0].Name + ')';                
            }
            catch(Exception e){
                return e.getmessage();
            }
        }
        else 
            return 'Wrong id';
        return null;
    } 
    
    // Method return the map of all combonation and their matching Price Tier values. 
    // Method accepts paramter as list of client avails which contains Client__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,Title_Content_Type__c,Local_Title__r.Price_Code__c
        global static Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> getPricingRecords(List<client_avail__c> listClientAvail)
    {
        // Account Id,Country,Format,Channel,Content Type,PriceCode.
        Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = new Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>>();
        
        set<Id> listAccountIds = new set<Id>();
        set<String> listContentTypes = new set<String>();
        set<String> listChannels = new set<String>();
        set<String> listFormats = new set<String>();
        set<String> listCountries = new set<String>();
        set<String> listPriceCodes = new set<String>();
        
        for(client_avail__c clientAvail : listClientAvail)
        {
            listAccountIds.add(clientAvail.Client__c);
            listChannels.add(clientAvail.Release_Plan_Channel__c);
            listFormats.add(clientAvail.Release_Plan_Format__c);
            listCountries.add(clientAvail.Release_Plan_Country__c);
            listContentTypes.add(clientAvail.Title_Content_Type__c);
            if(clientAvail.Title_Content_Type__c == 'Season'){
                listContentTypes.add('Episode');
            }
            //listPriceCodes.add(clientAvail.Local_Title__r.Price_Code__c);  //Commented by Tushar as it is not being used
           
        }
        List<Pricing__c> listPricing = [SELECT Name,Account__c,Channel__c,Format__c,Account_Price__c,Content_Type__c,Country__c,Country__r.Name,Price_Tier__c,WS_Price__c,SR_Price__c,Episode_Price_Tier__c,Episode_Price__c,SR_Per_Episode__c,Price_Code_Status__c FROM Pricing__c
                                        WHERE Account__c in: listAccountIds AND Channel__c in: listChannels AND Format__c in: listFormats
                                        AND Country__r.Name in: listCountries AND Content_Type__c in: listContentTypes]; //AND Name in: listPriceCodes]; sriniz comment
        if(listPricing != null && listPricing.size() > 0)
        {
            for(Pricing__c pricingRecord : listPricing)
            {
                // Add account
                if(!mapPricingRecords.containskey(pricingRecord.Account__c)){
                    mapPricingRecords.put(pricingRecord.Account__c,new Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>());
                }
                // Add Country Name    
                if(!mapPricingRecords.get(pricingRecord.Account__c).containskey(pricingRecord.Country__r.Name)){
                    mapPricingRecords.get(pricingRecord.Account__c).put(pricingRecord.Country__r.Name,new Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>());
                }
                // Add Format
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).containskey(pricingRecord.Format__c)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).put(pricingRecord.Format__c,new Map<String,Map<String,Map<String,Pricing__c>>>());
                }    
                // Add Channel
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).containskey(pricingRecord.Channel__c)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).put(pricingRecord.Channel__c,new Map<String,Map<String,Pricing__c>>());
                }
                // Add Content Type
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).containskey(pricingRecord.Content_Type__c)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).put(pricingRecord.Content_Type__c,new Map<String,Pricing__c>());
                }
                // Add Price code
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).containskey(pricingRecord.Name)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).put(pricingRecord.Name,pricingRecord);    
                } 
                // Add related Price Tier values for related combination.    
                //mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).get(pricingRecord.Name).add(pricingRecord.Price_Tier__c);  
            }
        }
        return mapPricingRecords;
    }
    // Method return the map of all combonation and their matching Price Tier values. 
    // Method accepts paramter as list of client avails which contains Client__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,Title_Content_Type__c,Local_Title__r.Price_Code__c
    global static Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> getPricingRecordsByPriceCode(List<client_avail__c> listClientAvail)
    {
        // Account Id,Country,Format,Channel,Content Type,PriceCode.
        Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = new Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>>();
        
        set<Id> listAccountIds = new set<Id>();
        set<String> listContentTypes = new set<String>();
        set<String> listChannels = new set<String>();
        set<String> listFormats = new set<String>();
        set<String> listCountries = new set<String>();
        set<String> listPriceCodes = new set<String>();
        for(client_avail__c clientAvail : listClientAvail)
        {
            listAccountIds.add(clientAvail.Client__c);
            listChannels.add(clientAvail.Release_Plan_Channel__c);
            listFormats.add(clientAvail.Release_Plan_Format__c);
            listCountries.add(clientAvail.Release_Plan_Country__c);
            listContentTypes.add(clientAvail.Title_Content_Type__c); 
            listPriceCodes.add(clientAvail.Local_Title__r.Price_Code__c);
        }
        
        List<Pricing__c> listPricing = [SELECT Name,Account__c,Channel__c,Format__c,Content_Type__c,Country__c,Country__r.Name,Price_Tier__c,WS_Price__c,SR_Price__c,Episode_Price_Tier__c,Episode_Price__c,SR_Per_Episode__c FROM Pricing__c
                                        WHERE Account__c in: listAccountIds AND Channel__c in: listChannels AND Format__c in: listFormats
                                        AND Country__r.Name in: listCountries AND Content_Type__c in: listContentTypes AND Name in: listPriceCodes]; 
        if(listPricing != null && listPricing.size() > 0)
        {
            for(Pricing__c pricingRecord : listPricing)
            {
                // Add account
                if(!mapPricingRecords.containskey(pricingRecord.Account__c)){
                    mapPricingRecords.put(pricingRecord.Account__c,new Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>());
                }
                // Add Country Name    
                if(!mapPricingRecords.get(pricingRecord.Account__c).containskey(pricingRecord.Country__r.Name)){
                    mapPricingRecords.get(pricingRecord.Account__c).put(pricingRecord.Country__r.Name,new Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>());
                }
                // Add Format
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).containskey(pricingRecord.Format__c)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).put(pricingRecord.Format__c,new Map<String,Map<String,Map<String,Pricing__c>>>());
                }    
                // Add Channel
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).containskey(pricingRecord.Channel__c)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).put(pricingRecord.Channel__c,new Map<String,Map<String,Pricing__c>>());
                }
                // Add Content Type
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).containskey(pricingRecord.Content_Type__c)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).put(pricingRecord.Content_Type__c,new Map<String,Pricing__c>());
                }
                // Add Price code
                if(!mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).containskey(pricingRecord.Name)){
                    mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).put(pricingRecord.Name,pricingRecord);    
                }
                // Add related Price Tier values for related combination.    
                //mapPricingRecords.get(pricingRecord.Account__c).get(pricingRecord.Country__r.Name).get(pricingRecord.Format__c).get(pricingRecord.Channel__c).get(pricingRecord.Content_Type__c).get(pricingRecord.Name).add(pricingRecord.Price_Tier__c);  
            }
        }
        return mapPricingRecords;
    }

    
}