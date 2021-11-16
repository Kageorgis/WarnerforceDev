/*
* Performs the upload of Products, only accepts files in CSV format.
*
* Author:          Date:           Description
* Martin Mori   18-April-17        First Draft
*/

public with sharing class TPX_UploadProducts_CC {
	public Id BatchId {get; set;}
    public String sNameFile {get;set;}
    public Static Blob binFile {get;set;}
    public String sStatus {get;set;}
    public String sStatusToView {get;set;}
    public Boolean bStatus {get;set;}
    public Boolean bPoller {get;set;}
	
    //Class constructor
	public TPX_UploadProducts_CC(){
		bStatus = false;
        bPoller = false;
        sNameFile = '';
		if(binFile != null){
            sNameFile = binFile.toString();
		}
	}
    
    //Method to read the file
	public void readFile(){
		bStatus = true;
		TPX_UploadProducts_Batch uploadProducts = new TPX_UploadProducts_Batch(binFile);
		BatchId = Database.executeBatch(uploadProducts, 50);
		getBatchStatus();
	}
	
    //Method to obtain the status of the batch
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