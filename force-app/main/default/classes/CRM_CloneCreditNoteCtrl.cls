public with sharing class CRM_CloneCreditNoteCtrl {
    public boolean aleradyRCNExist{get; set;}
    public static Set<String> fieldsNotExclude = new Set<String>{'Reversal_Credit_Note__c','Id','RecordTypeId','Status__c','Credit_Note_Type__c'};
    public CRM_CloneCreditNoteCtrl(Apexpages.StandardController stdCon) {
    	aleradyRCNExist = false;
    	Id cnId = ApexPages.currentPage().getParameters().get('id');
        if(cnId != null){
            Integer reversalCNCount = [SELECT count() FROM Credit_Note__C WHERE Reversal_Credit_Note__c = :cnId];
            if(reversalCNCount > 0 ){
            	aleradyRCNExist = true;
            }
        }
    }
    
    @RemoteAction 
    public static Id cloneCreditNote(Id CNID,String CNStatus,String CNSON,String CNHS){
        Id creditNoteId = null;
        List<DealCreditNote__c> lstDealCreditNoteToInsert = new List<DealCreditNote__c>();
        
        String SOQL_QUERY = 'SELECT ' + String.join(getCNFieldsToCopy(), ', ');
        SOQL_QUERY += ' FROM Credit_Note__c';
        SOQL_QUERY += ' WHERE Id=\''+ CNID +'\'';
        
        Credit_Note__c[] lstCreditNote = new  List<Credit_Note__c>();
        lstCreditNote = (Credit_Note__c[])Database.Query(SOQL_QUERY);
		
        if(!lstCreditNote.isEmpty()){
        	if(CNStatus != CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED){
        		if(CNSON != null && CNHS == CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_SAP){
        			lstCreditNote[0].Reversal_Credit_Note__c = lstCreditNote[0].Id;
					lstCreditNote[0].Id = null;
					lstCreditNote[0].RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_REVERSE;
					lstCreditNote[0].Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED;
					lstCreditNote[0].Credit_Note_Type__c = CRM_AppConstants.CREDIT_NOTE_TYPE_REVERSAL;
					lstCreditNote[0].PO_Number__c = CNSON;
					try{
		                insert lstCreditNote;
		                creditNoteId = lstCreditNote[0].Id;
		            }catch(System.DmlException ex){
		                throw new CRM_CloneCreditNoteException(ex.getDmlMessage(0));
		            }
        		}else{
        			throw new CRM_CloneCreditNoteException(System.label.CRM_Credit_Note_Not_IN_SAP);
        		}
        	}else{
        		throw new CRM_CloneCreditNoteException(System.label.CRM_Rejected_Credit_Note_Reverse_Error_Msg);
        	}
            
        }
        
        //Insert DealCreditNote records
        if(CNID != null){
        	List<DealCreditNote__c> lstDealCreditNote = [Select Opportunity__c From DealCreditNote__c Where Credit_Note__c = :CNID];
			System.debug('#lstDealCreditNote' + lstDealCreditNote);
			            
            Set<Id> setDealIds = new Set<Id>();
            for(DealCreditNote__c dealCreditNote: lstDealCreditNote){
                setDealIds.add(dealCreditNote.Opportunity__c);
            }
            System.debug('#setDealIds' + setDealIds);
            
            for(Id id: setDealIds){
                DealCreditNote__c dealCreditNote = new DealCreditNote__c();
                dealCreditNote.Opportunity__c = id;
                dealCreditNote.Credit_Note__c = creditNoteId;
				dealCreditNote.Unique_Key__c = Id + '-' + creditNoteId;
                lstDealCreditNoteToInsert.add(dealCreditNote);
            }
        }
        
        System.debug('#lstDealCreditNoteToInsert' + lstDealCreditNoteToInsert);
        if(!lstDealCreditNoteToInsert.isEmpty()){
        	try{
                insert lstDealCreditNoteToInsert;
            }catch(System.DmlException ex){
                throw new CRM_CloneCreditNoteException(ex.getDmlMessage(0));
            }
        }
        
        return creditNoteId;
    }
    
    @RemoteAction 
    public static cloneError[] cloneCreditNoteItems(Id clonedCreditNoteId, Id[] creditNoteItemIds){
        String SOQL_DCI_QUERY = 'SELECT ' + String.join(getCNIFieldsToCopy(), ', ');
        SOQL_DCI_QUERY += ' FROM Credit_Note_Item__c';
        SOQL_DCI_QUERY += ' WHERE Id IN :creditNoteItemIds';
        
        Credit_Note_Item__c[] listCreditNoteItems = (Credit_Note_Item__c[]) Database.Query(SOQL_DCI_QUERY);
		
        for(Credit_Note_Item__c dci : listCreditNoteItems) {
            dci.Id = null;
            //Creating UniqueId
            String originalUniqueId = dci.Unique_Id__c;
            List<String> splitteUniqueId = originalUniqueId.split('-');
            splitteUniqueId.remove(0);
            splitteUniqueId.add(0, clonedCreditNoteId);
            String UniqueId = string.join(splitteUniqueId,'-');
            dci.Unique_Id__c = UniqueId;
            
            dci.Credit_Note__c = clonedCreditNoteId;
        }
		
        Database.SaveResult[] dciInsertResults = Database.insert(listCreditNoteItems, false);
        return getSaveErrors(dciInsertResults,listCreditNoteItems);
    }
    
    private static cloneError[] getSaveErrors(Database.SaveResult[] saveResults, Credit_Note_Item__c[] listCreditNoteItems) {
        cloneError[] errors = new cloneError[]{};
        for(Integer i=0; i< saveResults.size(); i++) {
            if(!saveResults[i].isSuccess()) {
                cloneError err = new cloneError();
                err.creditNoteItems = listCreditNoteItems[i].Name;
                err.error = saveResults[i].getErrors()[0].getMessage();
                errors.add(err);
            }
        }
        return errors;
    }
	
    private static String[] getCNFieldsToCopy(){
        Set<String> setCNAllFields = getSObjectFields('Credit_Note__c');
        Set<String> setCNFieldsToExclude = getFieldsToExclude('Credit_Note__c');
        setCNAllFields.removeAll(setCNFieldsToExclude);
        return new List<String>(setCNAllFields);
    }
	
    private static String[] getCNIFieldsToCopy(){
        Set<String> setCNIAllFields = getSObjectFields('Credit_Note_Item__c');
        Set<String> setCNIFieldsToExclude = getFieldsToExclude('Credit_Note_Item__c');
        for(String fieldNotExclude : fieldsNotExclude){
        	if(setCNIFieldsToExclude.contains(fieldNotExclude)){
        		setCNIFieldsToExclude.remove(fieldNotExclude);		
        	}
        }
        setCNIAllFields.removeAll(setCNIFieldsToExclude);
        return new List<String>(setCNIAllFields);
    }
	
    private static Set<String> getSObjectFields(String objectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        Set<String> setAllFields = new Set<String>();
        
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            Schema.describeFieldResult dfield = sfield.getDescribe();

            if(!dfield.isAutoNumber() && !dfield.isCalculated() && dfield.isCreateable() ) {
                setAllFields.add(dfield.getName());
            }
        }
        return setAllFields;
    }
    
	private static List<Schema.FieldSetMember> getFieldsFromFieldset (String objName) {
        if(objName.equals('Credit_Note__c'))
            return SObjectTYpe.Credit_Note__c.FieldSets.ExcludeFieldsInClone.getFields();
        else if(objName.equals('Credit_Note_Item__c'))
            return SObjectTYpe.Credit_Note_Item__c.FieldSets.ExcludeFieldsInClone.getFields();
            
        return null;    
    }
    
    private static Set<String> getFieldsToExclude(String objectName) {
        Set<String> fieldsToExclude = new Set<String>();
        
        for (Schema.FieldSetMember field : getFieldsFromFieldset(objectName)) 
            fieldsToExclude.add(field.getFieldPath());
                
        return fieldsToExclude;
    }
    
    public class cloneError {
        public String creditNoteItems {get;set;}
        public String error {get;set;}
    }
	
    public class CRM_CloneCreditNoteException extends Exception {}
}