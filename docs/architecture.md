# Architecture Decisions

## Overview
This document records key architectural decisions for the Multi-Line Insurance Policy & Claims Management System.

## Decision Records

### ADR-001: SFDX Source Format over Metadata API
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Need version control, CI/CD, and team collaboration.
**Decision**: Use SFDX source format with `force-app/main/default` structure.
**Consequences**: Enables scratch orgs, GitOps, and automated testing.

### ADR-002: Record Types for Policy Lines
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Auto, Property, Life policies have different fields.
**Decision**: Use Record Types on Policy__c with Field Sets per type.
**Consequences**: Single object, dynamic UI, simpler reporting.

### ADR-003: Flow-First Automation
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Business logic changes frequently; need admin-maintainable automation.
**Decision**: Use Screen Flows and Record-Triggered Flows over Apex triggers.
**Consequences**: 
- Pros: Declarative, version-controlled, debuggable, admin-friendly
- Cons: Complex logic limited; use Apex for calculations (PremiumCalculator)

### ADR-004: Invocable Apex for Premium Calculation
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Premium logic is mathematical, state-dependent, needs testability.
**Decision**: `@InvocableMethod` in PremiumCalculator called from AutoQuoting Flow.
**Consequences**: Reusable, testable, Flow-integrated.

### ADR-005: LWC Dashboard with @wire
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Real-time adjuster dashboard with filtering.
**Decision**: Parent LWC (`claimsDashboardLwc`) uses `@wire` to Apex; child (`claimTileLwc`) receives data via props.
**Consequences**: Reactive, cacheable, componentized.

### ADR-006: Two-Step Approval Process
**Date**: 2026-10-01
**Status**: Accepted
**Context**: High-value claims (>$50K) need managerial oversight.
**Decision**: Standard Approval Process with 2 steps: Senior Adjuster → Dept Manager.
**Consequences**: Native Salesforce approval routing, email notifications, audit trail.

### ADR-007: Criteria-Based Sharing by State
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Adjusters only handle claims in their licensed states.
**Decision**: Sharing Rules on Claim__c filtered by `Policy__r.Policy_State__c`.
**Consequences**: OWD Private + sharing rules = least privilege.

### ADR-008: Permission Set Strategy
**Date**: 2026-10-01
**Status**: Accepted
**Context**: Three distinct roles with different access needs.
**Decision**: Three Permission Sets (Agent/Adjuster/Manager) assigned via Permission Set Groups.
**Consequences**: Modular, stackable, audit-friendly.

---

## Data Flow Diagram

```
User → AutoQuoting Flow → Contact + Policy__c (with RecordType)
                           ↓
                    PremiumCalculator (Invocable)
                           ↓
                    Policy__c.Premium__c populated

Claim Created → Claim_Routing_Flow → Queue Assignment
                   ↓
         Claim_Amount__c > 50000?
                   ↓
         Yes → Submission_Automation_Flow → High_Value_Claim_Approval
                   ↓
         Senior Adjuster → Dept Manager → Approved/Rejected
                   ↓
         Claim_Approver_Screen_Flow (Quick Action) → Approval_Status__c

Adjuster → Claims Dashboard (LWC) → @wire → ClaimsAdjusterController → ClaimWrapper[]