# API-driven Terraform Cloud cost estimates

This configuration intentionally has no `terraform.cloud` block. The accompanying
script uploads this directory and creates runs through the Terraform Cloud API,
keeping it independent from `aws/example-terraform-cli`.

Run from the repository root:

```sh
bash aws-dev/run-cost-estimate.sh
```

The script uses `TFC_TOKEN` when set, otherwise the token stored by
`terraform login` for `app.terraform.io`. It creates or reuses the
`travis-dev/example-terraform-api` remote-execution workspace, uploads an
archived configuration version, and creates a plan-only run. The workspace
must already exist; use `TFC_CREATE_WORKSPACE=true` only when bootstrapping a
new workspace.

Override the target without changing source:

```sh
TFC_ORGANIZATION=my-org TFC_WORKSPACE=my-api-workspace \
  bash aws-dev/run-cost-estimate.sh
```

On a successful cost estimate, the unmodified API payload is written to
`cost-estimate-<run-id>.json`. These output files are ignored by the script
when it builds the next configuration archive; do not commit them if they
contain data you do not want to share.

## GitHub Actions

`.github/workflows/terraform-cloud-cost-estimate.yml` runs this script for
pull requests opened by the repository owner from a branch in this repository.
Add a `TFC_API_TOKEN` GitHub Actions secret containing a Terraform Cloud team
token that has access only to `example-terraform-api` and can queue plans, but
cannot apply or administer the workspace. Fork and collaborator pull requests
are skipped and never receive the secret.
