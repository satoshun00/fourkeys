resource "google_cloud_run_service" "dashboard" {
  count    = var.enable_dashboard ? 1 : 0
  name     = "fourkeys-grafana-dashboard"
  location = var.region
  project  = var.project_id
  template {
    spec {
      containers {
        ports {
          name           = "http1"
          container_port = 3000
        }
        image = local.dashboard_container_url
        env {
          name  = "PROJECT_NAME"
          value = var.project_id
        }
        env {
          name  = "GF_SERVER_ROOT_URL"
          value = "https://${var.domain}"
        }
        env {
          name  = "GF_AUTH_JWT_ENABLED"
          value = "true"
        }
        env {
          name  = "GF_AUTH_JWT_HEADER_NAME"
          value = "X-Goog-Iap-Jwt-Assertion"
        }
        env {
          name  = "GF_AUTH_JWT_USERNAME_CLAIM"
          value = "email"
        }
        env {
          name  = "GF_AUTH_JWT_EMAIL_CLAIM"
          value = "email"
        }
        env {
          name  = "GF_AUTH_JWT_JWK_SET_URL"
          value = "https://www.gstatic.com/iap/verify/public_key-jwk"
        }
        env {
          name  = "GF_AUTH_JWT_EXPECTED_CLAIMS"
          value = "{\"iss\": \"https://cloud.google.com/iap\"}"
        }
        env {
          name  = "GF_AUTH_JWT_AUTO_SIGN_UP"
          value = "true"
        }
        env {
          name = "GF_USERS_AUTO_ASSIGN_ORG_ROLE"
          value = "Viewer"
        }
        env {
          name = "GF_USERS_VIEWERS_CAN_EDIT"
          value = "true"
        }
        env {
          name = "GF_USERS_EDITORS_CAN_ADMIN"
          value = "false"
        }
      }
      service_account_name = google_service_account.fourkeys.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata {
    labels = { "created_by" : "fourkeys" }
  }
  autogenerate_revision_name = true
  depends_on = [
    time_sleep.wait_for_services
  ]
}

output "cloud_run_dashboard_name" {
  value = google_cloud_run_service.dashboard.0.name
}
