/*
* Processes the rows of the file to be returned to the batch you use it.
*
* Author:          Date:           Description
* Walter Ynche  19-August-16       First Draft
*/

global with sharing class FileIterator implements Iterator<String>, Iterable<String> {
	private String sData;
	private String sValue;
    
	public FileIterator(String sDataFile, String sFileValue){
		sData = sDataFile;
		sValue = sFileValue;
	}
 	
	global Boolean hasNext(){
		return sData.length()>1 ? true : false;
	}
	
	global String next(){
		String row = sData.subString(0,sData.indexOf(sValue));
		sData = sData.subString(sData.indexOf(sValue) + sValue.length(),sData.length());
		return row;
	}
    
	global Iterator<String> Iterator(){
		return this;
	}
}