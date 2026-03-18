# How Platform Workflows Work - User Guide

## Overview

As an application team, your workflow files are **extremely simple** - they just call the platform team's reusable workflows. Here's how it all works together.

---

## The Simple Pattern

### Your Workflow File

```yaml
name: Deploy Storage Account to Azure

on:
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: [dev, staging, prod]

jobs:
  deploy-storage:
    uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
    with:
      environment: ${{ inputs.environment }}
      tfvars_file: tfvars/${{ inputs.environment }}/storage-account.tfvars
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
      # ... other secrets
```

**That's it! Just 30 lines of YAML.**

---

## What Happens When You Run It

```
┌─────────────────────────────────────────────────────────┐
│  Step 1: User Triggers Workflow                         │
│  └─ GitHub Actions UI → Select environment → Run       │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│  Step 2: Your Workflow Calls Platform Workflow          │
│  └─ uses: platform-repo/workflows/platform-deploy@main │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│  Step 3: Platform Workflow Executes                     │
│  ├─ Receives: environment, tfvars_file, secrets       │
│  ├─ Checks out platform repo                          │
│  ├─ Looks for tfvars at: tfvars/dev/storage.tfvars    │
│  ├─ Runs terraform init → plan → apply                │
│  └─ Returns: outputs (storage account ID, name, etc)  │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│  Step 4: Results Displayed to You                       │
│  ├─ Workflow logs show terraform output                │
│  ├─ Storage account created in Azure                   │
│  └─ Deployment complete                                │
└─────────────────────────────────────────────────────────┘
```

---

## Key Files You Manage

### 1. Your Workflow Files (`.github/workflows/*.yml`)

**What:** Simple delegators that call platform workflows  
**How many:** One per resource type (storage, vms, loadbalancer)  
**Size:** ~40 lines each  
**Who maintains:** You  
**Frequency of changes:** Rarely (only if adding new inputs)  

**Example:**
```yaml
uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
with:
  environment: ${{ inputs.environment }}
  tfvars_file: tfvars/${{ inputs.environment }}/storage-account.tfvars
```

### 2. Your tfvars Files (`tfvars/{env}/*.tfvars`)

**What:** Your application-specific configuration  
**How many:** 3 per resource (dev, staging, prod)  
**Content:** Variables like storage_account_name, resource_group_name, tags  
**Who maintains:** You  
**Frequency of changes:** Often (when deploying new configs)  

**Example:**
```hcl
resource_group_name = "my-app-rg-dev"
storage_account_name = "myappstoragdev"
tags = {
  Environment = "dev"
  Team = "my-team"
}
```

### 3. Platform's Workflow Files (`.github/workflows/platform-deploy-*.yml`)

**What:** Terraform execution logic  
**Location:** Platform repo (not your repo)  
**Content:** terraform init, plan, apply  
**Who maintains:** Platform team  
**Frequency of changes:** Rarely (when updating terraform patterns)  

**You never edit these!** Platform team maintains them.

### 4. Platform's Terraform Modules (`platform/terraform-modules/*/`)

**What:** Actual infrastructure code  
**Location:** Platform repo (not your repo)  
**Content:** main.tf, variables.tf, outputs.tf  
**Who maintains:** Platform team  
**Frequency of changes:** Rarely (when adding features)  

**You never edit these!** Platform team maintains them.

---

## How Your Workflow Finds Your tfvars

When you run your workflow:

```
1. You select environment: "dev"

2. Your workflow passes:
   tfvars_file: "tfvars/dev/storage-account.tfvars"

3. Platform workflow:
   - Checks out your repo
   - Looks for: tfvars/dev/storage-account.tfvars
   - Passes it to terraform: -var-file="tfvars/dev/storage-account.tfvars"

4. Terraform:
   - Reads your tfvars
   - Creates resources with your values
```

**Important:** Your tfvars file path MUST match exactly!

```
✅ CORRECT:
   tfvars_file: tfvars/dev/storage-account.tfvars

❌ WRONG:
   tfvars_file: tfvars/dev/storage.tfvars     (wrong filename)
   tfvars_file: tfvars-dev/storage-account.tfvars  (wrong path)
```

---

## Example: Deploying to Dev

### Before Running Workflow:

```
your-repo/
├── .github/workflows/
│   └── deploy-storage.yml
├── tfvars/dev/
│   ├── storage-account.tfvars     ← Contains your dev config
│   ├── virtual-machines.tfvars
│   └── load-balancer.tfvars
└── (your application code)
```

**tfvars/dev/storage-account.tfvars contains:**
```hcl
resource_group_name = "my-app-rg-dev"
storage_account_name = "myappstoragdev"
environment = "dev"
tags = { Team = "my-team" }
```

### Running Workflow:

1. Go to GitHub → Actions
2. Select "Deploy Storage Account"
3. Click "Run workflow"
4. Select environment: "dev"
5. Click "Run workflow"

### What Happens Behind the Scenes:

```
1. Your workflow runs:
   deploy-storage.yml

2. It calls:
   platform-repo/.github/workflows/platform-deploy-storage.yml
   
3. Platform workflow:
   - Checks out: your-repo (to get tfvars/dev/storage-account.tfvars)
   - Checks out: platform-repo (to get terraform modules)
   - Runs: terraform plan -var-file="tfvars/dev/storage-account.tfvars"
   - Runs: terraform apply
   
4. Terraform creates:
   - Storage account named: "myappstoragdev"
   - In resource group: "my-app-rg-dev"
   - With tags: Team=my-team
   
5. You see:
   - Workflow logs in GitHub Actions
   - Storage account created in Azure Portal
```

---

## The Key Insight

```
┌──────────────────────────────────────┐
│  Platform Team Responsibility        │
├──────────────────────────────────────┤
│                                      │
│  "How to deploy" (terraform code)    │
│  ├─ terraform modules                │
│  └─ platform workflows               │
│                                      │
│  Maintains once, used by everyone    │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  Your Team Responsibility            │
├──────────────────────────────────────┤
│                                      │
│  "What to deploy" (your config)      │
│  ├─ tfvars files                     │
│  └─ application code                 │
│                                      │
│  You customize for your app          │
└──────────────────────────────────────┘
```

---

## Common Tasks

### Task 1: Deploy Storage to Dev

1. Edit `tfvars/dev/storage-account.tfvars`
2. Change `storage_account_name` to your desired name
3. Go to Actions → Deploy Storage → Run workflow → Select "dev"
4. Done! Storage created

### Task 2: Change Storage Configuration for Prod

1. Edit `tfvars/prod/storage-account.tfvars`
2. Change the values (e.g., `storage_account_tier = "Premium"`)
3. Go to Actions → Deploy Storage → Run workflow → Select "prod"
4. Platform workflow updates the storage account

### Task 3: Deploy All Three Resources (Storage, VMs, Load Balancer)

1. Make sure all tfvars files exist:
   - `tfvars/dev/storage-account.tfvars`
   - `tfvars/dev/virtual-machines.tfvars`
   - `tfvars/dev/load-balancer.tfvars`

2. Run workflows in order:
   - Deploy Storage Account
   - Deploy VMs (VMs can take 5+ minutes)
   - Deploy Load Balancer

3. Each workflow calls the corresponding platform workflow

---

## Troubleshooting

### Problem: "tfvars file not found"

**Error message:**
```
❌ ERROR: tfvars file not found!
Expected: tfvars/dev/storage-account.tfvars
```

**Causes:**
- File doesn't exist at that path
- Wrong environment selected (chose prod but file is in dev/)
- Filename is incorrect

**Solution:**
1. Verify file exists: `ls -la tfvars/dev/storage-account.tfvars`
2. Verify path matches exactly (case-sensitive on Linux)
3. Try running workflow again with correct environment

### Problem: "Storage account already exists"

**Error:**
```
Error: storage account 'myappstorage' already exists
```

**Cause:** Storage account name must be globally unique across Azure

**Solution:**
1. Change name in tfvars file (add suffix like `-v2`)
2. Commit and push
3. Run workflow again

### Problem: "Permission denied"

**Error:**
```
Error: Authorization failed. Insufficient permissions.
```

**Cause:** Service Principal doesn't have permissions

**Solution:**
1. Verify secrets are correct in GitHub Settings
2. Check Service Principal has "Contributor" role on subscription
3. Ask platform team to grant permissions

### Problem: Workflow hangs

**Symptom:** Workflow running but stuck on a step

**Cause:** Usually network/auth issues

**Solution:**
1. Wait 5 minutes (terraform can be slow)
2. Check resource group exists in Azure
3. Check all secrets are set correctly
4. Cancel workflow and try again

---

## Key Points to Remember

✅ **Your workflows are simple** - just calling platform workflows  
✅ **You only manage tfvars** - your application configuration  
✅ **Platform team manages terraform** - the terraform code itself  
✅ **Separation of concerns** - you don't need terraform knowledge  
✅ **Maximum reuse** - all teams use the same terraform logic  

❌ **Don't edit platform workflows** - they're in platform repo  
❌ **Don't edit terraform modules** - they're in platform repo  
❌ **Don't hardcode secrets** - use GitHub Secrets  
❌ **Don't run terraform locally** - use workflows  

---

## Next Steps

1. **Copy your workflows** from examples
2. **Customize your tfvars** for your app
3. **Set GitHub secrets** (5 required)
4. **Run a workflow** to test
5. **Verify** resource created in Azure Portal

---

## Questions?

- "Can I add more containers?" → Yes, add to tfvars `container_names`
- "Can I change VM size?" → Yes, edit tfvars `vm_size`
- "Can I deploy to both dev and prod simultaneously?" → Not in single workflow, but you can trigger multiple workflows
- "Can I see what terraform will change?" → Yes, check the "Terraform Plan" step in workflow logs
- "Can I rollback changes?" → Yes, edit tfvars and re-run workflow with previous values

