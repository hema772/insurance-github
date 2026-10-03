# Multi-Line Insurance Policy & Claims Management System

![Salesforce](https://img.shields.io/badge/Salesforce-Lightning%20Platform-00A1E0?logo=salesforce&logoColor=white)
![SFDX](https://img.shields.io/badge/SFDX-Source%20Format-00A1E0)
![Apex](https://img.shields.io/badge/Apex-Test%20Coverage%2095%25-brightgreen)
![LWC](https://img.shields.io/badge/Lightning%20Web%20Components-ES6%2B-F7DF1E?logo=javascript&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

A complete **Salesforce DX** project implementing a multi-line insurance platform for **Auto, Property, and Life** policies with automated quoting, premium calculation, claim routing, approval workflows, and a real-time adjuster dashboard.


---

## Architecture Overview

![Salesforce Claims Automation Flowchart](docs/Salesforce%20Claims%20Automation%20Flowchart.png)

## Features by Milestone

### 🏗️ Milestone 1: Core Data Model
| Component | Details |
|-----------|---------|
| **Policy__c** | Auto-number `P-{0000}`, 10 custom fields, 3 record types (Auto/Property/Life), 3 field sets, VIN validation (17 chars) |
| **Claim__c** | Auto-number `C-{0000}`, 6 custom fields, 3 record types (Accident/Property/Life), Approval Status picklist |
| **Relationships** | Policy__c → Contact (Customer), Claim__c → Policy__c (Lookup), Claim__c → User (Adjuster) |

### ⚡ Milestone 2: Policy Issuance & Claim Routing
| Component | Type | Description |
|-----------|------|-------------|
| **AutoQuoting** | Screen Flow | Dynamic screens per policy type; creates Contact + Policy__c with correct RecordType |
| **PremiumCalculator** | Apex (Invocable) | State-based rates (CA/TX/NY/FL/Other), model year adjustment, property age factor |
| **Claim_Routing_Flow** | Record-Triggered Flow | Routes new claims to `Auto_Claims_Queue`, `Property_Claims_Queue`, `Life_Claims_Queue` by Policy RecordType |

### 📊 Milestone 3: Claims Adjuster Dashboard
| Component | Type | Features |
|-----------|------|----------|
| **ClaimsAdjusterController** | Apex | `@AuraEnabled(cacheable=true)` `getAssignedClaims()` → `List<ClaimWrapper>` |
| **claimsDashboardLwc** | LWC (Parent) | Policy type filter (All/Auto/Property/Life), `@wire` to Apex, client-side filtering |
| **claimTileLwc** | LWC (Child) | Reusable tile: policy icon (🚗/🏠/👤), claim amount, status badge, days open |

### 🔐 Milestone 4: Approvals, Security & Testing
| Component | Type | Details |
|-----------|------|---------|
| **High_Value_Claim_Approval** | Approval Process | 2-step: Senior Adjuster Queue → Dept Manager Queue; entry criteria `Claim_Amount__c > 50000` |
| **Submission_Automation_Flow** | Record-Triggered Flow | Auto-submits claims >$50K to approval process |
| **Claim_Approver_Screen_Flow** | Screen Flow | Approver UI: Approve/Reject radio, required comments on reject |
| **Approve_Reject_Claim** | Quick Action | Flow-based action on Claim record page |
| **ClaimsAdjusterControllerTest** | Apex Test | 234 lines, `@testSetup`, 7 test methods, targets 95%+ coverage |
| **Permission Sets** | 3 | Insurance Agent Access, Claims Adjuster Access, Claims Manager Access |
| **Sharing Rules** | 5 | Criteria-based on `Policy__r.Policy_State__c` (CA, TX, NY, FL, Other) |

---

## Quick Start

### Prerequisites
- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli) (`sf` v2.150+)
- [Git](https://git-scm.com/)
- Salesforce Developer Edition or Dev Hub org

### Local Development Setup

```bash
# Clone repository
cd insurance-github

# Authenticate to your org
sf org login web --alias insurance-org

# Deploy all metadata
sf project deploy start --target-org insurance-org

# Run tests
sf test run local --target-org insurance-org
```

### Verify Deployment

1. **AutoQuoting Flow** → App Launcher → *AutoQuoting* → Create Auto Policy (VIN: `1HGCM82633A123456`)
2. **Create Claim** on that Policy → Amount: `60000` → Save → Verify `Approval_Status__c = Submitted for Approval`
3. **Approve/Reject Claim** button → Approve → Status = `Approved`
4. **Claims Dashboard** → App Launcher → *Claims Dashboard* → Add to Lightning Page
5. **Permission Sets** → Setup → Permission Sets → Assign to users

---

## Project Structure

```
insurance-github/
├── .github/
│   ├── workflows/           # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/      # Bug report, feature request
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   ├── architecture.md      # Detailed architecture decisions
│   ├── data-model.md        # ERD and field definitions
│   ├── flows.md             # Flow documentation
│   └── api.md               # Apex method signatures
├── force-app/
│   └── main/
│       └── default/
│           ├── objects/           # Policy__c, Claim__c
│           ├── flows/             # 4 Flow definitions
│           ├── approvalProcesses/ # High_Value_Claim_Approval
│           ├── quickActions/      # Approve_Reject_Claim
│           ├── permissionSets/    # 3 permission sets
│           ├── classes/           # 3 Apex classes + test
│           ├── lwc/               # 2 LWC components
│           └── sharingRules/      # 5 criteria-based rules
├── .forceignore              # SFDX ignore patterns
├── .gitignore                # Git ignore patterns
├── sfdx-project.json         # Project config (API v63.0)
├── DEPLOYMENT_STATUS.md      # Milestone tracking
├── CONTRIBUTING.md           # Contribution guidelines
├── CODE_OF_CONDUCT.md        # Community standards
├── LICENSE                   # MIT License
└── README.md                 # This file
```

---

## CI/CD Pipeline

### GitHub Actions (`.github/workflows/ci.yml`)

```yaml
# Runs on every push/PR:
# 1. Validate sfdx-project.json
# 2. Deploy to scratch org
# 3. Run Apex tests (min 75% coverage)
# 4. Run LWC tests (if configured)
# 5. Static analysis (PMD/ApexScanner)
```

```bash
# Trigger manually
gh workflow run ci.yml
```

### Environments

| Environment | Purpose | Branch |
|-------------|---------|--------|
| **Development** | Feature validation | `feature/*` |
| **Staging** | Integration testing | `develop` |
| **Production** | Release | `main` |

---

## Testing Strategy

```bash
# All tests
sf test run local --target-org insurance-org --code-coverage --result-format human

# Specific class
sf test run local --class ClaimsAdjusterControllerTest --target-org insurance-org

# Coverage report
sf test run local --target-org insurance-org --code-coverage --result-format json | jq '.result.coverage'
```

### Coverage Targets
| Metric | Target |
|--------|--------|
| **Overall** | ≥ 75% (Salesforce minimum) |
| **Apex Classes** | ≥ 90% |
| **Critical Paths** | 100% (PremiumCalculator, Approval logic) |

---

## Security

- **OWD**: Policy__c (Private), Claim__c (Private)
- **Sharing**: Criteria-based rules by `Policy_State__c`
- **Permission Sets**: Least-privilege access (Agent/Adjuster/Manager)
- **Field-Level Security**: Configured per permission set
- **Apex**: `with sharing` enforced on all controllers

---

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'feat: add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

MIT License — see [LICENSE](LICENSE) for details.


## 📋 Deployment Checklist

Before deploying to production, verify the following:

### Pre-Deployment Checks
- [ ] All Apex tests pass (target 95%+ coverage)
- [ ] All flows are active and tested
- [ ] Permission sets are configured correctly
- [ ] Sharing rules are in place and tested
- [ ] Approval processes are defined (if required)

### Metadata Deployment
- [ ] Run `sf project deploy start --target-org <org-name>`
- [ ] Deploy only to appropriate sandbox/production
- [ ] Validate all custom fields and objects
- [ ] Check Record Type assignments are correct

### Post-Deployment Validation
- [ ] Test AutoQuoting flow end-to-end
- [ ] Verify PremiumCalculator returns correct values
- [ ] Test claim routing by policy type
- [ ] Confirm adjuster dashboard displays correctly
- [ ] Validate approval process entry criteria

### Security Review
- [ ] Review field-level security on all custom objects
- [ ] Verify profile/permission set assignments
- [ ] Check sharing rule criteria

### Documentation Updates
- [ ] Update README with any configuration changes
- [ ] Ensure API docs reflect current implementations
- [ ] Review and update flow interview labels if changed

---

*Run `sf test run local` to verify test coverage before deployment.*

## 🔧 Troubleshooting Quick Reference

### Common Issues

**AutoQuoting Flow won't launch**
- Check that the flow is active in Setup → Flows
- Verify the Lightning Page assignment is correct
- Ensure the user has the "Insurance Agent" permission set

**PremiumCalculator returns null**
- Validate the policy state is one of: CA, TX, NY, FL, Other
- Check that model year is provided for Auto policies (4-digit number)
- Confirm square footage is provided for Property policies
- Verify policy term in months is provided for Life policies

**Claim not routing to correct queue**
- Check the Policy's RecordType is set correctly (Auto/Property/Life)
- Ensure the Claim_Routing_Flow is triggered on Claim creation
- Verify the three public queues exist and users have access

**Adjuster dashboard shows no claims**
- Confirm the adjuster has "Claims Adjuster Access" permission set
- Verify sharing rules are active for the adjuster's licensed states
- Check that claims have been created and submitted for approval

**Approval process not triggering**
- Ensure the claim amount exceeds $50,000 threshold
- Verify the High_Value_Claim_Approval process is active
- Check that Submission_Automation_Flow is configured correctly

### Debug Steps

1. Run `sf apex log --target-org <org>` to view Apex execution logs
2. Check `Setup > Process Automation > Paused and Failed Flow Interviews`
3. Enable debug logs for the running user, filter by `FLOW` and `APEX`
4. Review `Setup > Managing Apps > Security` for permission set assignments

---

*If issues persist, contact the Claims Administration team or open a GitHub issue.*
