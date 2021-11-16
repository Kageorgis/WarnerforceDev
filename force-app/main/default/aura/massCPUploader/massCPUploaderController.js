(
    {
        loadTable:function(component, event, helper)
        {
            var action = component.get("c.getLookupValues");
// set param to method
// set a callBack
            action.setCallback(this, function(response) {
                //  $A.util.removeClass(component.find("mySpinner"), "slds-show");
                var state = response.getState();
                if (state === "SUCCESS") {
                    const storeResponse = response.getReturnValue();
                    // set searchResult list with return value from server.
                   // console.log('Ret Vals -->'+JSON.stringify(storeResponse));
                    helper.createTable(component,event,storeResponse);

                }
                else {

                }
            });
            $A.enqueueAction(action);
          //  helper.createTable(component, event, helper);

        },
        saveRecords:function(component, event, helper) {
            console.log('Saving');
            //var newtitles = cmp.get("v.newtitles");
            //console.log('New titles: '+JSON.stringify(newtitles));
            //hlp.saveNewTitles(cmp, evt, hlp);
            helper.saveRecs(component, event, helper);
            console.log('saveRecords End');
        },

        exportCSVFile: function (component, event, helper) {
            console.log('IN exportCSVFile');
            var csv = ['* Licensee Name',
                            '* Country',
                '"* GTIN (UPC/ISBN)"','* MPN',
                '* Retailer ,"*Retailer SKU(ASIN,Prime)"',
                '* Licensed Property','* Item Description',
                '* Sub-Category','Buyer Name',
                'RSP($)','Gender','Demo','* Size',
                'Set Date','Retired Date','Product Status',
                'Flow-Through','Flow-Through Start Date',
                'Flow-Through End Date','Promotional',
                'Promotional Start Date',
                'Promotional End Date']
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
            hiddenElement.target = '_self'; //
            hiddenElement.download = 'ProductTemplateFile.csv';  // CSV file Name* you can change it.[only name not .csv]
            hiddenElement.click(); // using click() js function to download csv file
        },

        logResource:function(cmp,evt,hlp) {
            /*  -- HAri
            //console.log('recordId===',cmp.get("v.recordId"));
            hlp.getProductFields(cmp,evt);
            var path = $A.get("$Resource.handsOnTable");
            var req = new XMLHttpRequest();
            req.open("GET", path);
            req.addEventListener("load", $A.getCallback(function() {
                console.log('Loaded');
            }));
            req.send(null);
            -- HAri */
        },
        
        handleTemplateDownload:function (cmp,evt,hlp) {
            var id = '0691b000000cKIQAA2';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://cs25.salesforce.com/sfc/servlet.shepherd/version/download/0681b000000RZN6AAO?operationContext=S1"
            });
            urlEvent.fire();
        },
      /* Hari commented back button function  */ 
        backToHome : function (component, event, helper) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
             // "url": "https://wbcp2-wbpartner.cs60.force.com/CP/s/" 
                
                "url": "/"
            });
            urlEvent.fire();
        } 
    });