global class WB_PromotionPivotMiniGrid {

    public WB_PromotionPivotMiniGrid(ApexPages.StandardController controller) {
    }

    @RemoteAction
    global static Map<String, String> getIdsByCriteria(String promotionId, List<String> fields, Integer pageSize) {
        String whereClause;
        if (promotionId == null || promotionId == '') {
            whereClause = 'CreatedDate = null';
        } else {
            Promotion__c pm = [select Channels__c, Formats__c from Promotion__c where Id = :promotionId];
            List<String> channels = null;
            if (pm.Channels__c != null && pm.Channels__c != '') {
                channels = pm.Channels__c.split(';');
                for (Integer i = 0; i < channels.size(); i++) {
                    channels[i] = '\'' + String.escapeSingleQuotes(channels[i]) + '\'';
                }
            }
            List<String> formats = null;
            if (pm.Formats__c != null && pm.Formats__c != '') {
                formats = pm.Formats__c.split(';');
                for (Integer i = 0; i < formats.size(); i++) {
                    formats[i] = '\'' + String.escapeSingleQuotes(formats[i]) + '\'';
                }
            }
            if (formats == null || formats.isEmpty() || channels == null || channels.isEmpty()) {
                whereClause = 'CreatedDate = null';
            } else {
                whereClause = 'Format__c in (' + String.join(formats, ',') + ') and Channel__c in (' + String.join(channels, ',') + ') and PromotionID__c = \'' + promotionId + '\'';
            }
        }
        
        if(!Test.isRunningTest())
            return PowerLoader.Configero_GridApp.getIdsBySQL('Promotion_Title__c', fields, whereClause, pageSize);
        return null;
        
    }
}