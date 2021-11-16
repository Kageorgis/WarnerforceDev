({ 
    downloadExportFile : function(component, event, helper) {
        event.getSource().set("v.disabled", true);
        var oppName = component.get("v.opptName");
        var fileName = oppName + "'s Products.csv";
        var resultList = component.get("v.fullData");
        if(resultList !== null && resultList !== '' && resultList !== undefined)
        {
            var csv = helper.convertArrayOfObjectsToCSV(component, resultList);
            if(csv === null){
                return;
            }
            var hiddenElement = document.createElement("a");
            hiddenElement.href = "data:text/csv;charset=utf-8,%EF%BB%BF" + encodeURIComponent(csv);
            hiddenElement.target = "_blank";
            hiddenElement.download = fileName;
            document.body.appendChild(hiddenElement);
            hiddenElement.click();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                type: 'success',
                "message": "Download Success."
            });
            toastEvent.fire();
        }
        event.getSource().set("v.disabled", false);
    }
})