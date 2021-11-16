/******* 
Name:WB_TriggerHandlerCountClientAvail
Creation Date- 5th Sept'2014
Description- Trigger Handler for Count Client Avail on Commercial
Author- Navjyoti Mohanta
********/
/* =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                          Date                                  Comment
*  Prachi Gadewar                  28-7-2015                             CH01 : Added two methods validatePriceTiersOnInsert & validatePriceTiersOnUpdate
*                                                                                for ER-15 price tier validation.
*            
*  
*/
public class WB_TriggerHandlerCountClientAvail{

/*MDR - Updated on 26 April'17
Description - Below method update IsClientAvailChanges field of Release Plan on CA updation
*/


 public static void updateIsCAChangedFlagOnRP(){
    list<client_avail__c> clientListNew= new list<client_avail__c>();
    Map<Id,Commercial_Avail__c> mapRPCADateStatusChnage = new Map<Id,Commercial_Avail__c>();
    Map<Id,List<client_avail__c>> mapOfRPToCAs = new Map<Id,List<client_avail__c>>();
   
    Map<Id,Commercial_Avail__c> mapCommercialAvail = new Map<Id,Commercial_Avail__c>();
    //commercial_avail__c commAvail = new Commercial_Avail__c();
    clientListNew=Trigger.new;
    for(Client_Avail__c ca:clientListNew){
         Client_Avail__c caOld = (Client_Avail__c)Trigger.oldMap.get(ca.Id);
         //commercial_avail__c commAvail = new Commercial_Avail__c();
         //commAvail.Id = ca.commercial_avail__c;
       
         //if Start Date is changed or (Status is changed to "Confirmed" and RP Status is Tentative)  ER-000565 - CA Status
         if(ca.Start_Date__c != caOld.Start_Date__c || (ca.Status__c != caOld.Status__c && (ca.Status__c == 'Confirmed' || caOld.Status__c == 'Confirmed'))) {
             
             //To make map for RP for which CA (date & Status both) / (Status only) get changed
             if(!mapRPCADateStatusChnage.containsKey(ca.commercial_avail__c)){
                commercial_avail__c commAvail = new Commercial_Avail__c(id=ca.commercial_avail__c);
                mapRPCADateStatusChnage.put(commAvail.Id,commAvail);
             }
             mapRPCADateStatusChnage.get(ca.commercial_avail__c).IsClientAvailChanged__c = true; 
             
             if(ca.Status__c != caOld.Status__c && (ca.Status__c == 'Confirmed' && ca.Release_Plan_Status__c == 'Tentative')){
                mapRPCADateStatusChnage.get(ca.commercial_avail__c).Status__c = 'Confirmed';
                mapRPCADateStatusChnage.get(ca.commercial_avail__c).MRD_Roll_up__c = true;
             }
             
             if(!mapOfRPToCAs.containsKey(ca.commercial_avail__c)){
                mapOfRPToCAs.put(ca.commercial_avail__c,new List<Client_Avail__c>{ca});
             }else{
                mapOfRPToCAs.get(ca.commercial_avail__c).add(ca);
             }
         }
     }
             //ER-002142 : Include Tentative Avails in EAD Calculations 
             /*if(ca.Start_Date__c != caOld.Start_Date__c || (ca.Status__c != caOld.Status__c && (ca.Status__c == 'Confirmed' || caOld.Status__c == 'Confirmed' || ca.Status__c == 'Tentative'))) {
                 mapCommercialAvail.get(ca.commercial_avail__c).IsClientAvailChanged__c = true;
             }*/
             //ER-002142 : end    
         
            /*  if(commAvail.Id != NULL ){
                if(!mapCommercialAvail.containsKey(commAvail.Id))
                    mapCommercialAvail.put(commAvail.Id,commAvail);
            }*/
            
     WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = true;
    
     if(mapRPCADateStatusChnage != NULL && mapRPCADateStatusChnage.size()>0){
        Database.SaveResult[] srList = Database.update(mapRPCADateStatusChnage.values(), false);   
        for(integer i=0;i<srList.size();i++){
            Database.SaveResult sr = srList[i]; 
            if (!sr.isSuccess() && sr.getErrors().size() > 0) {  //ER-007118 
                Database.Error errArray = sr.getErrors()[0]; //ER-007118 
                for(Client_Avail__c errorCA : mapOfRPToCAs.get(mapRPCADateStatusChnage.values()[i].Id)){
                   //--WBTINC0207320-- system.debug('********** err.getMessage() **********  '+err.getMessage());
                   errorCA.addError(errArray.getMessage());
                }
            }
        }
    }
    WB_TriggerRecursionHelper.releasePlanRecursiveUpdate = false;
}
 
 
public static void CountClientAvail(){   
    
    Set<Id> setCommercialId = new Set<Id>();
    map<id,integer> countmap = new map<id,integer>();
    Set<commercial_avail__c> setUpdatecommercialId = new Set<commercial_avail__c>();
   
    list<client_avail__c> clientListNew= new list<client_avail__c>();
    
    if(Trigger.isDelete){
        clientListNew=Trigger.old;
        
    } else{
        clientListNew=Trigger.new;
       
    }
    
    list<commercial_avail__c> updateCommAvail= new list<commercial_avail__c>();
    list<client_avail__c> clientAvailCountList= new list<client_avail__c>();

        for(Client_Avail__c cm : clientListNew)
        {
            setCommercialId.add(cm.Commercial_Avail__c);
        }
       
        Map<Id,Commercial_Avail__c> rPlanMap = new Map<Id,Commercial_Avail__c>([Select IsClientAvailChanged__c,Count_Client_Avail__c,Status__c, ( select id,Status__c from Client_Avails__r) from Commercial_Avail__c where id in:setCommercialId]);
        List<Commercial_Avail__c> listCommercial = rPlanMap.values();
        for(integer y=0;y<listCommercial.size();y++ ){
            clientAvailCountList= listCommercial[y].Client_Avails__r;
            countmap.put(listCommercial[y].id,clientAvailCountList.size());
                    
        } 
        
        Boolean isStatusConfirmed = false;
        
        for(Integer i=0;i<listCommercial.size();i++){
            //ER-000565 - CA Status
            for(Client_Avail__c caRec : listCommercial[i].Client_Avails__r){
                for(Client_Avail__c caRecNew : clientListNew){
                    if(caRecNew.Id == caRec.Id){
                        if(caRec.Status__c == 'Confirmed')    
                            isStatusConfirmed = true;
                       
                    }
                 }
           }
           
           for(Integer z=0;z<countmap.size();z++){
            if(countmap.containskey(listCommercial[i].id)) { 
                listCommercial[i].Count_Client_Avail__c=countmap.get(listCommercial[i].id);
                listCommercial[i].IsClientAvailChanged__c = true; //MDR - Updated on 26 April'17
              
                //ER-000565 - CA Status
                if(isStatusConfirmed && !Trigger.isDelete){
                    if(listCommercial[i].Status__c == 'Tentative')
                        listCommercial[i].Status__c = 'Confirmed';
                }
                if(setUpdatecommercialId.add(listCommercial[i])){
                  updateCommAvail.add(listCommercial[i]);
                }  
            } 
        } 
        isStatusConfirmed = false;
    }
    
    Update updateCommAvail;
    
}

    // CH01 :  Validate Client avail records id Status is changed to Confirmed Status and if anyone is changing Price Tier value. 
    public static void validatePriceTiersOnUpdate()
    {
        Map<Id,Client_Avail__c> mapClientAvail = new Map<Id,Client_Avail__c>([SELECT id,Name,Price_Tier_Text__c,Status__c,Client__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,Title_Content_Type__c,Local_Title__r.Price_Code__c from Client_Avail__c where id in: trigger.new]);
        List<Client_Avail__c> caList = new List<Client_Avail__c>();
        for(Client_Avail__c caRec : mapClientAvail.values()){
            Client_Avail__c oldClientAvailRec = (Client_Avail__c)Trigger.oldMap.get(caRec.id);
            if(((caRec.Status__c != oldClientAvailRec.Status__c) && caRec.Status__c == 'Confirmed') && caRec.Title_Content_Type__c == 'Feature'){
                caList.add(caRec);
            }
        }
        
        Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(caList);
        
        for(Client_Avail__c clientAvail : (list<Client_Avail__c>)trigger.new)
        {
            Client_Avail__c oldClientAvail = (Client_Avail__c)Trigger.oldMap.get(clientAvail.id);
            if(clientAvail.Status__c != oldClientAvail.Status__c || clientAvail.Price_Tier_Text__c != oldClientAvail.Price_Tier_Text__c)
            {                
                if(clientAvail.Status__c == 'Confirmed' || (clientAvail.Price_Tier_Text__c != oldClientAvail.Price_Tier_Text__c || clientAvail.Price_Tier_Text__c == null))
                {
                    if(clientAvail.Price__c == null && clientAvail.Title_Content_Type__c == 'Feature'){
                    /* sriniz comment
                    if(clientAvail.Status__c == 'Confirmed' && (mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c == null || mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c == ''))
                        clientAvail.adderror(Label.WB_Price_code_Not_Available+ ' ' + oldClientAvail.Name);                    
                    else */
                    if(clientAvail.Status__c == 'Confirmed')
                    {
                        if((mapPricingRecords != null && mapPricingRecords.size()>0) && !clientAvail.CA_CRM_Country__c)
                        {
                            if(mapPricingRecords.get(clientAvail.Client__c) != null &&
                               mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c) != null &&
                               mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c) != null &&
                               mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c) != null &&
                               mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c) != null)
                            
                            {
                                /* sriniz comment
                                Pricing__c MatchingPricing = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c).get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                                //--WBTINC0207320-- system.debug('********MatchingPricing  : '+MatchingPricing); 
                                if(MatchingPricing != null && clientAvail.Price_Tier_Text__c != MatchingPricing.Price_Tier__c && clientAvail.Status__c == 'Confirmed')
                                    clientAvail.adderror(Label.WB_Price_Tier_Value_Not_Matching + ' ' + oldClientAvail.Name);
                                */
                                Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                                Boolean isPriceTierFound = false;
                                for(Pricing__c pricingRecords : allPriceTiers.values())                            {
                                     if(pricingRecords != null && mapClientAvail.get(clientAvail.id).Price_Tier_Text__c == pricingRecords.Price_Tier__c && clientAvail.Status__c == 'Confirmed'){
                                        isPriceTierFound = true;
                                    }
                                }
                                if(!isPriceTierFound)
                                    clientAvail.adderror(Label.WB_Price_Tier_Value_Not_Matching + ' ' + clientAvail.Name);

                            }      
                            else
                                clientAvail.adderror(Label.WB_Pricing_Record_Not_Available + ' '+ oldClientAvail.Name);
                        }else{
                            if(clientAvail.CA_CRM_Country__c){
                                
                                if(clientAvail.Price_Tier_Text__c == Null){
                                    
                                    clientAvail.adderror(Label.WB_Pricing_Record_Not_Available + ' '+ oldClientAvail.Name);
                                }else if(clientAvail.CA_Rate_Card__c == Null && (clientAvail.Price_Tier_Text__c != Null && clientAvail.Price_Tier_Text__c != '' && clientAvail.Price_Tier_Text__c != 'TBD')){
                                    clientAvail.adderror('No matching Rate Card' + ' ' + clientAvail.Name);
                                }
                            }else{
                                clientAvail.adderror(Label.WB_Pricing_Record_Not_Available + ' '+ oldClientAvail.Name);
                            }
                        }
                            
                    }//'Price Tier field have wrong value for'
                }
                }
            }
        }
    }
    
    // CH01 :  Validate Client avail records id Status is Confirmed and if anyone and Price Tier is null. 
    /*public static void validatePriceTiersOnInsert()
    {        
        Map<Id,Client_Avail__c> mapClientAvail = new Map<Id,Client_Avail__c>([SELECT id,Name,Price_Tier_Text__c,Status__c,Client__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,Title_Content_Type__c,Local_Title__r.Price_Code__c from Client_Avail__c where id in: trigger.new]);
        Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(mapClientAvail.values());
        for(Client_Avail__c clientAvail : (list<Client_Avail__c>)trigger.new)
        {
            if(clientAvail.Status__c == 'Confirmed' && clientAvail.Price__c == null && clientAvail.Title_Content_Type__c == 'Feature')
            {
                    if(mapPricingRecords != null && mapPricingRecords.size()>0)
                    {
                        //--WBTINC0207320-- system.debug('Mapofrecord****' + mapPricingRecords);
                        if(mapPricingRecords.get(clientAvail.Client__c) != null &&
                           mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c) != null &&
                           mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c) != null &&
                           mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c) != null &&
                           mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c) != null)
                        
                        {
                            Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                            Boolean isPriceTierFound = false;
                            for(Pricing__c pricingRecords : allPriceTiers.values())                            
                                if(pricingRecords != null && mapClientAvail.get(clientAvail.id).Price_Tier_Text__c == pricingRecords.Price_Tier__c && clientAvail.Status__c == 'Confirmed')
                                    isPriceTierFound = true;
                            if(!isPriceTierFound)
                                clientAvail.adderror(Label.WB_Price_Tier_Value_Not_Matching + ' ' + clientAvail.Name);
                            
                        }      
                        else
                            clientAvail.adderror(Label.WB_Pricing_Record_Not_Available + clientAvail.Name);
                    }
                    else
                        clientAvail.adderror(Label.WB_Pricing_Record_Not_Available + clientAvail.Name); 
            }
        }
    }
    */
    public static void assignRateCardBeforeUpdate(){
        
        List<Client_Avail__c> caList = new List<Client_Avail__c>();
        List<Client_Avail__c> caRateCardNullList = new List<Client_Avail__c>();
        caList = trigger.new;
        
        for(Client_Avail__c ca : caList){
            if(ca.CA_Rate_Card__c == Null && ca.CA_CRM_Country__c && ((ca.Price_Tier_Text__c != Null && ca.Price_Tier_Text__c != '' && ca.Price_Tier_Text__c != 'TBD') || ca.Price__c != Null)){
                caRateCardNullList.add(ca);
            }
        }
        
        if(caRateCardNullList != Null && caRateCardNullList.size()>0){
            WB_RateCardHelper.assignRateCardToCA(caRateCardNullList);
        }
    } 
}