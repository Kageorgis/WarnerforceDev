/**
@Author Cognizant
@name CRM_ActivateCreditNote 
@CreateDate 2 JAN 2018
@Description controller for vf to activate the credit note and change the status to Send to SAP
@Version <1.0>
@reference
*/
public with sharing class CRM_ActivateCreditNote{
    
    public CRM_ActivateCreditNote(Apexpages.StandardController stdCon) {}
    
    /** 
*  @description: - This method is used to activate the credit note by changing the status to Send to SAP
*  @name: activateCreditNoteToSendToSAP
*  @return: Credit note ID
*/ 
    @RemoteAction 
    public static void activateCreditNoteToSendToSAP(Id CNID,String CNStatus){
        List<DealCreditNote__c> lstDealCreditNoteToInsert = new List<DealCreditNote__c>();
        List<Credit_Note__c> lstCreditNote =  [SELECT ID,Status__c, Credit_Note_Item_Count__c FROM Credit_Note__c WHERE Id =:CNID ]; 
        Schema.DescribeSObjectResult descResult =  Credit_Note__c.sObjectType.getDescribe();
        Map<String, Set<String>> dealMethodOfPayment = new Map<String, Set<String>>();
        Integer queryLimitCount = Limits.getLimitQueryRows() - Limits.getQueryRows();
        Set<String> checkPaid = new Set<String>();
        
        if( descResult.isUpdateable() == false){
            throw new CRM_ActivateCreditNoteException(System.label.CRM_CreditNote_Activation_Error_Privilege);
        }else if(!lstCreditNote.isEmpty()){
            if(lstCreditNote[0].Credit_Note_Item_Count__c == 0){
                throw new CRM_ActivateCreditNoteException(System.label.CRM_Credit_Note_Item_Not_Present);
            }else if(lstCreditNote[0].Status__c == CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED){
                for(AggregateResult ar : [SELECT COUNT(ID) arg0, Deal__r.Method_of_Payment__c arg1, Deal__r.Check_Paid__c arg2 FROM Credit_Note_Item__c 
                                          WHERE (Credit_Note__c=:CNID AND Deal__r.RecordType.DeveloperName=:CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL) 
                                          GROUP BY Deal__r.Method_of_Payment__c, Deal__r.Check_Paid__c LIMIT:queryLimitCount]){
                                              String paymentMethod = (String)ar.get('arg1');
                                              if(!dealMethodOfPayment.containsKey(paymentMethod) && paymentMethod==CRM_AppConstants.DEAL_MOP_CREDIT_MEMO){
                                                  dealMethodOfPayment.put(paymentMethod, new Set<String>());
                                              }else if(paymentMethod==CRM_AppConstants.DEAL_MOP_CHECK){
                                                  checkPaid.add((String)ar.get('arg2'));
                                                  dealMethodOfPayment.put(paymentMethod, checkPaid);
                                              }
                                          }
                
                if(!dealMethodOfPayment.isEmpty()){
                    if(dealMethodOfPayment.containsKey(CRM_AppConstants.DEAL_MOP_CREDIT_MEMO) && dealMethodOfPayment.containsKey(CRM_AppConstants.DEAL_MOP_CHECK)){
                        throw new CRM_ActivateCreditNoteException(System.label.CRM_CreditNoteActivationError_MixedDealMethodOfPayment);
                    }else if(dealMethodOfPayment.containsKey(CRM_AppConstants.DEAL_MOP_CREDIT_MEMO)){
                        lstCreditNote[0].Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY;
                        lstCreditNote[0].ByPassValidationByDate__c = System.now();
                    }
                    else if(dealMethodOfPayment.containsKey(CRM_AppConstants.DEAL_MOP_CHECK)){
                        checkPaid = dealMethodOfPayment.get(CRM_AppConstants.DEAL_MOP_CHECK);
                        if(checkPaid.contains(CRM_AppConstants.DEAL_CHECK_PAID_NO)){
                            throw new CRM_ActivateCreditNoteException(System.label.CRM_CreditNoteActivationError_MixedDealCheckPaid);
                        }else{
                            lstCreditNote[0].Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_PAID;
                            lstCreditNote[0].ByPassValidationByDate__c = System.now();
                        }
                    }
                }else{
                    lstCreditNote[0].Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY;
                    lstCreditNote[0].ByPassValidationByDate__c = System.now();
                }
                try{
                    update lstCreditNote; 
                }catch(System.DmlException ex){
                    throw new CRM_ActivateCreditNoteException(ex.getDmlMessage(0));
                }
            }else{
                throw new CRM_ActivateCreditNoteException(System.label.CRM_CreditNote_Activation_Error);
            }
        }
    }  
    
    public class CRM_ActivateCreditNoteException extends Exception {}
}