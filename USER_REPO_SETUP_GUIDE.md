# User Repository Setup Guide - Deploy from Your Own Repo

This guide shows how application teams with their own repositories can deploy infrastructure using the centralized platform terraform modules and workflows.

---

## Architecture Overview

```
┌─────────────────────────────────────────┐
│  PLATFORM REPO (This Repository)        │
│  ├─ platform/terraform-modules/         │
│  │  ├─ resource-group/                  │
│  │  ├─ storage-account/  ◄─────────────┐│
│  │  ├─ virtual-machines/                ││
│  │  └─ load-balancer/                   ││
│  └─ .github/workflows/                  ││
│     └─ platform-deploy-storage.yml ◄───┤│
└─────────────────────────────────────────┘
                           ▲               │
                           │               │
                    workflow_call          │
                           │               │
┌─────────────────────────────────────────┐│
│  USER/APP REPO (Your Repository)        ││
│  ├─ .github/workflows/                  ││
│  │  └─ deploy-storage.yml ──────────────┘│
│  ├─ tfvars/                             │
│  │  ├─ dev/storage-account.tfvars       │
│  │  ├─ staging/storage-account.tfvars   │
│  │  └─ prod/storage-account.tfvars      │
│  └─ terraform/                          │
│     └─ storage-account/ (optional)      │
└─────────────────────────────────────────┘
```

---

## Step 1: Set Up Your Application Repository

### 1.1 Repository Structure

Create this directory structure in your repo:

```
my-app-repo/
├── .github/
│   └── workflows/
│       └── deploy-storage.yml          # Your custom workflow
├── tfvars/
│   ├── dev/
│   │   └── storage-account.tfvars
│   ├── staging/
│   │   └── storage-account.tfvars
│   └── prod/
│       └── storage-account.tfvars
├── terraform/
│   └── storage-account/               # Optional: if using git modules
└── README.md
```

---

## Step 2: Create Application-Specific Variables (tfvars)

### 2.1 Example: `tfvars/dev/storage-account.tfvars`

```hcl
# Resource Group Configuration
resource_group_name = "my-app-rg-dev"
location            = "eastus"

# Storage Account Configuration
storage_account_name = "myappstoragdev"  # Must be globally unique
storage_account_tier = "Standard"
access_tier          = "Hot"

# Environment Tagging
environment = "dev"

tags = {
  Environment  = "dev"
  Application  = "my-app"
  Team         = "platform-team"
  CostCenter   = "12345"
  ManagedBy    = "Terraform"
}

# Storage Account Features
enable_https_traffic_only = true
min_tls_version          = "TLS1_2"

# Containers
container_names = ["app-logs", "app-data", "app-backups"]

# Diagnostics
enable_diagnostics = true
```

### 2.2 Example: `tfvars/prod/storage-account.tfvars`

```hcl
# Resource Group Configuration
resource_group_name = "my-app-rg-prod"
location            = "eastus"

# Storage Account Configuration
storage_account_name = "myappstorageprod"  # Must be globally unique
storage_account_tier = "Premium"
access_tier          = "Hot"

# Environment Tagging
environment = "prod"

tags = {
  Environment  = "prod"
  Application  = "my-app"
  Team         = "platform-team"
  CostCenter   = "67890"
  ManagedBy    = "Terraform"
  Compliance   = "PCI-DSS"
}

# Storage Account Features
enable_https_traffic_only = true
min_tls_version          = "TLS1_2"

# Containers
container_names = ["app-logs", "app-data", "app-backups", "audit-trails"]

# Diagnostics
enable_diagnostics = true
```

---

## Step 3: Create Your Deployment Workflow

### 3.1 Workflow That Calls Platform Workflow (RECOMMENDED)

Your workflow is **very simple** - it just calls the platform's workflow. Create `.github/workflows/deploy-storage.yml` in your repo:

```yaml
name: Deploy Storage Account to Azure

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Select deployment environment'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod

jobs:
  deploy-storage:
    name: Deploy Storage Account to ${{ inputs.environment }}
    
    # Calls the platform's reusable workflow
    uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
    with:
      environment: ${{ inputs.environment }}
      tfvars_file: tfvars/${{ inputs.environment }}/storage-account.tfvars
      terraform_version: '1.5.0'
    
    secrets:
      # Pass all required Azure authentication secrets
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

**That's it!** The platform team maintains all the terraform logic - your workflow is just a simple delegator.

### Key Points:
- ✅ **20 lines of YAML** instead of 200+
- ✅ **Platform team owns terraform** - no terraform knowledge needed for users
- ✅ **Users only manage tfvars** - their application-specific configuration
- ✅ **Consistent execution** - all users run the same terraform logic
- ✅ **Easy updates** - platform team fixes bugs once, all users benefit

---

## Step 4: Set Up GitHub Secrets in Your Repository

Your repository needs these Azure authentication secrets:

| Secret Name | Description | Where to get |
|-------------|-------------|--------------|
| `AZURE_CLIENT_ID` | Azure Service Principal Client ID | Azure Portal → App registrations |
| `AZURE_CLIENT_SECRET` | Azure Service Principal Secret | Azure Portal → App registrations → Certificates & secrets |
| `AZURE_SUBSCRIPTION_ID` | Your Azure Subscription ID | Azure Portal → Subscriptions |
| `AZURE_TENANT_ID` | Your Azure Tenant ID | Azure Portal → Azure AD → Tenant info |
| `AZURE_CREDENTIALS` | Full JSON credentials | `az account get-access-token` |

### 4.1 Setting Up Secrets in GitHub

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret from the table above

**Example JSON for `AZURE_CREDENTIALS`:**
```json
{
  "clientId": "00000000-0000-0000-0000-000000000000",
  "clientSecret": "your-secret-here",
  "subscriptionId": "00000000-0000-0000-0000-000000000000",
  "tenantId": "00000000-0000-0000-0000-000000000000"
}
```

---

## Step 5: Understanding Your Application-Specific Variables

### 5.1 What Variables Are Required?

The platform storage-account module expects these variables in your tfvars:

```hcl
# REQUIRED
resource_group_name      = "your-rg-name"        # Resource group where storage will be created
storage_account_name     = "yourstorageaccount"   # Must be globally unique, lowercase, 3-24 chars
location                 = "eastus"               # Azure region

# OPTIONAL
storage_account_tier     = "Standard"             # Standard or Premium
access_tier              = "Hot"                  # Hot, Cool, or Archive
environment              = "dev"
container_names          = ["container1", "container2"]
enable_https_traffic_only = true
min_tls_version          = "TLS1_2"
enable_diagnostics       = false

tags = {
  Environment = "dev"
  # ... other tags
}
```

### 5.2 Environment-Specific Values

Keep different values per environment:

**Dev environment** - Lower cost, basic features:
```hcl
storage_account_tier = "Standard"  # Cheaper
enable_diagnostics   = false       # Less logging
```

**Prod environment** - Higher performance, compliance:
```hcl
storage_account_tier = "Premium"   # Better performance
enable_diagnostics   = true        # Full audit trails
min_tls_version      = "TLS1_2"    # Security requirement
```

---

## Step 6: How to Use Your Workflow

### 6.1 Deploy Storage Account

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select **Deploy Storage Account to Azure** workflow
4. Click **Run workflow**
5. Select environment (dev/staging/prod)
6. Click **Run workflow**

The workflow will:
- ✅ Validate your tfvars file exists
- ✅ Checkout both your app code and platform code
- ✅ Run terraform plan to show what will be created
- ✅ Apply the changes to Azure
- ✅ Output storage account details

### 6.2 Workflow Execution Example

```
Input: environment=dev

Step 1: Checkout app-repo → your tfvars are here
Step 2: Validate dev/storage-account.tfvars exists ✓
Step 3: Checkout platform-repo → has terraform modules
Step 4: Copy your tfvars to platform structure
Step 5: terraform init → Initialize Terraform
Step 6: terraform plan → Show what will be created
Step 7: terraform apply → Create storage account in Azure
Step 8: Output results → Display storage account ID & name

Result: ✅ Storage account deployed to your resource group
```

---

## Step 7: Production-Ready Checklist

Before deploying to production, ensure:

- [ ] **Resource Group Exists**: Your resource group should already exist in Azure
  ```bash
  az group create --name my-app-rg-prod --location eastus
  ```

- [ ] **Unique Storage Account Name**: Must be globally unique (3-24 lowercase alphanumeric)
  ```bash
  # Check if name is available
  az storage account check-name --name myappstorageprod
  ```

- [ ] **Secrets are Set**: All 5 secrets configured in GitHub Settings

- [ ] **Permissions**: Service Principal has these permissions:
  - `Contributor` on the subscription or resource group
  - OR specific roles: `Storage Account Contributor`, `Storage Blob Data Contributor`

- [ ] **TLS Configuration**: Production should enforce `MIN_TLS_VERSION = "TLS1_2"`

- [ ] **Diagnostics Enabled**: Production should have `enable_diagnostics = true`

- [ ] **Containers Named**: Define container names for your app: `app-logs`, `app-data`, etc.

- [ ] **Access Control**: Configure storage account firewall rules if needed

---

## Step 8: Troubleshooting

### Issue: "tfvars file not found"
```yaml
✗ ERROR: tfvars file not found at app-repo/tfvars/dev/storage-account.tfvars
```
**Solution**: Create the file with the correct path matching your environment choice.

### Issue: "Storage account name already exists"
```
Error: storage account 'myappstorage' already exists
```
**Solution**: Change the `storage_account_name` in your tfvars to something globally unique:
```hcl
storage_account_name = "myappstg${var.environment}${random_suffix}"
```

### Issue: "Service Principal doesn't have permissions"
```
Error: Authorization failed for assignment
```
**Solution**: Grant the service principal the `Contributor` role on the resource group:
```bash
az role assignment create --assignee <CLIENT_ID> --role Contributor --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>
```

### Issue: "Resource group not found"
```
Error: azurerm_storage_account.storage: reading: storage.AccountsClient#GetProperties: Failure
```
**Solution**: Create the resource group before deploying:
```bash
az group create --name my-app-rg-dev --location eastus
```

---

## Step 9: Alternative: Using Reusable Workflows Directly

Instead of managing tfvars manually, you can call the platform workflow directly from your repo:

**Advanced Usage** - `.github/workflows/deploy-storage-advanced.yml`:

```yaml
name: Deploy Storage (Direct Platform Workflow)

on:
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: [dev, staging, prod]

jobs:
  deploy-storage:
    name: Deploy Storage Account
    uses: github-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
    with:
      environment: ${{ inputs.environment }}
      tfvars_file: tfvars/${{ inputs.environment }}/storage-account.tfvars
      terraform_version: '1.5.0'
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

This is **simpler** but requires the tfvars path to match exactly where the platform workflow expects it.

---

## Summary

| Component | Location | Managed By |
|-----------|----------|-----------|
| **Terraform Modules** | platform-repo/platform/terraform-modules/ | Platform Team |
| **Platform Workflows** | platform-repo/.github/workflows/ | Platform Team |
| **Your Workflow** | your-repo/.github/workflows/deploy-storage.yml | Your Team |
| **Your Variables** | your-repo/tfvars/{env}/storage-account.tfvars | Your Team |
| **Your Secrets** | GitHub Settings in your repo | Your Team |

**Benefits:**
- ✅ Centralized, versioned terraform modules
- ✅ Application-specific configurations per environment
- ✅ Decoupled: Your repo, your variables, your secrets
- ✅ Repeatable deployments
- ✅ Full audit trail in GitHub Actions

