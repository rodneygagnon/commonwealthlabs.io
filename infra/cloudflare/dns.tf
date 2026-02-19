# =============================================================================
# Cloudflare DNS Records
# =============================================================================

# Root domain → Pages
resource "cloudflare_record" "root" {
  count           = var.enable_custom_domain ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "@"
  content         = "${var.pages_project_name}.pages.dev"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
  comment         = "Root domain → Cloudflare Pages (${local.name_prefix})"
}

# www → Pages
resource "cloudflare_record" "www" {
  count           = var.enable_custom_domain ? 1 : 0
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  content         = "${var.pages_project_name}.pages.dev"
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
  comment         = "www → Cloudflare Pages (${local.name_prefix})"
}
