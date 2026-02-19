# =============================================================================
# Cloudflare Pages — Static Landing Page (Astro)
# =============================================================================
#
# The Pages project is created here; actual file deployment is handled
# via `wrangler pages deploy ./dist` in the GitHub Actions workflow.
# =============================================================================

resource "cloudflare_pages_project" "landing" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = "main"

  build_config {
    build_command   = "npm run build"
    destination_dir = "dist"
  }

  deployment_configs {
    production {
      compatibility_date = "2025-02-01"
    }
    preview {
      compatibility_date = "2025-02-01"
    }
  }
}

# -----------------------------------------------------------------------------
# Custom Domain Attachments
# -----------------------------------------------------------------------------

resource "cloudflare_pages_domain" "root" {
  count        = var.enable_custom_domain ? 1 : 0
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.landing.name
  domain       = var.domain_name
}

resource "cloudflare_pages_domain" "www" {
  count        = var.enable_custom_domain ? 1 : 0
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.landing.name
  domain       = "www.${var.domain_name}"
}
