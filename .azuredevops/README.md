# Azure DevOps Pipelines – Terraform Infrastructure

This folder contains Azure DevOps (ADO) pipelines for deploying Terraform infrastructure (dev and prod).

**Pipelines don’t show in your project until you register them.** See **[PIPELINES_SETUP.md](PIPELINES_SETUP.md)** for step-by-step instructions to add the pipelines so they appear under Pipelines in Azure DevOps. The repo root also has **`azure-pipelines.yml`** so ADO can suggest it when you create a new pipeline.

## Pipeline: `pipelines/terraform-infra.yml`

**Purpose:** Run Terraform init, validate, plan, and optionally apply for a chosen environment (dev or prod).

### Parameters

| Parameter    | Description                                      | Default |
|-------------|---------------------------------------------------|---------|
| `environment` | Target environment: `dev` or `prod`             | `dev`   |
| `runApply`    | If true, runs Apply stage after Plan and publishes plan artifact | `false` |

### Required setup

1. **Azure RM service connection**  
   Create an Azure Resource Manager service connection in your ADO project (Project Settings → Service connections). The identity must have sufficient RBAC (e.g. Contributor) on the target subscription(s).

2. **Pipeline variable**  
   Set the variable **`azureSubscription`** to the **name** of that service connection (either in the pipeline UI or in a variable group linked to the pipeline).

3. **Environments (optional)**  
   Create environments `tf-dev` and `tf-prod` in Pipelines → Environments. You can add approvals and checks (e.g. manual approval for `tf-prod`) so Apply runs only after review.

### Running the pipeline

- **Plan only (default):** Run with `runApply = false`. Use this for PRs or to review plan output.
- **Plan and apply:** Run with `runApply = true`. Plan runs first; if it succeeds, the Apply stage runs (subject to environment approvals).

### Secrets and tfvars

- **Sensitive variables** (e.g. passwords, keys) must not be stored in `.tfvars` in the repo. Use:
  - **Pipeline variables** (mark as secret) and pass via `-var` or a generated tfvars in the pipeline, or  
  - **Azure Key Vault** linked to the pipeline (variable group), or  
  - **TF_VAR_*** in the pipeline so Terraform reads them from the environment.

- Ensure `dev.tfvars` / `prod.tfvars` do not contain production secrets; use placeholders and override in CI (e.g. `-var="administrator_login_password=$(sqlAdminPassword)"`).

### Remote state (optional)

To use Azure backend for Terraform state:

1. Uncomment and set the `backend "azurerm"` block in `environments/<env>/provider.tf` (or use a separate `backend.tf`).
2. Create a storage account and container for state (e.g. via a bootstrap script or separate pipeline).
3. Either:
   - Pass backend config via pipeline variables and `-backend-config` in `terraform init`, or  
   - Use a `backend.hcl` or partial config and `terraform init -backend-config=...`.

### Infrastructure cost estimation

After **Terraform Plan**, the pipeline runs **Infracost** to estimate monthly infrastructure cost and prints a table to the job log. A JSON cost report is published as artifact **`infracost-<environment>`** for downstream use. No Infracost API key is required for the default table output; optional keys enable diff and other features (see [Infracost docs](https://www.infracost.io/docs/)).

### Path filters

The pipeline is triggered on changes under:

- `modules/*`
- `environments/*`
- `.azuredevops/**`

Adjust the `trigger` and `pr` sections in `terraform-infra.yml` if you use different paths.
