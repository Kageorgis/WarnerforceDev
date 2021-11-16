/**
 * Created by XMMORENO on 3/3/2020.
 */

public with sharing class cp_accountRecordDetailController {

    @AuraEnabled
    public static Id getRecordTypeId(Id accId){
        Account accRec = [SELECT Id,RecordTypeId FROM Account WHERE Id =:accId];
        System.debug('The Id '+accRec.RecordTypeId);
        return accRec.RecordTypeId;


    }
    @AuraEnabled
    public static Id createProperties(Account acc, List<SObject> propIds, List<SObject> retIds, String recTypeId){
        acc.RecordTypeId = recTypeId;
        System.debug(acc.Id);
        if(acc.Id !=null){
            update acc;
        }
        else{
            insert(acc);
        }

        List<SObject> props = new List<SObject>();
        for(Integer i = 0; i < propIds.size();i++){
            System.debug('The Props -->'+propIds[i]);
        }
        for(SObject prop : propIds) {

            Licensee_Property__c newProp = new Licensee_Property__c();
            newProp.Account__c = acc.Id;
            newProp.Property__c = prop.Id;

            props.add(newProp);
        }
        insert props;

        List<SObject> retails = new List<SObject>();
        for(Integer i = 0; i < retIds.size();i++){
            System.debug('The Props -->'+retIds[i]);
        }
        for(SObject retl : retIds) {

            Licensee_Related_Retailer__c newRetl = new Licensee_Related_Retailer__c();
            newRetl.Related_Licensee__c = acc.Id;
            newRetl.Retailer_Description__c = retl.Id;

            retails.add(newRetl);
        }
        insert retails;
        return acc.Id;
    }

        @AuraEnabled

    public static catSubCatWrapper getCategories(String accountId){
        catSubCatWrapper catWrapper = new catSubCatWrapper();
        List<String> catValuesList = new List<String>();
        List<String> subcatValuesList = new List<String>();
        Schema.DescribeFieldResult catValue = Account.cp_Category_Licensee__c.getDescribe();
        Schema.DescribeFieldResult subCatValue = Account.cp_Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> subcat = subCatValue.getPicklistValues();
        List<Schema.PicklistEntry> cat = catValue.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : subcat) {
            subcatValuesList.add(pickListVal.getLabel());
        //    System.debug('Values in Rating are: ' + subcatValuesList);
        }
        for (Schema.PicklistEntry pickListVal : cat) {
            catValuesList.add(pickListVal.getLabel());
         //   System.debug('Values in Rating are: ' + catValuesList);
        }
        if(!catValuesList.isEmpty()){
            catWrapper.catValuesList = catValuesList;
            catWrapper.subcatValuesList = subcatValuesList;

        }
            List<Licensee_Property__c> existProperties = [SELECT Id,Name,Property__r.Name,Account__r.Name, Property__c FROM Licensee_Property__c WHERE Account__c = :accountId];
            System.debug('Existing Props --> '+existProperties+'AccountId --->'+accountId);
        if(!existProperties.isEmpty()){
            catWrapper.propertiesList = existProperties;
        }
            List<Licensee_Related_Retailer__c> existRetailers = [SELECT Id,Name,Related_Licensee__c,Retailer_Description__c, Retailer_Description__r.Name FROM Licensee_Related_Retailer__c WHERE Related_Licensee__c = :accountId];
            System.debug('Existing Rets --> '+existRetailers+'AccountId --->'+accountId);
            if(!existRetailers.isEmpty()){
                catWrapper.retailersList = existRetailers;
            }
        return catWrapper;
    }
    public class catSubCatWrapper{
        @AuraEnabled
        public List<String> catValuesList{get;set;}
        @AuraEnabled
        public List<String> subcatValuesList{get;set;}
        @AuraEnabled
        public List<Licensee_Property__c> propertiesList{get;set;}
        @AuraEnabled
        public List<Licensee_Related_Retailer__c> retailersList{get;set;}

    }
    @AuraEnabled
    public static  Map<String,List<String>> populateCategories(List<String> selectedSubCats){

        Map<String, List<String>> depMap = new Map<String, List<String>>();

        for(Category_Dependecy__mdt value : [select Category__c, Sub_Category__c, LOB__c, LOB_Type_c__c, NAM_Category__c, NAM_LOB__c, NAM_LOB_Type__c, NAM_Sub_Category__c, MasterLabel FROM Category_Dependecy__mdt WHERE Sub_Category__c LIKE :selectedSubCats]) {
            if(depMap.containsKey(value.Category__c)) {
                List<String> category = depMap.get(value.Category__c);
                category.add(value.Sub_Category__c);
                depMap.put(value.Category__c,category );
            } else {
                depMap.put(value.Category__c, new List<String> { value.Sub_Category__c });
            }
        }
    //    System.debug(depMap);


        return depMap;
    }

    @AuraEnabled
    public static List<LayoutSection> getPageLayoutFields(String recTypeId) {

        List<LayoutSection> lstSections = new List<LayoutSection>();

        try {
            // Provide the page layout name here
            // You can give multiple page layout names here as well

            String licenseeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
            String reatailerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
            System.debug('The Licensee Id---> '+licenseeId);

            System.debug('The Retailer Id---> '+reatailerId);
            List<String> componentNameList = new List<String>();
            if(recTypeId == licenseeId) {
                componentNameList.add('Account-WBCP Licensee');
            }
            else{
                componentNameList.add('Account-WBCP Retailer');
            }
            // Retrieve page layout details
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout contLayout = (Metadata.Layout) components.get(0);

            // We are going to find the fields names and will keep them according to columns so
            // we can show them as per page layout
            for( Metadata.LayoutSection ls : contLayout.layoutSections ) {

                LayoutSection section = new LayoutSection( ls.label, ls.layoutColumns.size() );

                List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                Integer maxFieldsInColumn = 0;
                for( Metadata.LayoutColumn lc : ls.layoutColumns ) {

                    LayoutColumn column = new LayoutColumn();
                    // check if there are fields available in that column
                    if( lc.layoutItems != null ) {
                        // Get the max number of fields in a column to preserve the alignment
                        if( maxFieldsInColumn < lc.layoutItems.size() ) {
                            maxFieldsInColumn = lc.layoutItems.size();
                        }
                        for( Metadata.LayoutItem li : lc.layoutItems ) {

                            // Pass the LayoutItem object in the LayoutField consturctor
                            column.lstFields.add( new LayoutField( li ) );
                        }
                    }
                    // No need to add a column in the section if there is no field available
                    if( column.lstFields.size() > 0 ) {
                        lstColumns.add( column );
                    }
                }

                // Now, we need to arrange the fields in section so we can use them in the iteration
                // on the component so we will have to arrange them in the order
                if( maxFieldsInColumn > 0 ) {
                    for( Integer i = 0; i < maxFieldsInColumn; i++ ) {
                        for( Integer j = 0; j < lstColumns.size(); j++ ){
                            if( lstColumns[j].lstFields.size() > i ) {
                                section.lstFields.add( lstColumns[j].lstFields[i] );
                            }
                            else {
                                section.lstFields.add( new LayoutField() );
                            }
                        }
                    }
                }

                lstSections.add( section );
            }
        }
        catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return lstSections;
    }
    public class LayoutSection {
        @AuraEnabled public String label;
        @AuraEnabled public List<LayoutField> lstFields;
        @AuraEnabled public Integer totalColumns;
        public LayoutSection( String label, Integer totalColumns ) {
            this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }

    private class LayoutColumn {
        private List<LayoutField> lstFields;
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }

    public class LayoutField {
        @AuraEnabled public String fieldName;
        @AuraEnabled public Boolean isRequired;
        @AuraEnabled public Boolean isReadOnly;

        public LayoutField() {}

        public LayoutField( Metadata.LayoutItem li ) {

            this.fieldName = li.field;
            if( li.behavior == Metadata.UiBehavior.Required ) {
                this.isRequired = true;
            }
            else if( li.behavior == Metadata.UiBehavior.ReadOnly ) {
                this.isReadOnly = true;
            }
        }
    }


}