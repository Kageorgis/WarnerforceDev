/******* 
WB_PhysicalAllocations
Creation Date- 21 Feb 2015
Description- This class is to allocate Video Version to Ecs
Author- Harika Bondalapati
*******/
public class WB_PhysicalAllocations{
    public final MPM__c mpm;
    public List<MPM__c> mpmList= new List<MPM__c>();
    public String mpmNames{get;set;}
    public String mpmIds;
    public Boolean showpicklist {get;set;}
    public Boolean showtable {get;set;}
    public List<EC_Piece__c> EcpieceList{get;set;}
    public List<EC_Title_Allocation__c> Ectitles {get;set;}
    public List<EC_Title_Allocation__c> Ectitles2 {get;set;}
    public List<Title__c> TitlesecondList{get;set;}
    public transient List<String> EcNameList{get;set;}
    public List<Title__c> TitleList {get;set;}
    public Boolean cheks {get;set;}
    public Integer vvSize{get;set;}
    Public Set<string> leftvalues = new Set<string>();
    Public Set<string> rightvalues = new Set<string>();
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    public List<string> rightList{get;set;}

    public WB_PhysicalAllocations(ApexPages.StandardController stdController) {
       
       this.mpm= (MPM__c)stdController.getRecord();
       mpmIds = mpm.Id;
       mpmList = [select Name from MPM__c where Id=:mpmIds limit 1];
       for(MPM__c m:mpmList){
           mpmNames = m.Name;
       }
       
       showpicklist = true;
       showtable = false;
       
       Ectitles = new List<EC_Title_Allocation__c>();
       Ectitles2 = new List<EC_Title_Allocation__c>();
       EcpieceList = new List<EC_Piece__c>();
       TitlesecondList = new List<Title__c>();
       TitleList = [select Name,Id,MPM__c,Video_Version__c from Title__c where MPM__c=:mpmIds order by Video_Version__c];
       EcNameList = new List<String>();
       
       
       Ectitles = [select EC_Piece__c,MPM__c,Title__c,EC_Name__c,
                   Video_Version_Number__c,checkedbox__c,
                   EC_Piece__r.Name from EC_Title_Allocation__c
                   where MPM__c=:mpmIds order by EC_Piece__r.Name,Video_Version_Number__c];
       
       for(Title__c tit:TitleList){
           leftvalues.add(tit.Video_Version__c + '-' + tit.Name);
       }
       if(leftvalues.size() > 6){
           vvSize = leftvalues.size();
       }else{
          vvSize  = 6;
       }
       leftselected = new List<String>();
       rightselected = new List<String>();
       
    }
    
    public PageReference updateAll(){
      Id vvnumber = Apexpages.currentPage().getParameters().get('q');
      Boolean Allchecks = false;
      system.debug('vvnumber------------------------>>>'+vvnumber);
   
      for(EC_Title_Allocation__c ect7:Ectitles2){
          if(ect7.Title__c == vvnumber){
             if(ect7.checkedbox__c == false && Allchecks == false){
                Allchecks = true;
             }  
          }
      }
    
      for(EC_Title_Allocation__c ect9:Ectitles2){
          if(ect9.Title__c == vvnumber && Allchecks == true){
             ect9.checkedbox__c = true;
          }else if(ect9.Title__c == vvnumber && Allchecks == false){
             ect9.checkedbox__c = false;
          }
      }
      return null;
    }
  
    public PageReference Saves(){
       List<EC_Title_Allocation__c> insertECT = new List<EC_Title_Allocation__c>();
       List<EC_Title_Allocation__c> deleteECT = new List<EC_Title_Allocation__c>();
       for(EC_Title_Allocation__c ect9:Ectitles2){
           if(ect9.Id == null && ect9.checkedbox__c == true){
              system.debug('ectitles-------->>>'+ect9);
              insertECT.add(ect9);
           }else if(ect9.Id != null && ect9.checkedbox__c == false){
              deleteECT.add(ect9);
           }  
       }  
       
       Database.insert(insertECT);
       Database.delete(deleteECT);
       
       PageReference Save1= new PageReference('/'+mpmIds);
       return Save1;
    }
  
    public PageReference Cancel(){
       PageReference cancl= new PageReference('/'+mpmIds);
       return cancl;
    }
  
    //---------------------------------------started the multi select picklist code 
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
    //--------------------------------End of Multi Select Picklist code
    public PageReference Next(){
       showpicklist = false;
       showtable = true;
       rightList = new List<String>();
       rightList.addAll(rightvalues);
       system.debug('rightList------------>>>>>>>>>>>>'+rightList);
       Ectitles2 = new List<EC_Title_Allocation__c>();
     
       EcpieceList = [select Name,EC_Name__c,Id,MPM__c from EC_Piece__c where MPM__c=:mpmIds order by Name];
       TitlesecondList = new List<Title__c>();
       if(rightList!=null && rightList.size()>0){
          for(Title__c tit2:TitleList){
              system.debug('tit2------------>>>>>>>>>>>>'+tit2);
              for(string vvsn:rightList){
                  system.debug('vvsn------------>>>>>>>>>>>>'+vvsn);
                  if(vvsn == (tit2.Video_Version__c + '-' + tit2.Name)){
                     TitlesecondList.add(tit2);
                  }
              }
          }               
       }
     
       //collect the checkboxes
       for(EC_Piece__c ec:EcpieceList){
           for(Title__c tit3:TitlesecondList){
               EC_Title_Allocation__c ect = new EC_Title_Allocation__c();
                   ect.EC_Piece__c = ec.Id;
                   ect.Title__c = tit3.Id;
                   ect.MPM__c = mpmIds;
                   Boolean recordcreate = true;    
               for(EC_Title_Allocation__c ect2:Ectitles){
                   if(ect2.Video_Version_Number__c == tit3.Video_Version__c && ect2.EC_Piece__c == ec.Id){
                      Ectitles2.add(ect2);
                      recordcreate = false;
                    }
                }
                if(recordcreate == true){
                   Ectitles2.add(ect);
                }            
            }
        } 
        return null;
    }
}