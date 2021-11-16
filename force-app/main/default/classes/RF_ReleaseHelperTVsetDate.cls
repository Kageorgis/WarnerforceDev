// W-017691:  DCHO
public class RF_ReleaseHelperTVsetDate {
    
    public static sObject setDefaultDateOnInsert(sObject newrec1, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap){
        
        String streetDate_ApiNm= 'Street_Date__c';
        String isPhysical_ApiNm= 'IsPhysical__c';
        
        
        if(newrec1.get(streetDate_ApiNm)!=null){
            newrec1.put(isPhysical_ApiNm,true);
        }
        if(newrec1.get(streetDate_ApiNm)==null){
            newrec1.put(isPhysical_ApiNm,false);
        }
        
        String ESTDateTVLabel= 'EST_Date_TV';
        String ESTDateTV_ApiName = releaseDefaultLabelMap.get(ESTDateTVLabel).Source_Field__c;
        String PremiereDate_ApiName = releaseDefaultLabelMap.get(ESTDateTVLabel).Destination_Field__c;
        String FinaleDate_ApiName = 'Finale_Date__c';
        String DigitalCategory_ApiNm= 'Digital_Category__c';
        String AnnouncedateLabel= 'Announce_Trade_PR';
        
        // Update EST Date        
        if(newrec1.get(ESTDateTV_ApiName)==null && releaseDefaultLabelMap.get(ESTDateTVLabel)!=null){
            if(newrec1.get(PremiereDate_ApiName)!=null && newrec1.get(DigitalCategory_ApiNm)=='Next Day Air (NDA)'){
                Date PremiereDate = Date.ValueOf(newrec1.get(releaseDefaultLabelMap.get(ESTDateTVLabel).Destination_Field__c));             
                newrec1.put(ESTDateTV_ApiName,PremiereDate.addDays(Integer.ValueOf(releaseDefaultLabelMap.get(ESTDateTVLabel).Calculation__c)));
            } else if (newrec1.get(FinaleDate_ApiName)!=null && newrec1.get(DigitalCategory_ApiNm)=='Day After Finale'){
                Date FinaleDate = Date.ValueOf(newrec1.get(FinaleDate_ApiName));             
                newrec1.put(ESTDateTV_ApiName,FinaleDate.addDays(Integer.ValueOf(releaseDefaultLabelMap.get(ESTDateTVLabel).Calculation__c)));
            }            
        }
        
        // Update Pre-Order EST Date
        if (newrec1.get('Pre_Order_EST_Date__c')==null && newrec1.get('EST_Date__c')!=null && newrec1.get('Pre_Order_Logic__c')!=null){
            updatePreOrderDate(newrec1, Date.ValueOf(newrec1.get('EST_Date__c')), String.ValueOf(newrec1.get('Pre_Order_Logic__c')));
        }
        
        // Update Order Due Date
        if (newrec1.get('Order_Due_Date__c')==null && newrec1.get('Street_Date__c')!=null && newrec1.get('Country_List__c')!=null) {
            updateOrderDueDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        // Update Announce Date PR
        if (newrec1.get('Announce_Trade_PR__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateAnnounceDatePR(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        if (newrec1.get('Mechs_Due__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateMecksdue(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        if (newrec1.get('Send_Media_SD__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateMediaSD(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        
        if (newrec1.get('Artwork_Delivery_Due_Date__c')==null && newrec1.get('Premiere_Date__c')!=null ) {
            updateartworkdate(newrec1, Date.ValueOf(newrec1.get('Premiere_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
         if (newrec1.get('WW_Creative_Kick_Off__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateWWkickoff(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        // Update Digital Copy Expiration Date
        if (newrec1.get('Digital_Copy_Expiration_Date__c')==null && newrec1.get('Digital_Copy__c')==true && newrec1.get('Street_Date__c')!=null) {
            updateDigitalCopyExpirationDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')));       
        }
		        
        // Update Trade Email Date = street date - 84 - @Kalash
        if (newrec1.get('Premium_Release_Announce_Date__c')==null && newrec1.get('Street_Date__c')!=null) {
            updateTradeEmailDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        /*consumer announce date = street date - 84 - @Kalash*/
        if (newrec1.get('Trade_Solicitation_Date__c')==null && newrec1.get('Street_Date__c')!=null){
            updateTradeSolicitationDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        /*In plant date = street date - 70 - @Kalash*/
        if (newrec1.get('In_Plant_Date__c')==null && newrec1.get('Street_Date__c')!=null){
            updateInPlantDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        /*selling guide due date = street date - 5 months - @Kalash*/
        if (newrec1.get('Selling_Guides_Due_Date__c')==null && newrec1.get('Street_Date__c')!=null){
            updateSellingGuideDueDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        /*trade asset due to jv date = Trade Email Date - 10 days - @Kalash*/
        if (newrec1.get('Trade_Assets_Due_to_JV_Date__c')==null && newrec1.get('Premium_Release_Announce_Date__c')!=null){
            updateTradeAssetDueToJVDate(newrec1, Date.ValueOf(newrec1.get('Premium_Release_Announce_Date__c')), releaseDefaultLabelMap);       
        }
        if(newrec1.get('Street_Date__c')!=NULL){
            //date announcedate = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-119);
            //date sendmediadate = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-112);
            //date mechsdue = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-77);
            //date ww_creative_kickoff = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-180);
            //newrec1.put('Announce_Trade_PR__c',announcedate);
          //  newrec1.put('Send_Media_SD__c',sendmediadate);
            //newrec1.put('Mechs_Due__c', mechsdue);
            //newrec1.put('WW_Creative_Kick_Off__c', ww_creative_kickoff);
        }
        
        
        
        
        return newrec1;
    }
    
    /*ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
    User should be able to clear off dependent fields like PVOD date, PEST and able to save record successfully.*/
    public static void setdateonupdate(SObject newrec1,Map<Id, SObject> oldReleaseMap,Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap,Map< String, String > destinationfieldMap,Map< String, Decimal > releaseDateDefaultsMap,Map< String, String > sourcefieldMap,Map< String, String > calculatedfieldMap,Map< String, String > calculatedfield_operation_Map){
        RELEASE__c newrec = (RELEASE__c) newrec1;
        RELEASE__c oldrec = (RELEASE__c)oldReleaseMap.get(newrec.Id);
        SObject oldrec1 = (SObject)oldReleaseMap.get(newrec.Id);
         String streetDate_ApiNm= 'Street_Date__c';
        String isPhysical_ApiNm= 'IsPhysical__c';
        
        
        if(newrec1.get(streetDate_ApiNm)!=null){
            newrec1.put(isPhysical_ApiNm,true);
        }
        if(newrec1.get(streetDate_ApiNm)==null){
            newrec1.put(isPhysical_ApiNm,false);
        }
        
        // Update Order Due Date
        if (newrec.Street_Date__c!=null && newrec.Street_Date__c!=oldrec.Street_Date__c) {
            updateOrderDueDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        
        // Update Digital Copy Expiration Date
        if (newrec.Digital_Copy__c==true && newrec.Street_Date__c!=null &&
            (newrec.Street_Date__c!=oldrec.Street_Date__c || newrec.Digital_Copy__c!=oldrec.Digital_Copy__c)) {
                updateDigitalCopyExpirationDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')));             
            }
        if (newrec1.get('Announce_Trade_PR__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateAnnounceDatePR(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        
        if (newrec1.get('Mechs_Due__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateMecksdue(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        
        if (newrec1.get('Send_Media_SD__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateMediaSD(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
         if (newrec1.get('WW_Creative_Kick_Off__c')==null && newrec1.get('Street_Date__c')!=null ) {
            updateMediaSD(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        if (newrec1.get('Artwork_Delivery_Due_Date__c')==null && newrec1.get('Premiere_Date__c')!=null ) {
            updateartworkdate(newrec1, Date.ValueOf(newrec1.get('Premiere_Date__c')),String.ValueOf(newrec1.get('Country_List__c')), releaseDefaultLabelMap);       
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
        /*Trade Email date = street date - 84 - @Kalash*/
        if ((newrec1.get('Premium_Release_Announce_Date__c')==null && newrec.Street_Date__c!=oldrec.Street_Date__c)
        	||(newrec1.get('Premium_Release_Announce_Date__c')!=null && newrec.Street_Date__c!=oldrec.Street_Date__c)){
            if(newrec.Street_Date__c != Null)
           		 updateTradeEmailDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
         /*consumer announce date = street date - 84 - @Kalash*/
        if ((newrec1.get('Trade_Solicitation_Date__c')==null && newrec.Street_Date__c!=oldrec.Street_Date__c)
        	||(newrec1.get('Trade_Solicitation_Date__c')!=null && newrec.Street_Date__c!=oldrec.Street_Date__c)){
            if(newrec.Street_Date__c != Null)
           		 updateTradeSolicitationDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
         /*in plant date = street date - 70 - @Kalash*/
        if ((newrec1.get('In_Plant_Date__c')==null && newrec.Street_Date__c!=oldrec.Street_Date__c)
        	||(newrec1.get('In_Plant_Date__c')!=null && newrec.Street_Date__c!=oldrec.Street_Date__c)){
            if(newrec.Street_Date__c != Null)
           		 updateInPlantDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
         /*selling guide due date = street date - 5 months - @Kalash*/
        if ((newrec1.get('Selling_Guides_Due_Date__c')==null && newrec.Street_Date__c!=oldrec.Street_Date__c) 
        	||(newrec1.get('Selling_Guides_Due_Date__c')!=null && newrec.Street_Date__c!=oldrec.Street_Date__c)){
            if(newrec.Street_Date__c != Null)
           		 updateSellingGuideDueDate(newrec1, Date.ValueOf(newrec1.get('Street_Date__c')), releaseDefaultLabelMap);       
        }
        //ER-007374 : RF - Date defaulting - Ability to update dependent date fields to blank
         /*Trade_Assets_Due_to_JV_Date__c = Trade Email Date - 10 days - @Kalash*/
        if ((newrec1.get('Trade_Assets_Due_to_JV_Date__c')==null && newrec.Premium_Release_Announce_Date__c!=oldrec.Premium_Release_Announce_Date__c)
        	||(newrec1.get('Trade_Assets_Due_to_JV_Date__c')!=null && newrec.Premium_Release_Announce_Date__c!=oldrec.Premium_Release_Announce_Date__c)){
            if(newrec.Premium_Release_Announce_Date__c != Null)
           		 updateTradeAssetDueToJVDate(newrec1, Date.ValueOf(newrec1.get('Premium_Release_Announce_Date__c')), releaseDefaultLabelMap);       
        }
        if(newrec1.get('Street_Date__c')!=NULL){
            //date announcedate = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-119);
            //date sendmediadate = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-112);
            //date mechsdue = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-77);
            //date ww_creative_kickoff = Date.ValueOf(newrec1.get('Street_Date__c')).addDays(-180);
            // newrec1.put('Announce_Trade_PR__c',announcedate);
            //newrec1.put('Send_Media_SD__c',sendmediadate);
         //   newrec1.put('Mechs_Due__c', mechsdue);
            //newrec1.put('WW_Creative_Kick_Off__c', ww_creative_kickoff);
        }
        
        
        // Update EST Date
        if (newrec.Digital_Category__c=='Next Day Air (NDA)' && newrec.Premiere_Date__c!=null
            && (newrec.Digital_Category__c!=oldrec.Digital_Category__c || newrec.Premiere_Date__c!=oldrec.Premiere_Date__c)){             
                Integer days = Integer.ValueOf(releaseDefaultLabelMap.get('EST_Date_TV').Calculation__c);
                newrec.EST_Date__c = newrec.Premiere_Date__c + days;
            } else if (newrec.Digital_Category__c=='Day After Finale' && newrec.Finale_Date__c!=null
                       && (newrec.Digital_Category__c!=oldrec.Digital_Category__c || newrec.Finale_Date__c!=oldrec.Finale_Date__c)){             
                           Integer days = Integer.ValueOf(releaseDefaultLabelMap.get('EST_Date_TV').Calculation__c);
                           newrec.EST_Date__c = newrec.Finale_Date__c + days;
                       }    
        
        // Update Pre-Order EST Date
        if (newrec.EST_Date__c!=null && newrec.Pre_Order_Logic__c!=null
            && (newrec.EST_Date__c!=oldrec.EST_Date__c || newrec.Pre_Order_Logic__c!=oldrec.Pre_Order_Logic__c)){
                updatePreOrderDate(newrec1, Date.ValueOf(newrec1.get('EST_Date__c')), String.ValueOf(newrec1.get('Pre_Order_Logic__c')));            
            }		
        
    }
    
    
    public static void updateDigitalCopyExpirationDate (sObject newrec1, Date streetDate) {
        Integer monthStreetDate = streetDate.month();
        Integer newYear = streetDate.year() + 1;
        Date newDate;
        
        if (monthStreetDate==1 || monthStreetDate==2 || monthStreetDate==3){
            newDate = date.newinstance(newYear, 3, 31);
        } else if (monthStreetDate==4 || monthStreetDate==5 || monthStreetDate==6){
            newDate = date.newinstance(newYear, 6, 30);
        } else if (monthStreetDate==7 || monthStreetDate==8 || monthStreetDate==9){
            newDate = date.newinstance(newYear, 9, 30);
        } else if (monthStreetDate==10 || monthStreetDate==11 || monthStreetDate==12){
            newDate = date.newinstance(newYear, 12, 31);
        }
        
        if (newDate!=null) {
            newrec1.put('Digital_Copy_Expiration_Date__c',newDate);
        }
    }
    
    
    public static void updateAnnounceDatePR(sObject newrec1, Date streetDate, String country, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;
        
        
        days = Integer.ValueOf(releaseDefaultLabelMap.get('Announce_Trade_PR').Calculation__c);
        
        
        if (days!=null){
            newrec1.put('Announce_Trade_PR__c',streetDate.addDays(days));
        }        
    }
    
    public static void updateMecksdue(sObject newrec1, Date streetDate, String country, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;

        days = Integer.ValueOf(releaseDefaultLabelMap.get('Mechs_Due').Calculation__c);
        if (days!=null){
            newrec1.put('Mechs_Due__c',streetDate.addDays(days));
        }        
    }
     public static void updateWWkickoff(sObject newrec1, Date streetDate, String country, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;

        days = Integer.ValueOf(releaseDefaultLabelMap.get('WW_Creative_Kick_Off_TV').Calculation__c);
        if (days!=null){
            newrec1.put('WW_Creative_Kick_Off__C',streetDate.addDays(days));
        }        
    }
    
    public static void updateMediaSD(sObject newrec1, Date streetDate, String country, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;

        days = Integer.ValueOf(releaseDefaultLabelMap.get('Send_Media_SD').Calculation__c);
        if (days!=null){
            newrec1.put('Send_Media_SD__c',streetDate.addDays(days));
        }        
    }    
    
    public static void updateartworkdate(sObject newrec1, Date premierdate, String country, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;

        days = Integer.ValueOf(releaseDefaultLabelMap.get('Artwork_Delivery_Due_Date').Calculation__c);
        if (days!=null){
            newrec1.put('Artwork_Delivery_Due_Date__c',premierdate.addDays(days));
        }        
    }    
    
    
    public static void updateOrderDueDate (sObject newrec1, Date streetDate, String country, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;
        
        if (country=='USA') {
            days = Integer.ValueOf(releaseDefaultLabelMap.get('Order_Due_Date_TV_US').Calculation__c);
        } else if (country=='Canada') {
            days = Integer.ValueOf(releaseDefaultLabelMap.get('Order_Due_Date_TV_CA').Calculation__c);
        }
        
        if (days!=null){
            newrec1.put('Order_Due_Date__c',streetDate.addDays(days));
        }        
    }
    
    
    public static void updatePreOrderDate (sObject newrec1, Date dateEST, String poLogic){
        DateTime dateTimeEST = DateTime.newInstance(dateEST, Time.newInstance(0,0,0,0));
        String dayOfWeek = dateTimeEST.format('E');
        Date newDate;
        
        switch on poLogic {
            when '1 week' {
                switch on dayOfWeek {
                    when 'Sun' {
                        newDate = dateEST.addDays(-6);
                    }
                    when 'Mon' {
                        newDate = dateEST.addDays(-7);
                    }
                    when 'Tue' {
                        newDate = dateEST.addDays(-1);
                    }
                    when 'Wed' {
                        newDate = dateEST.addDays(-2);
                    }
                    when 'Thu' {
                        newDate = dateEST.addDays(-3);
                    }
                    when 'Fri' {
                        newDate = dateEST.addDays(-4);
                    }
                    when 'Sat' {
                        newDate = dateEST.addDays(-5);
                    }                    
                }
            }
            when '2 week' {
                switch on dayOfWeek {
                    when 'Sun' {
                        newDate = dateEST.addDays(-13);
                    }
                    when 'Mon' {
                        newDate = dateEST.addDays(-14);
                    }
                    when 'Tue' {
                        newDate = dateEST.addDays(-8);
                    }
                    when 'Wed' {
                        newDate = dateEST.addDays(-9);
                    }
                    when 'Thu' {
                        newDate = dateEST.addDays(-10);
                    }
                    when 'Fri' {
                        newDate = dateEST.addDays(-11);
                    }
                    when 'Sat' {
                        newDate = dateEST.addDays(-12);
                    }                    
                }
            }
            when '3 week' {
                switch on dayOfWeek {
                    when 'Sun' {
                        newDate = dateEST.addDays(-20);
                    }
                    when 'Mon' {
                        newDate = dateEST.addDays(-21);
                    }
                    when 'Tue' {
                        newDate = dateEST.addDays(-15);
                    }
                    when 'Wed' {
                        newDate = dateEST.addDays(-16);
                    }
                    when 'Thu' {
                        newDate = dateEST.addDays(-17);
                    }
                    when 'Fri' {
                        newDate = dateEST.addDays(-18);
                    }
                    when 'Sat' {
                        newDate = dateEST.addDays(-19);
                    }                    
                }
            }
            when '4 week' {
                switch on dayOfWeek {
                    when 'Sun' {
                        newDate = dateEST.addDays(-27);
                    }
                    when 'Mon' {
                        newDate = dateEST.addDays(-28);
                    }
                    when 'Tue' {
                        newDate = dateEST.addDays(-22);
                    }
                    when 'Wed' {
                        newDate = dateEST.addDays(-23);
                    }
                    when 'Thu' {
                        newDate = dateEST.addDays(-24);
                    }
                    when 'Fri' {
                        newDate = dateEST.addDays(-25);
                    }
                    when 'Sat' {
                        newDate = dateEST.addDays(-26);
                    }                    
                }
            }
            when else {
                System.debug('default');
            }            
        }
        if (newDate!=null) {
            newrec1.put('Pre_Order_EST_Date__c',newDate);
        }
        //system.debug('dateEST: ' + dateEST.format() + ' dateTimeEST: ' + dateTimeEST.format() + ' dayOfWeek: ' + dayOfWeek + ' newDate: ' + newDate.format());
    }
    
    public static void updateChildMRPMaterials(Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        List<Release_Planning_Release__c> materials = 
            [SELECT Id, Avail_Date_Formula__c, Avail_Date__c, Release__c, RecordType.Name FROM Release_Planning_Release__c 
             WHERE Release__c IN :newReleaseMap.keyset()
             AND RecordType.Name IN ('Digital Film Store', 'Digital TV Store')]; 
        
        if (materials.size()>0) {
            for(Id rel:newReleaseMap.keySet()){
                RELEASE__c newrec = (RELEASE__c)newReleaseMap.get(rel);   
                RELEASE__c oldrec = (RELEASE__c)oldReleaseMap.get(rel);
                
                if(newrec.Record_Type_Name__c=='TV' && 
                   (newrec.Pre_Order_EST_Date__c!=oldrec.Pre_Order_EST_Date__c
                    || newrec.Content_Type__c!=oldrec.Content_Type__c
                    || newrec.Digital_Category__c!=oldrec.Digital_Category__c)
                   || newrec.EST_Date__c!=oldrec.EST_Date__c){
                       
                       for (Release_Planning_Release__c m:materials){
                           if(m.Release__c==newrec.Id){
                               m.Avail_Date__c = m.Avail_Date_Formula__c;
                               system.debug('Release Name: ' + newrec.Name + ' Material Avail Date Formula: ' + String.valueOf(m.Avail_Date_Formula__c)
                                            + ' Material Avail Date: ' + String.valueOf(m.Avail_Date__c) + ' Pre Order Date: ' + String.valueOf(newrec.Pre_Order_EST_Date__c)
                                            + ' EST Date: ' + String.valueOf(newrec.EST_Date__c)); 
                           }
                       }        
                   }            
            }	    
            update materials;
        }
    }
    /*update trade email date = street date - 84 - @Kalash*/
    public static void updateTradeEmailDate(sObject newrec1, Date streetDate, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;
        
        days = Integer.ValueOf(releaseDefaultLabelMap.get('Premium_Release_Announce_Date_tv').Calculation__c);
        
        
        if (days!=null){
            newrec1.put(releaseDefaultLabelMap.get('Premium_Release_Announce_Date_tv').Source_Field__c,streetDate.addDays(days));
        }        
    }
    
     /*update trade solicitation date = street date - 84 - @Kalash*/
    public static void updateTradeSolicitationDate(sObject newrec1, Date streetDate, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;
        
        days = Integer.ValueOf(releaseDefaultLabelMap.get('Trade_Solicitation_Date_tv').Calculation__c);
        
        
        if (days!=null){
            newrec1.put(releaseDefaultLabelMap.get('Trade_Solicitation_Date_tv').Source_Field__c,streetDate.addDays(days));
        }        
    }
    
     /*update in plant date = street date - 70 - @Kalash*/
    public static void updateInPlantDate(sObject newrec1, Date streetDate, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;
        
        days = Integer.ValueOf(releaseDefaultLabelMap.get('In_Plant_Date_tv').Calculation__c);
        
        
        if (days!=null){
            newrec1.put(releaseDefaultLabelMap.get('In_Plant_Date_tv').Source_Field__c,streetDate.addDays(days));
        }        
    }
    
     /*update selling guides due date = street date - 5 months - @Kalash*/
    public static void updateSellingGuideDueDate(sObject newrec1, Date streetDate, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer months;
        
        months = Integer.ValueOf(releaseDefaultLabelMap.get('Selling_Guides_Due_Date_tv').Calculation__c);
        
        
        if (months!=null){
            newrec1.put(releaseDefaultLabelMap.get('Selling_Guides_Due_Date_tv').Source_Field__c,streetDate.addMonths(months));
        }        
    }
    /*Trade_Assets_Due_to_JV_Date__c = Trade Email Date - 10 days - @Kalash*/
    public static void updateTradeAssetDueToJVDate(sObject newrec1, Date tradeEmailDate, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap) {
        Integer days;
        
        days = Integer.ValueOf(releaseDefaultLabelMap.get('Trade_Assets_Due_to_JV_Date_tv').Calculation__c);
        
        
        if (days!=null){
            newrec1.put(releaseDefaultLabelMap.get('Trade_Assets_Due_to_JV_Date_tv').Source_Field__c,tradeEmailDate.addDays(days));
        }        
    }
    
}