/*
* Processes information from the file to insert the object Inventory
*
* Author:          Date:           Description
* Walter Ynche  19-August-16       First Draft
*/

global class UploadInventory_Batch implements Database.Batchable<String>, Database.Stateful {
    
    global final blob binFile;
            
    global UploadInventory_Batch(blob binData){
        this.binFile = binData;
    }
    
    global Iterable<String> start(Database.BatchableContext BC){
        system.debug('##start');
        return new FileIterator(this.binFile.toString(), '\n');
    }
    global void execute(Database.BatchableContext BC, List<String> lstoInventory){
        system.debug('##execute');
        
        Map<String,Integer> mapCoverRatingCounter = new Map<String,Integer>();
        Map<String,Integer> mapCoverRatingProductCounter = new Map<String,Integer>();
        Integer iCounterProduct;
        for(String row : lstoInventory){
			List<String> fields = row.split(',');
            //It is not comparate when the first row that contains the file header.
            if(fields[0].trim()!='Product'){
                iCounterProduct = 0; 
                //When they sell this it counts as 1 page
                if(fields[0].trim()=='First RHP' && fields[3].trim()!='Weekly'){
                    if(mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim())==null && Integer.valueOf(fields[2].trim())==1 && fields[1].trim()!='Mad'){
						iCounterProduct = 1;
                    	mapCoverRatingProductCounter.put(fields[1].trim()+'-'+fields[0].trim(),1);
                    }else{
                        System.abortJob(BC.getJobId());
                    }
                //When they sell this it counts as 1 page
                }else if(fields[0].trim()=='Second RHP' && fields[3].trim()!='Weekly'){
                    if(mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim())==null && Integer.valueOf(fields[2].trim())==1 && (fields[1].trim()!='Kids' || fields[1].trim()!='Mad')){
						iCounterProduct = 1;
                    	mapCoverRatingProductCounter.put(fields[1].trim()+'-'+fields[0].trim(),1);
                    }else{
                        System.abortJob(BC.getJobId());
                    }
                //When they sell this it counts as 2 pages
                }else if(fields[0].trim()=='First Spread' && fields[3].trim()!='Weekly'){
                    if(mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim())==null && Integer.valueOf(fields[2].trim())==1 && fields[1].trim()!='Mad'){
						iCounterProduct = 2;
                    	mapCoverRatingProductCounter.put(fields[1].trim()+'-'+fields[0].trim(),1);
                    }else{
                        System.abortJob(BC.getJobId());
                    }
                //When they sell this it counts as 2 pages
                }else if(fields[0].trim()=='Center Spread' && fields[3].trim()!='Weekly'){
                    if(mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim())==null && Integer.valueOf(fields[2].trim())==1 && (fields[1].trim()!='Kids' || fields[1].trim()!='Mad')){
						iCounterProduct = 2;
                    	mapCoverRatingProductCounter.put(fields[1].trim()+'-'+fields[0].trim(),1);
                    }else{
                        System.abortJob(BC.getJobId());
                    }
				//When they sell this is counts as 1 page, but they can sell more than 1
                }else if(fields[0].trim()=='Interior Page' && fields[3].trim()!='Weekly'){
                    if(mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim())==null){
                        if((Integer.valueOf(fields[2].trim())<=9 && fields[1].trim()!='Kids' && fields[1].trim()!='Mad') || (Integer.valueOf(fields[2].trim())<=6 && fields[1].trim()!='Kids' && fields[1].trim()=='Mad')){
                            iCounterProduct = Integer.valueOf(fields[2].trim());
                            mapCoverRatingProductCounter.put(fields[1].trim()+'-'+fields[0].trim(),iCounterProduct);
                        }else{
                            System.abortJob(BC.getJobId());
                        }
                    }else{
                        if(((mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim()) + Integer.valueOf(fields[2].trim()) <= 9) && fields[1].trim()!='Kids' && fields[1].trim()!='Mad')
                          || ((mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim()) + Integer.valueOf(fields[2].trim()) <= 6) && fields[1].trim()!='Kids' && fields[1].trim()=='Mad')){
                            iCounterProduct = Integer.valueOf(fields[2].trim());
                            mapCoverRatingProductCounter.put(fields[1].trim()+'-'+fields[0].trim(),iCounterProduct);
                        }else{
                            System.abortJob(BC.getJobId());
                        }
                    }
                }else{
                    if(fields[3].trim()!='Weekly'){
                        if(mapCoverRatingProductCounter.get(fields[1].trim()+'-'+fields[0].trim())!=null && (fields[0].trim()=='C2' || fields[0].trim()=='C3' || fields[0].trim()=='C4') && (fields[1].trim()!='Kids' || fields[1].trim()!='Mad')){
                            System.abortJob(BC.getJobId());
                        }
                    }
                }
                
                //When is One-Time Change, not valid amount.
                if(fields[3].trim()=='One-Time Change'){
                    if(fields[5].trim()==''){
                        //Abort Proccess.
                        system.abortJob(BC.getJobId());
                    }
                }else{
                    Integer iCounterProductTotal = mapCoverRatingCounter.get(fields[1].trim());
                    //If there is no counter for this Cover Rating is added.
                    if(iCounterProductTotal==null){
                        mapCoverRatingCounter.put(fields[1].trim(),iCounterProduct);
                    }else{
                        iCounterProductTotal = iCounterProductTotal + iCounterProduct;
                        //Only 9 pages can be sold for a given week.
                        if(iCounterProductTotal <= 9){
                            mapCoverRatingCounter.put(fields[1].trim(),iCounterProductTotal);
                        }else{
                            //Abort Proccess.
                            System.abortJob(BC.getJobId());
                        }
                    }
                }
                
                //Validation
                if(fields[4].trim()=='Print'){
                    //If One-Time Change validate enter date
                    if(fields[3].trim()=='One-Time Change' && fields[5].trim()==''){
                        System.abortJob(BC.getJobId());
                    }
                }else if(fields[4].trim()=='Digital'){
                    //If Daily validate enter quantity
                    if(fields[3].trim()=='Daily' && fields[2].trim()==''){
                        System.abortJob(BC.getJobId());
                    }
                }
            }
        } 
        
        Map<String,Id> mapNameIdProduct2 = new Map<String,Id>();
		for(Product2 product : [Select Id, Name From Product2 WHERE IsActive = true AND RecordType.Name = 'DC Products']){
        	mapNameIdProduct2.put(product.Name,product.Id);
        }
        
        Set<Product2> setProduct2 = new Set<Product2>();
        Id ProductId;
        for(String row : lstoInventory){
            //The fields in each row of the file is separated.
			List<String> lstFields = row.split(',');
            //It is not added to the list when the first row that contains the file header.
            if(lstFields[0].trim()!='Product' && lstFields[0].trim()!=''){
                ProductId = mapNameIdProduct2.get(lstFields[0].trim());
                if(ProductId == null){
                    Product2 product = new Product2();
                    product.Name = lstFields[0].trim();
                    product.Family = lstFields[4].trim();
                    setProduct2.add(product);
                }
            }
        }
        
        if(setProduct2.size()>0){
            List<Product2> lstProduct2 = new List<Product2>();
            lstProduct2.addAll(setProduct2);
            try{
            	insert lstProduct2;
            }catch(DMLException e){
                System.abortJob(BC.getJobId());
            }
        } 
        
        mapNameIdProduct2.clear();
		for(Product2 product : [Select Id, Name From Product2 WHERE IsActive = true AND RecordType.Name = 'DC Products']){
        	mapNameIdProduct2.put(product.Name,product.Id);
        }
        
        List<Inventory__c> lstInventory = new List<Inventory__c>();
        for(String row : lstoInventory){
			List<String> lstFields = row.split(',');
            if(lstFields[0].trim()!='Product' && lstFields[0].trim()!=''){
                if(lstFields[4].trim()=='Print' && lstFields[1].trim()!='' && lstFields[2].trim()!='' && lstFields[3].trim()!=''){
                    Inventory__c inventory = new Inventory__c();
                    inventory.Target_Cover_Rating__c = lstFields[1].trim();
                    inventory.Quantity__c = decimal.valueOf(lstFields[2].trim());
                    inventory.Onsale_Availability__c = lstFields[3].trim();
                    inventory.Product__c = mapNameIdProduct2.get(lstFields[0].trim());
                    String dateString = '';
                    if(lstFields[3].trim()=='One-Time Change' && lstFields[5].trim()!=''){
                        String[] s = lstFields[5].trim().split('/');
                        dateString = ' '+s[2]+'-'+s[0]+'-'+s[1];
						inventory.Availability_Date__c = Date.parse(lstFields[5].trim());  
                    } 
                    inventory.External_ID__c = lstFields[0].trim()+' '+lstFields[1].trim()+' '+lstFields[3].trim()+dateString;
                    lstInventory.add(inventory);
                }else if(lstFields[4].trim()=='Digital'){
                    Inventory__c inventory = new Inventory__c();
                    inventory.Target_Cover_Rating__c = lstFields[1].trim();
                    if(lstFields[2].trim()!='') inventory.Quantity__c = decimal.valueOf(lstFields[2].trim()); 
                    inventory.Onsale_Availability__c = lstFields[3].trim();
                    inventory.Quantity__c = decimal.valueOf(lstFields[2].trim());
                    String dateString = '';
                    if(lstFields[3].trim()=='One-Time Change' && lstFields[5].trim()!=''){
                        String[] s = lstFields[5].trim().split('/');
                        if(lstFields[0].trim()=='DCComics.com Leaderboard (728x90)' ||
                          lstFields[0].trim()=='DCComics.com Medium Rectangle (300x250)' || 
                          lstFields[0].trim()=='MadMagazine.con Leaderboard (728x90)' || 
                          lstFields[0].trim()=='MadMagazine.con Medium Rectangle (300x250)' || 
                          lstFields[0].trim()=='Vertigocomincs.com Leaderboard (728x90)' || 
                          lstFields[0].trim()=='Vertigocomincs.com Medium Rectangle (300x250)') {
                               dateString = ' '+s[2]+'-'+s[0];
                           }
                        else {
                            dateString = ' '+s[2]+'-'+s[0]+'-'+s[1];
                        }
                        inventory.Availability_Date__c = Date.parse(lstFields[5].trim());    
                    }
                    inventory.External_ID__c = lstFields[0].trim()+' '+lstFields[1].trim()+' '+lstFields[3].trim()+dateString;
                    inventory.Product__c = mapNameIdProduct2.get(lstFields[0].trim());
                    if(lstFields[6].trim()!='') inventory.Impressions__c = decimal.valueOf(lstFields[6].trim()); 
                    lstInventory.add(inventory);                
                }
            }
        }
        
        if(lstInventory.size()>0){
            try{
            	upsert lstInventory External_ID__c;
            }catch(DMLException e){
                System.abortJob(BC.getJobId());
            }
        }
	}

    global void finish(Database.BatchableContext BC){
        system.debug('##finish');
    }
}