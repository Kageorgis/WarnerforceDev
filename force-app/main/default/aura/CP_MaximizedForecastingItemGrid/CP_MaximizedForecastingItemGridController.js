({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        component.set("v.recordId", recordId);
    },
    /*goBack : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        var currentId = component.get("v.recordId"); 
        navEvt.setParams({
            "recordId": currentId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }*/
})