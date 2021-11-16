/*
Name:WB_CalculateRPDates
Creation Date - 5th Oct 2020
Last Modified Date - 5th Oct 2020
Last Modified by  - Tejasvini Telangi
Description- This class is to recalculate RP dates - ER-006428 - Automated Release Date Based on Theatrical Window
Author - Tejasvini Telangi
*/
public with sharing class WB_CalculateRPDates {

    public static boolean recursiveUpdate = false;
    public static boolean recursiveInsert = false;
    public WB_CalculateRPDates() {

    }

    public static void calculateAutomatedReleaseDates(List<Commercial_Avail__c> newRPList,Map<Id,Commercial_Avail__c> oldReleasePlanMap,String operation){
        
        if(newRPList == null || newRPList.isEmpty())
          return;

        List<Id> processRPIdList = new List<Id>();
        List<Commercial_Avail__c> updateRPList = new List<Commercial_Avail__c>();
        Map<Id,Title__c> titleMap = new Map<Id,Title__c>();
        Set<Id> titleIdSet = new Set<Id>();
        Map<Id,Local_Title__c> localTitleMap = new Map<Id,Local_Title__c>();
        Set<Id> localTitleIdSet = new Set<Id>();
        Map<Id,Rights__c> rightsMap = new Map<Id,Rights__c>();
        Set<Id> rightsIdSet = new Set<Id>();
        Map<Id,Country__c> countryMap = new Map<Id,Country__c>();
        Set<Id> countryIdSet = new Set<Id>();

        for(Commercial_Avail__c rpRec : newRPList){
            if(rpRec.Title_Content_Type__c != 'Feature')
                continue;
            
            if(rpRec.Channel__c == 'EST' || rpRec.Channel__c == 'VODc' || rpRec.Channel__c == 'VODi' || rpRec.Channel__c == 'PPV'|| rpRec.Channel__c == 'Physical'){
                if(operation == 'Insert'){
                    if(rpRec.RP_AutoCalc__c){
                        if(rpRec.Title__c != Null){
                            titleIdSet.add(rpRec.Title__c);
                        }
                        if(rpRec.Rights_ID__c != Null){
                            rightsIdSet.add(rpRec.Rights_ID__c);
                        }
                        system.debug(LoggingLevel.INFO,'titleIdSet:'+titleIdSet);
                       
                        if(rpRec.Local_Title__c != Null){
                            localTitleIdSet.add(rpRec.Local_Title__c);
                        }
                        if(rpRec.Country_Lookup__c != Null){
                            countryIdSet.add(rpRec.Country_Lookup__c);
                        }
                    }
                }else if(operation == 'Update'){
                    Commercial_Avail__c oldRPRecord = oldReleasePlanMap.get(rpRec.Id);
                    if(rpRec.Channel__c == 'Physical' && rpRec.Exclusive_Date__c != oldRPRecord.Exclusive_Date__c ){
                        rpRec.GPP_Avail_Start__c = rpRec.Exclusive_Date__c;
                    }
                    
                    if(rpRec.RP_AutoCalc__c && ((rpRec.RP_AutoCalc__c != oldRPRecord.RP_AutoCalc__c) || (( rpRec.Exclusive_Date__c != oldRPRecord.Exclusive_Date__c)||(rpRec.Channel__c != 'Physical' && rpRec.Start_Date__c != oldRPRecord.Start_Date__c )|| rpRec.Rights_End__c != oldRPRecord.Rights_End__c || (rpRec.Channel__c != 'Physical' && rpRec.End_Date__c != oldRPRecord.End_Date__c )))){
                        processRPIdList.add(rpRec.Id);
                    }
                }
            }
        }

        if(operation == 'Insert'){
            if(titleIdSet != Null && titleIdSet.size()>0){
                titleMap = new Map<Id,Title__c>([SELECT Id,US_Theatrical_Release_Date_New__c,First_Available_Date__c,Expiration_Date__c FROM Title__c WHERE Id IN :titleIdSet]);
            }
            if(localTitleIdSet != Null && localTitleIdSet.size()>0){
                localTitleMap = new Map<Id,Local_Title__c>([SELECT Id,Local_Theatrical_Release_Date__c,Initial_VOD_Release_Date__c FROM Local_Title__c WHERE Id IN :localTitleIdSet]);
            }
            if(countryIdSet != Null && countryIdSet.size()>0){
                countryMap = new Map<Id,Country__c>([SELECT Id,EST_Offset__c,VOD_Offset__c,VOD_Exploitation_Days__c,Physical_Offset__c FROM Country__c WHERE Id IN :countryIdSet]);
            }
            if(rightsIdSet != Null && rightsIdSet.size()>0){
                rightsMap = new Map<Id,Rights__c>([SELECT Id,Rights_Start__c,Rights_End__c,Rights_Start_2__c,Rights_End_2__c,Rights_Start_3__c,Rights_End_3__c,Rights_Start_4__c,Rights_End_4__c,Rights_Start_5__c,Rights_End_5__c FROM Rights__c WHERE Id IN :rightsIdSet]);
            }
            
            WB_CalculateRPDates.autoCalcReleaseDates(newRPList,titleMap,localTitleMap,countryMap,rightsMap,Null,operation);
            

        }else if(operation == 'Update'){
            Map<Id,Commercial_Avail__c> processRPMap = new Map<Id,Commercial_Avail__c>([SELECT Id,Channel__c,RP_AutoCalc__c,Rights_Start__c,Rights_Object_End__c,Rights_ID__c,Rights_End__c,Exclusive_Date__c,Start_Date__c,End_Date__c,GPP_Avail_Start__c,Title_Content_Type__c,Country_Lookup__c,Country_Lookup__r.EST_Offset__c,
                            Country_Lookup__r.VOD_Offset__c,Country_Lookup__r.VOD_Exploitation_Days__c,Country_Lookup__r.Physical_Offset__c,Local_Title__c,Local_Title__r.Local_Theatrical_Release_Date__c,Local_Title__r.Initial_VOD_Release_Date__c,
                            Title__c,Title__r.US_Theatrical_Release_Date_New__c,Title__r.First_Available_Date__c,Title__r.Expiration_Date__c FROM Commercial_Avail__c WHERE Id IN :processRPIdList]);
            
            if(processRPMap != Null && processRPMap.size()>0){
                    WB_CalculateRPDates.autoCalcReleaseDates(newRPList,Null,Null,Null,Null,processRPMap,operation);
            }
        }
        
    }

    public static List<Commercial_Avail__c> autoCalcReleaseDates(List<Commercial_Avail__c> newRPList,Map<Id,Title__c> titleMap,Map<Id,Local_Title__c> localTitleMap,Map<Id,Country__c> countryMap,Map<Id,Rights__c> rightsMap,Map<Id,Commercial_Avail__c> processRPMap,String operation){

        List<Commercial_Avail__c> updateRPList = new List<Commercial_Avail__c>();

        if(newRPList != Null && newRPList.size()>0){
            
            for(Commercial_Avail__c rpRecord : newRPList){

                if(!rpRecord.RP_AutoCalc__c || rpRecord.Title_Content_Type__c != 'Feature')
                    continue;

                Date LTRD_OffSetDate = Null;
                Date LTRD = Null;
                Date UTRD = Null;
                Date titleFAD = Null;
                Date titleExpirationDate = Null;
                Date rightsStartDateRights = Null;
                Date rightsEndDateRights = Null;
                Date initialVODReleaseDate = Null;
                Boolean isRPStartDateModified = false;
                Boolean isRPEndDateModified = false;
                Boolean isRPAutoCalcModified = false;
                Set<Date> rpStartDateCalcSet = new Set<Date>();
                Set<Date> rpEndDateCalcSet = new Set<Date>();
                List<Date> rpStartDateCalcList = new List<Date>();
                List<Date> rpEndDateCalcList = new List<Date>();
                Date endDate = Date.newInstance(2049,12,31);
                Decimal estOffset;
                Decimal vodOffset;
                Decimal physicalOffset;
                Decimal vodExploitationDays;

                
                if(operation == 'Insert'){
                    if(localTitleMap.get(rpRecord.Local_Title__c) != Null && localTitleMap.get(rpRecord.Local_Title__c).Local_Theatrical_Release_Date__c != Null){
                        LTRD = localTitleMap.get(rpRecord.Local_Title__c).Local_Theatrical_Release_Date__c;
                    }

                    if((rpRecord.Channel__c == 'Physical') && localTitleMap.get(rpRecord.Local_Title__c) != Null && localTitleMap.get(rpRecord.Local_Title__c).Initial_VOD_Release_Date__c != Null){
                        initialVODReleaseDate = localTitleMap.get(rpRecord.Local_Title__c).Initial_VOD_Release_Date__c;
                    }

                    if(countryMap.get(rpRecord.Country_Lookup__c) != Null){
                        if(countryMap.get(rpRecord.Country_Lookup__c).EST_Offset__c != Null){
                            estOffset = countryMap.get(rpRecord.Country_Lookup__c).EST_Offset__c;
                        }
    
                        if(countryMap.get(rpRecord.Country_Lookup__c).VOD_Offset__c != Null){
                            vodOffset = countryMap.get(rpRecord.Country_Lookup__c).VOD_Offset__c;
                        }

                        if(countryMap.get(rpRecord.Country_Lookup__c).Physical_Offset__c != Null){
                            physicalOffset = countryMap.get(rpRecord.Country_Lookup__c).Physical_Offset__c;
                        }

                        if(countryMap.get(rpRecord.Country_Lookup__c).VOD_Exploitation_Days__c != Null){
                            vodExploitationDays = countryMap.get(rpRecord.Country_Lookup__c).VOD_Exploitation_Days__c;
                        }
                    }

                    if(titleMap.get(rpRecord.Title__c) != Null){

                        if(titleMap.get(rpRecord.Title__c).First_Available_Date__c != Null){
                            titleFAD = titleMap.get(rpRecord.Title__c).First_Available_Date__c;
                        }
                        if(titleMap.get(rpRecord.Title__c).Expiration_Date__c != Null){
                            titleExpirationDate = titleMap.get(rpRecord.Title__c).Expiration_Date__c;
                        }
                        if(titleMap.get(rpRecord.Title__c).US_Theatrical_Release_Date_New__c != Null){
                            UTRD = titleMap.get(rpRecord.Title__c).US_Theatrical_Release_Date_New__c;
                        }
                    }

                    if(rightsMap.get(rpRecord.Rights_ID__c) != Null){

                        if(rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_5__c != Null && rpRecord.Rights_End__c >= rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_5__c){
                            rightsStartDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_5__c;
                            rightsEndDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_End_5__c;
                        }else if(rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_4__c != Null && rpRecord.Rights_End__c >= rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_4__c){
                            rightsStartDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_End_4__c;
                            rightsEndDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_5__c;
                        }else if(rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_3__c != Null && rpRecord.Rights_End__c >= rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_3__c){
                            rightsStartDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_3__c;
                            rightsEndDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_End_3__c;
                        }else if(rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_2__c != Null && rpRecord.Rights_End__c >= rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_2__c){
                            rightsStartDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_Start_2__c;
                            rightsEndDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_End_2__c;
                        }else{
                            rightsStartDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_Start__c;
                            rightsEndDateRights = rightsMap.get(rpRecord.Rights_ID__c).Rights_End__c;
                        }
                        
                    }
                }else if(operation == 'Update' || operation == 'Batch'){
                    if(processRPMap.get(rpRecord.Id) != Null){

                        if(processRPMap.get(rpRecord.Id).Local_Title__c != Null && processRPMap.get(rpRecord.Id).Local_Title__r.Local_Theatrical_Release_Date__c != Null){
                            LTRD = processRPMap.get(rpRecord.Id).Local_Title__r.Local_Theatrical_Release_Date__c;
                        }

                        if((rpRecord.Channel__c == 'Physical') && processRPMap.get(rpRecord.Id).Local_Title__c != Null && processRPMap.get(rpRecord.Id).Local_Title__r.Initial_VOD_Release_Date__c != Null){
                            initialVODReleaseDate = processRPMap.get(rpRecord.Id).Local_Title__r.Initial_VOD_Release_Date__c;
                        }
    
                        if(processRPMap.get(rpRecord.Id).Country_Lookup__c != Null){
                            if(processRPMap.get(rpRecord.Id).Country_Lookup__r.EST_Offset__c != Null){
                                estOffset = processRPMap.get(rpRecord.Id).Country_Lookup__r.EST_Offset__c;
                            }
        
                            if(processRPMap.get(rpRecord.Id).Country_Lookup__r.VOD_Offset__c != Null){
                                vodOffset = processRPMap.get(rpRecord.Id).Country_Lookup__r.VOD_Offset__c;
                            }
    
                            if(processRPMap.get(rpRecord.Id).Country_Lookup__r.Physical_Offset__c != Null){
                                physicalOffset = processRPMap.get(rpRecord.Id).Country_Lookup__r.Physical_Offset__c;
                            }
    
                            if(processRPMap.get(rpRecord.Id).Country_Lookup__r.VOD_Exploitation_Days__c != Null){
                                vodExploitationDays = processRPMap.get(rpRecord.Id).Country_Lookup__r.VOD_Exploitation_Days__c;
                            }
                        }
    
                        if(processRPMap.get(rpRecord.Id).Title__c != Null){
    
                            if(processRPMap.get(rpRecord.Id).Title__r.First_Available_Date__c != Null){
                                titleFAD = processRPMap.get(rpRecord.Id).Title__r.First_Available_Date__c;
                            }
                            if(processRPMap.get(rpRecord.Id).Title__r.Expiration_Date__c != Null){
                                titleExpirationDate = processRPMap.get(rpRecord.Id).Title__r.Expiration_Date__c;
                            }
                            if(processRPMap.get(rpRecord.Id).Title__r.US_Theatrical_Release_Date_New__c != Null){
                                UTRD = processRPMap.get(rpRecord.Id).Title__r.US_Theatrical_Release_Date_New__c;
                            }
                        }

                        if(processRPMap.get(rpRecord.Id).Rights_ID__c != Null){
                            rightsStartDateRights = processRPMap.get(rpRecord.Id).Rights_Start__c;
                            rightsEndDateRights = processRPMap.get(rpRecord.Id).Rights_Object_End__c;
                        }
                    }
                }

                if(LTRD != Null){
                    Integer offSetVal = Null;
                    if(rpRecord.Channel__c == 'EST' && estOffset != Null){
                        offSetVal = Integer.valueOf(estOffset);
                    }
                    if((rpRecord.Channel__c == 'VODc' || rpRecord.Channel__c == 'VODi' || rpRecord.Channel__c == 'PPV') && vodOffset != Null){
                        offSetVal = Integer.valueOf(vodOffset);
                    }
                    if(rpRecord.Channel__c == 'Physical' && physicalOffset != Null){
                        offSetVal = Integer.valueOf(physicalOffset);
                    }

                    if(offSetVal != Null){
                        LTRD_OffSetDate = LTRD.addDays(offSetVal);
                    }
                    
                    //Disable the Autocalc feature on the RP Wizard if LTRD+VOD Offset has passed - For now set for all channels
                    if(LTRD_OffSetDate != Null){
                        rpStartDateCalcSet.add(LTRD_OffSetDate);
                    }
                    
                }

                if(rpRecord.Channel__c == 'Physical'){
                    if((LTRD == Null) && (UTRD != Null)){
                        rpStartDateCalcSet.add(UTRD.addDays(1));
                    }
                    if(initialVODReleaseDate != Null){
                        rpStartDateCalcSet.add(initialVODReleaseDate);
                    }
                }

               //If Channel not Physical use - Avail Start Date - Exclusive_Date__c 
                if(rpRecord.Channel__c != 'Physical' &&  rpRecord.Exclusive_Date__c != Null){
                    rpStartDateCalcSet.add(rpRecord.Exclusive_Date__c);
                }else if(rpRecord.Channel__c == 'Physical' && rpRecord.GPP_Avail_Start__c != Null ){ //else use GPP Avail Start - Date - value entered by user in AVail Start is copied to GPP Avail Start
                    rpStartDateCalcSet.add(rpRecord.GPP_Avail_Start__c);
                }

                //Rights Start - from Rights
                if(rightsStartDateRights != Null){
                    rpStartDateCalcSet.add(rightsStartDateRights);
                }

                //Title's First Available Date
                if(rpRecord.Title__c != Null && titleFAD != Null){
                    rpStartDateCalcSet.add(titleFAD);
                }


                //Release Start will be the later of LTRD+EST Offset, Avail Start, Rights Start or Title FAD
                if(rpStartDateCalcSet != Null && rpStartDateCalcSet.size()>0){
                    rpStartDateCalcList.addAll(rpStartDateCalcSet);
                    if(rpStartDateCalcList.size()>1)
                        rpStartDateCalcList.sort();
                    
                    Date laterDate = rpStartDateCalcList.get(rpStartDateCalcList.size()-1);
                    //assign Start Date new value
                    if(rpRecord.Channel__c != 'Physical'){
                        if((rpRecord.Start_Date__c != Null && rpRecord.Start_Date__c != laterDate) || rpRecord.Start_Date__c == Null){
                            rpRecord.Start_Date__c = laterDate;     //Release Start - Start_Date__c
                            isRPStartDateModified = true;
                        }
                    }else if(rpRecord.Channel__c == 'Physical'){
                        if((rpRecord.Exclusive_Date__c != Null && rpRecord.Exclusive_Date__c != laterDate) || rpRecord.Exclusive_Date__c == Null){
                            rpRecord.Exclusive_Date__c = laterDate; //Avail Start - Exclusive_Date__c
                            isRPStartDateModified = true;
                        }
                    }
                    
                }
                //Start Date Calc End 

                 //End Date Calc Begin

                //VOD window 
                if(rpRecord.Channel__c == 'VODc' || rpRecord.Channel__c == 'VODi' || rpRecord.Channel__c == 'PPV'){
                    if(vodExploitationDays != Null){
                         Date rpStart_VOD = rpRecord.Start_Date__c.addDays(Integer.valueOf(vodExploitationDays));
                         rpEndDateCalcSet.add(rpStart_VOD);
                     }
                 }
 
                 //Avail End - Rights_End__c
                 if(rpRecord.Channel__c != 'Physical' && rpRecord.Rights_End__c != Null){
                     rpEndDateCalcSet.add(rpRecord.Rights_End__c);
                 }
 
                 //Rights End from Rights
                 if(rightsEndDateRights != Null){
                     rpEndDateCalcSet.add(rightsEndDateRights);
                 }
 
                 //Title's Expiration Date
                 if(rpRecord.Title__c != Null && titleExpirationDate != Null && rpRecord.Channel__c != 'Physical'){
                     rpEndDateCalcSet.add(titleExpirationDate);
                 }
 
                 //Date - 12/31/2049
                 rpEndDateCalcSet.add(endDate);
                     
                 //Release End will be earlier of Avail End, Rights End, Expiration Date or 12/31/2049
                 if(rpEndDateCalcSet != Null && rpEndDateCalcSet.size()>0){
                     
                    rpEndDateCalcList.addAll(rpEndDateCalcSet);
                    if(rpEndDateCalcList.size()>1)
                        rpEndDateCalcList.sort();
                    Date earlierDate = rpEndDateCalcList.get(0);
                    if(rpRecord.Channel__c != 'Physical'){
                        if((rpRecord.End_Date__c != Null && rpRecord.End_Date__c != earlierDate) || rpRecord.End_Date__c == Null){
                            rpRecord.End_Date__c = earlierDate; //Avail Start - Exclusive_Date__c
                            isRPEndDateModified = true;
                        }
                    }else if(rpRecord.Channel__c == 'Physical'){
                        if((rpRecord.Rights_End__c != Null && rpRecord.Rights_End__c != earlierDate) || rpRecord.Rights_End__c == Null){
                            rpRecord.Rights_End__c = earlierDate; //Avail Start - Exclusive_Date__c
                            isRPEndDateModified = true;
                        }
                    }
                }
                 //End Date Calc End
 
                 if(rpRecord.Start_Date__c != Null && rpRecord.Start_Date__c < System.Today()){
                     rpRecord.RP_AutoCalc__c = false;
                     isRPAutoCalcModified = true;
                 }
 
                 if(isRPStartDateModified || isRPEndDateModified || isRPAutoCalcModified){
                     updateRPList.add(rpRecord);
                 }
            }
        }

        return updateRPList;
    }
}