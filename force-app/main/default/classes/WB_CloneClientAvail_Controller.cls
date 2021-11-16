/******* 
Name:WB_CloneClientAvail_Controller
Creation Date- 9 May2014
Description- Controller for the cloning the records of Client Avail from Client Avail view list
Author- Rashmi Singh
*******/
public with sharing class WB_CloneClientAvail_Controller{
   public string availids;
   public list<string> selectedClientAvail ;
   public Client_Avail__c obj;
   public list<client_avail__c> selectedClientAvail_list{get; set;}
   public date selectedStartDate;
   public date selectedEndDate;
   public list<Client_Avail__c> finalClientAvail_lst ;
   public boolean flagException {get; set;}
   public boolean flagNoException {get; set;} 
   public List<clientAvailwrapper> notMatchedClientAvailWrap_list {get;set;}
    
    public WB_CloneClientAvail_Controller(ApexPages.StandardSetController controller) {     
        availids = ApexPages.currentPage().getParameters().get('ID');
        selectedClientAvail = availids.split(',');
        obj= (Client_Avail__c) controller.getRecord();
        obj.Status__c ='Draft';
        flagException = false ;
        flagNoException = false ;
        
        selectedClientAvail_list = [Select id, name,Commercial_Avail__c,Commercial_Avail__r.Title__c,Release_Plan_Format__c,Commercial_Avail__r.Language_Type__c,
                                    Release_Plan_Channel__c,client__c,Release_Plan_Country__c,Commercial_Avail__r.Country_Lookup__c,Commercial_Avail__r.Languages__c,
                                    Release_Plan_Language__c,RP_Language_Type__c,Release_Plan_Title__c,Start_Date__c,End_Date__c,Status__c from Client_Avail__c 
                                    where id IN :selectedClientAvail ];
                                     
    }
    public class clientAvailwrapper{
        public Client_Avail__c clientAvail{get; set;}        
        public string reasonMsg{get;set;}       
        
        }
    public void CloneCheck(){
        
        list<Schema.FieldSetMember> selectedClientAvailforClone_list = new list<Schema.FieldSetMember>();
        list<Client_Avail__c> cloneSelectedClientAvail_list = new list<Client_Avail__c>();
        list<Client_Avail__c> cloneSelectedClientAvail_list2 = new list<Client_Avail__c>();
        list<Client_Avail__c> cloneSelectedClientAvail_list3 = new list<Client_Avail__c>();
        list<Client_Avail__c> cloneSelectedClientAvail_listfinal = new list<Client_Avail__c>();
        selectedStartDate = obj.Start_Date__c ;
        selectedEndDate = obj.End_Date__c ;
        set<string> clientAvailAccounts = new set<string>();
        set<string> clientAvailRPIds = new set<string>();
        
        set<string> exceptionClientIds1 = new set<string>();//with selected records
        set<string> exceptionClientIds2 = new set<string>();//with existing records
        set<string> exceptionClientIds3 = new set<string>();//selected dates out side release plan date range
        set<string> exceptionClientIds = new set<string>();//All cumilative
        
        finalClientAvail_lst = new list<client_avail__c>();
        notMatchedClientAvailWrap_list = new List<clientAvailwrapper>();
        
        
        list<Client_Avail__c> existingClientAvail = new list<Client_Avail__c>();
        
        selectedClientAvailforClone_list = Schema.SObjectType.Client_Avail__c.fieldSets.getMap().get('All_fields_Client_avail').getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : selectedClientAvailforClone_list ){
            query += f.getFieldPath()+ ', ';
        }
        query += 'Id FROM Client_Avail__c where Id IN:selectedClientAvail_list ';
        cloneSelectedClientAvail_list =Database.query(query);

        for(Client_Avail__c client:cloneSelectedClientAvail_list){
            clientAvailAccounts.add(client.client__c);
            clientAvailRPIds.add(client.Commercial_Avail__r.Id);
        }
               
        //filterout first level if selected date overlap with selected clientavail records.
        for(Client_Avail__c client:cloneSelectedClientAvail_list){
            if(client.Start_Date__c != null && client.End_Date__c != null && selectedStartDate != null && selectedStartDate != null){
                if(selectedStartDate > client.End_Date__c || selectedEndDate <client.Start_Date__c ){
                    cloneSelectedClientAvail_list2.add(client);
                }
                else exceptionClientIds1.add(client.Id);
            }
        }
       
        //filterout the records if selected dates are within the release plan start and end date.
        for(Client_Avail__c client:cloneSelectedClientAvail_list2){
            if(client.Release_Plan_Start_Date__c != null && client.Release_Plan_End_Date__c != null && selectedStartDate != null && selectedStartDate != null){
                if(client.Release_Plan_Start_Date__c <= selectedStartDate && selectedEndDate <= client.Release_Plan_End_Date__c ){
                    cloneSelectedClientAvail_list3.add(client);
                }
                else exceptionClientIds3.add(client.Id);
            }
        }
     
        //exiting client avail records.
        existingClientAvail =[Select id, name,Commercial_Avail__c,Client__c,Start_Date__c,End_Date__c,Status__c from Client_Avail__c 
                                where Commercial_Avail__c IN :clientAvailRPIds AND Client__c IN :clientAvailAccounts];

     
        //filtering the records with existing record date overlapp.
        
        if(existingClientAvail.size()!= 0 && existingClientAvail != null){
            for(Client_Avail__c cloneclient :cloneSelectedClientAvail_list3 ){
                integer counter=0;
                for(Client_Avail__c existclient :existingClientAvail ){
                    if(cloneclient.Commercial_Avail__c == existclient.Commercial_Avail__c && cloneclient.Client__c == existclient.Client__c){
                        if(cloneclient.Id != existclient.Id){
                            if(existclient.Start_Date__c != null && existclient.End_Date__c != null && selectedStartDate != null && selectedStartDate != null){
                                if(selectedStartDate > existclient.End_Date__c || selectedEndDate <existclient.Start_Date__c  ){
                                                                                        
                                        
                                }else{
                                       counter++;
                                       exceptionClientIds2.add(cloneclient.Id);
                                    } 
                                }                       
                            }
                        }
                    } 
                    if(counter==0){
                    cloneSelectedClientAvail_listfinal.add(cloneclient);
                }
            } 
        }
        else{
            cloneSelectedClientAvail_listfinal.addAll(cloneSelectedClientAvail_list2);
        }
       
   
       //Exception list to display
       exceptionClientIds.addAll(exceptionClientIds1);
       exceptionClientIds.addAll(exceptionClientIds2);
       exceptionClientIds.addAll(exceptionClientIds3);

        if(exceptionClientIds.size() != 0){
            flagException= true;
            flagNoException= false;        
        }else{
            flagException= false;
            flagNoException= true; 
        }
        
        list<Client_Avail__c> exceptionClientAvail_lst =[Select id, name,Commercial_Avail__c,Commercial_Avail__r.Title__c,Release_Plan_Channel__c,Release_Plan_Format__c,Commercial_Avail__r.Language_Type__c,
                                                        client__c,Commercial_Avail__r.Country_Lookup__c,Commercial_Avail__r.Languages__c,
                                                        Start_Date__c,End_Date__c,Status__c from Client_Avail__c  where id IN :exceptionClientIds];

        //Wrapper with reasons
        for(Client_Avail__c clientAvail :exceptionClientAvail_lst ){
            clientAvailwrapper real= new clientAvailwrapper();
            real.clientAvail =clientAvail;
            if(exceptionClientIds1.contains(clientAvail.Id)){
                real.reasonMsg ='Entered date range overlapp with selected records ';
            }
            else if(exceptionClientIds2.contains(clientAvail.Id)){
                real.reasonMsg =' Entered date range overlapp with existing records';
            }
           else{
           		real.reasonMsg =' Entered date range outside the Release Plan dates';
           }
                
            notMatchedClientAvailWrap_list.add(real);
        }
    
       //Clonning logic.
        for(Client_Avail__c clientAvail :cloneSelectedClientAvail_listfinal ){          
            Client_Avail__c newRecod = new Client_Avail__c();
            newRecod = clientAvail.clone(false,false,false,false);
            newRecod.Start_Date__c = selectedStartDate;
            newRecod.End_Date__c = selectedEndDate;
            newRecod.Status__c = obj.Status__c;
            newRecod.Comments__c = obj.Comments__c;
            
            finalClientAvail_lst.add(newRecod);
        }
    
    }
    
    public pageReference Okbutton(){
  
        try {
            if(finalClientAvail_lst != null && finalClientAvail_lst.size() > 0) {       
            
                    Database.Saveresult[] saveResult  = Database.insert(finalClientAvail_lst, false);                  
                    boolean flageReDirect=true;
                    for(integer i=0;i<saveResult.size();i++){
                        if(!(saveResult[i].isSuccess())){
                                flageReDirect=false;
                        }                    
                    }
                    if (flageReDirect==true){                    
                        Pagereference PageRef = new Pagereference(System.Label.Redirect_to_All_Client_avail);                      
                        return PageRef;
                     } 
                    
            }
            else{
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Cancel  because no Client Avails can be created'));
            }
        } 
        catch(Exception e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
   
   
    return null;
    }
        
    public pageReference Bulkcancel(){
        pageReference PageRef= new Pagereference(System.Label.Cancel_CloneClientAvail);
        return PageRef;
    }


}