# Pull Request Template

## Description
<!-- Provide a clear description of the changes in this PR -->

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Test coverage improvement

## Related Issue
<!-- Link to related issue(s) -->
Closes #

## Changes Made
- Change 1
- Change 2
- Change 3

## Components Modified
- [ ] Policy__c object
- [ ] Claim__c object
- [ ] AutoQuoting Flow
- [ ] Claim_Routing_Flow
- [ ] Submission_Automation_Flow
- [ ] Claim_Approver_Screen_Flow
- [ ] High_Value_Claim_Approval Process
- [ ] PremiumCalculator Apex
- [ ] ClaimsAdjusterController Apex
- [ ] claimsDashboardLwc
- [ ] claimTileLwc
- [ ] Approve/Reject Quick Action
- [ ] Permission Sets
- [ ] Sharing Rules

## Testing Performed
- [ ] Deployed to scratch org successfully
- [ ] All Apex tests pass (RunLocalTests)
- [ ] Manual verification in org:
  - [ ] AutoQuoting Flow creates policy correctly
  - [ ] Claim routing works by policy type
  - [ ] High-value claim (>$50K) submits to approval
  - [ ] Approve/Reject quick action updates status
  - [ ] Dashboard filters by policy type
  - [ ] Permission sets grant correct access
  - [ ] Sharing rules enforce state-based visibility
- [ ] Code coverage ≥ 75% (Salesforce minimum)
- [ ] Code coverage ≥ 90% for modified Apex classes

## Screenshots / Recordings
<!-- Add screenshots or screen recordings of the changes in action -->

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code where necessary
- [ ] I have updated documentation (README, docs/) if needed
- [ ] My changes generate no new warnings/errors
- [ ] I have added/updated tests for my changes
- [ ] All tests pass locally
- [ ] I have verified no sensitive data (API keys, passwords) in code

## Deployment Notes
<!-- Any special deployment considerations -->
- [ ] Requires manual post-deploy steps (specify in description)
- [ ] Data migration needed
- [ ] Profile/Permission set assignments needed