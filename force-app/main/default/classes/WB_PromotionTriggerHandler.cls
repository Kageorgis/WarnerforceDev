public class WB_PromotionTriggerHandler {
    
    public static void checkPromotion(Map<Id,Promotion__c> mapOldPromotionData, List<Promotion__c> listPromotionData){
        //Promtoion Records 
        Set<Id> updatePromotionIds = new Set<Id>();
        for(Promotion__c promoRec : listPromotionData){
            if(promoRec.Country__c != mapOldPromotionData.get(promoRec.Id).Country__c){
                updatePromotionIds.add(promoRec.Id);
            }
        }
        if(!updatePromotionIds.isEmpty()){
            updatePromotionOwner(updatePromotionIds);
        }
    }
    
    public static void updatePromotionOwner(Set<Id> updatePromotionIds){
        //Fetch PT and Promotion Records
        List<Promotion__c> updatePromotionRecs = [SELECT Id,Country__c,OwnerId,CreatedById,(SELECT Id,Title__r.Studio__c FROM Promotion_Titles__r) FROM Promotion__c WHERE Id IN :updatePromotionIds];
        Set<String> countryNames = new Set<String>();
        Set<Id> titleIds = new Set<Id>();
        for(Promotion__c promoRec : updatePromotionRecs){
            if(promoRec.Country__c != null){
                countryNames.addAll(promoRec.Country__c.split(';'));  
            }
            if(!promoRec.Promotion_Titles__r.isEmpty()){
                for(Promotion_Title__c obj : promoRec.Promotion_Titles__r){
                    titleIds.add(obj.Title__c);
                }
            }
        }
        List<Local_Title__c> listLocalData = [SELECT Id,Title__c,LocalDisplayStudio__c FROM Local_Title__c WHERE Title__c IN :titleIds AND External_Company__c = Null];
        Map<Id,List<Local_Title__c>> mapTitleLocalData = new Map<Id,List<Local_Title__c>>();
        if(!listLocalData.isEmpty()){
            for(Local_Title__c obj : listLocalData){
                if(mapTitleLocalData.containsKey(obj.Title__c)){
                    mapTitleLocalData.get(obj.Title__c).add(obj);
                } else{
                    mapTitleLocalData.put(obj.Title__c,new List<Local_Title__c>{obj});
                }
            }
        }
        //LoggedIn User Record
        User userRec = [SELECT Id,Territory__c FROM USER WHERE Id = :UserInfo.getUserId()];
        if(!userRec.Territory__c.equals('Home Office')){
            countryNames.add(userRec.Territory__c);
        }
        
        //Country Records
        Map<String,Country__c> mapCountryData = new Map<String,Country__c>();
        List<Country__c> listCountryData = [SELECT Id,Name,Digital_Owner__c,HBO_Override__c,Turner_Override__c FROM Country__c WHERE Name IN :countryNames];
        if(!listCountryData.isEmpty()){
            for(Country__c countryRec : listCountryData){
                mapCountryData.put(countryRec.Name,countryRec);
            }
        }
        
        //Queue Records
        Map<String,WB_Queue_Id__c> mapQueueData = WB_Queue_Id__c.getAll();
        
        //Queue Assignment Logic
        for(Promotion__c promoRec : updatePromotionRecs){
            if(String.isBlank(promoRec.Country__c)){
                promoRec.OwnerId = promoRec.CreatedById;
            } else{
                Set<String> digitalOwnerQueueData = new Set<String>();
                Boolean hboTurnerFlag = true;
                Map<String,WB_HBO_TURNER_Countries__c> mapHBOTURNERCountries = WB_HBO_TURNER_Countries__c.getAll();
                for(String countryName : promoRec.Country__c.split(';')){
                    digitalOwnerQueueData.add(mapCountryData.get(countryName).Digital_Owner__c);
                    //Country Check
                    if(!mapHBOTURNERCountries.containsKey(countryName)){
                        hboTurnerFlag = false;
                    }
                }
                System.debug('hboTurnerFlag==='+hboTurnerFlag);
                if(hboTurnerFlag){
                    //Promotion Titles Check
                    List<Promotion_Title__c> listPromoTitles = promoRec.Promotion_Titles__r;
                    System.debug('PT===='+promoRec.Promotion_Titles__r);
                    if(!listPromoTitles.isEmpty()){
                        Boolean hboFlag = false;
                        Boolean turnerFlag = false;
                        String hboOverrideStudios = Label.HBOVal;
                        List<String> listHBOOverrideStudios = hboOverrideStudios.split(',');
                        String hboTurnerStudios = Label.TurnerVal;
                        List<String> listHBOTurnerStudios = hboTurnerStudios.split(',');
                        for(Promotion_Title__c promoTitleObj : listPromoTitles){
                            if(mapTitleLocalData.containsKey(promoTitleObj.Title__c)){
                                System.debug('mapTitleLocalData.containsKey(promoTitleObj.Title__c)data==='+mapTitleLocalData.get(promoTitleObj.Title__c));
                                System.debug('mapTitleLocalData.containsKey(promoTitleObj.Title__c)size==='+mapTitleLocalData.get(promoTitleObj.Title__c).size());
                                for(Local_Title__c localTitleObj : mapTitleLocalData.get(promoTitleObj.Title__c)){
                                    if(!String.isBlank(localTitleObj.LocalDisplayStudio__c)){
                                        System.debug('LocalDisplayStudio__c==='+localTitleObj.LocalDisplayStudio__c);
                                        if(listHBOOverrideStudios.contains(localTitleObj.LocalDisplayStudio__c)){
                                            hboFlag = true;
                                        }
                                        else if(listHBOTurnerStudios.contains(localTitleObj.LocalDisplayStudio__c)){
                                            turnerFlag = true;
                                        }
                                    }
                                    
                                    if(hboFlag){
                                        break;
                                    }
                                }
                            }
                            if(hboFlag){
                                break;
                            }
                            System.debug('hboFlag==='+hboFlag);
                            System.debug('turnerFlag==='+turnerFlag);
                            //if(promoTitleObj.Title__r.Studio__c.equals('HBO')){
                            /*if(listHBOOverrideStudios.contains(promoTitleObj.Title__r.Studio__c)){
hboFlag = true;
}*/
                            //else if(promoTitleObj.Title__r.Studio__c.equals('TURNER')){
                            /*else if(listHBOTurnerStudios.contains(promoTitleObj.Title__r.Studio__c)){
turnerFlag = true;
}*/
                        }
                        System.debug('hboFlag==='+hboFlag);
                        System.debug('turnerFlag==='+turnerFlag);
                        if(hboFlag){
                            Set<String> setQueueNames = new Set<String>();
                            for(String countName : promoRec.Country__c.split(';')){
                                setQueueNames.add(mapCountryData.get(countName).HBO_Override__c);
                            }
                            if(setQueueNames.size() == 1){
                                for(String obj : setQueueNames){
                                    System.debug('Queue Name==='+obj);
                                    promoRec.OwnerId = mapQueueData.get(obj).Value__c;
                                }
                            } else{
                                //Need to Ask
                                hboTurnerFlag = false;
                            }
                        } else if(turnerFlag){
                            Set<String> setQueueNames = new Set<String>();
                            for(String countName : promoRec.Country__c.split(';')){
                                setQueueNames.add(mapCountryData.get(countName).Turner_Override__c);
                            }
                            if(setQueueNames.size() == 1){
                                for(String obj : setQueueNames){
                                    System.debug('Queue Name==='+obj);
                                    promoRec.OwnerId = mapQueueData.get(obj).Value__c;
                                }
                            } else{
                                //Need to Ask
                                hboTurnerFlag = false;
                            }
                        } else{
                            hboTurnerFlag = false;
                        }
                        System.debug('hboTurnerFlag==='+hboTurnerFlag);
                    } else{
                        hboTurnerFlag = false;
                        System.debug('hboTurnerFlag==='+hboTurnerFlag);
                    }
                }
                System.debug('hboTurnerFlag==='+hboTurnerFlag);
                if(!hboTurnerFlag){
                    if(digitalOwnerQueueData.size() == 1){
                        for(String recData : digitalOwnerQueueData)
                        {
                            System.debug('Queue Name==='+recData);
                            System.debug('In One Digital Owner');
                            if(mapQueueData.containsKey(recData)){
                                promoRec.OwnerId = mapQueueData.get(recData).Value__c;	//Assign the digitalOwner Queue
                            } else{
                                promoRec.OwnerId = promoRec.CreatedById;
                            }
                        }
                    } else{
                        System.debug('In User Territory');
                        if(userRec.Territory__c.equals('Home Office')){
                            System.debug('Queue Name==='+userRec.Territory__c.replaceAll(' ','')+'Q');
                            promoRec.OwnerId = mapQueueData.get(userRec.Territory__c.replaceAll(' ','')+'Q').Value__c;	//Assign LoggedIn User Territory and assign DigitalOwner Queue
                        } else if(mapCountryData.containsKey(userRec.Territory__c) && !String.isBlank(mapCountryData.get(userRec.Territory__c).Digital_Owner__c)){
                            System.debug('Queue Name==='+mapCountryData.get(userRec.Territory__c).Digital_Owner__c);
                            promoRec.OwnerId = mapQueueData.get(mapCountryData.get(userRec.Territory__c).Digital_Owner__c).Value__c;
                        } else{
                            System.debug('Queue Name==='+promoRec.CreatedById);
                            promoRec.OwnerId = promoRec.CreatedById;
                        }
                    }
                }
            }
        }
        List<Database.SaveResult> listSaveResult = Database.update(updatePromotionRecs);
        System.debug('listSaveResult==='+listSaveResult);
    }
}