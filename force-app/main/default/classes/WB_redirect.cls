public class WB_redirect {

    public WB_redirect(ApexPages.StandardController controller) {

    }

    public PageReference redirectUser(){
        PageReference ref = new PageReference('/apex/WB_TitleSearchVVR');
        ref.setRedirect(true);
        return ref;
    }
}