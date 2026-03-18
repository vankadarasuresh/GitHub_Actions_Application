# Pre-Deployment Checklist

Complete this checklist before running your first deployment to ensure everything is configured correctly.

## Azure Setup

- [ ] Azure subscription is active and accessible
- [ ] You have access to create resources via Azure CLI
- [ ] Service Principal (or managed identity) is set up with Contributor role
- [ ] Azure CLI is installed: `az --version`
- [ ] You are logged in to Azure: `az account show`

## GitHub Repository Setup

- [ ] Repository is a fork/clone of the platform application template
- [ ] `.github/workflows/` directory exists with workflow files
- [ ] `tfvars/` directory exists with environment subdirectories (dev, staging, prod)
- [ ] Each environment has `.tfvars` files:
  - [ ] `tfvars/dev/storage-account.tfvars`
  - [ ] `tfvars/dev/virtual-machines.tfvars`
  - [ ] `tfvars/dev/load-balancer.tfvars`
  - [ ] `tfvars/staging/` (same files)
  - [ ] `tfvars/prod/` (same files)

## GitHub Secrets Configuration

Add the following secrets to your GitHub repository:
**Settings → Secrets and variables → Actions → Repository secrets**

### Required Secrets

- [ ] **AZURE_SUBSCRIPTION_ID** — Your Azure subscription ID
  ```bash
  az account show --query id -o tsv
  ```

- [ ] **AZURE_TENANT_ID** — Your Azure AD tenant ID
  ```bash
  az account show --query tenantId -o tsv
  ```

- [ ] **AZURE_CLIENT_ID** — Service Principal Client ID
  ```bash
  # If you have a service principal:
  az ad sp show --id <service-principal-id> --query appId -o tsv
  ```

- [ ] **AZURE_CLIENT_SECRET** — Service Principal Password/Secret
  - Store this securely (only you should know it)
  - Create new client secret if needed:
    ```bash
    az ad sp credential reset --id <service-principal-id> --credential-description "GitHub Actions" --years 2
    ```

- [ ] **AZURE_CREDENTIALS** — Full JSON credentials (optional backup)
  - Format:
    ```json
    {
      "clientId": "your-client-id",
      "clientSecret": "your-client-secret",
      "subscriptionId": "your-subscription-id",
      "tenantId": "your-tenant-id"
    }
    ```

- [ ] **ARM_ACCESS_KEY** — Azure Storage Account Access Key
  - For Terraform state backend
  ```bash
  az storage account keys list \
    --resource-group <rg-name> \
    --account-name <storage-account-name> \
    --query '[0].value' -o tsv
  ```

## Workflow Configuration

### Step 1: Update Platform Repository Reference

Edit each workflow file and customize these values:
- `PLATFORM_REPO_OWNER` — Your GitHub organization name
- `PLATFORM_REPO_NAME` — Your platform repository name
- `PLATFORM_REPO_REF` — Branch or tag (main, v1.0.0, etc.)

Files to update:
- [ ] `.github/workflows/deploy-storage.yml`
- [ ] `.github/workflows/deploy-vms.yml`
- [ ] `.github/workflows/deploy-loadbalancer.yml`

**Example:**
```yaml
env:
  PLATFORM_REPO_OWNER: "my-company"              # your-org
  PLATFORM_REPO_NAME: "platform-terraform"        # platform repo name
  PLATFORM_REPO_REF: "main"                        # main branch
```

### Step 2: Verify Platform Workflow Names

Confirm that these platform reusable workflows exist in your platform repository:
- [ ] `.github/workflows/platform-deploy-storage.yml`
- [ ] `.github/workflows/platform-deploy-vm.yml`
- [ ] `.github/workflows/platform-deploy-loadbalancer.yml`

## Terraform State Backend

- [ ] Azure Storage Account created for Terraform state
- [ ] Storage containers created (dev-state, staging-state, prod-state)
- [ ] `backend.tf` file in repository root (use template from platform)
- [ ] `ARM_ACCESS_KEY` secret configured in GitHub

**Verify:**
```bash
# Check that terraform init works
terraform init

# Check current backend state
terraform state list
```

## Environment-Specific Configuration

### Development Environment (`tfvars/dev/*.tfvars`)

- [ ] Resource names updated for dev environment (include "dev" in names)
- [ ] VM count reasonable for testing (e.g., 1-2 VMs)
- [ ] Storage account tier set to "Standard" for cost savings
- [ ] Sample values verified:
  ```
  environment              = "dev"
  location                 = "eastus"
  resource_group_name      = "rg-dev-app"
  storage_account_name     = "stdevapp123"
  ```

### Staging Environment (`tfvars/staging/*.tfvars`)

- [ ] Resource names updated for staging
- [ ] Closer to production specification
- [ ] Storage replication set to "GRS" or "RAGRS" for redundancy
- [ ] Health probe intervals appropriate for load balancing

### Production Environment (`tfvars/prod/*.tfvars`)

- [ ] ⚠️ **CRITICAL**: Production resource names are final
- [ ] High availability configuration enabled
- [ ] Storage account tier "Premium" or high-performance "Standard"
- [ ] Replication type is "GRS" or "RAGZRS"
- [ ] Load balancer SKU is "Standard"
- [ ] All VMs have production-grade sizing (Standard_D2s_v3 or higher)

## First Deployment Test

### Test with Development Environment

1. **Validate Terraform locally:**
   ```bash
   terraform validate
   terraform plan -var-file=tfvars/dev/storage-account.tfvars
   ```

2. **Run workflow via GitHub UI:**
   - Go to Actions
   - Select "Deploy Storage Account to Azure"
   - Click "Run workflow"
   - Select "dev" environment
   - Wait for completion

3. **Verify resources in Azure:**
   ```bash
   # List resource groups
   az group list --output table
   
   # List resources in group
   az resource list --resource-group rg-dev-app
   
   # List storage accounts
   az storage account list --output table
   ```

4. **Check Terraform outputs:**
   - Workflow should display storage account ID and name
   - Terraform state should be in Azure Storage (not local)

## Troubleshooting

### Workflow Fails at "Authenticate to Azure"

**Issue:** Error: `ClientAuthenticationError`

**Solution:**
- [ ] Verify `AZURE_CREDENTIALS` or `AZURE_CLIENT_ID`/`AZURE_CLIENT_SECRET` are correct
- [ ] Confirm service principal has Contributor role on subscription
- [ ] Check that secrets are not expired

### "terraform init" Fails

**Issue:** Error: `no backend config`

**Solution:**
- [ ] Verify `backend.tf` file exists in repository root
- [ ] Confirm `ARM_ACCESS_KEY` is set as environment variable
- [ ] Check storage account and container names match backend.tf

### Workflow References Platform Incorrectly

**Issue:** Workflow says `workflow not found`

**Solution:**
- [ ] Verify `PLATFORM_REPO_OWNER` matches your GitHub organization
- [ ] Verify `PLATFORM_REPO_NAME` matches exact platform repo name
- [ ] Confirm workflow files exist in platform repo with exact names

## Documentation Links

- Platform Overview: See [README.md](README.md)
- How Workflows Work: See [HOW_PLATFORM_WORKFLOWS_WORK.md](HOW_PLATFORM_WORKFLOWS_WORK.md)
- Module Dependencies: See [MODULE_DEPENDENCY_GUIDE.md](MODULE_DEPENDENCY_GUIDE.md)
- Multi-Repo Setup: See [MULTI_REPO_DEPLOYMENT_GUIDE.md](MULTI_REPO_DEPLOYMENT_GUIDE.md)

## Support

If you encounter issues:

1. **Check GitHub Actions Run Logs**
   - Actions → Select workflow run → View logs
   - Look for error messages at terraform plan/apply stage

2. **Check Azure Resources**
   - Azure Portal or Azure CLI to verify resource creation

3. **Validate Terraform**
   - Run `terraform validate` locally to catch syntax errors
   - Run `terraform plan` to see what will be created

4. **Review Module Documentation**
   - Check [terraform-modules/](terraform-modules/) README files
   - Verify all required variables are provided

---

**Checklist Complete!** You're ready to start your first deployment.
