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

Open a [Discussion](https://github.com/hema772/insurance-github/discussions) or check existing [Issues](https://github.com/hema772/insurance-github/issues).
## 🛠️ Useful Commands Reference

### Quick Setup
```bash
# Clone and authenticate
git clone https://github.com/YOUR_USERNAME/insurance-github.git
cd insurance-github
gh auth switch --user YOUR_GITHUB_USERNAME
sf org login web --alias dev-org

# Full development cycle
sf project deploy start --target-org dev-org
sf test run local --target-org dev-org

# Check test coverage
sf coverage:report --target-org dev-org --type ApexClass

# Debug flows
sf flow debug interview --target-org dev-org --run-id <interview-id>
```

### Common Git Workflows

**Creating a new feature branch:**
```bash
git checkout -b feature/claim-queue-improvement main
# ... make changes ...
git add .
git commit -m "feat: improve claim queue routing logic"
git push origin feature/claim-queue-improvement
```

**Fixing a bug:**
```bash
git checkout -b fix/vin-validation-bug main
# ... make changes ...
git add .
git commit -m "fix: correct VIN length validation for Auto policies"
git push origin fix/vin-validation-bug
```

**Synchronizing with upstream:**
```bash
git remote add upstream https://github.com/hema772/insurance-github.git
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### IDE Settings (VS Code)

**Recommended settings.json:**
```json
{
  "salesforce.debugApi": true,
  "salesforce.sfdxApi": true,
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true
  }
}
```

### Environment Variables

Required for local development:
- `SFDX_CONNECTED_APP_CLIENT_ID` — Salesforce connected app client ID
- `SFDX_CONNECTED_APP_CLIENT_SECRET` — Salesforce connected app client secret  
- `DEV_ORG_USERNAME` — Dev org username
- `DEV_ORG_PASSWORD` — Dev org password + security token

---

## 📝 Commit Message Template

For consistency across contributors:

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation changes
- `style` — Formatting, missing semi colons, etc.
- `refactor` — Refactoring existing code
- `test` — Adding missing tests
- `chore` — Updating build tasks, package manager configs, etc.

**Example:**
```
feat: add VIN length validation for Property policies

- Added 17-character VIN validation rule
- Updated Property_Fields field set
- Added test method testValidateVIN_PropertyPolicy

Closes: #42
```
