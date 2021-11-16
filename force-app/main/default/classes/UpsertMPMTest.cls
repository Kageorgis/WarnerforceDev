/*****************************************************************************
 * Class Name:      UpsertMPMTest
 * Description:     Test Class for UpsertMPM Web Service
 *
 * Author:          Date:          Description
 * Ishwar Kabra   12-dec-2014      First Draft 
 *****************************************************************************/
@isTest
public class UpsertMPMTest
{
  static testMethod void UpsertMPMTest_Positive()
    {
        Test.startTest();
        
        Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        insert lang;

        UpsertMPM.ReleaseDetail rd = new UpsertMPM.ReleaseDetail();
        rd.Country_2_Code = 'IN';
        rd.Theatrical_Release_Date = '2015-04-25';
        rd.TV_Airing_Date = '2015-04-20';
         
        UpsertMPM.MPMrdDetails MPMRd = new UpsertMPM.MPMrdDetails();
        MPMRd.IntegrationID = '11111111';
        MPMRd.Abstract_EIDR = 'Test EIDR';
        MPMRd.Production_Year = '2013';
        MPMRd.MPM_Number = '1234567';
        MPMRd.Film_Color = 'Green';
        MPMRd.Record_Status = 'Active';
        MPMRd.ReleaseDetailList = new list<UpsertMPM.ReleaseDetail>();
        MPMRd.ReleaseDetailList.add(rd);
        
        UpsertMPM.MPMrdDetails MPMRd1 = new UpsertMPM.MPMrdDetails();
        MPMRd1.IntegrationID = '222222';
        MPMRd1.Abstract_EIDR = 'Test EIDR';
        MPMRd1.Production_Year = '2013';
        MPMRd1.MPM_Number = '7654321';
        MPMRd1.Film_Color = 'Red';
        MPMRd1.Record_Status = 'Inactive';
        //MPMRd1.ReleaseDetailList = new list<UpsertMPM.ReleaseDetail>();
        //MPMRd1.ReleaseDetailList.add(rd);
        
        list<UpsertMPM.MPMrdDetails> MPMRdList = new list<UpsertMPM.MPMrdDetails>();
        MPMRdList.add(MPMRd);
        MPMRdList.add(MPMRd1);
        
        List<UpsertMPM.ResponseMessage> responseList = UpsertMPM.createMPMrd(MPMRdList);
        System.assertEquals(responseList[0].Message_Result, true);
        
        Test.stopTest();
    }
    
    static testMethod void UpsertMPMTest_Duplicate_MPMNumber()
    {
        Test.startTest();
        
        Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        insert lang;

        UpsertMPM.ReleaseDetail rd = new UpsertMPM.ReleaseDetail();
        rd.Country_2_Code = 'IN';
        rd.Theatrical_Release_Date = '2015-04-25';
        rd.TV_Airing_Date = '2015-04-20';
         
        UpsertMPM.MPMrdDetails MPMRd = new UpsertMPM.MPMrdDetails();
        MPMRd.IntegrationID = '11111111';
        MPMRd.Abstract_EIDR = 'Test EIDR';
        MPMRd.Production_Year = '2013';
        MPMRd.MPM_Number = '1234567';
        MPMRd.Film_Color = 'Green';
        MPMRd.Record_Status = 'Active';
        MPMRd.ReleaseDetailList = new list<UpsertMPM.ReleaseDetail>();
        MPMRd.ReleaseDetailList.add(rd);
        
        UpsertMPM.MPMrdDetails MPMRd1 = new UpsertMPM.MPMrdDetails();
        MPMRd1.IntegrationID = '222222';
        MPMRd1.Abstract_EIDR = 'Test EIDR';
        MPMRd1.Production_Year = '2013';
        MPMRd1.MPM_Number = '1234567';
        MPMRd1.Film_Color = 'Red';
        MPMRd1.Record_Status = 'Inctive';
        MPMRd1.ReleaseDetailList = new list<UpsertMPM.ReleaseDetail>();
        MPMRd1.ReleaseDetailList.add(rd);
        
        
        list<UpsertMPM.MPMrdDetails> MPMRdList = new list<UpsertMPM.MPMrdDetails>();
        MPMRdList.add(MPMRd);
        MPMRdList.add(MPMRd1);
        
        List<UpsertMPM.ResponseMessage> responseList = UpsertMPM.createMPMrd(MPMRdList);
        System.assertEquals(responseList[0].Message_Result, false);
        
        Test.stopTest();
    }
    
      static testMethod void UpsertMPMTest_CharLimit_MPMNumber()
    {
        Test.startTest();
        
        Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        insert lang;

        UpsertMPM.ReleaseDetail rd = new UpsertMPM.ReleaseDetail();
        rd.Country_2_Code = 'IN';
        rd.Theatrical_Release_Date = '2015-04-25';
        rd.TV_Airing_Date = '2015-04-20';
         
        UpsertMPM.MPMrdDetails MPMRd = new UpsertMPM.MPMrdDetails();
        MPMRd.IntegrationID = '11111111';
        MPMRd.Abstract_EIDR = 'Test EIDR';
        MPMRd.Production_Year = '2013';
        MPMRd.MPM_Number = '12345678';
        MPMRd.Film_Color = 'Green';
        MPMRd.Record_Status = 'Active';
        MPMRd.ReleaseDetailList = new list<UpsertMPM.ReleaseDetail>();
        MPMRd.ReleaseDetailList.add(rd);
        
        list<UpsertMPM.MPMrdDetails> MPMRdList = new list<UpsertMPM.MPMrdDetails>();
        MPMRdList.add(MPMRd);

        List<UpsertMPM.ResponseMessage> responseList = UpsertMPM.createMPMrd(MPMRdList);
        Error_Log__c aErrLoglst = [Select id,Error_Message__c,Invoked_Method__c from Error_Log__c];
        System.assertEquals(aErrLoglst.Error_Message__c, 'Incorrect MPM Number !');
        
        Test.stopTest();
    }
 }