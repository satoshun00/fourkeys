variable "project_id" {
  type = string
}
variable "account_id" {
  type = string
}
variable "description" {
  type = string
}
variable "roles" {
  type    = list(string)
  default = []
}

output "account_id" {
  value = google_service_account.sa.account_id
}
output "name" {
  value = google_service_account.sa.name
}
output "email" {
  value = google_service_account.sa.email
}