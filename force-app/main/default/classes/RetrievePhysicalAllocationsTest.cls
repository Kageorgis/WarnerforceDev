@isTest
public class RetrievePhysicalAllocationsTest
{

  static testMethod void testRetAllocs()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
  EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece1',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description');
  insert ec1;
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 1ec test piece 1ec test piece 1 ec test piece minetest',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Description 22');
  insert ec2;
  
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta;
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta1;
  //Create Account
  Account acct = TestUtil.initAccount();
  acct.EC_Digital_Account__c='Vendor';
  insert acct;
  //Create Contact
  Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',Role__c='EC Vendor;EC Contact');
  insert con;
  //create Contact Assignment
  Contact_Assignment__c cona = new Contact_Assignment__c(Account__c=acct.Id,EC_Tracker__c=tracker.Id,Role__c='EC Vendor');
  insert cona;
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
          newvv.Video_Version = title1.Video_Version__c;
                   
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
 static testMethod void testRetAllocs1()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
 EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece1',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description');
  insert ec1;
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece2',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2');
  insert ec2;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta;
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta1;
  
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
          newvv.Video_Version = 'test';
                   
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
 static testMethod void testRetAllocs2()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
  EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece1',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description');
  insert ec1;
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece2',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2');
  insert ec2;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta;
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta1;
  
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
          newvv.Video_Version = title2.Video_Version__c;
                   
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
 static testMethod void testRetAllocs3()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
  EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece1',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description');
  insert ec1;
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece2',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2');
  insert ec2;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta;
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta1;
  
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
          newvv.Video_Version = '2345677766';
                   
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
 static testMethod void testRetAllocs4()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
  EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece1',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description');
  insert ec1;
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece2',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2');
  insert ec2;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta;
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  insert ecta1;
  
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
         newvv.Video_Version = '';
        //newvv= null;           
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
  static testMethod void testRetAllocs5()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
  List<EC_Piece__c> ectestlist = new List<EC_Piece__c>();
  EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 1ec test piece 1ec test piece 1 ec test pie    1ec test piece 1ec test piece 1ec test piece 1ec test pi ec  e1 ec test piece 1ec test piece 1',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description3ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Description ');
  ectestlist.add(ec1);
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece62ec test piece 2ec test piece 2ec test piece 2ec test piece 2ec test piece 2ec test piece62ec test piece 2ec test pi',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Descriptio');
  ectestlist.add(ec2);
  EC_Piece__c ec3 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece6 2ec test piece 2ec test piece 2ec test piece 2ec test piec e',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Description223');
  ectestlist.add(ec3);
  EC_Piece__c ec4 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece6 2ec test piece 2ec test piece 2ec test piece 2ec test piec',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Description22 3');
  ectestlist.add(ec4);
  EC_Piece__c ec5 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece62ec test piece 2ec test piece 2ec test piece 2ec test piecet e',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Description');
  ectestlist.add(ec5);
  EC_Piece__c ec6 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece62ec test piece 2ec test piece 2ec test piece 2ec test piecet',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Description2232');
  ectestlist.add(ec6);
  EC_Piece__c ec7 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 7',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Description2 232');
  ectestlist.add(ec7);
  EC_Piece__c ec8 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 8',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 10, 7),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Description22');
  ectestlist.add(ec8);
  EC_Piece__c ec9 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 9',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Descriptions');
  ectestlist.add(ec9);
  EC_Piece__c ec10 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 10',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Description  s');
  ectestlist.add(ec10);
  EC_Piece__c ec11 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 11 this is it',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Descriptionect');
  ectestlist.add(ec11);
  EC_Piece__c ec12 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 12',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test Descriptionect ');
  ectestlist.add(ec12);
  EC_Piece__c ec13 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 13',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptione');
  ectestlist.add(ec13);
  EC_Piece__c ec14 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 14',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionse c Test Descriptionec Test Descriptionec Test Descriptionec e');
  ectestlist.add(ec14);
  EC_Piece__c ec15 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 15',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionse c Test Descriptionec Test Descriptionec Test Descriptioned');
  ectestlist.add(ec15);
  EC_Piece__c ec16 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 16',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionse c Test Descriptionec Test Descriptionec Test Descrip');
  ectestlist.add(ec16);
  EC_Piece__c ec17 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 17',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Descriptionsec Test Descriptionec Test Descriptionec Test Descriptionect s');
  ectestlist.add(ec17);
  EC_Piece__c ec18 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 18',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Descriptionsec Test Descriptionec Test Descriptionec Test Descriptionecte');
  ectestlist.add(ec18);
  EC_Piece__c ec19 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 19',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Descriptionsec Test Descriptionec Test Descriptionec Test Descriptionect');
  ectestlist.add(ec19);
  EC_Piece__c ec20 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 20',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description 2ec Test Description2ec Test Description2Test Descriptionsec Test Descriptionec Test Descriptionec Test Descrip');
  ectestlist.add(ec20);
  EC_Piece__c ec21 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 21',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptionecs');
  ectestlist.add(ec21);
  EC_Piece__c ec22 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 22',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionse c Test Descriptionec Test Descriptionec Test Descriptioneces s');
  ectestlist.add(ec22);
  EC_Piece__c ec23 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 23',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionse c Test Descriptionec Test Descriptionec Test Descriptionedsr');
  ectestlist.add(ec23);
  EC_Piece__c ec24 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 24',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionse c Test Descriptionec Test Descriptionec Test Descrip');
  ectestlist.add(ec24);
  EC_Piece__c ec25 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 25',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test DescriptionsecTest Descriptionec Test Descriptionec Test Descriptionecttsrf');
  ectestlist.add(ec25);
  EC_Piece__c ec26 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='test ec piece 26',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = null,Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Description2ec Test Description2ec Test Description2Test DescriptionsecTest Descriptionec Test Descriptionec Test Descriptionectecd');
  ectestlist.add(ec26);
  insert ectestlist;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  List<EC_Title_Allocation__c> Allocationtestlist = new List<EC_Title_Allocation__c>();
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta);
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta1);
  EC_Title_Allocation__c ecta2 = new EC_Title_Allocation__c(EC_Piece__c=ec3.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta2);
  EC_Title_Allocation__c ecta3 = new EC_Title_Allocation__c(EC_Piece__c=ec4.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta3);
  EC_Title_Allocation__c ecta4 = new EC_Title_Allocation__c(EC_Piece__c=ec5.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta4);
  EC_Title_Allocation__c ecta5 = new EC_Title_Allocation__c(EC_Piece__c=ec6.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta5);
  EC_Title_Allocation__c ecta6 = new EC_Title_Allocation__c(EC_Piece__c=ec7.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta6);
  EC_Title_Allocation__c ecta7 = new EC_Title_Allocation__c(EC_Piece__c=ec8.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta7);
  EC_Title_Allocation__c ecta8 = new EC_Title_Allocation__c(EC_Piece__c=ec9.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta8);
  EC_Title_Allocation__c ecta9 = new EC_Title_Allocation__c(EC_Piece__c=ec10.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta9);
  EC_Title_Allocation__c ecta10 = new EC_Title_Allocation__c(EC_Piece__c=ec11.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta10);
  EC_Title_Allocation__c ecta11 = new EC_Title_Allocation__c(EC_Piece__c=ec12.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta11);
  EC_Title_Allocation__c ecta12 = new EC_Title_Allocation__c(EC_Piece__c=ec13.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta12);
  EC_Title_Allocation__c ecta13 = new EC_Title_Allocation__c(EC_Piece__c=ec14.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta13);
  EC_Title_Allocation__c ecta14 = new EC_Title_Allocation__c(EC_Piece__c=ec15.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta14);
  EC_Title_Allocation__c ecta15 = new EC_Title_Allocation__c(EC_Piece__c=ec16.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta15);
  EC_Title_Allocation__c ecta16 = new EC_Title_Allocation__c(EC_Piece__c=ec17.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta16);
  EC_Title_Allocation__c ecta17 = new EC_Title_Allocation__c(EC_Piece__c=ec18.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta17);
  EC_Title_Allocation__c ecta18 = new EC_Title_Allocation__c(EC_Piece__c=ec19.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta18);
  EC_Title_Allocation__c ecta19 = new EC_Title_Allocation__c(EC_Piece__c=ec20.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta19);
  EC_Title_Allocation__c ecta20 = new EC_Title_Allocation__c(EC_Piece__c=ec21.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta20);
  EC_Title_Allocation__c ecta21 = new EC_Title_Allocation__c(EC_Piece__c=ec22.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta21);
  EC_Title_Allocation__c ecta22 = new EC_Title_Allocation__c(EC_Piece__c=ec23.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta22);
  EC_Title_Allocation__c ecta23 = new EC_Title_Allocation__c(EC_Piece__c=ec24.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta23);
  EC_Title_Allocation__c ecta24 = new EC_Title_Allocation__c(EC_Piece__c=ec25.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta24);
  EC_Title_Allocation__c ecta25 = new EC_Title_Allocation__c(EC_Piece__c=ec26.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta25);
  insert Allocationtestlist;
  //Create Account
  Account acct = TestUtil.initAccount();
  acct.EC_Digital_Account__c='Vendor';
  insert acct; 
  //Create Contact
  Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',Role__c='EC Vendor;EC Contact');
  insert con;
  //create Contact Assignment
  Contact_Assignment__c cona = new Contact_Assignment__c(Account__c=acct.Id,EC_Tracker__c=tracker.Id,Role__c='EC Vendor');
  insert cona;
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
          newvv.Video_Version = title2.Video_Version__c;
                   
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
  static testMethod void testRetAllocs6()
  {
   // create MPM
  MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
  insert mpm1;
  //create a title
  Title__c title1 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',MPM__c=mpm1.Id);
  Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='126466789',MPM__c=mpm1.Id);
  List<Title__c> titlelist = new List<Title__c>();
  titlelist.add(title1);
  titlelist.add(title2);
  insert titlelist;
  //create EC Tracker
  EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm1.Id);
  insert tracker;
  //create or update EC Piece
  List<EC_Piece__c> ectestlist = new List<EC_Piece__c>();
  EC_Piece__c ec1 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece62ec test piece 2ec test piece 2ec test piece 2ec test piece2ec test piece 2ec test piece62ec test piece 2ec test pi',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '4',Asp_Ratio__c = '16X9 F',Aud_Ind__c = 'Audio-only',Audio_Language_Type__c = 'Commentary',
                                    Delivery_Date__c = Date.newInstance(2017, 2, 17),Dlvbl__c = 'BD Only',Audio_Format__c = '1M',EC_Menu_Icon__c = 'Behind the Scenes',
                                    EC_Type__c = 'Digital Comics',Min__c = 101,Res__c = '1080p',Sec__c = 23,
                                    Long_Description__c='ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ec Test Description1 ');
  ectestlist.add(ec1);
  EC_Piece__c ec2 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec test piece 2ec test piece 2ec test piece 2ec test piece62ec test piece 2ec test piece 2ec test piece',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2');
  ectestlist.add(ec2);
  EC_Piece__c ec3 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 3',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptio neec Test Description2ec Test Description2ec Test Descript io2ec');
  ectestlist.add(ec3);
  EC_Piece__c ec4 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 4',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptio neec Test Description2ec Test Description2ec Test Descriptio2ec');
  ectestlist.add(ec4);
  EC_Piece__c ec5 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 5',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptio neec Test Description2ec Test Description2ec Test Descript');
  ectestlist.add(ec5);
  EC_Piece__c ec6 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 6',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptio neec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec6);
  EC_Piece__c ec7 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 7',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio 2ec');
  ectestlist.add(ec7);
  EC_Piece__c ec8 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 8',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2ec');
  ectestlist.add(ec8);
  EC_Piece__c ec9 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 9',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio');
  ectestlist.add(ec9);
  EC_Piece__c ec10 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 10',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionss e ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec10);
  EC_Piece__c ec11 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 11',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio 2ec');
  ectestlist.add(ec11);
  EC_Piece__c ec12 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 12',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio2ec');
  ectestlist.add(ec12);
  EC_Piece__c ec13 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 13',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio');
  ectestlist.add(ec13);
  EC_Piece__c ec14 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 14',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec14);
  EC_Piece__c ec15 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 15',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2e c');
  ectestlist.add(ec15);
  EC_Piece__c ec16 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 16',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2ec');
  ectestlist.add(ec16);
  EC_Piece__c ec17 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 17',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptions');
  ectestlist.add(ec17);
  EC_Piece__c ec18 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 18',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2 ec Test Description2ec Test Description2Test Descriptionsse ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec18);
  EC_Piece__c ec19 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 19',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio 2ec');
  ectestlist.add(ec19);
  EC_Piece__c ec20 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 20',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio2ec');
  ectestlist.add(ec20);
  EC_Piece__c ec21 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 11',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio');
  ectestlist.add(ec21);
  EC_Piece__c ec22 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 22',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec22);
  EC_Piece__c ec23 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 23',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2e c');
  ectestlist.add(ec23);
  EC_Piece__c ec24 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 24',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2ec');
  ectestlist.add(ec24);
  EC_Piece__c ec25 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 25',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptions');
  ectestlist.add(ec25);
  EC_Piece__c ec26 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 26',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssed ec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec26);
  EC_Piece__c ec27 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 27',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2ec Test');
  ectestlist.add(ec27);
  EC_Piece__c ec28 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 28',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptio2ecTest');
  ectestlist.add(ec28);
  EC_Piece__c ec29 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 29',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Descriptionss');
  ectestlist.add(ec29);
  EC_Piece__c ec30 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 30',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptioneec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec30);
  EC_Piece__c ec31 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 31',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio2ec Test');
  ectestlist.add(ec31);
  EC_Piece__c ec32 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 32',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptio2ecTest');
  ectestlist.add(ec32);
  EC_Piece__c ec33 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 33',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Descriptionss');
  ectestlist.add(ec33);
  EC_Piece__c ec34 = new EC_Piece__c(MPM__c=mpm1.Id,EC_Name__c='ec piece 34',EC_Tracker__c=tracker.Id,
                                    Image_Number__c = '3',Asp_Ratio__c = 'DUAL',Aud_Ind__c = 'Video-only',Audio_Language_Type__c = 'Production',
                                    Delivery_Date__c = Date.newInstance(2017, 6, 17),Dlvbl__c = 'SD / BD',Audio_Format__c = '2S',EC_Menu_Icon__c = 'Featurette',
                                    EC_Type__c = 'Deleted Scenes',Min__c = 81,Res__c = '576i',Sec__c = 56,
                                    Long_Description__c='ec Test Description2ec Test Description2ec Test Descriptio2ec Test Description2ec Test Description2Test Descriptionssedec Test Descriptionec Test Descriptionec Test Descriptione ec Test Description2ec Test Description2ec Test Desc');
  ectestlist.add(ec34);
  insert ectestlist;
  //Create a record on ECTitelAllocaiton Object to add ecs to titles
  List<EC_Title_Allocation__c> Allocationtestlist = new List<EC_Title_Allocation__c>();
  EC_Title_Allocation__c ecta = new EC_Title_Allocation__c(EC_Piece__c=ec1.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta);
  EC_Title_Allocation__c ecta1 = new EC_Title_Allocation__c(EC_Piece__c=ec2.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta1);
  EC_Title_Allocation__c ecta2 = new EC_Title_Allocation__c(EC_Piece__c=ec3.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta2);
  EC_Title_Allocation__c ecta3 = new EC_Title_Allocation__c(EC_Piece__c=ec4.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta3);
  EC_Title_Allocation__c ecta4 = new EC_Title_Allocation__c(EC_Piece__c=ec5.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta4);
  EC_Title_Allocation__c ecta5 = new EC_Title_Allocation__c(EC_Piece__c=ec6.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta5);
  EC_Title_Allocation__c ecta6 = new EC_Title_Allocation__c(EC_Piece__c=ec7.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta6);
  EC_Title_Allocation__c ecta7 = new EC_Title_Allocation__c(EC_Piece__c=ec8.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta7);
  EC_Title_Allocation__c ecta8 = new EC_Title_Allocation__c(EC_Piece__c=ec9.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta8);
  EC_Title_Allocation__c ecta9 = new EC_Title_Allocation__c(EC_Piece__c=ec10.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta9);
  EC_Title_Allocation__c ecta10 = new EC_Title_Allocation__c(EC_Piece__c=ec11.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta10);
  EC_Title_Allocation__c ecta11 = new EC_Title_Allocation__c(EC_Piece__c=ec12.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta11);
  EC_Title_Allocation__c ecta12 = new EC_Title_Allocation__c(EC_Piece__c=ec13.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta12);
  EC_Title_Allocation__c ecta13 = new EC_Title_Allocation__c(EC_Piece__c=ec14.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta13);
  EC_Title_Allocation__c ecta14 = new EC_Title_Allocation__c(EC_Piece__c=ec15.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta14);
  EC_Title_Allocation__c ecta15 = new EC_Title_Allocation__c(EC_Piece__c=ec16.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta15);
  EC_Title_Allocation__c ecta16 = new EC_Title_Allocation__c(EC_Piece__c=ec17.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta16);
  EC_Title_Allocation__c ecta17 = new EC_Title_Allocation__c(EC_Piece__c=ec18.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta17);
  EC_Title_Allocation__c ecta18 = new EC_Title_Allocation__c(EC_Piece__c=ec19.Id,MPM__c=mpm1.Id,Title__c=title2.Id);
  Allocationtestlist.add(ecta18);
  EC_Title_Allocation__c ecta19 = new EC_Title_Allocation__c(EC_Piece__c=ec20.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta19);
  EC_Title_Allocation__c ecta20 = new EC_Title_Allocation__c(EC_Piece__c=ec21.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta20);
  EC_Title_Allocation__c ecta21 = new EC_Title_Allocation__c(EC_Piece__c=ec22.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta21);
  EC_Title_Allocation__c ecta22 = new EC_Title_Allocation__c(EC_Piece__c=ec23.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta22);
  EC_Title_Allocation__c ecta23 = new EC_Title_Allocation__c(EC_Piece__c=ec24.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta23);
  EC_Title_Allocation__c ecta24 = new EC_Title_Allocation__c(EC_Piece__c=ec25.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta24);
  EC_Title_Allocation__c ecta25 = new EC_Title_Allocation__c(EC_Piece__c=ec26.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta25);
  EC_Title_Allocation__c ecta26 = new EC_Title_Allocation__c(EC_Piece__c=ec27.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta26);
  EC_Title_Allocation__c ecta27 = new EC_Title_Allocation__c(EC_Piece__c=ec28.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta27);
  EC_Title_Allocation__c ecta28 = new EC_Title_Allocation__c(EC_Piece__c=ec29.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta28);
  EC_Title_Allocation__c ecta29 = new EC_Title_Allocation__c(EC_Piece__c=ec30.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta29);
  EC_Title_Allocation__c ecta30 = new EC_Title_Allocation__c(EC_Piece__c=ec31.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta30);
  EC_Title_Allocation__c ecta31 = new EC_Title_Allocation__c(EC_Piece__c=ec32.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta31);
  EC_Title_Allocation__c ecta32 = new EC_Title_Allocation__c(EC_Piece__c=ec33.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta32);
  EC_Title_Allocation__c ecta33 = new EC_Title_Allocation__c(EC_Piece__c=ec34.Id,MPM__c=mpm1.Id,Title__c=title1.Id);
  Allocationtestlist.add(ecta33);
  
  insert Allocationtestlist;
  //Create Account
  Account acct = TestUtil.initAccount();
  acct.EC_Digital_Account__c='Vendor';
  insert acct;
  //Create Contact
  Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',Role__c='EC Vendor;EC Contact');
  insert con;
  //create Contact Assignment
  Contact_Assignment__c cona = new Contact_Assignment__c(Account__c=acct.Id,EC_Tracker__c=tracker.Id,Role__c='EC Vendor');
  insert cona;
    Test.startTest();
        RetrievePhysicalAllocations.VideoversionDetails newvv = new RetrievePhysicalAllocations.VideoversionDetails();
          newvv.Video_Version = title1.Video_Version__c;
                   
        List<RetrievePhysicalAllocations.VideoversionDetails> nt = new List<RetrievePhysicalAllocations.VideoversionDetails>();
        nt.add(newvv);
        
        List<RetrievePhysicalAllocations.ResponseMessage> responseList = RetrievePhysicalAllocations.RetriveAllocation(nt);
    
    Test.stopTest();
  }
   
}