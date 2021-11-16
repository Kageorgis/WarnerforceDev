({
    convertArrayOfObjectsToCSV : function(component, arrayOfObjects) {
        component.set("v.spinner", true);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if(arrayOfObjects === null || !arrayOfObjects.length){
            return null;
        }
        columnDivider = ",";
        lineDivider =  "\n";
        var tablecol = component.get("v.columnName");
        var fieldNames = new Set();
        for(var i=0 ; i<tablecol.length;i++){
            if(!fieldNames.has(tablecol[i].fieldName)){
                fieldNames.add(tablecol[i].fieldName);
            }
        }
        var fieldArry = [];
        fieldNames.forEach(j => fieldArry.push(j));
        var columnNames = [];
        for(var i=0 ; i<tablecol.length;i++){
            columnNames.push(tablecol[i].label);
        }
        var columnArry = [];
        columnNames.forEach(j => columnArry.push(j));
        keys = fieldArry;
        csvStringResult = "";
        csvStringResult += columnArry;
        csvStringResult += lineDivider;
        for(var i=0; i < arrayOfObjects.length; i++){
            counter = 0;
            for(var sTempkey in keys){
                var skey = keys[sTempkey] ;
                var array = (skey).split(".");
                var second = array[1];
                if(counter > 0){
                    csvStringResult += columnDivider;
                }
                if(array.length > 1 && typeof arrayOfObjects[i][array[0]]==='object'){
                    var value = (arrayOfObjects[i][array[0]][array[1]]) === undefined || (arrayOfObjects[i][array[0]][array[1]]) === null ? '' : (arrayOfObjects[i][array[0]][array[1]]);
                    csvStringResult+='"'+value+'"';
                }
                else{
                    var value = arrayOfObjects[i][skey] === undefined || arrayOfObjects[i][skey] === null ? '' : arrayOfObjects[i][skey];
                    csvStringResult += '"'+ value +'"';
                }
                counter++;
            }
            csvStringResult += lineDivider;
        }
        component.set("v.spinner", false);
        return csvStringResult;
    }
})