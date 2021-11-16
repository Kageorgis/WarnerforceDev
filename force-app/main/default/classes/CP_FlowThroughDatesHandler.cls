public class CP_FlowThroughDatesHandler {
    
    public static void generateFlowThroughDatesKey(List<Flow_Through_Dates__c> lstFlowThroughDates) {
            Set<String> FTKeys = new Set<String>();
            Map<String,Flow_Through_Dates__c> mapFTDates = new Map<String,Flow_Through_Dates__c>();
            
        for(Flow_Through_Dates__c obj : lstFlowThroughDates){
            Date DateFts = (obj.Flow_Through_Start_Date__c);
            Datetime formattedDate = datetime.newInstance(DateFts.year(), DateFts.month(),DateFts.day());
            String str =formattedDate.format('MM/dd/yyyy');
            String FTSDate = str.replaceAll('/','');
            String key = obj.Retailer_Name__c + '_' + obj.Country_Code__c + '_' + obj.GTIN_Padded__c + '_' + FTSDate;
            FTKeys.add(key);
        }
        for(Flow_Through_Dates__c prodRec : [SELECT Id, Name,Flow_Through_Dates_Key__c FROM Flow_Through_Dates__c WHERE Flow_Through_Dates_Key__c IN : FTKeys]){
            String key = prodRec.Flow_Through_Dates_Key__c;
            if(!mapFTDates.containsKey(key) && FTKeys.contains(key)){
                mapFTDates.put(key, prodRec);
            }
        }
        for(Flow_Through_Dates__c obj : lstFlowThroughDates){
            String error = '';
            Date DateFts = (obj.Flow_Through_Start_Date__c);
            Datetime formattedDate = datetime.newInstance(DateFts.year(), DateFts.month(),DateFts.day());
            String str =formattedDate.format('MM/dd/yyyy');
            String FTSDate = str.replaceAll('/','');
            String key = obj.Retailer_Name__c + '_' + obj.Country_Code__c + '_' + obj.GTIN_Padded__c + '_' + FTSDate;
            if(!mapFTDates.isEmpty() && mapFTDates.containsKey(key)){
                error += String.format(system.label.WBCP_FT_Dates_Duplicates_Error_Msg, new String[] {mapFTDates.get(key).Name});
            }
            if(error != ''){
                obj.addError(error);
            }
            else{
                obj.Flow_Through_Dates_Key__c = key;
            }
        }                            
    }
    public static void checkExistingCPProducts(List<Flow_Through_Dates__c> lstFlowThroughDates){
        
        Set<String> RetailerVal = new Set<String>();
        Set<String> CountryCodeVal = new Set<String>();
        Set<String> GTINPaddedVal = new Set<String>();
        Set<String> CPProductKey= new Set<String>();
        
        for(Flow_Through_Dates__c FTD: lstFlowThroughDates){
            RetailerVal.add(FTD.Retailer_Name__c);    
            CountryCodeVal.add(FTD.Country_Code__c);
            GTINPaddedVal.add(FTD.GTIN_Padded__c);
        }
        
        List<CP_Product__c> listCPProducts = [SELECT id,cp_Retailer_Name__c,cp_Country_Code__c,GTIN_Padded__c FROM CP_Product__c WHERE cp_Retailer_Name__c IN :RetailerVal and cp_Country_Code__c IN :CountryCodeVal and GTIN_Padded__c IN :GTINPaddedVal];
        for(CP_Product__c objcp : listCPProducts){
            String Key=objcp.cp_Retailer_Name__c+'_'+objcp.cp_Country_Code__c+'_'+objcp.GTIN_Padded__c;
            CPProductKey.add(Key);
        }
        
        for(Flow_Through_Dates__c FTD : lstFlowThroughDates){
            String FTDKey=FTD.Retailer_Name__c+'_'+FTD.Country_Code__c+'_'+FTD.GTIN_Padded__c;
            if(!CPProductKey.contains(FTDKey)){
                FTD.addError(System.Label.WBCP_CP_Product_Does_Not_Exist);
            }
        } 
    }
}