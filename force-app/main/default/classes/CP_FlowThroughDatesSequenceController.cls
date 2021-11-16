public class CP_FlowThroughDatesSequenceController {
    public static void executeBeforeInsert(List<Flow_Through_Dates__c> lstFlowThroughDates) {
        CP_FlowThroughDatesHandler.checkExistingCPProducts(lstFlowThroughDates);
        CP_FlowThroughDatesHandler.generateFlowThroughDatesKey(lstFlowThroughDates);
    }
    
    public static void executeBeforeUpdate(List<Flow_Through_Dates__c> lstFlowThroughDates, Map<Id,Flow_Through_Dates__c> oldMapFlowThroughDates){
        Map<Id,Flow_Through_Dates__c> mapRecToUpdateKey = new Map<Id,Flow_Through_Dates__c>();
        for(Flow_Through_Dates__c newRec : lstFlowThroughDates){
            Flow_Through_Dates__c oldRec = oldMapFlowThroughDates.get(newRec.Id);                  
            if(newRec.Retailer__c != oldRec.Retailer__c || newRec.Country__c != oldRec.Country__c ||
               newRec.GTIN__c != oldRec.GTIN__c || newRec.Flow_Through_Start_Date__c != oldRec.Flow_Through_Start_Date__c){
                   if(!mapRecToUpdateKey.containsKey(newRec.Id)){
                       mapRecToUpdateKey.put(newRec.Id, newRec);
                   }
               }
        }        
        if(!mapRecToUpdateKey.isEmpty()){
            CP_FlowThroughDatesHandler.checkExistingCPProducts(lstFlowThroughDates);
            CP_FlowThroughDatesHandler.generateFlowThroughDatesKey(mapRecToUpdateKey.values());
        }        
    }
    
}