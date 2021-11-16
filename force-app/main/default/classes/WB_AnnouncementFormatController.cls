public with sharing class WB_AnnouncementFormatController {
    public string selectedEmailTemplate{get;set;}
    public string selectedRepTemplate{get;set;}    
    public boolean saveMessageFlag{get;set;} 
    public boolean saveFailedMsgFlag {get;set;}
    public String annTypeIds{get;set;}
    Announcement_Rule__c annTypeList = new Announcement_Rule__c();
    Set<String> mismatchValSet;
    Boolean isError;
    public String optionalTriggerFinalVal;
    
    public WB_AnnouncementFormatController(ApexPages.StandardController controller) {
                 annTypeIds = ApexPages.currentPage().getParameters().get('ID');
                 //defaultTemp();
                 saveMessageFlag=false;
                 saveFailedMsgFlag=false;
                 annTypeList = [select id,Email_Template__c,Email_Template_Id__c,Report_ID__c,Report_Template__c,Optional_Triggers__c,Report_Template_fields__c from Announcement_Rule__c where Id =: annTypeIds];
        }

    public List<EmailTemplate> EmailTemp = new List<EmailTemplate>();
    public List<Report> ReportTemp = new List<Report>();
    public WB_AnnouncementFormatController()
    {
   
    }
    
    public List<SelectOption> eTemplateList
    {
        get {   
            EmailTemp = [Select Id, Name From EmailTemplate where folder.name =:System.Label.Email_Template_Folder Order by Name ASC];
            
            eTemplateList = new List<SelectOption>(); 
            
            if(annTypeList.Email_Template_Id__c == NULL || annTypeList.Email_Template_Id__c == ''){
                //uncommented by shalini for allowing None Option 
                eTemplateList.add(new SelectOption('None','--None--')); 
                //eTemplateList.add(new SelectOption('None',System.Label.Default_Email_Template));             
            
            }else eTemplateList.add(new SelectOption(annTypeList.Email_Template_Id__c,annTypeList.Email_Template__c));
            
            for(EmailTemplate temp : EmailTemp) {
                integer countEmailTemp = 0;
                for(SelectOption emailTempSelected: eTemplateList){                    
                    if(emailTempSelected.getLabel() == temp.Name){
                        countEmailTemp++;
                    }
                    
                }   
                if(countEmailTemp ==0 ){
                    eTemplateList.add(new SelectOption(temp.Id, temp.Name)); 
                    
                }
                    
               
            }   
            return eTemplateList;
        } set;
    }
    
    public List<SelectOption> rTemplateList
    {
        get
        {
            
            ReportTemp = [SELECT id,Name FROM Report WHERE OwnerId in (
                          SELECT ID FROM Folder WHERE name =:System.Label.Announcement_Report_Folder and Type = 'Report') ORDER BY Name ASC];
            
            rTemplateList = new List<SelectOption>();
            
            if(annTypeList.Report_ID__c == NULL || annTypeList.Report_ID__c == ''){
                //uncommented by shalini for allowing None Option 
                rTemplateList.add(new SelectOption('None','--None--'));
                //rTemplateList.add(new SelectOption('None',System.Label.Default_Report_Template));             
             
            }else rTemplateList.add(new SelectOption(annTypeList.Report_ID__c,annTypeList.Report_Template__c));
                
            
            for(Report temp : ReportTemp) {
                integer countRepTemp = 0;
                for(SelectOption repTempSelected: rTemplateList){
                    
                    if(repTempSelected.getLabel() == temp.Name){
                        countRepTemp++;
                        
                    }
                }
                if(countRepTemp == 0){
                    rTemplateList.add(new SelectOption(temp.Id, temp.Name));                    
                }
                
            }
            return rTemplateList;
        }
        set;
    }
   public String getSelectedEmailTemp()
    {
           
            return selectedEmailTemplate ;
           
    }
    public String getSelectedRepTemp()
    {
           
            return selectedRepTemplate ;
           
    }
        
        public void saveSelection() {           
                saveMessageFlag=false; 
                saveFailedMsgFlag= false;
                string repTempName = '';
                string emailTempName = '';
                for(SelectOption repTempSelected: rTemplateList){
                    if(repTempSelected.getValue() == selectedRepTemplate){
                        repTempName = repTempSelected.getLabel(); 
                    }
                }
                for(SelectOption emailTempSelected: eTemplateList){
                    if(emailTempSelected.getValue() == selectedEmailTemplate){
                        emailTempName = emailTempSelected.getLabel(); 
                    }
                }
                
                String reportTemplateFields = getReportFields(selectedRepTemplate,annTypeList);
                
                system.debug(LoggingLevel.INFO,'After function call optionalTriggerFinalVal:'+optionalTriggerFinalVal);
                
                
                Announcement_Rule__c annTypeUpdated= new Announcement_Rule__c(id = annTypeIds,Email_Template__c = emailTempName,
                                                                                Email_Template_Id__c =selectedEmailTemplate, Report_Template__c = repTempName,
                                                                                Report_ID__c = selectedRepTemplate, Report_Template_fields__c = reportTemplateFields, 
                                                                                Optional_Triggers__c = optionalTriggerFinalVal);
                try{
                       Database.Saveresult updateResult  = Database.update(annTypeUpdated, false); 
                        if(updateResult.isSuccess()){
                            saveMessageFlag=true;
                        }  else{
                            saveMessageFlag=false; 
                            saveFailedMsgFlag= true;
                            for(Database.Error error :updateResult.getErrors()){
                                System.debug('The following error has occurred.');                    
                                System.debug(error.getStatusCode() + ': ' + error.getMessage());
                                System.debug('Fields that affected this error: ' + error.getFields());
                            }
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Rights to update this record.');
                            ApexPages.addMessage(myMsg);
                        }           
                        
                }
            catch(exception e){
                
            }
        }
    public void defaultTemp(){
    //Updating default vaues for format 
    if(annTypeList.Email_Template_Id__c == NULL || annTypeList.Email_Template_Id__c == ''){
        EmailTemplate EmailTemplateRec = [Select Id, Name From EmailTemplate where Name =:System.Label.Default_Email_Template ];
        Report ReportTempRec = [SELECT id,Name FROM Report WHERE OwnerId in (
                          SELECT ID FROM Folder WHERE name =:System.Label.Announcement_Report_Folder and Type = 'Report') and name =:System.Label.Default_Report_Template];
        Announcement_Rule__c annTypeUpdated= new Announcement_Rule__c(id = annTypeIds,Email_Template__c = EmailTemplateRec.name,
                                                                                    Email_Template_Id__c =EmailTemplateRec.Id, Report_Template__c = ReportTempRec.Name,
                                                                                    Report_ID__c = ReportTempRec.Id);
                    try{
                            Database.Saveresult updateResult  = Database.update(annTypeUpdated, false); 
                            if(updateResult.isSuccess()){
                                    saveMessageFlag=true;
                            }  else{
                                    saveMessageFlag=false; 
                                    saveFailedMsgFlag= true;
                            }              
                                                    
                            
                    }
                catch(exception e){
                    
                }            
            }  
    }  
    
    public String getReportFields(String reportTemplateID,Announcement_Rule__c annTypeRec){
        
        Set<String> uniqueColumnval = new Set<String>();
        Set<String> finalFilteredStr = new Set<String>();
        List<Announcement_Trigger_Field__c> optionalTriggerFields = new List<Announcement_Trigger_Field__c>();
        
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportTemplateID);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
    
    //  Reports.ReportResults reportResults = Reports.ReportManager.runReport(reportTemplateID, reportMd,true);
    //  System.debug('ReportResults--->> ' +reportResults);
        
     // Reports.ReportExtendedMetadata rmd =   reportResults.getReportExtendedMetadata();
        System.debug('Detail columns: ' + reportMd.getDetailColumns());
        uniqueColumnval.addAll(reportMd.getDetailColumns());
        System.debug('uniqueColumnval--->> ' +uniqueColumnval);
        
        //Get Report columns API Name values
        for(String val : uniqueColumnval){
            String colApi = '';
            colApi =  val.substringAfter('.');
            finalFilteredStr.add(colApi);
        }
        
        system.debug(LoggingLevel.INFO,'###finalFilteredStr:'+finalFilteredStr);
        
        //Get API Name of all fields from Ann.trigger Obj
        optionalTriggerFields = [SELECT Id,Name,Source_API__c,Destination_API__c,Report_API__c from Announcement_Trigger_Field__c];
        
        Set<String> apiMatchingReportSet = new Set<String>();
        Map<String,String> apiMatchingReportMap = new Map<String,String>();
            
            
        if(finalFilteredStr != null && finalFilteredStr.size()>0){
            //system.debug(LoggingLevel.INFO,'finalFilteredStr:'+finalFilteredStr);
            for(Announcement_Trigger_Field__c optionalFieldVal : optionalTriggerFields){
                    
                if(finalFilteredStr.contains(optionalFieldVal.Source_API__c)){
                    //system.debug(LoggingLevel.INFO,'optionalFieldVal.Source_API__c:'+optionalFieldVal.Source_API__c);
                    if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                        apiMatchingReportMap.put(optionalFieldVal.Name,optionalFieldVal.Source_API__c);
                    }
                    //apiMatchingReportSet.add(optionalFieldVal.Source_API__c);
                }else if(finalFilteredStr.contains(optionalFieldVal.Destination_API__c)){
                    //system.debug(LoggingLevel.INFO,'optionalFieldVal.Destination_API__c:'+optionalFieldVal.Destination_API__c);
                    if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                            apiMatchingReportMap.put(optionalFieldVal.Name,optionalFieldVal.Destination_API__c);
                    }
                       // apiMatchingReportSet.add(optionalFieldVal.Destination_API__c);
                }else if(optionalFieldVal.Report_API__c != null  ){
                    if(optionalFieldVal.Report_API__c.contains(', ')){
                        for(String value : optionalFieldVal.Report_API__c.split(',')){
                            value = value.trim();
                            if(finalFilteredStr.contains(value)){
                                if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                                    apiMatchingReportMap.put(optionalFieldVal.Name,value);
                                }
                            }
                                
                        }    
                    }else if(!optionalFieldVal.Report_API__c.contains(', ')){
                        if(finalFilteredStr.contains(optionalFieldVal.Report_API__c)){
                            if(!apiMatchingReportMap.containsKey(optionalFieldVal.Name)){
                                apiMatchingReportMap.put(optionalFieldVal.Name,optionalFieldVal.Report_API__c);
                            }
                        }
                    }
                        
                        
                }
            }
        }
        
        String reportOptionalMatchedField;
        if(apiMatchingReportMap != null && apiMatchingReportMap.size()>0){
            //system.debug(LoggingLevel.INFO,'###apiMatchingReportMap:'+apiMatchingReportMap);  
            for(String val : apiMatchingReportMap.values()){
                
                 //system.debug(LoggingLevel.INFO,'###val:'+val);
                if(reportOptionalMatchedField == null || reportOptionalMatchedField == ''){
                    reportOptionalMatchedField = val;
                }else{
                    reportOptionalMatchedField = reportOptionalMatchedField +', '+val;
                }
            }
        }
        
        Set<String> OptionalFieldAnn = new Set<String>();
        if(apiMatchingReportMap != null && apiMatchingReportMap.size()>0){
            
            //system.debug(LoggingLevel.INFO,'apiMatchingReportMap:'+apiMatchingReportMap);
            if(annTypeRec.Optional_Triggers__c != null){
                //system.debug(LoggingLevel.INFO,'annTypeRec.Optional_Triggers__c:'+annTypeRec.Optional_Triggers__c);
                for(String value : annTypeRec.Optional_Triggers__c.split(';')){
                    value = value.trim();
                    //system.debug(LoggingLevel.INFO,'value:'+value);
                    Set<String> apiSet = new Set<String>();
                    apiSet = apiMatchingReportMap.keySet();
                    //system.debug(LoggingLevel.INFO,'apiSet:'+apiSet);
                     
                    if(apiSet.contains(value)){
                        //system.debug('match');
                        //system.debug('match value:'+apiMatchingReportMap.get(value));
                        OptionalFieldAnn.add(value);
                    }   

                }
                    
            }
        }
        
        //system.debug(LoggingLevel.INFO,'after removing set value:'+OptionalFieldAnn);
        
      
        optionalTriggerFinalVal = '';

        if(OptionalFieldAnn != null && OptionalFieldAnn.size()>0){
            for(String val:OptionalFieldAnn){
                if(optionalTriggerFinalVal == null || optionalTriggerFinalVal == ''){
                    optionalTriggerFinalVal = val;
                }else{
                    optionalTriggerFinalVal = optionalTriggerFinalVal+'; '+val;
                }
            }
        }
        system.debug(LoggingLevel.INFO,'optionalTriggerFinalVal:'+optionalTriggerFinalVal);
        
        return reportOptionalMatchedField;
    }
   

}