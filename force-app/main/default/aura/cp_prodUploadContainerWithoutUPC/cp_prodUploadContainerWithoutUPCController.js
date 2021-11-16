({
        doInit : function(component, event, helper) {  
        var spinner = component.find("gridSpinner");
        if(component){
            $A.util.toggleClass(spinner, "slds-hide");            
        }  
        helper.Refresh(component,event);     
        helper.getTemplates(component,event);
        helper.getValSets(component,event);
        helper.getFieldSet(component,event);
        $A.util.toggleClass(spinner, "slds-hide");
    }  
});