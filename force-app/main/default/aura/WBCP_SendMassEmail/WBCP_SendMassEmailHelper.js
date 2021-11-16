({
    MAX_ATTACHMENT_LIMIT:25000000,
    CHUNK_SIZE: 2000000,
    FILE_COUNTER:0,
    
	redirectToListView : function(component, event) {
        var listviewID = component.get("v.listViewId");
        component.set("v.loaded", false);
		if (sforce && sforce.one) {
            sforce.one.navigateToList(listviewID, null,'Contact');
        }
	},
    
    setPills : function(component, event, listOfConEmailIds){
        console.log('listOfConEmailIds:::'+listOfConEmailIds)
        component.set("v.loaded", false);
        var listOfPills = [];
        var keys = [];
        for (var k in JSON.parse(listOfConEmailIds)) keys.push(k);
        console.log('keys:::',keys);
        var emails = keys;
        console.log('emails.length : ',emails);
        if(emails.length > 2){
            var label = '('+emails.length+' Recipients) '+component.get("v.listviewName");
            var pill = {
                type: 'icon',
                label: label,
                name: label,
                iconName: 'standard:contact',
                alternativeText: 'Contacts',
            }
            listOfPills.push(pill);
            component.set("v.emailBoxWidth","60%");
            component.set("v.pillBoxWidth","40%");
        }else if (emails.length > 0 && (!$A.util.isEmpty(emails[0]))){
            for(var i=0;i<emails.length;i++){
                var conName = emails[i].split("@")[0].replace('.',' ');
                console.log('listOfCons',conName);
                var pill = {
                    type: 'icon',
                    label: conName,
                    name: emails[i],
                    iconName: 'standard:contact',
                    alternativeText: 'Contacts',
                }
                listOfPills.push(pill);
            }
            var emailboxWidth = listOfPills.length == 1 ? "80%" : "60%";
            component.set("v.emailBoxWidth",emailboxWidth);
            component.set("v.pillBoxWidth","20%");
        }else{
            component.set("v.emailBoxWidth","100%");
            component.set("v.pillBoxWidth","0%");
        }
        component.set("v.emailPills", listOfPills);
        component.set("v.email",'');
        console.log("emails:::",emails);
        component.set("v.listOfEmails",emails);
        //component.set("v.listOfEmails",JSON.stringify(emails).replaceAll(',',';'));
        //console.log("v.listOfEmails:::",component.get("v.listOfEmails"));
    },
    
    sendHelper: function(component,event){
        component.set("v.loaded", true);
        var getEmail = component.get("v.email");
        var contactEmails = component.get("v.listOfEmails");
        var mapContactEmailId = component.get("v.mapContactEmailId");
        var mapContactEmailIdToSend = {};
      	if (!$A.util.isEmpty(getEmail)){
            contactEmails.push(...getEmail.split(';'));
            //contactEmails= contactEmails.concat(getEmail.split(';'));
            //contactEmails += (!$A.util.isEmpty(contactEmails) ? ';' : '')+getEmail;
        }
        if(contactEmails != null && contactEmails != ''){
            var mapContactEmailIdData = JSON.parse(mapContactEmailId);
            console.log('mapContactEmailIdData:::',mapContactEmailIdData);
            console.log('contactEmails:::',contactEmails);
            contactEmails.forEach(function(email){
                console.log('email:::',email);
                console.log('mapContactEmailIdData.email:::',mapContactEmailIdData[email]);
                if(mapContactEmailIdData[email] !== undefined && mapContactEmailIdData[email] !== ''){
                    mapContactEmailIdToSend[email] = mapContactEmailIdData[email];
                }else {
                    mapContactEmailIdToSend[email] = '';
                }
            });
            console.log('mapContactEmailIdToSend:::',mapContactEmailIdToSend);
        }
        var files = component.get("v.attachments");
        if(files.length > 0){
            console.log('test - ?',files.length);
            for(var i=0;i<files.length;i++){
                this.uploadHelper(component,event,files[i].file,mapContactEmailIdToSend);
            }
        }else{
            console.log('IN sendMail sendHelper else',mapContactEmailIdToSend);
            this.sendEmail(component,event,mapContactEmailIdToSend,[]);
        }
    },
    uploadHelper: function(component,event,file,mapContactEmailIdToSend) {
        var reader = new FileReader();
        var self = this;
        
        reader.onload =  $A.getCallback(function() {
            var fileContents = reader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component,event,file,fileContents,mapContactEmailIdToSend);
        });
        reader.readAsDataURL(file);
    },
    uploadProcess: function(component,event,file,fileContents,mapContactEmailIdToSend) {
        if(fileContents.length < 6000000){
            // set a default size or startpostiton as 0 
            var startPosition = 0;
            // calculate the end size or endPostion using Math.min() function which is return the min. value   
            var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
            // start with the initial chunk, and set the attachId(last parameter)is null in begin
            this.uploadInChunk(component,event,file,fileContents, startPosition, endPosition,mapContactEmailIdToSend,[]);
        }
    },
    
    uploadInChunk: function(component,event,file,fileContents,startPosition,endPosition,mapContactEmailIdToSend,attachId){
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.storetheAttachedFile");
        action.setParams({
            'fileName': file.name,
            'base64Data': encodeURIComponent(getchunk),
            'contentType': file.type,
            'mapContactEmailIdToSend': mapContactEmailIdToSend,
            'listFielIds': attachId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            attachId = response.getReturnValue();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component,event,file,fileContents,startPosition,endPosition,mapContactEmailIdToSend,attachId);
                }else {
                    var totalFiles = component.get("v.attachments").length;
                    this.FILE_COUNTER++;
                    if(totalFiles == this.FILE_COUNTER){
                        this.sendEmail(component,event,mapContactEmailIdToSend,attachId);
                    }
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: ",errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    sendEmail: function(component,event,mapContactEmailIdToSend,attachmentIds){
        console.log('IN sendMail sendEmail',mapContactEmailIdToSend);
        console.log('attachmentIds:::',attachmentIds);
        var emailTemp = component.get("v.emailTemp");
        var subject = component.get("v.subject");
        var emailBody = component.get("v.emailBody") ? component.get("v.emailBody") : ' ';
        var action = component.get("c.sendEmail");
        var attachIds = [];
        attachmentIds.forEach(function(attachId){
            attachIds.push(attachId);
        });
        console.log('attachIds:::',attachIds);
        action.setParams({
            'emailTempId': ((!$A.util.isEmpty(emailTemp)) ? emailTemp.Id : null),
            'subject':subject,
            'emailBody':emailBody,
            'mapContactEmailIdToSend': mapContactEmailIdToSend,
            'attachmentIds': attachIds
         });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	this.showToast(component,event);    
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: ",errors[0].message);
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component,event) {
        var toastParam = {"title": "Success!","message": "List email was queued.","type":"success"};
        if (sforce && sforce.one) {
        	sforce.one.showToast(toastParam);
            this.redirectToListView(component, event);
        }
    },
    
    getfileType: function(fileName,allFileTypes) {
        var temp = fileName.split(".");
        var fileType;
        if(temp.length > 0){
            fileType = temp[temp.length - 1].toLowerCase();
            switch (fileType.substring(0, 3)) {
              case 'xls':
                fileType = "excel";
                break;
              case 'doc':
                fileType = "word";
                break;
              case 'jpg':
                fileType = "image";
                break;
              case 'png':
                fileType = "image";
                break;
              case 'jpeg':
                fileType = "image";
                break;
            }
            var matchingFTs = allFileTypes.filter(record => (fileType.includes(record) || record == fileType));
        }
        console.log('---fileType----',matchingFTs);
        return (matchingFTs.length > 0 ? matchingFTs[0] : 'attachment');
    }
})