# Quick-Start Example for User Repository

This folder contains **copy-paste-ready files** for an application team's repository to deploy storage accounts using the platform modules.

## Files in This Directory

```
user-repo-example/
├── .github/
│   └── workflows/
│       └── deploy-storage.yml              ← Copy this to your repo
├── tfvars/
│   ├── dev/storage-account.tfvars          ← Copy and customize
│   ├── staging/storage-account.tfvars      ← Copy and customize
│   └── prod/storage-account.tfvars         ← Copy and customize
└── README.md                                ← Your repo's main README
```

## Quick Setup (5 Minutes)

### 1. Copy Workflow Files
```bash
# In your application repository
mkdir -p .github/workflows
cp ../user-repo-example/.github/workflows/*.yml .github/workflows/
```

### 2. Copy and Customize tfvars Files
```bash
mkdir -p tfvars/{dev,staging,prod}
cp -r ../user-repo-example/tfvars/* tfvars/
```

### 3. Edit Each tfvars File
Update the storage account names, resource group names, and tags for your application:
```bash
# Update your specific values
nano tfvars/dev/storage-account.tfvars
nano tfvars/staging/storage-account.tfvars
nano tfvars/prod/storage-account.tfvars
```

### 4. Set GitHub Secrets (Critical!)
In your GitHub repository Settings → Secrets and variables → Actions:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `AZURE_CREDENTIALS`

### 5. Deploy!
- Go to Actions tab in GitHub
- Select workflow (deploy-storage, deploy-vms, or deploy-loadbalancer)
- Click "Run workflow"
- Choose environment (dev/staging/prod)

## 🎯 How This Works

Your workflow files (`.github/workflows/*.yml`) are **very simple** - they just call the platform's reusable workflows:

```yaml
jobs:
  deploy-storage:
    uses: your-org/GitHub_Actions/.github/workflows/platform-deploy-storage.yml@main
    with:
      environment: ${{ inputs.environment }}
      tfvars_file: tfvars/${{ inputs.environment }}/storage-account.tfvars
    secrets: (pass AWS credentials)
```

**That's it!** The platform team handles all the terraform logic - you just provide your configuration in tfvars files.

**Benefits:**
- ✅ Your workflows are just 40 lines each (very simple!)
- ✅ Platform team maintains terraform - no terraform knowledge needed
- ✅ You only manage application-specific variables
- ✅ Consistent execution across all users
- ✅ Easy to add new resources (just copy workflow template)

## What's Happening Behind the Scenes

When you run the workflow:

1. **Your workflow** (in your repo) is triggered
2. **Checks out** your application code (to get tfvars)
3. **Checks out** the platform repo (to get terraform modules)
4. **Runs terraform** using your tfvars and platform modules
5. **Creates storage account** in your Azure subscription
6. **Outputs** storage account details

## Important: Edit These Values in tfvars

```hcl
# MUST CHANGE - These are unique to your application
storage_account_name = "YOUR_APP_NAME_HERE"    # e.g., "acmeappstoragedev"
resource_group_name  = "YOUR_RG_NAME_HERE"     # e.g., "acme-app-rg-dev"

# SHOULD CHANGE - Your organization info
tags = {
  team      = "your-team-name"
  owner     = "your-email"
  costcenter = "12345"
}
```

## Variables Explained

| Variable | Example | Notes |
|----------|---------|-------|
| `storage_account_name` | `mycompanystoragedev` | Must be globally unique (3-24 chars, lowercase+numbers) |
| `resource_group_name` | `mycompany-app-rg-dev` | Resource group must already exist in Azure |
| `location` | `eastus` | Must match your resource group location |
| `storage_account_tier` | `Standard` | Standard (cheaper) or Premium (faster) |
| `access_tier` | `Hot` | Hot (immediate access) or Cool (less frequently accessed) |
| `container_names` | `["logs", "data"]` | Containers to create in storage account |
| `environment` | `dev` | Tag for environment identification |

## Example: Real-World Application

**Company: Acme Corp**
**App: FinanceApp**
**Teams: Dev, Staging, Prod**

### Structure
```
acme-financeapp-repo/
├── .github/
│   └── workflows/
│       └── deploy-storage.yml
├── tfvars/
│   ├── dev/storage-account.tfvars
│   │   storage_account_name = "acmefindevstg"
│   │   resource_group_name = "acme-financeapp-rg-dev"
│   │
│   ├── staging/storage-account.tfvars
│   │   storage_account_name = "acmefinstagstg"
│   │   resource_group_name = "acme-financeapp-rg-staging"
│   │
│   └── prod/storage-account.tfvars
│       storage_account_name = "acmefinprodstg"
│       resource_group_name = "acme-financeapp-rg-prod"
```

### Deployment Steps
1. Developer: Push code change or click Actions → Deploy Storage → choose "dev"
2. GitHub Actions: Runs workflow → creates storage in acme-financeapp-rg-dev
3. Developer: Gets notified with storage account ID and name
4. Developer: Configures application to use the storage account

## Monitoring Deployment

In GitHub → Actions tab:
- ✅ See each step (init, plan, apply)
- ✅ Check for errors in real-time
- ✅ View final output with storage account details
- ✅ Download logs if needed

## Next Steps After Deployment

Once storage account is created:

1. **Configure Application**
   ```
   Connection String: (from workflow output)
   Storage Account Name: (from workflow output)
   ```

2. **Upload Initial Data** (if needed)
   ```bash
   az storage container create --account-name <storage-name> --name mydata
   az storage blob upload --account-name <storage-name> --container-name mydata --file myfile.txt
   ```

3. **Set Access Policies**
   ```bash
   az storage account update --resource-group <rg-name> --name <storage-name> --allow-shared-key-access true
   ```

4. **Monitor & Backup**
   - Enable soft delete on containers
   - Configure lifecycle policies
   - Set up backup to another region

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| "Storage account already exists" | Change `storage_account_name` to unique value |
| "Resource group not found" | Create RG: `az group create --name <rg-name> --location eastus` |
| "Permission denied" | Ensure service principal has Contributor role |
| "tfvars not found" | Check tfvars path matches your environment choice |
| "Terraform init failed" | Check Azure credentials are valid |

## Support

Need help? Check:
1. [USER_REPO_SETUP_GUIDE.md](../USER_REPO_SETUP_GUIDE.md) - Full detailed guide
2. [COMPLETE_ARCHITECTURE.md](../COMPLETE_ARCHITECTURE.md) - System design
3. [MODULE_DEPENDENCY_GUIDE.md](../MODULE_DEPENDENCY_GUIDE.md) - Dependency info

