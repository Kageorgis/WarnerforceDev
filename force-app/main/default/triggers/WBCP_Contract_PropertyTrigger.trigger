trigger WBCP_Contract_PropertyTrigger on Contract_Property__c (before insert,before update) {
    if(Trigger.isBefore && trigger.isInsert){
        set<string> contractNoSets = new set<string>();
        set<string> propertyNoSets = new set<string>();
        List<String> lstErrors = new List<String>();    
        Map<string,ID> contactMap;
        Map<string,ID> propertyMap;
        
        for(Contract_Property__c cp : Trigger.new){
            contractNoSets.add(cp.Contract_No__c);
            propertyNoSets.add(cp.Property__c);
        }
        contactMap = CP_ProductUtility.getContractMap(contractNoSets);
        propertyMap = CP_ProductUtility.getPropertyMap(propertyNoSets);
        
        try{
            for(Contract_Property__c cp : Trigger.new){
                if(contactMap.get(cp.Contract_No__c) != null){
                    cp.Contract__c =contactMap.get(cp.Contract_No__c); 
                }else {
                       lstErrors.add(cp.Contract_No__c);
                }
                cp.cp_Property__c= propertyMap.get(cp.Property__c);
            } 
            if(lstErrors.size() > 0){
                throw new DMLException('Invalid Contract No');
            }
        }catch (DMLException ex){
            ex.setMessage('You are trying to insert contract No='+lstErrors+' Not present in Salesforce');
            throw ex;
        }
    }               
}