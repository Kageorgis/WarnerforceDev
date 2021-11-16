public with sharing class WB_CA_Upload_Streaming_Controller {

    public List<CA_Upload__c> summaryData {get;set;}
    public Id selectedSummaryId;
    public String renderFile {get;set;}
        
    public WB_CA_Upload_Streaming_Controller(ApexPages.StandardController controller) {
        summaryData = new List<CA_Upload__c>();
        selectedSummaryId = (Id)controller.getRecord().get('id');
        renderFile = null;
        getSummaryData();
    }
    
    public String getlinkForAttachment(){
      CA_Upload__c result = [Select Id, (Select Id, Name from Attachments) from CA_Upload__c Where Id = :selectedSummaryId LIMIT 1];
      if(result.Attachments.size() != 0) {
          Attachment temp = result.Attachments[0];
          String link = String.valueOf(temp.Id);
          renderFile = 'Yes';
          return link;
      } else return null;
    }
    
    public void getSummaryData() {
        try{
            for(CA_Upload__c ca : [SELECT Id,Name,Upload_Time__c,Upload_Status__c
                             FROM CA_Upload__c
                            WHERE Id = :selectedSummaryId 
                            LIMIT 1
                          ])
                summaryData.add(ca);
        }
        catch(QueryException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

}