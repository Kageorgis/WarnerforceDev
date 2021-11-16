/**
   @Author Cognizant
   @name CRM_DecayCurveTemplateHandler_Test
   @CreateDate 9 Feb 2017
   @Description Test class for CRM_DecayCurveTemplateHandler
   @Version <1.0>
   @reference Defect no 3895(Decay Curve is miscalculating schedules)
  */

@isTest(seeAlldata=false)
public with sharing class CRM_DecayCurveTemplateHandler_Test {
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void testDataForInsertDCT() {
        
        //Inseert DCT with same name,Version Number,Currency Code
        List<Decay_Curve_Template__c> lstDCT = new List<Decay_Curve_Template__c>();
        for(integer i=0 ; i<3 ; i++){
            Decay_Curve_Template__c dct = new Decay_Curve_Template__c();
            dct.Name = 'Test DCT';
            dct.CurrencyIsoCode = 'JPY';
            lstDCT.add(dct);
        }
        insert lstDCT;
        integer counter = 0;
        for(Decay_Curve_Template__c dct : [Select Version_Number__c From Decay_Curve_Template__c ORDER BY Version_Number__c ASC]){
        	system.assertEquals(counter,dct.Version_Number__c);
        	counter++;
        }
        
        Decay_Curve_Template__c newDct = new Decay_Curve_Template__c();
        newDct.Name = 'Test DCT';
        newDct.CurrencyIsoCode = 'JPY';
        insert newDct;
        
        system.assertEquals(3,[Select Version_Number__c From Decay_Curve_Template__c Where Id =:newDct.Id Limit 1].Version_Number__c,'Version number should be populated by value 3');
    }
    
    static testMethod void testDataForUpdateDCT() {
        List<Decay_Curve_Template__c> lstDCT = new List<Decay_Curve_Template__c>();
        List<Decay_Curve_Template__c> lstDCTJPY = new List<Decay_Curve_Template__c>();
        List<Decay_Curve_Template__c> lstDCTGBP = new List<Decay_Curve_Template__c>();
        List<Decay_Curve_Item__c> lstDCI = new List<Decay_Curve_Item__c>();
        
        for(integer i=0 ; i<=5 ; i++){
            Decay_Curve_Template__c dct = new Decay_Curve_Template__c();
            if(i<3){
                dct.Name = 'Test DCT JP';
                dct.CurrencyIsoCode = 'JPY';
                dct.Version_Number__c = i;
            }else{
                dct.Name = 'Test DCT GBP';
                dct.CurrencyIsoCode = 'GBP';
                dct.Version_Number__c = i - 3;
            }
            lstDCT.add(dct);
        }
        insert lstDCT;
        
        for(Decay_Curve_Template__c dct : lstDCT){
            if(dct.CurrencyIsoCode == 'JPY')
                lstDCTJPY.add(dct);
            else
                lstDCTGBP.add(dct);
            for(integer i=0 ; i<2 ; i++){
                Decay_Curve_Item__c dci = new Decay_Curve_Item__c();
                dci.Name  = 'Test - '+i+'_'+dct.ID;
                dci.Percent_Allocation__c = 50;
                dci.Day_Number__c = 1;
                dci.Decay_Curve_Template__c = dct.ID;
                lstDCI.add(dci);
            }
        }
        insert lstDCI;
        
        //Change Status From Draf to Active
        lstDCTJPY[0].Status__c = 'Active';
        update lstDCT[0];
        
        //Try to update same DCT with status Active
        try{
            lstDCTJPY[1].Status__c = 'Active';
            update lstDCTJPY[1];
        }catch(System.DMLException de){
            String errorMsg = de.getDmlMessage(0);
            //Assert error msg
            system.assertEquals(errorMsg,System.label.CRM_DCT_Active_Validation_Msg);
        }
        
        system.assertEquals(3,[Select Count() From Decay_Curve_Template__c Where Name = 'Test DCT JP']);
        system.assertEquals(3,[Select Count() From Decay_Curve_Template__c Where Name = 'Test DCT GBP']);
        
        //Update DCT Name
        lstDCTJPY[1].Name = 'Test DCT GBP';
        lstDCTJPY[1].CurrencyIsoCode = 'GBP';
        update lstDCTJPY[1];
        List<Decay_Curve_Template__c> dctList1 =[Select Version_Number__c From Decay_Curve_Template__c Where Id = :lstDCTJPY[1].Id];
        system.assertEquals(4,[Select Count() From Decay_Curve_Template__c Where Name = 'Test DCT GBP'],'Added one DCT with Name Test DCT GBP');    
        System.assertEquals(3,dctList1[0].Version_Number__c,'Version Number updated to 3');
        
        //Update DCT Name
        lstDCTJPY[2].Name = 'Test New DCT';
        update lstDCTJPY[2];
        List<Decay_Curve_Template__c> dctList2 =[Select Version_Number__c From Decay_Curve_Template__c Where Id = :lstDCTJPY[2].ID];
        System.assertEquals(0,dctList2[0].Version_Number__c,'Version Number updated to 0');
        
        //Try to delete Active DCT
        try{
            delete lstDCTJPY[0];
        }catch(System.DMLException de){
            String errorMsg = de.getDmlMessage(0);
            //Assert error msg
            system.assertEquals(errorMsg,System.label.CRM_DCT_Restrict_To_Delete_ActiveOrArchived_DCT);
        }
    }
}