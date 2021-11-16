/*******************************************************************************************************************************************
* File Name     :   WB_TriggerHandlerECPiecesTest
* Description   :   Test class
* @author       :   TCS
* Modification Log
===================================================================================================
* Ver.    Date              Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0    19 Nov 2014        Harika Bondalapati      Class created
* 2.0    31 March 2016      Prajakta                CH-01 : Added one method
********************************************************************************************************************************************/

@isTest
public with sharing class WB_TriggerHandlerECPiecesTest{
    
    static testMethod void updateMPMTest() {
          // create MPM
          //MPM_Long_Desc__c='test long',
          MPM__c mpm = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
          insert mpm;
          //create EC Tracker
          EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm.Id);
          insert tracker;
          
          // insert custom setting for trigger on/off functionality 
          //insert DisableTrigger__c(isDisabled__c = false);
          
          DisableTrigger__c CustSetting = new DisableTrigger__c(); 
          CustSetting.name = 'TriggerOnECPiece';
          CustSetting.isDisabled__c = false;
          insert CustSetting ;
          
          //create or update EC Piece
          Decimal ones = 1;
          Decimal twos = 2;
          Test.startTest();
              EC_Piece__c ec = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Min__c=56,Sec__c=45);
              insert ec;
              EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,Min__c=56,Sec__c=45);
              insert ec2;
              
              EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Min__c=56,Sec__c=45);
              insert ec1;
              List<EC_Piece__c> ecdelList = new List<EC_Piece__c>();
              ecdelList.add(ec1);
              ecdelList.add(ec);
              delete ecdelList;
          Test.stopTest();     
     }
       
    static testMethod void updateMPMTest2() {
        // create MPM
        MPM__c mpm = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
        insert mpm;
        
        //create EC Tracker
        EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm.Id);
        insert tracker;
        
           
        DisableTrigger__c CustSetting = new DisableTrigger__c(); 
        CustSetting.name = 'TriggerOnECPiece';
        CustSetting.isDisabled__c = false;
        insert CustSetting ;  
          
      
        //create or update EC Piece
        EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=1,Min__c=56,Sec__c=45);
        insert ec1;
        EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=2,Min__c=56,Sec__c=45);
        insert ec2;
        EC_Piece__c ec3 = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=3,Min__c=56,Sec__c=45);
        insert ec3;
      
        Test.startTest();
            List<EC_Piece__c> ecl2 = new List<EC_Piece__c>();
              
            EC_Piece__c ec5 = new EC_Piece__c(EC_Name__c='ec test piece3',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=2,Min__c=56,Sec__c=45);
            ecl2.add(ec5);
            EC_Piece__c ec7 = new EC_Piece__c(EC_Name__c='ec test piece3',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Min__c=56,Sec__c=45);
            ecl2.add(ec7);
            EC_Piece__c  ec6 = [select Id,Sequence__c from EC_Piece__c where Id=:ec3.Id];
            ec3.Sequence__c = -1;
            ecl2.add(ec3);
            EC_Piece__c  ec8 = [select Id,Sequence__c from EC_Piece__c where Id=:ec1.Id];
            ec8.Sequence__c = 3;
            ecl2.add(ec8);
            try{
                upsert ecl2;
            } catch (Exception e) {
                system.assert(e.getMessage().contains('Sequence'));
            }  
        Test.stopTest();     
    }
    
    static testMethod void updateSeq2() {
        // create MPM
        MPM__c mpm = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
        insert mpm;
        
        //create EC Tracker
        EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm.Id);
        insert tracker;
      
              
        DisableTrigger__c CustSetting = new DisableTrigger__c(); 
        CustSetting.name = 'TriggerOnECPiece';
        CustSetting.isDisabled__c = false;
        insert CustSetting ;  
        
        //create or update EC Piece
        EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=1,Min__c=56,Sec__c=45);
        insert ec1;
        EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=2,Min__c=56,Sec__c=45);
        insert ec2;
        EC_Piece__c ec3 = new EC_Piece__c(EC_Name__c='ec test piece',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Sequence__c=3,Min__c=56,Sec__c=45);
        insert ec3;
      
        Test.startTest();
            List<EC_Piece__c> ecl2 = new List<EC_Piece__c>();
            EC_Piece__c  ec4 = [select Id,Sequence__c from EC_Piece__c where Id=:ec2.Id];
            ec4.Sequence__c = 3;
            ecl2.add(ec4);
            
            
            try{
                WB_TriggerHandlerECPieces.updateflag = true;
                //update ecl2;
                WB_TriggerHandlerECPieces.updateflag = false;
            } catch (Exception e) {
                system.debug('-----e.getMessage()------'+e.getMessage());
                system.assert(e.getMessage().contains('incorrect'));
            }  
        Test.stopTest();     
    }
   
    static testMethod void updateTracker() {
        // create MPM
        MPM__c mpm = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
        insert mpm;
        
        //create EC Tracker
        EC_Tracker__c tracker1 = new EC_Tracker__c(Name='tracker test name1',MPM__c=mpm.Id);
        insert tracker1;
        EC_Tracker__c tracker2 = new EC_Tracker__c(Name='tracker test name2',MPM__c=mpm.Id);
        insert tracker2;
                    
        DisableTrigger__c CustSetting = new DisableTrigger__c(); 
        CustSetting.name = 'TriggerOnECPiece';
        CustSetting.isDisabled__c = false;
        insert CustSetting ;  
        
        //create or update EC Piece
        EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker1.Id,MPM__c=mpm.Id,Sequence__c=1,Min__c=56,Sec__c=45);
        insert ec1;
        EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker2.Id,MPM__c=mpm.Id,Sequence__c=1,Min__c=56,Sec__c=45);
        insert ec2;
      
        Test.startTest();

        	List<EC_Piece__c> ecl2 = new List<EC_Piece__c>();
            EC_Piece__c  ec4 = [select Id,Sequence__c, EC_Tracker__c from EC_Piece__c where Id=:ec2.Id];
			system.debug('EC Sequence before = ' + ec4.Sequence__c);
        	ec4.EC_Tracker__c = tracker1.id;
            ecl2.add(ec4);
        	update ecl2;
        	system.debug('EC Sequence after = ' + ec4.Sequence__c);

        Test.stopTest();     
    }
    
}