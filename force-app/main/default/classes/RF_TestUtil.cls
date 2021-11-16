public class RF_TestUtil { 
   
    //creating releaseList 
    public static release__c releaseList(string name,Id mpmid){ 
        release__c rel = new release__c(Name=name,mpm__c=mpmid); 
        return rel; 
    } 
    // creating carslist 
    public static CAR__C Carslist(string name, string status){ 
        CAR__c carInst = new CAR__c(Name = name,Status__c = status); 
                return carInst; 
    } 
    // Creating Countrylist 
    public static country__c countryList(string name,string cntcode,string cntcode2){ 
        country__c cnt = new country__c(name=name,country_code__c=cntcode, country_code2__c=cntcode2); 
        return cnt; 
    } 
     // creating LanguageList 
    public static language__c languageList(string name,integer lngcode){ 
        language__c lng = new language__c(name=name,Language_Order__c=lngcode); 
        return lng; 
    } 
    
    //Creating Release 
    public static release__c createReleaseList(string name,Id mpmid,String countryName,Id recordTypeId){ 
        release__c rel = new release__c(Name=name,mpm__c=mpmid,Country_List__c=countryName,RecordTypeId=recordTypeId); 
        
        return rel; 
    } 
    // creating MPMlist 
    public static mpm__c mpmList(string mpmnumber){ 
        mpm__c mpm = new mpm__C(mpm_number__c=mpmnumber); 
        return mpm; 
    } 
    //Create Rights 
    public static Rights__c getRightsRecord(Id mpmId, Id recordTypeId, String country,  String channel){ 
        Rights__c rObj = new Rights__c(MPM__c=mpmId, 
                                       RecordTypeId = recordTypeId, 
                                       Status__c='Confirmed', 
                                       Rights_Group__c=country, 
                                       Channel__c=channel); 
        return rObj; 
    } 
    
}