({
    totalPageCalculation : function(component, event, length){
        var recordsPerPageVar = component.get("v.recordsPerPage");
        var remainder = length / recordsPerPageVar;
        var totalPagesCalculated = Number.isSafeInteger(remainder) ? remainder : Math.trunc(remainder) + 1;
        component.set("v.totalPages", totalPagesCalculated);
        var records = component.get("v.PaginationData");
        var recordList = [];
        var pageSize = component.get("v.recordsPerPage");
        var start = component.get("v.startPage");
        var end = component.get("v.endPage");
        var last = (parseInt(start)-1)+parseInt(pageSize);
        var first = parseInt(start)-1;
        for(var i=first; i < last; i++){
            if(records[i]){
                recordList.push(records[i]);
            }
            else
                continue;
        }
        component.set("v.filterData", recordList);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.spinner", false);
            }), 2000
        );
    },
    displayNextPrev :function(component, event, helper){
        var records = component.get("v.PaginationData");
        var recordList = [];
        var pageSize = component.get("v.recordsPerPage");
        var start = component.get("v.startPage");
        var end = component.get("v.endPage");
        var first = parseInt(start)-1;
        var last = parseInt(start-1)+parseInt(pageSize);
        for(var i=first; i < last; i++){
            if(records[i]){
                recordList.push(records[i]);
            }
            else
                continue;
        }
        component.set("v.filterData", recordList);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.spinner", false);
            }),500
        );
    },
    resetValues: function(component, event, helper){
        component.set("v.slNo", 1);
        component.set("v.startPage", 1);
        component.set("v.endPage", 10);
        component.set("v.totalPages", 0);
        component.set("v.currentPage", 1);
    },
})