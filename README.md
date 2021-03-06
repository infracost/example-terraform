# Example Terraform Project

Use this example Terraform project to see how [`infracost`](https://www.infracost.io) works.
- sample1 contains a basic AWS Terraform project with an EC2 instance and a Lambda function.
- sample2 contains a basic Google Terraform project with a Compute Instance and a DNS record set.
- sample3 contains a basic Azure Terraform project with a Linux Virtual Machine and an Azure Function. Use `infracost breakdown --path sample3/plan.json` to run this sample. Otherwise, you'll need to use one of the [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) authentication methods as Terraform `plan` cannot be run without Azure credentials.

To try Infracost with the samples:
```
git clone https://github.com/infracost/example-terraform.git
cd example-terraform/sample1

# Play with main.tf and re-run to compare costs
infracost breakdown --path .

# Show diff of monthly costs, edit the yaml file and re-run to compare costs
infracost diff --path . --sync-usage-file --usage-file infracost-usage.yml
```
