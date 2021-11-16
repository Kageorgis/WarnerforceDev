trigger WBCP_ContractProductTrigger on Contract_Product__c (before insert,before update) {
    if(Trigger.isBefore && trigger.isInsert){
        set<string> contractNoSets = new set<string>();
        set<string> productDetlSets = new set<string>();
        
        Map<string,ID> contactMap;
        Map<string,ID> productDetlsMap;
        List<String> lstContractErrors = new List<String>(); 
        
        for(Contract_Product__c contractProd : Trigger.new){
            contractNoSets.add(contractProd.Contract_No__c);
            productDetlSets.add(contractProd.Product_Detail__c);
        }
        contactMap = CP_ProductUtility.getContractMap(contractNoSets);
        productDetlsMap = CP_ProductUtility.getProductMap(productDetlSets);
        try{
            for(Contract_Product__c contractProd : Trigger.new){
                if(contactMap.get(contractProd.Contract_No__c) !=null){
                     contractProd.Contract__c= contactMap.get(contractProd.Contract_No__c); 
                }else{
                     lstContractErrors.add(contractProd.Contract_No__c);
                }
              contractProd.WBCP_Master_Product__c= productDetlsMap.get(contractProd.Product_Detail__c);
            }
            if(lstContractErrors.size()>0){
                  throw new DMLException('Invalid Contract No');
            }
        }catch(DmlException ex){
            ex.setMessage('You are trying to insert contract No='+lstContractErrors+' is not present in Salesforce.');
            throw ex; 
        }
    }
}