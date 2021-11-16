/*
* Class used to calculate the sums of the amounts for the products with the recordtype "TPX Products"
*
* Author:          Date:           Description
* Martin Mori  18-April-17         First Draft
*/

global class TPX_Calculate {
    webservice static String TPX_UpdateOpportunity(ID oppId){
        Opportunity opp = new Opportunity(Id=oppId);
        //We initialize all amounts to zero
        opp.On_Air_Integration_Fee__c=0;
        opp.Est_On_Air_Sponsorship_Cost__c=0;
        opp.Final_On_Air_Sponsorship_Cost__c=0;
        opp.Est_On_Air_Production_Cost__c=0;
        opp.Final_On_Air_Production_Costs__c=0;
        opp.Digital_Integration_Fee__c=0;
        opp.Est_Ellentube_Costs__c=0;
        opp.Final_Ellentube_Costs__c=0;
        opp.Est_YouTube_Revenue__c=0;
        opp.Final_YouTube_Revenue__c=0;
        //Code Modified by Mayank Desai on 03/28/2019 for ER-2310 - TPX games Rollup + Start
        /*opp.Heads_Up_Fee__c=0;
        opp.Psych_Fee__c=0;
        opp.Hot_Hands_Fee__c=0;
        opp.Emoji_App_Fee__c=0;*/
        //Code Modified by Mayank Desai on 03/28/2019 for ER-2310 - TPX games Rollup + End
        opp.Ellen_Sales_Led_Value_of_Program__c=0;
        opp.Ellen_Sales_Led_Est_Costs__c=0;
        opp.Ellen_Sales_Led_Final_Costs__c=0;
        opp.Twitter_Sales_Led_Est_Fee_to_Ellen__c=0;
        opp.Twitter_Sales_Led_Final_Fee_to_Ellen__c=0;
        opp.Est_Net_On_Air_Income__c=0;
        opp.Final_Net_On_Air_Income__c=0;
        opp.Ellen_Sales_Led_Value_of_Ellen_s_Portio__c=0;
        opp.Est_Net_Ellentube_Income__c=0;
        opp.Final_Net_Ellentube_Income__c=0;
        opp.Ellentube_Fee__c=0;
        opp.Prizing_Incremental_to_Fee__c=0;
        opp.Prizing_Taken_out_of_On_Air_Int_Fee__c=0;
        opp.Prizing_Taken_out_of_Digital_Int_Fee__c=0;
        opp.Prizing_Given_by_Client__c=0;
        opp.YouTube_Fee__c=0;
        //Code Modified by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup + Start
        /*opp.Est_Heads_Up_Cost__c=0;
        opp.Final_Heads_Up_Cost__c=0;
        opp.Est_Heads_Up_Net_Income__c=0;
        opp.Final_Heads_Up_Net_Income__c=0;
        opp.Est_Psych_Cost__c=0;
        opp.Final_Psych_Costs__c=0;
        opp.Est_Psych_Net_Income__c=0;
        opp.Final_Psych_Net_Income__c=0;
        opp.Est_Hot_Hands_Cost__c=0;
        opp.Final_Hot_Hands_Cost__c=0;
        opp.Est_Hot_Hands_Net_Income__c=0;
        opp.Final_Hot_Hands_Net_Income__c=0;
        opp.Est_Emoji_App_Cost__c=0;
        opp.Final_Emoji_App_Costs__c=0;
        opp.Est_Emoji_App_Net_Income__c=0;
        opp.Final_Emoji_App_Net_Income__c=0;*/
        opp.Games_Fee__c=0;
        opp.EST_Games_Net_Income__c=0;
        opp.Final_Games_Net_Income__c=0;
        opp.Est_Games_Cost__c=0;
        opp.Final_Games_Cost__c=0;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup + End
        //We update the last calculation date with today's date and time
        opp.Last_Calculated_Date__c=System.now();
        opp.Number_of_Product_s__c = 0;        
        opp.Total_Sponsorship__c = 0;        
        opp.Total_Shipping_Sponsor__c = 0; 
        opp.Number_of_Redemption_s__c = 0; 
        opp.Value_of_Product_s__c = 0;
        opp.Total_Wholesale_Cost__c = 0;
        //Query of all opportunity products with the id of opportunity passed as parameter
        //Code Added by Mayank Desai on 02/20/2019 for ER-2310 - TPX games Rollup + Start
        /*for(OpportunityLineItem oli : [SELECT Id,Ellen_Sales_Led_Est_Cost__c,Ellen_Sales_Led_Final_Cost__c,
                Est_Ellentube_Cost__c,Est_On_Air_Production_Cost__c,Est_On_Air_Sponsorship_Cost__c,
                Final_Ellentube_Cost__c,Final_On_Air_Production_Cost__c,Final_On_Air_Sponsorship_Cost__c,
                Final_YouTube_Revenue__c,Prizing_Gift_Card_Value_Paid__c,Product_Category__c,Product_Sub_Category__c,
                Twitter_Sales_Led_Est_Fee_to_Ellen__c,Twitter_Sales_Led_Final_Fee_to_Ellen__c,Product2.Name,
                Prizing_Gift_Card_Value__c,TotalPrice,Est_YouTube_Revenue__c,Est_Heads_Up_Cost__c,Final_Heads_Up_Cost__c,
                Est_Psych_Cost__c,Final_Psych_Costs__c,Est_Hot_Hands_Cost__c,Final_Hot_Hands_Cost__c,Est_Emoji_App_Cost__c,
                Final_Emoji_App_Costs__c, Est_Games_Cost__c, Final_Games_Cost__c FROM OpportunityLineItem WHERE OpportunityId = :oppId]) {*/
                for(OpportunityLineItem oli : [SELECT Id,Ellen_Sales_Led_Est_Cost__c,Ellen_Sales_Led_Final_Cost__c,
                Est_Ellentube_Cost__c,Est_On_Air_Production_Cost__c,Est_On_Air_Sponsorship_Cost__c,
                Final_Ellentube_Cost__c,Final_On_Air_Production_Cost__c,Final_On_Air_Sponsorship_Cost__c,
                Final_YouTube_Revenue__c,Prizing_Gift_Card_Value_Paid__c,Product_Category__c,Product_Sub_Category__c,
                Twitter_Sales_Led_Est_Fee_to_Ellen__c,Twitter_Sales_Led_Final_Fee_to_Ellen__c,Product2.Name,
                Prizing_Gift_Card_Value__c,TotalPrice,Est_YouTube_Revenue__c, Est_Games_Cost__c, Final_Games_Cost__c, Revenue_Allocation__c, MSRP__c, Total_Wholesale_Cost__c 
                FROM OpportunityLineItem WHERE OpportunityId = :oppId]){
                    //If the totalprice of the product of the opportunity is null it was set with zero
                    if(oli.TotalPrice==null) oli.TotalPrice=0;

                    //If the Est_Heads_Up_Cost__c of the product of the opportunity is null it was set with zero
                    /*if(oli.Est_Heads_Up_Cost__c==null) oli.Est_Heads_Up_Cost__c=0;
                    //We add the Est_Heads_Up_Cost__c of "opportunity product" to the Est_Heads_Up_Cost__c of the "opportunity"
                    opp.Est_Heads_Up_Cost__c+=oli.Est_Heads_Up_Cost__c;
                    //If the Final_Heads_Up_Cost__c of the product of the opportunity is null it was set with zero
                    if(oli.Final_Heads_Up_Cost__c==null) oli.Final_Heads_Up_Cost__c=0;
                    //We add the Final_Heads_Up_Cost__c of "opportunity product" to the Final_Heads_Up_Cost__c of the "opportunity"
                    opp.Final_Heads_Up_Cost__c+=oli.Final_Heads_Up_Cost__c;
                    //If the Est_Psych_Cost__c of the product of the opportunity is null it was set with zero
                    if(oli.Est_Psych_Cost__c==null) oli.Est_Psych_Cost__c=0;
                    //We add the Est_Psych_Cost__c of "opportunity product" to the Est_Psych_Cost__c of the "opportunity"
                    opp.Est_Psych_Cost__c+=oli.Est_Psych_Cost__c;
                    //If the Final_Psych_Costs__c of the product of the opportunity is null it was set with zero
                    if(oli.Final_Psych_Costs__c==null) oli.Final_Psych_Costs__c=0;
                    //We add the Final_Psych_Costs__c of "opportunity product" to the Final_Psych_Costs__c of the "opportunity"
                    opp.Final_Psych_Costs__c+=oli.Final_Psych_Costs__c;
                    //If the Est_Hot_Hands_Cost__c of the product of the opportunity is null it was set with zero
                    if(oli.Est_Hot_Hands_Cost__c==null) oli.Est_Hot_Hands_Cost__c=0;
                    //We add the Est_Hot_Hands_Cost__c of "opportunity product" to the Est_Hot_Hands_Cost__c of the "opportunity"
                    opp.Est_Hot_Hands_Cost__c+=oli.Est_Hot_Hands_Cost__c;
                    //If the Final_Hot_Hands_Cost__c of the product of the opportunity is null it was set with zero
                    if(oli.Final_Hot_Hands_Cost__c==null) oli.Final_Hot_Hands_Cost__c=0;
                    //We add the Final_Hot_Hands_Cost__c of "opportunity product" to the Final_Hot_Hands_Cost__c of the "opportunity"
                    opp.Final_Hot_Hands_Cost__c+=oli.Final_Hot_Hands_Cost__c;
                    //If the Est_Emoji_App_Cost__c of the product of the opportunity is null it was set with zero
                    if(oli.Est_Emoji_App_Cost__c==null) oli.Est_Emoji_App_Cost__c=0;
                    //We add the Est_Emoji_App_Cost__c of "opportunity product" to the Est_Emoji_App_Cost__c of the "opportunity"
                    opp.Est_Emoji_App_Cost__c+=oli.Est_Emoji_App_Cost__c;
                    //If the Final_Emoji_App_Costs__c of the product of the opportunity is null it was set with zero
                    if(oli.Final_Emoji_App_Costs__c==null) oli.Final_Emoji_App_Costs__c=0;
                    //We add the Final_Emoji_App_Costs__c of "opportunity product" to the Final_Emoji_App_Costs__c of the "opportunity"
                    opp.Final_Emoji_App_Costs__c+=oli.Final_Emoji_App_Costs__c;*/
                    
                    if(oli.Product_Category__c=='On-Air') {
                        //We add the totalprice of "opportunity product" to the On_Air_Integration_Fee__c of the "opportunity"
                        opp.On_Air_Integration_Fee__c+=oli.TotalPrice;
                        if(oli.Product_Sub_Category__c=='Sponsorship') {
                            //If the Est_On_Air_Sponsorship_Cost__c of the product of the opportunity is null it was set with zero
                            if(oli.Est_On_Air_Sponsorship_Cost__c==null) oli.Est_On_Air_Sponsorship_Cost__c=0;
                            //We add the Est_On_Air_Sponsorship_Cost__c of "opportunity product" to the Est_On_Air_Sponsorship_Cost__c of the "opportunity"
                            opp.Est_On_Air_Sponsorship_Cost__c+=oli.Est_On_Air_Sponsorship_Cost__c;
                            //If the Final_On_Air_Sponsorship_Cost__c of the product of the opportunity is null it was set with zero
                            if(oli.Final_On_Air_Sponsorship_Cost__c==null) oli.Final_On_Air_Sponsorship_Cost__c=0;
                            //We add the Final_On_Air_Sponsorship_Cost__c of "opportunity product" to the Final_On_Air_Sponsorship_Cost__c of the "opportunity"
                            opp.Final_On_Air_Sponsorship_Cost__c+=oli.Final_On_Air_Sponsorship_Cost__c;
                        }
                        //If the Est_On_Air_Production_Cost__c of the product of the opportunity is null it was set with zero
                        if(oli.Est_On_Air_Production_Cost__c==null) oli.Est_On_Air_Production_Cost__c=0;
                        //We add the Est_On_Air_Production_Cost__c of "opportunity product" to the Est_On_Air_Production_Cost__c of the "opportunity"
                        opp.Est_On_Air_Production_Cost__c+=oli.Est_On_Air_Production_Cost__c;
                        //If the Final_On_Air_Production_Cost__c of the product of the opportunity is null it was set with zero
                        if(oli.Final_On_Air_Production_Cost__c==null) oli.Final_On_Air_Production_Cost__c=0;
                        //We add the Final_On_Air_Production_Cost__c of "opportunity product" to the Final_On_Air_Production_Costs__c of the "opportunity"
                        opp.Final_On_Air_Production_Costs__c+=oli.Final_On_Air_Production_Cost__c;
                    }
                    if(oli.Product_Category__c=='Ellentube' || oli.Product_Category__c=='Youtube' || oli.Product_Category__c=='Games') {
                        //We add the totalprice of "opportunity product" to the Digital_Integration_Fee__c of the "opportunity"
                        opp.Digital_Integration_Fee__c+=oli.TotalPrice;
                        if(oli.Product_Category__c=='Ellentube') {
                            //We add the totalprice of "opportunity product" to the Ellentube_Fee__c of the "opportunity"
                            opp.Ellentube_Fee__c+=oli.TotalPrice;
                            //If the Est_Ellentube_Cost__c of the product of the opportunity is null it was set with zero
                            if(oli.Est_Ellentube_Cost__c==null) oli.Est_Ellentube_Cost__c=0;
                            //We add the Est_Ellentube_Cost__c of "opportunity product" to the Est_Ellentube_Costs__c of the "opportunity"
                            opp.Est_Ellentube_Costs__c+=oli.Est_Ellentube_Cost__c;
                            //If the Final_Ellentube_Cost__c of the product of the opportunity is null it was set with zero
                            if(oli.Final_Ellentube_Cost__c==null) oli.Final_Ellentube_Cost__c=0;
                            //We add the Final_Ellentube_Cost__c of "opportunity product" to the Final_Ellentube_Costs__c of the "opportunity"
                            opp.Final_Ellentube_Costs__c+=oli.Final_Ellentube_Cost__c;
                        }
                        if(oli.Product_Category__c=='Youtube') {
                            //We add the totalprice of "opportunity product" to the YouTube_Fee__c of the "opportunity"
                            opp.YouTube_Fee__c+=oli.TotalPrice;
                            if(oli.Est_YouTube_Revenue__c=='Digital IO'){
                                //We add the TotalPrice*55% of "opportunity product" to the Est_YouTube_Revenue__c of the "opportunity"
                                opp.Est_YouTube_Revenue__c+=oli.TotalPrice*55/100;
                            }
                            if(oli.Est_YouTube_Revenue__c=='Paper'){
                                //We add the TotalPrice*-45% of "opportunity product" to the Est_YouTube_Revenue__c of the "opportunity"
                                opp.Est_YouTube_Revenue__c+=oli.TotalPrice*(-45)/100;
                            }
                            //If the Final_YouTube_Revenue__c of the product of the opportunity is null it was set with zero
                            if(oli.Final_YouTube_Revenue__c==null) oli.Final_YouTube_Revenue__c=0;
                            //We add the Final_YouTube_Revenue__c of "opportunity product" to the Final_YouTube_Revenue__c of the "opportunity"
                            opp.Final_YouTube_Revenue__c+=oli.Final_YouTube_Revenue__c;
                        }
                        if(oli.Product_Category__c=='Games') {
                            /*if(oli.Product_Sub_Category__c=='Heads Up') {
                                //We add the totalprice of "opportunity product" to the Heads_Up_Fee__c of the "opportunity"
                                opp.Heads_Up_Fee__c+=oli.TotalPrice;
                            }
                            if(oli.Product_Sub_Category__c=='Psych') {
                                //We add the totalprice of "opportunity product" to the Psych_Fee__c of the "opportunity"
                                opp.Psych_Fee__c+=oli.TotalPrice;
                            }
                            if(oli.Product_Sub_Category__c=='Hot Hands') {
                                //We add the totalprice of "opportunity product" to the Hot_Hands_Fee__c of the "opportunity"
                                opp.Hot_Hands_Fee__c+=oli.TotalPrice;
                            }
                            if(oli.Product_Sub_Category__c=='Emoji') {
                                //We add the totalprice of "opportunity product" to the Emoji_App_Fee__c of the "opportunity"
                                opp.Emoji_App_Fee__c+=oli.TotalPrice;
                            }*/
                            //Code Added by Mayank Desai on 02/20/2019 for ER-2310 - TPX games Rollup + Start
                            opp.Games_Fee__c+=oli.TotalPrice;
                            if(oli.Est_Games_Cost__c==null) oli.Est_Games_Cost__c=0;
                            opp.Est_Games_Cost__c+=oli.Est_Games_Cost__c;
                            if(oli.Final_Games_Cost__c==null) oli.Final_Games_Cost__c=0;
                            opp.Final_Games_Cost__c+= oli.Final_Games_Cost__c;
                             //Code Added by Mayank Desai on 02/20/2019 for ER-2310 - TPX games Rollup + END
                        }
                    }
                    if(oli.Product2.Name=='Twitter Amplify') {
                        //We add the totalprice of "opportunity product" to the Ellen_Sales_Led_Value_of_Program__c of the "opportunity"
                        if(oli.Ellen_Sales_Led_Est_Cost__c!=null || oli.Ellen_Sales_Led_Final_Cost__c!=null) opp.Ellen_Sales_Led_Value_of_Program__c+=oli.TotalPrice;
                        //If the Ellen_Sales_Led_Est_Cost__c of the product of the opportunity is null it was set with zero
                        if(oli.Ellen_Sales_Led_Est_Cost__c==null) oli.Ellen_Sales_Led_Est_Cost__c=0;
                        //We add the Ellen_Sales_Led_Est_Cost__c of "opportunity product" to the Ellen_Sales_Led_Est_Costs__c of the "opportunity"
                        opp.Ellen_Sales_Led_Est_Costs__c+=oli.Ellen_Sales_Led_Est_Cost__c;
                        //If the Ellen_Sales_Led_Final_Cost__c of the product of the opportunity is null it was set with zero
                        if(oli.Ellen_Sales_Led_Final_Cost__c==null) oli.Ellen_Sales_Led_Final_Cost__c=0;
                        //We add the Ellen_Sales_Led_Final_Cost__c of "opportunity product" to the Ellen_Sales_Led_Final_Costs__c of the "opportunity"
                        opp.Ellen_Sales_Led_Final_Costs__c+=oli.Ellen_Sales_Led_Final_Cost__c;
                        //If the Twitter_Sales_Led_Est_Fee_to_Ellen__c of the product of the opportunity is null it was set with zero
                        if(oli.Twitter_Sales_Led_Est_Fee_to_Ellen__c==null) oli.Twitter_Sales_Led_Est_Fee_to_Ellen__c=0;
                        //We add the Twitter_Sales_Led_Est_Fee_to_Ellen__c of "opportunity product" to the Twitter_Sales_Led_Est_Fee_to_Ellen__c of the "opportunity"
                        opp.Twitter_Sales_Led_Est_Fee_to_Ellen__c+=oli.Twitter_Sales_Led_Est_Fee_to_Ellen__c;
                        //If the Twitter_Sales_Led_Final_Fee_to_Ellen__c of the product of the opportunity is null it was set with zero
                        if(oli.Twitter_Sales_Led_Final_Fee_to_Ellen__c==null) oli.Twitter_Sales_Led_Final_Fee_to_Ellen__c=0;
                        //We add the Twitter_Sales_Led_Final_Fee_to_Ellen__c of "opportunity product" to the Twitter_Sales_Led_Final_Fee_to_Ellen__c of the "opportunity"
                        opp.Twitter_Sales_Led_Final_Fee_to_Ellen__c+=oli.Twitter_Sales_Led_Final_Fee_to_Ellen__c;
                        
                    }
                    if(oli.Prizing_Gift_Card_Value_Paid__c=='Incremental to Fee') {
                        //If the Prizing_Gift_Card_Value__c of the product of the opportunity is null it was set with zero
                        if(oli.Prizing_Gift_Card_Value__c==null) oli.Prizing_Gift_Card_Value__c=0;
                        //We add the Prizing_Gift_Card_Value__c of "opportunity product" to the Prizing_Incremental_to_Fee__c of the "opportunity"
                        opp.Prizing_Incremental_to_Fee__c+=oli.Prizing_Gift_Card_Value__c;
                    }
                    if(oli.Prizing_Gift_Card_Value_Paid__c=='Taken out of On-Air Integration Fee') {
                        //If the Prizing_Gift_Card_Value__c of the product of the opportunity is null it was set with zero
                        if(oli.Prizing_Gift_Card_Value__c==null) oli.Prizing_Gift_Card_Value__c=0;
                        //We add the Prizing_Gift_Card_Value__c of "opportunity product" to the Prizing_Taken_out_of_On_Air_Int_Fee__c of the "opportunity"
                        opp.Prizing_Taken_out_of_On_Air_Int_Fee__c+=oli.Prizing_Gift_Card_Value__c;
                    }
                    if(oli.Prizing_Gift_Card_Value_Paid__c=='Taken out of Digital Integration Fee') {
                        //If the Prizing_Gift_Card_Value__c of the product of the opportunity is null it was set with zero
                        if(oli.Prizing_Gift_Card_Value__c==null) oli.Prizing_Gift_Card_Value__c=0;
                        //We add the Prizing_Gift_Card_Value__c of "opportunity product" to the Prizing_Taken_out_of_Digital_Int_Fee__c of the "opportunity"
                        opp.Prizing_Taken_out_of_Digital_Int_Fee__c+=oli.Prizing_Gift_Card_Value__c;
                    }
                    if(oli.Prizing_Gift_Card_Value_Paid__c=='Given by Client') {
                        //If the Prizing_Gift_Card_Value__c of the product of the opportunity is null it was set with zero
                        if(oli.Prizing_Gift_Card_Value__c==null) oli.Prizing_Gift_Card_Value__c=0;
                        //We add the Prizing_Gift_Card_Value__c of "opportunity product" to the Prizing_Given_by_Client__c of the "opportunity"
                        opp.Prizing_Given_by_Client__c+=oli.Prizing_Gift_Card_Value__c;
                    }
                    //Calculates the number of these products: Standard Box, Premium box
                    if(oli.Product2.Name == 'Standard Box Product' || oli.Product2.Name == 'Premium Box Product') opp.Number_of_Product_s__c++;
                    if(oli.Product2.Name == 'Redemption Box Product') opp.Number_of_Redemption_s__c++;
                    if(oli.Product2.Name == 'Box Sponsorship' && oli.Revenue_Allocation__c != null) opp.Total_Sponsorship__c = opp.Total_Sponsorship__c + oli.Revenue_Allocation__c;
                    if(oli.Product2.Name == 'Box Shipping Sponsor' && oli.Revenue_Allocation__c != null) opp.Total_Shipping_Sponsor__c = opp.Total_Shipping_Sponsor__c + oli.Revenue_Allocation__c;
                    if(oli.MSRP__c != null) opp.Value_of_Product_s__c = opp.Value_of_Product_s__c + oli.MSRP__c;
                    if(oli.Total_Wholesale_Cost__c != null) opp.Total_Wholesale_Cost__c = opp.Total_Wholesale_Cost__c + oli.Total_Wholesale_Cost__c;
        }
        
        //We subtract the Prizing_Taken_out_of_Digital_Int_Fee__c of "opportunity" to the Est_Ellentube_Costs__c of "opportunity"
        opp.Est_Ellentube_Costs__c=opp.Est_Ellentube_Costs__c-opp.Prizing_Taken_out_of_Digital_Int_Fee__c;
        //We subtract the Prizing_Taken_out_of_Digital_Int_Fee__c of "opportunity" to the Final_Ellentube_Costs__c of "opportunity"
        opp.Final_Ellentube_Costs__c=opp.Final_Ellentube_Costs__c-opp.Prizing_Taken_out_of_Digital_Int_Fee__c;
        
        //Variable used to store the amount of Est_On_Air_Sponsorship_Cost__c or Final_On_Air_Sponsorship_Cost__c
        Decimal OnAirSponsorshipCostForEst = opp.Est_On_Air_Sponsorship_Cost__c;
        if(OnAirSponsorshipCostForEst==null || OnAirSponsorshipCostForEst==0) OnAirSponsorshipCostForEst = opp.Final_On_Air_Sponsorship_Cost__c;
        //Variable used to store the amount of Est_On_Air_Production_Cost__c or Final_On_Air_Production_Costs__c
        Decimal OnAirProductionCostForEst = opp.Est_On_Air_Production_Cost__c;
        if(OnAirProductionCostForEst==null || OnAirProductionCostForEst==0) OnAirProductionCostForEst = opp.Final_On_Air_Production_Costs__c;
        //Calculation of the amount Est_Net_On_Air_Income__c
        opp.Est_Net_On_Air_Income__c=opp.On_Air_Integration_Fee__c-(OnAirSponsorshipCostForEst+OnAirProductionCostForEst)-opp.Prizing_Taken_out_of_On_Air_Int_Fee__c;
        
        //Variable used to store the amount of Final_On_Air_Sponsorship_Cost__c or Est_On_Air_Sponsorship_Cost__c
        Decimal OnAirSponsorshipCostForFinal = opp.Final_On_Air_Sponsorship_Cost__c;
        if(OnAirSponsorshipCostForFinal==null || OnAirSponsorshipCostForFinal==0) OnAirSponsorshipCostForFinal = opp.Est_On_Air_Sponsorship_Cost__c;
        //Variable used to store the amount of Final_On_Air_Production_Costs__c or Est_On_Air_Production_Cost__c
        Decimal OnAirProductionCostForFinal = opp.Final_On_Air_Production_Costs__c;
        if(OnAirProductionCostForFinal==null || OnAirProductionCostForFinal==0) OnAirProductionCostForFinal = opp.Est_On_Air_Production_Cost__c;
        //Calculation of the amount Est_Net_On_Air_Income__c
        opp.Final_Net_On_Air_Income__c=opp.On_Air_Integration_Fee__c-(OnAirSponsorshipCostForFinal+OnAirProductionCostForFinal)-opp.Prizing_Taken_out_of_On_Air_Int_Fee__c;
        
        //Calculation of the amount Ellen_Sales_Led_Value_of_Ellen_s_Portio__c
        opp.Ellen_Sales_Led_Value_of_Ellen_s_Portio__c=opp.Ellen_Sales_Led_Value_of_Program__c*50/100;
        
        //Variable used to store the amount of Est_Ellentube_Costs__c or Final_Ellentube_Costs__c
        Decimal EllentubeCostsForEst = opp.Est_Ellentube_Costs__c;
        if(EllentubeCostsForEst==null || EllentubeCostsForEst==0) EllentubeCostsForEst = opp.Final_Ellentube_Costs__c;
        //Variable used to store the amount of Ellen_Sales_Led_Est_Costs__c or Ellen_Sales_Led_Final_Costs__c
        Decimal EllenSalesLedCostsForEst = opp.Ellen_Sales_Led_Est_Costs__c;
        if(EllenSalesLedCostsForEst==null || EllenSalesLedCostsForEst==0) EllenSalesLedCostsForEst = opp.Ellen_Sales_Led_Final_Costs__c;
        //Calculation of the amount Est_Net_Ellentube_Income__c
        //Code Modified by Ajeet Tripathi on 23/Sep/2020 for ER-006631 - ELLEN(TPX): Calculation formula change for Est Net Ellentube Income
        // opp.Est_Net_Ellentube_Income__c=opp.Ellentube_Fee__c-(EllentubeCostsForEst+EllenSalesLedCostsForEst);
        if(opp.Twitter_Sales_Led_Est_Fee_to_Ellen__c>0)
            opp.Est_Net_Ellentube_Income__c=opp.Twitter_Sales_Led_Est_Fee_to_Ellen__c;
        else
            opp.Est_Net_Ellentube_Income__c=opp.Ellentube_Fee__c-(EllentubeCostsForEst+EllenSalesLedCostsForEst);
        //Variable used to store the amount of Final_Ellentube_Costs__c or Est_Ellentube_Costs__c
        Decimal EllentubeCostsForFinal = opp.Final_Ellentube_Costs__c;
        if(EllentubeCostsForFinal==null || EllentubeCostsForFinal==0) EllentubeCostsForFinal = opp.Est_Ellentube_Costs__c;
        //Variable used to store the amount of Ellen_Sales_Led_Final_Costs__c or Ellen_Sales_Led_Est_Costs__c
        Decimal EllenSalesLedCostsForFinal = opp.Ellen_Sales_Led_Final_Costs__c;
        if(EllenSalesLedCostsForFinal==null || EllenSalesLedCostsForFinal==0) EllenSalesLedCostsForFinal = opp.Ellen_Sales_Led_Est_Costs__c;
        //Calculation of the amount Final_Net_Ellentube_Income__c
        //Code Modified by Ajeet Tripathi on 02/June/2020 for ER-003626 - ELLEN(TPX): Calculation formula change for Final Net Ellentube Income
        //opp.Final_Net_Ellentube_Income__c=opp.Ellentube_Fee__c-(EllentubeCostsForFinal+EllenSalesLedCostsForFinal);
        //Code Modified by Ajeet Tripathi on 23/Sep/2020 for ER-006631 - ELLEN(TPX): Calculation formula change for Final Net Ellentube Income
        //opp.Final_Net_Ellentube_Income__c=opp.Ellentube_Fee__c-(EllentubeCostsForFinal+EllenSalesLedCostsForFinal) - opp.Twitter_Sales_Led_Final_Fee_to_Ellen__c;
        
        if(opp.Twitter_Sales_Led_Final_Fee_to_Ellen__c>0) 
            opp.Final_Net_Ellentube_Income__c=opp.Twitter_Sales_Led_Final_Fee_to_Ellen__c;
        else
            opp.Final_Net_Ellentube_Income__c=opp.Ellentube_Fee__c-(EllentubeCostsForFinal+EllenSalesLedCostsForFinal);
        //Calculation of the amount Est_Heads_Up_Net_Income__c
        /*if(opp.Est_Heads_Up_Cost__c!=null && opp.Est_Heads_Up_Cost__c!=0) opp.Est_Heads_Up_Net_Income__c=opp.Heads_Up_Fee__c-opp.Est_Heads_Up_Cost__c;
        //else opp.Est_Heads_Up_Net_Income__c=opp.Heads_Up_Fee__c-opp.Final_Heads_Up_Cost__c;
        //Calculation of the amount Final_Heads_Up_Net_Income__c
        if(opp.Final_Heads_Up_Cost__c!=null && opp.Final_Heads_Up_Cost__c!=0) opp.Final_Heads_Up_Net_Income__c=opp.Heads_Up_Fee__c-opp.Final_Heads_Up_Cost__c;
        else opp.Final_Heads_Up_Net_Income__c=opp.Heads_Up_Fee__c-opp.Est_Heads_Up_Cost__c;*/
        
        /*//Calculation of the amount Est_Psych_Net_Income__c
        if(opp.Est_Psych_Cost__c!=null && opp.Est_Psych_Cost__c!=0) opp.Est_Psych_Net_Income__c=opp.Psych_Fee__c-opp.Est_Psych_Cost__c;
        else opp.Est_Psych_Net_Income__c=opp.Psych_Fee__c-opp.Final_Psych_Costs__c;
        //Calculation of the amount Final_Psych_Net_Income__c
        if(opp.Final_Psych_Costs__c!=null && opp.Final_Psych_Costs__c!=0) opp.Final_Psych_Net_Income__c=opp.Psych_Fee__c-opp.Final_Psych_Costs__c;
        else opp.Final_Psych_Net_Income__c=opp.Psych_Fee__c-opp.Est_Psych_Cost__c;*/
        
        //Calculation of the amount Est_Hot_Hands_Net_Income__c
        /*if(opp.Est_Hot_Hands_Cost__c!=null && opp.Est_Hot_Hands_Cost__c!=0) opp.Est_Hot_Hands_Net_Income__c=opp.Hot_Hands_Fee__c-opp.Est_Hot_Hands_Cost__c;
        else opp.Est_Hot_Hands_Net_Income__c=opp.Hot_Hands_Fee__c-opp.Final_Hot_Hands_Cost__c;
        //Calculation of the amount Final_Hot_Hands_Net_Income__c
        if(opp.Final_Hot_Hands_Cost__c!=null && opp.Final_Hot_Hands_Cost__c!=0) opp.Final_Hot_Hands_Net_Income__c=opp.Hot_Hands_Fee__c-opp.Final_Hot_Hands_Cost__c;
        else opp.Final_Hot_Hands_Net_Income__c=opp.Hot_Hands_Fee__c-opp.Est_Hot_Hands_Cost__c;*/
        
        //Calculation of the amount Est_Emoji_App_Net_Income__c
        /*if(opp.Est_Emoji_App_Cost__c!=null && opp.Est_Emoji_App_Cost__c!=0) opp.Est_Emoji_App_Net_Income__c=opp.Emoji_App_Fee__c-opp.Est_Emoji_App_Cost__c;
        else opp.Est_Emoji_App_Net_Income__c=opp.Emoji_App_Fee__c-opp.Final_Emoji_App_Costs__c;
        //Calculation of the amount Final_Emoji_App_Net_Income__c
        if(opp.Final_Emoji_App_Costs__c!=null && opp.Final_Emoji_App_Costs__c!=0) opp.Final_Emoji_App_Net_Income__c=opp.Emoji_App_Fee__c-opp.Final_Emoji_App_Costs__c;
        else opp.Final_Emoji_App_Net_Income__c=opp.Emoji_App_Fee__c-opp.Est_Emoji_App_Cost__c; */
        
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup + Start
        //Calculation of Games Fees
        //opp.Games_Fee__c = opp.Emoji_App_Fee__c + opp.Heads_Up_Fee__c + opp.Hot_Hands_Fee__c + opp.Psych_Fee__c;        
        //Calculation of the Estimated Games Net Income        
        //opp.EST_Games_Net_Income__c= opp.Est_Heads_Up_Net_Income__c + opp.Est_Psych_Net_Income__c + opp.Est_Hot_Hands_Net_Income__c + opp.Est_Emoji_App_Net_Income__c;
        //Calculation of the Final Games Net Income
        //opp.Final_Games_Net_Income__c = opp.Final_Heads_Up_Net_Income__c + opp.Final_Psych_Net_Income__c + opp.Final_Hot_Hands_Net_Income__c + opp.Final_Emoji_App_Net_Income__c;
        //Calculation of the amount EST_Games_Net_Income__c
        if(opp.Est_Games_Cost__c!=null && opp.Est_Games_Cost__c!=0) opp.EST_Games_Net_Income__c=opp.Games_Fee__c-opp.Est_Games_Cost__c;
        else opp.EST_Games_Net_Income__c=opp.Games_Fee__c-opp.Final_Games_Cost__c;
        //Calculation of the amount Final_Games_Net_Income__c
        if(opp.Final_Games_Cost__c!=null && opp.Final_Games_Cost__c!=0) opp.Final_Games_Net_Income__c=opp.Games_Fee__c-opp.Final_Games_Cost__c;
        else opp.Final_Games_Net_Income__c=opp.Games_Fee__c-opp.Est_Games_Cost__c;
        //Calculating Esitmated Games Cost
        //opp.Est_Games_Cost__c= opp.Est_Heads_Up_Cost__c + opp.Est_Psych_Cost__c + opp.Est_Hot_Hands_Cost__c + opp.Est_Emoji_App_Cost__c;
        //Calculating Final Games Cost                    
        //opp.Final_Games_Cost__c= opp.Final_Heads_Up_Cost__c + opp.Final_Psych_Costs__c + opp.Final_Hot_Hands_Cost__c + opp.Final_Emoji_App_Costs__c;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup + End
        update opp;
        return 'Done';
    }
}