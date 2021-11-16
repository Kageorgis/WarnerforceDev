/*
1) ER-1043
Created Date - 3/29/2017
Description - Class is used to update fields on Local Title ( Initial_EST_Release_Date__c,Initial_Physical_Release_Date__c,Initial_VOD_Release_Date__c) 
              as below logic:
 It fetches all the MPM release Date records with status 'Tentative' ot 'Confirmed' for MPM and categorise them in acc.to the Channel(Physical,VOD and EST) and locale value on them and then stores lowest Release Start Date value for channel and locale.
For Title associated to MPM it then fetches all the local Title Records and then updates above calculated lowest date values
   into the Local Title records matching channel and Locale(Key in Local Title)
2)ER-002449 Local Data to be rolled down to reflect change in status/avail/release dates of MPM RD with all other statuses (except 'Confirmed' and 'Tentative')
*/

public class WB_MpmRdReleaseDateRollDown { 
     
    
    public void updateDatesOnLocalTitles(List<MPM_Release_Date__c> lstMpmReleaseDt){
        Set<Id> setMpmReleaseDtIds = new Set<Id>();
        Set<String> mpmReleaseDtStatus = new Set<String>();
        Set<String> mpmReleaseDtLocale = new Set<String>();
        Date maxDate = Date.newInstance(3010, 12, 31);
        Map<String,Set<String>> mapReleaseLocale =new Map<String,Set<String>>();
        
        mpmReleaseDtStatus.add('Tentative');
        mpmReleaseDtStatus.add('Confirmed');

        //Add into Set if Channel/Release Start Date/MPM/Country/Language is changed
        for(MPM_Release_Date__c releaseDateRec : lstMpmReleaseDt){
            MPM_Release_Date__c oldReleaseDateRecord;
            if(trigger.isUpdate)
                oldReleaseDateRecord = (MPM_Release_Date__c)trigger.oldMap.get(releaseDateRec.Id);
            if(trigger.isInsert || (releaseDateRec.MPM__c != oldReleaseDateRecord.MPM__c || 
              releaseDateRec.Release_Start__c != oldReleaseDateRecord.Release_Start__c  || 
              releaseDateRec.channel__c != oldReleaseDateRecord.channel__c ||
              releaseDateRec.Locale__c != oldReleaseDateRecord.Locale__c || 
              (releaseDateRec.Release_Status__c != oldReleaseDateRecord.Release_Status__c && (releaseDateRec.Release_Status__c == 'Tentative' || releaseDateRec.Release_Status__c == 'Confirmed')))){
                  setMpmReleaseDtIds.add(releaseDateRec.MPM__c);                  
                  mpmReleaseDtLocale.add(releaseDateRec.Locale__c);
              }
              
                
        }
        system.debug('setMpmReleaseDtIds****'+setMpmReleaseDtIds);
        if(setMpmReleaseDtIds != NULL && setMpmReleaseDtIds.size() > 0){
            //fetch all the locals matching mpmReleaseDtLocale
            if(mpmReleaseDtLocale != NULL && mpmReleaseDtLocale.size()>0 ){
                for(Rights_Group__c rightGroup: [Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c IN:mpmReleaseDtLocale]){
                    if(!mapReleaseLocale.containsKey(rightGroup.Release_Locale__c))
                        mapReleaseLocale.put(rightGroup.Release_Locale__c,new Set<String>());
                    mapReleaseLocale.get(rightGroup.Release_Locale__c).add(rightGroup.Name);
                }    
            }
            
            List<MPM_Release_Date__c> lstMpmReleaseDate = [Select Id,channel__c,Release_Start__c,Release_Status__c, Language__r.Language_Code_2__c,Country__r.Country_Code2__c,MPM__c,MPM__r.Name,Locale__c
                                                        FROM MPM_Release_Date__c
                                                        WHERE MPM__c IN: setMpmReleaseDtIds AND Release_Status__c IN: mpmReleaseDtStatus
                                                        ];
            //ER-002449 - creating two new Maps ; splitting for preference
            //Map<String,Date> channelDateMap = new Map<String,Date>();         
            Map<String,Date> channelDateMapConfirmed = new Map<String,Date>();
            Map<String,Date> channelDateMapTentative = new Map<String,Date>();
            
            Set<String> langSet = new Set<String>();
            Set<String> countrySet = new Set<String>();
            Set<String> mpmSet = new Set<String>();
            List<Local_Title__c> localTitles = new List<Local_Title__c>();
            for(MPM_Release_Date__c mpmRd : lstMpmReleaseDate) {
                if(mpmRd.channel__c != NULL && mpmRd.Locale__c != NULL &&
                   (mpmRd.channel__c == 'Physical' || mpmRd.channel__c == 'EST' || mpmRd.channel__c == 'VODi' || mpmRd.channel__c == 'VODc' )) {
                    String channel = mpmRd.channel__c.contains('VOD') ? 'VOD' : mpmRd.channel__c;
                    if(mapReleaseLocale.containsKey(mpmRd.Locale__c)) {
                        for(String strLocale:mapReleaseLocale.get(mpmRd.Locale__c)) {
                            //system.debug('********'+strLocale.toLowerCase()+strLocale);
                            String key = mpmRd.MPM__r.Name+'-'+strLocale.toLowerCase()+'-'+channel;
                            if(mpmRd.Release_Status__c=='Confirmed'){
                                if(!channelDateMapConfirmed.containsKey(key))
                                    channelDateMapConfirmed.put(key,mpmRd.Release_Start__c != NULL ? mpmRd.Release_Start__c : maxDate);
                                else if(mpmRd.Release_Start__c != NULL && channelDateMapConfirmed.get(key) > mpmRd.Release_Start__c)
                                    channelDateMapConfirmed.put(key,mpmRd.Release_Start__c);
                            }
                            else if(mpmRd.Release_Status__c=='Tentative'){
                                if(!channelDateMapTentative.containsKey(key))
                                    channelDateMapTentative.put(key,mpmRd.Release_Start__c != NULL ? mpmRd.Release_Start__c : maxDate);
                                else if(mpmRd.Release_Start__c != NULL && channelDateMapTentative.get(key) > mpmRd.Release_Start__c)
                                    channelDateMapTentative.put(key,mpmRd.Release_Start__c);
                            }
                                
                            langSet.add(strLocale.substringBefore('_'));
                            countrySet.add(strLocale.substringAfter('_'));
                        }    
                        mpmSet.add(mpmRd.MPM__r.Name);
                    }
                }
                
            }
            system.debug('lstMpmReleaseDate***'+lstMpmReleaseDate);
            for(Local_Title__c loc : [SELECT id,key__c, Title_MPM_F__c, Country_Code2__c, Language_Code__c FROM Local_Title__c WHERE Title_MPM_F__c =: mpmSet AND Country_Code2__c =: countrySet AND Language_Code__c =: langSet AND External_Company__c = Null LIMIT 5000 ])
            {
                
                String locKeyPhysical = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'Physical';
                
                String locKeyEST = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'EST';
                
                String locKeyVOD = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'VOD';
                
                
                Integer count = 0;
                if(channelDateMapConfirmed.containsKey(locKeyPhysical))
                { 
                    loc.Initial_Physical_Release_Date__c = channelDateMapConfirmed.get(locKeyPhysical) == maxDate ? NULL : channelDateMapConfirmed.get(locKeyPhysical);
                    count++;
                }
                else if(channelDateMapTentative.containsKey(locKeyPhysical))
                { 
                    loc.Initial_Physical_Release_Date__c = channelDateMapTentative.get(locKeyPhysical) == maxDate ? NULL : channelDateMapTentative.get(locKeyPhysical);
                    count++;
                }
                if(channelDateMapConfirmed.containsKey(locKeyEST))
                {
                    loc.Initial_EST_Release_Date__c = channelDateMapConfirmed.get(locKeyEST) == maxDate ? NULL : channelDateMapConfirmed.get(locKeyEST);
                    count++;
                }
                else if(channelDateMapTentative.containsKey(locKeyEST))
                {
                    loc.Initial_EST_Release_Date__c = channelDateMapTentative.get(locKeyEST) == maxDate ? NULL : channelDateMapTentative.get(locKeyEST);
                    count++;
                }
                if(channelDateMapConfirmed.containsKey(locKeyVOD))
                {
                    loc.Initial_VOD_Release_Date__c = channelDateMapConfirmed.get(locKeyVOD) == maxDate ? NULL : channelDateMapConfirmed.get(locKeyVOD);
                    count++;
                }
                else if(channelDateMapTentative.containsKey(locKeyVOD))
                {
                    loc.Initial_VOD_Release_Date__c = channelDateMapTentative.get(locKeyVOD) == maxDate ? NULL : channelDateMapTentative.get(locKeyVOD);
                    count++;
                }
               
                //system.debug('loc*****'+loc);
                if(count > 0)
                    localTitles.add(loc);
            }
            system.debug('localTitles size****'+localTitles.size());
            try{
                Database.update(localTitles);
                //system.debug('localTitles after insert ****'+localTitles);
            }
            catch(Exception e)
            {
                System.debug('Following error occurred: '+e.getMessage());
            }
        }
        
    } 
    //ER-002449 : START
    public void updateDatesOnLocalTitlesForCancel(List<MPM_Release_Date__c> lstMpmReleaseDt){
        Set<Id> setMpmReleaseDtIds = new Set<Id>();
        Set<String> mpmReleaseDtStatus = new Set<String>();
        Set<String> mpmReleaseDtLocale = new Set<String>();
        Date maxDate = Date.newInstance(3010, 12, 31);
        Map<String,Set<String>> mapReleaseLocale =new Map<String,Set<String>>();
        
        mpmReleaseDtStatus.add('Tentative');
        mpmReleaseDtStatus.add('Confirmed');

        //Add into Set if Channel/Release Start Date/MPM/Country/Language is changed
        for(MPM_Release_Date__c releaseDateRec : lstMpmReleaseDt){
            MPM_Release_Date__c oldReleaseDateRecord;
            if(trigger.isUpdate)
                oldReleaseDateRecord = (MPM_Release_Date__c)trigger.oldMap.get(releaseDateRec.Id);
            if(trigger.isInsert || (releaseDateRec.Release_Start__c != oldReleaseDateRecord.Release_Start__c  || 
               releaseDateRec.Avail_Start__c!= oldReleaseDateRecord.Avail_Start__c||
              (releaseDateRec.Release_Status__c != oldReleaseDateRecord.Release_Status__c && (releaseDateRec.Release_Status__c != 'Tentative' && releaseDateRec.Release_Status__c != 'Confirmed')))){
                  setMpmReleaseDtIds.add(releaseDateRec.MPM__c);                  
                  mpmReleaseDtLocale.add(releaseDateRec.Locale__c);
              }
              
                
        }
        system.debug('setMpmReleaseDtIds****'+setMpmReleaseDtIds);
        if(setMpmReleaseDtIds != NULL && setMpmReleaseDtIds.size() > 0){
            //fetch all the locals matching mpmReleaseDtLocale
            if(mpmReleaseDtLocale != NULL && mpmReleaseDtLocale.size()>0 ){
                for(Rights_Group__c rightGroup: [Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c IN:mpmReleaseDtLocale]){
                    if(!mapReleaseLocale.containsKey(rightGroup.Release_Locale__c))
                        mapReleaseLocale.put(rightGroup.Release_Locale__c,new Set<String>());
                    mapReleaseLocale.get(rightGroup.Release_Locale__c).add(rightGroup.Name);
                }    
            }
            
            List<MPM_Release_Date__c> lstMpmReleaseDate = [Select Id,channel__c,Release_Start__c,Release_Status__c,Language__r.Language_Code_2__c,Country__r.Country_Code2__c,MPM__c,MPM__r.Name,Locale__c
                                                        FROM MPM_Release_Date__c
                                                        WHERE MPM__c IN: setMpmReleaseDtIds /*AND Release_Status__c NOT IN: mpmReleaseDtStatus*/
                                                        ];
            Map<String,Date> channelDateMapConfirmed = new Map<String,Date>();
            Map<String,Date> channelDateMapTentative = new Map<String,Date>();
            Map<String,Date> channelDateMapBlank = new Map<String,Date>();
            Set<String> langSet = new Set<String>();
            Set<String> countrySet = new Set<String>();
            Set<String> mpmSet = new Set<String>();
            List<Local_Title__c> localTitles = new List<Local_Title__c>();
            for(MPM_Release_Date__c mpmRd : lstMpmReleaseDate) {
                if(mpmRd.channel__c != NULL && mpmRd.Locale__c != NULL && (mpmRd.channel__c == 'Physical' || mpmRd.channel__c == 'EST' || mpmRd.channel__c == 'VODi' || mpmRd.channel__c == 'VODc' )) {
                    String channel = mpmRd.channel__c.contains('VOD') ? 'VOD' : mpmRd.channel__c;
                    if(mapReleaseLocale.containsKey(mpmRd.Locale__c)){
                        for(String strLocale:mapReleaseLocale.get(mpmRd.Locale__c)) {
                            String key = mpmRd.MPM__r.Name+'-'+strLocale.toLowerCase()+'-'+channel;
                            if(mpmRd.Release_Status__c=='Confirmed'){
                                if(!channelDateMapConfirmed.containsKey(key))
                                    channelDateMapConfirmed.put(key,mpmRd.Release_Start__c != NULL ? mpmRd.Release_Start__c : maxDate);
                                else if(mpmRd.Release_Start__c != NULL && channelDateMapConfirmed.get(key) > mpmRd.Release_Start__c)
                                    channelDateMapConfirmed.put(key,mpmRd.Release_Start__c);
                            }
                            else if(mpmRd.Release_Status__c=='Tentative'){
                                if(!channelDateMapTentative.containsKey(key))
                                    channelDateMapTentative.put(key,mpmRd.Release_Start__c != NULL ? mpmRd.Release_Start__c : maxDate);
                                else if(mpmRd.Release_Start__c != NULL && channelDateMapTentative.get(key) > mpmRd.Release_Start__c)
                                    channelDateMapTentative.put(key,mpmRd.Release_Start__c);
                            }
                            else{
                                channelDateMapBlank.put(key,null);
                            }    
                            langSet.add(strLocale.substringBefore('_'));
                            countrySet.add(strLocale.substringAfter('_'));
                        }    
                        mpmSet.add(mpmRd.MPM__r.Name);
                    }
                }
            }
            //Monika added limit
            for(Local_Title__c loc : [SELECT id,key__c, Title_MPM_F__c, Country_Code2__c, Language_Code__c FROM Local_Title__c WHERE Title_MPM_F__c =: mpmSet AND Country_Code2__c =: countrySet AND Language_Code__c =: langSet AND External_Company__c = Null])
            {
                String locKeyPhysical = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'Physical';
                String locKeyEST = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'EST';
                String locKeyVOD = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'VOD';
                
                Integer count = 0;
                if(channelDateMapConfirmed.containsKey(locKeyPhysical)){ 
                    loc.Initial_Physical_Release_Date__c = channelDateMapConfirmed.get(locKeyPhysical) == maxDate ? NULL : channelDateMapConfirmed.get(locKeyPhysical);
                    count++;
                }
                else if(channelDateMapTentative.containsKey(locKeyPhysical))
                { 
                    loc.Initial_Physical_Release_Date__c = channelDateMapTentative.get(locKeyPhysical) == maxDate ? NULL : channelDateMapTentative.get(locKeyPhysical);
                    count++;
                }
                else if(channelDateMapBlank.containsKey(locKeyPhysical)){
                    loc.Initial_Physical_Release_Date__c = null;
                    
                }
                
                if(channelDateMapConfirmed.containsKey(locKeyEST)){
                    loc.Initial_EST_Release_Date__c = channelDateMapConfirmed.get(locKeyEST) == maxDate ? NULL : channelDateMapConfirmed.get(locKeyEST);
                    count++;
                }
                else if(channelDateMapTentative.containsKey(locKeyEST))
                {
                    loc.Initial_EST_Release_Date__c = channelDateMapTentative.get(locKeyEST) == maxDate ? NULL : channelDateMapTentative.get(locKeyEST);
                    count++;
                }               
                else if(channelDateMapBlank.containsKey(locKeyEST)){
                    loc.Initial_EST_Release_Date__c = null;
                }
                if(channelDateMapConfirmed.containsKey(locKeyVOD)){
                    loc.Initial_VOD_Release_Date__c = channelDateMapConfirmed.get(locKeyVOD) == maxDate ? NULL : channelDateMapConfirmed.get(locKeyVOD);
                    count++;
                }
                else if(channelDateMapTentative.containsKey(locKeyVOD))
                {
                    loc.Initial_VOD_Release_Date__c = channelDateMapTentative.get(locKeyVOD) == maxDate ? NULL : channelDateMapTentative.get(locKeyVOD);
                    count++;
                }
                else if(channelDateMapBlank.containsKey(locKeyVOD)){
                    loc.Initial_VOD_Release_Date__c = null;
                }
                
                if(count > 0)
                    localTitles.add(loc);
            }
            
            try{
                Database.update(localTitles);
               // system.debug('localTitles after insert ****'+localTitles);
            }
            catch(Exception e)
            {
                System.debug('Following error occurred: '+e.getMessage());
            }
        }
        
    }    
    
    public void setOldReleaseStatus(List<MPM_Release_Date__c> lstMpmReleaseDt){
        for(MPM_Release_Date__c releaseDateRec : lstMpmReleaseDt){                
                if(trigger.isInsert){
                    //releaseDateRec.Old_Release_Status__c=releaseDateRec.Release_Status__c;
                    if(WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup)
                    releaseDateRec.Local_Data_Roll_Down__c=true;
                }
                else if(trigger.isUpdate){
                 MPM_Release_Date__c oldReleaseDateRecord;
                 oldReleaseDateRecord = (MPM_Release_Date__c)trigger.oldMap.get(releaseDateRec.Id);                  
                  if(releaseDateRec.Release_Start__c != oldReleaseDateRecord.Release_Start__c  || 
                   releaseDateRec.Avail_Start__c!= oldReleaseDateRecord.Avail_Start__c||
                   (releaseDateRec.Release_Status__c != oldReleaseDateRecord.Release_Status__c && (releaseDateRec.Release_Status__c != 'Tentative' && releaseDateRec.Release_Status__c != 'Confirmed') )){     
                       // releaseDateRec.Old_Release_Status__c=oldReleaseDateRecord.Release_Status__c;
                        if(WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup)
                        releaseDateRec.Local_Data_Roll_Down__c=true;
                    }
               }
             } 
    }
    //ER-002449 : END

}