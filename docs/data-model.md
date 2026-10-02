# Data Model Documentation

## Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│     Contact     │       │    Policy__c    │       │    Claim__c     │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ Id (PK)         │◄──────│ Customer__c     │       │ Id (PK)         │
│ FirstName       │       │ (Lookup)        │       │ Policy__c       │
│ LastName        │       ├─────────────────┤       │ (Lookup)        │
│ Email           │       │ Name (Auto#)    │◄──────│ Adjuster__c     │
│ Phone           │       │ RecordTypeId    │       │ (Lookup User)   │
└─────────────────┘       │ Policy_Start_Date__c       ├─────────────────┤
                          │ Policy_Term_Months__c      │ Claim_Amount__c │
           ┌──────────────┤ Premium__c                 │ Date_of_Loss__c │
           │              │ Policy_State__c (Picklist) │ Description__c  │
           │              │ VIN__c                     │ Approval_Status__c│
           │              │ Model_Year__c              │ RecordTypeId    │
           │              │ Square_Footage__c          └────────┬────────┘
           │              │ Year_Built__c                   │
           │              │ Beneficiary_Name__c             │
           │              │ Policy_Term_Months__c           │
           └──────────────┴─────────────────────────────────┘
```

## Policy__c Object

### Fields

| API Name | Label | Type | Required | Description |
|----------|-------|------|----------|-------------|
| `Name` | Policy Number | AutoNumber | Yes | Format: `P-{0000}` |
| `Customer__c` | Customer | Lookup(Contact) | Yes | Policy holder |
| `Policy_Start_Date__c` | Policy Start Date | Date | Yes | Policy effective date |
| `Policy_Term_Months__c` | Policy Term (Months) | Number | Yes | Term length (Life only) |
| `Premium__c` | Premium | Currency | No | Calculated by PremiumCalculator |
| `Policy_State__c` | Policy State | Picklist | Yes | CA, TX, NY, FL, Other |
| `VIN__c` | VIN | Text(17) | Auto only | 17-char validation rule |
| `Model_Year__c` | Model Year | Number | Auto only | Vehicle year |
| `Square_Footage__c` | Square Footage | Number | Property only | Property size |
| `Year_Built__c` | Year Built | Number | Property only | Construction year |
| `Beneficiary_Name__c` | Beneficiary Name | Text | Life only | Life policy beneficiary |

### Record Types

| Record Type | Developer Name | Description | Field Set |
|-------------|----------------|-------------|-----------|
| Auto Policy | Auto | Vehicle insurance | Vehicle_Fields |
| Property Policy | Property | Home/property insurance | Property_Fields |
| Life Policy | Life | Life insurance | Life_Fields |

### Field Sets

| Field Set | API Name | Fields |
|-----------|----------|--------|
| Vehicle Details | Vehicle_Fields | VIN__c, Model_Year__c |
| Property Details | Property_Fields | Square_Footage__c, Year_Built__c |
| Life Details | Life_Fields | Beneficiary_Name__c, Policy_Term_Months__c |

### Validation Rules

| Name | Error Condition | Error Message |
|------|-----------------|---------------|
| VIN_Must_Be_17_Characters | `AND(RecordType.DeveloperName="Auto", LEN(VIN__c) <> 17)` | VIN must be exactly 17 characters for Auto policies |

---

## Claim__c Object

### Fields

| API Name | Label | Type | Required | Description |
|----------|-------|------|----------|-------------|
| `Name` | Claim Number | AutoNumber | Yes | Format: `C-{0000}` |
| `Policy__c` | Policy | Lookup(Policy__c) | Yes | Related policy |
| `Adjuster__c` | Adjuster | Lookup(User) | No | Assigned adjuster |
| `Claim_Amount__c` | Claim Amount | Currency | Yes | Claim value |
| `Date_of_Loss__c` | Date of Loss | Date | Yes | Incident date |
| `Description__c` | Description | Long Text | Yes | Claim details |
| `Approval_Status__c` | Approval Status | Picklist | Yes | New, Submitted for Approval, Approved, Rejected |
| `Policy_Account_Holder_State__c` | Policy Holder State | Formula(Text) | No | `Policy__r.Policy_State__c` (for sharing) |

### Record Types

| Record Type | Developer Name | Description |
|-------------|----------------|-------------|
| Accident Claim | Accident | Auto policy claims |
| Property Claim | Property | Property policy claims |
| Life Claim | Life | Life policy claims |

### Approval Status Picklist Values

| Value | API Name | Description |
|-------|----------|-------------|
| New | New | Initial claim state |
| Submitted for Approval | Submitted_for_Approval | Auto-set when >$50K |
| Approved | Approved | Final approval |
| Rejected | Rejected | Final rejection |

---

## Queues & Groups

| Name | Type | Supports | Purpose |
|------|------|----------|---------|
| Auto_Claims_Queue | Queue | Claim__c | Auto claim routing |
| Property_Claims_Queue | Queue | Claim__c | Property claim routing |
| Life_Claims_Queue | Queue | Claim__c | Life claim routing |
| Senior_Adjuster_Queue | Queue | Claim__c | First approval step |
| Dept_Manager_Queue | Queue | Claim__c | Final approval step |
| All_Adjusters_Group | Public Group | Claim__c | Sharing rule target |

---

## Permission Sets

### Insurance_Agent_Access
- **Objects**: Policy__c (CRUD), Contact (CRUD)
- **Apex**: PremiumCalculator
- **Purpose**: Create policies only

### Claims_Adjuster_Access
- **Objects**: Policy__c (R), Claim__c (RUE), Contact (RUE)
- **Apex**: PremiumCalculator, ClaimsAdjusterController
- **User Permissions**: ViewSetup, ViewRoles
- **Purpose**: Handle claims, view dashboard

### Claims_Manager_Access
- **Objects**: Policy__c (R, ViewAll), Claim__c (CRUD, ViewAll), Contact (RUE, ViewAll)
- **Apex**: PremiumCalculator, ClaimsAdjusterController
- **User Permissions**: ViewSetup, ViewRoles, RunReports
- **Purpose**: Full access, approvals, reporting

---

## Sharing Rules (Claim__c)

| Rule Name | Criteria | Shared With | Access |
|-----------|----------|-------------|--------|
| Share_CA_Claims | `Policy__r.Policy_State__c = CA` | All_Adjusters_Group | Read/Write |
| Share_TX_Claims | `Policy__r.Policy_State__c = TX` | All_Adjusters_Group | Read/Write |
| Share_NY_Claims | `Policy__r.Policy_State__c = NY` | All_Adjusters_Group | Read/Write |
| Share_FL_Claims | `Policy__r.Policy_State__c = FL` | All_Adjusters_Group | Read/Write |
| Share_Other_Claims | `Policy__r.Policy_State__c = Other` | All_Adjusters_Group | Read/Write |

---

## Apex Classes

### PremiumCalculator
```apex
public with sharing class PremiumCalculator {
    @InvocableMethod(label='Calculate Premium' description='Calculates premium for Auto/Property/Life')
    public static List<PremiumResult> calculatePremium(List<PremiumRequest> requests) { ... }
}
```

**Inputs**: `policyType`, `state`, `modelYear`, `squareFootage`, `yearBuilt`, `policyTermMonths`, `basePremium`
**Output**: `premium`, `adjustmentFactor`, `messages`

### ClaimsAdjusterController
```apex
public with sharing class ClaimsAdjusterController {
    @AuraEnabled(cacheable=true)
    public static List<ClaimWrapper> getAssignedClaims() { ... }

    public class ClaimWrapper {
        @AuraEnabled public Id claimId;
        @AuraEnabled public String claimNumber;
        @AuraEnabled public Decimal claimAmount;
        @AuraEnabled public String status;
        @AuraEnabled public String policyType;
        @AuraEnabled public String policyHolderName;
        @AuraEnabled public Integer daysOpen;
    }
}
```

---

## Flow API Names

| Flow Label | API Name | Type |
|------------|----------|------|
| AutoQuoting | AutoQuoting | Screen Flow |
| Claim Routing | Claim_Routing_Flow | Record-Triggered |
| Submission Automation | Submission_Automation_Flow | Record-Triggered |
| Claim Approver Screen | Claim_Approver_Screen_Flow | Screen Flow |

---

## Approval Process

**Name**: High_Value_Claim_Approval
**Object**: Claim__c
**Entry Criteria**: `Claim_Amount__c > 50000`

| Step | Assigned To | Actions |
|------|-------------|---------|
| 1 | Senior_Adjuster_Queue | Approve → Next Step; Reject → Final Rejection |
| 2 | Dept_Manager_Queue | Approve → Final Approval; Reject → Final Rejection |

**Field Updates**:
- Initial Submission: `Approval_Status__c = 'Submitted for Approval'`
- Step 1 Approve: `Approval_Status__c = 'Approved'`
- Step 1 Reject: `Approval_Status__c = 'Rejected'`
- Step 2 Approve: `Approval_Status__c = 'Approved'`
- Step 2 Reject: `Approval_Status__c = 'Rejected'`