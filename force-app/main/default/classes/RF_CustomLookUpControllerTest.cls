@isTest
public class RF_CustomLookUpControllerTest {
    static testmethod void fetchLookUpValuesTest(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        List < sObject > returnList = RF_CustomLookUpController.fetchLookUpValues('id','Account');
        System.assert(returnList != null);
    }
}