@isTest
public class TPX_OnAirTrackingController_Test{
    static{
        //Creating Account "AccountTest01"
        Account acc = new Account(
                            name = 'AccountTest01', 
                            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ELLEN - Brand').getRecordTypeId()
                          );
        insert acc;
        //Creating Commitment "CorporateForecast01"
        Commitments__c Commitment = new Commitments__c(
                                    Name = 'CorporateForecast01',
                                    On_Air_Integration_Fee__c = 200000,
                                    On_Air_Admin_Costs__c = 400000,
                                    On_Air_Production_Costs__c = 500000,
                                    Net_On_Air_Income__c = 600000,
                                    RecordTypeId = Schema.SObjectType.Commitments__c.getRecordTypeInfosByName().get('On-Air Forecast').getRecordTypeId()
                                  );
        insert Commitment;
        //Creating Opportunity "oppountTest01"
        Opportunity opp1=new Opportunity(
                                name = 'oppountTest01', 
                                AccountId = acc.id, 
                      On_Air_Integration_Fee__c = 10000,
                                Est_On_Air_Production_Cost__c = 20000,
                      Est_On_Air_Sponsorship_Cost__c = 50000,
                      Prizing_Taken_out_of_On_Air_Int_Fee__c = 25000,
                      Final_Net_On_Air_Income__c = 15000,
                      Final_On_Air_Production_Costs__c = 17000,
                      Est_Net_On_Air_Income__c = 12000,
                      Final_On_Air_Sponsorship_Cost__c = 22000,
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Closed',
                                CloseDate = Date.Today(),
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(),
                                On_Air_Billing_Season_Commitment__c = Commitment.Id
                            );
        insert opp1;
        //Creating Opportunity "oppountTest02"
        Opportunity opp2=new Opportunity(
                                name = 'oppountTest02', 
                                AccountId = acc.id, 
                                Integration_End_Date__c = Date.Today(), 
                      On_Air_Integration_Fee__c = 10000,
                                Est_On_Air_Production_Cost__c = 20000,
                      Est_On_Air_Sponsorship_Cost__c = 50000,
                      Prizing_Taken_out_of_On_Air_Int_Fee__c = 25000,
                      Final_Net_On_Air_Income__c = 15000,
                      Final_On_Air_Production_Costs__c = 17000,
                      Est_Net_On_Air_Income__c = 12000,
                      Final_On_Air_Sponsorship_Cost__c = 22000,
                                StageName = 'Contract',
                                CloseDate = Date.Today(),
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(),
                      On_Air_Billing_Season_Commitment__c=Commitment.Id
                            );
        insert opp2;
        //Creating Opportunity "oppountTest03"
        Opportunity opp3=new Opportunity(
                                name = 'oppountTest03',  
                                AccountId = acc.id, 
                      On_Air_Integration_Fee__c = 10000,
                                Est_On_Air_Production_Cost__c = 20000,
                      Est_On_Air_Sponsorship_Cost__c = 50000,
                      Prizing_Taken_out_of_On_Air_Int_Fee__c = 25000,
                      Final_Net_On_Air_Income__c = 15000,
                      Final_On_Air_Production_Costs__c = 17000,
                      Est_Net_On_Air_Income__c = 12000,
                      Final_On_Air_Sponsorship_Cost__c = 22000,
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Hot',
                                CloseDate = Date.Today(),
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(),
                      On_Air_Billing_Season_Commitment__c=Commitment.Id
                            );
        insert opp3;
        //Creating Opportunity "oppountTest04"
        Opportunity opp4=new Opportunity(
                                name = 'oppountTest04', 
                                AccountId = acc.id, 
                      On_Air_Integration_Fee__c = 10000,
                                Est_On_Air_Production_Cost__c = 20000,
                      Est_On_Air_Sponsorship_Cost__c = 50000,
                      Prizing_Taken_out_of_On_Air_Int_Fee__c = 25000,
                      Final_Net_On_Air_Income__c = 15000,
                      Final_On_Air_Production_Costs__c = 17000,
                      Est_Net_On_Air_Income__c = 12000,
                      Final_On_Air_Sponsorship_Cost__c = 22000,
                                Integration_End_Date__c = Date.Today(), 
                                StageName = 'Proposal',
                                CloseDate = Date.Today(),
                                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPX Integrations').getRecordTypeId(),
                      On_Air_Billing_Season_Commitment__c=Commitment.Id
                            );
        insert opp4;
    }
    @isTest static void Test_TPX_DealReport(){
        Test.startTest();
        //Creating and executing constructor of the controller 'TPX_DealReport_CC'
        TPX_OnAirTrackingController tpxDealReport = new TPX_OnAirTrackingController();
        //Executing the method 'nextSeason'
        tpxDealReport.nextSeason();
        //Executing the method 'previousSeason'
        tpxDealReport.previousSeason();
        Test.stopTest();
    }
}