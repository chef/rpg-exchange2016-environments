terraform {
  required_version = "~> 0.12"
}

# Configure variables
variable "aws_region" {}
variable "aws_profile" {}

# just to stop warnings
variable "execute_script" {}
variable "setup_script" {}
variable "remediation_profile" {}
variable "inspec_profile" {}

variable "ssh_key_name" {}

variable "instance_password" {}

provider "aws" {
  version = "~> 2.7"
  region = var.aws_region
  profile = var.aws_profile
  shared_credentials_file = "~/.aws/credentials"
}

resource "aws_key_pair" "generated_key" {
  key_name = var.ssh_key_name
  public_key = tls_private_key.priv_key.public_key_openssh
}

resource "tls_private_key" "priv_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_cloudformation_stack" "exchange2016" {
  name = "exchange-stack"

  parameters = {
    AvailabilityZones = "eun1-az1,eun1-az2",
    ADServer1NetBIOSName = "DC1",
    ADServer1InstanceType = "t3.large",
    ADServer2InstanceType = "t3.large",
    ADServer2NetBIOSName = "StopDC2",
    DomainAdminUser = "ExchangeAdmin",
    DomainAdminPassword = var.instance_password,
    DomainDNSName = "exchexample.com",
    DomainNetBIOSName = "exchexample",
    ExchangeNode1NetBIOSName = "ExchNodeMain",
    ExchangeNode2NetBIOSName = "StopExchNode2",
    ExchangeNodeInstanceType = "m5.xlarge",
    ExchangeServerVersion = "2016",
    FileServerInstanceType = "t3.small",
    FileServerNetBIOSName = "StopFileServer",
    KeyPairName = var.ssh_key_name,
    QSS3BucketName = "aws-quickstart",
    QSS3BucketRegion = "us-east-1",
    QSS3KeyPrefix = "quickstart-microsoft-exchange/",
    RDGWCIDR = "0.0.0.0/0",
    RDGWInstanceType = "m5.large"
  }

  template_url = "https://aws-quickstart.s3.amazonaws.com/quickstart-microsoft-exchange/templates/exchange-master.template"
  capabilities = ["CAPABILITY_IAM"]
  timeout_in_minutes = "300"
  disable_rollback = "true"

  timeouts {
    create = "240m"
  }

  tags = {
    Name = "Exchange2016Stack"
  }
}