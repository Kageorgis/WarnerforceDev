public class TPX_OnAirTrackingController {

    public List<Opportunity> lstClosedOpps {get; set;}
    public List<Opportunity> lstHotOpps {get; set;}
    public List<Opportunity> lstContractOpps {get; set;}
    public List<Opportunity> lstProposalOpps {get; set;}
    public Id commitmentId {get; set;}
    
    public Integer lastSeason {get;set;}
    public Integer seasonIndex {get;set;}
    
    public Commitments__c commitment {get;set;}
    public List<Commitments__c> commitments {get;set;}
    
    public Decimal onAirIntegrationFeeTotalClosed {get; set;}
    public Decimal onAirIntegrationFeeTotalHot {get; set;}
    public Decimal onAirIntegrationFeeTotalContract {get; set;}
    public Decimal onAirIntegrationFeeTotalProposal {get; set;}
    
    public Decimal estOnAirProductionCostTotalClosed {get; set;}
    public Decimal estOnAirProductionCostTotalHot {get; set;}
    public Decimal estOnAirProductionCostTotalContract {get; set;}
    public Decimal estOnAirProductionCostTotalProposal {get; set;}
    
    public Decimal actualOnAirProductionCostTotalClosed {get; set;}
    public Decimal actualOnAirProductionCostTotalHot {get; set;}
    public Decimal actualOnAirProductionCostTotalContract {get; set;}
    public Decimal actualOnAirProductionCostTotalProposal {get; set;}
    
    public Decimal estOnAirSponsorshipCostTotalClosed {get; set;}
    public Decimal estOnAirSponsorshipCostTotalHot {get; set;}
    public Decimal estOnAirSponsorshipCostTotalContract {get; set;}
    public Decimal estOnAirSponsorshipCostTotalProposal {get; set;}
    
    public Decimal estOnAirIncomeTotalClosed {get; set;}
    public Decimal estOnAirIncomeTotalHot {get; set;}
    public Decimal estOnAirIncomeTotalContract {get; set;}
    public Decimal estOnAirIncomeTotalProposal {get; set;}
    
    public Decimal actualOnAirSponsorshipCostTotalClosed {get; set;}
    public Decimal actualOnAirSponsorshipCostTotalHot {get; set;}
    public Decimal actualOnAirSponsorshipCostTotalContract {get; set;}
    public Decimal actualOnAirSponsorshipCostTotalProposal {get; set;}
    
    public Decimal prizingTakenOutOfOnAirIntFeeTotalClosed {get; set;}
    public Decimal prizingTakenOutOfOnAirIntFeeTotalHot {get; set;}
    public Decimal prizingTakenOutOfOnAirIntFeeTotalContract {get; set;}
    public Decimal prizingTakenOutOfOnAirIntFeeTotalProposal {get; set;}
    
    public Decimal finalNetOnAirIncomeTotalClosed {get; set;}
    public Decimal finalNetOnAirIncomeTotalHot {get; set;}
    public Decimal finalNetOnAirIncomeTotalContract {get; set;}
    public Decimal finalNetOnAirIncomeTotalProposal {get; set;}
    
    public Decimal totalClosedMinusAdminClosed {get; set;}
    public Decimal totalClosedMinusAdminHot {get; set;}
    public Decimal totalClosedMinusAdminContract {get; set;}
    public Decimal totalClosedMinusAdminProposal {get; set;}
    
    public Decimal grossOnAirIntegrationGoal {get; set;}
    public Decimal adminCosts {get; set;}
    public Decimal onAirProductionCost {get; set;}
    public Decimal netOnAirIntegrationGoal {get; set;}
    
    public Decimal percentageToGoalClosed {get; set;}
    public Decimal percentageToGoalHot {get; set;}
    public Decimal percentageToGoalProposal {get; set;}
    public Decimal percentageToGoalContract {get; set;}
    public Decimal toGo {get; set;}
    
    public TPX_OnAirTrackingController(){
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('seasonIndex'))) seasonIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('seasonIndex'));
        else seasonIndex = 0;
        getSeasons();
        getDeals();
    }
    
    public void getDeals(){
        commitment = new Commitments__c();
        if(!commitments.isEmpty()) commitment = commitments[seasonIndex];
        
        grossOnAirIntegrationGoal = commitment.On_Air_Integration_Fee__c != null ? commitment.On_Air_Integration_Fee__c : 0;
    	adminCosts = commitment.On_Air_Admin_Costs__c != null ? commitment.On_Air_Admin_Costs__c : 0;
    	onAirProductionCost = commitment.On_Air_Production_Costs__c;
    	netOnAirIntegrationGoal = commitment.Net_On_Air_Income__c;
        
        commitmentId = commitment.Id;
        
        onAirIntegrationFeeTotalClosed = 0.00;
        onAirIntegrationFeeTotalHot = 0.00;
        onAirIntegrationFeeTotalContract = 0.00;
        onAirIntegrationFeeTotalProposal = 0.00;
        
        estOnAirProductionCostTotalClosed = 0.00;
        estOnAirProductionCostTotalHot = 0.00;
        estOnAirProductionCostTotalContract = 0.00;
        estOnAirProductionCostTotalProposal = 0.00;
        
        actualOnAirProductionCostTotalClosed = 0.00;
        actualOnAirProductionCostTotalHot = 0.00;
        actualOnAirProductionCostTotalContract = 0.00;
        actualOnAirProductionCostTotalProposal = 0.00;
        
        estOnAirSponsorshipCostTotalClosed = 0.00;
        estOnAirSponsorshipCostTotalHot = 0.00;
		estOnAirSponsorshipCostTotalContract = 0.00;
		estOnAirSponsorshipCostTotalProposal = 0.00;
        
        estOnAirIncomeTotalClosed = 0.00;
        estOnAirIncomeTotalHot = 0.00;
		estOnAirIncomeTotalContract = 0.00;
		estOnAirIncomeTotalProposal = 0.00;
        
        actualOnAirSponsorshipCostTotalClosed = 0.00;
        actualOnAirSponsorshipCostTotalHot = 0.00;
        actualOnAirSponsorshipCostTotalContract = 0.00;
        actualOnAirSponsorshipCostTotalProposal = 0.00;
        
        prizingTakenOutOfOnAirIntFeeTotalClosed = 0.00;
        prizingTakenOutOfOnAirIntFeeTotalHot = 0.00;
        prizingTakenOutOfOnAirIntFeeTotalContract = 0.00;
        prizingTakenOutOfOnAirIntFeeTotalProposal = 0.00;
        
        finalNetOnAirIncomeTotalClosed = 0.00;
        finalNetOnAirIncomeTotalHot = 0.00;
        finalNetOnAirIncomeTotalContract = 0.00;
        finalNetOnAirIncomeTotalProposal = 0.00;
        
        totalClosedMinusAdminClosed = 0.00;
        totalClosedMinusAdminHot = 0.00;
        totalClosedMinusAdminContract = 0.00;
        totalClosedMinusAdminProposal = 0.00;
        
        lstClosedOpps = [SELECT Id, Name, Owner.Name, On_Air_Integration_Fee__c, Est_On_Air_Production_Cost__c, Est_On_Air_Sponsorship_Cost__c, Prizing_Taken_out_of_On_Air_Int_Fee__c,
                   Final_Net_On_Air_Income__c, Final_On_Air_Production_Costs__c, Est_Net_On_Air_Income__c, Final_On_Air_Sponsorship_Cost__c, StageName FROM Opportunity WHERE StageName = 'Closed' AND On_Air_Billing_Season_Commitment__c=:commitmentId AND (RecordTypeId !=:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() OR (RecordTypeId =:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() AND On_Air_Integration_Fee__c != null))];
        
        lstHotOpps = [SELECT Id, Name, Owner.Name, On_Air_Integration_Fee__c, Est_On_Air_Production_Cost__c, Est_On_Air_Sponsorship_Cost__c, Prizing_Taken_out_of_On_Air_Int_Fee__c,
                   Final_Net_On_Air_Income__c, Final_On_Air_Production_Costs__c, Est_Net_On_Air_Income__c, Final_On_Air_Sponsorship_Cost__c, StageName FROM Opportunity WHERE StageName = 'Hot' AND On_Air_Billing_Season_Commitment__c=:commitmentId AND (RecordTypeId !=:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() OR (RecordTypeId =:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() AND On_Air_Integration_Fee__c != null))];
        
        lstContractOpps = [SELECT Id, Name, Owner.Name, On_Air_Integration_Fee__c, Est_On_Air_Production_Cost__c, Est_On_Air_Sponsorship_Cost__c, Prizing_Taken_out_of_On_Air_Int_Fee__c,
                   Final_Net_On_Air_Income__c, Final_On_Air_Production_Costs__c, Est_Net_On_Air_Income__c, Final_On_Air_Sponsorship_Cost__c, StageName FROM Opportunity WHERE StageName = 'Contract' AND On_Air_Billing_Season_Commitment__c=:commitmentId AND (RecordTypeId !=:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() OR (RecordTypeId =:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() AND On_Air_Integration_Fee__c != null))];
        
        lstProposalOpps = [SELECT Id, Name, Owner.Name, On_Air_Integration_Fee__c, Est_On_Air_Production_Cost__c, Est_On_Air_Sponsorship_Cost__c, Prizing_Taken_out_of_On_Air_Int_Fee__c,
                   Final_Net_On_Air_Income__c, Final_On_Air_Production_Costs__c, Est_Net_On_Air_Income__c, Final_On_Air_Sponsorship_Cost__c, StageName FROM Opportunity WHERE StageName = 'Proposal' AND On_Air_Billing_Season_Commitment__c=:commitmentId AND (RecordTypeId !=:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() OR (RecordTypeId =:Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BE KIND. Box Deal').getRecordTypeId() AND On_Air_Integration_Fee__c != null))];
        
        for(Opportunity opp : lstClosedOpps){
            if(opp.On_Air_Integration_Fee__c!=null){
                onAirIntegrationFeeTotalClosed += opp.On_Air_Integration_Fee__c;
            }
            
            if(opp.Est_On_Air_Production_Cost__c!=null){
                estOnAirProductionCostTotalClosed += opp.Est_On_Air_Production_Cost__c;
            }
            
            if(opp.Final_On_Air_Production_Costs__c!=null){
                actualOnAirProductionCostTotalClosed += opp.Final_On_Air_Production_Costs__c;
            }
            
            if(opp.Est_On_Air_Sponsorship_Cost__c!=null){
                estOnAirSponsorshipCostTotalClosed += opp.Est_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Final_On_Air_Sponsorship_Cost__c!=null){
                actualOnAirSponsorshipCostTotalClosed += opp.Final_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null){
                prizingTakenOutOfOnAirIntFeeTotalClosed += opp.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            }
            
            if(opp.Final_Net_On_Air_Income__c!=null){
                finalNetOnAirIncomeTotalClosed += opp.Final_Net_On_Air_Income__c;
            }
            
            if(opp.Est_Net_On_Air_Income__c!=null){
                estOnAirIncomeTotalClosed += opp.Est_Net_On_Air_Income__c;
            }
        }
        
        for(Opportunity opp : lstHotOpps){
            if(opp.On_Air_Integration_Fee__c!=null){
                onAirIntegrationFeeTotalHot += opp.On_Air_Integration_Fee__c;
            }
            
            if(opp.Est_On_Air_Production_Cost__c!=null){
                estOnAirProductionCostTotalHot += opp.Est_On_Air_Production_Cost__c;
            }
            
            if(opp.Final_On_Air_Production_Costs__c!=null){
                actualOnAirProductionCostTotalHot += opp.Final_On_Air_Production_Costs__c;
            }
            
            if(opp.Est_On_Air_Sponsorship_Cost__c!=null){
                estOnAirSponsorshipCostTotalHot += opp.Est_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Final_On_Air_Sponsorship_Cost__c!=null){
                actualOnAirSponsorshipCostTotalHot += opp.Final_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null){
                prizingTakenOutOfOnAirIntFeeTotalHot += opp.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            }
            
            if(opp.Final_Net_On_Air_Income__c!=null){
                finalNetOnAirIncomeTotalHot += opp.Final_Net_On_Air_Income__c;
            }
            
            if(opp.Est_Net_On_Air_Income__c!=null){
                estOnAirIncomeTotalHot += opp.Est_Net_On_Air_Income__c;
            }
        }
        
        for(Opportunity opp : lstContractOpps){
            if(opp.On_Air_Integration_Fee__c!=null){
                onAirIntegrationFeeTotalContract += opp.On_Air_Integration_Fee__c;
            }
            
            if(opp.Est_On_Air_Production_Cost__c!=null){
                estOnAirProductionCostTotalContract += opp.Est_On_Air_Production_Cost__c;
            }
            
            if(opp.Final_On_Air_Production_Costs__c!=null){
                actualOnAirProductionCostTotalContract += opp.Final_On_Air_Production_Costs__c;
            }
            
            if(opp.Est_On_Air_Sponsorship_Cost__c!=null){
                estOnAirSponsorshipCostTotalContract += opp.Est_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Final_On_Air_Sponsorship_Cost__c!=null){
                actualOnAirSponsorshipCostTotalContract += opp.Final_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null){
                prizingTakenOutOfOnAirIntFeeTotalContract += opp.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            }
            
            if(opp.Final_Net_On_Air_Income__c!=null){
                finalNetOnAirIncomeTotalContract += opp.Final_Net_On_Air_Income__c;
            }
            
            if(opp.Est_Net_On_Air_Income__c!=null){
                estOnAirIncomeTotalContract += opp.Est_Net_On_Air_Income__c;
            }
        }
        
        for(Opportunity opp : lstProposalOpps){
            if(opp.On_Air_Integration_Fee__c!=null){
                onAirIntegrationFeeTotalProposal += opp.On_Air_Integration_Fee__c;
            }
            
            if(opp.Est_On_Air_Production_Cost__c!=null){
                estOnAirProductionCostTotalProposal += opp.Est_On_Air_Production_Cost__c;
            }
            
            if(opp.Final_On_Air_Production_Costs__c!=null){
                actualOnAirProductionCostTotalProposal += opp.Final_On_Air_Production_Costs__c;
            }
            
            if(opp.Est_On_Air_Sponsorship_Cost__c!=null){
                estOnAirSponsorshipCostTotalProposal += opp.Est_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Final_On_Air_Sponsorship_Cost__c!=null){
                actualOnAirSponsorshipCostTotalProposal += opp.Final_On_Air_Sponsorship_Cost__c;
            }
            
            if(opp.Prizing_Taken_out_of_On_Air_Int_Fee__c!=null){
                prizingTakenOutOfOnAirIntFeeTotalProposal += opp.Prizing_Taken_out_of_On_Air_Int_Fee__c;
            }
            
            if(opp.Final_Net_On_Air_Income__c!=null){
                finalNetOnAirIncomeTotalProposal += opp.Final_Net_On_Air_Income__c;
            }
            
            if(opp.Est_Net_On_Air_Income__c!=null){
                estOnAirIncomeTotalProposal += opp.Est_Net_On_Air_Income__c;
            }
        }
        
        totalClosedMinusAdminClosed = finalNetOnAirIncomeTotalClosed - adminCosts;
        totalClosedMinusAdminHot = finalNetOnAirIncomeTotalHot - adminCosts;
        totalClosedMinusAdminContract = finalNetOnAirIncomeTotalContract - adminCosts;
        totalClosedMinusAdminProposal = finalNetOnAirIncomeTotalProposal - adminCosts;
        
        Decimal percentageClosed;
        Decimal percentageHot;
        Decimal percentageContract;
        Decimal percentageProposal;
        
        percentageClosed = 0.00;
        percentageHot = 0.00;
        percentageContract = 0.00;
        percentageProposal = 0.00;
        if(netOnAirIntegrationGoal!=null){
            if(finalNetOnAirIncomeTotalClosed!=null){
                if(finalNetOnAirIncomeTotalClosed==0.00){
                    percentageClosed = 0.00;
                } else {
                    percentageClosed = totalClosedMinusAdminClosed/netOnAirIntegrationGoal*100;
                }
            }
            if(finalNetOnAirIncomeTotalHot!=null){
                if(finalNetOnAirIncomeTotalHot==0.00){
                    percentageHot = 0.00;
                } else {
                    percentageHot = finalNetOnAirIncomeTotalHot/netOnAirIntegrationGoal*100;
                }
            }
            if(finalNetOnAirIncomeTotalContract!=null){
                if(finalNetOnAirIncomeTotalContract==0.00){
                    percentageContract = 0.00;
                } else {
                    percentageContract = finalNetOnAirIncomeTotalContract/netOnAirIntegrationGoal*100;
                }
            }
            if(finalNetOnAirIncomeTotalProposal!=null){
                if(finalNetOnAirIncomeTotalProposal==0.00){
                    percentageProposal = 0.00;
                } else {
                    percentageProposal = finalNetOnAirIncomeTotalProposal/netOnAirIntegrationGoal*100;
                }
            }
            
            percentageToGoalClosed = percentageClosed.setScale(2);
            percentageToGoalHot = percentageHot.setScale(2);
            percentageToGoalContract = percentageContract.setScale(2);
            percentageToGoalProposal = percentageProposal.setScale(2);
            toGo = netOnAirIntegrationGoal-totalClosedMinusAdminClosed;
        }
    }
    
    //Method used to go to the next season
    public void nextSeason(){
        if(lastSeason > seasonIndex) seasonIndex += 1; getSeasons(); getDeals();
    }
    //Method used to go to the previous season
    public void previousSeason(){
        if(0 < seasonIndex) seasonIndex -= 1; getSeasons(); getDeals();
    }
    //Method to get all the Corporate Forecasts
    public void getSeasons(){
        commitments = [select id, Name, Digital_Integration_Fee__c, Ellentube_Fee_WAD_Agreement__c, Ellentube_Fee__c, Ellentube_Costs__c, Ellentube_Fee_Digital_IO__c, Net_Ellentube_Income__c, 
                      Heads_Up_Goal__c, Psych_Goal__c, Hot_Hands_Goal__c, Emoji_App_Goal__c, YouTube_Goal__c, On_Air_Integration_Fee__c, On_Air_Production_Costs__c, On_Air_Admin_Costs__c, Net_On_Air_Income__c
                      from Commitments__c where RecordTypeId =:Schema.SObjectType.Commitments__c.getRecordTypeInfosByName().get('On-Air Forecast').getRecordTypeId() order by Name, Createddate];
        lastSeason = commitments.size() - 1;
    }   
    
}