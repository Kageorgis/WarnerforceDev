({
    doInit: function(component, event, helper){
        helper.getOptions(component);
    },
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
     },
    
     closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
     },
    clickCreate: function(component, event, helper) {
        var validForm = component.find('formlead').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            console.log(validSoFar+'-'+inputCmp.get('v.validity').valid);
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log(validForm);

        if(validForm){
            var array = {
                "Company" : component.get("v.Company"),
                "LastName" : component.get("v.LastName"),
                "BrandName" : component.get("v.BrandName"),
                "Salutation" : component.get("v.Salutation"),
                "FirstName" : component.get("v.FirstName"),
                "phone" : component.get("v.phone"),
                "BrandCategory" : component.get("v.BrandCategory"),
                "Email" : component.get("v.Email"),
                "Title" : component.get("v.Title"),
                "TimingofIntegration" : component.get("v.TimingofIntegration"),
                "Budget" : component.get("v.Budget"),
                "KeyMessages" : component.get("v.KeyMessages"),
                "importantthings" : component.get("v.importantthings"),
                "DetailsofMarketing" : component.get("v.DetailsofMarketing"),
                "MainKPIs" : component.get("v.MainKPIs"),
                "PriorityElements" : component.get("v.PriorityElements")
            };

            var action = component.get("c.create");
            action.setParams({
                "params": JSON.stringify(array)
            });
            
            action.setCallback(this, function(response){
                console.log(response);
                var state = response.getState();                
                console.log(state);
                if(state === "SUCCESS"){
                    console.log(response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    if(response.getReturnValue() == 'Registered successfully'){
                        component.set("v.isModalOpen", false);
                        component.set("v.Company","");
                        component.set("v.LastName","");
                        component.set("v.BrandName","");
                        component.set("v.Salutation","");
                        component.set("v.FirstName","");
                        component.set("v.phone","");
                        component.set("v.BrandCategory","");
                        component.set("v.Email","");
                        component.set("v.Title","");
                        component.set("v.TimingofIntegration","");
                        component.set("v.Budget","");
                        component.set("v.KeyMessages","");
                        component.get("v.importantthings","");
                        component.get("v.DetailsofMarketing","");
                        component.get("v.MainKPIs","");
                        component.get("v.PriorityElements","");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": response.getReturnValue()
                        });
                    }else{
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": response.getReturnValue()
                        });
                    }
                    toastEvent.fire();
                }
                
            });
    
            $A.enqueueAction(action);
        }
    }
})