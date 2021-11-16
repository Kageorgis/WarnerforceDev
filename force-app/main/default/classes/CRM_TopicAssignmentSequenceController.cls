public with sharing class CRM_TopicAssignmentSequenceController {
 
    /*public static void executeBeforeInsert(List<TopicAssignment> lstNewTopicAssignments) {
    }*/
    
    /*public static void executeBeforeUpdate(Map<Id,TopicAssignment> mapOldTopicAssignments, Map<Id,TopicAssignment> mapNewTopicAssignments) {
    }*/
    
    public static void executeAfterInsert(Map<Id,TopicAssignment> mapOldTopicAssignments, Map<Id,TopicAssignment> mapNewTopicAssignments){
         new CRM_TopicAssignmentHandler().getNewTopicId(mapOldTopicAssignments, mapNewTopicAssignments);
    }
    
    /*public static void executeAfterUpdate(Map<Id,TopicAssignment> mapOldTopicAssignments, Map<Id,TopicAssignment> mapNewTopicAssignments) {
    }*/ 
    
    public static void executeAfterDelete(Map<Id,TopicAssignment> mapOldTopicAssignments, Map<Id,TopicAssignment> mapNewTopicAssignments) {
         new CRM_TopicAssignmentHandler().getOldTopicId(mapOldTopicAssignments, mapNewTopicAssignments);  
    }  
}