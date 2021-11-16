/**
    *  Description - This class is used to Update the field on Local Data object with the comma seperated values of Topics added
    *  on the Local Data record. If Topic length is > 255 characters, it will substring the last characters and update Topics__c for this
    *  we have used substring method. 
    *  @name - updateTopic
    *  @param - 
    *  @return -
    *  @throws exception- //TO DO
    */
    public with sharing Class CRM_TopicAssignmentHandler{
    String topicName;
    public static Set<Id> setModifiedTopicIds = new Set<Id>();
    public static Set<Id> setLocalTitleIds = new Set<Id>();
    
    public void getNewTopicId(Map<Id,TopicAssignment> mapOldTopicAssignments, Map<Id,TopicAssignment> mapNewTopicAssignments){
        for(TopicAssignment topicAssign:mapNewTopicAssignments.values()){
            setModifiedTopicIds.add(topicAssign.Id);
            setLocalTitleIds.add(topicAssign.EntityId);
        }
        if(!setLocalTitleIds.isEmpty() || !setModifiedTopicIds.isEmpty())  
        updateTopic(setLocalTitleIds, setModifiedTopicIds);
        }
        
    public void getOldTopicId(Map<Id,TopicAssignment> mapOldTopicAssignments, Map<Id,TopicAssignment> mapNewTopicAssignments){
        for(TopicAssignment oldTopicAssign:mapOldTopicAssignments.values()){
            setModifiedTopicIds.add(oldTopicAssign.Id);
            setLocalTitleIds.add(oldTopicAssign.EntityId);
        } 
        if(!setLocalTitleIds.isEmpty() || !setModifiedTopicIds.isEmpty())  
              updateTopic(setLocalTitleIds, setModifiedTopicIds);
        }
        
    public void updateTopic(Set<Id> setLocalTitleId, Set<Id> setModifiedTopicId){     
        //Holds a map of the Local Data id and comma separated Topics
        Map<Id, String> localTitleTopicMap = new Map<Id, String>(); 
        
        //if(setLocalTitleId!=Null || !setLocalTitleId.isEmpty())
        List<TopicAssignment> topicAssignment = [select id, EntityId,TopicId,Topic.Name from TopicAssignment
                                                 where EntityId IN : setLocalTitleId order by CreatedDate];
        
        if(topicAssignment.size()>0 && !topicAssignment.isEmpty()){
            for (TopicAssignment tAssign: topicAssignment){
                if(!localTitleTopicMap.containsKey(tAssign.EntityId)){
                    localTitleTopicMap.put(tAssign.EntityId,tAssign.Topic.Name);   // if the key (Local Data) doesn't exist, add it with Topic Name
                }
                else if(localTitleTopicMap.containsKey(tAssign.EntityId)){
                    localTitleTopicMap.put(tAssign.EntityId,localTitleTopicMap.get(tAssign.EntityId) + ', ' + tAssign.Topic.Name);    // if the key (Local Data) already exist, add ", Topic-name"
                }
                else if(localTitleTopicMap.containsKey(tAssign.Topic.Name)){
                    localTitleTopicMap.put(tAssign.EntityId,tAssign.Topic.Name);    
                }
            }
        }
        
        //if(setLocalTitleId!=Null && !setLocalTitleId.isEmpty())
        List<Local_Title__c> localtitles = [select id,Topics__c from Local_Title__c where Id IN :setLocalTitleId];    //get the Local Data that were affected
       
        if(localtitles.size()> 0 || !localtitles.isEmpty()){   
            for (Local_Title__c ltitle : localtitles){
                if(localTitleTopicMap.containsKey(ltitle.id)){
                    ltitle.Topics__c= localTitleTopicMap.get(ltitle.id);
                }  
                if(ltitle.Topics__c.length()>255){
                    topicName = ltitle.Topics__c.SubString(0,255); // This is to substing the data when Sting>255 character
                    ltitle.Topics__c = topicName;
                }
                else if(ltitle.Topics__c.length()>0 && ltitle.Topics__c.length()<255){
                    topicName = ltitle.Topics__c.SubString(0); // This is to substing the data when Sting<255 character                 
                    ltitle.Topics__c =topicName;
                    
                    if(localTitleTopicMap.get(ltitle.id)==NUll || localTitleTopicMap.get(ltitle.id)==''){
                        topicName = ltitle.Topics__c.remove(topicName);   
                        ltitle.Topics__c =topicName;
                    }
                }
            }
        }
        try{
            if(!localtitles.isEmpty())
            update localtitles;
        }catch(DmlException e){
            System.debug('ERROR:' + e.getMessage());
        } 
    }
}