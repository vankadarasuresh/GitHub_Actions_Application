# Load Balancer Configuration - Production Environment
#
# ⚠️  PRODUCTION CONFIGURATION - CRITICAL REQUIREMENTS
#
# This file contains production-specific values for your load balancer.
# Copy this file to your application repository at: tfvars/prod/load-balancer.tfvars
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
  HighAvailability = "true"
  SLA          = "99.99"
}

# ============================================================================
# REQUIRED: Load Balancer Configuration
# ============================================================================

# Load Balancer name
lb_name = "my-app-lb-prod"

# SKU - Standard for production (better performance, features)
lb_sku = "Standard"  # Production - enterprise-grade features

# Load balancing mode - Dynamic for better connection distribution
lb_allocation_method = "Dynamic"

# Frontend IP configuration
frontend_ip_name = "my-app-frontend-prod"

# Backend pool configuration
backend_pool_name = "my-app-backend-pool-prod"

# Health probe configuration - HTTPS for security
probe_name        = "my-app-probe-prod"
probe_port        = 443
probe_protocol    = "Https"
probe_request_path = "/health"

# Load balancing rule - Production configuration
lb_rule_name            = "my-app-rule-prod"
lb_rule_protocol        = "TCP"
lb_rule_frontend_port   = 443
lb_rule_backend_port    = 8443
enable_floating_ip      = true

# ============================================================================
# PRODUCTION: Security (MANDATORY)
# ============================================================================

enable_https_traffic_only = true
min_tls_version           = "TLS1_2"

# ============================================================================
# PRODUCTION CHECKLIST
# ============================================================================

# Before deploying to production, verify:
#
# ☑️  Load Balancer SKU is Standard
# ☑️  Probe is HTTPS (port 443) for security
# ☑️  Probe path is a valid health check endpoint
# ☑️  Frontend port is 443 (HTTPS)
# ☑️  Backend port matches your application port
# ☑️  Floating IP enabled for high availability
# ☑️  Health probe interval appropriate for your workload
# ☑️  SSL certificate configured on port 443
# ☑️  Network Security Group allows port 443
# ☑️  Backend pool contains all VMs for HA
# ☑️  Monitoring configured for LB metrics
# ☑️  Alerts configured for health probe failures
# ☑️  Geo-redundancy configured if needed
# ☑️  Session persistence configured (if needed)
# ☑️  Connection draining configured (if needed)

# ============================================================================
# NOTES FOR PRODUCTION ENVIRONMENT
# ============================================================================
# - Use Standard SKU for enterprise features
# - HTTPS probe on port 443 for security
# - Dynamic IP allocation for better distribution
# - Floating IP enabled for HA scenarios
# - Health probe should point to a valid endpoint
# - Monitor health probe failures closely
# - Configure alerts for backend pool health
# - Ensure SSL certificate is installed
# - Use Network Security Groups for access control
# - Set up backup frontend configurations
