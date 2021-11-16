public with sharing class CRM_ExportCSVFileFromUploadExtractCtrl {
    public List<String> excelHeaderNames{ get; set;}
    public string userLanguage{get; set;}
    public final string XMLHeader{get; set;}

    public CRM_ExportCSVFileFromUploadExtractCtrl(){
        this.excelHeaderNames = ApexPages.currentPage().getParameters().get('excelHeaderNames').split(',');
        userLanguage = UserInfo.getLanguage();
        XMLHeader = '<?xml version="1.0" encoding="UTF-8"?><?mso-application progid="Excel.Sheet"?>';
    }
    
    public PageReference exportToExcel() {
        return null;
    }

}