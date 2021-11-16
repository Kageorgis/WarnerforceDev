public class RF_MpmReleaseDateTriggerHandler { 
    
    public String tvId = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
    public String theatricalID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
    //Id catalogID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('Catalog').getRecordTypeId();
    //Id JvID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('SDS').getRecordTypeId();
    
    public void createReleaseRcrd(List<MPM_Release_Date__c> lstMpmReleaseDt){
        List<Release__c> insRlist=new List<Release__c>();
        List<Release__c> insUpRlist=new List<Release__c>();
        Set<Id> countryIds=new Set<Id>();
        Set<Id> mpmIds=new Set<Id>();
        Set<String> countryNames=new Set<String>();
        String defaultstudio = MPM_release_date_Default_Studio__c.getOrgDefaults().Studio__c;
        system.debug('defaultstudio===>'+defaultstudio);
        RF_Studio__c studiotodefault;
        if(defaultstudio!=null){
             studiotodefault = [select id, name from RF_Studio__c where name = : defaultstudio limit 1]; 
        }
          
        for(MPM_Release_Date__c rlDt : lstMpmReleaseDt){
            if(rlDt.Country__c!=null)
                countryIds.add(rlDt.Country__c);
            if(rlDt.MPM__c!=null){
                mpmIds.add(rlDt.MPM__c);
            }
        }
        
        Map<Id,Country__c> countryMap= new Map<Id,Country__c>();
        
        for(Country__c cnty:[SELECT Id,Name FROM Country__c WHERE Id IN:countryIds]){
            countryMap.put(cnty.Id,cnty);
            countryNames.add(cnty.Name);
        }
        Map<String,List<Release__c>> existingrlMap=new Map<String,List<Release__c>>();
        
        for(Release__c rl:[SELECT Id,First_Theatrical_Date__c,MPM__c,Country_List__c,recordTypeId FROM Release__c WHERE MPM__c IN:mpmIds AND Country_List__c IN:countryNames AND recordTypeId=:theatricalID]){
            
            String rlKey=rl.MPM__c+'_'+rl.Country_List__c;
            if(existingrlMap.containsKey(rlKey)){
                
                List<Release__c> rList=existingrlMap.get(rlKey);
                rList.add(rl);
                existingrlMap.put(rlKey,rList);
            }else{
                List<Release__c> rListNew=new List<Release__c>();
                rListNew.add(rl);
                existingrlMap.put(rl.MPM__c+'_'+rl.Country_List__c,rListNew);
            }
        }
        
        string relRecTypeID = Schema.SobjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        
        for(MPM_Release_Date__c rlDt : lstMpmReleaseDt){
            
            String countryNm='';
            system.debug('countryMap.get of AUS===>'+countryMap.get(rlDt.Country__c));
            if((rlDt.Channel__c==null || String.isEmpty(rlDt.Channel__c))&& (rlDt.Format__c==null || String.isEmpty(rlDt.Format__c))){
                if(countryMap.containsKey(rlDt.Country__c)){countryNm= countryMap.get(rlDt.Country__c).Name;}
                if(rlDt.MPM__c!=null){
                    system.debug('<==== for AUS record ====>');
                    String mpKey= rlDt.MPM__c+'_'+countryNm;
                    if(!existingrlMap.containsKey(mpKey)){
                        Release__c rlNw=new Release__c();
                        if(studiotodefault!=NULL){
                            rlNw.RF_Studio__c=studiotodefault.id;
                            
                        }
                        //rlNw.recordTypeId= relRecTypeID;
                        if(rlDt.Country__c!=null){
                            //rlNw.Country__c= rlDt.Country__c;
                            if(countryMap.containsKey(rlDt.Country__c)){
                                if((countryMap.get(rlDt.Country__c).Name=='USA')||(countryMap.get(rlDt.Country__c).Name=='Canada')||(countryMap.get(rlDt.Country__c).Name=='Australia')){
                                    system.debug('countryMap.get(rlDt.Country__c).Name===>'+countryMap.get(rlDt.Country__c).Name);
                                    rlNw.Country_List__c= countryMap.get(rlDt.Country__c).Name;
                                }
                            }
                            
                        }
                        if(rlDt.MPM__c!=null){
                            string description;
                            rlNw.MPM__c= rlDt.MPM__c;
                            if((rlDt.MPM_Short_Description__c!=null)&&(rlDt.Country__c!=null)){
                                if(countryMap.get(rlDt.Country__c).Name!='USA'){
                                    description = rlDt.MPM_Short_Description__c;
                                    description.remove('SDS USE ONLY');
                                    system.debug('description===>'+description.remove('SDS USE ONLY'));
                                    rlNw.Name= description.remove('SDS USE ONLY')+'_'+countryMap.get(rlDt.Country__c).Name;
                                }else if(countryMap.get(rlDt.Country__c).Name=='USA'){
                                    description = rlDt.MPM_Short_Description__c;
                                    rlNw.Name= description.remove('SDS USE ONLY');
                                }
                                
                            }else if(rlDt.Country__c!=null){
                                rlNw.Name= '_'+countryMap.get(rlDt.Country__c).Name;
                            }else if(rlDt.MPM_Short_Description__c!=null){
                                rlNw.Name= rlDt.MPM_Short_Description__c;
                            }else{
                                rlNw.Name='Test-Release';
                            }
                        }
                        if(rlDt.Theatrical_Release_Date__c!=null){
                            rlNw.First_Theatrical_Date__c= rlDt.Theatrical_Release_Date__c;
                            rlNw.recordTypeId= theatricalID;
                        }else{
                            rlNw.recordTypeId= theatricalID;
                        } 
                        system.debug('rlDt.MPM_Short_Description__c===>'+rlDt.MPM_Short_Description__c);
                        if(rlDt.MPM_Short_Description__c!=NULL){
                             if(!(rlDt.MPM_Short_Description__c.containsIgnoreCase('SDS USE ONLY'))){
                            insRlist.add(rlNw);    
                        }
                       
                        }
                        
                    }else{
                        if(rlDt.Theatrical_Release_Date__c > SYSTEM.TODAY()){
                            for(Release__c exRl:existingrlMap.get(mpKey)){
                                if(exRL.recordTypeId== theatricalID){
                                    exRl.First_Theatrical_Date__c= rlDt.Theatrical_Release_Date__c;
                                    insUpRlist.add(exRl);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if(insRlist.size()>0){
            try{
                Database.insert(insRlist);
            }catch(Exception e)
            {
                System.debug('Following error occurred in Release insert: '+e.getMessage());
            }
        }
        if(insUpRlist.size()>0){
            try{
                Database.update(insUpRlist);
            }catch(Exception e)
            {
                System.debug('Following error occurred in Release update: '+e.getMessage());
            }
        }
    }
    public void updateReleaseRcrd(Map<Id,MPM_Release_Date__c> rlDtNewMap,Map<Id,MPM_Release_Date__c> rlDtOldMap){
        
        Map<Id,MPM_Release_Date__c>updRlDatempmMap=new Map<Id,MPM_Release_Date__c>();
        List<Release__c> updRlist=new List<Release__c>();
        Set<Id> countryIds=new Set<Id>();
        Set<String> countryNames=new Set<String>();
        
        for(Id mpmRlDtId : rlDtNewMap.keySet()){
            
            if(rlDtNewMap.get(mpmRlDtId).Theatrical_Release_Date__c!= rlDtOldMap.get(mpmRlDtId).Theatrical_Release_Date__c){
                
                if(rlDtNewMap.get(mpmRlDtId).MPM__c!=null){
                    updRlDatempmMap.put(rlDtNewMap.get(mpmRlDtId).MPM__c,rlDtNewMap.get(mpmRlDtId));
                }
                if(rlDtNewMap.get(mpmRlDtId).Country__c!=null)
                    countryIds.add(rlDtNewMap.get(mpmRlDtId).Country__c);
            }
        }
        
        Map<Id,Country__c> countryMap= new Map<Id,Country__c>();
        
        list<country__c> countrylist = [SELECT Id,Name FROM Country__c WHERE Id IN:countryIds];
        
        for(Country__c cnty:countrylist){
            countryMap.put(cnty.Id,cnty);
            countryNames.add(cnty.Name);
        }
        
        
        list<Release__c> releaselist = [SELECT Id,First_Theatrical_Date__c,MPM__c FROM Release__c WHERE MPM__c IN:updRlDatempmMap.keySet() AND Country_List__c IN:countryNames AND RecordTypeId=:theatricalID];
        for (Release__c rl : releaselist){
            
            if(updRlDatempmMap.get(rl.MPM__c).Theatrical_Release_Date__c > SYSTEM.TODAY()){
                rl.First_Theatrical_Date__c= updRlDatempmMap.get(rl.MPM__c).Theatrical_Release_Date__c;
                
                updRlist.add(rl);
            }else if(String.isBlank(string.valueof(updRlDatempmMap.get(rl.MPM__c).Theatrical_Release_Date__c))){
                system.debug('control is in null else if ====>');
                
                rl.First_Theatrical_Date__c=NULL;
                rl.Early_Pre_Order_Date__c=NULL;
                rl.est_date__C=NULL;
                rl.VOD_Street_Date__c=null;
                rl.Drafting_Start_Date__c=null;
                rl.Drafting_End_Date__c=null;
                rl.Trade_Assets_Due_to_JV_Date__c=null;
                rl.Selling_Guides_Due_Date__c=null;
                rl.Order_Due_Date__c=null;
                rl.Suppression_Lift_Datee__c=null;
                rl.PVOD_Date__c=NULL;
                rl.PEST_Date__c=NULL;
                rl.In_Plant_Date__c=NULL;
                rl.street_date__C=NULL;
                rl.Physical_Rental_Date__c=NULL;
                rl.Trade_Solicitation_Date__c=NULL;
                rl.Approve_Catalog_Drafting_Titles__c=NULL;
                rl.Marketing_Guidelines_Guardrails__c=NULL;
                rl.Domestic_Initial_Info_To_Mkts_Request__c=NULL;
                rl.WW_Creative_Kick_Off__c=NULL;
                rl.Marketing_Alert_Request_Input_To_Plan__c=NULL;
                rl.L1_Review_Date__c=NULL;
                rl.L2_Review_Date__c=NULL;
                rl.L3_Review_Date__c=NULL;
                rl.Filmmaker_3rd_Party_Due_Date__c=NULL;
                rl.Client_Avails_Confirmation__c=NULL;
				updRlist.add(rl);
            }
        }
        
        if(updRlist.size()>0){
            try{
                Database.update(updRlist);
            }catch(Exception e)
            {
                System.debug('Following error occurred in Release update: '+e.getMessage());
            }
        }
    }
}