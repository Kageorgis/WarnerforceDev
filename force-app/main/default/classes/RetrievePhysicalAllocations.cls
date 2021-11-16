global class RetrievePhysicalAllocations{
  
  // Global list of titles after mapping of data
     global static List<Title__c> listOfTitles = new List<Title__c>();
    
    // Class definition of the inbound title object for de-serialization
     global class VideoversionDetails{
      // String names match SFDC API Names for associated objects (Title__c)
      webService String Video_Version;  //Match to Videoversion number in Title Object
     }
       // Class definition of the returned data struction
     global class ResponseMessage 
     {
       //webService Boolean Message_Result;              // True/False indicator of success
        //webService String Error_Message;                // Detailed message of failure
        webService String Video_Version;                // Video Version that caused the failure
        webService String ECTechnical_Id;
        webService Decimal PLMId;
        webService String EC_Name1;
        webService String EC_Name2;
        webService String EC_Name3;
        webService String EC_Description1;
        webService String EC_Description2;
        webService String EC_Description3;
        webService String EC_Description4;
        webService String EC_Description5;
        webService String Image_Number;
        webService String EC_Type;
        webService String Aud_Indicator;
        webService String Deliverable_Format;
        webService Decimal Runtime_Min;
        webService Decimal Runtime_Sec;
        webService String EC_Menu_Icon;
        webService String Aspect_Ratio;
        webService String Resolution;
        webService String EC_Audio_Format;
        webService String Audio_Language_Type;
        webService String Language;
        webService String Usage;
        webService String Delivery_Date;
        webService String Vendor;
     }
      /**************************************************************************
     * Method Name:     RetriveAllocation
     * Description:     Exposed as a web service to retrive VideoVersion & EC Allocation Object data
     * Parameters:      Accepts a Videoversion number for Collecting the Data
     * Returns:         List of VideoVersion & EC Allocation Records
     **************************************************************************/
     webservice static List<ResponseMessage> RetriveAllocation (List<VideoversionDetails> VVInfo){
       List<ResponseMessage> replyAllocation = new List<ResponseMessage>();
       List <Transaction_Log__c> listOfTransactions = new List<Transaction_Log__c>();
       List <Error_Log__c> listOfErrors = new List<Error_Log__c>();
       List<Title__c> titles = new List<Title__c>();
       List<String> allVVinfo = new List<String>();
       List<Id> allecinfo = new List<Id>();
       List<Id> alltrackerinfo = new List<Id>();
       List<EC_Piece__c> ecList = new List<EC_Piece__c>();
       List<Contact_Assignment__c> contactAssignmentsList = new List<Contact_Assignment__c >();
       for(VideoversionDetails vvd2:VVInfo){
          allVVinfo.add(vvd2.Video_Version);
       }
       List<EC_Title_Allocation__c> ectList = [select EC_Piece__c,Title__c,Video_Version_Number__c,PLM_ID__c,
                                                    MPM__c,EC_Piece__r.Id,EC_Piece__r.Name,EC_Piece__r.EC_Name__c,
                                                    EC_Piece__r.EC_Tracker__c,EC_Piece__r.Long_Description__c,EC_Piece__r.Image_Number__c,
                                                    EC_Piece__r.EC_Type__c,EC_Piece__r.Usage__c,EC_Piece__r.Aud_Ind__c,EC_Piece__r.Dlvbl__c,
                                                    EC_Piece__r.Min__c,EC_Piece__r.Sec__c,EC_Piece__r.EC_Menu_Icon__c,EC_Piece__r.Asp_Ratio__c,
                                                    EC_Piece__r.Res__c,EC_Piece__r.Audio_Format__c,EC_Piece__r.Audio_Language_Type__c,EC_Piece__r.Lang__c,
                                                    EC_Piece__r.Delivery_Date__c from EC_Title_Allocation__c where Video_Version_Number__c IN:allVVinfo];           
                      
       for(EC_Title_Allocation__c ect2:ectList){
            allecinfo.add(ect2.EC_Piece__c);
       }
       ecList = [select Id,EC_Tracker__c from EC_Piece__c where Id IN:allecinfo];
       for(EC_Piece__c ec2:ecList){
            alltrackerinfo.add(ec2.EC_Tracker__c);
       }
       contactAssignmentsList = [select Account__r.Name,EC_Tracker__c from Contact_Assignment__c
                                    where Role__c = 'EC Vendor' and EC_Tracker__c IN:alltrackerinfo];
       titles = [select Id,Video_Version__c from Title__c where Video_Version__c IN:allVVinfo];
        system.debug('titles---------------->>>'+titles);
       if(VVInfo.size()>0){
           for(VideoversionDetails vvd:VVInfo){
                if(vvd.Video_Version != null && vvd.Video_Version != ''){ 
                system.debug('vv---------------->>>'+vvd.Video_Version);
                  Boolean isvv = false;
                   for(Title__c tile:titles){
                     if(tile.Video_Version__c == vvd.Video_Version){
                     
                         isvv = true;
                     }
                   
                   }
                   system.debug('titles---------------->>>'+titles);
                    system.debug('isvv---------------->>>'+isvv); 
                    if(titles.size()>0 && isvv == true){
                        Boolean AllocCheck = false;
                          system.debug('ectList---->>>'+ectList);
                        system.debug('ectList size---->>>'+ectList.size());
                        
                        for(EC_Title_Allocation__c ect:ectList){
                           AllocCheck = true;
                           system.debug('ect.EC_Piece__r.Name---->>>'+ect.EC_Piece__r.Name);
                           system.debug('ect.EC_Piece__r.EC_Name__c---->>>'+ect.EC_Piece__r.EC_Name__c);
                           system.debug('ect.EC_Piece__r.Long_Description__c---->>>'+ect.EC_Piece__r.Long_Description__c);
                                ResponseMessage sendect = new ResponseMessage();
                                sendect.Video_Version = vvd.Video_Version;               
                                sendect.ECTechnical_Id = ect.EC_Piece__r.Name;
                                sendect.PLMId = ect.PLM_ID__c; 
                                system.debug('ect.EC_Piece__r.EC_Name__c.length()---------------->>>'+ect.EC_Piece__r.EC_Name__c.length());
                                if(ect.EC_Piece__r.EC_Name__c == null || ect.EC_Piece__r.EC_Name__c.length() <= 60){
                                   sendect.EC_Name1 = ect.EC_Piece__r.EC_Name__c;
                                   sendect.EC_Name2 = null;
                                   sendect.EC_Name3 = null;
                                }else { 
                                   system.debug('ect.EC_Piece__r.EC_Name__c.substring(59,60)----->>>'+ect.EC_Piece__r.EC_Name__c.substring(59,60)); 
                                   if(ect.EC_Piece__r.EC_Name__c.substring(59,60) == ' '){
                                       system.debug('Came Here');
                                       sendect.EC_Name1 = ect.EC_Piece__r.EC_Name__c.substring(0,59);
                                       if(ect.EC_Piece__r.EC_Name__c.length() >= 118){
                                          if(ect.EC_Piece__r.EC_Name__c.length() > 118){
                                               system.debug('118,119 character ---->>>>'+ect.EC_Piece__r.EC_Name__c.substring(118,119));
                                               if(ect.EC_Piece__r.EC_Name__c.substring(118,119) == ' '){
                                                   sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(59,118);
                                                   sendect.EC_Name3 = ect.EC_Piece__r.EC_Name__c.substring(118);
                                               }else{
                                                   sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(59,119);
                                                   sendect.EC_Name3 = ect.EC_Piece__r.EC_Name__c.substring(119);
                                               }    
                                           }else if(ect.EC_Piece__r.EC_Name__c.length() == 118){
                                               sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(59,118);
                                               sendect.EC_Name3 = ect.EC_Piece__r.EC_Name__c.substring(118);
                                           }
                                       }else{
                                          sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(59);
                                          sendect.EC_Name3 = null;
                                       
                                       }    
                                   }else{
                                       sendect.EC_Name1 = ect.EC_Piece__r.EC_Name__c.substring(0,60);
                                       if(ect.EC_Piece__r.EC_Name__c.length() >= 119){
                                          if(ect.EC_Piece__r.EC_Name__c.length() > 119){
                                              if(ect.EC_Piece__r.EC_Name__c.substring(119,120) == ' '){
                                                   sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(60,119);
                                                   sendect.EC_Name3 = ect.EC_Piece__r.EC_Name__c.substring(119);
                                               }else{
                                                   sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(60,120);
                                                   sendect.EC_Name3 = ect.EC_Piece__r.EC_Name__c.substring(120);
                                               }    
                                           }else if(ect.EC_Piece__r.EC_Name__c.length() == 119){
                                               sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(60,119);
                                               sendect.EC_Name3 = ect.EC_Piece__r.EC_Name__c.substring(119);
                                           }
                                       }else{
                                          sendect.EC_Name2 = ect.EC_Piece__r.EC_Name__c.substring(60);
                                          sendect.EC_Name3 = null;
                                       }    
                                   } 
                                }
                    system.debug('EC Technical Id---------------->>>'+ect.EC_Piece__r.Name);
        
                                system.debug('sendect.EC_Name1---------------->>>'+sendect.EC_Name1);
                                system.debug('sendect.EC_Name2---------------->>>'+sendect.EC_Name2);
                                system.debug('sendect.EC_Name3---------------->>>'+sendect.EC_Name3);
                                
                               // Name calculation ends
                               //EC Description Calculation starts
                              if(ect.EC_Piece__r.Long_Description__c == null || ect.EC_Piece__r.Long_Description__c.length() <= 60){
                                    sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c;
                                    sendect.EC_Description2 = null;
                                    sendect.EC_Description3 = null;
                                    sendect.EC_Description4 = null;
                                    sendect.EC_Description5 = null;
                               }else if(ect.EC_Piece__r.Long_Description__c.length() <= 120){
                                         system.debug('Long_Description__c length 120 check---->>>'+ect.EC_Piece__r.Long_Description__c.length());
                                        if(ect.EC_Piece__r.Long_Description__c.substring(59,60) == ' '){
                                           sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c.substring(0,59);
                                           system.debug('sendect.EC_Description1 length---->>>'+sendect.EC_Description1.length());
                                           if(ect.EC_Piece__r.Long_Description__c.length() >= 118){
                                              if(ect.EC_Piece__r.Long_Description__c.length() > 118){
                                                  if(ect.EC_Piece__r.Long_Description__c.substring(118,119) == ' '){
                                                      sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,118);
                                                      sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118);
                                                      sendect.EC_Description4 = null;
                                                      sendect.EC_Description5 = null;
                                                 }else{
                                                      sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,119);
                                                      sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119);
                                                      sendect.EC_Description4 = null;
                                                      sendect.EC_Description5 = null;
                                                 }    
                                              }else if(ect.EC_Piece__r.Long_Description__c.length() == 118){
                                                      sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,118);
                                                      sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118);
                                                      sendect.EC_Description4 = null;
                                                      sendect.EC_Description5 = null;
                                              }
                                          }else{
                                              sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59);
                                              sendect.EC_Description3 = null;
                                              sendect.EC_Description4 = null;
                                              sendect.EC_Description5 = null;
                                         }    
                                      }else{
                                         sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c.substring(0,60);
                                         system.debug('actual description------>>>'+ect.EC_Piece__r.Long_Description__c);
                                         if(ect.EC_Piece__r.Long_Description__c.length() >= 119){
                                             system.debug('119 length------>>>'+ect.EC_Piece__r.Long_Description__c.length());
                                            if(ect.EC_Piece__r.Long_Description__c.length() > 119){
                                                system.debug('119,120 character------>>>'+ect.EC_Piece__r.Long_Description__c.substring(119,120));
                                                if(ect.EC_Piece__r.Long_Description__c.substring(119,120) == ' '){
                                                    sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,119);
                                                    sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119);
                                                    sendect.EC_Description4 = null;
                                                    sendect.EC_Description5 = null;
                                                }else{
                                                    sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,120);
                                                    sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120);
                                                    sendect.EC_Description4 = null;
                                                    sendect.EC_Description5 = null;
                                               }    
                                            }else if(ect.EC_Piece__r.Long_Description__c.length() == 119){
                                                sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,119);
                                                sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119);
                                                sendect.EC_Description4 = null;
                                                sendect.EC_Description5 = null;
                                            }
                                         }else{
                                              sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60);
                                              sendect.EC_Description3 = null;
                                              sendect.EC_Description4 = null;
                                              sendect.EC_Description5 = null;
                                         }    
                                     } 
                               }else if(ect.EC_Piece__r.Long_Description__c.length() <= 180){
                                        system.debug('Long_Description__c length 180 check---->>>'+ect.EC_Piece__r.Long_Description__c.length());
                                        if(ect.EC_Piece__r.Long_Description__c.substring(59,60) == ' '){
                                           sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c.substring(0,59);
                                             system.debug('118,119 for < 180 character------->>>'+ect.EC_Piece__r.Long_Description__c.substring(118,119));
                                            if(ect.EC_Piece__r.Long_Description__c.substring(118,119) == ' '){
                                              sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,118);
                                              if(ect.EC_Piece__r.Long_Description__c.length() >= 177){
                                                 if(ect.EC_Piece__r.Long_Description__c.length() > 177){
                                                     if(ect.EC_Piece__r.Long_Description__c.substring(177,178) == ' '){
                                                         sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118,177);
                                                         sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(177);
                                                         sendect.EC_Description5 = null;
                                                     }else{
                                                         sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118,178);
                                                         sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                         sendect.EC_Description5 = null;
                                                     }    
                                                 }else if(ect.EC_Piece__r.Long_Description__c.length() == 177){
                                                     sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118,177);
                                                     sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(177);
                                                     sendect.EC_Description5 = null;
                                                 }
                                              }else{
                                                  sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118);
                                                  sendect.EC_Description4 = null;
                                                  sendect.EC_Description5 = null;
                                              }        
                                          }else{
                                               sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,119);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 178){
                                                  if(ect.EC_Piece__r.Long_Description__c.length() > 178){
                                                      if(ect.EC_Piece__r.Long_Description__c.substring(178,179) == ' '){
                                                          sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,178);
                                                          sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                          sendect.EC_Description5 = null;
                                                      }else{
                                                          sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,179);
                                                          sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                          sendect.EC_Description5 = null;
                                                      }    
                                                  }else if(ect.EC_Piece__r.Long_Description__c.length() == 178){
                                                      sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,178);
                                                      sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                      sendect.EC_Description5 = null;
                                                  }  
                                               }else{
                                                   sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119);
                                                   sendect.EC_Description4 = null;
                                                   sendect.EC_Description5 = null;
                                               }     
                                          }
                                       }else{
                                            sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c.substring(0,60);
                                            if(ect.EC_Piece__r.Long_Description__c.substring(119,120) == ' '){
                                                sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,119);
                                                if(ect.EC_Piece__r.Long_Description__c.length() >= 178){
                                                    if(ect.EC_Piece__r.Long_Description__c.length() > 178){
                                                        if(ect.EC_Piece__r.Long_Description__c.substring(178,179) == ' '){
                                                             sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,178);
                                                             sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                             sendect.EC_Description5 = null;
                                                        }else{
                                                             sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,179);
                                                             sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                             sendect.EC_Description5 = null;
                                                        }     
                                                    }else if(ect.EC_Piece__r.Long_Description__c.length() == 178){
                                                         sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,178);
                                                         sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                         sendect.EC_Description5 = null;
                                                    } 
                                                }else{
                                                    sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119);
                                                    sendect.EC_Description4 = null;
                                                    sendect.EC_Description5 = null;
                                                }       
                                           }else{
                                                 sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,120);
                                                 if(ect.EC_Piece__r.Long_Description__c.length() >= 179){
                                                     if(ect.EC_Piece__r.Long_Description__c.length() > 179){
                                                        if(ect.EC_Piece__r.Long_Description__c.substring(179,180) == ' '){
                                                            sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120,179);
                                                            sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                            sendect.EC_Description5 = null;
                                                        }else{
                                                            sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120,180);
                                                            sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(180);
                                                            sendect.EC_Description5 = null;
                                                        }    
                                                    }else if(ect.EC_Piece__r.Long_Description__c.length() == 179){
                                                        sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120,179);
                                                        sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                        sendect.EC_Description5 = null;
                                                    } 
                                                } else{
                                                  sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120);
                                                  sendect.EC_Description4 = null;
                                                  sendect.EC_Description5 = null;
                                               }     
                                          }
                                   } 
                                }else {
                                  system.debug('Long_Description__c length > 180 check---->>>'+ect.EC_Piece__r.Long_Description__c.length());
                                  if(ect.EC_Piece__r.Long_Description__c.substring(59,60) == ' '){
                                       sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c.substring(0,59);
                                       if(ect.EC_Piece__r.Long_Description__c.substring(118,119) == ' '){
                                           sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,118);
                                           if(ect.EC_Piece__r.Long_Description__c.substring(177,178) == ' '){
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118,177);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 236){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 236){
                                                       if(ect.EC_Piece__r.Long_Description__c.substring(236,237) == ' '){
                                                            sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(177,236);
                                                            sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(236);
                                                       }else{
                                                            sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(177,237);
                                                            sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                       }     
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 236){
                                                        sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(177,236);
                                                        sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(236);
                                                   }
                                                }else{
                                                  sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(177);
                                                  sendect.EC_Description5 = null;
                                                }       
                                           }else{
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(118,178);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 237){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 237){
                                                       if(ect.EC_Piece__r.Long_Description__c.substring(237,238) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,237);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                       }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,238);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                       }    
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 237){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,237);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                   }
                                               }else{
                                                  sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                  sendect.EC_Description5 = null;
                                               }    
                                           }    
                                       }else{
                                           sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(59,119);
                                           if(ect.EC_Piece__r.Long_Description__c.substring(178,179) == ' '){
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,178);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 237){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 237){
                                                       if(ect.EC_Piece__r.Long_Description__c.substring(237,238) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,237);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                       }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,238);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                       } 
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 237){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,237);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                   }
                                                }else{
                                                  sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                  sendect.EC_Description5 = null;
                                               }     
                                           }else{
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,179);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 238){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 238){
                                                       if(ect.EC_Piece__r.Long_Description__c.substring(238,239) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,238);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                       }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,239);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(239);
                                                       }    
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 238){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,238);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                   }
                                               }else{
                                                  sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                  sendect.EC_Description5 = null;
                                               }      
                                           }    
                                       }
                                   }else{
                                       sendect.EC_Description1 = ect.EC_Piece__r.Long_Description__c.substring(0,60);
                                       if(ect.EC_Piece__r.Long_Description__c.substring(119,120) == ' '){
                                           sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,119);
                                           if(ect.EC_Piece__r.Long_Description__c.substring(178,179) == ' '){
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,178);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 237){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 237){
                                                       if(ect.EC_Piece__r.Long_Description__c.substring(237,238) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,237);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                       }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,238);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                       }
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 237){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178,237);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(237);
                                                   }
                                                }else{
                                                 sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(178);
                                                 sendect.EC_Description5 = null;
                                               }   
                                           }else{
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(119,179);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 238){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 238){
                                                       if(ect.EC_Piece__r.Long_Description__c.substring(238,239) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,238);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                       }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,239);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(239);
                                                       }
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 238){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,238);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                   }
                                               }else{
                                                sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                sendect.EC_Description5 = null;
                                               }    
                                           }    
                                       }else{
                                           sendect.EC_Description2 = ect.EC_Piece__r.Long_Description__c.substring(60,120);
                                           if(ect.EC_Piece__r.Long_Description__c.substring(179,180) == ' '){
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120,179);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 238){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 238){
                                                        if(ect.EC_Piece__r.Long_Description__c.substring(238,239) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,238);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                        }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,239);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(239);
                                                       }   
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 238){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179,238);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(238);
                                                   }
                                                }else{
                                                  sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(179);
                                                  sendect.EC_Description5 = null;
                                                }    
                                           }else{
                                               sendect.EC_Description3 = ect.EC_Piece__r.Long_Description__c.substring(120,180);
                                               if(ect.EC_Piece__r.Long_Description__c.length() >= 239){
                                                   if(ect.EC_Piece__r.Long_Description__c.length() > 239){
                                                        if(ect.EC_Piece__r.Long_Description__c.substring(239,240) == ' '){
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(180,239);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(239);
                                                        }else{
                                                           sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(180,240);
                                                           sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(240);
                                                       }   
                                                   }else if(ect.EC_Piece__r.Long_Description__c.length() == 239){
                                                       sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(180,239);
                                                       sendect.EC_Description5 = ect.EC_Piece__r.Long_Description__c.substring(239);
                                                   }
                                               }else{
                                                 sendect.EC_Description4 = ect.EC_Piece__r.Long_Description__c.substring(180);
                                                 sendect.EC_Description5 = null;
                                               }    
                                           } 
                                       }
                                   } 
                                } 
                                system.debug('sendect.EC_Description1---------------->>>'+sendect.EC_Description1);
                                system.debug('sendect.EC_Description2---------------->>>'+sendect.EC_Description2);
                                system.debug('sendect.EC_Description3---------------->>>'+sendect.EC_Description3);
                                system.debug('sendect.EC_Description4---------------->>>'+sendect.EC_Description4);
                                system.debug('sendect.EC_Description5---------------->>>'+sendect.EC_Description5);
                               //EC Description Calculation ends
                              
                                sendect.Image_Number = ect.EC_Piece__r.Image_Number__c;
                                sendect.EC_Type = ect.EC_Piece__r.EC_Type__c;
                                sendect.Aud_Indicator = ect.EC_Piece__r.Aud_Ind__c;
                                sendect.Deliverable_Format = ect.EC_Piece__r.Dlvbl__c;
                                sendect.Runtime_Min = ect.EC_Piece__r.Min__c;
                                sendect.Runtime_Sec = ect.EC_Piece__r.Sec__c;
                                sendect.EC_Menu_Icon = ect.EC_Piece__r.EC_Menu_Icon__c;
                                sendect.Aspect_Ratio = ect.EC_Piece__r.Asp_Ratio__c;
                                sendect.Resolution = ect.EC_Piece__r.Res__c;
                                sendect.EC_Audio_Format = ect.EC_Piece__r.Audio_Format__c;
                                sendect.Audio_Language_Type = ect.EC_Piece__r.Audio_Language_Type__c;
                                sendect.Language = ect.EC_Piece__r.Lang__c;
                                sendect.Usage = ect.EC_Piece__r.Usage__c;
                                if(ect.EC_Piece__r.Delivery_Date__c != null){
                                    String month;
                                    if(ect.EC_Piece__r.Delivery_Date__c.month() < 10){
                                       month = '0' + string.valueof(ect.EC_Piece__r.Delivery_Date__c.month());
                                    }else{
                                       month = string.valueof(ect.EC_Piece__r.Delivery_Date__c.month());
                                    }
                                    system.debug('month---------------->>>'+month);
                                    String days;
                                    if(ect.EC_Piece__r.Delivery_Date__c.day() < 10){
                                       days = '0' + string.valueof(ect.EC_Piece__r.Delivery_Date__c.day());
                                    }else{
                                       days = string.valueof(ect.EC_Piece__r.Delivery_Date__c.day());
                                    }
                                    system.debug('days---------------->>>'+days);
                                    sendect.Delivery_Date = month + '/' + days + '/' + ect.EC_Piece__r.Delivery_Date__c.year();
                                }else{
                                    sendect.Delivery_Date = null;
                                }
                                system.debug('Delivery Date------>>>'+sendect.Delivery_Date);    
                                for(Contact_Assignment__c ca:contactAssignmentsList){
                                  sendect.Vendor = ca.Account__r.Name;
                                }
                                system.debug('sendect---------------->>>'+sendect);
                                replyAllocation.add(sendect);
                        }
                        // Log all records to transaction table
                        Transaction_Log__c TLog = new Transaction_log__c();
                        TLog = createTransactionLog (vvd.Video_Version, true,'RetrievePhysicalAllocations', 'RetriveAllocation', vvd);  
                        system.debug('TLog---------------->>>'+TLog);
                        listOfTransactions.add(TLog);
                  }else{
                      // Log all records to transaction table                    
                      Transaction_Log__c TLog1 = new Transaction_log__c();
                      TLog1 = createTransactionLog (vvd.Video_Version, false,'RetrievePhysicalAllocations', 'RetriveAllocation', vvd);  
                      listOfTransactions.add(TLog1);
                      Error_Log__c ErrLog1 = new Error_log__c();
                      ErrLog1 = createErrorLog(vvd.Video_Version,'RetrievePhysicalAllocations', 'RetriveAllocation', 'Video Version Not Available', vvd);
                      listOfErrors.add(ErrLog1);
                  }
                }else{
                  // Log all records to transaction table
                  Transaction_Log__c TLog2 = new Transaction_log__c();
                  TLog2 = createTransactionLog (vvd.Video_Version, false, 'RetrievePhysicalAllocations','RetriveAllocation', vvd);  
                  listOfTransactions.add(TLog2);
                  Error_Log__c ErrLog2 = new Error_log__c();
                  ErrLog2 = createErrorLog(vvd.Video_Version,'RetrievePhysicalAllocations', 'RetriveAllocation', 'Input Inconsistent', vvd);
                  listOfErrors.add(ErrLog2);
               }
           }
       } else{
          // Log all records to transaction table
          Transaction_Log__c TLog3 = new Transaction_log__c();
          TLog3 = createTransactionLog (VVInfo[0].Video_Version, false, 'RetrievePhysicalAllocations', 'RetriveAllocation', VVInfo[0]);  
          listOfTransactions.add(TLog3);
          Error_Log__c ErrLog3 = new Error_log__c();
          ErrLog3 = createErrorLog(VVInfo[0].Video_Version,'RetrievePhysicalAllocations', 'RetriveAllocation', 'Input Inconsistent', VVInfo[0]);
          listOfErrors.add(ErrLog3);
       }
       
       //Check if there are any records are sent to PLM or send a blank record
       if(!(replyAllocation.size()>0)){
            ResponseMessage sendblank = new ResponseMessage();
            for(VideoversionDetails vvdb:VVInfo){
                sendblank.Video_Version = vvdb.Video_Version; 
            }                 
            sendblank.ECTechnical_Id = null;
            sendblank.PLMId = null;
            sendblank.EC_Name1 = null;
            sendblank.EC_Name2 = null;
            sendblank.EC_Name3 = null;
            sendblank.EC_Description1 = null;
            sendblank.EC_Description2 = null;
            sendblank.EC_Description3 = null;
            sendblank.EC_Description4 = null;
            sendblank.EC_Description5 = null;
            sendblank.Image_Number = null;
            sendblank.EC_Type = null;
            sendblank.Aud_Indicator = null;
            sendblank.Deliverable_Format = null;
            sendblank.Runtime_Min = null;
            sendblank.Runtime_Sec = null;
            sendblank.EC_Menu_Icon = null;
            sendblank.Aspect_Ratio = null;
            sendblank.Resolution = null;
            sendblank.EC_Audio_Format = null;
            sendblank.Audio_Language_Type = null;
            sendblank.Language = null;
            sendblank.Usage = null;
            sendblank.Delivery_Date = null;
            sendblank.Vendor = null;
           
            replyAllocation.add(sendblank);
       }
       system.debug('replyAllocation---------------->>>'+replyAllocation);
       system.debug('listOfErrors---------------->>>'+listOfErrors);
       system.debug('listOfTransactions---------------->>>'+listOfTransactions);
       insert listOfTransactions;
       insert listOfErrors;
       return replyAllocation;
     }
     
    
    /**************************************************************************
     * Method Name:     createTransactionLog
     * Description:     Create a log record as a copy of the transaction 
     *                  received for tracking and historical purposes - should 
     *                  be set up to archive eventually
     * Parameters:      IDOC, Success/Failure Values, Related Record if Error,
     *                  Method Invoked, Record being logged Title 
     * Return Values:   void
     **************************************************************************/
    private static Transaction_Log__c createTransactionLog (String idoc, Boolean isSuccess, String Itface, String methodName, VideoversionDetails VVInfo)
    {
     // Create new Transaction Log record for insert / return
        Transaction_Log__c Log = new Transaction_Log__c (IDOC__c = idoc, Invoked_Method__c = methodName, Interface__c = Itface);
        
        // Set status value
        if (isSuccess)
        {
            Log.Status__c = 'Success';
        }
        else
        {
            Log.Status__c = 'Failure';
        }
        // Set String value
        if (VVInfo != null)
        {
            Log.Input_Message__c = VVInfo.toString();
        }

        // Return Transaction Log record created
        return Log;
    }
      /**************************************************************************
     * Method Name:     createErrorLog
     * Description:     Create a log record as a copy of the transaction 
     *                  received for those records that failed - should 
     *                  be set up to archive eventually
     * Parameters:      IDOC, Method Invoked, Error Message, Record that failed
     *                  Title 
     * Return Values:   An Error Log record
     **************************************************************************/
    private static Error_Log__c createErrorLog (String idoc, String Itface, String methodName, String errMessage, VideoversionDetails VVInfo)
    {
     // Create new Transaction Log record for insert / return
        Error_Log__c Log = new Error_Log__c (IDOC__c = idoc,Interface__c = Itface, Invoked_Method__c = methodName, Error_Message__c = errMessage);
            
        // Set String value
        if (VVInfo != null)
        {
            Log.Input_Message__c = VVInfo.toString(); //VVInfo;
        }

        // Return Transaction Log record created
        return Log;
    }
}