@isTest(seeAllData=true)
public class WB_ClientAvailPriceTriggerTest {
    
    public static testMethod void testCapCreation(){
    	
    	List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
    	List<Client_Avail_Price__c> rePriceList = new List<Client_Avail_Price__c>();
    	
    	Client_Avail__c[] carecords	 = [Select Id,Name,Start_Date__c,End_Date__c from Client_Avail__c Where CA_LifeCycle__c ='Active Current' and End_Date__c > :System.Today().addDays(200) Limit 10];
    	System.debug(carecords);
    	
    	for(Client_Avail__c caRecord:carecords){
    		if(caRecord.End_Date__c > System.Today().addDays(10)){
    			Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c=caRecord.Id,Type__c='First',Category__c='Catalog',Price__c=14.99,Effective_Date__c=caRecord.Start_Date__c,Expiry_Date__c=caRecord.End_Date__c);
    			capList.add(cap1);
    			
    			Client_Avail_Price__c cap2 = new Client_Avail_Price__c(Client_Avail__c=caRecord.Id,Category__c='Catalog',Price__c=11.99,Effective_Date__c=caRecord.Start_Date__c.addDays(8));
    			rePriceList.add(cap2);
    			
    		}
    	}
    	
    	try{
	    	Database.insert(capList,false);
	    	
	    	Database.insert(rePriceList,false);
	    	
	    	for(Client_Avail_Price__c updateCap:rePriceList){
	    		updateCap.Price__c = 8.99;
	    	}
	    	Database.update(rePriceList,false);
	    	
	    	Database.delete(rePriceList[0],false);
    	}catch(Exception ex){
    		
    	}
    }
    
}