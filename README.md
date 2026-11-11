# AWS Security Baseline — Scaffolding (OpenTofu)

A scaffolding for building an AWS security baseline with OpenTofu.
This project is a **starting point**, not a ready-made solution. Its structure, modules
and defaults are kept simple on purpose so they are easy to copy, change and extend
to fit your account or organization.

> **Status:** template. It has never been applied to any account.
> Review and adjust every value before using it in a real environment.

References: **CIS AWS Foundations Benchmark v3.0** and
**AWS Foundational Security Best Practices**.

---

## Why scaffolding?

- **Patterns first, details later.** What you get is the pattern: folder layout, module
  boundaries, multi-region deployment, state encryption, tests and CI.
- **Safe but generic defaults.** Values follow CIS recommendations and are not yet tuned
  to your business, cost or compliance needs.
- **Easy to take apart.** Each module stands on its own. Keep what you need, drop the rest.

## What's included

| Area | Contents | Location |
|---|---|---|
| Logging | Multi-region CloudTrail + CloudWatch Logs, KMS-encrypted | `modules/cloudtrail` |
| Secure bucket | Locked-down S3 bucket pattern, reused everywhere | `modules/secure-bucket` |
| Encryption | KMS key with per-service key policy | `modules/kms` |
| Detection | GuardDuty, Security Hub, AWS Config + sample rules | `modules/guardduty`, `securityhub`, `config` |
| Hardening | Password policy, account-level S3 BPA, EBS encryption, IMDSv2, Access Analyzer, etc. | `modules/account-hardening`, `regional-hardening` |
| Alerting | SNS + 15 CIS alarms + EventBridge for Security Hub findings | `modules/alerting` |
| State | State bucket + KMS, client-side state encryption (OpenTofu), S3 native locking | `bootstrap/` |
| Multi-region | Provider `for_each` (OpenTofu ≥ 1.9) | `environments/prod/providers.tf` |
| Quality | Offline unit tests (mock provider), tflint, trivy, checkov, pre-commit, GitHub Actions | `tests/`, `Makefile`, `.github/` |

Default region: **Singapore (`ap-southeast-1`)**.

## Layout

```
.
├── bootstrap/               # state bucket + KMS key (run once)
├── environments/
│   └── prod/                # example root module; copy it for other envs
├── modules/
│   ├── kms/
│   ├── secure-bucket/       # + tests/
│   ├── cloudtrail/
│   ├── account-hardening/   # global settings (once per account)
│   ├── config-role/         # IAM role for AWS Config (global)
│   ├── config/
│   ├── guardduty/
│   ├── securityhub/
│   ├── regional-hardening/
│   ├── regional-baseline/   # wraps the regional modules, called once per region
│   └── alerting/            # + tests/
├── Makefile
├── .tflint.hcl
├── .pre-commit-config.yaml
└── .github/workflows/ci.yml
```

**Module rules:**
- Modules have no `provider` blocks. Providers are always passed in from the root module.
- **Global** resources (IAM, CloudTrail) are called once from the root.
- **Regional** resources go through `regional-baseline`, which is called once per region.

## Quick start

### 1. Copy and customize

```bash
cp -r aws-security-baseline my-security-baseline
cd my-security-baseline
```

Things you **must** review first:

| What | Where |
|---|---|
| Project name / resource prefix | `variable "project"` in `environments/prod/variables.tf` and `bootstrap/variables.tf` |
| Regions | `home_region`, `additional_regions` |
| Alert recipients | `alert_emails` |
| Security Hub standards | `securityhub_standards` |
| Config rules | `config_rules`, `config_global_rules` |
| Log retention | `log_retention_days`, `cloudtrail_log_group_retention_days` |
| GuardDuty features (cost) | `guardduty_features` |
| Required org tags | `tags` |

### 2. Local checks (safe, never touch AWS)

```bash
make fmt-check   # formatting
make validate    # validate without a backend
make test        # unit tests with a mock provider, no credentials needed
make lint scan   # needs tflint / trivy / checkov
```

### 3. Deploy (manual, when you are ready)

```bash
# a. bootstrap state
export TF_VAR_state_passphrase='a-long-passphrase-of-at-least-16-chars'
make bootstrap            # also writes environments/prod/backend.hcl

# b. variables
cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars

# c. plan → review → apply
make init
make plan
make apply
```

After applying, confirm the SNS subscription email sent by AWS.

## Extending

**Add an environment** (e.g. `staging`):
```bash
cp -r environments/prod environments/staging
# change the key in backend.hcl and the environment value in tfvars
make plan ENV=staging
```

**Add a region:** set `additional_regions = ["ap-southeast-3"]`.
To remove a region, first move it to `regions_pending_removal`, apply, then delete it.

**Add a Config rule:** add an entry to `config_rules` (every region) or
`config_global_rules` (home region only):
```hcl
ec2-no-public-ip = { identifier = "EC2_INSTANCE_NO_PUBLIC_IP" }
```

**Add a new module** (e.g. `inspector`):
1. Create `modules/inspector/` with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
2. If it is regional, call it from `modules/regional-baseline/main.tf`.
   If it is global, call it from `environments/prod/main.tf`.
3. Add tests under `modules/inspector/tests/` and list the module in `TESTED` in the `Makefile`.

**Add an alert destination** (Slack, PagerDuty, etc.): subscribe to the `alerts_topic_arn` output.

## Roadmap ideas

- [ ] Multi-account: AWS Organizations, delegated admin, organization trail
- [ ] Service Control Policies (region deny, prevent disabling CloudTrail/GuardDuty)
- [ ] S3 Object Lock for the log bucket
- [ ] VPC Flow Logs, Amazon Inspector, Macie
- [ ] Slack alerts via AWS Chatbot
- [ ] IAM Identity Center instead of IAM users
- [ ] Automatic remediation via Config remediation or Lambda
- [ ] Deployment pipeline (plan on PR, manual apply with approval)

## Before using it for real

- **Services already enabled.** An existing GuardDuty detector, Security Hub, Config recorder
  or CloudTrail will conflict. Import them first, for example:
  ```bash
  tofu -chdir=environments/prod import \
    'module.regional_baseline["ap-southeast-1"].module.guardduty.aws_guardduty_detector.this' <detector-id>
  ```
- **AWS Organizations.** If a delegated admin already manages these services at the org
  level, enable them there and drop the matching modules here.
- **Default security groups** in default VPCs will be emptied
  (set `restrict_default_security_groups = false` to skip).
- **Cost.** GuardDuty, Security Hub, Config and CloudTrail data events are billed.
  `RUNTIME_MONITORING` and S3 data events are off by default.
- **Opt-in regions.** If you move to an opt-in region (e.g. `ap-southeast-3` Jakarta),
  enable that region in the account first.
- **Bootstrap passphrase.** Store it safely; without it the bootstrap state cannot be read.

## Requirements

- OpenTofu ≥ 1.10 (tested with 1.13)
- AWS credentials with admin rights in the target account (only for deploying)
- Optional: `tflint`, `trivy`, `checkov`, `pre-commit`
