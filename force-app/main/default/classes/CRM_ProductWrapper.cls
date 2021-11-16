global class CRM_ProductWrapper implements Comparable{

    public CRM_Product_Group_Update__c prodCustomSetting ;
    
    //Constructor
    public CRM_ProductWrapper(CRM_Product_Group_Update__c  proCS){
        prodCustomSetting = proCS; 
    }
    
    // Compare Custom Setting based on Order field
    global Integer compareTo(Object compareTo){
        
        CRM_ProductWrapper prodWrap = (CRM_ProductWrapper)compareTo;
        Integer returnValue = 0;
        if (prodCustomSetting.Order__c > prodWrap.prodCustomSetting.Order__c) {
            returnValue = 1;
        } else if (prodCustomSetting.Order__c < prodWrap.prodCustomSetting.Order__c) {
            returnValue = -1;
          }
        return returnValue;       
    }
}