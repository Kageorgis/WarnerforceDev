/*
   @Author: Aditi Satpute
   @name: CRM_MoveCountryPlanTargetsService_Test
   @CreateDate: 27 May 2016
   @Description: Test Code Coverage for 'CRM_MoveCountryPlanTargetsService' 
   @Version <1.0>
   @reference: classes: CRM_MoveCountryPlanTargetsService
*/

@isTest
public with sharing class CRM_MoveCountryPlanTargetsService_Test {

    /**
     * Method to created Test data
     */
    public static void createData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(5, false);
        for (Account acc : lstAccounts) {
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        }
        insert lstAccounts;
        //CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        System.assertEquals(5, lstAccounts.size());

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, false);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp, lstAccounts);
        System.assertEquals(5, lstProduct.size());
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today();
            prod.Pending_Country_Plan_Creation__c =false;
        }
        update lstProduct;

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, true);
        System.assertEquals(5, lstCountryPlan.size());

        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstAccounts, true);
        System.assertEquals(25, lstAccountPlan.size());

        // Insert GL calendars
        List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();

        // For Target 1
        Date startDate = System.today().toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar1);

        // For Target 2 with 2 months difference
        startDate = (System.today().toStartOfMonth()).addMonths(6);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar2 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar2);

        // For Target 3 with 3 months difference
        startDate = (System.today().toStartOfMonth()).addMonths(8);
        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar3 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar3);
        insert lstGLCalendar;
        System.assertEquals(3, lstGLCalendar.size());

        // Insert Country Plan Targets
        List<Country_Plan_Target__c> lstCountryPlanTargets = new List<Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : lstCountryPlan) {
            lstCountryPlanTargets.addAll(CRM_TestDataFactory.createCountryPlanTarget(countryPlan, [SELECT Id FROM GL_Calendar__c ORDER BY Start_Date__c]));
        }

        // Verify 3 Country Plan Targets created for each Country Plan records
        System.assertEquals(15, lstCountryPlanTargets.size());
    }

    /**
     * Method to test scenario with No GL Calendar Present on Street Date Change
     */
    public static testMethod void testNoGLCalendarPresent() {
        createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM
                Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CountryPlanTargetWrapper> mapIdToCountryPlanInstance = new Map<Id, CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CountryPlanTargetWrapper instance = new CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c;
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Change Street Date such that no GL calendar available for that date range
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 150;
        }
        update lstProduct;

        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, NR_Product__r.Type__c, NR_Product__r.Local_Title__r.Country__r.Country_Code2__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Target_Quantity__c,Stretch_Target_Quantity__c
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

        Test.startTest();
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstException =
            CRM_MoveCountryPlanTargetsService.processCountryPlanRecords(
                countryPlansWithInnerQuery,
                setProcessedIds
            );
        Test.stopTest();
        // Verify no exception present
        System.assertEquals(0, lstException.size());

        // Verify No GL Calendar Updated in Country Plan targets 
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name,Target_Quantity__c,Stretch_Target_Quantity__c
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
                CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(actualCPT.Id);
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
     * Method to test Targets Moved on StreetDate Change -> Verify Account Plan Auto Allocated properly with Targets Updated
     */
    public static testMethod void testMoveCPTargetsWithAccountPlanTargetUpdate() {

        createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c, GL_Calendar__r.Name,
                GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Target_Quantity__c,Stretch_Target_Quantity__c
            FROM
                Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CountryPlanTargetWrapper> mapIdToCountryPlanInstance = new Map<Id, CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CountryPlanTargetWrapper instance = new CountryPlanTargetWrapper();
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
        system.debug(lstProduct);

        Map<String, CountryPlanTargetWrapper> mapBeforeAPTargetUniqueKeyToCPTargetInstance = new Map<String, CountryPlanTargetWrapper>();
        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, NR_Product__r.Type__c, NR_Product__r.Local_Title__r.Country__r.Country_Code2__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c, Target_Quantity__c,Stretch_Target_Quantity__c 
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
                CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(countryPlanTarget.Id);
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
            FROM
                Target__c ORDER BY StartDate__c, CreatedDate
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
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstException =
            CRM_MoveCountryPlanTargetsService.processCountryPlanRecords(
                countryPlansWithInnerQuery,
                setProcessedIds
            );
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, lstException.size());

        // Verify GL Calendar Updated in Country Plan targets 
        Map<String, Country_Plan_Target__c> mapAfterAPTargetUniqueKeyToCPTargetInstance = new Map<String, Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name,Target_Quantity__c,Stretch_Target_Quantity__c
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
            system.debug('CPTs+++++++++++++++++++'+countryPlan.Country_Plan_Targets__r);
            for (Integer i = 0; i < countryPlan.Country_Plan_Targets__r.size(); i++) {
                Country_Plan_Target__c actualCPT = countryPlan.Country_Plan_Targets__r[i];
                CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(actualCPT.Id);

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
                Id, GL_Calendar__c, StartDate__c, End_Date__c, Target__c,LastModifiedDate,Product__c,
                Unique_Key__c, Account__c, Account_Plan_Lookup__r.Customer__c
            FROM Target__c ORDER BY StartDate__c, CreatedDate
        ];
        System.assertEquals(75, lstTargetsAfterUpdate.size());

        for (Integer i=0; i < lstTargetsAfterUpdate.size(); i++) {
            Target__c actualTargetInstance = lstTargetsAfterUpdate[i];
            Target__c expectedTargetInstance = lstTargetsBeforeUpdate[i];
            System.assertEquals(11, actualTargetInstance.Target__c);
            System.assert(actualTargetInstance.Unique_Key__c != null);
            System.assertNotEquals(expectedTargetInstance.LastModifiedDate, actualTargetInstance.LastModifiedDate);
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
    }

    /**
     * Method to test Targets Moved on StreetDate Change -> Verify Account Plan Auto Allocated properly with Targets Created
     */
    public static testMethod void testMoveCPTargetsWithAccountPlanTargetInsert() {

        createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c,
                GL_Calendar__r.Name, GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CountryPlanTargetWrapper> mapIdToCountryPlanInstance = new Map<Id, CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CountryPlanTargetWrapper instance = new CountryPlanTargetWrapper();
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

        List<Country_Plan__c> countryPlansWithInnerQuery = 
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, NR_Product__r.Type__c, NR_Product__r.Local_Title__r.Country__r.Country_Code2__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Target_Quantity__c,Stretch_Target_Quantity__c
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
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstException =
            CRM_MoveCountryPlanTargetsService.processCountryPlanRecords(
                countryPlansWithInnerQuery,
                setProcessedIds
            );
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, lstException.size());

        // Verify GL Calendar Updated in Country Plan targets 
        Map<String, Country_Plan_Target__c> mapAPTargetUniqueKeyToCPTargetInstance = new Map<String, Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name,Target_Quantity__c,Stretch_Target_Quantity__c
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
                CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(actualCPT.Id);

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
                Id, GL_Calendar__c, Target__c,StartDate__c,End_Date__c, Product__c,
                Unique_Key__c, Account__c, Account_Plan_Lookup__r.Customer__c
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
    }

    /**
     * Method to test Targets not moved even if StreetDate Changed as those already have proper GL Calendars
     */
    public static testMethod void testCPTargetsNotMovedAsGLCalendarAlreadyPresent() {
        createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c,
                GL_Calendar__r.Name, GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];
        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CountryPlanTargetWrapper> mapIdToCountryPlanInstance = new Map<Id, CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CountryPlanTargetWrapper instance = new CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c;
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Change Street Date such that valid GL Calendar already added to Targets
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 10;
        }
        update lstProduct;

        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, NR_Product__r.Type__c, NR_Product__r.Local_Title__r.Country__r.Country_Code2__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Target_Quantity__c,Stretch_Target_Quantity__c
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

        Test.startTest();
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstException =
            CRM_MoveCountryPlanTargetsService.processCountryPlanRecords(
                countryPlansWithInnerQuery,
                setProcessedIds
            );
        Test.stopTest();

        // Verify no exception present
        System.assertEquals(0, lstException.size());

        // Verify No GL Calendar Updated in Country Plan targets 
        for (Country_Plan__c countryPlan : [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,LastModifiedDate, GL_Calendar__r.Name,Target_Quantity__c,Stretch_Target_Quantity__c
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
                CountryPlanTargetWrapper expectedCPTWrapperInstance = mapIdToCountryPlanInstance.get(actualCPT.Id);

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
     * Method to test Error Handling if no valid fields present in query while processing GL Calender
     */
    public static testMethod void testGLCalendarProcessingException() {
        createData();
        Set<Id> setProcessedIds = new Set<Id>();
        List<Product2> lstProduct = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan_Target__c> lstCountryPlantarget = [
            SELECT
                Id, Start_Date__c, End_Date__c, LastModifiedDate, GL_Calendar__c,
                GL_Calendar__r.Name, GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
            FROM Country_Plan_Target__c
        ];

        System.assertEquals(15, lstCountryPlantarget.size());
        Map<Id, CountryPlanTargetWrapper> mapIdToCountryPlanInstance = new Map<Id, CountryPlanTargetWrapper>();
        for (Country_Plan_Target__c cpt : lstCountryPlantarget) {
            CountryPlanTargetWrapper instance = new CountryPlanTargetWrapper();
            instance.month = Integer.valueOf(cpt.GL_Calendar__r.Month__c);
            instance.year = Integer.valueOf(cpt.GL_Calendar__r.Year__c);
            instance.glCalendarName = cpt.GL_Calendar__r.Name;
            instance.glCalendarId = cpt.GL_Calendar__c; 
            instance.startDate = cpt.Start_Date__c;
            instance.endDate = cpt.End_Date__c;
            instance.lastModifiedDate = cpt.LastModifiedDate;
            mapIdToCountryPlanInstance.put(cpt.Id, instance);
        }

        // Change Street Date such that no GL calendar available for that date range
        for (Product2 prod : lstProduct) {
            prod.Street_Date__c = System.today() + 150; 
        }
        update lstProduct;

        // Query without inner query fields to throw exception
        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, NR_Product__r.Type__c, NR_Product__r.Local_Title__r.Country__r.Country_Code2__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
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
            ];

        Test.startTest();
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstException =
            CRM_MoveCountryPlanTargetsService.processCountryPlanRecords(
                countryPlansWithInnerQuery,
                setProcessedIds
            );
        Test.stopTest();

        // Verify exception present
        System.assertEquals(1, lstException.size());
        List<CRM_Error_Log__c> lstErrorLog = [SELECT Id FROM CRM_Error_Log__c];
        System.assertEquals(1, lstErrorLog.size());
    }

    /**
     * Method to test error handling when Country Plans are inserted
     */
    public static testMethod void testNegativeCountryPlanInsertFail() {
        createData();
        List<Country_Plan_Target__c> lstUpdateCountryPlanTarget = [SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c FROM Country_Plan_Target__c];
        for (Country_Plan_Target__c cpt : lstUpdateCountryPlanTarget) {
            cpt.Id = null;
        }

        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstExceptions =
            new List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException>();

        Test.startTest();
        List<Country_Plan__c> countryPlanList = CRM_MoveCountryPlanTargetsService.updateCountryPlanTargets(
            lstUpdateCountryPlanTarget,
            listErrorLog,
            lstExceptions
        );
        Test.stopTest();

        System.assertEquals(0, countryPlanList.size());

        // Verify exception present
        System.assertEquals(15, lstExceptions.size());
        System.assertEquals(15, listErrorLog.size());
    }

    /**
     * Method to test error handling when Account Plan Targets are inserted / updated
     */
    public static testMethod void testNegativeAccountPlanTargetInsertFail_No_Field_Available() {
        createData();
        List<Country_Plan__c> lstCountryPlanToAutoAllocate =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id,Target_Quantity__c,Stretch_Target_Quantity__c
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
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstExceptions =
            new List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException>();

        Test.startTest();
        CRM_MoveCountryPlanTargetsService.autoAllocateAccountPlanTargets(
            lstCountryPlanToAutoAllocate,
            listErrorLog,
            lstExceptions
        );
        Test.stopTest();

        // Verify exception present
        System.assertEquals(1, lstExceptions.size());
        System.assertEquals(1, listErrorLog.size());
    }

    /**
     * Method to test error handling when Account Plan Targets are inserted / updated
     */
    public static testMethod void testNegativeAccountPlanTargetInsertFail_Incorrect_Data() {
        createData();

        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstExceptions =
            new List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException>();

        List<Country_Plan__c> countryPlanList = [SELECT Id, Stretch_Target__c FROM Country_Plan__c];
        for (Country_Plan__c cp : countryPlanList) {
            cp.Stretch_Target__c = 1000000000;
        }
        update countryPlanList;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for(Account_Plan__c ap : lstAccountPlan){
            ap.Share__c = 1000000000;
        }
        update lstAccountPlan;

        List<Country_Plan_Target__c> lstCountryPlanTarget = [SELECT Id, Target__c FROM Country_Plan_Target__c];
        for(Country_Plan_Target__c ct: lstCountryPlanTarget){
            ct.Target__c = 1000000000;
        }
        update lstCountryPlanTarget;

        List<Country_Plan__c> lstCountryPlanToAutoAllocate =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c, NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c,Target_Quantity__c,Stretch_Target_Quantity__c
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c,Returns_Share__c,Billing_Adjustment_Share__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
            ];

        Test.startTest();
        CRM_MoveCountryPlanTargetsService.autoAllocateAccountPlanTargets(
            lstCountryPlanToAutoAllocate,
            listErrorLog,
            lstExceptions
        );
        Test.stopTest();

        // Verify exception present
        system.debug('---lstExceptions---'+lstExceptions);
        System.assertEquals(75, lstExceptions.size());
        System.assertEquals(75, listErrorLog.size());
    }

    public class CountryPlanTargetWrapper {
        public Integer month;
        public Integer year;
        public String glCalendarName;
        public Id glCalendarId;
        public Date startDate;
        public Date endDate;
        public DateTime lastModifiedDate;
    }
}