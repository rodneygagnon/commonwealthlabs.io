# =============================================================================
# Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Cloudflare Account
# -----------------------------------------------------------------------------

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:DNS:Edit and Account:Pages:Edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
}

# -----------------------------------------------------------------------------
# Project
# -----------------------------------------------------------------------------

variable "domain_name" {
  description = "Base domain name"
  type        = string
  default     = "opuspopuli.org"
}

variable "pages_project_name" {
  description = "Name of the Cloudflare Pages project"
  type        = string
  default     = "opuspopuli-landing"
}

# -----------------------------------------------------------------------------
# Feature Toggles (per-environment via tfvars)
# -----------------------------------------------------------------------------

variable "enable_custom_domain" {
  description = "Attach custom domain to Pages and create DNS records"
  type        = bool
  default     = false
}
