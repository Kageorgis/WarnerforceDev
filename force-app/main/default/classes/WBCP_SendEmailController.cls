public with sharing class WBCP_SendEmailController {
    public string mapContactEmailId{get; set;}
    public string listViewId{get; set;}
    public WBCP_SendEmailController() {
        this.mapContactEmailId = System.currentPagereference().getParameters().get('mapContactEmailId');
        System.debug('mapContactEmailId');
        this.listViewId = [SELECT Id,Name,SobjectType FROM ListView WHERE SobjectType='Contact' AND Name='Recently Viewed Contacts' LIMIT 1].Id;
    }

    @AuraEnabled
    public static Id createListEmailRecord(String contactEmails ,Id emailTempId,String subject,String emailBody,Id listEmailId){
    return null;
    }

    @AuraEnabled
    //public static void sendEmail(String contactEmails ,Id emailTempId,String subject,String emailBody,Id listEmailId, String mapContactEmailId){
    public static void sendEmail(Id emailTempId,String subject,String emailBody,Map<String,Object> mapContactEmailIdToSend,Object[] attachmentIds){
        System.debug('mapContactEmailIdToSend:::'+mapContactEmailIdToSend);
        System.debug('attachmentIds:::'+attachmentIds);
        Map<String,String> mapContactEmailId = new Map<String,String>();
        List<String> attachmentStringIds = new List<String>();
        for(String email : mapContactEmailIdToSend.keySet()){
            mapContactEmailId.put(email,String.valueOf(mapContactEmailIdToSend.get(email)));
        }
        system.debug('mapContactEmailId==>'+mapContactEmailId.values()[0]);
        for(Object attachmentId : attachmentIds){
            attachmentStringIds.add(String.valueOf(attachmentId));
        }
        System.debug('attachmentStringIds:::'+attachmentStringIds); 
        if(!mapContactEmailId.isEmpty()){
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId =: mapContactEmailId.values()[0] AND ID IN :attachmentStringIds];
            system.debug('files : '+files.size());
            for(String email : mapContactEmailId.keySet()){
                System.debug('email:::'+email);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{email});
                mail.setSubject(subject);
                mail.setHtmlBody(emailBody);
                if(!String.isBlank(mapContactEmailId.get(email))){
                    mail.setSaveAsActivity(true);
                    mail.setTargetObjectId(mapContactEmailId.get(email));
                }
                if(emailTempId != null){
                    mail.setTemplateId(emailTempId);  
                    mail.setTreatBodiesAsTemplate(true);
                }
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                for (Attachment file: files) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(file.Name);
                    efa.setBody(file.Body);
                    efa.setContentType(file.ContentType);
                    attachments.add(efa);
                }
                if(!attachments.isEmpty()){
                    mail.setFileAttachments(attachments);    
                }
                mails.add(mail);
            }
            System.debug('mails:::'+JSON.serialize(mails));
            for(Messaging.SingleEmailMessage singMail: mails)
            System.debug('mails:::'+singMail);
            Messaging.sendEmail(mails);
        }
    }

    @AuraEnabled
    public static list<EmailTemplateWrapper> getEmailTempaltes(){
        Map<String,EmailTemplateWrapper> mapOfEmailTemp = new Map<String,EmailTemplateWrapper>();
        for(EmailTemplate emailtemp : [SELECT Body,Description,DeveloperName,FolderId,FolderName,HtmlValue,Id,IsActive,Name,Subject,TemplateStyle,TemplateType FROM EmailTemplate WHERE IsActive = true AND TemplateType != 'visualforce' ORDER BY Name ASC]){
            if(emailtemp.HtmlValue != null){
                if(mapOfEmailTemp.containsKey(emailtemp.FolderId)){
                   EmailTemplateWrapper eWrap = mapOfEmailTemp.get(emailtemp.FolderId);
                   eWrap.emailtemplatelist.add(emailtemp);
                }else{
                    EmailTemplateWrapper eWrap = new EmailTemplateWrapper();
                    eWrap.folderName = String.valueOf(emailtemp.FolderName);
                    eWrap.folderId = String.valueOf(emailtemp.FolderId);
                    eWrap.emailtemplatelist = new List<EmailTemplate>();
                    eWrap.emailtemplatelist.add(emailtemp);
                    mapOfEmailTemp.put(eWrap.folderId,eWrap);
                }
            }
        }
        return mapOfEmailTemp.values();
    }

    public class EmailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public List<EmailTemplate> emailtemplatelist{get;set;}
        
    }

    @AuraEnabled
    public static List<String> storetheAttachedFile(String fileName, String base64Data, String contentType, Map<String,Object> mapContactEmailIdToSend, List<String> listFielIds) {
        System.debug('mapContactEmailIdToSend:::'+mapContactEmailIdToSend);
        System.debug('listFielIds:::'+listFielIds);
        Set<String> contactIds = new Set<String>();
        for(Object contactId : mapContactEmailIdToSend.values()){
            if(!String.isBlank(String.valueOf(contactId))){
                contactIds.add(String.valueOf(contactId));
            }
        }
        if (listFielIds.isEmpty()) {
            listFielIds = saveTheFile(fileName, base64Data, contentType, contactIds);
        } else {
            appendToFile(listFielIds, base64Data);
        }
        
        return listFielIds;
    }

    public static List<String> saveTheFile(String fileName, String base64Data, String contentType, Set<String> contactIds) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        List<Attachment> listAttachRecs = new List<Attachment>();
        List<String> insertedAttachmentIds = new List<String>();
        for(String contactId : contactIds){
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = contactId;
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            listAttachRecs.add(oAttachment);
        }
        
        Database.SaveResult[] srList = Database.insert(listAttachRecs);

        for (Database.SaveResult sr : srList)
        {
            insertedAttachmentIds.add(sr.getId());
        }
        return insertedAttachmentIds;
    }

    private static void appendToFile(List<String> listFielIds, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        List<Attachment> listAttachRecs = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id IN: listFielIds
        ];
        
        for(Attachment attachRec : listAttachRecs){
            attachRec.Body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attachRec.Body) + base64Data);        
        }
        update listAttachRecs;
    }
}