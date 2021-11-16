/*
* To exportt Promotion and Promotion Title records to Marvin when webservice is called.
* Export only those Promotion and related records having 'Send to MArvin = True'
* After export, update 'Send to Marvin' to False
*
* Author:          Date:           Description
* Ishwar Kabra   06-Jan-15         First Draft
*/

global class ExportPromotionTitles
{
    global class PromotionDetails
    {
        webservice String  Id;
        webservice String  Promotion_Name;
        webservice String  Account;
        webservice String  Channels;
        webservice String  Country;
        webservice String  Country_Group;
        webservice String  Promotion_Currency;
        webservice Date    End_Date;
        webservice String  Formats;
        webservice Decimal Max_Retail_Price;
        webservice String  Offer_Details;
        webservice String  Placement_Specifics;
        webservice String  Promoted_Product_Visibility;
        webservice String  Description;
        webservice String  Promotion_Grouping;
        webservice String  Promotion_Number;
        webservice String  Promotion_Owner;
        webservice String  Status;
        webservice String  Promotion_Type;
        webservice String  Retailer_Contact;
        webservice String  Retailer_Requirements;
        webservice Boolean Send_to_Marvin;
        webservice Date    Start_Date;
        webservice String  Tactic;
        webservice boolean Warner_Only;
        
        webservice list<PromotionTitleDetails> promotionTitleList = new list<PromotionTitleDetails>() ;
    }
    global class PromotionTitleDetails
    {
        webservice String  Id;
        webservice String  PromotionTitle_Name;
        webservice String  Box_Set_Name;
        webservice String  Business_Unit;
        webservice Date    Cable_License_End_Date;
        webservice Date    Cable_License_Start_Date;
        webservice String  Channel;
        webservice String  Comments;
        webservice String  Content_Type;
        webservice Decimal Episode;
        webservice String  Format;
        webservice String  Genre;
        webservice Boolean Live;
        webservice Date    Live_Date;
        webservice String  Local_Name;
        webservice String  MPM;
        webservice String  Notes;
        webservice String  Other_Expense_Details;
        webservice Decimal Other_Expenses;
        webservice Decimal Pre_Promo_Retail_Price;
        webservice Decimal Pre_Promo_Rev_Share;
        webservice Decimal Pre_Promo_Wholesale_Cost;
        webservice String  PromotionID;
        webservice String  Promotion_Price_Tier;
        webservice Decimal Promotion_Retail_Price;
        webservice Decimal Promotion_Rev_Share;
        webservice Date    Promotion_Start_Date;
        webservice Decimal Promotion_Wholesale_Cost;
        webservice String  Retailer_Product_ID;
        webservice String  Retailer_Title_ID;
        webservice String  Season;
        webservice String  Title;
        webservice String  Video_Version;
        webservice Decimal Viewing_Period;
    }
    
    webservice static List<PromotionDetails> exportPromotionDetails()
    {
        list<PromotionDetails> promotionList = new list<PromotionDetails>();
        list<Promotion__c> promotionsToBeUpdated = new list<Promotion__c>();
        
        for(Promotion__c prom : [SELECT
                                 Id,/*Account__c,*/Channels__c,/*Country_Group__c,*/Country__c,/*Currency__c,*/Description__c,
                                 End_Date__c,Formats__c,/*Max_Retail_Price__c,*/Name,/*Offer_Details__c,Placement_Specifics__c,*/
                                 /*Promoted_Product_Visibility__c,*/Promotion_Grouping__c,Promotion_Number__c,Promotion_Owner__c,
                                 /*Promotion_Type__c,Retailer_Contact__c,Retailer_Requirements__c,Send_to_Marvin__c,*/
                                 Start_Date__c,Status__c,SystemModstamp,/*Tactic__c,Warner_Only__c,*/
                                 (
                                     SELECT
                                     Id,/*Box_Set_Name__c,Business_Unit__c,Cable_License_End_Date__c,Cable_License_Start_Date__c,*/Channel__c,
                                     Comments__c,/*Content_Type__c,Episode__c,*/Format__c,/*Genre__c,Live_Date__c,Live__c,Local_Name__c,MPM__c,*/
                                     Name,/*Notes__c,Other_Expenses__c,Other_Expense_Details__c,Pre_Promo_Retail_Price__c,Pre_Promo_Rev_Share__c,*/
                                     /*Pre_Promo_Wholesale_Cost__c,*/PromotionID__c,/*Promotion_Price_Tier__c,Promotion_Retail_Price__c,*/
                                     /*Promotion_Rev_Share__c,Promotion_Start_Date__c,Promotion_Wholesale_Cost__c,Retailer_Product_ID__c,*/
                                     /*Retailer_Title_ID__c,Season__c,*/Title__c,Video_Version__c/*,Viewing_Period__c*/
                                     FROM Promotion_Titles__r
                                 )
                                 FROM Promotion__c /*where Send_to_Marvin__c = True*/
                                ]) 
        {
            PromotionDetails promotion = new PromotionDetails();
            promotion.Id = prom.Id;
            promotion.Promotion_Name = prom.Name;
            //promotion.Account = prom.Account__c;
            promotion.Channels = prom.Channels__c;
            promotion.Country = prom.Country__c;
            //promotion.Country_Group = prom.Country_Group__c;
            //promotion.Promotion_Currency = prom.Currency__c;
            promotion.End_Date = prom.End_Date__c;
            promotion.Formats = prom.Formats__c;
            //promotion.Max_Retail_Price = prom.Max_Retail_Price__c;
            //promotion.Offer_Details = prom.Offer_Details__c;
            //promotion.Placement_Specifics = prom.Placement_Specifics__c;
            //promotion.Promoted_Product_Visibility = prom.Promoted_Product_Visibility__c;
            promotion.Description = prom.Description__c;
            promotion.Promotion_Grouping = prom.Promotion_Grouping__c;
            promotion.Promotion_Number = prom.Promotion_Number__c;
            promotion.Promotion_Owner = prom.Promotion_Owner__c;
            promotion.Status = prom.Status__c;
            //promotion.Promotion_Type = prom.Promotion_Type__c;
            //promotion.Retailer_Contact = prom.Retailer_Contact__c;
            //promotion.Retailer_Requirements = prom.Retailer_Requirements__c;
            //promotion.Send_to_Marvin = prom.Send_to_Marvin__c;
            promotion.Start_Date = prom.Start_Date__c;
            //promotion.Tactic = prom.Tactic__c;
            //promotion.Warner_Only = prom.Warner_Only__c;

            
            //Get all child promotion titles for Prom
            for(Promotion_Title__c pt : prom.Promotion_Titles__r)
            {
                PromotionTitleDetails promotionTitle = new PromotionTitleDetails();
                
                promotionTitle.Id = pt.Id;
                promotionTitle.PromotionTitle_Name = pt.Name;
                //promotionTitle.Box_Set_Name = pt.Box_Set_Name__c;
                //promotionTitle.Business_Unit = pt.Business_Unit__c;
                //promotionTitle.Cable_License_End_Date = pt.Cable_License_End_Date__c;
                //promotionTitle.Cable_License_Start_Date = pt.Cable_License_Start_Date__c;
                promotionTitle.Channel = pt.Channel__c;
                promotionTitle.Comments = pt.Comments__c;
                //promotionTitle.Content_Type = pt.Content_Type__c;
                //promotionTitle.Episode = pt.Episode__c;
                promotionTitle.Format = pt.Format__c;
                //promotionTitle.Genre = pt.Genre__c;
                //promotionTitle.Live = pt.Live__c;
                //promotionTitle.Live_Date = pt.Live_Date__c;
                //promotionTitle.Local_Name = pt.Local_Name__c;
                //promotionTitle.MPM = pt.MPM__c;
                //promotionTitle.Notes = pt.Notes__c;
                //promotionTitle.Other_Expense_Details = pt.Other_Expense_Details__c;
                //promotionTitle.Other_Expenses = pt.Other_Expenses__c;
                //promotionTitle.Pre_Promo_Retail_Price = pt.Pre_Promo_Retail_Price__c;
                //promotionTitle.Pre_Promo_Rev_Share = pt.Pre_Promo_Rev_Share__c;
                //promotionTitle.Pre_Promo_Wholesale_Cost = pt.Pre_Promo_Wholesale_Cost__c;
                promotionTitle.PromotionID = pt.PromotionID__c;
                //promotionTitle.Promotion_Price_Tier = pt.Promotion_Price_Tier__c;
                //promotionTitle.Promotion_Retail_Price = pt.Promotion_Retail_Price__c;
                //promotionTitle.Promotion_Rev_Share = pt.Promotion_Rev_Share__c;
                //promotionTitle.Promotion_Start_Date = pt.Promotion_Start_Date__c;
                //promotionTitle.Promotion_Wholesale_Cost = pt.Promotion_Wholesale_Cost__c;
                //promotionTitle.Retailer_Product_ID = pt.Retailer_Product_ID__c;
                //promotionTitle.Retailer_Title_ID = pt.Retailer_Title_ID__c;
                //promotionTitle.Season = pt.Season__c;
                promotionTitle.Title = pt.Title__c;
                promotionTitle.Video_Version = pt.Video_Version__c;
                //promotionTitle.Viewing_Period = pt.Viewing_Period__c;
                
                promotion.promotionTitleList.add(promotionTitle);
            }
            promotionList.add(promotion);
            
            // Set Send_to_MArvin__c to FALSE 
            //prom.Send_to_Marvin__c = false; commented for testing
            //promotionsToBeUpdated.add(prom);
        }
        
        System.debug('MYDEBUG pdList size : ' + promotionList.size());
        if(promotionsToBeUpdated.size() > 0)
        {
            update promotionsToBeUpdated;
        }
        
        return promotionList;
    }
}