({
	getBrandContacts : function(component, event, helper) {
		var action = component.get("c.getBrandContacts");	
        var brandEngId = component.get('v.recordId');
        console.log('brandEngId',brandEngId);
        action.setParams({
            'brandEngId': brandEngId,
        });
        action.setCallback(this, function (response) {
            console.log('response.getReturnValue() : ',response.getReturnValue());
            var state = response.getState();
            component.set("v.isLoading",false);
            if (state === "SUCCESS") {
                var bcw = response.getReturnValue();
                if(bcw.BEStatus == 'Not Started' || bcw.BEStatus == 'In Progress'){
                    if(bcw.BCWList.length > 0){
                        component.set("v.brandContact", bcw.BCWList);    
                    }else{
                        if(bcw.bcFlag){
                            component.set("v.message","<span>No Brand Contacts are present under the Brand - <b>"+bcw.brandName+"</b>.<br/>Please add Brand Contacts to Brand First!</span>");
                        }else{
                            component.set("v.message",'All Brand Contacts are added as Attendees to this Engagement!!');
                        }
                    }
                }else{
                 	component.set("v.message","<span>Engagement is "+bcw.BEStatus+". Cannot add the Attendees at this Stage!!</span>");   
                }
            }else if (state === "INCOMPLETE") {
                system.debug('INCOMPLETE');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: ",errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})