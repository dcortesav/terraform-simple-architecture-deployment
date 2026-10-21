# Huawei Cloud RPA Infrastructure (Terraform)

Provisions the RPA infrastructure on Huawei Cloud as described in
`huawei_cloud_terraform_specification.md`, using a modular Terraform layout.

The specification document was used **only to identify which parameters must be
configured**. No example values from the document are hardcoded — every
configurable value is a variable that you fill in via `terraform.tfvars`.

## Infrastructure created

| Layer | Resources |
| :--- | :--- |
| Network | 1 VPC, 1 subnet |
| Security | 2 security groups (dataBase-sg + ldap-sg) with explicit port rules |
| Storage | 2 SFS Turbo file systems |
| Compute | 6 ECS instances (static private IPs) |
| VPN | 2 public EIPs + 1 VPN gateway |

## Project structure

```
terraform_RPA/
├── versions.tf                 # Terraform & provider version constraints
├── provider.tf                 # Huawei Cloud provider (credentials, region, project)
├── main.tf                     # Module composition
├── variables.tf                # Root input variables
├── outputs.tf                  # Root outputs
├── terraform.tfvars.example    # Copy to terraform.tfvars and fill in values
└── modules/
    ├── network/                # VPC + subnet
    ├── security/               # 2 security groups (database + ldap) + rules
    ├── storage/                # SFS Turbo instances
    ├── compute/                # ECS instances
    └── vpn/                    # EIPs + VPN gateway
```

## Prerequisites

- Terraform >= 1.3.0
- A Huawei Cloud account with an access key (AK) and secret key (SK)
- The target region, project ID, and OS image names for your ECS instances
- The target region must have at least **two** availability zones for the HA
  VPN gateway (single-AZ regions will work for all other resources)

## Usage

```bash
# 1. Copy the variable template and fill in your values
cp terraform.tfvars.example terraform.tfvars
#   ...edit terraform.tfvars...

# 2. Initialise, review the plan, and apply
terraform init
terraform plan
terraform apply
```

### Credentials

You can provide credentials in either of two ways:

1. Set `access_key` / `secret_key` in `terraform.tfvars` (the file is
   git-ignored), **or**
2. Export the environment variables `HW_ACCESS_KEY` and `HW_SECRET_KEY` and
   leave the two variables blank/null in `terraform.tfvars`.

## Notes

- **Pay-per-use billing**: all resources that support a charging mode are
  explicitly set to `charging_mode = "postPaid"` (pay-per-use): ECS instances,
  SFS Turbo file systems, and the two VPN EIPs. The VPN gateway itself has no
  charging-mode argument. The `charging_mode` field was removed from the
  `ecs_instances` variable so billing mode can't be accidentally overridden.
- **Dynamic ECS flavors**: instead of hard-coding a `flavor_id`, each instance
  specifies `vcpu_count` and `memory_gb`. The `huaweicloud_compute_flavors` data
  source looks up a matching flavor in the instance's assigned availability zone.
  If a specific vCPU/memory combination returns no flavors, set the optional
  `performance_type` field (e.g. `computingv3`, `highmem`) to narrow the search,
  or adjust the vCPU/memory to a combination that exists in your region.
- **ECS image compatibility**: the image must be compatible with the selected
  flavor. Older images (e.g. Ubuntu 16.04) do not support modern flavor
  generations — use a current image (e.g. Ubuntu 24.04) to avoid
  `Ecs.0005: The flavor does not match the image`.
- **Dynamic ECS images**: instead of hard-coding an `image_id`, each instance
  specifies an `image_name` pattern. The `huaweicloud_images_image` data source
  resolves it to the most recent public image matching that name (via
  `name_regex`). Use a pattern such as `Ubuntu 22.04 server 64bit`.
- **Random availability zones**: availability zones are **not** hard-coded. The
  `huaweicloud_availability_zones` data source lists the region's zones, and the
  `random` provider assigns one to every resource that supports an AZ (subnet,
  each SFS Turbo, and each ECS). The assigned zones are stable in Terraform state
  and exported so you can see what was chosen. To re-randomize, taint the
  corresponding `random_integer` resource. The VPN gateway uses a separate
  `huaweicloud_vpn_gateway_availability_zones` data source (see above) instead of
  random assignment.
- **ECS static IPs**: the current Huawei Cloud provider uses the
  `fixed_ip_v4` argument inside the `network` block (the specification
  referred to `fixed_ip_v2` / `fixed_ip`, which were renamed in newer provider
  versions). Each ECS instance's static private IP is set via this attribute.
- **ECS credentials**: for each instance set **either** a password (in the
  sensitive `ecs_admin_passwords` map) **or** a key pair (the `key_pair` field in
  the `ecs_instances` map). Passwords are kept in a separate sensitive variable
  so they are masked in plan output while still allowing the instances to be
  created with `for_each`.
- **ECS VPC binding**: the VPC is implied by the subnet, so the compute module
  only receives the subnet ID (no separate `vpc_id` argument exists on
  `huaweicloud_compute_instance`).
- **VPN connection capacity**: this is determined by the gateway `flavor`
  (e.g. `Professional1`) and is not a separate Terraform argument.
- **VPN EIPs**: two dedicated-bandwidth (`share_type = "PER"`) EIPs are created
  and attached to the VPN gateway via the `eip1` / `eip2` blocks.
- **VPN gateway availability zones**: queried from the
  `huaweicloud_vpn_gateway_availability_zones` data source (filtered by flavor
  and `attachment_type = "vpc"`) so only zones that actually support the
  requested flavor are used. The first two supporting zones are assigned to the
  HA gateway.
- **SFS Turbo naming**: SFS Turbo names must start with a letter, be 4-64
  characters, and contain only letters, digits, hyphens, and underscores (no
  spaces or special characters like `&`). A variable validation rule catches
  invalid names at `terraform plan` time.
- **Security groups**: two security groups are created — `dataBase-sg` (assigned
  to all ECS instances except LDAP) and `ldap-sg` (assigned to the instance whose
  name is `LDAP`). Default rules are deleted (`delete_default_rules = true`) so
  all rules are managed explicitly. Both groups have: all egress, SSH (TCP 22)
  from a configurable CIDR, and full intra-group communication. `dataBase-sg`
  additionally allows database service ports (3306, 3307, 3308, 3316, 33060,
  33070, 33080, 27017, 5432, 6379, 6380) and NFS (2049) from the VPC.
  `ldap-sg` allows LDAP (389) from the VPC and ICMP from anywhere. Port rules
  follow `sg-ports.md`. The SFS Turbo file systems use `dataBase-sg`.

## Reference documentation

- ECS: https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/compute_instance
- SFS Turbo: https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/sfs_turbo
- VPN Gateway: https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/resources/vpn_gateway
- Availability zones (data): https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/data-sources/availability_zones
- Compute flavors (data): https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/data-sources/compute_flavors
- Images (data): https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs/data-sources/images_image
