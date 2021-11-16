({
    doInit : function (cmp, event, helper) {
        var promotionId =  cmp.get("v.recordId");
        console.log('promotionId'+promotionId);
        var action = cmp.get("c.getRecord");
        action.setParams({
            'promotionId' : promotionId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Record retrived');
                cmp.set("v.promoObj",response.getReturnValue());
                if(response.getReturnValue().Status__c == 'Draft' || response.getReturnValue().Status__c == 'In Progress')
                    cmp.set("v.delButton",false);
                if(response.getReturnValue().Status__c == 'Draft' || response.getReturnValue().Status__c == 'In Progress')
                    cmp.set("v.valPromoButton",false);
                if(response.getReturnValue().Status__c == 'In Progress' || response.getReturnValue().Status__c == 'Committed')
                    cmp.set("v.commitButton",false);
                if(response.getReturnValue().Status__c == 'Committed')
                    cmp.set("v.cancelButton",false);
                cmp.set("v.valPromoButton",false);
                
                if(response.getReturnValue().Status__c == 'Cancelled')
                    cmp.set("v.valPromoButton",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    onValidate : function (cmp, event, helper) {
        var promotionId =  cmp.get("v.recordId");
        var toastEvent = $A.get("e.force:showToast");
        var action = cmp.get("c.getRecord");
        action.setParams({
            'promotionId' : promotionId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Record retrived');
                cmp.set("v.promoObj",response.getReturnValue());
                if(response.getReturnValue().Country__c != null && response.getReturnValue().Country__c != '' && response.getReturnValue().Account_Multipicklist__c != null && response.getReturnValue().Account_Multipicklist__c != '' )     
                {
                    //console.log('size===',response.getReturnValue().Promotion_Titles__r.length);
                    if(response.getReturnValue().Promotion_Titles__r != undefined && response.getReturnValue().Promotion_Titles__r.length != undefined && response.getReturnValue().Promotion_Titles__r.length > 0)
                    {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/apex/WB_ValidatePromotion?id="+promotionId            
                        });
                        urlEvent.fire();
                    }
                    else   
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Please add at least one title on Titles tab before validating the Promotion.",
                            "type":"Error"
                        });
                    }	
                } 
                else
                {
                    if(response.getReturnValue().Country__c != null && response.getReturnValue().Country__c != '')
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Please add at least one Account on Countries/Accounts tab before validating the Promotion.",
                            "type":"Error"
                        });
                    }
                    else
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Please add at least one Country and Account on Countries/Accounts tab before validating the Promotion.",
                            "type":"Error"
                        });
                    }
                }
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteRec : function (cmp, event, helper){
        var action = cmp.get("c.deleteRecord");
        action.setParams({
            'promotionRec' : cmp.get("v.promoObj")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Record Deleted');
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "Promotion__c"
                });
                homeEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },   
    
    onCommit : function (cmp, event, helper) {
        //var promotionRec = cmp.get("v.promoObj");
        var promotionId =  cmp.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        var toastEvent = $A.get("e.force:showToast");
        var action = cmp.get("c.getRecord");
        action.setParams({
            'promotionId' : promotionId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Record retrived');
                cmp.set("v.promoObj",response.getReturnValue());
                
                if(response.getReturnValue().Country__c != null && response.getReturnValue().Country__c != '' && response.getReturnValue().Account_Multipicklist__c != null && response.getReturnValue().Account_Multipicklist__c != '')     
                {
                    if(response.getReturnValue().Promotion_Titles__r != undefined && response.getReturnValue().Promotion_Titles__r.length != undefined && response.getReturnValue().Promotion_Titles__r.length > 0)
                    {
                        if(response.getReturnValue().Promotion_Title_Details__r != undefined && response.getReturnValue().Promotion_Title_Details__r.length != undefined && response.getReturnValue().Promotion_Title_Details__r.length > 0)
                        {
                            toastEvent.setParams({
                                "title": "Error",
                                "message": "Please fix all Validation errors prior committing the Promotion.",
                                "type":"Error"
                            });
                        }
                        else
                        {
                            urlEvent.setParams({
                                "url": "/apex/WB_CommitPromotion?id="+promotionId
                            });
                            urlEvent.fire();
                        } 
                    }
                    
                    else   
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Please add at least one title on Titles tab before validating the Promotion.",
                            "type":"Error"
                        });
                    } 
                }        
                else
                { 
                    if(response.getReturnValue().Country__c != null && response.getReturnValue().Country__c != '')
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Please add at least one Account on Countries/Accounts tab before validating the Promotion.",
                            "type":"Error"
                        });  
                    }    
                    
                    else
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Please add at least one Country and Account on Countries/Accounts tab before validating the Promotion.",
                            "type":"Error"
                        });
                    }
                }
                toastEvent.fire();
            } 
        });
        $A.enqueueAction(action);  
    },
    
    onCancel : function (cmp, event, helper) {
        var promotionRec = cmp.get("v.promoObj");
        promotionRec.Status__c = 'Cancelled';
        var action = cmp.get("c.updateRecord");
        action.setParams({
            'promo' : promotionRec
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Commit Record Updated');
                /*var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": promotionRec.Id
                });
                navEvt.fire();*/
                window.open('/lightning/r/Promotion__c/'+promotionRec.Id+'/view?fr=1','_self');
            }
        });
        $A.enqueueAction(action);
    },
})