public class WB_AccountRoleTriggerHandler {
    
   public void checkDuplicateAccRoles(List<Account_Role__c> ARList){
        
        Map<String,set<String>> roleMap = new Map<String,set<String>>();
        Set<String> accountSet = new Set<String>();
        Set<String> UserSet = new Set<String>();
        Set<String> roleSet = new Set<String>();
    
        for(Account_Role__c ar : ARList) //trigger.new
        {
            accountSet.add(ar.Account__c);
            UserSet.add(ar.User__c);
            for(String singleRole : ar.Role__c.split(';'))
            {
                singleRole = '\''+singleRole+'\'';
                roleSet.add(singleRole);
            }
            system.debug('*****RoleSet:'+roleSet);
        }
    
        String queryString = 'select Id, Account__c, User__c, Role__c from Account_Role__c Where Account__c = :accountSet and User__c =:userSet and Role__c includes (';
        for(String uRole : roleSet)
            queryString += uRole + ',';
        queryString = queryString.removeEnd(',') + ')';
    
        system.debug('*****QueryString:'+queryString);
       
        for(Account_Role__c ar1 : ARList)   //trigger.new
        {
            Set<String> roles1 = new Set<String>();
            roles1.addAll(ar1.Role__c.split(';'));
            
            for(Account_Role__c ar2 : (List<Account_Role__c>) Database.Query(queryString))
            {
                Set<String> roles2 = new Set<String>();
                roles2.addAll(ar2.Role__c.split(';'));
                
                if(ar1.Id != ar2.Id && ar1.Account__c == ar2.Account__c && ar1.User__c == ar2.User__c)
                {
                    roles2.retainAll(roles1);
                    if(roles2.size() != 0)
                        ar1.addError('User Already Added To Account With Selected Role');
                    
                }
            }
            
        }

    }
}