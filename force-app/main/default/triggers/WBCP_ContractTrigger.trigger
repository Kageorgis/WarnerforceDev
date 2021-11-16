/*******************************************************************************************************************************************
* File Name     :   WBCP_ContractTrigger
  @CreateDate July May 2021
* Description   :   Trigger for Handler to update Licensse and based Licensee Code.
* @author       :   CTS
********************************************************************************************************************************************/
trigger WBCP_ContractTrigger on CP_Contract__c (before insert,before update) {
    Map<string,ID> accMap = new Map<string,ID>();
    set<string> licenseeCodeSets = new set<string>();
    String licenseeRecTypeId = CP_ProductUtility.getRecordTypeId(CP_Contract__c.getSobjectType(),'WBCP Contracts'); 
    for(CP_Contract__c contract : trigger.new){
         if(licenseeRecTypeId ==contract.RecordTypeId ){
              licenseeCodeSets.add(contract.Licensee_Code__c);
         }
    }
    accMap =CP_ProductUtility.getAccIdsbyLicenseeCodes(licenseeCodeSets);
   
    if(Trigger.isBefore){
           for(CP_Contract__c contract : trigger.new){
               if(licenseeRecTypeId ==contract.RecordTypeId )
               {
                   if(trigger.isInsert){
                       contract.Account_Licensee__c=accMap.get(contract.Licensee_Code__c);
                   }
                   if(Trigger.isUpdate)
                   {
                       if(Trigger.oldMap.get(contract.id).Licensee_Code__c != contract.Licensee_Code__c){
                           contract.Account_Licensee__c= accMap.get(contract.Licensee_Code__c);
                       }
                   }
               }
        }
         
    }
}