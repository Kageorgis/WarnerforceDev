/******* 
WB_GenericAllocationController
Creation Date- 17 Apr 2015
Description- This class is to Allocate Video Versions from Generic MPMs to the current MPMs EC Piece
Author- Harika Bondalapati
*******/
public with sharing class WB_GenericAllocationController{
    public EC_Title_Allocation__c ecta {get; set;}
    public Id VVId {get;set;}    
    Public Set<string> leftvalues {get;set;}
    Public Set<string> rightvalues {get;set;}
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    public List<string> rightList{get;set;}
    public String mpmNames{get;set;}  
    public String MPMId;
    public Integer mSize {get;set;}
    public List<EC_Piece__c> EcpieceList = new List<EC_Piece__c>();
    public Map<String,EC_Piece__c> EcpieceMap {get;set;}

    public WB_GenericAllocationController(ApexPages.StandardController stdController){
        this.ecta = (EC_Title_Allocation__c)stdController.getRecord();
        MPMId = ApexPages.currentPage().getParameters().get('mpmid');
        leftvalues = new Set<string>();
        rightvalues = new Set<string>();
        EcpieceMap = new Map<String,EC_Piece__c>();
        List<MPM__c> mpmList = [select Name from MPM__c where Id=:MPMId limit 1];
        for(MPM__c m:mpmList){
            mpmNames = m.Name;
        }
        system.debug('mpmNames--------------->>>>>'+mpmNames);
        EcpieceList = [select Name,EC_Name__c,Id,MPM__c from EC_Piece__c where MPM__c=:MPMId order by Name];
        for(EC_Piece__c ec:EcpieceList){
            
            EcpieceMap.put(ec.Name + '-' + ec.EC_Name__c,ec);
        } 
       
        if(leftvalues.size()>6){
            mSize = leftvalues.size();
        }else{
            mSize = 6;
        }    
        system.debug('mSize----------------->>>>>>'+mSize);
           
        leftselected = new List<String>();
        rightselected = new List<String>();      
    }
    public PageReference Save(){
        List<EC_Title_Allocation__c> insertECT = new List<EC_Title_Allocation__c>();
        List<EC_Title_Allocation__c> deleteECT = new List<EC_Title_Allocation__c>();
        Id vvnumber2 = ecta.title__c;
        rightList = new List<String>();
        rightList.addAll(rightvalues);
        system.debug('rightList------------>>>>>>>>>>>>'+rightList);
        List<EC_Title_Allocation__c> ectaList3 = [select MPM__c,Title__c,EC_Piece__c,
                                                      checkedbox__c,EC_Piece__r.Name,EC_Piece__r.EC_Name__c from EC_Title_Allocation__c
                                                      where MPM__c=:MPMId AND Title__c =: vvnumber2 order by EC_Piece__r.Name];
        List<EC_Title_Allocation__c> ectaList2  =  ectaList3;                                           
        for(String rt:rightList){
            EC_Title_Allocation__c ectnew = new EC_Title_Allocation__c ();
                ectnew.EC_Piece__c = EcpieceMap.get(rt).Id;
                ectnew.MPM__c = MPMId;
                ectnew.Title__c = vvnumber2;
            Boolean recexists = false;
            
            for(EC_Title_Allocation__c ect2:ectaList3){
                if((ect2.EC_Piece__r.Name + '-' + ect2.EC_Piece__r.EC_Name__c) == rt){
                    recexists = true;
                }      
            }
            if(recexists == false){
               insertECT.add(ectnew);
            }
       }
        
       for(String lt:leftvalues){
           EC_Title_Allocation__c ectdel = new EC_Title_Allocation__c ();
               ectdel.EC_Piece__c = EcpieceMap.get(lt).Id;
               ectdel.MPM__c = MPMId;
               ectdel.Title__c = vvnumber2;
              
           for(EC_Title_Allocation__c ect3:ectaList2){
               if(lt == (ect3.EC_Piece__r.Name + '-' + ect3.EC_Piece__r.EC_Name__c)){
                  ectdel.Id = ect3.Id;
                  deleteECT.add(ectdel);
                }
            }    
        }
        
        Database.insert(insertECT);
        Database.delete(deleteECT);
        PageReference sav= new PageReference('/'+MPMId);
        return sav;
    }
    
    public PageReference Next(){
        system.debug('ecta.title__c------------>>>'+ecta.title__c);
        Id vvnumber = ecta.title__c;
        system.debug('vvnumber----------------->>>>>>'+vvnumber);
        leftvalues.clear();
        rightvalues.clear();
        system.debug('leftvalues----------------->>>>>>'+leftvalues);
        system.debug('rightvalues----------------->>>>>>'+rightvalues);
        List<Id> ecIds = new List<Id>();
        List<EC_Piece__c> ecsList = [select Name,EC_Name__c,Id,MPM__c from EC_Piece__c where MPM__c=:MPMId order by Name];
        for(EC_Piece__c ec3:ecsList){
          ecIds.add(ec3.Id);
        }
        List<EC_Title_Allocation__c> ectaList = [select MPM__c,Title__c,EC_Piece__c,
                                                        checkedbox__c from EC_Title_Allocation__c where MPM__c=:MPMId 
                                                        AND EC_Piece__c IN:ecIds AND Title__c =: vvnumber 
                                                        order by EC_Piece__r.Name];
        system.debug('size------>>>'+ectaList.size());
        for(EC_Piece__c ec2:ecsList){
            Boolean RecordExist = false;
            
            for(EC_Title_Allocation__c ect:ectaList){
                if(ec2.Id == ect.EC_Piece__c){
                    RecordExist = true;
                }
            }
            if(RecordExist == false){
                leftvalues.add(ec2.Name + '-' + ec2.EC_Name__c);
            }
            if(RecordExist == true){
                rightvalues.add(ec2.Name + '-' + ec2.EC_Name__c);
            }
        } 
        system.debug('leftvalues----------------->>>>>>'+leftvalues);
        system.debug('rightvalues----------------->>>>>>'+rightvalues); 
        mSize = leftvalues.size();
        return null;
    }

    public PageReference Cancel(){
        PageReference cancl= new PageReference('/'+MPMId);
        return cancl;
    }
    
    //mulstiselect code
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
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