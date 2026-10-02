@isTest
private class ClaimsAdjusterControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a real active test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Username = 'testuser1234343@example.com.test',
            Email = 'testuser123@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        // Query Policy__c RecordType
        Id policyRT = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName()
            .get('Auto')
            .getRecordTypeId();
        Id claimRT = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName()
            .get('Accident')
            .getRecordTypeId();

        // Create Contact owned by same user
        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            OwnerId = u.Id
        );
        insert con;

        // Create Policy owned by same user
        Policy__c policy = new Policy__c(
            Customer__c = con.Id,
            RecordTypeId = policyRT,
            OwnerId = u.Id,
            VIN__c = '1A903284375893532'
        );
        insert policy;

        // Create Claim owned by same user
        Claim__c claim = new Claim__c(
            Policy__c = policy.Id,
            RecordTypeId = claimRT,
            Claim_Amount__c = 5000,
            Date_of_Loss__c = Date.today().addDays(-10),
            OwnerId = u.Id
        );
        insert claim;
        System.debug('Claim inserted: ' + claim.Id);
    }

    @isTest
    static void testGetAssignedClaims() {
        User u = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            List<ClaimsAdjusterController.ClaimWrapper> results =
                ClaimsAdjusterController.getAssignedClaims();
            System.debug('Result is: ' + results);
            Test.stopTest();

            ClaimsAdjusterController.ClaimWrapper wrap = results[0];

            System.assertNotEquals(null, wrap.claimId);
            System.assertNotEquals(null, wrap.claimNumber);
            System.assertEquals('New', wrap.status);
            System.assertEquals(5000, wrap.claimAmount);
            System.assert(wrap.policyHolderName.contains('John'));
            System.assertNotEquals('Unknown', wrap.policyType);
        }
    }

    @isTest
    static void testGetAssignedClaimsMultipleClaims() {
        User u = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        System.runAs(u) {
            // Create additional claims
            Id policyRT = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName()
                .get('Property')
                .getRecordTypeId();
            Id claimRT = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName()
                .get('Property')
                .getRecordTypeId();

            Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Smith', OwnerId = u.Id);
            insert con2;

            Policy__c policy2 = new Policy__c(
                Customer__c = con2.Id,
                RecordTypeId = policyRT,
                OwnerId = u.Id,
                Square_Footage__c = 2500
            );
            insert policy2;

            Claim__c claim2 = new Claim__c(
                Policy__c = policy2.Id,
                RecordTypeId = claimRT,
                Claim_Amount__c = 75000,
                Date_of_Loss__c = Date.today().addDays(-5),
                OwnerId = u.Id
            );
            insert claim2;

            Test.startTest();
            List<ClaimsAdjusterController.ClaimWrapper> results =
                ClaimsAdjusterController.getAssignedClaims();
            Test.stopTest();

            System.assertEquals(2, results.size(), 'Should return both claims');
            
            // Verify filtering by policy type works in wrapper
            Integer autoCount = 0;
            Integer propertyCount = 0;
            for (ClaimsAdjusterController.ClaimWrapper w : results) {
                if (w.policyType == 'Auto') autoCount++;
                else if (w.policyType == 'Property') propertyCount++;
            }
            System.assertEquals(1, autoCount);
            System.assertEquals(1, propertyCount);
        }
    }

    @isTest
    static void testGetAssignedClaimsNoClaims() {
        // Create a different user with no claims
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u2 = new User(
            FirstName = 'Empty',
            LastName = 'User',
            Alias = 'euser',
            Username = 'emptyuser@example.com.test',
            Email = 'empty@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u2;

        System.runAs(u2) {
            Test.startTest();
            List<ClaimsAdjusterController.ClaimWrapper> results =
                ClaimsAdjusterController.getAssignedClaims();
            Test.stopTest();

            System.assertEquals(0, results.size(), 'Should return empty list for user with no claims');
        }
    }

    @isTest
    static void testClaimWrapperDaysOpenCalculation() {
        User u = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        System.runAs(u) {
            // Create a claim with known date of loss
            Id policyRT = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName()
                .get('Auto')
                .getRecordTypeId();
            Id claimRT = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName()
                .get('Accident')
                .getRecordTypeId();

            Contact con = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];
            Policy__c policy = [SELECT Id FROM Policy__c WHERE Customer__c = :con.Id LIMIT 1];

            Claim__c claim = new Claim__c(
                Policy__c = policy.Id,
                RecordTypeId = claimRT,
                Claim_Amount__c = 10000,
                Date_of_Loss__c = DateTime.now().addDays(-15),
                OwnerId = u.Id
            );
            insert claim;

            Test.startTest();
            List<ClaimsAdjusterController.ClaimWrapper> results =
                ClaimsAdjusterController.getAssignedClaims();
            Test.stopTest();

            ClaimsAdjusterController.ClaimWrapper wrap = results[0];
            System.assertEquals(15, wrap.daysOpen, 'Days open should match difference from today');
        }
    }

    @isTest
    static void testClaimWrapperNullDateOfLoss() {
        User u = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
        System.runAs(u) {
            Id policyRT = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName()
                .get('Life')
                .getRecordTypeId();
            Id claimRT = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName()
                .get('Life')
                .getRecordTypeId();

            Contact con = new Contact(FirstName = 'Bob', LastName = 'Wilson', OwnerId = u.Id);
            insert con;

            Policy__c policy = new Policy__c(
                Customer__c = con.Id,
                RecordTypeId = policyRT,
                OwnerId = u.Id,
                Beneficiary_Name__c = 'Jane Wilson',
                Policy_Term_Months__c = 240
            );
            insert policy;

            Claim__c claim = new Claim__c(
                Policy__c = policy.Id,
                RecordTypeId = claimRT,
                Claim_Amount__c = 100000,
                Date_of_Loss__c = null,
                OwnerId = u.Id
            );
            insert claim;

            Test.startTest();
            List<ClaimsAdjusterController.ClaimWrapper> results =
                ClaimsAdjusterController.getAssignedClaims();
            Test.stopTest();

            ClaimsAdjusterController.ClaimWrapper wrap = results[results.size() - 1];
            System.assertEquals(0, wrap.daysOpen, 'Days open should be 0 when Date of Loss is null');
        }
    }
}