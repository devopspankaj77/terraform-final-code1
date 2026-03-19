# How to Get Pipelines to Show in Your Azure DevOps Project

Pipelines **do not appear** in Azure DevOps until you **create** a pipeline and link it to a YAML file. Follow these steps so the pipelines show under **Pipelines** in your project.

---

## Option A: Use the root pipeline (recommended)

1. In your Azure DevOps project, go to **Pipelines** → **Pipelines**.
2. Click **New pipeline** (or **Create pipeline**).
3. Select your **repository** (e.g. Azure Repos Git, GitHub).
4. When asked how to configure the pipeline, choose **Existing Azure Pipelines YAML file**.
5. Set **Branch** to `main` (or your default branch).
6. Set **Path** to one of:
   - **`/azure-pipelines.yml`** (root – recommended; this file is the main Terraform + cost pipeline)
   - **`/.azuredevops/pipelines/terraform-infra.yml`** (same content, under .azuredevops)
7. Click **Continue** (or **Run**). If you click **Run**, the pipeline runs once and is saved. If you only **Continue**, click **Save** (and optionally **Save and run**).
8. The pipeline will now appear in **Pipelines** with the name you gave it (e.g. the repo name). You can rename it in **Pipeline settings** (e.g. "Terraform Infra - Dev/Prod").

**Required:** In the pipeline (or in a variable group), add variable **`azureSubscription`** = the **name** of your Azure Resource Manager service connection (Project Settings → Service connections).

---

## Option B: Add the “dev_updated” pipeline (scan + plan + cost)

To also use the pipeline that runs TFLint, tfsec, then Terraform plan + Infracost:

1. **Pipelines** → **New pipeline**.
2. Select the **same repository**.
3. **Existing Azure Pipelines YAML file**.
4. **Path:** **`/pipelines/dev_updated.yaml`**.
5. **Continue** → **Save** (or **Save and run**).
6. Set variable **`azureSubscription`** for this pipeline as well.

You will then have two pipelines in the project (e.g. "Terraform Infra" and "Terraform Dev - Scan & Plan").

---

## Why pipelines weren’t showing

- Azure DevOps does **not** auto-create a pipeline just because a YAML file exists in the repo.
- You must **create a pipeline** in the UI and point it to the YAML file (e.g. **`/azure-pipelines.yml`** or **`/.azuredevops/pipelines/terraform-infra.yml`**).
- Putting the main pipeline at **repo root** as **`azure-pipelines.yml`** makes it easy to select when you choose “Existing Azure Pipelines YAML file.”

---

## Summary

| Pipeline purpose              | YAML path to select when creating pipeline |
|------------------------------|--------------------------------------------|
| Terraform plan + cost + apply (dev/prod) | **`/azure-pipelines.yml`** or **`/.azuredevops/pipelines/terraform-infra.yml`** |
| Scan (TFLint, tfsec) + Plan + Cost      | **`/pipelines/dev_updated.yaml`**          |

After creating each pipeline once as above, they will appear under **Pipelines** and you can run them from the project.
