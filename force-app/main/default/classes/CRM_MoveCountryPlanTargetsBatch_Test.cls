/**
   @Author Aditi Satpute
   @name CRM_MoveCountryPlanTargetsBatch_Test
   @CreateDate 31 May 2016
   @Description Test class for CRM_MoveCountryPlanTargetsBatch
   @Version <1.0>
   @reference Requirement no 185
  */

@isTest
public with sharing class CRM_MoveCountryPlanTargetsBatch_Test {

    @testsetup  
    public static void createTestDataForBatchNotificationStatus(){ 
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
    }

    /**
     * Method to test Targets Moved on StreetDate Change -> Verify Account Plan Auto Allocated properly with Targets updated
     */
    public static testMethod void testMoveCPTargetsWithAccountPlanTargetUpdate() {

        CRM_MoveCountryPlanTargetsService_Test.createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper> mapIdToCountryPlanInstance =
            new Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper instance =
                new CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c;
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Insert GL calendars
        List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();

        // For Target 1 - After Street Date Change
        Date startDate = (System.today() + 220).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar1);

        // For Target 2 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar2 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar2);
        
        // For Target 3 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar3 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar3);

        // For Target 4 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar4 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar4);

        // For Target 5 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar5 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar5);

        // For Target 6 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar6 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar6);

        // For Target 7 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar7 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar7);

        // For Target 8 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar8 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar8);
        insert lstGLCalendar;

        // Change Street Date such that no GL calendar available for that date range
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 220;
        }
        update lstProduct;

        List<Product2> lstProductBeforeBatchProcess = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProductBeforeBatchProcess.size());
        for (Product2 prod : lstProductBeforeBatchProcess) {
            System.assert(prod.Update_Country_Plan_Targets__c, 'The Flag should be checked');
        }

        Map<String, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper> mapBeforeAPTargetUniqueKeyToCPTargetInstance =
            new Map<String, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper>();
        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c,Target_Quantity__c,Stretch_Target_Quantity__c
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, RecordTypeId, Name, CurrencyISOCode, Share__c, Total_Target__c,Target_Quantity__c, Product_Group__c, Customer__c,Returns_Share__c,Billing_Adjustment_Share__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
            ];

        for(Country_Plan__c countryPlan : countryPlansWithInnerQuery){
            for(Country_Plan_Target__c countryPlanTarget : countryPlan.Country_Plan_Targets__r){
                CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper expectedCPTWrapperInstance =
                    mapIdToCountryPlanInstance.get(countryPlanTarget.Id);
                for(Account_Plan__c accountPlan : countryPlan.Account_Plans__r){
                    mapBeforeAPTargetUniqueKeyToCPTargetInstance.put(countryPlanTarget.Name + accountPlan.Name, expectedCPTWrapperInstance);
                }
            }
        }

        // Auto Allocate Account Plan Targets
        //CRM_GenerateAccountPlanTargetsCtrl controller = new CRM_GenerateAccountPlanTargetsCtrl();
        List<Target__c> accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlansWithInnerQuery);

        if (!accountPlanTargetList.isEmpty()) {
            upsert accountPlanTargetList Unique_Key__c;
        }

        // Verify existing targets Present
        List<Target__c> lstTargetsBeforeUpdate = [
            SELECT
                Id, GL_Calendar__c,StartDate__c, End_Date__c,LastModifiedDate, Target__c,Product__c,
                Unique_Key__c, Account__c, Account_Plan_Lookup__r.Customer__c
            FROM Target__c ORDER BY StartDate__c, CreatedDate
        ];
        System.assertEquals(75, lstTargetsBeforeUpdate.size());
        for (Target__c targetInstance : lstTargetsBeforeUpdate) {
            System.assertEquals(11, targetInstance.Target__c);
            System.assert(targetInstance.Unique_Key__c != null);
            System.assertEquals(targetInstance.Account_Plan_Lookup__r.Customer__c, targetInstance.Account__c);
            System.assert(mapBeforeAPTargetUniqueKeyToCPTargetInstance.containsKey(targetInstance.Unique_Key__c), 'Unique Key should be present');
            System.assertEquals(mapBeforeAPTargetUniqueKeyToCPTargetInstance.get(targetInstance.Unique_Key__c).glcalendarId, targetInstance.GL_Calendar__c);
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, batchInstance.lstExceptions.size());


        // Verify GL Calendar Updated in Country Plan targets 
        Map<String, Country_Plan_Target__c> mapAfterAPTargetUniqueKeyToCPTargetInstance = new Map<String, Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            System.assertEquals(3, countryPlan.Country_Plan_Targets__r.size());
            for (Integer i = 0; i < countryPlan.Country_Plan_Targets__r.size(); i++) {
                Country_Plan_Target__c actualCPT = countryPlan.Country_Plan_Targets__r[i];
                CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper expectedCPTWrapperInstance =
                    mapIdToCountryPlanInstance.get(actualCPT.Id);

                // Verif Batch did modified the targets
                //System.assertNotEquals(expectedCPTWrapperInstance.lastModifiedDate, actualCPT.LastModifiedDate);
                System.assertNotEquals(expectedCPTWrapperInstance.startDate, actualCPT.Start_Date__c);
                System.assertNotEquals(expectedCPTWrapperInstance.endDate, actualCPT.End_Date__c);
                System.assertNotEquals(expectedCPTWrapperInstance.glCalendarId, actualCPT.GL_Calendar__c);

                Date updatedDate = (System.today() + 220).toStartOfMonth();

                // Verify First record is updated with updated Product's Street Date month / Year Calendar
                if (i == 0) {
                    System.assertEquals(updatedDate.year() + '-' + updatedDate.month(), actualCPT.GL_Calendar__r.Name);
                } else if (i == 1) {
                    System.assertEquals((updatedDate.addMonths(1)).year()  + '-' + (updatedDate.addMonths(1)).month() , actualCPT.GL_Calendar__r.Name);
                } else {
                    System.assertEquals((updatedDate.addMonths(2)).year()  + '-' + (updatedDate.addMonths(2)).month() , actualCPT.GL_Calendar__r.Name);
                }

                for(Account_Plan__c accountPlan : countryPlan.Account_Plans__r){
                    mapAfterAPTargetUniqueKeyToCPTargetInstance.put(actualCPT.Name + accountPlan.Name, actualCPT);
                }
            }
        }

        // Verify new Targets are updated Properly
        List<Target__c> lstTargetsAfterUpdate = [
            SELECT
                Id, GL_Calendar__c, StartDate__c, End_Date__c, Target__c,LastModifiedDate,
                Product__c, Unique_Key__c, Account__c, Account_Plan_Lookup__r.Customer__c
            FROM Target__c ORDER BY StartDate__c, CreatedDate
        ];
        System.assertEquals(75, lstTargetsAfterUpdate.size());

        for (Integer i=0; i < lstTargetsAfterUpdate.size(); i++) {
            Target__c actualTargetInstance = lstTargetsAfterUpdate[i];
            Target__c expectedTargetInstance = lstTargetsBeforeUpdate[i];
            System.assertEquals(11, actualTargetInstance.Target__c);
            System.assert(actualTargetInstance.Unique_Key__c != null);
            //System.assertNotEquals(expectedTargetInstance.LastModifiedDate, actualTargetInstance.LastModifiedDate);
            System.assertNotEquals(expectedTargetInstance.GL_Calendar__c, actualTargetInstance.GL_Calendar__c);
            System.assertNotEquals(expectedTargetInstance.StartDate__c, actualTargetInstance.StartDate__c);
            System.assertNotEquals(expectedTargetInstance.End_Date__c, actualTargetInstance.End_Date__c);
            System.assertEquals(actualTargetInstance.Account_Plan_Lookup__r.Customer__c, actualTargetInstance.Account__c);
            System.assert(mapAfterAPTargetUniqueKeyToCPTargetInstance.containsKey(actualTargetInstance.Unique_Key__c), 'Unique Key should be present');
            System.assertEquals(mapAfterAPTargetUniqueKeyToCPTargetInstance.get(actualTargetInstance.Unique_Key__c).GL_Calendar__c, actualTargetInstance.GL_Calendar__c);
            System.assertEquals(mapAfterAPTargetUniqueKeyToCPTargetInstance.get(actualTargetInstance.Unique_Key__c).Country_Plan__r.NR_Product__c, actualTargetInstance.Product__c);
            System.assertEquals(mapAfterAPTargetUniqueKeyToCPTargetInstance.get(actualTargetInstance.Unique_Key__c).Start_Date__c, actualTargetInstance.StartDate__c);
            System.assertEquals(mapAfterAPTargetUniqueKeyToCPTargetInstance.get(actualTargetInstance.Unique_Key__c).End_Date__c, actualTargetInstance.End_Date__c);
        }

        // Verify Flag has been reset proeprly after processing
        List<Product2> lstProductAfterBatchProcess = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProductAfterBatchProcess.size());
        for (Product2 prod : lstProductAfterBatchProcess) {
            System.assert(!prod.Update_Country_Plan_Targets__c, 'The Flag should be reset');
        }
    }

    /**
     * Method to test Targets Moved on StreetDate Change -> Verify Account Plan Auto Allocated properly with Targets Created
     */
    public static testMethod void testMoveCPTargetsWithAccountPlanTargetInsert() {

        CRM_MoveCountryPlanTargetsService_Test.createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper> mapIdToCountryPlanInstance =
            new Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper instance =
                new CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c;
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Insert GL calendars
        List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();

        // For Target 1 - After Street Date Change
        Date startDate = (System.today() + 220).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar1);

        // For Target 2 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar2 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar2);
        
        // For Target 3 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar3 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar3);

        // For Target 4 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar4 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar4);

        // For Target 5 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar5 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar5);

        // For Target 6 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar6 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar6);

        // For Target 7 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar7 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar7);

        // For Target 8 - After Street Date Change
        startDate = (startDate.toStartOfMonth()).addMonths(1);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar8 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar8);
        insert lstGLCalendar;

        // Change Street Date such that no GL calendar available for that date range
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 220;
        }
        update lstProduct;
        
        // Verify Flag has been set proeprly
        List<Product2> lstProductBeforeBatchProcess = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProductBeforeBatchProcess.size());
        for (Product2 prod : lstProductBeforeBatchProcess) {
            System.assert(prod.Update_Country_Plan_Targets__c, 'The Flag should be checked');
        }

        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
            ];

        // Verify no existing targets Present
        System.assertEquals(0, [SELECT Id FROM Target__c].size());
        
        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, batchInstance.lstExceptions.size());
        
        // Verify GL Calendar Updated in Country Plan targets  
        Map<String, Country_Plan_Target__c> mapAPTargetUniqueKeyToCPTargetInstance = new Map<String, Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            System.assertEquals(3, countryPlan.Country_Plan_Targets__r.size());
            for (Integer i = 0; i < countryPlan.Country_Plan_Targets__r.size(); i++) {
                Country_Plan_Target__c actualCPT = countryPlan.Country_Plan_Targets__r[i];
                CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper expectedCPTWrapperInstance =
                    mapIdToCountryPlanInstance.get(actualCPT.Id);

                // Verif Batch did modified the targets
                //System.assertNotEquals(expectedCPTWrapperInstance.lastModifiedDate, actualCPT.LastModifiedDate);
                System.assertNotEquals(expectedCPTWrapperInstance.startDate, actualCPT.Start_Date__c);
                System.assertNotEquals(expectedCPTWrapperInstance.endDate, actualCPT.End_Date__c);
                System.assertNotEquals(expectedCPTWrapperInstance.glCalendarId, actualCPT.GL_Calendar__c);
                
                Date updatedDate = (System.today() + 220).toStartOfMonth();

                // Verify First record is updated with updated Product's Street Date month / Year Calendar
                if (i == 0) {
                    System.assertEquals(updatedDate.year() + '-' + updatedDate.month(), actualCPT.GL_Calendar__r.Name);
                } else if (i == 1) {
                    System.assertEquals((updatedDate.addMonths(1)).year()  + '-' + (updatedDate.addMonths(1)).month() , actualCPT.GL_Calendar__r.Name);
                } else {
                    System.assertEquals((updatedDate.addMonths(2)).year()  + '-' + (updatedDate.addMonths(2)).month() , actualCPT.GL_Calendar__r.Name);
                }

                for(Account_Plan__c accountPlan : countryPlan.Account_Plans__r){
                    mapAPTargetUniqueKeyToCPTargetInstance.put(actualCPT.Name + accountPlan.Name, actualCPT);
                }
            }
        }

        // Verify new Targets are inserted Properly
        List<Target__c> lstTargets = [
            SELECT
                Id, GL_Calendar__c, Target__c,StartDate__c,End_Date__c, Product__c, Unique_Key__c,
                Account__c, Account_Plan_Lookup__r.Customer__c
            FROM Target__c
        ];
        System.assertEquals(75, lstTargets.size());
        for (Target__c targetInstance : lstTargets) {
            System.assertEquals(11, targetInstance.Target__c);
            System.assert(targetInstance.Unique_Key__c != null);
            System.assertEquals(targetInstance.Account_Plan_Lookup__r.Customer__c, targetInstance.Account__c);
            System.assert(mapAPTargetUniqueKeyToCPTargetInstance.containsKey(targetInstance.Unique_Key__c), 'Unique Key should be present');
            System.assertEquals(mapAPTargetUniqueKeyToCPTargetInstance.get(targetInstance.Unique_Key__c).GL_Calendar__c, targetInstance.GL_Calendar__c);
            System.assertEquals(mapAPTargetUniqueKeyToCPTargetInstance.get(targetInstance.Unique_Key__c).Country_Plan__r.NR_Product__c, targetInstance.Product__c);
            System.assertEquals(mapAPTargetUniqueKeyToCPTargetInstance.get(targetInstance.Unique_Key__c).Start_Date__c, targetInstance.StartDate__c);
            System.assertEquals(mapAPTargetUniqueKeyToCPTargetInstance.get(targetInstance.Unique_Key__c).End_Date__c, targetInstance.End_Date__c);
        }

        // Verify Flag has been reset proeprly after processing
        List<Product2> lstProductAfterBatchProcess = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProductAfterBatchProcess.size());
        for (Product2 prod : lstProductAfterBatchProcess) {
            System.assert(!prod.Update_Country_Plan_Targets__c, 'The Flag should be reset');
        }
    }

    /**
     * Method to test Street Date Changed to non Future i.e prev month
     */
    public static testMethod void testStreetDateChangedToNonFuture() {

        CRM_MoveCountryPlanTargetsService_Test.createData();

        List<Product2> lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id FROM Country_Plan__c];
        System.assertEquals(5, lstCountryPlan.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper> mapIdToCountryPlanInstance =
            new Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper instance = new CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c;
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Change Street Date to previous Date
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() - 20;
        }
        update lstProduct;

        // Verify Flag is not Checked as the changed Date is non future
        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        for (Product2 prod : lstProduct) {
            System.assert(!prod.Update_Country_Plan_Targets__c, 'The Flag should not be checked');
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, batchInstance.lstExceptions.size());

        // Verify No GL Calendar Updated in Country Plan targets 
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            System.assertEquals(3, countryPlan.Country_Plan_Targets__r.size());
            for (Integer i = 0; i < countryPlan.Country_Plan_Targets__r.size(); i++) {
                Country_Plan_Target__c actualCPT = countryPlan.Country_Plan_Targets__r[i];
                CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(actualCPT.Id);

                 Date startDate = System.today().toStartOfMonth();
 
                // Verif Batch did not modify the targets
                System.assertEquals(expectedCPTWrapperInstance.LastModifiedDate, actualCPT.LastModifiedDate);
                if (i == 0) {
                    System.assertEquals(startDate.year() + '-' + startDate.month(), actualCPT.GL_Calendar__r.Name);
                } else if (i == 1) {
                    System.assertEquals((startDate.addMonths(6)).year()  + '-' + (startDate.addMonths(6)).month() , actualCPT.GL_Calendar__r.Name);
                } else {
                    System.assertEquals((startDate.addMonths(8)).year()  + '-' + (startDate.addMonths(8)).month() , actualCPT.GL_Calendar__r.Name);
                }
            }
        }
    }

    /**
     * Method to test Street date not present after Changing
     */
    public static testMethod void testStreetDateChangedToBlank() {

        CRM_MoveCountryPlanTargetsService_Test.createData();

        List<Product2> lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id FROM Country_Plan__c];
        System.assertEquals(5, lstCountryPlan.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper> mapIdToCountryPlanInstance =
            new Map<Id, CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper instance = new CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c;
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Change Street Date to make it blank
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = null;
        }
        update lstProduct;

        // Verify Flag is not Checked as the changed Date is non future
        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        for (Product2 prod : lstProduct) {
            System.assert(!prod.Update_Country_Plan_Targets__c, 'The Flag should not be checked');
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, batchInstance.lstExceptions.size());

        // Verify No GL Calendar Updated in Country Plan targets 
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            System.assertEquals(3, countryPlan.Country_Plan_Targets__r.size());
            for (Integer i = 0; i < countryPlan.Country_Plan_Targets__r.size(); i++) {
                Country_Plan_Target__c actualCPT = countryPlan.Country_Plan_Targets__r[i];
                CRM_MoveCountryPlanTargetsService_Test.CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(actualCPT.Id);

                Date startDate = System.today().toStartOfMonth();

                // Verif Batch did not modify the targets
                System.assertEquals(expectedCPTWrapperInstance.LastModifiedDate, actualCPT.LastModifiedDate);
                if (i == 0) {
                    System.assertEquals(startDate.year() + '-' + startDate.month(), actualCPT.GL_Calendar__r.Name);
                } else if (i == 1) {
                    System.assertEquals((startDate.addMonths(6)).year()  + '-' + (startDate.addMonths(6)).month() , actualCPT.GL_Calendar__r.Name);
                } else {
                    System.assertEquals((startDate.addMonths(8)).year()  + '-' + (startDate.addMonths(8)).month() , actualCPT.GL_Calendar__r.Name);
                }
            }
        }
    }

    /**
     * Method to test sending mail with exception having Record Id present
     */
    public static testMethod void Negative_Test_SendMail_With_RecordId(){
        //Method to create Dummy Data
        CRM_MoveCountryPlanTargetsService_Test.createData();

        List<Product2> lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id FROM Country_Plan__c];
        System.assertEquals(5, lstCountryPlan.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());

        // Change Street Date such that the flag used to process is checked
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 150;
        }
        update lstProduct;

        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        for (Product2 prod : lstProduct) {
            System.assert(prod.Update_Country_Plan_Targets__c, 'The Flag should be checked');
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        for (Country_Plan__c p : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            batchInstance.lstExceptions.add(new CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException(p.NR_Product__c, lstErrors));
        }
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        System.assertEquals(5, batchInstance.lstExceptions.size());

        // Verify Product Flag is not reset as there is error
        for(Product2 p : [SELECT Id, RecordTypeId, Update_Country_Plan_Targets__c, NR_Product_Created__c FROM Product2]){
            System.assert(p.Update_Country_Plan_Targets__c, 'True as there is error');
        }
    }

    /**
     * Method to test sending mail with exception having no Record Id present
     */
    public static testMethod void Negative_Test_SendMail_Without_RecordId() {
        //Method to create Dummy Data
        CRM_MoveCountryPlanTargetsService_Test.createData();

        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id FROM Country_Plan__c];
        System.assertEquals(5, lstCountryPlan.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());

        // Change Street Date such that the flag used to process is checked
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 150;
        }
        update lstProduct;

        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        for (Product2 prod : lstProduct) {
            System.assert(prod.Update_Country_Plan_Targets__c, 'The Flag should be checked');
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        for (Country_Plan__c p : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            batchInstance.lstExceptions.add(new CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException(null, lstErrors));
        }
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        System.assertEquals(5, batchInstance.lstExceptions.size());

        // Verify Product Flag is reset as no Product Id found in exception
        for (Product2 p : [SELECT Id, RecordTypeId, Update_Country_Plan_Targets__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!p.Update_Country_Plan_Targets__c);
        }
    }

    /**
     * Method to test Error Handling while Resetting Processed Product Flag
     */
    public static testMethod void Negative_Test_ResetProcessedProductFlags() {
        //Method to create Dummy Data
        CRM_MoveCountryPlanTargetsService_Test.createData();

        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        // Change Street Date such that the flag used to process is checked
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 150;
        }
        update lstProduct;

        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        for (Product2 prod : lstProduct) {
            System.assert(prod.Update_Country_Plan_Targets__c, 'The Flag should be checked');
        }

        for(Product2 p : lstProduct){
            p.CurrencyIsoCode = null;
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        System.assert(batchInstance.lstExceptions.isEmpty());
        batchInstance.resetProcessedProductFlags(lstProduct);
        Test.stopTest();

        System.assert(!batchInstance.lstExceptions.isEmpty());
        System.assertEquals(5, batchInstance.lstExceptions.size());
    }

    /**
     * Method to test Error Handling sending mail
     */
    public static testMethod void Negative_Test_Send_Mail() {
        //Method to create Dummy Data
        CRM_MoveCountryPlanTargetsService_Test.createData();

        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, false);
        System.assertEquals(1, lstProGrp.size());
        
        List<Product2> lstNewProduct = CRM_TestDataFactory.createProducts(lstProGrp, 5, false);
        for (Product2 prod : lstNewProduct) {
            prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
        }
        insert lstNewProduct;

        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        System.assertEquals(10, lstProduct.size());

        // Change Street Date such that the flag used to process is checked
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 150;
        }
        update lstProduct;

        lstProduct = [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2];
        for (Product2 prod : lstProduct) {
            System.assert(prod.Update_Country_Plan_Targets__c, 'The Flag should be checked');
        }

        Test.startTest();
        CRM_MoveCountryPlanTargetsBatch batchInstance = new CRM_MoveCountryPlanTargetsBatch();
        Set<Id> processedProductIds = new set<Id>();
        for (Country_Plan__c p : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
        ]) {
            processedProductIds.add(p.NR_Product__c);
        }
        for (Product2 p : [SELECT Id, Update_Country_Plan_Targets__c, Street_Date__c FROM Product2 WHERE Id NOT IN: processedProductIds]) {
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            batchInstance.lstExceptions.add(new CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException(p.Id, lstErrors));
        }
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify errors present
        System.assertEquals(5, batchInstance.lstExceptions.size());

        // Verify Product Flag is reset ony for 5 Products for which Country Plans are present
        for (Product2 p : [SELECT Id, RecordTypeId, Update_Country_Plan_Targets__c, NR_Product_Created__c FROM Product2]){
            if (processedProductIds.contains(p.Id)) {
                System.assert(!p.Update_Country_Plan_Targets__c, 'False as Country Plans processed');
            } else {
                System.assert(p.Update_Country_Plan_Targets__c, 'True as there is no Country Plan Record present');
            }
        }
    }
}