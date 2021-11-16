public Without Sharing class WB_Distinct_PriceCodes {
    public Boolean allowContinue { get; private set; }
    public List<String> distinctPriceCodes { get; private set ;}

    public WB_Distinct_PriceCodes() {
        Set<String> distinctCountryContentType = new Set<String>();

        // Sample Test data - start
        /*distinctCountryContentType.add('USA_Feature');
        distinctCountryContentType.add('Canada_Feature');
        distinctCountryContentType.add('United Kingdom_Feature');*/
        // Sample Test data - end        
        distinctCountryContentType.addAll(ApexPages.currentPage().getparameters().get('dt').split(';'));
        system.debug('distinctCountryContentType passed value...'+ApexPages.currentPage().getparameters().get('dt'));
        system.debug('distinctCountryContentType...'+distinctCountryContentType);
        Map<String,Set<String>> cntryCntTypeMap = new Map<String,Set<String>>();
        Set<String> firstSet = new Set<String>();
        Set<String> distinctPriceCodeValues = new Set<String>();

        for(String cntryCntType : distinctCountryContentType){
            integer i = 0;
            Set<String> priceCodes = new Set<String>();
            for(Pricing__c pricingRecord : [SELECT Id, Name FROM Pricing__c WHERE Country_Content_Type__c = :cntryCntType AND Price_Code_Status__c = 'Active']){
                if(i==0)
                    firstSet.add(pricingRecord.Name);
                priceCodes.add(pricingRecord.Name);
            }
            cntryCntTypeMap.put(cntryCntType,priceCodes);
        }
        
        for(String fs : firstSet){
            Boolean isFound = true;
            for(Set<String> priceCodes : cntryCntTypeMap.values()){
                if(!priceCodes.contains(fs)){
                    isFound = false;
                    break;
                }
            }
            if(isFound)
                distinctPriceCodeValues.add(fs);
        }
            
        allowContinue = distinctPriceCodeValues.size() > 0;
        if (!allowContinue) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'No common price code values found for the country and content type selected'));
    
        distinctPriceCodes = new List<String>();
        distinctPriceCodes.addAll(distinctPriceCodeValues);
        distinctPriceCodes.sort();
    }
}