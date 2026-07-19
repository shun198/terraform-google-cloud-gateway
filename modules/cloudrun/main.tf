resource "google_service_account" "runtime" {
  account_id   = "${var.name_prefix}-run"
  display_name = "Cloud Run runtime (${var.name_prefix})"
}

resource "google_project_iam_member" "run_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_project_iam_member" "run_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_project_iam_member" "run_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_project_iam_member" "run_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

locals {
  vpc_network = var.host_project_id != "" ? (
    startswith(var.network_name, "projects/") ? var.network_name : "projects/${var.host_project_id}/global/networks/${var.network_name}"
  ) : var.network_name

  vpc_subnetwork = var.host_project_id != "" ? (
    startswith(var.subnet_name, "projects/") ? var.subnet_name : "projects/${var.host_project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  ) : var.subnet_name
}

resource "google_artifact_registry_repository" "app" {
  location      = var.region
  repository_id = "${var.name_prefix}-app"
  description   = "Next.js / API container images"
  format        = "DOCKER"
  labels        = var.labels

  depends_on = [var.api_dependency]
}

# --- Frontend: Next.js ---
resource "google_cloud_run_v2_service" "web" {
  name     = "${var.name_prefix}-web"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  labels = var.labels

  template {
    service_account = google_service_account.runtime.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    vpc_access {
      network_interfaces {
        network    = local.vpc_network
        subnetwork = local.vpc_subnetwork
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.web_image

      ports {
        container_port = 3000
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "PORT"
        value = "3000"
      }

      # 同一 LB 配下の /api をブラウザから叩く想定（相対パス）
      env {
        name  = "NEXT_PUBLIC_API_BASE_PATH"
        value = "/api"
      }

      startup_probe {
        http_get {
          path = "/"
        }
        initial_delay_seconds = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = "/"
        }
        period_seconds = 30
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_project_iam_member.run_secret_accessor,
    google_project_iam_member.run_cloudsql_client,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "web_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.web.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# --- Backend API ---
resource "google_cloud_run_v2_service" "api" {
  name     = "${var.name_prefix}-api"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  labels = var.labels

  template {
    service_account = google_service_account.runtime.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # Cloud SQL Private IP 向け（Shared VPC 対応）
    vpc_access {
      network_interfaces {
        network    = local.vpc_network
        subnetwork = local.vpc_subnetwork
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.api_image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "PORT"
        value = "8080"
      }

      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = var.cloud_sql_connection_name
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.database_url_secret_id
            version = "latest"
          }
        }
      }

      startup_probe {
        http_get {
          path = "/api/health"
        }
        initial_delay_seconds = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = "/api/health"
        }
        period_seconds = 30
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_project_iam_member.run_secret_accessor,
    google_project_iam_member.run_cloudsql_client,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "api_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
