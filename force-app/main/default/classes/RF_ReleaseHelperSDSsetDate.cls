public class RF_ReleaseHelperSDSsetDate {
    Final static private String SourceApiNm = 'Source__C';
    Final static String ProjectypeApiNm = 'Project_Type__c';
    Final static private string NEW_RELEASE ='New Release';
    Final static private string CATALOG = 'Catalog';
    Final static private string TV='TV';  
    public static sObject setDefaultDateOnInsert(sObject newrec1, Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap){     
        if(newrec1.get(SourceApiNm)=='SDS'|| newrec1.get(SourceApiNm)=='WBHE'){
            if(newrec1.get(ProjectypeApiNm)==NEW_RELEASE){
                system.debug('Inside New release');
                newrec1 = RF_ReleaseHelperTheatricalsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap); 
            }else if(newrec1.get(ProjectypeApiNm)==CATALOG){
                newrec1 = RF_ReleaseHelperCatalogsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap);
            }else if(newrec1.get(ProjectypeApiNm)==TV){		// W-017691:  DCHO
            	newrec1 = RF_ReleaseHelperTVsetDate.setDefaultDateOnInsert(newrec1,releaseDefaultLabelMap);
            }   
        }

        return newrec1;    
    }
    public static void setdateonupdate(SObject newrec1,Map<Id, SObject> oldReleaseMap,Map< String, RF_Relase_Date_Config__mdt > releaseDefaultLabelMap,Map< String, String > destinationfieldMap,Map< String, Decimal > releaseDateDefaultsMap,Map< String, String > sourcefieldMap,Map< String, String > calculatedfieldMap,Map< String, String > calculatedfield_operation_Map){
        if(newrec1.get(SourceApiNm)=='SDS'|| newrec1.get(SourceApiNm)=='WBHE'){
            if(newrec1.get(ProjectypeApiNm)==NEW_RELEASE){
                RF_ReleaseHelperTheatricalsetDate.setdateonupdate( newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap, calculatedfieldMap, calculatedfield_operation_Map); 
            }else if(newrec1.get(ProjectypeApiNm)==CATALOG){
                RF_ReleaseHelperCatalogsetDate.setdateonupdate(newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap, calculatedfieldMap, calculatedfield_operation_Map);
            }else if(newrec1.get(ProjectypeApiNm)==TV){		// W-017691:  DCHO
                RF_ReleaseHelperTVsetDate.setdateonupdate(newrec1,oldReleaseMap,releaseDefaultLabelMap,destinationfieldMap,releaseDateDefaultsMap,sourcefieldMap,calculatedfieldMap,calculatedfield_operation_Map);
            }   
        }

        
        
    }
}