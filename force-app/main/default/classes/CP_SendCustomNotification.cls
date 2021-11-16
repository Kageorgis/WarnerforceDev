/*============================================================================================
* @author: Ajit Singh
* @date: 13/08/2021
* @description: This class is for sending custom notification to the Forecast Approver.
=============================================================================================*/
public inherited sharing class CP_SendCustomNotification {
    
    public static void sendNotificationsToForecastOwner(String strBody, String strSenderId, String strTargetId, String strTitle, String strNotificationId, set<String> setUserIds) {
        
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        
        // Custom notification type Id
        obj.setNotificationTypeId(strNotificationId);
        
        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(strTargetId);
        
        // Notification Title
        obj.setTitle(strTitle);
        
        // Notification Body
        obj.setBody(strBody);
    
        // send used to send the notification, pass the set of user ids , Group or Queue member
        obj.send(setUserIds);
    }
}