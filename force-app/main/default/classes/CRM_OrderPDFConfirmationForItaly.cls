public class CRM_OrderPDFConfirmationForItaly {
    // Required extension constructor
    public CRM_OrderPDFConfirmationForItaly(ApexPages.StandardController controller) {    
        String ordId = ApexPages.currentPage().getParameters().get('id');
        String ordNumber;
        
        if(ordId != null) {
            ordNumber = [select OrderNumber from Order where Id =:ordId][0].OrderNumber;
        }
        String fileName = 'Order '+ordNumber+ ' Confirmation'+'.pdf';
        ApexPages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
    }   
}