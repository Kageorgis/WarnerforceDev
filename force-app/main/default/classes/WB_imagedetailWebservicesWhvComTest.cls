@IsTest

private with sharing class WB_imagedetailWebservicesWhvComTest
{
    private static testMethod void coverTypes()
    {
        new WB_imagedetailWebservicesWhvCom.getAssetURLResponse();
        new WB_imagedetailWebservicesWhvCom.assetMetaData();
        new WB_imagedetailWebservicesWhvCom.assetURLResponse();
        new WB_imagedetailWebservicesWhvCom.getAssetURL();
        new WB_imagedetailWebservicesWhvCom.assetDwndURLPort();
    }
    
    private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof WB_imagedetailWebservicesWhvCom.getAssetURL)
                response.put('response_x', new WB_imagedetailWebservicesWhvCom.getAssetURLResponse());
            return;
        }
    }
    
    
}