/*================================================================================================================================
* @author Ajit Singh
* @date 23/02/2021
* @description: Trigger handler class for RF_Exception_Log__c which implements all the trigger events like insert,update,delete
==================================================================================================================================*/
public class RF_ExceptionLogHelper {
    
    //Update exception log field on Car layout from RF exception log
    public static void updateRFLogInCAR(List<RF_Exception_Log__c> newItems){
        system.debug('inside updateRFLogInCAR');
        for(RF_Exception_Log__c ca:newItems){
            if(ca.Object_Name__c=='CAR__c'){
                car__c carobj=new car__c();
                carobj.Exception_Log__c=ca.RF_Error_Log__c;
                carobj.id=ca.Source_ID__c;
                update carobj;
            }
        }
        
    }
    
    // US -W-017802: CAR - Send Email from Exception log
    /**---------------------- START ---------------------------*/ 
    public static void sendMail(List<RF_Exception_Log__c> newItems){
        Set<Id> carIds=new Set<Id>();
        set<Id> lstids = new set<id>();
        Set<String> emails= new Set<String>();
        for(RF_Exception_Log__c ca:newItems){
            carIds.add(ca.Source_ID__c);
        }
        List<Car__c> carObjList=[Select id,name,owner.name,Creative_Owner__c,Creative_Production_Contact__c from CAR__c where id IN:carIds];
        
        for(Car__c car:carObjList){
            lstids.add(car.Creative_Owner__c);
            lstids.add(car.Creative_Production_Contact__c);
        } 
        
        User userList=[Select id,email from User where email=:Label.RF_ArtTrack_Support LIMIT 1];
        lstids.add(userList.id);
        
        system.debug('lstids-->:'+lstids);
        EmailTemplate template=[Select id from EmailTemplate where name =:Label.RF_CAR_Exception_Email limit 1];
        
        for(RF_Exception_Log__c ca:newItems){
            if(ca.Object_Name__c=='CAR__c'){
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
                
                
                for(Id usrId :lstids) {
                    
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, usrId, ca.Source_ID__c);
                    String emailSubject = email.getSubject();
                    String emailTextBody = email.getPlainTextBody();
                    email.setTargetObjectId(usrId);
                    email.setSubject(emailSubject);
                    email.setPlainTextBody(emailTextBody);
                    email.saveAsActivity = false;
                    mails.add(email);
                    
                }
                try{
                    if(mails.size() > 0){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                        
                        if (results.size() > 0 && results[0].success) 
                        {
                            System.debug('The email was sent successfully from RF_ExceptionLogHelper to Queue members.');
                        } else {
                            
                            System.debug('The email failed to send from RF_ExceptionLogHelper to Queue members.'); 
                        }
                    }
                }
                Catch(Exception exp){
                    System.debug(exp);
                }
                
            }
        }
        
    }
    
}