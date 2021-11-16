({
	doInit : function(component, event, helper) 
    {
        var ECRecords = component.get("v.ECAllocationCount");
        var ECPieceId = component.get("v.ECPId");
        if (ECRecords > 0) {
            var confirm = window.confirm('Are you sure you want to delete all the records?');
            if(confirm){
                var action = component.get("c.deleteECAllocation");
                action.setParams({"ECPId1" : ECPieceId}); 
                action.setCallback(this, function(response) {  
                    var state = response.getState();
                    if (state === "SUCCESS"){  
                        var URLrn = '/lightning/r/EC_Piece__c/'+ECPieceId+'/view?fr=1';                            
                        window.open($A.get('$Label.c.WB_BaseURL')+URLrn,'_parent');                                                                                                                   
                    }                       
                });                    
                $A.enqueueAction(action);	   
            }else{                   
                sforce.one.navigateToSObject(ECPieceId,'related');                    
             }
        }else{
            alert('No records to delete');
            sforce.one.navigateToSObject(ECPieceId, 'related');  
        }      
	}
})