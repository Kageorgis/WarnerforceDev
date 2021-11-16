public class WB_TVSalesHistoryTriggerHandler {
    public static void setQueueToOwner(List<TV_Sales_History__c> listTVSalesHistory){
        Map<String,WB_Queue_Id__c> allQueuesetting = WB_Queue_Id__c.getAll();
        Set<Id> countryIds = new  Set<Id>();
        
        if(listTVSalesHistory != null && listTVSalesHistory.size() >0){
            for(TV_Sales_History__c tvSalesRecord:listTVSalesHistory){
                countryIds.add(tvSalesRecord.Country__c);
            }
          Map<Id,Country__c> mapCountry = new Map<Id,Country__c>([SELECT Id, Name, Digital_Owner__c FROM Country__c Where Id IN: countryIds LIMIT 10000]);
            
            for(TV_Sales_History__c tvSalesHistoryRecord:listTVSalesHistory){
               if(tvSalesHistoryRecord.Country__c != null &&  mapCountry.get(tvSalesHistoryRecord.Country__c) != null && mapCountry.get(tvSalesHistoryRecord.Country__c).Digital_Owner__c != null 
                   && allQueuesetting!=null && allQueuesetting.get(mapCountry.get(tvSalesHistoryRecord.Country__c).Digital_Owner__c) != null && allQueuesetting.get(mapCountry.get(tvSalesHistoryRecord.Country__c).Digital_Owner__c).Value__c != null){
                   tvSalesHistoryRecord.ownerId = allQueuesetting.get(mapCountry.get(tvSalesHistoryRecord.Country__c).Digital_Owner__c).Value__c;
               }else{
                    if(allQueuesetting != null && allQueuesetting.get('USA_Q') != null && allQueuesetting.get('USA_Q').Value__c != null){
                        tvSalesHistoryRecord.ownerId = allQueuesetting.get('USA_Q').Value__c;
                    }
               }
            }
               
        }
    }
}