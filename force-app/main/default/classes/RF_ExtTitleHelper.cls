/*========================================================================================================
* @author: Sai Santhan
* @date: 20/09/2020
* @description: Helper class that will implement the functionality of EXTTitle object

==========================================================================================================*/
public class RF_ExtTitleHelper {
    //ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
    //Storing the value of "Universal-Warner Bros JV" in a static string
    Static String frbReportingGroup = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
 	///Updating MPM from Ext title if Ext Title present in Release    
    public static void setMPMRequest(List<SObject> newExtLst,Map<Id, SObject> oldItems){
        Map<id,Ext_Title__c> inboundExtMap= new Map<id,Ext_Title__c>();
       // Map<String,MPM__c> mpmMatchMap= new Map<String,MPM__c>();
        for(SObject rec:newExtLst){
            Ext_Title__c ext=(Ext_Title__c)rec;
            if(ext!=null){
                inboundExtMap.put(ext.id,ext);
            } 
        }
        list<Release__C> Releaselist = [select id, Ext_Title_Id__c,MPM__c from Release__C where Ext_Title_Id__c IN : inboundExtMap.keyset()];
        system.debug('Releaselist+++++'+ Releaselist);
        list<Release__c> releasestoupdate= new list<Release__c>();
        for(Release__c rel : Releaselist){
            if(rel!=null && rel.Ext_Title_Id__c!=null){
                rel.mpm__c = inboundExtMap.get(rel.Ext_Title_Id__c).mpm__c;  
                releasestoupdate.add(rel);
            }   
        }
        system.debug('releasestoupdate+++++'+ releasestoupdate);
        if(releasestoupdate.size()>0){
            update releasestoupdate;
        }
        
    }
    //W-017377- comparing sgenno and financial comments 3 and setting the MPM request status and Integration status
    public static void setMPMFCPrefix( List<SObject> newExtLst){
        system.debug('MPM Prefix');
        Map<String,Ext_Title__c> inboundExtMap= new Map<String,Ext_Title__c>();
        Map<String,MPM__c> mpmMatchMap= new Map<String,MPM__c>();
        
        for(SObject rec:newExtLst){
            Ext_Title__c ext=(Ext_Title__c)rec;
            if(ext.SGENNO__c != null){
                inboundExtMap.put(ext.SGENNO__c,ext);
            }
        }
        set<string> fuzzyMatchKeys = new set<string>();
        for(String sgn:inboundExtMap.keySet()){
            fuzzyMatchKeys.add('%'+sgn+'%');
        }
		//ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
		//Added check for FRB Reporting Group = “Universal-Warner Bros JV” in MPM__c and removed the check for MPM_Short_Desc__c.       
        List<MPM__C> mpmList  = [SELECT Financial_Comment_3__c,Id,MPM_Number__c FROM MPM__c WHERE FRB_Reporting_Group__c =: frbReportingGroup and Financial_Comment_3__c like :fuzzyMatchKeys];
        system.debug('mpmList:'+mpmList);
        For(MPM__c mpm:mpmList) {            
            if(mpm.financial_comment_3__c!=null && mpm.financial_comment_3__c.contains(':') && mpm.financial_comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){                
                if(!mpm.financial_comment_3__c.contains(';')){
                    String actualSysGenValue=mpm.financial_comment_3__c.substringAfter(':');//J01:2222
                    
                    mpmMatchMap.put(actualSysGenValue,mpm);
                    //ext.SGENNO__c = actualSysGenValue; 
                }
                if(mpm.financial_comment_3__c.contains(';')){
                    
                   /* String initalSysGenValue=mpm.financial_comment_3__c.SubStringBefore(';');
                    if (initalSysGenValue.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                        String modifiedSysGenValue=  mpm.financial_comment_3__c.substringAfter(':');
                        String finalSysGenValue=  modifiedSysGenValue.SubStringBefore(';');//J01:2222;J01:2232
                        system.debug('finalSysGenValue:'+finalSysGenValue);
                    
                        mpmMatchMap.put(finalSysGenValue,mpm);
                        //ext.SGENNO__c = finalSysGenValue; 
                    } */
                    
                    
                    //ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
                    //Added condition to check anywhere in financial Comment 3 for the substring followed by J01: prefix 
                        
                    List<String> financialComment = mpm.financial_comment_3__c.split(';');
                    String modifiedSysGenValue='';
                    for(String fc:financialComment){
                        if(fc.contains(System.Label.RF_Financial_Comment_3_Prefix_J01))
                        modifiedSysGenValue=fc.substringAfter(':');
                        mpmMatchMap.put(modifiedSysGenValue,mpm);
                    }
                }
                }else{
                mpmMatchMap.put(mpm.Financial_Comment_3__c,mpm); 
            }
		}
        for(String sgn:inboundExtMap.keySet()){
            
            Ext_Title__c extL= inboundExtMap.get(sgn);
            if(mpmMatchMap.containsKey(sgn)){
                extL.MPM__c= mpmMatchMap.get(sgn).Id;
                extL.MPM_Request_Status__c= System.Label.RF_MPM_Request_Status_Complete;
                extL.Integration_State__c = LABEL.RF_PICK_ME_UP;
                
              	setprefix(extL, mpmMatchMap.get(sgn));
                
                extL.MPM_Number__c= mpmMatchMap.get(sgn).MPM_Number__c;
                system.debug('EXTITLleMPM_Number__c'+extL.MPM_Number__c);
                
            }else{
                extL.MPM__c=null;
                extL.MPM_Number__c='';
                extL.MPM_Request_Status__c= System.Label.RF_MPM_Request_Status_MPM_Required;
                extL.Integration_State__c= LABEL.RF_PICK_ME_UP;  
           }
        }
    }
  //comparing sgenno and financial comments 3 fields on update  
    public static void setMPMFCPrefixUpdate( List<SObject> newExtLst, Map<Id, SObject> oldItems){
        system.debug('MPM Prefix');
        Map<String,Ext_Title__c> inboundExtMap= new Map<String,Ext_Title__c>();
        Map<String,MPM__c> mpmMatchMap= new Map<String,MPM__c>();
        
        for(SObject rec:newExtLst){
            Ext_Title__c ext=(Ext_Title__c)rec;
            if(ext.SGENNO__c != null){
                inboundExtMap.put(ext.SGENNO__c,ext);
            }
            
        }
        set<string> fuzzyMatchKeys = new set<string>();
        for(String sgn:inboundExtMap.keySet()){
            fuzzyMatchKeys.add('%'+sgn+'%');
        }
        
		//ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
		//Added check for FRB Reporting Group = “Universal-Warner Bros JV” in MPM__c and removed the check for MPM_Short_Desc__c.       
        List<MPM__C> mpmList  = [SELECT Financial_Comment_3__c,Id,MPM_Number__c FROM MPM__c WHERE FRB_Reporting_Group__c =: frbReportingGroup and Financial_Comment_3__c like :fuzzyMatchKeys];
        system.debug('mpmList:'+mpmList);
        For(MPM__c mpm:mpmList) {            
            if(mpm.financial_comment_3__c!=null && mpm.financial_comment_3__c.contains(':') && mpm.financial_comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){                
                if(!mpm.financial_comment_3__c.contains(';')){
                    String actualSysGenValue=mpm.financial_comment_3__c.substringAfter(':');
                    system.debug('actualSysGenValue:'+actualSysGenValue);
                    mpmMatchMap.put(actualSysGenValue,mpm);
                    //ext.SGENNO__c = actualSysGenValue; 
                }
                if(mpm.financial_comment_3__c.contains(';')){
                    
                   	//ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
                    //Added condition to check anywhere in financial Comment 3 for the substring followed by J01: prefix 
                        
                    List<String> financialComment = mpm.financial_comment_3__c.split(';');
                    String modifiedSysGenValue='';
                    for(String fc:financialComment){
                        if(fc.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                        modifiedSysGenValue=fc.substringAfter(':');
                        mpmMatchMap.put(modifiedSysGenValue,mpm);
                        }
                    }
                    /*String initalSysGenValue=mpm.financial_comment_3__c.SubStringBefore(';');
                    if (initalSysGenValue.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
                    String modifiedSysGenValue=  mpm.financial_comment_3__c.substringAfter(':');
                    String finalSysGenValue=  modifiedSysGenValue.SubStringBefore(';');
                    system.debug('finalSysGenValue:'+finalSysGenValue);
                    mpmMatchMap.put(finalSysGenValue,mpm);*/
                    //ext.SGENNO__c = finalSysGenValue; 
                    }          
            }else{
                mpmMatchMap.put(mpm.Financial_Comment_3__c,mpm); 
            }
        }
        for(String sgn:inboundExtMap.keySet()){
            Ext_Title__c extL= inboundExtMap.get(sgn);
            Ext_Title__C extold = (Ext_Title__C)oldItems.get(extL.id);
            if(extL.SGENNO__c!=extold.SGENNO__c){
                if(mpmMatchMap!=null && mpmMatchMap.containsKey(sgn)){
                
                    extL.MPM__c= mpmMatchMap.get(sgn).Id;
                    extL.MPM_Request_Status__c= System.Label.RF_MPM_Request_Status_Complete;
                    extL.Integration_State__c = LABEL.RF_PICK_ME_UP;
                    
                    setprefix(extL, mpmMatchMap.get(sgn));
                    
                    extL.MPM_Number__c= mpmMatchMap.get(sgn).MPM_Number__c;
                    system.debug('EXTITLleMPM_Number__c'+extL.MPM_Number__c);
                     
                }
                else {
                    extL.MPM__c=null;
                    extL.MPM_Number__c='';
                    extL.MPM_Request_Status__c= System.Label.RF_MPM_Request_Status_MPM_Required;
                    extL.Integration_State__c = LABEL.RF_PICK_ME_UP;                      
                }
            }
            
        }
       
    }
    
    public static void updateMpmNumber( List<SObject> newExtLst, Map<Id, SObject> oldItems){
      Map<String,Ext_Title__c> inboundExtMap= new Map<String,Ext_Title__c>();
        
        for(SObject rec:newExtLst){
            Ext_Title__c ext=(Ext_Title__c)rec;
            if(ext.mpm__c != null){
                inboundExtMap.put(ext.mpm__c,ext);
            }
        } 
       
        List<MPM__C> mpmList  = [SELECT Id,MPM_Number__c FROM MPM__c where id in :inboundExtMap.keyset()];
        if(mpmList.size()>0){
           for(MPM__c mpm:mpmList) {
               if(inboundExtMap.containsKey(mpm.id)){
                   ext_title__c ext = inboundExtMap.get(mpm.id);
                   ext.mpm_number__c = mpm.mpm_number__c;
               }           
        	}  
        }
    }    
    
    public static void setprefix(Ext_Title__c ext, MPM__c mpm){
        //extracting the system generated number from financial comment 3
        if(mpm.financial_comment_3__c!=null && mpm.financial_comment_3__c.contains(':') && mpm.financial_comment_3__c.contains(System.Label.RF_Financial_Comment_3_Prefix_J01)){
            
            if(!mpm.financial_comment_3__c.contains(';')){
                String actualSysGenValue=mpm.financial_comment_3__c.substringAfter(':');//J01:121222
                system.debug('actualSysGenValue:'+actualSysGenValue);
                ext.SGENNO__c = actualSysGenValue; 
            }
            if(mpm.financial_comment_3__c.contains(';')){
                
                //ER-007280 | Change the MPM/Ext Title Matching Process To Use FRB Reporting Group
               	//Added condition to check anywhere in financial Comment 3 for the substring followed by J01: prefix 
                        
                List<String> financialComment = mpm.financial_comment_3__c.split(';');
                    String modifiedSysGenValue='';
                    for(String fc:financialComment){
                        if(fc.contains(System.Label.RF_Financial_Comment_3_Prefix_J01))
                        modifiedSysGenValue=fc.substringAfter(':');
                    }
                /*
                String modifiedSysGenValue=  mpm.financial_comment_3__c.substringAfter(':');
                String finalSysGenValue=  modifiedSysGenValue.SubStringBefore(';');//J01:121222;J01:122122
                system.debug('finalSysGenValue:'+finalSysGenValue);
                ext.SGENNO__c = finalSysGenValue; */
                
                if(modifiedSysGenValue==ext.SGENNO__c)
                ext.SGENNO__c = modifiedSysGenValue; 
			 }
        }
        else{
            //Prefixing J01: to financial comment 3
            system.debug('ading prefix '+ mpm.financial_comment_3__c);
            ext.SGENNO__c = mpm.financial_comment_3__c;
            System.debug('mpm.financial_comment_3__c'+mpm.financial_comment_3__c);
            mpm.financial_comment_3__c = System.Label.RF_Financial_Comment_3_Prefix_J01+':'+mpm.financial_comment_3__c;
            update mpm;
        }
        
    }
 
    // Updating Integration state to "PICK ME UP" if user change Ext Title Mpm request change
    public static void SetMPMRequeststatus( List<SObject> newExtList, Map<Id, SObject> oldItems){
        Map<String,Ext_Title__c> inboundExtMap= new Map<String,Ext_Title__c>();
    		for(SObject ex:newExtList){
            Ext_Title__c ext=(Ext_Title__c)ex;
                inboundExtMap.put(ex.id,ext);
               if(ext.MPM_Request_Status__c == System.Label.RF_MPM_Request_Status_MPM_Required 
               ||ext.MPM_Request_Status__c == System.Label.RF_MPM_Request_Status_MPM_Requested 
               ||ext.MPM_Request_Status__c == System.Label.RF_MPM_Request_Status_MPM_Update_Required 
               ||ext.MPM_Request_Status__c == System.Label.RF_MPM_Request_Status_MPM_Update_Requested 
               ||ext.MPM_Request_Status__c == System.Label.RF_MPM_Request_Status_MPM_Rejected){
                 
                   ext.Integration_State__c = LABEL.RF_PICK_ME_UP;
                
            }
        }
        
    }
}