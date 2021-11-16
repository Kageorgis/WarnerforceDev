@isTest
public class WB_Schedule_MPMReleaseDateUpdate_Test {
    static testmethod void TestSchedulableClass() {
        Test.StartTest();
        
            MPMRollUpBatchSetting__c batchSize = new MPMRollUpBatchSetting__c();
            batchSize.name= 'Test custom setting';
            batchSize.LastModified_RP_Minutes__c = -05;
            batchSize.MPM_Roll_up_Batch_size__c = 20;
            insert batchSize;
            
			List<MPM__c> mpmList = new List<MPM__c>();
            MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='012345');
			MPM__c mpm1 = new MPM__c(name='MPM record',MPM_Number__c='012346',Generic__c = true);
			mpmList.add(mpm);
			mpmList.add(mpm1);
			insert mpmList;
        
            List<Title__c> titleList = new List<Title__c>();
			Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',
                                          First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                                          Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
										  
			Title__c title2 = new Title__c(Name='TestTitle12Sep26', Video_Version__c='0123456780',
                                          First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                                          Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
            titleList.add(title);
			titleList.add(title2);
			insert titleList;
            
            Language__c Language = new Language__c (Name='TestLanguage2', Language_Order__c = 1);
            insert Language;
            
            Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
            insert availLangTitle1;
        
            Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
            insert con;
        
            MPM_Release_Date__c mpmRD1 = new MPM_Release_Date__c(); 
            mpmRD1.Country__c = con.id;
            mpmRD1.Language__c = Language.id;
            mpmRD1.Locale__c = 'de_CH'; 
            mpmRD1.MPM__c = mpm1.id;
            mpmRD1.Record_Status__c ='Active'; 
            mpmRD1.Channel__c = 'EST';
            mpmRD1.Format__c = 'HD';
            mpmRD1.Avail_Start__c=date.today(); 
            mpmRD1.Release_Start__c= date.today();
            mpmRD1.Release_Status__c='Confirmed';
        	mpmRD1.Key__c = '2000000_de_CH_EST_HD';
        	insert mpmRD1;
            
            Commercial_Avail__c commTest = new Commercial_Avail__c( Title__c = title.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Sub', end_date__c = system.today()+190, start_Date__c = system.today()+10,status__c = 'Open',
            Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2) );
            
            
            Commercial_Avail__c commTest1 = new Commercial_Avail__c( Title__c = title.Id, Channel__c = 'EST', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Sub', end_date__c = system.today()+190, start_Date__c = system.today()+10,status__c = 'Open',
            Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2),Release_Locale__c = 'de_CH');
			//key = 012345_de_CH_EST_HD
			
			
			Commercial_Avail__c commTest2 = new Commercial_Avail__c( Title__c = title2.Id, Channel__c = 'EST', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Sub', end_date__c = system.today()+190, start_Date__c = system.today()+10,status__c = 'Open',MRD_ID__c = mpmRD1.id,
            Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
            
            //Datetime halfHourBack = Datetime.now().addMinutes(-65);
            //Map<Id,Commercial_Avail__c> mapRPIds = new Map<Id,Commercial_Avail__c>([SELECT Id FROM Commercial_Avail__c WHERE MPM_Release_Date_Key__c != null AND LastModifiedDate >= :halfHourBack]);   
            List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
			rpList.add(commTest);
			rpList.add(commTest1);
			rpList.add(commTest2);
			insert rpList;
			set<Id> rpIds = new set<Id>(); 
			rpIds.add(rpList[0].id);
			rpIds.add(rpList[1].id);
			rpIds.add(rpList[2].id);
			
            WB_Schedule_MPMReleaseDateUpdate objScheduler = new WB_Schedule_MPMReleaseDateUpdate();
            String sch = '0 0 23 * * ?';
            system.schedule('Test MPM Roll UP', sch, objScheduler); 
        
            //WB_Batch_MPMRD_Rollup uptMPMRelDt= new WB_Batch_MPMRD_Rollup(mapRPIds.keySet());
			WB_Batch_MPMRD_Rollup uptMPMRelDt= new WB_Batch_MPMRD_Rollup(rpIds);
            database.executebatch(uptMPMRelDt);
			
			WB_Batch_MPMRD_Mismatch mpmRDmismatch = new WB_Batch_MPMRD_Mismatch(rpIds);
			database.executebatch(mpmRDmismatch);
			
        Test.stopTest(); 
    }
}