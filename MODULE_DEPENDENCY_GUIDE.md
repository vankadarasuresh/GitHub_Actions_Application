# Terraform Module Dependency Architecture

## 📊 Dependency Chain Diagram

```
┌────────────────────────────────────────┐
│    USER'S TERRAFORM CONFIGURATION     │
│   (Different Repository - Their Repo)  │
└────────────────────────────────────────┘
                    ↓
           Calls modules from:
┌────────────────────────────────────────┐
│   PLATFORM REPOSITORY (GitHub_Actions) │
│   platform/terraform-modules/          │
└────────────────────────────────────────┘
                    ↓
        ┌───────────────────────┐
        │   RESOURCE GROUP      │ ← CREATED FIRST
        │   (Foundation)        │
        └───────────────────────┘
             ↙    ↓    ↘    ↖
        ┌─────┬─────┬──────┬─────┐
        ↓     ↓     ↓      ↓     ↓
      [RG]  [RG]  [RG]   [RG]  [RG]
        ↓     ↓     ↓      ↓
    ┌──────────────────────────────────┐
    │  RESOURCE MODULES                │
    ├──────────────────────────────────┤
    │ • Storage Account                │ ← Uses RG outputs
    │ • Virtual Machines               │ ← Uses RG outputs  
    │ • Load Balancer                  │ ← Uses RG outputs
    │ • [Other Modules]                │ ← Uses RG outputs
    └──────────────────────────────────┘
```

## 🔄 Execution Order

```
Step 1: terraform init
├─ Downloads provider plugins
└─ Fetches remote modules from GitHub_Actions repo

Step 2: terraform plan
├─ Reads resource_group module ✓
├─ Reads storage_account module ✓
├─ Identifies dependencies
└─ Shows creation order

Step 3: terraform apply
├─ Phase 1: Create Resource Group
│  ├─ azurerm_resource_group.main
│  └─ Outputs: name, location, tags
│
├─ Phase 2: Create Storage Account
│  ├─ Uses resource_group.name as input
│  ├─ azurerm_storage_account.main
│  ├─ azurerm_storage_container.main[*]
│  └─ Outputs: account name, keys, endpoints
│
├─ Phase 3 (optional): Create VMs
│  ├─ Uses resource_group.name as input
│  ├─ azurerm_virtual_network.main
│  ├─ azurerm_linux_virtual_machine.main[*]
│  └─ Outputs: VM IDs, IP addresses
│
└─ Phase 4 (optional): Create Load Balancer
   ├─ Uses resource_group.name as input
   ├─ azurerm_lb.main
   ├─ azurerm_lb_backend_address_pool.main
   └─ Outputs: LB IP, FQDN
```

## 📋 Module Calling Pattern

### Pattern 1: Resource Group Module (Always First)

```hcl
module "resource_group" {
  source = "git::https://github.com/your-org/GitHub_Actions.git//platform/terraform-modules/resource-group?ref=main"

  # ✅ User provides these:
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # ✅ Outputs:
  # - resource_group_name
  # - location
  # - tags
}
```

### Pattern 2: Any Resource Module (Uses RG Outputs)

```hcl
module "storage_account" {
  source = "git::https://github.com/your-org/GitHub_Actions.git//platform/terraform-modules/storage-account?ref=main"

  # ✅ CRITICAL: Pass RG outputs as inputs
  resource_group_name = module.resource_group.resource_group_name  ← From RG module
  location            = module.resource_group.location             ← From RG module
  tags                = module.resource_group.tags                 ← From RG module

  # ✅ Resource-specific inputs:
  storage_account_name     = var.storage_account_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  # ... more config

  # ✅ Explicit dependency:
  depends_on = [module.resource_group]
}
```

## 🔗 Variable Flow

```
User's terraform.tfvars
        ↓
User's variables.tf (defines var.*)
        ↓
User's main.tf (calls modules)
        ├─ module.resource_group (receives: environment, location, tags)
        │  └─ Outputs: resource_group_name, location, tags
        │
        └─ module.storage_account (receives: RG outputs + other vars)
           └─ Uses: resource_group_name, location, tags from RG
```

## ✅ Step-by-Step Example

### User's File Structure
```
my-infrastructure/
├── environments/
│   └── prod/
│       ├── main.tf           ← Module calls
│       ├── variables.tf      ← Variable definitions
│       ├── terraform.tfvars  ← Variable values
│       └── outputs.tf        ← What to return
└── .gitignore
```

### User's main.tf
```hcl
terraform {
  required_providers {
    azurerm = { version = "~> 3.0" }
  }
}

provider "azurerm" {
  features {}
}

# STEP 1: Call resource group module (from GitHub_Actions repo)
module "resource_group" {
  source = "git::https://github.com/org/GitHub_Actions.git//platform/terraform-modules/resource-group?ref=main"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# STEP 2: Call storage account module (uses RG outputs)
module "storage_account" {
  source = "git::https://github.com/org/GitHub_Actions.git//platform/terraform-modules/storage-account?ref=main"
  
  # Pass RG outputs
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags
  
  # Storage config
  storage_account_name     = var.storage_account_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  depends_on = [module.resource_group]
}

# STEP 3: Call VM module (optional, also uses RG outputs)
module "vms" {
  source = "git::https://github.com/org/GitHub_Actions.git//platform/terraform-modules/virtual-machines?ref=main"
  
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags
  environment         = var.environment
  
  vm_count = 2
  vm_size  = "Standard_B2s"
  
  depends_on = [module.resource_group]
}
```

### User's variables.tf
```hcl
variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
```

### User's terraform.tfvars
```hcl
environment         = "prod"
location            = "eastus"
resource_group_name = "rg-myapp-prod"
storage_account_name = "stgmyappprod001"

tags = {
  Environment = "production"
  Team        = "platform"
}
```

### User's outputs.tf
```hcl
output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "storage_account_name" {
  value = module.storage_account.storage_account_name
}

output "storage_account_keys" {
  value     = module.storage_account.primary_access_key
  sensitive = true
}
```

### User Deploys
```bash
cd my-infrastructure/environments/prod

terraform init
terraform plan
terraform apply

# ✅ Result:
# 1. Resource group created first
# 2. Storage account created in that resource group
# 3. Both have consistent tags and location
```

## 🎯 Key Points

| Aspect | Value |
|--------|-------|
| **Resource Group Module** | Always created FIRST |
| **Output Reuse** | RG outputs → fed as inputs to other modules |
| **Dependency Chain** | RG → Storage/VMs/LB (strict order) |
| **User Responsibility** | Define variables, provide values in tfvars |
| **Platform Responsibility** | Modules handle Azure resource creation |
| **Module Location** | GitHub_Actions repo (shared platform) |
| **User Repo** | Calls modules, manages environments |

## ⚠️ Common Mistakes

```hcl
❌ WRONG: Creating RG inside storage module
module "storage" {
  source = "git::https://...storage-account"
  
  # Still creating RG here
  azurerm_resource_group "main" { ... }
}

✅ RIGHT: RG created in separate module, passed to storage
module "storage" {
  source = "git::https://...storage-account"
  
  resource_group_name = module.resource_group.resource_group_name
}
```

```hcl
❌ WRONG: Not passing RG outputs
module "storage" {
  storage_account_name = var.storage_account_name
  # location and resource_group_name missing!
}

✅ RIGHT: All required inputs passed
module "storage" {
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  storage_account_name = var.storage_account_name
}
```

---

**Summary**: Resource Group Module is the **foundation**. All other modules depend on it. Users call all modules from their repo, but resource group always creates first, then outputs flow to other modules. 🏗️
