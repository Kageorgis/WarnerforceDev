/*
Class Name -WB_Sequence_Running_Order
Description - This class maintain EC placement within the Content Playlist. EC pieces can be placed before the playlist, 
              after the playlist, in season, or within the playlist. 
              Each of the four values for EC placement will be grouped for the purposes of sequencing the Running Order field.
Created Date - 18-Oct-2016 
21-MAR-2017 - ER 967 - Dennis Cho - Modified logic such that EC Placement of "In Season - Tied" will be assigned Running Order number series (1, 2, 3...).  
EC Placement values of "Pre-Order", "In Season", "Hiatus", and "Post Season" will be grouped together and assigned Running Order number series (101, 102, 103...).
Same EC Asset will be assigned the same Running Order value.  Same EC Asset defined as EC Piece with same name but one piece has US End Card populated and
other piece has International End Card populated.
26-DEC-2018 - ER 1191 - Dennis Cho - Add new method to populate EC UPC-HD on EC Piece
*/


public class WB_Sequence_Running_Order {
    
    public Id ECTracker_Id {get;set;}
    public String franchiseRecordTypeId {get;set;}
    private ApexPages.StandardController standardController;
    
    public WB_Sequence_Running_Order(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        ECTracker_Id = standardController.getId();
        franchiseRecordTypeId = Schema.SObjectType.EC_Tracker__c.getRecordTypeInfosByName().get('Franchise Record Type').getRecordTypeId();
        
    }
    
    
    public void  updateSequence_Running_Order(){
        
        Map<String ,List<EC_Piece__c>> MapStringToEcPiece = new Map<String ,List<EC_Piece__c>>();
        List<EC_Piece__c> lstEcPiece = [SELECT Sequence__c,Running_Order__c,EC_Placement__c,Name, EC_Name__c, US_End_Card__c, International_End_Card__c from EC_Piece__c  
                                        where EC_Tracker__r.Id =: ECTracker_Id and
                                        Sequence__c != NULL and EC_Placement__c != ''
                                        order by Sequence__c,EC_Placement__c];
/* ER-1191 - New list for EC UPC */
        List<EC_Piece__c> lstEcPiece2 = [SELECT Sequence__c, EC_UPC_HD__c, EC_Placement__c,Name, EC_Name__c, US_End_Card__c, International_End_Card__c from EC_Piece__c  
                                        where EC_Tracker__r.Id =: ECTracker_Id and
                                        Sequence__c != NULL and EC_Placement__c != '' 
                                        order by Sequence__c];
		EC_Tracker__c Tracker = [SELECT Digital_UPC__c, EC_UPC_Counter__c from EC_Tracker__c where Id =: ECTracker_Id limit 1];

        if(lstEcPiece != NULL){
                        for(EC_Piece__c e:lstEcPiece){ 
                            			if(e.EC_Placement__c == 'In Season - Tied'){
                                            if(! MapStringToEcPiece.containsKey('In Season - Tied')){
                                                MapStringToEcPiece.put('In Season - Tied',new List<EC_Piece__c>());
                                            } 
                                        }                                                 
                            			if(e.EC_Placement__c != 'In Season - Tied'){
/* If EC Placement is "Pre Order", "In Season", "Hiatus", or "Post Season" then check if key for Post Season exists in Map.
If it does not exist, then add it.  */							
                                            if(! MapStringToEcPiece.containsKey('Post Season')){
                                                MapStringToEcPiece.put('Post Season',new List<EC_Piece__c>());
                                            } 
                                        }                 
                            			if (e.EC_Placement__c == 'In Season - Tied'){
                                            MapStringToEcPiece.get('In Season - Tied').add(e);
                                        } else {
                                            MapStringToEcPiece.get('Post Season').add(e);
                                        }
                        }
        }	

        lstEcPiece.clear();
        for(String Key: MapStringToEcPiece.keyset())
        {
                        updateRunningOrder(MapStringToEcPiece.get(key),key);                                                                      
                        lstEcPiece.addAll(MapStringToEcPiece.get(key));
        }
        if(lstEcPiece != null && lstEcPiece.size() > 0 )
            update lstEcPiece;
/* ER - 1191 - Call method to populate EC UPC */
        if(lstEcPiece2 != null && lstEcPiece2.size() > 0 && Tracker.Digital_UPC__c != NULL)
            {
             updateecupc(lstEcPiece2,Tracker);
	     	 update lstEcPiece2;
             update Tracker;
            }

     }    //End Of updateSequence_Running_Order()
    
     /* Function is used to update sequence in Running Order field for List of EC Pieces 
        with same EC Placement value*/
        
     void updateRunningOrder(List<EC_Piece__c> lstEcPiece, String key){
        Integer Running_Order;
        string p_ec_name = '';  // Previous EC Name
        string p_us_end_card = '';  // Previous US End Card
        string p_international_end_card = '';  // Previous International End Card
/* Set Running Order to start at 1 for "In Season - Tied".  Set start at 101 for "Pre Order", "In Season", "Hiatus", and "Post Season" */
        if(key == 'In Season - Tied')
        Running_Order = 1;
        else 
        Running_Order = 101;
        if(lstEcPiece.size() > 0) {
            for(EC_Piece__c Piece: lstEcPiece) {
                if (Running_Order == 1 || Running_Order == 101){
                	Piece.Running_Order__c = Running_Order;
                	Running_Order = Running_Order + 1;    
                } else{
                    if ((Piece.EC_Name__c == p_ec_name // Identify same EC piece and assign same Running Order value
                        && Piece.US_End_Card__c == NULL
                     	&& p_us_end_card != NULL
                        && Piece.International_End_Card__c != NULL
                     	&& p_international_end_card == NULL)  
                        || 
                        (Piece.EC_Name__c == p_ec_name
                        && Piece.US_End_Card__c != NULL
                     	&& p_us_end_card == NULL
                        && Piece.International_End_Card__c == NULL
                        && p_international_end_card != NULL))
                        Piece.Running_Order__c = Running_Order - 1;
                    else {
                    	Piece.Running_Order__c = Running_Order;
                        Running_Order = Running_Order + 1;
                    }
                }
                // Save previous values for EC Name, US End Card, and International End Card
                p_ec_name = Piece.EC_Name__c;
                p_us_end_card = Piece.US_End_Card__c;
                p_international_end_card = Piece.International_End_Card__c;
            }
     
        }
    }


     /* ER - 1191 - Function is used to update EC UPC for List of EC Pieces */
        
     void updateecupc(List<EC_Piece__c> lstEcPiece2, EC_Tracker__C Tracker){
        string p_ec_name = '';  // Previous EC Name
        string p_us_end_card = '';  // Previous US End Card
        string p_international_end_card = '';  // Previous International End Card
		string p_ecupc = '';  // Previous EC UPC
        if(lstEcPiece2.size() > 0) {
            for(EC_Piece__c Piece: lstEcPiece2) {
                if (p_ec_name == NULL && Piece.EC_UPC_HD__c == NULL){
                	Piece.EC_UPC_HD__c = Tracker.Digital_UPC__c + '_EC' + String.valueOf(Tracker.EC_UPC_Counter__c);
                	Tracker.EC_UPC_Counter__c = Tracker.EC_UPC_Counter__c + 1;    
                } else{if (p_ec_name != NULL && Piece.EC_UPC_HD__c == NULL){
                    if ((Piece.EC_Name__c == p_ec_name // Identify same EC piece and assign same EC UPC
                        && Piece.US_End_Card__c == NULL
                     	&& p_us_end_card != NULL
                        && Piece.International_End_Card__c != NULL
                     	&& p_international_end_card == NULL)  
                        || 
                        (Piece.EC_Name__c == p_ec_name
                        && Piece.US_End_Card__c != NULL
                     	&& p_us_end_card == NULL
                        && Piece.International_End_Card__c == NULL
                        && p_international_end_card != NULL))
                        Piece.EC_UPC_HD__c = p_ecupc;
                    else {
                    	Piece.EC_UPC_HD__c = Tracker.Digital_UPC__c + '_EC' + String.valueOf(Tracker.EC_UPC_Counter__c);
                		Tracker.EC_UPC_Counter__c = Tracker.EC_UPC_Counter__c + 1;
                    }}
                }
                // Save previous values for EC Name, US End Card, International End Card, and EC UPC
                p_ec_name = Piece.EC_Name__c;
                p_us_end_card = Piece.US_End_Card__c;
                p_international_end_card = Piece.International_End_Card__c;
				p_ecupc = Piece.EC_UPC_HD__c;
            }
        }
    }
}