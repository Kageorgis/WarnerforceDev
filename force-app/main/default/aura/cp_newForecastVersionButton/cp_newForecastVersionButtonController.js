({
    doInit: function(cmp) {
        var recordId = cmp.get("v.recordId");
        console.log('Id coming from Record:' + recordId)
        var action = cmp.get('c.createForecastVersion');
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this,function(result){
            var state = result.getState();
            if (state === "SUCCESS") {
                console.log('Success!')
                console.log('Record created with Id: '+ result.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'The new version has been created.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissable'
                });
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result.getReturnValue(),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
            else {
                console.log("Failed with state: " + state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Error occured while creating the version. Please check with the System Administrator.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissable'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})