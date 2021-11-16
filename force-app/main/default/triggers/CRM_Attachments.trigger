trigger CRM_Attachments on Attachment (before delete) {
	if(Trigger.isBefore && Trigger.isDelete) {
		CRM_AttachmentSequenceController.executeBeforeDelete(Trigger.Old);
  	}
}