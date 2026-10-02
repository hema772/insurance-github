# Flow Documentation

## Overview
This document describes all Flow definitions in the Multi-Line Insurance system.

---

## 1. AutoQuoting (Screen Flow)
**API Name**: `AutoQuoting`
**Type**: Screen Flow
**Trigger**: Manual (App Launcher / Lightning Page)
**Purpose**: Guided multi-line policy creation

### Flow Structure

```
START
  │
  ▼
┌─────────────────────┐
│ Screen: Policy Type │  ◄── Radio: Auto / Property / Life
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Decision: Route by  │  ◄── 3 Outcomes: Auto, Property, Life
│ Policy Type         │
└─────────┬───────────┘
    ┌─────┴─────┬────────────┐
    ▼           ▼            ▼
┌─────────┐ ┌──────────┐ ┌─────────┐
│ Vehicle │ │ Property │ │  Life   │
│ Details │ │ Details  │ │ Details │
└────┬────┘ └────┬─────┘ └────┬────┘
     │           │            │
     └───────────┼────────────┘
                 ▼
        ┌─────────────────┐
        │ Screen: Customer│  ◄── First/Last/Email/Phone + Policy_State
        │ Info            │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │ Get RecordTypes │  ◄── Query RecordType for Policy__c
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │ Create Contact  │  ◄── Creates Contact from Customer Info
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │ Assignment: Map │  ◄── Map RecordTypeId by policy type
        │ RecordTypeId    │
        └────────┬────────┘
                 │
                 ▼
        ┌─────────────────┐
        │ Create Policy__c│  ◄── All fields + RecordTypeId
        └────────┬────────┘
                 │
                 ▼
               END
```

### Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `varPolicyType` | Text | Stores selected policy type |
| `varRecordTypeId` | Id | Mapped RecordTypeId for Policy__c |
| `varContactId` | Id | Created Contact Id |

### Screen Components

**Policy Type Screen**
- Radio Buttons: `Auto`, `Property`, `Life` (default: Auto)

**Customer Info Screen**
- Text: FirstName (Required)
- Text: LastName (Required)
- Email: Email (Required)
- Phone: Phone
- Picklist: Policy_State__c (Required)

**Vehicle Details Screen** (Auto path)
- Text: VIN (Required, Max 17)
- Number: Model_Year (Required)

**Property Details Screen** (Property path)
- Number: Square_Footage (Required)
- Number: Year_Built (Required)

**Life Details Screen** (Life path)
- Text: Beneficiary_Name (Required)
- Number: Policy_Term_Months (Required)

---

## 2. Claim_Routing_Flow (Record-Triggered Flow)
**API Name**: `Claim_Routing_Flow`
**Type**: Record-Triggered Flow
**Object**: Claim__c
**Trigger**: Created
**Run**: Fast Field Updates

### Flow Structure

```
RECORD CREATED
     │
     ▼
┌─────────────────────┐
│ Get Policy Record   │  ◄── Query Policy__c via Policy__c lookup
│ (Single Record)     │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Decision: Policy    │  ◄── 3 Outcomes by RecordType.DeveloperName
│ RecordType          │
└─────────┬───────────┘
    ┌─────┴─────┬────────────┐
    ▼           ▼            ▼
┌─────────┐ ┌──────────┐ ┌─────────┐
│ Update  │ │ Update   │ │ Update  │
│ OwnerId │ │ OwnerId  │ │ OwnerId │
│ = Auto_ │ │ = Prop_  │ │ = Life_ │
│ Queue   │ │ Queue    │ │ Queue   │
└─────────┘ └──────────┘ └─────────┘
```

### Outcomes

| Outcome | Condition | Action |
|---------|-----------|--------|
| Auto | `{$Get_Policy.PolicyRecord.RecordType.DeveloperName} = 'Auto'` | Update Claim__c OwnerId = `Auto_Claims_Queue` Id |
| Property | `... = 'Property'` | Update OwnerId = `Property_Claims_Queue` Id |
| Life | `... = 'Life'` | Update OwnerId = `Life_Claims_Queue` Id |

---

## 3. Submission_Automation_Flow (Record-Triggered Flow)
**API Name**: `Submission_Automation_Flow`
**Type**: Record-Triggered Flow
**Object**: Claim__c
**Trigger**: Created or Updated
**Condition**: `Claim_Amount__c > 50000`
**Run**: Actions and Related Records

### Flow Structure

```
RECORD CREATED/UPDATED
     │
     ▼
┌─────────────────────┐
│ Condition: Amount   │  ◄── Claim_Amount__c > 50000
│ > 50000             │
└─────────┬───────────┘
          │ Yes
          ▼
┌─────────────────────┐
│ Action: Submit for  │  ◄── Submits to High_Value_Claim_Approval
│ Approval            │
└─────────┬───────────┘
          │
          ▼
        END
```

---

## 4. Claim_Approver_Screen_Flow (Screen Flow)
**API Name**: `Claim_Approver_Screen_Flow`
**Type**: Screen Flow
**Trigger**: Quick Action (Approve/Reject Claim)
**Input**: `recordId` (Claim__c Id)
**Purpose**: Approver UI for High Value Claims

### Flow Structure

```
START
  │
  ▼
┌─────────────────────┐
│ Input Variable:     │  ◄── recordId (Text, Available for Input)
│ recordId            │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Get Claim Record    │  ◄── Query Claim__c by Id = {!recordId}
│ (Single Record)     │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Screen: Review      │  ◄── Display: Claim Number, Amount, Policy Type,
│ Claim               │       Description, Policy Holder State
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Screen: Decision    │  ◄── Radio: Approve / Reject (store in varDecision)
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Screen: Comments    │  ◄── Visible ONLY when varDecision = 'Reject'
│ (Conditional)       │       Long Text: Comments (Required)
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Update Claim__c     │  ◄── Approval_Status__c = 
│ (Record Variable)   │       IF(varDecision='Approve','Approved','Rejected')
└─────────┬───────────┘
          │
          ▼
        END
```

### Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `recordId` | Text (Input) | Claim__c Id from Quick Action |
| `varDecision` | Text | 'Approve' or 'Reject' |
| `varComments` | Text | Rejection comments |

### Screen Components

**Review Claim Screen**
- Display Text: Claim Number (`{$Get_Claim.ClaimRecord.Name}`)
- Display Text: Amount (`{$Get_Claim.ClaimRecord.Claim_Amount__c}`)
- Display Text: Policy Type (`{$Get_Claim.ClaimRecord.Policy__r.RecordType.DeveloperName}`)
- Display Text: Description (`{$Get_Claim.ClaimRecord.Description__c}`)

**Decision Screen**
- Radio Buttons: `Approve`, `Reject` (API: `Decision`)

**Comments Screen** (Conditional Visibility: `{$Decision} = 'Reject'`)
- Long Text: Comments (Required)

---

## Flow Deployment Notes

### Required Setup (Manual)
1. **Queues**: Create 5 queues before deploying flows:
   - `Auto_Claims_Queue`
   - `Property_Claims_Queue`
   - `Life_Claims_Queue`
   - `Senior_Adjuster_Queue`
   - `Dept_Manager_Queue`

2. **Public Group**: Create `All_Adjusters_Group` for sharing rules

3. **Approval Process**: Create `High_Value_Claim_Approval` before deploying Submission_Automation_Flow

### Activation Order
1. Deploy all metadata
2. Activate Approval Process
3. Activate Flows in order: Claim_Routing_Flow → Submission_Automation_Flow → AutoQuoting → Claim_Approver_Screen_Flow
4. Add Quick Action to Claim Page Layout

### Testing Flows
```bash
# Debug in Flow Builder
# 1. Open Flow → Debug → Run
# 2. Set input variables
# 3. Verify path execution
```

---

## Version Control
- All flows in `force-app/main/default/flows/*.flow-meta.xml`
- Changes tracked via Git
- Deploy via SFDX: `sf project deploy start --target-org <alias> --source-dir force-app/main/default/flows`