/*******************************************************************************************************************************************
* File Name     :   WB_Batch_MPMRD_UpdateDatesOnLocalTitle
* Description   :   Batch class for Roll Down on Local litle from MPM RD updates 
* @author       :   CTS
* Modification Log
===================================================================================================------------------
* Ver.    Date              Author              Modification
------------------------------------------------------------------------------------------------------------------
* 1.0    Oct 2018            CTS                ER-002449 
********************************************************************************************************************************************/
public class WB_Batch_MPMRD_UpdateDatesOnLocalTitle implements Database.Batchable<sObject>{
  public string strBatchGroup = System.Label.MRD_Rollup_Batch_Group;  
  public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id,Avail_Start__c,Channel__c,Country__c,EAI_Message__c,EAI_Processing_Status__c,
       EAI_Update_Date__c,Earliest_Release_Plan_ID__c,Format__c,Local_Data_Roll_Down__c,Key__c,Language__c,Locale_Key__c,Locale__c,
       MPM_Mismatch__c,MPM_Short_Description__c,MPM_Status__c,MPM__c,Name,
       Opt_Out_Date__c,Opt_Out_Status__c,
       Record_Status__c,Release_Start__c,Release_Status__c,Theatrical_Release_Date__c,TV_Airing_Date__c  
       FROM MPM_Release_Date__c 
       WHERE Local_Data_Roll_Down__c = true]); 
                                                
   }

   public void execute(Database.BatchableContext BC, List<MPM_Release_Date__c> scope){
        
        Set<Id> setMpmReleaseDtIds = new Set<Id>();
        Set<String> mpmReleaseDtStatus = new Set<String>();
        Set<String> mpmReleaseDtLocale = new Set<String>();
        Date maxDate = Date.newInstance(3010, 12, 31);
        Map<String,Set<String>> mapReleaseLocale =new Map<String,Set<String>>();
        
        mpmReleaseDtStatus.add('Tentative');
        mpmReleaseDtStatus.add('Confirmed');

        //Add into Set if Channel/Release Start Date/MPM/Country/Language is changed
        for(MPM_Release_Date__c releaseDateRec : scope){
          setMpmReleaseDtIds.add(releaseDateRec.MPM__c);                  
          mpmReleaseDtLocale.add(releaseDateRec.Locale__c);
          releaseDateRec.Local_Data_Roll_Down__c=false;
        }
        
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
                                                        WHERE MPM__c IN: setMpmReleaseDtIds AND channel__c != null AND Locale__c != null //ER-007463
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
                    if(mapReleaseLocale.containsKey(mpmRd.Locale__c)) {
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
            
            for(Local_Title__c loc : [SELECT id,key__c, Title_MPM_F__c, Country_Code2__c, Language_Code__c FROM Local_Title__c WHERE Title_MPM_F__c =: mpmSet AND Country_Code2__c =: countrySet AND Language_Code__c =: langSet AND External_Company__c = Null LIMIT 5000])
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
          //Code Added by Mayank Desai on 05/21/2019 for ER-003154 + Start
          count++;
          //Code Added by Mayank Desai on 05/21/2019 for ER-003154 + END
                    
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
          //Code Added by Mayank Desai on 05/21/2019 for ER-003154 + Start
          count++;
          //Code Added by Mayank Desai on 05/21/2019 for ER-003154 + END
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
          //Code Added by Mayank Desai on 05/21/2019 for ER-003154 + Start
          count++;
          //Code Added by Mayank Desai on 05/21/2019 for ER-003154 + END
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
        
        Database.update(scope);
   }
   
   public void finish(Database.BatchableContext BC){
    AsyncApexJob apexJob = [SELECT Id, NumberOfErrors, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        List<Group> lstMembers  = new  List<Group>([SELECT(select userOrGroupId from groupMembers) FROM group WHERE name =: strBatchGroup LIMIT 1]);
        if(apexJob.NumberOfErrors > 0 && lstMembers.size() > 0 && (lstMembers[0].groupMembers).size() > 0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {apexJob.CreatedBy.Email};            
            mail.setSubject('Local Data RollDown Batch Failure Details');
            mail.setPlainTextBody('Records processed ' + apexJob.TotalJobItems +   ' with '+ apexJob.NumberOfErrors + ' failures.');
            List<String> mailToAddresses = new List <String>();
            List<Id> idList = new List <Id>();
            
            for (GroupMember gm: lstMembers[0].groupMembers)
                idList.add(gm.userOrGroupId);
                
            List<User> lstUsr = [SELECT email FROM user WHERE id IN: idList];
            for (User u: lstUsr)
                mailToAddresses.add(u.email);   
                             
            mail.setToAddresses(mailToAddresses);            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {apexJob.CreatedBy.Email};            
            mail.setSubject('Local Data RollDown Batch Passing Details');
            mail.setPlainTextBody('Records processed ' + apexJob.TotalJobItems +   ' with '+ apexJob.NumberOfErrors + ' failures.');
            List<String> mailToAddresses = new List <String>();
            List<Id> idList = new List <Id>();
            
            for (GroupMember gm: lstMembers[0].groupMembers)
                idList.add(gm.userOrGroupId);
                
            List<User> lstUsr = [SELECT email FROM user WHERE id IN: idList];
            for (User u: lstUsr)
                //mailToAddresses.add('astha.singh@wbconsultant.com');   
                mailToAddresses.add(u.email);             
            mail.setToAddresses(mailToAddresses);            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }     
            
   }
}