/**
   @Author Cognizant
   @name WB_Update_FamilyMPM_Batch
   @CreateDate 15 Sept 2020
   @Description This class is used to populate Family MPM on MPM when Family MPM Record exist in system.
   @Version <1.0>
   @reference ER-006470
*/
global class WB_Update_FamilyMPM_Batch implements Database.Batchable<sObject>, Schedulable{
    String dateFilter;
    DateTime lastRunDate;
    DateTime LastModifiedFrom;
    DateTime LastModifiedTo;
    
    // Schedulable interface
    Global void execute(SchedulableContext ctx){   
        
        system.debug('lastRunDate : '+lastRunDate);
        WB_Update_FamilyMPM_Batch rd = new WB_Update_FamilyMPM_Batch(lastRunDate,null);
        lastRunDate = system.now();
        
        Integer batchSize = WB_Populate_TRD_On_LT__c.getInstance('WB_Update_FamilyMPM') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_Update_FamilyMPM').Batch_Size__c) : 200;
        database.executebatch(rd,batchSize);
    }
    
    Global WB_Update_FamilyMPM_Batch(){}
    Global WB_Update_FamilyMPM_Batch(DateTime fromDateVar,DateTime toDateVar){
        LastModifiedFrom = (fromDateVar != null) ? fromDateVar.addMinutes(-1) : system.now().addDays(-1);
        LastModifiedTo = (toDateVar != null) ? toDateVar : null;
        dateFilter = ' LastModifiedDate >= :LastModifiedFrom' + (LastModifiedTo != null ? ' AND LastModifiedDate <= :LastModifiedTo)' : '');
    }
    
    //Batch Class Implementation
    global Database.QueryLocator start (Database.BatchableContext bc){
        createErrorLog('Update The Family MPM','Start Method','MPM__c',null,LastModifiedFrom,null,true);
        Set<String> setOfFamilyMPMs = new Set<String>();
        for(MPM__c m : Database.query('Select Name From MPM__c Where '+dateFilter)){
        	setOfFamilyMPMs.add(m.Name);
        }
        return Database.getQueryLocator('Select Id,Name,Family_MPM_Number_Lookup__c,Family_MPM_Generic_Synopsis__c,Family_MPM_Long_Synopsis__c,Family_MPM_Short_Synopsis__c,Family_MPM_Number__c From MPM__c Where Family_MPM_Number__c IN :setOfFamilyMPMs');
    }
    
    global void execute (Database.BatchableContext bc,List<MPM__c> lstMPMs){
        List<String> lstFamilyMPMNo = new List<String>();   
        Map<String, MPM__c> mapFamilyMPM = new Map<String, MPM__c>(); 
        
        //Get list of Family MPM numbers
        for(MPM__c mpm : lstMPMs){
            if(mpm.Family_MPM_Number__c != null)
                lstFamilyMPMNo.add(mpm.Family_MPM_Number__c);
        }
        
        for(MPM__c mpm : [Select Id, Name, MPM_Generic_Synopsis__c, MPM_Long_Synopsis__c, MPM_Short_Synopsis__c FROM MPM__c WHERE Name IN : lstFamilyMPMNo]){
            mapFamilyMPM.put(mpm.Name, mpm);
        }
        
        //Update the value of Family MPM details   
        List<MPM__c> listOfMPMNeedToUpdate = new List<MPM__c>();
        for(MPM__c mpm : lstMPMs){
            if(mpm.Family_MPM_Number__c != null){
                if(mapFamilyMPM.size() > 0 && mapFamilyMPM.containsKey(mpm.Family_MPM_Number__c) && mapFamilyMPM.get(mpm.Family_MPM_Number__c).Id != mpm.Id){
                    mpm.Family_MPM_Number_Lookup__c = mapFamilyMPM.get(mpm.Family_MPM_Number__c).Id;
                    mpm.Family_MPM_Generic_Synopsis__c = mapFamilyMPM.get(mpm.Family_MPM_Number__c).MPM_Generic_Synopsis__c;
                    mpm.Family_MPM_Long_Synopsis__c = mapFamilyMPM.get(mpm.Family_MPM_Number__c).MPM_Long_Synopsis__c;
                    mpm.Family_MPM_Short_Synopsis__c = mapFamilyMPM.get(mpm.Family_MPM_Number__c).MPM_Short_Synopsis__c;
                    listOfMPMNeedToUpdate.add(mpm);
                }
            }
        }
        
        Database.SaveResult[] srList = Database.update(listOfMPMNeedToUpdate,false);
        List<CAS_Error_Log__c> errorLogs = new List<CAS_Error_Log__c>();
        for (integer i=0;i<srList.size();i++){
            Database.SaveResult sr = srList[i];
            MPM__c mpm = listOfMPMNeedToUpdate[i];
            if (!sr.isSuccess()){
                errorLogs.add(createErrorLog('Update The Family MPM','Execute Method','MPM__c',sr,LastModifiedFrom,mpm,false));
            }
        }
        
        if(errorLogs.size() > 0){
            insert errorLogs;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    //This method is used to create CAS Error Log from start & Execute Method
    public static CAS_Error_Log__c createErrorLog(String errorCategory,String callingFrom,String objectName,Database.SaveResult sr,DateTime lastRunDate,MPM__c mpm,Boolean isInsert){
        CAS_Error_Log__c CASErrorLog = new CAS_Error_Log__c();
        CASErrorLog.Object_Name__c = objectName;
        CASErrorLog.Error_Category__c = errorCategory;
        
        if(mpm != null && sr != null){
            CASErrorLog.Record_Id__c = mpm.Id;
            CASErrorLog.Error_Description__c = callingFrom+' : '+mpm.Name+' && Time : '+String.valueOf(lastRunDate);
            CASErrorLog.Error_Description_Long__c =  sr.getErrors()[0].getMessage()+' ;; '+sr.getErrors()[0].getFields();
        }else{
            CASErrorLog.Error_Description__c = callingFrom+' && Time : '+String.valueOf(lastRunDate);
        }
        
        if(isInsert){
            insert CASErrorLog;
        }
        
        return CASErrorLog;
    }
    
}