# Example Terraform Project

Use this example Terraform project to see how [`infracost`](https://www.infracost.io) works.
To try it:
```
git clone https://github.com/infracost/example-terraform.git
cd example-terraform
# You can play with `aws/main.tf` and `aws/infracost-usage.yml`, and re-run infracost to compare costs
infracost --terraform-dir aws --usage-file aws/infracost-usage.yml

# GCP example:
infracost --terraform-dir google --usage-file google/infracost-usage.yml
```
