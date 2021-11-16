/*
* Controller of the TPX_DealReport page to show open and closed opportunities according to sessions.
*
* Author:          Date:           Description
* Robint         16-May-17         First Draft
*/

public class TPX_DealReport_CC{
    public Commitments__c commitment {get;set;}
    public List<Commitments__c> commitments {get;set;}
    public List<Opportunity> closedDeals {get;set;}
    public List<Opportunity> contractDeals {get;set;}
    public List<Opportunity> hotDeals {get;set;}
    public List<Opportunity> proposalDeals {get;set;}
    public Integer lastSeason {get;set;}
    public Integer seasonIndex {get;set;}
    public Double totalClosedOnAirIntegrationFee {get;set;}
    public Double totalClosedFinalOnAirSponsorshipCost {get;set;}
    public Double totalClosedFinalOnAirProductionCosts {get;set;}
    public Double totalClosedFinalNetOnAirIncome {get;set;}
    public Double totalClosedDigitalIntegrationFee {get;set;}
    public Double totalClosedEllentubeFee {get;set;}
    public Double totalClosedEllentubeFeeDigital {get;set;}
    public Double totalClosedFinalEllentubeCosts {get;set;}
    public Double totalClosedEstEllentubeCosts {get;set;}
    public Double totalClosedFinalNetEllentubeIncome {get;set;}
    public Double totalClosedYouTubeFee {get;set;}
    public Double totalClosedEstYouTubeRevenue {get;set;}
    public Double totalClosedFinalYouTubeRevenue {get;set;}
    public Double totalClosedPrizingTakenoutofOnAirIntFee {get;set;}
    public Double totalClosedBroadcastMedia {get;set;}
    // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double totalClosedHeadsUpFee {get;set;}
    public Double totalClosedFinalHeadsUpCost {get;set;}
    public Double totalClosedFinalHeadsUpNetIncome {get;set;}
    public Double totalClosedPsychFee {get;set;}
    public Double totalClosedFinalPsychCosts {get;set;}
    public Double totalClosedFinalPsychNetIncome {get;set;}
    public Double totalClosedHotHandsFee {get;set;}
    public Double totalClosedFinalHotHandsCost {get;set;}
    public Double totalClosedFinalHotHandsNetIncome {get;set;}
    public Double totalClosedEmojiAppFee {get;set;}
    public Double totalClosedFinalEmojiAppCosts {get;set;}
    public Double totalClosedFinalEmojiAppNetIncome {get;set;} */
    public Double totalClosedGamesFee {get;set;}
    public Double totalClosedFinalGamesCost {get;set;}
    public Double totalClosedFinalGamesNetIncome {get;set;}
    // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
    public Double PercentClosedDigitalIntegrationFee {get;set;}
    public Double PercentClosedEllentubeFeeWADAgreement {get;set;}
    public Double PercentClosedEstEllentubeCosts {get;set;}
    public Double PercentClosedFinalEllentubeCosts {get;set;}
    public Double PercentClosedNetEllentubeIncome {get;set;}
    public Double PercentClosedEllentubeFeeDigitalIO {get;set;}
    public Double PercentClosedYouTubeFee {get;set;}
    public Double PercentClosedEstYouTubeRevenue {get;set;}
    public Double PercentClosedFinalYouTubeRevenue {get;set;}
    // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double PercentClosedHeadsUpGoal {get;set;}
    public Double PercentClosedPsychGoal {get;set;}
    public Double PercentClosedHotHandsGoal {get;set;}
    public Double PercentClosedEmojiAppGoal {get;set;}*/
    public Double PercentClosedGamesGoal {get;set;}
    // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + END
    public Double totalContractOnAirIntegrationFee {get;set;}
    public Double totalContractFinalOnAirSponsorshipCost {get;set;}
    public Double totalContractFinalOnAirProductionCosts {get;set;}
    public Double totalContractFinalNetOnAirIncome {get;set;}
    public Double totalContractDigitalIntegrationFee {get;set;}
    public Double totalContractEllentubeFee {get;set;}
    public Double totalContractEllentubeFeeDigital {get;set;}
    public Double totalContractFinalEllentubeCosts {get;set;}
    public Double totalContractEstEllentubeCosts {get;set;}
    public Double totalContractFinalNetEllentubeIncome {get;set;}
    public Double totalContractYouTubeFee {get;set;}
    public Double totalContractEstYouTubeRevenue {get;set;}
    public Double totalContractFinalYouTubeRevenue {get;set;}
    public Double totalContractPrizingTakenoutofOnAirIntFee {get;set;}
    public Double totalContractBroadcastMedia {get;set;}
    // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double totalContractHeadsUpFee {get;set;}
    public Double totalContractFinalHeadsUpCost {get;set;}
    public Double totalContractFinalHeadsUpNetIncome {get;set;}
    public Double totalContractPsychFee {get;set;}
    public Double totalContractFinalPsychCosts {get;set;}
    public Double totalContractFinalPsychNetIncome {get;set;}
    public Double totalContractHotHandsFee {get;set;}
    public Double totalContractFinalHotHandsCost {get;set;}
    public Double totalContractFinalHotHandsNetIncome {get;set;}
    public Double totalContractEmojiAppFee {get;set;}
    public Double totalContractFinalEmojiAppCosts {get;set;}
    public Double totalContractFinalEmojiAppNetIncome {get;set;}*/
    public Double totalContractGamesFee {get;set;}
    public Double totalContractFinalGamesCost {get;set;}
    public Double totalContractFinalGamesNetIncome {get;set;}
    // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
    public Double totalHotOnAirIntegrationFee {get;set;}
    public Double totalHotFinalOnAirSponsorshipCost {get;set;}
    public Double totalHotFinalOnAirProductionCosts {get;set;}
    public Double totalHotFinalNetOnAirIncome {get;set;}
    public Double totalHotDigitalIntegrationFee {get;set;}
    public Double totalHotEllentubeFee {get;set;}
    public Double totalHotEllentubeFeeDigital {get;set;}
    public Double totalHotFinalEllentubeCosts {get;set;}
    public Double totalHotEstEllentubeCosts {get;set;}
    public Double totalHotFinalNetEllentubeIncome {get;set;}
    public Double totalHotYouTubeFee {get;set;}
    public Double totalHotEstYouTubeRevenue {get;set;}
    public Double totalHotFinalYouTubeRevenue {get;set;}
    public Double totalHotPrizingTakenoutofOnAirIntFee {get;set;}
    public Double totalHotBroadcastMedia {get;set;}
    // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double totalHotHeadsUpFee {get;set;}
    public Double totalHotFinalHeadsUpCost {get;set;}
    public Double totalHotFinalHeadsUpNetIncome {get;set;}
    public Double totalHotPsychFee {get;set;}
    public Double totalHotFinalPsychCosts {get;set;}
    public Double totalHotFinalPsychNetIncome {get;set;}
    public Double totalHotHotHandsFee {get;set;}
    public Double totalHotFinalHotHandsCost {get;set;}
    public Double totalHotFinalHotHandsNetIncome {get;set;}
    public Double totalHotEmojiAppFee {get;set;}
    public Double totalHotFinalEmojiAppCosts {get;set;}
    public Double totalHotFinalEmojiAppNetIncome {get;set;}*/
    public Double totalHotGamesFee {get;set;}
    public Double totalHotFinalGamesCost {get;set;}
    public Double totalHotFinalGamesNetIncome {get;set;}
// Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
    public Double totalProposalOnAirIntegrationFee {get;set;}
    public Double totalProposalFinalOnAirSponsorshipCost {get;set;}
    public Double totalProposalFinalOnAirProductionCosts {get;set;}
    public Double totalProposalFinalNetOnAirIncome {get;set;}
    public Double totalProposalDigitalIntegrationFee {get;set;}
    public Double totalProposalEllentubeFee {get;set;}
    public Double totalProposalEllentubeFeeDigital {get;set;}
    public Double totalProposalFinalEllentubeCosts {get;set;}
    public Double totalProposalEstEllentubeCosts {get;set;}
    public Double totalProposalFinalNetEllentubeIncome {get;set;}
    public Double totalProposalYouTubeFee {get;set;}
    public Double totalProposalEstYouTubeRevenue {get;set;}
    public Double totalProposalFinalYouTubeRevenue {get;set;}
    public Double totalProposalPrizingTakenoutofOnAirIntFee {get;set;}
    public Double totalProposalBroadcastMedia {get;set;}
    // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double totalProposalHeadsUpFee {get;set;}
    public Double totalProposalFinalHeadsUpCost {get;set;}
    public Double totalProposalFinalHeadsUpNetIncome {get;set;}
    public Double totalProposalPsychFee {get;set;}
    public Double totalProposalFinalPsychCosts {get;set;}
    public Double totalProposalFinalPsychNetIncome {get;set;}
    public Double totalProposalHotHandsFee {get;set;}
    public Double totalProposalFinalHotHandsCost {get;set;}
    public Double totalProposalFinalHotHandsNetIncome {get;set;}
    public Double totalProposalEmojiAppFee {get;set;}
    public Double totalProposalFinalEmojiAppCosts {get;set;}
    public Double totalProposalFinalEmojiAppNetIncome {get;set;}*/
    public Double totalProposalGamesFee {get;set;}
    public Double totalProposalFinalGamesCost {get;set;}
    public Double totalProposalFinalGamesNetIncome {get;set;}
    // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
    public Double totalOpenGrossIntegrationFee {get;set;}
    public Double totalOpenOnAirIntegrationFee {get;set;}
    public Double totalOpenFinalOnAirSponsorshipCost {get;set;}
    public Double totalOpenFinalOnAirProductionCosts {get;set;}
    public Double totalOpenFinalNetOnAirIncome {get;set;}
    public Double totalOpenDigitalIntegrationFee {get;set;}
    public Double totalOpenEllentubeFee {get;set;}
    public Double totalOpenEllentubeFeeDigital {get;set;}
    public Double totalOpenFinalEllentubeCosts {get;set;}
    public Double totalOpenEstEllentubeCosts {get;set;}
    public Double totalOpenFinalNetEllentubeIncome {get;set;}
    public Double totalOpenYouTubeFee {get;set;}
    public Double totalOpenEstYouTubeRevenue {get;set;}
    public Double totalOpenFinalYouTubeRevenue {get;set;}
    public Double totalOpenPrizingTakenoutofOnAirIntFee {get;set;}
    public Double totalOpenBroadcastMedia {get;set;}
    // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double totalOpenHeadsUpFee {get;set;}
    public Double totalOpenFinalHeadsUpCost {get;set;}
    public Double totalOpenFinalHeadsUpNetIncome {get;set;}
    public Double totalOpenPsychFee {get;set;}
    public Double totalOpenFinalPsychCosts {get;set;}
    public Double totalOpenFinalPsychNetIncome {get;set;}
    public Double totalOpenHotHandsFee {get;set;}
    public Double totalOpenFinalHotHandsCost {get;set;}
    public Double totalOpenFinalHotHandsNetIncome {get;set;}
    public Double totalOpenEmojiAppFee {get;set;}
    public Double totalOpenFinalEmojiAppCosts {get;set;}
    public Double totalOpenFinalEmojiAppNetIncome {get;set;}*/
    public Double totalOpenGamesFee {get;set;}
    public Double totalOpenFinalGamesCost {get;set;}
    public Double totalOpenFinalGamesNetIncome {get;set;}
    // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + end
    public Double PercentOpenDigitalIntegrationFee {get;set;}
    public Double PercentOpenEllentubeFeeWADAgreement {get;set;}
    public Double PercentOpenEstEllentubeCosts {get;set;}
    public Double PercentOpenFinalEllentubeCosts {get;set;}
    public Double PercentOpenNetEllentubeIncome {get;set;}
    public Double PercentOpenEllentubeFeeDigitalIO {get;set;}
    public Double PercentOpenYouTubeFee {get;set;}
    public Double PercentOpenEstYouTubeRevenue {get;set;}
    public Double PercentOpenFinalYouTubeRevenue {get;set;}
    // Code Modified by Mayank Desai on 03/26/2019 for ER-002310_TPX_GamesRollup + Start
    /*public Double PercentOpenHeadsUpGoal {get;set;}
    public Double PercentOpenPsychGoal {get;set;}
    public Double PercentOpenHotHandsGoal {get;set;}
    public Double PercentOpenEmojiAppGoal {get;set;}*/
    public Double PercentOpenGamesGoal {get;set;}
    // Code Modified by Mayank Desai on 03/26/2019 for ER-002310_TPX_GamesRollup + END
    //Class constructor
    public TPX_DealReport_CC(){
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('seasonIndex'))) seasonIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('seasonIndex'));
        else seasonIndex = 0;
        getSeasons();
        getDeals();
    }
    //Method to get open and closed deals and the Corporate Forecast
    public void getDeals(){
        commitment = new Commitments__c();
        if(!commitments.isEmpty()) commitment = commitments[seasonIndex];
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
        /* closedDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                        Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                        Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, Heads_Up_Fee__c, Final_Heads_Up_Cost__c, 
                        Final_Heads_Up_Net_Income__c, Psych_Fee__c, Final_Psych_Costs__c, Final_Psych_Net_Income__c, Hot_Hands_Fee__c, Final_Hot_Hands_Cost__c, Final_Hot_Hands_Net_Income__c, Emoji_App_Fee__c, 
                        Final_Emoji_App_Costs__c, Final_Emoji_App_Net_Income__c, Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                        from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Closed'];*/
        closedDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                        Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                        Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, 
                        Games_Fee__c, Final_Games_Cost__c, Final_Games_Net_Income__c, 
                        Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                        from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Closed'];          
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
        totalClosedOnAirIntegrationFee = 0;
        totalClosedFinalOnAirSponsorshipCost = 0;
        totalClosedFinalOnAirProductionCosts = 0;
        totalClosedFinalNetOnAirIncome = 0;
        totalClosedDigitalIntegrationFee = 0;
        totalClosedEllentubeFee = 0;
        totalClosedEllentubeFeeDigital = 0;
        totalClosedFinalEllentubeCosts = 0;
        totalClosedEstEllentubeCosts = 0;
        totalClosedFinalNetEllentubeIncome = 0;
        totalClosedYouTubeFee = 0;
        totalClosedEstYouTubeRevenue = 0;
        totalClosedFinalYouTubeRevenue = 0;
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
        /*totalClosedHeadsUpFee = 0;
        totalClosedFinalHeadsUpCost = 0;
        totalClosedFinalHeadsUpNetIncome = 0;
        totalClosedPsychFee = 0;
        totalClosedFinalPsychCosts = 0;
        totalClosedFinalPsychNetIncome = 0;
        totalClosedHotHandsFee = 0;
        totalClosedFinalHotHandsCost = 0;
        totalClosedFinalHotHandsNetIncome = 0;
        totalClosedEmojiAppFee = 0;
        totalClosedFinalEmojiAppCosts = 0;
        totalClosedFinalEmojiAppNetIncome = 0;*/
        totalClosedGamesFee =0;
        totalClosedFinalGamesCost=0;
        totalClosedFinalGamesNetIncome=0;
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
        
        totalClosedPrizingTakenoutofOnAirIntFee = 0;        
        totalClosedBroadcastMedia = 0;        
        for(Opportunity closedDeal:closedDeals){
            if(closedDeal.On_Air_Integration_Fee__c!=null) totalClosedOnAirIntegrationFee += closedDeal.On_Air_Integration_Fee__c;
            if(closedDeal.Final_On_Air_Sponsorship_Cost__c!=null) totalClosedFinalOnAirSponsorshipCost += closedDeal.Final_On_Air_Sponsorship_Cost__c;
            if(closedDeal.Final_On_Air_Production_Costs__c!=null) totalClosedFinalOnAirProductionCosts += closedDeal.Final_On_Air_Production_Costs__c;
            if(closedDeal.Final_Net_On_Air_Income__c!=null) totalClosedFinalNetOnAirIncome += closedDeal.Final_Net_On_Air_Income__c;
            if(closedDeal.Digital_Integration_Fee__c!=null) totalClosedDigitalIntegrationFee += closedDeal.Digital_Integration_Fee__c;
            if(closedDeal.Ellentube_Fee__c!=null && closedDeal.How_is_Digital_Being_Paid__c=='Digital IO') totalClosedEllentubeFeeDigital += closedDeal.Ellentube_Fee__c;
            else if(closedDeal.Ellentube_Fee__c!=null) totalClosedEllentubeFee += closedDeal.Ellentube_Fee__c;
            if(closedDeal.Est_Ellentube_Costs__c!=null) totalClosedEstEllentubeCosts += closedDeal.Est_Ellentube_Costs__c;
            if(closedDeal.Final_Ellentube_Costs__c!=null) totalClosedFinalEllentubeCosts += closedDeal.Final_Ellentube_Costs__c;
            if(closedDeal.Final_Net_Ellentube_Income__c!=null) totalClosedFinalNetEllentubeIncome += closedDeal.Final_Net_Ellentube_Income__c;
            if(closedDeal.YouTube_Fee__c!=null) totalClosedYouTubeFee += closedDeal.YouTube_Fee__c;
            if(closedDeal.Est_YouTube_Revenue__c!=null) totalClosedEstYouTubeRevenue += closedDeal.Est_YouTube_Revenue__c;
            if(closedDeal.Final_YouTube_Revenue__c!=null) totalClosedFinalYouTubeRevenue += closedDeal.Final_YouTube_Revenue__c;
            // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
            /*if(closedDeal.Heads_Up_Fee__c!=null) totalClosedHeadsUpFee += closedDeal.Heads_Up_Fee__c;
            if(closedDeal.Final_Heads_Up_Cost__c!=null) totalClosedFinalHeadsUpCost += closedDeal.Final_Heads_Up_Cost__c;
            if(closedDeal.Final_Heads_Up_Net_Income__c!=null) totalClosedFinalHeadsUpNetIncome += closedDeal.Final_Heads_Up_Net_Income__c;
            if(closedDeal.Psych_Fee__c!=null) totalClosedPsychFee += closedDeal.Psych_Fee__c;
            if(closedDeal.Final_Psych_Costs__c!=null) totalClosedFinalPsychCosts += closedDeal.Final_Psych_Costs__c;
            if(closedDeal.Final_Psych_Net_Income__c!=null) totalClosedFinalPsychNetIncome += closedDeal.Final_Psych_Net_Income__c;
            if(closedDeal.Hot_Hands_Fee__c!=null) totalClosedHotHandsFee += closedDeal.Hot_Hands_Fee__c;
            if(closedDeal.Final_Hot_Hands_Cost__c!=null) totalClosedFinalHotHandsCost += closedDeal.Final_Hot_Hands_Cost__c;
            if(closedDeal.Final_Hot_Hands_Net_Income__c!=null) totalClosedFinalHotHandsNetIncome += closedDeal.Final_Hot_Hands_Net_Income__c;
            if(closedDeal.Emoji_App_Fee__c!=null) totalClosedEmojiAppFee += closedDeal.Emoji_App_Fee__c;
            if(closedDeal.Final_Emoji_App_Costs__c!=null) totalClosedFinalEmojiAppCosts += closedDeal.Final_Emoji_App_Costs__c;
            if(closedDeal.Final_Emoji_App_Net_Income__c!=null) totalClosedFinalEmojiAppNetIncome += closedDeal.Final_Emoji_App_Net_Income__c;*/
            if(closedDeal.Games_Fee__c!=null) totalClosedGamesFee += closedDeal.Games_Fee__c;
            if(closedDeal.Final_Games_Cost__c!=null) totalClosedFinalGamesCost += closedDeal.Final_Games_Cost__c;
            if(closedDeal.Final_Games_Net_Income__c!=null) totalClosedFinalGamesNetIncome += closedDeal.Final_Games_Net_Income__c;
            // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
            if(closedDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null) totalClosedPrizingTakenoutofOnAirIntFee += closedDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            if(closedDeal.Broadcast_Media__c!=null) totalClosedBroadcastMedia += closedDeal.Broadcast_Media__c;
        }
        PercentClosedDigitalIntegrationFee = commitment.Digital_Integration_Fee__c != null && commitment.Digital_Integration_Fee__c!= 0 ? totalClosedDigitalIntegrationFee*100/commitment.Digital_Integration_Fee__c : null;        
        PercentClosedEllentubeFeeWADAgreement = commitment.Ellentube_Fee_WAD_Agreement__c != null && commitment.Ellentube_Fee_WAD_Agreement__c!= 0 ? totalClosedEllentubeFee*100/commitment.Ellentube_Fee_WAD_Agreement__c : null;        
        PercentClosedEstEllentubeCosts = commitment.Ellentube_Costs__c != null && commitment.Ellentube_Costs__c!= 0 ? totalClosedEstEllentubeCosts*100/commitment.Ellentube_Costs__c : null;        
        PercentClosedFinalEllentubeCosts = commitment.Ellentube_Costs__c != null && commitment.Ellentube_Costs__c!= 0 ? totalClosedFinalEllentubeCosts*100/commitment.Ellentube_Costs__c : null;        
        PercentClosedNetEllentubeIncome = commitment.Net_Ellentube_Income__c != null && commitment.Net_Ellentube_Income__c!= 0 ? totalClosedFinalNetEllentubeIncome*100/commitment.Net_Ellentube_Income__c : null;        
        PercentClosedEllentubeFeeDigitalIO = commitment.Ellentube_Fee_Digital_IO__c != null && commitment.Ellentube_Fee_Digital_IO__c!= 0 ? totalClosedEllentubeFeeDigital*100/commitment.Ellentube_Fee_Digital_IO__c : null;        
        PercentClosedYouTubeFee = commitment.YouTube_Goal__c != null && commitment.YouTube_Goal__c!= 0 ? totalClosedYouTubeFee*100/commitment.YouTube_Goal__c : null;        
        PercentClosedEstYouTubeRevenue = commitment.YouTube_Goal__c != null && commitment.YouTube_Goal__c!= 0 ? totalClosedEstYouTubeRevenue*100/commitment.YouTube_Goal__c : null;        
        PercentClosedFinalYouTubeRevenue = commitment.YouTube_Goal__c != null && commitment.YouTube_Goal__c!= 0 ? totalClosedFinalYouTubeRevenue*100/commitment.YouTube_Goal__c : null;        
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + START
        /*PercentClosedHeadsUpGoal = commitment.Heads_Up_Goal__c != null && commitment.Heads_Up_Goal__c!= 0 ? totalClosedHeadsUpFee*100/commitment.Heads_Up_Goal__c : null;        
        PercentClosedPsychGoal = commitment.Psych_Goal__c != null && commitment.Psych_Goal__c!= 0 ? totalClosedPsychFee*100/commitment.Psych_Goal__c : null;        
        PercentClosedHotHandsGoal = commitment.Hot_Hands_Goal__c != null && commitment.Hot_Hands_Goal__c!= 0 ? totalClosedHotHandsFee*100/commitment.Hot_Hands_Goal__c : null;
        PercentClosedEmojiAppGoal = commitment.Emoji_App_Goal__c != null && commitment.Emoji_App_Goal__c!= 0 ? totalClosedEmojiAppFee*100/commitment.Emoji_App_Goal__c : null;*/
        PercentClosedGamesGoal = commitment.Games_Goal__c != null && commitment.Games_Goal__c != 0 ? totalClosedGamesFee*100/commitment.Games_Goal__c : null;
        //----------Need Review-------;
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End

        totalContractOnAirIntegrationFee = 0;
        totalContractFinalOnAirSponsorshipCost = 0;
        totalContractFinalOnAirProductionCosts = 0;
        totalContractFinalNetOnAirIncome = 0;
        totalContractDigitalIntegrationFee = 0;
        totalContractEllentubeFee = 0;
        totalContractEllentubeFeeDigital = 0;
        totalContractFinalEllentubeCosts = 0;
        totalContractEstEllentubeCosts = 0;
        totalContractFinalNetEllentubeIncome = 0;
        totalContractYouTubeFee = 0;
        totalContractEstYouTubeRevenue = 0;
        totalContractFinalYouTubeRevenue = 0;
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
        /*totalContractHeadsUpFee = 0;
        totalContractFinalHeadsUpCost = 0;
        totalContractFinalHeadsUpNetIncome = 0;
        totalContractPsychFee = 0;
        totalContractFinalPsychCosts = 0;
        totalContractFinalPsychNetIncome = 0;
        totalContractHotHandsFee = 0;
        totalContractFinalHotHandsCost = 0;
        totalContractFinalHotHandsNetIncome = 0;
        totalContractEmojiAppFee = 0;
        totalContractFinalEmojiAppCosts = 0;
        totalContractFinalEmojiAppNetIncome = 0;*/
        totalContractGamesFee=0;
        totalContractFinalGamesCost =0;
        totalContractFinalGamesNetIncome =0;
        // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
        totalContractPrizingTakenoutofOnAirIntFee = 0;        
        totalContractBroadcastMedia = 0;        
        /*contractDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, Heads_Up_Fee__c, Final_Heads_Up_Cost__c, 
                    Final_Heads_Up_Net_Income__c, Psych_Fee__c, Final_Psych_Costs__c, Final_Psych_Net_Income__c, Hot_Hands_Fee__c, Final_Hot_Hands_Cost__c, Final_Hot_Hands_Net_Income__c, Emoji_App_Fee__c, 
                    Final_Emoji_App_Costs__c, Final_Emoji_App_Net_Income__c, Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Contract'];*/
        contractDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c,
                    Games_Fee__c, Final_Games_Cost__c, Final_Games_Net_Income__c,
                    Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Contract'];
        for(Opportunity contractDeal:contractDeals){
            if(contractDeal.On_Air_Integration_Fee__c!=null) totalContractOnAirIntegrationFee += contractDeal.On_Air_Integration_Fee__c;
            if(contractDeal.Final_On_Air_Sponsorship_Cost__c!=null) totalContractFinalOnAirSponsorshipCost += contractDeal.Final_On_Air_Sponsorship_Cost__c;
            if(contractDeal.Final_On_Air_Production_Costs__c!=null) totalContractFinalOnAirProductionCosts += contractDeal.Final_On_Air_Production_Costs__c;
            if(contractDeal.Final_Net_On_Air_Income__c!=null) totalContractFinalNetOnAirIncome += contractDeal.Final_Net_On_Air_Income__c;
            if(contractDeal.Digital_Integration_Fee__c!=null) totalContractDigitalIntegrationFee += contractDeal.Digital_Integration_Fee__c;
            if(contractDeal.Ellentube_Fee__c!=null && contractDeal.How_is_Digital_Being_Paid__c=='Digital IO') totalcontractEllentubeFeeDigital += contractDeal.Ellentube_Fee__c;
            else if(contractDeal.Ellentube_Fee__c!=null) totalcontractEllentubeFee += contractDeal.Ellentube_Fee__c;
            if(contractDeal.Est_Ellentube_Costs__c!=null) totalContractEstEllentubeCosts += contractDeal.Est_Ellentube_Costs__c;
            if(contractDeal.Final_Ellentube_Costs__c!=null) totalContractFinalEllentubeCosts += contractDeal.Final_Ellentube_Costs__c;
            if(contractDeal.Final_Net_Ellentube_Income__c!=null) totalContractFinalNetEllentubeIncome += contractDeal.Final_Net_Ellentube_Income__c;
            if(contractDeal.YouTube_Fee__c!=null) totalContractYouTubeFee += contractDeal.YouTube_Fee__c;
            if(contractDeal.Est_YouTube_Revenue__c!=null) totalContractEstYouTubeRevenue += contractDeal.Est_YouTube_Revenue__c;
            if(contractDeal.Final_YouTube_Revenue__c!=null) totalContractFinalYouTubeRevenue += contractDeal.Final_YouTube_Revenue__c;
            
            // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + Start
            /*if(contractDeal.Heads_Up_Fee__c!=null) totalContractHeadsUpFee += contractDeal.Heads_Up_Fee__c;
            if(contractDeal.Final_Heads_Up_Cost__c!=null) totalContractFinalHeadsUpCost += contractDeal.Final_Heads_Up_Cost__c;
            if(contractDeal.Final_Heads_Up_Net_Income__c!=null) totalContractFinalHeadsUpNetIncome += contractDeal.Final_Heads_Up_Net_Income__c;
            if(contractDeal.Psych_Fee__c!=null) totalClosedPsychFee += contractDeal.Psych_Fee__c;
            if(contractDeal.Final_Psych_Costs__c!=null) totalClosedFinalPsychCosts += contractDeal.Final_Psych_Costs__c;
            if(contractDeal.Final_Psych_Net_Income__c!=null) totalClosedFinalPsychNetIncome += contractDeal.Final_Psych_Net_Income__c;
            if(contractDeal.Hot_Hands_Fee__c!=null) totalClosedHotHandsFee += contractDeal.Hot_Hands_Fee__c;
            if(contractDeal.Final_Hot_Hands_Cost__c!=null) totalClosedFinalHotHandsCost += contractDeal.Final_Hot_Hands_Cost__c;
            if(contractDeal.Final_Hot_Hands_Net_Income__c!=null) totalClosedFinalHotHandsNetIncome += contractDeal.Final_Hot_Hands_Net_Income__c;
            if(contractDeal.Emoji_App_Fee__c!=null) totalClosedEmojiAppFee += contractDeal.Emoji_App_Fee__c;
            if(contractDeal.Final_Emoji_App_Costs__c!=null) totalClosedFinalEmojiAppCosts += contractDeal.Final_Emoji_App_Costs__c;
            if(contractDeal.Final_Emoji_App_Net_Income__c!=null) totalClosedFinalEmojiAppNetIncome += contractDeal.Final_Emoji_App_Net_Income__c;*/
            if(contractDeal.Games_Fee__c!=null) totalContractGamesFee += contractDeal.Games_Fee__c;
            if(contractDeal.Final_Games_Cost__c!=null) totalContractFinalGamesCost += contractDeal.Final_Games_Cost__c;
            if(contractDeal.Final_Games_Net_Income__c!=null) totalContractFinalGamesNetIncome += contractDeal.Final_Games_Net_Income__c;
            // Code Modified by Mayank Desai on 03/19/2019 for ER-002310_TPX_GamesRollup + End
            if(contractDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null) totalContractPrizingTakenoutofOnAirIntFee += contractDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            if(contractDeal.Broadcast_Media__c!=null) totalContractBroadcastMedia += contractDeal.Broadcast_Media__c;
        }
        totalHotOnAirIntegrationFee = 0;
        totalHotFinalOnAirSponsorshipCost = 0;
        totalHotFinalOnAirProductionCosts = 0;
        totalHotFinalNetOnAirIncome = 0;
        totalHotDigitalIntegrationFee = 0;
        totalHotEllentubeFee = 0;
        totalHotEllentubeFeeDigital = 0;
        totalHotFinalEllentubeCosts = 0;
        totalHotEstEllentubeCosts = 0;
        totalHotFinalNetEllentubeIncome = 0;
        totalHotYouTubeFee = 0;
        totalHotEstYouTubeRevenue = 0;
        totalHotFinalYouTubeRevenue = 0;
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
        /*totalHotHeadsUpFee = 0;
        totalHotFinalHeadsUpCost = 0;
        totalHotFinalHeadsUpNetIncome = 0;
        totalHotPsychFee = 0;
        totalHotFinalPsychCosts = 0;
        totalHotFinalPsychNetIncome = 0;
        totalHotHotHandsFee = 0;
        totalHotFinalHotHandsCost = 0;
        totalHotFinalHotHandsNetIncome = 0;
        totalHotEmojiAppFee = 0;
        totalHotFinalEmojiAppCosts = 0;
        totalHotFinalEmojiAppNetIncome = 0;*/
        totalHotGamesFee=0;
        totalHotFinalGamesCost=0;
        totalHotFinalGamesNetIncome=0;
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
        totalHotPrizingTakenoutofOnAirIntFee = 0;        
        totalHotBroadcastMedia = 0;    
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
        /*hotDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, Heads_Up_Fee__c, Final_Heads_Up_Cost__c, 
                    Final_Heads_Up_Net_Income__c, Psych_Fee__c, Final_Psych_Costs__c, Final_Psych_Net_Income__c, Hot_Hands_Fee__c, Final_Hot_Hands_Cost__c, Final_Hot_Hands_Net_Income__c, Emoji_App_Fee__c, 
                    Final_Emoji_App_Costs__c, Final_Emoji_App_Net_Income__c, Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Hot'];*/
        hotDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, 
                    Games_Fee__c, Final_Games_Cost__c, Final_Games_Net_Income__c,
                    Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Hot'];
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + End
        for(Opportunity hotDeal:hotDeals){
            if(hotDeal.On_Air_Integration_Fee__c!=null) totalHotOnAirIntegrationFee += hotDeal.On_Air_Integration_Fee__c;
            if(hotDeal.Final_On_Air_Sponsorship_Cost__c!=null) totalHotFinalOnAirSponsorshipCost += hotDeal.Final_On_Air_Sponsorship_Cost__c;
            if(hotDeal.Final_On_Air_Production_Costs__c!=null) totalHotFinalOnAirProductionCosts += hotDeal.Final_On_Air_Production_Costs__c;
            if(hotDeal.Final_Net_On_Air_Income__c!=null) totalHotFinalNetOnAirIncome += hotDeal.Final_Net_On_Air_Income__c;
            if(hotDeal.Digital_Integration_Fee__c!=null) totalHotDigitalIntegrationFee += hotDeal.Digital_Integration_Fee__c;
            if(hotDeal.Ellentube_Fee__c!=null && hotDeal.How_is_Digital_Being_Paid__c=='Digital IO') totalhotEllentubeFeeDigital += hotDeal.Ellentube_Fee__c;
            else if(hotDeal.Ellentube_Fee__c!=null) totalhotEllentubeFee += hotDeal.Ellentube_Fee__c;
            if(hotDeal.Est_Ellentube_Costs__c!=null) totalHotEstEllentubeCosts += hotDeal.Est_Ellentube_Costs__c;
            if(hotDeal.Final_Ellentube_Costs__c!=null) totalHotFinalEllentubeCosts += hotDeal.Final_Ellentube_Costs__c;
            if(hotDeal.Final_Net_Ellentube_Income__c!=null) totalHotFinalNetEllentubeIncome += hotDeal.Final_Net_Ellentube_Income__c;
            if(hotDeal.YouTube_Fee__c!=null) totalHotYouTubeFee += hotDeal.YouTube_Fee__c;
            if(hotDeal.Est_YouTube_Revenue__c!=null) totalHotEstYouTubeRevenue += hotDeal.Est_YouTube_Revenue__c;
            if(hotDeal.Final_YouTube_Revenue__c!=null) totalHotFinalYouTubeRevenue += hotDeal.Final_YouTube_Revenue__c;
            // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
            /*if(hotDeal.Heads_Up_Fee__c!=null) totalHotHeadsUpFee += hotDeal.Heads_Up_Fee__c;
            if(hotDeal.Final_Heads_Up_Cost__c!=null) totalHotFinalHeadsUpCost += hotDeal.Final_Heads_Up_Cost__c;
            if(hotDeal.Final_Heads_Up_Net_Income__c!=null) totalHotFinalHeadsUpNetIncome += hotDeal.Final_Heads_Up_Net_Income__c;
            if(hotDeal.Psych_Fee__c!=null) totalClosedPsychFee += hotDeal.Psych_Fee__c;
            if(hotDeal.Final_Psych_Costs__c!=null) totalClosedFinalPsychCosts += hotDeal.Final_Psych_Costs__c;
            if(hotDeal.Final_Psych_Net_Income__c!=null) totalClosedFinalPsychNetIncome += hotDeal.Final_Psych_Net_Income__c;
            if(hotDeal.Hot_Hands_Fee__c!=null) totalClosedHotHandsFee += hotDeal.Hot_Hands_Fee__c;
            if(hotDeal.Final_Hot_Hands_Cost__c!=null) totalClosedFinalHotHandsCost += hotDeal.Final_Hot_Hands_Cost__c;
            if(hotDeal.Final_Hot_Hands_Net_Income__c!=null) totalClosedFinalHotHandsNetIncome += hotDeal.Final_Hot_Hands_Net_Income__c;
            if(hotDeal.Emoji_App_Fee__c!=null) totalClosedEmojiAppFee += hotDeal.Emoji_App_Fee__c;
            if(hotDeal.Final_Emoji_App_Costs__c!=null) totalClosedFinalEmojiAppCosts += hotDeal.Final_Emoji_App_Costs__c;
            if(hotDeal.Final_Emoji_App_Net_Income__c!=null) totalClosedFinalEmojiAppNetIncome += hotDeal.Final_Emoji_App_Net_Income__c;*/
            if(hotDeal.Games_Fee__c!=null) totalHotGamesFee += hotDeal.Games_Fee__c;
            if(hotDeal.Final_Games_Cost__c!=null) totalHotFinalGamesCost += hotDeal.Final_Games_Cost__c;
            if(hotDeal.Final_Games_Net_Income__c!=null) totalHotFinalGamesNetIncome += hotDeal.Final_Games_Net_Income__c;
            // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + End
            
            if(hotDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null) totalHotPrizingTakenoutofOnAirIntFee += hotDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            if(hotDeal.Broadcast_Media__c!=null) totalHotBroadcastMedia += hotDeal.Broadcast_Media__c;
        }
        totalProposalOnAirIntegrationFee = 0;
        totalProposalFinalOnAirSponsorshipCost = 0;
        totalProposalFinalOnAirProductionCosts = 0;
        totalProposalFinalNetOnAirIncome = 0;
        totalProposalDigitalIntegrationFee = 0;
        totalProposalEllentubeFee = 0;
        totalProposalEllentubeFeeDigital = 0;
        totalProposalFinalEllentubeCosts = 0;
        totalProposalEstEllentubeCosts = 0;
        totalProposalFinalNetEllentubeIncome = 0;
        totalProposalYouTubeFee = 0;
        totalProposalEstYouTubeRevenue = 0;
        totalProposalFinalYouTubeRevenue = 0;
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
        /*totalProposalHeadsUpFee = 0;
        totalProposalFinalHeadsUpCost = 0;
        totalProposalFinalHeadsUpNetIncome = 0;
        totalProposalPsychFee = 0;
        totalProposalFinalPsychCosts = 0;
        totalProposalFinalPsychNetIncome = 0;
        totalProposalHotHandsFee = 0;
        totalProposalFinalHotHandsCost = 0;
        totalProposalFinalHotHandsNetIncome = 0;
        totalProposalEmojiAppFee = 0;
        totalProposalFinalEmojiAppCosts = 0;
        totalProposalFinalEmojiAppNetIncome = 0;*/
        totalProposalGamesFee=0;
        totalProposalFinalGamesCost=0;
        totalProposalFinalGamesNetIncome=0;
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
        totalProposalPrizingTakenoutofOnAirIntFee = 0;        
        totalProposalBroadcastMedia = 0;        
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
        /*proposalDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, Heads_Up_Fee__c, Final_Heads_Up_Cost__c, 
                    Final_Heads_Up_Net_Income__c, Psych_Fee__c, Final_Psych_Costs__c, Final_Psych_Net_Income__c, Hot_Hands_Fee__c, Final_Hot_Hands_Cost__c, Final_Hot_Hands_Net_Income__c, Emoji_App_Fee__c, 
                    Final_Emoji_App_Costs__c, Final_Emoji_App_Net_Income__c, Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Proposal'];*/
        proposalDeals = [select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, 
                    Games_Fee__c, Final_Games_Cost__c, Final_Games_Net_Income__c, 
                    Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and StageName = 'Proposal'];
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
        for(Opportunity proposalDeal:proposalDeals){
            if(proposalDeal.On_Air_Integration_Fee__c!=null) totalProposalOnAirIntegrationFee += proposalDeal.On_Air_Integration_Fee__c;
            if(proposalDeal.Final_On_Air_Sponsorship_Cost__c!=null) totalProposalFinalOnAirSponsorshipCost += proposalDeal.Final_On_Air_Sponsorship_Cost__c;
            if(proposalDeal.Final_On_Air_Production_Costs__c!=null) totalProposalFinalOnAirProductionCosts += proposalDeal.Final_On_Air_Production_Costs__c;
            if(proposalDeal.Final_Net_On_Air_Income__c!=null) totalProposalFinalNetOnAirIncome += proposalDeal.Final_Net_On_Air_Income__c;
            if(proposalDeal.Digital_Integration_Fee__c!=null) totalProposalDigitalIntegrationFee += proposalDeal.Digital_Integration_Fee__c;
            if(proposalDeal.Ellentube_Fee__c!=null && proposalDeal.How_is_Digital_Being_Paid__c=='Digital IO') totalproposalEllentubeFeeDigital += proposalDeal.Ellentube_Fee__c;
            else if(proposalDeal.Ellentube_Fee__c!=null) totalproposalEllentubeFee += proposalDeal.Ellentube_Fee__c;
            if(proposalDeal.Est_Ellentube_Costs__c!=null) totalProposalEstEllentubeCosts += proposalDeal.Est_Ellentube_Costs__c;
            if(proposalDeal.Final_Ellentube_Costs__c!=null) totalProposalFinalEllentubeCosts += proposalDeal.Final_Ellentube_Costs__c;
            if(proposalDeal.Final_Net_Ellentube_Income__c!=null) totalProposalFinalNetEllentubeIncome += proposalDeal.Final_Net_Ellentube_Income__c;
            if(proposalDeal.YouTube_Fee__c!=null) totalProposalYouTubeFee += proposalDeal.YouTube_Fee__c;
            if(proposalDeal.Est_YouTube_Revenue__c!=null) totalProposalEstYouTubeRevenue += proposalDeal.Est_YouTube_Revenue__c;
            if(proposalDeal.Final_YouTube_Revenue__c!=null) totalProposalFinalYouTubeRevenue += proposalDeal.Final_YouTube_Revenue__c;
            // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
            /*if(proposalDeal.Heads_Up_Fee__c!=null) totalProposalHeadsUpFee += proposalDeal.Heads_Up_Fee__c;
            if(proposalDeal.Final_Heads_Up_Cost__c!=null) totalProposalFinalHeadsUpCost += proposalDeal.Final_Heads_Up_Cost__c;
            if(proposalDeal.Final_Heads_Up_Net_Income__c!=null) totalProposalFinalHeadsUpNetIncome += proposalDeal.Final_Heads_Up_Net_Income__c;
            if(proposalDeal.Psych_Fee__c!=null) totalClosedPsychFee += proposalDeal.Psych_Fee__c;
            if(proposalDeal.Final_Psych_Costs__c!=null) totalClosedFinalPsychCosts += proposalDeal.Final_Psych_Costs__c;
            if(proposalDeal.Final_Psych_Net_Income__c!=null) totalClosedFinalPsychNetIncome += proposalDeal.Final_Psych_Net_Income__c;
            if(proposalDeal.Hot_Hands_Fee__c!=null) totalClosedHotHandsFee += proposalDeal.Hot_Hands_Fee__c;
            if(proposalDeal.Final_Hot_Hands_Cost__c!=null) totalClosedFinalHotHandsCost += proposalDeal.Final_Hot_Hands_Cost__c;
            if(proposalDeal.Final_Hot_Hands_Net_Income__c!=null) totalClosedFinalHotHandsNetIncome += proposalDeal.Final_Hot_Hands_Net_Income__c;
            if(proposalDeal.Emoji_App_Fee__c!=null) totalClosedEmojiAppFee += proposalDeal.Emoji_App_Fee__c;
            if(proposalDeal.Final_Emoji_App_Costs__c!=null) totalClosedFinalEmojiAppCosts += proposalDeal.Final_Emoji_App_Costs__c;
            if(proposalDeal.Final_Emoji_App_Net_Income__c!=null) totalClosedFinalEmojiAppNetIncome += proposalDeal.Final_Emoji_App_Net_Income__c;*/
            if(proposalDeal.Games_Fee__c!=null) totalProposalGamesFee += proposalDeal.Games_Fee__c;
            if(proposalDeal.Final_Games_Cost__c!=null) totalProposalFinalGamesCost += proposalDeal.Final_Games_Cost__c;
            if(proposalDeal.Final_Games_Net_Income__c!=null) totalProposalFinalGamesNetIncome += proposalDeal.Final_Games_Net_Income__c;
            // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
            if(proposalDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null) totalProposalPrizingTakenoutofOnAirIntFee += proposalDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            if(proposalDeal.Broadcast_Media__c!=null) totalProposalBroadcastMedia += proposalDeal.Broadcast_Media__c;
        }
        totalOpenGrossIntegrationFee = 0;
        totalOpenOnAirIntegrationFee = 0;
        totalOpenFinalOnAirSponsorshipCost = 0;
        totalOpenFinalOnAirProductionCosts = 0;
        totalOpenFinalNetOnAirIncome = 0;
        totalOpenDigitalIntegrationFee = 0;
        totalOpenEllentubeFee = 0;
        totalOpenEllentubeFeeDigital = 0;
        totalOpenFinalEllentubeCosts = 0;
        totalOpenEstEllentubeCosts = 0;
        totalOpenFinalNetEllentubeIncome = 0;
        totalOpenYouTubeFee = 0;
        totalOpenEstYouTubeRevenue = 0;
        totalOpenFinalYouTubeRevenue = 0;
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
        /*totalOpenHeadsUpFee = 0;
        totalOpenFinalHeadsUpCost = 0;
        totalOpenFinalHeadsUpNetIncome = 0;
        totalOpenPsychFee = 0;
        totalOpenFinalPsychCosts = 0;
        totalOpenFinalPsychNetIncome = 0;
        totalOpenHotHandsFee = 0;
        totalOpenFinalHotHandsCost = 0;
        totalOpenFinalHotHandsNetIncome = 0;
        totalOpenEmojiAppFee = 0;
        totalOpenFinalEmojiAppCosts = 0;
        totalOpenFinalEmojiAppNetIncome = 0; */
        totalOpenGamesFee=0;
        totalOpenFinalGamesCost=0;
        totalOpenFinalGamesNetIncome=0;
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
        totalOpenPrizingTakenoutofOnAirIntFee = 0;        
        totalOpenBroadcastMedia = 0;        
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
        /*for(Opportunity openDeal:[select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, Heads_Up_Fee__c, Final_Heads_Up_Cost__c, 
                                    Final_Heads_Up_Net_Income__c, Psych_Fee__c, Final_Psych_Costs__c, Final_Psych_Net_Income__c, Hot_Hands_Fee__c, Final_Hot_Hands_Cost__c, Final_Hot_Hands_Net_Income__c, Emoji_App_Fee__c, 
                                    Final_Emoji_App_Costs__c, Final_Emoji_App_Net_Income__c, Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and (StageName = 'Closed' or StageName = 'Contract' or StageName = 'Hot' or StageName = 'Proposal')]){*/
        for(Opportunity openDeal:[select id, name, CloseDate, Account.Name, Total_Gross_Integration_Fee__c, On_Air_Integration_Fee__c, Final_On_Air_Sponsorship_Cost__c, Final_On_Air_Production_Costs__c, 
                                    Final_Net_On_Air_Income__c, Digital_Integration_Fee__c, Ellentube_Fee__c, Est_Ellentube_Costs__c, Final_Ellentube_Costs__c, Ellen_Sales_Led_Value_of_Program__c, Ellen_Sales_Led_Value_of_Ellen_s_Portio__c, 
                                    Ellen_Sales_Led_Final_Costs__c, Twitter_Sales_Led_Final_Fee_to_Ellen__c, Final_Net_Ellentube_Income__c, YouTube_Fee__c, Final_YouTube_Revenue__c, Est_YouTube_Revenue__c, 
                                    Games_Fee__c, Final_Games_Cost__c, Final_Games_Net_Income__c,
                                    Prizing_Taken_out_of_On_Air_Int_Fee__c, Broadcast_Media__c, How_is_Digital_Being_Paid__c
                                    from Opportunity where Digital_Billing_Year_Commitment__c = :commitment.id and (StageName = 'Closed' or StageName = 'Contract' or StageName = 'Hot' or StageName = 'Proposal')]){
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
            if(openDeal.Total_Gross_Integration_Fee__c!=null) totalOpenGrossIntegrationFee += openDeal.Total_Gross_Integration_Fee__c;
            if(openDeal.On_Air_Integration_Fee__c!=null) totalOpenOnAirIntegrationFee += openDeal.On_Air_Integration_Fee__c;
            if(openDeal.Final_On_Air_Sponsorship_Cost__c!=null) totalOpenFinalOnAirSponsorshipCost += openDeal.Final_On_Air_Sponsorship_Cost__c;
            if(openDeal.Final_On_Air_Production_Costs__c!=null) totalOpenFinalOnAirProductionCosts += openDeal.Final_On_Air_Production_Costs__c;
            if(openDeal.Final_Net_On_Air_Income__c!=null) totalOpenFinalNetOnAirIncome += openDeal.Final_Net_On_Air_Income__c;
            if(openDeal.Digital_Integration_Fee__c!=null) totalOpenDigitalIntegrationFee += openDeal.Digital_Integration_Fee__c;
            if(openDeal.Ellentube_Fee__c!=null && openDeal.How_is_Digital_Being_Paid__c=='Digital IO') totalOpenEllentubeFeeDigital += openDeal.Ellentube_Fee__c;
            else if(openDeal.Ellentube_Fee__c!=null) totalOpenEllentubeFee += openDeal.Ellentube_Fee__c;
            if(openDeal.Est_Ellentube_Costs__c!=null) totalOpenEstEllentubeCosts += openDeal.Est_Ellentube_Costs__c;
            if(openDeal.Final_Ellentube_Costs__c!=null) totalOpenFinalEllentubeCosts += openDeal.Final_Ellentube_Costs__c;
            if(openDeal.Final_Net_Ellentube_Income__c!=null) totalOpenFinalNetEllentubeIncome += openDeal.Final_Net_Ellentube_Income__c;
            if(openDeal.YouTube_Fee__c!=null) totalOpenYouTubeFee += openDeal.YouTube_Fee__c;
            if(openDeal.Est_YouTube_Revenue__c!=null) totalOpenEstYouTubeRevenue += openDeal.Est_YouTube_Revenue__c;
            if(openDeal.Final_YouTube_Revenue__c!=null) totalOpenFinalYouTubeRevenue += openDeal.Final_YouTube_Revenue__c;
            // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + Start
            /*if(openDeal.Heads_Up_Fee__c!=null) totalOpenHeadsUpFee += openDeal.Heads_Up_Fee__c;
            if(openDeal.Final_Heads_Up_Cost__c!=null) totalOpenFinalHeadsUpCost += openDeal.Final_Heads_Up_Cost__c;
            if(openDeal.Final_Heads_Up_Net_Income__c!=null) totalOpenFinalHeadsUpNetIncome += openDeal.Final_Heads_Up_Net_Income__c;
            if(openDeal.Psych_Fee__c!=null) totalClosedPsychFee += openDeal.Psych_Fee__c;
            if(openDeal.Final_Psych_Costs__c!=null) totalClosedFinalPsychCosts += openDeal.Final_Psych_Costs__c;
            if(openDeal.Final_Psych_Net_Income__c!=null) totalClosedFinalPsychNetIncome += openDeal.Final_Psych_Net_Income__c;
            if(openDeal.Hot_Hands_Fee__c!=null) totalClosedHotHandsFee += openDeal.Hot_Hands_Fee__c;
            if(openDeal.Final_Hot_Hands_Cost__c!=null) totalClosedFinalHotHandsCost += openDeal.Final_Hot_Hands_Cost__c;
            if(openDeal.Final_Hot_Hands_Net_Income__c!=null) totalClosedFinalHotHandsNetIncome += openDeal.Final_Hot_Hands_Net_Income__c;
            if(openDeal.Emoji_App_Fee__c!=null) totalClosedEmojiAppFee += openDeal.Emoji_App_Fee__c;
            if(openDeal.Final_Emoji_App_Costs__c!=null) totalClosedFinalEmojiAppCosts += openDeal.Final_Emoji_App_Costs__c;
            if(openDeal.Final_Emoji_App_Net_Income__c!=null) totalClosedFinalEmojiAppNetIncome += openDeal.Final_Emoji_App_Net_Income__c;*/
            if(openDeal.Games_Fee__c!=null) totalOpenGamesFee += openDeal.Games_Fee__c;
            if(openDeal.Final_Games_Cost__c!=null) totalOpenFinalGamesCost += openDeal.Final_Games_Cost__c; 
            if(openDeal.Final_Games_Net_Income__c!=null) totalOpenFinalGamesNetIncome += openDeal.Final_Games_Net_Income__c;
            // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + END
            if(openDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null) totalOpenPrizingTakenoutofOnAirIntFee += openDeal.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            if(openDeal.Broadcast_Media__c!=null) totalOpenBroadcastMedia += openDeal.Broadcast_Media__c;
        }
        PercentOpenDigitalIntegrationFee = commitment.Digital_Integration_Fee__c != null && commitment.Digital_Integration_Fee__c!= 0 ? totalOpenDigitalIntegrationFee*100/commitment.Digital_Integration_Fee__c : null;        
        PercentOpenEllentubeFeeWADAgreement = commitment.Ellentube_Fee_WAD_Agreement__c != null && commitment.Ellentube_Fee_WAD_Agreement__c!= 0 ? totalOpenEllentubeFee*100/commitment.Ellentube_Fee_WAD_Agreement__c : null;        
        PercentOpenEstEllentubeCosts = commitment.Ellentube_Costs__c != null && commitment.Ellentube_Costs__c!= 0 ? totalOpenEstEllentubeCosts*100/commitment.Ellentube_Costs__c : null;        
        PercentOpenFinalEllentubeCosts = commitment.Ellentube_Costs__c != null && commitment.Ellentube_Costs__c!= 0 ? totalOpenFinalEllentubeCosts*100/commitment.Ellentube_Costs__c : null;        
        PercentOpenNetEllentubeIncome = commitment.Net_Ellentube_Income__c != null && commitment.Net_Ellentube_Income__c!= 0 ? totalOpenFinalNetEllentubeIncome*100/commitment.Net_Ellentube_Income__c : null;        
        PercentOpenEllentubeFeeDigitalIO = commitment.Ellentube_Fee_Digital_IO__c != null && commitment.Ellentube_Fee_Digital_IO__c!= 0 ? totalOpenEllentubeFeeDigital*100/commitment.Ellentube_Fee_Digital_IO__c : null;        
        PercentOpenYouTubeFee = commitment.YouTube_Goal__c != null && commitment.YouTube_Goal__c!= 0 ? totalOpenYouTubeFee*100/commitment.YouTube_Goal__c : null;        
        PercentOpenEstYouTubeRevenue = commitment.YouTube_Goal__c != null && commitment.YouTube_Goal__c!= 0 ? totalOpenEstYouTubeRevenue*100/commitment.YouTube_Goal__c : null;        
        PercentOpenFinalYouTubeRevenue = commitment.YouTube_Goal__c != null && commitment.YouTube_Goal__c!= 0 ? totalOpenFinalYouTubeRevenue*100/commitment.YouTube_Goal__c : null;  
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + need UPDATES
        /*PercentOpenHeadsUpGoal = commitment.Heads_Up_Goal__c != null && commitment.Heads_Up_Goal__c!= 0 ? totalOpenHeadsUpFee*100/commitment.Heads_Up_Goal__c : null;        
        PercentOpenPsychGoal = commitment.Psych_Goal__c != null && commitment.Psych_Goal__c!= 0 ? totalOpenPsychFee*100/commitment.Psych_Goal__c : null;        
        PercentOpenHotHandsGoal = commitment.Hot_Hands_Goal__c != null && commitment.Hot_Hands_Goal__c!= 0 ? totalOpenHotHandsFee*100/commitment.Hot_Hands_Goal__c : null;        
        PercentOpenEmojiAppGoal = commitment.Emoji_App_Goal__c != null && commitment.Emoji_App_Goal__c!= 0 ? totalOpenEmojiAppFee*100/commitment.Emoji_App_Goal__c : null;*/
        PercentOpenGamesGoal = commitment.Games_Goal__c != null && commitment.Games_Goal__c!= 0 ? totalOpenGamesFee*100/commitment.Games_Goal__c : null;        
        // Code Modified by Mayank Desai on 03/25/2019 for ER-002310_TPX_GamesRollup + need UPDATES

        
    }
    //Method used to go to the next season
    public void nextSeason(){
        if(lastSeason > seasonIndex) seasonIndex += 1; getDeals();
    }
    //Method used to go to the previous season
    public void previousSeason(){
        if(0 < seasonIndex) seasonIndex -= 1; getDeals();
    }
    //Method to get all the Corporate Forecasts
    public void getSeasons(){
        // Code Modified by Mayank Desai on 03/26/2019 for ER-002310_TPX_GamesRollup + Start
        /*commitments = [select id, Name, Digital_Integration_Fee__c, Ellentube_Fee_WAD_Agreement__c, Ellentube_Fee__c, Ellentube_Costs__c, Ellentube_Fee_Digital_IO__c, Net_Ellentube_Income__c, 
                      Heads_Up_Goal__c, Psych_Goal__c, Hot_Hands_Goal__c, Emoji_App_Goal__c, YouTube_Goal__c
                      from Commitments__c where RecordTypeId =:Schema.SObjectType.Commitments__c.getRecordTypeInfosByName().get('Digital Forecast').getRecordTypeId() order by Name, Createddate];*/
        commitments = [select id, Name, Digital_Integration_Fee__c, Ellentube_Fee_WAD_Agreement__c, Ellentube_Fee__c, Ellentube_Costs__c, Ellentube_Fee_Digital_IO__c, Net_Ellentube_Income__c, 
                      Games_Goal__c, 
                      YouTube_Goal__c from Commitments__c where RecordTypeId =:Schema.SObjectType.Commitments__c.getRecordTypeInfosByName().get('Digital Forecast').getRecordTypeId() order by Name, Createddate];
        // Code Modified by Mayank Desai on 03/26/2019 for ER-002310_TPX_GamesRollup + END
        lastSeason = commitments.size() - 1;
    }    
}