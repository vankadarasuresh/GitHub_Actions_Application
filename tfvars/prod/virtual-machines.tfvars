# Virtual Machines Configuration - Production Environment
#
# ⚠️  PRODUCTION CONFIGURATION - CRITICAL REQUIREMENTS
#
# This file contains production-specific values for your virtual machines.
# Copy this file to your application repository at: tfvars/prod/virtual-machines.tfvars
# Then customize the values below for your application.

# ============================================================================
# REQUIRED: Resource Group Configuration
# ============================================================================

resource_group_name = "my-app-rg-prod"  # CHANGE THIS - Name of your production resource group
location            = "eastus"          # CHANGE THIS - Azure region (match your RG)

# ============================================================================
# REQUIRED: Environment & Tagging (PRODUCTION-SPECIFIC)
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
  DataClass     = "Confidential"
  Compliance    = "PCI-DSS,HIPAA"
  BackupPolicy  = "Daily"
  DisasterRecovery = "Cross-Region"
  SLA          = "99.99"
}

# ============================================================================
# REQUIRED: Virtual Machine Configuration
# ============================================================================

# Number of VMs to create (Production: typically 2+ for HA)
vm_count = 2

# VM name prefix (e.g., "myapp-prod-vm-1", "myapp-prod-vm-2")
vm_name_prefix = "myapp-prod-vm"

# VM size - Production should use larger sizes
# Medium: Standard_B2s, Standard_D2s_v3
# Large: Standard_D4s_v3, Standard_E2s_v3
vm_size = "Standard_D2s_v3"  # Production - medium size for performance

# Image configuration
image_publisher = "Canonical"
image_offer     = "UbuntuServer"
image_sku       = "18.04-LTS"

# Admin user configuration
admin_username = "azureuser"
# Note: SSH keys should be provided via terraform variables
# Never hardcode passwords

# ============================================================================
# PRODUCTION: Networking (High Availability)
# ============================================================================

# Virtual network name and subnet
vnet_name           = "my-app-vnet-prod"
subnet_name         = "my-app-subnet-prod"
vnet_address_space  = "10.0.0.0/16"
subnet_address_prefix = "10.0.1.0/24"

# For production, consider multiple subnets/availability zones
# Enable public IP only if necessary (use Load Balancer instead)
enable_public_ip = false  # Production: use Load Balancer for ingress

# ============================================================================
# PRODUCTION: Security (MANDATORY)
# ============================================================================

enable_https_traffic_only = true
min_tls_version           = "TLS1_2"

# ============================================================================
# PRODUCTION: Monitoring (MANDATORY)
# ============================================================================

enable_diagnostics = true  # MANDATORY for production

# ============================================================================
# PRODUCTION CHECKLIST
# ============================================================================

# Before deploying to production, verify:
#
# ☑️  VM count is set to 2+ for high availability
# ☑️  VM size is appropriate for workload (D2s_v3 or larger)
# ☑️  HTTPS enforced (enable_https_traffic_only = true)
# ☑️  TLS 1.2 enforced (min_tls_version = TLS1_2)
# ☑️  Diagnostics enabled (enable_diagnostics = true)
# ☑️  Public IP disabled (enable_public_ip = false)
# ☑️  Load Balancer configured for HA
# ☑️  SSH keys secured and stored in Key Vault
# ☑️  Network Security Groups configured
# ☑️  Backup policies configured
# ☑️  Monitoring/alerting set up
# ☑️  OS hardening completed per security policy
# ☑️  Antivirus/antimalware installed
# ☑️  Log forwarding to central logging system configured

# ============================================================================
# NOTES FOR PRODUCTION ENVIRONMENT
# ============================================================================
# - Use larger VM sizes (D2s_v3 or larger) for performance
# - Deploy at least 2 VMs for high availability
# - Disable public IP, use Load Balancer instead
# - Enable diagnostics for monitoring and auditing
# - Enforce TLS1.2 for all communications
# - SSH keys should be in Azure Key Vault
# - Configure Network Security Groups for access control
# - Set up backup and disaster recovery
