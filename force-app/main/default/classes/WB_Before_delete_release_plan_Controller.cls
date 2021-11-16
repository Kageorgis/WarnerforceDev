Public with sharing class WB_Before_delete_release_plan_Controller{

    public static void beforedelete_releaseplan(){
        list<Client_Avail__c> lst_client_aval = new list<Client_Avail__c>();
        list<Commercial_Avail__c> lst_commercial_aval = new list<Commercial_Avail__c>();
        list<string> lst_commercialavailids = new list<string>();
        list<User> userDetail = new list<User>();
        userDetail =[   SELECT id,ProfileId,Profile.Name,UserType,Territory__c,isGPPPermissionSetAssigned__c from User where id =: Userinfo.getUserId()];
        lst_commercial_aval = trigger.old;
        Map<id, List<Client_Avail__c>> releaseplanClientAvailMap = new Map<id, List<Client_Avail__c>>();
        
        set<String> setDeletedRPKey = new set<String>();
        set<Id> setDeletedRPCntry = new set<Id>();
        
        for(Commercial_Avail__c ca :lst_commercial_aval){
            lst_commercialavailids.add(ca.id);
        }   
        lst_client_aval = [SELECT id,name,Commercial_Avail__c 
                               FROM Client_Avail__c 
                               WHERE Commercial_Avail__c IN :lst_commercialavailids 
                              ];
        // create map of release plan id and release plan object in order to fetch details of release plans related records
        Map<id,Commercial_Avail__c> rpMap = new Map<id, commercial_avail__c>([select id,Name, channel__c, End_Date__c,Start_Date__c,Title__c,Title__r.Name,format__c, title__r.territory__c
                                                                                ,Country_Lookup__c,Country_Lookup__r.Name,Country_Lookup__r.Territory__c ,Languages__c,Languages__r.Name
                                                                                ,language_type__c, Status__c, MRD_Roll_up__c, MRD_ID__c, MPM_Release_Date_Key__c
                                                                                from commercial_avail__C where id IN:lst_commercialavailids]);
        
        for(Client_Avail__c ca : lst_client_aval){
            if(releaseplanClientAvailMap.get(ca.Commercial_Avail__c) == null){
                List<Client_Avail__c> caLst = new List<Client_Avail__c>();
                caLst.add(ca);
                releaseplanClientAvailMap.put(ca.Commercial_Avail__c, caLst);
            }else{
                releaseplanClientAvailMap.get(ca.Commercial_Avail__c).add(ca);
            }
        }       
        /* if WB_Territory_Release_Planner 's territory is not equal to title's territory then restrict deletion of release plan */
        for(Commercial_Avail__c objCA : lst_commercial_aval){
            Commercial_Avail__c ca = rpMap.get(objCA.Id);
            
            /*if(releaseplanClientAvailMap.containsKey(ca.id) || ((userDetail.get(0).Profile.Name != System.Label.WB_CAS_Administrator 
             && (userDetail.get(0).Profile.Name != System.Label.WB_Global_Title_Planner && userDetail.get(0).isGPPPermissionSetAssigned__c !=true) 
             && userDetail.get(0).Profile.Name != System.Label.WB_System_Administrator) 
             && ca.title__r.territory__c  != userDetail.get(0).Territory__c)){
                if((userDetail.get(0).Profile.Name != System.Label.WB_CAS_Administrator 
                && (userDetail.get(0).Profile.Name != System.Label.WB_Global_Title_Planner && userDetail.get(0).isGPPPermissionSetAssigned__c !=true) 
                && userDetail.get(0).Profile.Name != System.Label.WB_System_Administrator)  && ca.title__r.territory__c  != userDetail.get(0).Territory__c ){
                    objCA.addError('Titles Territory does not match with your territory hence cannot delete Release Plan!!');
                }else{
                    objCA.addError('Cannot delete Release Plan as it has associated Client Avails!!');
                }
             }*/
                
            if(!releaseplanClientAvailMap.containsKey(ca.id) && ca.MRD_ID__c == null){
                if(ca.MPM_Release_Date_Key__c != null){
                    setDeletedRPKey.add(ca.MPM_Release_Date_Key__c);
                    setDeletedRPCntry.add(ca.Country_Lookup__c);
                }
            }
            else if(!releaseplanClientAvailMap.containsKey(ca.id) && ca.Status__c == 'Draft' && !ca.MRD_Roll_up__c){
               if(ca.MPM_Release_Date_Key__c != null){
                    setDeletedRPKey.add(ca.MPM_Release_Date_Key__c);
                    setDeletedRPCntry.add(ca.Country_Lookup__c);
                }
            }
            else{
                if(releaseplanClientAvailMap.containsKey(ca.id))
                    objCA.addError('Release Plan cannot be deleted because there is an associated Client Avail');
                else
                    objCA.addError('Release Plan cannot be deleted because either the MRD ID field is not blank or the Release plan Status is not Draft or the MPD Rollup flag is checked'); 
            }
        }
		
        //set rollup flag of all associated RPs
        list<Commercial_Avail__c> lstUpdateRP = new list<Commercial_Avail__c>();
       
        for(Commercial_Avail__c rp : [SELECT Id, MRD_Roll_up__c, MPM_Release_Date_Key__c, Country_Lookup__c FROM Commercial_Avail__c 
                                        WHERE Country_Lookup__c IN: (setDeletedRPCntry) AND MRD_Roll_up__c = False AND MPM_Release_Date_Key__c IN: (setDeletedRPKey)]){
            rp.MRD_Roll_up__c = True;
            lstUpdateRP.add(rp);
        }
		if(lstUpdateRP.size() > 0)
			Database.Saveresult[] rpUpdateResults = Database.update(lstUpdateRP,false);
			
    } // End of function beforedelete_releaseplan()
    
    public static void afterdelete_releaseplan(List<Commercial_Avail__c> lstUndelRP){
        List<Commercial_Avail__c> lstUndeleteRP  = [SELECT Id, MRD_Roll_up__c, MPM_Release_Date_Key__c FROM Commercial_Avail__c WHERE Id IN :lstUndelRP];
        for(Commercial_Avail__c ca : lstUndeleteRP){
            ca.MRD_Roll_up__c = ca.MPM_Release_Date_Key__c != null ? True : False;
        }
            
        Database.Saveresult[] updateResults = Database.update(lstUndeleteRP,false);
    }// End of function afterdelete_releaseplan()
    
} // End of class WB_Before_delete_release_plan_Controller