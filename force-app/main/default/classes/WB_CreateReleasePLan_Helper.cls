public class WB_CreateReleasePLan_Helper{
    public static List<Commercial_Avail__c> returnProcessedRP_case1(List<Commercial_Avail__c> commercialAvailList, User userDetail,
    Map<Id,Title__c> titleIdMap, Map<Id,Country__c> CountryIdMap, Map<Id,Language__c> languageIdMap, Integer countExcpetionRec, 
    String ConfirmedPartialAllow, Map<String,Rights__c> mapRights, Map<String, String> mapRightsGrp){
        List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
        for(Commercial_Avail__c commAvl : commercialAvailList)
        {  
            countExcpetionRec++;
            Release_Plan_Exceptions__c rpExpnRec = new Release_Plan_Exceptions__c();
            rpExpnRec.name = userDetail.id + string.valueof(countExcpetionRec);
            rpExpnRec.Title__c = titleIdMap.get(commAvl.Title__c).Name;
            rpExpnRec.Video_Version__c = titleIdMap.get(commAvl.Title__c).Video_Version__c;
            rpExpnRec.Country__c = CountryIdMap.get(commAvl.Country_Lookup__c).Name;                        
            rpExpnRec.User_Detail__c = userDetail.id;
                                
            String strMPM = titleIdMap.get(commAvl.Title__c).MPM__c;
            String strVV =  titleIdMap.get(commAvl.Title__c).Video_Version__c;
            Date fstAvailDt = titleIdMap.get(commAvl.Title__c).First_Available_Date__c;
            Date expDate = titleIdMap.get(commAvl.Title__c).Expiration_Date__c;
            Boolean titleMPMGeneric = titleIdMap.get(commAvl.Title__c).MPM__r.Generic__c;
            //Country code
            String strCntyCd = CountryIdMap.containsKey(commAvl.Country_Lookup__c) ? CountryIdMap.get(commAvl.Country_Lookup__c).Country_Code2__c : '';    
            String strLangCd = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Language_Code_2__c : '';
            String strLangName = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Name : '';
                                
            if(mapRights != null && mapRights.size() > 0){ 
                String strRytGrp = mapRightsGrp.containsKey(strLangCd+'_'+strCntyCd) ? mapRightsGrp.get(strLangCd+'_'+strCntyCd) : ''; 
                                    
                if(mapRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c) || mapRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c)){
                    Rights__c ryt = (mapRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c) && !titleMPMGeneric)? 
                                         mapRights.get(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c):
                                         (mapRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c) && titleMPMGeneric)?
                                         mapRights.get(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c):null ;
                                        
                    if(ryt != null){
                        if(ConfirmedPartialAllow == 'NR' || ConfirmedPartialAllow == 'Yes' || (ryt.Status__c != 'TBA' && ryt.Status__c != 'Confirmed Partial' && ryt.Status__c != 'Tentative' && ryt.Status__c != 'Tentative Partial' &&
                        ConfirmedPartialAllow == 'No' && ryt.Status__c !='TBA Partial')){//Added 'TBA Partial' status
                            
                            if((strMPM == ryt.MPM__c || strVV ==ryt.Video_Version__c) && commAvl.Channel__c == ryt.Channel__c && strRytGrp == ryt.Rights_Group__c){ 
                                if(fstAvailDt != null){    
                                    if((fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null) || (ryt.Rights_End_5__c == null && fstAvailDt > ryt.Rights_End_4__c && ryt.Rights_End_4__c != null)  || (ryt.Rights_End_4__c == null && fstAvailDt > ryt.Rights_End_3__c && ryt.Rights_End_3__c != null) 
                                        || (ryt.Rights_End_3__c == null && fstAvailDt > ryt.Rights_End_2__c && ryt.Rights_End_2__c != null) || (ryt.Rights_End_2__c == null && fstAvailDt > ryt.Rights_End__c && ryt.Rights_End__c != null)){
                                        
                                        String reasonValue = 'Release Plan was not created since First Available Date is greater than Rights End.';
                                        WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                        
                                    }  
                                    else{
                                        
                                        if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA'
                                            ||ryt.Status__c == 'Confirmed TBA' ||ryt.Status__c == 'TBA Partial' ){ //Added 'Confirmed TBA' and 'TBA Partial' for ER-001181
                                           
                                            if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null){
                                                Date rightsStart = ryt.Rights_Start__c;
                                                Date rightsEnd = ryt.Rights_End__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,expDate,commAvl,lstCommAvail,ryt);
                                               
                                            } 
                                            if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null){
                                                Date rightsStart = ryt.Rights_Start_2__c;
                                                Date rightsEnd = ryt.Rights_End_2__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,expDate,commAvl,lstCommAvail,ryt);
                                               
                                            } 
                                            if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null){
                                                Date rightsStart = ryt.Rights_Start_3__c;
                                                Date rightsEnd = ryt.Rights_End_3__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,expDate,commAvl,lstCommAvail,ryt);
                                               
                                            } 
                                            if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null){
                                                Date rightsStart = ryt.Rights_Start_4__c;
                                                Date rightsEnd = ryt.Rights_End_4__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,expDate,commAvl,lstCommAvail,ryt);
                                               
                                            } 
                                            if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null){
                                                Date rightsStart = ryt.Rights_Start_5__c;
                                                Date rightsEnd = ryt.Rights_End_5__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,expDate,commAvl,lstCommAvail,ryt);
                                                                                                   
                                            }
                                            //Do not create release plan if no rights window.
                                            if(ryt.Rights_End__c == null){                                                                
                                            }  
                                        }
                                        if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'No Rights TBA'|| ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){                                                    
                                            String reasonValue = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights') ? 'Release plans are not created since rights status is No Right.' :(ryt.Status__c == 'No Rights TBA')?'Release plans are not created since rights status is No Rights TBA.': 'Release Plan was not created since rights have expired.';
                                            WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                                                                          
                                        }
                                    }
                                }
                                //If First avail date is blank on title only when status is Confirmed, Tentative, Confirmed Partial or TBA.
                                else if(fstAvailDt == null){
                                    
                                    if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' 
                                        || ryt.Status__c == 'TBA'  
                                        || ryt.Status__c =='TBA Partial' || ryt.Status__c == 'Confirmed TBA'){//Added 'TBA Partial' status //Added 'Confirmed TBA' status 
                                        
                                        if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null && ryt.Rights_End__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start__c;
                                            Date rightsEnd = ryt.Rights_End__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            
                                        } 
                                        if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null && ryt.Rights_End_2__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_2__c;
                                            Date rightsEnd = ryt.Rights_End_2__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                           
                                        } 
                                        if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null && ryt.Rights_End_3__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_3__c;
                                            Date rightsEnd = ryt.Rights_End_3__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        } 
                                        if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null && ryt.Rights_End_4__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_4__c;
                                            Date rightsEnd = ryt.Rights_End_4__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        } 
                                        if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null && ryt.Rights_End_5__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_5__c;
                                            Date rightsEnd = ryt.Rights_End_5__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        }     

                                    }
                                    if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' ||ryt.Status__c == 'No Rights TBA'|| ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){    
                                        String reasonValue =ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights')? 'Release plans are not created since rights status is No Right.' :(ryt.Status__c == 'No Rights TBA')? 'Release plans are not created since rights status is No Rights TBA.': 'Release Plan was not created since rights have expired.';
                                        WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                        
                                    }
                                }  
                            } 
                        }
                    }// if rights present
                }     
                else{
                    //Do not create release plan if no right found.
                    String reasonValue ='Release Plan not created since no rights are found in CAS.';
                    WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                                                           
                } 
            }
            else {  
                //Do not create release plan if MPM/VV is empty.
                rpExpnRec.Reason__c = 'Release Plan not created since either no rights are found in CAS or MPM is empty.';
                if(!system.isBatch())
                    WB_CreateReleasePlan_Controller.releasePlanExceptionList.add(rpExpnRec);
                else
                    WB_Batch_ReleasePlanWizard_New.rpExceptionPerBatch.add(rpExpnRec);
            } 
        } 
        
        return lstCommAvail;
    }
    
    public static List<Commercial_Avail__c> returnProcessedRP_case2(List<Commercial_Avail__c> commercialAvailList, User userDetail,
    Map<Id,Title__c> titleIdMap, Map<Id,Country__c> CountryIdMap, Map<Id,Language__c> languageIdMap, Integer countExcpetionRec, 
    String ConfirmedPartialAllow, Map<String,Rights__c> mapRights, Map<String, String> mapRightsGrp){
    
        List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
        for(Commercial_Avail__c commAvl : commercialAvailList)
        {  
            countExcpetionRec++;
            Release_Plan_Exceptions__c rpExpnRec = new Release_Plan_Exceptions__c();
            rpExpnRec.name = userDetail.id + string.valueof(countExcpetionRec);
            rpExpnRec.Title__c = titleIdMap.get(commAvl.Title__c).Name;
            rpExpnRec.Video_Version__c = titleIdMap.get(commAvl.Title__c).Video_Version__c;
            rpExpnRec.Country__c = CountryIdMap.get(commAvl.Country_Lookup__c).Name;                        
            rpExpnRec.User_Detail__c = userDetail.id;
                                
            String strMPM = titleIdMap.get(commAvl.Title__c).MPM__c;
            String strVV =  titleIdMap.get(commAvl.Title__c).Video_Version__c;
            Date fstAvailDt = titleIdMap.get(commAvl.Title__c).First_Available_Date__c;
            Boolean titleMPMGeneric = titleIdMap.get(commAvl.Title__c).MPM__r.Generic__c;
            //Country code
            String strCntyCd = CountryIdMap.containsKey(commAvl.Country_Lookup__c) ? CountryIdMap.get(commAvl.Country_Lookup__c).Country_Code2__c : '';    
            String strLangCd = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Language_Code_2__c : '';
            String strLangName = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Name : '';
                                
            if(mapRights != null && mapRights.size() > 0){ 
                String strRytGrp = mapRightsGrp.containsKey(strLangCd+'_'+strCntyCd) ? mapRightsGrp.get(strLangCd+'_'+strCntyCd) : ''; 
                                    
                if(mapRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c) || mapRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c)){
                    Rights__c ryt = (mapRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c) && !titleMPMGeneric)? 
                            mapRights.get(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c):
                            (mapRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c) && titleMPMGeneric)?
                            mapRights.get(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c):null ;
                                        
                    if(ryt != null){
                                            
                        if(ConfirmedPartialAllow == 'NR' || ConfirmedPartialAllow == 'Yes' || (ryt.Status__c != 'TBA' && ryt.Status__c != 'Confirmed Partial' && ryt.Status__c != 'Tentative' && ryt.Status__c != 'Tentative Partial' &&
                            ConfirmedPartialAllow == 'No' && ryt.Status__c !='TBA Partial')){
                                               
                            if((strMPM == ryt.MPM__c || strVV ==ryt.Video_Version__c) && commAvl.Channel__c == ryt.Channel__c && strRytGrp == ryt.Rights_Group__c){    
                                
                                if(fstAvailDt != null){    
                                    if((fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null) || (ryt.Rights_End_5__c == null && fstAvailDt > ryt.Rights_End_4__c && ryt.Rights_End_4__c != null)  || (ryt.Rights_End_4__c == null && fstAvailDt > ryt.Rights_End_3__c && ryt.Rights_End_3__c != null) 
                                        || (ryt.Rights_End_3__c == null && fstAvailDt > ryt.Rights_End_2__c && ryt.Rights_End_2__c != null) || (ryt.Rights_End_2__c == null && fstAvailDt > ryt.Rights_End__c && ryt.Rights_End__c != null)){
                                        
                                        String reasonValue ='Release Plan was not created since First Available Date is greater than Rights End.';
                                        WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                        
                                    }
                                    else{
                                        if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA'
                                            ||ryt.Status__c == 'Confirmed TBA' ||ryt.Status__c == 'TBA Partial' ){ //Added 'Confirmed TBA' and 'TBA Partial' for ER-001181
                                        
                                            if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null ){
                                                Date rightsStart = ryt.Rights_Start__c;
                                                Date rightsEnd = ryt.Rights_End__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                                                
                                            } 
                                            if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null ){
                                                Date rightsStart = ryt.Rights_Start_2__c;
                                                Date rightsEnd = ryt.Rights_End_2__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null ){
                                                Date rightsStart = ryt.Rights_Start_3__c;
                                                Date rightsEnd = ryt.Rights_End_3__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null ){
                                                Date rightsStart = ryt.Rights_Start_4__c;
                                                Date rightsEnd = ryt.Rights_End_4__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null ){
                                                Date rightsStart = ryt.Rights_Start_5__c;
                                                Date rightsEnd = ryt.Rights_End_5__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            }
                                            //Do not create release plan if no rights window.
                                            if(ryt.Rights_End__c == null){                                                            
                                            }  
                                        }
                                        //Do not create release plan if matching rights record status is Researching, No Rights or Expired.
                                        if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'No Rights TBA'|| ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){                                                    
                                            String reasonValue = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights') ? 'Release plans are not created since rights status is No Right.' :(ryt.Status__c == 'No Rights TBA')?'Release plans are not created since rights status is No Rights TBA.': 'Release Plan was not created since rights have expired.';
                                            WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                                                                           
                                        }
                                    }
                                }
                                //If First avail date is blank on title only when status is Confirmed, Tentative, Confirmed Partial or TBA.
                                else if(fstAvailDt == null){
                                    if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' 
                                        || ryt.Status__c == 'TBA'  
                                        || ryt.Status__c =='TBA Partial' || ryt.Status__c == 'Confirmed TBA'){//Added 'TBA Partial' status //Added 'Confirmed TBA' status 
                                        if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null && ryt.Rights_End__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start__c;
                                            Date rightsEnd = ryt.Rights_End__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        } 
                                        if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null && ryt.Rights_End_2__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_2__c;
                                            Date rightsEnd = ryt.Rights_End_2__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);               
                                        } 
                                        if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null && ryt.Rights_End_3__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_3__c;
                                            Date rightsEnd = ryt.Rights_End_3__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        } 
                                        if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null && ryt.Rights_End_4__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_4__c;
                                            Date rightsEnd = ryt.Rights_End_4__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);             
                                        } 
                                        if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null && ryt.Rights_End_5__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_5__c;
                                            Date rightsEnd = ryt.Rights_End_5__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckStartTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        }   
                                        
                                    }
                                    if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'No Rights TBA'|| ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){    
                                        String reasonValue = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights')? 'Release plans are not created since rights status is No Right.' :(ryt.Status__c == 'No Rights TBA')?'Release plans are not created since rights status is No Rights TBA.': 'Release Plan was not created since rights have expired.';
                                        WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                        
                                    }
                                }  
                            } 
                        }
                    }// if rights present
                } 
                else{
                    //Do not create release plan if no right found.
                    String reasonValue = 'Release Plan not created since no rights are found in CAS.';
                    WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                                                            
                } 
            }
            else {  
                //Do not create release plan if MPM/VV is empty.
                rpExpnRec.Reason__c = 'Release Plan not created since either no rights are found in CAS or MPM is empty.';
                if(!system.isBatch())
                    WB_CreateReleasePlan_Controller.releasePlanExceptionList.add(rpExpnRec);
                else
                    WB_Batch_ReleasePlanWizard_New.rpExceptionPerBatch.add(rpExpnRec);
            } 
        } 
        
        return lstCommAvail;
    }
    
    public static List<Commercial_Avail__c> returnProcessedRP_case3(List<Commercial_Avail__c> commercialAvailList, User userDetail,
    Map<Id,Title__c> titleIdMap, Map<Id,Country__c> CountryIdMap, Map<Id,Language__c> languageIdMap, Integer countExcpetionRec, 
    String ConfirmedPartialAllow, Map<String,Rights__c> mapRights, Map<String, String> mapRightsGrp){
        List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
        for(Commercial_Avail__c commAvl : commercialAvailList)
        {  
            countExcpetionRec++;
            Release_Plan_Exceptions__c rpExpnRec = new Release_Plan_Exceptions__c();
            rpExpnRec.name = userDetail.id + string.valueof(countExcpetionRec);
            rpExpnRec.Title__c = titleIdMap.get(commAvl.Title__c).Name;
            rpExpnRec.Video_Version__c = titleIdMap.get(commAvl.Title__c).Video_Version__c;
            rpExpnRec.Country__c = CountryIdMap.get(commAvl.Country_Lookup__c).Name;                        
            rpExpnRec.User_Detail__c = userDetail.id;
                                
            String strMPM = titleIdMap.get(commAvl.Title__c).MPM__c;
            String strVV =  titleIdMap.get(commAvl.Title__c).Video_Version__c;
            Date fstAvailDt = titleIdMap.get(commAvl.Title__c).First_Available_Date__c;
            Boolean titleMPMGeneric = titleIdMap.get(commAvl.Title__c).MPM__r.Generic__c;
                                
            String strCntyCd = CountryIdMap.containsKey(commAvl.Country_Lookup__c) ? CountryIdMap.get(commAvl.Country_Lookup__c).Country_Code2__c : '';    
            String strLangCd = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Language_Code_2__c : '';
            String strLangName = languageIdMap.containsKey(commAvl.Languages__c) ? languageIdMap.get(commAvl.Languages__c).Name : '';
                                
            if(mapRights != null && mapRights.size() > 0){ 
                String strRytGrp = mapRightsGrp.containsKey(strLangCd+'_'+strCntyCd) ? mapRightsGrp.get(strLangCd+'_'+strCntyCd) : ''; 
                if(mapRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c) || mapRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c)){
                    
                    Rights__c ryt = (mapRights.containsKey(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c) && !titleMPMGeneric)? 
                                    mapRights.get(strMPM+'_'+strRytGrp+'_'+commAvl.Channel__c):
                                    (mapRights.containsKey(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c) && titleMPMGeneric)?
                                    mapRights.get(strVV+'_'+strRytGrp+'_'+commAvl.Channel__c):null ;
                                        
                    if(ryt != null){
                        if(ConfirmedPartialAllow == 'NR' || ConfirmedPartialAllow == 'Yes' || (ryt.Status__c != 'TBA' && ryt.Status__c != 'Confirmed Partial' && ryt.Status__c != 'Tentative' && ryt.Status__c != 'Tentative Partial' &&
                            ConfirmedPartialAllow == 'No' && ryt.Status__c !='TBA Partial')){
                            
                            if((strMPM == ryt.MPM__c || strVV ==ryt.Video_Version__c) && commAvl.Channel__c == ryt.Channel__c && strRytGrp == ryt.Rights_Group__c){  
                                if(fstAvailDt != null){    
                                    //Do not create a release plan if First Avail Date id greater than all the right window of matching rights record.
                                    if((fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null) || (ryt.Rights_End_5__c == null && fstAvailDt > ryt.Rights_End_4__c && ryt.Rights_End_4__c != null)  || (ryt.Rights_End_4__c == null && fstAvailDt > ryt.Rights_End_3__c && ryt.Rights_End_3__c != null) 
                                        || (ryt.Rights_End_3__c == null && fstAvailDt > ryt.Rights_End_2__c && ryt.Rights_End_2__c != null) || (ryt.Rights_End_2__c == null && fstAvailDt > ryt.Rights_End__c && ryt.Rights_End__c != null)){
                                        
                                        String reasonValue = 'Release Plan was not created since First Available Date is greater than Rights End.';
                                        WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                    }  
                                    else{
                                        if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'TBA'
                                            ||ryt.Status__c == 'Confirmed TBA' ||ryt.Status__c == 'TBA Partial' ){ //Added 'Confirmed TBA' and 'TBA Partial' for ER-001181
                                            
                                            if(ryt.Rights_Start__c!=null && ryt.Rights_End__c != null){
                                                Date rightsStart = ryt.Rights_Start__c;
                                                Date rightsEnd = ryt.Rights_End__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null){
                                                Date rightsStart = ryt.Rights_Start_2__c;
                                                Date rightsEnd = ryt.Rights_End_2__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null){
                                                Date rightsStart = ryt.Rights_Start_3__c;
                                                Date rightsEnd = ryt.Rights_End_3__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null){
                                                Date rightsStart = ryt.Rights_Start_4__c;
                                                Date rightsEnd = ryt.Rights_End_4__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                            } 
                                            if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null){
                                                Date rightsStart = ryt.Rights_Start_5__c;
                                                Date rightsEnd = ryt.Rights_End_5__c;
                                                WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcFAD(fstAvailDt,rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);                                                          
                                            }
                                            //Do not create release plan if no rights window.
                                            if(ryt.Rights_End__c == null){                                                          
                                            }  
                                        }
                                        //Do not create release plan if matching rights record status is Researching, No Rights or Expired.
                                        if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'No Rights TBA'|| ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){                                                    
                                            String reasonValue = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights') ? 'Release plans are not created since rights status is No Right.' :(ryt.Status__c == 'No Rights TBA')?'Release plans are not created since rights status is No Rights TBA.': 'Release Plan was not created since rights have expired.';
                                            WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                                                                            
                                        }
                                    }
                                }
                                //If First avail date is blank on title only when status is Confirmed, Tentative, Confirmed Partial or TBA.
                                else if(fstAvailDt == null){
                                    if(ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Tentative Partial' 
                                       || ryt.Status__c == 'TBA'  
                                       || ryt.Status__c =='TBA Partial' || ryt.Status__c == 'Confirmed TBA'){//Added 'TBA Partial' status //Added 'Confirmed TBA' status 
                                                        
                                        Boolean flag=ryt.Rights_End__c >= System.Today();
                                        if(ryt.Rights_Start__c != null && ryt.Rights_End__c != null && ryt.Rights_End__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start__c;
                                            Date rightsEnd = ryt.Rights_End__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                                            
                                        } 
                                        if(ryt.Rights_Start_2__c != null && ryt.Rights_End_2__c != null && ryt.Rights_End_2__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_2__c;
                                            Date rightsEnd = ryt.Rights_End_2__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                                            
                                        } 
                                        if(ryt.Rights_Start_3__c != null && ryt.Rights_End_3__c != null && ryt.Rights_End_3__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_3__c;
                                            Date rightsEnd = ryt.Rights_End_3__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                                            
                                        } 
                                        if(ryt.Rights_Start_4__c != null && ryt.Rights_End_4__c != null && ryt.Rights_End_4__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_4__c;
                                            Date rightsEnd = ryt.Rights_End_4__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                        } 
                                        if(ryt.Rights_Start_5__c != null && ryt.Rights_End_5__c != null && ryt.Rights_End_5__c >= System.Today()){
                                            Date rightsStart = ryt.Rights_Start_5__c;
                                            Date rightsEnd = ryt.Rights_End_5__c;
                                            WB_CreateReleasePLan_Helper.rightsCheckEndTrueDatesCalcNoFAD(rightsEnd,rightsStart,commAvl,ryt,lstCommAvail);
                                                            
                                        }     
                                    }
                                    if(ryt.Status__c == 'Researching' || ryt.Status__c == 'No Rights' || ryt.Status__c == 'No Rights TBA'|| ryt.Status__c == 'Expired' || ryt.RT_Lifecycle__c == 'History Expired' || ryt.RT_Lifecycle__c == 'Active No Rights'){    
                                        String reasonValue = ryt.Status__c == 'Researching' ? 'Release Plan was not created since the rights have Researching status.' : (ryt.Status__c == 'No Rights' || ryt.RT_Lifecycle__c == 'Active No Rights')? 'Release plans are not created since rights status is No Right.' :(ryt.Status__c == 'No Rights TBA')?'Release plans are not created since rights status is No Rights TBA.': 'Release Plan was not created since rights have expired.';
                                        WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                       
                                    }
                                }  
                            } 
                        }
                    }// if rights present
                } 
                else{
                    //Do not create release plan if no right found.
                    String reasonValue = 'Release Plan not created since no rights are found in CAS.';
                    WB_CreateReleasePLan_Helper.rpExceptioHandling(rpExpnRec,strLangName,commAvl,reasonValue);
                                                                    
                } 
            }
            else {  
                //Do not create release plan if MPM/VV is empty.
                rpExpnRec.Reason__c = 'Release Plan not created since either no rights are found in CAS or MPM is empty.';
                if(!system.isBatch())
                    WB_CreateReleasePlan_Controller.releasePlanExceptionList.add(rpExpnRec);
                else
                    WB_Batch_ReleasePlanWizard_New.rpExceptionPerBatch.add(rpExpnRec);
            } 
        } 
                                               
        return lstCommAvail;
    }

    public static void assignRPValues(Commercial_Avail__c commAvl,Rights__c ryt,Commercial_Avail__c commAvlNew){
        commAvlNew.Country_Lookup__c = commAvl.Country_Lookup__c;
        //ER-006428 - Automated Release Date Based on Theatrical Window - Start
        commAvlNew.RP_AutoCalc__c = commAvl.RP_AutoCalc__c;
        commAvlNew.GPP_Avail_Start__c = commAvl.GPP_Avail_Start__c; 
        //ER-006428 - Automated Release Date Based on Theatrical Window - End
        commAvlNew.Format__c = commAvl.Format__c;
        commAvlNew.Title__c = commAvl.Title__c;
        commAvlNew.Language_Type__c = commAvl.Language_Type__c;
        commAvlNew.Languages__c = commAvl.Languages__c;
        commAvlNew.Channel__c = commAvl.Channel__c;
        commAvlNew.Comments__c = commAvl.Comments__c;
        commAvlNew.Rights_ID__c = ryt.Id;
        commAvlNew.Reason_Code__c = null;
    }

    public static void rightsCheckStartEndTrueDatesCalcFAD(Date fstAvailDt,Date rightsEnd,Date rightsStart,Date expDate,Commercial_Avail__c commAvl,List<Commercial_Avail__c> lstCommAvail,Rights__c ryt){
        Boolean isTrue = false;
        Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
        WB_CreateReleasePLan_Helper.assignRPValues(commAvl,ryt,commAvlNew);
        commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                ) ? 'Open' : 'Draft'; 

        if((fstAvailDt <= rightsEnd && rightsEnd >= System.Today()) || (rightsEnd >= System.Today())){
            if(expDate!=null){
                commAvlNew.Rights_End__c = expDate < rightsEnd ? expDate : rightsEnd;
            }
            else{
                commAvlNew.Rights_End__c = rightsEnd;
            }
        }
                        
        if(fstAvailDt >= rightsStart && fstAvailDt <= rightsEnd && rightsEnd >= System.Today()){
            commAvlNew.Exclusive_Date__c = fstAvailDt;
            isTrue = true;
        }
        else if(fstAvailDt < rightsStart && rightsEnd >= System.Today()){
            commAvlNew.Exclusive_Date__c = rightsStart;
            isTrue = true;
        }

        if(isTrue){
            commAvlNew.Start_Date__c = commAvlNew.Exclusive_Date__c;
            commAvlNew.End_Date__c = commAvlNew.Rights_End__c;
            lstCommAvail.add(commAvlNew);
        }
        
    }

    public static void rightsCheckStartEndTrueDatesCalcNoFAD(Date rightsEnd,Date rightsStart,Commercial_Avail__c commAvl,Rights__c ryt,List<Commercial_Avail__c> lstCommAvail){

        Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
        WB_CreateReleasePLan_Helper.assignRPValues(commAvl,ryt,commAvlNew);
        commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial' || ryt.Status__c == 'Confirmed TBA'
                                ) ? 'Open' : 'Draft'; 
        commAvlNew.Exclusive_Date__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : rightsStart;//Added 'TBA Partial' status
        commAvlNew.Rights_End__c = (ryt.Status__c == 'TBA' || ryt.Status__c =='TBA Partial') ? null : rightsEnd;//Added 'TBA Partial' status
        commAvlNew.Start_Date__c = commAvlNew.Exclusive_Date__c;
        commAvlNew.End_Date__c = commAvlNew.Rights_End__c;
        lstCommAvail.add(commAvlNew);
        
    }

    public static void rightsCheckStartTrueDatesCalcFAD(Date fstAvailDt,Date rightsEnd,Date rightsStart,Commercial_Avail__c commAvl,Rights__c ryt,List<Commercial_Avail__c> lstCommAvail){

        Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
        WB_CreateReleasePLan_Helper.assignRPValues(commAvl,ryt,commAvlNew);
        commAvlNew.End_Date__c=commAvl.End_Date__c;
        commAvlNew.Rights_End__c = commAvl.Rights_End__c;
        commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial') ? 'Open' : 'Draft'; 
                                             
        Boolean isTrue = false;
        if(fstAvailDt >= rightsStart && fstAvailDt <= rightsEnd && rightsEnd >= System.Today()){
            commAvlNew.Exclusive_Date__c = fstAvailDt;  
            isTrue = true;
        }    
        else if(fstAvailDt < rightsStart && rightsEnd >= System.Today()){
            commAvlNew.Exclusive_Date__c = rightsStart; 
            isTrue = true; 
        }

        if(isTrue){
            commAvlNew.Start_Date__c = commAvlNew.End_Date__c!=null?commAvlNew.Exclusive_Date__c:null;
            lstCommAvail.add(commAvlNew);
        }
       
    }

    public static void rightsCheckStartTrueDatesCalcNoFAD(Date rightsEnd,Date rightsStart,Commercial_Avail__c commAvl,Rights__c ryt,List<Commercial_Avail__c> lstCommAvail){
        Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
        WB_CreateReleasePLan_Helper.assignRPValues(commAvl,ryt,commAvlNew);
        commAvlNew.End_Date__c=commAvl.End_Date__c;
        commAvlNew.Rights_End__c = commAvl.Rights_End__c;
        commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial') ? 'Open' : 'Draft'; 
        
        Boolean isTrue = false;
        if(commAvl.Exclusive_Date__c >= rightsStart && commAvl.Exclusive_Date__c <= rightsEnd && rightsEnd >= System.Today()){
            commAvlNew.Exclusive_Date__c =commAvl.Exclusive_Date__c;
            isTrue = true; 
        }    
        else if(commAvl.Exclusive_Date__c < rightsStart && rightsEnd >= System.Today()){
            commAvlNew.Exclusive_Date__c=rightsStart; 
            isTrue = true; 
        }

        if(isTrue){
            commAvlNew.Start_Date__c = commAvlNew.End_Date__c!=null?commAvlNew.Exclusive_Date__c:null;
            lstCommAvail.add(commAvlNew);
        }

    }
    
    public static void rightsCheckEndTrueDatesCalcFAD(Date fstAvailDt,Date rightsEnd,Date rightsStart,Commercial_Avail__c commAvl,Rights__c ryt,List<Commercial_Avail__c> lstCommAvail){

        Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
        WB_CreateReleasePLan_Helper.assignRPValues(commAvl,ryt,commAvlNew);
        commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial') ? 'Open' : 'Draft';  
        commAvlNew.Exclusive_Date__c =commAvl.Exclusive_Date__c;
        commAvlNew.Start_Date__c = commAvl.Start_Date__c;
        Boolean isTrue = false;

        if(fstAvailDt >=rightsStart && fstAvailDt <= rightsEnd && rightsEnd >= System.Today()){
            commAvlNew.Rights_End__c= commAvl.Rights_End__c< rightsEnd?commAvl.Rights_End__c:rightsEnd;
            isTrue = true; 
        }    
        else if(fstAvailDt < rightsStart && rightsEnd >= System.Today()){
            commAvlNew.Rights_End__c= commAvl.Rights_End__c< rightsEnd?commAvl.Rights_End__c:rightsEnd;
            isTrue = true; 
        }

        if(isTrue){
            if(commAvlNew.Start_Date__c!=null)
                commAvlNew.End_Date__c=commAvlNew.Rights_End__c;
            else    
                commAvlNew.End_Date__c=null;
            lstCommAvail.add(commAvlNew);
        }
    }

    public static void rightsCheckEndTrueDatesCalcNoFAD(Date rightsEnd,Date rightsStart,Commercial_Avail__c commAvl,Rights__c ryt,List<Commercial_Avail__c> lstCommAvail){
        Commercial_Avail__c commAvlNew = new Commercial_Avail__c();
        WB_CreateReleasePLan_Helper.assignRPValues(commAvl,ryt,commAvlNew);
        commAvlNew.Status__c = (ryt.Status__c == 'Confirmed' || ryt.Status__c == 'Tentative' || ryt.Status__c == 'Tentative Partial' || ryt.Status__c == 'Confirmed Partial') ? 'Open' : 'Draft';  
        commAvlNew.Exclusive_Date__c =commAvl.Exclusive_Date__c;
        commAvlNew.Start_Date__c = commAvl.Start_Date__c;
        Boolean isTrue = false;

        if(commAvl.Exclusive_Date__c>= rightsStart && commAvl.Exclusive_Date__c <= rightsEnd && rightsEnd >= System.Today()){
            commAvlNew.Rights_End__c= commAvl.Rights_End__c<rightsEnd?commAvl.Rights_End__c:rightsEnd;
            isTrue = true; 
        }
        else if(commAvl.Exclusive_Date__c < rightsStart && rightsEnd >= System.Today()){
            commAvlNew.Rights_End__c= commAvl.Rights_End__c<rightsEnd?commAvl.Rights_End__c:rightsEnd;
            isTrue = true; 
                            
        } 

        if(isTrue){
            if(commAvlNew.Start_Date__c!=null)
                commAvlNew.End_Date__c=commAvlNew.Rights_End__c;
            else    
                commAvlNew.End_Date__c=null;
            lstCommAvail.add(commAvlNew);
        }
    }

    public static void rpExceptioHandling(Release_Plan_Exceptions__c rpExpnRec,String strLangName,Commercial_Avail__c commAvl,String reasonValue){
        rpExpnRec.Language__c = strLangName;
        rpExpnRec.Channel__c = commAvl.Channel__c;
        rpExpnRec.Format__c = commAvl.Format__c;
        rpExpnRec.Reason__c = reasonValue;
        if(!system.isBatch())
            WB_CreateReleasePlan_Controller.releasePlanExceptionList.add(rpExpnRec);
        else
            WB_Batch_ReleasePlanWizard_New.rpExceptionPerBatch.add(rpExpnRec);
    }

}