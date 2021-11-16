public class DealsWrapper {
    
    public class Table {
        @AuraEnabled public List<DealsWrapper.Column> references;
        @AuraEnabled public List<DealsWrapper.StudioUser> studioUsers;
        @AuraEnabled public List<DealsWrapper.Column> columns;
        @AuraEnabled public List<DealsWrapper.Filter> filters;
        @AuraEnabled public List<sObject> data;
        
        public Table() {
            references = new List<DealsWrapper.Column>();
            columns = new List<DealsWrapper.Column>();
            filters = new List<DealsWrapper.Filter>();
            data = new List<sObject>();
        }
    }
    
    public class View {
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public Boolean isRestricted;
        @AuraEnabled public Id viewId;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String child;
        
        public View() {
            isSelected = false;
            isRestricted = false;
            viewId = null;
            label = '';
            value = '';
            child = '';
        }
    }
    
    public class Column {
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public Boolean isRestricted;
        @AuraEnabled public Boolean isSortable;
        @AuraEnabled public Boolean isVisible;
        @AuraEnabled public Boolean isChild;
        @AuraEnabled public Id columnId;
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String originalFieldName;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public String fieldType;
        @AuraEnabled public Integer width;
        
        public Column() {
            isSelected = false;
            isRestricted = false;
            isSortable = true;
            isVisible = false;
            isChild = false;
            columnId = null;
            label = '';
            apiName = '';
            fieldName = '';
            originalFieldName = '';
            objectLabel = '';
            fieldType = '';
            width = 0;
        }
    }
    
    public class Filter {
        @AuraEnabled public Boolean isRestricted;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Id filterId;
        @AuraEnabled public String label;
        @AuraEnabled public String operatorLabel;
        @AuraEnabled public String apiName;
        @AuraEnabled public String fieldType;
        @AuraEnabled public String operator;
        @AuraEnabled public String value;
        
        public Filter() {
            isRestricted = false;
            isActive = false;
            filterId = null;
            label = '';
            operatorLabel = '';
            apiName = '';
            fieldType = '';
            operator = '';
            value = '';
        }
    }
    
    public class StudioUser {
        @AuraEnabled public String label;
        @AuraEnabled public String role;
        @AuraEnabled public String value;
        
        public StudioUser() {
            label = '';
            role = '';
            value = '';
        }
    }
}