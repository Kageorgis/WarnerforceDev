/******* 
multiselect 
Creation Date- 6 Nov 2014
Description- This class is to show a custom multi select picklist of countries for the current User
Author- Harika Bondalapati
*******/
public class multiselect{
    Set<String> originalvalues = new Set<String>();
    Set<String> originalrightvalues = new Set<String>();
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    List<string> countryExisiting = new List<String>();
    Set<String> countryExistings = new Set<String>();
    public String endResult;
    public String userTer;
     public String CurrentUser;
    public final Promotion__c promo;
    public String PromoCountry; 
    public String accountid;
   Public List<Agreement__c> lst_storefronts{get;set;}
     
    
    public multiselect(ApexPages.StandardController stdController) {
        this.promo= (Promotion__c)stdController.getRecord();
        system.debug('promo--->>>'+this.promo);
        for(Promotion__c proms:[select Id,Country__c/*,Account__c*/ from Promotion__c where Id=:promo.Id limit 1]){
            system.debug('proms--->>>'+proms);
            system.debug('proms.Country__c--->>>'+proms.Country__c);
            //accountid = proms.Account__c;
            system.debug('accountid  --->>>'+accountid );
            if(proms.Country__c!=null){
                PromoCountry = proms.Country__c;
            }
        }
        system.debug('PromoCountry--->>>'+PromoCountry);
        
         lst_storefronts = [SELECT Country__c,Country__r.Territory__c FROM Agreement__c WHERE Account__c = :accountid];
         system.debug('lst_storefronts--->>>'+lst_storefronts);
        
        CurrentUser = UserInfo.getUserId();
        for(User usr:[select Territory__c from User where Id=:CurrentUser limit 1]){
          userTer = usr.Territory__c;
        }
        system.debug('userTer--->>>'+userTer);
        if(PromoCountry!=null){
          countryExisiting = PromoCountry.split(';');
        }
        system.debug('countryExisiting--->>>'+countryExisiting);
        if(countryExisiting.size()>0){
         countryExistings.addAll(countryExisiting);  
        }
        system.debug('countryExistings--->>>'+countryExistings);
        for(Country__c con:[select Name from Country__c where Territory__c=:userTer]){
        system.debug('con--->>>'+con);
                if(countryExistings.Contains(con.Name) && countryExistings.size()>0){
                  originalrightvalues.add(con.Name);
                }else{
                    originalvalues.add(con.Name);
                }
        }
        system.debug('originalrightvalues--->>>'+originalrightvalues);
        system.debug('originalvalues--->>>'+originalvalues);
        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(originalValues);
        rightvalues.addAll(originalrightvalues);
        system.debug('leftvalues--->>>'+leftvalues);
        system.debug('rightvalues--->>>'+rightvalues);   
    }
     
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        SaveRecord();
        return null;
    }
    /* public PageReference Save(){
     List<string> SaveList = new List<String>();
        SaveList.addAll(rightvalues);
        SaveList.sort();
        for(String s : SaveList){
           if(endResult!=null){
               endResult = endResult + ';' + s;
           }else{
               endResult = s;     
           }
        }    
        promo.Country__c = endResult;
        update promo;
        return null;
    }*/
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        SaveRecord();
        return null;
    }
    
    public void SaveRecord(){
     List<string> SaveList = new List<String>();
        endResult = null;
        SaveList.addAll(rightvalues);
        SaveList.sort();
        for(String s : SaveList){
           if(endResult!=null){
               endResult = endResult + ';' + s;
           }else{
               endResult = s;     
           }
        }    
        promo.Country__c = endResult;
        update promo;
    }
 
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList){
               options1.add(new SelectOption(s,s));
        }
        return options1;
    }
}