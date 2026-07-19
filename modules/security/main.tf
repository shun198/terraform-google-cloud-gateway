# Cloud Armor = GCP の WAF 相当
resource "google_compute_security_policy" "waf" {
  name        = "${var.name_prefix}-waf"
  description = "Study WAF policy for Global HTTPS LB"

  # Default: allow (study). Production では default deny + allow list を推奨。
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow"
  }

  dynamic "rule" {
    for_each = length(var.allowed_ingress_cidrs) > 0 && !(length(var.allowed_ingress_cidrs) == 1 && var.allowed_ingress_cidrs[0] == "*") ? [1] : []
    content {
      action   = "allow"
      priority = 1000
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = var.allowed_ingress_cidrs
        }
      }
      description = "Explicit allow list"
    }
  }

  # OWASP 系の事前構成ルール（学習用に preview=true）
  rule {
    action   = "deny(403)"
    priority = 2000
    preview  = true
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "SQLi protection (preview)"
  }

  rule {
    action   = "deny(403)"
    priority = 2010
    preview  = true
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "XSS protection (preview)"
  }

  # 簡易レート制限
  rule {
    action   = "throttle"
    priority = 3000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 500
        interval_sec = 60
      }
    }
    description = "Per-IP throttle"
  }

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}
