resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  project                 = var.project_id

  depends_on = [var.api_dependency]
}

resource "google_compute_subnetwork" "runtime" {
  for_each = var.subnets

  project       = var.project_id
  name          = "${var.name_prefix}-${each.key}"
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_global_address" "private_services" {
  project       = var.project_id
  name          = "${var.name_prefix}-psa"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services.name]
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.name_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "${var.name_prefix}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "allow_internal" {
  project = var.project_id
  name    = "${var.name_prefix}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [for s in var.subnets : s.cidr]
  priority      = 1000
}

resource "google_compute_firewall" "allow_health_checks" {
  project = var.project_id
  name    = "${var.name_prefix}-allow-hc"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  priority      = 1000
}
