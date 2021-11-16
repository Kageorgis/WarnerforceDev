global class CP_ForecastBatchInsert implements Database.Batchable<CP_Forecast__c>, Database.Stateful {
    private List<CP_Forecast__c> forecastList;
    public CP_ForecastBatchInsert(List<CP_Forecast__c> forecastListToInsert) {
        forecastList = forecastListToInsert;
        system.debug('forecastList in constructor'+forecastList);
    }
        
    global Iterable<CP_Forecast__c> start(Database.BatchableContext bc) {
        return forecastList;
    }
    global void execute(Database.BatchableContext bc, List<CP_Forecast__c> records){
        system.debug('forecastList in batch'+records);
         system.debug('batch forecastList size :'+records.size());
        insert records;
        system.debug('insert finished-->');
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}