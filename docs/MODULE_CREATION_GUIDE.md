# Guide: Creating a Terraform Module (Any User)

Use this note when adding a **new Azure (or other) resource module** to this project. It keeps modules consistent, spec-aligned, and easy to wire into dev/prod.

---

## 1. Module layout

Create a folder under `modules/` with a **kebab-case** name (e.g. `my-resource`).

**Minimum files:**

| File | Purpose |
|------|--------|
| `main.tf` | Resource(s) and any related resources (e.g. lock, firewall rules). |
| `variables.tf` | Input variables: required and optional, with types and descriptions. |
| `outputs.tf` | Outputs needed by root or other modules (ids, names, endpoints, etc.). |

Optional: `versions.tf` or `provider.tf` only if you need a `terraform`/`required_providers` block; **do not** add a `provider` block in the module (use root provider so the module can be used with `count`/`for_each`).

---

## 2. Naming and location

- **Folder:** `modules/<resource-type>` e.g. `modules/cosmosdb`, `modules/front-door`.
- **Naming convention (for resources in Azure):** Use the project pattern, e.g. `ICR-<nnn>-Azure-<INT|CLT>-<ResourceType>-<Workload>` (see **docs/NAMING_CONVENTION.md**). Document it in a comment at the top of `variables.tf`.
- **Azure constraints:** Some resources (e.g. Storage, ACR) do not allow hyphens in names; document that in the module.

---

## 3. Variables (`variables.tf`)

### 3.1 Spec-style header (recommended)

At the top of `variables.tf`, add a short spec line:

```hcl
# =============================================================================
# <Resource> - Enterprise Module Variables
# Spec: <required_param_1>, <required_param_2> (required); <optional_param> (optional)
# =============================================================================
```

### 3.2 Use a map of objects

- Prefer **one main variable** that is a **map of objects**, keyed by logical name (e.g. `my_resources = { "main" = { ... }, "secondary" = { ... } }`).
- This allows the root to call the module once with `count = length(var.my_resources) > 0 ? 1 : 0` and pass the whole map.

### 3.3 Required vs optional

- **Required:** No `optional(...)` and no `default`; the type must be explicit (e.g. `string`, `number`, `list(string)`).
- **Optional:** Use `optional(type, default)` so the root does not have to pass every attribute.

Example:

```hcl
variable "my_resources" {
  description = "Map of My Resource configurations. Keys are logical names."
  type = map(object({
    name                = string                    # Required
    resource_group_name = string                    # Required
    location            = string                    # Required
    sku                 = optional(string, "Standard")
    tags                = optional(map(string), {})
  }))
}
```

### 3.4 Common tags

- Add a second variable for shared tags (e.g. company-mandatory tags from root):

```hcl
variable "common_tags" {
  description = "Common tags merged with each resource's tags."
  type        = map(string)
  default     = {}
}
```

- In `main.tf`, merge with resource-specific tags: `tags = merge(var.common_tags, each.value.tags)`.

### 3.5 Sensitive data

- Mark **only the value** as sensitive when it contains secrets (e.g. passwords, connection strings). Avoid marking the **entire map** as `sensitive`, or the variable cannot be used in `for_each` keys.
- Prefer passing secrets via `TF_VAR_*` or Key Vault and document that in the variable description.

---

## 4. Main configuration (`main.tf`)

- Use `for_each = var.<main_variable>` on the primary resource so one resource is created per map entry.
- Use `merge(var.common_tags, each.value.tags)` for tags.
- For **optional child resources** (e.g. lock, firewall rules), use a `dynamic` block or a `local` that builds a map only when the optional config exists.
- **Do not** add a `provider` block inside the module; the root provides the provider.

Example (pattern only):

```hcl
resource "azurerm_my_resource" "main" {
  for_each = var.my_resources

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  # ... required and optional attributes from each.value

  tags = merge(var.common_tags, each.value.tags)
}
```

---

## 5. Outputs (`outputs.tf`)

- Export what the **root or other modules** need: `id`, `name`, FQDNs, connection strings (mark sensitive if needed), etc.

```hcl
output "ids" {
  description = "Map of resource IDs."
  value       = { for k, v in azurerm_my_resource.main : k => v.id }
}

output "names" {
  value = { for k, v in azurerm_my_resource.main : k => v.name }
}
```

- For sensitive outputs (e.g. connection strings, keys), add `sensitive = true`.

---

## 6. Security and compliance

- Follow the project’s **security baseline** (see repo security docs): e.g. HTTPS only, minimum TLS, no public access where private endpoint is used, RBAC where applicable, soft delete / purge protection for Key Vault, etc.
- Prefer **optional attributes** for security settings so the root can turn them on per environment (e.g. `create_lock`, `public_network_access_enabled`).
- Document in `variables.tf` or in the spec line which options align with the baseline.

---

## 7. Wiring the module into the root (dev/prod)

### 7.1 Add a root variable

In `environments/dev/variables.tf` (and `environments/prod/variables.tf`), add an optional variable that defaults to an empty map:

```hcl
variable "my_resources" {
  description = "Map of My Resource configurations."
  type        = any
  default     = {}
}
```

### 7.2 Add the module block

In `environments/dev/main.tf` (and prod), add:

```hcl
module "my_resource" {
  source = "../../modules/my-resource"
  count  = length(var.my_resources) > 0 ? 1 : 0

  my_resources = var.my_resources
  common_tags  = local.common_tags
}
```

- Use `count` so the module is only instantiated when at least one instance is requested.
- Pass `common_tags` from the root so company-mandatory tags apply.

### 7.3 Using the new module

In `dev.tfvars` / `prod.tfvars`, define the map when you want to create resources:

```hcl
my_resources = {
  main = {
    name                = "example-name"
    resource_group_name = "rg-example"
    location            = "eastus"
    tags                = {}
  }
}
```

---

## 8. Checklist for a new module

- [ ] Folder under `modules/<name>` with `main.tf`, `variables.tf`, `outputs.tf`.
- [ ] Spec line in `variables.tf` (required/optional parameters).
- [ ] Main variable: map of objects with required and optional attributes; optional ones use `optional(..., default)`.
- [ ] `common_tags` variable and `merge(var.common_tags, each.value.tags)` in resources.
- [ ] No provider block inside the module.
- [ ] Sensitive values not used as `for_each` keys; only sensitive *attributes* marked sensitive where needed.
- [ ] Outputs for ids/names/endpoints (and `sensitive = true` where appropriate).
- [ ] Root variable and module block added in both `environments/dev` and `environments/prod` with `count = length(var.<name>) > 0 ? 1 : 0`.
- [ ] `terraform init -backend=false` and `terraform validate` succeed from an environment directory.

---

## 9. Quick reference: variable spec table

When documenting variables (e.g. for a spec or README), you can list them in a table:

| Name | Type | Required / Optional | Description | Default |
|------|------|---------------------|-------------|---------|
| `name` | `string` | Required | Resource name | — |
| `location` | `string` | Required | Azure region | — |
| `sku` | `string` | Optional | SKU name | `"Standard"` |
| `tags` | `map(string)` | Optional | Resource tags | `{}` |

In Terraform, “Required” = no `optional()` and no `default`; “Optional” = `optional(type, default)`.

---

## 10. Example: minimal new module

**modules/example-resource/variables.tf**

```hcl
# Spec: name, resource_group_name, location (required); sku (optional)

variable "examples" {
  description = "Map of Example Resource configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Standard")
    tags                = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
```

**modules/example-resource/main.tf**

```hcl
resource "azurerm_example_resource" "main" {
  for_each = var.examples

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku

  tags = merge(var.common_tags, each.value.tags)
}
```

**modules/example-resource/outputs.tf**

```hcl
output "ids" {
  value = { for k, v in azurerm_example_resource.main : k => v.id }
}
```

**Root:** Add `variable "examples" { type = any; default = {} }` and the `module "example_resource" { ... }` block as in section 7.

---

This note is the standard for **creating any module** in this project. Keep it next to the repo and follow it so all modules stay consistent and easy to maintain.
