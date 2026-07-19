resource "google_compute_region_network_endpoint_group" "web" {
  name                  = "${var.name_prefix}-web-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.web_service_name
  }
}

resource "google_compute_region_network_endpoint_group" "api" {
  name                  = "${var.name_prefix}-api-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.api_service_name
  }
}

resource "google_compute_backend_service" "web" {
  name = "${var.name_prefix}-web-backend"
  # Serverless NEG → Cloud Run は HTTP が一般的（クライアント向け TLS は LB で終端）
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = var.security_policy_self_link

  backend {
    group = google_compute_region_network_endpoint_group.web.id
  }

  enable_cdn = var.enable_cdn

  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode                   = "CACHE_ALL_STATIC"
      default_ttl                  = 3600
      client_ttl                   = 3600
      max_ttl                      = 86400
      negative_caching             = true
      serve_while_stale            = 86400
      signed_url_cache_max_age_sec = 0

      cache_key_policy {
        include_host         = true
        include_protocol     = true
        include_query_string = false
      }
    }
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_backend_service" "api" {
  name                  = "${var.name_prefix}-api-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = var.security_policy_self_link

  backend {
    group = google_compute_region_network_endpoint_group.api.id
  }

  # API はキャッシュしない
  enable_cdn = false

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_url_map" "web" {
  name            = "${var.name_prefix}-url-map"
  default_service = google_compute_backend_service.web.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "main"
  }

  path_matcher {
    name            = "main"
    default_service = google_compute_backend_service.web.id

    path_rule {
      paths   = ["/api", "/api/*"]
      service = google_compute_backend_service.api.id
    }
  }
}

resource "google_compute_managed_ssl_certificate" "web" {
  count = var.domain != "" ? 1 : 0

  name = "${var.name_prefix}-cert"

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_target_https_proxy" "web" {
  count = var.domain != "" ? 1 : 0

  name             = "${var.name_prefix}-https-proxy"
  url_map          = google_compute_url_map.web.id
  ssl_certificates = [google_compute_managed_ssl_certificate.web[0].id]
}

resource "google_compute_global_forwarding_rule" "https" {
  count = var.domain != "" ? 1 : 0

  name                  = "${var.name_prefix}-https-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.web[0].id
  ip_address            = google_compute_global_address.lb.id
}

# HTTP → HTTPS redirect（ドメイン指定時） / ドメイン未指定時は HTTP のみで学習開始
resource "google_compute_url_map" "http_redirect" {
  count = var.domain != "" ? 1 : 0

  name = "${var.name_prefix}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http" {
  name    = "${var.name_prefix}-http-proxy"
  url_map = var.domain != "" ? google_compute_url_map.http_redirect[0].id : google_compute_url_map.web.id
}

resource "google_compute_global_address" "lb" {
  name = "${var.name_prefix}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.name_prefix}-http-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http.id
  ip_address            = google_compute_global_address.lb.id
}
