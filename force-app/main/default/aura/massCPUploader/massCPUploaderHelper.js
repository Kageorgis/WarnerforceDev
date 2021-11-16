({
    createTable : function(component, event, valList) {

        //Create the table container
        var container = document.getElementById('handsOnTableDiv');
        console.log('container : ',container);

        //create an empty rowdata array
        var dataHandsOnTable = [];
        var minSpareRowCount = 1;
        //check for a defaultLicense... If we have one hide the first two columns and add default values
        if(valList.defaultLicensee){

               var hideColumn = [0];
            //    var tpl = [valList.defaultLicensee,valList.defaultCountry];
            dataHandsOnTable.push({'Licensee_Name':valList.defaultLicensee});

            minSpareRowCount = 0;
        }

        function isEmptyRow(instance, row) {
            var rowData = instance.countRows();

            for (var i = 0, ilen = rowData.length; i < ilen; i++) {
                if (rowData[i] !== null) {
                    return false;
                }
            }

            return true;
        }
        var handOnTableRef = new Handsontable(container, {
            data : dataHandsOnTable,
            colHeaders : [
				'* Licensee Name',
                '* Country',
                '* GTIN(UPC/ISBN)',
                '* MPN',
                '* Retailer',
                '* Retailer SKU(ASIN,Prime)',
                '* Licensed Property',
                '* Item Description',
              //  '* Category',
                '* Sub-Category',
                'Buyer Name',
                'RSP($)',
                'Gender',
                'Demo',
                '* Size',
                'Set Date',
                'Retired Date',
                'Product Status',
                'Flow-through',
                'Flow-through Start Date',
                'Flow-through End Date',
                'Promotional',
                'Promotional Start Date',
                'Promotional End Date',
                //'UPC',
                'Validation'
            ],
            columns : [
			    {data : 'Licensee_Name', type:'text', allowEmpty:false},
				{data : 'Country', type:'text', allowEmpty:false},
                {data : 'GTIN', type:'text', allowEmpty:false},
                {data : 'MPN', type:'text', allowEmpty:false},
                //{data : 'Retailer', type:'text', allowEmpty:false},
                {data : 'Retailer', type: 'dropdown', source:valList.retValues,
 						editor: 'select', selectOptions:valList.retValues,strict: true, allowEmpty:false},
                {data : 'Retailer_SKU', type:'text', allowEmpty:false},
                {data : 'Licensed_Property', type: 'dropdown', source: valList.propValues, editor: 'select', selectOptions:valList.propValues,
                    strict: true, allowEmpty:false},
                {data : 'Item_Description',type:'text',allowEmpty:false},

            //    {data : 'Category', type:'dropdown', source: valList.catValues,editor: 'select',selectOptions:valList.catValues, strict: true, allowEmpty:false},

                {data : 'Sub_Category', type:'dropdown', source: valList.subValues,editor: 'select',selectOptions:valList.subValues, strict: true, allowEmpty:false},
                {data : 'Buyer_Name', type:'text', allowEmpty:true},
                {data : 'RSP', type:'text', allowEmpty:true},
                {data : 'Gender', type:'dropdown', source: ['Boys','Girls','Men','Women','Unisex'],
                 		editor: 'select',selectOptions: ['Boys','Girls','Men','Women','Unisex'], strict: true, allowEmpty:true},                
                {data : 'Demo', type:'dropdown', source: ['0-2','3-5','6-8','9-12','12+','Superfan'],
                 		editor: 'select',selectOptions: ['0-2','3-5','6-8','9-12','12+','Superfan'], strict: true, allowEmpty:false},
                {data : 'Size',type:'text',allowEmpty:false},                
                {data : 'Set_Date',
                 		type:'date',
                 		dateFormat: 'M/D/YYYY',
                 		correctFormat: true,
                 		datePickerConfig: {
                        	firstDay: 0,
                        	showWeekNumber: true,
                        	numberOfMonths: 1,
                    	}
                },                
                {data : 'Retired_Date',
                 		type:'date',
                 		dateFormat: 'M/D/YYYY',
                 		correctFormat: true,
                 		datePickerConfig: {
                        	firstDay: 0,
                        	showWeekNumber: true,
                        	numberOfMonths: 1,
                    	}
                },           
                {data : 'Product_Status', type:'dropdown', source: ['New','Active','Sell-off','Inactive','Other'],
                 		editor: 'select',selectOptions: ['New','Active','Sell-off','Inactive','Other'], strict: true, allowEmpty:true},                
                {data : 'Flow_through_Flag', type:'dropdown', source: ['Yes','No'],
                 		editor: 'select',selectOptions: ['Yes','No'], strict: true, allowEmpty:true},                
                {data : 'Flow_through_Start_Date',
                 		type:'date',
                 		dateFormat: 'M/D/YYYY',
                 		correctFormat: true,
                 		datePickerConfig: {
                        	firstDay: 0,
                        	showWeekNumber: true,
                        	numberOfMonths: 1,
                    	}
                },                
                {data : 'Flow_through_End_Date',
                 		type:'date',
                 		dateFormat: 'M/D/YYYY',
                 		correctFormat: true,
                 		datePickerConfig: {
                        	firstDay: 0,
                        	showWeekNumber: true,
                        	numberOfMonths: 1,
                    	}
                },                
                {data : 'Promotional_Flag', type:'dropdown', source: ['Yes','No'],
                 		editor: 'select',selectOptions: ['Yes','No'], strict: true, allowEmpty:true},
                {data : 'Promotional_Start_Date',
                 		type:'date',
                 		dateFormat: 'M/D/YYYY',
                 		correctFormat: true,
                 		datePickerConfig: {
                        	firstDay: 0,
                        	showWeekNumber: true,
                        	numberOfMonths: 1,
                    	}
                },                
                {data : 'Promotional_End_Date',
                 		type:'date',
                 		dateFormat: 'M/D/YYYY',
                 		correctFormat: true,
                 		datePickerConfig: {
                        	firstDay: 0,
                        	showWeekNumber: true,
                        	numberOfMonths: 1,
                    	}
                },

               //{data : 'UPC',type:'text',allowEmpty:true}, 
               {data : 'Validation'}
            ],
            minSpareRows: minSpareRowCount,
            hiddenColumns: {
                columns: hideColumn,
                indicators: true
            },
            contextMenu : {
                items: {
                    "remove_row": {
                        name: 'Remove Row'
                    }
                }
            },            
            // added for Handsontable issue fix: Starts
            beforePaste: (data, coords) => {              
                data.forEach(function(value, index){
                    Object.keys(value).forEach(function(key) {                		
                        var temp =  value[key].trim();
                		value[key] = (temp).replace("\"",'');
                    });
                });
            },  
            cells: function(row, col, prop) {
                var cellProperties = {};
                cellProperties.renderer = function(instance, td, row, col, prop, value, cellProperties){
                    if(cellProperties.type == 'text'){

                        Handsontable.renderers.TextRenderer.apply(this, arguments);
                    }else if(cellProperties.type == 'numeric'){
                        Handsontable.renderers.NumericRenderer.apply(this, arguments);
                    }else if(cellProperties.type == 'dropdown'){
                        Handsontable.renderers.DropdownRenderer.apply(this, arguments);
                    }else if(cellProperties.type == 'date'){
                        Handsontable.renderers.DateRenderer.apply(this, arguments);
                    }                    
                    if(component.get('v.handsOnTableData')){
                        var realIndex = row;                         
                        var item = component.get('v.handsOnTableData')[cellProperties.row];
                        if(item){
                            if(item.isRowRemoved && item.isRowRemoved == true){
                                td.style.backgroundColor = 'grey';
                                td.style.color = 'white';
                                item.isRowModified = false;
                            }else if(item.errorOccured  && item.errorOccured == true){
                                td.style.backgroundColor = 'red';
                                td.style.color = 'white';
                            }else if(item.errorOccured == false && item.upcErrorOccured == true){
                                td.style.backgroundColor = 'yellow';
                                td.style.color = 'black';
                            }else if(item.errorOccured == false){
                                td.style.backgroundColor = 'green';
                                td.style.color = 'white';
                            }
                        }
                    }
                }
                return cellProperties;
            },

            afterChange : function (changes) {
                debugger;
                if (changes != null) {
                    console.log('changes===',changes);
                    changes.forEach(([row, prop, oldValue, newValue])=>{
                        console.log('Change: '+row + ' : '+prop + ' : '+oldValue + ' : '+newValue);
                        
                        var rowsData = component.get('v.handsOnTableData');
                        console.log('rowsData===',rowsData);
                        var rowRef = rowsData[row];
                        if(rowRef == null){
                            console.log('In Null');
                            var productRec = {'Licensee_Name':valList.defaultLicensee,'Country':newValue,'GTIN': newValue};
                            rowsData[row] = productRec;
                        } else{
                            console.log('In Not Null');
                            rowRef[prop] = newValue;
                            rowRef[prop] = newValue != "" && newValue != null ? newValue : null;
                            console.log(rowRef[prop]);
                        }  
                        console.log('test rowsData===',rowsData);
                	});
            	}
            },
            beforeRemoveRow: function(index, amount) {
            	var rowsData = component.get('v.handsOnTableData');    
                console.log('before remove : ',rowsData);    
            	for(var i=index;i<index+amount;i++) {
                    var item = rowsData[i];
                    item.isRowRemoved = true;
                    item.errorOccured = false;
                    item.validation = '';
                }
            	console.log('after remove : ',component.get('v.handsOnTableData'));    
                this.render();
                return false;
            },
            columnSorting: true, 
            copyPaste: {
            	columnsLimit: 100,
                rowsLimit: 2500
            },

            manualColumnResize: true    
		});
        console.log('dataHandsOnTable===',dataHandsOnTable);
		if(dataHandsOnTable.length < 1 || dataHandsOnTable == undefined){
            component.set('v.handsOnTableData',dataHandsOnTable);
		}
        component.set('v.handsOnTableRef',handOnTableRef);
	},
        
    buildTable: function (cmp, evt, cont) {

        var container = cont;
        console.log("Did we get the container? "+container);
    },

    saveNewTitles: function(cmp, evt, hlp) {

        var action = cmp.get("c.saveNewTitles");
        console.log('recordId===',cmp.get("v.recordId"));
        //console.log('Saving new titles: '+JSON.stringify(cmp.get("v.newtitles")));
        console.log('Saving new titles: ',cmp.get("v.newtitles"));
        action.setParams({
            newTitles : cmp.get("v.newtitles"),
            defaultAccountId : cmp.get("v.defaultAccountId"),
            recordId : cmp.get("v.recordId"),
        });
        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oneSuccess = false;
                var hot6 = cmp.get("v.handTableReference");
                console.log("hot6===",hot6);
                console.log("response.getReturnValue()===",response.getReturnValue());
                cmp.set("v.newtitles",response.getReturnValue());
                hot6.updateSettings({cells: function(row, col, prop) {
                        console.log('length===',cmp.get("v.newtitles").length);
                        var cellProperties = {};
                        cellProperties.renderer = function(instance, td, row, col, prop, value, cellProperties)
                        {	if(cellProperties.type == 'text'){
                            Handsontable.renderers.TextRenderer.apply(this, arguments);
                        }else if(cellProperties.type == 'numeric'){
                            Handsontable.renderers.NumericRenderer.apply(this, arguments);
                        }else if(cellProperties.type == 'dropdown'){
                            Handsontable.renderers.DropdownRenderer.apply(this, arguments);
                        }

                            if(cmp.get("v.newtitles")){
                                var realIndex = row;
                                var item = cmp.get("v.newtitles")[cellProperties.row];
                                console.log('script item===',item);
                                if(item){
                                    if(item.errorOccured  && item.errorOccured == true){
                                        td.style.backgroundColor = 'red';
                                        td.style.color = 'white';
                                    }
                                    else if(item.errorOccured == false){
                                        td.style.backgroundColor = 'green';
                                        td.style.color = 'white';
                                        oneSuccess = true;
                                    }
                                }
                            }
                        }
                        return cellProperties;
                    }});
                hot6.loadData(response.getReturnValue());

                var toastEvent = $A.get("e.force:showToast");
                if(oneSuccess){
                    toastEvent.setParams({
                        "type": "SUCCESS",
                        "title": "PRODUCTS WERE UPLOADED",
                        "message": 'Products Were Uploaded Successfully'
                    });
                } else {
                    toastEvent.setParams({
                        "type": "ERROR",
                        "title": "ERROR",
                        "message": 'Products Were not Uploaded Successfully'
                    });
                }
                toastEvent.fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
                console.log('INCOMPLETE');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "ERROR",
                            "title": "ERROR",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    sayHi: function(cmp, evt, hlp) {
        var action = cmp.get("c.sayHi");
        //console.log('Saving new titles: '+JSON.stringify(cmp.get("v.newtitles")));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned
                // from the server
                alert("From server: " + response.getReturnValue());

                // You would typically fire a event here to trigger
                // client-side notification that the server-side
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events,
        // which could trigger other events and
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);


    },

    getProductFields:function (cmp,evt) {
        var action = cmp.get("c.getEditableProductFields");


        //  action.setParams({ newTitles : cmp.get("v.newtitles") },{ defaultAccountId : cmp.get("v.defaultAccountId") });
        // Create a callback that is executed after
        // the server-side action returns
        action.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned
                // from the server
                //  alert(response.getReturnValue());
                var ids = response.getReturnValue();
                //console.log("Got Product Fields "+JSON.stringify(ids));
                cmp.set("v.headerFields",ids);
                // You would typically fire a event here to trigger
                // client-side notification that the server-side
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something

            }
            else if (state === "ERROR") {

                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");

                }
            }

        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events,
        // which could trigger other events and
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);

    },
        
	saveRecs : function(component, event, helper) {       
        var action = component.get("c.saveRecordsApexMethod");
        console.log('response.getReturnValue() pre : '+JSON.stringify(component.get("v.handsOnTableData")));
        action.setParams({
            productWrapperTableData : component.get("v.handsOnTableData")
        });
        console.log('action===',action);
        console.log('data===',component.get("v.handsOnTableData"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS"){
                console.log('SUCCESS');
                var handsOnTableRef = component.get('v.handsOnTableRef');
                console.log('response.getReturnValue() after : '+JSON.stringify(response.getReturnValue()));
                component.set('v.handsOnTableData',response.getReturnValue());
                handsOnTableRef.loadData(response.getReturnValue());
                var hasError = false;
                var returnList =response.getReturnValue(); 
                for(var i = 0; i < returnList.length; i++){
                    console.log('inside for');
                    console.log('returnList[i].errorOccured',returnList[i].errorOccured);
                    if(returnList[i].errorOccured == true){
                         console.log('inside if');
                        console.log('SUCCESS');
                        hasError = true;
                        break;
                    }
                }
                console.log('hasError ----------',hasError);
                console.log('response.getReturnValue()',response.getReturnValue());
                 console.log('response.getReturnValue()',response.getReturnValue().length);
                debugger;
                if(hasError){
                    toastEvent.setParams({
                        "type": "ERROR",
                        "title": "ERROR",
                        "message": "Please correct the records marked in Red."
                    });
                }
              //  console.log('response.getReturnValue() ----------',response.getReturnValue());
                    else if(hasError == false && response.getReturnValue().length <= 1){
                        toastEvent.setParams({
                        "type": "ERROR",
                        "title": "ERROR",
                        "message": "Please enter some data."
                    });
                    }
                else{
                	toastEvent.setParams({
                        "type": "SUCCESS",
                        "title": "Success!",
                      //   mode: 'pester',
                      	"message": 'All Records are Submitted Successfully.'
                    });    
                }  
                console.log('inside for');
                
                    
            }else if(state === 'ERROR'){
                console.log('ERROR');
                var errors = response.getError();
                console.log('errors===',errors);
                var toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: "+errors[0].message);
                        toastEvent.setParams({
                            "type": "ERROR",
                            "title": "ERROR",
                            "message": errors[0].message
                        //      "message": 'Please Enter some data'
                        });
                    }
                } else {
                    console.log("Unknown error");
                    toastEvent.setParams({
                        "type": "ERROR",
                        "title": "ERROR",
                        "message": 'Unknown error'
                    });
                }
            }
            console.log("toastEvent",JSON.stringify(toastEvent));
        	toastEvent.fire();
        });
        $A.enqueueAction(action);
    },


});