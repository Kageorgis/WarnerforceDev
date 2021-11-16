/**
 * Created by XMMORENO on 3/16/2020.
 */

({
    navigateToMyComponent : function(component, event, helper) {
        var recId = component.get("v.recordId");
        console.log(recId);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:cp_accountRecordDetail",
            componentAttributes: {
                recordId : recId
            },
            isRedirect: true
        });
        evt.fire();
    }
});