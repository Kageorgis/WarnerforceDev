({
	doInit : function(component, event, helper) 
    {
        var mpm = component.get("v.mpmNum");
        var recordType = component.get("v.selectedRecordType");
        
        var action = component.get("c.createECTFromLighting");
        action.setParams({"mpmNumber" : mpm,"recordTypeVal" : recordType});        
        action.setCallback(this, function(response) {  
        var state = response.getState();
        
        if (state === "SUCCESS"){    
               var wrapIds = response.getReturnValue();
               component.set("v.wrapperData",wrapIds); 
               component.set("v.recordTypeId",wrapIds.recordtypeId); 
               component.set("v.mpmId",wrapIds.mpmId); 
               var recordTypeId = component.get("v.recordTypeId");
               var mpmId = component.get("v.mpmId");
                                  
               sforce.one.createRecord('EC_Tracker__c', recordTypeId,{'MPM__c':mpmId});                
    	   }
           else if (state === "INCOMPLETE") {                
                 console.log("INCOMPLETE--->>");
            }
           else if (state === "ERROR") {                
                var errors = response.getError();
                console.log("ERROR--->>"+errors);                
            }            
		});
		$A.enqueueAction(action);		
	}
})