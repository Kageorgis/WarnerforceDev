public with sharing class CRM_CloneDecayCurveTemplateController {
    public CRM_CloneDecayCurveTemplateController(Apexpages.StandardController stdCon) {}
    
    @RemoteAction 
    public static Id cloneDecayCurveTemplate(Id dctId,String dctName, String dctCurrency){
        Id decayCurveTemplateId = null;
        String SOQL_DCT_QUERY = 'SELECT ' + String.join(getDCTFieldsToCopy(), ', ');
        SOQL_DCT_QUERY += ' FROM Decay_Curve_Template__c';
        SOQL_DCT_QUERY += ' WHERE Id=\''+ dctId +'\'';
        
        Decay_Curve_Template__c[] listDCTs = new  List<Decay_Curve_Template__c>();
        listDCTs = (Decay_Curve_Template__c[])Database.Query(SOQL_DCT_QUERY);
        if(!listDCTs.isEmpty()){
        	listDCTs[0].Id = null;
	        listDCTs[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_DRAFT;
	        Decimal dctVersionNumber = getVersionNumberForClonedDCT(dctName,dctCurrency);
	        listDCTs[0].Version_Number__c = (dctVersionNumber != null ? dctVersionNumber : listDCTs[0].Version_Number__c) + 1;
	        try{
	            insert listDCTs;
	            decayCurveTemplateId = listDCTs[0].Id;
	        }catch(System.DmlException ex){
	            throw new CRM_CloneDealException(ex.getDmlMessage(0));
	        }
	    }
        return decayCurveTemplateId;
    }
    
    @RemoteAction 
    public static DCISaveError[] cloneDecayCurveItems(Id clonedDCTId, Id[] decayCurveItemIds){
        String SOQL_DCI_QUERY = 'SELECT ' + String.join(getDCIFieldsToCopy(), ', ');
        SOQL_DCI_QUERY += ' FROM Decay_Curve_Item__c';
        SOQL_DCI_QUERY += ' WHERE Id IN :decayCurveItemIds';
        
        Decay_Curve_Item__c[] listDecayCurveItems = (Decay_Curve_Item__c[]) Database.Query(SOQL_DCI_QUERY);
        for(Decay_Curve_Item__c dci : listDecayCurveItems) {
            dci.Id = null;
            dci.Decay_Curve_Template__c = clonedDCTId;
        }
        Database.SaveResult[] dciInsertResults = Database.insert(listDecayCurveItems, false);
        return getSaveErrors(dciInsertResults,listDecayCurveItems);
    }
    
    private static Decimal getVersionNumberForClonedDCT(String dctName, String dctCurrency){
    	List<Decay_Curve_Template__c> listOfDCT = [SELECT Version_Number__c
                           						   FROM Decay_Curve_Template__c 
                           						   WHERE Name =:dctName AND CurrencyIsoCode =:dctCurrency ORDER BY Version_Number__c DESC NULLS LAST];
    	if(!listOfDCT.isEmpty())
    		return listOfDCT[0].Version_Number__c;
    	
    	return null;
    }
    private static DCISaveError[] getSaveErrors(Database.SaveResult[] saveResults, Decay_Curve_Item__c[] listDecayCurveItems) {
        DCISaveError[] errors = new DCISaveError[]{};
        for(Integer i=0; i< saveResults.size(); i++) {
            if(!saveResults[i].isSuccess()) {
                DCISaveError err = new DCISaveError();
                err.decayCurveItem = listDecayCurveItems[i].Name;
                err.error = saveResults[i].getErrors()[0].getMessage();
                errors.add(err);
            }
        }
        return errors;
    }
    private static String[] getDCTFieldsToCopy(){
        Set<String> setDCTAllFields = getSObjectFields('Decay_Curve_Template__c');
        return new List<String>(setDCTAllFields);
    }
    private static String[] getDCIFieldsToCopy(){
        Set<String> setDCIAllFields = getSObjectFields('Decay_Curve_Item__c');
        return new List<String>(setDCIAllFields);
    }
    private static Set<String> getSObjectFields(String objectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        Set<String> setAllFields = new Set<String>();
        
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            Schema.describeFieldResult dfield = sfield.getDescribe();

            if(!dfield.isAutoNumber() && !dfield.isCalculated() && dfield.isCreateable() ) {
                setAllFields.add(dfield.getName());
                system.debug('DCT/DCI Field API Name : '+dfield.getName());
            }
        }
        return setAllFields;
    }
    public class DCISaveError {
        public String decayCurveItem {get;set;}
        public String error {get;set;}
    }
    public class CRM_CloneDealException extends Exception {}
}