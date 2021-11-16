/*=========================================
 * @Author sai santhan
* @Date 20/09/2020
* @Description:
 ===========================================*/
public class RF_MPMHelper {
    //ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
    //Storing the value of "Universal-Warner Bros JV" in a static string
    Static String frbReportingGroup = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
 	//comparing sgenno field in ext title and financial comments 3 field in mpm and if it matches mpm number,mpm,mpm request status and integration status should be changed
    public void updateExtTitle(List<MPM__c> lstMPMs){
       List<Ext_Title__c> extUpdList=new List<Ext_Title__c>();
        Map<String,MPM__c> mpmMatchMap= new Map<String,MPM__c>();
        
        for(MPM__c mpm:lstMPMs){
            if(mpm.Financial_Comment_3__c!=null){
                system.debug('2');
                if(mpm.financial_comment_3__c.contains(':') && mpm.financial_comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                     system.debug('3');
                    if(!mpm.financial_comment_3__c.contains(';')){
                        String actualSysGenValue=mpm.financial_comment_3__c.substringAfter(':');
                        system.debug('actualSysGenValue:'+actualSysGenValue);
                        mpmMatchMap.put(actualSysGenValue,mpm);
                    }
                    if(mpm.financial_comment_3__c.contains(';')){
                        //ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
                        //Added condition to check anywhere in financial Comment 3 for the substring followed by J01: prefix 
                        List<String> financialComment = mpm.financial_comment_3__c.split(';');
                    	String modifiedSysGenValue='';
                    	for(String fc:financialComment){
                            if(fc.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                        		modifiedSysGenValue=fc.substringAfter(':');
                                mpmMatchMap.put(modifiedSysGenValue,mpm);}
                    	}
                    }
                }
            	}
        }    
        for(Ext_Title__c ext:[SELECT SGENNO__c,Id,MPM_Number__c,MPM__c FROM Ext_Title__c WHERE SGENNO__c IN:mpmMatchMap.keySet()]){
           /*ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
		   Added check for FRB Reporting Group = “Universal-Warner Bros JV” in MPM__c and removed the check for MPM_Short_Desc__c.*/       
        	
           /*W-017852 - update the Ext Titles record with the MPM which has "SDS USE ONLY-" prefix in MPM Short Description and Financial Comment 3 in correct format (J01:) only.
           check if MPM__c in the Ext Title record is blank or it is different from the Id of the MPM record*/
                if((ext.MPM__c == null || ext.MPM__c != mpmMatchMap.get(ext.SGENNO__c).Id)
                   && mpmMatchMap.containsKey(ext.SGENNO__c)
                   && mpmMatchMap.get(ext.SGENNO__c).FRB_Reporting_Group__c!=null
                   && mpmMatchMap.get(ext.SGENNO__c).FRB_Reporting_Group__c.contains(frbReportingGroup)
                   && mpmMatchMap.get(ext.SGENNO__c).Financial_Comment_3__c !=null
                   && mpmMatchMap.get(ext.SGENNO__c).Financial_Comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01+':'+ext.SGENNO__c))
                {
                    ext.MPM__c= mpmMatchMap.get(ext.SGENNO__c).Id;
                    ext.MPM_Request_Status__c=System.Label.RF_MPM_Request_Status_Complete;
                    ext.MPM_Number__c= mpmMatchMap.get(ext.SGENNO__c).MPM_Number__c;
                    ext.Integration_State__c= LABEL.RF_PICK_ME_UP;
                    extUpdList.add(ext);   
                }
        }
        if(extUpdList.size()>0){
            Database.update(extUpdList,false);
        }
	 }
    
  //W-017377 - Requirement - comparing financial comments 3 after the prefix ; 
  public static void setPrefixFinacial(List<MPM__c> lstMPMs){
      system.debug('1');
        List<Ext_Title__c> extUpdList=new List<Ext_Title__c>();
        Map<String,MPM__c> mpmMatchMap= new Map<String,MPM__c>();
        
        for(MPM__c mpm:lstMPMs){
            if(mpm.Financial_Comment_3__c!=null){
                system.debug('2');
                if(mpm.financial_comment_3__c.contains(':') && mpm.financial_comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                     system.debug('3');
                    if(!mpm.financial_comment_3__c.contains(';')){
                        String actualSysGenValue=mpm.financial_comment_3__c.substringAfter(':');
                        if(!mpmMatchMap.containsKey(actualSysGenValue)){
                          	mpmMatchMap.put(actualSysGenValue,mpm);  
                        }
                    }
                    if(mpm.financial_comment_3__c.contains(';')){
                        
                        /*String modifiedSysGenValue=  mpm.financial_comment_3__c.substringAfter(':');
                        String finalSysGenValue=  modifiedSysGenValue.SubStringBefore(';');
                        system.debug('finalSysGenValue:'+finalSysGenValue);
                        mpmMatchMap.put(finalSysGenValue,mpm);*/
                        
                        //ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
                        //Added condition to check anywhere in financial Comment 3 for the substring followed by J01: prefix 
                        List<String> financialComment = mpm.financial_comment_3__c.split(';');
                    	String modifiedSysGenValue='';
                    	for(String fc:financialComment){
                        if(fc.contains(System.Label.RF_Financial_Comment_3_Prefix_J01))
                        modifiedSysGenValue=fc.substringAfter(':');
                        if(!mpmMatchMap.containsKey(modifiedSysGenValue)){
                          	mpmMatchMap.put(modifiedSysGenValue,mpm);  
                        }
                    	}
                    }
                }
                else if(mpm.financial_comment_3__c.contains(':') && !mpm.financial_comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                     	if(!mpmMatchMap.containsKey(mpm.financial_comment_3__c)){
                          	mpmMatchMap.put(mpm.financial_comment_3__c,mpm);  
                        }
                }
            	}else{
                    system.debug('4');
                    mpmMatchMap.put(mpm.Financial_Comment_3__c,mpm); 
                    system.debug('4 mpmMatchMap::'+mpmMatchMap);
                }
            }
        for(Ext_Title__c ext:[SELECT SGENNO__c,Id,MPM_Number__c,MPM__c,MPM_Request_Status__c FROM Ext_Title__c WHERE SGENNO__c !=null AND ((MPM__c!=null AND MPM__c IN:mpmMatchMap.values()) OR SGENNO__c IN:mpmMatchMap.keySet()) ]){
            system.debug('5ext'+ext);
            
            /*ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
		   	  Added check for FRB Reporting Group = “Universal-Warner Bros JV” in MPM__c and removed the check for MPM_Short_Desc__c.
			  Updated the conditions in case Financial Comment 3 does not match SGENNO*/       
            if(ext.MPM_Request_Status__c!=System.Label.RF_MPM_Request_Status_MPM_Rejected 
               && ((mpmMatchMap.containsKey(null) && ext.MPM__c==mpmMatchMap.get(null).Id)
               ||!mpmMatchMap.containsKey(ext.SGENNO__c)|| mpmMatchMap.get(ext.SGENNO__c).FRB_Reporting_Group__c== null 
               ||mpmMatchMap.get(ext.SGENNO__c).FRB_Reporting_Group__c!=frbReportingGroup))
              {
               ext.MPM__c= null;
               ext.MPM_Request_Status__c=System.Label.RF_MPM_Request_Status_MPM_Required;
               ext.MPM_Number__c='';
			   ext.Integration_State__c = LABEL.RF_PICK_ME_UP;
               extUpdList.add(ext);
            }
            else if(mpmMatchMap!=null && mpmMatchMap.get(ext.SGENNO__c)!=null
               		&& mpmMatchMap.get(ext.SGENNO__c).FRB_Reporting_Group__c!=null 
               		&& mpmMatchMap.get(ext.SGENNO__c).FRB_Reporting_Group__c.contains(frbReportingGroup)
               		&& mpmMatchMap.get(ext.SGENNO__c).Financial_Comment_3__c!=null     
               		&& mpmMatchMap.get(ext.SGENNO__c).Financial_Comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01+':'+ext.SGENNO__c)
                    && !mpmMatchMap.containsKey(null)){
                   
                		system.debug('sgenooo'+ext.SGENNO__c);
                		ext.MPM__c= mpmMatchMap.get(ext.SGENNO__c).Id;
                		system.debug('mpm Number'+mpmMatchMap.get(ext.SGENNO__c).Id);
                		ext.MPM_Request_Status__c=System.Label.RF_MPM_Request_Status_Complete;
                		ext.MPM_Number__c= mpmMatchMap.get(ext.SGENNO__c).MPM_Number__c;
                		ext.Integration_State__c = LABEL.RF_PICK_ME_UP;
                		extUpdList.add(ext);
            	}
        }
        if(extUpdList.size()>0){
            Database.update(extUpdList,false);
        }
	 }
}