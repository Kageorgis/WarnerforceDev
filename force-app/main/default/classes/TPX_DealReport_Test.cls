/******* 
TPX_DealReport_Test
Creation Date- 12 July 2017
Description- This class is to do code coverage for TPX_DealReport_CC
Author- Robint
*******/
@isTest
public class TPX_DealReport_Test{
    static{
        //Creating Account "AccountTest01"
        Account acc = new Account(
                            name = 'AccountTest01', 
                            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ELLEN - Brand').getRecordTypeId()
                          );
        insert acc;
        //Creating Commitment "CorporateForecast01"
        Commitments__c Commitment = new Commitments__c(
                                    name = 'CorporateForecast01', 
                                    Digital_Integration_Fee__c = 100000,
                                    Ellentube_Fee_WAD_Agreement__c = 200000,
                                    Ellentube_Costs__c = 400000,
                                    Ellentube_Fee_Digital_IO__c = 500000,
                                    Net_Ellentube_Income__c = 600000,
                                    Heads_Up_Goal__c = 700000,
                                    Psych_Goal__c = 800000,
                                    Hot_Hands_Goal__c = 900000,
                                    Emoji_App_Goal__c = 1000000,
                                    YouTube_Goal__c = 1100000,
                                    RecordTypeId = Schema.SObjectType.Commitments__c.getRecordTypeInfosByName().get('Digital Forecast').getRecordTypeId()
                                  );
        insert Commitment;
        //Creating Opportunity "oppountTest01"
        Opportunity opp1=new Opportunity(
                                name = 'oppountTest01', 
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(), 
                                AccountId = acc.id, 
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Closed',
                                CloseDate = Date.Today(),
                                Digital_Billing_Year_Commitment__c = Commitment.id
                            );
        insert opp1;
        //Creating Opportunity "oppountTest02"
        Opportunity opp2=new Opportunity(
                                name = 'oppountTest02', 
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(), 
                                AccountId = acc.id, 
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Contract',
                                CloseDate = Date.Today(),
                                Digital_Billing_Year_Commitment__c = Commitment.id
                            );
        insert opp2;
        //Creating Opportunity "oppountTest03"
        Opportunity opp3=new Opportunity(
                                name = 'oppountTest03', 
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(), 
                                AccountId = acc.id, 
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Hot',
                                CloseDate = Date.Today(),
                                Digital_Billing_Year_Commitment__c = Commitment.id
                            );
        insert opp3;
        //Creating Opportunity "oppountTest04"
        Opportunity opp4=new Opportunity(
                                name = 'oppountTest04', 
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(), 
                                AccountId = acc.id, 
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Proposal',
                                CloseDate = Date.Today(),
                                Digital_Billing_Year_Commitment__c = Commitment.id
                            );
        insert opp4;
    }
    @isTest static void Test_TPX_DealReport(){
        Test.startTest();
        //Creating and executing constructor of the controller 'TPX_DealReport_CC'
        TPX_DealReport_CC tpxDealReport = new TPX_DealReport_CC();
        //Executing the method 'nextSeason'
        tpxDealReport.nextSeason();
        //Executing the method 'previousSeason'
        tpxDealReport.previousSeason();
        Test.stopTest();
    }
}