# destroy.ps1 — Automates terraform destroy for the terraform_RPA project.
# Safe to run from any location; the script sets its own working directory.

$ErrorActionPreference = "Stop"

# --- Ensure we are in the script's directory (the project root) ---------------
$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
Set-Location $projectDir

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Yellow
Write-Host "  WARNING: This will destroy ALL Huawei Cloud resources"      -ForegroundColor Yellow
Write-Host "  managed by the Terraform project in:"                       -ForegroundColor Yellow
Write-Host "  $projectDir"                                                -ForegroundColor Yellow
Write-Host "===========================================================" -ForegroundColor Yellow
Write-Host ""

# --- Confirm before proceeding -------------------------------------------------
$confirmation = Read-Host "Type 'yes' to confirm and proceed"
if ($confirmation -ne "yes") {
    Write-Host "Aborted. No resources were destroyed." -ForegroundColor Cyan
    exit 0
}

# --- Check that terraform is available -----------------------------------------
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: 'terraform' not found in PATH. Install Terraform and try again." -ForegroundColor Red
    exit 1
}

# --- Initialize (ensures providers are downloaded) -----------------------------
Write-Host ""
Write-Host ">> Running terraform init..." -ForegroundColor Cyan
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: terraform init failed. Resolve the errors above and try again." -ForegroundColor Red
    exit 1
}

# --- Destroy all resources -----------------------------------------------------
Write-Host ""
Write-Host ">> Running terraform destroy..." -ForegroundColor Cyan
terraform destroy -auto-approve -var-file="terraform.tfvars"

# --- Report result -------------------------------------------------------------
Write-Host ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: All resources successfully destroyed." -ForegroundColor Green
    Write-Host "Note: any resources created manually outside Terraform (e.g. via the console) are NOT affected." -ForegroundColor DarkGray
} else {
    Write-Host "ERROR: Teardown failed. Some resources may still exist." -ForegroundColor Red
    Write-Host "Check the errors above, then re-run this script." -ForegroundColor Red
    Write-Host "Also verify the Huawei Cloud console for any orphaned resources." -ForegroundColor DarkGray
    exit 1
}
