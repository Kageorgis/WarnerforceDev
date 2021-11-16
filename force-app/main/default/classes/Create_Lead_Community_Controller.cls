public without sharing class Create_Lead_Community_Controller {
    @AuraEnabled
    public static List<Map<String, String>> getOptions(){
        List<Map<String, String>> items = new List<Map<String, String>>();

        Schema.DescribeFieldResult fieldResult = Lead.Brand_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            items.add(new Map<String, String>{'value' => pickListVal.getValue(), 'label' => pickListVal.getLabel()});
        }
        return items;
    }

    @AuraEnabled
    public static String create(String params){
        system.debug(params);

        try{
            Id RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Ellen Community').getRecordTypeId();
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(params);
            String Company = String.valueof(data.get('Company'));
            String LastName = String.valueof(data.get('LastName'));
            String BrandName = String.valueof(data.get('BrandName'));
            String Salutation = String.valueof(data.get('Salutation'));
            String FirstName = String.valueof(data.get('FirstName'));
            String phone = String.valueof(data.get('phone'));
            String BrandCategory = String.valueof(data.get('BrandCategory'));
            String Email = String.valueof(data.get('Email'));
            String Title = String.valueof(data.get('Title'));
            String TimingofIntegration = String.valueof(data.get('TimingofIntegration'));
            String Budget = String.valueof(data.get('Budget'));
            String KeyMessages = String.valueof(data.get('KeyMessages'));

            String importantthings = String.valueOf(data.get('importantthings'));
            String DetailsofMarketing = String.valueOf(data.get('DetailsofMarketing'));
            String MainKPIs = String.valueOf(data.get('MainKPIs'));
            String PriorityElements = String.valueOf(data.get('PriorityElements'));

            AssignmentRule AR = [select id,name from AssignmentRule where SobjectType = 'Lead' and Active = true and name='Ellen Lead Assignment' limit 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            if(!Test.isRunningTest()){dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;}else{dmlOpts.assignmentRuleHeader.useDefaultRule= true;}

            Lead l = new Lead();
            l.Company = Company;
            l.LastName = LastName;
            l.Brand_Name__c = BrandName;
            l.Salutation = Salutation;
            l.FirstName = FirstName;
            l.Phone = phone;
            l.Brand_Category__c = BrandCategory;
            l.Email = Email;
            l.Title = Title;
            l.Timing_of_Integration__c = TimingofIntegration;
            l.Budget__c = Budget;
            l.X2_3_Key_Messages__c = KeyMessages;
            l.Important_things_about_Brand__c = importantthings;
            l.Details_of_Marketing_Campaign__c = DetailsofMarketing;
            l.Main_KPIs__c = MainKPIs;
            l.Priority_elements__c = PriorityElements;
            l.RecordTypeId = RecordTypeId;
            insert l;

            l.setOptions(dmlOpts);
            update l;

            

            return 'Registered successfully';
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.debug(e.getLineNumber());
            return e.getMessage();//'Failed to register, try in a few moments'; //e.getMessage();
        }

        
    }
}