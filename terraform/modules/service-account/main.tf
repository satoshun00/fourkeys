resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.account_id
  description  = var.description
  display_name = var.account_id
}

resource "google_project_iam_member" "project" {
  project  = var.project_id
  for_each = toset(var.roles)
  role     = each.key
  member   = "serviceAccount:${google_service_account.sa.email}"
}
