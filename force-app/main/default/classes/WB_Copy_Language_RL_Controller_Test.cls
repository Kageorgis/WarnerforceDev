/*
Version- 1.0
Creation Date- 23rd DEC 2016
Author- Preeti Jha
Description- This test class is for testing of WB_Copy_Language_RL_Controller.
*/
@isTest
public class WB_Copy_Language_RL_Controller_Test {

    static testMethod void validateCopyLanguage() {
        CopyLanguageQueryLimitSize__c limitSize = new CopyLanguageQueryLimitSize__c();
        limitSize.name= 'Test custom setting';
        limitSize.Copy_Language_Query_Limit_Size__c = 100;
        insert limitSize;
        
        MPM__c mpm = TestUtil.createMPM('12345');
        insert mpm;
        system.assertNotEquals(null,mpm.id);
        
        Title__c currentTitle = TestUtil.initTitle('Test Title1','2060707');
        currentTitle.MPM__c = mpm.id;
        currentTitle.Formats__c = 'SD';
        insert currentTitle;
        system.assertNotEquals(null,currentTitle.id);
        
        System.currentPageReference().getParameters().put('id', currentTitle.id);
        
        Title__c selectedTitle = TestUtil.initTitle('Test Title2','20607076');
        selectedTitle.MPM__c = mpm.id;
        selectedTitle.Formats__c = 'HD';
        insert selectedTitle;
        system.assertNotEquals(null,selectedTitle.id);
        
        Language__c lang = TestUtil.initLanguage('English','en',1);
        insert lang;
        system.assertNotEquals(null,lang.id);
        
        Language__c langArebic = TestUtil.initLanguage('Arebic','en',1);
        insert langArebic;
        system.assertNotEquals(null,langArebic.id);
        
        Language__c langHindi = TestUtil.initLanguage('Hindi','en',1);
        insert langHindi;
        system.assertNotEquals(null,langHindi.id);
        
        Available_Languages__c availableLang = TestUtil.initAvailableLang(lang.id,'Audio',selectedTitle.id);
        availableLang.Clear_to_Avail__c =true;
        insert availableLang;
        system.assertNotEquals(null,availableLang.id);
        
        Available_Languages__c availableLang2 = TestUtil.initAvailableLang(langHindi.id,'Audio',selectedTitle.id);
        availableLang2.Clear_to_Avail__c =true;
        insert availableLang2;
        system.assertNotEquals(null,availableLang2.id);
        
        WB_Copy_Language_RL_Controller copyLang = new WB_Copy_Language_RL_Controller();
        copyLang.getTitles();
        system.assertEquals(false,copyLang.TitleList[0].isChecked);
        copyLang.TitleList[0].isChecked = true;
        copyLang.processSelected();
        
        Available_Languages__c availableLangTitle = TestUtil.initAvailableLang(langArebic.id,'Audio',currentTitle.id);
        availableLangTitle.Clear_to_Avail__c =true;
        insert availableLangTitle;
        system.assertNotEquals(null,availableLangTitle.id);
        
        
        WB_Copy_Language_RL_Controller copyLang2 = new WB_Copy_Language_RL_Controller();
        copyLang2.getTitles();
        system.assertEquals(false,copyLang2.TitleList[0].isChecked);
        copyLang2.TitleList[0].isChecked = true;
        copyLang2.processSelected();
        copyLang2.doSearch();
        copyLang2.Cancel();
    }

}