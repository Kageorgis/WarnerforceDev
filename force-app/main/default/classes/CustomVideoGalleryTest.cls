@isTest
public class CustomVideoGalleryTest {
    @isTest static void getVideoTest(){


        Profile p = [SELECT Id FROM Profile WHERE Name='TPX - Standard User'];
        User u1 = new User(Alias = 'testing',Country='United States',Email='test@test.com',EmailEncodingKey='UTF-8', LastName='Testingtest', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='mokeyTestCloud@test.com');

        System.runAs(u1){

            List<String> ListIds = new List<String> ();
            List<Custom_Content__c> listUrls = new List<Custom_Content__c>();
            integer max = 4;
            for(Integer i = 0; i < max;  i++){
                ContentVersion cv=new Contentversion();
                cv.title='TestFile'+i;
                cv.PathOnClient ='TestFile'+i;
                cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body'+i);
                insert cv;
                
                ContentDistribution cd = new ContentDistribution();
                cd.Name = 'Test'+i;
                cd.ContentVersionId = cv.id;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                insert cd;
                
                if(cd.ID != Null){
                    ContentDistribution ContentDFile = [select Name,ContentDocumentId,ContentDownloadUrl from ContentDistribution where ID = :cd.ID];                    
                    ListIds.add(ContentDFile.ContentDocumentId);
                }
                
            }
            
                  
        
            Map<String,String> result = CustomVideoGallery.getVideo(ListIds);
            system.debug(result);
            system.assertEquals(result.size(), max);

            Delete [select Id from ContentDistribution];
            
        }
       
        
    }
}