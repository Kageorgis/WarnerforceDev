/*******************************************************************************************************************
* File Name     :   WB_CAUploadTriggerHandler
* Description   :    
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     13 JAN.2016       CTS                 Created class with method which is used to delete the related attachement if CA Uplaod 
*                                               Status changes from Uploaded to Waiting To Process
* 2.0       
*********************************************************************************************************************/

public class WB_CAUploadTriggerHandler {
    public static void  DeleteAttachements(List<CA_Upload__c> listCAUploadRecords,Map<id,Sobject> mapOldCAUpload)
    {
        Map<id,List<Attachment>> MapAttachment = new Map<id,List<Attachment>>();
        for(Attachment att : [Select id,ParentId from Attachment where ParentId in: trigger.new])
        {
            if(!MapAttachment.containskey(att.ParentId))
                MapAttachment.put(att.ParentId, new List<Attachment>());
            MapAttachment.get(att.ParentId).add(att);
        }
        for(CA_Upload__c caUplload : listCAUploadRecords)
        {
            CA_Upload__c oldCAUpload = (CA_Upload__c)mapOldCAUpload.get(caUplload.ID);
            if(caUplload.Upload_Status__c == 'Waiting To Process' && oldCAUpload.Upload_Status__c == 'Uploaded')
            {
                if(MapAttachment != null && MapAttachment.size() > 0)
                    delete MapAttachment.get(caUplload.id);
                WB_Batch_CA_Upload c = new WB_Batch_CA_Upload(caUplload.id);
                database.executebatch(c,10);
            }
            
        } 
    }
    
    /*public static void ScheduleBatch(List<CA_Upload__c> listCreatedCAUpload)
    {
        List<CA_Upload__c> tobeupdate = new List<CA_Upload__c>();
        for(CA_Upload__c caupload : listCreatedCAUpload)
        {
            String hour = String.valueOf(Datetime.now().hour()+1);
            String min = String.valueOf(Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second());
            
            parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            Id jobid1 = System.schedule('Schedule CA Upload 1 for '+caupload.name, '30 0 * * * ?', new WB_Schedule_CA_Upload(caupload.id));
            Id jobid2 = System.schedule('Schedule CA Upload 2 for '+caupload.name, '30 15 * * * ?', new WB_Schedule_CA_Upload(caupload.id));
            Id jobid3 = System.schedule('Schedule CA Upload 3 for '+caupload.name, '30 30 * * * ?', new WB_Schedule_CA_Upload(caupload.id));
            Id jobid4 = System.schedule('Schedule CA Upload 4 for '+caupload.name, '30 45 * * * ?', new WB_Schedule_CA_Upload(caupload.id));
            
            //WB_Batch_CA_Upload scheduler = new WB_Batch_CA_Upload(caupload.id); 
            //Id jobid = System.schedule('CA Upload batch on '+caupload.createddate, nextFireTime, scheduler);
            tobeupdate.add(new CA_Upload__c(id=caupload.id,Scheduler_Id__C=jobid1+','+jobid2+','+jobid3+','+jobid4));
        }
        update tobeupdate;    
    }*/
}