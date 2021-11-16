@isTest
private class WB_RePriceClientAvail_Redirect_Con_Test {
 
	static testMethod void ClientAvailReprice_Redirect() {
   
   		list<Client_Avail_Exception__c> lst_excepns = new list<Client_Avail_Exception__c>();
      
	   	Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',Country_Code__c='TF');
	    insert countryFrance;
	    
	    Profile p = [select id from profile where name='System Administrator'];
	    User u = new User(alias = 'standt', email='testuser@testorg.com', 
	        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
	        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);
	    insert u;    
	    
	  	Client_Avail_Exception__c  aval_excp1 = new Client_Avail_Exception__c (Name='test',
              Avail_End__c=date.today()+10,Avail_Start__c=date.today(),Channel__c='EST',
              Content_Type__c='Feature',Country__c='USA',Format__c='HD',Language__c='Eng', 
              Language_Type__c='Dub',Reason__c='test reason',Release_Plan_Number__c='01254',
              Status__c='Planned',Title__c='title',User_Detail__c='u.Id',Account__c='test account',Old_Price_Records__c = false);   
	    //lst_excepns.add(aval_excp1); 
	    insert aval_excp1;
	    system.runAs(u) {
		    Test.startTest();   
		    PageReference pageRef = Page.WB_RePriceClientAvail_Redirect;
		    Test.setCurrentPage(pageRef);
		    ApexPages.currentPage().getParameters().put('id', aval_excp1.Id);
		    ApexPages.currentPage().getParameters().put('sm', 'false');
	      	// ApexPages.StandardController  sc = new ApexPages.StandardController (lst_excepns[0]);
	      	ApexPages.StandardController  sc = new ApexPages.StandardController (aval_excp1);
	       	WB_RePriceClientAvail_Redirect_Con controller = new WB_RePriceClientAvail_Redirect_Con(sc);
	       	controller.final_list.add(aval_excp1);
	      	pageReference pr = controller.okbutton();
	      	system.assertNotEquals(null, pr);
	        Test.stopTest();
	    }
	}
	
	static testMethod void ClientAvail_Redirect1() {
   
	   	list<Client_Avail_Exception__c> lst_excepns = new list<Client_Avail_Exception__c>();
	      
	   	Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',Country_Code__c='TF');
	    insert countryFrance;
	    
	    Profile p = [select id from profile where name='System Administrator'];
	    User u = new User(alias = 'standt', email='testuser@testorg.com', 
	        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
	        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);
	    insert u;    
	    
	  	Client_Avail_Exception__c  aval_excp1 = new Client_Avail_Exception__c (Name='test',
	              Avail_End__c=date.today()+10,Avail_Start__c=date.today(),Channel__c='EST',
	              Content_Type__c='Feature',Country__c='USA',Format__c='HD',Language__c='Eng', 
	              Language_Type__c='Dub',Reason__c='test reason',Release_Plan_Number__c='01254',
	              Status__c='Planned',Title__c='title',User_Detail__c='u.Id',Account__c='test account',Old_Price_Records__c = false);   
	    insert aval_excp1;
	    
	    system.runAs(u) {
	       	Test.startTest();   
	       	PageReference pageRef = Page.WB_ClientAvail_Redirect;
	       	Test.setCurrentPage(pageRef);
	       	ApexPages.currentPage().getParameters().put('id', aval_excp1.Id);
	       	ApexPages.StandardController  sc = new ApexPages.StandardController (aval_excp1);
	       	WB_ClientAvail_Redirect_Controller controller = new WB_ClientAvail_Redirect_Controller(sc);
	      	controller.clientAvailException_list.add(aval_excp1);
	      	controller.okbutton();
	        Test.stopTest();
	        
	        system.assertEquals(0, controller.recordCount);
	    }
    }
    
    static testMethod void ClientAvail_Redirect2() {
   
	   	list<Client_Avail_Exception__c> lst_excepns = new list<Client_Avail_Exception__c>();
	      
	   	Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',Country_Code__c='TF');
	    insert countryFrance;
	    
	    Profile p = [select id from profile where name='System Administrator'];
	    
	    List<User> lstUser = new List<User>();
	    User user1 = new User(alias = 'standt', email='testuser1@testorg.com', 
	        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
	        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser1@testorg.com',profileid = p.Id);
	    
	    lstUser.add(user1);
	    insert lstUser;    
	    
	    Client_Avail_Exception__c  aval_excp1 = new Client_Avail_Exception__c();
	    
	  	aval_excp1 = new Client_Avail_Exception__c (Name='test',
	              Avail_End__c=date.today()+10,Avail_Start__c=date.today(),Channel__c='EST',
	              Content_Type__c='Feature',Country__c='USA',Format__c='HD',Language__c='Eng', 
	              Language_Type__c='Dub',Reason__c='test reason',Release_Plan_Number__c='01254',
	              Status__c='Planned',Title__c='title',Account__c='test account',Old_Price_Records__c = false,
	              User_Detail__c = lstUser[0].Id);
	    insert aval_excp1;
	    
	    system.runAs(lstUser[0]) {
	       	Test.startTest();   
	       	PageReference pageRef = Page.WB_ClientAvail_Redirect;
	       	Test.setCurrentPage(pageRef);
	       	ApexPages.currentPage().getParameters().put('id', aval_excp1.Id);
	       	ApexPages.StandardController  sc = new ApexPages.StandardController (aval_excp1);
	       	WB_ClientAvail_Redirect_Controller controller = new WB_ClientAvail_Redirect_Controller(sc);
	      	controller.clientAvailException_list.add(aval_excp1);
	      	controller.okbutton();
	        Test.stopTest();
	        
	        system.assertNotEquals(0, controller.clientAvailException_list.size());
	    }
    }
}