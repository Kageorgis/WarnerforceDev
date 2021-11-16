/*========================================================================================================
* @author sai santhan
* @date 10/10/2020
* @description: Date Defaulting logic for thearical record type
==========================================================================================================*/
public class RF_ReleaseHelperTheatricalsetDate {
    //Date defaulting field calculations on insert    
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
        
        
        Release__c newRel = (Release__c) newrec1;
        System.debug('##@@##' + newRel.PEST_Date__c);
        
        String WWBOXofcLabel= 'WW_Box_Office';
        system.debug('releaseDefaultLabelMap record for WW_Box_Office days: '+releaseDefaultLabelMap.get(WWBOXofcLabel));
        
        String WWBOXofcLabel_ApiName = releaseDefaultLabelMap.get(WWBOXofcLabel).Source_Field__c;
        String DOMBOXOFC_ApiName = releaseDefaultLabelMap.get(WWBOXofcLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 ww Date Value: '+newrec1.get(WWBOXofcLabel_ApiName));
        
        String EarlypreorderLabel= 'Early_pre_order_date';
        system.debug('releaseDefaultLabelMap record for EarlypreorderLabel days: '+releaseDefaultLabelMap.get(EarlypreorderLabel));
        
        String EarlypreorderLabel_ApiName = releaseDefaultLabelMap.get(EarlypreorderLabel).Source_Field__c;
        String StreetDateearly_ApiName = releaseDefaultLabelMap.get(EarlypreorderLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 VOD Date Value: '+newrec1.get(StreetDateearly_ApiName));
        if(newrec1.get(EarlypreorderLabel_ApiName)==null){
            if(newrec1.get(StreetDateearly_ApiName)!=null){
                if(releaseDefaultLabelMap.get(EarlypreorderLabel)!=null){
                    
                    Date StreetDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(EarlypreorderLabel).Destination_Field__c)); 
                    system.debug('StreetDate: '+StreetDate);
                    
                    Decimal StreetNumDays= releaseDefaultLabelMap.get(EarlypreorderLabel).Calculation__c;
                    system.debug('StreetNumDays: '+StreetNumDays);
                    Date StreetsubDate= StreetDate.addDays(Integer.ValueOf(StreetNumDays));
                    system.debug('StreetsubDate: '+StreetsubDate);
                    newrec1.put(EarlypreorderLabel_ApiName,StreetsubDate);
                }   
            }
        }
        
        newRel = (Release__c) newrec1;
        System.debug('##@@## 2' + newRel.PEST_Date__c);
        
        String ApproveDraftLabel= 'Approve_Catalog_Drafting_Titles';
        system.debug('releaseDefaultLabelMap record for Approve days: '+releaseDefaultLabelMap.get(ApproveDraftLabel));
        
        String ApproveDraftDays_ApiName = releaseDefaultLabelMap.get(ApproveDraftLabel).Source_Field__c;
        String FirstTheatrical_ApiName = releaseDefaultLabelMap.get(ApproveDraftLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 FirstTheatrical Date Value: '+newrec1.get(FirstTheatrical_ApiName));
        //Filmmaker_3rd_Party_Due_Date__c
        String reviewDateLabel= 'L3_Review_Date';
        String thirdPartyDueDateLabel= 'Filmmaker_3rd_Party_Due_Date';
        String reviewDateLabel1= 'L1_Review_Date';
        String reviewDateLabel2= 'L2_Review_Date';
        String DomININfoLabel= 'Domestic_Initial_Info_To_Mkts_Request';
        String DraftingEndLabel= 'Drafting_End_Date';
        String DraftingStartLabel= 'Drafting_Start_Date';
        String MarketingAlertLabel= 'Marketing_Alert_Request_Input_To_Plan';
        String MarketingGuidelinesLabel= 'Marketing_Guidelines_Guardrails';
        String WWCreativekickoffLabel= 'WW_Creative_Kick_Off';
        String WWCreativekickoffLabel1= 'WW_Creative_Kick_Off1';
        String StreetdtLabel= 'Street_Date';
        String VODdateLabel= 'Vod_date';
        String PVODdateLabel= 'PVOD_Date';
        String ESTdateLabel= 'EST_Date';
        String PESTdateLabel= 'PEST_Date';
        //String ORDERDUEDTLabel= 'Order_Due_Date';
        
        String Streetdate_ApiName = releaseDefaultLabelMap.get(StreetdtLabel).Source_Field__c;
        //String ORDERDUEDT_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Source_Field__c;
        String PESTDatee_ApiName = releaseDefaultLabelMap.get(PESTdateLabel).Source_Field__c;
        String ESTDatee_ApiName = releaseDefaultLabelMap.get(ESTdateLabel).Source_Field__c;
        String l3reviewDate_ApiName = releaseDefaultLabelMap.get(reviewDateLabel).Source_Field__c;
        String thirdPartyDueDate_ApiName = releaseDefaultLabelMap.get(thirdPartyDueDateLabel).Source_Field__c;
        String l2reviewDate_ApiName = releaseDefaultLabelMap.get(reviewDateLabel2).Source_Field__c;
        String l1reviewDate_ApiName = releaseDefaultLabelMap.get(reviewDateLabel1).Source_Field__c;
        String DomInitInfo_ApiName = releaseDefaultLabelMap.get(DomININfoLabel).Source_Field__c;
        String DraftingEndLabel_ApiName = releaseDefaultLabelMap.get(DraftingEndLabel).Source_Field__c;
        String DraftingEStartLabel_ApiName = releaseDefaultLabelMap.get(DraftingStartLabel).Source_Field__c;
        String MarketingAlertLabel_ApiName = releaseDefaultLabelMap.get(MarketingAlertLabel).Source_Field__c;
        String MarketingGuidelines_ApiName = releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Source_Field__c;
        //String WWCreativekickoff_ApiName1 = releaseDefaultLabelMap.get(WWCreativekickoffLabel).Source_Field__c;
        String WWCreativekickoff_ApiName = releaseDefaultLabelMap.get(WWCreativekickoffLabel).Source_Field__c;
        String VODdate_ApiName = releaseDefaultLabelMap.get(VODdateLabel).Source_Field__c;
        String PVODdate_ApiName = releaseDefaultLabelMap.get(PVODdateLabel).Source_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 L3_Review_Date Date Value: '+newrec1.get(ApproveDraftDays_ApiName));
        
        if(newrec1.get(FirstTheatrical_ApiName)!=null){
            if(releaseDefaultLabelMap.get(ApproveDraftLabel)!=null){
                
                Date FirstTheatricalDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ApproveDraftLabel).Destination_Field__c)); 
                system.debug('FirstTheatricalDate: '+FirstTheatricalDate);
                Decimal FirstTheatricalNumDays= releaseDefaultLabelMap.get(ApproveDraftLabel).Calculation__c;
                system.debug('FirstTheatricalNumDays: '+FirstTheatricalNumDays);
                Date FirstSubstractedDate= FirstTheatricalDate.addDays(Integer.ValueOf(FirstTheatricalNumDays));
                system.debug('FirstSubstractedDate: '+FirstSubstractedDate);
                newrec1.put(ApproveDraftDays_ApiName,FirstSubstractedDate);
            }
            if(newrec1.get(l3reviewDate_ApiName)==null){  
                if(releaseDefaultLabelMap.get(reviewDateLabel)!=null){
                    
                    Date FirstTheatricalDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(reviewDateLabel).Destination_Field__c)); 
                    system.debug('FirstTheatricalDate: '+FirstTheatricalDate);
                    Decimal l3ReviewDateNumDays= releaseDefaultLabelMap.get(reviewDateLabel).Calculation__c;
                    system.debug('l3ReviewDateNumDays: '+l3ReviewDateNumDays);
                    Date l3ReviewDate= FirstTheatricalDate.addDays(Integer.ValueOf(l3ReviewDateNumDays));
                    system.debug('l3ReviewDate: '+l3ReviewDate);
                    newrec1.put(l3reviewDate_ApiName,l3ReviewDate);
                    
                    
                    if(newrec1.get(thirdPartyDueDate_ApiName)==null){  
                        if(releaseDefaultLabelMap.get(thirdPartyDueDateLabel)!=null){
                            
                            Decimal thirdPartyDueNumDays= releaseDefaultLabelMap.get(thirdPartyDueDateLabel).Calculation__c;
                            system.debug('thirdPartyDueNumDays: '+thirdPartyDueNumDays);
                            Date thirdPartyDueDate= l3ReviewDate.addDays(Integer.ValueOf(thirdPartyDueNumDays));
                            system.debug('thirdPartyDueDate: '+thirdPartyDueDate);
                            newrec1.put(thirdPartyDueDate_ApiName,thirdPartyDueDate);
                        }
                    }
                }
                if(newrec1.get(l2reviewDate_ApiName)==null){ 
                    if(releaseDefaultLabelMap.get(reviewDateLabel2)!=null){
                        
                        Date FirstTheatricalDate2 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(reviewDateLabel2).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate2: '+FirstTheatricalDate2);
                        Decimal l2ReviewDateNumDays= releaseDefaultLabelMap.get(reviewDateLabel2).Calculation__c;
                        system.debug('l2ReviewDateNumDays: '+l2ReviewDateNumDays);
                        Date l2ReviewDate= FirstTheatricalDate2.addDays(Integer.ValueOf(l2ReviewDateNumDays));
                        system.debug('l2ReviewDate: '+l2ReviewDate);
                        newrec1.put(l2reviewDate_ApiName,l2ReviewDate);
                    }
                }
                
                if(newrec1.get(Streetdate_ApiName)==null){ 
                    if(releaseDefaultLabelMap.get(StreetdtLabel)!=null){
                        
                        Date FirstTheatricalDateS = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(StreetdtLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDateS: '+FirstTheatricalDateS);
                        Decimal StreetdtDays= releaseDefaultLabelMap.get(StreetdtLabel).Calculation__c;
                        system.debug('StreetdtDays: '+StreetdtDays);
                        Date StreetdtDaysDate= FirstTheatricalDateS.addDays(Integer.ValueOf(StreetdtDays));
                        system.debug('StreetdtDaysDate: '+StreetdtDaysDate);
                        newrec1.put(Streetdate_ApiName,StreetdtDaysDate);
                    }
                }
                
                if(newrec1.get(ESTDatee_ApiName)==null){ 
                    if(releaseDefaultLabelMap.get(ESTdateLabel)!=null){
                        
                        Date FirstTheatricalDate0 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ESTdateLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate0: '+FirstTheatricalDate0);
                        Decimal ESTdateLabelNumDays= releaseDefaultLabelMap.get(ESTdateLabel).Calculation__c;
                        system.debug('ESTdateLabelNumDays: '+ESTdateLabelNumDays);
                        Date ESTdateLabelDate= FirstTheatricalDate0.addDays(Integer.ValueOf(ESTdateLabelNumDays));
                        system.debug('ESTdateLabelDate: '+ESTdateLabelDate);
                        newrec1.put(ESTDatee_ApiName,ESTdateLabelDate);
                    }
                }
                if(newrec1.get(PESTDatee_ApiName)==null){ 
                    if(releaseDefaultLabelMap.get(PESTdateLabel)!=null && newrec1.get('country__c')!=null){
                        
                        Id conId = (Id) newrec1.get('country__c');
                         system.debug('conId: '+conId);
                        String countryRelease = [SELECT Name FROM Country__c where id =: conId].Name;
                        
                        Date FirstTheatricalDate00 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PESTdateLabel).Destination_Field__c)); 
                        Date PESTdateLabelDate;
                        
                        system.debug('FirstTheatricalDate00: '+FirstTheatricalDate00);
                        
                        if(countryRelease == 'USA'){
                            PESTdateLabelDate= FirstTheatricalDate00.addDays(49);
                        }
                        
                        else if(countryRelease == 'Canada'){
                            PESTdateLabelDate= FirstTheatricalDate00;
                        }
                        
                        else{
                            Decimal PESTdateLabelNumDays= releaseDefaultLabelMap.get(PESTdateLabel).Calculation__c;
                            system.debug('PESTdateLabelNumDays: '+PESTdateLabelNumDays);
                            PESTdateLabelDate = FirstTheatricalDate00.addDays(Integer.ValueOf(PESTdateLabelNumDays));
                            system.debug('PESTdateLabelDate: '+PESTdateLabelDate);
                        }
                        newrec1.put(PESTDatee_ApiName,PESTdateLabelDate);
                    }
                }
                newRel = (Release__c) newrec1;
                System.debug('##@@## 3' + newRel.PEST_Date__c + newRel.Country__c + newrec1.get('Country_Name__c'));
                if(newrec1.get(VODdate_ApiName)==null){    
                    if(releaseDefaultLabelMap.get(VODdateLabel)!=null){
                        
                        Date FirstTheatricalDat = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(VODdateLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDat: '+FirstTheatricalDat);
                        Decimal VODNumDays= releaseDefaultLabelMap.get(VODdateLabel).Calculation__c;
                        system.debug('VODNumDays: '+VODNumDays);
                        Date VODDate= FirstTheatricalDat.addDays(Integer.ValueOf(VODNumDays));
                        system.debug('VODDate: '+VODDate);
                        newrec1.put(VODdate_ApiName,VODDate);
                        
                    }
                }
                if(newrec1.get(PVODdate_ApiName)==null){    
                    if(releaseDefaultLabelMap.get(PVODdateLabel)!=null && newrec1.get('country__c')!=null){
                        Id conId = (Id) newrec1.get('Country__c');
                        if(conId != NULL){
                            String countryRelease = [SELECT Name FROM Country__c where id =: conId].Name;
                        
                            Date FirstTheatricalDat = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PVODdateLabel).Destination_Field__c)); 
                            Date PVODDate;
                            
                            system.debug('FirstTheatricalDat: '+FirstTheatricalDat);
                            
                            if(countryRelease == 'USA'){
                                PVODDate = FirstTheatricalDat.addDays(49);
                            }
                            
                            else if(countryRelease == 'Canada'){
                                PVODDate = FirstTheatricalDat;
                            }
                            
                            else{
                                Decimal PVODNumDays= releaseDefaultLabelMap.get(PVODdateLabel).Calculation__c;
                                system.debug('PVODNumDays: '+PVODNumDays);
                                PVODDate= FirstTheatricalDat.addDays(Integer.ValueOf(PVODNumDays));
                                system.debug('PVODDate: '+PVODDate);
                            }
                            
                            newrec1.put(PVODdate_ApiName,PVODDate);
                        }
                        
                        
                    }
                }
                if(newrec1.get(Streetdate_ApiName)==null){    
                    if(releaseDefaultLabelMap.get(StreetdtLabel)!=null){
                        
                        Date FirstTheatricalDat12 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(StreetdtLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDat: '+FirstTheatricalDat12);
                        Decimal stDays= releaseDefaultLabelMap.get(StreetdtLabel).Calculation__c;
                        system.debug('stDays: '+stDays);
                        Date stDate= FirstTheatricalDat12.addDays(Integer.ValueOf(stDays));
                        system.debug('stDate: '+stDate);
                        newrec1.put(Streetdate_ApiName,stDate);
                        
                    }
                }
                
                release__C recevivedrecord = (release__C)newrec1;
                string recordtype = recevivedrecord.Record_Type_Name__c;
                system.debug('received record type====>'+recordtype);
                if(newrec1.get(WWCreativekickoff_ApiName)==null){  
                    if(releaseDefaultLabelMap.get(WWCreativekickoffLabel)!=null){
                        system.debug('this code is for Theatrical and Catalog record type');                                
                        Date FirstTheatricalDate8 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(WWCreativekickoffLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate8: '+FirstTheatricalDate8);
                        Decimal WWkickoffNumDays= releaseDefaultLabelMap.get(WWCreativekickoffLabel).Calculation__c;
                        system.debug('WWkickoffNumDays: '+WWkickoffNumDays);
                        Date WWkickoffDate= FirstTheatricalDate8.addDays(Integer.ValueOf(WWkickoffNumDays));
                        system.debug('WWkickoffDate: '+WWkickoffDate);
                        newrec1.put(WWCreativekickoff_ApiName,WWkickoffDate);
                        
                        
                    }
                }
                
                if(newrec1.get(DomInitInfo_ApiName)==null){ 
                    if(releaseDefaultLabelMap.get(DomININfoLabel)!=null){
                        
                        Date FirstTheatricalDate3 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DomININfoLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate3: '+FirstTheatricalDate3);
                        Decimal DomReviewDateNumDays= releaseDefaultLabelMap.get(DomININfoLabel).Calculation__c;
                        system.debug('DomReviewDateNumDays: '+DomReviewDateNumDays);
                        Date DomReviewDate= FirstTheatricalDate3.addDays(Integer.ValueOf(DomReviewDateNumDays));
                        system.debug('DomReviewDate: '+DomReviewDate);
                        newrec1.put(DomInitInfo_ApiName,DomReviewDate);
                    }
                }     
                if(newrec1.get(DraftingEndLabel_ApiName)==null){
                    if(releaseDefaultLabelMap.get(DraftingEndLabel)!=null){
                        
                        Date FirstTheatricalDate4 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DraftingEndLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate4: '+FirstTheatricalDate4);
                        Decimal DraftingEndlabelNumDays= releaseDefaultLabelMap.get(DraftingEndLabel).Calculation__c;
                        system.debug('DraftingEndlabelNumDays: '+DraftingEndlabelNumDays);
                        Date DraftingDate= FirstTheatricalDate4.addDays(Integer.ValueOf(DraftingEndlabelNumDays));
                        system.debug('DraftingDate: '+DraftingDate);
                        newrec1.put(DraftingEndLabel_ApiName,DraftingDate);
                    }
                }
                
                if(newrec1.get(DraftingEStartLabel_ApiName)==null){
                    if(releaseDefaultLabelMap.get(DraftingStartLabel)!=null){
                        
                        Date FirstTheatricalDate5 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DraftingStartLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate5: '+FirstTheatricalDate5);
                        Decimal DraftingStartlabelNumDays= releaseDefaultLabelMap.get(DraftingStartLabel).Calculation__c;
                        system.debug('DraftingStartlabelNumDays: '+DraftingStartlabelNumDays);
                        Date DraftingStartDate= FirstTheatricalDate5.addDays(Integer.ValueOf(DraftingStartlabelNumDays));
                        system.debug('DraftingStartDate: '+DraftingStartDate);
                        newrec1.put(DraftingEStartLabel_ApiName,DraftingStartDate);
                    }
                }
                if(newrec1.get(MarketingAlertLabel_ApiName)==null){
                    if(releaseDefaultLabelMap.get(MarketingAlertLabel)!=null){
                        
                        Date FirstTheatricalDate6 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingAlertLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate6: '+FirstTheatricalDate6);
                        Decimal MarketingLabelNumDays= releaseDefaultLabelMap.get(MarketingAlertLabel).Calculation__c;
                        system.debug('MarketingLabelNumDays: '+MarketingLabelNumDays);
                        Date MarketingLabelDate= FirstTheatricalDate6.addDays(Integer.ValueOf(MarketingLabelNumDays));
                        system.debug('MarketingLabelDate: '+MarketingLabelDate);
                        newrec1.put(MarketingAlertLabel_ApiName,MarketingLabelDate);
                    }
                }
                if(newrec1.get(MarketingGuidelines_ApiName)==null){
                    if(releaseDefaultLabelMap.get(MarketingGuidelinesLabel)!=null){
                        
                        Date FirstTheatricalDate7 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate7: '+FirstTheatricalDate7);
                        Decimal MarketingGuidelinesNumDays= releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Calculation__c;
                        system.debug('MarketingGuidelinesNumDays: '+MarketingGuidelinesNumDays);
                        Date MarketingGuidelinesDate= FirstTheatricalDate7.addDays(Integer.ValueOf(MarketingGuidelinesNumDays));
                        system.debug('MarketingGuidelinesDate: '+MarketingGuidelinesDate);
                        newrec1.put(MarketingGuidelines_ApiName,MarketingGuidelinesDate);
                    }
                }
                if(newrec1.get(l1reviewDate_ApiName)==null){
                    if(releaseDefaultLabelMap.get(reviewDateLabel1)!=null){
                        
                        Date FirstTheatricalDate1 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(reviewDateLabel1).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate1: '+FirstTheatricalDate1);
                        Decimal l1ReviewDateNumDays= releaseDefaultLabelMap.get(reviewDateLabel1).Calculation__c;
                        system.debug('l1ReviewDateNumDays: '+l1ReviewDateNumDays);
                        Date l1ReviewDate= FirstTheatricalDate1.addDays(Integer.ValueOf(l1ReviewDateNumDays));
                        system.debug('l1ReviewDate: '+l1ReviewDate);
                        newrec1.put(l1reviewDate_ApiName,l1ReviewDate);
                    }
                }
                
            }
            
            
        }
        else{
            newRel = (Release__c) newrec1;
            System.debug('##@@## 5' + newRel.PEST_Date__c);
            if(newrec1.get(thirdPartyDueDate_ApiName)==null){  
                Release__c rel = (Release__c)newrec1;
                Date l3ReviewDate = rel.L3_Review_Date__c;
                if(l3ReviewDate!=null){
                    if(releaseDefaultLabelMap.get(thirdPartyDueDateLabel)!=null){
                        Decimal thirdPartyDueNumDays= releaseDefaultLabelMap.get(thirdPartyDueDateLabel).Calculation__c;
                        system.debug('thirdPartyDueNumDays: '+thirdPartyDueNumDays);
                        Date thirdPartyDueDate= l3ReviewDate.addDays(Integer.ValueOf(thirdPartyDueNumDays));
                        system.debug('thirdPartyDueDate: '+thirdPartyDueDate);
                        newrec1.put(thirdPartyDueDate_ApiName,thirdPartyDueDate);
                    }
                }
            }
            
            // newrec1.put(ApproveDraftDays_ApiName,null);
            // newrec1.put(VODdate_ApiName,null);
            // newrec1.put(l2reviewDate_ApiName,null);
            // newrec1.put(l1reviewDate_ApiName,null);
            // newrec1.put(MarketingGuidelines_ApiName,null);
            // newrec1.put(MarketingAlertLabel_ApiName,null);
            // newrec1.put(DraftingEStartLabel_ApiName,null);
            // newrec1.put(DraftingEndLabel_ApiName,null);
            // newrec1.put(DomInitInfo_ApiName,null);
            // newrec1.put(ESTDatee_ApiName,null);
        }
        
        
        String ClientAvailsConfirmationLabel= 'Client_Avails_Confirmation';
        system.debug('releaseDefaultLabelMap record for ClientAvailsConfirmationLabel days: '+releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel));
        
        String ClientAvailsconfirmation_ApiName = releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Source_Field__c;
        String EstDate_ApiName = releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 VOD Date Value: '+newrec1.get(EstDate_ApiName));
        if(newrec1.get(ClientAvailsconfirmation_ApiName)==null){
            if(newrec1.get(EstDate_ApiName)!=null){
                if(releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel)!=null){
                    
                    Date EstDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Destination_Field__c)); 
                    system.debug('EstDate: '+EstDate);
                    
                    Decimal ESTNumDays= releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Calculation__c;
                    system.debug('ESTNumDays: '+ESTNumDays);
                    Date ESTsubDate= EstDate.addDays(Integer.ValueOf(ESTNumDays));
                    system.debug('ESTsubDate: '+ESTsubDate);
                    newrec1.put(ClientAvailsconfirmation_ApiName,ESTsubDate);
                }   
            }
        }
        String PhysicalrentalLabel= 'Physical_Rental_Date';
        system.debug('releaseDefaultLabelMap record for PhysicalrentalLabel days: '+releaseDefaultLabelMap.get(PhysicalrentalLabel));
        
        String PhysicalrentalLabel_ApiName = releaseDefaultLabelMap.get(PhysicalrentalLabel).Source_Field__c;
        String StreetDT1_ApiName = releaseDefaultLabelMap.get(PhysicalrentalLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(PhysicalrentalLabel_ApiName));
        if(newrec1.get(PhysicalrentalLabel_ApiName)==null){
            if(newrec1.get(StreetDT1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(PhysicalrentalLabel)!=null){
                    
                    Date PhysicalrentalLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PhysicalrentalLabel).Destination_Field__c)); 
                    system.debug('PhysicalrentalLabelDate: '+PhysicalrentalLabelDate);
                    
                    Decimal PhysicalNumDays= releaseDefaultLabelMap.get(PhysicalrentalLabel).Calculation__c;
                    system.debug('PhysicalNumDays: '+PhysicalNumDays);
                    Date physicalsubDate= PhysicalrentalLabelDate.addDays(Integer.ValueOf(PhysicalNumDays));
                    system.debug('physicalsubDate: '+physicalsubDate);
                    newrec1.put(PhysicalrentalLabel_ApiName,physicalsubDate);
                    
                }   
            }
        }
        
        /*Announce Date = PVOD - 10*/
        String TradeSolicitationLabel= 'Trade_Solicitation_Date';
        system.debug('releaseDefaultLabelMap record for TradeSolicitation days: '+releaseDefaultLabelMap.get(TradeSolicitationLabel));
        
        String TradeSolicitation_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Source_Field__c;
        String PVODDT_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(TradeSolicitation_ApiName));
        if(newrec1.get(TradeSolicitation_ApiName)==null ){
            if(newrec1.get(PVODDT_ApiName)!=null){
                if(releaseDefaultLabelMap.get(TradeSolicitationLabel)!=null){
                    
                    Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c)); 
                    system.debug('TradesolicitationDate: '+TradesolicitationDate);
                    
                    Decimal TradeNumDays= releaseDefaultLabelMap.get(TradeSolicitationLabel).Calculation__c;
                    system.debug('TradeNumDays: '+TradeNumDays);
                    Date TradesubDate= TradesolicitationDate.addDays(Integer.ValueOf(TradeNumDays));
                    system.debug('TradesubDate: '+TradesubDate);
                    newrec1.put(TradeSolicitation_ApiName,TradesubDate);
                }
            }
            else{
                if(newrec1.get('Street_Date__c')!=null){
                    Date stDate = Date.valueOf(newrec1.get('Street_Date__c'));
                    newrec1.put(TradeSolicitation_ApiName, stDate.addDays(-56));
                }
            }
        }
        String ORDERDUEDTLabel= 'Order_Due_Date';
        system.debug('releaseDefaultLabelMap record for TradeSolicitation days: '+releaseDefaultLabelMap.get(TradeSolicitationLabel));
        
        String ORDERDUEDTLabel_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Source_Field__c;
        String StreetDTt_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 ORDERDUEDTLabel Date Value: '+newrec1.get(ORDERDUEDTLabel_ApiName));
        if(newrec1.get(ORDERDUEDTLabel_ApiName)==null){
            if(newrec1.get(StreetDTt_ApiName)!=null){
                if(releaseDefaultLabelMap.get(ORDERDUEDTLabel)!=null){
                    
                    Date ORDERDUEDTLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c)); 
                    system.debug('ORDERDUEDTLabelDate: '+ORDERDUEDTLabelDate);
                    
                    Decimal OrderNumDays= releaseDefaultLabelMap.get(ORDERDUEDTLabel).Calculation__c;
                    system.debug('OrderNumDays: '+OrderNumDays);
                    Date OrdersubDate= ORDERDUEDTLabelDate.addDays(Integer.ValueOf(OrderNumDays));
                    system.debug('OrdersubDate: '+OrdersubDate);
                    newrec1.put(ORDERDUEDTLabel_ApiName,OrdersubDate);
                }
            }   
        }
        
        String SellingguidesduedtLabel= 'Selling_Guides_Due_Date';
        system.debug('releaseDefaultLabelMap record for SellingguidesduedtLabel days: '+releaseDefaultLabelMap.get(SellingguidesduedtLabel));
        
        String SellingguidesduedtLabel_APIname = releaseDefaultLabelMap.get(SellingguidesduedtLabel).Source_Field__c;
        String Stdt0_ApiName = releaseDefaultLabelMap.get(SellingguidesduedtLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 Stdt0_ApiName Date Value: '+newrec1.get(Stdt0_ApiName));
        if(newrec1.get(SellingguidesduedtLabel_APIname)==null){
            if(newrec1.get(Stdt0_ApiName)!=null){
                if(releaseDefaultLabelMap.get(SellingguidesduedtLabel)!=null){
                    
                    Date SellingguidesduedtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(SellingguidesduedtLabel).Destination_Field__c)); 
                    system.debug('SellingguidesduedtLabelDate: '+SellingguidesduedtLabelDate);
                    
                    Decimal SellingguidesduedtDays= releaseDefaultLabelMap.get(SellingguidesduedtLabel).Calculation__c;
                    system.debug('SellingguidesduedtDays: '+SellingguidesduedtDays);
                    Date SellingguidesubDate= SellingguidesduedtLabelDate.addMonths(Integer.ValueOf(SellingguidesduedtDays));
                    system.debug('SellingguidesubDate: '+SellingguidesubDate);
                    newrec1.put(SellingguidesduedtLabel_APIname,SellingguidesubDate);
                }
            }   
        }
        String ORDERDUEDTLabell= 'Order_Due_Date';
        String ORDERDUEDTLabell_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabell).Source_Field__c;
        String StreetDTt1_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabell).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 ORDERDUEDTLabel Date Value: '+newrec1.get(ORDERDUEDTLabell_ApiName));
        if(newrec1.get(ORDERDUEDTLabell_ApiName)==null){
            if(newrec1.get(StreetDTt1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(ORDERDUEDTLabell)!=null){
                    
                    Date ORDERDUEDTLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c)); 
                    system.debug('ORDERDUEDTLabelDate: '+ORDERDUEDTLabelDate);
                    
                    Decimal OrderNumDays= releaseDefaultLabelMap.get(ORDERDUEDTLabel).Calculation__c;
                    system.debug('OrderNumDays: '+OrderNumDays);
                    Date OrdersubDate= ORDERDUEDTLabelDate.addDays(Integer.ValueOf(OrderNumDays));
                    system.debug('OrdersubDate: '+OrdersubDate);
                    newrec1.put(ORDERDUEDTLabell_ApiName,OrdersubDate);
                }
            }   
        }
        /*String TradeassetdueJVLabel= 'Trade_Assets_Due_to_JV_Date';
system.debug('releaseDefaultLabelMap record for TradeassetdueJVLabel days: '+releaseDefaultLabelMap.get(TradeassetdueJVLabel));

String TradeassetdueJVLabel_ApiName = releaseDefaultLabelMap.get(TradeassetdueJVLabel).Source_Field__c;
String Tradesolicitation1_ApiName = releaseDefaultLabelMap.get(TradeassetdueJVLabel).Destination_Field__c;

system.debug('newrec1 Value: '+newrec1);
system.debug('newrec1 Tradesolicitation1_ApiName Value: '+newrec1.get(Tradesolicitation1_ApiName));
if(newrec1.get(TradeassetdueJVLabel_ApiName)==null){
if(newrec1.get(Tradesolicitation1_ApiName)!=null){
if(releaseDefaultLabelMap.get(TradeassetdueJVLabel)!=null){

Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeassetdueJVLabel).Destination_Field__c)); 
system.debug('TradesolicitationDate: '+TradesolicitationDate);

Decimal SolNumDays= releaseDefaultLabelMap.get(TradeassetdueJVLabel).Calculation__c;
system.debug('SolNumDays: '+SolNumDays);
Date SolsubDate= TradesolicitationDate.addDays(Integer.ValueOf(SolNumDays));
system.debug('SolsubDate: '+SolsubDate);
newrec1.put(TradeassetdueJVLabel_ApiName,SolsubDate);
}   
}
}*/
        
        
        String InplantLabel= 'In_plant_date';
        system.debug('releaseDefaultLabelMap record for InplantLabel days: '+releaseDefaultLabelMap.get(InplantLabel));
        
        String InplantLabel_ApiName = releaseDefaultLabelMap.get(InplantLabel).Source_Field__c;
        String StreetDateearly1_ApiName = releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 streetDate Value: '+newrec1.get(StreetDateearly1_ApiName));
        if(newrec1.get(InplantLabel_ApiName)==null){
            if(newrec1.get(StreetDateearly1_ApiName)!=null){
                if(releaseDefaultLabelMap.get(InplantLabel)!=null){
                    
                    Date StreetDate1 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c)); 
                    system.debug('StreetDate1: '+StreetDate1);
                    
                    Decimal StreetNumDays1= releaseDefaultLabelMap.get(InplantLabel).Calculation__c;
                    system.debug('StreetNumDays1: '+StreetNumDays1);
                    Date StreetsubDate1= StreetDate1.addDays(Integer.ValueOf(StreetNumDays1));
                    system.debug('StreetsubDate1: '+StreetsubDate1);
                    newrec1.put(InplantLabel_ApiName,StreetsubDate1);
                }   
            }
        }
        
        String suppressionLabel= 'Suppression_Lift_Datee';
        system.debug('releaseDefaultLabelMap record for Suppression_Lift_Datee days: '+releaseDefaultLabelMap.get(suppressionLabel));
        
        String suppLabel_ApiName = releaseDefaultLabelMap.get(suppressionLabel).Source_Field__c;
        String Estlab_ApiName = releaseDefaultLabelMap.get(suppressionLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 Estlab_ApiName Date Value: '+newrec1.get(Estlab_ApiName));
        if(newrec1.get(suppLabel_ApiName)==null){
            if(newrec1.get(Estlab_ApiName)!=null){
                if(releaseDefaultLabelMap.get(suppressionLabel)!=null){
                    
                    Date ESTDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(suppressionLabel).Destination_Field__c)); 
                    system.debug('suppressionLabel: '+suppressionLabel);
                    
                    Decimal ESTNumDays= releaseDefaultLabelMap.get(suppressionLabel).Calculation__c;
                    system.debug('ESTNumDays: '+ESTNumDays);
                    Date ESTsubDate= ESTDate.addDays(Integer.ValueOf(ESTNumDays));
                    system.debug('ESTsubDate: '+ESTsubDate);
                    newrec1.put(suppLabel_ApiName,ESTsubDate);
                }   
            }
        }
        
        /*Premium release date = sreet date - 63*/
        String PremiumReleaseAnnounceDate= 'Premium_Release_Announce_Date';
        //system.debug('releaseDefaultLabelMap record for Suppression_Lift_Datee days: '+releaseDefaultLabelMap.get(suppressionLabel));
        
        String PremiumReleaseAnnounceDate_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Source_Field__c;
        String Street_Date_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 Estlab_ApiName Date Value: '+newrec1.get(Estlab_ApiName));
        if(newrec1.get(PremiumReleaseAnnounceDate_ApiName)==null){
            if(newrec1.get(Street_Date_ApiName)!=null){
                if(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate)!=null){
                    
                    Date streetDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c)); 
                    //system.debug('suppressionLabel: '+suppressionLabel);
                    
                    Decimal streetNumDays= releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Calculation__c;
                    //system.debug('ESTNumDays: '+ESTNumDays);
                    Date streetSubDate= streetDate.addDays(Integer.ValueOf(streetNumDays));
                    //system.debug('ESTsubDate: '+ESTsubDate);
                    newrec1.put(PremiumReleaseAnnounceDate_ApiName,streetSubDate);
                }   
            }
        }
        
        /*trade asset due to JV date = premium release date - 10*/
        String tradeAssetDueToJVDate= 'Trade_Assets_Due_to_JV_Date';
        //system.debug('releaseDefaultLabelMap record for Suppression_Lift_Datee days: '+releaseDefaultLabelMap.get(suppressionLabel));
        
        String tradeAssetDueToJVDate_APIName = releaseDefaultLabelMap.get(tradeAssetDueToJVDate).Source_Field__c;
        String PremiumReleaseAnnounceDate_API = releaseDefaultLabelMap.get(tradeAssetDueToJVDate).Destination_Field__c;
        
        //system.debug('newrec1 Value: '+newrec1);
        //system.debug('newrec1 Estlab_ApiName Date Value: '+newrec1.get(Estlab_ApiName));
        if(newrec1.get(tradeAssetDueToJVDate_APIName)==null){
            if(newrec1.get(PremiumReleaseAnnounceDate_API)!=null){
                if(releaseDefaultLabelMap.get(tradeAssetDueToJVDate)!=null){
                    
                    Date premRelDate = Date.ValueOf(newrec1.get(PremiumReleaseAnnounceDate_API)); 
                    //system.debug('suppressionLabel: '+suppressionLabel);
                    
                    Decimal numDays= releaseDefaultLabelMap.get(tradeAssetDueToJVDate).Calculation__c;
                    //system.debug('ESTNumDays: '+ESTNumDays);
                    Date subDate= premRelDate.addDays(Integer.ValueOf(numDays));
                    //system.debug('ESTsubDate: '+ESTsubDate);
                    newrec1.put(tradeAssetDueToJVDate_APIName,subDate);
                }   
            }
        }
        
        newRel = (Release__c) newrec1;
        System.debug('##@@## 6' + newRel.PEST_Date__c);
        
        return newrec1;
        
    }
    
    //Date Defaulting fields logic on update
    /*ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
    User should be able to clear off dependent fields like PVOD date, PEST and able to save record successfully.*/
    public static void setdateonupdate(SObject newrec1,Map<Id, SObject> oldReleaseMap,Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap,Map< String, String > destinationfieldMap,Map< String, Decimal > releaseDateDefaultsMap,Map< String, String > sourcefieldMap,Map< String, String > calculatedfieldMap,Map< String, String > calculatedfield_operation_Map){
        Id theatricalID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();        
        system.debug('newrec1 Value: '+newrec1);
        SObject oldrec = (RELEASE__c)oldReleaseMap.get(newrec1.id);
        Release__C newRecord = (Release__C) newrec1;
        Release__C oldRecord = (Release__C)oldReleaseMap.get(newRecord.id);
        
        System.debug('##INSIDE SETDATEONUPDATE## NEWRECORD:' + newRecord.Drafting_Start_Date__c + newRecord.Drafting_End_Date__c + 'OLDRECORD:' + oldRecord.Drafting_Start_Date__c + oldRecord.Drafting_End_Date__c);
        
        String Firsttheatricaldate_ApiName = destinationfieldMap.get('First_Theatrical_Date');
        String Approvecatalogdraft_ApiName = sourcefieldMap.get('Approve_Catalog_Drafting_Titles');
        String calculatedfield_ApiName = calculatedfieldMap.get('put calculatedfield label here');
        
        //Requirement - If street date is not equal to null isphysical checkbox should enable and If street date is equal to null isphysical checkbox should disable on update  
        
        String streetDate_ApiNm= 'Street_Date__c';
        
        String isPhysical_ApiNm= 'IsPhysical__c';
        if(newrec1.get(streetDate_ApiNm)==null){
            newrec1.put(isPhysical_ApiNm,false);
        }   
        
        String ApproveDraftLabel= 'Approve_Catalog_Drafting_Titles';
        system.debug('releaseDefaultLabelMap record for Approve days: '+releaseDefaultLabelMap.get(ApproveDraftLabel));
        
        String ApproveDraftDays_ApiName = releaseDefaultLabelMap.get(ApproveDraftLabel).Source_Field__c;
        String FirstTheatrical_ApiName = releaseDefaultLabelMap.get(ApproveDraftLabel).Destination_Field__c;
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 FirstTheatrical Date Value: '+newrec1.get(FirstTheatrical_ApiName));
        
        //Filmmaker_3rd_Party_Due_Date__c
        String reviewDateLabel= 'L3_Review_Date';
        String thirdPartyDueDateLabel= 'Filmmaker_3rd_Party_Due_Date';
        String reviewDateLabel1= 'L1_Review_Date';
        String reviewDateLabel2= 'L2_Review_Date';
        String DomININfoLabel= 'Domestic_Initial_Info_To_Mkts_Request';
        String DraftingEndLabel= 'Drafting_End_Date';
        String DraftingStartLabel= 'Drafting_Start_Date';
        String MarketingAlertLabel= 'Marketing_Alert_Request_Input_To_Plan';
        String MarketingGuidelinesLabel= 'Marketing_Guidelines_Guardrails';
        String WWCreativekickoffLabel= 'WW_Creative_Kick_Off';
        String VODdateLabel= 'Vod_date';
        String PVODdateLabel= 'PVOD_Date';
        String ESTdateLabel= 'EST_Date';
        String PESTdateLabel= 'PEST_Date';
        // String ORDERDUEDTLabel= 'Order_Due_Date';
        String StreetdtLabel= 'Street_Date';
        
        
        String Streetdate_ApiName = releaseDefaultLabelMap.get(StreetdtLabel).Source_Field__c;
        // String ORDERDUEDT_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Source_Field__c;
        String PESTDatee_ApiName = releaseDefaultLabelMap.get(PESTdateLabel).Source_Field__c;
        system.debug('PESTDatee_ApiName: '+PESTDatee_ApiName);
        String ESTDatee_ApiName = releaseDefaultLabelMap.get(ESTdateLabel).Source_Field__c;
        String l3reviewDate_ApiName = releaseDefaultLabelMap.get(reviewDateLabel).Source_Field__c;
        String thirdPartyDueDate_ApiName = releaseDefaultLabelMap.get(thirdPartyDueDateLabel).Source_Field__c;
        String l2reviewDate_ApiName = releaseDefaultLabelMap.get(reviewDateLabel2).Source_Field__c;
        String l1reviewDate_ApiName = releaseDefaultLabelMap.get(reviewDateLabel1).Source_Field__c;
        String DomInitInfo_ApiName = releaseDefaultLabelMap.get(DomININfoLabel).Source_Field__c;
        String DraftingEndLabel_ApiName = releaseDefaultLabelMap.get(DraftingEndLabel).Source_Field__c;
        String DraftingEStartLabel_ApiName = releaseDefaultLabelMap.get(DraftingStartLabel).Source_Field__c;
        String MarketingAlertLabel_ApiName = releaseDefaultLabelMap.get(MarketingAlertLabel).Source_Field__c;
        String MarketingGuidelines_ApiName = releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Source_Field__c;
        String WWCreativekickoff_ApiName = releaseDefaultLabelMap.get(WWCreativekickoffLabel).Source_Field__c;
        String VODdate_ApiName = releaseDefaultLabelMap.get(VODdateLabel).Source_Field__c;
        String PVODdate_ApiName = releaseDefaultLabelMap.get(PVODdateLabel).Source_Field__c;
        
        System.debug('##1. INSIDE SETDATEONUPDATE## NEWRECORD:' + newRecord.Drafting_Start_Date__c + newRecord.Drafting_End_Date__c + 'OLDRECORD:' + oldRecord.Drafting_Start_Date__c + oldRecord.Drafting_End_Date__c);
        //System.debug('##1.  newRec1: ' + newrec1.get(DraftingStartLabel));
        
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 L3_Review_Date Date Value: '+newrec1.get(ApproveDraftDays_ApiName));
        system.debug('new record  theatrical date: ' + newRecord.First_Theatrical_Date__c);
        system.debug('old record  theatrical date: ' + oldRecord.First_Theatrical_Date__c);
        System.debug('##2. INSIDE SETDATEONUPDATE## NEWRECORD:' + newRecord.Drafting_Start_Date__c + newRecord.Drafting_End_Date__c + 'OLDRECORD:' + oldRecord.Drafting_Start_Date__c + oldRecord.Drafting_End_Date__c);
        
        if(newrec1.get(FirstTheatrical_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c  ){
            /*Approve Catalog Drafting Titles = Theatrical Release date - 365 days*/
            if(releaseDefaultLabelMap.get(ApproveDraftLabel)!=null){
                
                Date FirstTheatricalDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ApproveDraftLabel).Destination_Field__c)); 
                system.debug('FirstTheatricalDate: '+FirstTheatricalDate);
                Decimal FirstTheatricalNumDays= releaseDefaultLabelMap.get(ApproveDraftLabel).Calculation__c;
                system.debug('FirstTheatricalNumDays: '+FirstTheatricalNumDays);
                if(FirstTheatricalNumDays!=null){
                    
                    Date FirstSubstractedDate= FirstTheatricalDate.addDays(Integer.ValueOf(FirstTheatricalNumDays));
                    system.debug('FirstSubstractedDate: '+FirstSubstractedDate);
                    newrec1.put(ApproveDraftDays_ApiName,FirstSubstractedDate);
                }
            }
            
            System.debug('##4. INSIDE SETDATEONUPDATE## NEWRECORD:' + newRecord.Drafting_Start_Date__c + newRecord.Drafting_End_Date__c + 'OLDRECORD:' + oldRecord.Drafting_Start_Date__c + oldRecord.Drafting_End_Date__c);
            /*Street Date = Theatrical Release Date+95*/
            
            if(newrec1.get(Streetdate_ApiName)==NULL || newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c){
                if(releaseDefaultLabelMap.get(StreetdtLabel)!=null){
                    Date FirstTheatricalDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(StreetdtLabel).Destination_Field__c)); 
                    Decimal daystoadd = releaseDefaultLabelMap.get(StreetdtLabel).Calculation__c;
                    if(daystoadd!=NULL){
                        date streeDatecalculated = FirstTheatricalDate.addDays(Integer.valueof(daystoadd));
                        newrec1.put(Streetdate_ApiName,streeDatecalculated);
                    }
                }               
            }
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*L3 Review Date = Theatrical Release date + 28 days */
            if((newrec1.get(l3reviewDate_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
            	||(newrec1.get(l3reviewDate_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){  
                if(releaseDefaultLabelMap.get(reviewDateLabel)!=null){
                    
                    Date FirstTheatricalDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(reviewDateLabel).Destination_Field__c)); 
                    system.debug('FirstTheatricalDate: '+FirstTheatricalDate);
                    Decimal l3ReviewDateNumDays= releaseDefaultLabelMap.get(reviewDateLabel).Calculation__c;
                    system.debug('l3ReviewDateNumDays: '+l3ReviewDateNumDays);
                    Date l3ReviewDate= FirstTheatricalDate.addDays(Integer.ValueOf(l3ReviewDateNumDays));
                    system.debug('l3ReviewDate: '+l3ReviewDate);
                    newrec1.put(l3reviewDate_ApiName,l3ReviewDate);
                    
                }
            }
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /* L2 Review Date = Theatrical Release date + 21 days */
            if((newrec1.get(l2reviewDate_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
            	||(newrec1.get(l2reviewDate_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){ 
                if(releaseDefaultLabelMap.get(reviewDateLabel2)!=null){
                    
                    Date FirstTheatricalDate2 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(reviewDateLabel2).Destination_Field__c)); 
                    system.debug('FirstTheatricalDate2: '+FirstTheatricalDate2);
                    Decimal l2ReviewDateNumDays= releaseDefaultLabelMap.get(reviewDateLabel2).Calculation__c;
                    system.debug('l2ReviewDateNumDays: '+l2ReviewDateNumDays);
                    Date l2ReviewDate= FirstTheatricalDate2.addDays(Integer.ValueOf(l2ReviewDateNumDays));
                    system.debug('l2ReviewDate: '+l2ReviewDate);
                    newrec1.put(l2reviewDate_ApiName,l2ReviewDate);
                }
            }
            
            String TradeSolicitationLabel= 'Trade_Solicitation_Date';
            
            String TradeSolicitation1_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Source_Field__c;
            String PVODDT_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c;
            String stDateAPIName = 'Street_Date__c';
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(TradeSolicitation1_ApiName));
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Announce Date	=	PVOD Date -10 */
            if((newrec1.get(TradeSolicitation1_ApiName)==null && (newRecord.PVOD_Date__c!=oldRecord.PVOD_Date__c || newRecord.Street_Date__c !=oldRecord.Street_Date__c))
            ||(newrec1.get(TradeSolicitation1_ApiName)!=null && (newRecord.PVOD_Date__c!=oldRecord.PVOD_Date__c || newRecord.Street_Date__c !=oldRecord.Street_Date__c))){
                if(newrec1.get(PVODDT_ApiName)!=null ){
                    if(releaseDefaultLabelMap.get(TradeSolicitationLabel)!=null){
                        
                        Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c)); 
                        system.debug('TradesolicitationDate: '+TradesolicitationDate);
                        
                        Decimal TradeNumDays= releaseDefaultLabelMap.get(TradeSolicitationLabel).Calculation__c;
                        system.debug('TradeNumDays: '+TradeNumDays);
                        Date TradesubDate= TradesolicitationDate.addDays(Integer.ValueOf(TradeNumDays));
                        system.debug('TradesubDate: '+TradesubDate);
                        newrec1.put(TradeSolicitation1_ApiName,TradesubDate);
                    }
                }
                else{
                    if(newrec1.get(stDateAPIName)!=null){
                        Date stDate = Date.valueOf(newrec1.get(stDateAPIName));
                        newrec1.put(TradeSolicitation1_ApiName, stDate.addDays(-56));
                    }
                }
                
                /*String TradeSolicitationLabel= 'Trade_Solicitation_Date';

String TradeSolicitation1_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Source_Field__c;
String StreetDT_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c;

system.debug('newrec1 Value: '+newrec1);
system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(TradeSolicitation1_ApiName));

/*Announce Date	=	Street Date -49 

if(newrec1.get(TradeSolicitation1_ApiName)==null || newRecord.Street_Date__c!=oldRecord.Street_Date__c){
if(newrec1.get(StreetDT_ApiName)!=null ){
if(releaseDefaultLabelMap.get(TradeSolicitationLabel)!=null){

Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c)); 
system.debug('TradesolicitationDate: '+TradesolicitationDate);

Decimal TradeNumDays= releaseDefaultLabelMap.get(TradeSolicitationLabel).Calculation__c;
system.debug('TradeNumDays: '+TradeNumDays);
Date TradesubDate= TradesolicitationDate.addDays(Integer.ValueOf(TradeNumDays));
system.debug('TradesubDate: '+TradesubDate);
newrec1.put(TradeSolicitation1_ApiName,TradesubDate);
}
}   
}*/
                /*String TradeassetdueJVLabel= 'Trade_Assets_Due_to_JV_Date';
system.debug('releaseDefaultLabelMap record for TradeassetdueJVLabel days: '+releaseDefaultLabelMap.get(TradeassetdueJVLabel));

String TradeassetdueJVLabel_ApiName = releaseDefaultLabelMap.get(TradeassetdueJVLabel).Source_Field__c;
String Tradesolicitation_ApiName = releaseDefaultLabelMap.get(TradeassetdueJVLabel).Destination_Field__c;

system.debug('newrec1 Value: '+newrec1);
system.debug('newrec1 Tradesolicitation_ApiName Value: '+newrec1.get(Tradesolicitation_ApiName));

/* Trade Assets Due to JV Date = Announce Date - 7 */
                /*if(newrec1.get(TradeassetdueJVLabel_ApiName)==null || newRecord.Trade_Solicitation_Date__c!=oldRecord.Trade_Solicitation_Date__c){
if(newrec1.get(Tradesolicitation_ApiName)!=null ){
if(releaseDefaultLabelMap.get(TradeassetdueJVLabel)!=null){
system.debug('Annouce date====>'+newrec1.get(Tradesolicitation_ApiName));
Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeassetdueJVLabel).Destination_Field__c)); 
system.debug('TradesolicitationDate: '+TradesolicitationDate);

Decimal SolNumDays= releaseDefaultLabelMap.get(TradeassetdueJVLabel).Calculation__c;
system.debug('SolNumDays: '+SolNumDays);
Date SolsubDate= TradesolicitationDate.addDays(Integer.ValueOf(SolNumDays));
system.debug('SolsubDate: '+SolsubDate);
newrec1.put(TradeassetdueJVLabel_ApiName,SolsubDate);
}   
}
}*/
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Drafting End Date	= Theatrical Release date + 11 days*/
                if((newrec1.get(DraftingEndLabel_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(DraftingEndLabel_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){
                    if(releaseDefaultLabelMap.get(DraftingEndLabel)!=null){
                        
                        Date FirstTheatricalDate4 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DraftingEndLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate4: '+FirstTheatricalDate4);
                        Decimal DraftingEndlabelNumDays= releaseDefaultLabelMap.get(DraftingEndLabel).Calculation__c;
                        system.debug('DraftingEndlabelNumDays: '+DraftingEndlabelNumDays);
                        Date DraftingDate= FirstTheatricalDate4.addDays(Integer.ValueOf(DraftingEndlabelNumDays));
                        system.debug('DraftingDate: '+DraftingDate);
                        newrec1.put(DraftingEndLabel_ApiName,DraftingDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Drafting Start Date = Theatrical Release date - 30 days*/
                if((newrec1.get(DraftingEStartLabel_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(DraftingEStartLabel_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){
                    if(releaseDefaultLabelMap.get(DraftingStartLabel)!=null){
                        
                        Date FirstTheatricalDate5 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DraftingStartLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate5: '+FirstTheatricalDate5);
                        Decimal DraftingStartlabelNumDays= releaseDefaultLabelMap.get(DraftingStartLabel).Calculation__c;
                        system.debug('DraftingStartlabelNumDays: '+DraftingStartlabelNumDays);
                        Date DraftingStartDate= FirstTheatricalDate5.addDays(Integer.ValueOf(DraftingStartlabelNumDays));
                        system.debug('DraftingStartDate: '+DraftingStartDate);
                        newrec1.put(DraftingEStartLabel_ApiName,DraftingStartDate);
                        
                    }
                }
                String PhysicalrentalLabel= 'Physical_Rental_Date';
                system.debug('releaseDefaultLabelMap record for PhysicalrentalLabel days: '+releaseDefaultLabelMap.get(PhysicalrentalLabel));
                
                String PhysicalrentalLabel_ApiName = releaseDefaultLabelMap.get(PhysicalrentalLabel).Source_Field__c;
                String StreetDT1_ApiName = releaseDefaultLabelMap.get(PhysicalrentalLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(PhysicalrentalLabel_ApiName));
                
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Physical rental date = Street date*/
                
                if((newrec1.get(PhysicalrentalLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
                	||(newrec1.get(PhysicalrentalLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
                    if(newrec1.get(StreetDT1_ApiName)!=null){
                        if(releaseDefaultLabelMap.get(PhysicalrentalLabel)!=null){
                            
                            Date PhysicalrentalLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PhysicalrentalLabel).Destination_Field__c)); 
                            system.debug('PhysicalrentalLabelDate: '+PhysicalrentalLabelDate);
                            
                            Decimal PhysicalNumDays= releaseDefaultLabelMap.get(PhysicalrentalLabel).Calculation__c;
                            system.debug('PhysicalNumDays: '+PhysicalNumDays);
                            Date physicalsubDate= PhysicalrentalLabelDate.addDays(Integer.ValueOf(PhysicalNumDays));
                            system.debug('physicalsubDate: '+physicalsubDate);
                            newrec1.put(PhysicalrentalLabel_ApiName,physicalsubDate);
                            
                        }   
                    }
                }
                
                /*EST Date = Theatrical Release Date + 74*/
                
                if(newrec1.get(ESTDatee_ApiName)==null || newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c){
                    
                    if(releaseDefaultLabelMap.get(ESTdateLabel)!=null){
                        system.debug('ESTdateLabel====>'+releaseDefaultLabelMap.get(ESTdateLabel).Calculation__c);
                        Date FirstTheatricalDate2 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ESTdateLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate2: '+FirstTheatricalDate2);
                        Decimal ESTdateLabelNumDays= releaseDefaultLabelMap.get(ESTdateLabel).Calculation__c;
                        system.debug('ESTdateLabelNumDays: '+ESTdateLabelNumDays);
                        Date ESTdateLabelDate= FirstTheatricalDate2.addDays(Integer.ValueOf(ESTdateLabelNumDays));
                        system.debug('ESTdateLabelDate: '+ESTdateLabelDate);
                        newrec1.put(ESTDatee_ApiName,ESTdateLabelDate);
                    }
                }
                
                /*Street Date	=	Theatrical Release Date+95*/
                if(newrec1.get(Streetdate_ApiName)==null){ 
                    if(releaseDefaultLabelMap.get(StreetdtLabel)!=null){
                        
                        Date FirstTheatricalDateS = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(StreetdtLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDateS: '+FirstTheatricalDateS);
                        Decimal StreetdtDays= releaseDefaultLabelMap.get(StreetdtLabel).Calculation__c;
                        system.debug('StreetdtDays: '+StreetdtDays);
                        Date StreetdtDaysDate= FirstTheatricalDateS.addDays(Integer.ValueOf(StreetdtDays));
                        system.debug('StreetdtDaysDate: '+StreetdtDaysDate);
                        newrec1.put(Streetdate_ApiName,StreetdtDaysDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*PEST Date	= Theatrical Release Date+49*/
                if((newrec1.get(PESTDatee_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(PESTDatee_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){ 
                    if(releaseDefaultLabelMap.get(PESTdateLabel)!=null){
                        
                        Id conId = (Id) newrec1.get('country__c');
                        system.debug('Theatrical countryRelease:'+ conId);
                        String countryRelease = [SELECT Name FROM Country__c where id =: conId].Name;
                        
                        Date FirstTheatricalDate00 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PESTdateLabel).Destination_Field__c)); 
                        Date PESTdateLabelDate;
                        
                        system.debug('FirstTheatricalDate00: '+FirstTheatricalDate00);
                        
                        if(countryRelease == 'USA'){
                            PESTdateLabelDate = FirstTheatricalDate00.addDays(49);
                        }
                        
                        else if(countryRelease == 'Canada'){
                            PESTdateLabelDate = FirstTheatricalDate00;
                        }
                        
                        else{
                            Decimal PESTdateLabelNumDays= releaseDefaultLabelMap.get(PESTdateLabel).Calculation__c;
                            system.debug('PESTdateLabelNumDays: '+PESTdateLabelNumDays);
                            PESTdateLabelDate= FirstTheatricalDate00.addDays(Integer.ValueOf(PESTdateLabelNumDays));
                            system.debug('PESTdateLabelDate: '+PESTdateLabelDate);
                        }
                        newrec1.put(PESTDatee_ApiName,PESTdateLabelDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*VOD Date	= Theatrical Release Date+95 */
                if(((newrec1.get(VODdate_ApiName)==null) && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||((newrec1.get(VODdate_ApiName)!=null) &&newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){    
                    if(releaseDefaultLabelMap.get(VODdateLabel)!=null){
                        
                        Date FirstTheatricalDat = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(VODdateLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDat: '+FirstTheatricalDat);
                        Decimal VODNumDays= releaseDefaultLabelMap.get(VODdateLabel).Calculation__c;
                        system.debug('VODNumDays: '+VODNumDays);
                        Date VODDate= FirstTheatricalDat.addDays(Integer.ValueOf(VODNumDays));
                        system.debug('VODDate: '+VODDate);
                        newrec1.put(VODdate_ApiName,VODDate);
                        
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*PVOD Date	= Theatrical Release Date+49*/            
                if((newrec1.get(PVODdate_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(PVODdate_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){    
                    if(releaseDefaultLabelMap.get(PVODdateLabel)!=null){
                        Id conId = (Id) newrec1.get('Country__c');
                        if(conId != null){
                            String countryRelease = [SELECT Name FROM Country__c where id =: conId].Name;
                            Date FirstTheatricalDat = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PVODdateLabel).Destination_Field__c));
                            Date PVODDate;
                            system.debug('FirstTheatricalDat: '+FirstTheatricalDat);
                            
                            if(countryRelease == 'USA'){
                                PVODDate = FirstTheatricalDat.addDays(49);
                            }
                            else if(countryRelease == 'Canada'){
                                PVODDate = FirstTheatricalDat;
                            }
                            else{
                                
                                Decimal PVODNumDays= releaseDefaultLabelMap.get(PVODdateLabel).Calculation__c;
                                system.debug('PVODNumDays: '+PVODNumDays);
                                PVODDate= FirstTheatricalDat.addDays(Integer.ValueOf(PVODNumDays));
                                system.debug('PVODDate: '+PVODDate);
                            }
                            newrec1.put(PVODdate_ApiName,PVODDate);
                        }
                        
                    }
                }
                String suppressionLabel= 'Suppression_Lift_Datee';
                system.debug('releaseDefaultLabelMap record for Suppression_Lift_Datee days: '+releaseDefaultLabelMap.get(suppressionLabel));
                
                String suppLabel_ApiName = releaseDefaultLabelMap.get(suppressionLabel).Source_Field__c;
                String Estlab_ApiName = releaseDefaultLabelMap.get(suppressionLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 Estlab_ApiName Date Value: '+newrec1.get(Estlab_ApiName));
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Suppression Lift Date	= EST Date - 28 days*/
                if((newrec1.get(suppLabel_ApiName)==null && newRecord.EST_Date__c!=oldRecord.EST_Date__c)
                	||(newrec1.get(suppLabel_ApiName)!=null && newRecord.EST_Date__c!=oldRecord.EST_Date__c)){   
                    if(newrec1.get(Estlab_ApiName)!=null){
                        system.debug('releaseDefaultLabelMap at line 1068: '+releaseDefaultLabelMap);
                        system.debug('releaseDefaultLabelMap.get(suppressionLabel) at line 1068: '+releaseDefaultLabelMap.get(suppressionLabel));
                        if(releaseDefaultLabelMap.get(suppressionLabel)!=null){
                            
                            Date ESTDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(suppressionLabel).Destination_Field__c)); 
                            system.debug('suppressionLabel: '+suppressionLabel);
                            
                            Decimal ESTNumDays= releaseDefaultLabelMap.get(suppressionLabel).Calculation__c;
                            system.debug('ESTNumDays: '+ESTNumDays);
                            Date ESTsubDate= ESTDate.addDays(Integer.ValueOf(ESTNumDays));
                            system.debug('ESTsubDate: '+ESTsubDate);
                            newrec1.put(suppLabel_ApiName,ESTsubDate);
                        }   
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /* WW Creative Kick-Off = Theatrical Release date - 15 days */
                if((newrec1.get(WWCreativekickoff_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(WWCreativekickoff_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){  
                    if(releaseDefaultLabelMap.get(WWCreativekickoffLabel)!=null){
                        
                        Date FirstTheatricalDate8 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(WWCreativekickoffLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate8: '+FirstTheatricalDate8);
                        Decimal WWkickoffNumDays= releaseDefaultLabelMap.get(WWCreativekickoffLabel).Calculation__c;
                        system.debug('WWkickoffNumDays: '+WWkickoffNumDays);
                        Date WWkickoffDate= FirstTheatricalDate8.addDays(Integer.ValueOf(WWkickoffNumDays));
                        system.debug('WWkickoffDate: '+WWkickoffDate);
                        newrec1.put(WWCreativekickoff_ApiName,WWkickoffDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Domestic Initial Info To Mkts & Request = Theatrical Release date - 49 days*/
                if((newrec1.get(DomInitInfo_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(DomInitInfo_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){ 
                    if(releaseDefaultLabelMap.get(DomININfoLabel)!=null){
                        
                        Date FirstTheatricalDate3 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DomININfoLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate3: '+FirstTheatricalDate3);
                        Decimal DomReviewDateNumDays= releaseDefaultLabelMap.get(DomININfoLabel).Calculation__c;
                        system.debug('DomReviewDateNumDays: '+DomReviewDateNumDays);
                        Date DomReviewDate= FirstTheatricalDate3.addDays(Integer.ValueOf(DomReviewDateNumDays));
                        system.debug('DomReviewDate: '+DomReviewDate);
                        newrec1.put(DomInitInfo_ApiName,DomReviewDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /* Marketing Alert & Request Input To Plan = Theatrical Release date + 7 days */
                if((newrec1.get(MarketingAlertLabel_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(MarketingAlertLabel_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){
                    if(releaseDefaultLabelMap.get(MarketingAlertLabel)!=null){
                        
                        Date FirstTheatricalDate6 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingAlertLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate6: '+FirstTheatricalDate6);
                        Decimal MarketingLabelNumDays= releaseDefaultLabelMap.get(MarketingAlertLabel).Calculation__c;
                        system.debug('MarketingLabelNumDays: '+MarketingLabelNumDays);
                        Date MarketingLabelDate= FirstTheatricalDate6.addDays(Integer.ValueOf(MarketingLabelNumDays));
                        system.debug('MarketingLabelDate: '+MarketingLabelDate);
                        newrec1.put(MarketingAlertLabel_ApiName,MarketingLabelDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Marketing Guidelines & Guardrails = Theatrical Release date - 90 days*/
                if((newrec1.get(MarketingGuidelines_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(MarketingGuidelines_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){
                    if(releaseDefaultLabelMap.get(MarketingGuidelinesLabel)!=null){
                        
                        Date FirstTheatricalDate7 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate7: '+FirstTheatricalDate7);
                        Decimal MarketingGuidelinesNumDays= releaseDefaultLabelMap.get(MarketingGuidelinesLabel).Calculation__c;
                        system.debug('MarketingGuidelinesNumDays: '+MarketingGuidelinesNumDays);
                        Date MarketingGuidelinesDate= FirstTheatricalDate7.addDays(Integer.ValueOf(MarketingGuidelinesNumDays));
                        system.debug('MarketingGuidelinesDate: '+MarketingGuidelinesDate);
                        newrec1.put(MarketingGuidelines_ApiName,MarketingGuidelinesDate);
                    }
                }
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*L1 Review Date = Theatrical Release date + 14 days*/
                if((newrec1.get(l1reviewDate_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
                	||(newrec1.get(l1reviewDate_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){
                    if(releaseDefaultLabelMap.get(reviewDateLabel1)!=null){
                        
                        Date FirstTheatricalDate1 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(reviewDateLabel1).Destination_Field__c)); 
                        system.debug('FirstTheatricalDate1: '+FirstTheatricalDate1);
                        Decimal l1ReviewDateNumDays= releaseDefaultLabelMap.get(reviewDateLabel1).Calculation__c;
                        system.debug('l1ReviewDateNumDays: '+l1ReviewDateNumDays);
                        Date l1ReviewDate= FirstTheatricalDate1.addDays(Integer.ValueOf(l1ReviewDateNumDays));
                        system.debug('l1ReviewDate: '+l1ReviewDate);
                        newrec1.put(l1reviewDate_ApiName,l1ReviewDate);
                    }
                }
                String ClientAvailsConfirmationLabel= 'Client_Avails_Confirmation';
                system.debug('releaseDefaultLabelMap record for ClientAvailsConfirmationLabel days: '+releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel));
                
                String ClientAvailsconfirmation_ApiName = releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Source_Field__c;
                String EstDate_ApiName = releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 VOD Date Value: '+newrec1.get(EstDate_ApiName));
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*CLIENT AVAILS CONFIRMATION = EST Date - 45 days*/
                if((newrec1.get(ClientAvailsconfirmation_ApiName)==null  && newRecord.EST_Date__c!=oldRecord.EST_Date__c)
                	||(newrec1.get(ClientAvailsconfirmation_ApiName)!=null  && newRecord.EST_Date__c!=oldRecord.EST_Date__c)){
                    if(newrec1.get(EstDate_ApiName)!=null){
                        if(releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel)!=null){
                            
                            Date EstDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Destination_Field__c)); 
                            system.debug('EstDate: '+EstDate);
                            
                            Decimal ESTNumDays= releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Calculation__c;
                            system.debug('ESTNumDays: '+ESTNumDays);
                            Date ESTsubDate= EstDate.addDays(Integer.ValueOf(ESTNumDays));
                            system.debug('ESTsubDate: '+ESTsubDate);
                            newrec1.put(ClientAvailsconfirmation_ApiName,ESTsubDate);
                        }   
                    }
                }
                String ORDERDUEDTLabel= 'Order_Due_Date';
                String ORDERDUEDTLabel_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Source_Field__c;
                String StreetDTt1_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 ORDERDUEDTLabel Date Value: '+newrec1.get(ORDERDUEDTLabel_ApiName));
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Order Due Date = Street Date - 42 days*/
                if((newrec1.get(ORDERDUEDTLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
                	||(newrec1.get(ORDERDUEDTLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
                    if(newrec1.get(StreetDTt1_ApiName)!=null){
                        if(releaseDefaultLabelMap.get(ORDERDUEDTLabel)!=null){
                            
                            Date ORDERDUEDTLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c)); 
                            system.debug('ORDERDUEDTLabelDate: '+ORDERDUEDTLabelDate);
                            
                            Decimal OrderNumDays= releaseDefaultLabelMap.get(ORDERDUEDTLabel).Calculation__c;
                            system.debug('OrderNumDays: '+OrderNumDays);
                            Date OrdersubDate= ORDERDUEDTLabelDate.addDays(Integer.ValueOf(OrderNumDays));
                            system.debug('OrdersubDate: '+OrdersubDate);
                            newrec1.put(ORDERDUEDTLabel_ApiName,OrdersubDate);
                        }
                    }   
                }
                String InplantLabel= 'In_plant_date';
                system.debug('releaseDefaultLabelMap record for InplantLabel days: '+releaseDefaultLabelMap.get(InplantLabel));
                
                String InplantLabel_ApiName = releaseDefaultLabelMap.get(InplantLabel).Source_Field__c;
                String StreetDateearly1_ApiName = releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 streetDate Value: '+newrec1.get(StreetDateearly1_ApiName));
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*In Plant Date = Street Date - 70 days*/
                if((newrec1.get(InplantLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
                	||(newrec1.get(InplantLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
                    if(newrec1.get(StreetDateearly1_ApiName)!=null){
                        if(releaseDefaultLabelMap.get(InplantLabel)!=null){
                            
                            Date StreetDate1 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c)); 
                            system.debug('StreetDate1: '+StreetDate1);
                            
                            Decimal StreetNumDays1= releaseDefaultLabelMap.get(InplantLabel).Calculation__c;
                            system.debug('StreetNumDays1: '+StreetNumDays1);
                            Date StreetsubDate1= StreetDate1.addDays(Integer.ValueOf(StreetNumDays1));
                            system.debug('StreetsubDate1: '+StreetsubDate1);
                            newrec1.put(InplantLabel_ApiName,StreetsubDate1);
                        }   
                    }
                }

                String SellingguidesduedtLabel= 'Selling_Guides_Due_Date';
                system.debug('releaseDefaultLabelMap record for SellingguidesduedtLabel days: '+releaseDefaultLabelMap.get(SellingguidesduedtLabel));
                
                String SellingguidesduedtLabel_APIname = releaseDefaultLabelMap.get(SellingguidesduedtLabel).Source_Field__c;
                String Stdt0_ApiName = releaseDefaultLabelMap.get(SellingguidesduedtLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 Stdt0_ApiName Date Value: '+newrec1.get(Stdt0_ApiName));
                
                //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
                /*Selling Guides Due Date = Street Date - 5 months*/
                if((newrec1.get(SellingguidesduedtLabel_APIname)==null && newrec1.get(streetDate_ApiNm)!=oldRecord.Street_Date__c)
                	||(newrec1.get(SellingguidesduedtLabel_APIname)!=null && newrec1.get(streetDate_ApiNm)!=oldRecord.Street_Date__c)){
                    if(newrec1.get(Stdt0_ApiName)!=null){
                        if(releaseDefaultLabelMap.get(SellingguidesduedtLabel)!=null){
                            
                            Date SellingguidesduedtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(SellingguidesduedtLabel).Destination_Field__c)); 
                            system.debug('SellingguidesduedtLabelDate: '+SellingguidesduedtLabelDate);
                            
                            Decimal SellingguidesduedtDays= releaseDefaultLabelMap.get(SellingguidesduedtLabel).Calculation__c;
                            system.debug('SellingguidesduedtDays: '+SellingguidesduedtDays);
                            Date SellingguidesubDate= SellingguidesduedtLabelDate.addMonths(Integer.ValueOf(SellingguidesduedtDays));
                            system.debug('SellingguidesubDate: '+SellingguidesubDate);
                            newrec1.put(SellingguidesduedtLabel_APIname,SellingguidesubDate);
                        }
                    }   
                }
            }
            
        }else{
            
            
            
            String TradeSolicitationLabel= 'Trade_Solicitation_Date';
            
            String TradeSolicitation1_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Source_Field__c;
            String PVODDT_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c;
            String stDateAPIName = 'Street_Date__c';
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(TradeSolicitation1_ApiName));
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Announce Date	=	PVOD Date -10 */
            if((newrec1.get(TradeSolicitation1_ApiName)==null && (newRecord.PVOD_Date__c!=oldRecord.PVOD_Date__c || newRecord.Street_Date__c !=oldRecord.Street_Date__c))
            	||(newrec1.get(TradeSolicitation1_ApiName)!=null && (newRecord.PVOD_Date__c!=oldRecord.PVOD_Date__c || newRecord.Street_Date__c !=oldRecord.Street_Date__c))){
                if(newrec1.get(PVODDT_ApiName)!=null ){
                    if(releaseDefaultLabelMap.get(TradeSolicitationLabel)!=null){
                        
                        Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c)); 
                        system.debug('TradesolicitationDate: '+TradesolicitationDate);
                        
                        Decimal TradeNumDays= releaseDefaultLabelMap.get(TradeSolicitationLabel).Calculation__c;
                        system.debug('TradeNumDays: '+TradeNumDays);
                        Date TradesubDate= TradesolicitationDate.addDays(Integer.ValueOf(TradeNumDays));
                        system.debug('TradesubDate: '+TradesubDate);
                        newrec1.put(TradeSolicitation1_ApiName,TradesubDate);
                    }
                }
                else{
                    if(newrec1.get(stDateAPIName)!=null){
                        Date stDate = Date.valueOf(newrec1.get(stDateAPIName));
                        newrec1.put(TradeSolicitation1_ApiName, stDate.addDays(-56));
                    }
                }
            }
            
            
            String SellingguidesduedtLabel= 'Selling_Guides_Due_Date';
            system.debug('releaseDefaultLabelMap record for SellingguidesduedtLabel days: '+releaseDefaultLabelMap.get(SellingguidesduedtLabel));
            
            String SellingguidesduedtLabel_APIname = releaseDefaultLabelMap.get(SellingguidesduedtLabel).Source_Field__c;
            String Stdt0_ApiName = releaseDefaultLabelMap.get(SellingguidesduedtLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 Stdt0_ApiName Date Value: '+newrec1.get(Stdt0_ApiName));
            
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Selling Guides Due Date = Street Date - 5 months*/
            if((newrec1.get(SellingguidesduedtLabel_APIname)==null && newrec1.get(streetDate_ApiNm)!=oldRecord.Street_Date__c)
            	||(newrec1.get(SellingguidesduedtLabel_APIname)!=null && newrec1.get(streetDate_ApiNm)!=oldRecord.Street_Date__c)){
                if(newrec1.get(Stdt0_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(SellingguidesduedtLabel)!=null){
                        
                        Date SellingguidesduedtLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(SellingguidesduedtLabel).Destination_Field__c)); 
                        system.debug('SellingguidesduedtLabelDate: '+SellingguidesduedtLabelDate);
                        
                        Decimal SellingguidesduedtDays= releaseDefaultLabelMap.get(SellingguidesduedtLabel).Calculation__c;
                        system.debug('SellingguidesduedtDays: '+SellingguidesduedtDays);
                        Date SellingguidesubDate= SellingguidesduedtLabelDate.addMonths(Integer.ValueOf(SellingguidesduedtDays));
                        system.debug('SellingguidesubDate: '+SellingguidesubDate);
                        newrec1.put(SellingguidesduedtLabel_APIname,SellingguidesubDate);
                    }
                }   
            }
            
            String ORDERDUEDTLabel= 'Order_Due_Date';
            String ORDERDUEDTLabel_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Source_Field__c;
            String StreetDTt1_ApiName = releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 ORDERDUEDTLabel Date Value: '+newrec1.get(ORDERDUEDTLabel_ApiName));
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Order Due Date = Street Date - 42 days*/
            if((newrec1.get(ORDERDUEDTLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
            	||(newrec1.get(ORDERDUEDTLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
                if(newrec1.get(StreetDTt1_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(ORDERDUEDTLabel)!=null){
                        
                        Date ORDERDUEDTLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ORDERDUEDTLabel).Destination_Field__c)); 
                        system.debug('ORDERDUEDTLabelDate: '+ORDERDUEDTLabelDate);
                        
                        Decimal OrderNumDays= releaseDefaultLabelMap.get(ORDERDUEDTLabel).Calculation__c;
                        system.debug('OrderNumDays: '+OrderNumDays);
                        Date OrdersubDate= ORDERDUEDTLabelDate.addDays(Integer.ValueOf(OrderNumDays));
                        system.debug('OrdersubDate: '+OrdersubDate);
                        newrec1.put(ORDERDUEDTLabel_ApiName,OrdersubDate);
                    }
                }   
            }
            
            String PhysicalrentalLabel= 'Physical_Rental_Date';
            system.debug('releaseDefaultLabelMap record for PhysicalrentalLabel days: '+releaseDefaultLabelMap.get(PhysicalrentalLabel));
            
            String PhysicalrentalLabel_ApiName = releaseDefaultLabelMap.get(PhysicalrentalLabel).Source_Field__c;
            String StreetDT1_ApiName = releaseDefaultLabelMap.get(PhysicalrentalLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(PhysicalrentalLabel_ApiName));
            
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Physical rental date = Street date*/
            
            if((newrec1.get(PhysicalrentalLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
            	||(newrec1.get(PhysicalrentalLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
                if(newrec1.get(StreetDT1_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(PhysicalrentalLabel)!=null){
                        
                        Date PhysicalrentalLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PhysicalrentalLabel).Destination_Field__c)); 
                        system.debug('PhysicalrentalLabelDate: '+PhysicalrentalLabelDate);
                        
                        Decimal PhysicalNumDays= releaseDefaultLabelMap.get(PhysicalrentalLabel).Calculation__c;
                        system.debug('PhysicalNumDays: '+PhysicalNumDays);
                        Date physicalsubDate= PhysicalrentalLabelDate.addDays(Integer.ValueOf(PhysicalNumDays));
                        system.debug('physicalsubDate: '+physicalsubDate);
                        newrec1.put(PhysicalrentalLabel_ApiName,physicalsubDate);
                        
                    }   
                }
            }
            
            
            String InplantLabel= 'In_plant_date';
            system.debug('releaseDefaultLabelMap record for InplantLabel days: '+releaseDefaultLabelMap.get(InplantLabel));
            
            String InplantLabel_ApiName = releaseDefaultLabelMap.get(InplantLabel).Source_Field__c;
            String StreetDateearly1_ApiName = releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 streetDate Value: '+newrec1.get(StreetDateearly1_ApiName));
            
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*In Plant Date = Street Date - 70 days*/
            if((newrec1.get(InplantLabel_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
            ||(newrec1.get(InplantLabel_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
                if(newrec1.get(StreetDateearly1_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(InplantLabel)!=null){
                        
                        Date StreetDate1 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(InplantLabel).Destination_Field__c)); 
                        system.debug('StreetDate1: '+StreetDate1);
                        
                        Decimal StreetNumDays1= releaseDefaultLabelMap.get(InplantLabel).Calculation__c;
                        system.debug('StreetNumDays1: '+StreetNumDays1);
                        Date StreetsubDate1= StreetDate1.addDays(Integer.ValueOf(StreetNumDays1));
                        system.debug('StreetsubDate1: '+StreetsubDate1);
                        newrec1.put(InplantLabel_ApiName,StreetsubDate1);
                    }   
                }
            }
            
            /*String TradeassetdueJVLabel= 'Trade_Assets_Due_to_JV_Date';
system.debug('releaseDefaultLabelMap record for TradeassetdueJVLabel days: '+releaseDefaultLabelMap.get(TradeassetdueJVLabel));

String TradeassetdueJVLabel_ApiName = releaseDefaultLabelMap.get(TradeassetdueJVLabel).Source_Field__c;
String Tradesolicitation_ApiName = releaseDefaultLabelMap.get(TradeassetdueJVLabel).Destination_Field__c;

system.debug('newrec1 Value: '+newrec1);
system.debug('newrec1 Tradesolicitation_ApiName Value: '+newrec1.get(Tradesolicitation_ApiName));

/* Trade Assets Due to JV Date = Announce Date - 7 */
            /*if(newrec1.get(TradeassetdueJVLabel_ApiName)==null || newRecord.Trade_Solicitation_Date__c!=oldRecord.Trade_Solicitation_Date__c){
if(newrec1.get(Tradesolicitation_ApiName)!=null ){
if(releaseDefaultLabelMap.get(TradeassetdueJVLabel)!=null){
system.debug('Annouce date====>'+newrec1.get(Tradesolicitation_ApiName));
Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeassetdueJVLabel).Destination_Field__c)); 
system.debug('TradesolicitationDate: '+TradesolicitationDate);

Decimal SolNumDays= releaseDefaultLabelMap.get(TradeassetdueJVLabel).Calculation__c;
system.debug('SolNumDays: '+SolNumDays);
Date SolsubDate= TradesolicitationDate.addDays(Integer.ValueOf(SolNumDays));
system.debug('SolsubDate: '+SolsubDate);
newrec1.put(TradeassetdueJVLabel_ApiName,SolsubDate);
}   
}
}*/
            
            String suppressionLabel= 'Suppression_Lift_Datee';
            system.debug('releaseDefaultLabelMap record for Suppression_Lift_Datee days: '+releaseDefaultLabelMap.get(suppressionLabel));
            
            String suppLabel_ApiName = releaseDefaultLabelMap.get(suppressionLabel).Source_Field__c;
            String Estlab_ApiName = releaseDefaultLabelMap.get(suppressionLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 Estlab_ApiName Date Value: '+newrec1.get(Estlab_ApiName));
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Suppression Lift Date	= EST Date - 28 days*/
            if((newrec1.get(suppLabel_ApiName)==null && newRecord.EST_Date__c!=oldRecord.EST_Date__c)
            	||(newrec1.get(suppLabel_ApiName)!=null && newRecord.EST_Date__c!=oldRecord.EST_Date__c)){   
                if(newrec1.get(Estlab_ApiName)!=null){
                    system.debug('releaseDefaultLabelMap at line 1068: '+releaseDefaultLabelMap);
                        system.debug('releaseDefaultLabelMap.get(suppressionLabel) at line 1068: '+releaseDefaultLabelMap.get(suppressionLabel));
                    if(releaseDefaultLabelMap.get(suppressionLabel)!=null){
                        
                        Date ESTDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(suppressionLabel).Destination_Field__c)); 
                        system.debug('suppressionLabel: '+suppressionLabel);
                        
                        Decimal ESTNumDays= releaseDefaultLabelMap.get(suppressionLabel).Calculation__c;
                        system.debug('ESTNumDays: '+ESTNumDays);
                        Date ESTsubDate= ESTDate.addDays(Integer.ValueOf(ESTNumDays));
                        system.debug('ESTsubDate: '+ESTsubDate);
                        newrec1.put(suppLabel_ApiName,ESTsubDate);
                    }   
                }
            }
            
            
            String ClientAvailsConfirmationLabel= 'Client_Avails_Confirmation';
            system.debug('releaseDefaultLabelMap record for ClientAvailsConfirmationLabel days: '+releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel));
            
            String ClientAvailsconfirmation_ApiName = releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Source_Field__c;
            String EstDate_ApiName = releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 VOD Date Value: '+newrec1.get(EstDate_ApiName));
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*CLIENT AVAILS CONFIRMATION = EST Date - 45 days*/
            
            if((newrec1.get(ClientAvailsconfirmation_ApiName)==null  && newRecord.EST_Date__c!=oldRecord.EST_Date__c)
            	||(newrec1.get(ClientAvailsconfirmation_ApiName)!=null  && newRecord.EST_Date__c!=oldRecord.EST_Date__c)){
                if(newrec1.get(EstDate_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel)!=null){
                        
                        Date EstDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Destination_Field__c)); 
                        system.debug('EstDate: '+EstDate);
                        
                        Decimal ESTNumDays= releaseDefaultLabelMap.get(ClientAvailsConfirmationLabel).Calculation__c;
                        system.debug('ESTNumDays: '+ESTNumDays);
                        Date ESTsubDate= EstDate.addDays(Integer.ValueOf(ESTNumDays));
                        system.debug('ESTsubDate: '+ESTsubDate);
                        newrec1.put(ClientAvailsconfirmation_ApiName,ESTsubDate);
                    }   
                }
            }
            
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        /*Premium release date = sreet date - 63*/
        String PremiumReleaseAnnounceDate= 'Premium_Release_Announce_Date';
        
        String PremiumReleaseAnnounceDate_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Source_Field__c;
        String Street_Date_ApiName = releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c;
        if((newrec1.get(PremiumReleaseAnnounceDate_ApiName)==null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)
        	||(newrec1.get(PremiumReleaseAnnounceDate_ApiName)!=null && newRecord.Street_Date__c!=oldRecord.Street_Date__c)){
            if(newrec1.get(Street_Date_ApiName)!=null){
                if(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate)!=null){
                    Date streetDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Destination_Field__c)); 
                    Decimal streetNumDays= releaseDefaultLabelMap.get(PremiumReleaseAnnounceDate).Calculation__c;
                    Date streetSubDate= streetDate.addDays(Integer.ValueOf(streetNumDays));
                    newrec1.put(PremiumReleaseAnnounceDate_ApiName,streetSubDate);
                }   
            }
        }
        
        String TradeSolicitationLabel= 'Trade_Solicitation_Date';
        
        String TradeSolicitation1_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Source_Field__c;
        String PVODDT_ApiName = releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c;
        String stDateAPIName = 'Street_Date__c';
        system.debug('newrec1 Value: '+newrec1);
        system.debug('newrec1 Tradesolicitaion Date Value: '+newrec1.get(TradeSolicitation1_ApiName));
        
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        /*Announce Date	=	PVOD Date -10 */

        if((newrec1.get(TradeSolicitation1_ApiName)==null && (newRecord.PVOD_Date__c!=oldRecord.PVOD_Date__c || newRecord.Street_Date__c !=oldRecord.Street_Date__c))
        	||(newrec1.get(TradeSolicitation1_ApiName)!=null && (newRecord.PVOD_Date__c!=oldRecord.PVOD_Date__c || newRecord.Street_Date__c !=oldRecord.Street_Date__c))){
            if(newrec1.get(PVODDT_ApiName)!=null ){
                if(releaseDefaultLabelMap.get(TradeSolicitationLabel)!=null){
                    
                    Date TradesolicitationDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(TradeSolicitationLabel).Destination_Field__c)); 
                    system.debug('TradesolicitationDate: '+TradesolicitationDate);
                    
                    Decimal TradeNumDays= releaseDefaultLabelMap.get(TradeSolicitationLabel).Calculation__c;
                    system.debug('TradeNumDays: '+TradeNumDays);
                    Date TradesubDate= TradesolicitationDate.addDays(Integer.ValueOf(TradeNumDays));
                    system.debug('TradesubDate: '+TradesubDate);
                    newrec1.put(TradeSolicitation1_ApiName,TradesubDate);
                }
            }
            else{
                if(newrec1.get(stDateAPIName)!=null){
                    Date stDate = Date.valueOf(newrec1.get(stDateAPIName));
                    newrec1.put(TradeSolicitation1_ApiName, stDate.addDays(-56));
                }
            }
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        /*Trade Asset due to JV Date = prem rel date - 63*/
        String tradeAssetDueToJVDate= 'Trade_Assets_Due_to_JV_Date';
        
        String tradeAssetJV_ApiName = releaseDefaultLabelMap.get(tradeAssetDueToJVDate).Source_Field__c;
        String premRel_ApiName = releaseDefaultLabelMap.get(tradeAssetDueToJVDate).Destination_Field__c;
        if((newrec1.get(tradeAssetJV_ApiName)==null && newRecord.Premium_Release_Announce_Date__c!=oldRecord.Premium_Release_Announce_Date__c)
        	||(newrec1.get(tradeAssetJV_ApiName)!=null && newRecord.Premium_Release_Announce_Date__c!=oldRecord.Premium_Release_Announce_Date__c)){
            if(newrec1.get(premRel_ApiName)!=null){
                if(releaseDefaultLabelMap.get(tradeAssetDueToJVDate)!=null){
                    Date premRelDate = Date.ValueOf(newrec1.get(premRel_ApiName)); 
                    Decimal numDays= releaseDefaultLabelMap.get(tradeAssetDueToJVDate).Calculation__c;
                    Date subDate= premRelDate.addDays(Integer.ValueOf(numDays));
                    newrec1.put(tradeAssetJV_ApiName,subDate);
                }   
            }
        }
        
        
        String ThirdpartyLabel= 'Filmmaker_3rd_Party_Due_Date';
        String ThirdpartyLabel_ApiName = releaseDefaultLabelMap.get(ThirdpartyLabel).Source_Field__c;
        String L3label_ApiName = releaseDefaultLabelMap.get(ThirdpartyLabel).Destination_Field__c;
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        /*PLAN TO FLIMMAKER/3RD PARTY = L3 Review Date + 7 days*/
        
        if((newrec1.get(ThirdpartyLabel_ApiName)==null && newRecord.L3_Review_Date__c!=oldRecord.L3_Review_Date__c)
        	||(newrec1.get(ThirdpartyLabel_ApiName)!=null && newRecord.L3_Review_Date__c!=oldRecord.L3_Review_Date__c)){
            if(newrec1.get(L3label_ApiName)!=null ){
                if(releaseDefaultLabelMap.get(ThirdpartyLabel)!=null){
                    
                    Date StreetDate3 = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ThirdpartyLabel).Destination_Field__c)); 
                    system.debug('StreetDate: '+StreetDate3);
                    
                    Decimal Street3NumDays= releaseDefaultLabelMap.get(ThirdpartyLabel).Calculation__c;
                    system.debug('Street3NumDays: '+Street3NumDays);
                    Date Street3subDate= StreetDate3.addDays(Integer.ValueOf(Street3NumDays));
                    system.debug('Street3subDate: '+Street3subDate);
                    newrec1.put(ThirdpartyLabel_ApiName,Street3subDate);
                }   
            }
            
            String EarlypreorderLabel= 'Early_pre_order_date';
            system.debug('releaseDefaultLabelMap record for EarlypreorderLabel days: '+releaseDefaultLabelMap.get(EarlypreorderLabel));
            
            String EarlypreorderLabel_ApiName = releaseDefaultLabelMap.get(EarlypreorderLabel).Source_Field__c;
            String StreetDateearly_ApiName = releaseDefaultLabelMap.get(EarlypreorderLabel).Destination_Field__c;
            
            system.debug('newrec1 Value: '+newrec1);
            system.debug('newrec1 VOD Date Value: '+newrec1.get(StreetDateearly_ApiName));
            //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
            /*Early Pre Order Date = Same as Theatrical Release date*/
            if((newrec1.get(EarlypreorderLabel_ApiName)==null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)
              ||(newrec1.get(EarlypreorderLabel_ApiName)!=null && newRecord.First_Theatrical_Date__c!=oldRecord.First_Theatrical_Date__c)){
                if(newrec1.get(StreetDateearly_ApiName)!=null ){
                    if(releaseDefaultLabelMap.get(EarlypreorderLabel)!=null){
                        
                        Date StreetDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(EarlypreorderLabel).Destination_Field__c)); 
                        system.debug('StreetDate: '+StreetDate);
                        
                        Decimal StreetNumDays= releaseDefaultLabelMap.get(EarlypreorderLabel).Calculation__c;
                        system.debug('StreetNumDays: '+StreetNumDays);
                        Date StreetsubDate= StreetDate.addDays(Integer.ValueOf(StreetNumDays));
                        system.debug('StreetsubDate: '+StreetsubDate);
                        newrec1.put(EarlypreorderLabel_ApiName,StreetsubDate);
                    }   
                }
                
                
                
                
                String DigitalAnnounceDTLabel= 'Digital_Announce_Date';
                system.debug('releaseDefaultLabelMap record for DigitalAnnounceDTLabel days: '+releaseDefaultLabelMap.get(DigitalAnnounceDTLabel));
                
                String DigitalAnnounceDTLabel_ApiName = releaseDefaultLabelMap.get(DigitalAnnounceDTLabel).Source_Field__c;
                String STDYS_ApiName = releaseDefaultLabelMap.get(DigitalAnnounceDTLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 VOD Date Value: '+newrec1.get(STDYS_ApiName));
                // if(newrec1.get(DigitalAnnounceDTLabel_ApiName)==null){
                
                
                if(newrec1.get(STDYS_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(DigitalAnnounceDTLabel)!=null){
                        
                        Date STDYSDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(DigitalAnnounceDTLabel).Destination_Field__c)); 
                        system.debug('STDYSDate: '+STDYSDate);
                        
                        Decimal STDYSDateNumDays= releaseDefaultLabelMap.get(DigitalAnnounceDTLabel).Calculation__c;
                        system.debug('STDYSDateNumDays: '+STDYSDateNumDays);
                        Date PSTDYSDatesubDate= STDYSDate.addDays(Integer.ValueOf(STDYSDateNumDays));
                        system.debug('PSTDYSDatesubDate: '+PSTDYSDatesubDate);
                        newrec1.put(DigitalAnnounceDTLabel_ApiName,PSTDYSDatesubDate);
                    }
                }   
                
                
                String RegieRatingsLabel= 'Regie_Ratings_Due_Date';
                system.debug('releaseDefaultLabelMap record for Canadian_Ratings days: '+releaseDefaultLabelMap.get(RegieRatingsLabel));
                
                String RegieRatingsLabel_ApiName = releaseDefaultLabelMap.get(RegieRatingsLabel).Source_Field__c;
                String Finaledate1_ApiName = releaseDefaultLabelMap.get(RegieRatingsLabel).Destination_Field__c;
                
                system.debug('newrec1 Value: '+newrec1);
                system.debug('newrec1 ww Date Value: '+newrec1.get(RegieRatingsLabel_ApiName));
                
                if(newrec1.get(Finaledate1_ApiName)!=null){
                    if(releaseDefaultLabelMap.get(RegieRatingsLabel)!=null){
                        
                        Date RegieRatingsLabelDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(RegieRatingsLabel).Destination_Field__c)); 
                        system.debug('RegieRatingsLabelDate: '+RegieRatingsLabelDate);
                        
                        Decimal RegieNumDays= releaseDefaultLabelMap.get(RegieRatingsLabel).Calculation__c;
                        system.debug('RegieNumDays: '+RegieNumDays);
                        Date regiesubDate= RegieRatingsLabelDate.addDays(Integer.ValueOf(RegieNumDays));
                        system.debug('regiesubDate: '+regiesubDate);
                        newrec1.put(RegieRatingsLabel_ApiName,regiesubDate);
                        
                    }   
                }
                
                
                String premierdate_ApiName = destinationfieldMap.get('Premiere_Date');
                String ArtworkdeliveryLabel= 'Artwork_Delivery_Due_Date';
                String Artworkdelivery_ApiName = releaseDefaultLabelMap.get(ArtworkdeliveryLabel).Source_Field__c;
                
                if(newrec1.get(premierdate_ApiName)!=null && newrec1.get(premierdate_ApiName)!=oldrec.get(premierdate_ApiName) && newrec1.get('Release_Sync__c')==null){
                    if(releaseDefaultLabelMap.get(ArtworkdeliveryLabel)!=null){
                        Date PremierDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ArtworkdeliveryLabel).Destination_Field__c)); 
                        system.debug('PremierDate: '+PremierDate);                   
                        Decimal PremierNumDays= releaseDefaultLabelMap.get(ArtworkdeliveryLabel).Calculation__c;
                        system.debug('PremierNumDays: '+PremierNumDays);
                        Date PremiersubDate= PremierDate.addDays(Integer.ValueOf(PremierNumDays));
                        system.debug('PremiersubDate: '+PremiersubDate);
                        newrec1.put(Artworkdelivery_ApiName,PremiersubDate);
                    }
                }
                
                Release__c newrec=(Release__c)newrec1;
                
                
                system.debug('Early_Pre_Order_Date__c-----------------'+newrec.Early_Pre_Order_Date__c);
                if(theatricalID!=null && newrec!=null){
                    if(newrec.get('RecordTypeId') == theatricalID){
                        if(newrec.Street_Date__c!=null){
                            newrec.IsPhysical__c=true;
                            
                            
                            if(newrec.Digital_Announce_Date__c!=null){
                                if(releaseDateDefaultsMap.get('Digital_Announce_Date')!=null){
                                    Integer days = (Integer)releaseDateDefaultsMap.get('Digital_Announce_Date');
                                    newrec.Digital_Announce_Date__c = newrec.Street_Date__c.addDays(days);
                                }
                                else{
                                    
                                }
                            }
                            
                            
                        }
                        
                        if(newrec.First_Theatrical_Date__c!=null){
                            
                        }
                        
                    }
                    
                }
            }
        }
    }
}