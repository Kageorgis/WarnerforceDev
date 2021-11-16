public class WB_ClientAvailTempPriceWrapper {
    
  public String clientAvailID;
  public String dealProductID;
  public Decimal price;
  public String priceTier;
  public Decimal episodePrice;
  public String episodePriceTier;
  public Date priceStartDate;
  public Date priceEndDate;
  public String dealID;
  public String dealStatus;
  
  public String promotionID;//ER-2559
  public String promoTitleDetailID;//ER-2559
  public Promotion_Title_Detail__c promoTitleDetailRec;//ER-2559
  public String promotionStatus;//ER-2559
  public String rateCardId;//ER-2559
  
  public String priceType;//Deafult to 'TEMP'
  public String currencyCode;
  public String priceStatus;//Active,Cancelled
  public String category;
  public String status; //Success,Failed
  public String[] messages;
}