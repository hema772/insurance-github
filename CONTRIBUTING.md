# Contributing Guidelines

Thank you for contributing to the Multi-Line Insurance Policy & Claims Management System!

## Getting Started

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/YOUR_USERNAME/insurance-github.git`
3. **Create a branch**: `git checkout -b feature/your-feature-name`
4. **Make changes** following the guidelines below
5. **Test** thoroughly
6. **Submit a Pull Request**

## Development Setup

```bash
# Prerequisites
- Salesforce CLI (sf) v2.150+
- Git
- VS Code with Salesforce Extension Pack (recommended)

# Authenticate
sf org login web --alias dev-org

# Deploy to test
sf project deploy start --target-org dev-org
sf test run local --target-org dev-org
```

## Code Standards

### Apex
- Follow [Salesforce Apex Code Style](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_code_style.htm)
- Use `with sharing` on all controllers
- Bulkify all SOQL/DML operations
- Minimum 90% test coverage for new classes
- Use `@AuraEnabled(cacheable=true)` for read-only LWC methods

### Flows
- Name flows: `{Purpose}_Flow` (e.g., `Claim_Routing_Flow`)
- Use descriptive variable names: `varPolicyType`, `varContactId`
- Add descriptions to all elements
- Use Decision elements for branching (not multiple connectors)
- Test with Debug before deploying

### LWC
- Follow [LWC Best Practices](https://lwc.dev/guide/best_practices)
- Use `@wire` for reactive data
- Pass data via `@api` properties (parent → child)
- Use `lightning-record-form` / `lightning-datatable` where possible
- Keep components small and focused

### Git Commits
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new claim routing logic
fix: correct VIN validation for Auto policies
docs: update architecture decision records
test: add coverage for PremiumCalculator
refactor: simplify claim tile component
chore: update sfdx-project.json API version
```

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `develop` | Integration branch |
| `feature/*` | New features |
| `fix/*` | Bug fixes |
| `release/*` | Release preparation |

## Pull Request Process

1. **Title**: Use conventional commit format
2. **Description**: Clear summary of changes + related issue
3. **Testing**: Document manual verification steps
4. **Screenshots**: Include for UI changes
5. **Review**: At least 1 approval required
6. **CI**: All checks must pass

## Testing Requirements

| Change Type | Required Testing |
|-------------|------------------|
| Apex Class | Unit tests (90%+ coverage) |
| Flow | Debug test + manual verification |
| LWC | Manual verification in org |
| Permission Set | Assign to test user, verify access |
| Sharing Rule | Test with multiple users |

## Release Process

1. Create `release/vX.Y.Z` branch from `develop`
2. Update version in `sfdx-project.json`
3. Run full test suite
4. Merge to `main` with PR
5. Tag release: `git tag -a vX.Y.Z -m "Release X.Y.Z"`
5. Deploy to production

## Questions?

Open a [Discussion](https://github.com/ArenRedd/insurance-github/discussions) or check existing [Issues](https://github.com/ArenRedd/insurance-github/issues).