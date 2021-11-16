/*****************************************************************************
 * Class Name:      DPT_PromotionMultiselect_Controller
 * Description:     To dispaly multi-select Promotion Countries as related list
 *                  on  Promotion Object 
 *
 * Author:          Date:           Description
 * Rashmi           2/4/2014        Created initial version of class 
 *****************************************************************************/
public with sharing class DPT_PromotionMultiselect_Controller {
    public SelectOption[] allCountries{ get; set; } // list to display all the countries    
    public SelectOption[] selectedCountriesRecords { get; set; }// list of selected countries  
    public boolean noCountryFoundFlag {get;set;}
    public boolean saveMessageFlag{get;set;} 
    public final Promotion__c promo;
    list<User> userDetail;  
    list<Promotion_Countries__c> promoCountriesList;
    map<string,string> mapOfStorefrontCountries;
    public DPT_PromotionMultiselect_Controller(ApexPages.StandardController controller) {
        noCountryFoundFlag = false;
        saveMessageFlag=false;
        this.promo= (Promotion__c)controller.getRecord();
        //User Info validation for listing countries whose territory match with user's territory 
        userDetail = new list<User>(); 
        mapOfStorefrontCountries = new map<string,string>();
        userDetail =[SELECT id,ProfileId,Profile.Name,UserType,Territory__c  from User where id =: Userinfo.getUserId() ]; 
        Promotion__c proms = [select Id,Country__c/*,Currency__c,Account__c*/ from Promotion__c where Id=: promo.Id ];
        list<Account_Role__c> accRoleRec = [select Account__c,Role__c from Account_Role__c where /*Account__c =: proms.Account__c AND */ User__c =: userDetail[0].Id ];               
        
        if(accRoleRec.size() !=0 && accRoleRec != NULL){
                    
            list<country__c> availableCountryList = new list<country__c>();
            availableCountryList= [select Id, name from country__c where territory__c =: userDetail[0].Territory__c order by name];
            List<Agreement__c> lst_storefronts = new List<Agreement__c>();
            lst_storefronts = [SELECT Country__c,Country__r.Territory__c FROM Agreement__c /*WHERE Account__c = :proms.Account__c AND Status__c = 'Active' */ /*AND Pricing_Currency__c like :proms.Currency__c.substring(0,3)*/];
            if(availableCountryList.size() == 0 || availableCountryList == NULL || lst_storefronts.size() == 0 || lst_storefronts == NULL){
                noCountryFoundFlag = true;
            }else{
                noCountryFoundFlag = false;
                allCountries = new list<SelectOption>();                
                selectedCountriesRecords = new list<SelectOption>();
                promoCountriesList = [select id,Country__c,Country__r.Name,PromotionID__c from Promotion_Countries__c where PromotionID__c =: proms.Id];
                for(Promotion_Countries__c promoConRec : promoCountriesList ){
                    selectedCountriesRecords.add(new SelectOption(promoConRec.country__c, promoConRec.Country__r.Name));                      
                }
                // comparing list of countries which are available in user's territory and has active storefronts available.
                for(country__c country:availableCountryList){ 
                    for(Agreement__c storeFrntRec: lst_storefronts){                        
                        if(country.Id == storeFrntRec.Country__c){
                            mapOfStorefrontCountries.put(country.Id,storeFrntRec.Id);
                            integer counter = 0;
                            for(SelectOption selectedCountry:selectedCountriesRecords){
                                string selectedCountriesId = selectedCountry.getValue();
                                if(selectedCountriesId == country.Id){
                                     counter++;
                                }
                            }
                            if(counter == 0){
                                allCountries.add(new SelectOption(country.Id, country.Name));  
                            }
                            
                        }
                    }           
                              
                }
           } 
        }else noCountryFoundFlag = true;
        }
/**************************************************************************
* Method Name:     saveCountries
* Description:     Insert selected Promotion Countries on click of save
*                  button
* Parameters:      NA
* Returns:         NULL
**************************************************************************/
        public pageReference saveCountries(){
            list<Promotion_Countries__c> promoCountryList = new list<Promotion_Countries__c>();
            list<Promotion_Countries__c> PromoCountriesDelete = new list<Promotion_Countries__c>();
            set<string> selectedCountriesIdsList = new set<string>();
            if(selectedCountriesRecords!= null){
                for(SelectOption selectedCountry:selectedCountriesRecords ){
                    string selectedCountryIds= selectedCountry.getValue();
                    selectedCountriesIdsList.add(selectedCountryIds);
                    integer counter = 0;
                    for(Promotion_Countries__c promoConRec : promoCountriesList ){
                        if(promoConRec.country__c == selectedCountryIds){
                            counter++;
                            
                        }
                    }
                    if(counter == 0){                       
                        Promotion_Countries__c promoCountry = new Promotion_Countries__c ();
                        promoCountry.country__c = selectedCountryIds;
                        promoCountry.PromotionID__c = promo.Id;
                        promoCountry.StorefrontID__c = mapOfStorefrontCountries.get(selectedCountryIds);
                        promoCountryList.add(promoCountry );
                    }
                                       
                }
            }
            for(Promotion_Countries__c promoConRec : promoCountriesList ){
                if(selectedCountriesIdsList.contains(promoConRec.country__c)){                    
                }else PromoCountriesDelete.add(promoConRec);                        
            }  
            //insert promoCountryList;
            if(PromoCountriesDelete.size() !=0 && PromoCountriesDelete != NULL){
                Database.DeleteResult[] deleteResult  = Database.delete(PromoCountriesDelete, false); 
                if(deleteResult[0].isSuccess()){
                    saveMessageFlag = true;
                }
            }
            if(promoCountryList.size() !=0 && promoCountryList != NULL){
                Database.Saveresult[] insertResult  = Database.insert(promoCountryList, false);
                if(insertResult[0].isSuccess()){
                    saveMessageFlag = true;
                }
            }
                  
            return null;
        }
        
}