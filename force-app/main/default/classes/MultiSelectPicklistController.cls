public class MultiSelectPicklistController {
    public SelectOption[] leftOptions{ get; set; }
    public SelectOption[] rightOptions{ get; set; }
    
     public String leftOptionsHidden { get; set { 
             if(value !=''){
            leftOptionsHidden = value; 
            setOptions(leftOptions, value); 
            }
            else
            {
            	leftOptions.clear();
            }
         } 
     } 
      
     public String rightOptionsHidden { get; set { 
            system.debug('right value' +value);
            if(value !=''){
            rightOptionsHidden = value; 
            setOptions(rightOptions, value); 
            }
            else
            {
            	rightOptions.clear();
            }
     } 
     }

     private void setOptions(SelectOption[] options, String value) { 
         system.debug('value##'+value);
         options.clear(); 
         String[] optionValue = value.split('&');
         system.debug('option values'+optionValue.size()); 
         for (Integer i=0; i<optionValue.size(); i++) { 
         
             String[] optionParts = optionValue[i].split('#'); 
             system.debug('option values &&&'+optionParts);
             options.add(new SelectOption(EncodingUtil.urlDecode(optionParts[0], 'UTF-8'), EncodingUtil.urlDecode(optionParts[1], 'UTF-8'))); 
             system.debug('selected option'+options);
             options.sort();
             system.debug('selected option after sort'+options);
             
         } 
         
         
     } 
}