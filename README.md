# AWS Security Baseline — Template (OpenTofu)

A small starter template for the security setup of a new AWS account.
It is meant as a **first init**: one account, one region, sensible defaults.
Copy it, change the values, and extend it as your needs grow.

> **Status:** template. It has never been applied to any account.
> Review every value before using it for real.

Based on **CIS AWS Foundations Benchmark v3.0** and
**AWS Foundational Security Best Practices**.

## What you get

| Area | Contents | Module |
|---|---|---|
| Logging | Multi-region CloudTrail with log file validation, KMS-encrypted | `cloudtrail` |
| Log storage | Private, versioned, encrypted, TLS-only S3 bucket | `secure-bucket` |
| Encryption | One KMS key with automatic rotation | `kms` |
| Detection | GuardDuty, Security Hub (FSBP + CIS v3), AWS Config recorder | `guardduty`, `securityhub`, `config` |
| Hardening | Password policy, S3 Block Public Access, EBS encryption by default, IMDSv2, no public snapshots/AMIs, Access Analyzer, empty default security group | `hardening` |
| Alerting | Encrypted SNS topic + email for HIGH/CRITICAL Security Hub findings | `alerting` |
| State | S3 bucket + KMS key for remote state, S3 native locking | `bootstrap/` |

Default region: **Singapore (`ap-southeast-1`)**.

## Layout

```
.
├── bootstrap/           # state bucket + KMS key (run once)
├── environments/prod/   # root module that wires everything together
├── modules/             # one small module per service
├── Makefile
└── .github/workflows/ci.yml
```

## Usage

### 1. Check locally (safe, never touches AWS)

```bash
make check    # format, validate, unit tests with a mock provider
```

### 2. Set your values

```bash
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
```

| Variable | Purpose |
|---|---|
| `project`, `environment` | Prefix for resource names |
| `region` | Where the baseline lives |
| `allowed_account_ids` | Optional guard against applying to the wrong account |
| `alert_emails` | Who receives security alerts |
| `securityhub_standards` | `aws-foundational`, `cis-v3`, `cis-v1.4`, `nist-800-53`, `pci-dss` |
| `log_retention_days` | How long logs stay in S3 |

### 3. Deploy (manual)

```bash
make bootstrap    # prints the backend config when done
# paste that output into environments/prod/backend.hcl

make init
make plan         # read the plan carefully
make apply
```

Then confirm the SNS subscription email from AWS.

## Good to know

- **Standalone accounts.** The template assumes an account that is not centrally managed.
  If your AWS Organization already runs GuardDuty, Security Hub, Config or an organization
  trail for you, remove those modules from `environments/prod/main.tf` and keep `hardening`.
- **Already enabled services.** An existing GuardDuty detector, Security Hub, or Config
  recorder will conflict. Import it first (`tofu import`) or remove the module.
- **Default security groups** in default VPCs are emptied
  (set `restrict_default_security_groups = false` in the `hardening` module to skip).
- **One region.** CloudTrail records every region, but GuardDuty, Security Hub and Config
  only watch the chosen one.
- **Cost.** GuardDuty, Security Hub and Config are billed by usage.
- **Manual steps.** Root MFA and the account security contact are not managed here.

## Ideas for later

- More regions or multiple accounts (AWS Organizations, SCPs)
- CloudWatch alarms for CIS monitoring controls
- VPC Flow Logs, Inspector, Macie
- Slack alerts via AWS Chatbot
- OpenTofu client-side state encryption

## Requirements

- OpenTofu ≥ 1.10 (tested with 1.13)
- AWS credentials with admin rights in the target account (only for deploying)
