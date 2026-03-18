terraform {
  backend "azurerm" {
    # Azure backend configuration for Terraform state
    # Update the values below with your environment-specific details
    
    # Resource group that contains the storage account
    resource_group_name  = "rg-terraform-state-dev"
    
    # Storage account name (must be globally unique)
    storage_account_name = "tfstatedev987"
    
    # Container name within the storage account
    container_name       = "dev-state"
    
    # State file name - IMPORTANT: This is overridden per module via CLI
    # Each workflow passes -backend-config="key=module-name.tfstate"
    # Possible values:
    #   - resource-group.tfstate (for resource group module)
    #   - storage-account.tfstate (for storage account module)
    #   - virtual-machines.tfstate (for VMs module)
    #   - load-balancer.tfstate (for load balancer module)
    key                  = "terraform.tfstate"
  }
}

# ARM_ACCESS_KEY environment variable is required for authentication
# Set it from GitHub secrets: export ARM_ACCESS_KEY=${{ secrets.ARM_ACCESS_KEY }}
# This is handled automatically by the GitHub Actions workflows
