/*****************************************************************************
 * Class Name:      UpsertTitlesTest
 * Description:     Test Class for UpsertTitles Web Service
 *
 * Author:          Date:          Description
 * Andrew Hilsher   11/3/2014      First Draft - 81% coverage
 * ishwar Kabra     19/12/2014      88%
 *****************************************************************************/


@isTest
public class UpsertTitlesTest
{
    static testMethod void testUpsertTitles()
    {
        Test.startTest();
        UpsertTitles.TitleDetails newtitle = new UpsertTitles.TitleDetails();
        newtitle.IDOC_Number = '123456789';
        newtitle.Title_Name = 'Hobbit';
        newtitle.Video_Version = '897654321';
        newtitle.Status = 'Active';
        newtitle.Content_Type = 'Good';
        newtitle.Production_Year = '2013';
        newtitle.Alias = 'Hob';
        newtitle.MPM_Number = '2222222';
        newtitle.MPM_Long_Desc = '123';
        newtitle.MPM_Short_Desc = '321';
        newtitle.MPM_Family_Desc = '333';
           
        List<UpsertTitles.TitleDetails> nt = new List<UpsertTitles.TitleDetails>();
        nt.add(newtitle);
        
        List<UpsertTitles.ResponseMessage> responseList = UpsertTitles.createTitle(nt);
        System.assertEquals(responseList[0].Message_Result, true);
        Test.stopTest();
    }
    
    static testMethod void testUpsertTitles2()
    {
        Test.startTest();
        
        Title__c title1 = TestUtil.initTitle('TestGoogle', '897654321');
        title1.Formats__c = 'SD';
        insert title1;
        title1.content_type__c='Feature';
        upsert title1;
        
        UpsertTitles.TitleDetails newtitle = new UpsertTitles.TitleDetails();
        newtitle.IDOC_Number = '123456789';
        newtitle.Title_Name = 'Hobbit';
        newtitle.Video_Version = '897654321';
        newtitle.Status = 'Active';
        newtitle.Content_Type = 'Good';
        newtitle.Production_Year = '2013';
        newtitle.Alias = 'Hob';
        newtitle.MPM_Number = '2222222';
        newtitle.MPM_Long_Desc = '123';
        newtitle.MPM_Short_Desc = '321';
        newtitle.MPM_Family_Desc = '333';
               
        List<UpsertTitles.TitleDetails> nt = new List<UpsertTitles.TitleDetails>();
        nt.add(newtitle);
        
        List<UpsertTitles.ResponseMessage> responseList = UpsertTitles.createTitle(nt);
        System.assertEquals(responseList[0].Message_Result, true);
        Test.stopTest();
    }
    
     //Method Added for SINC0547965
    static testMethod void testUpsertTitles3()
    {
        Test.startTest();
            MPM__c mpm1 = TestUtil.createMPM('123456');
            mpm1.MPM_Short_Desc__c = null;
            insert mpm1;
            
            Title__c title1 = TestUtil.initTitle('TestGoogle', '897654321');
            title1.Formats__c = 'SD';
            title1.content_type__c='Feature';
            title1.MPM__c = mpm1.Id;
            insert title1;
            
            UpsertTitles.TitleDetails newtitle = new UpsertTitles.TitleDetails();
            newtitle.IDOC_Number = '123456789';
            newtitle.Title_Name = 'Hobbit';
            newtitle.Video_Version = '897654321';
            newtitle.Status = 'Active';
            newtitle.Content_Type = 'Good';
            newtitle.Production_Year = '2013';
            newtitle.Alias = 'Hob';
            newtitle.MPM_Number = '123456';
            newtitle.MPM_Long_Desc = '123';
            newtitle.MPM_Short_Desc = 'Test Description';
            newtitle.MPM_Family_Desc = '333';
                   
            List<UpsertTitles.TitleDetails> nt = new List<UpsertTitles.TitleDetails>();
            nt.add(newtitle);
            
            List<UpsertTitles.ResponseMessage> responseList = UpsertTitles.createTitle(nt);
            system.debug('nt list ============<<<<<' +nt);
            System.assertEquals(responseList[0].MPM_Short_Desc, 'Test Description');
        Test.stopTest();
    }
    //Method Finish 
}