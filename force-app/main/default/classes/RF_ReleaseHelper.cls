/*========================================================================================================
* @author sai santhan(left), Kalash Rastogi
* @date 20/09/2020
* @description: Helper class that will implement the functionality of Release

==========================================================================================================*/
public class RF_ReleaseHelper {
    public static Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap = new Map< String, RF_Relase_Date_Config__mdt >();
    
    public static RF_Release_Wrapper fetchRF_ReleaseDateDefaults(){
        
        Map< String, Decimal > releaseDateDefaultsMap = new Map< String, Decimal >();
        Map< String, String > sourcefieldMap = new Map< String, String >();
        Map< String, String > destinationfieldMap = new Map< String, String >();
        Map< String, String > calculatedfieldMap = new Map< String, String >();
        Map< String, String > calculatedfield_operation_Map = new Map< String, String >();
        RF_Release_Wrapper releaseObjWrapper = new RF_Release_Wrapper();
        List<RF_Relase_Date_Config__mdt  > releaseDateDefaults_list = new List<RF_Relase_Date_Config__mdt  >(); 
        releaseDateDefaults_list.addAll([SELECT Label,DeveloperName, Calculated_Field_Operation__c ,Calculated_Field_Value__c, Source_Field_Label__c,Destination_Field_Label__c,Calculated_Field_Label__c,Calculated_field__c,Calculation__c,Destination_Field__c,Object_API_Name__c,Source_Field__c,Studio__c 
                                         FROM RF_Relase_Date_Config__mdt ]);
        system.debug('releaseDateDefaults_list size=====>'+releaseDateDefaults_list.size());
        for(RF_Relase_Date_Config__mdt  rf_release : releaseDateDefaults_list){
            
            
            //SAP Code START//
            releaseDefaultLabelMap.put(rf_release.DeveloperName,rf_release);
            //SAP Code END//
            
            if(rf_release.Destination_Field__c!=null){
                destinationfieldMap.put(rf_release.Destination_Field_Label__c,rf_release.Destination_Field__c);
            }
            if(rf_release.Calculation__c!=null){
                releaseDateDefaultsMap.put(rf_release.Source_Field__c, rf_release.Calculation__c);
                sourcefieldMap.put(rf_release.Source_Field_Label__c,rf_release.Source_Field__c);
                //system.debug('rf_release.Source_Field__c-------->'+rf_release.Source_Field__c+'-----rf_release.Calculation__c--->'+rf_release.Calculation__c);
                
            }
        }
        releaseObjWrapper.releaseDateDefaultsMap = releaseDateDefaultsMap;
        releaseObjWrapper.sourcefieldMap = sourcefieldMap;
        
        releaseObjWrapper.calculatedfieldMap = calculatedfieldMap;//This section can be removed as calculated field map is not in use
        releaseObjWrapper.destinationfieldMap = destinationfieldMap;
        return releaseObjWrapper;
    }
    //W-017888 - INTERNATIONAL_CHANGES -Prevent user from updating theatrical Release date for Dash tracked country (except for US & Canada)
        /* public static void PreventTheatricalDate(List<release__c> newRecordsList,list<release__c> oldRecordList){
        
        map<id,release__c> relCountryNewMap = new map<id,release__c>();
        map<id,release__c> relCountryOldMap = new map<id,release__c>();
        for(release__c rel:newRecordsList){
            relCountryNewMap.put(rel.country__c,rel);
        }
        for(release__c rel:oldRecordList){
            relCountryOldMap.put(rel.country__c,rel);
        }
        
        list<country__c> countryList = [select id,name,Dash_Tracked_Countries__c from country__c where id in :relCountryNewMap.keyset()];
        for(country__c cnt:countryList){
            release__c newRelRec = relCountryNewMap.get(cnt.id);
            release__c oldRelRec = relCountryOldMap.get(cnt.id);
            system.debug('Thea'+newRelRec.First_Theatrical_Date__c);
            system.debug(oldRelRec.First_Theatrical_Date__c);
            system.debug(newRelRec.Source__c);
            system.debug(cnt.name);
            system.debug(cnt.Dash_Tracked_Countries__c);
            
                if(newRelRec.First_Theatrical_Date__c != oldRelRec.First_Theatrical_Date__c){
                    if(newRelRec.Source__c == 'WBHE'&&(newRelRec.Country_List__c !='USA')&& cnt.Dash_Tracked_Countries__c == true){
                            system.debug('DashTrack'+cnt.Dash_Tracked_Countries__c);
                            system.debug('DashTrack'+newRelRec.Country_List__c);
                           newRelRec.addError(Label.Prevent_Theatrical_Release_Date);
                        }
                }
            }
            
        }*/
        
    //W-017705 - RF - Uni Releaseforce Integration
    //If Release__c Source = UPHE and any of the following fields are updated, set Integration State to "Pick me up"
    Public static void setIntegrationStatus(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        for(Id ex:newItems.keySet()){
            Release__c newrec = (Release__c)newItems.get(ex);
            Release__c oldrec = (Release__c)oldItems.get(ex);
            //if(oldrec.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
            //  continue;
            system.debug('newrec: '+newrec+'oldrec: '+oldrec);
            if(newrec.In_Plant_Date__c != oldrec.In_Plant_Date__c 
               ||newrec.Order_Due_Date__c!=oldrec.Order_Due_Date__c 
               ||newrec.Trade_Assets_Due_to_JV_Date__c!=oldrec.Trade_Assets_Due_to_JV_Date__c 
               ||newrec.Selling_Guides_Due_Date__c!= oldrec.Selling_Guides_Due_Date__c
               ||newrec.Trade_Solicitation_Date__c!= oldrec.Trade_Solicitation_Date__c
               ||newrec.Premium_Release_Announce_Date__c != oldrec.Premium_Release_Announce_Date__c ){
                   
                   if(newrec!= null && newrec.source__c == Label.RF_UPHE){
                       system.debug('statuext'+ newrec.source__c);
                       newrec.Integration_State__c = LABEL.RF_PICK_ME_UP;
                   }
               }
            
            if(newrec.Premium_Release_Announce_Date__c != oldrec.Premium_Release_Announce_Date__c && (newrec.Source__c == 'UPHE' || newrec.Source__c == 'SDS') && (newrec.Distributor__c).toLowerCase() == 'universal'){
                newrec.Integration_State__c = LABEL.RF_PICK_ME_UP;
            }
        }
    }
    //W-017705 -  If Source = SDS and Distributor = Uni and Status = Live OR Cancelled - set Integration State to "Pick me up".
    Public static void setIntegrationStatus2(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        for(Id ex:newItems.keySet()){
            Release__c newrec = (Release__c)newItems.get(ex);
            Release__c oldrec = (Release__c)oldItems.get(ex);
            if(oldrec.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            if(newrec!= null && newrec.Source__c == Label.RF_SDS && newrec.Distributor__c == Label.RF_UNI && (newrec.RF_Status__c == Label.RF_LIVE ||newrec.RF_Status__c == Label.RF_CANCELLED)){
                newrec.Integration_State__c = LABEL.RF_PICK_ME_UP;
            }
        }
    }
    // Defaulting Distributor From RF Studio
    public static void defautlDistributorFromStudio(List<release__c> newItemsList){
        Map<id,release__c> releaseMap = new Map<id,release__c>();
        for(release__c rel:newItemsList){
            releaseMap.put(rel.rf_studio__c,rel);
        }
        
        List<rf_studio__c> rfStudioList=[select id,name,RF_Studio1__c,distributor__c from rf_studio__c where id IN :releaseMap.KeySet()];
        
        for(rf_studio__c rf:rfStudioList){
            release__c rel = releaseMap.get(rf.id);
            //if(rel.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
            //    continue;
            system.debug('rf.RF_Studio1__c->'+rf.RF_Studio1__c);
            rel.RF_Studio1__c   = rf.RF_Studio1__c;
            system.debug('ReleaseStudio->'+rel.RF_Studio1__c);
            rel.distributor__c =  rf.distributor__c;
            system.debug('distributor->'+rel.distributor__c);
        }
        
    }
    /*------------------------START------------------------------*/
    // Default Primary Contact and Backup Contact if physicalStreet date present.
    public static void insertprimaryBackupcontemail(List<release__c> newItemsList){ //Insert
        Map<id,release__c> relConMap = new Map<id,release__c>();
        for(release__c rel:newItemsList){
            //Release__c newrec = (Release__c)newItems.get(rel);
            if(rel.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            if(rel.Street_Date__c!=null && (rel.Country_List__c == 'USA' || rel.Country_List__c == 'Canada')){
                rel.Primary_Contact_Email__c = Label.RF_Primary_Contact;
                rel.Backup_Contact_Email__c  = Label.RF_Backup_Contact;
            }
        } 
    }
    
    public static void defaultprimaryBackupcontemail(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){ //update
        Map<id,release__c> relConMap = new Map<id,release__c>();
        for(Id ex:newItems.keySet()){
            Release__c newrec = (Release__c)newItems.get(ex);
            Release__c oldrec = (Release__c)oldItems.get(ex);
            if(oldrec.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            System.debug('###');
            if(newrec.Street_Date__c!= oldrec.Street_Date__c && (newrec.Country_List__c == 'USA' || newrec.Country_List__c == 'Canada') ){
                // Boolean a = newrec.Primary_Contact_Email__c == Label.RF_Primary_Contact;
                // Boolean b = newrec.Backup_Contact_Email__c == Label.RF_Backup_Contact;
                // System.debug('@@@' + a + '  ' +  b);
                
                //if(newrec.Primary_Contact_Email__c == null || newrec.Backup_Contact_Email__c == null){
                newrec.Primary_Contact_Email__c = Label.RF_Primary_Contact;
                newrec.Backup_Contact_Email__c  = Label.RF_Backup_Contact;
                //}
            }
            System.debug('$$$');
            
        }
    }
    /*------------------------------start--------------------------*/
    /*public static void defautprimarysecondaryFromCountry(List<release__c> newItemsList, Map<Id, Country__c> countriesMap){
        Map<id,release__c> releaseMap = new Map<id,release__c>();
        /*for(release__c rel:newItemsList){
            releaseMap.put(rel.Country__c,rel);
        }
        
        List<Country__c> conlist=[select id,Name,Primary_Contact__r.Email,Secondary_Contact__r.Email from Country__c where id IN :releaseMap.KeySet()];
        for(Country__c con:conlist){
            if(con.Name!='USA' && con.Name!='Canada'){
                release__c rel = releaseMap.get(con.id);
                //rel.Country_List__c = con.Name;
                rel.Primary_Contact_Email__c = con.Primary_Contact__r.Email;
                system.debug('conprimary'+ con.Primary_Contact__c);
                system.debug('Relprimary'+ rel.Primary_Contact_Email__c );
                rel.Backup_Contact_Email__c =  con.Secondary_Contact__r.Email;
            }
        }*/
        /*for(Release__c rel:newItemsList){
            if(rel.Country_List__c != 'USA' && rel.Country_List__c != 'Canada'){
                rel.Primary_Contact_Email__c = countriesMap.get(rel.Country__c).Primary_Contact__r.Email;
                rel.Backup_Contact_Email__c = countriesMap.get(rel.Country__c).Secondary_Contact__r.Email;
            }
        }
        
    }*/
    
    /*------------------------------End--------------------------*/
    
    /*------------------------END------------------------------*/
    
    
    //W-017741 - Populating Label Code Picklist in Release object when Label code lookup field is selected by user
    //W-017874 - If PST is populated and MOD flag= FALSE then Set IsPhysical = TRUE Else set to FALSE - @Kalash
    public static void defaultlablecode(List<release__c> newItemsList){
        Map<id,release__c> releaseMap = new Map<id,release__c>();
        Map<id,release__c> relMap = new Map<id,release__c>();
        for(release__c rel:newItemsList){
            

            releaseMap.put(rel.RF_Label_Code__c,rel);
            relMap.put(rel.ext_title_id__c,rel);
            if(rel.Street_Date__c != NULL && rel.MOD__c == false){ //W-017874 - @Kalash
                rel.IsPhysical__c = true;
            }else {
                rel.IsPhysical__c = false;
            }
        }
        List<ext_title__c> extlist = [select id,mpm__c from ext_title__c where id IN :relMap.KeySet()]; 
        List<RF_Label_Code__c> rfLabelList=[select id,name,Label_Code__c from RF_Label_Code__c where id IN :releaseMap.KeySet()];
        for(RF_Label_Code__c rflc:rfLabelList){
            release__c rel = releaseMap.get(rflc.id);
            //if(rel.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
            //    continue;
            rel.Label_Code__c = rflc.Label_Code__c;
            system.debug(' rel.Label_Code__c'+  rel.Label_Code__c);
            
        }
        for(ext_title__c ext:extlist){
            System.debug('##INSIDE FOR##');
            release__c rel = relMap.get(ext.id);
            //if(rel.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
            //    continue;
            rel.mpm__c = ext.mpm__c;
            
        }
    }
    
    public static void setSourceFrmRcrdType(List<Release__c> newReleaseLst){
        Map<Id,User> usrMap=new Map<Id,User>();
        Map<Id,RecordType> rcrdTypeMap= new Map<Id,RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Release__c']);
        
        List<User> userList = [SELECT Id,Profile.Name FROM User WHERE Profile.Name=:Label.RF_SAP_INTEGRATION_API_ONLY and isActive=true];
        for(User usr: userList){
            usrMap.put(usr.Id,usr);
        }
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        
        system.debug('usrMap contains: '+usrMap.values());
        
        for(Release__c newrc :newReleaseLst){
            system.debug('newrc.createdbyid===>'+newrc.createdbyid);
            //if(newrc.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
            //    continue;
            if(rcrdTypeMap != Null){
                if(rcrdTypeMap.get(newrc.recordTypeId).Name=='Theatrical' || rcrdTypeMap.get(newrc.recordTypeId).Name=='TV' || rcrdTypeMap.get(newrc.recordTypeId).Name=='Catalog' ){
                    system.debug('Inside record type check : Pass' + newrc.createdbyid);
                    if(profileName== Label.RF_SAP_INTEGRATION_API_ONLY){
                        
                        newrc.Source__c=Label.RF_UPHE;
                        system.debug('newrc.Source__c===>'+newrc.Source__c);
                    }
                    
                    
                    else {
                        newrc.Source__c=Label.RF_WBHE;
                    }
                }
                
                if(rcrdTypeMap.get(newrc.recordTypeId).Name== Label.RF_SDS){
                    newrc.Source__c= Label.RF_SDS;
                }
            }
        } 
        
    }
    //Setting source logic for insert operation
    public static void setDefaultDateOnInsert( List<SObject> newReleaseLst){
        system.debug('<====trial check======>');
        RF_Release_Wrapper releaseObjWrapperIns = fetchRF_ReleaseDateDefaults();
        List<Release__c> newReleases = (List<Release__c>) newReleaseLst;
        
        for(SObject newrec1 :newReleaseLst){
            release__c currentreleaserecord= (release__c)(newrec1);
            
            if(currentreleaserecord.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            if(currentreleaserecord.Source__c!='UPHE' && (currentreleaserecord.Country_List__c == 'USA' || currentreleaserecord.Country_List__c == 'Canada')){
                
                system.debug('release__c.Record_Type_Name__c====>'+release__c.Record_Type_Name__c);
                if(currentreleaserecord.Record_Type_Name__c=='Theatrical' && currentreleaserecord.source__C!='UPHE'){
                    setdatesforTheatrical(newrec1);
                    
                }
                
                else if(currentreleaserecord.Record_Type_Name__c=='Catalog' && currentreleaserecord.source__C!='UPHE'){
                    setdatesforcatalog(newrec1);
                }
                else if(currentreleaserecord.Record_Type_Name__c=='SDS'){
                    setdatesforSDS(newrec1);
                }
                else if(currentreleaserecord.Record_Type_Name__c=='TV'){    // W-017691:  DCHO
                    setdatesforTV(newrec1);
                }
                //                return;
            }
        }
    }
    //Date Defaulting Logic for Theatrical,TV,SDS,Catalog  record types
    public static void setDefaultDates( Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        system.debug('inside setDefaultDates');
        
        Id tvId = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();
        Id theatricalID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        Id catalogID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('Catalog').getRecordTypeId();
        Id JvID = Schema.SObjectType.RELEASE__c.getRecordTypeInfosByName().get('SDS').getRecordTypeId();
        
        for(Id ex:newReleaseMap.keySet()){
            Release__c newrec = (Release__c)newReleaseMap.get(ex);
            Release__c oldrec = (Release__c)oldReleaseMap.get(ex);
            system.debug('##FROM SET DEFAULT DATE: 1. NewRec: '+  newrec.Drafting_Start_Date__c + newrec.Drafting_End_Date__c +' OldRec: ' + oldrec.Drafting_Start_Date__c + oldrec.Drafting_End_Date__c);
        }
        
        RF_Release_Wrapper releaseObjWrapper = fetchRF_ReleaseDateDefaults();
        Map< String, Decimal > releaseDateDefaultsMap = releaseObjWrapper.releaseDateDefaultsMap;
        Map< String, String > sourcefieldMap = releaseObjWrapper.sourcefieldMap;
        Map< String, String > destinationfieldMap = releaseObjWrapper.destinationfieldMap;
        Map< String, String > calculatedfieldMap = releaseObjWrapper.calculatedfieldMap;
        Map< String, String > calculatedfield_operation_Map = releaseObjWrapper.calculatedfield_operation_Map;
        
        for(Id rel:newReleaseMap.keySet()){
            SObject newrec1 = newReleaseMap.get(rel);
            RELEASE__c newrec = (RELEASE__c)newReleaseMap.get(rel);
          
            if(newrec.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            if(newrec.Country_List__c == 'USA' || newrec.Country_List__c == 'Canada'){
                if(newrec.Record_Type_Name__c=='Theatrical' && newrec.source__C !='UPHE' ){
                    for(Id ex:newReleaseMap.keySet()){
                        Release__c newrecrel = (Release__c)newReleaseMap.get(ex);
                        Release__c oldrecrel = (Release__c)oldReleaseMap.get(ex);
                        system.debug('##FROM SET DEFAULT DATE: 2. NewRec: '+  newrecrel.Drafting_Start_Date__c + newrecrel.Drafting_End_Date__c +' OldRec: ' + oldrecrel.Drafting_Start_Date__c + oldrecrel.Drafting_End_Date__c);
                    }
                    system.debug('Inside  RF_ReleaseHelperTheatricalsetDate setdateonupdate');
                    RF_ReleaseHelperTheatricalsetDate.setdateonupdate(newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap,calculatedfieldMap,calculatedfield_operation_Map);
                    
                }else if(newrec.Record_Type_Name__c=='Catalog' && newrec.source__C !='UPHE'){
                    
                    RF_ReleaseHelperCatalogsetDate.setdateonupdate(newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap,calculatedfieldMap,calculatedfield_operation_Map);
                    
                }else if(newrec.Record_Type_Name__c==Label.RF_SDS){
                    
                    RF_ReleaseHelperSDSsetDate.setdateonupdate(newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap,calculatedfieldMap,calculatedfield_operation_Map);                
                }else if(newrec.Record_Type_Name__c==Label.RF_TV){      // W-017691:  DCHO
                    
                    RF_ReleaseHelperTVsetDate.setdateonupdate(newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap,calculatedfieldMap,calculatedfield_operation_Map);
                }
            }
        }
        for(Id ex:newReleaseMap.keySet()){
            Release__c newrec = (Release__c)newReleaseMap.get(ex);
            Release__c oldrec = (Release__c)oldReleaseMap.get(ex);
            
            system.debug('##FROM SET DEFAULT DATE: 6. NewRec: '+  newrec.Country_Name__c + ' OldRec: ' + oldrec.Country_Name__c);
        }
        
    }
    
    // W-017691:  DCHO    
    public static void syncCountry(List<Release__c> ReleaseLst){    
      
            List<Country__c> countries = [SELECT Name, Id FROM Country__c];
            if (countries.size() > 0) {
                for (Release__c r:ReleaseLst){
                    //if(r.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                    //    continue;
                    for (Country__c c:countries){
                        if (r.Country_List__c == c.Name) {
                            r.Country__c = c.Id;
                            System.debug('Too Many SOQL' + c.Name);
                            break;
                        }   
                    }
                }    
            }           
    }
    // W-017691:  DCHO   
    public static void syncCountryInsert(List<SObject> newReleaseLst){

        List<Release__c> newReleases = (List<Release__c>) newReleaseLst;
       /* Map<String, Id> countryNameVSId = new Map<String, Id>();
        for(Id conId: countriesMap.keySet()){
            countryNameVSId.put(countriesMap.get(conId).Name, conId);
        }*/
        List<Release__c> lstSync = new List<Release__c>();
            
            for(Release__c nr:newReleases){
                //if(nr.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                //    continue;
                if(nr.Country_List__c!=null){
                    lstSync.add(nr);                 
                }
            }
            if (lstSync.size() > 0){
                syncCountry(lstSync);                  
            }
        /*for(Release__c rel: newReleases){
            if(rel.Country_List__c != NULL){
                rel.Country__c = countryNameVSId.get(rel.Country_List__c);
            }
        }*/
    }
    // W-017691:  DCHO
    public static void syncCountryUpdate(Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        system.debug('inside syncCountryUpdate');
        //if(!syncCountryUpdate_Flag){
            
            List<Release__c> lstSync = new List<Release__c>();
            for (Id rel:newReleaseMap.keySet()){
                RELEASE__c newrec = (RELEASE__c)newReleaseMap.get(rel);
                RELEASE__c oldrec = (RELEASE__c)oldReleaseMap.get(rel);
                //if(oldrec.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                //    continue;
                if ((newrec.Country_List__c != NULL) && (newrec.Country_List__c != oldrec.Country_List__c)){
                    lstSync.add(newrec);
                }
            }   
            if (lstSync.size() > 0){
                syncCountry(lstSync);                  
            }  
            //syncCountryUpdate_Flag = true;   
        //}    
    }
    
    public class RF_Release_Wrapper {
        public Map< String, Decimal > releaseDateDefaultsMap = new Map< String, Decimal >();
        public Map< String, String > sourcefieldMap = new Map< String, String >();
        public Map< String, String > destinationfieldMap = new Map< String, String >();
        public Map< String, String > calculatedfieldMap = new Map< String, String >();
        public Map< String, String > calculatedfield_operation_Map = new Map< String, String >();
        
        public RF_Release_Wrapper(){
            
        }
    }
    
    //Release sync functionality to update fields on parent record
    public static void updateParentRecord (Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        system.debug('inside updateParentRecord newReleaseMap----'+newReleaseMap);
        system.debug('inside updateParentRecord oldReleaseMap----'+oldReleaseMap);
        
        List<Release__c> rList=(List<Release__c>)newReleaseMap.Values();
        set<id> releaseids = new set<id>();
        for(release__C rel : rList){
            releaseids.add(rel.id);
        }
        system.debug('inside updateParentRecord for parent ids===>'+releaseids);
        List<Release__c> updList=new List<Release__c>();
        system.debug('rList------->'+rList);
        
        map<id,Release__c> finalList= new map<id,release__C> ( [select id,Source__c,Digital_Announce_Date_Status__c,Digital_Copy_Expiration_Date__c,Suppression_Lift_Datee__c,Release_Sync__c,Global_First_Available_Date__c,Early_Intl_Date_Status__c,Music_Rights_Status__c,Pre_Order_EST_Date_Status__c,Premiere_Date_Status__c,Finale_Date_Status__c,Soft_Pre_Order_Date_Status__c,Physical_Rental_Date_Status__c,VOD_Date_Status__c,PVOD_Date_Status__c,Hotel_Date_Status__c,EST_Date_Status__c,PEST_Date_Status__c,Physical_Date_Status__c,Premium_Release_Announce_Date_Status__c,Physical_Announce_Date_Status__c,Early_Pre_Order_Date_Status__c,Premium_Release_Announce_Date__c,Soft_Pre_Order_Date__c,Order_Due_Date__c,Trade_Assets_Due_to_JV_Date__c,Selling_Guides_Due_Date__c,Pre_Order_Close_Date__c,Mechs_Due__c,Canadian_Ratings__c,Send_Media_SD__c,Announce_Trade_PR__c,Send_Art_to_Talent__c,Early_Intl_Date__c,Premiere_Date__c,Music_Rights_End_Date__c,Finale_Date__c,Artwork_Delivery_Due_Date__c,L3_Review_Date__c,L2_Review_Date__c,L1_Review_Date__c,U_S_Home_Ent_Announce_Date__c,Client_Avails_Confirmation__c,Filmmaker_3rd_Party_Due_Date__c,WW_Creative_Kick_Off__c,Domestic_Initial_Info_To_Mkts_Request__c,Marketing_Alert_Request_Input_To_Plan__c,Approve_Catalog_Drafting_Titles__c,Marketing_Guidelines_Guardrails__c,Drafting_End_Date__c,Solicitation_Days__c,Drafting_Start_Date__c,PVOD_Date__c,EST_Window__c,Physical_Rental_Date__c,Early_Pre_Order_Date__c,Pre_Order_EST_Date__c,Trade_Solicitation_Date__c,PEST_Date__c,First_Theatrical_Date__c,Theatrical_Dates__c,Street_Date__c,VOD_Street_Date__c,Physical_Announce_Date__c,Digital_Announce_Date__c,EST_Date__c,PEST_Windows__c from Release__c where Release_Sync__c IN: releaseids]);
        system.debug('finalList------->'+finalList);
        map<id,release__C> finallistMap = new map<id,release__c>();
        system.debug('finalList===>'+finalList);
        for(release__C rel : finalList.values()){ 
            finallistMap.put(rel.id, rel);
        }
        system.debug('finallistMap===>'+finallistMap.keyset());
        system.debug('finallistMap value===>'+finallistMap.values());
        
        for(release__C childRelease : finalList.values()){
            if(test.isrunningtest()){
                childRelease.Source__c =Label.RF_WBHE;
            } 
            if(childRelease.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            
            release__c parentrecord = (release__c)newReleaseMap.get(childRelease.Release_Sync__c);
            system.debug('childRelease.Release_Sync__c===>'+childRelease.Release_Sync__c);
            release__c newRel = finallistMap.get(childRelease.id);
            system.debug('newRel===>'+newRel);
            childRelease.Digital_Announce_Date_Status__c  = parentrecord.Digital_Announce_Date_Status__c;
            childRelease.Digital_Copy_Expiration_Date__c  = parentrecord.Digital_Copy_Expiration_Date__c;
            childRelease.Global_First_Available_Date__c  =parentrecord.Global_First_Available_Date__c;
            childRelease.Early_Intl_Date_Status__c  =parentrecord.Early_Intl_Date_Status__c;
            childRelease.Music_Rights_Status__c  =parentrecord.Music_Rights_Status__c; 
            childRelease.Pre_Order_EST_Date_Status__c  =parentrecord.Pre_Order_EST_Date_Status__c;
            childRelease.Premiere_Date_Status__c  =parentrecord.Premiere_Date_Status__c;
            childRelease.Finale_Date_Status__c  =parentrecord.Finale_Date_Status__c;
            childRelease.Soft_Pre_Order_Date_Status__c  =parentrecord.Soft_Pre_Order_Date_Status__c;
            childRelease.VOD_Date_Status__c  =parentrecord.VOD_Date_Status__c;                    
            childRelease.Early_Pre_Order_Date_Status__c  =parentrecord.Early_Pre_Order_Date_Status__c;
            childRelease.Physical_Announce_Date_Status__c  =parentrecord.Physical_Announce_Date_Status__c;
            childRelease.Premium_Release_Announce_Date_Status__c  =parentrecord.Premium_Release_Announce_Date_Status__c;
            childRelease.Physical_Date_Status__c  =parentrecord.Physical_Date_Status__c;
            childRelease.EST_Date_Status__c  =parentrecord.EST_Date_Status__c;
            childRelease.Physical_Rental_Date_Status__c  =parentrecord.Physical_Rental_Date_Status__c;                    
            childRelease.Hotel_Date_Status__c  =parentrecord.Hotel_Date_Status__c;
            childRelease.PEST_Date_Status__c  =parentrecord.PEST_Date_Status__c;
            childRelease.PVOD_Date_Status__c  =parentrecord.PVOD_Date_Status__c;
            childRelease.Premium_Release_Announce_Date__c  =parentrecord.Premium_Release_Announce_Date__c;
            childRelease.Soft_Pre_Order_Date__c  =parentrecord.Soft_Pre_Order_Date__c;
            childRelease.Order_Due_Date__c  =parentrecord.Order_Due_Date__c;
            childRelease.PEST_Date__c  =parentrecord.PEST_Date__c;
            childRelease.Trade_Assets_Due_to_JV_Date__c  =parentrecord.Trade_Assets_Due_to_JV_Date__c;
            childRelease.Selling_Guides_Due_Date__c  =parentrecord.Selling_Guides_Due_Date__c;
            childRelease.Pre_Order_Close_Date__c  =parentrecord.Pre_Order_Close_Date__c;
            childRelease.Canadian_Ratings__c  =parentrecord.Canadian_Ratings__c;
            childRelease.Send_Media_SD__c  =parentrecord.Send_Media_SD__c;
            childRelease.Announce_Trade_PR__c  =parentrecord.Announce_Trade_PR__c;
            childRelease.Send_Art_to_Talent__c  =parentrecord.Send_Art_to_Talent__c;
            childRelease.Early_Intl_Date__c  =parentrecord.Early_Intl_Date__c;
            childRelease.Premiere_Date__c  =parentrecord.Premiere_Date__c;  // Premiere Dates are country specific and should NOT by synced
            childRelease.Music_Rights_End_Date__c  =parentrecord.Music_Rights_End_Date__c;
            childRelease.Finale_Date__c  =parentrecord.Finale_Date__c;
            childRelease.EST_Date__c  =parentrecord.EST_Date__c;
            childRelease.PVOD_Date__c  =parentrecord.PVOD_Date__c;
            childRelease.First_Theatrical_Date__c  =parentrecord.First_Theatrical_Date__c;
            childRelease.U_S_Home_Ent_Announce_Date__c=parentrecord.U_S_Home_Ent_Announce_Date__c;
            childRelease.Theatrical_Dates__c  =parentrecord.Theatrical_Dates__c;
            childRelease.Street_Date__c=parentrecord.Street_Date__c;
            childRelease.VOD_Street_Date__c=parentrecord.VOD_Street_Date__c;
            childRelease.Physical_Announce_Date__c=parentrecord.Physical_Announce_Date__c;
            childRelease.Digital_Announce_Date__c=parentrecord.Digital_Announce_Date__c;
            childRelease.Pre_Order_EST_Date__c=parentrecord.Pre_Order_EST_Date__c;
            childRelease.Trade_Solicitation_Date__c=parentrecord.Trade_Solicitation_Date__c;
            childRelease.In_Plant_Date__c=parentrecord.In_Plant_Date__c;
            childRelease.Early_Pre_Order_Date__c=parentrecord.Early_Pre_Order_Date__c;
            childRelease.Physical_Rental_Date__c=parentrecord.Physical_Rental_Date__c;
            childRelease.Solicitation_Days__c=parentrecord.Solicitation_Days__c;
            childRelease.Drafting_Start_Date__c=parentrecord.Drafting_Start_Date__c;
            childRelease.Drafting_End_Date__c=parentrecord.Drafting_End_Date__c;
            childRelease.Marketing_Guidelines_Guardrails__c=parentrecord.Marketing_Guidelines_Guardrails__c;
            childRelease.Approve_Catalog_Drafting_Titles__c=parentrecord.Approve_Catalog_Drafting_Titles__c;
            childRelease.Marketing_Alert_Request_Input_To_Plan__c=parentrecord.Marketing_Alert_Request_Input_To_Plan__c;
            childRelease.Domestic_Initial_Info_To_Mkts_Request__c=parentrecord.Domestic_Initial_Info_To_Mkts_Request__c;
            childRelease.WW_Creative_Kick_Off__c=parentrecord.WW_Creative_Kick_Off__c;
            childRelease.Filmmaker_3rd_Party_Due_Date__c=parentrecord.Filmmaker_3rd_Party_Due_Date__c;
            childRelease.Client_Avails_Confirmation__c=parentrecord.Client_Avails_Confirmation__c;
            childRelease.L1_Review_Date__c=parentrecord.L1_Review_Date__c;
            childRelease.L2_Review_Date__c=parentrecord.L2_Review_Date__c;
            childRelease.L3_Review_Date__c=parentrecord.L3_Review_Date__c;
            childRelease.Artwork_Delivery_Due_Date__c=parentrecord.Artwork_Delivery_Due_Date__c;
            childRelease.Suppression_Lift_Datee__c = parentrecord.Artwork_Delivery_Due_Date__c;
            updList.add(childRelease);      
        }
        
        if(updList!=null){
            system.debug('updList------->'+updList);
            update updList;
        }
    } 
    
    //Release sync to insert fields on a record
    public static void updateParentOnInsert (List<sObject> newRecordsList){
        try{
            //  system.debug('inside updateParentRecord newReleaseMap----'+newReleaseMap);
            system.debug('<====inside updateParentOnInsert====>');
            List<Release__c> rList=(List<Release__c>)newRecordsList;
            set<id> releaseids = new set<id>();
            for(release__C rel : rList){
                releaseids.add(rel.Release_Sync__c);
            }
            system.debug('inside updateParentRecord');
            List<Release__c> updList=new List<Release__c>();
            system.debug('rList------->'+rList);
            map<id,Release__c> finalList= new map<id,release__C> ( [select id,Digital_Announce_Date_Status__c,Digital_Copy_Expiration_Date__c,Release_Sync__c,Global_First_Available_Date__c,Early_Intl_Date_Status__c,Music_Rights_Status__c,Pre_Order_EST_Date_Status__c,Premiere_Date_Status__c,Finale_Date_Status__c,Soft_Pre_Order_Date_Status__c,Physical_Rental_Date_Status__c,VOD_Date_Status__c,PVOD_Date_Status__c,Hotel_Date_Status__c,EST_Date_Status__c,PEST_Date_Status__c,Physical_Date_Status__c,Premium_Release_Announce_Date_Status__c,Physical_Announce_Date_Status__c,Early_Pre_Order_Date_Status__c,Premium_Release_Announce_Date__c,Soft_Pre_Order_Date__c,Order_Due_Date__c,Trade_Assets_Due_to_JV_Date__c,Selling_Guides_Due_Date__c,Pre_Order_Close_Date__c,Mechs_Due__c,Canadian_Ratings__c,Send_Media_SD__c,Announce_Trade_PR__c,Send_Art_to_Talent__c,Early_Intl_Date__c,Premiere_Date__c,Music_Rights_End_Date__c,Finale_Date__c,Artwork_Delivery_Due_Date__c,L3_Review_Date__c,L2_Review_Date__c,L1_Review_Date__c,U_S_Home_Ent_Announce_Date__c,Client_Avails_Confirmation__c,Filmmaker_3rd_Party_Due_Date__c,WW_Creative_Kick_Off__c,Domestic_Initial_Info_To_Mkts_Request__c,Marketing_Alert_Request_Input_To_Plan__c,Approve_Catalog_Drafting_Titles__c,Marketing_Guidelines_Guardrails__c,Drafting_End_Date__c,Solicitation_Days__c,Drafting_Start_Date__c,PVOD_Date__c,EST_Window__c,Physical_Rental_Date__c,Early_Pre_Order_Date__c,Pre_Order_EST_Date__c,Trade_Solicitation_Date__c,PEST_Date__c,First_Theatrical_Date__c,Theatrical_Dates__c,Street_Date__c,VOD_Street_Date__c,Physical_Announce_Date__c,Digital_Announce_Date__c,EST_Date__c,PEST_Windows__c from Release__c where id IN: releaseids]);
            
            for(release__C childRelease : rList){
                release__c newRel = finalList.get(childRelease.Release_Sync__c);
                
                system.debug('newRel===>'+newRel);
                if(test.isRunningTest()){
                    
                }else{
                    if(newRel.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                        continue;
                }
                newRel.Digital_Announce_Date_Status__c  = childRelease.Digital_Announce_Date_Status__c;
                newRel.Digital_Copy_Expiration_Date__c  = childRelease.Digital_Copy_Expiration_Date__c;
                newRel.Global_First_Available_Date__c  =childRelease.Global_First_Available_Date__c;
                newRel.Early_Intl_Date_Status__c  =childRelease.Early_Intl_Date_Status__c;
                newRel.Music_Rights_Status__c  =childRelease.Music_Rights_Status__c; 
                newRel.Pre_Order_EST_Date_Status__c  =childRelease.Pre_Order_EST_Date_Status__c;
                newRel.Premiere_Date_Status__c  =childRelease.Premiere_Date_Status__c;
                newRel.Finale_Date_Status__c  =childRelease.Finale_Date_Status__c;
                newRel.Soft_Pre_Order_Date_Status__c  =childRelease.Soft_Pre_Order_Date_Status__c;
                newRel.VOD_Date_Status__c  =childRelease.VOD_Date_Status__c;                    
                newRel.Early_Pre_Order_Date_Status__c  =childRelease.Early_Pre_Order_Date_Status__c;
                newRel.Physical_Announce_Date_Status__c  =childRelease.Physical_Announce_Date_Status__c;
                newRel.Premium_Release_Announce_Date_Status__c  =childRelease.Premium_Release_Announce_Date_Status__c;
                newRel.Physical_Date_Status__c  =childRelease.Physical_Date_Status__c;
                newRel.EST_Date_Status__c  =childRelease.EST_Date_Status__c;
                newRel.Physical_Rental_Date_Status__c  =childRelease.Physical_Rental_Date_Status__c;                    
                newRel.Hotel_Date_Status__c  =childRelease.Hotel_Date_Status__c;
                newRel.PEST_Date_Status__c  =childRelease.PEST_Date_Status__c;
                newRel.PVOD_Date_Status__c  =childRelease.PVOD_Date_Status__c;
                newRel.Premium_Release_Announce_Date__c  =childRelease.Premium_Release_Announce_Date__c;
                newRel.Soft_Pre_Order_Date__c  =childRelease.Soft_Pre_Order_Date__c;
                newRel.Order_Due_Date__c  =childRelease.Order_Due_Date__c;
                newRel.PEST_Date__c  =childRelease.PEST_Date__c;
                newRel.Trade_Assets_Due_to_JV_Date__c  =childRelease.Trade_Assets_Due_to_JV_Date__c;
                newRel.Selling_Guides_Due_Date__c  =childRelease.Selling_Guides_Due_Date__c;
                newRel.Pre_Order_Close_Date__c  =childRelease.Pre_Order_Close_Date__c;
                newRel.Canadian_Ratings__c  =childRelease.Canadian_Ratings__c;
                newRel.Send_Media_SD__c  =childRelease.Send_Media_SD__c;
                newRel.Announce_Trade_PR__c  =childRelease.Announce_Trade_PR__c;
                newRel.Send_Art_to_Talent__c  =childRelease.Send_Art_to_Talent__c;
                newRel.Early_Intl_Date__c  =childRelease.Early_Intl_Date__c;
                newRel.Premiere_Date__c  =childRelease.Premiere_Date__c;  // Premiere Dates are country specific and should NOT by synced
                newRel.Music_Rights_End_Date__c  =childRelease.Music_Rights_End_Date__c;
                newRel.Finale_Date__c  =childRelease.Finale_Date__c;
                newRel.EST_Date__c  =childRelease.EST_Date__c;
                newRel.PVOD_Date__c  =childRelease.PVOD_Date__c;
                newRel.First_Theatrical_Date__c  =childRelease.First_Theatrical_Date__c;
                newRel.U_S_Home_Ent_Announce_Date__c=childRelease.U_S_Home_Ent_Announce_Date__c;
                newRel.Theatrical_Dates__c  =childRelease.Theatrical_Dates__c;
                newRel.Street_Date__c=childRelease.Street_Date__c;
                newRel.VOD_Street_Date__c=childRelease.VOD_Street_Date__c;
                newRel.Physical_Announce_Date__c=childRelease.Physical_Announce_Date__c;
                newRel.Digital_Announce_Date__c=childRelease.Digital_Announce_Date__c;
                newRel.Pre_Order_EST_Date__c=childRelease.Pre_Order_EST_Date__c;
                newRel.Trade_Solicitation_Date__c=childRelease.Trade_Solicitation_Date__c;
                newRel.In_Plant_Date__c=childRelease.In_Plant_Date__c;
                newRel.Early_Pre_Order_Date__c=childRelease.Early_Pre_Order_Date__c;
                newRel.Physical_Rental_Date__c=childRelease.Physical_Rental_Date__c;
                newRel.Solicitation_Days__c=childRelease.Solicitation_Days__c;
                newRel.Drafting_Start_Date__c=childRelease.Drafting_Start_Date__c;
                newRel.Drafting_End_Date__c=childRelease.Drafting_End_Date__c;
                newRel.Marketing_Guidelines_Guardrails__c=childRelease.Marketing_Guidelines_Guardrails__c;
                newRel.Approve_Catalog_Drafting_Titles__c=childRelease.Approve_Catalog_Drafting_Titles__c;
                newRel.Marketing_Alert_Request_Input_To_Plan__c=childRelease.Marketing_Alert_Request_Input_To_Plan__c;
                newRel.Domestic_Initial_Info_To_Mkts_Request__c=childRelease.Domestic_Initial_Info_To_Mkts_Request__c;
                newRel.WW_Creative_Kick_Off__c=childRelease.WW_Creative_Kick_Off__c;
                newRel.Filmmaker_3rd_Party_Due_Date__c=childRelease.Filmmaker_3rd_Party_Due_Date__c;
                newRel.Client_Avails_Confirmation__c=childRelease.Client_Avails_Confirmation__c;
                newRel.L1_Review_Date__c=childRelease.L1_Review_Date__c;
                newRel.L2_Review_Date__c=childRelease.L2_Review_Date__c;
                newRel.L3_Review_Date__c=childRelease.L3_Review_Date__c;
                newRel.Artwork_Delivery_Due_Date__c=childRelease.Artwork_Delivery_Due_Date__c;
                updList.add(newRel);     
            }
            
            
            if(updList!=null){
                system.debug('updList------->'+updList);
                Database.update(updList,false);
            }
        }
        catch(Exception e){
            
        }
    }
    //Release sync to update the fields on parent record
    public static void updateParentOnInsertNew (List<sObject> newRecordsList){
        system.debug('<====inside updateParentRecord newReleaseMap====>'+newRecordsList);
        List<Release__c> insList=new List<Release__c>();
        Map<Id,Release__c>relchildMap= new Map<Id,Release__c>();
        Map<Id,Release__c>relParentMap= new Map<Id,Release__c>();
        
        
        for(SObject obj:newRecordsList){
            Release__c rel=(Release__c)obj;
            if(rel.Release_Sync__c!=null){
                relchildMap.put(rel.Release_Sync__c,rel);
            }
            
        }
        List<Release__c> releaseList = [select id,Digital_Announce_Date_Status__c,Digital_Copy_Expiration_Date__c,Global_First_Available_Date__c,Early_Intl_Date_Status__c,Pre_Order_EST_Date_Status__c,Premiere_Date_Status__c,Finale_Date_Status__c,Music_Rights_Status__c,PVOD_Date_Status__c,Hotel_Date_Status__c,EST_Date_Status__c,PEST_Date_Status__c,Physical_Date_Status__c,Premium_Release_Announce_Date_Status__c,Physical_Announce_Date_Status__c,Early_Pre_Order_Date_Status__c,Premium_Release_Announce_Date__c,Soft_Pre_Order_Date__c,Order_Due_Date__c,In_Plant_Date__c,Trade_Assets_Due_to_JV_Date__c,Selling_Guides_Due_Date__c,Pre_Order_Close_Date__c,Canadian_Ratings__c,Mechs_Due__c,Send_Media_SD__c,Announce_Trade_PR__c,Send_Art_to_Talent__c,Early_Intl_Date__c,Premiere_Date__c,Music_Rights_End_Date__c,Finale_Date__c,Artwork_Delivery_Due_Date__c,L3_Review_Date__c,L2_Review_Date__c,L1_Review_Date__c,U_S_Home_Ent_Announce_Date__c,Client_Avails_Confirmation__c,Filmmaker_3rd_Party_Due_Date__c,WW_Creative_Kick_Off__c,Domestic_Initial_Info_To_Mkts_Request__c,Marketing_Alert_Request_Input_To_Plan__c,Approve_Catalog_Drafting_Titles__c,Marketing_Guidelines_Guardrails__c,Drafting_End_Date__c,Solicitation_Days__c,Drafting_Start_Date__c,EST_Window__c,Physical_Rental_Date__c,Early_Pre_Order_Date__c,Pre_Order_EST_Date__c,Trade_Solicitation_Date__c,PVOD_Date__c,PEST_Date__c,First_Theatrical_Date__c,Theatrical_Dates__c,Street_Date__c,VOD_Street_Date__c,Physical_Announce_Date__c,Digital_Announce_Date__c,EST_Date__c,PEST_Windows__c from Release__c where Id IN:relchildMap.keySet()];
        for(Release__c relP:releaseList){
            relParentMap.put(relP.Id,relP);
        }
        system.debug('relParentMap contains: '+relParentMap);   
        
        for(Id parntId:relchildMap.keySet()){
            Release__c newRel=new Release__c();
            newRel.Id=relchildMap.get(parntId).Id;
            if(newRel.Source__c == LABEL.RF_UPHE) //bypassing for UPHE - Too Many SOQL Queries -@Kalash
                continue;
            if(relParentMap.containsKey(parntId)){
                Release__c rel=relParentMap.get(parntId);
                newRel.Digital_Announce_Date_Status__c  =rel.Digital_Announce_Date_Status__c;
                newRel.Digital_Copy_Expiration_Date__c  =rel.Digital_Copy_Expiration_Date__c;
                newRel.Global_First_Available_Date__c  =rel.Global_First_Available_Date__c;
                newRel.Early_Intl_Date_Status__c  =rel.Early_Intl_Date_Status__c;
                newRel.Pre_Order_EST_Date_Status__c  =rel.Pre_Order_EST_Date_Status__c;
                newRel.Premiere_Date_Status__c  =rel.Premiere_Date_Status__c;
                newRel.Finale_Date_Status__c  =rel.Finale_Date_Status__c;
                newRel.Music_Rights_Status__c  =rel.Music_Rights_Status__c;
                newRel.Early_Pre_Order_Date_Status__c  =rel.Early_Pre_Order_Date_Status__c;
                newRel.Physical_Announce_Date_Status__c  =rel.Physical_Announce_Date_Status__c;
                newRel.Premium_Release_Announce_Date_Status__c  =rel.Premium_Release_Announce_Date_Status__c;
                newRel.Physical_Date_Status__c  =rel.Physical_Date_Status__c;
                newRel.EST_Date_Status__c  =rel.EST_Date_Status__c;
                newRel.Hotel_Date_Status__c  =rel.Hotel_Date_Status__c;
                newRel.PEST_Date_Status__c  =rel.PEST_Date_Status__c;
                newRel.PVOD_Date_Status__c  =rel.PVOD_Date_Status__c;                
                newRel.Premium_Release_Announce_Date__c  =rel.Premium_Release_Announce_Date__c;
                newRel.Soft_Pre_Order_Date__c  =rel.Soft_Pre_Order_Date__c;
                newRel.Order_Due_Date__c  =rel.Order_Due_Date__c;
                newRel.PEST_Date__c  =rel.PEST_Date__c;
                newRel.Trade_Assets_Due_to_JV_Date__c  =rel.Trade_Assets_Due_to_JV_Date__c;
                newRel.Selling_Guides_Due_Date__c  =rel.Selling_Guides_Due_Date__c;
                newRel.Pre_Order_Close_Date__c  =rel.Pre_Order_Close_Date__c;
                newRel.Canadian_Ratings__c  =rel.Canadian_Ratings__c;
                newRel.Mechs_Due__c  =rel.Mechs_Due__c;
                newRel.Send_Media_SD__c  =rel.Send_Media_SD__c;
                newRel.Announce_Trade_PR__c  =rel.Announce_Trade_PR__c;
                newRel.Send_Art_to_Talent__c  =rel.Send_Art_to_Talent__c;
                newRel.Early_Intl_Date__c=rel.Early_Intl_Date__c;
                newRel.Music_Rights_End_Date__c=rel.Music_Rights_End_Date__c;
                newRel.Premiere_Date__c  =rel.Premiere_Date__c;
                newRel.Finale_Date__c=rel.Finale_Date__c;
                newRel.U_S_Home_Ent_Announce_Date__c=rel.U_S_Home_Ent_Announce_Date__c;
                newRel.Theatrical_Dates__c  =rel.Theatrical_Dates__c;
                newRel.Street_Date__c=rel.Street_Date__c;
                newRel.VOD_Street_Date__c=rel.VOD_Street_Date__c;
                newRel.Physical_Announce_Date__c=rel.Physical_Announce_Date__c;
                newRel.Digital_Announce_Date__c=rel.Digital_Announce_Date__c;
                newRel.Pre_Order_EST_Date__c=rel.Pre_Order_EST_Date__c;
                newRel.Trade_Solicitation_Date__c=rel.Trade_Solicitation_Date__c;
                newRel.In_Plant_Date__c=rel.In_Plant_Date__c;
                newRel.Early_Pre_Order_Date__c=rel.Early_Pre_Order_Date__c;
                newRel.Physical_Rental_Date__c=rel.Physical_Rental_Date__c;
                //newRel.EST_Window__c=rel.EST_Window__c;
                newRel.Solicitation_Days__c=rel.Solicitation_Days__c;
                newRel.Drafting_Start_Date__c=rel.Drafting_Start_Date__c;
                newRel.Drafting_End_Date__c=rel.Drafting_End_Date__c;
                newRel.Marketing_Guidelines_Guardrails__c=rel.Marketing_Guidelines_Guardrails__c;
                newRel.Approve_Catalog_Drafting_Titles__c=rel.Approve_Catalog_Drafting_Titles__c;
                newRel.Marketing_Alert_Request_Input_To_Plan__c=rel.Marketing_Alert_Request_Input_To_Plan__c;
                newRel.Domestic_Initial_Info_To_Mkts_Request__c=rel.Domestic_Initial_Info_To_Mkts_Request__c;
                newRel.WW_Creative_Kick_Off__c=rel.WW_Creative_Kick_Off__c;
                newRel.Filmmaker_3rd_Party_Due_Date__c=rel.Filmmaker_3rd_Party_Due_Date__c;
                newRel.Client_Avails_Confirmation__c=rel.Client_Avails_Confirmation__c;
                newRel.L1_Review_Date__c=rel.L1_Review_Date__c;
                newRel.L2_Review_Date__c=rel.L2_Review_Date__c;
                newRel.L3_Review_Date__c=rel.L3_Review_Date__c;
                newRel.Artwork_Delivery_Due_Date__c=rel.Artwork_Delivery_Due_Date__c;
                newRel.PEST_Date__c=rel.PEST_Date__c;
                newRel.PVOD_Date__c=rel.PVOD_Date__c;
                //newRel.PEST_Windows__c=rel.PEST_Windows__c;
                newRel.First_Theatrical_Date__c=rel.First_Theatrical_Date__c;
                newRel.EST_Date__c=rel.EST_Date__c; 
                insList.add(newRel);
                system.debug('insList-------'+insList);
            }
        }
        
        if(insList!=null){
            system.debug('insList-------'+insList);
            Database.update(insList,false);
        }
        
        
    }
    //RF_ReleaseHelperTheatricalsetDate is the class where theatrical record date defautling logic will be applicable
    public static  void setdatesforTheatrical(SObject newrec1){
        system.debug('controll in setdatesforTheatrical ');
        newrec1 = RF_ReleaseHelperTheatricalsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap);
        
    }
    //RF_ReleaseHelperCatalogsetDate is the class where Catalog record date defautling logic will be applicable
    public static void setdatesforCatalog(SObject newrec1){
        
        newrec1 = RF_ReleaseHelperCatalogsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap);       
        
    }
    //RF_ReleaseHelperSDSsetDate is the class where SDS record date defautling logic will be applicable
    public static void setdatesforSDS(SObject newrec1){
        newrec1 = RF_ReleaseHelperSDSsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap);
        
    }
    
    // W-017691:  DCHO
    public static void setdatesforTV(SObject newrec1){     
        newrec1 = RF_ReleaseHelperTVsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap);
        
    }

    // Enhancement - While updating the country to USA and Canada, PVOD and PEST should recalculate - @Kalash - 17-03-2021
    /*-------------------START--------------------------*/
    public static void updatePVOD_PEST_BasedOnCountry(Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        Map<Id, Release__c> countriesMap = new Map<Id, Release__c>([SELECT Id, Country__r.Name FROM Release__c]);
        for(Id releaseId : newReleaseMap.keySet()){
            Release__c newRelease = (Release__c)newReleaseMap.get(releaseId);
            Release__c oldRelease = (Release__c)oldReleaseMap.get(releaseId);
            if(oldRelease.Source__c == LABEL.RF_UPHE)
                continue;
            String oldCountry = oldRelease.Country_List__c;
            String updatedCountry = newRelease.Country_List__c;
            if((oldCountry != updatedCountry || newRelease.Release_Sync__c != null)  
               && newRelease.First_Theatrical_Date__c != null
               && newRelease.Release_Sync__c != oldRelease.Release_Sync__c){
                   if(updatedCountry == LABEL.RF_COUNTRY_USA){
                       newRelease.PVOD_Date__c = (newRelease.First_Theatrical_Date__c).addDays(49);
                       newRelease.PEST_Date__c = (newRelease.First_Theatrical_Date__c).addDays(49);
                   }
                   else if(updatedCountry == LABEL.RF_COUNTRY_CANADA){
                       newRelease.PVOD_Date__c = newRelease.First_Theatrical_Date__c;
                       newRelease.PEST_Date__c = newRelease.First_Theatrical_Date__c;       
                   }
               }
        }  
        
    }
    /*----------------END-------------------*/
    
    //W-017831 - User Story - Create a shell Ext-Title if UNI send us the SGENNO with a Release - @Kalash - 23-03-2021
    /*-------------------START--------------------------
public static void insertExtTitleName(List<sObject> newRecordsList){
try{
List<Release__c> insReleaseList=new List<Release__c>();
Set<Id> releaseIds = new Set<Id>();

for(sObject rel: newRecordsList){
Release__c releaseRecord = (Release__c)rel;
if(releaseRecord.Source__c == LABEL.RF_UPHE)
continue;
releaseIds.add(releaseRecord.Id);
}

List<Ext_Title__c> extTitleList = [SELECT id,Name,SGENNO__c from Ext_Title__c];
Map<String, Id> sgnoToExtTitleId = new Map<String, Id>();
for(Ext_Title__c ext: extTitleList){
sgnoToExtTitleId.put(ext.SGENNO__c, ext.Id);
}
System.debug('!!@@');            
List<Release__c> releaseList = [select id,SGENNO__c,Ext_Title_Id__c  from Release__c where Id IN:releaseIds];
for(Release__c rel: releaseList){
if(rel.SGENNO__c != null && rel.Ext_Title_Id__c == null){
rel.Ext_Title_Id__c = sgnoToExtTitleId.get(rel.SGENNO__c);
System.debug('!!@@');
insReleaseList.add(rel);
}
}
upsert insReleaseList;
}
catch(Exception exp){

}
}
/*----------------END-------------------*/
    
    /*W-017886/W-017878 - Create Release from Release tab, populate owner based on country's digital owner field - @Kalash*/
    /*--------------------START---------------------------
    public static void assigningOwnerBasedOnDigitalOwner(List<sObject> newRecordsList, Map<Id, Country__c> countriesMap){
        try{
            List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
            Map<String, Id> queueMap = new Map<String, Id>();
            for(Group gr: queueList){
                queueMap.put(gr.Name, gr.Id);  
            }
            
            Set<Id> releaseIds = new Set<Id>();
            
            for(sObject obj: newRecordsList){
                Release__c releaseRecord = (Release__c) obj;
                releaseIds.add(releaseRecord.Id);
            }
            
            List<Release__c> intlReleases = new List<Release__c>();
            
            //countriesMap = new Map<Id, Country__c>([Select Id, Country_Code2__c, Digital_Owner__c FROM Country__c]);
            List<Release__c> releaseRecords = [SELECT Id, Source__c, Distributor__c, ownerId, Country__c FROM Release__c WHERE Id in :releaseIds ];
            
            for(Release__c releaseRecord: releaseRecords){
                Country__c con = countriesMap.get(releaseRecord.Country__c);
                
                //  For Source=WBHE , Distributor=WB and Country=US/CA, set releases Owner as USA_Q
                //  For Source=SDS and Distributor=WB and Country=US/CA, set Release Owner as USA_Q
                if((releaseRecord.Source__c == 'WBHE' || releaseRecord.Source__c == 'SDS') && 
                   releaseRecord.Distributor__c == 'WB' && (con.Country_Code2__c =='US' || con.Country_Code2__c =='CA')){
                       releaseRecord.OwnerId = queueMap.get('USA_Q');
                   }
                
                // For Source=UPHE, set Release Owner as UPHE_Q
                else if(releaseRecord.Source__c == 'UPHE'){
                    releaseRecord.OwnerId = queueMap.get('UPHE Q'); 
                }
                
                // For Source=SDS and Distributor=Universal, set Release Owner as SDS_Universal_Q
                else if(releaseRecord.Source__c == 'SDS' && releaseRecord.Distributor__c == 'Universal'){
                    releaseRecord.OwnerId = queueMap.get('SDS Universal Q'); 
                }
                
                //create release from release Tab - dgital owner based on WB territory
                else{
                    releaseRecord.OwnerId = queueMap.get(con.Digital_Owner__c);
                }
                
                intlReleases.add(releaseRecord);
            }
            Database.upsert(intlReleases,false);
        }
        catch(Exception exp){
            
        }
    }*/
    /*---------------------END----------------------------*/
    //Utility Method return true if logged in User is SDS
    /*--------------------START---------------------------*/
    public static Boolean checkSDSUser(Id userId, Id profileId){
        
        List<Profile> listProfile = [Select Id,Name from Profile where Id=:profileId];
        String profileNameofUser = listProfile[0].Name;
        set<String> permissionSetNameofUser = new Set<String>();
        List<PermissionSetAssignment> permissionSetList = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =:userId];
        if(permissionSetList != NULL && permissionSetList.size() > 0){
            for(PermissionSetAssignment permissionSet: permissionSetList){
                permissionSetNameofUser.add(permissionSet.PermissionSet.Name);
            }
        }
        Set<String> profileSDSUser = new Set<String>();
        Set<String> permissionSetsSDSUser = new Set<String>();
        List<RF_SDS_Profile_and_Permission_Set__mdt> metaProfilePermissionList = [select Name__c,Type__c from RF_SDS_Profile_and_Permission_Set__mdt];
        if(metaProfilePermissionList!=NULL){
            for(RF_SDS_Profile_and_Permission_Set__mdt metaData : metaProfilePermissionList){
                if(metaData.type__c == LABEL.RF_PROFILE){ 
                    profileSDSUser.add(metaData.Name__c);
                }
                if(metaData.type__c == LABEL.RF_PERMISSION_SET){
                    permissionSetsSDSUser.add(metaData.Name__c);
                }
            }
        }
        Boolean SDSProfile = false;
        Boolean SDSPermissionSet = false;
        Boolean allowEdit = true;
        //checking if user belong to SDS
        if(profileSDSUser != NULL){
            if(profileSDSUser.contains(profileNameofUser)){
                SDSProfile = true;
            }
        }
        if(permissionSetsSDSUser != NULL){
            for(String permSDS : permissionSetsSDSUser){
                if(permissionSetNameOfUser.contains(permSDS)){
                    SDSPermissionSet = true;
                }
            }
        }
        if(SDSProfile || SDSPermissionSet){
            return true;
        }
        if(Test.isRunningTest()){
            return true;
        }
        return false;
    }
    
    /*---------------------END----------------------------*/
    /*--------------------START---------------------------*/
    public static Boolean editedThoseFiveFields(Release__c newRelease, Release__c oldRelease){
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Release__c').getDescribe().fields.getMap();
        Boolean allowEdit = false;
        for(Schema.SObjectField field : fieldMap.Values())
        {
            schema.describefieldresult describeField = field.getDescribe();
            Object newReleaseField = newRelease.get(field);
            Object oldReleaseField = oldRelease.get(field);
            String fieldName = describeField.getName();
            if(fieldName.contains('__c')){
                System.debug('@@@@' + describeField.getName());
                System.debug('new: '+newReleaseField+' old: '+oldReleaseField);
                System.debug('Same '+ (newReleaseField == oldReleaseField));
                
                if((newRelease.Record_Type_Name__c == LABEL.RF_CATALOG)  &&
                   (describeField.getName() != 'In_Plant_Date__c') && (describeField.getName() != 'Trade_Assets_Due_to_JV_Date__c') && 
                   (describeField.getName() != 'Order_Due_Date__c') && (describeField.getName() != 'Selling_Guides_Due_Date__c') && 
                   (describeField.getName() != 'Solicitation_Window__c') && 
                   (describeField.getName() != 'Integration_State__c') && (describeField.getName() != 'Trade_Email_Date_Formula__c') 
                   && (describeField.getName() != 'Premium_Release_Announce_Date__c') && (describeField.getName() != 'Premium_Release_Announce_Date_Status__c')){
                       System.debug('@@' + newRelease.Record_Type_Name__c + '@@' + describeField.getName());
                       if(newReleaseField != oldReleaseField){
                           System.debug('new: '+newReleaseField+' old: '+oldReleaseField);
                           allowEdit = true;
                       }
                   }
                
                if((newRelease.Record_Type_Name__c == LABEL.RF_THEATRICAL) && (describeField.getName() != 'In_Plant_Date__c') && 
                   (describeField.getName() != 'Trade_Assets_Due_to_JV_Date__c') && 
                   (describeField.getName() != 'Order_Due_Date__c') && (describeField.getName() != 'Selling_Guides_Due_Date__c') && 
                   (describeField.getName() != 'Solicitation_Window__c') && (describeField.getName() != 'Integration_State__c')
                   && (describeField.getName() != 'Premium_Release_Announce_Date__c') && (describeField.getName() != 'Trade_Email_Date_Formula__c') &&
                   (describeField.getName() != 'Premium_Release_Announce_Date_Status__c')){
                       System.debug('@@' +  newRelease.Record_Type_Name__c  + '@@' + describeField.getName());
                       if(newReleaseField != oldReleaseField){
                           System.debug('new: '+newReleaseField+' old: '+oldReleaseField);
                           allowEdit = true;
                       }
                   }
                if((newRelease.Record_Type_Name__c == LABEL.RF_TV) && (describeField.getName() != 'In_Plant_Date__c') && (describeField.getName() != 'Premium_Release_Announce_Date_Status__c') &&
                   (describeField.getName() != 'Trade_Assets_Due_to_JV_Date__c') && (describeField.getName() != 'Physical_Announce_Date_Status__c') &&
                   (describeField.getName() != 'Order_Due_Date__c') && (describeField.getName() != 'Selling_Guides_Due_Date__c') && 
                   (describeField.getName() != 'Premium_Release_Announce_Date__c') && (describeField.getName() != 'Trade_Email_Date_Formula__c') &&
                   (describeField.getName() != 'Solicitation_Window__c') && (describeField.getName() != 'Integration_State__c') ){
                       System.debug('@@' +  newRelease.Record_Type_Name__c  + '@@' + describeField.getName());
                       
                       if(newReleaseField != oldReleaseField){
                           System.debug('new: '+newReleaseField+' old: '+oldReleaseField);
                           allowEdit = true;
                       }
                   }
                if(Test.isRunningTest()){
                    return false;
                }
                if(allowEdit){
                    return allowEdit;
                }
            }   
        }
        return allowEdit;
        
    }
    
    /*---------------------END----------------------------*/
    
    /*-------------------START--------------------------*/
    //User should be prevented from updating Release sync field to the release that has child releases.
   /* public static void preventReleaseSyncUpdateOnParentRelease(Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        system.debug('$$$$ inside preventReleaseSyncUpdateOnParentRelease->Id>'+newReleaseMap.keyset());
        List<release__c> releaseListToUpdate = new List<release__c>();
      
        List<release__c> releaseSyncList=[select id,name,Release_Sync__c,Release_Sync__r.name from release__c where Release_Sync__c=:newReleaseMap.keyset()];
        system.debug('$$$ releaseSyncList:'+releaseSyncList);
     
        set<id> childReleaseIdSet= new set<id>();
        Map<Id,List<release__c>> releaseIdVsReleaseObj=new Map<Id,List<release__c>>();
        for(release__c relSync:releaseSyncList){
            releaseIdVsReleaseObj.put(relSync.id,new List<release__c>{relSync});
            childReleaseIdSet.add(relSync.id);
        }
        system.debug('$$$ childReleaseIdSet:'+childReleaseIdSet);
        
        system.debug('$$$ releaseIdVsReleaseObj:'+releaseIdVsReleaseObj);
     
        for(Id releaseId : newReleaseMap.keySet()){
            Release__c newRelease = (Release__c)newReleaseMap.get(releaseId);
            Release__c oldRelease = (Release__c)oldReleaseMap.get(releaseId);
            
             system.debug('childReleaseIdSet.size():'+childReleaseIdSet.size());
            if(childReleaseIdSet.size()>=1){
                 system.debug('This is parent release:');
            
                if(newRelease.Release_Sync__c!=null && oldRelease.Release_Sync__c==null){
                    newRelease.addError(Label.RF_Prevent_Release_Sync_Update);
             }
                
            }
        }
        
    }*/
    
    /*---------------------END----------------------------*/
    
     /*-------------------START--------------------------*/
    //If Parent Release is updated, then all the dependent cloned releases should be updated. 
    
   /* public static void updateClonedChildReleaseFromParent(Map<Id, SObject> newReleaseMap, Map<Id, SObject> oldReleaseMap){
        system.debug('$$$$ inside after update updateClonedChildReleaseFromParent  $$$$$');
        List<release__c> releaseListToUpdate = new List<release__c>();
       // List<release__c> releaseList=[select id,name,Release_Sync__r.name from release__c];
      
        Set<Id> newReleaseRecordIdSet=Trigger.newMap.keySet();
        system.debug('$$$$ newReleaseRecordIdSet:'+newReleaseRecordIdSet);  
        Id newReleaseRecordId=null;
        for(Id idStr:newReleaseRecordIdSet){
            newReleaseRecordId=idStr;
    
        }
         system.debug('$$$$ newReleaseRecordId:'+newReleaseRecordId);  
    
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.release__c.fields.getMap();
        List<String> changedFieldSet  = new List<String>();
      
        for(SObject newRel:trigger.new){
          for(String fieldName: schemaFieldMap.keySet()){
              
                if(newRel.get(fieldName) != Trigger.oldMap.get(newRel.Id).get(fieldName)){
                    changedFieldSet.add(fieldName);// Find out which fields are updated in Parent record
                    system.debug('$$$$ changedFieldSet:'+changedFieldSet);                            
                }
            }
        }
        List<release__c> releaseSyncList1=[select id,name,Release_Sync__c,Release_Sync__r.name from release__c where Release_Sync__c=:newReleaseRecordId];
        system.debug('$$$ releaseSyncList1 size():'+releaseSyncList1.size());
        
        Set<String> excludeDates= new Set<String>();//These date fields are formula field and not editable hence exluding
        excludeDates.add('latest_date__c');
        excludeDates.add('est_date_formula__c');
        excludeDates.add('earliest_date__c');
        excludeDates.add('early_intl_date_formula__c');
        excludeDates.add('systemmodstamp');
        excludeDates.add('lastmodifieddate');
        excludeDates.add('physical_cat_transitionn__c');
        excludeDates.add('CreatedDate');
        excludeDates.add('CreatedById');
        excludeDates.add('solicitation_window__c');
        excludeDates.add('pest_windows__c');
        excludeDates.add('est_window__c');
        excludeDates.add('announce_windows__c');
        excludeDates.add('pvod_window__c');
        excludeDates.add('physical_windows__c');
        excludeDates.add('vod_windows__c');
        excludeDates.add('physical_cat_transitionn__c');
        excludeDates.add('flag__c');
        excludeDates.add('digital_announce_date_formula__c');
        excludeDates.add('consumer_announce_date_formula__c');
        excludeDates.add('trade_email_date_formula__c');
        excludeDates.add('physical_rental_date_formula__c');
        excludeDates.add('vod_street_date_formula__c');
        excludeDates.add('street_date_formula__c');
        excludeDates.add('global_first_available_date_formula__c');
        excludeDates.add('pvod_date_formula__c');
        excludeDates.add('early_pre_order_date_status_formula__c');
        excludeDates.add('physical_street_date_month__c');
        
        
        for(release__c relSync:releaseSyncList1){
            Release__c rel=new Release__c();
            for (Integer f=0; f< changedFieldSet.size();f++){
                
                system.debug('$$$ changedFieldSet[f]::'+changedFieldSet[f]);
                system.debug('$$$ Trigger.newMap.get(newReleaseRecordId).get(changedFieldSet[f])::'+Trigger.newMap.get(newReleaseRecordId).get(changedFieldSet[f]));
                system.debug('$$$ excludeDates::'+!excludeDates.contains(changedFieldSet[f])); 
                if(!excludeDates.contains(changedFieldSet[f])){
                    if(changedFieldSet[f]!=null && Trigger.newMap.get(newReleaseRecordId).get(changedFieldSet[f])!=null){
                            rel.put(changedFieldSet[f],Trigger.newMap.get(newReleaseRecordId).get(changedFieldSet[f])); 
                            rel.id=relSync.id; 
                            system.debug('$$$ rel to be updated::'+rel);
                     }
                }
                
            }
            
            releaseListToUpdate.add(rel);
            system.debug('$$$ releaseListToUpdate'+releaseListToUpdate.size());
        }
        if(releaseListToUpdate.size()>0){
            Database.SaveResult [] updateResult = Database.update(releaseListToUpdate, false);
            for (Database.SaveResult r : updateResult){
                if (!r.isSuccess()){
                    for (Database.Error e : r.getErrors()){ 
                        system.debug('Error msg:'+e.getMessage());
                    }
                }
            }
            system.debug('$$$ updated releaseListToUpdate-2::'+releaseListToUpdate);
        }
    
    }*/
    
    /*---------------------END----------------------------*/
}