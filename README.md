# terraform-transmission-aws

A [Terraform](terraform) configuration for provisioning an EC2 instance for running [Transmission](transmission) over [OpenVPN](openvpn) with completed downloads automatically copied to an S3 bucket.

This is intended for ephemeral deployments where you may spin-up an instance for an hour or two and then destroy it. It's not intended for long-running use.

## Prerequisites

In order to use this configuration you MUST have:

- An [AWS](aws) account
- An existing EC2 keypair
- An existing S3 bucket
- AWS credentials on the machine you will run `terraform apply` from
- A supported VPN provider (see providers [here](https://haugene.github.io/docker-transmission-openvpn/supported-providers/))
- An understanding of [Terraform](terraform) and it installed on your system

## Setup

Initialise terraform

```bash
terraform init
```

You will need to provide values for all variables defined at the top of `stack.tf`. The easy way to do this is by creating a `terraform.tfvars` file. See the [terraform docs](https://www.terraform.io/docs/configuration/variables.html#variable-definitions-tfvars-files) for more information.

Once you've defined your variables apply the configuration.

```bash
terraform apply
```

Once the configuration is applied you will get the output URL of Transmission's WebUI. Note you may need to wait a minute or two for the software provisioning to complete before the instance is available to use.

Once you are finished with the instance you can simply destroy it.

```bash
terraform destroy
```

[terraform]: https://www.terraform.io/
[transmission]: https://transmissionbt.com/
[openvpn]: https://openvpn.net/
[aws]: https://aws.amazon.com/
