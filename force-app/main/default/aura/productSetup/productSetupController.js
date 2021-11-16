({
	
    doInit: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    /*
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
	*/
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        //component.set("v.isOpen", false);
        //var recordId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        	//"url": "https://wbcp2-wbpartner.cs60.force.com/CP/s/"
             "url": "/"
        });
        urlEvent.fire();
    },
})