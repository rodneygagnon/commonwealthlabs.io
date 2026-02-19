# =============================================================================
# Outputs
# =============================================================================

output "environment" {
  description = "Current Terraform workspace/environment"
  value       = local.environment
}

output "pages_project_name" {
  description = "Cloudflare Pages project name"
  value       = cloudflare_pages_project.landing.name
}

output "pages_url" {
  description = "Cloudflare Pages default URL"
  value       = "https://${cloudflare_pages_project.landing.name}.pages.dev"
}

output "website_url" {
  description = "Public website URL"
  value       = var.enable_custom_domain ? "https://${var.domain_name}" : "https://${cloudflare_pages_project.landing.name}.pages.dev"
}
