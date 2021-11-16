/*******************************************************************************************************************************************
* File Name     :   WB_AutomateDigitalAllocation
* Description   :   Controller for WB_AutomateECAllocation page
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     2 March.2016      CTS                 ER-000227 : Created the class.
* 2.0                                           ER-000508 : Made the changes in the class so that it will create EC Account Allocation records for different Business Unit
* 3.0    31 March 2016      Prajakta            CH-01 : Commented line as for Season Pass, Int'l End card will be considered now onwards     
* 4.0    21 June 2016       Akash               CH-02 ER-542 : Automated Allocation for Worldwide EC pieces for TV
********************************************************************************************************************************************/


public class WB_AutomateDigitalAllocation
{
    Public String titleId;
    Public String mpmId{get; set;}
    Public String ecpieceId{get; set;}
    Public String bUnit;
    Public Integer errCount{get; set;}
    Public MPM__c mpmRecord = new MPM__c();
    
    List<EC_Account_Allocation__c> insertedAllocations { get; set; }
    Set<String> successIds = new Set<String>();
    
    //updated for ER-658 1/17/2017
    public WB_AutomateDigitalAllocation()
    {
        // Page parameters
        bUnit = ApexPages.currentPage().getParameters().get('bu');
        titleId = ApexPages.currentPage().getParameters().get('id');
        mpmId = ApexPages.currentPage().getParameters().get('mpmId');
        ecpieceId = ApexPages.currentPage().getParameters().get('ecpieceId');
        // List of all EC pieces, EC Account Allocations and Titles of Specific MPMs
		if(ecpieceId == NULL) {
			mpmRecord = [SELECT Id, name, 
							(SELECT Id, MPM__c FROM Titles__r WHERE Id =:titleId), 
							(SELECT Id, EC_Availability__c, International_End_Card__c,MPM__c, US_End_Card__c,EC_Status__c FROM EC_Pieces__r), 
							(SELECT Id, Account__c, EC_Piece__c, Format__c, MPM__c, Title__c FROM EC_Account_Allocations__r) 
						FROM MPM__c WHERE Id =: mpmId];
        
		}
		else {
			mpmRecord = [SELECT Id, name, 
						(SELECT Id, MPM__c FROM Titles__r WHERE Id =:titleId), 
						(SELECT Id, EC_Availability__c, International_End_Card__c,MPM__c, US_End_Card__c,EC_Status__c FROM EC_Pieces__r where Id =:ecpieceId), 
						(SELECT Id, Account__c, EC_Piece__c, Format__c, MPM__c, Title__c FROM EC_Account_Allocations__r) 
						FROM MPM__c WHERE Id =: mpmId];
		}
        
        errCount = 0;
        insertedAllocations = new List<EC_Account_Allocation__c>();
    }
    
    public void automateAllocation()
    {
        List<EC_Account_Allocation__c> finalAllocations = new List<EC_Account_Allocation__c>();
        
        // List of all the EC Digital Account Set Up records
        List<EC_Digital_Account_Set_Up__c> ECDigitalSetUpList = [SELECT Id, Account__c, Business_unit__c, EC_Availability__c, Format__c, 																International_End_Card__c,US_End_Card__c 
                                                                   FROM EC_Digital_Account_Set_Up__c];
                                                               
        if(ECDigitalSetUpList.size() > 0) {
            
            // Create map of strKey (BUnit+EC_Availability__c+International_End_Card__c) to List of EC Account Digital Set up
            map<String, List<EC_Digital_Account_Set_Up__c>> mapKeyTolstECDigitalSetUp = new map<String, List<EC_Digital_Account_Set_Up__c>>();
            
            for(EC_Digital_Account_Set_Up__c objSetUp : ECDigitalSetUpList) {
                
                String strKey;
                List<EC_Digital_Account_Set_Up__c> setUpList = new List<EC_Digital_Account_Set_Up__c>();
                //CH-02 Start
                if(objSetUp.Business_Unit__c == 'TV') {
                	if(objSetUp.International_End_Card__c!=null && objSetUp.US_End_Card__c!=null ){
                    	strKey = objSetUp.Business_Unit__c + objSetUp.EC_Availability__c + objSetUp.International_End_Card__c + objSetUp.US_End_Card__c;
                    }
                    else if(objSetUp.International_End_Card__c == null && objSetUp.US_End_Card__c!=null ){
                    	strKey = objSetUp.Business_Unit__c + objSetUp.EC_Availability__c + '_' + objSetUp.US_End_Card__c;
                    }
                    else if(objSetUp.International_End_Card__c != null && objSetUp.US_End_Card__c == null ){
                    	strKey = objSetUp.Business_Unit__c + objSetUp.EC_Availability__c + objSetUp.International_End_Card__c + '_';
                    }
                    else if(objSetUp.International_End_Card__c == null && objSetUp.US_End_Card__c == null ){
                    	strKey = objSetUp.Business_Unit__c + objSetUp.EC_Availability__c + '_' + '_';
                    }
                    if(mapKeyTolstECDigitalSetUp.containsKey(strKey)) {
                        setUpList = mapKeyTolstECDigitalSetUp.get(strKey);
                        setUpList.add(objSetUp);
                    } else {
                        setUpList.add(objSetUp);
                    }
                }
                //CH-02 End
               else if(objSetUp.Business_Unit__c != 'TV') {
                    strKey = objSetUp.Business_Unit__c;
                    if(mapKeyTolstECDigitalSetUp.containsKey(strKey)) {
                        setUpList = mapKeyTolstECDigitalSetUp.get(strKey);
                        setUpList.add(objSetUp);
                    } else {
                        setUpList.add(objSetUp);
                    }
                }
                mapKeyTolstECDigitalSetUp.put(strKey, setUpList);
            }
            
            if(bUnit != NULL && mpmRecord.EC_Pieces__r != NULL && mpmRecord.EC_Pieces__r.size() > 0) {
                // Check for all the EC piece records of that MPM
                for(EC_Piece__c objECPiece : mpmRecord.EC_Pieces__r) {
                    // Created key  //CH-02 Start
                    String strSetUp;
                    if(bUnit == 'TV') {
                        if(objECPiece.International_End_Card__c != null &&  objECPiece.US_End_Card__c != null )    // objECPiece.EC_Availability__c != 'Season pass' &&  /* Prajakta : CH-01 */
                            strSetUp = bUnit + objECPiece.EC_Availability__c + 'Yes' + 'Yes';
                        else if (objECPiece.International_End_Card__c != null &&  objECPiece.US_End_Card__c == null )     
                             strSetUp = bUnit + objECPiece.EC_Availability__c + 'Yes' + '_';
                        else if (objECPiece.International_End_Card__c == null &&  objECPiece.US_End_Card__c != null )     
                             strSetUp = bUnit + objECPiece.EC_Availability__c + '_' + 'Yes';
                        else if(objECPiece.International_End_Card__c == null &&  objECPiece.US_End_Card__c == null )
                            strSetUp = bUnit + objECPiece.EC_Availability__c + '_' + '_';
                    } 
                    else {
                        strSetUp = bUnit;
                    }
                     //CH-02 End
                    // Check if map contains above key
                    if(mapKeyTolstECDigitalSetUp.containsKey(strSetUp)) {
                        List<EC_Digital_Account_Set_Up__c> setUpList = mapKeyTolstECDigitalSetUp.get(strSetUp);
                        
                        // Checking for all the EC Setup records for the key
                        for(EC_Digital_Account_Set_Up__c objSetUp : setUpList) {
                            boolean duplicate = false;
                            
                           
                            // Check if duplicates EC Account Allocation records are already present
                            if(mpmRecord.EC_Account_Allocations__r != NULL && mpmRecord.EC_Account_Allocations__r.size()>0) {
                                for(EC_Account_Allocation__c eca : mpmRecord.EC_Account_Allocations__r) {
                                    if(eca.Account__c == objSetUp.Account__c && eca.EC_Piece__c == objECPiece.Id && eca.Title__c == titleId 
                                    && eca.Format__c == objSetUp.Format__c && eca.MPM__c == mpmId) {
                                        duplicate = true;
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.EC_Account_Allocation_Record_Already_Exists);
                                        ApexPages.addMessage(myMsg);
                                    }
                                }
                            }
                            // If Duplicates are not present then create EC Account Allocation records 
                            if(duplicate == false){
                                String createRecords='Yes';
                                /*if((objECPiece.EC_Availability__c == 'Season pass' && bUnit == 'TV')
                                || (objECPiece.EC_Availability__c == 'Free to Consumers' && bUnit == 'TV')
                                || (objECPiece.EC_Availability__c == 'Available To All' && bUnit == 'Kids'))*/
                                //|| (objECPiece.EC_Status__c == 'Final')) //Commented for SINC1336257
                                
                                if(bUnit =='TV'){
                                    if(objECPiece.EC_Availability__c != 'Season pass' && objECPiece.EC_Availability__c != 'Free to Consumers')
                                        createRecords='No';
                                }
                                else if(bUnit=='Kids' )
                                    if(objECPiece.EC_Availability__c != 'Available To All')
                                        createRecords='No';
                                
                                if(createRecords=='Yes')
                                { 
                                    EC_Account_Allocation__c ecaRecord = new EC_Account_Allocation__c();
                                    ecaRecord.EC_Piece__c = objECPiece.Id;
                                    ecaRecord.Account__c = objSetUp.Account__c;
                                    ecaRecord.MPM__c = objECPiece.MPM__c;
                                    ecaRecord.Format__c = objSetUp.Format__c;
                                    ecaRecord.Title__c = titleId;
                                    finalAllocations.add(ecaRecord);
                                }
                            }
                        }
                    }
                }
            }
        }       
        
        if(finalAllocations != NULL && finalAllocations.size()>0) {
            Database.SaveResult[] srList = Database.insert(finalAllocations, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess())
                    successIds.add(sr.getId());
                else
                    errCount = errCount + 1;
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Ec Account Allocation fields that affected this error: ' + err.getFields());
                    }
            }
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.No_EC_Account_Allocations);
            ApexPages.addMessage(myMsg);
        }
        
        // Made this variable true so that Method :WB_TriggerHandlerECPieces.UpdateSequence in UpdateMPMonECPiece trigger will not be executed
        // TestUtil.isRunning_WB_AutomateDigitalAllocation = true;
    }
    
    public List<EC_Account_Allocation__c> getInsertedAllocations() {
        if(successIds.size()>0 && successIds != NULL) {
            insertedAllocations = [SELECT Name, Account__c, EC_Name__c, EC_Piece__c, Format__c, MPM__c, Title__c FROM EC_Account_Allocation__c WHERE Id =: successIds];
            return insertedAllocations;
        } else {
            return NULL;
        }
    }
    
    public Integer getErrCount() {
        if(errCount != 0) {
            return errCount;
        } else {
            return NULL;
        }
    }
    //updated for ER-658 1/17/2017 
    public PageReference returnToMpm() {
        if(ecpieceId == NULL) {
            PageReference success = new PageReference('/'+mpmId);
            return success;
        }
        else{
            PageReference success = new PageReference('/'+ecpieceId);
            return success;
        }
    }
}