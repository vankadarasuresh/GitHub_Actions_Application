# Load Balancer Configuration - Development Environment
#
# This file contains development-specific values for your load balancer.
# Copy this file to your application repository at: tfvars/dev/load-balancer.tfvars
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
# REQUIRED: Load Balancer Configuration
# ============================================================================

# Load Balancer name
lb_name = "my-app-lb-dev"

# SKU - Basic (Dev) or Standard (Prod)
lb_sku = "Basic"  # Development - lower cost

# Load balancing mode
lb_allocation_method = "Static"

# Frontend IP configuration
frontend_ip_name = "my-app-frontend-dev"

# Backend pool configuration
backend_pool_name = "my-app-backend-pool-dev"

# Health probe configuration
probe_name        = "my-app-probe-dev"
probe_port        = 80
probe_protocol    = "Http"
probe_request_path = "/"

# Load balancing rule
lb_rule_name            = "my-app-rule-dev"
lb_rule_protocol        = "TCP"
lb_rule_frontend_port   = 80
lb_rule_backend_port    = 80
enable_floating_ip      = false

# ============================================================================
# OPTIONAL: Security
# ============================================================================

enable_https_traffic_only = true
min_tls_version           = "TLS1_2"

# ============================================================================
# NOTES FOR DEV ENVIRONMENT
# ============================================================================
# - Use Basic SKU for minimum cost
# - HTTP probe on port 80 for development
# - Static IP allocation
# - Single rule sufficient for development
