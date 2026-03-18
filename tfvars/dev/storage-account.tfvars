# Storage Account Configuration - Development Environment
# 
# This file contains development-specific values for your storage account.
# Copy this file to your application repository at: tfvars/dev/storage-account.tfvars
# Then customize the values below for your application.

# ============================================================================
# REQUIRED: Resource Group Configuration
# ============================================================================

resource_group_name = "my-app-rg-dev"  # CHANGE THIS - Name of your resource group
location            = "eastus"         # CHANGE THIS - Azure region (match your RG)

# ============================================================================
# REQUIRED: Storage Account Configuration
# ============================================================================

# Storage account name MUST:
# - Be globally unique across all Azure accounts
# - Be 3-24 characters long
# - Use only lowercase letters and numbers
# - Not use hyphens (use abbreviations instead)
storage_account_name = "myappstoragdev"  # CHANGE THIS - Must be globally unique!

# Storage account tier
# Options: Standard (cheaper, for general use), Premium (faster, higher cost)
storage_account_tier = "Standard"

# Access tier for blob storage
# Options: Hot (immediate access), Cool (infrequent access), Archive (rare access)
access_tier = "Hot"

# ============================================================================
# OPTIONAL: Environment & Tagging
# ============================================================================

environment = "dev"

# Tags help organize and track resources
# Add tags relevant to your organization
tags = {
  Environment  = "dev"
  Application  = "my-app"
  Team         = "application-team"
  CostCenter   = "12345"
  Owner        = "your-email@company.com"
  ManagedBy    = "Terraform"
  CreatedDate  = "2024-01-01"
}

# ============================================================================
# OPTIONAL: Security & Network
# ============================================================================

# Require HTTPS for all connections (recommended for prod)
enable_https_traffic_only = true

# Minimum TLS version to require
# Options: TLS1_0, TLS1_1, TLS1_2 (recommended)
min_tls_version = "TLS1_2"

# ============================================================================
# OPTIONAL: Containers (Blob Storage)
# ============================================================================

# List of containers to create in the storage account
# Example: ["logs", "uploads", "backups"]
container_names = [
  "app-logs",      # Application logs
  "app-data",      # Application data
  "app-backups"    # Backup data
]

# ============================================================================
# OPTIONAL: Diagnostics & Monitoring
# ============================================================================

# Enable diagnostics (sends metrics to Log Analytics)
# Set to true for production, false for dev to reduce costs
enable_diagnostics = false

# ============================================================================
# REFERENCE: All Available Variables  
# ============================================================================
# For a complete list of variables, see the module's variables.tf file:
# platform-repo/platform/terraform-modules/storage-account/variables.tf
#
# Common variables:
# - storage_account_name: Globally unique storage account name
# - resource_group_name: Name of the resource group
# - location: Azure region
# - storage_account_tier: Standard or Premium
# - access_tier: Hot, Cool, or Archive
# - environment: Environment tag (dev, staging, prod)
# - tags: Resource tags dictionary
# - container_names: List of blob containers to create
# - enable_https_traffic_only: Require HTTPS (true recommended)
# - min_tls_version: Minimum TLS version
# - enable_diagnostics: Enable diagnostic logging

# ============================================================================
# NOTES FOR DEV ENVIRONMENT
# ============================================================================
# - Use Standard tier to minimize costs
# - Disable diagnostics to reduce storage costs
# - Use self-signed certificates in dev
# - Can use lower TLS versions for compatibility testing
# - Fine for manual/ad-hoc deployments
