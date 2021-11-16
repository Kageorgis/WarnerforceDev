@isTest
public class WB_Batch_UpdateMPMReleaseDateTest {
      public static testMethod void UpdateMPMReleaseDate() {
        
        Test.startTest();
         MPM__c mpm = TestUtil.createMPM('12345');
         insert mpm;
         system.assertNotEquals(null,mpm.id);
        
        Title__c currentTitle = TestUtil.initTitle('Test Title1','2060707');
        currentTitle.MPM__c = mpm.id;
        currentTitle.Formats__c = 'SD';
        insert currentTitle;
        system.assertNotEquals(null,currentTitle.id);
          
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1);
        insert Language;
          
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
        Commercial_Avail__c commTest = new Commercial_Avail__c(
            Title__c = currentTitle.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = date.parse('10/31/2024'), start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/16/2018')
        );
        lstCommAvail.add(commTest);
        
        Commercial_Avail__c commTest1 = new Commercial_Avail__c(
            Title__c = currentTitle.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Sub', end_date__c = date.parse('10/31/2024'), start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/16/2018')
        );
        //lstCommAvail.add(commTest1);
        insert lstCommAvail;
        //Test.stopTest();
        
      Set<Id> setRPID = new Set<Id>();
      for(Commercial_Avail__c RP : [Select id from Commercial_Avail__c limit 5])
          setRPID.add(RP.id);
          
        User users = [select id from user where isActive = true and Profile.Name = 'System Administrator' LIMIT 1]; 
        System.RunAs(users) {
            Group grp = new Group();
            grp.Name = 'Test Group';
            insert grp;
             
            List<GroupMember>listGroupMember =new List<GroupMember>();  
            // loop the users that have been created
            GroupMember gm = new GroupMember(); 
            gm.GroupId= grp.id;
            gm.UserOrGroupId = users.id;
            listGroupMember.add(gm);  
        
            insert listGroupMember;
        WB_Batch_MPMRD_Rollup obj = new WB_Batch_MPMRD_Rollup(setRPID);
        obj.strBatchGroup='Test Group';
        WB_Batch_UpdateMPMReleaseDate batchInst = new WB_Batch_UpdateMPMReleaseDate(setRPID);
        Database.executeBatch(batchInst,50);
        }          
        
           Test.stopTest();
      }
    
    public static testMethod void UpdateMPMReleaseDate2() {
        
        Test.startTest();
         MPM__c mpm = TestUtil.createMPM('12345');
         insert mpm;
         system.assertNotEquals(null,mpm.id);
        
         MPM__c mpm2 = TestUtil.createMPM('123456');
         insert mpm2;
         
        
        Title__c currentTitle = TestUtil.initTitle('Test Title1','2060707');
        currentTitle.MPM__c = mpm2.id;
        currentTitle.Formats__c = 'SD';
        insert currentTitle;
        system.assertNotEquals(null,currentTitle.id);
          
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1);
        insert Language;
          
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
        Commercial_Avail__c commTest = new Commercial_Avail__c(
            Title__c = currentTitle.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+5, start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=system.today()+5,Exclusive_Date__c=date.parse('10/16/2018')
        );
        lstCommAvail.add(commTest);
        
        
        Commercial_Avail__c commTest1 = new Commercial_Avail__c(
            Title__c = currentTitle.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Sub', end_date__c = date.parse('10/31/2024'), start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/16/2018')
        );
        //lstCommAvail.add(commTest1);
        //insert lstCommAvail;
        lstCommAvail.add(null);
        
        
      Set<Id> setRPID = new Set<Id>();
      for(Commercial_Avail__c RP : [Select id from Commercial_Avail__c limit 1])
          setRPID.add(RP.id);
          
        User users = [select id from user where isActive = true and Profile.Name = 'System Administrator' LIMIT 1]; 
        System.RunAs(users) {
            Group grp = new Group();
            grp.Name = 'Test Group';
            insert grp;
             
            List<GroupMember>listGroupMember =new List<GroupMember>();  
            // loop the users that have been created
            GroupMember gm = new GroupMember(); 
            gm.GroupId= grp.id;
            gm.UserOrGroupId = users.id;
            listGroupMember.add(gm);  
        
            insert listGroupMember;
        
        
        /*WB_Batch_MPMRD_Rollup obj = new WB_Batch_MPMRD_Rollup(setRPID);
        obj.strBatchGroup='Test Group';*/
          
        WB_Batch_UpdateMPMReleaseDate batchInst2 = new WB_Batch_UpdateMPMReleaseDate(setRPID);
       
        Database.executeBatch(batchInst2,21);
        }
           Test.stopTest();
            
      }
    
}