({
	doInit: function(component,event,helper){
        var params = new Array();        
     	var action = component.get("c.getVideo");
        var file1 = component.get("v.FileName1");
        var file2 = component.get("v.FileName2");
        var file3 = component.get("v.FileName3");
        
        if(file1!=''){
            params.push(file1);
        }
        if(file2!=''){
            params.push(file2);
        }
        if(file3!=''){
            params.push(file3);
        }

        action.setParams({
            "videoIds": params 
        });
        
        action.setCallback(this, function(response){
           var state = response.getState();
            console.log(response.getError());
            if(state === "SUCCESS"){
                
                var urls = response.getReturnValue();
                console.log(urls);
                for (var item in urls){
                    if(file1!='' && item.includes(file1)){
                        component.set("v.url1",urls[item]);
                    }
                    if(file2!='' && item.includes(file2)){
                        component.set("v.url2",urls[item]);
                    }
                    if(file3!='' && item.includes(file3)){
                        component.set("v.url3",urls[item]);
                    }
                }                
                
            }else{
                console.log("Failed with state: "+ state)
                
            }
        });
        
        $A.enqueueAction(action);
    }
})