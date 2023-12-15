resource "google_compute_region_network_endpoint_group" "default" {
  name                  = "dashboard-cloud-run-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  cloud_run {
    service = var.cloud_run_service_name
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  name    = "dashboard-cloud-run-lb"
  project = var.project_id

  ssl                             = true
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = true

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.default.id
        }
      ]
      enable_cdn              = false
      security_policy         = google_compute_security_policy.policy.id
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = true
        oauth2_client_id     = google_iap_client.default.client_id
        oauth2_client_secret = google_iap_client.default.secret
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
}

resource "google_compute_security_policy" "policy" {
  name     = "dashboard-lb-policy"
  project  = var.project_id

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}

data "google_project" "default" {
  project_id = var.project_id
}

resource "google_iap_client" "default" {
  display_name = "dashboard-iap-client"
  brand        = "projects/${data.google_project.default.number}/brands/${data.google_project.default.number}"
}

resource "google_iap_web_iam_member" "iap_iam" {
  project = var.project_id
  role    = "roles/iap.httpsResourceAccessor"
  member  = "domain:${var.workspace}"
}

resource "google_project_service_identity" "iap_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "iap.googleapis.com"
}

resource "google_cloud_run_service_iam_member" "allow_iap" {
  project  = var.project_id
  service  = var.cloud_run_service_name
  location = var.region
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_project_service_identity.iap_sa.email}"
}

output "external_ip" {
  value = module.lb-http.external_ip
}
