({
	doInit : function(component, event, helper) {
        // Prepare the action to load account record
        var getDeal = component.get('c.getDeal');
        getDeal.setParams({'dealId': component.get('v.recordId')});

        // Configure response handler
        getDeal.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                component.set('v.deal', response.getReturnValue());
                var cloneDealFromRecord = component.get('c.cloneDealFromRecord');
                cloneDealFromRecord.setParams({
                    'dealIdToClone': component.get('v.recordId'),
                    'dealName': component.get('v.deal').Name
                });
                cloneDealFromRecord.setCallback(this, function(cloneResponse) {
                    var state = cloneResponse.getState();
                    if(state === 'SUCCESS') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Deal cloned",
                            message: "'"+component.get('v.deal').Name+"' has been successfully created",
                            type: "success"
                        });
                        toastEvent.fire();
                        var newDealEvent = $A.get('e.force:navigateToSObject');
                        newDealEvent.setParams({
                            "recordId": cloneResponse.getReturnValue()
                        });
                        newDealEvent.fire();
                    } else {
                        console.log('Problem cloning deal, response state: ' + state);
                    }
                });
                $A.enqueueAction(cloneDealFromRecord);
            } else {
                console.log('Problem getting deal, response state: ' + state);
            }
        });
        $A.enqueueAction(getDeal);
    }
    
})