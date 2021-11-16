/*
* Processes information from the file to insert the object Materials_Due
*
* Author:          Date:           Description
* Walter Ynche  19-August-16       First Draft
*/

global class UploadMaterial_Batch implements Database.Batchable<String>, Database.Stateful {
    
    global final blob binFile;
            
    global UploadMaterial_Batch(blob binData){
        this.binFile = binData;
    }
    
    global Iterable<String> start(Database.BatchableContext BC){
        system.debug('##start');
        return new FileIterator(this.binFile.toString(), '\n');
    }
    
    global void execute(Database.BatchableContext BC, List<String> lstoMaterialsDue){
        system.debug('##execute');       
        Map<String,String> mapMaterialsDue = new Map<String,String>();
        for(Materials_Due__c materialsDue : [Select Id, Name From Materials_Due__c]){
            mapMaterialsDue.put(materialsDue.Name,materialsDue.Id);
        }
        
        List<Materials_Due__c> lstMaterialsDue = new List<Materials_Due__c>();        
        for(String row : lstoMaterialsDue){
            //The fields in each row of the file is separated.
			List<String> lstFields = row.split(',');
            //It is not added to the list when the first row that contains the file header.
            if(lstFields[0].trim()!='Materials Due Name' && lstFields[0].trim()!='' && lstFields[1].trim()!='' && lstFields[2].trim()!=''){
                Materials_Due__c materialsDue = new Materials_Due__c();
                if(mapMaterialsDue.get(lstFields[0].trim()) != null){
                    materialsDue.Id = mapMaterialsDue.get(lstFields[0].trim());
                    materialsDue.Drop_Dead__c = Date.parse(lstFields[2].trim());
                    materialsDue.Materials_Due__c = Date.parse(lstFields[1].trim());
                }else{
                    materialsDue.Name = lstFields[0].trim();
                    materialsDue.Drop_Dead__c = Date.parse(lstFields[2].trim());
                    materialsDue.Materials_Due__c = Date.parse(lstFields[1].trim());
                }
                lstMaterialsDue.add(materialsDue);
            }
        }
        
        if(lstMaterialsDue.size()>0){
            try{
            	upsert lstMaterialsDue;
            }catch(DMLException e){
                System.abortJob(BC.getJobId());
            }
        }
	}

    global void finish(Database.BatchableContext BC){
        system.debug('##finish');
    }
}