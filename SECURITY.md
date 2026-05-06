# Security Policy

## Supported versions

Only the `main` branch of this repository is supported. Older commits
and audit branches do not receive security fixes.

## Reporting a vulnerability

If you believe you have found a security vulnerability in this repository
or in the infrastructure it provisions, please **do not** open a public
GitHub issue. Instead, report it privately:

- Open a [private security advisory](https://github.com/melorga/infra-live/security/advisories/new) on this repository, **or**
- Email the maintainer listed in the repository profile.

Please include:

- A description of the issue and its impact.
- Steps to reproduce, or a proof of concept.
- Any relevant logs, IAM/policy snippets, or Terraform plan output
  (with secrets redacted).

We aim to acknowledge reports within 3 business days and to provide a
remediation plan within 14 days for confirmed issues.

## Scope

In scope:

- Bugs in the Terragrunt/Terraform configurations in this repo that
  result in insecure AWS resources (public buckets, overly permissive
  IAM, unencrypted storage, etc.).
- Misconfigurations in the GitHub Actions workflows under
  `.github/workflows/` (e.g. token leakage, privilege escalation).

Out of scope:

- Vulnerabilities in upstream Terraform providers or modules — please
  report those to the relevant upstream project.
- Issues that require already-compromised AWS credentials.
