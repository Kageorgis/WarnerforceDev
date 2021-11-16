/******* 
ER-002734
Name:WB_UntrackedMarketMRDCreation
Creation Date- 08 April 2019
Last Modified Date - 15 April 2019
Last Modified by  - Suraj Thakur
Description- This is trigger class to update Theatrical Release Date from 2 Key MPM Release Date to 4 Key MPM Release Date and vice versa.
And for the creation of Untracked MRDs from Tracked Market MRDs(coming from ATOM).
Author- Suraj Thakur
*******/

public class WB_UntrackedMarketMRDCreation {
    public static Map<Id,Country__c> mapIdCountry;
    public static Map<Id,MPM__c> mapIdMPM =new Map<Id,MPM__c>();
    
    public static void createRecord(List<MPM_Release_Date__c> lstNewMRD)
    {
        Set<Id> setCountry = new Set<Id>();
        Set<Id> setUntrackedCountry = new Set<Id>();
        Set<Id> setMPM = new Set<Id>();
        Set<Id> setMRD = new Set<Id>();
        
        Map<String, List<Country__c>> mapCountry= new Map<String, List<Country__c>>();
        Map<String, MPM_Release_Date__c> mapMRD= new Map <String, MPM_Release_Date__c>();
        
        List<MPM_Release_Date__c> lstMRDUpsert= new List<MPM_Release_Date__c>();
        List<MPM_Release_Date__c> lstMRD = new List<MPM_Release_Date__c>();
        
        WB_TriggerRecursionHelper.mrdRecursiveUpdateTrigger = true;

        
        System.debug('lstNewMRD==='+lstNewMRD);
        
        for(MPM_Release_Date__c mrd : lstNewMRD)
        {
            if(mrd.Language__c == null && mrd.Channel__c == null && mrd.Format__c == null && mrd.Country__c != null)
            {
                setMRD.add(mrd.Id);
            }
        }
        
        if(setMRD.size()>0 && setMRD != null)
        {
            lstMRD = [SELECT Id,Country__c,key__c,Country__r.Country_Code2__c,Theatrical_Release_Date__c,TV_Airing_Date__c,MPM__c,MPM__r.Name FROM MPM_Release_Date__c WHERE Id IN: setMRD];
            System.debug('lstMRD==='+lstMRD);
            
            for(MPM_Release_Date__c mrd : lstMRD)
            {
                setCountry.add(mrd.Country__c);
                setMPM.add(mrd.MPM__c);
                setMRD.add(mrd.Id);
                mapMRD.put(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c,mrd);
            }
            
            System.debug('mapMRD==='+mapMRD);
            System.debug('setCountry==='+setCountry);
            System.debug('setMPM==='+setMPM);
            
            for(Country__c country : [Select Id, Name, Tracked_Market__c,Untracked_Market_TRD_Calc__c,Country_Code2__c
                                      FROM Country__c
                                      WHERE Tracked_Market__c IN: setCountry
                                     ])
            {
                System.debug('countr===='+country+'====='+country.Tracked_Market__c);
                if(!mapCountry.containsKey(country.Tracked_Market__c))
                {
                    mapCountry.put(country.Tracked_Market__c, new List<Country__c>{country});
                    setUntrackedCountry.add(country.Id);
                }
                else
                {
                    (mapCountry.get(country.Tracked_Market__c)).add(country);
                    setUntrackedCountry.add(country.Id);
                }
            }
            
            setCountry.addAll(setUntrackedCountry);
            System.debug('setCountry==='+setCountry);
            
            mapIdCountry =new Map<Id,Country__c>([SELECT Id, Name, Tracked_Market__c,Untracked_Market_TRD_Calc__c, Country_Code2__c FROM Country__c WHERE ID IN :setCountry]);
            mapIdMPM =new Map<Id,MPM__c>([SELECT Id, Name FROM MPM__c WHERE ID IN :setMPM]);
            
            if(setUntrackedCountry != null && setUntrackedCountry.size()>0)
            {
                System.debug('mapCountry==='+mapCountry);
                System.debug('setUntrackedCountry==='+setUntrackedCountry);
                System.debug('setUntrackedCountry Count==='+setUntrackedCountry.size());
                
                for(MPM_Release_Date__c mrd : [Select Id,MPM__c,Country__c,Tracked_Market_MRD_Id__r.TV_Airing_Date__c,Key__c,Country__r.Country_Code2__c,Country__r.Tracked_Market__r.Country_Code2__c,MPM__r.Name,Tracked_Market_MRD_Id__r.Theatrical_Release_Date__c,Country__r.Untracked_Market_TRD_Calc__c
                                               FROM MPM_Release_Date__c
                                               WHERE MPM__c IN: setMPM AND Country__c IN: setUntrackedCountry
                                              ])
                {
                    if(mrd.Key__c == (mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c))
                    {
                        System.debug('mrd==='+mrd);
                        MPM_Release_Date__c mpmRelDate = mapMRD.get(mrd.MPM__r.Name+'_'+mrd.Country__r.Tracked_Market__r.Country_Code2__c);
                        System.debug('mpmRelDate==='+mpmRelDate);
                        if(mpmRelDate != null)
                        {
                            if(mpmRelDate.Theatrical_Release_Date__c != null)
                            {
                                Date trdDate =mpmRelDate.Theatrical_Release_Date__c;
                                System.debug('trdDate==='+trdDate);
                                String day = dayOfDate(trdDate);
                                System.debug('day==='+day);
                                System.debug(mrd.Country__r.Untracked_Market_TRD_Calc__c+'_'+day);
                                Integer offset = Integer.valueOf(Untracked_Markets_TRD_Offset__c.getValues(mrd.Country__r.Untracked_Market_TRD_Calc__c+'_'+day).Untracked_Market_TRD_Offset__c);
                                System.debug('offset==='+offset);
                                
                                mrd.Theatrical_Release_Date__c=trdDate.addDays(offset);
                            }
                            else
                                mrd.Theatrical_Release_Date__c=null;
                            
                            /*if(mpmRelDate.TV_Airing_Date__c != null)
							mrd.TV_Airing_Date__c=mpmRelDate.TV_Airing_Date__c;*/
                            
                            mrd.Tracked_Market_MRD_Id__c=mpmRelDate.Id;
                        }
                        mapMRD.put(mrd.Key__c, mrd);
                        lstMRDUpsert.add(mrd);
                    }
                }
                System.debug('mapMRD==='+mapMRD);
                System.debug('lstMRDUpsert==='+lstMRDUpsert);
                
                for(MPM_Release_Date__c mrd : lstMRD)
                {
                    System.debug('mrdrec==='+mapCountry.containsKey(mrd.Country__c)+'===='+mrd.Country__c+'====='+mapCountry.get(mrd.Country__c));
                    if(mapCountry.containsKey(mrd.Country__c))
                    {
                        for(Country__c countryRec : mapCountry.get(mrd.Country__c))
                        {
                            System.debug('check2==='+(mrd.MPM__r.Name+'_'+countryRec.Country_Code2__c));
                            if(!mapMRD.containsKey(mrd.MPM__r.Name+'_'+countryRec.Country_Code2__c))
                            {
                                MPM_Release_Date__c mrdInsert=new MPM_Release_Date__c();
                                mrdInsert.MPM__c = mrd.MPM__c;
                                mrdInsert.Country__c = countryRec.Id;
                                mrdInsert.Record_Status__c = 'Active';
                                if(mrd.Theatrical_Release_Date__c != null)
                                {
                                    Date trdDate = mrd.Theatrical_Release_Date__c;
                                    System.debug('trdDate==='+trdDate);
                                    String day = dayOfDate(trdDate);
                                    System.debug('day==='+day);
                                    System.debug(countryRec.Untracked_Market_TRD_Calc__c+'_'+day);
                                    Integer offset = Integer.valueOf(Untracked_Markets_TRD_Offset__c.getValues(countryRec.Untracked_Market_TRD_Calc__c+'_'+day).Untracked_Market_TRD_Offset__c);
                                    System.debug('offset==='+offset);
                                    
                                    mrdInsert.Theatrical_Release_Date__c=trdDate.addDays(offset);
                                }
                                else
                                    mrdInsert.Theatrical_Release_Date__c = null;
                                
                                /*if(mrd.TV_Airing_Date__c != null)
								mrdInsert.TV_Airing_Date__c=mrd.TV_Airing_Date__c;*/
                                
                                mrdInsert.Tracked_Market_MRD_Id__c = mrd.Id;
                                System.debug('Mrd Insert==='+mrdInsert);
                                
                                lstMRDUpsert.add(mrdInsert);
                            }
                        }
                    }
                }
                
                System.debug('lstMRDUpsert==='+lstMRDUpsert);
                System.debug('lstMRDUpsert Count==='+lstMRDUpsert.size());
                
                try
                {
                    if(lstMRDUpsert != null && lstMRDUpsert.size()> 0)
                    {
                        List<Database.UpsertResult> upsertMRDResult = Database.upsert(lstMRDUpsert, true);
                        System.debug('upsertMRDResult==='+upsertMRDResult);
                        
                        for(Integer index = 0; index < upsertMRDResult.size(); index++)
                        {
                            if(upsertMRDResult[index].isSuccess())
                            {
                                System.debug('lstMRDUpsert[index]==='+lstMRDUpsert[index]);
                                mapMRD.put((mapIdMPM.get(lstMRDUpsert[index].MPM__c).Name+'_'+mapIdCountry.get(lstMRDUpsert[index].Country__c).Country_Code2__c),lstMRDUpsert[index]);
                            }
                        }
                        
                        System.debug('mapMRD==='+mapMRD);
                        System.debug('lstMRDUpsert==='+lstMRDUpsert);
                        
                        trdRollDownNew2KeyTo4Key(mapMRD,setMPM,setCountry);
                    }
                }
                catch(Exception Ex)
                {
                    system.debug('=============== Exception : ' + Ex.getMessage());
                }
            }
        }
        WB_TriggerRecursionHelper.mrdRecursiveUpdateTrigger = false;
    }
    
    static String dayOfDate(Date dt)
    {
        System.debug('dt==='+dt);
        //return dt.format('EEEE');
        
        Date monday = Date.newInstance(1900, 1, 1);
        Integer datInt = Math.mod(monday.daysBetween(dt),7);
        System.debug('datInt==='+datInt);
        
        switch on datInt {
            when 0{
                return 'Monday';}
            when 1{
                return 'Tuesday';}
            when 2{
                return 'Wednesday';}
            when 3{
                return 'Thursday';}
            when 4{
                return 'Friday';}
            when 5{
                return 'Saturday';}
            when 6{
                return 'Sunday';}
            when else{
                return null;}
        }   }
    
    static void trdRollDownNew2KeyTo4Key(Map<String, MPM_Release_Date__c> mapMRD,Set<Id> setMPM,Set<Id> setCountry)
    {
        List<MPM_Release_Date__c> lstUpdateMRD = new List<MPM_Release_Date__c>();
        System.debug('In trdRollDown2KeyTo4Key');
        Map<String, List<MPM_Release_Date__c>> map4KeyMRD= new Map<String, List<MPM_Release_Date__c>>();
        for(MPM_Release_Date__c mrd : [Select Id,Record_Status__c,Theatrical_Release_Date__c,TV_Airing_Date__c,Language__c,Country__c,Channel__c,Format__c,Country__r.Country_Code2__c,MPM__c,MPM__r.Name FROM MPM_Release_Date__c WHERE MPM__c IN: setMPM AND Country__c IN : setCountry])
        {
            System.debug('mrd==='+mrd);
            if(mrd.Channel__c != null && mrd.Format__c != null)
            {
                System.debug('check3==='+(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c));
                if(map4KeyMRD.containsKey(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c))
                    map4KeyMRD.get(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c).add(mrd);
                else
                    map4KeyMRD.put(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c,new List<MPM_Release_Date__c>{mrd});
            }
        }
        System.debug('map4KeyMRD==='+map4KeyMRD);
        
        for(String key: mapMRD.keySet())
        {
            if(map4KeyMRD.containsKey(key))
            {
                for(MPM_Release_Date__c mrd : map4KeyMRD.get(key))
                {
                    System.debug('map4KeyMRDgetkey1==='+map4KeyMRD.get(key));
                    mrd.Theatrical_Release_Date__c = mapMRD.get(key).Theatrical_Release_Date__c;
                    if(mrd.Record_Status__c != 'Locked')
                        mrd.Record_Status__c = 'Active';
                    /*if(mapMRD.get(key).TV_Airing_Date__c != null)
					mrd.TV_Airing_Date__c = mapMRD.get(key).TV_Airing_Date__c;*/
                    mrd.Tracked_Market_MRD_Id__c = mapMRD.get(key).Id;
                    System.debug('mrd==='+mrd);
                    lstUpdateMRD.add(mrd);
                }
            }
        }
        
        System.debug('lstUpdateMRD==='+lstUpdateMRD);
        try
        {
            if(lstUpdateMRD != null && lstUpdateMRD.size() > 0)
                Database.update(lstUpdateMRD, true);
        }
        catch(Exception Ex)
        {
            System.debug('=============== Exception : ' + Ex.getMessage());
        }
    }
    
    //ER-003201 Start
    //Method added to flow TRD from 2 Key MRDs to 4 Key MRDs as per the MPM and Country passesd
    public static void trdRollUp2KeyTo4Key(Set<Id> setMPM,Set<Id> setCountry)
    {
        List<MPM_Release_Date__c> lstUpdateMRD = new List<MPM_Release_Date__c>();
        Map<String, List<MPM_Release_Date__c>> map4KeyMRD= new Map<String, List<MPM_Release_Date__c>>();
        String query = 'Select Id,Key__c,Theatrical_Release_Date__c,TV_Airing_Date__c,Language__c,Country__c,Channel__c,Format__c,Country__r.Country_Code2__c,MPM__c,MPM__r.Name FROM MPM_Release_Date__c';
        
        for(MPM_Release_Date__c mrd : Database.query(query+' WHERE MPM__c IN: setMPM AND Country__c IN : setCountry'))
        {
            System.debug('mrd==='+mrd);
            if(mrd.Channel__c != null && mrd.Format__c != null)
            {
                System.debug('check3==='+(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c));
                if(map4KeyMRD.containsKey(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c))
                    map4KeyMRD.get(mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c).add(mrd);
                else
                    map4KeyMRD.put((mrd.MPM__r.Name+'_'+mrd.Country__r.Country_Code2__c),new List<MPM_Release_Date__c>{mrd});
            }
        }
        System.debug('map4KeyMRD==='+map4KeyMRD);
        Set<String> keySet = map4KeyMRD.keySet();
        if(!map4KeyMRD.isEmpty())
        for(MPM_Release_Date__c mrd : Database.query(query+' WHERE Key__c IN: keySet'))
        {
            if(map4KeyMRD.containsKey(mrd.Key__c))
            {
                for(MPM_Release_Date__c mrd4Key : map4KeyMRD.get(mrd.Key__c))
                {
                    System.debug('map4KeyMRDgetkey2==='+mrd4Key);
                    System.debug('map4KeyMRDgetkey1==='+mrd4Key.Key__c);
                    mrd4Key.Theatrical_Release_Date__c = mrd.Theatrical_Release_Date__c;
                    /*if(mrd.TV_Airing_Date__c != null)
					mrd4Key.TV_Airing_Date__c = mrd.TV_Airing_Date__c;*/
                    mrd4Key.Tracked_Market_MRD_Id__c = mrd.Id;
                    System.debug('map4KeyMRDgetkey2==='+mrd4Key.Key__c);
                    lstUpdateMRD.add(mrd4Key);
                }
            }
        }
        
        System.debug('lstUpdateMRD==='+lstUpdateMRD);
        try
        {
            if(!lstUpdateMRD.isEmpty())
                Database.update(lstUpdateMRD, true);
        }
        catch(Exception Ex)
        {
            System.debug('=============== Exception : ' + Ex.getMessage());
        }
    }
    //ER-003201 End
}