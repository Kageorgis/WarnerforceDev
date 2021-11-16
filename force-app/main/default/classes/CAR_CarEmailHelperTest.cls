/*========================================================================================================
* @author: Kalash
* @date: 16/03/2021
* @description: Test class for CAR_CarEmailHelper class
==========================================================================================================*/
@isTest
public class CAR_CarEmailHelperTest {
    static testmethod void getChatterGroupNameTest(){
        List<String> requestingGroupList = new List<String>();
        List<String> distributorList = new List<String>();
        List<String> brandGroupList = new List<String>();
        List<String> chatterGroupName;
        integer i,j,k;
        requestingGroupList.add(Label.RF_SDS);
        requestingGroupList.add(Label.RF_WB_DIGITAL);
        distributorList.add(Label.RF_WB);
        distributorList.add(Label.RF_UNI);
        brandGroupList.add(Label.RF_Film);
        brandGroupList.add(Label.RF_TV);
        brandGroupList.add(Label.RF_Multi_BU);
        brandGroupList.add(Label.RF_OA_F);
        for(i=0;i<2;i++){
            for(j=0;j<2;j++){
                for(k=0;k<4;k++){
                    chatterGroupName = CAR_CarEmailHelper.getChatterGroupNameForSalesUser(requestingGroupList[i], distributorList[j], brandGroupList[k]);
                    chatterGroupName = CAR_CarEmailHelper.getChatterGroupNameForTradeUsers(requestingGroupList[i], distributorList[j], brandGroupList[k]);
                    chatterGroupName = CAR_CarEmailHelper.getChatterGroupNameForCancelledStatus(requestingGroupList[i], distributorList[j], brandGroupList[k]);
                    chatterGroupName = CAR_CarEmailHelper.getChatterGroupNameForReactivatedStatus(requestingGroupList[i], distributorList[j], brandGroupList[k]);
                }
            }
        }
        
        country__c cnt =  RF_TestUtil.countryList('USA','US','United States');
        insert cnt;
        language__c lng =  RF_TestUtil.languageList('English',1);
        insert lng;
        RF_User_Access__c useraccess = new RF_User_Access__c();
        Id userId = Userinfo.getUserId();
        useraccess.user__c = userId;
        
        useraccess.CAR_Role__c = 'Creative';
        useraccess.Requesting_Group__c = 'DIGITAL';
        useraccess.Distributor__c = 'UNI';
        insert useraccess;
        
        Car__c crs = new Car__c();
        crs.name = 'test';
        crs.Suppress_Integration__c = True;
        crs.Status__c = 'Draft';
        crs.country__c = cnt.id;
        crs.language__c = lng.id;
        insert crs;
        String emailTemplate=Label.RF_EMAIL_TEMPLATE_CAR_ASSIGNED_QUEUE;
        CAR_CarEmailHelper.sendEmailToChatterGroupMembers(chatterGroupName,crs.Id, emailTemplate, crs.Requester__c);
    }
}