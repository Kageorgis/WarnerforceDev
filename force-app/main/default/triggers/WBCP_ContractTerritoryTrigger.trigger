/*******************************************************************************************************************************************
* File Name     : WBCP_ContractTerritoryTriggerHandler  
@CreateDate July May 2021
* Description   :  perform action to update contract based on contract code on before insert .
* @author       :   CTS
********************************************************************************************************************************************/

trigger WBCP_ContractTerritoryTrigger on Contract_Territory__c (before insert) {
    if(Trigger.isBefore && trigger.isInsert){
        set<string> contractNoSets = new set<string>();
        set<string> territoryCodeSets = new set<string>();
        List<String> lstContractErrors = new List<String>(); 
        
        Map<string,ID> contactMap;
        Map<string,ID> territoryMap;
         
        for(Contract_Territory__c contractTerritory : Trigger.new){
            contractNoSets.add(contractTerritory.Contract_No__c);
            territoryCodeSets.add(contractTerritory.Territory_Code__c);
        }
        contactMap = CP_ProductUtility.getContractMap(contractNoSets);
        territoryMap = CP_ProductUtility.getTerritoryMap(territoryCodeSets);
        try{
            for(Contract_Territory__c contractTerritory : Trigger.new){
                if(contactMap.get(contractTerritory.Contract_No__c) !=null){
                   contractTerritory.Contract__c = contactMap.get(contractTerritory.Contract_No__c);    
                }else{
                     lstContractErrors.add(contractTerritory.Contract_No__c);
                }
               contractTerritory.Territory__c = territoryMap.get(contractTerritory.Territory_Code__c);  
            }
            if(lstContractErrors.size()>0){
                 throw new DMLException('Invalid Contract No');
            }
        } catch(DMLException ex){
              ex.setMessage('You are trying to insert contract No='+lstContractErrors+' is not present in Salesforce.');
           throw ex;   
        }
    }
}