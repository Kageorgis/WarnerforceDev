public class CloneDealAndRelatedLists {
    private static final String DEAL_QUALIFIED_API_NAME = 'Opportunity';
    private static final String RELATED_CONTACT_QUALIFIED_API_NAME = 'WBSF_Related_Contacts__c';
    private static final String RELATED_COMPANY_QUALIFIED_API_NAME = 'WBSF_Related_Company__c';
    
    @AuraEnabled
    public static Opportunity getDeal(Id dealId) {
        return [SELECT Name FROM Opportunity WHERE Id = :dealId];
    }
    
    @AuraEnabled
    public static String cloneDealFromRecord(String dealIdToClone, String dealName) {
        List<DealsWrapper.Column> fieldReferences = getAvailableFields();
        Boolean addCompanyField = true;
        for(DealsWrapper.Column checkField : fieldReferences) if(checkField.originalFieldName.equals('Company__c')) addCompanyField = false;
        if(addCompanyField) {
            DealsWrapper.Column companyField = new DealsWrapper.Column();
            companyField.objectLabel = 'Deals';
            companyField.originalFieldName = 'Company__c';
            fieldReferences.add(companyField);
        }
        String query = 'SELECT ';
        for(DealsWrapper.Column field : fieldReferences) {
            if(field.objectLabel.equals('Deals')) query += field.originalFieldName+', ';
        }
        query += 'RecordTypeId FROM Opportunity WHERE Id = \''+dealIdToClone+'\' LIMIT 1';
        system.debug(query);
        List<sObject> record = Database.query(query);
        Opportunity newDeal = (Opportunity) record.get(0);
        List<User> users = [Select id, Department from User where id =:UserInfo.getUserId()];
        newDeal.Id = null;
        newDeal.Name = dealName;
        newDeal.OwnerId = UserInfo.getUserId();
        newDeal.CreatedById = UserInfo.getUserId();
        newDeal.CreatedDate = null;
        newDeal.WB_Department_text__c = !users.isEmpty() ? users[0].Department : null;
        newDeal.Owner_Role_Department__c = null;
        insert newDeal;
        String newDealId = ID.valueOf(newDeal.Id);
        List<WBSF_Related_Contacts__c> contactsToClone = [SELECT WBSF_Contact__c, WBSF_Role__c, Relationship_Strength__c FROM WBSF_Related_Contacts__c WHERE WBSF_Deal__c = :dealIdToClone];
        List<WBSF_Related_Contacts__c> newContacts = new List<WBSF_Related_Contacts__c>();
        for(WBSF_Related_Contacts__c contact : contactsToClone) {
            WBSF_Related_Contacts__c relatedContact = new WBSF_Related_Contacts__c();
            relatedContact.WBSF_Deal__c = newDeal.Id;
            relatedContact.WBSF_Contact__c = contact.WBSF_Contact__c;
            relatedContact.WBSF_Role__c = contact.WBSF_Role__c;
            relatedContact.Relationship_Strength__c = contact.Relationship_Strength__c;
            newContacts.add(relatedContact);
        }
        insert newContacts;
        List<WBSF_Related_Company__c> companiesToClone = [SELECT WBSF_Company__c, WBSF_Role__c FROM WBSF_Related_Company__c WHERE WBSF_Deal__c = :dealIdToClone];
        List<WBSF_Related_Company__c> newCompanies = new List<WBSF_Related_Company__c>();
        for(WBSF_Related_Company__c company : companiesToClone) {
            WBSF_Related_Company__c relatedCompany = new WBSF_Related_Company__c();
            relatedCompany.WBSF_Deal__c = newDeal.Id;
            relatedCompany.WBSF_Company__c = company.WBSF_Company__c;
            relatedCompany.WBSF_Role__c = company.WBSF_Role__c;
            if(!relatedCompany.WBSF_Company__c.equals(newDeal.Company__c)) newCompanies.add(relatedCompany);
        }
        insert newCompanies;
        return newDealId;
    }
    
    @AuraEnabled
    public static List<DealsWrapper.Column> getAvailableFields(){
        Set<String> fieldsRestricted = new Set<String>();
        fieldsRestricted.add('IsDeleted');
        fieldsRestricted.add('LastReferencedDate');
        fieldsRestricted.add('LastViewedDate');
        fieldsRestricted.add('UserRecordAccessId');
        fieldsRestricted.add('SystemModstamp');
        fieldsRestricted.add('IqScore');
        
        /*
        Map<String,String> dataType = new Map<String,String>();
        dataType.put('address','');
        _dataType.put('boolean','');
        _dataType.put('currency','');
        dataType.put('date','');
        dataType.put('datetime','');
        _dataType.put('double','');
        _dataType.put('email','');
        _dataType.put('id','');
        _dataType.put('integer','');
        _dataType.put('multipicklist','');
        _dataType.put('percent','');
        _dataType.put('phone','');
        _dataType.put('picklist','text');
        _dataType.put('reference','');
        _dataType.put('string','text');
        _dataType.put('textarea','text');
        dataType.put('time','');
        dataType.put('url','');
        */
        
        List<String> apiNames = new List<String>();
        apiNames.add(DEAL_QUALIFIED_API_NAME);
        apiNames.add(RELATED_COMPANY_QUALIFIED_API_NAME);
        apiNames.add(RELATED_CONTACT_QUALIFIED_API_NAME);
        
        Set<String> opportunityFields = getOpportunityLayoutFields();
        
        Map<String,DealsWrapper.Column> fieldMap = new Map<String,DealsWrapper.Column>();
        List<DealsWrapper.Column> availableFields = new List<DealsWrapper.Column>();
        Schema.DescribeSobjectResult[] results  = Schema.describeSObjects(apiNames);
        for(Schema.DescribeSobjectResult describeResult  : results){                
            if(describeResult.isAccessible()) {
                //System.debug(describeResult.getName()+'~~~~~~~~~~~~~~is accessible to this user');
                for(Schema.SobjectField  field : describeResult.fields.getMap().values()){
                    if(
                        field.getDescribe().isAccessible() && 
                        !fieldsRestricted.contains(field.getDescribe().getName()) && 
                        !field.getDescribe().getName().equals('RecordTypeId')
                    ){
                        DealsWrapper.Column referenceColumn = new DealsWrapper.Column();
                        referenceColumn.label = field.getDescribe().getLabel();
                        referenceColumn.apiName = describeResult.getName()+'.'+field.getDescribe().getName();
                        String relationship = '';
                        referenceColumn.objectLabel = 'Deals';
                        if(describeResult.getName().equals(RELATED_CONTACT_QUALIFIED_API_NAME)) {
                            relationship = 'Related_Contacts__r.';
                            referenceColumn.isChild = true;
                            referenceColumn.objectLabel = 'Related Contacts';
                        } else if(describeResult.getName().equals(RELATED_COMPANY_QUALIFIED_API_NAME)) {
                            relationship = 'Related_Companies__r.';
                            referenceColumn.isChild = true;
                            referenceColumn.objectLabel = 'Related Companies';
                        }
                        referenceColumn.originalFieldName = field.getDescribe().getName();
                        referenceColumn.fieldName = relationship+field.getDescribe().getName();
                        referenceColumn.fieldType = field.getDescribe().getType().name().toLowercase();
                        Boolean addColumn = true;
                        if(describeResult.getName().equals(DEAL_QUALIFIED_API_NAME) && !opportunityFields.contains(referenceColumn.apiName)) addColumn = false;
                        if(referenceColumn.fieldType.equals('reference')) {
                            referenceColumn.label = field.getDescribe().getLabel().replace('ID','Name');
                            if(field.getDescribe().getRelationshipName().equals('WBSF_Contact__r')) {
                                referenceColumn.label = 'WBSF '+field.getDescribe().getLabel();
                            }
                            referenceColumn.apiName = describeResult.getName()+'.'+field.getDescribe().getRelationshipName()+'.Name';
                        	referenceColumn.fieldName = relationship+field.getDescribe().getRelationshipName();
                        }
                        
                        if(addColumn) availableFields.add(referenceColumn);
                        //system.debug(referenceColumn);
                        //system.debug(describeResult.getName()+'.'+field.getDescribe().getName()+'~~~~~~~~~~~~~~~~~~~~type: '+field.getDescribe().getType().name().toLowercase()+' - '+field.getDescribe().getPrecision()+'_'+field.getDescribe().getScale());
                        //system.debug(describeResult.getName()+'.'+field.getDescribe().getName()+'~~~~~~~~~~~~~~~~~~~~label: '+field.getDescribe().getLabel()+' - '+field.getDescribe().getRelationshipName());
                    }
                }
            }
        }
        return availableFields;
    }
    
    private static Set<String> getOpportunityLayoutFields() {
        List<Metadata.Metadata> layouts =  Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {'Opportunity-WBSF Studio Deal Layout'});
        Set<String> opportunityFields = new Set<String>();
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        for (Metadata.LayoutSection section : layoutMd.layoutSections) {
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                if (column.layoutItems != null) {
                    for (Metadata.LayoutItem item : column.layoutItems) {
                        if(item.field != null) {
                            opportunityFields.add('Opportunity.'+item.field);
                        }
                    }
                }
            }
        }
        opportunityFields.add('Opportunity.Id');
        opportunityFields.add('Opportunity.CreatedById');
        opportunityFields.add('Opportunity.CreatedDate');
        return opportunityFields;
    }
    
}