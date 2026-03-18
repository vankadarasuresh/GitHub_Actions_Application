# Virtual Machines Configuration - Staging Environment
#
# This file contains staging-specific values for your virtual machines.
# Copy this file to your application repository at: tfvars/staging/virtual-machines.tfvars
# Then customize the values below for your application.

resource_group_name = "my-app-rg-staging"
location            = "eastus"

environment = "staging"

tags = {
  Environment  = "staging"
  Application  = "my-app"
  Team         = "application-team"
  CostCenter   = "12345"
  Owner        = "your-email@company.com"
  ManagedBy    = "Terraform"
  DataClass    = "Internal"
}

# Number of VMs (Staging: 1-2 for cost efficiency with production-like setup)
vm_count = 1

vm_name_prefix = "myapp-stg-vm"

# Staging: Medium size for production validation
vm_size = "Standard_B2s"

image_publisher = "Canonical"
image_offer     = "UbuntuServer"
image_sku       = "18.04-LTS"

admin_username = "azureuser"

vnet_name           = "my-app-vnet-staging"
subnet_name         = "my-app-subnet-staging"
vnet_address_space  = "10.0.0.0/16"
subnet_address_prefix = "10.0.1.0/24"

enable_public_ip = true

enable_https_traffic_only = true
min_tls_version           = "TLS1_2"

enable_diagnostics = true  # Match production for validation
