###############################################################################
# Huawei Cloud provider configuration
###############################################################################

provider "huaweicloud" {
  # API credentials.
  # Fill these in via terraform.tfvars, OR export the environment variables
  # HW_ACCESS_KEY / HW_SECRET_KEY and leave the variables below null.
  access_key = var.access_key
  secret_key = var.secret_key

  # Target region and project (tenant) scope.
  region     = var.region
  project_id = var.project_id
}
