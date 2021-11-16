({
	init : function(component, event, helper) {
		component.set("v.spinner", true);
        var myRef = component.get("v.pageReference");
        var myid = myRef.state.c__Id;
        var recordType = myRef.state.c__recordType;
        if(myid!==null){
            component.set("v.objectId", myid);
        }
        helper.getOpptDetails(component, event, helper);
	},
    reInit : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
        var a = component.get('c.init');
        $A.enqueueAction(a);
    },
    backToDeal : function(component, event, helper){
        helper.redirectToDeal(component, event, helper);
    },
    reloadPage : function(component, event, helper){
        window.location.reload();
    },
})