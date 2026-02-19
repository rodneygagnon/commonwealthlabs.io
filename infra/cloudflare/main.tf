# =============================================================================
# OPUSPOPULI.ORG Cloudflare Infrastructure
# =============================================================================
#
# Static landing page hosted on Cloudflare Pages. Terraform manages the
# Pages project, custom domain attachments, and DNS records.
#
# Multi-environment via Terraform workspaces:
#   terraform workspace new prod
#   terraform workspace select prod
#   terraform apply -var-file=environments/prod.tfvars
#
# Environments:
#   dev  — No custom domain (preview on .pages.dev)
#   prod — Custom domain: opuspopuli.org + www.opuspopuli.org
#
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# -----------------------------------------------------------------------------
# Local values — workspace-aware naming
# -----------------------------------------------------------------------------

locals {
  environment = terraform.workspace
  name_prefix = "opuspopuli-landing-${local.environment}"
}
