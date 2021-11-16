/*****************************************************************************
 * Class Name:      WB_Display_AnnouncementType_Controller
 * Description:     To display related list- 'Announcement type' on 'Account detail Page' with a 
                    checkbox option and custom button 'Generate Announcements' *
 * Author:          Date:           Description
 * Rashmi Singh     02/12/2015      First Draft
 *****************************************************************************/
public with sharing class WB_Display_AnnouncementType_Controller {
    public string selectedIds {get;set;}
    public Boolean shouldRedirect {public get; private set;}
    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirectShowMore {public get; private set;}
    public String redirectShowMoreUrl {public get; private set;}    
    boolean displayPagination{get;set;}
    list<announcementTypeWrapper> announcementTypesDisplayed{get;set;}
    string accId;
        
    public WB_Display_AnnouncementType_Controller(ApexPages.StandardController controller) {
        displayPagination=true;
        shouldRedirect = false;
        shouldRedirectShowMore=false;
        
    }
 public ApexPages.StandardSetController con {
        get { accId= ApexPages.currentPage().getParameters().get('ID');
            if(con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator([select Id,name,
                                                                                Selection_Criteria__c,Report_Format__c,
                                                                                Date_Last_Run__c,Announcement_Type__c,Report_Template__c
                                                                                from Announcement_Rule__c where Account__c =:accId order by name ]));
                // sets the number of records in each page set
                con.setPageSize(100);
                               
                
            }
            return con;
        }
        set;
    }
    public boolean getdisplayPagination(){
        if(con.getResultSize()>100){
            return true;
        } else return false;
    }
    public boolean getReDirect(){
        if(con.getResultSize()>10){
            return true;
        } else return false;
    }
   // returns a list of wrapper objects for the sObjects in the current page set
    public List<announcementTypeWrapper> getannouncementTypesDisplayed() {
        announcementTypesDisplayed = new List<announcementTypeWrapper>();
        for (announcement_Rule__c accouncementTypeRecord : (List<announcement_Rule__c>)con.getRecords())
            announcementTypesDisplayed.add(new announcementTypeWrapper(accouncementTypeRecord));

        return announcementTypesDisplayed;
    }
    public class announcementTypeWrapper {

    public Announcement_Rule__c announcementTypeRec{get;set;}
    public boolean isSelected{get;set;}

    public announcementTypeWrapper(){
        announcementTypeRec = new announcement_Rule__c();
        isSelected = false;
    }

    public announcementTypeWrapper(announcement_Rule__c c){
        announcementTypeRec = c;
        isSelected = false;
    }

    }
 // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
     public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
     }

     // returns the next page of records
     public void next() {
         con.next();
     }
    
 
    public pageReference deleteAnnouncementType(){      
        Id announcementTypeIdId = ApexPages.currentPage().getParameters().get('announcementTypeIdId');      
        try{
            Announcement_Rule__c deleteAnnouncementType= new Announcement_Rule__c (id=announcementTypeIdId);
            delete deleteAnnouncementType;
            pageReference pageRef= new Pagereference('/'+accId);            
            return pageRef;
        }catch(exception e){
            
        }
        return null;
    }
    public pageReference generateAnnouncements(){
         selectedIds='';        
        for(announcementTypeWrapper selectedAnnounceTypes:announcementTypesDisplayed ){ 
            
            if(selectedAnnounceTypes.isSelected==true){               
                String newid = selectedAnnounceTypes.announcementTypeRec.Id;
                selectedIds=selectedIds+newid+',';
            }
        }
        if(selectedIds.length()>0){
        shouldRedirect = true;          
        redirectUrl = System.Label.Redirect_Generate_Announcements + selectedIds;
        return null;
        }else return null;
    }
   public pageReference redirectToMoreAnnTypes(){
        shouldRedirectShowMore=true;
        redirectShowMoreUrl='/apex/WB_DispalyAllAnnouncemnetTypes?ID='+ accId;
        return null;    
       
   }
}