({
	init : function(component, event, helper) {
        var action = component.get("c.getVideoVersion");
        action.setParams({titleId : component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var videoVersion = response.getReturnValue();
                window.open("/lightning/r/Report/00OU0000002SFcNMAW/view?fv0="+videoVersion);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})