/******* 
WB_ECAccountAllocation
Creation Date- 17 Mar 2015
Description- This class is to allocate Accounts to Ecs
Author- Harika Bondalapati
*******/
public class WB_ECAccountAllocation{
    public transient Boolean showtable{get;set;}
    public transient Boolean showpicklist{get;set;}
    
    public Boolean isOverride{get;set;}
    
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    public List<string> rightList{get;set;}
    Public Set<string> leftvalues = new Set<string>();
    Public Set<string> rightvalues = new Set<string>();
    public Set<string> picklistvalue = new Set<string>();
    public String mpmNames{get;set;}  
    public String MPMId{get;set;}
    public String ECPieceId {get;set;}
    public Integer dgSize {get;set;}
    public List<EC_Piece__c> EcpieceList{get;set;}
    public List<AccountFormat> DisplayAcctfmt {get;set;}
    public List<AccountFormat> DisplayAcctfmt2 {get;set;}
    public List<EC_Account_Allocation__c> testlist {get;set;}
    public List<EC_Account_Allocation__c> testlist2 {get;set;}
    public List<EC_Account_Allocation__c> DigitalAllocation{get;set;}
    public String SelectedVV{get;set;}
    public String SelectedBU{get;set;}  //ER-227: 17-Feb-2016
    
    //added by shalini - ER-000252
    public EC_Title_Allocation__c videoversionlookup {get;set;}
    
    // ER - 1633 --> Code added by Shubham (For 'Digital Allocation' Button)
    public ApexPages.StandardSetController setCon{get;set;}
    public Integer errorCount {get; set;}
    
    public WB_ECAccountAllocation(ApexPages.StandardSetController controller){
        setCon = controller;
        Id recId = ApexPages.currentPage().getParameters().get('id');
        showtable = false;
        showpicklist = true;
        isOverride = false;
        //errorCount = 0;
        if(recId != null){
            String objectName = String.valueOf(recId.getsobjecttype());
            if(objectName == 'MPM__c'){
                List<MPM__c> mpmList = [select Name,Id from MPM__c where Id=:recId limit 1];
                for(MPM__c m:mpmList){
                       mpmNames = m.Name;
                       MPMId = m.id;
                }  
            }
           if(objectName == 'EC_Piece__c'){
                ECPieceId = recId;
                List<MPM__c> mpmList = [select id,name from MPM__c where id in (select MPM__c from EC_Piece__c where Id=:ECPieceId)]; 
                for(MPM__c m:mpmList){
                     mpmNames = m.name;
                     MPMId = m.id;
                 }
            }
        }
    
        if(leftvalues.size() > dgSize){
           dgSize = leftvalues.size();
        }else{
           dgSize = 6;
        }
       
        //get the picklist default values
        Map<String,Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        List<Schema.PicklistEntry> ple = EC_Account_Allocation__c.Format__c.getDescribe().getPicklistValues();
        /* Display only records with format HD.  ER1782.
        for(Schema.PicklistEntry f : ple){
           picklistvalue.add(f.getValue());
        } 
	   */
        picklistvalue.add('HD');
   
        //create custom lists to be displayed on the page
        DisplayAcctfmt = new List<AccountFormat>();
        DisplayAcctfmt2 = new List<AccountFormat>();
        EcpieceList = new List<EC_Piece__c>();
       
        List<Account> accountList = [select Id,Name from Account where EC_Digital_Account__c = 'Digital'];
        for(Account acct:accountList){
           for(String pick:picklistvalue){
               String addname = acct.Name + ' - ' + pick;
               DisplayAcctfmt.add(new AccountFormat(acct.Id,acct.Name,pick,addname));
               leftvalues.add(addname);
           } 
   
        }
   
       //get the list of values from digital Allocation 
       testlist  = [select Id,Account__c,EC_Piece__c,checkedbox__c,Format__c,MPM__c,Title__c  from EC_Account_Allocation__c where MPM__c =:MPMId];
       testlist2 = testlist;
       DigitalAllocation = new List<EC_Account_Allocation__c>();
   
  
       leftselected = new List<String>();
       rightselected = new List<String>();  
       //added by shalini - ER-000252
       videoversionlookup = new EC_Title_Allocation__c();
            
    }
   
    public List<selectOption> getvvs() {
        List<Title__c> titleList = new List<Title__c>();
        titleList = [select Id,Name,Video_Version__c,MPM__c,Digital_Planning__c from Title__c where MPM__c =:MPMId AND Digital_Planning__c = 'Yes'];
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the picklist options
        
        for (Title__c titls:titleList) { 
              options.add(new selectOption(titls.id, titls.Video_Version__c + ' -- ' + titls.Name)); 
        //for all records found - add them to the picklist options
        }
        return options; //return the picklist options
    }
    
    //Added for ER-227
    public List<selectOption> getBusinessUnit()
    {
        List<selectOption>  BU = new List<selectOption>();
        List<Business_Unit__c> bUnits = Business_Unit__c.getAll().values();
        
        BU.add(new selectOption('--None--','--None--'));
        
        for(Business_Unit__c b : bUnits)
        {
            BU.add(new selectOption(b.Name, b.Name)); 
        }
        
        return BU;
    }
    
    
    public PageReference Allocate(){
        
        List<Title__c> titleList = [select Id, Name, Video_Version__c ,Digital_Planning__c from Title__c where Id = :videoversionlookup.Title__c];
        
        if(SelectedVV == null && videoversionlookup.Title__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please select a Video Version or Title with Digital Planning set before you edit the Digital Allocations'
            );
            ApexPages.addMessage(myMsg);
        }else if(isOverride && videoversionlookup.Title__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please select a Title from the lookup before you edit the Digital Allocations'
            );
            ApexPages.addMessage(myMsg);
            
        }else if(isOverride && videoversionlookup.Title__c != null && titleList.get(0).Digital_Planning__c !='Yes'){
            ApexPages.Message myMsg = new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please select a Title with Digital Planning set before you edit the Digital Allocations'
            );
            ApexPages.addMessage(myMsg);
        }
        else{
            showtable = true;
            showpicklist = false;
            rightList = new List<String>();
            DigitalAllocation.clear();
            //Id selectedVideoVersion = SelectedVV;
            rightList.addAll(rightvalues);
            //EcpieceList = [select Name,EC_Name__c,Id,MPM__c from EC_Piece__c where MPM__c=:MPMId order by Name]; 
            DisplayAcctfmt2 = new List<AccountFormat>();
            
            if(rightList!=null && rightList.size()>0){
                for(AccountFormat acnttfmt:DisplayAcctfmt){
                    for(string actual:rightList){
                        if(actual == acnttfmt.Acctfmt){
                            DisplayAcctfmt2.add(acnttfmt);
                        }
                    }
                }
            }
            
            //create custom list values for the table
            EcPieceList = [select Name,EC_Name__c,Id,MPM__c from EC_Piece__c where MPM__c=:MPMId order by Name];
            for(EC_Piece__c ec:EcPieceList){
                
                for(AccountFormat actfmt:DisplayAcctfmt2){
                    EC_Account_Allocation__c ecaRecord = new EC_Account_Allocation__c();
                    ecaRecord.EC_Piece__c = ec.Id;
                    ecaRecord.Account__c = actfmt.AcctId;
                    ecaRecord.MPM__c = MPMId;
                    ecaRecord.Format__c = actfmt.Format;
                    Boolean recordExists = false;
                    for(EC_Account_Allocation__c eca:testlist2){ 
                        //ER-252 Commented by shalini to allow EC Allocations to be created for same account but with different titles
                        if(eca.Account__c == actfmt.AcctId && eca.EC_Piece__c == ec.Id && eca.Format__c == actfmt.Format && (eca.Title__c == SelectedVV || eca.Title__c == videoversionlookup.Title__c)){
                          //if(eca.EC_Piece__c == ec.Id && eca.Title__c == SelectedVV && eca.Title__c == videoversionlookup.Title__c){
                            recordExists = true;
                            ecaRecord.checkedbox__c = true;
                            ecaRecord.Id = eca.Id;
                        }
                    }
                    if(recordExists == false){
                        ecaRecord.checkedbox__c = false;
                        ecaRecord.Id = null;
                    }
                    DigitalAllocation.add(ecaRecord);
                }
            }
        }
        return null;
    }
    
    //Added for ER-227
    //updated for ER-658 1/17/2017
    public PageReference Redirect()
    {
        String tId;
        if(SelectedBU == 'None')
        {
            ApexPages.Message myMsg6 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select Correct Business Unit');
            ApexPages.addMessage(myMsg6);
        }
        else if(isOverride && videoversionlookup.Title__c == null)
        {
            ApexPages.Message myMsg7 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Title from the lookup before you Automate Allocations');
            ApexPages.addMessage(myMsg7);
        }
        else if(isOverride && videoversionlookup.Title__c != null)
        {
            tId = videoversionlookup.Title__c;
        }
        else
        {
            tId = SelectedVV;
        }
            
        IF(tId != NULL && ECPieceId == NULL)
        {
            PageReference automate = new PageReference('/apex/WB_AutomateEcAllocation?id='+tId+'&bu='+SelectedBU+'&mpmId='+MPMId);
            return automate;
        }
        else if (tId != NULL && ECPieceId != NULL){
            PageReference automate = new PageReference('/apex/WB_AutomateEcAllocation?id='+tId+'&bu='+SelectedBU+'&mpmId='+MPMId+'&ecpieceId='+ECPieceId);
            return automate;
        }
        else return null;
    }
    
    public PageReference updateAll(){
       String accountfmt = Apexpages.currentPage().getParameters().get('q');
       String accid;
       String fmt;
       Boolean alltrue = false;
       for(AccountFormat acnfmt:DisplayAcctfmt){
           if(acnfmt.Acctfmt == accountfmt){
              accid = acnfmt.AcctId;
              fmt = acnfmt.Format;
           }
    
        }
    
        for(EC_Account_Allocation__c eca2:DigitalAllocation){
            if(eca2.Account__c == accid && eca2.Format__c == fmt){
               if(eca2.checkedbox__c == false && alltrue == false){
                  alltrue = true;
               }
             }
         }
         for(EC_Account_Allocation__c eca3:DigitalAllocation){
             if(eca3.Account__c == accid && eca3.Format__c == fmt && alltrue == true){
                eca3.checkedbox__c = true;
             }else if(eca3.Account__c == accid && eca3.Format__c == fmt && alltrue == false){
                eca3.checkedbox__c = false;
             }
         }
         return null;
    }
   
    public PageReference Saves(){
        
       //modified by shalini -- ER-252 
       String errorMessage='';
       errorCount=0;
       List<EC_Account_Allocation__c> insertList = new List<EC_Account_Allocation__c>();
       List<EC_Account_Allocation__c> deleteList = new List<EC_Account_Allocation__c>();
       for(EC_Account_Allocation__c eca6 : DigitalAllocation){
           if(eca6.checkedbox__c == true && eca6.Id == null){
                /* //added by shalini - ER-000252: Start */
                if(isOverride){
                   List<Title__c> titleList = [select Id, Name, Video_Version__c ,Digital_Planning__c from Title__c where Id = :videoversionlookup.Title__c ];
                    
                    if(titleList != null && titleList.size() > 0){
                        eca6.Title__c = titleList[0].Id;
                    }
                }/* //added by shalini - ER-000252 : End */
                else if(SelectedVV != null){
                    eca6.Title__c = SelectedVV;
                }
              insertList.add(eca6);
           }else if(eca6.checkedbox__c == false && eca6.Id != null){
             deleteList.add(eca6);
           }
           //errorCount++;
       }  
       try{
        
        //Insert EC Account Allocations
        Database.Saveresult[] results =  Database.insert(insertList,false);
        for (Database.Saveresult sr : results)
            {
                if (!sr.isSuccess())
                {
                    errorCount++;
                    for (Database.Error err : sr.getErrors())
                    {
                        errorMessage += (err.getMessage() + 'Exception  ');
                    }
                    system.debug(errorMessage);
                    //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                    //ApexPages.addMessage(errMsg);  
                      
                }
            }
       }catch(DmlException e) {
         System.debug('The following exception has occurred: ' + e.getMessage());
      }    
       Database.delete(deleteList);
       
       string theme = UserInfo.getUiThemeDisplayed();
       if (theme == 'Theme4d'){
           return null;
       } 
       
       return (errorCount == 0)? new PageReference('/'+MPMId) : null;
    }
    //ER-658 Updated on 1/17/2017
    
    public PageReference Cancel(){
        if(ECPieceId != NULL)
        {
            PageReference cancl= new PageReference('/'+ECPieceId);
            return cancl;
        }
        else {
            PageReference cancl= new PageReference('/'+MPMId);
            return cancl;    
        }
        
    }
  
    //---------------------------------------started the multi select picklist code 
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
       
        return null;
    }
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
      
        return null;
    }
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
   
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList){
               options1.add(new SelectOption(s,s));
        }
        return options1;
    }
    //--------------------------------End of Multi Select Picklist code
    
    //---- custom lists
    public class AccountFormat{
        public Id AcctId{get; set;}
        public String AcctName{get; set;}
        public String Format{get; set;}
        public String Acctfmt{get; set;}
                        
        public AccountFormat(Id actid,String actnm,String fmt,String actfmt){
          AcctId = actid;
          AcctName = actnm;
          Format = fmt;
          Acctfmt = actfmt;
        }
    
    }
}