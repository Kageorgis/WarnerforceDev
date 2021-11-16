/*******************************************************************************************************************************************
* File Name     :   WB_RPRelease
* Description   :   Handler class for WB_RPReleaseTrigger
* @author       :   Dennis Cho
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
*                                               ER-776 
* 1.0     24 DEC 2019       Dennis Cho          Handler class to calculate costs for physical and digital Release Planning Release records 
* 2.0      4 JUL 2020		Dennis Cho			Modify class to disregard Category for costing derivation for physical
* 3.0     19 AUG 2021		Dennis Cho			Add Turner specific costing.  Use Category to identify Turner rates.
********************************************************************************************************************************************/

public class WB_RPRelease {

    public static void insertRPRelease(List<Release_Planning_Release__c> lstRPRelease){

        for(Release_Planning_Release__c RPR : lstRPRelease){
            if (RPR.Country__c == 'Canada') RPR.CurrencyIsoCode = 'CAD';
        }        
    }

    public static void insertPhysicalRPRelease(List<Release_Planning_Release__c> lstRPRelease){
      
        List<MRP_Costing__c> MRPlist = [SELECT Country__r.Name, SRP__c, Retail_Cost__c, Expected_Retail__c	 
					from MRP_Costing__c where RecordType.Name = 'Physical'];

        for(Release_Planning_Release__c RPR : lstRPRelease){

            for (MRP_Costing__c MRPC : MRPlist){
                if (RPR.Country__c == MRPC.Country__r.Name &&
                    /* RPR.Category__c == MRPC.Category__c && */
                    RPR.SRP__c == MRPC.SRP__c){
                        if (RPR.Retail_Cost__c == null) RPR.Retail_Cost__c = MRPC.Retail_Cost__c;
                        if (RPR.Expected_Retail__c == null) RPR.Expected_Retail__c = MRPC.Expected_Retail__c;
                        break;
                }
            }            
        }
    }

    public static void insertDigitalRPRelease(List<Release_Planning_Release__c> lstRPRelease){
      
        List<MRP_Costing__c> MRPlist = [SELECT Country__r.Name, Content_Type__c, SRP__c, Retail_Cost__c, Category__c
					from MRP_Costing__c where RecordType.Name = 'Digital'];

        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.SD_Episode_Retail__c > 0 &&
                RPR.SD_Episode_Wholesale__c == null){
                    for (MRP_Costing__c MRPC : MRPlist){
                        if (RPR.Country__c == MRPC.Country__r.Name &&
                            RPR.SD_Episode_Retail__c == MRPC.SRP__c &&
                            RPR.Studio__c == MRPC.Category__c)                        
                        		{
                                RPR.SD_Episode_Wholesale__c = MRPC.Retail_Cost__c;
                                break;
                        		}	
                    }
            }
			if (RPR.SD_Season_Retail__c >= 4.99 &&
                RPR.SD_Season_Wholesale__c == null)
            	RPR.SD_Season_Wholesale__c = RPR.SD_Season_Retail__c * 0.7;

            if (RPR.HD_Episode_Retail__c > 0 &&
                RPR.HD_Episode_Wholesale__c == null){
                    for (MRP_Costing__c MRPC : MRPlist){
                        if (RPR.Country__c == MRPC.Country__r.Name &&
                            RPR.HD_Episode_Retail__c == MRPC.SRP__c &&
                            RPR.Studio__c == MRPC.Category__c){
                                RPR.HD_Episode_Wholesale__c = MRPC.Retail_Cost__c;
                                break;
                        }	
                    }
            }
			if (RPR.HD_Season_Retail__c >= 4.99 &&
                RPR.HD_Season_Wholesale__c == null)
            	RPR.HD_Season_Wholesale__c = RPR.HD_Season_Retail__c * 0.7;            

            if (RPR.X4k_Episode_Retail__c > 0 &&
                RPR.X4k_Episode_Wholesale__c == null){
                    for (MRP_Costing__c MRPC : MRPlist){
                        if (RPR.Country__c == MRPC.Country__r.Name &&
                            RPR.X4k_Episode_Retail__c == MRPC.SRP__c &&
                            RPR.Studio__c == MRPC.Category__c){
                                RPR.X4k_Episode_Wholesale__c = MRPC.Retail_Cost__c;
                                break;
                        }	
                    }
            }
			if (RPR.X4k_Season_Retail__c >= 4.99 &&
                RPR.X4k_Season_Wholesale__c == null)
            	RPR.X4k_Season_Wholesale__c = RPR.X4k_Season_Retail__c * 0.7;     

        }
    }    
    
    public static void updatePhysicalRPRelease(List<Release_Planning_Release__c> lstRPRelease){

        List<MRP_Costing__c> MRPlist = [SELECT Country__r.Name, SRP__c, Retail_Cost__c, Expected_Retail__c	 
					from MRP_Costing__c where RecordType.Name = 'Physical'];

        for(Release_Planning_Release__c RPR : lstRPRelease){
            for (MRP_Costing__c MRPC : MRPlist){
                if (RPR.Country__c == MRPC.Country__r.Name &&
                    // RPR.Category__c == MRPC.Category__c &&
                    RPR.SRP__c == MRPC.SRP__c){
						RPR.Retail_Cost__c = MRPC.Retail_Cost__c;
                        RPR.Expected_Retail__c = MRPC.Expected_Retail__c;
                        break;
                }
            }            
        }        
    }

    public static void updateSDERPRelease(List<Release_Planning_Release__c> lstRPRelease){

        List<MRP_Costing__c> MRPlist = [SELECT Country__r.Name, Content_Type__c, SRP__c, Retail_Cost__c, Category__c
					from MRP_Costing__c where RecordType.Name = 'Digital'];        
        
        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.SD_Episode_Retail__c > 0) {
                    for (MRP_Costing__c MRPC : MRPlist){
                        if (RPR.Country__c == MRPC.Country__r.Name &&
                            RPR.SD_Episode_Retail__c == MRPC.SRP__c &&
                            RPR.Studio__c == MRPC.Category__c){
                                RPR.SD_Episode_Wholesale__c = MRPC.Retail_Cost__c;
                                break;
                        }	
                    }
            }        
        }
    }

    public static void updateSDSRPRelease(List<Release_Planning_Release__c> lstRPRelease){  
        
        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.SD_Season_Retail__c > 4.99) 
				RPR.SD_Season_Wholesale__c = RPR.SD_Season_Retail__c * 0.7;        
        }
    } 
    
    public static void updateHDERPRelease(List<Release_Planning_Release__c> lstRPRelease){

        List<MRP_Costing__c> MRPlist = [SELECT Country__r.Name, Content_Type__c, SRP__c, Retail_Cost__c, Category__c
					from MRP_Costing__c where RecordType.Name = 'Digital'];        
        
        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.HD_Episode_Retail__c > 0) {
                    for (MRP_Costing__c MRPC : MRPlist){
                        if (RPR.Country__c == MRPC.Country__r.Name &&
                            RPR.HD_Episode_Retail__c == MRPC.SRP__c &&
                            RPR.Studio__c == MRPC.Category__c){
                                RPR.HD_Episode_Wholesale__c = MRPC.Retail_Cost__c;
                                break;
                        }	
                    }
            }        
        }
    }

    public static void updateHDSRPRelease(List<Release_Planning_Release__c> lstRPRelease){  
        
        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.HD_Season_Retail__c > 4.99) 
				RPR.HD_Season_Wholesale__c = RPR.HD_Season_Retail__c * 0.7;        
        }
    } 
    
    public static void update4DERPRelease(List<Release_Planning_Release__c> lstRPRelease){

        List<MRP_Costing__c> MRPlist = [SELECT Country__r.Name, Content_Type__c, SRP__c, Retail_Cost__c, Category__c 
					from MRP_Costing__c where RecordType.Name = 'Digital'];        
        
        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.X4k_Episode_Retail__c > 0) {
                    for (MRP_Costing__c MRPC : MRPlist){
                        if (RPR.Country__c == MRPC.Country__r.Name &&
                            RPR.X4k_Episode_Retail__c == MRPC.SRP__c &&
                            RPR.Studio__c == MRPC.Category__c){
                                RPR.X4k_Episode_Wholesale__c = MRPC.Retail_Cost__c;
                                break;
                        }	
                    }
            }        
        }
    }

    public static void update4DSRPRelease(List<Release_Planning_Release__c> lstRPRelease){  
        
        for(Release_Planning_Release__c RPR : lstRPRelease){
			if (RPR.X4k_Season_Retail__c > 4.99) 
				RPR.X4k_Season_Wholesale__c = RPR.X4k_Season_Retail__c * 0.7;        
        }
    }     

}