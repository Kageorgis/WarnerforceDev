/******* 
Name:WB_CloneClientAvail_Controller
Creation Date- 9 May2014
Description- Controller for the cloning the records of Client Avail from Client Avail view list
Author- Rashmi Singh
*******/
public with sharing class WB_RunGapClientAvail_Controller {
    public list<string> selectedClientAvail ;
    public string availids;
    public Client_Avail__c obj;
    public list<client_avail__c> selectedClientAvail_list{get; set;}
    public string selectedAccntId;
    public list<Client_Avail__c> filteredClientAvail_lst1 ;
    public List<clientAvailwrapper> notMatchedClientAvailWrap_list {get;set;}
    public boolean flagException {get; set;}
    public boolean flagNoException {get; set;} 
        
    public WB_RunGapClientAvail_Controller (ApexPages.StandardSetController controller) {
        //selectedClientAvail = (list<Client_Avail__c>)controller.getSelected();
        
        availids = ApexPages.currentPage().getParameters().get('ID');
        selectedClientAvail = availids.split(',');
        obj= (Client_Avail__c) controller.getRecord();
        flagException = false ;
        flagNoException = false ;
        
        system.debug('@@@selectedClientAvail'+selectedClientAvail);
        
        
        selectedClientAvail_list = [Select id, name,Commercial_Avail__c,Commercial_Avail__r.Title__c,Release_Plan_Format__c,Commercial_Avail__r.Language_Type__c,
                                    Release_Plan_Channel__c,client__c,Release_Plan_Country__c,Commercial_Avail__r.Country_Lookup__c,Commercial_Avail__r.Languages__c,
                                    Release_Plan_Language__c,RP_Language_Type__c,Release_Plan_Title__c,Start_Date__c,End_Date__c,Status__c from Client_Avail__c 
                                    where id IN :selectedClientAvail ];
                            
        system.debug('@@@selectedClientAvail_list'+selectedClientAvail_list);
        
    }
    public class clientAvailwrapper{
        public Client_Avail__c clientAvail{get; set;}        
        public string reasonMsg{get;set;}       
        
        }
   
public void GapAnalysis(){

    list<Schema.FieldSetMember> selectedClientAvailforClone_list = new list<Schema.FieldSetMember>();
    list<Client_Avail__c> cloneSelectedClientAvail_list = new list<Client_Avail__c>();
    list<Client_Avail__c> cloneSelectedClientAvail_list2 = new list<Client_Avail__c>();
    selectedAccntId = obj.Client__c;
    list<string> clientAvailCountries = new list<string>();
    list<string> clientAvailRPIds = new list<string>();
    list<Client_Avail__c> existingClientAvail = new list<Client_Avail__c>();
    list<Agreement__c> filteredStorefront_list = new list<Agreement__c>();

    map<id,set<string>> mapStorefrontChannels = new  map<id,set<string>>();
    map<id,set<string>> mapstorefrontFormats = new  map<id,set<string>>();
    map<id,set<string>> mapstorefrontContentTypes = new  map<id,set<string>>();

    filteredClientAvail_lst1 = new list<Client_Avail__c>();
    notMatchedClientAvailWrap_list = new List<clientAvailwrapper>();

    set<string> clonedClientIds1 = new set<string>();
    set<string> exceptionClientIds1 = new set<string>();//existing record
    set<string> exceptionClientIds2 = new set<string>();//storefront
    set<string> exceptionClientIds = new set<string>();//All cumilative

        selectedClientAvailforClone_list = Schema.SObjectType.Client_Avail__c.fieldSets.getMap().get('All_fields_Client_avail').getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : selectedClientAvailforClone_list ){
        query += f.getFieldPath()+ ', ';
        }
        query += 'Id FROM Client_Avail__c where Id IN:selectedClientAvail_list ';
        cloneSelectedClientAvail_list =Database.query(query);

        system.debug('@@@cloneSelectedClientAvail_list'+cloneSelectedClientAvail_list.size());

        for(Client_Avail__c client:cloneSelectedClientAvail_list){
            clientAvailCountries.add(client.Commercial_Avail__r.Country_Lookup__c);
            clientAvailRPIds.add(client.Commercial_Avail__r.Id);
        }
        system.debug('clientAvailCountries'+clientAvailCountries+'size'+clientAvailCountries.size());

        //exiting client avail records.
        existingClientAvail =[Select id, name,Commercial_Avail__c,Client__c,Start_Date__c,End_Date__c,Status__c from Client_Avail__c 
                                where Commercial_Avail__c IN :clientAvailRPIds AND Client__c =:selectedAccntId];

        system.debug('@@@existingClientAvail'+existingClientAvail);
        
        if(existingClientAvail.size()!= 0 && existingClientAvail != null){
            for(Client_Avail__c cloneclient :cloneSelectedClientAvail_list ){
                integer counter=0;
                for(Client_Avail__c existclient :existingClientAvail ){
                    if(cloneclient.Commercial_Avail__c == existclient.Commercial_Avail__c){
                        if(cloneclient.Id != existclient.Id){
                            if(cloneclient.Start_Date__c != null && cloneclient.End_Date__c != null && existclient.Start_Date__c != null && existclient.End_Date__c != null){
                                if(cloneclient.Start_Date__c > existclient.End_Date__c || cloneclient.End_Date__c <existclient.Start_Date__c ){
                                        cloneSelectedClientAvail_list2.add(cloneclient);                                                
                                        
                                }else{
                                        exceptionClientIds1.add(cloneclient.Id);
                                } counter++;
                            }                       
                        }
                    }
                } if(counter==0){
                    cloneSelectedClientAvail_list2.add(cloneclient );
                }
            } 
        }
        else{
            cloneSelectedClientAvail_list2.addAll(cloneSelectedClientAvail_list);
        }
        system.debug('@@@cloneSelectedClientAvail_listsize'+cloneSelectedClientAvail_list.size());
        system.debug('@@@cloneSelectedClientAvail_list2_size'+cloneSelectedClientAvail_list2.size()); 
        system.debug('exceptionClientIds1$$$'+exceptionClientIds1);
        //storefrnt logic 
        filteredStorefront_list = [SELECT Id,Name,Account__c,Account__r.Name,Pricing_Currency__c,Country__c,Channel_Picklist__c,
                        Format__c,Content_Type__c FROM Agreement__c WHERE Account__c =:selectedAccntId AND Country__c 
                        IN:clientAvailCountries];
        system.debug('@@filteredStorefront_list'+filteredStorefront_list);


        for(Agreement__c strfrnt : filteredStorefront_list ){
            set<string> storefrontChannels = new set<string>();
            list<string> storefrontChannels2 = new list<string>();
            set<string> storefrontFormats = new set<string>();
            list<string> storefrontFormats2 = new list<string>();
            set<string> storefrontContentTypes = new set<string>();
            list<string> storefrontContentTypes2 = new list<string>();

            if(strfrnt.Channel_Picklist__c!=null){
                storefrontChannels2=strfrnt.Channel_Picklist__c.split(';');         
                storefrontChannels.addAll(storefrontChannels2);
                mapStorefrontChannels.put(strfrnt.Id,storefrontChannels);
            }
            if(strfrnt.Format__c!=null){
                storefrontFormats2=strfrnt.Format__c.split(';');
                storefrontFormats.addAll(storefrontFormats2);
                mapstorefrontFormats.put(strfrnt.Id,storefrontFormats);
            }
            if(strfrnt.Content_Type__c!=null){
                storefrontContentTypes2=strfrnt.Content_Type__c.split(';');
                storefrontContentTypes.addAll(storefrontContentTypes2);
                mapstorefrontContentTypes.put(strfrnt.Id,storefrontContentTypes);
            }  
        }

        system.debug('@@@mapStorefrontChannels'+mapStorefrontChannels);
        system.debug('@@@mapstorefrontFormats'+mapstorefrontFormats);
        system.debug('@@@mapstorefrontContentTypes'+mapstorefrontContentTypes);

        //clonned functionality
        for(Client_Avail__c clientAvail :cloneSelectedClientAvail_list2){
            for(Agreement__c selectStrfront : filteredStorefront_list ){
                if(clientAvail.Commercial_Avail__r.Country_Lookup__c == selectStrfront.Country__c && selectedAccntId == selectStrfront.Account__c){
                    if( mapStorefrontChannels.size() != 0 && mapstorefrontFormats.size()!= 0&& mapstorefrontContentTypes.size()!= 0){
                        if(mapStorefrontChannels.get(selectStrfront.Id)!= Null && mapstorefrontFormats.get(selectStrfront.Id)!=Null && mapstorefrontContentTypes.get(selectStrfront.Id)!= Null){
                            if(mapStorefrontChannels.get(selectStrfront.Id).contains(clientAvail.Release_Plan_Channel__c) && mapstorefrontFormats.get(selectStrfront.Id).contains(clientAvail.Release_Plan_Format__c)
                            && mapstorefrontContentTypes.get(selectStrfront.Id).contains(clientAvail.Title_Content_Type__c)){

                            Client_Avail__c newRecod = new Client_Avail__c();
                            newRecod = clientAvail.clone(false,false,false,false);
                            newRecod.Client__c = selectStrfront.Account__c;
                            newRecod.Storefront__c = selectStrfront.Id;
                            clonedClientIds1.add(clientAvail.Id);

                            filteredClientAvail_lst1.add(newRecod);
                            }
                        }
                    }
                }
            }
        }
        system.debug('@@@filteredClientAvail_lst1'+filteredClientAvail_lst1.size()+'size'+filteredClientAvail_lst1);

        for(Client_Avail__c clientAvail :cloneSelectedClientAvail_list2 ){
            if(clonedClientIds1.contains(clientAvail.Id)){
            }else{
            exceptionClientIds2.add(clientAvail.Id);
            }
        }

        exceptionClientIds.addAll(exceptionClientIds1);
        exceptionClientIds.addAll(exceptionClientIds2);

        system.debug('@@@exceptionClientIds'+exceptionClientIds);

        //flag for rendering the block
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

        system.debug('@@exceptionClientAvail_lst'+exceptionClientAvail_lst);


        //Wrapper with reasons
        for(Client_Avail__c clientAvail :exceptionClientAvail_lst ){
            clientAvailwrapper real= new clientAvailwrapper();
            real.clientAvail =clientAvail;
            if(exceptionClientIds1.contains(clientAvail.Id)){
                real.reasonMsg ='Client Avail present for this Account in the selected Date range ';
            }
            else {
                real.reasonMsg ='Storefront is not present OR Channel/Content Type/Format is not present. ';
                }
                notMatchedClientAvailWrap_list.add(real);
        }
        system.debug('@@@notMatchedClientAvailWrap_list'+notMatchedClientAvailWrap_list);                                                               

}

public pageReference Okbutton(){
    system.debug('@@@filteredClientAvail_lst1'+filteredClientAvail_lst1);
        try {
            if(filteredClientAvail_lst1 != null && filteredClientAvail_lst1.size() > 0) {       
            
                    Database.Saveresult[] saveResult  = Database.insert(filteredClientAvail_lst1, false);
                    system.debug('@@@saveResult[0].isSuccess()'+saveResult);
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
                Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please Cancel the Analysis because No client avails can be created'));
            }
        } 
        catch(Exception e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
   
   
    return null;
    }
    public pageReference Bulkcancel(){
        pageReference PageRef= new Pagereference(System.Label.Redirect_to_All_Client_avail);
        return PageRef;
    }
        
}