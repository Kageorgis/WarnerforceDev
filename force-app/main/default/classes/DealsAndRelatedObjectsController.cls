public with sharing class DealsAndRelatedObjectsController {
    private static final String DEAL_QUALIFIED_API_NAME = 'Opportunity';
    private static final String RELATED_CONTACT_QUALIFIED_API_NAME = 'WBSF_Related_Contacts__c';
    private static final String RELATED_COMPANY_QUALIFIED_API_NAME = 'WBSF_Related_Company__c';
    private static final String DEAL_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Deal').getRecordTypeId();
    
    @AuraEnabled
    public static List<DealsWrapper.View> getListViews() {
		CRM_Deals_Table__c[] cdt = [SELECT
                                    	Id,
                                    	Name,
                                    	Record_Name__c,
                                    	Join_Deals_with__c,
                                    	Restricted__c
                                    FROM
                                    	CRM_Deals_Table__c
                                    WHERE
                                    	OwnerId = :UserInfo.getUserId() AND
                                    	Active__c = true AND
                                    	RecordTypeId = :Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_View').getRecordTypeId()
                                    ORDER BY
                                    	Record_Name__c ASC];
		List<DealsWrapper.View> listViews = new List<DealsWrapper.View>();
        if(cdt.size() == 0) {
            cdt = defaultViews();
        }
        for(CRM_Deals_Table__c cdtView : cdt) {
            DealsWrapper.View view = new DealsWrapper.View();
            view.isSelected = false;
            view.viewId = cdtView.Id;
            view.value = cdtView.Name;
            view.label = cdtView.Record_Name__c;
            view.child = cdtView.Join_Deals_with__c;
            view.isRestricted = cdtView.Restricted__c;
            listViews.add(view);
        }
        return listViews;
    }
    
    private static CRM_Deals_Table__c[] defaultViews() {
        CRM_Deals_Table__c dealWithCompanies = new CRM_Deals_Table__c();
        dealWithCompanies.Record_Name__c = 'All Deals with Related Companies';
        dealWithCompanies.Join_Deals_with__c = 'Related Companies';
        dealWithCompanies.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_View').getRecordTypeId();
        dealWithCompanies.Active__c = true;
        dealWithCompanies.Restricted__c = true;
        insert dealWithCompanies;
        CRM_Deals_Table__c dealWithContacts = new CRM_Deals_Table__c();
        dealWithContacts.Record_Name__c = 'All Deals with Related Contacts';
        dealWithContacts.Join_Deals_with__c = 'Related Contacts';
        dealWithContacts.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_View').getRecordTypeId();
        dealWithContacts.Active__c = true;
        dealWithContacts.Restricted__c = true;
        insert dealWithContacts;
        List<CRM_Deals_Table__c> newFields = new List<CRM_Deals_Table__c>();
        CRM_Deals_Table__c crmCategoryField = new CRM_Deals_Table__c();
        crmCategoryField.List_View_Id__c = dealWithCompanies.Id;
        crmCategoryField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmCategoryField.Record_Name__c = 'Opportunity.WBSF_Project_Phase__c';
        crmCategoryField.Width__c = 0;
        crmCategoryField.Order__c = 0;
        crmCategoryField.Child__c = false;
        crmCategoryField.Restricted__c = true;
        crmCategoryField.Visible__c = false;
        crmCategoryField.Active__c = true;
        newFields.add(crmCategoryField);
        CRM_Deals_Table__c crmDealNameField = new CRM_Deals_Table__c();
        crmDealNameField.List_View_Id__c = dealWithCompanies.Id;
        crmDealNameField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmDealNameField.Record_Name__c = 'Opportunity.Name';
        crmDealNameField.Width__c = 0;
        crmDealNameField.Order__c = 1;
        crmDealNameField.Child__c = false;
        crmDealNameField.Restricted__c = true;
        crmDealNameField.Visible__c = true;
        crmDealNameField.Active__c = true;
        newFields.add(crmDealNameField);
        CRM_Deals_Table__c crmChildNameField = new CRM_Deals_Table__c();
        crmChildNameField.List_View_Id__c = dealWithCompanies.Id;
        crmChildNameField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmChildNameField.Record_Name__c = 'WBSF_Related_Company__c.WBSF_Company__r.Name';
        crmChildNameField.Width__c = 0;
        crmChildNameField.Order__c = 2;
        crmChildNameField.Child__c = true;
        crmChildNameField.Restricted__c = true;
        crmChildNameField.Visible__c = true;
        crmChildNameField.Active__c = true;
        newFields.add(crmChildNameField);
        CRM_Deals_Table__c crmCategoryFieldForContact = crmCategoryField.clone();
        crmCategoryFieldForContact.List_View_Id__c = dealWithContacts.Id;
        newFields.add(crmCategoryFieldForContact);
        CRM_Deals_Table__c crmDealNameFieldForContact = crmDealNameField.clone();
        crmDealNameFieldForContact.List_View_Id__c = dealWithContacts.Id;
        newFields.add(crmDealNameFieldForContact);
        CRM_Deals_Table__c crmChildNameFieldForContact = crmChildNameField.clone();
        crmChildNameFieldForContact.List_View_Id__c = dealWithContacts.Id;
        crmChildNameFieldForContact.Record_Name__c = 'WBSF_Related_Contacts__c.WBSF_Contact__r.Name';
        newFields.add(crmChildNameFieldForContact);
        CRM_Deals_Table__c crmRelationshipField = new CRM_Deals_Table__c();
        crmRelationshipField.List_View_Id__c = dealWithContacts.Id;
        crmRelationshipField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmRelationshipField.Record_Name__c = 'WBSF_Related_Contacts__c.Relationship_Strength__c';
        crmRelationshipField.Width__c = 0;
        crmRelationshipField.Order__c = 0;
        crmRelationshipField.Child__c = true;
        crmRelationshipField.Restricted__c = true;
        crmRelationshipField.Visible__c = false;
        crmRelationshipField.Active__c = true;
        CRM_Deals_Table__c crmFilterPrivateForCompany = new CRM_Deals_Table__c();
        crmFilterPrivateForCompany.List_View_Id__c = dealWithCompanies.Id;
        crmFilterPrivateForCompany.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
        crmFilterPrivateForCompany.Record_Name__c = 'Opportunity.CreatedBy.Name';
        crmFilterPrivateForCompany.Operator__c = 'includes';
        crmFilterPrivateForCompany.Filter_value__c = 'ALL';
        crmFilterPrivateForCompany.Restricted__c = true;
        crmFilterPrivateForCompany.Active__c = true;
        newFields.add(crmFilterPrivateForCompany);
        CRM_Deals_Table__c crmFilterPublicForCompany = new CRM_Deals_Table__c();
        crmFilterPublicForCompany.List_View_Id__c = dealWithCompanies.Id;
        crmFilterPublicForCompany.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
        crmFilterPublicForCompany.Record_Name__c = 'Opportunity.CreatedDate';
        crmFilterPublicForCompany.Operator__c = 'equals';
        crmFilterPublicForCompany.Filter_value__c = 'LAST 2 WEEKS';
        crmFilterPublicForCompany.Restricted__c = false;
        crmFilterPublicForCompany.Active__c = true;
        newFields.add(crmFilterPublicForCompany);
        CRM_Deals_Table__c crmFilterPrivateForContact = new CRM_Deals_Table__c();
        crmFilterPrivateForContact.List_View_Id__c = dealWithContacts.Id;
        crmFilterPrivateForContact.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
        crmFilterPrivateForContact.Record_Name__c = 'Opportunity.CreatedBy.Name';
        crmFilterPrivateForContact.Operator__c = 'includes';
        crmFilterPrivateForContact.Filter_value__c = 'ALL';
        crmFilterPrivateForContact.Restricted__c = true;
        crmFilterPrivateForContact.Active__c = true;
        newFields.add(crmFilterPrivateForContact);
        CRM_Deals_Table__c crmFilterPublicForContact = new CRM_Deals_Table__c();
        crmFilterPublicForContact.List_View_Id__c = dealWithContacts.Id;
        crmFilterPublicForContact.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
        crmFilterPublicForContact.Record_Name__c = 'Opportunity.CreatedDate';
        crmFilterPublicForContact.Operator__c = 'equals';
        crmFilterPublicForContact.Filter_value__c = 'LAST 2 WEEKS';
        crmFilterPublicForContact.Restricted__c = false;
        crmFilterPublicForContact.Active__c = true;
        newFields.add(crmFilterPublicForContact);
        insert newFields;
        CRM_Deals_Table__c[] defaultViews = new CRM_Deals_Table__c[]{ dealWithCompanies,dealWithContacts };
        return defaultViews;
    }
    
    @AuraEnabled
    public static DealsWrapper.View insertView(String listViewName, String joinRelationship, String category) {
		CRM_Deals_Table__c newView = new CRM_Deals_Table__c();
        newView.Record_Name__c = listViewName;
        newView.Join_Deals_with__c = joinRelationship;
        newView.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_View').getRecordTypeId();
        newView.Active__c = true;
        newView.Restricted__c = false;
        insert newView;
        CRM_Deals_Table__c viewName = [SELECT Name FROM CRM_Deals_Table__c WHERE Id = :newView.Id LIMIT 1];
        List<CRM_Deals_Table__c> newFields = new List<CRM_Deals_Table__c>();
        CRM_Deals_Table__c crmCategoryField = new CRM_Deals_Table__c();
        crmCategoryField.List_View_Id__c = newView.Id;
        crmCategoryField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmCategoryField.Record_Name__c = category;
        crmCategoryField.Width__c = 0;
        crmCategoryField.Order__c = 0;
        crmCategoryField.Child__c = false;
        crmCategoryField.Restricted__c = true;
        crmCategoryField.Visible__c = false;
        crmCategoryField.Active__c = true;
        newFields.add(crmCategoryField);
        CRM_Deals_Table__c crmDealNameField = new CRM_Deals_Table__c();
        crmDealNameField.List_View_Id__c = newView.Id;
        crmDealNameField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmDealNameField.Record_Name__c = 'Opportunity.Name';
        crmDealNameField.Width__c = 0;
        crmDealNameField.Order__c = 1;
        crmDealNameField.Child__c = false;
        crmDealNameField.Restricted__c = true;
        crmDealNameField.Visible__c = true;
        crmDealNameField.Active__c = true;
        newFields.add(crmDealNameField);
        String childName = '';
        if(joinRelationship.equals('Related Companies')) {
            childName = 'WBSF_Related_Company__c.WBSF_Company__r.Name';
            CRM_Deals_Table__c crmFilterPrivateForCompany = new CRM_Deals_Table__c();
            crmFilterPrivateForCompany.List_View_Id__c = newView.Id;
            crmFilterPrivateForCompany.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
            crmFilterPrivateForCompany.Record_Name__c = 'Opportunity.CreatedBy.Name';
            crmFilterPrivateForCompany.Operator__c = 'includes';
            crmFilterPrivateForCompany.Filter_value__c = 'ALL';
            crmFilterPrivateForCompany.Restricted__c = true;
            crmFilterPrivateForCompany.Active__c = true;
            newFields.add(crmFilterPrivateForCompany);
            CRM_Deals_Table__c crmFilterPublicForCompany = new CRM_Deals_Table__c();
            crmFilterPublicForCompany.List_View_Id__c = newView.Id;
            crmFilterPublicForCompany.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
            crmFilterPublicForCompany.Record_Name__c = 'Opportunity.CreatedDate';
            crmFilterPublicForCompany.Operator__c = 'equals';
            crmFilterPublicForCompany.Filter_value__c = 'LAST 2 WEEKS';
            crmFilterPublicForCompany.Restricted__c = false;
            crmFilterPublicForCompany.Active__c = true;
            newFields.add(crmFilterPublicForCompany);
        } else if (joinRelationship.equals('Related Contacts')) {
            childName = 'WBSF_Related_Contacts__c.WBSF_Contact__r.Name';
            CRM_Deals_Table__c crmRelationshipField = new CRM_Deals_Table__c();
            crmRelationshipField.List_View_Id__c = newView.Id;
            crmRelationshipField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
            crmRelationshipField.Record_Name__c = 'WBSF_Related_Contacts__c.Relationship_Strength__c';
            crmRelationshipField.Width__c = 0;
            crmRelationshipField.Order__c = 0;
            crmRelationshipField.Child__c = true;
            crmRelationshipField.Restricted__c = true;
            crmRelationshipField.Visible__c = false;
            crmRelationshipField.Active__c = true;
            newFields.add(crmRelationshipField);
            CRM_Deals_Table__c crmFilterPrivateForContact = new CRM_Deals_Table__c();
            crmFilterPrivateForContact.List_View_Id__c = newView.Id;
            crmFilterPrivateForContact.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
            crmFilterPrivateForContact.Record_Name__c = 'Opportunity.CreatedBy.Name';
            crmFilterPrivateForContact.Operator__c = 'includes';
            crmFilterPrivateForContact.Filter_value__c = 'ALL';
            crmFilterPrivateForContact.Restricted__c = true;
            crmFilterPrivateForContact.Active__c = true;
            newFields.add(crmFilterPrivateForContact);
            CRM_Deals_Table__c crmFilterPublicForContact = new CRM_Deals_Table__c();
            crmFilterPublicForContact.List_View_Id__c = newView.Id;
            crmFilterPublicForContact.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
            crmFilterPublicForContact.Record_Name__c = 'Opportunity.CreatedDate';
            crmFilterPublicForContact.Operator__c = 'equals';
            crmFilterPublicForContact.Filter_value__c = 'LAST 2 WEEKS';
            crmFilterPublicForContact.Restricted__c = false;
            crmFilterPublicForContact.Active__c = true;
            newFields.add(crmFilterPublicForContact);
        }
        CRM_Deals_Table__c crmChildNameField = new CRM_Deals_Table__c();
        crmChildNameField.List_View_Id__c = newView.Id;
        crmChildNameField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmChildNameField.Record_Name__c = childName;
        crmChildNameField.Width__c = 0;
        crmChildNameField.Order__c = 2;
        crmChildNameField.Child__c = true;
        crmChildNameField.Restricted__c = true;
        crmChildNameField.Visible__c = true;
        crmChildNameField.Active__c = true;
        newFields.add(crmChildNameField);
        insert newFields;
        DealsWrapper.View view = new DealsWrapper.View();
        view.isSelected = true;
        view.viewId = newView.Id;
        view.value = viewName.Name;
        view.label = newView.Record_Name__c;
        view.child = newView.Join_Deals_with__c;
        view.isRestricted = newView.Restricted__c;
        return view;
    }
    
    @AuraEnabled
    public static void deleteView(String listViewName) {
        CRM_Deals_Table__c view = [SELECT Id, Name FROM CRM_Deals_Table__c WHERE Name = :listViewName LIMIT 1];
        view.Active__c = false;
        CRM_Deals_Table__c[] fields = [SELECT Id, Name FROM CRM_Deals_Table__c WHERE List_View_Id__c = :view.Id];
        for(CRM_Deals_Table__c field : fields) {
            field.Active__c = false;
        }
        update fields;
        update view;
    }
    
    @AuraEnabled
    public static List<DealsWrapper.StudioUser> getStudioUsers() {
        Set<ID> studioRoleIds = new Set<ID>();
        ID managerId = [Select Id, Name FROM UserRole WHERE Name = 'WBSF Studio Manager'].Id;
        studioRoleIds.add(managerId);
        for(UserRole subrole : [Select Id, Name FROM UserRole WHERE ParentRoleId = :managerId]) {
            studioRoleIds.add(subrole.Id);
        }
        List<DealsWrapper.StudioUser> studioUsers = new List<DealsWrapper.StudioUser>();
        for(User user : [SELECT Id,Name,UserRole.Name FROM user WHERE UserRoleId in :studioRoleIds ORDER BY UserRole.Name, Name ASC]) {
            String userNameWithRole = user.Name+' ('+user.UserRole.Name+')';
            DealsWrapper.StudioUser studioUser = new DealsWrapper.StudioUser();
            studioUser.label = userNameWithRole;
            studioUser.role = user.UserRole.Name;
            studioUser.value = Id.valueOf(user.Id);
            studioUsers.add(studioUser);
        }
        return studioUsers;
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
    
    @AuraEnabled
    public static List<String> getPickListValues(String objectApi, String pickListApi, Boolean useRecordType) {
        List<String> pickListValues = new List<String>();
        if(useRecordType) {
            try {
                String endpoint = 'callout:WBSF_Deals_Access/services/data/v41.0/ui-api/object-info/' + objectApi + '/picklist-values/'+DEAL_RECORD_TYPE_ID+'/' + pickListApi;
                HttpRequest request = new HttpRequest();
                // set Authorization
                request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                request.setEndpoint(endpoint);
                request.setMethod('GET');
                Http http = new Http();
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    if(root.containsKey('values')){
                        List<Object> values = (List<Object>) root.get('values');
                        for(Object value : values){
                            Map<String,Object> valueMap = (Map<String,Object>) value;
                            pickListValues.add((String) valueMap.get('label'));
                        }
                    }
                }
            } catch (Exception ex) {
               System.debug(ex);
            }
        } else {
            String[] types = new String[]{objectApi};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
            for(Schema.DescribeSobjectResult res : results) {
                for (Schema.PicklistEntry entry : res.fields.getMap().get(pickListApi).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) pickListValues.add(entry.getValue());
                }
            }
        }
        return pickListValues;
    }
    
    private static List<DealsWrapper.Column> getColumns(String listViewId, List<DealsWrapper.Column> references, List<CRM_Deals_Table__c> columnsForView) {
        Map<String,DealsWrapper.Column> availableFields = new Map<String,DealsWrapper.Column>();
        for(DealsWrapper.Column field : references) {
            availableFields.put(field.apiName,field);
        }
        List<DealsWrapper.Column> columns = new List<DealsWrapper.Column>();
        for(CRM_Deals_Table__c cdtColumn : columnsForView) {
            DealsWrapper.Column column = new DealsWrapper.Column();
            column.isSelected = true;
            column.isRestricted = cdtColumn.Restricted__c;
            column.isSortable = true;
            column.isVisible = cdtColumn.Visible__c;
            column.isChild = cdtColumn.Child__c;
            column.columnId = cdtColumn.Id;
            column.apiName = cdtColumn.Record_Name__c;
            column.width = cdtColumn.Width__c.intValue();
            if(availableFields.containsKey(cdtColumn.Record_Name__c)) {
                column.label = availableFields.get(cdtColumn.Record_Name__c).label;
                column.fieldName = availableFields.get(cdtColumn.Record_Name__c).fieldName;
                column.originalFieldName = availableFields.get(cdtColumn.Record_Name__c).originalFieldName;
                column.objectLabel = availableFields.get(cdtColumn.Record_Name__c).objectLabel;
            	column.fieldType = availableFields.get(cdtColumn.Record_Name__c).fieldType;
                columns.add(column);
            }
        }
        return columns;
    }
    
    private static List<DealsWrapper.Filter> getFilters(String listViewId, List<DealsWrapper.Column> references, List<CRM_Deals_Table__c> filtersForView) {
        Map<String,DealsWrapper.Column> availableFilters = new Map<String,DealsWrapper.Column>();
        for(DealsWrapper.Column field : references) {
            availableFilters.put(field.apiName,field);
        }
        List<DealsWrapper.Filter> filters = new List<DealsWrapper.Filter>();
        for(CRM_Deals_Table__c cdtFilter : filtersForView) {
            DealsWrapper.Filter filter = new DealsWrapper.Filter();
            filter.isActive = true;
            filter.isRestricted = cdtFilter.Restricted__c;
            filter.filterId = cdtFilter.Id;
            filter.apiName = cdtFilter.Record_Name__c;
            filter.operator = cdtFilter.Operator__c;
            filter.value = cdtFilter.Filter_value__c;
            if(availableFilters.containsKey(cdtFilter.Record_Name__c)) {
                filter.label = availableFilters.get(cdtFilter.Record_Name__c).label;
                filter.operatorLabel = filter.operator.toLowerCase()+' '+filter.value.toUpperCase();
                if(filter.apiName.equals('Opportunity.CreatedBy.Name') && !filter.value.equals('ALL')) {
                    String[] values = filter.value.split(';');
                    String valueForLabel = values.size()+' Studio User';
                    if(values.size()>1) valueForLabel += 's';
                    filter.operatorLabel = filter.operator.toLowerCase()+' '+valueForLabel.toUpperCase();
                }
            	filter.fieldType = availableFilters.get(cdtFilter.Record_Name__c).fieldType;
                filters.add(filter);
            }
        }
        return filters;
    }
    
    private static List<sObject> getDataTable(String child, List<DealsWrapper.Column> columns, List<DealsWrapper.Filter> filters) {
        String query = 'SELECT ';
        for(DealsWrapper.Column column : columns) {
            if(!column.isChild) {
                query = query+column.apiName+', ';
            }
        }
        query = query+'( SELECT ';
        for(DealsWrapper.Column column : columns) {
            if(column.isChild) {
                query = query+column.apiName+', ';
            }
        }
        query = query.substring(0,(query.length()-2))+' ';
        if(child.equals('Related Companies')) {
            query = query+' FROM Related_Companies__r ) FROM Opportunity';
        } else if (child.equals('Related Contacts')) {
            query = query+' FROM Related_Contacts__r ) FROM Opportunity';
        }
        query = query + ' WHERE RecordTypeId=\''+DEAL_RECORD_TYPE_ID+'\'';
        for(DealsWrapper.Filter filter : filters) {
            String field = filter.apiName;
            String operation = operatorTranslator(filter.operator);
            String value = filter.value;
            if(!value.equals('ALL')) {
                if(filter.isRestricted) {
                    field = 'Opportunity.CreatedById';
                    operation = ' AND field in (value)';
                    String[] values = value.split(';');
                    value = '';
                    for(Integer i = 0; i<values.size(); i++) {
                        value += '\''+values[i]+'\',';
                    }
                    value = value.substring(0,(value.length()-1));
                } else {
                    if(
                        filter.fieldType == 'id' || 
                        filter.fieldType == 'string' || 
                        filter.fieldType == 'reference' || 
                        filter.fieldType == 'textarea' || 
                        filter.fieldType == 'phone' || 
                        filter.fieldType == 'email'
                    ) {
                        value = value.replaceAll('[^a-zA-Z0-9 ]+','_');
                        if(filter.operator != 'contains' && filter.operator != 'does not contain' && filter.operator != 'starts with') {
                            value = '\''+value+'\'';
                        }
                    }
                    if(filter.fieldType == 'date' || filter.fieldType == 'datetime') {
                        value = dateValueTranslator(value,filter.fieldType);
                    }
                    if(filter.fieldType == 'picklist') {
                        if(filter.operator == 'equals') operation = ' AND field in (value)';
                        if(filter.operator == 'not equal to') operation = ' AND field NOT IN (value)';
                        String[] values = value.split(';');
                        value = '';
                        for(Integer i = 0; i<values.size(); i++) {
                            value += '\''+values[i]+'\',';
                        }
                        value = value.substring(0,(value.length()-1));
                    }
                    if(filter.fieldType == 'multipicklist') {
                        if(filter.operator.equals('includes') || filter.operator.equals('excludes')) {
                            String[] values = value.split(';');
                            value = '';
                            for(Integer i = 0; i<values.size(); i++) {
                                value += '\''+values[i]+'\',';
                            }
                            value = value.substring(0,(value.length()-1));
                        } else {
                            value = '\''+value+'\'';
                        }
                    }
                }
                operation = operation.replace('field', field);
                operation = operation.replace('value', value);
                query += operation;
            }
        }
        query += ' LIMIT 200';
        List<Opportunity> opportunities = new List<Opportunity>();
        try{
            opportunities = Database.query(query);
        }
        catch(Exception e){
            System.debug('Error Executing getDataTable(): ' + e.getMessage());
        }
        system.debug(query);
        return opportunities;
    }
    
    private static String dateValueTranslator(String value, String fieldType) {
        String dateValue = value.replaceAll(' ', '_');
        List<String> relativeFilters = new List<String>();
        relativeFilters.add('YESTERDAY'); relativeFilters.add('TODAY'); relativeFilters.add('TOMORROW');
        relativeFilters.add('LAST_WEEK'); relativeFilters.add('THIS_WEEK'); relativeFilters.add('NEXT_WEEK');
        relativeFilters.add('LAST_MONTH'); relativeFilters.add('THIS_MONTH'); relativeFilters.add('NEXT_MONTH');
        relativeFilters.add('LAST_90_DAYS'); relativeFilters.add('NEXT_90_DAYS'); relativeFilters.add('LAST_QUARTER');
        relativeFilters.add('THIS_QUARTER'); relativeFilters.add('NEXT_QUARTER'); relativeFilters.add('LAST_YEAR');
        relativeFilters.add('THIS_YEAR'); relativeFilters.add('NEXT_YEAR'); relativeFilters.add('LAST_FISCAL_QUARTER');
        relativeFilters.add('THIS_FISCAL_QUARTER'); relativeFilters.add('NEXT_FISCAL_QUARTER'); relativeFilters.add('LAST_FISCAL_YEAR');
        relativeFilters.add('THIS_FISCAL_YEAR'); relativeFilters.add('NEXT_FISCAL_YEAR');
        List<String> relativeFiltersWithN = new List<String>();
        relativeFiltersWithN.add('LAST_N_WEEKS'); relativeFiltersWithN.add('NEXT_N_WEEKS'); relativeFiltersWithN.add('N_WEEKS_AGO');
        relativeFiltersWithN.add('NEXT_N_MONTHS'); relativeFiltersWithN.add('LAST_N_MONTHS'); relativeFiltersWithN.add('N_MONTHS_AGO');
        relativeFiltersWithN.add('N_DAYS_AGO'); relativeFiltersWithN.add('LAST_N_QUARTERS'); relativeFiltersWithN.add('NEXT_N_QUARTERS');
        relativeFiltersWithN.add('N_QUARTERS_AGO'); relativeFiltersWithN.add('N_YEARS_AGO'); relativeFiltersWithN.add('LAST_N_YEARS');
        relativeFiltersWithN.add('NEXT_N_YEARS'); relativeFiltersWithN.add('LAST_N_FISCAL_QUARTERS'); relativeFiltersWithN.add('NEXT_N_FISCAL_QUARTERS');
        relativeFiltersWithN.add('N_FISCAL_QUARTERS_AGO'); relativeFiltersWithN.add('LAST_N_FISCAL_YEARS');
        relativeFiltersWithN.add('NEXT_N_FISCAL_YEARS'); relativeFiltersWithN.add('N_FISCAL_YEARS_AGO');
        if(!relativeFilters.contains(dateValue)) {
            dateValue = dateValue.replaceAll('[0-9]','N');
            if(relativeFiltersWithN.contains(dateValue)) {
                String comparator = dateValue;
                Integer position = 0;
                String[] comparatorArray = comparator.split('_');
                for(Integer i=0; i<comparatorArray.size(); i++) {
                    if(comparatorArray[i].equals('N')) position = i;
                }
                dateValue = value.replaceAll(' ', '_');
                datevalue = comparator+':'+dateValue.split('_')[position];
            } else {
                dateValue = value;
                Date dateInput = Date.parse(dateValue);
                if(fieldType.equals('date')) dateValue = DateTime.newInstance(dateInput.year(), dateInput.month(), dateInput.day()).format('yyyy-MM-dd');
                if(fieldType.equals('datetime')) dateValue = DateTime.newInstance(dateInput.year(), dateInput.month(), dateInput.day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
        }
        return dateValue;
    }
    
    private static String operatorTranslator(String operator) {
        String soqlOperator = '';
        switch on operator {
            when 'equals' { soqlOperator = ' AND field = value'; }
            when 'less than' { soqlOperator = ' AND field < value'; }
            when 'greater than' { soqlOperator = ' AND field > value'; }
            when 'less or equal' { soqlOperator = ' AND field <= value'; }
            when 'greater or equal' { soqlOperator = ' AND field >= value'; }
            when 'not equal to' { soqlOperator = ' AND field != value'; }
            when 'contains' { soqlOperator = ' AND field LIKE \'%value%\''; }
            when 'does not contain' { soqlOperator = ' AND NOT field LIKE \'%value%\''; }
            when 'starts with' { soqlOperator = ' AND field LIKE \'value%\''; }
            when 'includes' { soqlOperator = ' AND field INCLUDES (value)'; }
            when 'excludes' { soqlOperator = ' AND field EXCLUDES (value)'; }
        }
        return soqlOperator;
    }
    
    @AuraEnabled
    public static DealsWrapper.Table getView(String listViewId, String child) {
        DealsWrapper.Table table = new DealsWrapper.Table();
        List<CRM_Deals_Table__c> columnsForView = [SELECT
                                                   	Id,
                                                   	Name,
                                                   	Record_Name__c,
                                                   	Restricted__c,
                                                   	Visible__c,
                                                   	Child__c,
                                                   	Width__c
                                                   FROM
                                                   	CRM_Deals_Table__c
                                                   WHERE
                                                   	List_View_Id__c = :listViewId AND
                                                   	Active__c = true AND
                                                   	RecordTypeId = :Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId()
                                                   ORDER BY
                                                   	Order__c ASC
                                                  ];
        List<CRM_Deals_Table__c> filtersForView = [SELECT
                                                   	Id,
                                                   	Name,
                                                   	Record_Name__c,
                                                   	Restricted__c,
                                                   	Operator__c,
                                                   	Filter_value__c
                                                   FROM
                                                   	CRM_Deals_Table__c
                                                   WHERE
                                                   	List_View_Id__c = :listViewId AND
                                                   	Active__c = true AND
                                                   	RecordTypeId = :Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId()
                                                   ORDER BY
                                                   	Name ASC
                                                  ];
        List<DealsWrapper.Column> references = getAvailableFields();
        List<DealsWrapper.StudioUser> studioUsers = getStudioUsers();
        system.debug('columns for View: '+columnsForView.size());
        for(CRM_Deals_Table__c testColumn : columnsForView) system.debug('column: '+testColumn.Record_Name__c);
        system.debug('filters for View: '+filtersForView.size());
        for(CRM_Deals_Table__c testFilter : filtersForView) system.debug('filter: '+testFilter.Record_Name__c);
        List<DealsWrapper.Column> columns = getColumns(listViewId, references, columnsForView);
        List<DealsWrapper.Filter> filters = getFilters(listViewId, references, filtersForView);
        system.debug('columns obtained: '+columns.size());
        for(DealsWrapper.Column testTableColumn : columns) system.debug('tableColumn: '+testTableColumn.apiName);
        system.debug('filters obtained: '+filters.size());
        for(DealsWrapper.Filter testTableFilter : filters) system.debug('tableFilter: '+testTableFilter.apiName);
        table.references = references;
        table.studioUsers = studioUsers;
        table.columns = columns;
        table.filters = filters;
        table.data = getDataTable(child, columns, filters);
        return table;
    }
    
    @AuraEnabled
    public static Integer followContacts(String followRecordIds) {
        Integer followingCount = 0;
        Set<ID> subscribeIds = new Set<ID>();
        String[] followIds = followRecordIds.split(';');
        for(String followId : followIds) {
            subscribeIds.add(followId);
        }
        Set<ID> subscriptions = new Set<ID>();
        for(EntitySubscription follow : [SELECT ParentId FROM EntitySubscription WHERE SubscriberId = :UserInfo.getUserId() AND ParentId IN (SELECT Id FROM Contact) LIMIT 1000]) {
            subscriptions.add(follow.parentId);
        }
        List<EntitySubscription> subscribeList = new List<EntitySubscription>();
        for(ID subscribeId : subscribeIds) {
            if(!subscriptions.contains(subscribeId)) {
                EntitySubscription newSubscription = new EntitySubscription();
                newSubscription.ParentId = subscribeId;
                newSubscription.SubscriberId = UserInfo.getUserId();
                subscribeList.add(newSubscription);
            }
        }
        if(subscribeList.size()>0) {
            insert subscribeList;
            followingCount = subscribeList.size();
        }
        return followingCount;
    }
    
    @AuraEnabled
    public static Opportunity getDeal(Id dealId) {
        return [SELECT Name FROM Opportunity WHERE Id = :dealId];
    }
    
    @AuraEnabled
    public static String cloneDealFromRecord(String dealIdToClone, String dealName) {
        List<DealsWrapper.Column> fieldReferences = getAvailableFields();
        String query = 'SELECT ';
        Boolean addCompany = true;
        for(DealsWrapper.Column field : fieldReferences) {
            if(field.objectLabel.equals('Deals')) {
                query += field.originalFieldName+', ';
                if(field.originalFieldName.equals('Company__c')) addCompany = false;
            }
        }
        if(addCompany) query += 'Company__c, ';
        query += 'RecordTypeId FROM Opportunity WHERE Id = \''+dealIdToClone+'\' LIMIT 1';
        system.debug(query);
        List<sObject> record = Database.query(query);
        Opportunity newDeal = (Opportunity) record.get(0);
        newDeal.Id = null;
        newDeal.Name = dealName;
        newDeal.OwnerId = UserInfo.getUserId();
        newDeal.CreatedById = UserInfo.getUserId();
        newDeal.CreatedDate = null;
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
    public static String cloneDeal(String dealIdToClone, String dealName) {
        List<DealsWrapper.Column> fieldReferences = getAvailableFields();
        String query = 'SELECT ';
        for(DealsWrapper.Column field : fieldReferences) {
            if(field.objectLabel.equals('Deals')) query += field.originalFieldName+', ';
        }
        query += 'RecordTypeId FROM Opportunity WHERE Id = \''+dealIdToClone+'\' LIMIT 1';
        List<sObject> record = Database.query(query);
        Opportunity newDeal = (Opportunity) record.get(0);
        newDeal.Id = null;
        newDeal.Name = dealName;
        newDeal.OwnerId = UserInfo.getUserId();
        newDeal.CreatedById = UserInfo.getUserId();
        newDeal.CreatedDate = null;
        insert newDeal;
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
            newCompanies.add(relatedCompany);
        }
        insert newCompanies;
        return dealName;
    }
    
    @AuraEnabled
    public static String hideDeal(String dealIdToHide, String dealName, String listViewId) {
        CRM_Deals_Table__c filter = new CRM_Deals_Table__c();
        filter.List_View_Id__c = listViewId;
        filter.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
        filter.Record_Name__c = 'Opportunity.Id';
        filter.Restricted__c = false;
        filter.Operator__c = 'not equal to';
        filter.Filter_value__c = dealIdToHide;
        filter.Active__c = true;
        insert filter;
        return dealName;
    }
    
    @AuraEnabled
    public static List<sObject> updateData(String child, String columnsList, String filtersList) {
        String query = 'SELECT ';
        List<DealsWrapper.Column> columns = new List<DealsWrapper.Column>();
        columns = (List<DealsWrapper.Column>) System.JSON.deserialize(columnsList, List<DealsWrapper.Column>.class);
        List<DealsWrapper.Filter> filters = new List<DealsWrapper.Filter>();
        filters = (List<DealsWrapper.Filter>) System.JSON.deserialize(filtersList, List<DealsWrapper.Filter>.class);
        for(DealsWrapper.Column column : columns) {
            if(!column.isChild) {
                query = query+column.apiName+', ';
            }
        }
        query = query+'( SELECT ';
        for(DealsWrapper.Column column : columns) {
            if(column.isChild) {
                query = query+column.apiName+', ';
            }
        }
        query = query.substring(0,(query.length()-2))+' ';
        if(child.equals('Related Companies')) {
            query = query+' FROM Related_Companies__r ) FROM Opportunity';
        } else if (child.equals('Related Contacts')) {
            query = query+' FROM Related_Contacts__r ) FROM Opportunity';
        }
        query = query + ' WHERE RecordTypeId=\''+DEAL_RECORD_TYPE_ID+'\'';
        List<Opportunity> opportunities = new List<Opportunity>();
        try{
            opportunities = Database.query(query);
        }
        catch(Exception e){
            System.debug('Error Executing updateData(): ' + e.getMessage());
        }
        system.debug(query);
        return opportunities;
    }
    
    @AuraEnabled
    public static DealsWrapper.Table updateColumns(String listViewId, String child, String category, String updateColumnsList, String filtersList) {
        List<DealsWrapper.Column> columns = new List<DealsWrapper.Column>();
        List<DealsWrapper.Filter> filters = new List<DealsWrapper.Filter>();
        columns = (List<DealsWrapper.Column>) System.JSON.deserialize(updateColumnsList, List<DealsWrapper.Column>.class);
        filters = (List<DealsWrapper.Filter>) System.JSON.deserialize(filtersList, List<DealsWrapper.Filter>.class);
        CRM_Deals_Table__c[] oldFields = [SELECT 
                                          	Id, 
                                          	Active__c 
                                          FROM 
                                          	CRM_Deals_Table__c 
                                          WHERE 
                                          	List_View_Id__c = :listViewId AND
                                          	Active__c = true AND
                                          	RecordTypeId = :Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId()];
        for(CRM_Deals_Table__c column : oldFields) {
            column.Active__c = false;
        }
        update oldFields;
        List<CRM_Deals_Table__c> newFields = new List<CRM_Deals_Table__c>();
        CRM_Deals_Table__c crmCategoryField = new CRM_Deals_Table__c();
        crmCategoryField.List_View_Id__c = listViewId;
        crmCategoryField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
        crmCategoryField.Record_Name__c = category;
        crmCategoryField.Width__c = 0;
        crmCategoryField.Order__c = 0;
        crmCategoryField.Restricted__c = true;
        crmCategoryField.Active__c = true;
        newFields.add(crmCategoryField);
        if (child.equals('Related Contacts')) {
            CRM_Deals_Table__c crmRelationshipField = new CRM_Deals_Table__c();
            crmRelationshipField.List_View_Id__c = listViewId;
            crmRelationshipField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
            crmRelationshipField.Record_Name__c = 'WBSF_Related_Contacts__c.Relationship_Strength__c';
            crmRelationshipField.Width__c = 0;
            crmRelationshipField.Order__c = 0;
            crmRelationshipField.Child__c = true;
            crmRelationshipField.Restricted__c = true;
            crmRelationshipField.Visible__c = false;
            crmRelationshipField.Active__c = true;
            newFields.add(crmRelationshipField);
        }
        for(Integer i=0; i<columns.size(); i++) {
            CRM_Deals_Table__c crmField = new CRM_Deals_Table__c();
            crmField.List_View_Id__c = listViewId;
            crmField.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Field').getRecordTypeId();
            crmField.Record_Name__c = columns.get(i).apiName;
            crmField.Width__c = 0;
            crmField.Order__c = i+1;
            crmField.Child__c = columns.get(i).isChild;
            crmField.Restricted__c = columns.get(i).isRestricted;
            crmField.Visible__c = true;
            crmField.Active__c = true;
            newFields.add(crmField);
        }
        insert newFields;
        List<DealsWrapper.Column> references = getAvailableFields();
        List<DealsWrapper.Column> newColumns = getColumns(listViewId,references,newFields);
        DealsWrapper.Table table = new DealsWrapper.Table();
        table.columns = newColumns;
        table.filters = filters;
        table.data = getDataTable(child, newColumns, filters);
        return table;
    }
    
    @AuraEnabled
    public static DealsWrapper.Table updateFilters(String listViewId, String child, String columnsList, String updateFiltersList) {
        List<DealsWrapper.Column> columns = new List<DealsWrapper.Column>();
        List<DealsWrapper.Filter> filters = new List<DealsWrapper.Filter>();
        columns = (List<DealsWrapper.Column>) System.JSON.deserialize(columnsList, List<DealsWrapper.Column>.class);
        filters = (List<DealsWrapper.Filter>) System.JSON.deserialize(updateFiltersList, List<DealsWrapper.Filter>.class);
        CRM_Deals_Table__c[] oldFilters = [SELECT 
                                          	Id, 
                                          	Active__c 
                                          FROM 
                                          	CRM_Deals_Table__c 
                                          WHERE 
                                          	List_View_Id__c = :listViewId AND
                                          	Active__c = true AND
                                          	RecordTypeId = :Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId()];
        for(CRM_Deals_Table__c oldfilter : oldFilters) {
            oldfilter.Active__c = false;
        }
        update oldFilters;
        List<CRM_Deals_Table__c> newFiltersList = new List<CRM_Deals_Table__c>();
        for(DealsWrapper.Filter filter : filters) {
            CRM_Deals_Table__c newfilter = new CRM_Deals_Table__c();
            newfilter.List_View_Id__c = listViewId;
            newfilter.RecordTypeId = Schema.SObjectType.CRM_Deals_Table__c.getRecordTypeInfosByDeveloperName().get('CRM_Deals_Table_Filter').getRecordTypeId();
            newfilter.Record_Name__c = filter.apiName;
            newfilter.Operator__c = filter.operator;
            newfilter.Filter_value__c = filter.value;
            newfilter.Restricted__c = filter.isRestricted;
            newfilter.Active__c = true;
            newFiltersList.add(newfilter);
        }
        insert newFiltersList;
        List<DealsWrapper.Column> references = getAvailableFields();
        List<DealsWrapper.Filter> newFilters = getFilters(listViewId,references,newFiltersList);
        DealsWrapper.Table table = new DealsWrapper.Table();
        table.columns = columns;
        table.filters = newFilters;
        table.data = getDataTable(child, columns, newFilters);
        return table;
    }
}