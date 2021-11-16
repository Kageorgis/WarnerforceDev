global class GWSController {
    
    public static Boolean insertTrriggerFlag = true;
    
    public static void checkForContact(List<WB_Project__c > lstWBProject)
    {
        Map<String,Id> mapEmailContId = new Map<String,Id>();
        for(WB_Project__c wbProjObj : lstWBProject)
        {
            Id contactId = fetchContactId(wbProjObj.Submitter_Email_Id__c);
            if(contactId != null)
            {
            	mapEmailContId.put(wbProjObj.Submitter_Email_Id__c,contactId);
            }
        }
        Account accRec = [SELECT Id FROM Account WHERE Name = :Label.WB_Intake_Account_Name];
        for(WB_Project__c wbProjObj : lstWBProject)
        {
            if(mapEmailContId.containsKey(wbProjObj.Submitter_Email_Id__c))
            {
                wbProjObj.Submitter_LookUp__c = mapEmailContId.get(wbProjObj.Submitter_Email_Id__c);
            }
            else
            {
                Contact cont = new Contact();
                cont.FirstName = wbProjObj.Submitter_First_Name__c;
                cont.LastName = wbProjObj.Submitter_Last_Name__c;
                cont.Email = wbProjObj.Submitter_Email_Id__c;
                cont.Phone = wbProjObj.Submitter_Phone_Number__c;
                cont.AccountId = accRec.Id;
                insert cont;
                wbProjObj.Submitter_LookUp__c = cont.Id;
            }
        }
    }
    
    public static Id fetchContactId(String email)
    {
        List<List<SObject>> contactRecs =[FIND :email IN EMAIL FIELDS Returning Contact(Name,FirstName,LastName,Id,Email,Phone)];
        System.debug('contactRecs==='+contactRecs);
        for(List<SObject> sObj : contactRecs)
        {
            for(SObject contObj : sObj)
            {
                return contObj.Id;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static Boolean checkUserProfile(String recordId)
    {
        Id profileId = UserInfo.getProfileId();
		Profile profileRec = [SELECT Name FROM Profile WHERE id = :profileId];
        if(profileRec.Name.equals('WBT Accessor'))
        {
            return false;
        }
        return true;
    }
    
    @AuraEnabled
    public static WB_Project__c getValues(String recordId)
    {
        WB_Project__c wbObj= [SELECT Id,Submitter_First_Name__c,Submitter_Last_Name__c,Submitter_Email_Id__c,
                              Submitter_Phone_Number__c,Project_Name__c,Project_Requester__c,Project_Owner__c,
                              Requesting_DivisionDepartment__c,Executive_Sponsor__c,Technology_Sponsor__c,Project_Type__c,
                              Request_Type__c,If_other_please_describe__c,Business_or_Technology_Problems__c,
                              Required_Services__c,Users_Level__c,Project_Approved__c,If_no_expected_approval_date__c,
                              Project_Funded__c,If_no_expected_funding_date__c,Number_of_impacted_user__c,
                              Impacted_user_groups__c,Locations_of_impacted_users__c,Users_are_in_each_location__c,
                              Project_align_to_specific_business__c,GSW_Review_Date__c,Reviewed_By__c,
                              Application_Other_Team_Checked__c,If_other_please_explain__c,Describe_any_Risks__c,
                              Estimated_1X_Cost__c,Estimated_Ongoing_OPEX_Costs__c,Funding_Source__c,Estimated_Start_Date__c,
                              Estimated_Delivery_Date__c,If_you_selected_other_please_explain__c,GWS_Director_Approval__c,
                              Date_of_GWS_Director_Approval__c,GWS_VP_Approval__c,Date_of_GWS_VP_Approval__c,
                              Any_other_Considerations__c,GWS_Project_Type__c,High_Level_Project_Activities__c,Impacted_Teams__c,
                              Other_Potential_Impacts__c,Cost_Delivery_Estimate__c,Complexity__c,Next_Steps__c,Path_Picklist__c,
                              Name,Service_Type__c,OwnerId,Submitter_LookUp__r.Id,Submitter_LookUp__r.Name,Submitter_LookUp__r.Email,
                              Submitter_LookUp__r.Phone,Submitter_LookUp__r.FirstNameLocal,Submitter_LookUp__r.LastNameLocal,
                              Approval_Stage__c, Reason__c
                              FROM WB_Project__c WHERE Id = :recordId];
        system.debug(wbObj.Approval_Stage__c);
        return wbObj;
    }
    
    @AuraEnabled
    public static void updateRec(WB_Project__c recObj)
    {
        update recObj;
        
        //return wbObj;
    }
    
    @AuraEnabled
    public static List<String> getCountries()
    {
        List<String> lstCount= new List<String>();
        List<Country__c> lstRec = [SELECT ID,Name FROM Country__c WHERE Status__c = 'Active' ORDER BY Name];
        if( !lstRec.isEmpty())
        for(Country__c c : lstRec)
            lstCount.add(c.Name);
        return lstCount;
    }
    
    @AuraEnabled
        public static String insertRec(WB_Project__c recObj)
    {
        insertTrriggerFlag = false;
        insert recObj;
        insertTrriggerFlag = true;
        
        return recObj.Id;
    }
    
    @AuraEnabled
    public static void updatePathPicklist(String recordId)
    {
        WB_Project__c wbObj= [SELECT Id,Path_Picklist__c FROM WB_Project__c WHERE Id = :recordId];
        wbObj.Path_Picklist__c='Assessment';
        update wbObj;
    }
    
    @AuraEnabled
    public static List<Contact> fetchContacts(String searchKeyWord)
    {
        //String searchKey = '%' + searchKeyWord + '%';
        String searchKey = searchKeyWord;
        if(searchKey.length() < 2)
        {
            for(Integer i = searchKey.length() ; i < 2 ; i++)
            {
                searchKey += 'a';
            }
        }
        System.debug('searchKey==='+searchKey);
        //List<Contact> lstContact = [SELECT Id, Name, Email, Phone FROM Contact WHERE Name LIKE :searchKey ];
        List<Contact> lstContact = new List<Contact>();
        List<List<SObject>> contactRecs =[FIND :searchKey IN Name FIELDS Returning Contact(Name,FirstName,LastName,Id,Email,Phone)];
        System.debug('contactRecs==='+contactRecs);
        for(List<SObject> sObj : contactRecs)
        {
            for(SObject contObj : sObj)
            {
                lstContact.add((Contact)contObj);
            }
        }
		System.debug('lstContact==='+lstContact);
        
        return lstContact;
    }
    
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        //System.debug('Value==='+fieldMap.get(fld).getDescribe().getPickListValues());
        // Get the list of picklist values for this field. 
        
        list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        return allOpts;
    }    
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*@AuraEnabled
public static Boolean isUserWorthy(String recordId)
{
Boolean worthy=false;

WB_Project__c wbpro = [SELECT OwnerId,Path_Picklist__c FROM WB_Project__c WHERE Id = :recordId];

GroupMember gm = [SELECT GroupId, UserOrGroupId, Id FROM GroupMember WHERE GroupId = :wbpro.OwnerId AND UserOrGroupId = :UserInfo.getUserId()];
System.debug('gm==='+gm);
if(gm != null && wbpro.Path_Picklist__c == 'Assessment' )
worthy=true;

return worthy;
}*/
}