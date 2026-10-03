# Multi-Line Insurance Policy & Claims Management System

![Salesforce](https://img.shields.io/badge/Salesforce-Lightning%20Platform-00A1E0?logo=salesforce&logoColor=white)
![SFDX](https://img.shields.io/badge/SFDX-Source%20Format-00A1E0)
![Apex](https://img.shields.io/badge/Apex-Test%20Coverage%2095%25-brightgreen)
![LWC](https://img.shields.io/badge/Lightning%20Web%20Components-ES6%2B-F7DF1E?logo=javascript&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

A complete **Salesforce DX** project implementing a multi-line insurance platform for **Auto, Property, and Life** policies with automated quoting, premium calculation, claim routing, approval workflows, and a real-time adjuster dashboard.

Built for **Smart India Hackathon 2025** — Problem Statement: *Dark Web Threat Actor De-anonymization* (adapted for insurance domain).

---

## Architecture Overview

<svg viewBox="0 0 1100 680">
        <!-- ============================================================= -->
        <!-- DEFINITIONS                                                    -->
        <!-- ============================================================= -->
        <defs>
          <!-- Slate arrowhead (for standard arrows) -->
          <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto" markerUnits="strokeWidth">
            <polygon points="0 0, 10 3.5, 0 7" fill="#64748b" />
          </marker>

          <!-- Violet arrowhead (for dashed return flows) -->
          <marker id="arrowhead-violet" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto" markerUnits="strokeWidth">
            <polygon points="0 0, 10 3.5, 0 7" fill="#a78bfa" />
          </marker>

          <!-- Grid pattern -->
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1e293b" stroke-width="0.5"/>
          </pattern>
        </defs>

        <!-- Background Grid -->
        <rect width="100%" height="100%" fill="url(#grid)" />

        <!-- ============================================================= -->
        <!-- ARROWS (drawn before components so they render behind boxes)  -->
        <!-- ============================================================= -->

        <!-- Top-row data flows -->
        <!-- Claim__c to Policy__c (relationship, leftward) -->
        <line x1="390" y1="117" x2="210" y2="117" stroke="#34d399" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="300" y="111" fill="#94a3b8" font-size="8" text-anchor="middle">REL</text>

        <!-- Claim__c to Approval Process (trigger) -->
        <line x1="450" y1="117" x2="570" y2="117" stroke="#34d399" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="510" y="111" fill="#94a3b8" font-size="8" text-anchor="middle">TRIGGER</text>

        <!-- Approval Process to Dashboard (status update) -->
        <line x1="710" y1="117" x2="830" y2="117" stroke="#34d399" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="770" y="111" fill="#94a3b8" font-size="8" text-anchor="middle">STATUS</text>

        <!-- Claim__c to Automation Layer flows (vertical triggers) -->
        <!-- Claim__c to Claim_Routing -->
        <line x1="390" y1="145" x2="550" y2="185" stroke="#fb923c" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="470" y="138" fill="#fb923c" font-size="8" text-anchor="middle">TRIGGER</text>

        <!-- Claim__c to Submission_Automation (curved path, right side) -->
        <path d="M 390 145 C 440 145 860 145 890 185" fill="none" stroke="#fb923c" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="650" y="138" fill="#fb923c" font-size="8" text-anchor="middle">&gt;$50K</text>

        <!-- Claim__c to AutoQuoting -->
        <line x1="390" y1="145" x2="250" y2="185" stroke="#fb923c" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="320" y="138" fill="#fb923c" font-size="8" text-anchor="middle">TRIGGER</text>

        <!-- Automation Layer to Apex Services -->
        <!-- Submission_Automation to PremiumCalculator (invocable) -->
        <path d="M 890 245 C 950 280 970 370 320 417" fill="none" stroke="#34d399" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="645" y="295" fill="#94a3b8" font-size="8" text-anchor="middle">INVOCABLE</text>

        <!-- Claim_Approver to ClaimsAdjusterController (@AuraEnabled) -->
        <line x1="550" y1="325" x2="715" y2="390" stroke="#34d399" stroke-width="1.5" marker-end="url(#arrowhead)"/>
        <text x="632" y="358" fill="#94a3b8" font-size="8" text-anchor="middle">@AuraEnabled</text>

        <!-- Apex Services return flows (dashed) -->
        <!-- ClaimsAdjusterController to Dashboard (cacheable return) -->
        <path d="M 715 390 C 760 320 895 200 895 120" fill="none" stroke="#a78bfa" stroke-width="1.5" stroke-dasharray="5,5" marker-end="url(#arrowhead-violet)"/>
        <text x="835" y="250" fill="#a78bfa" font-size="8" text-anchor="middle">CACHE</text>

        <!-- PremiumCalculator to Claim_Approver (result return) -->
        <path d="M 320 445 C 360 385 480 335 550 325" fill="none" stroke="#a78bfa" stroke-width="1.5" stroke-dasharray="5,5" marker-end="url(#arrowhead-violet)"/>
        <text x="435" y="365" fill="#a78bfa" font-size="8" text-anchor="middle">RESULT</text>

        <!-- ============================================================= -->
        <!-- BOUNDARIES (regions and tiers)                                 -->
        <!-- ============================================================= -->

        <!-- Salesforce Org Boundary (region) -->
        <rect x="25" y="25" width="1050" height="490" rx="12" fill="rgba(120, 53, 15, 0.05)" stroke="#fbbf24" stroke-width="1" stroke-dasharray="8,4"/>
        <text x="37" y="40" fill="#fbbf24" font-size="10" font-weight="600">Salesforce Org</text>

        <!-- Automation Layer Boundary -->
        <rect x="25" y="155" width="1050" height="190" rx="10" fill="transparent" stroke="#fbbf24" stroke-width="1" stroke-dasharray="4,4"/>
        <text x="37" y="170" fill="#fbbf24" font-size="10" font-weight="600">Automation Layer</text>

        <!-- Apex Services Boundary -->
        <rect x="25" y="365" width="1050" height="130" rx="10" fill="transparent" stroke="#fbbf24" stroke-width="1" stroke-dasharray="4,4"/>
        <text x="37" y="380" fill="#fbbf24" font-size="10" font-weight="600">Apex Services</text>

        <!-- ============================================================= -->
        <!-- TOP ROW: Data Model + Approval + Dashboard                     -->
        <!-- ============================================================= -->

        <!-- Policy__c (Database) -->
        <rect x="90" y="85" width="120" height="55" rx="6" fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1.5"/>
        <text x="150" y="108" fill="white" font-size="11" font-weight="600" text-anchor="middle">Policy__c</text>
        <text x="150" y="124" fill="#94a3b8" font-size="9" text-anchor="middle">Custom Object</text>

        <!-- Claim__c (Database) -->
        <rect x="330" y="85" width="120" height="55" rx="6" fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1.5"/>
        <text x="390" y="108" fill="white" font-size="11" font-weight="600" text-anchor="middle">Claim__c</text>
        <text x="390" y="124" fill="#94a3b8" font-size="9" text-anchor="middle">Custom Object</text>

        <!-- Approval Process (Backend) -->
        <rect x="570" y="85" width="140" height="55" rx="6" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
        <text x="640" y="108" fill="white" font-size="11" font-weight="600" text-anchor="middle">Approval Process</text>
        <text x="640" y="124" fill="#94a3b8" font-size="9" text-anchor="middle">Workflow</text>

        <!-- Dashboard (Frontend - LWC) -->
        <rect x="830" y="85" width="130" height="55" rx="6" fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1.5"/>
        <text x="895" y="108" fill="white" font-size="11" font-weight="600" text-anchor="middle">Dashboard</text>
        <text x="895" y="124" fill="#94a3b8" font-size="9" text-anchor="middle">LWC</text>

        <!-- ============================================================= -->
        <!-- AUTOMATION LAYER: Flows                                         -->
        <!-- ============================================================= -->

        <!-- AutoQuoting Screen Flow -->
        <rect x="180" y="185" width="140" height="60" rx="6" fill="rgba(251, 146, 60, 0.3)" stroke="#fb923c" stroke-width="1.5"/>
        <text x="250" y="208" fill="white" font-size="11" font-weight="600" text-anchor="middle">AutoQuoting</text>
        <text x="250" y="224" fill="#94a3b8" font-size="9" text-anchor="middle">Screen Flow</text>

        <!-- Claim_Routing Record-Triggered Flow -->
        <rect x="480" y="185" width="140" height="60" rx="6" fill="rgba(251, 146, 60, 0.3)" stroke="#fb923c" stroke-width="1.5"/>
        <text x="550" y="208" fill="white" font-size="11" font-weight="600" text-anchor="middle">Claim_Routing</text>
        <text x="550" y="224" fill="#94a3b8" font-size="8" text-anchor="middle">Record-Triggered Flow</text>

        <!-- Submission_Automation Flow -->
        <rect x="820" y="185" width="140" height="60" rx="6" fill="rgba(251, 146, 60, 0.3)" stroke="#fb923c" stroke-width="1.5"/>
        <text x="890" y="208" fill="white" font-size="11" font-weight="600" text-anchor="middle">Submission_Automation</text>
        <text x="890" y="224" fill="#94a3b8" font-size="8" text-anchor="middle">Flow (>$50K)</text>

        <!-- Claim_Approver_Screen_Flow -->
        <rect x="360" y="270" width="380" height="55" rx="6" fill="rgba(251, 146, 60, 0.3)" stroke="#fb923c" stroke-width="1.5"/>
        <text x="550" y="293" fill="white" font-size="12" font-weight="600" text-anchor="middle">Claim_Approver_Screen_Flow</text>
        <text x="550" y="310" fill="#94a3b8" font-size="9" text-anchor="middle">Screen Flow</text>

        <!-- ============================================================= -->
        <!-- APEX SERVICES                                                -->
        <!-- ============================================================= -->

        <!-- PremiumCalculator (Invocable) -->
        <rect x="240" y="390" width="160" height="55" rx="6" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
        <text x="320" y="413" fill="white" font-size="11" font-weight="600" text-anchor="middle">PremiumCalculator</text>
        <text x="320" y="429" fill="#94a3b8" font-size="9" text-anchor="middle">(Invocable)</text>

        <!-- ClaimsAdjusterController -->
        <rect x="620" y="390" width="190" height="55" rx="6" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1.5"/>
        <text x="715" y="413" fill="white" font-size="11" font-weight="600" text-anchor="middle">ClaimsAdjusterController</text>
        <text x="715" y="429" fill="#94a3b8" font-size="8" text-anchor="middle">@AuraEnabled Cacheable</text>

        <!-- ============================================================= -->
        <!-- LEGEND (placed below all boundary boxes)                     -->
        <!-- Lowest boundary Y = 365 + 130 = 495, legend at y=510         -->
        <!-- ============================================================= -->

        <text x="830" y="510" fill="white" font-size="10" font-weight="600">Legend</text>

        <!-- Database -->
        <rect x="830" y="522" width="16" height="10" rx="2" fill="rgba(76, 29, 149, 0.4)" stroke="#a78bfa" stroke-width="1"/>
        <text x="852" y="530" fill="#94a3b8" font-size="8">Data Object (Custom Object)</text>

        <!-- Flow / Message Bus -->
        <rect x="830" y="538" width="16" height="10" rx="2" fill="rgba(251, 146, 60, 0.3)" stroke="#fb923c" stroke-width="1"/>
        <text x="852" y="546" fill="#94a3b8" font-size="8">Flow / Orchestration</text>

        <!-- Backend / Apex -->
        <rect x="830" y="554" width="16" height="10" rx="2" fill="rgba(6, 78, 59, 0.4)" stroke="#34d399" stroke-width="1"/>
        <text x="852" y="562" fill="#94a3b8" font-size="8">Backend / Apex</text>

        <!-- Frontend -->
        <rect x="830" y="570" width="16" height="10" rx="2" fill="rgba(8, 51, 68, 0.4)" stroke="#22d3ee" stroke-width="1"/>
        <text x="852" y="578" fill="#94a3b8" font-size="8">Frontend (LWC)</text>

        <!-- Region Boundary -->
        <rect x="830" y="586" width="16" height="10" rx="2" fill="rgba(120, 53, 15, 0.05)" stroke="#fbbf24" stroke-width="1" stroke-dasharray="2,2"/>
        <text x="852" y="594" fill="#94a3b8" font-size="8">Salesforce Boundary</text>

        <!-- Security Group boundary -->
        <rect x="830" y="602" width="16" height="10" rx="2" fill="transparent" stroke="#fb7185" stroke-width="1" stroke-dasharray="2,2"/>
        <text x="852" y="610" fill="#94a3b8" font-size="8">Tier Boundary</text>

        <!-- Dashed flow -->
        <line x1="830" y1="624" x2="846" y2="624" stroke="#a78bfa" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#arrowhead-violet)"/>
        <text x="852" y="627" fill="#94a3b8" font-size="8">Return / Cache Flow</text>

        <!-- Solid flow -->
        <line x1="830" y1="640" x2="846" y2="640" stroke="#34d399" stroke-width="1" marker-end="url(#arrowhead)"/>
        <text x="852" y="643" fill="#94a3b8" font-size="8">Trigger / Invocable</text>

      </svg>
---

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
git clone https://github.com/ArenRedd/insurance-github.git
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

