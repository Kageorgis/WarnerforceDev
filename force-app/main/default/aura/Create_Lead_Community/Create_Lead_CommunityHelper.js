({
    getOptions : function(component) {
        var action = component.get('c.getOptions');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                //if successful stores query results in ipRecordTypes
                var Options = response.getReturnValue();
                console.log('Options returned: ' +Options);                

                component.set('v.Options', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})