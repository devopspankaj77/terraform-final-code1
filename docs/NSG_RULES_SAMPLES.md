# NSG Rules Samples (VNet Module)

**Subnet-specific rules (recommended):** Define **`nsg_rules` inside each subnet** for clarity and least-privilege. Each subnet’s NSG gets only that subnet’s rules (e.g. web: HTTP/HTTPS; app: SSH/RDP from VNet; data: SQL from app subnet). If a subnet omits `nsg_rules`, the VNet-level **`nsg_rules`** are used as fallback. **`pe_subnet_nsg_rules`** apply only to the private endpoint subnet.

**Where to put rules:** In `vnets.<key>.subnets.<subnet_key>.nsg_rules` for per-subnet, or `vnets.<key>.nsg_rules` for shared fallback. Rule keys must be unique within each map. **Priority** must be unique per NSG (100, 110, 120, …). Use either **`source_address_prefix`** (single) or **`source_address_prefixes`** (list); same for destination.

---

## 1. Allow SSH from VNet only (app / jump subnet)

```hcl
allow_ssh = {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "VirtualNetwork"   # VNet + connected networks
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "Allow SSH from VNet"
}
```

---

## 2. Allow RDP from VNet only (Windows / bastion targets)

```hcl
allow_rdp = {
  name                        = "AllowRDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "Allow RDP from VNet"
}
```

---

## 3. Restrict RDP/SSH to jump box or VPN (prod-safe)

Use a **single** CIDR (e.g. jump subnet or VPN):

```hcl
allow_rdp_from_jump = {
  name                        = "AllowRDPFromJump"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.0.1.0/24"    # e.g. web/jump subnet
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "RDP only from jump subnet"
}
```

Or **multiple** CIDRs (use prefix list; omit `source_address_prefix` when using `source_address_prefixes`):

```hcl
allow_ssh_from_specific = {
  name                         = "AllowSSHFromSpecific"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  # source_address_prefix      = omit when using source_address_prefixes
  destination_address_prefix   = "*"
  source_address_prefixes     = ["10.0.1.0/24", "192.168.1.0/24"]   # jump + VPN
  destination_address_prefixes = []
  description                  = "SSH from jump and VPN only"
}
```

---

## 4. Web subnet – allow HTTP/HTTPS inbound

```hcl
allow_http = {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"               # or "Internet", or a load balancer CIDR
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "Allow HTTP"
}
allow_https = {
  name                        = "AllowHTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "Allow HTTPS"
}
```

---

## 5. App subnet – allow only from web subnet (tiered)

```hcl
allow_from_web_subnet = {
  name                         = "AllowFromWebSubnet"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"            # or "80-443" for a range
  source_address_prefix        = "10.0.1.0/24"    # web subnet
  destination_address_prefix   = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                  = "Allow from web tier only"
}
```

---

## 6. Data subnet – allow SQL from app subnet only

```hcl
allow_sql_from_app = {
  name                         = "AllowSQLFromApp"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "1433"           # MS SQL; use 3306 for MySQL
  source_address_prefix        = "10.0.2.0/24"    # app subnet
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                  = "SQL from app subnet only"
}
```

---

## 7. Private endpoint subnet – allow HTTPS outbound to Azure

Use in **`pe_subnet_nsg_rules`** only:

```hcl
pe_subnet_nsg_rules = {
  allow_https_out = {
    name                        = "AllowHttpsOutbound"
    priority                    = 100
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "AzureCloud"    # Azure service tag
    source_address_prefixes     = []
    destination_address_prefixes = []
    description                 = "Allow HTTPS to Azure for Private Link"
  }
}
```

---

## 8. Outbound – allow HTTPS to Internet (e.g. for app subnet)

```hcl
allow_https_out = {
  name                        = "AllowHttpsOut"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "Allow outbound HTTPS"
}
```

---

## 9. Deny rule (use higher priority number = lower precedence; Azure default is Deny)

```hcl
# Example: deny all inbound from Internet (use after specific allows)
deny_internet_in = {
  name                        = "DenyInternetInbound"
  priority                    = 4096             # lower priority = evaluated later
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  source_address_prefixes     = []
  destination_address_prefixes = []
  description                 = "Deny all from Internet"
}
```

---

## 10. Azure service tags (handy prefixes)

| Tag               | Use case                    |
|-------------------|-----------------------------|
| `VirtualNetwork`  | Traffic from same VNet, peered VNets, on-prem via VPN/ER |
| `AzureCloud`      | Outbound to Azure services (e.g. Private Link, management) |
| `Internet`        | Outbound to public Internet |
| `AzureLoadBalancer` | Health probes from Azure load balancer |

---

## 11. Example: full `nsg_rules` for web + app + bastion (shared when nsg_per_subnet = true)

When **`nsg_per_subnet = true`**, the **same** `nsg_rules` are applied to **every** subnet (web, app, data, bastion). So use a set that makes sense for all, or use the most restrictive set and add more rules via the portal until the module supports per-subnet rules:

```hcl
nsg_rules = {
  allow_ssh = {
    name                        = "AllowSSH"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    source_address_prefixes     = []
    destination_address_prefixes = []
    description                 = "Allow SSH from VNet"
  }
  allow_rdp = {
    name                        = "AllowRDP"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3389"
    source_address_prefix       = "VirtualNetwork"
    destination_address_prefix  = "*"
    source_address_prefixes     = []
    destination_address_prefixes = []
    description                 = "Allow RDP from VNet"
  }
}
```

Use **`pe_subnet_nsg_rules`** for rules that apply **only** to the private endpoint subnet (see section 7).

---

## 12. Field reference (per rule)

| Field                         | Required | Example / note |
|-------------------------------|----------|-----------------|
| `name`                        | Yes      | Unique per NSG, no spaces |
| `priority`                    | Yes      | 100–4096; lower = higher precedence |
| `direction`                   | Yes      | `"Inbound"` or `"Outbound"` |
| `access`                      | Yes      | `"Allow"` or `"Deny"` |
| `destination_port_range`      | Yes      | Port or range, e.g. `"443"`, `"80-443"` |
| `protocol`                    | No       | `"Tcp"`, `"Udp"`, `"*"` (default) |
| `source_port_range`           | No       | Default `"*"` |
| `source_address_prefix`       | No*      | CIDR or service tag; *omit if using list |
| `destination_address_prefix`  | No       | Default `"*"` |
| `source_address_prefixes`     | No       | List of CIDRs; use **or** `source_address_prefix` |
| `destination_address_prefixes`| No       | List; use **or** `destination_address_prefix` |
| `description`                 | No       | Documentation only (if supported by provider) |
