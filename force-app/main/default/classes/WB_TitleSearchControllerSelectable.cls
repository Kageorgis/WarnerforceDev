public with sharing class WB_TitleSearchControllerSelectable {    
    private integer counter=0;  //keeps track of the offset
    private integer list_size=50; //sets the page size or number of rows
    public integer total_size=0; //used to show user the total size of the list
    public List<cTitle> cTitles {get;set;}
    private boolean showbutton {get;set;}
    public String ids {get;set;}
    public List<Title__c> titles {get;set;}
    private String soql {get;set;}
    private String soqlCount {get;set;}
    
    public WB_TitleSearchControllerSelectable() {
    }

    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    
    public String getDigPicklist() {
        return null;
    }
    
    public String getPhyPicklist() {
        return null;
    }
    
    public String sortField {
        get  { if (sortField == null) {sortField = 'Name'; } return sortField;  }
        set;
    }

    public PageReference createRP() {
        if (cTitles!=null) {
              for (cTitle ct: cTitles) {
                  if (ct.selected) {
                      showbutton=true;
                      String newid = ct.tit.id;
                      ids=ids+newid+',';
                  }
              }
        }
        if (ids.length()>0) {
            PageReference ref = new PageReference('/apex/WB_Create_CommercialAvail?ID='+ids+'&param=search');
            return ref;
        }    
        else  return null;          
    }
    
    public class cTitle {
        public Title__c tit {get; set;}
        public Boolean selected {get; set;}   
        
        public cTitle(Title__c t) {
            tit = t;
            selected = false;
        }
    }
    
    public void runQuery() {    
        try {
            ids='';
            cTitles=null;
            showbutton=false;
            
            if (cTitles == null) {
                cTitles = new List<cTitle>();
                system.debug('soql in runquery --> ' + soql );
                system.debug('list_size  ' + list_size );                   
                
                    titles = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit ' + list_size + ' offset ' + counter); 
                   // titles = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 10 '  + ' offset ' + counter);     
               
                for (Title__c t: titles) {
                    cTitles.add(new cTitle(t));
                }
                if(titles.size()==0){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' No Result Found !!'));  
                }
            }
        
        } catch (Exception e) {
            system.debug('in exception');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Result Found......'));
        }
        //total_size = cTitles.size();
    }
    public void toggleSort() {
        // simply toggle the direction
        //sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        //runQuery();
    }
    public PageReference runSearch() {
        //RenderPageBlock=true;
        counter=0;
        if(cTitles!=null){
            cTitles.clear();
            cTitles=null;

        }
        if(titles!=null){
            titles.clear();
            titles=null;
        }
        String actualtitle = Apexpages.currentPage().getParameters().get('title').trim();
        String actualmpm = Apexpages.currentPage().getParameters().get('mpm').trim();
        String actualseason = Apexpages.currentPage().getParameters().get('season').trim();
        String digitalPlanning = Apexpages.currentPage().getParameters().get('digitalPlanning');
        String physicalPlanning = Apexpages.currentPage().getParameters().get('physicalPlanning');
        String actualvideoVersion= Apexpages.currentPage().getParameters().get('vv').trim();
        String actualstudio= Apexpages.currentPage().getParameters().get('studio').trim();
        
        String mpm=actualmpm.replace('*','%');
        String season=actualseason.replace('*','%');
        String videoVersion=actualvideoVersion.replace('*','%');
        String studio=actualstudio.replace('*','%');
        
        String title = actualtitle.toLowerCase();
        title = title.replace('*','%');
        
        String[] andTitleKeywords = title.split(' and ',0);
        
        soqlCount='select count() from Title__c where name != null ';
        /*ER-007018-soql = 'select id, name, MPM__r.Name, MPM__r.id, Season__c, Digital_Planning__c, Physical_Planning__c,Video_Version__c from Title__c where name != null';*/
        soql = 'select id, name, MPM__r.Name, MPM__r.id, Season__c, Digital_Planning__c, Physical_Planning__c,Video_Version__c,Studio__c  from Title__c where name != null';
        if (!title.equals(''))
        {
            for(String tk : andTitleKeywords)
            {
                tk = tk.trim();
                String[] orTitleKeywords = tk.split(' or ',0);
                if(orTitleKeywords.size() > 1)
                {
                    Integer size = orTitleKeywords.size();
                    soql += ' and (';
                    soqlCount += ' and (';
                    for(integer i=0; i < size-1; i++)
                    {
                        soql += ' name LIKE \''+String.escapeSingleQuotes(orTitleKeywords[i])+'\' OR ';
                        soqlCount += ' name LIKE \''+String.escapeSingleQuotes(orTitleKeywords[i])+'\' OR ';
                    }
                    soql += ' name LIKE \''+String.escapeSingleQuotes(orTitleKeywords[size-1])+'\' ) ';
                    soqlCount += ' name LIKE \''+String.escapeSingleQuotes(orTitleKeywords[size-1])+'\' ) ';
                }
                else
                {
                    soql += ' and name LIKE \''+String.escapeSingleQuotes(tk)+'\'';
                    soqlCount += ' and name LIKE \''+String.escapeSingleQuotes(tk)+'\'';
                }
            }
        }

        /*if (!title.equals(''))
        {
            soql += ' and name LIKE \''+String.escapeSingleQuotes(title)+'\'';
            soqlCount += ' and name LIKE \''+String.escapeSingleQuotes(title)+'\'';
        }
        */
        /*if (!title.equals('') && searchTypeAND == 'true')
        {
            for(String tk : titleKeywords)
            {
                soql += ' and name LIKE \'%'+String.escapeSingleQuotes(tk)+'%\'';
                soqlCount += ' and name LIKE \'%'+String.escapeSingleQuotes(tk)+'%\'';
            }
        }
        else if (!title.equals('') && searchTypeAND == 'false')
        {
            Integer size = titleKeywords.size();
            soql += ' and (';
            soqlCount += ' and (';
            for(integer i=0; i < size-1; i++)
            {
                soql += ' name LIKE \'%'+String.escapeSingleQuotes(titleKeywords[i])+'%\' OR ';
                soqlCount += ' name LIKE \'%'+String.escapeSingleQuotes(titleKeywords[i])+'%\' OR ';
            }
            soql += ' name LIKE \'%'+String.escapeSingleQuotes(titleKeywords[size-1])+'%\' ) ';
            soqlCount += ' name LIKE \'%'+String.escapeSingleQuotes(titleKeywords[size-1])+'%\' ) ';
        }
        */
        
        if (!mpm.equals('')){
            soql += ' and MPM__r.Name LIKE \''+String.escapeSingleQuotes(mpm)+'\'';
            soqlCount += ' and MPM__r.Name LIKE \''+String.escapeSingleQuotes(mpm)+'\'';
        }
        if (!season.equals('')){
            soql += ' and Season__c LIKE \''+String.escapeSingleQuotes(season)+'\''; 
            soqlCount += ' and Season__c LIKE \''+String.escapeSingleQuotes(season)+'\''; 
        }       
        if (!digitalPlanning.equals('')){
            soql += ' and Digital_Planning__c LIKE  \'%'+String.escapeSingleQuotes(digitalPlanning)+'%\'';
            soqlCount += ' and Digital_Planning__c LIKE  \'%'+String.escapeSingleQuotes(digitalPlanning)+'%\'';
        }
        if (!physicalPlanning.equals('')){
            soql += ' and Physical_Planning__c LIKE  \'%'+String.escapeSingleQuotes(physicalPlanning)+'%\'';
            soqlCount += ' and Physical_Planning__c LIKE  \'%'+String.escapeSingleQuotes(physicalPlanning)+'%\'';
        }
       /*ER-007018*/if (!studio.equals('')){
            soql += ' and studio__c LIKE  \'%'+String.escapeSingleQuotes(studio)+'%\'';
            soqlCount += ' and studio__c LIKE  \'%'+String.escapeSingleQuotes(studio)+'%\'';
        }
        if (!videoVersion.equals('')){
            soql += ' and video_version__c LIKE \''+String.escapeSingleQuotes(videoVersion)+'\'';
            soqlCount += ' and video_version__c LIKE \''+String.escapeSingleQuotes(videoVersion)+'\'';
            
        }
        
        if(actualtitle.equals('') && mpm.equals('') && season.equals('') && digitalPlanning.equals('') && physicalPlanning.equals('') && videoVersion.equals('')){
            soqlCount += ' limit 50000';
        }
          
       
        total_size=Database.countQuery(soqlCount);
        if(total_size >= 50000){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Too many search results found, kindly refine your search...'));
        }
        else{
        // run the query again
            runQuery();
        }
        
        //cTitles=null;
        
        return null;
    }
   // Pagination code
    
   public PageReference Beginning() { //user clicked beginning
      counter = 0;
      runQuery();
      return null;
   }
 
   public PageReference Previous() { //user clicked previous button
      counter -= list_size;
      runQuery();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      counter += list_size;
      runQuery();
      return null;
   }
 
   public PageReference End() { //user clicked end
      //total_size=cTitles.size(); 
      counter = total_size - math.mod(total_size, list_size);
      runQuery();
      return null;
   }
 
   public Boolean getDisablePrevious() {
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
       if (counter + list_size < total_size) return false; else return true;
      
   }
 
   public Integer getTotal_size() {
      return total_size;
   }
 
  /* public Integer getPageNumber() {
      return counter/list_size + 1;
   }
   
   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }*/
   // use apex describe to build the digital planning picklist values
  public List<String> DigPicklist {
    get {
      if (DigPicklist == null) {

        DigPicklist = new List<String>();
        Schema.DescribeFieldResult field = Title__c.Digital_Planning__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          DigPicklist.add(f.getLabel());

      }
      return DigPicklist;          
    }
    set;
  }
  
    // use apex describe to build the physical planning picklist values
  public List<String> PhyPicklist {
    get {
      if (PhyPicklist == null) {

        PhyPicklist = new List<String>();
        Schema.DescribeFieldResult field = Title__c.Digital_Planning__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          PhyPicklist.add(f.getLabel());

      }
      return PhyPicklist;          
    }
    set;
  }
    
  /*ER-007018- public List<String> studio{
    get {
      if (studio== null) {

        studio= new List<String>();
        / Schema.DescribeFieldResult field = Title__c.Studio__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          studio.add(f.getLabel());
      
      }
      return studio;          
    }
    set;
  }  -*/
}