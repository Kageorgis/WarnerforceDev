@isTest
private class WB_Sequence_Running_OrderTest {

    //Method to Create MPM Record
    private static MPM__c createMPMRecord(){
        MPM__c mpmRec = new MPM__c(
            Name = 'TestMPM',
            MPM_Number__c = '213446',
            Family_MPM_Number__c = '78900',
            MPM_Family_Desc__c = 'HARRY POTTER AND THE SORCERER STONE',
            MPM_Short_Desc__c = 'HARRY POTTER AND THE SORCERER STONE'
            );
        return mpmRec;
    }
        //Method to Create Title Record
    private static Title__c createTitleRecord(){
        Title__c TitleRec = new Title__c(
            Name = 'TestTitle',
            CurrencyIsoCode = 'USD',
            Video_Version__c = '6000023425',
            Digital_UPC__c = '123456789'
            );
        return TitleRec;
    } 
    //Method to create EC Tracker
    private static 	EC_Tracker__c createECTrackerRecord(MPM__c mpm, Title__c Title, String releaseType){
        Id recordTypeId = Schema.SObjectType.EC_Tracker__c.getRecordTypeInfosByName().get('Franchise Record Type').getRecordTypeId();
        EC_Tracker__c trackerRec = new EC_Tracker__c(
            Name= 'Harry Potter & The Sorcerers Stone',
            //CurrencyIsoCode = 'USD - U.S. Dollar',
            MPM__c = mpm.Id,
            Title__c = Title.Id,
            EC_UPC_Counter__c = 1,
            Release_Type__c = releaseType);
        return trackerRec;
    }
    //Method to create EC Pieces
    private static List<EC_Piece__c>  createLstECPieces(MPM__c mpm,EC_Tracker__c ecTracker,String strPlacement,Integer noOfRecs){
        List<EC_Piece__c> lstECPiece = new List<EC_Piece__c>();
        for(Integer i=0;i<noOfRecs;i++){
            lstECPiece.add(new 	EC_Piece__c (
                EC_Name__c = 'testECPiece' + i ,
                //CurrencyIsoCode = 'USD - U.S. Dollar',
                EC_Placement__c = strPlacement,
                MPM__c = mpm.Id,
                Min__c = 3,
                Sec__c = 3,
                EC_Type__c = 'Featurette',
                EC_Menu_Icon__c = 'Games',
                EC_Tracker__c = ecTracker.Id,
                EC_Status__c = 'Pending',
                Sequence__c = 1 + i 
            ));
        }
        return lstECPiece;
    }
	private static testMethod void PositiveTest() {
        MPM__c mpmRec = createMPMRecord();
        insert mpmRec;
        system.assertNotEquals(NULL, mpmRec);
       
        Title__c TitleRec = createTitleRecord();
        insert TitleRec;
        system.assertNotEquals(NULL, TitleRec);
        
        EC_Tracker__c ecTrackerRec =  createECTrackerRecord(mpmRec, TitleRec, 'Franchise - TV');
        insert ecTrackerRec;
        system.assertNotEquals(NULL, ecTrackerRec);
        
        List<EC_Piece__c> lstECPiecePreOrder = createLstECPieces(mpmRec,ecTrackerRec,'Pre-Order',5);
        insert lstECPiecePreOrder;
        List<EC_Piece__c> lstECPieceInSeasonTied = createLstECPieces(mpmRec,ecTrackerRec,'In Season - Tied',5);
        insert lstECPieceInSeasonTied;
        List<EC_Piece__c> lstECPieceInSeason = createLstECPieces(mpmRec,ecTrackerRec,'In Season',5);
        insert lstECPieceInSeason;
        List<EC_Piece__c> lstECPieceHiatus = createLstECPieces(mpmRec,ecTrackerRec,'Hiatus',5);
        insert lstECPieceHiatus;
        List<EC_Piece__c> lstECPiecePostSeason = createLstECPieces(mpmRec,ecTrackerRec,'Post Season',5);
        insert lstECPiecePostSeason;
        system.assertNotEquals(NULL, lstECPiecePostSeason);
        
        // start the test execution context
        Test.startTest();

        // set the test's page to your VF page (or pass in a PageReference)
        Test.setCurrentPage(Page.WB_Create_EC_Pieces);

        // call the constructor
        WB_Sequence_Running_Order controller = new WB_Sequence_Running_Order(new ApexPages.StandardController(ecTrackerRec));

        // test action methods on your controller and verify the output with assertions
        controller.updateSequence_Running_Order();

        // stop the test
        Test.stopTest();
	}

}