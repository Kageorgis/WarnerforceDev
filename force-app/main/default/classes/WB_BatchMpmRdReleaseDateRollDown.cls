global class WB_BatchMpmRdReleaseDateRollDown implements Schedulable, Database.Batchable<sObject> {
    //---------------ER-007170 - Change Start -----------
    String dateFilter;
    DateTime lastRunDate;
    DateTime LastModifiedFrom;
    DateTime LastModifiedTo;
    
    public WB_BatchMpmRdReleaseDateRollDown(DateTime fromDateVar,DateTime toDateVar){
        system.debug('Before batch class constructor lastRunDate : '+fromDateVar+'-----'+toDateVar);
        LastModifiedFrom = (fromDateVar != null) ? fromDateVar.addMinutes(-1) : system.now().addDays(-7);
        LastModifiedTo = (toDateVar != null) ? toDateVar : null;
        system.debug('After batch class constructor lastRunDate : '+LastModifiedFrom+'-----'+LastModifiedTo);
        
        dateFilter = ' AND LastModifiedDate >= :LastModifiedFrom'; 
        if(LastModifiedTo != null){
            dateFilter += ' AND LastModifiedDate <= :LastModifiedTo';
        }
    }
    
    Global void execute(SchedulableContext ctx){
        system.debug('lastRunDate : '+lastRunDate);
        WB_BatchMpmRdReleaseDateRollDown batch = new WB_BatchMpmRdReleaseDateRollDown(lastRunDate,null);
        lastRunDate = system.now();
        
        Integer batchSize = WB_Populate_TRD_On_LT__c.getInstance('WB_MPMRD_Roll_Down') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_MPMRD_Roll_Down').Batch_Size__c) : 10;
        Database.executeBatch(batch,batchSize);
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        String queryStr = 'SELECT id,Initial_EST_Release_Date__c,Initial_VOD_Release_Date__c,Initial_Physical_Release_Date__c,key__c,Title_MPM_F__c, Country_Code2__c, Language_Code__c,Title__C,Title__r.MPM__c FROM Local_Title__c WHERE External_Company__c = Null'+dateFilter;
        return Database.getQueryLocator(queryStr);
    }
    
    //---------------ER-007170 - Change End -----------
    
    global void execute (Database.BatchableContext bc,List<Local_Title__c> lstlocalData)
    {   
        system.debug('lstlocalData*****'+lstlocalData);
        Set<id> setMPMids = new Set<id>();
    	Map<String,Date> channelDateMap = new Map<String,Date>();
        Set<String> langSet = new Set<String>();
        Set<String> countrySet = new Set<String>();
        Set<String> mpmSet = new Set<String>();
        List<Local_Title__c> localTitles = new List<Local_Title__c>(); 
        Date maxDate = Date.newInstance(3010, 12, 31);
        Set<String> mpmReleaseDtLocale = new Set<String>();
        Map<String,Set<String>> mapReleaseLocale =new Map<String,Set<String>>();
        
        List<MPM_Release_Date__c> LstMpmReleaseDt = new List<MPM_Release_Date__c>();
        Set<String> mpmReleaseDtStatus = new Set<String>();
        mpmReleaseDtStatus.add('Tentative');
        mpmReleaseDtStatus.add('Confirmed'); 
        
        for(Local_Title__c localdata:lstlocalData)
            setMPMids.add(localdata.Title__r.MPM__c);
            
        
        
        if(setMPMids != NULL && setMPMids.size() > 0 ) 
        {
            
            LstMpmReleaseDt = [SELECT Id,channel__c,Release_Start__c,Language__r.Language_Code_2__c,Country__r.Country_Code2__c,MPM__c
                                                          ,MPM__r.Name,Locale__c
                                                          FROM MPM_Release_Date__c 
                                                          WHERE MPM__c=:setMPMids AND Release_Status__c IN: mpmReleaseDtStatus];
            
            for(MPM_Release_Date__c mpmReleaseDate:LstMpmReleaseDt)
                mpmReleaseDtLocale.add(mpmReleaseDate.Locale__c);
            
            //fetch all the locals matching mpmReleaseDtLocale
            if(mpmReleaseDtLocale != NULL && mpmReleaseDtLocale.size()>0 ){
                for(Rights_Group__c rightGroup: [Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c IN:mpmReleaseDtLocale]){
                    if(!mapReleaseLocale.containsKey(rightGroup.Release_Locale__c))
                        mapReleaseLocale.put(rightGroup.Release_Locale__c,new Set<String>());
                    mapReleaseLocale.get(rightGroup.Release_Locale__c).add(rightGroup.Name);
                }    
            }
                
            for(MPM_Release_Date__c mpmRd : LstMpmReleaseDt) 
            {
                if(mpmRd.channel__c != NULL && mpmRd.Locale__c != NULL &&
                   (mpmRd.channel__c == 'Physical' || mpmRd.channel__c == 'EST' || mpmRd.channel__c == 'VODi' || mpmRd.channel__c == 'VODc' ))
                {
                    String channel = mpmRd.channel__c.contains('VOD') ? 'VOD' : mpmRd.channel__c;
                     if(mapReleaseLocale.containsKey(mpmRd.Locale__c)) {
                        for(String strLocale:mapReleaseLocale.get(mpmRd.Locale__c)) {
                            system.debug('********'+strLocale.toLowerCase()+strLocale);
                            String key = mpmRd.MPM__r.Name+'-'+strLocale.toLowerCase()+'-'+channel;
                            if(!channelDateMap.containsKey(key))
                                channelDateMap.put(key,mpmRd.Release_Start__c != NULL ? mpmRd.Release_Start__c : maxDate);
                            else if(mpmRd.Release_Start__c != NULL && channelDateMap.get(key) > mpmRd.Release_Start__c)
                                channelDateMap.put(key,mpmRd.Release_Start__c);
                            langSet.add(strLocale.substringBefore('_'));
                            countrySet.add(strLocale.substringAfter('_'));
                        }    
                        mpmSet.add(mpmRd.MPM__r.Name);
                    }
                }
                
            }
            
            for(Local_Title__c loc : lstlocalData)
            {
                String locKeyPhysical = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'Physical';
                String locKeyEST = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'EST';
                String locKeyVOD = loc.Title_MPM_F__c+'-'+loc.Language_Code__c.toLowerCase()+'_'+loc.Country_Code2__c.toLowerCase()+'-'+'VOD';
                
                Integer count = 0;
                if(channelDateMap.containsKey(locKeyPhysical))
                {
                    loc.Initial_Physical_Release_Date__c = channelDateMap.get(locKeyPhysical) == maxDate ? NULL : channelDateMap.get(locKeyPhysical);
                    count++;
                }
                if(channelDateMap.containsKey(locKeyEST))
                {
                    loc.Initial_EST_Release_Date__c = channelDateMap.get(locKeyEST) == maxDate ? NULL : channelDateMap.get(locKeyEST);
                    count++;  
                }
                if(channelDateMap.containsKey(locKeyVOD))
                {
                     loc.Initial_VOD_Release_Date__c = channelDateMap.get(locKeyVOD) == maxDate ? NULL : channelDateMap.get(locKeyVOD); 
                    count++;
                }
                
                if(count > 0)
                    localTitles.add(loc);
            }
            
            try{
            	WB_LocalTitleTriggerHandler.recursiveUpdate = true;
                Database.update(localTitles);
                WB_LocalTitleTriggerHandler.recursiveUpdate = false;
            }
            catch(Exception e)
            {
                System.debug('Following error occurred: '+e.getMessage());
            }
            
        }
     } //End Of Execute
    global void finish(Database.BatchableContext BC){}
}