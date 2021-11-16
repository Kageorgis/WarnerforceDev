trigger WB_CA_Upload_Record_Trigger on CA_Upload_Record__c (after insert, after update) {

    if(trigger.isAfter && trigger.isInsert){
        List<CA_Upload__c> caUploadToUpdate = new List<CA_Upload__c>();
        set<Id> caUploadIds = new Set<Id>();
        For(CA_Upload_Record__c caur : Trigger.New)
            caUploadIds.add(caur.CA_Upload__c);
        Map<Id,CA_Upload__c> existingValuesMap = new Map<Id,CA_Upload__c>([SELECT Id,Total_Stream__c FROM CA_Upload__c WHERE Id IN :caUploadIds]);
        Map<Id,Integer> caSet = new Map<Id,Integer>();
        for(CA_Upload__c ca : existingValuesMap.values())
            caSet.put(ca.Id,(Integer)(ca.Total_Stream__c == null ? 0 : ca.Total_Stream__c));
        for(CA_Upload_Record__c caur : Trigger.New){
            Integer caCurrent = caSet.get(caur.CA_Upload__c);
            caCurrent++;
            caSet.put(caur.CA_Upload__c,caCurrent);
        }
        for(CA_Upload__c ca : existingValuesMap.values()){
            caUploadToUpdate.add(new CA_Upload__c(Id=ca.Id,Total_Stream__c=(Decimal)caSet.get(ca.id)));
        }
        update caUploadToUpdate;        
    }

    if(trigger.isAfter && trigger.isUpdate){    
        List<CA_Upload__c> caUploadToUpdate = new List<CA_Upload__c>();
        set<Id> caUploadIds = new Set<Id>();
        For(CA_Upload_Record__c caur : Trigger.Old)
            caUploadIds.add(caur.CA_Upload__c);
        Map<Id,CA_Upload__c> existingValuesMap = new Map<Id,CA_Upload__c>([SELECT Id,Total_Successful_Stream__c,Total_Fail_Stream__c FROM CA_Upload__c WHERE Id IN :caUploadIds]);
        Map<Id,Integer> successfulSet = new Map<Id,Integer>();
        Map<Id,Integer> failSet = new Map<Id,Integer>();
        for(CA_Upload__c ca : existingValuesMap.values()){
            successfulSet.put(ca.Id,(Integer)(ca.Total_Successful_Stream__c == null ? 0 : ca.Total_Successful_Stream__c));
            failSet.put(ca.Id,(Integer)(ca.Total_Fail_Stream__c == null ? 0 : ca.Total_Fail_Stream__c));
        }
        for(CA_Upload_Record__c caur : Trigger.new){
            Integer successfulCurrent = successfulSet.get(caur.CA_Upload__c);
            Integer failCurrent = failSet.get(caur.CA_Upload__c);
            if(caur.CA_upload_status__c != Trigger.OldMap.get(caur.id).CA_upload_status__c){
                if(caur.CA_upload_status__c == 'Successful'){
                    successfulCurrent++;
                } else if(caur.CA_upload_status__c == 'Failed'){
                    failCurrent++;
                }
            }
            successfulSet.put(caur.CA_Upload__c,successfulCurrent);
            failSet.put(caur.CA_Upload__c,failCurrent);
        }
        for(CA_Upload__c ca : existingValuesMap.values()){
            caUploadToUpdate.add(new CA_Upload__c(Id=ca.Id,Total_Successful_Stream__c=(Decimal)successfulSet.get(ca.id),Total_Fail_Stream__c=(Decimal)failSet.get(ca.id)));
        }
        update caUploadToUpdate;
    }
}