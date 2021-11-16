public class WB_AddAttendeesCtrl {
	@AuraEnabled
    public static BrandConMainWrap getBrandContacts(Id brandEngId){
        BrandConMainWrap bcw = new BrandConMainWrap();
    	List<BrandConWrap> bcList = new List<BrandConWrap>();
        Set<Id> existingBCIds = new Set<Id>();
        if(brandEngId != null){
            List<Brand_Engagement__c> BE = [Select Id,Brand__c,Brand__r.name,Status__c From Brand_Engagement__c Where Id=:brandEngId];
            for(Attendees__c at : [Select Id,Brand_Contact__c From Attendees__c Where Brand_Engagement__c =:brandEngId]){
                existingBCIds.add(at.Brand_Contact__c);
            }
            if(!BE.isEmpty()){
                for(Brand_Contact__c bc : [Select Id,Name,Account__c,Account__r.name,Contact__c,Contact__r.Email,Contact__r.Phone,Contact__r.name,Role__c From Brand_Contact__c Where Account__c=:BE[0].Brand__c AND ID NOT IN :existingBCIds ORDER BY name ASC]){
                    bcList.add(new BrandConWrap(bc));
                }
            }
            bcw.brandName = BE[0].Brand__r.name;
            bcw.BEStatus = BE[0].status__c != null ? BE[0].status__c : 'Not Started';
        }
        bcw.BCWList = bcList;
        bcw.bcFlag = (existingBCIds.isEmpty() && bcList.isEmpty()) ? true : false;
        return bcw;
    }
    
    @AuraEnabled
    public static list<BrandConWrap> addAttendeesToBE(list<BrandConWrap> bcList,Id brandEngId){
        system.debug('--------'+bcList+'-------'+brandEngId);
        List<Attendees__c> atts = new List<Attendees__c>();
        if(!bcList.isEmpty() && brandEngId != null){
            for(BrandConWrap bcw : bcList){
                Attendees__c at = new Attendees__c();
                at.Brand_Engagement__c = brandEngId;
                at.Brand_Contact__c = bcw.bc.Id;
                atts.add(at);
            }
            
            if(!atts.isEmpty()){
                insert atts;
            }
        }
        return getBrandContacts(brandEngId).BCWList;
    }
    
    public class BrandConWrap{
        @AuraEnabled public string Account_name{get; set;}
        @AuraEnabled public string Contact_name{get; set;}
        @AuraEnabled public string Role{get; set;}
        @AuraEnabled public string Name{get; set;}
        @AuraEnabled public string email{get; set;}
        @AuraEnabled public string phone{get; set;}
        @AuraEnabled public Brand_Contact__c bc{get; set;}
       
        public BrandConWrap(){}
        public BrandConWrap(Brand_Contact__c bc){
            this.bc = bc;
            this.email = bc.Contact__r.Email;
            this.phone = bc.Contact__r.Phone;
        	this.Account_name = bc.Account__r.name;
            this.Contact_name = bc.Contact__r.name;
            this.Role = bc.Role__c;
            this.Name = bc.Name;
        }
    }
    
    public class BrandConMainWrap{
        @AuraEnabled public List<BrandConWrap> BCWList{get; set;}
        @AuraEnabled public boolean bcFlag{get; set;}
        @AuraEnabled public string brandName{get; set;}
        @AuraEnabled public string BEStatus{get; set;}
        
    }
}