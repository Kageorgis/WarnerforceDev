/*
* Shows if the products are availables in a week for a month.
* Only show the status X, VIO and Open when the product has inventory or if the quantity in the inventory is higher than 0
*
* Author:          Date:           Description
* Angello Camacho  10-August-16    First Draft
*/

public class Inventory_CC {
    
    public String monthName {get;set;}
    public String yearName {get;set;}
    public List<Integer> lstWeeks {get;set;}
    public Integer month;
    public integer year;
    public Map<Integer, Map<String, Map<String, List<Inventory>>>> mapWeekMapTargetMapProductlstInventory {get;set;}
    Set<String> setTarget = new Set<String>();
    Map<Date, Integer> mapWeekNumber;
    public Map<Integer, Date> mapWeekNumberDate {get;set;}
    Map<String, String> mapTarget = new Map<String, String>();
    
    public Inventory_CC(){
        month = system.now().month();
        year = system.now().year();
        yearName = String.valueOf(year);        
        getMonthName();
        getNumberOfWednesdays(year, month);
        getTargets();
        getInventoryData();     
    }
    
    private void getTargets(){
        setTarget.add('E');
        setTarget.add('T');
        setTarget.add('T+');
        setTarget.add('M');
        setTarget.add('MM');
        
        mapTarget.put('E','E - Everyone');
        mapTarget.put('T','T - Teen');
        mapTarget.put('T+','T+ - Teen+');
        mapTarget.put('M','M - Mature');
        mapTarget.put('MM','MM - Mad');
    }
    
    private void getNumberOfWednesdays(Integer year, Integer month){
        mapWeekNumber = new Map<Date, Integer>();
        mapWeekNumberDate = new Map<Integer, Date>();
        Integer numberDays = date.daysInMonth(year, month);
        Integer numberWednesdays = 0;
        lstWeeks = new List<Integer>();
        for(Integer iloop=1; iloop<=numberDays; iloop++){
            Datetime dt = DateTime.newinstance(date.newinstance(year, month, iloop), Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt.format('EEEE');     
            if(dayOfWeek=='Wednesday'){
                numberWednesdays++;
                lstWeeks.add(numberWednesdays);
                mapWeekNumber.put(dt.date(),numberWednesdays);
                mapWeekNumberDate.put(numberWednesdays, dt.date());
            }
        }
    }
    
    public void getInventoryData(){
        Date dtStartDay = Date.newInstance(year, month, 15).toStartOfMonth();
        Date dtEndDay = dtStartDay.addMonths(1).addDays(-1);
        //get all the opportunity line items for an specific range of dates
        List<OpportunityLineItem> lstOli = [SELECT Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, Target_Cover_Rating__c, Onsale_Date__c, Opportunity.StageName, Quantity FROM OpportunityLineItem WHERE Target_Cover_Rating__c != NULL AND PricebookEntry.Product2.Family = 'Print' AND (Onsale_Date__c>=: dtStartDay AND Onsale_Date__c<=:dtEndDay) ORDER BY Onsale_Date__c];
        //if the lstOli is empty I add an empty opportunity line item
        if(lstOli.size()==0){
            lstOli.add(new OpportunityLineItem());
        }
        //get all the inventories
        List<Inventory__c> lstInventory = [SELECT Id, Product__r.Name, Target_Cover_Rating__c, Quantity__c, External_ID__c, Onsale_Availability__c, Availability_Date__c FROM Inventory__c WHERE Target_Cover_Rating__c != NULL AND Product_Family__c = 'Print'];
        Map<String, Inventory__c> mapInventoryWeekly = new Map<String, Inventory__c>();
        Map<String, Inventory__c> mapInventoryOnTimeChange = new Map<String, Inventory__c>();
        for(Inventory__c i : lstInventory){
            if(i.Onsale_Availability__c == 'Weekly'){
                mapInventoryWeekly.put(i.Product__r.Name+' '+i.Target_Cover_Rating__c, i);
            }
            else if(i.Onsale_Availability__c == 'One-Time Change' && i.Availability_Date__c!=null){
                mapInventoryOnTimeChange.put(i.Product__r.Name+' '+i.Target_Cover_Rating__c + ' One-Time Change ' + String.valueOf(i.Availability_Date__c).substring(0,10), i);
            }
        }
        mapWeekMapTargetMapProductlstInventory = new Map<Integer, Map<String, Map<String, List<Inventory>>>>();
        for(Integer w : lstWeeks){
            Map<String, Map<String, List<Inventory>>> mapTargetMapProductlstInventory = new Map<String, Map<String, List<Inventory>>>();
            for(String t : setTarget){  
                Map<String, List<Inventory>> mapProductlstInventory = new Map<String, List<Inventory>>();
                List<Inventory> lstInventaryC2 = new List<Inventory>();
                List<Inventory> lstInventaryC3 = new List<Inventory>();
                List<Inventory> lstInventaryC4 = new List<Inventory>();
                List<Inventory> lstInventary1RHP = new List<Inventory>();
                List<Inventory> lstInventary2RHP = new List<Inventory>();
                List<Inventory> lstInventary1Spread = new List<Inventory>();
                List<Inventory> lstInventaryCenterSpread = new List<Inventory>();
                List<Inventory> lstInventaryInteriorPage = new List<Inventory>();
                Integer quantity = 0;
                Integer quantityC2 = 0;
                Integer quantityC3 = 0;
                Integer quantityC4 = 0;
                Integer numberOlis = 0;
                Integer interiorPageQuantity = 0;
                Integer totalQuantity = 0;
                for(OpportunityLineItem oli : lstOli){//first loop for all the product except for Interior Page
                    //numberOlis++;
                    String name;
                    String types;
                    if(oli.Id != null){//I check the opportunity line item is not an empty opportunity line item 
                        Integer index =  String.valueOf(oli.Target_Cover_Rating__c).indexOf(' ');//I get the index of the space in the target field for the opportunity line item
                        if(mapWeekNumber.get(oli.Onsale_Date__c) == w){//I Compare if the week of the on sale date of the opportunity line item is the week that this crossing the loop
                            if(t==String.valueOf(oli.Target_Cover_Rating__c).substring(0, index)){// I Compare if the target of the opportunity line item is the target that this crossing the loop
                                if(oli.PricebookEntry.Product2.Name=='C2'){
                                    lstInventaryC2.clear();
                                    quantityC2 = quantityC2 + Integer.valueOf(oli.Quantity);
                                    if(oli.Opportunity.StageName == 'Confirmed'){
                                        name = 'X';
                                        types = 'product-confirmed';
                                    }
                                    else if(oli.Opportunity.StageName == 'Verbal'){
                                        name = 'VIO';
                                        types = 'verbal-insertion';
                                    }
                                    else{
                                        name = 'O';
                                        types = 'open';
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0 
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    else if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c<quantityC2) {
                                        types = 'exceededi';
                                    }
                                    Inventory inventory = new Inventory(oli.Id, name, types);
                                    lstInventaryC2.add(inventory);
                                }
                                else if(oli.PricebookEntry.Product2.Name=='C3'){
                                    lstInventaryC3.clear();
                                    quantityC3 = quantityC3 + Integer.valueOf(oli.Quantity);
                                    if(oli.Opportunity.StageName == 'Confirmed'){
                                        name = 'X';
                                        types = 'product-confirmed';
                                    }
                                    else if(oli.Opportunity.StageName == 'Verbal'){
                                        name = 'VIO';
                                        types = 'verbal-insertion';
                                    }
                                    else{
                                        name = 'O';
                                        types = 'open';
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    else if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c<quantityC3) {
                                        types = 'exceededi';
                                    }
                                    Inventory inventory = new Inventory(oli.Id, name, types);
                                    lstInventaryC3.add(inventory);
                                }
                                else if(oli.PricebookEntry.Product2.Name=='C4'){
                                    lstInventaryC4.clear();
                                    quantityC4 = quantityC4 + Integer.valueOf(oli.Quantity);
                                    if(oli.Opportunity.StageName == 'Confirmed'){
                                        name = 'X';
                                        types = 'product-confirmed';
                                    }
                                    else if(oli.Opportunity.StageName == 'Verbal'){
                                        name = 'VIO';
                                        types = 'verbal-insertion';
                                    }
                                    else{
                                        name = 'O';
                                        types = 'open';
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    else if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c<quantityC4) {
                                        types = 'exceededi';
                                    }
                                    Inventory inventory = new Inventory(oli.Id, name, types);
                                    lstInventaryC4.add(inventory);
                                }
                                else if(oli.PricebookEntry.Product2.Name=='First RHP'){
                                    //lstInventary1RHP.clear();
                                    if(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) != null){
                                        if(mapWeekNumber.get(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Availability_Date__c)==w){
                                            if(oli.Quantity<=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c)
                                                quantity = quantity + Integer.valueOf(oli.Quantity);
                                            if(oli.Opportunity.StageName == 'Confirmed'){
                                                name = 'X';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventary1RHP.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'product-confirmed';
                                                }
                                            }
                                            else if(oli.Opportunity.StageName == 'Verbal'){
                                                name = 'VIO';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventary1RHP.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'verbal-insertion';
                                                }
                                            }
                                        }
                                    }
                                    else{                                       
                                        quantity = quantity + 1;//Integer.valueOf(oli.Quantity);
                                        if(oli.Opportunity.StageName == 'Confirmed'){
                                            name = 'X';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventary1RHP.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'product-confirmed';
                                            }
                                        }
                                        else if(oli.Opportunity.StageName == 'Verbal'){
                                            name = 'VIO';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventary1RHP.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'verbal-insertion';
                                            }
                                        }
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0 &&
                                    (mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) == null || mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c==0)){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    if(name!=null && name!='' && types!=null && types!=''){
                                        if(lstInventary1RHP.size()>=1){
                                            lstInventary1RHP.clear();
                                        }
                                        Inventory inventory = new Inventory(oli.Id, name, types);
                                        lstInventary1RHP.add(inventory);
                                    }
                                }
                                else if(oli.PricebookEntry.Product2.Name=='Second RHP'){
                                    //lstInventary2RHP.clear();
                                    if(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) != null){
                                        if(mapWeekNumber.get(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Availability_Date__c)==w){
                                            if(oli.Quantity<=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c)
                                                quantity = quantity + Integer.valueOf(oli.Quantity);
                                            if(oli.Opportunity.StageName == 'Confirmed'){
                                                name = 'X';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventary2RHP.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'product-confirmed';
                                                }
                                            }
                                            else if(oli.Opportunity.StageName == 'Verbal'){
                                                name = 'VIO';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventary2RHP.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'verbal-insertion';
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        quantity = quantity + 1;//Integer.valueOf(oli.Quantity);
                                        if(oli.Opportunity.StageName == 'Confirmed'){
                                            name = 'X';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventary2RHP.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'product-confirmed';
                                            }
                                        }
                                        else if(oli.Opportunity.StageName == 'Verbal'){
                                            name = 'VIO';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventary2RHP.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'verbal-insertion';
                                            }
                                        }
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0 &&
                                    (mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) == null || mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c==0)){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    if(name!=null && name!='' && types!=null && types!=''){
                                        if(lstInventary2RHP.size()>=1){
                                            lstInventary2RHP.clear();
                                        }
                                        Inventory inventory = new Inventory(oli.Id, name, types);
                                        lstInventary2RHP.add(inventory);
                                    }
                                }
                                else if(oli.PricebookEntry.Product2.Name=='First Spread'){
                                    //lstInventary1Spread.clear();
                                    if(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) != null){
                                        if(mapWeekNumber.get(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Availability_Date__c)==w){
                                            if(oli.Quantity<=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c)
                                                quantity = quantity + Integer.valueOf(oli.Quantity);
                                            if(oli.Opportunity.StageName == 'Confirmed'){
                                                name = 'X';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventary1Spread.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'product-confirmed';
                                                }
                                            }
                                            else if(oli.Opportunity.StageName == 'Verbal'){
                                                name = 'VIO';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventary1Spread.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'verbal-insertion';
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        quantity = quantity + 2;//Integer.valueOf(oli.Quantity);
                                        if(oli.Opportunity.StageName == 'Confirmed'){
                                            name = 'X';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventary1Spread.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'product-confirmed';
                                            }
                                        }
                                        else if(oli.Opportunity.StageName == 'Verbal'){
                                            name = 'VIO';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventary1Spread.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'verbal-insertion';
                                            }
                                        }
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0 &&
                                    (mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) == null || mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c==0)){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    if(name!=null && name!='' && types!=null && types!=''){
                                        if(lstInventary1Spread.size()>=1){
                                            lstInventary1Spread.clear();
                                        }
                                        Inventory inventory = new Inventory(oli.Id, name, types);
                                        lstInventary1Spread.add(inventory);
                                    }
                                }
                                else if(oli.PricebookEntry.Product2.Name=='Center Spread'){
                                    //lstInventaryCenterSpread.clear();
                                    if(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) != null){
                                        if(mapWeekNumber.get(mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Availability_Date__c)==w){
                                            if(oli.Quantity<=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c)
                                                quantity = quantity + Integer.valueOf(oli.Quantity);
                                            if(oli.Opportunity.StageName == 'Confirmed'){
                                                name = 'X';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventaryCenterSpread.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'product-confirmed';
                                                }
                                            }
                                            else if(oli.Opportunity.StageName == 'Verbal'){
                                                name = 'VIO';
                                                if(Integer.valueOf(oli.Quantity)>mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c || lstInventaryCenterSpread.size()>=mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c){
                                                    types = 'exceededi';
                                                }else{
                                                    types = 'verbal-insertion';
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        quantity = quantity + 2;//Integer.valueOf(oli.Quantity);
                                        if(oli.Opportunity.StageName == 'Confirmed'){
                                            name = 'X';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventaryCenterSpread.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'product-confirmed';
                                            }
                                        }
                                        else if(oli.Opportunity.StageName == 'Verbal'){
                                            name = 'VIO';
                                            if(Integer.valueOf(oli.Quantity)>1 || lstInventaryCenterSpread.size()>=1){
                                                types = 'exceededi';
                                            }else{
                                                types = 'verbal-insertion';
                                            }
                                        }
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0 &&
                                    (mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)) == null || mapInventoryOnTimeChange.get(oli.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oli.Onsale_Date__c).substring(0,10)).Quantity__c==0)){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    if(name!=null && name!='' && types!=null && types!=''){
                                        if(lstInventaryCenterSpread.size()>=1){
                                            lstInventaryCenterSpread.clear();
                                        }
                                        Inventory inventory = new Inventory(oli.Id, name, types);
                                        lstInventaryCenterSpread.add(inventory);
                                    }
                                }
                            }                       
                        }
                    }           
                }
                for(OpportunityLineItem oliInteriorPage : lstOli){//second loop for Interior Page because needs to be processed at last
                    numberOlis++;
                    String name;
                    String types;
                    if(oliInteriorPage.Id != null){//I check the opportunity line item is not an empty opportunity line item 
                        Integer index =  String.valueOf(oliInteriorPage.Target_Cover_Rating__c).indexOf(' ');//I get the index of the space in the target field for the opportunity line item
                        if(mapWeekNumber.get(oliInteriorPage.Onsale_Date__c) == w){//I Compare if the week of the on sale date of the opportunity line item is the week that this crossing the loop
                            if(t==String.valueOf(oliInteriorPage.Target_Cover_Rating__c).substring(0, index)){// I Compare if the target of the opportunity line item is the target that this crossing the loop
                                if(oliInteriorPage.PricebookEntry.Product2.Name=='Interior Page'){
                                    lstInventaryInteriorPage.clear();
                                    Integer tquantity = 9;
                                    if(t=='MM'){
                                        tquantity = 6;
                                    }
                                    if(mapInventoryOnTimeChange.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oliInteriorPage.Onsale_Date__c).substring(0,10)) != null){
                                        if(mapWeekNumber.get(mapInventoryOnTimeChange.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oliInteriorPage.Onsale_Date__c).substring(0,10)).Availability_Date__c)==w){
                                            tquantity = Integer.valueOf(mapInventoryOnTimeChange.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oliInteriorPage.Onsale_Date__c).substring(0,10)).Quantity__c);
                                        }
                                    }
                                    
                                    interiorPageQuantity = interiorPageQuantity + Integer.valueOf(oliInteriorPage.Quantity);
                                    totalQuantity = tquantity - quantity;
                                    if(Integer.valueOf(oliInteriorPage.Quantity) == 0){                                     
                                        name = interiorPageQuantity + ' of ' + tquantity;
                                        types = 'oot';
                                    }
                                    else if(quantity + interiorPageQuantity < tquantity){                                       
                                        name = interiorPageQuantity + ' of ' + (tquantity - quantity);
                                        types = 'tot';
                                    }
                                    else if(quantity + interiorPageQuantity == tquantity){
                                        name = interiorPageQuantity + ' of ' + (tquantity - quantity);
                                        types = 'full';
                                    }
                                    else if(tquantity-quantity<interiorPageQuantity){
                                        name = interiorPageQuantity + ' of ' + (tquantity - quantity);
                                        types = 'exceededi';
                                    }
                                    //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                                    if(mapInventoryWeekly.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)) == null || mapInventoryWeekly.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)).Quantity__c==0 &&
                                    (mapInventoryOnTimeChange.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oliInteriorPage.Onsale_Date__c).substring(0,10)) == null || mapInventoryOnTimeChange.get(oliInteriorPage.PricebookEntry.Product2.Name+' '+mapTarget.get(t)+' One-Time Change '+String.valueOf(oliInteriorPage.Onsale_Date__c).substring(0,10)).Quantity__c==0)){
                                        name = 'N/A';
                                        types = 'exceededi';
                                    }
                                    Inventory inventory = new Inventory(oliInteriorPage.Id, name, types);
                                    lstInventaryInteriorPage.add(inventory);
                                }
                            }
                        }
                    }
                    if(numberOlis==lstOli.size()){//I ask if is the last round of the loop
                        if(lstInventaryC2.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('C2 '+mapTarget.get(t)) == null || mapInventoryWeekly.get('C2 '+mapTarget.get(t)).Quantity__c==0){
                                lstInventaryC2.add(addProductNA());
                            }
                            else{
                                lstInventaryC2.add(addProduct('open'));
                            }
                        }
                        if(lstInventaryC3.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('C3 '+mapTarget.get(t)) == null || mapInventoryWeekly.get('C3 '+mapTarget.get(t)).Quantity__c==0){
                                lstInventaryC3.add(addProductNA());
                            }
                            else{
                                lstInventaryC3.add(addProduct('open'));
                            }
                        }
                        if(lstInventaryC4.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('C4 '+mapTarget.get(t)) == null || mapInventoryWeekly.get('C4 '+mapTarget.get(t)).Quantity__c==0){
                                lstInventaryC4.add(addProductNA());
                            }
                            else{
                                lstInventaryC4.add(addProduct('open'));
                            }
                        }
                        if(lstInventary1RHP.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('First RHP '+mapTarget.get(t)) == null || mapInventoryWeekly.get('First RHP '+mapTarget.get(t)).Quantity__c==0){
                                lstInventary1RHP.add(addProductNA());
                            }
                            else{
                                if(interiorPageQuantity>0 && totalQuantity>0 && interiorPageQuantity>=totalQuantity){
                                    lstInventary1RHP.add(addProduct('openr'));
                                }
                                else{
                                    //lstInventary1RHP.add(addProduct('open'));
                                    if((mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)).Quantity__c==0) && 
                                    (mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) == null || mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c==0)){
                                        lstInventary1RHP.add(addProduct('open'));
                                    }
                                    else if(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) != null && mapWeekNumber.get(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Availability_Date__c)==w){
                                            Integer tquantity = Integer.valueOf(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c);
                                        if(quantity>=tquantity){
                                        	lstInventary1RHP.add(addProduct('openr'));
                                        }
                                        else {
                                            lstInventary1RHP.add(addProduct('open'));
                                        }
                                    }                           
                                    else{
                                        if(t=='MM'){
                                            if(quantity>=6){
                                                lstInventary1RHP.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventary1RHP.add(addProduct('open'));
                                            }
                                        }
                                        else{
                                            if(quantity>=9){
                                                lstInventary1RHP.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventary1RHP.add(addProduct('open'));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(lstInventary2RHP.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('Second RHP '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Second RHP '+mapTarget.get(t)).Quantity__c==0){
                                lstInventary2RHP.add(addProductNA());
                            }
                            else{
                                if(interiorPageQuantity>0 && totalQuantity>0 && interiorPageQuantity>=totalQuantity){
                                    lstInventary2RHP.add(addProduct('openr'));
                                }
                                else{
                                    //lstInventary2RHP.add(addProduct('open'));
                                    if((mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)).Quantity__c==0) && 
                                    (mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) == null || mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c==0)){
                                        lstInventary2RHP.add(addProduct('open'));
                                    }
                                    else if(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) != null && mapWeekNumber.get(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Availability_Date__c)==w){
                                            Integer tquantity = Integer.valueOf(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c);
                                        if(quantity>=tquantity){
                                        	lstInventary2RHP.add(addProduct('openr'));
                                        }
                                        else {
                                            lstInventary2RHP.add(addProduct('open'));
                                        }
                                    }                           
                                    else{
                                        if(t=='MM'){
                                            if(quantity>=6){
                                                lstInventary2RHP.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventary2RHP.add(addProduct('open'));
                                            }
                                        }
                                        else{
                                            if(quantity>=9){
                                                lstInventary2RHP.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventary2RHP.add(addProduct('open'));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(lstInventary1Spread.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('First Spread '+mapTarget.get(t)) == null || mapInventoryWeekly.get('First Spread '+mapTarget.get(t)).Quantity__c==0){
                                lstInventary1Spread.add(addProductNA());
                            }
                            else{
                                if(interiorPageQuantity>0 && totalQuantity>0 && interiorPageQuantity>=totalQuantity){
                                    lstInventary1Spread.add(addProduct('openr'));
                                }
                                else{
                                    //lstInventary1Spread.add(addProduct('open'));
                                    if((mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)).Quantity__c==0) && 
                                    (mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) == null || mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c==0)){
                                        lstInventary1Spread.add(addProduct('open'));
                                    }
                                    else if(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) != null && mapWeekNumber.get(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Availability_Date__c)==w){
                                            Integer tquantity = Integer.valueOf(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c);
                                        if(quantity>=tquantity){
                                        	lstInventary1Spread.add(addProduct('openr'));
                                        }
                                        else {
                                            lstInventary1Spread.add(addProduct('open'));
                                        }
                                    }                           
                                    else{
                                        if(t=='MM'){
                                            if(quantity>=6){
                                                lstInventary1Spread.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventary1Spread.add(addProduct('open'));
                                            }
                                        }
                                        else{
                                            if(quantity>=9){
                                                lstInventary1Spread.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventary1Spread.add(addProduct('open'));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(lstInventaryCenterSpread.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if(mapInventoryWeekly.get('Center Spread '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Center Spread '+mapTarget.get(t)).Quantity__c==0){
                                lstInventaryCenterSpread.add(addProductNA());
                            }
                            else{
                                if(interiorPageQuantity>0 && totalQuantity>0 && interiorPageQuantity>=totalQuantity){
                                    lstInventaryCenterSpread.add(addProduct('openr'));
                                }
                                else{
                                    //lstInventaryCenterSpread.add(addProduct('open'));
                                    if((mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)).Quantity__c==0) && 
                                    (mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) == null || mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c==0)){
                                        lstInventaryCenterSpread.add(addProduct('open'));
                                    }
                                    else if(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) != null && mapWeekNumber.get(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Availability_Date__c)==w){
                                            Integer tquantity = Integer.valueOf(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c);
                                        if(quantity>=tquantity){
                                        	lstInventaryCenterSpread.add(addProduct('openr'));
                                        }
                                        else {
                                            lstInventaryCenterSpread.add(addProduct('open'));
                                        }
                                    }                           
                                    else{
                                        if(t=='MM'){
                                            if(quantity>=6){
                                                lstInventaryCenterSpread.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventaryCenterSpread.add(addProduct('open'));
                                            }
                                        }
                                        else{
                                            if(quantity>=9){
                                                lstInventaryCenterSpread.add(addProduct('openr'));
                                            }
                                            else {
                                                lstInventaryCenterSpread.add(addProduct('open'));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(lstInventaryInteriorPage.size()==0){//I ask if the size of the list for this product is 0
                            //I ask if the product of the opportunity line item has an inventory or if the inventory has a quantity higher than 0
                            if((mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)) == null || mapInventoryWeekly.get('Interior Page '+mapTarget.get(t)).Quantity__c==0) && 
                            (mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) == null || mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c==0)){
                                lstInventaryInteriorPage.add(addProductInterioirPageNA());
                            }
                            else if(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)) != null && mapWeekNumber.get(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Availability_Date__c)==w){
                                    Integer tquantity = Integer.valueOf(mapInventoryOnTimeChange.get('Interior Page '+mapTarget.get(t)+' One-Time Change '+String.valueOf(mapWeekNumberDate.get(w)).substring(0,10)).Quantity__c);
                                    lstInventaryInteriorPage.add(addProductInterioirPage(tquantity, quantity));
                            }                           
                            else{
                                if(t=='MM'){
                                    lstInventaryInteriorPage.add(addProductInterioirPage(6, quantity));
                                }
                                else{
                                    lstInventaryInteriorPage.add(addProductInterioirPage(9, quantity));
                                }
                            }                           
                        }
                    }
                    mapProductlstInventory.put('C2',lstInventaryC2);
                    mapProductlstInventory.put('C3',lstInventaryC3);
                    mapProductlstInventory.put('C4',lstInventaryC4);
                    mapProductlstInventory.put('First RHP',lstInventary1RHP);
                    mapProductlstInventory.put('Second RHP',lstInventary2RHP);
                    mapProductlstInventory.put('First Spread',lstInventary1Spread);
                    mapProductlstInventory.put('Center Spread',lstInventaryCenterSpread);
                    mapProductlstInventory.put('Interior Page',lstInventaryInteriorPage);
                    mapTargetMapProductlstInventory.put(t, mapProductlstInventory.clone());
                }
                mapWeekMapTargetMapProductlstInventory.put(w,mapTargetMapProductlstInventory.clone());      
            }
        }
        for(Integer w : mapWeekMapTargetMapProductlstInventory.keySet()){
            for(String t : mapWeekMapTargetMapProductlstInventory.get(w).keySet()){
                for(String p : mapWeekMapTargetMapProductlstInventory.get(w).get(t).keySet()){
                    for(Inventory inv : mapWeekMapTargetMapProductlstInventory.get(w).get(t).get(p)){
                        system.debug('#### ' + w + ' ' + t + ' ' + p + ' ' + inv);
                    }
                }
            }
        }
    }
    
    private Inventory addProduct(String typess){
        String name = 'O';
        String types = typess;
        Id id = null;
        Inventory inventory = new Inventory(id, name, types);
        return inventory;
    }
    
    private Inventory addProductNA(){
        String name = 'N/A';
        String types = 'na';
        Id id = null;
        Inventory inventory = new Inventory(id, name, types);
        return inventory;
    }
    
    private Inventory addProductInterioirPage(Integer tq, Integer ip){
        String name = '0 of ' + (tq-ip);
        String types = 'oot';
        if(tq-ip<0){
            name = 0 + ' of ' + (tq - ip);
            types = 'exceededi';
        }
        else {
            if(tq==ip){
                types = 'openr';
            }
        }
        Id id = null;
        Inventory inventory = new Inventory(id, name, types);
        return inventory;
    }
    
    private Inventory addProductInterioirPageNA(){
        String name = 'N/A';
        String types = 'na';
        Id id = null;
        Inventory inventory = new Inventory(id, name, types);
        return inventory;
    }
    
    private void getMonthName(){
        if(month==1) monthName = 'January';
        else if(month==2) monthName = 'February';
        else if(month==3) monthName = 'March';
        else if(month==4) monthName = 'April';
        else if(month==5) monthName = 'May';
        else if(month==6) monthName = 'June';
        else if(month==7) monthName = 'July';
        else if(month==8) monthName = 'August';
        else if(month==9) monthName = 'September';
        else if(month==10) monthName = 'October';
        else if(month==11) monthName = 'November';
        else if(month==12) monthName = 'December';
    }
    
    private void getYearAsString(){
        yearName = String.valueOf(year);
    }
    
    public void sumMonth(){
        month++;
        if(month<=12){          
            getMonthName();
            getNumberOfWednesdays(year, month);
            getInventoryData();
        }
        else{
            month=1;
            year++;
            getYearAsString();
            getMonthName();
            getNumberOfWednesdays(year, month);
            getInventoryData();
        }
    }
    
    public void restMonth(){
        month--;
        if(month>=1){           
            getMonthName();
            getNumberOfWednesdays(year, month);
            getInventoryData();
        }
        else{
            month=12;
            year--;
            getYearAsString();
            getMonthName();
            getNumberOfWednesdays(year, month);
            getInventoryData();
        }
    }
    
    public class Inventory{
        
        public Id id;
        public String name{get;set;}
        public String types{get;set;}
        
        public Inventory(Id ids, String Names, String Typess){
            id=ids;
            name = Names;
            types = Typess;
        }
    }
}