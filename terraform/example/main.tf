module "fourkeys" {
  source              = "../modules/fourkeys"
  project_id          = var.project_id
  enable_apis         = var.enable_apis
  region              = var.region
  bigquery_region     = var.bigquery_region
  parsers             = var.parsers
}

module "github_actions_runner" {
  source = "../modules/service-account"

  project_id  = var.project_id
  account_id  = "github-actions-runner"
  description = "Github Actionsのスクリプト上で使用する、デプロイメントユーザー(terraform管理)"
  roles = [
    "roles/cloudbuild.builds.builder"
  ]
}

module "github_oidc" {
  source                = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id            = var.project_id
  pool_id               = "github-actions-pool"
  pool_display_name     = "github-actions-pool"
  pool_description      = "Github Actionsにgithub-actions-runnerサービスアカウントの権限借用を行う設定 (terraform管理)"
  provider_id           = "github-actions-provider"
  provider_display_name = "github-actions-provider"
  provider_description  = "Github Actionsにgithub-actions-runnerサービスアカウントの権限借用を行う設定 (terraform管理)"
  sa_mapping = {
    "github-actions-runner" = {
      sa_name   = module.github_actions_runner.name
      attribute = "attribute.repository/${var.forkeys_repo}"
    }
  }
}
