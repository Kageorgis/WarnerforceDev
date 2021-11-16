public class WB_RePriceClientAvails_Handler {
    
    public Date datename;
    public date previousEndDate;
    public String Message;
    public boolean showMessageParam=false;
    
    List<String> messageList;
    
    map<string, list<String>> localErrorMessageMap;
    
    public map<string, List<String>> updateprice(Client_Avail__c obj, List<String> selectedClientAvailIds, Id loggedInUserId, Boolean isRunningBatch){
        messageList = new List<String>();
        localErrorMessageMap = new map<string, list<String>>();
        
        List<Client_Avail_Wizard_Exceptions__c> CAWizardExceptionList = new List<Client_Avail_Wizard_Exceptions__c>();
        
        list<Schema.FieldSetMember> selectedClientAvailforClone_list = new list<Schema.FieldSetMember>();
        list<Client_Avail__c> selectedClientAvail_list3 = new list<Client_Avail__c>();
        list<Client_Avail__c> filteredClientAvail_list = new list<Client_Avail__c>();
        list<Client_Avail__c> clientAvailUpdate_list = new list<Client_Avail__c>();
        list<Client_Avail__c> newlyCreatedClientAvail_list = new list<Client_Avail__c>();
        
        selectedClientAvailforClone_list = Schema.SObjectType.Client_Avail__c.fieldSets.getMap().get('All_fields_Client_avail').getFields();
        String strquery = 'SELECT ';
        for(Schema.FieldSetMember f : selectedClientAvailforClone_list ){
            strquery += f.getFieldPath()+ ', ';
        }
        strquery += 'Id,EC_Available__c,Local_Title__r.Price_Code__c,Local_Data_Category_Picklist__c,Local_Title__r.Local_Category__c,Recalculate_Playlist_Avails__c FROM Client_Avail__c where Id IN:selectedClientAvailIds AND Avail_Type__c != \'Automated\'';
        selectedClientAvail_list3 =Database.query(strquery);
        
        list<string> releasePlnIds = new list<string>();
        list<string> priceCodes = new list<string>();
        map<id,string> releasPlnPriceCode = new map<id,string>();
            
        list<Client_Avail__c> finalFilteredselectedClientAvail_list = new list<Client_Avail__c>();
        system.debug('selectedClientAvail_list3==: ' + selectedClientAvail_list3);
        /*
        for(Client_Avail__c clientAvail : selectedClientAvail_list3)
        {
            if(clientAvail.Local_Title__c != null) // && clientAvail.Local_Title__r.Price_Code__c != null ER-15 sriniz
            {
                if(!obj.Use_Price_Codes__c)
                {
                    if(clientAvail.Price_Tier_Text__c != obj.Price_Tier_Text__c){
                        finalFilteredselectedClientAvail_list.add(clientAvail);
                    }
                }
                else
                    finalFilteredselectedClientAvail_list.add(clientAvail);
            }
        } */
        
        for(Client_Avail__c clientAvail : selectedClientAvail_list3)
        {
            if(clientAvail.Local_Title__c != null) // && clientAvail.Local_Title__r.Price_Code__c != null ER-15 sriniz
            {
                if(!obj.Use_Price_Codes__c)
                {
                    if(clientAvail.Price_Tier_Text__c != obj.Price_Tier_Text__c || 
                       clientAvail.Price__c != obj.Price__c || 
                       clientAvail.SR_Price__c != obj.SR_Price__c || 
                       clientAvail.Episode_Price_Tier__c != obj.Episode_Price_Tier__c || 
                       clientAvail.Episode_Price__c != obj.Episode_Price__c || 
                       clientAvail.SR_Per_Episode__c != obj.SR_Per_Episode__c
                      )
                        finalFilteredselectedClientAvail_list.add(clientAvail);
                }
                else
                    finalFilteredselectedClientAvail_list.add(clientAvail);
            }
        }

        datename = obj.Effective_Price_Date__c;
        previousEndDate = datename.addDays(-1) ;//End Date to update for existing client avails.
        
        boolean flagPriceTier = false;
        if(obj.Price__c != Null && obj.Price_Tier_Text__c != Null ){
            flagPriceTier = true;
        }
        system.debug('finalFilteredselectedClientAvail_list==: ' + finalFilteredselectedClientAvail_list);
        for(Client_Avail__c clientAvail :finalFilteredselectedClientAvail_list){
           system.debug('Date ===: ' + clientAvail.Start_Date__c + ' : ' + datename + ' : ' + clientAvail.End_Date__c);
           if(clientAvail.Start_Date__c < datename && clientAvail.End_Date__c >= datename){
               filteredClientAvail_list.add(clientAvail);
           }
           else{
                showMessageParam=true;         //ER-15 sriniz
                CAWizardExceptionList.add(//ER-417
                    new Client_Avail_Wizard_Exceptions__c(
                        Account__c = clientAvail.Client__r.Name,
                        Country__c = clientAvail.Release_Plan_Country__c,
                        Language__c = clientAvail.Release_Plan_Language__c,
                        Format__c = clientAvail.Release_Plan_Format__c,
                        Channel__c = clientAvail.Release_Plan_Channel__c,
                        Title__c = clientAvail.Release_Plan_Title__c,
                        User_Detail__c = UserInfo.getUserId(),
                        Price_Tier__c = clientAvail.Price_Tier_Text__c,
                        SR_Price__c = clientAvail.SR_Price__c,
                        WS_Price__c = clientAvail.Price__c,
                        ClientAvail_Start_Date__c = clientAvail.Start_Date__c,
                        ClientAvail_End_Date__c = clientAvail.End_Date__c,
                        Reason__c = 'Effective Price Date should lie within Client Start and Client End. Please select different Effective Price Date',
                        Name = clientAvail.Id
                    )
                );
           }
        }
        system.debug('filteredClientAvail_list==: ' + filteredClientAvail_list);
        //For Price Code logic
        for(Client_Avail__c clientAvail :filteredClientAvail_list ){
            releasePlnIds.add(clientAvail.Commercial_Avail__c);
        }
        list<Commercial_Avail__c> releasePlnRecods =[Select Local_Title__r.Price_Code__c from Commercial_Avail__c where id IN :releasePlnIds];
        
        system.debug('releasePlnRecods==: ' + releasePlnRecods);
        for(Commercial_Avail__c comm : releasePlnRecods){
            system.debug('comm.Local_Title__r.Price_Code__c==: ' + comm.Local_Title__r.Price_Code__c);
            priceCodes.add(comm.Local_Title__r.Price_Code__c);
            releasPlnPriceCode.put(comm.Id,comm.Local_Title__r.Price_Code__c);
        }
        system.debug('priceCodes ===: ' + priceCodes);
        list<Pricing__c> listPricingTable = [
            Select id,Name,Account__c,Channel__c,Format__c,Content_Type__c,Country__c,Country__r.Name,Effective_Date__c,
                   Episode_Price__c,Episode_Price_Tier__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,WS_Price__c
              from Pricing__c where Name IN:priceCodes
        ];
        
        Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(filteredClientAvail_list);
        
        Boolean PriceTierMatches=false;// CH01
        
        system.debug('obj.Use_Price_Codes__c ===: ' + obj.Use_Price_Codes__c);
        if(obj.Use_Price_Codes__c == true){
            
            system.debug('listPricingTable.size() ===: ' + listPricingTable.size());
            if(listPricingTable.size() == 0){ //&& listPricingTable == null)
                
                system.debug('filteredClientAvail_list ===: ' + filteredClientAvail_list.size());
                for(Client_Avail__c clientAvail :filteredClientAvail_list){
                    Client_Avail__c newRecod = new Client_Avail__c();
                    newRecod = clientAvail.clone(false,false,false,false);
                    newRecod.Start_Date__c = datename;
                    newRecod.End_Date__c = clientAvail.End_Date__c ;
                    newRecod.Price__c = obj.Price__c ;
                    newRecod.Price_Tier_Text__c = obj.Price_Tier_Text__c ;
                    newRecod.SR_Price__c = obj.SR_Price__c ;
                    newRecod.Change_Context__c = 'Re-Price';
                    newRecod.RP_Synch__c = false;
                    if(clientAvail.Title_Content_Type__c == 'Season'){
                        newRecod.Episode_Price__c = obj.Episode_Price__c ;
                        newRecod.SR_Per_Episode__c = obj.SR_Per_Episode__c ;
                        newRecod.Episode_Price_Tier__c = obj.Episode_Price_Tier__c ;
                    }
                    
                    Boolean isPriceTierFound = false;
                    integer priceCounter=0;
                    if(mapPricingRecords.get(clientAvail.Client__c) != null &&
                       mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c) != null &&
                       mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c) != null &&
                       mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c) != null &&
                       mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c) != null)
                    {
                        Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                        for(Pricing__c pricingRecords : allPriceTiers.values())
                        if(pricingRecords != null && obj.Price_Tier_Text__c == pricingRecords.Price_Tier__c && obj.Episode_Price_Tier__c == pricingRecords.Episode_Price_Tier__c){
                            isPriceTierFound = true;
                        }
                    }
                    
                    if(newRecod.Status__c=='Confirmed' && (obj.Price_Tier_Text__c != null|| obj.Episode_Price_Tier__c != null)){
                        if(!isPriceTierFound){ //ER-15 sriniz
                            showMessageParam=true;
                            newRecod.Status__c='Tentative';
                        }
                    } else if(newRecod.Status__c=='Confirmed' && 
                              obj.Price_Tier_Text__c == null &&
                              obj.Price__c == null &&
                              obj.SR_Price__c == null &&
                              obj.Episode_Price_Tier__c == null &&
                              obj.Episode_Price__c == null &&
                              obj.SR_Per_Episode__c == null
                             ){
                        if(!isPriceTierFound){ 
                             showMessageParam=true;
                             newRecod.Status__c='Tentative';
                        }
                    }// logic ended
                    
                    newrecod.Local_Data_Category_Picklist__c = clientAvail.Local_Title__r.Local_Category__c;
                    newrecod.EC_Available__c=clientAvail.EC_Available__c;
                    newrecod.Created_From_RePrice_Flag__c=true;
                  /*  if(newrecord.Avail_Type__c == 'Manual' && newrecord.Playlist__c != null && newrecord.Title_Content_Type__c == 'Season')
                        //system.debug('im here');
                        newrecord.Recalculate_Playlist_Avails__c = 'Insert'; */
                    newlyCreatedClientAvail_list.add(newRecod);
                    clientAvailUpdate_list.add(clientAvail);
                }
            }else{
                for(Client_Avail__c clientAvail :filteredClientAvail_list){
                    integer priceCounter=0;
                    Boolean isPriceCodeFound = false; //ER-15 sriniz
                    for(Pricing__c price :listPricingTable){
                        if(releasPlnPriceCode.get(clientAvail.Commercial_Avail__c) == price.Name){
                            isPriceCodeFound = true; //ER-15 sriniz
                            if(price.Account__c == clientAvail.Client__c && price.Channel__c == clientAvail.Release_Plan_Channel__c && price.Format__c == clientAvail.Release_Plan_Format__c&& price.Country__r.Name == clientAvail.Release_Plan_Country__c){
                                if(price.Price_Tier__c == clientAvail.Price_Tier_Text__c && 
                                       price.WS_Price__c == clientAvail.Price__c && 
                                       price.SR_Price__c == clientAvail.SR_Price__c && 
                                       price.Episode_Price_Tier__c == clientAvail.Episode_Price_Tier__c && 
                                       price.Episode_Price__c == clientAvail.Episode_Price__c && 
                                       price.SR_Per_Episode__c == clientAvail.SR_Per_Episode__c
                                      ){
                                        PriceTierMatches = true;
                                        showMessageParam=true;
                                }
                                else
                                {// CH01 : end
                                    Client_Avail__c  newRecod = new Client_Avail__c();
                                    newRecod = clientAvail.clone(false,false,false,false);
                                    newRecod.Start_Date__c = datename;
                                    newRecod.End_Date__c = clientAvail.End_Date__c ;
                                    newRecod.Price__c = price.WS_Price__c ;
                                    newRecod.Price_Tier_Text__c = price.Price_Tier__c ;
                                    newRecod.SR_Price__c = price.SR_Price__c ;
                                    newRecod.RP_Synch__c = false;
                                    newRecod.Change_Context__c = 'Re-Price';
                                    if(clientAvail.Title_Content_Type__c == 'Season'){
                                        newRecod.Episode_Price__c = price.Episode_Price__c ;
                                        newRecod.SR_Per_Episode__c = price.SR_Per_Episode__c ;
                                        newRecod.Episode_Price_Tier__c = price.Episode_Price_Tier__c ;
                                    }
                                    newrecod.Local_Data_Category_Picklist__c = clientAvail.Local_Title__r.Local_Category__c;
                                    newrecod.EC_Available__c=clientAvail.EC_Available__c;
                                    newrecod.Created_From_RePrice_Flag__c=true;
                                    newlyCreatedClientAvail_list.add(newRecod);
                                    clientAvailUpdate_list.add(clientAvail);
                                    priceCounter++;
                                }
                            }
                        }
                    }
                   
                    If(!isPriceCodeFound){
                        Boolean isPriceTierFound = false;
                        if( mapPricingRecords.get(clientAvail.Client__c) != null &&
                            mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c) != null &&
                            mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c) != null &&
                            mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c) != null &&
                            mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c) != null
                        ){
                            Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                            for(Pricing__c pricingRecords : allPriceTiers.values())
                                if(pricingRecords != null && obj.Price_Tier_Text__c == pricingRecords.Price_Tier__c && obj.Episode_Price_Tier__c == pricingRecords.Episode_Price_Tier__c){
                                    isPriceTierFound = true;
                                }
                        }
                        Client_Avail__c  newRecod = new Client_Avail__c();
                        
                        newRecod = clientAvail.clone(false,false,false,false);
                        newRecod.Local_Data_Category_Picklist__c = clientAvail.Local_Data_Category_Picklist__c;
                        newRecod.Start_Date__c = datename;
                        newRecod.End_Date__c = clientAvail.End_Date__c ;
                        
                        newRecod.Price__c = obj.Price__c ;
                        newRecod.Price_Tier_Text__c = obj.Price_Tier_text__c ;
                        newRecod.SR_Price__c = obj.SR_Price__c ;
                        if(clientAvail.Title_Content_Type__c == 'Season'){
                            newRecod.Episode_Price__c = obj.Episode_Price__c ;
                            newRecod.SR_Per_Episode__c = obj.SR_Per_Episode__c ;
                            newRecod.Episode_Price_Tier__c = obj.Episode_Price_Tier__c ;
                        }
                            
                        if(newRecod.Status__c=='Confirmed' && (obj.Price_Tier_Text__c != null || obj.Episode_Price_Tier__c != null)){
                            if(isPriceTierFound){
                                newRecod.Status__c='Confirmed';
                            }
                            else{
                                showMessageParam=true;
                                newRecod.Status__c='Tentative';
                            }
                        } else if(newRecod.Status__c=='Confirmed' && 
                              obj.Price_Tier_Text__c == null &&
                              obj.Price__c == null &&
                              obj.SR_Price__c == null &&
                              obj.Episode_Price_Tier__c == null &&
                              obj.Episode_Price__c == null &&
                              obj.SR_Per_Episode__c == null
                             ){
                             if(isPriceTierFound){
                                newRecod.Status__c='Confirmed';
                            }
                            else{
                                showMessageParam=true;
                                newRecod.Status__c='Tentative';
                            }
                        } 
        
                        newrecod.Local_Data_Category_Picklist__c = clientAvail.Local_Title__r.Local_Category__c;
                        newrecod.EC_Available__c=clientAvail.EC_Available__c;
                        newrecod.Created_From_RePrice_Flag__c=true;
                        newlyCreatedClientAvail_list.add(newRecod);
                        clientAvailUpdate_list.add(clientAvail);
                        continue;
                    }
                    
                    if(priceCounter==0 && !PriceTierMatches){
                        Client_Avail__c  newRecod = new Client_Avail__c();
                        newRecod = clientAvail.clone(false,false,false,false);
                        newRecod.Start_Date__c = datename;
                        newRecod.End_Date__c = clientAvail.End_Date__c ;
                        newRecod.Price__c = obj.Price__c ;
                        newRecod.Price_Tier_Text__c = obj.Price_Tier_Text__c ;
                        newRecod.SR_Price__c = obj.SR_Price__c ;
                        newRecod.RP_Synch__c = false;
                        newRecod.Change_Context__c = 'Re-Price';
                        if(clientAvail.Title_Content_Type__c == 'Season'){
                            newRecod.Episode_Price__c = obj.Episode_Price__c ;
                            newRecod.SR_Per_Episode__c = obj.SR_Per_Episode__c ;
                            newRecod.Episode_Price_Tier__c = obj.Episode_Price_Tier__c ;
                        }
                            
                        if(newRecod.Status__c=='Confirmed' && (obj.Price_Tier_Text__c != null || obj.Episode_Price_Tier__c != null)){
                            showMessageParam=true;
                            newRecod.Status__c='Tentative';
                        } else if(newRecod.Status__c=='Confirmed' && 
                                  obj.Price_Tier_Text__c == null &&
                                  obj.Price__c == null &&
                                  obj.SR_Price__c == null &&
                                  obj.Episode_Price_Tier__c == null &&
                                  obj.Episode_Price__c == null &&
                                  obj.SR_Per_Episode__c == null
                             ){
                             showMessageParam=true;
                            newRecod.Status__c='Tentative';
                        } // logic ended
                        newrecod.Local_Data_Category_Picklist__c = clientAvail.Local_Title__r.Local_Category__c;
                        newrecod.EC_Available__c=clientAvail.EC_Available__c;
                        newrecod.Created_From_RePrice_Flag__c=true;
                        newlyCreatedClientAvail_list.add(newRecod);
                        clientAvailUpdate_list.add(clientAvail);
                    }
                }
            }
        }
        else{
            for(Client_Avail__c clientAvail :filteredClientAvail_list){
                system.debug('im here sriniz 1...');
                Boolean isPriceTierFound = false;
                integer priceCounter=0;
                if( mapPricingRecords.get(clientAvail.Client__c) != null &&
                    mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c) != null &&
                    mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c) != null &&
                    mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c) != null &&
                    mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c) != null
                ){
                    Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                    for(Pricing__c pricingRecords : allPriceTiers.values()){
                        if(pricingRecords != null && obj.Price_Tier_Text__c == pricingRecords.Price_Tier__c && obj.Episode_Price_Tier__c == pricingRecords.Episode_Price_Tier__c){
                            isPriceTierFound = true;
                        }
                    }
                }
                Client_Avail__c newRecod = new Client_Avail__c();
                System.debug(Logginglevel.ERROR,'CPUTIME5*** ' + Limits.getCPUTime());
                
                newRecod = clientAvail.clone(false,false,false,false);
                newRecod.Local_Data_Category_Picklist__c = clientAvail.Local_Data_Category_Picklist__c; 
                newRecod.Start_Date__c = datename;
                newRecod.End_Date__c = clientAvail.End_Date__c ;
                newRecod.Price__c = obj.Price__c ;
                newRecod.Price_Tier_Text__c = obj.Price_Tier_Text__c ;
                newRecod.SR_Price__c = obj.SR_Price__c ;
                newRecod.RP_Synch__c = false;
                newRecod.Change_Context__c = 'Re-Price';
                if(clientAvail.Title_Content_Type__c == 'Season'){
                    newRecod.Episode_Price__c = obj.Episode_Price__c ;
                    newRecod.SR_Per_Episode__c = obj.SR_Per_Episode__c ;
                    newRecod.Episode_Price_Tier__c = obj.Episode_Price_Tier__c ;
                }
                
                if(newRecod.Status__c=='Confirmed' && (obj.Price_Tier_Text__c != null || obj.Episode_Price_Tier__c != null))
                {
                    if(isPriceTierFound)
                        newRecod.Status__c='Confirmed';
                    else
                    {
                        showMessageParam=true;
                        newRecod.Status__c='Tentative';
                    }
                }else if(newRecod.Status__c=='Confirmed' && 
                          obj.Price_Tier_Text__c == null &&
                          obj.Price__c == null &&
                          obj.SR_Price__c == null &&
                          obj.Episode_Price_Tier__c == null &&
                          obj.Episode_Price__c == null &&
                          obj.SR_Per_Episode__c == null
                         ){
                        if(isPriceTierFound)
                            newRecod.Status__c='Confirmed';
                        else
                        {
                            system.debug('im here sriniz 2...');
                            showMessageParam=true;
                            newRecod.Status__c='Tentative';
                        }
                }
        
                newrecod.Local_Data_Category_Picklist__c = clientAvail.Local_Title__r.Local_Category__c;
                newrecod.EC_Available__c=clientAvail.EC_Available__c;
                newrecod.Created_From_RePrice_Flag__c=true;
                newlyCreatedClientAvail_list.add(newRecod);
                clientAvailUpdate_list.add(clientAvail);
                priceCounter++; 
            }
        }
        // CH01 : Give an error if not rcords to insert and Price Tier have same value.
        if(PriceTierMatches && newlyCreatedClientAvail_list.size() == 0)
        {
            if(isRunningBatch){
                localErrorMessageMap.put('saveResult3',new List<string>{'New client avails can\'t be created if Pricing is same as Pricing of old Client Avail.'});
                
                CAWizardExceptionList.add(new Client_Avail_Wizard_Exceptions__c(
                    Reason__c = 'New client avails can\'t be created if Pricing is same as Pricing of old Client Avail.',
                    Name = 'Multiple Client Avails', User_Detail__c = UserInfo.getUserId(),
                    Country__c = '-', Language__c = '-', Format__c = '-', Channel__c = '-', Title__c = '-', Price_Tier__c = '-', SR_Price__c = 0, WS_Price__c = 0
                ));
            }else{
                if(localErrorMessageMap.containsKey('pageMessages')){
                    localErrorMessageMap.get('pageMessages').add('New client avails can\'t be created if Price Tier is same as Price Tier of old Client Avail.');
                }else{
                    localErrorMessageMap.put('pageMessages',new List<string>{'New client avails can\'t be created if Price Tier is same as Price Tier of old Client Avail.'});
                }
                return localErrorMessageMap;
            }
            //messageList.add('New client avails can\'t be created if Price Tier is same as Price Tier of old Client Avail.');
            //return messageList;
        }
        // CH01: END
        
        //For updating the existing records: only the end date
        for(Client_Avail__c clientAvail :clientAvailUpdate_list){
            clientAvail.End_Date__c = previousEndDate ;
            //added by shalini -- ER-323
            clientAvail.Change_Context__c='Re-Price';
        }
        
        list<Client_Avail_Exception__c> clientAvailException_listold = new list<Client_Avail_Exception__c>();
        list<Client_Avail_Exception__c> clientAvailException_listnew = new list<Client_Avail_Exception__c>();
        list<Client_Avail_Exception__c> clientAvailException_listfinal = new list<Client_Avail_Exception__c>();
        
        //insertion of old client avail records into Exception custom setting
        for(Client_Avail__c clientAvail :selectedClientAvail_list3){
            Client_Avail_Exception__c clientExcep = new Client_Avail_Exception__c();
            string str = String.valueOf(clientAvail.Name) + 'old';
            
            clientExcep.Name = str;
            clientExcep.User_Detail__c = loggedInUserId;
            clientExcep.Client_Avail_ID__c = clientAvail.Name;
            clientExcep.Title__c = clientAvail.Release_Plan_Title__c;
            clientExcep.Account__c = clientAvail.Client__r.Name;
            clientExcep.Country__c = clientAvail.Release_Plan_Country__c;
            clientExcep.Language__c = clientAvail.Release_Plan_Language__c;
            clientExcep.Format__c = clientAvail.Release_Plan_Format__c;
            clientExcep.Channel__c = clientAvail.Release_Plan_Channel__c;
            clientExcep.ClientAvail_Start_Date__c = clientAvail.Start_Date__c;
            clientExcep.ClientAvail_End_Date__c = clientAvail.End_Date__c;
            clientExcep.Status__c = clientAvail.Status__c;
            clientExcep.Price_Tier__c = clientAvail.Price_Tier_Text__c;
            clientExcep.SR_Price__c = clientAvail.SR_Price__c;
            clientExcep.WS_Price__c = clientAvail.Price__c;
            clientExcep.Episode_Price__c = clientAvail.Episode_Price__c;
            clientExcep.SR_Per_Episode__c = clientAvail.SR_Per_Episode__c;
            clientExcep.Episode_Price_Tier__c = clientAvail.Episode_Price_Tier__c;
            clientExcep.Old_Price_Records__c = true;
            
            clientAvailException_listold.add(clientExcep);
        }
        clientAvailException_listfinal.addAll(clientAvailException_listold);
        
        try{
            if(clientAvailUpdate_list != null && clientAvailUpdate_list.size() > 0 && obj.Effective_Price_Date__c != null){
                if(flagPriceTier == false){
                    Database.Saveresult[] saveResult  = Database.update(clientAvailUpdate_list, false);
                    
                    /* Start : Error Message Logic */
                    for(Integer n=0; n<saveResult.size(); n++) {
                        //Database.SaveResult sr : saveResult
                        Database.SaveResult sr = saveResult[n];
                        if (!sr.isSuccess()) {
                            String allErrors = '';
                            for(Database.Error err : sr.getErrors()) {
                                allErrors = err.getMessage() + '\n';
                                if(localErrorMessageMap.containsKey(sr.getId())){
                                    localErrorMessageMap.get(sr.getId()).add(err.getMessage());
                                }else{
                                    localErrorMessageMap.put(sr.getId(), new List<string>{err.getMessage()});
                                }
                            }
                            Client_Avail__c processedClientAvail = filteredClientAvail_list[n];
                            Client_Avail_Wizard_Exceptions__c objCAWizardException = new Client_Avail_Wizard_Exceptions__c(
                                Account__c = processedClientAvail.Client__r.Name,
                                Country__c = processedClientAvail.Release_Plan_Country__c,
                                Language__c = processedClientAvail.Release_Plan_Language__c,
                                Format__c = processedClientAvail.Release_Plan_Format__c,
                                Channel__c = processedClientAvail.Release_Plan_Channel__c,
                                Title__c = processedClientAvail.Release_Plan_Title__c,
                                User_Detail__c = UserInfo.getUserId(),
                                Price_Tier__c = processedClientAvail.Price_Tier_Text__c,
                                SR_Price__c = processedClientAvail.SR_Price__c,
                                WS_Price__c = processedClientAvail.Price__c,
                                ClientAvail_Start_Date__c = processedClientAvail.Start_Date__c,
                                ClientAvail_End_Date__c = processedClientAvail.End_Date__c,
                                Reason__c = allErrors,
                                Name = processedClientAvail.Id
                            );
                            CAWizardExceptionList.add(objCAWizardException);
                        }
                    }
                    /* End : Error Message Logic */
                    
                    boolean flageReDirect=true;
                    for(integer i=0;i<saveResult.size();i++){
                        if(!(saveResult[i].isSuccess())){
                            flageReDirect=false;
                        }
                    }
                    if (flageReDirect==true){
                        list<string> newlyClientIds = new list<string>();
                        if(newlyCreatedClientAvail_list.size() != 0 && newlyCreatedClientAvail_list!= null){
                            Database.Saveresult[] saveResult1  = Database.insert(newlyCreatedClientAvail_list, false);
                            
                            for(Integer n=0; n<saveResult1.size(); n++){
                                Database.Saveresult sr = saveResult1[n];
                                if (sr.isSuccess()){
                                    newlyClientIds.add(sr.getId());
                                }
                                /* Start : Error Message Logic */
                                else{
                                    Integer i = 1;
                                    String allErrors = '';
                                    for(Database.Error err : sr.getErrors()) {
                                        String key = 'saveResult1_'+i;
                                        allErrors = err.getMessage() + '\n';
                                        if(localErrorMessageMap.containsKey(key)){
                                            localErrorMessageMap.get(key).add(err.getMessage());
                                        }else{
                                            localErrorMessageMap.put(key, new List<string>{err.getMessage()});
                                        }
                                        i++;
                                    }
                                    
                                    Client_Avail__c processedClientAvail = newlyCreatedClientAvail_list[n];
                                    Client_Avail_Wizard_Exceptions__c objCAWizardException = new Client_Avail_Wizard_Exceptions__c(
                                        Account__c = processedClientAvail.Client__r.Name,
                                        Country__c = processedClientAvail.Release_Plan_Country__c,
                                        Language__c = processedClientAvail.Release_Plan_Language__c,
                                        Format__c = processedClientAvail.Release_Plan_Format__c,
                                        Channel__c = processedClientAvail.Release_Plan_Channel__c,
                                        Title__c = processedClientAvail.Release_Plan_Title__c,
                                        User_Detail__c = UserInfo.getUserId(),
                                        Price_Tier__c = processedClientAvail.Price_Tier_Text__c,
                                        SR_Price__c = processedClientAvail.SR_Price__c,
                                        WS_Price__c = processedClientAvail.Price__c,
                                        ClientAvail_Start_Date__c = processedClientAvail.Start_Date__c,
                                        ClientAvail_End_Date__c = processedClientAvail.End_Date__c,
                                        Reason__c = allErrors,
                                        Name = 'New Client Avail'
                                    );
                                    CAWizardExceptionList.add(objCAWizardException);
                                }
                                /* End : Error Message Logic */
                            }
                        }
                        
                        //added by shalini er-119 -- uncheck RP synch
                        list<client_avail__c> newlyCreatedClientAvail = [
                            Select Name,Release_Plan_Title__c,Client__r.Name,Release_Plan_Country__c,RP_Synch__c,
                                   Release_Plan_Language__c,Release_Plan_Format__c,Release_Plan_Channel__c,Start_Date__c,
                                   End_Date__c,Status__c,Price_Tier_Text__c,SR_Price__c,Price__c,Episode_Price__c,SR_Per_Episode__c
                              from client_avail__c
                             where Id IN:newlyClientIds
                        ];
                        
                        //insertion of new client avail records into Exception custom setting
                        for(Client_Avail__c clientAvail :newlyCreatedClientAvail){
                            Client_Avail_Exception__c clientExcep = new Client_Avail_Exception__c();
                            string str = String.valueOf(clientAvail.Name) + 'new';
                            
                            clientExcep.Name = str;
                            clientExcep.User_Detail__c = loggedInUserId;
                            clientExcep.Client_Avail_ID__c = clientAvail.Name;
                            clientExcep.Title__c = clientAvail.Release_Plan_Title__c;
                            clientExcep.Account__c = clientAvail.Client__r.Name;
                            clientExcep.Country__c = clientAvail.Release_Plan_Country__c;
                            clientExcep.Language__c = clientAvail.Release_Plan_Language__c;
                            clientExcep.Format__c = clientAvail.Release_Plan_Format__c;
                            clientExcep.Channel__c = clientAvail.Release_Plan_Channel__c;
                            clientExcep.ClientAvail_Start_Date__c = clientAvail.Start_Date__c;
                            clientExcep.ClientAvail_End_Date__c = clientAvail.End_Date__c;
                            clientExcep.Status__c = clientAvail.Status__c;
                            clientExcep.Price_Tier__c = clientAvail.Price_Tier_Text__c;
                            clientExcep.SR_Price__c = clientAvail.SR_Price__c;
                            clientExcep.WS_Price__c = clientAvail.Price__c;
                            clientExcep.Episode_Price__c = clientAvail.Episode_Price__c;
                            clientExcep.SR_Per_Episode__c = clientAvail.SR_Per_Episode__c;
                            clientExcep.Old_Price_Records__c = false;
                            
                            clientAvailException_listnew.add(clientExcep);
                        }
                        
                        clientAvailException_listfinal.addAll(clientAvailException_listnew);
                        
                        if(clientAvailException_listfinal.size() != 0 && clientAvailException_listfinal!= null){
                            Database.Saveresult[] saveResult2  = Database.insert(clientAvailException_listfinal, false);
                        }
                        /* Start : Error Message Logic */
                        Integer j = 1;
                        String key;
                        for (Database.SaveResult sr : saveResult) {
                            if (!sr.isSuccess()) {
                                for(Database.Error err : sr.getErrors()) {
                                    key = 'saveResult2_'+j;
                                    if(localErrorMessageMap.containsKey(key)){
                                        localErrorMessageMap.get(key).add(err.getMessage());
                                    }else{
                                        localErrorMessageMap.put(key, new List<string>{err.getMessage()});
                                    }
                                    j++;
                                }
                            }
                        }
                        /* End : Error Message Logic */
                        //Pagereference PageRef = new Pagereference('/apex/WB_RePriceClientAvail_Redirect?sm='+showMessageParam);
                        //return PageRef;
                        
                        if(!isRunningBatch){
                            localErrorMessageMap.put('pageMessages',new List<string>{'/apex/WB_RePriceClientAvail_Redirect?sm='+showMessageParam});
                            return localErrorMessageMap;
                        }
                    }else {
                        filteredClientAvail_list.clear();
                        newlyCreatedClientAvail_list.clear();
                        return null;
                    }
                }else{
                    if(isRunningBatch){
                        if(localErrorMessageMap.containsKey('saveResult3')){
                            localErrorMessageMap.get('saveResult3').add('Price Tier and WS Price are mutually exclusive');
                        }else{
                            localErrorMessageMap.put('saveResult3',new List<string>{'Price Tier and WS Price are mutually exclusive'});
                        }
                        CAWizardExceptionList.add(new Client_Avail_Wizard_Exceptions__c(
                            Reason__c = 'Price Tier and WS Price are mutually exclusive',
                            Name = 'Multiple Client Avails', User_Detail__c = UserInfo.getUserId(), Country__c = '-', Language__c = '-', 
                            Format__c = '-', Channel__c = '-', Title__c = '-', Price_Tier__c = '-', SR_Price__c = 0, WS_Price__c = 0
                        ));
                    }else{
                        if(localErrorMessageMap.containsKey('pageMessages')){
                            localErrorMessageMap.get('pageMessages').add('Price Tier and WS Price are mutually exclusive');
                        }else{
                            localErrorMessageMap.put('pageMessages',new List<string>{'Price Tier and WS Price are mutually exclusive'});
                        }
                        return localErrorMessageMap;
                    }
                }
            }else{
                if(isRunningBatch){
                    if(localErrorMessageMap.containsKey('saveResult3')){
                        localErrorMessageMap.get('saveResult3').add('Effective Price Date should lie within Client Start and Client End. Please select different Effective Price Date');
                    }else{
                        localErrorMessageMap.put('saveResult3',new List<string>{'Effective Price Date should lie within Client Start and Client End. Please select different Effective Price Date'});
                    }
                    CAWizardExceptionList.add(new Client_Avail_Wizard_Exceptions__c(
                        Reason__c = 'Effective Price Date should lie within Client Start and Client End. Please select different Effective Price Date',
                        Name = 'Multiple Client Avails', User_Detail__c = UserInfo.getUserId(), Country__c = '-', Language__c = '-',
                        Format__c = '-', Channel__c = '-', Title__c = '-', Price_Tier__c = '-', SR_Price__c = 0, WS_Price__c = 0
                    ));
                }else{
                    if(localErrorMessageMap.containsKey('pageMessages')){
                        localErrorMessageMap.get('pageMessages').add('Effective Price Date should lie within Client Start and Client End. Please select different Effective Price Date');
                    }else{
                        localErrorMessageMap.put('pageMessages',new List<string>{'Effective Price Date should lie within Client Start and Client End. Please select different Effective Price Date'});
                    }
                    return localErrorMessageMap;
                }
            }
            /****** Mahesh ******/
            if(CAWizardExceptionList != null && CAWizardExceptionList.size() > 0){
                Database.saveResult[] CAWizardExceptionSaveResultList = Database.insert(CAWizardExceptionList, false);
                system.debug('============>  ' + CAWizardExceptionSaveResultList);
            }
            /****** Mahesh ******/
            
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return localErrorMessageMap;
    }
}