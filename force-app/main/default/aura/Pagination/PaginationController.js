({
    doinit : function(component, event, helper) {
        var startPageVar = 0;
        var currentPageVar = 0;
        var endPageVar = 0;
        var pageSize = component.get("v.recordsPerPage");
        helper.resetValues(component, event, helper);
        if(component.get("v.startPage") > 1){
            startPageVar = component.get("v.startPage");
            component.set("v.startPage", startPageVar);
        }
        else{
            component.set("v.startPage", 1);
        }
        if(component.get("v.currentPage") > 1){
            currentPageVar = component.get("v.currentPage");
            component.set("v.currentPage", currentPageVar);
        }
        else{
            component.set("v.currentPage", 1);
        }
        if(component.get("v.endPage") > component.get("v.recordsPerPage")){
            endPageVar = component.get("v.endPage");
            component.set("v.endPage", endPageVar);
        }
        else{
            component.set("v.endPage", component.get("v.recordsPerPage"));
        }
        var leng = component.get("v.len");
        helper.totalPageCalculation(component, event, leng);
    },
    changeRecordsPerPage: function(component, event, helper){
        component.set("v.spinner", true);
        window.setTimeout(
            $A.getCallback(function() {
                $A.enqueueAction(component.get('c.continueProcessing'));
            }), 2000
        );
    },
    continueProcessing : function(component, event, helper){
        var selectedRecValue= component.find("selectItem").get("v.value");
        component.set("v.recordsPerPage", selectedRecValue);
        helper.resetValues(component, event, helper);
        $A.enqueueAction(component.get('c.doinit'));
    },
    next: function(component, event, helper){
        component.set("v.spinner", true);
        window.setTimeout(
            $A.getCallback(function() {
                $A.enqueueAction(component.get('c.continueNextProcessing'));
            }), 500
        );
    },
    continueNextProcessing : function(component, event, helper){
        var currentPageVar = component.get("v.currentPage");
        component.set("v.currentPage", currentPageVar+1);
        var totalPagesCalculated = component.get("v.totalPages");
        var Records = component.get("v.PaginationData");
        var pageSize = component.get("v.recordsPerPage");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var Paginationlist = [];
        var counter = 0;
        if(Records.length > 0){
            var recordPush = Records[0];
            for(var i=parseInt(end); i < parseInt(end)+parseInt(pageSize); i++){
                if(Records.length > i){
                    Paginationlist.push(recordPush[i]);
                }
                counter ++ ;
            }
            start = parseInt(start) + parseInt(counter);
            end = parseInt(end) + parseInt(counter);
            var oldv = component.get("v.slNo");
            var newv = oldv + parseInt(pageSize);
            component.set("v.slNo", newv);
            component.set("v.endPage", end);
            component.set("v.startPage", start);
            helper.displayNextPrev(component, event, helper);
        }
    },
    previous: function(component, event, helper){
        component.set("v.spinner", true);
        window.setTimeout(
            $A.getCallback(function() {
                $A.enqueueAction(component.get('c.continuePreviousProcessing'));
            }), 500
        );
    },
    continuePreviousProcessing: function(component, event, helper){
        var currentPageVar = component.get("v.currentPage");
        component.set("v.currentPage", currentPageVar-1);
        var totalPagesCalculated = component.get("v.totalPages");
        var Records = component.get("v.PaginationData");
        var Paginationlist = [];
        var counter = 0;
        var pageSize = component.get("v.recordsPerPage");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        if(Records.length > 0){
            var recordPush = Records[0];
            for(var i= parseInt(start)-parseInt(pageSize)-1; i < parseInt(start)-1 ; i++){
                if(i > -1){
                    Paginationlist.push(recordPush[i]);
                    counter ++
                }
                else{
                    start++;
                }
            }
            start = parseInt(start) - parseInt(counter);
            end = parseInt(end) - parseInt(counter);
            var oldv = component.get("v.slNo");
            var newv = oldv - parseInt(pageSize);
            component.set("v.slNo", newv);
            component.set("v.endPage", end);
            component.set("v.startPage", start);
            helper.displayNextPrev(component, event, helper);
        }
    }
})