/*
* Performs the upload of Inventory, only accepts files in CSV format.
*
* Author:          Date:           Description
* Walter Ynche  19-August-16       First Draft
*/

public with sharing class UploadInventory_CC {
	public Id BatchId {get; set;}
    public String sNameFile {get;set;}
    public Static Blob binFile {get;set;}
    public String sStatus {get;set;}
    public String sStatusToView {get;set;}
    public Boolean bStatus {get;set;}
    public Boolean bPoller {get;set;}

	public UploadInventory_CC(){
		bStatus = false;
        bPoller = false;
        sNameFile = '';
		if(binFile != null){
            sNameFile = binFile.toString();
		}
	}
    
	public void readFile(){
		bStatus = true;
		UploadInventory_Batch uploadInventoryBatch = new UploadInventory_Batch(binFile);
		BatchId = Database.executeBatch(uploadInventoryBatch, 50);
		getBatchStatus();
	}
	
	public void getBatchStatus(){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: BatchId];
        sStatus = job.Status;
        if(sStatus=='Failed') sStatusToView = 'Failed';
        else if(sStatus=='Completed') sStatusToView = 'Complete';
        else if(sStatus=='Aborted') sStatusToView = 'Aborted';
        else sStatusToView = 'Uploading';
        
        if(job!=null){
			if(sStatus == 'Completed' || sStatus == 'Aborted'){
	            bPoller = false;
	        }else{
	            bPoller = true;
	        }
        }
    }
}