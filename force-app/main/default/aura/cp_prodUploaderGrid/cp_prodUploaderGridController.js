/**
 * Created by XMMORENO on 5/12/2020.
*/

({
    scriptsLoaded:function(cmp,evt,hlp){     
        var valueSets = cmp.get("v.valSets");
        var hideCol = false;
        if(valueSets[0].defaultLicensee){
            hideCol = true;
        }
        var rowNum = 0;
        var columnDefs = [
            
            {headerName: "", field: "select", valueGetter: "node.rowIndex + 1", checkboxSelection: true, maxWidth:75, lockPosition: true,
             pinned: 'left',
             lockPinned: true,
             cellClass: 'lock-pinned',
             editable:false,
             suppressSizeToFit:true,
             suppressCellSelection:true
            },
            {headerName: 'Validation', field: "Validation", width: 180, editable:false},
            {headerName: 'Licensee Name', field: "Licensee_Name", width: 140, hide:hideCol,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].licenseeValues}
            },
            {headerName: 'Country', field:'Country', width: 100,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].countryValues}
            },
            {headerName: 'GTIN (UPC/ISBN)', field: "GTIN", width: 140},
            {headerName: 'MPN', field: "MPN", width: 100},
            {headerName: 'MPN Description', field: "MPN_Description", width: 100},
            {headerName: 'Retailer', field: "Retailer", width: 100,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: { values: valueSets[0].retValues }
             
            },
            {headerName: 'Retailer SKU (ASIN,Prime)', field: "Retailer_SKU", width: 170},
            {headerName: 'Licensed Property', field: "Licensed_Property", width: 170,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].propValues}
            },
            {headerName: 'Item Description', field: "Item_Description", width: 170},
            {headerName: 'Sub-Category', field: "Sub_Category", width: 150,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].subValues}
            },
            {headerName: 'Buyer Name', field: "Buyer_Name", width: 150},
            {headerName: 'RSP($)', field: "RSP", width: 100},
            {headerName: 'Gender', field: "Gender", width: 100,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].genderValues}
            },
            {headerName: 'Demo', field: "Demo", width: 100,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].demoValues}
            },
            {headerName: 'Size', field: "Size", width: 100},
            {headerName: 'Set Date', field: "Set_Date", width: 100},
            {headerName: 'Retired Date', field: "Retired_Date", width: 120},
            {headerName: 'Product Status', field: "Product_Status", width: 120,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].prodValues}
            },
            {headerName: 'Flow-through', field: "Flow_through_Flag", width: 120,
             cellEditor: 'agSelectCellEditor',
             cellEditorParams: {values: valueSets[0].flowValues}
            },
            {headerName: 'Flow-through Start Date', field: "Flow_through_Start_Date", width: 180},
            {headerName: 'Flow-through End Date', field: "Flow_through_End_Date", width: 180},
            {headerName: 'Promotional', field: "Promotional_Flag", width: 120},
            {headerName: 'Promotional Start Date', field: "Promotional_Start_Date", width: 180},
            {headerName: 'Promotional End Date', field: "Promotional_End_Date", width: 180}
        ];
        var blankRow = {
            'Validation':"",
            'Licensee_Name':"",
            'Country':"",
            'GTIN':"",
            'MPN':"",
            'MPN Description':"",
            'Retailer':"",
            'Retailer SKU (ASIN,Prime)':"",
            'Licensed Property':"",
            'Item Description':"",
            'Sub-Category':"",
            'Buyer Name':"",
            'RSP ($)':"",
            'Gender':"",
            'Demo':"",
            'Size':"",
            'Set Date':"",
            'Retired Date':"",
            'Product Status':"",
            'Flow-Through':"",
            'FT Start Date':"",
            'FT End Date':"",
            'Promotional':"",
            'PM Start Date':"",
            'PM End Date':""
        }            
        var rowData = [blankRow];        
        // specify the data        
        // let the grid know which columns and what data to use
        var gridOptions = {
            columnDefs: columnDefs,
            defaultColDef: {
                width: 100,
                editable: true,
                resizable: true,
                headerCheckboxSelection: isFirstColumn,
                checkboxSelection: isFirstColumn,
                filter : true
                //menuTabs: ['generalMenuTab', 'columnsMenuTab']                
            },
            rowClassRules:{
                'row-errors':'data.errorOccured == true'
            },
            suppressRowClickSelection: true,
            rowSelection: 'multiple',
            enableRangeSelection: true,
            enableFillHandle: true,
            undoRedoCellEditing: true,
            undoRedoCellEditingLimit: 20,
            enableCellChangeFlash: true,
            rowData: rowData
        };        
        function isFirstColumn(params) {
            var displayedColumns = params.columnApi.getAllDisplayedColumns();
            var thisIsFirstColumn = displayedColumns[0] === params.column;
            return thisIsFirstColumn;
        };        
        // setup the grid after the page has finished loading   
        var gridDiv = document.querySelector('#myGrid');
        var gridRef =  new agGrid.Grid(gridDiv, gridOptions);
        cmp.set('v.gridRef',gridRef);
        cmp.set('v.blankRow',blankRow);
    },
    
    saveTable:function (cmp,evt,hlp) {
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        hlp.saveRecords(cmp,evt);
    },     
    
    handleBulkAction:function (cmp,evt,hlp) {
        var gridRef = cmp.get("v.gridRef");
        var gridData = cmp.get("v.gridData");
        var blankRow = {
            'Validation':"",
            'Licensee_Name':"",
            'Country':"",
            'GTIN':"",
            'MPN':"",
            'MPN Description':"",
            'Retailer':"",
            'Retailer SKU (ASIN,Prime)':"",
            'Licensed Property':"",
            'Item Description':"",
            'Sub-Category':"",
            'Buyer Name':"",
            'RSP ($)':"",
            'Gender':"",
            'Demo':"",
            'Size':"",
            'Set Date':"",
            'Retired Date':"",
            'Product Status':"",
            'Flow-Through':"",
            'FT Start Date':"",
            'FT End Date':"",
            'Promotional':"",
            'PM Start Date':"",
            'PM End Date':""
        }
        var rowData = [];
        var selectedRows = gridRef.gridOptions.api.getSelectedRows();
        var action = cmp.find('bulk').get('v.value');
        switch (action) {
            case 'Insert Row':
                rowData.push(blankRow);
                gridRef.gridOptions.api.applyTransaction({add:rowData});
                var rowCount = gridRef.gridOptions.api.getDisplayedRowCount();
                cmp.set("v.rowCount", rowCount);
                break;
            case 'Delete Selected':
                gridRef.gridOptions.api.applyTransaction({remove:selectedRows});
                var rowCount = gridRef.gridOptions.api.getDisplayedRowCount();
                cmp.set("v.rowCount", rowCount);
                break;
            case 'Update Selected':
                gridRef.gridOptions.api.applyTransaction({update:selectedRows});
                var rowCount = gridRef.gridOptions.api.getDisplayedRowCount();
                cmp.set("v.rowCount", rowCount);
                break;
            case 'Clear Grid':
                var rows = [cmp.get('v.blankRow')];
                gridRef.gridOptions.api.setRowData(rows);
                cmp.set("v.rowCount",0);
                break;
        }
    },
    
    copyLicensee : function(component, event, helper) {
        var textForCopy = component.get("v.selectedLookUpRecord").Name;
        helper.copyTextHelper(component,event,textForCopy);
    },
    
    copyProperty : function(component, event, helper) {
        var textForCopy = component.get("v.selectedPropertyRecord").Name;
        helper.copyTextHelper(component,event,textForCopy);
    },
    
    hideSpinner:function(cmp,evt){
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    downloadTemplate : function(component,event,helper){
        var docId = event.currentTarget.getAttribute("data-Id");
        var urlval = $A.get("$Label.c.WBCP_UPC_Collection_Template_Download_URL") + docId;
        if(component.get("v.valSets")[0].defaultLicensee){
            urlval = '/CP' + $A.get("$Label.c.WBCP_UPC_Collection_Template_Download_URL") + docId;
        }
        window.open(urlval, '_blank');
    },
    
    handleImport:function(component, event, helper) {
        let eventType = event.getParam("type");
        if(eventType === "SUCCESS"){
            var workbook = event.getParam("table");
            var firstSheetName = workbook.SheetNames[1];
            var worksheet = workbook.Sheets[firstSheetName];
            var columns = {
                'B': 'Licensee_Name',
                'C': 'Country',
                'D': 'GTIN',
                'E': 'MPN',
                'F': 'MPN_Description',
                'G': 'Retailer',
                'H': 'Retailer_SKU',
                'I': 'Licensed_Property',
                'J': 'Item_Description',
                'K': 'Sub_Category',
                'L': 'Buyer_Name',
                'M': 'RSP',
                'N': 'Gender',
                'O': 'Demo',
                'P': 'Size',
                'Q': 'Set_Date',
                'R': 'Retired_Date',
                'S': 'Product_Status',
                'T': 'Flow_through_Flag',
                'U': 'Flow_through_Start_Date',
                'V': 'Flow_through_End_Date',
                'W': 'Promotional_Flag',
                'X': 'Promotional_Start_Date',
                'Y': 'Promotional_End_Date'
            };
            var rowData = [];
            // start at the 2nd row - the first row are the headers
            var rowIndex = 8;
            // iterate over the worksheet pulling out the columns we're expecting
            while(worksheet['B' + rowIndex]){
                var row = {};
                Object.keys(columns).forEach(function(column){
                    row[columns[column]] = worksheet[column + rowIndex].w;
                });
                if(row[columns['B']]){
                    rowData.push(row);
                }
                rowIndex++;
            }
            helper.buildGrid(component,event,rowData);
        }
        if(eventType === "ERROR"){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type":"error",
                "message": "The file you uploaded is corrupt. Please download template."
            });
            toastEvent.fire();
        }
    }
});