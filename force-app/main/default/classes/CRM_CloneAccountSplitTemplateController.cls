public with sharing class CRM_CloneAccountSplitTemplateController {
    public CRM_CloneAccountSplitTemplateController(Apexpages.StandardController stdCon) {}
    
    @RemoteAction 
    public static Id cloneAccountSplitTemplate(Id astId,String astName, String astCurrency){
        Id accountSplitTemplateId = null;
        String SOQL_DCT_QUERY = 'SELECT ' + String.join(getASTFieldsToCopy(), ', ');
        SOQL_DCT_QUERY += ' FROM Target_Split_Template__c';
        SOQL_DCT_QUERY += ' WHERE Id=\''+ astId +'\'';
        
        Target_Split_Template__c[] listDCTs = new  List<Target_Split_Template__c>();
        listDCTs = (Target_Split_Template__c[])Database.Query(SOQL_DCT_QUERY);
        if(!listDCTs.isEmpty()){
          listDCTs[0].Id = null;
          listDCTs[0].ownerId = UserInfo.getUserId();
          listDCTs[0].Name = listDCTs[0].Name + ' - Copy ' + DateTime.now().year() + 
            (String.valueof(DateTime.now().month()).length() == 1 ? ('0' + String.valueof(DateTime.now().month())) : String.valueof(DateTime.now().month()))
            + (String.valueof(DateTime.now().day()).length() == 1 ? '0' + String.valueof(DateTime.now().day()) : String.valueof(DateTime.now().day()))
            +(String.valueof(DateTime.now().hour()).length() == 1 ? '0' + String.valueof(DateTime.now().hour()) : String.valueof(DateTime.now().hour()))
            +(String.valueof(DateTime.now().minute()).length() == 1 ? '0' + String.valueof(DateTime.now().minute()) : String.valueof(DateTime.now().minute()))
            +(String.valueof(DateTime.now().second()).length() == 1 ? '0' + String.valueof(DateTime.now().second()) : String.valueof(DateTime.now().second()));

          try{
              insert listDCTs;
              accountSplitTemplateId = listDCTs[0].Id;
              
          }catch(System.DmlException ex){
              throw new CRM_CloneAccountSplitTemplateException(ex.getDmlMessage(0));
          }
      }
        return accountSplitTemplateId;
    }
    
    @RemoteAction 
    public static ASLSaveError[] cloneAccountSplits(Id clonedASTId, Id[] accountSplitIds){
        String SOQL_ASL_QUERY = 'SELECT ' + String.join(getASLFieldsToCopy(), ', ');
        SOQL_ASL_QUERY += ',Name FROM Account_Split__c';
        SOQL_ASL_QUERY += ' WHERE Id IN :accountSplitIds';
        
        Account_Split__c[] listAccountSplits = (Account_Split__c[]) Database.Query(SOQL_ASL_QUERY);
        for(Account_Split__c accSplit : listAccountSplits) {
            accSplit.Id = null;
            accSplit.Target_Split_Template__c = clonedASTId;
            accSplit.Unique_Customer_Id__c = clonedASTId + '-' + accSplit.Account__c;
        }
        Database.SaveResult[] aslInsertResults = Database.insert(listAccountSplits, false);
        return getSaveErrors(aslInsertResults,listAccountSplits);
    }
    
    private static ASLSaveError[] getSaveErrors(Database.SaveResult[] saveResults, Account_Split__c[] listAccountSplits) {
        ASLSaveError[] errors = new ASLSaveError[]{};
        for(Integer i=0; i< saveResults.size(); i++) {
            if(!saveResults[i].isSuccess()) {
                ASLSaveError err = new ASLSaveError();
                err.accountSplit = listAccountSplits[i].Name;
                err.error = saveResults[i].getErrors()[0].getMessage();
                errors.add(err);
            }
        }
        return errors;
    }
    private static String[] getASTFieldsToCopy(){
        Set<String> setDCTAllFields = getSObjectFields('Target_Split_Template__c');
        return new List<String>(setDCTAllFields);
    }
    private static String[] getASLFieldsToCopy(){
        Set<String> setDCIAllFields = getSObjectFields('Account_Split__c');
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
                system.debug('AST/ASL Field API Name : '+dfield.getName());
            }
        }
        return setAllFields;
    }
    public class ASLSaveError {
        public String accountSplit {get;set;}
        public String error {get;set;}
    }
    public class CRM_CloneAccountSplitTemplateException extends Exception {}


}