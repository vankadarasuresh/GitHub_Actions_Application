# Storage Account Configuration - Staging Environment
# 
# This file contains staging-specific values for your storage account.
# Copy this file to your application repository at: tfvars/staging/storage-account.tfvars
# Then customize the values below for your application.

# ============================================================================
# REQUIRED: Resource Group Configuration
# ============================================================================

resource_group_name = "my-app-rg-staging"  # CHANGE THIS - Name of your staging resource group
location            = "eastus"             # CHANGE THIS - Azure region (match your RG)

# ============================================================================
# REQUIRED: Storage Account Configuration
# ============================================================================

# Storage account name MUST:
# - Be globally unique across all Azure accounts
# - Be 3-24 characters long
# - Use only lowercase letters and numbers
storage_account_name = "myappstoraging"  # CHANGE THIS - Must be globally unique!

# Storage account tier - Staging often uses Standard with potential for Premium
storage_account_tier = "Standard"

# Access tier - Hot for quick access during testing
access_tier = "Hot"

# ============================================================================
# OPTIONAL: Environment & Tagging
# ============================================================================

environment = "staging"

# Tags help organize and track resources
tags = {
  Environment  = "staging"
  Application  = "my-app"
  Team         = "application-team"
  CostCenter   = "12345"
  Owner        = "your-email@company.com"
  ManagedBy    = "Terraform"
  CreatedDate  = "2024-01-01"
  DataClass    = "Internal"  # Staging-specific tagging
}

# ============================================================================
# OPTIONAL: Security & Network
# ============================================================================

# Require HTTPS for all connections (recommended)
enable_https_traffic_only = true

# Minimum TLS version - Enforce TLS1.2 for staging
min_tls_version = "TLS1_2"

# ============================================================================
# OPTIONAL: Containers (Blob Storage)
# ============================================================================

# List of containers to create - Match production structure
container_names = [
  "app-logs",
  "app-data",
  "app-backups",
  "staging-validation"  # Additional container for staging validation
]

# ============================================================================
# OPTIONAL: Diagnostics & Monitoring
# ============================================================================

# Enable diagnostics for staging (useful for pre-prod validation)
enable_diagnostics = true

# ============================================================================
# NOTES FOR STAGING ENVIRONMENT
# ============================================================================
# - Use Standard tier (cost-effective)
# - Enable diagnostics to match production
# - Enforce TLS1.2 for security testing
# - Use same container structure as production for validation
# - Can serve as pre-production smoke testing
# - Good for load testing and performance validation
