# Load Balancer Configuration - Staging Environment
#
# This file contains staging-specific values for your load balancer.
# Copy this file to your application repository at: tfvars/staging/load-balancer.tfvars
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

# Staging: Standard SKU to match production
lb_name = "my-app-lb-staging"

lb_sku = "Standard"

lb_allocation_method = "Static"

frontend_ip_name = "my-app-frontend-staging"

backend_pool_name = "my-app-backend-pool-staging"

probe_name        = "my-app-probe-staging"
probe_port        = 80
probe_protocol    = "Http"
probe_request_path = "/"

lb_rule_name            = "my-app-rule-staging"
lb_rule_protocol        = "TCP"
lb_rule_frontend_port   = 80
lb_rule_backend_port    = 80
enable_floating_ip      = false

enable_https_traffic_only = true
min_tls_version           = "TLS1_2"
