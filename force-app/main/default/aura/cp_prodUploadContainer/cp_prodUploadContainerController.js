/**
 * Created by XMMORENO on 5/21/2020.
 */

({
    doInit : function(component, event, helper) {
        var spinner = component.find("gridSpinner");
        if(component){
            $A.util.toggleClass(spinner, "slds-hide");
        }
        helper.getTemplates(component,event);
        helper.getValSets(component,event);
        helper.getFieldSet(component,event);
        $A.util.toggleClass(spinner, "slds-hide");
    }
});