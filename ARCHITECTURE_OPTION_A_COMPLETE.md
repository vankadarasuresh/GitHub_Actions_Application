# Complete Architecture - Option A (Reusable Workflows) ✅

## What's Changed from Earlier

**Earlier (Option B - Not Used):**
- User workflows had 200+ lines
- Users ran terraform directly
- Each user maintained their own terraform execution logic

**Now (Option A - Implemented):**
- User workflows have ~40 lines
- User workflows call platform workflows
- Platform team maintains terraform execution logic
- Maximum code reuse, minimal user complexity

---

## Complete System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        PLATFORM REPOSITORY                      │
│                  (Maintained by Platform Team)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  .github/workflows/                                             │
│  ├─ platform-deploy-storage.yml         (Reusable)            │
│  ├─ platform-deploy-vm.yml              (Reusable)            │
│  └─ platform-deploy-loadbalancer.yml    (Reusable)            │
│                                                                 │
│  platform/terraform-modules/                                    │
│  ├─ resource-group/                     (Terraform)            │
│  ├─ storage-account/                    (Terraform)            │
│  ├─ virtual-machines/                   (Terraform)            │
│  └─ load-balancer/                      (Terraform)            │
│                                                                 │
│  examples/                                                       │
│  ├─ USER_REPO_SETUP_GUIDE.md                                   │
│  ├─ USER_REPO_CHECKLIST.md                                     │
│  ├─ HOW_PLATFORM_WORKFLOWS_WORK.md                             │
│  └─ user-repo-example/                  (Templates for users)  │
│     ├─ .github/workflows/                                      │
│     │  ├─ deploy-storage.yml            (20 lines)            │
│     │  ├─ deploy-vms.yml                (20 lines)            │
│     │  └─ deploy-loadbalancer.yml       (20 lines)            │
│     └─ tfvars/                                                  │
│        ├─ dev/storage-account.tfvars                           │
│        ├─ dev/virtual-machines.tfvars                          │
│        ├─ dev/load-balancer.tfvars                             │
│        ├─ staging/ (same structure)                             │
│        └─ prod/ (same structure)                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                      USER REPOSITORY #1                         │
│              (Team A's Application Repository)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  .github/workflows/                                             │
│  ├─ deploy-storage.yml          (Calls platform workflow)      │
│  ├─ deploy-vms.yml              (Calls platform workflow)      │
│  └─ deploy-loadbalancer.yml     (Calls platform workflow)      │
│                                                                 │
│  tfvars/                                                        │
│  ├─ dev/                                                        │
│  │  ├─ storage-account.tfvars        (Team A's config)        │
│  │  ├─ virtual-machines.tfvars       (Team A's config)        │
│  │  └─ load-balancer.tfvars          (Team A's config)        │
│  ├─ staging/ (same structure)                                   │
│  └─ prod/ (same structure)                                      │
│                                                                 │
│  (Team A's application code & docs)                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                      USER REPOSITORY #2                         │
│              (Team B's Application Repository)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  .github/workflows/                                             │
│  ├─ deploy-storage.yml          (Calls platform workflow)      │
│  ├─ deploy-vms.yml              (Calls platform workflow)      │
│  └─ deploy-loadbalancer.yml     (Calls platform workflow)      │
│                                                                 │
│  tfvars/                                                        │
│  ├─ dev/                                                        │
│  │  ├─ storage-account.tfvars        (Team B's config)        │
│  │  ├─ virtual-machines.tfvars       (Team B's config)        │
│  │  └─ load-balancer.tfvars          (Team B's config)        │
│  ├─ staging/ (same structure)                                   │
│  └─ prod/ (same structure)                                      │
│                                                                 │
│  (Team B's application code & docs)                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                      USER REPOSITORY #N                         │
│              (Team N's Application Repository)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Same pattern as Team A and Team B...                           │
│  (Each team has their own workflows + tfvars)                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Deployment Flow - Example

### Scenario: Team A deploys storage account to dev

```
1️⃣  TRIGGER
   ├─ Team A: Go to GitHub Actions
   ├─ Team A: Click "Deploy Storage"
   ├─ Team A: Select environment "dev"
   └─ Team A: Click "Run workflow"

2️⃣  TEAM A'S WORKFLOW EXECUTES
   └─ deploy-storage.yml:
      uses: platform-repo/.../platform-deploy-storage.yml@main
      with:
        environment: dev
        tfvars_file: tfvars/dev/storage-account.tfvars

3️⃣  PLATFORM WORKFLOW EXECUTES (in platform repo)
   └─ platform-deploy-storage.yml:
      ├─ Accepts: environment=dev, tfvars_file path, secrets
      ├─ Checks out: team-a-repo (to access tfvars)
      ├─ Reads: tfvars/dev/storage-account.tfvars
      │  └─ Contains: "resource_group_name", "storage_account_name", etc
      ├─ Checks out: platform-repo (to access terraform modules)
      ├─ Runs: terraform init (uses platform's storage-account module)
      ├─ Runs: terraform plan with team-a's tfvars as variables
      ├─ Runs: terraform apply
      └─ Returns: storage_account_id, storage_account_name

4️⃣  TERRAFORM CREATES RESOURCES
   └─ storage-account module creates:
      ├─ Storage Account (using team A's name from tfvars)
      ├─ Containers (using team A's container_names from tfvars)
      └─ Tags (using team A's tags from tfvars)

5️⃣  RESULT
   ├─ Team A: Sees successful workflow in GitHub Actions
   ├─ Team A: Gets storage account ID and name
   └─ Team A: Storage account live in Azure
```

---

## File Purposes & Ownership

### Deployment Files

| File | Location | Owner | Purpose |
|------|----------|-------|---------|
| `deploy-storage.yml` | user-repo/.github/workflows/ | User Team | Simple delegator (20 lines) |
| `platform-deploy-storage.yml` | platform-repo/.github/workflows/ | Platform Team | Terraform executor (200 lines) |

### Configuration Files

| File | Location | Owner | Purpose |
|------|----------|-------|---------|
| `tfvars/dev/storage-account.tfvars` | user-repo/tfvars/dev/ | User Team | Dev config values |
| `tfvars/prod/storage-account.tfvars` | user-repo/tfvars/prod/ | User Team | Prod config values |

### Infrastructure Code

| File | Location | Owner | Purpose |
|------|----------|-------|---------|
| `storage-account/main.tf` | platform-repo/platform/terraform-modules/ | Platform Team | Terraform code |
| `storage-account/variables.tf` | platform-repo/platform/terraform-modules/ | Platform Team | Variable definitions |
| `storage-account/outputs.tf` | platform-repo/platform/terraform-modules/ | Platform Team | Output definitions |

---

## Why This Architecture is Better

### ✅ Advantages

1. **DRY (Don't Repeat Yourself)**
   - Platform team writes terraform ONCE
   - All users call the same workflow
   - No duplication across users

2. **Maintainability**
   - Bug fixes in terraform = fix once, benefit everyone
   - Terraform version updates = update once
   - Feature additions = centralized

3. **Consistency**
   - All users run the same terraform logic
   - Same error handling for everyone
   - Same output format for everyone

4. **User Simplicity**
   - User workflows are just 20 lines
   - Users only understand their tfvars
   - No terraform knowledge required

5. **Security**
   - Platform team owns terraform execution
   - Platform team controls how terraform runs
   - Users can't run arbitrary terraform

6. **Version Control**
   - Platform workflows tagged with versions (v1.0.0, v2.0.0)
   - Users can lock to specific versions
   - Easy to rollback to previous versions

---

## How to Update/Maintain

### Scenario 1: Platform Team Fixes a Bug in Terraform

```
1. Platform team edits: platform/terraform-modules/storage-account/main.tf
2. Platform team tests the fix
3. Platform team pushes to main or tags as v1.0.1
4. All users automatically use the fix (if using @main)
   OR users manually update to v1.0.1
```

### Scenario 2: User Wants to Change Their Configuration

```
USER REPO:
1. Edit: tfvars/dev/storage-account.tfvars
2. Change value (e.g., storage_account_tier = "Premium")
3. Push to git
4. Run workflow from Actions
5. Terraform applies the changes
```

### Scenario 3: User Wants to Use a Specific Platform Version

```
USER REPO:
deploy-storage.yml change:
-  uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
+  uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@v1.0.0
```

---

## Summary

### The Key Pattern

```
User Workflow (20 lines)
    ↓
Calls
    ↓
Platform Workflow (200 lines)
    ↓
Runs
    ↓
Platform Terraform Module (300 lines)
    ↓
Uses
    ↓
User's tfvars (configuration)
    ↓
Creates
    ↓
Azure Resources (Storage, VMs, LB, etc)
```

### What Users Do
- ✅ Copy workflow templates from `user-repo-example/`
- ✅ Customize tfvars files with their values
- ✅ Set GitHub secrets (Azure credentials)
- ✅ Run workflows from GitHub Actions UI

### What Users DON'T Do
- ❌ Write terraform code
- ❌ Maintain terraform modules
- ❌ Edit platform workflows
- ❌ Manage terraform state
- ❌ Know terraform syntax

### What Platform Team Does
- ✅ Write and maintain terraform code
- ✅ Write and maintain platform workflows
- ✅ Update terraform versions as needed
- ✅ Fix bugs centrally
- ✅ Document best practices

---

## Reusable Workflow Syntax

### Your Workflow (calling platform workflow)

```yaml
name: Deploy Storage Account

on:
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: [dev, staging, prod]

jobs:
  deploy:
    uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
    with:
      environment: ${{ inputs.environment }}
      tfvars_file: tfvars/${{ inputs.environment }}/storage-account.tfvars
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      # ... other secrets
```

**Key Points:**
- `uses:` - Specifies which workflow to call
- `@main` - Use main branch, OR `@v1.0.0` for specific version
- `with:` - Pass inputs to the platform workflow
- `secrets:` - Pass secrets to the platform workflow

---

## One More Time: Why This is Better

| Aspect | Option B (Direct Terraform) | Option A (Reusable Workflows) ✅ |
|--------|---------------------------|------------------------------|
| User workflow size | 200+ lines | ~40 lines |
| Terraform expertise needed | Yes | No |
| Code duplication | High (each user) | None (centralized) |
| Update process | Each user updates | Platform updates once |
| Bug fix deployment | Each user deploys | Platform deploys once |
| Consistency | Low (each user different) | High (all same) |
| Maintenance burden | Per user | Centralized |
| Learning curve | Steep | Gentle |

**Clear winner: Option A ✅**

