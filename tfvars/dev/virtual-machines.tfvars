# Virtual Machines Configuration - Development Environment
#
# This file contains development-specific values for your virtual machines.
# Copy this file to your application repository at: tfvars/dev/virtual-machines.tfvars
# Then customize the values below for your application.

# ============================================================================
# REQUIRED: Resource Group Configuration
# ============================================================================

resource_group_name = "my-app-rg-dev"  # CHANGE THIS - Name of your resource group
location            = "eastus"         # CHANGE THIS - Azure region (match your RG)

# ============================================================================
# REQUIRED: Environment & Tagging
# ============================================================================

environment = "dev"

tags = {
  Environment  = "dev"
  Application  = "my-app"
  Team         = "application-team"
  CostCenter   = "12345"
  Owner        = "your-email@company.com"
  ManagedBy    = "Terraform"
}

# ============================================================================
# REQUIRED: Virtual Machine Configuration
# ============================================================================

# Number of VMs to create
vm_count = 1

# VM name prefix (e.g., "myapp-dev-vm-1", "myapp-dev-vm-2")
vm_name_prefix = "myapp-dev-vm"

# VM size - Options: Standard_B1s, Standard_B2s, Standard_D2s_v3
vm_size = "Standard_B1s"  # Development - small size to minimize costs

# Image configuration
image_publisher = "Canonical"
image_offer     = "UbuntuServer"
image_sku       = "18.04-LTS"

# Admin user configuration
admin_username = "azureuser"
# Note: SSH keys should be provided via terraform variables
# Never hardcode passwords

# ============================================================================
# OPTIONAL: Networking
# ============================================================================

# Virtual network name and subnet
vnet_name           = "my-app-vnet-dev"
subnet_name         = "my-app-subnet-dev"
vnet_address_space  = "10.0.0.0/16"
subnet_address_prefix = "10.0.1.0/24"

# Enable public IP (set to false for private VMs)
enable_public_ip = true

# ============================================================================
# OPTIONAL: Security
# ============================================================================

enable_https_traffic_only = true
min_tls_version           = "TLS1_2"

# ============================================================================
# OPTIONAL: Monitoring
# ============================================================================

enable_diagnostics = false  # Set to true for production

# ============================================================================
# NOTES FOR DEV ENVIRONMENT
# ============================================================================
# - Use small VM sizes (B1s) to minimize costs
# - Disable diagnostics to reduce overhead
# - Single VM sufficient for development
# - Public IP enabled for easy access
