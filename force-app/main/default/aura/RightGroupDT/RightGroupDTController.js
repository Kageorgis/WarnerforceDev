({
 doInit : function(component, event, helper) {
        var action = component.get("c.fetchRightGroup");
        var releaseRecordId = component.get("v.recordId");
        console.log('releaseRecordId:'+releaseRecordId);
        component.set('v.mycolumns', [
                {label: 'Release Name', fieldName: 'Release', type: 'text',wrapText: true,initialWidth: 160},
                {label: 'MPM', fieldName: 'MPM', type: 'text',wrapText: true ,initialWidth: 140},
                {label: 'MPM Description', fieldName: 'MPMDescription', type: 'text',wrapText: true,initialWidth: 160},
                {label: 'Rights Group', fieldName: 'RightGroup', type: 'text ',initialWidth: 140},
                {label: 'Channel', fieldName: 'Channel', type: 'text',initialWidth: 120},
                {label: 'Status', fieldName: 'Status', type: 'text',wrapText: true,initialWidth: 120},
                {label: 'Date Last Changed', fieldName: 'DateLastChanged', type: 'Date',initialWidth: 160},
                {label: 'Notes', fieldName: 'Notes', type: 'text ',wrapText: true,initialWidth: 140},
                {label: 'Right Start 1', fieldName: 'RightStart1', type: 'Date',initialWidth: 120},
                {label: 'Right End 1', fieldName: 'RightEnd1', type: 'Date',initialWidth: 120},
                {label: 'Right Start 2', fieldName: 'RightStart2', type: 'Date',initialWidth: 120},
                {label: 'Right End 2', fieldName: 'RightEnd2', type: 'Date ',initialWidth: 120},
                {label: 'Right Start 3', fieldName: 'RightStart3', type: 'Date',initialWidth: 120},
                {label: 'Right End 3', fieldName: 'RightEnd3', type: 'Date',initialWidth: 120},
                {label: 'Right Start 4', fieldName: 'RightStart4', type: 'Date',initialWidth: 120},
                {label: 'Right End 4', fieldName: 'RightEnd4', type: 'Date ',initialWidth: 120},
            	{label: 'Right Start 5', fieldName: 'RightStart5', type: 'Date',initialWidth: 120},
                {label: 'Right End 5', fieldName: 'RightEnd5', type: 'Date ',initialWidth: 120},
            	{label: 'Rights', fieldName: 'Rights', type: 'Date ',initialWidth: 120}
            ]);
        action.setParams({
          "releaseRecordId": releaseRecordId,
     });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {	
                component.set("v.dataTableList", response.getReturnValue());
                console.log('getReturnValue name:'+response.getReturnValue());
                if(response.getReturnValue()!=''){
               	var releaseName=response.getReturnValue()[0].Release;
                var today = new Date();
                var excelNameFormat=releaseName+ (today.getMonth() + 1) + "_" + today.getDate() + "_" + today.getFullYear()+".csv";
                component.set("v.fileName", excelNameFormat);
              }
           }
        });
        $A.enqueueAction(action);
 },
     downloadCsv : function(component, event, helper){
        var recordsList = component.get("v.dataTableList");

        // call the helper function which returns the CSV data as a String
        var csv = helper.convertListToCSV(component, recordsList);
        if (csv == null){
            return;
        }

        // Create a temporal <a> html tag to download the CSV file
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';
       hiddenElement.download = component.get("v.fileName");
        //hiddenElement.download='RightGroupExportData.csv';
        document.body.appendChild(hiddenElement); //Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})