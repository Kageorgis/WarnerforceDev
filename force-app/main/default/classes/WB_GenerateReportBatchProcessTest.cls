/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class WB_GenerateReportBatchProcessTest {
	
	static TestDataUtility tdu = new TestDataUtility();
	
	public class ReportHttpCalloutMockImpl implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
		// Create a fake response.
		// Set response values, and
		// return response.
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('<sessionId>1235</sessionId');
		res.setStatusCode(200);
		return res;
		}
	}


	@isTest(SeeAllData='true')
    static void testGenerateReportBatchProcess() {
    	
    	//Preparing Data for Testing.
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        Announcement__c ann = tdu.createAnnouncement(aList[0], ar);
        
        EmailTemplate e =[SELECT id,Subject, HtmlValue, Body, name 
                            FROM EmailTemplate 
                            WHERE name = 'Announce - Google Delta no FE'];
        
        ar.Email_Template_Id__c = e.Id;
        update ar;
        
        
        MPM__c m = tdu.createMPM();
	    Title__c t = tdu.createTitle(m);
	    Language__c l = tdu.createLanguage();
	    Country__c c = tdu.createCountry();
	    Local_Title__c lt = tdu.createlocalTitle(c, l);
	    Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
	    Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
	    Test.startTest();
 	    Client_Avail__c ca = tdu.createClientAvail(rp, sf, aList[0]);
	    
	    tdu.createAnnouncementRecord(new List<Announcement__c>{ann}, aList[0], new List<Client_Avail__c>{ca});
	    
    
	    Test.setMock(HttpCalloutMock.class, new ReportHttpCalloutMockImpl());
	    set<Id> announementIdSet = new set<Id>() ;
	    announementIdSet.add(ann.Id);
	    Id batchInstanceId = Database.executeBatch(new WB_GenerateReportBatchProcess (announementIdSet), 10);
	    Test.stopTest();
    }
}