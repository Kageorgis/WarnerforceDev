({
    onPageReferenceChange: function(component, event, helper) {
        helper.setPills(component, event,component.get("v.mapContactEmailId"));  
    },
    
    closeModal: function (component, event, helper) {
        component.set("v.showModal", false);
        helper.redirectToListView(component, event);
    },
    
    openmodal: function (component, event, helper) {
        component.set("v.showModal", true);
    },
    
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function (component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.emailbody", null);
        component.set("v.showModal", false);
        helper.redirectToListView(component, event);
    },
    
    sendMail: function (component, event, helper) {
        console.log('IN sendMail');
        var subject = component.get("v.subject");
        var contactEmails = component.get("v.listOfEmails");
        var getEmail = component.get("v.email");
        if($A.util.isEmpty(contactEmails) && $A.util.isEmpty(getEmail)){
            var toastParam = {"message": "Please add Recipients!!","type":"error"};
            if (sforce && sforce.one) {
                sforce.one.showToast(toastParam);
            }
        }else{
            if($A.util.isEmpty(subject)){
                component.set("v.mailStatus",true);
            }else{
                console.log('IN sendMail else');
                helper.sendHelper(component,event);
            }
        }
    },
    
    onRemovePill: function(component, event, helper){
        var label = event.getSource().get("v.name");
        var pillList = component.get("v.emailPills");
        for(var i=0;i<pillList.length;i++){
            if(pillList[i].name == label){
                pillList.splice(i, 1);
                var emailBoxWidth = parseInt(component.get("v.emailBoxWidth"));
            	var pillBoxWidth = parseInt(component.get("v.pillBoxWidth"));
               	emailBoxWidth += pillBoxWidth;
                component.set("v.emailBoxWidth",(String(emailBoxWidth)+'%'));
            }
        }
        if(pillList.length == 0){
            component.set("v.listOfEmails",'');
        }else if (pillList.length == 1){
            component.set("v.listOfEmails",pillList[0].name);
        }
        component.set("v.emailPills",pillList);
    },
    
    openTemplateModel: function(component, event, helper){
        var appEvent = $A.get("e.c:WBCP_SendEmailEvent");
        appEvent.setParams({"openModel" : true});
        appEvent.fire();
    },
    
    selectEmailTemplate: function(component, event, helper){
        var emailTemp = event.getParam("emailTemplate");
        console.log('HtmlValue : ',emailTemp.HtmlValue);
        component.set("v.templateFlag",false);
        component.set("v.emailTemp",emailTemp);
        component.set("v.subject",emailTemp.Subject);
        component.set("v.emailBody",emailTemp.HtmlValue);
    },
    
    closeMailStatus: function(component, event, helper){
        component.set("v.mailStatus",false);
    },
    sendMailStatus: function(component, event, helper){
        component.set("v.mailStatus",false);
        helper.sendHelper(component,event);
    },
    
    openFileUploadScreen: function(component, event, helper){
        component.set("v.fileUpload",true);
    },
    closeFileUploadBox:function(component, event, helper){
        component.set("v.fileUpload",false);
    },
    handleFilesChange: function (component, event,helper) {
        var allFileTypes = ['attachment','audio','box_notes','csv','eps','excel','exe','flash','folder','gdoc','gdocs','gform','gpres','gsheet','html','image','keynote','library_folder','link','mp4','overlay','pack','pages','pdf','ppt','psd','quip_doc','quip_sheet','quip_slide','rtf','slide','stypi','txt','unknown','video','visio','webex','word','xml','zip'];
    	var files = event.getSource().get("v.files");
       	var fileSize = component.get("v.attachmentSize") ? component.get("v.attachmentSize") : 0;
        var attachedFileSize = fileSize;
        var limitExceeds = false;
        var extAttachments = component.get("v.attachments");
        var moreThan6MBFile = [];
        for(var i=0;i<files.length;i++){
            var fSize = files[i].size; 
            fileSize += fSize;
            var fSizeInString = fSize+' B';
            
            if(fSize >= 1000 && fSize < 1000000){
                fSizeInString = Math.round(fSize/1000)+' KB';
            }else if(fSize >= 1000000){
                fSizeInString = Math.round(fSize/1000000)+' MB';
            }
            
            if(fileSize > helper.MAX_ATTACHMENT_LIMIT){
                limitExceeds = true;
                if(fSize >= 5000000){
                    moreThan6MBFile.push(files[i].name+' ('+fSizeInString+')');
                }
            }else{
                if(fSize >= 5000000){
                    moreThan6MBFile.push(files[i].name+' ('+fSizeInString+')');
                }else{
                	var attachment = {
                        file : files[i],
                        label : files[i].name+' ('+fSizeInString+')',
                        type : "doctype:"+helper.getfileType(files[i].name,allFileTypes)
                    }
                    attachedFileSize += fSize;
                    extAttachments.push(attachment);    
                }
            }
        }
        if(limitExceeds || moreThan6MBFile.length > 0){
            
            var message = limitExceeds ? 'Total Attachments size exceeds available limit: 25MB!! ' : '';
             
            if(moreThan6MBFile.length > 0){
                message += 'Each attachment size should be less than 6MB. Found '+moreThan6MBFile.length+' files having size >= 6MB.';
            }
            var toastParam = {"message": message,"duration":"10000","type":"info"};
            if (sforce && sforce.one) {
                sforce.one.showToast(toastParam);
                component.set("v.toastMessage","pre-line !important");
            } 
        }
        component.set("v.attachmentSize",attachedFileSize);
       	component.set("v.attachments",extAttachments);
        component.set("v.fileUpload",false);
	},
    removeAttachment: function(component, event, helper){
        var label = event.getSource().get("v.name");
        var attachments = component.get("v.attachments");
        var attachedFileSize = component.get("v.attachmentSize");
        for(var i=0;i<attachments.length;i++){
            if(attachments[i].file.name == label){
                attachedFileSize -= attachments[i].file.size;
                attachments.splice(i, 1);
            }
        }
        component.set("v.attachmentSize",attachedFileSize);
        component.set("v.attachments",attachments);
    }
})