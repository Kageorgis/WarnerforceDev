/*******************************************************************************************************************************************
* File Name     :   WB_CountryTriggerHandler
* Description   :   Handler class for Country trigger.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.      15/01/2018        Astha Singh          ER-1305  
********************************************************************************************************************************************/
public class WB_CountryTriggerHandler{
    
    public void checkPrimaryRating(List<Country__c> lstCountries){
        
        
        for(Country__c country : lstCountries){         
            if(country.Valid_Rating_Systems__c!=null){ 
                Set<String> setRating = new Set<String>();             
                setRating.addAll(country.Valid_Rating_Systems__c.split(';'));
                List<String> ls= new List<String>(setRating);
                String allstring = String.join(ls,',');
                country.Valid_Ratings_For_Country__c=allstring;                
                if(country.Default_Feature_Rating_Systems__c!=null){                    
                    if(!setRating.contains(country.Default_Feature_Rating_Systems__c))
                    country.addError(' Default Feature Rating systems should be sub-set of Valid Rating Systems ');                
                }
                if(country.Default_TV_Rating_System__c!=null){                    
                    if(!setRating.contains(country.Default_TV_Rating_System__c))
                    country.addError(' Default TV Rating systems should be sub-set of Valid Rating Systems ');                
                }
            }
            
        }          
    }
    //ER-1680 Starts
     public void digPhyCheckonQueueOnInsert(List<Country__c> countryList)
    {
        for(Country__c c: countryList)
        {
             System.debug('+++++Insert Method-> Country Loop');
            if(c.Physical_Owner__c !=Null || c.Digital_Owner__c !=Null || c.SDS_Owner__c != Null)
            {
              WB_Queue_Id__c queueNamePhysical= WB_Queue_Id__c.getValues(c.Physical_Owner__c);
              WB_Queue_Id__c queueNameDigital= WB_Queue_Id__c.getValues(c.Digital_Owner__c);
              WB_Queue_Id__c queueNameSDS = WB_Queue_Id__c.getValues(c.SDS_Owner__c);
              if(queueNamePhysical==NULL)
              {
                   c.Physical_Owner__c.addError('Physical Owner is not present in the Queue') ;
              }
              if(queueNameDigital==NULL)
               {
                   c.Digital_Owner__c.addError('Digital Owner is not present in the Queue') ;
               }
               if(queueNameSDS==NULL)
               {
                   c.SDS_Owner__c.addError('SDS Owner is not present in the Queue') ;
               }
            }
        }
    
    }
    public void digPhyCheckonQueueOnUpdate(Map<Id,Country__c> countryMapOld, Map<Id,Country__c> countryMapNew)
    {
        for(Id c:countryMapNew.keySet())
        {
            if(countryMapOld.get(c).Physical_Owner__c != countryMapNew.get(c).Physical_Owner__c ||  countryMapOld.get(c).Digital_Owner__c != countryMapNew.get(c).Digital_Owner__c 
            || countryMapOld.get(c).SDS_Owner__c != countryMapNew.get(c).SDS_Owner__c)
            {
                 if(countryMapNew.get(c).Physical_Owner__c !=Null || countryMapNew.get(c).Digital_Owner__c !=Null)
                {
                  WB_Queue_Id__c queueNamePhysical= WB_Queue_Id__c.getValues(countryMapNew.get(c).Physical_Owner__c);
                  WB_Queue_Id__c queueNameDigital= WB_Queue_Id__c.getValues(countryMapNew.get(c).Digital_Owner__c);
                  WB_Queue_Id__c queueNameSDS = WB_Queue_Id__c.getValues(countryMapNew.get(c).SDS_Owner__c);

                  if(queueNamePhysical==NULL)
                  {
                       countryMapNew.get(c).Physical_Owner__c.addError('Physical Owner is not present in the Queue') ;
                  }
                  if(queueNameDigital==NULL)
                  {
                       countryMapNew.get(c).Digital_Owner__c.addError('Digital Owner is not present in the Queue') ;
                  }
                  if(queueNameSDS==NULL)
                  {
                       countryMapNew.get(c).SDS_Owner__c.addError('SDS Owner is not present in the Queue') ;
                  }
                }   
            }
        }
    
    }
    //ER-1680 Ends
    
}