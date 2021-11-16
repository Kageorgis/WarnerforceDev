/**
* Written by: Ketan
* Description: This class is used for User Deactivation Notification functionality.
* Project: EBR <!--ER-001249-->
* Modified by: Prashant  <!--ER-007165-->
**/

public class WB_NotifyInactiveUsers {    
    public static String reminder;
    public static Integer daySinceInactive;
    public static List<User> inactiveUserslist = new List<User>();
    public static void getUsers(){
        List<User> users = [SELECT UserName,FirstName,LastName,CreatedDate,Email,Id,LastLoginDate FROM User where IsActive = True];
        List<Messaging.SingleEmailMessage> inactiveUsersEmailslist = new List<Messaging.SingleEmailMessage>();
        Id fromoweaId = getFromOWEmailAddressId(); //ER-007165
        for(User usr : users){
            Boolean isEligible = isEligibleForNotifying(usr);
            if (isEligible){
                System.debug('User with EmailID is inactive ' +String.valueOf(usr.Email));
                System.debug('daySinceInactive' + daySinceInactive);
                inactiveUsersEmailslist.add(createEmailBody(usr,fromoweaId)); //ER-007165
            }
        }
        if(inactiveUsersEmailslist.size()>0){
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(inactiveUsersEmailslist);
        }
    } 
    
    public static Boolean isEligibleForNotifying(User usr){
        Boolean res;
        if(usr.LastLoginDate == Null){
            system.debug('In isEligibleForNotifying');
            res = compareDate(usr.CreatedDate);
            
        }
        else {
            res = compareDate(usr.LastLoginDate);
        }
        
        system.debug('result for user ' + usr.userName + ' is ' + res);
        return res;
    }
    //ER-007165--Start
    public static Id getFromOWEmailAddressId(){
        Id oweaId = null;      
        string OW_EMAIL_ADDRESS = Label.WBCASSupportTeamOrgWideEmail;
       /* ER-007165--  CAS_Global_Settings__c globalConfig = CAS_Global_Settings__c.getValues('CAS Global Settings');
        OWD_EMAIL_ADDRESS= globalConfig.Global_Email__c; 
       */
        if(OW_EMAIL_ADDRESS !=null)
        {  
            List<OrgWideEmailAddress> lstOwea = new List<OrgWideEmailAddress>([SELECT Id 
                                                                               FROM OrgWideEmailAddress 
                                                                               WHERE Address=:OW_EMAIL_ADDRESS limit 1]);   
            oweaId = (lstOwea != null && lstOwea.size() > 0) ? lstOwea[0].Id : null;
        }
        return oweaId;
    }
    //ER-007165--End
    public static Messaging.SingleEmailMessage createEmailBody(User usr,Id oweaId){ 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String firstName = usr.FirstName;
        String lastName = usr.LastName;
        String subject = reminder + ' : ' + 'Your Salesforce login is about to expire ';
        String body = null;
        body = '<html>';
        body += '<body>';
        body = 'Dear ' + usr.FirstName + ' ' + usr.LastName + ', ';
        body += '<p>As part of our continued efforts to secure our WB Data and Applications we monitor and remove application access where inactivity exceeds 90 days, we inform you that your Salesforce account with' + ' ' + usr.Username + ' ' +'has been inactive for' + ' '+ daySinceInactive  + ' ' + 'days.' + '</p>';
        body += '<p>If you need to continue to use Salesforce, Please use the URL below specific to your application to login using your WB credentials. If you do not wish to continue to use, no action is required.';
 		body += '<p>For CAS, ECLM, CRMi, S2S, ELLEN TPX, GREATT APP, US Games, WBSF, WBSL.....use'+ ' ' + '<u>https://wb.my.salesforce.com/</u>' + ' ' + '.';
        body += '<p>For WBCP Bugs Bunny Licensee Portal, use'+ ' ' + '<u>https://wbpartner.force.com/CP</u>' + ' ' + '.';
        body += '<p>For RRT Application, use'+ ' ' + '<u>https://wbpartner.force.com/RRT</u>' + ' ' + '.';
        body += '<p>For CAS Vendor Portal Application, use'+ ' ' + '<u>https://wbpartner.force.com/CAS</u>' + ' ' + '.';
        body += '<p>For Mediamorph Defect Tracker Portal Application, use'+ ' ' + '<u>https://wbpartner.force.com/DefectTracker</u>' + ' ' + '.';
        body +=  System.Label.WB_Email_Signature + '</body> </html>';
        /* ER-007165--  if(owea != null)
            mail.setOrgWideEmailAddressId(owea.Id);*/
        if(oweaId != null)
            mail.setOrgWideEmailAddressId(oweaId);
        
        mail.setToAddresses(new List<String>{usr.Email});
        mail.setSubject(subject);
        mail.setHTMLBody(body);
        return mail;
    }
   public static Boolean compareDate(Datetime dt){
       Date newDate = date.newinstance(dt.year(), dt.month(), dt.day());
       Integer  diffDate = newDate.daysBetween(date.today()) ;
       Boolean result = true;
       List<Integer> differenceDays = new List<Integer>();
       List<Reminder_Settings__c> lstreminderCS = new  List<Reminder_Settings__c>();
       lstreminderCS = Reminder_Settings__c.getall().values();
        for(Reminder_Settings__c r: lstreminderCS){
            if(diffDate == Integer.valueOf(r.Days_Since__c)){
                reminder = r.Name;
                result = true;
                break;
                
            }
            else 
                result = false;
        }
        daySinceInactive = diffDate;
        return result;
    }
}