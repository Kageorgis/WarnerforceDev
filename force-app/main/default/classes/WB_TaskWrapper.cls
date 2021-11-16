/**
*  Description    :   Wrapper class used to save task,Language Name, Video Version number, due date, color code (if date is passed then apply red).
*                     Class used to sort the list as per selected sort option.
   Author         :   Prachi Gadewar
   Emp ID         :   489635
*  Date           :   11 – Sep- 2015
*  
*  =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                   Date                           Comment
*  Prachi Gadewar           23/10/2015                     CH01: Added logic to add only 30 charecters in titlename variable.            
*  
*/

global class WB_TaskWrapper implements Comparable {

    public Task taskInstnace{get; set;}
    public String LanguageName{get; set;}
    public String LangType;
    public Boolean isSelected{get; set;}
    public String colorCode{get; set;}    
    public String AvailLangName;
    public Long videoVersionNumber{get; set;}
    public DateTime dueDate;
    public String TitleName{get; set;}
    public Available_Languages__c availLang{get; set;}
    
    public enum SORT_BY {
        LanguageName,videoVersionNumber,DueDate,TitleName
        }

    //Variable to decide the member on which sorting should be performed
    public static SORT_BY sortBy;
    
    public WB_TaskWrapper(String sortType)
    {
        if(sortType == 'LanguageName')
            sortBy = SORT_BY.LanguageName;
        else if(sortType == 'videoVersionNumber')
            sortBy = SORT_BY.videoVersionNumber;
        else if(sortType == 'TitleName')
            sortBy = SORT_BY.TitleName;
    }
    
    public WB_TaskWrapper(Task currentTask,String taskLanguageName, Available_Languages__c avaiLangRecord)
    {
        taskInstnace = currentTask;
        if(currentTask.ActivityDate <= system.today())
            colorCode='#900';
        else
            colorCode='#FFFFFFF';
        dueDate = currentTask.ActivityDate;
        availLang=avaiLangRecord;
        videoVersionNumber = Decimal.valueOf(avaiLangRecord.Title__r.Video_Version__c).longValue();
        LanguageName = avaiLangRecord.Language__r.Name;
        AvailLangName = avaiLangRecord.Name;
        LangType = avaiLangRecord.Language_Types__c;
        // CH01: start
        if(avaiLangRecord.Title__r.Name.length() > 30)
        {
            TitleName = avaiLangRecord.Title__r.Name.substring(0, 27);
            TitleName += '..';
        }
        else 
            TitleName = avaiLangRecord.Title__r.Name;
        // CH01: end
        isSelected = false;
    }

    global Integer compareTo(Object objToCompare) {
        if(sortBy == SORT_BY.LanguageName)
        {
            return LanguageName.compareTo(((WB_TaskWrapper)objToCompare).LanguageName);
        }
        else if(sortBy == SORT_BY.videoVersionNumber)
        {
            Long vvNumber = Decimal.valueof(((WB_TaskWrapper)objToCompare).videoVersionNumber).longValue();
            return Integer.valueOf(videoVersionNumber- vvNumber);
        }
        else if(sortBy == SORT_BY.TitleName)
        {
            return TitleName.compareTo(((WB_TaskWrapper)objToCompare).TitleName);
        }
        return null;
    }
}