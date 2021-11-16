/*
   @Author Cognizant 
   @name WB_CreateCommercialAvail_Lightning.
   @CreateDate 23 Jan 2018
   @Description - Apex class for Manage Playlist button on Title
   @Version <1.0>
   @Requirement ER-1660
*/


public class WB_ManagePlaylistLightning {
     public Id id;
     public WB_ManagePlaylistLightning(ApexPages.StandardController controller) {
       id = controller.getRecord().Id;
     }
   
     public PageReference forwardIdToPage() {
        PageReference pr = Page.WB_ManagePlayListContent;
        pr.getParameters().put('id', id);
        return pr;
    }
}