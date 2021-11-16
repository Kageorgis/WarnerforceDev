/*========================================================================================================
* @author: Sai Santhan
* @date: 20/09/2020
* @description: Helper class that will implement the functionality of catalog record type
==========================================================================================================*/
public class RF_ReleaseHelperCatalogsetDate {
     //Date defaulting field calculations on insert for catalog record
    public static sObject setDefaultDateOnInsert(sObject newrec1, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap){
       //Requirement - If street date is not equal to null isphysical checkbox should enable and If street date is equal to null isphysical checkbox should disable on insert  

        String streetDate_ApiNm= 'Street_Date__c';
        String isPhysical_ApiNm= 'IsPhysical__c';      
        if(newrec1.get(streetDate_ApiNm)!=null){
            newrec1.put(isPhysical_ApiNm,true);
        }
        if(newrec1.get(streetDate_ApiNm)==null){
            newrec1.put(isPhysical_ApiNm,false);
        }
        
        
        
        
        String MarketingGuidelinesLabel= 'Marketing_Guidelines_Guardrails_catalog';
        system.debug('releaseDefaultLabelMap record for Marketing days: '+releaseDefaultLabelMap.get(MarketingGuidelinesLabel));
        
        String MarketingGuidelinesLabel_ApiName = releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Source_Field__c;
        String Voddate_ApiName = releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(MarketingGuidelinesLabel_ApiName)==null ){ 
            if(newrec1.get(Voddate_ApiName)!=null){
                if(releaseDefaultLabelMap.get(MarketingGuidelinesLabel)!=null){
                    
                    Date MarketingGuidelinesLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Destination_Field__c)); 
                    system.debug('MarketingGuidelinesLabelDate: '+MarketingGuidelinesLabelDate);
                    
                    Decimal MarketingGuidelinesDays= releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Calculation__c;
                    system.debug('MarketingGuidelinesDays: '+MarketingGuidelinesDays);
                    Date MarksubDate= MarketingGuidelinesLabelDate.addDays(Integer.ValueOf(MarketingGuidelinesDays));
                    system.debug('MarksubDate: '+MarksubDate);
                    newrec1.put(MarketingGuidelinesLabel_ApiName,MarksubDate);
                }
            }
            
        }
        String DomesticLabel= 'Domestic_Initial_Info_To_Mkts_catalog';
        system.debug('releaseDefaultLabelMap record for DomesticLabel days: '+releaseDefaultLabelMap.get(DomesticLabel));
        
        String DomesticLabel_ApiName = releaseDefaultLabelMap.get(DomesticLabel).Source_Field__c;
        String Voddate1_ApiName = releaseDefaultLabelMap.get(DomesticLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(DomesticLabel_ApiName)==null){ 
            if(newrec1.get(Voddate1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(DomesticLabel)!=null){
                    
                    Date DomesticLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DomesticLabel).Destination_Field__c)); 
                    system.debug('DomesticLabelDate: '+DomesticLabelDate);
                    
                    Decimal DomesticLabelDateDays= releaseDefaultLabelMap.get(DomesticLabel).Calculation__c;
                    system.debug('DomesticLabelDateDays: '+DomesticLabelDateDays);
                    Date DomsubDate= DomesticLabelDate.addDays(Integer.ValueOf(DomesticLabelDateDays));
                    system.debug('DomsubDate: '+DomsubDate);
                    newrec1.put(DomesticLabel_ApiName,DomsubDate);
                }
            }
            
        }
        String WWkickoffLabel= 'WW_Creative_Kick_Off_catalog';
        system.debug('releaseDefaultLabelMap record for WWkickoffLabel days: '+releaseDefaultLabelMap.get(WWkickoffLabel));
        
        String WWkickoffLabel_ApiName = releaseDefaultLabelMap.get(WWkickoffLabel).Source_Field__c;
        String Voddate2_ApiName = releaseDefaultLabelMap.get(WWkickoffLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(WWkickoffLabel_ApiName)==null){ 
            if(newrec1.get(Voddate2_ApiName)!=null){
                if(releaseDefaultLabelMap.get(WWkickoffLabel)!=null){
                    
                    Date WWkickoffLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(WWkickoffLabel).Destination_Field__c)); 
                    system.debug('WWkickoffLabelDate: '+WWkickoffLabelDate);
                    
                    Decimal WWkickoffLabelDateDays= releaseDefaultLabelMap.get(WWkickoffLabel).Calculation__c;
                    system.debug('WWkickoffLabelDateDays: '+WWkickoffLabelDateDays);
                    Date WWkickoffsubDate= WWkickoffLabelDate.addDays(Integer.ValueOf(WWkickoffLabelDateDays));
                    system.debug('WWkickoffsubDate: '+WWkickoffsubDate);
                    newrec1.put(WWkickoffLabel_ApiName,WWkickoffsubDate);
                }
            }
        }
        String MarketingAlertLabel= 'Marketing_Alert_Request_Input_To_catalog';
        system.debug('releaseDefaultLabelMap record for MarketingAlertLabel days: '+releaseDefaultLabelMap.get(MarketingAlertLabel));
        
        String MarketingAlertLabel_ApiName = releaseDefaultLabelMap.get(MarketingAlertLabel).Source_Field__c;
        String Voddate3_ApiName = releaseDefaultLabelMap.get(MarketingAlertLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(MarketingAlertLabel_ApiName)==null){ 
            if(newrec1.get(Voddate3_ApiName)!=null){
                if(releaseDefaultLabelMap.get(MarketingAlertLabel)!=null){
                    
                    Date MarketingAlertLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingAlertLabel).Destination_Field__c)); 
                    system.debug('MarketingAlertLabelDate: '+MarketingAlertLabelDate);
                    
                    Decimal MarketingAlertLabelDateDays= releaseDefaultLabelMap.get(MarketingAlertLabel).Calculation__c;
                    system.debug('MarketingAlertLabelDateDays: '+MarketingAlertLabelDateDays);
                    Date MarketingAlertsubDate= MarketingAlertLabelDate.addDays(Integer.ValueOf(MarketingAlertLabelDateDays));
                    system.debug('MarketingAlertsubDate: '+MarketingAlertsubDate);
                    newrec1.put(MarketingAlertLabel_ApiName,MarketingAlertsubDate);
                }
            }
        }
        
        String L1reviewLabel= 'L1_Review_Date_catalog';
        system.debug('releaseDefaultLabelMap record for L1reviewLabel days: '+releaseDefaultLabelMap.get(L1reviewLabel));
        
        String L1reviewLabel_ApiName = releaseDefaultLabelMap.get(L1reviewLabel).Source_Field__c;
        String Voddate4_ApiName = releaseDefaultLabelMap.get(L1reviewLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(L1reviewLabel_ApiName)==null){ 
            if(newrec1.get(Voddate4_ApiName)!=null){
                if(releaseDefaultLabelMap.get(L1reviewLabel)!=null){
                    
                    Date L1reviewLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(L1reviewLabel).Destination_Field__c)); 
                    system.debug('L1reviewLabelDate: '+L1reviewLabelDate);
                    
                    Decimal L1reviewLabelDateDateDays= releaseDefaultLabelMap.get(L1reviewLabel).Calculation__c;
                    system.debug('L1reviewLabelDateDateDays: '+L1reviewLabelDateDateDays);
                    Date L1reviewLabelsubDate= L1reviewLabelDate.addDays(Integer.ValueOf(L1reviewLabelDateDateDays));
                    system.debug('L1reviewLabelsubDate: '+L1reviewLabelsubDate);
                    newrec1.put(L1reviewLabel_ApiName,L1reviewLabelsubDate);
                }
            }
        }
       
        
        String clientavailsLabel= 'Client_Avails_Confirmation_catalog';
        system.debug('releaseDefaultLabelMap record for clientavailsLabel days: '+releaseDefaultLabelMap.get(clientavailsLabel));
        
        String clientavailsLabel_ApiName = releaseDefaultLabelMap.get(clientavailsLabel).Source_Field__c;
        String EST_ApiName = releaseDefaultLabelMap.get(clientavailsLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(clientavailsLabel_ApiName)==null){ 
            if(newrec1.get(EST_ApiName)!=null){
                if(releaseDefaultLabelMap.get(clientavailsLabel)!=null){
                    
                    Date clientavailsLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(clientavailsLabel).Destination_Field__c)); 
                    system.debug('clientavailsLabelDate: '+clientavailsLabelDate);
                    
                    Decimal clientavailsLabelDateDays= releaseDefaultLabelMap.get(clientavailsLabel).Calculation__c;
                    system.debug('clientavailsLabelDateDays: '+clientavailsLabelDateDays);
                    Date clientavailssubDate= clientavailsLabelDate.addDays(Integer.ValueOf(clientavailsLabelDateDays));
                    system.debug('clientavailssubDate: '+clientavailssubDate);
                    newrec1.put(clientavailsLabel_ApiName,clientavailssubDate);
                }
            }
        }
        String AnnouncedtLabel= 'Trade_Solicitation_Date_catalog';
        system.debug('releaseDefaultLabelMap record for AnnouncedtLabel days: '+releaseDefaultLabelMap.get(AnnouncedtLabel));
        
        String AnnouncedtLabel_ApiName = releaseDefaultLabelMap.get(AnnouncedtLabel).Source_Field__c;
        String stdt_ApiName = releaseDefaultLabelMap.get(AnnouncedtLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(AnnouncedtLabel_ApiName)==null){ 
            if(newrec1.get(stdt_ApiName)!=null){
                if(releaseDefaultLabelMap.get(AnnouncedtLabel)!=null){
                    
                    Date AnnouncedtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(AnnouncedtLabel).Destination_Field__c)); 
                    system.debug('AnnouncedtLabelDate: '+AnnouncedtLabelDate);
                    
                    Decimal AnnouncedtLabelDateDays= releaseDefaultLabelMap.get(AnnouncedtLabel).Calculation__c;
                    system.debug('AnnouncedtLabelDateDays: '+AnnouncedtLabelDateDays);
                    Date AnnouncedtLabelsubDate= AnnouncedtLabelDate.addDays(Integer.ValueOf(AnnouncedtLabelDateDays));
                    system.debug('AnnouncedtLabelsubDate: '+AnnouncedtLabelsubDate);
                    newrec1.put(AnnouncedtLabel_ApiName,AnnouncedtLabelsubDate);
                }
            }
        }
        
        String L2reviewLabel= 'L2_Review_Date_catalog';
        system.debug('releaseDefaultLabelMap record for L2reviewLabel days: '+releaseDefaultLabelMap.get(L2reviewLabel));
        
        String L2reviewLabel_ApiName = releaseDefaultLabelMap.get(L2reviewLabel).Source_Field__c;
        String Vod5_ApiName = releaseDefaultLabelMap.get(L2reviewLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(L2reviewLabel_ApiName)==null ){ 
            if(newrec1.get(Vod5_ApiName)!=null){
                if(releaseDefaultLabelMap.get(L2reviewLabel)!=null){
                    
                    Date L2reviewLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(L2reviewLabel).Destination_Field__c)); 
                    system.debug('L2reviewLabelDate: '+L2reviewLabelDate);
                    
                    Decimal L2reviewLabelDateDateDays= releaseDefaultLabelMap.get(L2reviewLabel).Calculation__c;
                    system.debug('L2reviewLabelDateDateDays: '+L2reviewLabelDateDateDays);
                    Date L2reviewLabelsubDate= L2reviewLabelDate.addDays(Integer.ValueOf(L2reviewLabelDateDateDays));
                    system.debug('L2reviewLabelsubDate: '+L2reviewLabelsubDate);
                    newrec1.put(L2reviewLabel_ApiName,L2reviewLabelsubDate);
                }
            }
        }
         String L3reviewLabel= 'L3_Review_Date_catalog';
        system.debug('releaseDefaultLabelMap record for L2reviewLabel days: '+releaseDefaultLabelMap.get(L2reviewLabel));
        
        String L3reviewLabel_ApiName = releaseDefaultLabelMap.get(L3reviewLabel).Source_Field__c;
        String L2label_ApiName = releaseDefaultLabelMap.get(L3reviewLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(L3reviewLabel_ApiName)==null){ 
           // system.debug('newrec1.get(L2_ApiName)===>'+newrec1.get(L2_ApiName));
           // system.debug('L2_ApiName===>'+L2_ApiName);
            if(newrec1.get(L2label_ApiName)!=null){
                if(releaseDefaultLabelMap.get(L3reviewLabel)!=null){
                    
                    Date L3reviewLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(L3reviewLabel).Destination_Field__c)); 
                    system.debug('L3reviewLabelDate: '+L3reviewLabelDate);
                    
                    Decimal L3reviewLabelDateDateDays= releaseDefaultLabelMap.get(L3reviewLabel).Calculation__c;
                    system.debug('L3reviewLabelDateDateDays: '+L3reviewLabelDateDateDays);
                    Date L3reviewLabelsubDate= L3reviewLabelDate.addDays(Integer.ValueOf(L3reviewLabelDateDateDays));
                    system.debug('L3reviewLabelsubDate: '+L3reviewLabelsubDate);
                    newrec1.put(L3reviewLabel_ApiName,L3reviewLabelsubDate);
                }
            }
            
        }
        String FilmmakerLabel= 'Filmmaker_3rd_Party_Due_Date_catalog';
        system.debug('releaseDefaultLabelMap record for FilmmakerLabel days: '+releaseDefaultLabelMap.get(FilmmakerLabel));
        
        String FilmmakerLabel_ApiName = releaseDefaultLabelMap.get(FilmmakerLabel).Source_Field__c;
        String L3_ApiName = releaseDefaultLabelMap.get(FilmmakerLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(FilmmakerLabel_ApiName)==null){ 
            system.debug('newrec1.get(L3_ApiName)====>'+newrec1.get(L3_ApiName));
            system.debug('L3_ApiName===>'+L3_ApiName);
            if(newrec1.get(L3_ApiName)!=null){
                if(releaseDefaultLabelMap.get(FilmmakerLabel)!=null){
                    
                    Date FilmmakerLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(FilmmakerLabel).Destination_Field__c)); 
                    system.debug('FilmmakerLabelDate: '+FilmmakerLabelDate);
                    
                    Decimal FilmmakerLabelDateDateDays= releaseDefaultLabelMap.get(FilmmakerLabel).Calculation__c;
                    system.debug('FilmmakerLabelDateDateDays: '+FilmmakerLabelDateDateDays);
                    Date filmmakersubDate= FilmmakerLabelDate.addDays(Integer.ValueOf(FilmmakerLabelDateDateDays));
                    system.debug('filmmakersubDate: '+filmmakersubDate);
                    newrec1.put(FilmmakerLabel_ApiName,filmmakersubDate);
                }
            }
        }
        String SellingguidelinesdtLabel= 'Selling_Guides_Due_Date_catalog';
        system.debug('releaseDefaultLabelMap record for AnnouncedtLabel days: '+releaseDefaultLabelMap.get(SellingguidelinesdtLabel));
        
        String SellingguidelinesdtLabel_ApiName = releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Source_Field__c;
        String stdt1_ApiName = releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(SellingguidelinesdtLabel_ApiName)==null){ 
            if(newrec1.get(stdt1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(SellingguidelinesdtLabel)!=null){
                    
                    Date SellingguidelinesdtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Destination_Field__c)); 
                    system.debug('SellingguidelinesdtLabelDate: '+SellingguidelinesdtLabelDate);
                    
                    Decimal SellingguidelinesdtLabelDateDays= releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Calculation__c;
                    system.debug('SellingguidelinesdtLabelDateDays: '+SellingguidelinesdtLabelDateDays);
                    Date SellingguidelinesdtsubDate= SellingguidelinesdtLabelDate.addMonths(Integer.ValueOf(SellingguidelinesdtLabelDateDays));
                    system.debug('SellingguidelinesdtsubDate: '+SellingguidelinesdtsubDate);
                    newrec1.put(SellingguidelinesdtLabel_ApiName,SellingguidelinesdtsubDate);
                }
            }
        }
        String InplantLabel= 'In_Plant_Date_catalog';
        system.debug('releaseDefaultLabelMap record for InplantLabel days: '+releaseDefaultLabelMap.get(InplantLabel));
        
        String InplantLabel_ApiName = releaseDefaultLabelMap.get(InplantLabel).Source_Field__c;
        String stdt2_ApiName = releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(InplantLabel_ApiName)==null){ 
            if(newrec1.get(stdt2_ApiName)!=null){
                if(releaseDefaultLabelMap.get(InplantLabel)!=null){
                    
                    Date InplantLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c)); 
                    system.debug('InplantLabelDate: '+InplantLabelDate);
                    
                    Decimal InplantLabelDateDays= releaseDefaultLabelMap.get(InplantLabel).Calculation__c;
                    system.debug('InplantLabelDateDays: '+InplantLabelDateDays);
                    Date InplantLabelDtsubDate= InplantLabelDate.addDays(Integer.ValueOf(InplantLabelDateDays));
                    system.debug('InplantLabelDtsubDate: '+InplantLabelDtsubDate);
                    newrec1.put(InplantLabel_ApiName,InplantLabelDtsubDate);
                }
            }
        }
        String TradeassetsLabel= 'Trade_Assets_Due_to_JV_Date_catalog';
        system.debug('releaseDefaultLabelMap record for TradeassetsLabel days: '+releaseDefaultLabelMap.get(TradeassetsLabel));
        
        String TradeassetsLabel_ApiName = releaseDefaultLabelMap.get(TradeassetsLabel).Source_Field__c;
        String Announce1_ApiName = releaseDefaultLabelMap.get(TradeassetsLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(TradeassetsLabel_ApiName)==null){ 
            if(newrec1.get(Announce1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(TradeassetsLabel)!=null){
                    
                    Date TradeassetsLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeassetsLabel).Destination_Field__c)); 
                    system.debug('TradeassetsLabelDate: '+TradeassetsLabelDate);
                    
                    Decimal TradeassetsLabelDateDays= releaseDefaultLabelMap.get(TradeassetsLabel).Calculation__c;
                    system.debug('TradeassetsLabelDateDays: '+TradeassetsLabelDateDays);
                    Date TradeassetsLabelsubDate= TradeassetsLabelDate.addDays(Integer.ValueOf(TradeassetsLabelDateDays));
                    system.debug('TradeassetsLabelsubDate: '+TradeassetsLabelsubDate);
                    newrec1.put(TradeassetsLabel_ApiName,TradeassetsLabelsubDate);
                }
            }
        }
        
        String orderdueLabel= 'Order_Due_Date_catalog';
        system.debug('releaseDefaultLabelMap record for TradeassetsLabel days: '+releaseDefaultLabelMap.get(TradeassetsLabel));
        
        String orderdueLabel_ApiName = releaseDefaultLabelMap.get(orderdueLabel).Source_Field__c;
        String st4_ApiName = releaseDefaultLabelMap.get(orderdueLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if(newrec1.get(orderdueLabel_ApiName)==null){ 
            if(newrec1.get(st4_ApiName)!=null){
                if(releaseDefaultLabelMap.get(orderdueLabel)!=null){
                    
                    Date orderdueLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(orderdueLabel).Destination_Field__c)); 
                    system.debug('orderdueLabelDate: '+orderdueLabelDate);
                    
                    Decimal orderdueLabelDateDays= releaseDefaultLabelMap.get(orderdueLabel).Calculation__c;
                    system.debug('orderdueLabelDateDays: '+orderdueLabelDateDays);
                    Date orderdueLabelsubDate= orderdueLabelDate.addDays(Integer.ValueOf(orderdueLabelDateDays));
                    system.debug('orderdueLabelsubDate: '+orderdueLabelsubDate);
                    newrec1.put(orderdueLabel_ApiName,orderdueLabelsubDate);
                }
            }
        }
        
        /*Premium release date = sreet date - 63
		Premiumrelease announce date now is trade email date	
		*/
        String PremiumReleaseAnnounceDate= 'Premium_Release_Announce_Date_catalog';
        
        String PremiumReleaseAnnounceDate_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Source_Field__c;
        String Street_Date_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c;
        
        if(newrec1.get(PremiumReleaseAnnounceDate_ApiName)==null){
            if(newrec1.get(Street_Date_ApiName)!=null){
                if(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate)!=null){
                    Date streetDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c)); 
                    Decimal streetNumDays= releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Calculation__c;
                    Date streetSubDate= streetDate.addDays(Integer.ValueOf(streetNumDays));
                    newrec1.put(PremiumReleaseAnnounceDate_ApiName,streetSubDate);
                }   
            }
        }
        
        return newrec1;        
    }
    
    //Date defaulting field calculations on update for catalog record
   	/*ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
    User should be able to clear off dependent fields like PVOD date, PEST and able to save record successfully.*/
    public static void setdateonupdate(SObject newrec1,Map<Id, SObject> oldReleaseMap,Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap,Map< String, String > destinationfieldMap,Map< String, Decimal > releaseDateDefaultsMap,Map< String, String > sourcefieldMap,Map< String, String > calculatedfieldMap,Map< String, String > calculatedfield_operation_Map){        
        system.debug('newrec1 Value: '+newrec1);
        SObject oldrec = (RELEASE__c)oldReleaseMap.get(newrec1.id);
        
        Release__c newRecord = (Release__c)(newrec1);
        Release__c oldRecord= (Release__c)oldReleaseMap.get(newRecord.Id);
         //Requirement - If street date is not equal to null isphysical checkbox should enable and If street date is equal to null isphysical checkbox should disable on update  

        String streetDate_ApiNm= 'Street_Date__c';        
        String isPhysical_ApiNm= 'IsPhysical__c';
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String MarketingGuidelinesLabel= 'Marketing_Guidelines_Guardrails_catalog';
        system.debug('releaseDefaultLabelMap record for Marketing days: '+releaseDefaultLabelMap.get(MarketingGuidelinesLabel));
        
        String MarketingGuidelinesLabel_ApiName = releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Source_Field__c;
        String Voddate_ApiName = releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(MarketingGuidelinesLabel_ApiName)==null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)
        	||(newrec1.get(MarketingGuidelinesLabel_ApiName)!=null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)){ 
            if(newrec1.get(Voddate_ApiName)!=null){
                if(releaseDefaultLabelMap.get(MarketingGuidelinesLabel)!=null){
                    
                    Date MarketingGuidelinesLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Destination_Field__c)); 
                    system.debug('MarketingGuidelinesLabelDate: '+MarketingGuidelinesLabelDate);
                    
                    Decimal MarketingGuidelinesDays= releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Calculation__c;
                    system.debug('MarketingGuidelinesDays: '+MarketingGuidelinesDays);
                    Date MarksubDate= MarketingGuidelinesLabelDate.addDays(Integer.ValueOf(MarketingGuidelinesDays));
                    system.debug('MarksubDate: '+MarksubDate);
                    newrec1.put(MarketingGuidelinesLabel_ApiName,MarksubDate);
                }
            }
            
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String DomesticLabel= 'Domestic_Initial_Info_To_Mkts_catalog';
        system.debug('releaseDefaultLabelMap record for DomesticLabel days: '+releaseDefaultLabelMap.get(DomesticLabel));
        
        String DomesticLabel_ApiName = releaseDefaultLabelMap.get(DomesticLabel).Source_Field__c;
        String Voddate1_ApiName = releaseDefaultLabelMap.get(DomesticLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(DomesticLabel_ApiName)==null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)
        	||(newrec1.get(DomesticLabel_ApiName)!=null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)){ 
            if(newrec1.get(Voddate1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(DomesticLabel)!=null){
                    
                    Date DomesticLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DomesticLabel).Destination_Field__c)); 
                    system.debug('DomesticLabelDate: '+DomesticLabelDate);
                    
                    Decimal DomesticLabelDateDays= releaseDefaultLabelMap.get(DomesticLabel).Calculation__c;
                    system.debug('DomesticLabelDateDays: '+DomesticLabelDateDays);
                    Date DomsubDate= DomesticLabelDate.addDays(Integer.ValueOf(DomesticLabelDateDays));
                    system.debug('DomsubDate: '+DomsubDate);
                    newrec1.put(DomesticLabel_ApiName,DomsubDate);
                }
            }
            
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String WWkickoffLabel= 'WW_Creative_Kick_Off_catalog';
        system.debug('releaseDefaultLabelMap record for WWkickoffLabel days: '+releaseDefaultLabelMap.get(WWkickoffLabel));
        
        String WWkickoffLabel_ApiName = releaseDefaultLabelMap.get(WWkickoffLabel).Source_Field__c;
        String Voddate2_ApiName = releaseDefaultLabelMap.get(WWkickoffLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(WWkickoffLabel_ApiName)==null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)
        	||(newrec1.get(WWkickoffLabel_ApiName)!=null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)){ 
            if(newrec1.get(Voddate2_ApiName)!=null){
                if(releaseDefaultLabelMap.get(WWkickoffLabel)!=null){
                    
                    Date WWkickoffLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(WWkickoffLabel).Destination_Field__c)); 
                    system.debug('WWkickoffLabelDate: '+WWkickoffLabelDate);
                    
                    Decimal WWkickoffLabelDateDays= releaseDefaultLabelMap.get(WWkickoffLabel).Calculation__c;
                    system.debug('WWkickoffLabelDateDays: '+WWkickoffLabelDateDays);
                    Date WWkickoffsubDate= WWkickoffLabelDate.addDays(Integer.ValueOf(WWkickoffLabelDateDays));
                    system.debug('WWkickoffsubDate: '+WWkickoffsubDate);
                    newrec1.put(WWkickoffLabel_ApiName,WWkickoffsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String MarketingAlertLabel= 'Marketing_Alert_Request_Input_To_catalog';
        system.debug('releaseDefaultLabelMap record for MarketingAlertLabel days: '+releaseDefaultLabelMap.get(MarketingAlertLabel));
        
        String MarketingAlertLabel_ApiName = releaseDefaultLabelMap.get(MarketingAlertLabel).Source_Field__c;
        String Voddate3_ApiName = releaseDefaultLabelMap.get(MarketingAlertLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(MarketingAlertLabel_ApiName)==null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)
        	||(newrec1.get(MarketingAlertLabel_ApiName)!=null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)){ 
            if(newrec1.get(Voddate3_ApiName)!=null){
                if(releaseDefaultLabelMap.get(MarketingAlertLabel)!=null){
                    
                    Date MarketingAlertLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingAlertLabel).Destination_Field__c)); 
                    system.debug('MarketingAlertLabelDate: '+MarketingAlertLabelDate);
                    
                    Decimal MarketingAlertLabelDateDays= releaseDefaultLabelMap.get(MarketingAlertLabel).Calculation__c;
                    system.debug('MarketingAlertLabelDateDays: '+MarketingAlertLabelDateDays);
                    Date MarketingAlertsubDate= MarketingAlertLabelDate.addDays(Integer.ValueOf(MarketingAlertLabelDateDays));
                    system.debug('MarketingAlertsubDate: '+MarketingAlertsubDate);
                    newrec1.put(MarketingAlertLabel_ApiName,MarketingAlertsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String L1reviewLabel= 'L1_Review_Date_catalog';
        system.debug('releaseDefaultLabelMap record for L1reviewLabel days: '+releaseDefaultLabelMap.get(L1reviewLabel));
        
        String L1reviewLabel_ApiName = releaseDefaultLabelMap.get(L1reviewLabel).Source_Field__c;
        String Voddate4_ApiName = releaseDefaultLabelMap.get(L1reviewLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(L1reviewLabel_ApiName)==null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)
        	||(newrec1.get(L1reviewLabel_ApiName)!=null && newRecord.VOD_Street_Date__c!=oldRecord.VOD_Street_Date__c)){ 
            if(newrec1.get(Voddate4_ApiName)!=null){
                if(releaseDefaultLabelMap.get(L1reviewLabel)!=null){
                    
                    Date L1reviewLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(L1reviewLabel).Destination_Field__c)); 
                    system.debug('L1reviewLabelDate: '+L1reviewLabelDate);
                    
                    Decimal L1reviewLabelDateDateDays= releaseDefaultLabelMap.get(L1reviewLabel).Calculation__c;
                    system.debug('L1reviewLabelDateDateDays: '+L1reviewLabelDateDateDays);
                    Date L1reviewLabelsubDate= L1reviewLabelDate.addDays(Integer.ValueOf(L1reviewLabelDateDateDays));
                    system.debug('L1reviewLabelsubDate: '+L1reviewLabelsubDate);
                    newrec1.put(L1reviewLabel_ApiName,L1reviewLabelsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String L2reviewLabel= 'L2_Review_Date_catalog';
        system.debug('releaseDefaultLabelMap record for L2reviewLabel days: '+releaseDefaultLabelMap.get(L2reviewLabel));
        
        String L2reviewLabel_ApiName = releaseDefaultLabelMap.get(L2reviewLabel).Source_Field__c;
        String Announce_ApiName = releaseDefaultLabelMap.get(L2reviewLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(L2reviewLabel_ApiName)==null && newRecord.Trade_Solicitation_Date__c!=oldRecord.Trade_Solicitation_Date__c)
        	||(newrec1.get(L2reviewLabel_ApiName)!=null && newRecord.Trade_Solicitation_Date__c!=oldRecord.Trade_Solicitation_Date__c)){ 
            if(newrec1.get(Announce_ApiName)!=null){
                if(releaseDefaultLabelMap.get(L2reviewLabel)!=null){
                    
                    Date L2reviewLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(L2reviewLabel).Destination_Field__c)); 
                    system.debug('L2reviewLabelDate: '+L2reviewLabelDate);
                    
                    Decimal L2reviewLabelDateDateDays= releaseDefaultLabelMap.get(L2reviewLabel).Calculation__c;
                    system.debug('L2reviewLabelDateDateDays: '+L2reviewLabelDateDateDays);
                    Date L2reviewLabelsubDate= L2reviewLabelDate.addDays(Integer.ValueOf(L2reviewLabelDateDateDays));
                    system.debug('L2reviewLabelsubDate: '+L2reviewLabelsubDate);
                    newrec1.put(L2reviewLabel_ApiName,L2reviewLabelsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String L3reviewLabel= 'L3_Review_Date_catalog';
        system.debug('releaseDefaultLabelMap record for L2reviewLabel days: '+releaseDefaultLabelMap.get(L2reviewLabel));
        
        String L3reviewLabel_ApiName = releaseDefaultLabelMap.get(L3reviewLabel).Source_Field__c;
        String L2_ApiName = releaseDefaultLabelMap.get(L3reviewLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(L3reviewLabel_ApiName)==null && newRecord.L2_Review_Date__c!=oldRecord.L2_Review_Date__c)
        	||(newrec1.get(L3reviewLabel_ApiName)!=null && newRecord.L2_Review_Date__c!=oldRecord.L2_Review_Date__c)){ 
            if(newrec1.get(L2_ApiName)!=null){
                if(releaseDefaultLabelMap.get(L3reviewLabel)!=null){
                    
                    Date L3reviewLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(L3reviewLabel).Destination_Field__c)); 
                    system.debug('L3reviewLabelDate: '+L3reviewLabelDate);
                    
                    Decimal L3reviewLabelDateDateDays= releaseDefaultLabelMap.get(L3reviewLabel).Calculation__c;
                    system.debug('L3reviewLabelDateDateDays: '+L3reviewLabelDateDateDays);
                    Date L3reviewLabelsubDate= L3reviewLabelDate.addDays(Integer.ValueOf(L3reviewLabelDateDateDays));
                    system.debug('L3reviewLabelsubDate: '+L3reviewLabelsubDate);
                    newrec1.put(L3reviewLabel_ApiName,L3reviewLabelsubDate);
                }
            }
            
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String FilmmakerLabel= 'Filmmaker_3rd_Party_Due_Date_catalog';
        system.debug('releaseDefaultLabelMap record for FilmmakerLabel days: '+releaseDefaultLabelMap.get(FilmmakerLabel));
        
        String FilmmakerLabel_ApiName = releaseDefaultLabelMap.get(FilmmakerLabel).Source_Field__c;
        String L3_ApiName = releaseDefaultLabelMap.get(FilmmakerLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(FilmmakerLabel_ApiName)==null && newRecord.L3_Review_Date__c!=oldRecord.L3_Review_Date__c)
        	||(newrec1.get(FilmmakerLabel_ApiName)!=null && newRecord.L3_Review_Date__c!=oldRecord.L3_Review_Date__c)){ 
            if(newrec1.get(L3_ApiName)!=null){
                if(releaseDefaultLabelMap.get(FilmmakerLabel)!=null){
                    
                    Date FilmmakerLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(FilmmakerLabel).Destination_Field__c)); 
                    system.debug('FilmmakerLabelDate: '+FilmmakerLabelDate);
                    
                    Decimal FilmmakerLabelDateDateDays= releaseDefaultLabelMap.get(FilmmakerLabel).Calculation__c;
                    system.debug('FilmmakerLabelDateDateDays: '+FilmmakerLabelDateDateDays);
                    Date filmmakersubDate= FilmmakerLabelDate.addDays(Integer.ValueOf(FilmmakerLabelDateDateDays));
                    system.debug('filmmakersubDate: '+filmmakersubDate);
                    newrec1.put(FilmmakerLabel_ApiName,filmmakersubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String clientavailsLabel= 'Client_Avails_Confirmation_catalog';
        system.debug('releaseDefaultLabelMap record for clientavailsLabel days: '+releaseDefaultLabelMap.get(clientavailsLabel));
        
        String clientavailsLabel_ApiName = releaseDefaultLabelMap.get(clientavailsLabel).Source_Field__c;
        String EST_ApiName = releaseDefaultLabelMap.get(clientavailsLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(FilmmakerLabel_ApiName)==null && newRecord.EST_Date__c!=OldRecord.EST_Date__c)
        	||(newrec1.get(FilmmakerLabel_ApiName)!=null && newRecord.EST_Date__c!=OldRecord.EST_Date__c)){ 
            if(newrec1.get(EST_ApiName)!=null){
                if(releaseDefaultLabelMap.get(clientavailsLabel)!=null){
                    
                    Date clientavailsLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(clientavailsLabel).Destination_Field__c)); 
                    system.debug('clientavailsLabelDate: '+clientavailsLabelDate);
                    
                    Decimal clientavailsLabelDateDays= releaseDefaultLabelMap.get(clientavailsLabel).Calculation__c;
                    system.debug('clientavailsLabelDateDays: '+clientavailsLabelDateDays);
                    Date clientavailssubDate= clientavailsLabelDate.addDays(Integer.ValueOf(clientavailsLabelDateDays));
                    system.debug('clientavailssubDate: '+clientavailssubDate);
                    newrec1.put(clientavailsLabel_ApiName,clientavailssubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String AnnouncedtLabel= 'Trade_Solicitation_Date_catalog';
        system.debug('releaseDefaultLabelMap record for AnnouncedtLabel days: '+releaseDefaultLabelMap.get(AnnouncedtLabel));
        
        String AnnouncedtLabel_ApiName = releaseDefaultLabelMap.get(AnnouncedtLabel).Source_Field__c;
        String stdt_ApiName = releaseDefaultLabelMap.get(AnnouncedtLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(AnnouncedtLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
        	||(newrec1.get(AnnouncedtLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){ 
            if(newrec1.get(stdt_ApiName)!=null){
                if(releaseDefaultLabelMap.get(AnnouncedtLabel)!=null){
                    
                    Date AnnouncedtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(AnnouncedtLabel).Destination_Field__c)); 
                    system.debug('AnnouncedtLabelDate: '+AnnouncedtLabelDate);
                    
                    Decimal AnnouncedtLabelDateDays= releaseDefaultLabelMap.get(AnnouncedtLabel).Calculation__c;
                    system.debug('AnnouncedtLabelDateDays: '+AnnouncedtLabelDateDays);
                    Date AnnouncedtLabelsubDate= AnnouncedtLabelDate.addDays(Integer.ValueOf(AnnouncedtLabelDateDays));
                    system.debug('AnnouncedtLabelsubDate: '+AnnouncedtLabelsubDate);
                    newrec1.put(AnnouncedtLabel_ApiName,AnnouncedtLabelsubDate);
                }
            }
        }
        
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String SellingguidelinesdtLabel= 'Selling_Guides_Due_Date_catalog';
        system.debug('releaseDefaultLabelMap record for AnnouncedtLabel days: '+releaseDefaultLabelMap.get(SellingguidelinesdtLabel));
        
        String SellingguidelinesdtLabel_ApiName = releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Source_Field__c;
        String stdt1_ApiName = releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(SellingguidelinesdtLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
        	||(newrec1.get(SellingguidelinesdtLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){ 
            if(newrec1.get(stdt1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(SellingguidelinesdtLabel)!=null){
                    
                    Date SellingguidelinesdtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Destination_Field__c)); 
                    system.debug('SellingguidelinesdtLabelDate: '+SellingguidelinesdtLabelDate);
                    
                    Decimal SellingguidelinesdtLabelDateDays= releaseDefaultLabelMap.get(SellingguidelinesdtLabel).Calculation__c;
                    system.debug('SellingguidelinesdtLabelDateDays: '+SellingguidelinesdtLabelDateDays);
                    Date SellingguidelinesdtsubDate= SellingguidelinesdtLabelDate.addMonths(Integer.ValueOf(SellingguidelinesdtLabelDateDays));
                    system.debug('SellingguidelinesdtsubDate: '+SellingguidelinesdtsubDate);
                    newrec1.put(SellingguidelinesdtLabel_ApiName,SellingguidelinesdtsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String InplantLabel= 'In_Plant_Date_catalog';
        system.debug('releaseDefaultLabelMap record for InplantLabel days: '+releaseDefaultLabelMap.get(InplantLabel));
        
        String InplantLabel_ApiName = releaseDefaultLabelMap.get(InplantLabel).Source_Field__c;
        String stdt2_ApiName = releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(InplantLabel_ApiName)==null && NewRecord.Street_Date__c != oldRecord.Street_Date__c)
        	||(newrec1.get(InplantLabel_ApiName)!=null && NewRecord.Street_Date__c != oldRecord.Street_Date__c)){ 
            if(newrec1.get(stdt2_ApiName)!=null){
                if(releaseDefaultLabelMap.get(InplantLabel)!=null){
                    
                    Date InplantLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c)); 
                    system.debug('InplantLabelDate: '+InplantLabelDate);
                    
                    Decimal InplantLabelDateDays= releaseDefaultLabelMap.get(InplantLabel).Calculation__c;
                    system.debug('InplantLabelDateDays: '+InplantLabelDateDays);
                    Date InplantLabelDtsubDate= InplantLabelDate.addDays(Integer.ValueOf(InplantLabelDateDays));
                    system.debug('InplantLabelDtsubDate: '+InplantLabelDtsubDate);
                    newrec1.put(InplantLabel_ApiName,InplantLabelDtsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        /*Premium release date = sreet date - 63
		Premiumrelease announce date now is trade email date	
		*/
        String PremiumReleaseAnnounceDate= 'Premium_Release_Announce_Date_catalog';
        
        String PremiumReleaseAnnounceDate_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Source_Field__c;
        String Street_Date_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c;
        
        if(newrec1.get(PremiumReleaseAnnounceDate_ApiName)==null || newRecord.Street_Date__c!=oldRecord.Street_Date__c){
            if(newrec1.get(Street_Date_ApiName)!=null){
                if(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate)!=null){
                    Date streetDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c)); 
                    Decimal streetNumDays= releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Calculation__c;
                    Date streetSubDate= streetDate.addDays(Integer.ValueOf(streetNumDays));
                    newrec1.put(PremiumReleaseAnnounceDate_ApiName,streetSubDate);
                }   
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String TradeassetsLabel= 'Trade_Assets_Due_to_JV_Date_catalog';
        system.debug('releaseDefaultLabelMap record for TradeassetsLabel days: '+releaseDefaultLabelMap.get(TradeassetsLabel));
        
        String TradeassetsLabel_ApiName = releaseDefaultLabelMap.get(TradeassetsLabel).Source_Field__c;
        String Announce1_ApiName = releaseDefaultLabelMap.get(TradeassetsLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(TradeassetsLabel_ApiName)==null && newRecord.Premium_Release_Announce_Date__c!=oldRecord.Premium_Release_Announce_Date__c)
        	||(newrec1.get(TradeassetsLabel_ApiName)!=null && newRecord.Premium_Release_Announce_Date__c!=oldRecord.Premium_Release_Announce_Date__c)){ 
            if(newrec1.get(Announce1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(TradeassetsLabel)!=null){
                    
                    Date TradeassetsLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeassetsLabel).Destination_Field__c)); 
                    system.debug('TradeassetsLabelDate: '+TradeassetsLabelDate);
                    
                    Decimal TradeassetsLabelDateDays= releaseDefaultLabelMap.get(TradeassetsLabel).Calculation__c;
                    system.debug('TradeassetsLabelDateDays: '+TradeassetsLabelDateDays);
                    Date TradeassetsLabelsubDate= TradeassetsLabelDate.addDays(Integer.ValueOf(TradeassetsLabelDateDays));
                    system.debug('TradeassetsLabelsubDate: '+TradeassetsLabelsubDate);
                    newrec1.put(TradeassetsLabel_ApiName,TradeassetsLabelsubDate);
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        String orderdueLabel= 'Order_Due_Date_catalog';
        system.debug('releaseDefaultLabelMap record for TradeassetsLabel days: '+releaseDefaultLabelMap.get(TradeassetsLabel));
        
        String orderdueLabel_ApiName = releaseDefaultLabelMap.get(orderdueLabel).Source_Field__c;
        String st4_ApiName = releaseDefaultLabelMap.get(orderdueLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        
        if((newrec1.get(orderdueLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
        	||(newrec1.get(orderdueLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){ 
            if(newrec1.get(st4_ApiName)!=null){
                if(releaseDefaultLabelMap.get(orderdueLabel)!=null){
                    
                    Date orderdueLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(orderdueLabel).Destination_Field__c)); 
                    system.debug('orderdueLabelDate: '+orderdueLabelDate);
                    
                    Decimal orderdueLabelDateDays= releaseDefaultLabelMap.get(orderdueLabel).Calculation__c;
                    system.debug('orderdueLabelDateDays: '+orderdueLabelDateDays);
                    Date orderdueLabelsubDate= orderdueLabelDate.addDays(Integer.ValueOf(orderdueLabelDateDays));
                    system.debug('orderdueLabelsubDate: '+orderdueLabelsubDate);
                    newrec1.put(orderdueLabel_ApiName,orderdueLabelsubDate);
                }
            }
        }
        
        
        
    }
    
}