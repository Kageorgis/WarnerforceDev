@isTest
private class WB_AccountRoleTriggerTest {
	@isTest
	static void WB_AccountRole(){
	    Boolean result=false;
	    String profileName='System Administrator';
		Profile testProfile=TestUtil.initProfile(profileName);
		
		User testUser=TestUtil.initUser(testProfile.Id);
		insert testUser;
		
		Account testAccount=TestUtil.initAccount();
		insert testAccount;
		
		Account_Role__c accRoll1=new Account_Role__c(
								Account__c=testAccount.Id,
								Role__c='Announcer;Promoter',
								User__c=testUser.Id);
		insert accRoll1;
		
		Account_Role__c accRoll2=new Account_Role__c(
								Account__c=testAccount.Id,
								Role__c='Announcer',
								User__c=testUser.Id);
		try{
		    insert accRoll2;
		}
		catch(DmlException ex){
		    result=true;
		}
		
		System.assertEquals(true,result);
		
	}
}