public with sharing class WB_SplitReleaseplanController {
public Commercial_Avail__c obj;
public string rpids;
public list<string> lst_releaseplans {set; get;}
public list<Commercial_Avail__c> lst_releaseplandetails {set; get;} 
public date splitDate ;
public list<User> userDetail = new list<User>();
public list<string> exceptionMsg_list;
public list<string> exceptionMsgQueue_list;

public static boolean bypassTerritoryTitleValidationFromTrigger = false;//ER-000081 - Mahesh - Bypass trigger validation for Terr. Release Planner Profile

    public WB_SplitReleaseplanController(ApexPages.StandardSetController controller) {
          
          rpids = ApexPages.currentPage().getParameters().get('ID');
          lst_releaseplans = rpids.split(','); 
          system.debug('RP Ids in Spit'+ lst_releaseplans);
          //Query modified to add UPC__c by shalini for ER-14
          lst_releaseplandetails = [SELECT id,name,Title__c,Country_Lookup__c,Languages__c,Language_Type__c,Channel__c,Format__c,Status__c,End_Date__c,Start_Date__c ,
                                    Exclusive_Date__c,Rights_End__c,UPC__c,Reason_Code__c,RP_Split_Date__c FROM Commercial_Avail__c   WHERE id IN :lst_releaseplans
                                   ];
          
            system.debug('RP Ids in SOQL'+ lst_releaseplandetails);
            obj= (Commercial_Avail__c) controller.getRecord();  
            obj.Status__c = 'Draft'; 
            
            userDetail =[  SELECT id,Name  from User where id =: Userinfo.getUserId() ];
        }
        public void deleteRPSplitRec(){
            integer releaseExceptionCount = [SELECT count() FROM Release_Plan_Exceptions__c];
            system.debug('@@@clientExceptionCount'+releaseExceptionCount);
            if(releaseExceptionCount > 0){
                system.debug('user detail'+userDetail[0].Id);
                List<Release_Plan_Exceptions__c> existing = [SELECT Id From Release_Plan_Exceptions__c where User_Detail__c =:userDetail[0].Id];
                
                system.debug('@@@@existing records'+existing);
                delete existing;
            }
        }
        
        public list<Commercial_avail__c> batchIdGeneration(list<Commercial_avail__c> list_TobeUpdate){
            
            list<Batch_Ids_Customsetting__c> clientAvailBatchId_lst = [Select Id,Name,CA_Batch_Id__c,RP_Batch_Id__c,RP_Created_Date__c,CA_User_Detail__c from 
                                                                       Batch_Ids_Customsetting__c for update];
            
            integer incremnt = integer.ValueOf(clientAvailBatchId_lst[0].RP_Batch_Id__c);           
            incremnt++;         
            string finalBatchId = String.valueOf(incremnt);       
            
            clientAvailBatchId_lst[0].Name = userDetail[0].Id;
            clientAvailBatchId_lst[0].RP_Batch_Id__c = finalBatchId ;
            clientAvailBatchId_lst[0].RP_Created_Date__c = system.now();
            clientAvailBatchId_lst[0].CA_User_Detail__c = userDetail[0].Id;
            
            Database.Upsertresult[] saveBatchResult  = Database.upsert(clientAvailBatchId_lst, false);
            system.debug('@@@saveBatchResult'+saveBatchResult);
            if(saveBatchResult[0].isSuccess()){         
            
            userDetail[0].RP_Batch_Id__c = clientAvailBatchId_lst[0].RP_Batch_Id__c;
            update userDetail[0];
        }
        
        for(Commercial_Avail__c client :list_TobeUpdate){
            client.Batch_Id__c = clientAvailBatchId_lst[0].RP_Batch_Id__c;
        }
        return list_TobeUpdate ;
    }
    
    public pagereference splitReleasePlan(){
    
        bypassTerritoryTitleValidationFromTrigger = true;//ER-000081 - Mahesh - Bypass trigger validation for Terr. Release Planner Profile
        splitDate = obj.RP_Split_Date__c;
        boolean noDate=false;
        if(splitDate == null){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select date to proceed'));
            noDate=true;
        }
        if(noDate==false){
        integer countDate=0;
        system.debug('lst_releaseplandetails ===> ' + lst_releaseplandetails);
        
        for(commercial_avail__c comm:lst_releaseplandetails){
            if(comm.Exclusive_Date__c == Null && comm.Rights_End__c == null){
                if(comm.Start_Date__c > splitDate || comm.End_Date__c < splitDate){
                   countDate++;//list whose status is Not releasing: avail dates are not mandatory
                   system.debug('in for loop countDate ' + countDate);
                }
            }
            else{
                if(comm.Exclusive_Date__c > splitDate || comm.Rights_End__c < splitDate){
                    countDate++;// list where entered date is out side the RP avail dates
                    system.debug('in Else loop countDate ' + countDate);
                }
            }
        }
        system.debug('countDate  ' + countDate);
        if(countDate !=lst_releaseplandetails.size()){
            list<Schema.FieldSetMember> selectedReleasepln_lst = new list<Schema.FieldSetMember>();
            list<Commercial_Avail__c> selectedReleasepln_lst2 = new list<Commercial_Avail__c>();
            list<Client_Avail__c> clientAvailsOfRPs = new list<Client_Avail__c>();
            
            set<Commercial_Avail__c> exceptionRP_lst = new set<Commercial_Avail__c>();
            set<Commercial_Avail__c> exceptionRP_lst1 = new set<Commercial_Avail__c>();
            set<Commercial_Avail__c> exceptionRP_lst2 = new set<Commercial_Avail__c>();
            set<Commercial_Avail__c> spltdtOutsdAvailDatesRP_lst = new set<Commercial_Avail__c>();
            exceptionMsg_list = new list<string>();
            exceptionMsgQueue_list = new list<string>();
            
            list<Commercial_Avail__c> filteredRP_lst = new list<Commercial_Avail__c>();
            list<Commercial_Avail__c> newlyCreatedRP_lst = new list<Commercial_Avail__c>();
            
            date prevousDate = splitDate.addDays(-1);
            system.debug('prevousDate'+prevousDate);
            //release plan list with all fields for cloning.
            selectedReleasepln_lst = Schema.SObjectType.Commercial_Avail__c.fieldSets.getMap().get('All_fields_ReleasePlan').getFields();
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : selectedReleasepln_lst ){
            query += f.getFieldPath()+ ', ';
            }
            query += 'Id,UPC__c FROM Commercial_Avail__c where Id IN:lst_releaseplandetails ';
            selectedReleasepln_lst2 =Database.query(query);
            system.debug('@@selectedReleasepln_lst2'+selectedReleasepln_lst2+'selectedReleasepln_lst2 size'+selectedReleasepln_lst2.size());
            
            clientAvailsOfRPs =[Select Name, Start_Date__c,End_Date__c,Commercial_Avail__c from Client_Avail__c where Commercial_Avail__c IN :selectedReleasepln_lst2];
            system.debug('@@clientAvailsOfRPs'+clientAvailsOfRPs);
            
            //finding exception RPs list
            for (Commercial_Avail__c comm :selectedReleasepln_lst2){
                if(comm.Exclusive_Date__c == Null && comm.Rights_End__c == null){
                    if(comm.Start_Date__c > splitDate || comm.End_Date__c < splitDate){
                        exceptionRP_lst2.add(comm);//list whose status is Not releasing: avail dates are not mandatory
                    }
                   
                }
                else{
                    if(comm.Exclusive_Date__c > splitDate || comm.Rights_End__c < splitDate){
                            exceptionRP_lst.add(comm);// list where entered date is out side the RP avail dates
                            
                        }
                    else{
                            for (Client_Avail__c client :clientAvailsOfRPs){
                                if(client.Commercial_Avail__c == comm.Id ){
                                    if( prevousDate < client.End_Date__c){
                                       // exceptionRP_lst1.add(comm);//list of RP whose client avail dates not overlap with entered date
                                        system.debug('@exceptionRP_lst1'+exceptionRP_lst1);
                                    }
                                }
                            }
                        }
                    }
                }
            system.debug('@@finalexceptionRP_lst'+exceptionRP_lst);
            system.debug('@@finalexceptionRP_lst1'+exceptionRP_lst1);
            //final list of RPs whose going to update and cloned.
            
            for (Commercial_Avail__c comm :selectedReleasepln_lst2){
                 if (exceptionRP_lst.contains(comm)|| exceptionRP_lst1.contains(comm) || exceptionRP_lst2.contains(comm)){
                 }else{
                 filteredRP_lst.add(comm); 
                 }
            }   
           system.debug('final list filteredRP_lst'+filteredRP_lst); 
           
           //For newly created commercial avails
           for(Commercial_Avail__c comm : filteredRP_lst){
            
                Commercial_Avail__c newRP = new Commercial_Avail__c();
                //Entered Date withon start and End Date
                if(comm.Start_Date__c < splitDate && comm.End_Date__c >= splitDate){                
                    newRP = comm.clone(false,false,false,false);
                    newRP.Start_Date__c = splitDate;
                    newRP.End_Date__c = comm.End_Date__c;
                    newRP.Status__c = obj.Status__c;
                    //added by shalini for ER-14
                    newRP.UPC__c = comm.UPC__c;
                    if(obj.Language_Type__c != null){
                    newRP.Language_Type__c = obj.Language_Type__c;
                    }
                    
                    newlyCreatedRP_lst.add(newRP);
                    system.debug('newlyCreatedRP_lst in 1st senario'+newlyCreatedRP_lst);
                }
                //Entered date within avail start date and RP starat date
                else if(splitDate >= comm.Exclusive_Date__c && splitDate < comm.Start_Date__c){
                    spltdtOutsdAvailDatesRP_lst.add(comm);
                    newRP = comm.clone(false,false,false,false);
                    newRP.Start_Date__c = splitDate;
                    newRP.End_Date__c = comm.Start_Date__c.addDays(-1);
                    newRP.Status__c = obj.Status__c;
                    //added by shalini for ER-14
                    newRP.UPC__c = comm.UPC__c;
                    if(obj.Language_Type__c != null){
                    newRP.Language_Type__c = obj.Language_Type__c;
                    }
                    newlyCreatedRP_lst.add(newRP);
                    system.debug('newlyCreatedRP_lst in 2nd senario'+newlyCreatedRP_lst);
                }
                //Entered date within RP end date and Avail end date
                else if(splitDate > comm.End_Date__c &&  splitDate <= comm.Rights_End__c){
                    spltdtOutsdAvailDatesRP_lst.add(comm);
                    newRP = comm.clone(false,false,false,false);
                    newRP.Start_Date__c = splitDate;
                    newRP.End_Date__c = comm.Rights_End__c;
                    newRP.Status__c = obj.Status__c;
                    //added by shalini for ER-14
                    newRP.UPC__c = comm.UPC__c;
                    if(obj.Language_Type__c != null){
                    newRP.Language_Type__c = obj.Language_Type__c;
                    }
                    newlyCreatedRP_lst.add(newRP);
                    system.debug('newlyCreatedRP_lst in 3rd senario'+newlyCreatedRP_lst);
                }
           }
           system.debug('@@newlyCreatedRP_lst'+newlyCreatedRP_lst+'size'+newlyCreatedRP_lst.size());
           system.debug('@@@list of RPs whose are not going to update'+spltdtOutsdAvailDatesRP_lst);
           
           //Updating existing filtered RPs  
           for(Commercial_Avail__c comm : filteredRP_lst){
                if(comm.Start_Date__c < splitDate && comm.End_Date__c >= splitDate){
                    comm.End_Date__c = prevousDate;
                }
           } 
           system.debug('after updating the end date filteredRP_lst'+filteredRP_lst);
           
           //Custom setting code
           /*
            integer releaseExceptionCount = [SELECT count() FROM Release_Plan_Exceptions__c];
            system.debug('@@@clientExceptionCount'+releaseExceptionCount);
            if(releaseExceptionCount > 0){
                List<Release_Plan_Exceptions__c> existing = [SELECT Id From Release_Plan_Exceptions__c where User_Detail__c =:userDetail[0].Id];
                system.debug('@@@@existing records'+existing);
                delete existing;
            }
            */
            //deleteRPSplitRec();
            list<Release_Plan_Exceptions__c> releasePlanException_listold = new list<Release_Plan_Exceptions__c>();
            list<Release_Plan_Exceptions__c> releasePlanException_listnew = new list<Release_Plan_Exceptions__c>();
            list<Release_Plan_Exceptions__c> releasePlanException_listnew2 = new list<Release_Plan_Exceptions__c>();
            list<Release_Plan_Exceptions__c> releasePlanException_listfinal = new list<Release_Plan_Exceptions__c>();
            
            //insertion of old release plan records into Exception custom setting
            
            for(Commercial_Avail__c commercial :selectedReleasepln_lst2){
                Release_Plan_Exceptions__c releaseExcep = new Release_Plan_Exceptions__c();                    
                string str = String.valueOf(commercial.Name) + String.valueOf(userDetail[0].Id)+'old';
                system.debug('str old   ' + str);
                releaseExcep.Name = str;
                releaseExcep.User_Detail__c = userDetail[0].Id;
                releaseExcep.Release_Plan_Id__c = commercial.Name;
                releaseExcep.Title__c = commercial.Title__r.Name;                                          
                releaseExcep.Country__c = commercial.Country_Lookup__r.Name;
                releaseExcep.Language__c = commercial.Languages__r.Name;
                releaseExcep.Format__c = commercial.Format__c;
                releaseExcep.Channel__c = commercial.Channel__c;
                releaseExcep.Language_Type__c = commercial.Language_Type__c;
                
                releaseExcep.Avails_Start__c = commercial.Exclusive_Date__c;
                releaseExcep.Avails_End__c = commercial.Rights_End__c;
                releaseExcep.Release_Start_Date__c = commercial.Start_Date__c;
                releaseExcep.Release_End_Date__c = commercial.End_Date__c;
                releaseExcep.Status__c = commercial.Status__c;
                releaseExcep.Old_RP_Records__c = true;
                if(exceptionRP_lst.contains(commercial)){
                    releaseExcep.Reason__c = 'Release Plan cannot split because Split date is outside the Avail Dates ';
                }else if(exceptionRP_lst1.contains(commercial)){
                    releaseExcep.Reason__c = 'Release Plan cannot split because it makes Client Avails inactive in the process ';
                }else if(exceptionRP_lst2.contains(commercial)){
                    releaseExcep.Reason__c = 'Release Plan cannot split because Split date is outside the Release Dates ';
                }else if(spltdtOutsdAvailDatesRP_lst.contains(commercial)){
                    releaseExcep.Reason__c ='Release Plan cannot split because Split date is outside the Release Dates but it will create a new Release Plan '; 
                }else releaseExcep.Reason__c =''; 
                
               
                releasePlanException_listold.add(releaseExcep);           
              
                
            }
            system.debug('@@@releasePlanException_listold old release plans'+releasePlanException_listold);        
            
            releasePlanException_listfinal.addAll(releasePlanException_listold);
            list<commercial_avail__c>  commercialAvailListInsert= new  list<commercial_avail__c>();
           
           try{
                if(filteredRP_lst.size()!=0 && filteredRP_lst != null){
                    Database.Saveresult[] saveResult  = Database.update(filteredRP_lst, false);
                    system.debug('@@@@saveResult11'+saveResult);
                    system.debug('@@@@saveResult11size'+saveResult.size());
                    
                    boolean flageReDirect=true;
                    for(integer i=0;i<saveResult.size();i++){
                        if(!(saveResult[i].isSuccess())){
                                flageReDirect=false;
                        }                    
                    }
                    if (flageReDirect==true){
                        list<string> newlyReleasePlnIds = new list<string>();
                        try{
                            if(newlyCreatedRP_lst.size() != 0 && newlyCreatedRP_lst!= null){
                                commercialAvailListInsert= batchIdGeneration(newlyCreatedRP_lst);                   
                                Database.Saveresult[] saveResult1  = Database.insert(commercialAvailListInsert, false);
                                system.debug('@@saveResult1'+saveResult1);
                                system.debug('@@saveResult1size'+saveResult1.size());
                                
                                for(Database.Saveresult sr :saveResult1){                           
                                    if (sr.isSuccess()){
                                        newlyReleasePlnIds.add(sr.getId());
                                        
                                    }
                                    else if (!sr.isSuccess()){
                                        Database.Error[] error = sr.getErrors();
                                        for(Database.Error er :error){
                                            String failedDML = er.getMessage();
                                            exceptionMsg_list.add(failedDML);
                                        }
                                       system.debug('@@@exceptionMsg_list'+exceptionMsg_list); 
                                    }
                                }                        
                            }
                        }catch(exception e){
                            system.debug('The error message to print'+e);
                        }
                        list<Commercial_Avail__c> newlyCreatedRPs = [Select Name,Title__c,Title__r.Name,Country_Lookup__r.Name, Languages__r.Name,Format__c,
                                                                    Channel__c,Language_Type__c,Exclusive_Date__c,Rights_End__c,Start_Date__c,
                                                                    End_Date__c,Status__c from Commercial_Avail__c where Id IN:newlyReleasePlnIds];
                        system.debug('@@newlyCreatedRPs1111'+newlyCreatedRPs);
                                                                    
                        //insertion of new client avail records into Exception custom setting
                        for(Commercial_Avail__c commercial :newlyCreatedRPs){
                            Release_Plan_Exceptions__c releaseExcep = new Release_Plan_Exceptions__c();                    
                            string str = String.valueOf(commercial.Name) + String.valueOf(userDetail[0].Id)+'new';
                            system.debug('str new  ' + str);
                            releaseExcep.Name = str;
                            releaseExcep.User_Detail__c = userDetail[0].Id;
                            releaseExcep.Release_Plan_Id__c = commercial.Name;
                            releaseExcep.Title__c = commercial.Title__r.Name;                                          
                            releaseExcep.Country__c = commercial.Country_Lookup__r.Name;
                            releaseExcep.Language__c = commercial.Languages__r.Name;
                            releaseExcep.Format__c = commercial.Format__c;
                            releaseExcep.Channel__c = commercial.Channel__c;
                            releaseExcep.Language_Type__c = commercial.Language_Type__c;
                            
                            releaseExcep.Avails_Start__c = commercial.Exclusive_Date__c;
                            releaseExcep.Avails_End__c = commercial.Rights_End__c;
                            releaseExcep.Release_Start_Date__c = commercial.Start_Date__c;
                            releaseExcep.Release_End_Date__c = commercial.End_Date__c;
                            releaseExcep.Status__c = commercial.Status__c;
                            releaseExcep.Old_RP_Records__c = false;                               
                           
                            releasePlanException_listnew.add(releaseExcep);         
                          
                        }
                        for(integer i=0 ;i<exceptionMsg_list.size();i++){
                            Release_Plan_Exceptions__c releaseExcep = new Release_Plan_Exceptions__c();
                            string str = String.valueOf(i) + String.valueOf(userDetail[0].Id)+'new';
                            releaseExcep.Name = str;
                            releaseExcep.User_Detail__c = userDetail[0].Id;
                            releaseExcep.Old_RP_Records__c = false;
                            releaseExcep.Exception_with_ExistingRecord__c = true;
                            releaseExcep.Reason__c =exceptionMsg_list[i];
                            
                            releasePlanException_listnew2.add(releaseExcep);  
                            
                        }
                        releasePlanException_listfinal.addAll(releasePlanException_listnew);
                        releasePlanException_listfinal.addAll(releasePlanException_listnew2);
                        system.debug('@@@releasePlanException_listfinal old+new'+releasePlanException_listfinal);
                        //final list insertion
                        if(releasePlanException_listfinal.size() != 0 && releasePlanException_listfinal!= null){
                            Database.Saveresult[] saveResult2  = Database.insert(releasePlanException_listfinal, false);
                            system.debug('@@@@saveResult333'+saveResult2+'size'+saveResult2.size());                                               
                        }
                                                   
                        Pagereference PageRef = new Pagereference('/apex/WB_SplitRP_Redirect');                    
                        system.debug('@@PageRef'+PageRef);
                        return PageRef;
                    }
                    else{
                        filteredRP_lst.clear();
                        newlyCreatedRP_lst.clear();
                        return null;
                    }                
                }else if(releasePlanException_listfinal!=null || releasePlanException_listfinal.size()!=0){
                    try{
                        system.debug('in else if');
                        Database.Saveresult[] saveResult2  = Database.insert(releasePlanException_listfinal, false);
                        Pagereference PageRef = new Pagereference('/apex/WB_SplitRP_Redirect');               
                        return PageRef;
                        
                    }catch(exception e){
                        system.debug('an exception occured'+e);                 
                    }
                    
                    
                }else {
                    Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Selected Date is outside the Avail dates'));
                }
                
           }
           catch(Exception e){
                system.debug('The following exception has occured'+e.getMessage());
           } 
      }else Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Selected Date is outside the Avail dates'));
      }
      return null;
      }
      
      public pageReference Bulkcancel(){
        pageReference PageRef= new Pagereference(System.Label.Redirect_to_All_Release_Plans);
        return PageRef;
        }


}