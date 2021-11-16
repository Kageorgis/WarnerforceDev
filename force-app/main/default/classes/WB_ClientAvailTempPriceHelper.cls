public without sharing class  WB_ClientAvailTempPriceHelper {
    public Map<Id,Client_Avail__c> caMapValue = new Map<Id,Client_Avail__c>();
    /**
Method to validate Temp Price Data
*/
    public List<WB_ClientAvailTempPriceWrapper> validateTempPrice(List<WB_ClientAvailTempPriceWrapper> tempPriceList){
        Set<String> caIDSet = new Set<String>();
        for(WB_ClientAvailTempPriceWrapper tempWrapper:tempPriceList){
            caIDSet.add(tempWrapper.clientAvailID);
        }
        
        Map<Id,Client_Avail__c> caMap = new Map<Id,Client_Avail__c>([Select Id,Name,Start_Date__c,End_Date__c,Status__c,APO_Date__c From Client_Avail__c Where Id In :caIDSet]);
        for(WB_ClientAvailTempPriceWrapper tempWrapper:tempPriceList){
            Client_Avail__c caRecord = caMap.get(tempWrapper.clientAvailID);
            validatePriceData(tempWrapper,caRecord);
        }
        
        return tempPriceList;
    }
    
    public void validatePriceData(WB_ClientAvailTempPriceWrapper tempWrapper,Client_Avail__c caRecord){
        List<String> errorMessages = new List<String>();
        if(caRecord == null){
            tempWrapper.status = 'Failed';
            errorMessages.add('Client Avail does not exist');
        }else{
            if(caRecord.Status__c != WB_PriceUtility.STATUS_CONF && caRecord.Status__c != WB_PriceUtility.STATUS_TENTVE){
                tempWrapper.status = 'Failed';
                errorMessages.add('Client Avail Status is not tentative/confirmed'); 
            }else if(tempWrapper.priceStartDate > caRecord.End_Date__c){
                tempWrapper.status = 'Failed';
                errorMessages.add('Deal Start Date must be on or before Avail End Date'); 
            }else if(caRecord.APO_Date__c != null ? tempWrapper.priceEndDate < caRecord.APO_Date__c : tempWrapper.priceEndDate < caRecord.Start_Date__c){
                tempWrapper.status = 'Failed';
                errorMessages.add('Deal End Date must be on or after Avail Start Date'); 
            }
        }
        
        
        if(!errorMessages.isEmpty()){
            tempWrapper.status = 'Failed';
            tempWrapper.messages = errorMessages;
        }else{
            tempWrapper.status = 'Success';
        }
    }
    
    public Boolean validatePriceAndPopulateClientAvailMap(List<WB_ClientAvailTempPriceWrapper> tempPriceList){
        Set<String> caIDSet = new Set<String>();
        Set<String> dealIDSet = new Set<String>();
        Set<String> promoIDSet = new Set<String>();
        for(WB_ClientAvailTempPriceWrapper tempWrapper:tempPriceList){
            caIDSet.add(tempWrapper.clientAvailID);
            if(tempWrapper.dealId != null)
                dealIDSet.add(tempWrapper.dealId);
            else if(tempWrapper.promotionID != null)	
                promoIDSet.add(tempWrapper.promotionID);
        }
        Boolean hasError = false;
        //SINC1773713:Added field Local_Title__r.Title__c to fetch the title of associated local data to update the same of title field of TEMP CAP record
        caMapValue = new Map<Id,Client_Avail__c>([Select Id,Name,Start_Date__c,End_Date__c,Status__c,Local_Data_Category_Picklist__c,Episode_Price_Tier__c,Episode_Price__c,Local_Title__r.Title__c,APO_Date__c,(Select Id,Name,Client_Avail__c,Deal_ID__c From Client_Avail_Prices__r Where Deal_ID__c in :dealIDSet OR Promotion__c in :promoIDSet) From Client_Avail__c Where Id In :caIDSet]);
        for(WB_ClientAvailTempPriceWrapper tempWrapper:tempPriceList){
            Client_Avail__c caRecord = caMapValue.get(tempWrapper.clientAvailID);
            
            validatePriceData(tempWrapper,caRecord);
            if(!hasError && tempWrapper.status == 'Failed'){
                hasError = true;
            }
        }
        return hasError;
    }
    
    /**
Method to create Temp Price Records
*/ 
    public List<WB_ClientAvailTempPriceWrapper> upsertTempPrice(List<WB_ClientAvailTempPriceWrapper> tempPriceList){
        
        
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        Set<String> dealIDSet = new Set<String>();
        Set<String> caIdDealIdSet = new Set<String>();
        Map<String,Client_Avail_Price__c> capMap = new Map<String,Client_Avail_Price__c>();
        List<Client_Avail_Price__c> tempCapUpsertList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> tempCapDeleteList = new List<Client_Avail_Price__c>();
        Map<String,Client_Avail_Price__c> capMapCancelledList = new Map<String,Client_Avail_Price__c>();
        
        
        Boolean hasError = validatePriceAndPopulateClientAvailMap(tempPriceList);
        if(hasError)
            return tempPriceList;  
        
        for(WB_ClientAvailTempPriceWrapper tempWrapper:tempPriceList){
            //Set to query CAP based on DealID
            dealIDSet.add(tempWrapper.dealId);
        }
        
        //Query CAP record based on dealIDSet
        List<Client_Avail_Price__c> queriedCaps = [Select Id,Name,Effective_Date__c,Client_Avail__c,Price_Tier__c,Price__c,CurrencyIsoCode,CAP_Status__c,Category__c,Episode_Price__c,Episode_Price_Tier__c,(Select Id,Name,Announcement_Date__c,Client_Start__c from Announcement_Records__r Limit 1),Client_Avail__r.Start_Date__c,Client_Avail__r.End_Date__c,Client_Avail__r.Status__c,Deal_ID__c,Client_Avail__r.Local_Data_Category_Picklist__c,Client_Avail__r.APO_Date__c From Client_Avail_Price__c Where Deal_ID__c in :dealIDSet];
        
        for(Client_Avail_Price__c capRecord : queriedCaps){
            capMap.put(String.valueOf(capRecord.Client_Avail__c).trim()+String.valueOf(capRecord.Deal_ID__c).trim(),capRecord);
        }
        
        
        for(WB_ClientAvailTempPriceWrapper priceWrapper:tempPriceList){
            Client_Avail_Price__c capRecord;
            //String key = priceWrapper.clientAvailID.trim()+priceWrapper.dealID.trim();
            //Insertion or Update only for records with Deal Status  as Committed       
            if(priceWrapper.dealStatus == 'Committed'){
                capRecord = capMap.get(priceWrapper.clientAvailID.trim()+priceWrapper.dealID.trim());
                if(capRecord!=null){
                    capMap.remove(priceWrapper.clientAvailID+priceWrapper.dealID);
                    
                }
                if(capRecord == null){
                    capRecord = new Client_Avail_Price__c();
                    capRecord.Client_Avail__c = priceWrapper.clientAvailID;
                    capRecord.RecordTypeId = tpRecTypeId;
                    capRecord.Deal_ID__c = priceWrapper.dealID;
                    capRecord.CurrencyIsoCode = priceWrapper.currencyCode;
                    capRecord.CAP_Status__c = priceWrapper.priceStatus;
                    //SINC1702076 : Update Episode price tier or episode WSP to TEMP CAP record from CA. 
                    if(caMapValue.containsKey(priceWrapper.clientAvailID)){
                        capRecord.Episode_Price_Tier__c = caMapValue.get(priceWrapper.clientAvailID).Episode_Price_Tier__c;
                        capRecord.Episode_Price__c = caMapValue.get(priceWrapper.clientAvailID).Episode_Price__c;
                    }
                    //SINC1773713: update title Id on TEMP CAP record from CA's local data.
                    capRecord.Title__c = caMapValue.get(priceWrapper.clientAvailID).Local_Title__r.Title__c;
                    if(caMapValue.containsKey(priceWrapper.clientAvailID)){
                        capRecord.Category__c = caMapValue.get(priceWrapper.clientAvailID).Local_Data_Category_Picklist__c;
                    }
                    
                    
                }
                if(priceWrapper.priceTier != NULL){
                    capRecord.Price_Tier__c = priceWrapper.priceTier; 
                    capRecord.Price__c = null;
                }else{
                    capRecord.Price_Tier__c = null;
                    capRecord.Price__c = priceWrapper.price;
                }
                //SINC1702076 : added a check to run below logic only for PERM CAPs
                /*
if(capRecord.Episode_Price_Tier__c != null){
capRecord.Episode_Price_Tier__c = priceWrapper.episodePriceTier;
capRecord.Episode_Price__c = null;
}else{
capRecord.Episode_Price_Tier__c = null;
capRecord.Episode_Price__c = priceWrapper.episodePrice;
}
*/
                capRecord.Effective_Date__c = priceWrapper.priceStartDate;
                capRecord.Expiry_Date__c = priceWrapper.priceEndDate;
                
                if(caMapValue.containsKey(priceWrapper.clientAvailID)){
                    Client_Avail__c caRec = caMapValue.get(priceWrapper.clientAvailID);
                    if(capRecord.Effective_Date__c < caRec.Start_Date__c){
                        if(caRec.APO_Date__c == null)
                            capRecord.Effective_Date__c = caRec.Start_Date__c;
                        else if(capRecord.Effective_Date__c < caRec.APO_Date__c)
                            capRecord.Effective_Date__c = caRec.APO_Date__c;  
                    }
                    
                    if(capRecord.Expiry_Date__c > caRec.End_Date__c)
                        capRecord.Expiry_Date__c = caRec.End_Date__c;  
                }
                //capRecord.CAP_Status__c = priceWrapper.priceStatus;
                tempCapUpsertList.add(capRecord);
                
            }
        }
        
        for(Client_Avail_Price__c capToBeCancelled : capMap.values()){
            Date currentDate = System.today(); 
            
            if(capToBeCancelled.Effective_Date__c <= currentDate && capToBeCancelled.Announcement_Records__r.size() > 0){
                capToBeCancelled.Expiry_Date__c = currentDate;
                capToBeCancelled.CAP_Status__c = 'Deleted' ;
                tempCapUpsertList.add(capToBeCancelled);
            }else
                tempCapDeleteList.add(capToBeCancelled);
            
        }
        
        if(tempCapUpsertList.size()>0)
        {
            Database.UpsertResult[] upsertResults = Database.upsert(tempCapUpsertList,true);
            if(upsertResults.size()>0){
                for(Integer index=0;index < tempPriceList.size();index++){
                    Database.UpsertResult upsertResult = upsertResults[index];
                    if(upsertResult.isSuccess()){
                        tempPriceList[index].status = 'Success';
                    }else{
                        List<String> errorMessages = new List<String>();
                        for(Database.Error error:upsertResult.getErrors()){
                            errorMessages.add(error.getMessage());
                        }
                        tempPriceList[index].status = 'Failed';
                        tempPriceList[index].messages = errorMessages;
                    }   
                } 
            }
            
        }
        
        if(tempCapDeleteList.size()>0){
            Database.DeleteResult[] deleteResults = Database.delete(tempCapDeleteList, true);
        }
        
        return tempPriceList;
        
    }
    
    /**
Method to create Temp Price Records for Promotion
*/ 
    public List<WB_ClientAvailTempPriceWrapper> upsertPromoTempPrice(List<WB_ClientAvailTempPriceWrapper> tempPriceList,Boolean isBatchMode){
        
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        Set<String> promoIDSet = new Set<String>();
        Map<String,Client_Avail_Price__c> capMap = new Map<String,Client_Avail_Price__c>();
        List<Client_Avail_Price__c> tempCapUpsertList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> tempCapDeleteList = new List<Client_Avail_Price__c>();
        Map<String,Client_Avail_Price__c> capMapCancelledList = new Map<String,Client_Avail_Price__c>();
        Boolean hasError = validatePriceAndPopulateClientAvailMap(tempPriceList);
        if(hasError)
            return tempPriceList;  
        
        for(WB_ClientAvailTempPriceWrapper tempWrapper:tempPriceList){
            promoIDSet.add(tempWrapper.promotionID);
        }
        
        //Query CAP record based on promoIDSet
        List<Client_Avail_Price__c> queriedCaps = [Select Id,Name,Effective_Date__c,Client_Avail__c,Price_Tier__c,Price__c,CurrencyIsoCode,CAP_Status__c,Category__c,Episode_Price__c,Episode_Price_Tier__c,(Select Id,Name,Announcement_Date__c,Client_Start__c from Announcement_Records__r Limit 1),Client_Avail__r.Start_Date__c,Client_Avail__r.End_Date__c,Client_Avail__r.Status__c,Promotion__c,Client_Avail__r.Local_Data_Category_Picklist__c,Client_Avail__r.APO_Date__c From Client_Avail_Price__c Where Promotion__c in :promoIDSet];
        
        for(Client_Avail_Price__c capRecord : queriedCaps){
            capMap.put(String.valueOf(capRecord.Client_Avail__c).trim()+String.valueOf(capRecord.Promotion__c).trim(),capRecord);
        }
        
        
        for(WB_ClientAvailTempPriceWrapper priceWrapper : tempPriceList){
            Client_Avail_Price__c capRecord;
            if(priceWrapper.promotionStatus == 'Committed'){
                capRecord = capMap.get(priceWrapper.clientAvailID.trim()+priceWrapper.promotionID.trim());
                if(capRecord!=null){
                    capMap.remove(priceWrapper.clientAvailID.trim()+priceWrapper.promotionID.trim());
                }
                if(capRecord == null){
                    capRecord = new Client_Avail_Price__c();
                    capRecord.Client_Avail__c = priceWrapper.clientAvailID;
                    capRecord.RecordTypeId = tpRecTypeId;
                    capRecord.Promotion__c = priceWrapper.promotionID;
                    capRecord.Promotion_Title_Detail__c = priceWrapper.promoTitleDetailID;
                    capRecord.CurrencyIsoCode = priceWrapper.currencyCode;
                    capRecord.CAP_Status__c = priceWrapper.priceStatus;
                    capRecord.CAP_Rate_Card__c = priceWrapper.rateCardId;
                    if(caMapValue.containsKey(priceWrapper.clientAvailID)){
                        capRecord.Episode_Price_Tier__c = caMapValue.get(priceWrapper.clientAvailID).Episode_Price_Tier__c;
                        capRecord.Episode_Price__c = caMapValue.get(priceWrapper.clientAvailID).Episode_Price__c;
                        capRecord.Category__c = caMapValue.get(priceWrapper.clientAvailID).Local_Data_Category_Picklist__c;
                    }
                    capRecord.Title__c = caMapValue.get(priceWrapper.clientAvailID).Local_Title__r.Title__c;
                }
                
                //String rcKey;
                //List<Rate_Card__c> lstRCs;
                
                if(priceWrapper.priceTier != NULL){
                    capRecord.Price_Tier__c = priceWrapper.priceTier; 
                    capRecord.Price__c = null;
                }else{
                    capRecord.Price_Tier__c = null;
                    capRecord.Price__c = priceWrapper.price;
                }
                capRecord.Promotion_Title_Detail__c = priceWrapper.promoTitleDetailID;
                capRecord.Effective_Date__c = priceWrapper.priceStartDate;
                capRecord.Expiry_Date__c = priceWrapper.priceEndDate;
                
                if(caMapValue.containsKey(priceWrapper.clientAvailID)){
                    Client_Avail__c caRec = caMapValue.get(priceWrapper.clientAvailID);
                    if(capRecord.Effective_Date__c < caRec.Start_Date__c){
                        if(caRec.APO_Date__c == null)
                            capRecord.Effective_Date__c = caRec.Start_Date__c;
                        else if(capRecord.Effective_Date__c < caRec.APO_Date__c)
                            capRecord.Effective_Date__c = caRec.APO_Date__c;  
                    }
                    
                    if(capRecord.Expiry_Date__c > caRec.End_Date__c)
                        capRecord.Expiry_Date__c = caRec.End_Date__c;  
                }
                //capRecord.CAP_Status__c = priceWrapper.priceStatus;
                tempCapUpsertList.add(capRecord);
            }
        }
        
        if(isBatchMode == false){      
            for(Client_Avail_Price__c capToBeCancelled : capMap.values()){
                Date currentDate = System.today(); 
                
                if(capToBeCancelled.Effective_Date__c <= currentDate && capToBeCancelled.Announcement_Records__r.size() > 0){
                    capToBeCancelled.Expiry_Date__c = currentDate;
                    capToBeCancelled.CAP_Status__c = 'Deleted' ;
                    tempCapUpsertList.add(capToBeCancelled);
                }else
                    tempCapDeleteList.add(capToBeCancelled);
            }               
        }
        
        if(tempCapUpsertList.size()>0)
        {
            Database.UpsertResult[] upsertResults = Database.upsert(tempCapUpsertList,true);
            if(upsertResults.size()>0){
                for(Integer index=0;index < tempPriceList.size();index++){
                    Database.UpsertResult upsertResult = upsertResults[index];
                    if(upsertResult.isSuccess()){
                        tempPriceList[index].status = 'Success';
                    }else{
                        List<String> errorMessages = new List<String>();
                        for(Database.Error error:upsertResult.getErrors()){
                            errorMessages.add(error.getMessage());
                        }
                        tempPriceList[index].status = 'Failed';
                        tempPriceList[index].messages = errorMessages;
                    }   
                } 
            }
        }
        
        if(tempCapDeleteList.size()>0){
            Database.DeleteResult[] deleteResults = Database.delete(tempCapDeleteList, true);
        }
        
        return tempPriceList;
    } 
    
    /*
Method to delete or end date tempcaps. Call this from batch by sending list of CAPs passed to execute method.
*/
    public static Boolean deleteOrEndDateTempPrice(List<Client_Avail_Price__c> tempCAPs){
        List<Client_Avail_Price__c> tempCapDeleteList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> tempCapUpdateList = new List<Client_Avail_Price__c>();
        
        List<Client_Avail_Price__c> queriedCaps = [Select Id,Name,Effective_Date__c,Client_Avail__c,CAP_Status__c,(Select Id,Name,Announcement_Date__c,Client_Start__c from Announcement_Records__r Limit 1) From Client_Avail_Price__c Where Id in :tempCAPs];
        
        for(Client_Avail_Price__c tempCap : queriedCaps){
            Date currentDate = System.today();
            
            if(tempCap.Effective_Date__c <= currentDate && tempCap.Announcement_Records__r.size() > 0){
                tempCap.Expiry_Date__c = currentDate;
                tempCap.CAP_Status__c = 'Deleted' ;
                tempCapUpdateList.add(tempCap);
            }else
                tempCapDeleteList.add(tempCap);
        }
        
        
        if(tempCapUpdateList.size()>0){
            Database.SaveResult[] deleteResults = Database.update(tempCapUpdateList, true);
        }
        
        if(tempCapDeleteList.size()>0){
            Database.DeleteResult[] deleteResults = Database.delete(tempCapDeleteList, true);
        }
        
        //for any errors during update/delete, log errors to CAS Error Log and return false.
        return true;
    }	
}