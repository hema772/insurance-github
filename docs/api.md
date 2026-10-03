# Apex API Reference

## PremiumCalculator

### calculatePremium
```apex
@InvocableMethod(label='Calculate Premium' description='Calculates premium for Auto/Property/Life policies')
public static List<PremiumResult> calculatePremium(List<PremiumRequest> requests)
```

#### PremiumRequest
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `policyType` | String | Yes | 'Auto', 'Property', or 'Life' |
| `state` | String | Yes | State code (CA, TX, NY, FL, Other) |
| `modelYear` | Integer | Auto only | Vehicle model year |
| `squareFootage` | Integer | Property only | Property square footage |
| `yearBuilt` | Integer | Property only | Property construction year |
| `policyTermMonths` | Integer | Life only | Policy term in months |
| `basePremium` | Decimal | No | Base premium override |

#### PremiumResult
| Property | Type | Description |
|----------|------|-------------|
| `premium` | Decimal | Calculated premium amount |
| `adjustmentFactor` | Decimal | Applied adjustment factor |
| `messages` | List<String> | Calculation details/warnings |

#### Example Flow Usage
```xml
<!-- In Flow: Action Element -->
<!-- Action: PremiumCalculator -->
<!-- Inputs: policyType={!varPolicyType}, state={!Customer_Info.Policy_State__c} -->
<!-- Output: {!varPremiumResult} -->
```

---

## ClaimsAdjusterController

### getAssignedClaims
```apex
@AuraEnabled(cacheable=true)
public static List<ClaimWrapper> getAssignedClaims()
```

Returns claims assigned to the current user or their queues.

#### ClaimWrapper
| Property | Type | Description |
|----------|------|-------------|
| `claimId` | Id | Claim__c record Id |
| `claimNumber` | String | Claim auto-number (C-{0000}) |
| `claimAmount` | Decimal | Claim amount |
| `status` | String | Approval_Status__c value |
| `policyType` | String | Policy RecordType DeveloperName |
| `policyHolderName` | String | Contact.Name from Policy__c.Customer__c |
| `daysOpen` | Integer | Days since Date_of_Loss__c |

#### LWC Usage
```javascript
// claimsDashboardLwc.js
import getAssignedClaims from '@salesforce/apex/ClaimsAdjusterController.getAssignedClaims';

@wire(getAssignedClaims)
wiredClaims({ error, data }) {
    if (data) {
        this.claims = data;
        this.filterClaims();
    }
}
```

---

## Test Classes

### ClaimsAdjusterControllerTest

Run all tests:
```bash
sf test run local --class ClaimsAdjusterControllerTest --target-org <alias> --code-coverage
```

Test Methods:
| Method | Coverage Target |
|--------|-----------------|
| `testGetAssignedClaims` | Claims returned for assigned adjuster |
| `testGetAssignedClaims_FilterByPolicyType` | Auto/Property/Life filtering |
| `testGetAssignedClaims_EmptyResults` | No assigned claims |
| `testGetAssignedClaims_WithSharing` | Sharing rules enforced |
| `testGetAssignedClaims_BulkQueries` | Bulk query performance |
| `testGetAssignedClaims_QueueAssignment` | Queue-based assignment |
| `testGetAssignedClaims_ApprovalStatus` | Status filter accuracy |

---

---

## Flow Automation Reference

### Claim_Routing_Flow
**Type**: Record-Triggered Flow
**Object**: `Claim__c`
**Trigger**: A record is created
**Conditions**: None (fires on all new claims)
**Entry Criteria**: `ISNEW() = true`
**Output**: Assigns claim to one of three public queues based on related Policy's RecordType DeveloperName

#### Queue Routing Logic
| Policy RecordType | Queue Name | DeveloperName |
|---|---|---|
| Auto | Auto_Claims_Queue | Auto_Claims_Queue |
| Property | Property_Claims_Queue | Property_Claims_Queue |
| Life | Life_Claims_Queue | Life_Claims_Queue |

#### Flow Variables
| Variable | Type | Is Collection | Description |
|---|---|---|---|
| `{!varPolicyRecordType}` | Text | No | DeveloperName of the Policy's RecordType |
| `{!varClaimId}` | Record ID | No | ID of the newly created Claim__c |

#### Debug Logging
Enable debug logs for the running user and filter by `FLOW` to trace routing decisions.

---

### Submission_Automation_Flow
**Type**: Record-Triggered Flow
**Object**: `Claim__c`
**Trigger**: A record is created or updated
**Conditions**: `Claim_Amount__c > 50000`
**Entry Criteria**: `AND(ISCHANGED([Claim__c].Claim_Amount__c), [Claim__c].Claim_Amount__c > 50000)`
**Output**: Submits the claim record to the `High_Value_Claim_Approval` approval process

#### Subflow: Auto-Submission Logic
```text
IF Claim__c.Claim_Amount__c > 50000 AND Claim__c.Approval_Status__c != "Submitted"
THEN
    Submit for Approval: High_Value_Claim_Approval
    Update Approval_Status__c = "Submitted"
ELSE
    Skip (not high-value or already submitted)
```

#### Monitoring
- Check `Setup > Process Automation > Paused and Failed Flow Interviews` for stalled submissions
- Approval history is visible on the Claim record detail page under "Approvals" related list

---

## Error Handling

All Apex methods follow this pattern:
```apex
try {
    // Business logic
    return result;
} catch (Exception e) {
    throw new AuraHandledException('User-friendly message: ' + e.getMessage());
}
```

LWC error handling:
```javascript
@wire(getAssignedClaims)
wiredClaims({ error, data }) {
    if (error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error loading claims',
            message: error.body.message,
            variant: 'error'
        }));
    }
}
```