/**
   @Author Cognizant
   @name CRM_ProcessAccountTeamMembers 
   @CreateDate 30 May 2016
   @Description This class will insert/update account team member according to Owner Games user on account
   @Version <1.0>
*/

public with sharing class CRM_ProcessAccountTeamMembers {

  
  /**
    * @Description - Method to identify the accounts and generate/update account team members
    * @name processTeamMembers
    * @param mapOldAccounts- Instance of old accounts 
    * @param mapNewAccounts- Instance of new accounts 
    * @return void
  */
  public static void processTeamMembers(Map<Id,Account> mapOldAccounts, Map<Id,Account> mapNewAccounts) {
    AccountTeamMember[] listTeamMembersToInsert = new AccountTeamMember[]{};
    AccountTeamMember[] listTeamMembersToRemove = new AccountTeamMember[]{};


    for(Account acc : mapNewAccounts.values()) {

      Account oldAccount = Trigger.isUpdate && mapOldAccounts.get(acc.Id) != null ? mapOldAccounts.get(acc.Id) : null;

      if(Trigger.isInsert || 
        (Trigger.isUpdate && acc.Owner_Games__c != oldAccount.Owner_Games__c)) {

        if(acc.Owner_Games__c != null) {
          listTeamMembersToInsert.add(
              new AccountTeamMember(AccountId = acc.Id, 
                UserId = acc.Owner_Games__c,
                TeamMemberRole = 'Games')
            );
        }

        if(oldAccount != null && oldAccount.Owner_Games__c != null) {
          listTeamMembersToRemove.add(
              new AccountTeamMember(AccountId = acc.Id, UserId = oldAccount.Owner_Games__c)
            );
        }
      }
    }

    if(!listTeamMembersToInsert.isEmpty()) {
      insertTeamMembers(listTeamMembersToInsert);

      String strTeamMembersJSON = JSON.serialize(listTeamMembersToInsert);
      updateTeamMembersShares(strTeamMembersJSON);
    }

    if(!listTeamMembersToRemove.isEmpty()) {
      removeTeamMembers(listTeamMembersToRemove);
    }
  }

  /**
    * @Description - Method to insert account team members
    * @name insertTeamMembers
    * @param listTeamMembers- List of team members to insert
    * @return void
  */
  public static void insertTeamMembers(AccountTeamMember[] listTeamMembers){
    Database.SaveResult[] insertResult = Database.insert(listTeamMembers, false);
    List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();

    for(Integer i=0; i< insertResult.size(); i++){
      if(!insertResult[i].isSuccess()) {
        CRM_ErrorLogger.ErrorLog errorLogInstance = logAnException('Insert TeamMember failed for <account|user> comibination:<'+listTeamMembers[i].AccountId + '|' + listTeamMembers[i].UserId + '> Error Description:'+insertResult[i].getErrors().get(0).getMessage());
        errorLogs.add(errorLogInstance);
        //system.debug('Insert TeamMember failed for <account|user> comibination:<'+listTeamMembers[i].AccountId + '|' + listTeamMembers[i].UserId + '> Error Description:'+insertResult[i].getErrors().get(0).getMessage());
      }
    }
    if(!errorLogs.isEmpty()){
        CRM_ErrorLogger.logError(errorLogs); 
    }
  }

  /**
    * @Description - Method to remove account team members
    * @name removeTeamMembers
    * @param listTeamMembers- List of team members to remove
    * @return void
  */
  public static void removeTeamMembers(AccountTeamMember[] listTeamMembers){
    Set<Id> setAccountIds = new Set<Id>();
    Set<Id> setUserIds = new Set<Id>();
    Set<String>  setAccountUserKey = new Set<String>();
    List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();

    for(AccountTeamMember teamMember : listTeamMembers) {
      setAccountIds.add(teamMember.AccountId);
      setUserIds.add(teamMember.UserId);

      setAccountUserKey.add(teamMember.AccountId + '_' + teamMember.UserId);
    }

    AccountTeamMember[] listTeamMembersToRemove = new AccountTeamMember[]{};

    for(AccountTeamMember teamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :setAccountIds AND UserId IN : setUserIds]) {
      if(setAccountUserKey.contains(teamMember.AccountId + '_' + teamMember.UserId)) {
        listTeamMembersToRemove.add(teamMember);
      }
    }

    if(!listTeamMembersToRemove.isEmpty()) {
      Database.DeleteResult[] deleteResult = Database.delete(listTeamMembersToRemove, false);

      for(Integer i=0; i< deleteResult.size(); i++){
        if(!deleteResult[i].isSuccess()) {
           CRM_ErrorLogger.ErrorLog errorLogInstance = logAnException('Delete TeamMember failed for <account|user> comibination:<'+listTeamMembersToRemove[i].AccountId + '|' + listTeamMembersToRemove[i].UserId + '> Error Description:'+deleteResult[i].getErrors().get(0).getMessage());
           errorLogs.add(errorLogInstance);
           //system.debug('Delete TeamMember failed for <account|user> comibination:<'+listTeamMembersToRemove[i].AccountId + '|' + listTeamMembersToRemove[i].UserId + '> Error Description:'+deleteResult[i].getErrors().get(0).getMessage());
        }
      }
      if(!errorLogs.isEmpty()){
        CRM_ErrorLogger.logError(errorLogs); 
      }
    }
  }

  /**
    * @Description - Method to update account share records
    * @name updateTeamMembersShares
    * @param listTeamMembersJSON - String of team members to update corresponding account share records
    * @return void
  */
  @Future
  public static void updateTeamMembersShares(String listTeamMembersJSON){
    AccountTeamMember[] listTeamMembers = (AccountTeamMember[])JSON.deserialize(listTeamMembersJSON, List<AccountTeamMember>.class);

    Set<Id> setAccountIds = new Set<Id>();
    Set<Id> setUserIds = new Set<Id>();
    Set<String>  setAccountUserKey = new Set<String>();
    List<CRM_ErrorLogger.ErrorLog> errorLogs = new List<CRM_ErrorLogger.ErrorLog>();

    for(AccountTeamMember teamMember : listTeamMembers) {
      setAccountIds.add(teamMember.AccountId);
      setUserIds.add(teamMember.UserId);

      setAccountUserKey.add(teamMember.AccountId + '_' + teamMember.UserId);
    }

    AccountShare[] listAccSharedToUpdate = new AccountShare[]{};

    for(AccountShare accShare : [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :setAccountIds AND UserOrGroupId IN : setUserIds AND RowCause = 'Team']) {
      if(setAccountUserKey.contains(accShare.AccountId + '_' + accShare.UserOrGroupId)) {
        accShare.AccountAccessLevel = 'Edit';
        accShare.OpportunityAccessLevel = 'Edit';
        listAccSharedToUpdate.add(accShare);
      }
    }

    if(!listAccSharedToUpdate.isEmpty()) {
      Database.SaveResult[] udpateResult = Database.update(listAccSharedToUpdate, false);
      
      for(Integer i=0; i< udpateResult.size(); i++){
        if(!udpateResult[i].isSuccess()) {
            CRM_ErrorLogger.ErrorLog errorLogInstance = logAnException('Update TeamMemberShare failed for <account|user> comibination:<'+listAccSharedToUpdate[i].AccountId + '|' + listAccSharedToUpdate[i].UserOrGroupId + '> Error Description:'+udpateResult[i].getErrors().get(0).getMessage());
            errorLogs.add(errorLogInstance);
            //system.debug('Update TeamMemberShare failed for <account|user> comibination:<'+listAccSharedToUpdate[i].AccountId + '|' + listAccSharedToUpdate[i].UserOrGroupId + '> Error Description:'+udpateResult[i].getErrors().get(0).getMessage());
        }
      }
      if(!errorLogs.isEmpty()){
        CRM_ErrorLogger.logError(errorLogs); 
      }
    }
  }
    
    /*
        *  This method will take the exception occured as an input and forward it to the common utility class. 
        *  @name: logAnException
        *  @param: String errorMessage
        *  @return: CRM_ErrorLogger.ErrorLog
    */
    public static CRM_ErrorLogger.ErrorLog logAnException(String errorMessage){
        
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        errorLogInstance.functionalModule = 'Update account team member functionality';
        errorLogInstance.className = 'CRM_ProcessAccountTeamMembers';        

        errorLogInstance.stackTrace = errorMessage;
        return errorLogInstance;
    }
    

}