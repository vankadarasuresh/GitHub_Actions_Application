# Storage Account Configuration - Production Environment
# 
# ⚠️  PRODUCTION CONFIGURATION - CRITICAL REQUIREMENTS
# 
# This file contains production-specific values for your storage account.
# Copy this file to your application repository at: tfvars/prod/storage-account.tfvars
# Then customize the values below for your application.
#
# IMPORTANT: Review all settings before deploying to production!

# ============================================================================
# REQUIRED: Resource Group Configuration
# ============================================================================

resource_group_name = "my-app-rg-prod"  # CHANGE THIS - Name of your production resource group
location            = "eastus"          # CHANGE THIS - Azure region (match your RG)

# ============================================================================
# REQUIRED: Storage Account Configuration
# ============================================================================

# Storage account name MUST:
# - Be globally unique across all Azure accounts
# - Be 3-24 characters long
# - Use only lowercase letters and numbers
# - PRODUCTION RECOMMENDATION: Use a naming convention like: appname-env-storage
storage_account_name = "myappstorageprod"  # CHANGE THIS - Must be globally unique!

# Storage account tier for production
# Standard: Good for most workloads, cost-effective
# Premium: Higher throughput, lower latency (more expensive)
storage_account_tier = "Standard"

# Access tier for blob storage
# Hot: Immediate access (recommended for production)
# Cool: For infrequent access (lowers cost, higher latency)
access_tier = "Hot"

# ============================================================================
# OPTIONAL: Environment & Tagging (PRODUCTION-SPECIFIC)
# ============================================================================

environment = "prod"

# Production tags - CRITICAL for compliance and cost management
tags = {
  Environment   = "prod"
  Application   = "my-app"
  Team          = "application-team"
  CostCenter    = "67890"
  Owner         = "your-email@company.com"
  ManagedBy     = "Terraform"
  CreatedDate   = "2024-01-01"
  DataClass     = "Confidential"          # ← PRODUCTION DATA CLASSIFICATION
  Compliance    = "PCI-DSS,HIPAA"         # ← COMPLIANCE STANDARDS
  BackupPolicy  = "Daily"                 # ← BACKUP REQUIREMENTS
  DisasterRecovery = "Cross-Region"       # ← DR REQUIREMENTS
  SLA          = "99.99"                  # ← SERVICE LEVEL AGREEMENT
}

# ============================================================================
# SECURITY: Network & Encryption Settings
# ============================================================================

# CRITICAL: Require HTTPS for all connections (MANDATORY for production)
enable_https_traffic_only = true

# CRITICAL: Enforce strong TLS version (MANDATORY for production)
# TLS1.2 minimum required for production
min_tls_version = "TLS1_2"

# ============================================================================
# OPTIONAL: Containers (Blob Storage) - PRODUCTION STRUCTURE
# ============================================================================

# Production containers - Well-organized structure
container_names = [
  "app-logs",          # Application logs (audit trail)
  "app-data",          # Primary application data
  "app-backups",       # Regular backup data
  "audit-trails",      # Compliance audit logs
  "disaster-recovery"  # DR/replication data
]

# ============================================================================
# OPTIONAL: Diagnostics & Monitoring (PRODUCTION-REQUIRED)
# ============================================================================

# CRITICAL: Enable diagnostics for production (MANDATORY)
# Sends logs to Azure Log Analytics for monitoring/compliance
enable_diagnostics = true

# ============================================================================
# PRODUCTION CHECKLIST
# ============================================================================

# Before deploying to production, verify:
# 
# ☑️  Resource group exists in Azure:
#     az group create --name my-app-rg-prod --location eastus
#
# ☑️  Storage account name is globally unique:
#     az storage account check-name --name myappstorageprod
#
# ☑️  Service Principal has required permissions:
#     az role assignment create --assignee <CLIENT_ID> --role "Storage Account Contributor"
#
# ☑️  GitHub secrets are configured correctly:
#     - AZURE_CLIENT_ID
#     - AZURE_CLIENT_SECRET
#     - AZURE_SUBSCRIPTION_ID
#     - AZURE_TENANT_ID
#     - AZURE_CREDENTIALS
#
# ☑️  Compliance requirements understood:
#     - HTTPS enforced (enable_https_traffic_only = true)
#     - TLS 1.2 enforced (min_tls_version = TLS1_2)
#     - Diagnostics enabled (enable_diagnostics = true)
#     - Data classification tagged (tags.DataClass = "Confidential")
#
# ☑️  Backup/disaster recovery configured:
#     - Consider cross-region replication
#     - Set up lifecycle policies for backups
#     - Configure retention policies
#
# ☑️  Access control configured:
#     - Use Managed Identities where possible
#     - Avoid shared keys if possible
#     - Configure firewall rules to restrict access
#     - Use private endpoints for network isolation
#
# ☑️  Monitoring/alerting set up:
#     - Log Analytics workspace configured
#     - Alert rules created for critical metrics
#     - Operational dashboard created
#
# ☑️  Documentation updated:
#     - Runbook for failover procedures
#     - Contact list for on-call support
#     - Disaster recovery procedures
#
# ☑️  Testing completed:
#     - Failover test completed and documented
#     - Backup restoration test completed
#     - Performance baseline established

# ============================================================================
# PRODUCTION DEPLOYMENT NOTES
# ============================================================================
#
# SECURITY REQUIREMENTS:
# - All access via HTTPS (configured: ✓)
# - TLS 1.2 minimum (configured: ✓)
# - Diagnostics enabled (configured: ✓)
# - Network isolation recommended (Azure Private Link)
# - Managed identity recommended over connection strings
#
# COMPLIANCE & AUDIT:
# - All changes tracked in GitHub
# - Terraform state locked for safety
# - Change log maintained
# - Audit logs sent to Log Analytics
#
# BUSINESS CONTINUITY:
# - Automated backups configured
# - Multi-region replication recommended
# - RTO: Recovery Time Objective documented
# - RPO: Recovery Point Objective documented
#
# OPERATIONAL:
# - On-call support team assigned
# - Escalation procedures defined
# - SLA: 99.99% availability
# - Maintenance windows scheduled
#
# COST OPTIMIZATION:
# - Use lifecycle policies for old data
# - Archive infrequently accessed data
# - Monitor storage usage regularly
# - Review cost anomalies monthly

# ============================================================================
# EMERGENCY CONTACTS
# ============================================================================
# Platform Team Lead:  platform-lead@company.com
# Storage Specialist:  storage-admin@company.com
# Security Team:       security@company.com
# On-Call: Refer to runbook for escalation numbers

# ============================================================================
# USEFUL COMMANDS FOR PRODUCTION OPERATIONS
# ============================================================================

# View storage account details:
# az storage account show --resource-group my-app-rg-prod --name myappstorageprod

# List containers:
# az storage container list --account-name myappstorageprod --auth-mode key

# Check diagnostics settings:
# az monitor diagnostic-settings list --resource /subscriptions/...

# Test connectivity:
# az storage account check-name --name myappstorageprod

# View metrics:
# az monitor metrics list --resource /subscriptions/...

# For complete guidance, refer to:
# - USER_REPO_SETUP_GUIDE.md
# - COMPLETE_ARCHITECTURE.md
# - Azure Storage Best Practices documentation
