# Example Terraform Project

Use this example Terraform project to see how [`infracost`](https://www.infracost.io) works.
- sample1 contains a basic AWS Terraform project with an EC2 instance and a Lambda function
- sample2 contains a basic Google Terraform project with a Compute Instance and a DNS record set

To try Infracost with the samples:
```
git clone https://github.com/infracost/example-terraform.git
cd example-terraform

# Play with sample1/main.tf and re-run to compare costs
infracost breakdown --path sample1

# Show diff of monthly costs, edit the yaml file and re-run to compare costs
infracost diff --path sample1 --usage-file sample1/infracost-usage.yml
```
