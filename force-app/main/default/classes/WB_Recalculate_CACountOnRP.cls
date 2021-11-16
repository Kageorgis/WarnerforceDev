global without sharing class WB_Recalculate_CACountOnRP implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        return Database.getQueryLocator([SELECT Id, 
                                                Name
                                           FROM Commercial_Avail__c]);
                                                  
    }
    
    global void execute(Database.BatchableContext BC, list<Commercial_Avail__c> scope){

        Map<Id,Commercial_Avail__c> rPlanMap = new Map<Id,Commercial_Avail__c>([Select Id,Name,Count_Client_Avail__c, ( select id from Client_Avails__r) from Commercial_Avail__c where id in :scope]);
        List<Commercial_Avail__c> listCommercial = rPlanMap.values();
        Set<commercial_avail__c> setUpdatecommercialId = new Set<commercial_avail__c>();
        list<commercial_avail__c> updateCommAvail= new list<commercial_avail__c>();
        list<client_avail__c> clientAvailCountList= new list<client_avail__c>();
        map<id,integer> countmap = new map<id,integer>();
        
        system.debug('listCommercial : '+listCommercial);
        system.debug('count on commercial : '+listCommercial.size());
        
        for(integer i=0; i < listCommercial.size() ; i++){
            clientAvailCountList = listCommercial[i].Client_Avails__r;
            countmap.put(listCommercial[i].id,clientAvailCountList.size());
        } 
        
        for(Integer i=0; i < listCommercial.size(); i++){
            for(Integer z=0 ; z < countmap.size(); z++){
                if(countmap.containskey(listCommercial[i].id)) { 
                    listCommercial[i].Count_Client_Avail__c = countmap.get(listCommercial[i].id);
                    if(setUpdatecommercialId.add(listCommercial[i])){
                        updateCommAvail.add(listCommercial[i]);
                    }
                } 
            } 
        }
        
        system.debug('setUpdatecommercialId : '+setUpdatecommercialId);
        system.debug('updateCommAvail    : '+updateCommAvail);
        
        database.update(updateCommAvail,false);
    }
    
    global void finish(Database.BatchableContext BC){
    
    }

}