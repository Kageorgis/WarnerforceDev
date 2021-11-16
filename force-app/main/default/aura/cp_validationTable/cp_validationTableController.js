({
    init: function(cmp, event, helper){
        cmp.set('v.columns', [
            {label: 'Row', fieldName: 'row', type: 'text', initialWidth: 40, hideDefaultActions:true},
            {label: 'Message', fieldName: 'message', type: 'text', hideDefaultActions:true, wrapText:true, clipText:false},
        ]);
        var fetchData = [{ row: "1", message: "Errors will appear here." }];
        cmp.set("v.data", fetchData);
    },
    
    handleProcessedEvt: function(cmp,evt,hlp){
        var errList = evt.getParam('errorList');
        var fetchData = [];
        for(var i = 0; i<errList.length; i++){ 
            if(errList[i].Validation.includes('missing: [Licensee')){
                fetchData.push({'row':JSON.stringify(i+1), 'message': errList[i].Licensee_Name +' was not found. Please check Spelling or use Licensee Lookup.'})
            }else if(errList[i].Validation.includes('WBCP Country')){
                fetchData.push({'row':JSON.stringify(i+1), 'message': errList[i].Country +' was not found. Please spell out the country(ie.United States)'})
            }else if(errList[i].Validation.includes('Retailer Description')){
                fetchData.push({'row':JSON.stringify(i+1), 'message': errList[i].Retailer +' was not found. Please check the spelling or pick from the dropdown.'})
            }else if(errList[i].Validation.includes('missing: [Licensed Property')){
                fetchData.push({'row':JSON.stringify(i+1), 'message': errList[i].Licensed_Property +' was not found. Please check Spelling or use Property Lookup.'})
            }else if(errList[i].Validation == 'Product created successfully, But UPC not present in starlab'){
            }
            else{
                fetchData.push({'row':JSON.stringify(i+1), 'message':errList[i].Validation})
            }
        }
        cmp.set("v.data", fetchData);
    }
});