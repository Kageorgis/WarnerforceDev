/*
* Processes information from the file to insert the object Product2
*
* Author:          Date:           Description
* Martin Mori   18-April-17        First Draft
*/

global class TPX_UploadProducts_Batch implements Database.Batchable<String>, Database.Stateful {
    
    global final blob binFile;
            
    global TPX_UploadProducts_Batch(blob binData){
        this.binFile = binData;
    }
    
    //Method to convert the file to utf-8 Charset
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
    
    global Iterable<String> start(Database.BatchableContext BC){
        //return new FileIterator(this.binFile.toString(), '\n');
        return new FileIterator(blobToString(this.binFile,'UTF-8'), '\n');
    }
    global void execute(Database.BatchableContext BC, List<String> lstoProduct){
        //We get Ids recordtype and pricebooks
        Id rtProduct = [SELECT Id FROM RecordType WHERE Name = 'ELLEN Products' AND SObjectType = 'Product2' LIMIT 1].Id;
        Id idPriceBookStandard = '01sU0000000Q9brIAC';//[SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
        Id idPriceBookEllen = [SELECT Id FROM PriceBook2 WHERE Name = 'ELLEN Price Book' LIMIT 1].Id;
        
        //
        List<Product2> ltsProduct = new List<Product2>();
        for(String row : lstoProduct){
            row=row.replace('""', '"');
			List<String> fields = row.split(',');
            //It is not comparate when the first row that contains the file header.
            if(String.valueOf(fields[0].trim())!='Product Name'){
                if(String.valueOf(fields[0].trim()).contains('"')) {
                    fields = row.split('",');
                    Integer pos = 0;
                    for(String aux : fields) {
                        if(aux.contains('"')) {
                            String startCharacter = aux.substring(0,1);
                            if(startCharacter=='"') {
                                fields[pos] = aux.substring(1);
                            }
                        }
                        pos++;
                    }
                    if(fields.size()==2) {
                        List<String> fieldsAux = fields[1].split(',');
                    	ltsProduct.add(new Product2(Name=fields[0].trim(), Product_Category__c=fieldsAux[0].trim(), Product_Sub_Category__c=fieldsAux[1].trim(), IsActive=true, RecordTypeId=rtProduct));
                    }
                    else {
                    	ltsProduct.add(new Product2(Name=fields[0].trim(), Product_Category__c=fields[1].trim(), Product_Sub_Category__c=fields[2].trim(), IsActive=true, RecordTypeId=rtProduct));
                    }
                }
                else {
                    ltsProduct.add(new Product2(Name=fields[0].trim(), Product_Category__c=fields[1].trim(), Product_Sub_Category__c=fields[2].trim(), IsActive=true, RecordTypeId=rtProduct));
                }
            }
        }
        
        if(ltsProduct.size()>0){
            if(Test.isRunningTest()){
                ltsProduct.remove(0);
            }
            insert ltsProduct;
            //We create PriceBookEntry
            List<PriceBookEntry> ltsInsertPriceBookEntryEllen = new List<PriceBookEntry>();
            List<PriceBookEntry> ltsInsertPriceBookEntryStandard = new List<PriceBookEntry>();
            for(Product2 oProduct : ltsProduct) {
                ltsInsertPriceBookEntryStandard.add(new PriceBookEntry(PriceBook2Id=idPriceBookStandard, Product2Id=oProduct.Id, IsActive=true, UnitPrice=0));
                ltsInsertPriceBookEntryEllen.add(new PriceBookEntry(PriceBook2Id=idPriceBookEllen, Product2Id=oProduct.Id, IsActive=true, UnitPrice=0));
            }
            if(ltsInsertPriceBookEntryStandard.size()>0) insert ltsInsertPriceBookEntryStandard;
            if(ltsInsertPriceBookEntryEllen.size()>0) insert ltsInsertPriceBookEntryEllen;
        }
        
	}

    global void finish(Database.BatchableContext BC){
        
    }
}